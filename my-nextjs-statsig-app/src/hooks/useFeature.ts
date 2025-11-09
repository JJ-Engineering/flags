import { useEffect, useState } from 'react';
import { useStatsig } from '../lib/statsig.client';

const useFeature = (featureName: string) => {
  const [isEnabled, setIsEnabled] = useState<boolean | null>(null);
  const statsig = useStatsig();

  useEffect(() => {
    const checkFeature = async () => {
      if (statsig) {
        const result = await statsig.checkGate(featureName);
        setIsEnabled(result);
      }
    };

    checkFeature();
  }, [featureName, statsig]);

  return isEnabled;
};

export default useFeature;