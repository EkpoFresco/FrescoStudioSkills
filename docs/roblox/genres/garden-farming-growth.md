# Genre: Garden / Farming / Growth
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong but volatile - Grow a Garden set platform records in 2025. The 2026 sequel faded within months [1][2]. There is no official subgenre, so it sits under Simulation (Idle or Incremental) [3].
Top Roblox references (mechanics only):
- Grow a Garden (Mar 2025): buy seeds, plant, wait, harvest, sell. Crops grow while you are offline, seeds go in and out of stock, weekly exclusives must be claimed online, pets come from loot boxes [1].
- Grow a Garden 2 (Jun 12, 2026): day farming plus night stealing, defensive plants (snapping and shooting plants), a circular map around a hub. No progress carried over from the first game [4].
- Plants vs Brainrots-style hybrids: crops as defenders (UNVERIFIED, not researched).

## Core loop
- Buy a seed, plant it, real-time growth, harvest (with a variable-value roll: size, mutation), sell or keep, buy a rarer seed, expand the plot.
- Restock timers on the seed shop create a "check back" rhythm and scarcity [1].
- Weather and event mutations multiply crop value, which turns waiting into lottery anticipation (heuristic, mutation details UNVERIFIED for GaG).

## Session one
- 0:00-0:30: an empty plot plus starter currency for cheap seeds [1]. The first seed grows in seconds (heuristic).
- 1-5 min: first harvest and sell. Show the price per fruit and make the jump to the next seed tier visible.
- 5-15 min: the first long-grow seed planted, plus the "it grows while you're away" message.
- 15-30 min: shop restock moment (rare seed appears), a neighbor's flashy garden, and pets or eggs teased.
- Exit: crops growing offline. The return trip is built in [1].

## Retention hooks (D1 / D7 / D30)
- D1: offline growth plus restock timers [1]. Rewarded "progressive rewards" chains (Grow a Garden is Roblox's example) [5].
- D7: weekly update events. Grow a Garden formed two event teams and ran weekly events [1].
- D30: rare seeds and pets, trading, garden expansions (the up-to-4x expansion update coincided with the 8.9M CCU spike) [6].
- Warning: Grow a Garden 2 fell from 171.8K CCU (Aug 2026) to outside the top 50 by Sept 30, 2026 [2]. Sequels without progress carryover and novelty fatigue are real risks (heuristic).

## Monetization norms
- Robux to skip waits, extra perks, and (in the original) steal other players' crops [1].
- Seed or egg packs (paid random items need percent odds), growth-speed passes, extra plot space, sprinklers and gear (heuristic) [7].
- Some co-owners were criticized for over-monetization [1].
- Rewarded video: 15%+ opt-in, 3+ views per day benchmark for tycoon-style progressive reward chains [5].

## Social and discovery levers
- "Show off your fruits to friends" is the stated pitch [8]. Visible gardens next to each other, plus mutation flexes.
- Cross-game events: the Aug 23, 2025 mock "admin war" with Steal a Brainrot drove both to records, and Roblox to a 47.4M platform peak [1][9].
- Celebrity tie-in events (an NFL player in July 2025) [1].
- Fastest game to 1B visits (33 days) [6]. Bot-inflation allegations were raised by an analyst, then partly retracted. Roblox disputes them [1].

## Technical traps on Roblox
- Real-time growth: store plant timestamps, not tick counters. On load, compute stage = f(now - plantedAt) with the server's os.time() [10].
- Hundreds of plants per plot at 6+ plots per server is a heavy part count. Use stage-swapped models, StreamingEnabled, and LOD (heuristic).
- Restock timers should be global and server-synced (same restock for everyone), so they can be shared on social and feel fair (heuristic).
- Trading and stealing need session locking against dupes [11].
- Real-money trading of rare items (eBay, Discord) breaks ToS. Design rarity knowing it will happen [1].

## What transfers from outside Roblox
- FarmVille and Hay Day: crop timers set appointment play. Neighbor help mechanics drive virality (heuristic).
- Stardew Valley: crop quality tiers and seasons give depth (heuristic).
- Plants vs Zombies: plants-as-defense is the hybrid direction Grow a Garden 2 took [4].

## Octalysis read
- CD6 Scarcity and Impatience: restocks and grow timers. Dominant.
- CD4 Ownership: the garden plot.
- CD7 Unpredictability: mutations, rare restocks, weather.
- CD8 Loss and Avoidance (in stealing variants): defend the harvest.

## Sources
[1] Wikipedia, Grow a Garden - https://en.wikipedia.org/wiki/Grow_a_Garden - checked 2026-11-03
[2] StudioKrew, Top Roblox games September 2026 - https://studiokrew.com/blog/top-roblox-games-september-2026/ - checked 2026-11-03
[3] Roblox Creator Hub, Experience genres - https://create.roblox.com/docs/production/publishing/experience-genres - checked 2026-11-03
[4] All Things How, Grow a Garden 2 launches June 12 with night stealing - https://allthings.how/grow-a-garden-2-launches-june-12-with-night-stealing-on-roblox/ - checked 2026-11-03
[5] Roblox Creator Hub, Rewarded video playbook: Tycoon - https://create.roblox.com/docs/production/promotion/rewarded-video-playbooks/tycoon - checked 2026-11-03
[6] PocketGamer.biz, Grow a Garden record 8.9M CCU (2025-06-02) - https://www.pocketgamer.biz/roblox-game-grow-a-garden-beats-steam-with-record-concurrent-user-high-of-89m/ - checked 2026-11-03
[7] Roblox Creator Hub, Paid random items policy - https://create.roblox.com/docs/production/monetization/paid-random-items - checked 2026-11-03
[8] Roblox, Grow a Garden game page - https://www.roblox.com/games/126884695634066/Grow-a-Garden - checked 2026-11-03
[9] PocketGamer.biz, Steal a Brainrot passes 25M CCU (2025-10-07) - https://www.pocketgamer.biz/robloxs-steal-a-brainrot-becomes-first-game-to-surpass-25m-concurrent-players/ - checked 2026-11-03
[10] DevForum, How do "Steal a" games calculate offline cash - https://devforum.roblox.com/t/how-do-steal-a-games-calculate-offline-cash/3854950 - checked 2026-11-03
[11] DevForum, ProfileStore - https://devforum.roblox.com/t/profilestore/3190543 - checked 2026-11-03
