# Genre: Fishing, Collection and Chill
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - Fisch (5.1B visits) and Grow a Garden (21.3M CCU in June 2025) prove calm collection loops can become Roblox's biggest games [1][2].
Top Roblox references (mechanics only):
- Fisch (Fisching group, created Mar 2024): cast, reel minigame, sell, better rods and bait, new islands; 5.1B visits, ~80K CCU now, 1.3M peak [1]. Creator WoozyNate and a Nov 2024 DoBig acquisition per fan wiki (UNVERIFIED) [3].
- Grow a Garden (Mar 2025): plant, offline growth, harvest, sell, rotating seed stock, weekly exclusives; 35.3B visits by May 2026 [2]. Now ~17K CCU, a steep fall from peak [4].
- Bee Swarm Simulator (Onett): incremental collection of bees and fields [5].
- Steal a Brainrot: collection plus theft; 25.4M CCU in Oct 2025 [6]. Not chill, same collection engine.

## Core loop
- Fishing: cast, timing minigame, catch with a rarity roll, sell or log in a journal, upgrade rod or bait, travel to new water, hunt weather or time-window rares.
- Garden: buy seeds, plant, wait (growth continues offline), harvest, sell, rarer seeds, pets [2].
- Long goal: complete the collection book (heuristic).

## Session one (what works in a first session on Roblox, minute by minute where possible)
- 0-1 min: rod in hand, water in view, first cast within 20 s (heuristic).
- 1-3 min: guaranteed first catch; forgiving minigame.
- 3-6 min: sell; buy first upgrade.
- 6-12 min: scripted lucky rare with a server-wide shout.
- 12-20 min: next location unlocked or teased; journal shows empty slots.
- Grow a Garden opens with an empty plot and Sheckles for carrot seeds [2].

## Retention hooks (D1 / D7 / D30)
- D1: offline growth or traps to collect; daily stock.
- D7: weekly exclusives that require being online [2]; weather and admin events; rotating shop stock.
- D30: journal completion, new biomes, seasonal fish, trading.
- Warning: Grow a Garden peaks did not hold; CCU fell from 21.3M to 7.6M within an hour of the record [2]. Events need a durable loop under them.

## Monetization norms (what players accept on Roblox for this genre)
- Accepted: rod, bait and seed packs, storage, auto-fish or auto-harvest passes, skip-wait products, private servers.
- Fisch runs 9 game passes and 697 developer products [1]. Grow a Garden sells speed-ups, perks, crop stealing and pet loot boxes; its partner drew criticism for heavy monetization [2].
- Luck boosts are probability modifiers under paid random item rules: explain before purchase, show updated odds while active [7].
- Chill players resent pressure. Sell accelerators, not gates (heuristic).

## Social and discovery levers
- Server-wide rare-catch announcements; shared weather everyone plays together (heuristic).
- Trading builds an economy. Off-platform real-money trading breaks Roblox terms [2]. Respect `IsPaidItemTradingAllowed` [7].
- Cross-game events: a mock admin war between Steal a Brainrot and Grow a Garden pushed Roblox to 47.4M concurrent [6].
- Wide age spread: ~35% of Grow a Garden players under 13, per its developer [2].

## Technical traps on Roblox
- Offline growth from saved server timestamps only (heuristic).
- Rarity rolls on the server; luck multipliers transparent (heuristic).
- Minigame runs on the client for feel; server validates results and timing (heuristic).
- Rotate shop stock on a deterministic clock (os.time) so all servers agree (heuristic).
- Store fish as counts, not instances; 4,194,304 characters per DataStore key [8].

## What transfers from outside Roblox (what to keep, what breaks on Roblox's young, mobile, short-session audience)
External titles are common design references, described from general knowledge (heuristic).
- Keep: Animal Crossing's time and weather critter calendar plus museum; Stardew crop timers; Dredge's eerie rares; Webfishing's hangout; Pokemon dex completion.
- Breaks: day-long waits, hard reel minigames for young players, solo cozy with no social layer.
- Adapt: minute-scale timers, visible progress, shared rare moments.

## Octalysis read (dominant drives, 2-4 bullets)
- CD4 Ownership: collection and garden.
- CD7 Unpredictability: rare rolls, mutations, weather.
- CD6 Scarcity: rotating stock and limited events.
- CD5 Social: trading and show-off.

## Sources
[1] Rotrends: Fisch game page - https://rotrends.com/game/5750914919 - checked 2026-11-03
[2] Grow a Garden (Wikipedia) - https://en.wikipedia.org/wiki/Grow_a_Garden - checked 2026-11-03
[3] Roblox Wiki (Fandom): Fisch - https://roblox.fandom.com/wiki/Fisching/Fisch - checked 2026-11-03 (fetch blocked; search excerpt only)
[4] Rotrends Tycoon subgenre - https://rotrends.com/games/genre%3Asub%3ATycoon - checked 2026-11-03
[5] List of Roblox games (Wikipedia) - https://en.wikipedia.org/wiki/List_of_Roblox_games - checked 2026-11-03
[6] Steal a Brainrot (Wikipedia) - https://en.wikipedia.org/wiki/Steal_a_Brainrot - checked 2026-11-03
[7] Paid random items policy guidelines (Creator Docs) - https://create.roblox.com/docs/production/monetization/paid-random-items - checked 2026-11-03
[8] Data store error codes and limits (Creator Docs) - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits - checked 2026-11-03
