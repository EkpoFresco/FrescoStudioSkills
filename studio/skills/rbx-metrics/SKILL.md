---
name: rbx-metrics
description: "Roblox: paste Creator Analytics or third-party numbers (PTR, bounce, D1/D7/D30, session length, playtime, ARPDAU, conversion, CCU) and get a diagnosis of the first broken funnel step and the next 3 actions. Use weekly on a live game, after an update, or when growth stalls."
argument-hint: "<pasted numbers | path to export>"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Agent
---

# /rbx-metrics

## 0. Relevance check
No numbers pasted or attached: ask for exactly these (one list, then stop): impressions, PTR, first-play bounce (<60 s, 61-180 s), D1, D7, D30, avg session length, playtime per user, payer conversion, ARPDAU, CCU peak, each with date range and the benchmark percentile if shown. Creator Hub path: Creations > <game> > Analytics. Print `SKIPPED: no numbers yet` after the list.

## 1. Context
`{{RBX_HOME}}/library/roblox/discovery-algorithm.md` (signals ranked on RFY-organic players only; benchmarks do not affect ranking; the 2026-10-12 measurement change dipped PTR for every game), `discovery-playbook.md` (healthy = at or above 50th percentile of similar games, strong near 90th), `genres/<genre>.md`.

## 2. Diagnose
`analytics-engineer` + `discovery-strategist` walk the funnel in order: impressions -> PTR -> bounce -> D1 -> D2-7 -> D8-28 -> co-play -> spend. Mark each step PASS (at or above the 50th percentile) or FAIL. The first FAIL (or clearly broken step) is the problem; overall verdict HEALTHY or AT RISK. Cross-check: traffic mix (ads, search, friends do not count for ranking), recent updates, seasonality, measurement changes.

## 3. Actions
3 actions max, each with: what to change, which skill does it, the metric that should move, and when to re-check. Retention before monetization unless retention is already strong.

## 4. Save
Append to `.rbx-studio/reports/metrics-log.md`: date, key numbers, diagnosis line, actions. Trend lines only within one source.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- problem: <funnel step> at <value> (<percentile>) vs <benchmark>
- actions: 1) <..> 2) <..> 3) <..>
YOU DO
1. <exact step>
RISKS
- <only if real>
NEXT
- <skill for action 1>
```
