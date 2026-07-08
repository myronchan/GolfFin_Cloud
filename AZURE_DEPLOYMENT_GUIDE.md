# Azure Deployment Guide: Web API and SQL Database with GitHub Actions

This guide provides step-by-step instructions on how to host a Web API and an SQL Database on Azure, and how to automate the deployment process using GitHub Actions.

## Prerequisites
- An active [Azure Subscription](https://azure.microsoft.com/free/).
- A [GitHub](https://github.com/) account and your Web API source code pushed to a GitHub repository.
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed (optional, but helpful), or access to the [Azure Portal](https://portal.azure.com/).

---

## Step 1: Create and Configure Azure SQL Database

1. **Log in to the Azure Portal** at [portal.azure.com](https://portal.azure.com/).
2. **Create a SQL Database**:
   - Search for **"SQL databases"** in the top search bar and select it.
   - Click **"+ Create"**.
   - **Basics tab**:
     - Choose your Subscription and Resource Group (create a new one, e.g., `MyApp-RG`).
     - Enter a **Database name**.
     - Under **Server**, click **"Create new"**. Enter a globally unique server name, set the location, and configure authentication (Use SQL authentication for simplicity: enter a server admin login and password).
     - Under **Compute + storage**, click **"Configure database"** and select a pricing tier that fits your needs (e.g., Basic or standard DTU-based tier for development).
   - **Networking tab**:
     - For **Connectivity method**, select **"Public endpoint"**.
     - Set **"Allow Azure services and resources to access this server"** to **Yes**. (This allows your Web API to connect).
     - Set **"Add current client IP address"** to **Yes** if you want to connect from your local machine using tools like SQL Server Management Studio (SSMS) or Azure Data Studio.
   - Click **"Review + create"** and then **"Create"**. Wait for the deployment to finish.

3. **Get the Connection String**:
   - Go to your newly created SQL database resource.
   - In the left menu under **Settings**, select **"Connection strings"**.
   - Copy the **ADO.NET** connection string. You will need to replace `{your_password}` with the password you created earlier.

---

## Step 2: Create Azure App Service (for Web API)

1. **Create App Service**:
   - In the Azure Portal, search for **"App Services"** and select it.
   - Click **"+ Create"** -> **"Web App"**.
   - **Basics tab**:
     - Select the same Subscription and Resource Group as your database.
     - Enter a globally unique **Name** (this will be your API's URL, e.g., `my-cool-api.azurewebsites.net`).
     - **Publish**: Select **"Code"**.
     - **Runtime stack**: Select the appropriate runtime for your Web API (e.g., .NET 8, Node.js 20, Python 3.11).
     - **Operating System**: Select Linux or Windows (Linux is often cheaper and recommended for .NET Core/Node/Python).
     - **Region**: Select the same region as your SQL database to minimize latency.
     - **App Service Plan**: Create a new plan. You can select the "Free F1" or "Shared D1" tier for testing purposes under "Explore pricing plans".
   - Click **"Review + create"** and then **"Create"**. Wait for deployment.

2. **Configure App Settings (Connection String)**:
   - Go to your newly created App Service resource.
   - In the left menu under **Settings**, select **"Environment variables"** (or "Configuration" in older UI).
   - Go to the **"Connection strings"** tab and click **"+ Add"**.
   - **Name**: Enter the name your application expects (e.g., `DefaultConnection`).
   - **Value**: Paste the connection string you copied from Step 1 (remember to include your actual password).
   - **Type**: Select **"SQLAzure"**.
   - Click **"Apply"** and then **"Save"**.

---

## Step 3: Setup GitHub Actions CI/CD

To deploy automatically when you push to GitHub, we need to connect GitHub Actions to Azure. We will use a Publish Profile for simplicity.

1. **Get the Publish Profile from Azure**:
   - Go to your App Service in the Azure Portal.
   - On the **Overview** page, click the **"Get publish profile"** button at the top. This will download a `.PublishSettings` file.
   - Open the downloaded file in a text editor and copy the entire XML content.

2. **Add Secret to GitHub**:
   - Go to your repository on GitHub.
   - Navigate to **Settings** -> **Secrets and variables** -> **Actions**.
   - Click **"New repository secret"**.
   - **Name**: `AZURE_WEBAPP_PUBLISH_PROFILE`
   - **Secret**: Paste the entire XML content from the publish profile file.
   - Click **"Add secret"**.

3. **Create the GitHub Actions Workflow**:
   - In your GitHub repository, click on the **"Actions"** tab.
   - Depending on your stack, GitHub will suggest workflows (e.g., ".NET Core", "Node.js"). Click **"Configure"** on the relevant one, or click **"set up a workflow yourself"**.
   - Create a file at `.github/workflows/deploy.yml`.

   **Example Workflow for a .NET Web API:**

   ```yaml
   name: Build and deploy ASP.Net Core app to Azure Web App

   on:
     push:
       branches:
         - main
     workflow_dispatch:

   env:
     AZURE_WEBAPP_NAME: 'your-app-service-name'    # set this to your application's name
     AZURE_WEBAPP_PACKAGE_PATH: '.'                # set this to the path to your web app project
     DOTNET_VERSION: '8.0.x'                       # set this to the dotnet version to use

   jobs:
     build:
       runs-on: ubuntu-latest

       steps:
         - uses: actions/checkout@v4

         - name: Set up .NET Core
           uses: actions/setup-dotnet@v4
           with:
             dotnet-version: ${{ env.DOTNET_VERSION }}

         - name: Build with dotnet
           run: dotnet build --configuration Release

         - name: dotnet publish
           run: dotnet publish -c Release -o ${{env.DOTNET_ROOT}}/myapp

         - name: Upload artifact for deployment job
           uses: actions/upload-artifact@v4
           with:
             name: .net-app
             path: ${{env.DOTNET_ROOT}}/myapp

     deploy:
       runs-on: ubuntu-latest
       needs: build
       environment:
         name: 'Production'

       steps:
         - name: Download artifact from build job
           uses: actions/download-artifact@v4
           with:
             name: .net-app

         - name: Deploy to Azure Web App
           id: deploy-to-webapp
           uses: azure/webapps-deploy@v3
           with:
             app-name: ${{ env.AZURE_WEBAPP_NAME }}
             publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
             package: .
   ```
   *(Note: Adjust the `AZURE_WEBAPP_NAME` and `DOTNET_VERSION` to match your setup. If using Node/Python, use the respective actions).*

4. **Commit and Push**:
   - Commit the workflow file to your repository.
   - This push will automatically trigger the GitHub Actions workflow.
   - Go to the **"Actions"** tab in GitHub to watch the build and deployment process.

---

## Step 4: Verify Deployment

1. Once the GitHub Action completes successfully, go back to your App Service in the Azure Portal.
2. Click the **"Browse"** button (or click the URL on the overview page).
3. Your Web API should now be live! If it uses Swagger, you can navigate to `/swagger` to test the endpoints.
4. The API will securely connect to your Azure SQL Database using the connection string configured in the environment variables.
