# Intermediate Lab 04 - Encryption and Network Remediation

## Time Estimate

- 75 to 105 minutes

## Scenario

A storage workload fails compliance checks and cannot be reached from an approved workload subnet.

## Objective

1. Enforce required encryption and transport settings.
2. Correct network rules to allow approved source paths only.
3. Validate deny and allow behavior with evidence.

## Variables

```bash
SUB_ID="<subscription-id>"
RG_NAME="rg-az104-storage-dev-eastus2-01"
STORAGE_ACCOUNT="staz104blobdev01"
APPROVED_SUBNET="/subscriptions/<subscription-id>/resourceGroups/rg-az104-network-dev-eastus2-01/providers/Microsoft.Network/virtualNetworks/vnet-az104-spoke-dev-eus2-01/subnets/snet-spoke-app"
```

## Step 1 - Capture baseline

```bash
az account set --subscription "$SUB_ID"
az storage account show -g "$RG_NAME" -n "$STORAGE_ACCOUNT" -o json > evidence-storage-before.json
az storage account network-rule list -g "$RG_NAME" --account-name "$STORAGE_ACCOUNT" -o json > evidence-network-before.json
```

## Step 2 - Remediate encryption baseline

```bash
az storage account update \
  --resource-group "$RG_NAME" \
  --name "$STORAGE_ACCOUNT" \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false
```

## Step 3 - Remediate network rules

```bash
az storage account update -g "$RG_NAME" -n "$STORAGE_ACCOUNT" --default-action Deny
az storage account network-rule add -g "$RG_NAME" --account-name "$STORAGE_ACCOUNT" --subnet "$APPROVED_SUBNET"
```

## Step 4 - Re-validate

```bash
az storage account show -g "$RG_NAME" -n "$STORAGE_ACCOUNT" -o json > evidence-storage-after.json
az storage account network-rule list -g "$RG_NAME" --account-name "$STORAGE_ACCOUNT" -o json > evidence-network-after.json
```

## Acceptance Criteria

- Storage encryption and transport requirements are enforced.
- Public access is restricted and only approved network paths are allowed.
- Before/after evidence and rollback notes are documented.
