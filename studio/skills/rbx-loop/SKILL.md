---
name: rbx-loop
description: "Roblox: core loop, session plan, retention hooks, progression curve simulation."
argument-hint: "[design | curve | review]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Agent
disable-model-invocation: true
---

# /rbx-loop

## 0. Relevance check
`curve` with no progression in the game (pure party or social game): `SKIPPED: no progression to model`. `review` needs real retention numbers or a playable build; without either, run `design`.

## 1. Context
Concept brief and genre notes in `.rbx-studio/reports/`, `{{RBX_HOME}}/library/roblox/genres/<genre>.md` (Core loop, Retention hooks), `{{RBX_HOME}}/library/roblox/discovery-algorithm.md` (signals: play days, playtime, co-play days, spend days over D1, D2-7, D8-28).

## 2. Loop and sessions
Delegate to `retention-designer`: loop in one line, session plan (first session minute by minute to 10, typical return session), hooks per window (D1, D7, D30) each with the metric that judges it. Only Octalysis or flow lenses that fit this game.

## 3. Curve simulation
For any progression or economy curve: write the formulas into `.rbx-studio/reports/curve.luau` (pure Luau) and run it with `lune run .rbx-studio/reports/curve.luau` if Lune is installed (else compute in a table). Output time-to-unlock for the first 10 milestones and the first hour of currency. Flag gaps more than 2x the previous step and any milestone under 10 s or over 30 min early on.

## 4. Save
Fill the loop sections of `{{RBX_HOME}}/templates/gdd-short.md` into `.rbx-studio/reports/gdd.md` (create or update only those sections).

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- loop: <one line>
- curve: first 10 unlocks <t1..t10>; flags: <n>
- saved: .rbx-studio/reports/gdd.md, curve.luau
YOU DO
1. <exact step>
RISKS
- <only if real>
NEXT
- /rbx-first-60 design or /rbx-plan
```
