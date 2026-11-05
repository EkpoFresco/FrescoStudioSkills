# Skill Spec: /rbx-try
Category: team · Source: `studio/skills/rbx-try/SKILL.md`

## Summary
Tries a teammate's branch in Studio without merging. `rbx-try.ps1` makes a detached git worktree outside the game folder, writes `try.project.json` (game project plus every `*.spec.luau` as `ReplicatedStorage.<Name>Spec`), and runs `rojo serve` in the background. Builds a what-to-check list from commit bodies and new spec cases. Never commits, merges or pushes; the working copy and its branch stay untouched.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox" and is under 300 chars
- [ ] Relevance check skips non-git, non-Rojo games and already-merged branches with `SKIPPED:`
- [ ] Serve runs in the background and waits for Rojo's listening line before saying ready
- [ ] States that merging needs the developer's approval and is outside this skill
- [ ] Report has DONE / YOU DO / RISKS / NEXT

## Fixture Defaults
Rojo game with `default.project.json`, `game/tests/WeaponCombat.spec.luau`, remote `origin` with `main` and two feature branches by a teammate.

## Case 1: Happy path
**Fixture**: Developer types `/rbx-try collision`; `origin/lab/interactions/collision-cannon-swords` is 1 ahead, 5 behind main.
**Assertions**:
- [ ] Runs `rbx-try.ps1 prep` then `serve` with run_in_background; no `git checkout` in the working copy
- [ ] Report lists the worktree path, port, `WeaponCombatSpec`, and one feel check per commit claim
- [ ] `git status` of the game folder is unchanged afterwards

## Case 2: Relevance skip
**Fixture**: `/rbx-try lab/interface`, branch fully merged into main.
**Assertions**:
- [ ] Prints `SKIPPED: lab/interface is already in main`; creates no worktree

## Case 3: Edge - saved changes in the worktree
**Fixture**: The developer saved the worktree's TestLab.rbxl; `/rbx-try collision` again.
**Assertions**:
- [ ] Tool refuses without `-Reset`; skill asks before discarding
- [ ] No merge or push command runs at any point

## Protocol Compliance
- [ ] Writes nothing in the game folder; worktrees live under `%USERPROFILE%\.rbx-try`
- [ ] Never merges or pushes (T1)
- [ ] Ends with NEXT `/rbx-try <next>` or `/rbx-ship`
