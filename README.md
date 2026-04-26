# Versace HRMS

> Modern, scalable, open-source HR Management System — built on FastAPI + PostgreSQL + Vue 3

[![CI](https://github.com/your-org/versace-hrms/actions/workflows/ci.yml/badge.svg)](https://github.com/your-org/versace-hrms/actions)

---

## 🏗️ Architecture

| Layer | Technology |
|-------|-----------|
| **API** | Python 3.11 + FastAPI |
| **Database** | PostgreSQL 15 |
| **Cache / Queue** | Redis 7 + Celery |
| **Frontend** | Vue 3 + TypeScript + Vite |
| **Mobile** | React Native (Expo) — Phase 3 |
| **Infra** | Docker Compose |
| **CI/CD** | GitHub Actions → VPS |

---

## 🚀 Quick Start (Local Development)

### Prerequisites
- Docker Desktop
- Git

### 1. Clone and configure
```bash
git clone https://github.com/your-org/versace-hrms.git
cd versace-hrms
cp .env.example .env
# Edit .env as needed (defaults work for local dev)
```

### 2. Start the full stack
```bash
docker compose -f infra/docker-compose.yml up --build
```

### 3. Access services
| Service | URL |
|---------|-----|
| **API** | http://localhost:8000 |
| **API Docs (Swagger)** | http://localhost:8000/docs |
| **Frontend** | http://localhost:5173 |
| **pgAdmin** | http://localhost:5050 |
| **Flower (Celery)** | http://localhost:5555 |

> Start dev tools: `docker compose --profile dev up`

### 4. Run migrations
```bash
docker compose exec backend alembic upgrade head
```

### 5. Seed initial data
```bash
docker compose exec backend python scripts/seed.py
```

---

## 📁 Project Structure

```
versace-hrms/
├── .github/workflows/    # CI/CD pipelines
├── backend/              # FastAPI application
│   ├── app/
│   │   ├── modules/      # Feature modules (auth, employees, leave, ...)
│   │   └── shared/       # Shared utilities, middleware, dependencies
│   ├── migrations/       # Alembic DB migrations
│   └── tests/
├── frontend/             # Vue 3 + TypeScript
├── infra/                # Docker, Nginx, Postgres init
├── docs/                 # Architecture docs, ADRs
└── scripts/              # Seed, migrate helpers
```

---

## 🔑 Default Roles

| Role | Access |
|------|--------|
| `SUPER_ADMIN` | Full system access |
| `HR_ADMIN` | HR operations, configuration |
| `PAYROLL_OFFICER` | Payroll processing |
| `MANAGER` | Team management, approvals |
| `RECRUITER` | Recruitment pipeline |
| `EMPLOYEE` | Self-service |

---

## 🗺️ Development Phases

| Phase | Scope | Status |
|-------|-------|--------|
| **Phase 1** (Wks 1–4) | Foundation: Auth, Employees, DevOps | 🚧 In Progress |
| **Phase 2** (Wks 5–10) | Leave, Attendance, Org Structure | ⏳ Planned |
| **Phase 3** (Wks 11–18) | Performance, Payroll, Expenses, Recruitment | ⏳ Planned |
| **Phase 4** (Wks 19–24) | Mobile, Integrations, Production | ⏳ Planned |

---

## 🧪 Running Tests

```bash
# Inside container
docker compose exec backend pytest tests/ -v --cov=app

# Locally (with venv)
cd backend
pip install -r requirements.txt
pytest tests/ -v
```

---

## 🌿 Git Branching

```
main          ← Production only (tagged releases)
develop       ← Integration, deployed to staging
  └── feature/EMP-001-employee-profile
  └── fix/LEV-003-balance-calculation
  └── chore/update-deps
```

---

## 📖 API Documentation

FastAPI auto-generates interactive docs:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

---

## 🔒 Environment Variables

See [`.env.example`](.env.example) for full reference. Never commit `.env`.

---

## 📜 License

Proprietary — Versace HRMS © 2026
