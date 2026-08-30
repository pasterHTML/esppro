-- ============================================================
-- 🔥 PRO ESP + AIMBOT (ОБЪЕДИНЁННЫЙ)
-- Версия: 3.0
-- ============================================================

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

local AimbotEnabled = true
local ESPEnabled = false
local MaxDistance = 300

local ESPObjects = {}
local ESPLines = {}

-- ============================================================
-- 🎯 ФУНКЦИЯ ПРОВЕРКИ ВРАГА
-- ============================================================

local function isEnemy(player)
    if player.Team and LocalPlayer.Team then
        return player.Team ~= LocalPlayer.Team
    end
    return true
end

-- ============================================================
-- 🎯 ФУНКЦИЯ НАХОЖДЕНИЯ БЛИЖАЙШЕГО ВРАГА
-- ============================================================

local function getClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = MaxDistance

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and isEnemy(player) then
            local head = player.Character.Head
            local distance = (head.Position - Camera.CFrame.Position).Magnitude

            -- Проверка видимости (не за стеной)
            local ray = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * distance)
            local hit, _ = workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)

            if distance <= shortestDistance and (not hit or hit:IsDescendantOf(player.Character)) then
                closestEnemy = player
                shortestDistance = distance
            end
        end
    end

    return closestEnemy
end

-- ============================================================
-- 🟢 ESP
-- ============================================================

local function toggleESP()
    ESPEnabled = not ESPEnabled

    -- Удаляем старые ESP
    for _, v in pairs(ESPObjects) do
        if v then pcall(function() v:Destroy() end) end
    end
    ESPObjects = {}

    -- Удаляем старые линии
    for _, v in pairs(ESPLines) do
        if v then pcall(function() v:Destroy() end) end
    end
    ESPLines = {}

    if ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and isEnemy(player) then
                local char = player.Character

                -- Обводка тела (BoxHandleAdornment)
                local box = Instance.new("BoxHandleAdornment")
                box.Size = char:GetExtentsSize()
                box.Adornee = char
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Color3 = Color3.new(1, 0, 0)
                box.Transparency = 0.5
                box.Parent = char
                table.insert(ESPObjects, box)

                -- Highlight (подсветка частей тела)
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        local highlight = Instance.new("Highlight")
                        highlight.Parent = part
                        highlight.Adornee = part
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.OutlineTransparency = 0
                        table.insert(ESPObjects, highlight)
                    end
                end

                -- Линия к голове
                local line = Drawing.new("Line")
                line.Color = Color3.new(1, 0, 0)
                line.Thickness = 2
                line.Transparency = 1
                line.Visible = true

                table.insert(ESPLines, line)

                -- Обновление линии через RenderStepped
                local conn
                conn = RunService.RenderStepped:Connect(function()
                    if not ESPEnabled or not player.Character or not player.Character:FindFirstChild("Head") then
                        line.Visible = false
                        return
                    end

                    local headPos = Camera:WorldToViewportPoint(player.Character.Head.Position)
                    line.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
                    line.To = Vector2.new(headPos.X, headPos.Y)
                    line.Visible = true
                end)

                table.insert(ESPObjects, conn)
            end
        end
    end
end

-- ============================================================
-- 🎯 АИМБОТ
-- ============================================================

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = getClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- ============================================================
-- 🔄 ПЕРЕЗАХОД НА СЕРВЕР
-- ============================================================

local function rejoinServer()
    local placeId = game.PlaceId
    TeleportService:Teleport(placeId, LocalPlayer, {})
end

-- ============================================================
-- 📊 GUI (КОРЕГУИ - НЕ ПРОПАДАЕТ)
-- ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProESP_GUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- ===== ГЛАВНОЕ МЕНЮ =====
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 280)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -140)
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

-- ===== ЗАГОЛОВОК =====
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "🔥 PRO ESP + AIMBOT"
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- ===== КНОПКА ЗАКРЫТИЯ =====
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

-- ===== ФУНКЦИЯ ОБНОВЛЕНИЯ КНОПОК =====
local function updateButton(button, state)
    button.Text = state and button.Name .. ": ON" or button.Name .. ": OFF"
    button.BackgroundColor3 = state and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(150, 50, 50)
end

-- ===== КНОПКА Aimbot =====
local AimbotButton = Instance.new("TextButton")
AimbotButton.Size = UDim2.new(0, 250, 0, 40)
AimbotButton.Position = UDim2.new(0.5, -125, 0, 55)
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

-- ===== КНОПКА ESP =====
local ESPButton = Instance.new("TextButton")
ESPButton.Size = UDim2.new(0, 250, 0, 40)
ESPButton.Position = UDim2.new(0.5, -125, 0, 105)
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

-- ===== КНОПКА REJOIN =====
local RejoinButton = Instance.new("TextButton")
RejoinButton.Size = UDim2.new(0, 250, 0, 40)
RejoinButton.Position = UDim2.new(0.5, -125, 0, 155)
RejoinButton.Text = "Rejoin Server"
RejoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinButton.Font = Enum.Font.GothamBold
RejoinButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
RejoinButton.BorderSizePixel = 0
RejoinButton.Parent = MainFrame

local rejoinCorner = Instance.new("UICorner")
rejoinCorner.Parent = RejoinButton
rejoinCorner.CornerRadius = UDim.new(0, 8)

RejoinButton.MouseButton1Click:Connect(function()
    rejoinServer()
end)

-- ===== КНОПКА CLEAR REPORTS =====
local ClearButton = Instance.new("TextButton")
ClearButton.Size = UDim2.new(0, 250, 0, 40)
ClearButton.Position = UDim2.new(0.5, -125, 0, 205)
ClearButton.Text = "Clear Reports (Exit)"
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.Font = Enum.Font.GothamBold
ClearButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ClearButton.BorderSizePixel = 0
ClearButton.Parent = MainFrame

local clearCorner = Instance.new("UICorner")
clearCorner.Parent = ClearButton
clearCorner.CornerRadius = UDim.new(0, 8)

ClearButton.MouseButton1Click:Connect(function()
    game:Shutdown()
end)

-- ===== ЗАКРЫТИЕ GUI =====
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- ===== ОТКРЫТИЕ GUI (Правый Shift) =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
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
-- 📌 ИНФОРМАЦИЯ
-- ============================================================

print("🔥 PRO ESP + AIMBOT загружен!")
print("🔹 Правый Shift — показать/скрыть меню")
print("🔹 Кнопки в меню — управление функциями")
print("🎯 Aimbot наводится на врагов (не за стеной)")
print("🟢 ESP показывает врагов (красный)")
