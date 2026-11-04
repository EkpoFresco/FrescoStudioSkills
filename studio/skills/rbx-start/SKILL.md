---
name: rbx-start
description: "Roblox: set up the studio in a game folder (detect via MCP or files, create .rbx-studio/, learn conventions, build the project map, pick a toolchain). `config k=v` edits settings."
argument-hint: "[new | existing | config key=value]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, PowerShell, Agent
disable-model-invocation: true
---

# /rbx-start

## 0. Relevance check
If `$ARGUMENTS` starts with `config`: set each `key=value` in `.rbx-studio/project.yaml` (create from template if missing), print the changed lines, report, stop.
If `.rbx-studio/project.yaml` and `conventions.md` already exist and no argument was given: say so in one line, offer `/rbx-pickup`, and stop (`SKIPPED: already set up`).

## 1. Detect
Run in parallel:
- MCP: is a Studio MCP tool available (`get_studio_state`, `search_game_tree`)? If yes: `get_studio_state`, then `search_game_tree` with `max_depth: 2` for ServerScriptService, ReplicatedStorage, StarterPlayer, StarterGui. Count scripts with `script_search`.
- Files: Glob `*.project.json`, `*.rbxl*`, `rokit.toml`, `aftman.toml`, `wally.toml`, `selene.toml`, `stylua.toml`, `src/**/*.luau`, `src/**/*.lua`. `git rev-parse --is-inside-work-tree`, `git remote -v`, contributor count for this folder only (`git shortlog -sn HEAD -- . | wc -l`; the game may sit inside a bigger repo).
- No MCP tools: say once: "Studio MCP not connected. In Studio: Assistant > ... > Manage MCP Servers > enable Studio as MCP server. Then run `claude mcp add --scope user roblox-studio -- \"%LOCALAPPDATA%\\Roblox\\mcp.bat\"` and restart Claude Code." Continue with files.
Classify: `new` (no scripts), `existing-mcp` (scripts in Studio, no files), `existing-files` (Rojo or Script Sync files), `hybrid`.

## 2. Scaffold `.rbx-studio/`
Create only these, from `{{RBX_HOME}}/templates/`: `project.yaml`, `decisions.md` (header line), `backlog.md`, `locks.md` (header row), `debt.md` (header row), `handoffs/`, `reports/`, `evidence/`, `.gitignore` (`state/`).
Fill project.yaml: `toolchain` (mcp | rojo | hybrid | studio-only from step 1), `team_size` (git contributors, else 1), `paths.*` (from `default.project.json`, or DataModel paths for MCP-only), `paths.data_module` and `paths.receipt_handler` (Grep/script_grep for `GetDataStore` and `ProcessReceipt|BindReceiptHandler`), `genre` if obvious from names, else leave "" and note it.
Never move, rename, or reformat existing files.

## 3. Learn conventions (existing projects)
More than 12 scripts: delegate to the `luau-architect` agent with this brief; 12 or fewer: do it inline (cheaper, same output): sample up to 12 scripts (entry scripts, the data module, the largest server module, the largest client module, 2 shared modules, any remote wrapper, any UI module); fill `{{RBX_HOME}}/templates/conventions.md` into `.rbx-studio/conventions.md` with file:line examples; list patterns to Keep and patterns to Phase out (with the replacement and a priority). The goal is better code over time, not copying old code. New projects: write a seed conventions.md from the default stack in `{{RBX_HOME}}/library/roblox/implementation.md`.

## 3b. Project map
Build `.rbx-studio/map.md`: files: `node "{{RBX_HOME}}/tools/rbx-map.js"`; MCP-only: the `studio` path in `~/.claude/skills/rbx-map/SKILL.md`. The conventions pass in step 3 reads the map first to pick its 12 sample files.

## 4. Toolchain recommendation
One line of reasoning, then steps. Defaults from `{{RBX_HOME}}/library/roblox/studio-reference.md` "When to switch": solo or 2 people: Studio + MCP. 3+ scripters on shared modules or CI wanted: Rojo + Git + Wally (`/rbx-toolchain rojo`). Do not switch anything yourself.

## 5. Commit
If git and `git.local_commits`: `git add .rbx-studio && git commit -m "chore(studio): set up .rbx-studio"`. Never push.

## Report
Studio report shape only. Lead with the result. Short lines, file paths, no em dashes, no filler.
```
DONE
- project: <class>, toolchain <x>, team_size <n>, <N> scripts seen
- wrote .rbx-studio/{project.yaml, conventions.md, ...}
YOU DO
1. <smallest exact step, e.g. set genre: /rbx-start config roblox.genre=idle-clicker>
RISKS
- <only if real>
NEXT
- /rbx-concept (new game) or /rbx-review (existing code)
```
