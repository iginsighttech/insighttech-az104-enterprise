# Intermediate Lab 01 - Storage Operations Runbook

## Purpose

This lab converts M01 storage foundations into repeatable operational work. You will manage storage account lifecycle, container and blob operations, SAS token generation, and access-tier transitions using both CLI and PowerShell.

## Time Estimate

- 60 to 90 minutes

## Prerequisites

- Completed beginner Lab 01
- Non-production subscription access
- Contributor or Storage Account Contributor role on target resource group
- Azure CLI and PowerShell Az installed

## Scenario

The platform team manages a storage account for an application that writes raw data, promotes it to curated, and archives stale blobs. You must:

1. Validate the storage account and container structure
2. Demonstrate blob lifecycle via manual tier changes
3. Generate and validate a SAS token scoped to a single container
4. Produce evidence for audit and handoff

## Variables

```bash
SUB_ID="<subscription-id>"
LOCATION="eastus2"
RG_NAME="rg-az104-storageops-dev-eastus2-01"
STORAGE_ACCOUNT="staz104storopsdev01"
```

```powershell
$SubscriptionId = "<subscription-id>"
$Location = "eastus2"
$RgName = "rg-az104-storageops-dev-eastus2-01"
$StorageAccountName = "staz104storopsdev01"
```

## Task 1 - Set Context and Create Baseline Resource Group

### Azure CLI

```bash
az account set --subscription "$SUB_ID"

az group create \
  --name "$RG_NAME" \
  --location "$LOCATION" \
  --tags Owner="student" CostCenter="IT-104" Environment="dev" Workload="storage-ops" DataClass="internal" ExpirationDate="2026-12-31"
```

### PowerShell

```powershell
Select-AzSubscription -SubscriptionId $SubscriptionId

New-AzResourceGroup `
  -Name $RgName `
  -Location $Location `
  -Tag @{
    Owner          = "student"
    CostCenter     = "IT-104"
    Environment    = "dev"
    Workload       = "storage-ops"
    DataClass      = "internal"
    ExpirationDate = "2026-12-31"
  }
```

## Task 2 - Create or Validate Storage Account and Containers

### Azure CLI

```bash
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --https-only true \
  --allow-blob-public-access false

ACCOUNT_KEY=$(az storage account keys list \
  --account-name "$STORAGE_ACCOUNT" \
  --resource-group "$RG_NAME" \
  --query "[0].value" -o tsv)

for container in raw curated archive; do
  az storage container create \
    --name "$container" \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$ACCOUNT_KEY"
done

az storage container list --account-name "$STORAGE_ACCOUNT" --account-key "$ACCOUNT_KEY" -o table
```

### PowerShell

```powershell
$storageAccount = New-AzStorageAccount `
  -ResourceGroupName $RgName `
  -Name $StorageAccountName `
  -Location $Location `
  -SkuName Standard_LRS `
  -Kind StorageV2 `
  -MinimumTlsVersion TLS1_2 `
  -EnableHttpsTrafficOnly $true `
  -AllowBlobPublicAccess $false

$ctx = $storageAccount.Context

foreach ($container in @("raw", "curated", "archive")) {
  New-AzStorageContainer -Name $container -Context $ctx -ErrorAction SilentlyContinue
}

Get-AzStorageContainer -Context $ctx | Select-Object Name, PublicAccess
```

## Task 3 - Upload a Test Blob and Change its Access Tier

### Azure CLI

```bash
echo "test-content-$(date +%s)" > /tmp/sample.txt

az storage blob upload \
  --account-name "$STORAGE_ACCOUNT" \
  --account-key "$ACCOUNT_KEY" \
  --container-name raw \
  --name sample.txt \
  --file /tmp/sample.txt

az storage blob show \
  --account-name "$STORAGE_ACCOUNT" \
  --account-key "$ACCOUNT_KEY" \
  --container-name raw \
  --name sample.txt \
  --query "{name:name,tier:properties.blobTierLabel}" -o table

az storage blob set-tier \
  --account-name "$STORAGE_ACCOUNT" \
  --account-key "$ACCOUNT_KEY" \
  --container-name raw \
  --name sample.txt \
  --tier Cool
```

### PowerShell

```powershell
$tempFile = New-TemporaryFile
Set-Content -Path $tempFile -Value "test-content-$(Get-Date -Format 'yyyyMMddHHmmss')"

Set-AzStorageBlobContent `
  -Context $ctx `
  -Container "raw" `
  -File $tempFile.FullName `
  -Blob "sample.txt" `
  -Force

$blob = Get-AzStorageBlob -Context $ctx -Container "raw" -Blob "sample.txt"
$blob | Select-Object Name, @{N="Tier";E={$_.ICloudBlob.Properties.StandardBlobTier}}

$blob.ICloudBlob.SetStandardBlobTierAsync("Cool").Wait()
```

## Task 4 - Generate and Validate a Scoped SAS Token

### Azure CLI

```bash
EXPIRY=$(date -u -d "+2 hours" '+%Y-%m-%dT%H:%MZ')

SAS_TOKEN=$(az storage container generate-sas \
  --account-name "$STORAGE_ACCOUNT" \
  --account-key "$ACCOUNT_KEY" \
  --name raw \
  --permissions rl \
  --expiry "$EXPIRY" \
  -o tsv)

echo "SAS token generated"

az storage blob list \
  --account-name "$STORAGE_ACCOUNT" \
  --sas-token "$SAS_TOKEN" \
  --container-name raw \
  -o table
```

### PowerShell

```powershell
$expiry = (Get-Date).AddHours(2).ToUniversalTime()

$sasToken = New-AzStorageContainerSASToken `
  -Context $ctx `
  -Name "raw" `
  -Permission "rl" `
  -ExpiryTime $expiry

Write-Output "SAS token generated: $sasToken"

$sasCtx = New-AzStorageContext `
  -StorageAccountName $StorageAccountName `
  -SasToken $sasToken

Get-AzStorageBlob -Context $sasCtx -Container "raw" | Select-Object Name
```

## Task 5 - Produce Evidence Package

Create these files in your branch under this lab folder:

- `evidence-account.json` — output of `az storage account show`
- `evidence-containers.txt` — container list
- `evidence-blob-tiers.txt` — blob show output before and after tier change
- `evidence-sas-validation.txt` — blob list output using SAS token only
- `ops-notes.md` — short note on why SAS scope was limited to `rl` on a single container

## Acceptance Criteria

- Storage account exists with HTTPS-only, TLS 1.2, public blob access disabled
- All three containers (raw, curated, archive) exist
- sample.txt uploaded and tier changed to Cool
- SAS token scoped to raw container with read-list only; write attempt using SAS rejected
- Evidence files are complete and readable

## Troubleshooting

### Storage account name already taken

- Cause: storage account names are globally unique
- Fix: append a random suffix: `staz104stor$(openssl rand -hex 3)dev01`

### Tier change fails with `BlobAccessTierNotSupported`

- Cause: blob was uploaded as BlockBlob to a Premium or page-blob account
- Fix: confirm account kind is StorageV2 and sku is Standard_LRS

### SAS token rejected

- Cause: system clock skew or incorrect expiry format
- Fix: use `date -u` (CLI) or `ToUniversalTime()` (PowerShell) for expiry; wait 30 seconds and retry
