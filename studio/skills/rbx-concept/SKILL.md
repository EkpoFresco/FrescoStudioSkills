---
name: rbx-concept
description: "Roblox: write a one-page game concept brief with a hook, pillars, first 60 seconds, a discovery hypothesis and QPTR story (players who stay, not clicks), market check, and kill criteria. Use for a new game idea, a pivot, or 'is this idea good'."
argument-hint: "[idea in a few words | path to notes]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, WebSearch, WebFetch, Agent
---

# /rbx-concept

## 0. Relevance check
If a brief already exists in `.rbx-studio/reports/concept-*.md` and no new idea was given, summarize it in 3 lines and stop (`SKIPPED: concept exists, pass a new idea to replace it`).

## 1. Context
`.rbx-studio/project.yaml` (genre, team_size, monetization_style). `{{RBX_HOME}}/library/roblox/genres/README.md`, then the matching genre file. `{{RBX_HOME}}/library/roblox/discovery-algorithm.md` TL;DR. `{{RBX_HOME}}/library/roblox/market-data.md` (How an agent should use this).

## 2. Shape the idea (run in parallel)
- `genre-designer`: genre fit, take / skip / twist (mechanics only, no IP).
- `discovery-strategist`: market check (3 reference games: CCU with source and timestamp, what they do in session one), and the discovery hypothesis: who clicks, why they stay past 3 minutes, which signals should move (PTR, first-play bounce, D1 / D2-7 / D8-28, co-play days).
Brief each with the idea, genre, team size, and the exact output you need (table rows, max 15 lines).

## 3. Write the brief
Fill `{{RBX_HOME}}/templates/concept-brief.md` into `.rbx-studio/reports/concept-<slug>.md`. The thumbnail promise must equal what the first 60 seconds delivers (QPTR over CTR). Kill criteria are numeric and time-boxed.

## 4. Director call
`roblox-director` reads the brief and returns go / pivot / kill-before-building plus the smallest first playable (max 5 bullets). Log the call in `.rbx-studio/decisions.md`. Set `roblox.genre` in project.yaml if empty.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- brief: .rbx-studio/reports/concept-<slug>.md (verdict: GO | PIVOT | KILL)
- hook: <one line>
YOU DO
1. <exact step>
RISKS
- <only if real>
NEXT
- /rbx-loop
```
