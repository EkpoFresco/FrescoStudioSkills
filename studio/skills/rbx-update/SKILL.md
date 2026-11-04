---
name: rbx-update
description: "Roblox: live update plan: migration, smoke test, publish steps, soft shutdown, update log. --hotfix."
argument-hint: "[plan | --hotfix <bug>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Agent
disable-model-invocation: true
---

# /rbx-update

## 0. Relevance check
Game not live yet (no GO launch-checklist report in `.rbx-studio/reports/`, no `roblox.universe_id`, and the developer has not said it is live): `SKIPPED: not live, use /rbx-launch`. Nothing changed since the last published version (no commits or Studio edits listed): `SKIPPED: nothing to ship`.

## 1. Changes
List changes since the last update (git log since the last `update-log` report, backlog rows `done`, Studio-only edits in the checkpoint). Classify: content, balance, data schema, monetization, fix.

## 2. Safety (parallel)
- Schema changed: `data-engineer` writes the migration, dry run on a copied prefix, rollback (`/rbx-data-audit migration`).
- Monetization changed: `monetization-designer` policy check.
- `qa-playtester` runs `/rbx-playtest --smoke` on the build.
Any BLOCKER stops the update.

## 3. Rollout plan (liveops-designer)
Timing (before the weekend peak), private test place or server first, publish, then soft shutdown (Creator Hub restart servers with migration) or migrate-on-join, verification in a live server (console clean, data loads), rollback = previous place version number written down before publishing. `--hotfix`: smallest change, smoke test, publish, verify, one-line note.

## 4. Update log
`community-marketer` fills `{{RBX_HOME}}/templates/update-log.md` into `.rbx-studio/reports/update-log-<date>.md`: lead with the best change, short lines, young reading level.

## 5. Approval
Publishing, restarting servers, and posting the log are outward-facing. Present the plan and wait for the developer's go. They publish (or approve a scripted Open Cloud publish).

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- update plan: <n> changes, migration <yes/no>, smoke <PASS/FAIL> (.rbx-studio/reports/update-log-<date>.md)
YOU DO
1. note current place version: Creator Hub > Creations > <game> > Places > <place> > Version History
2. Studio > File > Publish to Roblox
3. Creator Hub > Creations > <game> > ... > Restart Servers (soft shutdown)
RISKS
- <only if real>
NEXT
- /rbx-metrics in 48 h
```
