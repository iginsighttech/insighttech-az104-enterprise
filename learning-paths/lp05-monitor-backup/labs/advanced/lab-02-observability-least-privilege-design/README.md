# Advanced Lab 02 - Observability Least-Privilege Design

## Difficulty

- Advanced

## Time Estimate

- 90 to 120 minutes

## Scenario

An SRE team must maintain alert rules and backup visibility without receiving unrestricted access to production resources. Design a least-privilege model for monitoring and recovery operations.

## Objective

1. Define observability personas and exact required actions.
2. Implement minimum RBAC for monitoring and backup tasks.
3. Validate both success and denial paths.
4. Document rationale and rollback procedure.

## Required Deliverables

- design-assumptions.md
- role-scope-matrix.md
- implementation-cli.txt
- implementation-pwsh.txt
- validation-allowed-denied.md
- rationale.md
- rollback.md

## Step 1 - Identify personas

Document:

1. alert-operator (manage metric alerts and action groups).
2. backup-operator (monitor backup jobs and recovery points).
3. observability-auditor (read-only compliance checks).
4. Disallowed actions (resource deletion, subscription policy changes, owner delegation).

## Step 2 - Map roles to scopes

Use scopes:

- Resource group: rg-az104-monitor-dev-eastus2-01
- Recovery Services vault: rsv-az104-ops-dev-01

Suggested matrix:

- alert-operator: Monitoring Contributor at monitor RG scope.
- backup-operator: Backup Contributor at vault scope.
- observability-auditor: Reader at subscription scope.

## Step 3 - Implement assignments

CLI example:

```bash
SUB_ID="<subscription-id>"
RG_SCOPE="/subscriptions/$SUB_ID/resourceGroups/rg-az104-monitor-dev-eastus2-01"
VAULT_SCOPE="$RG_SCOPE/providers/Microsoft.RecoveryServices/vaults/rsv-az104-ops-dev-01"

az role assignment create --assignee-object-id "<alert-ops-group-id>" --assignee-principal-type Group --role "Monitoring Contributor" --scope "$RG_SCOPE"
az role assignment create --assignee-object-id "<backup-ops-group-id>" --assignee-principal-type Group --role "Backup Contributor" --scope "$VAULT_SCOPE"
az role assignment create --assignee-object-id "<observability-auditor-group-id>" --assignee-principal-type Group --role Reader --scope "/subscriptions/$SUB_ID"
```

## Step 4 - Validate expected outcomes

Record tests:

- Allow: alert-operator updates CPU alert threshold.
- Deny: alert-operator deletes VM resource.
- Allow: backup-operator lists recovery points and starts restore test.
- Deny: backup-operator modifies NSG in another RG.
- Allow: observability-auditor reads backup reports.
- Deny: observability-auditor changes action group webhook.

## Step 5 - Rationale and rollback

In rationale.md explain why monitoring and backup responsibilities are split.

In rollback.md provide delete commands for all role assignments.

## Acceptance Criteria

- Monitoring and backup write permissions are limited to required scopes.
- Read-only auditing remains available without elevation.
- Validation evidence includes blocked privilege-escalation attempts.
- Design can be reviewed and replayed by another team.
