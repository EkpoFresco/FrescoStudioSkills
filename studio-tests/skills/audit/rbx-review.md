# Skill Spec: /rbx-review
Category: audit · Source: `studio/skills/rbx-review/SKILL.md`

## Summary
Project-specific code review delegated to code-optimizer against `.rbx-studio/conventions.md`. Scope: diff (default), branch, path, or all. Runs configured gates (StyLua, Selene, luau-lsp), fixes BLOCKER and MAJOR it safely can inside scope, appends learned patterns to conventions.md and debt to debt.md, saves `.rbx-studio/reports/review-<date>.md`.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: nothing changed` on empty scope
- [ ] Verdict list: APPROVED, APPROVED WITH NOTES, CHANGES REQUIRED, NOT ASSESSED
- [ ] Severities BLOCKER, MAJOR, MINOR, NIT
- [ ] Report uses DONE / YOU DO / RISKS / NEXT

## Fixture Defaults
Template project.yaml (rigor minimal, toolchain rojo for file cases), conventions.md present, git repo.

## Case 1: Happy path - diff with an unguarded remote
**Fixture**: `git diff` touches `src/server/Shop.server.luau`, which adds `Buy.OnServerEvent:Connect(function(player, id, n) give(player, id, n) end)`.
**Expected**: code-optimizer reviews the 1 file, flags the handler BLOCKER (no validation), adds a typeof/range/rate-limit guard, re-runs gates, verdict APPROVED WITH NOTES or CHANGES REQUIRED if it could not fix.
**Assertions**:
- [ ] File count stated ("1 files")
- [ ] The guard fix is inside the changed file only
- [ ] Report saved under `.rbx-studio/reports/review-<date>.md`

## Case 2: Relevance skip - clean tree
**Fixture**: no diff, no staged changes, no argument.
**Assertions**:
- [ ] Prints `SKIPPED: nothing changed` and writes nothing

## Case 3: Edge - no conventions.md
**Fixture**: `.rbx-studio/conventions.md` missing.
**Assertions**:
- [ ] Reviews against `code-quality.md` only and says so (or points to /rbx-start step 3)

## Protocol Compliance
- [ ] Never reformats beyond changed lines
- [ ] Local commit only for fixes; no push
- [ ] conventions.md gains dated Learned entries when patterns are found
