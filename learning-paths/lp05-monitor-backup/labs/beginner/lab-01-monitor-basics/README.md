# Beginner Lab 01 — Monitor Foundations

**Track:** Beginner
**Learning Path:** LP05 — Monitor and back up Azure resources
**Module Coverage:** M01 — Monitor Foundations
**Estimated Time:** 40 minutes

## Goal

Create a Log Analytics workspace, enable subscription-level activity log collection, and verify that diagnostic settings are routing data to the workspace.

---

## Variables

Set these at the start of your session and reference them throughout every task.

Bash / Azure CLI:

```bash
SUBSCRIPTION_ID="<your-subscription-id>"
LOCATION="eastus2"
RG_NAME="rg-az104-monitor-dev-eastus2-01"
WORKSPACE_NAME="law-az104-monitor-dev-01"
SKU="PerGB2018"
RETENTION_DAYS=30
DIAG_SETTING_NAME="diag-activity-to-law"
```

PowerShell:

```powershell
$SubscriptionId    = "<your-subscription-id>"
$Location          = "eastus2"
$ResourceGroupName = "rg-az104-monitor-dev-eastus2-01"
$WorkspaceName     = "law-az104-monitor-dev-01"
$Sku               = "PerGB2018"
$RetentionDays     = 30
$DiagSettingName   = "diag-activity-to-law"
```

---

## Task 1 — Set subscription context

Azure CLI:

```bash
az account set --subscription "$SUBSCRIPTION_ID"
az account show --query "{name:name, id:id}" -o table
```

PowerShell:

```powershell
Set-AzContext -SubscriptionId $SubscriptionId
Get-AzContext | Select-Object Name, Subscription
```

---

## Task 2 — Create the resource group with required tags

Azure CLI:

```bash
az group create \
  --name "$RG_NAME" \
  --location "$LOCATION" \
  --tags env=dev project=az104 owner=labuser
```

PowerShell:

```powershell
New-AzResourceGroup `
  -Name $ResourceGroupName `
  -Location $Location `
  -Tag @{ env = "dev"; project = "az104"; owner = "labuser" }
```

Verify:

```bash
az group show --name "$RG_NAME" --query "tags" -o json
```

---

## Task 3 — Create the Log Analytics workspace

Azure CLI:

```bash
az monitor log-analytics workspace create \
  --resource-group "$RG_NAME" \
  --workspace-name "$WORKSPACE_NAME" \
  --location "$LOCATION" \
  --sku "$SKU" \
  --retention-time "$RETENTION_DAYS" \
  --output table
```

PowerShell:

```powershell
New-AzOperationalInsightsWorkspace `
  -ResourceGroupName $ResourceGroupName `
  -Name $WorkspaceName `
  -Location $Location `
  -Sku $Sku `
  -RetentionInDays $RetentionDays
```

---

## Task 4 — Route subscription activity logs to the workspace

Azure CLI:

```bash
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group "$RG_NAME" \
  --workspace-name "$WORKSPACE_NAME" \
  --query id -o tsv)

az monitor diagnostic-settings create \
  --name "$DIAG_SETTING_NAME" \
  --resource "/subscriptions/$SUBSCRIPTION_ID" \
  --workspace "$WORKSPACE_ID" \
  --logs '[{"category":"Administrative","enabled":true},{"category":"Security","enabled":true},{"category":"Policy","enabled":true}]'
```

PowerShell:

```powershell
$workspace = Get-AzOperationalInsightsWorkspace `
  -ResourceGroupName $ResourceGroupName `
  -Name $WorkspaceName

$logCategories = @(
  New-AzDiagnosticSettingLogSettingsObject -Category Administrative -Enabled $true
  New-AzDiagnosticSettingLogSettingsObject -Category Security       -Enabled $true
  New-AzDiagnosticSettingLogSettingsObject -Category Policy         -Enabled $true
)

New-AzDiagnosticSetting `
  -Name $DiagSettingName `
  -ResourceId "/subscriptions/$SubscriptionId" `
  -WorkspaceId $workspace.ResourceId `
  -Log $logCategories
```

---

## Task 5 — Verify workspace properties and diagnostic routing

Azure CLI:

```bash
az monitor log-analytics workspace show \
  --resource-group "$RG_NAME" \
  --workspace-name "$WORKSPACE_NAME" \
  --query "{name:name, sku:sku.name, retentionDays:retentionInDays, provisioningState:provisioningState}" \
  -o table
```

Confirm `sku` is `PerGB2018`, `retentionDays` is `30`, and `provisioningState` is `Succeeded`.

```bash
az monitor diagnostic-settings list \
  --resource "/subscriptions/$SUBSCRIPTION_ID" \
  --query "[].{name:name, workspace:workspaceId}" \
  -o table
```

---

## Task 6 — Run validation (required)

```powershell
pwsh learning-paths/lp05-monitor-backup/modules/m01-monitor-foundations/validation/validate.ps1 `
  -LogAnalyticsWorkspaceName $WorkspaceName
```

A passing result confirms the workspace exists with the correct SKU, retention period, and activity log diagnostic settings.

---

## Clean-up (optional)

```bash
az group delete --name "$RG_NAME" --yes --no-wait
```
