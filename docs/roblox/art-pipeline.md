# Art and Asset Pipeline Reference

Last checked: 2026-11-03. Sources at bottom.

Reader: the `art-generator` agent. Scope: Studio MCP generation tools, placeholder to production workflow, the look check, Figma to Roblox UI, mobile asset budgets, permissions and licensing.

## TL;DR for agents

- Generation tools on this machine: `generate_mesh`, `generate_texture`, `generate_material`, `generate_procedural_model`, `segment_mesh`, plus `store_image`, `upload_image`, `search_asset`, `insert_asset`, `screen_capture` [1].
- Default to `async: true` for `generate_mesh`, `generate_material`, `generate_procedural_model`. Call `wait_job_finished` only when the next step depends on the result [1]. `generate_texture` and `segment_mesh` have no async flag [1].
- `generate_mesh`: `maxTriangles` 12 to 20,000 [1], default 10,000 [3][11]. Use 100s to 1K for small or low-poly props [3]. Size is a hint, not a guarantee [1][4]. Measure and rescale after.
- Prompts: name the object, then add color, material, and one distinguishing feature. Never add background, camera, lighting, or "high quality" words [12][5].
- Procedural models: 50 per rolling 24 hours [11]. They regenerate and wipe manual edits. Bake by clearing `Generator` [10].
- Mobile budgets: 20,000 triangles per mesh hard cap [17]. Most images at most 512x512, minor images under 256x256 [20]. Texture memory scales with pixels, not file size [20].
- Look check every asset with `screen_capture` at a phone framing and a desktop framing. Judge silhouette, contrast, style match, triangle and texture budget. Two failed rounds on a hero asset means escalate to a human artist.
- Creator Store assets: prefer `verifiedCreatorsOnly`, inspect scripts before shipping, and ask the user before any cross-owner insert [1][36].
- Figma path: Studio side (`upload_image` accepts `figma.com/api/mcp/asset` URLs, `execute_luau`, `screen_capture`) is wired today [1]. Figma MCP server is NOT configured in this repo yet. Figma asset URLs expire, so upload right after fetching [43].
- Measure, do not guess: Developer Console Memory (`GraphicsTexture`, `GraphicsMeshParts`) [22] and the MCP skill `rbx-scene-analysis` (SceneAnalysisService) [1][23].

## 1. Studio MCP generation tools

### 1.1 Models behind the tools

- Cube 3D is Roblox's 3D foundation model. `GenerationService` generates 3D objects from text with it [4].
- Studio `generate_mesh` uses the same mesh generation as Assistant, built on `GenerateModelAsync` [3].
- `GenerateModelAsync` inputs: `TextPrompt` or `Image`, approximate `Size`, `MaxTriangles`, `GenerateTextures` (default true). Schemas: `Car5`, `Body1`, or a custom `Groups` list [4].
- Open repo `Roblox/cube`: v0.1 (March 2025), v0.5 (July 2025, adds bounding box conditioning), CubePart (May 2026, part-controllable) [14]. Open weights output untextured `.obj`; texture generation listed as upcoming [14].
- Known model weakness: extreme bounding boxes for a prompt cause bad or disconnected output [14]. Give realistic proportions in `size`.
- 4D generation (functional objects via schemas) entered beta 2026-02-04, focused on in-experience creation [15].
- Errors to expect: rate limit (per minute, value not published), moderation rejection, character limit exceeded, service overloaded [4].
- Quota: Roblox describes "default free platform limits" for Cube 3D, with Extended Services to buy more capacity [16]. Exact numbers: UNVERIFIED. Verify: Creator Dashboard Extended Services page, or log the `wait_job_finished` failure text when a limit hits.

### 1.2 Tool by tool

| Tool | What it does | Hard limits | Best for |
|---|---|---|---|
| `generate_mesh` | Text to textured mesh [1] | `maxTriangles` 12 to 20,000 [1]; `partNames` max 8 [1]; text only via MCP (no image param) [1] | Props, set dressing, first-pass hero shapes |
| `generate_texture` | Re-textures an existing MeshPart or Model in place [1] | `Quality` mode: single MeshPart only, research preview [1] | Restyling generated or imported meshes |
| `generate_material` | Creates a MaterialVariant, returns BaseMaterial + variant name [1] | `baseMaterial` must be one of 40 enum values [1] | Tiling surfaces: floors, walls, terrain, rock |
| `generate_procedural_model` | Builds a ProceduralModel from primitives with editable attributes [1] | 50 per rolling 24h [11]; `partNames` max 8 [1] | Placeholders, parametric props (fences, tracks, shelves) |
| `segment_mesh` | Splits a mesh into named sub-parts [1] | Max 5 parts per pass; rerun for more [1][6] | Making wheels, doors, lids movable |
| `store_image` | Local png/jpg to `IMAGEID_<id>` URI [1] | 5MB max [1] | Reference images for procedural models |
| `upload_image` | Batch HTTP image URLs to `rbxassetid://` map [1] | Moderation before others see it, usually within hours [35] | UI raster assets, decals |

### 1.3 `generate_mesh`

- Does well: single coherent objects with clear silhouettes. Roblox claims better forms, fewer artifacts, and less baked-in lighting in current generation [5].
- `size`: "will try to fit" [1]. `GenerationService` gives "no guarantee" on final size [4]. Always read the result's bounding box and scale.
- `maxTriangles`: lower values look more faceted and low-poly [4][11]. Budget guide in section 4.2.
- `segmentation`: omit for auto, `none` for one piece, `explicit` plus `partNames` when the user named parts [1]. Segment only parts that will move or swap color (wheels, doors). Each part is a separate MeshPart and draw call candidate (heuristic, see [20]).
- Image input exists in Assistant (Input Mode: Image) [6], not in the MCP schema on this machine [1]. For image-guided shapes use `generate_procedural_model` with `attachedImageUri`.
- Prompt recipe (Roblox guidance [12][5]):
  - Start with the noun, then layer details: `mailbox` to `blue metal mailbox` to `weathered blue metal mailbox with a red flag` [12].
  - Pattern from Roblox samples: color + object + distinguishing feature, e.g. "yellow sports car with a spoiler" [5].
  - Describe only the object. Drop backgrounds, camera angles, lighting, and quality words [12].
- Prompt additions that help style consistency (heuristic): one fixed style phrase per project from the art bible (e.g. "stylized low-poly, chunky proportions, flat colors"), reused verbatim on every prompt.
- Avoid in prompts (heuristic, plus moderation [4][38]): brand names, real logos, celebrity names, weapons in all-ages games.
- Placeholder use: `maxTriangles` 300 to 1,000, no segmentation. Production use: tuned prompt, explicit parts if needed, then `generate_texture` Quality pass, then look check.

### 1.4 `generate_texture`

- Fast mode: 1K diffuse texture via a new TextureID, under 30 seconds [7]. Quality mode: 4K PBR via a SurfaceAppearance, "a couple of minutes" [7]. MCP default is Quality [1].
- Quality accepts a single-MeshPart source only [1]. For multi-part Models use Fast, or texture parts one at a time.
- Optional `hintImage` is a style guide, not a template [1][7].
- Prompt tips (Roblox [7]): give as much detail as possible (materials, colors, patterns, features). Do not ask it to change geometry, reference the current texture, other scene objects, terrain, earlier generations, reflectivity, or transparency.
- Multi-mesh input should form "a unified body". Do not texture scattered meshes or several identical meshes in one call [7].
- Do not edit the asset while it runs. Back it up first [7]. Duplicate the source before calling, since it replaces in place [1].
- Known issue (user report): texturing reset custom normals (flat-shaded look) and changed the mesh ID [6]. Look check for faceting after every texture pass.
- Roblox frames output as "a starting point" to refine in external tools [6].
- 4K Quality maps cost memory. Texture Streaming serves lower resolutions on weak devices [19], but downsize anything that stays small on screen (section 4.1).

### 1.5 `generate_material`

- Returns BaseMaterial and the MaterialVariant name. Set both `Material` and `MaterialVariant` on each BasePart [1].
- `materialPattern`: `Organic` randomizes output so tiling looks less repetitive [8]. Use `Regular` for bricks, tiles, planks.
- Prompt tips (Roblox [8]): "close up", "top down", or "texture" for close patterns. "simple", "pattern", "symmetrical", "flat" for clean repeats. Style words: "photorealistic", "cartoon", "hand-drawn". Add "grayscale" if you plan to tint.
- Same prompt gives different results each run [8]. Generate 2 to 3, pick one in the look check.
- Variants live in MaterialService. Renaming a variant breaks parts using it. Packages need the variant present in MaterialService [9].
- A variant set as an override applies to every use of that base material, terrain included [9]. Do not override unless the user asked for a global restyle.
- Prefer materials over per-mesh textures for big repeated surfaces (heuristic, consistent with [9][21]).

### 1.6 `generate_procedural_model`

- Output: a ProceduralModel built from blocks, spheres, cylinders, wedges, with attributes users can tweak without regenerating. Auto-inserted into Workspace [1].
- Pass the user's own words as `prompt`. Do not describe an attached image [1].
- Prompt tips (Roblox [12]): name editable properties ("add properties to change the colors of the cabin"), define scale behavior ("add more chairs proportionally"), include measurements ("distance between the rails").
- Reference images (Roblox [12]): `.png`, good lighting, clear focus, simple background, isometric or 3/4 angle, not low-poly style, multiple viewpoints in one image if needed.
- Regeneration overwrites the `Generated` folder on every parameter change. Finalize, then clear `Generator` to bake [10].
- Cannot be converted to Packages yet. "Join Surfaces" breaks joints during generation [10].
- Best placeholder tool: cheap primitives, instant tweaks, honest gray-box look.

### 1.7 Asset search and insert

- `search_asset` scopes: `auto` waterfalls universe, group, user, then Creator Store [1]. Use `scope: creator_store`, `verifiedCreatorsOnly: true`, `priceFilter: free` for placeholder hunting [1].
- Fetch `thumbnailUrl` to compare results visually before inserting [1].
- Cross-owner inserts: name source and destination owners and get explicit user consent first [1].
- Creator Store results may be restricted. If insert fails, try the next result [1].

## 2. Workflow for `art-generator`

### 2.1 Placeholder pass (minutes, not hours)

1. Read the art bible style phrase and the asset list.
2. Gray-box with plain Parts via `execute_luau`, or `generate_procedural_model` (async) for anything parametric.
3. Quick `generate_mesh` (async, `maxTriangles` 300 to 1,000) only where shape matters for gameplay readability.
4. Tag every placeholder: attribute `ArtStage = "placeholder"` (repo convention, heuristic).
5. One look check at phone framing. Gate: gameplay reads correctly. Polish is not judged.

### 2.2 Production pass (pick per asset)

| Route | When | Steps |
|---|---|---|
| A. Generate | Props, environment pieces, non-branded items | `generate_mesh` with tuned prompt and budgeted `maxTriangles`, `segment_mesh` if parts move, `generate_texture` (Quality for single MeshPart), `generate_material` for surfaces |
| B. Creator Store | Common objects (trees, crates, lamps), audio | `search_asset` verified + free, compare thumbnails, `insert_asset`, strip or review scripts, license check (section 5) |
| C. Human artist | Hero, branded, rigged, or IP-sensitive assets | Write the brief (2.5), keep the placeholder live until delivery |

- Run independent generations in parallel with `async: true`, then `wait_job_finished` per job [1].
- After any generation: inspect with `inspect_instance` for triangle-relevant data, MeshPart count, SurfaceAppearance presence [1].
- Apply mobile settings before the look check: RenderFidelity Automatic, CollisionFidelity Box or collisions off for decor (section 4.3).
- Set `ArtStage = "production"` only after the look check passes.

### 2.3 The look check

- Tool: `screen_capture` with `camera_position` and `look_at_position` [1]. It captures the current Studio viewport [2].
- Capture IDs: `LookCheck_<asset>_<framing>_<round>`.
- Result payloads are large. A community report cites a 1MB MCP result limit for Claude, and JPEG encoding rolling out [3]. Capture one framing per call.

Framings (heuristic, tune per genre):

| Framing | Camera setup | Purpose |
|---|---|---|
| Phone gameplay | Default third-person distance (about 10 to 15 studs behind, slightly above), asset at typical play distance | Silhouette and readability at phone size |
| Phone far | Asset at 2 to 3x play distance | Does it still read as itself? |
| Desktop close | 4 to 6 studs, 3/4 angle | Texture quality, seams, flat-shading artifacts |
| In context | Asset in its real scene with real lighting | Contrast and style consistency |
| UI | Device Simulator phone preset via MCP skill `rbx-device-simulator-lua` [1] | Real phone aspect ratio and safe areas |

What to judge (pass/fail each):

| Check | Pass rule |
|---|---|
| Silhouette | Recognizable as a solid shape at phone gameplay framing. Imagine it all black: can you still name it? |
| Contrast | Value (brightness) differs clearly from the background behind it. Interactive items stand out more than decor |
| Style | Matches the art bible: proportions, palette, surface detail level, same style phrase used |
| Artifacts | No holes, floating bits, flat-shaded faceting after texturing [6], stretched textures |
| Triangle budget | Within the table in 4.2. Check with Scene Analysis triangle composition [23] |
| Texture budget | Resolution matches on-screen size (4.1). No 4K map on a small prop |
| Collision | Matches gameplay need, not visual detail (4.3) |

- Verdict: PASS, FIX (re-prompt or adjust settings, max 2 rounds), or ESCALATE.
- Roblox advises playtesting after every round of changes, AI-made or manual [13]. Rerun the look check after each FIX.
- Record each verdict and the final prompt in the asset log so later assets reuse winning prompts (heuristic).

### 2.4 When to escalate to a human artist

- Hero assets: the main character, signature item, mascot, anything in thumbnails or the game icon.
- Branded or IP-adjacent assets: logos, licensed characters, anything that must not resemble existing IP.
- Rigged or animated meshes. Generated meshes from these tools are not described as rigged [1][4] (character rigging: UNVERIFIED for generated output; verify by inspecting for Bones after generation).
- Style drift: a set of related assets fails the style check twice.
- UI icon sets and fonts that must be pixel-consistent.
- Budget failure: cannot hit triangle or texture budget without losing the silhouette.

### 2.5 Short artist brief (template)

- Asset name, purpose, and where it appears (gameplay, shop, thumbnail).
- Reference: placeholder capture IDs, art bible link, 2 to 3 reference images.
- Silhouette notes: what must read at phone size.
- Budgets: triangle cap, texture size per map, map list (color, normal, roughness, metalness), single UV set in 0 to 1 space [18].
- Format: `.fbx` or `.glb` import [32], quads where possible, watertight, max 4 bone influences per vertex if rigged [17].
- Parts: named sub-meshes that must move or recolor.
- Color: palette hex values, which areas use tint masks (SurfaceAppearance TintMask [27]).
- Deadline, revision count, and ownership terms (work for hire, upload under the game's group).

## 3. Figma to Roblox UI pipeline

### 3.1 Figma MCP server (formerly "Dev Mode MCP server")

- Remote server: `https://mcp.figma.com/mcp`, recommended, no desktop app needed [39][44]. Desktop server: `http://127.0.0.1:3845/mcp`, needs Figma desktop and a Dev or Full seat on a paid plan [42].
- Claude Code is a listed client for desktop and remote [39].
- Useful read tools [40]:

| Tool | Returns | Use in pipeline |
|---|---|---|
| `get_metadata` | XML outline: IDs, names, types, positions, sizes | Frame tree to ScreenGui hierarchy |
| `get_design_context` | Design context plus code (React + Tailwind by default) | Layout hints, text styles, fills |
| `get_variable_defs` | Variables and styles in a selection | Design tokens (colors, spacing, type) |
| `get_screenshot` | Screenshot URL or base64 | Ground truth for the look check |
| `download_assets` (remote only) | Exports and source images, up to 20 nodes per call | Raster assets to upload |

- Asset URLs are temporary and expire [43]. Remote URLs look like `https://www.figma.com/api/mcp/asset/<id>` (format seen in the Studio `upload_image` description [1]). Desktop "Local server" image mode returns localhost links [42].
- Rate limits [41]: View/Collab seats 20 calls per month. Full/Dev: Professional 200/day and 10/min, Organization 200/day and 15/min, Enterprise 600/day and 20/min. Batch work into few calls.

### 3.2 Existing converters (as of 2026-11-03)

| Tool | Type | How | Scale vs offset | Notes |
|---|---|---|---|---|
| Figma Importer Assistant (iGottic) [45] | Figma + Roblox plugin, open source | Classic import as images; "Opportunistic" mode makes text as text, auto layout as wrapped list | Aspect ratio option; commenter says Scale + AspectRatio | Docs at figma-importer.igottic.com; manual fixes expected |
| figrbx (thynomex) [46] | Figma + Studio plugin + local Node bridge, MIT | Six-character code or JSON bundle; live sync every 2 s | Scale | Uploads images via OAuth or Open Cloud key, cached by SHA-256. Drops blend modes, auto-layout reflow, constraints, backdrop blur. Rebuild replaces its ScreenGui |
| FigmaToRoblox (UiUyHerrera) [47] | Figma + Studio plugin + local server, MIT | Six-letter code, port 7777, 6 hour expiry | Not stated | 81 layer-name tags for behavior. Needs Figma desktop |
| RobloxPlugin-FigmaToRoblox (Rawblocky) [48] | Archived 2024, MIT | JSON paste | Offset only | Unmaintained. Do not use |
| RbxUiStudio (MarkRuiz00) [49] | Skill + editor + MCP server + Studio plugin | AI builds real Instances | Not checked | 1 star, very new. Evaluate before trusting |

- All are community tools, not Roblox-endorsed. Maintenance and safety: UNVERIFIED. Verify: read the plugin source before installing, check last commit date, test on a throwaway place.
- No Roblox doc page describes an official Figma integration. The only first-party signal is `upload_image` accepting Figma MCP asset URLs [1]. UNVERIFIED whether Assistant ships a Figma connector. Verify: Studio Assistant > Manage MCP Servers, and DevForum Announcements.

### 3.3 Future-ready path (Figma MCP to ScreenGui)

| Step | Action | Status |
|---|---|---|
| 1 | Add the Figma MCP server to Claude Code (remote URL) | FUTURE: not configured in this repo |
| 2 | `get_metadata` on the frame link; `get_variable_defs` for tokens; `get_screenshot` for reference | FUTURE (needs step 1) |
| 3 | Convert tree to a layout spec: each node gets Position and Size as Scale of its parent frame, AnchorPoint from alignment | Agent logic, wired once step 2 works |
| 4 | Fetch raster asset URLs (`download_assets` or design-context URLs), then `upload_image` immediately (URLs expire [43]) | `upload_image` WIRED [1] |
| 5 | Build the ScreenGui with `execute_luau` in chunks with `task.wait()` [1], or write a builder ModuleScript via `multi_edit` [1] | WIRED |
| 6 | Look check: `rbx-device-simulator-lua` phone preset + `screen_capture`, compare to the Figma screenshot | WIRED [1] |

Mapping rules for step 3 and 5:

- Scale for position and size so layouts adapt; Offset only for fixed pixel nudges [31].
- AnchorPoint (0.5, 0.5) for centered elements so resizing keeps the midpoint [31].
- `UIAspectRatioConstraint` on icons and square images. It overrides layout sizing inside `UIListLayout` [30].
- `UISizeConstraint` for min and max sizes; `UITextSizeConstraint` with `MinTextSize` no lower than 9 [30].
- One `UIScale` on the root for global sizing and tweened emphasis [30].
- Keep important UI out of bottom-left and bottom-right corners on mobile (default controls live there) [31].
- Figma auto layout to `UIListLayout` or flex; corner radius to `UICorner`; strokes to `UIStroke` (pixel thickness does not scale [46]); gradients to `UIGradient`.
- Pack small icons into one sprite sheet, use `ImageRectOffset` and `ImageRectSize` [29][20]. Use `ScaleType.Slice` with `SliceCenter` for 9-slice panels [29].
- Write tokens to a `UITheme` ModuleScript (colors, spacing, font sizes) so UI code reads tokens, not literals (heuristic).

## 4. Asset optimization for mobile

### 4.1 Textures and images

- Max texture resolution: 4096x4096 [18]. 4K renders where Texture Streaming decides more than 1K is needed, and weaker devices get lower versions [19].
- Engine loads low quality first, then ramps up by device memory, distance, and screen coverage [20][18].
- Memory = pixel count. 1024x1024 uses 4x the memory of 512x512. Compression and stripping alpha do not reduce memory [20].
- Most images need at most 512x512. Minor images should be under 256x256 [20].
- Upload format limits: png, jpg, tga, bmp [18]; Open Cloud images under 8000x8000 and 20MB per file [32].

| Use | Recommended size | Source |
|---|---|---|
| Object about 5x5 studs | 256x256 | [18] |
| Object about 10x10 studs | 512x512 | [18] |
| Object about 20x20 studs | 1024x1024 | [18] |
| PBR maps | 256x256 per 2x2x2 units, round up | [18] |
| Minor UI icons | under 256x256, packed in sprite sheets | [20] |
| Full-screen UI art | up to 1024 on the long side | heuristic |
| Generated Quality texture | Arrives 4K PBR [7]; keep only for large or hero assets | heuristic |

- Reuse one color map with different `SurfaceAppearance.Color` tints. Tinting "does not affect performance" and saves memory [27][20].
- Built-in materials use much less memory than custom textures [21].

### 4.2 Meshes and triangles

- Hard cap: 20,000 triangles per individual mesh [17]. `generate_mesh` accepts up to 20,000 [1].
- Roblox publishes no per-asset budgets. One documented baseline example: under 1,000 draw calls and 1,000,000 triangles for a low-end target device [21]. Draw calls matter more than triangles [20].

| Asset class | Triangle budget | Source |
|---|---|---|
| Small or low-poly prop | 100s to 1,000 | [3] |
| Medium prop, furniture | 1,000 to 3,000 | heuristic |
| Large or detailed object | up to 10,000 (generation default) | [3][11] |
| Hero asset | up to 20,000 cap, justify it | [17] |

- Upload once, reuse the same MeshId. Identical meshes with the same MeshContent and identical SurfaceAppearance (or TextureContent) batch into one draw call [20].
- The Importer does not deduplicate meshes. Use Packages to reuse objects [20].
- Combining parts can cut draw calls (Roblox example: 8 to 1) [50].

### 4.3 Fidelity settings

| Setting | Values | Mobile default |
|---|---|---|
| RenderFidelity | Automatic: LOD by distance (under 250 studs high, 250 to 500 medium, 500+ low) [24][25]. Precise: always full detail. Performance: favors speed, may hurt visuals [25] | Automatic. Performance for background. Avoid Precise at scale [20] |
| CollisionFidelity | Default (voxel convex hull), Hull, Box, PreciseConvexDecomposition, Tunable [26] | Box for small anchored decor [20]. PreciseConvexDecomposition is most expensive [20] |
| Non-collidable decor | CanCollide, CanTouch, CanQuery false. Collision geometry stays in memory otherwise [20] | Always |
| CastShadow | Off for small and distant parts [20] | Off on decor |

- Transparency: avoid values other than 0 and 1 [21]. Layered transparent foliage creates heavy overdraw [50].

### 4.4 SurfaceAppearance and MaterialVariant cost

- SurfaceAppearance: up to five maps (color, normal, roughness, metalness, emissive mask) [27]. Each map costs memory by pixels [20]. Not preloadable by `PreloadAsync`; streams at runtime [28].
- Instancing breaks if SurfaceAppearances differ, so share one SurfaceAppearance setup across copies [20].
- MaterialVariant: one tiling set shared by every part using it (heuristic: cheaper than per-mesh textures for big surfaces). Also not supported by `PreloadAsync` [28].
- Numeric cost of either: not documented. UNVERIFIED. Verify: compare `GraphicsTexture` in the Developer Console before and after adding [22].

### 4.5 Instances, UI images, preloading, audio

- Instance counts: no official budget. Scene Analysis groups instances by category and flags surprises (Roblox example: 25,000 particle emitters) [23]. Steadily growing counts signal leaks [20].
- Streaming is the "highest impact" client memory lever [20].
- UI images count as textures. Size them to on-screen pixels and pack sprite sheets [20][29].
- `ContentProvider:PreloadAsync`: preload only loading-screen, key UI, and start-area assets. Not the whole Workspace. Offer a skip [28][20]. Do not drive loading bars with `RequestQueueSize` [28].
- Audio: MP3, OGG, WAV, FLAC, 48 kHz or lower, under 20MB and 7 minutes [33]. Audio memory surprises; load only what the current area needs [20].

### 4.6 How to measure

- Developer Console > Memory: `GraphicsTexture`, `GraphicsTextureCharacter`, `GraphicsMeshParts`, `GraphicsParts`, `GraphicsParticles`, `Sounds` [22].
- Studio memory numbers run high because client and server share one process. Test on real devices [21].
- Scene Analysis (Window > Performance Summary > Scene Analysis): triangle and draw call counts by pass, instance composition, audio and animation memory [23].
- Via MCP: invoke skill `rbx-scene-analysis` first, then call `SceneAnalysisService` methods (`GetTriangleCompositionAsync`, `GetInstanceCompositionAsync`, `GetAudioMemoryAsync`) through `execute_luau` during a playtest [1][23].
- Render stats in client: Shift+F2 [20].

## 5. Permissions and licensing

### 5.1 Privacy defaults

- Imported assets are private by default [35]. Images, Decals, and Meshes are Open Use by default unless Asset Privacy is on [34].
- Granting a game access to a restricted asset cannot be revoked [34].
- Restricted assets without permission are invisible or silent at runtime [37].
- Upload under the account or group that owns the game. Package ownership cannot be transferred [37].

### 5.2 Creator Store assets

- Loading needs explicit permission. Without it the asset does not load in Studio or at runtime [36].
- Safety: watch for remote asset loading ("virus" assets), obfuscated code, huge scripts. Disable scripts from Explorer to test an asset without them [36].
- Agent rule: after `insert_asset`, list descendant scripts with `search_game_tree` (`instance_type: BaseScript`) and report them before keeping the asset [1].
- Paid models: forked games and dynamic loads only work if the owner bought it or the game has permission [36].
- Content must follow Community Rules, Terms of Use, and IP guidelines. No separate Creator Store license is named [36].

### 5.3 Audio

- Imported audio starts private; grant use to specific experiences [33].
- Import quotas: docs conflict. Audio assets page says 2,000 per 30 days ID-verified, 100 unverified [33]. Open Cloud guide says 100 per month verified, 10 unverified for API uploads [32]. UNVERIFIED which applies to Studio imports. Verify: Creator Dashboard upload quota display.
- Prefer the Creator Store audio library (100,000+ licensed tracks and effects) for placeholders [33].

### 5.4 Packages

- Permission levels: Use & View, or Edit [37]. `PackageLink.AutoUpdate` updates unmodified copies on open [37].
- Procedural models cannot be Packages yet [10].

### 5.5 Generated assets

- All generated content must follow Community Standards. GenerationService inputs and outputs are moderated [38].
- Uploaded assets pass moderation, usually within a few hours [35]. Declined images never load (`IsLoaded`) [29].
- In-experience generation (players prompting) must be disclosed in the Content Maturity questionnaire [38].
- Ownership and commercial rights to Studio-generated meshes and textures: UNVERIFIED (Terms of Use page returned 403). Verify: read the Roblox Terms of Use sections on AI tools and User Content at en.help.roblox.com.
- Agent rule (heuristic): never prompt with brand, franchise, or real-person names. Treat look-alike output as an IP risk and escalate.
- `SegmentMeshAsync` on a published mesh needs edit permission for that asset [4]. Assume `segment_mesh` follows the same rule (UNVERIFIED).

## Sources

[1] Roblox Studio MCP tool manifest (local verbatim dump) - docs/roblox/studio-mcp-tools.md - checked 2026-11-03
[2] Connect to the Roblox Studio MCP server - https://create.roblox.com/docs/studio/mcp - checked 2026-11-03
[3] Assistant Updates: Mesh Generation, New MCP Server Tools, Screenshot Tool, and More (DevForum, 2026-03-19) - https://devforum.roblox.com/t/assistant-updates-mesh-generation-new-mcp-server-tools-screenshot-tool-and-more/4527258 - checked 2026-11-03
[4] GenerationService API reference - https://create.roblox.com/docs/reference/engine/classes/GenerationService - checked 2026-11-03
[5] Model generation guide - https://create.roblox.com/docs/parts/model-generation - checked 2026-11-03
[6] Introducing new texture generation tools, segment any mesh, and image previews (DevForum, 2026-09-23) - https://devforum.roblox.com/t/introducing-new-texture-generation-tools-segment-any-mesh-and-image-previews/4890084 - checked 2026-11-03
[7] Texture Generator - https://create.roblox.com/docs/studio/texture-generator - checked 2026-11-03
[8] Material Generator - https://create.roblox.com/docs/studio/material-generator - checked 2026-11-03
[9] Materials (custom materials) - https://create.roblox.com/docs/parts/materials - checked 2026-11-03
[10] [Full Release] Procedural Models (DevForum, 2026-05-18) - https://devforum.roblox.com/t/full-release-procedural-models-build-parametrized-3d-models-with-code-or-ai/4642542 - checked 2026-11-03
[11] Assistant guide - https://create.roblox.com/docs/assistant/guide - checked 2026-11-03
[12] Assistant prompt guide and examples - https://create.roblox.com/docs/assistant/prompt-engineering - checked 2026-11-03
[13] Build with Assistant - https://create.roblox.com/docs/ai/build-with-assistant - checked 2026-11-03
[14] Roblox/cube GitHub repository - https://github.com/Roblox/cube - checked 2026-11-03
[15] Accelerating creation powered by the Roblox Cube foundation model (Roblox newsroom, 2026-02-04) - https://about.roblox.com/newsroom/2026/02/accelerating-creation-powered-roblox-cube-foundation-model - checked 2026-11-03
[16] Creator Roadmap 2025: Summer Update (DevForum; read via search excerpt only) - https://devforum.roblox.com/t/creator-roadmap-2025-summer-update/3880746 - checked 2026-11-03
[17] Mesh specifications - https://create.roblox.com/docs/art/modeling/specifications - checked 2026-11-03
[18] Texture specifications - https://create.roblox.com/docs/art/modeling/texture-specifications - checked 2026-11-03
[19] [Studio Beta] 4k Texture rendering (DevForum) - https://devforum.roblox.com/t/studio-beta-4k-texture-rendering/4144950 - checked 2026-11-03
[20] Improve performance - https://create.roblox.com/docs/performance-optimization/improve - checked 2026-11-03
[21] Design for performance - https://create.roblox.com/docs/performance-optimization/design - checked 2026-11-03
[22] Memory usage (Developer Console) - https://create.roblox.com/docs/studio/optimization/memory-usage - checked 2026-11-03
[23] Scene Analysis - https://create.roblox.com/docs/performance-optimization/scene-analysis - checked 2026-11-03
[24] MeshPart API reference - https://create.roblox.com/docs/reference/engine/classes/MeshPart - checked 2026-11-03
[25] RenderFidelity enum - https://create.roblox.com/docs/reference/engine/enums/RenderFidelity - checked 2026-11-03
[26] CollisionFidelity enum - https://create.roblox.com/docs/reference/engine/enums/CollisionFidelity - checked 2026-11-03
[27] SurfaceAppearance - https://create.roblox.com/docs/art/modeling/surface-appearance - checked 2026-11-03
[28] ContentProvider API reference - https://create.roblox.com/docs/reference/engine/classes/ContentProvider - checked 2026-11-03
[29] ImageLabel API reference - https://create.roblox.com/docs/reference/engine/classes/ImageLabel - checked 2026-11-03
[30] Size modifiers and constraints - https://create.roblox.com/docs/ui/size-modifiers - checked 2026-11-03
[31] UI position and size - https://create.roblox.com/docs/ui/position-and-size - checked 2026-11-03
[32] Usage guide for assets (Open Cloud) - https://create.roblox.com/docs/cloud/guides/usage-assets - checked 2026-11-03
[33] Audio assets - https://create.roblox.com/docs/audio/assets - checked 2026-11-03
[34] Asset privacy - https://create.roblox.com/docs/projects/assets/privacy - checked 2026-11-03
[35] Assets overview - https://create.roblox.com/docs/projects/assets - checked 2026-11-03
[36] Creator Store - https://create.roblox.com/docs/production/creator-store - checked 2026-11-03
[37] Packages - https://create.roblox.com/docs/projects/assets/packages - checked 2026-11-03
[38] Games with generative AI - https://create.roblox.com/docs/generative-AI - checked 2026-11-03
[39] Figma MCP server introduction - https://developers.figma.com/docs/figma-mcp-server/ - checked 2026-11-03
[40] Figma MCP server tools and prompts - https://developers.figma.com/docs/figma-mcp-server/tools-and-prompts/ - checked 2026-11-03
[41] Figma MCP server rate limits and access - https://developers.figma.com/docs/figma-mcp-server/rate-limits-access/ - checked 2026-11-03
[42] Figma MCP desktop server installation - https://developers.figma.com/docs/figma-mcp-server/local-server-installation/ - checked 2026-11-03
[43] Figma MCP: why have my images stopped loading - https://developers.figma.com/docs/figma-mcp-server/images-stopped-loading/ - checked 2026-11-03
[44] Figma Help: Guide to the Figma MCP server - https://help.figma.com/hc/en-us/articles/32132100833559-Guide-to-the-Dev-Mode-MCP-Server - checked 2026-11-03
[45] Figma Importer Assistant v2 (DevForum, iGottic) - https://devforum.roblox.com/t/2961561 - checked 2026-11-03
[46] figrbx (GitHub, thynomex) - https://github.com/thynomex/figrbx - checked 2026-11-03
[47] FigmaToRoblox (GitHub, UiUyHerrera) - https://github.com/UiUyHerrera/FigmaToRoblox - checked 2026-11-03
[48] RobloxPlugin-FigmaToRoblox (GitHub, Rawblocky, archived) - https://github.com/Rawblocky/RobloxPlugin-FigmaToRoblox - checked 2026-11-03
[49] GitHub topic figma-to-roblox (RbxUiStudio) - https://github.com/topics/figma-to-roblox - checked 2026-11-03
[50] Optimize your experience (environmental art curriculum) - https://create.roblox.com/docs/tutorials/curriculums/environmental-art/optimize-your-experience - checked 2026-11-03
