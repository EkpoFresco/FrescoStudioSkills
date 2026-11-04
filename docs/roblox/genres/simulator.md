# Genre: Simulator
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - this is the platform's native grind loop. It is cheap to build, readable on mobile, and pays out often enough for short sessions.
Top Roblox references (mechanics only):
- Pet Simulator 99: hatched pets do the breaking for you, rarity tiers stack on top of each other, and updates ship every week or two [1][2].
- Bee Swarm Simulator: a collect-and-convert loop (pollen into honey) with quests and events layered over it [3].
- Gym or strength sims (UNVERIFIED titles): click to gain a stat, the stat unlocks zones, rebirth multiplies the stat.

## Core loop
- Click or act, gain a stat or currency, buy a multiplier (tool, pet, zone), repeat on a bigger number (heuristic).
- A zone gate needs stat X, so each new zone is both a goal and a visible flex (heuristic).
- Rebirth resets currency for a permanent multiplier. Each rebirth should cost about 3-4x the last one, so the player has to push further every run (heuristic, see idle-clicker.md for the math).

## Session one
- 0:00-0:30: the first click pays out. Never open on a menu or a tutorial wall (heuristic).
- 0:30-3:00: first purchase, first pet or tool, first zone in sight. Third-party commentary puts a simulator's survival on the first 3 minutes [4].
- 3-10 min: first egg hatch, first rarity reveal, first gate cleared.
- 10-20 min: a rebirth preview shows exactly what the player will gain. Show it before they can afford it.
- Exit hook: a daily reward timer, an egg that is still incubating, or a quest that is 80% done.

## Retention hooks (D1 / D7 / D30)
- D1: daily login streak, a timed free gift, an unfinished quest. Community benchmark: D1 under 25-30% is a red flag (UNVERIFIED, third-party) [4].
- D7: weekly update on a fixed weekday, rotating event currency, a leaderboard reset.
- D30: limited pets that are never available again, the rebirth ladder, and status tiers like Huge or Titanic [2].
- Third-party data says simulators decay steeply and depend on events. One claim: about 60% of peak CCU is lost within 30 days without an event (UNVERIFIED) [5].
- Roblox's Home algorithm now weighs play days at D1, D2-7, and D8-28, so D30 matters for discovery and not only revenue [6][7].

## Monetization norms
- Gamepasses: 2x currency, auto-click or auto-farm, extra pet slots, and luck tiers. Reported PS99 prices: Lucky 275 R$, Ultra Lucky 800 R$, Huge Hunter 3,250 R$ (third-party) [2].
- Dev products: currency packs, timed boosts, exclusive eggs (about 400 R$ reported) [2].
- Any paid random hatch, and any paid luck boost, must show exact odds as percentages before purchase [8].
- Rewarded video (incremental sim guide): speed or multiplier boosts, doubled offline earnings, energy refills, 10-minute automation trials. Benchmark: 13%+ opt-in, 2.8 views per day [9].
- Players accept pay-for-speed. They resent pay-only power that dominates PvP or trading (heuristic). PS99 draws steady "p2w" criticism [2].
- Regional pricing is on by default for passes [10].

## Social and discovery levers
- Visible pets and auras act as walking ads in a shared server (heuristic).
- Group join and like rewards are common, but keep them modest and optional.
- Server-wide spectacle such as huge hatch announcements turns one player's spend into everyone's FOMO [2].
- Intentional co-play days are a ranking signal, so friend boosts are directly rewarded [6].

## Technical traps on Roblox
- The server must own the stat math. Clients send only "I clicked", and the server rate-limits clicks (heuristic).
- Never accept a currency amount from a RemoteEvent. Auto-click exploits are endemic in the genre (heuristic).
- Use session-locked saves (ProfileStore) to prevent pet dupes when trading exists [11].
- DataStore: 4 MB max per key, plus per-key and per-server request budgets. Batch your saves [12].
- Hundreds of pets following players at once kills mobile performance. Cap rendered followers, and animate client-side only (heuristic).
- Numbers outgrow 1e15 quickly. Plan BigNum handling from day one (see idle-clicker.md).

## What transfers from outside Roblox
- Idle and incremental pacing math from Kongregate-era games: exponential costs against polynomial income, plus prestige [13].
- Mobile gacha practice: pity counters and shown odds build trust (heuristic).
- Collection-log completion meters from MMOs (heuristic).

## Octalysis read
- CD2 Development and Accomplishment: numbers go up, zones unlock.
- CD4 Ownership and Possession: pet inventories, collection logs.
- CD6 Scarcity and Impatience: limited eggs, timers, event exclusives.
- CD7 Unpredictability: hatch reveals. Pair it with odds disclosure.

## Sources
[1] Wikipedia, Pet Simulator (list entry) - https://en.wikipedia.org/wiki/Pet_Simulator - checked 2026-11-03
[2] RoWatcher, Pet Simulator 99 monetization (third-party) - https://rowatcher.com/news/pet-simulator-99-inside-roblox-s-most-aggressive-monetization-machine - checked 2026-11-03
[3] Wikipedia, List of Roblox games (Bee Swarm entry) - https://en.wikipedia.org/wiki/Tower_of_Hell - checked 2026-11-03
[4] RoWatcher, Simulators and Obbies Need Different Retention Clocks (third-party) - https://rowatcher.com/news/simulators-and-obbies-need-different-retention-clocks - checked 2026-11-03
[5] RoWatcher, Roblox Retention by Genre (third-party, no methodology) - https://rowatcher.com/news/roblox-retention-by-genre-which-games-keep-players-longest - checked 2026-11-03
[6] Roblox Creator Hub, Discovery - https://create.roblox.com/docs/discovery - checked 2026-11-03
[7] DevForum, Recommended For You Algorithm Improvements (2026-06-15) - https://devforum.roblox.com/t/recommended-for-you-algorithm-improvements-that-better-value-long-term-retention/4684575 - checked 2026-11-03
[8] Roblox Creator Hub, Paid random items policy - https://create.roblox.com/docs/production/monetization/paid-random-items - checked 2026-11-03
[9] Roblox Creator Hub, Rewarded video playbook: Incremental Sim - https://create.roblox.com/docs/production/promotion/rewarded-video-playbooks/incremental-sim - checked 2026-11-03
[10] Roblox Creator Hub, Regional pricing - https://create.roblox.com/docs/production/monetization/regional-pricing - checked 2026-11-03
[11] DevForum, ProfileStore - https://devforum.roblox.com/t/profilestore/3190543 - checked 2026-11-03
[12] Roblox Creator Hub, Data store error codes and limits - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits - checked 2026-11-03
[13] Pecorella, The Math of Idle Games Part III - https://www.gamedeveloper.com/design/the-math-of-idle-games-part-iii - checked 2026-11-03
