# Advanced Lab 02 - Storage Least-Privilege Design

## Difficulty

- Advanced

## Time Estimate

- 90 to 120 minutes

## Scenario

Your platform team is opening delegated storage operations to an application squad. You must design RBAC and data-plane permissions that allow required storage actions while preventing account-level sprawl and privilege escalation.

## Objective

1. Build a storage-specific identity and scope model.
2. Assign management-plane and data-plane roles at minimum scope.
3. Prove required operations succeed and prohibited operations fail.
4. Produce auditable rationale and rollback instructions.

## Required Deliverables

- design-assumptions.md
- role-scope-matrix.md
- implementation-cli.txt
- implementation-pwsh.txt
- validation-allowed-denied.md
- rationale.md
- rollback.md

## Step 1 - Define access model

In design-assumptions.md document:

1. Personas: storage-operator, storage-auditor, app-data-contributor.
2. Required actions per persona (lifecycle rules, diagnostic settings, blob upload/read).
3. Explicitly denied actions (key rotation, public access enablement, RBAC delegation outside target RG).

## Step 2 - Build role and scope matrix

Use these reference scopes:

- Subscription: read-only inventory
- Resource group: rg-az104-storage-dev-eastus2-01
- Storage account: staz104blobdev01
- Container: archive

Suggested matrix entries:

- storage-operator: Storage Account Contributor at storage RG scope.
- storage-auditor: Reader at subscription scope.
- app-data-contributor: Storage Blob Data Contributor at container scope.

## Step 3 - Implement role assignments

CLI example:

```bash
SUB_ID="<subscription-id>"
RG_SCOPE="/subscriptions/$SUB_ID/resourceGroups/rg-az104-storage-dev-eastus2-01"
SA_SCOPE="$RG_SCOPE/providers/Microsoft.Storage/storageAccounts/staz104blobdev01"
CONTAINER_SCOPE="$SA_SCOPE/blobServices/default/containers/archive"

az role assignment create --assignee-object-id "<storage-operator-group-id>" --assignee-principal-type Group --role "Storage Account Contributor" --scope "$RG_SCOPE"
az role assignment create --assignee-object-id "<storage-auditor-group-id>" --assignee-principal-type Group --role Reader --scope "/subscriptions/$SUB_ID"
az role assignment create --assignee-object-id "<app-data-group-id>" --assignee-principal-type Group --role "Storage Blob Data Contributor" --scope "$CONTAINER_SCOPE"
```

## Step 4 - Validate allow and deny behavior

Capture in validation-allowed-denied.md:

- Allow: app-data-contributor uploads blob in archive container.
- Deny: app-data-contributor updates storage account networking.
- Allow: storage-operator updates lifecycle rule.
- Deny: storage-operator assigns Owner role at subscription.
- Allow: storage-auditor reads storage inventory.
- Deny: storage-auditor deletes any blob.

## Step 5 - Document rationale and rollback

In rationale.md explain why each scope is the smallest viable boundary.

In rollback.md include exact delete commands for each role assignment.

## Acceptance Criteria

- Data-plane write access exists only where required.
- Management-plane privileges are constrained to storage RG scope.
- Validation evidence includes both successful and blocked actions.
- Submission is reproducible without hidden assumptions.
