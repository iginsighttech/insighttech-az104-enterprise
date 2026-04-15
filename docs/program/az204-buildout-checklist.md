# AZ-204 Build-Out Checklist

## Goal
Build a complete AZ-204 training repo using the same delivery model and quality bar as AZ-104.

## Working Model
- Branch from `develop` into focused feature branches.
- Keep changes scoped to one learning path or one shared system at a time.
- Merge with pull requests and validation evidence.

## Phase 1: Foundation Alignment
- [ ] Confirm AZ-204 exam objective domains and weighting.
- [ ] Map AZ-104 repo structure to AZ-204 domain structure.
- [ ] Decide learning path naming convention for AZ-204.
- [ ] Update top-level README with AZ-204 program intent.
- [ ] Update docs/program curriculum matrix for AZ-204.

## Phase 2: Learning Path Scaffolding
- [ ] Create/confirm AZ-204 learning-path folders.
- [ ] Add README for each path.
- [ ] Add module skeletons for each path.
- [ ] Add labs skeletons by level: beginner, intermediate, advanced, capstone.
- [ ] Add exam prep folders and placeholders.
- [ ] Add validation script placeholders for each path.

## Phase 3: Content Migration and Rewrite
- [ ] Rewrite identity/auth content to app-centric AZ-204 topics.
- [ ] Rewrite compute content to app services, containers, and functions operations.
- [ ] Rewrite storage content to developer storage patterns and SDK usage.
- [ ] Add messaging and event-driven modules (Service Bus, Event Grid, Event Hubs).
- [ ] Add API and integration modules (APIM, managed identity, secure config).
- [ ] Add observability and troubleshooting modules for apps and services.
- [ ] Ensure every module has lab + assessment + remediation path.

## Phase 4: Shared Assets and Automation
- [ ] Review shared Bicep modules for AZ-204 relevance.
- [ ] Add new shared modules needed for app architecture labs.
- [ ] Update shared scripts (CLI and PowerShell) for AZ-204 scenarios.
- [ ] Add markdown lint and docs consistency checks to CI.
- [ ] Add secret scanning and baseline policy checks.

## Phase 5: Quality and Validation
- [ ] Create per-path validation scripts and expected outputs.
- [ ] Run full validation sweep across all learning paths.
- [ ] Review links, command correctness, and timing estimates.
- [ ] Perform instructor dry-run for at least one module per path.
- [ ] Track remediation issues and close before release.

## Phase 6: Release Readiness
- [ ] Finalize changelog entries for AZ-204 launch.
- [ ] Publish instructor-only guidance updates.
- [ ] Confirm CODEOWNERS coverage for new paths.
- [ ] Tag initial AZ-204 baseline release.

## Branch Plan
- `feature/az204-lp01-*`
- `feature/az204-lp02-*`
- `feature/az204-lp03-*`
- `feature/az204-lp04-*`
- `feature/az204-lp05-*`
- `feature/az204-shared-*`

## Definition of Done (Per Learning Path)
- [ ] Path README complete and accurate.
- [ ] Modules include objectives, concepts, and hands-on tasks.
- [ ] Labs include prerequisites, steps, checks, and cleanup.
- [ ] Validation script exists and passes.
- [ ] Exam prep questions and answer key reviewed.

## Immediate Next Actions
- [ ] Finalize AZ-204 learning path taxonomy.
- [ ] Scaffold first target path and modules.
- [ ] Implement first end-to-end lab with validation script.