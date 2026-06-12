# Azure File Sync – Change Detection Runbook
<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/284e5670-3e73-4608-99d1-4ec960668d14" />

This repository contains a PowerShell runbook that triggers **Azure File Sync Change Detection** on a cloud endpoint and supports authentication with Azure Automation managed identity. It can run against the **entire Azure file share** or a **specific path relative to the share root**.[1][2]

## Overview

Azure File Sync periodically checks an Azure file share for changes that were made directly in Azure Files, and `Invoke-AzStorageSyncChangeDetection` can be used to trigger that detection manually instead of waiting for the scheduled cycle.[1][3]
This is useful when folders or files are created, moved, or deleted in Azure Files and those changes must be synced back to the on-premises server quickly.[3][1]

## How it works

The runbook connects to Azure using a managed identity from the Automation Account. If `ManagedIdentityAccountID` is provided, it uses that specific **user-assigned managed identity**; otherwise it tries the managed identity already associated with the Automation Account and throws a clear error if authentication fails.[2][4]

The script resolves the cloud endpoint from the Storage Sync Service and Sync Group, then runs `Invoke-AzStorageSyncChangeDetection`. If `Path` is empty, it triggers change detection for the **entire file share**; if `Path` is provided, it runs detection only for that path and its subfolders in recursive mode.[1][5][3]

## Parameters

| Parameter | Required | Description |
|---|---|---|
| `AzureSubscriptionId` | Yes | Subscription containing the Storage Sync Service. |
| `ResourceGroupName` | Yes | Resource group where the Storage Sync Service exists. |
| `StorageSyncServiceName` | Yes | Name of the Azure Storage Sync Service. |
| `SyncGroupName` | Yes | Name of the Sync Group containing the target Cloud Endpoint. |
| `Path` | No | Path relative to the root of the Azure file share. Leave empty to scan the full share.[1][3] |
| `ManagedIdentityAccountID` | No | Client ID of the user-assigned managed identity. If omitted, the runbook tries the Automation Account managed identity first.[2][4] |

## Usage examples

### Full share detection

Use an empty `Path` to trigger detection on the entire Azure file share.[1][5]

```powershell
.\AzureFileSyncCD.ps1 `
 -AzureSubscriptionId "xxxx" `
 -ResourceGroupName "xxxx" `
 -StorageSyncServiceName "xxxx" `
 -SyncGroupName "AFSDocfinance" `
 -Path "" `
 -ManagedIdentityAccountID ""
```

### Specific folder detection

When `Path` is provided, it must be **relative to the Azure file share root**, not a local Windows path like `D:\Share`.[3][6]

```powershell
.\AzureFileSyncCD.ps1 `
 -AzureSubscriptionId "xxxx" `
 -ResourceGroupName "xxxx" `
 -StorageSyncServiceName "xxxx" `
 -SyncGroupName "AFSDocfinance" `
 -Path "Clients/2026" `
 -ManagedIdentityAccountID "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

## Important notes

- Do **not** pass a local drive path such as `D:\Share` to `Path`; the value must be relative to the Azure file share root.[3][6]
- Do **not** pass `""` as a literal text value from the portal if your goal is full-share detection; the intended value is an actual empty string.[1]
- Running the command without `-DirectoryPath` is the documented way to trigger **share-level** change detection.[1][5]
- When using path-based detection, the recursive mode is intended for folders and can enumerate up to 10,000 items in the specified scope.[1][3]

## Azure Automation setup

This section assumes the following already exist:
- Azure Storage Account and Azure file share
- Storage Sync Service
- Sync Group
- Cloud Endpoint
- Server Endpoint
- Registered server and healthy Azure File Sync topology[1][7]

### 1. Create the Automation Account

In the Azure portal, create an **Automation Account** in the same subscription as the Storage Sync Service, then choose the correct resource group and region for your operational standards.[7][8]
If you already have an Automation Account, you can reuse it instead of creating a new one.[9][10]

### 2. Enable managed identity

Open the Automation Account, go to **Identity**, and enable a managed identity. Azure Automation supports both **system-assigned** and **user-assigned** managed identities.[4][2]
If you want to use a specific identity, open the **User assigned** tab and add the existing user-assigned managed identity to the Automation Account.[4][2]

### 3. Grant permissions

Assign Azure RBAC permissions to the managed identity so the runbook can read the Storage Sync configuration and invoke change detection. Apply the role assignment at the narrowest scope that covers the Storage Sync Service or its resource group.[10][8]
If your environment uses a dedicated user-assigned managed identity, use that identity's object and client IDs for role assignment and runbook parameters.[2][8]

### 4. Create the runbook

In the Automation Account, go to **Runbooks** and create a new **PowerShell** runbook named `AzureFileSyncCD`.[8][7]
Paste the script from this repository into the editor, save it, test it, and then publish it.[7][8]

### 5. Import required Az modules

Ensure the Automation Account has the required Az modules available, especially `Az.Accounts` and `Az.StorageSync`, because the runbook uses `Connect-AzAccount`, `Get-AzStorageSyncCloudEndpoint`, and `Invoke-AzStorageSyncChangeDetection`.[1][7]
If the environment uses older Az module versions, test the runbook carefully before scheduling it in production.[1]

### 6. Configure runbook parameters

Use the following values when starting the runbook manually or when creating a schedule:

```text
AzureSubscriptionId     = <subscription-id>
ResourceGroupName       = <resource-group>
StorageSyncServiceName  = <storage-sync-service>
SyncGroupName           = <sync-group-name>
Path                    = <empty for full share, or relative path>
ManagedIdentityAccountID= <optional client-id of user-assigned MI>
```

For full-share detection, leave `Path` empty. For a subfolder, use a relative path such as `Clients`, `Inbound/2026`, or `Reports/Finance/Q2`.[1][3][6]

### 7. Test the runbook

Start the runbook manually with `Path` empty and confirm the output shows the correct Sync Group, Cloud Endpoint, and change detection mode.[1]
Then verify on the server endpoint that a new Azure File Sync session appears and that `AppliedDirectoryCount` or `AppliedFileCount` changes when Azure-side content is detected.[11]

### 8. Schedule it

If you need recurring cloud-side detection faster than the default cycle, create an Automation schedule and link it to the runbook with the required parameters.[8][7]
Use a frequency that matches your operational need and validate that overlapping jobs do not cause unnecessary reruns.[1]

## Example output

Typical runbook output includes the resolved Sync Group, Cloud Endpoint, and whether the change detection is executed on the entire share or on a specific path. This makes troubleshooting easier in Azure Automation job logs.[1]

## Repository structure

```text
/
├── AzureFileSyncCD.ps1   # PowerShell runbook
├── README.md             # Documentation
└── .gitignore            # Ignore rules for PowerShell artifacts
```

## Credits

This script is based on the original Azure File Sync change detection runbook concept published by **Charbel Nemnom**, then adapted and extended for Azure Automation and managed identity scenarios.[3]
