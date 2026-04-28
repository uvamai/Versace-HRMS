"""
Versace HRMS — FastAPI Application Entry Point
"""
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware

from app.config import settings
from app.database import AsyncSessionLocal, engine, Base
from app.modules.auth.seed import create_default_roles, create_default_super_admin
from app.shared.middleware import AuditMiddleware, RequestIDMiddleware

# ── Module routers ────────────────────────────────────────────
from app.modules.auth.router import router as auth_router
from app.modules.employees.router import router as employees_router
from app.modules.leave.router import router as leave_router
from app.modules.attendance.router import router as attendance_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown lifecycle."""
    # Startup
    async with engine.begin() as conn:
        # Only create tables in dev — use Alembic in production
        if settings.APP_ENV == "development":
            await conn.run_sync(Base.metadata.create_all)
    async with AsyncSessionLocal() as session:
        await create_default_roles(session)
        await create_default_super_admin(session)
        await session.commit()
    yield
    # Shutdown
    await engine.dispose()


app = FastAPI(
    title="Versace HRMS API",
    description="Modern HR Management System — REST API",
    version="1.0.0",
    docs_url="/docs" if settings.DEBUG else None,
    redoc_url="/redoc" if settings.DEBUG else None,
    lifespan=lifespan,
)

# ── Middleware (order matters — outermost = first) ────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(GZipMiddleware, minimum_size=1000)
app.add_middleware(RequestIDMiddleware)
app.add_middleware(AuditMiddleware)

# ── API Routes ────────────────────────────────────────────────
API_PREFIX = "/api/v1"

app.include_router(auth_router, prefix=f"{API_PREFIX}/auth", tags=["Authentication"])
app.include_router(employees_router, prefix=f"{API_PREFIX}/employees", tags=["Employees"])
app.include_router(leave_router, prefix=f"{API_PREFIX}/leave", tags=["Leave Management"])
app.include_router(attendance_router, prefix=f"{API_PREFIX}/attendance", tags=["Attendance"])


# ── Health check ─────────────────────────────────────────────
@app.get("/health", tags=["System"])
async def health_check():
    return {"status": "healthy", "version": "1.0.0", "app": settings.APP_NAME}


@app.get("/", tags=["System"])
async def root():
    return {"message": "Versace HRMS API", "docs": "/docs"}
