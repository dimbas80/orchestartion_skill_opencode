# Examples (brainstorming)

Worked examples from past sessions. The classes and rules live in SKILL.md; these are the concrete wordings.

## First message when they've said what they want — the shape

Echo their request back in your own words (what they want, who it's for, why, as far as they've said), add what you found that bears on it, say plainly anything they may not have considered (constraint, conflict, cheaper path), end with one line inviting corrections, then one question about what they want. About 200 words total.

## First message when they haven't — worked example

One open question, in their own terms, about the biggest thing their request leaves unsettled, plus why you're asking: what the answer would change about what you build. For "a website for my bakery": "If it's mostly for people deciding whether to stop by, I'd lead with hours and what's in the case today; taking orders is a different site. What do you want someone to do when they land on it?"

## Socratic follow-up — worked example

Build each question on their last answer or on something you found, so it helps them think through a consequence or a case they may have missed: "Voting closes before the meeting, and two members joined this month. Does someone who joins mid-round get a vote?"

## Opt-out offer wording

After your question, add a light, one-line offer to just get going instead: "Or if you'd rather I just dive in, say so." If they take you up on it, this skill is done: state any significant how-it-gets-made choice (platform, language, medium) in one plain line, then do what they asked through the normal workflow.

## Visual companion offer wording

The offer is its own message with nothing else in it:

> "This might be easier if I show you. Want me to open a browser tab with some mockups?"

## Contradiction-hunt examples — classes, not scripts

Examples from past projects are illustrative; the classes in SKILL.md (value vs value, chosen part vs its operating requirement, assumed runtime vs real deployment target) are what matters. Unresolved items land in the decision log and the requirements' open-risks section.

## Structured-document systems (from SKILL.md)

Model repeated entities as a collection of objects, not numbered duplicate keys: `collection → validate → calculate each item → render a loop`, keeping input fields, per-item computation and rendered output separate. Do not promise that a template engine computes what it has no mechanism for — inspect the format's representation and verify computed-field substitution separately (declarative templating does not rewrite embedded formula objects).
