# Release APK for EBOMIM IMS field distribution.
# Prerequisite: populate assets/config/access_codes.json with invite codes before building.
#
# Usage (PowerShell):
#   .\scripts\build_release_apk.ps1
# Or set env SUPABASE_URL and SUPABASE_ANON_KEY first.

param(
    [string] $SupabaseUrl = $env:SUPABASE_URL,
    [string] $SupabaseAnonKey = $env:SUPABASE_ANON_KEY
)

$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

if (-not $SupabaseUrl -or -not $SupabaseAnonKey) {
    Write-Error "Set SUPABASE_URL and SUPABASE_ANON_KEY (environment or script parameters)."
}

flutter build apk --release `
    --dart-define=SUPABASE_URL=$SupabaseUrl `
    --dart-define=SUPABASE_ANON_KEY=$SupabaseAnonKey

Write-Host "Output: build\app\outputs\flutter-apk\app-release.apk"
