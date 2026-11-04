# Genre: Card, Board and Casual
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: weak - deckbuilders and match-3 have no breakout; social board games are a medium niche. Board & Card has 285 games, top live CCU ~4.4K; Match & Merge has 150, top ~5.4K [1][2].
Top Roblox references (mechanics only):
- Monopoly-likes: Ronopoly (81M visits), Monopoly (35.6M) [1].
- Regional classics: CHESS! (114M), Ludo variants, Korean Board Game Cafe, Yut Nori [1].
- Card: Hitman Card Game (32M); Breach the Bastion: Deck Builder Card Game (~1.1K CCU on 359K visits, new and rising) [1].
- Party minigames: Epic Minigames [3]; Party & Casual holds ~381K live CCU overall [4].
- Merge: Merge Shop (60M visits), Impossible Animals (5.4K CCU) [2].

## Core loop
- Board: sit at table, 20-60 s turns, 10-20 min game, earn coins, unlock dice, tokens, table themes.
- Card battler: build deck, 3-5 min 1v1, win rewards, open packs, upgrade cards.
- Match/merge: short levels, stars, boosters, map progress.
- Party: rotating 1-2 min minigames, points, podium.

## Session one (what works in a first session on Roblox, minute by minute where possible)
- 0-1 min: walk to a table in a 3D lobby, auto-seat, bots fill empty seats instantly.
- 1-3 min: first turn with highlighted valid moves, no rules page.
- 3-10 min: short first game (half board, 3 rounds), likely win.
- 10-15 min: first pack or cosmetic; collection book opens.
- 15-20 min: matchmade game with real players; friend invite.
- Never let a player wait over ~15 s for seats (heuristic).

## Retention hooks (D1 / D7 / D30)
- D1: daily pack and quests, collection gaps.
- D7: weekly rotating format or tournament.
- D30: ranked seasons, new card sets, seasonal boards.
- Board games retain through friend groups and private servers; solo players churn (heuristic).

## Monetization norms (what players accept on Roblox for this genre)
- Accepted: cosmetics (dice, card backs, tables, emotes), packs, battle pass, VIP servers, starter bundles.
- Card packs bought with Robux, or with currency bought with Robux, are paid random items [5]:
  - Show every outcome and odds as percentages summing to exactly 100% before purchase. A labeled pop-up is fine; a bare (i) icon is not.
  - Same-odds items may share one line: "Odds for each item listed below: X%". Rounding needs a disclaimer.
  - Luck boosts, pity, rate-up: explain before purchase and show updated odds while active. Single-instance outcomes must update remaining odds per user.
  - Exempt: random rewards earned without spending Robux or paid currency.
  - If `ArePaidRandomItemsRestricted` is true: earnable path, fixed disclosed order, direct purchase priced on expected value, hide, block, or move the user.
  - If `IsPaidItemTradingAllowed` is false: no trading of paid random outcomes.
- Roblox rolled the revised disclosure rules out globally, reported June 2026, after Korea's loot box law [6].
- Gambling: "games cannot contain playable gambling content, including simulated gambling". Wagering Robux or items of value on chance counts [7]. Avoid chip-staking blackjack or poker; depicted casinos only, rated Moderate [7].

## Social and discovery levers
- "Social co-opetition" searches (bingo, board game, fashion) hit ~7.5M in Q1 2024 [8].
- Regional classics win locally (Yut Nori, Ludo, Korean cafe) [1]. Localize boards and rules.
- Tables inside a hub: spectators, emotes, reactions. Avatars sitting at tables is the Roblox edge (heuristic).
- Chat is age-banded [9]; ship quick-chat phrases.

## Technical traps on Roblox
- Turn timers, AFK bot takeover, resume on rejoin (heuristic).
- Shuffle and draw on the server. Never replicate hidden hands to other clients (heuristic).
- Log pack openings server-side to audit published odds (heuristic).
- Store card counts compactly; 4,194,304 characters per DataStore key [10].
- Icon-first card UI; text must read on phones (heuristic).

## What transfers from outside Roblox (what to keep, what breaks on Roblox's young, mobile, short-session audience)
External titles are common design references, described from general knowledge (heuristic).
- Keep: Clash Royale and Marvel Snap short matches; Balatro run scoring; Hearthstone pack theatre; Mario Party and Jackbox variety; Candy Crush map progress.
- Breaks: long rule texts, 40-minute matches, deep keyword systems, gacha pressure under new odds rules.
- Adapt: physical 3D tables, social first, matches under 10 min.

## Octalysis read (dominant drives, 2-4 bullets)
- CD4 Ownership: collections.
- CD7 Unpredictability: draws and packs (with disclosed odds).
- CD5 Social: tables with friends.
- CD2 Accomplishment: ranks and set completion.

## Sources
[1] Rotrends Board & Card Games subgenre - https://rotrends.com/games/genre%3Asub%3ABoard%20%26%20Card%20Games - checked 2026-11-03
[2] Rotrends Match & Merge subgenre - https://rotrends.com/games/genre%3Asub%3AMatch%20%26%20Merge - checked 2026-11-03
[3] List of Roblox games (Wikipedia) - https://en.wikipedia.org/wiki/List_of_Roblox_games - checked 2026-11-03
[4] RoWatcher Genre Observatory (live CCU snapshot) - https://rowatcher.com/genres - checked 2026-11-03
[5] Paid random items policy guidelines (Creator Docs) - https://create.roblox.com/docs/production/monetization/paid-random-items - checked 2026-11-03
[6] TechTimes: Korea's loot box rules push Roblox to disclose item odds worldwide (Jun 2026) - https://www.techtimes.com/articles/319148/20260626/koreas-loot-box-rules-push-roblox-disclose-item-odds-worldwide.htm - checked 2026-11-03
[7] Content maturity labels (Creator Docs) - https://create.roblox.com/docs/production/promotion/content-maturity - checked 2026-11-03
[8] Roblox Newsroom: genre insights (Jul 2024) - https://about.roblox.com/newsroom/2024/07/roblox-genre-insights-what-will-you-create-next - checked 2026-11-03
[9] Roblox Newsroom: age checks and chat limits (Nov 2025) - https://about.roblox.com/newsroom/2025/11/roblox-requires-age-checks-limits-minor-and-adult-chat - checked 2026-11-03
[10] Data store error codes and limits (Creator Docs) - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits - checked 2026-11-03
