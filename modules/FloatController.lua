local FloatController = {}
FloatController.__index = FloatController

function FloatController.new(config)
    local self = setmetatable({}, FloatController)
    self.Player = config.Player
    self.RunService = config.RunService
    self.TweenService = config.TweenService
    self.Button = config.Button
    self.OnColor = config.OnColor
    self.OffColor = config.OffColor
    self.StudsToRise = config.StudsToRise or 9
    self.RiseSpeed = config.RiseSpeed or 15

    self.Enabled = false
    self.Connection = nil
    self.ActiveLV = nil
    self.ActiveAttachment = nil
    self.TargetHeight = 0

    return self
end

function FloatController:_safeSetButtonColor(color)
    if not self.Button or not color then return end
    pcall(function()
        self.TweenService:Create(self.Button, TweenInfo.new(0.1), {BackgroundColor3 = color}):Play()
    end)
end

function FloatController:stop()
    self.Enabled = false
    if self.Connection and typeof(self.Connection) == "RBXScriptConnection" then
        self.Connection:Disconnect()
    end
    self.Connection = nil

    if self.ActiveLV then self.ActiveLV:Destroy() self.ActiveLV = nil end
    if self.ActiveAttachment then self.ActiveAttachment:Destroy() self.ActiveAttachment = nil end
    self:_safeSetButtonColor(self.OffColor)
end

function FloatController:start()
    self:stop()

    local character = self.Player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or humanoid.Health <= 0 then return end

    self.TargetHeight = root.Position.Y + self.StudsToRise
    self.Enabled = true
    self:_safeSetButtonColor(self.OnColor)

    self.ActiveAttachment = Instance.new("Attachment")
    self.ActiveAttachment.Parent = root

    self.ActiveLV = Instance.new("LinearVelocity")
    self.ActiveLV.Attachment0 = self.ActiveAttachment
    self.ActiveLV.MaxForce = math.huge
    self.ActiveLV.RelativeTo = Enum.ActuatorRelativeTo.World
    self.ActiveLV.Parent = root

    self.Connection = self.RunService.RenderStepped:Connect(function()
        local currentCharacter = self.Player.Character
        if not currentCharacter then self:stop() return end

        local currentRoot = currentCharacter:FindFirstChild("HumanoidRootPart")
        local currentHumanoid = currentCharacter:FindFirstChildOfClass("Humanoid")
        if not currentRoot or not currentHumanoid or currentHumanoid.Health <= 0 then
            self:stop()
            return
        end

        local yVelocity = 0
        if currentRoot.Position.Y < self.TargetHeight - 0.5 then
            yVelocity = self.RiseSpeed
        end

        if not self.ActiveLV or self.ActiveLV.Parent ~= currentRoot then
            self:stop()
            return
        end

        self.ActiveLV.VectorVelocity = (currentHumanoid.MoveDirection * currentHumanoid.WalkSpeed) + Vector3.new(0, yVelocity, 0)
    end)
end

function FloatController:toggle()
    if self.Enabled then
        self:stop()
    else
        self:start()
    end
end

return FloatController
