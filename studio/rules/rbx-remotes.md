---
paths:
  - "**/*Remote*.luau"
  - "**/*Net*.luau"
  - "**/*Network*.luau"
  - "**/*remote*.luau"
  - "**/*net*.luau"
---
# Remotes (rbx-studio)

Must:
- One contract per remote: name, direction, payload types, rate limit. Template: {{RBX_HOME}}/templates/remote-contract.md.
- Server handler order: type check, `math.isfinite`, range, ownership, distance, cooldown, rate limit (token bucket per player per remote), then act.
- Batch high-frequency traffic. Client to server is capped near 500 req/s per client, shared per remote type.
- `UnreliableRemoteEvent` only for cosmetic, high-frequency, droppable data. Payloads over 1000 bytes are dropped.
- If a handler is validated by a wrapper the commit hook cannot see, put `-- rbx:guarded` on the line above the Connect.

Never:
- `InvokeClient`. Yielding server code on client replies.
- Send whole tables every frame. Send deltas.

The commit hook blocks inline handlers that take client args with no visible guard. Detail: {{RBX_HOME}}/library/roblox/implementation.md (Networking).
