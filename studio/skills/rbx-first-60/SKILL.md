---
name: rbx-first-60
description: "Roblox: design or review the first 60 seconds (time to fun, bounce risk); review mode plays via Studio MCP and screenshots phone + desktop."
argument-hint: "[design | review]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent
---

# /rbx-first-60

## 0. Relevance check
The game has no player-facing start yet and no concept (pure backend or library work): `SKIPPED: no first minute to design`. `review` needs a playable build (scripts exist in Studio or src/); none: switch to `design`. Default: `review` if playable, else `design`.

## 1. Context
`{{RBX_HOME}}/library/roblox/ux-standards.md` (First 60 seconds + Look check rubric), `{{RBX_HOME}}/library/roblox/genres/<genre>.md` (Session one), concept brief and loop notes in `.rbx-studio/reports/`. Why it matters: first-play bounce under 60 s and at 61-180 s is a top negative ranking signal (`discovery-algorithm.md`).

## 2. Design
`ux-mobile-designer` + `retention-designer` (parallel) fill `{{RBX_HOME}}/templates/first-60.md`: storyboard by second, loading plan (ReplicatedFirst, small preload), control by 5 s, reward by 20 s, goal by 30 s, upgrade by 60 s (heuristic targets), max 4 words of text per beat, bounce risks. Save to `.rbx-studio/reports/first-60.md`.

## 3. Review (Studio MCP)
Delegate to `qa-playtester` following `{{RBX_HOME}}/docs/look-check.md`: fresh-player state (reset the test player's data in the edit datamodel or use a test key), start play, capture at 0, 5, 20, 40, 60 s on desktop and on a landscape phone (Device Simulator skill), note the time each beat actually happened, read console errors. Then `ux-mobile-designer` judges each capture against the rubric (PASS/FAIL per line with measured values).

## 4. Fix list
Rank gaps by bounce risk: anything that delays control or the first reward ranks first. Hand UI fixes to `client-ui-programmer`, pacing to `retention-designer`. Do not fix inside this skill unless the fix is one line.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- first-60: <PASS | FAIL>, control at <s>, first reward at <s>, goal at <s>
- evidence: .rbx-studio/evidence/first-60/<files>
- top fix: <one line>
YOU DO
1. <exact step>
RISKS
- <only if real>
NEXT
- /rbx-build <top fix>
```
