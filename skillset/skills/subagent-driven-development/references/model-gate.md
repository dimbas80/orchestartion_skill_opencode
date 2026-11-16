# Model Gate — full mechanics (SKILL.md holds the required 4-step summary)

## Confirm Models Before Dispatch (REQUIRED GATE)

Before dispatching ANY executor subagent for a plan, confirm the model map
with your human partner. Providers differ in reliability (some have
temporarily unavailable models or paused subscriptions), and a worker that
discovers a dead provider mid-task burns the budget of the whole run.

1. Build the map: **every executor role the plan will touch** (coder,
   reviewer, architect — whoever the routing policy assigns work to) →
   model, read from the role's agent file (`model` field: zcode —
   `.zcode/agents/<role>.md` or the harness model list; opencode —
   `.opencode/agents/<role>.md`). The reviewer is part of the map:
   the final whole-branch review is a capable-model job by design.
   When the user names a model in shorthand (e.g. «deepseek-flash»), resolve it
   to the exact model id from the harness's model list and state what you
   will set — never write a shorthand that is not a real model id.
   **A provider's id namespace is not the harness's default string.** The same
   model usually has a different id per provider (a bare `glm-5.3-flash` on one,
   a slash-prefixed `glm/glm-5.3` on another). When the approved map
   names provider P + model M, list P's own models (`GET <base_url>/models` with
   that provider's key) and copy the id it returns verbatim; an id from the wrong
   namespace fails at worker spawn, not at the gate.
2. Present it as a table and ask for explicit approval. For unreliable
   providers, propose the fallback: which role/model takes over.
3. Offer a cheap health-check per executor (a one-token test call through that
   provider) — recommended for flaky providers before a long run. Probe with the
   exact id you are about to pin, using the key the harness would use — the same
   vendor key can return 429 "Insufficient balance" on one base path and 200 on
   another (vendors host several API planes under one domain) — try the vendor's
   alternate documented base path before declaring the key or model dead.
   Read the result correctly: a 200 with empty
   content is a working model (reasoning models often emit no text at a tiny
   `max_tokens`), while an empty or non-JSON body is a retry, not a verdict —
   probe twice before calling a provider dead, then report it and ask which
   fallback to apply instead of swapping on your own.
4. Record the approved map in the ledger and in the first dispatch's body.
5. NEVER switch a role's model silently mid-run. If a provider dies
   (worker fails on an unavailable model), stop the run, ask your human
   partner which fallback to use, apply it (edit the role's agent file or
   the per-dispatch override the harness offers), and announce the change.
   A silent model swap is a decision made in secret.
6. **The gate is procedural — there is no supervisor to enforce it.**
   In these harnesses nothing blocks an unapproved model before the worker
   runs; skipping the gate costs nothing immediately and everything later.
   You are the enforcer: no dispatch before the map is approved.

**"Approval" can mean changing the executor's model — two mechanisms, pick by scope.**
The approved map may disagree with a role's agent file (e.g. the role sits on
`custom:anymodel / am/minimax-m3`, the user wants `zai / glm-5.3-flash`):
- project-specific choice → per-dispatch model override, if the harness
  offers one (zcode — spawn-time model selection; opencode — the Task tool's
  model parameter where available); the role's agent file stays untouched
  for its other projects;
- the user approves it as the role's new default → edit the role's agent
  file (`model` field) — and say explicitly that this changes every project
  of that role.
- A fallback-only change, where the harness supports it, is a separate
  fallback setting — the primary stays put, so this is narrower than a
  default change and affects only failover.

**Recovery when a dead-provider block already landed mid-run:** get explicit
approval → apply the model → record the approved map in the ledger →
re-dispatch the affected task. Do not invent a recovery the harness does not
offer: a task lost to a dead provider re-runs from its brief, the ledger
marks the wasted round.
