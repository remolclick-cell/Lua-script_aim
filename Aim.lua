-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local highlights = {}
local espEnabled = false

-- 🎨 Создание интерфейса (Минималистичное меню)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MinimalESP"
screenGui.ResetOnSpawn = false

-- Пытаемся защитить GUI (для инжекторов вроде Xeno/Synapse)
pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
    end
    screenGui.Parent = CoreGui
end)
if not screenGui.Parent then
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 120, 0, 40)
mainFrame.Position = UDim2.new(0.5, -60, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Можно перетаскивать мышкой
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -10, 1, -10)
toggleBtn.Position = UDim2.new(0, 5, 0, 5)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleBtn.Text = "ESP: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 4)
btnCorner.Parent = toggleBtn

-- ⚙️ Логика ESP
local function updatePlayer(player)
    if player == LocalPlayer then return end
    
    -- Удаляем старую подсветку
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end

    -- Если ESP выключен или у игрока нет персонажа, выходим
    if not espEnabled or not player.Character then return end

    -- Создаем новую подсветку
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = player.Character
    highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Красный цвет
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Белая обводка
    highlight.FillTransparency = 0.5 -- Прозрачность заливки
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Видно сквозь стены
    highlight.Parent = player.Character

    highlights[player] = highlight
end

-- Обновление всех игроков
local function refreshAll()
    for _, player in ipairs(Players:GetPlayers()) do
        updatePlayer(player)
    end
end

-- 🔄 Следим за новыми игроками и их спавном
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1) -- Ждем загрузку персонажа
        updatePlayer(player)
    end)
end)

-- Обработка игроков, которые уже в игре
for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        updatePlayer(player)
    end
    player.CharacterAdded:Connect(function()
        task.wait(1)
        updatePlayer(player)
    end)
end

-- 🔘 Логика кнопки
toggleBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    
    if espEnabled then
        toggleBtn.Text = "ESP: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0) -- Зеленый при включении
    else
        toggleBtn.Text = "ESP: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Серый при выключении
    end
    
    refreshAll()
end)

-- Периодическое обновление на случай перезахода в игру (каждые 2 секунды)
task.spawn(function()
    while task.wait(2) do
        if espEnabled then
            refreshAll()
        end
    end
end)

print("Minimal ESP loaded successfully!")
