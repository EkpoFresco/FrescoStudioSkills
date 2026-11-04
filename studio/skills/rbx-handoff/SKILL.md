---
name: rbx-handoff
description: "Roblox: write a teammate handoff note and release locks."
argument-hint: "[to <name>] [topic]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
disable-model-invocation: true
---

# /rbx-handoff

## 0. Relevance check
No changes since the last handoff (no commits, clean status, no backlog movement): `SKIPPED: nothing new to hand off`.

## 1. Gather
`git log --oneline` since the last handoff file's time (or last 15), `git status --short`, current branch, `.rbx-studio/backlog.md` rows that moved, `.rbx-studio/checkpoint.md`, `.rbx-studio/locks.md` rows owned by you, Studio-only edits listed in the checkpoint, and latest reports (review, playtest).

## 2. Write
`<paths.handoffs>/YYYY-MM-DD-<initials>-<topic>.md` from `{{RBX_HOME}}/templates/handoff-note.md` (default dir `.rbx-studio/handoffs/`). Style: lead with where it stands; one line per change with the path; "Start here" is numbered and starts with the smallest step; only real risks. Studio-only changes (not in git) are called out explicitly so the teammate knows to open the place.

## 3. Locks and commit
Release your lock rows for finished work; keep rows for work in progress and say so in the note. Local commit `docs(handoff): <topic>`. Pushing it is the developer's call (`/rbx-ship`).

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- handoff: .rbx-studio/handoffs/<file> (<n> changes, <n> open)
- locks released: <n>
YOU DO
1. say "approved, push" so the teammate can pull it (or send them the file)
NEXT
- teammate runs /rbx-pickup
```
