# Upgrading

## Your machine
`.\install.ps1 -Update` (or `./install.sh --update`) in your clone: pulls with `--ff-only`, reinstalls, removes files dropped from the payload, keeps your settings. Restart Claude Code. Sessions print "Studio update available" when the clone is newer than the installed copy.

## Your games
`.rbx-studio/project.yaml` has `schema_version` and `studio_version`. Missing keys use defaults (`studio/rbx-studio/docs/config.md`), so old projects keep working. Run `/rbx-start config studio_version=<new>` after reading the changelog when a release notes a config change.

## From Claude Code Game Studios (upstream)
Not an in-place upgrade: this fork removes the engine template model. Install rbx-studio globally, then run `/rbx-start` in each Roblox game. Upstream history stays in git (`git log upstream/main`).
