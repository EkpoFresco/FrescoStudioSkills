# Skill Spec: /rbx-playtest
Category: audit · Source: `studio/skills/rbx-playtest/SKILL.md`

## Summary
Plays the game through Studio MCP. Plans 5-10 steps from story acceptance lines (`--smoke`: 3-5 critical-path steps), has `qa-playtester` drive them per `look-check.md`, confirm effects on the Server datamodel with `execute_luau`, and capture desktop and landscape phone. `ux-mobile-designer` judges captures against the `ux-standards.md` rubric. `--soak` samples memory every minute for 10+ minutes. Writes `.rbx-studio/reports/playtest-<date>-<slug>.md` with PASS, CONCERNS, or FAIL.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: nothing to play`; no MCP runs Lune tests, marks the visual half NOT VERIFIED, writes the report, stops
- [ ] Each plan step has input, expected result, and how to confirm
- [ ] Evidence under `.rbx-studio/evidence/playtest-<date>/`; report from `playtest-report.md`
- [ ] `--soak`: steady climb over 5 samples is a leak finding for `code-optimizer`
- [ ] DONE has `Run result: OBSERVED - <what> - <evidence dir>` and verdict PASS | CONCERNS | FAIL

## Fixture Defaults
Template project.yaml (`rigor: minimal`, `toolchain: mcp`, `target_devices: [phone, desktop]`), Studio MCP connected, git repo with one commit.

## Case 1: Happy path - daily reward story
**Fixture**: `/rbx-playtest S-03`; S-03 done with acceptance: claim grants 100 coins, second claim in 24 h rejected, toast shows. On phone the toast covers the jump button.
**Expected**: 1. Plan 5 steps. 2. Run and capture. 3. Judge. 4. Save.
**Assertions**:
- [ ] Coin grant confirmed by reading the player's coins on the Server datamodel, not only the toast
- [ ] Toast overlap logged as a bug with severity and repro steps (device, step, screenshot path)
- [ ] Verdict CONCERNS or FAIL, not PASS
- [ ] NEXT `/rbx-build <worst bug>`

## Case 2: Relevance skip - nothing to play
**Fixture**: Empty place; no scripts in Studio or `src/`.
**Assertions**:
- [ ] Prints `SKIPPED: nothing to play` and writes nothing

## Case 3: Edge - soak finds a leak
**Fixture**: `/rbx-playtest --soak`; Lua heap per minute: 210, 214, 219, 225, 231, 238 MB.
**Assertions**:
- [ ] Runs at least 10 minutes with one sample per minute (`collectgarbage("count")`, instance count, memory)
- [ ] Steady climb reported as a leak finding handed to `code-optimizer`
- [ ] Verdict is not PASS

## Protocol Compliance
- [ ] Tests only in Studio play sessions; never publishes
- [ ] Writes only `.rbx-studio/reports/` and `.rbx-studio/evidence/`
- [ ] Ends with NEXT `/rbx-build <worst bug>`
