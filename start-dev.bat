@echo off
REM ============================================================
REM Versace HRMS - Windows Development Startup Script
REM ============================================================

set ROOT_DIR=%~dp0
cd /d "%ROOT_DIR%"

echo.
echo ------------------------------------------------------------
echo      Versace HRMS - Local Development                       
echo ------------------------------------------------------------
echo.

REM Check if .env exists
if not exist ".env" (
    echo ERROR: .env file not found. Please run init-setup.bat first.
    pause
    exit /b 1
)

REM Try to read config from .env
set PGPASSWORD=jayking46
for /f "tokens=2 delims==" %%a in ('findstr /b "POSTGRES_PASSWORD=" .env') do set PGPASSWORD=%%a
set ADMIN_EMAIL=admin@versace.com
for /f "tokens=2 delims==" %%a in ('findstr /b "DEFAULT_SUPER_ADMIN_EMAIL=" .env') do set ADMIN_EMAIL=%%a
set ADMIN_PASS=admin@1234
for /f "tokens=2 delims==" %%a in ('findstr /b "DEFAULT_SUPER_ADMIN_PASSWORD=" .env') do set ADMIN_PASS=%%a

REM Check if PostgreSQL is running
echo [1/3] Checking PostgreSQL...
psql -h 127.0.0.1 -U postgres -d postgres -w -c "SELECT 1" >nul 2>&1
if %errorlevel% equ 0 (
    echo OK: PostgreSQL is running
) else (
    echo ERROR: PostgreSQL not responding or password incorrect!
    pause
    exit /b 1
)

REM Start Backend
echo.
echo Starting Backend (FastAPI) on port 8000...
if not exist "backend\venv" (
    echo ERROR: Backend venv not found.
    pause
    exit /b 1
)

cd backend
start "Backend - Versace HRMS" cmd /k "venv\Scripts\python.exe -m uvicorn app.main:app --reload --port 8000 --host 127.0.0.1"
cd ..

timeout /t 3 /nobreak

REM Start Frontend
echo.
echo Starting Frontend (Vue 3) on port 5173...
if not exist "frontend\node_modules" (
    echo ERROR: Frontend node_modules not found.
    pause
    exit /b 1
)

cd frontend
start "Frontend - Versace HRMS" cmd /k "npm run dev -- --host 127.0.0.1"
cd ..

echo.
echo ------------------------------------------------------------
echo   Services Starting!
echo   Backend:  http://127.0.0.1:8000
echo   Frontend: http://127.0.0.1:5173
echo   API Docs: http://127.0.0.1:8000/docs
echo.
echo   Login: %ADMIN_EMAIL% / %ADMIN_PASS%
echo ------------------------------------------------------------
echo.
pause
