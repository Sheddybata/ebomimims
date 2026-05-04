# Run the Flutter app with Supabase from mobile/dart_defines.env
# Setup: copy ..\dart_defines.example.env to ..\dart_defines.env and fill values.

$ErrorActionPreference = "Stop"
$mobile = Split-Path $PSScriptRoot
$envFile = Join-Path $mobile "dart_defines.env"

if (-not (Test-Path $envFile)) {
    Write-Error "Missing $envFile — copy dart_defines.example.env to dart_defines.env and set SUPABASE_URL and SUPABASE_ANON_KEY."
}

Set-Location $mobile
flutter run --dart-define-from-file=dart_defines.env
