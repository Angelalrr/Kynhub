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
local StarterGui        = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ALLOWED_PLACE_ID = 109983668079237

if game.PlaceId ~= ALLOWED_PLACE_ID then
    warn("[KYN Hub] PlaceId distinto al recomendado (" .. tostring(ALLOWED_PLACE_ID) .. "). Ejecutando en modo compatible.")
end

--// ======= SETTINGS PERSISTENTES =======
local CONFIG_FILE = "KYNHub_Settings.json"
local SETTINGS = {
    AutoDesync = false,
    AutoSteal = false,
    AutoDesyncAutoActivate = false,
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
    ShowAutoCloneButton = true,
    StealSpeedValue = 25,
    GuiPositions = {},
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
                    if SETTINGS[k] ~= nil then
                        if type(SETTINGS[k]) == "boolean" and type(v) == "boolean" then
                            SETTINGS[k] = v
                        elseif type(SETTINGS[k]) == "number" and type(v) == "number" then
                            SETTINGS[k] = v
                        elseif type(SETTINGS[k]) == "table" and type(v) == "table" then
                            SETTINGS[k] = v
                        end
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

local function setRawSetting(key, value)
    if SETTINGS[key] ~= nil then
        SETTINGS[key] = value
        saveSettings()
    end
end

local function _encodeUDim2(pos)
    return {
        xs = pos.X.Scale, xo = pos.X.Offset,
        ys = pos.Y.Scale, yo = pos.Y.Offset
    }
end

local function _decodeUDim2(data, fallback)
    if type(data) ~= "table" then return fallback end
    if type(data.xs) ~= "number" or type(data.xo) ~= "number" or type(data.ys) ~= "number" or type(data.yo) ~= "number" then
        return fallback
    end
    return UDim2.new(data.xs, data.xo, data.ys, data.yo)
end

local function _saveGuiPos(key, frame)
    if not (key and frame) then return end
    SETTINGS.GuiPositions = SETTINGS.GuiPositions or {}
    SETTINGS.GuiPositions[key] = _encodeUDim2(frame.Position)
    saveSettings()
end

local function _loadGuiPos(key, fallback)
    local map = SETTINGS.GuiPositions
    return _decodeUDim2(type(map) == "table" and map[key] or nil, fallback)
end

local function _bindGuiPosPersistence(key, frame)
    if not frame then return end
    frame:GetPropertyChangedSignal("Position"):Connect(function()
        _saveGuiPos(key, frame)
    end)
end

loadSettings()

local function _getExecutorName()
    local candidates = {
        identifyexecutor,
        getexecutorname,
        getexecutor,
        get_exploit_name
    }
    for _, fn in ipairs(candidates) do
        if type(fn) == "function" then
            local ok, result = pcall(fn)
            if ok and type(result) == "string" and result ~= "" then
                return result
            end
        end
    end
    return "Executor desconocido"
end

local function _notify(title, text, duration)
    local ok = pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 6
        })
    end)
    if not ok then
        print(("[KYN Hub] %s - %s"):format(title, text))
    end
end

local function _safeFireSignal(signalObj)
    if not signalObj then return false end
    if firesignal then
        local ok = pcall(function() firesignal(signalObj) end)
        if ok then return true end
    end
    if getconnections then
        local ok = pcall(function()
            for _, conn in ipairs(getconnections(signalObj)) do
                if conn.Fire then
                    conn:Fire()
                elseif conn.Function then
                    conn.Function()
                end
            end
        end)
        if ok then return true end
    end
    return false
end

local function _resolveGuiParent()
    local canUseCoreGui = pcall(function()
        local probe = Instance.new("ScreenGui")
        probe.Name = "KYN_CoreGuiProbe"
        probe.Parent = CoreGui
        probe:Destroy()
    end)
    return canUseCoreGui and CoreGui or PlayerGui
end

local function _createScreenGui(name)
    local sg = Instance.new("ScreenGui")
    sg.Name = name
    sg.ResetOnSpawn = false
    local parent = _resolveGuiParent()
    pcall(function()
        sg.Parent = parent
    end)
    if not sg.Parent then sg.Parent = PlayerGui end
    return sg
end

task.spawn(function()
    task.wait(1)
    local deviceType = (UIS.TouchEnabled and not UIS.KeyboardEnabled) and "Móvil" or "PC"
    local executorName = _getExecutorName()
    _notify("KYN Hub", ("Executor: %s | Dispositivo: %s"):format(executorName, deviceType), 8)
end)

-- Limpiar GUI antigua
local OLD = CoreGui:FindFirstChild("KYNHubGUI") or PlayerGui:FindFirstChild("KYNHubGUI")
if OLD then OLD:Destroy() end

-- ScreenGui
local gui = _createScreenGui("KYNHubGUI")

-- ==========================================
-- // BOTÓN FLOTANTE (OPEN/CLOSE)
-- ==========================================
local btnDragFrame = Instance.new("Frame")
btnDragFrame.Size = UDim2.new(0, 55, 0, 55)
btnDragFrame.Position = _loadGuiPos("OpenButton", UDim2.new(0, 20, 0.2, 0))
btnDragFrame.BackgroundTransparency = 1
btnDragFrame.Active = true
btnDragFrame.Draggable = true
btnDragFrame.Parent = gui
_bindGuiPosPersistence("OpenButton", btnDragFrame)

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
cloneDragFrame.Position = _loadGuiPos("CloneButton", UDim2.new(1, -74, 0.45, 0))
cloneDragFrame.BackgroundTransparency = 1
cloneDragFrame.Active = true
cloneDragFrame.Draggable = true
cloneDragFrame.Parent = gui
cloneDragFrame.Visible = SETTINGS.ShowAutoCloneButton
_bindGuiPosPersistence("CloneButton", cloneDragFrame)

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

do
    local dragging = false
    local dragInput, dragStart, startPos
    cloneQuickBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = cloneDragFrame.Position
            dragInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    dragInput = nil
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and dragInput and input == dragInput then
            local delta = input.Position - dragStart
            cloneDragFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ==========================================
-- // MAIN GUI FRAME
-- ==========================================
local mainDragFrame = Instance.new("Frame")
mainDragFrame.Size = UDim2.new(0, 270, 0, 300)
mainDragFrame.Position = _loadGuiPos("MainPanel", UDim2.new(0.5, -135, 0.5, -150))
mainDragFrame.BackgroundTransparency = 1
mainDragFrame.Active = true
mainDragFrame.Draggable = true
mainDragFrame.Visible = false
mainDragFrame.Parent = gui
_bindGuiPosPersistence("MainPanel", mainDragFrame)

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
        if player ~= LocalPlayer then
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

    local function hardenHumanoid(humanoid)
        if not humanoid then return end
        pcall(function()
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        end)
        humanoid.PlatformStand = false
        humanoid.Sit = false
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
                hardenHumanoid(humanoid)
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

        table.insert(connections, humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
            if humanoid.PlatformStand then
                humanoid.PlatformStand = false
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
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
            hardenHumanoid(humanoid)
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
        hardenHumanoid(humanoid)
        cleanCharacter(character, cleanBodyMovers)
        stopKnockbackAnimations(animator)

        table.insert(connections, localPlayer.CharacterAdded:Connect(function(newCharacter)
            character = newCharacter
            humanoid = newCharacter:WaitForChild("Humanoid")
            humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
            animator = humanoid:WaitForChild("Animator")
            lastVelocity = Vector3.new(0, 0, 0)
            enableControls(localPlayer)
            hardenHumanoid(humanoid)
            cleanCharacter(newCharacter, cleanBodyMovers)
            stopKnockbackAnimations(animator)
        end))
    end

    local function disableAntiKnockback()
        if not isEnabled then return end
        isEnabled = false
        pcall(function()
            local character = Players.LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            end
        end)
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
local _freezeSavedAnims = {}
local _freezeDescendantConn = nil
local _freezeAnimPlayedConn = nil
local _freezeHeartbeatConn = nil
local _freezeTrackSpeeds = setmetatable({}, {__mode = "k"})
local _freezeAnimateStates = setmetatable({}, {__mode = "k"})

local function _freezeDisconnectConns()
    if _freezeDescendantConn then
        pcall(function() _freezeDescendantConn:Disconnect() end)
        _freezeDescendantConn = nil
    end
    if _freezeAnimPlayedConn then
        pcall(function() _freezeAnimPlayedConn:Disconnect() end)
        _freezeAnimPlayedConn = nil
    end
    if _freezeHeartbeatConn then
        pcall(function() _freezeHeartbeatConn:Disconnect() end)
        _freezeHeartbeatConn = nil
    end
end

local function _freezeIsWalkAnim(anim)
    if not (anim and anim:IsA("Animation")) then return false end
    local n = anim.Name:lower()
    return n:find("walk") ~= nil or n:find("run") ~= nil
end

local function _freezeSaveAndClearAnimation(anim)
    if not _freezeIsWalkAnim(anim) then return end
    for _, v in ipairs(_freezeSavedAnims) do
        if v.instance == anim then return end
    end
    table.insert(_freezeSavedAnims, {instance = anim, id = anim.AnimationId})
    anim.AnimationId = ""
end

local function _freezeRestoreAnimations()
    for _, v in ipairs(_freezeSavedAnims) do
        if v.instance and v.instance.Parent then
            v.instance.AnimationId = v.id
        end
    end
    _freezeSavedAnims = {}
end

local function _freezeStopWalkTracks(humanoid)
    if not humanoid then return end
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        local trackName = (track.Name or ""):lower()
        if trackName:find("walk") or trackName:find("run") then
            pcall(function() track:Stop(0) end)
        end
    end
end

local function _freezeTrack(track, shouldFreeze)
    if not track then return end
    if shouldFreeze then
        if _freezeTrackSpeeds[track] == nil then
            local original = 1
            pcall(function() original = track.Speed end)
            _freezeTrackSpeeds[track] = original
        end
        pcall(function() track:AdjustSpeed(0) end)
    else
        local original = _freezeTrackSpeeds[track]
        if original == nil then original = 1 end
        pcall(function() track:AdjustSpeed(original) end)
        _freezeTrackSpeeds[track] = nil
    end
end

local function _freezeApplyAnimatorTracks(animator, shouldFreeze)
    if not animator then return end
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        _freezeTrack(track, shouldFreeze)
    end
end

local function _freezeSetAnimateDisabled(character, disabledState)
    local animate = character and character:FindFirstChild("Animate")
    if not (animate and animate:IsA("LocalScript")) then return end
    if disabledState then
        if _freezeAnimateStates[animate] == nil then
            _freezeAnimateStates[animate] = animate.Disabled
        end
        animate.Disabled = true
    else
        local prev = _freezeAnimateStates[animate]
        if prev ~= nil then
            animate.Disabled = prev
            _freezeAnimateStates[animate] = nil
        else
            animate.Disabled = false
        end
    end
end

local function _freezeScanCharacter(character)
    if not character then return end
    local animate = character:FindFirstChild("Animate")
    if animate then
        local walkFolder = animate:FindFirstChild("walk")
        local runFolder = animate:FindFirstChild("run")
        if walkFolder then
            local walkAnim = walkFolder:FindFirstChild("WalkAnim")
            if walkAnim then _freezeSaveAndClearAnimation(walkAnim) end
        end
        if runFolder then
            local runAnim = runFolder:FindFirstChild("RunAnim")
            if runAnim then _freezeSaveAndClearAnimation(runAnim) end
        end
        for _, desc in ipairs(animate:GetDescendants()) do
            if desc:IsA("Animation") then
                _freezeSaveAndClearAnimation(desc)
            end
        end
    end

    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum then
        _freezeStopWalkTracks(hum)
        local animator = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 2)
        if animator then
            _freezeApplyAnimatorTracks(animator, true)
            _freezeAnimPlayedConn = animator.AnimationPlayed:Connect(function(track)
                if not _freezeEnabled or not track then return end
                _freezeTrack(track, true)
                local trackName = (track.Name or ""):lower()
                if trackName:find("walk") or trackName:find("run") then pcall(function() track:Stop(0) end) end
            end)
            _freezeHeartbeatConn = RunService.Heartbeat:Connect(function()
                if _freezeEnabled then
                    _freezeApplyAnimatorTracks(animator, true)
                end
            end)
        end
    end
end

local function _freezeBindCharacter(character)
    if not character then return end
    _freezeDisconnectConns()
    _freezeScanCharacter(character)
    _freezeDescendantConn = character.DescendantAdded:Connect(function(desc)
        if _freezeEnabled and desc:IsA("Animation") then
            _freezeSaveAndClearAnimation(desc)
        end
    end)
end

local function _setFreezeAnims(state)
    _freezeEnabled = state and true or false
    local character = LocalPlayer.Character

    if _freezeEnabled then
        _freezeSavedAnims = {}
        if character then
            _freezeSetAnimateDisabled(character, true)
            _freezeBindCharacter(character)
        end
    else
        _freezeDisconnectConns()
        _freezeRestoreAnimations()
        if character then _freezeSetAnimateDisabled(character, false) end
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        _freezeStopWalkTracks(hum)
        local animator = hum and (hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 1))
        if animator then _freezeApplyAnimatorTracks(animator, false) end
    end
end

local function _freezeCharacterAdded(character)
    if _freezeEnabled then
        task.wait(0.25)
        _freezeSetAnimateDisabled(character, true)
        _freezeBindCharacter(character)
    end
end

LocalPlayer.CharacterAdded:Connect(_freezeCharacterAdded)


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
            if not (ownerId and tonumber(ownerId) == LocalPlayer.UserId) then
                local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                if part and (rootPos - part.Position).Magnitude <= _antiTorretDetectionDistance then
                    return obj
                end
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

-- Auto Steal (simple)
local _autoStealEnabled = false
local _autoStealMode = "Priority"
local _autoStealGui, _autoStealFrame = nil, nil
local _autoStealTargetLabel, _autoStealMainButton, _autoStealModeButton = nil, nil, nil
local _autoStealBeam, _autoStealAtt0, _autoStealAtt1, _autoStealBillboard = nil, nil, nil, nil
local _autoStealLoopThread, _autoStealDeps = nil, nil
local _autoStealFeatureRunning = false
local _AUTO_STEAL_PRIORITY = {"Strawberry Elephant","Meowl","Skibidi Toilet","Headless Horseman","Dragon Gingerini","Dragon Cannelloni","Ketupat Bros","Hydra Dragon Cannelloni","La Supreme Combinasion","Love Love Bear"}

local function _autoStealEnsureDeps()
    if _autoStealDeps then return true end
    local ok, data = pcall(function()
        local Packages = ReplicatedStorage:WaitForChild("Packages")
        local Datas = ReplicatedStorage:WaitForChild("Datas")
        local Shared = ReplicatedStorage:WaitForChild("Shared")
        local Utils = ReplicatedStorage:WaitForChild("Utils")
        return {
            Synchronizer = require(Packages:WaitForChild("Synchronizer")),
            AnimalsData = require(Datas:WaitForChild("Animals")),
            AnimalsShared = require(Shared:WaitForChild("Animals")),
            NumberUtils = require(Utils:WaitForChild("NumberUtils"))
        }
    end)
    if ok then _autoStealDeps = data end
    return ok
end

local function _autoStealFormatMoney(v)
    if not _autoStealEnsureDeps() then return "$0/s" end
    local ok, s = pcall(function() return _autoStealDeps.NumberUtils:ToString(v) end)
    return ok and ("$"..s.."/s") or ("$"..tostring(v).."/s")
end

local function _autoStealGetTargetPart(plotName, slot)
    local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(plotName)
    local pod = plot and plot:FindFirstChild("AnimalPodiums") and plot.AnimalPodiums:FindFirstChild(tostring(slot))
    return pod and pod:FindFirstChild("Base") and pod.Base:FindFirstChild("Spawn") or nil
end

local function _autoStealFindPrompt(plotName, slot)
    local spawn = _autoStealGetTargetPart(plotName, slot)
    local att = spawn and spawn:FindFirstChild("PromptAttachment")
    return att and att:FindFirstChildWhichIsA("ProximityPrompt") or nil
end

local function _autoStealExecute(prompt)
    local old = prompt.HoldDuration
    prompt.HoldDuration = 0
    if fireproximityprompt then fireproximityprompt(prompt) else prompt:InputHoldBegin(); task.wait(0.05); prompt:InputHoldEnd() end
    task.delay(0.1, function() if prompt and prompt.Parent then prompt.HoldDuration = old end end)
end

local function _autoStealGetPets()
    if not _autoStealEnsureDeps() then return {} end
    local pets, plots = {}, Workspace:FindFirstChild("Plots")
    if not plots then return pets end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    for _, plot in ipairs(plots:GetChildren()) do
        local channel = _autoStealDeps.Synchronizer:Get(plot.Name)
        if channel then
            local owner = channel:Get("Owner")
            local isMine = (typeof(owner) == "Instance" and owner == LocalPlayer) or (typeof(owner) == "table" and owner.UserId == LocalPlayer.UserId)
            if not isMine then
                local animalList = channel:Get("AnimalList")
                if animalList then
                    for slot, data in pairs(animalList) do
                        if type(data) == "table" then
                            local aName = data.Index
                            local info = _autoStealDeps.AnimalsData[aName]
                            local display = info and info.DisplayName or aName
                            local gen = _autoStealDeps.AnimalsShared:GetGeneration(aName, data.Mutation, data.Traits, nil)
                            local dist = math.huge
                            if hrp then pcall(function() dist = (hrp.Position - plot.AnimalPodiums[tostring(slot)].Base.Spawn.Position).Magnitude end) end
                            local rank = 999
                            for i, p in ipairs(_AUTO_STEAL_PRIORITY) do if display:lower() == p:lower() then rank = i break end end
                            table.insert(pets, {plot = plot.Name, slot = tostring(slot), name = display, genValue = gen, genText = _autoStealFormatMoney(gen), dist = dist, pRank = rank})
                        end
                    end
                end
            end
        end
    end
    table.sort(pets, function(a,b) if a.pRank ~= b.pRank then return a.pRank < b.pRank end return a.genValue > b.genValue end)
    return pets
end

local function _autoStealPickTarget(pets)
    if #pets == 0 then return nil end
    if _autoStealMode == "Nearest" then table.sort(pets, function(a,b) return a.dist < b.dist end); return pets[1] end
    if _autoStealMode == "Highest" then table.sort(pets, function(a,b) return a.genValue > b.genValue end); return pets[1] end
    return pets[1]
end

local function _autoStealClearVisuals()
    if _autoStealBeam then _autoStealBeam:Destroy(); _autoStealBeam = nil end
    if _autoStealAtt0 then _autoStealAtt0:Destroy(); _autoStealAtt0 = nil end
    if _autoStealAtt1 then _autoStealAtt1:Destroy(); _autoStealAtt1 = nil end
    if _autoStealBillboard then _autoStealBillboard:Destroy(); _autoStealBillboard = nil end
end

local function _autoStealUpdateVisuals(target)
    if not _autoStealEnabled or not target then _autoStealClearVisuals() return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetPart = _autoStealGetTargetPart(target.plot, target.slot)
    if not hrp or not targetPart then _autoStealClearVisuals() return end
    if not _autoStealAtt0 or _autoStealAtt0.Parent ~= hrp then if _autoStealAtt0 then _autoStealAtt0:Destroy() end; _autoStealAtt0 = Instance.new("Attachment", hrp) end
    if not _autoStealAtt1 or _autoStealAtt1.Parent ~= targetPart then if _autoStealAtt1 then _autoStealAtt1:Destroy() end; _autoStealAtt1 = Instance.new("Attachment", targetPart) end
    if not _autoStealBeam then
        _autoStealBeam = Instance.new("Beam")
        _autoStealBeam.FaceCamera = true
        _autoStealBeam.Width0 = 0.45
        _autoStealBeam.Width1 = 0.45
        _autoStealBeam.Color = ColorSequence.new(THEME.Accent)
        _autoStealBeam.Transparency = NumberSequence.new(0.3)
        _autoStealBeam.Parent = Workspace
    end
    _autoStealBeam.Attachment0 = _autoStealAtt0
    _autoStealBeam.Attachment1 = _autoStealAtt1
end

local function _autoStealRefreshUi()
    if _autoStealMainButton then
        _autoStealMainButton.Text = _autoStealEnabled and "AUTO STEAL: ON" or "AUTO STEAL: OFF"
        _autoStealMainButton.BackgroundColor3 = _autoStealEnabled and Color3.fromRGB(30, 150, 90) or THEME.Danger
    end
    if _autoStealModeButton then _autoStealModeButton.Text = "Modo: " .. string.upper(_autoStealMode) end
end

local function _autoStealBuildGui()
    if _autoStealGui then pcall(function() _autoStealGui:Destroy() end) end
    _autoStealGui = _createScreenGui("KYN_AutoStealGUI")
    _autoStealFrame = Instance.new("Frame")
    _autoStealFrame.Size = UDim2.new(0, 230, 0, 120)
    _autoStealFrame.Position = _loadGuiPos("AutoStealPanel", UDim2.new(0.05, 0, 0.35, 0))
    _autoStealFrame.BackgroundColor3 = THEME.FrameBg
    _autoStealFrame.BorderSizePixel = 0
    _autoStealFrame.Active = true
    _autoStealFrame.Draggable = true
    _autoStealFrame.Parent = _autoStealGui
    _bindGuiPosPersistence("AutoStealPanel", _autoStealFrame)
    Instance.new("UICorner", _autoStealFrame).CornerRadius = UDim.new(0, 10)
    local s = Instance.new("UIStroke", _autoStealFrame); s.Color = THEME.Accent; s.Thickness = 1.3
    local title = Instance.new("TextLabel", _autoStealFrame)
    title.Size = UDim2.new(1, -10, 0, 24)
    title.Position = UDim2.new(0, 8, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = "⚡ KYN HUB — AUTO STEAL"
    title.TextColor3 = THEME.TitleText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    _autoStealTargetLabel = Instance.new("TextLabel", _autoStealFrame)
    _autoStealTargetLabel.Size = UDim2.new(1, -10, 0, 20)
    _autoStealTargetLabel.Position = UDim2.new(0, 8, 0, 28)
    _autoStealTargetLabel.BackgroundTransparency = 1
    _autoStealTargetLabel.Text = "Objetivo: Ninguno"
    _autoStealTargetLabel.TextColor3 = THEME.Accent
    _autoStealTargetLabel.Font = Enum.Font.GothamMedium
    _autoStealTargetLabel.TextSize = 11
    _autoStealTargetLabel.TextXAlignment = Enum.TextXAlignment.Left
    _autoStealMainButton = Instance.new("TextButton", _autoStealFrame)
    _autoStealMainButton.Size = UDim2.new(1, -16, 0, 34)
    _autoStealMainButton.Position = UDim2.new(0, 8, 0, 52)
    _autoStealMainButton.Font = Enum.Font.GothamBold
    _autoStealMainButton.TextSize = 12
    _autoStealMainButton.TextColor3 = Color3.new(1, 1, 1)
    _autoStealMainButton.AutoButtonColor = false
    Instance.new("UICorner", _autoStealMainButton).CornerRadius = UDim.new(0, 7)
    _autoStealModeButton = Instance.new("TextButton", _autoStealFrame)
    _autoStealModeButton.Size = UDim2.new(1, -16, 0, 24)
    _autoStealModeButton.Position = UDim2.new(0, 8, 0, 90)
    _autoStealModeButton.BackgroundColor3 = THEME.FrameBg2
    _autoStealModeButton.Font = Enum.Font.GothamBold
    _autoStealModeButton.TextSize = 11
    _autoStealModeButton.TextColor3 = THEME.TextLight
    Instance.new("UICorner", _autoStealModeButton).CornerRadius = UDim.new(0, 6)
    _autoStealMainButton.MouseButton1Click:Connect(function() _autoStealEnabled = not _autoStealEnabled _autoStealRefreshUi() end)
    _autoStealModeButton.MouseButton1Click:Connect(function() if _autoStealMode == "Priority" then _autoStealMode = "Nearest" elseif _autoStealMode == "Nearest" then _autoStealMode = "Highest" else _autoStealMode = "Priority" end _autoStealRefreshUi() end)
    _autoStealRefreshUi()
end

local function _autoStealStartLoop()
    if _autoStealLoopThread then return end
    _autoStealFeatureRunning = true
    _autoStealLoopThread = task.spawn(function()
        while _autoStealFeatureRunning and _autoStealGui and _autoStealGui.Parent do
            task.wait(0.35)
            local target = _autoStealEnabled and _autoStealPickTarget(_autoStealGetPets()) or nil
            if _autoStealTargetLabel then _autoStealTargetLabel.Text = target and ("Objetivo: " .. target.name) or "Objetivo: Ninguno" end
            if target then
                local prompt = _autoStealFindPrompt(target.plot, target.slot)
                if prompt and prompt.Parent and prompt.Enabled then _autoStealExecute(prompt) end
            end
            _autoStealUpdateVisuals(target)
        end
        _autoStealLoopThread = nil
    end)
end

local function _setAutoStealFeature(state)
    if state then
        if not _autoStealGui then _autoStealBuildGui() end
        if _autoStealGui then _autoStealGui.Enabled = true end
        _autoStealStartLoop()
    else
        _autoStealFeatureRunning = false
        _autoStealEnabled = false
        _autoStealRefreshUi()
        _autoStealClearVisuals()
        if _autoStealGui then _autoStealGui.Enabled = false end
    end
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

local _desyncLoaded = false
local _desyncGui, _desyncPanel = nil, nil
local _desyncToggleButton = nil
local _desyncAutoToggleButton = nil
local _desyncStatusLabel = nil
local _desyncStatusCircle = nil
local _desyncCloneWatchConn = nil
local _desyncRubberbandLoop = nil
local _desyncServerGhost = nil
local _desyncWorldAddedConn = nil
local _desyncIsActive = false
local _desyncAutoActivate = SETTINGS.AutoDesyncAutoActivate and true or false
local _desyncStealEnabled = true
local _desyncStealSpeed = math.clamp(tonumber(SETTINGS.StealSpeedValue) or 25, 5, 100)
local _desyncStealMin, _desyncStealMax = 5, 100
local _desyncStealConn = nil
local _desyncLastPlayerPos = nil
local _desyncLagbackWarningEndTime = 0
local _desyncIgnoringTeleport = false
local _desyncToolName = "Quantum Cloner"
local _desyncCloneName = tostring(LocalPlayer.UserId) .. "_Clone"
local _desyncStealSpeedLabel = nil
local _desyncStealSliderBg = nil
local _desyncStealSliderFill = nil
local _desyncStealSliderKnob = nil

local _desyncHighlight = Instance.new("Highlight")
_desyncHighlight.Name = "KYN_RubberbandHighlight"
_desyncHighlight.FillTransparency = 0.5
_desyncHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
_desyncHighlight.Enabled = false
_desyncHighlight.Parent = _resolveGuiParent()

local function _desyncSetButtonUI()
    if not _desyncToggleButton then return end
    if _desyncIsActive then
        _desyncToggleButton.Text = "DESYNC: ACTIVADO"
        _desyncToggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        _desyncToggleButton.Text = "DESYNC: DESACTIVADO"
        _desyncToggleButton.BackgroundColor3 = THEME.FrameBg2
    end
end

local function _desyncUpdateStatusUI()
    if _desyncStatusLabel then
        _desyncStatusLabel.Text = _desyncIsActive and "Activador: Activado" or "Activador: Desactivado"
        _desyncStatusLabel.TextColor3 = _desyncIsActive and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(180, 180, 180)
    end
    if _desyncStatusCircle then
        _desyncStatusCircle.BackgroundColor3 = _desyncIsActive and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(90, 90, 95)
    end
    if _desyncAutoToggleButton then
        _desyncAutoToggleButton.Text = _desyncAutoActivate and "Auto desync: ON" or "Auto desync: OFF"
        _desyncAutoToggleButton.BackgroundColor3 = _desyncAutoActivate and Color3.fromRGB(40, 130, 65) or THEME.FrameBg2
    end
end

local function _desyncUpdateStealUI()
    if _desyncStealSpeedLabel then
        _desyncStealSpeedLabel.Text = "Velocidad: " .. tostring(_desyncStealSpeed)
    end
    local percent = (_desyncStealSpeed - _desyncStealMin) / (_desyncStealMax - _desyncStealMin)
    if _desyncStealSliderFill then _desyncStealSliderFill.Size = UDim2.new(percent, 0, 1, 0) end
    if _desyncStealSliderKnob then _desyncStealSliderKnob.Position = UDim2.new(percent, 0, 0.5, 0) end
end

local function _desyncEnsureStealLoop()
    if _desyncStealConn then return end
    _desyncStealConn = RunService.Heartbeat:Connect(function()
        if not _desyncStealEnabled then return end
        if LocalPlayer:GetAttribute("Stealing") ~= true then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then
            local md = hum.MoveDirection
            if md.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    md.X * _desyncStealSpeed,
                    hrp.AssemblyLinearVelocity.Y,
                    md.Z * _desyncStealSpeed
                )
            end
        end
    end)
end

local function _desyncCreateServerGhost(character)
    if _desyncServerGhost then _desyncServerGhost:Destroy() end
    _desyncServerGhost = Instance.new("Part")
    _desyncServerGhost.Name = "KYN_DesyncedServerPosition"
    _desyncServerGhost.Size = Vector3.new(2.5, 2.5, 2.5)
    _desyncServerGhost.Shape = Enum.PartType.Block
    _desyncServerGhost.Anchored = true
    _desyncServerGhost.CanCollide = false
    _desyncServerGhost.CanTouch = false
    _desyncServerGhost.CanQuery = false
    _desyncServerGhost.Material = Enum.Material.ForceField
    _desyncServerGhost.Color = Color3.fromRGB(0, 150, 255)
    _desyncServerGhost.Transparency = 0.2

    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if hrp then _desyncServerGhost.CFrame = hrp.CFrame end

    local bg = Instance.new("BillboardGui")
    bg.Name = "ServerPosGui"
    bg.Size = UDim2.new(0, 250, 0, 50)
    bg.StudsOffset = Vector3.new(0, 2.5, 0)
    bg.AlwaysOnTop = true
    bg.Parent = _desyncServerGhost

    local txt = Instance.new("TextLabel")
    txt.Name = "ServerText"
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = "Server Position"
    txt.TextColor3 = Color3.fromRGB(0, 200, 255)
    txt.TextStrokeTransparency = 0.2
    txt.Font = Enum.Font.GothamBold
    txt.TextScaled = true
    txt.Parent = bg

    _desyncServerGhost.Parent = Workspace
    _desyncHighlight.Adornee = _desyncServerGhost
    _desyncHighlight.Enabled = true
end

local function _desyncUpdateHighlight()
    if not _desyncIsActive or not _desyncServerGhost then return end
    local char = LocalPlayer.Character
    if not char then return end
    local realHRP = char:FindFirstChild("HumanoidRootPart")
    if not realHRP then return end

    local currentPos = realHRP.Position
    if _desyncLastPlayerPos then
        local distanceJump = (currentPos - _desyncLastPlayerPos).Magnitude
        if distanceJump > 2.5 then
            _desyncServerGhost.CFrame = realHRP.CFrame
            if not _desyncIgnoringTeleport then
                _desyncLagbackWarningEndTime = os.clock() + 2.5
            end
        end
    end
    _desyncLastPlayerPos = currentPos

    local distFromServerPos = (currentPos - _desyncServerGhost.Position).Magnitude
    local bg = _desyncServerGhost:FindFirstChild("ServerPosGui")
    local txt = bg and bg:FindFirstChild("ServerText")
    if os.clock() < _desyncLagbackWarningEndTime then
        _desyncServerGhost.Color = Color3.fromRGB(255, 0, 0)
        _desyncHighlight.FillColor = Color3.fromRGB(255, 0, 0)
        if txt then
            txt.Text = "⚠️ LAGBACK DETECTADO ⚠️"
            txt.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    else
        _desyncServerGhost.Color = Color3.fromRGB(0, 150, 255)
        _desyncHighlight.FillColor = Color3.fromRGB(0, 150, 255)
        if txt then
            txt.Text = string.format("Server Position\n(Distancia: %.1f studs)", distFromServerPos)
            txt.TextColor3 = Color3.fromRGB(0, 200, 255)
        end
    end
end

local function _desyncSetHiddenState(obj, invisible)
    if obj.Name == "KYN_RubberbandHighlight" or obj.Name == "KYN_DesyncedServerPosition" then return end
    if obj:IsA("BasePart") then
        obj.Transparency = invisible and 1 or 0
        obj.CanCollide = not invisible
    elseif obj:IsA("Decal") then
        obj.Transparency = invisible and 1 or 0
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
        obj.Enabled = not invisible
    elseif obj:IsA("Highlight") then
        obj.Enabled = not invisible
    elseif obj:IsA("Smoke") or obj:IsA("Fire") then
        obj.Enabled = not invisible
    elseif obj:IsA("ForceField") then
        obj.Visible = not invisible
    end
end

local function _desyncApplyToClone(clone, hide)
    for _, obj in ipairs(clone:GetDescendants()) do
        _desyncSetHiddenState(obj, hide)
    end
    if _desyncCloneWatchConn then _desyncCloneWatchConn:Disconnect() _desyncCloneWatchConn = nil end
    if hide then
        _desyncCloneWatchConn = clone.DescendantAdded:Connect(function(obj)
            _desyncSetHiddenState(obj, true)
        end)
    end
end

local function _desyncGetTool()
    local character = LocalPlayer.Character
    if character then
        local tool = character:FindFirstChild(_desyncToolName)
        if tool and tool:IsA("Tool") then return tool end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild(_desyncToolName)
        if tool and tool:IsA("Tool") then return tool end
    end
    return nil
end

local function _desyncEquipAndUseTool()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local tool = _desyncGetTool()
    if not tool then return false end
    if tool.Parent ~= character then
        humanoid:EquipTool(tool)
        task.wait(0.15)
    end
    pcall(function() tool:Activate() end)
    return true
end

local function _desyncTryFindClone(timeoutSeconds)
    local start = os.clock()
    while os.clock() - start < timeoutSeconds do
        local clone = Workspace:FindFirstChild(_desyncCloneName, true)
        if clone and clone:IsA("Model") then return clone end
        task.wait(0.05)
    end
    return nil
end

local function _desyncTriggerTeleportSafely()
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end
        local toolsFrames = playerGui:WaitForChild("ToolsFrames", 2)
        if not toolsFrames then return end
        local qcFrame = toolsFrames:WaitForChild("QuantumCloner", 2)
        if not qcFrame then return end
        local teleportBtn = qcFrame:WaitForChild("TeleportToClone", 2)
        if teleportBtn and teleportBtn:IsA("GuiButton") then
            _desyncIgnoringTeleport = true
            _safeFireSignal(teleportBtn.MouseButton1Up)
            qcFrame.Visible = false
            task.delay(1, function() _desyncIgnoringTeleport = false end)
        end
    end)
end

local function _desyncActivate()
    local char = LocalPlayer.Character
    if not char then return end
    _desyncIsActive = true
    _desyncSetButtonUI()
    _desyncUpdateStatusUI()
    _desyncCreateServerGhost(char)
    pcall(function() raknet.desync(true) end)
    _desyncLastPlayerPos = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position or nil
    if not _desyncRubberbandLoop then
        _desyncRubberbandLoop = RunService.Heartbeat:Connect(_desyncUpdateHighlight)
    end

    if _desyncEquipAndUseTool() then
        local clone = _desyncTryFindClone(2)
        if clone then
            _desyncApplyToClone(clone, true)
            task.wait(0.1)
            _desyncTriggerTeleportSafely()
        end
    end
end

local function _desyncDeactivate()
    _desyncIsActive = false
    _desyncSetButtonUI()
    _desyncUpdateStatusUI()
    pcall(function() raknet.desync(false) end)
    if _desyncRubberbandLoop then _desyncRubberbandLoop:Disconnect() _desyncRubberbandLoop = nil end
    if _desyncCloneWatchConn then _desyncCloneWatchConn:Disconnect() _desyncCloneWatchConn = nil end
    _desyncHighlight.Enabled = false
    if _desyncServerGhost then _desyncServerGhost:Destroy() _desyncServerGhost = nil end
    local clone = Workspace:FindFirstChild(_desyncCloneName, true)
    if clone then _desyncApplyToClone(clone, false) end
end

local function _buildDesyncPanel()
    if _desyncGui then pcall(function() _desyncGui:Destroy() end) end
    _desyncGui = _createScreenGui("KYN_DesyncGUI")

    _desyncPanel = Instance.new("Frame")
    _desyncPanel.Name = "KYN_DesyncPanel"
    _desyncPanel.Size = UDim2.new(0, 250, 0, 250)
    _desyncPanel.Position = _loadGuiPos("DesyncPanel", UDim2.new(1, -265, 0.55, -125))
    _desyncPanel.BackgroundColor3 = THEME.FrameBg
    _desyncPanel.BorderSizePixel = 0
    _desyncPanel.Active = true
    _desyncPanel.Draggable = true
    _desyncPanel.Parent = _desyncGui
    _bindGuiPosPersistence("DesyncPanel", _desyncPanel)
    Instance.new("UICorner", _desyncPanel).CornerRadius = UDim.new(0, 10)
    local panelStroke = Instance.new("UIStroke", _desyncPanel)
    panelStroke.Color = THEME.Accent
    panelStroke.Thickness = 1.4

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 25)
    title.Position = UDim2.new(0, 10, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = "⚡ KYN Desync"
    title.TextColor3 = THEME.TitleText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = _desyncPanel

    _desyncStatusCircle = Instance.new("Frame")
    _desyncStatusCircle.Size = UDim2.new(0, 12, 0, 12)
    _desyncStatusCircle.Position = UDim2.new(0, 12, 0, 38)
    _desyncStatusCircle.BackgroundColor3 = Color3.fromRGB(90, 90, 95)
    _desyncStatusCircle.BorderSizePixel = 0
    _desyncStatusCircle.Parent = _desyncPanel
    Instance.new("UICorner", _desyncStatusCircle).CornerRadius = UDim.new(1, 0)

    _desyncStatusLabel = Instance.new("TextLabel")
    _desyncStatusLabel.Size = UDim2.new(1, -32, 0, 18)
    _desyncStatusLabel.Position = UDim2.new(0, 30, 0, 35)
    _desyncStatusLabel.BackgroundTransparency = 1
    _desyncStatusLabel.Text = "Activador: Desactivado"
    _desyncStatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    _desyncStatusLabel.Font = Enum.Font.GothamMedium
    _desyncStatusLabel.TextSize = 13
    _desyncStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    _desyncStatusLabel.Parent = _desyncPanel

    _desyncAutoToggleButton = Instance.new("TextButton")
    _desyncAutoToggleButton.Size = UDim2.new(1, -20, 0, 32)
    _desyncAutoToggleButton.Position = UDim2.new(0, 10, 0, 58)
    _desyncAutoToggleButton.BackgroundColor3 = THEME.FrameBg2
    _desyncAutoToggleButton.TextColor3 = THEME.TextLight
    _desyncAutoToggleButton.Font = Enum.Font.GothamBold
    _desyncAutoToggleButton.TextSize = 13
    _desyncAutoToggleButton.AutoButtonColor = true
    _desyncAutoToggleButton.Parent = _desyncPanel
    Instance.new("UICorner", _desyncAutoToggleButton).CornerRadius = UDim.new(0, 8)

    _desyncToggleButton = Instance.new("TextButton")
    _desyncToggleButton.Size = UDim2.new(1, -20, 0, 45)
    _desyncToggleButton.Position = UDim2.new(0, 10, 0, 98)
    _desyncToggleButton.BackgroundColor3 = THEME.FrameBg2
    _desyncToggleButton.TextColor3 = Color3.new(1, 1, 1)
    _desyncToggleButton.Font = Enum.Font.GothamBold
    _desyncToggleButton.TextScaled = true
    _desyncToggleButton.AutoButtonColor = true
    _desyncToggleButton.Parent = _desyncPanel
    Instance.new("UICorner", _desyncToggleButton).CornerRadius = UDim.new(0, 8)

    _desyncStealSpeedLabel = Instance.new("TextLabel")
    _desyncStealSpeedLabel.Size = UDim2.new(1, -20, 0, 20)
    _desyncStealSpeedLabel.Position = UDim2.new(0, 10, 0, 152)
    _desyncStealSpeedLabel.BackgroundTransparency = 1
    _desyncStealSpeedLabel.Text = "Velocidad: " .. tostring(_desyncStealSpeed)
    _desyncStealSpeedLabel.TextColor3 = THEME.TextLight
    _desyncStealSpeedLabel.Font = Enum.Font.GothamBold
    _desyncStealSpeedLabel.TextSize = 13
    _desyncStealSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    _desyncStealSpeedLabel.Parent = _desyncPanel

    _desyncStealSliderBg = Instance.new("Frame")
    _desyncStealSliderBg.Size = UDim2.new(1, -20, 0, 6)
    _desyncStealSliderBg.Position = UDim2.new(0, 10, 0, 178)
    _desyncStealSliderBg.BackgroundColor3 = Color3.fromRGB(40, 42, 48)
    _desyncStealSliderBg.BorderSizePixel = 0
    _desyncStealSliderBg.Parent = _desyncPanel
    Instance.new("UICorner", _desyncStealSliderBg).CornerRadius = UDim.new(1, 0)

    _desyncStealSliderFill = Instance.new("Frame")
    _desyncStealSliderFill.Size = UDim2.new(0, 0, 1, 0)
    _desyncStealSliderFill.BackgroundColor3 = THEME.Accent
    _desyncStealSliderFill.BorderSizePixel = 0
    _desyncStealSliderFill.Parent = _desyncStealSliderBg
    Instance.new("UICorner", _desyncStealSliderFill).CornerRadius = UDim.new(1, 0)

    _desyncStealSliderKnob = Instance.new("Frame")
    _desyncStealSliderKnob.Size = UDim2.new(0, 14, 0, 14)
    _desyncStealSliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    _desyncStealSliderKnob.Position = UDim2.new(0, 0, 0.5, 0)
    _desyncStealSliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    _desyncStealSliderKnob.Parent = _desyncStealSliderBg
    Instance.new("UICorner", _desyncStealSliderKnob).CornerRadius = UDim.new(1, 0)

    _desyncToggleButton.MouseButton1Click:Connect(function()
        if _desyncIsActive then _desyncDeactivate() else _desyncActivate() end
    end)
    _desyncAutoToggleButton.MouseButton1Click:Connect(function()
        _desyncAutoActivate = not _desyncAutoActivate
        setSetting("AutoDesyncAutoActivate", _desyncAutoActivate)
        _desyncUpdateStatusUI()
        if _desyncAutoActivate and not _desyncIsActive then
            _desyncActivate()
        end
    end)
    do
        local sliderDragging = false
        local function updateSlider(input)
            if not _desyncStealSliderBg then return end
            local pos = math.clamp(input.Position.X - _desyncStealSliderBg.AbsolutePosition.X, 0, _desyncStealSliderBg.AbsoluteSize.X)
            local percent = pos / _desyncStealSliderBg.AbsoluteSize.X
            _desyncStealSpeed = math.floor(_desyncStealMin + (percent * (_desyncStealMax - _desyncStealMin)))
            setRawSetting("StealSpeedValue", _desyncStealSpeed)
            _desyncUpdateStealUI()
        end
        _desyncStealSliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliderDragging = true
                updateSlider(input)
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliderDragging = false
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)
    end
    _desyncSetButtonUI()
    _desyncUpdateStatusUI()
    _desyncUpdateStealUI()
end

local function _loadDesync()
    if _desyncLoaded then
        if _desyncGui then _desyncGui.Enabled = true end
        return
    end
    _desyncLoaded = true
    _buildDesyncPanel()
    _desyncEnsureStealLoop()
    if _desyncAutoActivate and not _desyncIsActive then
        task.spawn(function()
            task.wait(0.2)
            _desyncActivate()
        end)
    end
    if not _desyncWorldAddedConn then
        _desyncWorldAddedConn = Workspace.ChildAdded:Connect(function(child)
            if _desyncIsActive and child.Name == _desyncCloneName and child:IsA("Model") then
                _desyncApplyToClone(child, true)
            end
        end)
    end
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
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        local tf = pg:FindFirstChild("ToolsFrames")
        if not tf then return end

        local tpButton = nil
        local timeout = tick() + 2
        while tick() < timeout and not tpButton do
            local cloneUI = tf:FindFirstChild("QuantumCloner")
            if cloneUI then
                tpButton = cloneUI:FindFirstChild("TeleportToClone", true)
            end
            if not tpButton then task.wait(0.05) end
        end
        if not tpButton then
            warn("[KYN Hub] No se encontró botón TeleportToClone.")
            return
        end

        pcall(function()
            -- Igual al comportamiento del script original: usar MouseButton1Up del botón TP.
            if not _safeFireSignal(tpButton.MouseButton1Up) and tpButton:IsA("GuiButton") then
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
                if player ~= LocalPlayer then
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
    if _arEnabled and _antiKnockbackController then task.wait(0.2); _antiKnockbackController.Enable() end
    if _antiTorretEnabled then _antiTorretStart() else _antiTorretStop() end
end)
if LocalPlayer.Character and _arEnabled and _antiKnockbackController then
    task.spawn(function() task.wait(0.2); _antiKnockbackController.Enable() end)
end

-- REGISTRAR FEATURES
_G.KYNAddToggle("Main", {
    Name = "Auto Steal",
    Default = SETTINGS.AutoSteal,
    Callback = function(state)
        setSetting("AutoSteal", state)
        _setAutoStealFeature(state)
    end
})
_G.KYNAddToggle("Main", {
    Name = "Auto Desync",
    Default = SETTINGS.AutoDesync,
    Callback = function(state)
        setSetting("AutoDesync", state)
        if state then
            _loadDesync()
        else
            _desyncDeactivate()
            if _desyncGui then _desyncGui.Enabled = false end
            if _desyncPanel then _desyncPanel.Visible = false end
        end
    end
})
_G.KYNAddToggle("Main", {
    Name = "Mostrar botón Auto Clone",
    Default = SETTINGS.ShowAutoCloneButton,
    Callback = function(state)
        setSetting("ShowAutoCloneButton", state)
        cloneDragFrame.Visible = state
    end
})

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
