# Skill Spec: /rbx-plan
Category: design · Source: `studio/skills/rbx-plan/SKILL.md`

## Summary
Turns concept, gdd, and first-60 notes into a milestone backlog of small vertical stories with 2-4 acceptance lines, sizes, and a cut line set by `roblox-director`. Writes `.rbx-studio/backlog.md` and `.rbx-studio/stories/S-NN.md` only when a story needs detail. With `team.github_repo` set, drafts `gh issue create` commands and runs them only after approval. `cut` re-ranks and moves the cut line.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: run /rbx-concept first` with no concept, no loop notes, and no code
- [ ] Sizes S under 2 h, M half day, L split; types logic, server, data, ui, art, perf
- [ ] Order: first playable loop, first 60 s, data safety, monetization, polish
- [ ] Cuts logged in `.rbx-studio/decisions.md`
- [ ] YOU DO offers "approved, create issues"; issues are outward-facing

## Fixture Defaults
Template project.yaml (`rigor: minimal`, `team_size: 1`, `team.github_repo: ""`), git repo with one commit.

## Case 1: Happy path - first milestone
**Fixture**: `.rbx-studio/reports/` has `concept-tower-rush.md`, `gdd.md`, `first-60.md`; `backlog.md` empty.
**Expected**: 1. Read context. 2. Break into stories. 3. Director sets the cut. 4. Write backlog.md.
**Assertions**:
- [ ] No story sized L; every story has 2-4 acceptance lines a screenshot or test can prove
- [ ] S-01 is the first playable loop (place a tower, a wave spawns, an enemy dies)
- [ ] Nothing above the cut fails to test the hook; cuts appear in decisions.md
- [ ] DONE states counts above and below the cut; NEXT `/rbx-build S-01`

## Case 2: Relevance skip - nothing to plan from
**Fixture**: `.rbx-studio/` has project.yaml only; no reports; no `src/` and no Studio scripts.
**Assertions**:
- [ ] Prints `SKIPPED: run /rbx-concept first` and writes nothing

## Case 3: Edge - GitHub mirror needs approval
**Fixture**: `team.github_repo: studio-kit/tower-rush`, `team_size: 3`; developer has not said "approved, create issues".
**Assertions**:
- [ ] Shows one `gh issue create --repo studio-kit/tower-rush` command per story above the cut
- [ ] Runs none of them in this session
- [ ] backlog.md is still written locally

## Protocol Compliance
- [ ] Writes only `.rbx-studio/` (backlog.md, stories/, decisions.md)
- [ ] No GitHub write without the developer's own approval words
- [ ] Ends with NEXT `/rbx-build S-01`
