---
name: rbx-thumbnail
description: "Roblox: write the icon and thumbnail brief and a thumbnail personalization A/B plan judged by play-through rate and first-play bounce (QPTR over CTR), then optionally produce placeholder art via Studio MCP. Use before launch, when PTR is low, or for a new update or event."
argument-hint: "[brief | plan | make]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, PowerShell, Agent
---

# /rbx-thumbnail

## 0. Relevance check
No concept brief and no playable game: `SKIPPED: nothing to promise yet, run /rbx-concept`.

## 1. Context
`{{RBX_HOME}}/library/roblox/discovery-algorithm.md` (thumbnail personalization, penalties for mismatched metadata), `discovery-playbook.md`, the concept brief and `.rbx-studio/reports/first-60.md`. Note from research: thumbnail personalization is Roblox's only creative test tool; there is no icon A/B tool (icon tests are sequential swaps, a workaround, not Roblox guidance).

## 2. Brief
`discovery-strategist` writes `.rbx-studio/reports/thumbnails.md`: the one moment from the first 60 s each image promises (the promise must be true), 3-5 thumbnail concepts that each vary one thing (subject, action, color, text-free vs one word), icon concept readable at 50x50 px, gameplay video beats.

## 3. Test plan
Personalization set of 2-5 active thumbnails. Judge by PTR and first-play bounce for RFY traffic, not CTR alone; hold each set at least 7 days or until the dashboard shows a clear winner. Exact path to read results: Creator Hub > Creations > <game> > Analytics (home page / thumbnail personalization section; column names UNVERIFIED, see OPEN_QUESTIONS #3).

## 4. Make (optional, `make`)
`art-generator` stages each concept in Studio (placeholder models, lighting, camera) and captures it with `screen_capture` plus `{{RBX_HOME}}/tools/capture-studio.ps1` to `.rbx-studio/evidence/thumbnails/`. Final art at 16:9; check readability at phone thumbnail size.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- brief + plan: .rbx-studio/reports/thumbnails.md (<n> variants)
- placeholders: .rbx-studio/evidence/thumbnails/ (if made)
YOU DO
1. Creator Hub > Creations > <game> > Places/Experience > Thumbnails: upload variants, turn on personalization
RISKS
- <only if real>
NEXT
- /rbx-launch
```
