# Azure DevOps Release Pipeline for Salesforce

This document describes how to configure an Azure DevOps release pipeline for a Salesforce DX project, including creating a Salesforce Connected App and using pipeline variables securely.

## 1. Overview

The recommended release pipeline flow for Salesforce DX in Azure DevOps is:

1. Authenticate to Salesforce using a Connected App.
2. Store auth values in Azure DevOps variables or variable groups.
3. Run Salesforce CLI commands to deploy metadata or run tests.
4. Use a YAML pipeline with secure variables and secret files.

## 2. Prerequisites

- Azure DevOps project with repo containing your Salesforce DX project.
- Salesforce CLI installed on hosted/self-hosted build agents.
- Salesforce org where you can create a Connected App.
- A certificate/private key file if using JWT Bearer flow.

## 3. Create a Salesforce Connected App

A Connected App is required for OAuth-based authentication between Azure DevOps and Salesforce.

### 3.1 Recommended: JWT Bearer Token Flow

1. In Salesforce, go to Setup > App Manager.
2. Click **New Connected App**.
3. Enter:
   - Connected App Name
   - API Name
   - Contact Email
4. Enable **OAuth Settings**.
5. Set a callback URL (it can be a placeholder like `https://localhost`).
6. Add OAuth Scopes:
   - `Access and manage your data (api)`
   - `Perform requests on your behalf at any time (refresh_token, offline_access)`
7. Under **Use Digital Signatures**, upload the certificate public key.
8. Save the Connected App.

After saving, copy the **Consumer Key**. This becomes the `SF_CLIENT_ID` or `SF_CONNECTED_APP_CONSUMER_KEY`.

### 3.2 Alternate: Username-Password OAuth Flow

If you use username-password OAuth instead of JWT, you also need:

- Consumer Secret
- Salesforce username
- Salesforce password + security token

This is less secure than JWT and not recommended for production.

## 4. Azure DevOps Variables and Secret Storage

Use Azure DevOps Library variable groups or pipeline variables.

### 4.1 Recommended Variables

- `SF_CLIENT_ID` - Connected App Consumer Key
- `SF_CLIENT_SECRET` - Connected App Consumer Secret (only for username-password OAuth)
- `SF_USERNAME` - Salesforce username
- `SF_JWT_KEY` - Use Azure DevOps secure file for JWT private key
- `SF_LOGIN_URL` - `https://login.salesforce.com` or `https://test.salesforce.com`
- `SF_PASSWORD` - Salesforce password + security token (username-password OAuth only)
- `SF_DEFAULT_DEV_HUB_USERNAME` - optional if using scratch orgs

### 4.2 Use a Variable Group

1. In Azure DevOps, go to **Pipelines > Library**.
2. Create a variable group, e.g. `SalesforceAuth`.
3. Add the values above.
4. Mark secret values as **secret**.
5. If using a secure file for JWT key, upload it under **Pipelines > Library > Secure files**.

### 4.3 Using Variables in YAML

In YAML, reference variables as `$(VAR_NAME)`.

Example:

```yaml
variables:
  - group: SalesforceAuth
  SF_LOGIN_URL: 'https://login.salesforce.com'

steps:
  - script: echo "Deploying to $(SF_LOGIN_URL)"
    displayName: 'Show target org'
```

## 5. Azure DevOps YAML Pipeline Example

Below is a release pipeline example using Salesforce CLI and JWT auth.

```yaml
trigger:
  branches:
    include:
      - main

pr:
  branches:
    include:
      - main

variables:
  - group: SalesforceAuth
  SF_LOGIN_URL: 'https://login.salesforce.com'
  SFDX_ENV: 'production'

stages:
  - stage: Deploy
    displayName: 'Salesforce Deploy'
    jobs:
      - job: DeployToSalesforce
        displayName: 'Deploy to Salesforce'
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: UsePythonVersion@0
            inputs:
              versionSpec: '3.x'
          - script: |
              npm install -g sfdx-cli
            displayName: 'Install Salesforce CLI'

          - task: DownloadSecureFile@1
            name: downloadJWTKey
            inputs:
              secureFile: 'salesforce_jwt.key'
            displayName: 'Download JWT private key'

          - script: |
              echo "Authenticating to Salesforce..."
              sfdx auth:jwt:grant \
                --clientid $(SF_CLIENT_ID) \
                --jwtkeyfile $(downloadJWTKey.secureFilePath) \
                --username $(SF_USERNAME) \
                --instanceurl $(SF_LOGIN_URL)
            displayName: 'Authenticate to Salesforce'

          - script: |
              sfdx force:source:deploy \
                --sourcepath force-app/main/default \
                --targetusername $(SF_USERNAME) \
                --wait 10
            displayName: 'Deploy source to Salesforce'
```

### Notes

- `DownloadSecureFile@1` retrieves the JWT private key from Azure DevOps secure files.
- `sfdx auth:jwt:grant` authenticates the CLI using the connected app consumer key.
- `--sourcepath` should point to your metadata folder.

## 6. Using Connected App Variables in Scripts

Example variables in a PowerShell inline script:

```yaml
- powershell: |
    Write-Host "Using org: $(SF_LOGIN_URL)"
    Write-Host "Username: $(SF_USERNAME)"
  displayName: 'Use Azure DevOps variables'
```

Example shell script:

```yaml
- script: |
    echo "Deploying with client ID $(SF_CLIENT_ID)"
    sfdx force:source:deploy --targetusername $(SF_USERNAME) --wait 10
  displayName: 'Deploy using Azure DevOps variables'
```

## 7. Release Pipeline Best Practices

- Keep secrets in Azure DevOps secret variables or secure files.
- Do not commit `sfdx auth` files or private keys to repo.
- Use `SF_LOGIN_URL` to switch between sandbox and production.
- Prefer JWT Bearer flow in automated pipelines.
- Use stage approvals for production deployments.

## 8. Example Variable Group Structure

Name: `SalesforceAuth`

- SF_CLIENT_ID: `xxxxxxxxxxxxxxxxxxxxxxxxxxxx`
- SF_CLIENT_SECRET: `xxxxxxxxxxxxxxxxxxxxxxxxxxxx` (optional)
- SF_USERNAME: `deploy-user@yourcompany.com`
- SF_PASSWORD: `password+securitytoken` (if using username-password OAuth)
- SF_LOGIN_URL: `https://login.salesforce.com`
- SF_DEFAULT_DEV_HUB_USERNAME: `your-hub-org@example.com` (optional)

## 9. Connected App Access and Policies

- Set IP Relaxation to `Relax IP restrictions` if using non-fixed build agents.
- Set session policies appropriately for pipeline access.
- If using JWT, assign the connected app to the deployment user profile or permission set.

## 10. Troubleshooting

- `ERROR running force:auth:jwt:grant`: verify certificate and `SF_CLIENT_ID`.
- `INVALID_LOGIN`: verify `SF_USERNAME` and `SF_LOGIN_URL`.
- `INSUFFICIENT_ACCESS`: verify Connected App OAuth scopes and user profile.
- `Source deploy errors`: run `sfdx force:source:deploy --checkonly` locally first.
