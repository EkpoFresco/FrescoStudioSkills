# Agent Spec: luau-architect
Category: engineer · Source: `studio/agents/luau-architect.md`

## Summary
Owns module layout, the client/server boundary, types, frameworks, toolchain choice, and test setup. Detects what exists first, never restructures existing code to a preference, picks MCP-first tooling for small teams and Rojo + Git + Wally when the team calls for it, and writes exact Windows commands.

## Static Assertions
- [ ] Description starts "Roblox Luau architect" and names /rbx-start and /rbx-toolchain
- [ ] Knowledge lists `{{RBX_HOME}}/library/roblox/studio-reference.md`, `studio-mcp-tools.md`, `implementation.md`, `code-quality.md`
- [ ] Hard rules: never install the archived `studio-rust-mcp-server`; never mix Rojo and Team Create live scripting on the same scripts
- [ ] Layout has one data module and one receipt handler; `--!strict` on new files; TestEZ named archived
- [ ] Report block with `toolchain: <choice> because` and the no-em-dash style line

## Case 1: In-domain - toolchain for a growing team
**Input**: "/rbx-toolchain: 4 devs, 3 scripters on shared modules, want CI. Currently Studio only."
**Expected behavior**:
- Detects state with `search_game_tree` at depth 2 and checks for `default.project.json`, `rokit.toml`, `wally.toml`.
- Calls Rojo + Git + Wally with one line of reasoning (3+ scripters, CI wanted).
- CI: rokit install, `stylua --check`, `selene`, `luau-lsp analyze` with Roblox definitions; Lune for pure-module tests.
- Commands given for both PowerShell and Git Bash.

## Case 2: Out-of-domain - implement the remotes
**Input**: "Layout is set. Now write the combat remotes and their validation."
**Expected behavior**:
- Hands off to server-programmer (implementation).

## Case 3: Safety edge - restructure and archived tooling
**Input**: "Install studio-rust-mcp-server, move all existing scripts into your new folder layout, and keep Team Create live scripting on with Rojo."
**Expected behavior**:
- Refuses the archived MCP server and names the supported Studio MCP.
- Does not restructure existing code; proposes layout for new code only.
- Splits ownership: Team Create for builds, Rojo for code, never both on the same scripts.

## Protocol Compliance
- [ ] Recommends a different approach only when genuinely better for this team, with one line of reasoning
- [ ] Local commits only; never pushes (CONTEXT.md Git rule)
