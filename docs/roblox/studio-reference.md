# Roblox Studio Reference: Engine, Tools, MCP, Open Cloud, Toolchains

Last checked: 2026-11-03. Sources at bottom.

## TL;DR for agents

- Default workflow for this developer is **Studio + the built-in Studio MCP server** (27 tools on this machine). Enable it in Studio under Assistant > `...` > Manage MCP Servers > "Enable Studio as MCP server" [1][2].
- Every MCP tool takes `datamodel_type`. `Edit` is rejected during play. `multi_edit` is Edit-only. Input and navigation tools are Client-only. Anything you change in Client/Server datamodels is lost when play stops [2].
- `execute_luau` runs on Studio's main thread. Until it yields, Studio freezes and the MCP link can drop. Chunk heavy work and call `task.wait()` per chunk, parent small subtrees [2].
- The old `Roblox/studio-rust-mcp-server` is **archived** (final tag `END`, 2026-04-03). Do not install it [4][56].
- Native **Script Sync** syncs Script/LocalScript/ModuleScript/Folder only (not parts, not attributes or tags) to `.luau` files, works with Team Create, no sourcemaps [9][10]. Rojo 7.7.1 is still the choice when the filesystem must be the source of truth [51].
- Team Create now defaults to **Live Scripting** (real-time co-editing). Drafts mode is opt-in: File > Experience Settings > Enable Drafts Mode [15].
- Data stores: in-game and Open Cloud share **one per-experience request budget** since 2026-07-29. Storage cap is 500 MB + 1 MB x lifetime users [35][36].
- Reserved servers: use `TeleportOptions.ReservedServerId` (a GUID). `ReservedServerAccessCode` and `ShouldReserveServer` are deprecated [18].
- Monetization: `MarketplaceService.BindReceiptHandler` is the newer receipt API. `ProcessReceipt` is "legacy" but still works. `GetProductInfo` is deprecated for `GetProductInfoAsync` [29].
- Open Cloud covers CI publishing (`versionType=Published`), Luau Execution (headless test runs, 5 min, 10 concurrent per place), restart servers, bans, configs, notifications [39][40][41].

## 0. This machine (context only, nothing was run)

| Item | Detail |
|---|---|
| Studio MCP launcher | `%LOCALAPPDATA%\Roblox\mcp.bat`, wraps `Versions\version-<hash>\StudioMCP.exe`, falls back to registry `ContentFolder` lookup |
| MCP tool cache | Written by Studio 2026-10-17, 27 tools, 7 built-in skills [2] |
| Rokit binaries (`~/.rokit/bin`) | rojo, selene, stylua, luau-lsp, lune, wally, wally-package-types, run-in-roblox |
| Newest installed versions (`~/.rokit/tool-storage`) | rojo 7.7.1, selene 0.32.0, stylua 2.5.2, luau-lsp 1.69.0, lune 0.10.5, wally 0.3.2, wally-package-types 1.6.2, run-in-roblox 0.3.0 |
| Upstream latest (2026-11-03) | rojo 7.7.1, selene 0.32.0, StyLua 2.6.0, luau-lsp 1.70.1, Lune 0.11.1, Wally 0.3.2 [51][57-61] |
| Global `rokit.toml` | `[tools]` empty. Pin tools per project with `rokit add` |
| Repo root | No `rokit.toml` or `*.project.json` yet |

## 1. Engine services

All names below are confirmed in the Engine API index [19] unless flagged.

| Service | What it is for | Runs on | Key gotcha |
|---|---|---|---|
| Workspace | 3D world, physics, streaming config | Both | `StreamingEnabled` is on by default for new places. Client must `WaitForChild` streamed parts; target radius default 1024 [37] |
| Players | Player objects, join/leave, bans (`BanAsync`) | Both | Bind `PlayerAdded` and loop existing players (late connect misses early joiners) |
| Lighting | Sky, atmosphere, post effects, time of day | Both | Lighting changes on server replicate. Per-player looks must be client-side |
| ReplicatedStorage | Shared modules, remotes, assets | Both | Everything here is visible to exploiters. No secrets |
| ReplicatedFirst | Loading screens, first client code | Client | Replicates before everything else. Do not assume other services are loaded |
| ServerScriptService | Server Scripts and server modules | Server | Never replicated. Put all authority here |
| ServerStorage | Server-only assets and modules | Server | Clients cannot see it. Clone to Workspace to show |
| StarterGui | Template ScreenGuis copied to PlayerGui | Client copy | `ResetOnSpawn` default true wipes GUI state on respawn |
| StarterPack | Tools copied to Backpack on spawn | Client copy | Copied every respawn. Server-granted tools go to `Backpack` directly |
| StarterPlayer | Character and camera defaults | Both | Holds StarterPlayerScripts and StarterCharacterScripts |
| StarterPlayerScripts | LocalScripts run once per session | Client | Not re-run on respawn |
| StarterCharacterScripts | Scripts copied into each character | Both | Re-run on every spawn. Clean up connections |
| Teams | Team objects and auto-assign | Both | `AutoAssignable` teams balance automatically |
| SoundService | Global audio, ambient reverb, new Audio API routing | Both | Sounds playing from server replicate to all |
| TextChatService | Current chat system, channels, commands, bubbles | Both | Filter server-side with `TextService:FilterStringAsync` [24] |
| Chat (legacy) | Legacy Lua chat framework | Both | Being phased out. Set `Chat.LoadDefaultChat = false` and use TextChatService [24] |
| DataStoreService | Persistent key-value storage | Server | Server Scripts only. Studio uses live data: enable File > Experience Settings > Security > "Enable Studio Access to API Services" only on a test copy. Use `UpdateAsync` for multi-server writes [34] |
| MemoryStoreService | Low-latency shared memory: sorted maps, queues, hash maps | Server | 32 KB item max, 45 day max expiry, quota 64 KB + 1.2 KB x users per experience [33] |
| MessagingService | Cross-server pub/sub | Server | 1 kB messages, best-effort delivery, 600 + 240 x players sends/min per server [32] |
| MarketplaceService | Dev products, passes, subscriptions, prompts | Both | Grant on receipt, never on prompt-finished. Make grants idempotent by `PurchaseId` [29] |
| PolicyService | Per-player legal/policy flags (paid random items, links) | Both | Yields. Required for loot boxes and external links compliance. UNVERIFIED method list: check `GetPolicyInfoForPlayerAsync` page |
| TeleportService | Move players between places and servers | Server for `TeleportAsync` | Does not work in Studio playtests. Teleport data is client-visible [17] |
| HttpService | External HTTP, JSON, GUIDs, Secrets | Server | `HttpEnabled` required. 500 external req/min, separate 2,500/min for Open Cloud. `GetSecret` not available locally [31] |
| RunService | Frame events, context checks | Both | Use `PreSimulation`/`PostSimulation`/`RenderStepped` (client). `IsStudio()` for Studio gates |
| UserInputService | Raw input, device detection | Client | Use `gameProcessedEvent` to ignore typing in TextBoxes |
| ContextActionService | Bind actions with mobile buttons | Client | Overlaps with new Input Action System (InputContext/InputAction) [26] |
| GuiService | Selection, gamepad nav, safe insets | Client | `GetGuiInset` and safe areas matter on mobile notches |
| TweenService | Property interpolation | Both | Server tweens replicate every step. Tween on client for smoothness |
| CollectionService | Tags for component systems | Both | Tags replicate. Pair `GetTagged` with `GetInstanceAddedSignal` for streaming |
| PhysicsService | Collision groups | Both | Register groups on server. Max group count is limited (UNVERIFIED: 32) |
| PathfindingService | NPC paths, agent params, modifiers | Server typical | Recompute on `Blocked`. Cost per call adds up with many NPCs |
| ContentProvider | Preloading assets | Client | `PreloadAsync` is for critical assets only. Overuse slows joins |
| AnalyticsService | Economy, funnel, custom events | Server | Event and name cardinality limits apply. UNVERIFIED exact limits: check AnalyticsService page |
| BadgeService | Badge award and checks | Server for award | `AwardBadge` deprecated, use `AwardBadgeAsync` (50 + 35 x users/min) [30] |
| SocialService | Invites, calls, phone book prompts | Client | Prompts are rate limited and need eligibility checks |
| LocalizationService | Translators, locale IDs, auto-translate | Both | Use `GetTranslatorForPlayerAsync`. LocalizationTable instances hold strings |
| AvatarEditorService | In-experience avatar editing, catalog search | Client | Prompt-based. Player must confirm saves |
| ProximityPromptService | Global settings/events for ProximityPrompts | Both | Custom prompt UI needs `Style = Custom` |
| Debris | Timed `Destroy` | Both | Legacy. `task.delay(t, inst.Destroy, inst)` is clearer |
| VoiceChatService | Voice settings and eligibility | Both | Players must be eligible and opted in. Test with real accounts |
| AdService | Rewarded video ads, ad integrations | Split | `ShowRewardedVideoAdAsync` server-only, `GetAdAvailabilityNowAsync` client-only. Grant via receipt, not the show result. `ShowVideoAd` decommissioned [23] |
| ExperienceNotificationService | Opt-in prompt for experience notifications | Client | `CanPromptOptInAsync` then `PromptOptIn`. 13+ only. Sends happen via Open Cloud [22][44] |
| OpenCloudService | Old in-engine Open Cloud bridge | n/a | **Deprecated**. `GetApiV1` always errors. Use HttpService + Secrets [21] |
| ConfigService | Live config values and experiments | Server | `GetConfigAsync`, `GetConfigForPlayerAsync`. Errors on client. Up to 1,000 configs. Source is machine-translated pages [28] |
| MatchmakingService | Custom matchmaking server attributes | Server (likely) | `SetServerAttribute`, names/values 50 chars. Use `InitializeServerAttributesForStudio` to test [27] |
| SceneAnalysisService | Scene memory/render audit | Studio | Used by MCP skill `rbx-scene-analysis` [8] |
| InstanceFileSyncService | Plugin API for Script Sync status | Studio plugin | `PluginSecurity` only [25] |
| DraftsService | Drafts commit/discard | Studio plugin | Only meaningful in Drafts mode [15] |
| ScriptEditorService, ChangeHistoryService | Script editor and undo history | Studio plugin | Wrap bulk edits in a recording so users can undo (recommendation) |

### Newer or notable additions (2025-2026)

- 2026-10 builds added `CloudClientService`, `InputReplayService`, `TestCoordinatorService` (0.744, 2026-10-19), `FeatureMatchingService`, `IntegrityService` (0.745, 2026-10-26), `FriendsCallingService`, `HiddenPlayerService`, `InstanceRegistryService`, `AnimationPlayer`, `UIBlur`, `TestSuite`/`TestResult` (0.742, 2026-10-05) [20]. Purposes UNVERIFIED: docs pages not yet populated. Verify on each class page before use.
- `TestService.RegisterTestLegacy` deprecated for `RegisterTest` (2026-10) [20]. Suggests a native test runner is coming. UNVERIFIED.
- `BulkImportService` removed 2026-10-26 [20].
- Other services present in the index: `GenerationService`, `CommerceService`, `CaptureService`, `AvatarCreationService`, `CreatorStoreService`, `HapticService`, `VideoService` [19]. Purposes not checked this pass.

## 2. Studio tools and windows

UI: the new ribbon UI is mandatory since about Jan 2026 (opt-out removed) [62]. Top bar is the **mezzanine**: left = testing controls, center = tabs Home, Model, Avatar, UI, Script, Plugins, right = Collaborate, Share, Assistant, notifications [11]. There is no Test tab and no View tab by default. Add tools back with the `+` custom tab button. Custom tab JSON lives in `%LOCALAPPDATA%\Roblox\<userID>\CustomRibbonTabs` [11].

| Tool | Open via | Use for |
|---|---|---|
| Explorer, Properties | Window menu or Home tab [11] | Hierarchy and property editing |
| Output | Window menu or Script tab [11] | Logs. Blue = client, green = server in playtests [12] |
| Command Bar | Script tab, Window > Script, `Ctrl+9` [11] | One-off edit-mode Luau. Multi-line version in File > Beta Features [11] |
| Script Analysis | UNVERIFIED path (likely Window menu) | Static warnings. luau-lsp gives stricter results |
| Asset Manager, Toolbox (Creator Store) | Window menu or Home tab [11] | Places, images, meshes, packages. Store inserts may contain malicious scripts [16] |
| Developer Console | `F9`, `/console` in chat, or Roblox menu > Settings [13] | Log, Memory, Luau heap snapshots, Network, Script Profiler. Server view needs edit permission [13] |
| MicroProfiler | `Ctrl+Alt+F6` (one doc page says `Ctrl+F6`), pause `Ctrl+P` [14] | Frame-time breakdown. MCP skill `rbx-perf-profiling` reads it [8] |
| Script Profiler | Developer Console tool [13]. Studio path UNVERIFIED | CPU time per script |
| Playtest | Mezzanine left: Test (`F5`), Test Here, Run (`F8`) [12] | Solo tests. Client/server toggle during solo test |
| Multi-client local server | Dropdown > Server & Clients, pick 1-8 clients, `F7` [12] | Replication and remote testing. End Session closes all |
| Team Test | Same dropdown, needs collaboration [12] | One team test at a time |
| Device Simulator, Controller Emulator, Player Emulator | Testing controls. Player Emulator in Test menu [12] | Screen sizes, touch, gamepad, locale and policy emulation |
| Terrain Editor | Home tab [11] | Terrain generate, sculpt, import |
| Avatar tools | Avatar tab: rig tools, Avatar Setup, animation, accessory fitting [11] | Rigs, Animation Editor, layered clothing |
| UI tools | UI tab: UI object insertion, Style Editor [11] | Style sheets and tokens |
| Script History | Right-click script > View Script History [15] | Compare and restore versions |
| Settings | File > Studio Settings, File > Experience Settings, File > Beta Features [11][15][34] | Editor prefs, security, HTTP, Drafts, betas |

## 3. Collaboration and project structure

- **Experience (universe)** holds many **places**. One is the start place (where players land). Scripts see `game.GameId` (universe) and `game.PlaceId` [17].
- **Team Create**: click **Collaborate** (mezzanine right), open Manage Collaborators, which enables Team Create. Cloud autosave every 4 minutes [15].
- Collaborating with others requires an **age check** (ID or facial estimation). Solo Team Create does not [15].
- Permissions: Owner, Edit (includes Play), Play, No Access. User-owned games grant Edit only to friends. Group games use roles [15].
- **Live Scripting** (default ON): real-time shared script editing, colored cursors, autosave every 5 min, `Ctrl+S` to save now [15].
- **Drafts mode** (default OFF): File > Experience Settings > Enable Drafts Mode. All collaborators must leave the session first. Edits stay local until you commit. Merge teammates' commits from the Drafts window [15].
- Revert: only the owner reverts others' changes. Disable collaboration first so autosaves do not overwrite the revert [15].
- **Packages** [16]:
  - Create: right-click > Convert to Package. A `PackageLink` child appears. Never move or delete it.
  - Publish: right-click modified copy > Publish to Package. Others: Get Latest Package or Update All (saves, does not publish places, skips modified copies).
  - `AutoUpdate` on PackageLink updates copies when a place opens in Studio. Editing a copy disables it.
  - Versions and diff: Package Details > Versions, Compare Package Versions.
  - Nested: publish the child before the parent.
  - Script Sync can sync a package's scripts but not the `PackageLink` [9].
- **TeleportService** [17][18]:
  - `TeleportAsync(placeId, players, TeleportOptions)` from server. Client `Teleport()` is deprecated.
  - Reserved server: `options.ReservedServerId = HttpService:GenerateGUID(false)`. First teleport creates it, same ID rejoins.
  - Private (VIP) server: `options.VipServerId`. Specific server: `options.ServerInstanceId = JobId`. Set only one routing field.
  - Handle `TeleportInitFailed`, retry `Flooded`/`Failure` with backoff.
  - Place access control: Fully open, same universe, or secure within universe.

## 4. Roblox Studio MCP server (built-in)

### 4.1 Enable and connect

1. Studio: open **Assistant** > `...` > **Manage MCP Servers** > turn on **Enable Studio as MCP server**. Green indicator shows connected client count [1].
2. Quick connect: Assistant Settings > MCP Servers > Quick connect dropdown. Supports Claude Code, Claude Desktop, Codex CLI, Cursor, Gemini CLI, VS Code, Antigravity [1].
3. Manual JSON (Windows): `"command": "cmd.exe", "args": ["/c", "%LOCALAPPDATA%\\Roblox\\mcp.bat"]`. macOS: `/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP` [1].
4. Claude Code CLI form: `claude mcp add --scope user Roblox_Studio -- cmd.exe /c "%LOCALAPPDATA%\Roblox\mcp.bat"`. UNVERIFIED exact flags: confirm with `claude mcp add --help`, then `/mcp` in a session.
5. Alternative: official plugin `Roblox/roblox-studio-agent-plugin` (`/plugin`, search "Roblox Studio"). Registers `plugin:roblox-studio:windows`. Does not edit Studio settings, you still flip the toggle [5].
6. Transport is stdio only. claude.ai web cannot reach it [1][5].

### 4.2 Tools (27 in local cache) [2]

| Group | Tool | Use it when |
|---|---|---|
| Inspect | `get_studio_state` | First call. Learn play state and allowed datamodels |
| Inspect | `search_game_tree` | Map hierarchy (default depth 3, max 10, 200 results) |
| Inspect | `inspect_instance` | All properties, attributes, child counts of one path (max 20 matches) |
| Inspect | `script_search` | Find a script by fuzzy name (10 results) |
| Inspect | `script_grep` | Find code by string or Luau pattern (50 matches) |
| Inspect | `script_read` | Read source with line numbers, whole or range |
| Edit scripts | `multi_edit` | Atomic exact-match edits to one script, or create a script (`className` + empty first `old_string`). Edit datamodel only |
| Run/play | `execute_luau` | Anything else: bulk edits, queries, runtime checks in Edit/Client/Server |
| Run/play | `start_stop_play` | Enter or leave play mode |
| Run/play | `get_console_output` | Read Output after a run |
| Input | `character_navigation` | Walk the character to xyz or an instance (Client) |
| Input | `user_keyboard_input` | keyDown/keyUp/keyPress/textInput/wait (Client) |
| Input | `user_mouse_input` | Move, click, scroll on GUI or world (Client) |
| Capture | `screen_capture` | Viewport screenshot, optional camera position and look-at |
| Generation | `generate_mesh` | AI textured mesh, 12-20,000 tris, up to 8 parts. Use `async` |
| Generation | `generate_procedural_model` | Parametric primitive model with attributes. Use `async` |
| Generation | `generate_material` | MaterialVariant. Set both `Material` and `MaterialVariant` on parts |
| Generation | `generate_texture` | Re-texture a MeshPart/Model in place (Fast or Quality) |
| Generation | `segment_mesh` | Split a mesh into up to 5 named parts |
| Generation | `wait_job_finished` | Block on an async job only when you need its result |
| Assets | `search_asset` | Find assets: universe > group > user inventory > Creator Store |
| Assets | `insert_asset` | Insert by asset ID. Ask consent for cross-owner assets |
| Assets | `upload_image` | Upload images from URLs to Roblox, get `rbxassetid://` |
| Assets | `store_image` | Local png/jpg (5 MB max) to `IMAGEID_` URI for generators |
| Meta | `http_get` | Fetch Roblox docs `.md` or `llms.txt` only, with keyword filter |
| Meta | `skill` | Load a built-in skill before working in its domain |
| Meta | `subagent` | Hand off multi-step exploration to a Studio-side subagent |

Built-in skills (same 7 as Assistant's Roblox skills [8]): `rbx-create-skill`, `rbx-debug`, `rbx-device-simulator-lua`, `rbx-docs-search`, `rbx-perf-profiling`, `rbx-scene-analysis`, `rbx-unit-test` [2].

### 4.3 Datamodel rules [2]

| Datamodel | Available | Tools |
|---|---|---|
| Edit | Not in play | `multi_edit`, `execute_luau`, `search_game_tree` |
| Client | In play | input tools, `character_navigation`, `execute_luau`, `search_game_tree` |
| Server | In play | `execute_luau`, `search_game_tree` |

- Play-mode changes are discarded on stop. Persist fixes in Edit.
- `screen_capture` is described as "edit-time". Assistant docs say the capture subagent works in Edit and Play [2][7].

### 4.4 Limitations and gotchas

- Heavy `execute_luau` freezes Studio and cannot be stopped. Batch about 1,000 items per chunk and `task.wait()` per chunk. Parent big trees in small pieces [2].
- Multiple Studio windows: pass `studio_id`. Docs say get IDs from `list_roblox_studios` [1]. That tool is NOT in this machine's 27-tool cache. UNVERIFIED: run `/mcp` and list tools to see if StudioMCP.exe adds it.
- `subagent` types differ: local cache lists `explore`, `screen_capture`, `unit_test`; docs list `explore`, `playtest` [1][2]. Trust the live tool schema.
- Older tools `run_script_in_play_mode` and `get_studio_mode` (Feb 2026) are gone from the current cache [3][2].
- Generation quotas: 50 procedural models per rolling 24 h [7].
- Restart Studio and the client if tools do not appear [1].

### 4.5 Security

- Connected clients can read and modify open places. Connect only trusted clients [1].
- Creator Store inserts can carry malicious scripts. Grep inserted models for `require(` with numeric IDs, `getfenv`, `loadstring` [16].
- `upload_image` creates real assets on your account (moderation applies). Recommendation, not doc-stated.
- Never paste API keys into `execute_luau` code. Use universe Secrets [31][41].

### 4.6 Built-in vs studio-rust-mcp-server

| | Built-in (StudioMCP.exe) | studio-rust-mcp-server |
|---|---|---|
| Status | Active, ships with Studio [1] | Archived 2026-04-03, last real release v0.2.365 (2026-02-24) [4][56] |
| Architecture | Inside Studio, stdio launcher | Separate Rust binary + Studio plugin long-polling an axum server [4] |
| Tools | 27, plus skills and subagents [2] | 6: `run_code`, `insert_model`, `get_console_output`, `start_stop_play`, `run_script_in_play_mode`, `get_studio_mode` [4] |
| Multi-Studio | `studio_id` [1] | No |

## 5. Open Cloud APIs

Base `https://apis.roblox.com`. Auth: `x-api-key` header or OAuth 2.0 bearer [38].

| API | Key endpoint / scope | Limit | Dev workflow use |
|---|---|---|---|
| Place publish | `POST /universes/v1/{u}/places/{p}/versions?versionType=Published` (or `Saved`), `universe-places:write`, rbxl/rbxlx body [40] | 30/min | CI publish from a Rojo build |
| Place instances (beta) | `GET/PATCH /cloud/v2/universes/{u}/places/{p}/instances/{id}`, `:listChildren` [40] | 45/min, Source 200 KB | Patch script Source remotely. Place PATCH returns 409 during active Team Create [40] |
| Luau Execution | `POST .../places/{p}[/versions/{v}]/luau-execution-session-tasks`, scope `universe.place.luau-execution-session:write` [39] | Create 5/min, 5 min runtime, 10 concurrent per place, 4 MB script and return | Headless tests in CI (Jest), data audits. No physics, scripts do not auto-run, changes not saved [39] |
| Data stores v2 | `/cloud/v2/universes/{u}/data-stores/...entries`, `:increment`, `:listRevisions`, `:snapshot` (1/day) [42] | Shared with in-game budget [35] | Migrations, support fixes, GDPR deletes |
| Ordered data stores | `/cloud/v2/.../ordered-data-stores/{id}/scopes/{s}/entries` [42] | Same | Leaderboard repair |
| Memory stores | `/memory-store:flush`, queues, sorted maps [42] | n/a | Flush bad state, inspect matchmaking queues |
| Messaging publish | `POST /cloud/v2/universes/{u}:publishMessage`, `universe-messaging-service:publish` [41] | 5,000/min plus MessagingService limits | Live ops broadcasts, kill switches |
| Restart servers | `POST /cloud/v2/universes/{u}:restartServers`, `universe:write` [41] | 30/min | Force update after publish |
| Universe secrets | `/cloud/v2/universes/{u}/secrets` [41] | 120/min | Provision keys for `HttpService:GetSecret` |
| Configs (beta) | `/creator-configs-public-api/v1/configs/universes/{u}/repositories/{r}`: draft, publish, revisions, restore [45] | publish 10/min | Live tuning without restarts (pairs with ConfigService) |
| User restrictions (bans, beta) | `PATCH /cloud/v2/universes/{u}/user-restrictions/{id}`, `:listLogs` [43] | 10 updates/s per universe | Moderation tooling. `excludeAltAccounts` option [43] |
| Notifications | `POST /cloud/v2/users/{id}/notifications`, `user.user-notification:write` [44] | 1 per user per day per experience | Re-engagement. Template `messageId`, 200-byte launchData [44] |
| Assets (beta) | `POST/PATCH /assets/v1/assets`, versions, `:rollback`, poll operations [47] | 120/min | Upload images, audio, meshes, models, video from CI |
| Developer products (beta) | `/developer-products/v2/universes/{u}/developer-products` [48] | 3/s writes | Price/product management as code. Game passes have their own reference page [38] |
| Team Create (experimental) | `/legacy-develop/v1/universes/{u}/teamcreate` [46] | 100/min | Toggle TC, remove members |

Also listed: Analytics, Badges, Experiments, Matchmaking, Observability, Private servers, Localization, Generative AI, Thumbnails [38]. Not reviewed in detail.

**Keys and OAuth**
- API keys: Creator Dashboard > Credentials > API Keys. Scope per API and per experience. Optional IP/CIDR allowlist, but not for keys used inside Roblox places. Unused keys auto-expire after 60 days. Group automation: use a dedicated alt account with a minimal role [49].
- OAuth 2.0: authorization code (+PKCE) for third-party apps acting for users. Registration needs ID verification [50].
- Use API keys for your own CI and ops. Use OAuth only if you ship a tool other creators authorize.
- CLI wrappers: `rbxcloud` (v0.17.0, 2025-03, possibly stale) [70], Mantle (v0.11.18, 2025-03, possibly stale) [71], asphalt asset uploader (v2.0.2, 2026-07) [72].

## 6. Roblox Assistant (late 2026)

| Capability | Detail |
|---|---|
| Open | Assistant button, right side of mezzanine [7] |
| Scripts, instances, assets | Create/edit scripts across objects, edit instances, search and insert store and inventory assets [7] |
| Planning Mode | `/plan` or input dropdown. Editable Markdown plan, runs only when you click Build [7] |
| Playtesting Agent | Beta (2026-04-15). Tests against the plan via code, datamodel, logs, and driving the character [6] |
| Generation | Meshes, procedural models (50 per 24 h, 8 parts), materials, segmentation (5 parts) [7] |
| Skills | `...` > Assistant Settings > Skills. Markdown with `name`, `description`, `enabled` frontmatter. `rbx-` prefix reserved [8] |
| BYOK models | `...` > Manage API Keys: Anthropic, OpenAI, Google Gemini (2026-02-21) [3] |
| Chats | Multiple cloud-synced threads per place, branching [7] |

- Relation to MCP: the MCP server exposes Assistant's own tool layer (same generators, skills, subagents) to external agents [1][2][8]. Assistant is the in-Studio client. Claude Code is an external client of the same tools.
- Roblox says 44% of top 1,000 creators used Assistant or MCP tools in Mar to Apr 2026 [6].
- Roadmap (not shipped): parallel agents, cloud agent workflows, node graph [6]. Assistant connecting to third-party MCP servers (Figma, Blender) was "future" in Feb 2026 [3]. UNVERIFIED if shipped since.
- Separate product: **Build**, a mobile AI creator for simple 2D/2.5D games. Editing a Build game in Studio permanently removes its Build status [63].

## 7. Toolchain options

### 7.1 Tools

| Tool | Latest (date) | What | Honest tradeoff |
|---|---|---|---|
| Studio + MCP | Ships with Studio | Agent edits live datamodel | Fastest loop. No real git history of code |
| Script Sync | Native | Two-way scripts to `.luau` files [9] | Scripts and Folders only. Attributes/tags on synced scripts can be lost. No sourcemap [9][10] |
| Rojo | 7.7.1 (2026-10-02) [51] | Filesystem is source of truth, build, serve, sourcemap | No Team Create support. Some properties (terrain, CSG, MeshId) do not live-sync [52]. Plugin `twoWaySync` exists, default false [53] |
| Rojo syncback | 7.7.0 (2026-07-02) [51] | `rojo syncback <project> --input place.rbxl` converts a place to files | One-shot conversion, not live sync |
| Argon | 2.0.29 (2026-05-19) [54] | Rojo-compatible (`rojo_mode` default true) live two-way sync of code and instances | Smaller community. One maintainer |
| Wally | 0.3.2 (2023-06) [60] | Package manager, de facto registry | Releases stagnant. Needs `wally-package-types` for types |
| pesde | 0.7.4 (2026-09-09) [64] | Luau package manager, Roblox + Lune, own registry, can use Wally sources | Younger ecosystem |
| Rokit | 1.2.0 (2025-09-30) [55] | Toolchain manager, reads `aftman.toml` and `foreman.toml` | Recommended. Aftman archived [65]. Foreman 1.7.0 (2026-05) is Roblox-internal focused [66] |
| Selene | 0.32.0 (2026-10-01) [57] | Linter | Needs `std = "roblox"` |
| StyLua | 2.6.0 (2026-10-10) [58] | Formatter | Local is 2.5.2. Update with rokit |
| luau-lsp | 1.70.1 (2026-09-27) [59] | Types, autocomplete, diagnostics. Recommended by Script Sync docs with the Luau Language Server Companion plugin [9] | Wants a sourcemap (from Rojo) or the companion plugin |
| Lune | 0.11.1 (2026-10-21) [61] | Standalone Luau runtime for scripts, can read/write place files | Local is 0.10.5. No engine physics or rendering |
| darklua | 0.19.0 (2026-06-10) [67] | Luau transforms, bundling, path-require conversion | Extra build step |
| run-in-roblox | 0.3.0 (2020-07) [68] | Run a script in Studio from CLI | Stale. Drives EDIT datamodel only (no players) |
| Jest Roblox | 3.20.0 per README [69] | Jest port. Wally `roblox/jest`, `roblox/jest-globals`. Runs in Studio or via Luau Execution for CI | The supported choice now |
| TestEZ | 0.4.2, archived [73] | Old BDD tests | Do not start new suites on it. jsdotlua/jest-lua last release 2024-12 [74] |

### 7.2 Git workflows

- Rojo project: code (and optionally models as `.rbxm`/`.model.json`) in git. Feature branches. `rojo build -o game.rbxl` then publish via Open Cloud [40][51].
- Bootstrap an existing game: `rojo syncback` from the live place file [51].
- `.rbxl` is binary: undiffable, use for builders' content outside git or in Team Create. `.rbxlx` is XML and diffable but noisy and huge. Prefer Rojo-managed files for anything you want reviewed.
- `sourcemap.json` is in Rojo's default `.gitignore` since 7.6.1 [51]. Regenerate with `rojo sourcemap --watch`.
- Script Sync + git: git tracks only scripts. Map and UI remain in Studio's cloud history.

### 7.3 Team Create plus Rojo pitfalls

- Rojo does not support Team Create. Its serve overwrites synced trees with your local files [10].
- Two people serving Rojo into one TC session overwrite each other. One "sync owner" per tree at most.
- Rule: Rojo owns code folders (ServerScriptService, shared modules). Builders own Workspace and UI in TC. Never edit Rojo-managed scripts in Studio.
- Script Sync is the TC-safe alternative, but do not have two people syncing the same script [9].
- Live Scripting edits by teammates land in Studio, then sync to the disk of whoever syncs that folder. Communicate.

## 8. When to switch

| Situation | Recommended toolchain | Reason |
|---|---|---|
| Solo dev, quick prototype | Studio + MCP | Zero setup, agent edits live datamodel |
| Solo dev, long-lived game | Studio + MCP + Script Sync (code folders) + git | Gets history and LSP without leaving Studio-first |
| 2-3 scripters | Team Create Live Scripting + MCP, Script Sync per owner | Real-time edits, low ceremony |
| 4+ scripters on same modules | Rojo (or Argon) + git + PR review, Wally/pesde, selene, StyLua | Merge conflicts need branches, not live overwrites |
| Builders + scripters mixed | TC for world/UI, Rojo or Script Sync for code folders only | Split ownership avoids overwrites |
| Heavy UI artist team | TC + Studio UI tab and Style Editor, code in Script Sync | UI is instance data, files cannot hold it well |
| Live game with ops needs | Any of the above + Open Cloud keys (bans, configs, messaging, restart, datastore migrations) | Ops without shipping a build |
| CI/testing wanted | Rojo build + Jest Roblox via Luau Execution + Open Cloud publish | Only file-based builds give reproducible CI |

MCP stays useful in every row for inspection, playtesting, and capture, even when code lives in files.

## Sources

[1] Connect to the Roblox Studio MCP server - https://create.roblox.com/docs/studio/mcp - checked 2026-11-03
[2] Studio MCP tool manifest (local dump, Studio cache 2026-10-17) - docs/roblox/studio-mcp-tools.md - checked 2026-11-03
[3] Studio MCP Server Updates and External LLM Support for Assistant (DevForum, 2026-02-21) - https://devforum.roblox.com/t/studio-mcp-server-updates-and-external-llm-support-for-assistant/4415631 - checked 2026-11-03
[4] Roblox/studio-rust-mcp-server README - https://github.com/Roblox/studio-rust-mcp-server - checked 2026-11-03
[5] Roblox/roblox-studio-agent-plugin - https://github.com/Roblox/roblox-studio-agent-plugin - checked 2026-11-03
[6] Roblox Studio is Going Agentic (2026-04-15) - https://about.roblox.com/newsroom/2026/04/roblox-studio-going-agentic - checked 2026-11-03
[7] Assistant guide - https://create.roblox.com/docs/assistant/guide - checked 2026-11-03
[8] Assistant skills - https://create.roblox.com/docs/assistant/skills - checked 2026-11-03
[9] Script Sync - https://create.roblox.com/docs/scripting/sync - checked 2026-11-03
[10] Studio Script Sync, Now In Beta (DevForum, 2025-11-12) - https://devforum.roblox.com/t/studio-script-sync-now-in-beta/4065468 - checked 2026-11-03
[11] Studio UI overview - https://create.roblox.com/docs/studio/ui-overview - checked 2026-11-03
[12] Studio testing modes - https://create.roblox.com/docs/studio/testing-modes - checked 2026-11-03
[13] Developer Console - https://create.roblox.com/docs/studio/developer-console - checked 2026-11-03
[14] MicroProfiler - https://create.roblox.com/docs/performance-optimization/microprofiler - checked 2026-11-03
[15] Collaboration - https://create.roblox.com/docs/projects/collaboration - checked 2026-11-03
[16] Packages - https://create.roblox.com/docs/projects/assets/packages - checked 2026-11-03
[17] Teleport between places - https://create.roblox.com/docs/projects/teleport - checked 2026-11-03
[18] TeleportOptions - https://create.roblox.com/docs/reference/engine/classes/TeleportOptions - checked 2026-11-03
[19] Engine API index - https://create.roblox.com/docs/reference/engine/llms.txt - checked 2026-11-03
[20] Roblox API updates 2026 (community mirror) - https://robloxapi.github.io/ref/updates/2026.html - checked 2026-11-03
[21] OpenCloudService (community mirror) - https://robloxapi.github.io/ref/class/OpenCloudService.html - checked 2026-11-03
[22] ExperienceNotificationService - https://create.roblox.com/docs/reference/engine/classes/ExperienceNotificationService - checked 2026-11-03
[23] AdService - https://create.roblox.com/docs/reference/engine/classes/AdService - checked 2026-11-03
[24] Chat - https://create.roblox.com/docs/reference/engine/classes/Chat - checked 2026-11-03
[25] InstanceFileSyncService - https://create.roblox.com/docs/reference/engine/classes/InstanceFileSyncService - checked 2026-11-03
[26] InputContext - https://create.roblox.com/docs/reference/engine/classes/InputContext - checked 2026-11-03
[27] MatchmakingService - https://create.roblox.com/docs/reference/engine/classes/MatchmakingService - checked 2026-11-03
[28] ConfigService (via translated pages) - https://create.roblox.com/docs/reference/engine/classes/ConfigService - checked 2026-11-03
[29] MarketplaceService - https://create.roblox.com/docs/reference/engine/classes/MarketplaceService - checked 2026-11-03
[30] BadgeService - https://create.roblox.com/docs/reference/engine/classes/BadgeService - checked 2026-11-03
[31] HttpService - https://create.roblox.com/docs/reference/engine/classes/HttpService - checked 2026-11-03
[32] MessagingService - https://create.roblox.com/docs/reference/engine/classes/MessagingService - checked 2026-11-03
[33] Memory stores - https://create.roblox.com/docs/cloud-services/memory-stores - checked 2026-11-03
[34] Data stores - https://create.roblox.com/docs/cloud-services/data-stores - checked 2026-11-03
[35] Data store error codes and limits - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits - checked 2026-11-03
[36] Unifying Data Stores Open Cloud and Game APIs (DevForum, 2026-07-15) - https://devforum.roblox.com/t/unifying-data-stores-open-cloud-and-game-apis-and-increasing-storage-limits/4739240 - checked 2026-11-03
[37] Instance streaming - https://create.roblox.com/docs/workspace/streaming - checked 2026-11-03
[38] Open Cloud docs index - https://create.roblox.com/docs/cloud/llms.txt - checked 2026-11-03
[39] Luau Execution API - https://create.roblox.com/docs/cloud/reference/features/luau-execution - checked 2026-11-03
[40] Places API - https://create.roblox.com/docs/cloud/reference/features/places - checked 2026-11-03
[41] Universes API - https://create.roblox.com/docs/cloud/reference/features/universes - checked 2026-11-03
[42] Data and memory stores API - https://create.roblox.com/docs/cloud/reference/features/storage - checked 2026-11-03
[43] Bans and blocks API - https://create.roblox.com/docs/cloud/reference/features/bans-and-blocks - checked 2026-11-03
[44] Notifications API - https://create.roblox.com/docs/cloud/reference/features/notifications - checked 2026-11-03
[45] Configs API - https://create.roblox.com/docs/cloud/reference/features/configs - checked 2026-11-03
[46] Team Create API - https://create.roblox.com/docs/cloud/reference/features/team-create - checked 2026-11-03
[47] Assets API - https://create.roblox.com/docs/cloud/reference/features/assets - checked 2026-11-03
[48] Developer products API - https://create.roblox.com/docs/cloud/reference/features/developer-products - checked 2026-11-03
[49] Manage API keys - https://create.roblox.com/docs/cloud/auth/api-keys - checked 2026-11-03
[50] OAuth 2.0 overview - https://create.roblox.com/docs/cloud/auth/oauth2-overview - checked 2026-11-03
[51] Rojo releases (7.6.0 to 7.7.1) - https://github.com/rojo-rbx/rojo/releases - checked 2026-11-03
[52] Rojo sync details - https://rojo.space/docs/v7/sync-details/ - checked 2026-11-03
[53] Rojo plugin Settings.lua - https://github.com/rojo-rbx/rojo/blob/master/plugin/src/Settings.lua - checked 2026-11-03
[54] Argon releases - https://github.com/argon-rbx/argon/releases - checked 2026-11-03
[55] Rokit - https://github.com/rojo-rbx/rokit - checked 2026-11-03
[56] studio-rust-mcp-server releases (GitHub API) - https://github.com/Roblox/studio-rust-mcp-server/releases - checked 2026-11-03
[57] Selene releases - https://github.com/Kampfkarren/selene/releases - checked 2026-11-03
[58] StyLua releases - https://github.com/JohnnyMorganz/StyLua/releases - checked 2026-11-03
[59] luau-lsp releases - https://github.com/JohnnyMorganz/luau-lsp/releases - checked 2026-11-03
[60] Wally releases - https://github.com/UpliftGames/wally/releases - checked 2026-11-03
[61] Lune releases - https://github.com/lune-org/lune/releases - checked 2026-11-03
[62] Roblox Studio UI forced update (PiunikaWeb, 2026-01-06, secondary) - https://piunikaweb.com/2026/01/06/roblox-studio-ui-forced-update-creators-furious/ - checked 2026-11-03
[63] Create games with Build - https://create.roblox.com/docs/ai/build - checked 2026-11-03
[64] pesde releases - https://github.com/pesde-pkg/pesde/releases - checked 2026-11-03
[65] Aftman (archived) - https://github.com/LPGhatguy/aftman - checked 2026-11-03
[66] Foreman releases - https://github.com/Roblox/foreman/releases - checked 2026-11-03
[67] darklua releases - https://github.com/seaofvoices/darklua/releases - checked 2026-11-03
[68] run-in-roblox - https://github.com/rojo-rbx/run-in-roblox - checked 2026-11-03
[69] Jest Roblox README - https://github.com/Roblox/jest-roblox - checked 2026-11-03
[70] rbxcloud releases - https://github.com/Sleitnick/rbxcloud/releases - checked 2026-11-03
[71] Mantle releases - https://github.com/blake-mealey/mantle/releases - checked 2026-11-03
[72] asphalt releases - https://github.com/jackTabsCode/asphalt/releases - checked 2026-11-03
[73] TestEZ (archived) - https://github.com/Roblox/testez - checked 2026-11-03
[74] jest-lua releases - https://github.com/jsdotlua/jest-lua/releases - checked 2026-11-03
