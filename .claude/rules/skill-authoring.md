---
paths:
  - "studio/skills/**"
  - "studio/agents/**"
  - "studio/rules/**"
---
# Authoring rbx-studio skills and agents (maintainers)

Skill shape (lint-enforced by `tools/studio-lint.js`):
- Frontmatter: `name` (= folder, `rbx-` prefix), `description` starting "Roblox:" with trigger phrases, `argument-hint`, `user-invocable: true`, minimal `allowed-tools`.
- `## 0. Relevance check`: one line; prints `SKIPPED: <reason>` and stops when the skill does not apply. Nothing runs by default just because it exists.
- `## 1.` .. `## N.` numbered phases, each with a concrete output.
- `## Report` with exactly DONE / YOU DO / RISKS (only if real) / NEXT.
- Under 300 lines. Long reference material belongs in `docs/roblox/` (installed as the library), not in the skill.

Agent shape: frontmatter `name`, `description` starting "Roblox", `model: inherit`, `maxTurns`; omit `tools` when the agent needs Studio MCP (MCP tool names vary by user config). Sections: Knowledge (exact library paths), How you work, Hard rules, Hand off to, Report. Agents cannot ask questions mid-task: open questions go at the end of the report.

Paths: write `{{RBX_HOME}}/library/roblox/<file>` for research and `{{RBX_HOME}}/<docs|templates|tools>/...` for studio files. The installer replaces `{{RBX_HOME}}` with the absolute path. Never write `~`.

Voice (the developer's): lead with the result, short sentences, plain words, numbers and paths, no em dashes, no filler, no recap. Make the call and log it; ask only when a wrong guess is expensive and hard to reverse, one question with options.

Safety: local commits fine; push, PR, merge to main, issue writes, publishing, and live data writes need the developer's approval in their own words.

After editing: `node tools/studio-lint.js <name>`, then add or update its spec in `studio-tests/`.
