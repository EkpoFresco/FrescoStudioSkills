---
name: skill-improve
description: "Maintainer tool for this repo: improve one rbx-studio skill or agent with a test, fix, retest loop (static lint, spec, category), keeping a change only if the score does not drop."
argument-hint: "<skill-or-agent-name>"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash(node tools/studio-lint.js*), Bash(git diff*), Bash(git checkout -- studio/*)
---

# /skill-improve

## 1. Baseline
Run `/skill-test static <name>`, `/skill-test spec <name>`, `/skill-test category <name>`. Score = failures x 3 + partials x 1 + warnings x 1 (lower is better). Record it.

## 2. Diagnose
List the failing checks and assertions. Pick the one with the biggest effect on real use (a wrong action beats a missing word). Never weaken a spec assertion to make it pass; fix the spec only when it asserts wrong behavior, and say why.

## 3. Fix
Edit `studio/skills/<name>/SKILL.md` or `studio/agents/<name>.md` with the smallest change. Keep the developer's style: lead with results, short lines, no em dashes, DONE / YOU DO / RISKS / NEXT reports.

## 4. Retest
Rerun the three modes. Score lower or equal with the target fixed: keep. Score higher: revert with `git checkout -- <file>` and try the next fix. Max 3 rounds.

## 5. Record
Update catalog dates and results. Commit locally: `fix(studio): improve <name> (<before> -> <after>)`.

## Report
```
DONE
- <name>: score <before> -> <after>; fixed: <items>
YOU DO
1. reinstall to pick it up: .\install.ps1
NEXT
- /skill-improve <next weakest>
```
