# Roblox Policy Reference for Design, Monetization, and Marketing

Last checked: 2026-11-03. Sources at bottom.

> Not legal advice. This is a working summary of Roblox platform rules for design agents. Roblox policy changes often. When a rule decides a launch, re-read the linked primary page.

Conventions: `[n]` links to Sources. `UNVERIFIED` means no primary page confirmed it during research. Each one says how to verify it. "Title only" means only the DevForum post title was seen, not its body.

## TL;DR for agents

- Paid random items (eggs, crates, spins, gacha, luck boosts, anything bought with Robux or with currency bought with Robux) need every outcome's numeric odds shown before purchase. The odds must total 100%. Every outcome must give some benefit. Clarified May 26, 2026, live that day [5][6].
- Gate paid random items with `ArePaidRandomItemsRestricted` and gate trading of paid items with `IsPaidItemTradingAllowed`. Named regulated markets: Australia, Belgium, Netherlands, UK, Brazil [6][7].
- Playable gambling is banned, even with nothing of value at stake (simulated gambling). Only "unplayable" gambling references and imagery are allowed, at Moderate or above [1][4].
- Unrated games are restricted for all players. Kids (5-8) and Select (9-15) can only reach games that are labeled Minimal, Mild, or Moderate and that pass a separate evaluation [3][8][9].
- Age checks have been required to chat worldwide since January 7, 2026. Age checks are also required for Team Create (June 11, 2026), for private published games (June 16, 2026), and to see social links (16+, June 30, 2026) [11][12][14].
- No URLs, handles, invites, or QR-style workarounds in games. Social links go only in the Social Links field on the details page. `AllowedExternalLinkReferences` is legacy and always returns an empty array [1][7][24].
- Since May 4, 2026, every paid or off-platform-promoting ad integration (including self-promotion) must be registered in Ads Manager, reviewed, and labeled. Third-party ad or measurement calls are banned. Revenue share starts with campaigns on or after January 1, 2027 [1][25][26].
- Under-13s: no rewarded ad formats, no food, cosmetics, pharma, or financial ads. Ads must be contextual and COPPA compliant. No ad personalization for anyone under 18 [1][25].
- Cross-game sales of passes and developer products ended May 29, 2026. Donation games must use the Transfers API [21].
- Tip jars are fine only if players clearly get nothing in return. Charity drives and Robux or real-money prize contests are banned without Roblox's involvement [1].
- AI in games: tell players the AI is not human, that its output is machine-generated and may be wrong. Declare AI interaction in the questionnaire [2][4].
- IP: rights holders can force removal or take a revenue share through Roblox's IP tools. Use the License Manager for licensed IP. Never put "Roblox" or "Blox" in a game title [2][30].

## 1. Community Standards: the parts that hit game design

| Area | Rule | Design implication |
|---|---|---|
| Violence | Extreme violence, serious abuse, and realistic extreme gore or death are banned. Strong violence is allowed only under the Restricted (18+) label [1][3]. | Pick a maturity tier before art direction. |
| Romance and sexual | Sexual content and suggestive design are always banned. Romantic or flirtatious gestures and content are banned except as "romantic themes" in Restricted games. Private spaces (bedrooms, bathrooms) are banned in Social Hangouts unless the game is age-verified 18+ [1][3][15]. | No dating or "girlfriend" loops outside Restricted. Bedrooms are fine in a dollhouse sim where the design does not encourage the targeted behavior [15]. |
| Gambling | "We prohibit both simulated and actual gambling activities." No real money, Robux, or items of value may be exchanged in connection with gambling. Unplayable references and imagery are allowed [1]. | No slots, roulette, blackjack, coin-flip betting, or case battles, even with free chips. |
| Real-world currency trading | Using third parties to buy, sell, trade, or give away Robux is banned. Off-platform secondary-market sales of accounts or virtual items are banned [1][2]. | Never sell items for PayPal, gift cards, or crypto. Never reference RMT sites. |
| Scams and cheating | Exploits and phishing are banned. Subscription offers that scam or mislead get the game taken down [1][18]. | Purchases must deliver exactly what the UI says. |
| Misleading content | "Deceptive, sensational, duplicative, or otherwise misleading content or metadata" used to drive discoverability, monetization, or engagement is banned. So are near-duplicate uploads and games made solely to send users off Roblox [1]. | Thumbnails, titles, and icons must match the actual game. No fake "free Robux" claims. |
| Discrimination and harassment | Threatening, insulting, mocking, or excluding people by protected category is banned [1]. | Watch faction names, NPC dialogue, and meme humor. |
| Real-world sensitive events | Recreating or profiting from mass violence, disasters, or sensational crimes is banned [1]. | No "disaster of the week" tie-ins to real tragedies. |
| Political figures | Depicting current officials, campaigns, or parties, or fundraising for them, is restricted [1]. | Avoid real politicians in memes and skins. |
| Bots and system misuse | Bots running disruptive tasks, raid-flooding games, false mass reporting, ban or VPN evasion, and obfuscated code are banned. Creators must use PolicyService and TextChatService [1]. | Server-side checks only. Never buy traffic from bot farms. |
| Engagement integrity | Roblox screens engagement for bots by account age, play history, and spend before Kids/Select reach [8]. Bots or multiple accounts can cost Creator Rewards eligibility [2]. Passes sold for template games without legitimate visits are not DevEx-eligible [20]. | Fake engagement now blocks audience reach, not just payouts. |

## 2. Content maturity labels and the questionnaire

### Label tiers [3][4]

| Label | Allows | Who can play |
|---|---|---|
| Minimal | Occasional mild violence, light unrealistic blood | Kids (5-8), Select (9-15), 16+ |
| Mild | Repeated mild violence, heavy unrealistic blood, mild fear, mild crude humor | Kids, Select, 16+ |
| Moderate | Moderate violence, light realistic blood, moderate fear, moderate crude humor, unplayable gambling | Select (9-15) and 16+ |
| Content May Vary | Given when you answer only the first age-restricted question (with "No") instead of the full questionnaire [8] | Age-checked 16+ only |
| Restricted | Strong violence, heavy realistic blood, romantic themes, alcohol, strong language, unplayable gambling | Age-verified (ID) 18+ only. Unplayable in Korea, Saudi Arabia, Türkiye, and some other regions |

Descriptor gates that override the label [4]:
- Social hangout (main activity is chatting): 16+. With private spaces: 18+. Mentioning "hangout" in the title or description makes it one.
- Free-form user creation (drawing or writing visible to others): 16+.
- Primary theme is a sensitive issue: 16+, and not recommended or discoverable unless the player is age-verified.
- Other questionnaire items: paid random items, paid item trading, media sharing (feeds, autoplay, cross-game content), and AI interaction ("Limited" vs "Extended", where Extended means cross-session memory, or AI as the main purpose with no time limit).

### Rules
- You must complete the questionnaire before the game is available. You are "not entitled to any particular" label [2].
- Unrated games: "Roblox automatically restricts the playability of the game on the platform for all players" [3]. Announced August 15, 2025 [15]. Enforcement began about September 30, 2025. `UNVERIFIED` (exact date comes from secondary reports; check the DevForum announcement archive).
- Restricted moved from 17+ to 18+. Announced August 28, 2025, updated November 6, 2025 [16]. Creators must be 18+ to publish new Restricted games [16].
- A Restricted label restarts servers, removes non-18+ players, and removes non-18+ collaborators from Studio sessions. Restricted cannot be downgraded, but descriptors can be edited [3][4].
- Re-take the questionnaire after any content change. Resubmitting temporarily removes immersive and rewarded ads eligibility while the new answers are reviewed [4][27][28].
- Wrong answers can get the label replaced or removed. Repeated or intentional misrepresentation can bring penalties on the game or account [4].
- Roblox says it will move to the IARC global rating framework, starting later in 2026 [9][10]. `UNVERIFIED` whether this has started (check the Content maturity page [3] for IARC wording).

## 3. Publishing tiers and Kids/Select reach

| Tier | Creator requirements |
|---|---|
| Personal use | None [10] |
| 16+ and Trusted Friends | Age check (facial estimation or ID), good standing, account at least 2 days old, first questionnaire question answered [8][10] |
| All ages (reaches under-16) | All of the above plus ID verification (if 18+), 2FA, a full questionnaire rated Minimal, Mild, or Moderate, and either Roblox Plus or Premium (2 consecutive months) or a refundable 1,000 Robux fee per game. The game must also pass evaluation [8][11] |

- Effective May 19, 2026 [10]. Kids and Select launched globally June 16, 2026 [11].
- Evaluation: a trial with age-checked 16+ users, bot screening, real-time moderation review, then a threshold of highly engaged players. The docs say 250 unique plays from highly engaged, age-checked users within 60 days [8]. RDC26 said the threshold would drop to 100 in November 2026 [32]. `UNVERIFIED` current number (check the Audience Reach tab in Creator Hub).
- Expedited review: refundable fee per game. The docs say 50,000 Robux [8]; the June 2026 post said 100,000 [11]. Treat the docs as current. Fees are forfeited for severe violations [8][11].
- Default exclusions from Kids/Select: social hangouts, free-form drawing, sensitive issues [9].
- Parents can approve specific games outside the default tier, but never Restricted ones [8][9].

## 4. Paid random items (loot boxes)

### What counts [5][6]
- Capsules: spin wheels, egg hatches, chests, crates, gacha pulls.
- Enhancements: potions with random duration, upgrades that can fail.
- Combinations: fuse or craft for a chance at something better.
- Probability modifiers: luck boosts, pity systems, enhanced drops, rate-up scrolls.
- Indirect purchases count: keys, re-roll tokens, spin tickets, or soft currency bought with Robux.
- A random item bundled into a paid pack makes the whole bundle a paid random item.
- Not covered: random rewards that can only be earned, never bought directly or indirectly.

### Disclosure (live May 26, 2026) [5][6]
- Show every possible outcome and its numeric percentage before purchase. Totals must equal 100%.
- An info pop-up is fine if it is reachable before purchase and labeled "Info" or "Details". A bare (i) icon is not enough.
- Items with identical odds can share one line ("Odds for each item listed below: X%").
- Rounding: keep at least 4 places past the first non-zero digit and show: "Probabilities are rounded; total of displayed individual probabilities may not equal 100%."
- Nested or tiered boxes: disclose the odds of every final outcome.
- Every outcome must give some benefit. No pure-loss outcomes.
- Probability modifiers: state the effect numerically before purchase. Displayed odds must update live while a modifier is active.
- One-time outcomes: update the remaining odds for that user [5].
- Background: the revision followed a Korean regulator inquiry and was applied worldwide [33] (secondary source). A disclosure requirement existed before 2026. `UNVERIFIED` original effective date (check DevForum announcements from 2019 to 2020).
- Enforcement: a moderator note, then fix and appeal. Confirmed violations mean game removal and account suspension [6].

### Regional restriction [5][6][7]
- Call `PolicyService:GetPolicyInfoForPlayerAsync(player)` (yields, wrap in `pcall`). If `ArePaidRandomItemsRestricted` is true, use one of these:
  - a free, earnable path;
  - a fixed, disclosed order (no randomness);
  - direct purchase of the specific item, priced at expected value;
  - hide or remove the item (preferred);
  - block the purchase with an error (allowed but discouraged);
  - keep the user out of areas with paid random items.
- Roblox maintains the region list centrally. Never hard-code countries. Test with Studio's Player Emulator.

### Trading [1][5][6]
- If `IsPaidItemTradingAllowed` is false, the user must not be able to trade paid random outcomes or other paid items.
- Buying eligibility and trading eligibility are separate checks.
- `UNVERIFIED`: whether the trading gate covers non-random paid items. The policy wording ("or other paid items") is ambiguous. Ask on DevForum or Roblox Support.

## 5. Monetization rules

| Topic | Rule |
|---|---|
| Selling advantages (pay-to-win) | No Roblox rule found that bans selling power. Purchases just must not mislead [1][18]. `UNVERIFIED` that no rule exists (re-read Community Standards "Roblox Economy" before shipping). |
| Misleading purchases | Misleading metadata to drive monetization is banned. Subscriptions that scam or use false offers get the game removed [1][18]. |
| Fake timers, pressure tactics | Not named in any page checked. `UNVERIFIED`. Treat them as misleading content risk. Consumer law (for example the EEA) may also apply. Never fake a countdown or a fake stock count. |
| Donations and tip jars | Robux tips are allowed if it is clear the player gets nothing in return. Charity solicitation is banned [1]. |
| Donation boards (PLS DONATE style) | Cross-game pass and product sales ended May 29, 2026. Use the Transfers API (`PromptRobuxTransferAsync`): 0% Roblox fee, recipient gets 90%, the hosting game gets 10% (DevEx-eligible). The recipient's share is not DevEx-eligible. The sender needs Roblox Plus [21][22]. |
| Transfer limits | Accounts with 2SV in good standing: 5,000 Robux per day and 10,000 per month from May 20, 2026. Parental approval age dropped from 18 to 16 in most regions (June 2026) [22]. |
| Contests | No Robux or real-money prizes without Roblox's direct involvement [1]. |
| Off-platform deals | Off-platform promotions bundled with in-game rewards need a contract with Roblox. Commerce products must follow the Commerce Standards and check `IsEligibleToPurchaseCommerceProduct` [1][7]. |
| Real-money gambling | Banned [1]. |
| Receipts | Grant in `ProcessReceipt` only. Return `PurchaseGranted` only after the grant succeeds [19]. |
| Rewarded video rewards | Must be a developer product normally sold for Robux. Never Robux. Never randomized. Never a forced progress gate [27]. |

### Subscriptions [18]
- Robux subscriptions cost 49 Robux or more. Local-currency subscriptions use fixed tiers ($2.99 to $14.99) and need an ID- or phone-verified account.
- Robux price changes: at most once every 60 days. Increases apply only after 30 days' notice to subscribers. Local-currency prices cannot change (delete and recreate instead).
- Benefits must be honored for the full term, must be the same on every platform, and cannot be quietly revoked.
- You may not require extra tasks (for example social posts) to unlock benefits already paid for. Battle passes are exempt.
- You may not use the Roblox app to direct users to buy elsewhere.
- Robux subscriptions are not refundable. Deleting a subscription with active subscribers refunds them all and pays you zero.
- Use `IsEligibleToPurchaseSubscription` before showing the offer [7].

### Refunds, prices, payouts
- Terms of Use (effective November 1, 2026): purchases are final and non-refundable unless law says otherwise. The EEA now has a consumer right of withdrawal [2]. Paid Access bought with local currency can be refunded within 48 hours [2].
- A "Transaction Refunded" webhook launched September 23, 2026 (title only) [35]. `UNVERIFIED` details (read the post before designing refund clawbacks).
- Managed Pricing (June 15, 2026) runs automatic regional and price tests at least every 90 days. You get notice first and can opt items out. Hard-coded prices block it [23].
- DevEx: 0.0038 USD per Earned Robux since September 5, 2025. Robux earned before that date cash out first at 0.0035. Spend by US players verified 18+ earns 0.0054 in eligible games (announced April 30, 2026). Minimum 30,000 Robux, age 13+, one request per month. Transfers, trading, and gift cards are not Earned Robux [20].
- Roblox Wallet (daily USD payouts) is planned for late 2026. A reply in the RDC26 thread quotes a US DevEx phase-out in mid-2027 [32]. `UNVERIFIED` (not in the staff post itself; watch Creator Hub Finances).

## 6. Age, chat, and child safety

- Account bands: Kids 5-8 (all communication off by default), Select 9-15, standard 16+. Assigned by age check or by a verified parent [9].
- Unverified users: limited game access (Kids tier if self-declared 5-8, Select tier if 9+) and no chat [8][9].
- Chat: age check required globally since January 7, 2026, using facial estimation (Persona; images deleted after processing) or ID. Players chat within their own and adjacent age groups. Under-9s need parental consent [12].
- Chat analytics age groups: under 9, 9-12, 13-15, 16-17, 18-20, 21+ [13].
- Trusted Connections let age-checked 13+ users chat across age groups with people they know [12][13].
- TextChatService is required and enforced. Custom preset or quick-chat systems must filter through `TextService:FilterStringAsync`, send at most one message per 10 seconds, use at most 12 presets, be labeled as system presets, and look distinct from free chat. Noncompliant games can be sequestered [13].
- Studio: age check required for Team Create (June 11, 2026) and to play private published games (June 16, 2026). Cross-age collaboration needs trusted friends or parent permission (June 25, 2026) [14].
- November 2024 baseline: under-13s cannot DM outside games and only see public broadcast chat in games by default. Hangouts and free-form drawing were age-gated for them [17].
- Parental controls: remote linking, spend limits, screen-time limits, blocking specific games through age 15, approving specific games, managing direct chat [9][17].
- COPPA-related duties for creators: never sell or share player personal information, never build profiles on individual users, protect any data you process [2]. Ads to under-13s must be COPPA compliant [25]. Sharing personal info (emails, real names) is restricted by age [1].
- Design implications: never ask for emails, real names, ages, or socials. Design core loops to work with chat off. Use `IsContentSharingAllowed` for UGC feeds, plus `IsEndlessContentLoadAllowed` and `IsEndlessContentAutoplayAllowed` for infinite feeds [7].

## 7. IP and copyright

- Roblox removes content on a valid copyright or trademark takedown. It may also proactively delete or archive suspected infringing assets [1].
- Repeat infringers can lose their accounts [2].
- IP tools (Creator Terms 5.6): a rights holder that finds its IP in your game can request removal or offer a license that takes a share of your Robux earnings. You get a short, unspecified window to dispute. During licensing you agree not to sue the rights holder [2].
- No "Roblox", "Blox", or similar names in game, group, or user names (games published before June 22, 2022 are excepted) [2].
- Licensing platform (License Manager in Creator Hub) [30]:
  - Full game licenses (revenue share on all game earnings).
  - In-game sales licenses (live September 12, 2026; share only on licensed items sold through passes and developer products).
  - Licensed IP cannot be used in subscriptions yet.
  - When a license ends, pull the licensed items from sale. Players keep what they bought.
  - You cannot combine a full game license for one IP with an in-game sales license for another.
  - Current IPs include Kodansha titles (FAIRY TAIL, Knights of Sidonia, Ghost Encyclopedia).
  - Marketplace licenses for IP-based avatar items were announced October 8, 2026 (title only) [34].
- Meme and "brainrot" content: viral characters often have identifiable creators or brand owners who can file takedowns or use Roblox's IP tools to claim revenue [1][2]. `UNVERIFIED`: specific Roblox takedowns of brainrot or Skibidi-style games (check the Lumen Database at lumendatabase.org for notices naming roblox.com, and search DevForum for "DMCA").
- Real brands: unlicensed logos, products, or trademarks are takedown risks [1]. Paid brand placement is an ad integration and must be registered (section 8).
- Music [2][31]:
  - Upload only audio you hold rights to. Uploads pass copyright checks, and assets are private by default.
  - Roblox Licensed Music: up to 250 distinct tracks per game at once. No charging players to listen, no export. The license can be revoked at any time.
  - Partner names (for example APM, Monstercat, DistroKid, Too Lost) are `UNVERIFIED` here. One July 2026 post title mentions songs from Too Lost. Check the Creator Store Audio tab.

## 8. Advertising

### Ads you buy (Ads Manager)
- Ads must follow the Advertising Standards [1]. Since May 4, 2026 creators can run their own Ads Manager ads to all ages [25].
- Misleading ads (for example "free Robux") are banned [26].
- `UNVERIFIED`: full Advertising Standards text (the help center page returned 403; read it on en.help.roblox.com in a browser).

### Ad integrations inside your game (effective May 4, 2026) [1][25][26]
- An ad is any content published for compensation that promotes a brand, product, service, event, or persona, or that has calls to action for off-platform products. This includes your own merch and self-promotion.
- Register each campaign in Ads Manager (Ad integrations > Register). Submit assets at least 5 days ahead; review takes about 48 hours. Campaigns still in review are shown only to 18+.
- Use Roblox's standard ad labels. They must be legible within 500 studs and visible where players first meet the ad. Fully ad-based games need a HUD label and a thumbnail disclosure.
- Games may not make programmatic calls to third-party advertising or measurement services. No third-party SDKs for serving, targeting, or measurement.
- No ad personalization for under-18s. No activity profiles of users.
- Revenue share applies to campaigns starting on or after January 1, 2027. Rates are per 1,000 qualified visits: US $1.50, Tier 1 $0.75, Tier 2 $0.20, Tier 3 $0.05 for the first 28 days, then $0.10.

### Roblox-run ad units
- Immersive ads (billboards, portals): creator 13+, ID verified, 2FA, approved questionnaire, at least 2,000 unique visitors per month. Hide ad units when `AreAdsAllowed` is false. Faked impressions mean clawbacks or suspension [28].
- Rewarded video: same creator bar, and the game must be public, unrestricted, and without free-form creation. Viewers must be 13+. Disclose the ad and the reward before playback, grant immediately after completion, never gate progress, never take over the screen [27][29].
- Under-13s: no rewarded formats, no food, cosmetics, pharma, or financial ads. Ads must be contextual and sold directly via Roblox or creators. No programmatic partners [25].
- Pre-roll loading ads are announced as coming soon (not shown to Roblox Plus subscribers) [32].

## 9. Off-platform and social links

- You may not link, share, or display external URLs anywhere except the Social Links feature on game, group, or user detail pages [1][24].
- Allowed link types: Facebook, X (Twitter), YouTube, Twitch, Discord, Guilded, Roblox community. Each type once, maximum 3 per game [24].
- No handles, URLs, Discord invites, or emails in the description text or inside the game. "Join our community via the links on this page" is fine [24].
- Visible only to age-checked users 16+ (since June 30, 2026). You must be verified 16+ to add links [11][24].
- `PolicyService.AllowedExternalLinkReferences` is legacy and always returns an empty array. Do not build link UI around it [7].
- Games made solely to send users off Roblox are banned [1].

## 10. Generative AI in experiences

- No rule bans AI-generated assets. AI outputs are UGC and face the same moderation and IP rules. Roblox claims no ownership of your outputs, and you are responsible for using them [2].
- AI that talks to players (Creator Terms 3.6.1) [2]:
  - disclose that "the AI is not human";
  - disclose that output "is artificially generated, does not represent the views or advice of a human, and may be factually inaccurate";
  - avoid direct AI interaction unless it is immediately apparent;
  - follow the law and put risk controls in place.
- Roblox may restrict AI tools for certain age groups [2].
- The questionnaire asks whether users interact with generative AI, and whether that interaction is Limited or Extended [4].
- Photo-to-Avatar calls require `IsPhotoToAvatarAllowed` [7].
- The Terms reserve Roblox's right to use your content for AI training where law permits [2].

## Policy check

Each check must pass (Yes) before an agent signs off on a monetization or content design.

1. Does every paid random item show all outcomes with numeric odds totaling 100%, before purchase? [5][6]
2. Are odds shown for indirect purchases (keys, tickets, Robux-bought currency) before spend? [5]
3. Does every random outcome give some benefit (no pure-loss outcomes)? [1][6]
4. Do luck boosts or pity systems state their effect numerically and update the displayed odds live? [6]
5. Is the "Info" or "Details" label a word, not a bare (i) icon? [6]
6. Does the game check `ArePaidRandomItemsRestricted` and hide the item or offer a compliant alternative? [6][7]
7. Is trading of paid items gated by `IsPaidItemTradingAllowed`? [1][6]
8. Is the design free of any playable gambling (slots, roulette, betting), even with free currency? [1]
9. Is there zero RMT, off-platform selling, or Robux-for-cash language? [1][2]
10. Are titles, thumbnails, icons, and offers free of misleading claims (no "free Robux", no fake timers or fake scarcity)? [1][26]
11. Do tip or donation features state that players get nothing in return, and use the Transfers API instead of cross-game sales? [1][21]
12. Are there no Robux or real-money prize contests without Roblox involvement? [1]
13. Do subscriptions honor benefits for the full term, the same on every platform, with no extra tasks to unlock them? [18]
14. Are planned subscription price increases at least 60 days apart, with 30 days' notice? [18]
15. Is the questionnaire complete and accurate for the most extreme content players can see, including the AI, media, and trading questions? [3][4]
16. If the target audience is under 16, is the content Minimal, Mild, or Moderate, and does the game avoid hangout, free-form drawing, and sensitive-issue designs? [8][9]
17. Does the core loop work for players with chat off (Kids and unverified users)? [9][12]
18. Do custom quick-chat or preset systems follow the TextChatService preset rules? [13]
19. Is there no URL, handle, invite, or email anywhere in the game or description text? [1][24]
20. Is every sponsored or self-promotional placement registered, approved, and labeled in Ads Manager? [25][26]
21. Is there no third-party ad or measurement SDK or HTTP call? [1][25]
22. Is there no rewarded ad, and no food, cosmetics, pharma, or financial ad, for under-13 players? [25]
23. Do rewarded video rewards grant a non-random developer product right after completion, with no forced viewing? [27]
24. Is every character, brand, song, and meme original, licensed through the License Manager, or otherwise cleared? [1][2][30]
25. If players talk to AI, does the game disclose that it is AI, not human, and may be inaccurate? [2]

## Sources

[1] Roblox Community Standards - https://about.roblox.com/community-standards - checked 2026-11-03
[2] Roblox Terms of Use incl. Creator Terms (effective Nov 1, 2026) - https://en.help.roblox.com/hc/en-us/articles/115004647846-Roblox-Terms-of-Use - checked 2026-11-03
[3] Content maturity (Creator Docs) - https://create.roblox.com/docs/production/promotion/content-maturity - checked 2026-11-03
[4] Experience guidelines / Maturity & Compliance Questionnaire - https://create.roblox.com/docs/production/promotion/experience-guidelines - checked 2026-11-03
[5] Paid random items (Creator Docs) - https://create.roblox.com/docs/production/monetization/paid-random-items - checked 2026-11-03
[6] Clarifying Requirements for Paid Random Items (DevForum, May 26, 2026) - https://devforum.roblox.com/t/4654622 - checked 2026-11-03
[7] PolicyService API reference - https://create.roblox.com/docs/reference/engine/classes/PolicyService - checked 2026-11-03
[8] Kids and Select publishing (Creator Docs) - https://create.roblox.com/docs/production/publishing/kids-and-select - checked 2026-11-03
[9] Introducing Roblox Kids and Select accounts (Newsroom, Apr 13, 2026) - https://about.roblox.com/newsroom/2026/04/introducing-roblox-kids-and-select-accounts - checked 2026-11-03
[10] New Publishing Requirements & Evaluation Process (DevForum, Apr 13, 2026) - https://devforum.roblox.com/t/4573166 - checked 2026-11-03
[11] Roblox Kids and Select Global Launch (DevForum, Jun 16, 2026) - https://devforum.roblox.com/t/roblox-kids-and-select-global-launch-upcoming-updates-to-eligibility-ads-manager-and-expedited-review/4685717 - checked 2026-11-03
[12] Age checks required to chat (Newsroom, Jan 2026) - https://about.roblox.com/newsroom/2026/01/roblox-age-checks-required-to-chat - checked 2026-11-03
[13] Age Check to Chat fast-follow roadmap (DevForum, Mar 26, 2026) - https://devforum.roblox.com/t/4539685 - checked 2026-11-03
[14] Age Requirements for Team Create in Studio (DevForum, Mar 26, 2026) - https://devforum.roblox.com/t/4539725 - checked 2026-11-03
[15] Extending Roblox policy on romantic and sexual content (Newsroom, Aug 15, 2025) - https://about.roblox.com/newsroom/2025/08/extending-roblox-policy-on-romantic-and-sexual-content - checked 2026-11-03
[16] Updating age requirements for Restricted label (DevForum, Aug 28, 2025, upd. Nov 6, 2025) - https://devforum.roblox.com/t/3905863 - checked 2026-11-03
[17] Major updates to safety systems and parental controls (Newsroom, Nov 18, 2024) - https://about.roblox.com/newsroom/2024/11/major-updates-to-our-safety-systems-and-parental-controls - checked 2026-11-03
[18] Subscriptions (Creator Docs) - https://create.roblox.com/docs/production/monetization/subscriptions - checked 2026-11-03
[19] Developer products (Creator Docs) - https://create.roblox.com/docs/production/monetization/developer-products - checked 2026-11-03
[20] Developer Exchange (Creator Docs) - https://create.roblox.com/docs/production/monetization/developer-exchange - checked 2026-11-03
[21] Disabling Cross-Game Sales and Introducing the Transfers API (DevForum, May 4, 2026) - https://devforum.roblox.com/t/4618396 - checked 2026-11-03
[22] Update on Roblox Plus, Transfers, and Community Gifting (DevForum, May 15, 2026) - https://devforum.roblox.com/t/4637912 - checked 2026-11-03
[23] Managed Pricing (DevForum, Jun 15, 2026) - https://devforum.roblox.com/t/4684738 - checked 2026-11-03
[24] Social media links (Creator Docs) - https://create.roblox.com/docs/production/promotion/social-media-links - checked 2026-11-03
[25] New Advertising Policies & Standards (DevForum, Mar 20, 2026) - https://devforum.roblox.com/t/4527365 - checked 2026-11-03
[26] Ad integrations (Creator Docs) - https://create.roblox.com/docs/production/promotion/ad-integrations - checked 2026-11-03
[27] Rewarded video ads (Creator Docs) - https://create.roblox.com/docs/production/promotion/rewarded-video-ads - checked 2026-11-03
[28] Immersive ads (Creator Docs) - https://create.roblox.com/docs/production/monetization/immersive-ads - checked 2026-11-03
[29] More Creators Can Now Use Rewarded Video Ads (DevForum, Jul 24, 2025) - https://devforum.roblox.com/t/more-creators-can-now-use-rewarded-video-ads/3838678 - checked 2026-11-03
[30] Licensing Platform Update: In-Game Sales License (DevForum, Sep 12, 2026) - https://devforum.roblox.com/t/4868288 - checked 2026-11-03
[31] Audio assets (Creator Docs) - https://create.roblox.com/docs/audio/assets - checked 2026-11-03
[32] RDC26: What We Announced (DevForum, Sep 11, 2026) - https://devforum.roblox.com/t/4865880 - checked 2026-11-03
[33] Korea's loot box rules push Roblox to disclose odds worldwide (TechTimes, Jun 26, 2026, secondary) - https://www.techtimes.com/articles/319148/20260626/koreas-loot-box-rules-push-roblox-disclose-item-odds-worldwide.htm - checked 2026-11-03
[34] Create IP-Based Avatar Items With Marketplace Licenses (DevForum, Oct 8, 2026, title only) - https://devforum.roblox.com/t/4921794 - checked 2026-11-03
[35] New Transaction Refunded Webhook (DevForum, Sep 23, 2026, title only) - https://devforum.roblox.com/t/4890339 - checked 2026-11-03
