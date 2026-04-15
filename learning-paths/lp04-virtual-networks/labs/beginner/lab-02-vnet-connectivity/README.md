# Beginner Lab 02 - VNet Connectivity

Goal: create hub-and-spoke virtual network connectivity with peering and route controls.

## Variables

Azure CLI:

```bash
SUB_ID="<subscription-id>"
RG_NAME="rg-az104-network-dev-eastus2-01"
LOCATION="eastus2"
VNET_HUB="vnet-az104-hub-dev-eus2-01"
VNET_SPOKE="vnet-az104-spoke-dev-eus2-01"
ROUTE_TABLE="rt-az104-spoke-dev-eus2-01"
```

PowerShell:

```powershell
$SubscriptionId = "<subscription-id>"
$ResourceGroupName = "rg-az104-network-dev-eastus2-01"
$Location = "eastus2"
$VnetHub = "vnet-az104-hub-dev-eus2-01"
$VnetSpoke = "vnet-az104-spoke-dev-eus2-01"
$RouteTableName = "rt-az104-spoke-dev-eus2-01"
```

## Task 1 - Create VNets and subnets

Azure CLI:

```bash
az account set --subscription "$SUB_ID"
az group create --name "$RG_NAME" --location "$LOCATION"

az network vnet create -g "$RG_NAME" -n "$VNET_HUB" --address-prefix 10.10.0.0/16 --subnet-name snet-hub-core --subnet-prefix 10.10.0.0/24
az network vnet create -g "$RG_NAME" -n "$VNET_SPOKE" --address-prefix 10.20.0.0/16 --subnet-name snet-spoke-app --subnet-prefix 10.20.1.0/24
```

## Task 2 - Configure peering

Azure CLI:

```bash
az network vnet peering create -g "$RG_NAME" -n hub-to-spoke --vnet-name "$VNET_HUB" --remote-vnet "$VNET_SPOKE" --allow-vnet-access
az network vnet peering create -g "$RG_NAME" -n spoke-to-hub --vnet-name "$VNET_SPOKE" --remote-vnet "$VNET_HUB" --allow-vnet-access
```

## Task 3 - Configure route table and associate subnet

Azure CLI:

```bash
az network route-table create -g "$RG_NAME" -n "$ROUTE_TABLE" -l "$LOCATION"
az network route-table route create \
  -g "$RG_NAME" \
  --route-table-name "$ROUTE_TABLE" \
  -n to-hub-inspection \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address 10.10.0.4

az network vnet subnet update \
  -g "$RG_NAME" \
  --vnet-name "$VNET_SPOKE" \
  -n snet-spoke-app \
  --route-table "$ROUTE_TABLE"
```

## Verify

```bash
az network vnet peering list -g "$RG_NAME" --vnet-name "$VNET_HUB" -o table
az network route-table show -g "$RG_NAME" -n "$ROUTE_TABLE" --query "routes[].{name:name,nextHopType:nextHopType,addressPrefix:addressPrefix}" -o table
```

## Validation

```powershell
pwsh -File learning-paths/lp04-virtual-networks/modules/m02-connectivity-and-routing/validation/validate.ps1 -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -RouteTableName $RouteTableName
```
