# Genre: Steal / Base Raid (2025-2026 wave)
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - this wave set the all-time single-game CCU record (about 25.4M, Oct 2025) [1], and a steal-and-hatch game led the charts in Sept to Oct 2026 [2]. It has no official subgenre and is usually filed as Simulation or Idle [3].
Top Roblox references (mechanics only):
- Steal a Brainrot (May 2025): buy characters off a central conveyor, they earn passive income in your base. Steal from others, temporary base shield button, traps and gear, rebirth for stats [4].
- Steal An Egg (Jul 2026): steal eggs from guarded biome nests, carry them home (heavier eggs mean slower carrying), hatch them into income pets. Speed stat gates biomes. Bear traps are the PvP tool. Servers hold 7 players [5][2].
- Grow a Garden 2 (Jun 2026): the growth loop plus night-only stealing and defensive plants [6].

## Core loop
- Acquire (buy or snipe from the conveyor, or grab from a nest), carry to your base (vulnerable), the item earns income per second, upgrade, defend your base, raid others, rebirth.
- The carry run is the core tension. Carrying slows you and exposes you. That is capture-the-flag with idle income attached [4][5].
- Base protection is a timed shield. One guide reports a 60s lock cooldown (UNVERIFIED, changes often) [7].
- Purchase sniping: another player can grab your conveyor purchase mid-walk, which creates instant rivalry [7].

## Session one
- 0:00-0:30: empty base, starter cash, the conveyor or nest right in view [4].
- 0:30-3:00: first buy or grab, walk it home, income ticks. Then the first theft against you, or the first time you see one.
- 3-10 min: the first steal attempt, a shield-button lesson, a trap or bat tool.
- 10-30 min: a rarer item appears on the conveyor or in a nest (a server-wide moment), offline income promise, rebirth preview.
- Exit: "your base earns while offline" [8]. Note that loss anxiety also pulls players back.

## Retention hooks (D1 / D7 / D30)
- D1: offline cash (24h clamp plus a divisor is the common implementation) [8], plus revenge on whoever stole from you.
- D7: weekly events. Steal An Egg ships updates every Saturday [2]. Rotating 30-minute in-server events (rifts, races, blooms) [5].
- D30: rebirth tiers, limited event characters, and mounts or mutations. Expect steep decay: Steal a Brainrot fell from a 25.8M peak to roughly 100-215K CCU (third-party) [9][2].

## Monetization norms
- Robux gear: tools, traps, invisibility or freeze. Critics say "the best items are only available for cash" [4].
- Server-wide luck boosts and server admin powers bought with Robux. One player's spend becomes an event for everyone [4][7].
- Steal An Egg (reported): 2x money 399 R$, 2x growth 467 R$, speed multipliers from 3 R$ to 1,375 R$ [5].
- Random hatches or rolls bought with Robux need percent odds before purchase [10].
- Private servers sell as "100% theft protection" [7].

## Social and discovery levers
- Cross-game admin events: the Aug 23, 2025 "admin war" with Grow a Garden set records and helped push Roblox to 47.4M CCU [11][1].
- Live concert inside the game (Jan 2026, about 12.8M CCU) [4].
- Heavy clip culture (kids reacting to losses), and many clones. The IP owner sued a Fortnite copy [4].
- Theft creates enemies and allies, and friend-access toggles let friends past base defenses [7].

## Technical traps on Roblox
- Exploiters automate collection and stealing [4]. The server must validate carry state, distance, speed, and shield timers.
- Carried items: weld to the character with the server owning state. Drop on death and handle disconnect mid-carry (heuristic).
- Offline income: use the server's os.time() delta, clamp it, and save last-seen on leave and periodically [8].
- Base persistence across servers: the base is per-player saved data, rebuilt into a free slot on join. Small servers (6-8) keep raids readable (heuristic) [2].
- Dupes from steal plus disconnect race conditions: use session locking and an atomic transfer between player profiles [12].
- Child-safety optics: losing items to theft is upsetting. Consider loss caps and recovery paths (heuristic).

## What transfers from outside Roblox
- Clash of Clans: raid-or-be-raided with shields after an attack. Shield timing is the key lever (heuristic).
- Capture-the-flag (Team Fortress 2): the carrier is slowed and visible (heuristic).
- Rust and Sea of Thieves: loot-carry vulnerability creates stories (heuristic).

## Octalysis read
- CD8 Loss and Avoidance: dominant (theft, shields).
- CD4 Ownership: the base collection.
- CD5 Social Influence: rivalry, revenge, admin events.
- CD7 Unpredictability: conveyor spawns, mutations, raids.

## Sources
[1] PocketGamer.biz, Steal a Brainrot passes 25M CCU (2025-10-07) - https://www.pocketgamer.biz/robloxs-steal-a-brainrot-becomes-first-game-to-surpass-25m-concurrent-players/ - checked 2026-11-03
[2] StudioKrew, Top Roblox games September 2026 - https://studiokrew.com/blog/top-roblox-games-september-2026/ - checked 2026-11-03
[3] Roblox Creator Hub, Experience genres - https://create.roblox.com/docs/production/publishing/experience-genres - checked 2026-11-03
[4] Wikipedia, Steal a Brainrot - https://en.wikipedia.org/wiki/Steal_a_Brainrot - checked 2026-11-03
[5] RBLX Guide, Steal an Egg beginner guide - https://rblxguide.com/games/steal-an-egg/updates/beginner-guide - checked 2026-11-03
[6] All Things How, Grow a Garden 2 launches with night stealing - https://allthings.how/grow-a-garden-2-launches-june-12-with-night-stealing-on-roblox/ - checked 2026-11-03
[7] games.gg, Steal a Brainrot beginner's guide - https://games.gg/roblox/guides/steal-a-brainrot-ultimate-beginners-guide/ - checked 2026-11-03
[8] DevForum, How do "Steal a" games calculate offline cash - https://devforum.roblox.com/t/how-do-steal-a-games-calculate-offline-cash/3854950 - checked 2026-11-03
[9] RoWatcher, Is the Brainrot Trend Dying (third-party) - https://rowatcher.com/news/is-the-brainrot-trend-dying-what-ccu-data-from-three-top-games-reveals - checked 2026-11-03
[10] Roblox Creator Hub, Paid random items policy - https://create.roblox.com/docs/production/monetization/paid-random-items - checked 2026-11-03
[11] Wikipedia, Grow a Garden - https://en.wikipedia.org/wiki/Grow_a_Garden - checked 2026-11-03
[12] DevForum, ProfileStore - https://devforum.roblox.com/t/profilestore/3190543 - checked 2026-11-03
