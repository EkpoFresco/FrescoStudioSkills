# Genre: Strategy
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: medium - Strategy is a top-10 genre by live players (~342K CCU snapshot), but nearly all of it is tower defense; RTS, auto-battler and grand strategy stay niche [1][2][3].
Top Roblox references (mechanics only):
- Tower defense (the dominant Roblox strategy form): Anime Adventures (~102K CCU), Tower Defense Simulator (5.06B visits), Toilet Tower Defense (6.2B visits). Unit collection plus co-op waves [3].
- Rise of Nations (Hyperant, 2018): RTS plus grand strategy hybrid, 313.5M visits, ~1K CCU, 5K peak in Feb 2026 [4].
- The Conquerors 3: classic base-and-army RTS, ~95M visits, all-time peak ~1.5K CCU (Feb 2021) [5].
- Command An Army: army-command battler, 87M visits, ~13K CCU, charting in Battlegrounds [6].
- Auto-battlers: Units Battlegrounds and Anime Auto Chess exist; no breakout yet [7][8].

## Core loop
- TD shape (proven): queue with 1-4 friends, place units, survive waves, earn currency, summon or upgrade units, harder map (heuristic).
- RTS / grand strategy: claim territory, grow economy, produce units, fight, snowball. Matches of 20-60+ min are the core Roblox problem (heuristic).
- Auto-battler: draft between rounds, position, watch combat resolve, adjust. Short rounds fit mobile (heuristic).
- Shared meta: own a unit collection, level it, unlock maps and modes, climb ranks.
- BedWars shows strategy can hide inside action: Wikipedia classes it as team action-strategy [9].

## Session one (what works in a first session on Roblox, minute by minute where possible)
- 0-1 min: lobby with visible queue pads or an elevator. No menu wall (heuristic).
- 1-3 min: scripted tutorial map with 2-3 starter units. Place, upgrade, win the first wave in seconds.
- 3-8 min: first real match, easy map, near-guaranteed win.
- 8-12 min: first free summon or unit unlock with a rarity reveal.
- 12-20 min: second match on a new map; show the next unlock and a leaderboard.
- RTS: offer a 10-minute bot skirmish before 30-minute PvP. Rise of Nations lists desktop controls (right-drag move, shift-select) [4]; mapping that to touch is the main onboarding cost (heuristic).

## Retention hooks (D1 / D7 / D30)
- D1: daily login reward, half-finished unit upgrade, "next map at level X".
- D7: weekly banner unit, challenge maps, streak rewards.
- D30: ranked seasons, raids and boss modes, collection completion, trading where `IsPaidItemTradingAllowed` permits [10].
- Experience Notifications: opt-in, 13+ only, max 1 per user per day per experience. Use for "new banner live" or "your squad is online" [11].

## Monetization norms (what players accept on Roblox for this genre)
- Accepted: unit summons, extra unit slots, 2x currency or XP passes, VIP servers, unit skins, battle pass.
- Toilet Tower Defense sells unit crates priced in gems [12]. Paid summons (Robux or Robux-bought currency) must show every outcome and odds summing to 100% before purchase; luck boosts must show updated odds [10].
- If `ArePaidRandomItemsRestricted` is true, use an earnable path, direct purchase priced on expected value, or hide the item [10].
- Subscriptions: single tier, $2.99 to $14.99 or 49+ Robux. Fit "daily summon ticket" benefits [13].
- Pushback: paid power in ranked PvP. Sell power in PvE, cosmetics and convenience in PvP (heuristic).

## Social and discovery levers
- Co-op beats PvP here: friends carry new players. Keep parties together with `Player.PartyId` and `SocialService:GetPlayersByPartyId()` [14].
- New experiences reach only age-checked 16+ players until they earn 250 unique plays from engaged players within 60 days [15]. Strategy's older lean helps pass this gate (heuristic).
- 18+ is 29% of global age-checked DAU (37% in the US) and the fastest-growing cohort [16]. Deeper strategy has more room than in 2022.
- Social media links in experiences are barred from early 2026 [17]. Build community through Roblox groups and in-game events.
- Spectate mode and big-win replays give streamers material (heuristic).

## Technical traps on Roblox
- Hundreds of Humanoid units kill mobile frame rate. Simulate units as server data; render lightweight client models (heuristic).
- Do not call PathfindingService per unit per frame. Precompute lanes or flow fields (heuristic).
- Server owns all combat resolution. Clients send intents only (heuristic).
- Long matches meet mobile disconnects. Rejoin the same match via `TeleportOptions.ReservedServerId`; retry failed teleports [14].
- Teleport data is client-visible and unencrypted. Never pass loadouts or currency in it [14].
- Saved bases and armies: 4,194,304 characters per DataStore key; per-server write budget 60 + players x 40 per minute [18].

## What transfers from outside Roblox (what to keep, what breaks on Roblox's young, mobile, short-session audience)
External titles below are common design references, described from general knowledge (heuristic).
- Keep: Clash Royale-style 3-minute matches and elixir pacing; TFT-style draft rounds; Bloons-style upgrade paths; Polytopia-style small maps.
- Keep: asymmetric co-op roles (one runs economy, one fights).
- Breaks: StarCraft-level APM on touch screens; 4X sessions of hours; tooltip walls for 9-15 readers.
- Breaks: losing everything after a 40-minute match. Pay XP and unit progress on a loss.
- Adapt: grand strategy as a persistent server world with 30-minute "eras" instead of hour-long campaigns.

## Octalysis read (dominant drives, 2-4 bullets)
- CD4 Ownership and Possession: unit rosters and upgrades are the spine of Roblox strategy.
- CD2 Development and Accomplishment: wave clears, map unlocks, ranks.
- CD7 Unpredictability: summons and wave variety (keep odds disclosed).
- CD5 Social Influence: co-op carries and trading. Grand strategy adds CD1 (nation building) for older players.

## Sources
[1] Experience genres (Creator Docs) - https://create.roblox.com/docs/production/publishing/experience-genres - checked 2026-11-03
[2] RoWatcher Genre Observatory (live CCU snapshot) - https://rowatcher.com/genres - checked 2026-11-03
[3] Rotrends Tower Defense subgenre (live snapshot) - https://rotrends.com/games/genre%3Asub%3ATower%20Defense - checked 2026-11-03
[4] RoWatcher: Rise of Nations - https://rowatcher.com/games/918677693/rise-of-nations - checked 2026-11-03
[5] Rolimons: The Conquerors 3 [Elite] - https://www.rolimons.com/game/8377997 - checked 2026-11-03
[6] Rotrends Battlegrounds & Fighting subgenre - https://rotrends.com/games/genre%3Asub%3ABattlegrounds%20%26%20Fighting - checked 2026-11-03
[7] Rolimons: Units Battlegrounds - https://www.rolimons.com/game/17569406428 - checked 2026-11-03
[8] Pro Game Guides: Anime Auto Chess tier list (Dec 2025) - https://progameguides.com/roblox/anime-auto-chess-tier-list/ - checked 2026-11-03
[9] List of Roblox games (Wikipedia) - https://en.wikipedia.org/wiki/List_of_Roblox_games - checked 2026-11-03
[10] Paid random items policy guidelines (Creator Docs) - https://create.roblox.com/docs/production/monetization/paid-random-items - checked 2026-11-03
[11] Experience Notifications (Creator Docs) - https://create.roblox.com/docs/production/promotion/experience-notifications - checked 2026-11-03
[12] Sportskeeda: Toilet Tower Defense Forcefield units and crate odds - https://www.sportskeeda.com/roblox-news/toilet-tower-defense-forcefield-units-crate-odds - checked 2026-11-03
[13] Subscriptions (Creator Docs) - https://create.roblox.com/docs/production/monetization/subscriptions - checked 2026-11-03
[14] Teleport between places (Creator Docs) - https://create.roblox.com/docs/projects/teleporting - checked 2026-11-03
[15] Roblox Kids and Select publishing (Creator Docs) - https://create.roblox.com/docs/production/publishing/kids-and-select - checked 2026-11-03
[16] Gaming.net: Roblox Q3 2026 results - https://gaming.net/roblox-q3-revenue-rises-16-as-bookings-fall-12-to-1-7-billion - checked 2026-11-03
[17] Roblox Newsroom: age checks and chat limits (Nov 2025) - https://about.roblox.com/newsroom/2025/11/roblox-requires-age-checks-limits-minor-and-adult-chat - checked 2026-11-03
[18] Data store error codes and limits (Creator Docs) - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits - checked 2026-11-03
