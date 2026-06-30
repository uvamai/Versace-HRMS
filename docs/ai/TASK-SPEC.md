# Task Spec template

The standard handoff format. A task is only ready to assign when it fills this out — any implementer (Codex, Gemini, Cursor, or a Claude subagent) can then execute it without re-deriving scope. Copy the block below per task.

> "Owner" is whichever implementer is assigned. Claude writes the spec and reviews the result. Keep specs tight: file paths + exact change + acceptance + a "do not touch" fence beats prose.

---

```md
## TASK: <short title>

- **Owner:** claude | codex | gemini | cursor
- **Branch:** <area>/<short-desc>
- **Repo:** <repo path>
- **Depends on:** <other tasks / APIs that must exist first, or "none">
- **Risk:** low | medium | high   (high → Claude implements or reviews adversarially)

### Context
<2–4 sentences: why this exists, the relevant existing code, links to plan/board.>

### Goal
<one paragraph: the outcome, observable from outside.>

### Files to touch (and ONLY these)
- `path/to/file` — <what changes>
- ...

### Do NOT touch
- <files/areas owned by another in-flight task; shared files to append-only; backend/schema/auth if out of scope>

### Exact changes / acceptance criteria
1. <concrete, testable step with the real endpoint/contract/field names>
2. ...

### Verification (must pass before handoff)
- [ ] `corepack pnpm -r typecheck` (or repo equivalent) — clean for touched packages
- [ ] build: `<command>`
- [ ] tests: `<command / "none">`
- [ ] migration applies on a FRESH DB (if schema changed)
- [ ] live smoke (if user-facing): <what to exercise>

### Review notes (for Claude)
<auth/billing/data/migration sensitivity; what to scrutinize.>
```

---

## Example (abridged)

```md
## TASK: Operator console — suspend/reactivate + usage bars

- Owner: cursor   Branch: op/console-ui   Repo: New Workspace/License Manager   Risk: medium
### Files to touch
- apps/admin/src/api.ts (APPEND new functions only)
- apps/admin/src/pages/CustomerDetailPage.tsx
### Do NOT touch
- apps/api/** (backend done), CustomersPage.tsx (Codex owns it), API field names
### Acceptance
1. suspendCustomer(id) -> POST /api/admin/customers/:id/suspend ; button + confirm + refresh + toast
2. usage bars from GET /api/admin/customers/:id/usage-summary, color-coded <80/80–99/≥100, 'no_signal' greyed
### Verification
- [ ] corepack pnpm --filter @mirai/admin build
### Review notes: auth-sensitive parts (login MFA step) flagged for Claude review.
```
