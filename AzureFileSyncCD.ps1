<#
.DESCRIPTION
A Runbook example which checks for files and directories changes
for a specific Azure File Share in a specific Sync Group / Cloud Endpoint
using Managed Identity.

.NOTES
Filename : AzureFileSyncCD
Original Author: Charbel Nemnom (Microsoft MVP/MCT)
Author   : Mario Mancini
Version  : 2.6
Date     : 03-August-2019
Updated  : 03-May-2024 (managed identity)
Updated  : 02-Nov-2025 (add specific managed account id, example user-assigned managed identity)
Updated  : 11-Jun-2026 (Path optional for full-share scan, improved MI handling, clearer logging)
#>

Param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $AzureSubscriptionId,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $StorageSyncServiceName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $SyncGroupName,

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string] $Path = "",

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string] $ManagedIdentityAccountID = ""
)

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with managed identity
try {
    if (-not [string]::IsNullOrWhiteSpace($ManagedIdentityAccountID)) {
        Write-Output "Autenticazione con User-Assigned Managed Identity specificata"
        Connect-AzAccount -Identity -AccountId $ManagedIdentityAccountID -ErrorAction Stop | Out-Null
    }
    else {
        Write-Output "Autenticazione con Managed Identity associata al runbook"
        Connect-AzAccount -Identity -ErrorAction Stop | Out-Null
    }
}
catch {
    throw "Autenticazione con Managed Identity non riuscita. Se il runbook deve usare una User-Assigned Managed Identity specifica, valorizza il parametro 'ManagedIdentityAccountID'. Errore: $($_.Exception.Message)"
}

# Set Azure Subscription context
Set-AzContext -SubscriptionId $AzureSubscriptionId -ErrorAction Stop | Out-Null

# Get Cloud Endpoint
Write-Output "Recupero Cloud Endpoint per SyncGroup: $SyncGroupName"

$cloudEndpoint = Get-AzStorageSyncCloudEndpoint `
    -ResourceGroupName $ResourceGroupName `
    -StorageSyncServiceName $StorageSyncServiceName `
    -SyncGroupName $SyncGroupName `
    -ErrorAction Stop

# Null / sanity check
if ($null -eq $cloudEndpoint) {
    throw "Cloud Endpoint non trovato. Verifica i parametri: ResourceGroup='$ResourceGroupName', StorageSyncService='$StorageSyncServiceName', SyncGroup='$SyncGroupName'."
}

if ($cloudEndpoint -is [System.Array]) {
    throw "Trovati più Cloud Endpoint nel SyncGroup '$SyncGroupName'. Questo script supporta un solo Cloud Endpoint per esecuzione."
}

# Normalize accidental literal double quotes from job input
if ($Path -eq '""') {
    $Path = ""
}

Write-Output "SyncGroupName: $SyncGroupName"
Write-Output "CloudEndpointName: $($cloudEndpoint.CloudEndpointName)"

# Invoke change detection
if ([string]::IsNullOrWhiteSpace($Path)) {
    Write-Output "DirectoryPath: ''"
    Write-Output "Avvio change detection su intera share"

    Invoke-AzStorageSyncChangeDetection `
        -ResourceGroupName $ResourceGroupName `
        -StorageSyncServiceName $StorageSyncServiceName `
        -SyncGroupName $SyncGroupName `
        -CloudEndpointName $($cloudEndpoint.CloudEndpointName) `
        -Verbose `
        -ErrorAction Stop
}
else {
    Write-Output "DirectoryPath: '$Path'"
    Write-Output "Avvio change detection per path specifico (ricorsivo)"

    Invoke-AzStorageSyncChangeDetection `
        -ResourceGroupName $ResourceGroupName `
        -StorageSyncServiceName $StorageSyncServiceName `
        -SyncGroupName $SyncGroupName `
        -CloudEndpointName $($cloudEndpoint.CloudEndpointName) `
        -DirectoryPath $Path `
        -Recursive `
        -Verbose `
        -ErrorAction Stop
}

Write-Output "Sync completata"
