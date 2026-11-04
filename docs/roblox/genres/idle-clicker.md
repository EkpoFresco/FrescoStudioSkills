# Genre: Idle / Incremental / Clicker
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - Roblox lists both "Incremental Simulator" and "Idle" as official Simulation subgenres [1], and 2026 idle hybrids hit the top charts [2][3].
Top Roblox references (mechanics only):
- Sell Lemons (2026): an incremental stall with hired sellers and garage automation that earn offline. Rebirth gives a big boost and unlocks powers such as Remote Buy [4]. Peak about 229K CCU (UNVERIFIED tracker).
- Anime Dice (2026): roll for units, place them on a plot for idle income, upgrade the dice [2].
- Sol's RNG and Fisch: rewarded-video automation and luck boosts, cited in Roblox's own playbook [5].

## Core loop
- Act (click or mine), earn, buy a generator, the generator earns while idle, buy a multiplier, prestige, repeat faster.
- Cost of next unit: `cost = base * r^owned`. AdVenture Capitalist's first generator uses r = 1.07 [6]. Usual range is 1.07-1.15, steeper for later generators (heuristic).
- Production is linear in units owned, times milestone multipliers (example: x2 at 25 and 50 owned) [6].
- Exponential cost always overtakes polynomial income. That crossover is the wall, and prestige is the release valve [6].
- Bulk buy n units: `b * r^k * (r^n - 1) / (r - 1)`. Max affordable: `floor(log_r(c*(r-1)/(b*r^k) + 1))` [6].
- Mining mapping (heuristic): pickaxe = click multiplier, auto-drills = generators, depth layers = generator tiers with new ore value, backpack cap = sell friction that you can pass or upgrade away.

## Prestige math
| Model | Formula (prestige currency p) | Cost to double p |
|---|---|---|
| Cookie Clicker | p = cbrt(lifetime / 1e12) | about 8x lifetime |
| AdVenture Capitalist | p = 150 * sqrt(lifetime / 1e15) | about 3-4x |
| Realm Grinder | p = (sqrt(1 + 8*max/1e12) - 1) / 2 | about 4x |
| Egg, Inc. | delta p = (run / 1e6)^0.14 | about 128x |
All four rows come from [7]. Root curves keep the numbers manageable. Under a sqrt model, resetting at the same point again still pays, but less each time [7].
- Design rule (heuristic): the first prestige should land at 20-40 min of play. Each prestige bonus should cut time-back-to-wall by about 50%+, or players stall.
- Layer it: prestige 1 (rebirth), then a prestige-of-prestige later, like Realm Grinder Reincarnations or AdCap Mega Bucks [7].

## Session one
- 0:00-0:15: the first click pays. The first upgrade is affordable in under 10 seconds (heuristic).
- 1-3 min: the first generator. Income ticks while the player is not clicking. This is the "aha".
- 3-10 min: the first milestone multiplier and the first automation teaser (a paid 10-minute auto-click trial works well) [5].
- 15-30 min: the first wall. Show the prestige preview with an exact gain number.
- Exit: tell the player "offline earnings: X/hr, capped at Yh" so they have a reason to return.

## Retention hooks (D1 / D7 / D30)
- D1: banked offline earnings. Offering 2x on return is Roblox's documented "Welcome Back" placement [5].
- Offline caps: Egg, Inc. caps at 2h, which shifts progress to a sub-prestige loop. Clicker Heroes has no cap [7]. Roblox devs often clamp to 24h and divide the payout (for example /5) [8].
- D7: prestige layers, daily quests, and a time-limited event currency.
- D30: deep prestige trees, collection logs, leaderboards on lifetime totals.

## Monetization norms
- Passes: 2x income, auto-click, offline cap extension, extra slots or drills (heuristic, consistent with [4][5]).
- Rewarded video: velocity boosts, 2x offline, resource refill, 10-minute automation trials. Benchmark: 13%+ opt-in, 2.8 views per day [5].
- Dev products scaled to current income ("1h of earnings") stay relevant at every stage (heuristic).
- Paid random elements such as rolls and luck boosts need odds disclosure [9].

## Number formatting
- Luau numbers are 64-bit doubles: max about 1.7e308, about 15 significant digits [10]. Exact integers stop at 2^53, about 9.0e15 (heuristic, IEEE fact).
- Suffix ladder: K 1e3, M 1e6, B 1e9, T 1e12, Qa 1e15, Qi 1e18, Sx 1e21, Sp 1e24, Oc 1e27, No 1e30, Dc 1e33. Offer a scientific-notation toggle past Dc (heuristic).
- Show 3 significant digits ("12.3M"), and never jitter the width of the counter (heuristic).
- Past 1e308 you need a BigNum module: EternityNum, GammaNum (claims 30-100x faster, disputed), or mantissa-exponent designs [11][12]. Pure-Lua BigNum is slow, so keep it out of per-frame loops [13].
- Rounding bugs are real: one EternityNum user got 0.99 instead of 1, which blocked a purchase [14]. Compare with tolerance.

## Social and discovery levers
- Leaderboards on lifetime earnings and prestige count. Visible auras or titles by prestige tier.
- Co-op boosts (a friend in server = +X% income) feed the intentional co-play signal [15].
- A first-play bounce under 60 seconds is a negative ranking signal, so the first click must pay out immediately [15].

## Technical traps on Roblox
- The server owns the time. Use the server's `os.time()` for offline deltas, and never trust a client clock [8].
- Clicks: the server rate-limits and validates them. Auto-clicker macros are expected, so decide whether to allow or cap them.
- Save as a string or {mantissa, exponent}, not raw doubles near inf (heuristic). 4 MB per key, per-key write throughput limits [16].
- Use ProfileStore session locking. Its default autosave period is 300s, so also save on purchase milestones [17].
- Tick income on the server at 1 Hz and interpolate the counter on the client for smooth display (heuristic).

## What transfers from outside Roblox
- Kongregate-era models and spreadsheets (Pecorella) [6][7].
- Egg, Inc.: the offline cap pushes active play without punishing absence [7].
- Cookie Clicker: steep prestige makes each reset feel earned [7].

## Octalysis read
- CD2 Accomplishment: the dominant drive. Numbers and suffix jumps.
- CD8 Loss and Avoidance: "earnings capped" pulls players back.
- CD3 Empowerment of Creativity: build orders, prestige timing choices.
- CD6 Scarcity: timed boosts and automation trials.

## Sources
[1] Roblox Creator Hub, Experience genres - https://create.roblox.com/docs/production/publishing/experience-genres - checked 2026-11-03
[2] StudioKrew, Top Roblox games September 2026 - https://studiokrew.com/blog/top-roblox-games-september-2026/ - checked 2026-11-03
[3] Roblox Creator Hub, Rewarded video genre guides - https://create.roblox.com/docs/production/rewarded-video-guides - checked 2026-11-03
[4] Pocket Gamer, Sell Lemons guide - https://www.pocketgamer.com/roblox/sell-lemons-guide/ - checked 2026-11-03
[5] Roblox Creator Hub, Rewarded video playbook: Incremental Sim - https://create.roblox.com/docs/production/promotion/rewarded-video-playbooks/incremental-sim - checked 2026-11-03
[6] Pecorella, The Math of Idle Games Part I - https://www.gamedeveloper.com/design/the-math-of-idle-games-part-i - checked 2026-11-03
[7] Pecorella, The Math of Idle Games Part III - https://www.gamedeveloper.com/design/the-math-of-idle-games-part-iii - checked 2026-11-03
[8] DevForum, How do "Steal a" games calculate offline cash - https://devforum.roblox.com/t/how-do-steal-a-games-calculate-offline-cash/3854950 - checked 2026-11-03
[9] Roblox Creator Hub, Paid random items policy - https://create.roblox.com/docs/production/monetization/paid-random-items - checked 2026-11-03
[10] Roblox Creator Hub, Luau numbers - https://create.roblox.com/docs/luau/numbers - checked 2026-11-03
[11] DevForum, How to use EternityNum - https://devforum.roblox.com/t/how-to-use-eternitynum/2853584 - checked 2026-11-03
[12] DevForum, GammaNum - https://devforum.roblox.com/t/gammanum-up-to-100x-faster-than-eternitynum/3906397 - checked 2026-11-03
[13] DevForum, BigNumber module - https://devforum.roblox.com/t/bignumber-scalable-math-system-for-huge-numbers-in-roblox/4039476 - checked 2026-11-03
[14] DevForum, EternityNum issues - https://devforum.roblox.com/t/eternitynum-issues/3925172 - checked 2026-11-03
[15] Roblox Creator Hub, Discovery - https://create.roblox.com/docs/discovery - checked 2026-11-03
[16] Roblox Creator Hub, Data store limits - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits - checked 2026-11-03
[17] DevForum, ProfileStore - https://devforum.roblox.com/t/profilestore/3190543 - checked 2026-11-03
