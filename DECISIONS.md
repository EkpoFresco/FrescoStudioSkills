# Decisions Log

One line each: decision, then why. Newest at the bottom. Format: `D-NNN (phase) decision. Why.`

- D-001 (setup) Built the fork in the existing `Roblox Workfloq` folder via `git init` + fetch of upstream `main` (05ad7c8, v1.2.0), since the folder already held the prompt file. Why: avoids a nested clone; same result as a fresh clone.
- D-002 (setup) Renamed remote `origin` to `upstream` and set its push URL to `DISABLED-push-requires-approval`. Why: makes an accidental push impossible until the owner approves and adds their own remote.
- D-003 (research) Used the local Studio MCP tool cache (`%LOCALAPPDATA%\Roblox\StudioMCP\tools-cache.json`) as the primary source for MCP tools, dumped verbatim to `docs/roblox/studio-mcp-tools.md`. Why: it is exactly what this machine's Studio exposes, more reliable than web pages.
- D-004 (research) Ran Phase 2 as parallel research subagents, one output file each, while Phase 1 audit ran in the main session. Why: research is the longest phase; the prompt asks for parallel subagents.
- D-005 (research) Split implementation research into `implementation.md` (Luau, architecture, networking, exploits, performance) and `implementation-data.md` (DataStores, monetization APIs, analytics). Why: agents load only the half they need; keeps context small.
