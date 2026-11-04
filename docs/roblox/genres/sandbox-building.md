# Genre: Sandbox and Building
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - building and physics play are native to Roblox. Build A Boat For Treasure (5.25B visits) and physics toys like Fling Things and People (3.7B) still chart years after launch [1][2].
Top Roblox references (mechanics only):
- Build A Boat For Treasure (Chillz Studios, 2016): build a boat from blocks, sail a hazard course to treasure, earn gold for parts [1][3].
- Plane Crazy (512M visits) and Build A Plane (782M): vehicle builders with mechanical parts [1].
- Fling Things and People, ragdoll playgrounds, Destruction Engine Testing: physics destruction toys [2].
- Build with Voxels (166M) and Terraform-style tools: voxel creative build [1].
- Natural Disaster Survival: survive disasters on a destructible map [4].

## Core loop
- Plot builder: get parts, build, test (sail, fly, crash), earn, unlock parts, rebuild.
- Destruction: spawn tools, wreck structures, chain reactions, earn, bigger tools and maps.
- Creative: free build, share, get likes, show off.
- A test goal is required. BABFT's treasure run gives building a purpose; goal-free building churns fast (heuristic).

## Session one (what works in a first session on Roblox, minute by minute where possible)
- 0-1 min: spawn on a plot with a prebuilt starter vehicle and a "Launch" button. Test first, build second (heuristic).
- 1-3 min: starter fails partway; reward still paid.
- 3-6 min: guided build, place 5 snapped parts, relaunch, get further.
- 6-12 min: first new part type (thruster, wheel); showcase of better builds nearby.
- 12-20 min: open build, friend build-off or themed challenge.
- Touch tools: big gizmos, grid snap, undo. Free-form CAD on phones is the top failure (heuristic).

## Retention hooks (D1 / D7 / D30)
- D1: saved unfinished build, daily quest ("reach stage 5"), part chest.
- D7: weekly themed contests, limited parts.
- D30: blueprint sharing and building for an audience; builders with fans stay longest (heuristic).
- Destruction toys: new maps, tools, server events (meteor shower) (heuristic).

## Monetization norms (what players accept on Roblox for this genre)
- Accepted: part packs, premium tools (resize, move), bigger plots, extra save slots, 2x gold, materials and colors, private servers.
- Destruction: bigger explosives and tools as passes.
- Physics toys earn little per user; volume and sponsorships matter (heuristic).
- Save slots and blueprint sharing are high value and low controversy (heuristic).

## Social and discovery levers
- Show-off: plot visits, likes, best-build votes, a server showcase stage.
- Co-building with friend permissions.
- Physics chaos is clip fuel for short video (heuristic).
- Repeated mild ragdoll violence rates Mild; realistic blood pushes to Moderate [5].
- Player builds must meet Community Standards. Ship report and plot-reset tools (heuristic).

## Technical traps on Roblox
- Player builds explode part counts. Cap parts per plot, merge static parts, use streaming (heuristic).
- Serialize builds compactly (part id, quantized CFrame, color index). Max 4,194,304 characters per DataStore key; per-key writes capped at 4 MB per minute [6].
- Network ownership lets clients fling others. Griefing is the default; add anti-fling and plot locks (heuristic).
- Welds and joints break differently on low-end Android; test there (heuristic).

## What transfers from outside Roblox (what to keep, what breaks on Roblox's young, mobile, short-session audience)
External titles are common design references, described from general knowledge (heuristic).
- Keep: Minecraft's survival-to-creative ladder; Besiege's goal-based machine tests; Teardown-style satisfying debris; Animal Crossing room ratings.
- Breaks: deep CAD tools (Space Engineers) on touch; long goal-free sessions; complex wiring logic for 9-15.
- Adapt: templates, prefab modules, and a test run in under 30 s.

## Octalysis read (dominant drives, 2-4 bullets)
- CD3 Creativity and Feedback: the core.
- CD4 Ownership: plots and saved builds.
- CD5 Social: show-off and co-building.
- CD7 Unpredictability: physics chaos.

## Sources
[1] Rotrends Sandbox subgenre - https://rotrends.com/games/genre%3Asub%3ASandbox - checked 2026-11-03
[2] Rotrends Physics Sim subgenre - https://rotrends.com/games/genre%3Asub%3APhysics%20Sim - checked 2026-11-03
[3] Pocket Tactics: Build a Boat for Treasure passes three billion visits - https://www.pockettactics.com/build-a-boat-for-tresure/visits - checked 2026-11-03
[4] List of Roblox games (Wikipedia) - https://en.wikipedia.org/wiki/List_of_Roblox_games - checked 2026-11-03
[5] Content maturity labels (Creator Docs) - https://create.roblox.com/docs/production/promotion/content-maturity - checked 2026-11-03
[6] Data store error codes and limits (Creator Docs) - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits - checked 2026-11-03
