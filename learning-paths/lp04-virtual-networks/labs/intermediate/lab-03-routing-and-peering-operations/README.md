# Intermediate Lab 03 - Routing and Peering Operations

## Time Estimate

- 60 to 90 minutes

## Scenario

Traffic between hub and spoke VNets is inconsistent after multiple change windows. You must validate peering state, route propagation, and effective routes for a spoke workload subnet.

## Objective

1. Capture current peering and routing state.
2. Identify a misconfigured route or peering setting.
3. Apply minimal corrective change.
4. Re-validate data path and document rollback.

## Variables

```bash
SUB_ID="<subscription-id>"
RG_NAME="rg-az104-network-dev-eastus2-01"
HUB_VNET="vnet-az104-hub-dev-eus2-01"
SPOKE_VNET="vnet-az104-spoke-dev-eus2-01"
ROUTE_TABLE="rt-az104-spoke-dev-eus2-01"
```

## Step 1 - Capture baseline evidence

```bash
az account set --subscription "$SUB_ID"
az network vnet peering list -g "$RG_NAME" --vnet-name "$HUB_VNET" -o json > evidence-hub-peerings.json
az network vnet peering list -g "$RG_NAME" --vnet-name "$SPOKE_VNET" -o json > evidence-spoke-peerings.json
az network route-table show -g "$RG_NAME" -n "$ROUTE_TABLE" -o json > evidence-route-table.json
```

## Step 2 - Validate effective routes for a workload NIC

```bash
NIC_ID="<workload-nic-resource-id>"
az network nic show-effective-route-table --ids "$NIC_ID" -o json > evidence-effective-routes-before.json
```

## Step 3 - Implement minimum fix

Use one targeted remediation:

- enable missing gateway transit/use remote gateway on peering,
- add missing route to hub inspection path,
- remove stale conflicting route.

Example:

```bash
az network vnet peering update \
  -g "$RG_NAME" \
  --vnet-name "$SPOKE_VNET" \
  -n spoke-to-hub \
  --set useRemoteGateways=true
```

## Step 4 - Re-validate and document

```bash
az network nic show-effective-route-table --ids "$NIC_ID" -o json > evidence-effective-routes-after.json
```

Create:

- `routing-root-cause-summary.md`
- `rollback-plan.md`

## Acceptance Criteria

- Before/after evidence demonstrates corrected route behavior.
- Peering and route updates are minimal and controlled.
- Rollback steps are included and testable.
