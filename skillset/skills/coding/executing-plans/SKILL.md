---
name: executing-plans
description: "Инлайн-исполнение плана в СВОЕЙ сессии (роль coder): задача за задачей по TDD-дисциплине, ledger против компакции, финальный ревью ветки. Триггеры: выбран режим native при handoff плана, «исполняй план». Пара к subagent-driven-development (диспетчерский режим orchestrator'а)."
---

# Executing Plans

Execute the plan yourself, task by task, in this session: no implementer subagent, no reviewer per task — one fresh-context review of the whole branch at the end. Inline keeps what it gives up by other means: brief = spec, ledger = memory, TDD = per-task gate, final reviewer = second pair of eyes. Rationale: [references/rationale.md](references/rationale.md).

**Core principle:** the plan already did the thinking — execute it exactly, prove each step with a test watched RED then GREEN, leave a record that survives your forgetting.

**Narration & pace:** at most one short line between tool calls; never pause to check in between tasks — they chose inline to spend less.

**Rulings, not stalls.** Conflicts, ambiguities, plan defects — decide yourself. The spec is the binding authority, the plan is its argument, your judgment settles the rest. Ledger every decision as `Ruling: <what you decided> — <why> — <what it costs if wrong>`; an unledgered deviation is a decision made in secret. Four stops, only these: irreversible/destructive operation; security-sensitive action; side effect outside this worktree norms say ask about first (merge, push to shared branch, publish); plan so broken every path forward is a guess.

## When to Use

Plan from writing-plans with inline chosen at handoff; harness with no subagent tool (never fabricate a dispatch); tasks mostly independent — prefer subagent-driven-development for a per-task review gate or when later tasks would run compacted. A fully specified plan runs well on a mid-tier model; the most capable model earns its cost on the final review, dispatched separately — tell the partner so.

## Setup

Process diagram (dot): [references/process-diagram.md](references/process-diagram.md) — read before Task 1 and after compaction.

Isolated workspace via using-git-worktrees; never start implementation on main/master without the partner's explicit consent.

At skill start read [references/resuming.md](references/resuming.md): workspace via `scripts/sdd-workspace PLAN_FILE` (git-ignored, shared with subagent-driven-development); ledger rules (`Task <N>: complete` = DONE, resume at the first without one; identity first line `# SDD ledger — plan: <plan file path>`; after compaction trust the ledger and `git log`; `git clean -fdx` destroys it — recover from `git log`); read-plan-once / spec-is-authority rules (no reachable spec → ledger note; rulings without one are provisional).

**REQUIRED SUB-SKILL:** load test-driven-development now, before Task 1 — a plan whose steps say "write the failing test first" does not exempt you.

Pre-flight conflict scan (Interfaces blocks, ledger rows per shared interface, rulings beside rows): [references/preflight.md](references/preflight.md) — run before Task 1.

## The Task Loop

Everything you print and every tool result stays resident for the rest of the session: redirect long test output to a workspace file, read its tail; read the brief, not the whole plan. Bookkeeping rides along — ledger append in the same call as the commit, never its own call.

### 1. Take the task

Run `scripts/task-start PLAN_FILE N` — prints the brief path and BASE (the commit the task's range is cut from). Read the brief for EVERY task, even ones you remember: memory is a summary, the brief has the exact values, signatures, test cases. Mark the todo in_progress.

### 2. Work the steps

Follow the plan's steps in RED-GREEN order under test-driven-development. Watching a test fail is a step, not a formality — a test passing before the implementation exists is a finding about the test.

Every command step has an `Expected:` line. Run it, read the output, compare:
- **Matches** → next step.
- **Code is wrong** → systematic-debugging; never patch the symptom to make output match.
- **Plan is wrong** (contradicts the spec; interface mismatch; impossible command) → rule on the smallest change satisfying the spec, ledger `Task <N>: Ruling: <finding> — <what you decided and why>`. Later tasks touching the same interface read it from the ledger.

Commit as the plan's commit steps say; several commits per task is fine; the review range is cut from BASE, never `HEAD~1`.

### 3. The completion contract

Before the task's ledger line, ALL true with evidence in this session, not inferred from the diff: every test the brief names exists and ran, output read; the final test run passed (`task-done` writes command+result into the ledger line); every `Expected:` line compared against real output; every deviation has a `Ruling:` line. **REQUIRED SUB-SKILL:** verification-before-completion governs the claim — any item missing, the task is not complete.

### 4. Complete the task

Run `scripts/task-done PLAN_FILE N BASE -- <test command>` (the brief names it). It runs the tests, keeps output in the workspace, prints the tail, and only on pass appends: `Task <N>: complete (commits <base7>..<head7>, tests: <command> → <result>)`. A failing run records nothing. Mark the todo complete, take the next task.

## Final Review

Before reviewing, read [references/final-review.md](references/final-review.md) — review modes for this setup (Kanban vs autonomous; self-review via [code-reviewer.md](code-reviewer.md) without a subagent tool), re-grading by effect, fix-pass contract, verbatim ledger formats. Run `scripts/review-package PLAN_FILE MERGE_BASE HEAD` (`git merge-base main HEAD`) and review from the printed file. The gates live in the reference and are never skipped: severity labels are advice — re-grade by effect; Critical/Important → ONE TDD-verified fix pass; Minor → deferred to the ledger, never a ruling; an unfixed finding is a ledgered `Final: Ruling`; no second fix pass, no re-review dispatch.

## Finish

Every `Ruling:` line → final message "Rulings I made" (in order, each with cost if wrong); every `minor (deferred)` → "Deferred minors" — both exhaustive, the final message is the only place these reach the partner. Review clean → delete this plan's workspace (git history is the record; sibling dirs belong to other plans). Hand off with both lists, branch name, review outcome; the merge decision — finishing-a-development-branch — is the Orchestrator's call with the partner, not the implementer's.

## Hermes Notes (this setup)

- Скрипты (`task-start`, `task-done`, `sdd-workspace`, `review-package`) — через terminal (`bash scripts/...`); локальные копии скриптов subagent-driven-development (один workspace-формат).
- Финальный ревью — по режимам из [references/final-review.md](references/final-review.md): Kanban (multi-profile) или автономный диспатч ревьюера.

## Common Rationalizations

Full table: [references/rationale.md](references/rationale.md). Most expensive inline: "I remember what Task N says" — the brief has the exact values, read it; "ledger lines after a few tasks" — one line per task with the commit, compaction does not wait.
