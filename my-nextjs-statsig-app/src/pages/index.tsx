import { useEffect, useState } from 'react';
import { useFeature } from '../hooks/useFeature';

const Home = () => {
  const { isEnabled } = useFeature('newHomepageFeature');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Simulate loading time
    const timer = setTimeout(() => {
      setLoading(false);
    }, 1000);
    return () => clearTimeout(timer);
  }, []);

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div>
      <h1>Welcome to My Next.js Statsig App</h1>
      {isEnabled ? (
        <p>The new homepage feature is enabled!</p>
      ) : (
        <p>The new homepage feature is not enabled.</p>
      )}
    </div>
  );
};

export default Home;