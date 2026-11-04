# Telemetry plan: Snorbo's Brain Rock Mine
Date: 2026-11-04 · Mode: plan only (no code changed) · Basis: concept kill criteria, first-60.md, monetization.md, Game.server.luau, Data.luau, Config.luau, Remotes.luau, library implementation-data.md section 9 (checked 2026-11-03)

## Verdict in 4 lines
- Q1 bounce and Q3 session length and D1 need zero events. Roblox computes them. We only read them.
- Q2 needs one onboarding funnel (6 steps). That is the only funnel.
- Q4 needs one economy currency (Rocks), batched, plus one custom event.
- Total: 1 onboarding funnel, 0 of 10 regular funnels, 1 of 5 currencies, 1 of 100 custom event names (2nd later), 1 of 3 custom fields.

## Rules that shape the plan
- AnalyticsService is server only and logs only in a published game. Studio and clients log nothing.
- Budget is 120 + 20 x CCU requests per minute, all methods combined. A tap fires up to 15 times a second per player (Config.RateLimits.Mine). So taps and the 10 Hz tick are never logged one by one. They are summed in memory and flushed every 60 s.
- Charts take about 24 h. Use View Events for same-day checks.
- KPIs unlock only after more than 10 DAU and 10 play hours for 7 days in a row (discovery-playbook, Reading the dashboard). The 250-play kill gate may fire before the bounce chart shows. The funnel and Economy pages are the fallback. UNVERIFIED whether those two pages unlock earlier. Verify: open them on day 2 of real traffic.
- Log after success, not on attempt. Every call below sits after the state change.
- No personal data. Fields hold only fixed buckets. No UserId, no name, no event name built from input.

## Question 1: first-play bounce (<60 s and 61-180 s, threshold 40%)
| Item | Plan |
|---|---|
| Built-in | Roblox first-play bounce metric. No code. |
| Events | None. |
| Dashboard | Creator Hub > Creations > game > Analytics > Acquisition (bounce next to PTR). UNVERIFIED which page holds it. Verify: open Acquisition and Overview, find the "bounce" tooltip, copy the exact definition into this file. |
| Decision | Over 40% under 60 s after 7 days and 250 RFY plays: rework first 60 s (first-60.md fix list order 1,3,2,4,8,6). Still over 40% at day 14: kill. |
| Gap | Roblox does not say why they left. Question 2 covers the why. |

## Question 2: where new players drop in the first 3 minutes
Tool: `AnalyticsService:LogOnboardingFunnelStepEvent(player, step, stepName, customFields)`. Built-in first, no custom event.

| Step | stepName | Fires when | Call site |
|---|---|---|---|
| 1 | `Joined` | New player's profile loaded and first State pushed | src/server/Game.server.luau:109 (just before `push(player)`) |
| 2 | `FirstTap` | First accepted Mine | Game.server.luau:131 (after `add`) |
| 3 | `FirstBonkPick` | bonkPick level goes 0 to 1 | Game.server.luau:156 (after `p.Levels[def.id] = ...`) |
| 4 | `FirstSnorblet` | snorblet level goes 0 to 1. This is the aha. | Game.server.luau:156 |
| 5 | `Snorblet10` | snorblet level reaches 10 (bulk buy chip point) | Game.server.luau:156 |
| 6 | `FirstBrainDrill` | brainDrill level goes 0 to 1 | Game.server.luau:156 |

- Fields: `CustomField01 = Bucket`, one of `t<60`, `t60-180`, `t180+`. It is seconds since this session's join (`os.clock()` stored at step 1). This ties each step to the two bounce windows. UNVERIFIED that the Funnels page can split a step by custom field. Verify: after first data, look for a breakdown control on the Funnels page. If missing, drop the field and read time from the step-to-step drop plus the bounce chart.
- New player means `OnbStep < step`. A new profile field `OnbStep: number` (default 0) is stored in the save. Reason: a player who taps once, leaves, and returns has `Lifetime > 0`, so a "Lifetime == 0" test would hide them from steps 3 to 6 and undercount the funnel. The field also stops repeats across sessions.
  - Data.luau:8-17 (`Profile` type) and Data.luau:33-44 (`template`) add `OnbStep = 0`. `reconcile` (Data.luau:46) already fills missing keys, so no Version bump and no migration. data-engineer to confirm.
- Order: `Analytics.step` fires any missing earlier steps first, in order. A player who buys a Snorblet without a Bonk Pick (50 taps at +1) logs step 3 then 4. This is rare and keeps the funnel monotone. UNVERIFIED whether Roblox needs in-order steps. Verify: View Events.
- Dashboard: Analytics > Funnels (onboarding funnel).
- Decision (first broken step wins, heuristics, UNVERIFIED thresholds):
  - Step 1 to 2 under 85%: the rock is not read as the button. Fix cue (pulse ring, hand), per first-60 risk 3 and 1.
  - Step 2 to 3 under 70%: Bonk Pick not found or taps feel dead. Fix prompt and local tap prediction (risks 3, 8).
  - Step 3 to 4 under 60%: the 0:21 aha is too slow or the row is not visible. Fix pacing, starter Snorblet.
  - Step 4 to 5 under 50%: the 0:53 plateau (risk 6). Add the x2 milestone, retention-designer call.
  - Step 5 to 6 under 40%: Brain Drill goal is not pulling. Fix the progress fill.

## Question 3: session length and D1 return (D1 under 15% pivots)
| Item | Plan |
|---|---|
| Built-in | Engagement (average session time, playtime) and Retention (D1, D7, D30 cohorts). No code. |
| Events | None. A custom SessionEnd event is not added: Roblox already reports the average, and a duration value would cost 1 request per leave for no new decision. |
| Dashboard | Analytics > Engagement (session time). Analytics > Retention (D1 by source). |
| Read | Split D1 by source (RFY vs other). Early traffic is age-checked 16+ (concept risk). A low D1 from that slice is not proof for the target audience. |
| Decision | D1 under 15% after 14 days of RFY traffic: pivot the hook. D1 fine but session under the similar-game median: go to the loop (retention-designer). |
| Link to Q4 | If D1 is low and the Offline source is tiny, the return reason is weak. Read Q4 next. |

## Question 4: is the economy inflating
One currency: `Rocks`. Tool: `LogEconomyEvent(player, flowType, currency, amount, endingBalance, transactionType, itemSku, customFields)`. Amounts are summed in memory and flushed, so one event stands for many.

| Flow | transactionType | itemSku | Accumulated where | Call site |
|---|---|---|---|---|
| Source | Gameplay | `Tap` | Each accepted Mine | Game.server.luau:131 |
| Source | Gameplay | `Idle` | Each tick (sum of all helpers, one key) | Game.server.luau:216 |
| Source | TimedReward | `Offline` | Offline pile credited at join | Game.server.luau:106-108 |
| Sink | Shop | upgrade id (`bonkPick`, `snorblet`, `brainDrill`, `mushRocket`, `gooBase`) | Cost paid | Game.server.luau:155 (after `p.Rocks -= cost`; use `cost`) |
| Sink | Gameplay | `Rebirth` | Balance wiped by rebirth | Game.server.luau:173 (log `p.Rocks` before the reset to 0). Only if the Rebirth handler stays in the build; it is cut but the code exists. Without it Rocks vanish unlogged. |

- Transaction type enum member names are from memory. UNVERIFIED. Verify: type `Enum.AnalyticsEconomyTransactionType.` in Studio and use the listed members.
- `endingBalance` is `p.Rocks` at flush time.
- Large numbers: Rocks reach 1e30 and above late. UNVERIFIED how the Economy page handles values that large. Verify: View Events after a test session at high levels. If sums look wrong, log `math.log10(amount)` is NOT an option (it breaks sums). Instead cap the test build or read per-event counts only.
- Request cost: at most 3 sources + 5 sink SKUs + 1 rebirth = 9 events per player per minute. Allowance is 20 per CCU per minute plus 120. Margin is over 2x at any CCU.

Custom event, last:
| Name | Fires when | Value | Field | Question | Call site |
|---|---|---|---|---|---|
| `OfflineGrant` | A returning player gets an offline pile | Seconds credited (`min(away, Config.OfflineCapSeconds)`) | `CustomField01`: `capped` if away reached the cap, else `open` | Does the 2 h cap bite? Do players return after long gaps? | Game.server.luau:106-108 (inside `if offline > 0`) |
| `WelcomeBackClaim` (LATER, blocked) | Player claims the 2x | 1 | `CustomField01`: `2x` | Welcome Back 2x claim rate | Does not exist yet. See gap below. |

Gap: there is no Welcome Back claim. The offline pile is auto-credited at join (Game.server.luau:106-108) and no remote or Hud code mentions it. Welcome Back 2x is in the director's scope, so when the claim handler is built, log its extra rocks as Source / TimedReward / `WelcomeBack2x` and fire `WelcomeBackClaim` there. Claim rate = `WelcomeBackClaim` count / `OfflineGrant` count.

Dashboard: Analytics > Economy (sources, sinks, flow by SKU, ending balance). Counts and cap share: Analytics > Explore (custom events).

Decisions (all thresholds are heuristics, UNVERIFIED, tune after week 1):
| Read | Meaning | Action |
|---|---|---|
| Sinks / sources under 0.5 over a day | Players hoard, nothing to buy. Prices too low or content gap. | Raise `growth` or `baseCost` in Config.Upgrades, or add the next tier sooner. |
| Sinks / sources near 1.0 | Greedy reinvest. Expected for an idle game. Healthy. | None. |
| Median ending balance rising week over week | Inflation. | Same as above, and check the Rebirth gain curve before restoring rebirth. |
| `Offline` over 50% of sources | Players earn more away than active. Tap loop is weak. | Retention-designer: lower `OfflineRate` or strengthen the active loop. |
| `OfflineGrant` capped share over 50% | Players leave over 2 h often. Cap bites. | Evidence for the Big Sack pass later (monetization-designer). |
| `Tap` under 10% of sources after minute 10 | Taps stop mattering early. Pillar 1 fades. | Review perClick scaling. |
| Per-SKU sinks show one upgrade at zero | Players never reach that tier. | Check step 5 to 6 in the funnel, then the price. |

## One server module: src/server/Analytics.luau
Single owner of AnalyticsService. Nothing else calls it. `--!strict`, services cached at top, every call in `pcall`, nothing runs in Studio (`RunService:IsStudio()` returns early; the service would drop it anyway). No client code, no new remote.

API (names fixed so call sites above stay valid):
- `Analytics.joined(player, p)`: stores `t0 = os.clock()`, calls `step(player, p, 1)`.
- `Analytics.step(player, p, n)`: fires steps `p.OnbStep+1 .. n`, sets `p.OnbStep = n`. Reads the bucket from `t0`.
- `Analytics.source(player, sku, amount)`: adds to the per-player sum. No allocation on the 10 Hz path.
- `Analytics.sink(player, sku, amount)`: same, sink side.
- `Analytics.offline(player, away, credited)`: fires `OfflineGrant`.
- `Analytics.flush(player)`: one `LogEconomyEvent` per nonzero key, then zero the sums. Reads `Data.get(player).Rocks` for `endingBalance`. A module-owned 60 s loop calls it for every player (same cadence as the autosave, Data.luau:143-150).
- `Analytics.clear(player)`: drops the player's table.

Lifecycle call sites in Game.server.luau:
- Line 11 area: `local Analytics = require(script.Parent:WaitForChild("Analytics"))`.
- Lines 117-120 (PlayerRemoving): `Analytics.flush(player)` BEFORE `Data.release(player)` at line 119 (release clears the profile), then `Analytics.clear(player)`. Logging during shutdown may drop. UNVERIFIED; accept a small tail loss.
- Player-keyed state is cleared on PlayerRemoving, per rbx-luau.md.

Config: set `analytics: true` in `.rbx-studio/project.yaml` (line 14) in the same change that adds the module. It is false today. The concept's director call puts telemetry in scope, so flip it when the first event lands.

Order of work (small): 1) `OnbStep` field (data-engineer nod), 2) Analytics.luau, 3) wire the 9 call sites, 4) publish, 5) play a test session, 6) check View Events.

## Not added (and why)
- No flow or churn events (no design question about frustration).
- No regular funnels (the onboarding funnel covers Q2).
- No Experiments (no test is running; the Double Rocks price test is post-gate).
- No progression events (not charted).
- No per-tap or per-tick logging (rate limit).

## Later list (cut until bounce passes at 250 RFY plays)
- Rebirth: `Rebirth` sink exists above; add Brain Cells as currency 2 and a preview-opened custom event.
- Moon 2: custom event `MoonEnter` with `CustomField01 = moon id`.
- Monetization: IAP economy event after the receipt is saved (Game.server.luau:195-198, after `Data.save` succeeds), shop-open funnel, Experiments for Double Rocks 199 vs 249.
- Welcome Back claim events (above) when the claim ships.

## YOU DO (after build)
1. Publish the place. Play one fresh test account 3 minutes. Creator Hub > Creations > Snorbo's Brain Rock Mine > Analytics > Explore > View Events. Expect 6 onboarding steps, `OfflineGrant` after a rejoin 5 minutes later, and Economy events within 60 s.
2. Day 2: Analytics > Funnels. Read the first step under its threshold.
3. Day 8: Acquisition for bounce, Retention for D1, Economy for sinks/sources. Apply the kill table.

## RISKS
- KPI unlock (10 DAU, 10 play hours, 7 days) may delay the bounce read past the gate date. Funnel is the fallback.
- Early traffic is 16+ (audience gate). Bounce and D1 skew older than the target. Read by source.
- Bucket field split, enum member names, giant-number handling, and step order rules are UNVERIFIED (each has a verify step above).
- `OnbStep` touches the save schema. Additive only, but data-engineer should confirm.

## NEXT
- server-programmer or data-engineer builds the `OnbStep` field and `src/server/Analytics.luau`, then code-optimizer reviews the 9 call sites.

## Open questions
1. Is the Welcome Back 2x a free claim button or the rewarded ad? The monetization sheet says ad (skipped in v1), the concept says in scope. The claim event waits on this.
2. Keep the Rebirth handler live in the test build? If yes, the `Rebirth` sink line is required.
