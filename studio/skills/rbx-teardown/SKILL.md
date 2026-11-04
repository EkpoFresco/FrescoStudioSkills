---
name: rbx-teardown
description: "Roblox: tear down a competitor's loop, UX, monetization, and discovery from public data."
argument-hint: "<game name | place id | URL>"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, WebSearch, WebFetch, Agent
disable-model-invocation: true
---

# /rbx-teardown

## 0. Relevance check
No game named: `SKIPPED: name a game, place id, or URL`.

## 1. Context
`{{RBX_HOME}}/library/roblox/market-data.md` (tools, what each sees, record source + timestamp, never mix sources in one trend line), the genre file for the game's genre.

## 2. Gather (parallel)
- `discovery-strategist`: public page (description, update date, visits, favorites, likes), CCU now and trend (CCUCheck or RobloxGameStats API, Rotrends chart history, RoWatcher), thumbnails and icon, update cadence vs CCU spikes. If a site blocks you, ask the developer to paste the numbers.
- `genre-designer`: core loop, session one minute by minute (from the developer's notes, a video the developer links, or public breakdowns), retention hooks.
- `monetization-designer`: passes and products with Robux prices (public store page), placement, policy observations.
Each returns max 15 lines with sources.

## 3. Synthesize
`.rbx-studio/reports/teardown-<game>.md`: loop, first session, UX notes (mobile layout, onboarding), monetization table, discovery read, what to take (mechanics), what to avoid, and one gap this game leaves open. Every number has source and timestamp. Third-party revenue numbers are labeled as models.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- teardown: .rbx-studio/reports/teardown-<game>.md
- take: <mechanic> · avoid: <thing> · gap: <one line>
YOU DO
1. <exact step, e.g. paste their Creator Store page numbers if blocked>
NEXT
- /rbx-concept with the gap
```
