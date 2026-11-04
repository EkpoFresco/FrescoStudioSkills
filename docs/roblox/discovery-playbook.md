# Roblox Discovery Playbook

Last checked: 2026-11-03. Sources at bottom.

What to do, phase by phase, to earn Home recommendations. Read `discovery-algorithm.md` first for the mechanics. For third-party trackers, CCU history and genre market sizing, see `market-data.md`. This file does not duplicate either.

## TL;DR for agents

- Core rule: attract the right players, then keep them. RFY ranks on PTR plus first-play bounce, then per-user play days, playtime, co-play and spend over D1, D2-7 and D8-28. All of it is measured only on players who came organically from RFY [1][2].
- Fix the first 3 minutes before buying traffic. Bounce under 60s and at 61-180s are "most important" negative signals [1]. Roblox's guidance: get players to the fun "in 5 minutes or less" [7].
- Retention first, then monetization. "If retention is low, focus on core gameplay first. Once retention is strong, improving monetization can help" [2].
- Plan the audience gate. New games reach only age-checked 16+ users until they pass Kids and Select evaluation (250 highly engaged plays in 60 days, with a drop to 100 planned for November 2026) [3][4].
- Ads buy retrieval, not ranking. Ad users are excluded from RFY signals, and RFY impressions can dip after ads without it being a penalty [2][5].
- Always run thumbnail personalization (2-5 thumbnails active) and upload an authentic gameplay video [6][8].
- Social is a ranked signal. Intentional co-play days count joins, invites, private servers and reserved servers [1][9].
- Judge changes on Roblox's dashboard against "similar games" benchmarks. A healthy metric sits at or above the 50th percentile, and a strong one near the 90th. Benchmarks never affect ranking [10][11].
- Note the 2026-10-12 measurement change: impressions went up and PTR dipped slightly for every game at once. Do not read that as a regression [12].

## Phase 1: Pre-launch

| Phase | Action | Why (signal it moves) | Metric to watch | Where |
|---|---|---|---|---|
| Pre-launch | Pick the final genre and subgenre carefully. You can only change it once every 3 months | Correct genre Charts sorts. Accurate tags reduce bounce [13][2] | First-play bounce | Creator Dashboard > game > Overview > Genre (Basic settings) |
| Pre-launch | Write a title with no giveaway or "Robux" framing, and keep it unique (no clone naming) | Avoids reduced exposure. Protects PTR quality [1] | Reduced-exposure banner absent | Creator Dashboard > game > Overview (banner) |
| Pre-launch | Description: first ~160 chars give the hook, genre and unique feature. Relevant keywords only, no repetition. No hashtags (unused in ranking) | Search relevance. Avoids keyword-spam demotion [14][15] | Search plays (Acquisition by source) | Configure > Basic settings > Description |
| Pre-launch | Make 3-5 custom 16:9 thumbnails (1920x1080) showing real gameplay. No key text at the bottom | A custom thumbnail is required for RFY. Raises PTR from fitting players [1][6] | Thumbnail Performance table | Configurations > Places > start place > Thumbnails > Home Page tab |
| Pre-launch | Make an icon (512x512) that reads at 150x150 and signals genre and tone | PTR on icon surfaces (Continue, Search) [16] | PTR by source | Configurations > Places > start place > Icon |
| Pre-launch | Record a gameplay video: real, current gameplay, no narration, no promo text, no lyrical music | RFY hover video raised RFY playtime up to +39% in tests. Sets the right expectations, so lower bounce [8][6] | Video approval, RFY playtime | Configurations > Places > Videos (3 uploads per month) |
| Pre-launch | Complete the full Maturity and Compliance questionnaire (aim for Minimal, Mild or Moderate if the content allows) | Decides which age groups the game is recommended to [17] | Content rating shown | Publish settings > Content rating |
| Pre-launch | Meet the all-ages requirements: ID or facial age estimation, 2SV, a Plus/Premium subscription for 2+ months or the refundable fee | Needed to ever reach under-16 users [3] | Eligibility status | create.roblox.com/settings/eligibility/publishing-permissions |
| Pre-launch | Test the first-time experience with up to 10 similar-aged friends, or run an Experience Beta (hidden from RFY and search) | Finds bounce causes without polluting RFY signals [18][19] | Session length in beta analytics | Publish flow > Invite early testers. Experience Betas |
| Pre-launch | Instrument onboarding funnel events | Diagnoses the <60s and 61-180s bounce [1] | Funnel step drop-off | Analytics > Funnels (custom funnel events) |
| Pre-launch | Build social hooks: invite prompts with launch data, a friend referral reward, "spawn with friends", free or cheap private servers | Intentional co-play days [1][20] | Co-play days per user (Home Recommendations tab) | Studio code. Audience > Access Settings > Allow private servers |
| Pre-launch | Add a notification opt-in prompt at a natural moment (13+ only, shown at most once every 30 days) | Return visits, so play days D2-7 and D8-28 [21] | Opt-in reach, notification visit rate | Creator Dashboard > game > Notifications analytics |
| Pre-launch | Plan your Kids and Select route: organic HEP plays, an Ads Manager Engagement campaign, or expedited review (50,000 Robux refundable, up to 48h) for a timed launch | Unlocks the under-16 audience [3][4] | Highly engaged player count | Creator Hub > game > Audience Reach |
| Pre-launch | Leave "Exclude from recommendations" OFF | Otherwise there are no RFY impressions at all [18] | RFY impressions above 0 | Configure > Recommendations section |

## Phase 2: Launch week

| Phase | Action | Why (signal it moves) | Metric to watch | Where |
|---|---|---|---|---|
| Launch | Seed traffic from any source: community, share links, friends, a small Plays campaign | Retrieval needs only "a very low minimum number of plays from any source" [2] | New users by source | Analytics > Acquisition |
| Launch | Use a separate share link per channel (YouTube, Discord, X) with launch data perks | Off-platform acquisition plus Creator Rewards Audience Expansion (35% of a new or reactivated user's first $100 over 60 days, if the game averages 100+ DAU) [22][23] | Link visits, signups, D7 by link | Creations > Share Links tab. Analytics Home > Share Links |
| Launch | Run an Ads Manager Plays campaign for 3-5 days before judging it | Builds the initial traffic Roblox says can get the game considered for RFY. Does not affect ranking [5] | CPP, plays, playtime per ad user | Ads Manager (advertise.roblox.com) > campaign reporting |
| Launch | If you are targeting under-16s, run a dedicated Engagement-objective budget. Pause it manually at the threshold | Highly engaged plays toward Kids and Select. It does not auto-pause [5] | HEP progress (updates hourly) | Ads Manager. Audience Reach |
| Launch | Activate thumbnail personalization with at least 2 active thumbnails and leave it running | Optimizes qualified plays per user group (+8.5% average in testing) [6] | Qualified PTR per thumbnail, winning segment | Thumbnails > Home Page tab > Edit active thumbnails > Start |
| Launch | Read the Home Recommendations tab daily. Impressions lag signal changes by a few days | Early PTR and bounce decide the next explore round [1][24] | PTR, bounce <60s and 61-180s, D1 play days | Analytics > Acquisition > Home Recommendations |
| Launch | Hotfix the first-session flow fast if bounce is high. Then wait, because the system re-tests daily and early failure carries no penalty | Bounce, PTR [2] | Bounce trend | Home Recommendations tab. Funnels |
| Launch | Expect PTR to dip as impressions spike. Do not panic-change the creatives | Normal during explore, and it "should stabilize" [1] | PTR after impressions plateau | Home Recommendations tab |
| Launch | Create a launch event (up to 10 events). Push "Notify Me" to reach 1,000+ RSVPs | Charts "Trending Events" eligibility. Event start notifications [25] | RSVPs, event joins | Creator Dashboard > Events and Updates |
| Launch | Submit the event for off-platform featuring at least 7 days before it starts | App Store, Google Play and Roblox marketing placements [25] | Post-event featuring report | Events > featuring submission |
| Launch | Nominate the game for Standout Games if it is genuinely novel (new mechanic, style or underrepresented genre). Include a gameplay video | Curated Home exposure, separate from organic ranking [26][8] | Acquisition source (curation) | Standout Games nomination survey (creator-programs page) |

## Phase 3: Scale

| Phase | Action | Why (signal it moves) | Metric to watch | Where |
|---|---|---|---|---|
| Scale | Ship small updates every 2-4 weeks and feature updates every 2-3 months | Roblox re-explores after updates. Content keeps D8-28 play days up [1][7] | Impressions spike after the update, then the new baseline | Home Recommendations tab. Overview |
| Scale | Refresh 2-3 thumbnails with each major update. Keep the older winners active | Prevents creative fatigue. Personalization adapts to trends [6] | Qualified PTR by thumbnail | Thumbnails > Home Page tab |
| Scale | Post update announcements (60 chars, at most once every 3 days). Do not over-post | Brings back followers, so play days. Too many posts raise unfollows [25] | Views, visit rate, unfollow rate | Events and Updates > Update announcements |
| Scale | Send personalized experience notifications (friend beat your score, energy refilled). Never generic ads | Return visits, so D2-7 and D8-28 play days [21] | Notification visit rate | Open Cloud notifications API. Notifications analytics |
| Scale | Add monetization only after retention is at benchmark: passes, subscriptions, starter packs. Test pricing with Experiments | Spend days and Robux spent per user. Games strong in both retention and spend get broader reach [2][27] | Payer conversion, ARPPU, ARPDAU vs benchmark | Analytics > Monetization. Experiments page |
| Scale | Use Experiments (14-60 days, 50/50 on a large rollout) for onboarding, progression and shop changes | Causal readout on D1, D7, playtime, ARPU before rolling out [27] | Goal metric vs minimum detectable effect | Creator Dashboard > game > Experiments |
| Scale | Deepen co-play: party features, group goals, friend invite rewards, reserved servers for parties | Intentional co-play days [1][9] | Co-play days D1, D2-7, D8-28 | Home Recommendations tab |
| Scale | Ads budget logic: keep Plays running only while ad users' D7 and playtime are near organic levels. Add Lapsed Players (needs 20K+ lapsed) and Recent Players (needs 10K+) audiences as you grow. Use Earnings only with a mature economy | Incremental users and reactivation. RFY impressions may dip and that is not a penalty [5][2] | CPP, ROAS, D7 by Resurrected and New views | Ads Manager reporting (All, New, Recent, Resurrected) |
| Scale | Search ads on up to 10 tightly relevant keywords. Use one keyword per ad set for clean reads | Relevance-weighted auction. Irrelevant keywords get optimized away [28] | Clicks, plays per ad set | Ads Manager > Visits > Search Experience |
| Scale | Run recurring events (weekly or seasonal) with a unique event thumbnail | RSVPs to Trending Events, notifications, play days [25] | RSVPs, D7 for event cohorts | Events and Updates |
| Scale | Watch seasonality: Saturday peaks, summer, back-to-school, holidays | Impressions move with Home traffic, not just with your game [1] | Week-over-week impressions vs the same weekday | Overview. Home Recommendations |
| Scale | Watch competitors in your benchmark set. They can take impressions even when your signals hold | Relative performance factor [1][2] | Similar-games list on the Home Recommendations tab | Bottom of the Home Recommendations tab. See `market-data.md` for external tracking |
| Scale | Localize the title, description and in-game text | Wider cohort fit for explore and expand [1] | New users by country | Analytics breakdown by Country and Language |
| Scale | Set analytics alerts on DAU, PTR and revenue | Catch regressions within a day [10] | Alert triggers | Analytics > Alerts |

## Thumbnail and icon testing cadence

- Always keep 2-5 Home thumbnails active. Personalization does the A/B test for you and optimizes qualified plays per user group [6].
- Add new thumbnails in batches with each major update. Let them run until the Thumbnail Performance table stabilizes, which takes at least a few days of impressions. Retire only clear losers [6].
- There is no icon A/B tool, and only one icon is allowed per locale [16]. If you test icons, swap one icon at a time for a full week (Saturday to Saturday) and compare PTR from Continue and Search. Treat the result as directional only, because seasonality confounds it. This method is UNVERIFIED and is not Roblox guidance. To verify, ask Roblox staff whether an icon test tool is planned.
- Experiments cannot test thumbnails or icons. They test in-game configs and matchmaking only [27].
- Judge creatives on qualified PTR, then on the bounce and D1 of that cohort. Never on clicks alone [1][6].

## Reading the dashboard

Eligibility: all KPIs unlock after more than 10 DAU and 10 play hours for 7 consecutive days. Benchmark scorecards need 100+ DAU [10][11].

| Page (Creator Dashboard > game > Analytics) | What it shows | Use it for |
|---|---|---|
| Overview | Insights, benchmark scorecards, retention by source, signal summary | Weekly health check [11][29] |
| Acquisition (Overview, Home Recommendations, Share Links) | Impressions and plays by source. PTR. RFY signals vs benchmark. Similar games. "Not interested" stats | Discovery diagnosis [24][30] |
| Retention | D1, D7, D30 cohorts. Breakdown by source. 7D and 30D down-funnel revenue | Is the game sticky, and for which source [7][29] |
| Engagement | Average session time, playtime, DAU and MAU | Depth of play [11] |
| Monetization (plus Creator Rewards) | Payer conversion, ARPPU, ARPDAU, revenue, rewards | Spend signals [10][22] |
| Funnels | Custom funnel events | Find where onboarding loses players [11] |
| Economy | Economy events (sources and sinks) | Currency balance [10] |
| Demographics | Age (age-checked groups), gender, country, language | Audience fit, Kids and Select mix [10][31] |
| Feedback | Ratings and comments | Sentiment [10] |
| Explore, Custom dashboards, Alerts | Custom charts with benchmark overlays, shared views, threshold alerts | Ongoing monitoring [10] |
| Experiments | A/B results | Causal tests [27] |
| Audience Reach | Highly engaged player progress toward Kids and Select | Audience gate [3] |

Benchmarks (from Roblox):
- Peer set, in order: games with similar players, then genre, then all experiences. You can switch between similar and genre on Overview. Benchmarks update daily [10][29].
- Benchmarked KPIs: all retention KPIs, average session time, ARPPU, ARPDAU, payer conversion, PTR [10].
- Display: 50th to 90th percentile band. Scale KPIs use Top 200, 500 and 1000 tiers drawn from the top 1000 games by 30-day playtime [10].
- Roblox publishes NO fixed numeric targets. The D1 example in the docs (12.11% to 18.73%) is illustrative only [10]. The Benchmarks API (experimental) returns your peer percentiles programmatically [32].

| Status | Rule of thumb (based on Roblox's percentile bands) |
|---|---|
| Healthy | At or above the 50th percentile of similar games on D1 and session time. Roblox says to reach "comparable to or above" before driving traffic [11] |
| Strong | Near or above the 90th percentile. Expect expand phases |
| Warning | Below the 50th percentile on D1 or session time. Fix onboarding before buying ads [11] |
| Warning | RFY impressions falling after drops in PTR, play days or playtime, or a rise in bounce. Roblox says this is the typical order [1] |
| Not a warning | A PTR dip during an impression spike [1]. An RFY dip after ads [2]. A small PTR drop after 2026-10-12 [12] |
| Red flag | Reduced-exposure banner, or a low-quality notice. Fix the metadata and wait for reassessment [1][2] |

Third-party benchmarks and external CCU tracking: see `market-data.md`.

## UNVERIFIED and open items

- Icon testing method (above) is a practitioner workaround, not Roblox guidance.
- The planned November 2026 HEP threshold of 100 may not be live yet. Check Audience Reach.
- Whether thumbnail personalization now optimizes PTR instead of QPTR. Check the Home Page tab columns [6].
- Exact dashboard tab names vary by rollout. Some (Economy, Feedback, Explore) are documented, but their menu placement was not confirmed in a live dashboard. To verify, open the Analytics left navigation of a live game.

## Sources

[1] Discovery (Creator Hub docs) - https://create.roblox.com/docs/discovery - checked 2026-11-03
[2] Discovery FAQ (Creator Hub docs) - https://create.roblox.com/docs/discovery-faq - checked 2026-11-03
[3] Roblox Kids and Select (Creator Hub docs) - https://create.roblox.com/docs/production/publishing/kids-and-select - checked 2026-11-03
[4] Making Publishing Easier: Our Vision and What's Coming (DevForum, 2026-09-11) - https://devforum.roblox.com/t/making-publishing-easier-our-vision-and-whats-coming/4865780 - checked 2026-11-03
[5] Ads Manager (Creator Hub docs) - https://create.roblox.com/docs/production/promotion/ads-manager - checked 2026-11-03
[6] Thumbnails (Creator Hub docs) - https://create.roblox.com/docs/production/publishing/thumbnails - checked 2026-11-03
[7] Retention (Creator Hub analytics docs) - https://create.roblox.com/docs/production/analytics/retention - checked 2026-11-03
[8] How we are improving Home this year (DevForum, 2026-03-09, updates to 2026-07-29) - https://devforum.roblox.com/t/how-we-are-improving-home-this-year/4502571 - checked 2026-11-03
[9] Weekly Recap: December 8 - December 12, 2025 (DevForum) - https://devforum.roblox.com/t/weekly-recap-december-8-december-12-2025/4147197 - checked 2026-11-03
[10] Analytics dashboard (Creator Hub docs) - https://create.roblox.com/docs/production/analytics/analytics-dashboard - checked 2026-11-03
[11] Analytics overview (Creator Hub docs) - https://create.roblox.com/docs/production/analytics - checked 2026-11-03
[12] Improved Discovery Measurement in Creator Analytics (DevForum, 2026-10-12) - https://devforum.roblox.com/t/improved-discovery-measurement-in-creator-analytics/4930122 - checked 2026-11-03
[13] Genres (Creator Hub docs) - https://create.roblox.com/docs/production/publishing/experience-genres - checked 2026-11-03
[14] Create and publish games and places (Creator Hub docs) - https://create.roblox.com/docs/production/publishing/publish-games-and-places - checked 2026-11-03
[15] Game descriptions (experimental, Creator Hub docs) - https://create.roblox.com/docs/production/publishing/descriptions - checked 2026-11-03
[16] Icons (Creator Hub docs) - https://create.roblox.com/docs/production/publishing/experience-icons - checked 2026-11-03
[17] Content maturity and compliance (Creator Hub docs) - https://create.roblox.com/docs/production/promotion/content-maturity - checked 2026-11-03
[18] Create and publish games and places: early testers, Exclude from recommendations (Creator Hub docs) - https://create.roblox.com/docs/production/publishing/publish-games-and-places - checked 2026-11-03
[19] Weekly Recap Dec 8-12, 2025: Experience Betas (DevForum) - https://devforum.roblox.com/t/weekly-recap-december-8-december-12-2025/4147197 - checked 2026-11-03
[20] Player invite prompts (Creator Hub docs) - https://create.roblox.com/docs/production/promotion/invite-prompts - checked 2026-11-03
[21] Experience notifications (Creator Hub docs) - https://create.roblox.com/docs/production/promotion/experience-notifications - checked 2026-11-03
[22] Creator Rewards (Creator Hub docs) - https://create.roblox.com/docs/creator-rewards - checked 2026-11-03
[23] Share links (Creator Hub docs) - https://create.roblox.com/docs/production/promotion/share-links - checked 2026-11-03
[24] Boost Your Discovery with the Improved RFY Algorithm and Analytics for Creators (DevForum, 2025-03-31, updated 2025-12-11) - https://devforum.roblox.com/t/boost-your-discovery-with-the-improved-recommended-for-you-algorithm-and-analytics-for-creators/3587441 - checked 2026-11-03
[25] Experience events (Creator Hub docs) - https://create.roblox.com/docs/production/promotion/experience-events - checked 2026-11-03
[26] Standout Games (Creator Hub docs) - https://create.roblox.com/docs/creator-programs/standout-games - checked 2026-11-03
[27] Experiments (Creator Hub docs) - https://create.roblox.com/docs/production/experiments - checked 2026-11-03
[28] Search ads (Creator Hub docs) - https://create.roblox.com/docs/production/promotion/search-ads - checked 2026-11-03
[29] Analytics: View retention by acquisition source and select your benchmark set (DevForum, 2025-10-16) - https://devforum.roblox.com/t/analytics-view-retention-by-acquisition-source-and-select-your-benchmark-set/4010157 - checked 2026-11-03
[30] Acquisition (Creator Hub analytics docs) - https://create.roblox.com/docs/production/analytics/acquisition - checked 2026-11-03
[31] Creator Roadmap 2026: Fall Update (age group analytics) (DevForum, 2026-09-18) - https://devforum.roblox.com/t/creator-roadmap-2026-fall-update/4880208 - checked 2026-11-03
[32] Benchmarks API (Creator Hub docs) - https://create.roblox.com/docs/cloud/guides/analytics/benchmarks - checked 2026-11-03
