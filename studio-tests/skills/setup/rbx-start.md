# Skill Spec: /rbx-start
Category: setup · Source: `studio/skills/rbx-start/SKILL.md`

## Summary
First-run setup for a Roblox game folder. Detects the project through Studio MCP (`get_studio_state`, `search_game_tree` max_depth 2, `script_search`) or files (`*.project.json`, `rokit.toml`, `wally.toml`, `src/**/*.luau`, git), classifies it `new`, `existing-mcp`, `existing-files`, or `hybrid`, scaffolds `.rbx-studio/` from `{{RBX_HOME}}/templates/`, has `luau-architect` learn `conventions.md` from up to 12 sampled scripts, recommends a toolchain without switching, and makes one local commit. `config key=value` edits project.yaml only.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: already set up` when project.yaml and conventions.md exist and no argument is given, and offers `/rbx-pickup`
- [ ] Scaffold list is exactly: project.yaml, decisions.md, backlog.md, locks.md, debt.md, handoffs/, reports/, evidence/, .gitignore (`state/`)
- [ ] No-MCP notice names `Manage MCP Servers` and `claude mcp add --scope user roblox-studio`
- [ ] Toolchain defaults cite `studio-reference.md` "When to switch": solo or 2 people Studio + MCP, 3+ scripters Rojo + Git + Wally
- [ ] Commit message `chore(studio): set up .rbx-studio`; report uses DONE / YOU DO / RISKS / NEXT

## Fixture Defaults
No `.rbx-studio/` yet, Studio MCP connected, git repo with one commit and one contributor, unless a case says otherwise.

## Case 1: Happy path - existing MCP-only game
**Fixture**: Studio place with 14 scripts, including `ServerScriptService.DataService` (calls `GetDataStore`), `ServerScriptService.Shop` (sets `MarketplaceService.ProcessReceipt`), `StarterPlayer.StarterPlayerScripts.Controls`, `StarterGui.HUD.HUDController`. No `src/`, no `*.project.json`.
**Expected**: 1. MCP detection in parallel with file globs. 2. Class `existing-mcp`. 3. Scaffold with `toolchain: mcp`, `team_size: 1`, `paths.data_module: ServerScriptService.DataService`, `paths.receipt_handler: ServerScriptService.Shop`. 4. luau-architect writes conventions.md with Keep and Phase out lists. 5. Recommends Studio + MCP. 6. Local commit.
**Assertions**:
- [ ] DONE states class `existing-mcp`, toolchain mcp, team_size 1, 14 scripts seen
- [ ] conventions.md cites DataModel path examples and gives each Phase out item a replacement and priority
- [ ] No existing script is moved, renamed, or reformatted
- [ ] NEXT names `/rbx-review`

## Case 2: Relevance skip - already set up
**Fixture**: `.rbx-studio/project.yaml` and `.rbx-studio/conventions.md` exist; run with no argument.
**Assertions**:
- [ ] Prints `SKIPPED: already set up`, offers `/rbx-pickup`, writes nothing, makes no commit

## Case 3: Edge - no Studio MCP, Rojo project, 3 contributors
**Fixture**: No MCP tools. `default.project.json` maps `src/server` to ServerScriptService and `src/client` to StarterPlayerScripts; `git shortlog -sn --all` lists 3 authors.
**Assertions**:
- [ ] Prints the MCP setup notice once, then continues from files
- [ ] Class `existing-files`, `toolchain: rojo`, `team_size: 3`, `paths.server: src/server` read from `default.project.json`
- [ ] Toolchain step says Rojo + Git fits 3+ scripters and switches nothing itself

## Protocol Compliance
- [ ] Writes only `.rbx-studio/` in the game folder (S1)
- [ ] One local commit when `git.local_commits` is true; never pushes
- [ ] Ends with NEXT: `/rbx-concept` (new game) or `/rbx-review` (existing code)
