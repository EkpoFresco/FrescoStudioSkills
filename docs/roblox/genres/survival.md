# Genre: Survival (survive the night, crafting, base building)
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - co-op day and night loops are the biggest non-sim breakout of 2025; 99 Nights in the Forest reported a 14.2M CCU peak [1].
Top Roblox references (mechanics only):
- 99 Nights in the Forest (Grandma's Favourite Games): co-op campfire base, gather by day, defend by night, rescue lost kids, 33+ classes; Best Horror 2025, Best Survival 2026 [1][2][3][4].
- Dead Rails: train run across about 80 km, stop to scavenge, fortify at night, Bonds buy classes; Best Strategy and Best Use of Tech 2025 [2][4].
- Natural Disaster Survival: survive a random disaster per round; Best Classic 2026 [3].
- Escape Tsunami For Brainrots: survival dodging plus collection, about 350K CCU Mar 2026 [5].

## Core loop
- Day: gather, craft, upgrade base or campfire. Night: defend, survive, recover. Repeat with rising threat [4].
- Run-based variant: a trip with a start and finish, risk vs reward per stop (Dead Rails) [4].
- Meta: currency (diamonds, Bonds) unlocks classes between runs [4].

## Session one
- 0 to 2 min: spawn at the base with one obvious job (feed the fire) [4].
- 2 to 8 min: first gather trip and first craft; night falls before boredom (heuristic).
- 8 to 15 min: first night defense with friends; first death or near death.
- End: night counter and next upgrade visible; strong "one more night" pull (heuristic).

## Retention hooks (D1 / D7 / D30)
- D1: next class, next base tier, beat your best night.
- D7: milestone nights (50, 99), true ending via rescues [4].
- D30: new biomes and crafting updates (99 Nights Jungle Biome Part 2 and a crafting update in Mar 2026) [5].
- Developer note: players not rushing through content is credited for longevity [1].

## Monetization norms
- Classes for premium currency or Robux; best classes often earnable (Dead Rails) [4].
- Reported prices (promotional source, UNVERIFIED): 99 Nights bundle about 299 Robux, classes about 350 Robux; Dead Rails storage about 79, self-revive about 45 [4].
- Revives and storage are accepted; selling the win is not (heuristic).
- Regional pricing shows up in live prices [4].

## Social and discovery levers
- Co-op is the hook; friends carry newbies through nights (heuristic).
- Spinoff and fan games ride a hit's name; tracker data is polluted by copies [1].
- Film deals extend brand reach (99 Nights movie rights) [1].
- Party joins and invites via SocialService [6].

## Technical traps on Roblox
- Night waves: server-owned NPCs; batch AI updates, cap counts on mobile (heuristic).
- Moving bases (trains, cars): give ownership to the driver and loose parts on top to the same client [7].
- Welded player structures on moving vehicles fight ownership; seat welds cause jitter for viewers [8].
- Building: validate placement on the server; client-owned unanchored parts can be flung [9].
- Persistent progress across nights: periodic saves and UpdateAsync; save at checkpoints [10].
- Physics: high-speed assemblies get bumped to 240 Hz solver islands, raising cost [11].

## What transfers from outside Roblox
- Don't Starve: hunger, light as safety, seasons.
- Valheim and Rust: base raids, crafting tiers (simplify for kids).
- FTL style runs: travel, stops, risk choices (Dead Rails pattern).
- Lesson: shorten to 15 to 30 minute arcs with clear night counters (heuristic).

## Octalysis read
- Loss and Avoidance (CD8): night threat.
- Accomplishment (CD2): nights survived.
- Social Influence (CD5): co-op roles.
- Empowerment (CD3): base layout and class choice.

## Sources
[1] List of Roblox games (Wikipedia) - https://en.wikipedia.org/wiki/List_of_Roblox_games - checked 2026-11-03
[2] Roblox reveals 2025 Innovation Awards winners (PocketGamer.biz) - http://www.pocketgamer.biz/roblox-reveals-2025-innovation-awards-winners/ - checked 2026-11-03
[3] 2026 Roblox Innovation Awards (Roblox Newsroom) - https://about.roblox.com/newsroom/2026/09/2026-roblox-innovation-awards - checked 2026-11-03
[4] 99 Nights in the Forest vs Dead Rails (Earnaldo, promotional blog, 2026-06-14) - https://earnaldo.com/blog/99-nights-in-the-forest-vs-dead-rails - checked 2026-11-03
[5] The 10 Fastest-Growing Roblox Games in March 2026 (RoWatcher) - https://rowatcher.com/news/the-10-fastest-growing-roblox-games-in-march-2026 - checked 2026-11-03
[6] SocialService (Roblox Docs) - https://create.roblox.com/docs/reference/engine/classes/SocialService - checked 2026-11-03
[7] Network ownership (Roblox Docs) - https://create.roblox.com/docs/physics/network-ownership - checked 2026-11-03
[8] Chrono custom physics replication library (DevForum) - https://devforum.roblox.com/t/chrono-drop-in-custom-physics-replication-library/3873294 - checked 2026-11-03
[9] Network ownership, movement validation, and physics (Roblox Docs) - https://create.roblox.com/docs/scripting/security/network-ownership - checked 2026-11-03
[10] Best practices for data stores (Roblox Docs) - https://create.roblox.com/docs/cloud-services/data-stores/best-practices - checked 2026-11-03
[11] Adaptive timestepping (Roblox Docs) - https://create.roblox.com/docs/physics/adaptive-timestepping - checked 2026-11-03
