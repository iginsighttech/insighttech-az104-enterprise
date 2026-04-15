# Advanced Lab 03 - Cross-Subscription Monitoring Governance

## Difficulty

- Advanced

## Time Estimate

- 120 to 150 minutes

## Scenario

Operations must monitor and recover workloads across multiple subscriptions while preserving least privilege. Build a cross-subscription governance model for alerts, logs, and backup operations.

## Objective

1. Define monitoring and backup access boundaries across subscriptions.
2. Assign least-privilege roles for alert and recovery operations.
3. Apply governance controls for observability configuration quality.
4. Validate both operational success and governance denials.

## Target Scopes

- Subscription A: platform-observability
- Subscription B: workload-observability
- Resource group in Subscription B: rg-az104-monitor-prod-eastus2-01
- Recovery Services vault: rsv-az104-ops-prod-01

## Required Deliverables

- tenant-and-scope-map.md
- role-assignment-plan.md
- policy-assignment-plan.md
- implementation-cli.txt
- validation-results.md
- risk-and-mitigation.md
- rollback.md

## Step 1 - Scope and persona design

Document personas:

- observability-auditor (read-only in both subscriptions).
- alert-operator (alert and action group updates in approved RG).
- backup-operator (backup and restore operations on designated vault).

## Step 2 - RBAC model

Define assignments:

- Reader for observability-auditor at both subscription scopes.
- Monitoring Contributor for alert-operator at monitor RG scope.
- Backup Contributor for backup-operator at vault scope.

## Step 3 - Governance controls

Assign and validate controls such as:

1. Require action group linkage for critical metric alerts.
2. Require tags on alert rules and backup resources.
3. Audit vaults without recent recovery point activity.

## Step 4 - Validation tests

Capture evidence for:

- Allow: alert-operator updates critical CPU alert in approved RG.
- Deny: alert-operator edits compute resources outside monitoring scope.
- Allow: backup-operator triggers backup and lists recovery points.
- Deny: backup-operator modifies NSG or route resources.
- Policy audit or deny: create untagged alert rule.

## Step 5 - Governance reporting

In risk-and-mitigation.md summarize:

- Risks from alert misrouting and over-privileged operators.
- Monitoring signals for governance drift.
- Emergency access workflow with expiration and review.

Provide rollback steps for RBAC and policy assignments.

## Acceptance Criteria

- Monitoring and backup rights are correctly scoped across subscriptions.
- Governance controls are assigned and validated.
- Validation includes both permitted and blocked actions.
- Documentation is complete, auditable, and reproducible.
