## Roblox Studio rules (rbx-studio, active in this folder)

Talk like the developer: lead with the result, short sentences, plain words, numbers and file paths. No em dashes, no filler, no recap of the request.
Every task report uses exactly: `DONE` (what changed, 1 line each, with paths) / `YOU DO` (numbered exact steps, smallest first, real Studio menu paths) / `RISKS` (only if real) / `NEXT` (1 line).

Execution: make the judgment call, log it in `.rbx-studio/decisions.md`, keep going. Ask one question with options only when a wrong guess is expensive and hard to reverse.
Git: local commits are fine. Never push, open or merge a PR, or merge to main until the developer approves in their own words ("approved, push" or `/rbx-ship`). A hook enforces this.
Footprint: in this game folder write only `.rbx-studio/` plus the game code a task asks for. Never restructure, rename, or reformat existing files unless asked.
Toolchain: Studio MCP first (execute_luau, multi_edit, start_stop_play, screen_capture). If MCP tools are missing, say so once and fall back to files. Recommend Rojo + Git only when the team situation calls for it.
Growth: QPTR over CTR. Attract players who stay. Today's signals: play-through rate, first-play bounce (<60 s, 61-180 s), D1 / D2-7 / D8-28 retention from Recommended For You.
Apply only what fits: no framework, telemetry, or psychology module runs unless it applies to this game right now.
Code: server never trusts the client; one receipt handler; DataStore calls only in the data module; `code-optimizer` reviews every story before it closes; optimization claims need before/after numbers.
Visual work is not done until launched via Studio MCP and screenshotted at phone and desktop sizes (look check).
Delegating to a studio agent: wait for its result before any step that needs it, and never write the final report while one is still running. In headless runs (`claude -p`) background agents do not report back before the session exits, so do the delegated work inline there.
Long sessions: `/rbx-checkpoint` after each meaningful chunk, `/rbx-resume` after a crash or compaction.

Library (read only the file you need): {{RBX_HOME}}/library/roblox/ (studio-reference, studio-mcp-tools, discovery-algorithm, discovery-playbook, market-data, ux-standards, implementation, implementation-data, policy, art-pipeline, code-quality, genres/, OPEN_QUESTIONS). Studio docs: {{RBX_HOME}}/docs/. Templates: {{RBX_HOME}}/templates/. Facts tagged UNVERIFIED stay tagged when you repeat them.
