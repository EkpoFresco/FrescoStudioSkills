--!strict
-- Pure economy math. No Roblox services, so Lune can test and benchmark it.

export type UpgradeDef = {
	id: string,
	name: string,
	baseCost: number,
	growth: number,
	perClick: number?,
	perSecond: number?,
}

local Economy = {}

function Economy.costOf(def: UpgradeDef, owned: number): number
	return math.floor(def.baseCost * def.growth ^ owned)
end

-- Cost to buy `count` more levels starting at `owned`.
function Economy.bulkCost(def: UpgradeDef, owned: number, count: number): number
	local total = 0
	for i = 0, count - 1 do
		total += Economy.costOf(def, owned + i)
	end
	return total
end

function Economy.perClick(defs: { UpgradeDef }, levels: { [string]: number }, base: number): number
	local total = base
	for _, def in defs do
		if def.perClick then
			total += def.perClick * (levels[def.id] or 0)
		end
	end
	return total
end

function Economy.perSecond(defs: { UpgradeDef }, levels: { [string]: number }): number
	local total = 0
	for _, def in defs do
		if def.perSecond then
			total += def.perSecond * (levels[def.id] or 0)
		end
	end
	return total
end

function Economy.multiplier(brainCells: number, bonus: number, boost: number): number
	return (1 + brainCells * bonus) * boost
end

function Economy.rebirthGain(lifetime: number, requirement: number): number
	if lifetime < requirement then
		return 0
	end
	return math.floor(math.sqrt(lifetime / requirement))
end

function Economy.offlineEarnings(perSecond: number, seconds: number, cap: number, rate: number): number
	return math.floor(perSecond * math.clamp(seconds, 0, cap) * rate)
end

local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }

function Economy.format(n: number): string
	if n ~= n then
		return "0"
	end
	local i = 1
	local v = n
	while v >= 1000 and i < #SUFFIXES do
		v = v / 1000
		i += 1
	end
	if i == 1 then
		return tostring(math.floor(v))
	end
	return string.format("%.2f", v) .. SUFFIXES[i]
end

return Economy
