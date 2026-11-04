# Skill Spec: /rbx-toolchain
Category: setup · Source: `studio/skills/rbx-toolchain/SKILL.md`

## Summary
Sets up exactly one toolchain target (`mcp`, `scriptsync`, `rojo`, `lint`, `tests`, `ci`) or reports what is installed (`check`, default). Reads project.yaml, `studio-reference.md` (Toolchain + When to switch) and `code-quality.md`, detects tool versions, writes only that target's files, verifies by running the new tool once, updates `roblox.toolchain` and `decisions.md`, and commits locally.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: <target> already configured` when the target is set up and passing; `check` or no argument reports and stops
- [ ] "Do only the one asked" for targets
- [ ] `mcp` target never installs the archived studio-rust-mcp-server; `tests` notes TestEZ is archived
- [ ] `ci` writes `.github/workflows/ci.yml` running `stylua --check src`, `selene src`, and `luau-lsp analyze` with `--sourcemap sourcemap.json`
- [ ] Commands shown for both PowerShell and Git Bash when they differ

## Fixture Defaults
Template project.yaml (`rigor: minimal`, `toolchain: rojo`, `team_size: 2`), `rokit.toml` present, git repo with one commit, unless a case says otherwise.

## Case 1: Happy path - lint
**Fixture**: `rokit.toml` lists selene and stylua; no `selene.toml` or `stylua.toml`; `src/server/Combat.server.luau` and 22 other files indent with tabs.
**Expected**: 1. Detect versions. 2. Write `selene.toml` (`std = "roblox"`) and `stylua.toml` with tabs. 3. Run `selene src` and `stylua --check src` once. 4. Log the choice in decisions.md. 5. Local commit.
**Assertions**:
- [ ] Only the two config files plus `.rbx-studio/decisions.md` change; no file under `src/` is reformatted
- [ ] DONE shows the verify command and its counts (e.g. "selene: 14 warnings, stylua: 9 files differ")
- [ ] Whole-codebase formatting offered as a separate commit, only if asked

## Case 2: Relevance skip - rojo already configured
**Fixture**: `default.project.json`, `rokit.toml` with rojo 7.7.0, `rojo build -o test.rbxl` passes; run `/rbx-toolchain rojo`.
**Assertions**:
- [ ] Prints `SKIPPED: rojo already configured` and writes nothing

## Case 3: Edge - rojo on an MCP-only game
**Fixture**: `toolchain: mcp`, no `src/`, no `rokit.toml`, 20 scripts in ServerScriptService and StarterPlayer; run `/rbx-toolchain rojo`.
**Assertions**:
- [ ] Runs `rokit init`, `rokit add rojo-rbx/rojo`, then `rojo syncback` (7.7.0+) before any `rojo serve`
- [ ] `default.project.json` maps the existing DataModel; no script moves without a migration plan
- [ ] Warns against mixing Rojo with Team Create live scripting on the same scripts
- [ ] YOU DO gives the plugin path (Studio > Toolbox > Plugins > "Rojo"); a failing verify run is reported as a finding

## Protocol Compliance
- [ ] Writes only `.rbx-studio/` plus the target's own config files
- [ ] Local commit only; never pushes
- [ ] Ends with a NEXT line
