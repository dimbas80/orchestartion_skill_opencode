# Dispatch operations — SDD (read before any non-trivial dispatch decision)

Moved from SKILL.md «Running the board»; neutralized from the original
board-ops lessons. Read whole file once per session before dispatch-heavy work.

- **Never dispatch two implementers in parallel on overlapping files.**
  Workers hold no shared lock and do not see each other — two dispatches
  touching the same header or loop region corrupt or double-patch each
  other's hunks. Serialize explicitly: order the dispatches so the second
  waits for the first's completion (synchronous harnesses do this by
  construction; background-agent harnesses need an explicit ordering), and
  fold the second dispatch's independent items in (batching beats a third
  touch of the same file). When the second must run while a structural
  dispatch is already in flight, serialize in the body instead: an explicit
  file allowlist that excludes the running dispatch's files, a prohibition
  on `git restore`/`checkout` of anything outside it (the worker would
  otherwise revert the in-flight dispatch's half-done edits), and an
  instruction to build on whatever it finds in the tree.
- **Dirty-tree safety.** Workers run in the live project dir, not a
  throwaway worktree. Record `git status --short` at session start (and the
  fact that those dirty files are the owner's), so a re-dispatch can rip out
  a half-done worker's edits with
  `git checkout -- <exactly the files that were clean then>` without touching
  the owner's uncommitted work. Read the worker's `git diff` first and
  confirm it holds nothing but that worker's changes.
- **A paused task keeps its memory in files, not in the queue.** When you
  park a task (owner away, decision pending), the ledger line and the
  report file carry its state; the owner's answer goes into the NEXT
  dispatch's body — a fresh dispatch re-reads brief + report + answer.
  Never rely on a "blocked" marker in any tool to preserve context.
- **The dispatch prompt is a tool argument, not a document.** A prompt
  pasted straight out of your reasoning can break the call: a
  multi-kilobyte prompt stalls, truncates, or arrives corrupted. Keep the
  prompt to the contract (objective, read/modify lists, bounds, acceptance)
  and put the long spec — long tables, dump excerpts, findings — in a
  project file (`.scratch/<wave>/…md`) that the prompt names as read-first.
  Same for edits: assemble long content in a file and hand it over by path.
- **Degeneration of long inline emission is a class, and the transport
  stall is only one of its faces.** The same root condition — one
  long/multi-line/nested structured payload passed inline — shows up as at
  least three distinct symptoms: (a) the call stalls; (b) the arguments of
  a structured tool call break up at the field boundary (the parse error
  lands at the `arguments`/`name` seam — e.g. "Expecting property name") and
  the failure column moves with the payload; (c) the emitted long string
  carries corrupted character fragments (foreign-glyph or merged-word
  tokens) that survive into the stored artifact and become the worker's
  instructions. Rule: long or multi-line content NEVER goes inline — compose
  it in a file and hand it over by path; keep structured tool-call arguments
  flat and short (a couple of short string fields); split multi-line call
  payloads into several small calls. Proofread a long argument right after
  emitting it (re-read the stored TITLE and the file the worker will read
  before it is claimed) — a corrupted token mid-title survives a body-only
  check and mislabels the work for its whole life; corrupted fragments are
  not recoverable later, only rewriteable.
- **A multi-round review file accumulates verdicts — the operative one is
  the LAST `## Вердикт`/`Verdict` section, not the first.** Each rework
  round appends to the same `review.md`; grep every occurrence and read the
  final verdict plus which findings it closed before reporting the task's
  state. Retelling round 1's CHANGES_REQUESTED for a task whose final
  verdict is PASS is how a finished feature gets reported as blocked.
- **The verdict line's shape is not canonical — parse it format-agnostically.**
  Nothing historically pinned how the reviewer writes the verdict in
  `workflows/<id>/review.md`: both `## Вердикт: …` headings and bold inline
  `**Вердикт: PASS**` lines occur. The templates now pin the shape (`## Вердикт: PASS` / `## Вердикт: CHANGES_REQUESTED` as the last section), but older artifacts
  predate the pin. Extract with one regex over both shapes:
  `(?:Вердикт|Verdict)\s*:?\s*\**\s*(CHANGES_REQUESTED|PASS)`, last match
  wins (rework rounds append; the operative verdict is the last one). The
  verdict file lives in the IMPLEMENTER task's `workflows/` dir, not the
  reviewer dispatch's own — checking the wrong dir is the silent-empty
  failure.
- **Watching a wave without polling.** Keep working while you have local
  work. In harnesses with background agents, run the dispatch in the
  background and act on completion notification; otherwise wait in bounded
  stretches (5–10 min) with a one-line status between them — never poll a
  wait interface with short timeouts. When you must watch a file for a
  verdict (e.g. from a cron-like facility), write a DETERMINISTIC status
  script (print the tracked ids' status + the verdict token via the regex
  above; no timestamps), dry-run it BY HAND before arming anything (a wrong
  extraction path prints an empty token forever), and remove the watcher
  when the verdict lands — a forgotten recurring monitor re-reports the
  same verdict forever.
- **A multi-batch review dispatch writes its artifacts into the BATCHES'
  dirs.** When one reviewer dispatch covers several implementation
  dispatches, the natural instruction is one `review.md` per batch under
  `workflows/<batch-id>/` — then the reviewer's own workspace stays empty
  by design. Check the batch dirs (and grep their final verdicts) before
  concluding the review did not happen; equally, put the per-batch paths
  into the dispatch body explicitly, because a reviewer told only "write
  review.md" will put everything in one file and leave no verdict for the
  other cards. Ask for a verdict per batch in the body — an aggregate PASS
  cannot tell which diff still needs a fix.
- **Line refs in a dispatch built from an older review are stale by
  construction.** Each fix wave shifts every line below its edits, so a
  follow-up body that enumerates `file:line` from review time sends the
  worker hunting. Name the symbol and let the body say plainly "сверяй
  номера строк с текущим кодом", and treat the reviewer's own line refs in
  its findings as hints, not canon.
- **Reading the tree while a worker holds it returns half-built states.**
  A generate/classify module re-imported mid-edit yields empty lists and
  missing keys that read like real defects; a grep started a minute ago
  sees a partial rewrite. Attribute the anomaly to "the worker is editing
  right now", and re-run the check after the dispatch completes before you
  write it up as a finding or build a dispatch body from it.
- **A timed-out `clarify` is not an answer.** No response means the owner
  is away, not that they agreed: take the coherent default, write the
  decision and its rollback recipe (which files to revert, which table
  entries to drop) into the wave's journal, and say plainly in the final
  message what you decided and that it is reversible. Never resolve a
  decision the project already records (spec, `AGENTS.md`, a comment
  marked as the owner's) this way — that class waits for a real answer,
  and asking again is cheaper than a reverted tree.
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
  never ran. When it surfaces in the full run anyway: the code is right,
  the pins are stale, and the fix is a test-only follow-up — update probes
  to the new convention, never weaken or delete them. An extraction helper
  that reads one level of a structure misses nested items — helpers must
  descend to the nesting level the spec names.
- **A wave implemented without a dispatch is reviewed from the tree, not
  from history.** A prior session can land a complete implementation
  (report + green runs, review artifact missing) with no live record, and
  its closing summary lags the tree — route from `git status` plus the
  wave's `report.md`/`review*.md`, never from the summary text. With
  nothing committed, the review-package script has no BASE/HEAD: build the
  package by hand as `git diff HEAD` plus a `=== NEW FILE: <path>
  (uncommitted) ===` section per untracked production file; workspace
  artifacts (ticket, report) stay out of the package — they are the brief,
  not diff. Pin the model map before the first dispatch rather than after.
  And since no implementer carried environment knowledge, put the working
  invocation forms (full-suite command, lint command, env workarounds) into
  the reviewer dispatch body verbatim — a form reconstructed from an old
  summary's notes will contradict fixes made after that summary was written.
- **Per-item work list hides cross-item inconsistency — accept at class
  level, not per item.** When the body enumerates items (files, endpoints,
  checklist entries) and the shared behaviour is one idiom, checking each
  item against its own spec passes while the same input pattern behaves
  differently in two items: the coder copies the reference only where the
  list named it, and the reviewer verifies item-by-item, so nothing
  compares them. Two consequences. (a) The body's acceptance carries a
  class line — "every occurrence of this primitive in the data behaves
  identically" — and you verify it yourself by enumerating the primitive
  from the source data and diffing the per-item behaviour, not by reading
  the report. (b) A review that attributes behaviour to "the orchestrator's
  decision" is reporting your own split instruction back at you: re-read
  what you actually told the coder for the sibling items before treating
  the verdict as agreement.
