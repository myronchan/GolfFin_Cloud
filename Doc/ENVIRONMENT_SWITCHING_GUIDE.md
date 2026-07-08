# GolfFinApp Environment Switching Guide

This document explains how to switch your GolfFin mobile app between your local development backend and your production cloud backend.

## The Setup
We have configured your mobile app to use two different environment files located in `src/UI/GolffinApp/`:
1. **`.env.development`**: Contains the URL for your local backend (`http://192.168.1.193:5215`).
2. **`.env.production`**: Contains the URL for your Azure cloud backend (`https://golffin-beg6dpcfeycwcefk.westus2-01.azurewebsites.net`).

---

## How to Run the App

Because the Expo bundler (Metro) caches environment variables, you should always clear the cache (`-c`) when switching between environments to ensure it picks up the right URLs.

### 1. Connecting to the Local Backend (Default)
When you want to test the mobile app against the backend running on your local computer, use the standard start command. Expo will automatically use `.env.development`.

```bash
cd src/UI/GolffinApp
npm start -- -c
```
*Note: Make sure your local backend (`GolfFinWebApi`) is also running!*

### 2. Connecting to the Cloud Backend (Production)
When you want to test the mobile app against your live Azure backend, you must tell Expo to use the production environment variables by prefixing the command with `NODE_ENV=production`.

```bash
cd src/UI/GolffinApp
NODE_ENV=production npm start -- -c
```

---

## Note on Backend Configuration
Your backend API (`GolfFinWebApi`) handles environment switching automatically based on where it is running:
- **Local:** When running via `dotnet run`, it uses `appsettings.Development.json` (Local SQL Database).
- **Cloud:** When deployed to Azure, it defaults to Production and uses `appsettings.json` (Azure SQL Database).
