# studio-tests

Quality checks for the rbx-studio payload: 28 skills and 18 agents.

| Command | What it does |
|---|---|
| `/skill-test static all` | Runs `node tools/studio-lint.js all`: structure, report shape, relevance check, write scope, approval gate, broken library refs, em dashes, engine names. |
| `/skill-test spec <name>` | Evaluates one spec in `skills/` or `agents/`. |
| `/skill-test category all` | Applies `quality-rubric.md` per category. |
| `/skill-test audit` | Coverage: every item catalogued with a spec (`node tools/gen-catalog.js --check`). |
| `/skill-improve <name>` | Test, fix, retest loop on one item. |

Other test scripts (repo `tools/`):
- `bash tools/test-hooks.sh` runs 25 hook fixtures through Git Bash and PowerShell (`RBX_PSH=powershell.exe` for Windows PowerShell 5.1).
- `pwsh -File tools/test-install.ps1 -Sandbox <dir>` round-trips the installer in a sandbox config dir.

What a pass proves: static and spec modes read files; they do not run the skill. Real behavior is checked by the dogfood run (see `dogfood/`).
