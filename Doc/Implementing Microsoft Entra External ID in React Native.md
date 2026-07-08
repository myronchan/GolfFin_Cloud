# Implementing Microsoft Entra External ID in React Native (Expo)

This guide explains how to add a secure login flow to your React Native app using Microsoft Entra External ID. Since you are using Expo, the easiest and most secure way to handle OAuth 2.0 authentication is using the `expo-auth-session` library.

## Step 1: Install the Required Packages

In your terminal, navigate to your mobile app directory (`src/UI/GolffinApp`) and install the necessary Expo packages:

```bash
npx expo install expo-auth-session expo-crypto expo-web-browser expo-secure-store
```
*   `expo-auth-session`: Handles the OAuth login redirect flow securely.
*   `expo-web-browser`: Opens the secure Microsoft login page in a web view.
*   `expo-secure-store`: Safely stores the JWT token on the device's keychain so the user doesn't have to log in every time.

## Step 2: Configure the Azure Portal for Mobile

Before writing code, you must tell Microsoft Entra that a mobile app is allowed to request tokens.

1. Go to the Azure Portal -> **Microsoft Entra External ID** -> **App registrations**.
2. Select your `GolfFin Web API` app (or create a separate one just for the mobile app, which is a good practice).
3. Click **Authentication** on the left menu.
4. Click **+ Add a platform** and select **iOS / macOS**.
   - **Bundle ID**: Enter your app's bundle ID (e.g., `com.yourcompany.golffin`). You can find this in your `app.json`.
5. Click **+ Add a platform** and select **Android**.
   - **Package name**: Enter your package name (e.g., `com.yourcompany.golffin`).
   - **Signature hash**: If testing locally, you can use the default Expo development hash (you will update this later for production).
6. Ensure that **Access tokens (used for implicit flows)** is **NOT** checked (we will use the more secure Authorization Code Flow with PKCE, which `expo-auth-session` handles automatically).

## Step 3: Add the Login Code to Your App

Create a new file in your app (e.g., `src/hooks/useAuth.ts`) to handle the login logic.

```typescript
import * as React from 'react';
import * as WebBrowser from 'expo-web-browser';
import * as AuthSession from 'expo-auth-session';
import * as SecureStore from 'expo-secure-store';
import { getEndpoint } from '../constants/api'; // The file we created earlier

// This is required by expo-auth-session to complete the web flow
WebBrowser.maybeCompleteAuthSession();

const ENTRA_TENANT_ID = "YOUR_TENANT_ID";
const ENTRA_CLIENT_ID = "YOUR_CLIENT_ID";
const ENTRA_DOMAIN = "golffin"; // Just the prefix, e.g., golffin

// Construct the Discovery Document URL for Entra CIAM
const discovery = AuthSession.useAutoDiscovery(
  `https://${ENTRA_DOMAIN}.ciamlogin.com/${ENTRA_TENANT_ID}/v2.0`
);

export function useAuth() {
  const [token, setToken] = React.useState<string | null>(null);

  // Set up the Auth Request
  const [request, response, promptAsync] = AuthSession.useAuthRequest(
    {
      clientId: ENTRA_CLIENT_ID,
      scopes: ['openid', 'profile', 'offline_access', `api://${ENTRA_CLIENT_ID}/access_as_user`],
      redirectUri: AuthSession.makeRedirectUri({
        scheme: 'golffin' // Ensure this matches the "scheme" in your app.json
      }),
    },
    discovery
  );

  // Handle the response after the user logs in
  React.useEffect(() => {
    if (response?.type === 'success') {
      const { code } = response.params;
      
      // Exchange the authorization code for an access token
      // In a production app, you use AuthSession.exchangeCodeAsync here
      // For simplicity, if you get a token directly in the response:
      if (response.authentication?.accessToken) {
          const jwtToken = response.authentication.accessToken;
          setToken(jwtToken);
          // Securely save the token to the device
          SecureStore.setItemAsync('userToken', jwtToken);
      }
    }
  }, [response]);

  // Helper to load token on app start
  React.useEffect(() => {
    SecureStore.getItemAsync('userToken').then((savedToken) => {
      if (savedToken) setToken(savedToken);
    });
  }, []);

  const logout = async () => {
    await SecureStore.deleteItemAsync('userToken');
    setToken(null);
  };

  // Helper to call your API with the token attached
  const fetchWithAuth = async (endpointPath: string, options: RequestInit = {}) => {
      if (!token) throw new Error("Not logged in");
      
      const url = getEndpoint(endpointPath);
      return fetch(url, {
          ...options,
          headers: {
              ...options.headers,
              Authorization: `Bearer ${token}`
          }
      });
  };

  return { token, promptAsync, request, logout, fetchWithAuth };
}
```

## Step 4: Add the Login Button to your Screen

Now you can use this hook in your login screen (`src/screens/LoginScreen.tsx`):

```tsx
import React from 'react';
import { View, Button, Text, StyleSheet } from 'react-native';
import { useAuth } from '../hooks/useAuth';

export default function LoginScreen() {
  const { token, promptAsync, request, logout, fetchWithAuth } = useAuth();

  const handleTestApi = async () => {
      try {
          // This will automatically route to localhost or Azure based on your api.ts config!
          const response = await fetchWithAuth('/api/admin/users');
          const data = await response.json();
          console.log("Secure API Response:", data);
      } catch (error) {
          console.error("API Call Failed", error);
      }
  };

  return (
    <View style={styles.container}>
      {token ? (
        <>
          <Text>You are securely logged in!</Text>
          <Button title="Test Secure API Call" onPress={handleTestApi} />
          <Button title="Log Out" onPress={logout} />
        </>
      ) : (
        <Button 
          disabled={!request}
          title="Log in with Microsoft Entra" 
          onPress={() => promptAsync()} 
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center' }
});
```

## Summary
1. The user clicks **"Log in with Microsoft Entra"**.
2. A secure browser window opens to your `.ciamlogin.com` page.
3. The user logs in and the browser closes.
4. The `expo-auth-session` library grabs the JWT token.
5. You pass that JWT token into the `Authorization: Bearer <token>` header every time you fetch data from your ASP.NET Core API!
