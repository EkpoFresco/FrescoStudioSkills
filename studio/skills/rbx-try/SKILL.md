---
name: rbx-try
description: "Roblox: try a teammate's branch in Studio without merging. Throwaway git worktree + rojo serve, spec modules synced, a short what-changed and what-to-test list. list, <branch>, status, clean."
argument-hint: "[list | <branch> [--port N] [--open] | status | clean <branch|all>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, PowerShell
---

# /rbx-try

Try a teammate's branch in Studio without merging it or touching your files.

How it works: each branch gets its own throwaway copy (a git worktree) under `%USERPROFILE%\.rbx-try\<game>\<branch>`, and Rojo serves that copy to Studio. Saving in Studio there never changes the real game folder. It never commits, merges or pushes.

Tool: `{{RBX_HOME}}/tools/rbx-try.ps1`, run from the game folder with `powershell -NoProfile -ExecutionPolicy Bypass -File`.

## 0. Relevance check
- Not a git repo, or no `*.project.json`: the tool prints `SKIPPED: ...`; report it and stop. Suggest `/rbx-toolchain rojo` for a Studio-only game.
- No argument or `list`: run `list`, show the table, then stop. Rows marked `merged` need no try: `SKIPPED: <branch> is already in main`.
- `status` or `clean`: run that command, report, stop. `clean` discards anything saved inside the worktree; say so first.

## 1. Prep the branch
`rbx-try.ps1 prep <branch>` (partial names work if they match one branch). It fetches, creates or refreshes the worktree at the remote tip, and writes `try.project.json`: the game's project plus every `*.spec.luau` as `ReplicatedStorage.<Name>Spec`, so test suites need no copy and paste.
- "has saved changes" error: ask whether to discard them, then re-run with `-Reset`.
- Note ahead/behind main. Behind by commits that touch the same files means the merge needs care later; flag it.

## 2. What changed and what to test
Read the commit bodies and changed files (open the diff with `git diff origin/main...origin/<branch>` only where a commit body is vague). Write two short lists in plain player-facing words, no code names unless needed:
- **What changed**: max 4 bullets, about 12 words each. What the branch does to the game, not how.
- **Test**: max 6 bullets, each "X should happen" so it can be judged by eye in one Play. Include one line for the test suite (the game's own test UI if it has one, for example a Checks tab, else `require(game.ReplicatedStorage.<Name>Spec).Run()` in the command bar) with the count of new or changed `case("...")` lines in `*.spec.luau`, and one line for the main regression risk.
These two lists open the report, every time, before setup steps.

## 3. Serve
Before reporting, confirm `git status --short` in the game folder is empty and say so in the FILES line. Not empty: name the files and stop.
Start it in the background so the session stays free: `rbx-try.ps1 serve <branch> -Port <N>` with `run_in_background`. Default port 34872; if a `rojo serve` already runs, use 34873 and up. `--open` adds `-OpenStudio`, which opens the worktree's own place copy (prefers a TestLab place).
Wait for the `Rojo server listening` line in its output before telling the developer it is ready. Port in use or rojo missing: report the exact error and the fix (`rokit install`, or another port).

## 4. Switch or stop
- Another branch: stop the running serve (TaskStop), then step 1 for the next branch. Studio stays connected only after Rojo reconnects: Plugins > Rojo > Disconnect, then Connect.
- Done testing: stop the serve, leave the worktree for a quick retry, or `clean` it.
- Merging is never part of this skill. When the developer likes a branch, point at `/rbx-ship` or a PR merge on GitHub; that needs their approval.

## Report
Everything the developer needs goes in the final reply text, never only in tool output: the terminal shows tool output dimmed and collapsed, and it goes unread. Repeat any path, port, error or file-safety fact there.
Studio report shape only. No em dashes, no filler. WHAT CHANGED and TEST come first and stay that short. Always include the FILES line.
```
WHAT CHANGED (<branch>)
- <max 4 bullets, plain words>
TEST
- <max 6 bullets: "X should happen", one test-suite line, one regression line>
FILES
- game folder untouched (git status clean); only the throwaway worktree changed
DONE
- serving <branch> @ <hash> on localhost:<port> (<n> ahead, <m> behind main)
- worktree: <path>
YOU DO
1. Studio: open <place path> (throwaway copy) or your test place
2. Plugins > Rojo > Connect (localhost:<port>), then Play
3. Say "next <branch>" to switch, or "stop" when done
RISKS
- <behind main on the same files, or none>
NEXT
- /rbx-try <next branch> or /rbx-ship once a branch is approved
```
