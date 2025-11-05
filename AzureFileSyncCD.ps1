<#
.DESCRIPTION
A Runbook example which continuously check for files and directories changes in recursive mode
For a specific Azure File Share in a specific Sync Group / Cloud Endpoint
Using the Managed Identity (Service Principal in Azure AD)

.NOTES
Filename : AzureFileSyncCD
Original Author: Charbel Nemnom (Microsoft MVP/MCT)
Author   : Mario Mancini
Version  : 2.0 
Date     : 03-August-2019 
Updated  : 03-May-2024 (managed identity)
Updated  : 02/11/2025 (add specific managed account id, example user managed identity)
#>

Param ( 
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] 
    [String] $AzureSubscriptionId, 
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $ResourceGroupName, 
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $StorageSyncServiceName, 
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $SyncGroupName, 
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $Path,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $ManagedIdentityAccountID
) 

# Ensures you do not inherit an AzContext in your runbook 
Disable-AzContextAutosave -Scope Process 

# Connect to Azure with user-assigned managed identity
Connect-AzAccount -Identity -AccountId "$ManagedIdentityAccountID"

# Set Azure Subscription context
Set-AzContext -SubscriptionId "$AzureSubscriptionId"

# Get Cloud Endpoint Name
$azsync = Get-AzStorageSyncCloudEndpoint -ResourceGroupName "$ResourceGroupName" `
  -StorageSyncServiceName "$StorageSyncServiceName" -SyncGroupName "$SyncGroupName"

Write-Output "Get Azure Storage Sync Cloud Endpoint Name: $($azsync.CloudEndpointName)"

# CORREZIONE: Usa $SyncGroupName invece di $StorageSyncServiceName
$cloudEndpoint = Get-AzStorageSyncCloudEndpoint -ResourceGroupName $ResourceGroupName `
  -StorageSyncServiceName $StorageSyncServiceName -SyncGroupName $SyncGroupName

Write-Output "Get Azure Storage Sync Cloud Endpoint Name: $($cloudEndpoint.CloudEndpointName)"

# Invoke change detection
Invoke-AzStorageSyncChangeDetection -InputObject $cloudEndpoint -verbose


Write-Output "Sync completata"
