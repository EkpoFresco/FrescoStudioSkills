# Security

- Report a vulnerability in the studio (hooks, installer, push gate bypass) privately to the repo owner, not in a public issue.
- The studio never stores credentials. Hooks read only the hook JSON on stdin and files inside the game folder, and write only `.rbx-studio/`.
- The push gate is a guardrail, not a sandbox. Keep normal Claude Code permission prompts on for anything outward-facing.
- Exploit testing in `/rbx-remote-audit` runs only in Studio or test places you own.
