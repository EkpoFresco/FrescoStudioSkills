#!/usr/bin/env bash
# rbx-studio hook dispatcher (bash / Git Bash). Usage: rbx-hook.sh <event>
# Events: session-start | prompt | pre-bash | post-write | pre-compact | stop | notify
#
# Contract:
# - Outside a Roblox project: exit 0, print nothing, write nothing.
# - Inside one: write only under <project>/.rbx-studio/.
# - No dependencies beyond Git Bash coreutils (grep, sed, awk). jq is used if present.
# - Exit 2 only from pre-bash (blocks the tool call). Everything else is advisory.

RBX_HOME="{{RBX_HOME}}"
case "$RBX_HOME" in *"{{"*|"") RBX_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)" ;; esac
EVENT="${1:-}"
INPUT="$(cat 2>/dev/null)"

# ---------- JSON helpers (no jq required) ----------
json_unescape() {
  # Decode the common JSON escapes. \\ first via a placeholder.
  LC_ALL=C awk '{ gsub(/\\\\/, "\001"); gsub(/\\n/, "\n"); gsub(/\\r/, ""); gsub(/\\t/, "\t"); gsub(/\\"/, "\""); gsub(/\\\//, "/"); print }' | tr '\001' '\\'
}
# json_get <key>: first string value for "key" anywhere in INPUT.
json_get() {
  local raw
  raw=$(printf '%s' "$INPUT" | LC_ALL=C grep -oE "\"$1\"[[:space:]]*:[[:space:]]*\"(\\\\.|[^\"\\\\])*\"" | head -1)
  [ -z "$raw" ] && return 0
  printf '%s' "$raw" | LC_ALL=C sed -E "s/^\"$1\"[[:space:]]*:[[:space:]]*\"//; s/\"$//" | json_unescape
}
json_escape() {
  LC_ALL=C awk 'BEGIN{ORS=""} { gsub(/\\/, "\\\\"); gsub(/"/, "\\\""); gsub(/\t/, "\\t"); gsub(/\r/, ""); if (NR>1) print "\\n"; print }'
}
to_unix_path() {
  if command -v cygpath >/dev/null 2>&1; then cygpath -u "$1" 2>/dev/null || printf '%s' "$1"; else printf '%s' "$1"; fi
}

# ---------- project root + detection ----------
CWD="$(json_get cwd)"
ROOT="${CLAUDE_PROJECT_DIR:-$CWD}"
[ -z "$ROOT" ] && ROOT="$PWD"
ROOT="$(to_unix_path "$ROOT")"
SESSION="$(json_get session_id)"
SESSION="${SESSION//[^A-Za-z0-9_-]/}"
STATE="$ROOT/.rbx-studio/state"

is_roblox() { # $1 = deep (1) or shallow (0)
  [ -d "$ROOT/.rbx-studio" ] && return 0
  local f
  for f in "$ROOT"/*.project.json "$ROOT"/*.rbxl "$ROOT"/*.rbxlx "$ROOT"/wally.toml "$ROOT"/rokit.toml "$ROOT"/aftman.toml "$ROOT"/foreman.toml; do
    [ -e "$f" ] && return 0
  done
  if [ -f "$ROOT/.mcp.json" ] && grep -qiE 'StudioMCP|roblox' "$ROOT/.mcp.json" 2>/dev/null; then return 0; fi
  if [ "${1:-0}" = 1 ]; then
    find "$ROOT" -maxdepth 3 \( -name node_modules -o -name .git -o -name Packages \) -prune -o -name '*.luau' -print 2>/dev/null | head -1 | grep -q . && return 0
  fi
  return 1
}

ensure_state() {
  mkdir -p "$STATE" 2>/dev/null || return 1
  [ -f "$ROOT/.rbx-studio/.gitignore" ] || printf 'state/\n' > "$ROOT/.rbx-studio/.gitignore"
}

yaml_val() { # yaml_val <key>  (flat "key: value" anywhere in project.yaml, first match)
  local y="$ROOT/.rbx-studio/project.yaml"
  [ -f "$y" ] || return 0
  grep -E "^[[:space:]]*$1:[[:space:]]*" "$y" | head -1 | sed -E "s/^[[:space:]]*$1:[[:space:]]*//; s/[[:space:]]+#.*$//; s/^[\"']//; s/[\"']$//"
}

file_age_s() { # seconds since mtime, or 999999
  local m now
  m=$(date -r "$1" +%s 2>/dev/null) || { echo 999999; return; }
  now=$(date +%s); echo $(( now - m ))
}

# ---------- remote guard scan ----------
# Prints "line" for each inline OnServerEvent/OnServerInvoke handler that takes client
# args beyond player and shows no guard within the next 12 lines.
guard_scan() { # $1 = file
  local extra
  extra=$(yaml_val guard_words | tr -d '[]"' | tr ',' '\n' | sed 's/^ *//; s/ *$//' | grep -v '^$' | tr '\n' '\034')
  LC_ALL=C awk -v extra="$extra" '
    function guarded(s,   n, i, w) {
      if (s ~ /typeof[ ]*\(/ || s ~ /(^|[^A-Za-z0-9_])t\.[a-z]/ || s ~ /[Gg]uard/ || s ~ /[Vv]alidat/ || s ~ /assert[ ]*\(/ || s ~ /[Cc]heck/ || s ~ /rbx:guarded/ || s ~ /[Ss]anitiz/) return 1
      n = split(extra, w, "\034"); for (i = 1; i <= n; i++) if (w[i] != "" && index(s, w[i]) > 0) return 1
      return 0
    }
    { line[NR] = $0 }
    END {
      for (i = 1; i <= NR; i++) {
        s = line[i]
        if (s !~ /OnServerEvent[ ]*:[ ]*Connect[ ]*\(/ && s !~ /OnServerInvoke[ ]*=/) continue
        if (s !~ /function[ ]*\(/) continue           # named handler: cannot see params
        p = s; sub(/.*function[ ]*\(/, "", p); sub(/\).*/, "", p); gsub(/[ \t]/, "", p)
        if (p !~ /,/) continue                        # only player: no client data
        if (i > 1 && line[i-1] ~ /rbx:guarded/) continue
        ok = 0; for (j = i; j <= i + 12 && j <= NR; j++) if (guarded(line[j])) { ok = 1; break }
        if (!ok) print i
      }
    }' "$1"
}

# ================= events =================
case "$EVENT" in

session-start)
  is_roblox 1 || exit 0
  ver="$(cat "$RBX_HOME/VERSION" 2>/dev/null)"
  echo "[rbx-studio ${ver:-dev}] Roblox project detected at $ROOT"
  [ -f "$RBX_HOME/CONTEXT.md" ] && cat "$RBX_HOME/CONTEXT.md"
  echo
  if [ -f "$ROOT/.rbx-studio/project.yaml" ]; then
    echo "Project: genre=$(yaml_val genre) toolchain=$(yaml_val toolchain) rigor=$(yaml_val rigor) team_size=$(yaml_val team_size)"
    [ -f "$ROOT/.rbx-studio/conventions.md" ] || echo "Gap: no .rbx-studio/conventions.md. /rbx-start builds it."
  else
    echo "No .rbx-studio/project.yaml yet. Suggest /rbx-start before other rbx skills."
  fi
  if [ -f "$ROOT/.rbx-studio/checkpoint.md" ]; then
    echo "Checkpoint: .rbx-studio/checkpoint.md ($(( $(file_age_s "$ROOT/.rbx-studio/checkpoint.md") / 60 )) min old). After a crash or compaction, run /rbx-resume."
  fi
  if [ -f "$STATE/last-turn.txt" ] && [ -f "$ROOT/.rbx-studio/checkpoint.md" ] && [ "$STATE/last-turn.txt" -nt "$ROOT/.rbx-studio/checkpoint.md" ]; then
    echo "Note: work happened after the last checkpoint (state/last-turn.txt is newer)."
  fi
  latest=$(ls -1t "$ROOT/.rbx-studio/handoffs/"*.md 2>/dev/null | head -1)
  [ -n "$latest" ] && echo "Latest handoff: ${latest#"$ROOT"/}"
  src="$(cat "$RBX_HOME/source.txt" 2>/dev/null)"
  if [ -n "$src" ] && [ -f "$src/studio/rbx-studio/VERSION" ]; then
    sv="$(cat "$src/studio/rbx-studio/VERSION")"
    [ "$sv" != "$ver" ] && echo "Studio update available ($ver -> $sv): run install.ps1 -Update (or install.sh --update) in $src"
  fi
  exit 0 ;;

prompt)
  is_roblox 0 || exit 0
  p="$(json_get prompt | tr '[:upper:]' '[:lower:]')"
  [ -z "$p" ] && exit 0
  if printf '%s' "$p" | grep -qE "(don'?t|do not|never|no|not yet|stop)[[:space:]]+(to[[:space:]]+)?(push|ship|merge|open)"; then
    rm -f "$STATE/approval-$SESSION" 2>/dev/null; exit 0
  fi
  if printf '%s' "$p" | grep -qE "^[[:space:]]*/rbx-ship|approved?[,.!]?[[:space:]]+(to[[:space:]]+)?(push|ship|merge)|(ok|okay|yes|go)[,.!]?[[:space:]]+(ahead[[:space:]]+(and[[:space:]]+)?)?push|push it|ship it|you can push|go ahead and (push|ship|open the pr)|open the pr"; then
    ensure_state && date +%s > "$STATE/approval-$SESSION" && echo "[rbx-studio] Push/PR approval recorded for this session (2 h)."
  fi
  exit 0 ;;

pre-bash)
  case "$INPUT" in *'"tool_input"'*[Gg]it*|*'"tool_input"'*gh\ *) ;; *) exit 0 ;; esac
  is_roblox 0 || exit 0
  cmd="$(json_get command)"
  [ -z "$cmd" ] && exit 0
  segs="$(printf '%s\n' "$cmd" | sed -E 's/(&&|\|\||;|\|)/\n/g')"
  need_approval=""; is_commit=""; commit_all=""
  while IFS= read -r s; do
    s="$(printf '%s' "$s" | sed -E 's/^[[:space:]]+//; s/^([A-Za-z_][A-Za-z0-9_]*=[^ ]* +)*//; s/^(command|exec|&)[[:space:]]+//')"
    if printf '%s' "$s" | grep -qE '^"?([^ ]*[/\\])?git(\.exe)?"?([[:space:]]+-[Cc][[:space:]]+[^ ]+|[[:space:]]+--[a-z-]+(=[^ ]+)?)*[[:space:]]+push([[:space:]]|$)'; then
      printf '%s' "$s" | grep -qE -- '--dry-run|(^|[[:space:]])-n([[:space:]]|$)' || need_approval="git push"
    elif printf '%s' "$s" | grep -qE '^gh(\.exe)?[[:space:]]+pr[[:space:]]+(create|merge)'; then
      need_approval="gh pr"
    elif printf '%s' "$s" | grep -qE '^"?([^ ]*[/\\])?git(\.exe)?"?.*[[:space:]]merge([[:space:]]|$)'; then
      br="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null)"; mb="$(yaml_val main_branch)"
      [ "$br" = "${mb:-main}" ] || [ "$br" = "master" ] && need_approval="git merge into $br"
    elif printf '%s' "$s" | grep -qE '^"?([^ ]*[/\\])?git(\.exe)?"?([[:space:]]+-[Cc][[:space:]]+[^ ]+)*[[:space:]]+commit([[:space:]]|$)'; then
      is_commit=1
      printf '%s' "$s" | grep -qE -- '(^|[[:space:]])-[a-zA-Z]*a|--all' && commit_all=1
    fi
  done <<< "$segs"
  if [ -n "$need_approval" ]; then
    tok="$STATE/approval-$SESSION"
    if [ -n "$SESSION" ] && [ -f "$tok" ] && [ "$(file_age_s "$tok")" -lt 7200 ]; then exit 0; fi
    echo "BLOCKED by rbx-studio: '$need_approval' needs the developer's approval this session. Stop and ask. They approve by typing 'approved, push' or running /rbx-ship. Local commits are fine." >&2
    exit 2
  fi
  if [ -n "$is_commit" ]; then
    files="$(git -C "$ROOT" diff --cached --name-only --diff-filter=ACM 2>/dev/null)"
    [ -n "$commit_all" ] && files="$files
$(git -C "$ROOT" diff --name-only --diff-filter=ACM 2>/dev/null)"
    report=""
    tmp="$(mktemp 2>/dev/null || echo "/tmp/rbx-$$")"
    while IFS= read -r f; do
      case "$f" in *.lua|*.luau) ;; *) continue ;; esac
      git -C "$ROOT" show ":$f" > "$tmp" 2>/dev/null || cp "$ROOT/$f" "$tmp" 2>/dev/null || continue
      for ln in $(guard_scan "$tmp"); do report="$report
  $f:$ln"; done
    done <<< "$(printf '%s\n' "$files" | sort -u)"
    rm -f "$tmp"
    if [ -n "$report" ]; then
      echo "BLOCKED by rbx-studio: unguarded remote handlers in files being committed:$report
Validate every client arg (typeof, range, ownership, rate limit) before use. If validated elsewhere, add '-- rbx:guarded' on the line above the Connect. Rule: rbx-remotes." >&2
      exit 2
    fi
  fi
  exit 0 ;;

post-write)
  is_roblox 0 || exit 0
  tool="$(json_get tool_name)"
  fp="$(json_get file_path)"
  msgs=""; target=""; label=""; is_mcp=""
  case "$tool" in
    mcp__*multi_edit*)
      is_mcp=1; label="$fp"
      target="$(mktemp 2>/dev/null || echo "/tmp/rbx-$$")"
      printf '%s' "$INPUT" | LC_ALL=C grep -oE '"new_string"[[:space:]]*:[[:space:]]*"(\\.|[^"\\])*"' | LC_ALL=C sed -E 's/^"new_string"[[:space:]]*:[[:space:]]*"//; s/"$//' | json_unescape > "$target" ;;
    *)
      case "$fp" in *.lua|*.luau) ;; *) exit 0 ;; esac
      target="$(to_unix_path "$fp")"; label="${target#"$ROOT"/}"
      [ -f "$target" ] || exit 0 ;;
  esac
  if [ -z "$is_mcp" ]; then
    if command -v stylua >/dev/null 2>&1 && { [ -f "$ROOT/stylua.toml" ] || [ -f "$ROOT/.stylua.toml" ]; }; then
      (cd "$ROOT" && stylua --check "$target" >/dev/null 2>&1) || msgs="$msgs
- StyLua: $label is not formatted. Run: stylua \"$label\""
    fi
    if command -v selene >/dev/null 2>&1 && [ -f "$ROOT/selene.toml" ]; then
      out="$(cd "$ROOT" && selene --display-style Quiet "$target" 2>&1 | grep -E 'error|warning' | head -15)"
      [ -n "$out" ] && msgs="$msgs
- Selene:
$out"
    fi
  fi
  if grep -qE 'GetDataStore|GetOrderedDataStore|DataStoreService' "$target" 2>/dev/null; then
    dm="$(yaml_val data_module)"
    if [ -n "$dm" ]; then
      dmp="$(printf '%s' "$dm" | tr '\\' '/')"; dmd="$(printf '%s' "$dm" | tr '/\\' '..')"
      case "$label" in *"$dmp"*|*"$dmd"*) ;; *) msgs="$msgs
- Data: DataStore access in $label, outside the data module ($dm). Route reads/writes through the data module (rule rbx-data)." ;; esac
    else
      printf '%s' "$label" | grep -qE '[Dd]ata|[Pp]rofile|[Ss]tore|[Ss]ave|[Pp]ersist|[Rr]eceipt' || msgs="$msgs
- Data: DataStore access in $label, which does not look like the data module. Keep DataStore calls in one module (rule rbx-data). Set paths.data_module in .rbx-studio/project.yaml."
    fi
  fi
  lines="$(guard_scan "$target" | tr '\n' ' ')"
  [ -n "$lines" ] && msgs="$msgs
- Remotes: unguarded handler(s) in $label at line(s) $lines. Validate client args before use (rule rbx-remotes). Commits will be blocked until fixed."
  [ -n "$is_mcp" ] && rm -f "$target"
  [ -z "$msgs" ] && exit 0
  ctx="$(printf '[rbx-studio] Checks on %s:%s' "$label" "$msgs" | json_escape)"
  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$ctx"
  exit 0 ;;

pre-compact)
  is_roblox 0 || exit 0
  ensure_state || exit 0
  {
    echo "# Auto checkpoint (PreCompact) $(date '+%Y-%m-%d %H:%M:%S')"
    echo "session: $SESSION"
    echo "branch: $(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null)"
    echo "## git status"; git -C "$ROOT" status --short 2>/dev/null | head -40
    echo "## last commits"; git -C "$ROOT" log --oneline -5 2>/dev/null
    [ -f "$ROOT/.rbx-studio/checkpoint.md" ] && echo "## manual checkpoint is $(( $(file_age_s "$ROOT/.rbx-studio/checkpoint.md") / 60 )) min old"
  } > "$STATE/auto-checkpoint.md"
  exit 0 ;;

stop)
  is_roblox 0 || exit 0
  ensure_state || exit 0
  {
    echo "time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "session: $SESSION"
    echo "branch: $(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null)"
    echo "changed:"; git -C "$ROOT" status --short 2>/dev/null | head -50
  } > "$STATE/last-turn.txt"
  exit 0 ;;

notify)
  is_roblox 0 || exit 0
  msg="$(json_get message)"; [ -z "$msg" ] && msg="Claude Code needs your attention"
  safe="$(printf '%s' "$msg" | head -c 200 | sed "s/'/''/g")"
  if command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile -NonInteractive -WindowStyle Hidden -Command "
      Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing
      \$n = New-Object System.Windows.Forms.NotifyIcon
      \$n.Icon = [System.Drawing.SystemIcons]::Information
      \$n.BalloonTipTitle = 'Claude Code (Roblox)'
      \$n.BalloonTipText = '$safe'
      \$n.Visible = \$true; \$n.ShowBalloonTip(5000); Start-Sleep -Seconds 6; \$n.Dispose()" >/dev/null 2>&1 &
  fi
  exit 0 ;;

*) exit 0 ;;
esac
