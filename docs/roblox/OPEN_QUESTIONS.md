# Open Questions

Last checked: 2026-11-03. What the research could not verify, and how you can verify it fast.
Every file in `docs/roblox/` marks its own gaps with `UNVERIFIED` (about 170 tags in total). Find them with: `grep -rn UNVERIFIED docs/roblox`.
Research note: the web search budget ran out partway through Phase 2, so later facts came from direct page fetches. Facts most likely to move are listed first.

## High impact (affects what the studio recommends)

| # | Question | Why it matters | How to verify (fastest first) |
|---|---|---|---|
| 1 | Is the under-16 audience gate now 100 qualifying plays (was 250 in 60 days)? | Launch plan math for every new game. | Creator Hub > your experience > Audience Reach tab. |
| 2 | What counts as a "qualified play" (minimum seconds) after QPTR was replaced by PTR + first-play bounce (2026-06-15)? | The QPTR-over-CTR playbook now targets PTR and bounce; the threshold sets the first-60 target. | Ask staff on DevForum; compare Home Page tab columns in Creator Analytics. |
| 3 | Does thumbnail personalization rank by PTR or by the old QPTR? | `/rbx-thumbnail` A/B plan metric. | Creator Hub > Analytics > Home Page / thumbnail test results columns. |
| 4 | How are Trending, Up-and-Coming, Fun with Friends, Top Revisited charts ranked? | Which chart a launch should aim at. | DevForum staff question; or track chart placement daily for 2 weeks via Rotrends / RoWatcher. |
| 5 | Do ratings (likes) feed ranking at all? | Whether "like prompts" are worth UI space. | Not in Roblox's signal list; ask staff. |
| 6 | Did the "Maximize Spend" ads objective ship? | Ads budget logic in `/rbx-launch`. | Ads Manager > Create campaign > Objectives list. |
| 7 | `BindReceiptHandler` ship date and whether it is GA. | Data skills recommend it alongside `ProcessReceipt`. | Engine release notes / DevForum Announcements; Studio autocomplete. |
| 8 | Economy event currency cap: 5 or 10 per experience? | `/rbx-telemetry` plans for 5 until confirmed. | AnalyticsService API page vs limits table; log 6 currencies in a test place. |
| 9 | Live Studio MCP tool list: is `list_roblox_studios` exposed, and which `subagent` types exist (local cache says explore, screen_capture, unit_test)? | Skills call MCP tools by name. | Connect Studio MCP, run `/mcp` in Claude Code, read the tool list. Regenerate `studio-mcp-tools.md` with `node tools/dump-mcp-manifest.js`. |
| 10 | Script Sync: full release (2026-06-17) or still beta? | Toolchain recommendation between Script Sync and Rojo. | Studio > File > Beta Features. |

## Medium (numbers and edge details)

| # | Question | How to verify |
|---|---|---|
| 11 | Cube 3D / generation quotas (procedural model cap is documented as 50 per 24 h). | Creator Dashboard > Extended Services; log the error when a limit hits. |
| 12 | Ownership terms for AI-generated assets. | Roblox Terms of Use, AI and User Content sections (blocked automated reads). |
| 13 | Audio upload quota (2,000 vs 100 per 30 days for ID-verified). | Creator Dashboard upload quota display. |
| 14 | Memory cost of SurfaceAppearance and MaterialVariant. | Developer Console `GraphicsTexture` before/after in a test place. |
| 15 | `--!optimize` levels and `--!native` gains in real Studio servers (Lune showed none). | Script Profiler on a server run, before/after. |
| 16 | Attribute vs ValueObject replication bandwidth. | Studio network stats with 2 clients. |
| 17 | `Stats.InstanceCount` deprecation status. | Studio autocomplete / class page. |
| 18 | Roblox Plus launch details (2026-04-30) and Plus discount effect on displayed prices. | "Introducing Roblox Plus" DevForum thread. |
| 19 | Rewarded video revenue share. | Creator Hub > Ads earnings page. |
| 20 | Advertising Standards full text (help center blocked automated reads). | Open in a browser. |
| 21 | Unrated-experience enforcement date (about 2025-09-30). | DevForum Announcements archive. |
| 22 | Meme / "brainrot" IP takedown examples. | lumendatabase.org search "Roblox" + character names. |
| 23 | New Oct 2026 services: IntegrityService, CloudClientService, TestCoordinatorService. | Engine class pages. |

## Third-party data

| # | Question | How to verify |
|---|---|---|
| 24 | Rotrends future (footer says "Chartis", possible shutdown notice). | Open rotrends.com in a browser. |
| 25 | RoMonitor Stats owner (Gamefam vs Silicon Digital Group). | RoMonitor terms page. |
| 26 | Paid tiers for Creator Exchange, ROLearn, RoMonitor, GameAnalytics. | Pricing pages in a real browser. |
| 27 | Sensor Tower, AppMagic, Naavik, Konvoy Roblox coverage. | Search each site for "Roblox". |
| 28 | Several game-specific numbers in genre files (prices, peaks) come from single sources. | Each is tagged UNVERIFIED in its genre file; check the game page or a tracker. |

## How the studio handles these

- Agents read the library and must repeat an `UNVERIFIED` tag when they rely on one.
- When a live check is cheap (Studio MCP, `gh`, a dashboard number you paste), skills ask for it instead of guessing.
- Update a fact in `docs/roblox/`, then run the installer with `-Update` so every machine gets it.
