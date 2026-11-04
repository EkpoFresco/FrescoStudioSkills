--!strict
-- HUD: big rock button, rock counter, upgrade list, rebirth. Mobile-first (prototype pass).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Economy = require(Shared:WaitForChild("Economy"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local player = Players.LocalPlayer
local state: any = { rocks = 0, perClick = 1, perSecond = 0, brainCells = 0, levels = {}, lifetime = 0 }

local gui = Instance.new("ScreenGui")
gui.Name = "Hud"
gui.ResetOnSpawn = false
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local PALETTE = {
	bg = Color3.fromRGB(34, 24, 52),
	panel = Color3.fromRGB(58, 40, 88),
	accent = Color3.fromRGB(255, 196, 61),
	rock = Color3.fromRGB(196, 120, 255),
	text = Color3.fromRGB(255, 255, 255),
	muted = Color3.fromRGB(200, 190, 220),
}

local function corner(parent: Instance, px: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, px)
	c.Parent = parent
end

local function label(parent: Instance, name: string, size: UDim2, pos: UDim2, textSize: number): TextLabel
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Size = size
	l.Position = pos
	l.BackgroundTransparency = 1
	l.TextColor3 = PALETTE.text
	l.Font = Enum.Font.FredokaOne
	l.TextSize = textSize
	l.Text = ""
	l.Parent = parent
	return l
end

-- counter (top center, below topbar inset)
local counter = Instance.new("Frame")
counter.Name = "Counter"
counter.AnchorPoint = Vector2.new(0.5, 0)
counter.Position = UDim2.new(0.5, 0, 0, 8)
counter.Size = UDim2.new(0.36, 0, 0, 64)
counter.BackgroundColor3 = PALETTE.panel
counter.Parent = gui
corner(counter, 16)
local rocksLabel = label(counter, "Rocks", UDim2.new(1, 0, 0.62, 0), UDim2.new(0, 0, 0, 2), 30)
local rateLabel = label(counter, "Rate", UDim2.new(1, 0, 0.38, 0), UDim2.new(0, 0, 0.6, 0), 16)
rateLabel.TextColor3 = PALETTE.muted

-- the rock (center left, clear of the right-side jump button)
local rock = Instance.new("TextButton")
rock.Name = "Rock"
rock.AnchorPoint = Vector2.new(0.5, 0.5)
rock.Position = UDim2.new(0.42, 0, 0.55, 0)
rock.Size = UDim2.new(0.3, 0, 0.3, 0)
rock.BackgroundColor3 = PALETTE.rock
rock.Text = "BONK"
rock.TextColor3 = PALETTE.text
rock.Font = Enum.Font.FredokaOne
rock.TextSize = 34
rock.AutoButtonColor = false
rock.Parent = gui
local aspect = Instance.new("UIAspectRatioConstraint")
aspect.AspectRatio = 1
aspect.Parent = rock
corner(rock, 999)
local stroke = Instance.new("UIStroke")
stroke.Thickness = 6
stroke.Color = PALETTE.accent
stroke.Parent = rock

-- upgrades panel (right side, above jump zone)
local panel = Instance.new("ScrollingFrame")
panel.Name = "Upgrades"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -8, 0, 80)
panel.Size = UDim2.new(0.3, 0, 0.55, 0)
panel.BackgroundColor3 = PALETTE.panel
panel.ScrollBarThickness = 6
panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
panel.CanvasSize = UDim2.new()
panel.Parent = gui
corner(panel, 14)
local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 6)
list.Parent = panel
local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 6)
pad.PaddingLeft = UDim.new(0, 6)
pad.PaddingRight = UDim.new(0, 12)
pad.Parent = panel

for i, def in Config.Upgrades do
	local b = Instance.new("TextButton")
	b.Name = def.id
	b.LayoutOrder = i
	b.Size = UDim2.new(1, 0, 0, 56)
	b.BackgroundColor3 = PALETTE.bg
	b.TextColor3 = PALETTE.text
	b.Font = Enum.Font.FredokaOne
	b.TextSize = 16
	b.TextWrapped = true
	b.Parent = panel
	corner(b, 10)
	b.Activated:Connect(function()
		Remotes.get("BuyUpgrade"):FireServer(def.id, 1)
	end)
end

-- rebirth (bottom left, above the thumbstick zone)
local rebirth = Instance.new("TextButton")
rebirth.Name = "Rebirth"
rebirth.AnchorPoint = Vector2.new(0, 0)
rebirth.Position = UDim2.new(0, 8, 0, 80)
rebirth.Size = UDim2.new(0.18, 0, 0, 56)
rebirth.BackgroundColor3 = PALETTE.accent
rebirth.TextColor3 = PALETTE.bg
rebirth.Font = Enum.Font.FredokaOne
rebirth.TextSize = 16
rebirth.TextWrapped = true
rebirth.Parent = gui
corner(rebirth, 12)
rebirth.Activated:Connect(function()
	Remotes.get("Rebirth"):FireServer()
end)

gui.Parent = player:WaitForChild("PlayerGui")

rock.Activated:Connect(function()
	Remotes.get("Mine"):FireServer()
	local t = TweenService:Create(rock, TweenInfo.new(0.08), { Size = UDim2.new(0.27, 0, 0.27, 0) })
	t:Play()
	t.Completed:Connect(function()
		TweenService:Create(rock, TweenInfo.new(0.1), { Size = UDim2.new(0.3, 0, 0.3, 0) }):Play()
	end)
end)

Remotes.get("State").OnClientEvent:Connect(function(s)
	state = s
end)

-- redraw every frame
RunService.RenderStepped:Connect(function()
	local hud = player.PlayerGui:FindFirstChild("Hud")
	if not hud then
		return
	end
	hud:FindFirstChild("Counter"):FindFirstChild("Rocks").Text = Economy.format(state.rocks) .. " Brain Rocks"
	hud:FindFirstChild("Counter"):FindFirstChild("Rate").Text = Economy.format(state.perSecond)
		.. "/s  +"
		.. Economy.format(state.perClick)
		.. " per bonk"
	for _, def in Config.Upgrades do
		local b = hud:FindFirstChild("Upgrades"):FindFirstChild(def.id) :: TextButton
		local owned = (state.levels and state.levels[def.id]) or 0
		local cost = Economy.costOf(def, owned)
		b.Text = def.name .. " (" .. owned .. ")\n" .. Economy.format(cost) .. " rocks"
		b.BackgroundColor3 = if state.rocks >= cost then Color3.fromRGB(60, 140, 90) else PALETTE.bg
	end
	local gain = Economy.rebirthGain(state.lifetime or 0, Config.RebirthRequirement)
	hud:FindFirstChild("Rebirth").Text = if gain > (state.brainCells or 0)
		then "BIG BRAIN\n+" .. (gain - state.brainCells) .. " cells"
		else "Big Brain at\n" .. Economy.format(Config.RebirthRequirement)
end)
