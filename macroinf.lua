local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local events = ReplicatedStorage:WaitForChild("Events")
local punchRemote = events:WaitForChild("Punch")

-- Delays exactos para cada combo (1 al 5)
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

local function doPunch(isCharged)
    local now = tick()
    
    if isPunching then return end
    
    -- Reiniciar combo si ha pasado más de 1.5 segundos sin golpear
    if now - lastComboTime > 1.5 then
        combo = 0
    end
    
    -- Determinar el índice del Siguiente golpe
    local nextCombo = combo + 1
    if nextCombo > 5 then
        nextCombo = 1
    end
    
    local currentDelay = hitDelays[nextCombo] or 0.22
    
    -- Comprobar Cooldown del golpe actual
    if now - lastPunch < currentDelay then
        return
    end
    
    -- Actualizar variables de control
    isPunching = true
    lastPunch = now
    lastComboTime = now
    combo = nextCombo
    
    local v4 = isCharged and 0.35 or 0
    local v5 = currentDelay
    
    -- Enviar evento al servidor
    punchRemote:FireServer(v4, v5, combo)
    
    -- Desbloquear el estado de golpe justo cuando termina el tiempo estipulado
    task.delay(currentDelay, function()
        isPunching = false
    end)
end

-- Entrada para Ratón (Golpe Normal)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        doPunch(false)
    end
end)

-- Entrada para Mando / Gamepad (Golpe Cargado)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonX then
        doPunch(true)
    end
end)

-- Sistema Antigrab / Anti-agarre
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

        if isGrabbed and math.random() < 0.8 then
            humanoid.PlatformStand = false
            local currentState = humanoid:GetState()
            if currentState == Enum.HumanoidStateType.Physics or currentState == Enum.HumanoidStateType.Ragdoll then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end)
end

-- Inicialización de Character y Respawn
if player.Character then
    setup(player.Character)
end

player.CharacterAdded:Connect(setup)

print("Script optimizado cargado con éxito.")
