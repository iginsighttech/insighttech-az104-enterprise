# Intermediate Lab 05 - Network Compliance Reporting

## Time Estimate

- 45 to 75 minutes

## Prerequisites

- At least two VNets or subnets in the subscription
- One subnet intentionally missing an NSG association
- Network Watcher enabled in at least one region
- Bash and PowerShell available

## Objective

Generate an audit-friendly network compliance report that verifies each VNet and subnet meets platform security standards.

## Required Network Controls

- Every subnet has an NSG associated (except GatewaySubnet and AzureBastionSubnet)
- Network Watcher is enabled in each region that has a VNet
- No subnet uses the /8 or /16 address space without justification tag
- DDoS protection plan is configured if required by policy (check policy assignment)
- No VNet has an overlapping address space with hub VNets

## Tasks

1. Run PowerShell report: `shared/scripts/pwsh/validation/network-compliance-report.ps1`
2. Run CLI report: `shared/scripts/cli/validation/network-compliance-report.sh`
3. Cross-check outputs and attach CSV + JSON to PR evidence

## Step 1 - Execute PowerShell Report

```powershell
$SubscriptionId = "<subscription-id>"
Select-AzSubscription -SubscriptionId $SubscriptionId

pwsh shared/scripts/pwsh/validation/network-compliance-report.ps1 `
  -SubscriptionId $SubscriptionId
```

Expected outputs:

- `network-compliance-report.csv`
- `network-compliance-report.json`

## Step 2 - Execute CLI Report

```bash
SUB_ID="<subscription-id>"
az account set --subscription "$SUB_ID"

chmod +x shared/scripts/cli/validation/network-compliance-report.sh
shared/scripts/cli/validation/network-compliance-report.sh "$SUB_ID"
```

Expected outputs:

- `network-compliance-report-cli.csv`
- `network-compliance-report-cli.json`

## Step 3 - Validate Output Quality

Check that each report includes:

- VNet name, resource group, and address space
- Per-subnet NSG association status (compliant / non-compliant / exempt)
- Network Watcher status per region
- Overlapping address space check result
- Overall compliance verdict per VNet

Quick checks:

```bash
head -n 5 network-compliance-report.csv
jq '.[0]' network-compliance-report.json
```

## Step 4 - Reconcile Differences Between CLI and PowerShell Reports

Create `report-diff-summary.md` describing:

1. Count of VNets and subnets scanned by each script
2. Count of non-compliant subnets in each output
3. Any differences in exempt subnet handling
4. Final source of truth and reason

## Step 5 - Create Remediation Plan

Create `remediation-plan.md` with:

- Top 3 non-compliant subnets by risk
- Specific controls to fix
- Owner assignment
- Due date
- Verification commands

Example remediation commands:

```bash
RG="<resource-group>"
VNET="<vnet-name>"
SUBNET="<subnet-name>"
NSG="<nsg-name>"

az network vnet subnet update \
  --resource-group "$RG" \
  --vnet-name "$VNET" \
  --name "$SUBNET" \
  --network-security-group "$NSG"
```

```powershell
$vnet   = Get-AzVirtualNetwork -ResourceGroupName "<rg>" -Name "<vnet>"
$nsg    = Get-AzNetworkSecurityGroup -ResourceGroupName "<rg>" -Name "<nsg>"
$subnet = $vnet.Subnets | Where-Object Name -eq "<subnet>"
$subnet.NetworkSecurityGroup = $nsg
Set-AzVirtualNetwork -VirtualNetwork $vnet | Out-Null
```

## Acceptance Criteria

- Both reports generated and non-empty
- At least one non-compliant subnet correctly flagged
- Network Watcher status checked for all VNet regions
- Reconciliation table complete
- Remediation plan includes at least one specific subnet with commands

## Required Deliverables

- `network-compliance-report.csv`
- `network-compliance-report.json`
- `network-compliance-report-cli.csv`
- `network-compliance-report-cli.json`
- `report-diff-summary.md`
- `remediation-plan.md`

## Troubleshooting

- Empty report: verify subscription context; confirm Reader + Network Contributor access
- GatewaySubnet falsely flagged as non-compliant: report script should include exemption list; update script if missing
- Network Watcher status unknown: run `az network watcher list -o table` to check all registered watchers
- Overlapping CIDR check inconclusive: script requires all VNet address prefixes in scope; ensure cross-subscription VNets are included if peered
