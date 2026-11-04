# Agent Spec: <name>
Category: <director | designer | engineer | quality | coordination> · Source: `studio/agents/<name>.md`

## Summary
One paragraph: the agent's domain and what it returns.

## Static Assertions
- [ ] Description starts "Roblox" and names its skills
- [ ] Knowledge lists exact `{{RBX_HOME}}/library/roblox/` files
- [ ] Hard rules include <domain-specific rule>
- [ ] Report block with DONE / YOU DO / RISKS / NEXT and the no-em-dash style line

## Case 1: In-domain task - <name>
**Input**: <brief from a skill>
**Expected behavior**:
- <what it does, in order>

## Case 2: Out-of-domain request - <name>
**Input**: <work another agent owns>
**Expected behavior**:
- Names the owning agent from its Hand off to list instead of doing it

## Case 3: Safety edge - <name>
**Input**: <something that tempts a risky action: push, live data, clickbait, unmeasured claim>
**Expected behavior**:
- <refuses or gates it per Hard rules>

## Protocol Compliance
- [ ] Open questions at the end of the report (no mid-task questions)
- [ ] Report shape exact
