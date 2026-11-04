# Roblox UX Standards

Last checked: 2026-11-03. Sources at bottom.

Scope: player-facing UX rules for Roblox experiences. UI designers, UI programmers, and the QA look check use this page. Policy detail lives elsewhere; this page covers UX.
Labels: `[n]` = sourced. `HEURISTIC` = house standard, not stated by any source. `UNVERIFIED` = could not confirm, with how to verify.

## TL;DR for agents

- Design for a landscape phone first. Mobile is the majority surface (about 80% of 2024 DAUs per a secondary report [5]). Apple and Google stores took 44% of 2025 revenue [4]. Landscape is the default orientation [24].
- On a notched phone, the safe area for interactive UI is about 733x313 px out of 851x392. Roblox reserves 58 px at the top and about 59 px on each side [15]. Never hardcode these numbers. Use `ScreenInsets = CoreUISafeInsets` (the default) and `GuiService.TopbarInset` [12][14][15].
- Keep two zones clear of UI: the jump button (70 to 72 px, bottom right) and the dynamic thumbstick zone (left 40% of width, bottom two thirds of height in landscape) [26][27].
- Touch targets are at least 44x44 px, and primary HUD actions are at least 60 px. Text is at least 14 px on phones. Roblox's own floor is 9 px, and that is never acceptable [20][51][52]. HEURISTIC for the 14/60 values.
- Players are young. Of age-checked users, 34% are under 13 and 37% are 13 to 17 (Q3 2026) [1]. Chat now requires an age check [7]. Write short words, pair every label with an icon, and offer ways to communicate without chat.
- Branch on input with `UserInputService.PreferredInput`, not `TouchEnabled` [28][29]. Every action needs a touch path, a gamepad path, and a keyboard/mouse path. Prompts must show the active device's glyph (`InputActionLabel`) [23][33].
- First 60 seconds: get the player controlling the character fast, show one clear goal, and give a reward early. Players decide within minutes [8]. Sessions of 0 to 3 minutes retain worst (D1 median 4.31%) [6].
- Shop: prompt only after a clear player action. Read prices from `GetProductInfo`, never hardcode them. Use no fake or restarting timers and no urgent copy aimed at minors [40][42][43].
- Respect `PreferredTextSize`, `PreferredTransparency`, and `ReducedMotionEnabled`. `TextScaled` ignores PreferredTextSize, so avoid it [21][45].
- UI images are at most 512x512 unless they are large on screen, and at most 256x256 for minor icons. Use sprite sheets. The frame budget is 16.67 ms at 60 FPS [49][50].

## 1. Audience: who you are designing for

### 1.1 Headline platform numbers

| Metric | Value | Period | Src |
|---|---|---|---|
| DAUs | 138M (down 9% YoY, up 12% QoQ) | Q3 2026 (ended 2026-09-30) | [1] |
| DAUs | 123M (up 10% YoY) | Q2 2026 | [2] |
| Hours engaged | nearly 34B (down 15% YoY) | Q3 2026 | [1] |
| Hours per DAU per day | 2.7 | FY2025 | [4] |
| Bookings | $1,697M (down 12% YoY) | Q3 2026 | [1] |
| In-experience chat | 1.6B messages/day | Q3 2026 | [1] |

### 1.2 Device split

- The Q2 and Q3 2026 letters do not report a device split [1][2].
- 10-K FY2025: "significant use of our Platform on mobile devices". 29% of revenue came through the Apple App Store and 15% through Google Play [4].
- 2024: about 80% of DAUs on mobile, 17% PC, 3% console. Source is PocketGamer.biz citing Roblox's annual report (2025-04-23) [5]. UNVERIFIED in a primary filing. Verify: search the Roblox 2024 annual report on ir.roblox.com for "mobile".
- GameAnalytics benchmark (titles with more than 1M MAU, about 47% of engagement, Jan 2023 to Jul 2025): 48.39% of players use PC and mobile, 37.56% PC only, 7 to 10% mobile only, about 2% console (2025) [6]. The dataset is SDK-instrumented games only. Its PC share conflicts with [5]. Reading: many players switch devices, so UI must hold up on both.
- VR share: not reported. UNVERIFIED. Treat VR as out of scope unless the game targets Quest.

### 1.3 Age

| Cohort (of age-checked users) | Q3 2026 [1] | Q2 2026 [2] | Jan 2026 [7] |
|---|---|---|---|
| Under 13 | 34% | 35% | 35% |
| 13 to 17 | 37% | 38% | 38% |
| 18+ (O18) | 29% | 27% | 27% |
| Share of DAUs age-checked | 64% | 57% | 45% |

- More than 80% of DAUs aged 13 to 17 have age-checked. U.S. O18 is 37% of age-checked DAUs (Q3 2026) [1].
- Inference: teens are over-represented among checked users because chat requires an age check [7]. The real under-13 share of all DAUs is probably above 34%. Design reading level for 8 to 12 year olds.
- Pre-age-check basis: 13+ was about 64% of DAUs in Q2 2025. UNVERIFIED. Verify: Q2 2025 letter, sec.gov `q225shletterex992.htm`.

### 1.4 Region

- Q3 2026 revenue by billing country: US/Canada 57%, Europe 21%, APAC 12%, rest of world 10% [3].
- Fastest DAU growth, Q3 2026 YoY: India +37%, Japan +33%, Saudi Arabia +30%, Germany +13%, France +12% [1]. Q2 2026: Japan +67%, India +64%, US/Canada +6% [2].
- Regional DAU split: shown only as chart images in the letter. UNVERIFIED. Verify: supplemental materials on ir.roblox.com.
- Implication: growth is outside English-speaking markets, and those markets are often on low-end Android. Localize everything (section 7) and budget for weak devices (section 8).

### 1.5 Default assumption

- Primary target: a landscape phone around 852x393 logical px, held with two thumbs, reached by a 10 year old reader.
- Secondary targets: 1920x1080 desktop with mouse, then 1080p TV with gamepad.
- Why: mobile dominates DAUs [5] and app-store revenue [4]. Phones are the tightest case (smallest safe area, touch occlusion, weak GPU). A layout that works there scales up with constraints. A desktop-first layout rarely scales down.

## 2. First 60 seconds

### 2.1 What the sources say

- "New players typically decide their interest in a game within minutes." Teach the core loop: what to do and why [8].
- Keep early level thresholds low so progress shows right away. Give starter items or soft currency. End onboarding on a designed moment of joy [8].
- Measure D1 in the Player Funnel. A/B test tutorial steps (Roblox's example: a shorter dialogue vs a guided arrow) [8].
- D1 retention by median session length (2025): 0 to 3 min 4.31%, 7 to 12 min 7.91%, 19 to 24 min 11.46% [6].
- The 25th-percentile session fell to about 2 minutes by mid-2025. The benchmark advises "Win the first two minutes" with a mini-goal the player can complete right away [6].
- Examples Roblox cites: Super Striker League shows on-screen control prompts. Jailbreak highlights season-exclusive items in a pass pop-up [8].

### 2.2 Target timings (all HEURISTIC, no source gives numbers)

| Milestone | Target (mid-range phone) |
|---|---|
| Custom loading screen visible | First rendered frame (lives in ReplicatedFirst) |
| Join to controllable character | 15 s or less |
| Spawn to first meaningful action | 10 s or less |
| First reward or visible progress | 60 s or less |
| Pop-ups on first spawn | At most 1 (and it is the goal, not a shop) |
| First purchase offer | Not before the first reward. Never in the first 60 s |

### 2.3 Onboarding rules

- Show, don't tell. Teach with world cues (beams, arrows, highlighted targets) and one short line. HEURISTIC: 12 words or fewer per tutorial step, one step on screen at a time.
- Show control hints for the active device only (section 4).
- Use contextual prompts (ProximityPrompt) instead of permanent buttons [18].
- Returning players skip the tutorial. Store a completion flag. HEURISTIC.
- Spawn facing the core activity, with the first goal in camera view and no UI over the center of the screen. HEURISTIC.

### 2.4 Loading screens

- Put the loading `ScreenGui` and its `LocalScript` in `ReplicatedFirst`. It replicates before anything else [9][10]. Objects that script needs must also live in ReplicatedFirst, or they replicate late [10].
- `ReplicatedFirst:RemoveDefaultLoadingScreen()` removes the Roblox screen immediately. Call it only if you show your own, or players see geometry pop in [10].
- If anything sits in ReplicatedFirst, the default screen is removed "after a few seconds" whether or not you call the method [10].
- The doc pattern sets `IgnoreGuiInset = true` on the loading screen, waits on `game:IsLoaded()` / `game.Loaded`, then destroys it [9]. The doc's `task.wait(5)` minimum is sample code, not a rule. HEURISTIC: hold the screen only as long as loading needs, plus at most about 1 s for a brand beat.
- `ContentProvider:PreloadAsync`: preload only essentials (loading-screen art, core UI, the start area), not the whole Workspace. Pop-in is acceptable [11].
- Let players skip the loading screen, or skip it automatically after a set time [11]. HEURISTIC: show a Skip button after 5 s.
- Do not drive progress bars from `RequestQueueSize`, because it rises and falls. Preload assets one at a time and count them [11].
- `PreloadAsync` does not cover SurfaceAppearance or MaterialVariant [11].

| Preload choice | Gain | Cost |
|---|---|---|
| Nothing | Fastest entry | Blank or flickering UI icons on first open |
| Core UI and spawn area | Clean first frame | A few seconds more |
| Whole Workspace | Little pop-in | Long wait, more drop-off, memory pressure |

## 3. Layout

### 3.1 Orientation

- Default `StarterGui.ScreenOrientation = LandscapeSensor`: always landscape, flipped to stay upright [24].
- Other modes: `Sensor` (landscape and portrait), `LandscapeLeft`, `LandscapeRight`, `Portrait`. Roblox has no upside-down portrait [24].
- Change it at runtime with `PlayerGui.ScreenOrientation`. Changing StarterGui does not affect players already in the game [24].
- If you allow portrait, every screen needs a portrait layout check. Otherwise leave the default.

### 3.2 Safe areas, notches, topbar

| `ScreenGui.ScreenInsets` | Value | Use |
|---|---|---|
| `None` | 0 | Full screen, ignores cutouts. Only for non-interactive art (backgrounds) [13][14] |
| `DeviceSafeInsets` | 1 | Avoids notches but not Roblox core UI [13] |
| `CoreUISafeInsets` | 2 | Default. Avoids notches and the topbar. Use it for buttons and status text [12][13] |
| `TopbarSafeInsets` | 3 | The free strip inside the topbar, right of the Roblox controls. Dynamic size [12][13] |

- `IgnoreGuiInset` (default false) is linked to ScreenInsets. Setting it true while on CoreUISafeInsets switches ScreenInsets to DeviceSafeInsets [14].
- `ClipToDeviceSafeArea` (default true) clips descendants to the device safe area. It has no effect with `None` [14].
- `SafeAreaCompatibility` (default `FullscreenExtension`) auto-stretches legacy full-screen frames. Roblox says to avoid it for new work and use ScreenInsets instead [14].
- `GuiService.TopbarInset` is a Rect for the free topbar area. It changes at runtime (health bar, `SetCoreGuiEnabled`, control changes), so listen with `GetPropertyChangedSignal("TopbarInset")` [15].
- `GuiService:GetInsetArea(insets)` returns the usable Rect for any ScreenInsets value. `GetGuiInset()` still works and is not deprecated [15].
- Topbar height: Roblox raised the reserved space from 36 px to 58 px for tap-target accessibility (staff, 2023). It "may vary by device and screen size" [16]. Staff said in Oct 2024 that some users still had the old topbar on purpose [17]. Never hardcode 36 or 58.
- Reference numbers from Roblox's own `GetInsetArea` example on a mobile screen [15]:

| Area | Rect (relative to the CoreUISafe origin) | Meaning |
|---|---|---|
| None (full screen) | -59, -58 to 792, 334 | Screen about 851x392 |
| DeviceSafeInsets | 0, -58 to 733, 313 | 59 px side insets, 21 px bottom inset |
| CoreUISafeInsets | 0, 0 to 733, 313 | Usable area for interactive UI: about 733x313 |
| TopbarSafeInsets | 164, -58 to 733, 0 | Topbar strip free to the right of x=164 |

- Inference: Roblox UI px on phones match OS logical points, since 851x392 matches an iPhone 14 Pro (852x393 pt). UNVERIFIED. Verify: print `workspace.CurrentCamera.ViewportSize` on a real device.

### 3.3 Default mobile controls (do not cover)

- Roblox reserves the bottom-left and bottom-right corners for the default controls. Keep important info and buttons out of them [18][19].
- Jump button, phone (shorter screen side 500 px or less) [26]:
  - Classic layout: 70x70 px, right edge 25 px from the frame edge, bottom 20 px from the bottom.
  - Newer "avatar abilities" layout: 72x72 px, inset 64 px from the right and bottom.
  - Tablet: 120 px.
- Dynamic thumbstick touch zone, landscape: left 40% of width, bottom two thirds of height. Portrait: full width, bottom 40% [27]. A touch anywhere in that zone starts movement, so buttons there catch the thumb.
- Place custom action buttons relative to the jump button. Roblox's sample uses 0.8x the jump size, 20 px to its left [18].
- `GuiService.TouchControlsEnabled` toggles the default touch controls [15].
- Values come from PlayerModule source mirrored on 2026-11-03 and can change with client updates [26][27].
- House zones (HEURISTIC):
  - Jump zone: the bottom-right 200x200 px of the safe area. Only deliberately clustered action buttons go here, and none overlap the jump button.
  - Thumb rest zone: the bottom-left 35% of width by 50% of height. No tappable UI.
  - A narrow button column on the left edge (15% of width or less), centered vertically, is acceptable.

### 3.4 Touch targets

| Baseline | Size |
|---|---|
| Apple iOS default / minimum control | 44x44 pt / 28x28 pt [51] |
| Android | 48x48 dp minimum [52] |
| WCAG 2.2 SC 2.5.8 (AA) | 24x24 CSS px minimum, or enough spacing [54] |
| Roblox jump button (phone) | 70 to 72 px [26] |
| Our standard (HEURISTIC) | Any tappable 44 px or more on the short side. Primary HUD actions 60 px or more. 8 px or more between targets |

- The hit box can be larger than the art. Wrap small icons in a transparent 44 px button. HEURISTIC.

### 3.5 Thumb zones

- Most phone players use two thumbs: one on the thumbstick, one on jump [18].
- Reach differs between phones and tablets. A button 40% from the top is reachable on a phone and nearly unreachable on a tablet [18].
- Landscape map (HEURISTIC):

| Region | Put here |
|---|---|
| Top center | Read-only info (timer, objective) |
| Top right, below the topbar | Currency, settings |
| Left edge, mid height | Menu buttons (shop, inventory) |
| Right side around jump | Frequent actions (attack, ability, interact) |
| Screen center (middle 50%) | Nothing persistent during gameplay |

- Hide controls until they matter, and keep the HUD sparse on mobile [18].

### 3.6 Scale vs offset, constraints, text

- Scale is a percentage of the parent. Offset is pixels. They add together [19].
- Place with Scale plus `AnchorPoint` (for example, anchor (1,0) at scale X=1 for a top-right counter) [19][22].
- Size by scale, then lock proportions with `UIAspectRatioConstraint` and cap with `UISizeConstraint`. Pure scale can blow up: a 75%-wide container is huge on a 4K TV [22].
- Constraints override layout objects such as UIListLayout [20].
- `UIScale` multiplies a subtree's size, which is useful for global density and hover tweens [20]. HEURISTIC pattern: author in offset at a 1280x720 reference and apply one UIScale computed from the viewport, clamped to 0.6 to 1.5. Then re-check that targets still meet 44 px.
- Use `GuiService.ViewportDisplaySize` (Small/Medium/Large) to pick layouts, not pixel guesses [15][22].
- `TextScaled` pitfalls [21][45]:
  - It ignores TextSize, forces TextWrapped, and grows to 100 without a constraint.
  - It ignores PreferredTextSize.
  - Text can become unreadable.
  - Roblox recommends AutomaticSize instead. Do not combine AutomaticSize and TextScaled.
- If you must use TextScaled, add a `UITextSizeConstraint`. Roblox says MinTextSize must never be below 9 [20]. House rule: 14 or more on phones (HEURISTIC).
- Text size standard on phones (HEURISTIC, informed by the Apple 11 pt minimum and 17 pt default [51]):

| Text role | Minimum |
|---|---|
| Body, labels | 14 px |
| Button labels | 16 px |
| HUD numerals (currency, timer, HP) | 18 px |
| Headings | 24 px |
| Console at 1080p | 26 px [55] |
| PC at 1080p | 18 px [55] |

### 3.7 Test resolution matrix

- The Studio Device Simulator (beta) groups phones as Flagship, Mid-range, and Entry level. It supports custom devices up to 7680x4320, a Rotate button, and on-screen keyboard height [25].
- Exact built-in device list: UNVERIFIED. Verify: Device Manager > Standard list in Studio.
- Logical sizes to test (HEURISTIC, from public device specs, landscape):

| Device class | Logical px |
|---|---|
| Small Android (entry) | 640x360 |
| iPhone SE | 667x375 |
| iPhone 14/15 class | 844x390 to 852x393 |
| Large phone | 932x430 |
| iPad | 1180x820 |
| Desktop | 1920x1080 |
| Console/TV | 1920x1080, and 3840x2160 for cap checks |

## 4. Input parity

- `UserInputService.PreferredInput` gives `KeyboardAndMouse` (0), `Gamepad` (1), `Touch` (2), or `MicroGamepad` (3, gamepads without a thumbstick such as TV remotes) [29].
- Read PreferredInput at start and react to its change signal [28].
- `TouchEnabled` is not a mobile check, because it is true on touch laptops. `GetLastInputType()` flips between mouse and keyboard [28].
- Every action must work with touch, gamepad, and keyboard. Prompts follow the active input method [23].
- `InputActionLabel` renders the right key or glyph for an `InputAction` and updates when the device changes [33].
- The Input Action System (InputAction/InputBinding) went to "[Client Beta] available to publish" [34]. Current release status: UNVERIFIED. Verify: the create.roblox.com Input Action System page header.
- Without IAS, use `UserInputService:GetImageForKeyCode()` and `GetStringForKeyCode()` for glyphs [33].
- Gamepad defaults [28][30]:
  - ButtonA accepts GUI selections and prompts. ButtonB cancels.
  - The Select button toggles UI selection mode.
  - Start is reserved for the Roblox menu and cannot be overridden.
  - The thumbstick or D-pad navigates UI.
- Gamepad navigation APIs [15][31][32]:
  - `GuiService.SelectedObject` is the focused object.
  - `GuiService:Select(parent)` focuses the visible descendant with the lowest `SelectionOrder`.
  - `AddSelectionParent` and `AddSelectionTuple` define groups.
  - `AutoSelectGuiEnabled` and `GuiNavigationEnabled` control navigation.
  - `GuiObject.Selectable` and `NextSelectionUp/Down/Left/Right` set explicit routes.
  - `SelectionImageObject` sets the per-object focus ring. `PlayerGui.SelectionImageObject` sets it globally.
  - `SelectionGroup` with `SelectionBehavior*` set to `Stop` traps focus inside a modal. The default `Escape` lets focus leave.
- Rules (HEURISTIC):
  - Opening any menu on gamepad calls `GuiService:Select(menu)`.
  - Closing a menu restores focus or sets `SelectedObject = nil`.
  - Modals trap focus.
  - The focus ring stays visible against every background.
- Ten-foot UI: `IsTenFootInterface()` exists, but Roblox says not to use it to detect consoles. Use `ViewportDisplaySize` [15]. TV text is 26 px or more at 1080p [55]. TV targets around 66 pt by tvOS reference [51].
- Touch buttons from `ContextActionService:BindAction(..., true)` appear near the jump button, and `SetPosition`/`SetImage`/`SetTitle` adjust them. UNVERIFIED this session. Verify: ContextActionService reference. Prefer custom buttons placed relative to jump [18].
- Haptics: use `HapticEffect` (Type such as `UIClick` or `GameplayCollision`, then `:Play()`) on supported phones and controllers [24][30].
- Keyboard/mouse: show hotkeys on buttons, keep hover states, and make every key action also clickable. HEURISTIC.

## 5. Social UX

- Invites [35]:
  - Check `SocialService:CanSendGameInviteAsync()` in `pcall`. Hide the invite button if it returns false.
  - Then call `PromptGameInvite(player, ExperienceInviteOptions)`.
  - `PromptMessage` that overflows the UI is not shown. Keep it short.
  - `InviteUser` targets one friend. `InviteMessageId` uses a Creator Dashboard notification string with `{experienceName}`.
  - `LaunchData` is 200 characters or fewer, read on the server via `GetJoinData()`. It can take a few seconds to arrive.
- When to invite (HEURISTIC): after a shared high point (win, unlock, boss). Never at spawn, never modal, never more than once per session unprompted.
- Parties [36]:
  - `Player.PartyId` is an empty string when the player is not in a party.
  - `SocialService:GetPlayersByPartyId` covers this server. `GetPartyAsync` covers all servers.
  - Test with the Studio Party Simulator.
  - HEURISTIC: keep party members on the same team and teleport group.
- Private servers [37]:
  - They can be free (toggle off Requires Robux) or a monthly Robux subscription. Roblox Plus subscribers get paid private servers at no cost.
  - Under-13 players may be blocked by parental settings.
  - A price change cancels all subscriptions.
- Friend joined (HEURISTIC): show a non-blocking toast below the topbar for 3 to 4 s. `GuiService:SendNotification` supports Title, Text, Icon, and Buttons [15].
- Emotes: `GuiService:SetEmotesMenuOpen` / `GetEmotesMenuOpen` [15]. Keep the emote menu available unless the genre forbids it. HEURISTIC.
- Chat [38]:
  - Use `TextChatService`. It has four UI configs: ChatWindow, ChatInputBar, ChannelTabs, and BubbleChat.
  - Default channels are RBXGeneral and RBXSystem. Duplicate channel names break the default window.
  - Custom chat must use Roblox's native systems. TextChatService filters automatically.
- Chat requires an age check (since January 2026). Trusted Connections can chat across age groups [7]. In Q3 2026, 64% of DAUs had age-checked [1].
- Inference: roughly a third of players may be unable to chat. Give them quick pings, emotes, and preset callouts. HEURISTIC.
- Legacy chat status: UNVERIFIED this session. Verify: the `TextChatService.ChatVersion` reference. Ship TextChatService regardless.
- Filter every other piece of user text: TextBox input, pet names, signs, and external data. Use `TextService:FilterStringAsync` then `GetNonChatStringForBroadcastAsync` or `GetNonChatStringForUserAsync`, after submit and not per keystroke. Unfiltered games get removed [39].

## 6. Shop and monetization UX

### 6.1 Roblox rules that are UX rules

- Users "must never be misled, confused, or pressured into purchases". Discounts must be genuine. No countdown that is inaccurate or restarts for the same item [40].
- Use neutral copy with minors: "View Item", not "GET IT NOW" [40].
- Prompt purchases only in response to a clear user action (button, vendor NPC). Check `IsForSale` first [42].
- Show name, price, and description from `GetProductInfo`. Never hardcode prices: price optimization and per-user prices only work through `MarketplaceService` [42][43].
- Price optimization needs about 60,000 transactions in 30 days [43].
- Gate with `PolicyService:GetPolicyInfoForPlayerAsync` (in pcall, rate-limited) [44]:
  - `ArePaidRandomItemsRestricted`
  - `IsPaidItemTradingAllowed`
  - `AreAdsAllowed`
  - `IsEligibleToPurchaseSubscription`
  - `IsEligibleToPurchaseCommerceProduct`
- HEURISTIC: hide gated items entirely rather than showing a dead button.

### 6.2 Placement and value

- The shop icon matches the UI style. Players jump in and out "without feeling disrupted" [41].
- Show context and value for every item, not just name and price. Doors explains what Revives do [41].
- A starter pack is an offer seen "within the first few minutes after joining" [41]. HEURISTIC: show it only after the first reward and at most once per session.
- Rotate stock on updates. Season passes show time remaining, both tracks, and a reward preview [41].
- Personalize order with `RankProductsAsync` (once at join) and `RecommendTopProductsAsync` (top picks, in `task.spawn`) [42].
- Product icons are 512x512 or smaller, with nothing important outside the circle [42].
- HEURISTIC conversion patterns that stay fair:
  - Anchor with a real reference price. Show the per-unit value on bundles ("3 for the price of 2" only if true).
  - Put the best-value tier in the middle and mark it with a label, not a timer.
  - Show the exact Robux price on every button.
  - One purchase CTA per panel.
- HEURISTIC: never interrupt play.
  - No prompts during combat or movement.
  - Offers appear in lobbies, after rounds, or at natural failure points (a revive offer on death is acceptable if dismissing it costs one tap).
  - Every offer has a close button 44 px or larger, visible immediately.

## 7. Accessibility

| Player setting | API | Do this [45][15] |
|---|---|---|
| Text Size | `GuiService.PreferredTextSize` (Medium default, then Large, Larger, Largest) | Use AutomaticSize and TextWrapped so layouts grow. TextScaled ignores it |
| Background Transparency | `GuiService.PreferredTransparency` (1 default, 0 = opaque) | Multiply each BackgroundTransparency by it |
| Reduced Motion | `GuiService.ReducedMotionEnabled` | Set tween time to 0, or swap motion for a fade |

- Contrast: 4.5:1 for text under 18 pt, 3:1 for large or bold text [53][51][52]. Roblox asks for "sufficient color contrast" with no number [45].
- Text over the 3D world needs a backing plate or outline. XAG shows the outline approach [55].
- Color: over 5% of people have some color blindness. Pair every color state with an icon, shape, or label [45].
- Sound: never signal an event by audio alone. Provide separate volume groups for SFX, music, and speech [45].
- Captions: no native caption system for game audio was found this session. UNVERIFIED. Verify: search create.roblox.com for "captions". HEURISTIC: build a subtitle line for any voiced or story audio, 18 px or larger on a 60% opaque plate.
- Localization [47]:
  - Automatic translation covers 18 languages.
  - Text capture needs `AutoLocalize`. For TextBox, only PlaceholderText is captured.
  - Text baked into images is never translated. Do not put words in images.
- Text expansion (IBM data via W3C) [48]:
  - 200 to 300% for strings of 10 characters or fewer.
  - 180 to 200% for 11 to 20 characters.
  - 130% for strings over 70 characters.
  - Use reflowing, non-fixed containers.
- Reading level (HEURISTIC; under-13 users are at least 34% of age-checked users [1]):
  - 8 words or fewer per instruction line, common words, numbers over prose.
  - Sentence case, not full caps [55].
  - Icon plus word on every button.

## 8. Performance UX

- Frame budget: 16.67 ms at 60 FPS [49]. HEURISTIC: UI scripts take 2 ms or less per frame on the entry phone. No per-frame UI updates without a reason; use events. Roblox advises running code on `RunService` events sparingly [50].
- Low-end phones crash from memory pressure. Pick a baseline device and test on it all through development. Studio does not reflect client memory accurately [49].
- Use the Simulator's Entry level phones for layout checks only [25].
- Images [50]:
  - Memory scales with pixel count: 1024x1024 uses 4x the memory of 512x512.
  - Use 512x512 at most unless the image is large on screen, and under 256x256 for minor images.
  - Pack small icons into sprite sheets (`ImageRectOffset`/`ImageRectSize`).
- Avoid heavy partial transparency layering (overdraw). Roblox advises 0 or 1 transparency where possible [49].
- Loading feedback:
  - Show per-asset progress [11].
  - HEURISTIC: placeholder tiles for shop thumbnails, a pending state on any remote-backed button within 100 ms, and a timeout message after 10 s.
- Test UI under latency with the Studio Network Simulator [25]. Check render stats with Shift+F2 [50].

## 9. Look check rubric

Run each check on two screenshots: phone (852x393 notched, plus 640x360 entry) and desktop (1920x1080). Add TV (1920x1080 gamepad) if console is enabled. Each check passes or fails.

| # | Check | Pass condition |
|---|---|---|
| 1 | Safe area | No tappable element within the notch inset (about 59 px) or the bottom inset (about 21 px) on the notched phone |
| 2 | Topbar | No custom UI overlaps Roblox topbar controls. Nothing in the top 58 px except via TopbarSafeInsets |
| 3 | Insets mode | Every interactive ScreenGui uses CoreUISafeInsets (or TopbarSafeInsets). `None` only on non-interactive art |
| 4 | Touch size | Every tappable is 44 px or more on its short side at 852x393 and 640x360 |
| 5 | Primary actions | Main HUD actions are 60 px or more and sit within reach of the jump button |
| 6 | Spacing | 8 px or more between adjacent tappables |
| 7 | Jump zone | Nothing overlaps the jump button bounds. Only action buttons in the bottom-right 200x200 px |
| 8 | Thumb zone | No tappable in the bottom-left 35% of width by 50% of height |
| 9 | Center clear | No persistent UI in the middle 50% of the screen during gameplay |
| 10 | HUD density | HUD covers 20% of screen area or less on the phone during gameplay |
| 11 | Text floor | No text under 14 px on the phone, none under 9 px anywhere, HUD numerals 18 px or more |
| 12 | TV text | All text is 26 px or more at 1080p in the TV screenshot |
| 13 | Contrast | Text under 18 pt has 4.5:1 or more against its actual background. Icons and large text have 3:1 or more |
| 14 | Color independence | Every color-coded state also has an icon, shape, or label |
| 15 | No clipping | No truncated or overflowing text (TextFits true) at default size and at PreferredTextSize Largest |
| 16 | Localization | No clipping in a pseudo-localized build (+40% length) and no words baked into images |
| 17 | Scaling caps | At 1920x1080 and 4K, no modal wider than 60% of the screen. Icons are not stretched (aspect ratio locked) |
| 18 | Input glyphs | Prompts match the device in each screenshot: no "Press E" on phone or gamepad, no touch icon on PC |
| 19 | Gamepad focus | With a menu open on gamepad, a visible focus ring sits on one element. B closes the menu |
| 20 | Modal close | Every modal shows a close control 44 px or larger, inside the safe area, without waiting |
| 21 | Shop honesty | Prices are live text, not baked art. No restarting or fake timers. No urgent full-caps CTAs |
| 22 | No surprise prompts | No purchase prompt or invite prompt appears without a player tap |
| 23 | First spawn | The first objective is visible in 12 words or fewer. At most 1 pop-up. No shop offer |
| 24 | Loading | A custom loading screen shows on the first frame with moving progress. Skip appears by 5 s |
| 25 | Reduced motion | With ReducedMotionEnabled on, no looping bounces, shakes, or slide-ins remain |

## Open items

- Device split: no 2025 or 2026 primary figure. Verify: ir.roblox.com supplemental materials or the investor day deck.
- Regional DAU split for Q3 2026: shown in chart images only. Verify: the letter images or the supplemental XLS.
- Input Action System release status, ContextActionService touch-button details, legacy chat status, and native captions were not rechecked this session (fetch limit). Verify on the create.roblox.com reference pages named above.

## Sources

[1] Roblox Q3 2026 Earnings Shareholder Letter (8-K Ex. 99.1, 2026-10-29) - https://www.sec.gov/Archives/edgar/data/0001315098/000162828026068235/ex991-q32026earningsshar.htm - checked 2026-11-03
[2] Roblox Q2 2026 Earnings Shareholder Letter (8-K Ex. 99.1, 2026-07-30) - https://www.sec.gov/Archives/edgar/data/0001315098/000162828026051059/ex991-robloxq22026earnin.htm - checked 2026-11-03
[3] Roblox Form 10-Q, quarter ended 2026-09-30 - https://www.sec.gov/Archives/edgar/data/0001315098/000162828026068253/rblx-20260930.htm - checked 2026-11-03
[4] Roblox Form 10-K FY2025 - https://www.sec.gov/Archives/edgar/data/1315098/000131509826000024/rblx-20251231.htm - checked 2026-11-03
[5] PocketGamer.biz, 80% of Roblox users are on mobile, contributing 46% of Robux revenue (2025-04-23) - http://www.pocketgamer.biz/80-of-roblox-users-are-on-mobile-contributing-46-of-robux-revenue/ - checked 2026-11-03
[6] InvestGame and GameAnalytics, The 2025 Roblox Benchmark Report - https://investgame.net/news/pdf/the-2025-roblox-benchmark-report/ - checked 2026-11-03
[7] Roblox Newsroom, Moving Beyond Self-Reported Age (2026-02-05) - https://about.roblox.com/newsroom/2026/02/moving-beyond-self-reported-age - checked 2026-11-03
[8] Roblox Creator Docs, Onboarding - https://create.roblox.com/docs/production/game-design/onboarding - checked 2026-11-03
[9] Roblox Creator Docs, Loading screens - https://create.roblox.com/docs/players/loading-screens - checked 2026-11-03
[10] Roblox Creator Docs, ReplicatedFirst - https://create.roblox.com/docs/reference/engine/classes/ReplicatedFirst - checked 2026-11-03
[11] Roblox Creator Docs, ContentProvider - https://create.roblox.com/docs/reference/engine/classes/ContentProvider - checked 2026-11-03
[12] Roblox Creator Docs, On-screen UI containers - https://create.roblox.com/docs/ui/on-screen-containers - checked 2026-11-03
[13] Roblox Creator Docs, ScreenInsets enum - https://create.roblox.com/docs/reference/engine/enums/ScreenInsets - checked 2026-11-03
[14] Roblox Creator Docs, ScreenGui - https://create.roblox.com/docs/reference/engine/classes/ScreenGui - checked 2026-11-03
[15] Roblox Creator Docs, GuiService - https://create.roblox.com/docs/reference/engine/classes/GuiService - checked 2026-11-03
[16] DevForum (staff), Studio Beta for Experience Controls Available Now (2023-08-28) - https://devforum.roblox.com/t/studio-beta-for-experience-controls-available-now/2567355 - checked 2026-11-03
[17] DevForum, Inconsistent Top Bar (2024-10) - https://devforum.roblox.com/t/inconsistent-top-bar/3228098 - checked 2026-11-03
[18] Roblox Creator Docs, Cross-platform design (UI) - https://create.roblox.com/docs/ui/cross-platform-design - checked 2026-11-03
[19] Roblox Creator Docs, Position and size UI objects - https://create.roblox.com/docs/ui/position-and-size - checked 2026-11-03
[20] Roblox Creator Docs, Size modifiers and constraints - https://create.roblox.com/docs/ui/size-modifiers - checked 2026-11-03
[21] Roblox Creator Docs, TextLabel - https://create.roblox.com/docs/reference/engine/classes/TextLabel - checked 2026-11-03
[22] Roblox Creator Docs, Cross-platform development - https://create.roblox.com/docs/projects/cross-platform - checked 2026-11-03
[23] Roblox Creator Docs, Adaptive design guidelines - https://create.roblox.com/docs/production/publishing/adaptive-design - checked 2026-11-03
[24] Roblox Creator Docs, Mobile input - https://create.roblox.com/docs/input/mobile - checked 2026-11-03
[25] Roblox Creator Docs, Device Simulator - https://create.roblox.com/docs/studio/device-simulator - checked 2026-11-03
[26] Roblox PlayerModule TouchJump.lua (Client Tracker mirror) - https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/scripts/PlayerScripts/StarterPlayerScripts/PlayerModule.module/ControlModule/TouchJump.lua - checked 2026-11-03
[27] Roblox PlayerModule DynamicThumbstick.lua (Client Tracker mirror) - https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/scripts/PlayerScripts/StarterPlayerScripts/PlayerModule.module/ControlModule/DynamicThumbstick.lua - checked 2026-11-03
[28] Roblox Creator Docs, Input overview - https://create.roblox.com/docs/input - checked 2026-11-03
[29] Roblox Creator Docs, PreferredInput enum - https://create.roblox.com/docs/reference/engine/enums/PreferredInput - checked 2026-11-03
[30] Roblox Creator Docs, Gamepad input - https://create.roblox.com/docs/input/gamepad - checked 2026-11-03
[31] Roblox Creator Docs, GuiObject - https://create.roblox.com/docs/reference/engine/classes/GuiObject - checked 2026-11-03
[32] Roblox Creator Docs, GuiBase2d.SelectionGroup - https://create.roblox.com/docs/reference/engine/classes/GuiBase2d/SelectionGroup - checked 2026-11-03
[33] Roblox Creator Docs, InputActionLabel - https://create.roblox.com/docs/reference/engine/classes/InputActionLabel - checked 2026-11-03
[34] DevForum, [Client Beta] Input Action System is now available to publish in experiences - https://devforum.roblox.com/t/client-beta-input-action-system-is-now-available-to-publish-in-experiences/3890979 - checked 2026-11-03
[35] Roblox Creator Docs, Invite prompts - https://create.roblox.com/docs/production/promotion/invite-prompts - checked 2026-11-03
[36] Roblox Creator Docs, SocialService - https://create.roblox.com/docs/reference/engine/classes/SocialService - checked 2026-11-03
[37] Roblox Creator Docs, Private servers - https://create.roblox.com/docs/production/monetization/private-servers - checked 2026-11-03
[38] Roblox Creator Docs, Text chat overview - https://create.roblox.com/docs/chat/in-experience-text-chat - checked 2026-11-03
[39] Roblox Creator Docs, Text filtering - https://create.roblox.com/docs/ui/text-filtering - checked 2026-11-03
[40] Roblox Creator Docs, Monetization overview - https://create.roblox.com/docs/production/monetization - checked 2026-11-03
[41] Roblox Creator Docs, Monetization foundations - https://create.roblox.com/docs/production/game-design/monetization-foundations - checked 2026-11-03
[42] Roblox Creator Docs, Developer products - https://create.roblox.com/docs/production/monetization/developer-products - checked 2026-11-03
[43] Roblox Creator Docs, Price optimization - https://create.roblox.com/docs/production/monetization/price-optimization - checked 2026-11-03
[44] Roblox Creator Docs, PolicyService - https://create.roblox.com/docs/reference/engine/classes/PolicyService - checked 2026-11-03
[45] Roblox Creator Docs, Accessibility guidelines - https://create.roblox.com/docs/production/publishing/accessibility - checked 2026-11-03
[46] (unused)
[47] Roblox Creator Docs, Automatic translation - https://create.roblox.com/docs/production/localization/automatic-translations - checked 2026-11-03
[48] W3C Internationalization, Text size in translation - https://www.w3.org/International/articles/article-text-size - checked 2026-11-03
[49] Roblox Creator Docs, Design for performance - https://create.roblox.com/docs/performance-optimization/design - checked 2026-11-03
[50] Roblox Creator Docs, Improve performance - https://create.roblox.com/docs/performance-optimization/improve - checked 2026-11-03
[51] Apple Human Interface Guidelines, Accessibility - https://developer.apple.com/design/human-interface-guidelines/accessibility - checked 2026-11-03
[52] Android Developers, Make apps more accessible - https://developer.android.com/guide/topics/ui/accessibility/apps - checked 2026-11-03
[53] W3C, Understanding SC 1.4.3 Contrast (Minimum) - https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html - checked 2026-11-03
[54] W3C, Understanding SC 2.5.8 Target Size (Minimum) - https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html - checked 2026-11-03
[55] Microsoft, Xbox Accessibility Guideline 101 (text display) - https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/101 - checked 2026-11-03
