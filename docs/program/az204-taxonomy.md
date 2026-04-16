# AZ-204 Taxonomy and Migration Map

## Objective
Define the active AZ-204 learning path structure and show how the existing AZ-104 source material can be reused during migration.

## Target Learning Paths

### LP01: Develop Azure Compute Solutions
- Folder: `learning-paths/az204-lp01-develop-azure-compute-solutions`
- Focus: App Service, Azure Functions, container-hosted compute, deployment slots, release workflows

### LP02: Develop for Azure Storage
- Folder: `learning-paths/az204-lp02-develop-for-azure-storage`
- Focus: Blob Storage integration, Cosmos DB usage patterns, storage SDK usage, data lifecycle design

### LP03: Implement Azure Security
- Folder: `learning-paths/az204-lp03-implement-azure-security`
- Focus: managed identity, Key Vault, app authentication/authorization, secure configuration and secrets handling

### LP04: Monitor, Troubleshoot, and Optimize Azure Solutions
- Folder: `learning-paths/az204-lp04-monitor-troubleshoot-optimize`
- Focus: Application Insights, Log Analytics, distributed tracing, resilience, performance tuning, remediation workflows

### LP05: Connect to and Consume Azure Services and Third-Party Services
- Folder: `learning-paths/az204-lp05-connect-consume-azure-services`
- Focus: API Management, Event Grid, Event Hubs, Service Bus, external integrations, message-driven application patterns

## Naming Convention
- Learning paths: `az204-lp0X-<topic>`
- Modules: `m0X-<topic>`
- Labs: `lab-0X-<scenario>`
- Validation scripts: `az204-lp0X-validate.ps1`

## Source Material Reuse Map

| Legacy Source Area | Reuse Direction in AZ-204 |
|---|---|
| `lp02-storage-management` | storage SDK workflows, data protection scenarios, lifecycle and access patterns |
| `lp03-compute-resources` | App Service and compute deployment mechanics |
| `lp05-monitor-backup` | monitoring, alerting, diagnostics, remediation workflows |
| `lp01-identity-governance` | identity and RBAC concepts adapted to app authentication and managed identity |
| `lp04-virtual-networks` | service connectivity, private endpoints, network troubleshooting where app-relevant |

## Migration Rules
- Treat the AZ-104 folders as source material, not as the final AZ-204 taxonomy
- Keep new AZ-204 learning paths isolated under `learning-paths/az204-*`
- Rewrite administrator-centric language into developer and application scenarios
- Prefer lab flows that validate application behavior, not just resource creation

## Current Status
- LP01 is scaffolded
- LP02 is scaffolded
- LP03 through LP05 are planned but not yet scaffolded
