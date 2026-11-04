# Snorbo's Brain Rock Mine concept brief
Date: 2026-11-04 · Genre: idle-clicker · Status: go (smallest test)

## Hook (1 line)
Tap a giant brain rock, watch Snorblet helpers dig for you, and rocket to goofier moons.

## Pillars (3)
1. The first tap pays. First upgrade in under 10 s.
2. Every moon changes how the game plays, not only a number.
3. Big Brain rebirth shows its exact gain before you press it.

## First 60 seconds (3 beats)
0-10 s: tap the brain rock, +1 per tap, Bonk Pick (10 rocks) is affordable at once. · 10-30 s: buy the first Snorblet (50 rocks), income ticks with no tapping. · 30-60 s: Snorblet count climbs, bulk-buy appears, Brain Drill is shown as the next goal.

## Discovery hypothesis
- Who clicks: Home RFY players, mostly under 16, mobile, who play brainrot and idle income games.
- Why they stay (QPTR story): the Snorblet "aha" lands before 3 min, then a visible rebirth preview with an exact gain number gives a goal. Return on D1 for banked offline earnings (2 h cap, 50%) and a Welcome Back 2x.
- Signals we expect to move: PTR, first-play bounce (<60 s and 61-180 s), D1 / D2-7 / D8-28, co-play days (weak for a solo clicker), spend days.
- Thumbnail promise = first 60 s delivery: giant brain rock with one Snorblet on it. The player taps that rock in the first 10 s.

## Market check
| Reference game | CCU (source, time) | What we take (mechanics only) | What we do better |
|---|---|---|---|
| Steal a Brainrot | ~85-100K, -69.5% WoW, RobloxGameStats/RoWatcher weekly, 2026-11-03 (UNVERIFIED) | Brainrot theme pull, income while away | Active tap loop plus moons. No steal or PvP stress |
| Sell Lemons | peak ~229K, tracker not named, 2026-11-03 (UNVERIFIED) | Hired helpers, offline earnings, rebirth boost | Funnier theme, moon variety |
| Anime Dice | not in library (UNVERIFIED; check CCUCheck API) | Units earning idle income | No random paid rolls, no odds disclosure needed |

Theme risk: brainrot interest is falling fast (-69.5% WoW on the lead title). UNVERIFIED trend; verify on CCUCheck before art spend.

## Monetization fit (one line, see monetization-sheet)
Light: 2x income pass, offline cap extension, RockRush 10-min x2 product (productId still 0), no paid random items.

## Scope for first playable (max 5 bullets)
- Tap, 5 upgrades, bulk buy, suffix number format (K to Dc).
- Server-owned economy, 1 Hz income tick, client interpolation.
- Offline earnings with Welcome Back 2x.
- Big Brain rebirth with exact gain preview, root-curve gain, first rebirth at 20-40 min.
- Moon 2 as a real change (one ore value and Snorblet behavior), not a reskin.

## Kill criteria
- If first-play bounce <60 s is above 40% after 7 days and 250 RFY plays, rework first 60 s; if still above 40% after 14 days, kill. (Threshold is a heuristic, UNVERIFIED.)
- If D1 < 15% after 14 days of RFY traffic, pivot the hook.
- If the game has fewer than 100 unique plays by day 30 post-launch, treat the audience gate as the cause, then pivot to ads for retrieval only.

## Risks (only real ones)
- Audience gating: new games reach only age-checked 16+ users until Kids and Select evaluation passes. Early data skews older than the target.
- Brainrot trend decay.
- Crowded idle niche; the moon mechanic is the only differentiator.

## Director call (2026-11-04): GO, smallest test
- Ship tap, 5 upgrades, bulk buy, K-to-Dc format, server economy with save, offline earnings with Welcome Back 2x, telemetry (bounce <60 s and 61-180 s, session length, D1).
- Cut until bounce passes at 250 RFY plays: Big Brain rebirth preview, Moon 2, monetization.
- Tension: pillars 2 and 3 (moons, rebirth) are in the cut list. Test pillar 1 first.
