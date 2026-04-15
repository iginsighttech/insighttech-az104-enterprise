# Intermediate Lab 05 - Monitoring Compliance Reporting

## Time Estimate

- 45 to 75 minutes

## Prerequisites

- At least two resources in the subscription (VMs, storage accounts, or key vaults)
- One resource intentionally missing diagnostic settings or alert coverage
- A Log Analytics workspace deployed
- Bash and PowerShell available

## Objective

Generate an audit-friendly monitoring compliance report that verifies each resource meets platform observability standards.

## Required Monitoring Controls

- Diagnostic settings configured and targeting the designated Log Analytics workspace
- At least one alert rule covering Severity 0 or Severity 1 for each critical resource
- Backup policy applied to all VMs tagged with `DataClass=sensitive` or `DataClass=confidential`
- Log Analytics agent or Azure Monitor Agent installed and reporting heartbeat within 24 hours
- Action group assigned to all active alert rules

## Tasks

1. Run PowerShell report: `shared/scripts/pwsh/validation/monitoring-compliance-report.ps1`
2. Run CLI report: `shared/scripts/cli/validation/monitoring-compliance-report.sh`
3. Cross-check outputs and attach CSV + JSON to PR evidence

## Step 1 - Execute PowerShell Report

```powershell
$SubscriptionId = "<subscription-id>"
Select-AzSubscription -SubscriptionId $SubscriptionId

pwsh shared/scripts/pwsh/validation/monitoring-compliance-report.ps1 `
  -SubscriptionId $SubscriptionId
```

Expected outputs:

- `monitoring-compliance-report.csv`
- `monitoring-compliance-report.json`

## Step 2 - Execute CLI Report

```bash
SUB_ID="<subscription-id>"
az account set --subscription "$SUB_ID"

chmod +x shared/scripts/cli/validation/monitoring-compliance-report.sh
shared/scripts/cli/validation/monitoring-compliance-report.sh "$SUB_ID"
```

Expected outputs:

- `monitoring-compliance-report-cli.csv`
- `monitoring-compliance-report-cli.json`

## Step 3 - Validate Output Quality

Check that each report includes:

- Resource name, type, and resource group
- Diagnostic settings status and target workspace
- Alert rule coverage (Sev0/Sev1 present: yes/no)
- Action group assignment status
- Agent heartbeat status (within 24 hours: yes/no/N/A)
- Backup policy status for VMs with sensitive data tags
- Overall compliance verdict per resource

Quick checks:

```bash
head -n 5 monitoring-compliance-report.csv
jq '.[0]' monitoring-compliance-report.json
```

## Step 4 - Reconcile Differences Between CLI and PowerShell Reports

Create `report-diff-summary.md` describing:

1. Count of resources scanned by each script
2. Count of non-compliant resources in each output
3. Any differences in alert coverage evaluation
4. Final source of truth and reason

## Step 5 - Create Remediation Plan

Create `remediation-plan.md` with:

- Top 3 non-compliant resources by risk
- Specific controls to fix
- Owner assignment
- Due date
- Verification commands

Example remediation commands:

```bash
RESOURCE_ID="<resource-id>"
WORKSPACE_NAME="<workspace-name>"
RG="<resource-group>"

# Create missing diagnostic settings
az monitor diagnostic-settings create \
  --name "diag-to-law" \
  --resource "$RESOURCE_ID" \
  --workspace "$WORKSPACE_NAME" \
  --resource-group "$RG" \
  --logs '[{"category":"AuditEvent","enabled":true}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]'
```

```powershell
# List resources with no diagnostic settings (quick check)
$resources = Get-AzResource
foreach ($r in $resources) {
  $diag = Get-AzDiagnosticSetting -ResourceId $r.ResourceId -ErrorAction SilentlyContinue
  if (-not $diag) { Write-Output "No diag: $($r.Name)" }
}
```

## Acceptance Criteria

- Both reports generated and non-empty
- At least one non-compliant resource correctly flagged
- All critical VMs checked for backup policy
- Reconciliation table complete
- Remediation plan includes at least one specific resource with commands

## Required Deliverables

- `monitoring-compliance-report.csv`
- `monitoring-compliance-report.json`
- `monitoring-compliance-report-cli.csv`
- `monitoring-compliance-report-cli.json`
- `report-diff-summary.md`
- `remediation-plan.md`

## Troubleshooting

- Empty report: verify subscription context; confirm Monitoring Reader access
- Diagnostic settings API returns empty for some resource types: not all resource types support all log categories; check supported categories with `az monitor diagnostic-settings categories list --resource "$RESOURCE_ID"`
- Agent heartbeat absent but agent appears installed: confirm the agent is pointing to the correct workspace; check MMA / AMA workspace configuration
- Backup status unknown: confirm Recovery Services vault exists and VM is registered; run `az backup item list --vault-name <vault> --resource-group <rg> -o table`
