---
name: rbx-monetize
description: "Roblox: design monetization that fits the game: gamepasses, developer products, subscriptions, rewarded ads, price ladder, placement, economy sinks and faucets, and a policy check against current Roblox rules. Use for shop design, pricing, or 'how should this game make money'."
argument-hint: "[design | review | price <item>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Agent
---

# /rbx-monetize

## 0. Relevance check
`roblox.monetization_style: none`: `SKIPPED: monetization off for this game`. No core loop yet: `SKIPPED: run /rbx-loop first` (retention before monetization). If D1 is known and weak (below the genre benchmark), continue but limit to non-intrusive offers and say why.

## 1. Context
`.rbx-studio/reports/` (concept, gdd, curve), `{{RBX_HOME}}/library/roblox/genres/<genre>.md` (Monetization norms), `{{RBX_HOME}}/library/roblox/policy.md` (TL;DR + Policy check), `{{RBX_HOME}}/library/roblox/implementation-data.md` (Monetization APIs, Roblox Plus pricing, Experiments).
Review mode: Grep or `script_grep` for `PromptProductPurchase`, `PromptGamePassPurchase`, `ProcessReceipt`, `BindReceiptHandler`, `UserOwnsGamePassAsync`, `AdService`.

## 2. Design
`monetization-designer` fills `{{RBX_HOME}}/templates/monetization-sheet.md` into `.rbx-studio/reports/monetization.md`: offers table, price ladder, placement after a clear player action, economy faucets and sinks with a first-hour simulation (Lune if installed), and an Experiments A/B plan for the one price that matters most.

## 3. Policy check (BLOCKER on any fail)
Run every line of the Policy check in `policy.md` against each offer: paid random item odds (all outcomes, total 100%, live with boosts, shown before purchase), PolicyService gates fail closed, no playable gambling, no fake or restarting timers, no urgency copy at minors, rewarded ads not for under-13s, donations through the Transfers API.

## 4. Code check (review mode)
`data-engineer` confirms: one receipt handler, PurchaseId stored in the session-locked profile, ad-reward products covered, prices read live (`GetProductInfoAsync`). Findings ranked BLOCKER / MAJOR / MINOR.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- offers: <n> (.rbx-studio/reports/monetization.md); policy check PASS | FAIL (<items>)
- code: <SAFE | findings>
YOU DO
1. Creator Hub > Creations > <game> > Monetization > Passes: create <name> at <price> R$
RISKS
- <only if real>
NEXT
- /rbx-build <shop story>
```
