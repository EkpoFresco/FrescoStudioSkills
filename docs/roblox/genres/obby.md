# Genre: Obby (obstacle course, tower, difficulty chart)
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - this is a native genre with official subgenres (Classic Obby, Runner, Tower Obby) [1]. It is cheap to build and easy to theme, but very crowded.
Top Roblox references (mechanics only):
- Tower of Hell: a randomly generated tower with no checkpoints. VIP-server owners can skip rounds, set tower size, and lock the shop [2].
- +1 Speed escape obbies (2026): every step adds speed, mixing a speed stat into the course. One hit 137.9K CCU (Sept 2026) [3].
- Glide Tower and an escape-themed obby: Roblox's own rewarded-video examples (checkpoint respawn, a one-life item) [4].
- Brainrot-themed escape and swing obbies (2025-2026): trend reskins of the obby loop. One reported peak was about 5M CCU (third-party, UNVERIFIED) [5].

## Core loop
- Attempt, fail, respawn at a checkpoint, learn, clear the stage, see the next stage, repeat.
- Tower variant: a timed round, a shared race to the top, the tower rerolls each round.
- Difficulty chart (heuristic): stages are color-banded by difficulty with a visible progress chart. Each band is a goal.
- Hybrid trend: add a persistent stat (speed, jump) so failure still yields progress [3].

## Session one
- 0:00-0:10: spawn facing stage 1. No menu or tutorial needed, because jumping is the tutorial (heuristic).
- 0-3 min: 5-10 trivial stages for fast wins. Stage counter visible.
- 3-10 min: the first real fail spike. Offer a checkpoint revive or a skip prompt here [4].
- 10-20 min: a themed section change or a cosmetic unlock (trail, title) at a milestone stage.
- Exit: "you're at stage 34 / 100" saved progress, plus a leaderboard position.

## Retention hooks (D1 / D7 / D30)
- Obbies run on a mastery clock, not a time clock. Third-party claim: healthy obby D1 is about 15-22%, below simulator norms, with players returning days later (UNVERIFIED) [6].
- D1: saved stage, daily reward, a "beat your time" ghost.
- D7: new stage packs on a weekly cadence, and weekly speedrun leaderboards.
- D30: completion badges, hard-mode remixes, a creator mode if you have one.
- Track D7 and D30 reacquisition and depth on return, not only D1 [6].

## Monetization norms
- Dev products: skip stage (the genre's signature purchase), skip to end, revive, temporary gear such as a speed coil (heuristic, widely observed; prices UNVERIFIED).
- Passes: permanent gravity or speed coils, trails, VIP server perks, 2x coins (heuristic).
- Rewarded video placements: first view, invest-and-progress, post-failure second chance. Benchmark: 15-25% opt-in (best 30%+), about 3 views per day (best 4+) [4].
- Glide Tower reported a 47% opt-in on checkpoint-respawn ads [4].
- Players accept skips because skipping is voluntary. Pay-gated stages read as a cash grab (heuristic).

## Social and discovery levers
- Group races (tower rounds) create spectating and rivalry in a shared server.
- Friend-carry mechanics (two-player obbies, tethers) feed the co-play signal [7].
- Fail clips drive TikTok and YouTube shorts. Design dramatic fail points (heuristic).
- Trend-theme reskins are the main discovery lever. They die fast, so ship them fast [5].

## Technical traps on Roblox
- Client-authoritative movement means fly, teleport, and noclip hacks. Validate stage touches on the server, with time and distance sanity checks (heuristic).
- Checkpoint saves: write on stage clear but throttle. Respect the per-key write throughput [8].
- Kill bricks and moving parts: use client-side tweens with server-owned truth. Network-owned physics platforms jitter on mobile (heuristic).
- Mobile: jump buttons and camera make precision jumps harder. Tune the gaps for touch, or offer an easy mode (heuristic).
- Long courses: StreamingEnabled plus part-count discipline.

## What transfers from outside Roblox
- Getting Over It and Jump King: frustration plus visible height is shareable content (heuristic).
- Celeste: assist modes widen the audience without breaking mastery (heuristic).
- Fall Guys: short rounds and elimination spectacle for party obbies (heuristic).

## Octalysis read
- CD2 Accomplishment: stage counters, completion badges.
- CD5 Social Influence: races, leaderboards, spectating.
- CD8 Loss and Avoidance: losing progress (no checkpoints) raises stakes in tower variants.
- CD6 Scarcity: skip products monetize impatience.

## Sources
[1] Roblox Creator Hub, Experience genres - https://create.roblox.com/docs/production/publishing/experience-genres - checked 2026-11-03
[2] Roblox, Tower of Hell game page - https://www.roblox.com/games/1962086868/Tower-of-Hell - checked 2026-11-03
[3] StudioKrew, Top Roblox games September 2026 - https://studiokrew.com/blog/top-roblox-games-september-2026/ - checked 2026-11-03
[4] Roblox Creator Hub, Rewarded video playbook: Obby - https://create.roblox.com/docs/production/promotion/rewarded-video-playbooks/obby - checked 2026-11-03
[5] RoWatcher, Is the Brainrot Trend Dying (third-party) - https://rowatcher.com/news/is-the-brainrot-trend-dying-what-ccu-data-from-three-top-games-reveals - checked 2026-11-03
[6] RoWatcher, Simulators and Obbies Need Different Retention Clocks (third-party) - https://rowatcher.com/news/simulators-and-obbies-need-different-retention-clocks - checked 2026-11-03
[7] Roblox Creator Hub, Discovery - https://create.roblox.com/docs/discovery - checked 2026-11-03
[8] Roblox Creator Hub, Data store limits - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits - checked 2026-11-03
