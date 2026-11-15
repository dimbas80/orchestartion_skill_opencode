# Workspace, Ledger & Plan Reading (executing-plans)

Read at skill start. Shared with subagent-driven-development (same directory, same format), so a plan can change executors mid-flight and the new one resumes from the same ledger. Todos are the live view; the ledger is the record.

- Each plan owns a workspace: at skill start, run this skill's `scripts/sdd-workspace PLAN_FILE` — it prints the plan's git-ignored directory (`<repo-root>/.superpowers/sdd/<plan-basename>/`), home to every artifact for THIS plan: ledger, briefs, review packages. Another plan's directory is never yours to read or write.
- Check for this plan's ledger at `<workspace>/progress.md`. If its first line names your plan file, tasks with a `Task <N>: complete` line are DONE — do not redo them; resume at the first task without one. Their commits exist in git even when your context no longer remembers making them: after compaction, trust the ledger and `git log` over your own recollection. A ledger whose first line names a different plan file is another plan's progress: leave it and start your own, fresh.
- Create the ledger with its identity as the first line: `# SDD ledger — plan: <plan file path>`.
- `git clean -fdx` will destroy the workspace (it's git-ignored scratch); if that happens, recover from `git log`.

Conversation memory does not survive compaction. An inline executor that loses its place re-implements tasks whose commits already exist — the same failure as a controller re-dispatching them, paid for in your own context. Track progress in a ledger file, not only in todos.

## Read the plan

Read the plan once, note its context and Global Constraints, and create a todo per task. If the plan names a Spec, read that too: the spec is the authority the plan argues from, and conflicts inside the plan resolve against it. A plan with no reachable spec gets a ledger note saying so — rulings made without one are provisional.
