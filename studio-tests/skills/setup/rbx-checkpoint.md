# Skill Spec: /rbx-checkpoint
Category: setup · Source: `studio/skills/rbx-checkpoint/SKILL.md`

## Summary
Saves session state so work survives a crash, compaction, or cutoff. Gathers cheaply (branch, `git log --oneline -5`, `git status --short`, previous checkpoint, backlog statuses, this session's work), writes `.rbx-studio/checkpoint.md` from `{{RBX_HOME}}/templates/checkpoint.md`, logs unlogged decisions in `decisions.md`, lists Studio-only DataModel edits, and makes a local commit `chore(checkpoint): <one line>`.

## Static Assertions
- [ ] Frontmatter complete; description starts "Roblox"
- [ ] Relevance check prints `SKIPPED: checkpoint is current` when same commit, clean status, and no new decisions
- [ ] Missing `.rbx-studio/`: creates only `checkpoint.md` and `.gitignore` (`state/`) and suggests `/rbx-start`
- [ ] Checkpoint sections: goal, phase, done, in progress, next 3, open decisions, files touched
- [ ] Studio-only edits listed by DataModel path for `/rbx-resume` to verify with `script_read`
- [ ] Report uses DONE / YOU DO / NEXT with "resume any time with /rbx-resume"

## Fixture Defaults
Template project.yaml (`rigor: minimal`, `toolchain: hybrid`, `team_size: 1`), Studio MCP connected, git repo on `feat/shop-ui`.

## Case 1: Happy path - mid-story with Studio-only edits
**Fixture**: S-04 "Shop UI" is `doing`. `src/server/ShopService.luau` has an uncommitted edit (price lookup half done at line 58). MCP edits made to `StarterGui.ShopGui.Frame` (not in git). The session decided "read prices with GetProductInfoAsync" but did not log it.
**Expected**: 1. Gather. 2. Write checkpoint.md. 3. Append the decision to decisions.md. 4. Commit.
**Assertions**:
- [ ] In progress names `src/server/ShopService.luau:58`, what is half done, and the next edit
- [ ] Studio-only section lists `StarterGui.ShopGui.Frame`
- [ ] decisions.md gains the GetProductInfoAsync line
- [ ] Next 3 are concrete actions a fresh session can start without asking
- [ ] DONE shows the commit hash and NEXT is step 1 of Next 3

## Case 2: Relevance skip - checkpoint is current
**Fixture**: checkpoint.md references HEAD, `git status --short` is empty, decisions.md unchanged since.
**Assertions**:
- [ ] Prints `SKIPPED: checkpoint is current` and writes nothing

## Case 3: Edge - no .rbx-studio and not a git repo
**Fixture**: Folder with `src/server/Main.server.luau` only; no `.rbx-studio/`; `git rev-parse` fails. Note given: "spawn pads done".
**Assertions**:
- [ ] Creates only `.rbx-studio/checkpoint.md` and `.rbx-studio/.gitignore`
- [ ] Note "spawn pads done" appears in checkpoint.md
- [ ] DONE shows `commit: skipped (not a git repo)` and suggests `/rbx-start`

## Protocol Compliance
- [ ] Writes only `.rbx-studio/` (S1); no exploration beyond the Gather list
- [ ] Never pushes; a hook-blocked commit is skipped and the reason reported
- [ ] Ends with NEXT naming step 1 of Next 3
