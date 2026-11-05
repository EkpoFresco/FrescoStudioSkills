# FrescoStudioSkills

A Roblox game studio inside Claude Code. You type a command like `/rbx-build`, and a team of specialist helpers plans, codes, tests and reviews it in your game.

Install it once. It works in any Roblox game folder and only ever adds one folder there: `.rbx-studio/`.

## Setup (5 minutes)
1. Install:
   ```powershell
   git clone https://github.com/EkpoFresco/FrescoStudioSkills.git
   cd FrescoStudioSkills
   .\install.ps1          # Mac / Git Bash: ./install.sh
   ```
2. Connect Roblox Studio (lets Claude play and screenshot your game):
   - In Studio: **Assistant > ... > Manage MCP Servers > enable**.
   - In a terminal: `claude mcp add --scope user roblox-studio -- "%LOCALAPPDATA%\Roblox\mcp.bat"`
3. Restart Claude Code inside your game folder and type `/rbx-start`.

To update later, run `.\install.ps1 -Update`. More options: [docs/install.md](docs/install.md).

## First session
**Existing game:** make a branch, open Claude Code in the game folder, then run:
1. `/rbx-start` sets up `.rbx-studio/` and learns your code style.
2. `/rbx-pickup` shows where things stand and the best next move.
3. `/rbx-plan` turns your goal into small tasks (S-01, S-02...).
4. `/rbx-build S-01` builds the first one.

**New game:** `/rbx-start new`, then `/rbx-concept brainstorm <theme>`.

## What do you want to do?
| I want to... | Type |
| --- | --- |
| Set up a game folder | `/rbx-start` |
| See where things stand | `/rbx-pickup` |
| Brainstorm or judge a game idea | `/rbx-concept` |
| Plan the work into small tasks | `/rbx-plan` |
| Build a feature or fix | `/rbx-build <task or description>` |
| Play-test it with screenshots | `/rbx-playtest` |
| Check the first minute for new players | `/rbx-first-60` |
| Try a teammate's branch without merging | `/rbx-try <branch>` |
| Review code | `/rbx-review` |
| Check for exploits | `/rbx-remote-audit` |
| Check saving and purchases are safe | `/rbx-data-audit` |
| Fix lag | `/rbx-perf`, then `/rbx-optimize` |
| Save progress before stopping | `/rbx-checkpoint` |
| Pick up after a crash | `/rbx-resume` |
| Hand work to a teammate | `/rbx-handoff` |
| Push and open a PR | `/rbx-ship` |

<details>
<summary>All 30 commands by stage</summary>

| Stage | Commands |
|---|---|
| Setup | `/rbx-start`, `/rbx-toolchain`, `/rbx-map`, `/rbx-checkpoint`, `/rbx-resume` |
| Design | `/rbx-concept`, `/rbx-genre`, `/rbx-loop`, `/rbx-first-60`, `/rbx-plan`, `/rbx-monetize`, `/rbx-thumbnail` |
| Build | `/rbx-build`, `/rbx-art`, `/rbx-telemetry` |
| Quality | `/rbx-review`, `/rbx-optimize`, `/rbx-perf`, `/rbx-remote-audit`, `/rbx-data-audit`, `/rbx-playtest` |
| Growth | `/rbx-teardown`, `/rbx-metrics`, `/rbx-launch`, `/rbx-update` |
| Team | `/rbx-issues`, `/rbx-handoff`, `/rbx-pickup`, `/rbx-try`, `/rbx-ship` |
</details>

## Safe by default
- **Nothing goes to GitHub without you.** Push, PR and merge are blocked until you type `approved, push` or `/rbx-ship`.
- **Your files stay yours.** It only writes `.rbx-studio/` in a game folder. It never moves, renames or reformats your code.
- **Work stays on branches.** Commits are local until you approve.
- **Nothing visual counts as done until it's screenshotted** on phone and desktop.
- **Every change is reviewed** for speed and exploits before it closes.

## How it thinks
- **Players who stay beat players who click.** Designs follow Roblox's real ranking signals: do players keep playing past the first few minutes, and come back the next day.
- **Phone first.** Most Roblox players are on phones.
- **Server decides, client asks.** Every message from a player is checked, so exploiters can't fake it.
- **Short reports.** Every answer ends in four parts: DONE, YOU DO, RISKS, NEXT.

<details>
<summary>The helper team (18 specialists)</summary>

| Helper | Handles |
|---|---|
| roblox-director | vision, scope, what to cut, go or kill calls |
| discovery-strategist | getting found: algorithm, thumbnails, launch |
| retention-designer | core loop, why players come back |
| genre-designer | what works in your genre on Roblox |
| monetization-designer | passes, products, fair pricing |
| ux-mobile-designer | first minute, touch controls, phone layout |
| luau-architect | code structure and tooling |
| server-programmer | game logic, anti-exploit |
| client-ui-programmer | UI, input, camera, game feel |
| code-optimizer | reviews every change, fixes lag |
| art-generator | in-Studio art and style |
| data-engineer | saving, purchases, data safety |
| analytics-engineer | tracking what players do |
| exploit-tester | tries to break every system |
| qa-playtester | plays the game and screenshots it |
| liveops-designer | events and update schedule |
| community-marketer | update logs, game page, socials |
| team-coordinator | tasks, branches, handoffs |
</details>

<details>
<summary>Research library</summary>

`docs/roblox/` holds sourced, dated notes on how Roblox works today: the discovery algorithm, phone UX standards, policy rules, data and purchase APIs, performance, and 32 genre guides. Unconfirmed facts are marked UNVERIFIED and listed in [OPEN_QUESTIONS.md](docs/roblox/OPEN_QUESTIONS.md).
</details>

<details>
<summary>For maintainers</summary>

- Checks after editing `studio/`: `node tools/studio-lint.js all`, `node tools/gen-catalog.js --check`, `bash tools/test-hooks.sh`, `pwsh -File tools/test-install.ps1 -Sandbox <dir>`.
- Token cost: a project map (`.rbx-studio/map.md`) and a section reader (`tools/lib.js`) keep sessions cheap. Track with `node tools/token-budget.js`.
- Design notes: `docs/audit/ROBLOX_STUDIO_DESIGN.md`, `DECISIONS.md`. Changes: `CHANGELOG.md`.
</details>

Forked from [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) v1.2.0 and rebuilt for Roblox only. License: MIT (upstream copyright kept).
