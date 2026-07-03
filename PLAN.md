# PLAN.md — Resume Dashboard (MIRAI HRMS)

> **Crash-recovery + multi-IDE entry point.** After a restart (or when opening this repo in a
> different IDE), tell Claude: **"restart from PLAN.md"**.
> **Standing rule:** before any agent (Claude / Codex / Gemini) starts an assigned task, its
> prompt/spec is written into **§ Active agent assignments** below *first*, then executed — so an
> interruption never loses the in-flight instruction and any IDE can resume it.

**Last updated:** 2026-07-03
**Repo:** MIRAI HRMS — HR management (backend Python/FastAPI + Alembic; frontend Vue 3)
**Active branch:** `HRMS-26-June`
**Control plane:** MIRAI LicenseHub (`../License Manager`)

---

## ▶ RESUME HERE — current in-progress item

**Working tree:** clean — no uncommitted in-flight code right now.

**Where the product stands:**
- Phase 1 foundation scaffold committed (`8e4fd1d`); bcrypt/DB/CORS config fixed (`05d56f8`).
- **Single-tenant, feature-complete; NOT yet integrated with LicenseHub.**

**Headline next task (risky / cross-cutting — Claude designs first):**
**Multi-tenancy retrofit** — add `organization_id` as the isolation boundary across models, auth,
and queries, sequenced so the single-tenant app keeps working through the migration. This precedes
any LicenseHub integration.

**Next concrete step:**
1. Design the multi-tenancy retrofit (living plan): `organization_id` boundary, Alembic migration sequence, backfill, auth/session scoping. Socratic questions before code.
2. After tenancy lands: add the Python **`httpx` LicenseHub client** (metered on employee count) per the License Manager `docs/integration/DEVELOPER-GUIDE.md`.

**Gates to hold:** `pytest`, **Alembic on a fresh DB**, frontend `type-check` / `build`, security/privacy baseline (playbook §6).

**Env note:** backend runs via venv — `uvicorn app.main:app --reload`, `alembic upgrade head`, `pytest`; frontend `cd frontend && npm run dev|build|type-check`. Helper scripts: `start-dev.*`, `setup-and-run.*`.

---

## Active agent assignments (live prompts)

> Paste the exact task prompt/spec here **before** the agent runs. One row per active assignment.
> Move to `done` (or clear) once merged. This is the handoff record that survives interruptions.

| Agent | Assigned prompt / spec (or link) | Files held (do not collide) | Branch | Status |
|-------|----------------------------------|-----------------------------|--------|--------|
| 🟣 Claude | _(none active)_ — next: design the multi-tenancy (`organization_id`) retrofit. | | | |
| 🟦 Codex | _(none active)_ | | | |
| 🟩 Gemini/Cursor | _(none active)_ | | | |

<!-- When assigning, append the full prompt below under a heading like:
### 🟦 Codex — <task title> (assigned 2026-07-03)
<full prompt / TASK-SPEC with file paths, exact change, acceptance, do-not-touch fence>
-->

---

## Agent roles & instruction files

| Agent | Instruction file | Owns |
|-------|------------------|------|
| 🟣 **Claude** (tech-lead / review gate) | [CLAUDE.md](CLAUDE.md) | plan; auth, tenancy, Alembic migrations, future hub client; reviews every diff before merge. |
| 🟦 **Codex** | [AGENTS.md](AGENTS.md) | rote implementation on disjoint files per spec; tests. |
| 🟩 **Gemini / Cursor** | [GEMINI.md](GEMINI.md) | Vue 3 frontend on disjoint files. |

**Coordination surfaces:**
- [docs/roadmap.md](docs/roadmap.md)
- [docs/ai/AI-TEAM-PLAYBOOK.md](docs/ai/AI-TEAM-PLAYBOOK.md) · [docs/ai/TASK-SPEC.md](docs/ai/TASK-SPEC.md)
- Control-plane task board: `../License Manager/docs/ai/TASK-BOARD.md` (path relative to the suite root).

---

## Roadmap

- ✅ Phase 1 foundation scaffold (auth, DB, CORS).
- 🟡 Multi-tenancy retrofit (`organization_id`) — **headline next task**, Claude-designed.
- ⬜ Python `httpx` LicenseHub client, metered on employee count.
