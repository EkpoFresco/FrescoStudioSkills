---
paths:
  - "**/*.project.json"
  - "**/*.rbxl"
  - "**/*.rbxlx"
  - "**/wally.toml"
  - "**/rokit.toml"
---
# Place and project files (rbx-studio)

- Never hand-edit `.rbxl` (binary). `.rbxlx` only through Rojo or Studio.
- `default.project.json`: keep the tree stable. Renaming a `$path` node renames instances in Studio and breaks `WaitForChild` callers. Add, do not move, unless the task is a migration.
- `wally.toml` / `rokit.toml`: pin exact versions. Run `wally install` / `rokit install` after changes and commit the lock files.
- Publishing a place is outward-facing: only through `/rbx-update` or `/rbx-launch` after approval.

Detail: {{RBX_HOME}}/library/roblox/studio-reference.md (Toolchain).
