# Video Upload & Playback Implementation

The GolfFin app now fully supports uploading videos to Azure Blob Storage and watching them directly in the app! 

Here is a summary of the changes we've made:

### 1. Azure Blob Storage Dynamic Files
Previously, the backend hardcoded every single upload to end with `.jpg`. We updated the `upload-sas` endpoint in `ListingsController.cs` to check the file's MIME type from the frontend. It now dynamically generates SAS URLs for `.mp4` and `.mov` files when you pick a video from your camera roll.

### 2. Database Integration
The `Listings` database table already contained a `VideoUrl` column, but our backend wasn't using it. We updated the API so that when you hit "Save", the backend receives the video's URL and saves it securely via the `INSERT` and `UPDATE` SQL queries into the database.

### 3. Smart Upload Logic
When you pick multiple items from your photo library on the "Post Item" screen (`sell.tsx`), the frontend now loops through them and automatically detects which ones are videos and which ones are images. 
- **Images** are uploaded as `image/jpeg` and stored in the `images` list.
- **Videos** are uploaded as `video/mp4` and stored separately in the `videoUrl` property for the database.

### 4. Seamless Playback 
We installed `expo-av`, the official video package for React Native. When you navigate to a listing detail page (`[id].tsx`), if that listing has a `VideoUrl` attached to it, a beautiful video player will appear just beneath the price, allowing buyers to watch the item in action with native iOS video controls!

## Testing it out
1. Make sure your local `dotnet run` server is running in your terminal so the app can communicate with the updated API.
2. If your Expo app tells you it needs to restart because a native dependency (`expo-av`) was added, just press **`r`** in your Expo terminal to reload.
3. Try posting a new listing and selecting a short video from your camera roll!
