# Skill Spec: /<name>
Category: <setup | design | build | audit | growth | team> · Source: `studio/skills/<name>/SKILL.md`

## Summary
One paragraph: what it does, inputs, outputs, where it writes.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] `## 0. Relevance check` prints `SKIPPED: <reason>` for <the skip case>
- [ ] Report uses DONE / YOU DO / RISKS / NEXT
- [ ] <one skill-specific structural fact, e.g. names `{{RBX_HOME}}/library/roblox/<file>`>

## Fixture Defaults
`.rbx-studio/project.yaml` from the template (`modes.rigor: minimal`, `toolchain: mcp`, `team_size: 1`), Studio MCP connected, git repo with one commit, unless a case says otherwise.

## Case 1: Happy path - <name>
**Fixture**: <state>
**Expected**: <numbered behavior>
**Assertions**:
- [ ] <observable outcome>

## Case 2: Relevance skip - <name>
**Fixture**: <state where the skill does not apply>
**Assertions**:
- [ ] Prints `SKIPPED:` with the reason and stops without writing files

## Case 3: Edge - <name>
**Fixture**: <no MCP, team_size 3, missing file, etc.>
**Assertions**:
- [ ] <behavior>

## Protocol Compliance
- [ ] Writes only inside `.rbx-studio/` (plus game code the task names)
- [ ] No push, PR, issue write, or publish without the developer's approval
- [ ] Ends with a NEXT line naming a skill or action
