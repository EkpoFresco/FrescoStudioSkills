# Skill Spec: /rbx-concept
Category: design · Source: `studio/skills/rbx-concept/SKILL.md`

## Summary
Writes a one-page concept brief: hook, pillars, first 60 seconds, discovery hypothesis and QPTR story, market check, numeric kill criteria. Reads project.yaml, `genres/README.md` plus the matching genre file, `discovery-algorithm.md` TL;DR, and `market-data.md`. Runs `genre-designer` and `discovery-strategist` in parallel, fills `concept-brief.md` into `.rbx-studio/reports/concept-<slug>.md`, and gets a GO / PIVOT / KILL call from `roblox-director` logged in `decisions.md`.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: concept exists, pass a new idea to replace it` after a 3-line summary
- [ ] Names `{{RBX_HOME}}/library/roblox/genres/README.md`, `discovery-algorithm.md`, and `market-data.md`
- [ ] Discovery hypothesis names PTR, first-play bounce, D1 / D2-7 / D8-28, co-play days
- [ ] Verdict words GO / PIVOT / KILL; kill criteria numeric and time-boxed
- [ ] Report uses DONE / YOU DO / RISKS / NEXT

## Fixture Defaults
Template project.yaml (`rigor: minimal`, `genre: ""`, `team_size: 1`, `monetization_style: light`), no `.rbx-studio/reports/concept-*.md`, web search available.

## Case 1: Happy path - new idea
**Fixture**: `/rbx-concept "hatch pets that build your tycoon for you"`.
**Expected**: 1. Read context. 2. genre-designer (take / skip / twist) and discovery-strategist (3 reference games, hypothesis) in parallel, each max 15 lines. 3. Write `.rbx-studio/reports/concept-pet-tycoon.md`. 4. Director call, logged. 5. Set `roblox.genre`.
**Assertions**:
- [ ] Each of 3 reference games has a CCU with source and timestamp
- [ ] Thumbnail promise equals a beat the first 60 seconds delivers
- [ ] Kill criteria read like "D1 under 20% after 14 days of RFY traffic: kill", not "if it flops"
- [ ] decisions.md gains the verdict; `roblox.genre` set (e.g. `tycoon`); NEXT `/rbx-loop`

## Case 2: Relevance skip - brief already exists
**Fixture**: `.rbx-studio/reports/concept-obby-rush.md` exists; run `/rbx-concept` with no argument.
**Assertions**:
- [ ] Prints a 3-line summary and `SKIPPED: concept exists, pass a new idea to replace it`; writes nothing

## Case 3: Edge - idea built on someone else's IP
**Fixture**: `/rbx-concept "Pokemon battles with the real Pokemon"`.
**Assertions**:
- [ ] Brief keeps mechanics only (capture, type advantage, team of 6); no IP names or assets in hook, pillars, or thumbnail promise
- [ ] RISKS flags the IP problem; the policy check is run or named (D4)
- [ ] Verdict is PIVOT or KILL with the reason, not GO on the original framing

## Protocol Compliance
- [ ] Writes only `.rbx-studio/reports/`, `decisions.md`, and `roblox.genre` in project.yaml
- [ ] Judges the idea by players who stay, never by CTR alone (D2)
- [ ] Ends with NEXT `/rbx-loop`
