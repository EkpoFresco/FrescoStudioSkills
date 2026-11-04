## rbx-studio rules (active in this folder)
Voice: result first, short lines, numbers and paths, no em dashes, no filler. Every report: `DONE` / `YOU DO` (numbered, exact menu paths) / `RISKS` (only if real) / `NEXT` (1 line).
Decide and log in `.rbx-studio/decisions.md`; ask one question with options only when a wrong guess is expensive and hard to reverse.
Git: local commits fine. Push, PR, merge to main only after the developer approves in their own words ("approved, push" or `/rbx-ship`); a hook enforces it.
Footprint: write only `.rbx-studio/` plus code the task asks for; never restructure or reformat existing files.
Toolchain: Studio MCP first; say once if it is missing and fall back to files. Hybrid/Rojo: sync Studio after file edits.
Growth: QPTR over CTR, measured by PTR, first-play bounce (<60 s, 61-180 s), D1 / D2-7 / D8-28 from Recommended For You.
Code: server never trusts the client; one receipt handler; DataStore calls only in the data module; code-optimizer closes every story; optimization claims need before/after numbers. Visual work needs a look check (phone + desktop).
Token rules: (1) start from `.rbx-studio/map.md` (rebuild: `node "{{RBX_HOME}}/tools/rbx-map.js"`) and open only the scripts the task needs, Grep with line numbers then Read ranges; (2) never Read a library file whole: `node "{{RBX_HOME}}/tools/lib.js" <file>` gives the TL;DR and section list, `lib.js <file> "<section>"` one section, `lib.js --grep <regex>` a fact; (3) briefs to agents ask for 15 lines or fewer; (4) read old reports' first 20 lines only.
Agents: wait for a delegated result before any step that needs it; in headless runs (`claude -p`) do delegated work inline.
User-only skills (start, toolchain, genre, loop, plan, monetize, thumbnail, art, telemetry, teardown, metrics, issues, handoff, ship, launch, update, map) are hidden from you: when a step needs one, read `~/.claude/skills/rbx-<name>/SKILL.md` and follow it, except `rbx-ship`, which only the developer starts.
Long work: `/rbx-checkpoint` after each chunk (and update its Done/Next when you finish an item it lists); `/rbx-resume` after a crash or compaction.
Library: {{RBX_HOME}}/library/roblox/ (index: `node "{{RBX_HOME}}/tools/lib.js"`). Docs: {{RBX_HOME}}/docs/. Templates: {{RBX_HOME}}/templates/. Keep UNVERIFIED tags when repeating facts.
