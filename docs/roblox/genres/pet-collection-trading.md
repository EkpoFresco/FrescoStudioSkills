# Genre: Pet Collection / Eggs / Trading
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - this is a top-earning loop on the platform. Legal and policy load is the highest of any genre (odds disclosure, country restrictions, trade gating) [1].
Top Roblox references (mechanics only):
- Adopt Me!: care tasks age pets through 6 stages. Four full-grown pets of the same type make a Neon, and four Neons make a Mega Neon. Trade license gates trades above rare. Anti-scam unfair-trade alerts [2].
- Pet Simulator 99: Normal, Golden, Rainbow, Huge, Titanic, and Gargantuan tiers. Trading Plaza and auctions. Server-wide cutscenes for top hatches [3].
- Steal An Egg (2026): steal eggs from biome nests, hatch them in your pen. Mutations multiply income (Golden 2.5x, Rainbow 3.5x) [4]. 1.6M CCU on 2026-09-30 [5].
- Ride A Pet (2026): hatched pets double as mounts, so speed gates rarer eggs [5].

## Core loop
- Earn currency, buy or open an egg, reveal a pet, the pet boosts income or stats, buy rarer eggs, trade duplicates for wants.
- Merge or fusion sinks (Neon-style 4-into-1) turn duplicates into progress and keep supply in check [2].
- A trading economy turns rarity into social value. Value lists and Discord communities form around it [3].

## Session one
- 0:00-1:00: a free starter egg. The first hatch animation is the hook, so make it loud (heuristic).
- 1-5 min: a second egg affordable fast. Show a rarity table with odds (required for paid eggs) [1].
- 5-15 min: the first equip-slot decision and the first mutation or shiny chance.
- 15-30 min: see another player's Huge-tier pet. Aspiration plus a trade-plaza teaser.
- Exit: an incubating egg or a timed free egg.

## Retention hooks (D1 / D7 / D30)
- D1: free timed eggs, daily care tasks (Adopt Me style aging) [2].
- D7: weekly or biweekly updates with limited eggs. PS99 reportedly updates about every 2 weeks [3].
- D30: retired pets gain value, fusion ladders, collection indexes. Power creep devalues old pets, which can hurt trust [3].

## Monetization norms
- Luck passes and Huge-odds passes. Reported PS99 prices: 275, 800, 1,200, 3,250 R$, about 8K R$ total (third-party) [3].
- Robux-only eggs and rotating exclusive shops (about 400 R$ per egg reported) [3].
- Paid random items rules [1]:
  - Every possible outcome and its exact odds, in percent, shown before purchase, summing to 100%. Rounding needs a disclaimer.
  - Applies to indirect purchases too (tickets or keys bought with Robux, or paid currency).
  - Luck boosts must state their effect numerically, and displayed odds must update while active. Pity systems count as probability modifiers.
  - A bare (i) icon is not sufficient. Use a labeled pop-up.
  - Check `PolicyService:GetPolicyInfoForPlayerAsync()`. If `ArePaidRandomItemsRestricted`, offer an earnable path, a fixed order, a direct buy priced by expected value, or hide or block the item.
  - If `IsPaidItemTradingAllowed` is false, that user cannot trade the outcome.
- Roblox applied Korea-style disclosure worldwide in 2026 [6].
- Platform Limited-item trading needs Roblox Plus or legacy Premium. In-experience trading is a separate system [7].

## Social and discovery levers
- Visible pets as status. Server announcements for rare hatches.
- Trade hubs create a reason to be online together, which is a co-play signal [8].
- Real-money trading off-platform (eBay, Discord) violates Roblox ToS and fuels scams. Design trade UX to resist "trust trades" [2][3].

## Technical traps on Roblox
- Duplication is the top risk. Use session locking (ProfileStore) plus atomic trade commits on the server. Log every trade with IDs [9].
- Never let the client roll the RNG. Roll on the server, store the seed or result before the animation plays (heuristic).
- Give each pet a unique ID and keep an inventory schema with versioning. Big inventories approach the 4 MB per key, so paginate or compress [10].
- Rendering many followers kills mobile. Cap visible followers per player and use simple rigs (heuristic).
- Trade scam UX: two-step confirm, a countdown on changes, a value-delta warning (Adopt Me model) [2].

## What transfers from outside Roblox
- Pokemon: completion index plus trade-to-complete (heuristic).
- Gacha (Genshin and others): pity counters, rate-up transparency, duplicate conversion (heuristic).
- Neopets: pet care plus economy. Its inflation history warns you to design currency sinks early (heuristic).

## Octalysis read
- CD4 Ownership and Possession: dominant.
- CD7 Unpredictability: hatches and mutations. This is also where the regulatory risk sits.
- CD5 Social Influence: trading and status.
- CD6 Scarcity: limited or retired eggs.

## Sources
[1] Roblox Creator Hub, Paid random items policy - https://create.roblox.com/docs/production/monetization/paid-random-items - checked 2026-11-03
[2] Wikipedia, Adopt Me! - https://en.wikipedia.org/wiki/Adopt_Me! - checked 2026-11-03
[3] RoWatcher, Pet Simulator 99 monetization (third-party) - https://rowatcher.com/news/pet-simulator-99-inside-roblox-s-most-aggressive-monetization-machine - checked 2026-11-03
[4] RBLX Guide, Steal an Egg beginner guide - https://rblxguide.com/games/steal-an-egg/updates/beginner-guide - checked 2026-11-03
[5] StudioKrew, Top Roblox games September 2026 - https://studiokrew.com/blog/top-roblox-games-september-2026/ - checked 2026-11-03
[6] Tech Times, Korea's loot box rules push Roblox to disclose odds worldwide (2026-06-26) - https://www.techtimes.com/articles/319148/20260626/koreas-loot-box-rules-push-roblox-disclose-item-odds-worldwide.htm - checked 2026-11-03
[7] Roblox Newsroom, Introducing Roblox Plus (2026-04) - https://about.roblox.com/newsroom/2026/04/introducing-roblox-plus-subscription - checked 2026-11-03
[8] Roblox Creator Hub, Discovery - https://create.roblox.com/docs/discovery - checked 2026-11-03
[9] DevForum, ProfileStore - https://devforum.roblox.com/t/profilestore/3190543 - checked 2026-11-03
[10] Roblox Creator Hub, Data store limits - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits - checked 2026-11-03
