# RUN_STATE

Resume with: "read RUN_STATE.md and continue". Spec: `ROBLOX_STUDIO_BUILD_PROMPT.md`. Design: `docs/audit/ROBLOX_STUDIO_DESIGN.md` (the build spec).

## Current phase
Phase 5 (test). Phase 4 build complete.

## Done
- Phase 1: `docs/audit/REPO_AUDIT.md`.
- Phase 2: `docs/roblox/` (43 files incl. 32 genres, OPEN_QUESTIONS.md), `docs/install-research.md`. Note: QPTR replaced by PTR + bounce (D-014).
- Phase 3: `docs/audit/ROBLOX_STUDIO_DESIGN.md`, DECISIONS D-006..D-016.
- Phase 4: installer + tests (13/13 pwsh 7 and PS 5.1), studio-lint 79/79, 46 specs, catalog 0 problems, upstream payload removed, docs. Earlier: hooks `studio/rbx-studio/hooks/rbx-hook.{sh,ps1}` (25/25 tests in Git Bash, pwsh 7, PS 5.1 via `tools/test-hooks.sh`), 7 rules `studio/rules/`, studio docs, 17 templates, CONTEXT.md, 18 agents `studio/agents/`.

## In progress
- Dogfood: `dogfood/brainrot-miner/` (Rojo project, Lune tests 14/14). Studio open on `build/brainrot-miner.rbxl`, MCP reachable via `node studio/rbx-studio/tools/mcp-call.js`.
- Next: real install to ~/.claude, nested `claude -p` runs of /rbx-start etc. with `--mcp-config`.

## Next 3 steps
1. Dogfood: start -> concept -> loop -> first-60 -> push code to Studio via MCP -> playtest + screenshots -> review/optimize with before/after -> monetize/remote/data audits -> telemetry.
2. Team sim: /rbx-handoff then fresh `claude -p` /rbx-pickup. Survival: kill a session mid-task, /rbx-resume.
3. Global install test (dogfood copy footprint, non-Roblox folder silent), uninstall, final report.

## Open decisions
- Dogfood MCP path: nested `claude -p --mcp-config` with mcp.bat vs a Node stdio MCP client script. Needs Studio running.
