# Phase 1: Migration to Microsoft Entra External ID Complete

The API has been successfully migrated from Azure AD B2C to the modern **Microsoft Entra External ID (CIAM)** architecture.

## Changes Made

### 1. Configuration (`appsettings.json`)
- Removed the old `AzureAdB2C` section.
- Added a new `EntraExternalID` configuration block. The new format requires your Domain, Tenant ID, and Client ID. It no longer requires a "SignUpSignInPolicyId".

### 2. Middleware (`Program.cs`)
- Updated the JWT Bearer configuration to construct the Authority URL using the modern CIAM format: `https://<tenant-name>.ciamlogin.com/<tenant-id>/v2.0`.
- Your admin endpoints (`/api/admin/users`) remain protected by the `[Authorize]` attribute.

### 3. Architecture Documentation
- Updated [security_architecture.md](file:///Users/myronchan/Documents/Projects/GolfFin_Cloud/Doc/security_architecture.md) to reflect the shift to Microsoft Entra External ID.

## Setup Guide: Microsoft Entra External ID (Customer Tenant)

To get the values for your `appsettings.json`, follow these steps in the Azure Portal:

### Step 1: Create a Customer Tenant
1. Log in to the [Azure Portal](https://portal.azure.com/).
2. Search for **"Tenant creation"** or go to **Microsoft Entra ID** and click **Manage tenants** -> **Create**.
3. Select **Customer** (for app customers, not workforce).
4. Enter your organization name and initial domain name (e.g., `golffin`).
5. Complete the creation process and switch your directory to the new Customer tenant.

### Step 2: Register your Web API
1. Inside your new Customer tenant, go to **App registrations** -> **New registration**.
2. **Name**: `GolfFin Web API`.
3. **Supported account types**: Select the option for all users (including social identities).
4. **Redirect URI**: Leave blank.
5. Click **Register**.
6. Copy the **Application (client) ID** and **Directory (tenant) ID** into your `appsettings.json`.

### Step 3: Expose an API Scope
1. In your app registration, select **Expose an API**.
2. Set the **Application ID URI** (e.g., `api://<client-id>`).
3. Click **Add a scope**.
4. Name it `access_as_user` and provide a display name and description. Enable the scope.

### Step 4: Create a User Flow
1. Go to **External Identities** -> **User flows**.
2. Click **New user flow**.
3. Select the identity providers you want (Email with password, Google, etc.).
4. Select the user attributes you want to collect during sign-up.
5. Save the flow. (You no longer need to put the flow name in your API's backend configuration!).

Once you paste your Tenant ID, Client ID, and Domain into `appsettings.json`, your API will be fully secure and ready for your mobile app!
