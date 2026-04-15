# Beginner Lab 03 — Load Balancing and DNS

**Track:** Beginner
**Learning Path:** LP04 — Configure and manage virtual networking
**Module Coverage:** M03 — Load Balancing and Name Resolution
**Estimated Time:** 50 minutes

## Goal

Deploy a public Azure Load Balancer with a frontend IP, backend pool, health probe, and load-balancing rule. Verify that the load balancer is provisioned and configured correctly.

---

## Variables

Set these at the start of your session and reference them throughout every task.

Bash / Azure CLI:

```bash
SUBSCRIPTION_ID="<your-subscription-id>"
LOCATION="eastus2"
RG_NAME="rg-az104-netlb-dev-eastus2-01"
LB_NAME="lb-az104-netlb-dev-eastus2-01"
PIP_NAME="pip-lb-az104-netlb-dev-eastus2-01"
FRONTEND_IP_CONFIG="lb-frontend-dev"
BACKEND_POOL="lb-backend-pool-dev"
HEALTH_PROBE="lb-probe-http-dev"
LB_RULE="lb-rule-http-dev"
```

PowerShell:

```powershell
$SubscriptionId    = "<your-subscription-id>"
$Location          = "eastus2"
$ResourceGroupName = "rg-az104-netlb-dev-eastus2-01"
$LbName            = "lb-az104-netlb-dev-eastus2-01"
$PipName           = "pip-lb-az104-netlb-dev-eastus2-01"
$FrontendCfg       = "lb-frontend-dev"
$BackendPool       = "lb-backend-pool-dev"
$HealthProbe       = "lb-probe-http-dev"
$LbRule            = "lb-rule-http-dev"
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

## Task 3 — Create a public IP address for the load balancer frontend

Azure CLI:

```bash
az network public-ip create \
  --resource-group "$RG_NAME" \
  --name "$PIP_NAME" \
  --sku Standard \
  --allocation-method Static \
  --location "$LOCATION" \
  --output table
```

PowerShell:

```powershell
New-AzPublicIpAddress `
  -ResourceGroupName $ResourceGroupName `
  -Name $PipName `
  -Location $Location `
  -Sku Standard `
  -AllocationMethod Static
```

---

## Task 4 — Create the load balancer with frontend, backend pool, probe, and rule

Azure CLI:

```bash
az network lb create \
  --resource-group "$RG_NAME" \
  --name "$LB_NAME" \
  --sku Standard \
  --frontend-ip-name "$FRONTEND_IP_CONFIG" \
  --public-ip-address "$PIP_NAME" \
  --backend-pool-name "$BACKEND_POOL" \
  --output table

az network lb probe create \
  --resource-group "$RG_NAME" \
  --lb-name "$LB_NAME" \
  --name "$HEALTH_PROBE" \
  --protocol Http \
  --port 80 \
  --path "/" \
  --interval 15 \
  --threshold 2

az network lb rule create \
  --resource-group "$RG_NAME" \
  --lb-name "$LB_NAME" \
  --name "$LB_RULE" \
  --protocol Tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name "$FRONTEND_IP_CONFIG" \
  --backend-pool-name "$BACKEND_POOL" \
  --probe-name "$HEALTH_PROBE" \
  --output table
```

PowerShell:

```powershell
$pip = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $PipName

$frontend = New-AzLoadBalancerFrontendIpConfig `
  -Name $FrontendCfg `
  -PublicIpAddress $pip

$backendPool = New-AzLoadBalancerBackendAddressPoolConfig `
  -Name $BackendPool

$probe = New-AzLoadBalancerProbeConfig `
  -Name $HealthProbe `
  -Protocol Http `
  -Port 80 `
  -RequestPath "/" `
  -IntervalInSeconds 15 `
  -ProbeCount 2

$rule = New-AzLoadBalancerRuleConfig `
  -Name $LbRule `
  -FrontendIPConfiguration $frontend `
  -BackendAddressPool $backendPool `
  -Probe $probe `
  -Protocol Tcp `
  -FrontendPort 80 `
  -BackendPort 80

New-AzLoadBalancer `
  -ResourceGroupName $ResourceGroupName `
  -Name $LbName `
  -Location $Location `
  -Sku Standard `
  -FrontendIpConfiguration $frontend `
  -BackendAddressPool $backendPool `
  -Probe $probe `
  -LoadBalancingRule $rule
```

---

## Task 5 — Verify the load balancer configuration

Azure CLI:

```bash
az network lb show \
  --resource-group "$RG_NAME" \
  --name "$LB_NAME" \
  --query "{name:name, sku:sku.name, frontends:frontendIpConfigurations[].name, backends:backendAddressPools[].name, probes:probes[].name, rules:loadBalancingRules[].name}" \
  -o json
```

Confirm the SKU is `Standard` and that the frontend, backend pool, health probe, and rule all appear.

PowerShell:

```powershell
Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName -Name $LbName |
  Select-Object Name, Sku, @{N='Probes';E={$_.Probes.Name}}, @{N='Rules';E={$_.LoadBalancingRules.Name}}
```

---

## Task 6 — Run validation (required)

```powershell
pwsh learning-paths/lp04-virtual-networks/modules/m03-load-balancing-and-name-resolution/validation/validate.ps1 `
  -LoadBalancerName $LbName
```

A passing result confirms the load balancer exists with a Standard SKU, a configured health probe, and at least one load-balancing rule.

---

## Clean-up (optional)

```bash
az group delete --name "$RG_NAME" --yes --no-wait
```
