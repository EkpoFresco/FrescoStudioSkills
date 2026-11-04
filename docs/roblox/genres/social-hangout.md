# Genre: Social Hangout
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: weak (for new projects) - demand is real, but 2024-2026 safety policy cuts under-13 access, excludes hangouts from under-16 default catalogs, and gates private-space hangouts behind 17+ ID [1][2][3].
Top Roblox references (mechanics only):
- Vibe and club spaces: music, emotes, seating, and photo spots. "Social" is an official genre with no subgenres [4].
- MeepCity (historical): Club Penguin-like rooms and pets. It was placed under review in Feb 2022 over party content, and parties were removed [5]. This is the cautionary case.
- Dress to Impress: shows how to give a social crowd a structured activity (themed rounds) [5].

## Core loop
- Arrive, express yourself (avatar, emotes, voice or text if eligible), do a light activity, meet people, friend them, return to see them.
- The activity layer (minigames, karaoke, fashion rounds) keeps the game from being a pure chat room. Structured play also changes how policy classifies it (heuristic).

## Session one
- 0:00-0:30: spawn into a visibly populated area with music. Empty servers kill hangouts, so fill servers and avoid spreading players thin (heuristic).
- 1-5 min: an emote wheel, a seat, a photo booth. Give non-chatters something to do.
- 5-15 min: a scheduled micro-event (DJ set, contest, round) and a friend-request moment.
- Exit: friends added. That is the only real hook.

## Retention hooks (D1 / D7 / D30)
- D1/D7/D30 are almost entirely friend-graph driven. Intentional co-play days are a direct Home ranking signal [6].
- Scheduled events with Roblox Experience Events (opt-in notifications, up to 5 thumbnails) bring cohorts back [6].
- Cosmetic progression (titles, auras by visit streak) adds a light layer (heuristic).

## Monetization norms
- Passes: VIP rooms, emote packs, radios or music, custom name tags. Name tags must be filtered (heuristic).
- Private servers for friend groups. Roblox Plus gives subscribers free private servers, and creators earn up to 100 R$ per Plus subscriber who spends 60+ minutes in a paid private server within 30 days [7].
- Low spend per user versus progression genres (heuristic).

## Social and discovery levers (policy impact, 2024-2026)
- Nov 2024: users under 13 barred from social hangouts and free-form 2D creation experiences. Creators must complete a maturity questionnaire [1].
- Aug 2025: hangouts depicting private spaces (bedrooms, bathrooms) or adult settings (bars, clubs) limited to ID-verified 17+ users. Developers of 17+ experiences must verify age. Unrated experiences are restricted to their developers. Roblox auto-takes down servers with high violative behavior volume [2].
- Aug and Nov 2025: Restricted-label experiences hidden from under-18 search and recommendations, then blocked for under-18 users [8].
- Dec 2025 to Jan 2026: age checks required to chat worldwide. Six age bands, chat only with your own and adjacent bands. Trusted Connections apply for 13+ [9].
- Apr to Jun 2026: Roblox Kids (5-8) and Select (9-15) accounts exclude social hangouts by default. Unverified users get limited game access and no communication [3].
- Net effect: the hangout audience is now mostly 13+ age-checked users. Build for 16+ or add structured play (heuristic).

## Technical traps on Roblox
- Voice and text eligibility now varies per user. Design for the case where nobody can chat: emotes, pings, quick chat [9].
- Any user-generated text (signs, bios, names) goes through TextService filtering. Free drawing is audience-restricted [1].
- Crowds of 50+ detailed avatars tank mobile frame rate. Use avatar LOD and impostors, and keep server sizes moderate (heuristic).
- Moderation tooling (report flow, server logs) reduces takedown risk [2].

## What transfers from outside Roblox
- VRChat and Rec Room: events and creator-hosted programming beat static rooms (heuristic).
- Club Penguin: room themes plus party calendars (heuristic).
- Discord-style "third place" design: regulars and rituals (heuristic).

## Octalysis read
- CD5 Social Influence and Relatedness: the whole genre.
- CD3 Creativity: self-expression through avatar and emotes.
- CD4 Ownership: VIP spaces and tags (light).
- Weak CD2. Add structured goals to compensate.

## Sources
[1] TechCrunch, Roblox bans under-13s from social spaces (2024-11-07) - https://techcrunch.com/2024/11/07/roblox-adds-new-safety-measures-to-ban-kids-under-13-from-social-spaces - checked 2026-11-03
[2] Roblox Newsroom, Extending policy on romantic and sexual content (2025-08-15) - https://about.roblox.com/newsroom/2025/08/extending-roblox-policy-on-romantic-and-sexual-content - checked 2026-11-03
[3] Roblox Newsroom, Introducing Roblox Kids and Select accounts (2026-04-13) - https://about.roblox.com/newsroom/2026/04/introducing-roblox-kids-and-select-accounts - checked 2026-11-03
[4] Roblox Creator Hub, Experience genres - https://create.roblox.com/docs/production/publishing/experience-genres - checked 2026-11-03
[5] Wikipedia, List of Roblox games (redirect target) - https://en.wikipedia.org/wiki/Tower_of_Hell - checked 2026-11-03
[6] Roblox Creator Hub, Discovery - https://create.roblox.com/docs/discovery - checked 2026-11-03
[7] Roblox Newsroom, Introducing Roblox Plus (2026-04) - https://about.roblox.com/newsroom/2026/04/introducing-roblox-plus-subscription - checked 2026-11-03
[8] DevForum, Updating age requirements for Restricted label (2025-08-28, updated 2025-11-06) - https://devforum.roblox.com/t/updating-age-requirements-for-experiences-with-%E2%80%98restricted%E2%80%99-content-maturity-label/3905863 - checked 2026-11-03
[9] Roblox Newsroom, Age checks required to chat (2026-01-07) - https://about.roblox.com/newsroom/2026/01/roblox-age-checks-required-to-chat - checked 2026-11-03
