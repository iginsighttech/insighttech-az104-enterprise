# Beginner Lab 02 - VM Deployment and Sizing

Goal: deploy a virtual machine scale set (VMSS), validate sizing, and configure basic autoscale behavior.

## Variables

Azure CLI:

```bash
SUB_ID="<subscription-id>"
RG_NAME="rg-az104-compute-dev-eastus2-01"
LOCATION="eastus2"
VMSS_NAME="vmss-az104-web-dev-01"
ADMIN_USER="azureadmin"
```

PowerShell:

```powershell
$SubscriptionId = "<subscription-id>"
$ResourceGroupName = "rg-az104-compute-dev-eastus2-01"
$Location = "eastus2"
$VmssName = "vmss-az104-web-dev-01"
$AdminUser = "azureadmin"
```

## Task 1 - Create resource group and VMSS

Azure CLI:

```bash
az account set --subscription "$SUB_ID"
az group create --name "$RG_NAME" --location "$LOCATION"

az vmss create \
  --resource-group "$RG_NAME" \
  --name "$VMSS_NAME" \
  --image Ubuntu2204 \
  --instance-count 2 \
  --admin-username "$ADMIN_USER" \
  --generate-ssh-keys \
  --upgrade-policy-mode automatic
```

## Task 2 - Configure autoscale rules

Azure CLI:

```bash
VMSS_ID=$(az vmss show -g "$RG_NAME" -n "$VMSS_NAME" --query id -o tsv)

az monitor autoscale create \
  --resource-group "$RG_NAME" \
  --resource "$VMSS_NAME" \
  --resource-type Microsoft.Compute/virtualMachineScaleSets \
  --name "autoscale-$VMSS_NAME" \
  --min-count 2 \
  --max-count 4 \
  --count 2

az monitor autoscale rule create \
  --resource-group "$RG_NAME" \
  --autoscale-name "autoscale-$VMSS_NAME" \
  --condition "Percentage CPU > 70 avg 5m" \
  --scale out 1

az monitor autoscale rule create \
  --resource-group "$RG_NAME" \
  --autoscale-name "autoscale-$VMSS_NAME" \
  --condition "Percentage CPU < 30 avg 10m" \
  --scale in 1
```

PowerShell verification:

```powershell
Select-AzSubscription -SubscriptionId $SubscriptionId
Get-AzVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $VmssName | Select-Object Name, Location
```

## Verify

- VMSS exists with at least 2 instances.
- Autoscale settings are present.

```bash
az vmss show -g "$RG_NAME" -n "$VMSS_NAME" --query "{name:name,capacity:sku.capacity,tier:sku.tier,size:sku.name}" -o table
az monitor autoscale list -g "$RG_NAME" -o table
```

## Validation

```powershell
pwsh -File learning-paths/lp03-compute-resources/modules/m02-vm-scale-and-availability/validation/validate.ps1 -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -VmssName $VmssName
```
