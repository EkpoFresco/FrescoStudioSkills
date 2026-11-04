# Roblox Implementation Reference

Last checked: 2026-11-03. Sources at bottom.

Read by: luau-architect, server-programmer, client-ui-programmer, exploit-tester, code-optimizer.
Related: [implementation-data.md](implementation-data.md) (DataStores, MemoryStore, MessagingService, monetization, ProcessReceipt, PolicyService, ads, AnalyticsService), [code-quality.md](code-quality.md) (lint, style, review), [studio-mcp-tools.md](studio-mcp-tools.md) (Studio MCP tools).

## TL;DR for agents

- Write every new script as `--!strict`. The New Type Solver left beta on 2025-11-20. Strict-mode places stay on the old solver unless `UseNewLuauTypeSolver` is Enabled. The old solver is available "through 2026" [1].
- Native codegen (`--!native`, `@native`) runs on servers and on Android clients only. Use `@native` on hot functions, not `--!native` on whole scripts. Native code has a per-game memory cap [6][7].
- Server is the source of truth. Exploiters decompile all replicated code, fire any remote with any args at any rate, own their character physics, and trigger ProximityPrompts and ClickDetectors from any distance [16][15].
- Validate every remote: type, `math.isfinite`, range, ownership, distance, cooldown, then rate limit (token bucket per player per remote) [15][7].
- Server Authority shipped for all games on 2026-07-09 (opt-in, `Workspace.AuthorityMode = Server`). Use it for competitive movement, vehicles, sports. It requires StreamingEnabled, Deferred signals, IAS, fixed simulation, and Next Generation Replication [27][26].
- Remotes: RemoteEvent is reliable and ordered. UnreliableRemoteEvent drops payloads over 1000 bytes and is unordered. Client to server is capped at about 500 req/s per client, shared per remote type. Never `InvokeClient` [12][13][14].
- Networking default: plain typed wrappers over RemoteEvents for small games, Blink (active, v0.18.9 Sep 2026) for bandwidth-heavy games. Knit, Red, and the original Matter are archived [39][38][43].
- StreamingEnabled is default for new places. Client code must tolerate missing parts: use `WaitForChild` with timeouts, CollectionService tags, and `Persistent` models only when unavoidable. String `require` does not wait [29][9].
- Ban flow: server heuristics with a suspicion score, then `Players:BanAsync` (up to 50 UserIds, alt-account detection on by default, optional 24 h desktop `ApplyDeviceBlock`) [18][22][23].
- New 2026 security levers: Device Trust API (`Player.DeviceTrustLevel`, 2026-10-27), Creator Store script sandboxing (2026-05-13), honeypot remotes [20][21][25][18].
- Performance: 16.67 ms frame budget at 60 FPS, server heartbeat capped at 60. About 65% of players are on Android and about 60% of those devices have 2 to 4 GB RAM. Test on a low-end baseline device [32][33][34].
- UI: tween on the client only, `ResetOnSpawn = false` for persistent HUDs, UI Styling (StyleSheets) is fully released (2026-01-20). Pick React (official `roblox/react`) for large data-driven UI, Vide or Fusion for lighter reactive UI [35][37][45].

## 1. Luau

### 1.1 Type modes and solver status

| Item | Status (2026-11-03) | Source |
|---|---|---|
| `--!strict` | Checks all inferred and annotated types. Our default. | [2] |
| `--!nonstrict` | Redesigned nonstrict is the default for everyone. Reports definite runtime errors and lint-style warnings. New templates set `LuauTypeCheckMode` to Nonstrict. | [1] |
| `--!nocheck` | No checking. Use only for generated or vendored code. | [2] |
| New Type Solver | General release 2025-11-20. On by default for nocheck/nonstrict. Strict users opt in with `Workspace.UseNewLuauTypeSolver = Enabled` (applies to everyone editing the place). Beta toggle removed 2026-01-07. Old solver "through 2026", property kept at least a year. | [1] |
| Type functions | New solver only. `type function name(t) ... end`, runs at analysis time with the `types` library. | [1][3] |
| Read-only props, better refinements, relaxed casts | Shipped with new solver. | [1] |
| Explicit instantiation `f<<T>>(x)` | Documented on luau.org. UNVERIFIED in Studio: test in a `--!strict` script with the new solver on. | [4] |
| `if local` / `if const` | Studio Beta since 2026-10-06 (Beta Features: "If Local/Const Bindings"). Single name, single value only. Do NOT ship until full release. | [11] |

Agent rule: set `UseNewLuauTypeSolver = Enabled` in every new place, put `--!strict` on line 1 of every file. Note: a place-level property may lag the 2026 old-solver removal. Re-check [1] each quarter.

### 1.2 Exported types and module layout

```luau
--!strict
-- ReplicatedStorage/Shared/Types.luau
export type ItemId = string
export type InventoryEntry = { id: ItemId, count: number }
export type Inventory = { [ItemId]: InventoryEntry }
return {}
```

```luau
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)
local function total(inv: Types.Inventory): number
	local n = 0
	for _, entry in inv do
		n += entry.count
	end
	return n
end
```

- `require` caches: one return value per module per side (client and server get separate copies) [9][10].
- Circular requires error with "Requested module was required recursively" [10]. Break cycles by moving shared types into a types-only module.
- Require-by-string: `./` starts at `script.Parent`, `../` at `script.Parent.Parent`, `@self/` at `script`, `@game/` at `game` [9]. It is non-blocking: it throws if the module is not there yet [9]. On the client, prefer `WaitForChild` paths for anything in ReplicatedStorage that might replicate late.

### 1.3 Typed OOP class (copy this shape)

```luau
--!strict
local Account = {}
Account.__index = Account

type AccountData = { name: string, balance: number }
export type Account = typeof(setmetatable({} :: AccountData, Account))

function Account.new(name: string, balance: number): Account
	return setmetatable({ name = name, balance = balance }, Account)
end

function Account.deposit(self: Account, amount: number)
	self.balance += amount
end

return Account
```

The explicit `self: Account` annotation is still required for methods [5]. New solver alternative: `setmetatable<AccountData, typeof(Account)>` [5].

### 1.4 Typing Instances and remotes

```luau
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BuyItem = Remotes:WaitForChild("BuyItem") :: RemoteEvent

-- Server: treat every client arg as unknown, then refine.
BuyItem.OnServerEvent:Connect(function(player: Player, itemId: unknown, qty: unknown)
	if typeof(itemId) ~= "string" or typeof(qty) ~= "number" then
		return
	end
	-- itemId: string, qty: number from here on
end)
```

- `WaitForChild` and `FindFirstChild` return `Instance?` / `Instance`. Cast with `::` only after you know the class, or refine with `:IsA("Part")` [2].
- Never annotate remote args with concrete types and skip runtime checks. Types are not enforced over the network [38].

### 1.5 Common type errors and fixes

| Error (paraphrased) | Cause | Fix |
|---|---|---|
| `Instance` cannot be converted to `Part` | `FindFirstChild` returns base type | `if x and x:IsA("Part") then` or `FindFirstChildWhichIsA("Part")` |
| Value of type `T?` could be nil | Optional not refined | `if v then`, `assert(v)`, or early return [5] |
| Key not found in table type | Sealed table: annotated or returned tables cannot gain keys | Declare the field in the type, or build the full literal at once |
| `self` has unknown field | Methods do not share inferred `self` | Annotate `self: Class` as in 1.3 [5] |
| Generic cannot be inferred | No argument mentions `T` | Annotate the result local, or explicit instantiation (UNVERIFIED in Studio) [4] |
| `any` spreads through code | Untyped `require` of a dynamic Instance, or remote args | Cast the module result to a declared type; use `unknown` for remote args |

Refinements that narrow: truthy test, `type(x) == "number"`, `typeof(x) == "Instance"`, equality to a singleton, `assert`, composed with `and/or/not` [5].

### 1.6 Native code generation and `--!optimize`

- Enable per script with `--!native` or per function with `@native`. No automatic enabling yet [6].
- Runs on server scripts and Android clients only (Android added in 2025) [6][7]. On iOS, desktop, and console clients the attribute is ignored and code runs in the interpreter.
- Helps: math-heavy loops, `buffer` work, functions called every frame. Little gain on top-level code that runs once [6].
- Costs: extra server startup time, extra memory, and a per-game cap on native code size. Past the cap, code runs non-natively [6].
- Deopts: `getfenv`/`setfenv`, builtins called with wrong types, wrong-typed args to annotated functions [6].
- Annotate argument types. A `Vector3` annotation gets vector-specialized code. Unannotated args are assumed to be tables [6].
- Verify: Script Profiler shows `<native>` on native frames. Run `debug.dumpcodesize()` in the Command Bar (server view) for size and the cap [6].
- Hard limits: 64K instructions per block, 32K blocks per function, 1M instructions per script [6].

```luau
--!strict
@native
local function stepParticles(pos: { Vector3 }, vel: { Vector3 }, dt: number)
	for i = 1, #pos do
		pos[i] += vel[i] * dt
	end
end
```

`--!optimize`: UNVERIFIED as of this check. Common knowledge: live servers and clients compile at level 2 (inlining), Studio at level 1, and `--!optimize 2` forces level 2 in Studio for profiling. Verify on the Luau compiler options page on luau.org before relying on it. Do not ship `--!optimize 0`.

### 1.7 Performance idioms

These are standard Luau idioms. The 2025 compiler items are from [7]; the rest are UNVERIFIED as a group (verify against luau.org "How we make Luau fast").

- Cache services and hot lookups in locals at module scope (`local Players = game:GetService("Players")`).
- Pre-size arrays: `table.create(n)` or `table.create(n, 0)`.
- Build strings with `table.concat(parts)` or `buffer`, not `..` in a loop.
- Use generalized iteration: `for k, v in t do`. Avoid `pairs` / `ipairs` wrappers in hot code only if profiling shows a cost.
- Do not create closures inside per-frame loops. Hoist functions out and pass state as arguments.
- Use `math.isnan`, `math.isinf`, `math.isfinite`, `math.lerp`, `math.map` (added 2025) [7].
- `buffer` with `buffer.readbits` / `writebits` for packed data (added 2025) [7]. Native code uses integer CPU ops on buffer and `bit32` math [7].
- Constant folding now covers `string.char`, `string.sub`, concatenation, and interpolation of constants [7].
- Avoid repeated Instance property reads in loops. Read once, store, overwrite when it changes [32].

```luau
--!strict
-- Pack an entity update: u16 id + 3 x f32 = 14 bytes
local function encode(id: number, pos: Vector3): buffer
	local b = buffer.create(14)
	buffer.writeu16(b, 0, id)
	buffer.writef32(b, 2, pos.X)
	buffer.writef32(b, 6, pos.Y)
	buffer.writef32(b, 10, pos.Z)
	return b
end
```

### 1.8 Parallel Luau

- Scripts under an `Actor` can run in parallel. They still run serially until `task.desynchronize()` or `ConnectParallel` [8].
- Scripts in the same Actor run serially relative to each other. Use multiple Actors; more Actors than cores helps load balancing [8].
- Most DataModel writes are unsafe in parallel. Check each API's thread safety tag (Unsafe, Read Parallel, Local Safe, Safe). Untagged means Unsafe [8].
- `require()` is not allowed in a desynchronized phase. Require in serial first [8].
- Communication: `Actor:SendMessage` / `BindToMessageParallel`, `SharedTable` (shared, atomic updates, cheap clone), or DataModel attributes (forces syncs) [8].
- Worth it for: server hit validation raycasts, procedural generation, pathfinding batches, large pure-math jobs. Not worth it for: small per-frame logic, anything that mostly writes Instances [8].

```luau
--!strict
local RunService = game:GetService("RunService")
RunService.Heartbeat:ConnectParallel(function(dt: number)
	local results = computeTargets(dt) -- pure math, raycasts (Read Parallel)
	task.synchronize()
	applyResults(results)              -- Instance writes, serial
end)
```

## 2. Architecture

### 2.1 Client/server boundary

| Container | Replicates to client | Use for |
|---|---|---|
| `ServerScriptService` | No | All server logic, services, secrets [16] |
| `ServerStorage` | No | Server-only assets, cloned on demand [32] |
| `ReplicatedStorage` | Yes, all of it, before join completes | Shared modules, remotes, assets every client needs now [35] |
| `ReplicatedFirst` | Yes, first | Loading screen only. Keep lean [35] |
| `Workspace` | Yes (streamed if StreamingEnabled) | World [29] |
| `StarterPlayerScripts` / `StarterGui` | Copied to each client | Client controllers, UI |

- Anything in ReplicatedStorage can be decompiled, including ModuleScripts that never run on the client [16].
- Client-created Instances do not replicate to the server. Server property changes replicate to all clients. Remote args that reference Instances the other side cannot see arrive as `nil` [12].
- Remote tables are copied, metatables are dropped, non-string keys become strings, functions become `nil`, mixed tables and `nil` holes are unsafe [12].

### 2.2 Module layout (default)

```
src/
  server/            -> ServerScriptService
    Main.server.luau   (single entry point)
    Services/          (PlayerDataService, CombatService, ...)
  client/            -> StarterPlayer.StarterPlayerScripts
    Main.client.luau
    Controllers/       (InputController, HudController, ...)
  shared/            -> ReplicatedStorage.Shared
    Types.luau, Config/, Net/ (remote definitions), Util/
```

### 2.3 Single entry point vs many scripts

| Choice | Pros | Cons |
|---|---|---|
| Single script per side + ModuleScripts | Deterministic load order, explicit Init/Start, one place to wire dependencies, easy to test modules | One error in Init can halt everything (wrap each in `pcall`) |
| Many Scripts | Isolation of failures, simple for small games | Race conditions, implicit order, duplicated setup, `WaitForChild` sprawl |

Default: single entry point per side. Use separate Scripts only for Actors (Parallel Luau) and Server Authority simulation scripts [8][26].

### 2.4 Service/controller lifecycle (plain modules)

```luau
--!strict
-- ServerScriptService/Main.server.luau
type Service = { Init: ((Service) -> ())?, Start: ((Service) -> ())? }
local services: { [string]: Service } = {}

for _, m in script.Parent.Services:GetChildren() do
	if m:IsA("ModuleScript") then
		services[m.Name] = (require :: any)(m) :: Service
	end
end
for name, s in services do -- Init: sync, no yields, no cross-service calls
	if s.Init then
		local ok, err = pcall(s.Init, s)
		if not ok then warn(`[Init] {name}: {err}`) end
	end
end
for _, s in services do -- Start: may yield, may call other services
	if s.Start then task.spawn(s.Start, s) end
end
```

Rules: `Init` must not yield. `Start` may. Services require each other directly by module path; no service locator magic.

### 2.5 Frameworks (status checked via GitHub, 2026-11-03)

| Framework | Status | Honest take |
|---|---|---|
| Knit | Archived (last push 2024-07). Author: cannot benefit from types [38][39] | Do not start new projects on it. Fine to maintain. |
| Flamework (roblox-ts) | `rbxts-flamework/core` last release v1.2.3 (2024-06), last push 2025-09. roblox-ts active (push 2026-10) [39] | Only if the team writes TypeScript. Low release cadence. |
| Matter | Original archived; community fork `matter-ecs/matter` (0.8.4) [40] | Prefer JECS for new ECS work. |
| JECS | Active, v0.11.0 (2026-03), push 2026-10 [39] | Best ECS choice for heavy simulation (many entities). Overkill for typical UI/economy games. |
| ECR | Active, push 2026-09 [39] | Solid, smaller community than JECS. |
| Plain modules | Always available | Default. Matches Knit's own archival advice [38]. |

### 2.6 Networking libraries

| Library | Type | Status | Notes |
|---|---|---|---|
| Blink | IDL compiler, buffers | Active, v0.18.9 (2026-09-19) [39] | Generates typed code, validates client data on receive [43]. Recommended for bandwidth-heavy games. |
| Zap | IDL compiler, buffers | Rewrite in progress; 0.6.x maintained (v0.6.29, 2026-06) [42][39] | Good, but pin 0.6.x until the rewrite ships. |
| ByteNet | Runtime schema, buffers | Low activity, last push 2025-08 [39] | Acceptable, not preferred. |
| Red | Runtime | Archived 2024-02 [39] | Do not use. |
| Warp | Runtime, optional schema | Active, push 2026-10 [39] | Small community (35 stars). |
| Packet | Runtime, buffers (Suphi) | DevForum distributed [44] | User benchmarks: beats ByteNet, behind Blink/Zap. Had a thread-resume vulnerability fixed in v1.1 [44]. Version status UNVERIFIED: check the thread's first post. |
| BridgeNet2 | Runtime | README says use ByteNet instead [41] | Do not use. |

Every library is a wrapper over RemoteEvent/UnreliableRemoteEvent. None replaces server validation of values (ranges, ownership) [38].

## 3. Networking

### 3.1 Remote types

| Remote | Delivery | Ordering | Limits | Use |
|---|---|---|---|---|
| `RemoteEvent` | Reliable, retransmitted | Ordered, including across RemoteEvent instances | About 500 req/s per client shared by all RemoteEvents; excess is delayed [13][12] | Actions, state changes |
| `UnreliableRemoteEvent` | May drop | Unordered | Payload over 1000 bytes dropped; excess over rate limit dropped; no handler means dropped [14][12] | Cosmetic, high-rate, latest-wins data (aim, VFX) |
| `RemoteFunction` | Reliable | Not ordered with RemoteEvents | One in-flight invoke per thread [12] | Client to server request/response only |

- Unreliable limit was 900 bytes in older docs; current docs say 1000 bytes [14]. Engine compresses some types (buffers), so pre-checking size is hard [14].
- Add a sequence number or timestamp to unreliable messages and drop stale ones [12].
- Ordering is per handler start, not finish. A yielding handler lets later messages start first [12].
- Never `InvokeClient`: if the client errors, the server errors; if the client never returns, the server yields forever; disconnect throws [12].
- Under Server Authority, remotes are not synced with the simulation timeline (about 40 to 50 ms skew). Use attributes on predicted instances instead [27][26].

### 3.2 What costs bandwidth

- Frequent remotes, sending whole tables instead of deltas, replicating every frame, and server-side tweens (replicate every frame) [35].
- Creating or destroying large instance trees on the server, and leftover Animation Editor data in rigs [35].
- Buffers are compressed by the engine and are the cheapest dense format [14].
- User-measured sizes (Packet thread): CFrame about 20 bytes native vs 12 to 18 packed; Instance ref 5 bytes [44]. Treat as indicative.
- Attributes vs ValueObjects replication cost: no official per-byte numbers found. UNVERIFIED. Measure with Studio Settings > Network > "Print Join Size Breakdown" [34] and the MicroProfiler network scopes (`ProcessPackets`, `Allocate Bandwidth and Run Senders`) [35].
- Rule: replicate state on change, not per frame; batch per frame on the server; send IDs, not Instances, when the client can resolve them.

### 3.3 Server validation pattern

```luau
--!strict
local MAX_QTY = 99
local SHOP_RANGE = 12

local function finiteNumber(v: unknown, lo: number, hi: number): number?
	if typeof(v) ~= "number" or not math.isfinite(v) then return nil end
	if v < lo or v > hi or v % 1 ~= 0 then return nil end
	return v
end

BuyItem.OnServerEvent:Connect(function(player: Player, rawId: unknown, rawQty: unknown)
	if not limiter:allow(player) then return end
	if typeof(rawId) ~= "string" or #rawId > 32 then return end
	local item = ItemCatalog[rawId]               -- server-owned data, never client data
	local qty = finiteNumber(rawQty, 1, MAX_QTY)
	if not item or not qty then return end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not (root and root:IsA("BasePart")) then return end
	if (root.Position - ShopPart.Position).Magnitude > SHOP_RANGE then return end
	PurchaseService.tryBuy(player, item, qty)     -- checks funds and mutates atomically
end)
```

- NaN passes `type == "number"` and fails every comparison, so `if v < 0` checks silently pass. Always `math.isfinite` [15][7].
- Clients can send tables shaped like Instances. Never trust `ClassName`/`Value` fields from args; look up server-side data by ID [15].
- Bound string length before any work that scales with length [15].

### 3.4 Rate limiting (token bucket per player per remote)

```luau
--!strict
local Players = game:GetService("Players")
local RateLimiter = {}
RateLimiter.__index = RateLimiter
type Bucket = { tokens: number, last: number }
export type RateLimiter = typeof(setmetatable({} :: {
	capacity: number, refill: number, buckets: { [Player]: Bucket } }, RateLimiter))

function RateLimiter.new(capacity: number, perSecond: number): RateLimiter
	local self = setmetatable({ capacity = capacity, refill = perSecond, buckets = {} }, RateLimiter)
	Players.PlayerRemoving:Connect(function(p) self.buckets[p] = nil end)
	return self
end

function RateLimiter.allow(self: RateLimiter, player: Player): boolean
	local now = os.clock()
	local b = self.buckets[player]
	if not b then b = { tokens = self.capacity, last = now }; self.buckets[player] = b end
	b.tokens = math.min(self.capacity, b.tokens + (now - b.last) * self.refill)
	b.last = now
	if b.tokens < 1 then return false end
	b.tokens -= 1
	return true
end
return RateLimiter
```

One limiter per remote (`RateLimiter.new(5, 2)` = burst 5, 2/s). Clear buckets on leave to avoid leaks [15]. Apply the same to ProximityPrompt, ClickDetector, DragDetector handlers [15].

### 3.5 StreamingEnabled and client code

- Default on for new places; not scriptable [29].
- Recommended: `ModelStreamingBehavior = Improved`, `StreamingIntegrityMode = PauseOutsideLoadedArea`, `StreamingTargetRadius > StreamingMinRadius` [29].
- `ModelStreamingMode`: `Nonatomic` (default), `Atomic` (descendants arrive together), `Persistent` (always present, sent before `Workspace.PersistentLoaded`), `PersistentPerPlayer` (`Model:AddPersistentPlayer()`). Persistent is for rare cases only [29].
- Streamed-out instances are parented to `nil`; removal signals fire on the parent, not the instance [29].
- Client physics (and Server Authority prediction) only runs in streamed areas, even for Persistent models [29].
- Extra foci: `Player:AddReplicationFocus()`. Each moving focus costs server work like a player [29]. `Player:RequestStreamAroundAsync()` to pre-fetch before teleports [29].
- New 2026: Predictive Streaming (`Workspace.PredictiveStreamingMode`, 2026-07-29), Frustum Streaming (`Player.FrustumStreaming`, server-set, 2026-09-29), SLIM LOD (`Model.LevelOfDetail = SLIM`, `Workspace.EnableSLIMAvatars`, needs published place + Team Create) [29][31][30][37].
- Client code pattern: bind behavior with `CollectionService:GetInstanceAddedSignal(tag)` plus `GetTagged` at start, so parts that stream in later get wired. Use `WaitForChild(name, timeout)` and handle `nil`.

## 4. Exploit prevention

### 4.1 What exploiters can do in 2026

- Decompile any replicated LocalScript or ModuleScript [16].
- Fire or invoke any remote at any rate with arbitrary args (only the Player arg is trusted) [16].
- Own and move their character and nearby unanchored parts: teleport, fly, speed, fling, send NaN/inf CFrames and velocities, suppress or fake `Touched` [17].
- Set WalkSpeed locally without firing any events [17].
- Fire ProximityPrompt hold events with no distance check (only `Triggered` is distance-checked), fire ClickDetector events with no server checks at all [15].
- Change anything in their local DataModel silently [16].

Hyperion (Byfron, acquired Oct 2022) raises the cost of injecting on desktop [50]. It does not stop: external tools, network-level abuse, or any logic bug you ship. Community trackers dated Aug 2026 still list working executors (UNVERIFIED, not linked; verify via the Roblox security docs, not executor sites). Design as if every client is hostile [16].

### 4.2 Platform levers (2025 to 2026)

| Lever | What it does | Date |
|---|---|---|
| Server Authority | Server simulates, clients send inputs only; stops speed, fly, wall clip, fling [16][28]. Attribute limits: first 64 per instance, name and string value max 50 chars [26]. Server CPU rises [27]. | Full release 2026-07-09 [27] |
| Device Trust API | `Player.DeviceTrustLevel` (Pending, Unknown, None, Standard, Full), `IntegrityService.EvaluatePlayerDeviceTrust` to Accept/Reject. Verified on Android, Chromebook, Quest; web is `None`; iOS, macOS, Windows, consoles report `Unknown` ("coming soon"). Read on the server only. Always `Pending` in Studio [20]. | 2026-10-27 [21] |
| Ban API | `Players:BanAsync` / `UnbanAsync` [22] | Device block added 2026-06-04 [23] |
| Script capabilities sandbox | Creator Store inserts are sandboxed; blocks `require(id)`, `LoadAsset` and other high-risk capabilities [25] | 2026-05-13 [25] |

Device Trust policy: gate trading, ranked, AFK rewards on `Standard`/`Full`; treat `Pending` as untrusted; decide `Unknown` per feature (most players are `Unknown` until iOS/Windows ship) [20].

### 4.3 Sanity checks

- Movement (without Server Authority): compare server-side positions over time on the XZ plane, use a leaky bucket accumulator for bursts, exempt legit teleports, account for latency [17].
- Distance: check the server-side character position against the target with latency tolerance [15].
- Cooldowns and ammo: server tracks last-fire time and ammo [15].
- Hits: client sends origin and claimed hit; server checks origin near character, hit near target, no static obstruction (raycast against static geometry only) [15].
- Heuristics: fastest completion time, rate of gain, action cadence (robotic intervals). Combine into a suspicion score; act only on multiple signals [18].
- Defensive design beats detection: sequential checkpoints, server-computed damage, no points for killing fresh spawns [19].

### 4.4 Currency, inventory, duplication

- All balances and inventories live in server memory and DataStore only. Clients get read-only copies [16].
- No yield between "check" and "mutate". A yield (DataStore call, `task.wait`, `InvokeServer`) between them lets spammed remotes double-spend.
- Per-player busy flag for multi-step transactions (purchase, trade, craft). Reject while busy.
- Trades in one server: lock both players, validate both inventories at commit time, apply both sides in one non-yielding block, then save both. Cancel the trade if either player leaves before commit.
- Cross-server and DataStore races (rejoin before save, teleport before save, two servers writing one key): use session locking and `UpdateAsync`. See [implementation-data.md](implementation-data.md).
- Rate-of-gain heuristic on every currency source [18].

```luau
--!strict
local busy: { [Player]: true } = {}
function PurchaseService.tryBuy(player: Player, item: Item, qty: number): boolean
	if busy[player] then return false end
	busy[player] = true
	local data = PlayerData.get(player)            -- in-memory, no yield
	local cost = item.price * qty
	local ok = data ~= nil and data.coins >= cost
	if ok and data then
		data.coins -= cost                            -- check and mutate, no yield between
		Inventory.add(data, item.id, qty)
	end
	busy[player] = nil
	return ok
end
```

### 4.5 Honeypots, logging, bans

- Honeypot remote: a plausible remote no legit client script fires. Any traffic is a high-confidence signal: log and kick [18].
- Direction check: track which remotes are server-to-client only; a client firing one is a signal [18].
- Consequence ladder: silent log, quiet mitigation (rubber-band, drop, clamp), feature restriction, then kick/ban. Delay visible consequences so exploiters cannot learn the trigger [18].
- Logging: log rule ID, UserId, values, server JobId. Version your detection rules [18]. Send counts to AnalyticsService (see implementation-data.md).

`Players:BanAsync` config [22]:

| Field | Notes |
|---|---|
| `UserIds` | Required, max 50 |
| `Duration` | Required, seconds, `-1` permanent |
| `DisplayReason` | Required, max 400 chars, text filtered |
| `PrivateReason` | Required, max 1000 chars, not shown to user |
| `ApplyToUniverse` | Default `true` |
| `ExcludeAltAccounts` | Default `false` (alt detection on) |
| `ApplyDeviceBlock` | Default `false`; 24 h block, desktop (Windows/macOS) only; lifted only by `UnbanAsync` [22][23] |

- Bans in Studio and Team Test do not apply to production [22].
- Escalate durations from `GetBanHistoryAsync` and your `PrivateReason` notes [22].
- Roblox platform moderation (separate from your bans) uses multi-signal alt detection; shared IP/Wi-Fi alone does not trigger action. New Creator Hub page: Creations > Game > Safety > Issues and appeals (2026-11-02) [24].

## 5. Performance

### 5.1 Budgets

| Budget | Value | Source |
|---|---|---|
| Frame at 60 FPS | 16.67 ms total | [32] |
| Client FPS cap | 60 default, up to 240 on Windows | [34] |
| Server heartbeat | Capped at 60; check Dev Console > Server Jobs > Heartbeat "Steps Per Sec" | [34] |
| Server memory | `6.25 GiB + 100 MiB x peak players`; keep under 50%; does not shrink when players leave | [34] |
| Client crash rate | Investigate above 2 to 3% | [34] |
| Device mix | Android about 65%; of those about 60% 2 to 4 GB RAM, 35% 4 to 8 GB | [33] |

- No official per-device client memory MB budget. Pick a baseline device (doc examples: Infinix Smart 9, Moto G05, Oppo A18, Fire HD 10 2023) and find the crash point there [33]. Studio memory numbers are inflated (runs client and server) [32].
- New 2026-11-02: `DataModel.ServerLowMemoryWarning` fires on live servers when memory goes high, then every 60 s while high. Use it to destroy debris, unload unused map areas, pause spawning [36].

### 5.2 Tools

| Tool | Open | Use |
|---|---|---|
| Developer Console | `F9` | Memory tab (LuaHeap, InstanceCount, PlaceScriptMemory, GraphicsTexture, Sounds), Server Jobs, Server Stats, Scripts [34][35] |
| MicroProfiler | `Ctrl+Alt+F6` (`Cmd+Opt+F6`) | Per-frame breakdown, client or server; dump on device [33] |
| Performance Stats | `Ctrl+Alt+F7` | FPS, memory, CPU, GPU, ping overlay [34] |
| Debug Stats | `Shift+Ctrl+F1..F5` | Render, network, physics, summary [34] |
| Script Profiler | Studio | Per-function time; `<native>` label [6] |
| Scene Analysis | Studio | Resource usage per instance [34] |
| Network Simulation | `Alt+S` in Studio | Latency, jitter, loss (expanded 2026-06, full release 2026-09-09) [34][37] |
| Performance Dashboard | Creator Hub | Live memory, FPS, heartbeat, crashes [34] |

Dev Console Scripts tab "Activity %" and "Rate/s" columns: UNVERIFIED this pass (verify at create.roblox.com/docs/studio/developer-console). Treat any script above a few percent activity as a profiling target.

```luau
--!strict
debug.profilebegin("Combat.resolveHits") -- shows as a MicroProfiler label
resolveHits(pending)
debug.profileend()
```

Keep labels static strings (no per-call string building). Other relevant 2026 items: LibMP MicroProfiler API (Studio Beta, 2026-06-25), automated profiling with Assistant (2026-06-26) [37].

### 5.3 Script cost

- Prefer events over per-frame work. Spread long jobs over frames with `task.wait()` chunks (100 ms of work once per second = visible stutter) [32].
- Heartbeat, PreSimulation, PostSimulation, PreRender, PreAnimation handlers run every frame: keep them tiny and throttle [35].
- Heavy table ops (deep clone, serialize) are expensive. Do them rarely [35].
- If the server is still CPU-bound after optimizing: Extended Services for Compute [35].

### 5.4 Physics

- Anchor everything that does not need simulation [35].
- Non-colliding decor: `CanCollide = false`, `CanTouch = false`, `CanQuery = false`, and Box or Hull `CollisionFidelity` (collision geometry stays in memory otherwise) [35].
- Small anchored parts: Box fidelity is safe. Large complex meshes: invisible box parts as custom collision [35].
- Adaptive timestepping (default) steps at 60/120/240 Hz; fixed mode forces 240 Hz [35].
- Humanoids are expensive: disable unused `HumanoidStateType`s, use `AnimationController` for static NPCs, play NPC animations on the client, pool NPCs, update `Motor6D.Transform` not `C0/C1` [35].
- Profile scopes: `physicsStepped`, `worldStep`, `stepHumanoid`, `stepAnimation`, `updateInvalidatedFastClusters` (over 4 ms means avatar churn) [35].

### 5.5 Rendering and assets (client)

- Draw calls: identical `MeshContent` plus identical SurfaceAppearance or texture or material instance into one call. Re-uploaded duplicate meshes break instancing [35].
- Texture memory scales with pixels: 1024x1024 is 4x a 512x512 [35]. Use sprite sheets with `ImageRectOffset`/`ImageRectSize` for UI icons [35].
- Avoid partial transparency and layered transparent overdraw [32].
- Keep ReplicatedStorage and ReplicatedFirst lean; do not over-`PreloadAsync` [35].
- Texture Streaming (2025-12-12) and Mesh Streaming (opt-in, 2026-04-27) exist; details UNVERIFIED this pass (see [37] titles) [37].

### 5.6 Cleanup and leaks

- Connections keep their callback and upvalues alive until disconnected or the instance is destroyed [35].
- Remove per-player table entries on `PlayerRemoving` [35].
- Enable `Workspace.PlayerCharacterDestroyBehavior` so players and characters are destroyed on leave [35].
- Watch LuaHeap and InstanceCount growth over a long server session [35].

```luau
--!strict
-- Minimal maid: one cleanup list per owner
local Trove = {}
Trove.__index = Trove
export type Trove = typeof(setmetatable({} :: { items: { RBXScriptConnection | Instance | () -> () } }, Trove))
function Trove.new(): Trove return setmetatable({ items = {} }, Trove) end
function Trove.add<T>(self: Trove, item: T): T
	table.insert(self.items, item :: any)
	return item
end
function Trove.clean(self: Trove)
	for _, it in self.items do
		if typeof(it) == "RBXScriptConnection" then it:Disconnect()
		elseif typeof(it) == "Instance" then it:Destroy()
		elseif type(it) == "function" then it() end
	end
	table.clear(self.items)
end
return Trove
```

## 6. Client UI

### 6.1 Structure

- One `ScreenGui` per layer (HUD, Menus, Modals, Toasts), ordered by `DisplayOrder`.
- Set `ResetOnSpawn = false` on persistent UI so it survives respawn (default is `true`, UNVERIFIED this pass: confirm on the ScreenGui reference). Build UI from a client controller, not from StarterGui clones, when using a UI framework.
- UI Styling: `StyleSheet`, `StyleRule` selectors, tokens and themes via attributes, `StyleLink` to a ScreenGui (one StyleSheet per link) [37]. Full release 2026-01-20; StyleQuery 2026-04-09; UI shadows and per-corner radius 2026-05-14; upgraded UIGradient 2026-09-02 [37].
- Input: Input Action System full release 2026-06-11 (required by Server Authority), Input Action Manager full release 2026-10-29, `GuiButton.SecondaryActivated` 2026-07-06 [37][27].

### 6.2 TweenService patterns

- Tween on the client only. Server tweens replicate every frame and jitter [35].
- Keep one active tween per property per object: cancel the previous tween before starting a new one.
- Reuse `TweenInfo` constants. Prefer tweening a container (CanvasGroup or parent Frame) over many children. CanvasGroup render cost: UNVERIFIED, profile before using many.

```luau
--!strict
local TweenService = game:GetService("TweenService")
local FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local active: { [Instance]: Tween } = {}

local function tweenTo(obj: GuiObject, goal: { [string]: any }, info: TweenInfo?)
	local prev = active[obj]
	if prev then prev:Cancel() end
	local t = TweenService:Create(obj, info or FAST, goal)
	active[obj] = t
	t.Completed:Once(function()
		if active[obj] == t then active[obj] = nil end
	end)
	t:Play()
end
```

### 6.3 UI frameworks

| Option | Status | Pick when |
|---|---|---|
| React (`roblox/react` on Wally, Roblox/react-luau mirror) | Official Roblox port of React 17, bindings for non-render updates [45]. `jsdotlua/react-lua` community build last pushed 2025-05 [39] | Large data-driven UI, team knows React. Our front-end dev default. |
| Fusion | v0.3 (2024-08), last push 2026-02 [47][39] | Reactive state with less boilerplate. Slower release cadence. |
| Vide | Active, 0.4.x, push 2026-10; Solid-inspired, fully typecheckable [46][39] | Small to mid UI, best Luau types, fine-grained reactivity. |
| Roact | Superseded by React (UNVERIFIED formal deprecation date) | Never for new code. |
| Plain Instances + StyleSheets | Engine native [37] | HUDs, few screens, max performance. |

Whatever the framework: no per-frame state updates that re-render trees; use bindings or sources for values that change every frame.

## 7. Default stack (new project, late 2026)

| Layer | Default | Why |
|---|---|---|
| Language | Luau `--!strict`, `UseNewLuauTypeSolver = Enabled` | New solver is GA; type functions and better refinements [1] |
| Sync / tooling | Rojo (active, push 2026-10-31) + luau-lsp (push 2026-11-03); Studio Script Sync as alternative | Git-based workflow. Script Sync full release listed 2026-06-17 [37] but the coding-harness doc still calls it beta: UNVERIFIED, check Studio Beta Features [39] |
| Module layout | `server/`, `client/`, `shared/`, one entry script per side, Init/Start services | Deterministic order, testable modules (2.2 to 2.4) |
| Framework | Plain modules | Knit archived; no framework lock-in [38] |
| ECS (only if many entities) | JECS | Most active ECS [39] |
| Networking | Typed RemoteEvent wrappers + validation; Blink when bandwidth matters | Blink is active and validates on receive [43] |
| Movement security | Server Authority for competitive or physics games; manual checks otherwise | Removes movement exploit class [16][27] |
| Data | See [implementation-data.md](implementation-data.md) | Session locking, UpdateAsync, receipts |
| UI | React (`roblox/react`) for complex UI, plain Instances + StyleSheets for HUD | Official port; engine-native styling [45][37] |
| Streaming | On, Improved model streaming, PauseOutsideLoadedArea, Predictive on | Memory and join time on 2 to 4 GB Android [29][33] |
| Testing | Jest (Roblox/jest-roblox, active 2026-10) for modules; StudioTestService (2025-12-04) and Studio MCP playtests for integration; Lune for pure-Luau offline tests | Official runner plus real play sessions [48][37]. StudioTestService API details UNVERIFIED. |
| Lint / format | See [code-quality.md](code-quality.md) | Owned there |

When to deviate:
- TypeScript team: roblox-ts + Flamework, accept slower Flamework releases.
- Tiny prototype: skip Blink, use raw remotes with the 3.3 validator.
- Mass simulation (thousands of NPCs, bullets): JECS + Parallel Luau Actors + `@native` hot paths + buffer networking.

## UNVERIFIED items (how to verify)

| Item | Verify by |
|---|---|
| `--!optimize` levels (2 live, 1 Studio) | luau.org compiler docs; compare Script Profiler timings with and without the directive |
| `f<<T>>` explicit instantiation in Studio | Write it in a strict script with the new solver; check Script Analysis |
| Attribute vs ValueObject bandwidth | Studio Network stats or MicroProfiler network scopes on a test place |
| Dev Console Scripts tab columns | create.roblox.com/docs/studio/developer-console |
| ScreenGui `ResetOnSpawn` default `true` | ScreenGui class reference |
| Script Sync GA vs beta | Studio > Beta Features list; DevForum topic 4688454 |
| Packet current version | DevForum thread 3573907 first post |
| Executor landscape vs Hyperion | Roblox security docs and DevForum security announcements only |
| CanvasGroup cost, Texture/Mesh Streaming details | MicroProfiler on device; DevForum topics 4144855, 4601232 |
| StudioTestService API | create.roblox.com reference for StudioTestService; DevForum topic 4116257 |

## Sources

[1] General Release: Luau's New Type Solver (2025-11-20) - https://devforum.roblox.com/t/general-release-luaus-new-type-solver/4084991 - checked 2026-11-03
[2] Type checking - https://create.roblox.com/docs/en-us/luau/type-checking - checked 2026-11-03
[3] Type Functions - https://luau.org/types/type-functions - checked 2026-11-03
[4] Generics and Polymorphism - https://luau.org/types/generics - checked 2026-11-03
[5] Object-Oriented Programming (types) and Type Refinements - https://luau.org/types/object-oriented-programs , https://luau.org/types/type-refinements - checked 2026-11-03
[6] Native code generation - https://create.roblox.com/docs/en-us/luau/native-code-gen - checked 2026-11-03
[7] Luau Recap for 2025: Runtime (2025-12-19) - https://luau.org/news/2025-12-19-luau-recap-runtime-2025 - checked 2026-11-03
[8] Parallel Luau - https://create.roblox.com/docs/en-us/scripting/multithreading - checked 2026-11-03
[9] Luau globals (require) - https://create.roblox.com/docs/en-us/reference/engine/globals/LuaGlobals - checked 2026-11-03
[10] Reuse code (ModuleScripts) - https://create.roblox.com/docs/en-us/scripting/module - checked 2026-11-03
[11] [Beta] if local Statements and Expressions (2026-10-06) - https://devforum.roblox.com/t/4918297 - checked 2026-11-03
[12] Remote events and callbacks - https://create.roblox.com/docs/en-us/scripting/events/remote - checked 2026-11-03
[13] RemoteEvent reference (Throttling) - https://create.roblox.com/docs/en-us/reference/engine/classes/RemoteEvent - checked 2026-11-03
[14] UnreliableRemoteEvent reference - https://create.roblox.com/docs/en-us/reference/engine/classes/UnreliableRemoteEvent - checked 2026-11-03
[15] Securing the client-server boundary - https://create.roblox.com/docs/en-us/scripting/security/client-server-boundary - checked 2026-11-03
[16] Security and cheat mitigation tactics - https://create.roblox.com/docs/en-us/scripting/security/security-tactics - checked 2026-11-03
[17] Network ownership, movement validation, and physics - https://create.roblox.com/docs/en-us/scripting/security/network-ownership - checked 2026-11-03 (still says Server Authority "in beta": stale vs [27])
[18] Server-side detection and consequencing - https://create.roblox.com/docs/en-us/scripting/security/server-side-detection - checked 2026-11-03
[19] Defensive design tactics - https://create.roblox.com/docs/en-us/scripting/security/defensive-design - checked 2026-11-03
[20] Device trust - https://create.roblox.com/docs/en-us/scripting/security/device-trust - checked 2026-11-03
[21] Improve Your Game Security with the Device Trust API (2026-10-27) - https://devforum.roblox.com/t/4961129 - checked 2026-11-03 (title and date only)
[22] Players reference (BanAsync, UnbanAsync) - https://create.roblox.com/docs/en-us/reference/engine/classes/Players - checked 2026-11-03
[23] Ban API: New Device Blocking Capability (2026-06-04) - https://devforum.roblox.com/t/4668265 - checked 2026-11-03
[24] Update on Account Bans, Alt Detection, and Appeals (2026-11-02) - https://devforum.roblox.com/t/4972565 - checked 2026-11-03
[25] Protect Your Games with Script Capabilities Sandboxing (2026-05-13) - https://devforum.roblox.com/t/4634642 - checked 2026-11-03
[26] Server authority - https://create.roblox.com/docs/en-us/projects/server-authority - checked 2026-11-03
[27] [Full Release] Ship Fair And Competitive Games with Server Authority (2026-07-09) - https://devforum.roblox.com/t/full-release-ship-fair-and-competitive-games-with-server-authority/4727993 - checked 2026-11-03
[28] Creating responsive, cheat-resistant games with Roblox Server Authority (2026-07-09) - https://about.roblox.com/newsroom/2026/07/creating-responsive-cheat-resistant-games-roblox-server-authority - checked 2026-11-03
[29] Instance streaming - https://create.roblox.com/docs/en-us/workspace/streaming - checked 2026-11-03
[30] SLIM - https://create.roblox.com/docs/en-us/workspace/streaming/slim - checked 2026-11-03
[31] Frustum Streaming - https://create.roblox.com/docs/en-us/workspace/streaming/frustum - checked 2026-11-03
[32] Design for performance - https://create.roblox.com/docs/en-us/performance-optimization/design - checked 2026-11-03
[33] Test on hardware - https://create.roblox.com/docs/en-us/performance-optimization/test-on-hardware - checked 2026-11-03
[34] Identify performance issues - https://create.roblox.com/docs/en-us/performance-optimization/identify - checked 2026-11-03
[35] Improve performance - https://create.roblox.com/docs/en-us/performance-optimization/improve - checked 2026-11-03
[36] Clean Up Server Memory Before Crashes With ServerMemoryWarning (2026-11-02) - https://devforum.roblox.com/t/4972486 - checked 2026-11-03
[37] DevForum Announcements category (titles and dates: UI Styling 2026-01-20, StyleQuery 2026-04-09, Script Sync 2026-06-17, IAS 2026-06-11, Input Action Manager 2026-10-29, Predictive Streaming 2026-07-29, Frustum Streaming 2026-09-29, Network Simulator 2026-09-09, LibMP 2026-06-25, StudioTestService 2025-12-04, Texture Streaming 2025-12-12, Mesh Streaming 2026-04-27) - https://devforum.roblox.com/c/updates/announcements/36 - checked 2026-11-03 (titles only; bodies not read)
[38] Knit ARCHIVAL.md - https://github.com/Sleitnick/Knit/blob/main/ARCHIVAL.md - checked 2026-11-03
[39] GitHub repository metadata (archived flag, last push, latest release) for Knit, Flamework, roblox-ts, Matter, JECS, ECR, Blink, Zap, ByteNet, Red, Warp, BridgeNet2, react-lua, Fusion, Vide, Rojo, luau-lsp, Lune - https://api.github.com/repos/{owner}/{repo} - checked 2026-11-03
[40] evaera/matter README (points to matter-ecs fork) - https://github.com/evaera/matter , https://github.com/matter-ecs/matter - checked 2026-11-03
[41] BridgeNet2 README - https://github.com/ffrostfall/BridgeNet2 - checked 2026-11-03
[42] Zap README - https://github.com/red-blox/zap - checked 2026-11-03
[43] Blink README - https://github.com/1Axen/blink - checked 2026-11-03
[44] Packet - Networking library (DevForum thread) - https://devforum.roblox.com/t/packet-networking-library/3573907 - checked 2026-11-03 (search snippets only)
[45] Roblox/react-luau - https://github.com/Roblox/react-luau - checked 2026-11-03
[46] Vide README - https://github.com/centau/vide - checked 2026-11-03
[47] Fusion releases - https://github.com/dphfox/Fusion/releases - checked 2026-11-03
[48] Roblox/jest-roblox - https://github.com/Roblox/jest-roblox - checked 2026-11-03
[49] Build with a coding harness (Script Sync + MCP) - https://create.roblox.com/docs/en-us/ai/coding-harness - checked 2026-11-03
[50] Welcoming Byfron to Roblox - https://devforum.roblox.com/t/welcoming-byfron-to-roblox/2018233 - checked 2026-11-03 (search snippet only)
