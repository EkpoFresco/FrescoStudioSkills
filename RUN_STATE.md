# RUN_STATE

Resume with: "read RUN_STATE.md and continue". Spec: `ROBLOX_STUDIO_BUILD_PROMPT.md`. Design: `docs/audit/ROBLOX_STUDIO_DESIGN.md` (the build spec).

## Current phase
Phase 4 (build).

## Done
- Phase 1: `docs/audit/REPO_AUDIT.md`.
- Phase 2: `docs/roblox/` (43 files incl. 32 genres, OPEN_QUESTIONS.md), `docs/install-research.md`. Note: QPTR replaced by PTR + bounce (D-014).
- Phase 3: `docs/audit/ROBLOX_STUDIO_DESIGN.md`, DECISIONS D-006..D-016.
- Phase 4 so far: hooks `studio/rbx-studio/hooks/rbx-hook.{sh,ps1}` (25/25 tests in Git Bash, pwsh 7, PS 5.1 via `tools/test-hooks.sh`), 7 rules `studio/rules/`, studio docs, 17 templates, CONTEXT.md, 18 agents `studio/agents/`.

## In progress
- 28 skills in `studio/skills/rbx-*/SKILL.md`.

## Next 3 steps
1. Skills, then installer (`install.ps1`, `install.sh`) + `settings.hooks.json` + tools (capture-studio.ps1, studio-lint.js, dump-mcp-manifest.js).
2. Clean old `.claude/` (keep rewritten skill-test/skill-improve), rewrite studio-tests, CLAUDE.md, README, docs/install.md; grep out Godot/Unity/Unreal.
3. Phase 5: lint, hook tests, sandbox install test, dogfood game via Studio MCP (connect StudioMCP.exe), survival test.

## Open decisions
- Dogfood MCP path: nested `claude -p --mcp-config` with mcp.bat vs a Node stdio MCP client script. Needs Studio running.
