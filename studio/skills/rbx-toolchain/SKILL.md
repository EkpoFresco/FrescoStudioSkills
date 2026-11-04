---
name: rbx-toolchain
description: "Roblox: set up or switch the dev toolchain for this game: Studio MCP, Script Sync, Rojo + VS Code, Wally, Rokit, Selene, StyLua, luau-lsp, Lune or Jest tests, GitHub Actions CI. Windows-ready commands, MCP first."
argument-hint: "[mcp | rojo | scriptsync | lint | tests | ci | check]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, PowerShell
---

# /rbx-toolchain

## 0. Relevance check
`check` (or no argument): report what is installed and configured, recommend one change if it is genuinely better, stop. If the requested target is already set up and passing, print `SKIPPED: <target> already configured` and stop.

## 1. Context
Read `.rbx-studio/project.yaml` (toolchain, team_size). Read `{{RBX_HOME}}/library/roblox/studio-reference.md` (Toolchain + When to switch) and `{{RBX_HOME}}/library/roblox/code-quality.md` (lint and CI commands). Detect tools: `rokit --version`, `rojo --version`, `wally --version`, `selene --version`, `stylua --version`, `luau-lsp --version`, `lune --version`.

## 2. Targets (do only the one asked)
- `mcp`: Studio: Assistant > ... > Manage MCP Servers > enable "Studio as MCP server". Claude Code: `claude mcp add --scope user roblox-studio -- "%LOCALAPPDATA%\Roblox\mcp.bat"`, restart, `/mcp` shows the tools. Never install the archived studio-rust-mcp-server.
- `scriptsync`: Studio beta/feature Script Sync for scripts-only file mirroring; note its limits (scripts and folders only, no attributes or tags, no sourcemap).
- `rojo`: `rokit init` if no rokit.toml; `rokit add rojo-rbx/rojo`; write `default.project.json` mapping the existing DataModel (never move code without a migration plan); `rojo serve` + the Rojo Studio plugin; for an MCP-only game, export scripts with `rojo syncback` (7.7.0+) first. Warn: do not mix Rojo with Team Create live scripting on the same scripts.
- `lint`: add `selene.toml` (`std = "roblox"`), `stylua.toml` (tabs or spaces matching the code), run both once, report counts. Formatting the whole codebase is a separate commit and only if asked.
- `tests`: Lune for pure modules (`tests/*.spec.luau`, run `lune run tests/run`), MCP skill `rbx-unit-test` or Jest Roblox for engine-dependent modules. TestEZ is archived.
- `ci`: `.github/workflows/ci.yml` with Rokit setup, `stylua --check src`, `selene src`, `luau-lsp analyze --definitions:@roblox=globalTypes.d.luau --sourcemap sourcemap.json src` (download the definitions file in the job).
Every command shown for both PowerShell and Git Bash when they differ.

## 3. Verify
Run the new tool once and show the first lines of output. A failing run is a finding, not a success.

## 4. Record
Update `roblox.toolchain` in project.yaml if it changed. Log the choice in `.rbx-studio/decisions.md` with one line why. Local commit only.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- <target> set up: <files written>, verified with <command> (<result>)
YOU DO
1. <exact step the tool cannot do, e.g. install the Rojo plugin: Studio > Toolbox > Plugins > "Rojo">
RISKS
- <only if real>
NEXT
- <one line>
```
