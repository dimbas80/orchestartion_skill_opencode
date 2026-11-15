# Final Review (executing-plans) — full mechanics

Run this skill's `scripts/review-package PLAN_FILE MERGE_BASE HEAD` (`MERGE_BASE` = the commit the branch started from, e.g. `git merge-base main HEAD`) and review from the printed file.

## Review modes in this setup

- **Orchestrated mode (default when a leading session runs the pipeline):** do not dispatch a reviewer yourself. Hand the review package to the session lead — it becomes a reviewer-role subagent dispatch (REVIEW stage of the routing policy), which returns `review.md` findings. Proceed with the fix pass on its findings.
- **Autonomous mode (no orchestrator in the loop):** dispatch a reviewer-role subagent yourself when the harness has one (its model is the one approved in the Model Gate — the whole-branch review is a judgment job); do it yourself as described below otherwise. Use this skill's [code-reviewer.md](../code-reviewer.md), with the package path, the plan and spec paths, the plan's Review Focus section verbatim if it has one (the input classes and failure modes the plan's tests do not exercise — the reviewer checks each deliberately), and a pointer to the ledger's `Ruling:` lines so it can weigh the calls you made. This is the one fresh context the whole run buys. Do not skip it, and do not replace it with your own read of the diff.

**Without a subagent mechanism:** read code-reviewer.md and perform that review yourself against the package, as a separate pass after the last task's ledger line. Write `Final review: self-review (no subagent mechanism)` to the ledger, and say so in your final message: a self-review by the author is weaker than a fresh reviewer, and your human partner decides whether that is enough before merge.

## Sorting, re-grading, the fix pass

Sort the findings before you act on any of them. The reviewer's severity labels are advice; the gate is yours. Its "Declined to judge" list is yours too: every line there is a ruling you make and ledger, exactly like a plan conflict — `Final: Ruling: <behavior the reviewer set aside> — <what a reasonable person using this software gets, and why that stands or why it is now a finding> — <cost if wrong>`. Re-grade first, by effect: the spec is a vision document, and a finding's grade is what a reasonable person using this software gets if it ships, not whether the spec names the input that triggers it — a reviewer who set a finding at Minor because the spec was silent has graded the spec, not the effect. Then:

- **Critical and Important** enter the fix pass.
- **Minor** goes to the ledger as `Final: minor (deferred): <one-liner>` and to your final message under "Deferred minors". Minors never enter the fix pass, and never become rulings — a ruling is a decision about a conflict, not a note that you declined a polish suggestion.

Fix the Critical and Important findings yourself — you are the implementer here — in ONE pass. Each fix is verified by TDD, not by a second reviewer: write the test that reproduces the finding, watch it fail, make it pass, then run the whole suite. Record each in the ledger as `Final: fixed <finding> — <test name> RED→GREEN, suite <N>/<N>`. A fix without a test that failed first is not verified; a suite that is not green after the pass means the pass is not over. Do not dispatch a re-review: it would re-read a diff whose covering tests already answer "addressed" and whose suite run already answers "broke nothing".

A finding you decide not to fix is a ruling — `Final: Ruling: <finding> — <why the code stands> — <cost if wrong>` — and reaches your human partner in the rulings list. There is no second fix pass.
