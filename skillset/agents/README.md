# agents/ — персоны под zcode и opencode

Бывшие профили (`soul/`) исходной версии набора, переработанные под модель
«ведущая сессия + субагенты». Профилей-установок больше нет: персоны живут в файлах этой папки
и разворачиваются в файлы конкретного харнесса (`install/emit.sh` или вручную
по [install/zcode.md](../install/zcode.md) / [install/opencode.md](../install/opencode.md)).

## Кто куда

| Файл | Роль | zcode | opencode |
|---|---|---|---|
| `session-lead.md` | Ведущая сессия: универсал по умолчанию (solo), оркестратор конвейера — когда Routing Gate его выбрал | секция в workspace `AGENTS.md` (шаблон `project-init/template/`) | оверрайд `build`: `.opencode/agent/build.md` |
| `architect.md` | Субагент: архитектора (софт, система, железо) | `.zcode/agents/architect.md` | `.opencode/agent/architect.md` (`mode: subagent`) |
| `coder.md` | Субагент: разработчик (software + firmware) | `.zcode/agents/coder.md` | `.opencode/agent/coder.md` (`mode: subagent`) |
| `reviewer.md` | Субагент: независимый ревьюер | `.zcode/agents/reviewer.md` | `.opencode/agent/reviewer.md` (`mode: subagent`) |

`session-lead.md` — НЕ субагент: все гейты набора (HARD-GATE, Routing Gate,
Model Gate, merge-решение) требуют живого диалога с пользователем, а субагенты
в обоих харнессах не интерактивны — только отчёт родителю. Оркестратор-субагент
превратил бы каждый гейт в лишний хоп.

## Solo-first

Ведущая сессия по умолчанию работает сама (аналог профиля `default` исходной версии):
конвейер включается только через Routing Gate или явную просьбу
(«диспетчируй задачи»). Полная доктрина — в `session-lead.md`.

## examples/ — персоны вне конвейера

Бывшие профили `default`, `enginer`, `3dprint` не переносятся как глобальные
установки. Их место — паттерн «workspace-персона»:

- **zcode**: персона = workspace `AGENTS.md` соответствующего проекта
  (или пользовательский `~/.zcode/AGENTS.md` для постоянной, как бывший
  `default`).
- **opencode**: персона = кастомный primary-агент (`~/.config/opencode/agent/<имя>.md`,
  `mode: primary`) — переключается Tab'ом, ближайший аналог «смены профиля».

Файлы в `examples/` — очищенные от механик исходной платформы (`delegate_task`, `ctx_*`)
тела персон; кладутся в соответствующее место как есть.

## Общие блоки

Блоки CodeGraph и «Skill library policy» остаются внутри тел персон (как в
исходных SOUL.md) — они короткие и нужны каждой роли независимо от того,
попадает ли ей workspace `AGENTS.md`.
