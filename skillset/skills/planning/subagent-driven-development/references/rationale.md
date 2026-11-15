# Rulings doctrine + rationalizations (verbatim from SKILL.md)

## Rulings, not stalls — doctrine


Five things stop you, and only these: an irreversible or destructive
operation; a security-sensitive action; a side effect outside this worktree
that norms say you ask about first (a merge, a push to a shared branch, a
publish); a plan so broken that every path forward is a guess; and a ruling
that would overturn an owner decision the project already records (a spec, an
`AGENTS.md`/`STATE.md` line, a code comment marked as the owner's decision).
That last one is not a ruling at all — it is the owner's to make. Asking costs
one message; dispatching a contrary ruling costs a stopped worker, a reverted
tree and an owner who has to re-read the mechanic from scratch. For those five,
stop and ask.


## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Close enough on spec compliance" | Reviewer found spec gaps = not done. Fix or hit the cap and adjudicate — those are the only exits. |
| "I'll fix it myself, dispatching is overhead" | Controller fixes pollute your context and skip review. Resume the implementer. |
| "One more round will converge" | Past the cap, rounds don't converge — the failure is structural. Adjudicate and route. |
| "The reviewer will just find something new anyway" | Scoped re-reviews verify fixes; they cannot wander. New findings on untouched code go to the ledger, not the loop. |
| "This finding is obviously wrong, I'll drop it" | You adjudicate only at the cap, and every ruling is a ledger entry. Silent discards are forbidden. |
| "The fix was small, skip the re-review" | Unreviewed fixes are how regressions land. Every round ends with a scoped re-review. |
| "The mechanic is obvious, I'll rule on it and dispatch" | A ruling that contradicts a decision the project already records (spec, `AGENTS.md`, a comment marked as the owner's) is not a ruling. The owner stops the worker mid-run, the tree has to be reverted, and the mechanic gets re-explained from zero. Establish the rule from the source data and put it in front of them first. |
| "Reviews slow the loop down" | The loop without reviews is just unverified churn. Reviews are the loop's brakes and steering. |
| "Ledger bookkeeping is overhead" | The ledger is what survives compaction. Controllers without one have re-dispatched entire completed task sequences. |
| "The implementer spawned its own reviewer — free extra assurance" | It's a duplicate seat reviewing the same diff; the task review is the gate. A worker-spawned reviewer is a defect to flag, not rigor. |
| "The worker's summary says 'Reviewed and approved' — it self-reviewed" | That is the implementer's SELF-review, not the task review. Dispatch the separate reviewer task anyway. Self-review re-validates the implementer's own assumptions and can bless the exact structure that is wrong (a config never compiled, a schema it invented); only an independent read against the current external docs catches it. |
