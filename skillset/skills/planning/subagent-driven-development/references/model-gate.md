# Model Gate — full mechanics (SKILL.md holds the required 4-step summary)

## Confirm Models & Providers Before Dispatch (REQUIRED GATE)

Before creating ANY kanban tasks for a plan, confirm the model map with your
human partner. Providers differ in reliability (some — like anymodel — have
temporarily unavailable models or paused subscriptions), and a worker that
discovers a dead provider mid-task burns the budget of the whole run.

1. Build the map: **every executor profile the plan will touch** (coder,
   reviewer, architect — whoever the routing policy assigns tasks to) →
   provider/model, read from each profile's `config.yaml`
   (`model.provider`, `model.default`). The reviewer is part of the map:
   the final whole-branch review is a capable-model job by design.
   When the user names a model in shorthand (e.g. «deepseek-flash»), resolve it
   to the exact model id from `config.yaml`/`custom_providers` (e.g. `deepseek-v4-flash`)
   and state what you set — never write a shorthand that is not a real model id.
   **A provider's id namespace is not the profile's default string.** The same
   model usually has a different id per provider (a bare `glm-5.3-flash` on one,
   a slash-prefixed `glm/glm-5.3` on another), and the profile default is only
   valid for the provider that profile is configured with. When the approved map
   names provider P + model M, list P's own models (`GET <base_url>/models` with
   that provider's key) and copy the id it returns verbatim; an id from the wrong
   namespace fails at worker spawn, after the claim, not at creation.
2. Present it as a table and ask for explicit approval. For unreliable
   providers, propose the fallback: which profile/model takes over.
3. Offer a cheap health-check per executor (a one-token test call through that
   profile) — recommended for flaky providers before a long run. Probe with the
   exact id you are about to pin, using the profile's OWN `.env` key, not the
   orchestrator's: the same vendor key can return 429 "Insufficient balance" on
   one base path and 200 on another (vendors host several API planes under one
   domain, and the profile's `.env` may omit the base override) — try the
   vendor's alternate documented base path before declaring the key or model dead.
   Read the result correctly: a 200 with empty
   content is a working model (reasoning models often emit no text at a tiny
   `max_tokens`), while an empty or non-JSON body is a retry, not a verdict —
   probe twice before calling a provider dead, then report it and ask which
   fallback to apply instead of swapping on your own.
4. Record the approved map in the ledger and in the first kanban task's body.
5. NEVER switch a profile's model/provider silently mid-run. If a provider dies
   (worker fails on an unavailable model, the circuit breaker trips):
   `kanban_block` the task, ask your human partner which fallback to use,
   apply it, unblock. A silent model swap is a decision made in secret.
6. **The gate is enforced, not advisory.** Skipping it does not merely break
   policy — a supervisor (the mentor/наставник) auto-blocks the task with
   "Model Gate: модель не утверждена" before the worker runs. There is no
   fast path; the first dispatch is where the block lands.

**"Approval" can mean changing the executor's model — two mechanisms, pick by scope.**
The approved map may disagree with a profile's `config.yaml` (e.g. the profile sits on
`custom:anymodel / am/minimax-m3`, the user wants `zai / glm-5.3-flash`):
- project-specific choice → pin it per task: `hermes kanban set-model [--provider P] <task_id> <model>`
  (the profile's global config stays untouched for its other projects);
- the user approves it as the profile's new default → patch the profile's `config.yaml`
  (`model.provider` / `model.default`) — and say explicitly that this changes every
  project of that profile. A fallback-only change edits the `fallback_providers` list
  (each entry `provider`/`model`) instead of the primary keys — the primary stays put,
  so this is narrower than a default change and affects only failover.

**Recovery when the block already landed:** get explicit approval → apply the model
(per-task `set-model`, or patch the profile config when the user chose that) → record
the approved map in the task body via `kanban_comment` → `kanban_unblock`. Do not
recreate the task: the blocked card carries the context, and the supervisor re-checks
it on unblock.

