# Walkthrough: Direct-to-Blob Image Uploads

We have successfully implemented Phase 3! Here is a breakdown of the changes that were made to enable direct image uploads from the mobile app to your Azure Blob Storage container.

## What Was Changed

### 1. Backend: Azure Storage Integration
- Installed the `Azure.Storage.Blobs` package in the Web API.
- Added your Azure Storage Connection String to `appsettings.json` and `appsettings.Development.json`.
- Updated the `ListingsController.cs` to include a new `GET /api/listings/upload-sas` endpoint.
- This endpoint securely generates a time-limited (15-minute) Shared Access Signature (SAS) token with Write permissions. It allows the mobile app to upload exactly one file to a unique `Guid` blob name without exposing your account keys.

### 2. Frontend: Direct Upload Logic
- Modified the `handleList` function in `src/app/sell.tsx`.
- The app now bypasses the heavy `POST /api/listings/upload` multipart form request.
- Instead, it requests the SAS URL from the backend, converts the local image URI into a binary `Blob`, and executes a direct `PUT` request to Azure Blob Storage.
- The app then collects the permanent public URLs of the uploaded images and sends them in the final JSON payload to create the listing.

## How to Test
1. Make sure your local Web API server is restarted (`dotnet run` in your backend terminal).
2. Open the GolfFin app in the Simulator.
3. Navigate to the **Sell** screen (click the "+" icon).
4. Fill out the listing details and select an image to upload.
5. Click **Save**.
6. If everything works perfectly, the app will upload the image directly to Azure, the listing will be created, and you will be able to see the new image blob when you check the **`listings`** container inside your Storage Account in the Azure Portal!

> [!NOTE]
> By offloading image uploads directly to Azure, your Web API will use significantly less bandwidth and memory, making the entire platform much faster and more scalable!
