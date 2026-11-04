# Genre: Social Deduction (murder mystery, imposter, hide and seek)
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - simple roles, short rounds, and trading economies; one tracker reports flat retention 12 to 18 months after launch for the genre [1].
Top Roblox references (mechanics only):
- Murder Mystery 2 (Nikilis, Jan 2014): 12 players, 1 Murderer, 1 Sheriff, 10 Innocents; dropped gun makes a Hero; 24.6B visits, 125K+ CCU [2].
- Flee the Facility (A.W. Apps): 1 Beast vs survivors hacking computers; 3B visits by Apr 2022 [3].
- Murderers VS Sheriffs DUELS (Red21, Feb 2023): team duel spin on the roles; 2.36B visits [4].
- Hide and Seek Extreme (Tim7775): seeker vs hiders on oversized maps [3].

## Core loop
- Lobby, map vote, secret role roll, round (hide, hunt, deduce), reveal, coins and XP, open boxes or trade, next round [2].
- Each role has a different verb; the rotation keeps rounds fresh (heuristic).
- MM2 modes: Standard, Disguises, Assassin [2].

## Session one
- 0 to 1 min: lobby with countdown; first round usually as Innocent, the easiest role (heuristic).
- 1 to 3 min: collect coins, die or survive; learn the misfire rule (Sheriff who shoots an Innocent dies and drops the gun) [5].
- 3 to 15 min: first Sheriff or Murderer roll creates the big moment (heuristic).
- First box opening with earned coins shows the knife and gun economy (heuristic).

## Retention hooks (D1 / D7 / D30)
- D1: daily quests (MM2 Christmas 2025: three per day) [2].
- D7: seasonal battle pass (25 tiers at Halloween 2025), crafting from lower rarities [2].
- D30: trading economy as the real endgame; 11 rarity tiers; event items never return [2].
- About four major events per year in MM2 [2].

## Monetization norms
- Mystery boxes with Robux keys; Godly drop rate 0.2%, Common 70% (MM2) [2].
- Passes: Elite 499 Robux (1.5x XP), Radio 475 Robux (MM2) [2].
- Seasonal bundles and battle passes [2].
- Paid random items: disclose odds and check current Roblox paid random item policy (heuristic).
- Never sell role choice in competitive play; it breaks trust (heuristic).

## Social and discovery levers
- Trading communities and fan value lists (MM2 official value list, 2.6M users) [2].
- Item scarcity as status; limit free codes to protect value [2].
- Voice chat is proximity based by default; team-only voice is supported [6].
- Has Friends and Voice Chat matchmaking signals help keep groups and voice users together [7].

## Technical traps on Roblox
- Role secrecy: assign roles on the server and send each player only their own role; exploiters read anything replicated (heuristic).
- Highlights and names leak through ESP; do not replicate the murderer's tool until equipped (heuristic).
- Ranged weapon (gun) hit reg: client raycast, server validates angle, distance, obstruction [8].
- Known pain points: teaming, camping, gun accuracy inconsistency, past dupes, account theft targeting kids [2].
- Trading: server-side two-phase trade with UpdateAsync; dupes destroy item value [9].
- Low-trust devices: docs suggest blocking trades for None trust in trade hangouts [10].

## What transfers from outside Roblox
- Among Us: tasks for crew, sabotage and meetings, voting.
- Werewolf and Mafia: night kills, day discussion.
- Prop Hunt: disguise as objects.
- Lesson: keep the core loop simple; "complexity is the enemy of longevity on Roblox" [2].

## Octalysis read
- Unpredictability (CD7): role roll every round.
- Social Influence (CD5): accusation, trading, flexing knives.
- Scarcity (CD6): limited event items.
- Ownership (CD4): inventory and trade value.

## Sources
[1] Is Battle Royale Dead on Roblox? (RoWatcher) - https://rowatcher.com/news/is-battle-royale-dead-on-roblox-the-data-says-yes - checked 2026-11-03
[2] How Nikilis Keeps Murder Mystery 2 Alive After 12 Years and 24.6 Billion Visits (RoWatcher) - https://rowatcher.com/news/how-nikilis-keeps-murder-mystery-2-alive-after-12-years-and-24-6-billion-visits - checked 2026-11-03
[3] List of Roblox games (Wikipedia) - https://en.wikipedia.org/wiki/List_of_Roblox_games - checked 2026-11-03
[4] Murderers VS Sheriffs DUELS stats (RoWatcher) - https://rowatcher.com/games/4348829796/murderers-vs-sheriffs-duels - checked 2026-11-03
[5] What Is Murder Mystery 2? (RoWatcher) - https://rowatcher.com/news/what-is-murder-mystery-2-a-guide-to-roblox-s-legendary-social-deduction-game - checked 2026-11-03
[6] Voice chat (Roblox Docs) - https://create.roblox.com/docs/chat/voice-chat - checked 2026-11-03
[7] Matchmaking attributes and signals (Roblox Docs) - https://create.roblox.com/docs/matchmaking/attributes-and-signals - checked 2026-11-03
[8] Detect hits tutorial (Roblox Docs) - https://create.roblox.com/docs/tutorials/curriculums/gameplay-scripting/detect-hits - checked 2026-11-03
[9] Best practices for data stores (Roblox Docs) - https://create.roblox.com/docs/cloud-services/data-stores/best-practices - checked 2026-11-03
[10] Device trust (Roblox Docs) - https://create.roblox.com/docs/scripting/security/device-trust - checked 2026-11-03
