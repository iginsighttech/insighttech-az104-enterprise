# Beginner Lab 03 — Backup Vault and Policy

**Track:** Beginner
**Learning Path:** LP05 — Monitor and back up Azure resources
**Module Coverage:** M03 — Backup and Recovery Services
**Estimated Time:** 45 minutes

## Goal

Create a Recovery Services vault, configure a backup policy with daily and weekly retention, and enable protection for a virtual machine. Verify that the backup item is registered and the policy is applied.

---

## Variables

Set these at the start of your session and reference them throughout every task.

Bash / Azure CLI:

```bash
SUBSCRIPTION_ID="<your-subscription-id>"
LOCATION="eastus2"
RG_NAME="rg-az104-backup-dev-eastus2-01"
VAULT_NAME="rsv-az104-backup-dev-eastus2-01"
POLICY_NAME="pol-daily-backup-dev"
VM_RG_NAME="rg-az104-compute-dev-eastus2-01"
VM_NAME="vm-az104-compute-dev-01"
```

PowerShell:

```powershell
$SubscriptionId    = "<your-subscription-id>"
$Location          = "eastus2"
$ResourceGroupName = "rg-az104-backup-dev-eastus2-01"
$VaultName         = "rsv-az104-backup-dev-eastus2-01"
$PolicyName        = "pol-daily-backup-dev"
$VmRgName          = "rg-az104-compute-dev-eastus2-01"
$VmName            = "vm-az104-compute-dev-01"
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

## Task 3 — Create the Recovery Services vault

Azure CLI:

```bash
az backup vault create \
  --resource-group "$RG_NAME" \
  --name "$VAULT_NAME" \
  --location "$LOCATION" \
  --output table
```

PowerShell:

```powershell
New-AzRecoveryServicesVault `
  -ResourceGroupName $ResourceGroupName `
  -Name $VaultName `
  -Location $Location
```

---

## Task 4 — Configure the backup policy

The default `DefaultPolicy` uses daily backups retained for 30 days. For this lab, set a custom policy with 30-day daily retention and 12-week weekly retention.

Azure CLI:

```bash
az backup policy set \
  --resource-group "$RG_NAME" \
  --vault-name "$VAULT_NAME" \
  --name "$POLICY_NAME" \
  --policy '{
    "backupManagementType": "AzureIaasVM",
    "schedulePolicy": {
      "scheduleRunFrequency": "Daily",
      "scheduleRunTimes": ["2000-01-01T02:00:00Z"]
    },
    "retentionPolicy": {
      "retentionPolicyType": "LongTermRetentionPolicy",
      "dailySchedule": {"retentionDuration": {"count": 30, "durationType": "Days"}},
      "weeklySchedule": {"daysOfTheWeek": ["Sunday"], "retentionDuration": {"count": 12, "durationType": "Weeks"}}
    }
  }'
```

PowerShell:

```powershell
$vault = Get-AzRecoveryServicesVault -ResourceGroupName $ResourceGroupName -Name $VaultName
Set-AzRecoveryServicesVaultContext -Vault $vault

$policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name "DefaultPolicy"
$policy.RetentionPolicy.DailySchedule.DurationCountInDays = 30
Set-AzRecoveryServicesBackupProtectionPolicy -Policy $policy
```

---

## Task 5 — Enable backup protection for a VM

> **Note:** The VM referenced in the variables section must exist in the specified resource group. If it does not, complete LP03 beginner lab-01 first or substitute an existing VM name.

Azure CLI:

```bash
az backup protection enable-for-vm \
  --resource-group "$RG_NAME" \
  --vault-name "$VAULT_NAME" \
  --vm "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$VM_RG_NAME/providers/Microsoft.Compute/virtualMachines/$VM_NAME" \
  --policy-name DefaultPolicy \
  --output table
```

PowerShell:

```powershell
$vault = Get-AzRecoveryServicesVault -ResourceGroupName $ResourceGroupName -Name $VaultName
Set-AzRecoveryServicesVaultContext -Vault $vault

$vm = Get-AzVM -ResourceGroupName $VmRgName -Name $VmName
Enable-AzRecoveryServicesBackupProtection `
  -ResourceGroupName $VmRgName `
  -Name $VmName `
  -Policy (Get-AzRecoveryServicesBackupProtectionPolicy -Name "DefaultPolicy")
```

---

## Task 6 — Verify the backup item and vault

Azure CLI:

```bash
az backup vault show \
  --resource-group "$RG_NAME" \
  --name "$VAULT_NAME" \
  --query "{name:name, location:location, provisioningState:properties.provisioningState}" \
  -o table

az backup item list \
  --resource-group "$RG_NAME" \
  --vault-name "$VAULT_NAME" \
  --backup-management-type AzureIaasVM \
  --query "[].{name:name, protectionState:properties.protectionState}" \
  -o table
```

Confirm the vault has `provisioningState` of `Succeeded` and that the VM backup item shows `ProtectionConfigured`.

PowerShell:

```powershell
Get-AzRecoveryServicesVault -ResourceGroupName $ResourceGroupName -Name $VaultName |
  Select-Object Name, Location

Get-AzRecoveryServicesBackupItem -BackupManagementType AzureVM -WorkloadType AzureVM |
  Select-Object Name, ProtectionState
```

---

## Task 7 — Run validation (required)

```powershell
pwsh learning-paths/lp05-monitor-backup/modules/m03-backup-and-recovery-services/validation/validate.ps1 `
  -RecoveryVaultName $VaultName
```

A passing result confirms the Recovery Services vault exists and has at least one protected backup item registered.

---

## Clean-up (optional)

Disable backup protection before deleting the vault to avoid soft-delete retention locks.

```bash
az backup protection disable \
  --resource-group "$RG_NAME" \
  --vault-name "$VAULT_NAME" \
  --container-name "iaasvmcontainerv2;${VM_RG_NAME};${VM_NAME}" \
  --item-name "$VM_NAME" \
  --backup-management-type AzureIaasVM \
  --workload-type VM \
  --delete-backup-data true \
  --yes

az group delete --name "$RG_NAME" --yes --no-wait
```
