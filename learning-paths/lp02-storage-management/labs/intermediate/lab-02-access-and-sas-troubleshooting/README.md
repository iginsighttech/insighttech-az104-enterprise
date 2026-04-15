# Intermediate Lab 02 - Access and SAS Troubleshooting

## Time Estimate
- 75 to 105 minutes

## Scenario
An application team reports intermittent blob download failures. Some users can upload but cannot read blobs. Others can read only for a few minutes before access is denied.

Your job is to identify whether the issue is caused by:
- incorrect RBAC data-plane role assignment,
- invalid or expired SAS token,
- container-level permission mismatch,
- storage firewall/public network restrictions.

## Variables

```bash
SUB_ID="<subscription-id>"
RG_NAME="rg-az104-storage-dev-eastus2-01"
STORAGE_ACCOUNT="staz104blobdev01"
CONTAINER="raw"
```

```powershell
$SubscriptionId = "<subscription-id>"
$ResourceGroupName = "rg-az104-storage-dev-eastus2-01"
$StorageAccountName = "staz104blobdev01"
$ContainerName = "raw"
```

## Step 1 - Collect baseline evidence

### Azure CLI
```bash
az account set --subscription "$SUB_ID"
az storage account show -g "$RG_NAME" -n "$STORAGE_ACCOUNT" -o json > evidence-storage-account.json
az role assignment list --scope "/subscriptions/$SUB_ID/resourceGroups/$RG_NAME" -o json > evidence-rbac-rg.json
az storage container show --account-name "$STORAGE_ACCOUNT" --name "$CONTAINER" --auth-mode login -o json > evidence-container.json
```

### PowerShell
```powershell
Select-AzSubscription -SubscriptionId $SubscriptionId
Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName | ConvertTo-Json -Depth 8 | Out-File evidence-storage-account-pwsh.json
Get-AzRoleAssignment -Scope "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName" | ConvertTo-Json -Depth 8 | Out-File evidence-rbac-rg-pwsh.json
```

## Step 2 - Reproduce deny and success paths

1. Generate a short-lived SAS token (5 minutes) and attempt read after expiration.
2. Generate a corrected read SAS token (60 minutes) and validate download success.
3. Record both outcomes in `validation-results.md`.

```bash
EXPIRY_SHORT=$(date -u -d '+5 minutes' '+%Y-%m-%dT%H:%MZ')
EXPIRY_LONG=$(date -u -d '+60 minutes' '+%Y-%m-%dT%H:%MZ')

SAS_SHORT=$(az storage container generate-sas --account-name "$STORAGE_ACCOUNT" --name "$CONTAINER" --permissions r --expiry "$EXPIRY_SHORT" --auth-mode login -o tsv)
SAS_LONG=$(az storage container generate-sas --account-name "$STORAGE_ACCOUNT" --name "$CONTAINER" --permissions rl --expiry "$EXPIRY_LONG" --auth-mode login -o tsv)
```

## Step 3 - Implement minimum fix

Choose the smallest corrective action based on findings:
- assign missing `Storage Blob Data Reader` role at correct scope,
- rotate to proper SAS permissions (`r` vs `rl` as needed),
- adjust network access settings for approved source path only.

Example RBAC fix:

```bash
PRINCIPAL_ID="<object-id>"
az role assignment create \
  --assignee-object-id "$PRINCIPAL_ID" \
  --assignee-principal-type Group \
  --role "Storage Blob Data Reader" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/$RG_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"
```

## Step 4 - Re-validate and document rollback

Produce:
- `root-cause-summary.md`
- `rollback-plan.md`
- `validation-results.md` showing one denied test and one successful test after fix.

## Acceptance Criteria
- Root cause is specific (RBAC, SAS, or network).
- Evidence captures before and after states.
- Fix follows least privilege and minimal blast radius.
- Rollback steps are executable.

