# InSight Technologies — AZ-204 Enterprise Training

This repository is the enterprise training workspace for Microsoft **AZ-204: Developing Solutions for Microsoft Azure**.

## Program focus
- App-centric, exam-aligned AZ-204 learning paths
- Enterprise delivery model carried forward from the AZ-104 program
- Repeatable labs with validation, remediation, and instructor-ready guidance
- Shared templates, scripts, and infrastructure artifacts reused across paths

## Active AZ-204 taxonomy
- `az204-lp01-develop-azure-compute-solutions`
- `az204-lp02-develop-for-azure-storage`
- `az204-lp03-implement-azure-security`
- `az204-lp04-monitor-troubleshoot-optimize`
- `az204-lp05-connect-consume-azure-services`

See `docs/program/az204-taxonomy.md` for the target domain model and migration mapping.

## Migration status
- `az204-lp01-develop-azure-compute-solutions` is scaffolded
- `az204-lp02-develop-for-azure-storage` is scaffolded
- legacy `lp01-` through `lp06-` folders remain as source material during the AZ-204 conversion

## Student workflow (high-level)
1. Read `docs/program/cohort-guide.md`
2. Work in branches; do not push directly to `main`
3. Build new modules and labs from `shared/templates/`
4. Submit pull requests with validation evidence and instructor notes where required

## Security
- No secrets in this repo
- Students should use interactive auth (`az login`, `Connect-AzAccount`)
- Instructor automation should use GitHub OIDC or repository secrets where needed

## Repo layout
- `docs/program/` for governance, curriculum planning, and delivery standards
- `docs/architecture/` for program architecture and supporting design views
- `shared/` for reusable templates, scripts, and infrastructure assets
- `learning-paths/` for active AZ-204 paths and legacy source material under migration
