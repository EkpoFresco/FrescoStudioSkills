# Skill Spec: /rbx-metrics
Category: growth · Source: `studio/skills/rbx-metrics/SKILL.md`

## Summary
Diagnoses the first broken funnel step from pasted Creator Analytics or third-party numbers. `analytics-engineer` and `discovery-strategist` walk impressions -> PTR -> bounce -> D1 -> D2-7 -> D8-28 -> co-play -> spend, mark each PASS (at or above 50th percentile) or FAIL, and return HEALTHY or AT RISK with up to 3 actions. Appends to `.rbx-studio/reports/metrics-log.md`.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] No numbers: one list (impressions, PTR, bounce <60 s and 61-180 s, D1, D7, D30, session length, playtime per user, payer conversion, ARPDAU, CCU peak, with date range and percentile), path Creations > <game> > Analytics, then `SKIPPED: no numbers yet`
- [ ] Names `discovery-algorithm.md` (RFY-organic only, benchmarks do not affect ranking, 2026-10-12 measurement change) and `discovery-playbook.md` (50th healthy, near 90th strong)
- [ ] Verdict HEALTHY or AT RISK; first FAIL in funnel order is the problem
- [ ] Max 3 actions, each with skill, metric to move, and re-check time; retention before monetization
- [ ] Trend lines only within one source

## Fixture Defaults
Template project.yaml (`genre: obby`, `universe_id: "5123456789"`), `metrics-log.md` absent, no Studio MCP needed.

## Case 1: Happy path - bounce is the problem
**Fixture**: Pasted (Oct 20-26, Creator Analytics): impressions 412,000; PTR 6.1% (62nd pct); bounce <60 s 38% (31st pct); D1 19% (44th); D7 5% (40th); ARPDAU 0.6 R$.
**Expected**: 1. Read context. 2. Walk funnel. 3. Actions. 4. Append log.
**Assertions**:
- [ ] Impressions and PTR PASS; bounce is the first FAIL and named the problem with value and percentile
- [ ] Verdict AT RISK
- [ ] Action 1 targets the first minute (e.g. `/rbx-first-60 review`), not monetization
- [ ] metrics-log.md gains a dated entry with numbers, diagnosis, actions

## Case 2: Relevance skip - no numbers
**Fixture**: `/rbx-metrics` with nothing pasted or attached.
**Assertions**:
- [ ] Prints the one request list and `SKIPPED: no numbers yet`; writes nothing

## Case 3: Edge - PTR dip after the measurement change
**Fixture**: PTR 7.4% (Oct 1-7) and 5.2% (Oct 13-19); 40% of traffic from ads; RoMonitor CCU pasted alongside.
**Assertions**:
- [ ] Names the 2026-10-12 measurement change before blaming thumbnails
- [ ] Says ads traffic does not count for ranking
- [ ] Does not draw one trend line across Creator Analytics and third-party CCU

## Protocol Compliance
- [ ] Every number carries its source and date range (G1)
- [ ] Diagnoses in funnel order (G2); changes nothing live
- [ ] Ends with NEXT naming the skill for action 1
