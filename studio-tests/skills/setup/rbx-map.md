# Skill Spec: /rbx-map
Category: setup · Source: `studio/skills/rbx-map/SKILL.md`

## Summary
Builds `.rbx-studio/map.md` and `map.json`, a static project graph (scripts, requires, exports, services, remotes fired and handled, DataStore calls, purchases, analytics, per-frame connections, infinite loops) so code skills open only the scripts they need. File-based games use `tools/rbx-map.js`; MCP-only games scan Studio with `tools/rbx-map.luau` through `execute_luau`, then `--from-json`. Graphify is optional for docs-heavy repos and never installed without approval.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"; `disable-model-invocation: true`
- [ ] Relevance check prints `SKIPPED: map current` for `--check` on a current map
- [ ] Names `{{RBX_HOME}}/tools/rbx-map.js` and `{{RBX_HOME}}/tools/rbx-map.luau`
- [ ] States graphify is optional and needs the developer's go to install
- [ ] Report uses DONE / YOU DO / NEXT

## Fixture Defaults
Template project.yaml, Rojo layout under `src/`, git repo, node on PATH, unless a case says otherwise.

## Case 1: Happy path - file-based game
**Fixture**: `src/server/Game.server.luau` handles `Mine` via `remotes.Mine.OnServerEvent`; `src/client/Hud.client.luau` fires it through `local remoteMine = Remotes.get("Mine")`.
**Expected**: runs rbx-map.js; map.md lists `Mine: src/client/Hud.client.luau:<n> -> src/server/Game.server.luau:<n>`.
**Assertions**:
- [ ] Writes only `.rbx-studio/map.md` and `.rbx-studio/map.json`
- [ ] Report gives script count and approximate tokens

## Case 2: Relevance skip - map current
**Fixture**: `map.json` hash matches the sources.
**Assertions**:
- [ ] `--check` prints `SKIPPED: map current` and writes nothing

## Case 3: Edge - MCP-only game
**Fixture**: no `.luau` files on disk; scripts live only in the open Studio place.
**Assertions**:
- [ ] Runs rbx-map.luau via `execute_luau`, saves JSON under `.rbx-studio/state/`, builds with `--from-json`

## Protocol Compliance
- [ ] Writes only inside `.rbx-studio/`
- [ ] Never installs graphify or any package without approval
- [ ] Ends with a NEXT line
