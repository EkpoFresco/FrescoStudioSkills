# Data audit (measurement run, before): 2026-11-04, scope: all

Verdict: AT RISK (BLOCKER 0, MAJOR 4, MINOR 4)

Audited inline, no agent delegation. Read: `src/server/Data.luau` (168 lines), `src/server/Game.server.luau` (223 lines), `implementation-data.md`. Not changed: any other file. Not committed.

## Inventory
- DataStore call sites: 3, all in `src/server/Data.luau` (GetDataStore :27, UpdateAsync :67 load, UpdateAsync :110 save). None outside the data module. Pass.
- Receipt handlers: 1 (`Game.server.luau:179`). No `PromptProductPurchaseFinished` use. Pass.
- Session lock: custom (JobId + timestamp inside UpdateAsync, 180 s expiry). Not ProfileStore. ProfileService not used.
- Autosave: 60 s loop (`Data.luau:143`), under the 180 s lock. Pass.
- Save on leave: `Game.server.luau:117`. BindToClose: `Data.luau:153`, parallel release. Pass.
- Test key prefix: `Test_User_` in Studio, same store name `PlayerData_v1`. Pass.
- Products: RockRush only, ad-reward product none. Config productId is a placeholder, so the handler grants nothing today.

## Findings

### MAJOR
F1. Receipt retry returns PurchaseGranted without a durable save. `Game.server.luau:186`.
Attempt 1 grants, records the id (:194), then `Data.save` fails (:195) and returns NotProcessedYet. Attempt 2 hits `hasPurchase` (:186) and returns PurchaseGranted with no save check. If the next autosave also fails or the server crashes, the player paid and the grant is lost.
Fix: on the `hasPurchase` branch call `Data.save(player, false)` and return PurchaseGranted only when it returns true.

F2. Leave and shutdown saves have no retry, and the profile is dropped regardless. `Data.luau:98-127`.
One failed `UpdateAsync` (throttle, 5xx) loses up to 60 s of progress. `release` still sets `profiles[player] = nil` (:126) and the lock stays set. Rejoin then fails: `load` retries only about 14 s (2+4+8 s) against a 180 s lock, so the player is kicked as "busy".
Fix: retry the release save up to 3 times with backoff and jitter, no retry on 1xx codes. Drop the profile only after success or the last attempt.

F3. No schema guard. `Data.luau:53`.
`reconcile` stamps `Version = VERSION` on any loaded data. A v1 server loading v2 data rewrites the stamp to 1, so a later migration can run twice or never. No migration table exists.
Fix: add forward steps, one per version, idempotent. If stored Version > VERSION, do not mutate: release the lock and kick. Add a fixture per version.

F4. Not ProfileStore. `Data.luau` (whole file).
Rule says ProfileStore v1.0.3. The custom lock works on paper but has no ordered saves, no session-end signal, no MessageAsync, no Mock, and crash takeover waits a fixed 180 s.
Fix: log a decision in `.rbx-studio/decisions.md`. Preferred: migrate to ProfileStore while the schema is v1. Else keep custom and own F2, F5, F7.

### MINOR
F5. Load transform does not reset `result` on rerun. `Data.luau:64-80`. `save` resets `wrote` at the top of its callback, `load` does not. If the callback reruns on conflict and the last run returns nil, `result` still holds the earlier profile and this server proceeds without the lock. Add `result = nil` at the top of the callback.

F6. `PurchaseHistory` never capped. `Data.luau:134`. One string per purchase forever, and `table.find` is linear. Cap at 100 in `recordPurchase`.

F7. Autosave, leave, and shutdown can write one key at once. `Data.luau:143-165`. An autosave that lands after a release re-sets `_lock` and strands it for 180 s. Add a `releasing[player]` flag checked in `save`. `BindToClose` only waits on players still in `GetPlayers()`, so releases started by PlayerRemoving are not awaited. UNVERIFIED: engine order of PlayerRemoving vs BindToClose at shutdown. Verify with a logged 2-player Studio server close.

F8. UpdateAsync drops userIds and metadata. `Data.luau:67,110`. Return `keyInfo:GetUserIds()` and add `player.UserId` on first write so RTBF and GDPR tooling can find the key.

### Notes (no action)
- Unknown product id returns NotProcessedYet (`Game.server.luau:192`). Add a loud `warn` with the ProductId.
- Studio without API access: `GetDataStore` does not throw, so `store` is never nil and the in-memory fallback at :58 is dead. `load` kicks after 3 failed tries. Test with API access on.
- Budget: autosave is 1 read + 1 write per player per minute against 60 + 40n. Fine. No `SetRateLimitForRequestType` or budget gating yet.
- Grant and id insert run with no yield between them (:190-194). Pass.
- Ad-reward (`AdReward` channel) is covered only in the sense that any unknown product returns NotProcessedYet. No ad product exists, so nothing to cover yet.

## Fix order
1. F1, F2 (data loss paths)
2. F3, F5 (before any v2 schema or second server)
3. F4 decision
4. F6, F7, F8

DONE
- verdict: AT RISK (BLOCKER 0, MAJOR 4) (.rbx-studio/reports/ab-before-data-audit.md)
- worst: receipt retry grants without a durable save at src/server/Game.server.luau:186
YOU DO
1. Read the report, then run /rbx-build fix-data when ready.
RISKS
- Dev product id is a placeholder, so F1 cannot hit a live player yet.
NEXT
- /rbx-build fix-data
