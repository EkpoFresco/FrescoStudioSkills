--!strict
-- Snorbo's Brain Rock Mine: server game loop (prototype pass).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Economy = require(Shared:WaitForChild("Economy"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Data = require(script.Parent:WaitForChild("Data"))

-- remotes
local folder = Instance.new("Folder")
folder.Name = "Remotes"
local remotes: { [string]: RemoteEvent } = {}
for _, name in Remotes.Names do
	local r = Instance.new("RemoteEvent")
	r.Name = name
	r.Parent = folder
	remotes[name] = r
end
folder.Parent = ReplicatedStorage

local defsById: { [string]: Config.UpgradeDef } = {}
for _, def in Config.Upgrades do
	defsById[def.id] = def
end

local function boost(p: Data.Profile): number
	return if os.time() < p.BoostEnds then Config.Products.RockRush.multiplier else 1
end

local function snapshot(p: Data.Profile): Remotes.State
	local perSecond = Economy.perSecond(Config.Upgrades, p.Levels)
	return {
		rocks = p.Rocks,
		lifetime = p.Lifetime,
		perClick = Economy.perClick(Config.Upgrades, p.Levels, Config.BaseClick),
		perSecond = perSecond,
		income = perSecond * Economy.multiplier(p.BrainCells, Config.BrainCellBonus, boost(p)),
		brainCells = p.BrainCells,
		levels = p.Levels,
		boostEnds = p.BoostEnds,
	}
end

local function push(player: Player)
	local p = Data.get(player)
	if p then
		remotes.State:FireClient(player, snapshot(p))
	end
end

local function add(p: Data.Profile, amount: number)
	p.Rocks += amount
	p.Lifetime += amount
end

-- Per-player token buckets, cleared on PlayerRemoving.
local buckets: { [Player]: { [string]: { tokens: number, t: number } } } = {}

local function allow(player: Player, name: string): boolean
	local limit = Config.RateLimits[name]
	local mine = buckets[player]
	if not limit or not mine then
		return false
	end
	local now = os.clock()
	local b = mine[name]
	if not b then
		b = { tokens = limit.burst, t = now }
		mine[name] = b
	end
	b.tokens = math.min(limit.burst, b.tokens + (now - b.t) * limit.perSecond)
	b.t = now
	if b.tokens < 1 then
		return false
	end
	b.tokens -= 1
	return true
end

local function onPlayerAdded(player: Player)
	buckets[player] = {}
	local p = Data.load(player)
	if player.Parent ~= Players then
		-- left while the load yielded: release the session lock and drop the profile
		if p then
			Data.release(player)
		end
		return
	end
	if not p then
		player:Kick("Your save is busy on another server. Rejoin in a minute.")
		return
	end
	local away = os.time() - p.LastSeen
	local mult = Economy.multiplier(p.BrainCells, Config.BrainCellBonus, 1)
	local offline = Economy.offlineEarnings(
		Economy.perSecond(Config.Upgrades, p.Levels) * mult,
		away,
		Config.OfflineCapSeconds,
		Config.OfflineRate
	)
	if offline > 0 then
		add(p, offline)
	end
	push(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, existing in Players:GetPlayers() do
	task.spawn(onPlayerAdded, existing)
end

Players.PlayerRemoving:Connect(function(player)
	buckets[player] = nil
	Data.release(player)
end)

remotes.Mine.OnServerEvent:Connect(function(player)
	if not allow(player, "Mine") then
		return
	end
	local p = Data.get(player)
	if not p then
		return
	end
	local mult = Economy.multiplier(p.BrainCells, Config.BrainCellBonus, boost(p))
	add(p, Economy.perClick(Config.Upgrades, p.Levels, Config.BaseClick) * mult)
	push(player)
end)

remotes.BuyUpgrade.OnServerEvent:Connect(function(player, upgradeId: any, count: any)
	if not allow(player, "BuyUpgrade") then
		return
	end
	if typeof(upgradeId) ~= "string" or typeof(count) ~= "number" then
		return
	end
	if count ~= count or count < 1 or count > 100 or count % 1 ~= 0 then
		return
	end
	local def = defsById[upgradeId]
	local p = Data.get(player)
	if not def or not p then
		return
	end
	local owned = p.Levels[def.id] or 0
	local cost = Economy.bulkCost(def, owned, count)
	if p.Rocks < cost then
		return
	end
	p.Rocks -= cost
	p.Levels[def.id] = owned + count
	push(player)
end)

remotes.Rebirth.OnServerEvent:Connect(function(player)
	if not allow(player, "Rebirth") then
		return
	end
	local p = Data.get(player)
	if not p then
		return
	end
	local gain = Economy.rebirthGain(p.Lifetime, Config.RebirthRequirement)
	if gain <= p.BrainCells then
		return
	end
	p.BrainCells = gain
	p.Rocks = 0
	p.Levels = {}
	push(player)
end)

-- Receipts: the single handler. Grant, record PurchaseId in the same profile, save, then confirm.
MarketplaceService.ProcessReceipt = function(info)
	local player = Players:GetPlayerByUserId(info.PlayerId)
	local p = player and Data.get(player)
	if not player or not p then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local id = tostring(info.PurchaseId)
	if Data.hasPurchase(p, id) then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	if info.ProductId == Config.Products.RockRush.productId then
		p.BoostEnds = math.max(p.BoostEnds, os.time()) + Config.Products.RockRush.minutes * 60
	else
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	Data.recordPurchase(p, id)
	if not Data.save(player, false) then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	push(player)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Passive income tick. State is pushed on change (handlers above) and as a heartbeat for players
-- with passive income; the client interpolates rocks between pushes using State.income.
local sinceHeartbeat = 0
while true do
	local dt = task.wait(Config.TickSeconds)
	sinceHeartbeat += dt
	local beat = sinceHeartbeat >= Config.HeartbeatSeconds
	if beat then
		sinceHeartbeat = 0
	end
	for player, p in Data.all() do
		local perSecond = Economy.perSecond(Config.Upgrades, p.Levels)
		if perSecond > 0 then
			local mult = Economy.multiplier(p.BrainCells, Config.BrainCellBonus, boost(p))
			add(p, perSecond * mult * dt)
			if beat then
				push(player)
			end
		end
	end
end
