local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local events = ReplicatedStorage:WaitForChild("Events")
local punchRemote = events:WaitForChild("Punch")

local hitDelays = {
    3.19, -- combo 1
    4.00, -- combo 2
    3.24, -- combo 3
    4.00, -- combo 4
    4.25  -- combo 5
}

local lastPunch = 0
local combo = 0
local lastComboTime = 0
local isPunching = false

local function doPunch(isCharged)
    local now = tick()
    
    if isPunching then return end
    
    if now - lastComboTime > 1.5 then
        combo = 0
    end
    
    local currentDelay = hitDelays[combo + 1] or 0.22
    
    if now - lastPunch < currentDelay then
        return
    end
    
    isPunching = true
    lastPunch = now
    lastComboTime = now
    
    combo = combo + 1
    if combo > 5 then
        combo = 1
    end
    
    local v4 = isCharged and 0.35 or 0
    local v5 = hitDelays[combo]
    
    punchRemote:FireServer(v4, v5, combo)
    
    task.delay(currentDelay * 0.9, function()
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

local function setup(character)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    local humanoid = character:WaitForChild("Humanoid", 5)

    if not humanoidRootPart or not humanoid then return end

    RunService.Heartbeat:Connect(function()
        if not character or not character:IsDescendantOf(workspace) then return end
        
        local isGrabbed =
            humanoidRootPart:FindFirstChildWhichIsA("AlignPosition") or
            humanoidRootPart:FindFirstChildWhichIsA("BodyPosition") or
            humanoidRootPart:FindFirstChildWhichIsA("VectorForce") or
            humanoidRootPart:FindFirstChildWhichIsA("BodyMover") or
            humanoidRootPart:FindFirstChildWhichIsA("AlignOrientation")

        if isGrabbed and math.random() < 0.7 then
            humanoid.PlatformStand = false
            if humanoid:GetState() == Enum.HumanoidStateType.Physics or 
               humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end)
end

if player.Character then
    setup(player.Character)
end

player.CharacterAdded:Connect(setup)

print("Working")
