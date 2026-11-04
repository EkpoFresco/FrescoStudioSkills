# Genre: Shooter (FPS/TPS, arena, tactical)
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - short rounds, cross-platform input, and cosmetic economies fit; Rivals won Best Shooter in 2025 and 2026 [1][2].
Top Roblox references (mechanics only):
- Rivals (Nosniy Games, June 2024): 1v1 to 5v5 duels, first to 5 rounds, ranked ladder, cosmetic-only monetization. Peak 967,342 CCU per one tracker [3].
- Arsenal (ROLVe, 2015): gun-rotation FFA, each kill swaps your weapon [4].
- Phantom Forces (StyLiS): class loadouts, long unlock tree, large-map team modes [4].
- Frontlines (Maximillian, Feb 2023): high-fidelity military FPS from a 5-person team; 3K to 6K CCU at launch [5][6].
- Hypershot: hero-lite arena shooter; tracker peak 87K on 2026-01-31 [7].

## Core loop
- Queue, spawn, fight, round ends, rewards (XP, keys), unlock or equip, requeue.
- Rivals: keys earned from wins and level-ups unlock weapons permanently [3].
- Rounds under 3 minutes keep mobile sessions dense (heuristic).

## Session one
- 0 to 1 min: land in a lobby with a visible queue pad or Play button. No menus before the first fight (heuristic).
- 1 to 5 min: first match with a starter loadout; first win pays keys or XP.
- 5 to 15 min: first unlock choice, first cosmetic seen on other players (desire seed).
- Ranked gated: Rivals requires Level 50 plus verification before ranked [3].

## Retention hooks (D1 / D7 / D30)
- D1: unlock next weapon, daily quests, close-match near misses.
- D7: season pass progress, ranked placement, map pool rotation.
- D30: rank tiers (Rivals: Bronze to Archnemesis, hidden MMR), seasonal resets, tournaments [3].
- Cadence: Rivals shipped 19 major updates in 21 months [3].

## Monetization norms
- Cosmetic only is the accepted norm for competitive shooters. Rivals: skin cases 249 Robux, season pass built to return about 5x value if completed [3].
- Weapon wraps, charms, finishers, emotes, bundles.
- Pay-for-power guns are punished in reviews (heuristic).
- Price testing needs about 60,000 transactions in 30 days and dynamic prices from MarketplaceService [8].

## Social and discovery levers
- Duo and squad queues, party joins via Player.PartyId and SocialService [9].
- Input-based matchmaking: Rivals separates mobile from mouse and keyboard [3]. Roblox matchmaking has a Device Type signal [10].
- Clips, kill montages, and creator tournaments drive discovery (heuristic).

## Technical traps on Roblox
- Hit registration default pattern: client raycasts, server validates type, angle, distance, and obstruction (official laser tag tutorial) [11].
- Favor-the-shooter plus server rewind: store short position history per character, rewind to the shooter timestamp, cap the window. Community practice; common cap 150 to 200 ms UNVERIFIED [12].
- Server Authority (prediction plus rollback) is in beta per docs as of 2026-11-02. It lacks built-in latency-compensated hit detection; you build rewind yourself [13][14][15].
- Rollback cost: a 100 ms correction can need 6.25x the simulation load [14].
- Projectiles: FastCast (segmented raycasts, drop) last versioned Nov 2020; no built-in net compensation [16].
- Tracers and muzzle FX on UnreliableRemoteEvent: unordered, payload over 1000 bytes dropped, about 500 req/s per client shared [17].
- Movement exploits: client owns its character; speed and teleport need server checks (leaky bucket, XZ projection) [15].
- Ranked integrity: Device Trust API; docs suggest ranked only for Standard or Full trust [18].
- Mobile: aim assist, larger hitboxes, separate pools. Keep effects cheap (heuristic).

## What transfers from outside Roblox
- CS and Valorant: round economy, map bans, first-to-N rounds (Rivals uses map bans) [3].
- CoD: fast TTK, killstreaks, loadout unlocks.
- Battle passes that refund the next pass (Fortnite pattern) [3].
- Hard lesson: competitive shooters live or die on anti-cheat trust (heuristic).

## Octalysis read
- Accomplishment (CD2): ranks, unlocks, kill feed.
- Ownership (CD4): skins and wraps as identity.
- Social Influence (CD5): visible cosmetics, rivalries.
- Unpredictability (CD7): cases, but keep core fairness deterministic.

## Sources
[1] Roblox reveals 2025 Innovation Awards winners (PocketGamer.biz) - http://www.pocketgamer.biz/roblox-reveals-2025-innovation-awards-winners/ - checked 2026-11-03
[2] 2026 Roblox Innovation Awards (Roblox Newsroom) - https://about.roblox.com/newsroom/2026/09/2026-roblox-innovation-awards - checked 2026-11-03
[3] RIVALS: How Roblox's Top Shooter Built a Nearly Million-Player Empire (RoWatcher) - https://rowatcher.com/news/rivals-how-roblox-s-top-shooter-built-a-nearly-million-player-empire - checked 2026-11-03
[4] List of Roblox games (Wikipedia) - https://en.wikipedia.org/wiki/List_of_Roblox_games - checked 2026-11-03
[5] Roblox Frontlines devs interview (Insider Gaming, 2023-03-08) - https://insider-gaming.com/roblox-frontlines-developers/ - checked 2026-11-03
[6] Inside Roblox Studio: creator interviews (Roblox Newsroom, 2026-07-01) - https://about.roblox.com/newsroom/2026/07/roblox-studio-fidelity-creator-interviews-twin-atlas-fluorlite-maximillian-ecos - checked 2026-11-03
[7] Hypershot stats (RoWatcher) - https://rowatcher.com/games/5995470825 - checked 2026-11-03
[8] Price optimization (Roblox Docs) - https://create.roblox.com/docs/production/monetization/price-optimization - checked 2026-11-03
[9] SocialService (Roblox Docs) - https://create.roblox.com/docs/reference/engine/classes/SocialService - checked 2026-11-03
[10] Matchmaking attributes and signals (Roblox Docs) - https://create.roblox.com/docs/matchmaking/attributes-and-signals - checked 2026-11-03
[11] Detect hits tutorial (Roblox Docs) - https://create.roblox.com/docs/tutorials/curriculums/gameplay-scripting/detect-hits - checked 2026-11-03
[12] Am I doing hitbox replication right? (DevForum) - https://devforum.roblox.com/t/am-i-doing-hitbox-replication-right/4773807 - checked 2026-11-03
[13] Server authority model (Roblox Docs) - https://create.roblox.com/docs/projects/server-authority - checked 2026-11-03
[14] Server Authority tech deep dive (DevForum, 2026-05-08) - https://devforum.roblox.com/t/server-authority-tech-deep-dive-engineering-insights/4624565 - checked 2026-11-03
[15] Network ownership, movement validation, and physics (Roblox Docs) - https://create.roblox.com/docs/scripting/security/network-ownership - checked 2026-11-03
[16] FastCast Redux (DevForum) - https://devforum.roblox.com/t/fastcast-redux/133474 - checked 2026-11-03
[17] UnreliableRemoteEvent (Roblox Docs) - https://create.roblox.com/docs/reference/engine/classes/UnreliableRemoteEvent - checked 2026-11-03
[18] Device trust (Roblox Docs) - https://create.roblox.com/docs/scripting/security/device-trust - checked 2026-11-03
