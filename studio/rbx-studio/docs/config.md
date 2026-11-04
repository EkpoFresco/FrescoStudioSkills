# Config: `.rbx-studio/project.yaml`

Flat YAML, read directly (no resolver). Template: `{{RBX_HOME}}/templates/project.yaml`. A missing key uses the default below.

| Key | Default | Used by |
|---|---|---|
| modes.rigor | minimal | every gate (rigor.md) |
| roblox.toolchain | mcp | build, playtest, toolchain (mcp, rojo, hybrid, studio-only) |
| roblox.genre | "" | genre, loop, concept (file stem in library/roblox/genres/) |
| roblox.target_devices | [phone, desktop, tablet, console] | look check, UX |
| roblox.monetization_style | light | monetize (none, light, standard, heavy) |
| roblox.team_size | 1 | start, toolchain (Rojo + Git suggested at 3+ scripters), locks |
| roblox.analytics | false | telemetry runs only when true or asked |
| roblox.universe_id / place_ids | "" / [] | update, launch, Open Cloud |
| paths.server / client / shared | src/server, src/client, src/shared | rules, review (DataModel paths when MCP-only) |
| paths.data_module | "" | DataStore hook check, data-audit |
| paths.receipt_handler | "" | data-audit, monetize |
| paths.handoffs | .rbx-studio/handoffs | handoff, pickup |
| remotes.guard_words | [] | extra guard words for the commit hook |
| git.main_branch | main | push gate, ship |
| git.local_commits | true | checkpoint, build |
| git.push_requires_approval | true | always enforced; the hook ignores false |
| team.github_repo | "" | issues, ship |

Change a value with `/rbx-start config key=value` or edit the file.
