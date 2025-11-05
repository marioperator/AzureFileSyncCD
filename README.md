# Azure File Sync – Change Detection Runbook

This repository contains a PowerShell runbook that triggers **Change Detection** on an Azure File Sync Cloud Endpoint using a **User-Assigned Managed Identity**.

---

## 📌 Overview

Azure File Sync performs change detection automatically every 24 hours.  
This runbook allows you to **force immediate sync** by invoking:

```
Invoke-AzStorageSyncChangeDetection
```

It is designed for automation scenarios where waiting for the default cycle is not acceptable.

---

## ✅ Usage

### Runbook Parameters

| Parameter | Description |
|----------|-------------|
| **AzureSubscriptionId** | Azure subscription containing the Storage Sync Service |
| **ResourceGroupName** | Resource Group where the Storage Sync Service resides |
| **StorageSyncServiceName** | Name of the Azure Storage Sync Service |
| **SyncGroupName** | Name of the Sync Group containing the Cloud Endpoint |
| **Path** | File Share path (kept for backward compatibility) |
| **ManagedIdentityAccountID** | Client ID (GUID) of the User-Assigned Managed Identity |

### Example Execution

```powershell
.\AzureFileSyncCD.ps1 `
 -AzureSubscriptionId "xxxx" `
 -ResourceGroupName "xxxx" `
 -StorageSyncServiceName "xxxx" `
 -SyncGroupName "xxxx" `
 -Path "D:\Share" `
 -ManagedIdentityAccountID "xxxxx"
```

---

## 📌 Evolution Based on the Original Work

This script is an evolution of the runbook created by **Charbel Nemnom (Microsoft MVP/MCT)**:

**“Enable Immediate Sync with Azure File Sync”**  
https://charbelnemnom.com/enable-immediate-sync-with-azure-file-sync/

The original script introduced the concept of forcing immediate synchronization via `Invoke-AzStorageSyncChangeDetection`.

---

## ✅ Improvements Introduced in Version 2.0  
**Author: Mario Mancini**

### Enhancements

- **✅ Managed Identity Support (User-Assigned)**  
  Secure authentication via `Connect-AzAccount -Identity`, no credentials required.

- **✅ Full Parameterization**  
  All required inputs are provided as mandatory parameters.

- **✅ Correct Cloud Endpoint Retrieval**  
  Uses `Get-AzStorageSyncCloudEndpoint` with proper parameters for reliability.

- **✅ Better Automation Compatibility**  
  Uses `Disable-AzContextAutosave` to avoid inheriting contexts in Azure Automation.

### Purpose of These Improvements

This version is designed for scenarios such as:

- automated workflows,  
- Azure Automation scheduled jobs,  
- high-frequency file update environments,  
- CI/CD or DevOps pipelines requiring controlled synchronization.

---

## 📁 Repository Structure

```
/
├── AzureFileSyncCD.ps1   # PowerShell runbook
├── README.md             # Documentation
└── .gitignore            # Ignore rules for PowerShell artifacts
```

---

## 📄 License (Optional)

If you want, a recommended **MIT License** can be added.
