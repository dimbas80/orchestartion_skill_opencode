# Установка набора в zcode

## Откуда что берётся

| Компонент | Куда в zcode | Откуда в наборе |
|---|---|---|
| Скиллы (32) | `<репо>/.agents/skills/<имя>/` — workspace scope, общий с opencode; или `~/.agents/skills/` — user scope для всех проектов | `skillset/skills/` |
| Субагенты architect/coder/reviewer | `<репо>/.zcode/agents/<имя>.md` (проектные) или `~/.zcode/agents/<имя>.md` (глобальные) | `skillset/agents/*.md` |
| Доктрина ведущей сессии | `<репо>/AGENTS.md` — секция оркестратора (уже в шаблоне `project-init/template/AGENTS.md`) | `skillset/agents/session-lead.md` |
| git-guardrails | `<репо>/.zcode/config.json` → `hooks` (PreToolUse) + скрипт | `skillset/skills/core/git-guardrails/scripts/` |

Скиллы кладутся именно в `.agents/skills/`: этот compat-путь читают и zcode, и
opencode — одна копия обслуживает оба харнесса. Прецеденты разрешения: первый
одноимённый скилл в порядке сканирования (user раньше workspace, `.zcode`
раньше `.agents`).

## Скиллы

```bash
# в корень проекта (версионируется с репо):
mkdir -p .agents/skills
cp -a <набор>/skills/* .agents/skills/

# или глобально (все проекты):
mkdir -p ~/.agents/skills
cp -a <набор>/skills/* ~/.agents/skills/
```

Дискреция по модулям, как раньше по профилям, теперь по ролям: `core/` — всегда;
`coding/` + `planning/` + `review/` — в проекты, где ведётся конвейерная работа
(скиллы по триггерам безвредны в универсальной сессии — не сработают без
своих триггеров).

## Субагенты

Файлы субагентов в zcode — markdown с frontmatter. Минимум:

```markdown
---
description: <одна строка — когда диспатчить эту роль; всегда в контексте, это триггер>
---
<тело из skillset/agents/<роль>.md>
```

Опционально можно закрепить модель (`model: <id>` из ListModels) — тогда
Model Gate ведущей сессии читает её прямо из файла. Без поля — модель
по умолчанию харнесса, и карта моделей для Model Gate берётся из ListModels.

```bash
mkdir -p .zcode/agents          # или ~/.zcode/agents
cp <набор>/agents/architect.md  .zcode/agents/architect.md
cp <набор>/agents/coder.md      .zcode/agents/coder.md
cp <набор>/agents/reviewer.md   .zcode/agents/reviewer.md
```

## git-guardrails (хук PreToolUse)

Скрипт `block-dangerous-git.sh` совместим 1-в-1: zcode PreToolUse-хуки
используют тот же stdin-JSON (`tool_input.command`), `exit 2` = блок.

1. Скопировать скрипт (конвенция — один скрипт на машину):

```bash
mkdir -p ~/.agents/hooks
cp <набор>/skills/core/git-guardrails/scripts/block-dangerous-git.sh \
   ~/.agents/hooks/block-dangerous-git.sh
chmod +x ~/.agents/hooks/block-dangerous-git.sh
```

2. Зарегистрировать в конфиге (workspace: `<репо>/.zcode/config.json`;
   user: `~/.zcode/cli/config.json`) и включить хук-раннер:

```json
{
  "hooks": {
    "enabled": true,
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "command": "~/.agents/hooks/block-dangerous-git.sh", "timeout": 10 }
        ]
      }
    ]
  }
}
```

- Матчер — имя shell-инструмента zcode (`Bash`). Хуки из конфиг-файла должны
  нести `hooks.enabled: true`, иначе не запускаются.
- fail-closed поведение: скрипт сам блокирует при неопределённом входе;
  неопределённость ошибок рантайма проверь на своём zcode (`diagnosing-hooks`).

## Verify

- Скиллы: открыть сессию в проекте — скиллы видны в списке; вызвать
  «используй skill verification-before-completion».
- Субагенты: Settings → Subagents / список агентов сессии; диспатч
  «спроектируй архитектуру через субагента architect».
- Хук: `echo '{"tool_input":{"command":"git push origin main"}}' |
  ~/.agents/hooks/block-dangerous-git.sh; echo $?` → `BLOCKED…`, exit=2.
