# Genre: Roleplay / Life Sim
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - Roblox's longest-lived top games are here. "Life" and "Pet Care" are official Roleplay subgenres [1]. Watch 2025-2026 safety rules on private spaces.
Top Roblox references (mechanics only):
- Brookhaven RP: an open town with houses and vehicles and no objective. Peaked at about 800K CCU. Acquired by Voldex Feb 2025 [2]. 329.6K CCU on 2026-09-30 [3].
- Welcome to Bloxburg: jobs earn money for building houses and buying cars. Sims-like. Went free-to-play June 15, 2024 [2].
- Adopt Me!: started as family roleplay, now pet raising and trading. About 40 staff, reportedly about $60M per year [4].
- Dress to Impress: themed dress-up rounds rated 1-5 stars. Over 250K DAU in 2024 [2].

## Core loop
- Pick a role or job, customize your avatar, house, or vehicle, act out scenes with others, earn cosmetics or money, show them off.
- The players provide the content. The designer's job is props, spaces, and roles that seed stories (heuristic).
- Life sims (Bloxburg style) add a light economy: job loops pay for building.

## Session one
- 0:00-0:30: role or avatar picker, kept short. Spawn into a busy public space (heuristic).
- 1-3 min: a free house or vehicle claim. Ownership comes immediately.
- 3-10 min: discover interactables such as phones, jobs, and vehicles. NPC or UI prompts suggest scenes ("start a family", "open a shop").
- 10-30 min: join someone's scene. Social proof is the onboarding.
- Exit: house saved, and a friend-follow prompt.

## Retention hooks (D1 / D7 / D30)
- Roleplay has the flattest decay curve of any genre and the highest session frequency, per third-party trackers (UNVERIFIED) [5].
- One vendor report claims D1/D7/D30 of 32/18/9% and 48-minute average sessions for the genre (UNVERIFIED, modeled) [6].
- D1: friends met, house started. D7: weekly content drops (Brookhaven reportedly updates weekly) [3]. D30: house builds and friend groups.

## Monetization norms
- Passes: premium houses, vehicles, VIP areas, roleplay tools (fire, police kits), extra plot space (heuristic, Brookhaven-style).
- Cosmetics and dev products: outfits, furniture, limited seasonal sets.
- Vendor estimate: roleplay games earn less per CCU than simulators, but retain longer (UNVERIFIED) [6].
- Paid-access models faded. Bloxburg dropped its 25 R$ entry fee [2].
- Subscriptions fit the genre (monthly furniture drops, VIP) [7].

## Social and discovery levers
- Under-16 reach now needs Roblox Kids/Select eligibility. Creators must be ID-verified, use 2-step verification, and keep an active Roblox Plus subscription. Games must pass a 3-step selection process [8].
- Social hangouts are excluded by default from Kids and Select catalogs. Keep the game framed as structured roleplay, not hangout (exact classification line UNVERIFIED) [8].
- Hangouts depicting private spaces (bedrooms, bathrooms) or adult venues (bars, clubs) are limited to ID-verified 17+ users (Aug 2025) [9]. Life sims with houses should check their maturity questionnaire answers.
- Chat is age-banded (6 groups, adjacent-group chat only) since Jan 2026. Mixed-age scenes rely on emotes and props more than text [10].
- Live events (Dress to Impress artist collabs) and creator videos drive spikes [2].

## Technical traps on Roblox
- Big open towns cost memory on mobile. Use StreamingEnabled, keep house interiors streamed on demand, and keep part budgets (heuristic).
- Vehicles: physics network ownership creates fling exploits. Rate-limit velocity and despawn abandoned vehicles (heuristic).
- Player-built houses: serialize as compact item IDs and transforms. Stay under the 4 MB per key [11].
- Moderation surface: free text on signs or names must go through TextService filtering. Free-form drawing restricts audience [12].
- Server takedowns: Roblox auto-closes servers with high violative behavior volume, so moderation tooling matters [9].

## What transfers from outside Roblox
- The Sims: aspiration via house building and needs systems [2].
- Club Penguin and Habbo: room ownership plus events. Their history also warns about safety (heuristic).
- Animal Crossing: daily small chores and seasonal items (heuristic).

## Octalysis read
- CD3 Creativity: stories, outfits, house builds.
- CD5 Social Influence and Relatedness: the dominant drive.
- CD4 Ownership: houses, vehicles, pets.
- CD1 Epic Meaning is light. Role identity (cop, parent) gives a small dose.

## Sources
[1] Roblox Creator Hub, Experience genres - https://create.roblox.com/docs/production/publishing/experience-genres - checked 2026-11-03
[2] Wikipedia, List of Roblox games (redirect target) - https://en.wikipedia.org/wiki/Tower_of_Hell - checked 2026-11-03
[3] StudioKrew, Top Roblox games September 2026 - https://studiokrew.com/blog/top-roblox-games-september-2026/ - checked 2026-11-03
[4] Wikipedia, Adopt Me! - https://en.wikipedia.org/wiki/Adopt_Me! - checked 2026-11-03
[5] RoWatcher, Roblox Retention by Genre (third-party) - https://rowatcher.com/news/roblox-retention-by-genre-which-games-keep-players-longest - checked 2026-11-03
[6] ROLearn, Roleplay vs Simulator 2026 (vendor, modeled) - https://rolearn.dev/trend-reports/roleplay-vs-simulator-genre-comparison-2026 - checked 2026-11-03
[7] Roblox Creator Hub, Subscriptions - https://create.roblox.com/docs/production/monetization/subscriptions - checked 2026-11-03
[8] Roblox Newsroom, Introducing Roblox Kids and Select accounts (2026-04-13) - https://about.roblox.com/newsroom/2026/04/introducing-roblox-kids-and-select-accounts - checked 2026-11-03
[9] Roblox Newsroom, Extending policy on romantic and sexual content (2025-08-15) - https://about.roblox.com/newsroom/2025/08/extending-roblox-policy-on-romantic-and-sexual-content - checked 2026-11-03
[10] Roblox Newsroom, Age checks required to chat (2026-01-07) - https://about.roblox.com/newsroom/2026/01/roblox-age-checks-required-to-chat - checked 2026-11-03
[11] Roblox Creator Hub, Data store limits - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits - checked 2026-11-03
[12] TechCrunch, Roblox bans under-13s from social spaces (2024-11-07) - https://techcrunch.com/2024/11/07/roblox-adds-new-safety-measures-to-ban-kids-under-13-from-social-spaces - checked 2026-11-03
