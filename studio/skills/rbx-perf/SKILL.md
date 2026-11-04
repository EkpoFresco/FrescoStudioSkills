---
name: rbx-perf
description: "Roblox: measured mobile performance review (MicroProfiler, memory, instances, network) with ranked fixes."
argument-hint: "[full | cpu | memory | network | scene]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Agent
---

# /rbx-perf

## 0. Relevance check
No playable build and no scripts: `SKIPPED: nothing to measure`. No Studio MCP: run only the static half (step 3) and mark measured lines NOT ASSESSED.

## 1. Context
`{{RBX_HOME}}/library/roblox/implementation.md` (Performance: 16.67 ms frame at 60 FPS, about 65% of players on Android, many with 2-4 GB RAM), `{{RBX_HOME}}/library/roblox/code-quality.md` (measurement protocol), `{{RBX_HOME}}/library/roblox/art-pipeline.md` (texture and mesh budgets).

## 2. Measure (Studio MCP)
Delegate to `code-optimizer`:
- Play, warm up 30 s, then sample 3 times: frame time and top labels via MCP skill `rbx-perf-profiling` (`skill` tool, LibMP), memory via `execute_luau` (`Stats`, `collectgarbage("count")`), instance and part counts, network in/out.
- Scene: MCP skill `rbx-scene-analysis` (rendering, memory, unparented instances, asset sizes).
- Network: MCP skill `rbx-network-simulator` to add latency or loss and confirm remotes and UI tolerate it.
- Phone profile: repeat the frame sample with the Device Simulator on a low-end phone.
Record median of 3 per metric with the method.

## 3. Static scan
Start from the Per-frame connections and Infinite loops sections of `.rbx-studio/map.md`. Grep or `script_grep` for per-frame work (`Heartbeat`, `RenderStepped`, `PreSimulation`), `FindFirstChild` or `GetChildren` in loops, `while true do` without yields, unbounded tables keyed by player, `Touched` spam, unanchored decoration parts.

## 4. Rank
Each finding: metric impact (measured or estimated with label), fix, effort. Top 3 go to `/rbx-optimize`. Write `.rbx-studio/reports/perf-<date>.md` with the numbers table.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- frame: <ms> desktop / <ms> phone profile; memory <MB>; instances <n>; net <KB/s>
- top issue: <label or file:line> costing <ms or MB>
YOU DO
1. <exact step>
RISKS
- <only if real>
NEXT
- /rbx-optimize
```
