-- ============================================================
-- 🧪 ТЕСТОВЫЙ СКРИПТ (ПРОВЕРКА КОНТРОЛЛЕРА)
-- ============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Загружаем BlasterController
local BlasterController = require(ReplicatedStorage.Blaster.Scripts.BlasterController)
print("✅ BlasterController загружен!")

-- Функция поиска Desert Eagle
local function findDesertEagle()
    if not LocalPlayer.Character then return nil end
    for _, child in pairs(LocalPlayer.Character:GetChildren()) do
        if child.Name == "Desert Eagle" then
            return child
        end
    end
    return nil
end

-- Ищем Desert Eagle
local desertEagle = findDesertEagle()
if not desertEagle then
    print("❌ Desert Eagle не найден! Возьми пистолет в руки.")
    return
end
print("✅ Desert Eagle найден!")

-- ═══════════════════════════════════════════════
-- ПРОВЕРКА: ЕСТЬ ЛИ УЖЕ КОНТРОЛЛЕР?
-- ═══════════════════════════════════════════════

local WeaponController = nil

-- Ищем существующий контроллер в памяти
print("🔍 Ищем существующий контроллер...")
for _, v in pairs(getgc(true)) do
    if typeof(v) == 'table' and rawget(v, 'shoot') and type(rawget(v, 'shoot')) == 'function' then
        -- Проверяем, что это контроллер для Desert Eagle
        if rawget(v, 'blaster') and rawget(v, 'blaster') == desertEagle then
            WeaponController = v
            print("✅ Найден существующий контроллер!")
            break
        end
    end
end

-- Если контроллер не найден — создаём свой
if not WeaponController then
    print("🔧 Создаём новый контроллер...")
    WeaponController = BlasterController.new(desertEagle)
    print("✅ Новый контроллер создан!")
end

-- ═══════════════════════════════════════════════
-- ТЕСТОВАЯ СТРЕЛЬБА ПО КЛАВИШЕ P
-- ═══════════════════════════════════════════════

print("🎯 Нажми P для выстрела (если пистолет в руках)")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.P then
        if WeaponController and WeaponController.shoot then
            print("🔫 Выстрел!")
            WeaponController:shoot()
        else
            print("❌ Контроллер не найден или нет метода shoot()")
        end
    end
end)
