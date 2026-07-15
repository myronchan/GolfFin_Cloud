# Final Steps for Firebase App Check Configuration

Before publishing your app to the App Store or Google Play Store, you must complete the Firebase setup and enable App Check validation on your backend. Currently, the backend skips validation (`Firebase:EnableAppCheck = false`) and the mobile app is wrapped in a `try...catch` to prevent simulator crashes.

Follow these steps to fully configure Firebase App Check for production:

## Step 1: Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click on **Add project** (or create a project).
3. Follow the on-screen instructions to set up your new Firebase project.

## Step 2: Register Your Apps
You need to register both your iOS and Android apps within your new Firebase project.

### For iOS:
1. In the Firebase console, click the **iOS** icon to add an iOS app.
2. Enter your app's **iOS bundle ID** (e.g., `com.yourcompany.yourapp`).
3. Follow the prompts to register the app.

### For Android:
1. In the Firebase console, click the **Android** icon to add an Android app.
2. Enter your app's **Android package name** (e.g., `com.yourcompany.yourapp`).
3. Follow the prompts to register the app.

## Step 3: Add Configuration Files to React Native
After registering your apps, Firebase will provide configuration files. You must add these to your React Native project.

1. **iOS:** Download `GoogleService-Info.plist` from the Firebase console and place it in the `ios/` directory of your React Native project (typically inside the main Xcode project folder). Ensure it is added to your Xcode target.
2. **Android:** Download `google-services.json` from the Firebase console and place it in the `android/app/` directory of your React Native project.

## Step 4: Configure the Azure Server (Backend)
To allow your backend to verify App Check tokens, you need the Firebase Admin SDK credentials.

1. In the Firebase console, go to **Project settings** (the gear icon) > **Service accounts**.
2. Click **Generate new private key**. This will download a JSON file containing your Admin SDK credentials.
3. On your **Azure server**, set up a new environment variable:
   - **Name:** `GOOGLE_APPLICATION_CREDENTIALS`
   - **Value:** The absolute path to the downloaded JSON key file (or appropriately configure the JSON content directly depending on your Azure hosting setup).

## Step 5: Enable App Check Validation in Backend
Finally, update your backend configuration to enforce App Check validation.

1. Locate the `appsettings.json` file in your backend project.
2. Find the `EnableAppCheck` setting.
3. Change its value from `false` to `true`:
   ```json
   "Firebase": {
     "EnableAppCheck": true
   }
   ```
4. Deploy the updated backend to Azure.

> [!IMPORTANT]
> Once `EnableAppCheck` is set to `true`, your backend will reject any requests that do not include a valid Firebase App Check token. Ensure Steps 1-4 are fully completed and tested before doing this in production.
