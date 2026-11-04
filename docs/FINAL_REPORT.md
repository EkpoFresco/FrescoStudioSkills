# Final report: rbx-studio 2.0.0

Run: 2026-11-03 to 2026-11-04. Fork of Claude Code Game Studios v1.2.0, all commits local, nothing pushed.

```
DONE
- studio/: 18 agents, 28 rbx-* skills, 7 path rules, CONTEXT.md, 7 support docs, 17 templates, 3 tools
- hooks: studio/rbx-studio/hooks/rbx-hook.sh + rbx-hook.ps1 (7 events, silent outside Roblox folders)
- install.ps1 / install.sh: install, -Update, -Uninstall, -Target sandbox; docs/install.md
- docs/roblox/: 45 research files (11 topics + MCP manifest + 32 genres + index + OPEN_QUESTIONS), sourced and dated
- docs/audit/: REPO_AUDIT.md, ROBLOX_STUDIO_DESIGN.md, FRICTION.md (21 items); DECISIONS.md (D-001..D-019)
- studio-tests/: 46 specs (28 skills, 18 agents), rubric, catalog; .claude/skills: /skill-test, /skill-improve
- tools/: studio-lint.js, gen-catalog.js, test-hooks.sh, test-install.ps1, dump-mcp-manifest.js
- dogfood/brainrot-miner/: playable idle mining clicker, driven through 17 fresh headless sessions with Studio MCP
- installed globally at ~/.claude (uninstall: .\install.ps1 -Uninstall)

YOU DO
1. Fix your Claude Code CLI (its 2.1.318 auto-update failed, so new sessions cannot start):
   cd "$env:APPDATA\npm\node_modules\@anthropic-ai\claude-code"; node install.cjs
   (or: npm i -g @anthropic-ai/claude-code)
2. Connect Studio MCP once: claude mcp add --scope user roblox-studio -- "%LOCALAPPDATA%\Roblox\mcp.bat"
3. Restart Claude Code in your real game folder and run /rbx-start
4. When happy: add your own remote and say "approved, push" (upstream push is disabled on purpose)

RISKS
- Research search budget ran out mid-run; ~170 facts are tagged UNVERIFIED (docs/roblox/OPEN_QUESTIONS.md, top 10 first)
- Dogfood skills ran on Sonnet in headless mode; agent prompts were exercised less than skill prompts (F-20)
- Dogfood Studio place is unsaved and partly out of sync with src/ (expected for a test place)

NEXT
- /rbx-start then /rbx-review all on your real game
```

## Verification
| Check | Result |
|---|---|
| Static lint (`node tools/studio-lint.js all`, = `/skill-test static all`) | 79/79 COMPLIANT (28 skills, 18 agents, 33 rules/docs/templates) |
| Spec coverage (`node tools/gen-catalog.js --check`, = `/skill-test audit`) | 28/28 skills, 18/18 agents have specs; 0 problems |
| Hooks (`bash tools/test-hooks.sh both`) | 50/50: 25 Git Bash + 25 PowerShell 7; also 25/25 on Windows PowerShell 5.1 |
| Installer round trip (`tools/test-install.ps1`) | 13/13 on pwsh 7 and PS 5.1; `install.sh` leaves 0 entries after uninstall |
| Real global install, fresh headless session in game folder | rbx SessionStart context fired; 28 skills, 18 agents, Studio MCP connected (33 tools) |
| Non-Roblox folder | 0 rbx-studio output, nothing written |
| Footprint (clean game repo + `/rbx-start`) | only `.rbx-studio/` added and committed; 11 original files byte-identical |
| Uninstall of the real install | `settings.json` byte-identical to pre-install; agents/, rules/, rbx-* skills removed; your skills untouched |
| Survival (killed `/rbx-optimize` at 403 s, fresh `/rbx-resume`) | found the half-done edit, finished it, tests 18/18, committed |
| Team (`/rbx-handoff`, fresh `/rbx-pickup`) | handoff note written; pickup reported state, risks, next move (stale-checkpoint read fixed, F-21) |

## Dogfood: Snorbo's Brain Rock Mine
Original placeholder game (no real meme characters). 17 fresh sessions, $6.54 total on Sonnet, 131 Studio MCP calls (59 execute_luau, 14 start_stop_play, 8 screen_capture, 2 generate_mesh).

| Step | Outcome |
|---|---|
| /rbx-start | hybrid project detected via MCP + files; conventions.md with file:line Keep / Phase out |
| /rbx-concept | GO with cut list; kill criteria |
| /rbx-loop | Lune curve sim: rebirth at 30:52, 5 curve gaps flagged |
| /rbx-first-60 | storyboard, 8 ranked bounce risks |
| /rbx-build | Rebirth hidden until payable, rock cue; synced to Studio via multi_edit; verified in play |
| /rbx-art | purple brain rock + Snorbo mascot via generate_mesh; look check; artist brief for the rock |
| /rbx-playtest | CONCERNS: 5 bugs incl. upgrade list sorted by name (key upgrade off-screen on phone); evidence PNGs |
| /rbx-review | 2 BLOCKERs fixed (lock leak on leave-during-load; cancelled save counted as success), 5 MAJOR fixed, +8 conventions |
| /rbx-optimize | measured, see table |
| /rbx-remote-audit | 4 remotes, ~30 attacks PROVEN in play: 0 BLOCKER; 1000 Mine calls credited 21 |
| /rbx-data-audit | AT RISK: receipt retry path can lose a paid purchase (MAJOR), 3 more MAJOR |
| /rbx-monetize | 3 offers + 1 deferred, policy check PASS |
| /rbx-telemetry | 8 events for 4 questions, within AnalyticsService limits |

| Target | Metric | Before | After | Method |
|---|---|---|---|---|
| State push (TD-001) | State packets/s, idle player | 9 | 0 | Studio MCP client count, 3 x 10 s |
| State push (TD-001) | State packets/s, earning player | 9 | ~1 | same |
| Economy.bulkCost | ms per 20,000 calls (owned 200, count 100) | 70.33 | 8.59 | Lune, median of 5 |
| Rock tap tweens (TD-007) | ms per 2,000 taps | 17.45 | 1.71 | Client execute_luau, median of 5 |

## Counts
| | Before | After |
|---|---|---|
| Agents | 49 | 18 |
| Skills | 74 | 28 rbx-* (+2 maintainer, repo only) |
| Hooks | 15 registered + 3 helpers (5,219 lines) | 7 events, 1 dispatcher per shell |
| Rules | 14 | 7 (+1 maintainer) |
| Templates | 72 | 17 |

## What was cut and why
Agents (17 cut outright; 28 merged into the new 18, mapping in REPO_AUDIT.md):
- godot-specialist, godot-gdscript-specialist, godot-csharp-specialist, godot-shader-specialist, godot-gdextension-specialist: Godot only.
- unity-specialist, unity-ui-specialist, unity-shader-specialist, unity-dots-specialist, unity-addressables-specialist: Unity only.
- unreal-specialist, ue-blueprint-specialist, ue-gas-specialist, ue-replication-specialist, ue-umg-specialist: Unreal only.
- engine-programmer: no engine code on Roblox; perf parts went to code-optimizer.
- world-builder: lore depth is not a Roblox bottleneck; genre-designer covers story genres.

Skills (17 cut outright; 50 merged into rbx-* skills):
- gate-check: 1,371-line phase gate; replaced by the story close gate and /rbx-launch GO/NO-GO.
- design-review, review-all-gdds, consistency-check, content-audit, propagate-design-change: GDD-corpus process a small team does not run.
- architecture-review: TR traceability matrix; decisions are one line in decisions.md now.
- team-combat, team-narrative, team-audio, team-level: orchestration ceremony; skills call agents directly.
- regression-suite, test-helpers, test-evidence-review, test-flakiness: engine or CI-scale test plumbing; /rbx-playtest and the close gate cover it.
- localize: Roblox auto-translates; a launch checklist line covers the rest.
- retrospective: ceremony; /rbx-handoff captures what changed.

## Try these 3 first on your real game
1. `/rbx-start`: builds `.rbx-studio/conventions.md` from your code (Keep and Phase out with file:line). Everything else gets sharper after it.
2. `/rbx-review all`: on the dogfood it found 2 real data-loss BLOCKERs in code that looked fine. Run it before your next update.
3. `/rbx-remote-audit all`: attacks every remote in a play session and proves what an exploiter can do. Cheap insurance on a live game with money or items.
