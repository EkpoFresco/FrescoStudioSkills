# Genre: Puzzle and Escape
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: medium - pure puzzle is small (~72K live CCU across ~2K games), but puzzles inside co-op horror and "escape" fantasies are big [1][2].
Top Roblox references (mechanics only):
- Doors (LSPLASH and Red, 2022): roguelite horror escape room. Door-by-door rooms, items, entities with tells; modifiers and a second floor added later [2].
- Flee the Facility (A.W. Apps): asymmetric horror escape. Survivors hack computers while one beast hunts; 3B+ visits by Apr 2022 [2].
- Escape Room subgenre: 320 games. MONOCHROME (204M visits), Project: Escape Room (94M), Escape 99 Rooms (81M), Terminal (71M) [3].
- Word and merge: Last Letter (139M visits), Finish The Word! (105M), Merge Shop (60M) [4][5].
- Physics puzzles: few hits. Physics succeeds as sandbox play (Fling Things and People, 3.7B visits), not as solved puzzles [6].

## Core loop
- Enter room, observe, find clue, use or combine, unlock, next room. 1-5 min per room (heuristic).
- Co-op: split information across players (one sees the code, one has the keypad) (heuristic).
- Meta: chapter list, star rating per room (time, hints used), cosmetics for completion.
- Threat wrapper (timer, monster) turns thinking into urgency. This is why horror escapes outperform calm puzzles (heuristic).

## Session one (what works in a first session on Roblox, minute by minute where possible)
- 0-1 min: spawn inside room one, not a lobby. One glowing interactable.
- 1-3 min: first puzzle solvable by pressing things, zero reading. Door opens with big sound and VFX.
- 3-8 min: second room teaches carry or combine. Free hint button visible.
- 8-15 min: first "aha" puzzle needing a teammate or careful observation. Optional threat appears.
- 15-20 min: chapter end, rating screen, next-chapter teaser, invite prompt.
- Core rooms solvable by a 9-year-old in 2-3 min; hard rooms are optional side doors (heuristic).

## Retention hooks (D1 / D7 / D30)
- D1: next chapter, missing stars, daily challenge room.
- D7: weekly room or chapter drop; fastest-escape leaderboards.
- D30: seasonal chapters or a player room editor. Puzzles burn content, so cadence beats depth (heuristic).
- Answers spread on YouTube within days. Randomize codes, item spots and room order per run, Doors-style (heuristic).

## Monetization norms (what players accept on Roblox for this genre)
- Accepted: hint packs (keep a free hint path), revives in horror variants, cosmetics, chapter or season passes, private servers for friend groups.
- Risky: skip-room products (removes the point), paywalls mid-puzzle (kids quit) (heuristic).
- Paid-access whole games only work with an existing fanbase (heuristic).
- Any random reward bought with Robux follows paid random item odds rules [7].

## Social and discovery levers
- Default to 2-4 player co-op. Split-info puzzles create shareable moments.
- Roblox called horror "extremely high growth"; Doors passed 5B visits in just over two years [8].
- Chat needs an age check since Jan 2026 and links only similar ages [9]. Make puzzles solvable via pings, emotes and pointing, not text.
- Jump scares and creepy NPCs rate Mild; realistic gore rates Moderate, which drops Roblox Kids (5-8) [10].
- New games reach only age-checked 16+ until 250 engaged unique plays in 60 days [11].

## Technical traps on Roblox
- Never keep solutions on the client. Exploiters read LocalScripts and ReplicatedStorage. Validate answers on the server (heuristic).
- Physics puzzles: a client with network ownership of a box can teleport it. Server-own key objects or validate positions (heuristic).
- Decide which puzzle states are shared vs per-player; sync state to late joiners (heuristic).
- Instance streaming can unload distant clue objects; keep key clues persistent (heuristic).
- Seed codes per server with `Random.new(seed)`; keep the seed server-side (heuristic).

## What transfers from outside Roblox (what to keep, what breaks on Roblox's young, mobile, short-session audience)
External titles are common design references, described from general knowledge (heuristic).
- Keep: The Room's tactile objects; Keep Talking and Nobody Explodes split info; Portal's teach, test, twist; hint ladders (nudge, clue, answer).
- Keep with care: 2048 and match-3 short loops. Match & Merge is small on Roblox (150 games, top ~5.4K CCU) [5].
- Breaks: text riddles (reading level, many languages), pixel hunts on phones, long solves, single-answer logic a wiki spoils.
- Adapt: physical and social puzzles over verbal ones.

## Octalysis read (dominant drives, 2-4 bullets)
- CD7 Unpredictability and Curiosity: what is behind the door.
- CD3 Creativity and Feedback: experimenting with objects.
- CD2 Accomplishment: stars and speed records.
- CD8 Loss and Avoidance (horror variants): the threat makes puzzles tense.

## Sources
[1] RoWatcher Genre Observatory (live CCU snapshot) - https://rowatcher.com/genres - checked 2026-11-03
[2] List of Roblox games (Wikipedia) - https://en.wikipedia.org/wiki/List_of_Roblox_games - checked 2026-11-03
[3] Rotrends Escape Room subgenre - https://rotrends.com/games/genre%3Asub%3AEscape%20Room - checked 2026-11-03
[4] Rotrends Word subgenre - https://rotrends.com/games/genre%3Asub%3AWord - checked 2026-11-03
[5] Rotrends Match & Merge subgenre - https://rotrends.com/games/genre%3Asub%3AMatch%20%26%20Merge - checked 2026-11-03
[6] Rotrends Physics Sim subgenre - https://rotrends.com/games/genre%3Asub%3APhysics%20Sim - checked 2026-11-03
[7] Paid random items policy guidelines (Creator Docs) - https://create.roblox.com/docs/production/monetization/paid-random-items - checked 2026-11-03
[8] Roblox Newsroom: genre insights (Jul 2024) - https://about.roblox.com/newsroom/2024/07/roblox-genre-insights-what-will-you-create-next - checked 2026-11-03
[9] Roblox Newsroom: age checks and chat limits (Nov 2025) - https://about.roblox.com/newsroom/2025/11/roblox-requires-age-checks-limits-minor-and-adult-chat - checked 2026-11-03
[10] Content maturity labels (Creator Docs) - https://create.roblox.com/docs/production/promotion/content-maturity - checked 2026-11-03
[11] Roblox Kids and Select publishing (Creator Docs) - https://create.roblox.com/docs/production/publishing/kids-and-select - checked 2026-11-03
