param(
    [switch]$RemoveOnly
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$addonTarget = "D:\Games\World of Warcraft\_anniversary_\Interface\AddOns\Hekili_TBC"
$source = $repoRoot

if (-not $RemoveOnly) {
    Write-Host "Bootstrapping embedded libraries..."
    & (Join-Path $PSScriptRoot "bootstrap_libs.ps1")
}

if (Test-Path $addonTarget) {
    Write-Host "Removing existing path: $addonTarget"
    Remove-Item -LiteralPath $addonTarget -Force
}

if (-not $RemoveOnly) {
    Write-Host "Creating junction:"
    Write-Host "  $addonTarget -> $source"
    New-Item -ItemType Junction -Path $addonTarget -Target $source | Out-Null
}

Write-Host ""
Write-Host "Next steps:"
Write-Host "1) Launch WoW TBC Anniversary."
Write-Host "2) Ensure addon 'Hekili_TBC' is enabled."
Write-Host "3) Run /reload."
