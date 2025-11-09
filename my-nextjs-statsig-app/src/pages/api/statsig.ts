import type { NextApiRequest, NextApiResponse } from 'next';
import { Statsig } from 'statsig';

const STATSIG_SERVER_KEY = process.env.STATSIG_SERVER_KEY;

if (!STATSIG_SERVER_KEY) {
  throw new Error('STATSIG_SERVER_KEY is not defined in the environment variables.');
}

Statsig.initialize(STATSIG_SERVER_KEY);

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'POST') {
    const { user } = req.body;

    if (!user) {
      return res.status(400).json({ error: 'User information is required.' });
    }

    try {
      const statsigUser = Statsig.user(user);
      const featureFlags = await Statsig.getFeatureFlags(statsigUser);
      return res.status(200).json(featureFlags);
    } catch (error) {
      return res.status(500).json({ error: 'Failed to fetch feature flags.' });
    }
  } else {
    res.setHeader('Allow', ['POST']);
    res.status(405).end(`Method ${req.method} Not Allowed`);
  }
}