# Batching Small Tasks (and One Review per Batch)

Part of subagent-driven-development. Read before dispatching any small task.

Batching cuts the bootstrap tax: every fresh session pays full context setup. Two to four small tasks in ONE coder session with ONE review beat a session and a review per task — without lowering the gate, because the gate is the review, not the session count.

## When to batch

- **Same-shape work** — the same one-line fix, constant change, or field addition repeated across files: always one batch, however many items.
- **Independent small tasks** — 2–4 plan tasks that are each: a single-file or few-line change, no new interface, a clear spec in the plan, no open design question.
- **Housekeeping waves** — renames, comment/doc updates, test pins for a re-spec'd convention.

## When NOT to batch (one task = one session = one review)

- **Side effects outside the worktree**: migrations, deploys, live config, data writes, pushes — anything whose rollback recipe differs per item.
- **Core touches**: the tasks change the same module or a shared interface (merge conflicts, review cross-talk), or touch the module the other batched items depend on.
- **Own judgment or own debugging**: a task with an open design question, a failing test to investigate, or an unpredictable scope — it needs the full attention of the loop.
- **Security-sensitive or irreversible** changes — always alone, always with the explicit owner approval the project policy demands.
- **Acceptance batteries differ** — each task names a different test battery that must be judged on its own evidence. (A shared suite is fine; separate gates are not.)
- **More than 4 items** — split into batches of ≤4; a long batch hides cross-item inconsistency exactly like a long per-item list does.

If unsure — don't batch. The saving is real but bounded; a mis-batched fix loop costs more than the saved bootstrap.

## How to batch

1. **One brief, one task.** Write the batch brief as a numbered list — every item: file(s), exact change, per-item acceptance. The plan's task texts are quoted or linked, never paraphrased.
2. **One BASE, one report, one review package** for the whole batch. Report and review contracts stay exactly as for a single task (`workflows/<task_id>/implementation-report.md`; the reviewer gets brief + report + package).
3. **One dispatch per batch**: title names the batch (`B1`), prompt enumerates the items and their task ids, acceptance includes the class line — "every occurrence of this primitive in the data behaves identically" — not just item-by-item checks.
4. **Ledger**: one line per plan task as usual; the batch id goes in each line (`Task 3 (B1): complete …`). A crash mid-batch resumes from the ledger and the batch brief/report, which hold all items.
5. **Fix loop runs on the batch**: one review verdict, one fix round for the whole batch; item-scoped findings are fixed in the same round. Never split a failed batch review into per-item re-reviews.

## Batch review

One reviewer dispatch per batch. Its checklist:

- each item against its brief text and acceptance;
- the class line across items (identical behaviour for identical inputs, no copy-paste drift);
- the untouched-scope guard: items that were NOT batched (core, side-effect tasks) must show no changes from this diff;
- report evidence: the worker's suite run must cover every battery the batch names.

A reviewer that reports "the orchestrator's decision" as cause of an inconsistency is quoting your split instruction back — re-check what the batch brief actually said for each item before treating the verdict as agreement.
