# Beginner Lab 01 — Storage Account Foundations

**Track:** Beginner  
**Learning Path:** LP02 — Implement and manage storage in Azure  
**Module Coverage:** M01

Goal: create and validate an enterprise-ready StorageV2 storage account with secure-transfer settings for an application team.

## Variables

Azure CLI:

```bash
export SUBSCRIPTION_ID="<your-subscription-id>"
export LOCATION="eastus2"
export RG_NAME="rg-az104-storage-dev-eastus2-01"
export STORAGE_ACCOUNT="staz104stordev01"
export TAG_Owner="student01"
export TAG_CostCenter="training"
export TAG_Environment="dev"
export TAG_Workload="az104"
export TAG_DataClass="training"
export TAG_ExpirationDate="2026-12-31"
```

PowerShell:

```powershell
$SubscriptionId     = "<your-subscription-id>"
$ResourceGroupName  = "rg-az104-storage-dev-eastus2-01"
$Location           = "eastus2"
$StorageAccountName = "staz104stordev01"
$Tags = @{
  Owner          = "student01"
  CostCenter     = "training"
  Environment    = "dev"
  Workload       = "az104"
  DataClass      = "training"
  ExpirationDate = "2026-12-31"
}
```

## Task 1 - Set subscription context

Portal: search **Subscriptions**, click your lab subscription, confirm name and ID.

Azure CLI:

```bash
az login
az account set --subscription "$SUBSCRIPTION_ID"
az account show --query "{name:name,id:id}" -o table
```

PowerShell:

```powershell
Connect-AzAccount
Set-AzContext -Subscription $SubscriptionId
Get-AzContext | Select-Object Subscription, Tenant
```

## Task 2 - Create the resource group with required tags

Portal: search **Resource groups** → **Create**, name `rg-az104-storage-dev-eastus2-01`, region **East US 2**, add the required tags, then **Review + create**.

Azure CLI:

```bash
az account set --subscription "$SUBSCRIPTION_ID"

az group create \
  --name "$RG_NAME" \
  --location "$LOCATION" \
  --tags \
    Owner="$TAG_Owner" \
    CostCenter="$TAG_CostCenter" \
    Environment="$TAG_Environment" \
    Workload="$TAG_Workload" \
    DataClass="$TAG_DataClass" \
    ExpirationDate="$TAG_ExpirationDate"

az group show --name "$RG_NAME" --query tags -o jsonc
```

PowerShell:

```powershell
Select-AzSubscription -SubscriptionId $SubscriptionId

New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Tag $Tags | Out-Null
Get-AzResourceGroup -Name $ResourceGroupName | Select-Object ResourceGroupName, Location, Tags
```

## Task 3 - Create the storage account with secure settings

Portal: search **Storage accounts** → **Create**, select the resource group, name `staz104stordev01`, region **East US 2**, Performance **Standard**, Redundancy **LRS**. On the **Advanced** tab enable **Secure transfer**, set **Minimum TLS** to **1.2**, and disable **Allow Blob public access**. Review + create.

Azure CLI:

```bash
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --https-only true \
  --allow-blob-public-access false

az storage account show \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RG_NAME" \
  --query "{sku:sku.name,kind:kind,httpsOnly:enableHttpsTrafficOnly,tls:minimumTlsVersion,publicAccess:allowBlobPublicAccess}" \
  -o table
```

PowerShell:

```powershell
New-AzStorageAccount `
  -ResourceGroupName $ResourceGroupName `
  -Name $StorageAccountName `
  -Location $Location `
  -SkuName Standard_LRS `
  -Kind StorageV2 `
  -MinimumTlsVersion TLS1_2 `
  -EnableHttpsTrafficOnly $true `
  -AllowBlobPublicAccess $false | Out-Null

Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName |
  Select-Object StorageAccountName, @{N="SKU";E={$_.Sku.Name}}, Kind, EnableHttpsTrafficOnly, MinimumTlsVersion, AllowBlobPublicAccess
```

## Task 4 - Verify replication and access tier

Azure CLI:

```bash
az storage account show \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RG_NAME" \
  --query "{name:name,sku:sku.name,accessTier:accessTier,kind:kind}" \
  -o table
```

PowerShell:

```powershell
Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName |
  Select-Object StorageAccountName, @{N="SKU";E={$_.Sku.Name}}, AccessTier, Kind
```

Expected: SKU = `Standard_LRS`, Kind = `StorageV2`, AccessTier = `Hot`.

## Task 5 - Run validation (required)

```powershell
pwsh -File learning-paths/lp02-storage-management/modules/m01-storage-accounts/validation/validate.ps1 `
  -SubscriptionId $SubscriptionId `
  -ResourceGroupName $ResourceGroupName `
  -StorageAccountName $StorageAccountName
```

Expected:

- PASS: Resource group exists
- PASS: Required tags present on RG
- PASS: Storage account exists
- PASS: HTTPS-only enabled
- PASS: Minimum TLS is TLS1_2
- PASS: Blob public access disabled
