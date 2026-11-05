# Install

One install per machine. Works in every Roblox game folder. Touches nothing outside `~/.claude/` except `.rbx-studio/` inside game folders.

## Commands
| Do | PowerShell | Git Bash / macOS |
|---|---|---|
| Install | `.\install.ps1` | `./install.sh` |
| Update | `.\install.ps1 -Update` | `./install.sh --update` |
| Uninstall | `.\install.ps1 -Uninstall` | `./install.sh --uninstall` |
| Sandbox test | `.\install.ps1 -Target C:\tmp\claude-sandbox` | `./install.sh --target /tmp/claude-sandbox` |
| Preview | `-DryRun` | `--dry-run` |
| Force hook shell | `-Shell bash` / `-Shell powershell` | `--shell ...` |

Teammates: clone this repo once, run the install, then `-Update` whenever the lead says so. Everyone on the same commit runs the same studio. Restart Claude Code after installing.

Studio MCP (once per machine): Studio > Assistant > `...` > Manage MCP Servers > enable Studio as MCP server. Then `claude mcp add --scope user roblox-studio -- "%LOCALAPPDATA%\Roblox\mcp.bat"` and check `/mcp`.

macOS/Linux: the installer runs under PowerShell 7 (`brew install powershell`). Hooks run in bash.

## What gets installed
| Path under `~/.claude/` (or `$CLAUDE_CONFIG_DIR`) | What |
|---|---|
| `agents/<18 names>.md` | roblox-director, discovery-strategist, retention-designer, genre-designer, monetization-designer, ux-mobile-designer, luau-architect, server-programmer, client-ui-programmer, code-optimizer, art-generator, data-engineer, analytics-engineer, exploit-tester, qa-playtester, liveops-designer, community-marketer, team-coordinator |
| `skills/rbx-*/` | 30 skills (13 model-visible, 17 user-only) (`/rbx-start` and friends) |
| `rules/rbx-*.md` | 7 path-scoped rules (load only when Claude touches matching Luau or project files) |
| `rbx-studio/` | CONTEXT.md, hooks, docs, templates, tools, `library/roblox/` research, manifest, VERSION |
| `settings.json` | 7 hook entries (SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, PreCompact, Stop, Notification). Your other settings and hooks stay. |

Not installed: a statusLine (it would replace yours), permissions, env.

## How Claude Code loads it (why this design)
Research with sources: `docs/install-research.md`.
- User-level `~/.claude/agents`, `skills`, `rules`, and `settings.json` hooks load in every project. Hooks from user, project, and local settings all run; nothing of yours is replaced.
- Name clashes: a project's own `.claude/agents/<same name>.md` beats ours; our user-level skills beat a project skill of the same name. We prefix skills with `rbx-` so clashes are unlikely.
- Path rules (`paths:` frontmatter) resolve against the session folder, so `rbx-*` rules only load when Claude touches `*.luau`, `src/server/**`, `default.project.json` and similar files.
- Hooks stay silent outside Roblox folders. Detection, cheapest first: `.rbx-studio/`, `*.project.json`, `*.rbxl(x)`, `wally.toml` / `rokit.toml` / `aftman.toml` / `foreman.toml`, `.mcp.json` naming Studio MCP, and (session start only) a `*.luau` within 3 levels. Empty folder with only Studio MCP: run `/rbx-start` once; it creates `.rbx-studio/` and detection works from then on.
- Windows hook shell: Git Bash when installed (`bash ".../rbx-hook.sh" <event>` with `shell: bash`), else PowerShell (`powershell -File ".../rbx-hook.ps1" <event>` with `shell: powershell`). Both dispatchers pass the same 25 fixtures (`bash tools/test-hooks.sh`).

## Safety guarantees
- Manifest (`rbx-studio/manifest.txt`, path + SHA256) records every installed file. Update removes files dropped from the payload. Uninstall removes exactly the manifest and prunes empty folders.
- A file at a payload path that the installer did not put there is backed up to `~/.claude/rbx-studio-backups/<time>/` and restored on uninstall.
- `settings.json` is backed up before every install. Uninstall restores the pre-install copy byte for byte when you have not edited settings since; otherwise it removes only the rbx-studio hook entries.
- Verified: install, reinstall, update, uninstall round trip leaves the sandbox identical (`tools/test-install.ps1`, 13 checks, pwsh 7 and Windows PowerShell 5.1).

## Per-game footprint
`.rbx-studio/`: project.yaml, conventions.md, backlog.md, decisions.md, debt.md, checkpoint.md, locks.md, handoffs/, reports/, evidence/, state/ (gitignored). Commit it so teammates share it.

## Push gate
Hooks block `git push`, `gh pr create`, `gh pr merge`, and `git merge` on main unless the developer approved in this session by typing "approved, push" (or similar) or `/rbx-ship`. The approval comes from the `UserPromptSubmit` hook, which only sees what the human typed. "Do not push" revokes it. Approval lasts 2 hours.
