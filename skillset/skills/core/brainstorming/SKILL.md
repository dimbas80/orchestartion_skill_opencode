---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, modifying behavior, or planning anything new, in software or out of it. Triggers: «новая фича», «давай сделаем», «придумаем», «новый проект», «спроектируем». NOT for stress-testing an existing plan - that is grilling. NOT for clear small tasks (single-file fix, bug with clear repro, small well-defined change) — quick path instead: systematic-debugging / direct code + verification-before-completion (Routing Gate, README). Интервью → подходы → design doc в docs/product/."
---

# Brainstorming

You build what you believe your partner wants; that belief is usually thinner than it feels. This skill finds out what they actually want, and why, before anything is built. Full preamble and the Red Flags table: [references/rationale.md](references/rationale.md). Worked wordings of every message type: [references/examples.md](references/examples.md).

## First: What Do You Actually Know?

- **Everything that matters is in the request** ("make the icon cornflower blue") — quick, clear task: do it, say what you did.
- **Something non-trivial is missing** — start the conversation.

Before implementing, in order: lay out approaches in a message of their own → partner picks; write the design doc; get approval; offer grilling, then invoke writing-plans (core-only: hand the approved doc to the orchestrator — the plan is written by the planning module). Not implementing: an approved spike, and doing what they asked once they opted out of questions.

## Look Before You Ask

Existing project → initialize/refresh the code graph when `codegraph` is available and requested or `.codegraph-*` exists (`codegraph init .` → `status .` → `explore` for symbols before broad grep). Given context — a spec, a plan, a handoff, files, earlier conversation — dig in before your first message; keep reading until you can explain how the relevant parts work today and what the change would touch. Never ask what the project or their context already answers.

**Ready-made text** (IDEA.md, a note, a draft plan) is interview INPUT, not a replacement: read it first, ask about gaps, and actively hunt internal contradictions — each goes to the user as an explicit question (they supply the real values; never "на усмотрение архитектора"). Classes: value vs value; chosen part/setting vs its operating requirement; assumed runtime vs real deployment target. Unresolved items land in the decision log and the requirements' open-risks section.

## Your First Message

- **They've already said what they want** (spec, plan, detailed request): about 200 words. Echo the request back in your own words (what, for whom, why, as far as said); add what you found that bears on it; say plainly anything they may not have considered that would change the ask or the build (constraint, conflict, cheaper path); end with one line inviting corrections, then one question about the point their request leaves open whose answer most changes what gets built. Specs are often incomplete; confirm before building on one.
- **They haven't:** one open question in their own terms about the biggest unsettled thing, plus why you're asking (what the answer changes).

Ending depends on whether they asked for brainstorming. If yes — end with your question. If not — after the question add one light line offering to just get going ("Or if you'd rather I just dive in, say so."); if they take it, this skill is done: state any significant how-it-gets-made choice (platform, language, medium) in one plain line, then do the work through the normal workflow.

## The Conversation

One question per message — a single sentence, no example lists hanging off it. Plain language pitched just above your partner; match their vocabulary; never process jargon; never quote this skill at them. Lead with what matters; offer the rest.

- **Get them describing.** Open questions first — their words carry intent options can't; a short menu only when stuck; on "just guess" propose something concrete.
- **How it gets made.** Medium, tools, materials, resources: which they choose, which they hand you, what exists. Existing work → build on what it uses. Your choices go into the design as your call, never as something they agreed to.
- **Structured-document systems** (collections not numbered duplicate keys; never promise a template engine what it can't compute): [references/examples.md](references/examples.md).
- **Ground to cover** (territory, never a script): kind of thing and what makes it special; why now and what success looks like; goals, non-goals, anti-goals (what makes it fail even if it works); prior art loved and hated; current state and what they tried; details they care about.
- **Specific, Socratic questions:** build each on their last answer or something you found; when the reason isn't plain, say what you hope to learn. A correctable proposal plus your reason often beats a question.
- **Offer recon** once grounded (codebase/files/data or the web — say what you'd look for; they decide).
- **Lay out the approaches** before writing anything, in a message of its own: several real alternatives, drop the weak ones (against their why, or ruled out by existing work), present 2–3 grounded in what the project does and what each trades off; recommend one and say why; ask which way. Genuinely one sensible way → say so and why others don't fit.
- **Show, don't tell.** Offer the visual companion when seeing beats reading: something they'll look at, a layout, a flow, distinguishable options, structures easier to see than read. Accepted → mockups, side-by-side options, clickable throwaway prototypes.
- **Spike to feel things out:** a quick throwaway build is often the cheapest way to learn what they want or whether something works; when they just want to spike, get out of the way. No/minimal tests, skip plan/implementation/review; bring learnings back.

## Play It Back

As soon as one part is clear enough to describe, play it back (200–300 words), then return to questions about the next part; playback and questions alternate to the end. Only what they said goes in as theirs; anything you filled in is your proposal with your reason. End each chunk asking what's wrong or missing. If the chunk describes something they'll *look at* and the visual offer hasn't been made yet — send the offer instead (its own message) and hold the chunk; after acceptance put a mockup beside it.

## Terms and Decisions Go Down as You Go

A vocabulary term crystallises → `GLOSSARY.md` at repo root. A decision that changes future work → `docs/adr/`. Both created lazily with the first entry. Follow the project's domain-doc conventions (`docs/agents/domain.md` when present); full discipline → invoke domain-modeling. By the end of the interview the glossary already exists.

## Size the Work

Say how big the work is in plain words; they can override.

| Size | The design doc |
|------|----------------|
| A small change | a short one: what you already covered together, written down |
| A project | the full written design (below) |

Short or full, the doc has an **Approaches** part: the ways considered, what each trades off, which they picked and why — they pick in the conversation, before you write. Grows mid-task → stop, say so, step up a size. Really several independent projects → say so, agree an order, brainstorm one at a time.

**Too big or too foggy for a design doc** (won't fit a session, you can't even name the decisions it hangs on): don't force one — invoke wayfinder to chart a map of decision tickets; not installed → hand off to the orchestrator/architect (planning module).

## The Written Design

A plain document a talented builder in the domain could plan from without coming back to the partner: intent and why; goals/non-goals/anti-goals; constraints; approaches; their how-decisions; what's left to the builder. Small change: the same points in a line or two each, straight to the partner, no builder check.

**Where it goes, and the builder check** (fresh subagent with `builder-check-prompt.md`, or a reviewer-role subagent dispatch; three piles: answered / minor / theirs; one round of "theirs" questions): [references/design-doc.md](references/design-doc.md).

## After Approval: Offer the Stress-Test

Once the doc is approved, ask one question: stress-test the plan with grilling? Yes → invoke grilling, fold changes back into the doc, re-confirm those spots. Either way the next step is the plan: invoke writing-plans and no other skill.

<HARD-GATE>
Nothing gets built until the partner approves the design doc (short for a small change, full for a project). Building = product code, scaffolding, installing dependencies, creating projects, invoking any implementation skill. Reading and exploring are fine. Two exceptions: they opted out of the questions (the skill and its gate are done), and an approved spike (built throwaway only; keeping what it produced is a new request that comes back through this gate). After approval: grilling first if they want it, then writing-plans and no other skill.
</HARD-GATE>

## Visual Companion

A browser tab for mockups, diagrams, prototypes — a tool, not a mode; accepting doesn't send every question to the browser. Offer just-in-time, the first time one of the "show, don't tell" moments comes up, never upfront; the offer is its own message (wording in examples). Declined → stay in text, don't re-offer unless they raise it. Per question ask: would they understand this better by seeing it? Mockups, layouts, diagrams, side-by-side designs → browser; requirements, scope, tradeoffs, conceptual choices → text (a UI topic is not automatically a visual question). Accepted → read `visual-companion.md` in this directory before starting the server.
