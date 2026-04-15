# Beginner Lab 02 - Alert Rules and Action Groups

Goal: configure a reusable action group and attach it to a metric alert so monitoring notifications are operational.

## Variables

### Azure CLI
```bash
SUB_ID="<subscription-id>"
RG_NAME="rg-az104-monitor-dev-eastus2-01"
LOCATION="eastus2"
ACTION_GROUP_NAME="ag-az104-ops-dev-01"
ALERT_RULE_NAME="cpu-high-vm-alert"
TARGET_RESOURCE_ID="<vm-resource-id>"
EMAIL_RECEIVER="ops-team@example.com"
```

### PowerShell
```powershell
$SubscriptionId = "<subscription-id>"
$ResourceGroupName = "rg-az104-monitor-dev-eastus2-01"
$Location = "eastus2"
$ActionGroupName = "ag-az104-ops-dev-01"
$AlertRuleName = "cpu-high-vm-alert"
$TargetResourceId = "<vm-resource-id>"
$EmailReceiver = "ops-team@example.com"
```

## Task 1 - Create resource group and action group

```bash
az account set --subscription "$SUB_ID"
az group create --name "$RG_NAME" --location "$LOCATION"

az monitor action-group create \
  --name "$ACTION_GROUP_NAME" \
  --resource-group "$RG_NAME" \
  --short-name "azops" \
  --action email ops "$EMAIL_RECEIVER"
```

## Task 2 - Create metric alert rule

```bash
ACTION_GROUP_ID=$(az monitor action-group show -g "$RG_NAME" -n "$ACTION_GROUP_NAME" --query id -o tsv)

az monitor metrics alert create \
  --name "$ALERT_RULE_NAME" \
  --resource-group "$RG_NAME" \
  --scopes "$TARGET_RESOURCE_ID" \
  --condition "avg Percentage CPU > 80" \
  --description "Alert when VM CPU is high" \
  --evaluation-frequency 5m \
  --window-size 15m \
  --severity 2 \
  --action "$ACTION_GROUP_ID"
```

## Task 3 - Verify rule wiring

```bash
az monitor action-group show -g "$RG_NAME" -n "$ACTION_GROUP_NAME" -o table
az monitor metrics alert show -g "$RG_NAME" -n "$ALERT_RULE_NAME" -o json
```

## Validation
```powershell
pwsh -File learning-paths/lp05-monitor-backup/modules/m02-alerting-and-log-analytics/validation/validate.ps1 -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ActionGroupName $ActionGroupName
```
