---
name: rbx-build
description: "Roblox: implement one story or feature through Studio MCP or files, then close it through the code-optimizer review and, for anything visual, the look check. `--prototype` trades standards for speed. Use for 'build X', 'implement S-03', 'add a shop', 'make this work'."
argument-hint: "<story id | feature description> [--prototype]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, PowerShell, Agent
---

# /rbx-build

## 0. Relevance check
No story id and no description: show the top 3 `todo` rows in `.rbx-studio/backlog.md` and stop (`SKIPPED: pick a story`). Story already `done`: `SKIPPED: S-NN is done`.

## 1. Ready check
Load the story (backlog row or `.rbx-studio/stories/S-NN.md`). If it has no acceptance lines, write 2-4 now (observable or testable) and log it. Read `.rbx-studio/conventions.md`, `.rbx-studio/project.yaml` (toolchain, rigor), `.rbx-studio/locks.md`. Claim the modules you will touch in `locks.md` when `team_size > 1`; a module claimed by someone else: stop and report.
Set status `doing`.

## 2. Plan (5-10 lines)
Files or DataModel paths to create or change; remote contract changes (`{{RBX_HOME}}/templates/remote-contract.md`); data changes (owned by `data-engineer`); UI pieces. Pick agents by type: server and remotes `server-programmer`, UI and client `client-ui-programmer`, data and purchases `data-engineer`, art `art-generator`. Independent parts run in parallel.

## 3. Implement
Brief each agent with: story id and acceptance, exact paths, the plan lines it owns, conventions to follow, "MCP first (`multi_edit`, `execute_luau` chunked) else files", and "return the Report block". Hybrid or Rojo projects: files are the source of truth; after editing `src/`, sync Studio before step 4 (`rojo serve` with the Rojo plugin connected, or push each changed module with `multi_edit`, then `script_read` to confirm). A run against stale Studio copies is NOT VERIFIED. `--prototype`: skip types and tests, keep server validation and data safety (never skip those), mark the story `prototype` in the backlog.

## 4. Run
Studio MCP: `start_stop_play` true, `get_console_output`, exercise the feature (inputs or Server datamodel `execute_luau`), stop play. Files only: run Lune tests if present. Errors loop back to step 3 (max 3 rounds, then report).

## 5. Close gate (never skipped)
1. `code-optimizer` reviews the change (list every file or script touched). Verdict must not be `CHANGES REQUIRED`. It fixes what it can; re-run step 4 if it changed code.
2. Visual or UI story: look check per `{{RBX_HOME}}/docs/look-check.md` (phone + desktop), evidence under `.rbx-studio/evidence/S-NN/`. `NOT VERIFIED` blocks the close.
3. Rigor extras (`{{RBX_HOME}}/docs/rigor.md`): tests at standard+, `exploit-tester` on money or item remotes at standard+, on every remote at full.
4. Fill the story Evidence section. Status `done`. Release locks. Local commit `type(scope): summary (S-NN)` if `git.local_commits`. Never push.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- S-NN <title>: done (review <VERDICT>, Run result <OBSERVED|N/A>)
- <path>: <what changed>
YOU DO
1. <exact step, e.g. Studio > Home > Play to try it>
RISKS
- <only if real>
NEXT
- /rbx-build <next story>
```
