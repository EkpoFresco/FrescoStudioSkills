# Survival: long sessions that cannot lose work

## Files
- `.rbx-studio/checkpoint.md`: written by `/rbx-checkpoint`. Phase, done, in progress, next 3, open decisions, files touched.
- `.rbx-studio/state/last-turn.txt`: Stop hook, every turn: time, branch, changed files.
- `.rbx-studio/state/auto-checkpoint.md`: PreCompact hook: branch, status, last commits.
- Git: local commits after each meaningful chunk (`git.local_commits: true`).

## Rules
1. After each completed task: update the checkpoint (one line per item is enough) and commit locally.
2. A fresh session must resume from `checkpoint.md` alone with `/rbx-resume`.
3. Before a likely cutoff or compaction: checkpoint and commit first, then continue.
4. Efficiency mode at about 1/4 context or usage left: stop broad exploration; read sections (Grep for `^#`, then Read with offset and limit), not whole files; write research to files instead of holding it; delegate bulky reads to a subagent that returns 10 lines; finish the current item cleanly before starting new work.

## Resume order (/rbx-resume)
`checkpoint.md`, then `state/last-turn.txt` (anything newer than the checkpoint is unrecorded work), then `state/auto-checkpoint.md`, then `git log --oneline` since the checkpoint time, then `git status`. Reconcile, print the plan, continue with step 1 of "Next".
