# RUN_STATE

Resume with: "read RUN_STATE.md and continue". Spec: `ROBLOX_STUDIO_BUILD_PROMPT.md`.

## Current phase
Phase 1 (audit) + Phase 2 (research) in parallel.

## Done
- Repo fetched from upstream v1.2.0 (05ad7c8). Push disabled (see DECISIONS D-002).
- Env check: git, gh, node 24, python 3.11, rokit (rojo, selene, stylua, luau-lsp, lune, wally), Roblox Studio installed, built-in Studio MCP at `%LOCALAPPDATA%\Roblox\mcp.bat`. Studio MCP NOT wired into this Claude session (no mcpServers).
- `docs/roblox/studio-mcp-tools.md` generated from local Studio MCP cache (27 tools, 7 built-in MCP skills).

## In progress
- Research subagents writing `docs/roblox/*` (see list below).
- Phase 1 audit: `docs/audit/REPO_AUDIT.md`.

## Research files expected
studio-reference.md, discovery-algorithm.md, discovery-playbook.md, market-data.md, ux-standards.md, genres/*.md, implementation.md, implementation-data.md, policy.md, art-pipeline.md, code-quality.md, docs/install-research.md (Claude Code loading model).

## Next 3 steps
1. Finish REPO_AUDIT.md, commit.
2. Collect research, write OPEN_QUESTIONS.md, commit.
3. Write docs/audit/ROBLOX_STUDIO_DESIGN.md.

## Open decisions
- Distribution: plain `~/.claude` copy vs Claude Code plugin. Waiting on install research.
- Dogfood build path: drive StudioMCP.exe over stdio from a script vs nested `claude -p --mcp-config`. Needs Studio launched.
