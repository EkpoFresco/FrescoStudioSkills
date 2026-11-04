# Genre: Roguelike and Roguelite
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - run-based co-op survival is one of Roblox's hottest shapes: Doors (roguelite horror), 99 Nights in the Forest (14.2M peak CCU), Dead Rails (6.64B visits) [1][2].
Top Roblox references (mechanics only):
- Doors (LSPLASH and Red, 2022): rooms in sequence, items, entities with tells. Modifiers added Aug 2023, second floor Aug 2024 [1].
- 99 Nights in the Forest: co-op survival run toward a night count; 26B visits by Apr 2026 [1].
- Dead Rails: Western exploration run along a rail line; 6.64B visits, ~20K CCU [2].
- Deepwoken: hardcore permadeath RPG with paid access (price UNVERIFIED) [3].
- Turn-based RPG niche: Loomian Legacy and Arcane Lineage hold small loyal audiences [4].

## Core loop
- Lobby, party up, start run, pick items or perks, escalate, die or win, earn meta currency, unlock permanent upgrades, rerun.
- Run length 15-30 min on Roblox. Checkpoint per floor to protect mobile disconnects (heuristic).
- Every run, even a failed one, must move a visible meta bar (heuristic).

## Session one (what works in a first session on Roblox, minute by minute where possible)
- 0-1 min: lobby elevator or queue pad, solo or 4-player party, short countdown.
- 1-5 min: zero-threat rooms teach interact, hide, pick up.
- 5-10 min: first threat with a clear telegraph (sound before entity). Death likely, cheap.
- 10-15 min: first death, result screen: meta currency, "room X, best Y".
- 15-25 min: second run with a first permanent unlock; go further.
- Doors-style rule: every threat has a learnable tell, so deaths feel fair (heuristic).

## Retention hooks (D1 / D7 / D30)
- D1: next unlock, beat best depth, achievement list.
- D7: daily seeded run with leaderboard, weekly modifiers.
- D30: new floors or biomes, hard modes (Doors added modifiers after launch [1]).
- Friends who have not cleared it yet are the best hook: carries and bragging (heuristic).

## Monetization norms (what players accept on Roblox for this genre)
- Accepted: revives (cheap, capped per run), starter-item boosts, skins, class unlocks, private servers.
- Paid revives in co-op feel fair when an earnable revive also exists (heuristic).
- Perk chests sold for Robux are paid random items: disclose all odds before purchase [5].
- Paid-access games only work with existing hype (heuristic).

## Social and discovery levers
- 4-player parties. Chat and voice need age checks and connect only similar ages [6].
- Keep parties together into reserved run servers via `Player.PartyId` [7].
- Clutch revives and dramatic deaths are clip material (heuristic).
- Jump scares rate Mild; realistic gore rates Moderate and drops Roblox Kids (5-8) [8].

## Technical traps on Roblox
- Generate rooms server-side from a seed; stream in ahead, unload behind (heuristic).
- One run per reserved server (`TeleportOptions.ReservedServerId`); wrap teleports in pcall and retry. Teleport data is client-visible [7].
- Mid-run state for rejoin: MemoryStore or DataStore, within 4,194,304 characters per key and write budgets [9].
- Many chasing NPCs plus pathfinding is server-heavy. Cap active entities (heuristic).
- Send room layouts only when needed so exploiters cannot map ahead (heuristic).

## What transfers from outside Roblox (what to keep, what breaks on Roblox's young, mobile, short-session audience)
External titles are common design references, described from general knowledge (heuristic).
- Keep: Hades meta-progression with story reasons to rerun; Slay the Spire branching paths; Vampire Survivors build snowball; Lethal Company co-op comedy and proximity voice.
- Breaks: hour-long runs, wiping all progress for kids, dense synergy text, solo-only design.
- Adapt: 3-choice perk picks with icons, short runs, an unlock every run.

## Octalysis read (dominant drives, 2-4 bullets)
- CD7 Unpredictability: run variety.
- CD8 Loss and Avoidance: death stakes.
- CD2 Accomplishment: depth records and unlocks.
- CD5 Social: co-op carries.

## Sources
[1] List of Roblox games (Wikipedia) - https://en.wikipedia.org/wiki/List_of_Roblox_games - checked 2026-11-03
[2] Rotrends Exploration subgenre - https://rotrends.com/games/genre%3Asub%3AExploration - checked 2026-11-03
[3] RoWatcher: Deepwoken, inside Roblox's most brutal hardcore RPG - https://rowatcher.com/news/deepwoken-inside-roblox-s-most-brutal-hardcore-rpg - checked 2026-11-03 (search excerpt only)
[4] Rotrends Turn-based RPG subgenre - https://rotrends.com/games/genre%3Asub%3ATurn-based%20RPG - checked 2026-11-03
[5] Paid random items policy guidelines (Creator Docs) - https://create.roblox.com/docs/production/monetization/paid-random-items - checked 2026-11-03
[6] Roblox Newsroom: age checks and chat limits (Nov 2025) - https://about.roblox.com/newsroom/2025/11/roblox-requires-age-checks-limits-minor-and-adult-chat - checked 2026-11-03
[7] Teleport between places (Creator Docs) - https://create.roblox.com/docs/projects/teleporting - checked 2026-11-03
[8] Content maturity labels (Creator Docs) - https://create.roblox.com/docs/production/promotion/content-maturity - checked 2026-11-03
[9] Data store error codes and limits (Creator Docs) - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits - checked 2026-11-03
