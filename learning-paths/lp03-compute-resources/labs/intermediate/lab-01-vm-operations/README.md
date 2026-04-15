# Intermediate Lab 01 - VM Operations Runbook

## Purpose

This lab converts M01 compute foundations into repeatable operational work. You will manage VM lifecycle, perform disk operations, resize instances, and validate effective permissions using both CLI and PowerShell.

## Time Estimate

- 60 to 90 minutes

## Prerequisites

- Completed beginner Lab 01
- Non-production subscription access
- Virtual Machine Contributor or Contributor role on target resource group
- Azure CLI and PowerShell Az installed

## Scenario

The platform team operates a fleet of dev VMs. You must:

1. Create and tag a VM resource group
2. Deploy or validate a standard dev VM
3. Perform start, stop, and status operations
4. Attach and detach a data disk
5. Produce evidence for audit and handoff

## Variables

```bash
SUB_ID="<subscription-id>"
LOCATION="eastus2"
RG_NAME="rg-az104-vmops-dev-eastus2-01"
VM_NAME="vm-az104-vmops-dev-01"
DISK_NAME="disk-az104-vmops-data-01"
```

```powershell
$SubscriptionId = "<subscription-id>"
$Location = "eastus2"
$RgName = "rg-az104-vmops-dev-eastus2-01"
$VmName = "vm-az104-vmops-dev-01"
$DiskName = "disk-az104-vmops-data-01"
```

## Task 1 - Set Context and Create Baseline Resource Group

### Azure CLI

```bash
az account set --subscription "$SUB_ID"

az group create \
  --name "$RG_NAME" \
  --location "$LOCATION" \
  --tags Owner="student" CostCenter="IT-104" Environment="dev" Workload="vm-ops" DataClass="internal" ExpirationDate="2026-12-31"
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
    Workload       = "vm-ops"
    DataClass      = "internal"
    ExpirationDate = "2026-12-31"
  }
```

## Task 2 - Deploy or Validate the Operations VM

### Azure CLI

```bash
az vm create \
  --resource-group "$RG_NAME" \
  --name "$VM_NAME" \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --os-disk-delete-option Delete \
  --nic-delete-option Delete \
  --no-wait

az vm wait --resource-group "$RG_NAME" --name "$VM_NAME" --created
az vm show --resource-group "$RG_NAME" --name "$VM_NAME" \
  --query "{name:name,powerState:powerState,size:hardwareProfile.vmSize}" -o table
```

### PowerShell

```powershell
$cred = New-Object PSCredential("azureuser", (ConvertTo-SecureString "TempPwd!123" -AsPlainText -Force))

New-AzVM `
  -ResourceGroupName $RgName `
  -Location $Location `
  -Name $VmName `
  -Image "Ubuntu2204" `
  -Size "Standard_B2s" `
  -Credential $cred

Get-AzVM -ResourceGroupName $RgName -Name $VmName -Status |
  Select-Object Name, @{N="PowerState";E={($_.Statuses | Where-Object Code -like "PowerState/*").DisplayStatus}}
```

## Task 3 - Perform Stop, Start, and Status Operations

### Azure CLI

```bash
az vm stop --resource-group "$RG_NAME" --name "$VM_NAME"
az vm show --resource-group "$RG_NAME" --name "$VM_NAME" -d --query powerState -o tsv

az vm start --resource-group "$RG_NAME" --name "$VM_NAME"
az vm show --resource-group "$RG_NAME" --name "$VM_NAME" -d --query powerState -o tsv
```

### PowerShell

```powershell
Stop-AzVM -ResourceGroupName $RgName -Name $VmName -Force

(Get-AzVM -ResourceGroupName $RgName -Name $VmName -Status).Statuses |
  Where-Object Code -like "PowerState/*" | Select-Object DisplayStatus

Start-AzVM -ResourceGroupName $RgName -Name $VmName

(Get-AzVM -ResourceGroupName $RgName -Name $VmName -Status).Statuses |
  Where-Object Code -like "PowerState/*" | Select-Object DisplayStatus
```

## Task 4 - Attach and Detach a Managed Data Disk

### Azure CLI

```bash
az disk create \
  --resource-group "$RG_NAME" \
  --name "$DISK_NAME" \
  --size-gb 32 \
  --sku Standard_LRS

az vm disk attach \
  --resource-group "$RG_NAME" \
  --vm-name "$VM_NAME" \
  --name "$DISK_NAME"

az vm show --resource-group "$RG_NAME" --name "$VM_NAME" \
  --query "storageProfile.dataDisks[].{name:name,sizeGb:diskSizeGb,lun:lun}" -o table

az vm disk detach \
  --resource-group "$RG_NAME" \
  --vm-name "$VM_NAME" \
  --name "$DISK_NAME"
```

### PowerShell

```powershell
$disk = New-AzDisk `
  -ResourceGroupName $RgName `
  -DiskName $DiskName `
  -Disk (New-AzDiskConfig -Location $Location -DiskSizeGB 32 -SkuName Standard_LRS -CreateOption Empty)

$vm = Get-AzVM -ResourceGroupName $RgName -Name $VmName
Add-AzVMDataDisk -VM $vm -Name $DiskName -ManagedDiskId $disk.Id -Lun 0 -CreateOption Attach | Out-Null
Update-AzVM -ResourceGroupName $RgName -VM $vm

$vm = Get-AzVM -ResourceGroupName $RgName -Name $VmName
$vm.StorageProfile.DataDisks | Select-Object Name, DiskSizeGB, Lun

Remove-AzVMDataDisk -VM $vm -Name $DiskName | Out-Null
Update-AzVM -ResourceGroupName $RgName -VM $vm
```

## Task 5 - Produce Evidence Package

Create these files in your branch under this lab folder:

- `evidence-vm.json` — output of `az vm show`
- `evidence-power-states.txt` — stop and start power state output
- `evidence-disk-attach.txt` — disk list output after attach
- `ops-notes.md` — short note on why B2s was chosen and why managed disks are required

## Acceptance Criteria

- Resource group exists with required tags
- VM deployed with Ubuntu2204, Standard_B2s, SSH key auth
- Stop and start operations confirmed with power state output
- Data disk attached (LUN 0) and detached successfully
- Evidence files are complete and readable

## Troubleshooting

### VM creation quota exceeded

- Cause: dev subscription has vCPU limits
- Fix: use `az vm list-usage --location "$LOCATION" -o table` to check; switch to Standard_B1s if needed

### Disk attach fails with `DiskInUse`

- Cause: disk is attached to another VM
- Fix: run `az disk show --name "$DISK_NAME" --resource-group "$RG_NAME" --query managedBy`; detach from existing VM first

### Power state stuck in `stopping`

- Cause: Azure guest agent not responding
- Fix: use `az vm restart` or wait 5 minutes; force-power-off only as a last resort
