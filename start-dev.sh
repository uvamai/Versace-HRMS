#!/bin/bash
# ============================================================
# Versace HRMS - Linux/Mac Development Startup Script
# ============================================================

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║     Versace HRMS - Local Development Setup             ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Check if PostgreSQL is running
echo "[1/4] Checking PostgreSQL..."
if psql -U postgres -c "SELECT 1" &> /dev/null; then
    echo "✓ PostgreSQL is running"
else
    echo "✗ PostgreSQL not running! Please start PostgreSQL first."
    echo ""
    echo "Start PostgreSQL via:"
    echo "  macOS: brew services start postgresql"
    echo "  Linux: sudo systemctl start postgresql"
    exit 1
fi

# Check Redis
echo ""
echo "[2/4] Checking Redis..."
if redis-cli ping &> /dev/null; then
    echo "✓ Redis is running"
else
    echo "⚠ Redis not found locally. Starting Docker Redis..."
    if docker ps | grep -q "hrms_redis"; then
        echo "✓ Docker Redis is already running"
    else
        if docker run -d --name hrms_redis -p 6379:6379 redis:7-alpine &> /dev/null; then
            echo "✓ Docker Redis started"
        else
            echo "✗ Could not start Redis. Please install Redis or Docker."
            exit 1
        fi
    fi
fi

# Backend
echo ""
echo "[3/4] Starting Backend (FastAPI) on port 8000..."
cd "$(dirname "$0")/backend"
source venv/bin/activate
uvicorn app.main:app --reload --port 8000 &
BACKEND_PID=$!

# Frontend
echo ""
echo "[4/4] Starting Frontend (Vue 3) on port 5173..."
cd "$(dirname "$0")/frontend"
npm run dev &
FRONTEND_PID=$!

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║  ✓ All services starting...                            ║"
echo "║  Backend:  http://localhost:8000                       ║"
echo "║  Frontend: http://localhost:5173                       ║"
echo "║  API Docs: http://localhost:8000/docs                 ║"
echo "║                                                        ║"
echo "║  Login: admin@versace-hrms.local / Admin1234!         ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

wait
