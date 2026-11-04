# Build Prompt: Claude Code Game Studios → Roblox Studios (Nsidibe Edition)

> Paste this whole file into Claude Code at the root of a fresh clone of
> https://github.com/Donchitos/Claude-Code-Game-Studios, running with
> `claude --dangerously-skip-permissions` on the strongest model available.
> Machine: Windows. Shell: Git Bash + PowerShell.
> Model: Opus 5.5 (1M context), highest effort.

---

## 0. Mission

Take this repo (49 agents, 74 skills, 15 hooks, 14 rules, 62 templates, built for Godot/Unity/Unreal) and turn it into the best possible Claude Code studio for **Roblox development specifically**, tuned to one developer: me.

"100x better for Roblox" means:

1. Every agent, skill, rule, hook, and template either becomes Roblox-native or gets cut. Godot, Unity, and Unreal are cut completely. No dormant sets.
2. The studio knows **Roblox Studio front and back**: every service, API, tool, workflow, and toolchain option.
3. The studio knows the **Roblox discovery algorithm** and designs toward it from day one, not as a marketing afterthought.
4. The studio knows **Roblox UX** (mobile-first, short sessions, young audience, social play, the first 60 seconds) and enforces it.
5. The studio knows **Roblox implementation** (Luau, client/server split, replication, remotes, DataStores, exploit-proofing, monetization APIs) and writes production code, not engine-generic code.
6. The studio is **genre-agnostic**. It works for any Roblox game. Roblox now hosts nearly every genre, so the studio also understands game design across all genres (shooters, RPGs, horror, sports, racing, party, idle/clicker, simulator, tycoon, obby, roleplay, social hangout, strategy, fighting, survival, and more) and how each translates to Roblox constraints.
7. The studio works for **teams**: handoffs, GitHub issues, branches, and PRs.
8. The studio **makes code better over time**: project-specific code review and optimization is a core strength, not an afterthought.
9. The studio **installs globally** and works in any Roblox project folder I open, touching nothing in that folder except its own small state directory.
10. The studio **talks like me**: short, direct, what happened and what I do next.

You have a long runway. Use it. Research first, then design, then build, then test, then report. Do not stop to ask me questions mid-run; make the judgment call, log it in `DECISIONS.md`, and keep going.

---

## 1. Who You Are Building This For

- Roblox developer for 6+ years. Project lead, front-end programmer, conceptual designer. 80M+ combined plays, 3 front page titles.
- Former marketing manager for Fast Food Simulator. Built the **"QPTR over CTR"** growth strategy: optimize for qualified players who stay, not raw clicks on a thumbnail. Treat this as a core principle of the studio.
- Studies gamification and player psychology: Octalysis (especially Drive 4 Ownership and Drive 5 Social Influence), variable reward, flow vs. boredom vs. frustration, compulsion vs. enjoyment. Builds telemetry and A/B frameworks in live games.
- Uses Claude Code as primary coder on real projects. Will usually work with a team.
- Busy college student. Time is the scarcest resource. Every interaction with the studio must save time, not add process.

### Toolchain

- **Primary:** Roblox Studio MCP, driven from VS Code or Claude chat. Assume MCP is the default path for building, inspecting, running, and screenshotting the game.
- **The studio must also know every other option** (Rojo + VS Code, Wally, Git workflows, Selene, StyLua, Luau LSP, Lune, Open Cloud, Team Create, Studio-only) and **recommend a different approach when it is genuinely better for the situation**. Example: "This team has 4 scripters editing the same modules. Rojo + Git will save you merge pain. Here is the setup." One line of reasoning, then the steps.
- Build a skill that sets up whichever toolchain the project needs, MCP-first.

### Install Model: Global, Low Footprint

- I jump between a lot of games. The studio installs once into the user-level Claude Code config (`~/.claude/`: agents, skills, hooks, rules, settings) and works in any Roblox project folder.
- In a game folder, it adds only one small state directory (e.g., `.rbx-studio/`: project config, learned conventions, handoffs, run state). It never restructures, renames, or reformats my existing project files unless a task asks for it.
- Global hooks must detect whether the current folder is a Roblox project (Studio MCP connection, `default.project.json`, `.rbxl`/`.rbxlx`, `*.luau`, or `.rbx-studio/`) and do nothing otherwise, so non-Roblox work is unaffected.
- My teammates use Claude Code too. Ship a one-command installer and updater (PowerShell + Bash) so the whole team runs the same studio version. Include an uninstall that removes everything cleanly.
- Research how Claude Code user-level vs. project-level agents, skills, hooks, and settings load and merge, and design around that. Document it in `docs/install.md`.

---

## 2. Operating Rules For This Run

1. **Autonomous.** No clarifying questions. When a choice is ambiguous, pick the option that ships faster and is easier to reverse. Log it in `DECISIONS.md` with one line of reasoning.
2. **Research before rewriting.** Phase 2 output must exist before Phase 3 starts.
3. **Max-depth research.** Use every research capability available: web search and fetch, any local or installed research skills, parallel subagents, the Roblox Studio MCP `skill` tool and docs, GitHub repos of well-known open-source Roblox projects. Go wide, then go deep.
4. **Cite or flag.** Every claim about the Roblox algorithm, policy, or API goes in `docs/roblox/` with a source URL and the date you checked it. If you cannot verify something, label it `UNVERIFIED` and say what would verify it. Roblox changes fast; stale certainty is worse than honest uncertainty.
5. **Cut aggressively.** If an agent or skill does not earn its place, delete it. Fewer, sharper agents beat 49 generic ones.
6. **Keep what works.** Keep the parts of the original that work (project.yaml config, rigor modes, studio-tests, skill-test, the "launch it and look at it" rule). Rewire them for Roblox.
7. **Apply only what fits.** No skill, framework, or analysis runs by default just because it exists. Telemetry, flow/churn modeling, monetization psychology, discovery tactics, and every other module run **only when they apply to the current game and situation**. Every skill starts with a one-line relevance check and skips itself if it does not apply.
8. **Git: local only.** Commit locally after each phase with clear messages. **Never push, merge to main, or open PRs until I approve.** When I say "approved, push" (or similar), push in one step. This same rule becomes a default in the studio itself.
9. **Windows.** All hooks and scripts must work in Git Bash and PowerShell on Windows. Test them there. Keep the Windows toast notification hook.
10. **Safety.** No force pushes, no deleting anything outside this repo, no real credentials anywhere.
11. **Run until every phase passes.** No early stopping.
12. **Token and session survival plan.**
    - Keep `RUN_STATE.md` at the repo root updated after every completed task: current phase, done list, in-progress item, next 3 steps, open decisions. A fresh session must be able to resume from this file alone with "read RUN_STATE.md and continue."
    - Commit locally after every meaningful chunk, not just per phase, so nothing is lost if the session dies.
    - When roughly 1/4 of context or usage budget is left, switch to efficiency mode: stop broad exploration, read only the sections you need, summarize research into files instead of holding it in context, delegate bulky reads to subagents that return short summaries, and prioritize finishing the current phase cleanly over starting new work.
    - Before any compaction or likely cutoff, write a checkpoint to `RUN_STATE.md` and commit.
    - Build the same survival behavior into the studio itself as a skill (`/rbx-checkpoint` and `/rbx-resume`) so long sessions on real games work the same way.

---

## 3. Phase 1: Audit the Repo

Read everything in `.claude/`, `CLAUDE.md`, `project.yaml`, `README.md`, `UPGRADING.md`, and `studio-tests/`.

Produce `docs/audit/REPO_AUDIT.md` with one table covering every agent, skill, hook, rule, and template:

| Item | Type | Keep / Rewrite / Merge / Cut | Roblox equivalent or reason |

Rules of thumb:
- Godot/Unity/Unreal specialist sets and every reference to them: cut.
- Path-scoped rules keyed to `src/gameplay/**`, `*.tscn`, etc.: rewrite for Roblox project layout (both Rojo file layout and Studio DataModel layout via MCP).
- Hooks: keep the logic, retarget to `.luau` / `.lua` files, `default.project.json`, `wally.toml`, etc.
- Release skills mentioning Steam, butler, steamcmd: rewrite for Roblox publishing (place versions, Team Create, live updates, soft shutdown, data migration).

---

## 4. Phase 2: Research (the most important phase)

Prioritize: create.roblox.com docs, Roblox DevForum announcements and staff posts, Creator Hub analytics docs, Roblox engineering blog, RDC talks, Roblox investor/earnings materials for platform stats, third-party analytics platforms, and reputable creator sources. Write findings into `docs/roblox/` as short, scannable reference files the agents read later.

### 4.1 Roblox Studio, Front and Back → `docs/roblox/studio-reference.md`

Every major service and what it is for, Studio tools and plugins, Team Create, collaborative editing, drafts, packages, place/universe structure, the Roblox Studio MCP server (every tool it exposes and when to use each), Open Cloud APIs, Assistant, and the full set of toolchain options with honest tradeoffs and a "when to switch" guide.

### 4.2 Discovery Algorithm → `docs/roblox/discovery-algorithm.md`

Find out, as of today, how Roblox decides what to show players. Research leads to verify, not facts to assume:
- Home recommendations, sorts, Search, continue playing, friend activity, Sponsored/ads placements.
- What signals feed ranking: qualified play-through rate, session length, retention (D1/D7/D30), playtime, engagement quality, monetization signals, ratings, return rate, friend joins.
- How new experiences get initial exposure and what makes them escalate.
- Thumbnail and icon testing tools in Creator Hub, and thumbnail personalization.
- Maturity labels / content guidelines and how they affect who can see a game.
- Algorithm changes announced in the last 12 months.

### 4.3 Third-Party Data and Market Intelligence → `docs/roblox/market-data.md`

Research **RobloxGameStats** and every other serious Roblox analytics and market-intelligence company or tool (find the current leaders; verify each is still active). For each: what data it has, how to access it, cost, and which studio skills should use it. Also research how these firms read trends (genre rises, breakout patterns, update cadence vs. player count).

Then produce `docs/roblox/discovery-playbook.md`: what a developer should actually do, phase by phase (pre-launch, launch week, scale), mapped to QPTR over CTR. Each action gets a metric to watch in Creator Dashboard or a third-party tool.

### 4.4 Roblox UX → `docs/roblox/ux-standards.md`

- Platform audience split (device, age bands) with current numbers and sources. Default assumption until proven otherwise: mobile-first.
- First 60 seconds: time to first fun, onboarding without text walls, loading screen and spawn.
- Touch targets, thumb zones, safe areas, GuiInset/topbar, notches, `UIScale`, `UIAspectRatioConstraint`, scale vs. offset, readable text at phone resolution.
- Console/gamepad navigation and keyboard/mouse parity.
- Social UX: party joins, friend invites, private servers, emotes, chat norms via `TextChatService`.
- Shop and monetization UX that converts without feeling predatory.
- Accessibility basics that matter on Roblox.

### 4.5 Genre Library → `docs/roblox/genres/`

One short file per genre: core loop, what top Roblox games in that genre do in session one, retention hooks, monetization norms, common technical traps, and what transfers from that genre outside Roblox. Cover all genres, including ones not traditionally big on Roblox.

### 4.6 Roblox Implementation → `docs/roblox/implementation.md`

- Luau: strict typing, `--!strict`, generics, performance idioms, `--!native` and when it helps.
- Architecture: client/server boundary, ModuleScript structure, single-script vs. many scripts, common frameworks with honest tradeoffs.
- Networking: RemoteEvent / RemoteFunction / UnreliableRemoteEvent, rate limiting, payload size, server-authoritative validation.
- Exploit prevention: what exploiters can actually do, sanity checks, remote spam defense, currency and inventory protection.
- Data: DataStoreService limits, session locking, ProfileStore or equivalent, versioning and migration, `MemoryStoreService`, `MessagingService`.
- Monetization APIs: `MarketplaceService`, `ProcessReceipt` correctness (idempotent, never lose a purchase), gamepasses, developer products, subscriptions, `PolicyService`, ads and rewarded video APIs.
- Performance: mobile memory budgets, streaming, instance and part counts, MicroProfiler, script activity.
- Analytics: `AnalyticsService` custom, funnel, and economy events; how they surface in Creator Dashboard.

### 4.7 Policy and Compliance → `docs/roblox/policy.md`

Community Standards, content guidelines, paid random item rules (odds disclosure, regional restrictions), age-related rules, IP/copyright risk (very relevant for meme and brainrot content), ads policy. Every monetization or content skill checks against this file.

### 4.8 Art and Asset Pipeline → `docs/roblox/art-pipeline.md`

- Studio MCP generation tools (mesh, material, texture, procedural models) for both placeholder and production art: what each does well, limits, and how to get production-quality output.
- Figma → Roblox UI pipeline via a Figma MCP: research current tools and plugins for converting Figma designs into Roblox UI, and design a future-ready path even if it is not wired yet.
- Asset optimization for mobile (texture size, triangle counts, image compression).

### 4.9 Code Quality and Optimization → `docs/roblox/code-quality.md`

Research how the original repo handles code review (`/code-review`, `/tech-debt`, `/perf-profile`, rules, hooks), then research the best Luau code quality practices from top Roblox studios and open-source projects: static analysis, typing, profiling, memory leak patterns (connections not disconnected, instances not destroyed), hot path optimization, network bandwidth, DataStore budgets. This feeds the most important agent in the studio (see Section 5).

### 4.10 Gap Check

End Phase 2 with `docs/roblox/OPEN_QUESTIONS.md`: what you could not verify and how I could verify it.

---

## 5. Phase 3: Design the Roblox Studio

Write `docs/audit/ROBLOX_STUDIO_DESIGN.md` before building. Cover:

1. **Roster.** Target 12 to 20 agents max. Starting point (adjust from research):
   - `roblox-director` (vision + scope, replaces the creative/technical/producer trio for a small team)
   - `discovery-strategist` (algorithm, QPTR, thumbnails/icons, launch plan, third-party market data)
   - `retention-designer` (core loop, session design, D1/D7 hooks, flow vs. frustration when relevant)
   - `genre-designer` (pulls from the genre library, adapts any genre to Roblox)
   - `monetization-designer` (gamepasses, dev products, subscriptions, policy-safe; picks whatever fits the game; avoids anything that reads as a cash grab unless the game's systems genuinely support it)
   - `ux-mobile-designer` (first 60 seconds, touch, safe areas, console parity)
   - `luau-architect` (structure, types, module boundaries, toolchain recommendation)
   - `server-programmer` (authority, remotes, anti-exploit)
   - `client-ui-programmer` (UI implementation, tweens, responsive layout)
   - `code-optimizer` (**top-priority agent**: see Code Quality below)
   - `art-generator` (Studio MCP generation for placeholder and production art; future Figma pipeline)
   - `data-engineer` (DataStores, session locking, migrations, receipts)
   - `analytics-engineer` (events, funnels, A/B tests, flow/churn telemetry only when useful)
   - `exploit-tester` (attacks every remote)
   - `qa-playtester` (runs the game via Studio MCP, screenshots, mobile emulation)
   - `liveops-designer` (events, updates, limited items, cadence)
   - `community-marketer` (update logs, socials, ads)
   - `team-coordinator` (handoffs, GitHub issues, branches, PR prep)
2. **Skills.** Keep the best of the original, rewrite for Roblox, and add Roblox-native ones:
   - `/rbx-start` (detect existing project via MCP or files; scaffold MCP-first setup; recommend Rojo + Git if the team situation calls for it)
   - `/rbx-toolchain` (set up or switch toolchain, Windows-ready)
   - `/rbx-concept` (one-page brief with a discovery hypothesis and QPTR story)
   - `/rbx-genre` (pull genre patterns for the current game)
   - `/rbx-first-60` (design and review the first minute of play)
   - `/rbx-loop` (core loop, session plan, retention hooks)
   - `/rbx-monetize` (offer design, placement, price ladder, policy check)
   - `/rbx-thumbnail` (icon/thumbnail brief and A/B plan)
   - `/rbx-remote-audit` (scan every remote for trust and rate-limit issues)
   - `/rbx-data-audit` (DataStore safety, session lock, receipt idempotency)
   - `/rbx-perf` (mobile performance review)
   - `/rbx-review` (project-specific code review against the project's learned conventions)
   - `/rbx-optimize` (find and fix the highest-impact performance, memory, and network issues in the current project, measure before and after)
   - `/rbx-art` (generate or improve assets via Studio MCP; run the look check)
   - `/rbx-checkpoint` and `/rbx-resume` (save and restore session state for long work)
   - `/rbx-telemetry` (analytics events, funnels; flow/churn signals only if relevant)
   - `/rbx-playtest` (launch via Studio MCP, play, screenshot, report)
   - `/rbx-teardown` (analyze a competitor or reference game's loop, UX, monetization, discovery)
   - `/rbx-metrics` (paste Creator Dashboard or third-party numbers, get diagnosis and next actions)
   - `/rbx-issues` (read open GitHub issues via `gh`, triage, turn into stories, link fixes back)
   - `/rbx-handoff` (write a handoff note for a teammate: what changed, what is open, where to start)
   - `/rbx-pickup` (read the latest handoff notes, issues, and commits, then tell me where things stand)
   - `/rbx-ship` (only after my approval: push, open PR, link issues)
   - `/rbx-launch` (launch checklist: thumbnails, description, maturity, ads, update log)
   - `/rbx-update` (live update checklist, soft shutdown, data migration)
3. **Code Quality (emphasize heavily).**
   - Each project gets a `.rbx-studio/conventions.md` that the studio builds by reading the existing code, then keeps improving. It records patterns that are good and patterns to phase out. The goal is not to copy my old code; the goal is for the code to keep getting better and more optimized.
   - `code-optimizer` reviews every story before it closes: correctness, typing, security, performance, memory, readability. It fixes what it can and flags the rest.
   - Optimization claims need evidence: MicroProfiler numbers, memory stats, script activity, or a clear before/after.
   - Periodic `/rbx-optimize` passes target tech debt in priority order without breaking working features.
4. **Look Check for UI and Art.** Anything visual is not done until it has been launched via Studio MCP, screenshotted at phone and desktop resolutions, and judged against `ux-standards.md`. Only escalate UI or art to a human artist when it fails the look check twice, or when I say something like "this looks rly bad, we gotta work on it." Then write a short artist brief in my style.
5. **Team workflow.** Branch naming, commit message format, handoff note location (`production/handoffs/`), how issues map to stories, how the studio avoids two people's Claude sessions editing the same module. Default: local commits, push only on approval. Handoff notes are for humans and use my style: concise, straight to the point, clear actions.
6. **Rules.** Path-scoped rules for Roblox layout (`src/server/**`, `src/client/**`, `src/shared/**`, `*.luau`), e.g., server never trusts client input, all purchases through one receipt handler, no yields in hot paths, typed modules in shared.
7. **Hooks.** Retarget validation to Luau: Selene + StyLua on write when available, block commits with unguarded remotes, warn on DataStore calls outside the data module, block `git push` unless approval was given in this session.
8. **Templates.** Roblox GDD (short), discovery plan, monetization sheet, remote contract, data schema, update log, playtest report, handoff note.
9. **Config.** `project.yaml` gets a `roblox` block (toolchain, genre, target devices, monetization style, team size, analytics on/off), stored in `.rbx-studio/` per game. Default `modes.rigor: minimal`.

---

## 6. Phase 4: Build

Implement the design. Then:
- Update `CLAUDE.md` to be Roblox-first and short.
- Rewrite `README.md` for this fork.
- Update `studio-tests/` catalog and specs so `/skill-test audit` passes for the new roster.
- Remove every reference to Godot/Unity/Unreal (grep for them).

---

## 7. Phase 5: Test

1. Run `/skill-test static` and `/skill-test audit` on everything. Fix until clean.
2. Run every hook in Git Bash and PowerShell on Windows. Fix anything that breaks.
3. **Dogfood on a placeholder game:** a brainrot-themed idle mining clicker in the style of Doge Miner. All original placeholder names and art (no real brainrot characters or other IP). Its only purpose is to exercise the workflow.
   - `/rbx-start` → `/rbx-concept` → `/rbx-loop` → `/rbx-first-60` → build a playable build via Studio MCP.
   - Generate placeholder art via `/rbx-art` and run the look check.
   - Run `/rbx-review` and `/rbx-optimize` and show measured before/after.
   - Run `/rbx-monetize`, `/rbx-remote-audit`, `/rbx-data-audit`, `/rbx-telemetry`, and `/rbx-playtest` against it.
   - Simulate a team handoff: `/rbx-handoff`, then a fresh session runs `/rbx-pickup`.
   - Launch and screenshot via Studio MCP. If MCP is unavailable during the run, say so in the report and test via files.
4. Test the global install: install via the installer, open the dogfood game folder, confirm only `.rbx-studio/` was added, then open a non-Roblox folder and confirm the hooks do nothing. Test uninstall.
5. Test survival: kill a session mid-task, start a fresh one, run `/rbx-resume`, confirm it continues correctly.
6. Log every friction point and fix it before finishing.

---

## 8. Communication Style (applies to every agent and skill you write)

Non-negotiable. Bake it into `CLAUDE.md` and every agent prompt.

- Lead with the result. No preamble, no recap of my request.
- Short sentences. Plain words. Shorthand is fine.
- No em dashes. No filler ("Great question", "It's worth noting", "Let's dive in"). No AI-sounding prose.
- Concrete over abstract. Numbers, file names, line numbers, exact Studio menu paths.
- Make judgment calls in execution mode instead of asking. Ask only when a wrong guess is expensive and hard to reverse, and then ask one question with options.
- Every task report uses this shape and nothing else:

```
DONE
- what changed, 1 line each, with file paths

YOU DO
- the exact steps I need to take, numbered, smallest first
  (e.g., "Open Studio > Game Settings > Monetization > turn on X")

RISKS
- only if real; otherwise omit this section

NEXT
- 1 line: the highest-leverage next move
```

---

## 9. Final Deliverables

1. Working fork with all changes committed **locally**. Not pushed.
2. Installer, updater, and uninstaller for the global install, plus `docs/install.md`.
3. `docs/roblox/` research library with sources and dates.
4. `docs/audit/REPO_AUDIT.md`, `ROBLOX_STUDIO_DESIGN.md`, `DECISIONS.md`.
5. `docs/roblox/OPEN_QUESTIONS.md`.
6. The placeholder dogfood game and its playtest evidence.
7. A final report in the Section 8 format, plus: agent count before/after, skill count before/after, what you cut and why (one line each), and the 3 skills I should try first on my real game.
