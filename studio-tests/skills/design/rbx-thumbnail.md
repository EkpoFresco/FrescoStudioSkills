# Skill Spec: /rbx-thumbnail
Category: design · Source: `studio/skills/rbx-thumbnail/SKILL.md`

## Summary
Writes the icon and thumbnail brief and a thumbnail personalization plan judged by PTR and first-play bounce. `discovery-strategist` writes `.rbx-studio/reports/thumbnails.md`: the first-60 moment each image promises, 3-5 one-variable concepts, an icon readable at 50x50 px, video beats. `make` has `art-generator` stage placeholders in Studio and capture them to `.rbx-studio/evidence/thumbnails/`. Uploading is the developer's step.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: nothing to promise yet, run /rbx-concept`
- [ ] Names `discovery-algorithm.md`, `discovery-playbook.md`, and `.rbx-studio/reports/first-60.md`
- [ ] States there is no icon A/B tool; icon tests are sequential swaps
- [ ] Personalization set of 2-5, held at least 7 days, judged by PTR and bounce for RFY traffic
- [ ] Analytics column names tagged UNVERIFIED (OPEN_QUESTIONS #3)

## Fixture Defaults
Template project.yaml (`genre: horror`), concept brief and first-60.md in `.rbx-studio/reports/`, Studio MCP connected.

## Case 1: Happy path - brief and plan
**Fixture**: first-60.md shows a flashlight reveal of the monster at 20 s and a locked door goal at 30 s.
**Expected**: 1. Read context. 2. Brief. 3. Test plan. 4. No `make`.
**Assertions**:
- [ ] Every concept promises a moment that happens in the first 60 s (flashlight reveal, locked door)
- [ ] 3-5 concepts, each varying exactly one thing (subject, action, color, text-free vs one word)
- [ ] Plan judges by PTR and first-play bounce, not CTR alone
- [ ] YOU DO uses Creator Hub > Creations > <game> > Places/Experience > Thumbnails

## Case 2: Relevance skip - nothing to promise
**Fixture**: No concept brief; no scripts in Studio or `src/`.
**Assertions**:
- [ ] Prints `SKIPPED: nothing to promise yet, run /rbx-concept` and writes nothing

## Case 3: Edge - make without Studio MCP
**Fixture**: `/rbx-thumbnail make`; MCP tools missing.
**Assertions**:
- [ ] Says once that MCP is missing; still writes the brief and plan
- [ ] Claims no placeholder captures; DONE placeholders line says not made
- [ ] No file appears under `.rbx-studio/evidence/thumbnails/`

## Protocol Compliance
- [ ] Writes only `.rbx-studio/reports/` and `.rbx-studio/evidence/thumbnails/`
- [ ] Never uploads thumbnails or turns on personalization itself
- [ ] Ends with NEXT `/rbx-launch`
