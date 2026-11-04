# Data schema: <game>
Store: ProfileStore · Key: `User_{UserId}` · Current Version: 1

| Field | Type | Default | Added in | Notes |
|---|---|---|---|---|
| Version | number | 1 | 1 | migration cursor |
| PurchaseHistory | {string} | {} | 1 | last N PurchaseIds for receipt idempotency |

## Migrations
| From | To | Change | Safe to re-run |
|---|---|---|---|

## Rules
Never delete unknown keys. Reconcile new defaults on load. Test migrations on a copied key prefix, never live data. Autosave interval < session lock interval.
