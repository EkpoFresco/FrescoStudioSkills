# Genre: Racing and Driving (racing, driving sims, car culture)
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: medium - car culture and open-world driving hold steady audiences, but vehicle netcode is hard; NASCAR + Driving Empire won Best Racing 2025 [1].
Top Roblox references (mechanics only):
- Driving Empire (Voldex, 2019): 200+ cars and boats, races, licensed brands, events; tracker peak 90K (Aug 2026) [2].
- Car Dealership Tycoon (Foxzie's, 2018): earn by driving and racing, display cars at your dealership, cosmetic tuning [3].
- Jailbreak (2017): cops vs robbers with vehicle chases; 8B visits by Oct 2026 [4].
- A Dusty Trip (Feb 2024): co-op road trip, repair and drive through hostile desert, up to 25 players per server [5].

## Core loop
- Drive or race, earn cash, buy or upgrade cars, show them off, repeat.
- Collection is the long game; racing is the earning verb (heuristic).
- Variant: road-trip survival (A Dusty Trip) mixes driving with scavenging [5].

## Session one
- 0 to 1 min: spawn next to a free starter car; driving starts in under 30 seconds (heuristic).
- 1 to 5 min: first race or delivery job pays enough for a visible upgrade (heuristic).
- 5 to 15 min: dealership browse; see a dream car with a price goal.
- Codes and group bonuses as early cash (Driving Empire: 15% cash bonus for group members) [2].

## Retention hooks (D1 / D7 / D30)
- D1: next car purchase, daily races.
- D7: limited-time cars, events, licensed collabs [1][2].
- D30: full garage collection, rare and retired cars, leaderboards for time trials.
- Weekly updates are common in car tycoons [3].

## Monetization norms
- Car packs, 2x money passes, VIP passes (Car Dealership Tycoon reported) UNVERIFIED specifics [3].
- Exclusive Robux-only cars and limited event cars (heuristic).
- Cosmetics: wraps, rims, underglow, horns.
- Driving Empire estimated about $289K per month (tracker model, low confidence) [2].

## Social and discovery levers
- Meetups and car shows in public servers; private servers for crews (heuristic).
- Licensed car brands and real-world collabs drive press [1][2].
- Leaderboards; docs suggest keeping low-trust devices off leaderboards [6].

## Technical traps on Roblox
- Give network ownership to the driver; passenger-first seating otherwise steals ownership and adds input lag [7].
- Assign loose parts on the car to the same client [7].
- Other players' cars jitter at speed; ownership and seat welds are the usual suspects [8].
- Server Authority beta does not forward other players' inputs by default, so rival cars render behind; store inputs in attributes (Racing template) [9].
- Under Server Authority, vehicle quantization causes some drift in constraints [10].
- Fast assemblies run on the 240 Hz solver island, raising physics cost [11].
- Client-owned cars can teleport; validate checkpoints and lap times with a fastest-possible-time heuristic [12][13].
- Big maps: StreamingEnabled and road-side LOD for mobile (heuristic).
- VehicleSeat plus VehicleController handle basic throttle and steer; most top games use custom chassis (heuristic) [14].

## What transfers from outside Roblox
- Forza Horizon: open world festival, car collection, cosmetic tuning.
- Mario Kart: catch-up items, short tracks, party fun.
- Need for Speed: cops, heat level, chases (Jailbreak pattern).
- Gran Turismo: licenses as onboarding.

## Octalysis read
- Ownership (CD4): the garage.
- Accomplishment (CD2): race wins, times.
- Social Influence (CD5): showing cars off.
- Scarcity (CD6): limited and event cars.

## Sources
[1] Roblox reveals 2025 Innovation Awards winners (PocketGamer.biz) - http://www.pocketgamer.biz/roblox-reveals-2025-innovation-awards-winners/ - checked 2026-11-03
[2] Driving Empire stats (RoWatcher) - https://rowatcher.com/games/1202096104 - checked 2026-11-03
[3] Car Dealership Tycoon codes (TheGamer) - https://www.thegamer.com/roblox-car-dealership-tycoon-codes/ - checked 2026-11-03
[4] List of Roblox games (Wikipedia) - https://en.wikipedia.org/wiki/List_of_Roblox_games - checked 2026-11-03
[5] a dusty trip [HARDCORE] stats (RoWatcher) - https://rowatcher.com/games/5650396773/a-dusty-trip-hardcore - checked 2026-11-03
[6] Device trust (Roblox Docs) - https://create.roblox.com/docs/scripting/security/device-trust - checked 2026-11-03
[7] Network ownership (Roblox Docs) - https://create.roblox.com/docs/physics/network-ownership - checked 2026-11-03
[8] Cars jittering when driving at high speed (DevForum) - https://devforum.roblox.com/t/cars-jittering-when-driving-at-high-speed/4068444 - checked 2026-11-03
[9] Server authority techniques (Roblox Docs) - https://create.roblox.com/docs/projects/server-authority/techniques - checked 2026-11-03
[10] Server Authority tech deep dive (DevForum, 2026-05-08) - https://devforum.roblox.com/t/server-authority-tech-deep-dive-engineering-insights/4624565 - checked 2026-11-03
[11] Adaptive timestepping (Roblox Docs) - https://create.roblox.com/docs/physics/adaptive-timestepping - checked 2026-11-03
[12] Network ownership, movement validation, and physics (Roblox Docs) - https://create.roblox.com/docs/scripting/security/network-ownership - checked 2026-11-03
[13] Server-side detection and consequencing (Roblox Docs) - https://create.roblox.com/docs/scripting/security/server-side-detection - checked 2026-11-03
[14] VehicleController (Roblox Docs) - https://create.roblox.com/docs/reference/engine/classes/VehicleController - checked 2026-11-03
