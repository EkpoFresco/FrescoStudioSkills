# Roblox Data, Monetization, and Analytics Implementation Reference

Last checked: 2026-11-03. Sources at bottom.

Audience: data-engineer, monetization-designer, analytics-engineer, code-optimizer agents.
Scope: persistence, cross-server state, purchases, policy, ads, analytics, experiments.
Luau style, architecture, networking, exploits, and general performance live in [implementation.md](./implementation.md). Do not duplicate them here.

## TL;DR for agents

- Data store limits moved to the **experience level** (rollout April 9 to April 23, 2026) and Open Cloud now **shares** that budget (live July 29, 2026). Default per-server limits still apply and are now configurable with `SetRateLimitForRequestType` [1][10][11].
- Use the **modern** `Enum.DataStoreRequestType` values (`StandardRead`, `StandardWrite`, ...). The legacy values (`GetAsync`, `SetIncrementAsync`, ...) "should not be used" [3].
- Storage limit is `500 MB + 1 MB x lifetime users` (base raised from 100 MB on July 29, 2026). Overage is not throttled: it is billed in Robux after a 2 week grace period [1][10][11].
- Player data: one key per player, `User_{UserId}`, session locked with **ProfileStore** (v1.0.3). ProfileService is unsupported. DataStore2 is legacy and Roblox ships a migration tool off it [6][14][17].
- A failed write can still have succeeded. Make every money or item write idempotent and verify with `UseCache = false` reads when you must know [1][5].
- Developer products: grant only in `ProcessReceipt` (or the newer `BindReceiptHandler`). Store `PurchaseId` in the **same session-locked key** as the reward, and return granted only after that key is durably saved [16][27].
- Never grant on `PromptProductPurchaseFinished`. It does not mean a purchase happened [28].
- Rewarded video rewards arrive through `ProcessReceipt` with `ProductPurchaseChannel.AdReward`. Your receipt handler must cover ad reward products [29][44].
- Hard-coded prices are wrong for Roblox Plus subscribers (10 to 20% discount) and for Managed Pricing. Always read prices from `GetProductInfoAsync` or `GetDeveloperProductsAsync` [35][39].
- Roblox ships first-party A/B testing: **Experiments** on top of **Configs**, read per player with `ConfigService:GetConfigForPlayerAsync` [53][54].
- AnalyticsService: server only, published games only, `120 + 20 x CCU` requests per minute, charts appear in about 24 hours, max 100 custom event names, 10 funnels, 10 economy currencies, 3 custom fields [48][49].
- `PolicyService:GetPolicyInfoForPlayerAsync` gates paid random items, paid item trading, ads, subscriptions, commerce. Fail closed on error [43].

## 1. DataStoreService

### 1.1 Data and metadata limits

| Item | Limit |
|---|---|
| Data store name, key name, scope | 50 characters each [1] |
| Value per key | 4,194,304 characters (4 MB), measured as serialized JSON [1] |
| Metadata key / value | 50 / 250 characters [1] |
| Metadata total size | 300 characters [1] |
| Request queue per type (Set, Ordered set, Get, Ordered get) | 30 requests, then errors 301 to 306 [1] |
| Version retention | Superseded versions expire 30 days after being overwritten. Latest never expires [5] |
| Removed keys | Deleted permanently after 30 days [4] |
| OrderedDataStore `PageSize` | 1 to 100 [1] |
| OrderedDataStore `BatchGetAsync` | Up to 100 keys (default server max). Ordered stores only [4] |

- Strings must be valid UTF-8 or the write fails [4].
- Do not store `inf`, `-inf`, `nan` [5].
- Buffers serialize natively [5].
- Do not pre-compress: storage usage is measured on Roblox's own compressed size and pre-compression can hurt it [1].

### 1.2 Per-key throughput (all servers combined, rolling 60 s)

| Type | Calls | Limit |
|---|---|---|
| Read | GetAsync, GetVersionAsync, GetVersionAtTimeAsync, ListVersionsAsync, UpdateAsync | 25 MB per minute [1] |
| Write | SetAsync, IncrementAsync, UpdateAsync, RemoveAsync | 4 MB per minute [1] |

- Each request rounds up to the next KB [1].
- Hot shared keys (event flags, weather) hit this first. Shard reads across copies like `Weather_1..N` with jittered polling [6].

### 1.3 Access limits (requests per minute)

Experience level, shared by all servers and Open Cloud since July 29, 2026 [1][11]:

| Type | Standard | Ordered |
|---|---|---|
| Read | 300 + CCU x 40 | 300 + CCU x 40 |
| Write | 300 + CCU x 20 | 300 + CCU x 20 |
| List | 300 + CCU x 2 | 300 + CCU x 2 |
| Remove | 300 + CCU x 40 | 300 + CCU x 40 |

Server level defaults, `numPlayers` = players in this server [1]:

| Request type enum | Default | Configurable range (base / per player) [2] |
|---|---|---|
| `StandardRead` | 60 + n x 40 | 0..10000 / 0..200 |
| `StandardWrite` | 60 + n x 40 | 0..10000 / 0..200 |
| `StandardList` | 5 + n x 2 | 0..10000 / 0..200 |
| `StandardRemove` | 60 + n x 40 | 0..10000 / 0..200 |
| `OrderedRead` | 60 + n x 40 | 0..10000 / 0..200 |
| `OrderedWrite` | 30 + n x 5 | 0..10000 / 0..200 |
| `OrderedList` | 5 + n x 2 | 0..10000 / 0..200 |
| `OrderedRemove` | 30 + n x 5 | 0..10000 / 0..200 |

- `UpdateAsync` consumes both read and write budget [1].
- Servers get a one-time startup burst [1].
- Call `SetRateLimitForRequestType` once per type at server init, never mid-game [2].
- Studio Run mode has separate static, possibly lower limits. Test limits in Team Create [1].
- Open Cloud has no built-in limiter. Rate limit external scripts so they do not starve live servers [1][6].
- Doc quirk: `GetRequestBudgetForRequestType(Enum.DataStoreRequestType.OrderedList)` is documented to return 0 [3]. Do not gate leaderboard refresh on it. UNVERIFIED in live servers: log the value once in a test place.
- New throttle error names: `<Type>GameServerThrottled` and `<Type>ExperienceThrottled` (for example `StandardWriteExperienceThrottled`). Retry with exponential backoff and jitter [1][10].

### 1.4 Storage quota and tooling

- Formula: `500 MB + 1 MB x lifetime user count`. Only the latest version of each key counts [1].
- Change dates: storage limits activated April 9, 2026 at a 100 MB base. Base raised to 500 MB on July 29, 2026 [10][11].
- Over the limit: writes are not throttled. You get notified, then after a 2 week grace period Roblox deducts Robux from the owner. Unpaid dues can unpublish the experience and freeze Robux spending. Extended Services is the paid alternative [10].
- Data stores deleted via Open Cloud keep counting for their 30 day deletion window [1].
- **Data Stores Observability dashboard** (Creator Hub, Monitoring, Data Stores): storage bytes, requests by API and status, quota usage per category. 30 days of history. Last 3 minutes may be incomplete [7].
- **Data Stores Manager** (Configurations, Data stores manager): browse keys, view versions, compare, revert, mark for deletion, estimated overage cost. Sizes hidden above 100 data stores [8].
- Use custom alerts on data store metrics [6].
- Take an Open Cloud snapshot (once per day allowed) before any release that changes save logic [5].

### 1.5 Reads, writes, caching

- `GetAsync` caches a key locally for 4 seconds. Writes through the same data store object update the cache [4][5].
- Bypass with `DataStoreGetOptions.UseCache = false` for verification reads after an uncertain write [5].
- Cache is per data store object instance. Two instances of the same store can disagree [5].
- `GetVersionAsync`, `ListVersionsAsync`, `ListKeysAsync`, `ListDataStoresAsync` never cache [5].
- Prefer `UpdateAsync` whenever the new value depends on the old one or multiple servers may write. `SetAsync` only for create or blind replace [4][6].
- `UpdateAsync` transform must not yield. Return `nil` to cancel the write. It may run several times on contention [4].
- Return `keyInfo:GetUserIds()` and `keyInfo:GetMetadata()` from the transform unless changing them, or they are cleared [4].
- Retries must be ordered per key. An old retry landing after a newer write overwrites new data [6][12].

### 1.6 Versioning, metadata, GDPR

- `DataStore:ListVersionsAsync(key, sortDirection, minDate, maxDate, pageSize)` lists versions. `GetVersionAsync` and `GetVersionAtTimeAsync` read them [5].
- Roll back a player by reading a version and writing it as a new version with `SetAsync`, preserving metadata [5].
- Always pass `{player.UserId}` as `userIds` on player keys (ProfileStore `AddUserId`) [4][15].
- Configure automated **RTBF** deletion templates (`User_{UserId}`) in Data Stores Manager or the Configs API. Up to 100 templates. The user ID must be in the key or scope name with a static pattern [9].
- Ordered data stores have no versions and no metadata. `RemoveAsync` on them is permanent [4].

### 1.7 Error codes that matter

| Code / name | Meaning | Action |
|---|---|---|
| 101 to 107 | Bad key, bad value, too large | Bug. Do not retry [1] |
| 301 to 306 | Queue full, request dropped | Back off, reduce rate [1] |
| 401, 402 | Experience shutting down | Stop issuing new requests [1] |
| 403 | Studio API access off | Enable in Game Settings [1] |
| 501 to 505 | Internal / malformed | Retry with backoff [1] |
| 511, 512, 513 | Metadata or user ID problems | Bug [1] |
| `KeyThrottled`, `DatastoreThrottled` | Throughput limit | Backoff, shard hot keys [1] |
| `*ExperienceThrottled`, `*GameServerThrottled` | Access limit | Backoff with jitter [1] |
| `InternalServerError` | Transient | Exponential backoff [1] |

```lua
--!strict
-- Retry with capped exponential backoff and jitter. Use for non-session keys.
local function withRetry(fn: () -> any, maxAttempts: number?): (boolean, any)
	local attempts = maxAttempts or 5
	local delay = 1
	local lastErr: any = nil
	for i = 1, attempts do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		lastErr = result
		-- "1xx:" errors are invalid requests. Retrying cannot fix them.
		local code = tonumber(string.match(tostring(result), "^(%d%d%d)"))
		if code and code >= 101 and code <= 107 then
			break
		end
		if i < attempts then
			task.wait(delay + math.random() * delay)
			delay = math.min(delay * 2, 30)
		end
	end
	return false, lastErr
end
```

- The `"NNN: message"` error prefix format is observed behavior, not a documented contract. UNVERIFIED: confirm by printing a forced 102 error (51 char key) in Studio.

### 1.8 Autosave and shutdown

- Load once, mutate in memory, save on interval, on leave, on shutdown, and at purchase checkpoints [6][12].
- ProfileStore autosaves each profile every 300 s, spread evenly across the period [15].
- Stagger any custom loop with a random start offset [6].
- `BindToClose`: the server waits up to **30 seconds** for bound functions, then shuts down anyway [13]. ProfileStore binds its own handler and ends all sessions in parallel [15].
- Do not add your own blocking saves in `BindToClose` on top of ProfileStore. Do flush analytics or MemoryStore cleanup quickly and in parallel.

## 2. Session locking

### 2.1 Why

- Without a lock, server B can load stale data while server A's final save is still retrying, throttled, or queued. A then overwrites B, or B overwrites A [12].
- Teleports and fast rejoins make this common. Exploiters abuse it for trade dupes [12].
- Roblox's own pattern: write a lock ID into the key inside `UpdateAsync`, refresh it on autosave, release on final save, allow takeover after expiry [12].

### 2.2 ProfileStore (recommended)

- Repo `MadStudioRoblox/ProfileStore`, Wally `lm-loleris/profilestore` **1.0.3**. Last code push 2025-07-31. Not archived [14].
- ProfileService README: "no longer supported", use ProfileStore for new projects [17].

API shape (from the source header) [15]:

| Member | Notes |
|---|---|
| `ProfileStore.New(storeName, template)` | Store object |
| `store:StartSessionAsync(key, {Steal?, Cancel?})` | Yields. Returns `Profile` or `nil` |
| `store:MessageAsync(key, message)` | Deliver a table to a profile even if offline. Queue cap 1000 |
| `store:GetAsync(key, version?)` | Read without session. No autosave |
| `store:VersionQuery(key, dir?, min?, max?)` | Version history for rollbacks |
| `store:RemoveAsync(key)` | Permanent delete |
| `profile.Data` / `profile.LastSavedData` | Live data / last durable snapshot |
| `profile:IsActive()` | Guarantee holds only until you yield |
| `profile:Reconcile()` | Fills missing keys from template. Never deletes keys |
| `profile:EndSession()` | Final save and release |
| `profile:Save()` | Immediate `UpdateAsync` while active |
| `profile:AddUserId(id)` | GDPR association |
| `profile:MessageHandler(fn)` | Process `MessageAsync` payloads |
| Signals | `OnSave`, `OnLastSave(reason)`, `OnSessionEnd`, `OnAfterSave(lastSaved)` |
| Store globals | `IsClosing`, `IsCriticalState`, `OnError`, `OnCriticalToggle`, `DataStoreState` |

Session conflict timings (constants, changeable with `ProfileStore.SetConstant`) [15]:

- Waiting server rereads after 5 s, then every 10 s. Steals the session after 40 s.
- A profile with no update for 630 s is assumed owned by a crashed server.
- `StartSessionAsync` gives up after 120 s.
- It publishes over MessagingService (`PS_<sessionId>`) to ask the owning server to end its session early, which makes teleport handoff fast in practice [15].

```lua
--!strict
local Players = game:GetService("Players")
local ProfileStore = require(script.Parent.ProfileStore)
local Migrate = require(script.Parent.Migrate)

local TEMPLATE = { SchemaVersion = 3, Coins = 0, PurchaseIds = {} :: { string } }
local PlayerStore = ProfileStore.New("PlayerData", TEMPLATE)
local Profiles: { [Player]: any } = {}

local function onPlayerAdded(player: Player)
	local profile = PlayerStore:StartSessionAsync(`User_{player.UserId}`, {
		Cancel = function() return player.Parent ~= Players end,
	})
	if profile == nil then
		player:Kick("Your data could not load. Please rejoin.")
		return
	end
	profile:AddUserId(player.UserId)
	if not Migrate.run(profile.Data) then
		profile:EndSession() -- newer schema than this server knows
		player:Kick("A newer game version saved your data. Please rejoin.")
		return
	end
	profile:Reconcile()
	profile.OnSessionEnd:Connect(function()
		Profiles[player] = nil
		player:Kick("Data session ended. Please rejoin.")
	end)
	if player.Parent ~= Players then
		profile:EndSession()
		return
	end
	Profiles[player] = profile
end

for _, p in Players:GetPlayers() do task.spawn(onPlayerAdded, p) end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
	local profile = Profiles[player]
	if profile then profile:EndSession() end
end)
```

- Expose `Profiles` through one module with a `WaitForProfile(player)` helper. The receipt handler in section 6 uses it.
- Never let gameplay code write `profile.Data` after `IsActive()` returns false.

### 2.3 Alternatives

| Option | Status | Notes |
|---|---|---|
| ProfileService | Unsupported by author [17] | Migrate to ProfileStore |
| DataStore2 | Legacy. Roblox says do not use for new games and ships a beta migration tool [6] | One data store per player pattern |
| Lapis (`nezuo/lapis`) | v0.3.3 (2024-08-24). README warns it is not battle-tested at scale [18] | Promise API, migrations, validation, save batching |
| Suphi's DataStore Module | UNVERIFIED (could not check repo this pass) | Reported to lock via MemoryStore. Verify on its DevForum thread before use |
| Roblox reference `SessionLockedDataStoreWrapper` | Sample code, "not proven in a popular game" [12] | Good for reading, not for shipping |

Recommendation: ProfileStore for player data. Raw `UpdateAsync` with idempotency keys for shared or global records.

### 2.4 Teleports and handoff

- Do not save in a separate `TeleportInitFailed` path and also on leave. Let `PlayerRemoving` end the session; the destination's `StartSessionAsync` waits or messages the source [15].
- Never move durable state through teleport data. Clients can tamper with it. See [implementation.md](./implementation.md) for teleport mechanics.
- Show a loading screen until the profile is active. Block purchases and trades until then.

## 3. Schema versioning and migration

- Store `SchemaVersion` in every profile. Migrations are forward only, one step per version, idempotent per step.
- Run migrations on raw loaded data, then `Reconcile()` to fill new defaults.
- Never delete unknown keys. An older server in a rolling update may load data written by a newer one; ProfileStore `Reconcile` only adds keys [15].
- If `SchemaVersion > LATEST`, the data came from a newer build. Do not mutate it. End the session and kick so the player lands on a new server.
- Keep removed fields for at least one release before deleting them.

```lua
--!strict
local Migrate = {}
Migrate.LATEST = 3

local STEPS: { [number]: (any) -> () } = {
	[1] = function(d) d.Gems = d.Gems or 0 end, -- v1 -> v2
	[2] = function(d) -- v2 -> v3: rename Items -> Inventory
		if d.Inventory == nil then d.Inventory = d.Items or {} end
		d.Items = nil
	end,
}

function Migrate.run(data: any): boolean
	local v: number = data.SchemaVersion or 1
	if v > Migrate.LATEST then
		return false
	end
	while v < Migrate.LATEST do
		STEPS[v](data)
		v += 1
		data.SchemaVersion = v
	end
	return true
end

return Migrate
```

Testing and rollback:

- Unit test each step with fixtures for every historical version, including `nil` fields.
- Use `ProfileStore.Mock` in Studio to run load, migrate, save loops without touching live data [15].
- Before release: take a data store snapshot [5]. Rollback path is `VersionQuery` or `ListVersionsAsync` plus a re-write, within the 30 day version window [5][15].
- Never ship a migration that drops currency or purchase history in the same release that introduces it.

## 4. MemoryStoreService

### 4.1 Limits

| Item | Limit |
|---|---|
| Memory quota (experience) | 64 KB + 1.2 KB x users. Drops only after an 8 day lookback [19] |
| Request units | 1000 + 120 x CCU per minute, experience level [19] |
| Sorted map / queue size | 1,000,000 items, 100 MB each [19] |
| Key / sort key | 128 characters [20][22] |
| Value | 32 KB [19] |
| Expiration | 0 to 3,888,000 s (45 days). Default 45 days [19][23] |
| Per partition | Throttling starts near 30,000 units per minute. Sorted maps and queues live on one partition [19] |
| Hash map per key | About 5,000 write and 15,000 read units per minute [19] |
| `GetRangeAsync` count | Max 200 [23] |
| Queue `ReadAsync` count | Max 100. Invisibility timeout default 30 s [24] |

Request unit costs: most calls 1. `GetRangeAsync` and `ReadAsync` cost per item returned (ReadAsync adds 1 per 2 s of waiting). Hash map `UpdateAsync` costs at least 2. `ListItemsAsync` costs partitions scanned plus items [19].

- At quota, any call that grows memory fails with `TotalMemoryOverLimit`. Recover by deleting, waiting for expiry, Open Cloud flush (clears the whole scope), or Extended Services [19].
- Studio and live data are isolated. Studio quotas are tiny because CCU is 1 [19].

### 4.2 Use cases

| Need | Structure |
|---|---|
| Matchmaking pool | Queue, or sorted map keyed by skill [19][21] |
| Live global leaderboard | Sorted map with numeric sort key. Persist to OrderedDataStore on a slow cadence [19] |
| Cross-server auction or trade board | Sorted map `UpdateAsync` keeping only the best bid [19] |
| Shared inventories, caches, short locks | Hash map (spreads across partitions) [19][22] |

```lua
--!strict
-- Short lease lock. Coordination only: the durable write must still be idempotent.
local MemoryStoreService = game:GetService("MemoryStoreService")
local locks = MemoryStoreService:GetHashMap("Locks")
local OWNER = game.JobId

local function tryLock(key: string, ttlSeconds: number): boolean
	local ok, value = pcall(function()
		return locks:UpdateAsync(key, function(current)
			if current ~= nil and current ~= OWNER then
				return nil -- held by another server: cancel
			end
			return OWNER
		end, ttlSeconds)
	end)
	return ok and value == OWNER
end

local function unlock(key: string)
	pcall(function() locks:RemoveAsync(key) end)
end
```

- Leases expire mid-operation if a server stalls. Never treat a MemoryStore lock as proof that a Robux or item transfer happened once.
- Cross-server trade pattern: trade record with a `TradeId` in MemoryStore, each side applies the change to its own session-locked profile keyed by `TradeId`, offline side receives it via `ProfileStore:MessageAsync` [15].
- Always pcall, back off on `DataUpdateConflict`, remove processed queue items before the invisibility timeout [19][24].

## 5. MessagingService

| Limit | Value [25] |
|---|---|
| Message size | 1 kB |
| Sent per server | 600 + 240 x players per minute |
| Received per topic | 40 + 80 x servers per minute |
| Received per game | 400 + 200 x servers per minute |
| Subscriptions per server | 20 + 8 x players |
| Subscribe requests per server | 240 per minute |
| Topic name | 1 to 80 characters |

- Delivery is **best effort, not guaranteed**. Typical latency 1 to 2 s [25].
- Good for: global announcements, "server X has event Y", nudging other servers to re-read MemoryStore [26].
- Bad for: anything that must arrive once. Use MemoryStore queues (at-least-once with explicit remove) or data stores instead.
- Subscribe once per topic per server, not per player.
- Open Cloud can publish into live servers for live ops tooling [25].

## 6. Monetization APIs

### 6.1 Product types

| Type | Buy count | Grant path | Notes |
|---|---|---|---|
| Pass | Once | Ownership check | `UserOwnsGamePassAsync` [33] |
| Developer product | Many | `ProcessReceipt` or `BindReceiptHandler` | 1 to 1,000,000,000 Robux [28] |
| Subscription | Monthly | Status check | Robux (min 49) or local currency tiers [34] |
| Robux transfer | Plus subscribers only | `BindReceiptHandler` | 10 to 500 Robux, game earns 10% [32] |
| Commerce product | Physical goods via Shopify | `CommerceService:PromptCommerceProductPurchase` | Creator 18+, ID verified [42] |

Date changes:

- Cross-game developer product sales were disabled starting May 30, 2026. Roblox points to Robux transfers [28].
- Listed developer products can sell outside the game (homepage, search, post Robux purchase). Roblox audits your `ProcessReceipt` and delists flagged products until fixed [28].
- `MarketplaceService:BindReceiptHandler(Enum.ReceiptType, handler, filter?)` is a newer alternative. Filtered handlers by product ID, one catch-all, unmatched receipts fall through to `ProcessReceipt`. Handlers return `Enum.ReceiptDecision.Processed` or `NotProcessedYet` [27][30][31]. Ship date UNVERIFIED: check the DevForum Announcements category or the engine release notes.

### 6.2 Passes

- `UserOwnsGamePassAsync(userId, passId)` results are cached. `PromptGamePassPurchaseFinished` refreshes the cache. External purchases can take minutes to show mid-session; on server join it returns true after purchase [27].
- Pattern: check on join (pcall), store in a server table, re-check with `UserOwnsGamePassAsync` when `PromptGamePassPurchaseFinished` fires with `wasPurchased = true` before granting.
- Pass benefits are derived from ownership. Do not persist "owns pass" as the only source of truth.

### 6.3 ProcessReceipt guarantees

From the official reference [27]:

- Called for unresolved purchases on purchase, on prompt success, and on **join**.
- No time-based retry. After `NotProcessedYet` it is retried only on another purchase or a rejoin.
- No timeout. You may yield as long as the server runs.
- Only one `ProcessReceipt` callback per game. If none is set, receipts auto-acknowledge and are lost.
- The buyer must be in the server for the callback to run. The result is recorded even if they leave.
- The same purchase can run on **two servers at once** if the player joins B before A returns.
- `PurchaseGranted` can still fail to record. The receipt then stays unresolved and comes back.
- Receipt fields: `PurchaseId`, `PlayerId`, `ProductId`, `PlaceIdWherePurchased`, `CurrencySpent`, `CurrencyType`, `ProductPurchaseChannel` [27].
- `ProductPurchaseChannel`: `InExperience`, `ExperienceDetailsPage`, `AdReward`, `CommerceProduct` [29].
- `CurrencySpent` is the real Robux paid, including price test variants [28].

Correctness rules:

1. Dedupe on `PurchaseId`, stored inside the same session-locked profile as the reward. A separate `PurchaseHistory` data store cannot be atomic with the reward [16][27].
2. Grant and record the ID in one non-yielding block, so no autosave can split them.
3. Return granted only after `LastSavedData` contains the ID [16].
4. If the session ends before that, return `NotProcessedYet`. The next server re-checks the ID and does not double grant.

```lua
--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local PlayerData = require(script.Parent.PlayerData) -- WaitForProfile(player): Profile?

local HISTORY = 100
local GRANTS: { [number]: (data: any) -> () } = {
	[123456] = function(data) data.Coins += 100 end, -- must not yield
}

local function saved(profile: any, id: string): boolean
	local ids = profile.LastSavedData.PurchaseIds
	return ids ~= nil and table.find(ids, id) ~= nil
end

local function processReceipt(r: { [string]: any }): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(r.PlayerId)
	local grant = GRANTS[r.ProductId]
	if player == nil or grant == nil then return Enum.ProductPurchaseDecision.NotProcessedYet end
	local profile = PlayerData.WaitForProfile(player)
	if profile == nil or not profile:IsActive() then return Enum.ProductPurchaseDecision.NotProcessedYet end

	local ids = profile.Data.PurchaseIds
	if table.find(ids, r.PurchaseId) == nil then
		local ok = pcall(grant, profile.Data) -- no yield between grant and insert
		if not ok then return Enum.ProductPurchaseDecision.NotProcessedYet end
		table.insert(ids, r.PurchaseId)
		while #ids > HISTORY do table.remove(ids, 1) end
	end

	local lastSave = -math.huge
	while profile:IsActive() do
		if saved(profile, r.PurchaseId) then return Enum.ProductPurchaseDecision.PurchaseGranted end
		if os.clock() - lastSave > 10 then profile:Save(); lastSave = os.clock() end
		task.wait(0.5)
	end
	return if saved(profile, r.PurchaseId) then Enum.ProductPurchaseDecision.PurchaseGranted else Enum.ProductPurchaseDecision.NotProcessedYet
end

MarketplaceService.ProcessReceipt = processReceipt
```

Notes on the snippet:

- `WaitForProfile` must return `nil` once the player leaves, so the handler cannot hang on a departed player.
- Grant functions must validate first and mutate last. A grant that errors halfway leaves partial changes.
- Unknown `ProductId` returns `NotProcessedYet`, never granted. Log it loudly.
- The ID history (100) must exceed the number of receipts that can be unresolved at once for one player.
- Every product used as a rewarded video reward needs an entry in `GRANTS` [44].
- With `BindReceiptHandler`, the same body applies. Return `Enum.ReceiptDecision.Processed` instead of `PurchaseGranted` [27][31].
- Fire `AnalyticsService:LogEconomyEvent` (`IAP`) only after the grant is saved.

### 6.4 Subscriptions

- Prompt: `MarketplaceService:PromptSubscriptionPurchase(player, subscriptionId)`. Check status on the **server** with `GetUserSubscriptionStatusAsync(player, subscriptionId)` returning `IsSubscribed`, `IsRenewing` [27][34].
- Listen to `Players.UserSubscriptionStatusChanged(player, subscriptionId)` and re-query. It also fires when prompting a user who already owns it [34].
- `IsSubscribed` is false while the first payment is still processing [27].
- Gate prompts on `PolicyService` `IsEligibleToPurchaseSubscription` [43].
- Pricing: Robux (>= 49, price change once per 60 days, increases need 30 days notice) or local currency tiers $2.99, $4.99, $7.99, $9.99, $14.99 (price fixed) [34].
- Payout: Robux subs 70% monthly. Local currency subs 70% first month, then 100% [34].
- No mutually exclusive tiers. Not cross-sellable [34].
- Deleting a local currency subscription forces full refunds. Take it off sale first [34].
- Benefits must be derived from live status each session, not stored as permanent flags.

### 6.5 Roblox Plus, Premium, payouts

- **Roblox Plus** launched April 30, 2026 at $4.99/month; no new Premium sign-ups after that, existing Premium continues [36]. Date taken from a search summary of the DevForum post; UNVERIFIED in full text: open the "Introducing Roblox Plus" thread.
- Plus subscribers get 10% off (20% from month 3) on dev products, passes, subscriptions, paid access. Roblox subsidizes it so creator earnings per item are unchanged [35].
- Hard-coded prices display wrong to Plus users. Read prices from `GetProductInfoAsync` (`PriceDiscountDetails`, `UserBasePriceInRobux`) [35].
- In-game Plus sign-ups via `PromptRobloxSubscriptionPurchase` earn 250 Robux per month for 3 months (max 750). Verify with `Player.HasRobloxSubscription` via `GetPropertyChangedSignal` before rewarding [35].
- Paid private server time by Plus owners: up to 100 Robux per subscriber per month at 60+ minutes [35].
- Engagement-based payouts were deprecated July 24, 2025 and replaced by **Creator Rewards** (Daily Engagement and Audience Expansion awards) [37][38].

### 6.6 Pricing tools

- **Managed Pricing** combines regional pricing and price optimization under one opt-in. New games and items are enrolled by default [39].
- Price optimization: needs roughly 60,000 transactions in 30 days. Tests rerun at least every 90 days. Applied only if incremental revenue is positive [40].
- Regional prices range from 30% to 100% of the default price, based on "economic location" [41].
- Use `MarketplaceService:GetUsersPriceLevelsAsync` to block price arbitrage in gifting and trading [41].
- Run the dynamic price check tool. If prices are hard-coded, optimization cannot work [40].

## 7. PolicyService

`GetPolicyInfoForPlayerAsync(player)` returns [43]:

| Field | Gate |
|---|---|
| `ArePaidRandomItemsRestricted` | Loot boxes bought with Robux or Robux-bought currency |
| `IsPaidItemTradingAllowed` | Trading items bought with Robux or premium currency |
| `AreAdsAllowed` | Immersive ads |
| `IsEligibleToPurchaseSubscription` | Subscription prompts |
| `IsEligibleToPurchaseCommerceProduct` | Commerce products |
| `IsContentSharingAllowed` | UGC sharing features |
| `IsSubjectToChinaPolicies` | China compliance |
| `IsPhotoToAvatarAllowed` | Photo-to-Avatar APIs |
| `IsEndlessContentLoadAllowed` | Infinite feeds |
| `IsEndlessContentAutoplayAllowed` | Endless autoplay media |
| `AllowedExternalLinkReferences` | Legacy. Always an empty array |

- Yields. pcall it. Errors if more than 100 calls are pending before a response [43].
- Call once per player on join from the server, cache for the session, replicate needed flags to the client.
- Fail closed: on error assume random items restricted, trading not allowed, ads not allowed, not eligible for subscriptions or commerce. Retry in the background.

```lua
--!strict
local PolicyService = game:GetService("PolicyService")

local FAIL_CLOSED = table.freeze({
	ArePaidRandomItemsRestricted = true,
	IsPaidItemTradingAllowed = false,
	AreAdsAllowed = false,
	IsEligibleToPurchaseSubscription = false,
	IsEligibleToPurchaseCommerceProduct = false,
})
local cache: { [Player]: { [string]: any } } = {}

local function getPolicy(player: Player): { [string]: any }
	local hit = cache[player]
	if hit then return hit end
	local ok, info = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, player)
	if ok and typeof(info) == "table" then
		cache[player] = info
		return info
	end
	return FAIL_CLOSED -- not cached: next call retries
end
```

- Clear `cache[player]` on `PlayerRemoving`.

## 8. Ads

### 8.1 Rewarded video (AdService)

- Methods: `CreateAdRewardFromDevProductId`, `GetAdAvailabilityNowAsync` (client RunContext), `ShowRewardedVideoAdAsync(player, reward, placementId?)` (server RunContext), plus `RegisterAdOpportunityAsync`, `RegisterDisclosureButton`, `UnregisterAdOpportunity`, `GetCampaignEligibilityAsync` [44].
- Reward must be a developer product of this universe. Granted through `ProcessReceipt` with `ProductPurchaseChannel.AdReward` [44][45].
- Eligibility: creator 13+, ID verified, public game with at least 2,000 unique visitors per month. Enable under Monetization, Ads, Settings [45].
- Ads are opt-in, clearly disclosed, 6 to 30 s. Rewards cannot be random. Suggested value 3 to 10 Robux equivalent [45].
- Call `GetAdAvailabilityNowAsync` only when the shop opens, not at join [44][45].
- Protect the character while the ad plays. Optionally exclude likely spenders in Monetization, Ads, Eligibility [45].
- Earnings = EPM x impressions [45]. Exact revenue share UNVERIFIED: check the Ads earnings page in Creator Hub.
- Tune with an Experiment using the "Rewarded Video Earnings" metric set [53].

### 8.2 Immersive ads

- Billboard video (click to play earns per 15 s view, autoplay per impression), image ads, and portal ads that teleport to the advertiser's game [46].
- Ineligible users see a fallback image or the Roblox logo [46].
- Respect `AreAdsAllowed` [43].

## 9. AnalyticsService and experiments

### 9.1 Methods

| Method | Dashboard |
|---|---|
| `LogCustomEvent(player, name, value?, customFields?)` | Custom (Explore) [47][49] |
| `LogEconomyEvent(player, flowType, currency, amount, endingBalance, transactionType, itemSku, customFields?)` | Economy [47][52] |
| `LogFunnelStepEvent(player, funnelName, funnelSessionId, step, stepName, customFields?)` | Funnels [47][51] |
| `LogOnboardingFunnelStepEvent(player, step, stepName, customFields?)` | Funnels (onboarding) [47] |
| `LogProgressionEvent` / `LogProgressionStartEvent` / `CompleteEvent` / `FailEvent` | Not shown in any chart yet [47] |
| `GetPlayerSegmentsAsync(player)` | Runtime buckets: payer status, tenure, engagement, acquisition source. Cached per server session [47] |

- `FireCustomEvent`, `FireEvent`, `FireInGameEconomyEvent`, `FireLogEvent`, `FirePlayerProgressionEvent` are legacy. Do not use [47].

### 9.2 Limits [48][49][50][51]

| Limit | Value |
|---|---|
| Requests | 120 + 20 x CCU per minute, all methods combined |
| Custom event names | 100 |
| Funnels | 10, steps 1 to 100 |
| Economy currencies | 10 per the limits table. The `LogEconomyEvent` reference says 5 [47][48]. Plan for 5 |
| Transaction types / item SKUs | Over 20 / over 100 grouped as "Other" |
| Custom fields | 3 (`Enum.AnalyticsCustomFieldKeys.CustomField01..03.Name`), string values only |
| Custom field combinations | Over 8,000 grouped as "Other" |
| Recurring funnel sessions | Last 10 `funnelSessionId` values per user per funnel |
| Retention | Rolls off 90 days after last data |

- Server only, published games only. Nothing logs from Studio or clients [49][52].
- Charts populate in about 24 hours. Use **View Events** for near real-time validation [48].
- Log after success, not on attempt [48].
- Put variety in custom fields, not event names (`PlantSeed` + field `Plant - Cabbage`) [49].
- Batch counts into values (`ZombiesKilled`, 10) to stay under the rate limit [49].

### 9.3 Roblox Experiments (first-party A/B)

- In-game experiments vary **Config** values. Matchmaking experiments vary matchmaking configs (one at a time) [53].
- Up to 2 variants plus control. 14 to 60 days. Percent rollout and audience targeting [53].
- Read with `ConfigService:GetConfigForPlayerAsync(player)` then `snapshot:GetValue(key)`. The first `GetValue` enrolls the player for that key. `GetConfigAsync` ignores experiments [53].
- Call `GetValue` only at the moment of exposure, or you dilute the test [53].
- Metrics: D1, D7, playtime, ARPU, ARPPU, payer conversion, session time. Up to 3 custom metrics from your custom, economy, or funnel events [53].
- Early harm checks every 5 minutes for 24 h. Sample ratio mismatch alerts. Config key locks while running [53].
- Targeting is evaluated per session. Persist the assignment in the profile if continuity matters [53].
- Config limits: string or JSON up to 100,000 characters, 100 conditions per game, 20 per key. Publishes reach servers in about 15 s to 1 min [54].

### 9.4 DIY bucketing (when you need more than Experiments offers)

```lua
--!strict
-- Stable 32-bit FNV-1a. Exact in doubles: multiply split as 2^24 + 403.
local function fnv1a(s: string): number
	local h = 2166136261
	for i = 1, #s do
		h = bit32.bxor(h, string.byte(s, i))
		h = (bit32.lshift(h, 24) + h * 403) % 4294967296
	end
	return h
end

-- Returns a variant name. weights sum to 10000 (basis points).
local function assign(userId: number, experiment: string, variants: { { name: string, weight: number } }): string
	local bucket = fnv1a(`{experiment}:{userId}`) % 10000
	local acc = 0
	for _, v in variants do
		acc += v.weight
		if bucket < acc then return v.name end
	end
	return variants[1].name
end
```

- Salt with the experiment name so tests are independent. Never reuse a salt after changing weights.
- Store `{experiment, variant, assignedAt}` in the profile on first exposure. Use the stored value afterward.
- Log exposure once: `LogCustomEvent(player, "ExpExposure", 1, {[CustomField01] = "Exp - shop_v2", [CustomField02] = "Var - B"})`. Watch the 8,000 combination cap.

## 10. Never do this

- Never grant a developer product in `PromptProductPurchaseFinished` or from a RemoteEvent [28].
- Never return `PurchaseGranted` before the grant and its `PurchaseId` are durably saved together [16][27].
- Never keep purchase history in a separate data store from the currency it grants. They cannot commit atomically.
- Never leave `ProcessReceipt` unset while selling products. Receipts auto-acknowledge and are gone [27].
- Never set `ProcessReceipt` in two scripts. Only one wins.
- Never `SetAsync` player data that another server might hold. Use a session lock and `UpdateAsync` [4][12].
- Never treat a pcall failure on a write as "nothing happened". The write may have landed [1].
- Never retry writes to one key out of order or in parallel [6][12].
- Never save default or fallback data over a profile that failed to load. Kick instead [12].
- Never write `profile.Data` after the session ends or across a yield without re-checking `IsActive()` [15].
- Never delete unknown keys during load or migration. Older servers and future fields depend on them.
- Never hard-code Robux prices in UI. Plus discounts and Managed Pricing change them per player [35][39].
- Never rely on MessagingService for anything that must arrive [25].
- Never use a MemoryStore lease lock as the only guard on a currency or item transfer.
- Never call `GetPolicyInfoForPlayerAsync` per prompt, and never default to "allowed" on error [43].
- Never run unthrottled Open Cloud batch jobs during peak. They share the live budget since July 29, 2026 [11].

## Sources

[1] Data store error codes and limits - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits - checked 2026-11-03
[2] DataStoreService class reference - https://create.roblox.com/docs/reference/engine/classes/DataStoreService - checked 2026-11-03
[3] DataStoreRequestType enum - https://create.roblox.com/docs/reference/engine/enums/DataStoreRequestType - checked 2026-11-03
[4] GlobalDataStore class reference - https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore - checked 2026-11-03
[5] Data store versioning, listing, and caching - https://create.roblox.com/docs/cloud-services/data-stores/versioning-listing-and-caching - checked 2026-11-03
[6] Best practices for data stores - https://create.roblox.com/docs/cloud-services/data-stores/best-practices - checked 2026-11-03
[7] Data store observability - https://create.roblox.com/docs/cloud-services/data-stores/observability - checked 2026-11-03
[8] Data Stores Manager - https://create.roblox.com/docs/cloud-services/data-stores/data-stores-manager - checked 2026-11-03
[9] Data store right to be forgotten (RTBF) - https://create.roblox.com/docs/cloud-services/data-stores/right-to-be-forgotten - checked 2026-11-03
[10] Extended Services for Data Stores is now available (DevForum, posted 2026-03-09, updated 2026-04-09) - https://devforum.roblox.com/t/extended-services-for-data-stores-is-now-available/4504347 - checked 2026-11-03
[11] Unifying Data Stores Open Cloud and Game APIs, and Increasing Storage Limits (DevForum, posted 2026-07-15, live 2026-07-29) - https://devforum.roblox.com/t/unifying-data-stores-open-cloud-and-game-apis-and-increasing-storage-limits/4739240 - checked 2026-11-03
[12] Implement player data and purchasing systems - https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing - checked 2026-11-03
[13] DataModel class reference (BindToClose) - https://create.roblox.com/docs/reference/engine/classes/DataModel - checked 2026-11-03
[14] ProfileStore repository and wally.toml - https://github.com/MadStudioRoblox/ProfileStore - checked 2026-11-03
[15] ProfileStore.luau source (v1.0.3) - https://github.com/MadStudioRoblox/ProfileStore/blob/main/ProfileStore.luau - checked 2026-11-03
[16] ProfileStore docs: Developer Products - https://github.com/MadStudioRoblox/ProfileStore/blob/main/docs/devproducts/index.md - checked 2026-11-03
[17] ProfileService README - https://github.com/MadStudioRoblox/ProfileService - checked 2026-11-03
[18] Lapis repository - https://github.com/nezuo/lapis - checked 2026-11-03
[19] Memory stores - https://create.roblox.com/docs/cloud-services/memory-stores - checked 2026-11-03
[20] Memory store sorted map - https://create.roblox.com/docs/cloud-services/memory-stores/sorted-map - checked 2026-11-03
[21] Memory store queue - https://create.roblox.com/docs/cloud-services/memory-stores/queue - checked 2026-11-03
[22] Memory store hash map - https://create.roblox.com/docs/cloud-services/memory-stores/hash-map - checked 2026-11-03
[23] MemoryStoreSortedMap class reference - https://create.roblox.com/docs/reference/engine/classes/MemoryStoreSortedMap - checked 2026-11-03
[24] MemoryStoreQueue class reference - https://create.roblox.com/docs/reference/engine/classes/MemoryStoreQueue - checked 2026-11-03
[25] MessagingService class reference - https://create.roblox.com/docs/reference/engine/classes/MessagingService - checked 2026-11-03
[26] Cross-server messaging - https://create.roblox.com/docs/cloud-services/cross-server-messaging - checked 2026-11-03
[27] MarketplaceService class reference (ProcessReceipt, BindReceiptHandler, UserOwnsGamePassAsync, GetUserSubscriptionStatusAsync) - https://create.roblox.com/docs/reference/engine/classes/MarketplaceService - checked 2026-11-03
[28] Developer Products - https://create.roblox.com/docs/production/monetization/developer-products - checked 2026-11-03
[29] ProductPurchaseChannel enum - https://create.roblox.com/docs/reference/engine/enums/ProductPurchaseChannel - checked 2026-11-03
[30] ReceiptType enum - https://create.roblox.com/docs/reference/engine/enums/ReceiptType - checked 2026-11-03
[31] ReceiptDecision enum - https://create.roblox.com/docs/reference/engine/enums/ReceiptDecision - checked 2026-11-03
[32] Robux transfers - https://create.roblox.com/docs/production/monetization/robux-transfers - checked 2026-11-03
[33] Passes - https://create.roblox.com/docs/production/monetization/passes - checked 2026-11-03
[34] Subscriptions - https://create.roblox.com/docs/production/monetization/subscriptions - checked 2026-11-03
[35] Roblox Plus (creator docs) - https://create.roblox.com/docs/production/monetization/roblox-plus - checked 2026-11-03
[36] Introducing Roblox Plus (DevForum; launch date via search summary, full text not fetched) - https://devforum.roblox.com/t/introducing-roblox-plus/4567894 - checked 2026-11-03
[37] Engagement-based payouts (deprecated notice) - https://create.roblox.com/docs/production/monetization/engagement-based-payouts - checked 2026-11-03
[38] Creator Rewards - https://create.roblox.com/docs/creator-rewards - checked 2026-11-03
[39] Managed pricing - https://create.roblox.com/docs/production/monetization/managed-pricing - checked 2026-11-03
[40] Price optimization - https://create.roblox.com/docs/production/monetization/price-optimization - checked 2026-11-03
[41] Regional pricing - https://create.roblox.com/docs/production/monetization/regional-pricing - checked 2026-11-03
[42] Commerce products - https://create.roblox.com/docs/production/monetization/commerce-products - checked 2026-11-03
[43] PolicyService class reference - https://create.roblox.com/docs/reference/engine/classes/PolicyService - checked 2026-11-03
[44] AdService class reference - https://create.roblox.com/docs/reference/engine/classes/AdService - checked 2026-11-03
[45] Rewarded video ads - https://create.roblox.com/docs/production/promotion/rewarded-video-ads - checked 2026-11-03
[46] Immersive ads - https://create.roblox.com/docs/production/monetization/immersive-ads - checked 2026-11-03
[47] AnalyticsService class reference - https://create.roblox.com/docs/reference/engine/classes/AnalyticsService - checked 2026-11-03
[48] Analytics event types and limits - https://create.roblox.com/docs/production/analytics/event-types - checked 2026-11-03
[49] Custom events - https://create.roblox.com/docs/production/analytics/custom-events - checked 2026-11-03
[50] Custom fields - https://create.roblox.com/docs/production/analytics/custom-fields - checked 2026-11-03
[51] Funnel events - https://create.roblox.com/docs/production/analytics/funnel-events - checked 2026-11-03
[52] Economy events - https://create.roblox.com/docs/production/analytics/economy-events - checked 2026-11-03
[53] Experiments - https://create.roblox.com/docs/production/experiments - checked 2026-11-03
[54] Configs - https://create.roblox.com/docs/production/configs - checked 2026-11-03
