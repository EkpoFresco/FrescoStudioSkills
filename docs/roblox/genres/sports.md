# Genre: Sports (soccer, basketball, volleyball, other ball sports)
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - anime-styled sports with scripted moves avoid weak ball physics; sports logged 500M hours in 2024, up 26% YoY (single source) [1].
Top Roblox references (mechanics only):
- Blue Lock: Rivals (Jul 2024): 5v5 or 5v6 soccer, named-power styles via gacha, weekly updates; 4.49B visits [1]. Peak reported as 1M CCU [1] vs 246K to 276K on trackers, conflicting UNVERIFIED [2].
- Volleyball Legends (Dec 2024): role-based team play, combo spikes, character styles, 62+ updates in about 15 months; about 87K CCU Mar 2026 [1].
- Basketball: Zero (Mar 2025): anime basketball, Best Sports 2025 [3][1].
- FIFA Super Soccer: licensed, Best Sports 2026 [4].

## Core loop
- Queue, play a short match, earn currency, spin or buy styles and abilities, equip, play again [1].
- Skill expression lives in timing and positioning; power comes from styles (heuristic).

## Session one
- 0 to 1 min: join a pickup field from the lobby; ball near you within seconds (heuristic).
- 1 to 5 min: tutorial prompts for shoot, pass, dribble on first touch (heuristic).
- 5 to 15 min: first goal or spike, first free spin for a style (heuristic).
- Keep matches 3 to 6 minutes for mobile (heuristic).

## Retention hooks (D1 / D7 / D30)
- D1: free daily spins, new style chase.
- D7: new characters and limited modes (Volleyball Legends Spleef, Hardcore mode) [1].
- D30: ranked, tournaments, rarity tiers, team clubs (heuristic).
- Update cadence is the moat: about one update every 1.5 weeks (Volleyball Legends) [1].

## Monetization norms
- Gacha-style ability systems with named powers [1]. Spin packs, lucky spins, style storage slots (heuristic).
- Rarity tiers drive spend (Common to World Class reported) UNVERIFIED.
- Blue Lock: Rivals reportedly about $5M per month at peak and sold for over $3M in Mar 2025 (single source) UNVERIFIED [1].
- Average sports player age reported as 18, older than platform average [1].

## Social and discovery levers
- Anime release windows spike interest (Volleyball Legends grew with a 2024 film) [1].
- Team play with friends; party queue via Player.PartyId [5].
- IP risk: Football Fusion (1.71B visits) was content-deleted after a second NFL DMCA strike in Mar 2025 [1]. Use original teams and characters.

## Technical traps on Roblox
- Ball ownership transfer causes a visible freeze on possession change (DevForum reports) [1].
- Many hits use scripted animation sets instead of physics (Volleyball Legends) [1].
- Server Authority beta: official Soccer template smooths the ball only when the simulated ball jumps away from the rendered one [6].
- Server-owned ball is fair but laggy; client-owned ball is smooth but exploitable (fling, teleport) [7][8].
- Physics differs between Studio and live servers; test on real servers [1].
- Shot and pass remotes: validate distance to ball, cooldown, and direction on the server (heuristic).
- Competitive integrity: Device Trust for ranked [9].

## What transfers from outside Roblox
- Rocket League: physics ball, short matches, rank tiers.
- FIFA and eFootball: card rarity and team building.
- Arcade sports (NBA Jam, Mario Strikers): exaggerated special moves, readable powers.
- Lesson: anime framing makes powers acceptable in a sports sim (heuristic).

## Octalysis read
- Accomplishment (CD2): goals, ranks.
- Unpredictability (CD7): spins and styles.
- Social Influence (CD5): team play, flexing rare styles.
- Ownership (CD4): style collection.

## Sources
[1] Sports Games on Roblox: A Billion-Visit Opportunity Hiding in Plain Sight (RoWatcher) - https://rowatcher.com/news/sports-games-on-roblox-a-billion-visit-opportunity-hiding-in-plain-sight - checked 2026-11-03
[2] Blue Lock: Rivals stats (RoWatcher) - https://rowatcher.com/games/6325068386/sendou-blue-lock-rivals/dying - checked 2026-11-03
[3] Roblox reveals 2025 Innovation Awards winners (PocketGamer.biz) - http://www.pocketgamer.biz/roblox-reveals-2025-innovation-awards-winners/ - checked 2026-11-03
[4] 2026 Roblox Innovation Awards (Roblox Newsroom) - https://about.roblox.com/newsroom/2026/09/2026-roblox-innovation-awards - checked 2026-11-03
[5] SocialService (Roblox Docs) - https://create.roblox.com/docs/reference/engine/classes/SocialService - checked 2026-11-03
[6] Server authority techniques (Roblox Docs) - https://create.roblox.com/docs/projects/server-authority/techniques - checked 2026-11-03
[7] Network ownership (Roblox Docs) - https://create.roblox.com/docs/physics/network-ownership - checked 2026-11-03
[8] Network ownership, movement validation, and physics (Roblox Docs) - https://create.roblox.com/docs/scripting/security/network-ownership - checked 2026-11-03
[9] Device trust (Roblox Docs) - https://create.roblox.com/docs/scripting/security/device-trust - checked 2026-11-03
