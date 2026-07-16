# How to Test and Verify Firebase App Check

Now that `EnableAppCheck` is set to `true` in your `appsettings.json`, your backend is actively blocking requests that lack a valid token. You need to perform two types of testing to ensure it works correctly: **Negative Testing** (verifying bad requests are blocked) and **Positive Testing** (verifying your app can still communicate with the backend).

## 1. Negative Testing (Verify Unauthorized Access is Blocked)

The goal here is to prove that if an attacker or unauthorized script tries to hit your API, they are rejected.

**Using Postman or curl:**
1. Try to make a standard GET or POST request to any protected endpoint on your Azure backend (e.g., `https://your-azure-api.com/api/users`).
2. Do **not** include an `X-Firebase-AppCheck` header (or pass a fake token like `12345`).
3. **Expected Result:** The server should return a `401 Unauthorized` or `403 Forbidden` response. It should **not** return the actual data.

If this works (the request is blocked), the backend App Check validation is successfully enabled.

## 2. Positive Testing (Verify the Real App is Allowed)

The goal here is to ensure your actual mobile app works and isn't accidentally locked out.

App Check behaves differently in a simulator vs. a real device. Because simulators don't have true hardware attestation (like Apple's DeviceCheck or Google's Play Integrity), you cannot simply run the app in the simulator and expect a valid production token. 

**Option A: Test on a Real Physical Device (Recommended)**
1. Build the app and deploy it to a physical iPhone or Android device.
2. Launch the app and perform an action that triggers a backend API call (e.g., logging in or fetching a list).
3. **Expected Result:** The request succeeds (`200 OK`) and the app functions normally.

**Option B: Test using a Debug Provider in the Simulator**
If you must test in a simulator, you have to use a "Debug Token".
1. In your React Native app code, temporarily configure the App Check provider to use the **Debug Provider**. This will print a debug token to your simulator's console/terminal when the app starts.
   - *Example console output:* `App Check debug token: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
2. Go to the [Firebase Console](https://console.firebase.google.com/) > **App Check** > **Apps** tab.
3. Click the three dots next to your iOS or Android app and select **Manage debug tokens**.
4. Click **Add debug token**, paste the token from your console, and save it.
5. Run the app in the simulator again. 
6. **Expected Result:** The simulator can now successfully communicate with the backend because Firebase recognizes the registered debug token.

> [!WARNING]
> Never ship the App Check Debug Provider to production. Always switch back to the standard providers (DeviceCheck/AppAttest for iOS, Play Integrity for Android) before uploading to the App Store or Google Play.
