# Advanced Lab 03 - Cross-Subscription Storage Governance

## Difficulty

- Advanced

## Time Estimate

- 120 to 150 minutes

## Scenario

A central platform team must govern storage resources in two subscriptions without granting broad tenant-wide privileges. You need to implement scoped access, policy controls, and evidence-driven validation.

## Objective

1. Implement cross-subscription read and write boundaries for storage operations.
2. Enforce baseline governance controls for storage security and tagging.
3. Validate allowed and denied behavior across both subscriptions.
4. Produce auditable governance and rollback documentation.

## Target Scopes

- Subscription A: shared-services (read plus policy audit)
- Subscription B: workload-storage (limited write in specific RG)
- Resource group in Subscription B: rg-az104-storage-prod-eastus2-01

## Required Deliverables

- tenant-and-scope-map.md
- role-assignment-plan.md
- policy-assignment-plan.md
- implementation-cli.txt
- validation-results.md
- risk-and-mitigation.md
- rollback.md

## Step 1 - Baseline mapping

Document scope boundaries and why each boundary is required.

Include:

- Which personas can read both subscriptions.
- Which personas can change storage configuration in Subscription B only.
- Which actions remain prohibited globally.

## Step 2 - Cross-subscription RBAC design

Define assignments such as:

- storage-governance-auditor: Reader on Subscription A and B.
- storage-operations-team: Storage Account Contributor on rg-az104-storage-prod-eastus2-01 in Subscription B only.
- data-access-team: Storage Blob Data Contributor at selected container scope.

## Step 3 - Policy controls

Assign at least two controls and record assignment evidence:

1. Require HTTPS only for storage accounts.
2. Require mandatory tags (environment, owner).

Record whether each control should be Audit or Deny for current rollout.

## Step 4 - Validation tests

Run and record:

- Allow: create storage account in approved RG with required tags.
- Deny: create storage account in non-approved RG.
- Deny or audit event: attempt HTTP-only configuration.
- Allow: blob upload in approved container scope.
- Deny: data team changes storage firewall settings.

## Step 5 - Governance report

In risk-and-mitigation.md include:

- Residual risks from cross-subscription operations.
- Monitoring signals to detect policy drift.
- Break-glass process with expiration requirement.

In rollback.md include exact steps for removing RBAC and policy assignments.

## Acceptance Criteria

- Cross-subscription role model is enforced at intended scope.
- Storage policy controls are assigned and validated.
- Evidence shows both successful actions and blocked actions.
- Rollback is complete and executable.
