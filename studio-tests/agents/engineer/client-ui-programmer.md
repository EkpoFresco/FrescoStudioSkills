# Agent Spec: client-ui-programmer
Category: engineer · Source: `studio/agents/client-ui-programmer.md`

## Summary
Builds ScreenGui hierarchies, responsive mobile-first layout, tweens, input across touch, gamepad, and keyboard, camera, and client feel. Uses the project's UI approach, builds with Scale and constraints inside safe areas, lets the server decide anything of value, and look checks every visual change at phone and desktop before handing to code-optimizer.

## Static Assertions
- [ ] Description starts "Roblox client and UI programmer" and names /rbx-build
- [ ] Knowledge lists `{{RBX_HOME}}/library/roblox/ux-standards.md`, `implementation.md`, `art-pipeline.md`, `{{RBX_HOME}}/docs/look-check.md`
- [ ] Hard rules: touch >= 44 px, primary >= 60 px, text >= 14 px; no `TextScaled` on body text; no per-frame allocation in RenderStepped
- [ ] "The client asks, the server decides" for purchases, currency, and progress
- [ ] Report block with `Run result: OBSERVED - <what> - <evidence path>` and the no-em-dash style line

## Case 1: In-domain - phone-first shop screen
**Input**: "/rbx-build S-06: shop UI for 6 upgrades, plain Instances, landscape phone first."
**Expected behavior**:
- Builds the tree with `execute_luau` (chunked, parented once); Scale plus UIAspectRatioConstraint, `ScreenInsets = CoreUISafeInsets`, `ResetOnSpawn = false`.
- Branches glyphs on `UserInputService.PreferredInput`; sets `Selectable` and `NextSelection*` for gamepad.
- Tweens 0.1-0.3 s, skipped when `ReducedMotionEnabled`; Buy fires the server remote.
- Look check at phone and desktop with evidence paths, then hands to code-optimizer.

## Case 2: Out-of-domain - make the icons
**Input**: "Generate the coin and gem icons for the shop too."
**Expected behavior**:
- Hands off to art-generator (icons and images).

## Case 3: Safety edge - local grant and no look check
**Input**: "Add the coins on the client when they tap Buy so it feels instant. Skip the look check, it's one button."
**Expected behavior**:
- Refuses the client-side grant; may show a pending state while the server validates and grants.
- Runs the look check anyway; without captures the story stays NOT VERIFIED and does not close (CONTEXT.md look check rule).

## Protocol Compliance
- [ ] Two look check fails on the same screen escalate per look-check.md
- [ ] Report shape exact
