local Players = cloneref(game:GetService("Players"))
local RS = cloneref(game:GetService("RunService"))
local UIS = cloneref(game:GetService("UserInputService"))
local Client = Players.LocalPlayer

local size = 30
local hitboxGeneral = false
local disabledPlayers = {}
local usuariosActivos = {} -- Tabla para usuarios con hitbox activo

-- COLORES PASTEL AESTHETIC
local COLOR_BG = Color3.fromRGB(170,255,200)       -- Fondo del Main Frame
local COLOR_BTN = Color3.fromRGB(120,220,160)      -- Botones
local COLOR_HOVER = Color3.fromRGB(100,200,140)    -- Hover/Click feedback
local COLOR_SLIDER = Color3.fromRGB(160,240,200)   -- Slider/Knob
local COLOR_WHITE = Color3.fromRGB(255,255,255)    -- Texto y bordes
local COLOR_GRAY = Color3.fromRGB(140,220,180)     -- Textbox / barra slider

-- ================= GUI =================
local guiEnabled = true

local ScreenGui = Instance.new("ScreenGui", Client.PlayerGui)
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,250,0,300)
Main.Position = UDim2.new(0.5,-125,0.05,0)
Main.BackgroundColor3 = COLOR_BG
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)

local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = COLOR_WHITE
mainStroke.Thickness = 4

-- ================= TITULO =================
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Text = "Hitbox Expansor"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextColor3 = COLOR_WHITE

-- ================= TAMAÑO =================
local SizeBg = Instance.new("Frame", Main)
SizeBg.Size = UDim2.new(1,-20,0,26)
SizeBg.Position = UDim2.new(0,10,0,40)
SizeBg.BackgroundColor3 = COLOR_BG  -- mismo color que el Main Frame
Instance.new("UICorner", SizeBg).CornerRadius = UDim.new(0,6)

local SizeLabel = Instance.new("TextLabel", SizeBg)
SizeLabel.Size = UDim2.new(1,0,1,0)
SizeLabel.BackgroundTransparency = 1  -- transparente, elimina el rectángulo negro
SizeLabel.Text = "Tamaño: "..size
SizeLabel.Font = Enum.Font.GothamBold
SizeLabel.TextSize = 24
SizeLabel.TextColor3 = COLOR_WHITE
SizeLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ================= SLIDER =================
local Slider = Instance.new("Frame", Main)
Slider.Size = UDim2.new(1,-20,0,30)
Slider.Position = UDim2.new(0,10,0,72)
Slider.BackgroundColor3 = COLOR_GRAY
Instance.new("UICorner", Slider).CornerRadius = UDim.new(0,6)

-- Degradado de la barra
local sliderGradient = Instance.new("UIGradient", Slider)
sliderGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(120,220,160)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(160,240,200))
})

local Knob = Instance.new("TextButton", Slider)
Knob.Size = UDim2.new(0,40,1,0)
Knob.Position = UDim2.new((size-2)/98,-20,0,0)
Knob.BackgroundColor3 = COLOR_WHITE
Knob.Text = ""
Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

local dragging = false
Knob.MouseButton1Down:Connect(function() dragging = true end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

RS.RenderStepped:Connect(function()
	if dragging then
		local mouse = Client:GetMouse()
		local x = math.clamp(mouse.X - Slider.AbsolutePosition.X,0,Slider.AbsoluteSize.X)
		local pct = x / Slider.AbsoluteSize.X
		size = math.floor(2 + pct*98)
		Knob.Position = UDim2.new(pct,-20,0,0)
		SizeLabel.Text = "Tamaño: "..size
	end
end)

-- ================= USUARIO =================
local UserBox = Instance.new("TextBox", Main)
UserBox.Size = UDim2.new(1,-20,0,30)
UserBox.Position = UDim2.new(0,10,0,115)
UserBox.BackgroundColor3 = COLOR_GRAY
UserBox.TextColor3 = COLOR_WHITE
UserBox.Font = Enum.Font.GothamBold
UserBox.TextSize = 22
UserBox.ClearTextOnFocus = false
UserBox.PlaceholderText = "Usuario"
UserBox.Text = ""
Instance.new("UICorner", UserBox).CornerRadius = UDim.new(0,6)

local function resizeText()
	local l = #UserBox.Text
	UserBox.TextSize = l <= 12 and 22 or l <= 18 and 18 or 14
end

UserBox:GetPropertyChangedSignal("Text"):Connect(function()
	resizeText()
end)

-- ================= BOTONES =================
local function createButton(parent, text, yPos, callback)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1,-20,0,28)
	btn.Position = UDim2.new(0,10,0,yPos)
	btn.BackgroundColor3 = COLOR_BTN
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 18
	btn.TextColor3 = COLOR_WHITE
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
	btn.MouseButton1Click:Connect(callback)
	btn.MouseEnter:Connect(function() btn.BackgroundColor3 = COLOR_HOVER end)
	btn.MouseLeave:Connect(function() btn.BackgroundColor3 = COLOR_BTN end)
	return btn
end

local ApplyBtn = createButton(Main, "Aplicar Hitbox (Usuario)", 150, function()
	local name = UserBox.Text:lower()
	if name ~= "" then
		usuariosActivos[name] = true
		disabledPlayers[name] = nil
	end
end)

local DisableBtn = createButton(Main, "Desactivar Hitbox (Usuario)", 185, function()
	local name = UserBox.Text:lower()
	if name ~= "" then
		disabledPlayers[name] = true
		usuariosActivos[name] = nil
	end
end)

local GeneralBtn = createButton(Main, "Hitbox General", 225, function()
	hitboxGeneral = not hitboxGeneral
	if hitboxGeneral then
		GeneralBtn.Text = "Hitbox Normal"
	else
		GeneralBtn.Text = "Hitbox General"
	end
end)

-- ================= HITBOX LOGIC =================
local function applyHitbox(player)
	if player == Client then return end
	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	if not hrp or not hum or hum.Health <= 0 then return end

	local name = player.Name:lower()
	local active = hitboxGeneral or (usuariosActivos[name] and not disabledPlayers[name])
	if disabledPlayers[name] and not hitboxGeneral then active = false end

	if active then
		hrp.Size = Vector3.new(size,size,size)
		hrp.Transparency = 0.5
		hrp.CanCollide = false
		hrp.Color = COLOR_BG

		if not hrp:FindFirstChild("SelectionBox") then
			local sb = Instance.new("SelectionBox")
			sb.Adornee = hrp
			sb.Color3 = COLOR_BG
			sb.LineThickness = 0.05
			sb.SurfaceTransparency = 1
			sb.Parent = hrp
		end
	else
		hrp.Size = Vector3.new(2,2,1)
		hrp.Transparency = 1
		local sb = hrp:FindFirstChild("SelectionBox")
		if sb then sb:Destroy() end
	end
end

RS.RenderStepped:Connect(function()
	for _,p in pairs(Players:GetPlayers()) do
		applyHitbox(p)
	end
end)

-- ================= TOGGLE GUI =================
local function toggleGUI(show)
	guiEnabled = show
	if show then ScreenGui.Enabled = true end
	Main:TweenPosition(
		UDim2.new(0.5,-125, show and 0.05 or -0.35,0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		0.3,
		true,
		function()
			if not show then ScreenGui.Enabled = false end
		end
	)
end

UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.Q then
		toggleGUI(not guiEnabled)
	end
end)
