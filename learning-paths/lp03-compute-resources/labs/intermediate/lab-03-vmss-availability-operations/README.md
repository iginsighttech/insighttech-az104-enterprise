# Intermediate Lab 03 - VMSS Availability Operations

## Time Estimate

- 60 to 90 minutes

## Scenario

An application on VM scale sets is experiencing inconsistent availability during traffic spikes. You must verify scale configuration, zone resilience posture, and safe maintenance operations.

## Objective

1. Validate VMSS health and capacity.
2. Tune autoscale profile and thresholds.
3. Execute a safe rolling upgrade operation.
4. Capture operational evidence and rollback notes.

## Variables

```bash
SUB_ID="<subscription-id>"
RG_NAME="rg-az104-compute-dev-eastus2-01"
VMSS_NAME="vmss-az104-web-dev-01"
```

```powershell
$SubscriptionId = "<subscription-id>"
$ResourceGroupName = "rg-az104-compute-dev-eastus2-01"
$VmssName = "vmss-az104-web-dev-01"
```

## Step 1 - Capture baseline evidence

```bash
az account set --subscription "$SUB_ID"
az vmss show -g "$RG_NAME" -n "$VMSS_NAME" -o json > evidence-vmss-baseline.json
az vmss list-instances -g "$RG_NAME" -n "$VMSS_NAME" -o json > evidence-vmss-instances-baseline.json
az monitor autoscale list -g "$RG_NAME" -o json > evidence-autoscale-baseline.json
```

## Step 2 - Tune autoscale profile

```bash
az monitor autoscale update \
  --resource-group "$RG_NAME" \
  --name "autoscale-$VMSS_NAME" \
  --min-count 2 \
  --max-count 6 \
  --count 3

az monitor autoscale rule create \
  --resource-group "$RG_NAME" \
  --autoscale-name "autoscale-$VMSS_NAME" \
  --condition "Percentage CPU > 70 avg 5m" \
  --scale out 1
```

## Step 3 - Perform controlled maintenance

1. Set manual upgrade policy (if required by your baseline).
2. Apply model update.
3. Run rolling upgrade and monitor instance status.

```bash
az vmss update -g "$RG_NAME" -n "$VMSS_NAME" --set upgradePolicy.mode=Rolling
az vmss rolling-upgrade start -g "$RG_NAME" -n "$VMSS_NAME"
az vmss rolling-upgrade get-latest -g "$RG_NAME" -n "$VMSS_NAME" -o json > evidence-rolling-upgrade.json
```

## Step 4 - Validate outcome

```bash
az vmss list-instances -g "$RG_NAME" -n "$VMSS_NAME" -o json > evidence-vmss-instances-after.json
```

Create:

- `availability-operations-summary.md`
- `rollback-plan.md`

## Acceptance Criteria

- VMSS capacity and autoscale profile match intended operations model.
- Rolling maintenance completed without service outage evidence.
- Documentation includes rollback and verification steps.
