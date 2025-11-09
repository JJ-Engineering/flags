import { useEffect, useState } from 'react';
import { useStatsig } from 'statsig-react';

interface FeatureGateProps {
  feature: string;
  children: React.ReactNode;
}

const FeatureGate: React.FC<FeatureGateProps> = ({ feature, children }) => {
  const { isFeatureEnabled } = useStatsig();
  const [isEnabled, setIsEnabled] = useState(false);

  useEffect(() => {
    const checkFeature = async () => {
      const enabled = await isFeatureEnabled(feature);
      setIsEnabled(enabled);
    };

    checkFeature();
  }, [feature, isFeatureEnabled]);

  return isEnabled ? <>{children}</> : null;
};

export default FeatureGate;