local Players = cloneref(game:GetService('Players'))
local RS = cloneref(game:GetService('RunService'))
local UIS = game:GetService('UserInputService')
local Client = Players.LocalPlayer
local size = 30

local COLOR_BLUE_PASTEL  = Color3.fromRGB(150, 200, 255)
local COLOR_RED_PASTEL   = Color3.fromRGB(255, 240, 150)
local GLOW_WHITE         = Color3.fromRGB(255, 255, 255)
local OUTLINE_WHITE      = Color3.fromRGB(255, 255, 255)

-- =========================
-- GUI PRINCIPAL
-- =========================
local guiEnabled = true

local ScreenGui = Instance.new('ScreenGui')
ScreenGui.Name = 'HitboxExpansorUI'
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Client:WaitForChild('PlayerGui')

local MainFrame = Instance.new('Frame')
MainFrame.Size = UDim2.new(0, 250, 0, 120)
MainFrame.Position = UDim2.new(0.5, -125, 0.05, 0) -- aparece al instante
MainFrame.BackgroundColor3 = COLOR_BLUE_PASTEL
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new('UICorner')
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainFrame
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Title = Instance.new('TextLabel')
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = 'Hitbox Expansor'
Title.TextColor3 = COLOR_BLUE_PASTEL
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.Parent = MainFrame

local titleGlow = Instance.new('UIStroke')
titleGlow.Color = GLOW_WHITE
titleGlow.Thickness = 2
titleGlow.Parent = Title

local titleOutline = Instance.new('UIStroke')
titleOutline.Color = OUTLINE_WHITE
titleOutline.Thickness = 1
titleOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
titleOutline.Parent = Title

local SizeLabel = Instance.new('TextLabel')
SizeLabel.Size = UDim2.new(1, -20, 0, 20)
SizeLabel.Position = UDim2.new(0, 10, 0, 40)
SizeLabel.BackgroundTransparency = 1
SizeLabel.Text = 'Tamaño: ' .. size
SizeLabel.TextColor3 = COLOR_BLUE_PASTEL
SizeLabel.Font = Enum.Font.GothamBold
SizeLabel.TextSize = 22
SizeLabel.TextStrokeTransparency = 0.2
SizeLabel.TextStrokeColor3 = OUTLINE_WHITE
SizeLabel.TextXAlignment = Enum.TextXAlignment.Left
SizeLabel.Parent = MainFrame

local sizeGlow = Instance.new('UIStroke')
sizeGlow.Color = GLOW_WHITE
sizeGlow.Thickness = 2
sizeGlow.Parent = SizeLabel

local sizeOutline = Instance.new('UIStroke')
sizeOutline.Color = OUTLINE_WHITE
sizeOutline.Thickness = 1
sizeOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
sizeOutline.Parent = SizeLabel

-- =========================
-- SLIDER
-- =========================
local SliderFrame = Instance.new('Frame')
SliderFrame.Size = UDim2.new(1, -20, 0, 30)
SliderFrame.Position = UDim2.new(0, 10, 0, 70)
SliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SliderFrame.BorderSizePixel = 0
SliderFrame.Parent = MainFrame

local SliderCorner = Instance.new('UICorner')
SliderCorner.CornerRadius = UDim.new(0, 6)
SliderCorner.Parent = SliderFrame

local SliderButton = Instance.new('TextButton')
SliderButton.Size = UDim2.new(0, 40, 1, 0)
SliderButton.Position = UDim2.new((size - 5) / 95, -20, 0, 0)
SliderButton.BackgroundColor3 = COLOR_RED_PASTEL
SliderButton.BorderSizePixel = 0
SliderButton.Text = ''
SliderButton.Parent = SliderFrame

local ButtonStroke = Instance.new('UIStroke')
ButtonStroke.Thickness = 2
ButtonStroke.Color = Color3.fromRGB(255, 255, 255)
ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ButtonStroke.Parent = SliderButton

local ButtonCorner = Instance.new('UICorner')
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = SliderButton

local dragging = false
SliderButton.MouseButton1Down:Connect(function() dragging = true end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

RS.RenderStepped:Connect(function()
	if dragging then
		local mouse = Client:GetMouse()
		local relativeX = math.clamp(mouse.X - SliderFrame.AbsolutePosition.X, 0, SliderFrame.AbsoluteSize.X)
		local percentage = relativeX / SliderFrame.AbsoluteSize.X
		size = math.floor(2 + (percentage * 98))
		SliderButton.Position = UDim2.new(percentage, -20, 0, 0)
		SizeLabel.Text = 'Tamaño: ' .. size
	end
end)

-- =========================
-- HITBOX
-- =========================
RS.RenderStepped:Connect(function()
	for _, Player in pairs(Players:GetPlayers()) do
		if Player == Client then continue end
		if Player.Character and Player.Character:FindFirstChild('HumanoidRootPart') then
			local HRP = Player.Character.HumanoidRootPart
			local Humanoid = Player.Character:FindFirstChild('Humanoid')
			if Humanoid and Humanoid.Health > 0 then
				HRP.Size = Vector3.new(size, size, size)
				HRP.Transparency = 0.5
				HRP.CanCollide = false
				HRP.Color = COLOR_RED_PASTEL
				if not HRP:FindFirstChild('SelectionBox') then
					local outline = Instance.new('SelectionBox')
					outline.Name = 'SelectionBox'
					outline.Parent = HRP
					outline.Adornee = HRP
					outline.LineThickness = 0.05
					outline.Color3 = COLOR_BLUE_PASTEL
					outline.SurfaceTransparency = 1
				end
			else
				HRP.Size = Vector3.new(2, 2, 1)
				HRP.Transparency = 1
				local outline = HRP:FindFirstChild('SelectionBox')
				if outline then outline:Destroy() end
			end
		end
	end
end)

-- =========================
-- TOGGLE GUI (Q)
-- =========================
local function tweenGUI(show)
	local startY = MainFrame.Position.Y.Scale
	local targetY = show and 0.05 or -0.2
	local duration = 0.3
	local steps = 30
	local waitTime = duration / steps
	for i = 1, steps do
		local t = i / steps
		local alpha = t^3 + (-3*t^2 + 3*t)*t
		MainFrame.Position = UDim2.new(0.5, -125, startY + (targetY - startY) * alpha, 0)
		task.wait(waitTime)
	end
	MainFrame.Position = UDim2.new(0.5, -125, targetY, 0)
end

UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Q then
		guiEnabled = not guiEnabled
		tweenGUI(guiEnabled)
	end
end)
