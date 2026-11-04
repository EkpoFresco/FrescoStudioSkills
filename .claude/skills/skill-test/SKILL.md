---
name: skill-test
description: "Maintainer tool for this repo: validate the rbx-studio skills and agents. Modes: static (runs tools/studio-lint.js), spec (evaluates a behavioral spec in studio-tests/), category (rubric), audit (coverage report). Use after editing anything in studio/."
argument-hint: "static [name | all] | spec <name> | category <name | all> | audit"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash(node tools/studio-lint.js*)
---

# /skill-test

Tests the studio itself (`studio/skills/rbx-*/SKILL.md`, `studio/agents/*.md`), not a game. What a pass proves: `static` = the file has the structure every rbx skill needs; `spec` = read closely, the instructions cover each case; `category` = it meets its category rubric; `audit` = which items have specs and when each was last checked. Only a real run shows behavior (Phase 5 dogfood).

## 1. Parse arguments
`static [name|all]`, `spec <name>`, `category <name|all>`, `audit` (default). Resolve a name against `studio-tests/catalog.yaml` (`skills:` or `agents:`); with no entry, use whichever of `studio/skills/<name>/SKILL.md` or `studio/agents/<name>.md` exists; neither: say so and stop.

## 2. Static
Run `node tools/studio-lint.js <name|all>` and show its table. The linter's checks (do not re-implement them by eye):
1. Frontmatter: skills need `name` (= folder, `rbx-` prefix), `description` (starts "Roblox"), `argument-hint`, `user-invocable`, `allowed-tools`; agents need `name` (= file), `description` (starts "Roblox"), `model`.
2. Skills: `## 0. Relevance check` that can print `SKIPPED`; at least 2 numbered phases; under 300 lines.
3. Report shape: a `## Report` section containing DONE, YOU DO, NEXT (the developer's report format).
4. Assessment skills carry verdict or severity words (PASS/FAIL, APPROVED/CHANGES REQUIRED/NOT ASSESSED, BLOCKER/MAJOR/MINOR, GO/NO-GO, SAFE/AT RISK).
5. Write scope (replaces upstream "May I write"): a skill that can Write or Edit names its `.rbx-studio/` write location; anything that pushes, opens PRs, or writes GitHub issues references the approval gate. The studio is autonomous by design; approval is required only for outward-facing actions.
6. Agents: Knowledge, Hard rules, Hand off to sections; the style block ("No em dashes").
7. Everywhere: no em dashes, no references to other engines, every `{{RBX_HOME}}/...` path resolves in this repo.
Verdicts per file: COMPLIANT, WARNINGS, NON-COMPLIANT; state the denominator the linter prints. No file writes in static mode.

## 3. Spec
Read the item and its spec (path from catalog `spec:`), plus `studio/rbx-studio/CONTEXT.md` (injected into every Roblox session, so its rules count for every skill and agent; cite it). For each Static Assertion, each case assertion, and each Protocol Compliance line: PASS, PARTIAL, FAIL, or NOT ASSESSED (cannot be evaluated: undefined fixture, runtime-only behavior, missing file). Case verdict = worst assertion; overall = worst of all, ranked FAIL > PARTIAL > NOT ASSESSED > PASS. Output:
```
=== Spec Test: <name> === Date: <date>
Static: [PASS] ...
Case 1 (<name>): [PASS] ... -> Case PASS
Protocol: [PASS] ...
Overall: <verdict>
```
Write results to `studio-tests/results/spec-<name>-<date>.md` and update `last_spec` / `last_spec_result` in the catalog (maintainer tool: writes are expected; no approval prompt).

## 4. Category
Read the item's `category:` from the catalog and the matching section of `studio-tests/quality-rubric.md` (agents: `## Agent Categories`). Mark each metric PASS, FAIL, WARN, or NOT ASSESSED with the gap quoted. Category verdict: FAIL if any fail, else WARNINGS, else NOT ASSESSED, else PASS. Record `last_category` / `last_category_result`. `category all` lists any skill or agent missing from the catalog as NOT ASSESSED.

## 5. Audit
Glob `studio/skills/*/SKILL.md` and `studio/agents/*.md` (the repo is the covered set, not the catalog). Compare with `catalog.yaml`: list anything uncatalogued or catalogued but missing. Table per item: category, spec exists (YES/NO), last static, last spec + result, last category + result, priority. Footer: `Skills: <n> (<specs>/<n> specs) · Agents: <n> (<specs>/<n> specs)`. Audit passes when every item is catalogued and has a spec file. No writes.

## Report
```
DONE
- <mode>: <counts and verdicts>
YOU DO
1. <fix to make, if any>
NEXT
- <spec or category run to do next>
```
