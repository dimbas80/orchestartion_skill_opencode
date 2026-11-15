# SOUL.md профилей

Эта папка — рабочие персоны профилей Hermes для этого набора.
`default.md` взят из `$HERMES_HOME/SOUL.md` (обычно `~/.hermes`), остальные —
из `~/.hermes/profiles/<профиль>/SOUL.md`; `architect.md` и `orchestrator.md`
отредактированы здесь (единый архитектор софт+хард, без hardware-designer).

Нужны для полной переустановки набора на другой машине/агенте: модули скиллов
(`skills/`) + персоны профилей (`soul/`) + шаблон проекта
(`skills/core/project-init/template/`) = самодостаточный комплект.

| Файл | Профиль |
|---|---|
| `default.md` | default — универсал (desktop, этот чат) |
| `orchestrator.md` | orchestrator — system_engineer, ведёт конвейер, маршрутизация Kanban |
| `architect.md` | architect — system_architect: **софт, система и железо** (единственный архитектор; hardware-designer влит сюда) |
| `coder.md` | coder — developer (software + firmware) |
| `reviewer.md` | reviewer — independent_reviewer |
| `enginer.md` | enginer — инженер-проектировщик (вне конвейера) |
| `3dprint.md` | 3dprint — Telegram-бот по 3D-печати |

**hardware-designer удалён** (решение Дмитрия, 24.10.2026): профиль будет
удалён из системы, его специфика (электрическая архитектура, выбор
компонентов, расчёты, pinout, BOM, верификация) перенесена в `architect.md`,
а маршрутизация в `orchestrator.md` больше не ссылается на него.

Установка на новой машине: положить содержимое файла в
`$HERMES_HOME/SOUL.md` соответствующего профиля. Это снимок на 24.10.2026 —
при расхождении с живым профилем источником истины остаётся живой профиль
(кроме architect/orchestrator: здесь — отредактированные версии).
