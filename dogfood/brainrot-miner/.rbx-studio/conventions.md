# Conventions: brainrot-miner (Snorbo's Brain Rock Mine)
Built: 2026-11-04 by /rbx-start from 6 files sampled (list below). Updated by /rbx-review and /rbx-optimize.
Goal: code keeps getting better. "Keep" = new code follows it. "Phase out" = new code never repeats it; /rbx-optimize migrates it over time.

## Layout
Rojo project (`default.project.json`). `src/shared` -> ReplicatedStorage.Shared, `src/server` -> ServerScriptService.Server, `src/client` -> StarterPlayerScripts.Client. Tests in `tests/` (Lune). Build output in `build/`.

## Naming
Modules PascalCase (`Data`, `Economy`). Scripts `*.server.luau` / `*.client.luau`. Locals camelCase, constants UPPER_SNAKE (`src/server/Data.luau:19`). Remotes PascalCase verbs (`Mine`, `BuyUpgrade`).

## Module pattern (services, controllers, lifecycle)
Plain module tables returning `Data`/`Config`/`Economy`. No lifecycle framework. Shared pure logic lives in `Economy` so server and client agree (`src/shared/Economy.luau`). `--!strict` on every file.

## Networking (remote wrapper, validation style)
Server creates the Remotes folder at runtime (`src/server/Game.server.luau:13-23`); clients use `Remotes.get(name)` (`src/shared/Remotes.luau:14`). Handlers check `typeof`, NaN, integer, and range before acting (`Game.server.luau:92-95`). Server pushes a full state snapshot after each change (`Game.server.luau:45`). No rate limits yet.

## Data (data module, schema, receipts)
Only `src/server/Data.luau` touches DataStoreService (line 27). Session lock via UpdateAsync with JobId + timestamp (lines 67-80). Versioned `Profile` with `reconcile` (lines 46-57). 60 s autosave, BindToClose release (lines 149-153). One `ProcessReceipt` in `Game.server.luau:129` with PurchaseId history for idempotency.

## UI (framework, layout style, tween patterns)
Hand-built Instances, no framework (`src/client/Hud.client.luau`). Single PALETTE table (line 22). `CoreUISafeInsets` set. Small TweenService press feedback (lines 145-148).

## Error handling and logging
`pcall` around DataStore calls, 3 retries with exponential wait, `warn` on failure. Kick on failed load.

## Perf budgets
Not set. Passive tick runs every 0.1 s and fires State to every player each tick (`Game.server.luau:153-160`). Budget it in /rbx-perf.

## Keep
| Pattern | Example (file:line) | Why |
|---|---|---|
| Single data module owns all DataStore calls | src/server/Data.luau:27 | One place to audit |
| Session lock + reconcile + version field | src/server/Data.luau:46 | Safe saves and migrations |
| Validate remote args before use | src/server/Game.server.luau:92 | Server never trusts client |
| One receipt handler, PurchaseId history | src/server/Game.server.luau:129 | Idempotent purchases |
| Pure shared economy math | src/shared/Economy.luau | Testable, no drift |
| `--!strict` everywhere | all files | Catches bugs early |

## Phase out
| Pattern | Example (file:line) | Replace with | Priority |
|---|---|---|---|
| Full-state push on every 0.1 s tick | src/server/Game.server.luau:153 | Push on change, 1 Hz tick for passive income display | High |
| ~~No rate limit on Mine remote~~ fixed 2026-11-04 | Game.server.luau:61 | done | done |
| ~~Remote names duplicated in two files~~ fixed 2026-11-04 | Game.server.luau:16 now loops `Remotes.Names` | done | done |
| Data.save on every receipt blocks the handler | Game.server.luau:145 | Keep, but add retry budget check | Med |
| Hard-coded product id 0 | src/shared/Config.luau:49 | Real id before launch | Med |
| Raw Instance UI building | Hud.client.luau | Keep for now; revisit if UI grows | Low |

## Learned (dated, appended by review/optimize)
- 2026-11-04 KEEP: per-player token bucket from `Config.RateLimits`, cleared on PlayerRemoving (src/server/Game.server.luau:61 `allow`). Every new remote gets a Config entry.
- 2026-11-04 KEEP: after any yielding load in PlayerAdded, re-check `player.Parent == Players` and release the lock if they left (src/server/Game.server.luau:84).
- 2026-11-04 KEEP: a cancelled UpdateAsync (returns nil) is not a save; track a `wrote` flag, reset at callback start (src/server/Data.luau:108).
- 2026-11-04 KEEP: remote payload types exported from Remotes (`Remotes.State`, src/shared/Remotes.luau:7), used by server snapshot and client handler.
- 2026-11-04 KEEP: HUD renders on State event, with cached refs, never in RenderStepped (src/client/Hud.client.luau:201).
- 2026-11-04 KEEP: BindToClose releases players in parallel with a pending counter (src/server/Data.luau:150).
- 2026-11-04 PHASE OUT: `FindFirstChild` chains inside RenderStepped (was Hud.client.luau, removed). Never repeat.
- 2026-11-04 PHASE OUT: `Remotes.get(name)` (WaitForChild) inside click handlers. Cache at module top (src/client/Hud.client.luau:14).

## Open questions
- Is the Studio place in sync with the Rojo files (build/brainrot-miner.rbxl is checked in)?
- Which team owns the universe_id / place_ids? Not set.

## Files sampled
src/server/Data.luau, src/server/Game.server.luau, src/shared/Config.luau, src/shared/Remotes.luau, src/shared/Economy.luau (skimmed via grep only), src/client/Hud.client.luau (first 60 lines plus grep)
