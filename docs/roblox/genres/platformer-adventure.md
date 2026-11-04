# Genre: Platformer and Adventure
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - Obby & Platformer holds ~678K live CCU across ~26K games [1]. Collectathons ("find the" games) are a solid niche; metroidvania-lite has few hits.
Top Roblox references (mechanics only):
- Tower of Hell: multiplayer tower platformer [2].
- Speed Run 4 (Vurse): speed platformer [2].
- Sonic Speed Simulator (Gamefam with Sega, 2022): incremental platformer, 1B visits by Aug 2024 [2].
- Find-the games: Find the Markers (988M visits), Find the Brainrot (580M), Secret Staycation (1.17B) [3].
- Exploration: Drill to Earth's Core (89.5M visits, ~10.7K CCU) [4].
- Metroidvania-lite: few hits. Ability-gated backtracking clashes with short, drop-in sessions (heuristic).

## Core loop
- Obby: run stages, checkpoint, fail, retry, finish, earn, cosmetics.
- 3D platformer: hub, worlds, collectibles open gates to new worlds.
- Find-the: explore, find a hidden item, earn a badge, counter climbs (e.g., "321" in the title) [3].
- Metroidvania-lite: new ability opens old paths (heuristic).

## Session one (what works in a first session on Roblox, minute by minute where possible)
- 0-1 min: spawn facing stage 1 with the next platform in view. Jump right away.
- 1-3 min: first checkpoint, first collectible, first badge.
- 3-8 min: first ability (double jump, dash) or speed coil.
- 8-15 min: hub with doors to worlds; collection counter on screen.
- 15-20 min: friend race or tower round.
- Big mobile jump button and generous ledges (heuristic).

## Retention hooks (D1 / D7 / D30)
- D1: next stage or world, leaderboards.
- D7: find-the updates add new collectibles and raise the count [3].
- D30: badge completion, speedrun boards, new worlds.
- Round-based towers that change layout keep replays fresh (Tower of Hell mechanism UNVERIFIED).

## Monetization norms (what players accept on Roblox for this genre)
- Accepted: skip-stage products, speed and gravity coils in casual obbies, trails, emotes, radio passes.
- Competitive towers and races: cosmetic only; paid skips ruin leaderboards (heuristic).
- Find-the: hint passes, teleporters between zones (heuristic).

## Social and discovery levers
- Racing friends, spectating, shared round timers.
- Find-the leans on YouTube guides; each new collectible is a video (heuristic).
- Roblox counted ~14M searches for open world action with parkour interest in Q1 2024 [5].
- New games reach only age-checked 16+ until 250 engaged unique plays in 60 days [6]. Obbies skew young, so plan for this gate.

## Technical traps on Roblox
- Characters are client-owned physics. Exploiters fly and teleport. Validate checkpoints in order and with minimum times (heuristic).
- Custom controllers can desync; tune Humanoid jump and walk before replacing it (heuristic).
- Moving platforms: animate client-side for smoothness, check server-side (heuristic).
- Camera clipping in tight spaces on mobile (heuristic).
- Save collectibles as bitsets or id lists in one DataStore key [7].

## What transfers from outside Roblox (what to keep, what breaks on Roblox's young, mobile, short-session audience)
External titles are common design references, described from general knowledge (heuristic).
- Keep: Mario Odyssey dense collectibles; A Hat in Time hub worlds; Celeste instant respawn; Only Up! vertical spectacle; Fall Guys party races.
- Breaks: precision platforming on touch, long levels without checkpoints, complex metroidvania maps, 2D views.
- Adapt: checkpoints every 20-30 s, abilities as gates, show the map.

## Octalysis read (dominant drives, 2-4 bullets)
- CD2 Accomplishment: stages, towers, badges.
- CD7 Curiosity: hidden collectibles.
- CD4 Ownership: badge collections.
- CD5 Social: races.

## Sources
[1] RoWatcher Genre Observatory (live CCU snapshot) - https://rowatcher.com/genres - checked 2026-11-03
[2] List of Roblox games (Wikipedia) - https://en.wikipedia.org/wiki/List_of_Roblox_games - checked 2026-11-03
[3] Rotrends Scavenger Hunt subgenre - https://rotrends.com/games/genre%3Asub%3AScavenger%20Hunt - checked 2026-11-03
[4] Rotrends Exploration subgenre - https://rotrends.com/games/genre%3Asub%3AExploration - checked 2026-11-03
[5] Roblox Newsroom: genre insights (Jul 2024) - https://about.roblox.com/newsroom/2024/07/roblox-genre-insights-what-will-you-create-next - checked 2026-11-03
[6] Roblox Kids and Select publishing (Creator Docs) - https://create.roblox.com/docs/production/publishing/kids-and-select - checked 2026-11-03
[7] Data store error codes and limits (Creator Docs) - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits - checked 2026-11-03
