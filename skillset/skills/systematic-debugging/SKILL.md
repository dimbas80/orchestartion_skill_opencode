---
name: systematic-debugging
description: "4-phase root cause debugging: understand bugs before fixing."
version: 1.1.0
license: MIT
    tags: [debugging, troubleshooting, problem-solving, root-cause, investigation]
    related_skills: [test-driven-development, subagent-driven-development]
---

# Systematic Debugging

Random fixes waste time and create new bugs; quick patches mask the cause.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure. **Violating the letter of this process is violating the spirit of debugging.**

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If Phase 1 is not complete, you cannot propose fixes.

## The Feedback Loop Rule

The feedback loop is the debugging work. Before reading code to build a theory, create or identify a **tight** command that goes red on the user's exact symptom and green when the bug is fixed: fast, deterministic, agent-runnable, specific enough to catch this bug (not merely "doesn't crash"). When a clean repro is hard, spend disproportionate effort building the loop — guessing without a red-capable loop is the failure mode this skill prevents. Loop recipes (10 construction patterns, how to tighten, flaky-bug tactics): [references/feedback-loop-recipes.md](references/feedback-loop-recipes.md).

## When to Use

ANY technical issue: test failures, production bugs, unexpected behavior, performance, build failures, integration issues. **Especially:** under time pressure, "just one quick fix" seems obvious, multiple fixes already tried, previous fix didn't work, you don't fully understand the issue. **Don't skip:** issue seems simple (simple bugs have root causes), in a hurry (rushing guarantees rework), someone wants it NOW (systematic is faster than thrashing).

## The Four Phases

Complete each phase before the next. Rationalizations table and the real-world impact data: [references/rationale.md](references/rationale.md).

## Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Read error messages carefully** — don't skip errors/warnings; they often contain the exact solution. Read stack traces completely; note line numbers, file paths, error codes. Use `read_file` on the sources and `search_files` for the error string.
2. **Build a tight feedback loop** — can one command trigger the user's exact symptom? Does it fail only for this bug? Fast, deterministic, high reproduction rate for flaky bugs? Not reproducible → gather more data, don't guess. Recipes: [references/feedback-loop-recipes.md](references/feedback-loop-recipes.md).
3. **Check recent changes** — `git log --oneline -10`, `git diff`, new dependencies/config.
4. **Multi-component systems** — add diagnostic instrumentation at EACH boundary (what enters, what exits, env/config propagation, state per layer). Run once to find WHERE it breaks, THEN investigate that component.
5. **Trace data flow** — where does the bad value originate? What called this with it? Keep tracing upstream; fix at the source, not the symptom.

**Phase 1 completion checklist** — all true before Phase 2:
- [ ] Error messages fully read and understood
- [ ] A tight loop command exists and ran at least once
- [ ] Loop is red-capable: asserts the user's exact symptom
- [ ] Loop is deterministic (or flaky bug has a high reproduction rate)
- [ ] Recent changes identified and reviewed
- [ ] Evidence gathered (logs, state, data flow)
- [ ] Problem isolated to a specific component/code
- [ ] Root cause hypotheses can be stated and tested

**STOP:** do not proceed until you understand WHY it's happening.

## Phase 2: Pattern Analysis

0. **Minimize the reproduction** — once the loop is red, shrink it to the smallest scenario that still goes red: cut inputs, callers, config, data, steps **one at a time**, re-running after each cut. Done when removing any remaining element makes the loop green. A minimal repro becomes the cleanest regression test.
1. **Find working examples** in the same codebase — what works that's similar?
2. **Compare against references** — read the reference implementation COMPLETELY, every line; don't skim.
3. **Identify differences** — list every one, however small; never assume "that can't matter".
4. **Understand dependencies** — what components, settings, config, environment; what assumptions does it make?

## Phase 3: Hypothesis and Testing

1. **Form 3–5 ranked falsifiable hypotheses** before testing any one. Rank by likelihood and cheapness to falsify; state each prediction ("If X is the cause, changing/observing Y should make Z happen"); discard any without a testable prediction. User present → show the ranked list first; AFK → proceed with your ranking.
2. **Test minimally** — smallest probe on the highest-ranked hypothesis; one variable at a time; no bundles. Prefer debugger/REPL over ten logs; if you add logs, tag each with a unique prefix (`[DEBUG-a4f2]`) so cleanup is one search.
3. **Verify before continuing** — worked → Phase 4; didn't → NEW hypothesis; never stack fixes.
4. **When you don't know** — say "I don't understand X", don't pretend, ask the user, research.

## Phase 4: Implementation

1. **Create the failing test** — simplest possible reproduction, automated if possible, MUST exist before fixing (`test-driven-development`).
2. **Implement a single fix** at the root cause — ONE change, no "while I'm here" improvements, no bundled refactoring.
3. **Verify** — run the specific regression test, then the full suite (no regressions).
4. **Rule of Three** — fix didn't work? STOP. Count fixes tried: < 3 → back to Phase 1 with new information; **≥ 3 → STOP and question the architecture (step 5). Do NOT attempt fix #4 without an architectural discussion.**
5. **3+ fixes failed → wrong architecture, not a failed hypothesis.** Signals: each fix reveals new shared state/coupling elsewhere; fixes require "massive refactoring"; each fix creates new symptoms. STOP: is the pattern fundamentally sound, or are we sticking with it through inertia? Discuss with the user before more fixes.

## Red Flags — STOP and Follow Process

Thinking "quick fix for now, investigate later", "just try changing X", "add multiple changes, run tests", "skip the test, I'll verify manually", "it's probably X", "I don't fully understand but this might work", "one more fix attempt" (after 2+), or proposing solutions before tracing data flow — **ALL mean: STOP, return to Phase 1.** 3+ failed fixes → question the architecture.

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors, reproduce, check changes, gather evidence, trace data flow | Understand WHAT and WHY |
| **2. Pattern** | Minimize repro, find working examples, compare, identify differences | Know what's different |
| **3. Hypothesis** | Ranked theories, test minimally, one variable at a time | Confirmed or new hypothesis |
| **4. Implementation** | Regression test, fix root cause, verify | Bug resolved, all tests pass |

## Harness Integration

Investigation tools: grep/search (error strings, call tracing), file read with line numbers (sources), shell (tests, git history, repro), web search/fetch (error messages, docs). For complex multi-component debugging, dispatch investigation subagents — see [references/subagent-dispatch.md](references/subagent-dispatch.md).

## With test-driven-development

Fixing bugs: write a test that reproduces the bug (RED) → debug systematically to root cause → fix the root cause (GREEN). The test proves the fix and prevents regression.
