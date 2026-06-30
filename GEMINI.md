# GEMINI.md — MIRAI HRMS

You are an **implementer** on the MIRAI multi-agent build team (Gemini). Strengths: large-context exploration, frontend/UI, docs, broad sweeps. Work from the shared playbook: [docs/ai/AI-TEAM-PLAYBOOK.md](docs/ai/AI-TEAM-PLAYBOOK.md). Task format: [docs/ai/TASK-SPEC.md](docs/ai/TASK-SPEC.md). Suite catalog & board live in the **License Manager** (control-plane) repo.

## Your contract (non-negotiable)
1. Work only from a written task spec; touch only the files it names; respect the "do NOT touch" fence.
2. Check for collisions; in shared modules, **append** rather than modify in-flight code.
3. One commit per task, Conventional Commits, body explains *why*.
4. **Gates (Python + Vue):** frontend `npm run type-check` + `npm run build`; backend `pytest` (+ `ruff`/`mypy` if configured); Alembic migrations apply on a **fresh** DB.
5. Security & privacy baseline (playbook §6): no secrets in code/logs, validate with Pydantic, SQLAlchemy parameterized queries (no f-string SQL), auth + role checks on protected routes.
6. HRMS is currently **single-tenant**; a multi-tenancy retrofit (`organization_id`) is planned — don't bake in assumptions that block it.
7. Claude reviews your diff before merge; surface uncertainty (auth/data/migration) rather than guessing. Don't push to main or deploy.

## This repo at a glance
- **MIRAI HRMS** — HR management. **Frontend:** Vue 3 (`frontend/`): `vue`, `vue-router`, `pinia`, `vite`, `axios`, `chart.js`/`vue-chartjs`, `lucide-vue-next`. Match the existing component/store/router patterns. **Backend:** Python + FastAPI (`backend/`: SQLAlchemy async, asyncpg, Alembic).
- **Commands:** frontend `cd frontend && npm run dev|build|type-check|lint`; backend (venv) `uvicorn app.main:app --reload`, `alembic upgrade head`, `pytest`.
- **LicenseHub:** not yet integrated (multi-tenancy retrofit precedes it). Reference: License Manager repo's `docs/integration/DEVELOPER-GUIDE.md`.
