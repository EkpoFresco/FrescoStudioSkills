---
name: rbx-telemetry
description: "Roblox: plan and add AnalyticsService events that answer real questions: onboarding funnel, funnels, economy sources and sinks, custom events, Roblox Experiments for A/B tests, and flow or churn signals only when relevant. Use when you need data to decide, or before launch."
argument-hint: "[plan | add | experiment <name>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent
---

# /rbx-telemetry

## 0. Relevance check
Write the questions first (from the request, the concept kill criteria, or the weakest funnel step). No question and `roblox.analytics: false`: `SKIPPED: no question to answer`. No question but `analytics: true`: use the default pair (where do new players drop in the first 3 minutes; is the core loop economy inflating) and continue. Flow or churn telemetry only if a question is about frustration, boredom, or quitting.

## 1. Context
`{{RBX_HOME}}/library/roblox/implementation-data.md` (AnalyticsService limits: server only, published games only, `120 + 20 x CCU` req/min, about 24 h to appear, 100 custom event names, 10 funnels, plan for 5 economy currencies (UNVERIFIED cap), 3 custom fields; Experiments on Configs). Existing events: Grep or `script_grep` for `AnalyticsService:Log`.

## 2. Plan
`analytics-engineer` writes `.rbx-studio/reports/telemetry.md`: per question, the event(s) (built-in first: onboarding funnel, funnel, economy; custom last), when each fires, fields, the dashboard page where the answer appears, and the decision it drives.

## 3. Add (`add`)
With Studio MCP, load the built-in MCP skills first (`skill` tool): `rbx-instrument-analytics` for event wiring and `rbx-configs-experimentation` for Configs and Experiments.
One server Analytics module wrapping the calls; call sites only on the server; stable low-cardinality names; no personal data. Then `/rbx-build`-style close: `code-optimizer` review.

## 4. Experiment (`experiment`)
Roblox Experiments first (Configs + `ConfigService:GetConfigForPlayerAsync`). Define variant, success metric, guardrail metric (D1 or bounce), minimum run time, and stop rule before starting. DIY hash bucketing of UserId only if Experiments cannot express it.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- <n> questions -> <n> events (.rbx-studio/reports/telemetry.md); added in <path>
YOU DO
1. publish, then after about 24 h: Creator Hub > Creations > <game> > Analytics > <page>
RISKS
- <only if real>
NEXT
- /rbx-metrics in 48 h
```
