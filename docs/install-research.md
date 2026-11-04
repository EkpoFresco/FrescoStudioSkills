# Claude Code Loading Model (research)

Last checked: 2026-11-03. Sources at bottom. Raw research behind `docs/install.md`.
Anything not confirmed in the pages read is marked UNVERIFIED.

## TL;DR for agents

- User level (`~/.claude/`) loads in every project: agents, skills, commands, `settings.json` (hooks, permissions, env, statusLine, outputStyle), `CLAUDE.md`, and rules [5][6].
- `~/.claude/rules/*.md` is supported. `paths:` frontmatter works from user level; patterns resolve against the session's working directory [5].
- Name collisions: agents, project beats user [3]. Skills, personal (user) beats project [4]. Plugin items are namespaced and never collide [3][4].
- Hooks from all scopes add together; identical handlers run once. Permission arrays merge. A deny anywhere wins [1][2][14].
- Windows: hook commands run in Git Bash if installed, else PowerShell. A `shell` field (`bash` / `powershell`) pins it. Exec form (`command` + `args`) needs a real `.exe` [1].
- `CLAUDE_CONFIG_DIR` relocates `~/.claude` and `~/.claude.json`: usable for sandbox-testing an installer [2][6].
- Plugins can ship agents, skills, commands, hooks, MCP servers, output styles, `bin/`. They cannot ship CLAUDE.md, rules, statusLine, permissions, env [7].

## 1. Load locations and precedence

| Item | User (`~/.claude/`) | Project (`.claude/`) | Plugin | Notes |
|---|---|---|---|---|
| Subagents | `agents/*.md`, recursive [3] | `.claude/agents/*.md` [3] | `agents/` as `plugin:name` [3][7] | Priority: managed > `--agents` > project > user > plugin [3] |
| Skills | `skills/<name>/SKILL.md` [4] | `.claude/skills/<name>/SKILL.md`, plus parent dirs up to repo root and nested subdirs [4] | `skills/<name>/SKILL.md` as `/<plugin>:<name>` [4][7] | Priority: enterprise > personal > project [4] |
| Slash commands | `commands/*.md` [6] | `.claude/commands/*.md` [4] | `commands/` [7] | Legacy. A skill wins over a same-name command [4] |
| Hooks | `~/.claude/settings.json` `hooks` [1] | `.claude/settings.json`, `.claude/settings.local.json` [1] | `hooks/hooks.json` while enabled [1][7] | All levels add together [1] |
| settings.json | `~/.claude/settings.json` [2] | `.claude/settings.json`, `.claude/settings.local.json` [2] | only `agent`, `subagentStatusLine` [7] | Precedence: managed > `--settings` > local > project > user [2] |
| CLAUDE.md | `~/.claude/CLAUDE.md`, every session [5] | `./CLAUDE.md`, `./.claude/CLAUDE.md`, `CLAUDE.local.md` [5] | not loaded from plugin root [7] | Context, not enforcement [5] |
| Rules | `~/.claude/rules/*.md`, loaded before project rules [5] | `.claude/rules/*.md`, recursive [5] | not a plugin component [7] | `paths:` works in both [5] |

- Rules without `paths:` load at launch. Rules with `paths:` load when Claude touches a matching file [5].
- User-scope memory files load without the trust dialog [5].

## 2. Merge semantics

- Hooks: user + project + local + plugin all run. Identical handlers in several files run once [1].
- Permission arrays (`allow`, `ask`, `deny`, `additionalDirectories`) merge across scopes [2].
- Evaluation: deny, then ask, then allow. First match decides. A deny from any level cannot be overridden [14].
- A `PreToolUse` hook returning `allow` does not bypass a deny rule [14].
- Scalars (`outputStyle`, `statusLine`, `model`): the highest-precedence file that sets the key wins [2]. An installer writing `statusLine` overwrites the user's own: back it up.
- `env` per-key merge vs whole-block replace: UNVERIFIED.
- Same-name agents: project `.claude/agents/` beats `~/.claude/agents/` [3]. `/doctor` reports duplicates [3].
- Same-name skills: personal beats project [4].

## 3. Hook mechanics

Events [1]: `SessionStart`, `SessionEnd`, `Setup`, `UserPromptSubmit`, `UserPromptExpansion`, `Stop`, `StopFailure`, `PreToolUse`, `PermissionRequest`, `PermissionDenied`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `TeammateIdle`, `InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `DirectoryAdded`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove`, `PreCompact`, `PostCompact`, `PreModelSwitch`, `PostModelSwitch`, `Notification`, `MessageDisplay`, `Elicitation`, `ElicitationResult`.

| Input field | Where |
|---|---|
| `session_id`, `transcript_path`, `cwd`, `permission_mode`, `hook_event_name` | all events |
| `tool_name`, `tool_input`, `tool_use_id` | tool events |
| `source` (`startup`, `resume`, `clear`, `compact`, `fork`), `model` | SessionStart |
| `prompt` | UserPromptSubmit |
| `message`, `title`, `notification_type` | Notification |

Exit codes [1]:
- `0`: success. One JSON object on stdout is parsed. Plain stdout is added as context only on UserPromptSubmit, UserPromptExpansion, SessionStart, PostModelSwitch.
- `2`: blocking. Stderr goes to Claude. Exit 2 beats a JSON allow. On PostToolUse, stderr is fed back (the tool already ran).
- Anything else: non-blocking error notice. Exit 1 does not block.

JSON output [1]: `continue`, `stopReason`, `suppressOutput`, `systemMessage`; top-level `decision: "block"` + `reason` on UserPromptSubmit, PostToolUse, Stop, SubagentStop, PreCompact; `hookSpecificOutput` with `hookEventName` + `additionalContext` (SessionStart and others) or `permissionDecision` (`allow`/`deny`/`ask`/`defer`) on PreToolUse. Strings capped at 10,000 chars.

Matchers [1]: empty or `*` = all; plain names and `|` lists = exact match; anything else = unanchored JS regex (e.g. `mcp__.*__multi_edit`). `if` takes one permission rule, e.g. `Bash(git *)`.

Timeouts [1]: default 600 s per command handler; set `timeout` per handler. A PreToolUse timeout does not block unless `onFailure: "block"`.

Variables [1][11]: `$CLAUDE_PROJECT_DIR`, `$CLAUDE_PLUGIN_ROOT`, `$CLAUDE_PLUGIN_DATA`. Hook processes get `CLAUDECODE=1`.

Windows [1][11]:
- `shell: "bash" | "powershell"` on a handler. Default bash (Git Bash) when installed.
- Trap found on this machine: in PowerShell, `bash` resolves to `C:\WINDOWS\system32\bash.exe` (the WSL launcher), not Git Bash. Never rely on a bare `bash` from a PowerShell-run command.
- Exec form example: `"command": "powershell.exe", "args": ["-NoProfile","-ExecutionPolicy","Bypass","-File","C:/Users/<you>/.claude/rbx-studio/hooks/rbx-hook.ps1"]`.
- Whether the hook process cwd equals the session cwd: UNVERIFIED. Read the `cwd` field.

## 4. Plugins and marketplaces

- Components: `skills/`, `commands/`, `agents/`, `hooks/hooks.json`, `.mcp.json`, `.lsp.json`, `output-styles/`, `monitors/`, `bin/` (on PATH while enabled), `settings.json` (two keys) [7].
- Names: skills `/<plugin>:<skill>`; bare `/<skill>` may also resolve when unambiguous (UNVERIFIED on this build) [4]. Agents `plugin:name` [3].
- Plugin agents ignore `hooks`, `mcpServers`, `permissionMode`, `initialPrompt` [3][7].
- CLI: `claude plugin marketplace add <repo|path>`, `claude plugin install <p>@<m> --scope user`, `claude plugin update`, `claude plugin uninstall`, `claude plugin list --json`, `claude plugin validate .` [8][10].
- Versions: manifest `version`, then marketplace entry, then git SHA [9]. Cache at `~/.claude/plugins/cache/` [9].

| Concern | Plugin | Copy into `~/.claude/` |
|---|---|---|
| Install / update / uninstall | built in | installer must track files and merge JSON |
| Short names (`/rbx-start`) | namespaced; bare form unverified | works directly |
| CLAUDE.md, rules, statusLine, permissions, env | no | yes |
| Collisions with user's own items | none (namespaced) | possible; installer must guard |
| Needs a hosted repo | git repo or local folder | nothing |

## 5. CLAUDE_CONFIG_DIR

- Relocates settings, session history, plugins, and `.claude.json` [2][6].
- Credential relocation: UNVERIFIED.
- Sandbox: PowerShell `$env:CLAUDE_CONFIG_DIR = "$HOME/claude-clean"; claude --setting-sources user`. `--bare` skips hooks and skills, so do not use it for hook tests [12][15][16].

## 6. statusLine, outputStyle, env

- statusLine is a single scalar object; a plugin cannot set it [7][13]. Windows runs it through Git Bash if installed [13].
- outputStyle: string, any scope [18].
- env: applies to every session and its subprocesses [18].

## 7. Frontmatter fields

- Skills [4][6]: `name`, `description` (with `when_to_use`, truncated at 1,536 chars), `when_to_use`, `argument-hint`, `arguments`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `disallowed-tools`, `model`, `effort`, `context: fork`, `agent`, `background`, `hooks`, `paths`, `shell`, `metadata`. Unknown fields ignored.
- Agents [3]: required `name`, `description`. Optional `tools`, `disallowedTools`, `model` (`sonnet`, `opus`, `haiku`, `fable`, full ID, `inherit`), `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `omitClaudeMd`, `effort`, `isolation`, `color`, `initialPrompt`.
- Rules [6]: `paths` only.

## 8. Headless verification

- `claude -p "<prompt>" --output-format stream-json --verbose`: first event `system/init` lists `tools`, `mcp_servers`, `slash_commands`, `agents`, `skills`, `plugins` [12][17]. Raw CLI key names: confirm by running once.
- SessionStart hook output streams as `hook_started` / `hook_response` events [12].
- `claude --debug` writes `~/.claude/debug/<session-id>.txt` with each hook event, matcher, exit code [15].
- Interactive: `/hooks`, `/skills`, `/context`, `/doctor` [15][3].

## Sources

[1] Hooks reference - https://code.claude.com/docs/en/hooks.md - checked 2026-11-03
[2] Settings files and precedence - https://code.claude.com/docs/en/settings.md - checked 2026-11-03
[3] Subagents - https://code.claude.com/docs/en/sub-agents.md - checked 2026-11-03
[4] Skills - https://code.claude.com/docs/en/skills.md - checked 2026-11-03
[5] How Claude remembers your project (CLAUDE.md and rules) - https://code.claude.com/docs/en/memory.md - checked 2026-11-03
[6] Explore the .claude directory - https://code.claude.com/docs/en/claude-directory.md - checked 2026-11-03
[7] Add components to a plugin - https://code.claude.com/docs/en/plugins/components.md - checked 2026-11-03
[8] Install and manage plugins - https://code.claude.com/docs/en/plugins/install.md - checked 2026-11-03
[9] Plugin loading reference - https://code.claude.com/docs/en/plugins/loading.md - checked 2026-11-03
[10] Plugin commands reference - https://code.claude.com/docs/en/plugins/cli-reference.md - checked 2026-11-03
[11] Environment variables - https://code.claude.com/docs/en/env-vars.md - checked 2026-11-03
[12] Run Claude Code programmatically - https://code.claude.com/docs/en/headless.md - checked 2026-11-03
[13] Customize your status line - https://code.claude.com/docs/en/statusline.md - checked 2026-11-03
[14] Configure permissions - https://code.claude.com/docs/en/permissions.md - checked 2026-11-03
[15] Debug your configuration - https://code.claude.com/docs/en/debug-your-config.md - checked 2026-11-03
[16] CLI reference - https://code.claude.com/docs/en/cli-reference.md - checked 2026-11-03
[17] Agent SDK TypeScript reference - https://code.claude.com/docs/en/agent-sdk/typescript.md - checked 2026-11-03
[18] Settings reference - https://code.claude.com/docs/en/settings-reference.md - checked 2026-11-03

## Recommendation (researcher's)

Hybrid: user-scope plugin for agents/skills/hooks, plus a small bootstrap for rules and settings plugins cannot carry. Caveat: plugin skills are namespaced (`/rbx-studio:rbx-start`) and the bare form is unverified. The final choice is logged in `DECISIONS.md` and `docs/install.md`.
