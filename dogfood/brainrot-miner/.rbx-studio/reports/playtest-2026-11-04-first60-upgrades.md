# Playtest report: first 60 s and upgrade buying (commit 193b302)
Date: 2026-11-04 · Mode: normal · Devices: Studio desktop viewport 492x464 (small Studio pane), iPhone 13 sim 749x388 (iPhone 14 not in list) · MCP: yes

## Verdict
CONCERNS. The core loop and server checks work. Snorblet, the "aha" upgrade, is sorted last in the list and sits below the fold.

## Run
| Step | Expected | Observed | Evidence |
|---|---|---|---|
| 1 Boot | No errors | 4 x "ContentId rbxassetid://203785492 failed: Asset type does not match" (not from game code, no asset id in src/). No script errors. Hud present on first read. | console |
| 2 Spawn cue | Rock tappable at spawn, pulse for first 2 taps | Rock 122x122 px at desktop, 99 px on phone. Stroke pulsed 6 to 15 px on a 0.6 s sine. After 10 taps the stroke is static gold 6 px. Rebirth hidden. | 01-spawn-desktop.png |
| 3 Tap x10 | +1 each, server confirms | 10 taps = 10 rocks. Read from the State snapshot the server pushes (rocks 10, lifetime 10). | 02-afford-bonk-desktop.png |
| 4 Affordability | Button changes at 10 rocks | Bonk Pick row turns green at 10 rocks. Other rows stay dark. | 02-afford-bonk-desktop.png |
| 5 Buy Bonk Pick | -10 rocks, level 1, perClick 2 | rocks 10 to 0, levels.bonkPick 1, perClick 2. | 03-after-purchase-desktop.png |
| 5b Cost curve | floor(10 x 1.15^n) | 6 more buys cost about 11, 13, 15, 17, 20, 23 (deltas include about 0.35 s of passive income). Matches the curve. | run log |
| 5c Income | Snorblet gives +1/s | Snorblet bought: perSecond 1, rocks tick up. | state JSON |
| 6 Unaffordable and spam | Server rejects | 150 spam buys at 0 rocks (snorblet, drill, bonkPick x100) and 6 bad-arg calls (-1, NaN, inf, 1.5, bad id, tables): no change. 5 simultaneous Snorblet buys with 60 rocks: exactly 1 succeeded (60 to 10). | state JSON |
| 7 Rebirth | Hidden until payable | Rebirth.Visible false at lifetime 0 and at lifetime about 480. Code shows at gain > brainCells (1e6 lifetime). Payable path not exercised. | client read |
| 8 Pacing | First buy under 10 s, buys in 60 s | NOT VERIFIED as real time. Scripted taps took about 1.5 s per 10 clicks. The run mixed scripted remote calls with real clicks, so no human pacing number. | n/a |
| 9 Captures | 4 states, desktop and phone | Desktop: spawn, affordable, after purchase. Phone: after buy only. Phone spawn and first-taps NOT captured: the simulator can only be set in the Client datamodel mid-play, and a restart would reset state. | 01 to 04 png |

## Look check
| Device | Rubric lines failed | Evidence path |
|---|---|---|
| Desktop (492x464 pane) | Legibility FAIL for row 1 and 2: Studio's own floating capture widget overlaps the list. Not a game bug. Hierarchy FAIL: Snorblet is not visible in the list (row order bug 1). Counter, rock, contrast PASS. | .rbx-studio/evidence/playtest-2026-11-04/01-spawn-desktop.png, 02-afford-bonk-desktop.png, 03-after-purchase-desktop.png |
| iPhone 13 sim (749x388) | Touch target PASS: rock 99 px, rows 56 px high. Text 16 px PASS. Safe area PASS (Counter and panel clear of notch). Upgrade panel shows 3 of 5 rows (181 px tall). Snorblet, Mush Rocket need scroll. FAIL for first-aha visibility. Jump and thumbstick zone clear. | .rbx-studio/evidence/playtest-2026-11-04/04-phone-iphone13-afterbuy.png |

Stills cover layout, legibility, presence. Feel, tap latency, pulse timing and audio are a human check.

Run result: OBSERVED - HUD at desktop and iPhone 13: rock, counter, 5-row upgrade list, Rebirth hidden, Bonk Pick green when affordable - .rbx-studio/evidence/playtest-2026-11-04/02-afford-bonk-desktop.png

## Console errors / warnings (count + top 3)
- 0 script errors from the game.
- 4 warnings: `ContentId: rbxassetid://203785492 failed due to: Asset type does not match requested type` (same line x4). Source not found in src/. Likely a Studio or default-character asset. Owner check needed.
- 1 error was mine (`AssistantCommand:5`, a QA require of Data from the plugin context returned a separate module copy). Not a game bug.

## Perf snapshot (if measured)
| Metric | Value | How |
|---|---|---|
| Frame time, memory | NOT MEASURED | out of scope |

## Bugs found
| # | Severity | Repro | Owner |
|---|---|---|---|
| 1 | High | `Hud.client.luau` line 100: `UIListLayout` has no `SortOrder = LayoutOrder`. Default sorts by Name, so rows show Bonk Pick, Brain Drill, Goo Moon Base, Mush Rocket, Snorblet (measured Y: 86, 148, 210, 272, 334). Snorblet is 5th, off-screen on phone (panel ends y=261). It is the aha purchase at 0:21. The locked 80K Goo Moon Base is third. Fix: add `list.SortOrder = Enum.SortOrder.LayoutOrder`. | client-ui-programmer |
| 2 | Medium | All 5 rows show at 0 s with prices up to 80.00K (first-60 item 2, "progressive rows" still open). | client-ui-programmer |
| 3 | Low | `Mine` remote has no rate limit. 30 calls in one frame all paid (+60 rocks). Auto-clickers or exploiters get unlimited income. `BuyUpgrade` validation is sound. | server-programmer |
| 4 | Low | Passive tick adds floats: lifetime 71.99999999999989, rocks 11.999999999999993. Display floors, so rocks can show one less than expected at the exact buy threshold. | server-programmer |
| 5 | Low | Click through `user_mouse_input` at Bonk Pick center did nothing; click off-center worked. Cause is most likely Studio's capture widget over the pane, UNVERIFIED. Not attributed to the game. | n/a |

## Not verified
- Time to first tap-able rock in real seconds (Hud was present at first read after boot; no stopwatch).
- Real-time pacing: seconds to first purchase and purchases in 60 s.
- Cue timing and feel, tap latency under bad network (first-60 item 8).
- Phone captures at spawn and after first taps.
- Rebirth when payable (needs lifetime 1e6).
- Server values were read from the State snapshot the server pushes, not from the Data table. A direct require from the plugin context returned a separate module copy.
- Gamepad selection on the rock.

## Open questions
- Should the Snorblet row be pinned or scrolled into view once the player can afford it?
- Is `rbxassetid://203785492` from the game or from Studio defaults?
