---
paths:
  - "**/*.luau"
  - "src/**/*.lua"
---
# Luau (rbx-studio)

Must:
- New files start with `--!strict`. Export types for anything another module consumes.
- Cache services and instance refs at module top. No `FindFirstChild` or `GetService` inside per-frame code.
- Every `:Connect` has an owner that disconnects it (Trove/Janitor or a stored connection cleared on PlayerRemoving / Destroying).
- Player-keyed tables are cleared on `Players.PlayerRemoving`.
- Dispose with `:Destroy()`. `Parent = nil` is only for temporary removal.
- Errors: wrap yielding Roblox calls (DataStore, MarketplaceService, HttpService, TeleportService) in `pcall` with a retry or a logged fallback.

Never:
- Yield (`task.wait`, `WaitForChild`, `*Async`) inside Heartbeat, RenderStepped, PreSimulation, or tween callbacks.
- Allocate tables or closures per frame in hot loops. Reuse with `table.clear`.
- String-build in loops with `..`. Use `table.concat` (Lune measured 232 ms vs 0.4 ms for 20k parts).
- Use `wait()`, `spawn()`, `delay()`. Use `task.*`.
- Claim a speedup without a before/after number.

Detail: {{RBX_HOME}}/library/roblox/code-quality.md, implementation.md. Project conventions: `.rbx-studio/conventions.md` (wins over this rule where they differ).
