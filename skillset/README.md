# Skillset — исходник собственного набора скиллов и шаблона оркестрации

Эта папка — **канонический источник** для установки в профили Hermes. Здесь живут
исправленные/связанные версии скиллов (из mattpocock/skills, obra/superpowers и
собственные) и исправленный шаблон проекта оркестрации.

Не устанавливать напрямую из `sources/` (upstream-клоны) — только отсюда.

**Репозиторий набора:** https://github.com/dimbas80/orchestartion_skill (private) —
отсюда `git clone` для установки на другой машине. Git-репозиторий заведён только
на эту папку (`skillset/`), апстрим-клоны в `../sources/` живут отдельно.

## Источники

Набор собран из двух апстримов, каталога Hermes и собственных скиллов. Базы
зафиксированы по коммитам (локальные клоны — в `../sources/`, в репозиторий
набора не входят):

| Источник | Ссылка | База | Что взято |
|---|---|---|---|
| **mattpocock/skills** | https://github.com/mattpocock/skills | `5beb35b` | grilling, domain-modeling, to-spec, to-tickets, wayfinder, code-review, pr, retro, wizard, triage, codebase-design, improve-codebase-architecture, teach, to-questionnaire, writing-for-agents, wait-what, summary (основа handoff), git-guardrails (Claude-Code-версия) |
| **obra/superpowers** | https://github.com/obra/superpowers | `2ce8aa1` | brainstorming, writing-plans, executing-plans, subagent-driven-development, dispatching-parallel-agents, using-git-worktrees, verification-before-completion, receiving-code-review, finishing-a-development-branch |
| **Hermes Agent hub** | каталог скиллов Hermes (`hermes skills`) | — | test-driven-development, systematic-debugging — канонические hub-копии (богаче апстримов); spike — прототип-выброс (нужен wayfinder) |
| **Собственные** | — | — | project-init (bootstrap проекта + единый шаблон в `template/`), git-guardrails (адаптация формата Claude Code под Hermes shell hooks), summary (переименование из opencode-команды `handoff`) |

Обе апстрим-коллекции распространяются по лицензии **MIT**; атрибуция сохранена
в файлах скиллов. Все адаптации под Hermes и решения по слиянию —
в [skills-design.md](../skills-design.md) и [skills-pipeline.md](../skills-pipeline.md).

Каталог скиллов (что делает каждый) и пошаговый рабочий путь пользователя —
в [SKILLS.md](SKILLS.md).

## Внешние зависимости

Набор самодостаточен по рабочим скиллам (`skills/`) и персоне исполнителей (`soul/`),
но двум группам нужны внешние компоненты, которых в наборе нет **по решению**:

| Зависимость | Где нужна | Состояние |
|---|---|---|
| `tavily-*` (hub-скиллы: `tavily-search`, `tavily-extract`, `tavily-research`, …) + CLI `tvly` + `TAVILY_API_KEY` | `research` (веб-первоисточники), веб-скиллы | стоят в **default** и **orchestrator** (категория `web/`) как hub-скиллы. В остальных профилях `research` откатывается на встроенные `web_search` / `web_extract` и пишет в отчёте, какой канал использован |
| MCP-серверы профиля (`codegraph`, `context7`, `n8n`, `tavily`, context-mode) | `codegraph explore`, контекст репозитория | профильная настройка Hermes (`mcp_servers` в `config.yaml`), не часть набора |

Почему не включены: это интеграции с инструментами/сервисами (требуют ключей, CLI и
сетевого доступа), а не процедуры. Если нужна установка на «чистую» машину — поставить
их отдельно (`hermes skills install tavily-search` и т.п.) или положиться на встроенные
веб-инструменты Hermes.

## Структура

```
skillset/
├── README.md                  # этот файл: состав, источники, профили
├── SKILLS.md                  # каталог 32 скиллов + рабочий путь пользователя
└── skills/
    ├── core/                  # ядро — во ВСЕ профили
    │   ├── project-init/      # СВОЙ: bootstrap проекта (template/ внутри скилла)
    │   │   └── template/      # шаблон оркестрации: ЕДИНЫЙ (software+embedded), src/, tests/, docs/, .gitignore
    │   ├── brainstorming/     # [O v7] интервью + design doc + HARD-GATE; домен-хук GLOSSARY/ADR; предлагает grilling
    │   ├── grilling/          # [M] стресс-тест готового плана (только по явной просьбе)
    │   ├── summary/           # [M handoff → переименован] summary.md в корне проекта, режимы read/create/update
    │   ├── verification-before-completion/ # [O] Iron Law: никакого «готово» без свежего доказательства
    │   ├── to-questionnaire/  # [M] нерешаемый вопрос → анкета для того, кто знает
    │   ├── teach/             # [M] мульти-сессионное обучение (Teaching Workspace, ZPD)
    │   ├── wait-what/         # [M] «не долетело» — переупаковка сообщения (GLOSSARY)
    │   ├── writing-for-agents/ # [M] как писать доки для агентов (скиллы, AGENTS.md)
    │   └── git-guardrails/    # [M→адаптирован] shell-hook pre_tool_call: блок опасных git-команд (scripts/)
    ├── planning/              # orchestrator, architect
    │   ├── domain-modeling/   # [M] GLOSSARY.md / ADR — полная дисциплина (в brainstorming встроен хук)
    │   ├── to-spec/           # [M] разговор → спека (.scratch/<feature>/spec.md), без интервью
    │   ├── to-tickets/        # [M] → tracer-bullet тикеты (.scratch/issues/) + зеркала Kanban
    │   ├── wayfinder/         # [M] большая работа-«туман»: карта решений (destination/тикеты/frontier)
    │   ├── spike/             # [H hub] прототип-выброс: проверить идею/подход до сборки (нужен wayfinder)
    │   ├── writing-plans/     # [O] спека → docs/architecture/implementation-plan.md (architect)
    │   ├── subagent-driven-development/ # [O] диспетчер через Kanban + Model Gate
    │   ├── dispatching-parallel-agents/ # [O] параллельные независимые домены
    │   ├── finishing-a-development-branch/ # [O] merge/PR/keep — решение Orchestrator'а с Дмитрием
    │   ├── research/          # [M] первоисточники → Markdown с цитатами (веб через tavily)
    │   ├── triage/            # [M] state machine триажа issues/PR (лейблы из шаблона)
    │   ├── codebase-design/   # [M] словарь глубоких модулей (architect)
    │   └── improve-codebase-architecture/ # [M] скан углублений → HTML-отчёт → grilling
    ├── coding/                # coder (+ default)
    │   ├── executing-plans/   # [O] инлайн-исполнение плана: ledger, TDD-шаги, completion contract, финальный ревью
    │   ├── using-git-worktrees/ # [O] изоляция workspace (.worktrees/, baseline-тесты)
    │   ├── test-driven-development/     # [H hub←obra v1.1.0] RED-GREEN-REFACTOR, каноническая копия
    │   ├── systematic-debugging/        # [H hub←obra v1.1.0] 4 фазы + Feedback Loop Rule, каноническая копия
    │   ├── receiving-code-review/       # [O] приём фидбека: verify before implement, без «You're absolutely right!»
    │   ├── pr/                # [M] тело PR: Summary / Evidence / Merge Danger (door + blast radius)
    │   ├── retro/             # [M] ретроспектива сессии: среда агента, guardrails
    │   └── wizard/            # [M] bash-визарды для человеко-шагов (template.sh)
    ├── review/                # reviewer
    │   └── code-review/       # [M] 2 оси: Standards (Фаулер-смеллы) + Spec; Kanban основной, delegate_task — solo-фолбэк
└── soul/                      # SOUL.md 7 рабочих профилей (переустановка/шаринг)
```

## Что исправлено относительно апстрима

| Файл | Изменение |
|---|---|
| `template/AGENTS.md` | Удалён дубль секции «Agent skills»; `.codegraph-$(hotname)` → `.codegraph/`; `CONTEXT.md` → `GLOSSARY.md` |
| `template/docs/agents/domain.md` | Конвенция приведена к актуальной у mattpocock/skills: `GLOSSARY.md` / `GLOSSARY-MAP.md` |
| `template/.gitignore` | Добавлен `.scratch/` (спеки и тикеты фич не должны попадать в git) |
| `skills/core/summary` | Переименован из `handoff` (привычное имя из opencode). Структура из кастомной команды summary.md: режимы read/create/update, 6 секций (блокер → следующий шаг → состояние → ошибки → suggested skills → артефакты), лимиты 4 000/6 000 символов. Файл — `summary.md` в корне проекта (в .gitignore). Не дублировать STATE.md |
| `skills/core/brainstorming` | [O v7] + 5 правок: description разграничивает с grilling (+ RU-триггеры); `superpowers:writing-plans` → `writing-plans` (2 места); design doc → `docs/product/` по artifact policy шаблона; **домен-хук** «Terms and Decisions Go Down as You Go» — термины в GLOSSARY.md, решения в docs/adr/ по ходу интервью (лениво); новая секция **After Approval** — предлагает стресс-тест grilling, потом writing-plans; **Size the Work** — передача в wayfinder, когда работа too big/foggy для design doc |
| `skills/core/grilling` | [M] as-is, только description сужен: СТРЕСС-ТЕСТ готового плана, только по явной просьбе (или из brainstorming после аппрува); не для старта новой работы |
| `skills/planning/domain-modeling` | [M] as-is, полная дисциплина GLOSSARY/ADR (в brainstorming встроен сокращённый хук) |
| `skills/planning/to-spec` | [M] description RU (без интервью, синтез разговорa); ссылка на setup-matt-pocock → адаптеры шаблона (issue-tracker.md / triage-labels.md); спека фичи → `.scratch/<feature>/spec.md`, продуктовые доки → `docs/product/` |
| `skills/planning/to-tickets` | [M] description RU (Kanban-зеркала); setup-matt-pocock → адаптеры; + примечание: orchestrator зеркалит тикеты в kanban-задачи (board=<slug>), файл в .scratch/ — источник истины. Local Files режим и шаблон тикета — as-is |
| `skills/planning/wayfinder` | [M] description RU («туман»); трекер → docs/agents/issue-tracker.md (Wayfinding operations); тикет-тип prototype → вызывает hub-скилл `spike`; research-ветки без remote — локально |
| `skills/planning/writing-plans` | [O] description RU (роль ARCHITECT); сохранение → `docs/architecture/implementation-plan.md` (контракт handoff, фикс. имя) — 3 места; `superpowers:`-префиксы сняты (3 места); Execution Handoff: native = coder-сессия, subagent-driven = диспатч orchestrator'а |
| `skills/coding/executing-plans` | [O] + правки: description RU (инлайн-режим coder'а); префиксы сняты (8); ссылки на using-superpowers убраны; общие скрипты sdd-workspace/review-package/task-brief скопированы локально (paths перепаяны в SKILL + task-start/task-done); `code-reviewer.md` локально; **Final Review — 2 режима**: Kanban (review-package → задача reviewer'у) или автономный диспатч; **финал = hand-off Orchestrator'у** (merge — не implementer'а); + Hermes-note |
| `skills/coding/using-git-worktrees` | [O] description RU; + Hermes-note (нет native worktree-инструмента → сразу git fallback 1b); + guard: не git-репо → стоп, нужен project-init. Step 0 детект/submodule-guard/baseline — as-is |
| `skills/core/verification-before-completion` | [O] as-is + RU-триггеры в description (Iron Law: никакого «готово» без свежего доказательства) |
| `skills/review/code-review` | [M] description RU (роль reviewer); setup-matt-pocock → адаптеры шаблона; **Kanban-режим основной**: ревью приходит задачей reviewer-профилю, две оси — два раздельных прохода (или две задачи для большого diff); delegate_task — solo-фолбэк. Оси/смеллы/агрегация — as-is |
| `skills/coding/receiving-code-review` | [O] description RU (роль coder); + примечание: `review.md` от reviewer-профиля = external review (проверки внешнего ревьюера применяются в полном объёме). Остальное as-is |
| `skills/coding/pr` | [M] description RU; GLOSSARY.md-связка совпадает с шаблоном; credits сохранены. As-is |
| `skills/planning/finishing-a-development-branch` | [O] description RU (роль ORCHESTRATOR + Дмитрий); Option 2 (push+PR) — тело PR: задача coder-профилю (модуль coding, скилл `pr`); в solo-сессии — загрузить `pr` здесь. Worktree cleanup (.worktrees/ ownership), discard-протокол — as-is |
| `skills/core/to-questionnaire` | [M] description RU; флаг снят. As-is |
| `skills/core/teach`, `skills/core/wait-what`, `skills/core/writing-for-agents` | [M] description RU (назначение: default, лежат в core — полезны любому профилю); флаги сняты. wait-what использует GLOSSARY.md шаблона; retro ссылается на writing-for-agents — связка на месте |
| `skills/planning/research` | [M] description RU; + строка: веб-источники через tavily-скиллы hub (research = дисциплина первоисточников, tavily = инструмент — не дубли) |
| `skills/planning/triage` | [M] description RU; setup-matt-pocock → `docs/agents/triage-labels.md` (таблица лейблов уже в шаблоне). AGENT-BRIEF.md / OUT-OF-SCOPE.md едут со скиллом |
| `skills/planning/codebase-design`, `skills/planning/improve-codebase-architecture` | [M] description RU (роль architect); DEEPENING/DESIGN-IT-TWICE/HTML-REPORT едут со скиллами; HTML-отчёт в Hermes — через ::preview |
| `skills/core/git-guardrails` | [M→адаптирован] Hermes shell hook `hooks.pre_tool_call` в config.yaml профиля (matcher `terminal`, `fail_closed`), скрипт в `~/.hermes/agent-hooks/`, exit 2 = блок. Формат stdin Claude Code совместим 1-в-1. v1 ловит только tool `terminal` (git из python-subprocess — вне охвата) |
| `skills/coding/test-driven-development` | [H hub←obra v1.1.0] Каноническая копия hub-версии (богаче obra: детальный RED-GREEN-REFACTOR, Anti-Patterns, Hermes Integration). Для reinstall/шаринга — полный набор самодостаточен |
| `skills/coding/systematic-debugging` | [H hub←obra v1.1.0] Каноническая копия hub-версии (4 фазы + Feedback Loop Rule + Rule of Three). Для reinstall/шаринга — полный набор самодостаточен |
| `skills/planning/spike` | [H hub] Добавлен для самодостаточности: на него ссылается wayfinder (prototype-тикеты). description RU с триггерами; ссылка `plan` → `writing-plans`; параллельные спайки — Kanban primary, delegate_task — solo-фолбэк |
| `skills/core/project-init` | НОВЫЙ скилл: при старте проекта — **копия шаблона из каталога самого скилла** (`project-init/template/`, не хардкод-путь — скилл самодостаточен для шаринга/других агентов), git init, `codegraph init`, и только потом интервью. Шаблон единый: **software + embedded** (firmware→`src/` без подпапок; lib/include/hardware агент создаёт при необходимости), architect — и софт-, и хард-архитектор |

## Профили (кто что получает)

| Профиль | Роль в конвейере | Модули |
|---|---|---|
| `default` | универсал (desktop/чат), оба модуля с ужесточёнными триггерами | core + coding + planning |
| `orchestrator` | system_engineer: discovery/specification, диспетчеризация через Kanban, Model Gate, merge-решение | core + planning |
| `architect` | system_architect: **софт, система и железо** (единственный архитектор — hardware-designer влит сюда): этап ARCHITECTURE | core + planning |
| `coder` | developer (**software + firmware**): этап IMPLEMENTATION | core + coding |
| `reviewer` | independent_reviewer: этап REVIEW | core + review |
| `enginer` | инженер-проектировщик, вне конвейера | core |
| `3dprint` | Telegram-бот по 3D-печати | core |

Полные `SOUL.md` рабочих профилей — в [`soul/`](soul/) (7 файлов; hardware-designer
удалён 24.10.2026 — его специфика влита в `soul/architect.md`). Для переустановки
сета на другой машине: `skills/` + `soul/` + `skills/core/project-init/template/`
образуют самодостаточный комплект.

## Установка в профили (выполнено 24.10.2026)

> **Статус: проверено на реальном проекте** (UPS_esp8266, 25.10.2026) — полный цикл
> project-init → Kanban → архитектура → имплементация; результат удовлетворительный.
> Живые уроки (Model Gate, fallback_providers, чек-листы противоречий, Skill library
> policy в SOUL) влиты в канон и в репозиторий.

- `core/` → все 7 профилей (по 10 скиллов) — hardware-designer слит в architect
- `coding/` → coder + default (8); `planning/` → orchestrator, architect + default (13);
  `review/` → reviewer (1)
- Итого по профилям: default 31 · orchestrator 23 · architect 23 · coder 18 ·
  reviewer 11 · enginer 10 · 3dprint 10 (= 126 инсталляций)
- `soul/`: architect и orchestrator установлены (обновлённые версии), остальные
  совпадали с живыми; профиль hardware-designer удалён
- `git-guardrails`: скрипт `~/.hermes/agent-hooks/block-dangerous-git.sh` +
  `hooks.pre_tool_call` (matcher `terminal`, `fail_closed`) во всех 7 профилях
- Пересечения убраны: superpowers-категория (9 скиллов × 3 профиля = 27),
  hub-копии `test-driven-development` / `systematic-debugging` / `plan`
  (3 × 8 корней = 24); в reviewer отключены `requesting-code-review`,
  `sdlc-review`, в coder — `requesting-code-review` (наши `code-review` /
  `executing-plans` их заменяют)
- Бэкап перед установкой: `~/.hermes/backups/stage7-preinstall-20261024-1828.tgz`
- Проверка: `hermes skills list -p <профиль> --enabled-only` — все наши скиллы
  видны как enabled; живой one-shot в reviewer вернул `code-review` в контексте
- Правки применяются только к НОВЫМ сессиям профилей

## Рабочий путь: от `project-init` до merge

Как пользователь работает с набором. Роли: **orchestrator** ведёт и диспетчит,
**architect** проектирует, **coder** пишет, **reviewer** проверяет. Задачи ходят
через Kanban-доску проекта; модели исполнителей согласуются до постановки задач.
Полный каталог «что делает каждый скилл» — в [SKILLS.md](SKILLS.md).

| № | Шаг | Скилл | Профиль | Результат |
|---|---|---|---|---|
| 0 | «Начинаем новый проект X» | `project-init` | любой (обычно orchestrator) | шаблон из каталога скилла, `git init`, `.gitignore`, `codegraph init` |
| 1 | Интервью «что делаем» | `brainstorming` | orchestrator | design doc в `docs/product/`; `GLOSSARY.md` + `docs/adr/` по ходу; **HARD-GATE** — без «ок» дальше нельзя |
| 2 | «Проверь план» (по желанию) | `grilling` | orchestrator | пакетные раунды вопросов, рекомендации, правки плана |
| 3 | План внедрения | `writing-plans` | architect | `docs/architecture/implementation-plan.md` (фикс. имя = контракт handoff) |
| 3a | Если работа «туманная» | `wayfinder` | orchestrator | карта решений вместо преждевременных тикетов |
| 4 | «Нарежь тикеты» | `to-tickets` | orchestrator | `.scratch/issues/NN-slug.md` + зеркала Kanban |
| 5 | «Диспетчируй» | `subagent-driven-development` | orchestrator | **Model Gate** (таблица «профиль → модель/провайдер», твоё утверждение) → задачи на доску `board=<slug>` |
| 6 | Исполнение | `executing-plans` (+ `using-git-worktrees`, `test-driven-development`, `systematic-debugging`) | coder | код в `src/`, коммиты, `workflows/<task_id>/implementation-report.md` |
| 7 | Ревью | `code-review` | reviewer | `workflows/<task_id>/review.md`; замечания → `receiving-code-review`, ≤3 раунда |
| 8 | Завершение | `finishing-a-development-branch` (+ `pr`) | orchestrator | решение merge / PR / keep, тело PR, уборка worktree |

**Ветвления**

- **Hardware-проект** — тот же путь: `architect` на шаге 3 дополнительно проектирует
  электронику (компоненты, расчёты, power budget, pinout, BOM) — профиля
  hardware-designer нет.
- **Фича в существующем проекте** — без шага 0: `brainstorming` → `to-spec` →
  `to-tickets` → шаги 5–8.
- **Баг** — `systematic-debugging` (tight repro) → фикс под `test-driven-development` →
  `code-review` → `verification-before-completion` перед словом «готово».
- **Архитектурный рефакторинг** — `improve-codebase-architecture` / `codebase-design` →
  `grilling` → `writing-plans` → шаги 5–8.
- **Передача работы** — `summary` (create/update) перед сменой сессии.

**Routing Gate — выбор пути (обязателен один раз на фичу/проект)**

Прежде чем диспетчить работу, оркестратор оценивает масштаб и ПРЕДЛАГАЕТ путь;
пользователь подтверждает — без «ок» не диспетчировать:

1. Оцени: число задач, новая предметная область/интеграции, решения по модели
   данных, взаимозависимые модули.
2. Предложи путь, причина — одной строкой:
   - **Короткий путь** — `orchestrator → coder → reviewer`, без отдельной сессии
     architect. Design doc пишет orchestrator сам (артефакт сохраняется — он нужен
     coder и reviewer). Критерии: план ≤ 5 задач, знакомая область, нет новых
     интеграций, нет решений по схеме данных.
   - **Длинный путь** — таблица «Рабочий путь» выше, с architect. Критерии: новая
     область/интеграции, схема данных, > 5 задач, взаимозависимые модули.
3. Исключение (без гейта): мелкая задача — однострочная правка или баг с ясным
   repro → `systematic-debugging` или сразу код + `verification-before-completion`,
   без brainstorming/writing-plans/to-tickets/SDD.
4. **Батчинг малых задач:** 2–4 мелких независимых задачи — одна сессия кодера,
   одно ревью на батч (`subagent-driven-development/references/batching.md`).
   Никогда не батчить: побочные эффекты вне worktree (миграции, деплой, live-конфиг),
   правки ядра/общего интерфейса, задачи с собственным решением или отладкой,
   security-чувствительные. Сомневаешься — не батчи.

**Примеры промптов:** «начинаем новый проект X» · «проверь план» · «оформи в спеку» ·
«нарежь тикеты» · «диспетчируй задачи» · «выполни план» · «почему падает тест» ·
«сделай ревью» · «заверши ветку / сделай PR» · «сохрани состояние».

**Действует всегда:** модель меняется только с твоего согласования (эскалация =
переназначение задачи, не тихая смена); делегация — через Kanban; служебное
(`.hermes/`, `docs/`, `workflows/`, `.scratch/`, `.codegraph/`, `summary.md`)
в git проекта не попадает; `git-guardrails` блокирует опасные git-команды.

## Ревью набора (24.10.2026)

Полное ревью набора (31 скилл на момент ревью; `spike` добавлен после — применены те же правила) субагентом (deepseek-flash) по 6 требованиям: полнота,
Hermes-совместимость, делегация через Kanban + Model Gate, отсутствие хардкод-путей,
README-профили + soul/, отсутствие висячих ссылок.

Исправлено по итогам: 12 вхождений `Skill tool` (Claude-конструкция) → `skill_view(name=...)`
в wayfinder / improve-codebase-architecture / triage / retro; 9 мест «модель в диспатче» →
«модель = профиль, эскалация = переназначение» (sdd Model Selection, 3 prompt-шаблона,
executing-plans, fix-loop, final-review); Kanban объявлен ОСНОВНЫМ путём в sdd / code-review /
dispatching-parallel-agents, in-session субагенты — фолбэк; кросс-модульные ссылки
(writing-plans→executing-plans, sdd→worktrees, finishing→pr, brainstorming→wayfinder)
переписаны как hand-off между профилями с fallback для core-only профилей; cwd-относительные
вызовы скриптов → `<skill_dir>/scripts/...`; visual-companion: добавлен блок Hermes,
Claude-специфика убрана; using-git-worktrees: один путь (git fallback); git-guardrails:
убраны `/root/`-пути, `<skillset>` → `<каталог_скилла>`.

## Как обновлять

1. Апстрим-клоны: `sources/mattpocock-skills/`, `sources/superpowers/` — `git pull` там.
2. Изменения переносить сюда ВРУЧНУЮ с нашими адаптациями (не копировать поверх!).
3. Дизайн набора: `skills-design.md`, конвейер и таблица решений: `skills-pipeline.md`.
