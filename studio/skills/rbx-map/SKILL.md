---
name: rbx-map
description: "Roblox: build or refresh .rbx-studio/map.md, a token-cheap project graph (scripts, requires, remotes fired and handled, DataStore calls, purchases, hot paths), from files or a Studio MCP scan. Optional graphify for docs-heavy repos."
argument-hint: "[--check | studio | graphify]"
user-invocable: true
allowed-tools: Read, Glob, Bash, PowerShell, Write
disable-model-invocation: true
---

# /rbx-map

## 0. Relevance check
`--check`: run `node "{{RBX_HOME}}/tools/rbx-map.js" --check`; current: print `SKIPPED: map current` and stop. The SessionStart hook already rebuilds a stale file-based map, so a manual run is only needed for MCP-only games, after big refactors, or for graphify.

## 1. File-based games (Rojo, Script Sync, hybrid)
`node "{{RBX_HOME}}/tools/rbx-map.js"` in the game folder. Writes `.rbx-studio/map.md` (read this) and `map.json` (the hash for staleness). It costs no model tokens to build. Typical size: 5-10x smaller than the sources it covers.

## 2. MCP-only games (`studio`)
1. Run the contents of `{{RBX_HOME}}/tools/rbx-map.luau` with the Studio MCP tool `execute_luau` (datamodel Edit). It returns JSON of every script's path, class, and source.
2. Save the returned JSON text to `.rbx-studio/state/studio-scan.json` (state/ is gitignored).
3. `node "{{RBX_HOME}}/tools/rbx-map.js" --from-json .rbx-studio/state/studio-scan.json`.
Rerun after Studio-only edits; the hook cannot see Studio changes.

## 3. Graphify (`graphify`, optional)
For repos with many design docs, specs, or wikis next to the code: if `graphify` is on PATH (install: `pip install graphifyy && graphify install`, then `/graphify .`), point agents at its graph for doc questions and keep `map.md` for Roblox code facts (graphify's code parser does not know remotes, DataStores, or DataModel paths). Never install it without the developer's go; it is a Python dependency.

## 4. Use
Every code skill reads `map.md` before opening scripts. Answer "who fires X", "where is data saved", "what runs per frame" from the map, then open only the lines it points to.

## Report
```
DONE
- map: .rbx-studio/map.md (<n> scripts, ~<tok> tok, source files|studio)
YOU DO
1. nothing; it refreshes itself at session start for file-based games
NEXT
- <one line>
```
