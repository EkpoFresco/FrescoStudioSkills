# Skill Spec: /rbx-launch
Category: growth · Source: `studio/skills/rbx-launch/SKILL.md`

## Summary
Launch checklist and go/no-go for the week before a public launch. Reuses audit reports under 7 days old (first-60 review, data-audit, remote-audit, perf phone profile) and reruns stale ones, has `discovery-strategist` draft the discovery plan, thumbnail set, and ads budget, and `community-marketer` the title, description, and update log. Fills `.rbx-studio/reports/launch-checklist.md` and returns GO or NO-GO. Publishing is the developer's action.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: live game, use /rbx-update` and `SKIPPED: build the first playable first`
- [ ] Names `launch-checklist.md`, `discovery-playbook.md`, `discovery-algorithm.md` (audience gate: 16+ until Kids and Select evaluation, 250 engaged plays in 60 days), `policy.md` (ads registration since 2026-05-04)
- [ ] Each checklist line is done, missing, or N/A with why
- [ ] Any audit BLOCKER, failed first-60 look check, or policy fail means NO-GO
- [ ] YOU DO paths: Creator Hub > Creations > <game> > Configure > Questionnaire; Studio > File > Publish to Roblox

## Fixture Defaults
Template project.yaml (`genre: tower-defense`, `place_ids: []`), unpublished game, Studio MCP connected, git repo with one commit.

## Case 1: Happy path - ready to launch
**Fixture**: `remote-audit-2026-11-01.md` (0 BLOCKER), `data-audit-2026-10-24.md` (11 days old, SAFE), `first-60` review PASS from 2026-11-02, `perf-2026-11-03.md` phone 14.9 ms.
**Expected**: 1. Read context. 2. Reuse fresh reports, rerun data-audit. 3. Fill checklist. 4. Verdict.
**Assertions**:
- [ ] Reruns only `/rbx-data-audit`; reuses the other three
- [ ] Every checklist line has a status; verdict GO
- [ ] Ads plan has a budget and stop rule and says ads buy retrieval, not ranking
- [ ] No publish executed; publish is the YOU DO step after GO

## Case 2: Relevance skip - already live
**Fixture**: Game public with 1,200 DAU and 3 published versions.
**Assertions**:
- [ ] Prints `SKIPPED: live game, use /rbx-update` and writes nothing

## Case 3: Edge - open BLOCKER in the remote audit
**Fixture**: As Case 1, but `remote-audit-2026-11-01.md` has 1 open BLOCKER: `Remotes.Trade` duplicates items.
**Assertions**:
- [ ] Verdict NO-GO with 1 open item
- [ ] Shortest path to GO names `/rbx-build fix-remotes` then a rerun of `/rbx-remote-audit`
- [ ] YOU DO does not tell the developer to publish yet

## Protocol Compliance
- [ ] Publishing, ads spend, and questionnaire stay developer actions (G3)
- [ ] YOU DO uses real Creator Hub and Studio menu paths (G4)
- [ ] Ends with a NEXT line
