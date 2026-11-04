# Changelog

## 2.0.0 (2026-11-03): Roblox fork
- Rebuilt Claude Code Game Studios v1.2.0 for Roblox only. Godot, Unity, Unreal removed.
- 49 agents -> 18 Roblox agents; 74 skills -> 28 `rbx-*` skills (+2 maintainer skills in this repo).
- Global install (`install.ps1` / `install.sh`) into `~/.claude/` with manifest, collision backups, exact uninstall.
- Hooks: one dispatcher per shell (Git Bash, PowerShell), silent outside Roblox folders. Push and PR gate from the developer's own approval, commit block on unguarded remotes, Luau checks on write (including Studio MCP `multi_edit`), auto state for resume, Windows toast.
- Research library `docs/roblox/` (43 files, sourced, dated 2026-11-03) with OPEN_QUESTIONS.
- Static linter, catalog generator, hook and installer test suites.
Upstream history before this fork: `git log upstream/main`.
