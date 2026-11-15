#!/bin/bash
# wave-monitor.sh — постановка cron-монитора волны канбан-карточек для профиля orchestrator.
#
# Почему он, а не ручной cron: возвращает ошибки ДО постановки (id не на доске,
# пустой вердикт-токен), ставит --deliver bot-chat:orchestrator явно (дефолт local
# молча теряет вывод), проверяет задачу чтением jobs.json после создания.
#
# Использование:
#   wave-monitor.sh arm <id1> <id2> ... [--board SLUG] [--workdir PATH] [--every 10m] [--paused]
#                                    [--telegram-chat ID] [--deliver "цель,цель"]
#   wave-monitor.sh disarm-all          # снять все wave-monitor-задачи
#   wave-monitor.sh list                # показать активные мониторы
set -euo pipefail

PROFILE=orchestrator
SCRIPTS_DIR="$HOME/.hermes/profiles/$PROFILE/scripts"
JOBS_JSON="$HOME/.hermes/profiles/$PROFILE/cron/jobs.json"
DELIVER="bot-chat:$PROFILE"
deliver_override=""
tg_chat="${WAVE_MONITOR_TELEGRAM_CHAT:-}"
mkdir -p "$SCRIPTS_DIR"

die() { echo "ОШИБКА: $*" >&2; exit 1; }

cmd="${1:-}"; shift || true

# ── disarm-all: снять все wave-monitor-задачи профиля (забытый повторяющийся
#    монитор репортит один и тот же вердикт каждые N минут)
if [ "$cmd" = "disarm-all" ]; then
  [ -f "$JOBS_JSON" ] || die "стор пуст: $JOBS_JSON"
  for jid in $(python3 - "$JOBS_JSON" <<'PYLIST2'
import json, sys
data = json.load(open(sys.argv[1]))
jobs = data.get("jobs", data) if isinstance(data, dict) else data
seq = jobs if isinstance(jobs, list) else list(jobs.values())
for j in seq:
    if isinstance(j, dict) and str(j.get("name", "")).startswith(("wave-monitor", "wave-")):
        print(j.get("id") or j.get("job_id"))
PYLIST2
); do
    hermes -p "$PROFILE" cron remove "$jid" && echo "снят: $jid"
  done
  exit 0
fi

# ── list: активные мониторы профиля
if [ "$cmd" = "list" ]; then
  hermes -p "$PROFILE" cron list 2>/dev/null || echo "(пусто)"
  exit 0
fi

[ "$cmd" = "arm" ] || die "режим: arm | disarm-all | list"

board=""; workdir=""; every="10m"; paused=""; name=""
ids=()
while [ $# -gt 0 ]; do
  case "$1" in
    --board)  board="$2";  shift 2 ;;
    --workdir) workdir="$2"; shift 2 ;;
    --every)  every="$2";  shift 2 ;;
    --name)   name="$2";   shift 2 ;;
    --paused) paused="--paused"; shift ;;
    --telegram-chat) tg_chat="$2"; shift 2 ;;
    --deliver) deliver_override="$2"; shift 2 ;;
    t_*)      ids+=("$1"); shift ;;
    *) die "неизвестный аргумент: $1" ;;
  esac
done

[ "${#ids[@]}" -ge 1 ] || die "укажи хотя бы один id карточки: wave-monitor.sh arm t_xxx t_yyy"

# ── board: явный флаг или текущая доска CLI
if [ -z "$board" ]; then
  board=$(hermes kanban boards list 2>/dev/null | awk '/^●/{print $2}')
  [ -n "$board" ] || die "не удалось определить текущую доску — задай --board SLUG"
fi

# ── workdir: явный флаг или каталог с workflows/ в cwd
if [ -z "$workdir" ]; then
  [ -d workflows ] && workdir="$PWD"
  [ -n "$workdir" ] || die "в cwd нет workflows/ — задай --workdir /путь/к/репо"
fi
[ -d "$workdir" ] || die "workdir не существует: $workdir"

# ── проверка id на доске ДО постановки: опечатка id = монитор, который никогда не сработает
list_json=$(hermes kanban --board "$board" list --json 2>/dev/null) \
  || die "не удалось прочитать доску $board"
for id in "${ids[@]}"; do
  echo "$list_json" | python3 -c "
import json, sys
ids = {t.get('id') for t in json.load(sys.stdin) if isinstance(t, dict)}
sys.exit(0 if '$id' in ids else 1)" \
    || die "карточка $id не найдена на доске $board — проверь id"
done

# ── имя и файл статус-скрипта
[ -n "$name" ] || name="wave-monitor-$board-$(date +%d%H%M)"
case "$name" in wave-*) ;; *) name="wave-monitor-$name" ;; esac
base="status_${name}.sh"
status_script="$SCRIPTS_DIR/$base"

# ── генерация детерминированного статус-скрипта (без таймстампов: cron-монитор
#    сравнивает вывод по хешу байт-в-байт; любое «время» сделало бы тик шумом)
ids_str="${ids[*]}"
cat > "$status_script" <<TEMPLATE
#!/bin/bash
# Сгенерирован wave-monitor.sh (board=$board, workdir=$workdir). НЕ править руками.
cd '$workdir' || exit 1
hermes kanban --board '$board' list --json 2>/dev/null | python3 -c '
import json, sys, re, glob, os
IDS = "$ids_str".split()
TOKEN = re.compile(r"(?:Вердикт|Verdict)\s*:?\s*\**\s*(CHANGES_REQUESTED|PASS)")
try:
    tasks = {t.get("id"): t for t in json.load(sys.stdin) if isinstance(t, dict)}
except Exception:
    tasks = {}
def verdict(tid):
    best = None  # (mtime, token) — при нескольких файлах берём самый свежий
    for f in glob.glob("workflows/%s*/review.md" % tid):
        try:
            txt = open(f, encoding="utf-8", errors="replace").read()
        except OSError:
            continue
        hits = TOKEN.findall(txt)
        # последний по файлу и по позиции (доработки дописывают вердикт в конец)
        if hits:
            key = (os.path.getmtime(f), hits[-1])
            if best is None or key > best:
                best = key
    return best[1] if best else "NONE"
for i in IDS:
    t = tasks.get(i, {})
    print("%s status=%s verdict=%s" % (i, t.get("status", "NOT_ON_BOARD"), verdict(i)))
'
TEMPLATE
chmod +x "$status_script"

# ── сухой прогон ДО постановки: монитор с битым извлечением — тот самый отказ,
#    из-за которого оркестратор трижды «следил» вхолостую
out=$(bash "$status_script") || die "статус-скрипт упал при прогоне"
echo "── сухой прогон $base:"
echo "$out"
for id in "${ids[@]}"; do
  line=$(echo "$out" | grep "^$id " || true)
  [ -n "$line" ] || die "$id не печатается статус-скриптом"
  echo "$line" | grep -q "status=[a-z_]*" || die "$id: пустой статус"
  echo "$line" | grep -Eq "verdict=(PASS|CHANGES_REQUESTED|NONE)" || die "$id: вердикт-токен пустой/мусорный — извлечение сломано"
done

# ── сборка целей: bot-chat (будит агента) + telegram (доходит до хозяина).
#    Важно: `telegram` без chat_id = home_channel профиля, а он у части профилей
#    не задан (доставка молча падает) — поэтому chat_id передаётся явно.
if [ -n "$deliver_override" ]; then
  DELIVER="$deliver_override"
elif [ -n "$tg_chat" ]; then
  DELIVER="telegram:$tg_chat,bot-chat:$PROFILE"
fi
echo "── цели доставки: $DELIVER"

# ── постановка cron: ТОЛЬКО через CLI (inline-вызов с длинным промптом коллапсирует),
#    --deliver явно (дефолт local не появляется в чате, вывод теряется молча)
prompt="Wave monitor tick. Tracked tasks above. Правила: любой verdict=CHANGES_REQUESTED -> прочитай workflows/<id>/review.md, перечисли требуемые правки, по строке на находку. Все verdict=PASS и все статусы done -> ответь ровно: WAVE COMPLETE. Иначе ответь ровно: WAITING. Доску и карточки не менять."
hermes -p "$PROFILE" cron create "every $every" \
  --name "$name" \
  --monitor-script "$base" \
  --workdir "$workdir" \
  --deliver "$DELIVER" \
  $paused \
  "$prompt"

# ── верификация чтением стора: «ok» от CLI ничего не доказывает
sleep 1
[ -f "$JOBS_JSON" ] || die "jobs.json не создан — задача не записалась"
python3 - "$name" "$JOBS_JSON" <<'PYCHECK'
import json, sys
name, path = sys.argv[1], sys.argv[2]
data = json.load(open(path))
jobs = data.get("jobs", data) if isinstance(data, dict) else data
job = next((j for j in (jobs if isinstance(jobs, list) else jobs.values())
            if isinstance(j, dict) and name in str(j.get("name", ""))), None)
if not job:
    sys.exit(f"ОШИБКА: задача {name} не найдена в {path}")
print(f"── верификация стора: name={job.get('name')} deliver={job.get('deliver')} "
      f"monitor={job.get('monitor_script') or job.get('monitorScript')} enabled={job.get('enabled')}")
deliver = str(job.get("deliver", ""))
if "bot-chat" not in deliver:
    sys.exit("ОШИБКА: в deliver нет bot-chat — агента не разбудит")
print(f"   цели: {[x.strip() for x in deliver.split(',') if x.strip()]}")
PYCHECK

echo "── ГОТОВО: монитор '$name' стоит (первый тик даст baseline-WAITING — это норма)."
echo "   После реакции на WAVE COMPLETE / CHANGES_REQUESTED снять: $0 disarm-all"
echo "   Снятый монитор репортит один вердикт каждые $every — не забудь."

exit 0
