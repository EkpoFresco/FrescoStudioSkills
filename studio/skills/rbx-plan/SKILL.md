---
name: rbx-plan
description: "Roblox: turn the concept and loop into a milestone backlog of small stories with acceptance criteria, sizes, and a cut line. Optionally mirrors stories to GitHub issues after approval. Use after /rbx-loop, or when scope needs cutting."
argument-hint: "[milestone name | cut]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Agent
---

# /rbx-plan

## 0. Relevance check
`cut`: re-rank the existing backlog and move the cut line; skip planning. No concept or loop notes and no existing code: `SKIPPED: run /rbx-concept first`.

## 1. Context
`.rbx-studio/reports/` (concept, gdd, first-60), `.rbx-studio/backlog.md`, `.rbx-studio/project.yaml` (team_size, rigor), `{{RBX_HOME}}/templates/backlog.md` and `story.md`.

## 2. Break down
Stories are vertical and small: each one is playable or observable when done (S = under 2 h, M = half day, L = split it). Types: logic, server, data, ui, art, perf. Every story has 2-4 acceptance lines a screenshot or test can prove. Order: first playable loop, then first 60 s, then data safety, then monetization, then polish.

## 3. Cut
`roblox-director` sets the cut line: everything that does not test the hook goes below it. Log cuts in `.rbx-studio/decisions.md`.

## 4. Write
`.rbx-studio/backlog.md` (table) and one file per story only when it needs detail (`.rbx-studio/stories/S-NN.md`).
GitHub mirror (only if `team.github_repo` is set): draft the `gh issue create` commands and show them. Run them only after the developer approves in their own words; creating issues is outward-facing.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- backlog: <n> stories above the cut, <m> below (.rbx-studio/backlog.md)
- first story: S-01 <title>
YOU DO
1. say "approved, create issues" to mirror to GitHub (optional)
NEXT
- /rbx-build S-01
```
