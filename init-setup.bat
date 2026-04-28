@echo off
REM ============================================================
REM Versace HRMS - Local Setup Script (Batch)
REM ============================================================

set ROOT_DIR=%~dp0
cd /d "%ROOT_DIR%"

echo.
echo ============================================================
echo      Versace HRMS - Local Setup                             
echo ============================================================
echo.

REM 1. Check for .env
if not exist ".env" (
    echo [1/6] Creating .env from .env.example (and fixing localhost to 127.0.0.1)...
    powershell -Command "(Get-Content .env.example) -replace 'localhost', '127.0.0.1' | Set-Content .env"
) else (
    echo [1/6] .env file already exists. Updating localhost to 127.0.0.1 for reliability...
    powershell -Command "(Get-Content .env) -replace 'localhost', '127.0.0.1' | Set-Content .env"
)

REM 2. Database Setup
echo.
echo [2/6] Checking PostgreSQL database...

REM Read password/db from .env
set PGPASSWORD=jayking46
for /f "tokens=2 delims==" %%a in ('findstr /b "POSTGRES_PASSWORD=" .env') do set PGPASSWORD=%%a
set PGUSER=postgres
for /f "tokens=2 delims==" %%a in ('findstr /b "POSTGRES_USER=" .env') do set PGUSER=%%a
set PGDATABASE=hrms_db
for /f "tokens=2 delims==" %%a in ('findstr /b "POSTGRES_DB=" .env') do set PGDATABASE=%%a

psql -h 127.0.0.1 -U %PGUSER% -d postgres -w -tAc "SELECT 1 FROM pg_database WHERE datname='%PGDATABASE%'" > .db_exists.tmp 2>nul
set /p DB_EXISTS=<.db_exists.tmp
del .db_exists.tmp

if "%DB_EXISTS%" neq "1" (
    echo Creating database %PGDATABASE%...
    psql -h 127.0.0.1 -U %PGUSER% -d postgres -w -c "CREATE DATABASE %PGDATABASE%"
    if %errorlevel% neq 0 (
        echo ERROR: Failed to create database. Check postgres connection/password.
        pause
        exit /b 1
    )
    echo Database %PGDATABASE% created.
) else (
    echo Database %PGDATABASE% already exists.
)

REM 3. Backend Setup
echo.
echo [3/6] Setting up Backend...
cd backend
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)
echo Installing backend dependencies...
venv\Scripts\python.exe -m pip install --upgrade pip
venv\Scripts\python.exe -m pip install -r requirements.txt
cd ..

REM 4. Frontend Setup
echo.
echo [4/6] Setting up Frontend...
cd frontend
if not exist "node_modules" (
    echo Installing frontend dependencies (npm install)...
    call npm install
) else (
    echo Frontend dependencies already installed.
)
cd ..

REM 5. Database Migrations
echo.
echo [5/6] Running database migrations...
cd backend
set PYTHONPATH=.
dir migrations\versions\*.py >nul 2>&1
if %errorlevel% neq 0 (
    echo No migrations found. Generating initial migration...
    venv\Scripts\python.exe -m alembic revision --autogenerate -m "Initial migration"
)
venv\Scripts\python.exe -m alembic upgrade head
cd ..

REM 6. Seed Data
echo.
echo [6/6] Seeding initial data...
set PYTHONPATH=.;backend
backend\venv\Scripts\python.exe scripts\seed.py

echo.
echo ============================================================
echo   Setup Complete!
echo ============================================================
echo.
echo You can now run start-dev.bat to start the application.
echo.
pause
