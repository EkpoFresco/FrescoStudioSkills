---
name: rbx-checkpoint
description: "Roblox: save session state so a long session can survive a crash, compaction, or usage cutoff: writes .rbx-studio/checkpoint.md (goal, phase, done, in progress, next 3, open decisions, files touched) and makes a local commit. Use after each meaningful chunk of work and before stopping."
argument-hint: "[note]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
---

# /rbx-checkpoint

## 0. Relevance check
No `.rbx-studio/`: create it with only `checkpoint.md` and `.gitignore` (`state/`); suggest `/rbx-start` later. Nothing changed since the last checkpoint (same commit, clean status, no new decisions): `SKIPPED: checkpoint is current`.

## 1. Gather (cheap, no exploration)
`git rev-parse --abbrev-ref HEAD`, `git log --oneline -5`, `git status --short`, the previous `checkpoint.md`, `.rbx-studio/backlog.md` statuses, and what this session did (from the conversation).

## 2. Write `.rbx-studio/checkpoint.md`
Use `{{RBX_HOME}}/templates/checkpoint.md`. Rules:
- In progress names the exact state: file:line or DataModel path, what is half done, what the next edit is.
- Next 3 are concrete actions a fresh session can start without asking.
- Open decisions list choices made but not yet logged; log them in `.rbx-studio/decisions.md` now.
- Studio-only edits (MCP) are not in git: list the DataModel paths changed so `/rbx-resume` can verify them with `script_read`.
- Append `$ARGUMENTS` as a note if given.

## 3. Commit
If `git.local_commits` (default true) and inside a git repo: `git add -u` (tracked changes) plus `git add .rbx-studio` (never untracked files outside it), commit `chore(checkpoint): <one line>`. Never push. Skip the commit if a hook blocks it and report why.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- checkpoint: .rbx-studio/checkpoint.md (<n> done, next: <step 1>)
- commit: <hash> | skipped (<why>)
YOU DO
1. nothing; resume any time with /rbx-resume
NEXT
- <step 1 of Next 3>
```
