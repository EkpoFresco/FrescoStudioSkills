# Roblox Discovery Algorithm

Last checked: 2026-11-03. Sources at bottom.

Scope: how Roblox decides which games players see, as of 2026-11-03. Companion files: `discovery-playbook.md` (what to do), `market-data.md` (third-party tools and market numbers).

## TL;DR for agents

- Home "Recommended For You" (RFY) is the main organic surface. Two stages: Retrieval (any traffic source can get you in), then Ranking (only users who organically joined from RFY count) [1][2].
- QPTR is gone from RFY. On 2026-06-15 Roblox removed qualified play-through rate and replaced it with play-through rate (PTR) plus first-play bounce rate (<60s and 61-180s) [3]. Treat older "optimize QPTR" advice as stale. The idea behind it still holds: a click only counts if the player stays.
- Current RFY signals. Most important: PTR, first-play bounce (negative), play days per user, playtime per user (capped 60 min/user/game/day). Important: intentional co-play days, qualified play sessions, spend days, Robux spent. All are per-user averages over D1, D2-7 and D8-28 windows [1][3].
- The algorithm's stated goal is long-term retention plus long-term monetization. The window grew from 7 days to 28 days on 2026-06-15. A retention and spend update went live for all players the week of 2026-08-20 [3][4][5].
- Weighting is personalized and dynamic. There is no single global formula, and Roblox will not publish weights or thresholds [7]. In Q3 2026 Roblox added age-cohort data to the weighting [12].
- Ads do not hurt or help RFY ranking. Users you get from ads, search, friends or curation are excluded from ranking signals. They can still help a game get retrieved [1][2][26].
- New games get tested at once. Signals arrive in stages (first session, D1, D2-7, D8-28). Games that fail early get no penalty, and the system re-tests daily [2]. About 40% of the weekly RFY top 100 by impressions were made in the last 3 months (end of Q3 2026) [12].
- Audience gating is the biggest discovery constraint in 2026. New games reach only age-checked 16+ users until they pass Kids and Select evaluation (250 unique plays from highly engaged players in 60 days, with a planned drop to 100 in November 2026) [19][20][22].
- Penalized: giveaway-led metadata, metadata that does not match the game, non-unique or cloned games, keyword spam, misleading videos. Check the "reduced exposure" banner in Creator Dashboard, which updates daily [1][2][39].
- Benchmarks shown in analytics do NOT affect ranking. They are for comparison only [1][2][37].

## 1. Surfaces (where players find games)

| Surface | What decides placement | Evidence | Source |
|---|---|---|---|
| Home: Recommended For You | Personalized ranking on the RFY signals below. About 100 games narrowed per user. Ads are now mixed throughout RFY | Roblox stated | [1][2][7] |
| Home: Continue | Recently played. First 2 slots fixed to the user's 2 most recent games (since 2025-12-12) | Roblox stated | [9][10] |
| Home: Friends / People You May Know | Friend activity. Shows up as the "Friends" acquisition source | Roblox stated | [9][33] |
| Home: Sponsored | Ads Manager auction (paid). Labeled tiles that share space with RFY | Roblox stated | [2][26] |
| Home: Standout Games (was Today's Picks) | Hand-curated novel games. Nomination form. Mostly video previews | Roblox stated | [7][32] |
| Home: Live Events | Games running limited-time quest events | Roblox stated, no ranking detail | [1] |
| Home: Avatar sort | Personalized avatar items (since 2026-04-02) | Roblox stated | [7] |
| Charts | Live sorts on 2026-11-03: Top Trending, Up-and-Coming, Top Playing Now, Fun with Friends, Top Revisited. Genre filters plus device and country filters | API observed | [29] |
| Charts: Top Playing Now | Ranked by concurrent users (CCU). Launched 2025-03-05 | Roblox stated (possibly stale) | [28] |
| Charts: Trending Events in Experiences | Active public events with at least 1,000 RSVPs that started in the last 7 days | Roblox stated | [30] |
| Search | Semantic search in all supported languages. An exact name match gets the enlarged top tile. Search ads appear next | Roblox stated | [1][27] |
| Game details page | Events, groups, passes, videos, and "similar games" recommendations | Roblox stated | [1] |
| Notifications | Opt-in experience notifications (13+), event "Notify Me", update announcements | Roblox stated | [30][31] |
| Moments | Short gameplay video feed inside the app. Beta from 2025-09-05, live in most of the US by Q3 2026 | Roblox stated | [12][46] |
| Off-platform featuring | Events submitted at least 7 days early can be placed in App Store, Google Play and Roblox marketing (since Dec 2025) | Roblox stated | [10][30] |

Notes:
- "Sorts to Charts": the Discover page was renamed Charts. The Discovery doc still calls it "Discover (top charts and trending sorts)". There was no algorithm change tied to the rename. UNVERIFIED exact rename date. To verify, look in the DevForum Announcements archive for the rename post.
- How Charts rank games other than Top Playing Now (Trending, Up-and-Coming, Fun with Friends, Top Revisited) is not published. UNVERIFIED. Third-party sites claim Trending uses CCU velocity. To verify, ask on the DevForum for a staff reply, or track chart entries against CCU history (see `market-data.md`).
- Genres feed genre-specific Charts sorts. After a genre change it can take a few days to show in Charts. You can only change genre once every 3 months [40].

## 2. How RFY works (mechanics)

- Stage 1, Retrieval: picks candidate games for each user based on engagement, retention and monetization. Signals from ads, curation, search, Charts, friends, teleports, notifications and social sharing "can accelerate your consideration". Retrieval needs only "a very low minimum number of plays from any source" [1][2].
- Stage 2, Ranking: orders the candidates for each user. How far a game goes "depends entirely on the engagement and retention of users who come to your game through Recommended for You" [1].
- Explore then expand: the system shows the game to a new cohort (explore). If that cohort engages and monetizes, it shows the game to more similar cohorts (expand) [1].
- Re-testing: "The algorithm tests your game daily, and if it sees improving performance, it increases impressions." Signals use a moving window, so a game that fails early is not permanently blocked [2].
- Four factors move your impressions: your own changes, Roblox's algorithm changes, total Home traffic (weekly peak on Saturday, plus summer, back-to-school and holiday cycles), and competitors improving faster than you [1][2][5].
- Per-user averages, not totals, so small games with very engaged users are not disadvantaged [1][2].
- Genre is not an explicit ranking factor. The model learns it from behavior. Wrong genre tags hurt you indirectly by causing bounces [2].
- Story or finite games are not penalized for lower D8-28 retention, because recommendations are personalized per user [2].
- When signals change, impressions usually move a few days later. Most signals refresh within 24 hours [8].

## 3. Ranking signals (current, since 2026-06-15)

All signals count only users who organically joined from RFY. Time windows: D1, D2-7, D8-28 [1][3].

| Priority | Signal | Definition (Roblox) | Windows |
|---|---|---|---|
| Most important | Play-through rate (PTR) | How often users play after seeing the game in RFY | First session |
| Most important | First-play bounce rate (negative) | Share of users who leave after a short first session | <60s, 61-180s |
| Most important | Play days per user | Average unique days played | D1, D2-7, D8-28 |
| Most important | Playtime per user | Average time played, capped at 60 min per user, per game, per day | D1, D2-7, D8-28 |
| Important | Intentional co-play days per user | Days users return to play with friends through join, invite or private server. Reserved servers count since 2025-12-11 | D1, D2-7, D8-28 |
| Important | Qualified play sessions per user | "Meaningful" sessions. Filters out accidental clicks and quick bounces | D1, D2-7, D8-28 |
| Important | Spend days per user | Unique days users spend Robux in the game | D1, D2-7, D8-28 |
| Important | Robux spent per user | Average Robux spent in the game | D1, D2-7, D8-28 |

- Windows are judged "both separately and combined". "It's very unlikely a game has a strong Day 8-28 signal if Day 1 and Day 2-7 are poor." [2]
- D2-7 play days is the average number of days played out of the 6 days in that window [2].
- Where to see them: Creator Analytics > Acquisition > Home Recommendations, and Creator Analytics > Overview [2][5].
- What "qualified" means exactly (minimum seconds) is not published. UNVERIFIED. To verify, ask on the DevForum. The bounce windows hint that sessions under 60s and under 180s are the failure zones.

### Master table: Signal | Surface | Evidence level | Source

| Signal | Surface it affects | Evidence level | Source |
|---|---|---|---|
| PTR (impression to play) | RFY ranking. Also shown for acquisition overall | Roblox stated | [1][3][33] |
| QPTR (qualified plays / RFY impressions) | Removed from RFY 2026-06-15. Still the metric in thumbnail personalization docs | Roblox stated (historic) | [3][8][13] |
| CTR (impression to click) | Clicks are tracked and counted (Oct 2026 pipeline). Not a named RFY signal | Roblox stated that clicks are counted, UNVERIFIED as a ranking input | [11] |
| First-play bounce (<60s, 61-180s) | RFY ranking (negative) | Roblox stated | [1][3] |
| Session length / playtime per user (capped 60 min/day) | RFY ranking | Roblox stated | [1] |
| Retention as play days D1, D2-7, D8-28 | RFY ranking | Roblox stated | [1][3][4] |
| Classic D1/D7/D30 retention | Not RFY inputs as such. Dashboard KPIs and benchmarks | Roblox stated (as KPIs) | [35][36] |
| Qualified play sessions per user | RFY ranking | Roblox stated | [1] |
| Spend days, Robux spent per user | RFY ranking | Roblox stated | [1][5] |
| ARPDAU, ARPPU, payer conversion | Dashboard KPIs with benchmarks. Ranking uses the per-user spend signals instead | Roblox stated (KPI) | [34] |
| Intentional co-play days (join, invite, private or reserved server) | RFY ranking | Roblox stated | [1][10] |
| Social graph, cohort, co-play signals | Recommendation and search systems overall | Roblox stated (shareholder letter) | [12] |
| Age-cohort data in weighting | RFY (from Q3 2026) | Roblox stated | [12] |
| "Not interested" dismissals | Discovery (testing since 2026-03-26). Stats in Acquisition > Overview | Roblox stated (test) | [7] |
| Deep play-through rate | Announced 2026-03-09. Not in the current signal list | Roblox stated, possibly superseded | [7] |
| Ratings / like ratio | Not in the RFY list. Shown publicly on tiles and in watchlists | UNVERIFIED as a ranking input | [1][35] |
| Return rate / Top Revisited | Charts sort "Top Revisited" exists. Logic not published | API observed, logic UNVERIFIED | [29] |
| CCU | Charts "Top Playing Now" | Roblox stated | [28] |
| Event RSVPs (at least 1,000) | Charts "Trending Events" | Roblox stated | [30] |
| Search query relevance and metadata | Search and search-ad auction | Roblox stated | [1][27][39] |
| Keyword spam or repeated keywords | Demotion | Roblox stated | [39] |
| Description tags and hashtags | "Unused in our ranking algorithms" | Roblox stated (experimental doc) | [41] |
| Gameplay video on tile | Raises RFY playtime (+39% in tests). Does not change ranking logic directly | Roblox stated | [7] |
| New vs returning mix | PTR and bounce use new RFY users only. Returning users via Continue do not count toward RFY impressions | Roblox stated | [2] |
| Ad-acquired users | Excluded from ranking. Can aid retrieval | Roblox stated | [1][2] |
| Sponsored traffic volume, botting | Botted traffic is refunded in ads and discounted in Creator Rewards. Bot effect on RFY not published | Partly stated, RFY effect UNVERIFIED | [26][42] |
| Highly engaged players (age-checked, tenure, playtime, platform spend) | Kids and Select eligibility, which decides who can see the game at all | Roblox stated | [20] |
| Content maturity label | Home and Charts recommendations by age group and region | Roblox stated | [25] |
| Custom thumbnail present | Required to be eligible for RFY impressions | Roblox stated | [1] |
| Benchmarks | None. "Do not impact the recommendation algorithm in any way" | Roblox stated | [1][3] |

## 4. QPTR over CTR (why the right click beats any click)

- Roblox never ranked on raw CTR. Even the old metric was qualified plays divided by RFY impressions, so a click that bounced added nothing [8].
- The 2026-06-15 change went further. PTR is now paired with explicit first-play bounce penalties at <60s and 61-180s. A clickbait thumbnail that lifts PTR but raises bounce now loses on two "most important" signals [1][3].
- Roblox's own reasoning (2026-06-15): overvaluing short-term engagement let "games that win attention with exciting thumbnails but don't deliver long-term value" crowd out better games. The 28-day view was built to fix that [4].
- Ranking counts the same users all the way through the funnel. Wrong-fit clicks then drag down D1, D2-7 and D8-28 play days, playtime and spend for that cohort [1][2].
- Mismatched thumbnails, titles and gameplay are explicitly "not recommended" [1]. Gameplay videos must show real, current gameplay, and misleading videos are rejected [7][13].
- A PTR dip during an impression surge is normal ("should stabilize") and is not a penalty [1][2].
- Practical rule for agents: judge any creative or metadata change on PTR x (1 - bounce) x D1 play days, not on PTR alone. Thumbnail personalization already optimizes qualified plays, not clicks [13].

## 5. New games: initial exposure and escalation

- Gate 1, audience. A new game first reaches only age-checked 16+ users. Reaching under-16 Kids (5-8) and Select (9-15) accounts requires a verified creator account, 2-step verification, a fee or a Plus/Premium subscription, a Minimal, Mild or Moderate rating, and evaluation [20].
- Evaluation threshold: 250 unique plays by highly engaged age-checked users within 60 days, tracked hourly on the Audience Reach dashboard [20]. History: 500 at launch (2026-05-19), 250 from 2026-08-19, and a planned drop to 100 in November 2026 [19][21][22]. UNVERIFIED whether 100 is live yet. To verify, open Creator Hub > game > Audience Reach.
- Maintenance bar: 25 highly engaged players over 60 days to stay in the catalog (since 2026-07-16) [21][39].
- Highly engaged player: meets rules on account tenure, playtime in your game, and platform spend (any purchase on Roblox in the last 60 days). They do not need to spend in your game [20].
- Expedited review: refundable 50,000 Robux per game (cut from 100,000 on 2026-09-11). Takes up to 48h and skips the HEP threshold [19][21].
- Gate 2, retrieval. Any small amount of play from any source qualifies (ads, friends, search, share links, Charts) [1][2].
- Gate 3, ranking. Early signals (PTR, bounce) start "immediately". D1, D2-7 and D8-28 follow. More data means more accurate targeting and "greater distribution over time" [2].
- The system "continuously explores by trying to introduce new games to new users" [2].
- Escalation trigger: a strong RFY cohort on the most important signals, then on co-play and spend. Expand to similar cohorts [1].
- Ads Manager's Plays objective is positioned as "building initial traffic that may help the game be considered for Recommended For You" [26].
- Evidence that new games break out: 40% of the weekly RFY top 100 by impressions were less than 3 months old (end of Q3 2026). 28% of the top 100 by hours launched in the prior 90 days (Aug 2026 data) [12][18].
- Pre-launch tools: invite up to 10 similar-aged friends before release. Experience Betas are hidden from Home Recommendations and search [10][39].
- "Up and Coming" style chart: an Up-and-Coming sort exists [29]. Its entry logic is UNVERIFIED. A 2025 community comment saw games from 10K to 200K+ CCU in it [28].

## 6. Thumbnails, icons, video, testing tools

| Tool | What it does | Metric it optimizes | Source |
|---|---|---|---|
| Thumbnail personalization (Home Page tab) | Activate 2-5 thumbnails. Each is shown to random users, then the winner per user group gets most impressions while the rest keep small exploration traffic | Qualified play-through rate (doc wording). Roblox said 2026-06-15 it will test switching to PTR | [3][13] |
| Thumbnail Performance table | Impressions, qualified plays, average playtime per qualified play, QPTR, winning segment. Fills after a few hours | Same | [13] |
| Gameplay video (Places > Videos) | Plays on hover (desktop) or pause (mobile) in RFY and Standout. Reviewed for authenticity. 3 uploads per month, and rejected videos count | Not ranked directly. Tests showed +39% RFY playtime and +47% quality plays on Standout | [7][13] |
| Icon | One icon per locale, 512x512. No icon A/B tool exists | None built in | [14] |
| Experiments (A/B) | In-game config and matchmaking A/B tests. 14-60 days. Up to 2 variants plus control | D1, D7, playtime, ARPU, ARPPU, payer conversion, session time. NOT thumbnails or icons | [15][16] |
| Ads creatives | Up to 10 thumbnails per campaign, spread evenly, 16:9 | Ad reporting (clicks, plays, CPP) | [26] |

- Results: thumbnail personalization gave +8.5% average QPTR in testing, and up to +50% for some games [13].
- Keep several thumbnails active. Do not pick a single winner [13].
- A custom thumbnail is required for RFY eligibility [1].
- Do not put key text at the bottom of a thumbnail, because the player count can cover it [13].
- Video preview analytics were delayed to late 2026 [17]. Auto-translation of icons and thumbnails was delayed to late 2026 [16].
- Reusing your own old thumbnails "shouldn't negatively affect discoverability" [2].
- UNVERIFIED: whether thumbnail personalization now uses PTR or QPTR. To verify, check the Home Page tab column headers in Creator Dashboard.

## 7. Maturity labels, age checks, audience limits

| Label | Who can see it by default | Source |
|---|---|---|
| Minimal, Mild | Kids (5-8), Select (9-15), 16+ | [20][25] |
| Moderate | Select (9-15), 16+ | [20][25] |
| Content May Vary (single "No" answer) | Age-checked 16+ only | [20][25] |
| Restricted | Age-verified 18+ only. Unplayable in some regions (Korea, Saudi Arabia, Türkiye) | [25] |
| Unrated | "Automatically restricts the playability of the game on the platform for all players" | [25] |

- Roblox uses maturity information to recommend games on Home and Charts by age group and regional policy [25].
- Sensitive-issue games are not recommended or discoverable unless the player has age-verified [25].
- Social hangouts without private spaces and free-form creation games are 16+. Hangouts with private spaces are 18+ [25].
- Questionnaire: Creator Dashboard > Publish settings > Content rating (Maturity and Compliance Questionnaire). Since Sep 2026 a single question gets you a 16+ release in most regions. Kids and Select need the full questionnaire [19][25].
- Inaccurate answers can lead to the label being replaced or removed, plus moderation [25].
- Unverified (non-age-checked) users are limited to Minimal and Mild games and have no chat [24].
- Chat requires an age check. By the end of Q3 2026, 64% of global DAUs had age-checked [12]. Social and co-play signals therefore come mostly from age-checked users. UNVERIFIED how much this weakens co-play for young audiences. To verify, compare co-play signal trends by age group in analytics.
- Roblox plans to move to the IARC rating framework. The questionnaire change was delayed to late 2026 [17][23].
- Creator publishing: for 16+, an account at least 2 days old plus an age check. For all ages, ID verification (or facial age estimation if under 18) plus 2SV [20].
- Release limit: up to 5 never-before-released games per day [39].
- "Exclude from recommendations" toggle: opts a public game out of RFY, and RFY metrics then show zero [33][39].

## 8. Timeline of discovery changes

Last 12 months (Nov 2025 to Nov 2026):

| Date | Change | Source |
|---|---|---|
| 2025-12-11 | Improved RFY signals released globally. Reserved servers count as co-play. Attribution fixed to RFY-only | [8][10] |
| 2025-12-12 | Continue slots 1-2 fixed to the 2 most recent games. One-click genre tags on the search landing page. Experience Betas. Off-platform event featuring | [9][10] |
| 2026-03-09 | "How we are improving Home": Today's Picks becomes Standout Games. Deep PTR signal. Video previews test. Dynamic, personalized weighting with no global formula | [7] |
| 2026-03-26 | 7-day qualified play sessions signal. "Not interested" signal testing | [7] |
| 2026-04-02 | Avatar sort on Home. Video previews on Standout | [7] |
| 2026-04-10 | Testing RFY signals over minutes, days, weeks and months (beyond 7 days) | [6] |
| 2026-04-13 | Kids and Select accounts announced | [23] |
| 2026-05-08 | Spring roadmap: Experimentation (A/B testing) shipped. Search landing page, Home UI and RFY improvements delayed | [16] |
| 2026-05-14 | Gameplay video expands to RFY (+39% playtime in tests) | [7] |
| 2026-05-19 | Publishing requirements and Kids and Select live in first regions (NZ, NL, AU, ID) | [21][24] |
| 2026-06-15 | 28-day RFY signals. QPTR removed, PTR and first-play bounce added. Relative importance published | [3][4] |
| 2026-06-16 | Kids and Select global. Ads Manager Engagement objective (beta). Expedited review | [21] |
| 2026-07-16 | HEP maintenance bar cut from 100 to 25 | [21] |
| 2026-07-29 | Hover-to-play video in RFY ("does not change how recommendations are ranked"). Ads spread throughout RFY | [7] |
| 2026-08-06 / 08-20 | RFY update favoring long-term retention plus monetization. Live for all players the week of 08-20 | [5] |
| 2026-08-19 | HEP entry threshold cut from 500 to 250 | [22] |
| 2026-09-11 | RDC26: Play on the Web (late 2026), pre-roll video ads, developer push notifications, single-question 16+ publishing, HEP cut to 100 (November) | [18][19] |
| 2026-09-18 | Fall roadmap: passes and dev products on Home (late 2026), name checks and promotional text, deceptive copy takedowns (late 2026). "Better discovery recommendations" and "Better Continue Playing" shipped | [17] |
| 2026-10-12 | New measurement pipeline: higher impression, click and play counts from Home, Search and Charts, and a small PTR drop. Ranking unchanged. Data before 10-12 is not restated | [11] |
| 2026-10-29 | Q3 letter: RFY refined with age-cohort weighting. New games surfacing faster. 70%+ of the top 100 by Robux spent ran Sponsored Ads | [12] |

Context, 2024 to mid 2025. Items older than about 18 months (before May 2025) are possibly stale:

| Date | Change | Source |
|---|---|---|
| 2025-01-31 (possibly stale) | Personalized ordering of Home sorts. RFY algorithm unchanged at the time | [9] |
| 2025-03-05 (possibly stale) | Top Playing Now (CCU) on Charts | [28] |
| 2025-03-31 (possibly stale) | RFY signals made public (7-day). Home Recommendations analytics tab. QPTR defined | [8] |
| 2025-07-24 | Creator Rewards replaced Engagement-Based Payouts | [42] |
| 2025-09-05 | RDC25: Moments beta. Experience Betas. Ads Manager upgrades. Search ads improvements "soon" | [46] |
| 2025-10-16 | Retention by acquisition source. Choice of benchmark set (similar vs genre) | [37] |

## 9. What Roblox penalizes or ignores

Penalized (reduced exposure or demotion):
- Leading with giveaways. Metadata that implies monetary rewards (example: "Robux! Play now!") [1].
- Metadata badly mismatched with the actual game [1].
- Non-unique games. Metadata or place files that closely resemble existing games. The game that first added the unique metadata or place file is the one highlighted [1][2].
- Keyword spam: repeated or irrelevant keywords in descriptions [39].
- Misleading gameplay videos (rejected): artificial visuals, ads or claims in text ("50% off", "Free UGC!") [13].
- Clickbait or spam in search ads is not surfaced. Non-unique games may get no ad delivery [26][27].
- Community Standards violations. Inaccurate maturity answers [2][25].
- Inauthentic traffic: bots, alt accounts. Discounted in Creator Rewards, refunded in ads [26][42].
- Planned for late 2026: takedowns of games that copy another game's title or thumbnail, and name protection [17].

Ignored (no ranking effect):
- Benchmarks and benchmark games [1][3].
- Running ads, either way. "A drop in RFY impressions after advertising is not an ad penalty" [2].
- Curated promotion, which is "separate from organic ranking" [7].
- Being first to publish an idea. What matters is who first added the unique metadata [2].
- Description tags and hashtags [41].
- Genre label as a direct factor (learned from behavior instead) [2].
- Reusing your own thumbnails [2].
- Gameplay video, which does not change ranking logic (it changes player behavior) [7].

How to check status:
- Creator Dashboard banner for reduced exposure, updated daily [1][2].
- Low-quality notice in Creator Analytics [2].
- Publishing eligibility at create.roblox.com/settings/eligibility/publishing-permissions [2].
- Bug report via Support with your Universe ID [1].

## 10. Ads and paid placement (as it relates to discovery)

- Placements: Sponsored tiles on Home plus search results (one campaign shows on both). Search ads use exact keyword match with up to 10 keywords per ad set, reach 13+ in all regions, and cannot be targeted. Portal ads and Sponsored Takeovers appear as acquisition sources [26][27][33].
- Objectives: Plays, Earnings (Limited), Engagement (beta, age-checked highly engaged players for the Kids and Select threshold). Engagement does not auto-pause at the threshold [26].
- Bidding is automated. Engaging games "may receive ad system discounts" [26]. Search ads rank on adjusted eCPM with query relevance [27].
- Attribution: New Users get 30-day credit. Plays and earnings can trail up to 30 days. Data lags up to 48h. Invalid-traffic checks run 14 days after the campaign ends [26].
- Ad-acquired users generally stop seeing your game in RFY because they count as "already acquired" [2][7].
- Coming: skippable pre-roll video ads, and a Maximize Spend objective (announced at RDC25 for early 2026). UNVERIFIED whether Maximize Spend shipped. To verify, check the Ads Manager objectives list [12][46].

## 11. Open questions and UNVERIFIED items

- Exact "qualified play" threshold in seconds. To verify, ask on the DevForum.
- Relative signal weights. The 2026-06-15 post shared them as an image only, and Roblox says weights are personalized. To verify, check Home Recommendations analytics for importance labels.
- Ranking logic of Top Trending, Up-and-Coming, Fun with Friends and Top Revisited. To verify, ask staff or run a longitudinal chart study (`market-data.md`).
- Whether thumbnail personalization switched to PTR. To verify, check the dashboard columns.
- Whether the HEP threshold of 100 is live (planned for November 2026). To verify, check the Audience Reach tab.
- Whether ratings affect ranking. Not in the signal list, so assume an indirect effect via PTR only.
- How search ranks results beyond semantic relevance and exact match. The search landing page and dynamic filters slipped to late 2026 [17].
- Effect of the 2026-10-12 measurement change on historical comparisons. Compare pre/post only with caution [11].

## Sources

[1] Discovery (Creator Hub docs) - https://create.roblox.com/docs/discovery - checked 2026-11-03
[2] Discovery FAQ (Creator Hub docs) - https://create.roblox.com/docs/discovery-faq - checked 2026-11-03
[3] Recommended For You Algorithm Improvements That Better Value Long-Term Retention (DevForum, 2026-06-15) - https://devforum.roblox.com/t/recommended-for-you-algorithm-improvements-that-better-value-long-term-retention/4684575 - checked 2026-11-03
[4] Optimizing Discovery: How Great Games Reach Millions of Players on Roblox (Newsroom, 2026-06-15) - https://about.roblox.com/newsroom/2026/06/optimizing-discovery-great-games-reach-millions-players-roblox - checked 2026-11-03
[5] Boost Your Discovery by Building Games People Want to Play (DevForum, 2026-08-06, updated 2026-08-20) - https://devforum.roblox.com/t/boost-your-discovery-by-building-games-people-want-to-play/4779042 - checked 2026-11-03
[6] Testing More Recommended For You Algorithm Signals (DevForum, 2026-04-10) - https://devforum.roblox.com/t/testing-more-recommended-for-you-algorithm-signals/4568033 - checked 2026-11-03
[7] How we are improving Home this year (DevForum, 2026-03-09, updates to 2026-07-29) - https://devforum.roblox.com/t/how-we-are-improving-home-this-year/4502571 - checked 2026-11-03
[8] Boost Your Discovery with the Improved Recommended For You Algorithm and Analytics for Creators (DevForum, 2025-03-31, updated 2025-12-11) - https://devforum.roblox.com/t/boost-your-discovery-with-the-improved-recommended-for-you-algorithm-and-analytics-for-creators/3587441 - checked 2026-11-03
[9] Building the Future of Roblox Home and Search: Introducing Personalized Discovery (DevForum, 2025-01-31, updated 2025-12-12) - https://devforum.roblox.com/t/building-the-future-of-roblox-home-and-search-introducing-personalized-discovery/3432124 - checked 2026-11-03
[10] Weekly Recap: December 8 - December 12, 2025 (DevForum) - https://devforum.roblox.com/t/weekly-recap-december-8-december-12-2025/4147197 - checked 2026-11-03
[11] Improved Discovery Measurement in Creator Analytics (DevForum, 2026-10-12) - https://devforum.roblox.com/t/improved-discovery-measurement-in-creator-analytics/4930122 - checked 2026-11-03
[12] Roblox Q3 2026 Shareholder Letter (2026-10-29) - https://s27.q4cdn.com/984876518/files/content_files/Q3-2026-Earnings-Shareholder-Letter.pdf - checked 2026-11-03
[13] Thumbnails (Creator Hub docs) - https://create.roblox.com/docs/production/publishing/thumbnails - checked 2026-11-03
[14] Icons (Creator Hub docs) - https://create.roblox.com/docs/production/publishing/experience-icons - checked 2026-11-03
[15] Experiments (Creator Hub docs) - https://create.roblox.com/docs/production/experiments - checked 2026-11-03
[16] Creator Roadmap 2026: Spring Update (DevForum, 2026-05-08) - https://devforum.roblox.com/t/creator-roadmap-2026-spring-update/4625473 - checked 2026-11-03
[17] Creator Roadmap 2026: Fall Update (DevForum, 2026-09-18) - https://devforum.roblox.com/t/creator-roadmap-2026-fall-update/4880208 - checked 2026-11-03
[18] RDC26: What We Announced (DevForum, 2026-09-11) - https://devforum.roblox.com/t/rdc26-what-we-announced/4865880 - checked 2026-11-03
[19] Making Publishing Easier: Our Vision and What's Coming (DevForum, 2026-09-11) - https://devforum.roblox.com/t/making-publishing-easier-our-vision-and-whats-coming/4865780 - checked 2026-11-03
[20] Roblox Kids and Select (Creator Hub docs) - https://create.roblox.com/docs/production/publishing/kids-and-select - checked 2026-11-03
[21] Roblox Kids and Select Global Launch: Upcoming Updates to Eligibility, Ads Manager, and Expedited Review (DevForum, 2026-06-16, updates to 2026-07-16) - https://devforum.roblox.com/t/roblox-kids-and-select-global-launch-upcoming-updates-to-eligibility-ads-manager-and-expedited-review/4685717 - checked 2026-11-03
[22] Highly Engaged Player Threshold Drops to 250 (DevForum, 2026-08-19) - https://devforum.roblox.com/t/highly-engaged-player-threshold-drops-to-250/4820164 - checked 2026-11-03
[23] Roblox Introduces New Age-Based Accounts and Expanded Parental Controls (Newsroom, 2026-04-13) - https://about.roblox.com/newsroom/2026/04/introducing-roblox-kids-and-select-accounts - checked 2026-11-03
[24] [AMA] Publishing Requirements + Roblox Kids & Select (DevForum, 2026-04-16) - https://devforum.roblox.com/t/ama-publishing-requirements-roblox-kids-select/4580953 - checked 2026-11-03
[25] Content maturity and compliance (Creator Hub docs) - https://create.roblox.com/docs/production/promotion/content-maturity - checked 2026-11-03
[26] Ads Manager (Creator Hub docs) - https://create.roblox.com/docs/production/promotion/ads-manager - checked 2026-11-03
[27] Search ads (Creator Hub docs) - https://create.roblox.com/docs/production/promotion/search-ads - checked 2026-11-03
[28] Introducing "Top Playing Now" on Charts (DevForum, 2025-03-05) - https://devforum.roblox.com/t/introducing-top-playing-now-on-charts/3529809 - checked 2026-11-03
[29] Roblox explore-api get-sorts (live Charts sort list, US, computer) - https://apis.roblox.com/explore-api/v1/get-sorts - checked 2026-11-03
[30] Experience events (Creator Hub docs) - https://create.roblox.com/docs/production/promotion/experience-events - checked 2026-11-03
[31] Experience notifications (Creator Hub docs) - https://create.roblox.com/docs/production/promotion/experience-notifications - checked 2026-11-03
[32] Standout Games (Creator Hub docs) - https://create.roblox.com/docs/creator-programs/standout-games - checked 2026-11-03
[33] Acquisition (Creator Hub analytics docs) - https://create.roblox.com/docs/production/analytics/acquisition - checked 2026-11-03
[34] Analytics dashboard: Benchmarking (Creator Hub docs) - https://create.roblox.com/docs/production/analytics/analytics-dashboard - checked 2026-11-03
[35] Analytics overview (Creator Hub docs) - https://create.roblox.com/docs/production/analytics - checked 2026-11-03
[36] Retention (Creator Hub analytics docs) - https://create.roblox.com/docs/production/analytics/retention - checked 2026-11-03
[37] Analytics: View retention by acquisition source and select your benchmark set (DevForum, 2025-10-16) - https://devforum.roblox.com/t/analytics-view-retention-by-acquisition-source-and-select-your-benchmark-set/4010157 - checked 2026-11-03
[39] Create and publish games and places (Creator Hub docs) - https://create.roblox.com/docs/production/publishing/publish-games-and-places - checked 2026-11-03
[40] Genres (Creator Hub docs) - https://create.roblox.com/docs/production/publishing/experience-genres - checked 2026-11-03
[41] Game descriptions (experimental guidelines, Creator Hub docs) - https://create.roblox.com/docs/production/publishing/descriptions - checked 2026-11-03
[42] Creator Rewards (Creator Hub docs) - https://create.roblox.com/docs/creator-rewards - checked 2026-11-03
[46] RDC25: What we announced (DevForum, 2025-09-05) - https://devforum.roblox.com/t/rdc25-what-we-announced/3920245 - checked 2026-11-03
