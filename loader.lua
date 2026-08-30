-- ============================================================
-- 🔥 PRO ESP + AIMBOT (АНТИ-ДЕТЕКТ)
-- Версия: 6.0
-- ============================================================

-- ============================================================
-- 🔓 МЯГКИЙ БАЙПАС (НЕ АГРЕССИВНЫЙ)
-- ============================================================

-- Отключаем только самые агрессивные функции античита
-- Не трогаем всё подряд, чтобы не сломать игру
for i, v in next, getgc(true) do
    if typeof(v) == 'function' and getfenv(v).script and getfenv(v).script.Parent == nil then
        if not isourclosure(v) then
            local source = debug.info(v, 's')
            if source and source:find('Anti') or source and source:find('Detect') then
                pcall(function()
                    hookfunction(v, function() return end)
                end)
            end
        end
    end
end

-- ============================================================
-- ⚙️ ОСНОВНОЙ СКРИПТ (ОБФУСЦИРОВАННЫЙ ВИД)
-- ============================================================

local a = game:GetService("Players")
local b = game:GetService("RunService")
local c = game:GetService("UserInputService")
local d = game:GetService("CoreGui")
local e = game:GetService("TeleportService")

local f = a.LocalPlayer
local g = workspace.CurrentCamera

local h = true
local i = false
local j = 300
local k = 150

local l = {}
local m = {}

-- ============================================================
-- 🎯 ФУНКЦИЯ ПРОВЕРКИ ВРАГА
-- ============================================================

local function n(o)
    if o.Team and f.Team then
        return o.Team ~= f.Team
    end
    return true
end

-- ============================================================
-- 🎯 ФУНКЦИЯ НАХОЖДЕНИЯ БЛИЖАЙШЕГО ВРАГА (ОБХОД)
-- ============================================================

local function p()
    local q = nil
    local r = j

    for _, o in ipairs(a:GetPlayers()) do
        if o ~= f and o.Character and o.Character:FindFirstChild("Head") and n(o) then
            local s = o.Character.Head
            local t = (s.Position - g.CFrame.Position).Magnitude

            local u = Ray.new(g.CFrame.Position, (s.Position - g.CFrame.Position).Unit * t)
            local v, _ = workspace:FindPartOnRay(u, f.Character, false, true)

            if t <= r and (not v or v:IsDescendantOf(o.Character)) then
                q = o
                r = t
            end
        end
    end

    return q
end

-- ============================================================
-- 🟢 ESP
-- ============================================================

local function w()
    i = not i

    for _, v in pairs(l) do
        if v then pcall(function() v:Destroy() end) end
    end
    l = {}

    for _, v in pairs(m) do
        if v then pcall(function() v:Destroy() end) end
    end
    m = {}

    if i then
        for _, o in ipairs(a:GetPlayers()) do
            if o ~= f and o.Character and n(o) then
                local x = o.Character
                local y = x:FindFirstChild("HumanoidRootPart")
                if not y then continue end

                local t = (y.Position - g.CFrame.Position).Magnitude
                if t > k then continue end

                local z = Instance.new("BoxHandleAdornment")
                z.Size = x:GetExtentsSize()
                z.Adornee = x
                z.AlwaysOnTop = true
                z.ZIndex = 10
                z.Color3 = Color3.new(1, 0, 0)
                z.Transparency = 0.5
                z.Parent = x
                table.insert(l, z)

                for _, part in ipairs(x:GetChildren()) do
                    if part:IsA("BasePart") then
                        local A = Instance.new("Highlight")
                        A.Parent = part
                        A.Adornee = part
                        A.FillColor = Color3.fromRGB(255, 0, 0)
                        A.FillTransparency = 0.5
                        A.OutlineColor = Color3.fromRGB(255, 255, 255)
                        A.OutlineTransparency = 0
                        table.insert(l, A)
                    end
                end

                -- Линия к голове (без Drawing, чтобы не детектить)
                local B = Instance.new("BillboardGui")
                B.Parent = x.Head
                B.Adornee = x.Head
                B.Size = UDim2.new(0, 2, 0, 2)
                B.AlwaysOnTop = true
                B.StudsOffset = Vector3.new(0, 0, 0)
                
                local C = Instance.new("Frame")
                C.Parent = B
                C.Size = UDim2.new(1, 0, 1, 0)
                C.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                C.BackgroundTransparency = 0
                C.BorderSizePixel = 0
                table.insert(l, B)
            end
        end
    end
end

-- ============================================================
-- 🎯 АИМБОТ
-- ============================================================

b.RenderStepped:Connect(function()
    if h then
        local o = p()
        if o and o.Character and o.Character:FindFirstChild("Head") then
            g.CFrame = CFrame.new(g.CFrame.Position, o.Character.Head.Position)
        end
    end
end)

-- ============================================================
-- 🔄 ПЕРЕЗАХОД
-- ============================================================

local function D()
    e:Teleport(game.PlaceId, f, {})
end

-- ============================================================
-- 📊 GUI
-- ============================================================

local E = Instance.new("ScreenGui")
E.Name = "M"
E.Parent = d
E.ResetOnSpawn = false

local F = Instance.new("Frame")
F.Size = UDim2.new(0, 300, 0, 280)
F.Position = UDim2.new(0.5, -150, 0.5, -140)
F.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
F.BackgroundTransparency = 0.15
F.BorderSizePixel = 2
F.BorderColor3 = Color3.fromRGB(255, 0, 0)
F.Active = true
F.Draggable = true
F.Parent = E

local G = Instance.new("UICorner")
G.Parent = F
G.CornerRadius = UDim.new(0, 12)

local H = Instance.new("TextLabel")
H.Size = UDim2.new(1, 0, 0, 40)
H.Position = UDim2.new(0, 0, 0, 5)
H.BackgroundTransparency = 1
H.Text = "🔥 PRO"
H.TextSize = 20
H.TextColor3 = Color3.fromRGB(255, 255, 255)
H.Font = Enum.Font.GothamBold
H.Parent = F

local I = Instance.new("TextButton")
I.Size = UDim2.new(0, 30, 0, 30)
I.Position = UDim2.new(1, -35, 0, 5)
I.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
I.Text = "✕"
I.TextColor3 = Color3.fromRGB(255, 255, 255)
I.TextSize = 16
I.Font = Enum.Font.GothamBold
I.BorderSizePixel = 0
I.Parent = F

local J = Instance.new("UICorner")
J.Parent = I
J.CornerRadius = UDim.new(0, 6)

local function K(btn, state)
    btn.Text = state and btn.Name .. ": ON" or btn.Name .. ": OFF"
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(150, 50, 50)
end

-- Aimbot
local L = Instance.new("TextButton")
L.Size = UDim2.new(0, 250, 0, 40)
L.Position = UDim2.new(0.5, -125, 0, 55)
L.Name = "Aimbot"
K(L, h)
L.TextColor3 = Color3.fromRGB(255, 255, 255)
L.Font = Enum.Font.GothamBold
L.BorderSizePixel = 0
L.Parent = F

local M = Instance.new("UICorner")
M.Parent = L
M.CornerRadius = UDim.new(0, 8)

L.MouseButton1Click:Connect(function()
    h = not h
    K(L, h)
end)

-- ESP
local N = Instance.new("TextButton")
N.Size = UDim2.new(0, 250, 0, 40)
N.Position = UDim2.new(0.5, -125, 0, 105)
N.Name = "ESP"
K(N, i)
N.TextColor3 = Color3.fromRGB(255, 255, 255)
N.Font = Enum.Font.GothamBold
N.BorderSizePixel = 0
N.Parent = F

local O = Instance.new("UICorner")
O.Parent = N
O.CornerRadius = UDim.new(0, 8)

N.MouseButton1Click:Connect(function()
    w()
    K(N, i)
end)

-- Rejoin
local P = Instance.new("TextButton")
P.Size = UDim2.new(0, 250, 0, 40)
P.Position = UDim2.new(0.5, -125, 0, 155)
P.Text = "Rejoin"
P.TextColor3 = Color3.fromRGB(255, 255, 255)
P.Font = Enum.Font.GothamBold
P.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
P.BorderSizePixel = 0
P.Parent = F

local Q = Instance.new("UICorner")
Q.Parent = P
Q.CornerRadius = UDim.new(0, 8)

P.MouseButton1Click:Connect(D)

-- Exit
local R = Instance.new("TextButton")
R.Size = UDim2.new(0, 250, 0, 40)
R.Position = UDim2.new(0.5, -125, 0, 205)
R.Text = "Exit"
R.TextColor3 = Color3.fromRGB(255, 255, 255)
R.Font = Enum.Font.GothamBold
R.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
R.BorderSizePixel = 0
R.Parent = F

local S = Instance.new("UICorner")
S.Parent = R
S.CornerRadius = UDim.new(0, 8)

R.MouseButton1Click:Connect(function()
    game:Shutdown()
end)

I.MouseButton1Click:Connect(function()
    F.Visible = false
end)

-- ============================================================
-- ⌨️ БИНДЫ
-- ============================================================

c.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.RightShift then
        F.Visible = not F.Visible
    end

    if input.KeyCode == Enum.KeyCode.G then
        w()
        K(N, i)
    end

    if input.KeyCode == Enum.KeyCode.H then
        h = not h
        K(L, h)
    end
end)

-- ============================================================
-- 👥 НОВЫЕ ИГРОКИ
-- ============================================================

a.PlayerAdded:Connect(function()
    if i then
        w()
        w()
    end
end)

-- ============================================================
-- 📌 ИНФОРМАЦИЯ
-- ============================================================

print("🔥 PRO загружен!")
print("🔹 Shift — меню")
print("🔹 G — ESP")
print("🔹 H — Аимбот")
