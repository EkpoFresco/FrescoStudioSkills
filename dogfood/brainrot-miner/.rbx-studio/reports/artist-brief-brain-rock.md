# Artist brief: Brain Rock (hero)
Date: 2026-11-04 · Why a human: failed look check twice

## What it is
The giant purple brain rock the player taps. Center of the game, in the thumbnail and icon. Workspace.BrainRock, 15 wide, 11 tall.

## What is wrong now
- Round 1: lumps floated above two small spheres. Read as bubbles, not a brain. (Ball parts ignore non-uniform size.)
- Round 2: two tall purple blobs with discs stuck on. Reads as gummy bears or ears, not a rock or a brain. No center groove visible from the front.
- Round 3 (generate_mesh, 1000 tris, prompt "wide lumpy purple brain-shaped boulder with a deep center groove..."): came out as a smooth pink-purple sphere with one seam. Reads as a peach, no folds. Removed from the scene.
- Evidence: .rbx-studio/evidence/art/01-scene-round2.png
- Primitives will not get there. Needs one sculpted mesh.

## What good looks like
- Style refs: .rbx-studio/reports/style-sheet.md (goofy, chunky, bright). Wide lumpy dome, low and heavy like a boulder, brain folds on top, clear center groove, flat bright colors.
- Must read at phone size (844x390 landscape) from 15 studs, and at 2x distance.
- Looks good with a Snorblet standing on top (thumbnail promise).
- Original design. No existing IP.

## Specs
Triangles <= 10,000 (hero) · Texture <= 512x512 · Format .fbx or .glb, single mesh, watertight, flat base · Colors #8E4DD6 body, #B57BFF folds, #5A2E91 groove · Deliver as one MeshPart, pivot at base center, collision box

## Deadline / priority
Priority: high (hero). Keep the placeholder live until delivery.
