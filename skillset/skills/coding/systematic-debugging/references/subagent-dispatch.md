# Investigation delegation

Moved from SKILL.md. For in-session complex multi-component debugging, dispatch investigation subagents (report-only; the fix stays with you):

```
Dispatch (investigate, do NOT fix):
  Follow systematic-debugging skill:
  1. Read the error message carefully
  2. Reproduce the issue
  3. Trace the data flow to find root cause
  4. Report findings — do NOT fix yet

  Error: [paste full error]
  File: [path to failing code]
  Test command: [exact command]
```

Real-world impact (from debugging sessions): systematic 15–30 min to fix vs 2–3 h of random-fix thrashing; first-time fix rate 95% vs 40%; new bugs introduced near zero vs common. No shortcuts. No guessing.
