import { AppProps } from 'next/app';
import { StatsigProvider } from 'statsig-react';
import { useEffect } from 'react';

const StatsigApp = ({ Component, pageProps }: AppProps) => {
  useEffect(() => {
    // Initialize Statsig SDK here if needed
  }, []);

  return (
    <StatsigProvider
      clientKey={process.env.NEXT_PUBLIC_STATSIG_CLIENT_KEY}
      user={{}} // Provide user information if available
    >
      <Component {...pageProps} />
    </StatsigProvider>
  );
};

export default StatsigApp;