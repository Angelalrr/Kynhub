local Bootstrap = {}

function Bootstrap.resolveLocalPlayer(players, timeoutSteps, stepDelay)
    local lp = players.LocalPlayer
    if lp then return lp end

    local steps = tonumber(timeoutSteps) or 120
    local delayTime = tonumber(stepDelay) or 0
    for _ = 1, steps do
        players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        lp = players.LocalPlayer
        if lp then break end
        if delayTime > 0 then
            task.wait(delayTime)
        end
    end
    return lp
end

function Bootstrap.createScreenGui(opts)
    local sg = Instance.new("ScreenGui")
    sg.Name = opts.Name or "KYNHubGUI"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local coreGui = opts.CoreGui
    local playerGui = opts.PlayerGui
    local players = opts.Players

    local okCore = pcall(function()
        if coreGui then sg.Parent = coreGui end
    end)

    if (not okCore) or (not sg.Parent) then
        pcall(function()
            if playerGui then sg.Parent = playerGui end
        end)
    end

    if not sg.Parent and players and players.LocalPlayer then
        sg.Parent = players.LocalPlayer:WaitForChild("PlayerGui")
    end

    return sg
end

return Bootstrap
