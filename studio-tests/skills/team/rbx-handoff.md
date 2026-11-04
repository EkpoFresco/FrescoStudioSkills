# Skill Spec: /rbx-handoff
Category: team · Source: `studio/skills/rbx-handoff/SKILL.md`

## Summary
Writes a handoff note for a teammate or future self. Gathers commits since the last handoff (or last 15), status, branch, moved backlog rows, checkpoint, own lock rows, Studio-only edits, and latest review and playtest reports. Writes `<paths.handoffs>/YYYY-MM-DD-<initials>-<topic>.md` from `handoff-note.md`, releases locks for finished work, keeps WIP locks, and commits `docs(handoff): <topic>` locally.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: nothing new to hand off` with no commits, clean status, and no backlog movement
- [ ] Note leads with where it stands; "Start here" is numbered, smallest step first
- [ ] Studio-only changes (not in git) called out explicitly
- [ ] Locks: finished rows released, WIP rows kept and named in the note
- [ ] YOU DO is "say \"approved, push\"" (or send the file); push only via `/rbx-ship`

## Fixture Defaults
Template project.yaml (`team_size: 3`, `paths.handoffs: .rbx-studio/handoffs`), Studio MCP connected, git repo on `feat/shop`.

## Case 1: Happy path - hand the shop to Sam
**Fixture**: `/rbx-handoff to sam shop`; developer initials NS. 4 commits since the last handoff. locks.md rows by NS: `src/server/Shop` (S-06 done), `src/client/ShopUI` (S-07 doing). Checkpoint lists Studio-only edit `Workspace.ShopStall`.
**Expected**: 1. Gather. 2. Write the note. 3. Release S-06 lock, keep S-07. 4. Local commit.
**Assertions**:
- [ ] Writes `.rbx-studio/handoffs/2026-11-04-ns-shop.md`
- [ ] One line per change with its path; `Workspace.ShopStall` flagged as Studio-only
- [ ] `src/server/Shop` row removed; `src/client/ShopUI` row kept and noted as in progress
- [ ] DONE shows "locks released: 1"; commit `docs(handoff): shop`; no push

## Case 2: Relevance skip - nothing new
**Fixture**: Last handoff file at HEAD time; no new commits, clean status, backlog unchanged.
**Assertions**:
- [ ] Prints `SKIPPED: nothing new to hand off` and writes nothing

## Case 3: Edge - first handoff, no checkpoint
**Fixture**: `.rbx-studio/handoffs/` empty; no checkpoint.md; 40 commits on the branch.
**Assertions**:
- [ ] Uses the last 15 commits, not all 40
- [ ] Note still has "Start here" and only real risks
- [ ] Skips Studio-only section without inventing edits

## Protocol Compliance
- [ ] Short, direct, start-here first, in the developer's style (T2)
- [ ] Releases own lock rows only (T3); never pushes
- [ ] Ends with NEXT "teammate runs /rbx-pickup"
