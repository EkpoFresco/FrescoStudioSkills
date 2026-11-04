---
name: rbx-art
description: "Roblox: make or improve art through Studio MCP generation tools (meshes, textures, materials, procedural models), keep one style sheet, audit asset budgets for mobile, and run the art look check at phone and desktop framings. Writes an artist brief after two failed looks. Use for placeholder art, production assets, or 'this looks bad'."
argument-hint: "[style | make <asset> | improve <path> | audit]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent
---

# /rbx-art

## 0. Relevance check
No Studio MCP: `make`/`improve` cannot run; do `style` or `audit` from files and say so. If the developer said it looks bad ("this looks rly bad, we gotta work on it"), skip to step 5 for that asset.

## 1. Context
`{{RBX_HOME}}/library/roblox/art-pipeline.md`, `{{RBX_HOME}}/library/roblox/studio-mcp-tools.md` (generation params), `{{RBX_HOME}}/docs/look-check.md`, `.rbx-studio/reports/style-sheet.md` (create from `{{RBX_HOME}}/templates/style-sheet.md` if missing; `style` mode stops after this).

## 2. Make or improve
Delegate to `art-generator` with: asset list, style sheet path, target DataModel parent, placeholder vs production, budgets (props <= 1K tris, hero <= 10K, textures <= 512, minor <= 256). Generation calls use `async: true` and `wait_job_finished` only when the next step needs the result. Track attempts per asset in the report.

## 3. Look check (every asset)
`screen_capture` with a camera at phone framing (near, as the player sees it on an 844x390 screen) and desktop framing; judge silhouette, contrast with surroundings, style match, budget. Save evidence to `.rbx-studio/evidence/art/` with `{{RBX_HOME}}/tools/capture-studio.ps1`. PASS or FAIL per asset with the reason.

## 4. Audit (`audit` mode)
`search_game_tree` + `inspect_instance` for MeshParts (triangle counts where readable, RenderFidelity, CollisionFidelity), SurfaceAppearances, images over 512, unanchored decor. MCP skill `rbx-scene-analysis` for memory by asset. Rank by memory.

## 5. Escalate
Second FAIL on the same asset, or the developer flagged it: fill `{{RBX_HOME}}/templates/artist-brief.md` into `.rbx-studio/reports/artist-brief-<asset>.md` in the developer's style and stop iterating on it.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- <asset> at <path>: <tris>/<texture>, look PASS | FAIL (<evidence path>)
- artist brief: <path> (if escalated)
YOU DO
1. <exact step>
RISKS
- <only if real>
NEXT
- <one line>
```
