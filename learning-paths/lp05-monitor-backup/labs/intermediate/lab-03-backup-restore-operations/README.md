# Intermediate Lab 03 - Backup and Restore Operations

## Time Estimate

- 60 to 90 minutes

## Scenario

A critical workload lost data after an operator error. You must verify backup readiness and execute a controlled restore test with auditable evidence.

## Objective

1. Validate Recovery Services vault and policy configuration.
2. Trigger backup for protected item.
3. Perform item-level or workload restore test.
4. Document recovery evidence and rollback steps.

## Variables

```bash
SUB_ID="<subscription-id>"
RG_NAME="rg-az104-monitor-dev-eastus2-01"
VAULT_NAME="rsv-az104-ops-dev-01"
PROTECTED_ITEM_NAME="<protected-item-name>"
```

## Step 1 - Capture baseline

```bash
az account set --subscription "$SUB_ID"
az backup vault show -g "$RG_NAME" -n "$VAULT_NAME" -o json > evidence-vault-baseline.json
az backup protection item list -g "$RG_NAME" -v "$VAULT_NAME" -o json > evidence-protected-items.json
```

## Step 2 - Trigger and monitor backup job

```bash
az backup protection backup-now \
  --resource-group "$RG_NAME" \
  --vault-name "$VAULT_NAME" \
  --item-name "$PROTECTED_ITEM_NAME" \
  --retain-until "2026-12-31T23:59:00Z"

az backup job list -g "$RG_NAME" -v "$VAULT_NAME" -o json > evidence-backup-jobs.json
```

## Step 3 - Execute restore test

Use your protected workload type to run one restore operation and capture output.

```bash
az backup recoverypoint list -g "$RG_NAME" -v "$VAULT_NAME" --item-name "$PROTECTED_ITEM_NAME" -o json > evidence-recovery-points.json
```

## Step 4 - Validate and document

Create:

- `restore-validation-results.md`
- `backup-operations-summary.md`
- `rollback-plan.md`

## Acceptance Criteria

- Backup and recovery points are verified with evidence.
- One restore path is validated end-to-end.
- Documentation covers rollback and post-restore verification.
