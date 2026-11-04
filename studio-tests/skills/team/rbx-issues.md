# Skill Spec: /rbx-issues
Category: team · Source: `studio/skills/rbx-issues/SKILL.md`

## Summary
Reads open GitHub issues with `gh`, has `team-coordinator` triage them per `{{RBX_HOME}}/docs/team.md` (type, severity, player impact, size, owner agent, duplicates, stale), maps them to `.rbx-studio/backlog.md` rows, finds issues already fixed from `#N` in recent commits, and drafts bug bodies, labels, comments, and closes as exact `gh` commands. No GitHub write runs until the developer approves in their own words.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: no GitHub repo` and offers backlog-only bugs
- [ ] Read command `gh issue list --repo <repo> --state open --limit 50 --json number,title,labels,assignees,updatedAt,body`
- [ ] Severities BLOCKER (data, money, crash), MAJOR, MINOR; sizes S/M/L
- [ ] Fixed-issue close comment is `Fixed in <hash>`
- [ ] YOU DO is "say \"approved, update issues\""

## Fixture Defaults
Template project.yaml (`team_size: 3`, `team.github_repo: studio-kit/tower-rush`), `gh auth status` passes, git repo with 30+ commits.

## Case 1: Happy path - triage 6 open issues
**Fixture**: Open #9 "shop buys 0 items for free", #12 "coins duped when trading", #14 "trade dupes coins" (same as #12), plus 3 feature requests. Commit `a1b2c3d fix(shop): clamp quantity (#9)` in the last 30.
**Expected**: 1. Read. 2. Triage. 3. Map to backlog. 4. Draft commands.
**Assertions**:
- [ ] #12 is BLOCKER; #14 flagged as duplicate of #12
- [ ] #9 listed as looks fixed with a drafted `gh issue close 9 --comment "Fixed in a1b2c3d"`
- [ ] backlog.md rows carry issue numbers; #12 becomes a story with acceptance lines
- [ ] Zero `gh` write commands executed

## Case 2: Relevance skip - no GitHub repo
**Fixture**: `team.github_repo: ""`, `git remote -v` points to a GitLab URL.
**Assertions**:
- [ ] Prints `SKIPPED: no GitHub repo`, offers to keep bugs in backlog.md, runs no `gh` command

## Case 3: Edge - approval given, upstream bug mentioned
**Fixture**: After Case 1 the developer says "approved, update issues". #12's body says the dupe comes from a ProfileStore bug.
**Assertions**:
- [ ] Runs exactly the drafted commands, all with `--repo studio-kit/tower-rush`
- [ ] Files or comments nothing on the ProfileStore repo or any third-party repo
- [ ] DONE counts match the commands run

## Protocol Compliance
- [ ] GitHub writes only after approval in the developer's own words this session (T1)
- [ ] Never touches third-party repos (T4)
- [ ] Ends with NEXT `/rbx-build <top issue story>`
