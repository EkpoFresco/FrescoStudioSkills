# Genre: Tower Defense
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - it is an official Strategy subgenre [1]. Co-op matches and long sessions fit well, and anime-unit gacha variants monetize heavily. Research note: live web search was unavailable for this file, so many claims are heuristic or UNVERIFIED.
Top Roblox references (mechanics only):
- Tower Defense Simulator: place units against zombie waves, co-op with friends against stronger bosses, unlock new units. Ships seasonal night events and crates [2].
- Anime-unit TDs (titles UNVERIFIED for 2026 rankings): units come from summon banners and carry rerollable traits. Story, infinite, and raid modes.
- Anime Dice (2026): a hybrid where rolled units are placed on a plot for idle income [3].

## Core loop
- In match: wave starts, earn cash per kill or wave, place and upgrade units on a path, survive, boss wave, rewards.
- Meta: match rewards feed unit unlocks or summons. Units get leveled or evolved, which unlocks harder modes, which pay better rewards (heuristic).
- Lobby to match: elevators or queue pads that teleport into match servers (TDS-style, heuristic).

## Session one
- 0:00-1:00: the lobby shows the queue pad right away. A solo easy-mode option skips the wait (heuristic).
- 1-10 min: first match on easy. Teach placement, then upgrade, then targeting with 2-3 starter units. Guarantee a win.
- 10-15 min: first reward spend. The first summon or unit purchase should land a good unit (heuristic: guaranteed first-pull rarity).
- 15-40 min: 2-3 more matches, the first loss on a harder mode, and a visible next unit goal.
- Exit: a daily quest half done, event currency in the bag.

## Retention hooks (D1 / D7 / D30)
- Third-party tracker rates TD retention as "Medium" at D30, with long sessions driven by match length (UNVERIFIED, no methodology) [4].
- D1: daily quests, login summons. D7: limited banners and event modes on a weekly cadence (heuristic).
- D30: hard-mode mastery, unit evolution chains, leaderboard modes (endless or infinite).
- Co-op groups are the strongest D30 glue. The Home algorithm counts intentional co-play days [5].

## Monetization norms
- Gamepass units (premium towers), VIP, 2x rewards, extra equip slots, skip-wave or x2 game speed (heuristic, TDS-style).
- Gacha summons with gems: common in anime TDs. Odds must be shown in percent before purchase, and trait rerolls bought with paid currency count as paid random items [6].
- Banner pity counters count as probability modifiers and must be explained [6].
- Cosmetic crates and skins (TDS has crates) [2]. These are also paid random items when bought with Robux.
- Players accept paid units if free units can clear content. Pay-only meta units in competitive modes cause backlash (heuristic).

## Social and discovery levers
- 4-player co-op parties and carry culture (strong players help new ones) (heuristic).
- Group join reward: TDS gives $100 starting cash for joining its group [2].
- Promo codes on social channels (TDS uses codes for skins) [2].
- Trend-theme TDs (brainrot, anime, garden) spin off fast. Third-party trackers note the brainrot theme spread into TD [7].

## Technical traps on Roblox
- Enemy count: hundreds of humanoid enemies destroy server performance. Simulate enemies as path-progress values on the server and render them client-side (heuristic).
- Never use Humanoids for enemies. Use anchored models moved by CFrame on the client (heuristic).
- Placement validation: the server checks cash, path overlap, and the unit cap. The client only previews.
- Unit inventories with traits and levels: unique IDs, session-locked saves, trade logs if trading exists [8].
- Match-server teleports: pass party data with TeleportService and handle failed teleports gracefully (heuristic).
- Mobile: placement UI needs big hit targets and a range preview. Speed-up toggles help short sessions (heuristic).

## What transfers from outside Roblox
- Bloons TD 6: upgrade paths (choose 2 of 3) create build identity, and the co-op mode extends life (heuristic).
- Kingdom Rush: hero units plus a few strong tower types beat many weak ones (heuristic).
- Arknights: gacha-unit TD with stamina and banner economics. Shows the monetization ceiling and the backlash risks (heuristic).

## Octalysis read
- CD2 Accomplishment: clearing harder modes.
- CD3 Creativity and Feedback: placement and build choices.
- CD4 Ownership: unit rosters and evolutions.
- CD7 Unpredictability: summons and traits, with regulatory obligations.

## Sources
[1] Roblox Creator Hub, Experience genres - https://create.roblox.com/docs/production/publishing/experience-genres - checked 2026-11-03
[2] Roblox, Tower Defense Simulator game page - https://www.roblox.com/games/3260590327/Tower-Defense-Simulator - checked 2026-11-03
[3] StudioKrew, Top Roblox games September 2026 - https://studiokrew.com/blog/top-roblox-games-september-2026/ - checked 2026-11-03
[4] RoWatcher, Roblox Retention by Genre (third-party) - https://rowatcher.com/news/roblox-retention-by-genre-which-games-keep-players-longest - checked 2026-11-03
[5] Roblox Creator Hub, Discovery - https://create.roblox.com/docs/discovery - checked 2026-11-03
[6] Roblox Creator Hub, Paid random items policy - https://create.roblox.com/docs/production/monetization/paid-random-items - checked 2026-11-03
[7] RoWatcher, Is the Brainrot Trend Dying (third-party) - https://rowatcher.com/news/is-the-brainrot-trend-dying-what-ccu-data-from-three-top-games-reveals - checked 2026-11-03
[8] DevForum, ProfileStore - https://devforum.roblox.com/t/profilestore/3190543 - checked 2026-11-03
