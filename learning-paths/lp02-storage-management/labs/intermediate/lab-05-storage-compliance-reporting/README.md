# Intermediate Lab 05 - Storage Compliance Reporting

## Time Estimate

- 45 to 75 minutes

## Prerequisites

- At least two storage accounts in the subscription
- One storage account intentionally misconfigured (HTTP-only disabled, or public blob access enabled, or TLS below 1.2)
- Bash and PowerShell available

## Objective

Generate an audit-friendly storage compliance report that verifies each account meets platform security standards.

## Required Storage Controls

- HTTPS-only traffic enforced (`supportsHttpsTrafficOnly = true`)
- Minimum TLS version: TLS1_2
- Public blob access disabled (`allowBlobPublicAccess = false`)
- Soft delete for blobs enabled with retention >= 7 days
- Soft delete for containers enabled

## Tasks

1. Run PowerShell report: `shared/scripts/pwsh/validation/storage-compliance-report.ps1`
2. Run CLI report: `shared/scripts/cli/validation/storage-compliance-report.sh`
3. Cross-check outputs and attach CSV + JSON to PR evidence

## Step 1 - Execute PowerShell Report

```powershell
$SubscriptionId = "<subscription-id>"
Select-AzSubscription -SubscriptionId $SubscriptionId

pwsh shared/scripts/pwsh/validation/storage-compliance-report.ps1 `
  -SubscriptionId $SubscriptionId
```

Expected outputs:

- `storage-compliance-report.csv`
- `storage-compliance-report.json`

## Step 2 - Execute CLI Report

```bash
SUB_ID="<subscription-id>"
az account set --subscription "$SUB_ID"

chmod +x shared/scripts/cli/validation/storage-compliance-report.sh
shared/scripts/cli/validation/storage-compliance-report.sh "$SUB_ID"
```

Expected outputs:

- `storage-compliance-report-cli.csv`
- `storage-compliance-report-cli.json`

## Step 3 - Validate Output Quality

Check that each report includes:

- Storage account name and resource group
- HTTPS-only status (compliant / non-compliant)
- Minimum TLS version
- Public access status
- Blob soft delete status and retention days
- Container soft delete status
- Overall compliance verdict

Quick checks:

```bash
head -n 5 storage-compliance-report.csv
jq '.[0]' storage-compliance-report.json
```

## Step 4 - Reconcile Differences Between CLI and PowerShell Reports

Create `report-diff-summary.md` describing:

1. Count of storage accounts scanned by each script
2. Count of non-compliant accounts in each output
3. Any differences in which controls were evaluated
4. Final source of truth and reason

## Step 5 - Create Remediation Plan

Create `remediation-plan.md` with:

- Top 3 non-compliant accounts by risk
- Specific controls to fix
- Owner assignment
- Due date
- Verification commands

Example remediation commands:

```bash
STORAGE_ACCOUNT="<account-name>"
RG="<resource-group>"

az storage account update \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RG" \
  --min-tls-version TLS1_2 \
  --https-only true \
  --allow-blob-public-access false
```

```powershell
Update-AzStorageAccount `
  -ResourceGroupName "<rg>" `
  -Name "<account>" `
  -MinimumTlsVersion TLS1_2 `
  -EnableHttpsTrafficOnly $true `
  -AllowBlobPublicAccess $false
```

## Acceptance Criteria

- Both reports generated and non-empty
- At least one non-compliant account correctly flagged
- Reconciliation table complete
- Remediation plan includes at least one specific account with commands

## Required Deliverables

- `storage-compliance-report.csv`
- `storage-compliance-report.json`
- `storage-compliance-report-cli.csv`
- `storage-compliance-report-cli.json`
- `report-diff-summary.md`
- `remediation-plan.md`

## Troubleshooting

- Empty report: verify subscription context; confirm you have Reader access to storage accounts in scope
- Permission denied running CLI script: `chmod +x` the script before running
- `jq` not installed: install via `sudo apt install jq` (Ubuntu) or `brew install jq` (macOS)
- Soft delete controls not visible: confirm account kind is StorageV2; page blob accounts do not support container soft delete
