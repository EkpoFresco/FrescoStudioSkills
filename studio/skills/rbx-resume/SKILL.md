---
name: rbx-resume
description: "Roblox: resume after a crash, kill, compaction, or new session: rebuilds state from .rbx-studio/checkpoint.md, the last-turn stamp, the auto checkpoint, and git, reconciles anything done after the checkpoint, then continues the next step. Use first thing in a fresh session on unfinished work."
argument-hint: "[--plan-only]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Agent
---

# /rbx-resume

## 0. Relevance check
No `.rbx-studio/checkpoint.md` and no `.rbx-studio/state/`: `SKIPPED: nothing to resume`, suggest `/rbx-pickup`.

## 1. Read (in this order, nothing else yet)
1. `.rbx-studio/checkpoint.md` (goal, in progress, next 3, open decisions).
2. `.rbx-studio/state/last-turn.txt`: if newer than the checkpoint, its changed files are unrecorded work.
3. `.rbx-studio/state/auto-checkpoint.md` (written before compaction).
4. `git log --oneline --since="<checkpoint time>"` and `git status --short`.
5. `.rbx-studio/decisions.md` last 5 lines.

## 2. Reconcile
- Commits after the checkpoint: mark matching items done.
- Uncommitted changes: inspect each changed file's diff (`git diff <file>`, limit 80 lines each). Decide: finished (commit locally), half done (continue it first), broken (fix or revert with a logged reason).
- Studio-only work listed in the checkpoint: verify with `script_read` / `search_game_tree` when MCP is available; else mark NOT VERIFIED.
- If the in-progress item no longer matches the code, trust the code and note the drift.

## 3. Plan
Print the reconciled state in 5 lines max and the next 3 steps. Update `checkpoint.md` (Updated time, Done, In progress). `--plan-only`: stop here.

## 4. Continue
Start step 1 of Next immediately (use the skill it names, e.g. `/rbx-build S-04`). Checkpoint again after it completes.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- resumed from checkpoint <time>; reconciled: <n> done, <n> in progress, <n> drift notes
- continuing: <step>
YOU DO
1. nothing unless a decision below needs you
RISKS
- <only if real>
NEXT
- <step after the current one>
```
