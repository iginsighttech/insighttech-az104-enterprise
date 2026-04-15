# Advanced Lab 03 - Cross-Subscription Compute Governance

## Difficulty

- Advanced

## Time Estimate

- 120 to 150 minutes

## Scenario

Compute workloads are distributed across platform and application subscriptions. Your team must enforce consistent compute governance while keeping operator rights tightly scoped.

## Objective

1. Design cross-subscription compute governance boundaries.
2. Apply scoped RBAC for VM and VMSS operations.
3. Implement policy controls for baseline compute posture.
4. Validate governance outcomes with evidence.

## Target Scopes

- Subscription A: platform-compute-shared
- Subscription B: app-compute-prod
- Resource group in Subscription B: rg-az104-compute-prod-eastus2-01

## Required Deliverables

- tenant-and-scope-map.md
- role-assignment-plan.md
- policy-assignment-plan.md
- implementation-cli.txt
- validation-results.md
- risk-and-mitigation.md
- rollback.md

## Step 1 - Scope and persona mapping

Document personas:

- compute-auditor (read-only in both subscriptions).
- vm-operator (write in approved compute RG only).
- vmss-operator (scale and instance operations on one VMSS resource).

## Step 2 - RBAC implementation plan

Define assignments:

- Reader on both subscriptions for compute-auditor.
- Virtual Machine Contributor on rg-az104-compute-prod-eastus2-01 for vm-operator.
- Contributor at VMSS resource scope only for vmss-operator.

Explicitly prohibit subscription-level Owner assignments.

## Step 3 - Policy controls

Assign and validate controls such as:

1. Require approved VM sizes.
2. Enforce managed disks.
3. Require diagnostic settings or boot diagnostics.

Record remediation strategy for noncompliant resources.

## Step 4 - Validation tests

Capture evidence for:

- Allow: vm-operator restarts VM in approved RG.
- Deny: vm-operator modifies VM in non-approved RG.
- Allow: vmss-operator updates capacity on designated VMSS.
- Deny: vmss-operator edits unrelated network resources.
- Policy deny or audit: attempted non-approved VM size deployment.

## Step 5 - Governance summary

In risk-and-mitigation.md explain:

- Risks of broad compute roles.
- How policy plus RBAC reduces blast radius.
- Escalation workflow for emergency operations.

Provide full rollback for RBAC and policy assignments.

## Acceptance Criteria

- Compute operations are limited to designated cross-subscription scopes.
- Policy controls are active and validated.
- Both allowed and denied tests are evidenced.
- Documentation is review-ready and reproducible.
