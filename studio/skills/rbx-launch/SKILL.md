---
name: rbx-launch
description: "Roblox: launch checklist and GO / NO-GO."
argument-hint: "[check | plan]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent
disable-model-invocation: true
---

# /rbx-launch

## 0. Relevance check
Game already public with players (a GO launch-checklist report exists in `.rbx-studio/reports/`, or the developer says it is live): `SKIPPED: live game, use /rbx-update`. No playable build: `SKIPPED: build the first playable first`.

## 1. Context
`{{RBX_HOME}}/templates/launch-checklist.md`, `{{RBX_HOME}}/library/roblox/discovery-playbook.md` (pre-launch and launch week), `discovery-algorithm.md` (audience gate: new games reach age-checked 16+ until Kids and Select evaluation, 250 engaged plays in 60 days, planned 100 UNVERIFIED), `policy.md` (title rules, social links field only, ads registration since 2026-05-04, maturity labels).

## 2. Gather evidence (parallel, reuse recent reports under 7 days old)
- `/rbx-first-60 review` result, `/rbx-data-audit`, `/rbx-remote-audit`, `/rbx-perf` (phone profile).
- `discovery-strategist`: discovery plan (`{{RBX_HOME}}/templates/discovery-plan.md`), thumbnail set, ads budget and stop rule (ads buy retrieval, not ranking).
- `community-marketer`: title, description, update log draft.

## 3. Checklist
Fill `.rbx-studio/reports/launch-checklist.md`. Each line: done, missing, or N/A with why. Any BLOCKER from audits, a failed first-60 look check, or a policy fail is NO-GO.

## 4. Verdict
GO or NO-GO with the shortest path to GO. Publishing is the developer's action after approval.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- verdict: GO | NO-GO (<n> open items) (.rbx-studio/reports/launch-checklist.md)
YOU DO
1. Creator Hub > Creations > <game> > Configure > Questionnaire: complete maturity questionnaire
2. Studio > File > Publish to Roblox (after GO)
RISKS
- <only if real>
NEXT
- <one line>
```
