# Skill Spec: /rbx-optimize
Category: audit · Source: `studio/skills/rbx-optimize/SKILL.md`

## Summary
Fixes the highest-impact performance, memory, and network issues one change at a time. Scores candidates (impact x risk / effort), takes the top `--max` (default 3), and for each: baseline with an accepted method from `standards.md`, one change, identical re-measure, verify (tests, MCP play run, clean console), keep only if improved, local commit. Updates `debt.md`, appends to `conventions.md`, writes `.rbx-studio/reports/optimize-<date>.md`.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] With no debt, no perf report, and no target: seeds `debt.md` from the `/rbx-perf` step 3 scan; nothing found prints `SKIPPED: no measurable debt`
- [ ] Score formula impact x risk / effort, each 1-5; default `--max` 3
- [ ] Table header `| Target | Metric | Before | After | Method | N | Kept |`
- [ ] Commit `perf(<scope>): <what> (<before> -> <after>)`
- [ ] "No number, no claim"; never refactor and optimize in one commit

## Fixture Defaults
Template project.yaml (`rigor: minimal`, `toolchain: rojo`), conventions.md present, Studio MCP connected, Lune installed, git repo with one commit.

## Case 1: Happy path - two debt items
**Fixture**: `debt.md` has D-02 `src/client/NameTags.client.luau:18` calls `GetChildren` inside `RenderStepped`, and D-05 `src/server/Combat/Hits.luau` keeps a per-player table never cleared on `PlayerRemoving`. Run `/rbx-optimize top --max 2`.
**Expected**: For each: baseline, change, re-measure, play run, keep, commit.
**Assertions**:
- [ ] D-05 (per-player leak) is taken first or scored above cosmetic items
- [ ] Each row has before, after, method (MicroProfiler label ms, memory MB over 5 min), and N
- [ ] One `perf(...)` commit per kept change; debt.md statuses updated
- [ ] conventions.md gains a dated learned pattern

## Case 2: Relevance skip - no measurable debt
**Fixture**: No `debt.md` items, no `perf-*.md` report, no target; static scan finds no hazards.
**Assertions**:
- [ ] Prints `SKIPPED: no measurable debt` and changes no code

## Case 3: Edge - change does not help
**Fixture**: `/rbx-optimize src/shared/Pathing.luau`; Lune benchmark median of 5 runs: before 4.1 ms, after caching 4.3 ms.
**Assertions**:
- [ ] Change reverted and reason recorded; row shows Kept = no
- [ ] No `perf(...)` commit for it
- [ ] Gameplay feel untouched without a playtest

## Protocol Compliance
- [ ] Before/after numbers with identical setup for every claim (A3)
- [ ] Feeds `debt.md` and `conventions.md` (A5); local commits only, no push
- [ ] Ends with a NEXT line
