# Data audit (measurement run, scope: all)

Date: 2026-11-04. Files read: src/server/Data.luau (168 lines), src/server/Game.server.luau (lines 55-223).

## Verdict
AT RISK (BLOCKER 0, MAJOR 2, MINOR 5)

## Inventory
- DataStore call sites: 3, all in src/server/Data.luau (GetDataStore:27, UpdateAsync:67, UpdateAsync:110). None outside the data module. PASS.
- Receipt handlers: 1 (src/server/Game.server.luau:179). PASS.
- Session lock: custom UpdateAsync lock (JobId + time, 180 s). No ProfileStore.
- Autosave: 60 s loop (Data.luau:143). 60 < 180. PASS.
- PlayerRemoving save: Game.server.luau:117 -> Data.release.
- BindToClose: Data.luau:153, parallel release, waits for all.
- Studio key prefix: `Test_User_` in Studio, `User_` live (Data.luau:21). PASS.

## Findings

### MAJOR 1: failed receipt save is later reported as granted
src/server/Game.server.luau:186-188 and 194-196.
Flow: grant is applied to the in-memory profile and the PurchaseId is recorded (194). If `Data.save` fails, the handler returns `NotProcessedYet` (196). Roblox retries the receipt. On retry, `hasPurchase` is true (186), so the handler returns `PurchaseGranted` without any save. If the server then crashes or the next save fails, the player paid and the boost plus PurchaseId are lost. Rule broken: `PurchaseGranted` only after the save is durable.
Fix: track unsaved purchase ids (or a dirty flag). On the duplicate path, call `Data.save` and return `PurchaseGranted` only if it succeeds.

### MAJOR 2: one-shot saves, and the profile is dropped even if the save failed
src/server/Data.luau:98-122 and 124-127.
`Data.save` has no retry or backoff (load has 3 tries, save has 0). `Data.release` ignores the result and sets `profiles[player] = nil`. One DataStore throttle or outage on leave loses the whole session of progress, and the lock stays held for 180 s. Autosave (147) also ignores failures silently.
Fix: retry 3 times with backoff in `save`, `warn` on failure, and in `release` keep retrying within the shutdown window before dropping the profile.

### MINOR 1: custom session lock, not ProfileStore
Data.luau:67-80. It works: lock refresh on each autosave, cancelled write when another JobId owns the key. But it is hand-rolled and unaudited against ProfileStore edge cases. The library rule asks for ProfileStore v1.0.x. Record the decision in `.rbx-studio/decisions.md` or migrate.

### MINOR 2: PurchaseHistory grows without bound
Data.luau:14, 134-136. Linear `table.find` and a growing key toward the 4 MB limit. Cap to the last N ids (e.g. 200) or store as a set with timestamps.

### MINOR 3: unknown products return NotProcessedYet forever
Game.server.luau:191-192. Roblox keeps retrying a product this server does not know. Fine with a single product today. Log it with `warn`.

### MINOR 4: ad-reward channel not handled
Game.server.luau:179-200. Only `Config.Products.RockRush` is covered. If an ad-reward product is added, it needs its own branch. Not a bug today.

### MINOR 5: no migration path, budget checks, or data tests
- Data.luau:46-55: `Version` field exists and unknown keys are kept, but `reconcile` just overwrites `Version`. No forward migration function. Fine at v1, add a migration table before v2.
- No `GetRequestBudgetForRequestType` checks with `StandardRead` / `StandardWrite`. Autosave fires one UpdateAsync per player per 60 s; low risk at small player counts.
- tests/ has only economy.spec.luau. No test for Data (lock conflict, receipt idempotency, failed save).

## Passing checks
- Lock refreshed by autosave, interval 60 s < LOCK 180 s.
- Save on leave and in BindToClose, parallel so 30 s is not exceeded by sequential saves.
- Player leaving during load releases the lock (Game.server.luau:87-93).
- Save only counts as written when the callback actually wrote (`wrote` flag, Data.luau:108-121).
- Receipt returns `NotProcessedYet` when the profile is not loaded (181-184).
- Nothing grants on `PromptProductPurchaseFinished`.
- Studio uses a separate `Test_User_` prefix.

## Not done
- `.rbx-studio/reports/data-schema.md` already exists; not touched (measurement run).
- No code changed, nothing committed.
