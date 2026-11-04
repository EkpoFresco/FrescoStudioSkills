-- Lune tests + micro-benchmark for src/shared/Economy.luau.  Run: lune run tests/economy.spec.luau
local Economy = require("../src/shared/Economy")

local pick = { id = "bonkPick", name = "Bonk Pick", baseCost = 10, growth = 1.15, perClick = 1 }
local helper = { id = "snorblet", name = "Snorblet", baseCost = 50, growth = 1.15, perSecond = 1 }

local passed, failed = 0, 0
local function eq(name: string, got: any, want: any)
	if got == want then
		passed += 1
	else
		failed += 1
		print(`FAIL {name}: got {got}, want {want}`)
	end
end

eq("costOf 0", Economy.costOf(pick, 0), 10)
eq("costOf 1", Economy.costOf(pick, 1), 11)
eq("bulk 1 = costOf", Economy.bulkCost(pick, 5, 1), Economy.costOf(pick, 5))
local sum = 0
for i = 0, 9 do
	sum += Economy.costOf(pick, 3 + i)
end
eq("bulk 10 = sum of costOf", Economy.bulkCost(pick, 3, 10), sum)
eq("perClick base", Economy.perClick({ pick }, {}, 1), 1)
eq("perClick 3 picks", Economy.perClick({ pick }, { bonkPick = 3 }, 1), 4)
eq("perSecond", Economy.perSecond({ pick, helper }, { snorblet = 5 }), 5)
eq("rebirth below", Economy.rebirthGain(5e5, 1e6), 0)
eq("rebirth 4M", Economy.rebirthGain(4e6, 1e6), 2)
eq("offline capped", Economy.offlineEarnings(10, 99999, 7200, 0.5), 36000)
eq("format small", Economy.format(999), "999")
eq("format K", Economy.format(1500), "1.50K")
eq("format M", Economy.format(2.5e6), "2.50M")
eq("format NaN", Economy.format(0 / 0), "0")
print(`tests: {passed} passed, {failed} failed`)

-- benchmark: median of 5 runs
local function bench(name: string, n: number, f: () -> ())
	local times = {}
	for r = 1, 5 do
		local t0 = os.clock()
		for _ = 1, n do
			f()
		end
		times[r] = (os.clock() - t0) * 1000
	end
	table.sort(times)
	print(string.format("bench %-28s n=%d median=%.2f ms", name, n, times[3]))
end
bench("bulkCost(owned=200,count=100)", 20000, function()
	Economy.bulkCost(pick, 200, 100)
end)
bench("format(1.23e15)", 200000, function()
	Economy.format(1.23e15)
end)
if failed > 0 then
	error("tests failed")
end
