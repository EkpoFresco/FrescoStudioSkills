---
name: rbx-ship
description: "Roblox: ship a branch only after the developer approves: final checks, push, open the PR with evidence and linked issues. Running /rbx-ship yourself counts as approval for this session; the push gate hook enforces it. Use when work is reviewed and ready to share."
argument-hint: "[branch] [--draft]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Agent
---

# /rbx-ship

## 0. Relevance check
Approval: this skill pushes. The push gate hook allows it only if the developer typed `/rbx-ship` or said "approved, push" in this session. If this skill was started by Claude without that, stop and ask: "Ready to push <branch> and open a PR. Say 'approved, push' to go." Nothing to ship (branch equals main, no commits ahead): `SKIPPED: nothing ahead of main`.

## 1. Pre-flight (no pushes yet)
- On a feature branch, not main. Branch name follows `{{RBX_HOME}}/docs/team.md`.
- `git status` clean (commit or stash leftovers with a note).
- Latest `/rbx-review` verdict for this branch is not `CHANGES REQUIRED`; if none exists, run it now through `code-optimizer`.
- UI stories have look check evidence; data or purchase changes have a data-audit line.
- Hook commit checks pass (no unguarded remotes).
Any failure: stop, report the blocker.

## 2. Ship
1. `git push -u <remote> <branch>`. No remote set (fresh fork): stop and tell the developer the exact `git remote add origin <url>` command. Never force push.
2. `gh pr create --base <main> --head <branch> --title "<type(scope): summary>" --body-file <tmp>` (add `--draft` if asked). Body: what, why, evidence (look check paths, before/after table), checks run, `Closes #N` for linked issues, the "Generated with Claude Code" line.
3. Never merge. Merging to main is a separate approval.

## 3. Record
Backlog rows to `review`. Release locks for shipped stories. Note the PR URL in `checkpoint.md`.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- pushed <branch> (<n> commits); PR: <url>
YOU DO
1. review and merge on GitHub when ready
RISKS
- <only if real>
NEXT
- /rbx-handoff
```
