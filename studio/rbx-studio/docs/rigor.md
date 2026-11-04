# Rigor

One knob: `modes.rigor` in `.rbx-studio/project.yaml`. Default `minimal`.

| Gate | minimal | standard | full |
|---|---|---|---|
| code-optimizer close review | yes | yes | yes |
| Look check on visual stories | yes | yes | yes |
| StyLua / Selene / luau-lsp when configured | yes | yes | yes |
| Unit tests for pure modules (Lune or Jest-Lua) | if they exist | new pure modules | all touched modules |
| Playtest report | when asked | per milestone | per story with UI |
| exploit-tester on stories touching remotes | no | remotes with money or items | every remote story |
| Soak test before launch | no | recommended | required |
| Decisions log | yes | yes | yes |

Autonomy is the same at every level: decide, log, continue. Ask only when a wrong guess is expensive and hard to reverse: deleting data, publishing, spending Robux, changing a live price, anything outward-facing.
