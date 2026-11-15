---
name: wayfinder
description: "Большая работа-«туман» (не влезает в одну сессию, путь не виден): проложить КАРТУ решений — destination, тикеты-вопросы (research/prototype/grilling/task), frontier — и разрешать их по одному, пока путь не станет ясен. Триггеры: «большая работа», «не влезает в сессию», «непонятно как подступиться», wayfinder. Plan, don't do."
---

# Wayfinder

A loose idea too big for one session, wrapped in fog: the way to the **destination** isn't visible. Wayfinding finds that way — it charts a **shared map** on the repo's issue tracker, then works its **decision tickets** (questions whose resolution is a decision) one at a time until the route is clear. Naming the destination is the first act of charting: it shapes every ticket and fixes the scope. Expanded rationale for every section below: [references/concepts.md](references/concepts.md).

**Plan, don't do.** Each ticket resolves a decision; the map is done when nothing is left to decide before someone goes and does the thing. The pull to just do the work usually means you've reached the edge of the map — hand off. An effort may override this in its **Notes**, carrying execution into the map; absent that, produce decisions, not deliverables.

**Refer by name.** Every map and ticket is an issue with a title; in everything the human reads refer to it by that name, never a bare id/number/slug. The link rides inside the name.

## The Map

The map is a single issue labelled `wayfinder:map` — the canonical artifact; tickets are its child issues. The map is an **index**, not a store: it lists decisions and points at the tickets that hold their detail; a decision lives in exactly one place, its ticket.

**Tracker mechanics** (map, child tickets, blocking, frontier queries) live in the project's tracker doc "Wayfinding operations" — `docs/agents/issue-tracker.md` (local-markdown tracker in `.scratch/<effort>/`: `map.md` + `issues/NN-slug.md`, `Status: claimed/resolved`, `Blocked by:` lines). No tracker doc → default to that local-markdown tracker.

### The map body

The whole map at low resolution, loaded once per session; open tickets are NOT listed (they are open child issues, found by query). Sections: **Destination** (what the end looks like, 1–2 lines), **Notes** (domain; skills to consult; standing preferences), **Decisions so far** (index: one line per closed ticket with gist + link), **Not yet specified** (in-scope fog), **Out of scope** (ruled beyond the destination). Exact markdown skeleton and the ticket body template: [references/map-templates.md](references/map-templates.md).

### Tickets

Each ticket is a child issue of the map; its body is the question, sized to one 100K token agent session.

Each ticket carries one `wayfinder:<type>` label — `research`, `prototype`, `grilling`, `task` (see [Ticket Types](#ticket-types)). `wayfinder:` labels are the only labels a map and its tickets carry — never a triage label like `ready-for-agent`: they are decisions, not implementation work.

A session **claims** a ticket by assigning it to the dev driving the map, **first**, before any work, so concurrent sessions skip it — an open, unassigned ticket is unclaimed. Blocking uses the tracker's **native** dependency relationship (it renders the frontier visually in the tracker UI); only a tracker lacking native blocking falls back to a body convention. **Unblocked** = every blocking ticket closed. The **frontier** = open, unblocked, unclaimed children — the edge of the known.

The answer isn't part of the body; it's recorded on resolution (see [Work through the map](#work-through-the-map)). Assets created while resolving a ticket are linked from the issue, not pasted in.

## Ticket Types

Every ticket is either **HITL** (worked _with_ a human who speaks for themselves; only that live exchange resolves it — an agent answering its own grilling questions has broken this) or **AFK** (agent-driven alone).

- **Research** (AFK): reading docs, third-party APIs, or local resources to surface a fact a decision waits on. Resolved by a research subagent that loads the research skill. Use when knowledge outside the current working directory is required.
- **Prototype** (HITL): raise the fidelity of the discussion with a cheap, rough, concrete artifact to react to (an outline, a rough take, a stub, or UI/logic code) by loading the spike skill — this set's prototype skill. Links the prototype as an asset. Use when "how should it look/behave" is the key question.
- **Grilling** (HITL): conversation, the default case. Always load the grilling and domain-modeling skills.
- **Task** (HITL or AFK): manual work that must happen before a _decision_ can be made — nothing to decide, prototype, or research, but the discussion is blocked until it's done (signing up for a service to judge its API, provisioning access, moving data to see its shape). This is the one type that _does_ rather than decides, and it earns its place by unblocking a decision. Agent drives it alone where it can (AFK); otherwise hands the human a precise checklist (HITL). Resolved when done; the answer records what was done and any resulting facts (credentials location, new URLs, row counts) later tickets depend on.

## Fog of war

The map is _deliberately_ incomplete: beyond the live tickets lies the **fog of war** — decisions you can tell are coming but can't yet pin down because they hang on open questions. Resolving a ticket clears the fog ahead of it, graduating whatever is now specifiable into fresh tickets, one at a time, until the way is clear and no tickets remain.

**Fog or ticket?** Ticket when the question is already sharp now, even if blocked; **Not yet specified** when you can't phrase it that sharply — don't pre-slice the fog. It excludes what's already decided, what's a live ticket, and what's out of scope.

## Out of scope

Work beyond the destination is **out of scope** — not fog, its own map section. Scope, not sharpness, lands it there; it never graduates. A ticket that turns out to sit past the destination: **close it**, one line in Out of scope (gist + why, linked) — never in Decisions so far. Full reasoning: [references/concepts.md](references/concepts.md).

## Invocation

Two modes. Either way, **never resolve more than one ticket per session**, with the exception of research tickets.

### Chart the map

User invokes with a loose idea.

1. **Name the destination.** Load the grilling and domain-modeling skills to pin down what this map is finding its way to. The destination fixes the scope, so it's settled first.
2. **Map the frontier.** Grill again, **breadth-first**: fan out across the whole space rather than deep on one thread, surfacing open decisions and the first steps takeable now. **If this surfaces no fog** (the way is already clear, the journey fits one session), you don't need a map — stop and ask the user how to proceed.
3. **Create the map** (label `wayfinder:map`): Destination and Notes filled in, Decisions-so-far empty, the fog sketched into Not yet specified.
4. **Create the tickets you can specify now** as child issues, then wire blocking edges in a **second pass** (issues need ids before they can reference each other). Write cross-references in that pass too, with real ids — a placeholder `#<n>` auto-links to an unrelated issue. Wiring sorts them into frontier and blocked; the rest stays in Not yet specified.
5. **Fire the research subagents.** For each `research` ticket, spin up one research subagent per research ticket, loading the research skill, to resolve them in parallel, capturing findings on a throwaway `research/<name>` branch with a context pointer from the ticket. Push the branch if the repo has a remote (open no PR: it is never merged); otherwise keep it local.
6. Stop: charting is one session's work; it hand-resolves nothing.

### Work through the map

User invokes with a map (URL or number). A ticket is **optional**: without one, you pick the next decision, not the user.

1. Load the **map**: the low-res view, not every ticket body.
2. Choose the ticket — the one the user named, otherwise the first frontier ticket in order. **Claim it**: assign it before any work.
3. Resolve it as the type its `wayfinder:<type>` label names (see Ticket Types). Read the label, not just the body: the body never states the type. **Zoom as needed**: fetch the full body of any related or closed ticket on demand; load whichever skills `## Notes` names. If in doubt, load the grilling and domain-modeling skills.
4. Record the resolution: post the answer as a **resolution comment**, **close** the issue, **append a context pointer** to the map's Decisions-so-far.
5. Add newly-surfaced tickets (create-then-wire); graduate any fog the answer made specifiable, clearing each graduated patch from Not yet specified so it lives only as its new ticket. If the answer reveals a ticket sits beyond the destination, **rule it out of scope** rather than resolving it on the route. If the decision invalidates other parts of the map, update or delete those tickets.

The user may run unblocked tickets in parallel — expect other sessions editing the tracker concurrently.
