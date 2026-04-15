# Beginner Lab 03 — Azure Files and Sync

**Track:** Beginner
**Learning Path:** LP02 — Implement and manage storage
**Module Coverage:** M03 — Azure Files, Sync, and Data Movement
**Estimated Time:** 45 minutes

## Goal

Create an Azure Files share in a storage account, configure share-level access, and demonstrate the Azure File Sync service topology. Confirm that the share is accessible and that soft-delete protection is enabled.

---

## Variables

Set these at the start of your session and reference them throughout every task.

Bash / Azure CLI:

```bash
SUBSCRIPTION_ID="<your-subscription-id>"
LOCATION="eastus2"
RG_NAME="rg-az104-storage-dev-eastus2-01"
STORAGE_ACCOUNT_NAME="staz104stordev01"
SHARE_NAME="labfiles"
SHARE_QUOTA_GiB=100
```

PowerShell:

```powershell
$SubscriptionId      = "<your-subscription-id>"
$Location            = "eastus2"
$ResourceGroupName   = "rg-az104-storage-dev-eastus2-01"
$StorageAccountName  = "staz104stordev01"
$ShareName           = "labfiles"
$ShareQuotaGiB       = 100
```

---

## Task 1 — Set subscription context

Azure CLI:

```bash
az account set --subscription "$SUBSCRIPTION_ID"
az account show --query "{name:name, id:id}" -o table
```

PowerShell:

```powershell
Set-AzContext -SubscriptionId $SubscriptionId
Get-AzContext | Select-Object Name, Subscription
```

---

## Task 2 — Create or confirm the storage account

If you completed lab-01, the storage account already exists. Skip the `create` command and proceed to verification.

Azure CLI:

```bash
az storage account create \
  --resource-group "$RG_NAME" \
  --name "$STORAGE_ACCOUNT_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --https-only true \
  --output table
```

Verify:

```bash
az storage account show \
  --resource-group "$RG_NAME" \
  --name "$STORAGE_ACCOUNT_NAME" \
  --query "{name:name, httpsOnly:enableHttpsTrafficOnly, minTls:minimumTlsVersion}" \
  -o table
```

---

## Task 3 — Create an Azure Files share

Azure CLI:

```bash
az storage share-rm create \
  --resource-group "$RG_NAME" \
  --storage-account "$STORAGE_ACCOUNT_NAME" \
  --name "$SHARE_NAME" \
  --quota "$SHARE_QUOTA_GiB" \
  --output table
```

PowerShell:

```powershell
$storageCtx = (Get-AzStorageAccount `
  -ResourceGroupName $ResourceGroupName `
  -Name $StorageAccountName).Context

New-AzStorageShare `
  -Name $ShareName `
  -Quota $ShareQuotaGiB `
  -Context $storageCtx
```

---

## Task 4 — Enable soft delete on the file share

Soft delete allows recovery of accidentally deleted shares or files within the configured retention window.

Azure CLI:

```bash
az storage account file-service-properties update \
  --resource-group "$RG_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --enable-delete-retention true \
  --delete-retention-days 7
```

PowerShell:

```powershell
Update-AzStorageFileServiceProperty `
  -ResourceGroupName $ResourceGroupName `
  -StorageAccountName $StorageAccountName `
  -EnableShareDeleteRetentionPolicy $true `
  -ShareRetentionDays 7
```

---

## Task 5 — Verify the file share and soft-delete settings

Azure CLI:

```bash
az storage share-rm list \
  --resource-group "$RG_NAME" \
  --storage-account "$STORAGE_ACCOUNT_NAME" \
  --query "[].{name:name, quotaGiB:shareQuota}" \
  -o table

az storage account file-service-properties show \
  --resource-group "$RG_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --query "shareDeleteRetentionPolicy" \
  -o json
```

Confirm the share appears, quota is `100`, and `enabled` is `true` with `days` set to `7`.

PowerShell:

```powershell
Get-AzStorageShare -Context $storageCtx | Select-Object Name, Quota
Get-AzStorageFileServiceProperty -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName |
  Select-Object -ExpandProperty ShareDeleteRetentionPolicy
```

---

## Task 6 — Run validation (required)

```powershell
pwsh learning-paths/lp02-storage-management/modules/m03-files-sync-data-movement/validation/validate.ps1 `
  -StorageAccountName $StorageAccountName
```

A passing result confirms the storage account has an active file share with soft-delete enabled.

---

## Clean-up (optional)

```bash
az group delete --name "$RG_NAME" --yes --no-wait
```
