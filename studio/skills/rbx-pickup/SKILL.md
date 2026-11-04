---
name: rbx-pickup
description: "Roblox: tell me where things stand. Reads the latest handoff notes, checkpoint, backlog, locks, open GitHub issues, and recent commits, then gives the state in five lines and the best next move. Use at the start of a session, when joining a teammate's work, or when stuck on what to do next."
argument-hint: "[--deep]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
---

# /rbx-pickup

## 0. Relevance check
No `.rbx-studio/`: `SKIPPED: not set up`, recommend `/rbx-start`. If `checkpoint.md` shows unfinished in-progress work from this machine's last session, recommend `/rbx-resume` first.

## 1. Read (cheap first)
Conventions for branches, locks, and handoffs: `{{RBX_HOME}}/docs/team.md`.
1. Newest 2 files in the handoffs dir (`paths.handoffs`).
2. `.rbx-studio/checkpoint.md`, `.rbx-studio/backlog.md`, `.rbx-studio/locks.md`.
3. `git fetch --quiet` (read-only) then `git log --oneline -15 --all --since="7 days ago"`, `git status --short`, current branch vs main (`git rev-list --left-right --count <main>...HEAD`).
4. `gh issue list --limit 15` if GitHub is set up.
5. `--deep`: latest review, playtest, perf, and metrics reports in `.rbx-studio/reports/`.

## 2. Summarize
Five lines max: what shipped recently, what is in progress and by whom (locks), what is blocked, what the newest handoff asks for, open BLOCKER issues. Then the single highest-leverage next move and the skill that does it.

## 3. Conflicts
Flag: two locks on one module, stale locks (> 24 h), branch far behind main, a handoff that references work not in git (Studio-only edits: open the place to see them).

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- state: <5 lines max>
YOU DO
1. <smallest exact step>
RISKS
- <conflicts, only if real>
NEXT
- <skill + target>
```
