---
name: rbx-review
description: "Roblox: project-specific code review against conventions.md; fixes what is safe, ranks the rest, learns patterns."
argument-hint: "[diff | branch | <path> | all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Agent
---

# /rbx-review

## 0. Relevance check
Resolve scope: `diff` (default: `git diff` + staged, or recent MCP edits named by the caller), `branch` (`git diff <main>...HEAD`), a path, or `all` (sample: entry scripts + largest 10 modules). Empty scope: `SKIPPED: nothing changed`.

## 1. Context
Read `.rbx-studio/map.md` first (rebuild with `node "{{RBX_HOME}}/tools/rbx-map.js"` if missing or stale) and open only the scripts it points to. `.rbx-studio/conventions.md` (missing: run `/rbx-start` step 3 first, or review against `{{RBX_HOME}}/library/roblox/code-quality.md` only and say so). `{{RBX_HOME}}/docs/standards.md`.

## 2. Review
Delegate to `code-optimizer` with the exact file list (or DataModel script paths), the scope type, and "fix BLOCKER and MAJOR you can fix safely inside the scope; never reformat beyond changed lines". It runs configured gates (StyLua, Selene, luau-lsp with Roblox definitions) and the code-quality checklist.

## 3. Learn
It appends new Keep or Phase out patterns to `conventions.md` under Learned (dated, file:line), and unfixed debt to `.rbx-studio/debt.md`.

## 4. Save
`.rbx-studio/reports/review-<date>.md`: verdict (`APPROVED`, `APPROVED WITH NOTES`, `CHANGES REQUIRED`, `NOT ASSESSED`), files covered, fixes, findings by severity (BLOCKER, MAJOR, MINOR, NIT). Local commit of fixes as `refactor(review): ...` if any.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- verdict: <VERDICT> (<n> files; BLOCKER <n>, MAJOR <n>, fixed <n>)
- conventions.md: +<n> learned
YOU DO
1. <exact step>
RISKS
- <only if real>
NEXT
- <one line>
```
