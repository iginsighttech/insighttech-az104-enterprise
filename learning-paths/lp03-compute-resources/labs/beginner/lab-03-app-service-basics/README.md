# Beginner Lab 03 — App Service Basics

**Track:** Beginner
**Learning Path:** LP03 — Deploy and manage Azure compute resources
**Module Coverage:** M03 — App Service and Container Services
**Estimated Time:** 45 minutes

## Goal

Create an App Service plan and deploy a web app. Configure application settings and verify the app is reachable at its default hostname.

---

## Variables

Set these at the start of your session and reference them throughout every task.

Bash / Azure CLI:

```bash
SUBSCRIPTION_ID="<your-subscription-id>"
LOCATION="eastus2"
RG_NAME="rg-az104-compute-dev-eastus2-01"
PLAN_NAME="asp-az104-compute-dev-01"
PLAN_SKU="B1"
WEBAPP_NAME="app-az104-compute-dev-01"
RUNTIME="python|3.11"
```

PowerShell:

```powershell
$SubscriptionId    = "<your-subscription-id>"
$Location          = "eastus2"
$ResourceGroupName = "rg-az104-compute-dev-eastus2-01"
$PlanName          = "asp-az104-compute-dev-01"
$PlanSku           = "B1"
$WebAppName        = "app-az104-compute-dev-01"
$Runtime           = "python|3.11"
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

## Task 3 — Create the App Service plan

Azure CLI:

```bash
az appservice plan create \
  --resource-group "$RG_NAME" \
  --name "$PLAN_NAME" \
  --location "$LOCATION" \
  --sku "$PLAN_SKU" \
  --is-linux \
  --output table
```

PowerShell:

```powershell
New-AzAppServicePlan `
  -ResourceGroupName $ResourceGroupName `
  -Name $PlanName `
  -Location $Location `
  -Tier Basic `
  -WorkerSize Small `
  -Linux
```

---

## Task 4 — Deploy a web app on the plan

Azure CLI:

```bash
az webapp create \
  --resource-group "$RG_NAME" \
  --plan "$PLAN_NAME" \
  --name "$WEBAPP_NAME" \
  --runtime "$RUNTIME" \
  --output table
```

PowerShell:

```powershell
New-AzWebApp `
  -ResourceGroupName $ResourceGroupName `
  -AppServicePlan $PlanName `
  -Name $WebAppName `
  -Location $Location
```

---

## Task 5 — Configure an application setting

Application settings are exposed as environment variables to the app runtime. Add a lab-specific setting to confirm the configuration pipeline works.

Azure CLI:

```bash
az webapp config appsettings set \
  --resource-group "$RG_NAME" \
  --name "$WEBAPP_NAME" \
  --settings LAB_ENV="beginner" PROJECT="az104" \
  --output table
```

PowerShell:

```powershell
$settings = @{ LAB_ENV = "beginner"; PROJECT = "az104" }
Set-AzWebApp `
  -ResourceGroupName $ResourceGroupName `
  -Name $WebAppName `
  -AppSettings $settings
```

---

## Task 6 — Verify the web app default hostname

Azure CLI:

```bash
az webapp show \
  --resource-group "$RG_NAME" \
  --name "$WEBAPP_NAME" \
  --query "{name:name, state:state, defaultHostName:defaultHostName}" \
  -o table
```

Confirm `state` is `Running` and note the `defaultHostName`. Open the URL in a browser to see the default Azure App Service welcome page.

PowerShell:

```powershell
Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName |
  Select-Object Name, State, DefaultHostName
```

---

## Task 7 — Run validation (required)

```powershell
pwsh learning-paths/lp03-compute-resources/modules/m03-app-service-and-container-services/validation/validate.ps1 `
  -AppServicePlanName $PlanName `
  -WebAppName $WebAppName
```

A passing result confirms the App Service plan and web app exist with the correct SKU and runtime configuration.

---

## Clean-up (optional)

```bash
az group delete --name "$RG_NAME" --yes --no-wait
```
