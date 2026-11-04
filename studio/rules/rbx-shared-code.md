---
paths:
  - "src/shared/**"
  - "**/ReplicatedStorage/**"
---
# Shared modules (rbx-studio)

Everything here replicates to every client. Assume exploiters read it.

Must:
- `--!strict`, exported types, pure functions where possible (config, formulas, types, remote contracts).
- Side-effect free on require: no connections, no instance creation, no yields at module top.
- Remote contracts (names + payload types) live here so server and client share one definition.

Never:
- Require server-only services (DataStoreService, MessagingService, ServerStorage) from shared code.
- Store secrets, admin ids, or anti-cheat thresholds here.

Detail: {{RBX_HOME}}/library/roblox/implementation.md (Architecture).
