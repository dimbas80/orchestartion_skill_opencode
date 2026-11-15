# The Written Design + Builder Check (full mechanics)

Moved verbatim from SKILL.md. Read when writing the design doc.

A plain document a talented builder in the domain could plan from without coming back to the partner. Cover: intent and the why; goals, non-goals, anti-goals; constraints; approaches; the parts of the how they decided, as they decided them; what's left to the builder.

For a small change, the short design covers the same points in a line or two each and goes straight to the partner, without the builder check.

**Where it goes:** in a software project using the orchestration template (`.hermes/orchestration.yml` present), into `docs/product/` — follow the project's artifact policy (e.g. `product-spec.md`, or `requirements.md` when the doc is requirements-shaped), committed. Otherwise, ask. Your partner's preferences override both.

**Builder check** (for a project): dispatch a fresh subagent with `builder-check-prompt.md` in this directory — in the multi-profile setup create a kanban task for the reviewer profile instead of an in-session subagent. When you tell your partner you're writing it up, say a reviewer will read it first and you may come back once with a few questions. Don't hand over the document until the check is back. Sort what the builder asks into three piles:

- **Answered already** by the conversation or the project: put the answer in the document.
- **Minor:** a sensible builder could settle it without changing what gets built. Settle it yourself and mark it in the document as your call.
- **Theirs:** only your partner can answer it, and the answer changes what gets built.

Bring the "theirs" pile in one message, most important first. Update the document with their answers, then hand it over with a short list of the calls you made so they can check those while reading. That's the only round of questions the check produces. Without a subagent tool, read the document as that builder yourself.
