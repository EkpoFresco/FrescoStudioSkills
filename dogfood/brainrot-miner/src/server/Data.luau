--!strict
-- Data module: the only place that touches DataStoreService.
-- Session lock via UpdateAsync (lock = JobId + timestamp). In Studio without API access, falls back to memory.
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

export type Profile = {
	Version: number,
	Rocks: number,
	Lifetime: number,
	BrainCells: number,
	Levels: { [string]: number },
	PurchaseHistory: { string },
	BoostEnds: number,
	LastSeen: number,
}

local VERSION = 1
local LOCK_SECONDS = 180
local KEY_PREFIX = if RunService:IsStudio() then "Test_User_" else "User_"

local Data = {}
local profiles: { [Player]: Profile } = {}
local store: DataStore? = nil
local ok = pcall(function()
	store = DataStoreService:GetDataStore("PlayerData_v1")
end)
if not ok then
	store = nil
end

local function template(): Profile
	return {
		Version = VERSION,
		Rocks = 0,
		Lifetime = 0,
		BrainCells = 0,
		Levels = {},
		PurchaseHistory = {},
		BoostEnds = 0,
		LastSeen = os.time(),
	}
end

local function reconcile(raw: any): Profile
	local p = template()
	if type(raw) == "table" then
		for k, v in raw do
			(p :: any)[k] = v -- keep unknown keys
		end
	end
	p.Version = VERSION
	return p
end

function Data.load(player: Player): Profile?
	if not store then
		local p = template()
		profiles[player] = p
		return p
	end
	local key = KEY_PREFIX .. player.UserId
	local result: Profile? = nil
	for attempt = 1, 3 do
		local success, err = pcall(function()
			(store :: DataStore):UpdateAsync(key, function(old: any)
				if
					type(old) == "table"
					and old._lock
					and old._lock.job ~= game.JobId
					and os.time() - old._lock.t < LOCK_SECONDS
				then
					return nil -- locked by another server
				end
				local p = reconcile(old);
				(p :: any)._lock = { job = game.JobId, t = os.time() }
				result = p
				return p
			end)
		end)
		if success and result then
			break
		end
		warn("Data.load attempt", attempt, err)
		task.wait(2 ^ attempt)
	end
	if result then
		profiles[player] = result
	end
	return result
end

function Data.get(player: Player): Profile?
	return profiles[player]
end

function Data.save(player: Player, release: boolean): boolean
	local p = profiles[player]
	if not p then
		return false
	end
	p.LastSeen = os.time()
	if not store then
		return true
	end
	local key = KEY_PREFIX .. player.UserId
	local success = pcall(function()
		(store :: DataStore):UpdateAsync(key, function(old: any)
			if type(old) == "table" and old._lock and old._lock.job ~= game.JobId then
				return nil -- another server owns it now
			end
			local copy = table.clone(p) :: any
			copy._lock = if release then nil else { job = game.JobId, t = os.time() }
			return copy
		end)
	end)
	return success
end

function Data.release(player: Player)
	Data.save(player, true)
	profiles[player] = nil
end

-- Purchase idempotency: true if this purchase id was already granted.
function Data.hasPurchase(p: Profile, purchaseId: string): boolean
	return table.find(p.PurchaseHistory, purchaseId) ~= nil
end

function Data.recordPurchase(p: Profile, purchaseId: string)
	table.insert(p.PurchaseHistory, purchaseId)
end

function Data.all(): { [Player]: Profile }
	return profiles
end

-- Autosave every 60 s (shorter than LOCK_SECONDS) and on shutdown.
task.spawn(function()
	while true do
		task.wait(60)
		for player in profiles do
			Data.save(player, false)
		end
	end
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		Data.release(player)
	end
end)

return Data
