# Skill Spec: /rbx-monetize
Category: design · Source: `studio/skills/rbx-monetize/SKILL.md`

## Summary
Designs monetization that fits the game. `monetization-designer` fills `monetization-sheet.md` into `.rbx-studio/reports/monetization.md`: offers, price ladder, placement after a player action, faucets and sinks with a first-hour simulation, one Experiments A/B plan. Every offer runs the `policy.md` Policy check (any fail is a BLOCKER). Review mode greps purchase APIs and has `data-engineer` check receipt safety.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: monetization off for this game` (style none) and `SKIPPED: run /rbx-loop first` (no core loop)
- [ ] Names `genres/<genre>.md`, `policy.md`, `implementation-data.md`
- [ ] Policy lines: odds for all outcomes totaling 100% shown before purchase, PolicyService fails closed, no gambling, no fake or restarting timers, no urgency copy at minors, rewarded ads not for under-13s, donations via Transfers API
- [ ] Review grep: `PromptProductPurchase`, `PromptGamePassPurchase`, `ProcessReceipt`, `BindReceiptHandler`, `UserOwnsGamePassAsync`, `AdService`
- [ ] YOU DO uses Creator Hub > Creations > <game> > Monetization > Passes

## Fixture Defaults
Template project.yaml (`genre: pet-collection-trading`, `monetization_style: standard`), gdd.md and curve.luau in `.rbx-studio/reports/`, Studio MCP connected.

## Case 1: Happy path - design with a paid egg
**Fixture**: Loop: hatch eggs, equip pets, earn coins. D1 unknown. Planned offers: 2x Luck pass, Robux egg, starter pack.
**Expected**: 1. Read context. 2. Fill the sheet. 3. Policy check each offer. 4. No code check (design mode).
**Assertions**:
- [ ] Robux egg lists every outcome with odds totaling 100%, live with boosts, shown before purchase
- [ ] Each offer is placed after a clear player action, not on join
- [ ] One Experiments A/B plan for the single most important price
- [ ] DONE shows "policy check PASS" or FAIL with named items

## Case 2: Relevance skip - monetization off
**Fixture**: `roblox.monetization_style: none`.
**Assertions**:
- [ ] Prints `SKIPPED: monetization off for this game` and writes nothing

## Case 3: Edge - review with two receipt handlers and a fake timer
**Fixture**: `/rbx-monetize review`. `ServerScriptService.Shop` and `src/server/VIP.server.luau:9` both set `ProcessReceipt`; `StarterGui.ShopGui.Deal` shows "LIMITED 00:59" that restarts every minute.
**Assertions**:
- [ ] Second receipt handler is a BLOCKER with both paths
- [ ] Restarting timer fails the policy check as a BLOCKER
- [ ] DONE `code:` line lists findings, not SAFE; no price changed live

## Protocol Compliance
- [ ] Writes only `.rbx-studio/reports/`
- [ ] Policy check runs on every offer (D4)
- [ ] Ends with NEXT `/rbx-build <shop story>`
