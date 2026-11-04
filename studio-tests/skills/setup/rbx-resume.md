# Skill Spec: /rbx-resume
Category: setup · Source: `studio/skills/rbx-resume/SKILL.md`

## Summary
Rebuilds state after a crash, kill, or compaction. Reads `{{RBX_HOME}}/docs/survival.md`, then in order: `checkpoint.md`, `state/last-turn.txt`, `state/auto-checkpoint.md`, git since the checkpoint, and the last 5 lines of `decisions.md`. Reconciles commits and uncommitted diffs (finished, half done, broken), verifies Studio-only work via MCP, prints a 5-line state and next 3, updates checkpoint.md, then continues step 1 (`--plan-only` stops after the plan).

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: nothing to resume` when no checkpoint.md and no `state/`, and suggests `/rbx-pickup`
- [ ] Read order is fixed and nothing else is read before reconcile
- [ ] Diff inspection limited to 80 lines per changed file
- [ ] Studio-only work verified with `script_read` / `search_game_tree`, else marked NOT VERIFIED
- [ ] Code wins over a stale in-progress item, with a drift note

## Fixture Defaults
Template project.yaml (`rigor: minimal`, `toolchain: mcp`, `team_size: 1`), Studio MCP connected, git repo on `feat/quests`.

## Case 1: Happy path - crash after unrecorded work
**Fixture**: checkpoint.md at 14:10, Next step 1 `/rbx-build S-05`. `state/last-turn.txt` at 14:42 lists `src/server/Quests/QuestService.luau`. One commit after the checkpoint: `feat(quests): add quest table (S-04)`. QuestService has an uncommitted, half-finished `CompleteQuest` function.
**Expected**: 1. Read in order. 2. Mark S-04 done from the commit. 3. Classify QuestService half done. 4. Print state and next 3, update checkpoint.md. 5. Finish `CompleteQuest` before starting S-05.
**Assertions**:
- [ ] DONE reads "reconciled: 1 done, 1 in progress, 0 drift notes"
- [ ] checkpoint.md Updated time, Done, and In progress change
- [ ] Half-done work continues before `/rbx-build S-05`; a new checkpoint follows completion

## Case 2: Relevance skip - nothing to resume
**Fixture**: `.rbx-studio/` exists with project.yaml only; no checkpoint.md, no `state/`.
**Assertions**:
- [ ] Prints `SKIPPED: nothing to resume`, suggests `/rbx-pickup`, writes nothing

## Case 3: Edge - no Studio MCP with --plan-only
**Fixture**: No MCP tools. checkpoint.md lists Studio-only edits to `Workspace.Map.SpawnArea` and `ServerScriptService.RoundManager`. Run `/rbx-resume --plan-only`.
**Assertions**:
- [ ] Both DataModel paths marked NOT VERIFIED, not assumed done
- [ ] Prints at most 5 state lines plus next 3, updates checkpoint.md, then stops
- [ ] No game code edited and no skill from Next started

## Protocol Compliance
- [ ] Writes only `.rbx-studio/` plus the game code the resumed step names (S1)
- [ ] Local commits only for finished work; never pushes
- [ ] Ends with NEXT naming the step after the current one
