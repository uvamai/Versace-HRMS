#!/usr/bin/env pwsh
# ============================================================
# Versace HRMS - Development Startup (CMD-Fallback)
# ============================================================

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

$ProjectRoot = Get-Location

# Kill previous
Stop-Process -Name python, uvicorn, node, npm -ErrorAction SilentlyContinue

Write-Host "`n[1/2] Starting Backend (Port 8080)..." -ForegroundColor Yellow
$BPath = Join-Path $ProjectRoot "backend"
# Use cmd /c specifically
$BArg = "/k venv\Scripts\python.exe -m uvicorn app.main:app --reload --port 8080 --host 0.0.0.0"
$BProc = Start-Process cmd -ArgumentList $BArg -WorkingDirectory $BPath -PassThru

Write-Host "[2/2] Starting Frontend (Port 3000)..." -ForegroundColor Yellow
$FPath = Join-Path $ProjectRoot "frontend"
# Use cmd /c specifically
$FArg = "/k npm run dev -- --port 3000 --host 0.0.0.0"
$FProc = Start-Process cmd -ArgumentList $FArg -WorkingDirectory $FPath -PassThru

Write-Host "`nWaiting 10s for servers to bind..."
Start-Sleep -Seconds 10

Write-Host "`n--- SELF-DIAGNOSTIC ---" -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri "http://127.0.0.1:8080/health" -UseBasicParsing -TimeoutSec 2 >$null
    Write-Host "SUCCESS: Backend is reachable at http://127.0.0.1:8080" -ForegroundColor Green
} catch {
    Write-Host "FAILURE: Backend is NOT reachable. Please check the black CMD window titled 'Backend'." -ForegroundColor Red
}

try {
    Invoke-WebRequest -Uri "http://127.0.0.1:3000" -UseBasicParsing -TimeoutSec 2 >$null
    Write-Host "SUCCESS: Frontend is reachable at http://127.0.0.1:3000" -ForegroundColor Green
} catch {
    Write-Host "FAILURE: Frontend is NOT reachable. Please check the black CMD window titled 'Frontend'." -ForegroundColor Red
}

Write-Host "`nIf both fail, please tell me EXACTLY what the black windows say."
Pause
