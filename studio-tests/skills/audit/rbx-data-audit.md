# Skill Spec: /rbx-data-audit
Category: audit · Source: `studio/skills/rbx-data-audit/SKILL.md`

## Summary
Audits DataStore and purchase safety. Inventories every DataStore call site, receipt handler, session lock library and version, `BindToClose`, autosave, and `PlayerRemoving` save with counts. `data-engineer` runs the `implementation-data.md` checklist (session locking, PurchaseId idempotency, save timing, budgets, schema versioning). Migration mode writes migration, dry run, rollback, and order. Verdict SAFE or AT RISK in `.rbx-studio/reports/data-audit-<date>.md`.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: no persistent data or purchases`
- [ ] More than one receipt handler, or DataStore calls outside `paths.data_module`, is a finding by itself
- [ ] Receipts: PurchaseId in the same locked profile; `PurchaseGranted` only after a durable save; `NotProcessedYet` when unloaded; never grant on `PromptProductPurchaseFinished`
- [ ] ProfileStore v1.0.x expected (ProfileService unsupported); `BindToClose` save within 30 s; autosave interval < lock interval
- [ ] Verdict SAFE or AT RISK; `data-schema.md` created from template if missing

## Fixture Defaults
Template project.yaml (`toolchain: rojo`, `paths.data_module: src/server/Data`), Studio MCP connected, git repo with one commit.

## Case 1: Happy path - receipt not idempotent
**Fixture**: `src/server/Data/init.luau` uses ProfileStore 1.0.3. `src/server/Shop.server.luau:41` `ProcessReceipt` adds coins and returns `PurchaseGranted` without storing PurchaseId. `src/server/Leaderboard.server.luau:12` calls `GetOrderedDataStore` directly.
**Expected**: 1. Inventory with counts. 2. Checklist. 3. Rank. 4. Save report and data-schema.md.
**Assertions**:
- [ ] Verdict AT RISK; worst finding is the missing PurchaseId record at `Shop.server.luau:41` (BLOCKER)
- [ ] `Leaderboard.server.luau:12` flagged as DataStore access outside `src/server/Data`
- [ ] DONE gives BLOCKER and MAJOR counts and the report path
- [ ] `.rbx-studio/reports/data-schema.md` created

## Case 2: Relevance skip - no persistence
**Fixture**: Party game; Grep finds no `DataStoreService`, `ProfileStore`, `ProcessReceipt`, or `BindReceiptHandler`.
**Assertions**:
- [ ] Prints `SKIPPED: no persistent data or purchases` and writes nothing

## Case 3: Edge - migration mode
**Fixture**: `/rbx-data-audit migration`; move `Coins` to `Currency.Coins`, `Version` 2 to 3.
**Assertions**:
- [ ] Writes a forward migration that preserves unknown keys and reconciles defaults
- [ ] Dry run targets a copied test key prefix, never live keys
- [ ] Gives rollback and order (publish, migrate-on-join, verify)
- [ ] No destructive step (e.g. `RemoveAsync` on old keys) runs without approval

## Protocol Compliance
- [ ] Never reads or writes live player data in tests
- [ ] Counts stated and dated report saved (A1, A4)
- [ ] Ends with NEXT `/rbx-build fix-data`
