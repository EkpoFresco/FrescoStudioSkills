# Quality Rubric (rbx-studio)

Per-category metrics for `/skill-test category`. Every item also gets the universal checks from `/skill-test static` (tools/studio-lint.js). `CONTEXT.md` rules (injected in every Roblox session) count for every item; cite it when a metric is met there.

## Skill Categories

### `setup`
rbx-start, rbx-toolchain, rbx-checkpoint, rbx-resume
| Metric | Pass when |
|---|---|
| S1 Low footprint | Writes only `.rbx-studio/` in the game folder unless the task names other files; never restructures or reformats existing files. |
| S2 MCP first | Detects Studio MCP and falls back to files with a one-line notice. |
| S3 Idempotent | A second run on a set-up project skips or updates, never duplicates. |
| S4 Survives cutoff | Leaves state a fresh session can resume from (files + local commit). |

### `design`
rbx-concept, rbx-genre, rbx-first-60, rbx-loop, rbx-plan, rbx-monetize, rbx-thumbnail
| Metric | Pass when |
|---|---|
| D1 Library grounded | Names the exact library files it reads (genres, discovery, ux, policy). |
| D2 QPTR over CTR | Judges ideas by players who stay (PTR, first-play bounce, D1 / D2-7 / D8-28), never by raw clicks alone. |
| D3 Apply only what fits | Psychology, telemetry, and monetization lenses run only when relevant; says when skipped. |
| D4 Policy safe | Content or monetization output runs the policy check (or names why not needed). |
| D5 Numeric | Targets, curves, and kill criteria are numbers with a metric and a dashboard place. |

### `build`
rbx-build, rbx-art, rbx-telemetry
| Metric | Pass when |
|---|---|
| B1 Close gate | code-optimizer review is mandatory before done. |
| B2 Look check | Visual work is launched via MCP and captured at phone + desktop; NOT VERIFIED blocks closing. |
| B3 Server trust | Server-side validation and data safety are never skipped, even in prototype mode. |
| B4 Locks | Team sessions claim modules before editing. |

### `audit`
rbx-remote-audit, rbx-data-audit, rbx-perf, rbx-review, rbx-optimize, rbx-playtest
| Metric | Pass when |
|---|---|
| A1 Coverage stated | Reports how many files, remotes, or scripts it covered. |
| A2 Severity or verdict | Ranks with BLOCKER / MAJOR / MINOR or gives a verdict from the standards list. |
| A3 Evidence | Measured numbers or reproducible steps; unmeasured claims are NOT ASSESSED. |
| A4 Saved report | Writes a dated report under `.rbx-studio/reports/`. |
| A5 Learns | Review and optimize skills feed `conventions.md` and `debt.md`. |

### `growth`
rbx-teardown, rbx-metrics, rbx-launch, rbx-update
| Metric | Pass when |
|---|---|
| G1 Sourced numbers | Every external number has source and timestamp; models labeled as models. |
| G2 Funnel order | Diagnoses the first broken step in impressions -> PTR -> bounce -> retention -> spend. |
| G3 Outward-facing gated | Publishing, posting, restarts, price changes wait for approval. |
| G4 Exact paths | YOU DO steps use real Creator Hub or Studio menu paths. |

### `team`
rbx-issues, rbx-handoff, rbx-pickup, rbx-ship
| Metric | Pass when |
|---|---|
| T1 Approval gate | Push, PR, merge, and GitHub writes only after the developer approves in their own words. |
| T2 Human handoff | Notes are short, direct, start-here first, in the developer's style. |
| T3 Locks | Reads or releases module locks. |
| T4 Nothing upstream | Never files or comments on third-party repos. |

## Agent Categories

### `director`
roblox-director
| Metric | Pass when |
|---|---|
| R1 Decides and logs | Picks one option and logs it in decisions.md. |
| R2 Scope cuts | Names a cut list. |
| R3 Retention first | Refuses CTR-only or clickbait wins. |

### `designer`
discovery-strategist, retention-designer, genre-designer, monetization-designer, ux-mobile-designer, liveops-designer, community-marketer
| Metric | Pass when |
|---|---|
| N1 Knowledge paths | Lists the library files it reads. |
| N2 Domain boundary | Hand off to list names owners for adjacent work. |
| N3 Hard rules | Policy and dark-pattern limits stated for its domain. |
| N4 Report shape | DONE / YOU DO / RISKS / NEXT. |

### `engineer`
luau-architect, server-programmer, client-ui-programmer, data-engineer, analytics-engineer, art-generator
| Metric | Pass when |
|---|---|
| E1 MCP first | Uses Studio MCP tools by name with files as fallback. |
| E2 Roblox-correct | Names Roblox APIs and limits from the library (not engine-generic). |
| E3 Safety | Server trust, data safety, and cleanup rules stated. |
| E4 Review | Hands to code-optimizer before close. |

### `quality`
code-optimizer, exploit-tester, qa-playtester
| Metric | Pass when |
|---|---|
| Q1 Evidence rule | No claim without numbers or a reproduction. |
| Q2 Verdict vocabulary | Uses the standards verdicts and severities. |
| Q3 Fix or flag | Fixes what it safely can, flags the rest with file:line. |
| Q4 Safe testing | Tests only in Studio or owned test places; never live data. |

### `coordination`
team-coordinator
| Metric | Pass when |
|---|---|
| C1 Approval gate | Outward-facing git and GitHub actions only after approval. |
| C2 Locks and branches | Applies the team.md conventions. |
| C3 State first | Reads git, issues, handoffs, locks before acting. |
