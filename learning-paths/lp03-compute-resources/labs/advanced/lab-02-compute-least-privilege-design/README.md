# Advanced Lab 02 - Compute Least-Privilege Design

## Difficulty

- Advanced

## Time Estimate

- 90 to 120 minutes

## Scenario

Your operations team needs controlled access to VM and VMSS workloads. Build a role design that supports patching and diagnostics while preventing broad subscription administration.

## Objective

1. Define compute personas and minimum required permissions.
2. Assign least-privilege roles at correct scopes.
3. Validate positive and negative access tests.
4. Document operational risks and rollback plan.

## Required Deliverables

- design-assumptions.md
- role-scope-matrix.md
- implementation-cli.txt
- implementation-pwsh.txt
- validation-allowed-denied.md
- rationale.md
- rollback.md

## Step 1 - Define personas

In design-assumptions.md define:

1. vm-operator (start/stop/redeploy VM in compute RG).
2. vmss-operator (manage scale settings only).
3. compute-auditor (read-only estate visibility).
4. Disallowed actions (subscription-level role assignment, policy edits, key vault admin).

## Step 2 - Scope model

Use these boundaries:

- Subscription: read-only inventory
- Resource group: rg-az104-compute-dev-eastus2-01
- VMSS: vmss-az104-web-dev-01

Reference assignments:

- vm-operator: Virtual Machine Contributor at compute RG scope.
- vmss-operator: Contributor at VMSS resource scope only.
- compute-auditor: Reader at subscription scope.

## Step 3 - Implement assignments

CLI example:

```bash
SUB_ID="<subscription-id>"
RG_SCOPE="/subscriptions/$SUB_ID/resourceGroups/rg-az104-compute-dev-eastus2-01"
VMSS_SCOPE="$RG_SCOPE/providers/Microsoft.Compute/virtualMachineScaleSets/vmss-az104-web-dev-01"

az role assignment create --assignee-object-id "<vm-ops-group-id>" --assignee-principal-type Group --role "Virtual Machine Contributor" --scope "$RG_SCOPE"
az role assignment create --assignee-object-id "<vmss-ops-group-id>" --assignee-principal-type Group --role Contributor --scope "$VMSS_SCOPE"
az role assignment create --assignee-object-id "<compute-auditor-group-id>" --assignee-principal-type Group --role Reader --scope "/subscriptions/$SUB_ID"
```

## Step 4 - Validation matrix

Record expected and actual outcomes:

- Allow: vm-operator restarts VM in compute RG.
- Deny: vm-operator changes subscription policy.
- Allow: vmss-operator adjusts autoscale settings for target VMSS.
- Deny: vmss-operator deletes unrelated VM in another RG.
- Allow: compute-auditor reads instance view.
- Deny: compute-auditor runs VM extension update.

## Step 5 - Rationale and rollback

Explain why no persona requires Owner or User Access Administrator at subscription scope.

Provide rollback commands removing all assignments in reverse order.

## Acceptance Criteria

- Compute operations are possible only within intended scope.
- No broad write role exists at subscription level.
- Both allowed and denied test evidence is complete and consistent.
- Role model is operationally practical for day-2 support.
