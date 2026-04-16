param(
    [string]$ResourceGroupName,
    [string]$StorageAccountName,
    [string]$CosmosAccountName
)

$errors = @()

if (-not $ResourceGroupName) {
    $errors += "ResourceGroupName is required."
}

if (-not $StorageAccountName) {
    $errors += "StorageAccountName is required."
}

if (-not $CosmosAccountName) {
    $errors += "CosmosAccountName is required."
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Host "[ERROR] $_" -ForegroundColor Red }
    exit 1
}

Write-Host "[INFO] AZ-204 LP02 validation started." -ForegroundColor Cyan
Write-Host "[INFO] Resource Group: $ResourceGroupName"
Write-Host "[INFO] Storage Account: $StorageAccountName"
Write-Host "[INFO] Cosmos DB Account: $CosmosAccountName"
Write-Host "[WARN] Validation checks are scaffolding placeholders and should be replaced as labs are finalized." -ForegroundColor Yellow
Write-Host "[PASS] Validation script executed." -ForegroundColor Green
