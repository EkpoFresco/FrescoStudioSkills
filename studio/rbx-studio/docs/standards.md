# Standards: code and evidence

## Code (every story)
- Rules in `~/.claude/rules/rbx-*.md` load by path. Project conventions in `.rbx-studio/conventions.md` win where they differ.
- Checks that must run when configured: `stylua --check`, `selene`, `luau-lsp analyze --definitions:@roblox=<globalTypes.d.luau> --sourcemap sourcemap.json src`. luau-lsp does not download Roblox types on its own.
- Review verdicts (code-optimizer): `APPROVED`, `APPROVED WITH NOTES`, `CHANGES REQUIRED`, `NOT ASSESSED`. Severities: BLOCKER (exploitable, data or purchase loss, crash, per-player growing leak), MAJOR (measurable perf or correctness risk), MINOR, NIT.
- A story with an open BLOCKER does not close. No data means NOT ASSESSED, never a clean pass. Every scan states how many files it covered.

## Evidence per story type
| Story type | Evidence to close |
|---|---|
| Logic (pure module) | test or Lune run output at rigor standard+, else a worked example in the story |
| Server / remotes | code-optimizer review + guard scan clean; exploit-tester note at rigor full |
| Data / purchases | data-audit checklist lines for the touched paths |
| UI / visual | look check `OBSERVED` with an evidence path |
| Performance | before/after table: same place, same player count, warmup, N samples, median |

## Optimization evidence table
| Metric | Before | After | How measured | N |
|---|---|---|---|---|

Accepted sources: MicroProfiler (MCP skill `rbx-perf-profiling`), Script Profiler %, Developer Console memory (LuaHeap, Instances, GraphicsTexture), Stats network KB/s, SceneAnalysisService (MCP skill `rbx-scene-analysis`), Lune `os.clock` benchmark for pure modules.
