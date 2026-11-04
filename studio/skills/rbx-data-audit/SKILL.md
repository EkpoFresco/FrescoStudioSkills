---
name: rbx-data-audit
description: "Roblox: audit DataStore and purchase safety: session locking, one receipt handler with PurchaseId idempotency, BindToClose saves, autosave timing, request budgets, schema versioning and migrations. Verdict SAFE or AT RISK with ranked fixes. Use before launch, before any data migration, or on a data-loss report."
argument-hint: "[all | receipts | migration]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent
---

# /rbx-data-audit

## 0. Relevance check
No `DataStoreService`, `ProfileStore`, `ProcessReceipt`, or `BindReceiptHandler` anywhere: `SKIPPED: no persistent data or purchases`.

## 1. Inventory
Every DataStore call site, every receipt handler, the session lock library and version, `BindToClose`, autosave loop, `PlayerRemoving` save. State counts. More than one receipt handler, or DataStore calls outside `paths.data_module`, is a finding by itself.

## 2. Checklist (data-engineer)
Delegate to `data-engineer` with the inventory and `{{RBX_HOME}}/library/roblox/implementation-data.md` ("Never do this" list + ProcessReceipt reference). Check:
- Session locked profile per player (ProfileStore v1.0.x; ProfileService unsupported).
- Receipts: PurchaseId stored in the same locked profile as the reward; `PurchaseGranted` only after the save is durable; `NotProcessedYet` when the profile is not loaded; ad-reward products covered; never granting on `PromptProductPurchaseFinished`.
- Saves: autosave interval < lock interval; save on leave and in `BindToClose` within 30 s.
- Budgets: modern request types, retries with backoff, idempotent writes.
- Schema: `Version` field, forward migrations, unknown keys preserved, defaults reconciled.
- Tests touch a test key prefix, never live data.

## 3. Migration mode
For a planned schema change: write the migration, a dry run on a copied prefix, the rollback, and the order (publish, migrate-on-join, verify). Never run destructive steps without approval.

## 4. Save
`.rbx-studio/reports/data-audit-<date>.md`. Update `.rbx-studio/reports/data-schema.md` from `{{RBX_HOME}}/templates/data-schema.md` if missing.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- verdict: SAFE | AT RISK (BLOCKER <n>, MAJOR <n>) (.rbx-studio/reports/data-audit-<date>.md)
- worst: <finding> at <path:line>
YOU DO
1. <exact step>
RISKS
- <only if real>
NEXT
- /rbx-build fix-data
```
