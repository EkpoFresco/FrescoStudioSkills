# Skill Spec: /rbx-loop
Category: design · Source: `studio/skills/rbx-loop/SKILL.md`

## Summary
Designs the core loop, session plan, D1/D7/D30 hooks, and progression or economy curves. `retention-designer` writes the loop and sessions; curves go into `.rbx-studio/reports/curve.luau` and run with `lune run` when Lune is installed. Outputs time-to-unlock for the first 10 milestones and first-hour currency, flags bad steps, and fills the loop sections of `gdd-short.md` into `.rbx-studio/reports/gdd.md`.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: no progression to model` for `curve` on a pure party or social game; `review` without numbers or a build runs `design`
- [ ] Names `genres/<genre>.md` (Core loop, Retention hooks) and `discovery-algorithm.md` (play days, co-play days, D1, D2-7, D8-28)
- [ ] Flags any step more than 2x the previous one and any early milestone under 10 s or over 30 min
- [ ] Each hook window (D1, D7, D30) names the metric that judges it
- [ ] Octalysis or flow lenses only when they fit; says when skipped

## Fixture Defaults
Template project.yaml (`rigor: minimal`, `genre: simulator`), concept brief and genre notes in `.rbx-studio/reports/`, Lune installed.

## Case 1: Happy path - simulator upgrade curve
**Fixture**: Brief defines upgrade cost `25 * 3^n` coins and income `1 + n` coins/s at level n; time per unlock = cost / income.
**Expected**: 1. Loop and sessions. 2. Write and run `curve.luau`. 3. Flag steps. 4. Update gdd.md loop sections.
**Assertions**:
- [ ] First unlocks read 25 s, 37.5 s, 75 s, 168.75 s (milestones 1-4)
- [ ] Milestone 4 flagged (2.25x the previous step); milestone 7 (about 43 min) flagged as over 30 min early
- [ ] DONE shows "flags: <n>" with n at least 2, plus first-hour currency
- [ ] gdd.md changes only its loop sections; NEXT `/rbx-first-60 design` or `/rbx-plan`

## Case 2: Relevance skip - curve on a social hangout
**Fixture**: `roblox.genre: social-hangout`, no currency or levels; run `/rbx-loop curve`.
**Assertions**:
- [ ] Prints `SKIPPED: no progression to model` and writes nothing

## Case 3: Edge - Lune not installed
**Fixture**: Same as Case 1; `lune --version` fails.
**Assertions**:
- [ ] Still writes `.rbx-studio/reports/curve.luau` with the formulas
- [ ] Computes the 10 milestones in a table with the same numbers as Case 1 and says Lune was missing
- [ ] Does not install Lune itself

## Protocol Compliance
- [ ] Writes only `.rbx-studio/reports/` (gdd.md, curve.luau)
- [ ] Targets and curves are numbers tied to a metric (D5)
- [ ] Ends with a NEXT line
