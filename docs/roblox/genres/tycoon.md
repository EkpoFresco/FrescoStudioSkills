# Genre: Tycoon
Last checked: 2026-11-03. Sources at bottom.
Roblox fit: strong - Roblox has an official Tycoon subgenre, and the plot-and-dropper loop gives players progress they can see from minute one [1].
Top Roblox references (mechanics only):
- Theme Park Tycoon 2: a sandbox park builder with budget, sanitation, and guest systems, plus global leaderboards and missions [2].
- Restaurant Tycoon 2: serve NPC customers and buy furniture and upgrades to expand [2]. Co-op staff roles are reported (third-party) [3].
- Retail Tycoon 2: buy stock at cost, sell at markup, manage cash flow (third-party) [3].
- Sell Lemons (2026): an idle-tycoon hybrid with a lemon stall, hired sellers for automation, and rebirth for boosts [4][5].

## Core loop
- Claim a plot, droppers produce, conveyors carry, a collector converts to cash, buy the next button, the base grows (heuristic) [1].
- Modern variants add employees (automation), multiple resource chains, prestige, and sometimes PvP raids [3].
- The design weight sits on the upgrade tree. Its order sets the pacing and the session length (heuristic).

## Session one
- 0:00-0:20: auto-assign a plot, or put the claim pad right at spawn. No lobby menu (heuristic).
- 0:20-2:00: the first 3-5 buttons cost seconds of income. Each one adds something physical to the base.
- 2-10 min: the first wall that teaches "collect, then buy". Introduce automation (auto-collect) here as earned or paid.
- 10-25 min: the base fills a whole floor. Show a rebirth or next-floor preview. Neighbors' bigger bases create aspiration.
- Exit hook: offline earnings, plus "your base keeps earning" text on leave [4].

## Retention hooks (D1 / D7 / D30)
- D1: offline earnings banked on return. Offering 2x on return through rewarded video is a documented placement [6].
- D7: a rebirth ladder with cosmetic base themes per tier. Weekly content drops such as new floors or a new resource chain.
- D30: persistent bases and decoration ownership. Third-party claim: persistent-world tycoons retain better than session-reset ones (UNVERIFIED) [3].
- The 28-day Home signals reward games people return to for weeks [7].

## Monetization norms
- Passes: 2x cash, auto-collect, extra droppers or exclusive upgraders, a VIP area, faster walk speed (vendor-sourced norms, prices UNVERIFIED) [8].
- Dev products: cash injections scaled to the player's current income (sell "10 minutes of income", not a fixed amount) (heuristic).
- Rewarded video for tycoons: time skip (2x offline), progressive reward chains, progression accelerators. Benchmark: 15%+ opt-in, 3+ views per day. Put the prompt in high-traffic UI, not three menus deep [6].
- Subscriptions fit "daily cash stipend" and VIP perks. Local-currency tiers run $2.99-$14.99, and mutually exclusive tiers are not supported [9].
- Players accept speed and convenience passes. They resent a progression that hard-walls without a pass (heuristic).

## Social and discovery levers
- Shared-map plots create ambient comparison without forced PvP [3].
- "Build the ultimate X in 24 hours" creator videos drive spikes (third-party claim) [3].
- Two-player and co-op tycoons create intentional co-play days, which is a ranking signal [10].
- Fresh theme on a proven loop (space, AI lab, food) is the main differentiation lever [3].

## Technical traps on Roblox
- Physical droppers mean thousands of unanchored parts and a physics cost. Simulate drops as values on the server, and render the visuals client-side only (heuristic).
- Collector touch events can be spoofed. Validate on the server with a rate cap.
- Purchase buttons: server-check cost and order. Never trust the client's "I bought button 12".
- Save the base as compact IDs plus levels, not instance trees. Stay under the 4 MB per-key limit [11].
- Plot streaming: enable StreamingEnabled and keep other plots low-detail for mobile (heuristic).
- Offline earnings: compute with the server's os.time() delta, clamp it (24h cap is common), and often scale it down [12].

## What transfers from outside Roblox
- RollerCoaster Tycoon and Theme Hospital: guest needs and flow make depth beyond the dropper (Theme Park Tycoon 2 is compared to RCT) [2].
- Mobile idle tycoons (AdVenture Capitalist style): manager automation, then prestige [13].
- Factory games: multi-step chains reward planning, and planning is retention (heuristic).

## Octalysis read
- CD2 Accomplishment: the base gets bigger, which you can see.
- CD4 Ownership: "my plot" with decoration and identity.
- CD5 Social Influence: neighbors' bases are the aspiration display.
- CD3 Creativity (in sandbox tycoons): layout choices.

## Sources
[1] Roblox Creator Hub, Experience genres - https://create.roblox.com/docs/production/publishing/experience-genres - checked 2026-11-03
[2] Wikipedia, List of Roblox games (redirect target) - https://en.wikipedia.org/wiki/Tower_of_Hell - checked 2026-11-03
[3] RoWatcher, Tycoon Games (third-party, no methodology) - https://rowatcher.com/news/tycoon-games-the-genre-that-built-roblox-and-still-hasn-t-peaked - checked 2026-11-03
[4] Pocket Gamer, Sell Lemons guide - https://www.pocketgamer.com/roblox/sell-lemons-guide/ - checked 2026-11-03
[5] StudioKrew, Top Roblox games September 2026 - https://studiokrew.com/blog/top-roblox-games-september-2026/ - checked 2026-11-03
[6] Roblox Creator Hub, Rewarded video playbook: Tycoon - https://create.roblox.com/docs/production/promotion/rewarded-video-playbooks/tycoon - checked 2026-11-03
[7] Roblox Newsroom, Optimizing discovery (2026-06-15) - https://about.roblox.com/newsroom/2026/06/optimizing-discovery-great-games-reach-millions-players-roblox - checked 2026-11-03
[8] creation.dev, How to make a tycoon (vendor) - https://www.creation.dev/learn/how-to-make-tycoon-roblox - checked 2026-11-03
[9] Roblox Creator Hub, Subscriptions - https://create.roblox.com/docs/production/monetization/subscriptions - checked 2026-11-03
[10] Roblox Creator Hub, Discovery - https://create.roblox.com/docs/discovery - checked 2026-11-03
[11] Roblox Creator Hub, Data store limits - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits - checked 2026-11-03
[12] DevForum, How do "Steal a" games calculate offline cash - https://devforum.roblox.com/t/how-do-steal-a-games-calculate-offline-cash/3854950 - checked 2026-11-03
[13] Pecorella, The Math of Idle Games Part I - https://www.gamedeveloper.com/design/the-math-of-idle-games-part-i - checked 2026-11-03
