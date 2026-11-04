---
name: rbx-optimize
description: "Roblox: fix top perf, memory, network debt one change at a time with measured before/after."
argument-hint: "[top | <debt id> | <file>] [--max N]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Agent
---

# /rbx-optimize

## 0. Relevance check
No `.rbx-studio/debt.md` items, no recent `/rbx-perf` report, and no target given: run the static scan from `/rbx-perf` step 3 to seed `debt.md`, then continue. Nothing found anywhere: `SKIPPED: no measurable debt`.

## 1. Pick targets
Read `.rbx-studio/map.md` first (rebuild with `node "{{RBX_HOME}}/tools/rbx-map.js"` if missing or stale) and open only the scripts it points to. Score each candidate: impact (1-5, players and ms/MB/KB affected) x risk of leaving it (1-5) / effort (1-5). Take the top `--max` (default 3). Prefer per-player growth (leaks), hot paths, and bandwidth over cosmetic cleanups.

## 2. For each target (code-optimizer, one at a time)
1. Baseline: measure with the method that fits (`{{RBX_HOME}}/docs/standards.md` accepted sources): MicroProfiler label ms, memory MB over 5 min, instance count, KB/s, or a Lune benchmark (median of 5 runs of N iterations) for pure modules. Same place, same player count, warmup.
2. Change one thing. Follow Keep patterns in `.rbx-studio/conventions.md`; migrate a Phase out pattern if that is the target.
3. Re-measure with the identical setup.
4. Verify nothing broke: tests if present, then a short MCP play run of the touched feature (`get_console_output` clean).
5. Keep it only if the number improved and nothing broke; otherwise revert and record why.
6. Local commit `perf(<scope>): <what> (<before> -> <after>)`.

## 3. Record
Update `debt.md` statuses. Append learned patterns to `conventions.md`. Write `.rbx-studio/reports/optimize-<date>.md` with the before/after table:
`| Target | Metric | Before | After | Method | N | Kept |`

## Rules
No number, no claim (mark NOT ASSESSED). Never refactor and optimize in the same commit. Never touch working gameplay feel without a playtest.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- <target>: <metric> <before> -> <after> (<method>, N=<n>), kept | reverted
YOU DO
1. <exact step>
RISKS
- <only if real>
NEXT
- <one line>
```
