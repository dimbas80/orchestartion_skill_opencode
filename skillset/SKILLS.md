# Каталог скиллов и рабочий путь

32 скилла в 4 модулях (`core/`, `planning/`, `coding/`, `review/`) + шаблон проекта
внутри `project-init/template/`. Источники — в [README](README.md#источники).

Скиллы вызываются по имени: в Hermes нет «команд» — есть `description` в
frontmatter, по которому агент сам понимает, когда скилл уместен. Достаточно
написать цель человеческим языком («сделай спеку», «проверь план», «нарежь
тикеты») — агент подхватит нужный скилл и объявит об этом. Явно тоже можно:
«используй skill X».

## Модули и профили

| Модуль | Что закрывает | Профили |
|---|---|---|
| `core/` | ядро: вход в работу, домен, дисциплина «готово», bootstrap проекта, git-защита | все 7 |
| `planning/` | спека → тикеты → план → диспетчеризация; исследование, триаж, архитектурный анализ | orchestrator, architect (+ default) |
| `coding/` | исполнение плана, worktrees, TDD, отладка, фидбек, PR, ретро, визарды | coder (+ default) |
| `review/` | независимое ревью двумя осями | reviewer |

## Каталог

### core/ — ядро (все профили)

| Скилл | Что делает | Когда срабатывает |
|---|---|---|
| `brainstorming` | Интервью по одному вопросу → design doc → HARD-GATE (без аппрува дальше нельзя); по ходу раскладывает термины в `GLOSSARY.md`, решения в `docs/adr/`; в конце предлагает grilling и зовёт writing-plans | «новая фича», «давай сделаем», «начинаем проект», любая новая работа |
| `grilling` | Стресс-тест уже готового плана: пакетные раунды вопросов по frontier-дереву решений, в каждом — рекомендация | Только явно: «погрили меня», «проверь план» (или по предложению brainstorming) |
| `summary` | `summary.md` в корне проекта: режимы read / create / update; 6 секций (блокер → шаг → состояние → ошибки → скиллы → артефакты), лимит 4 000/6 000 символов | «сохрани состояние», «сделай summary» перед передачей работы |
| `verification-before-completion` | Iron Law: «готово» только со свежим доказательством (вывод команд, тесты, диффы) | Перед любым заявлением о завершении |
| `project-init` | Bootstrap проекта: копирует шаблон из **каталога самого скилла** (`template/`), `git init`, правильный `.gitignore`, `codegraph init` — до интервью | «начинаем новый проект», «создай проект» |
| `to-questionnaire` | Нерешаемый вопрос → анкета для человека, который знает ответ | Агент упёрся в вопрос, ответа нет в системе |
| `teach` | Мульти-сессионное обучение: Teaching Workspace, ZPD, learning records | «объясни», «научи меня», «проведи по теме» |
| `wait-what` | Переупаковка «не долетевшего» сообщения по-другому (с опорой на GLOSSARY) | «повтори по-другому», «не понял» |
| `writing-for-agents` | Как писать доки и скиллы для агентов: pointer-дисциплина, разрезание, экономия контекста; `SKILL-MECHANICS.md` — механика скиллов именно Hermes | «напиши скилл», «напиши AGENTS.md», «доки для агентов» |
| `git-guardrails` | Hermes shell-hook (`hooks.pre_tool_call`): блок `git push`, `reset --hard`, `clean -f`, `branch -D`, `checkout .`, `restore .`; exit 2 = блок | Всегда после установки хука (один скрипт на все проекты) |

### planning/ — планирование (orchestrator, architect)

| Скилл | Что делает | Когда срабатывает |
|---|---|---|
| `domain-modeling` | Полная дисциплина `GLOSSARY.md` / ADR: единый словарь, решения с последствиями | «сведи домен», «разберись с терминами» |
| `to-spec` | Разговор → спека без нового интервью; фича-спека в `.scratch/<feature>/spec.md`, продуктовые доки в `docs/product/` | «оформи в спеку», «зафиксируй требования» |
| `to-tickets` | Спека/план → tracer-bullet тикеты (`.scratch/issues/NN-slug.md`) + зеркала Kanban-задач | «нарежь тикеты», «разложи на задачи» |
| `wayfinder` | Большая «туманная» работа: карта решений (destination, decision tickets, frontier) вместо преждевременного тикета | «непонятно с чего начать», работа не влезает в один заход |
| `spike` | Прототип-выброс: decompose → research → build → verdict (VALIDATED / PARTIAL / INVALIDATED); одноразовый код в `spikes/`, вывод — README спайка | «прикинь прототип», «сравни подходы A и B», «возможно ли вообще» — когда docs не отвечают |
| `writing-plans` | Спека → `docs/architecture/implementation-plan.md` (фикс. имя = контракт handoff архитектор→кодер); цепочка TDD-шагов | Утверждённый дизайн/спека есть, нужен план внедрения |
| `subagent-driven-development` | Диспетчерский режим: план → Kanban-задачи по профилям (fresh контекст), task review после каждой, финальный ревью ветки, **Model Gate** | План готов, «диспетчируй задачи», «разложи по ролям» |
| `dispatching-parallel-agents` | Параллельные независимые домены: по задаче на домен, интеграция после возврата | Несколько независимых участков работы |
| `finishing-a-development-branch` | Merge / PR / keep: решение с человеком, PR-тело через `pr`, уборка worktree, discard-протокол | «заверши ветку», «сделай PR», «влей» |
| `research` | Первоисточники → Markdown с цитатами; веб — через hub-скиллы tavily-* (если их нет в профиле — встроенные web_search/web_extract) | «изучи рынок», «собери факты по…» |
| `triage` | State machine триажа issues/PR по лейблам (`docs/agents/triage-labels.md`) | «разгреби issues», «присвой лейблы» |
| `codebase-design` | Словарь глубоких модулей и вариантов интерфейсов (architect) | «спроектируй модуль», «предложи интерфейс» |
| `improve-codebase-architecture` | Скан кодовой базы на углубления → HTML-отчёт (::preview) → grilling | «где архитектура просела», «сделай анализ кода» |

### coding/ — исполнение (coder)

| Скилл | Что делает | Когда срабатывает |
|---|---|---|
| `executing-plans` | Инлайн-исполнение плана: ledger, TDD-шаги, completion contract, финал = hand-off Orchestrator'у (не самомерж) | План получен, coder работает в своей сессии |
| `using-git-worktrees` | Изоляция workspace (`.worktrees/`), baseline-тесты, guard «не git-репо → стоп» | Перед началом имплементации |
| `test-driven-development` | RED → verify RED → GREEN → verify GREEN → REFACTOR; anti-patterns | Любой код по плану |
| `systematic-debugging` | 4 фазы; Feedback Loop Rule (сначала tight repro), Rule of Three | «не работает», баг, падающий тест |
| `receiving-code-review` | Приём фидбека: verify before implement, без «You're absolutely right!», фиксация причины | Получен `review.md` от ревьюера |
| `pr` | Тело PR: Summary / Evidence / Merge Danger (blast radius) | «оформи PR» |
| `retro` | Ретроспектива сессии: что зашло, где среда агента мешала, guardrails | «ретро», «разбор сессии» |
| `wizard` | Bash-визарды для шагов, которые человек делает руками (`template.sh`) | Нужен интерактивный сценарий для человека |

### review/ — ревью (reviewer)

| Скилл | Что делает | Когда срабатывает |
|---|---|---|
| `code-review` | Две независимые оси: **Standards** (документированные стандарты + смеллы Фаулера) и **Spec** (соответствие требованиям); агрегация без ре-ранжирования | Задача ревью пришла от Orchestrator'а |

---

# Рабочий путь пользователя

Роли: **orchestrator** ведёт разговор, планирует, диспетчит; **architect** проектирует;
**coder** пишет; **reviewer** проверяет независимо. Задачи ходят через Kanban-доску
проекта, модели исполнителей согласуются **до** постановки задач (Model Gate).

## 0. Установка набора (администратор)

```bash
# скиллы по модулям в профили (см. README → Профили)
cp -r skills/core/*      ~/.hermes/profiles/<профиль>/skills/   # все 7 профилей
cp -r skills/coding/*    ~/.hermes/profiles/coder/skills/
cp -r skills/planning/*  ~/.hermes/profiles/orchestrator/skills/
cp -r skills/planning/*  ~/.hermes/profiles/architect/skills/
cp -r skills/review/*    ~/.hermes/profiles/reviewer/skills/
# персоны
cp soul/orchestrator.md ~/.hermes/profiles/orchestrator/SOUL.md   # и т.д.
```

Шаблон отдельно копировать не нужно — он уже внутри `project-init/template/`.

## 1. Новый проект (главный сценарий)

1. **«Начинаем новый проект <название>, суть: …»** → `project-init`: копирует шаблон,
   `git init`, `.gitignore`, `codegraph init`.
2. **Интервью** → `brainstorming`: агент задаёт по одному вопросу, отвечаешь; термины
   падают в `GLOSSARY.md`, решения в `docs/adr/`, итог — design doc в `docs/product/`.
   HARD-GATE: без твоего «ок» дальше не идёт.
3. **«Проверь план»** (по желанию) → `grilling`: пакетные раунды жёстких вопросов,
   в каждом есть рекомендация; ответы вливаются в план.
4. **План внедрения** → `writing-plans` (architect): `docs/architecture/implementation-plan.md`.
   Если работа «туманная» и не режется — сначала `wayfinder` (карта решений).
5. **«Нарежь тикеты»** → `to-tickets`: файлы в `.scratch/issues/` + зеркала Kanban.
6. **«Диспетчируй»** → `subagent-driven-development`: сначала **Model Gate** — таблица
   «кто из профилей на какой модели/провайдере», ты утверждаешь (провайдеры бывают
   нестабильны), потом задачи на доску `board=<slug>`.
7. **coder**: `executing-plans` (+ `using-git-worktrees`, TDD, `systematic-debugging`
   при отладке) → отчёт `workflows/<task_id>/implementation-report.md`.
8. **reviewer**: `code-review` → `workflows/<task_id>/review.md`; замечания →
   `receiving-code-review` у coder'а, до 3 раундов.
9. **«Заверши ветку»** → `finishing-a-development-branch`: merge/PR/keep — решение твоё;
   тело PR — `pr`.

## 2. Фича в существующем проекте

`brainstorming` (короткое интервью) → `to-spec` (оформить спеку) → `to-tickets` →
диспетчеризация → `code-review`.

## 3. Баг

`systematic-debugging` (tight repro, 4 фазы) → фикс под `test-driven-development` →
`code-review` → `verification-before-completion` перед словом «готово».

## 4. Архитектурный рефакторинг

`improve-codebase-architecture` или `codebase-design` → `grilling` → `writing-plans` →
диспетчеризация. Решение «что углублять» фиксируется в ADR.

## 5. Передача работы / обучение

`summary` (create/update перед сменой сессии) · `teach` (разобраться в теме) ·
`wait-what` (объяснение по-другому) · `to-questionnaire` (вопрос человеку, который знает).

## Примеры промптов

| Скажи | Что произойдёт |
|---|---|
| «начинаем новый проект X» | project-init → brainstorming |
| «проверь план» | grilling (стресс-тест) |
| «оформи в спеку» | to-spec → `.scratch/.../spec.md` |
| «нарежь тикеты» | to-tickets + зеркала Kanban |
| «диспетчируй задачи» | sdd: Model Gate → задачи по профилям |
| «выполни план» (в сессии coder) | executing-plans + TDD |
| «почему падает тест» | systematic-debugging |
| «сделай ревью» | code-review (две оси) |
| «заверши ветку / сделай PR» | finishing-a-development-branch + pr |
| «сохрани состояние» | summary.md |
| «прикинь прототип / сравним подходы» | spike (spikes/ + verdict) |
| «научи меня <теме>» | teach |

## Правила, которые действуют всегда

- **Модели — только с согласованием.** Orchestrator показывает map профилей → моделей
  и ждёт утверждения; тихая смена модели запрещена, эскалация = переназначение задачи.
- **Делегация — через Kanban**, не через субагентов внутри сессии (те — только фолбэк).
- **Никаких хардкод-путей:** скрипты вызываются как `<skill_dir>/scripts/…`.
- **git-guardrails** включён во всех профилях: опасные git-команды блокируются хуком.
- **Служебное — вне git проекта:** `.hermes/`, `docs/`, `workflows/`, `.scratch/`,
  `.codegraph/`, `summary.md` игнорируются шаблонным `.gitignore`.
