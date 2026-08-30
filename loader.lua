-- ============================================================
-- 🔥 ТЕСТ: ИСПОЛЬЗУЕМ ОРИГИНАЛЬНЫЙ КОНТРОЛЛЕР
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local WeaponController = nil
local found = false

-- Ищем контроллер в памяти
local function findController()
    for _, v in pairs(getgc(true)) do
        if typeof(v) == 'table' then
            -- Проверяем, есть ли у таблицы метод shoot
            local shoot = rawget(v, 'shoot')
            if shoot and type(shoot) == 'function' then
                -- Проверяем, что это контроллер для Desert Eagle
                local blaster = rawget(v, 'blaster')
                if blaster and blaster.Name == "Desert Eagle" then
                    WeaponController = v
                    found = true
                    print("✅ Найден оригинальный контроллер!")
                    return true
                end
            end
        end
    end
    return false
end

-- Ищем каждые 2 секунды, пока не найдём
task.spawn(function()
    while not found do
        task.wait(2)
        findController()
        if found then
            print("🔫 Контроллер подключён!")
        end
    end
end)

-- Аимбот (только наведение, без выстрела)
RunService.RenderStepped:Connect(function()
    if not found then return end
    
    local closest = nil
    local minDist = 300
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local dist = (head.Position - cam.CFrame.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = plr
                end
            end
        end
    end
    
    if closest and closest.Character then
        local head = closest.Character:FindFirstChild("Head")
        if head then
            cam.CFrame = CFrame.new(cam.CFrame.Position, head.Position)
        end
    end
end)

-- Выстрел по нажатию P (используем оригинальный контроллер)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.P and found then
        if WeaponController and WeaponController.shoot then
            print("🔫 Выстрел через оригинальный контроллер!")
            WeaponController:shoot()
        end
    end
end)

print("🔍 Ищем оригинальный контроллер...")
