--[[
    ═══════════════════════════════════════════
      Universal Aim & ESP
      by borges
      UI: Fluent  |  ESP: Custom (встроенный)
    ═══════════════════════════════════════════
]]

-- ═══════════ ЗАГРУЗКА БИБЛИОТЕК ═══════════
local Library = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ═══════════ СЕРВИСЫ ═══════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ═══════════ НАСТРОЙКИ (все в одном месте) ═══════════
local Config = {
    -- Aim
    AimEnabled       = false,
    AimKey           = Enum.KeyCode.CapsLock,
    AimSmoothness    = 0.25,
    AimFOV           = 120,
    AimRange         = 500,
    AimPriority      = "Crosshair",   -- "Crosshair" / "Distance"
    AimVisibleCheck  = true,
    AimTeamCheck     = false,
    AimPart          = "Head",        -- "Head" / "HumanoidRootPart"
    SilentAim        = false,

    -- ESP
    EspEnabled       = false,
    EspBoxes         = true,
    EspNames         = true,
    EspHealth        = true,
    EspDistance      = true,
    EspTracers       = false,
    EspTeamCheck     = false,
    EspFillColor     = Color3.fromRGB(255, 165, 0),
    EspOutlineColor  = Color3.fromRGB(255, 255, 255),
    EspMaxDistance   = 1000,
}

-- ═══════════ СОЗДАНИЕ ОКНА ═══════════
local Window = Library:CreateWindow({
    Title = "Universal Aim & ESP",
    SubTitle = "by borges",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = true,
    Theme = "Darker",
    AccentColor = Color3.fromRGB(255, 165, 0),
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main      = Window:AddTab({ Title = "Welcome",     Icon = "home" }),
    Aim       = Window:AddTab({ Title = "Aim Assist",  Icon = "crosshair" }),
    Esp       = Window:AddTab({ Title = "ESP",         Icon = "eye" }),
    Settings  = Window:AddTab({ Title = "Settings",    Icon = "settings" }),
}

-- ═══════════ ВКЛАДКА WELCOME ═══════════
Tabs.Main:AddParagraph({
    Title = "Привет, " .. LocalPlayer.Name .. "!",
    Content = "Универсальный скрипт с Aim Assist и ESP.\nНажми CapsLock чтобы быстро вкл/выкл аим.\nНастройки сохраняются автоматически."
})

Tabs.Main:AddButton({
    Title = "Discord",
    Description = "Присоединиться к сообществу",
    Callback = function()
        Library:Notify({ Title = "Discord", Content = "Ссылка пока не задана.", Duration = 3 })
    end
})

-- ═══════════════════════════════════════════
--              ESP СИСТЕМА
-- ═══════════════════════════════════════════
local ESP = {}
ESP.Objects = {}

-- Создать Drawing-объекты для игрока
function ESP:Create(player)
    if player == LocalPlayer then return end
    if self.Objects[player] then return end

    local drawings = {
        Box      = Drawing.new("Square"),
        Name     = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBG = Drawing.new("Square"),
        Health   = Drawing.new("Square"),
        Tracer   = Drawing.new("Line"),
    }

    drawings.Box.Thickness   = 1
    drawings.Box.Filled      = false
    drawings.Box.Color       = Config.EspOutlineColor
    drawings.Box.Transparency = 1
    drawings.Box.Visible      = false

    drawings.Name.Size       = 14
    drawings.Name.Center     = true
    drawings.Name.Outline    = true
    drawings.Name.Color      = Color3.fromRGB(255, 255, 255)
    drawings.Name.Visible    = false

    drawings.Distance.Size   = 12
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.Color  = Color3.fromRGB(200, 200, 200)
    drawings.Distance.Visible = false

    drawings.HealthBG.Filled = true
    drawings.HealthBG.Color  = Color3.fromRGB(0, 0, 0)
    drawings.HealthBG.Visible = false

    drawings.Health.Filled   = true
    drawings.Health.Color    = Color3.fromRGB(0, 255, 0)
    drawings.Health.Visible  = false

    drawings.Tracer.Thickness = 1
    drawings.Tracer.Color     = Config.EspFillColor
    drawings.Tracer.Visible   = false

    self.Objects[player] = drawings
end

-- Удалить объекты
function ESP:Remove(player)
    if self.Objects[player] then
        for _, obj in pairs(self.Objects[player]) do
            pcall(function() obj:Remove() end)
        end
        self.Objects[player] = nil
    end
end

-- Проверка видимости цели
local function isVisible(part, ignoreList)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList or {}
    local result = Workspace:Raycast(origin, dir, params)
    return result == nil or result.Instance:IsDescendantOf(part.Parent)
end

-- Обновление ESP каждый кадр
RunService.RenderStepped:Connect(function()
    if not Config.EspEnabled then
        for _, drawings in pairs(ESP.Objects) do
            for _, obj in pairs(drawings) do obj.Visible = false end
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        if not (hrp and head and hum and hum.Health > 0) then
            if ESP.Objects[player] then
                for _, obj in pairs(ESP.Objects[player]) do obj.Visible = false end
            end
            continue
        end

        -- Team check
        if Config.EspTeamCheck and player.Team == LocalPlayer.Team then
            for _, obj in pairs(ESP.Objects[player]) do obj.Visible = false end
            continue
        end

        -- Дистанция
        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if dist > Config.EspMaxDistance then
            for _, obj in pairs(ESP.Objects[player]) do obj.Visible = false end
            continue
        end

        ESP:Create(player)
        local d = ESP.Objects[player]

        -- Проверка на экране
        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        local hrpPos = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            for _, obj in pairs(d) do obj.Visible = false end
            continue
        end

        local height = math.abs(headPos.Y - hrpPos.Y) * 2
        local width  = height * 0.6

        -- Box
        d.Box.Size     = Vector2.new(width, height)
        d.Box.Position = Vector2.new(headPos.X - width/2, headPos.Y - height/4)
        d.Box.Color    = Config.EspFillColor
        d.Box.Visible  = Config.EspBoxes

        -- Name
        d.Name.Text    = player.Name
        d.Name.Position = Vector2.new(headPos.X, headPos.Y - height/2 - 16)
        d.Name.Visible = Config.EspNames

        -- Distance
        d.Distance.Text     = string.format("[%d m]", dist)
        d.Distance.Position = Vector2.new(headPos.X, headPos.Y + height * 0.85)
        d.Distance.Visible  = Config.EspDistance

        -- Health bar
        local hp = hum.Health / hum.MaxHealth
        d.HealthBG.Size     = Vector2.new(3, height)
        d.HealthBG.Position = Vector2.new(headPos.X - width/2 - 6, headPos.Y - height/4)
        d.HealthBG.Visible  = Config.EspHealth

        d.Health.Size     = Vector2.new(3, height * hp)
        d.Health.Position = Vector2.new(headPos.X - width/2 - 6, headPos.Y - height/4 + height * (1 - hp))
        d.Health.Color    = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
        d.Health.Visible  = Config.EspHealth

        -- Tracer
        d.Tracer.From   = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        d.Tracer.To     = Vector2.new(headPos.X, headPos.Y + height/2)
        d.Tracer.Visible = Config.EspTracers
    end
end)

-- Чистим при выходе игроков
Players.PlayerRemoving:Connect(function(p) ESP:Remove(p) end)

-- ═══════════════════════════════════════════
--              AIM ASSIST
-- ═══════════════════════════════════════════
local Aim = {}

-- FOV Circle
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color     = Color3.fromRGB(255, 165, 0)
FovCircle.Filled    = false
FovCircle.Transparency = 0.7
FovCircle.Visible   = false

RunService.RenderStepped:Connect(function()
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FovCircle.Radius   = Config.AimFOV
    FovCircle.Visible  = Config.AimEnabled
end)

-- Получить цель
function Aim:GetTarget()
    local closest, shortest = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Config.AimTeamCheck and player.Team == LocalPlayer.Team then continue end

        local char = player.Character
        if not char then continue end

        local part = char:FindFirstChild(Config.AimPart)
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not (part and hum and hum.Health > 0) then continue end

        local worldDist = (Camera.CFrame.Position - part.Position).Magnitude
        if worldDist > Config.AimRange then continue end

        -- Экранные координаты
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local screenPos2 = Vector2.new(screenPos.X, screenPos.Y)
        local screenDist = (screenPos2 - center).Magnitude

        -- FOV
        if screenDist > Config.AimFOV then continue end

        -- Visible check
        if Config.AimVisibleCheck and not isVisible(part, {LocalPlayer.Character}) then
            continue
        end

        local score = (Config.AimPriority == "Crosshair") and screenDist or worldDist
        if score < shortest then
            shortest = score
            closest = part
        end
    end

    return closest
end

-- Основной цикл аима
RunService.RenderStepped:Connect(function()
    if not Config.AimEnabled then return end
    if UserInputService:IsKeyDown(Config.AimKey) or Config.SilentAim then
        local target = Aim:GetTarget()
        if target then
            local goal = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, Config.AimSmoothness)
        end
    end
end)

-- ═══════════════════════════════════════════
--              UI — AIM ASSIST
-- ═══════════════════════════════════════════
Tabs.Aim:AddToggle("AimEnabled", {
    Title = "Aim Assist",
    Description = "Главный выключатель аима",
    Default = Config.AimEnabled,
    Callback = function(v) Config.AimEnabled = v end
})

Tabs.Aim:AddSlider("AimSmoothness", {
    Title = "Плавность",
    Description = "Чем меньше — тем резче наводится",
    Default = 25, Min = 1, Max = 100, Rounding = 0,
    Callback = function(v) Config.AimSmoothness = v / 100 end
})

Tabs.Aim:AddSlider("AimFOV", {
    Title = "FOV (радиус)",
    Description = "Радиус захвата цели в пикселях",
    Default = 120, Min = 20, Max = 500, Rounding = 0,
    Callback = function(v) Config.AimFOV = v end
})

Tabs.Aim:AddSlider("AimRange", {
    Title = "Макс. дистанция",
    Description = "Максимальная дистанция до цели",
    Default = 500, Min = 50, Max = 2000, Rounding = 0,
    Callback = function(v) Config.AimRange = v end
})

Tabs.Aim:AddDropdown("AimPriority", {
    Title = "Приоритет",
    Description = "Кого выбирать целью",
    Values = { "Crosshair", "Distance" },
    Default = 1,
    Multi = false,
    Callback = function(v) Config.AimPriority = v end
})

Tabs.Aim:AddDropdown("AimPart", {
    Title = "Часть тела",
    Description = "Куда целиться",
    Values = { "Head", "HumanoidRootPart" },
    Default = 1,
    Multi = false,
    Callback = function(v) Config.AimPart = v end
})

Tabs.Aim:AddToggle("AimVisibleCheck", {
    Title = "Visible Check",
    Description = "Игнорировать цели за стенами",
    Default = Config.AimVisibleCheck,
    Callback = function(v) Config.AimVisibleCheck = v end
})

Tabs.Aim:AddToggle("AimTeamCheck", {
    Title = "Team Check",
    Description = "Игнорировать союзников",
    Default = Config.AimTeamCheck,
    Callback = function(v) Config.AimTeamCheck = v end
})

Tabs.Aim:AddToggle("SilentAim", {
    Title = "Silent Aim",
    Description = "Аим работает без удержания клавиши",
    Default = Config.SilentAim,
    Callback = function(v) Config.SilentAim = v end
})

-- ═══════════════════════════════════════════
--              UI — ESP
-- ═══════════════════════════════════════════
Tabs.Esp:AddToggle("EspEnabled", {
    Title = "ESP Global",
    Description = "Включить ESP для всех игроков",
    Default = Config.EspEnabled,
    Callback = function(v) Config.EspEnabled = v end
})

Tabs.Esp:AddToggle("EspBoxes", {
    Title = "Boxes",
    Default = Config.EspBoxes,
    Callback = function(v) Config.EspBoxes = v end
})

Tabs.Esp:AddToggle("EspNames", {
    Title = "Names",
    Default = Config.EspNames,
    Callback = function(v) Config.EspNames = v end
})

Tabs.Esp:AddToggle("EspHealth", {
    Title = "Health Bar",
    Default = Config.EspHealth,
    Callback = function(v) Config.EspHealth = v end
})

Tabs.Esp:AddToggle("EspDistance", {
    Title = "Distance",
    Default = Config.EspDistance,
    Callback = function(v) Config.EspDistance = v end
})

Tabs.Esp:AddToggle("EspTracers", {
    Title = "Tracers",
    Default = Config.EspTracers,
    Callback = function(v) Config.EspTracers = v end
})

Tabs.Esp:AddToggle("EspTeamCheck", {
    Title = "Team Check",
    Default = Config.EspTeamCheck,
    Callback = function(v) Config.EspTeamCheck = v end
})

Tabs.Esp:AddSlider("EspMaxDistance", {
    Title = "Макс. дистанция",
    Default = 1000, Min = 100, Max = 5000, Rounding = 0,
    Callback = function(v) Config.EspMaxDistance = v end
})

Tabs.Esp:AddColorPicker("EspFillColor", {
    Title = "Цвет ESP",
    Default = Config.EspFillColor,
    Callback = function(c) Config.EspFillColor = c end
})

-- ═══════════════════════════════════════════
--              Горячие клавиши
-- ═══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.AimKey then
        Config.AimEnabled = not Config.AimEnabled
        Library:Notify({
            Title = "🎯 Aim Assist",
            Content = Config.AimEnabled and "Включено" or "Выключено",
            Duration = 1.5
        })
    end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Config.EspEnabled = not Config.EspEnabled
        Library:Notify({
            Title = "👁 ESP",
            Content = Config.EspEnabled and "Включено" or "Выключено",
            Duration = 1.5
        })
    end
end)

-- ═══════════ СОХРАНЕНИЕ ═══════════
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
InterfaceManager:SetFolder("BorgesScripts")
SaveManager:SetFolder("BorgesScripts/Universal")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

Library:Notify({
    Title = "✅ Скрипт загружен",
    Content = "Нажми CapsLock — аим, RightShift — ESP",
    Duration = 4
})
