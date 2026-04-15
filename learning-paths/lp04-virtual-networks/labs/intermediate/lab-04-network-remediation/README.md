# Intermediate Lab 04 - Network Remediation

## Time Estimate

- 75 to 105 minutes

## Scenario

Application traffic is blocked by network control drift. You must locate and remediate the blocking configuration while preserving least privilege.

## Objective

1. Identify failing control (NSG, UDR, or peering).
2. Apply minimum viable fix.
3. Verify both connectivity restoration and policy intent.

## Variables

```bash
SUB_ID="<subscription-id>"
RG_NAME="rg-az104-network-dev-eastus2-01"
NSG_NAME="nsg-az104-app-dev-01"
ROUTE_TABLE="rt-az104-spoke-dev-eus2-01"
TARGET_PORT="443"
```

## Step 1 - Capture baseline

```bash
az account set --subscription "$SUB_ID"
az network nsg show -g "$RG_NAME" -n "$NSG_NAME" -o json > evidence-nsg-before.json
az network route-table show -g "$RG_NAME" -n "$ROUTE_TABLE" -o json > evidence-rt-before.json
```

## Step 2 - Apply targeted remediation

```bash
az network nsg rule create \
  --resource-group "$RG_NAME" \
  --nsg-name "$NSG_NAME" \
  --name Allow-App-443 \
  --priority 220 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes 10.0.0.0/8 \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges "$TARGET_PORT"
```

## Step 3 - Re-validate

```bash
az network nsg show -g "$RG_NAME" -n "$NSG_NAME" -o json > evidence-nsg-after.json
```

## Acceptance Criteria

- Blocking network control is identified and remediated.
- Connectivity is restored for approved sources only.
- Evidence and rollback notes are complete.
