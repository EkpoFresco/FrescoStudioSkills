--!nocheck
-- Curve sim for Snorbo's Brain Rock Mine. Greedy player: buys best payback each second.
-- Run: lune run .rbx-studio/reports/curve.luau   (from the game folder)
local defs = {
	{ id = "bonkPick", base = 10, g = 1.15, click = 1 },
	{ id = "snorblet", base = 50, g = 1.15, sec = 1 },
	{ id = "brainDrill", base = 600, g = 1.15, sec = 8 },
	{ id = "mushRocket", base = 7000, g = 1.15, sec = 47 },
	{ id = "gooBase", base = 80000, g = 1.15, sec = 260 },
}
local TAPS_PER_SEC = 3 -- active tapping, phone
local REBIRTH_REQ = 1e6
local HORIZON = 3600

local owned, rocks, life, t = {}, 0, 0, 0
for _, d in defs do owned[d.id] = 0 end
local function cost(d) return math.floor(d.base * d.g ^ owned[d.id]) end
local function perClick() local c = 1 for _, d in defs do if d.click then c += d.click * owned[d.id] end end return c end
local function perSec() local s = 0 for _, d in defs do if d.sec then s += d.sec * owned[d.id] end end return s end

local milestones = {
	{ "first Bonk Pick", function() return owned.bonkPick >= 1 end },
	{ "first Snorblet", function() return owned.snorblet >= 1 end },
	{ "10 Snorblets", function() return owned.snorblet >= 10 end },
	{ "first Brain Drill", function() return owned.brainDrill >= 1 end },
	{ "10 Brain Drills", function() return owned.brainDrill >= 10 end },
	{ "first Mush Rocket", function() return owned.mushRocket >= 1 end },
	{ "10 Mush Rockets", function() return owned.mushRocket >= 10 end },
	{ "first Goo Moon Base", function() return owned.gooBase >= 1 end },
	{ "10 Goo Moon Bases", function() return owned.gooBase >= 10 end },
	{ "rebirth ready (1M lifetime)", function() return life >= REBIRTH_REQ end },
}
local hit = {}
local function check()
	for i, m in milestones do
		if not hit[i] and m[2]() then hit[i] = t end
	end
end

while t < HORIZON do
	t += 1
	local gain = perClick() * TAPS_PER_SEC + perSec()
	rocks += gain
	life += gain
	-- buy loop: best (cost / gain) payback, only if affordable
	while true do
		local best, bestScore
		for _, d in defs do
			local c = cost(d)
			if c <= rocks then
				local add = (d.click and d.click * TAPS_PER_SEC or d.sec)
				local score = c / add
				if not bestScore or score < bestScore then best, bestScore = d, score end
			end
		end
		if not best then break end
		rocks -= cost(best)
		owned[best.id] += 1
	end
	check()
end

print("MILESTONES (seconds, mm:ss)")
local prev
for i, m in milestones do
	local s = hit[i]
	if s then
		local flag = ""
		if prev and prev > 0 and s / prev > 2 then flag ..= " [GAP>2x]" end
		if i <= 3 and s < 10 then flag ..= " [<10s]" end
		if s > 1800 and i <= 6 then flag ..= " [>30min early]" end
		print(string.format("%2d %-30s %5ds  %d:%02d%s", i, m[1], s, s // 60, s % 60, flag))
		prev = s
	else
		print(string.format("%2d %-30s not reached in %ds", i, m[1], HORIZON))
	end
end
print(string.format("After 1h: lifetime %.3e, perSec %d, perClick %d", life, perSec(), perClick()))
for _, d in defs do print(d.id, owned[d.id]) end
