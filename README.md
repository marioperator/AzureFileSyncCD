📌 Evolution Based on the Original Work

This script is an evolution of the runbook published by Charbel Nemnom (Microsoft MVP/MCT):

“Enable Immediate Sync with Azure File Sync”
https://charbelnemnom.com/enable-immediate-sync-with-azure-file-sync/

The original guide introduced the use of Invoke-AzStorageSyncChangeDetection to force immediate synchronization of an Azure File Share within its Sync Group.

✅ Improvements Introduced in Version 2.0 (Mario Mancini)

This version includes:

Support for User-Assigned Managed Identity
Secure authentication via Connect-AzAccount -Identity, without credentials.

Full Parameterization
All required inputs (Subscription, RG, Sync Service, Sync Group, Cloud Endpoint) are exposed as mandatory parameters.

Corrected Cloud Endpoint Lookup
Ensures reliable retrieval using Get-AzStorageSyncCloudEndpoint with correct parameters.

Cleanup and Reliability Enhancements
Disabled context autosave (Disable-AzContextAutosave) for consistent Azure Automation behavior.

✅ Purpose of This Script

Use this updated runbook when you need immediate sync, for example:

automated workflows,

scheduled Azure Automation jobs,

high-frequency file share updates,

CI/CD pipelines or operational runbooks.

📄 Files Included

AzureFileSyncCD.ps1 — the PowerShell runbook

README.md — this documentation

.gitignore — excludes PowerShell module artifacts and common temp files
