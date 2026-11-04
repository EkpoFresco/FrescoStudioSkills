# Skill Spec: /rbx-build
Category: build · Source: `studio/skills/rbx-build/SKILL.md`

## Summary
Implements one story or feature. Loads the story (writes 2-4 acceptance lines if missing), reads conventions.md, project.yaml, and locks.md, claims modules when `team_size > 1`, plans 5-10 lines, briefs agents by type (server-programmer, client-ui-programmer, data-engineer, art-generator), runs it via Studio MCP, then closes through the never-skipped gate: `code-optimizer` review, look check for visual stories, rigor extras, evidence, status `done`, lock release, local commit.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: pick a story` (with top 3 `todo` rows) and `SKIPPED: S-NN is done`
- [ ] Close gate: review verdict must not be `CHANGES REQUIRED`; look check `NOT VERIFIED` blocks the close
- [ ] `--prototype` skips types and tests but keeps server validation and data safety, and marks the story `prototype`
- [ ] Run loop max 3 rounds, then report
- [ ] Commit `type(scope): summary (S-NN)`; report uses DONE / YOU DO / RISKS / NEXT

## Fixture Defaults
Template project.yaml (`rigor: minimal`, `toolchain: mcp`, `team_size: 1`), conventions.md and backlog.md present, Studio MCP connected, git repo with one commit.

## Case 1: Happy path - daily reward story
**Fixture**: Backlog row S-03 "Daily reward" `todo`, acceptance: button in `StarterGui.HUD`; `ReplicatedStorage.Remotes.ClaimDaily` grants 100 coins once per 24 h; toast shows "+100".
**Expected**: 1. Status `doing`. 2. Plan. 3. server-programmer and client-ui-programmer in parallel. 4. `start_stop_play`, `get_console_output`, exercise, stop. 5. code-optimizer, look check, evidence, `done`, commit.
**Assertions**:
- [ ] `ClaimDaily` handler checks the cooldown from the server profile, never a client-sent time
- [ ] DONE shows "review <VERDICT>, Run result OBSERVED"; verdict is not CHANGES REQUIRED
- [ ] Phone and desktop captures under `.rbx-studio/evidence/S-03/`
- [ ] Local commit like `feat(daily): add daily reward (S-03)`; no push

## Case 2: Relevance skip - story already done
**Fixture**: `/rbx-build S-02`; backlog row S-02 status `done`.
**Assertions**:
- [ ] Prints `SKIPPED: S-02 is done` and writes nothing

## Case 3: Edge - team_size 3 and a held lock
**Fixture**: `team_size: 3`; locks.md row `src/server/Economy | alex | 2026-11-03 09:12`; S-05 touches `src/server/Economy/Wallet.luau`.
**Assertions**:
- [ ] Stops before editing and reports the module and its owner (alex)
- [ ] S-05 status is not set to `doing`; no file under `src/` changes
- [ ] Claims nothing in locks.md over alex's row

## Protocol Compliance
- [ ] Server validation and data safety never skipped, even with `--prototype` (B3)
- [ ] Writes only `.rbx-studio/` plus the game code the story names; never pushes
- [ ] Ends with NEXT `/rbx-build <next story>`
