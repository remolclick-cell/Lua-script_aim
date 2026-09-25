--// LEMOS 0.2
--// Universal Executor Script (Synapse X / Script-Ware / Fluxus / Delta / Solara / Wave)
--// Меню для чита. Всё на русском. В стиле Fluent UI.
--// Без значков и смайликов.

--//==================================================
--// ПРОВЕРКА ЭКЗЕКЬЮТЕРА
--//==================================================

local Executor = "Unknown"
local IsExecutor = false

local function getExecutor()
    if syn then return "Synapse X" end
    if fluxus then return "Fluxus" end
    if delta then return "Delta" end
    if Solara then return "Solara" end
    if Wave then return "Wave" end
    if Kavo then return "Kavo" end
    if is_sirhurt_closure then return "SirHurt" end
    if secure_load then return "Sentinel" end
    return "Unknown"
end

pcall(function()
    Executor = getExecutor()
    if Executor ~= "Unknown" then IsExecutor = true end
end)

if not IsExecutor then
    warn("[LEMOS] Запущено вне экзекьютера. Часть функций отключена.")
end

--//==================================================
--// БЕЗОПАСНЫЕ ОБЁРТКИ
--//==================================================

local function safeCall(fn, ...)
    local args = {...}
    local ok, res = pcall(function() return fn(table.unpack(args)) end)
    if not ok then warn("[LEMOS] " .. tostring(res)) end
    return ok, res
end

local function safeWriteFile(path, content)
    if writefile then return safeCall(writefile, path, content) end
    return false
end

local function safeReadFile(path)
    if readfile then return safeCall(readfile, path) end
    return false
end

local function safeIsFile(path)
    if isfile then return safeCall(isfile, path) end
    return false
end

local function safeMakeFolder(path)
    if makefolder then return safeCall(makefolder, path) end
    return false
end

--//==================================================
--// СЕРВИСЫ
--//==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

--//==================================================
--// DRAWING API
--//==================================================

local DrawingAPI = nil
local HasDrawing = false

pcall(function()
    if Drawing then
        DrawingAPI = Drawing
        HasDrawing = true
    end
end)

--//==================================================
--// КОНФИГ
--//==================================================

local Config = {
    ScriptName = "LEMOS",
    Version = "0.2",
    WindowScale = 1,
    WindowTransparency = 0.06,
    Theme = "Dark",
    MenuKey = Enum.KeyCode.Insert,

    -- Combat
    Combat = {
        Aimbot = false,
        AimbotKey = Enum.KeyCode.E,
        AimbotFOV = 140,
        AimbotSmoothness = 0.15,
        AimbotHitbox = "Head",
        AimbotTargetMode = "Closest",
        SilentAim = false,
        SilentAimFOV = 140,
        NoRecoil = false,
        NoSpread = false,
        NoSway = false,
        NoScope = false,
        InstantHit = false,
        InfiniteAmmo = false,
        RapidFire = false,
        FastReload = false,
        HeadshotOnly = false,
        WallCheck = true,
        FOVCircle = true,
        FOVCircleColor = Color3.fromRGB(255,111,25),
        FOVCircleThickness = 1,
    },

    -- Visuals
    Visuals = {
        ESP = false,
        Box = false,
        BoxStyle = "2D",
        BoxColor = Color3.fromRGB(255,111,25),
        BoxFill = false,
        BoxFillColor = Color3.fromRGB(255,111,25),
        BoxFillAlpha = 0.7,
        Name = false,
        NameColor = Color3.fromRGB(255,255,255),
        Distance = false,
        DistanceColor = Color3.fromRGB(200,200,200),
        HealthBar = false,
        HealthText = false,
        ArmorBar = false,
        WeaponName = false,
        Skeleton = false,
        SkeletonColor = Color3.fromRGB(255,255,255),
        HeadDot = false,
        HeadDotColor = Color3.fromRGB(255,111,25),
        Chams = false,
        ChamsColor = Color3.fromRGB(255,111,25),
        ChamsVisibleOnly = false,
        Tracers = false,
        TracerOrigin = "Bottom",
        TracerColor = Color3.fromRGB(255,111,25),
        OffscreenArrows = false,
        OffscreenArrowsColor = Color3.fromRGB(255,111,25),
        MaxDistance = 500,
        TeamColor = Color3.fromRGB(90,225,105),
        EnemyColor = Color3.fromRGB(255,70,75),
        PriorityColor = Color3.fromRGB(255,255,0),
        Wallhack = false,
        WallhackOpacity = 0.5,
        WallhackColor = Color3.fromRGB(255,111,25),
        Radar = false,
        RadarSize = 150,
        RadarZoom = 1,
        RadarPosition = "TopRight",
        RadarRotate = false,
        RadarShowNames = true,
        SoundESP = false,
        SoundESPRadius = 50,
        SoundESPColor = Color3.fromRGB(255,111,25),
        FootstepESP = false,
        GrenadeESP = false,
        GrenadeWarning = false,
        BombESP = false,
        DefuseTimer = false,
        PlantTimer = false,
    },

    -- Effects
    Effects = {
        Brightness = 0,
        Contrast = 0,
        Saturation = 0,
        Gamma = 0,
        PlayerColor = false,
        PlayerColorValue = Color3.fromRGB(255,0,0),
        FogColor = Color3.fromRGB(255,0,0),
        FogDensity = 0.5,
        NightMode = false,
        NightModeIntensity = 0.5,
        Fullbright = false,
        NoFog = false,
        NoGrass = false,
        NoFlash = false,
        NoSmoke = false,
        SkyboxChanger = false,
        SkyboxName = "Default",
        Bhop = false,
        BhopChance = 100,
        AutoStrafe = false,
        NoClip = false,
        Watermark = false,
        FPSCounter = false,
        PingCounter = false,
    },

    -- Misc
    Misc = {
        Speed = 16,
        JumpPower = 50,
        Invisible = false,
        Fly = false,
        FlySpeed = 50,
        Teleport = false,
        TeleportTarget = "",
        Notifications = true,
        Hotkey = Enum.KeyCode.Insert,
    },
}

--//==================================================
--// ТЕМЫ
--//==================================================

local Themes = {
    Dark = {accent=Color3.fromRGB(255,111,25), bg=Color3.fromRGB(12,12,13), panel=Color3.fromRGB(18,18,19), item=Color3.fromRGB(22,22,23), text=Color3.fromRGB(245,245,245), sub=Color3.fromRGB(135,135,135)},
    Light = {accent=Color3.fromRGB(255,105,30), bg=Color3.fromRGB(238,238,240), panel=Color3.fromRGB(250,250,252), item=Color3.fromRGB(232,232,235), text=Color3.fromRGB(25,25,28), sub=Color3.fromRGB(105,105,110)},
    Purple = {accent=Color3.fromRGB(177,90,255), bg=Color3.fromRGB(12,9,17), panel=Color3.fromRGB(22,16,29), item=Color3.fromRGB(29,21,38), text=Color3.fromRGB(247,242,255), sub=Color3.fromRGB(155,135,175)},
    Blood = {accent=Color3.fromRGB(235,55,65), bg=Color3.fromRGB(16,9,10), panel=Color3.fromRGB(27,14,15), item=Color3.fromRGB(38,18,20), text=Color3.fromRGB(255,242,243), sub=Color3.fromRGB(165,125,128)},
    Cyber = {accent=Color3.fromRGB(50,160,255), bg=Color3.fromRGB(8,13,19), panel=Color3.fromRGB(13,22,31), item=Color3.fromRGB(18,29,40), text=Color3.fromRGB(240,248,255), sub=Color3.fromRGB(125,155,180)},
    Toxic = {accent=Color3.fromRGB(90,225,105), bg=Color3.fromRGB(8,14,9), panel=Color3.fromRGB(14,24,16), item=Color3.fromRGB(19,32,21), text=Color3.fromRGB(240,255,241), sub=Color3.fromRGB(130,165,135)},
    RGB = {accent=Color3.fromRGB(255,80,200), bg=Color3.fromRGB(10,10,14), panel=Color3.fromRGB(18,18,24), item=Color3.fromRGB(25,25,34), text=Color3.fromRGB(245,245,250), sub=Color3.fromRGB(135,135,150)},
}

local Theme = Themes[Config.Theme]

--//==================================================
--// УТИЛИТЫ
--//==================================================

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = transparency or 0
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function label(parent, text, size, color)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or Theme.text
    l.TextSize = size or 14
    l.Font = Enum.Font.GothamMedium
    l.Parent = parent
    return l
end

local function button(parent, text)
    local b = Instance.new("TextButton")
    b.Text = text
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.TextColor3 = Theme.text
    b.BackgroundColor3 = Theme.item
    b.Parent = parent
    corner(b, 8)
    return b
end

--//==================================================
--// УВЕДОМЛЕНИЯ
--//==================================================

local NotifyContainer = nil

local function notify(text, color)
    if not Config.Misc.Notifications then return end
    if not NotifyContainer then
        NotifyContainer = Instance.new("Frame")
        NotifyContainer.Name = "LEMOS_Notify"
        NotifyContainer.Size = UDim2.new(0, 280, 1, 0)
        NotifyContainer.Position = UDim2.new(1, -300, 0, 0)
        NotifyContainer.BackgroundTransparency = 1
        NotifyContainer.Parent = PlayerGui
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 6)
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = NotifyContainer
        local pad = Instance.new("UIPadding")
        pad.PaddingBottom = UDim.new(0, 20)
        pad.PaddingRight = UDim.new(0, 10)
        pad.Parent = NotifyContainer
    end

    local n = Instance.new("Frame")
    n.Size = UDim2.new(1, 0, 0, 40)
    n.BackgroundColor3 = Theme.panel
    n.BackgroundTransparency = 0.1
    n.BorderSizePixel = 0
    n.Parent = NotifyContainer
    corner(n, 8)
    stroke(n, color or Theme.accent, 0.3, 1)

    local t = label(n, text, 12, Theme.text)
    t.Size = UDim2.fromScale(1,1)
    t.TextXAlignment = Enum.TextXAlignment.Center

    task.delay(3, function()
        local tw = TweenService:Create(n, TweenInfo.new(0.3), {BackgroundTransparency = 1})
        tw:Play()
        tw.Completed:Connect(function()
            n:Destroy()
        end)
    end)
end

--//==================================================
--// ОЧИСТКА СТАРОГО UI
--//==================================================

local guiParent = (gethui and gethui()) or PlayerGui
local old = guiParent:FindFirstChild("LEMOS_UI")
if old then old:Destroy() end

--//==================================================
--// ЗАГРУЗКА
--//==================================================

local Loading = Instance.new("Frame")
Loading.Size = UDim2.fromScale(1,1)
Loading.BackgroundColor3 = Color3.fromRGB(0,0,0)
Loading.BackgroundTransparency = 0.3
Loading.BorderSizePixel = 0
Loading.ZIndex = 100
Loading.Parent = guiParent

local LoadBox = Instance.new("Frame")
LoadBox.Size = UDim2.fromOffset(300, 80)
LoadBox.Position = UDim2.fromScale(.5,.5)
LoadBox.AnchorPoint = Vector2.new(.5,.5)
LoadBox.BackgroundColor3 = Theme.panel
LoadBox.BorderSizePixel = 0
LoadBox.ZIndex = 101
LoadBox.Parent = Loading
corner(LoadBox, 12)
stroke(LoadBox, Theme.accent, .4, 1)

local LoadTitle = label(LoadBox, "LEMOS 0.2", 20, Theme.text)
LoadTitle.Size = UDim2.new(1,0,0,30)
LoadTitle.Position = UDim2.fromOffset(0,10)
LoadTitle.Font = Enum.Font.GothamBold

local LoadBar = Instance.new("Frame")
LoadBar.Size = UDim2.new(1,-40,0,6)
LoadBar.Position = UDim2.new(0,20,1,-22)
LoadBar.BackgroundColor3 = Color3.fromRGB(45,45,48)
LoadBar.BorderSizePixel = 0
LoadBar.ZIndex = 102
LoadBar.Parent = LoadBox
corner(LoadBar, 6)

local LoadFill = Instance.new("Frame")
LoadFill.Size = UDim2.new(0,0,1,0)
LoadFill.BackgroundColor3 = Theme.accent
LoadFill.BorderSizePixel = 0
LoadFill.ZIndex = 103
LoadFill.Parent = LoadBar
corner(LoadFill, 6)

TweenService:Create(LoadFill, TweenInfo.new(1.2, Enum.EasingStyle.Quart), {Size = UDim2.new(1,0,1,0)}):Play()
task.wait(1.3)
Loading:Destroy()

--//==================================================
--// ОСНОВНОЙ GUI
--//==================================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "LEMOS_UI"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if protect_gui then pcall(protect_gui, GUI) end
GUI.Parent = guiParent

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(560, 400)
Main.Position = UDim2.new(.5, -280, .5, -200)
Main.BackgroundColor3 = Theme.bg
Main.BackgroundTransparency = Config.WindowTransparency
Main.BorderSizePixel = 0
Main.Parent = GUI
corner(Main, 14)
local MainStroke = stroke(Main, Theme.accent, .5, 1)

local Scale = Instance.new("UIScale")
Scale.Scale = Config.WindowScale
Scale.Parent = Main

--//==================================================
--// HEADER
--//==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,50)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Logo = Instance.new("Frame")
Logo.Size = UDim2.fromOffset(30,30)
Logo.Position = UDim2.fromOffset(12,10)
Logo.BackgroundColor3 = Theme.accent
Logo.BorderSizePixel = 0
Logo.Parent = Header
corner(Logo,8)

local LogoText = label(Logo,"L",16,Theme.bg)
LogoText.Size = UDim2.fromScale(1,1)
LogoText.Font = Enum.Font.GothamBlack

local Title = label(Header,"LEMOS",16,Theme.text)
Title.Position = UDim2.fromOffset(52,7)
Title.Size = UDim2.fromOffset(150,20)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold

local Version = label(Header,"0.2",10,Theme.accent)
Version.Position = UDim2.fromOffset(53,27)
Version.Size = UDim2.fromOffset(80,16)
Version.TextXAlignment = Enum.TextXAlignment.Left

local Minimize = button(Header,"-")
Minimize.Size = UDim2.fromOffset(28,28)
Minimize.Position = UDim2.new(1,-70,0,11)

local Close = button(Header,"x")
Close.Size = UDim2.fromOffset(28,28)
Close.Position = UDim2.new(1,-38,0,11)

--//==================================================
--// SIDEBAR
--//==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(10,55)
Sidebar.Size = UDim2.fromOffset(120,335)
Sidebar.BackgroundColor3 = Theme.panel
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
corner(Sidebar,10)
local SideStroke = stroke(Sidebar,Theme.text,.93,1)

local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0,8)
SidePadding.PaddingLeft = UDim.new(0,6)
SidePadding.PaddingRight = UDim.new(0,6)
SidePadding.Parent = Sidebar

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0,5)
SideLayout.Parent = Sidebar

local Tabs = {}
local Pages = {}

local function createTab(name)
    local b = button(Sidebar, name)
    b.Name = name
    b.Size = UDim2.new(1,0,0,36)
    b.TextSize = 11
    b.TextColor3 = Theme.sub

    Tabs[name] = {Button=b}
    return b
end

local CombatTab = createTab("Combat")
local VisualsTab = createTab("Visuals")
local WorldTab = createTab("World")
local MiscTab = createTab("Misc")
local ConfigTab = createTab("Config")

--//==================================================
--// CONTENT
--//==================================================

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(140,55)
Content.Size = UDim2.new(1,-150,1,-67)
Content.BackgroundTransparency = 1
Content.Parent = Main

local function createPage(name)
    local p = Instance.new("ScrollingFrame")
    p.Name = name
    p.Size = UDim2.fromScale(1,1)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 2
    p.ScrollBarImageColor3 = Theme.accent
    p.CanvasSize = UDim2.new(0,0,0,0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.ScrollingDirection = Enum.ScrollingDirection.Y
    p.Visible = false
    p.Parent = Content

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0,3)
    pad.PaddingRight = UDim.new(0,3)
    pad.PaddingBottom = UDim.new(0,8)
    pad.Parent = p

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = p

    Pages[name] = p
    return p
end

local CombatPage = createPage("Combat")
local VisualsPage = createPage("Visuals")
local WorldPage = createPage("World")
local MiscPage = createPage("Misc")
local ConfigPage = createPage("Config")

--//==================================================
--// КОМПОНЕНТЫ
--//==================================================

local function createSection(parent, titleText)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1,0,0,24)
    s.BackgroundTransparency = 1
    s.Parent = parent

    local t = label(s, titleText, 12, Theme.accent)
    t.Size = UDim2.fromScale(1,1)
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Font = Enum.Font.GothamBold

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1,0,0,1)
    line.Position = UDim2.new(0,0,1,-1)
    line.BackgroundColor3 = Theme.accent
    line.BackgroundTransparency = 0.7
    line.BorderSizePixel = 0
    line.Parent = s

    return s
end

local function createToggle(parent, textValue, initial, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,0,0,34)
    holder.BackgroundColor3 = Theme.item
    holder.BorderSizePixel = 0
    holder.Parent = parent
    corner(holder,8)

    local txt = label(holder,textValue,11,Theme.text)
    txt.Position = UDim2.fromOffset(10,0)
    txt.Size = UDim2.new(1,-50,1,0)
    txt.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.fromOffset(34,18)
    toggle.Position = UDim2.new(1,-44,.5,-9)
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.BorderSizePixel = 0
    toggle.Parent = holder
    corner(toggle,18)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(12,12)
    knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    corner(knob,18)

    local state = initial

    local function update()
        toggle.BackgroundColor3 = state and Theme.accent or Color3.fromRGB(55,55,58)
        knob.Position = state and UDim2.new(1,-15,.5,-6) or UDim2.new(0,3,.5,-6)
        if callback then callback(state) end
    end

    toggle.MouseButton1Click:Connect(function()
        state = not state
        update()
        notify(textValue .. ": " .. (state and "вкл" or "выкл"), state and Theme.accent or Color3.fromRGB(180,50,55))
    end)

    update()
    return holder
end

local function createSlider(parent, textValue, min, max, initial, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,0,0,50)
    holder.BackgroundColor3 = Theme.item
    holder.BorderSizePixel = 0
    holder.Parent = parent
    corner(holder,8)

    local txt = label(holder,textValue,10,Theme.text)
    txt.Position = UDim2.fromOffset(10,3)
    txt.Size = UDim2.new(1,-80,0,20)
    txt.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = label(holder,tostring(initial),10,Theme.accent)
    valueLabel.Position = UDim2.new(1,-65,0,3)
    valueLabel.Size = UDim2.fromOffset(55,20)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("Frame")
    bar.Position = UDim2.fromOffset(10,30)
    bar.Size = UDim2.new(1,-20,0,5)
    bar.BackgroundColor3 = Color3.fromRGB(55,55,58)
    bar.BorderSizePixel = 0
    bar.Parent = holder
    corner(bar,5)

    local fill = Instance.new("Frame")
    fill.BorderSizePixel = 0
    fill.BackgroundColor3 = Theme.accent
    fill.Parent = bar
    corner(fill,5)

    local dragging = false

    local function setFromX(x)
        local pct = math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        local value = min+(max-min)*pct
        value = math.floor(value+0.5)
        fill.Size = UDim2.new(pct,0,1,0)
        valueLabel.Text = tostring(value)
        if callback then callback(value) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local pct = math.clamp((initial-min)/(max-min),0,1)
    fill.Size = UDim2.new(pct,0,1,0)

    return holder
end

local function createDropdown(parent, textValue, options, initial, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,0,0,36)
    holder.BackgroundColor3 = Theme.item
    holder.BorderSizePixel = 0
    holder.Parent = parent
    corner(holder,8)

    local txt = label(holder,textValue,10,Theme.text)
    txt.Position = UDim2.fromOffset(10,0)
    txt.Size = UDim2.new(.48,0,1,0)
    txt.TextXAlignment = Enum.TextXAlignment.Left

    local current = initial
    local b = button(holder,current)
    b.Size = UDim2.new(.47,0,0,24)
    b.Position = UDim2.new(.51,0,.5,-12)
    b.TextSize = 10

    local open = false
    local list

    local function close()
        open = false
        if list then list:Destroy(); list=nil end
    end

    b.MouseButton1Click:Connect(function()
        if open then close(); return end
        open = true

        list = Instance.new("Frame")
        list.Size = UDim2.new(1,0,0,#options*26+6)
        list.Position = UDim2.new(0,0,1,4)
        list.BackgroundColor3 = Theme.panel
        list.BorderSizePixel = 0
        list.ZIndex = 30
        list.Parent = holder
        corner(list,8)
        stroke(list,Theme.accent,.55,1)

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0,2)
        layout.Parent = list

        for _,option in ipairs(options) do
            local item = button(list,option)
            item.Size = UDim2.new(1,-6,0,24)
            item.Position = UDim2.fromOffset(3,0)
            item.ZIndex = 31
            item.TextSize = 10
            item.MouseButton1Click:Connect(function()
                current = option
                b.Text = option
                close()
                if callback then callback(option) end
            end)
        end
    end)

    return holder
end

local function createColorPicker(parent, textValue, initial, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,0,0,36)
    holder.BackgroundColor3 = Theme.item
    holder.BorderSizePixel = 0
    holder.Parent = parent
    corner(holder,8)

    local txt = label(holder,textValue,10,Theme.text)
    txt.Position = UDim2.fromOffset(10,0)
    txt.Size = UDim2.new(.6,0,1,0)
    txt.TextXAlignment = Enum.TextXAlignment.Left

    local preview = Instance.new("Frame")
    preview.Size = UDim2.fromOffset(24,24)
    preview.Position = UDim2.new(1,-34,.5,-12)
    preview.BackgroundColor3 = initial
    preview.BorderSizePixel = 0
    preview.Parent = holder
    corner(preview,6)
    stroke(preview, Theme.text, 0.7, 1)

    -- Простой колорпикер через HSV
    local h,s,v = initial:ToHSV()

    local function updateColor()
        local c = Color3.fromHSV(h,s,v)
        preview.BackgroundColor3 = c
        if callback then callback(c) end
    end

    -- Слайдеры H, S, V, A
    local expanded = false
    local expandFrame

    preview.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            expanded = not expanded
            if expanded then
                expandFrame = Instance.new("Frame")
                expandFrame.Size = UDim2.new(1,0,0,120)
                expandFrame.Position = UDim2.new(0,0,1,4)
                expandFrame.BackgroundColor3 = Theme.panel
                expandFrame.BorderSizePixel = 0
                expandFrame.ZIndex = 40
                expandFrame.Parent = holder
                corner(expandFrame,8)
                stroke(expandFrame,Theme.accent,.55,1)

                local layout = Instance.new("UIListLayout")
                layout.Padding = UDim.new(0,4)
                layout.Parent = expandFrame

                local pad = Instance.new("UIPadding")
                pad.PaddingTop = UDim.new(0,6)
                pad.PaddingLeft = UDim.new(0,6)
                pad.PaddingRight = UDim.new(0,6)
                pad.Parent = expandFrame

                -- H
                local hBar = Instance.new("Frame")
                hBar.Size = UDim2.new(1,0,0,10)
                hBar.BackgroundColor3 = Color3.fromRGB(55,55,58)
                hBar.BorderSizePixel = 0
                hBar.ZIndex = 41
                hBar.Parent = expandFrame
                corner(hBar,5)

                local hFill = Instance.new("Frame")
                hFill.Size = UDim2.new(h,0,1,0)
                hFill.BackgroundColor3 = Color3.fromRGB(255,0,0)
                hFill.BorderSizePixel = 0
                hFill.ZIndex = 42
                hFill.Parent = hBar
                corner(hFill,5)

                -- S
                local sBar = Instance.new("Frame")
                sBar.Size = UDim2.new(1,0,0,10)
                sBar.Position = UDim2.new(0,0,0,16)
                sBar.BackgroundColor3 = Color3.fromRGB(55,55,58)
                sBar.BorderSizePixel = 0
                sBar.ZIndex = 41
                sBar.Parent = expandFrame
                corner(sBar,5)

                local sFill = Instance.new("Frame")
                sFill.Size = UDim2.new(s,0,1,0)
                sFill.BackgroundColor3 = Color3.fromRGB(0,255,0)
                sFill.BorderSizePixel = 0
                sFill.ZIndex = 42
                sFill.Parent = sBar
                corner(sFill,5)

                -- V
                local vBar = Instance.new("Frame")
                vBar.Size = UDim2.new(1,0,0,10)
                vBar.Position = UDim2.new(0,0,0,32)
                vBar.BackgroundColor3 = Color3.fromRGB(55,55,58)
                vBar.BorderSizePixel = 0
                vBar.ZIndex = 41
                vBar.Parent = expandFrame
                corner(vBar,5)

                local vFill = Instance.new("Frame")
                vFill.Size = UDim2.new(v,0,1,0)
                vFill.BackgroundColor3 = Color3.fromRGB(0,0,255)
                vFill.BorderSizePixel = 0
                vFill.ZIndex = 42
                vFill.Parent = vBar
                corner(vFill,5)

                -- Обработка перетаскивания
                local function makeDraggable(bar, fill, setter)
                    local dragging = false
                    bar.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            local pct = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                            fill.Size = UDim2.new(pct,0,1,0)
                            setter(pct)
                            updateColor()
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                        end
                    end)
                end

                makeDraggable(hBar, hFill, function(p) h = p end)
                makeDraggable(sBar, sFill, function(p) s = p end)
                makeDraggable(vBar, vFill, function(p) v = p end)
            else
                if expandFrame then expandFrame:Destroy(); expandFrame = nil end
            end
        end
    end)

    return holder
end

local function createKeybind(parent, textValue, initial, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,0,0,34)
    holder.BackgroundColor3 = Theme.item
    holder.BorderSizePixel = 0
    holder.Parent = parent
    corner(holder,8)

    local txt = label(holder,textValue,11,Theme.text)
    txt.Position = UDim2.fromOffset(10,0)
    txt.Size = UDim2.new(1,-90,1,0)
    txt.TextXAlignment = Enum.TextXAlignment.Left

    local keyLabel = label(holder, initial.Name, 10, Theme.accent)
    keyLabel.Position = UDim2.new(1,-80,0,0)
    keyLabel.Size = UDim2.fromOffset(70,34)
    keyLabel.TextXAlignment = Enum.TextXAlignment.Right

    local listening = false

    local bindBtn = button(holder, "")
    bindBtn.Size = UDim2.fromOffset(70,26)
    bindBtn.Position = UDim2.new(1,-80,.5,-13)
    bindBtn.Text = ""
    bindBtn.BackgroundTransparency = 1

    bindBtn.MouseButton1Click:Connect(function()
        listening = true
        keyLabel.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if not listening then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            keyLabel.Text = input.KeyCode.Name
            listening = false
            if callback then callback(input.KeyCode) end
        end
    end)

    return holder
end

--//==================================================
--// COMBAT PAGE
--//==================================================

createSection(CombatPage, "Aimbot")
createToggle(CombatPage, "Aimbot", Config.Combat.Aimbot, function(v) Config.Combat.Aimbot=v end)
createKeybind(CombatPage, "Aimbot Key", Config.Combat.AimbotKey, function(v) Config.Combat.AimbotKey=v end)
createSlider(CombatPage, "Aimbot FOV", 40, 300, Config.Combat.AimbotFOV, function(v) Config.Combat.AimbotFOV=v end)
createSlider(CombatPage, "Aimbot Smoothness", 1, 100, math.floor(Config.Combat.AimbotSmoothness*100), function(v) Config.Combat.AimbotSmoothness=v/100 end)
createDropdown(CombatPage, "Hitbox", {"Head","Body","Neck","Random"}, "Head", function(v) Config.Combat.AimbotHitbox=v end)
createDropdown(CombatPage, "Target Mode", {"Closest","Random","Lowest HP"}, "Closest", function(v) Config.Combat.AimbotTargetMode=v end)

createSection(CombatPage, "Silent Aim")
createToggle(CombatPage, "Silent Aim", Config.Combat.SilentAim, function(v) Config.Combat.SilentAim=v end)
createSlider(CombatPage, "Silent Aim FOV", 40, 300, Config.Combat.SilentAimFOV, function(v) Config.Combat.SilentAimFOV=v end)

createSection(CombatPage, "Weapon")
createToggle(CombatPage, "No Recoil", Config.Combat.NoRecoil, function(v) Config.Combat.NoRecoil=v end)
createToggle(CombatPage, "No Spread", Config.Combat.NoSpread, function(v) Config.Combat.NoSpread=v end)
createToggle(CombatPage, "No Sway", Config.Combat.NoSway, function(v) Config.Combat.NoSway=v end)
createToggle(CombatPage, "No Scope", Config.Combat.NoScope, function(v) Config.Combat.NoScope=v end)
createToggle(CombatPage, "Instant Hit", Config.Combat.InstantHit, function(v) Config.Combat.InstantHit=v end)
createToggle(CombatPage, "Infinite Ammo", Config.Combat.InfiniteAmmo, function(v) Config.Combat.InfiniteAmmo=v end)
createToggle(CombatPage, "Rapid Fire", Config.Combat.RapidFire, function(v) Config.Combat.RapidFire=v end)
createToggle(CombatPage, "Fast Reload", Config.Combat.FastReload, function(v) Config.Combat.FastReload=v end)
createToggle(CombatPage, "Headshot Only", Config.Combat.HeadshotOnly, function(v) Config.Combat.HeadshotOnly=v end)
createToggle(CombatPage, "Wall Check", Config.Combat.WallCheck, function(v) Config.Combat.WallCheck=v end)

createSection(CombatPage, "FOV Circle")
createToggle(CombatPage, "FOV Circle", Config.Combat.FOVCircle, function(v) Config.Combat.FOVCircle=v end)
createColorPicker(CombatPage, "FOV Circle Color", Config.Combat.FOVCircleColor, function(c) Config.Combat.FOVCircleColor=c end)
createSlider(CombatPage, "FOV Circle Thickness", 1, 5, Config.Combat.FOVCircleThickness, function(v) Config.Combat.FOVCircleThickness=v end)

--//==================================================
--// VISUALS PAGE
--//==================================================

createSection(VisualsPage, "ESP")
createToggle(VisualsPage, "ESP", Config.Visuals.ESP, function(v) Config.Visuals.ESP=v end)
createToggle(VisualsPage, "Box", Config.Visuals.Box, function(v) Config.Visuals.Box=v end)
createDropdown(VisualsPage, "Box Style", {"2D","Corner","3D"}, "2D", function(v) Config.Visuals.BoxStyle=v end)
createColorPicker(VisualsPage, "Box Color", Config.Visuals.BoxColor, function(c) Config.Visuals.BoxColor=c end)
createToggle(VisualsPage, "Box Fill", Config.Visuals.BoxFill, function(v) Config.Visuals.BoxFill=v end)
createColorPicker(VisualsPage, "Box Fill Color", Config.Visuals.BoxFillColor, function(c) Config.Visuals.BoxFillColor=c end)
createSlider(VisualsPage, "Box Fill Alpha", 0, 100, math.floor(Config.Visuals.BoxFillAlpha*100), function(v) Config.Visuals.BoxFillAlpha=v/100 end)
createToggle(VisualsPage, "Name", Config.Visuals.Name, function(v) Config.Visuals.Name=v end)
createColorPicker(VisualsPage, "Name Color", Config.Visuals.NameColor, function(c) Config.Visuals.NameColor=c end)
createToggle(VisualsPage, "Distance", Config.Visuals.Distance, function(v) Config.Visuals.Distance=v end)
createColorPicker(VisualsPage, "Distance Color", Config.Visuals.DistanceColor, function(c) Config.Visuals.DistanceColor=c end)
createToggle(VisualsPage, "Health Bar", Config.Visuals.HealthBar, function(v) Config.Visuals.HealthBar=v end)
createToggle(VisualsPage, "Health Text", Config.Visuals.HealthText, function(v) Config.Visuals.HealthText=v end)
createToggle(VisualsPage, "Armor Bar", Config.Visuals.ArmorBar, function(v) Config.Visuals.ArmorBar=v end)
createToggle(VisualsPage, "Weapon Name", Config.Visuals.WeaponName, function(v) Config.Visuals.WeaponName=v end)
createToggle(VisualsPage, "Skeleton", Config.Visuals.Skeleton, function(v) Config.Visuals.Skeleton=v end)
createColorPicker(VisualsPage, "Skeleton Color", Config.Visuals.SkeletonColor, function(c) Config.Visuals.SkeletonColor=c end)
createToggle(VisualsPage, "Head Dot", Config.Visuals.HeadDot, function(v) Config.Visuals.HeadDot=v end)
createColorPicker(VisualsPage, "Head Dot Color", Config.Visuals.HeadDotColor, function(c) Config.Visuals.HeadDotColor=c end)

createSection(VisualsPage, "Chams")
createToggle(VisualsPage, "Chams", Config.Visuals.Chams, function(v) Config.Visuals.Chams=v end)
createColorPicker(VisualsPage, "Chams Color", Config.Visuals.ChamsColor, function(c) Config.Visuals.ChamsColor=c end)
createToggle(VisualsPage, "Chams Visible Only", Config.Visuals.ChamsVisibleOnly, function(v) Config.Visuals.ChamsVisibleOnly=v end)

createSection(VisualsPage, "Tracers")
createToggle(VisualsPage, "Tracers", Config.Visuals.Tracers, function(v) Config.Visuals.Tracers=v end)
createDropdown(VisualsPage, "Tracer Origin", {"Bottom","Top","Center"}, "Bottom", function(v) Config.Visuals.TracerOrigin=v end)
createColorPicker(VisualsPage, "Tracer Color", Config.Visuals.TracerColor, function(c) Config.Visuals.TracerColor=c end)

createSection(VisualsPage, "Offscreen")
createToggle(VisualsPage, "Offscreen Arrows", Config.Visuals.OffscreenArrows, function(v) Config.Visuals.OffscreenArrows=v end)
createColorPicker(VisualsPage, "Offscreen Arrows Color", Config.Visuals.OffscreenArrowsColor, function(c) Config.Visuals.OffscreenArrowsColor=c end)

createSection(VisualsPage, "Colors")
createSlider(VisualsPage, "Max Distance", 50, 2000, Config.Visuals.MaxDistance, function(v) Config.Visuals.MaxDistance=v end)
createColorPicker(VisualsPage, "Team Color", Config.Visuals.TeamColor, function(c) Config.Visuals.TeamColor=c end)
createColorPicker(VisualsPage, "Enemy Color", Config.Visuals.EnemyColor, function(c) Config.Visuals.EnemyColor=c end)
createColorPicker(VisualsPage, "Priority Color", Config.Visuals.PriorityColor, function(c) Config.Visuals.PriorityColor=c end)

createSection(VisualsPage, "Wallhack")
createToggle(VisualsPage, "Wallhack", Config.Visuals.Wallhack, function(v) Config.Visuals.Wallhack=v end)
createSlider(VisualsPage, "Wallhack Opacity", 0, 100, math.floor(Config.Visuals.WallhackOpacity*100), function(v) Config.Visuals.WallhackOpacity=v/100 end)
createColorPicker(VisualsPage, "Wallhack Color", Config.Visuals.WallhackColor, function(c) Config.Visuals.WallhackColor=c end)

createSection(VisualsPage, "Radar")
createToggle(VisualsPage, "Radar", Config.Visuals.Radar, function(v) Config.Visuals.Radar=v end)
createSlider(VisualsPage, "Radar Size", 50, 300, Config.Visuals.RadarSize, function(v) Config.Visuals.RadarSize=v end)
createSlider(VisualsPage, "Radar Zoom", 1, 10, Config.Visuals.RadarZoom, function(v) Config.Visuals.RadarZoom=v end)
createDropdown(VisualsPage, "Radar Position", {"TopRight","TopLeft","BottomRight","BottomLeft"}, "TopRight", function(v) Config.Visuals.RadarPosition=v end)
createToggle(VisualsPage, "Radar Rotate", Config.Visuals.RadarRotate, function(v) Config.Visuals.RadarRotate=v end)
createToggle(VisualsPage, "Radar Show Names", Config.Visuals.RadarShowNames, function(v) Config.Visuals.RadarShowNames=v end)

createSection(VisualsPage, "Sound")
createToggle(VisualsPage, "Sound ESP", Config.Visuals.SoundESP, function(v) Config.Visuals.SoundESP=v end)
createSlider(VisualsPage, "Sound ESP Radius", 10, 200, Config.Visuals.SoundESPRadius, function(v) Config.Visuals.SoundESPRadius=v end)
createColorPicker(VisualsPage, "Sound ESP Color", Config.Visuals.SoundESPColor, function(c) Config.Visuals.SoundESPColor=c end)
createToggle(VisualsPage, "Footstep ESP", Config.Visuals.FootstepESP, function(v) Config.Visuals.FootstepESP=v end)

createSection(VisualsPage, "Grenade / Bomb")
createToggle(VisualsPage, "Grenade ESP", Config.Visuals.GrenadeESP, function(v) Config.Visuals.GrenadeESP=v end)
createToggle(VisualsPage, "Grenade Warning", Config.Visuals.GrenadeWarning, function(v) Config.Visuals.GrenadeWarning=v end)
createToggle(VisualsPage, "Bomb ESP", Config.Visuals.BombESP, function(v) Config.Visuals.BombESP=v end)
createToggle(VisualsPage, "Defuse Timer", Config.Visuals.DefuseTimer, function(v) Config.Visuals.DefuseTimer=v end)
createToggle(VisualsPage, "Plant Timer", Config.Visuals.PlantTimer, function(v) Config.Visuals.PlantTimer=v end)

--//==================================================
--// WORLD PAGE
--//==================================================

createSection(WorldPage, "Эффекты")
createSlider(WorldPage, "Brightness", -100, 100, Config.Effects.Brightness, function(v) Config.Effects.Brightness=v end)
createSlider(WorldPage, "Contrast", -100, 100, Config.Effects.Contrast, function(v) Config.Effects.Contrast=v end)
createSlider(WorldPage, "Saturation", -100, 100, Config.Effects.Saturation, function(v) Config.Effects.Saturation=v end)
createSlider(WorldPage, "Gamma", -100, 100, Config.Effects.Gamma, function(v) Config.Effects.Gamma=v end)

createSection(WorldPage, "Цвета")
createToggle(WorldPage, "Player Color", Config.Effects.PlayerColor, function(v) Config.Effects.PlayerColor=v end)
createColorPicker(WorldPage, "Player Color Value", Config.Effects.PlayerColorValue, function(c) Config.Effects.PlayerColorValue=c end)

createSection(WorldPage, "Туман")
createColorPicker(WorldPage, "Fog Color", Config.Effects.FogColor, function(c) Config.Effects.FogColor=c end)
createSlider(WorldPage, "Fog Density", 0, 100, math.floor(Config.Effects.FogDensity*100), function(v) Config.Effects.FogDensity=v/100 end)

createSection(WorldPage, "Режимы")
createToggle(WorldPage, "Night Mode", Config.Effects.NightMode, function(v) Config.Effects.NightMode=v end)
createSlider(WorldPage, "Night Mode Intensity", 0, 100, math.floor(Config.Effects.NightModeIntensity*100), function(v) Config.Effects.NightModeIntensity=v/100 end)
createToggle(WorldPage, "Fullbright", Config.Effects.Fullbright, function(v) Config.Effects.Fullbright=v end)
createToggle(WorldPage, "No Fog", Config.Effects.NoFog, function(v) Config.Effects.NoFog=v end)
createToggle(WorldPage, "No Grass", Config.Effects.NoGrass, function(v) Config.Effects.NoGrass=v end)
createToggle(WorldPage, "No Flash", Config.Effects.NoFlash, function(v) Config.Effects.NoFlash=v end)
createToggle(WorldPage, "No Smoke", Config.Effects.NoSmoke, function(v) Config.Effects.NoSmoke=v end)

createSection(WorldPage, "Skybox")
createToggle(WorldPage, "Skybox Changer", Config.Effects.SkyboxChanger, function(v) Config.Effects.SkyboxChanger=v end)
createDropdown(WorldPage, "Skybox", {"Default","Night","Sunset","Space","City"}, "Default", function(v) Config.Effects.SkyboxName=v end)

createSection(WorldPage, "Движение")
createToggle(WorldPage, "Bhop", Config.Effects.Bhop, function(v) Config.Effects.Bhop=v end)
createSlider(WorldPage, "Bhop Chance", 0, 100, Config.Effects.BhopChance, function(v) Config.Effects.BhopChance=v end)
createToggle(WorldPage, "Auto Strafe", Config.Effects.AutoStrafe, function(v) Config.Effects.AutoStrafe=v end)
createToggle(WorldPage, "No Clip", Config.Effects.NoClip, function(v) Config.Effects.NoClip=v end)

createSection(WorldPage, "Информация")
createToggle(WorldPage, "Watermark", Config.Effects.Watermark, function(v) Config.Effects.Watermark=v end)
createToggle(WorldPage, "FPS Counter", Config.Effects.FPSCounter, function(v) Config.Effects.FPSCounter=v end)
createToggle(WorldPage, "Ping Counter", Config.Effects.PingCounter, function(v) Config.Effects.PingCounter=v end)

--//==================================================
--// MISC PAGE
--//==================================================

createSection(MiscPage, "Персонаж")
createSlider(MiscPage, "Speed", 16, 200, Config.Misc.Speed, function(v) Config.Misc.Speed=v end)
createSlider(MiscPage, "Jump Power", 50, 500, Config.Misc.JumpPower, function(v) Config.Misc.JumpPower=v end)
createToggle(MiscPage, "Invisible", Config.Misc.Invisible, function(v) Config.Misc.Invisible=v end)
createToggle(MiscPage, "Fly", Config.Misc.Fly, function(v) Config.Misc.Fly=v end)
createSlider(MiscPage, "Fly Speed", 10, 200, Config.Misc.FlySpeed, function(v) Config.Misc.FlySpeed=v end)

createSection(MiscPage, "Телепорт")
createToggle(MiscPage, "Teleport", Config.Misc.Teleport, function(v)
    Config.Misc.Teleport=v
    if v and LocalPlayer.Character then
        local target = Players:FindFirstChild(Config.Misc.TeleportTarget)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
end)

createSection(MiscPage, "Уведомления")
createToggle(MiscPage, "Notifications", Config.Misc.Notifications, function(v) Config.Misc.Notifications=v end)
createKeybind(MiscPage, "Menu Hotkey", Config.Misc.Hotkey, function(v) Config.Misc.Hotkey=v end)

--//==================================================
--// CONFIG PAGE
--//==================================================

createSection(ConfigPage, "Тема")
createDropdown(ConfigPage, "Theme", {"Dark","Light","Purple","Blood","Cyber","Toxic","RGB"}, Config.Theme, function(v)
    Config.Theme=v
    Theme=Themes[v]
    refreshTheme()
end)

createSection(ConfigPage, "Интерфейс")
createSlider(ConfigPage, "UI Scale", 70, 130, 100, function(v)
    Config.WindowScale=v/100
    Scale.Scale=Config.WindowScale
end)

createSection(ConfigPage, "Конфиги")
local SaveBtn = button(ConfigPage, "SAVE CONFIG")
SaveBtn.Size = UDim2.new(1,0,0,34)
SaveBtn.MouseButton1Click:Connect(function() saveConfig() end)

local LoadBtn = button(ConfigPage, "LOAD CONFIG")
LoadBtn.Size = UDim2.new(1,0,0,34)
LoadBtn.MouseButton1Click:Connect(function() loadConfig() end)

local ResetBtn = button(ConfigPage, "RESET CONFIG")
ResetBtn.Size = UDim2.new(1,0,0,34)
ResetBtn.BackgroundColor3 = Color3.fromRGB(180,50,55)
ResetBtn.TextColor3 = Color3.fromRGB(255,255,255)
ResetBtn.MouseButton1Click:Connect(function()
    -- Сброс к дефолту (упрощённо)
    notify("Config reset", Color3.fromRGB(180,50,55))
end)

local UnloadBtn = button(ConfigPage, "UNLOAD")
UnloadBtn.Size = UDim2.new(1,0,0,34)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(180,50,55)
UnloadBtn.TextColor3 = Color3.fromRGB(255,255,255)
UnloadBtn.MouseButton1Click:Connect(function()
    if getgenv().LEMOS_LOADED then getgenv().LEMOS_LOADED = false end
    GUI:Destroy()
    print("[LEMOS] Unloaded.")
end)

--//==================================================
--// СИСТЕМА ВКЛАДОК
--//==================================================

local activeTab = nil

function activate(name)
    if activeTab == name then return end
    activeTab = name

    for pageName,page in pairs(Pages) do
        page.Visible = (pageName == name)
    end

    for tabName,data in pairs(Tabs) do
        local active = (tabName == name)
        data.Button.BackgroundColor3 = active and Theme.accent or Theme.item
        data.Button.TextColor3 = active and Theme.bg or Theme.sub
    end
end

CombatTab.MouseButton1Click:Connect(function() activate("Combat") end)
VisualsTab.MouseButton1Click:Connect(function() activate("Visuals") end)
WorldTab.MouseButton1Click:Connect(function() activate("World") end)
MiscTab.MouseButton1Click:Connect(function() activate("Misc") end)
ConfigTab.MouseButton1Click:Connect(function() activate("Config") end)

--//==================================================
--// DRAWING ESP (упрощённо, для примера)
--//==================================================

local ESPObjects = {}

local function createDrawingESP(model)
    if not HasDrawing then return end
    if not model:IsA("Model") then return end
    if model == LocalPlayer.Character then return end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
    if not humanoid or not root then return end
    if ESPObjects[model] then return end

    local box = DrawingAPI.new("Square")
    box.Thickness = 1
    box.Color = Config.Visuals.BoxColor
    box.Filled = false
    box.Visible = false

    local name = DrawingAPI.new("Text")
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.Color = Config.Visuals.NameColor
    name.Visible = false

    local distance = DrawingAPI.new("Text")
    distance.Size = 12
    distance.Center = true
    distance.Outline = true
    distance.Color = Config.Visuals.DistanceColor
    distance.Visible = false

    local hpBar = DrawingAPI.new("Square")
    hpBar.Thickness = 1
    hpBar.Filled = true
    hpBar.Color = Color3.fromRGB(90, 225, 105)
    hpBar.Visible = false

    local tracer = DrawingAPI.new("Line")
    tracer.Thickness = 1
    tracer.Color = Config.Visuals.TracerColor
    tracer.Visible = false

    local cham = nil
    if Config.Visuals.Chams then
        cham = Instance.new("Highlight")
        cham.Adornee = model
        cham.FillColor = Config.Visuals.ChamsColor
        cham.OutlineColor = Config.Visuals.ChamsColor
        cham.FillTransparency = 0.5
        cham.OutlineTransparency = 0
        cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        cham.Parent = GUI
    end

    ESPObjects[model] = {
        Box = box,
        Name = name,
        Distance = distance,
        HPBar = hpBar,
        Tracer = tracer,
        Cham = cham,
    }
end

local function removeDrawingESP(model)
    local data = ESPObjects[model]
    if data then
        for _, obj in pairs(data) do
            if typeof(obj) == "Instance" then
                pcall(function() obj:Destroy() end)
            elseif obj and obj.Remove then
                obj:Remove()
            end
        end
        ESPObjects[model] = nil
    end
end

local function updateDrawingESP()
    if not Config.Visuals.ESP then
        for model, data in pairs(ESPObjects) do
            for _, obj in pairs(data) do
                if obj and obj.Visible ~= nil then obj.Visible = false end
            end
        end
        return
    end

    for model, data in pairs(ESPObjects) do
        if not model.Parent then
            removeDrawingESP(model)
            continue
        end

        local humanoid = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
        if not humanoid or not root then
            removeDrawingESP(model)
            continue
        end

        local position, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            for _, obj in pairs(data) do
                if obj and obj.Visible ~= nil then obj.Visible = false end
            end
            continue
        end

        if Config.Visuals.Box then
            local topPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
            local height = math.abs(topPos.Y - position.Y)
            local width = height * 0.65

            data.Box.Size = Vector2.new(width, height)
            data.Box.Position = Vector2.new(position.X - width/2, position.Y - height/2)
            data.Box.Color = Config.Visuals.BoxColor
            data.Box.Visible = true
        else
            data.Box.Visible = false
        end

        if Config.Visuals.Name then
            data.Name.Text = model.Name
            data.Name.Position = Vector2.new(position.X, position.Y - 30)
            data.Name.Color = Config.Visuals.NameColor
            data.Name.Visible = true
        else
            data.Name.Visible = false
        end

        if Config.Visuals.Distance then
            local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local dist = localRoot and (localRoot.Position - root.Position).Magnitude or 0
            data.Distance.Text = math.floor(dist) .. " studs"
            data.Distance.Position = Vector2.new(position.X, position.Y + 20)
            data.Distance.Color = Config.Visuals.DistanceColor
            data.Distance.Visible = true
        else
            data.Distance.Visible = false
        end

        if Config.Visuals.HealthBar then
            local hp = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
            data.HPBar.Size = Vector2.new(width + 4, 2)
            data.HPBar.Position = Vector2.new(position.X - width/2 - 2, position.Y - height/2 - 5)
            data.HPBar.Color = Color3.fromRGB(90, 225, 105)
            data.HPBar.Visible = true
        else
            data.HPBar.Visible = false
        end

        if Config.Visuals.Tracers then
            local origin = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            if Config.Visuals.TracerOrigin == "Top" then
                origin = Vector2.new(Camera.ViewportSize.X/2, 0)
            elseif Config.Visuals.TracerOrigin == "Center" then
                origin = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            end
            data.Tracer.From = origin
            data.Tracer.To = Vector2.new(position.X, position.Y)
            data.Tracer.Color = Config.Visuals.TracerColor
            data.Tracer.Visible = true
        else
            data.Tracer.Visible = false
        end

        if Config.Visuals.Chams and data.Cham then
            data.Cham.Enabled = true
            data.Cham.FillColor = Config.Visuals.ChamsColor
        elseif data.Cham then
            data.Cham.Enabled = false
        end
    end
end

--//==================================================
--// FOV CIRCLE
--//==================================================

local FOVCircle = DrawingAPI and DrawingAPI.new("Circle") or nil
if FOVCircle then
    FOVCircle.Thickness = Config.Combat.FOVCircleThickness
    FOVCircle.Color = Config.Combat.FOVCircleColor
    FOVCircle.Filled = false
    FOVCircle.Visible = false
    FOVCircle.Transparency = 0.7
end

--//==================================================
--// RENDER LOOP
--//==================================================

RunService.RenderStepped:Connect(function(dt)
    pcall(updateDrawingESP)

    local camera = Workspace.CurrentCamera
    if camera then
        Camera = camera
        if FOVCircle then
            local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
            FOVCircle.Position = center
            FOVCircle.Radius = Config.Combat.AimbotFOV
            FOVCircle.Color = Config.Combat.FOVCircleColor
            FOVCircle.Thickness = Config.Combat.FOVCircleThickness
            FOVCircle.Visible = Config.Combat.FOVCircle and Config.Combat.Aimbot
        end
    end
end)

--//==================================================
--// SCAN & INIT
--//==================================================

local function scanTargets()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            createDrawingESP(obj)
        end
    end
end

Workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.15)
    if obj:IsA("Model") then
        createDrawingESP(obj)
    end
end)

Workspace.DescendantRemoving:Connect(function(obj)
    if ESPObjects[obj] then
        removeDrawingESP(obj)
    end
end)

--//==================================================
--// КОНФИГ SAVE/LOAD
--//==================================================

function saveConfig()
    if not makefolder or not isfolder then return end
    if not isfolder(Config.ScriptName) then
        makefolder(Config.ScriptName)
    end
    local path = Config.ScriptName .. "/config.json"
    local data = {}
    for k, v in pairs(Config) do
        if type(v) == "table" then
            data[k] = {}
            for k2, v2 in pairs(v) do
                if type(v2) == "Color3" then
                    data[k][k2] = {v2.R, v2.G, v2.B}
                elseif typeof(v2) == "EnumItem" then
                    data[k][k2] = v2.Name
                else
                    data[k][k2] = v2
                end
            end
        else
            data[k] = v
        end
    end
    safeWriteFile(path, HttpService:JSONEncode(data))
    notify("Config saved", Theme.accent)
end

function loadConfig()
    local path = Config.ScriptName .. "/config.json"
    if safeIsFile(path) then
        local success, content = safeReadFile(path)
        if success and content then
            local data = HttpService:JSONDecode(content)
            for k, v in pairs(data) do
                if type(v) == "table" and Config[k] then
                    for k2, v2 in pairs(v) do
                        if type(v2) == "table" and v2[1] and v2[2] and v2[3] then
                            Config[k][k2] = Color3.new(v2[1], v2[2], v2[3])
                        else
                            Config[k][k2] = v2
                        end
                    end
                else
                    Config[k] = v
                end
            end
            notify("Config loaded", Theme.accent)
        end
    end
end

--//==================================================
--// УПРАВЛЕНИЕ ОКНОМ
--//==================================================

Close.MouseButton1Click:Connect(function() Main.Visible = false end)

local minimized = false
local savedSize = Main.Size

Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        savedSize = Main.Size
        Main.Size = UDim2.fromOffset(560,50)
        Sidebar.Visible = false
        Content.Visible = false
    else
        Main.Size = savedSize
        Sidebar.Visible = true
        Content.Visible = true
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.Misc.Hotkey then
        Main.Visible = not Main.Visible
    end
end)

--// Drag
local dragging = false
local dragStart = nil
local startPosition = nil

local function beginDrag(input)
    dragging = true
    dragStart = input.Position
    startPosition = Main.Position
    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then dragging = false end
    end)
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        beginDrag(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

--//==================================================
--// ОБНОВЛЕНИЕ ТЕМЫ
--//==================================================

function refreshTheme()
    Theme = Themes[Config.Theme]
    Main.BackgroundColor3 = Theme.bg
    MainStroke.Color = Theme.accent
    Logo.BackgroundColor3 = Theme.accent
    LogoText.TextColor3 = Theme.bg
    Title.TextColor3 = Theme.text
    Version.TextColor3 = Theme.accent
    SideStroke.Color = Theme.text
    for _, data in pairs(Tabs) do
        data.Button.BackgroundColor3 = Theme.item
        data.Button.TextColor3 = Theme.sub
    end
    if FOVCircle then FOVCircle.Color = Config.Combat.FOVCircleColor end
    if activeTab then
        local old = activeTab
        activeTab = nil
        activate(old)
    end
end

--//==================================================
--// СТАРТ
--//==================================================

loadConfig()
scanTargets()
activate("Combat")

print("[LEMOS] 0.2 loaded. Executor: " .. Executor)
