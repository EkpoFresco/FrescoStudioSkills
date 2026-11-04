#!/usr/bin/env bash
# rbx-studio installer, Bash entry point (Git Bash on Windows, macOS, Linux).
#   ./install.sh                 install or reinstall into ~/.claude (or $CLAUDE_CONFIG_DIR)
#   ./install.sh --update        git pull --ff-only, then reinstall
#   ./install.sh --uninstall     remove everything the installer added
#   ./install.sh --target DIR    sandbox config dir
#   ./install.sh --dry-run       show what would change
#   ./install.sh --shell bash|powershell
# One implementation: this script runs install.ps1 with Windows PowerShell (Windows) or
# PowerShell 7 `pwsh` (macOS/Linux: brew install powershell / apt install powershell).
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --update) ARGS+=(-Update) ;;
    --uninstall) ARGS+=(-Uninstall) ;;
    --dry-run) ARGS+=(-DryRun) ;;
    --target) shift; t="$1"; command -v cygpath >/dev/null 2>&1 && t="$(cygpath -w "$t")"; ARGS+=(-Target "$t") ;;
    --shell) shift; ARGS+=(-Shell "$1") ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done
PS1="$REPO/install.ps1"
command -v cygpath >/dev/null 2>&1 && PS1="$(cygpath -w "$PS1")"
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    if command -v pwsh >/dev/null 2>&1; then PSH=pwsh; else PSH=powershell.exe; fi ;;
  *)
    if ! command -v pwsh >/dev/null 2>&1; then
      echo "rbx-studio needs PowerShell 7 (pwsh) to install on this OS: brew install powershell (macOS) or see https://aka.ms/powershell" >&2
      exit 1
    fi
    PSH=pwsh ;;
esac
exec "$PSH" -NoProfile -ExecutionPolicy Bypass -File "$PS1" "${ARGS[@]}"
