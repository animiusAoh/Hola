local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local events = ReplicatedStorage:WaitForChild("Events")
local punchRemote = events:WaitForChild("Punch")

local hitDelays = {
    [1] = 3.19,
    [2] = 4.00,
    [3] = 3.24,
    [4] = 4.00,
    [5] = 4.25
}

local lastPunch = 0
local combo = 0
local lastComboTime = 0
local isPunching = false

local scriptEnabled = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Z then
        scriptEnabled = not scriptEnabled
        if scriptEnabled then
            print("Script Activado")
        else
            print("Script Desactivado")
        end
    end
end)

local function doPunch(isCharged)
    if not scriptEnabled then return end
    
    local now = tick()
    
    if isPunching then return end
    
    if now - lastComboTime > 1.5 then
        combo = 0
    end
    
    local nextCombo = combo + 1
    if nextCombo > 5 then
        nextCombo = 1
    end
    
    local currentDelay = hitDelays[nextCombo] or 0.22
    
    if now - lastPunch < currentDelay then
        return
    end
    
    isPunching = true
    lastPunch = now
    lastComboTime = now
    combo = nextCombo
    
    local v4 = isCharged and 0.35 or 0
    local v5 = currentDelay
    
    punchRemote:FireServer(v4, v5, combo)
    
    task.delay(currentDelay, function()
        isPunching = false
    end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        doPunch(false)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonX then
        doPunch(true)
    end
end)

local function isHoldingSomeone(character)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("AlignPosition") or obj:IsA("VectorForce") or obj:IsA("Attachment") then
            if obj.Parent and obj.Parent:IsDescendantOf(character) then
                return true
            end
        end
    end
    return false
end

local function setup(character)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    local humanoid = character:WaitForChild("Humanoid", 5)

    if not humanoidRootPart or not humanoid then return end

    RunService.Heartbeat:Connect(function()
        if not scriptEnabled then return end
        if not character or not character:IsDescendantOf(workspace) then return end
        
        if isHoldingSomeone(character) then
            return
        end
        
        local isGrabbed =
            humanoidRootPart:FindFirstChildWhichIsA("AlignPosition") or
            humanoidRootPart:FindFirstChildWhichIsA("BodyPosition") or
            humanoidRootPart:FindFirstChildWhichIsA("VectorForce") or
            humanoidRootPart:FindFirstChildWhichIsA("BodyMover") or
            humanoidRootPart:FindFirstChildWhichIsA("AlignOrientation")

        if isGrabbed and math.random() < 0.8 then
            humanoid.PlatformStand = false
            local currentState = humanoid:GetState()
            if currentState == Enum.HumanoidStateType.Physics or currentState == Enum.HumanoidStateType.Ragdoll then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end)
end

if player.Character then
    setup(player.Character)
end

Players.LocalPlayer.CharacterAdded:Connect(setup)
