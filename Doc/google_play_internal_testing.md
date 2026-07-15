# How to Set Up Internal Testing in Google Play

Internal testing is the fastest way to distribute your app to a small set of trusted testers before releasing it to a wider audience. It does not require a review from Google, making it perfect for rapid iteration.

Follow these steps to set up internal testing for your Android app:

## Step 1: Prepare Your App for Release
Before you can distribute your app, you need to build it for release.
1. Ensure your app is signed with a release keystore.
2. Build an Android App Bundle (`.aab` file). If you are using React Native, you can usually do this by running `cd android && ./gradlew bundleRelease`.

## Step 2: Access Google Play Console
1. Go to the [Google Play Console](https://play.google.com/console/) and log in.
2. Select your app from the dashboard. (If you haven't created the app yet, click **Create app** and fill in the basic details).

## Step 3: Create a Testers List
You need to specify exactly who is allowed to download the internal test version.
1. In the left-hand menu, scroll down to **Testing** and click on **Internal testing**.
2. Click on the **Testers** tab.
3. Click **Create email list**.
4. Give the list a name (e.g., "Internal Team").
5. Add the Gmail or Google Workspace email addresses of your testers. You can type them in or upload a CSV file.
6. Save the list and make sure it is **checked/selected** in the Testers tab.
7. Click **Save changes** at the bottom right.

## Step 4: Create and Roll Out a Release
1. In the **Internal testing** section, go back to the **Releases** tab.
2. Click **Create new release**.
3. (Optional but recommended) If this is your first release, you may be asked to opt-in to Play App Signing.
4. Under the "App bundles and APKs" section, upload the `.aab` file you generated in Step 1.
5. Add a Release name (e.g., `1.0.0-beta1`) and some release notes so your testers know what to check.
6. Click **Next** (or Review release).
7. If there are any warnings, review them (warnings won't block an internal release, but errors will).
8. Click **Start rollout to Internal testing** and confirm.

## Step 5: Share the App with Testers
Once the rollout is complete, testers still need a special link to access the app.
1. Go back to the **Testers** tab under **Internal testing**.
2. Scroll down to the **How testers join your test** section.
3. Click **Copy link**.
4. Share this link directly with the people on your email list.

### What the testers need to do:
- They must click the link on an Android device (or while logged into the Google account on their browser).
- They will be prompted to **"Accept Invitation"**.
- Once accepted, they will be given a link to download the app directly from the Google Play Store.

> [!TIP]
> Internal testing releases are available almost immediately since they bypass Google's review process. If you push an update to this track, testers can usually download it within a few minutes.
