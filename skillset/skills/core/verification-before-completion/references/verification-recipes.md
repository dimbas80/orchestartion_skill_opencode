# Verification recipes — смежные классы проверок

Развёрнутые правила для трёх классов «проверка как доказательство»; ядро — в SKILL.md.

## Static checkers (grep-based criteria)

A checker that "finds a trace of X in the code" can certify itself. Two rules:

1. **Search live code only.** Strip comments and any embedded snapshot/doc blocks
   (quoted requirements, generated examples, `original` sections) before matching.
   A mention inside an explanatory comment is not an implementation — and such a
   comment is exactly what a developer writes when the code is NOT there.
2. **One component, one check.** When a requirement has several parts
   (several values, files, branches), verify each part separately and name the
   missing ones in the output. A single match must not mark the whole row done.
   Dedupe first when the source format lists the same part twice (mirrored
   blocks), otherwise a correct implementation looks incomplete.

Prove the checker itself: a case that must be flagged (partial input → ✗) and a
case where the only trace sits in a comment or snapshot block (→ ✗). A checker
never shown to fail is not evidence that the work passes.

**Check what the checker measures, not what it is named.** A checker proves only
its own predicate: a bounds/lint/schema check that returns OK says nothing about
the property the requirement is written in ("values fit the screen" ≠ "values do
not overlap", "line exists" ≠ "line is correct"). Before trusting a green
result, state the predicate in one sentence and compare it with the requirement;
if they differ, the green run is not evidence — build the metric the requirement
actually names (parse the real units from the source of truth, not an estimate
quoted in the task) and report both numbers.

## Generated artifacts and filesystem-reading criteria

A generated artifact (map, index, inventory, report table) is only evidence if
it is stable. Before claiming a regenerated artifact was "reproduced":

1. **Run the generator twice and compare hashes of every produced file.** The
   second run must change nothing. A byte-identical second run proves your
   change, not the tree's churn.
2. **Split the diff into "rows I changed" and "rows that changed by".** Rows
   nobody touched in your work are external drift: the criterion read the
   filesystem (file presence, directory contents, timestamps) and some other
   process wrote into it. Label them with the input that caused them, in the
   report and on the shared board — do not claim them as your work and do not
   silently revert them.
3. **Never leave drift unexplained.** "Other sections unchanged" is a claim that
   needs a check, not an assumption: name every file whose diff is not yours and
   why.

## Same rule, other entry points

A limit/validation/formatting rule usually has more than one place that enforces
it: the on-device editor, the web/config form, the API import, the second
screen. Fixing one of them is not "the rule changed" — it is "one path changed".

1. After changing a rule, grep the whole tree for the field/constant it guards
   and list every place that clamps it.
2. Turn the list into a per-path check: each path fixed / each path still old.
3. A path you are not allowed to touch is a **finding with a file and line**, not
   the silence of a scoped acceptance criterion. Say plainly: the decision is
   implemented on path A and still contradicted on path B by `<file:line>`, so
   the owner or orchestrator must schedule it. Never report the change as
   complete for the device while another live path keeps the old cap.

