# Hermes integration — investigation delegation (solo-session fallback)

Moved from SKILL.md. Multi-profile setup: a kanban task for the profile that owns the subsystem. For in-session complex multi-component debugging, dispatch investigation subagents:

```python
delegate_task(
    goal="Investigate why [specific test/behavior] fails",
    context="""
    Follow systematic-debugging skill:
    1. Read the error message carefully
    2. Reproduce the issue
    3. Trace the data flow to find root cause
    4. Report findings — do NOT fix yet

    Error: [paste full error]
    File: [path to failing code]
    Test command: [exact command]
    """,
    toolsets=['terminal', 'file']
)
```

Real-world impact (from debugging sessions): systematic 15–30 min to fix vs 2–3 h of random-fix thrashing; first-time fix rate 95% vs 40%; new bugs introduced near zero vs common. No shortcuts. No guessing.
