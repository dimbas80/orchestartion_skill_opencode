#!/usr/bin/env bash
# emit.sh — развернуть персоны набора в файлы харнессов.
#
#   ./emit.sh zcode <целевой-репо>      → .zcode/agents/{architect,coder,reviewer}.md
#   ./emit.sh opencode <целевой-репо>   → .opencode/agents/build.md + субагенты
#
# Скиллы copy-командой (см. install/zcode.md / install/opencode.md); этот скрипт
# только собирает agent-файлы: тело персоны + frontmatter с description
# (строка "> …" под заголовком файла персоны).
set -euo pipefail

usage() { echo "usage: emit.sh zcode|opencode <target-repo-dir>" >&2; exit 2; }
[ $# -eq 2 ] || usage
target=$1; repo=$2
here=$(cd -- "$(dirname -- "$0")" && pwd)
agents_dir="$here/../agents"
[ -d "$agents_dir" ] || { echo "agents/ not found next to install/" >&2; exit 2; }

# description персоны = первая строка "> …" в её файле
desc_of() {
  grep -m1 '^> ' "$1" | sed 's/^> //'
}

emit_opencode_agent() { # file role mode
  local src=$1 role=$2 mode=$3
  local out="$repo/.opencode/agents/$role.md"
  mkdir -p "$(dirname "$out")"
  {
    printf -- '---\ndescription: "%s"\nmode: %s\n---\n\n' "$(desc_of "$src")" "$mode"
    cat "$src"
  } > "$out"
  echo "  $out"
}

emit_zcode_agent() { # file role
  local src=$1 role=$2
  local out="$repo/.zcode/agents/$role.md"
  mkdir -p "$(dirname "$out")"
  {
    printf -- '---\ndescription: "%s"\n---\n\n' "$(desc_of "$src")"
    cat "$src"
  } > "$out"
  echo "  $out"
}

case "$target" in
  zcode)
    for role in architect coder reviewer; do
      emit_zcode_agent "$agents_dir/$role.md" "$role"
    done
    echo "zcode: субагенты готовы. Доктрину ведущей сессии несёт AGENTS.md проекта"
    echo "       (шаблон project-init), скиллы — cp -a skills/* .agents/skills/."
    ;;
  opencode)
    emit_opencode_agent "$agents_dir/session-lead.md" build primary
    for role in architect coder reviewer; do
      emit_opencode_agent "$agents_dir/$role.md" "$role" subagent
    done
    echo "opencode: build-оверрайд + 3 субагента готовы."
    echo "          Скиллы — cp -a skills/* .agents/skills/, git-guardrails — permission.deny (install/opencode.md)."
    ;;
  *) usage ;;
esac
