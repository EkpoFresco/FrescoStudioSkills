---
paths:
  - "src/server/**"
  - "**/*.server.luau"
  - "**/*.server.lua"
  - "**/ServerScriptService/**"
---
# Server code (rbx-studio)

The server is the only source of truth. Exploiters can read all replicated code, fire any remote with any args at any rate, move their own character, and trigger prompts from any distance.

Must:
- Validate every client arg before use: `typeof`, `math.isfinite` for numbers, range, ownership, distance, cooldown, then a per-player per-remote rate limit.
- Currency, inventory, stats, and progress change only on the server, inside the data module's API.
- Grant purchases only in the single receipt handler (`ProcessReceipt` / `BindReceiptHandler`).
- NPC and gameplay simulation runs here; send clients the result, not the authority.

Never:
- `RemoteFunction:InvokeClient`.
- Trust a client-sent price, position, damage, cooldown, or item id without a server check.
- Put secrets, admin lists, or anti-cheat thresholds in ReplicatedStorage.

Detail: {{RBX_HOME}}/library/roblox/implementation.md (Networking, Exploit prevention).
