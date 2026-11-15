# Skill mechanics

The skill-specific branch of [`writing-for-agents`](SKILL.md): what changes when the document is a skill (frontmatter, discoverability, and router skills). Everything else about writing it is the universal reference in `SKILL.md`.

## Invocation in Hermes

Hermes has exactly **one** invocation mechanism: `name` + `description` in the
YAML frontmatter. The agent discovers skills by description and runs them via
`skill_view(name=...)`; the human reaches the same skills by name. There is no
`disable-model-invocation` flag, no user-invoked/model-invoked split, and no
Settings/Claude Code-style switch — do not write skills that rely on them.

Practical consequences:

- **The description is the trigger.** It is always loaded, so it costs
  permanent context: write it as the top-level pointer (the pointer-writing
  rules in `SKILL.md` apply in full), carrying the trigger branches the agent
  will actually match. A skill whose description is vague simply never fires.
- **Any skill can reach any other skill** by naming it — no reachability
  restriction exists. Shared reference needed by several skills can live in one
  skill (in `references/` or a companion `.md`) and be loaded on demand.
- **Loading is on demand:** the body of a skill is read only when it fires or
  when another skill/route loads it, so long skill bodies don't sit in context.
  Keep the SKILL.md body a set of instructions; move long examples into
  `references/` files and point at them.
- **Skill directory convention:** `${HERMES_HOME}/skills/<name>/SKILL.md`
  (profile skills live under `~/.hermes/profiles/<profile>/skills/`). A skill
  may ship `references/`, `scripts/`, `templates/`, `assets/` next to
  `SKILL.md`; refer to them by paths relative to the skill's own directory
  (the agent gets that path from `skill_view`), never as absolute machine paths.

## Splitting by discoverability

The sequence cut lives in `SKILL.md`. Split off a separate skill when you have a
distinct leading word that should trigger it on its own — a trigger word you
actually use in your prompts — or when another skill must reach it. You pay
context load for the new always-loaded description, so independent reach has to
be worth it.

## Router skills

When the skill set grows past what the description triggers can separate
cleanly, a **router skill** — one skill that names the others and when to reach
for each — keeps the entry point small: the agent fires the router, the router
loads the specific skill. It is advice, not enforcement: the agent may also
reach the specific skill directly, so the router body must carry clear
selection criteria.

## Checking a skill before shipping it

1. Frontmatter parses (`name`, `description`) — no Claude-Code-only keys.
2. The description alone tells the agent when to fire; triggers are concrete words.
3. Every file the body points at exists inside the skill's directory (relative
   paths only — no `/root/...`, `/home/...`, `/mnt/...`).
4. Every skill named in the body exists in the target profile — or the
   hand-off is explicit ("this profile does not ship X; hand the task to …").
5. Scripts are executable, have a shebang, and are invoked via
   `<skill_dir>/scripts/...` (the terminal starts in the project directory).
