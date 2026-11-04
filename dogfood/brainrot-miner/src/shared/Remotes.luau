--!strict
-- Remote contract. Server creates the instances; clients wait for them.
-- Mine (C->S): no args. BuyUpgrade (C->S): upgradeId: string, count: number. Rebirth (C->S): no args.
-- State (S->C): snapshot table { rocks, lifetime, perClick, perSecond, brainCells, levels, boostEnds }.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type State = {
	rocks: number,
	lifetime: number,
	perClick: number,
	perSecond: number,
	brainCells: number,
	levels: { [string]: number },
	boostEnds: number,
}

local Remotes = {}
Remotes.Names = { "Mine", "BuyUpgrade", "Rebirth", "State" }

function Remotes.folder(): Folder
	return ReplicatedStorage:WaitForChild("Remotes") :: Folder
end

function Remotes.get(name: string): RemoteEvent
	return Remotes.folder():WaitForChild(name) :: RemoteEvent
end

return Remotes
