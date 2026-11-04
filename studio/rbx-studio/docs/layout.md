# Layouts the studio understands

## Rojo file layout (`default.project.json`)
| Folder | Maps to (typical) |
|---|---|
| `src/server/` | ServerScriptService (`*.server.luau` = Script) |
| `src/client/` | StarterPlayer.StarterPlayerScripts (`*.client.luau` = LocalScript) |
| `src/shared/` | ReplicatedStorage.Shared (ModuleScripts) |
| `Packages/` | ReplicatedStorage.Packages (Wally output, never edit) |

Read `default.project.json` for the real mapping. It wins over this table.

## Studio DataModel layout (MCP-only or Script Sync)
- Server: `ServerScriptService` (entry Scripts), `ServerStorage` (server-only modules and assets).
- Client: `StarterPlayer.StarterPlayerScripts`, `StarterPlayer.StarterCharacterScripts`, `StarterGui`, `ReplicatedFirst` (loading).
- Shared: `ReplicatedStorage` (modules, remotes folder, assets clients need).
- Inspect with `search_game_tree` (path + max_depth) before assuming. Scripts: `script_search`, `script_grep`, `script_read`. Edit with `multi_edit` (Edit datamodel only).

## Mapping
Path rules match both layouts: `src/server/**` and `**/ServerScriptService/**` load the same server rule. For MCP-only projects set `paths.*` in project.yaml to DataModel paths (for example `ServerScriptService.Data`).
