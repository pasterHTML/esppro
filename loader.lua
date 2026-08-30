-- ============================================================
-- 🎯 PRO ESP + AIMBOT
-- GitHub Version
-- ============================================================

-- Байпас
print("🔓 Запуск байпаса...")
local bypassed = 0
for i, v in next, getgc(true) do
    if typeof(v) == 'function' and getfenv(v).script and getfenv(v).script.Parent == nil then
        if not isourclosure(v) then
            local source = debug.info(v, 's')
            if source ~= '[C]' and not source:find('Network') and not source:find('PlayerGui.Client') then
                pcall(function()
                    hookfunction(v, function()
                        return coroutine.yield()
                    end)
                    bypassed = bypassed + 1
                end)
            end
        end
    end
end
print("🔓 Байпас завершён! Заменено функций: " .. bypassed)

-- Основной скрипт
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local espEnabled = false
local aimbotEnabled = false
local espData = {}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ProESP"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Parent = gui
mainFrame.Size = UDim2.new(0, 200, 0, 80)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -40)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true

local corner = Instance.new("UICorner")
corner.Parent = mainFrame
corner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "🎯 PRO ESP"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold

local espBtn = Instance.new("TextButton")
espBtn.Parent = mainFrame
espBtn.Size = UDim2.new(0, 80, 0, 30)
espBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
espBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
espBtn.Text = "ESP: OFF"
espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBtn.TextSize = 14
espBtn.Font = Enum.Font.GothamBold
espBtn.BorderSizePixel = 0

local espCorner = Instance.new("UICorner")
espCorner.Parent = espBtn
espCorner.CornerRadius = UDim.new(0, 6)

local aimBtn = Instance.new("TextButton")
aimBtn.Parent = mainFrame
aimBtn.Size = UDim2.new(0, 80, 0, 30)
aimBtn.Position = UDim2.new(0.5, 10, 0.55, 0)
aimBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
aimBtn.Text = "AIM: OFF"
aimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
aimBtn.TextSize = 14
aimBtn.Font = Enum.Font.GothamBold
aimBtn.BorderSizePixel = 0

local aimCorner = Instance.new("UICorner")
aimCorner.Parent = aimBtn
aimCorner.CornerRadius = UDim.new(0, 6)

-- Drag
local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Бинды
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.G then
        espEnabled = not espEnabled
        espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
        espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(40, 40, 60)
        
        if not espEnabled then
            for plr, data in pairs(espData) do
                pcall(function()
                    if data.highlight then data.highlight:Destroy() end
                    if data.billboard then data.billboard:Destroy() end
                end)
            end
            espData = {}
        end
    end
    
    if input.KeyCode == Enum.KeyCode.H then
        aimbotEnabled = not aimbotEnabled
        aimBtn.Text = aimbotEnabled and "AIM: ON" or "AIM: OFF"
        aimBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 60)
    end
end)

-- ESP
local function createESP(plr)
    if plr == player then return end
    if not plr.Character then return end
    
    local character = plr.Character
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return end
    
    if espData[plr] then
        pcall(function()
            if espData[plr].highlight then espData[plr].highlight:Destroy() end
            if espData[plr].billboard then espData[plr].billboard:Destroy() end
        end)
        espData[plr] = nil
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Parent = character
    highlight.FillColor = Color3.fromRGB(100, 200, 255)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(0, 150, 255)
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    local billboard = Instance.new("BillboardGui")
    billboard.Parent = head
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 200
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 18
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0.2
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    
    local healthBar = Instance.new("Frame")
    healthBar.Parent = billboard
    healthBar.Size = UDim2.new(1, 0, 0, 4)
    healthBar.Position = UDim2.new(0, 0, 1, 2)
    healthBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    healthBar.BorderSizePixel = 0
    
    local healthFill = Instance.new("Frame")
    healthFill.Parent = healthBar
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    healthFill.BorderSizePixel = 0
    
    local healthCorner = Instance.new("UICorner")
    healthCorner.Parent = healthBar
    healthCorner.CornerRadius = UDim.new(0, 2)
    
    espData[plr] = {
        highlight = highlight,
        billboard = billboard,
        nameLabel = nameLabel,
        healthFill = healthFill,
        healthBar = healthBar
    }
end

local function updateESP()
    if not espEnabled then return
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            if not espData[plr] or not espData[plr].highlight or not espData[plr].highlight.Parent then
                createESP(plr)
            end
            
            local data = espData[plr]
            if data and data.healthFill then
                local humanoid = plr.Character:FindFirstChild("Humanoid")
                if humanoid then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    data.healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
                    data.healthFill.BackgroundColor3 = healthPercent > 0.5 and Color3.fromRGB(0, 255, 100) or 
                                                       healthPercent > 0.25 and Color3.fromRGB(255, 200, 0) or 
                                                       Color3.fromRGB(255, 50, 50)
                end
            end
        end
    end
end

local function setupPlayer(plr)
    if plr == player then return end
    
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espEnabled then
            createESP(plr)
        end
    end)
    
    if plr.Character and espEnabled then
        task.wait(0.3)
        createESP(plr)
    end
end

Players.PlayerAdded:Connect(function(plr)
    setupPlayer(plr)
end)

for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= player then
        setupPlayer(plr)
    end
end

RunService.RenderStepped:Connect(function()
    if espEnabled then
        updateESP()
    end
end)

-- Аимбот
local function getClosestAlivePlayer()
    local closest = nil
    local minDist = math.huge
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == player then continue end
        if not plr.Character then continue end
        
        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = plr.Character:FindFirstChild("Humanoid")
        if not hrp or not humanoid then continue end
        if humanoid.Health <= 0 then continue end
        
        local head = plr.Character:FindFirstChild("Head")
        if not head then continue end
        
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {player.Character, plr.Character}
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        local origin = camera.CFrame.Position
        local direction = (head.Position - origin).Unit * 500
        local result = workspace:Raycast(origin, direction, rayParams)
        
        if result and not result.Instance:IsDescendantOf(plr.Character) then
            continue
        end
        
        local dist = (hrp.Position - camera.CFrame.Position).Magnitude
        if dist < minDist then
            minDist = dist
            closest = plr
        end
    end
    
    return closest
end

local function aimbot()
    if not aimbotEnabled then return end
    if not player.Character then return end
    
    local target = getClosestAlivePlayer()
    if not target then return end
    
    local head = target.Character:FindFirstChild("Head")
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local targetPos = head and head.Position or (hrp and hrp.Position)
    
    if targetPos then
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
    end
end

RunService.RenderStepped:Connect(function()
    aimbot()
end)

-- Открытие/закрытие GUI (Правый Shift)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

print("🎯 PRO ESP + AIMBOT загружен!")
print("🔹 Правый Shift — показать/скрыть меню")
print("🔹 G — включить/выключить ESP")
print("🔹 H — включить/выключить Аимбот")
