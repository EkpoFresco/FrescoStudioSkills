-- rbx-map Studio scan for MCP-only games (no files on disk). Run the whole file through the
-- Studio MCP tool execute_luau (datamodel Edit). It returns JSON: [{path, className, source}].
-- Save the returned text to .rbx-studio/state/studio-scan.json, then:
--   node "<RBX_HOME>/tools/rbx-map.js" --from-json .rbx-studio/state/studio-scan.json
-- Skips CoreGui, Packages folders, and scripts over 200k characters. Yields every 200 scripts.
local HttpService = game:GetService("HttpService")
local roots = {
	game:GetService("ServerScriptService"),
	game:GetService("ServerStorage"),
	game:GetService("ReplicatedStorage"),
	game:GetService("ReplicatedFirst"),
	game:GetService("StarterPlayer"),
	game:GetService("StarterGui"),
	game:GetService("StarterPack"),
	workspace,
}
local out = {}
local seen = 0
for _, root in roots do
	for _, inst in root:GetDescendants() do
		if inst:IsA("LuaSourceContainer") and not inst:FindFirstAncestor("Packages") then
			local ok, src = pcall(function()
				return (inst :: any).Source
			end)
			if ok and type(src) == "string" and #src < 200000 then
				table.insert(out, { path = inst:GetFullName(), className = inst.ClassName, source = src })
			end
			seen += 1
			if seen % 200 == 0 then
				task.wait()
			end
		end
	end
end
return HttpService:JSONEncode(out)
