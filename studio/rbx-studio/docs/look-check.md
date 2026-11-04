# Look Check

Anything visual (UI, art, VFX, a new area, a HUD number) is not done until it was launched and looked at. A parse check is not a run. A story nobody looked at does not close. (Kept from the original run-and-observe rule.)

## Procedure (Studio MCP)
1. `get_studio_state`. If playing, `start_stop_play` with `is_start=false` first.
2. Reach the state: set it in edit mode with `execute_luau` (attributes, a debug flag), or launch and drive it (`user_mouse_input`, `user_keyboard_input`, `character_navigation`).
3. `start_stop_play` `is_start=true`. Wait about 5 s (`get_console_output` should show your boot log). Check the console for errors first.
4. Desktop: `screen_capture`. Phone: load the MCP skill `rbx-device-simulator-lua` (`skill` tool), switch to a landscape phone (iPhone 14 class, 844x390 logical), `screen_capture` again. Add tablet or console when `roblox.target_devices` lists them.
5. Judge each capture against the Look check rubric at the bottom of `{{RBX_HOME}}/library/roblox/ux-standards.md` (UI) or the art checks in `art-pipeline.md` (assets). Write PASS or FAIL per rubric line that applies.
6. Retain evidence. MCP captures return to you only, so save the Studio window: `powershell -NoProfile -ExecutionPolicy Bypass -File "{{RBX_HOME}}/tools/capture-studio.ps1" -Out ".rbx-studio/evidence/<story>/NN-<what>.png"`. Read the PNG back to confirm it shows the state.
7. `start_stop_play` `is_start=false`. Changes made during play are lost; that is expected.
8. Report one line: `Run result: OBSERVED - <what was on screen> - <evidence path>`, or `NOT VERIFIED - <reason>`, or `N/A - <reason>`.

## Rules
- `NOT VERIFIED` blocks closing a UI or visual story at every rigor level.
- `N/A` only for work with nothing observable (pure data migration). "It is logic" is not a reason: a number shows somewhere.
- Stills prove layout, clipping, presence, contrast, legibility. They do not prove feel, timing, or audio. Say which half you covered.
- No MCP: say so, run the file-level checklist, and mark the visual half `NOT VERIFIED`.

## Escalation
Two failed look checks on the same asset or screen, or the developer says it looks bad ("this looks rly bad, we gotta work on it"): stop iterating, fill `{{RBX_HOME}}/templates/artist-brief.md` into `.rbx-studio/reports/`, and say who should take it.
