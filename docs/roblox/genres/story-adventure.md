# Genre: Story and Adventure
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: medium - chapter-based story games are a proven Roblox format (Piggy 12B plays, Break In 3B visits), almost always fused with horror, survival or comedy; pure narrative and point-and-click are weak [1][2].
Top Roblox references (mechanics only):
- Piggy (MiniToon, 2020): episodic horror released chapter by chapter; 12B plays by Nov 2023 [1]. Book 1 ran 12 chapters with collectible pages [3].
- Break In (Cracky4, 2019) and Break In 2 (2023): role-pick co-op story with good and bad endings; 3.03B and 1.05B visits [2][4].
- Rainbow Friends and The Mimic: episodic horror; Rainbow Friends at 5.17B visits [1][2].
- Weird Strict Dad (BlueLoop Studios, 2023): comedic chores-and-sneak story, ~532M visits [5].
- Story subgenre: 1,549 games. Top titles carry "[CH3]" or "Chapter 2" tags, so chapter numbers act as a discovery signal [2].

## Core loop
- Play a 10-25 min chapter with friends: short cutscene, objective, set piece, threat, ending, reward.
- Replay: alternate endings, roles, hidden badges, harder difficulty.
- Meta: chapter select, cosmetics per ending, lore collectibles (Piggy-style pages) [3].

## Session one (what works in a first session on Roblox, minute by minute where possible)
- 0-1 min: lobby with a "Start Story" pad and party countdown. Fills servers fast (heuristic).
- 1-3 min: cutscene under 30 s, skippable on repeat. First objective in five words.
- 3-10 min: first choice with a visible consequence (role or item pick), first set piece.
- 10-18 min: escalation, threat, a fail with quick checkpoint retry.
- 18-25 min: ending reveal, badge, "ending 1 of 4", next-chapter teaser.
- Keep a chapter under 25 min for mobile sessions (heuristic).

## Retention hooks (D1 / D7 / D30)
- D1: other endings, other roles, secret badge hunts.
- D7: next chapter drop with a lobby countdown.
- D30: chapter cadence plus an endless or hub mode. Story games spike on release and decay between chapters (heuristic).
- Long tail is real: Break In peaked at ~13K CCU in Dec 2024, five years after launch [4].
- Experience Notifications for "Chapter 3 is live": opt-in, 13+ only, max 1 per day [6].

## Monetization norms (what players accept on Roblox for this genre)
- Accepted: special role passes, revives or checkpoint skips, character skins, gadget passes in comedy stories, private servers.
- Story has low replay, so revenue rides on cosmetics and roles that carry across chapters (heuristic).
- Avoid paywalling a chapter ending. Kids read it as a scam (heuristic).
- Early access to new chapters for payers is a common pattern (UNVERIFIED).

## Social and discovery levers
- Squads of 4 with distinct roles force cooperation.
- Design for reaction videos: jump scare, twist, ending card (heuristic).
- Jump scares and creepy NPCs are Mild; realistic blood or disfigurement is Moderate and drops Roblox Kids (5-8); romance is Restricted (18+) [7].
- New games reach only age-checked 16+ until 250 engaged unique plays in 60 days [8].
- Roblox flagged horror as its fastest-growing area in 2024 [9].

## Technical traps on Roblox
- Cutscenes run on the client with server triggers. Late joiners desync shared beats; gate joins during scenes (heuristic).
- Voice lines: since Mar 22, 2022 new audio is private and works only in experiences owned by the uploader (user or group) [10].
- Branch flags: store compactly per player; never break old saves when retconning (heuristic).
- One place per chapter via TeleportService. Teleport data is client-visible; keep progress in DataStores [11].
- Keep dialogue short and localized; all text passes Roblox filtering (heuristic).

## What transfers from outside Roblox (what to keep, what breaks on Roblox's young, mobile, short-session audience)
External titles are common design references, described from general knowledge (heuristic).
- Keep: Telltale-style visible choices; Five Nights at Freddy's lore drip; Life is Strange chapter cadence; Undertale alternate endings as collectibles.
- Keep: point-and-click only when physical (drag key to door).
- Breaks: long dialogue trees, solo narrative, 2-hour chapters, obscure inventory combinations, text-only lore.
- Adapt: co-op story with roles; endings as a checklist.

## Octalysis read (dominant drives, 2-4 bullets)
- CD7 Curiosity: what happens next, hidden endings.
- CD1 Epic Meaning: characters and lore build fandoms.
- CD6 Scarcity: chapter countdowns.
- CD8 Loss Avoidance: the threat in horror stories.

## Sources
[1] List of Roblox games (Wikipedia) - https://en.wikipedia.org/wiki/List_of_Roblox_games - checked 2026-11-03
[2] Rotrends Story subgenre - https://rotrends.com/games/genre%3Asub%3AStory - checked 2026-11-03
[3] Sportskeeda: Piggy Book 1 pages guide - https://www.sportskeeda.com/roblox-news/piggy-book-1-pages-guide-all-chapters-page-locations - checked 2026-11-03
[4] RoWatcher: Break In (Story) - https://rowatcher.com/games/1318971886/break-in-story - checked 2026-11-03
[5] Bloxodes: Weird Strict Dad stats - https://bloxodes.com/stats/games/weird-strict-dad-5096440156 - checked 2026-11-03
[6] Experience Notifications (Creator Docs) - https://create.roblox.com/docs/production/promotion/experience-notifications - checked 2026-11-03
[7] Content maturity labels (Creator Docs) - https://create.roblox.com/docs/production/promotion/content-maturity - checked 2026-11-03
[8] Roblox Kids and Select publishing (Creator Docs) - https://create.roblox.com/docs/production/publishing/kids-and-select - checked 2026-11-03
[9] Roblox Newsroom: genre insights (Jul 2024) - https://about.roblox.com/newsroom/2024/07/roblox-genre-insights-what-will-you-create-next - checked 2026-11-03
[10] DevForum: Changes to asset privacy for audio - https://devforum.roblox.com/t/1701697 - checked 2026-11-03
[11] Teleport between places (Creator Docs) - https://create.roblox.com/docs/projects/teleporting - checked 2026-11-03
