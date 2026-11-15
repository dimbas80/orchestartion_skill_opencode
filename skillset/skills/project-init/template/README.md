# Engineering Project

This project is run by the leading agent session (orchestrator); implementation,
architecture and review roles are harness subagents (see
`.orchestration/orchestration.yml`).

## Workflow

Discovery
→ Architecture (hardware and software)
→ Implementation
→ Review
→ Integration

## Source of Truth

- Requirements: `docs/product/`
- Architecture (hardware + software): `docs/architecture/`
- ADR: `docs/adr/`
- Production files: `src/`
- Tests: `tests/`
- Review: `docs/review/`
- Hardware (when the project has hardware scope): `docs/hardware/`, `hardware/`
- Orchestration policy: `.orchestration/orchestration.yml`, state snapshot: `.orchestration/STATE.md`

`lib/`, `include/`, `hardware/` and similar directories are created by the
agent only when the project actually needs them. Do not implement anything
before the architecture is approved.
