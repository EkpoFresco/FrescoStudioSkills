# Friction log (Phase 5)

Every friction point hit while testing, and what was done. Newest at the bottom.

| # | Where | Friction | Fix | Status |
|---|---|---|---|---|
| F-01 | Research | Usage limit hit mid-research; 11 of 13 agents stopped before writing. | Resumed each with a capped budget (8 fetches) and "write now, tag UNVERIFIED". All files landed. | fixed |
| F-02 | Install research | claude-code-guide agent has no Write tool; returned the doc as text. | Saved its output to `docs/install-research.md` by hand. | fixed |
| F-03 | Shell | Bash heredocs with apostrophes failed in this harness; nothing written. | Used the Write tool for prose files. | worked around (harness only) |
| F-04 | Hooks | On this machine, `bash` from PowerShell is the WSL launcher, not Git Bash. | Hook entries pin `shell: bash` / `shell: powershell` (D-010, D-019). | fixed |
| F-05 | Installer | `Get-FileHash` failed to autoload in Windows PowerShell 5.1 started from a pwsh environment. | .NET SHA256 helper (D-018). | fixed |
| F-06 | Installer | Uninstall left empty `skills/rbx-*` folders; file-only snapshot test missed it. | Prune emptied parents; test compares directories too; restore recreates parent dirs. | fixed |
| F-07 | Permissions | The repo's own deny list blocked `rm -rf` and writing under `%TEMP%` during tests. | Tests use fresh sandbox dirs in the session scratchpad. Deny list kept (it works). | by design |
| F-08 | Lint | 4 skills had relevance checks that never actually skip; 1 diagnosis skill had no verdict words; 3 skills had no doc pointers. | Fixed the skills; linter enforces it now. | fixed |
| F-09 | Specs | Spec writers found 8 agent and 8 skill inconsistencies (missing `allowed-tools`, an un-gated publish in hotfix, undefined branches, D7/D30 vs D2-7/D8-28). | All 16 fixed in the payload. | fixed |
| F-10 | Toolchain | Rokit resolves tools per project; tools "missing" in a folder without `rokit.toml`. | Dogfood got a pinned `rokit.toml`; `/rbx-toolchain` already writes one. | fixed |
| F-11 | Studio | Launching Studio triggered an auto-update; `mcp.bat` moved to the new version folder. | Waited for the installer; MCP worked after. Skills never hardcode the version path. | fixed |
| F-12 | Claude Code | Claude Code's own npm auto-update to 2.1.318 failed (`update_apply_native_binary_missing`): new `claude` sessions fail to start on this machine. | Tests call the native binary directly. Developer fix in the final report (re-run the package postinstall). | environment, reported |
| F-13 | MCP config | `--mcp-config` with a file path from Git Bash was rejected as invalid JSON. | Pass the JSON inline. Documented in `docs/install.md`. | worked around |
| F-14 | /rbx-start | Delegated conventions to luau-architect even for 6 files (slow, costly); team size counted parent-repo authors when the game sits in a subfolder. | Inline when 12 scripts or fewer; contributor count scoped to the folder. | fixed |
| F-15 | Studio MCP | Studio update added 5 MCP tools and 3 MCP skills. | Regenerated `studio-mcp-tools.md`; wired `rbx-instrument-analytics`, `rbx-configs-experimentation`, `rbx-network-simulator` into telemetry, perf, playtest. | fixed |
| F-16 | Scope | Global agents and skills are listed in non-Roblox sessions too (Claude Code has no per-folder scoping for them). Hooks and rules are silent there. | Descriptions start with "Roblox" so routing stays correct; cost is about 2k tokens of listing. | known limit |
| F-17 | Headless runs | In `claude -p`, skills that delegated to a background agent ended the session before the agent reported (build close review, art). | CONTEXT.md: wait for delegated results; inline the work in headless runs. | fixed |
| F-18 | Look check | Studio's viewport was 740 px wide, narrower than the iPhone 13 emulator frame, so the right edge of the phone capture is Studio chrome cutting the frame. | look-check.md: maximize Studio or widen the viewport before phone captures; judge only inside the device frame. | fixed |
| F-19 | Hybrid sync | Several dogfood sessions found Studio running stale copies of edited `src/` modules (no `rojo serve` running). | /rbx-build: sync Studio after file edits (rojo serve or `multi_edit` + `script_read`); runs against stale copies are NOT VERIFIED. | fixed |
| F-20 | Skills doing agent work inline | In headless runs several skills did agent work inline (correct after F-17), so agent prompts were exercised less than skill prompts. | Agent behavior covered by the 18 agent specs; interactive dogfood still recommended. | known limit |
| F-21 | /rbx-pickup | Pickup repeated a stale checkpoint (said optimize target 3 not started; it was committed). | CONTEXT.md: finishing a checkpointed item updates the checkpoint; pickup trusts git over checkpoint and names the stale file. | fixed |
