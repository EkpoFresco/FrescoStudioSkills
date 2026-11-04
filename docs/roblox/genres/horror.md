# Genre: Horror (co-op, chase, story, asymmetric)
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - shared fear in co-op lobbies, chapter updates, and YouTuber reactions; horror and anime surged in 2021 per Roblox [1].
Top Roblox references (mechanics only):
- Doors (LSPLASH and Red): co-op run through procedurally ordered rooms, entity-specific counterplay, meta currency (Knobs), modifiers; DOORS won Best Use of Audio 2026 [2][3].
- Piggy (MiniToon, 2020): chapter-based chase horror, one player can be the killer; 12B plays by Nov 2023 [4][1].
- Evade: 3-minute rounds, sound-reactive nextbot chasers [1].
- Forsaken: asymmetric 8 survivors vs 1 killer, 9-player lobbies, peak over 138K CCU, Best Survival 2025 [5][6].
- Dandy's World (2024): co-op horror with collectible characters, peak about 238.9K (Oct 2025), Best Party and Casual 2025 [4][6].

## Core loop
- Co-op run: enter, explore, solve light puzzles, survive entities, die or reach the end, earn meta currency, unlock items or characters, run again.
- Asymmetric: queue, roll killer or survivor, complete objectives or hunt, earn points, unlock characters [5].
- Chapter games: play the new chapter, theorize lore, wait for the next one [1].

## Session one
- 0 to 1 min: lobby with an elevator or queue pad; join friends or randoms (heuristic).
- 1 to 5 min: safe intro room, then first scare within 2 to 3 minutes (heuristic).
- 5 to 15 min: first death, quick learn of one entity's rule (hide, look away, stay still).
- End of run: payout screen showing progress toward the first unlock (heuristic).

## Retention hooks (D1 / D7 / D30)
- D1: unlock next item or character with meta currency (Forsaken Player Points) [5].
- D7: achievements per entity, harder modifiers, quest chains (Forsaken hidden survivor quest) [5].
- D30: new floor or chapter, lore mysteries, seasonal events [1].
- Mystery is a stated draw: "always so much for players to discover" (MiniToon) [1].

## Monetization norms
- Revives sold for Robux (Doors) UNVERIFIED price [2].
- Meta currency packs and run boosters (Doors Knob boosts multiply gold to Knobs) UNVERIFIED rates.
- Character and killer skins, emotes, larger private lobbies (Pressure passes reportedly include bigger lobbies) UNVERIFIED.
- Keep core runs free; sell convenience and identity (heuristic).

## Social and discovery levers
- YouTubers and streamers drive discovery of story and chase games [1].
- Remix culture: fans make knockoffs; strong brand and fast follow-ups protect you [1].
- Voice chat is proximity based by default and lifts engagement [7].
- Friends-in-lobby matchmaking signal keeps groups together [8].

## Technical traps on Roblox
- Pathfinding: Roblox pathfinding saves small teams work, but chasers need tuning for stuck states [1].
- Scares must be client-side and timed; latency ruins jump scares. Drive the entity on the server, fire reveal FX locally (heuristic).
- Chaser hit checks: server distance check on catch; never trust client "I hid" flags (heuristic).
- Procedural rooms: stream rooms in and out to keep mobile memory low (heuristic).
- Lighting and fog carry mood cheaply; heavy future lighting hurts low-end phones (heuristic).
- Sound design is the product; budget it (Doors audio award) [3].

## What transfers from outside Roblox
- FNAF: simple autonomous creatures plus pop-ups [1].
- Dead by Daylight: asymmetric killer kits, generator style objectives [1].
- Lethal Company and Phasmophobia: co-op comedy-horror, proximity voice.
- Outlast and Amnesia: hide-and-avoid with no combat.

## Octalysis read
- Loss and Avoidance (CD8): dread of death.
- Curiosity and Unpredictability (CD7): what is behind the door.
- Social Influence (CD5): shared screams, carrying friends.
- Epic Meaning (CD1): lore and chapter mysteries.

## Sources
[1] Why are horror games so popular on Roblox? (Game Developer, 2022-11-22) - https://www.gamedeveloper.com/design/why-are-horror-games-so-popular-on-roblox- - checked 2026-11-03
[2] DOORS Knobs (Doors Wiki, fetch blocked; via search snippet) - https://doors-game.fandom.com/wiki/Knobs - checked 2026-11-03
[3] 2026 Roblox Innovation Awards (Roblox Newsroom) - https://about.roblox.com/newsroom/2026/09/2026-roblox-innovation-awards - checked 2026-11-03
[4] List of Roblox games (Wikipedia) - https://en.wikipedia.org/wiki/List_of_Roblox_games - checked 2026-11-03
[5] Forsaken's Floral Update Drives the Survival Horror Hit Past 86K Players (RoWatcher) - https://rowatcher.com/news/forsaken-s-floral-update-drives-the-survival-horror-hit-past-86k-players - checked 2026-11-03
[6] Roblox reveals 2025 Innovation Awards winners (PocketGamer.biz) - http://www.pocketgamer.biz/roblox-reveals-2025-innovation-awards-winners/ - checked 2026-11-03
[7] Voice chat (Roblox Docs) - https://create.roblox.com/docs/chat/voice-chat - checked 2026-11-03
[8] Matchmaking attributes and signals (Roblox Docs) - https://create.roblox.com/docs/matchmaking/attributes-and-signals - checked 2026-11-03
