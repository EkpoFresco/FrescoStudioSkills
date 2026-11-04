# Data audit: 2026-11-04 (scope: all)

Verdict: AT RISK (BLOCKER 0, MAJOR 4, MINOR 4)

Audited inline (no agent delegation). Read: `src/server/Data.luau`, `src/server/Game.server.luau`, `src/shared/Config.luau`. Checklist from `implementation-data.md`.

## Inventory
- DataStore call sites: 3, all in `src/server/Data.luau` (GetDataStore :27, UpdateAsync :67 load, UpdateAsync :110 save). None outside the data module. Pass.
- Receipt handlers: 1 (`Game.server.luau:179`). No `PromptProductPurchaseFinished` grant. Pass.
- Session lock: custom (JobId + timestamp inside UpdateAsync, 180 s expiry). Not ProfileStore.
- Autosave: 60 s loop (`Data.luau:143`), under the 180 s lock. Pass.
- Save on leave: `Game.server.luau:117`. BindToClose: `Data.luau:153`, parallel release. Pass.
- Test prefix: `Test_User_` in Studio. Pass.
- Products: RockRush only, `productId = 0` (not created yet). No ad-reward product exists.

## Findings

### MAJOR
F1. Receipt retry returns PurchaseGranted without a durable save. `Game.server.luau:186`.
If the first attempt grants, records the id, then `Data.save` fails (:195), it returns NotProcessedYet. The retry sees `hasPurchase` true and returns PurchaseGranted with no save check. If the next save also fails, the player paid and the grant is lost.
Fix: track saved ids. Keep `p.PurchaseHistory` as is, plus a server-side set `durable[id]` filled only when `Data.save` returns true. On the `hasPurchase` branch, call `Data.save` again and return Granted only on true.

F2. Leave and shutdown saves have no retry and the profile is dropped regardless. `Data.luau:98-127`.
One failed `UpdateAsync` (throttle, 5xx) loses up to 60 s of progress, leaves the lock set, and `release` still clears `profiles[player]`. The player is then kicked as "busy" for up to 180 s on rejoin, because `load` retries only 14 s (2+4+8).
Fix: retry save up to 3 times with backoff and jitter in `release`; skip retry on 1xx errors; keep the profile in memory until the save lands or attempts run out.

F3. No schema guard. `Data.luau:53`.
`reconcile` stamps `Version = VERSION` on any loaded data. A server running v1 loading v2 data downgrades the stamp and a later migration can run twice or not at all. No migration table exists.
Fix: add `Migrate.run` (forward steps, idempotent). If stored Version > VERSION, do not mutate: release the lock and kick. Add a fixture test per version.

F4. Not ProfileStore. `Data.luau` (whole file).
Rule and library say ProfileStore v1.0.3 for player data. The custom lock works on paper but re-implements what ProfileStore gives (ordered saves, session-end signal, MessageAsync, Mock for tests). Takeover waits are fixed at 180 s, so crash recovery is slow.
Fix: decide and log in `.rbx-studio/decisions.md`: migrate to ProfileStore (preferred, cheap while the schema is v1), or keep custom and accept F2/F5/F7 as your own maintenance. Not a data-loss bug today.

### MINOR
F5. Load transform does not reset `result` on rerun. `Data.luau:64-80`. `save` resets `wrote` at the top of the callback; `load` does not. If the callback reruns on conflict and the final run returns nil (another server took the lock), `result` still holds the earlier profile and this server proceeds without the lock. Set `result = nil` at the top of the callback.

F6. `PurchaseHistory` is never capped. `Data.luau:134`. Grows one string per purchase and `table.find` is linear. Cap at 100 (`while #ids > 100 do table.remove(ids, 1) end`) in `recordPurchase`.

F7. Autosave, leave, and shutdown can write the same key at once. `Data.luau:143-165`. An autosave transform that runs after a release save re-sets `_lock`, stranding it for 180 s. Add a `releasing[player]` flag checked in `save`. Also `BindToClose` only waits on players still in `GetPlayers()`; releases already started by PlayerRemoving are not awaited. Track in-flight releases in one counter. UNVERIFIED: engine order of PlayerRemoving vs BindToClose at shutdown; verify with a logged 2-player Studio server close.

F8. UpdateAsync drops userIds and metadata. `Data.luau:67,110`. Return `keyInfo:GetUserIds()` (and add `player.UserId` on first write) so RTBF and GDPR tooling can find the key. The key pattern `User_{UserId}` already works for RTBF templates, so this is hygiene.

### Notes (no action)
- Unknown product ids return NotProcessedYet (`Game.server.luau:192`). Add a loud `warn` with ProductId. When RockRush gets a real id, set `Config.Products.RockRush.productId`; until then the handler grants nothing.
- Studio without API access: `GetDataStore` does not throw, so `store` is never nil and `load` kicks after 3 failed tries. The in-memory fallback at :58 is dead. Test with API access on, or set `store = nil` when `RunService:IsStudio()` and the first call returns 403.
- Request budget: autosave is 1 read + 1 write per player per minute against 60 + 40n. Fine. No `GetRequestBudgetForRequestType` gating needed yet.
- Receipt grant and id insert run with no yield between them. Pass.

## Fix order
1. F1, F2 (data loss paths)
2. F3, F5 (before any v2 schema or second server)
3. F4 decision
4. F6, F7, F8
