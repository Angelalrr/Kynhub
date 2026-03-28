--// ======================================================
--//              ⚡ KYN HUB - SCRIPT COMPLETO ⚡
--// ======================================================

--// ======= THEME KYN HUB =========
local THEME = {
    FrameBg        = Color3.fromRGB(12, 13, 18),
    FrameBg2       = Color3.fromRGB(20, 22, 28),
    Accent         = Color3.fromRGB(0, 215, 255),
    AccentDark     = Color3.fromRGB(0, 80, 180),
    AccentHover    = Color3.fromRGB(80, 230, 255),
    TabIdle        = Color3.fromRGB(24, 26, 33),
    TabActive      = Color3.fromRGB(0, 215, 255),
    ToggleBg       = Color3.fromRGB(24, 26, 33),
    ToggleHover    = Color3.fromRGB(34, 37, 47),
    ToggleOffTrack = Color3.fromRGB(60, 65, 80),
    ToggleOnTrack  = Color3.fromRGB(0, 215, 255),
    TextLight      = Color3.fromRGB(240, 240, 250),
    TitleText      = Color3.fromRGB(255, 255, 255),
    Danger         = Color3.fromRGB(255, 60, 80)
}

--// ======= SERVICES =======
local CoreGui           = game:GetService("CoreGui")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local UIS               = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--// ======= PERSISTENCIA DE TOGGLES =======
local CONFIG_FILE = "KYNHub_Settings.json"
local SETTINGS = {
    AutoDesync = false,
    ESPJugadores = false,
    ESPBaseTime = false,
    ESPLadrones = false,
    XRayBase = false,
    InfiniteJump = false,
    AntiRagdoll = false,
    AntiLag = false,
    FreezeAnimaciones = false,
}

local function saveSettings()
    pcall(function()
        if writefile then
            writefile(CONFIG_FILE, HttpService:JSONEncode(SETTINGS))
        end
    end)
end

local function loadSettings()
    pcall(function()
        if isfile and readfile and isfile(CONFIG_FILE) then
            local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    if SETTINGS[k] ~= nil and type(v) == "boolean" then
                        SETTINGS[k] = v
                    end
                end
            end
        end
    end)
end

local function setSetting(key, value)
    if SETTINGS[key] ~= nil then
        SETTINGS[key] = value and true or false
        saveSettings()
    end
end

loadSettings()

-- Limpiar GUI antigua
local OLD = CoreGui:FindFirstChild("KYNHubGUI")
if OLD then OLD:Destroy() end
local OLD2 = CoreGui:FindFirstChild("KYNHubDesyncGUI")
if OLD2 then OLD2:Destroy() end

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "KYNHubGUI"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

-- ==========================================
-- // BOTÓN FLOTANTE (OPEN/CLOSE)
-- ==========================================
local btnDragFrame = Instance.new("Frame")
btnDragFrame.Size = UDim2.new(0, 55, 0, 55)
btnDragFrame.Position = UDim2.new(0, 20, 0.2, 0)
btnDragFrame.BackgroundTransparency = 1
btnDragFrame.Active = true
btnDragFrame.Draggable = true
btnDragFrame.Parent = gui

local toggleBtn = Instance.new("ImageButton")
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.Image = "rbxassetid://82945336379835"
toggleBtn.BackgroundColor3 = THEME.FrameBg
toggleBtn.BackgroundTransparency = 0.1
toggleBtn.Parent = btnDragFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local btnStroke = Instance.new("UIStroke")
btnStroke.Parent = toggleBtn
btnStroke.Thickness = 2.5
btnStroke.Color = Color3.new(1,1,1)

local btnGradient = Instance.new("UIGradient")
btnGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, THEME.Accent),
    ColorSequenceKeypoint.new(0.5, THEME.AccentDark),
    ColorSequenceKeypoint.new(1, THEME.Accent)
}
btnGradient.Parent = btnStroke

toggleBtn.MouseEnter:Connect(function()
    TweenService:Create(toggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back),
        {Size = UDim2.new(1.1,0,1.1,0), Position = UDim2.new(-0.05,0,-0.05,0)}):Play()
end)
toggleBtn.MouseLeave:Connect(function()
    TweenService:Create(toggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back),
        {Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0)}):Play()
end)

-- ==========================================
-- // BOTÓN FLOTANTE RÁPIDO (AUTO CLONE)
-- ==========================================
local cloneDragFrame = Instance.new("Frame")
cloneDragFrame.Size = UDim2.new(0, 60, 0, 60)
cloneDragFrame.Position = UDim2.new(1, -80, 0.45, 0)
cloneDragFrame.BackgroundTransparency = 1
cloneDragFrame.Active = true
cloneDragFrame.Draggable = true
cloneDragFrame.Parent = gui

local cloneQuickBtn = Instance.new("TextButton")
cloneQuickBtn.Size = UDim2.new(1, 0, 1, 0)
cloneQuickBtn.Text = "⚡\nCLONE"
cloneQuickBtn.Font = Enum.Font.GothamBold
cloneQuickBtn.TextSize = 10
cloneQuickBtn.TextColor3 = THEME.TextLight
cloneQuickBtn.BackgroundColor3 = THEME.AccentDark
cloneQuickBtn.AutoButtonColor = false
cloneQuickBtn.Parent = cloneDragFrame
Instance.new("UICorner", cloneQuickBtn).CornerRadius = UDim.new(1, 0)

local cloneStroke = Instance.new("UIStroke", cloneQuickBtn)
cloneStroke.Thickness = 1.5
cloneStroke.Color = THEME.Accent

-- ==========================================
-- // MAIN GUI FRAME
-- ==========================================
local mainDragFrame = Instance.new("Frame")
mainDragFrame.Size = UDim2.new(0, 270, 0, 300)
mainDragFrame.Position = UDim2.new(0.5, -135, 0.5, -150)
mainDragFrame.BackgroundTransparency = 1
mainDragFrame.Active = true
mainDragFrame.Draggable = true
mainDragFrame.Visible = false
mainDragFrame.Parent = gui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundColor3 = THEME.FrameBg
mainFrame.Parent = mainDragFrame
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local uiScale = Instance.new("UIScale")
uiScale.Scale = 0
uiScale.Parent = mainDragFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1.5
mainStroke.Color = Color3.new(1,1,1)
mainStroke.Parent = mainFrame

local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, THEME.Accent),
    ColorSequenceKeypoint.new(0.5, THEME.AccentDark),
    ColorSequenceKeypoint.new(1, THEME.Accent)
}
mainGradient.Parent = mainStroke

-- TITLE BAR
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -35, 0, 35)
title.BackgroundTransparency = 1
title.Text = "   ⚡ KYN HUB"
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = THEME.TitleText
title.Parent = mainFrame

local titleLine = Instance.new("Frame")
titleLine.Size = UDim2.new(1, 0, 0, 2)
titleLine.Position = UDim2.new(0, 0, 0, 35)
titleLine.BackgroundColor3 = THEME.Accent
titleLine.BorderSizePixel = 0
titleLine.Parent = mainFrame

-- ==========================================
-- // BOTÓN DE CERRAR (X) Y DIÁLOGO
-- ==========================================
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = THEME.TextLight
closeBtn.Parent = mainFrame

-- Overlay oscuro de confirmación
local overlayConfirm = Instance.new("Frame")
overlayConfirm.Size = UDim2.new(1, 0, 1, 0)
overlayConfirm.BackgroundColor3 = Color3.new(0,0,0)
overlayConfirm.BackgroundTransparency = 1
overlayConfirm.Visible = false
overlayConfirm.Active = true
overlayConfirm.ZIndex = 50
overlayConfirm.Parent = mainFrame
Instance.new("UICorner", overlayConfirm).CornerRadius = UDim.new(0, 12)

local confirmBox = Instance.new("Frame")
confirmBox.Size = UDim2.new(0, 220, 0, 110)
confirmBox.Position = UDim2.new(0.5, -110, 0.5, -55)
confirmBox.BackgroundColor3 = THEME.FrameBg2
confirmBox.ZIndex = 51
confirmBox.Parent = overlayConfirm
Instance.new("UICorner", confirmBox).CornerRadius = UDim.new(0, 10)

local confirmScale = Instance.new("UIScale")
confirmScale.Scale = 0
confirmScale.Parent = confirmBox

local confirmText = Instance.new("TextLabel")
confirmText.Size = UDim2.new(1, 0, 0, 50)
confirmText.BackgroundTransparency = 1
confirmText.Text = "¿Destruir KYN Hub?"
confirmText.Font = Enum.Font.GothamBold
confirmText.TextSize = 15
confirmText.TextColor3 = THEME.TextLight
confirmText.ZIndex = 52
confirmText.Parent = confirmBox

local btnYes = Instance.new("TextButton")
btnYes.Size = UDim2.new(0, 90, 0, 30)
btnYes.Position = UDim2.new(0, 15, 0, 60)
btnYes.BackgroundColor3 = THEME.Danger
btnYes.Text = "Sí"
btnYes.Font = Enum.Font.GothamBold
btnYes.TextColor3 = Color3.new(1,1,1)
btnYes.ZIndex = 52
btnYes.Parent = confirmBox
Instance.new("UICorner", btnYes).CornerRadius = UDim.new(0, 6)

local btnNo = Instance.new("TextButton")
btnNo.Size = UDim2.new(0, 90, 0, 30)
btnNo.Position = UDim2.new(1, -105, 0, 60)
btnNo.BackgroundColor3 = THEME.ToggleOffTrack
btnNo.Text = "No"
btnNo.Font = Enum.Font.GothamBold
btnNo.TextColor3 = Color3.new(1,1,1)
btnNo.ZIndex = 52
btnNo.Parent = confirmBox
Instance.new("UICorner", btnNo).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    overlayConfirm.Visible = true
    TweenService:Create(overlayConfirm, TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play()
    TweenService:Create(confirmScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end)

btnNo.MouseButton1Click:Connect(function()
    TweenService:Create(overlayConfirm, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    local hideTween = TweenService:Create(confirmScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0})
    hideTween:Play()
    hideTween.Completed:Wait()
    overlayConfirm.Visible = false
end)

btnYes.MouseButton1Click:Connect(function()
    local vanish = TweenService:Create(uiScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0})
    TweenService:Create(btnDragFrame, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,0)}):Play()
    TweenService:Create(cloneDragFrame, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,0)}):Play()
    vanish:Play()
    vanish.Completed:Wait()
    gui:Destroy()
end)

-- ==========================================
-- // TAB CONTAINER & CONTENT
-- ==========================================
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 30)
tabContainer.Position = UDim2.new(0, 10, 0, 45)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabContainer

local contentFrame = Instance.new("Frame")
contentFrame.Position = UDim2.new(0, 10, 0, 85)
contentFrame.Size = UDim2.new(1, -20, 1, -95)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local tabs, tabButtons = {}, {}

local function createTab(name)
    local tab = Instance.new("ScrollingFrame")
    tab.Name = name .. "Tab"
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.BackgroundTransparency = 1
    tab.ScrollBarThickness = 2
    tab.ScrollBarImageColor3 = THEME.Accent
    tab.Visible = false
    tab.Parent = contentFrame
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = tab
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    tabs[name] = tab
    return tab
end

createTab("Main") createTab("Visual") createTab("Misc")

local function setActiveTab(name)
    for tabName, tab in pairs(tabs) do tab.Visible = (tabName == name) end
    for tabName, btn in pairs(tabButtons) do
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = (tabName == name) and THEME.TabActive or THEME.TabIdle,
            TextColor3 = (tabName == name) and Color3.fromRGB(15,15,20) or THEME.TextLight
        }):Play()
    end
end

local function createTabButton(text, tabName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 78, 0, 26)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = THEME.TextLight
    btn.BackgroundColor3 = THEME.TabIdle
    btn.AutoButtonColor = false
    btn.Parent = tabContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() setActiveTab(tabName) end)
    tabButtons[tabName] = btn
end

createTabButton("Main", "Main")
createTabButton("Visual", "Visual")
createTabButton("Misc", "Misc")
setActiveTab("Main")

-- ==========================================
-- // ELEMENTOS: TOGGLE
-- ==========================================
_G.KYNAddToggle = function(tabName, data)
    local tab = tabs[tabName]
    if not tab then return end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 36)
    btn.BackgroundColor3 = THEME.ToggleBg
    btn.TextColor3 = THEME.TextLight
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = "   " .. (data.Name or "Toggle")
    btn.AutoButtonColor = false
    btn.Parent = tab
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 36, 0, 16)
    track.Position = UDim2.new(1, -48, 0.5, -8)
    track.BackgroundColor3 = THEME.ToggleOffTrack
    track.Parent = btn
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 2, 0.5, -6)
    dot.BackgroundColor3 = Color3.new(1,1,1)
    dot.Parent = track
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local state = false
    local function applyVisual()
        dot.Position = state and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
        track.BackgroundColor3 = state and THEME.ToggleOnTrack or THEME.ToggleOffTrack
        btn.TextColor3 = state and THEME.ToggleOnTrack or THEME.TextLight
    end

    if data.Default == true then
        state = true
        applyVisual()
        if data.Callback then task.spawn(function() pcall(data.Callback, true) end) end
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(dot, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = state and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)}):Play()
        TweenService:Create(track, TweenInfo.new(0.2),
            {BackgroundColor3 = state and THEME.ToggleOnTrack or THEME.ToggleOffTrack}):Play()
        TweenService:Create(btn, TweenInfo.new(0.2),
            {TextColor3 = state and THEME.ToggleOnTrack or THEME.TextLight}):Play()
        if data.Callback then pcall(data.Callback, state) end
    end)
end

_G.KYNAddButton = function(tabName, data)
    local tab = tabs[tabName]
    if not tab then return end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 36)
    btn.BackgroundColor3 = THEME.AccentDark
    btn.TextColor3 = THEME.TextLight
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = "   " .. (data.Name or "Botón")
    btn.AutoButtonColor = false
    btn.Parent = tab
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.Accent}):Play()
        task.wait(0.15)
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.AccentDark}):Play()
        if data.Callback then pcall(data.Callback) end
    end)
end

_G.KYNAddLabel = function(tabName, text)
    local tab = tabs[tabName]
    if not tab then return end
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -6, 0, 36)
    lbl.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    lbl.TextColor3 = Color3.fromRGB(120, 120, 140)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13
    lbl.Text = "   " .. text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = tab
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 6)
end

-- ============================================================
-- // FEATURES - CÓDIGO
-- ============================================================
local _lagEnabled = false
local _lagConn = nil

local function _lagOptimize(obj)
    pcall(function()
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled = false
        end
        if obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 1 end
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            obj.CastShadow = false
        end
        if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj.Enabled = false
        end
    end)
end

local function _lagApplyAll()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
        end
    end
    for _, v in pairs(Workspace:GetDescendants()) do _lagOptimize(v) end
end

local function _lagEnable()
    if _lagEnabled then return end
    _lagEnabled = true
    _lagApplyAll()
    _lagConn = Workspace.DescendantAdded:Connect(_lagOptimize)
end

local function _lagDisable()
    _lagEnabled = false
    if _lagConn then _lagConn:Disconnect(); _lagConn = nil end
end

local function _runAutoClone()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    local clonerTool = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner") or character:FindFirstChild("Quantum Cloner")
    if not clonerTool then return end
    if clonerTool.Parent ~= character then humanoid:EquipTool(clonerTool) end
    clonerTool:Activate()
    task.delay(0.2, function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local tf = pg and pg:FindFirstChild("ToolsFrames")
        local cloneUI = tf and tf:FindFirstChild("QuantumCloner")
        local tpButton = cloneUI and cloneUI:FindFirstChild("TeleportToClone")
        if not tpButton then return end
        pcall(function()
            if firesignal then firesignal(tpButton.MouseButton1Up) end
        end)
    end)
end

cloneQuickBtn.MouseButton1Click:Connect(function()
    TweenService:Create(cloneQuickBtn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.Accent}):Play()
    _runAutoClone()
    task.wait(0.15)
    TweenService:Create(cloneQuickBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.AccentDark}):Play()
end)

-- DESYNC (misma lógica solicitada, visual mejorado y renombrado)
local _desyncLoaded = false
local _desyncPanel = nil
local _desyncTargetBtn, _desyncTargetIndicator, _desyncTargetTB

local function _buildDesyncPanel()
    if _desyncPanel then pcall(function() _desyncPanel:Destroy() end) end

    _desyncPanel = Instance.new("Frame")
    _desyncPanel.Name = "KYNHubDesyncPanel"
    _desyncPanel.Size = UDim2.new(0, 240, 0, 150)
    _desyncPanel.Position = UDim2.new(1, -250, 0.5, -75)
    _desyncPanel.BackgroundColor3 = THEME.FrameBg
    _desyncPanel.BorderSizePixel = 0
    _desyncPanel.Active = true
    _desyncPanel.Draggable = true
    _desyncPanel.Parent = gui
    Instance.new("UICorner", _desyncPanel).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", _desyncPanel)
    stroke.Color = THEME.Accent
    stroke.Thickness = 1.5

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "   ⚡ KYN Hub — Desync"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = THEME.Accent
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.Parent = _desyncPanel

    local SpeedInput = Instance.new("TextBox")
    SpeedInput.Size = UDim2.new(0.84, 0, 0, 34)
    SpeedInput.Position = UDim2.new(0.08, 0, 0, 40)
    SpeedInput.BackgroundColor3 = THEME.FrameBg2
    SpeedInput.TextColor3 = THEME.TextLight
    SpeedInput.Font = Enum.Font.GothamMedium
    SpeedInput.TextSize = 14
    SpeedInput.PlaceholderText = "Velocidad..."
    SpeedInput.Parent = _desyncPanel
    Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0, 7)

    local ActionButton = Instance.new("TextButton")
    ActionButton.Size = UDim2.new(0.84, 0, 0, 42)
    ActionButton.Position = UDim2.new(0.08, 0, 0, 86)
    ActionButton.BackgroundColor3 = THEME.AccentDark
    ActionButton.Text = "EJECUTAR ACCIÓN"
    ActionButton.TextColor3 = THEME.TextLight
    ActionButton.Font = Enum.Font.GothamBold
    ActionButton.TextSize = 13
    ActionButton.AutoButtonColor = false
    ActionButton.Parent = _desyncPanel
    Instance.new("UICorner", ActionButton).CornerRadius = UDim.new(0, 7)

    if _desyncTargetTB and _desyncTargetTB.Text ~= "" then
        SpeedInput.Text = _desyncTargetTB.Text
    end

    SpeedInput:GetPropertyChangedSignal("Text"):Connect(function()
        if _desyncTargetTB then
            _desyncTargetTB.Text = SpeedInput.Text
            if firesignal then firesignal(_desyncTargetTB.FocusLost, true) end
        end
    end)

    local function simulateClick()
        if firesignal and _desyncTargetBtn then
            firesignal(_desyncTargetBtn.MouseButton1Down)
            firesignal(_desyncTargetBtn.MouseButton1Up)
            firesignal(_desyncTargetBtn.MouseButton1Click)
            firesignal(_desyncTargetBtn.Activated)
        end
    end

    ActionButton.MouseButton1Click:Connect(function()
        if not _desyncTargetIndicator then
            ActionButton.Text = "CARGANDO..."
            task.wait(0.4)
            ActionButton.Text = "EJECUTAR ACCIÓN"
            return
        end

        local currentColorHex = _desyncTargetIndicator.BackgroundColor3:ToHex():upper()
        if currentColorHex == "00FF78" then
            ActionButton.Text = "DOBLE CLIC!"
            simulateClick()
            task.wait(0.05)
            simulateClick()
        elseif currentColorHex == "28282D" then
            ActionButton.Text = "UN CLIC!"
            simulateClick()
        else
            ActionButton.Text = "COLOR: " .. currentColorHex
            simulateClick()
        end
        task.wait(0.4)
        ActionButton.Text = "EJECUTAR ACCIÓN"
    end)
end

local function _loadDesync()
    if _desyncLoaded then
        if _desyncPanel then _desyncPanel.Visible = true end
        return
    end
    _desyncLoaded = true

    task.spawn(function()
        local RobloxGui = CoreGui:WaitForChild("RobloxGui")
        local trampa
        trampa = RobloxGui.ChildAdded:Connect(function(child)
            if child.Name == "ChocolaDesync" then
                if child:IsA("ScreenGui") then child.Enabled = false end
                child.ChildAdded:Connect(function(subChild)
                    if subChild.Name == "Frame" then
                        subChild.Position = UDim2.new(9999, 0, 9999, 0)
                        subChild.Visible = false
                    end
                end)
                local existingFrame = child:FindFirstChild("Frame")
                if existingFrame then
                    existingFrame.Position = UDim2.new(9999, 0, 9999, 0)
                    existingFrame.Visible = false
                end
            end
        end)

        loadstring(game:HttpGet("https://raw.githubusercontent.com/chocolascript-glitch/Chocola.script/refs/heads/main/Chocola-Desync-no-auto-grab.lua"))()

        local ChocolaDesync = RobloxGui:WaitForChild("ChocolaDesync", 10)
        if not ChocolaDesync then
            warn("[KYN Hub] La GUI de Chocola no cargó.")
            _desyncLoaded = false
            if trampa then trampa:Disconnect() end
            return
        end

        local mainFrame = ChocolaDesync:WaitForChild("Frame", 5)
        task.wait(1)

        local seccion4 = mainFrame:GetChildren()[4]
        _desyncTargetBtn = seccion4.TextButton
        _desyncTargetIndicator = _desyncTargetBtn.Frame
        _desyncTargetTB = seccion4.Frame.Frame.TextBox

        if trampa then trampa:Disconnect() end
        _buildDesyncPanel()
    end)
end

-- ==========================================
-- // LÓGICA DE ABRIR / CERRAR
-- ==========================================
local isOpen = false
local isAnimating = false

local function toggleMenu()
    if isAnimating then return end
    isAnimating = true
    isOpen = not isOpen
    if isOpen then
        mainDragFrame.Visible = true
        local t = TweenService:Create(uiScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
        t:Play(); t.Completed:Wait()
    else
        local t = TweenService:Create(uiScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0})
        t:Play(); t.Completed:Wait()
        mainDragFrame.Visible = false
    end
    isAnimating = false
end

toggleBtn.MouseButton1Click:Connect(toggleMenu)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then toggleMenu() end
end)

-- ============================================================
-- // REGISTRAR FEATURES EN LOS TABS
-- ============================================================
_G.KYNAddLabel("Main", "Auto Steal  —  [Próximamente]")

_G.KYNAddToggle("Main", {
    Name = "Auto Desync",
    Default = SETTINGS.AutoDesync,
    Callback = function(state)
        setSetting("AutoDesync", state)
        if state then
            _loadDesync()
        else
            if _desyncPanel then _desyncPanel.Visible = false end
        end
    end
})

_G.KYNAddButton("Main", {
    Name = "Clone & TP",
    Callback = function()
        _runAutoClone()
    end
})

_G.KYNAddToggle("Visual", {
    Name = "ESP Jugadores",
    Default = SETTINGS.ESPJugadores,
    Callback = function(state)
        setSetting("ESPJugadores", state)
    end
})

_G.KYNAddToggle("Visual", {
    Name = "ESP Base Time",
    Default = SETTINGS.ESPBaseTime,
    Callback = function(state)
        setSetting("ESPBaseTime", state)
    end
})

_G.KYNAddToggle("Visual", {
    Name = "ESP Ladrones",
    Default = SETTINGS.ESPLadrones,
    Callback = function(state)
        setSetting("ESPLadrones", state)
    end
})

_G.KYNAddToggle("Visual", {
    Name = "X-Ray Base",
    Default = SETTINGS.XRayBase,
    Callback = function(state)
        setSetting("XRayBase", state)
    end
})

_G.KYNAddToggle("Misc", {
    Name = "Infinite Jump",
    Default = SETTINGS.InfiniteJump,
    Callback = function(state)
        setSetting("InfiniteJump", state)
    end
})

_G.KYNAddToggle("Misc", {
    Name = "Anti Ragdoll",
    Default = SETTINGS.AntiRagdoll,
    Callback = function(state)
        setSetting("AntiRagdoll", state)
    end
})

_G.KYNAddToggle("Misc", {
    Name = "Anti Lag",
    Default = SETTINGS.AntiLag,
    Callback = function(state)
        setSetting("AntiLag", state)
        if state then _lagEnable() else _lagDisable() end
    end
})

_G.KYNAddToggle("Misc", {
    Name = "Freeze Animaciones",
    Default = SETTINGS.FreezeAnimaciones,
    Callback = function(state)
        setSetting("FreezeAnimaciones", state)
    end
})

print("[KYN Hub] Cargado correctamente. RightShift para abrir/cerrar.")
