---
name: rbx-issues
description: "Roblox: read open GitHub issues with gh, triage them (severity, player impact, effort), map them to stories in .rbx-studio/backlog.md, draft bug reports, and link fixes back. Any write to GitHub (create, label, comment, close) waits for approval. Use for team work, bug reports, or 'what should we fix'."
argument-hint: "[triage | draft <bug> | link <issue> <commit>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Agent
---

# /rbx-issues

## 0. Relevance check
`gh auth status` fails or no `team.github_repo` and no git remote on GitHub: `SKIPPED: no GitHub repo`, and offer to keep bugs in `.rbx-studio/backlog.md` only.

## 1. Read
`gh issue list --repo <repo> --state open --limit 50 --json number,title,labels,assignees,updatedAt,body`. Read `.rbx-studio/backlog.md` and recent commits (`git log --oneline -30`) to find issues already fixed (`#N` in messages).

## 2. Triage (team-coordinator)
Rules: `{{RBX_HOME}}/docs/team.md` (issues = stories, outward-facing writes).
Per issue: type (bug, feature, chore), severity for bugs (BLOCKER data/money/crash, MAJOR, MINOR), player impact, size S/M/L, suggested owner agent. Duplicates and stale issues flagged.

## 3. Map
Add or update backlog rows with the issue number. Bugs with clear repro become stories with acceptance lines.

## 4. Drafts (no GitHub writes yet)
- `draft <bug>`: issue body with repro steps, expected, actual, evidence paths, device.
- Labels, comments, closes for fixed issues (`Fixed in <hash>`).
Show the exact `gh` commands. Run them only after the developer approves in their own words in this session; GitHub writes are outward-facing.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- <n> open issues triaged: BLOCKER <n>, MAJOR <n>; <n> mapped to backlog; <n> look fixed
YOU DO
1. say "approved, update issues" to run the <n> drafted gh commands
RISKS
- <only if real>
NEXT
- /rbx-build <top issue story>
```
