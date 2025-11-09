export interface StatsigUser {
  userID: string;
  email?: string;
  [key: string]: any; // Additional user properties can be added here
}

export interface FeatureGate {
  featureName: string;
  isEnabled: boolean;
  reason?: string; // Optional reason for the feature's status
}

export interface StatsigEvent {
  eventName: string;
  user: StatsigUser;
  metadata?: Record<string, any>; // Optional metadata for the event
}