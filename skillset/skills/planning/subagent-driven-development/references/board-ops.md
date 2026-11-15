# Board operations — SDD (read before ANY kanban CLI operation)

Moved from SKILL.md «Running the board». Lessons are verbatim; read whole file once per session before board work.

- **Dispatch without hanging your shell.** `hermes kanban dispatch` spawns the
  worker as a detached process that inherits stdout, so the call can sit open
  (or return an orphan-recovery warning) even though the worker started fine.
  Always run it redirected and bounded:
  `timeout 90 hermes kanban --board <slug> dispatch --max 1 > <log> 2>&1 < /dev/null`.
  `Spawned: 1` in the log is the confirmation; re-check with `hermes kanban list`.
- **Stop a running worker** (the owner interrupts, or the requirement changes):
  `hermes kanban reclaim <id>` releases the claim and ends the run, then
  `hermes kanban block <id> --kind needs_input "<one line why>"`. The reason is a
  POSITIONAL argument — there is no `--reason` flag.
- **Re-spec an existing card, never recreate it.** Write the new body to a file
  and `hermes kanban edit <id> --title T --body "$(cat body.md)"` (`edit` takes
  only `--body` — there is no `--body-file` flag on it, unlike `create`), then
  `hermes kanban unblock <id>`. Recreating loses the run history and the
  dependent cards' dependency edges. Re-spec has a window: while the card is
  still gated/`todo`. Once a worker holds the claim it has already read the body — put the finding in `kanban_comment` on that card (durable, and the reviewer
  card can point at it) and add the item to the reviewer's checklist, so a
  missed bit returns as CHANGES_REQUESTED instead of shipping. The claim can
  also land within seconds of `create` — a POST-CREATE body fix carries the
  same race: compare the `claimed` and `edited` events in the card history before
  assuming the running worker saw the corrected body; when a fix landed after
  the claim, repair the corrupted body AND anchor it with a `kanban_comment`
  that names the current body authoritative (the worker re-reads on its next
  turn, a comment is the only thing guaranteed to reach it). Read a body back
  with `show <id> --json | python3 -c "…['task']['body']" > f.md`; scan that
  read-back for foreign-glyph/merged-word fragments before declaring it clean —
  a body verified once at emit time is not a body verified after the `edit`.
  Never call
  bare `show` to check status — it echoes the whole body and comment thread
  back into your context. Status/assignee/model checks are `list --json` piped
  through a filter.
- **A spec change also rewrites the dependent cards.** The reviewer task's body
  encodes the spec it checks against; edit only the implementer's card and the
  reviewer will demand the old design. Edit both, then dispatch.
- **Two dispatches that edit overlapping files serialize by a parent edge, not
  by timing luck.** Workers in their runs hold no shared lock with your shell
  session and do not see each other — two cards touching the same header or
  loop region corrupt or double-patch each other's hunks. Create the second
  card with `--parent <first-id>` so the dispatcher holds it in `todo` until
  the first reaches `done`, and fold the second card's independent items in
  (batching beats a third touch of the same file). To add a dependency edge
  AFTER both cards exist: `hermes kanban --board <slug> link <parent-id>
  <child-id>` — both ids positional, no flags (`--parent/--child` die with
  `unrecognized arguments`); use it when priorities force an out-of-order
  chain (urgent hotfix between two waves on the same file). When the second card must
  run while a structural card is already in flight, serialize in the body
  instead: an explicit file allowlist that excludes the running card's files,
  a prohibition on `git restore`/`checkout` of anything outside it (the worker
  would otherwise revert the in-flight card's half-done edits), and an
  instruction to build on whatever it finds in the tree.
- **Dirty-tree safety.** Workers run in the live project dir
  (`workspace_kind=dir`), not a throwaway worktree. Record `git status --short`
  at session start (and the fact that those dirty files are the owner's), so a
  re-spec can rip out a half-done worker's edits with
  `git checkout -- <exactly the files that were clean then>` without touching
  the owner's uncommitted work. Read the worker's `git diff` first and confirm it
  holds nothing but that worker's changes.
- **Park, then re-decide, then unblock.** A blocked card keeps its context and
  its comment history; that is why the owner's answer goes back onto the same
  card instead of a fresh one.
- **`triage` is the backlog lane; `promote` will not move it.** `hermes kanban
  promote <id>` accepts only `todo`/`blocked`; a card created with
  `triage: true` — the right initial state for work the owner has not chosen
  yet, since triage cards are never dispatched — is released with
  `hermes kanban specify <id>`, which moves it to todo/ready for the
  dispatcher. Create owner-pending candidates in triage, then specify the one
  the owner picks.
- **Prep the card BEFORE `specify`, not after.** Releasing a triage card hands
  it to the dispatcher within a tick: the body you wrote at triage time is what
  the worker reads, and with no per-task pin it runs on the assignee profile's
  `config.yaml` model — an unapproved model, and the Model Gate violation lands
  as a live run, not as a refused dispatch. So the order is: rewrite the body
  (`--body "$(cat body.md)"`, board flag on the `kanban` command, not the
  subcommand), `set-model`, then `specify`. Caught after the fact, the fix is
  `reclaim` → `set-model` → let the dispatcher retry; check `git status` over
  the worker's paths first, since the aborted run may already have written
  files.
- **Rework after both cards are done: a fresh follow-up task, not a reopen.**
  `unblock` and `reopen-review` refuse cards in `done` — a CHANGES_REQUESTED
  discovered after the review card closed cannot requeue the implementer.
  Open a NEW task parented on the review card, scope narrowed to exactly the
  reviewer's Required Changes (e.g. tests only, game files untouched), body
  carrying them verbatim; leave a comment on the done card for history.
- **With a separate reviewer card, the implementer card must say
  `kanban_complete`, not `kanban_request_review`.** The worker's own lifecycle
  moves its card into the review lane, so the reviewer picks up the implementer
  card — under the implementer's model — while your reviewer card sits gated on
  the same diff: two review seats on one change, and the board shows the
  implementer still running in `review`. Put the instruction in the card body
  ("close with `kanban_complete`; independent review is a separate card").
  When you forget it, the symptom is a notice naming the *implementer* card as
  `@reviewer … done` and its assignee flipping to the reviewer: that is the
  duplicate seat consuming your change, not a second opinion — the reviewer card
  is still gated on the same diff.
- **Review-lane worker crashes at spawn with `kanban_skills_unavailable`.**
  The review lane force-loads `sdlc-review`; if that name sits in the
  assignee profile's `skills.disabled`, every review run dies in ~10 s
  (exit 1, empty output) and the card lands in `blocked` after two retries.
  Check the profile config's `skills.disabled` before blaming the model;
  remove the name, then unblock or (when a separate reviewer card exists)
  complete the implementer card — never recreate it.
- **A crash's cause picks the response; three look identical on the board.**
  `hermes kanban --board <slug> runs <id>` prints outcome, elapsed and the
  worker's last line. `Kanban owner refused: Gateway disconnected; turn outcome
  is unknown` is infrastructure: the dispatcher retries by itself and no model
  change is warranted — but check `git status`/`git diff` over the worker's paths
  before the retry gets far, so half-written edits from the dead run are known
  and a retry is not mistaken for progress. A spawn-fail with rc=0 and no kanban
  call at all is a bad `model_override`; a wall of `APITimeoutError` is the
  provider. Only the latter two justify touching the model map, and only after
  asking.
- **The card body is a tool argument, not a document.** A body pasted straight
  out of your reasoning can pass the transport limit: a multi-kilobyte card
  stalls the call and returns nothing. Keep the body to the contract (objective,
  read/modify lists, bounds, acceptance) and put the long spec — long
  tables, dump excerpts, findings — in a project file (`.scratch/<wave>/…md`)
  that the body names as read-first. Same for edits: assemble the new body in
  pieces in a file, then `--body "$(cat f.md)"`.
  The stall is not specific to card bodies: a long spec file written in a single
  `write_file` call fails the same way. Write it in two or three smaller pieces
  (or create it small and `patch` it), keep the card body to one screen, and let
  the body point at the spec file.
- **Degeneration of long inline emission is a class, and the transport stall is
  only one of its faces.** The same root condition — one long/multi-line/nested
  structured payload passed inline — shows up as at least three distinct
  symptoms: (a) the kanban call stalls on the body; (b) the arguments of a
  structured tool call break up at the field boundary (the parse error lands at
  the `arguments`/`name` seam — e.g. "Expecting property name") and the failure
  column moves with the payload; (c) the emitted long string carries corrupted
  character fragments (foreign-glyph or merged-word tokens) that survive into
  the stored card and become the worker's instructions. Rule: long or
  multi-line content NEVER goes inline — compose it in a file and hand it over
  by path or `$(cat file)` (card body, spec file, any structured argument);
  keep structured tool-call arguments flat and short (a couple of short string
  fields); split multi-line call payloads into several small calls. Proofread a
  long argument right after emitting it (re-read the stored BODY and the TITLE
  before a worker claims the card — a corrupted token mid-title survives a
  body-only check and mislabels the card for its whole life; fix it with
  `hermes kanban edit <id> --title T`) — corrupted fragments are not recoverable
  later, only rewriteable.
- **Comments ride the same degeneration class — and they are immutable.**
  A comment can be neither edited nor deleted after posting. When a check via
  `kanban_show` shows CJK-fragments, merged words or shifted meaning in a
  fresh comment (do the same proofread for comments as for bodies — the
  claimed worker reads the whole thread), post an explicit invalidation
  comment (`comment <id> INVALID — read the next one`) and the corrected text
  as a NEW comment. Never let one corrupted instruction stand unannounced:
  the worker that claims the card cannot know which of two contradictory
  comments is yours.
- **A multi-round review file accumulates verdicts — the operative one is the
  LAST `## Вердикт`/`Verdict` section, not the first.** Each rework round
  appends to the same `review.md`; grep every occurrence and read the final
  verdict plus which findings it closed before reporting the task's state.
  Retelling round 1's CHANGES_REQUESTED for a task whose final verdict is PASS
  is how a finished feature gets reported as blocked.
- **A multi-batch review card writes its artifacts into the BATCHES' dirs.**
  When one reviewer card covers several implementation cards, the natural
  instruction is one `review.md` per batch under `workflows/<batch-id>/` —
  then the reviewer card's own workspace stays empty by design. Check the
  batch dirs (and grep their final verdicts) before concluding the review did
  not happen; equally, put the per-batch paths into the card body explicitly,
  because a reviewer told only "write review.md" will put everything in one
  file and leave no verdict for the other cards. Ask for a verdict per batch in
  in the body — an aggregate PASS cannot tell which diff still needs a fix.
- **Line refs in a card built from an older review are stale by construction.**
  Each fix wave shifts every line below its edits, so a follow-up body that
  enumerates `file:line` from review time sends the worker hunting. Name the
  symbol and let the body say plainly "сверяй номера строк с текущим кодом",
  and treat the reviewer's own line refs in its findings as hints, not canon.
- **No external path can inject a turn into a client-owned session
  (desktop/TUI) — only the Bot Chat accepts one.** Probed: `notify+wake` and a
  raw `api_server:<session id>` self-post both end in HTTP 409
  `permission_denied` (12 retries, cursor stuck, nothing in the chat) for a
  desktop session of ANY profile, primary included — the client owns its
  session's only writer. The single injectable local chat is the profile's
  Bot Chat, and only through the session-authority door (`session_bot.deliver`,
  i.e. cron `--deliver bot-chat:<profile>`) — not through an API-turn binding.
  Practical consequence for a dispatcher that works in a TUI/desktop
  conversation: a monitor wake lands in a DIFFERENT chat (the Bot Chat) and
  that chat's agent answers there — the owner's working conversation is never
  woken, and an agent that says "the push does not reach me" is correct about
  its own chat. Either run dispatcher work in the Bot Chat, or make the monitor
  the owner-facing notifier (telegram) and treat the wake-in-Bot-Chat agent as
  the analyst.
- **Kanban `notify+wake` cannot wake an agent that lives in a LOCAL Bot Chat
  session — probe proved it, by design.** Two separate refusals: (a) a
  subscription stamped with a non-primary profile on a non-`api_server`
  platform is filtered out at route authorization (no `profile_routes` entry =
  no delivery, cursor never advances); (b) with `--platform api_server` and the
  profile's Bot Chat session id the subscription IS claimed, but the wake path
  binds the target as an API conversation and a local chat under a session
  authority refuses a second writer with `permission_denied` (12 retries, no
  wake, no message). The gateway log line to grep is
  `kanban notifier: wake self-post failed … permission_denied`. The working
  channel into such a session is exactly what the cron monitor already does —
  `--deliver bot-chat:<profile>` goes through the session-authority door
  (`session_bot.deliver`), not the API-turn binding. Consequence: board
  subscriptions are the right event source only when the destination is a
  routable messaging chat; for a local Bot Chat the cron monitor stays
  necessary. Remove a failing test subscription immediately — it retries every
  tick and floods the gateway log.
- **An agent's report about its own channels is a self-report — probe it.** The
  orchestrator claimed `bot-chat:<profile>` cron delivery "does not wake me";
  the delivery log showed zero bot-chat deliveries had ever been attempted. A
  one-shot probe job with `--deliver bot-chat:<profile>` disproved the claim:
  the injected prompt woke the agent, it answered the probe and cleaned the job
  up itself. Where the reply lands matters: the profile's canonical Bot Chat
  (a local chat), not the messaging lane — the owner sees the exchange only
  when that profile's chat is open, but the agent IS woken and acts.
- **Never hand-write a wave monitor — use the generator.** A canonical copy of
  the generator rides with this skill (`scripts/wave-monitor.sh`); the LIVE copy
  must sit in the profile's own scripts dir
  (`~/.hermes/profiles/orchestrator/scripts/wave-monitor.sh`) — cron resolves
  `--monitor-script` bare filenames against that dir only, so after a skillset
  reinstall copy it back from the skill's `scripts/` before arming. Modes
  `arm <ids…> [--board --workdir --every --paused --telegram-chat ID --deliver "a,b"]`,
  `disarm-all`, `list`. `deliver` accepts a COMMA-SEPARATED list (the resolver
  splits on commas), so the useful combo is `telegram:<owner chat>,bot-chat:<profile>`:
  the Telegram copy reaches the owner where he reads, the bot-chat copy wakes the
  agent that acts. Pass the chat id explicitly — a bare `telegram` target means the
  profile's home_channel, which is unset on several profiles and fails silently.
  Verified end to end: one tick delivered to both lanes, the woken agent answered
  in the Bot Chat. `--name` is forced to a `wave-*` prefix so a forgotten test job
  is still caught by `disarm-all`.
  it validates each task id against the board BEFORE arming (a typo'd id makes a
  monitor that never matches), dry-runs the status script before creating the
  job (a broken verdict extractor prints an empty token forever), creates the
  job through the CLI with `--deliver bot-chat:<profile>` explicitly, and
  re-reads the jobs store afterwards (the CLI's `ok` proves nothing; the store
  holds `deliver`, `enabled` — paused jobs read `enabled: false` — and the
  monitor script name). Every hand-written predecessor failed for one of these
  exact reasons.
- **The verdict line's shape is not canonical — parse it format-agnostically.**
  Nothing historically pinned how the reviewer writes the verdict in
  `workflows/<id>/review.md`: both `## Вердикт: …` headings (the majority) and
  bold inline `**Вердикт: PASS**` lines occur. Grepping for one fixed shape
  (a heading, an English word only, the review card's own dir instead of the
  implementer's) yields an empty or constant token forever — the monitor never
  fires and the silence surfaces as the owner asking what is happening.
  Extract with one regex over both shapes:
  `(?:Вердикт|Verdict)\s*:?\s*\**\s*(CHANGES_REQUESTED|PASS)`, last match wins
  (rework rounds append; the operative verdict is the last one). The reviewer
  prompt templates now pin the shape (`## Вердикт: PASS` / `## Вердикт:
  CHANGES_REQUESTED` as the last section); older artifacts predate the pin.
  The verdict
  file lives in the IMPLEMENTER task's `workflows/` dir, not the review card's
  own — checking the review card's dir is the other silent-empty failure.
- **Notifications lag the board and contradict it.** A chat notice can report
  "worker crashed", "timed out (max_runtime=0s), will retry", or "retrying"
  for a run that actually finished — the completion notice for the same card
  arrives after. Card status and run history (`kanban_show`) are
  authoritative: check them before re-dispatching, recreating a card, or
  chasing a phantom crash.
- **Reading the tree while a worker holds the claim returns half-built states.**
  A generate/classify module re-imported mid-edit yields empty lists and missing
  keys that read like real defects; a grep started a minute ago sees a partial
  rewrite. Attribute the anomaly to "the worker is editing right now", and re-run
  the check after the card is `done` before you write it up as a finding or build
  a card body from it.
- **Board-less subcommands resolve the board by env.** `comment` (and any
  subcommand without a `--board` flag) fails with "unknown task" on a
  non-default board — prefix `HERMES_KANBAN_BOARD=<slug>`.
- **`--board` belongs to `kanban`, not to the subcommand.**
  `hermes kanban dispatch --board <slug>` dies with `unrecognized arguments`;
  the accepted form is `hermes kanban --board <slug> dispatch …`.
- **A per-item work list hides cross-item inconsistency — accept at class
  level, not per item.** When the card enumerates items (files, endpoints,
  checklist entries) and the shared behaviour is one idiom, checking each item against
  its own spec passes while the same input pattern behaves differently in two
  items: the coder copies the reference only where the list named it, and the
  reviewer verifies item-by-item, so nothing compares them. Two consequences.
  (a) The card's acceptance carries a class line — "every occurrence of this
  primitive in the data behaves identically" — and you verify it yourself by
  enumerating the primitive from the source data and diffing the per-item
  behaviour, not by reading the report. (b) A review that attributes behaviour
  to "the orchestrator's decision" is reporting your own split instruction
  back at you: re-read what you actually told the coder for the sibling items
  before treating the verdict as agreement.
- **A timed-out `clarify` is not an answer.** No response means the owner is
  away, not that they agreed: take the coherent default, write the decision and
  its rollback recipe (which files to revert, which table entries to drop) into
  the wave's journal, and say plainly in the final message what you decided and
  that it is reversible. Never resolve a decision the project already records
  (spec, `AGENTS.md`, a comment marked as the owner's) this way — that class
  waits for a real answer, and asking again is cheaper than a reverted tree.
- **A report's green suite counts only what the worker ran.** Check the
  ticket's acceptance batteries against the report's test list before
  dispatching review: a worker that ran only its new test file and lint can
  hide a 2-failure regression in a named static battery — the reviewer must
  re-run every battery the ticket names, not just the new suite.
- **A wave that changes a codebase-wide convention breaks old test pins.**
  Static probes pin shapes (a required text, a required element, a count);
  when the owner re-specs the convention, sweep test files for pins of the
  old shape BEFORE dispatch and put their update into the ticket — otherwise
  the worker ships a correct code change with a hidden failing battery it
  never ran. When it surfaces in the full run anyway: the code is right, the
  pins are stale, and the fix is a test-only follow-up — update probes to
  the new convention, never weaken or delete them. An extraction helper that
  reads one level of a structure misses nested items — helpers must descend
  to the nesting level the spec names.
- **A wave implemented without a card is reviewed from the tree, not from
  the card history.** A prior session can land a complete implementation
  (report + green runs, review artifact missing) with no live card, and its
  closing summary lags the tree — route from `git status` plus the wave's
  `report.md`/`review*.md`, never from the summary text. With nothing
  committed, the review-package script has no BASE/HEAD: build the package
  by hand as `git diff HEAD` plus a `=== NEW FILE: <path> (uncommitted) ===`
  section per untracked production file; workspace artifacts (ticket,
  report) stay out of the package — they are the brief, not diff. Pin the
  model map at creation rather than post-creation: the kanban create API
  takes `board`/`model`/`provider` directly — one call, no separate
  `set-model` window. And since no implementer card carried environment
  knowledge, put the working invocation forms (full-suite command, lint
  command, env workarounds) into the reviewer card body verbatim — a form
  reconstructed from an old summary's notes will contradict fixes made
  after that summary was written.
- **Deliverable files ride the CLI `attach`, not inline bytes.**
  `hermes kanban --board <slug> attach <id> <path>` takes a local path; pushing
  a sizeable binary through the inline-base64 tool call re-runs the long-payload
  degeneration above. Remove a mistaken attachment with `attach-rm <attachment_id>`
  (id from `attachments <id>`), and confirm an attach by the byte size in the
  attachments list — the tool's `ok` alone proves nothing about which file landed.


