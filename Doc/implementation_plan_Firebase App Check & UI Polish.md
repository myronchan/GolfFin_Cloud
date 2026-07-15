# Implementation Plan: Firebase App Check & UI Polish

This plan covers implementing Phase 3 (Firebase App Check Security) and polishing the mobile app's empty states and error handling.

> [!WARNING]
> **Firebase Project Required**
> Since this app does not currently use Firebase, implementing App Check requires you to manually create a Firebase project in the Google Cloud Console, register your iOS/Android apps, and download the `GoogleService-Info.plist` and `google-services.json` files. I will write the code, but you will need to perform the console setup!

## Open Questions
1. **Firebase Configuration**: Do you already have a Firebase project created for GolfFin? If not, you will need to create one, enable App Check, and drop the config files into the project before the mobile app will build successfully.
2. **Empty State Graphics**: For the generic Empty State component, would you prefer an Ionicons icon (e.g. a magnifying glass / golf club) or do you have a specific custom illustration you'd like to use? (I will use Ionicons by default).

## Proposed Changes

### Component 1: Firebase App Check (React Native Frontend)
- **Install Dependencies**: `@react-native-firebase/app` and `@react-native-firebase/app-check`.
- **Initialization**: Update `_layout.tsx` to initialize Firebase App Check using the Apple DeviceCheck / Play Integrity providers (and a Debug provider for the simulator).
- **API Interceptor**: Update `api/client.ts` to automatically fetch the Firebase App Check token and attach it as the `X-Firebase-AppCheck` header to all Axios requests.

### Component 2: Firebase App Check (C# Web API)
- **Install Dependencies**: Add `FirebaseAdmin` NuGet package to `GolfFinWebApi`.
- **Middleware**: Create a custom `AppCheckMiddleware.cs` that intercepts all incoming requests to `/api/*`, extracts the `X-Firebase-AppCheck` header, and verifies it against the Firebase Admin SDK.
- **Service Registration**: Update `Program.cs` to inject the Firebase Admin SDK and register the middleware in the pipeline before the JWT authentication.

### Component 3: UI Polish & Empty States
- **Empty State Component**: Create `src/components/empty-state.tsx` displaying a custom icon, title, and descriptive message.
- **Implement in Feeds**: Update the following screens to display the Empty State when data arrays are empty, instead of a blank screen:
  - `home.tsx` (No active listings found)
  - `my-listings.tsx` (You haven't posted any listings)
  - `iso-feed.tsx` (No ISO requests active right now)
  - `trade-offers.tsx` (No trade offers sent or received)
  - `order-history.tsx` (No purchases or sales found)
  - `inbox.tsx` (No messages yet)
- **Error Handling**: Standardize the display of API error messages in these screens, ensuring `setLoading(false)` always runs in a `finally` block and errors are shown inline.

## Verification Plan
### Automated Tests
- Run `dotnet build` on the backend to ensure the new middleware compiles.
- Run `npx expo lint` and TypeScript checks on the React Native code.

### Manual Verification
- We will configure Firebase App Check in **Debug Mode** initially so you can run it in the iOS Simulator without needing real physical device attestation.
- You will test viewing an empty feed (e.g., Order History on a new account) to verify the new polished Empty State UI.
