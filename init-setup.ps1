#!/usr/bin/env pwsh
# ============================================================
# Versace HRMS - Local Setup Script
# ============================================================

$ErrorActionPreference = "Stop"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

$ProjectRoot = Get-Location

Write-Host ""
Write-Host "=== Versace HRMS - Local Setup ===" -ForegroundColor Cyan
Write-Host "============================================================"

# 1. .env Logic
Write-Host "[1/6] Config check..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
}
$content = Get-Content ".env"
$content = $content -replace 'localhost', '127.0.0.1'
$content | Set-Content ".env"

# Parse .env
$dbPass = "jayking46"
Get-Content ".env" | ForEach-Object {
    if ($_ -match "^POSTGRES_PASSWORD=(.*)$") { $dbPass = $Matches[1].Trim() }
}

# 2. Database
Write-Host "[2/6] Database check..." -ForegroundColor Yellow
$conn = "postgresql://postgres:$($dbPass)@127.0.0.1:5432/postgres"
try {
    $exists = psql -w "$conn" -tAc "SELECT 1 FROM pg_database WHERE datname='hrms_db'"
    if ($exists -ne "1") {
        psql -w "$conn" -c "CREATE DATABASE hrms_db"
    }
} catch {
    Write-Host "CRITICAL: Postgres Connection Failed! Check password/server." -ForegroundColor Red
    exit 1
}

# 3. Backend
Write-Host "[3/6] Backend setup..." -ForegroundColor Yellow
cd backend
if (-not (Test-Path "venv")) { python -m venv venv }
.\venv\Scripts\python.exe -m pip install --upgrade pip
.\venv\Scripts\python.exe -m pip install -r requirements.txt
cd ..

# 4. Frontend
Write-Host "[4/6] Frontend setup..." -ForegroundColor Yellow
cd frontend
if (-not (Test-Path "node_modules")) { npm install }
cd ..

# 5. Migrations
Write-Host "[5/6] Migrations..." -ForegroundColor Yellow
cd backend
$env:PYTHONPATH = "."
# Ensure versions dir exists
if (-not (Test-Path "migrations/versions")) { New-Item -ItemType Directory -Path "migrations/versions" }
# Generate if empty
$files = Get-ChildItem "migrations/versions" -Filter "*.py"
if (-not $files) {
    .\venv\Scripts\python.exe -m alembic revision --autogenerate -m "Initial"
}
# Upgrade
.\venv\Scripts\python.exe -m alembic upgrade head
if ($LASTEXITCODE -ne 0) { Write-Host "Migration Failed!" -ForegroundColor Red; exit 1 }
cd ..

# 6. Seed
Write-Host "[6/6] Seeding..." -ForegroundColor Yellow
$env:PYTHONPATH = ".;backend"
.\backend\venv\Scripts\python.exe scripts/seed.py
if ($LASTEXITCODE -ne 0) { Write-Host "Seeding Failed!" -ForegroundColor Red; exit 1 }

Write-Host "`nSetup Successful!" -ForegroundColor Green
