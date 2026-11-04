# Roblox Third-Party Data and Market Intelligence

Last checked: 2026-11-03. Sources at bottom.

Scope: every serious public tool for Roblox competitor and market data, what each one holds, what it costs, and how studio agents should use it. Live numbers quoted below are snapshots from 2026-11-03 unless dated otherwise.

## TL;DR for agents

- No third party sees retention, revenue, or QPTR. They see public fields only: CCU, visits, favorites, votes, created/updated dates, genre, creator, chart positions, game pass prices [13][3]. Every "revenue" number is a model [3][27].
- Current leaders (Nov 2026): **CCUCheck** (best API, has an MCP server for AI agents, early-find feed) [8][10], **RobloxGameStats** (the tool the developer named; new, revenue model with published method, free JSON API) [1][3][5], **RoWatcher** (fully free, breakout tracker, weekly reports, free API) [12][14], **Rotrends** (best per-game chart-placement history; ownership in flux) [21], **RoMonitor Stats** (oldest, best platform-level and branded/concert data, browser extension) [18].
- Default free stack for an agent: CCUCheck no-sign-in MCP or API for numbers, Rotrends game page for chart placement history, RobloxGameStats for session length and update markers, RoWatcher for genre and breakout context.
- Platform CCU totals disagree by source (10.8M to 22M on the same day) because each sums a different set of tracked games [1][7][20][31]. Never mix sources in one trend line.
- Per-game CCU also disagrees by source and freshness: Steal An Egg read 906K, 955K, 959K, and 522K on four sites the same morning [18][33][31][34]. Record which site and timestamp you used.
- 2025 breakouts rose fast and fell fast. Grow a Garden left the top 10 by Dec 2025; Steal a Brainrot lost about 30% of monthly visits from its Aug 2025 peak by Dec [41].
- 2026 pattern to study: Steal An Egg was created 2026-07-25, hit #1 Up-and-Coming by 2026-08-07, peaked at 14.3M CCU, and spawned a copycat wave ("Break and Steal an Egg", "Detect and Steal an Egg", "Fake an Egg") within weeks [21][1][17].
- Seasonality is large: Halloween 2026 lifted weekly platform averages to about 15M to 16.6M CCU, then the week of Oct 26 averaged 12.1M (-2.7% WoW) [15][16]. Saturdays are the peak day [31][40].
- If a site blocks scraping or renders only with JavaScript, try its API first, then ask the user to paste the numbers. Do not guess.
- Super Biz (ex-Bloxbiz) self-serve ads and analytics platform is being deprecated [25]. Do not recommend it.

## Tool directory

Status key: **active** = live data on 2026-11-03; **stale** = site up but content or features not updated recently; **dead** = gone or not a market tool.

### Tier 1: game and market trackers (current leaders)

| Tool | URL | Status | Data it has | Access | Cost | Studio skill |
|---|---|---|---|---|---|---|
| CCUCheck | ccucheck.com | Active. Live count stamped 15:30 UTC 3 Nov 2026 [7] | CCU (daily since 21 Feb 2026, 10-min detail since 7 Jun 2026), visits, likes, favourites, all-time peak, created/updated dates, chart positions, movers, "name trends", genres, studio pages, "found early" new-game feed. 101,433 games [8][9] | Free web; REST API (no key: 60/hr; free key 1,000/day; Pro 20,000/day); CLI; MCP server; CSV on Pro [9][10] | Free (30 days history); Pro $29/mo or $290/yr (about 8 months history, 50 alerts, CSV); Studio $499/mo or $4,990/yr (games found in first 14 days) [8] | /rbx-teardown, /rbx-genre, /rbx-concept, /rbx-launch |
| RobloxGameStats | robloxgamestats.com | Active. Launched 2026; changelog entries through Sep 2026 [4] | CCU every 5 min for top games, visits, likes, favorites, session length, server size, game passes and prices, update markers, name history, chart rank history, records, top developers, estimated history back to launch (rebuilt from badge stats), modeled revenue [3][4] | Free web; free JSON API at /api/v1 (60 req/min, non-commercial, revenue fields null unless signed in); CSV for signed-in users [5][4] | Free (revenue for top 10 only); Pro $19/mo list, $12/mo founding price (44 of 50 left), $149/yr [2] | /rbx-teardown, /rbx-metrics (benchmark), /rbx-concept |
| RoWatcher | rowatcher.com | Active. Weekly report dated 2 Nov 2026 [16] | Live CCU, 90 days history (1 yr and all-time with free account), revenue estimates, CCU forecasts, breakout "algorithm tracker", genre pages, market map, remake candidates, weekly reports [12][14][11] | Free web; public API 500 req/day no key, 1,000/day per free key [12] | Free, no paid plans [12] | /rbx-genre, /rbx-concept, /rbx-launch |
| Rotrends | rotrends.com | Active data, uncertain future. Footer now reads "Chartis © 2026"; news last posted Jun 2025 [20][22] | CCU, peak, visits, favorites, rating, created/updated, genre and subgenre, maturity, avg CCU with percentile, avg session, favorites per 1,000 visits, platform share, **Roblox chart placements with date ranges**, earning rank, game pass and dev product counts, groups, UGC [21][20] | Free web; Pro adds metrics, export, flexible date ranges [23] | Free; Pro price UNVERIFIED [23][24] | /rbx-teardown (chart history), /rbx-genre |
| RoMonitor Stats | romonitorstats.com | Active. Live CCU list on 3 Nov 2026 [18] | Platform CCU (all-time peak 42.57M, 14-day avg 12.68M), top experiences, top developers by visits, branded experiences, official concerts, community (group) pages, milestones, name changes, DevEx calculator [18][19] | Free web; Chrome extension shows stats on Roblox game pages; iOS and Android apps; consulting [18][19] | Free web; paid tier details UNVERIFIED [6] | /rbx-teardown, /rbx-launch (branded, events) |

### Tier 2: useful secondary trackers

| Tool | URL | Status | Data it has | Access | Cost | Studio skill |
|---|---|---|---|---|---|---|
| RoStats | rostats.io | Active ("updated 1 minute ago") [26] | CCU sampled 5 min to 12 hr by game size, visits, genre, creators, estimated earnings and session, update spikes, keywords, badges, marketplace for buying games. 67,252 games [26][27] | Free web (7-day history, top 100); Pro: 29-column table, CSV, alerts, history back to May 2026 [27] | Pro $20/mo [27] | /rbx-teardown, /rbx-concept |
| RoSignal | rosignal.net | Active, Public Beta v0.1.0 [28] | Observed CCU, momentum, estimated revenue, "opportunity score", opportunity scanner, trending by genre [28] | Free web (beta) | Free during beta; later pricing UNVERIFIED | /rbx-concept |
| RobloxTracker | robloxtracker.net | Active, refreshes every 15 min [29] | CCU, 24h peak, monthly average, trending, declining, hidden gems, heatmap of top 200 by momentum, tag-level 30-day charts, recently updated list [29] | Free web; blocks plain HTTP fetch (403), renders in a real browser [29] | Free | /rbx-genre (heatmap, tags) |
| Bloxodes Stats | bloxodes.com/stats | Active, refreshed 36 min before check [31] | Platform CCU, genre mix with game counts, fastest risers, players by day of week, monthly reports. 96,784 games [30][31] | Free web; no API or export found [30] | Free | /rbx-genre, /rbx-launch (day-of-week) |
| Creator Exchange | creatorexchange.io | Active [32] | Platform CCU with week average (12.6M, -2.8% WoW), top 100 by 30-day earnings, trending, marketplace to buy and sell games, thumbnail generator [32][6] | Free web; Pro tier [6] | Pro price UNVERIFIED (pricing page did not render) | /rbx-teardown, /rbx-thumbnail |
| ROLearn | rolearn.dev | Active [33] | CCU (11.1M platform, 187.2K experiences), "Game DNA", hourly and daily CCU charts per game. Mostly player-facing (quests, squads) [33] | Free web; "ROLearn Pro" for developers [33] | Pro price UNVERIFIED | Low priority |
| Rolimons Games | rolimons.com/games | Active, but CCU looked stale vs other sites [34] | Players, upvote score, sort by playing, visits, votes; genre filter; promotion rates; mainly an items and trading site [34] | Free web | Free | Cross-check only |
| profitable.app | profitable.app/roblox | Active (title dated Nov 2026) [36] | CCU, visits, revenue estimates for 10,000+ games, game ideas. Details UNVERIFIED (seen via search summary only) | Free web | UNVERIFIED | /rbx-concept (cross-check) |

### Tier 3: SDKs, bots, scrapers, reports

| Tool | URL | Status | Data it has | Access | Cost | Studio skill |
|---|---|---|---|---|---|---|
| GameAnalytics Roblox SDK | gameanalytics.com/use-cases/roblox | Active; offers a "2026 Roblox Benchmark Report" [37] | Your own game only: sessions, retention, spend, ARPU, A/B tests, remote configs, segments; raw export via PipelineIQ to BigQuery or S3 [37] | SDK in your game; "get started free" | Paid tiers UNVERIFIED | /rbx-metrics |
| Roblox Creator Analytics | create.roblox.com/docs/production/analytics | Active (first party) [38] | Your own game only: DAU, new users, session time, D1/D7/D30, revenue, payer conversion, ARPPU, acquisition by source, play-through rate, benchmarks vs similar games [38][39] | Creator Dashboard | Free | /rbx-metrics, /rbx-thumbnail, /rbx-launch |
| RoLive (Discord bot) | rolive.app | Active [35] | Live stats for your games and groups posted to Discord [35] | Discord bot | Free plan covers 1 game; paid UNVERIFIED | /rbx-metrics (alerts) |
| roblox-stats-tracker (open source) | github.com/DindinYT37/roblox-stats-tracker | Code exists; activity UNVERIFIED [42] | Logs visits, favorites, players, group members, votes to CSV on an interval [42] | Self-host | Free | /rbx-teardown (own logger) |
| Apify Roblox scrapers | apify.com/s_actors/roblox-game-stats-tracker | Listed [43] | Players, visits, votes as JSON [43] | Paid scraping platform | Apify usage pricing | Only if free APIs fail |
| Super Biz (ex-Bloxbiz) | superbiz.gg | **Stale / winding down.** Self-serve platform deprecated, sign-ups closed [25] | Was: in-experience ads, free analytics SDK, Rotrends | Closed | n/a | Do not use |
| rbxstats.com / rbxstats.xyz | rbxstats.com | **Not a market tool.** Login wall only; .xyz returns an empty page [44] | None usable | n/a | n/a | Do not use |
| Newzoo (via GameDev Reports) | gamedevreports.substack.com | Active; Apr 2026 recap of 2025 [41] | Quarterly visit rankings, peak CCU tiers, platform bookings, concentration of top-10 visits [41] | Free summary; full Newzoo reports paid | Free summary | /rbx-genre, /rbx-concept |
| GameDiscoverCo | newsletter.gamediscover.co | Active newsletter [40] | Case studies such as Grow a Garden's 8.9M CCU weekend (May 2025) [40] | Free posts, paid tier | Free posts | /rbx-concept, /rbx-launch |

### Leads not verified this pass (budget ran out)

| Lead | What to check | How to verify |
|---|---|---|
| Sensor Tower, AppMagic | App-level Roblox mobile revenue and downloads by country | Open each vendor's Roblox app page; their blogs publish free Roblox estimates. Ask the user for a paid seat if they have one. |
| Naavik, Deconstructor of Fun, Konvoy | Roblox market essays and deck-style reports | Fetch naavik.co, deconstructoroffun.com, konvoy.vc and search their archives for "Roblox" 2025 to 2026 posts. |
| Gamefam, Kinetic (agency reports) | Branded-experience reach reports | Fetch gamefam.com. Note: GameDev Reports credits data to "Gamefam RoMonitor Stats" [41], and RoMonitor links to Gamefam's creator fund [18], so RoMonitor may be Gamefam-owned. Ownership UNVERIFIED; RoMonitor's footer names Silicon Digital Group Ltd [18]. |
| Rotrends Pro price and the "deprecated on August 31" notice | A search index showed pages titled "An update from the Rotrends Team" mentioning deprecation on Aug 31 (no year). The site still served live data on 2026-11-03 under a "Chartis" footer [20] | Open rotrends.com in a browser and read any banner; check Rotrends or Super League social posts. |
| X/Twitter trackers (@RoMonitorStats, @RoWatcherHQ, others) | Real-time breakout callouts | Accounts are linked from the sites [18][12]. Activity UNVERIFIED; open the profiles while signed in. |
| Twitch and YouTube trend tools (TwitchTracker, StreamsCharts, vidIQ) | Streamer and video interest in a game before CCU moves | Fetch twitchtracker.com Roblox category page; search YouTube by game name sorted by upload date. |
| Roblox Game Stats Discord bot (DevForum thread 2441438) | Possibly another tool named "Roblox Game Stats" | Open devforum.roblox.com/t/roblox-game-stats/2441438 and check last reply date. |
| statroblox.com | Stats checker with revenue estimate | Root domain did not resolve on 2026-11-03. Retry later. |

## How analytics firms and top studios read trends

### Genre rise detection

- **Sum CCU across a genre, not one game.** Bloxodes and RoWatcher publish genre mix: on 2026-11-03 Simulation held about 4M CCU across 19,866 tracked games, Survival 1.4M across 5,967 [31]. Track the genre total weekly.
- **Watch genre WoW change.** RoWatcher's weekly report names the hottest and coldest genre (week of Oct 26, 2026: RPG +96.7%, Entertainment -22.3%, Simulation -6.2%) [16].
- **Count new entrants holding players.** RoStats Pro and CCUCheck "found early" filter by creation date with a player floor [27][8]. A genre is rising when several games under 30 days old hold 10K+ CCU at once. RobloxGameStats "New game radar" lists games released in the last 30 days with CCU and day-over-day change [1].
- **Name-pattern waves.** CCUCheck has a "Name trends" chart [7]. Agents can also count title tokens in new-game lists ("Steal", "+1", "Ragdoll", "Egg") as a cheap proxy.

### Breakout patterns

| Game | Curve evidence | Source |
|---|---|---|
| Grow a Garden (2025) | Acquired at about 1K CCU, scaled by ~12-person team; weekly Saturday 7am PT update; 8.9M CCU during a limited-time Saturday event; 1.5M to 2.5M baseline; 21.3M record later in Jun 2025 | [40][22] |
| Steal a Brainrot (2025) | 26.4B visits in Q3 2025; about -30% monthly visits from Aug peak by Dec; still 74.3B lifetime visits, ~85K to 100K CCU now, -69.5% WoW in the week of Oct 26, 2026 | [41][16][1] |
| 99 Nights in the Forest (2025) | Over 10B visits within a few months of launch; still about 156K CCU in Nov 2026 | [41][18] |
| Steal An Egg (2026) | Created Jul 25; #1 Up-and-Coming Aug 7 to 22; #1 Top Trending Aug 13 to Sep 26; peak 14.3M CCU; Oct 2026 monthly avg about 2.3M; Nov 3 avg CCU 7d 1.03M (-12.6%) | [21][29] |
| Dead Rails (2025) | Not covered in sources checked. UNVERIFIED | Check a Rotrends or RobloxGameStats game page for its chart history |

What a breakout looks like in public data:
1. Days 0 to 14: CCU climbs from near zero. First chart signal is **Up-and-Coming**, then **Top Trending**, then **Top Playing Now** and **Top Earning** [21]. Rotrends shows these placements with dates, which is the best free view of the sequence [21].
2. Momentum ratio: RoWatcher flags games running 2x to 4x their usual CCU as "surging", then "peaked", then "cooling" [14]. Most flags are small regional games, so set a CCU floor (for example 5K) before acting.
3. Peak is often an event, not an update. Grow a Garden's 8.9M came from a limited-time event [40]. Murder Mystery 2 averaged far above its normal CCU in Oct 2026, then fell 84.1% WoW [29][16].
4. Decay: 2025 records were followed by "equally rapid declines" [41]. Assume a breakout loses most of its peak within 2 to 4 months unless the team ships a steady cadence. This window is an inference from [41][21], not a measured rule.
5. Concentration rises in breakout years: the top title's share of top-10 visits went from 22% (Q1 2025) to 43% (Q4 2025) [41].

### Update cadence vs player count

- Weekly fixed-time updates create a weekly CCU sawtooth. Grow a Garden shipped every Saturday 7am PT [40].
- RobloxGameStats and RoStats mark update times on CCU charts; RoStats Pro overlays this week vs last week to show whether an update moved players [3][27]. Use these to measure each competitor's lift per update.
- Title tags like "[UPD]", "[🎃]", "[UPDATE 5]" signal live ops; nearly every top-20 game carried a Halloween tag on 2026-11-03 [1][29].

### Seasonality and time zones

- Holidays: weekly platform average CCU was 15.1M (week of Oct 5), 16.6M (week of Oct 24), then 12.1M (Oct 26 to Nov 1, 2026) [15][16]. Sep 28 to Oct 4 averaged 11.2M, peak 15.5M [17].
- Weekends: Bloxodes' busiest recent day was Saturday Sep 5 with 15.7M players [30]; Grow a Garden's record was a Saturday [40].
- Platform records came from events: Rotrends and RoMonitor list all-time platform peaks of 47.3M and 42.6M respectively [20][18]. The two disagree; cite the source.
- Time zones: RoWatcher's surge list on 2026-11-03 was dominated by Indonesian, Filipino, and Malaysian titles spiking at their local evening [14]. A spike at 03:00 UTC is usually Southeast Asia, not a global breakout. Check the game's language and its CCU at US evening hours.

### Copycat waves

- 2026 egg wave: after Steal An Egg, "Break and Steal an Egg" hit 392K CCU in its first weeks, plus "Steal an Clown Egg", "Detect and Steal an Egg" (+317% in a day), "Fake an Egg", "Launch an Egg", "Be An Animal For Eggs", "Steal A Balut" [17][1][31][20].
- Other live waves on 2026-11-03: "+1 ..." titles (+1 Spider Arm, +1 Anime Eyes, +1 Venom Evolution) and ragdoll sandboxes (Ragdoll Playground, Ragdoll Sandbox, Ragdoll Reality) [1][16].
- Saturation signal: the first fast follower can reach 10% to 40% of the original's CCU; later entrants fall quickly (Grow a Pet Fighter -70.8% WoW) [17]. Treat as an observation from a few weekly reports, not a law.
- GameDiscoverCo's warning: copying a viral formula does not guarantee success; execution still decides [40].

## How an agent should use this

### Competitor teardown (/rbx-teardown), free sources only

1. Get the universe ID or place ID from the Roblox URL the user gives.
2. Pull numbers: `curl -A "studio-agent/1.0 (contact)" https://ccucheck.com/api/v1/games/{placeId}` returns players now, visits, likes, favourites, all-time peak, created and updated dates, each with `as_of` [9]. If MCP is configured, use `claude mcp add --transport http --scope user ccucheck https://ccucheck.com/mcp`; the no-sign-in endpoint is `https://apps.ccucheck.com/mcp` (30 days history) [10].
3. Pull history and updates: `https://robloxgamestats.com/api/v1/games/{universeId}` and `/series?days=90` for hourly CCU, update times, daily visits, session length, like rating [5].
4. Pull chart history: open the Rotrends game page for chart placements with date ranges, percentile ranks, and pass and product counts [21].
5. Compute: peak vs current CCU, 7-day average trend, favorites per 1,000 visits, like ratio, days since last update, update lift (CCU 24h after vs 24h before each update marker).
6. Revenue: quote two estimates (RobloxGameStats Pro, RoWatcher, RoStats, Creator Exchange) as a range and label them modeled. Never quote one estimate as fact [3][27].
7. Write the teardown with a table that lists source and timestamp for every number.

### Trend validation (/rbx-concept, /rbx-genre), free sources only

1. Define the concept's genre and 3 to 5 title tokens.
2. Genre size: read genre CCU and game counts on Bloxodes platform stats and RoWatcher genres [31][11].
3. Direction: read the last 4 RoWatcher weekly reports for genre WoW moves [15].
4. New entrants: list games under 30 days old in that genre from RobloxGameStats "New games" or the CCUCheck free "found early" feed [1][8].
5. Saturation: count titles sharing the tokens and how many hold over 1K CCU. Many entrants with fast-falling CCU means the wave is late.
6. Leader health: if the genre leader's 7-day CCU is down over 10% and it has not updated in 3+ weeks, the space may be opening.
7. Seasonality check: compare to the same week last year if history exists (RobloxGameStats estimates back to launch [3]).
8. Output: verdict (rising, flat, saturated), evidence table, and what would change the verdict.

### Launch timing (/rbx-launch)

- Avoid launching into a Roblox-wide event week; spikes inflate competition and then collapse [16].
- Ship updates at a fixed weekly time before the weekend peak (Friday or Saturday US morning), the Grow a Garden pattern [40].
- Set CCUCheck or RoWatcher alerts on your game and 3 rivals [8][12].

### When a site blocks scraping

1. Try the site's official API first (CCUCheck, RobloxGameStats, RoWatcher all have free ones) [9][5][12].
2. Many sites are JavaScript apps (RoMonitor, RoSignal, RobloxTracker returned empty pages or 403 to plain fetch). A real browser render works, but do not hammer it.
3. If still blocked, stop and ask the user: "Paste the CCU, visits, favorites, like % and last-updated date from [site] for [game], with the time you looked."
4. Never invent or interpolate a number. Mark gaps as `UNVERIFIED`.
5. Respect rate limits: CCUCheck no-key 60/hr; RobloxGameStats 60/min; RoWatcher 500/day [9][5][12].

## Roblox's own data vs third-party data

| Metric | Creator Dashboard (owner only) | Third parties (public) |
|---|---|---|
| CCU / playing now | Yes | Yes, polled every 5 min to 12 hr [26] |
| Visits, favorites, up/down votes | Yes | Yes [13] |
| Created, updated, genre, creator, group members | Yes | Yes [13] |
| Chart / sort positions | Partly | Yes, via explore API sorts [13][21] |
| Game pass prices | Yes | Yes; dev product counts on Rotrends [13][21] |
| DAU, new users | Yes [38] | No (estimated from player-hours [3]) |
| Session time | Yes [38] | Estimated (player-hours / new visits) [3] |
| D1, D7, D30 retention | Yes [38] | No |
| Revenue, payer conversion, ARPPU | Yes [38] | Modeled only [3] |
| Acquisition by source, impressions, play-through rate | Yes [39] | No |
| QPTR (qualified play-through) | Owner-side discovery metric; the analytics pages checked reference "users with qualified plays" but do not define it [39] | No |
| Benchmarks vs similar games | Yes, once a game has 100+ DAU; updated daily; not a direct discovery signal [38] | Percentile ranks on Rotrends are a public proxy [21] |

Caveats:
- **Revenue is modeled.** RobloxGameStats: monthly revenue ≈ player-hours × earnings per player-hour by genre, anchored 70% to the Top Earning chart rank for the top 200 games [3]. RoStats weights by genre and store [27]. Treat estimates as plus or minus a lot, especially for new or small games.
- **History before tracking may be synthetic.** RobloxGameStats rebuilds pre-tracking history from badge award stats and smooths it [3]. CCUCheck history only starts Feb 2026 [8]. RoStats from May 2026 [27].
- **Botted and AFK CCU.** AFK-farm and idle games inflate CCU and session length. Example: "Post Rolimon Trade Ads While AFK" ranked in Rotrends' top by session time [20]; some games show 130 to 180 minute sessions [1]. A GameDiscoverCo reader disputed that Grow a Garden had no bot inflation [40]. Check like ratio, votes per visit, and favorites per 1,000 visits; bots rarely vote or favorite.
- **Sources disagree.** Same-day platform CCU ranged 10.8M (RobloxGameStats tracked games), 11.9M (RoWatcher), 12.6M (CCUCheck), 12.9M (RoSignal), to about 19M to 22M (Rotrends) [1][11][7][28][20]. Pick one source per analysis.
- **Some content is low trust.** RoWatcher news is high volume with analyst personas; use its data tables, treat opinion articles as unverified [15].
- **Your own diagnosis (/rbx-metrics) must use Creator Dashboard or your own SDK.** Third-party data is only for competitors and market context.

## Sources

[1] RobloxGameStats home - https://robloxgamestats.com/ - checked 2026-11-03
[2] RobloxGameStats Pricing - https://robloxgamestats.com/pricing - checked 2026-11-03
[3] RobloxGameStats, How our revenue estimates work - https://robloxgamestats.com/docs/methodology - checked 2026-11-03
[4] RobloxGameStats Changelog - https://robloxgamestats.com/changelog - checked 2026-11-03
[5] RobloxGameStats API - https://robloxgamestats.com/docs/api - checked 2026-11-03
[6] RobloxGameStats, Best Roblox analytics sites in 2026 (vendor-written) - https://robloxgamestats.com/best-roblox-analytics-sites - checked 2026-11-03
[7] CCUCheck home - https://ccucheck.com - checked 2026-11-03
[8] CCUCheck Pricing - https://ccucheck.com/pricing - checked 2026-11-03
[9] CCUCheck API docs - https://ccucheck.com/docs - checked 2026-11-03
[10] CCUCheck MCP for AI agents - https://ccucheck.com/docs/mcp - checked 2026-11-03
[11] RoWatcher home - https://rowatcher.com/ - checked 2026-11-03
[12] RoWatcher Pricing - https://rowatcher.com/pricing - checked 2026-11-03
[13] RoWatcher Data Sources (public Roblox endpoints) - https://rowatcher.com/data-sources - checked 2026-11-03
[14] RoWatcher Algorithm Tracker - https://rowatcher.com/algorithm - checked 2026-11-03
[15] RoWatcher News index - https://rowatcher.com/news - checked 2026-11-03
[16] RoWatcher, The Roblox Week in Numbers, Oct 26 to Nov 1, 2026 - https://rowatcher.com/news/roblox-week-in-numbers-2026-w44 - checked 2026-11-03
[17] RoWatcher, The Roblox Week in Numbers, Sep 28 to Oct 4, 2026 - https://rowatcher.com/news/roblox-week-in-numbers-2026-w40 - checked 2026-11-03
[18] RoMonitor Stats home - https://romonitorstats.com/ - checked 2026-11-03
[19] RoMonitor Stats Chrome extension - https://chrome.google.com/webstore/detail/romonitor-stats-roblox-st/ednkdolfafcikdchfnffkecohpnifogc - checked 2026-11-03
[20] Rotrends home - https://www.rotrends.com/ - checked 2026-11-03
[21] Rotrends, Steal An Egg game page - https://www.rotrends.com/game/10563114921/Steal-An-Egg - checked 2026-11-03
[22] Rotrends News - https://www.rotrends.com/news - checked 2026-11-03
[23] Roblox DevForum, Rotrends: analyze trends, keywords, and game stats - https://devforum.roblox.com/t/rotrends-%E2%80%93-analyze-trends-keywords-and-game-stats/3471292 - checked 2026-11-03
[24] Super League, Rotrends Pro press release (Aug 2025) - https://ir.superleague.com/news-events/press-releases/detail/263/super-league-taps-surging-demand-for-roblox-trend - checked 2026-11-03 (via search summary)
[25] Super Biz, Super Biz is evolving - https://superbiz.gg/ - checked 2026-11-03
[26] RoStats home - https://rostats.io/ - checked 2026-11-03
[27] RoStats Pro - https://rostats.io/pro - checked 2026-11-03
[28] RoSignal - https://rosignal.net/ - checked 2026-11-03
[29] RobloxTracker - https://www.robloxtracker.net/ - checked 2026-11-03
[30] Bloxodes Stats - https://bloxodes.com/stats - checked 2026-11-03
[31] Bloxodes Platform Stats - https://bloxodes.com/stats/roblox-platform - checked 2026-11-03
[32] Creator Exchange - https://creatorexchange.io/ - checked 2026-11-03
[33] ROLearn - https://rolearn.dev/ - checked 2026-11-03
[34] Rolimon's Roblox Games - https://www.rolimons.com/games - checked 2026-11-03
[35] RoLive - https://rolive.app/ - checked 2026-11-03
[36] profitable.app Roblox - https://profitable.app/roblox - checked 2026-11-03 (title only)
[37] GameAnalytics, Roblox use case - https://www.gameanalytics.com/use-cases/roblox - checked 2026-11-03
[38] Roblox Creator Hub, Analytics - https://create.roblox.com/docs/production/analytics - checked 2026-11-03
[39] Roblox Creator Hub, Acquisition analytics - https://create.roblox.com/docs/production/analytics/acquisition - checked 2026-11-03
[40] GameDiscoverCo, What Grow A Garden's 8.9 million CCU tells us about game discovery (May 27, 2025) - https://newsletter.gamediscover.co/p/what-grow-a-gardens-89-million-ccu - checked 2026-11-03
[41] GameDev Reports, Newzoo: Top Roblox Games in 2025 (Apr 17, 2026) - https://gamedevreports.substack.com/p/newzoo-top-roblox-games-in-2025 - checked 2026-11-03
[42] GitHub, roblox-stats-tracker - https://github.com/DindinYT37/roblox-stats-tracker - checked 2026-11-03 (via search summary)
[43] Apify, Roblox Player Count Tracker - https://apify.com/s_actors/roblox-game-stats-tracker - checked 2026-11-03 (via search summary)
[44] RbxStats - https://rbxstats.com/ - checked 2026-11-03
