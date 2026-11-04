# Snorbo's Brain Rock Mine GDD (short)
Date: 2026-11-04 · Version: 0.1 (loop sections only) · Owner: dev

## Core loop
Tap rock -> rocks -> buy Bonk Pick or Snorblet-line helper -> more rocks per tap and per second -> reach Big Brain rebirth -> restart faster with Brain Cells (+10% income each).

## Session plan
| Session | Minutes | Player goal | What brings them back |
|---|---|---|---|
| First | 0:04 Bonk Pick. 0:21 first Snorblet (the aha). 0:53 10 Snorblets, bulk-buy shown. 1:53 first Brain Drill. 5:06 10 Drills. 10 min: Mush Rocket is the next goal on screen. | Reach Brain Drill and see Mush Rocket price | Exit text: "Offline: X/hr, 2 h cap, 50%". Welcome Back 2x |
| Typical (return) | 5 to 10 | Collect offline pile, spend it, push the next tier | D1: banked offline. D7: rebirth gain preview. D30: Brain Cell stacking, lifetime leaderboard (post-v1) |

## Hooks by window (metric that judges each)
| Window | Hook | Metric |
|---|---|---|
| First 60 s | First tap pays, Snorblet at 0:21 | first-play bounce <60 s (target under 40%) |
| 61-180 s | 10 Snorblets at 0:53, Drill at 1:53 | bounce 61-180 s |
| D1 | Offline earnings and Welcome Back 2x | D1 (kill line 15%) |
| D2-7 | Rebirth gain preview at about 31 min of play (post-cut) | D2-7 retention, rebirth rate |
| D8-28 | Brain Cell tiers, Moon 2 (post-cut) | D8-28 retention |

## Progression (sim: greedy buyer, 3 taps/s, `curve.luau`)
| Stage | Time to reach | Unlock | Curve formula |
|---|---|---|---|
| 1 | 0:04 | Bonk Pick | cost = floor(base * 1.15^owned), base 10 |
| 2 | 0:21 | Snorblet | base 50, +1/s |
| 3 | 0:53 | 10 Snorblets | same |
| 4 | 1:53 | Brain Drill | base 600, +8/s |
| 5 | 5:06 | 10 Brain Drills | same |
| 6 | 11:32 | Mush Rocket | base 7000, +47/s |
| 7 | 24:59 | 10 Mush Rockets | same |
| 8 | 30:52 | Rebirth ready | gain = floor(sqrt(lifetime / 1e6)) |
| 9 | 48:12 | Goo Moon Base | base 80000, +260/s |

## Systems, Economy, Social, Tech, Out of scope
Not touched by /rbx-loop. See concept brief and Director call (cuts: rebirth preview, Moon 2, monetization until bounce passes).
