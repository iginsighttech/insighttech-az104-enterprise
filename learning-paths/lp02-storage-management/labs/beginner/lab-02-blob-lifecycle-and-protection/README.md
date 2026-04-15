# Beginner Lab 02 - Blob Lifecycle and Protection

Goal: configure blob data protection and lifecycle controls for a storage account used by application teams.

## Variables

Azure CLI:

```bash
SUB_ID="<subscription-id>"
RG_NAME="rg-az104-storage-dev-eastus2-01"
LOCATION="eastus2"
STORAGE_ACCOUNT="staz104blobdev01"
```

PowerShell:

```powershell
$SubscriptionId = "<subscription-id>"
$ResourceGroupName = "rg-az104-storage-dev-eastus2-01"
$Location = "eastus2"
$StorageAccountName = "staz104blobdev01"
```

## Task 1 - Create or validate storage baseline

Azure CLI:

```bash
az account set --subscription "$SUB_ID"
az group create --name "$RG_NAME" --location "$LOCATION"

az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2
```

PowerShell:

```powershell
Select-AzSubscription -SubscriptionId $SubscriptionId
New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force | Out-Null

New-AzStorageAccount \
  -ResourceGroupName $ResourceGroupName \
  -Name $StorageAccountName \
  -Location $Location \
  -SkuName Standard_LRS \
  -Kind StorageV2 | Out-Null
```

## Task 2 - Create required data containers

Azure CLI:

```bash
for c in raw curated archive; do
  az storage container create \
    --account-name "$STORAGE_ACCOUNT" \
    --name "$c" \
    --auth-mode login
done
```

  PowerShell:

```powershell
$ctx = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Context
"raw","curated","archive" | ForEach-Object {
  New-AzStorageContainer -Name $_ -Context $ctx -ErrorAction SilentlyContinue | Out-Null
}
```

## Task 3 - Enable protection controls

Azure CLI:

```bash
az storage account blob-service-properties update \
  --account-name "$STORAGE_ACCOUNT" \
  --resource-group "$RG_NAME" \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 14
```

PowerShell:

```powershell
Enable-AzStorageBlobDeleteRetentionPolicy \
  -ResourceGroupName $ResourceGroupName \
  -StorageAccountName $StorageAccountName \
  -RetentionDays 14 | Out-Null
```

## Task 4 - Configure lifecycle policy

Azure CLI:

```bash
cat > lifecycle-policy.json <<'JSON'
{
  "rules": [
    {
      "enabled": true,
      "name": "tier-and-archive",
      "type": "Lifecycle",
      "definition": {
        "filters": {
          "blobTypes": ["blockBlob"],
          "prefixMatch": ["raw/"]
        },
        "actions": {
          "baseBlob": {
            "tierToCool": {"daysAfterModificationGreaterThan": 30},
            "tierToArchive": {"daysAfterModificationGreaterThan": 90}
          }
        }
      }
    }
  ]
}
JSON

az storage account management-policy create \
  --account-name "$STORAGE_ACCOUNT" \
  --resource-group "$RG_NAME" \
  --policy @lifecycle-policy.json
```

## Verify

- Confirm versioning and delete retention are enabled.
- Confirm containers `raw`, `curated`, and `archive` exist.
- Confirm management policy exists.

```bash
az storage account blob-service-properties show --account-name "$STORAGE_ACCOUNT" --resource-group "$RG_NAME" -o table
az storage container list --account-name "$STORAGE_ACCOUNT" --auth-mode login -o table
az storage account management-policy show --account-name "$STORAGE_ACCOUNT" --resource-group "$RG_NAME"
```

## Validation

```powershell
pwsh -File learning-paths/lp02-storage-management/modules/m02-blob-services-data-protection/validation/validate.ps1 -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName
```
