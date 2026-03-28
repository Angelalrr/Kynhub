local _freezeEnabled = false
local _freezeAnimConns = {}
local _freezeCharacter = nil

local function _freezeDisconnectConns()
    for _, c in ipairs(_freezeAnimConns) do
        pcall(function() c:Disconnect() end)
    end
    _freezeAnimConns = {}
end

local function _freezeApplyToAnimator(animator, freezeState)
    if not animator then return end
    -- Freeze all currently playing tracks
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
        pcall(function() 
            track:AdjustSpeed(freezeState and 0 or 1) 
        end)
    end
end

local function _freezeBindAnimator(animator)
    if not animator then return end
    _freezeDisconnectConns()
    _freezeApplyToAnimator(animator, _freezeEnabled)
    
    -- Detect all new animations being played and freeze them immediately
    table.insert(_freezeAnimConns, animator.AnimationPlayed:Connect(function(track)
        if _freezeEnabled and track then
            pcall(function() 
                task.wait(0.01) -- Small delay to ensure track is ready
                track:AdjustSpeed(0) 
            end)
        end
    end))
    
    -- Also listen to state changes in humanoid to catch all animations
    local humanoid = animator.Parent
    if humanoid and humanoid:IsA("Humanoid") then
        table.insert(_freezeAnimConns, humanoid.StateChanged:Connect(function(oldState, newState)
            if _freezeEnabled then
                task.wait(0.02)
                _freezeApplyToAnimator(animator, true)
            end
        end))
    end
end

local function _setFreezeAnims(state)
    _freezeEnabled = state and true or false
    local character = LocalPlayer.Character
    if not character then return end
    
    _freezeCharacter = character
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    local animator = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 2)
    if not animator then return end

    _freezeBindAnimator(animator)
    _freezeApplyToAnimator(animator, _freezeEnabled)
    
    if not _freezeEnabled then
        _freezeDisconnectConns()
    end
end
