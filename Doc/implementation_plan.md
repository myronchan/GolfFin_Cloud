# Phase 1: Set up JWT Authentication (Azure AD B2C)

This plan outlines the steps to add JWT Authentication to your ASP.NET Core API so that it can validate tokens issued by your Azure AD B2C tenant.

## Open Questions

> [!IMPORTANT]
> To fully test this locally, you will need your Azure AD B2C tenant details. I will add placeholders in `appsettings.json` for you to fill in. 
> 
> The placeholders you will need to fill out in Azure are:
> - **Domain**: e.g., `yourtenant.onmicrosoft.com`
> - **TenantId**: e.g., `11111111-1111-1111-1111-111111111111`
> - **ClientId**: The application ID of your registered API in B2C
> - **SignUpSignInPolicyId**: The name of your user flow (e.g., `B2C_1_susi`)

## Proposed Changes

### Configuration and Packages

#### [NEW] NuGet Package
- Add `Microsoft.AspNetCore.Authentication.JwtBearer` to `src/GolfFinWebApi/GolfFinWebApi.csproj`

#### [MODIFY] [appsettings.json](file:///Users/myronchan/Documents/Projects/GolfFin_Cloud/src/GolfFinWebApi/appsettings.json)
- Add a new `"AzureAdB2C"` configuration section with placeholders for Domain, TenantId, ClientId, and SignUpSignInPolicyId.

### Application Logic

#### [MODIFY] [Program.cs](file:///Users/myronchan/Documents/Projects/GolfFin_Cloud/src/GolfFinWebApi/Program.cs)
- Add the necessary `using Microsoft.AspNetCore.Authentication.JwtBearer;` and `using Microsoft.IdentityModel.Tokens;` statements.
- Register authentication services using `builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(...)` which binds to the `AzureAdB2C` section in `appsettings.json`.
- Add `builder.Services.AddAuthorization();`.
- Insert `app.UseAuthentication();` and `app.UseAuthorization();` in the middleware pipeline (before `app.MapControllers()` and Minimal API endpoints).
- Add `[Authorize]` to the `/api/admin/users` and `/api/admin/users/reset-password` endpoints as a starting point to protect administrative routes.

## Verification Plan

### Automated / Build
- Run `dotnet build` inside the `src/GolfFinWebApi` directory to ensure the project compiles successfully with the new package and code changes.

### Manual Verification
- After filling in your B2C details in `appsettings.json`, you can run the API locally.
- Attempts to hit protected endpoints like `/api/admin/users` without a valid token will result in a `401 Unauthorized` response.
- When passing a valid B2C token via the `Authorization: Bearer <token>` header, the API should return a `200 OK`.
