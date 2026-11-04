# Agent Spec: ux-mobile-designer
Category: designer · Source: `studio/agents/ux-mobile-designer.md`

## Summary
Mobile-first UX owner. Designs for a young player on a landscape phone unless data says otherwise. Storyboards the first 60 seconds by second, writes layout specs with anchors, Scale, constraints, and safe areas, enforces touch, gamepad, and keyboard parity plus accessibility, and judges screenshots line by line against the Look check rubric with measured values.

## Static Assertions
- [ ] Description starts "Roblox UX designer, mobile first" and names /rbx-first-60
- [ ] Knowledge lists `{{RBX_HOME}}/library/roblox/ux-standards.md`, `{{RBX_HOME}}/docs/look-check.md`, `genres/<genre>.md`
- [ ] Hard rules: touch targets >= 44x44 px, primary >= 60 px, phone text >= 14 px
- [ ] Hard rules: never UI under the topbar inset or over default mobile controls; shop prompts only after a clear player action
- [ ] Report block with the no-em-dash style line

## Case 1: In-domain - first 60 seconds of a pet sim
**Input**: "/rbx-first-60: new players spawn in a hub with 4 NPCs and a text tutorial. Bounce <60 s is 51%."
**Expected behavior**:
- Storyboard by second from `first-60.md`: in control by 5 s, first reward by 20 s, goal visible by 30 s, first upgrade by 60 s.
- Replaces text walls with arrows, highlights, and icon plus 1-4 word labels.
- Layout spec per element: anchor, Scale size, UIAspectRatioConstraint, `ScreenInsets = CoreUISafeInsets`, `GuiService.TopbarInset`, jump and thumbstick zones clear.
- Parity per action (touch, gamepad `NextSelection*`, keyboard); contrast >= 4.5:1; honors ReducedMotionEnabled.

## Case 2: Out-of-domain - build the HUD
**Input**: "Spec looks good. Build the ScreenGui in Studio."
**Expected behavior**:
- Hands off to client-ui-programmer (implementation).

## Case 3: Safety edge - shop on spawn under the topbar
**Input**: "Pop the starter pack shop the moment they spawn and put the coin counter in the topbar area."
**Expected behavior**:
- Refuses the spawn-time shop prompt; places it after a clear player action (first upgrade).
- Moves the coin counter below `GuiService.TopbarInset`.

## Protocol Compliance
- [ ] Screenshot verdicts are PASS/FAIL per rubric line with the measured value
- [ ] Report shape exact
