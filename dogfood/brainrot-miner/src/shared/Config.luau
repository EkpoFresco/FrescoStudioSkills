--!strict
-- Snorbo's Brain Rock Mine: tuning. All names are original placeholders.

export type UpgradeDef = {
	id: string,
	name: string,
	baseCost: number,
	growth: number,
	perClick: number?,
	perSecond: number?,
}

local Config = {}

Config.Upgrades = {
	{ id = "bonkPick", name = "Bonk Pick", baseCost = 10, growth = 1.15, perClick = 1 },
	{ id = "snorblet", name = "Snorblet Helper", baseCost = 50, growth = 1.15, perSecond = 1 },
	{ id = "brainDrill", name = "Brain Drill", baseCost = 600, growth = 1.15, perSecond = 8 },
	{ id = "mushRocket", name = "Mush Rocket", baseCost = 7000, growth = 1.15, perSecond = 47 },
	{ id = "gooBase", name = "Goo Moon Base", baseCost = 80000, growth = 1.15, perSecond = 260 },
} :: { UpgradeDef }

Config.BaseClick = 1
Config.RebirthRequirement = 1e6 -- lifetime rocks
Config.BrainCellBonus = 0.10 -- +10% income per brain cell
Config.OfflineCapSeconds = 2 * 60 * 60
Config.OfflineRate = 0.5
Config.TickSeconds = 0.1

Config.Products = {
	RockRush = { productId = 0, minutes = 10, multiplier = 2 }, -- productId 0 = not created yet
}

return Config
