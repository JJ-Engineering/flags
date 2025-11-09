import { LogLevel, StatsigProvider } from '@statsig/react-bindings';
import type { AppProps } from 'next/app';

const StatsigApp = ({ Component, pageProps }: AppProps) => {
  const user = {
    userID: 'a-user',
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
      <Component {...pageProps} />
    </StatsigProvider>
  );
};

export default StatsigApp;
