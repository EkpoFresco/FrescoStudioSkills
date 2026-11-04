# Repo Audit: Claude Code Game Studios v1.2.0 → Roblox Studio

Audited 2026-11-03 against upstream `main` @ 05ad7c8 (v1.2.0).
Scope: every agent, skill, hook, rule, template, shared doc, script, and top-level file.

## Summary

| Area | Before | Keep | Rewrite | Merge | Cut | After (target) |
|---|---|---|---|---|---|---|
| Agents | 49 | 0 | 4 | 26 | 19 | 18 (14 renamed/rewritten + 4 new) |
| Skills | 74 | 2 | 6 | 47 | 19 | 30 (28 `rbx-*` + 2 maintainer skills) |
| Hooks + helpers | 18 | 1 | 6 | 3 | 8 | 1 dispatcher per shell (bash + PowerShell) |
| Rules | 14 | 1 | 5 | 2 | 6 | 7 |
| Templates (incl. guidance) | 64 + 8 | 0 | 12 | 10 | 50 | 14 |
| Shared docs (`.claude/docs`) | 25 + 28 gates + 6 hook refs | 0 | 8 | 6 | 45 | 9 |
| Scripts (`.claude/scripts`) | 37 | 0 | 2 | 1 | 34 | 4 (Node maintainer tools) |

What earns a place: a distinct Roblox domain, a skill that uses it, and output the developer acts on. Process built for 20-person Godot/Unity/Unreal studios (director gates, ADR traceability, sprint ceremony, entity registries) is cut. The developer is a busy solo-to-small-team lead; the studio must save time, not add process.

Key structural change: the original is a project template (you clone it as your game). The new studio installs once into `~/.claude/` and works in any Roblox folder, writing only `.rbx-studio/` there. So everything that assumed "the repo is the game" (`production/`, `design/`, `src/`, entity registries, `CLAUDE.md` imports) is rebuilt around a per-game `.rbx-studio/` state dir.

---

## Agents (49)

| Item | Type | Decision | Roblox equivalent or reason |
|---|---|---|---|
| creative-director | agent | Merge | → `roblox-director` (vision, pillars, scope). One director for a small team. |
| technical-director | agent | Merge | → `roblox-director` (tech risk) + `luau-architect` (architecture calls). |
| producer | agent | Merge | → `roblox-director` (scope) + `team-coordinator` (coordination, handoffs). |
| art-director | agent | Merge | → `art-generator` (style sheet, look check). |
| technical-artist | agent | Merge | → `art-generator` (asset budgets) + `code-optimizer` (render perf). |
| audio-director | agent | Merge | → `art-generator` (audio sourcing via Creator Store `search_asset`). Audio direction rarely a Roblox bottleneck. |
| sound-designer | agent | Merge | → `art-generator` (SFX specs). |
| accessibility-specialist | agent | Merge | → `ux-mobile-designer` (text size, contrast, reduced motion, input parity). |
| ux-designer | agent | Rewrite | → `ux-mobile-designer` (first 60 s, touch, safe areas, console parity). |
| ui-programmer | agent | Rewrite | → `client-ui-programmer` (ScreenGui, UIScale, tweens, client feel). |
| analytics-engineer | agent | Rewrite | → `analytics-engineer` (AnalyticsService funnels/economy/custom events, A/B bucketing). |
| live-ops-designer | agent | Rewrite | → `liveops-designer` (events, limited items, update cadence). |
| community-manager | agent | Merge | → `community-marketer` (update logs, socials, ads copy). |
| writer | agent | Merge | → `community-marketer` (player-facing copy) + `genre-designer` (in-game text for story genres). |
| narrative-director | agent | Merge | → `genre-designer` (story genres). |
| world-builder | agent | Cut | Lore depth is not a Roblox bottleneck; `genre-designer` covers story genres. |
| game-designer | agent | Merge | → `genre-designer` (mechanics by genre) + `retention-designer` (loops). |
| systems-designer | agent | Merge | → `retention-designer` (progression curves) + `monetization-designer` (economy math). |
| economy-designer | agent | Merge | → `monetization-designer` (sinks/faucets, price ladder). |
| level-designer | agent | Merge | → `genre-designer` (map, obby stage, arena layout). |
| prototyper | agent | Merge | → `server-programmer` + `client-ui-programmer` under `/rbx-build --prototype` (speed over standards). |
| lead-programmer | agent | Merge | → `luau-architect` (standards, structure) + `code-optimizer` (review). |
| gameplay-programmer | agent | Merge | → `server-programmer` (authoritative gameplay) + `client-ui-programmer` (input, camera, feel). |
| network-programmer | agent | Merge | → `server-programmer` (remotes, replication, validation). |
| ai-programmer | agent | Merge | → `server-programmer` (NPCs, PathfindingService). |
| engine-programmer | agent | Cut | No engine code on Roblox. Perf parts → `code-optimizer`. |
| performance-analyst | agent | Merge | → `code-optimizer` (MicroProfiler, memory, measured before/after). |
| tools-programmer | agent | Merge | → `luau-architect` (toolchain, plugins, CI). |
| devops-engineer | agent | Merge | → `luau-architect` (Rojo/Wally/CI) + `team-coordinator` (branches, PR prep). |
| release-manager | agent | Merge | → `liveops-designer` (place publish, soft shutdown cadence) + `team-coordinator` (ship). Steam/console certification cut. |
| qa-lead | agent | Merge | → `qa-playtester`. |
| qa-tester | agent | Merge | → `qa-playtester` (Studio MCP play, screenshots, device emulation). |
| security-engineer | agent | Merge | → `exploit-tester` (attack every remote) + `server-programmer` (fixes). |
| localization-lead | agent | Merge | → `ux-mobile-designer` (LocalizationService, auto-translate, text expansion). |
| godot-specialist | agent | Cut | Godot. |
| godot-gdscript-specialist | agent | Cut | Godot. |
| godot-csharp-specialist | agent | Cut | Godot. |
| godot-shader-specialist | agent | Cut | Godot. |
| godot-gdextension-specialist | agent | Cut | Godot. |
| unity-specialist | agent | Cut | Unity. |
| unity-ui-specialist | agent | Cut | Unity. |
| unity-shader-specialist | agent | Cut | Unity. |
| unity-dots-specialist | agent | Cut | Unity. |
| unity-addressables-specialist | agent | Cut | Unity. |
| unreal-specialist | agent | Cut | Unreal. |
| ue-blueprint-specialist | agent | Cut | Unreal. |
| ue-gas-specialist | agent | Cut | Unreal. |
| ue-replication-specialist | agent | Cut | Unreal. |
| ue-umg-specialist | agent | Cut | Unreal. |

New agents with no direct original: `discovery-strategist` (algorithm, QPTR, thumbnails, market data), `data-engineer` (DataStores, session locks, receipts, migrations), `code-optimizer` (top priority, closes every story), `team-coordinator` (issues, branches, handoffs, PR prep). `luau-architect`, `exploit-tester`, `qa-playtester`, `art-generator`, `retention-designer`, `monetization-designer` are new names built from merged originals.

## Skills (74)

| Item | Type | Decision | Roblox equivalent or reason |
|---|---|---|---|
| start | skill | Rewrite | → `/rbx-start` (detect project via MCP or files, scaffold `.rbx-studio/`, learn conventions, recommend toolchain). |
| setup-engine | skill | Merge | → `/rbx-start` + `/rbx-toolchain`. No engine version pinning on Roblox (live platform). |
| project-stage-detect | skill | Merge | → `/rbx-start` (detect) + `/rbx-pickup` (where things stand). |
| adopt | skill | Merge | → `/rbx-start` (brownfield: read existing code, write `conventions.md`). |
| reverse-document | skill | Merge | → `/rbx-start` (conventions from code). |
| onboard | skill | Merge | → `/rbx-pickup` (teammate onboarding). |
| help | skill | Merge | → `/rbx-pickup` (what next). |
| settings | skill | Merge | → `/rbx-start config key=value`. |
| brainstorm | skill | Merge | → `/rbx-concept`. |
| prototype | skill | Merge | → `/rbx-build --prototype`. |
| vertical-slice | skill | Merge | → `/rbx-build` + `/rbx-playtest`. |
| quick-design | skill | Merge | → `/rbx-build` (inline mini spec). |
| design-system | skill | Merge | → `/rbx-loop` (systems) + `/rbx-concept`. 1,370 lines of GDD authoring is too heavy. |
| map-systems | skill | Merge | → `/rbx-plan` (concept to backlog). |
| create-epics | skill | Merge | → `/rbx-plan`. |
| create-stories | skill | Merge | → `/rbx-plan` + `/rbx-issues`. |
| sprint-plan | skill | Merge | → `/rbx-plan` (milestone backlog). |
| estimate | skill | Merge | → `/rbx-plan` (S/M/L sizing). |
| scope-check | skill | Merge | → `/rbx-plan` (cut list). |
| story-readiness | skill | Merge | → `/rbx-build` Phase 1 (acceptance criteria check). |
| dev-story | skill | Rewrite | → `/rbx-build` (implement a story via MCP or files, with tests where they fit). |
| story-done | skill | Merge | → `/rbx-build` close gate: `code-optimizer` review + look check. |
| code-review | skill | Rewrite | → `/rbx-review` (project-specific, against `conventions.md`). |
| tech-debt | skill | Merge | → `/rbx-optimize` (debt register, priority passes). |
| perf-profile | skill | Rewrite | → `/rbx-perf` (mobile perf via MicroProfiler / Studio MCP `rbx-perf-profiling`). |
| security-audit | skill | Merge | → `/rbx-remote-audit` + `/rbx-data-audit`. |
| balance-check | skill | Merge | → `/rbx-loop` (curve sim) + `/rbx-monetize` (economy). |
| playtest-report | skill | Merge | → `/rbx-playtest`. |
| qa-plan | skill | Merge | → `/rbx-playtest` (test plan per build). |
| smoke-check | skill | Merge | → `/rbx-playtest --smoke`. |
| soak-test | skill | Merge | → `/rbx-playtest --soak` (memory over time). |
| regression-suite | skill | Cut | Rarely used solo; `/rbx-playtest` keeps a checklist. |
| test-setup | skill | Merge | → `/rbx-toolchain tests` (Jest-Lua / Studio MCP `rbx-unit-test`). |
| test-helpers | skill | Cut | Engine-specific test helpers. |
| test-evidence-review | skill | Cut | Evidence rules live in `/rbx-build` close gate. |
| test-flakiness | skill | Cut | CI-scale problem; not a Roblox solo/small-team need. |
| art-bible | skill | Merge | → `/rbx-art style` (one-page style sheet). |
| asset-spec | skill | Merge | → `/rbx-art` (prompts per asset). |
| asset-audit | skill | Merge | → `/rbx-art audit` + `/rbx-perf` (texture/triangle budgets). |
| ux-design | skill | Merge | → `/rbx-first-60` + `/rbx-build` UI stories. |
| ux-review | skill | Merge | → look check in `/rbx-playtest` and `/rbx-first-60`. |
| localize | skill | Cut | Roblox auto-translation + `ux-mobile-designer` knowledge; checklist line in `/rbx-launch`. |
| launch-checklist | skill | Rewrite | → `/rbx-launch` (thumbnails, description, maturity, ads, update log). |
| release-checklist | skill | Merge | → `/rbx-launch` + `/rbx-update`. Steam/console cert cut. |
| day-one-patch | skill | Merge | → `/rbx-update --hotfix`. |
| hotfix | skill | Merge | → `/rbx-update --hotfix` (publish, soft shutdown, rollback). |
| changelog | skill | Merge | → `/rbx-update` (update log) + `/rbx-handoff` (internal). |
| patch-notes | skill | Merge | → `/rbx-update` (player-facing update log). |
| bug-report | skill | Merge | → `/rbx-issues` (draft issue). |
| bug-triage | skill | Merge | → `/rbx-issues` (triage). |
| milestone-review | skill | Merge | → `/rbx-pickup` (status) + `/rbx-metrics`. |
| sprint-status | skill | Merge | → `/rbx-pickup`. |
| retrospective | skill | Cut | Ceremony. `/rbx-handoff` captures what changed. |
| gate-check | skill | Cut | 1,371-line phase gate. Replaced by story close gate and `/rbx-launch` go/no-go. |
| design-review | skill | Cut | Director review of GDDs; small teams review in chat. |
| review-all-gdds | skill | Cut | GDD corpus review. |
| consistency-check | skill | Cut | Entity registry. |
| content-audit | skill | Cut | Planned vs built GDD counts. `/rbx-pickup` reports backlog state. |
| propagate-design-change | skill | Cut | ADR staleness tracking. |
| architecture-decision | skill | Merge | → one-line entries in `.rbx-studio/decisions.md` (luau-architect). |
| create-architecture | skill | Merge | → `/rbx-start` (module layout) + `luau-architect`. |
| architecture-review | skill | Cut | TR traceability matrix. |
| create-control-manifest | skill | Merge | → `.rbx-studio/conventions.md` (must-do / never-do). |
| team-combat | skill | Cut | Orchestration ceremony; skills call agents directly. |
| team-narrative | skill | Cut | Same. |
| team-audio | skill | Cut | Same. |
| team-level | skill | Cut | Same. |
| team-ui | skill | Merge | → `/rbx-build` (UI story: ux-mobile-designer → client-ui-programmer → look check). |
| team-qa | skill | Merge | → `/rbx-playtest`. |
| team-release | skill | Merge | → `/rbx-ship` + `/rbx-update`. |
| team-polish | skill | Merge | → `/rbx-optimize`. |
| team-live-ops | skill | Merge | → `/rbx-update` + `liveops-designer`. |
| skill-test | skill | Keep | Maintainer skill, rewired: Check 4 becomes "write scope + approval" (autonomous studio); runs a Node linter. |
| skill-improve | skill | Keep | Maintainer skill, rewired to new catalog. |

New skills with no original: `/rbx-toolchain`, `/rbx-genre`, `/rbx-first-60`, `/rbx-monetize`, `/rbx-thumbnail`, `/rbx-remote-audit`, `/rbx-data-audit`, `/rbx-optimize`, `/rbx-art`, `/rbx-checkpoint`, `/rbx-resume`, `/rbx-telemetry`, `/rbx-teardown`, `/rbx-metrics`, `/rbx-handoff`, `/rbx-pickup`, `/rbx-ship`.

## Hooks (15 registered + 3 helpers)

| Item | Type | Decision | Roblox equivalent or reason |
|---|---|---|---|
| session-start.sh | hook | Rewrite | → `SessionStart`: detect Roblox project, inject studio rules + latest checkpoint/handoff; silent elsewhere. |
| detect-gaps.sh | hook | Merge | → SessionStart: one line if `.rbx-studio/` or `conventions.md` missing. |
| pre-compact.sh | hook | Rewrite | → `PreCompact`: write auto checkpoint to `.rbx-studio/state/` (survival plan). |
| session-stop.sh | hook | Rewrite | → `Stop`: cheap last-turn stamp (changed files) so `/rbx-resume` has ground truth after a kill. |
| notify.sh | hook | Keep | Windows toast, unchanged logic, gated to Roblox projects. |
| validate-commit.sh | hook | Rewrite | → `PreToolUse` git commit: block unguarded remote handlers in staged Luau; run Selene/StyLua checks when configured. 826 lines → ~100. |
| validate-push.sh | hook | Rewrite | → `PreToolUse`: block `git push`, `gh pr create/merge`, merge into main unless approval was given this session (token from `UserPromptSubmit`). Butler/steamcmd cut. |
| validate-write.sh | hook | Rewrite | → `PostToolUse` Write/Edit and MCP `multi_edit`: Selene/StyLua when available, DataStore calls outside data module warn. |
| validate-assets.sh | hook | Cut | Local asset naming/size; Roblox assets live in the cloud. `/rbx-art audit` covers budgets. |
| validate-read.sh | hook | Cut | 40 KB whole-read guard for GDDs; no GDD corpus now. |
| validate-registry.sh | hook | Cut | Entity registry removed. |
| validate-skill-change.sh | hook | Merge | → maintainer-only project hook in this repo (`.claude/settings.json`). Not installed globally. |
| validate-agent-artifact.sh | hook | Cut | Subagent artifact policing; noise. |
| log-agent.sh | hook | Cut | Audit log noise; `.rbx-studio/` must stay small. |
| log-agent-stop.sh | hook | Cut | Same. |
| log-instructions.sh | hook | Cut | Debug aid; `claude --debug` covers it. |
| update-check.sh | helper | Merge | → SessionStart: compare installed studio version to the source clone once a day. |
| yaml-helper.sh | helper | Cut | 2,152-line config resolver. New config is a flat `.rbx-studio/project.yaml` read directly. |
| statusline.sh | helper | Cut | A global statusLine would overwrite the user's own (scalar key). Not installed. |

## Rules (14)

| Item | Type | Decision | Roblox equivalent or reason |
|---|---|---|---|
| network-code.md | rule | Rewrite | → `rbx-remotes.md` (server never trusts client, rate limits, typed payloads). |
| gameplay-code.md | rule | Merge | → `rbx-server-code.md` + `rbx-client-code.md`. |
| ai-code.md | rule | Merge | → `rbx-server-code.md`. |
| ui-code.md | rule | Rewrite | → `rbx-client-code.md` (scale, safe areas, UIScale, no yields in render loop). |
| data-files.md | rule | Rewrite | → `rbx-data.md` (DataStore access only in data module, versioned schema, one receipt handler). |
| engine-code.md | rule | Rewrite | → `rbx-luau.md` (all `*.luau`: strict mode, no yields in hot paths, cleanup). |
| test-standards.md | rule | Rewrite | → `rbx-tests.md` (`*.spec.luau`, deterministic, no live DataStores). |
| scene-files.md | rule | Rewrite | → `rbx-place-files.md` (never hand-edit `.rbxl`; `.project.json` edits keep tree stable). |
| skill-authoring.md | rule | Keep | Maintainer rule in this repo, rewritten for `rbx-*` conventions. |
| prototype-code.md | rule | Cut | Prototype mode is a flag on `/rbx-build`, not a folder. |
| design-docs.md | rule | Cut | GDD folder removed. |
| narrative.md | rule | Cut | Narrative folder removed. |
| shader-code.md | rule | Cut | No custom shaders on Roblox. |
| agent-memory.md | rule | Cut | Agent memory dir removed; state lives in `.rbx-studio/`. |

New rule: `rbx-shared-code.md` (`src/shared/**`: typed, side-effect free, no server-only services).

## Templates (`.claude/docs/templates`, 64 + 8 guidance)

| Item | Type | Decision | Roblox equivalent or reason |
|---|---|---|---|
| game-concept.md | template | Rewrite | → `concept-brief.md` (one page, discovery hypothesis, QPTR story). |
| game-brief.md | template | Merge | → `concept-brief.md`. |
| pitch-document.md | template | Merge | → `concept-brief.md`. |
| game-pillars.md | template | Merge | → `concept-brief.md` (3 pillars line). |
| game-design-document.md | template | Rewrite | → `gdd-short.md` (Roblox GDD, 1-2 pages). |
| technical-design-document.md | template | Merge | → `gdd-short.md` tech section + `remote-contract.md` + `data-schema.md`. |
| economy-model.md | template | Rewrite | → `monetization-sheet.md` (offers, price ladder, sinks/faucets, policy check). |
| difficulty-curve.md | template | Merge | → `gdd-short.md` progression section. |
| player-journey.md | template | Merge | → `first-60.md` (minute-one storyboard). |
| launch-checklist.md | template | Rewrite | → `launch-checklist.md` (Roblox). |
| release-checklist-template.md | template | Merge | → `launch-checklist.md` / `update-log.md`. |
| release-notes.md | template | Merge | → `update-log.md`. |
| patch-notes-brief.md | template | Merge | → `update-log.md`. |
| patch-notes-commentary.md | template | Cut | Dev commentary format; rare. |
| changelog-template.md | template | Merge | → `update-log.md`. |
| changelog-internal.md | template | Merge | → `handoff-note.md`. |
| session-state.md | template | Rewrite | → `checkpoint.md` (`/rbx-checkpoint`). |
| story.md | template | Rewrite | → `story.md` (lean: goal, acceptance, files, evidence). |
| bug-report.md | template | Rewrite | → `.github/ISSUE_TEMPLATE/bug.md` style issue body used by `/rbx-issues`. |
| prototype-report.md | template | Merge | → `playtest-report.md`. |
| vertical-slice-report.md | template | Merge | → `playtest-report.md`. |
| test-plan.md | template | Merge | → `playtest-report.md` (plan section). |
| test-evidence.md | template | Merge | → `playtest-report.md` (evidence table). |
| soak-test-protocol.md | template | Merge | → `/rbx-playtest --soak` steps. |
| art-bible.md | template | Rewrite | → `style-sheet.md` (one page, for `/rbx-art`). |
| incident-response.md | template | Merge | → `/rbx-update --hotfix` steps. |
| accessibility-requirements.md | template | Cut | Lives in `docs/roblox/ux-standards.md`. |
| hud-design.md | template | Cut | HUD rules in `ux-standards.md`. |
| ux-spec.md | template | Cut | Heavy; `story.md` carries UI acceptance. |
| interaction-pattern-library.md | template | Cut | Heavy. |
| post-mortem.md | template | Cut | Ceremony. |
| adoption-plan.md | template | Cut | Brownfield plan replaced by `conventions.md`. |
| adoption-summary.md | template | Cut | Same. |
| architecture-decision-record.md | template | Cut | One-line `decisions.md` instead. |
| architecture-doc-from-code.md | template | Cut | Same. |
| architecture-traceability.md | template | Cut | TR registry removed. |
| bug-closure-record.md | template | Cut | GitHub issue close covers it. |
| certification-console.md | template | Cut | Console cert not applicable. |
| certification-itch.md | template | Cut | itch.io. |
| certification-none.md | template | Cut | Engine-generic. |
| certification-steam.md | template | Cut | Steam. |
| certification-unknown.md | template | Cut | Engine-generic. |
| concept-doc-from-prototype.md | template | Cut | Covered by `concept-brief.md`. |
| design-doc-from-implementation.md | template | Cut | Covered by `/rbx-start` conventions pass. |
| faction-design.md | template | Cut | Lore. |
| level-design-document.md | template | Cut | Heavy. |
| milestone-definition.md | template | Cut | `/rbx-plan` writes the milestone inline. |
| narrative-character-sheet.md | template | Cut | Lore. |
| project-stage-report.md | template | Cut | `/rbx-pickup` output. |
| quick-design-change.md | template | Cut | Inline in story. |
| quick-design-new-system.md | template | Cut | Same. |
| quick-design-tuning.md | template | Cut | Same. |
| release-platform-requirements.md | template | Cut | Multi-platform store reqs. |
| risk-register-entry.md | template | Cut | RISKS line in reports. |
| sound-bible.md | template | Cut | Audio direction. |
| sprint-plan.md | template | Cut | `backlog.md` replaces sprints. |
| sprint-status.yaml | template | Cut | Same. |
| start-paths.md | template | Cut | `/rbx-start` is one path. |
| systems-index.md | template | Cut | Heavy. |
| help-escalation.md | template | Cut | Help merged into `/rbx-pickup`. |
| help-where-you-are.md | template | Cut | Same. |
| help-where-you-are-minimal.md | template | Cut | Same. |
| SKILL-CONTRACT-TEMPLATE.md | template | Rewrite | → maintainer `docs/skill-contract.md` (rbx skill shape). |
| guidance/*.md (8 files) | template | Cut | UX/GDD authoring guides tied to cut templates. |

New templates: `remote-contract.md`, `data-schema.md`, `discovery-plan.md`, `handoff-note.md`, `artist-brief.md`, `conventions.md` (seed), `project.yaml` (per-game config), `backlog.md`.

## Shared docs (`.claude/docs`)

| Item | Type | Decision | Roblox equivalent or reason |
|---|---|---|---|
| coding-standards.md | doc | Rewrite | → `studio/rbx-studio/docs/standards.md` (Luau + evidence rules). |
| run-and-observe.md | doc | Rewrite | → `look-check.md` (Studio MCP `start_stop_play` + `screen_capture`, phone + desktop). The rule is kept word for word in spirit: a story nobody looked at does not close. |
| workflow-modes.md | doc | Merge | → `rigor.md` (`minimal` / `standard` / `full` in one table). |
| automation-modes.md | doc | Merge | → `rigor.md` (studio is autonomous by default; asks only on expensive irreversible calls). |
| config-resolution.md | doc | Rewrite | → `config.md` (flat `.rbx-studio/project.yaml`, defaults, no resolver). |
| context-management.md | doc | Rewrite | → `survival.md` (checkpoint/resume protocol). |
| error-recovery-protocol.md | doc | Merge | → `survival.md`. |
| coordination-rules.md | doc | Rewrite | → `coordination.md` (who owns what, module locks for teams, nothing goes upstream). |
| directory-structure.md | doc | Rewrite | → `layout.md` (Rojo file layout + Studio DataModel layout). |
| agent-roster.md | doc | Rewrite | → README roster table. |
| skills-reference.md | doc | Rewrite | → README skill table. |
| hooks-reference.md + hooks-reference/*.md (6) | doc | Rewrite | → `docs/hooks.md`. |
| model-tiers.md | doc | Merge | → agent frontmatter `model:` + one line in `docs/install.md`. |
| director-gates.md + director-gates/*.md (28) | doc | Cut | Director review panels; replaced by `code-optimizer` close gate. |
| effects-map.md | doc | Cut | Huge config spec for knobs that no longer exist. |
| technical-preferences.md | doc | Cut | Engine prefs; `.rbx-studio/project.yaml` holds config. |
| settings-guidance.md | doc | Cut | Covered by `docs/install.md`. |
| settings-local-template.md | doc | Cut | Same. |
| CLAUDE-local-template.md | doc | Cut | Same. |
| setup-requirements.md | doc | Merge | → `docs/install.md`. |
| quick-start.md | doc | Merge | → README. |
| rules-reference.md | doc | Cut | Rules are self-describing. |
| code-root-resolution.md | doc | Cut | `.rbx-studio/project.yaml` names roots. |
| agent-teams.md | doc | Cut | Experimental feature, not needed. |
| workflow-catalog.yaml | doc | Cut | Phase pipeline removed. |

## Scripts (`.claude/scripts`, 37)

| Item | Type | Decision | Roblox equivalent or reason |
|---|---|---|---|
| skill-lint.sh | script | Rewrite | → `tools/studio-lint.js` (static checks for skills + agents + style). |
| agent-check.sh | script | Merge | → `tools/studio-lint.js` (agent observations). |
| test-run.sh | script | Rewrite | → `tools/test-hooks.sh` / `.ps1` (hook fixtures in both shells). |
| hook-input.sh | script | Cut | Replaced by dispatcher's own parsing. |
| adr-dep-graph.sh, adr-status.sh | script | Cut | ADRs removed. |
| artifact-check.sh, asset-scan.sh, bug-stats.sh, code-markers.sh, compat-inventory.sh, config-set.sh, content-count.sh, debt-register.sh, flaky-stats.sh, gdd-structure-check.sh, godot-parse-check.gd, inputs-check.sh, md-section.sh, migrate-v1-config.sh, plan-math.sh, project-coherence.sh, project-state.sh, read-guard.sh, registry.sh, review-receipts.sh, review-scope.sh, rotate-session-state.sh, session-state.sh, set-stage.sh, story-facts.sh, story-status.sh, test-scaffold.sh, write-guard.sh, yaml-get.awk | scripts (29) | Cut | Each serves a cut subsystem (ADRs, GDD registry, sprints, stage tracking, Godot parse, engine test scaffold, config resolver). |

New tools: `tools/dump-mcp-manifest.js` (Studio MCP tool list → doc), `install.ps1` / `install.sh` (install, update, uninstall), `tools/studio-lint.js`, `tools/test-hooks.*`.

## Top-level and other folders

| Item | Type | Decision | Roblox equivalent or reason |
|---|---|---|---|
| CLAUDE.md | config | Rewrite | Roblox-first, short. For maintainers of this repo; the per-game context is injected by the SessionStart hook. |
| README.md | doc | Rewrite | Fork README. |
| project.yaml | config | Rewrite | → template for `.rbx-studio/project.yaml` with a `roblox:` block, `modes.rigor: minimal`. |
| UPGRADING.md | doc | Rewrite | → updater instructions (`install.ps1 -Update`). Upstream history dropped. |
| CHANGELOG.md | doc | Rewrite | Fork changelog starting at 2.0.0-roblox; upstream log dropped (still in git history). |
| CONTRIBUTING.md, SECURITY.md | doc | Rewrite | Short versions for the fork. |
| LICENSE | doc | Keep | MIT, upstream copyright kept. |
| .claude/settings.json | config | Rewrite | Maintainer-only project settings (deny rules kept, skill-change hook). The game-side hooks ship in the global install. |
| .claude/statusline.sh | config | Cut | See hooks table. |
| studio-tests/ (catalog, rubric, 129 specs) | tests | Rewrite | Catalog + rubric + specs for the new 30 skills and 18 agents; engine specs cut. |
| docs/engine-reference/ (46 files) | doc | Cut | Godot/Unity/Unreal API snapshots. Replaced by `docs/roblox/`. |
| docs/COLLABORATIVE-DESIGN-PRINCIPLE.md | doc | Cut | Replaced by autonomous-with-log protocol (prompt §8). |
| docs/WORKFLOW-GUIDE.md, docs/skill-flow-diagrams.md | doc | Rewrite | → `docs/workflow.md` (one short flow). |
| docs/migration-guide-v1.1.md | doc | Cut | Upstream migration. |
| docs/CLAUDE.md, src/CLAUDE.md, design/CLAUDE.md | doc | Cut | Folder instructions for cut folders. |
| docs/architecture/, docs/registry/, design/registry/ | data | Cut | TR and entity registries. |
| production/ (session logs/state) | data | Cut | State moves to per-game `.rbx-studio/`. |
| .github/ISSUE_TEMPLATE, PULL_REQUEST_TEMPLATE | config | Rewrite | Fork issue/PR templates. |
| .github/FUNDING.yml, CODEOWNERS | config | Cut | Upstream owner's. |
| .gitignore, .gitattributes, .worktreeinclude | config | Rewrite | Drop engine patterns; add `.rbx-studio/state/`, Roblox lock files. |

## Notes for Phase 3

- Keep from original: `project.yaml` config idea, rigor modes, studio-tests + `/skill-test`, the "launch it and look at it" rule, deny-list safety rules, Windows toast hook, early-exit hook pattern (skip parsing when the payload cannot match).
- Biggest risks: hooks must be silent outside Roblox folders; push gate must be un-fakeable by the model (approval comes from the user's prompt via `UserPromptSubmit`, not from Claude); installer must never overwrite files it did not install.
