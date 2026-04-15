# Intermediate Lab 01 - Log Analytics Operations Runbook

## Purpose

This lab converts M01 monitoring foundations into repeatable operational work. You will query a Log Analytics workspace with KQL, validate agent heartbeat coverage, and verify diagnostic settings using both CLI and PowerShell.

## Time Estimate

- 60 to 90 minutes

## Prerequisites

- Completed beginner Lab 01
- Non-production subscription access
- Monitoring Contributor or Log Analytics Contributor role on target resource group
- Azure CLI and PowerShell Az installed
- At least one VM or resource emitting logs to the workspace

## Scenario

The platform team must demonstrate that the Log Analytics workspace can answer operational questions about infrastructure health. You must:

1. Create and tag a monitoring resource group
2. Create or validate a Log Analytics workspace
3. Run heartbeat, performance, and event queries
4. Validate diagnostic settings on a resource
5. Produce evidence for audit and handoff

## Variables

```bash
SUB_ID="<subscription-id>"
LOCATION="eastus2"
RG_NAME="rg-az104-monops-dev-eastus2-01"
WORKSPACE_NAME="law-az104-monops-dev-01"
```

```powershell
$SubscriptionId = "<subscription-id>"
$Location = "eastus2"
$RgName = "rg-az104-monops-dev-eastus2-01"
$WorkspaceName = "law-az104-monops-dev-01"
```

## Task 1 - Set Context and Create Baseline Resource Group

### Azure CLI

```bash
az account set --subscription "$SUB_ID"

az group create \
  --name "$RG_NAME" \
  --location "$LOCATION" \
  --tags Owner="student" CostCenter="IT-104" Environment="dev" Workload="mon-ops" DataClass="internal" ExpirationDate="2026-12-31"
```

### PowerShell

```powershell
Select-AzSubscription -SubscriptionId $SubscriptionId

New-AzResourceGroup `
  -Name $RgName `
  -Location $Location `
  -Tag @{
    Owner          = "student"
    CostCenter     = "IT-104"
    Environment    = "dev"
    Workload       = "mon-ops"
    DataClass      = "internal"
    ExpirationDate = "2026-12-31"
  }
```

## Task 2 - Create or Validate the Log Analytics Workspace

### Azure CLI

```bash
az monitor log-analytics workspace create \
  --resource-group "$RG_NAME" \
  --workspace-name "$WORKSPACE_NAME" \
  --location "$LOCATION" \
  --sku PerGB2018 \
  --retention-time 30

az monitor log-analytics workspace show \
  --resource-group "$RG_NAME" \
  --workspace-name "$WORKSPACE_NAME" \
  --query "{name:name,sku:sku.name,retentionDays:retentionInDays,status:publicNetworkAccessForIngestion}" -o table
```

### PowerShell

```powershell
$workspace = New-AzOperationalInsightsWorkspace `
  -ResourceGroupName $RgName `
  -Name $WorkspaceName `
  -Location $Location `
  -Sku PerGB2018 `
  -RetentionInDays 30

$workspace | Select-Object Name, Sku, RetentionInDays, PublicNetworkAccessForIngestion
```

## Task 3 - Run Heartbeat and Performance KQL Queries

Use the workspace customer ID to run queries via the REST-backed CLI.

### Azure CLI

```bash
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group "$RG_NAME" \
  --workspace-name "$WORKSPACE_NAME" \
  --query customerId -o tsv)

# Heartbeat: agents that reported in the last hour
az monitor log-analytics query \
  --workspace "$WORKSPACE_ID" \
  --analytics-query "Heartbeat | where TimeGenerated > ago(1h) | summarize LastSeen=max(TimeGenerated) by Computer, OSType | order by LastSeen desc" \
  -o table

# CPU performance: average CPU per computer over last hour
az monitor log-analytics query \
  --workspace "$WORKSPACE_ID" \
  --analytics-query "Perf | where TimeGenerated > ago(1h) and ObjectName == 'Processor' and CounterName == '% Processor Time' | summarize AvgCPU=avg(CounterValue) by Computer | order by AvgCPU desc" \
  -o table
```

### PowerShell

```powershell
$workspaceId = (Get-AzOperationalInsightsWorkspace `
  -ResourceGroupName $RgName -Name $WorkspaceName).CustomerId.ToString()

# Heartbeat query
$heartbeatQuery = "Heartbeat | where TimeGenerated > ago(1h) | summarize LastSeen=max(TimeGenerated) by Computer, OSType | order by LastSeen desc"
Invoke-AzOperationalInsightsQuery -WorkspaceId $workspaceId -Query $heartbeatQuery |
  Select-Object -ExpandProperty Results

# CPU performance query
$cpuQuery = "Perf | where TimeGenerated > ago(1h) and ObjectName == 'Processor' and CounterName == '% Processor Time' | summarize AvgCPU=avg(CounterValue) by Computer | order by AvgCPU desc"
Invoke-AzOperationalInsightsQuery -WorkspaceId $workspaceId -Query $cpuQuery |
  Select-Object -ExpandProperty Results
```

## Task 4 - Validate Diagnostic Settings on a Resource

Pick any resource in the subscription (e.g. a storage account or key vault) and confirm that its diagnostic settings point to your workspace.

### Azure CLI

```bash
RESOURCE_ID=$(az storage account list \
  --resource-group "$RG_NAME" \
  --query "[0].id" -o tsv)

az monitor diagnostic-settings list \
  --resource "$RESOURCE_ID" \
  --query "[].{name:name,workspace:workspaceId}" -o table
```

If no diagnostic setting exists, create one:

```bash
az monitor diagnostic-settings create \
  --name "diag-to-law" \
  --resource "$RESOURCE_ID" \
  --workspace "$WORKSPACE_NAME" \
  --resource-group "$RG_NAME" \
  --logs '[{"category":"StorageRead","enabled":true},{"category":"StorageWrite","enabled":true}]' \
  --metrics '[{"category":"Transaction","enabled":true}]'
```

### PowerShell

```powershell
$resource = Get-AzStorageAccount -ResourceGroupName $RgName | Select-Object -First 1
$workspaceResourceId = (Get-AzOperationalInsightsWorkspace `
  -ResourceGroupName $RgName -Name $WorkspaceName).ResourceId

Get-AzDiagnosticSetting -ResourceId $resource.Id |
  Select-Object Name, @{N="Workspace";E={$_.WorkspaceId}}
```

## Task 5 - Produce Evidence Package

Create these files in your branch under this lab folder:

- `evidence-workspace.json` — output of `az monitor log-analytics workspace show`
- `evidence-heartbeat.txt` — heartbeat query results
- `evidence-cpu-perf.txt` — CPU performance query results
- `evidence-diag-settings.txt` — diagnostic settings list for chosen resource
- `ops-notes.md` — short note on:
  - What retention period was chosen and why
  - Which resource was validated for diagnostic settings
  - Whether any agent was absent from heartbeat and what the next step would be

## Acceptance Criteria

- Resource group exists with required tags
- Log Analytics workspace exists with PerGB2018 SKU and 30-day retention
- Heartbeat query runs without error (empty result is acceptable if no agents present)
- CPU performance query runs without error
- At least one diagnostic setting is configured and visible
- Evidence files are complete and readable

## Troubleshooting

### Query returns empty results

- Cause: no agents have connected to the workspace or data has not yet arrived
- Fix: wait 5 to 10 minutes after connecting an agent; verify agent health in the Azure portal Monitor blade

### `az monitor log-analytics query` fails with permission error

- Cause: identity lacks the Log Analytics Reader role on the workspace
- Fix: run `az role assignment create --role "Log Analytics Reader" --scope <workspace-id> --assignee <upn>`

### Diagnostic settings create fails with resource type error

- Cause: not all resource types support all log categories
- Fix: run `az monitor diagnostic-settings categories list --resource "$RESOURCE_ID"` to see supported categories before creating
