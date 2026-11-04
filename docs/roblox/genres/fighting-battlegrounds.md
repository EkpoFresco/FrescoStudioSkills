# Genre: Fighting and Battlegrounds
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - drop-in FFA servers, anime fandom, and readable kits; Jujutsu Shenanigans won Best Action in 2026 [1].
Top Roblox references (mechanics only):
- The Strongest Battlegrounds (Yielding Arts, Aug 2022): 8 moves per character (4 base, 4 via awakening), polished animation and VFX, over 17.2B visits [2].
- Jujutsu Shenanigans (Tze's Shenanigans): 21 free characters, M1 chains plus 4 cooldown abilities, dash, block, awakening, destructible terrain; peak about 338K CCU in Mar 2026 [3].
- Deepwoken (Monad Studios): parry and posture combat inside a permadeath RPG [4].

## Core loop
- Spawn into a shared FFA arena, pick a kit, fight, earn kills or awakening meter, die, respawn in seconds.
- Kit mastery is the progression: combos, cancels, tech (heuristic).
- Duels and 1v1 queues as side modes (JJS has Duels) [3].

## Session one
- 0 to 30 s: spawn straight into the arena with a starter kit. No tutorial wall (heuristic).
- 1 to 5 min: first kill on another newbie or a dummy; show combo prompts on screen (heuristic).
- 5 to 15 min: try 2 to 3 more kits (JJS: all free from the lobby) [3]; first awakening seen.
- Protect new players: lobby spawn shields, training room (heuristic).

## Retention hooks (D1 / D7 / D30)
- D1: new kit to learn, kill streak titles.
- D7: character drops on a steady cadence; JJS frames growth around character releases [3].
- D30: mastery, emotes, community metas and tier lists, ranked or 3v3 modes (TSB teased 3v3 and regional matchmaking) [2].

## Monetization norms
- Free kits is the norm at the top (JJS) [3]. TSB keeps core characters free [2].
- Early Access passes for work-in-progress characters (TSB: 300 Robux) [2]. Early access pricing is debated in JJS [3].
- Cosmetic passes: capes, chat tags, emotes, private servers [2].
- Paid stronger kits get punished (heuristic).

## Social and discovery levers
- Clip-driven: big ultimates and terrain destruction read well on video (heuristic).
- Anime-inspired kits trend with seasons of the source show; avoid using protected names and art (heuristic).
- Private servers for friend sparring and content creators.
- Known pain: teamers and kill stealers in FFA lobbies [2].

## Technical traps on Roblox
- Hitboxes: spatial queries (GetPartBoundsInBox, GetPartsInPart) or shapecasts (Blockcast, Spherecast, Shapecast). Blockcast misses parts already overlapping at the start [5].
- Client hitboxes feel good but mismatch between screens; common fix is a server-side query when the M1 event arrives, plus validation [6].
- Lag fairness: rewind target positions on the server for hit checks; cap the window (community practice) [7].
- Single collider avatars can route hits to a separate hitbox part (HitAndTouchDetectionMode UseHitbox) [8].
- Stun, ragdoll, knockback: client-owned characters can ignore server movement; ownership flips cause hitches (heuristic). Ragdolls conflict with custom replication libraries [9].
- Server Authority beta: prediction helps melee feel, but resimulation is CPU heavy and AnimationTrack caching breaks under rollback [10][11].
- VFX on UnreliableRemoteEvent, keep payloads under 1000 bytes [12].
- Separate low-trust devices into their own servers (docs policy for battlegrounds) [13].
- Exploit scripts recur in top titles; rate-limit ability remotes server side [2][14].

## What transfers from outside Roblox
- Smash and platform fighters: knockback, ledge play, readable silhouettes.
- Traditional fighters: frame data thinking, startup and recovery, punish windows.
- Souls-likes: parry and posture (Deepwoken) [4].
- Lesson: simplify inputs for mobile; keep depth in timing (heuristic).

## Octalysis read
- Accomplishment (CD2): kills, combo mastery.
- Empowerment of Creativity (CD3): combo routing, tech.
- Social Influence (CD5): showing off ultimates, tier list debates.
- Unpredictability (CD7): chaotic FFA lobbies.

## Sources
[1] 2026 Roblox Innovation Awards (Roblox Newsroom) - https://about.roblox.com/newsroom/2026/09/2026-roblox-innovation-awards - checked 2026-11-03
[2] The Strongest Battlegrounds: How One Punch Man Sparked Roblox's Anime Fighter Revolution (RoWatcher) - https://rowatcher.com/news/the-strongest-battlegrounds-how-one-punch-man-sparked-roblox-s-anime-fighter-revolution - checked 2026-11-03
[3] Jujutsu Shenanigans Surges Past 338K Peak Players (RoWatcher) - https://rowatcher.com/news/jujutsu-shenanigans-surges-past-338k-peak-players-after-disaster-plants-update - checked 2026-11-03
[4] Deepwoken: Inside Roblox's Most Brutal Hardcore RPG (RoWatcher) - https://rowatcher.com/news/deepwoken-inside-roblox-s-most-brutal-hardcore-rpg - checked 2026-11-03
[5] WorldRoot (Roblox Docs) - https://create.roblox.com/docs/reference/engine/classes/WorldRoot - checked 2026-11-03
[6] Combat system - hitboxes (DevForum) - https://devforum.roblox.com/t/combat-system-hitboxes/3312821 - checked 2026-11-03
[7] Am I doing hitbox replication right? (DevForum) - https://devforum.roblox.com/t/am-i-doing-hitbox-replication-right/4773807 - checked 2026-11-03
[8] AvatarSettingsHitAndTouchDetectionMode (Roblox Docs) - https://create.roblox.com/docs/reference/engine/enums/AvatarSettingsHitAndTouchDetectionMode - checked 2026-11-03
[9] Chrono custom physics replication library (DevForum) - https://devforum.roblox.com/t/chrono-drop-in-custom-physics-replication-library/3873294 - checked 2026-11-03
[10] Server Authority tech deep dive (DevForum, 2026-05-08) - https://devforum.roblox.com/t/server-authority-tech-deep-dive-engineering-insights/4624565 - checked 2026-11-03
[11] Server authority techniques (Roblox Docs) - https://create.roblox.com/docs/projects/server-authority/techniques - checked 2026-11-03
[12] UnreliableRemoteEvent (Roblox Docs) - https://create.roblox.com/docs/reference/engine/classes/UnreliableRemoteEvent - checked 2026-11-03
[13] Device trust (Roblox Docs) - https://create.roblox.com/docs/scripting/security/device-trust - checked 2026-11-03
[14] Server-side detection and consequencing (Roblox Docs) - https://create.roblox.com/docs/scripting/security/server-side-detection - checked 2026-11-03
