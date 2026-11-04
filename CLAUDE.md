# rbx-studio (maintainer repo)

This repo builds a Claude Code studio for Roblox development. It installs globally into `~/.claude/` and works in any Roblox game folder, writing only `.rbx-studio/` there.

## Layout
- `studio/`: the payload. `agents/` (18), `skills/rbx-*/` (29), `rules/` (7 path rules), `rbx-studio/` (CONTEXT, hooks, docs, templates, tools).
- `docs/roblox/`: research library, installed as `rbx-studio/library/roblox/`. Every claim has a source and date; gaps are tagged UNVERIFIED (`OPEN_QUESTIONS.md`).
- `install.ps1` / `install.sh`: install, `-Update`, `-Uninstall`, `-Target <sandbox>`.
- `tools/`: `studio-lint.js`, `gen-catalog.js`, `token-budget.js`, `test-hooks.sh`, `test-install.ps1`, `dump-mcp-manifest.js`. Payload tools in `studio/rbx-studio/tools/`: `rbx-map.js` (+ `.luau`), `lib.js`, `mcp-call.js`, `capture-studio.ps1`.
- `studio-tests/`: catalog, rubric, specs. `.claude/skills/`: maintainer `/skill-test`, `/skill-improve`.
- `docs/audit/`: repo audit and the design spec. `DECISIONS.md`, `RUN_STATE.md` at the root.

## Rules for working here
- Voice for everything we ship: lead with the result, short sentences, plain words, numbers and paths, no em dashes, no filler. Reports: DONE / YOU DO / RISKS / NEXT.
- Payload paths use `{{RBX_HOME}}`; the installer substitutes the absolute path. Never write `~`.
- After editing `studio/`: `node tools/studio-lint.js all` must stay at 0 NON-COMPLIANT; `node tools/gen-catalog.js --check` must report 0 problems; hook changes need `bash tools/test-hooks.sh` green in both shells.
- Roblox facts go in `docs/roblox/` with a source URL and the date checked. Unverifiable means `UNVERIFIED` plus how to verify.
- Git: local commits are fine. Never push, open PRs, or merge to main until the developer approves. The `upstream` remote push URL is disabled on purpose.
- Long runs: keep `RUN_STATE.md` current and commit after each chunk.
