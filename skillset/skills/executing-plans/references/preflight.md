# Pre-flight Scan (executing-plans)

Run before Task 1, record results in the ledger.

Scan the plan for conflicts between tasks. The plan's Interfaces blocks tell you where to look: for every task that consumes what an earlier task produces, one ledger row — the two tasks, what one produces against what the other consumes, and what you found. Tasks that share nothing get no row; a plan whose tasks share nothing gets the single line `Pre-flight: no shared interfaces`. Rule on each conflict a row surfaces with the spec as the binding authority, record the ruling beside its row, and start Task 1. Each task's own text is checked when you read its brief, not here.
