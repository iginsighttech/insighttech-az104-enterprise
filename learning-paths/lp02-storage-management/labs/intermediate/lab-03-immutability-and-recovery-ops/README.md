# Intermediate Lab 03 - Immutability and Recovery Operations

## Time Estimate

- 60 to 90 minutes

## Scenario

Your compliance team requires immutable protection for critical blob data, while operations needs an auditable recovery path for accidental deletions.

## Objective

1. Enable versioning and soft delete.
2. Apply immutable retention to a protected container.
3. Simulate delete/recovery workflow.
4. Capture evidence and operational notes.

## Variables

```bash
SUB_ID="<subscription-id>"
RG_NAME="rg-az104-storage-dev-eastus2-01"
STORAGE_ACCOUNT="staz104blobdev01"
CONTAINER="archive"
```

```powershell
$SubscriptionId = "<subscription-id>"
$ResourceGroupName = "rg-az104-storage-dev-eastus2-01"
$StorageAccountName = "staz104blobdev01"
$ContainerName = "archive"
```

## Step 1 - Capture baseline

```bash
az account set --subscription "$SUB_ID"
az storage account blob-service-properties show --account-name "$STORAGE_ACCOUNT" --resource-group "$RG_NAME" -o json > evidence-blob-service-baseline.json
az storage container show --account-name "$STORAGE_ACCOUNT" --name "$CONTAINER" --auth-mode login -o json > evidence-container-baseline.json
```

## Step 2 - Enable protection controls

```bash
az storage account blob-service-properties update \
  --account-name "$STORAGE_ACCOUNT" \
  --resource-group "$RG_NAME" \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 14

az storage container immutability-policy create \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name "$CONTAINER" \
  --period 7 \
  --allow-protected-append-writes true
```

## Step 3 - Simulate recovery workflow

1. Upload test blob to the protected container.
2. Delete blob and confirm soft-delete/version recoverability.
3. Restore by copying previous version and document result.

```bash
echo "immutable-test" > test.txt
az storage blob upload --account-name "$STORAGE_ACCOUNT" --container-name "$CONTAINER" --name "test.txt" --file test.txt --auth-mode login
az storage blob delete --account-name "$STORAGE_ACCOUNT" --container-name "$CONTAINER" --name "test.txt" --auth-mode login
az storage blob list --account-name "$STORAGE_ACCOUNT" --container-name "$CONTAINER" --include d,v --auth-mode login -o json > evidence-blob-versions.json
```

## Step 4 - Document outcome

Create:

- `recovery-runbook.md`
- `validation-results.md`
- `rollback-plan.md`

## Acceptance Criteria

- Immutability and retention controls are enabled and evidenced.
- Recovery behavior is demonstrated with before/after evidence.
- Rollback and operations notes are clear and reproducible.
