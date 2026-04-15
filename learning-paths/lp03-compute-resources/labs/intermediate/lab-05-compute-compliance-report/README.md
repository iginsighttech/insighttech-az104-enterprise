# Intermediate Lab 05 - Compute Compliance Reporting

## Time Estimate

- 45 to 75 minutes

## Prerequisites

- At least two virtual machines in the subscription
- One VM intentionally misconfigured (unmanaged disk, or no patch mode set, or public IP attached)
- Bash and PowerShell available

## Objective

Generate an audit-friendly compute compliance report that verifies each VM meets platform security and operational standards.

## Required Compute Controls

- OS disk is a managed disk (`storageProfile.osDisk.managedDisk` present)
- All data disks are managed disks
- Patch mode is set to `AutomaticByPlatform` or `AutomaticByOS` (not `Manual`)
- Boot diagnostics enabled
- No direct public IP on NIC (traffic must route through load balancer or Bastion)

## Tasks

1. Run PowerShell report: `shared/scripts/pwsh/validation/compute-compliance-report.ps1`
2. Run CLI report: `shared/scripts/cli/validation/compute-compliance-report.sh`
3. Cross-check outputs and attach CSV + JSON to PR evidence

## Step 1 - Execute PowerShell Report

```powershell
$SubscriptionId = "<subscription-id>"
Select-AzSubscription -SubscriptionId $SubscriptionId

pwsh shared/scripts/pwsh/validation/compute-compliance-report.ps1 `
  -SubscriptionId $SubscriptionId
```

Expected outputs:

- `compute-compliance-report.csv`
- `compute-compliance-report.json`

## Step 2 - Execute CLI Report

```bash
SUB_ID="<subscription-id>"
az account set --subscription "$SUB_ID"

chmod +x shared/scripts/cli/validation/compute-compliance-report.sh
shared/scripts/cli/validation/compute-compliance-report.sh "$SUB_ID"
```

Expected outputs:

- `compute-compliance-report-cli.csv`
- `compute-compliance-report-cli.json`

## Step 3 - Validate Output Quality

Check that each report includes:

- VM name and resource group
- Managed disk status for OS and data disks
- Patch mode setting
- Boot diagnostics status
- Public IP presence on any NIC
- Overall compliance verdict

Quick checks:

```bash
head -n 5 compute-compliance-report.csv
jq '.[0]' compute-compliance-report.json
```

## Step 4 - Reconcile Differences Between CLI and PowerShell Reports

Create `report-diff-summary.md` describing:

1. Count of VMs scanned by each script
2. Count of non-compliant VMs in each output
3. Any differences in which controls were evaluated
4. Final source of truth and reason

## Step 5 - Create Remediation Plan

Create `remediation-plan.md` with:

- Top 3 non-compliant VMs by risk
- Specific controls to fix
- Owner assignment
- Due date
- Verification commands

Example remediation commands:

```bash
VM_NAME="<vm-name>"
RG="<resource-group>"

# Enable boot diagnostics
az vm boot-diagnostics enable --name "$VM_NAME" --resource-group "$RG"

# Set patch mode
az vm update \
  --name "$VM_NAME" \
  --resource-group "$RG" \
  --set osProfile.linuxConfiguration.patchSettings.patchMode=AutomaticByPlatform
```

```powershell
# Enable boot diagnostics
$vm = Get-AzVM -ResourceGroupName "<rg>" -Name "<vm>"
Set-AzVMBootDiagnostic -VM $vm -Enable | Out-Null
Update-AzVM -ResourceGroupName "<rg>" -VM $vm
```

## Acceptance Criteria

- Both reports generated and non-empty
- At least one non-compliant VM correctly flagged
- Reconciliation table complete
- Remediation plan includes at least one specific VM with commands

## Required Deliverables

- `compute-compliance-report.csv`
- `compute-compliance-report.json`
- `compute-compliance-report-cli.csv`
- `compute-compliance-report-cli.json`
- `report-diff-summary.md`
- `remediation-plan.md`

## Troubleshooting

- Empty report: verify subscription context; confirm Reader access to VMs in scope
- Permission denied running CLI script: `chmod +x` before running
- Patch mode field empty in report: guest agent may not be installed; add note to remediation plan
- Unmanaged disk check false positive: use `az vm show` and inspect `storageProfile.osDisk.vhd`; if present, disk is unmanaged
