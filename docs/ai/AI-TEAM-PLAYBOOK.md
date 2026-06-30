# MIRAI AI Team Playbook

**The shared operating system for our multi-agent build team.** Every AI builder — **Claude** (CEO / tech lead / orchestrator), **Codex**, and **Gemini** — works from this one playbook so we ship faster, in parallel, without colliding, and without lowering the security bar.

> This is the single source of truth for *how we work*. Tool-specific entry points (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md` at each repo root) are thin and point here. The catalog of *what* we work on is [REPO-REGISTRY.md](./REPO-REGISTRY.md); live assignments are on the [TASK-BOARD.md](./TASK-BOARD.md).

---

## 1. The team & roles

Roles are assigned by **task shape**, not ego. Default split:

| Agent | Primary role | Best at | Typically owns |
|-------|--------------|---------|----------------|
| **Claude** | CEO / tech lead / orchestrator & reviewer | Planning, architecture, cross-cutting reasoning, judgement | The plan; risky/cross-cutting code (auth, billing, migrations, multi-tenancy, data-loss paths); writing task specs; **reviewing every other agent's diff before merge** |
| **Codex** | Implementer — localized backend & logic | Well-specified, single-file-ish changes, refactors, validation, CI, bug-fixes | Backend services/routes, schema-adjacent fixes, test wiring, mechanical changes against a precise spec |
| **Gemini** | Implementer — breadth, frontend, docs | Large-context exploration, UI/frontend, docs, data wrangling, generating alternative approaches | Frontend/SPA work, documentation, broad sweeps, research, first-draft generation |

**The one rule that makes this safe:** **Claude reviews every Codex/Gemini diff before it merges.** This caught real shipped-blocking bugs (e.g. a Postgres `42P10` on every notification write, an MFA-gate bypass) that typechecked fine. No exceptions for anything touching auth, billing, data, or migrations.

**Claude is the tie-breaker.** When agents disagree or a task is ambiguous, Claude decides and records why.

---

## 2. Operating principles (non-negotiable)

1. **Plan before code.** Produce a short plan + ask Socratic clarifying questions before writing code on any non-trivial task. Don't bake assumptions into code.
2. **Living plan.** Keep a plan doc per workstream (see `docs/enterprise/*-PLAN.md` for examples) and update it at every stage. Decisions get logged with their date and rationale.
3. **One source of truth.** A task is driven by one written spec ([TASK-SPEC.md](./TASK-SPEC.md) format). Implementers consume the spec verbatim and don't re-derive scope.
4. **Disjoint-file parallelism.** Parallel tasks must touch **non-overlapping files**. When that's impossible, *append* (add new functions/files) rather than modifying shared ones; the spec names a "do not touch" fence.
5. **One commit per task**, conventional-commit format, on a task branch. Reviewable diffs, clean rollback.
6. **Green before merge.** Typecheck + build (+ tests where they exist) must pass. Migrations must apply cleanly on a **fresh** DB.
7. **Review before merge.** Claude reviews; blockers are fixed before the branch lands.
8. **Security & privacy are baseline, not features** (§6). Never lowered to ship faster.
9. **Report honestly.** If tests fail, say so with output. If something is stubbed or skipped, say that. "Done" means done *and verified*.
10. **Confirm outward/irreversible actions.** Pushing, deleting, deploying, or anything customer-facing needs explicit human go-ahead unless already authorized.

---

## 3. The build workflow (task lifecycle)

```
 idea / request
   └─► Claude: plan + Socratic questions ──► human confirms scope
         └─► Claude writes a TASK-SPEC (or spec pack) per unit of work
               └─► assign on the TASK-BOARD (owner + branch + files + do-not-touch)
                     └─► implementer builds on the branch (1 commit/task)
                           └─► implementer runs typecheck/build (+ tests)
                                 └─► Claude reviews the diff (adversarial for risky work)
                                       └─► fix blockers ──► merge ──► update plan + board
```

**Spec packs:** for a batch of work, Claude freezes a `*-SPEC.md` so cheap/fast implementers never have to re-explore the repo — this is the biggest token saver and the main collision-preventer.

---

## 4. Parallelization & collision avoidance

- **Before assigning parallel tracks, check file overlap.** Tracks that share a file get serialized or restructured (append-only).
- **Lane discipline:** stay inside the files your spec names. Straying into another agent's lane (even with good intent) causes merge pain — flag it instead.
- **The TASK-BOARD is the collision map.** Agents run at different times and don't share live state, so the board records who holds which files on which branch. Update it when you pick up and when you finish.
- **Adversarial review for risky fan-outs.** When multiple agents touch correctness-critical areas, Claude runs a multi-perspective review (find → adversarially verify → synthesize) before merge.

---

## 5. Quality gates

Every change must clear, in order:
1. **Typecheck** — `corepack pnpm -r typecheck` (or the repo's equivalent). Zero errors in touched packages.
2. **Build** — the relevant app/package builds.
3. **Tests** — run what exists; add tests for correctness-critical logic (idempotency, billing, auth, cascades).
4. **Migrations** — generated via the repo's tool and **verified to apply on a fresh DB** (not just an existing one). Hand-author the data-safe parts (de-dup before a unique index, `IF EXISTS` for push-created objects).
5. **Live smoke** for anything user-facing — exercise the real endpoint/flow, don't assume.

If a gate can't be run, say so explicitly in the handoff.

---

## 6. Security & privacy baseline (non-negotiable)

Distilled from the enterprise hardening work (see `docs/enterprise/ENTERPRISE-UPGRADE-PLAN.md`). Applies to every product:

- **Secrets:** never in code, client bundles, logs, or committed env files. Compose/CI reference secrets, never inline defaults. No `change-me` defaults reachable in production config.
- **AuthN/Z:** every privileged route is behind auth + role checks. New route modules inherit the **same** guard chain (authn + MFA/enrollment gate + role/read-only) as the main scope — don't create a side scope that bypasses it.
- **Input validation:** schema-validate request bodies/params (zod/typebox). Parameterize all queries (ORM/placeholders) — never string-concatenate SQL. Validate IDs (UUID) before DB calls.
- **Brute force:** account lockout + rate limits on auth and link-generation endpoints.
- **Billing/metering correctness:** webhook signatures verified at entry; usage idempotency enforced at the DB (exactly-once); money/entitlement mutations are transactional.
- **Privacy baseline (legal, not optional):** PII classification, data export (SAR), deletion / right-to-be-forgotten, retention limits. No PII in usage metadata.
- **Tenant isolation:** every query scoped by the tenant boundary (`institution_id` / `customer_id` / `org_id`). No cross-tenant leakage.
- **Before deleting/overwriting:** look at the target; if it contradicts how it was described or you didn't create it, surface that instead of proceeding.

When in doubt on a security call, it's Claude's review gate — escalate rather than guess.

---

## 7. Conventions

- **Branches:** `<area>/<short-desc>` — e.g. `op/console-ui`, `harden/sec-rote`, `feat/parent-activation`. One branch per task/track.
- **Commits:** Conventional Commits — `feat(scope): …`, `fix(scope): …`, `docs(scope): …`, `chore(scope): …`. Body explains *why*; reference the spec/finding. Each agent signs its own commits (footer/author identifies the agent).
- **Don't** push, force-push, skip hooks, or bypass signing unless a human explicitly asks.
- **File layout:** new cross-cutting/risky services in their own files (keeps them disjoint from in-flight UI work). Living plans in `docs/<area>/*-PLAN.md`. Integration/reference docs in `docs/integration/`.
- **TODOs left behind** go in the commit message, not silently dropped.

---

## 8. Review & merge protocol

- Implementer opens the work as a branch + single commit and hands off (board → "in review").
- Claude reviews: correctness, the security baseline (§6), spec adherence, regressions (did it break a sibling flow?), and gate results.
- **Risky work gets an adversarial pass** (independent verifiers try to *refute* each finding; only survivors are real).
- Blockers are fixed (by the owner or Claude) before merge. Lows can ship as logged fast-follows.
- After merge: update the living plan's execution log + the TASK-BOARD.

---

## 9. Where things live (artifact map)

- **This playbook** — how we work.
- [REPO-REGISTRY.md](./REPO-REGISTRY.md) — the products/repos catalog (the suite map).
- [TASK-BOARD.md](./TASK-BOARD.md) — live assignments & the collision map.
- [TASK-SPEC.md](./TASK-SPEC.md) — the task-handoff template.
- [NEW-PRODUCT-ONBOARDING.md](./NEW-PRODUCT-ONBOARDING.md) — add a repo or a new product idea.
- Suite design & licensing: `docs/integration/PRODUCT-INTEGRATION-DESIGN.md`, `docs/integration/DEVELOPER-GUIDE.md`.
- Enterprise hardening, operator tooling, privacy: `docs/enterprise/*.md`.

---

## 10. Extending the team to new work

New repo or new product idea → follow [NEW-PRODUCT-ONBOARDING.md](./NEW-PRODUCT-ONBOARDING.md): drop this kit into the repo, register it, and (if it joins the suite) wire it to LicenseHub via the Developer Guide. Then it's business as usual: Claude plans, the board assigns, implementers build, Claude reviews, we ship.
