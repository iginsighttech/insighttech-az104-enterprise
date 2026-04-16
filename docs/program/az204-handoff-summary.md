# AZ-204 Handoff Summary

## Purpose
Use this file to continue AZ-204 repo work in a different VS Code window or a fresh Copilot Chat session.

## Current Repository
- Repo: `ITech3875Dev/insighttech-az204-enterprise`
- Local workspace folder: `insighttech-az204-enterprise`
- Current working branch: `feature/az204-taxonomy-lp02`
- Branch tracking: `origin/feature/az204-taxonomy-lp02`

## Remote Setup
- `origin` points to the AZ-204 fork: `git@github.com:ITech3875Dev/insighttech-az204-enterprise.git`
- `upstream` points to the original source repo: `https://github.com/iginsighttech/insighttech-az104-enterprise.git`
- `main` tracks `origin/main`
- `develop` tracks `origin/develop`

## Completed Work

### Initial AZ-204 repo setup
- Forked/cloned the AZ-104 source into a dedicated AZ-204 repo
- Added `upstream` remote to the original source repo
- Created `develop` as the long-lived integration branch
- Set repo-local Git safety settings for Windows, including `core.filemode=false`

### Feature branch 1: buildout checklist
- Branch: `feature/az204-buildout-checklist`
- Added build plan file: `docs/program/az204-buildout-checklist.md`
- Scaffolded first AZ-204 learning path:
  - `learning-paths/az204-lp01-develop-azure-compute-solutions/`
- Merged intentionally through `upstream/main`
- Synced the AZ-204 fork so both `main` and `develop` point to commit `81490ad`
- Deleted the old feature branch from `origin`

### Feature branch 2: taxonomy and LP02
- Branch: `feature/az204-taxonomy-lp02`
- Added taxonomy definition file:
  - `docs/program/az204-taxonomy.md`
- Updated repo branding and curriculum direction:
  - `README.md`
  - `docs/program/curriculum-matrix.md`
  - `docs/program/az204-buildout-checklist.md`
- Scaffolded second AZ-204 learning path:
  - `learning-paths/az204-lp02-develop-for-azure-storage/`

## Recent Commits
- `b678cd5` `scaffold: add AZ-204 LP02 storage path templates`
- `1901d12` `docs: define AZ-204 taxonomy and curriculum baseline`
- `81490ad` merged baseline from earlier AZ-204 setup work

## Active AZ-204 Taxonomy
- `az204-lp01-develop-azure-compute-solutions`
- `az204-lp02-develop-for-azure-storage`
- `az204-lp03-implement-azure-security`
- `az204-lp04-monitor-troubleshoot-optimize`
- `az204-lp05-connect-consume-azure-services`

## Files to Review First
- `docs/program/az204-taxonomy.md`
- `docs/program/az204-buildout-checklist.md`
- `docs/program/curriculum-matrix.md`
- `learning-paths/az204-lp01-develop-azure-compute-solutions/README.md`
- `learning-paths/az204-lp02-develop-for-azure-storage/README.md`

## Recommended Next Steps
1. Open a pull request for `feature/az204-taxonomy-lp02` if it has not been merged yet.
2. Scaffold `az204-lp03-implement-azure-security`.
3. Replace remaining top-level AZ-104-oriented student navigation docs with AZ-204 wording and structure.
4. Convert LP01 or LP02 from scaffold status into the first fully implemented end-to-end lab path.

## Suggested Prompt For New Chat
Continue AZ-204 repo work from `docs/program/az204-handoff-summary.md`. Assume the repo already has LP01 and LP02 scaffolded, AZ-204 taxonomy defined, `origin` is the AZ-204 fork, `upstream` is the AZ-104 source repo, and the next likely task is LP03 security path scaffolding or top-level AZ-204 doc replacement.
