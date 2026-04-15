# Beginner Lab 01 — VM Foundations

**Track:** Beginner
**Learning Path:** LP03 — Deploy and manage Azure compute resources
**Module Coverage:** M01 — Virtual Machine Foundations
**Estimated Time:** 45 minutes

## Goal

Deploy and validate a standard Azure virtual machine with a managed OS disk. Confirm that the VM reaches a running power state and that all required resource tags are present.

---

## Variables

Set these at the start of your session and reference them throughout every task.

Bash / Azure CLI:

```bash
SUBSCRIPTION_ID="<your-subscription-id>"
LOCATION="eastus2"
RG_NAME="rg-az104-compute-dev-eastus2-01"
VM_NAME="vm-az104-compute-dev-01"
IMAGE="Ubuntu2204"
VM_SIZE="Standard_B2s"
ADMIN_USER="azureadmin"
```

PowerShell:

```powershell
$SubscriptionId     = "<your-subscription-id>"
$Location           = "eastus2"
$ResourceGroupName  = "rg-az104-compute-dev-eastus2-01"
$VmName             = "vm-az104-compute-dev-01"
$Image              = "Ubuntu2204"
$VmSize             = "Standard_B2s"
$AdminUser          = "azureadmin"
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

## Task 3 — Deploy a virtual machine with a managed OS disk

Deploy a VM using ephemeral-safe delete options so the OS disk and NIC are removed when the VM is deleted.

Azure CLI:

```bash
az vm create \
  --resource-group "$RG_NAME" \
  --name "$VM_NAME" \
  --image "$IMAGE" \
  --size "$VM_SIZE" \
  --admin-username "$ADMIN_USER" \
  --generate-ssh-keys \
  --os-disk-delete-option Delete \
  --nic-delete-option Delete \
  --output table
```

PowerShell:

```powershell
$cred = Get-Credential -UserName $AdminUser -Message "Enter SSH admin credentials"
New-AzVm `
  -ResourceGroupName $ResourceGroupName `
  -Name $VmName `
  -Location $Location `
  -Image $Image `
  -Size $VmSize `
  -Credential $cred
```

---

## Task 4 — Verify VM power state and managed disk

Azure CLI:

```bash
az vm show \
  --resource-group "$RG_NAME" \
  --name "$VM_NAME" \
  --show-details \
  --query "{name:name, powerState:powerState, osDiskType:storageProfile.osDisk.managedDisk.storageAccountType}" \
  -o table
```

Confirm `powerState` is `VM running` and that `osDiskType` is populated (confirming a managed disk).

PowerShell:

```powershell
Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -Status |
  Select-Object Name, @{N='PowerState';E={ ($_.Statuses | Where-Object Code -Match 'PowerState').DisplayStatus }}
```

---

## Task 5 — Run validation (required)

```powershell
pwsh learning-paths/lp03-compute-resources/modules/m01-vm-foundations/validation/validate.ps1 `
  -VmName $VmName
```

A passing result confirms the VM exists, is running, and meets the baseline configuration requirements for this module.

---

## Clean-up (optional)

```bash
az group delete --name "$RG_NAME" --yes --no-wait
```
