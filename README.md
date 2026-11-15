# orchestration_skill_opencode

Набор скиллов и шаблон оркестрации для кодинг-агентов **zcode** и **opencode** —
переработанная версия личного набора скиллов оркестрации под модель
**«ведущая сессия + субагенты»**.

Вместо профильных установок исходной версии: одна ведущая сессия (orchestrator,
solo-first) и три субагента — `architect`, `coder`, `reviewer` — с fresh
контекстом на каждый диспатч. Конвейер включается только через Routing Gate;
мелкие задачи ведущая сессия делает сама.

## Что внутри

```
skillset/
├── skills/       # 32 скилла, плоско: skills/<имя>/SKILL.md
│   └── project-init/template/   # шаблон проекта (.orchestration/, AGENTS.md, src/, tests/, docs/)
├── agents/       # персоны: session-lead + 3 субагента (+ examples/ вне конвейера)
└── install/      # установка под zcode / opencode + emit.sh
```

Каталог всех 32 скиллов и рабочий путь пользователя —
[`skillset/SKILLS.md`](skillset/SKILLS.md); архитектура, источники и решения
порта — [`skillset/README.md`](skillset/README.md).

## Быстрый старт

```bash
# скиллы — общий для обоих харнессов путь (.agents/skills читают и zcode, и opencode):
mkdir -p <repo>/.agents/skills && cp -a skillset/skills/* <repo>/.agents/skills/

# субагенты + доктрина ведущей сессии:
skillset/install/emit.sh zcode <repo>      # .zcode/agents/{architect,coder,reviewer}.md
skillset/install/emit.sh opencode <repo>   # .opencode/agent/build.md + 3 субагента

# новый проект (из сессии агента): «начинаем новый проект X» → скилл project-init
```

Подробно, с git-guardrails и Verify-шагами:
[`skillset/install/zcode.md`](skillset/install/zcode.md) ·
[`skillset/install/opencode.md`](skillset/install/opencode.md).

## Рабочий путь (кратко)

`project-init` → `brainstorming` (HARD-GATE) → `writing-plans` → `to-tickets` →
`subagent-driven-development` (Model Gate → диспатчи) → `code-review` →
`finishing-a-development-branch`. Баг — сразу `systematic-debugging` + TDD.
Мелкая задача — соло, без конвейера.

## Источники и лицензия

Набор собран из [mattpocock/skills](https://github.com/mattpocock/skills) и
[obra/superpowers](https://github.com/obra/superpowers) (оба MIT, базы
зафиксированы по коммитам; полная таблица — в
[`skillset/README.md`](skillset/README.md#источники)), hub-копий TDD/debugging
и собственных скиллов. Все адаптации под zcode/opencode — в этом репозитории.

Лицензия — [MIT](LICENSE).
