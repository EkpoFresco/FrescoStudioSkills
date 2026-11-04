# Skill Spec: /rbx-update
Category: growth · Source: `studio/skills/rbx-update/SKILL.md`

## Summary
Ships an update to a live game safely. Lists and classifies changes since the last update log, runs safety in parallel (schema migration via `/rbx-data-audit migration`, monetization policy check, `/rbx-playtest --smoke`), has `liveops-designer` write the rollout plan with a recorded rollback version, and `community-marketer` fill `update-log.md` into `.rbx-studio/reports/update-log-<date>.md`. Publishing, restarting servers, and posting the log wait for the developer's go.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: not live, use /rbx-launch` and `SKIPPED: nothing to ship`
- [ ] Change classes: content, balance, data schema, monetization, fix
- [ ] Any BLOCKER from safety stops the update
- [ ] Rollback is the previous place version number, written down before publishing
- [ ] YOU DO: Version History path, Studio > File > Publish to Roblox, Restart Servers

## Fixture Defaults
Template project.yaml (`universe_id: "5123456789"`, `place_ids: [1234567890]`), live game, last report `update-log-2026-10-20.md`, Studio MCP connected, git repo.

## Case 1: Happy path - update with a schema change
**Fixture**: 5 commits since 2026-10-20: 2 content (new map, new pet), 1 balance, 1 adds `Pets.Shiny` to the profile schema, 1 fix.
**Expected**: 1. Classify. 2. Migration plan, smoke test. 3. Rollout plan. 4. Update log. 5. Wait for approval.
**Assertions**:
- [ ] Migration has a dry run on a copied prefix and a rollback
- [ ] Smoke result reported; rollout timed before the weekend peak
- [ ] Update log leads with the best change in short, young-reading-level lines
- [ ] No publish, server restart, or log post executed

## Case 2: Relevance skip - nothing to ship
**Fixture**: No commits, no `done` backlog rows, and no Studio-only edits since `update-log-2026-10-20.md`.
**Assertions**:
- [ ] Prints `SKIPPED: nothing to ship` and writes nothing

## Case 3: Edge - hotfix
**Fixture**: `/rbx-update --hotfix "coins reset on rejoin"`; bug in `src/server/Data/init.luau` save on `PlayerRemoving`.
**Assertions**:
- [ ] Plan is the smallest change, smoke test, publish, verify, one-line note
- [ ] No unrelated changes bundled
- [ ] Publish still waits for the developer's approval

## Protocol Compliance
- [ ] Publishing, restarts, and posts gated on approval (G3)
- [ ] YOU DO uses exact Creator Hub paths (G4)
- [ ] Ends with NEXT `/rbx-metrics in 48 h`
