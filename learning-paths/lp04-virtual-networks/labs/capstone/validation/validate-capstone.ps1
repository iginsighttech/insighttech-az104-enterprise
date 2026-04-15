#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Capstone Lab Validation Script
    Validates all LP04 capstone deliverables and reports PASS/FAIL/SKIP

.DESCRIPTION
    Runs comprehensive checks on capstone lab outputs:
    - RBAC assignments
    - Policy assignments
    - Budget configuration
    - Break-glass audit log
    - Compliance reports

.EXAMPLE
    .\\validate-capstone.ps1
    .\\validate-capstone.ps1 -Debug

.NOTES
    Author: InSight Technologies Training
    Requires: Azure PowerShell (Az) module, Git
#>

param(
    [switch]$Debug = $false
)

# Configuration
$CapstoneDir = "$PSScriptRoot/.."
$ErrorActionPreference = "Stop"
$Score = 0
$TotalChecks = 25

# Helper functions
function Pass($msg) {
    Write-Host "✅ PASS: $msg" -ForegroundColor Green
    $script:Score++
}

function Fail($msg) {
    Write-Host "❌ FAIL: $msg" -ForegroundColor Red
}

function Skip($msg) {
    Write-Host "⏭️  SKIP: $msg" -ForegroundColor Yellow
}

function Debug($msg) {
    if ($Debug) {
        Write-Host "🔍 DEBUG: $msg" -ForegroundColor Cyan
    }
}

function Section($title) {
    Write-Host ""
    Write-Host "═══════════════════════════════════" -ForegroundColor Cyan
    Write-Host "$title" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════" -ForegroundColor Cyan
}

# =============================================================================
# PART A: RBAC Architecture Validation
# =============================================================================
Section "PART A: RBAC Architecture"

# Check A1: RBAC assignments file exists
if (Test-Path "$CapstoneDir/evidence/rbac-assignments.json") {
    try {
        $rbacJson = Get-Content "$CapstoneDir/evidence/rbac-assignments.json" | ConvertFrom-Json
        Pass "RBAC assignments JSON file exists and is parseable"
        Debug "Found $($rbacJson.Count) role assignments"
    }
    catch {
        Fail "RBAC assignments JSON is not valid: $_"
    }
}
else {
    Fail "Missing: $CapstoneDir/evidence/rbac-assignments.json"
}

# Check A2: RBAC diagram exists
if (Test-Path "$CapstoneDir/diagrams/rbac-architecture.md") {
    $diagramContent = Get-Content "$CapstoneDir/diagrams/rbac-architecture.md" -Raw
    if ($diagramContent.Length -gt 100) {
        Pass "RBAC architecture diagram exists and has content"
    }
    else {
        Fail "RBAC architecture diagram is empty or too short"
    }
}
else {
    Fail "Missing: $CapstoneDir/diagrams/rbac-architecture.md"
}

# Check A3: RBAC rationale document
if (Test-Path "$CapstoneDir/rationale/rbac-design-rationale.md") {
    $rationale = Get-Content "$CapstoneDir/rationale/rbac-design-rationale.md" -Raw
    if ($rationale -match "least.privilege|minimum.privilege|scope" -and $rationale.Length -gt 300) {
        Pass "RBAC design rationale exists and discusses least-privilege principle"
    }
    else {
        Fail "RBAC design rationale is missing or too short (need >300 chars mentioning least-privilege)"
    }
}
else {
    Fail "Missing: $CapstoneDir/rationale/rbac-design-rationale.md"
}

# Check A4: RBAC validation passed
if (Test-Path "$CapstoneDir/evidence/rbac-validation.txt") {
    $rbacValidation = Get-Content "$CapstoneDir/evidence/rbac-validation.txt" -Raw
    if ($rbacValidation -match "PASS|VERIFIED" -and $rbacValidation.Length -gt 50) {
        Pass "RBAC validation evidence file present"
    }
    else {
        Fail "RBAC validation file exists but shows no validation passed"
    }
}
else {
    Skip "RBAC validation evidence (optional - can be manual test output)"
}

# =============================================================================
# PART B: Policy & Compliance Validation
# =============================================================================
Section "PART B: Policy & Compliance"

# Check B1: Tag policy file
if (Test-Path "$CapstoneDir/policies/tag-policy-definitions.json") {
    try {
        $tagPolicy = Get-Content "$CapstoneDir/policies/tag-policy-definitions.json" | ConvertFrom-Json
        if ($tagPolicy.properties.displayName -match "tag|Tag" -or $tagPolicy[0].properties.displayName -match "tag|Tag") {
            Pass "Tag policy definition file exists and is valid JSON"
        }
    }
    catch {
        Fail "Tag policy JSON is not valid: $_"
    }
}
else {
    Fail "Missing: $CapstoneDir/policies/tag-policy-definitions.json"
}

# Check B2: Location policy file
if (Test-Path "$CapstoneDir/policies/location-policy.json") {
    try {
        $locPolicy = Get-Content "$CapstoneDir/policies/location-policy.json" | ConvertFrom-Json
        Pass "Location policy definition file exists and is valid JSON"
    }
    catch {
        Fail "Location policy JSON is not valid: $_"
    }
}
else {
    Fail "Missing: $CapstoneDir/policies/location-policy.json"
}

# Check B3: Storage policy file
if (Test-Path "$CapstoneDir/policies/storage-policy.json") {
    try {
        $storPolicy = Get-Content "$CapstoneDir/policies/storage-policy.json" | ConvertFrom-Json
        Pass "Storage policy definition file exists and is valid JSON"
    }
    catch {
        Fail "Storage policy JSON is not valid: $_"
    }
}
else {
    Fail "Missing: $CapstoneDir/policies/storage-policy.json"
}

# Check B4: Policy assignments evidence
if (Test-Path "$CapstoneDir/evidence/policy-assignments.txt") {
    $assignments = Get-Content "$CapstoneDir/evidence/policy-assignments.txt" -Raw
    if ($assignments.Length -gt 100) {
        Pass "Policy assignments evidence file present"
        Debug "Policy assignments length: $($assignments.Length)"
    }
    else {
        Fail "Policy assignments evidence file is too short"
    }
}
else {
    Fail "Missing: $CapstoneDir/evidence/policy-assignments.txt"
}

# Check B5: Compliance report
if (Test-Path "$CapstoneDir/evidence/compliance-report.json") {
    try {
        $compliance = Get-Content "$CapstoneDir/evidence/compliance-report.json" | ConvertFrom-Json
        Pass "Compliance report JSON file exists and is parseable"
    }
    catch {
        Fail "Compliance report JSON is not valid: $_"
    }
}
else {
    Fail "Missing: $CapstoneDir/evidence/compliance-report.json"
}

# Check B6: Remediation log
if (Test-Path "$CapstoneDir/evidence/compliance-remediation-log.txt") {
    $remedLog = Get-Content "$CapstoneDir/evidence/compliance-remediation-log.txt" -Raw
    if ($remedLog.Length -gt 100) {
        Pass "Compliance remediation log present"
        Debug "Remediation log length: $($remedLog.Length)"
    }
    else {
        Fail "Compliance remediation log is empty or too short"
    }
}
else {
    Fail "Missing: $CapstoneDir/evidence/compliance-remediation-log.txt"
}

# Check B7: Policy exemption justification
if (Test-Path "$CapstoneDir/rationale/policy-exemption-justification.md") {
    $exemptDoc = Get-Content "$CapstoneDir/rationale/policy-exemption-justification.md" -Raw
    if ($exemptDoc.Length -gt 200) {
        Pass "Policy exemption justification document present"
    }
    else {
        Skip "Policy exemption justification is very short (may have no exemptions)"
    }
}
else {
    Skip "Policy exemption justification document (optional if no exemptions)"
}

# =============================================================================
# PART C: Cost Management Validation
# =============================================================================
Section "PART C: Cost Management"

# Check C1: Budgets created
if (Test-Path "$CapstoneDir/evidence/budgets-created.txt") {
    $budgets = Get-Content "$CapstoneDir/evidence/budgets-created.txt" -Raw
    if ($budgets -match "Budget|budget" -and $budgets.Length -gt 50) {
        Pass "Budgets created evidence file present"
        Debug "Budgets file length: $($budgets.Length)"
    }
    else {
        Fail "Budgets evidence file shows no budgets found"
    }
}
else {
    Fail "Missing: $CapstoneDir/evidence/budgets-created.txt"
}

# Check C2: Budget alerts configured
if (Test-Path "$CapstoneDir/evidence/budget-alerts-configured.txt") {
    $alerts = Get-Content "$CapstoneDir/evidence/budget-alerts-configured.txt" -Raw
    if ($alerts.Length -gt 50) {
        Pass "Budget alerts configuration evidence present"
    }
    else {
        Fail "Budget alerts evidence is empty or insufficient"
    }
}
else {
    Fail "Missing: $CapstoneDir/evidence/budget-alerts-configured.txt"
}

# Check C3: Cost analysis by tag
if (Test-Path "$CapstoneDir/evidence/cost-analysis-by-costcenter-tag.csv") {
    $costCsv = Get-Content "$CapstoneDir/evidence/cost-analysis-by-costcenter-tag.csv" -Raw
    if ($costCsv -match "CostCenter|cost" -and $costCsv.Length -gt 100) {
        Pass "Cost analysis by CostCenter tag present"
    }
    else {
        Fail "Cost analysis CSV does not contain CostCenter data"
    }
}
else {
    Fail "Missing: $CapstoneDir/evidence/cost-analysis-by-costcenter-tag.csv"
}

# Check C4: Advisor recommendations
if (Test-Path "$CapstoneDir/rationale/advisor-recommendations.md") {
    $advisorDoc = Get-Content "$CapstoneDir/rationale/advisor-recommendations.md" -Raw
    if ($advisorDoc -match "Accepted|Deferred|Rejected|recommendation" -and $advisorDoc.Length -gt 300) {
        Pass "Advisor recommendations document present with decisions"
    }
    else {
        Fail "Advisor recommendations document missing decisions or too short"
    }
}
else {
    Fail "Missing: $CapstoneDir/rationale/advisor-recommendations.md"
}

# =============================================================================
# PART D: Break-Glass & Incident Response Validation
# =============================================================================
Section "PART D: Break-Glass & Incident Response"

# Check D1: Break-glass runbook
if (Test-Path "$CapstoneDir/runbooks/break-glass-access-procedure.md") {
    $runbook = Get-Content "$CapstoneDir/runbooks/break-glass-access-procedure.md" -Raw
    if ($runbook -match "request|grant|revoke|audit" -and $runbook.Length -gt 300) {
        Pass "Break-glass runbook present and documented"
    }
    else {
        Fail "Break-glass runbook is missing key sections or too short"
    }
}
else {
    Fail "Missing: $CapstoneDir/runbooks/break-glass-access-procedure.md"
}

# Check D2: Break-glass activity log
if (Test-Path "$CapstoneDir/evidence/break-glass-activity-log.txt") {
    $breakLog = Get-Content "$CapstoneDir/evidence/break-glass-activity-log.txt" -Raw
    if ($breakLog -match "assignment|role|time" -and $breakLog.Length -gt 100) {
        Pass "Break-glass activity log present with audit entries"
    }
    else {
        Skip "Break-glass activity log present but may not contain test events"
    }
}
else {
    Skip "Break-glass activity log (optional - demonstrates real incident)"
}

# =============================================================================
# PART E: Validation & Self-Assessment
# =============================================================================
Section "PART E: Validation & Self-Assessment"

# Check E1: Completion checklist
if (Test-Path "$CapstoneDir/evidence/capstone-completion-checklist.md") {
    $checklist = Get-Content "$CapstoneDir/evidence/capstone-completion-checklist.md" -Raw
    if ($checklist -match "✅|\\[x\\]" -and $checklist.Length -gt 200) {
        $checkCount = ([regex]::Matches($checklist, "✅|\\[x\\]")).Count
        Pass "Capstone completion checklist present with $checkCount items checked"
    }
    else {
        Fail "Capstone completion checklist exists but has few or no items marked complete"
    }
}
else {
    Fail "Missing: $CapstoneDir/evidence/capstone-completion-checklist.md"
}

# Check E2: Reflection document
if (Test-Path "$CapstoneDir/reflection/learnings.md") {
    $reflection = Get-Content "$CapstoneDir/reflection/learnings.md" -Raw
    $wordCount = ($reflection -split '\\s+').Count
    if ($wordCount -ge 250 -and $reflection -match "complex|difficult|scale|enterprise") {
        Pass "Reflection document present ($wordCount words) with thoughtful insights"
    }
    elseif ($wordCount -ge 250) {
        Pass "Reflection document present but light on specific examples"
    }
    else {
        Fail "Reflection document is too short (need ≥250 words, found $wordCount)"
    }
}
else {
    Fail "Missing: $CapstoneDir/reflection/learnings.md"
}

# Check E3: No secrets in files
$secretPatterns = @(
    '(key|secret|password|token|credential)\\s*=\\s*["\\']?[A-Za-z0-9]{8,}'
)

$secretsFound = $false
Get-ChildItem -Path "$CapstoneDir" -Recurse -Include *.json, *.ps1, *.md | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
    foreach ($pattern in $secretPatterns) {
        if ($content -match $pattern) {
            Fail "Potential secret found in: $($_.Name)"
            $secretsFound = $true
        }
    }
}

if (-not $secretsFound) {
    Pass "No obvious secrets detected in capstone files"
}

# =============================================================================
# FINAL SUMMARY
# =============================================================================
Section "FINAL SUMMARY"

Write-Host ""
Write-Host "Validation Score: $Score / $TotalChecks" -ForegroundColor Cyan
$percentage = [math]::Round(($Score / $TotalChecks) * 100, 1)
Write-Host "Percentage: $percentage%" -ForegroundColor Cyan

if ($percentage -ge 85) {
    Write-Host "✅ CAPSTONE READY FOR FINAL REVIEW" -ForegroundColor Green -BackgroundColor Black
}
elseif ($percentage -ge 70) {
    Write-Host "⚠️  CAPSTONE MOSTLY COMPLETE - Address failing checks above" -ForegroundColor Yellow -BackgroundColor Black
}
else {
    Write-Host "❌ CAPSTONE NEEDS MORE WORK - Complete missing deliverables" -ForegroundColor Red -BackgroundColor Black
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Address any FAIL items above"
Write-Host "2. Commit changes: git add . && git commit -m 'capstone: complete deliverables'"
Write-Host "3. Push branch: git push origin lp04-capstone-{yourname}"
Write-Host "4. Open PR for instructor review"
Write-Host ""

exit 0

