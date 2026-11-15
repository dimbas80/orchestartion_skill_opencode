# Verifying detectors, criteria and coverage checks

Полная доктрина verbatim; ядро — в SKILL.md.

### Verifying detectors, criteria and coverage checks

When the deliverable is itself a check — a map/report generator criterion, a
linter rule, a coverage predicate, a "gap detector" — reading its code is not a
review. Verify it by **mutation on real inputs**: take the passing artifact,
remove or comment out the very line the criterion is supposed to see, and
require the criterion to flip to failing. Then re-add the trace in the two
places that must *not* count (a comment, a quoted/reference block) and require
it to stay failing. A criterion that only ever returns ✓ is indistinguishable
from one that always returns ✓; the ✗ case must be demonstrated, not assumed.

Two classes of defect this catches that reading never does:

- **the trace and the claim live at different granularity** — the predicate
  matches a value anywhere in the file, so a delta declared in one branch is
  "satisfied" by a delta in another branch;
- **the source of truth is narrower than the prose around it** — prose can
  promise an effect the underlying data/code never applies; a criterion built
  on the data will be truthfully silent about it, and that is a documentation
  finding, not an implementation bug.

### Verify artifact and visual invariants mechanically

- **Patch artifacts can be EOL-normalized.** When a per-batch diff will not apply against the working tree, do not fail the review on that alone: check whether it was produced in text mode (no `\r` in the patch while the target files are CRLF). Reconstruct the pre-change tree independently, take your own binary-safe diff, and compare content after EOL normalization. If the content matches, the code is verified and the artifact generation is a separate (usually LOW) finding.
- **"Layout / format unchanged" is a multiset assertion, not a code read.** Extract (anchor or column expression, string literal) pairs from the drawing/printing calls of the pre- and post-change versions, strip comments and trailing whitespace, and diff the multisets. Remaining differences are the real layout changes; strings that only padded a field before a new clear-and-redraw mechanism appeared will show up and are expected.
- **"No new warnings" is a subset test.** Compare warning identities (source file + message, with line:col stripped) of before and after; counts alone hide both fixed and newly introduced warnings. The same shape proves that unit/label literals survived a display refactor.

### Red-probe a new regression against the pre-fix baseline

A regression test that ships with the fix was written against the fixed tree; it
proves nothing until it has been shown to fail on the broken baseline. Run the
new/updated test file against a pristine copy of the pre-change files (export
the commit's versions of just the touched files into a scratch copy of the
tree — never mutate the repo) and require the failure set to be non-empty and
semantically on point. Record which tests stay green there: those are toothless
and need a sharper assertion. Two recurring shapes:

- the test asserts the *shape* the old code already had (a container is
  centred while its lines are not) and so passes on the bug it claims to guard;
- the test compares against a hard-coded constant taken from the fixed render
  instead of the measured geometry it should defend.

### Guards that scan text can be broken by prose

When a project guard greps/lints a *region* of source (a config block, a
section, a whole file) for forbidden literals, new explanatory comments inside
that region can trip it — the guard sees digits in prose as numbers. A full
suite that was green before the change and is red after is a blocking finding
even when the cause is only a comment: verify the causality (baseline green,
reworded prose green, as-is red) by mutation in a scratch copy, then require the
comment to be reworded or moved outside the scanned region.

Also sweep every row the criterion covers, not just the sample: recompute the
verdict independently and diff it against the published artifact, so the count
of ✓ and the count of "✓ with a missing component" are both known numbers.
When recomputing, mirror the artifact's *display rule* — which rows get a
verdict at all, and which side of a multi-verdict tuple (e.g. grant vs spend
per row) the published column shows. A harness that compares the wrong tuple
side, or expects verdicts where the criterion deliberately shows none, floods
the sweep with false mismatches and buries the one real finding: debug the
harness's own unpacking/display bugs before blaming the criterion.

