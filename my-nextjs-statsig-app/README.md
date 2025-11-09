# My Next.js Statsig App

This project is a Next.js application integrated with the Statsig SDK for feature management and experimentation.

## Getting Started

To get started with this project, follow the instructions below.

### Prerequisites

- Node.js (version 14 or later)
- npm (version 6 or later)

### Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd my-nextjs-statsig-app
   ```

2. Install the dependencies:

   ```bash
   npm install
   ```

3. Set up your environment variables. Create a `.env.local` file in the root directory and add your Statsig client key:

   ```
   STATSIG_CLIENT_KEY=your_statsig_client_key
   ```

### Running the Application

To run the application in development mode, use the following command:

```bash
npm run dev
```

The application will be available at `http://localhost:3000`.

### Building for Production

To build the application for production, run:

```bash
npm run build
```

Then, start the production server:

```bash
npm start
```

### Features

- **Feature Gating**: Use the `FeatureGate` component to conditionally render content based on feature flags.
- **Custom Hooks**: Utilize the `useFeature` hook to easily check feature status in your components.
- **API Integration**: The `/api/statsig` route handles server-side requests related to Statsig features.

### Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

### License

This project is licensed under the MIT License. See the LICENSE file for details.