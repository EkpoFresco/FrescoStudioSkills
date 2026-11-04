# Skill Spec: /rbx-teardown
Category: growth · Source: `studio/skills/rbx-teardown/SKILL.md`

## Summary
Tears down a competitor or reference game from public data and third-party trackers. Reads `market-data.md` and the genre file, runs `discovery-strategist` (page stats, CCU now and trend, thumbnails, update cadence), `genre-designer` (loop, session one, hooks), and `monetization-designer` (passes and products with Robux prices) in parallel, each max 15 lines with sources. Writes `.rbx-studio/reports/teardown-<game>.md`. Mechanics only, no IP.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: name a game, place id, or URL`
- [ ] Names `market-data.md` rules: source + timestamp on every number, never mix sources in one trend line
- [ ] CCU sources named: CCUCheck or RobloxGameStats API, Rotrends chart history, RoWatcher
- [ ] Report sections: loop, first session, UX notes, monetization table, discovery read, take, avoid, one gap
- [ ] Third-party revenue numbers labeled as models

## Fixture Defaults
Template project.yaml (`genre: pet-collection-trading`), web search and fetch available, no Studio MCP needed.

## Case 1: Happy path - named rival
**Fixture**: `/rbx-teardown "Pet Simulator 99"`; public page and trackers reachable.
**Expected**: 1. Read context. 2. Three agents in parallel. 3. Synthesize the report.
**Assertions**:
- [ ] Every number (visits, favorites, CCU, prices) has a source and timestamp
- [ ] Monetization table lists passes and products with Robux prices from the public store page
- [ ] Take list is mechanics, not names, art, or assets
- [ ] DONE has take, avoid, and gap; NEXT `/rbx-concept with the gap`

## Case 2: Relevance skip - no game named
**Fixture**: `/rbx-teardown` with no argument.
**Assertions**:
- [ ] Prints `SKIPPED: name a game, place id, or URL` and writes nothing

## Case 3: Edge - tracker blocks the fetch
**Fixture**: Rotrends returns 403; CCUCheck works for current CCU only.
**Assertions**:
- [ ] No CCU history invented; the trend line is marked missing
- [ ] CCUCheck current value is not stitched into another source's trend line
- [ ] YOU DO asks the developer to paste the blocked numbers

## Protocol Compliance
- [ ] Writes only `.rbx-studio/reports/teardown-<game>.md`
- [ ] Models labeled as models (G1); no posting or outreach to the rival
- [ ] Ends with NEXT `/rbx-concept`
