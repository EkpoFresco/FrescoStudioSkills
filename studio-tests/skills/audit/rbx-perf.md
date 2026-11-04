# Skill Spec: /rbx-perf
Category: audit · Source: `studio/skills/rbx-perf/SKILL.md`

## Summary
Mobile performance review with real numbers. `code-optimizer` plays, warms up 30 s, samples 3 times (frame time via MCP skill `rbx-perf-profiling`, memory via `execute_luau`, instances, network), runs `rbx-scene-analysis`, and repeats the frame sample on a low-end phone in the Device Simulator. A static scan finds per-frame and loop hazards. Findings are ranked by impact; top 3 go to `/rbx-optimize`. Writes `.rbx-studio/reports/perf-<date>.md`. Changes no code.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: nothing to measure`; no MCP runs only the static half and marks measured lines NOT ASSESSED
- [ ] Budgets from `implementation.md`: 16.67 ms frame at 60 FPS, about 65% Android, 2-4 GB RAM
- [ ] Median of 3 per metric with the method recorded
- [ ] Static scan covers `Heartbeat`, `RenderStepped`, `PreSimulation`, `FindFirstChild`/`GetChildren` in loops, `while true do` without yields, per-player tables, `Touched` spam, unanchored decor
- [ ] Report DONE line shows desktop and phone ms, memory MB, instances, KB/s

## Fixture Defaults
Template project.yaml (`rigor: minimal`, `toolchain: rojo`, `genre: tycoon`), Studio MCP connected, git repo with one commit.

## Case 1: Happy path - tycoon dropper lag
**Fixture**: `src/server/Droppers.server.luau:30` spawns a new Part on every `Heartbeat` per dropper and never destroys them; 40 droppers in `Workspace.Plots`.
**Expected**: 1. Measure (3 samples, desktop and phone). 2. Scene analysis. 3. Static scan. 4. Rank and save.
**Assertions**:
- [ ] DONE frame line has both desktop and phone ms (e.g. 9.8 ms / 21.4 ms) and the phone value is judged against 16.67 ms
- [ ] Top issue is `Droppers.server.luau:30` with ms or instance growth labeled measured or estimated
- [ ] Report has a numbers table with method and N=3
- [ ] No file under `src/` changed

## Case 2: Relevance skip - nothing to measure
**Fixture**: Empty baseplate place; no scripts in Studio or `src/`.
**Assertions**:
- [ ] Prints `SKIPPED: nothing to measure` and writes nothing

## Case 3: Edge - no Studio MCP
**Fixture**: Same code as Case 1; MCP tools missing.
**Assertions**:
- [ ] Says MCP is missing once; runs the static scan only
- [ ] Frame, memory, instance, and network lines are NOT ASSESSED, not guessed
- [ ] The dropper finding's impact is labeled estimated; report still saved

## Protocol Compliance
- [ ] Every claim has a measured number or is NOT ASSESSED (A3)
- [ ] Writes only `.rbx-studio/reports/perf-<date>.md`
- [ ] Ends with NEXT `/rbx-optimize`
