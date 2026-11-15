# Установка набора в opencode

## Откуда что берётся

| Компонент | Куда в opencode | Откуда в наборе |
|---|---|---|
| Скиллы (32) | `<репо>/.agents/skills/<имя>/` — workspace scope, общий с zcode; или `~/.config/opencode/skills/` (compat: `~/.agents/skills/`) | `skillset/skills/` |
| Субагенты architect/coder/reviewer | `<репо>/.opencode/agent/<имя>.md` с `mode: subagent` (проектные) или `~/.config/opencode/agent/<имя>.md` (глобальные) | `skillset/agents/*.md` |
| Доктрина ведущей сессии | `.opencode/agent/build.md` — **оверрайд встроенного build** (тот же ID мержится поверх); `plan` остаётся чистым read-only режимом | `skillset/agents/session-lead.md` |
| git-guardrails | `opencode.json` → `permission.deny` по shell-паттернам | `skillset/skills/git-guardrails/` |

## Скиллы

```bash
mkdir -p .agents/skills
cp -a <набор>/skills/* .agents/skills/
```

Формат совместим: opencode читает `SKILL.md` (name — только display label, ID
из пути; description — триггер). «Только по явной просьбе» (grilling, summary)
можно пометить:

```yaml
metadata:
  opencode/autoinvoke: false
```

— скилл скрывается из списка модели, но остаётся доступным по явному вызову
(`@skill-id`).

## Ведущая сессия: оверрайд build

```bash
mkdir -p .opencode/agent
# собрать из session-lead.md файл с frontmatter (см. install/emit.sh):
emit.sh opencode   # → .emit/opencode/agent/build.md и субагенты
```

Файл `.opencode/agent/build.md`:

```markdown
---
description: Universal engineer; orchestrates the architect/coder/reviewer pipeline when a route requires it
---
<тело session-lead.md>
```

Переключение Tab'ом (`build` ↔ `plan`) работает как обычно: `plan` —
исследования без правок, `build` — работа и оркестрация конвейера.

## Субагенты

```bash
# emit.sh делает это за один проход; вручную:
mkdir -p .opencode/agent
for role in architect coder reviewer; do
  {
    printf -- '---\ndescription: %s\nmode: subagent\n---\n\n' "$(grep -m1 '^> ' <набор>/agents/$role.md | sed 's/^> //')"
    cat <набор>/agents/$role.md
  } > .opencode/agent/$role.md
done
```

`mode: subagent` — роль запускается только в дочерней сессии по диспатчу
ведущей; `description` — то, по чему ведущая сессия решает, кого звать
(в каждом файле набора строка `> …` под заголовком несёт именно это).

Опционально в frontmatter: `model: <provider/model>` — тогда Model Gate
читает карту прямо из agent-файлов.

## git-guardrails (permissions)

В opencode хуков pre-tool нет — эквивалент достигается deny-правилами в
`opencode.json` (workspace) или `~/.config/opencode/opencode.json` (глобально):

```json
{
  "permission": {
    "deny": [
      "bash(git push*)",
      "bash(git reset --hard*)",
      "bash(git clean -f*)",
      "bash(git branch -D*)",
      "bash(git checkout .*)",
      "bash(git restore .*)"
    ]
  }
}
```

Паттерны — точный список из `block-dangerous-git.sh`; расширение списка —
правка deny-массива (в исходной версии это была правка скрипта).

## Verify

- Скиллы: сессия в проекте, `@verification-before-completion` — загрузился.
- Build-оверрайд: Tab переключает build/plan; системный промпт build несёт
  доктрину (проверь: «какой у тебя Routing Gate?»).
- Субагенты: в сессии build попроси «диспатчни reviewer на проверку HEAD» —
  запускается дочерняя сессия reviewer.
- Permissions: попроси «git push origin main» — отказ по deny-правилу.
