# Intermediate Lab 04 - Monitoring Remediation

## Time Estimate

- 75 to 105 minutes

## Scenario

Critical alerting is misconfigured and response routing is incomplete. You must remediate monitoring so incidents are detected and routed correctly.

## Objective

1. Identify broken alert/action configuration.
2. Correct rule scopes and action group linkage.
3. Validate alert lifecycle and evidence outputs.

## Variables

```bash
SUB_ID="<subscription-id>"
RG_NAME="rg-az104-monitor-dev-eastus2-01"
ACTION_GROUP_NAME="ag-az104-ops-dev-01"
ALERT_RULE_NAME="cpu-critical-alert"
TARGET_RESOURCE_ID="<target-resource-id>"
```

## Step 1 - Capture baseline

```bash
az account set --subscription "$SUB_ID"
az monitor action-group show -g "$RG_NAME" -n "$ACTION_GROUP_NAME" -o json > evidence-action-group-before.json
az monitor metrics alert show -g "$RG_NAME" -n "$ALERT_RULE_NAME" -o json > evidence-alert-before.json
```

## Step 2 - Remediate alert configuration

```bash
ACTION_GROUP_ID=$(az monitor action-group show -g "$RG_NAME" -n "$ACTION_GROUP_NAME" --query id -o tsv)
az monitor metrics alert update \
  --name "$ALERT_RULE_NAME" \
  --resource-group "$RG_NAME" \
  --add actions actionGroupId="$ACTION_GROUP_ID"
```

## Step 3 - Validate post-change state

```bash
az monitor metrics alert show -g "$RG_NAME" -n "$ALERT_RULE_NAME" -o json > evidence-alert-after.json
```

## Acceptance Criteria

- Alert rule includes correct scope and action routing.
- Monitoring remediation is evidenced with before/after outputs.
- Rollback instructions are documented.
