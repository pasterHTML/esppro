-- ============================================================
-- 🔥 PRO ESP + AIMBOT + WALLBANG
-- Версия: 10.1
-- Бинды: Shift (меню) | G (ESP) | H (Аимбот) | L (Wallbang)
-- ============================================================

-- 🔓 МЯГКИЙ БАЙПАС
for i, v in next, getgc(true) do
    if typeof(v) == 'function' and getfenv(v).script and getfenv(v).script.Parent == nil then
        if not isourclosure(v) then
            local source = debug.info(v, 's')
            if source and (source:find('Anti') or source:find('Detect')) then
                pcall(function()
                    hookfunction(v, function() return end)
                end)
            end
        end
    end
end

-- ============================================================
-- ⚙️ ПЕРЕМЕННЫЕ
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local AimbotEnabled = true
local ESPEnabled = false
local WallbangEnabled = false
local MaxDistance = 300
local ESPRadius = 300
local ESPObjects = {}

-- ============================================================
-- 🔥 WALLBANG (СТРЕЛЬБА ЧЕРЕЗ СТЕНЫ)
-- ============================================================

local oldFindPartOnRay = workspace.FindPartOnRay

local function enableWallbang()
    WallbangEnabled = true
    workspace.FindPartOnRay = function(ray, ignore, ...)
        if WallbangEnabled then
            local result = oldFindPartOnRay(ray, ignore, ...)
            if result and result:IsA("BasePart") and result.CanCollide and not result.Parent:FindFirstChild("Humanoid") then
                return nil
            end
            return result
        end
        return oldFindPartOnRay(ray, ignore, ...)
    end
    print("🧱 Wallbang включён!")
end

local function disableWallbang()
    WallbangEnabled = false
    workspace.FindPartOnRay = oldFindPartOnRay
    print("🧱 Wallbang выключен.")
end

-- ============================================================
-- 🎯 ФУНКЦИИ ПРОВЕРКИ
-- ============================================================

local function isEnemy(player)
    if player.Team and LocalPlayer.Team then
        return player.Team ~= LocalPlayer.Team
    end
    return true
end

local function isAlive(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end

-- ============================================================
-- 🎯 ФУНКЦИЯ НАХОЖДЕНИЯ БЛИЖАЙШЕГО ВРАГА
-- ============================================================

local function getClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = MaxDistance

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        if not isAlive(player) then continue end
        if not isEnemy(player) then continue end
        
        local head = player.Character:FindFirstChild("Head")
        if not head then continue end

        local distance = (head.Position - Camera.CFrame.Position).Magnitude

        -- Если Wallbang выключен — проверяем стены
        if not WallbangEnabled then
            local ray = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * distance)
            local hit, _ = workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
            if hit and not hit:IsDescendantOf(player.Character) then
                continue
            end
        end

        if distance <= shortestDistance then
            closestEnemy = player
            shortestDistance = distance
        end
    end

    return closestEnemy
end

-- ============================================================
-- 🔫 АИМБОТ + АВТО-СТРЕЛЬБА
-- ============================================================

local lastShotTime = 0
local shootCooldown = 0.08

RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end
    if not LocalPlayer.Character then return end
    
    local target = getClosestEnemy()
    if not target then return end
    
    local head = target.Character:FindFirstChild("Head")
    if not head then return end
    
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
    
    -- Авто-стрельба
    local currentTime = tick()
    if currentTime - lastShotTime >= shootCooldown then
        Mouse.Button1Down:Fire()
        task.wait(0.02)
        Mouse.Button1Up:Fire()
        lastShotTime = currentTime
    end
end)

-- ============================================================
-- 🟢 ESP
-- ============================================================

local function toggleESP()
    ESPEnabled = not ESPEnabled

    for _, v in pairs(ESPObjects) do
        if v then pcall(function() v:Destroy() end) end
    end
    ESPObjects = {}

    if ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not player.Character then continue end
            if not isAlive(player) then continue end
            if not isEnemy(player) then continue end

            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
            if distance > ESPRadius then continue end

            -- Highlight (красивая обводка)
            local highlight = Instance.new("Highlight")
            highlight.Parent = char
            highlight.FillColor = Color3.fromRGB(255, 50, 50)
            highlight.FillTransparency = 0.6
            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineTransparency = 0.1
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            table.insert(ESPObjects, highlight)

            -- Billboard с именем и здоровьем
            local head = char:FindFirstChild("Head")
            if head then
                local billboard = Instance.new("BillboardGui")
                billboard.Parent = head
                billboard.Adornee = head
                billboard.Size = UDim2.new(0, 150, 0, 40)
                billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                billboard.AlwaysOnTop = true
                billboard.MaxDistance = ESPRadius

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Parent = billboard
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                
                local humanoid = char:FindFirstChild("Humanoid")
                local health = humanoid and math.floor(humanoid.Health) or 0
                nameLabel.Text = player.Name .. " [" .. health .. " HP]"
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextSize = 16
                nameLabel.TextScaled = true
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextStrokeTransparency = 0.2
                nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

                table.insert(ESPObjects, billboard)
            end
        end
    end
end

-- ============================================================
-- 🔄 ПЕРЕЗАХОД
-- ============================================================

local function rejoinServer()
    TeleportService:Teleport(game.PlaceId, LocalPlayer, {})
end

-- ============================================================
-- 📊 GUI
-- ============================================================

local function createGUI()
    local existing = CoreGui:FindFirstChild("M")
    if existing then existing:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "M"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.Parent = MainFrame
    corner.CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = "🔥 PRO"
    Title.TextSize = 20
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = MainFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = CloseButton
    closeCorner.CornerRadius = UDim.new(0, 6)

    local function updateButton(button, state)
        button.Text = state and button.Name .. ": ON" or button.Name .. ": OFF"
        button.BackgroundColor3 = state and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(150, 50, 50)
    end

    -- Aimbot
    local AimbotButton = Instance.new("TextButton")
    AimbotButton.Size = UDim2.new(0, 250, 0, 40)
    AimbotButton.Position = UDim2.new(0.5, -125, 0, 50)
    AimbotButton.Name = "Aimbot"
    updateButton(AimbotButton, AimbotEnabled)
    AimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimbotButton.Font = Enum.Font.GothamBold
    AimbotButton.BorderSizePixel = 0
    AimbotButton.Parent = MainFrame

    local aimCorner = Instance.new("UICorner")
    aimCorner.Parent = AimbotButton
    aimCorner.CornerRadius = UDim.new(0, 8)

    AimbotButton.MouseButton1Click:Connect(function()
        AimbotEnabled = not AimbotEnabled
        updateButton(AimbotButton, AimbotEnabled)
    end)

    -- Wallbang
    local WallbangButton = Instance.new("TextButton")
    WallbangButton.Size = UDim2.new(0, 250, 0, 40)
    WallbangButton.Position = UDim2.new(0.5, -125, 0, 100)
    WallbangButton.Name = "Wallbang"
    updateButton(WallbangButton, WallbangEnabled)
    WallbangButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    WallbangButton.Font = Enum.Font.GothamBold
    WallbangButton.BorderSizePixel = 0
    WallbangButton.Parent = MainFrame

    local wallCorner = Instance.new("UICorner")
    wallCorner.Parent = WallbangButton
    wallCorner.CornerRadius = UDim.new(0, 8)

    WallbangButton.MouseButton1Click:Connect(function()
        WallbangEnabled = not WallbangEnabled
        updateButton(WallbangButton, WallbangEnabled)
        if WallbangEnabled then
            enableWallbang()
        else
            disableWallbang()
        end
    end)

    -- ESP
    local ESPButton = Instance.new("TextButton")
    ESPButton.Size = UDim2.new(0, 250, 0, 40)
    ESPButton.Position = UDim2.new(0.5, -125, 0, 150)
    ESPButton.Name = "ESP"
    updateButton(ESPButton, ESPEnabled)
    ESPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ESPButton.Font = Enum.Font.GothamBold
    ESPButton.BorderSizePixel = 0
    ESPButton.Parent = MainFrame

    local espCorner = Instance.new("UICorner")
    espCorner.Parent = ESPButton
    espCorner.CornerRadius = UDim.new(0, 8)

    ESPButton.MouseButton1Click:Connect(function()
        toggleESP()
        updateButton(ESPButton, ESPEnabled)
    end)

    -- Rejoin
    local RejoinButton = Instance.new("TextButton")
    RejoinButton.Size = UDim2.new(0, 250, 0, 40)
    RejoinButton.Position = UDim2.new(0.5, -125, 0, 200)
    RejoinButton.Text = "Rejoin"
    RejoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RejoinButton.Font = Enum.Font.GothamBold
    RejoinButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    RejoinButton.BorderSizePixel = 0
    RejoinButton.Parent = MainFrame

    local rejoinCorner = Instance.new("UICorner")
    rejoinCorner.Parent = RejoinButton
    rejoinCorner.CornerRadius = UDim.new(0, 8)

    RejoinButton.MouseButton1Click:Connect(rejoinServer)

    -- Exit
    local ExitButton = Instance.new("TextButton")
    ExitButton.Size = UDim2.new(0, 250, 0, 40)
    ExitButton.Position = UDim2.new(0.5, -125, 0, 250)
    ExitButton.Text = "Exit"
    ExitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExitButton.Font = Enum.Font.GothamBold
    ExitButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    ExitButton.BorderSizePixel = 0
    ExitButton.Parent = MainFrame

    local exitCorner = Instance.new("UICorner")
    exitCorner.Parent = ExitButton
    exitCorner.CornerRadius = UDim.new(0, 8)

    ExitButton.MouseButton1Click:Connect(function()
        game:Shutdown()
    end)

    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)

    return ScreenGui
end

-- ============================================================
-- 👥 СОЗДАЁМ GUI
-- ============================================================

local guiInstance = createGUI()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if not CoreGui:FindFirstChild("M") then
        guiInstance = createGUI()
    end
end)

-- ============================================================
-- 👥 НОВЫЕ ИГРОКИ
-- ============================================================

Players.PlayerAdded:Connect(function()
    if ESPEnabled then
        toggleESP()
        toggleESP()
    end
end)

-- ============================================================
-- ⌨️ БИНДЫ
-- ============================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Правый Shift — меню
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end

    -- G — ESP
    if input.KeyCode == Enum.KeyCode.G then
        toggleESP()
        updateButton(ESPButton, ESPEnabled)
    end

    -- H — Аимбот
    if input.KeyCode == Enum.KeyCode.H then
        AimbotEnabled = not AimbotEnabled
        updateButton(AimbotButton, AimbotEnabled)
    end

    -- L — Wallbang (стрельба через стены)
    if input.KeyCode == Enum.KeyCode.L then
        WallbangEnabled = not WallbangEnabled
        updateButton(WallbangButton, WallbangEnabled)
        if WallbangEnabled then
            enableWallbang()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Wallbang",
                Text = "Включён! Стреляй сквозь стены",
                Duration = 1.5
            })
        else
            disableWallbang()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Wallbang",
                Text = "Выключен",
                Duration = 1.5
            })
        end
    end
end)

-- ============================================================
-- 📌 ИНФОРМАЦИЯ
-- ============================================================

print("🔥 PRO + WALLBANG загружен!")
print("🔹 Shift — меню")
print("🔹 G — ESP")
print("🔹 H — Аимбот (с авто-стрельбой)")
print("🔹 L — Wallbang (стрельба через стены)")
print("🎯 Аимбот включён по умолчанию")
