# Monetization sheet: Snorbo's Brain Rock Mine
Style: light · Date: 2026-11-04 · Status: DESIGN ONLY. Ships after bounce passes (director cut, decisions.md 2026-11-04).
Rule: retention first. Monetize what players already love doing: banked offline pile and faster rocks.

## Offers
| Offer | Type | Price (R$) | Value to player | Placement (after which action) | Policy flags |
|---|---|---|---|---|---|
| Rock Rush | product | 25 | 2x rocks for 10 min (stacks time, not power) | After the first Brain Drill buy (about 1:53), as a small button, never a popup | none |
| Big Sack | pass | 99 | Offline cap 2 h -> 6 h | On the Welcome Back screen, when the pile hit the 2 h cap | none |
| Double Rocks | pass | 249 | Permanent 2x income | Shop tab only, plus a line after the first rebirth (post-cut) | none |
| Welcome Back 2x via rewarded ad | ad reward | free | Doubles the offline pile once per return | Welcome Back screen | Not shown to under-13s. UNVERIFIED: ad format eligibility for a new game. Skip in v1 |

Not offered: auto-tap (breaks pillar 1, the tap is the fun), paid random items (none, no odds work), trading, limited-time timers.

## Price ladder
Starter 25 (Rock Rush) · Core 99, 249 (Big Sack, Double Rocks) · Whale none in v1 · Sub none. Read live prices with GetProductInfoAsync; show them in the UI, never hardcode. Prices are first guesses. Test Double Rocks 249 vs 199 with Experiments (one price that matters most; judge by buyers per 100 D1 players, not revenue per buyer).

## Economy (sim base: curve.luau, greedy buyer, 3 taps/s)
| Stage (time) | Income /s (approx) | Rock Rush adds | Big Sack adds |
|---|---|---|---|
| 5:06, 10 Drills | about 90 + taps | doubles 10 min, saves about 5 min of play | cap not hit |
| 11:32, Mush Rocket | about 150 | same | 2 h cap at 50% = about 540k banked max, 6 h = about 1.6M |
| 30:52, rebirth ready | about 700 | 1M lifetime in about 10 min of Rush | pile near rebirth gain |
| Faucet | Rate | Sink | Rate | Net per 10 min |
| Taps + helpers | 3 taps/s + sum(perSecond) | Upgrades at 1.15^n | greedy buyer spends all | all income reinvested |

Check: Rush at 2x for 10 min saves under 10 min of progress at every stage, so it speeds the player and never gates them. Run `lune run` on a copy of curve.luau with a 2x window to confirm before build (Lune not run in this pass: UNVERIFIED numbers above are hand estimates).

Stacking rule (decide now, log it): Rush and Double Rocks add (1 + 1 + 1 = 3x), not multiply (4x). Keeps late income predictable. Brain Cells stay multiplicative as built in `Economy.multiplier`.

## Experiments plan
One test: Double Rocks at 199 vs 249. Split by UserId. Success = buyers per 100 players who reach 10 min, with D1 not lower in the 249 arm. Start after 250 RFY plays and first D1 reading.

## Policy check (from library/roblox/policy.md, checked 2026-11-03)
- [x] Paid random items: none offered, no odds needed
- [x] PolicyService gates: not needed with no paid random items or trading
- [x] No fake or restarting timers: Rush adds real minutes, countdown shows true BoostEnds
- [x] No urgency copy: no "last chance", no sale timers
- [x] No playable gambling
- [x] Rewarded ads not shown to under-13s: ad offer deferred; gate by age bracket before adding
- [ ] Grants only in the receipt handler: Rock Rush yes. Passes not built yet (see code check)
- [x] Cross-game selling and donations: not used
Result: PASS (design). Ads row stays UNVERIFIED until eligibility is read in Creator Hub.

## Code check (review of src/)
- BLOCKER for launch of Rock Rush: `Config.Products.RockRush.productId = 0` (src/shared/Config.luau:41). Create the product, paste the id.
- MAJOR: no purchase prompt exists. `PromptProductPurchase` and `PromptGamePassPurchase` are not called anywhere; the shop UI and a server-validated prompt remote are missing.
- MAJOR: no gamepass path. Needs `UserOwnsGamePassAsync` on join (cache in profile session), `PromptGamePassPurchaseFinished` for live grant, and Big Sack must feed `Config.OfflineCapSeconds` per player in the offline calc (Game.server.luau:103).
- MINOR: unknown ProductId returns NotProcessedYet forever (Game.server.luau:192). Fine now, but it retries on every join. Fine while only one product exists.
- OK: one receipt handler (Game.server.luau:179), PurchaseId stored in the session profile (Data.luau:129-136), saved before PurchaseGranted.
- OK: boost expiry is server time (`BoostEnds`), pushed to the client.
