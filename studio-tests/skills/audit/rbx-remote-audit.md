# Skill Spec: /rbx-remote-audit
Category: audit · Source: `studio/skills/rbx-remote-audit/SKILL.md`

## Summary
Audits every RemoteEvent, RemoteFunction, UnreliableRemoteEvent, ProximityPrompt, and ClickDetector handler for server trust, validation, rate limits, and payload size. Inventories with path:line and a count, reviews each handler against `implementation.md` (Networking + Exploit prevention), has `exploit-tester` attack money, item, and progress remotes in Studio play mode, ranks BLOCKER / MAJOR / MINOR with exact fixes, and saves `.rbx-studio/reports/remote-audit-<date>.md`.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: no client-to-server surface` when the Grep or `search_game_tree` finds none
- [ ] Check order: type, `math.isfinite`, range, ownership, distance, cooldown, rate limit
- [ ] Attack set: wrong types, NaN, inf, negative, huge, other player ids, 1000-call spam, races; results PROVEN or PLAUSIBLE
- [ ] No MCP: attack results NOT ASSESSED
- [ ] Fixes not applied here unless one line; offers `/rbx-build fix-remotes`

## Fixture Defaults
Template project.yaml (`rigor: minimal`, `toolchain: rojo`), Studio MCP connected, git repo with one commit.

## Case 1: Happy path - shop remote trusts client price
**Fixture**: `ReplicatedStorage.Remotes.BuyItem` handled at `src/server/Shop.server.luau:22` as `function(player, itemId, price) charge(player, price) end`; `Remotes.Sell` at `src/server/Inventory.server.luau:40` checks `typeof(n) == "number"` only; `Remotes.Emote` (UnreliableRemoteEvent); `Workspace.Bank.DepositPrompt` ProximityPrompt.
**Expected**: 1. Inventory 4 surfaces. 2. Static review. 3. Attack BuyItem with price 0 and Sell with NaN. 4. Rank. 5. Save.
**Assertions**:
- [ ] DONE states "remotes: 4 audited" with BLOCKER, MAJOR, MINOR counts
- [ ] BuyItem price 0 is BLOCKER PROVEN, confirmed by reading Server datamodel state
- [ ] Sell lacks `math.isfinite` and range checks; fix names the exact check and file:line
- [ ] Report saved at `.rbx-studio/reports/remote-audit-<date>.md`

## Case 2: Relevance skip - no client-to-server surface
**Fixture**: Touch-only obby: `src/server/Checkpoints.server.luau` uses `Touched`; no remotes, prompts, or ClickDetectors.
**Assertions**:
- [ ] Prints `SKIPPED: no client-to-server surface` and writes nothing

## Case 3: Edge - no Studio MCP
**Fixture**: Same code as Case 1; MCP tools missing.
**Assertions**:
- [ ] Says MCP is missing once and runs static review only
- [ ] Every attack result is NOT ASSESSED; nothing marked PROVEN
- [ ] Static findings and the report are still produced

## Protocol Compliance
- [ ] Attacks run only in Studio play mode, never on live servers
- [ ] Coverage count stated; dated report saved (A1, A4)
- [ ] Ends with NEXT `/rbx-build fix-remotes`
