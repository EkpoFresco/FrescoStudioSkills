# Skill Spec: /rbx-telemetry
Category: build · Source: `studio/skills/rbx-telemetry/SKILL.md`

## Summary
Plans and adds AnalyticsService events that answer written questions. `analytics-engineer` writes `.rbx-studio/reports/telemetry.md` mapping each question to events (built-in first), fire time, fields, dashboard page, and the decision it drives. `add` puts all calls in one server Analytics module and closes with `code-optimizer` review. `experiment` defines a Roblox Experiments test with guardrails before it starts.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Questions written first; `SKIPPED: no question to answer` when none exist and `roblox.analytics: false`
- [ ] Limits from `implementation-data.md`: server only, published games only, `120 + 20 x CCU` req/min, about 24 h, 100 custom event names, 10 funnels, 3 custom fields
- [ ] Built-in first (onboarding funnel, funnel, economy), custom last
- [ ] Experiments via Configs + `ConfigService:GetConfigForPlayerAsync`; DIY UserId bucketing only if Experiments cannot express it
- [ ] Flow or churn telemetry only for frustration, boredom, or quitting questions

## Fixture Defaults
Template project.yaml (`rigor: minimal`, `toolchain: rojo`, `analytics: true`), concept brief with kill criteria, Studio MCP connected.

## Case 1: Happy path - add an onboarding funnel
**Fixture**: `/rbx-telemetry add`; question "where do new players drop in the first 3 minutes?"; no existing `AnalyticsService:Log` calls.
**Expected**: 1. Plan in telemetry.md. 2. One module `src/server/Analytics.luau`. 3. Server call sites. 4. code-optimizer review.
**Assertions**:
- [ ] Question maps to onboarding funnel steps (`LogOnboardingFunnelStepEvent`), not custom events
- [ ] No AnalyticsService call in `src/client/`; names stable and low-cardinality; no usernames or other personal data in fields
- [ ] Review verdict reported and not CHANGES REQUIRED
- [ ] YOU DO: publish, then after about 24 h Creator Hub > Creations > <game> > Analytics > <page>

## Case 2: Relevance skip - no question
**Fixture**: `roblox.analytics: false`; no request detail, no kill criteria, no weak funnel step known.
**Assertions**:
- [ ] Prints `SKIPPED: no question to answer` and writes nothing

## Case 3: Edge - experiment on shop price
**Fixture**: `/rbx-telemetry experiment starter-pack-price`; variants 99 R$ and 149 R$.
**Assertions**:
- [ ] Uses Roblox Experiments with Configs, not DIY hash bucketing
- [ ] Defines variant, success metric (payer conversion), guardrail (D1 or bounce), minimum run time, and stop rule before starting
- [ ] Price changes on the live game stay a YOU DO step

## Protocol Compliance
- [ ] Writes only `.rbx-studio/` plus the Analytics module and its call sites
- [ ] `code-optimizer` review before `add` closes (B1)
- [ ] Ends with NEXT `/rbx-metrics in 48 h`
