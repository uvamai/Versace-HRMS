@echo off
REM ============================================================
REM Versace HRMS - Automated Setup & Start Script (Batch)
REM ============================================================

echo Starting Automated Setup...
call init-setup.bat

if %errorlevel% neq 0 (
    echo Setup failed!
    pause
    exit /b 1
)

echo Setup successful. Starting application...
call start-dev.bat
