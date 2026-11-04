# Skill Spec: /rbx-pickup
Category: team · Source: `studio/skills/rbx-pickup/SKILL.md`

## Summary
Read-only state summary. Reads `{{RBX_HOME}}/docs/team.md`, the newest 2 handoffs, checkpoint, backlog, locks, `git fetch --quiet` plus 7 days of log and branch vs main, open GitHub issues, and with `--deep` the latest review, playtest, perf, and metrics reports. Prints the state in five lines max, flags conflicts, and names the single highest-leverage next move with its skill. Writes no files.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: not set up` and recommends `/rbx-start`; unfinished in-progress checkpoint recommends `/rbx-resume` first
- [ ] Read order cheap first; `git fetch --quiet` is the only network git call
- [ ] `git rev-list --left-right --count <main>...HEAD` for branch vs main; `gh issue list --limit 15` when GitHub is set up
- [ ] Conflicts: two locks on one module, stale locks (> 24 h), branch far behind main, Studio-only handoff edits
- [ ] allowed-tools has no Write or Edit

## Fixture Defaults
Template project.yaml (`team_size: 3`, `team.github_repo: studio-kit/tower-rush`), `gh` authed, git repo on `feat/quests`, no Studio MCP needed.

## Case 1: Happy path - start of a session
**Fixture**: Handoffs `2026-11-03-sb-trade.md` ("start with S-12 trade validation") and `2026-11-02-ns-shop.md`; locks.md row `src/server/Trade | sb | 2026-11-04 08:30`; open issue #12 BLOCKER "coins duped when trading".
**Expected**: 1. Read. 2. Summarize. 3. Check conflicts.
**Assertions**:
- [ ] State is 5 lines or fewer and names #12 as an open BLOCKER and sb's Trade lock
- [ ] One next move with its skill (e.g. `/rbx-build S-12`)
- [ ] No file written or edited

## Case 2: Relevance skip - not set up
**Fixture**: No `.rbx-studio/` folder.
**Assertions**:
- [ ] Prints `SKIPPED: not set up`, recommends `/rbx-start`, writes nothing

## Case 3: Edge - stale and double locks, branch behind
**Fixture**: locks.md has `src/server/Economy | alex | 2026-11-02 09:00` and `src/server/Economy | ns | 2026-11-04 07:45`; `feat/quests` is 23 commits behind main.
**Assertions**:
- [ ] RISKS flags the double lock on `src/server/Economy`, alex's stale lock (> 24 h), and the 23-commit gap
- [ ] Does not edit locks.md or pull, merge, or rebase
- [ ] NEXT names a skill and target

## Protocol Compliance
- [ ] Read-only: writes nothing, no push (T1)
- [ ] Reads locks and reports conflicts (T3)
- [ ] Ends with NEXT `<skill + target>`
