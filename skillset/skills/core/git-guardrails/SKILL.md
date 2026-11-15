---
name: git-guardrails
description: "Настроить защиту от опасных git-команд (push, reset --hard, clean -f, branch -D, checkout/restore .) до исполнения: zcode — PreToolUse hook; opencode — permission.deny. Триггеры: «защити от git push», «git guardrails», «блокируй опасные git команды». Для шагов, которые агент может сделать сам, не вызывается."
---

# Git Guardrails

Ставит защиту, которая перехватывает и блокирует опасные git-команды до
исполнения. Один скрипт (`scripts/block-dangerous-git.sh`) обслуживает zcode:
PreToolUse-хуки zcode принимают тот же stdin-JSON (`tool_input.command`),
что и Claude Code, `exit 2` = блок. opencode хуков pre-tool не имеет — там
эквивалент ставится deny-правилами.

## Что блокируется

- `git push` (все варианты, включая `--force`)
- `git reset --hard`
- `git clean -f` / `git clean -fd`
- `git branch -D`
- `git checkout .` / `git restore .`

При блокировке (zcode) агент видит: `BLOCKED: '<команда>' matches dangerous
pattern '<паттерн>'. The user has prevented you from doing this.`

## Ограничение v1 (осознанное)

Скрипт ловит команды shell-инструмента. Git, запущенный из кода
(python-subprocess внутри исполняемого скрипта), не ловится — как и в
Claude Code ловился только Bash. Расширение покрытия — по запросу.

## Установка — zcode (hook)

### 1. Скопировать скрипт

```bash
mkdir -p ~/.agents/hooks
cp <каталог_скилла>/scripts/block-dangerous-git.sh \
   ~/.agents/hooks/block-dangerous-git.sh
chmod +x ~/.agents/hooks/block-dangerous-git.sh
```

Один скрипт обслуживает все проекты.

### 2. Зарегистрировать PreToolUse-хук

В `<репо>/.zcode/config.json` (проектный scope) или
`~/.zcode/cli/config.json` (user scope):

```json
{
  "hooks": {
    "enabled": true,
    "PreToolUse": [
      { "matcher": "Bash",
        "hooks": [ { "command": "~/.agents/hooks/block-dangerous-git.sh", "timeout": 10 } ] }
    ]
  }
}
```

- Матчер — имя shell-инструмента zcode (`Bash`).
- `hooks.enabled: true` обязателен: хуки из конфиг-файла без него не запускаются.
- Блокирующее поведение даёт сам скрипт (exit 2 на опасной команде);
  доступность `fail_closed`-настройки проверь в своей версии zcode
  (скилл `diagnosing-hooks`).

### 3. Спросить про кастомизацию

Спроси пользователя, добавить/убрать паттерны из списка блокировки
(например, разрешить `git push` в определённые ветки нельзя паттерном — это
делается расширением скрипта). Правится копия скрипта в `~/.agents/hooks/`.

### 4. Verify

```bash
echo '{"tool_input":{"command":"git push origin main"}}' \
  | ~/.agents/hooks/block-dangerous-git.sh; echo "exit=$?"
```

Ожидаемо: `BLOCKED: ...` на stderr, `exit=2`. Безопасная команда (`git status`)
даёт `exit=0` без вывода. Затем — живая проверка в сессии: попросить агента
выполнить `git push` и убедиться, что хук сработал.

## Установка — opencode (permissions)

В `opencode.json` (workspace) или `~/.config/opencode/opencode.json`
(глобально) — deny-паттерны, точный список из скрипта:

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

Расширение списка — правка deny-массива. Verify: попросить агента выполнить
`git push` — отказ по deny-правилу.

## Откат

- zcode: удалить блок `hooks` (или его PreToolUse-запись) из config.json и
  скрипт из `~/.agents/hooks/`.
- opencode: удалить записи из `permission.deny`.
Откат действует с новой сессии (zcode).
