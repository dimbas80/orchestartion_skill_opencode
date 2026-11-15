# Skillset — набор скиллов и шаблон оркестрации для zcode и opencode

Эта папка — **канонический источник** набора для установки в zcode и opencode.
Здесь живут связанные версии скиллов (из mattpocock/skills, obra/superpowers и
собственные), персоны ролей и шаблон проекта оркестрации.

Не устанавливать напрямую из апстрим-клонов — только отсюда.

**Репозиторий набора:** https://github.com/dimbas80/orchestartion_skill (private) —
отсюда `git clone` для установки на другой машине.

**Происхождение:** набор перенесён с Hermes (профили + Kanban) на модель
«ведущая сессия + субагенты» (ноябрь 2026). Baseline Hermes-версии — в
`../source/skillset/` (не правится); история порта — в git-логах.

## Источники

Набор собран из двух апстримов и собственных скиллов. Базы зафиксированы по
коммитам (локальные клоны — в `../sources/`, в репозиторий набора не входят):

| Источник | Ссылка | База | Что взято |
|---|---|---|---|
| **mattpocock/skills** | https://github.com/mattpocock/skills | `5beb35b` | grilling, domain-modeling, to-spec, to-tickets, wayfinder, code-review, pr, retro, wizard, triage, codebase-design, improve-codebase-architecture, teach, to-questionnaire, writing-for-agents, wait-what, summary (основа handoff), git-guardrails |
| **obra/superpowers** | https://github.com/obra/superpowers | `2ce8aa1` | brainstorming, writing-plans, executing-plans, subagent-driven-development, dispatching-parallel-agents, using-git-worktrees, verification-before-completion, receiving-code-review, finishing-a-development-branch |
| **Hermes Agent hub** | каталог скиллов Hermes (`hermes skills`) | — | test-driven-development, systematic-debugging — канонические hub-копии (богаче апстримов); spike — прототип-выброс (нужен wayfinder) |
| **Собственные** | — | — | project-init (bootstrap проекта + единый шаблон в `template/`), git-guardrails (скрипт + zcode-hook/opencode-permissions), summary (переименование из opencode-команды `handoff`) |

Обе апстрим-коллекции распространяются по лицензии **MIT**; атрибуция сохранена
в файлах скиллов.

Каталог скиллов (что делает каждый) и рабочий путь пользователя —
в [SKILLS.md](SKILLS.md).

## Архитектура (вместо профилей Hermes)

**Ведущая сессия + субагенты.** Пользователь говорит с одной сессией (zcode —
сессия по умолчанию + `AGENTS.md`; opencode — режим `build` + оверрайд
`.opencode/agent/build.md`). По умолчанию она работает **соло** — универсальный
инженер. Конвейер (architect → coder → reviewer) — opt-in: Routing Gate
предлагает путь, пользователь подтверждает; роли диспатчатся как **субагенты**
(fresh контекст на каждую задачу):

| Роль | Носитель (zcode) | Носитель (opencode) | Тело |
|---|---|---|---|
| orchestrator (ведущая сессия) | workspace `AGENTS.md` | `.opencode/agent/build.md` | [`agents/session-lead.md`](agents/session-lead.md) |
| architect | `.zcode/agents/architect.md` | `.opencode/agent/architect.md` | [`agents/architect.md`](agents/architect.md) |
| coder | `.zcode/agents/coder.md` | `.opencode/agent/coder.md` | [`agents/coder.md`](agents/coder.md) |
| reviewer | `.zcode/agents/reviewer.md` | `.opencode/agent/reviewer.md` | [`agents/reviewer.md`](agents/reviewer.md) |

Персоны вне конвейера (бывшие профили `default`, `enginer`, `3dprint`) —
паттерн «workspace-персона» в [`agents/examples/`](agents/examples/).

## Структура

```
skillset/
├── README.md                  # этот файл: состав, источники, архитектура
├── SKILLS.md                  # каталог 32 скиллов + рабочий путь пользователя
├── agents/                    # персоны: session-lead + 3 субагента (+ examples/)
├── install/                   # установка: zcode.md, opencode.md, emit.sh
└── skills/                    # 32 скилла, ПЛОСКАЯ структура (<имя>/SKILL.md)
    ├── project-init/          # bootstrap проекта; template/ внутри скилла
    │   └── template/          # шаблон оркестрации: .orchestration/, AGENTS.md, src/, tests/, docs/
    ├── brainstorming/         # интервью + design doc + HARD-GATE; домен-хук GLOSSARY/ADR
    ├── grilling/              # стресс-тест готового плана (только по явной просьбе)
    ├── summary/               # summary.md в корне проекта, режимы read/create/update
    ├── verification-before-completion/ # Iron Law: никакого «готово» без доказательства
    ├── to-questionnaire/      # нерешаемый вопрос → анкета для того, кто знает
    ├── teach/ · wait-what/ · writing-for-agents/ · git-guardrails/
    ├── domain-modeling/ · to-spec/ · to-tickets/ · wayfinder/ · spike/
    ├── writing-plans/ · subagent-driven-development/ · dispatching-parallel-agents/
    ├── finishing-a-development-branch/ · research/ · triage/
    ├── codebase-design/ · improve-codebase-architecture/
    ├── executing-plans/ · using-git-worktrees/ · test-driven-development/
    ├── systematic-debugging/ · receiving-code-review/ · pr/ · retro/ · wizard/
    └── code-review/           # ревью двумя осями (Standards + Spec)
```

## Внешние зависимости

Набор самодостаточен по скиллам, персонам и шаблону. Сети/поиск — встроенные
инструменты харнесса (web search/fetch); опционально пользователь может
подключить свои MCP-серверы (context7, tavily и т.п.) — скиллы используют их,
если они есть, и не требуют.

## Установка

Подробно с Verify-шагами — [`install/zcode.md`](install/zcode.md) и
[`install/opencode.md`](install/opencode.md); кратко:

```bash
# скиллы — общий для обоих харнессов путь:
mkdir -p <repo>/.agents/skills && cp -a skills/* <repo>/.agents/skills/
# субагенты + доктрина ведущей сессии:
install/emit.sh zcode <repo>      # .zcode/agents/*  (+ AGENTS.md из template при project-init)
install/emit.sh opencode <repo>   # .opencode/agent/build.md + 3 субагента
# git-guardrails: zcode — PreToolUse hook; opencode — permission.deny (см. install/*.md)
```

## Рабочий путь: от `project-init` до merge

Роли: **ведущая сессия** (orchestrator) ведёт и диспетчит, **architect**
проектирует, **coder** пишет, **reviewer** проверяет — всё субагентами с
fresh контекстом. Задачи ходят через файлы: тикеты `.scratch/issues/`,
brief/ledger `.superpowers/sdd/`, отчёты `workflows/<task_id>/`. Модели
исполнителей согласуются до первого диспатча (Model Gate).

| № | Шаг | Скилл | Кто | Результат |
|---|---|---|---|---|
| 0 | «Начинаем новый проект X» | `project-init` | ведущая сессия | шаблон из каталога скилла, `git init`, субагенты, `.gitignore`, `codegraph init` |
| 1 | Интервью «что делаем» | `brainstorming` | ведущая сессия | design doc в `docs/product/`; `GLOSSARY.md` + `docs/adr/` по ходу; **HARD-GATE** |
| 2 | «Проверь план» (по желанию) | `grilling` | ведущая сессия | пакетные раунды вопросов, рекомендации, правки плана |
| 3 | План внедрения | `writing-plans` | architect (диспатч) или соло | `docs/architecture/implementation-plan.md` (фикс. имя = контракт handoff) |
| 3a | Если работа «туманная» | `wayfinder` | ведущая сессия | карта решений вместо преждевременных тикетов |
| 4 | «Нарежь тикеты» | `to-tickets` | ведущая сессия | `.scratch/issues/NN-slug.md` |
| 5 | «Диспетчируй» | `subagent-driven-development` | ведущая сессия | **Model Gate** (таблица «роль → модель», твоё утверждение) → диспатчи кодера/ревьюера |
| 6 | Исполнение | `executing-plans` (+ `using-git-worktrees`, `test-driven-development`, `systematic-debugging`) | coder (диспатч) или соло | код в `src/`, коммиты, `workflows/<task_id>/implementation-report.md` |
| 7 | Ревью | `code-review` | reviewer (диспатч) | `workflows/<task_id>/review.md`; замечания → `receiving-code-review`, ≤3 раунда |
| 8 | Завершение | `finishing-a-development-branch` (+ `pr`) | ведущая сессия | решение merge / PR / keep, тело PR, уборка worktree |

**Ветвления**

- **Hardware-проект** — тот же путь: architect дополнительно проектирует
  электронику (компоненты, расчёты, power budget, pinout, BOM).
- **Фича в существующем проекте** — без шага 0: `brainstorming` → `to-spec` →
  `to-tickets` → шаги 5–8.
- **Баг** — `systematic-debugging` (tight repro) → фикс под `test-driven-development` →
  `code-review` → `verification-before-completion` перед словом «готово».
- **Архитектурный рефакторинг** — `improve-codebase-architecture` / `codebase-design` →
  `grilling` → `writing-plans` → шаги 5–8.
- **Передача работы** — `summary` (create/update) перед сменой сессии.

**Routing Gate — выбор пути (обязателен один раз на фичу/проект)**

Прежде чем диспетчить работу, ведущая сессия оценивает масштаб и ПРЕДЛАГАЕТ
путь; пользователь подтверждает — без «ок» не диспетчировать. **Дефолт —
соло:** конвейер не запускается сам, скиллы срабатывают только по триггерам.

1. **Без маршрута:** мелкая задача — однострочная правка или баг с ясным repro →
   `systematic-debugging` или сразу код + `verification-before-completion`,
   без brainstorming/writing-plans/to-tickets/SDD.
2. **Короткий путь** — один диспатч coder + один reviewer, без архитектурного
   диспатча; design doc ведущая сессия пишет сама. Критерии: план ≤ 5 задач,
   знакомая область, нет новых интеграций, нет решений по схеме данных.
3. **Длинный путь** — таблица выше, с architect. Критерии: новая
   область/интеграции, схема данных, > 5 задач, взаимозависимые модули.
4. **Батчинг малых задач:** 2–4 мелких независимых задачи — один диспатч
   кодера, одно ревью на батч (`subagent-driven-development/references/batching.md`).
   Никогда не батчить: побочные эффекты вне worktree (миграции, деплой,
   live-конфиг), правки ядра/общего интерфейса, задачи с собственным решением
   или отладкой, security-чувствительные. Сомневаешься — не батчи.

**Примеры промптов:** «начинаем новый проект X» · «проверь план» · «оформи в спеку» ·
«нарежь тикеты» · «диспетчируй задачи» · «выполни план» · «почему падает тест» ·
«сделай ревью» · «заверши ветку / сделай PR» · «сохрани состояние».

**Действует всегда:** модель меняется только с согласования пользователя
(эскалация = правка agent-файла с объявлением, не тихая смена); делегация —
диспатчами субагентов; служебное (`.orchestration/`, `docs/`, `workflows/`,
`.scratch/`, `.codegraph/`, `summary.md`) в git проекта не попадает;
`git-guardrails` блокирует опасные git-команды (hook/permissions).

## Как обновлять

1. Апстрим-клоны: `sources/mattpocock-skills/`, `sources/superpowers/` — `git pull` там.
2. Изменения переносить сюда ВРУЧНУЮ с нашими адаптациями (не копировать поверх!).
3. Доктрина ведущей сессии: канон — `agents/session-lead.md`; та же доктрина
   лежит в `skills/project-init/template/AGENTS.md` — правь оба места.
