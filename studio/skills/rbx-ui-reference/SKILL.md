---
name: rbx-ui-reference
description: "Roblox: analyze UI reference videos, X links, or screenshots and turn observed layout, interaction, and motion into a brief for an original game screen."
argument-hint: "<reference URL, clip, or ordered frames> [target screen]"
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, WebFetch, Write
---

# /rbx-ui-reference

## 0. Relevance check
Print `SKIPPED: no Roblox UI reference supplied` and stop if there is no source to inspect. A URL, an attached clip, or ordered screenshots qualify.

## 1. Collect visual evidence

- Identify the target screen, the player's goal, and any layout or behavior the developer wants to keep. When the target is unspecified, analyze the source and give patterns that transfer.
- Open supplied links in a browser when playback is available. Inspect visible video frames directly. Use the playback time or frame order for each observation. Use captions for attribution and context.
- Sample the resting UI, the action, the first visible change, the peak effect, and the settled state. Compare neighboring frames around a transition. With multiple clips, record each independently before comparing them.
- If playback fails, use visible posters or supplied stills and label the evidence. Request a clip or ordered screenshots for specific missing states. A caption alone cannot establish layout, motion, or timing.

## 2. Explain the design

- Record each useful moment as `Source / time | Player action | Visible change | What to adapt`. Use `action unclear` when the trigger is offscreen. Label inferred intent or mechanics explicitly. Mark timing, easing, sounds, and behavior `unverified` when the evidence cannot establish them.
- For layout, record visual priority, grouping, silhouettes, outlines, edge highlights, image and text roles, and coverage of the game view. For motion, record the order of dimming, movement, emphasis, and return of control.
- Read the timestamped worked examples in `{{RBX_HOME}}/library/roblox/ui-reference-videos.md`. When running directly from the repository, read `docs/roblox/ui-reference-videos.md`.

## 3. Make a screen brief

- Define the primary action, panel structure, and relevant states such as default, pressed, disabled, and reward. Specify which details make an element feel solid or interactive and where visual emphasis should go. Use the target game's layout, artwork, and labels. Draw original assets for a new project.
- When available, read the target game's UI notes and components. Use its theme and input flow. Respect phone safe areas and controls, protect the gameplay focal point, and describe a reduced-motion treatment. Present proposed timings as tuning values.
- List the exact phone and desktop states to capture in a look check. Use `{{RBX_HOME}}/library/roblox/ux-standards.md` and `{{RBX_HOME}}/docs/look-check.md` when installed.
- Return the brief in chat by default. If asked for a file in a game repo, save it under `.rbx-studio/reports/ui-reference-<screen>.md`. Implement UI only when separately requested.

## Report

- DONE: sources, coverage, timestamped observations, and the target screen brief.
- YOU DO: missing footage or a design choice only if it blocks a specific conclusion.
- RISKS: unresolved evidence or a concrete tradeoff, when present.
- NEXT: the screen or state to prototype and what to verify.
