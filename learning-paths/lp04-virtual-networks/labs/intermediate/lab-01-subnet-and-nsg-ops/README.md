# Intermediate Lab 01 - Subnet and NSG Operations Runbook

## Purpose

This lab converts M01 virtual network foundations into repeatable operational work. You will manage subnets, associate NSGs, add and remove security rules, and validate effective network security using both CLI and PowerShell.

## Time Estimate

- 60 to 90 minutes

## Prerequisites

- Completed beginner Lab 01
- Non-production subscription access
- Network Contributor or Contributor role on target resource group
- Azure CLI and PowerShell Az installed

## Scenario

The platform team manages virtual networks shared by multiple application teams. You must:

1. Create and tag a network resource group
2. Deploy or validate a VNet with production and management subnets
3. Create an NSG with allow-http, allow-ssh, and deny-all rules
4. Associate the NSG with the production subnet and validate effective rules
5. Produce evidence for audit and handoff

## Variables

```bash
SUB_ID="<subscription-id>"
LOCATION="eastus2"
RG_NAME="rg-az104-netops-dev-eastus2-01"
VNET_NAME="vnet-az104-netops-dev-eastus2-01"
SUBNET_PROD="snet-prod"
SUBNET_MGMT="snet-mgmt"
NSG_NAME="nsg-az104-prod-eastus2-01"
```

```powershell
$SubscriptionId = "<subscription-id>"
$Location = "eastus2"
$RgName = "rg-az104-netops-dev-eastus2-01"
$VnetName = "vnet-az104-netops-dev-eastus2-01"
$SubnetProd = "snet-prod"
$SubnetMgmt = "snet-mgmt"
$NsgName = "nsg-az104-prod-eastus2-01"
```

## Task 1 - Set Context and Create Baseline Resource Group

### Azure CLI

```bash
az account set --subscription "$SUB_ID"

az group create \
  --name "$RG_NAME" \
  --location "$LOCATION" \
  --tags Owner="student" CostCenter="IT-104" Environment="dev" Workload="net-ops" DataClass="internal" ExpirationDate="2026-12-31"
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
    Workload       = "net-ops"
    DataClass      = "internal"
    ExpirationDate = "2026-12-31"
  }
```

## Task 2 - Create or Validate VNet and Subnets

### Azure CLI

```bash
az network vnet create \
  --resource-group "$RG_NAME" \
  --name "$VNET_NAME" \
  --address-prefix 10.10.0.0/16 \
  --location "$LOCATION"

az network vnet subnet create \
  --resource-group "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --name "$SUBNET_PROD" \
  --address-prefix 10.10.1.0/24

az network vnet subnet create \
  --resource-group "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --name "$SUBNET_MGMT" \
  --address-prefix 10.10.2.0/24

az network vnet subnet list \
  --resource-group "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --query "[].{name:name,prefix:addressPrefix,nsg:networkSecurityGroup.id}" -o table
```

### PowerShell

```powershell
$subnetProdConfig = New-AzVirtualNetworkSubnetConfig -Name $SubnetProd -AddressPrefix "10.10.1.0/24"
$subnetMgmtConfig = New-AzVirtualNetworkSubnetConfig -Name $SubnetMgmt -AddressPrefix "10.10.2.0/24"

$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $RgName `
  -Location $Location `
  -Name $VnetName `
  -AddressPrefix "10.10.0.0/16" `
  -Subnet $subnetProdConfig, $subnetMgmtConfig

$vnet.Subnets | Select-Object Name, AddressPrefix, @{N="NSG";E={$_.NetworkSecurityGroup?.Id}}
```

## Task 3 - Create an NSG with Ordered Security Rules

### Azure CLI

```bash
az network nsg create \
  --resource-group "$RG_NAME" \
  --name "$NSG_NAME"

az network nsg rule create \
  --resource-group "$RG_NAME" \
  --nsg-name "$NSG_NAME" \
  --name Allow-HTTP \
  --priority 100 \
  --protocol Tcp \
  --destination-port-range 80 \
  --access Allow \
  --direction Inbound

az network nsg rule create \
  --resource-group "$RG_NAME" \
  --nsg-name "$NSG_NAME" \
  --name Allow-SSH \
  --priority 110 \
  --protocol Tcp \
  --destination-port-range 22 \
  --source-address-prefix "10.10.2.0/24" \
  --access Allow \
  --direction Inbound

az network nsg rule create \
  --resource-group "$RG_NAME" \
  --nsg-name "$NSG_NAME" \
  --name Deny-All-Inbound \
  --priority 4000 \
  --protocol "*" \
  --destination-port-range "*" \
  --access Deny \
  --direction Inbound

az network nsg rule list \
  --resource-group "$RG_NAME" \
  --nsg-name "$NSG_NAME" \
  --query "[].{name:name,priority:priority,access:access,direction:direction,port:destinationPortRange}" -o table
```

### PowerShell

```powershell
$ruleHttp = New-AzNetworkSecurityRuleConfig `
  -Name "Allow-HTTP" -Priority 100 -Protocol Tcp `
  -DestinationPortRange 80 -Access Allow -Direction Inbound `
  -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix *

$ruleSsh = New-AzNetworkSecurityRuleConfig `
  -Name "Allow-SSH" -Priority 110 -Protocol Tcp `
  -DestinationPortRange 22 -Access Allow -Direction Inbound `
  -SourceAddressPrefix "10.10.2.0/24" -SourcePortRange * -DestinationAddressPrefix *

$ruleDeny = New-AzNetworkSecurityRuleConfig `
  -Name "Deny-All-Inbound" -Priority 4000 -Protocol * `
  -DestinationPortRange * -Access Deny -Direction Inbound `
  -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix *

$nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName $RgName `
  -Location $Location `
  -Name $NsgName `
  -SecurityRules $ruleHttp, $ruleSsh, $ruleDeny

$nsg.SecurityRules | Select-Object Name, Priority, Access, Direction, DestinationPortRange
```

## Task 4 - Associate NSG with the Production Subnet and Validate

### Azure CLI

```bash
az network vnet subnet update \
  --resource-group "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --name "$SUBNET_PROD" \
  --network-security-group "$NSG_NAME"

az network vnet subnet show \
  --resource-group "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --name "$SUBNET_PROD" \
  --query "{subnet:name,nsg:networkSecurityGroup.id}" -o table
```

### PowerShell

```powershell
$vnet = Get-AzVirtualNetwork -ResourceGroupName $RgName -Name $VnetName
$nsg  = Get-AzNetworkSecurityGroup -ResourceGroupName $RgName -Name $NsgName

$subnet = $vnet.Subnets | Where-Object Name -eq $SubnetProd
$subnet.NetworkSecurityGroup = $nsg
Set-AzVirtualNetwork -VirtualNetwork $vnet | Out-Null

$vnet = Get-AzVirtualNetwork -ResourceGroupName $RgName -Name $VnetName
$vnet.Subnets | Where-Object Name -eq $SubnetProd |
  Select-Object Name, @{N="NSG";E={$_.NetworkSecurityGroup.Id}}
```

## Task 5 - Produce Evidence Package

Create these files in your branch under this lab folder:

- `evidence-vnet.json` — output of `az network vnet show`
- `evidence-nsg-rules.txt` — NSG rule list (priority-sorted)
- `evidence-subnet-nsg.txt` — subnet show confirming NSG association
- `ops-notes.md` — short note explaining why SSH is restricted to the mgmt subnet CIDR rather than `*`

## Acceptance Criteria

- Resource group exists with required tags
- VNet has two subnets (snet-prod at /24, snet-mgmt at /24)
- NSG has Allow-HTTP (100), Allow-SSH (110 source: snet-mgmt), Deny-All-Inbound (4000) in correct priority order
- NSG is associated with snet-prod only; snet-mgmt is unassociated
- Evidence files are complete and readable

## Troubleshooting

### Subnet create fails with address overlap

- Cause: CIDR already used by existing subnet in same VNet
- Fix: run `az network vnet show` to view existing address space; adjust prefix

### NSG rule priority conflict

- Cause: two rules with the same priority and direction
- Fix: run `az network nsg rule list --nsg-name "$NSG_NAME"` to see priorities; update the conflicting rule with `az network nsg rule update --priority <new>`

### NSG association does not appear in subnet show

- Cause: eventual consistency delay (rare)
- Fix: wait 30 seconds and re-run the subnet show command
