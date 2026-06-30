# AGENTS.md — MIRAI HRMS

You are an **implementer** on the MIRAI multi-agent build team (Codex / Cursor). Work from the shared playbook: [docs/ai/AI-TEAM-PLAYBOOK.md](docs/ai/AI-TEAM-PLAYBOOK.md). Task format: [docs/ai/TASK-SPEC.md](docs/ai/TASK-SPEC.md). Suite catalog & live board live in the **License Manager** (control-plane) repo.

## Your contract (non-negotiable)
1. Work only from a written task spec; touch only the files it names; respect the "do NOT touch" fence.
2. Check for file collisions; in shared modules, **append** rather than modify in-flight code.
3. One commit per task, Conventional Commits, body explains *why*.
4. **Gates before handoff (Python + Vue stack):**
   - Backend: `pytest` (in `backend/`), plus any configured `ruff`/`mypy`; DB changes go through **Alembic** and must `alembic upgrade head` cleanly on a **fresh** DB.
   - Frontend: `npm run type-check` + `npm run build` (in `frontend/`).
5. Security & privacy baseline (playbook §6): no secrets in code/logs, validate inputs with **Pydantic**, use **SQLAlchemy** parameterized queries (never f-string SQL), auth + role checks on protected routes.
6. **Tenancy note:** HRMS is currently **single-tenant**. The planned multi-tenancy retrofit adds `organization_id` as the isolation boundary — when that lands, every query must be org-scoped. Until then, don't hardcode assumptions that block the retrofit.
7. Claude reviews your diff before merge. Hand off on a branch; don't push to main or deploy.

## This repo at a glance
- **MIRAI HRMS** — HR management. **Backend:** Python + FastAPI (`backend/`): `fastapi`, `uvicorn`, `SQLAlchemy[asyncio]`, `asyncpg`, `alembic`, `redis`. Layout: `app/`, `migrations/` (Alembic), `tests/`, `requirements.txt`, `Dockerfile`. **Frontend:** Vue 3 (`frontend/`): `vue`, `vue-router`, `pinia`, `vite`, `axios`, `chart.js`.
- **Commands:** backend — activate venv, `pip install -r requirements.txt`, run `uvicorn app.main:app --reload`, migrate `alembic upgrade head`, test `pytest`; frontend — `cd frontend && npm run dev|build|type-check|lint`. Helper scripts: `start-dev.ps1/.sh`, `setup-and-run.*`.
- **LicenseHub:** not yet integrated. Go-forward = multi-tenancy retrofit first, then a Python `httpx` client to the hub (metered on employee count). See the License Manager repo's `docs/integration/DEVELOPER-GUIDE.md` when wiring it.
