---
name: rbx-playtest
description: "Roblox: launch the game through Studio MCP, play it with simulated input, read the console, screenshot desktop and a landscape phone via the Device Simulator, check state on the server, and write a playtest report with a verdict. `--smoke` is a 3-minute critical path; `--soak` watches memory over 10+ minutes. Use after a build, before a PR, or before publishing."
argument-hint: "[<story or area>] [--smoke | --soak]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Agent
---

# /rbx-playtest

## 0. Relevance check
No Studio MCP tools: say so, run Lune tests if any, mark the visual half NOT VERIFIED, write the report, stop. No playable scripts: `SKIPPED: nothing to play`.

## 1. Plan
From the story acceptance lines (or the backlog's done stories since the last playtest, or the first 60 s for a fresh game), list 5-10 steps (`--smoke`: 3-5 critical-path steps). Each step: input, expected result, how to confirm (screenshot, Server datamodel value, console line).

## 2. Run
Delegate to `qa-playtester` with the plan and `{{RBX_HOME}}/docs/look-check.md`. It must: `get_studio_state`, start play, read the console, drive each step, confirm effects on the Server datamodel with `execute_luau` (not just visuals), capture desktop and phone per key state, save evidence to `.rbx-studio/evidence/playtest-<date>/`, stop play.
`--soak`: 10+ minutes; sample `collectgarbage("count")`, instance count, and memory every minute; a steady climb over 5 samples is a leak finding for `code-optimizer`.

## 3. Judge
`ux-mobile-designer` checks captures against the Look check rubric (`{{RBX_HOME}}/library/roblox/ux-standards.md`). Bugs ranked by severity with repro steps.

## 4. Save
`.rbx-studio/reports/playtest-<date>-<slug>.md` from `{{RBX_HOME}}/templates/playtest-report.md`. Verdict: PASS, CONCERNS, or FAIL.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- verdict: PASS | CONCERNS | FAIL (<report path>)
- Run result: OBSERVED - <what> - <evidence dir>
- bugs: <n> (worst: <one line>)
YOU DO
1. <exact step>
RISKS
- <only if real>
NEXT
- /rbx-build <worst bug>
```
