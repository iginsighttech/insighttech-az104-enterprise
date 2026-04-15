# Beginner Lab 01 — VNet Foundations

**Track:** Beginner
**Learning Path:** LP04 — Configure and manage virtual networking
**Module Coverage:** M01 — Virtual Network Foundations
**Estimated Time:** 40 minutes

## Goal

Create a virtual network with two subnets and confirm that address space, subnet CIDRs, and resource tags are correctly configured.

---

## Variables

Set these at the start of your session and reference them throughout every task.

Bash / Azure CLI:

```bash
SUBSCRIPTION_ID="<your-subscription-id>"
LOCATION="eastus2"
RG_NAME="rg-az104-netfound-dev-eastus2-01"
VNET_NAME="vnet-az104-netfound-dev-eastus2-01"
VNET_PREFIX="10.10.0.0/16"
SNET_APP="snet-app-dev-eastus2-01"
SNET_APP_PREFIX="10.10.1.0/24"
SNET_DATA="snet-data-dev-eastus2-01"
SNET_DATA_PREFIX="10.10.2.0/24"
```

PowerShell:

```powershell
$SubscriptionId    = "<your-subscription-id>"
$Location          = "eastus2"
$ResourceGroupName = "rg-az104-netfound-dev-eastus2-01"
$VnetName          = "vnet-az104-netfound-dev-eastus2-01"
$VnetPrefix        = "10.10.0.0/16"
$SnetApp           = "snet-app-dev-eastus2-01"
$SnetAppPrefix     = "10.10.1.0/24"
$SnetData          = "snet-data-dev-eastus2-01"
$SnetDataPrefix    = "10.10.2.0/24"
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

## Task 3 — Create the virtual network with an app subnet

Azure CLI:

```bash
az network vnet create \
  --resource-group "$RG_NAME" \
  --name "$VNET_NAME" \
  --address-prefix "$VNET_PREFIX" \
  --subnet-name "$SNET_APP" \
  --subnet-prefix "$SNET_APP_PREFIX" \
  --output table
```

PowerShell:

```powershell
$appSubnet = New-AzVirtualNetworkSubnetConfig `
  -Name $SnetApp `
  -AddressPrefix $SnetAppPrefix

New-AzVirtualNetwork `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -Name $VnetName `
  -AddressPrefix $VnetPrefix `
  -Subnet $appSubnet
```

---

## Task 4 — Add the data subnet

Azure CLI:

```bash
az network vnet subnet create \
  --resource-group "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --name "$SNET_DATA" \
  --address-prefix "$SNET_DATA_PREFIX"
```

PowerShell:

```powershell
$vnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName
Add-AzVirtualNetworkSubnetConfig `
  -VirtualNetwork $vnet `
  -Name $SnetData `
  -AddressPrefix $SnetDataPrefix |
Set-AzVirtualNetwork
```

---

## Task 5 — Verify address space and subnet list

Azure CLI:

```bash
az network vnet show \
  --resource-group "$RG_NAME" \
  --name "$VNET_NAME" \
  --query "{addressSpace:addressSpace.addressPrefixes, subnets:subnets[].{name:name,prefix:addressPrefix}}" \
  -o json
```

Confirm the output shows address prefix `10.10.0.0/16` and both subnets listed with their correct CIDRs.

PowerShell:

```powershell
Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName |
  Select-Object Name, @{N='AddressSpace';E={$_.AddressSpace.AddressPrefixes}} -ExpandProperty Subnets |
  Select-Object Name, AddressPrefix
```

---

## Task 6 — Run validation (required)

```powershell
pwsh learning-paths/lp04-virtual-networks/modules/m01-vnet-foundations/validation/validate.ps1 `
  -VnetName $VnetName
```

A passing result confirms the VNet exists with the correct address space and both subnets are configured.

---

## Clean-up (optional)

```bash
az group delete --name "$RG_NAME" --yes --no-wait
```
