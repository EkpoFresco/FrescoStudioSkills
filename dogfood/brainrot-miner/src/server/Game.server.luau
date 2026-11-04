--!strict
-- Snorbo's Brain Rock Mine: server game loop (prototype pass).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Economy = require(Shared:WaitForChild("Economy"))
local Data = require(script.Parent:WaitForChild("Data"))

-- remotes
local folder = Instance.new("Folder")
folder.Name = "Remotes"
local remotes: { [string]: RemoteEvent } = {}
for _, name in { "Mine", "BuyUpgrade", "Rebirth", "State" } do
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

local function snapshot(p: Data.Profile)
	return {
		rocks = p.Rocks,
		lifetime = p.Lifetime,
		perClick = Economy.perClick(Config.Upgrades, p.Levels, Config.BaseClick),
		perSecond = Economy.perSecond(Config.Upgrades, p.Levels),
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

Players.PlayerAdded:Connect(function(player)
	local p = Data.load(player)
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
end)

Players.PlayerRemoving:Connect(function(player)
	Data.release(player)
end)

remotes.Mine.OnServerEvent:Connect(function(player)
	local p = Data.get(player)
	if not p then
		return
	end
	local mult = Economy.multiplier(p.BrainCells, Config.BrainCellBonus, boost(p))
	add(p, Economy.perClick(Config.Upgrades, p.Levels, Config.BaseClick) * mult)
	push(player)
end)

remotes.BuyUpgrade.OnServerEvent:Connect(function(player, upgradeId: any, count: any)
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

-- passive income tick
while true do
	task.wait(Config.TickSeconds)
	for player, p in Data.all() do
		local mult = Economy.multiplier(p.BrainCells, Config.BrainCellBonus, boost(p))
		add(p, Economy.perSecond(Config.Upgrades, p.Levels) * mult * Config.TickSeconds)
		push(player)
	end
end
