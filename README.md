# rbx-studio

A Claude Code studio for Roblox games. 18 agents, 29 skills, 7 path rules, 7 hooks, and a cited Roblox research library. Installs once, works in any Roblox game folder, writes only `.rbx-studio/` there.

Forked from [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) v1.2.0 and rebuilt for Roblox only. Every other engine set was removed.

## Install
```powershell
git clone https://github.com/EkpoFresco/FrescoStudioSkills.git
cd FrescoStudioSkills
.\install.ps1          # Git Bash / macOS: ./install.sh
```
Restart Claude Code, open a Roblox game folder, run `/rbx-start`. Details, update, uninstall: [docs/install.md](docs/install.md).

Studio MCP (the default build path): Studio > Assistant > `...` > Manage MCP Servers > enable. Then `claude mcp add --scope user roblox-studio -- "%LOCALAPPDATA%\Roblox\mcp.bat"`.

## Use it on an existing game
Open Claude Code inside the game folder (not a parent folder), on a branch:
```powershell
git clone <GAME_REPO_URL> MyGame; cd MyGame
git switch -c <initials>/chore-studio-setup
claude
```
Then paste:
```
This is my existing Roblox game. Use rbx-studio (https://github.com/EkpoFresco/FrescoStudioSkills).
1. Run /rbx-start existing. It must only add .rbx-studio/.
2. Run /rbx-review all, /rbx-remote-audit all, /rbx-data-audit. Findings only, ranked; fix nothing yet.
3. One DONE / YOU DO / RISKS / NEXT report with the top 5 fixes as proposed branch names.
Local commits only; never push, open a PR, or merge to main until I say "approved, push".
```
Then one fix per branch: `/rbx-build <fix>`, `/rbx-ship`, "approved, push".

New game instead: `/rbx-start new`, then `/rbx-concept brainstorm <theme>`.

## What it does
- MCP first: builds, inspects, plays, and screenshots the game through Roblox Studio's built-in MCP server. Recommends Rojo + Git when the team needs it.
- QPTR over CTR: designs for players who stay. Grounded in Roblox's current ranking signals (PTR, first-play bounce, D1 / D2-7 / D8-28 retention from Recommended For You).
- Mobile-first UX with a look check: nothing visual is done until it was launched and captured at phone and desktop sizes.
- Production Luau: server authority, validated remotes, session-locked data, one receipt handler.
- Code gets better over time: `code-optimizer` closes every story, `conventions.md` learns Keep and Phase out patterns, optimizations need before/after numbers.
- Apply only what fits: every skill starts with a relevance check and skips itself when it does not apply.
- Team-ready: issues as stories, module locks, handoff notes, PR prep. Pushes and PRs need your approval in your own words (hook-enforced).
- Survives long sessions: `/rbx-checkpoint` and `/rbx-resume`, plus auto state from hooks.
- Talks like you: result first, short lines, DONE / YOU DO / RISKS / NEXT.

## Token budget
Built to stay cheap in long sessions:
- Every session (Roblox or not) pays ~857 tokens of listings: 12 model-visible skills, 17 user-only skills hidden from the model, short agent descriptions.
- `.rbx-studio/map.md` (auto-refreshed at session start, zero model tokens) maps scripts, remotes, data, purchases, and hot paths, so skills open only the files they need.
- `tools/lib.js` reads the research library by section (300 to 1,500 tokens) instead of whole files (8k to 13k).
- Measured on the dogfood data audit: tool reads -79%, cost -29%, same findings. Track it with `node tools/token-budget.js`.

## Skills
| Stage | Skills |
|---|---|
| Setup | `/rbx-start`, `/rbx-toolchain`, `/rbx-map`, `/rbx-checkpoint`, `/rbx-resume` |
| Design | `/rbx-concept`, `/rbx-genre`, `/rbx-loop`, `/rbx-first-60`, `/rbx-plan`, `/rbx-monetize`, `/rbx-thumbnail` |
| Build | `/rbx-build`, `/rbx-art`, `/rbx-telemetry` |
| Quality | `/rbx-review`, `/rbx-optimize`, `/rbx-perf`, `/rbx-remote-audit`, `/rbx-data-audit`, `/rbx-playtest` |
| Growth | `/rbx-teardown`, `/rbx-metrics`, `/rbx-launch`, `/rbx-update` |
| Team | `/rbx-issues`, `/rbx-handoff`, `/rbx-pickup`, `/rbx-try`, `/rbx-ship` |

Typical flow: `/rbx-start` -> `/rbx-concept brainstorm <theme>` -> `/rbx-concept <pick>` -> `/rbx-loop` -> `/rbx-first-60` -> `/rbx-plan` -> `/rbx-build S-01` (repeat) -> `/rbx-playtest` -> `/rbx-launch`. Live game: `/rbx-metrics` weekly, `/rbx-update` per release, `/rbx-optimize` monthly.

## Agents
| Agent | Owns |
|---|---|
| roblox-director | vision, scope, cuts, go/pivot/kill |
| discovery-strategist | algorithm, thumbnails, launch, market data |
| retention-designer | core loop, sessions, D1/D7/D30, curves |
| genre-designer | any genre adapted to Roblox |
| monetization-designer | passes, products, subs, economy, policy-safe |
| ux-mobile-designer | first 60 s, touch, safe areas, parity, look check |
| luau-architect | structure, types, toolchain, CI |
| server-programmer | authority, remotes, anti-exploit |
| client-ui-programmer | UI, input, camera, feel |
| code-optimizer | top priority: closes every story, measured optimization |
| art-generator | Studio MCP generation, style sheet, art look check |
| data-engineer | DataStores, session locks, migrations, receipts |
| analytics-engineer | events, funnels, Experiments |
| exploit-tester | attacks every remote |
| qa-playtester | plays via MCP, screenshots, smoke and soak |
| liveops-designer | events, cadence, publishing, soft shutdown |
| community-marketer | update logs, page copy, socials |
| team-coordinator | issues, branches, locks, handoffs, PRs |

## Research library
`docs/roblox/`: studio reference and the Studio MCP tool manifest, discovery algorithm and playbook, market data tools, UX standards with a look check rubric, implementation (Luau, networking, exploits, perf), data and monetization APIs, policy, art pipeline, code quality, and 32 genre files. Every claim is sourced and dated (2026-11-03); gaps are in [OPEN_QUESTIONS.md](docs/roblox/OPEN_QUESTIONS.md).

## Maintaining the studio
- `node tools/studio-lint.js all` (static checks), `node tools/gen-catalog.js --check` (spec coverage), `bash tools/test-hooks.sh` (hooks in both shells), `pwsh -File tools/test-install.ps1 -Sandbox <dir>` (installer round trip).
- `/skill-test` and `/skill-improve` run inside this repo.
- Design and decisions: `docs/audit/ROBLOX_STUDIO_DESIGN.md`, `DECISIONS.md`.

License: MIT (upstream copyright kept).
