# Checkpoint
Updated: 2026-11-04 (resumed) · Session: rbx-optimize top --max 3 · Branch: main · Last commit: 3bb48ac

## Goal
/rbx-optimize: TD-001, then Economy.bulkCost, then next debt item. Measure before/after, checkpoint after each.

## Phase
Optimize, target 2 of 3.

## Done
- Economy.bulkCost: one pow, then running multiply, floor per level. 70.33 -> 8.59 ms / 20000 calls (8.2x). Matches sum of costOf exactly below 1e14 (spec added, 18 pass). Float drift possible above ~4e14 totals.
- TD-001 done (3bb48ac): State pushed on change plus 1 Hz heartbeat for players with income; client interpolates with State.income. Idle 9 -> 0 pkts/s, with income 9 -> ~1 pkt/s (Studio MCP client count, N=3 x 10 s).
- Config.HeartbeatSeconds added; Remotes.State has `income`.

## In progress
- Third target from debt.md (TD-007 or TD-008): not started.

## Next 3
1. Pick the third target from debt.md (TD-007 or TD-008), measure baseline.
2. Write .rbx-studio/reports/optimize-2026-11-04.md and update conventions.md.
3. Save the Studio place after syncing Data and Economy copies.

## Open decisions
- Studio place was stale vs Rojo files (no `allow`). I pushed Config, Remotes, Game, Hud into the open place via execute_luau. Data and Economy in Studio are still the old copies. Place not saved.

## Files touched since last commit
- none (Studio-only: ReplicatedStorage.Shared.Config, Shared.Remotes, ServerScriptService.Server.Game, StarterPlayer.StarterPlayerScripts.Client.Hud; unsaved)
