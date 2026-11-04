--!strict
-- HUD: big rock button, rock counter, upgrade list, rebirth. Mobile-first (prototype pass).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Economy = require(Shared:WaitForChild("Economy"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local player = Players.LocalPlayer
local remoteMine = Remotes.get("Mine")
local remoteBuy = Remotes.get("BuyUpgrade")
local remoteRebirth = Remotes.get("Rebirth")
local remoteState = Remotes.get("State")

local state: Remotes.State =
	{ rocks = 0, perClick = 1, perSecond = 0, income = 0, brainCells = 0, levels = {}, lifetime = 0, boostEnds = 0 }

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
rock.Position = UDim2.fromScale(0.42, 0.55)
rock.Size = UDim2.fromScale(0.3, 0.3)
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
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border -- Contextual would outline the "BONK" text on a TextButton
stroke.Thickness = 6
stroke.Color = PALETTE.accent
stroke.Parent = rock

-- upgrades panel (right side, above jump zone)
local panel = Instance.new("ScrollingFrame")
panel.Name = "Upgrades"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -8, 0, 80)
panel.Size = UDim2.fromScale(0.3, 0.55)
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

local upgradeButtons: { [string]: TextButton } = {}
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
	upgradeButtons[def.id] = b
	b.Activated:Connect(function()
		remoteBuy:FireServer(def.id, 1)
	end)
end

-- rebirth (bottom left, above the thumbstick zone)
local rebirth = Instance.new("TextButton")
rebirth.Name = "Rebirth"
rebirth.AnchorPoint = Vector2.new(0, 0)
rebirth.Position = UDim2.fromOffset(8, 80)
rebirth.Size = UDim2.new(0.18, 0, 0, 56)
rebirth.BackgroundColor3 = PALETTE.accent
rebirth.TextColor3 = PALETTE.bg
rebirth.Font = Enum.Font.FredokaOne
rebirth.TextSize = 16
rebirth.TextWrapped = true
rebirth.Parent = gui
corner(rebirth, 12)
rebirth.Visible = false -- shown only when a rebirth would pay out
rebirth.Activated:Connect(function()
	remoteRebirth:FireServer()
end)

-- new-player cue: pulse the rock for the first 2 taps (skipped for returning players)
local CUE_TAPS = 2
local tapCount = 0
local stateLoaded = false
local cueTween: Tween? = nil

local function stopCue()
	if cueTween then
		cueTween:Cancel()
		cueTween = nil
		stroke.Thickness = 6
		stroke.Color = PALETTE.accent
	end
end

local function startCue()
	if cueTween or tapCount >= CUE_TAPS then
		return
	end
	if GuiService.ReducedMotionEnabled then
		stroke.Thickness = 12 -- static cue, no motion
		stroke.Color = PALETTE.text
		cueTween = TweenService:Create(stroke, TweenInfo.new(0), { Thickness = 12 })
		return
	end
	local t =
		TweenService:Create(stroke, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			Thickness = 16,
			Color = PALETTE.text,
		})
	cueTween = t
	t:Play()
end

gui.Parent = player:WaitForChild("PlayerGui")

-- tap squash: one reusable tween pair, created once (not per tap)
local squashTween = TweenService:Create(rock, TweenInfo.new(0.08), { Size = UDim2.fromScale(0.27, 0.27) })
local restoreTween = TweenService:Create(rock, TweenInfo.new(0.1), { Size = UDim2.fromScale(0.3, 0.3) })
squashTween.Completed:Connect(function(playbackState: Enum.PlaybackState)
	if playbackState == Enum.PlaybackState.Completed then
		restoreTween:Play()
	end
end)

rock.Activated:Connect(function()
	tapCount += 1
	if tapCount >= CUE_TAPS then
		stopCue()
	end
	remoteMine:FireServer()
	-- cancel both: replaying a tween that is mid-play or finished strands the rock small on rapid taps
	restoreTween:Cancel()
	squashTween:Cancel()
	squashTween:Play()
end)

-- Server pushes on change plus a 1 Hz heartbeat; between pushes rocks grow by state.income x elapsed.
local stateAt = os.clock()
local function shownRocks(): number
	return state.rocks + state.income * (os.clock() - stateAt)
end

local function render()
	local rocks = shownRocks()
	rocksLabel.Text = Economy.format(rocks) .. " Brain Rocks"
	rateLabel.Text = Economy.format(state.perSecond) .. "/s  +" .. Economy.format(state.perClick) .. " per bonk"
	for _, def in Config.Upgrades do
		local b = upgradeButtons[def.id]
		local owned = state.levels[def.id] or 0
		local cost = Economy.costOf(def, owned)
		b.Text = def.name .. " (" .. owned .. ")\n" .. Economy.format(cost) .. " rocks"
		b.BackgroundColor3 = if rocks >= cost then Color3.fromRGB(60, 140, 90) else PALETTE.bg
	end
	local gain = Economy.rebirthGain(state.lifetime, Config.RebirthRequirement)
	local canRebirth = gain > state.brainCells
	rebirth.Visible = canRebirth
	if canRebirth then
		rebirth.Text = "BIG BRAIN\n+" .. (gain - state.brainCells) .. " cells"
	end
end

render()

remoteState.OnClientEvent:Connect(function(s: Remotes.State)
	state = s
	stateAt = os.clock()
	render()
	if not stateLoaded then
		stateLoaded = true
		if s.lifetime > 0 then
			tapCount = CUE_TAPS -- returning player: no cue
		else
			startCue()
		end
	end
end)

-- Passive income display: redraw at 10 Hz locally, no network.
task.spawn(function()
	while true do
		task.wait(0.1)
		if state.income > 0 then
			render()
		end
	end
end)
