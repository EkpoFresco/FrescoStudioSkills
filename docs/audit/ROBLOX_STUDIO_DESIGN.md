# Roblox Studio Design

Written 2026-11-03. Build spec for Phase 4. Inputs: `REPO_AUDIT.md`, `docs/install-research.md`, `docs/roblox/*`, the build prompt.

## 0. Principles

1. Save the developer time. Every skill starts with a one-line relevance check and skips itself if it does not apply.
2. Roblox-native only. No engine-generic advice.
3. MCP-first. Studio MCP is the default path to build, inspect, run, and screenshot. Rojo + Git is recommended when the team situation calls for it.
4. QPTR over CTR. Design for qualified players who stay, not raw clicks.
5. Autonomous with a log. Make the call, log it in `.rbx-studio/decisions.md`, keep going. Ask one question with options only when a wrong guess is expensive and hard to reverse.
6. Local commits yes, push never without approval.
7. Code gets better over time: `conventions.md` + `code-optimizer` close gate + evidence-backed optimization.
8. Low footprint: in a game folder the studio writes only `.rbx-studio/` (plus game code when a task asks for it).

## 1. Layout

### This repo
```
studio/                    payload the installer copies
  agents/*.md              18 agents          -> ~/.claude/agents/
  skills/rbx-*/SKILL.md    28 skills          -> ~/.claude/skills/
  rules/rbx-*.md           7 path rules       -> ~/.claude/rules/
  rbx-studio/              support files      -> ~/.claude/rbx-studio/
    CONTEXT.md             injected at SessionStart in Roblox folders
    VERSION
    hooks/rbx-hook.sh      bash dispatcher (primary)
    hooks/rbx-hook.ps1     PowerShell twin
    hooks/settings.hooks.json  hook block merged into settings.json
    docs/                  standards, look-check, rigor, config, survival, coordination, layout, team
    templates/             14 templates
    tools/                 capture-studio.ps1 (window PNG), mcp-call.js (stdio MCP client for scripts)
  (library)                docs/roblox/ copied to rbx-studio/library/roblox/ at install
install.ps1, install.sh    install | update | uninstall | -Target sandbox
docs/roblox/               research library (source of truth)
docs/install.md            install model + commands
.claude/                   maintainer tooling for THIS repo (skill-test, skill-improve, settings)
studio-tests/              catalog, rubric, specs for the 28 skills + 18 agents
tools/                     studio-lint.js, test-hooks.sh/.ps1, dump-mcp-manifest.js
dogfood/                   placeholder game used in Phase 5
```

Path token: payload files write `{{RBX_HOME}}` for the support dir. The installer replaces it with the absolute forward-slash path (e.g. `C:/Users/nsidi/.claude/rbx-studio`). Agents never guess `~`.

### Per game: `.rbx-studio/`
```
.rbx-studio/
  project.yaml       config (section 9)
  conventions.md     learned conventions: keep / phase out
  backlog.md         stories (local) or links to GitHub issues
  decisions.md       one line per decision
  debt.md            tech debt register
  checkpoint.md      latest /rbx-checkpoint
  locks.md           module claims for team sessions
  handoffs/          YYYY-MM-DD-<who>-<topic>.md
  reports/           dated playtest, review, optimize, perf, audit reports
  evidence/<story>/  look-check screenshots
  state/             gitignored: approval token, last-turn stamp, auto checkpoint
  .gitignore         state/
```
Committed to git so teammates share it (except `state/`).

## 2. Roster (18 agents)

| Agent | Owns | Main skills | Reads |
|---|---|---|---|
| roblox-director | vision, pillars, scope, cuts, tech risk calls | rbx-concept, rbx-plan | concept, discovery-algorithm |
| discovery-strategist | algorithm, QPTR, thumbnails/icons, launch plan, market data | rbx-thumbnail, rbx-launch, rbx-teardown, rbx-metrics | discovery-*, market-data |
| retention-designer | core loop, session plan, D1/D7/D30 hooks, progression curves, flow vs frustration | rbx-loop, rbx-first-60 | genres/*, ux-standards |
| genre-designer | genre patterns, maps/stages, story genres | rbx-genre, rbx-concept | genres/* |
| monetization-designer | gamepasses, dev products, subs, economy, price ladder, policy-safe | rbx-monetize | implementation-data, policy |
| ux-mobile-designer | first 60 s, touch, safe areas, console parity, accessibility, localization | rbx-first-60, look check | ux-standards |
| luau-architect | module layout, types, toolchain choice, CI, tests setup | rbx-start, rbx-toolchain | studio-reference, implementation, code-quality |
| server-programmer | authority, remotes, gameplay, NPCs, anti-exploit fixes | rbx-build | implementation, implementation-data |
| client-ui-programmer | UI, tweens, responsive layout, input, camera, client feel | rbx-build | ux-standards, implementation |
| code-optimizer | TOP PRIORITY: closes every story; review, perf, memory, network; measured before/after | rbx-review, rbx-optimize, rbx-perf, rbx-build close gate | code-quality, implementation |
| art-generator | Studio MCP generation, style sheet, look check, audio sourcing, artist briefs | rbx-art | art-pipeline, ux-standards |
| data-engineer | DataStores, session locks, migrations, receipts | rbx-data-audit, rbx-build (data) | implementation-data |
| analytics-engineer | AnalyticsService events, funnels, A/B buckets, flow/churn telemetry when useful | rbx-telemetry, rbx-metrics | implementation-data, discovery-playbook |
| exploit-tester | attacks every remote and purchase path | rbx-remote-audit | implementation |
| qa-playtester | runs the game via MCP, screenshots, device emulation, smoke/soak | rbx-playtest | ux-standards, look-check |
| liveops-designer | events, limited items, update cadence, publishing, soft shutdown | rbx-update | discovery-playbook, policy |
| community-marketer | update logs, socials, ads copy, player-facing text | rbx-update, rbx-launch | discovery-playbook, policy |
| team-coordinator | issues, branches, handoffs, locks, PR prep | rbx-issues, rbx-handoff, rbx-pickup, rbx-ship | team.md |

Agent contract (every agent file):
- Frontmatter: `name`, `description` starting "Roblox", `tools`, `model: inherit`, `maxTurns`.
- Sections: Role (2 lines) · Knowledge (exact library files to read, by path) · How you work (numbered) · Hard rules · Hand off to (who owns adjacent work) · Report (Section 8 format).
- Every agent carries the style block (no em dashes, lead with result, DONE/YOU DO/RISKS/NEXT).
- Subagents have no question tool: open questions go at the end of the report.

## 3. Skills (28 + 2 maintainer)

| Skill | Owner agents | What it does |
|---|---|---|
| /rbx-start | luau-architect, team-coordinator | Detect project (MCP tree or files), scaffold `.rbx-studio/`, learn `conventions.md`, recommend toolchain (MCP-first). `config k=v` mode edits project.yaml. |
| /rbx-toolchain | luau-architect | Set up or switch: MCP, Rojo + VS Code, Wally, Selene, StyLua, luau-lsp, Lune tests, CI. Windows-ready commands. |
| /rbx-concept | roblox-director, genre-designer, discovery-strategist | One-page brief: hook, pillars, discovery hypothesis, QPTR story, kill criteria. |
| /rbx-genre | genre-designer | Pull genre patterns for this game; what to copy mechanically, what to avoid. |
| /rbx-first-60 | ux-mobile-designer, retention-designer | Design or review the first minute: storyboard by second, time to first fun, look check. |
| /rbx-loop | retention-designer | Core loop, session plan, D1/D7/D30 hooks, progression curve sim. |
| /rbx-plan | roblox-director, team-coordinator | Concept + loop to a milestone backlog of small stories with acceptance criteria. Cut list. |
| /rbx-build | server/client programmers, data-engineer, code-optimizer | Implement one story via MCP or files. Close gate: code-optimizer review + look check for visual stories. `--prototype` relaxes standards. |
| /rbx-monetize | monetization-designer | Offer design, placement, price ladder, policy check. |
| /rbx-thumbnail | discovery-strategist, art-generator | Icon/thumbnail brief + A/B plan with the metric to judge. |
| /rbx-remote-audit | exploit-tester, server-programmer | Scan every remote: trust, validation, rate limits, payload size. Severity ranked. |
| /rbx-data-audit | data-engineer | DataStore safety, session lock, receipt idempotency, migrations. |
| /rbx-perf | code-optimizer | Mobile performance review: MicroProfiler/LibMP, memory, instances, network. |
| /rbx-review | code-optimizer | Project-specific code review against `conventions.md`. Updates conventions. |
| /rbx-optimize | code-optimizer | Top-impact perf/memory/network fixes, measured before/after, debt register. |
| /rbx-art | art-generator | Style sheet, generate/improve assets via MCP, asset budget audit, look check, artist brief on second fail. |
| /rbx-checkpoint | (main session) | Save session state to `.rbx-studio/checkpoint.md`, local commit. |
| /rbx-resume | (main session) | Rebuild state from checkpoint + last-turn stamp + git, continue the next step. |
| /rbx-telemetry | analytics-engineer | Events, funnels, economy events; flow/churn signals only if relevant. |
| /rbx-playtest | qa-playtester | Launch via MCP, play, screenshot phone + desktop, report. `--smoke`, `--soak`. |
| /rbx-teardown | discovery-strategist, genre-designer, monetization-designer | Analyze a competitor/reference: loop, UX, monetization, discovery. |
| /rbx-metrics | analytics-engineer, discovery-strategist | Paste dashboard or third-party numbers; diagnosis + next actions. |
| /rbx-issues | team-coordinator | Read open GitHub issues via `gh`, triage, map to stories, link fixes. Drafts only until approval for writes. |
| /rbx-handoff | team-coordinator | Handoff note for a teammate: what changed, what is open, where to start. |
| /rbx-pickup | team-coordinator | Read latest handoffs, issues, commits, checkpoint; tell me where things stand. |
| /rbx-ship | team-coordinator | Only after approval: push branch, open PR, link issues. |
| /rbx-launch | discovery-strategist, community-marketer | Launch checklist: thumbnails, description, maturity, ads, update log, go/no-go. |
| /rbx-update | liveops-designer, data-engineer, community-marketer | Live update: publish, soft shutdown, data migration, update log. `--hotfix`. |
| /skill-test, /skill-improve | maintainer (this repo only) | Lint and test the studio itself. |

Skill contract (every `rbx-*` SKILL.md):
```
---
name: rbx-xxx
description: "Roblox: <what, when>. <trigger phrases>"
argument-hint: "<modes>"
user-invocable: true
allowed-tools: <minimal set>
---
# /rbx-xxx
## 0. Relevance check     -> one line; if not applicable print `SKIPPED: <reason>` and stop
## 1. Load context        -> .rbx-studio/project.yaml, conventions, named library files only
## 2..N. Phases           -> numbered, each with a concrete output
## Report                 -> DONE / YOU DO / RISKS / NEXT (Section 8 of the prompt)
```
Lint rules (tools/studio-lint.js): required frontmatter; description starts "Roblox"; relevance check section; at least 2 numbered phases; a Report section with DONE, YOU DO, NEXT; review/audit skills carry verdict or severity words; library references resolve to real files; no em dashes; no Godot/Unity/Unreal; write-capable skills state their write scope; skills that push/PR reference the approval gate; SKILL.md under 300 lines.

## 4. Code quality (heaviest emphasis)

- `conventions.md` is built by `/rbx-start` from a sample of real code (up to 12 files across server/client/shared, largest + most-required first). Sections: Layout, Naming, Module pattern, Networking, Data, UI, Error handling + logging, Perf budgets, Keep, Phase out, Open questions. Each entry cites a file:line example.
- Goal is not to copy old code: "Phase out" lists patterns new code must not repeat and that `/rbx-optimize` migrates over time.
- `code-optimizer` closes every story in `/rbx-build`: correctness, typing, security, performance, memory, network, readability. Fixes BLOCKER and MAJOR it can, re-runs Selene/StyLua/luau-lsp when present, flags the rest. A story with an open BLOCKER does not close.
- Evidence rule: any optimization claim carries numbers (MicroProfiler ms, Script Profiler %, memory MB, KB/s, or a Lune/os.clock benchmark over N iterations) in a before/after table. No numbers, no claim.
- `/rbx-optimize` passes pick debt by score = impact x risk / effort, one change per commit, re-test or playtest after each.
- `/rbx-review` appends new learned patterns to `conventions.md` with a date.

## 5. Look check

Anything visual is not done until:
1. Launched via Studio MCP (`start_stop_play` → wait → `screen_capture`).
2. Captured at phone (landscape phone via Device Simulator, MCP skill `rbx-device-simulator-lua`) and desktop (1920x1080).
3. Judged against the rubric in `docs/roblox/ux-standards.md`.
4. Retained: `{{RBX_HOME}}/tools/capture-studio.ps1 -Out .rbx-studio/evidence/<story>/NN-<what>.png` saves the Studio window, since MCP captures return to the model only.
5. Reported as `Run result: OBSERVED | NOT VERIFIED | N/A` (kept from the original run-and-observe rule).
Escalate to a human artist only after two failed look checks, or when the developer says it looks bad ("this looks rly bad, we gotta work on it"). Then write `artist-brief.md` in the developer's style.

## 6. Team workflow

- Branches: `<initials>/<type>-<slug>` (e.g. `ns/feat-shop-ui`). Types: feat, fix, perf, refactor, data, ui, art, chore.
- Commits: `type(scope): summary (#issue)`, local by default.
- Issues = stories. `/rbx-issues` maps open issues to `backlog.md` rows; creating or commenting on issues is outward-facing and needs approval like a push.
- Handoffs: `.rbx-studio/handoffs/`, written for humans in the developer's style.
- Module locks: before editing a module, a session claims it in `.rbx-studio/locks.md` (`path | owner | branch | since`). Claims older than 24 h are stale. With Rojo + Git, locks are advisory and merges handle the rest; with Team Create + MCP, locks are the only guard, so skills check them.
- Push, PR, merge to main: only after approval (hook-enforced, section 8).

## 7. Rules (`~/.claude/rules/`)

| Rule | paths |
|---|---|
| rbx-luau.md | `**/*.luau`, `src/**/*.lua` |
| rbx-server-code.md | `src/server/**`, `**/*.server.luau`, `**/*.server.lua`, `**/ServerScriptService/**` |
| rbx-client-code.md | `src/client/**`, `**/*.client.luau`, `**/*.client.lua`, `**/StarterPlayer/**`, `**/StarterGui/**` |
| rbx-shared-code.md | `src/shared/**`, `**/ReplicatedStorage/**` |
| rbx-remotes.md | `**/*{Remote,Net,Network}*.luau`, `**/*{remote,net,network}*.luau` |
| rbx-data.md | `**/*{Data,Profile,Store,Save,Receipt}*.luau` |
| rbx-place-files.md | `**/*.project.json`, `**/*.rbxl`, `**/*.rbxlx`, `**/wally.toml` |

Each rule: 8-20 lines, must-do / never-do, links to the library file with detail.

## 8. Hooks (one dispatcher per shell)

| Event | Matcher | Does | Blocks? |
|---|---|---|---|
| SessionStart | all | detect Roblox folder; print `CONTEXT.md` + project summary + latest checkpoint/handoff + update notice | no |
| UserPromptSubmit | all | if the user's prompt approves a push (`approved, push`, `ok push`, `push it`, `ship it`, `/rbx-ship`), write `state/approval-<session>` (2 h TTL) | no |
| PreToolUse | Bash\|PowerShell | `git push`, `gh pr create/merge`, `git merge` on main: block without token. `git commit`: block unguarded remote handlers in staged Luau | yes (exit 2) |
| PostToolUse | Write\|Edit\|MultiEdit, `mcp__.*__multi_edit` | Luau files: StyLua check (if `stylua.toml`), Selene (if `selene.toml`), DataStore calls outside data module, unguarded remote handler | feedback only |
| PreCompact | all | write `state/auto-checkpoint.md` (branch, status, last commits) | no |
| Stop | all (async) | write `state/last-turn.txt` (time, changed files) | no |
| Notification | permission_prompt\|idle_prompt | Windows toast | no |

Detection (cheap, in order): `.rbx-studio/` · `*.project.json` · `*.rbxl`/`*.rbxlx` at top level · `wally.toml` / `rokit.toml` / `aftman.toml` / `foreman.toml` · `.mcp.json` naming Roblox/StudioMCP · (SessionStart only) any `*.luau` within depth 3. Not detected → exit 0, no output. Nothing is written outside `.rbx-studio/`.

Guard heuristic for remote handlers: an `OnServerEvent:Connect` / `OnServerInvoke =` handler with arguments beyond `player` is guarded if, within the next 12 lines, it calls a guard (`typeof(`, `t.`, `Guard`, `validate`, `assert(`, `check`, configurable in `project.yaml remotes.guard_patterns`) or carries `-- rbx:guarded`.

## 9. Config: `.rbx-studio/project.yaml`

```yaml
schema_version: 1
studio_version: 2.0.0
modes:
  rigor: minimal          # minimal | standard | full
roblox:
  toolchain: mcp          # mcp | rojo | hybrid | studio-only
  genre: ""               # file stem in library/roblox/genres/
  target_devices: [phone, desktop, tablet, console]
  monetization_style: light   # none | light | standard | heavy
  team_size: 1
  analytics: false
  universe_id: ""
  place_ids: []
paths:
  server: src/server
  client: src/client
  shared: src/shared
  data_module: ""         # e.g. src/server/Data
  receipt_handler: ""
  handoffs: .rbx-studio/handoffs
remotes:
  guard_patterns: ["typeof%(", "t%.", "Guard", "validate", "assert%(", "check"]
git:
  main_branch: main
  local_commits: true
  push_requires_approval: true
team:
  github_repo: ""
```

Rigor: `minimal` (default) = close gate + look check only; `standard` = + unit tests for pure modules, playtest report per milestone; `full` = + exploit-tester on every remote story, soak test before launch.

## 10. Templates

concept-brief, gdd-short, discovery-plan, monetization-sheet, remote-contract, data-schema, update-log, playtest-report, handoff-note, checkpoint, story, conventions (seed), artist-brief, style-sheet, launch-checklist, backlog, project.yaml.

## 11. Survival

- `/rbx-checkpoint`: phase, done, in progress, next 3, open decisions, files touched; local commit when `git.local_commits`.
- `/rbx-resume`: read checkpoint, `state/last-turn.txt`, `state/auto-checkpoint.md`, `git log` since checkpoint, `git status`; reconcile; print the plan; continue step 1 of "next".
- Efficiency mode (in `docs/survival.md`): at ~1/4 budget left, stop broad exploration, read sections not files, delegate bulky reads, finish the current item, checkpoint.

## 12. Install

- `install.ps1` / `install.sh`: `install` (default), `-Update` (pull the clone, reinstall, remove files dropped from payload), `-Uninstall`, `-Target <dir>` (sandbox; also honors `CLAUDE_CONFIG_DIR`), `-DryRun`.
- Manifest at `rbx-studio/manifest.txt` (path + sha256). Never overwrite a file not in the manifest: back it up to `rbx-studio/backups/<time>/` and report it.
- settings.json: back up, remove old `rbx-hook` entries, add the hook block. Uninstall removes exactly those entries and files. Hook shell: Git Bash if found, else PowerShell exec form.
- Statusline not installed (would overwrite the user's).
