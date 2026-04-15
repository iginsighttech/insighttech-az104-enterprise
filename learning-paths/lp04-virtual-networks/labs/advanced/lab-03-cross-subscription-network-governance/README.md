# Advanced Lab 03 - Cross-Subscription Network Governance

## Difficulty

- Advanced

## Time Estimate

- 120 to 150 minutes

## Scenario

Your organization runs hub-and-spoke networks across multiple subscriptions. You must implement cross-subscription governance that permits controlled routing and connectivity changes without exposing global network administration.

## Objective

1. Define cross-subscription network governance boundaries.
2. Assign least-privilege access for peering and routing operations.
3. Apply governance controls for NSG, route, and subnet hygiene.
4. Validate policy and RBAC behavior with operational evidence.

## Target Scopes

- Subscription A: central-network-hub
- Subscription B: spoke-app-network
- Resource group in Subscription B: rg-az104-network-prod-eastus2-01

## Required Deliverables

- tenant-and-scope-map.md
- role-assignment-plan.md
- policy-assignment-plan.md
- implementation-cli.txt
- validation-results.md
- risk-and-mitigation.md
- rollback.md

## Step 1 - Governance boundaries

Document:

- Which team can modify hub and spoke peering settings.
- Which team can modify NSG and UDR only in approved RG.
- Which operations are denied outside designated scope.

## Step 2 - RBAC model

Define assignments:

- network-auditor: Reader in both subscriptions.
- network-operator: Network Contributor on rg-az104-network-prod-eastus2-01.
- peering-operator: Network Contributor at specific hub and spoke VNet scopes.

## Step 3 - Policy controls

Assign and validate controls:

1. Deny inbound NSG rules from Any to management ports.
2. Require route tables on designated subnets.
3. Require environment and owner tags on network resources.

Record whether each policy is Audit or Deny in rollout.

## Step 4 - Validation matrix

Capture:

- Allow: update approved NSG rule in target RG.
- Deny: create permissive NSG rule violating policy.
- Allow: update approved peering setting.
- Deny: edit peering in non-approved subscription.
- Allow: read effective routes across both subscriptions.

## Step 5 - Risk and rollback

In risk-and-mitigation.md include:

- Risks from incorrect peering permissions.
- Required monitoring alerts for policy drift.
- Emergency rollback flow for route-impact incidents.

Provide rollback commands for all role and policy assignments.

## Acceptance Criteria

- Cross-subscription network operations are scope-limited.
- Policy controls are assigned and tested.
- Evidence demonstrates expected allow and deny outcomes.
- Rollback and governance notes are complete.
