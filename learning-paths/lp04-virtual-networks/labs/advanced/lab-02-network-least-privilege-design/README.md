# Advanced Lab 02 - Network Least-Privilege Design

## Difficulty

- Advanced

## Time Estimate

- 90 to 120 minutes

## Scenario

A network team manages hub-and-spoke connectivity and security controls. Create a least-privilege role design that allows routing and NSG changes in approved scopes without granting platform-wide authority.

## Objective

1. Model network personas with scoped privileges.
2. Assign least-privilege roles for hub/spoke operations.
3. Validate permitted and blocked tasks.
4. Produce a clear security rationale and rollback path.

## Required Deliverables

- design-assumptions.md
- role-scope-matrix.md
- implementation-cli.txt
- implementation-pwsh.txt
- validation-allowed-denied.md
- rationale.md
- rollback.md

## Step 1 - Persona definition

Document:

1. network-operator (NSG and UDR changes in network RG).
2. peering-operator (manage peering on specific VNets only).
3. network-auditor (read-only across subscription).
4. Denied operations (global policy updates, cross-subscription role assignment).

## Step 2 - Role and scope matrix

Use scopes:

- Resource group: rg-az104-network-dev-eastus2-01
- Hub VNet: vnet-az104-hub-dev-eus2-01
- Spoke VNet: vnet-az104-spoke-dev-eus2-01

Suggested assignments:

- network-operator: Network Contributor at network RG scope.
- peering-operator: Network Contributor at specific VNet scopes.
- network-auditor: Reader at subscription scope.

## Step 3 - Implement assignments

CLI example:

```bash
SUB_ID="<subscription-id>"
RG_SCOPE="/subscriptions/$SUB_ID/resourceGroups/rg-az104-network-dev-eastus2-01"
HUB_SCOPE="$RG_SCOPE/providers/Microsoft.Network/virtualNetworks/vnet-az104-hub-dev-eus2-01"
SPOKE_SCOPE="$RG_SCOPE/providers/Microsoft.Network/virtualNetworks/vnet-az104-spoke-dev-eus2-01"

az role assignment create --assignee-object-id "<network-ops-group-id>" --assignee-principal-type Group --role "Network Contributor" --scope "$RG_SCOPE"
az role assignment create --assignee-object-id "<peering-ops-group-id>" --assignee-principal-type Group --role "Network Contributor" --scope "$HUB_SCOPE"
az role assignment create --assignee-object-id "<peering-ops-group-id>" --assignee-principal-type Group --role "Network Contributor" --scope "$SPOKE_SCOPE"
az role assignment create --assignee-object-id "<network-auditor-group-id>" --assignee-principal-type Group --role Reader --scope "/subscriptions/$SUB_ID"
```

## Step 4 - Validate controls

Capture proof for:

- Allow: network-operator adds NSG rule in target RG.
- Deny: network-operator updates route table in non-approved RG.
- Allow: peering-operator updates hub-to-spoke peering setting.
- Deny: peering-operator edits NSG at RG scope.
- Allow: network-auditor reads effective route table.
- Deny: network-auditor creates peering.

## Step 5 - Final documentation

Summarize residual risk if Network Contributor were assigned at subscription scope.

Provide rollback commands for each assignment.

## Acceptance Criteria

- Network write operations are scoped to approved resources.
- Read-only auditing remains broad without write permissions.
- Denied tests prove protection boundaries.
- Evidence is sufficient for peer review.
