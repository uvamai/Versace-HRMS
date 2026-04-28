#!/usr/bin/env pwsh
# ============================================================
# Versace HRMS - Automated Setup & Start Script
# ============================================================

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

Write-Host "Starting Automated Setup..." -ForegroundColor Cyan
.\init-setup.ps1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Setup failed! Please check the errors above." -ForegroundColor Red
    exit 1
}

Write-Host "`nSetup successful. Starting application..." -ForegroundColor Green
.\start-dev.ps1
