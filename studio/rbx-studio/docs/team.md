# Team workflow

- Branch: `<initials>/<type>-<slug>`. Types: feat, fix, perf, refactor, data, ui, art, chore. Example: `ns/feat-shop-ui`.
- Commit: `type(scope): summary (#issue)`. Local by default. Push only after approval.
- Issues are stories. `/rbx-issues` maps open issues to `.rbx-studio/backlog.md`. Creating, editing, labeling, or commenting on issues is outward-facing: draft first, act after approval.
- Handoffs: `.rbx-studio/handoffs/YYYY-MM-DD-<initials>-<topic>.md`, written for humans in the developer's style. `/rbx-handoff` writes them, `/rbx-pickup` reads them.
- Module locks (`.rbx-studio/locks.md`): before editing a module, claim it with a row `| path | owner | branch | since |`. Release it when the story closes. Claims older than 24 h are stale and may be taken (note it in the row). Team Create + MCP: locks are the only guard, always check. Rojo + Git: advisory, merges handle the rest.
- Two Claude sessions on one machine: each claims its modules and never edits a module the other claimed.
- PRs: `/rbx-ship` after approval. Body: what, why, evidence (look check paths, before/after numbers), `Closes #N`.
- Nothing goes upstream: never file or comment on issues in Roblox, plugin, or library repos. Draft it; the developer submits it.
