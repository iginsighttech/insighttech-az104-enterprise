# Changelog

## v1.0.0
- Initial enterprise scaffolding (Governance + CI + Templates)
- Shared folder skeleton (Bicep + scripts + standards)
- LP01 skeleton + M01 module template filled
- Beginner Lab-01 populated

## v1.1.0
- Added Domain 1 enterprise enhancements (playbooks + intermediate/advanced labs)
- Added tag compliance reporting scripts (PowerShell + CLI)

## v1.2.0
- Completed Domain 1 (LP01) modules M02–M04 with labs, code, validation, and references
- Added LP01 masterclass content (CLI/PowerShell/Bicep/Portal)
- Added full LP01 practice exam (50Q) with answer key and official references
- Added LP01 umbrella validation runner

## v1.3.0 — 2026-04-15

### Content — LP02 Storage Management
- Populated beginner lab-01 (Storage Account Foundations) with StorageV2, HTTPS-only, TLS 1.2 content
- Populated beginner lab-03 (Azure Files and Sync) with Files share creation, soft-delete configuration
- Populated intermediate lab-01 (Storage Operations Runbook) with container lifecycle, blob tier, SAS token tasks
- Populated intermediate lab-05 (Storage Compliance Reporting) with HTTPS, TLS, public access, soft-delete controls
- Populated advanced lab-02 (Storage Least-Privilege Design) and lab-03 (Cross-Subscription Storage Governance)
- Updated LP02 README with current module and lab coverage summary

### Content — LP03 Compute Resources
- Populated beginner lab-01 (VM Foundations) with Ubuntu VM deployment, managed disks, power state verification
- Populated beginner lab-03 (App Service Basics) with App Service plan, web app, application settings
- Populated intermediate lab-01 (VM Operations Runbook) with stop/start, managed disk attach/detach tasks
- Populated intermediate lab-05 (Compute Compliance Report) with managed disks, patch mode, boot diagnostics controls
- Populated advanced lab-02 (Compute Least-Privilege Design) and lab-03 (Cross-Subscription Compute Governance)
- Updated LP03 README with current module and lab coverage summary

### Content — LP04 Virtual Networks
- Populated beginner lab-01 (VNet Foundations) with VNet + dual-subnet creation, address space verification
- Populated beginner lab-03 (Load Balancing and DNS) with Standard LB, health probe, load-balancing rule
- Populated intermediate lab-01 (Subnet and NSG Operations) with VNet/subnet create, NSG rule ordering, subnet association
- Populated intermediate lab-05 (Network Compliance Report) with NSG-per-subnet, Network Watcher, CIDR overlap controls
- Populated advanced lab-02 (Network Least-Privilege Design) and lab-03 (Cross-Subscription Network Governance)
- Updated LP04 README with current module and lab coverage summary

### Content — LP05 Monitor and Backup
- Populated beginner lab-01 (Monitor Foundations) with Log Analytics workspace, activity log diagnostic settings
- Populated beginner lab-03 (Backup Vault and Policy) with Recovery Services vault, backup policy, VM protection
- Populated intermediate lab-01 (Log Analytics Queries) with workspace creation, KQL heartbeat/CPU queries, diagnostic settings
- Populated intermediate lab-05 (Monitoring Compliance Report) with diagnostic settings, Sev0/1 alerts, backup policy, agent heartbeat controls
- Populated advanced lab-02 (Monitoring Least-Privilege Design) and lab-03 (Cross-Subscription Monitoring Governance)
- Updated LP05 README with current module and lab coverage summary

### Drift Remediation
- Replaced LP01 identity-governance content copy-forwarded into LP02–LP05 beginner lab-01 and lab-03 files across all four learning paths (8 files corrected)
- Replaced duplicate intermediate lab-01 and lab-05 template content across LP02–LP05 (8 files corrected)

### Scripts
- Added `scripts/lint-markdown.sh` — runs markdownlint locally via npx or pymarkdownlnt (no container required)
- Added `scripts/scan-secrets.sh` — runs secret scanning via gitleaks binary or detect-secrets (no container required)

### Infrastructure
- Updated CODEOWNERS with domain-specific ownership assignments for LP02–LP05
- Bicep modules compile cleanly across all learning paths (verified with `az bicep build`)
