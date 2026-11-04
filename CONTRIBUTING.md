# Contributing

1. Branch: `<initials>/<type>-<slug>`.
2. Change `studio/` (payload) or `docs/roblox/` (facts need a source URL and date checked; unverifiable means `UNVERIFIED` + how to verify).
3. Run: `node tools/studio-lint.js all`, `node tools/gen-catalog.js --check`, and `bash tools/test-hooks.sh` if you touched hooks, `pwsh -File tools/test-install.ps1 -Sandbox <dir>` if you touched the installer. All green.
4. Add or update the spec in `studio-tests/` for any new or changed skill or agent.
5. Voice: result first, short lines, no em dashes, no filler. Reports: DONE / YOU DO / RISKS / NEXT.
6. Open a PR when the lead approves. Body: what, why, test output.
