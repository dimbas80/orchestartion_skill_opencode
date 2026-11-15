---
name: git-guardrails
description: "Настроить shell-hook Hermes (pre_tool_call), блокирующий опасные git-команды (push, reset --hard, clean -f, branch -D, checkout/restore .) до исполнения. Триггеры: «защити от git push», «git guardrails», «блокируй опасные git команды». Для шагов, которые агент может сделать сам, не вызывается."
---

# Git Guardrails (Hermes shell hooks)

Ставит `pre_tool_call` shell-hook, который перехватывает и блокирует опасные
git-команды до исполнения. Формат Hermes совместим с Claude Code: хук получает
JSON в stdin (`tool_input.command`), `exit 2` = блок.

## Что блокируется

- `git push` (все варианты, включая `--force`)
- `git reset --hard`
- `git clean -f` / `git clean -fd`
- `git branch -D`
- `git checkout .` / `git restore .`

При блокировке агент видит: `BLOCKED: '<команда>' matches dangerous pattern
'<паттерн>'. The user has prevented you from doing this.`

## Ограничение v1 (осознанное)

Хук вешается на tool **`terminal`** (matcher). Git, запущенный из
`code_execution` (python-subprocess), этим хуком не ловится — как и в Claude
Code ловился только Bash. Расширение матчера — по запросу.

## Установка

### 1. Скопировать скрипт

```bash
mkdir -p ~/.hermes/agent-hooks
cp <каталог_скилла>/scripts/block-dangerous-git.sh \
   ~/.hermes/agent-hooks/block-dangerous-git.sh
chmod +x ~/.hermes/agent-hooks/block-dangerous-git.sh
```

`~/.hermes/agent-hooks/` — конвенция Hermes для shell-хуков; один скрипт
обслуживает все проекты (профиль передаётся в payload).

### 2. Зарегистрировать хук в config.yaml КАЖДОГО профиля

Хуки профильные: блокировка действует в тех профилях, чей config.yaml
содержит блок. Для полного покрытия повторить для всех профилей
(`$HERMES_HOME` каждого: у default-профиля обычно `~/.hermes`, у остальных `~/.hermes/profiles/<имя>`).

```bash
hermes config set -p <профиль> hooks.pre_tool_call \
  '[{"matcher": "terminal", "command": "~/.hermes/agent-hooks/block-dangerous-git.sh", "timeout": 10, "fail_closed": true}]'
```

Эквивалент в config.yaml:

```yaml
hooks:
  pre_tool_call:
    - matcher: "terminal"
      command: ~/.hermes/agent-hooks/block-dangerous-git.sh
      timeout: 10
      fail_closed: true
```

- `fail_closed: true` — обязателен для security-гейта: упавший/затайм-аутившийся
  скрипт **блокирует** команду, а не пропускает её.
- После правки config.yaml проверить парсинг (`hermes config get hooks`).

### 3. Спросить про кастомизацию

Спроси пользователя, добавить/убрать паттерны из списка блокировки
(например, разрешить `git push` в определённые ветки нельзя паттерном — это
делается расширением скрипта). Правится копия скрипта в `agent-hooks/`.

### 4. Verify

```bash
echo '{"tool_input":{"command":"git push origin main"}}' \
  | ~/.hermes/agent-hooks/block-dangerous-git.sh; echo "exit=$?"
```

Ожидаемо: `BLOCKED: ...` на stderr, `exit=2`. Безопасная команда (`git status`)
даёт `exit=0` без вывода.

### 5. Активация и consent

- Хук доезжает в **новые сессии** / после рестарта gateway.
- Консент-модель Hermes: при **первом** срабатывании пары (event, command)
  Hermes спросит пользователя подтвердить хук (`hooks_auto_accept: false` по
  умолчанию) — это одноразовое подтверждение на профиль.
- `hermes hooks list` показывает зарегистрированные shell-хуки.

## Откат

Удалить блок `hooks.pre_tool_call` из config.yaml профилей
(`hermes config unset -p <профиль> hooks.pre_tool_call`) и скрипт из
`~/.hermes/agent-hooks/`. Откат действует с новой сессии.
