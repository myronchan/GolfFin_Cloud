# Mobile App Financial Security Architecture

This document outlines the end-to-end security architecture for handling financial transactions between your mobile application and the ASP.NET Core Web API.

## Architecture Diagram (ASCII)

```text
       [ Mobile App (iOS / Android) ]
         |         |          |
         | (1)     | (2)      | (3)
         v         v          v
   +-------+   +-------+  +----------+
   | Apple |   | Entra |  |  Stripe  |
   |   /   |   | Ext ID|  | (Payment |
   |Google |   | (CIAM)|  | Gateway) |
   +-------+   +-------+  +----------+
         |         |          |
    App  |   JWT   |    Card  |
   Check |  Token  |   Token  |
   Token |         |          |
         v         v          v
       [ Mobile App (Holding Tokens) ]
                     |
                     | (4) HTTPS POST /api/checkout
                     | Headers: 
                     |  - Authorization: Bearer <JWT Token>
                     |  - X-App-Check: <App Check Token>
                     | Body:
                     |  - { "stripeToken": "<Card Token>", "amount": 100 }
                     v
+---------------------------------------------------------+
|                Azure App Service (Web API)              |
|                                                         |
|  +---------------------------------------------------+  |
|  | 1. App Attestation Middleware                     |  |
|  |    (Validates X-App-Check header with Firebase)   |  |
|  +---------------------------------------------------+  |
|                           |                             |
|  +---------------------------------------------------+  |
|  | 2. JWT Authentication Middleware                  |  |
|  |    (Validates Bearer token with Entra External ID)|  |
|  +---------------------------------------------------+  |
|                           |                             |
|  +---------------------------------------------------+  |
|  | 3. Payment Controller (Business Logic)            |  |
|  |    (Sends "stripeToken" to Stripe API to charge)  |  |
|  +---------------------------------------------------+  |
|                           |                             |
+---------------------------|-----------------------------+
                            | (5) Save Receipt/Order
                            v
                   +-----------------+
                   |   Azure SQL     |
                   |   Database      |
                   +-----------------+
```

> [!IMPORTANT]
> **Data Flow Security:** Notice that the raw credit card details never touch the Azure Web API or the Azure SQL Database. The Mobile App communicates directly with Stripe to get a secure `stripeToken`, which is then passed to your API.

---

## Step-by-Step Implementation Guide

### Phase 1: Set up JWT Authentication (Microsoft Entra External ID)

**Goal:** Ensure only logged-in users can access the API.

1. **Register API in Entra External ID:** 
   - Go to the Azure Portal -> Microsoft Entra External ID (Customer tenant).
   - Register your Web API as an application.
   - Expose an API scope (e.g., `api://<client-id>/access_as_user`).
2. **Install NuGet Packages:**
   - Add `Microsoft.AspNetCore.Authentication.JwtBearer` to your `GolfFinWebApi` project.
3. **Update `Program.cs`:**
   - Configure the Authentication middleware to use your Entra External ID details (Tenant ID, Client ID, Domain).
   - Add `app.UseAuthentication()` and `app.UseAuthorization()` to the request pipeline.
4. **Protect Endpoints:**
   - Add the `[Authorize]` attribute to any controller or Minimal API endpoint that requires user access.

### Phase 2: Integrate Payment Processor (Stripe)

**Goal:** Securely process payments without touching credit card data.

1. **Create Stripe Account:**
   - Sign up for a Stripe developer account and get your Public (Publishable) Key and Secret Key.
2. **Mobile App Integration:**
   - Install the Stripe SDK in your mobile app (iOS/Android/React Native/Flutter).
   - Use Stripe's pre-built UI components to collect the credit card.
   - The SDK will return a `PaymentMethodId` or `Token`.
3. **API Integration:**
   - Install the `Stripe.net` NuGet package in your `GolfFinWebApi`.
   - Store your Stripe Secret Key securely in Azure App Service Environment Variables (do not commit it to code).
   - Create a Checkout endpoint (e.g., `POST /api/payments/charge`) that takes the `PaymentMethodId` and uses the `Stripe.net` SDK to create a `PaymentIntent` and execute the charge.

### Phase 3: Add App Attestation (Firebase App Check)

**Goal:** Ensure requests only come from the genuine mobile app.

1. **Setup Firebase:**
   - Create a Firebase Project in the Firebase Console.
   - Register your iOS and Android apps.
   - Enable **App Check** and configure the attestation providers (DeviceCheck/App Attest for iOS, Play Integrity for Android).
2. **Mobile App Integration:**
   - Install the Firebase SDK and initialize App Check in your mobile app before making any API calls.
   - Attach the App Check token to the headers of your HTTP client (e.g., `X-Firebase-AppCheck`).
3. **API Integration (Custom Middleware):**
   - Install the Firebase Admin SDK in your `GolfFinWebApi` (`FirebaseAdmin` NuGet package).
   - Create a custom ASP.NET Core Middleware that intercepts incoming requests.
   - The middleware will read the `X-Firebase-AppCheck` header, use the Firebase Admin SDK to verify the token, and reject the request (`401 Unauthorized`) if the token is invalid or missing.

> [!TIP]
> If you are ready to begin, we can start with **Phase 1** and write the code for `Program.cs` to enable Microsoft Entra External ID authentication.
