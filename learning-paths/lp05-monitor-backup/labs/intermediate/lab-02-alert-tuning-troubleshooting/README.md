# Intermediate Lab 02 - Alert Tuning Troubleshooting

## Time Estimate
- 75 to 105 minutes

## Scenario
Your operations channel is flooded by repeated low-value alerts, while one critical incident was detected too late. You must reduce noise without losing signal.

Investigate and tune:
- threshold values and aggregation windows,
- action group routing,
- alert scope and dimensions,
- suppression and processing rules.

## Variables

```bash
SUB_ID="<subscription-id>"
RG_NAME="rg-az104-monitor-dev-eastus2-01"
ACTION_GROUP_NAME="ag-az104-ops-dev-01"
NOISY_ALERT="cpu-warning-alert"
CRITICAL_ALERT="cpu-critical-alert"
```

## Step 1 - Capture current alert state

```bash
az account set --subscription "$SUB_ID"
az monitor metrics alert list -g "$RG_NAME" -o json > evidence-alert-rules-before.json
az monitor action-group show -g "$RG_NAME" -n "$ACTION_GROUP_NAME" -o json > evidence-action-group.json
az monitor activity-log alert list -g "$RG_NAME" -o json > evidence-activity-alerts-before.json
```

## Step 2 - Analyze noisy vs missed alerts

1. Identify alert rules with high fire count and low operational value.
2. Identify critical condition not firing quickly enough.
3. Document baseline in `alert-analysis.md`.

## Step 3 - Apply tuning changes

Examples:
- increase warning threshold and evaluation window,
- keep strict critical threshold with faster frequency,
- limit dimensions to production resources only.

```bash
az monitor metrics alert update \
  --name "$NOISY_ALERT" \
  --resource-group "$RG_NAME" \
  --set evaluationFrequency=PT10M windowSize=PT15M severity=3

az monitor metrics alert update \
  --name "$CRITICAL_ALERT" \
  --resource-group "$RG_NAME" \
  --set evaluationFrequency=PT1M windowSize=PT5M severity=1
```

Optional suppression rule example:

```bash
az monitor alert-processing-rule create \
  --name "nightly-maintenance-suppress" \
  --resource-group "$RG_NAME" \
  --scopes "/subscriptions/$SUB_ID/resourceGroups/$RG_NAME" \
  --description "Suppress non-critical alerts during maintenance"
```

## Step 4 - Re-validate

```bash
az monitor metrics alert list -g "$RG_NAME" -o json > evidence-alert-rules-after.json
```

Create:
- `root-cause-summary.md`
- `tuning-decisions.md`
- `rollback-plan.md`

## Acceptance Criteria
- Alert noise is measurably reduced.
- Critical detection path is improved.
- Action routing is validated.
- Rollback plan restores prior settings if needed.

