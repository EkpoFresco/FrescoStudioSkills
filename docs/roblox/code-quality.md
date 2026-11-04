# Code Quality and Optimization Playbook (code-optimizer)

Last checked: 2026-11-03. Sources at bottom.

Owner: `code-optimizer`. Used by `/rbx-review`, `/rbx-optimize`, and the story-close gate.
Related: `docs/roblox/implementation.md` (Luau, architecture, networking, exploits, perf basics), `docs/roblox/implementation-data.md` (DataStores, monetization). This file does not repeat them; it adds review rules, tooling, and evidence rules.

## TL;DR for agents

- Every story closes through `code-optimizer`. Verdict is one of `CHANGES REQUIRED`, `NOT ASSESSED`, `APPROVED WITH NOTES`, `APPROVED` (kept from the original review skill [1]).
- Run the three gates on every change: `stylua --check`, `selene`, `luau-lsp analyze` with a Rojo sourcemap and Roblox definitions. All three verified locally on this machine [12].
- `luau-lsp analyze` does NOT download Roblox types. Pass `--definitions:@roblox=<file>` or Roblox globals go unchecked [12].
- New code in `src/shared/**` is `--!strict`. Convert existing files shared modules first, then server, then client.
- No optimization claim without a before/after table: same place, same player count, warmup, N samples, median. Unmeasured claims are `NOT ASSESSED` [3].
- Top leak sources: connections never disconnected, player-keyed tables not cleared on leave, characters and Player objects not destroyed [22]. Use a Trove per lifetime.
- `Destroy()` is the correct disposal; `Parent = nil` is only for temporary removal [38].
- Hot paths: no per-frame table or closure allocation, cache instance refs (FindFirstChild is about 8x slower than a stored reference [38]), use `table.create` when size is known [14].
- Remotes: client to server is about 500 req/s per client, shared across all remotes of a type [34]. Batch. `UnreliableRemoteEvent` drops payloads over 1000 bytes [32].
- DataStores: UpdateAsync costs read and write budget [31]. Autosave on an interval shorter than any session lock, plus on leave and shutdown [30].
- Severity defaults: BLOCKER (exploitable, data loss, crash, leak that grows per player), MAJOR (measurable perf or correctness risk), MINOR, NIT.
- Never refactor and optimize in the same commit. Small commits, playtest before and after.

## 1. What we kept from the original

The engine-generic repo has `/code-review` [1], `/tech-debt` [2], `/perf-profile` [3], `/story-done` [5], coding standards and path rules [4], and commit/push hooks. Kept, adapted for Roblox:

| Original rule | Source | How code-optimizer uses it |
|---|---|---|
| Insufficient input means `NOT ASSESSED`, never a filled-in pass | [1][3] | No profiler data means no perf verdict. Zero files scanned means "no information", not "clean". |
| "Absence of evidence is never evidence of absence" | [1][2] | Every scan reports its denominator (files scanned, remotes found). |
| Verify every specialist finding: file and line, evidence, VERIFIED or UNVERIFIED | [1] | Each finding cites `path:line` plus the triggering input. Unverified findings are labeled or dropped. |
| Verdict order: CHANGES REQUIRED > NOT ASSESSED > APPROVED WITH SUGGESTIONS > APPROVED | [1] | Same order. A skipped check never approves. |
| Severity tiers: ARCHITECTURAL VIOLATION (blocking), DRIFT (warning), MINOR (info) | [1] | Mapped to BLOCKER / MAJOR / MINOR / NIT (Section 9). |
| "Never optimize without measuring first"; "Static analysis identifies candidates; runtime profiling confirms" | [3] | Static findings are labeled `candidate`. Only measured ones are `confirmed`. |
| Budgets come from config; a metric with no budget is `NOT ASSESSED` | [3] | Budgets live in the project's `.rbx-studio/` config, not prose. |
| Reports written to disk so runs can be compared | [3] | `/rbx-optimize` writes `production/polish/optimize-<date>.md`. |
| Profile before AND after every optimization, document the numbers | [4] | Section 8 protocol. |
| Zero allocations in hot paths | [4] | Section 5. |
| Server authoritative; validate packet sizes and field ranges; per-message bandwidth budget | [4] | Section 6 and checklist SEC items. |
| Tech debt register: ID, category, effort S/M/L/XL, impact, priority, status, "why accepted" | [2] | Kept as is; score changed to impact x risk / effort (Section 10). |
| "A parse check is not a run": player-visible changes are launched and observed | [4] | Lint passing is not done. Playtest via Studio MCP. |
| Story close: criteria table, evidence, deviations, "Reviewed by" never blank | [5] | `code-optimizer` fills "Reviewed by". |

Dropped: SOLID checklist, 40-line method cap, mandatory doc comments on every public method, DI-over-singletons rule. Roblox codebases commonly use singleton service modules; judge by the project's `conventions.md` instead.

## 2. Static analysis

Tool versions verified locally via rokit on 2026-11-03: selene 0.32.0, stylua 2.5.2, luau-lsp 1.69.0, lune 0.10.5, rojo 7.7.1 [12].

### 2.1 Selene

- `std = "roblox"` loads Roblox globals. Without it, selene reports "`game` is not defined" [6].
- The roblox std is generated automatically, cached, refreshed every 6 hours; needs internet [6].
- For CI, pin it: `roblox-std-source = "pinned"` writes `roblox.yml` to the repo; regenerate with `selene generate-roblox-std` [6].
- Severities: `allow`, `warn`, `deny` [7]. `--allow-warnings` makes warnings pass [12].
- Lints that caught real bugs in a local test [12]: `undefined_variable` (typo globals), `duplicate_keys`, `roblox_incorrect_color3_new_bounds` (`Color3.new(255,0,0)`), `roblox_suspicious_udim2_new` (2 args to `UDim2.new`), `empty_if`, `unused_variable`.
- Other bug-catching lints in the list [8]: `almost_swapped`, `ifs_same_cond`, `if_same_then_else`, `mismatched_arg_count`, `incorrect_standard_library_use`, `shadowing`, `suspicious_reverse_loop`, `divide_by_zero`, `deprecated`, `must_use`, `constant_table_comparison`, `unbalanced_assignments`.

Recommended `selene.toml` (recommendation, not an official preset):

```toml
std = "roblox"
roblox-std-source = "pinned"
exclude = ["Packages/*", "ServerPackages/*", "DevPackages/*"]

[lints]
undefined_variable = "deny"
duplicate_keys = "deny"
mismatched_arg_count = "deny"
roblox_incorrect_color3_new_bounds = "deny"
deprecated = "warn"
shadowing = "warn"
unused_variable = "warn"
global_usage = "deny"
high_cyclomatic_complexity = "allow"
mixed_table = "warn"
```

- `mixed_table` matters for remotes: mixed numeric and string keys break across the network boundary [33].

### 2.2 StyLua

- `stylua --check` exits 1 on unformatted files and writes nothing [12].
- Defaults: `column_width = 120`, `indent_type = "Tabs"`, `quote_style = "AutoPreferDouble"`, `call_parentheses = "Always"`, `sort_requires` off [9].

Recommended `stylua.toml` (convention choice; keep whatever the project already uses):

```toml
syntax = "Luau"
column_width = 120
line_endings = "Unix"
indent_type = "Tabs"
indent_width = 4
quote_style = "AutoPreferDouble"
call_parentheses = "Always"
collapse_simple_statement = "Never"

[sort_requires]
enabled = false
```

- Keep `sort_requires` off in existing projects: reordering requires can change init order in module side effects (heuristic).
- Reformat legacy code in one dedicated `style:` commit, never inside a feature story.

### 2.3 luau-lsp analyze (type check in CLI)

Flags verified with `luau-lsp analyze --help` [12]: `--sourcemap PATH`, `--definitions` / `--defs @NAME=PATH`, `--platform roblox|standard`, `--base-luaurc PATH`, `--settings PATH`, `--ignore GLOB`, `--flag:KEY=VALUE`, `--no-strict-dm-types`, `--formatter default|plain|gnu`.

```bash
rojo sourcemap default.project.json --output sourcemap.json
curl -sSfL -o globalTypes.d.luau https://luau-lsp.pages.dev/type-definitions/globalTypes.None.d.luau
luau-lsp analyze --platform=roblox --sourcemap=sourcemap.json \
  --definitions:@roblox=globalTypes.d.luau --ignore="Packages/**" src
```

- The sourcemap lets the checker resolve `script.Parent.X` and `game.ReplicatedStorage.X` requires [10].
- Definition files per security level: `None`, `PluginSecurity`, `LocalUserSecurity`, `RobloxScriptSecurity` [11]. Use `None` for game code, `PluginSecurity` for plugins (inferred from names; UNVERIFIED, check luau-lsp docs).
- Without definitions it warns "`luau-lsp analyze` does not download definitions files" [12].
- Local test, strict mode, with definitions [12]: caught `part.Anchord = true` ("Key 'Anchord' not found in external type 'Part'"), `plr:Kik()`, `local x: number = "hello"`, unused locals. Exit code 1 on errors.
- Local test did NOT flag a property access on an unrefined `workspace:FindFirstChild(...)` result [12]. Do not rely on the checker there; refine with `IsA`.
- Gitignore `sourcemap.json` and the downloaded definitions [10].

### 2.4 Studio Script Analysis

- Studio's Script Analysis window shows the same Luau type and lint warnings for open places (UNVERIFIED menu path: check Studio Script tab / View menu).
- Workspace setting `LuauTypeCheckMode` sets the default mode; `--!strict` in a file overrides it [17][19].
- `UseNewLuauTypeSolver` (Workspace, Scripting) toggles the new solver per place [19].
- Studio-only projects (no Rojo): Script Analysis is the gate. Otherwise CI is the source of truth.

### 2.5 `--!strict` adoption for an existing codebase

1. Baseline: run `luau-lsp analyze` once in nonstrict; record error count per folder. That is the denominator.
2. Convert `src/shared/**` first: types, remote contracts, data schemas, utilities. Everything imports them, so typed exports spread value.
3. Then server services, then client controllers, then UI.
4. One file per commit: add `--!strict`, fix errors, no behavior changes. Commit as `refactor(types):`.
5. Allowed escape: `:: any` with a `-- TODO(types):` comment, counted as tech debt.
6. New files start strict. Rule: a PR may not lower the strict-file count.
7. Track progress: `grep -rL -- "--!strict" src --include=*.luau | wc -l`.

### 2.6 CI recipe (GitHub Actions + rokit)

`rokit.toml` pins tools; `setup-rokit` installs from it [13].

```toml
[tools]
rojo = "rojo-rbx/rojo@7.7.1"
selene = "Kampfkarren/selene@0.32.0"
stylua = "JohnnyMorganz/StyLua@2.5.2"
luau-lsp = "JohnnyMorganz/luau-lsp@1.69.0"
lune = "lune-org/lune@0.10.5"
```

```yaml
name: luau-quality
on: [push, pull_request]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: CompeyDev/setup-rokit@v0.2.1
      - run: stylua --check src
      - run: selene src
      - name: Types
        run: |
          rojo sourcemap default.project.json --output sourcemap.json
          curl -sSfL -o globalTypes.d.luau https://luau-lsp.pages.dev/type-definitions/globalTypes.None.d.luau
          luau-lsp analyze --platform=roblox --sourcemap=sourcemap.json \
            --definitions:@roblox=globalTypes.d.luau --ignore="Packages/**" src
```

- `setup-rokit@v0.2.1` is the tag shown in its README [13]; check for a newer tag.
- Pin the definitions file in the repo instead of curl if CI must be offline or reproducible.
- Local hook (Windows): same three commands on Write/Edit of `*.luau`, warn only; CI blocks.

## 3. Typing patterns that catch bugs

- `--!strict` asserts all types, inferred or annotated; nonstrict defaults unannotated values to `any` [17].
- `export type` in a ModuleScript shares types; consumers use `Module.TypeName` [17].
- `::` casts are checked: one side must be a subtype of the other, or `any` [16].
- Keep `require` paths static, or the checker cannot type them [16]. Cyclic requires confuse the checker [16].
- Roblox types refine with `IsA` [43].

### 3.1 Typed remote payloads

```luau
-- src/shared/Net/Contracts.luau
--!strict
export type BuyRequest = { itemId: string, qty: number }

local Contracts = {}
function Contracts.parseBuy(raw: unknown): BuyRequest?
	if typeof(raw) ~= "table" then return nil end
	local t = raw :: { [any]: any }
	if typeof(t.itemId) ~= "string" or #t.itemId > 32 then return nil end
	if typeof(t.qty) ~= "number" or t.qty ~= t.qty or t.qty < 1 or t.qty > 99 then return nil end
	return { itemId = t.itemId, qty = math.floor(t.qty) }
end
return Contracts
```

- Server handlers take `unknown`, never a typed table: the type is a promise the client can break.
- `t.qty ~= t.qty` rejects NaN. Bound every number.

### 3.2 Typed data schemas

```luau
export type PlayerDataV3 = {
	version: 3,
	coins: number,
	inventory: { [string]: number },
	settings: { music: boolean },
}
```

- Literal `version: 3` forces migrations to be explicit. Migration functions are typed `(V2) -> V3`.
- Data templates are `table.freeze`d and deep-copied per player (convention).

### 3.3 Avoiding `any`

| Pattern | Problem | Fix |
|---|---|---|
| `local x: any = ...` | turns off checking downstream | `unknown` + refine |
| `:: any` to silence error | hides the real bug | fix type or TODO(types) debt |
| untyped `{}` module tables | every field is `any` in nonstrict | annotate the module type |
| `FindFirstChild` result used directly | may be nil, may be wrong class | `local p = x:FindFirstChild("P"); if p and p:IsA("BasePart") then` |
| OOP via metatables untyped | methods lose `self` type | `export type Class = typeof(setmetatable({} :: Fields, Class))` [17] |

### 3.4 Type solver pitfalls (new solver, general release 2025-11-20) [19]

- New solver is default for nocheck/nonstrict places. Strict places stay on the old solver unless opted in [19].
- Known issues: verbose errors, slow on large scripts, "blocked type" or "inference failed" errors, strict can be overly strict [18][19].
- These affect edit time only, not live games [19].
- Long arithmetic-heavy functions infer huge types; annotate locals and parameters [18].
- Some older libraries lack new-solver annotations [19]. Isolate them behind a typed wrapper module.
- luau-lsp and Studio can disagree. CI's luau-lsp version is the reference; pin it.

## 4. Memory leaks: patterns and fixes

Engine facts:

- Connections on an instance are never garbage collected while the instance lives, even after firing [22].
- Player objects and characters are not destroyed automatically on leave; their connections keep memory [22].
- Fix: `Workspace.PlayerCharacterDestroyBehavior` enabled (engine calls `Destroy()` on old characters) [36], or clean up in PlayerRemoving / CharacterRemoving with `task.defer` [22].
- `Destroy()` sets Parent nil, locks Parent, disconnects all connections, destroys children [38].
- A Luau reference keeps an instance alive [38]. `Destroying` listeners keep it alive while running [38].

### 4.1 Patterns

| Leak | Detect | Fix |
|---|---|---|
| `:Connect` with no stored connection on a long-lived signal | grep `:Connect(` not assigned / not in a Trove | store in Trove; `Once` for one-shots |
| Player-keyed table never cleared | grep `\[player\]` / `\[plr.UserId\]` without PlayerRemoving `= nil` | clear in PlayerRemoving [22] |
| `Parent = nil` instead of `Destroy()` | grep `.Parent = nil` | `Destroy()` unless reused soon [38] |
| Closures capturing instances in module-level tables | Luau heap Unique References [24] | weak tables or explicit removal |
| CharacterAdded connections stacking per respawn | count connections after 20 respawns | per-character Trove cleaned on CharacterRemoving |
| Tweens created per event, never cleaned | heap Object Classes rising (Tween) [24] | reuse tween or `Destroy()` after Completed (UNVERIFIED that Tweens leak if not destroyed) |
| `task.spawn(function() while true do ... end end)` with no exit | thread count in heap Object Tags [24] | loop on a `alive` flag; cancel with `task.cancel` |
| `task.delay` on destroyed objects | errors in log on nil parent | check `obj.Parent` or cancel the thread |
| Per-player instances in ServerStorage never destroyed | SceneAnalysis Instance Composition [27] | destroy on leave |

### 4.2 Cleanup libraries

| Library | API shape | Use when |
|---|---|---|
| Trove (Sleitnick) | `new`, `Add(obj, method?)`, `Connect`, `Once`, `Clone`, `Construct`, `BindToRenderStep`, `AddPromise`, `Extend`, `Remove`, `Pop`, `Clean`, `WrapClean`, `AttachToInstance`, `Destroy` [40] | default choice; strict-typed source; `Extend` for child lifetimes [40] |
| Janitor (howmanysmall) | `Add(obj, method?, index?)` returns the object; link to an Instance [41] | project already uses it; need indexed tasks |
| Maid (Quenty, Nevermore) | `GiveTask`, index assignment `maid.X = task`, `DoCleaning` (UNVERIFIED: check Nevermore source) | project already uses Nevermore |

- Pick one per project; record it in `conventions.md`. Do not mix.
- Trove errors if you `Add`, `Connect`, `Clone`, or `Construct` while it is cleaning [40].
- Janitor claims to be faster than Maid [41] (author's own benchmark; treat as unconfirmed).

```luau
-- before: leaks one connection set per respawn
player.CharacterAdded:Connect(function(char)
	char.Humanoid.Died:Connect(onDied)
	RunService.Heartbeat:Connect(function() updateAura(char) end)
end)

-- after
local charTrove = Trove.new()
player.CharacterAdded:Connect(function(char)
	charTrove:Clean()
	local hum = char:WaitForChild("Humanoid") :: Humanoid
	charTrove:Connect(hum.Died, onDied)
	charTrove:Connect(RunService.Heartbeat, function() updateAura(char) end)
end)
-- PlayerRemoving: charTrove:Destroy(); playerState[player] = nil
```

### 4.3 How to detect

| Tool | What to read | Leak signal |
|---|---|---|
| Developer Console > Memory | PlaceMemory: Instances, Signals, LuaHeap; PlaceScriptMemory per script [24] | steady growth across identical cycles [22] |
| Developer Console > Luau heap | snapshots; views Graph, Object Tags, Memory Categories, Object Classes, Unique References, Unparented Instances [24] | counts rising between snapshot 1 and snapshot N |
| `debug.setmemorycategory("Name")` | custom category in the console [39] | per-system attribution |
| `Stats` | `InstanceCount`, `GetTotalMemoryUsageMb()`, `GetMemoryUsageMbForTag(tag)` [28] | scripted sampling; tag APIs return 0 if `MemoryTrackingEnabled` is false [28] |
| `collectgarbage("count")` | Luau heap KB (works in Lune [12]; in Studio UNVERIFIED but standard) | heap after forced cycles not returning to baseline |
| SceneAnalysisService | `GetUnparentedInstancesAsync` (held by Luau, grouped by host script), `GetScriptMemoryAsync`, `GetInstanceCompositionAsync` [27] | unparented instances attributed to your script |
| Studio MCP skill `rbx-scene-analysis` | wraps Scene Analysis: memory, instance composition, unparented instances [42] | agent-run leak hunt |
| Studio MCP skill `rbx-perf-profiling` | LibMP access to MicroProfiler data incl. memory by subsystem [42] | allocation spikes |

- Note: `Stats.InstanceCount` was reported as deprecated on the rendered class page but not in the source YAML [28]. Verify in Studio autocomplete before depending on it.
- Pending-GC instances show parent "Unknown" in unparented results; that is expected [27].

Leak test recipe (agent-runnable via `execute_luau`):

```luau
local Stats = game:GetService("Stats")
local function sample(tag: string)
	print(tag, Stats.InstanceCount, math.floor(collectgarbage("count")), "KB")
end
sample("baseline")
for i = 1, 20 do
	-- trigger the cycle under test: respawn, open/close UI, spawn/kill NPC
	task.wait(1)
end
task.wait(5)
sample("after 20 cycles") -- growth per cycle > 0 with no plateau = leak candidate
```

## 5. Hot path optimization

Per-frame events: PreRender, PreSimulation, PostSimulation, Heartbeat, PreAnimation. Keep them for camera-like work; run the rest less often [22]. Server Heartbeat caps at 60 FPS; frames over 16.67 ms in the MicroProfiler are the signal [21].

### 5.1 Rules (with evidence)

| Rule | Evidence |
|---|---|
| Cache instance refs outside loops | FindFirstChild ~20% slower than dot, ~8x slower than a stored reference [38] |
| Preallocate with `table.create(n)` | measured 8.5 ms vs 25.7 ms (`table.insert`) for 1M fills [12] |
| Reuse scratch tables + `table.clear` | measured 5.0 ms vs 11.7 ms for 200k iterations [12] |
| Hoist closures out of hot loops | measured 3.3 ms vs 9.9 ms for 200k calls [12]; no-upvalue closures are cached by compiler [14] |
| Build strings with `table.concat` or `buffer` | 20k appends: 232.6 ms (`..`) vs 0.42 ms (`table.concat`) vs 0.67 ms (buffer) [12] |
| Generalized iteration is fine | `for _, v in t` 4.4 ms, `ipairs` 3.8 ms, `for i=1,#t` 4.5 ms per 1M [12]; docs: comparable [14] |
| Methods on metatable, `obj:Method()` | inline caching; caching methods in locals "not recommended" [14] |
| `math.max(x, 1)` / `string.byte(s)` form | fastcall needs direct visible calls; `s:byte()` does not qualify [14] |
| No `getfenv` / `setfenv` / `loadstring` | deoptimizes the whole environment [14] |
| `GetPartBoundsInBox/Radius` over `GetPartsInPart` when bounds suffice | bounds queries are "less accurate but perform more efficiently" [37] |
| Avoid Touched-driven logic for zones | heuristic: poll a bounds query at 5 to 10 Hz instead of per-contact events; measure both |
| Disable CanCollide/CanTouch/CanQuery on decorative parts | reduces physics work [22] |
| Server tweens replicate every frame | tween on the client [22] |
| Split big jobs across frames with `task.wait()` | main thread blocks until yield [22] |

Measured numbers marked [12] come from Lune 0.10.5 on this dev machine, median of 9 runs after 2 warmups. They show relative cost in the Luau VM, not Roblox client frame cost.

### 5.2 Before/after snippets

```luau
-- before: lookup + alloc every frame
RunService.Heartbeat:Connect(function()
	for _, p in Players:GetPlayers() do
		local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		local nearby = {}
		-- ...
	end
end)

-- after: refs cached on spawn, scratch table reused, 10 Hz budget
local roots: { [Player]: BasePart } = {}
local scratch = table.create(32)
local acc = 0
RunService.Heartbeat:Connect(function(dt)
	acc += dt
	if acc < 0.1 then return end
	acc = 0
	for player, root in roots do
		table.clear(scratch)
		-- ...
	end
end)
```

```luau
-- CollectionService instead of scanning workspace
for _, inst in CollectionService:GetTagged("Coin") do register(inst) end
CollectionService:GetInstanceAddedSignal("Coin"):Connect(register)
CollectionService:GetInstanceRemovedSignal("Coin"):Connect(unregister)
```

### 5.3 `--!native`

- Enable with `--!native` at file top or `@native` per function [20].
- Supported on server scripts and client scripts on Android only [20].
- Best for math-heavy, frequently called code with few engine API calls; buffers and typed `Vector3` args help [20].
- Costs: startup compile time, extra memory, a per-game native code limit; 1M instruction limit per module [20].
- Check: Script Profiler shows `<native>`; `debug.dumpcodesize()` in Studio Command Bar (Server view) [20][39].
- Breakpoints disable native for those functions [20].
- Lune showed no speedup (63.1 ms vs 61.4 ms) [12]; Lune likely does not enable codegen (UNVERIFIED). Measure native in a Studio server run.

### 5.4 Task scheduling

- `task.wait`, `task.spawn`, `task.defer`, `task.delay` replace legacy `wait`, `spawn`, `delay` (legacy globals flagged by `DeprecatedGlobal` lint [15] and selene `deprecated` [8]).
- One shared ticker per frequency (for example 10 Hz) beats many `while task.wait(0.1)` loops (heuristic; measure).
- Parallel Luau (Actors) for data-model-free work [22]; buffers cannot be shared across Actors [35].

## 6. Network bandwidth

### 6.1 Measure

| Tool | Read |
|---|---|
| `Stats.DataSendKbps` / `DataReceiveKbps` | per-side KB/s; server side sums all clients [28] |
| `Stats.PhysicsSendKbps` / `PhysicsReceiveKbps` | physics replication [28] |
| Performance Stats (Ctrl+Alt+F7), Debug Stats (Shift+Ctrl+F1..F5) | network overlay, ping [21] |
| Server Stats tab / Shift+F3 | data ping vs network ping; big gap = replication queue backlog [21] |
| MicroProfiler network view, `ProcessPackets` scope | packet processing cost [21][22] |
| Network Simulation (Alt+S) | latency, jitter, loss in Studio [21] |

- Developer Console Network tab counts HTTP calls (HttpService, DataStoreService), not remote bandwidth [23].
- Wrap `FireClient` sites in a counter module in dev builds: calls/s and approx bytes per remote name (convention).

### 6.2 Rules

- Client to server: about 500 req/s per client, shared across all remotes of the same type [34]. Excess RemoteEvent messages are delayed; excess Unreliable ones dropped [33].
- Send only what changed: the purchased item, not the inventory [22].
- Do not replicate every frame; throttle input-triggered sends [22].
- Cosmetic effects: create locally on each client; server sends the outcome only [22].
- `UnreliableRemoteEvent` for ephemeral, continuously changing data; no order or delivery guarantee; payloads over 1000 bytes dropped [32]. Add a sequence number and drop stale ones [33].
- Remote args: no mixed tables, no nil holes, metatables lost, functions become nil, non-string keys become strings [33].
- Buffers: compact binary, little-endian, sent as copies [35]. Use for high-frequency state (positions, ids).
- Avoid attributes or ValueObjects that change every frame: each change replicates (heuristic; measure with DataSendKbps).
- Batch: queue events per frame or per 0.1 s, fire once with an array.

```luau
-- before: one remote call per hit, table per call
for _, hit in hits do DamageFx:FireAllClients({ pos = hit.Position, amt = hit.Damage }) end

-- after: one unreliable batch per frame, packed in a buffer (14 bytes per hit)
local b = buffer.create(#hits * 14)
for i, hit in hits do
	local o = (i - 1) * 14
	buffer.writef32(b, o, hit.Position.X); buffer.writef32(b, o + 4, hit.Position.Y)
	buffer.writef32(b, o + 8, hit.Position.Z); buffer.writeu16(b, o + 12, hit.Damage)
end
DamageFxUnreliable:FireAllClients(b) -- keep #hits * 14 under 1000 bytes; chunk if more
```

## 7. DataStore budgets

Full patterns live in `implementation-data.md`. Review rules only:

- Per-server budget per minute: read 60 + players x 40, write 60 + players x 40, list 5 + players x 2 [29].
- Experience-wide: write 300 + CCU x 20 per minute, shared with Open Cloud [29].
- UpdateAsync counts against read and write [29][31]. SetAsync counts only against write [31].
- Per key: 25 MB/min read, 4 MB/min write, rounded up per KB [29]. Value max 4,194,304 [29].
- GetAsync caches a key locally for 4 seconds [31].
- UpdateAsync callback cannot yield; returning nil cancels the write; it may rerun on conflict [31].
- Autosave interval: shorter than session-lock expiry, inside budget; the official sample uses 180 s. Also save on leave, shutdown, purchase [30].
- One key per player when it fits; small fixed set of stores [30].
- Retries: pcall, exponential backoff with jitter, capped [30]. Random start offset per server [30].
- Check `GetRequestBudgetForRequestType` before bulk work [29].
- Studio uses separate, possibly lower, limits [29]. Do not judge budget use from Studio alone.
- The old "6 seconds between writes to the same key" rule is not in the current limits page [29]. UNVERIFIED; treat per-key throughput as the limit.

Review flags: SetAsync on player data (MAJOR), DataStore calls outside the data module (MAJOR), GetAsync inside loops without cache (MAJOR), save on every currency change (BLOCKER at scale).

## 8. Measurement protocol for optimization claims

### 8.1 What counts as evidence

| Evidence | Valid when |
|---|---|
| MicroProfiler frame times with custom labels | `debug.profilebegin("Sys.Name")` / `profileend()` around the code [26][39]; frame dump captured before and after |
| Script Profiler % or ms | same frequency (1 KHz default, 10 KHz higher cost), same duration, same view [25]; export JSON both runs [25] |
| Memory | Luau heap snapshots or Memory tab categories at the same point in the same scenario [24] |
| Bandwidth | `DataSendKbps` averaged over 60 s with the same player count [28] |
| Micro-benchmark | `os.clock()` over N iterations, warmup, median of at least 5 runs |
| Load time | `os.clock()` from ReplicatedFirst to `game.Loaded` [21] |

Not evidence: "should be faster", lint passing, code reading, a single run, Studio-only FPS for client claims (Studio skews numbers [21]).

### 8.2 Fair before/after in Studio

1. Same place file, same commit except the change (stash or branch).
2. Same scenario script: same spawn point, same NPC count, same player count (Test tab, local server with N clients).
3. Warm up 30 s after join (load, JIT of `--!native`, caches).
4. Sample 60 s; for Script Profiler use the 1-minute session [25].
5. Three runs each side. Report median and spread.
6. Server and client measured separately; label which [25].
7. Note machine, Studio version, graphics quality (max removes the frame rate manager effect [21]).
8. Client FPS claims need a real client or low-end device check [21].

Report template (goes in the story or `production/polish/`):

```markdown
| Metric | Where | Before (median of 3) | After | Delta | Tool |
|---|---|---|---|---|---|
| Heartbeat label "Combat.Tick" | Server | 2.10 ms | 0.60 ms | -71% | MicroProfiler dump |
| CombatService self time | Server | 8.4% | 2.1% | -6.3 pts | Script Profiler 1 KHz, 1 min |
| LuaHeap after 20 respawns | Server | +3.2 MB | +0.1 MB | | Luau heap snapshots |
| DataSendKbps, 8 players | Server | 41 | 18 | -56% | Stats |
```

### 8.3 Offline micro-benchmarks via Lune

- For pure-Luau modules (math, serialization, data transforms). No engine APIs in Lune's VM.
- Harness used for Section 5 numbers [12]:

```luau
local function bench(name: string, runs: number, fn: () -> ())
	for _ = 1, 2 do fn() end
	local s = table.create(runs)
	for r = 1, runs do
		local t0 = os.clock(); fn(); s[r] = (os.clock() - t0) * 1000
	end
	table.sort(s)
	print(string.format("%-30s median %.3f ms", name, s[math.ceil(runs / 2)]))
end
```

- Run: `lune run bench/serializer.bench.luau`. Commit bench files next to the module.
- Lune results are relative. Confirm wins over 10% in Studio before claiming frame savings.

## 9. Review checklist

Severity: BLOCKER (must fix before close), MAJOR (fix in story unless logged as debt with reason), MINOR (fix if cheap), NIT (optional). Detect: G = grep, L = lint/typecheck, M = manual.

| ID | Check | Sev | Detect |
|---|---|---|---|
| C1 | No undefined globals or typos | BLOCKER | L selene `undefined_variable` |
| C2 | No legacy `wait(`, `spawn(`, `delay(` | MINOR | G `\b(wait\|spawn\|delay)\(` ; L `deprecated` |
| C3 | `WaitForChild` on client for replicated instances; no infinite wait without timeout in server code | MAJOR | G `WaitForChild\(` ; M |
| C4 | pcall around every yielding web call (DataStore, MarketplaceService, HttpService) | BLOCKER | G `Async\(` without `pcall` nearby; M |
| C5 | No mixed tables or nil holes sent over remotes [33] | MAJOR | L `mixed_table` ; M |
| C6 | UpdateAsync callbacks do not yield [31] | BLOCKER | G `task.wait` inside UpdateAsync; M |
| T1 | `src/shared/**` files are `--!strict` | MAJOR | G `grep -L -- "--!strict"` |
| T2 | New files are strict | MINOR | G |
| T3 | No new `: any` / `:: any` without `TODO(types)` | MINOR | G `:\s*any\b\|::\s*any\b` |
| T4 | Remote and data contracts use `export type` | MAJOR | M |
| T5 | `luau-lsp analyze` clean on changed files | MAJOR | L |
| T6 | FindFirstChild results refined (`IsA`, nil check) | MAJOR | G `FindFirstChild\(` ; M |
| S1 | Every `OnServerEvent` / `OnServerInvoke` validates types, ranges, NaN, string length | BLOCKER | G `OnServer(Event\|Invoke)` ; M |
| S2 | Server never trusts client-sent prices, damage, positions, cooldowns | BLOCKER | M |
| S3 | Per-player rate limit on each remote | MAJOR | M |
| S4 | No `RemoteFunction` server to client invoke (client can hang it) | MAJOR | G `InvokeClient` |
| S5 | No `loadstring`, `getfenv`, `setfenv` [14] | BLOCKER | G |
| P1 | No `FindFirstChild` / `GetDescendants` / `GetChildren` inside per-frame callbacks | MAJOR | G within Heartbeat/RenderStepped/PreSimulation bodies; M |
| P2 | No table or closure creation per frame in hot paths | MAJOR | M |
| P3 | String building in loops uses `table.concat` / buffer | MINOR | G `\.\.` inside `for` ; M |
| P4 | Server-side TweenService for visuals moved to client [22] | MAJOR | G `TweenService` in `src/server` |
| P5 | `while true do` loops yield and have an exit | BLOCKER | G `while true do` |
| P6 | Expensive per-frame work throttled or labeled with `debug.profilebegin` | MINOR | M |
| P7 | `--!native` only on measured math-heavy server modules | MINOR | G `--!native` ; M |
| M1 | Every long-lived `:Connect` owned by a cleanup object or a destroyed instance | MAJOR | G `:Connect\(` ; M |
| M2 | Player-keyed tables cleared on PlayerRemoving [22] | BLOCKER | G `\[player\]\|\[.*UserId\]` |
| M3 | `Destroy()` not `Parent = nil` for disposal [38] | MINOR | G `\.Parent = nil` |
| M4 | Per-character connections cleaned on respawn | MAJOR | M ; leak test (4.3) |
| M5 | Spawned threads have an exit or `task.cancel` | MAJOR | G `task.spawn\|task.delay\|coroutine.wrap` |
| N1 | No remote fired every frame unless unreliable and batched | MAJOR | G `FireAllClients\|FireClient` inside per-frame callbacks |
| N2 | Unreliable payloads stay under 1000 bytes [32] | MAJOR | M |
| N3 | Delta updates, not full-state resends [22] | MINOR | M |
| N4 | No attributes/ValueObjects written per frame | MAJOR | G `SetAttribute\(` in per-frame callbacks |
| D1 | DataStore calls only in the data module | MAJOR | G `DataStoreService\|GetDataStore` outside data path |
| D2 | UpdateAsync for read-modify-write; no SetAsync on player data [30] | MAJOR | G `SetAsync\(` |
| D3 | Saves on interval + leave + BindToClose, not on every change | BLOCKER | M |
| D4 | Schema has version and migration | MAJOR | M |
| R1 | StyLua clean | MINOR | L `stylua --check` |
| R2 | Names follow `conventions.md` | NIT | M |
| R3 | No dead code, commented-out blocks, unused requires | NIT | L `unused_variable`, `ImportUnused` [15] |
| R4 | Magic numbers in config modules | MINOR | M |

ID prefix = group: C correctness, T typing, S security (server trust), P performance, M memory, N network, D data, R readability.

## 10. Tech debt prioritization for `/rbx-optimize`

Extends the original register [2] with a risk column.

| Factor | 1 | 2 | 3 | 4 |
|---|---|---|---|---|
| Impact (player-felt cost if unfixed) | cosmetic | minor lag or debt | measurable frame/memory/bandwidth cost | crash, data loss, exploit, server leak |
| Risk (chance the fix breaks working features) | isolated pure module, tested | one system | cross-system | data/purchase path |
| Effort | S | M | L | XL |

Score = Impact x (5 - Risk) / Effort. Highest first. Ties: older entry first [2].

- Impact 4 items (exploits, data loss) skip the queue regardless of score.
- Each pass: pick top 3. Measure baseline first (Section 8). No baseline: `NOT ASSESSED`, do not fix blind [3].
- One debt item per commit: `perf(combat): cache roots, drop per-frame alloc (TD-014)`.
- Behavior-preserving only. Feature changes go to a new story.
- Before and after each commit: lint gates, unit tests if present (Studio MCP `rbx-unit-test` [42]), playtest the touched loop.
- Data or purchase path changes need a migration test with a copied save and owner approval.
- Revert any commit whose after-measurement does not beat noise (spread of the 3 runs).
- Items older than 3 passes: fix or mark `Accepted: reason` [2].

## 11. `conventions.md` seed (`.rbx-studio/conventions.md`)

### 11.1 What it records

```markdown
# Conventions: <game>
Last learned: <date> from <N> files (sample list at bottom)
## Layout          (services, controllers, shared folders, packages path)
## Keep            (pattern + example file:line)
## Phase out       (pattern + site count + TD id + target)
## Naming          (modules PascalCase, locals camelCase, CONSTANTS, _private, remotes Domain.Verb)
## Error handling  (pcall + retry helper path; how remote handlers reject bad input)
## Logging         (log module, levels, no print in server code, profile label format "Service.Fn")
## Cleanup library (one of Trove / Janitor / Maid)
## Typing          (strict file count X / Y, rules for new files)
## Tooling         (rokit.toml pins, CI gates)
```

### 11.2 How to learn it from existing code

1. Inventory: count files per top folder and lines per file. Read `default.project.json` for layout.
2. Sample, do not read everything: per area (server, client, shared, UI) pick the 3 largest, the 3 most changed (`git log --format= --name-only | sort | uniq -c | sort -rn | head`), the 2 newest, and every entrypoint script. About 25 to 40 files.
3. Pattern census by grep over all files, recording counts, not impressions: `--!strict`, `task.wait` vs `wait(`, `:Connect(` vs Trove/Janitor/Maid, `SetAsync` vs `UpdateAsync`, `OnServerEvent`, `require(` style, `print(`.
4. Newest code wins ties: the owner's current style is in recent commits, not old files.
5. Classify each pattern: keep (correct and consistent), phase out (fails a checklist item in Section 9), undecided (ask the owner once).
6. Write `conventions.md` with file:line examples and counts. Show the owner a 10-line summary before saving.
7. Update after each `/rbx-review`: a new accepted pattern is added; a fixed phase-out decrements its count. Goal: code gets better, not copied.

## Notes for agents

- APIs named in snippets but not re-fetched this session: `CollectionService:GetTagged`, `GetInstanceAddedSignal`, `GetInstanceRemovedSignal`, RunService events, `task.cancel`, `Players.PlayerRemoving`, `Humanoid.Died`. UNVERIFIED here; confirm with Studio MCP skill `rbx-docs-search` [42] before quoting signatures.
- When a number here conflicts with live docs, live docs win. Update this file and its Sources date.

## Sources

[1] Original repo `/code-review` skill - .claude/skills/code-review/SKILL.md (local) - checked 2026-11-03
[2] Original repo `/tech-debt` skill - .claude/skills/tech-debt/SKILL.md (local) - checked 2026-11-03
[3] Original repo `/perf-profile` skill - .claude/skills/perf-profile/SKILL.md (local) - checked 2026-11-03
[4] Original coding standards and path rules - .claude/docs/coding-standards.md, .claude/rules/engine-code.md, .claude/rules/network-code.md (local) - checked 2026-11-03
[5] Original repo `/story-done` skill and review gates - .claude/skills/story-done/SKILL.md (local) - checked 2026-11-03
[6] Selene: Roblox guide - https://kampfkarren.github.io/selene/roblox.html - checked 2026-11-03
[7] Selene: Configuration - https://kampfkarren.github.io/selene/usage/configuration.html - checked 2026-11-03
[8] Selene docs lint list (SUMMARY.md) - https://github.com/Kampfkarren/selene/blob/main/docs/src/SUMMARY.md - checked 2026-11-03
[9] StyLua README - https://github.com/JohnnyMorganz/StyLua - checked 2026-11-03
[10] luau-lsp README - https://github.com/JohnnyMorganz/luau-lsp - checked 2026-11-03
[11] luau-lsp scripts README (type definition URLs) - https://github.com/JohnnyMorganz/luau-lsp/blob/main/scripts/README.md - checked 2026-11-03
[12] Local verification on dev machine: `luau-lsp analyze --help` and test run (1.69.0), selene 0.32.0 test run, `stylua --check` (2.5.2), Lune 0.10.5 benchmarks (median of 9, 2 warmups) - local, no URL - checked 2026-11-03
[13] setup-rokit README - https://github.com/CompeyDev/setup-rokit - checked 2026-11-03
[14] Luau Performance - https://luau.org/performance - checked 2026-11-03
[15] Luau Linting - https://luau.org/lint - checked 2026-11-03
[16] Luau Type System and Additional Considerations - https://luau.org/types and https://luau.org/types/considerations - checked 2026-11-03
[17] Roblox: Type checking - https://create.roblox.com/docs/luau/type-checking - checked 2026-11-03
[18] DevForum: New Type Solver [Beta] - https://devforum.roblox.com/t/new-type-solver-beta/3155804 - checked 2026-11-03
[19] DevForum: [General Release] Luau's New Type Solver (2025-11-20) - https://devforum.roblox.com/t/general-release-luau%E2%80%99s-new-type-solver/4084991 - checked 2026-11-03
[20] Roblox: Native code generation - https://create.roblox.com/docs/luau/native-code-gen - checked 2026-11-03
[21] Roblox: Identify performance issues - https://create.roblox.com/docs/performance-optimization/identify - checked 2026-11-03
[22] Roblox: Improve performance - https://create.roblox.com/docs/performance-optimization/improve - checked 2026-11-03
[23] Roblox: Developer Console - https://create.roblox.com/docs/studio/developer-console - checked 2026-11-03
[24] Roblox: Memory usage (Memory and Luau heap tools) - https://create.roblox.com/docs/studio/optimization/memory-usage - checked 2026-11-03
[25] Roblox: Script Profiler - https://create.roblox.com/docs/studio/optimization/scriptprofiler - checked 2026-11-03
[26] Roblox: Use the MicroProfiler - https://create.roblox.com/docs/performance-optimization/microprofiler/use-microprofiler - checked 2026-11-03
[27] Roblox: SceneAnalysisService (class page and creator-docs YAML) - https://create.roblox.com/docs/reference/engine/classes/SceneAnalysisService - checked 2026-11-03
[28] Roblox: Stats (class page and creator-docs YAML) - https://create.roblox.com/docs/reference/engine/classes/Stats - checked 2026-11-03
[29] Roblox: Data store error codes and limits - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits - checked 2026-11-03
[30] Roblox: Data store best practices - https://create.roblox.com/docs/cloud-services/data-stores/best-practices - checked 2026-11-03
[31] Roblox: GlobalDataStore - https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore - checked 2026-11-03
[32] Roblox: UnreliableRemoteEvent - https://create.roblox.com/docs/reference/engine/classes/UnreliableRemoteEvent - checked 2026-11-03
[33] Roblox: Remote events and callbacks - https://create.roblox.com/docs/scripting/events/remote - checked 2026-11-03
[34] Roblox: RemoteEvent (Throttling) - https://create.roblox.com/docs/reference/engine/classes/RemoteEvent - checked 2026-11-03
[35] Roblox: buffer library - https://create.roblox.com/docs/reference/engine/libraries/buffer - checked 2026-11-03
[36] Roblox: Workspace.PlayerCharacterDestroyBehavior - https://create.roblox.com/docs/reference/engine/classes/Workspace - checked 2026-11-03
[37] Roblox: WorldRoot spatial queries - https://create.roblox.com/docs/reference/engine/classes/WorldRoot - checked 2026-11-03
[38] Roblox: Instance (Destroy, FindFirstChild, WaitForChild, Destroying) - https://create.roblox.com/docs/reference/engine/classes/Instance - checked 2026-11-03
[39] Roblox: debug library - https://create.roblox.com/docs/reference/engine/libraries/debug - checked 2026-11-03
[40] Trove source (RbxUtil) - https://github.com/Sleitnick/RbxUtil/blob/main/modules/trove/init.luau - checked 2026-11-03
[41] Janitor README - https://github.com/howmanysmall/Janitor - checked 2026-11-03
[42] Studio MCP tool manifest (built-in skills) - docs/roblox/studio-mcp-tools.md (local) - checked 2026-11-03
[43] Luau: Roblox types - https://luau.org/types/roblox-types - checked 2026-11-03
