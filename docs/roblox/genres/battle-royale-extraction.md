# Genre: Battle Royale and Extraction
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: weak (BR) to medium (extraction) - BR needs big stable lobbies and long sessions; extraction fits a niche hardcore audience.
Top Roblox references (mechanics only):
- Island Royale: classic build-and-shoot BR; about 20K CCU on weekend peaks at its height [1].
- Strucid: BR plus building; named as a fallen leader [1].
- Rift Royale (Easy.gg): pulled by its developer in Aug 2022 over cheaters [2].
- Project Delta: raid-based extraction, deploy from a Metro hub, 20-second extract countdown, periodic wipes [3].
- Apocalypse Rising 2: persistent open-world survival shooter, no extract, death loses progress [3].

## Core loop
- BR: drop, loot, rotate with the zone, fight, last squad wins, rewards, requeue.
- Extraction: prep loadout from stash, deploy, loot, survive PvPvE, extract to bank loot, sell or upgrade at traders, repeat [3].
- Extraction loss risk is the whole hook: gear at stake makes every fight matter (heuristic).

## Session one
- 0 to 2 min: hub or lobby with one big Play button; free starter kit so loss feels cheap (heuristic).
- 2 to 10 min: first raid on a smaller, safer map or a timed solo tutorial raid (heuristic).
- 10 to 20 min: first successful extract, first trader sale, first stash upgrade shown.
- BR first match should fill with bots if lobbies are thin, or the queue kills the game (heuristic).

## Retention hooks (D1 / D7 / D30)
- D1: stash growth, trader quests (Project Delta NPC quests pay Rubles and unlocks) [3].
- D7: quest chains, rare loot hunts, hideout or trader levels.
- D30: wipes reset progress; carry cosmetics and premium currency across wipes (Project Delta keeps skins and Delta Bux) [3].
- BR: season pass, ranked, limited modes.

## Monetization norms
- Cosmetics, season pass, private servers for squads.
- Extraction: stash size, cosmetic gear skins. Selling power gear breaks raid fairness (heuristic).
- Paid access is possible but cannot be combined with private servers [4].
- Project Delta monetization specifics UNVERIFIED.

## Social and discovery levers
- Squad queue via parties (Player.PartyId, SocialService) [5].
- Streamer moments: extract-with-loot clips, "lost everything" reactions (heuristic).
- Group membership perks are cheap acquisition (heuristic).

## Technical traps on Roblox
- Why BR faded: lobby fill threshold, 20 to 40 minute mobile sessions vs long loot phases, and 100-player server cost with desync. Tracker says aggregate BR DAU fell an estimated 73% from 2020 [1].
- Large maps need StreamingEnabled; Server Authority also requires it [6].
- Hit reg and movement: same as shooters. Client-owned characters can teleport and speed; validate on server [7].
- Matchmaking: queue in MemoryStore (queue structure, 45-day max expiry, request budget 1000 + 120 x CCU per minute) [8], then TeleportAsync with TeleportOptions.ReservedServerId (GUID) [9].
- Reserved servers block late joiners after the initial teleport, so plan backfill [10].
- Teleports can fail; wrap in pcall with retries and handle TeleportInitFailed [11].
- Stash and raid loot: save with UpdateAsync, not SetAsync, to avoid lost updates and dupes [12].
- Exploit surface is huge when loot is permanent. Use Device Trust to gate high-stakes modes [13].

## What transfers from outside Roblox
- Tarkov: stash, traders, insurance, wipes. Shrink session length for Roblox.
- Fortnite: zone pacing, bus drop, season pass.
- Hunt and Arc Raiders: PvPvE AI as pressure, solo-friendly extraction (heuristic).
- Lesson: shorter raids (8 to 15 min) and smaller lobbies (heuristic).

## Octalysis read
- Loss and Avoidance (CD8): gear at risk.
- Unpredictability (CD7): loot rolls, encounters.
- Ownership (CD4): stash as collection.
- Accomplishment (CD2): successful extracts, wins.

## Sources
[1] Is Battle Royale Dead on Roblox? (RoWatcher) - https://rowatcher.com/news/is-battle-royale-dead-on-roblox-the-data-says-yes - checked 2026-11-03
[2] List of Roblox games (Wikipedia) - https://en.wikipedia.org/wiki/List_of_Roblox_games - checked 2026-11-03
[3] Project Delta vs Apocalypse Rising 2 (Earnaldo, promotional blog, 2026-07-03) - https://earnaldo.com/blog/project-delta-vs-apocalypse-rising-2 - checked 2026-11-03
[4] Private servers (Roblox Docs) - https://create.roblox.com/docs/production/monetization/private-servers - checked 2026-11-03
[5] SocialService (Roblox Docs) - https://create.roblox.com/docs/reference/engine/classes/SocialService - checked 2026-11-03
[6] Server authority model (Roblox Docs) - https://create.roblox.com/docs/projects/server-authority - checked 2026-11-03
[7] Network ownership, movement validation, and physics (Roblox Docs) - https://create.roblox.com/docs/scripting/security/network-ownership - checked 2026-11-03
[8] Memory stores (Roblox Docs) - https://create.roblox.com/docs/cloud-services/memory-stores - checked 2026-11-03
[9] Teleport to private servers (Roblox Docs) - https://create.roblox.com/docs/projects/teleport-private-servers - checked 2026-11-03
[10] Public servers vs. reserved servers (DevForum) - https://devforum.roblox.com/t/public-servers-vs-reserved-servers/3471347 - checked 2026-11-03
[11] Teleport between places (Roblox Docs) - https://create.roblox.com/docs/projects/teleport - checked 2026-11-03
[12] Best practices for data stores (Roblox Docs) - https://create.roblox.com/docs/cloud-services/data-stores/best-practices - checked 2026-11-03
[13] Device trust (Roblox Docs) - https://create.roblox.com/docs/scripting/security/device-trust - checked 2026-11-03
