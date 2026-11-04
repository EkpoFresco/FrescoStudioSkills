---
name: rbx-remote-audit
description: "Roblox: audit and attack every remote and prompt for trust, validation, rate limits. Use before launch or on exploit reports."
argument-hint: "[all | <remote or file>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent
---

# /rbx-remote-audit

## 0. Relevance check
No remotes, prompts, or click detectors anywhere (Grep `RemoteEvent|RemoteFunction|OnServerEvent|OnServerInvoke|ProximityPrompt|ClickDetector`, or `search_game_tree` by instance_type): `SKIPPED: no client-to-server surface`.

## 1. Inventory
Start from the Remotes section of `.rbx-studio/map.md` (fired at -> handled at); rebuild it with `node "{{RBX_HOME}}/tools/rbx-map.js"` if stale. List every remote and handler with path:line. State the count. Note the wrapper (if any) the project uses for validation; read it once so wrapped handlers are judged correctly.

## 2. Static review
For each handler: args and their checks in order (type, `math.isfinite`, range, ownership, distance, cooldown, rate limit), what state it changes, payload size estimate, `InvokeClient` use, client-trusted values (price, damage, position). Use `{{RBX_HOME}}/library/roblox/implementation.md` Networking + Exploit prevention as the checklist.

## 3. Attack (Studio MCP available)
Delegate to `exploit-tester`: in play mode, fire each money, item, or progress remote from the Client datamodel with bad args (wrong types, NaN, inf, negative, huge, other player ids), spam (1000 calls), and races; read Server datamodel state after each. Record PROVEN or PLAUSIBLE. No MCP: static only, mark attack results NOT ASSESSED.

## 4. Rank and fix plan
BLOCKER (currency, items, data, other players, server crash), MAJOR (unfair advantage, grief), MINOR. Each with the exact check to add and where. Offer `/rbx-build fix-remotes`; do not fix here unless a fix is one line.

## 5. Save
`.rbx-studio/reports/remote-audit-<date>.md`.

## Report
Studio report shape only. No em dashes, no filler.
```
DONE
- remotes: <n> audited; BLOCKER <n>, MAJOR <n>, MINOR <n> (.rbx-studio/reports/remote-audit-<date>.md)
- worst: <remote> <attack> -> <result>
YOU DO
1. <exact step>
RISKS
- <only if real>
NEXT
- /rbx-build fix-remotes
```
