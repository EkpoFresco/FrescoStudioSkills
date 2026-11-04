# Genre: Management Sim (restaurant, shop, job, city)
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - Tycoon is the largest Simulation subgenre (17,301 games), and job sims are Roblox heritage: Work at a Pizza Place hit 5B plays by Feb 2025 [1][2].
Top Roblox references (mechanics only):
- Work at a Pizza Place (2007): co-op roles in one shared shop (cashier, cook, boxer, supplier, delivery); first Roblox game to 100M plays [2][3].
- Restaurant Tycoon 2 (Ultraw, 2019): own-restaurant management with layout, staff, VIP customers, ratings, reviews, drive-thru [2][4].
- Theme Park Tycoon 2 and Welcome to Bloxburg (jobs inside a life sim) [2].
- Live tycoon chart: My Small Business (~18.8K CCU), Karinderya (Filipino eatery, 90.9M visits), Sell a Million Sushi (~13.6K CCU) [1].
- Fast Food Simulator (burger flippers, Jan 2025): cook burgers, fries and drinks, grow a chain [5].
- City builders: few hits; Roblox city play lives in roleplay towns instead (heuristic).

## Core loop
| Shape | Fantasy | Loop |
|---|---|---|
| Job sim | "I work here with friends" | pick role, 10-30 s tasks, team throughput sets pay, promotion ladder |
| Tycoon | "I own and grow this" | serve, earn, upgrade, hire, rating rises, pickier customers [4] |
| Hybrid | "Staff today, owner later" | job shifts fund your own shop (heuristic) |
- Restaurant beat: order ticket, station minigame, serve before patience runs out, pay plus tip, rating moves.
- Automation curve: manual first, hire NPC staff, player becomes manager and optimizer (heuristic).
- Rush hours and special customers (VIP, critics) break routine. RT2 shipped VIP tables and wheelchair customers as content [4].

## Session one (what works in a first session on Roblox, minute by minute where possible)
- 0-1 min: spawn in a working kitchen, one glowing station, one customer waiting. No plot picker.
- 1-3 min: first order with on-screen recipe, under 30 s; coins plus a "+tip" pop.
- 3-6 min: second station; first mini rush (3 customers).
- 6-10 min: first upgrade (faster grill) or first hire.
- 10-15 min: first decor item; rating star rises.
- 15-20 min: rush event, level up, preview the expansion and the "manager" role.
- Co-op: auto-assign newcomers to the easiest open role (cashier); highlight a friend to follow (heuristic).

## Retention hooks (D1 / D7 / D30)
- D1: offline earnings from NPC staff (capped), unfinished expansion, daily special recipe.
- D7: weekly menu items, limited decor, holiday menus.
- D30: second location or franchise, prestige or rebirth multipliers, restaurant rankings.
- Cadence is the hook. RT2 logged ~47 updates in 2023, then slowed sharply [4].

## Monetization norms (what players accept on Roblox for this genre)
- Accepted: 2x cash, faster cooking, auto-collect, extra floors, premium furniture, VIP areas, staff uniforms, appliance passes, private servers for roleplay crews.
- Job sims: house items, vehicles, uniforms, pay boosts.
- Subscriptions for daily cash or decor drops: $2.99 to $14.99 tiers, or 49+ Robux [6].
- Avoid: speed-ups that make co-op partners pointless; random-item mystery crates without odds [7].

## Social and discovery levers
- Players as customers in your restaurant: social proof plus roleplay.
- Manager role and promotion titles create status in shared shops (heuristic).
- Local menus win locally: Karinderya charts [1]; Roblox reports regional demand in Brazil and Japan [8].
- New games reach only age-checked 16+ until 250 engaged unique plays in 60 days [9]. Plan a soft launch for older players.
- Brand tie-ins suit food sims; borrow mechanics, never another game's IP (heuristic).

## Technical traps on Roblox
- Many NPC customers per plot: keep queues as server data, render visuals client-side (heuristic).
- Many plots per server multiply parts. Stream and cap decor counts (heuristic).
- Offline income from a saved server timestamp, capped. Never trust client time (heuristic).
- Save layouts compactly; 4,194,304 characters per DataStore key [10].
- Auto-farm scripts in job sims: rate-limit task completions server-side (heuristic).

## What transfers from outside Roblox (what to keep, what breaks on Roblox's young, mobile, short-session audience)
External titles are common design references, described from general knowledge (heuristic).
- Keep: Overcooked chaotic stations; PlateUp! automation; Papa's Pizzeria ticket clarity and grading; Diner Dash patience meters; Supermarket Simulator stocking satisfaction.
- Breaks: finance spreadsheets, long setup before the first customer, fail states that close the shop.
- Adapt: forgiving timers, generous tips, "perfect order" combos.

## Octalysis read (dominant drives, 2-4 bullets)
- CD2 Accomplishment: ratings, promotions, expansions.
- CD4 Ownership: your restaurant.
- CD5 Social: co-op roles and visiting customers.
- CD6 Scarcity: limited menu items and decor.

## Sources
[1] Rotrends Tycoon subgenre - https://rotrends.com/games/genre%3Asub%3ATycoon - checked 2026-11-03
[2] List of Roblox games (Wikipedia) - https://en.wikipedia.org/wiki/List_of_Roblox_games - checked 2026-11-03
[3] Publisher Collective: Working at a Pizza Place Roblox - https://srand.publisher-collective.com/news/working-at-a-pizza-place-roblox - checked 2026-11-03 (low-quality source; roles UNVERIFIED beyond search excerpt)
[4] DevForum: Restaurant Tycoon 2 Information - https://devforum.roblox.com/t/restaurant-tycoon-2-information/356970 - checked 2026-11-03
[5] Deltia's Gaming: Fast Food Simulator Roblox beginner's guide - https://deltiasgaming.com/?p=237060 - checked 2026-11-03 (search excerpt only)
[6] Subscriptions (Creator Docs) - https://create.roblox.com/docs/production/monetization/subscriptions - checked 2026-11-03
[7] Paid random items policy guidelines (Creator Docs) - https://create.roblox.com/docs/production/monetization/paid-random-items - checked 2026-11-03
[8] Roblox Newsroom: genre insights (Jul 2024) - https://about.roblox.com/newsroom/2024/07/roblox-genre-insights-what-will-you-create-next - checked 2026-11-03
[9] Roblox Kids and Select publishing (Creator Docs) - https://create.roblox.com/docs/production/publishing/kids-and-select - checked 2026-11-03
[10] Data store error codes and limits (Creator Docs) - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits - checked 2026-11-03
