# Data schema: Snorbo's Brain Rock Mine
Store: custom UpdateAsync session lock (`PlayerData_v1`, not ProfileStore) · Key: `User_{UserId}` (Studio: `Test_User_{UserId}`) · Current Version: 1

| Field | Type | Default | Added in | Notes |
|---|---|---|---|---|
| Version | number | 1 | 1 | migration cursor. Today it is overwritten with VERSION on every load (see audit F3) |
| Rocks | number | 0 | 1 | spendable currency |
| Lifetime | number | 0 | 1 | drives rebirth gain |
| BrainCells | number | 0 | 1 | prestige currency |
| Levels | {[string]: number} | {} | 1 | upgrade id to level |
| PurchaseHistory | {string} | {} | 1 | PurchaseIds for receipt idempotency. Not capped yet (audit F6) |
| BoostEnds | number | 0 | 1 | os.time() when RockRush ends |
| LastSeen | number | os.time() | 1 | offline earnings base |
| _lock | {job: string, t: number} | nil | 1 | session lock, 180 s expiry, written by Data.luau only |

## Migrations
| From | To | Change | Safe to re-run |
|---|---|---|---|
| none yet | | | |

## Rules
Never delete unknown keys. Reconcile new defaults on load. Test migrations on a copied key prefix, never live data. Autosave interval (60 s) < session lock interval (180 s).
