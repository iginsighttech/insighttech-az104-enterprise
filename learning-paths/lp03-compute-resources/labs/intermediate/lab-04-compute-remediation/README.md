# Intermediate Lab 04 - Compute Remediation

## Time Estimate

- 75 to 105 minutes

## Scenario

A VM workload is out of baseline for security and operations standards. You must remediate without disrupting service.

## Objective

1. Identify baseline drift for VM operations.
2. Apply minimal remediation for access and security settings.
3. Validate compliance and workload availability.

## Variables

```bash
SUB_ID="<subscription-id>"
RG_NAME="rg-az104-compute-dev-eastus2-01"
VM_NAME="vm-az104-app-dev-01"
```

## Step 1 - Capture baseline

```bash
az account set --subscription "$SUB_ID"
az vm show -g "$RG_NAME" -n "$VM_NAME" -d -o json > evidence-vm-before.json
az vm extension list -g "$RG_NAME" --vm-name "$VM_NAME" -o json > evidence-vm-extensions-before.json
```

## Step 2 - Apply remediation

```bash
az vm update -g "$RG_NAME" -n "$VM_NAME" --set securityProfile.encryptionAtHost=true
az vm boot-diagnostics enable -g "$RG_NAME" -n "$VM_NAME"
```

## Step 3 - Re-validate operations

```bash
az vm show -g "$RG_NAME" -n "$VM_NAME" -d -o json > evidence-vm-after.json
az vm get-instance-view -g "$RG_NAME" -n "$VM_NAME" -o json > evidence-instance-view-after.json
```

## Step 4 - Document rollback

Create:

- remediation-summary.md
- rollback-plan.md

## Acceptance Criteria

- Remediation enforces compute baseline controls.
- VM remains healthy post-change.
- Evidence and rollback plan are complete.
