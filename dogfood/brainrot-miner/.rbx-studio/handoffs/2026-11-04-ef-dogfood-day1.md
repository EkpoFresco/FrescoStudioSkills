# Handoff: dogfood day 1 (brainrot-miner)
From: EkpoFresco · To: Jay · Date: 2026-11-04 · Branch: main · Last commit: 4d8414b

## Where it stands
Optimize pass is 2 of 3 done and committed. Audits and reports are written. The open Studio place is out of sync with the files and is not saved. Fix that first.

## Changed
- src/server/Game.server.luau: State pushed on change plus 1 Hz heartbeat (9 -> 0 pkts/s idle, 9 -> ~1 with income). TD-001.
- src/shared/Config.luau: added `HeartbeatSeconds`. src/shared/Remotes: `State` now carries `income`.
- src/shared/Economy.luau: `bulkCost` uses one pow plus running multiply (70.33 -> 8.59 ms / 20000 calls). Spec added, 18 pass.
- src/client/Hud.client.luau: one reused tween pair per rock tap (17.45 -> 1.71 ms / 2000 taps). TD-007. Rebirth hidden until payable, rock cue pulses for first 2 taps.
- Review fixes: rate limits, save-lock correctness, HUD renders on event, typed State.
- .rbx-studio/reports/: review, optimize, remote-audit, data-audit, first-60, playtest, telemetry, monetization (light offer sheet, design only until bounce gate).
- .rbx-studio/conventions.md: tween reuse pattern.

## Open
- Studio-only, NOT in git, NOT saved: I pushed Config, Remotes, Game, Hud into the open place via execute_luau. Data and Economy in Studio are still the old copies.
- Optimize target 3 not started: TD-008 (score 6) or TD-002 (score 2, data path, needs owner approval). See .rbx-studio/debt.md.
- TD-004: `Config.Products.RockRush.productId = 0`. Set a real id before launch.
- .rbx-studio/conventions.md is stale on net: lines 15, 27, 42 still say full-state push every 0.1 s and no rate limits. Update them to push on change plus 1 Hz heartbeat.
- checkpoint.md is stale (says last commit 3bb48ac, still lists bulkCost and TD-007 as not done).

## Start here
1. Run `/rbx-pickup`, then open the place in Studio.
2. Sync Data and Economy from src/ into the place (same way Config and Game were pushed), then save the place.
3. Run the Economy spec and confirm 18 pass.
4. Pick target 3: TD-008 (unknown ProductId should return NotProcessedYet only for transient errors). Measure baseline first.
5. Run `/rbx-checkpoint` to refresh checkpoint.md.

## Watch out
- bulkCost can drift above ~4e14 total cost (floats). Fine for current curve.
- Data.luau edits (TD-002, TD-003) touch saves. Get the developer's approval and run `/rbx-data-audit` after.
- Nothing is pushed. Pushing waits for the developer saying "approved, push".
