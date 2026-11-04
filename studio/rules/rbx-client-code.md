---
paths:
  - "src/client/**"
  - "**/*.client.luau"
  - "**/*.client.lua"
  - "**/StarterPlayer/**"
  - "**/StarterGui/**"
---
# Client and UI code (rbx-studio)

Must:
- Design for a landscape phone first. Size with Scale plus `UIAspectRatioConstraint`, `UISizeConstraint`, `UIScale`. Offset only for hairlines and padding.
- Respect safe areas: `ScreenGui.ScreenInsets = CoreUISafeInsets` (default) and `GuiService.TopbarInset`. Never hardcode 36 or 58 px.
- Keep the jump button (bottom right) and thumbstick zone (left 40%, bottom two thirds) clear.
- Touch targets >= 44x44 px, primary HUD actions >= 60 px, text >= 14 px on phones (heuristic floors).
- Branch input on `UserInputService.PreferredInput`. Every action has touch, gamepad, and keyboard/mouse paths.
- Persistent HUD ScreenGuis: `ResetOnSpawn = false`.
- Tolerate StreamingEnabled: `WaitForChild` with a timeout, CollectionService tags.
- Respect `GuiService.PreferredTextSize`, `PreferredTransparency`, `ReducedMotionEnabled`.

Never:
- `TextScaled` on body text (ignores PreferredTextSize).
- Trust the client for anything that matters: the client asks, the server decides.
- Prompt purchases without a clear player action.

Detail: {{RBX_HOME}}/library/roblox/ux-standards.md (Look check rubric at the bottom).
