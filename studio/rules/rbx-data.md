---
paths:
  - "**/*Data*.luau"
  - "**/*Profile*.luau"
  - "**/*Store*.luau"
  - "**/*Save*.luau"
  - "**/*Receipt*.luau"
---
# Data and purchases (rbx-studio)

Must:
- DataStore calls only inside the data module (`paths.data_module` in `.rbx-studio/project.yaml`). Everyone else uses its API.
- One key per player, session locked (ProfileStore). Schema has a `Version` field and forward migrations. Never delete unknown keys.
- One receipt handler. Store `PurchaseId` in the same session-locked profile as the reward; return `PurchaseGranted` only after that save is durable. Cover ad-reward products (`ProductPurchaseChannel.AdReward`).
- Read prices from `GetProductInfoAsync` / `GetDeveloperProductsAsync` (Roblox Plus discounts and managed pricing change them).
- Autosave on an interval shorter than the session lock, plus on leave and `BindToClose`.
- Use modern `Enum.DataStoreRequestType` values (`StandardRead`, `StandardWrite`) for budget checks.

Never:
- Grant on `PromptProductPurchaseFinished`.
- `SetAsync` on player data that another server might hold.
- Test against live player DataStores from Studio without a separate test key prefix.

Detail: {{RBX_HOME}}/library/roblox/implementation-data.md (ProcessReceipt snippet, limits table).
