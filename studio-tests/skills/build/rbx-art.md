# Skill Spec: /rbx-art
Category: build · Source: `studio/skills/rbx-art/SKILL.md`

## Summary
Makes or improves art through Studio MCP generation tools, keeps one style sheet (`.rbx-studio/reports/style-sheet.md`), audits mobile asset budgets, and runs the art look check at phone and desktop framings with evidence in `.rbx-studio/evidence/art/`. After a second FAIL on an asset, or when the developer flags it, writes `.rbx-studio/reports/artist-brief-<asset>.md` and stops iterating.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check: without Studio MCP, `make`/`improve` do not run; `style` or `audit` run from files and the skill says so
- [ ] Names `art-pipeline.md`, `studio-mcp-tools.md`, `{{RBX_HOME}}/docs/look-check.md`
- [ ] Budgets: props <= 1K tris, hero <= 10K, textures <= 512, minor <= 256
- [ ] Phone framing at 844x390 plus desktop; evidence via `{{RBX_HOME}}/tools/capture-studio.ps1`
- [ ] Generation uses `async: true`; `wait_job_finished` only when the next step needs the result

## Fixture Defaults
Template project.yaml (`rigor: minimal`, `toolchain: mcp`), style-sheet.md present (low-poly, warm palette), Studio MCP connected.

## Case 1: Happy path - make a prop and a hero
**Fixture**: `/rbx-art make "wooden crate prop and dragon statue hero"`, target parent `Workspace.Lobby`.
**Expected**: 1. Read context. 2. art-generator generates both. 3. Look check each. 4. Report attempts.
**Assertions**:
- [ ] Crate reports tris <= 1K and texture <= 256 or 512; statue tris <= 10K
- [ ] PASS or FAIL per asset with reason and evidence path under `.rbx-studio/evidence/art/`
- [ ] Attempts per asset tracked in the report
- [ ] Assets land under `Workspace.Lobby` only

## Case 2: Relevance skip - make without Studio MCP
**Fixture**: MCP tools missing; `/rbx-art make "lobby lamp"`.
**Assertions**:
- [ ] Says `make` cannot run without Studio MCP; no generation call attempted
- [ ] Offers or runs `style` or `audit` from files; claims no look check result

## Case 3: Edge - developer flags an asset
**Fixture**: Developer says "the fountain looks rly bad, we gotta work on it" about `Workspace.Lobby.Fountain`.
**Assertions**:
- [ ] Skips straight to step 5; no regeneration attempt
- [ ] Writes `.rbx-studio/reports/artist-brief-fountain.md` from `artist-brief.md` in the developer's style
- [ ] DONE lists the artist brief path

## Protocol Compliance
- [ ] Visual work not done until captured at phone and desktop; NOT VERIFIED blocks closing (B2)
- [ ] Writes only `.rbx-studio/` plus the DataModel assets the task names
- [ ] Ends with a NEXT line
