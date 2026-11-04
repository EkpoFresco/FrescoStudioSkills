# Changelog

## 2.1.0 (2026-11-04): token pass
- `/rbx-map` + `tools/rbx-map.js` (and `rbx-map.luau` for MCP-only games): Roblox-aware project graph (scripts, requires, remotes fired -> handled, DataStore calls, purchases, hot paths). Built with zero model tokens, auto-refreshed at session start, read first by every code skill. Graphify supported as an optional extra.
- `tools/lib.js`: read the research library by TL;DR and section instead of whole files.
- 17 user-only skills hidden from the model (`disable-model-invocation`), including `/rbx-ship`; all still typeable. Descriptions cut to lint-enforced budgets.
- Every agent carries token rules; 4 tool-heavy agents on Sonnet.
- `/rbx-concept brainstorm <theme>`: 5 scored concepts, pick one, then the normal brief.
- Measured: every-session listing 3,352 -> 857 tok; session start -4,165 tok; `/rbx-data-audit` on identical code: tool reads -79%, cost $0.302 -> $0.215, same findings.
- `tools/token-budget.js` to track it.

## 2.0.0 (2026-11-03): Roblox fork
- Rebuilt Claude Code Game Studios v1.2.0 for Roblox only. All other engine sets removed.
- 49 agents -> 18 Roblox agents; 74 skills -> 28 `rbx-*` skills (+2 maintainer skills in this repo).
- Global install (`install.ps1` / `install.sh`) into `~/.claude/` with manifest, collision backups, exact uninstall.
- Hooks: one dispatcher per shell (Git Bash, PowerShell), silent outside Roblox folders. Push and PR gate from the developer's own approval, commit block on unguarded remotes, Luau checks on write (including Studio MCP `multi_edit`), auto state for resume, Windows toast.
- Research library `docs/roblox/` (43 files, sourced, dated 2026-11-03) with OPEN_QUESTIONS.
- Static linter, catalog generator, hook and installer test suites.
Upstream history before this fork: `git log upstream/main`.
