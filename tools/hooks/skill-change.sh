#!/usr/bin/env bash
# Maintainer hook for THIS repo (not installed globally): after a Write/Edit to the studio
# payload, lint just that skill or agent and feed the result back to Claude.
INPUT="$(cat)"
fp="$(printf '%s' "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*:[[:space:]]*"//; s/"$//; s/\\\\/\//g')"
case "$fp" in
  *studio/skills/*/SKILL.md) name="$(basename "$(dirname "$fp")")" ;;
  *studio/agents/*.md) name="$(basename "$fp" .md)" ;;
  *) exit 0 ;;
esac
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
out="$(node tools/studio-lint.js "$name" 2>&1 | sed -n '2p')"
case "$out" in
  *NON-COMPLIANT*|*WARNINGS*) printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"studio-lint %s: %s. Run /skill-test static %s."}}\n' "$name" "$(printf '%s' "$out" | sed 's/"/\\"/g' | tr -s ' ')" "$name" ;;
esac
exit 0
