# First 60 seconds: Snorbo's Brain Rock Mine
Date: 2026-11-04 · Mode: design (no playtest yet) · Genre: idle-clicker
Target: player in control by 5 s, first reward by 20 s, first goal visible by 30 s, first upgrade by 60 s (heuristics). This game tightens it: first upgrade by 10 s (pillar 1).
Basis: concept brief, `curve.luau` sim (greedy buyer, 3 taps/s), `src/client/Hud.client.luau`.

| Second | Player sees | Player does | Feedback | Text on screen (max 4 words) |
|---|---|---|---|---|
| 0-5 | Giant brain rock center-left, glowing gold ring pulsing. Counter shows 0. A hand icon points at the rock. | Taps the rock. | Rock squishes (0.08 s), "+1" floats up, counter ticks, tap sound. | `TAP THE ROCK` |
| 5-20 | Bonk Pick button lights up gold at 10 rocks (about 0:04). Hand icon moves to it. | Taps rock 10 times, buys Bonk Pick. | Rock bursts bigger, "+2" per tap, pick button flashes. Snorblet row appears greyed with price 50. | `BUY BONK PICK` |
| 20-40 | Snorblet row turns gold at 50 rocks (about 0:21). | Buys the first Snorblet. | Snorblet pops onto the rock and digs. Rate label shows "+1/s". Counter climbs with no tapping. This is the aha. | `SNORBLET DIGS FOR YOU` (4 words) |
| 40-60 | Snorblet count climbs. Bulk-buy x10 chip appears near 10 Snorblets (about 0:53). Brain Drill row visible, locked, price 600. | Keeps buying Snorblets, taps when idle. | Each buy: small pop plus counter bump. Drill row shows a progress fill toward 600. | `NEXT: BRAIN DRILL` |

Text budget: one prompt on screen at a time, each removed on the action it teaches. Nothing else in the first 60 s.

## Loading
- ReplicatedFirst loading screen: yes. One LocalScript, one ScreenGui, `IgnoreGuiInset = true`, rock art and title only.
- Preload list: loading art, Hud icons, rock mesh or image, tap sound. Nothing else. Do not preload Workspace.
- Hold: only until `game:IsLoaded()` plus at most 1 s brand beat. Skip button after 5 s.
- Spawn to controllable Hud: 15 s or less on a mid phone (heuristic). Time to spawn on phone: UNMEASURED. Measure in `review`.
- Data load: the Hud shows the rock immediately and applies server state when it arrives. Never block the rock on DataStore.

## Onboarding without text walls
- One gold ring pulse on the rock, one hand arrow. Arrow moves to the next target (Bonk Pick, then Snorblet).
- Prompts are 2-4 words, icon plus label. No modal, no tutorial panel, no shop pop-up.
- Rock tap is the whole control. No movement tutorial, no keyboard hints needed. Rock is a GUI button, so touch, mouse, and gamepad all work (gamepad needs a selection target: check in `review`).
- Returning players (saved `lifetime > 0`): no prompts, show the offline pile instead.
- Tutorial done flag: store in the existing save table so the arrow never replays.

## Bounce risks (<60 s and 61-180 s)
Ranked by bounce risk. Ones found in `src/client/Hud.client.luau` are from reading code, not playing.

1. Rebirth button visible at 0 s (Hud.client.luau, bottom-left, gold, same weight as the rock). Rebirth is cut until bounce passes. A gold button that does nothing competes with the rock and pulls the eye. Hide it until `lifetime` is 1e6 x 0.5 or remove for the test build.
2. Five upgrade rows visible at 0 s in a 30%-wide panel. Brain Drill, Mush Rocket, Goo Moon Base show prices in the thousands before the player owns one rock. This reads as a grind wall. Show rows progressively: next affordable plus one teaser.
3. Rock label is "BONK" with no arrow or pulse in code. Without a cue, a player who lands from a thumbnail of "rock plus Snorblet" may not know the rock is the button. Add the pulse ring and hand.
4. No Snorblet on screen at 0 s. The thumbnail promise is "giant brain rock with one Snorblet on it". If the rock is bare, the first frame does not match what got the click. Show one idle Snorblet on the rock from second 0 (decorative until bought).
5. Upgrade panel overlaps the touch zone on small phones (30% width, 55% height, right side). Check the jump button area and thumb reach in `review`.
6. Gap 0:53 to 1:53 (61-180 s window). The sim shows 10 Snorblets at 0:53, Drill at 1:53, a full minute with the same action. Mitigation: Drill progress fill, a Snorblet milestone (x2 at 10 owned, heuristic) at 0:53 so there is a visible jump. Needs a retention-designer call: the milestone is not in Config yet.
7. Number counter width jitter. Keep a fixed-width counter and 3 significant digits.
8. Tap latency feel. `Mine` fires a RemoteEvent and the counter waits on the server. Predict the +N locally and reconcile on the server tick, or taps feel dead on a bad connection.

## Look check
Phone: not run · Desktop: not run · Rubric lines failed: n/a (design mode)

## Open items for build
- UNVERIFIED: tap-to-upgrade times (0:04, 0:21, 0:53) come from a sim at 3 taps/s. Real new players tap slower. Verify in `review` with simulated input at 1.5 and 3 taps/s.
- Fix list order: 1 (hide Rebirth), 3 (cue), 2 (progressive rows), 4 (starter Snorblet), 8 (local prediction), 6 (milestone).
