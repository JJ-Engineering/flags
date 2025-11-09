#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"

# Detect package manager
if [ -f "$ROOT/package-lock.json" ]; then
  PM="npm"
elif [ -f "$ROOT/yarn.lock" ]; then
  PM="yarn"
elif [ -f "$ROOT/pnpm-lock.yaml" ]; then
  PM="pnpm"
else
  echo "No lockfile detected; defaulting to npm"
  PM="npm"
fi
echo "Using package manager: $PM"

# Install Statsig packages
echo "Installing @statsig/react-bindings @statsig/session-replay @statsig/web-analytics"
case "$PM" in
  npm) npm install @statsig/react-bindings @statsig/session-replay @statsig/web-analytics ;;
  yarn) yarn add @statsig/react-bindings @statsig/session-replay @statsig/web-analytics ;;
  pnpm) pnpm add -w @statsig/react-bindings @statsig/session-replay @statsig/web-analytics ;;
esac

# Add .env.local with Statsig client key if missing or missing var
ENVFILE="$ROOT/.env.local"
KEY_LINE="NEXT_PUBLIC_STATSIG_CLIENT_KEY=client-WaqZr4e99fdw4FXTjZbZ5IlDVXJY6VvScIfJyCzoeM"
if [ -f "$ENVFILE" ]; then
  if grep -q '^NEXT_PUBLIC_STATSIG_CLIENT_KEY=' "$ENVFILE"; then
    echo ".env.local already contains NEXT_PUBLIC_STATSIG_CLIENT_KEY; leaving as-is"
  else
    echo "$KEY_LINE" >> "$ENVFILE"
    echo "Appended NEXT_PUBLIC_STATSIG_CLIENT_KEY to .env.local"
  fi
else
  echo "$KEY_LINE" > "$ENVFILE"
  echo "Created .env.local with NEXT_PUBLIC_STATSIG_CLIENT_KEY"
fi

# Detect router type
if [ -d "$ROOT/app" ]; then
  ROUTER="app"
elif [ -d "$ROOT/pages" ]; then
  ROUTER="pages"
else
  echo "No app/ or pages/ directory found. Exiting."
  exit 1
fi
echo "Detected router: $ROUTER"

# Create files / modify files based on router
if [ "$ROUTER" = "app" ]; then
  echo "Integrating for App Router..."

  # Create app/my-statsig.tsx if not exists
  MY_FILE="$ROOT/app/my-statsig.tsx"
  if [ -f "$MY_FILE" ]; then
    echo "app/my-statsig.tsx already exists; skipping creation"
  else
    cat > "$MY_FILE" <<'TSFILE'
"use client";

import React from "react";
import { LogLevel, StatsigProvider } from "@statsig/react-bindings";

export default function MyStatsig({ children }: { children: React.ReactNode }) {
  const id = typeof userID !== "undefined" ? userID : "a-user";

  const user = {
    userID: id,
    // Optional additional fields:
    // email: 'user@example.com',
    // customIDs: { internalID: 'internal-123' },
    // custom: { plan: 'premium' }
  };

  return (
    <StatsigProvider
      sdkKey={process.env.NEXT_PUBLIC_STATSIG_CLIENT_KEY!}
      user={user}
      options={{ logLevel: LogLevel.Debug }}
    >
      {children}
    </StatsigProvider>
  );
}
TSFILE
    echo "Created $MY_FILE"
  fi

  # Modify app/layout.tsx: add import and wrap {children} with <MyStatsig>
  LAYOUT="$ROOT/app/layout.tsx"
  if [ -f "$LAYOUT" ]; then
    if grep -q "MyStatsig" "$LAYOUT"; then
      echo "app/layout.tsx appears to already reference MyStatsig; skipping modification"
    else
      # Add import after the first import block (if any), otherwise at top
      awk 'BEGIN{added=0}
        /^import / && added==0 { print; next }
        { if (!added) { print "import MyStatsig from \"./my-statsig\";\n"; added=1 } print }
        END{ if (!added) print "import MyStatsig from \"./my-statsig\";\n" }' "$LAYOUT" > "$LAYOUT.tmp" && mv "$LAYOUT.tmp" "$LAYOUT"

      # Wrap the first occurrence of "{children}" with <MyStatsig>...</MyStatsig>
      perl -0777 -pe 's/\{children\}/<MyStatsig>{children}<\/MyStatsig>/s if $.==1/e' "$LAYOUT" > "$LAYOUT.tmp" && mv "$LAYOUT.tmp" "$LAYOUT" || true

      echo "Modified app/layout.tsx to import and wrap children with MyStatsig"
    fi
  else
    echo "Warning: app/layout.tsx not found. Created app/my-statsig.tsx only."
  fi

else
  echo "Integrating for Pages Router..."

  APP_FILE="$ROOT/pages/_app.tsx"
  if [ ! -f "$APP_FILE" ]; then
    echo "pages/_app.tsx not found. Creating a minimal pages/_app.tsx that preserves existing pages."
    cat > "$APP_FILE" <<'TSFILE'
import type { AppProps } from "next/app";
import { LogLevel, StatsigProvider } from "@statsig/react-bindings";

export default function App({ Component, pageProps }: AppProps) {
  const id = typeof userID !== "undefined" ? userID : "a-user";

  const user = {
    userID: id,
    // Optional additional fields:
    // email: 'user@example.com',
    // customIDs: { internalID: 'internal-123' },
    // custom: { plan: 'premium' }
  };

  return (
    <StatsigProvider
      sdkKey={process.env.NEXT_PUBLIC_STATSIG_CLIENT_KEY!}
      user={user}
      options={{ logLevel: LogLevel.Debug }}
    >
      <Component {...pageProps} /> {/* Preserve all existing pages */}
    </StatsigProvider>
  );
}
TSFILE
    echo "Created pages/_app.tsx"
  else
    if grep -q "StatsigProvider" "$APP_FILE"; then
      echo "pages/_app.tsx appears to already use StatsigProvider; skipping modification"
    else
      # Add import for StatsigProvider and LogLevel near other imports
      awk 'BEGIN{added=0}
        /^import / && added==0 { print; next }
        { if (!added) { print "import { LogLevel, StatsigProvider } from \"@statsig/react-bindings\";\n"; added=1 } print }
        END{ if (!added) print "import { LogLevel, StatsigProvider } from \"@statsig/react-bindings\";\n" }' "$APP_FILE" > "$APP_FILE.tmp" && mv "$APP_FILE.tmp" "$APP_FILE"

      # Insert user id + user const before the return inside App
      perl -0777 -pe 's/(export default function\s+App\([^\)]*\)\s*\{)/$1\n  const id = typeof userID !== "undefined" ? userID : "a-user";\n\n  const user = {\n    userID: id,\n    // Optional additional fields:\n    // email: \047user@example.com\047,\n    // customIDs: { internalID: \047internal-123\047 },\n    // custom: { plan: \047premium\047 }\n  };\n/s' "$APP_FILE" > "$APP_FILE.tmp" && mv "$APP_FILE.tmp" "$APP_FILE" || true

      # Wrap the component render <Component {...pageProps} /> with StatsigProvider
      perl -0777 -pe 's/<Component\s+\{\.\.\.pageProps\}\s*\/>/<StatsigProvider\n      sdkKey={process.env.NEXT_PUBLIC_STATSIG_CLIENT_KEY!}\n      user={user}\n      options={{ logLevel: LogLevel.Debug }}>\n      <Component {...pageProps} />\n    <\/StatsigProvider>/s' "$APP_FILE" > "$APP_FILE.tmp" && mv "$APP_FILE.tmp" "$APP_FILE" || true

      echo "Modified pages/_app.tsx to add StatsigProvider and user initialization"
    fi
  fi
fi

echo "Integration script finished. Please review the modified files before committing."