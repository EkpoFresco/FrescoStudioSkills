# Skill Spec: /rbx-genre
Category: design · Source: `studio/skills/rbx-genre/SKILL.md`

## Summary
Pulls genre patterns for the current game from the 32-file genre library. Genre comes from `$ARGUMENTS` or `roblox.genre`. Reads the genre file(s) in `{{RBX_HOME}}/library/roblox/genres/` and the concept brief, delegates to `genre-designer` for take, skip, one twist, session-one timeline, top 3 Roblox technical traps with owners, and monetization norms that fit `roblox.monetization_style`. Saves `.rbx-studio/reports/genre-<genre>.md` (max 60 lines).

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check lists the closest 3 from `genres/README.md` with their Roblox fit and prints `SKIPPED: pick a genre`
- [ ] Output path `.rbx-studio/reports/genre-<genre>.md`, max 60 lines
- [ ] Keeps UNVERIFIED tags from the library
- [ ] Each technical trap names its owning agent
- [ ] Report uses DONE / YOU DO / NEXT with "take: 3 · skip: 2 · twist: 1"

## Fixture Defaults
Template project.yaml (`rigor: minimal`, `team_size: 1`, `monetization_style: light`), Studio MCP connected, git repo with one commit.

## Case 1: Happy path - genre from project.yaml
**Fixture**: `roblox.genre: tower-defense`; `.rbx-studio/reports/concept-tower-rush.md` with hook "towers you build with friends merge into bigger towers".
**Expected**: 1. Read `genres/tower-defense.md` and the brief. 2. genre-designer adapts. 3. Save `genre-tower-defense.md`.
**Assertions**:
- [ ] Reads `tower-defense.md` and no unrelated genre file
- [ ] DONE lists 3 take items, 2 skip items with why, 1 twist tied to the merge hook
- [ ] Session-one timeline is adapted to tower merging, not copied
- [ ] Monetization norms fit `light` (no heavy gacha ladders); any UNVERIFIED tag kept

## Case 2: Relevance skip - no genre anywhere
**Fixture**: `roblox.genre: ""`, no argument, concept brief hook "hatch and trade pets".
**Assertions**:
- [ ] Lists 3 genres from README (e.g. pet-collection-trading, simulator, idle-clicker) with Roblox fit
- [ ] Prints `SKIPPED: pick a genre` and writes nothing

## Case 3: Edge - genre blend
**Fixture**: `/rbx-genre simulator+pet-collection-trading`.
**Assertions**:
- [ ] Reads both `simulator.md` and `pet-collection-trading.md`
- [ ] Writes one notes file under 60 lines, not two
- [ ] Twist and traps account for both genres (e.g. trading dupes owned by `data-engineer`)

## Protocol Compliance
- [ ] Writes only `.rbx-studio/reports/genre-*.md`
- [ ] Mechanics only; no IP copied from reference games
- [ ] Ends with NEXT `/rbx-loop`
