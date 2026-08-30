param(
  [string]$EnvFile = "config/env/atlas.local.json",
  [string]$OutputApk = "landing/public/downloads/atlas-release.apk"
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
  throw "Missing $EnvFile. Create it from config/env/atlas.example.json before building a release APK."
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
  throw "Release APK config is incomplete. Missing or placeholder keys: $($missing -join ', ')."
}

Write-Host "Building release APK with Dart defines from $EnvFile..."

$buildLog = New-TemporaryFile
try {
  & flutter build apk --release "--dart-define-from-file=$EnvFile" *> $buildLog
  $buildExitCode = $LASTEXITCODE

  if ($buildExitCode -ne 0) {
    $safeLog = (Get-Content -Raw -LiteralPath $buildLog) `
      -replace "-Pdart-defines=[^\s]+", "-Pdart-defines=<redacted>"
    Write-Host $safeLog
    throw "Flutter release build failed with exit code $buildExitCode."
  }
} finally {
  Remove-Item -LiteralPath $buildLog -Force -ErrorAction SilentlyContinue
}

$builtApk = "build/app/outputs/flutter-apk/app-release.apk"
if (-not (Test-Path -LiteralPath $builtApk)) {
  throw "Flutter reported success, but $builtApk was not created."
}

$outputDir = Split-Path -Parent $OutputApk
if (-not (Test-Path -LiteralPath $outputDir)) {
  New-Item -ItemType Directory -Path $outputDir | Out-Null
}

Copy-Item -LiteralPath $builtApk -Destination $OutputApk -Force

$apk = Get-Item -LiteralPath $OutputApk
if ($apk.Length -le 0) {
  throw "Copied APK is empty: $OutputApk"
}

Write-Host "Release APK built with Dart defines from $EnvFile"
Write-Host "Copied $($apk.Length) bytes to $OutputApk"
