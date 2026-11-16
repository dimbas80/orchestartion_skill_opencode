---
name: subagent-driven-development
description: "Диспетчерский режим ведущей сессии: план → диспатчи субагентов-исполнителей (coder), fresh контекст на каждую задачу через субагентскую сессию, task review после каждой, финальный ревью ветки. Триггеры: выбран режим subagent-driven при handoff плана, «диспетчируй задачи», «разложи по ролям». Пара к executing-plans (инлайн-режим)."
---

# Subagent-Driven Development

Execute a plan as a fresh implementer subagent per step — each task runs in its own isolated session (fresh context), with a task review (spec compliance + code quality) after each, and a whole-branch final review at the end. Inline execution (executing-plans) is the alternative when a harness has no subagent mechanism; the mechanics here assume dispatch exists.

**Core principle:** fresh session per task + per-task review + final review. **Continuous execution:** do not pause between tasks — the only stops are the five below or completion. "Should I continue?" prompts waste the owner's time. Narrate at most one short line between tool calls; the ledger and tool results carry the record.

**Rulings, not stalls.** A running plan does not wait on a human: decide conflicts, ambiguities, plan defects yourself, record every decision in the ledger as `Ruling: <what> — <why> — <what it costs if wrong>`, and keep going. Full doctrine and the rationalization table: [references/rationale.md](references/rationale.md). Five things DO stop you, and only these: (1) an irreversible or destructive operation; (2) a security-sensitive action; (3) a side effect outside this worktree that norms say ask about first (merge, push to shared branch, publish); (4) a plan so broken that every path forward is a guess; (5) a "ruling" that would overturn a decision the project already records (spec, `AGENTS.md`/`STATE.md` line, owner-marked comment) — that is the owner's to make, asking costs one message.

## When to Use

- No implementation plan yet → manual execution or `brainstorming` first.
- Tasks tightly coupled → `executing-plans` (inline: one context, review only at the end).
- No subagent mechanism in this harness, or the partner chose inline → `executing-plans`.
- Otherwise (plan exists, tasks mostly independent) → SDD.

Inline costs one context plus one final reviewer; SDD costs a fresh context per task and per review but gives per-task gates and no context pollution.

## Subagent Dispatch

The "subagents" are harness dispatches of the role agents (coder, reviewer — defined as agent files, see the project's `.orchestration/orchestration.yml` `roles` section): each task becomes one dispatch, which runs in its own session — exactly the fresh context this skill exists for. Script paths below are relative to this skill's dir.

**Before ANY non-trivial dispatch decision** (parallel fan-out, re-dispatch of a live worker, escalating a role's model, recovery after a crashed run) read [references/dispatch-ops.md](references/dispatch-ops.md) — it holds the operational lessons: serializing tasks that touch the same files, dirty-tree safety, long-payload discipline (bodies go through files, not inline), verdict parsing, crash triage, reading the tree while a worker holds it.

Per task:

1. `bash <skill_dir>/scripts/task-brief PLAN_FILE N` → brief file (the single source of requirements; exact values live only there).
2. Dispatch the implementer subagent (role `coder`, or the role the routing policy assigns): body links brief path + `implementation-plan.md` + spec + report contract (`workflows/<task-id>/implementation-report.md`). Template: [implementer-prompt.md](implementer-prompt.md).
3. The worker (executing-plans discipline) implements, tests, commits, writes the report.
4. `bash <skill_dir>/scripts/review-package PLAN_FILE BASE HEAD` → package file → dispatch the reviewer subagent → findings come back as `review.md`.
5. Fix loop per [references/fix-loop.md](references/fix-loop.md).

Ledger: `.superpowers/sdd/<plan>/progress.md` (git-ignored; workspace printed by `bash <skill_dir>/scripts/sdd-workspace PLAN_FILE`) — the cross-session recovery map. The ledger tracks what is actually done; nothing else is authoritative. An existing ledger → read [references/resuming.md](references/resuming.md) before anything else.

## Model Gate — REQUIRED, before ANY dispatch

1. Build the map: **every executor role** the plan touches → model, read from its agent file (`model` field: zcode `.zcode/agents/<role>.md`, opencode `.opencode/agents/<role>.md`) or, when unset, from the harness's model list. Resolve any user shorthand to the exact model id **in that provider's own namespace** (ids differ per provider; a wrong-namespace id fails at worker spawn).
2. Present the table, get explicit approval; agree the fallback for unreliable providers up front.
3. Record the approved map in the ledger and in the first dispatch's body. To change a role's model, edit its agent file (or the per-dispatch override the harness offers) — and say so to the user; never swap silently.
4. There is no supervisor enforcing this gate in these harnesses — it is procedural, and you are its enforcer.

Full mechanics (health-check probes, id namespaces, recovery): [references/model-gate.md](references/model-gate.md).

## Process

Setup → per task: dispatch implementer → handle report → task review → (fix loop, ≤ cap) → ledger complete → next task → final review (references/final-review.md) → delete this plan's workspace → `finishing-a-development-branch`.

Setup: the coder creates the worktree (`using-git-worktrees`); you verify it exists (`git worktree list`) — never implement on main/master without the partner's consent. Run `scripts/sdd-workspace PLAN_FILE`; create the ledger, identity first line: `# SDD ledger — plan: <plan file path>`. Read the plan once, note context and Global Constraints; if a spec is named, read it too — the spec is the authority, plan conflicts resolve against it. Before Task 1, read [references/preflight.md](references/preflight.md) and run its conflict scan into the ledger. Conversation memory does not survive compaction — controllers that lost their place re-dispatched whole completed sequences; after compaction trust the ledger and `git log` over your own recollection. `git clean -fdx` destroys the workspace (git-ignored); recover from `git log`.

## Model Selection

The model belongs to the role (its agent file): tier by choosing the role, never by per-dispatch arguments. Escalation is a reassignment to a stronger role or an approved model bump via the agent file — never a silent swap. Cheapest tier only for transcription-verbatim plans and single-file mechanical fixes; mid-tier is the floor for reviewers and implementers working from prose (cheap models take 2–3× the turns — turn count beats token price); integration/judgment → standard; design and the final whole-branch review → strongest approved tier. Fix-loop rounds 4–5 → move one tier up, ask the partner first.

## The Task Loop

**Batching:** 2–4 small tasks (or any same-shape edits across files) → read [references/batching.md](references/batching.md) before dispatching — one coder dispatch, one review per batch; side-effect, core-touching and judgment tasks are never batched. Everything pasted into a dispatch — and everything a subagent prints back — stays resident and is re-read every later turn: hand artifacts over as files. Never poll a wait interface with short timeouts; keep working while you have local work, otherwise wait in bounded stretches (5–10 min) with a one-line status between them. In harnesses with background agents (e.g. zcode) run long dispatches in the background and check artifacts on wake; in sequential harnesses (e.g. opencode) dispatches are synchronous by construction — the wait discipline applies to shell commands, not dispatches.

### 1. Dispatch the implementer

Record BASE (`git rev-parse HEAD`). Compose the dispatch from five parts only: (1) one line on where this task fits; (2) the brief path, introduced as "read this first — your requirements, exact values verbatim"; (3) interfaces and decisions from earlier tasks the brief cannot know; (4) your resolution of any ambiguity you noticed; (5) the report-file path and contract. Exact values (numbers, magic strings, signatures, test cases) appear only in the brief; never make the executor read the whole plan. No pasted prior-task history — a real session's dispatch hit 42k chars, 99% was pasted history. Carry the no-subagents contract: the implementer never dispatches helpers and never a reviewer (worker-spawned reviewers duplicate your review seat). Carry a pointer to any parked finding in the touched area. Never dispatch multiple implementers in parallel. Template: [implementer-prompt.md](implementer-prompt.md).

### 2. Handle the report

DONE → generate the review package (`bash <skill_dir>/scripts/review-package PLAN_FILE BASE HEAD`; BASE recorded before dispatch — never `HEAD~1`, it silently drops all but the last commit) → dispatch the task reviewer. DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED → read [references/handling-reports.md](references/handling-reports.md), every time. Implementer questions → answer clearly and completely, don't rush it.

Work already implemented in the live tree (another session, uncommitted) has no BASE/HEAD range: build the review package by hand — `git diff HEAD` plus the contents of every untracked new file the report names, each labeled `=== NEW FILE: <path> (uncommitted) ===` so the reviewer notices it — and at the wave's ticket/spec/plan paths. Commit being the owner's explicit job is part of this contract: the reviewer must never commit, and a mutation probe must be reverted byte-identically (checksum before/after).
- The hand-built package is a scratch artifact — delete it before the wave's commit (it is reproducible from the committed state; keeping it puts a stale diff in the repo forever).

### 3. Review the task

Per-task reviews are task-scoped gates; the broad review happens once at the end. Never skip the task review; both verdicts required — spec compliance AND quality. Implementer self-review never replaces it.

- Hand the reviewer its diff as a file: the review package path (or `git log --oneline` + `git diff --stat` + `git diff -U10` redirected to one file). The diff never enters your own context. Never dispatch a reviewer without a diff file.
- Before counting a report's or map's table rows by hand, read its legend/schema first: cross-check tables often carry one verdict column per category per row, so a naive cell sweep mislabels the second column and fabricates hundreds of phantom gaps instead of the real few. Parse the column the verdict lives in.
- If the project's run environment needs a non-default invocation (broken venv, interpreter override, env vars), put the exact working commands in the reviewer dispatch body: a fresh worker session inherits none of it and burns turns rediscovering it — or worse, runs a wrong-shaped command and produces a false verdict.
- After a PASS verdict, spot-check it cheaply against the live tree (counts, statuses, boundary octets, files that should be untouched) before reporting done: a reviewer's summary is a self-report, and a couple of grep/wc probes catch a hollow PASS in seconds. **A spot-check that FAILS is not yet a finding.** Before reporting a broken invariant to the owner, re-run the check with a robust parser (brace-balanced block extraction, comment-stripped lines): naive string-splits anchor on the identifier's NAME and match comments or prose that merely mention it, producing a false mismatch that triggers a false owner alarm — the false alarm costs a full owner round-trip and undermines trust in every later red. The same stands for cross-review adjudication: a second review's confirm/refute/re-prioritize of an independent review's findings is again a self-report — run the pointed probe (grep/read the exact file:line the dispute names) yourself before relaying either verdict to the owner as fact, and carry that probe result into the consolidated fix list.
- **A foreign review is dispatched as a second-opinion protocol, not as a checklist to re-read.** When the owner hands in someone else's review or audit, instruct the reviewer: own full pass over the tree FIRST (findings fixed before opening the foreign document — reading it first anchors the same misses), then verify each foreign item against the code (file:line + quote) as confirmed / refuted / re-prioritized, and return two artifacts: the own review and a comparison table that also lists what the foreign review missed. Spot-check a pilot claim from the foreign text against the source yourself before treating the comparison as fact — a false item often reviews an older snapshot of the code. A foreign review verified this way is the only kind that earns changes; a relayed 'looks right' is not evidence.
- Reviewer inputs: three paths — brief, report, package — plus the global-constraints block copied verbatim from the plan's Global Constraints or spec (exact values, exact formats, stated relationships). It is the attention lens; the template already carries the process rules.
- No open-ended directives ("check all uses") without a concrete task-specific reason; don't ask a reviewer to re-run tests the report already evidences; **never pre-judge findings** — if your prompt contains "do not flag", "at most Minor", "the plan chose", stop: you are dodging a review loop. Adjudicate findings in the loop instead.
- "⚠️ Cannot verify from diff" items → [references/cannot-verify.md](references/cannot-verify.md) before completing.
- A finding whose verification is physical (wiring/pull-ups, screen legibility, pins on real hardware) has no coder task: route it to the owner with the concrete check, and when the owner answers, close it by recording their physical facts as project facts. Findings routed to the owner for a DECISION go with the full detail, not a one-line label: file:line + the actual code snippet, why it matters in operation (the scenario where it bites), the options with cost, and a recommendation table (fix now / after tests / leave as is) — the owner decides from the detail, and "подробнее" on their follow-up means the first message was too thin. A code task for a hardware question produces a no-op diff and an unfixed claim. Before asking, diff-check whether the wave touched that surface at all (the drawing call, the font table, the pin defines): a path the changes never entered is already covered by the owner's earlier hands-on validation — close it from their past experience and skip the repeat bench run.
- **A structural refactor re-implements legacy behavior — including defects the owner has already approved fixing.** Before dispatching a rewrite of a module, sweep the decision log for approved-but-not-yet-applied fixes touching that module: fold each into the rewrite body expressed in the NEW architecture's terms (descriptor row, enum, table entry), or schedule an explicit follow-up fix dispatch. After the refactor lands, re-verify every approved fix against the new shape before closing the wave — the old line being rewritten is not the fix surviving, and a fidelity clause in the body ("keep the old rules verbatim") will faithfully carry a known bug into the new structure. The loss surfaces only when the owner next tests the setting the fix gates — too late and on their time.
- **A bug fix at one entry point has siblings at the others — make the allowlist cover the decision, not the file.** A validation/boundary bug reachable from the encoder menu usually has the same bug in the web form and the bot command path; when scoping a fix dispatch, grep for the same pattern across ALL entry points first and either include them in scope (and the file allowlist) or open an explicit follow-up dispatch in the same wave. A file-scoped allowlist narrower than the owner's decision guarantees a PASS review on the first path while the second one ships broken — the reviewer can only verify what the dispatch allows touching, and the residual surfaces as a MEDIUM finding after the wave is already committed.
- **A chain of batches that ran to `done` without interleaved reviews gets ONE catch-up reviewer dispatch at wave end, not one per batch.** Write the dispatch so it carries, per batch: that batch's diff/report/build paths and the batch-specific checks, plus the instruction to leave a separate `review.md` in **each batch's** `workflows/<batch-id>/` and to state a verdict per batch. A single aggregate verdict hides which batch failed and cannot route the fix. When reading back, look for those files in the batch dirs first — the reviewer dispatch's own `workflows/<id>/` is legitimately empty under this shape, and an empty own-dir is not a missing review.

Template: [task-reviewer-prompt.md](task-reviewer-prompt.md)

### 4. The fix loop

Triggers: spec ❌, any Critical or Important finding, or a ⚠️ item you confirmed as a real gap. When it triggers — and again before every round — read [references/fix-loop.md](references/fix-loop.md): it holds the round cap, the breaker, and the ledger line each round writes; your memory of it does not survive compaction.

### 5. Complete the task

Review clean — or every open finding parked with a ruling at the cap — append the ledger line in the same message as your bookkeeping: `Task <N>: complete (commits <base7>..<head7>, review clean)` or `Task <N>: complete (commits <base7>..<head7>, <K> parked)`. Mark the todo complete, move on. Never advance with open Critical/Important findings that are neither fixed nor parked-with-ruling.

## Final Review

Every task complete → read [references/final-review.md](references/final-review.md): the whole-branch review, its single fix wave, and how you finish (delete the plan's workspace when clean, then `finishing-a-development-branch`).

## Common Rationalizations

Full table: [references/rationale.md](references/rationale.md). Inline, the three most expensive: spec gaps found by the reviewer = not done; "I'll fix it myself" pollutes your context and skips review — resume the implementer; past the cap, rounds don't converge — the failure is structural, adjudicate and route. Every ruling and every discard is a ledger entry; silent discards are forbidden.
