#!/usr/bin/env bash
# Runs the same fixtures through rbx-hook.sh (Git Bash) and rbx-hook.ps1 (PowerShell).
# Usage: bash tools/test-hooks.sh [bash|ps|both]   (default both)
# Exit 0 = all pass. Creates throwaway fixtures under a temp dir; touches nothing else.
set -u
MODE="${1:-both}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SH="$REPO/studio/rbx-studio/hooks/rbx-hook.sh"
PS1="$REPO/studio/rbx-studio/hooks/rbx-hook.ps1"
unset CLAUDE_PROJECT_DIR
export RBX_GLOBAL_STATE="$(mktemp -d 2>/dev/null || echo /tmp/rbx-gstate-$$)"
PSH="${RBX_PSH:-$(command -v pwsh || command -v powershell.exe)}"

T="$(mktemp -d 2>/dev/null || echo "/tmp/rbx-hooktest-$$")"; mkdir -p "$T"
GAME="$T/game"; NON="$T/plain"
mkdir -p "$GAME/src/server" "$GAME/src/client" "$NON"
echo '{"name":"game","tree":{"$className":"DataModel"}}' > "$GAME/default.project.json"
cat > "$GAME/src/server/Shop.server.luau" <<'EOF'
local Remotes = game:GetService("ReplicatedStorage").Remotes
Remotes.Buy.OnServerEvent:Connect(function(player, itemId, amount)
	giveItem(player, itemId, amount)
end)
EOF
cat > "$GAME/src/server/Good.server.luau" <<'EOF'
local Remotes = game:GetService("ReplicatedStorage").Remotes
Remotes.Sell.OnServerEvent:Connect(function(player, itemId)
	if typeof(itemId) ~= "string" then return end
	sell(player, itemId)
end)
Remotes.Ping.OnServerEvent:Connect(function(player)
	pong(player)
end)
EOF
cat > "$GAME/src/client/Ui.client.luau" <<'EOF'
local DataStoreService = game:GetService("DataStoreService")
EOF
echo "hello" > "$NON/README.md"
( cd "$GAME" && git init -q && git config user.email t@t && git config user.name t && git add src/server/Good.server.luau )
( cd "$NON" && git init -q )

winpath() { if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else printf '%s' "$1"; fi; }
jpath() { winpath "$1" | sed 's/\\/\\\\/g'; }

PASS=0; FAIL=0
run() { # run <shell> <event> <json>  -> sets OUT, RC
  if [ "$1" = bash ]; then OUT="$(printf '%s' "$3" | bash "$SH" "$2" 2>&1)"; RC=$?
  else OUT="$(printf '%s' "$3" | "$PSH" -NoProfile -ExecutionPolicy Bypass -File "$(winpath "$PS1")" "$2" 2>&1)"; RC=$?; fi
}
check() { # check <name> <cond-result 0/1> <detail>
  if [ "$2" = 0 ]; then PASS=$((PASS+1)); echo "  ok   $1"; else FAIL=$((FAIL+1)); echo "  FAIL $1 :: rc=$RC out=$(printf '%s' "$OUT" | head -c 300)"; fi
}
J() { # J <dir> <extra-json-fields>
  printf '{"session_id":"sess1","cwd":"%s","hook_event_name":"x"%s}' "$(jpath "$1")" "$2"
}
bashcmd() { printf ',"tool_name":"Bash","tool_input":{"command":"%s"}' "$1"; }

suite() {
  local sh="$1"; echo "== $sh"
  rm -rf "$GAME/.rbx-studio" "$NON/.rbx-studio"
  run "$sh" session-start "$(J "$NON" '')"; check "plain: session-start silent" "$([ -z "$OUT" ] && [ $RC = 0 ]; echo $?)"
  run "$sh" pre-bash "$(J "$NON" "$(bashcmd 'git push origin main')")"; check "plain: push not gated" "$([ $RC = 0 ]; echo $?)"
  run "$sh" stop "$(J "$NON" '')"; check "plain: stop writes nothing" "$([ ! -e "$NON/.rbx-studio" ]; echo $?)"
  run "$sh" post-write "$(J "$NON" ',"tool_name":"Write","tool_input":{"file_path":"x.luau"}')"; check "plain: post-write silent" "$([ -z "$OUT" ]; echo $?)"
  run "$sh" session-start "$(J "$GAME" '')"; check "game: session-start detects" "$(printf '%s' "$OUT" | grep -q 'Roblox project detected'; echo $?)"
  run "$sh" pre-bash "$(J "$GAME" "$(bashcmd 'git push origin main')")"; check "game: push blocked without approval" "$([ $RC = 2 ]; echo $?)"
  run "$sh" pre-bash "$(J "$GAME" "$(bashcmd 'git status && git push')")"; check "game: chained push blocked" "$([ $RC = 2 ]; echo $?)"
  run "$sh" pre-bash "$(J "$GAME" "$(bashcmd 'gh pr create --fill')")"; check "game: gh pr create blocked" "$([ $RC = 2 ]; echo $?)"
  run "$sh" pre-bash "$(J "$GAME" "$(bashcmd 'git push --dry-run')")"; check "game: dry-run allowed" "$([ $RC = 0 ]; echo $?)"
  run "$sh" pre-bash "$(J "$GAME" "$(bashcmd 'git log --oneline')")"; check "game: other git allowed" "$([ $RC = 0 ]; echo $?)"
  run "$sh" prompt "$(J "$GAME" ',"prompt":"looks good. approved, push"')"; check "game: approval recorded" "$([ -f "$GAME/.rbx-studio/state/approval-sess1" ]; echo $?)"
  run "$sh" pre-bash "$(J "$GAME" "$(bashcmd 'git push origin main')")"; check "game: push allowed after approval" "$([ $RC = 0 ]; echo $?)"
  run "$sh" prompt "$(J "$GAME" ',"prompt":"wait, do not push yet"')"; check "game: negation revokes" "$([ ! -f "$GAME/.rbx-studio/state/approval-sess1" ]; echo $?)"
  run "$sh" prompt "$(J "$GAME" ',"prompt":"/rbx-ship"')"; check "game: /rbx-ship approves" "$([ -f "$GAME/.rbx-studio/state/approval-sess1" ]; echo $?)"
  rm -f "$GAME/.rbx-studio/state/approval-sess1"
  run "$sh" prompt "$(J "$GAME" ',"prompt":"push the shop changes when tests pass"')"; check "game: vague mention does not approve" "$([ ! -f "$GAME/.rbx-studio/state/approval-sess1" ]; echo $?)"
  run "$sh" pre-bash "$(J "$GAME" "$(bashcmd 'git commit -m ok')")"; check "game: commit of guarded file allowed" "$([ $RC = 0 ]; echo $?)"
  ( cd "$GAME" && git add src/server/Shop.server.luau )
  run "$sh" pre-bash "$(J "$GAME" "$(bashcmd 'git commit -m shop')")"; check "game: commit with unguarded remote blocked" "$([ $RC = 2 ] && printf '%s' "$OUT" | grep -q 'Shop.server.luau:2'; echo $?)"
  ( cd "$GAME" && git reset -q src/server/Shop.server.luau )
  run "$sh" post-write "$(J "$GAME" ",\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$(jpath "$GAME/src/server/Shop.server.luau")\"}")"
  check "game: post-write flags unguarded" "$(printf '%s' "$OUT" | grep -q 'Remotes: unguarded' && printf '%s' "$OUT" | grep -q hookSpecificOutput; echo $?)"
  run "$sh" post-write "$(J "$GAME" ",\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$(jpath "$GAME/src/client/Ui.client.luau")\"}")"
  check "game: post-write flags DataStore outside data module" "$(printf '%s' "$OUT" | grep -q 'Data: DataStore'; echo $?)"
  run "$sh" post-write "$(J "$GAME" ",\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$(jpath "$GAME/src/server/Good.server.luau")\"}")"
  check "game: post-write silent on clean file" "$([ -z "$OUT" ]; echo $?)"
  run "$sh" post-write "$(J "$GAME" ',"tool_name":"mcp__roblox__multi_edit","tool_input":{"file_path":"ServerScriptService.Shop","edits":[{"old_string":"a","new_string":"R.OnServerEvent:Connect(function(player, n)\n\tgive(player, n)\nend)"}]}')"
  check "game: MCP multi_edit flags unguarded" "$(printf '%s' "$OUT" | grep -q 'Remotes: unguarded'; echo $?)"
  run "$sh" stop "$(J "$GAME" '')"; check "game: stop writes last-turn" "$([ -f "$GAME/.rbx-studio/state/last-turn.txt" ]; echo $?)"
  run "$sh" pre-compact "$(J "$GAME" '')"; check "game: pre-compact auto checkpoint" "$([ -f "$GAME/.rbx-studio/state/auto-checkpoint.md" ]; echo $?)"
  check "game: .rbx-studio/.gitignore ignores state" "$(grep -q 'state/' "$GAME/.rbx-studio/.gitignore"; echo $?)"
  if command -v node >/dev/null 2>&1; then
    rm -f "$GAME/.rbx-studio/map.md" "$GAME/.rbx-studio/map.json"
    run "$sh" session-start "$(J "$GAME" '')"
    check "game: session-start builds the project map" "$(grep -q 'Buy: ' "$GAME/.rbx-studio/map.md" 2>/dev/null && printf '%s' "$OUT" | grep -q 'Map: refreshed'; echo $?)"
    run "$sh" session-start "$(J "$GAME" '')"
    check "game: map reported current on next start" "$(printf '%s' "$OUT" | grep -q 'map.md is current'; echo $?)"
  fi
  # session started in the PARENT folder (not a game): gate must follow cd / -C into the game
  rm -f "$RBX_GLOBAL_STATE"/approval-* 2>/dev/null
  run "$sh" pre-bash "$(printf '{"session_id":"par1","cwd":"%s","tool_name":"Bash","tool_input":{"command":"cd game \u0026\u0026 git push origin main"}}' "$(jpath "$T")")"; check "parent session: cd game && git push blocked" "$([ $RC = 2 ]; echo $?)"
  run "$sh" pre-bash "$(printf '{"session_id":"par1","cwd":"%s","tool_name":"Bash","tool_input":{"command":"git -C game push"}}' "$(jpath "$T")")"; check "parent session: git -C game push blocked" "$([ $RC = 2 ]; echo $?)"
  run "$sh" pre-bash "$(printf '{"session_id":"par1","cwd":"%s","tool_name":"Bash","tool_input":{"command":"cd plain \u0026\u0026 git push"}}' "$(jpath "$T")")"; check "parent session: push in a non-game folder not gated" "$([ $RC = 0 ]; echo $?)"
  run "$sh" prompt "$(printf '{"session_id":"par1","cwd":"%s","prompt":"approved, push"}' "$(jpath "$T")")"; check "parent session: approval recorded silently" "$([ -z "$OUT" ] && ls "$RBX_GLOBAL_STATE"/approval-par1 >/dev/null 2>&1; echo $?)"
  run "$sh" pre-bash "$(printf '{"session_id":"par1","cwd":"%s","tool_name":"Bash","tool_input":{"command":"cd game \u0026\u0026 git push origin main"}}' "$(jpath "$T")")"; check "parent session: push allowed after approval" "$([ $RC = 0 ]; echo $?)"
  run "$sh" post-write "$(printf '{"session_id":"par1","cwd":"%s","tool_name":"Write","tool_input":{"file_path":"%s"}}' "$(jpath "$T")" "$(jpath "$GAME/src/server/Shop.server.luau")")"; check "parent session: game file edit still checked" "$(printf '%s' "$OUT" | grep -q 'Remotes: unguarded'; echo $?)"
  extra="$(cd "$GAME" && git status --porcelain --ignored | grep -v -E 'src/|default.project.json|\.rbx-studio/' )"
  check "game: nothing written outside .rbx-studio" "$([ -z "$extra" ]; echo $?)"
}

case "$MODE" in bash) suite bash ;; ps) suite ps ;; *) suite bash; [ -n "$PSH" ] && suite ps ;; esac
rm -rf "$T"
echo "RESULT: $PASS passed, $FAIL failed"
[ "$FAIL" = 0 ]
