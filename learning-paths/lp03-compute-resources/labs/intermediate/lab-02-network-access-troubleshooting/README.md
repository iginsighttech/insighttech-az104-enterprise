# Intermediate Lab 02 - Network Access Troubleshooting

## Time Estimate
- 75 to 105 minutes

## Scenario
Operations reports that users cannot reach a compute workload. VM instances are healthy, but traffic from approved source ranges is blocked intermittently.

Investigate and isolate whether the issue is caused by:
- NSG rule ordering,
- route table next hop,
- missing load balancer probe/rule,
- or subnet association drift.

## Variables

```bash
SUB_ID="<subscription-id>"
RG_NAME="rg-az104-compute-dev-eastus2-01"
VM_NAME="vm-az104-app-dev-01"
TARGET_IP="10.20.1.4"
TARGET_PORT="443"
```

```powershell
$SubscriptionId = "<subscription-id>"
$ResourceGroupName = "rg-az104-compute-dev-eastus2-01"
$VmName = "vm-az104-app-dev-01"
$TargetIp = "10.20.1.4"
$TargetPort = 443
```

## Step 1 - Capture current network state

```bash
az account set --subscription "$SUB_ID"
az vm show -g "$RG_NAME" -n "$VM_NAME" -d -o json > evidence-vm-state.json

NIC_ID=$(az vm show -g "$RG_NAME" -n "$VM_NAME" --query 'networkProfile.networkInterfaces[0].id' -o tsv)
az network nic show --ids "$NIC_ID" -o json > evidence-nic.json
az network nic list-effective-nsg --ids "$NIC_ID" -o json > evidence-effective-nsg.json
az network nic show-effective-route-table --ids "$NIC_ID" -o json > evidence-effective-routes.json
```

## Step 2 - Reproduce failure and test dependencies

```bash
az network watcher test-connectivity \
  --source-resource "$NIC_ID" \
  --dest-address "$TARGET_IP" \
  --dest-port "$TARGET_PORT" \
  --output json > evidence-connectivity-test-before.json
```

## Step 3 - Apply minimum viable fix

Examples:
- add missing NSG allow rule for approved source,
- correct UDR next hop,
- fix load balancer health probe/port mapping.

Example NSG update:

```bash
az network nsg rule create \
  --resource-group "$RG_NAME" \
  --nsg-name "nsg-az104-app-dev-01" \
  --name "Allow-App-443-From-Corp" \
  --priority 200 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes 10.0.0.0/8 \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 443
```

## Step 4 - Validate and document

1. Re-run connectivity test and save `evidence-connectivity-test-after.json`.
2. Capture updated effective NSG/routes.
3. Create `root-cause-summary.md` and `rollback-plan.md`.

## Acceptance Criteria
- Root cause is proven by before/after evidence.
- Fix is minimal and limited in blast radius.
- Rollback commands are included and tested.
- Documentation is reproducible by a reviewer.

