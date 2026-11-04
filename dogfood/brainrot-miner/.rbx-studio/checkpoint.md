# Checkpoint
Updated: 2026-11-04 · Session: rbx-optimize top --max 3 · Branch: main · Last commit: 3bb48ac

## Goal
/rbx-optimize: TD-001, then Economy.bulkCost, then next debt item. Measure before/after, checkpoint after each.

## Phase
Optimize, target 2 of 3.

## Done
- TD-001 done (3bb48ac): State pushed on change plus 1 Hz heartbeat for players with income; client interpolates with State.income. Idle 9 -> 0 pkts/s, with income 9 -> ~1 pkt/s (Studio MCP client count, N=3 x 10 s).
- Config.HeartbeatSeconds added; Remotes.State has `income`.

## In progress
- Economy.bulkCost (src/shared/Economy.luau:21): baseline 70.33 ms / 20000 calls (owned=200,count=100), Lune median of 5. Next edit: closed-form geometric sum, keep per-level floor semantics or document the rounding change.

## Next 3
1. Replace bulkCost loop, rerun `lune run tests/economy.spec.luau`, commit.
2. Pick the third target from debt.md (TD-007 or TD-008).
3. Write .rbx-studio/reports/optimize-2026-11-04.md and update conventions.md.

## Open decisions
- Studio place was stale vs Rojo files (no `allow`). I pushed Config, Remotes, Game, Hud into the open place via execute_luau. Data and Economy in Studio are still the old copies. Place not saved.

## Files touched since last commit
- none (Studio-only: ReplicatedStorage.Shared.Config, Shared.Remotes, ServerScriptService.Server.Game, StarterPlayer.StarterPlayerScripts.Client.Hud; unsaved)
