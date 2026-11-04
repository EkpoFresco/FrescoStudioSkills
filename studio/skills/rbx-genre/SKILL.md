---
name: rbx-genre
description: "Roblox: pull genre patterns (32-genre library) for this game: take, skip, twist, traps."
argument-hint: "[genre | genre+genre]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Agent
disable-model-invocation: true
---

# /rbx-genre

## 0. Relevance check
Genre from `$ARGUMENTS`, else `roblox.genre` in `.rbx-studio/project.yaml`. Neither: pick the closest 3 to the concept hook (or the game name if no concept) from `{{RBX_HOME}}/library/roblox/genres/README.md` with their Roblox fit and stop (`SKIPPED: pick a genre`).

## 1. Context
The genre file(s) in `{{RBX_HOME}}/library/roblox/genres/`. The concept brief in `.rbx-studio/reports/` if present.

## 2. Adapt
Delegate to `genre-designer` with the genre file path(s), the concept hook, and team size. Ask for: take (mechanics), skip (with why), the one twist, session-one timeline adapted to this game, the top 3 Roblox technical traps with the owning agent, and monetization norms that fit `roblox.monetization_style`.

## 3. Save
Write `.rbx-studio/reports/genre-<genre>.md` (max 60 lines). Blends: `genre-<primary>-<secondary>.md`, primary = the genre that owns the core loop. Keep UNVERIFIED tags from the library.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- genre notes: .rbx-studio/reports/genre-<genre>.md
- take: <3 items> · skip: <2 items> · twist: <1 line>
YOU DO
1. <exact step>
NEXT
- /rbx-loop
```
