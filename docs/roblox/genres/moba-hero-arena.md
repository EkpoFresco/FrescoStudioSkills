# Genre: MOBA and Hero Arena
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: medium - hero-kit arena brawlers are huge (Battlegrounds & Fighting: 6,505 games; The Strongest Battlegrounds at 19.57B visits), but true lane MOBAs have few hits [1].
Top Roblox references (mechanics only):
- The Strongest Battlegrounds (19.57B visits, ~74K CCU) and Jujutsu Shenanigans (7.86B, ~92K CCU): character-kit brawlers in free-for-all arenas [1].
- BedWars (Easy.gg): team action-strategy. Protect your bed, gather resources, buy gear mid-match, break enemy beds; 9B+ visits by 2024 [2][3].
- Blade Ball (6.52B visits): ability arena built on one deflect mechanic [1].
- Superhero Arena and Anime Ability Arena: hero-kit arenas [1].
- Lane MOBAs: few hits. Likely causes: match length, coordination without chat, touch controls, harsh new-player experience (heuristic).

## Core loop
- Pick hero or kit, drop into arena, fight, respawn in seconds, earn XP and currency, unlock heroes and skins.
- BedWars shape: base defense plus economy plus fights inside one 10-20 min match [3].
- Lane MOBA on Roblox: compress to 8-12 min, auto-leveling, few items (heuristic).

## Session one (what works in a first session on Roblox, minute by minute where possible)
- 0-1 min: spawn straight into a live FFA arena with a free hero. No lobby (heuristic).
- 1-3 min: first kill on dummies or weaker players; ability buttons labeled on screen.
- 3-8 min: respawn under 5 s; streak feedback.
- 8-12 min: first hero unlock or a trial of a paid hero.
- 12-20 min: team mode or squad queue with friends.
- Battlegrounds teach by sandbox, not tutorial (heuristic).

## Retention hooks (D1 / D7 / D30)
- D1: next hero unlock, daily quests.
- D7: weekly free-hero rotation, events.
- D30: ranked seasons, hero mastery, new hero releases (each hero is a content drop).
- Balance cadence matters. A stale meta kills arenas (heuristic).

## Monetization norms (what players accept on Roblox for this genre)
- Accepted: hero unlocks (Robux or grind), skins, kill effects, emotes, battle pass, private servers.
- Paid heroes that out-power free ones cause backlash in PvP. Keep them side-grades, rotate free trials (heuristic).
- Random skin crates follow paid random item odds rules [4].
- BedWars kit and battle pass pricing details: UNVERIFIED.

## Social and discovery levers
- Squads of 2-4. Keep parties together via `Player.PartyId` and `SocialService:GetPlayersByPartyId()` [5].
- Clippable combos and big ability VFX drive short-form video (heuristic).
- Chat is age-banded since Jan 2026 [6]. Ping wheels and emotes are the coordination layer.
- Roblox's 2024 genre insights singled out team competition and battlegrounds [2].
- Repeated mild violence is Mild; realistic blood is Moderate [7].

## Technical traps on Roblox
- Hit detection: client-side hitboxes with server validation. Pure server hitboxes feel laggy at mobile ping (heuristic).
- Validate range, cooldowns and movement speed on the server. Speed, reach and auto-parry exploits are standard (heuristic).
- Cap particles and VFX for low-end phones (heuristic).
- Match servers: reserved server per match; retry failed teleports; teleport data is client-visible [5].
- Arena size: 12-30 players per server keeps fights readable (heuristic).

## What transfers from outside Roblox (what to keep, what breaks on Roblox's young, mobile, short-session audience)
External titles are common design references, described from general knowledge (heuristic).
- Keep: Brawl Stars 2-3 min modes and aim assist; Overwatch-style role kits; Smash knockback readability; Pokemon Unite's simple scoring objectives.
- Breaks: 30-40 min LoL or Dota matches, last-hitting, 100-item shops, punishing new players.
- Adapt: lanes as short objectives, bot backfill, kits readable in one look.

## Octalysis read (dominant drives, 2-4 bullets)
- CD2 Accomplishment: kills, ranks, mastery.
- CD4 Ownership: hero rosters and skins.
- CD5 Social: squads and rivalry.
- CD3 Creativity: combo and kit expression.

## Sources
[1] Rotrends Battlegrounds & Fighting subgenre - https://rotrends.com/games/genre%3Asub%3ABattlegrounds%20%26%20Fighting - checked 2026-11-03
[2] Roblox Newsroom: genre insights (Jul 2024) - https://about.roblox.com/newsroom/2024/07/roblox-genre-insights-what-will-you-create-next - checked 2026-11-03
[3] List of Roblox games (Wikipedia) - https://en.wikipedia.org/wiki/List_of_Roblox_games - checked 2026-11-03
[4] Paid random items policy guidelines (Creator Docs) - https://create.roblox.com/docs/production/monetization/paid-random-items - checked 2026-11-03
[5] Teleport between places (Creator Docs) - https://create.roblox.com/docs/projects/teleporting - checked 2026-11-03
[6] Roblox Newsroom: age checks and chat limits (Nov 2025) - https://about.roblox.com/newsroom/2025/11/roblox-requires-age-checks-limits-minor-and-adult-chat - checked 2026-11-03
[7] Content maturity labels (Creator Docs) - https://create.roblox.com/docs/production/promotion/content-maturity - checked 2026-11-03
