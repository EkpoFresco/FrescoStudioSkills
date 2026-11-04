# Skill Spec: /rbx-first-60
Category: design · Source: `studio/skills/rbx-first-60/SKILL.md`

## Summary
Designs or reviews the first 60 seconds of play. Design mode has `ux-mobile-designer` and `retention-designer` fill `first-60.md` into `.rbx-studio/reports/first-60.md`. Review mode has `qa-playtester` launch the game via Studio MCP from a fresh-player state, capture at 0, 5, 20, 40, 60 s on desktop and landscape phone per `look-check.md`, then `ux-mobile-designer` judges PASS/FAIL per rubric line. Gaps are ranked by bounce risk and handed off, not fixed here.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: no first minute to design` for pure backend or library work; `review` without a playable build switches to `design`
- [ ] Names `ux-standards.md` (First 60 seconds + Look check rubric), `genres/<genre>.md` (Session one), `discovery-algorithm.md`
- [ ] Heuristic targets: control by 5 s, reward by 20 s, goal by 30 s, upgrade by 60 s; max 4 words of text per beat
- [ ] Evidence under `.rbx-studio/evidence/first-60/`; verdict PASS or FAIL
- [ ] Report uses DONE / YOU DO / RISKS / NEXT

## Fixture Defaults
Template project.yaml (`rigor: minimal`, `toolchain: mcp`, `genre: obby`), Studio MCP connected, git repo with one commit.

## Case 1: Happy path - review a playable obby
**Fixture**: `StarterGui.IntroGui` shows 3 text panels (about 40 words) before spawn; player gains control at 12 s; first checkpoint reward at 34 s.
**Expected**: 1. Reset test player data. 2. Play, capture 5 times on 2 devices. 3. Note actual beat times, read console. 4. Judge per rubric line. 5. Rank fixes.
**Assertions**:
- [ ] DONE reads "first-60: FAIL, control at 12 s, first reward at 34 s" with measured values
- [ ] 10 captures saved (5 times x desktop and phone)
- [ ] Top fix is cutting or shrinking IntroGui (delays control), ranked above any polish item
- [ ] Fix handed to `client-ui-programmer`; IntroGui not edited by this skill; NEXT `/rbx-build <top fix>`

## Case 2: Relevance skip - backend library
**Fixture**: Repo is a DataStore wrapper: `src/shared/SafeStore.luau` and tests only; no StarterGui, no concept brief.
**Assertions**:
- [ ] Prints `SKIPPED: no first minute to design` and writes nothing

## Case 3: Edge - review requested with no playable build
**Fixture**: `/rbx-first-60 review`; concept brief exists; no scripts in Studio or `src/`.
**Assertions**:
- [ ] Says it is switching to `design` and attempts no play session or capture
- [ ] `.rbx-studio/reports/first-60.md` has a storyboard by second, loading plan (ReplicatedFirst, small preload), and bounce risks
- [ ] Each beat's text is 4 words or fewer

## Protocol Compliance
- [ ] Writes only `.rbx-studio/reports/` and `.rbx-studio/evidence/` (one-line fixes excepted)
- [ ] Frames bounce under 60 s and at 61-180 s as ranking signals (D2)
- [ ] Ends with NEXT `/rbx-build <top fix>`
