# Remote audit 2026-11-04

Scope: all. Verdict: no BLOCKER, no MAJOR, 2 MINOR.

## Inventory (4 remotes, 3 handlers, 0 prompts, 0 click detectors)
| Remote | Dir | Handler | Args | Limit |
|---|---|---|---|---|
| Mine | C->S | src/server/Game.server.luau:122 | none | 15/s, burst 20 |
| BuyUpgrade | C->S | src/server/Game.server.luau:135 | upgradeId: string, count: number | 10/s, burst 10 |
| Rebirth | C->S | src/server/Game.server.luau:160 | none | 1/s, burst 2 |
| State | S->C | FireClient only (no OnServerEvent) | snapshot | n/a |

No wrapper. Handlers validate inline. No RemoteFunction, no InvokeClient. Remotes are created by the server (Game.server.luau:14-23).

## Static review
- Order is rate limit, typeof, NaN, range (1..100), integer, id lookup, cost check, then act. All state changes go through the server profile.
- No client-sent price, position, damage, or item data. Cost comes from Config on the server.
- Rate limit sits before arg checks, so bad calls still cost tokens. That is the safe order.
- Buckets are cleared on PlayerRemoving. A player with no bucket is denied.
- Receipt: single ProcessReceipt (line 179), PurchaseId stored in the profile, save before PurchaseGranted. Unknown product returns NotProcessedYet.

## Attack results (Studio play mode, Client datamodel)
- PROVEN BuyUpgrade bad input: about 27 cases (nil, NaN, inf, -1, 0, 0.5, 101, 1e308, 2^53, tables, Vector3, "__index", "", NUL id). Rocks and levels unchanged.
- PROVEN Mine: 1000 calls in one frame credited 21. 3050 calls over 1.7 s credited 35. Matches 20 burst plus 15/s.
- PROVEN BuyUpgrade spam: 1000 calls, exactly 10 buys. Rocks covered about 15.
- PROVEN Rebirth: 1000 calls at lifetime about 422 (needs 1e6). No change.
- PROVEN oversize: 1 MB string, 1 MB extra arg, 200-deep table. No client error, no state change.
- PROVEN State:FireServer with fake snapshot: no effect.
- Limit: server console was not readable, so "no server errors" is PLAUSIBLE.

## Findings
MINOR 1: BuyUpgrade accepts any string length until the lookup. Payload still arrives, bounded by 10 calls/s.
Fix: Game.server.luau:139, add `or #upgradeId > 32` to the typeof check.

MINOR 2: Receipt path is NOT ASSESSED. Config.Products.RockRush.productId is 0 (Config.luau:40), so no real purchase can run.
Fix: after creating the product in Creator Hub, set the id and run a private-server test purchase. Re-run this audit on the receipt path.

## Notes
- The first State push can land before the client listener connects. Confirm the HUD handles a late first push (not audited here).
