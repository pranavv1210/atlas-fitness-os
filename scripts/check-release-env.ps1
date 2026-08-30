param(
  [string]$EnvFile = "config/env/atlas.local.json"
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $repoRoot

$requiredKeys = @(
  "SUPABASE_URL",
  "SUPABASE_ANON_KEY",
  "GOOGLE_WEB_CLIENT_ID"
)

if (-not (Test-Path -LiteralPath $EnvFile)) {
  throw "Missing $EnvFile. Create it from config/env/atlas.example.json."
}

$config = Get-Content -Raw -LiteralPath $EnvFile | ConvertFrom-Json
$missing = @()
foreach ($key in $requiredKeys) {
  $value = $config.$key
  if ($null -eq $value -or [string]::IsNullOrWhiteSpace([string]$value) -or [string]$value -like "your-*") {
    $missing += $key
  }
}

if ($missing.Count -gt 0) {
  throw "Missing or placeholder release keys: $($missing -join ', ')."
}

Write-Host "Release env is valid: $EnvFile"
