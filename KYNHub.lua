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

--// ======= SETTINGS PERSISTENTES =======
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
    AntiTorret = false,
    AntiBeeDisco = false,
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
            local raw = readfile(CONFIG_FILE)
            local decoded = HttpService:JSONDecode(raw)
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
-- // BOTÓN FLOTANTE RÁPIDO (CLONE & TP)
-- ==========================================
local cloneDragFrame = Instance.new("Frame")
cloneDragFrame.Size = UDim2.new(0, 56, 0, 56)
cloneDragFrame.Position = UDim2.new(1, -74, 0.45, 0)
cloneDragFrame.BackgroundTransparency = 1
cloneDragFrame.Active = true
cloneDragFrame.Draggable = true
cloneDragFrame.Parent = gui

local cloneQuickBtn = Instance.new("TextButton")
cloneQuickBtn.Size = UDim2.new(1, 0, 1, 0)
cloneQuickBtn.BackgroundColor3 = THEME.AccentDark
cloneQuickBtn.TextColor3 = THEME.TextLight
cloneQuickBtn.Font = Enum.Font.GothamBold
cloneQuickBtn.TextSize = 10
cloneQuickBtn.Text = "Auto Clone"
cloneQuickBtn.AutoButtonColor = false
cloneQuickBtn.Parent = cloneDragFrame
Instance.new("UICorner", cloneQuickBtn).CornerRadius = UDim.new(1, 0)

local cloneQuickStroke = Instance.new("UIStroke", cloneQuickBtn)
cloneQuickStroke.Color = THEME.Accent
cloneQuickStroke.Thickness = 1.4

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

local shadow = Instance.new("ImageLabel")
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
shadow.Size = UDim2.new(1, 45, 1, 45)
shadow.ZIndex = -1
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://131292684852487"
shadow.ImageColor3 = THEME.Accent
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24, 24, 276, 276)
shadow.Parent = mainFrame

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

local titleLineGradient = Instance.new("UIGradient")
titleLineGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, THEME.Accent),
    ColorSequenceKeypoint.new(1, THEME.AccentDark)
}
titleLineGradient.Parent = titleLine

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

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = THEME.Danger}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = THEME.TextLight}):Play()
end)

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

local confirmStroke = Instance.new("UIStroke")
confirmStroke.Color = THEME.Danger
confirmStroke.Thickness = 1.5
confirmStroke.Parent = confirmBox

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
    local function apply(animated)
        if animated then
            TweenService:Create(dot, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Position = state and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)}):Play()
            TweenService:Create(track, TweenInfo.new(0.2),
                {BackgroundColor3 = state and THEME.ToggleOnTrack or THEME.ToggleOffTrack}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2),
                {TextColor3 = state and THEME.ToggleOnTrack or THEME.TextLight}):Play()
        else
            dot.Position = state and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
            track.BackgroundColor3 = state and THEME.ToggleOnTrack or THEME.ToggleOffTrack
            btn.TextColor3 = state and THEME.ToggleOnTrack or THEME.TextLight
        end
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        apply(true)
        if data.Callback then pcall(data.Callback, state) end
    end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.ToggleHover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.ToggleBg}):Play()
    end)

    if data.Default == true then
        state = true
        apply(false)
        if data.Callback then task.spawn(function() pcall(data.Callback, true) end) end
    end
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

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 1, 0)
    icon.Position = UDim2.new(1, -36, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "▶"
    icon.TextColor3 = THEME.Accent
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 13
    icon.Parent = btn

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.Accent}):Play()
        task.wait(0.15)
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.AccentDark}):Play()
        if data.Callback then pcall(data.Callback) end
    end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.ToggleHover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.AccentDark}):Play()
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

local _animSpeed = 2.5
local _animDist  = 6
RunService.RenderStepped:Connect(function()
    btnGradient.Rotation  = (btnGradient.Rotation  + 2)   % 360
    mainGradient.Rotation = (mainGradient.Rotation + 1.5) % 360
    local wave = math.sin(tick() * _animSpeed) * _animDist
    toggleBtn.Position = UDim2.new(0, 0, 0, wave)
    mainFrame.Position = UDim2.new(0, 0, 0, wave)
end)

local isOpen, isAnimating = false, false
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

-- ================= FEATURES ORIGINALES =================
local _lagEnabled, _lagUltra, _lagConn = false, false, nil
local function _lagOptimize(obj)
    pcall(function()
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then obj.Enabled = false end
        if obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 1 end
        if obj:IsA("BasePart") then obj.Material = Enum.Material.Plastic; obj.Reflectance = 0; obj.CastShadow = false end
        if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then obj.Enabled = false end
        if obj:IsA("MeshPart") or obj:IsA("UnionOperation") then obj.RenderFidelity = Enum.RenderFidelity.Performance end
        if _lagUltra and (obj:IsA("Accessory") or obj:IsA("ShirtGraphic") or obj:IsA("Shirt") or obj:IsA("Pants")) then obj:Destroy() end
    end)
end
local function _lagApplyAll()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale  = 0
    Lighting.EnvironmentSpecularScale = 0
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") then v.Enabled = false end
    end
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then terrain.WaterWaveSize=0; terrain.WaterWaveSpeed=0; terrain.WaterReflectance=0; terrain.WaterTransparency=1 end
    for _, v in pairs(Workspace:GetDescendants()) do _lagOptimize(v) end
end
local function _lagEnable()
    if _lagEnabled then return end
    _lagEnabled = true
    _lagUltra = true -- una sola opción Anti Lag (incluye ultra)
    _lagApplyAll()
    _lagConn = Workspace.DescendantAdded:Connect(_lagOptimize)
    pcall(function() RunService:Set3dRenderingEnabled(true) end)
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
end
local function _lagDisable() _lagEnabled = false; _lagUltra = false; if _lagConn then _lagConn:Disconnect(); _lagConn=nil end end

local _espPlayerEnabled, _espPlayerFolder = false, nil
local function _espPlayerInit()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    _espPlayerFolder = pg:FindFirstChild("KYN_PlayerESP") or Instance.new("Folder")
    _espPlayerFolder.Name="KYN_PlayerESP"; _espPlayerFolder.Parent=pg
end
local function _espPlayerUpdate(player)
    if player == LocalPlayer or not _espPlayerEnabled then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = player.Character.HumanoidRootPart
    local hl = _espPlayerFolder:FindFirstChild(player.Name.."_HL")
    if not hl then hl = Instance.new("Highlight"); hl.Name=player.Name.."_HL"; hl.FillColor=Color3.fromRGB(0,0,255); hl.FillTransparency=0.7; hl.OutlineColor=Color3.fromRGB(0,0,255); hl.OutlineTransparency=0; hl.Parent=_espPlayerFolder end
    hl.Adornee = player.Character
    local bb = _espPlayerFolder:FindFirstChild(player.Name.."_BB")
    if not bb then
        bb=Instance.new("BillboardGui"); bb.Name=player.Name.."_BB"; bb.Size=UDim2.new(0,200,0,50); bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true; bb.Parent=_espPlayerFolder
        local lbl = Instance.new("TextLabel"); lbl.Name="Label"; lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(0,255,255); lbl.TextStrokeTransparency=0; lbl.Font=Enum.Font.SourceSansBold; lbl.TextScaled=true; lbl.Parent=bb
    end
    bb.Adornee = hrp
    local lbl = bb:FindFirstChild("Label") if lbl then lbl.Text=player.Name end
end
local function _espPlayerClear() if _espPlayerFolder then for _, v in pairs(_espPlayerFolder:GetChildren()) do v:Destroy() end end end
Players.PlayerRemoving:Connect(function(player)
    if not _espPlayerFolder then return end
    local bb = _espPlayerFolder:FindFirstChild(player.Name.."_BB") if bb then bb:Destroy() end
    local hl = _espPlayerFolder:FindFirstChild(player.Name.."_HL") if hl then hl:Destroy() end
end)

local _espBaseEnabled, _espBaseOwnPos = false, nil
local function _espBaseGetOwnPos()
    local Plots = Workspace:FindFirstChild("Plots") if not Plots then return nil end
    for _, plot in ipairs(Plots:GetChildren()) do
        local sign=plot:FindFirstChild("PlotSign"); local base=plot:FindFirstChild("DeliveryHitbox")
        if sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled and base then return base.Position end
    end
    return nil
end
local function _espBaseUpdate(plot)
    local purchases = plot:FindFirstChild("Purchases") if not purchases then return end
    local plotBlock = purchases:FindFirstChild("PlotBlock") if not plotBlock or not plotBlock:FindFirstChild("Main") then return end
    local main = plotBlock.Main
    local remainingTimeGui = main:FindFirstChild("BillboardGui") and main.BillboardGui:FindFirstChild("RemainingTime")
    local base = plot:FindFirstChild("DeliveryHitbox")
    if base and _espBaseOwnPos and (base.Position - _espBaseOwnPos).Magnitude < 1 then return end

    local bb = main:FindFirstChild("KYN_Base_BB")
    local textLabel
    if not bb then
        bb = Instance.new("BillboardGui"); bb.Name="KYN_Base_BB"; bb.Adornee=main; bb.Size=UDim2.new(0,200,0,50); bb.StudsOffset=Vector3.new(0,5,0); bb.AlwaysOnTop=true; bb.Parent=main
        textLabel = Instance.new("TextLabel"); textLabel.Name="Label"; textLabel.Size=UDim2.new(1,0,1,0); textLabel.BackgroundTransparency=1; textLabel.TextColor3=Color3.fromRGB(255,255,255); textLabel.TextStrokeTransparency=0; textLabel.Font=Enum.Font.SourceSansBold; textLabel.TextScaled=true; textLabel.Text="Cargando..."; textLabel.Parent=bb
    else textLabel = bb:FindFirstChild("Label") end

    if textLabel and remainingTimeGui then
        if remainingTimeGui:IsA("TextLabel") then
            local t = remainingTimeGui.Text
            if t == "0s" or t == "0" then textLabel.Text="Desbloqueado"; textLabel.TextColor3=Color3.fromRGB(0,255,0)
            else textLabel.Text=t; textLabel.TextColor3=Color3.fromRGB(255,255,255) end
        elseif remainingTimeGui:IsA("NumberValue") then
            if remainingTimeGui.Value <= 0 then textLabel.Text="Desbloqueado"; textLabel.TextColor3=Color3.fromRGB(0,255,0)
            else textLabel.Text="Tiempo: "..remainingTimeGui.Value.."s"; textLabel.TextColor3=Color3.fromRGB(255,255,255) end
        end
    end
end
local function _espBaseClear()
    local Plots = Workspace:FindFirstChild("Plots") if not Plots then return end
    for _, plot in ipairs(Plots:GetChildren()) do
        local purchases = plot:FindFirstChild("Purchases")
        if purchases then local pb = purchases:FindFirstChild("PlotBlock"); if pb and pb:FindFirstChild("Main") then local bb = pb.Main:FindFirstChild("KYN_Base_BB"); if bb then bb:Destroy() end end end
    end
end

local _espStealersEnabled = false
local function _espStealersApply(char, player)
    local hl = Instance.new("Highlight")
    hl.Name = "KYN_StealerHL"; hl.FillColor=Color3.fromRGB(255,100,0); hl.OutlineColor=Color3.fromRGB(255,200,0); hl.FillTransparency=0.5; hl.OutlineTransparency=0; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=char
    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    if root then
        local bb = Instance.new("BillboardGui")
        bb.Name="KYN_StealerBB"; bb.Size=UDim2.new(0,150,0,40); bb.StudsOffset=Vector3.new(0,4.5,0); bb.AlwaysOnTop=true; bb.Parent=root
        local lbl = Instance.new("TextLabel")
        lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text="🎒 "..player.Name; lbl.TextColor3=Color3.fromRGB(255,150,0); lbl.TextStrokeTransparency=0; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=14; lbl.Parent=bb
    end
end
local function _espStealersGetRobbing()
    local robbing = {}
    local tagged = CollectionService:GetTagged("ClientRenderBrainrot")
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if char then
            for _, obj in pairs(tagged) do
                if obj:IsDescendantOf(char) then robbing[player] = true; break end
                local attr = obj:GetAttribute("__render_stolen")
                local root = char:FindFirstChild("HumanoidRootPart")
                if attr == true and root and obj:IsA("BasePart") and (obj.Position - root.Position).Magnitude < 7 then robbing[player] = true; break end
            end
        end
    end
    return robbing
end
local function _espStealersClearAll()
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char then
            local hl = char:FindFirstChild("KYN_StealerHL") if hl then hl:Destroy() end
            local root = char:FindFirstChild("HumanoidRootPart") if root and root:FindFirstChild("KYN_StealerBB") then root.KYN_StealerBB:Destroy() end
        end
    end
end

local _xrayEnabled, _xrayConn = false, nil
local function _xrayStart()
    if _xrayConn then _xrayConn:Disconnect() end
    _xrayConn = RunService.Heartbeat:Connect(function()
        local Plots = Workspace:FindFirstChild("Plots") if not Plots then return end
        for _, Plot in ipairs(Plots:GetChildren()) do
            if Plot:IsA("Model") and Plot:FindFirstChild("Decorations") then
                for _, Part in ipairs(Plot.Decorations:GetDescendants()) do if Part:IsA("BasePart") then Part.Transparency = 0.8 end end
            end
        end
    end)
end
local function _xrayStop()
    if _xrayConn then _xrayConn:Disconnect(); _xrayConn=nil end
    local Plots = Workspace:FindFirstChild("Plots")
    if Plots then
        for _, Plot in ipairs(Plots:GetChildren()) do
            if Plot:IsA("Model") and Plot:FindFirstChild("Decorations") then
                for _, Part in ipairs(Plot.Decorations:GetDescendants()) do if Part:IsA("BasePart") then Part.Transparency = 1 end end
            end
        end
    end
end

local _ijEnabled, _ijJumping, _ijCharacter = false, false, (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
LocalPlayer.CharacterAdded:Connect(function(char) _ijCharacter = char end)
RunService.Heartbeat:Connect(function()
    if not _ijEnabled or not _ijCharacter then return end
    local hrp = _ijCharacter:FindFirstChild("HumanoidRootPart")
    if hrp then local vel = hrp.AssemblyLinearVelocity; if vel.Y < -80 then hrp.AssemblyLinearVelocity = Vector3.new(vel.X, -80, vel.Z) end end
end)
UIS.JumpRequest:Connect(function()
    if not _ijEnabled or _ijJumping or not _ijCharacter then return end
    local hum = _ijCharacter:FindFirstChildOfClass("Humanoid")
    local hrp = _ijCharacter:FindFirstChild("HumanoidRootPart")
    if hum and hrp then
        _ijJumping = true
        local force = math.random(45, 52)
        local vel   = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = Vector3.new(vel.X, force, vel.Z)
        task.wait(math.random(5, 15) / 100)
        _ijJumping = false
    end
end)

local _arEnabled = false
local _antiKnockbackController = nil

local function setupAntiKnockback()
    local isEnabled = false
    local connections = {}

    local function shouldApplyAntiKnockback(humanoid)
        local state = humanoid:GetState()
        local knockoutStates = {
            [Enum.HumanoidStateType.Physics] = true,
            [Enum.HumanoidStateType.Ragdoll] = true,
            [Enum.HumanoidStateType.FallingDown] = true,
            [Enum.HumanoidStateType.GettingUp] = true
        }
        return knockoutStates[state]
    end

    local function enableControls(player)
        pcall(function()
            local playerScripts = player:WaitForChild("PlayerScripts")
            local playerModule = playerScripts:WaitForChild("PlayerModule")
            require(playerModule):GetControls():Enable()
        end)
    end

    local function cleanCharacter(character, cleanBodyMovers)
        for _, descendant in pairs(character:GetDescendants()) do
            if descendant:IsA("BallSocketConstraint") or descendant:IsA("NoCollisionConstraint") or descendant:IsA("HingeConstraint") or (descendant:IsA("Attachment") and (descendant.Name == "A" or descendant.Name == "B")) then
                descendant:Destroy()
            elseif cleanBodyMovers and (descendant:IsA("BodyVelocity") or descendant:IsA("BodyPosition") or descendant:IsA("BodyGyro")) then
                descendant:Destroy()
            end
        end
        for _, descendant in pairs(character:GetDescendants()) do
            if descendant:IsA("Motor6D") then descendant.Enabled = true end
        end
    end

    local function stopKnockbackAnimations(animator)
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            if track.Animation then
                local animName = track.Animation.Name:lower()
                if animName:find("rag") or animName:find("fall") or animName:find("hurt") or animName:find("down") or animName:find("knock") or animName:find("stun") then
                    track:Stop(0)
                end
            end
        end
    end

    local function enableAntiKnockback()
        if isEnabled then return end
        isEnabled = true

        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        local camera = Workspace.CurrentCamera
        local animator = humanoid:WaitForChild("Animator")

        local velocityChangeThreshold = 40
        local minVelocityMagnitude = 25
        local maxVelocityMagnitude = 15
        local cleanBodyMovers = true
        local lastVelocity = Vector3.new(0, 0, 0)

        table.insert(connections, humanoid.StateChanged:Connect(function(_, newState)
            if shouldApplyAntiKnockback(humanoid) then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                task.wait()
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
                cleanCharacter(character, cleanBodyMovers)
                stopKnockbackAnimations(animator)
                camera.CameraSubject = humanoid
                enableControls(localPlayer)
            elseif newState == Enum.HumanoidStateType.Jumping then
                -- no interferir con el salto normal
            end
        end))

        pcall(function()
            local packages = ReplicatedStorage:FindFirstChild("Packages")
            local net = packages and packages:FindFirstChild("Net")
            local impulse = net and net:FindFirstChild("RE/CombatService/ApplyImpulse")
            if impulse and impulse:IsA("RemoteEvent") then
                table.insert(connections, impulse.OnClientEvent:Connect(function()
                    if shouldApplyAntiKnockback(humanoid) then
                        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
                end))
            end
        end)

        table.insert(connections, character.DescendantAdded:Connect(function()
            if shouldApplyAntiKnockback(humanoid) then
                cleanCharacter(character, cleanBodyMovers)
                stopKnockbackAnimations(animator)
            end
        end))

        table.insert(connections, RunService.Heartbeat:Connect(function()
            if shouldApplyAntiKnockback(humanoid) then
                cleanCharacter(character, cleanBodyMovers)
                stopKnockbackAnimations(animator)
                local currentVelocity = humanoidRootPart.AssemblyLinearVelocity
                local velocityChange = (currentVelocity - lastVelocity).Magnitude
                if velocityChange > velocityChangeThreshold and currentVelocity.Magnitude > minVelocityMagnitude then
                    if currentVelocity.Magnitude > 0 then
                        local limitedVelocity = currentVelocity.Unit * math.min(currentVelocity.Magnitude, maxVelocityMagnitude)
                        humanoidRootPart.AssemblyLinearVelocity = limitedVelocity
                    end
                end
                lastVelocity = currentVelocity
            end
        end))

        enableControls(localPlayer)
        cleanCharacter(character, cleanBodyMovers)
        stopKnockbackAnimations(animator)

        table.insert(connections, localPlayer.CharacterAdded:Connect(function(newCharacter)
            character = newCharacter
            humanoid = newCharacter:WaitForChild("Humanoid")
            humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
            animator = humanoid:WaitForChild("Animator")
            lastVelocity = Vector3.new(0, 0, 0)
            enableControls(localPlayer)
            cleanCharacter(newCharacter, cleanBodyMovers)
            stopKnockbackAnimations(animator)
        end))
    end

    local function disableAntiKnockback()
        if not isEnabled then return end
        isEnabled = false
        for _, connection in pairs(connections) do if connection then connection:Disconnect() end end
        connections = {}
    end

    return {
        Enable = enableAntiKnockback,
        Disable = disableAntiKnockback,
        IsEnabled = function() return isEnabled end
    }
end

_antiKnockbackController = setupAntiKnockback()

local _freezeEnabled = false
local function _setFreezeAnims(state)
    _freezeEnabled = state
    local character = LocalPlayer.Character if not character then return end
    local hum = character:FindFirstChildOfClass("Humanoid") if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator") if not animator then return end
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do pcall(function() track:AdjustSpeed(state and 0 or 1) end) end
end


-- Anti Torret
local _antiTorretEnabled = false
local _antiTorretTarget = nil
local _antiTorretConn = nil
local _antiTorretDetectionDistance = 60
local _antiTorretPullDistance = -5

local function _antiTorretGetCharacter() return LocalPlayer.Character end
local function _antiTorretGetWeapon()
    local char = _antiTorretGetCharacter()
    if not char then return nil end
    return LocalPlayer.Backpack:FindFirstChild("Bat") or char:FindFirstChild("Bat")
end
local function _antiTorretFindTarget()
    local char = _antiTorretGetCharacter()
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local rootPos = char.HumanoidRootPart.Position
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:find("Sentry") and not obj.Name:lower():find("bullet") then
            local ownerId = obj.Name:match("Sentry_(%d+)")
            if ownerId and tonumber(ownerId) == LocalPlayer.UserId then
                continue
            end
            local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
            if part and (rootPos - part.Position).Magnitude <= _antiTorretDetectionDistance then
                return obj
            end
        end
    end
    return nil
end
local function _antiTorretMoveTarget(obj)
    local char = _antiTorretGetCharacter()
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    for _, part in pairs(obj:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    local root = char.HumanoidRootPart
    local cf = root.CFrame * CFrame.new(0, 0, _antiTorretPullDistance)
    if obj:IsA("BasePart") then
        obj.CFrame = cf
    elseif obj:IsA("Model") then
        local main = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if main then main.CFrame = cf end
    end
end
local function _antiTorretAttack()
    local char = _antiTorretGetCharacter()
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local weapon = _antiTorretGetWeapon()
    if not weapon then return end
    if weapon.Parent == LocalPlayer.Backpack then
        hum:EquipTool(weapon)
        task.wait(0.1)
    end
    local handle = weapon:FindFirstChild("Handle")
    if handle then handle.CanCollide = false end
    pcall(function() weapon:Activate() end)
    for _, r in pairs(weapon:GetDescendants()) do
        if r:IsA("RemoteEvent") then pcall(function() r:FireServer() end) end
    end
end
local function _antiTorretStart()
    if _antiTorretConn then return end
    _antiTorretConn = RunService.Heartbeat:Connect(function()
        if not _antiTorretEnabled then return end
        if _antiTorretTarget and _antiTorretTarget.Parent == workspace then
            _antiTorretMoveTarget(_antiTorretTarget)
            _antiTorretAttack()
        else
            _antiTorretTarget = _antiTorretFindTarget()
        end
    end)
end
local function _antiTorretStop()
    if _antiTorretConn then _antiTorretConn:Disconnect(); _antiTorretConn = nil end
    _antiTorretTarget = nil
end

-- Anti Bee & Disco
local _antiBeeDiscoEnabled = false
local _antiBeeDiscoConns = {}
local _antiBeeFOVLock = 70
local _antiBeeBlacklist = {
    "BlurEffect","ColorCorrectionEffect","BloomEffect","SunRaysEffect","DepthOfFieldEffect","Atmosphere","Sky","Smoke","ParticleEmitter","Beam","Trail","Highlight","PostEffect","SurfaceAppearance","Fire","Sparkles","Explosion","PointLight","SpotLight","SurfaceLight","Shadows","Blur","Fog","ColorGradingEffect","ToneMappingEffect","VignetteEffect","GodRays","Glare","ChromaticAberrationEffect","DistortionEffect","LensFlare","SunFlare","LightInfluence","AmbientOcclusionEffect","RefractionEffect","HeatDistortion","GlitchEffect","ScreenSpaceReflection","MotionBlur","VolumetricLight","RainEffect","SnowEffect","LightningEffect","NeonGlow","ContrastCorrection","ShadowMap","Bloom","Clouds","FogVolume","WaterEffect","WindEffect","PixelateEffect","FilmGrainEffect","CRTShader","NightVisionEffect","InfraredEffect","HazeEffect","ColorBalanceEffect","DynamicLight","AmbientEffect","ScreenDistortion","ScanlineEffect","UnderwaterEffect","ThermalVision","ShockwaveEffect","FlashEffect","ExplosionLight","VFXPart","GlitchScreen","ScreenFlash","OverlayEffect","ShadowEffect","GhostEffect","FogEmitter","WindEmitter","HeatWave","SunGlow","ColorOverlay","VisionDistort","EchoEffect","ScreenOverlay","RenderEffect","VisualEffect","LightingEffect","CameraEffect","WeatherEffect","SmokeTrail","FireTrail","NeonEffect","RefractionLayer","PostProcessingEffect","VisualNoise","ScreenNoise"
}
local function _antiBeeIsBlacklisted(obj)
    for _, name in ipairs(_antiBeeBlacklist) do if obj:IsA(name) then return true end end
    return false
end
local function _antiBeeClearEffects()
    for _, v in pairs(Lighting:GetDescendants()) do
        if _antiBeeIsBlacklisted(v) then pcall(function() v:Destroy() end) end
    end
end
local function _antiBeeEnable()
    if _antiBeeDiscoEnabled then return end
    _antiBeeDiscoEnabled = true
    _antiBeeClearEffects()
    table.insert(_antiBeeDiscoConns, Lighting.DescendantAdded:Connect(function(obj) task.wait(); if _antiBeeIsBlacklisted(obj) then pcall(function() obj:Destroy() end) end end))
    table.insert(_antiBeeDiscoConns, RunService.RenderStepped:Connect(function()
        local camera = workspace.CurrentCamera
        if camera and camera.FieldOfView ~= _antiBeeFOVLock then camera.FieldOfView = _antiBeeFOVLock end
    end))
end
local function _antiBeeDisable()
    _antiBeeDiscoEnabled = false
    for _, c in ipairs(_antiBeeDiscoConns) do pcall(function() c:Disconnect() end) end
    _antiBeeDiscoConns = {}
end

local _desyncLoaded, _desyncPanel, _desyncTargetBtn, _desyncTargetIndicator, _desyncTargetTB = false, nil, nil, nil, nil
local function _buildDesyncPanel()
    if _desyncPanel then pcall(function() _desyncPanel:Destroy() end) end

    _desyncPanel = Instance.new("Frame")
    _desyncPanel.Name = "KYN_DesyncPanel"
    _desyncPanel.Size = UDim2.new(0, 220, 0, 135)
    _desyncPanel.Position = UDim2.new(1, -230, 0.5, -68)
    _desyncPanel.BackgroundColor3 = THEME.FrameBg
    _desyncPanel.BorderSizePixel = 0
    _desyncPanel.Active = true
    _desyncPanel.Draggable = true
    _desyncPanel.Parent = gui
    Instance.new("UICorner", _desyncPanel).CornerRadius = UDim.new(0, 10)
    local dStroke = Instance.new("UIStroke", _desyncPanel)
    dStroke.Color = THEME.Accent
    dStroke.Thickness = 1.5

    local dTitle = Instance.new("TextLabel")
    dTitle.Size = UDim2.new(1, 0, 0, 30)
    dTitle.BackgroundTransparency = 1
    dTitle.Text = "   ⚡ KYN Hub — Desync"
    dTitle.Font = Enum.Font.GothamBold
    dTitle.TextSize = 13
    dTitle.TextXAlignment = Enum.TextXAlignment.Left
    dTitle.TextColor3 = THEME.Accent
    dTitle.Parent = _desyncPanel

    local speedInput = Instance.new("TextBox")
    speedInput.Size = UDim2.new(0.85, 0, 0, 32)
    speedInput.Position = UDim2.new(0.075, 0, 0, 36)
    speedInput.BackgroundColor3 = THEME.FrameBg2
    speedInput.TextColor3 = THEME.TextLight
    speedInput.Font = Enum.Font.GothamMedium
    speedInput.TextSize = 13
    speedInput.PlaceholderText = "Velocidad..."
    speedInput.Parent = _desyncPanel
    Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 6)

    local actionBtn = Instance.new("TextButton")
    actionBtn.Size = UDim2.new(0.85, 0, 0, 38)
    actionBtn.Position = UDim2.new(0.075, 0, 0, 82)
    actionBtn.BackgroundColor3 = THEME.AccentDark
    actionBtn.Text = "EJECUTAR DESYNC"
    actionBtn.TextColor3 = THEME.TextLight
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.TextSize = 13
    actionBtn.AutoButtonColor = false
    actionBtn.Parent = _desyncPanel
    Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 6)

    if _desyncTargetTB then
        pcall(function() speedInput.Text = _desyncTargetTB.Text or "" end)
        speedInput:GetPropertyChangedSignal("Text"):Connect(function()
            pcall(function()
                if _desyncTargetTB then
                    _desyncTargetTB.Text = speedInput.Text
                    if firesignal then firesignal(_desyncTargetTB.FocusLost, true) end
                end
            end)
        end)
    end

    actionBtn.MouseButton1Click:Connect(function()
        if not _desyncTargetBtn then
            actionBtn.Text = "Cargando..."; task.wait(0.5); actionBtn.Text = "EJECUTAR DESYNC"; return
        end
        local function simClick()
            pcall(function()
                if firesignal then
                    firesignal(_desyncTargetBtn.MouseButton1Down)
                    firesignal(_desyncTargetBtn.MouseButton1Up)
                    firesignal(_desyncTargetBtn.MouseButton1Click)
                    firesignal(_desyncTargetBtn.Activated)
                elseif getconnections then
                    for _, c in pairs(getconnections(_desyncTargetBtn.MouseButton1Click)) do if c.Function then c.Function() end end
                end
            end)
        end
        local ok, colorHex = pcall(function() return _desyncTargetIndicator.BackgroundColor3:ToHex():upper() end)
        if ok then
            if colorHex == "00FF78" then actionBtn.Text = "DOBLE CLIC!"; simClick(); task.wait(0.05); simClick()
            elseif colorHex == "28282D" then actionBtn.Text = "UN CLIC!"; simClick()
            else actionBtn.Text = "COLOR: "..colorHex; simClick() end
        else actionBtn.Text = "EJECUTANDO..."; simClick() end
        task.wait(0.4)
        actionBtn.Text = "EJECUTAR DESYNC"
    end)
end

local function _loadDesync()
    if _desyncLoaded then if _desyncPanel then _desyncPanel.Visible = true end return end
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
                if existingFrame then existingFrame.Position = UDim2.new(9999, 0, 9999, 0); existingFrame.Visible = false end
            end
        end)

        local success = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/chocolascript-glitch/Chocola.script/refs/heads/main/Chocola-Desync-no-auto-grab.lua"))()
        end)
        if not success then
            warn("[KYN Hub] No se pudo cargar el Desync externo.")
            _desyncLoaded = false
            if trampa then trampa:Disconnect() end
            return
        end

        local ChocolaDesync = RobloxGui:WaitForChild("ChocolaDesync", 10)
        if not ChocolaDesync then
            warn("[KYN Hub] ChocolaDesync no apareció en el tiempo esperado.")
            _desyncLoaded = false
            if trampa then trampa:Disconnect() end
            return
        end
        if trampa then trampa:Disconnect() end

        local desyncFrame = ChocolaDesync:WaitForChild("Frame", 5)
        if not desyncFrame then return end
        task.wait(1)
        pcall(function()
            local seccion4 = desyncFrame:GetChildren()[4]
            _desyncTargetBtn = seccion4.TextButton
            _desyncTargetIndicator = _desyncTargetBtn.Frame
            _desyncTargetTB = seccion4.Frame.Frame.TextBox
        end)
        _buildDesyncPanel()
    end)
end



-- Auto Steal Hub (KYN)
local _autoStealLoaded = false
local function _loadAutoStealHub()
    if _autoStealLoaded then return end
    _autoStealLoaded = true

    local function R(r,g,b) return Color3.fromRGB(r,g,b) end
    local function RC(parent, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 10)
        c.Parent = parent
    end
    local function TW(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quart), props):Play()
    end
    local function MakeGui(name, order)
        local sg = Instance.new("ScreenGui")
        sg.Name = name
        sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.DisplayOrder = order or 100
        if not pcall(function() sg.Parent = CoreGui end) then
            sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
        return sg
    end

    for _, n in ipairs({"KYN_Floor_GUI", "KYN_AS_GUI", "KYN_Rush_GUI", "InstantGrabGui"}) do
        pcall(function()
            local g = CoreGui:FindFirstChild(n); if g then g:Destroy() end
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then local g2 = pg:FindFirstChild(n); if g2 then g2:Destroy() end end
        end)
    end

    local COLORS = {
        BG = THEME.FrameBg,
        BG_DARK = THEME.FrameBg2,
        ELEMENT = THEME.ToggleBg,
        BORDER = THEME.ToggleOffTrack,
        ACCENT = THEME.Accent,
        SUCCESS = R(50,200,100),
        WARNING = R(255,180,50),
        TEXT = THEME.TextLight,
        TEXT_DIM = R(160,160,170),
    }

    local function Notify(titleText, text)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = titleText, Text = text, Duration = 3})
        end)
    end

    local function isMeStealing()
        local character = LocalPlayer.Character
        if not character then return false end
        local taggedObjects = CollectionService:GetTagged("ClientRenderBrainrot")
        for _, obj in pairs(taggedObjects) do
            if obj:IsDescendantOf(character) then return true end
            if obj:IsA("BasePart") then
                for _, child in pairs(character:GetDescendants()) do
                    if child:IsA("Weld") or child:IsA("WeldConstraint") then
                        if child.Part0 == obj or child.Part1 == obj then return true end
                    end
                end
            end
            local isStolenAttr = obj:GetAttribute("__render_stolen")
            local root = character:FindFirstChild("HumanoidRootPart")
            if isStolenAttr == true and root and obj:IsA("BasePart") and (obj.Position - root.Position).Magnitude < 6 then
                return true
            end
        end
        return false
    end

    local function handleSpeedCoil(equip)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local currentTool = char:FindFirstChildOfClass("Tool")
        if equip and not isMeStealing() then
            local coil = LocalPlayer.Backpack:FindFirstChild("Speed Coil") or char:FindFirstChild("Speed Coil")
            if coil and coil.Parent == LocalPlayer.Backpack then hum:EquipTool(coil) end
        else
            if currentTool and currentTool.Name == "Speed Coil" then hum:UnequipTools() end
        end
    end

    local floorPart, floorState, targetFloorHeight = nil, false, nil
    local function SetStealFloor(state, targetY)
        if floorState == state then if state and targetY then targetFloorHeight = targetY end return end
        floorState = state
        targetFloorHeight = targetY
        if state then
            if not floorPart then
                floorPart = Instance.new("Part")
                floorPart.Size = Vector3.new(16, 1, 16)
                floorPart.Anchored = true
                floorPart.CanCollide = true
                floorPart.Color = THEME.Accent
                floorPart.Material = Enum.Material.Neon
                floorPart.Transparency = 0.3
                floorPart.Parent = Workspace
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then floorPart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z) end
            end
        else
            if floorPart then floorPart:Destroy(); floorPart = nil end
        end
    end

    RunService.Heartbeat:Connect(function()
        if floorState and floorPart then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and targetFloorHeight then
                local currentY = floorPart.Position.Y
                local desiredY = targetFloorHeight - 3.5
                if hrp.Position.Y < currentY - 5 then currentY = hrp.Position.Y - 3.5 end
                if currentY < desiredY then currentY = math.min(currentY + 1.8, desiredY) end
                floorPart.CFrame = CFrame.new(hrp.Position.X, currentY, hrp.Position.Z)
            end
        end
    end)

    local autoStealEnabled = true
    local selectedTargetIndex = 1
    local allAnimals = {}
    local activeTarget = nil
    local espGui, espText
    local tracerBeam, targetAttachment

    local function getModule(name)
        local found = ReplicatedStorage:FindFirstChild(name, true)
        if found and found:IsA("ModuleScript") then return require(found) end
    end
    local AnimalsData = getModule("Animals")
    local Synchronizer = getModule("Synchronizer")

    local function getChannelsTable()
        if not Synchronizer then return nil end
        local ok, ch = pcall(getupvalue, Synchronizer.GetAllChannels, 1)
        if ok and type(ch) == "table" then return ch end
        for i = 1, 5 do
            local ok2, val = pcall(getupvalue, Synchronizer.Get, i)
            if ok2 and type(val) == "table" then return val end
        end
    end

    local function parseToNumber(str)
        if type(str) == "number" then return str end
        if not str then return 0 end
        str = tostring(str):gsub("<[^>]+>",""):upper()
        local numStr = str:match("[%d%.]+")
        if not numStr then return 0 end
        local num = tonumber(numStr) or 0
        if str:find("K") then num = num * 1e3 elseif str:find("M") then num = num * 1e6 elseif str:find("B") then num = num * 1e9 elseif str:find("T") then num = num * 1e12 end
        return num
    end

    local function isOnCarpet(part)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local filter = {}
        if Workspace:FindFirstChild("Debris") then table.insert(filter, Workspace.Debris) end
        if LocalPlayer.Character then table.insert(filter, LocalPlayer.Character) end
        params.FilterDescendantsInstances = filter
        local result = Workspace:Raycast(part.Position, Vector3.new(0, -999, 0), params)
        if result and result.Instance then
            local inst = result.Instance
            if inst.Name == "Carpet" or inst:GetFullName():find("Map%.Carpet") then return true end
        end
        return false
    end

    local function getPriceAndPosFromDebris(targetName, usedSet)
        local debris = Workspace:FindFirstChild("Debris")
        if not debris then return nil, nil, false, nil end
        for _, child in ipairs(debris:GetChildren()) do
            local overhead = child:FindFirstChild("AnimalOverhead") or child:FindFirstChild("AnimalOverhead", true)
            if overhead then
                local part
                if overhead.Parent:IsA("Attachment") then part = overhead.Parent.Parent
                elseif overhead.Parent:IsA("BasePart") then part = overhead.Parent
                elseif overhead.Parent:IsA("Model") then part = overhead.Parent.PrimaryPart or overhead.Parent:FindFirstChildWhichIsA("BasePart", true) end
                if part and part:IsA("BasePart") and not usedSet[part] and not isOnCarpet(part) then
                    local nameObj = overhead:FindFirstChild("DisplayName")
                    local genObj = overhead:FindFirstChild("Generation")
                    if nameObj and genObj and nameObj:IsA("TextLabel") and genObj:IsA("TextLabel") then
                        local cleanName = nameObj.Text:gsub("<[^>]+>", "")
                        local rawGenText = genObj.Text:gsub("<[^>]+>", "")
                        if cleanName == targetName or cleanName:find(targetName, 1, true) then
                            local lowerText = rawGenText:lower()
                            local isFusion = not lowerText:find("/s") and (lowerText:match("%d+s") or lowerText:match("%d+m") or lowerText:match("%d+h")) and true or false
                            usedSet[part] = true
                            return rawGenText, parseToNumber(rawGenText), isFusion, part.Position
                        end
                    end
                end
            end
        end
        return nil, nil, false, nil
    end

    local function scanAllPlots()
        local channels = getChannelsTable()
        if not channels then return end
        local newAnimals = {}
        local usedDebrisParts = {}
        for channelId, channelObj in pairs(channels) do
            local ok, data = pcall(function() return channelObj:GetTable() end)
            if ok and data and type(data) == "table" and data.AnimalList then
                local isMe = false
                local owner = data.Owner
                if owner then
                    if typeof(owner) == "Instance" and owner == LocalPlayer then isMe = true
                    elseif type(owner) == "table" and owner.UserId == LocalPlayer.UserId then isMe = true end
                end
                if not isMe then
                    for slot, animal in pairs(data.AnimalList) do
                        local info = AnimalsData and AnimalsData[animal.Index]
                        if info or animal.Index then
                            local displayName = (info and info.DisplayName) or animal.Index
                            local mpsText, mpsValue, isFusion, pos = getPriceAndPosFromDebris(displayName, usedDebrisParts)
                            if not isFusion and pos then
                                if not mpsText then
                                    local baseGen = (info and (info.Generation or info.BaseGeneration)) or 1
                                    mpsValue = parseToNumber(baseGen)
                                    mpsText = "$" .. mpsValue .. "/s (Base)"
                                end
                                local coordStr = string.format("📍 %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
                                table.insert(newAnimals, {name = displayName, mpsValue = mpsValue, mpsText = mpsText, plotName = channelId, slot = tostring(slot), mutation = animal.Mutation or "None", pos = pos, coordsStr = coordStr, uid = channelId .. "_" .. tostring(slot)})
                            end
                        end
                    end
                end
            end
        end
        table.sort(newAnimals, function(a, b) return a.mpsValue > b.mpsValue end)
        allAnimals = newAnimals
    end

    local function isTargetStillValid(uid)
        for _, animal in ipairs(allAnimals) do if animal.uid == uid then return true end end
        return false
    end

    local InternalStealCache = {}
    local PromptMemoryCache = {}
    local CameraAimState = {lastUID = nil, aimed = false}
    local function resetCameraAim() CameraAimState.lastUID = nil; CameraAimState.aimed = false end

    local function findPrompt(plotName, slotName)
        local uid = plotName .. "_" .. slotName
        local cached = PromptMemoryCache[uid]
        if cached and cached.Parent and cached:IsDescendantOf(Workspace) then return cached end
        local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(plotName)
        local podium = plot and plot:FindFirstChild("AnimalPodiums") and plot.AnimalPodiums:FindFirstChild(slotName)
        local prompt
        if podium and podium:FindFirstChild("Base") and podium.Base:FindFirstChild("Spawn") and podium.Base.Spawn:FindFirstChild("PromptAttachment") then
            prompt = podium.Base.Spawn.PromptAttachment:FindFirstChildOfClass("ProximityPrompt")
        end
        if not prompt and podium then prompt = podium:FindFirstChildWhichIsA("ProximityPrompt", true) end
        if prompt then PromptMemoryCache[uid] = prompt end
        return prompt
    end

    local function buildStealCallbacks(prompt)
        if InternalStealCache[prompt] then return InternalStealCache[prompt] end
        local data = {holdCallbacks = {}, triggerCallbacks = {}}
        local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
        if ok1 then for _, c in ipairs(conns1) do table.insert(data.holdCallbacks, c.Function) end end
        local ok2, conns2 = pcall(getconnections, prompt.Triggered)
        if ok2 then for _, c in ipairs(conns2) do table.insert(data.triggerCallbacks, c.Function) end end
        InternalStealCache[prompt] = data
        return data
    end

    local function forceGrabSpam(target)
        local prompt = findPrompt(target.plotName, target.slot)
        if not prompt or not prompt:IsDescendantOf(Workspace) then return false end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local basePart = prompt.Parent
        if basePart:IsA("Attachment") then basePart = basePart.Parent end
        if not basePart or not basePart:IsA("BasePart") then return false end
        local promptPos = basePart.Position
        local dist = (hrp.Position - promptPos).Magnitude
        if dist <= 25 then
            if CameraAimState.lastUID ~= target.uid then CameraAimState.lastUID = target.uid; CameraAimState.aimed = false end
            local cam = Workspace.CurrentCamera
            if cam and not CameraAimState.aimed then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, promptPos); CameraAimState.aimed = true end
            local data = buildStealCallbacks(prompt)
            pcall(function()
                prompt.HoldDuration = 0
                prompt.RequiresLineOfSight = false
                prompt.MaxActivationDistance = 9e99
                prompt.Enabled = true
            end)
            if fireproximityprompt then pcall(function() fireproximityprompt(prompt, 0); fireproximityprompt(prompt, 1); fireproximityprompt(prompt) end) end
            pcall(function() prompt:InputHoldBegin(); task.wait(); prompt:InputHoldEnd() end)
            if data then
                for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
                for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
            end
        end
        return true
    end

    local asfRunning = false
    local asfThread = nil
    local asfLockPos = nil
    local asfBtnOuter, asfBtnLbl, asfStatusLbl
    local RushBtn

    local function resetASFBtn()
        if asfBtnOuter then TW(asfBtnOuter, {BackgroundColor3 = COLORS.ELEMENT}, 0.2) end
        if asfBtnLbl then asfBtnLbl.Text = "🏠 INICIAR AUTO STEAL FLOOR" end
        if RushBtn then RushBtn.Text = "⚡ INICIAR ASF"; RushBtn.BackgroundColor3 = THEME.AccentDark end
    end
    local function setASFStatus(txt, col)
        if asfStatusLbl and asfStatusLbl.Parent then asfStatusLbl.Text = txt or ""; asfStatusLbl.TextColor3 = col or COLORS.TEXT_DIM end
    end
    local function stopMainASF()
        asfRunning = false
        asfLockPos = nil
        activeTarget = nil
        resetCameraAim()
        if asfThread then pcall(function() task.cancel(asfThread) end); asfThread = nil end
        SetStealFloor(false)
        LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
        handleSpeedCoil(false)
        resetASFBtn()
        setASFStatus("⛔ Detenido", R(255,100,100))
    end

    RunService.Heartbeat:Connect(function()
        if isMeStealing() then
            if floorState then SetStealFloor(false) end
            handleSpeedCoil(false)
        end
        if asfRunning and asfLockPos then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                if isMeStealing() then asfLockPos = nil; return end
                asfLockPos = Vector3.new(asfLockPos.X, hrp.Position.Y, asfLockPos.Z)
                hum:MoveTo(asfLockPos)
            end
        end
    end)

    local function asfWalkTo(lockedTarget, timeout)
        local char = LocalPlayer.Character; if not char then return false end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return false end
        handleSpeedCoil(true)
        local elapsed = 0
        while elapsed < (timeout or 20) and asfRunning do
            if isMeStealing() then asfLockPos = nil return false end
            if not isTargetStillValid(lockedTarget.uid) then asfLockPos = nil return false end
            local pos = lockedTarget.pos
            asfLockPos = Vector3.new(pos.X, hrp.Position.Y, pos.Z)
            local flatDist = Vector3.new(hrp.Position.X - pos.X, 0, hrp.Position.Z - pos.Z).Magnitude
            if flatDist < 3.5 then break end
            task.wait(0.05); elapsed = elapsed + 0.05
        end
        return true
    end

    local function doOneCycle()
        if isMeStealing() then setASFStatus("⏸ Manos ocupadas...", COLORS.WARNING); handleSpeedCoil(false); return false end
        setASFStatus("🔍 Escaneando mapa...", COLORS.WARNING)
        scanAllPlots()
        local target = allAnimals[selectedTargetIndex]
        if not target then setASFStatus("❌ Sin objetivos", R(255,80,80)); task.wait(0.5); return false end
        if not activeTarget or activeTarget.uid ~= target.uid then resetCameraAim() end
        activeTarget = target
        local brainrotPos = target.pos
        if not brainrotPos or brainrotPos.Magnitude == 0 then task.wait(0.5); activeTarget = nil; return false end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then activeTarget = nil; return false end
        local yDiff = brainrotPos.Y - hrp.Position.Y
        local needFloor = yDiff > 10
        setASFStatus("🚶 Acercándose a " .. target.name, R(100,200,255))
        local walkSuccess = asfWalkTo(target, 20)
        if not asfRunning or not walkSuccess then asfLockPos = nil; handleSpeedCoil(false); activeTarget = nil; return false end

        if needFloor then
            setASFStatus("⬆ Subiendo plataforma...", COLORS.WARNING)
            handleSpeedCoil(false)
            SetStealFloor(true, brainrotPos.Y)
            local ft = 0
            while ft < 8 and asfRunning do
                if isMeStealing() then SetStealFloor(false); asfLockPos = nil; return false end
                if not isTargetStillValid(target.uid) then SetStealFloor(false); asfLockPos = nil; return false end
                local currentHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if currentHrp and currentHrp.Position.Y >= brainrotPos.Y - 6 then break end
                task.wait(0.1); ft = ft + 0.1
            end
            if not asfRunning then SetStealFloor(false); asfLockPos = nil; return false end
            task.wait(0.05)
        else
            if floorState then SetStealFloor(false) end
        end

        setASFStatus("⚡ Robando " .. target.name, COLORS.ACCENT)
        while not isMeStealing() and asfRunning do
            if not isTargetStillValid(target.uid) then break end
            forceGrabSpam(target)
            task.wait(0.05)
        end

        if isMeStealing() then
            setASFStatus("✅ ¡Éxito!", COLORS.SUCCESS)
            local escapeTimeout = 0
            while isMeStealing() and asfRunning do
                task.wait(0.1)
                escapeTimeout = escapeTimeout + 0.1
                if escapeTimeout > 3 then break end
            end
        else
            setASFStatus("⏱ Desapareció...", COLORS.WARNING)
            if floorState then SetStealFloor(false) end
        end
        asfLockPos = nil
        handleSpeedCoil(false)
        activeTarget = nil
        resetCameraAim()
        task.wait(0.1)
        return true
    end

    local function runAutoStealFloor()
        while asfRunning do
            doOneCycle()
            if not asfRunning then break end
            task.wait(0.05)
        end
        stopMainASF()
    end

    local ASGui = MakeGui("KYN_AS_GUI", 101)
    local RushGui = MakeGui("KYN_Rush_GUI", 102)

    local ASPanel = Instance.new("Frame", ASGui)
    ASPanel.Name = "ASPanel"
    ASPanel.Size = UDim2.new(0, 280, 0, 480)
    ASPanel.Position = UDim2.new(0.5, -140, 0.5, -240)
    ASPanel.BackgroundColor3 = COLORS.BG
    ASPanel.BorderSizePixel = 0
    ASPanel.Active = true
    ASPanel.Draggable = true
    ASPanel.ClipsDescendants = true
    RC(ASPanel, 12)
    local borderStroke = Instance.new("UIStroke", ASPanel)
    borderStroke.Thickness = 1.5
    borderStroke.Color = COLORS.ACCENT

    local Header = Instance.new("Frame", ASPanel)
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = COLORS.BG_DARK
    Header.BorderSizePixel = 0
    RC(Header, 12)

    local TitleLbl = Instance.new("TextLabel", Header)
    TitleLbl.Size = UDim2.new(1, -80, 1, 0)
    TitleLbl.Position = UDim2.new(0, 15, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = "⚡ KYN HUB // AUTO STEAL"
    TitleLbl.TextColor3 = COLORS.TEXT
    TitleLbl.Font = Enum.Font.GothamBlack
    TitleLbl.TextSize = 15
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 30, 0, 25)
    CloseBtn.Position = UDim2.new(1, -35, 0.5, -12)
    CloseBtn.BackgroundColor3 = THEME.Danger
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = COLORS.TEXT
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    RC(CloseBtn, 6)

    local MinBtn = Instance.new("TextButton", Header)
    MinBtn.Size = UDim2.new(0, 30, 0, 25)
    MinBtn.Position = UDim2.new(1, -70, 0.5, -12)
    MinBtn.BackgroundColor3 = COLORS.ELEMENT
    MinBtn.Text = "-"
    MinBtn.TextColor3 = COLORS.TEXT
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 18
    RC(MinBtn, 6)

    local isMinimized = false
    local fullSize = UDim2.new(0, 280, 0, 480)
    local minSize = UDim2.new(0, 280, 0, 45)
    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then TW(ASPanel, {Size = minSize}, 0.3); MinBtn.Text = "+"
        else TW(ASPanel, {Size = fullSize}, 0.3); MinBtn.Text = "-" end
    end)

    local TargetHeader = Instance.new("TextLabel", ASPanel)
    TargetHeader.Size = UDim2.new(1, -20, 0, 20)
    TargetHeader.Position = UDim2.new(0, 15, 0, 50)
    TargetHeader.BackgroundTransparency = 1
    TargetHeader.Text = "TOP 10 TARGETS"
    TargetHeader.TextColor3 = COLORS.TEXT_DIM
    TargetHeader.Font = Enum.Font.GothamBold
    TargetHeader.TextSize = 10
    TargetHeader.TextXAlignment = Enum.TextXAlignment.Left

    local ScrollList = Instance.new("ScrollingFrame", ASPanel)
    ScrollList.Size = UDim2.new(1, -20, 0, 220)
    ScrollList.Position = UDim2.new(0, 10, 0, 75)
    ScrollList.BackgroundTransparency = 1
    ScrollList.BorderSizePixel = 0
    ScrollList.ScrollBarThickness = 4
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, 10 * 60)

    local slotList = {}
    local function updateHighlight()
        for j = 1, 10 do
            if selectedTargetIndex == j then
                slotList[j].stroke.Color = COLORS.ACCENT
                slotList[j].stroke.Thickness = 1.5
                TW(slotList[j].btn, {BackgroundColor3 = THEME.ToggleHover}, 0.1)
            else
                slotList[j].stroke.Color = COLORS.BORDER
                slotList[j].stroke.Thickness = 1
                TW(slotList[j].btn, {BackgroundColor3 = COLORS.ELEMENT}, 0.1)
            end
        end
    end

    for i = 1, 10 do
        local b = Instance.new("TextButton", ScrollList)
        b.Size = UDim2.new(1, -8, 0, 55)
        b.Position = UDim2.new(0, 0, 0, (i-1) * 60)
        b.BackgroundColor3 = COLORS.ELEMENT
        b.Text = ""
        b.AutoButtonColor = false
        RC(b, 8)
        local bStroke = Instance.new("UIStroke", b)
        bStroke.Color = COLORS.BORDER
        bStroke.Thickness = 1
        local numLbl = Instance.new("TextLabel", b)
        numLbl.Size = UDim2.new(0, 20, 0, 20)
        numLbl.Position = UDim2.new(0, 5, 0, 5)
        numLbl.BackgroundTransparency = 1
        numLbl.Text = "#" .. i
        numLbl.TextColor3 = COLORS.TEXT_DIM
        numLbl.Font = Enum.Font.GothamBold
        numLbl.TextSize = 10
        local nameLbl = Instance.new("TextLabel", b)
        nameLbl.Size = UDim2.new(1, -80, 0, 18)
        nameLbl.Position = UDim2.new(0, 25, 0, 8)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = "Cargando..."
        nameLbl.TextColor3 = COLORS.TEXT
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 12
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        local mpsLbl = Instance.new("TextLabel", b)
        mpsLbl.Size = UDim2.new(1, -80, 0, 14)
        mpsLbl.Position = UDim2.new(0, 25, 0, 24)
        mpsLbl.BackgroundTransparency = 1
        mpsLbl.Text = "$0"
        mpsLbl.TextColor3 = COLORS.SUCCESS
        mpsLbl.Font = Enum.Font.Gotham
        mpsLbl.TextSize = 11
        mpsLbl.TextXAlignment = Enum.TextXAlignment.Left
        local coordsLbl = Instance.new("TextLabel", b)
        coordsLbl.Size = UDim2.new(1, -80, 0, 12)
        coordsLbl.Position = UDim2.new(0, 25, 0, 38)
        coordsLbl.BackgroundTransparency = 1
        coordsLbl.Text = "📍 X, Y, Z"
        coordsLbl.TextColor3 = COLORS.TEXT_DIM
        coordsLbl.Font = Enum.Font.Gotham
        coordsLbl.TextSize = 9
        coordsLbl.TextXAlignment = Enum.TextXAlignment.Left
        b.MouseButton1Click:Connect(function() selectedTargetIndex = i; updateHighlight() end)
        slotList[i] = {btn = b, stroke = bStroke, nameLbl = nameLbl, mpsLbl = mpsLbl, coordsLbl = coordsLbl}
    end

    local asToggle = Instance.new("TextButton", ASPanel)
    asToggle.Size = UDim2.new(1, -20, 0, 28)
    asToggle.Position = UDim2.new(0, 10, 0, 310)
    asToggle.BackgroundColor3 = COLORS.SUCCESS
    asToggle.Text = "AUTO STEAL: ON"
    asToggle.Font = Enum.Font.GothamBold
    asToggle.TextSize = 11
    asToggle.TextColor3 = COLORS.TEXT
    RC(asToggle, 6)
    asToggle.MouseButton1Click:Connect(function()
        autoStealEnabled = not autoStealEnabled
        asToggle.Text = "AUTO STEAL: " .. (autoStealEnabled and "ON" or "OFF")
        asToggle.BackgroundColor3 = autoStealEnabled and COLORS.SUCCESS or THEME.Danger
        if not autoStealEnabled then if espGui then espGui.Enabled = false end if tracerBeam then tracerBeam.Enabled = false end end
    end)

    asfBtnOuter = Instance.new("Frame", ASPanel)
    asfBtnOuter.Size = UDim2.new(1, -20, 0, 32)
    asfBtnOuter.Position = UDim2.new(0, 10, 0, 348)
    asfBtnOuter.BackgroundColor3 = COLORS.ELEMENT
    asfBtnOuter.BorderSizePixel = 0
    RC(asfBtnOuter, 6)

    local asfBtnClick = Instance.new("TextButton", asfBtnOuter)
    asfBtnClick.Size = UDim2.new(1, 0, 1, 0)
    asfBtnClick.BackgroundTransparency = 1
    asfBtnClick.Text = ""

    asfBtnLbl = Instance.new("TextLabel", asfBtnClick)
    asfBtnLbl.Size = UDim2.new(1, 0, 1, 0)
    asfBtnLbl.BackgroundTransparency = 1
    asfBtnLbl.Font = Enum.Font.GothamBold
    asfBtnLbl.TextSize = 11
    asfBtnLbl.TextXAlignment = Enum.TextXAlignment.Center
    asfBtnLbl.TextColor3 = COLORS.TEXT
    asfBtnLbl.Text = "🏠 AUTO STEAL FLOOR"

    local function activateMainASF()
        if asfRunning then return end
        asfRunning = true
        LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
        TW(asfBtnOuter, {BackgroundColor3 = COLORS.ACCENT}, 0.1)
        asfBtnLbl.Text = "🏠 ASF ACTIVO"
        RushBtn.Text = "⛔ CANCELAR ASF"
        RushBtn.BackgroundColor3 = THEME.Danger
        asfThread = task.spawn(runAutoStealFloor)
    end

    asfBtnClick.MouseEnter:Connect(function() TW(asfBtnOuter, {BackgroundColor3 = THEME.ToggleHover}, 0.1) end)
    asfBtnClick.MouseLeave:Connect(function() TW(asfBtnOuter, {BackgroundColor3 = COLORS.ELEMENT}, 0.1) end)
    asfBtnClick.MouseButton1Click:Connect(function() if asfRunning then stopMainASF() else activateMainASF() end end)

    asfStatusLbl = Instance.new("TextLabel", ASPanel)
    asfStatusLbl.Size = UDim2.new(1, -20, 0, 16)
    asfStatusLbl.Position = UDim2.new(0, 10, 0, 385)
    asfStatusLbl.BackgroundTransparency = 1
    asfStatusLbl.Font = Enum.Font.Gotham
    asfStatusLbl.TextSize = 10
    asfStatusLbl.TextColor3 = COLORS.TEXT_DIM
    asfStatusLbl.TextXAlignment = Enum.TextXAlignment.Center
    asfStatusLbl.Text = "Listo."

    local stopOuter = Instance.new("TextButton", ASPanel)
    stopOuter.Size = UDim2.new(1, -20, 0, 28)
    stopOuter.Position = UDim2.new(0, 10, 0, 405)
    stopOuter.BackgroundColor3 = R(40, 6, 6)
    stopOuter.BorderSizePixel = 0
    stopOuter.Text = ""
    stopOuter.AutoButtonColor = false
    RC(stopOuter, 6)
    local stopLbl = Instance.new("TextLabel", stopOuter)
    stopLbl.Size = UDim2.new(1, 0, 1, 0)
    stopLbl.BackgroundTransparency = 1
    stopLbl.Font = Enum.Font.GothamBold
    stopLbl.TextSize = 11
    stopLbl.TextXAlignment = Enum.TextXAlignment.Center
    stopLbl.TextColor3 = R(255, 80, 80)
    stopLbl.Text = "⛔ STOP ALL"
    stopOuter.MouseButton1Click:Connect(stopMainASF)

    RushBtn = Instance.new("TextButton", RushGui)
    RushBtn.Name = "RushBtn"
    RushBtn.Size = UDim2.new(0, 150, 0, 35)
    RushBtn.Position = UDim2.new(0, 20, 0.5, 60)
    RushBtn.BackgroundColor3 = THEME.AccentDark
    RushBtn.Text = "⚡ INICIAR ASF"
    RushBtn.Font = Enum.Font.GothamBlack
    RushBtn.TextSize = 12
    RushBtn.TextColor3 = R(255, 255, 255)
    RushBtn.Active = true
    RushBtn.Draggable = true
    RC(RushBtn, 8)
    local rushStroke = Instance.new("UIStroke", RushBtn)
    rushStroke.Color = THEME.Accent
    rushStroke.Thickness = 2
    RushBtn.MouseButton1Click:Connect(function() if asfRunning then stopMainASF() else activateMainASF() end end)

    CloseBtn.MouseButton1Click:Connect(function()
        stopMainASF()
        ASGui:Destroy()
        RushGui:Destroy()
        _autoStealLoaded = false
    end)

    espGui = Instance.new("BillboardGui", ASGui)
    espGui.Name = "KYN_AutoStealESP"
    espGui.Size = UDim2.new(0, 150, 0, 50)
    espGui.StudsOffset = Vector3.new(0, 4.5, 0)
    espGui.AlwaysOnTop = true
    espGui.Enabled = false
    espText = Instance.new("TextLabel", espGui)
    espText.Size = UDim2.new(1, 0, 1, 0)
    espText.BackgroundTransparency = 1
    espText.TextColor3 = R(255, 255, 0)
    espText.TextStrokeColor3 = R(0, 0, 0)
    espText.TextStrokeTransparency = 0
    espText.Font = Enum.Font.GothamBold
    espText.TextScaled = true

    task.spawn(function()
        local lastTopUID = ""
        while task.wait(0.05) do
            if not ASPanel or not ASPanel.Parent then break end
            pcall(function()
                scanAllPlots()
                if allAnimals[1] and allAnimals[1].uid ~= lastTopUID then
                    if lastTopUID ~= "" then Notify("KYN Hub", "Nuevo Top: " .. allAnimals[1].name .. " [" .. allAnimals[1].mpsText .. "]") end
                    lastTopUID = allAnimals[1].uid
                end
                for i = 1, 10 do
                    local pet = allAnimals[i]
                    if pet then
                        local mutText = (pet.mutation and pet.mutation ~= "None") and (" [" .. tostring(pet.mutation) .. "]") or ""
                        slotList[i].nameLbl.Text = tostring(pet.name or "Desconocido") .. mutText
                        slotList[i].mpsLbl.Text = tostring(pet.mpsText or "")
                        slotList[i].coordsLbl.Text = tostring(pet.coordsStr or "")
                    else
                        slotList[i].nameLbl.Text = "Ranura #" .. i .. " Vacía"
                        slotList[i].mpsLbl.Text = ""
                        slotList[i].coordsLbl.Text = ""
                    end
                end
                updateHighlight()
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.05)
            pcall(function()
                if not ASPanel or not ASPanel.Parent then return end
                if not tracerBeam or not tracerBeam.Parent then
                    tracerBeam = Instance.new("Beam")
                    tracerBeam.Color = ColorSequence.new(THEME.Accent, THEME.AccentHover)
                    tracerBeam.Width0 = 0.15
                    tracerBeam.Width1 = 0.15
                    tracerBeam.FaceCamera = true
                    tracerBeam.LightEmission = 1
                    tracerBeam.Transparency = NumberSequence.new(0.2)
                    tracerBeam.Parent = Workspace.Terrain
                end
                if not targetAttachment or not targetAttachment.Parent then
                    targetAttachment = Instance.new("Attachment")
                    targetAttachment.Parent = Workspace.Terrain
                end
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local att = hrp:FindFirstChild("KYNTracerOrigin")
                    if not att then att = Instance.new("Attachment"); att.Name = "KYNTracerOrigin"; att.Parent = hrp end
                    tracerBeam.Attachment0 = att
                else
                    tracerBeam.Attachment0 = nil
                end

                if autoStealEnabled and hrp then
                    local target = (asfRunning and activeTarget) or allAnimals[selectedTargetIndex]
                    if target then
                        local prompt = findPrompt(target.plotName, target.slot)
                        if prompt and prompt:IsDescendantOf(Workspace) then
                            local basePart = prompt.Parent
                            if basePart:IsA("Attachment") then basePart = basePart.Parent end
                            if basePart and basePart:IsA("BasePart") then
                                if espGui then espGui.Adornee = basePart; espText.Text = "🎯 " .. tostring(target.name) .. "
" .. tostring(target.mpsText); espGui.Enabled = true end
                                targetAttachment.Parent = basePart
                                targetAttachment.Position = Vector3.new(0, 0, 0)
                                tracerBeam.Attachment1 = targetAttachment
                                tracerBeam.Enabled = true
                                local distance = (hrp.Position - basePart.Position).Magnitude
                                if distance <= 25 and not isMeStealing() then forceGrabSpam(target) end
                            else
                                if espGui then espGui.Enabled = false end
                                tracerBeam.Enabled = false
                            end
                        else
                            if espGui then espGui.Enabled = false end
                            tracerBeam.Enabled = false
                        end
                    else
                        if espGui then espGui.Enabled = false end
                        tracerBeam.Enabled = false
                    end
                else
                    if espGui then espGui.Enabled = false end
                    if tracerBeam then tracerBeam.Enabled = false end
                end
            end)
        end
    end)
end

local function _runAutoClone()
    local character = LocalPlayer.Character
    if not character then warn("[KYN Hub] No hay personaje."); return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    local clonerTool = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner") or character:FindFirstChild("Quantum Cloner")
    if not clonerTool then warn("[KYN Hub] No se encontró 'Quantum Cloner' en el inventario."); return end
    if clonerTool.Parent ~= character then humanoid:EquipTool(clonerTool) end
    clonerTool:Activate()

    task.delay(0.2, function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui") if not pg then return end
        local tf = pg:FindFirstChild("ToolsFrames") if not tf then return end
        local cloneUI = tf:FindFirstChild("QuantumCloner") if not cloneUI then return end
        local tpButton = cloneUI:FindFirstChild("TeleportToClone") if not tpButton then return end
        pcall(function()
            if tpButton:IsA("GuiButton") then
                tpButton:Activate()
            end
        end)
    end)
end

cloneQuickBtn.MouseButton1Click:Connect(function()
    TweenService:Create(cloneQuickBtn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.Accent}):Play()
    _runAutoClone()
    task.wait(0.15)
    TweenService:Create(cloneQuickBtn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.AccentDark}):Play()
end)

-- BUCLES/RESPAWN
task.spawn(function()
    while true do
        if _espPlayerEnabled and _espPlayerFolder then for _, player in pairs(Players:GetPlayers()) do pcall(function() _espPlayerUpdate(player) end) end end
        if _espBaseEnabled then
            _espBaseOwnPos = _espBaseGetOwnPos()
            local Plots = Workspace:FindFirstChild("Plots")
            if Plots then for _, plot in pairs(Plots:GetChildren()) do pcall(function() _espBaseUpdate(plot) end) end end
        end
        if _espStealersEnabled then
            local robbing = _espStealersGetRobbing()
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                local char = player.Character
                if char then
                    local hasESP = char:FindFirstChild("KYN_StealerHL")
                    if robbing[player] then if not hasESP then _espStealersApply(char, player) end
                    else
                        if hasESP then hasESP:Destroy() end
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root and root:FindFirstChild("KYN_StealerBB") then root.KYN_StealerBB:Destroy() end
                    end
                end
            end
        else
            _espStealersClearAll()
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    local Plots = Workspace:WaitForChild("Plots", 15)
    if Plots then
        Plots.ChildAdded:Connect(function(plot)
            task.wait(0.8)
            if _espBaseEnabled then pcall(function() _espBaseUpdate(plot) end) end
        end)
    end
end)

_espPlayerInit()
LocalPlayer.CharacterAdded:Connect(function(char)
    _ijCharacter = char
    if _freezeEnabled then task.wait(0.5); _setFreezeAnims(true) end
    if _arEnabled and _antiKnockbackController then task.wait(0.2); _antiKnockbackController.Enable() end
    if _antiTorretEnabled then _antiTorretStart() else _antiTorretStop() end
end)
if LocalPlayer.Character and _arEnabled and _antiKnockbackController then
    task.spawn(function() task.wait(0.2); _antiKnockbackController.Enable() end)
end

-- REGISTRAR FEATURES
_G.KYNAddButton("Main", {Name = "Auto Steal", Callback = function() _loadAutoStealHub() end})
_G.KYNAddToggle("Main", {
    Name = "Auto Desync",
    Default = SETTINGS.AutoDesync,
    Callback = function(state)
        setSetting("AutoDesync", state)
        if state then _loadDesync() else if _desyncPanel then _desyncPanel.Visible = false end end
    end
})
_G.KYNAddButton("Main", {Name = "Clone & TP", Callback = function() _runAutoClone() end})

_G.KYNAddToggle("Visual", {
    Name = "ESP Jugadores",
    Default = SETTINGS.ESPJugadores,
    Callback = function(state)
        setSetting("ESPJugadores", state)
        _espPlayerEnabled = state
        if not state then _espPlayerClear() end
    end
})
_G.KYNAddToggle("Visual", {
    Name = "ESP Base Time",
    Default = SETTINGS.ESPBaseTime,
    Callback = function(state)
        setSetting("ESPBaseTime", state)
        _espBaseEnabled = state
        if not state then _espBaseClear() end
    end
})
_G.KYNAddToggle("Visual", {
    Name = "ESP Ladrones",
    Default = SETTINGS.ESPLadrones,
    Callback = function(state)
        setSetting("ESPLadrones", state)
        _espStealersEnabled = state
        if not state then _espStealersClearAll() end
    end
})
_G.KYNAddToggle("Visual", {
    Name = "X-Ray Base",
    Default = SETTINGS.XRayBase,
    Callback = function(state)
        setSetting("XRayBase", state)
        _xrayEnabled = state
        if state then _xrayStart() else _xrayStop() end
    end
})

_G.KYNAddToggle("Misc", {
    Name = "Infinite Jump",
    Default = SETTINGS.InfiniteJump,
    Callback = function(state)
        setSetting("InfiniteJump", state)
        _ijEnabled = state
    end
})
_G.KYNAddToggle("Misc", {
    Name = "Anti Ragdoll",
    Default = SETTINGS.AntiRagdoll,
    Callback = function(state)
        setSetting("AntiRagdoll", state)
        _arEnabled = state
        if _antiKnockbackController then
            if state then _antiKnockbackController.Enable() else _antiKnockbackController.Disable() end
        end
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
    Name = "Anti Torret",
    Default = SETTINGS.AntiTorret,
    Callback = function(state)
        setSetting("AntiTorret", state)
        _antiTorretEnabled = state
        if state then _antiTorretStart() else _antiTorretStop() end
    end
})
_G.KYNAddToggle("Misc", {
    Name = "Anti bee & disco",
    Default = SETTINGS.AntiBeeDisco,
    Callback = function(state)
        setSetting("AntiBeeDisco", state)
        if state then _antiBeeEnable() else _antiBeeDisable() end
    end
})
_G.KYNAddToggle("Misc", {
    Name = "Freeze Animaciones",
    Default = SETTINGS.FreezeAnimaciones,
    Callback = function(state)
        setSetting("FreezeAnimaciones", state)
        _setFreezeAnims(state)
    end
})

print("[KYN Hub] Cargado correctamente. RightShift para abrir/cerrar.")
