#!/bin/bash
# block-dangerous-git.sh — PreToolUse hook for zcode (and any harness using the
# Claude-Code hook JSON contract). Reads {"tool_input":{"command":...}} on
# stdin, exits 2 to BLOCK a dangerous git command, 0 to allow.
#
# Dependency-free on purpose: a hook that dies with a missing `jq` would
# fail OPEN (exit 0 = allow) on machines without it. JSON is parsed with
# bash regex over the raw payload instead — the hook contract only needs
# the value of "command".
set -u

INPUT=$(cat)
COMMAND=""

# Extract "command" value from the payload without jq. Tolerates escaped
# quotes/backslashes inside the value well enough for git one-liners; a
# malformed payload yields an empty COMMAND, and an EMPTY COMMAND IS A BLOCK
# (fail-closed): the hook's job is to be safe, not permissive.
if [[ "$INPUT" =~ \"command\"[[:space:]]*:[[:space:]]*\"(.*)\" ]]; then
  COMMAND=${BASH_REMATCH[1]}
  # Un-escape the common JSON escapes the hook contract produces.
  COMMAND=${COMMAND//\\n/ }
  COMMAND=${COMMAND//\\\"/\"}
  COMMAND=${COMMAND//\\\\/\\}
fi

if [[ -z "$COMMAND" ]]; then
  echo "BLOCKED: hook could not read the command from the tool payload (fail-closed). If this is a legitimate command, the user can run it directly or adjust the guardrails script." >&2
  exit 2
fi

DANGEROUS_PATTERNS=(
  "git push"
  "git reset --hard"
  "git clean -fd"
  "git clean -f"
  "git branch -D"
  "git checkout \."
  "git restore \."
  "push --force"
  "reset --hard"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "BLOCKED: '$COMMAND' matches dangerous pattern '$pattern'. The user has prevented you from doing this." >&2
    exit 2
  fi
done

exit 0
