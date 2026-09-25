--// LEMOS 0.1
--// Universal Executor Script
--// Synapse X / Script-Ware / Fluxus / Delta / Solara / Wave

--//==================================================
--// EXECUTOR CHECK
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
--// SAFE WRAPPERS
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
--// SERVICES
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
--// CONFIG
--//==================================================

local Config = {
    ScriptName = "LEMOS",
    Version = "0.1",
    WindowScale = 1,
    WindowTransparency = 0.06,
    Theme = "Dark",

    ESP = {
        Enabled = true,
        Boxes = true,
        Health = true,
        Names = true,
        Distance = true,
        Tracers = true,
        Chams = false,
        VisibilityCheck = true,
        BoxScale = 1.15,
        Color = Color3.fromRGB(255, 111, 25),
        TracerColor = Color3.fromRGB(255, 111, 25),
        ChamColor = Color3.fromRGB(255, 111, 25),
    },

    AIM = {
        Enabled = false,
        FOV = 140,
        Smoothness = 0.15,
        Bone = "Head",
        SilentAim = false,
        Triggerbot = false,
        TriggerDelay = 0.1,
        VisibleCheck = true,
        Sensitivity = 0.5,
    },

    Visual = {
        Fog = false,
        FogColor = Color3.fromRGB(255, 0, 0),
        FogStart = 0,
        FogEnd = 500,
        ThirdPerson = false,
        ThirdPersonDistance = 8,
        ThirdPersonHeight = 2,
        Spinbot = false,
        SpinbotSpeed = 10,
        Scale = 1,
        PlayerColor = false,
        PlayerColorValue = Color3.fromRGB(255, 0, 0),
    },

    Misc = {
        Speed = 16,
        Teleport = false,
        TeleportTarget = "",
        Invisible = false,
    },
}

--//==================================================
--// THEMES
--//==================================================

local Themes = {
    Dark = {accent=Color3.fromRGB(255,111,25), bg=Color3.fromRGB(12,12,13), panel=Color3.fromRGB(18,18,19), item=Color3.fromRGB(22,22,23), text=Color3.fromRGB(245,245,245), sub=Color3.fromRGB(135,135,135)},
    Light = {accent=Color3.fromRGB(255,105,30), bg=Color3.fromRGB(238,238,240), panel=Color3.fromRGB(250,250,252), item=Color3.fromRGB(232,232,235), text=Color3.fromRGB(25,25,28), sub=Color3.fromRGB(105,105,110)},
    ["Purple Neon"] = {accent=Color3.fromRGB(177,90,255), bg=Color3.fromRGB(12,9,17), panel=Color3.fromRGB(22,16,29), item=Color3.fromRGB(29,21,38), text=Color3.fromRGB(247,242,255), sub=Color3.fromRGB(155,135,175)},
    ["Red Blood"] = {accent=Color3.fromRGB(235,55,65), bg=Color3.fromRGB(16,9,10), panel=Color3.fromRGB(27,14,15), item=Color3.fromRGB(38,18,20), text=Color3.fromRGB(255,242,243), sub=Color3.fromRGB(165,125,128)},
    ["Blue Cyber"] = {accent=Color3.fromRGB(50,160,255), bg=Color3.fromRGB(8,13,19), panel=Color3.fromRGB(13,22,31), item=Color3.fromRGB(18,29,40), text=Color3.fromRGB(240,248,255), sub=Color3.fromRGB(125,155,180)},
    ["Green Toxic"] = {accent=Color3.fromRGB(90,225,105), bg=Color3.fromRGB(8,14,9), panel=Color3.fromRGB(14,24,16), item=Color3.fromRGB(19,32,21), text=Color3.fromRGB(240,255,241), sub=Color3.fromRGB(130,165,135)},
    RGB = {accent=Color3.fromRGB(255,80,200), bg=Color3.fromRGB(10,10,14), panel=Color3.fromRGB(18,18,24), item=Color3.fromRGB(25,25,34), text=Color3.fromRGB(245,245,250), sub=Color3.fromRGB(135,135,150)},
}

local Theme = Themes[Config.Theme]

--//==================================================
--// HELPERS
--//==================================================

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 9)
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
--// CLEAN OLD UI
--//==================================================

local guiParent = (gethui and gethui()) or PlayerGui
local old = guiParent:FindFirstChild("LEMOS_UI")
if old then old:Destroy() end

--//==================================================
--// LOADING SCREEN
--//==================================================

local Loading = Instance.new("Frame")
Loading.Name = "LEMOS_Loading"
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

local LoadTitle = label(LoadBox, "LEMOS 0.1", 20, Theme.text)
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
--// GUI
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
Main.Size = UDim2.fromOffset(460, 320)
Main.Position = UDim2.new(.5, -230, .5, -160)
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

local Version = label(Header,"0.1",10,Theme.accent)
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
Sidebar.Size = UDim2.fromOffset(105,255)
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
    b.Size = UDim2.new(1,0,0,38)
    b.TextSize = 11
    b.TextColor3 = Theme.sub

    Tabs[name] = {Button=b}
    return b
end

local ESPTab = createTab("ESP")
local AIMTab = createTab("AIM")
local VisualTab = createTab("VISUAL")
local MiscTab = createTab("MISC")
local SettingsTab = createTab("CONFIG")

--//==================================================
--// CONTENT
--//==================================================

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(125,55)
Content.Size = UDim2.new(1,-135,1,-67)
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

local ESPPage = createPage("ESP")
local AIMPage = createPage("AIM")
local VisualPage = createPage("VISUAL")
local MiscPage = createPage("MISC")
local SettingsPage = createPage("CONFIG")

--//==================================================
--// CONTROLS
--//==================================================

local function createToggle(parent,textValue,initial,callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,0,0,36)
    holder.BackgroundColor3 = Theme.item
    holder.BorderSizePixel = 0
    holder.Parent = parent
    corner(holder,8)

    local txt = label(holder,textValue,11,Theme.text)
    txt.Position = UDim2.fromOffset(10,0)
    txt.Size = UDim2.new(1,-60,1,0)
    txt.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.fromOffset(36,20)
    toggle.Position = UDim2.new(1,-46,.5,-10)
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.BorderSizePixel = 0
    toggle.Parent = holder
    corner(toggle,18)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14,14)
    knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    corner(knob,18)

    local state = initial

    local function update()
        toggle.BackgroundColor3 = state and Theme.accent or Color3.fromRGB(55,55,58)
        knob.Position = state and UDim2.new(1,-17,.5,-7) or UDim2.new(0,3,.5,-7)
        if callback then callback(state) end
    end

    toggle.MouseButton1Click:Connect(function()
        state = not state
        update()
    end)

    update()
    return holder
end

local function createSlider(parent,textValue,min,max,initial,callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,0,0,52)
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

local function createDropdown(parent,textValue,options,initial,callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,0,0,38)
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
    b.Size = UDim2.new(.47,0,0,26)
    b.Position = UDim2.new(.51,0,.5,-13)
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
        list.Size = UDim2.new(1,0,0,#options*28+6)
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
            item.Size = UDim2.new(1,-6,0,26)
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

--//==================================================
--// ESP PAGE
--//==================================================

createToggle(ESPPage,"ESP",Config.ESP.Enabled,function(v) Config.ESP.Enabled=v end)
createToggle(ESPPage,"Boxes",Config.ESP.Boxes,function(v) Config.ESP.Boxes=v end)
createToggle(ESPPage,"Health",Config.ESP.Health,function(v) Config.ESP.Health=v end)
createToggle(ESPPage,"Names",Config.ESP.Names,function(v) Config.ESP.Names=v end)
createToggle(ESPPage,"Distance",Config.ESP.Distance,function(v) Config.ESP.Distance=v end)
createToggle(ESPPage,"Tracers",Config.ESP.Tracers,function(v) Config.ESP.Tracers=v end)
createToggle(ESPPage,"Chams",Config.ESP.Chams,function(v) Config.ESP.Chams=v end)
createToggle(ESPPage,"Visibility Check",Config.ESP.VisibilityCheck,function(v) Config.ESP.VisibilityCheck=v end)
createSlider(ESPPage,"Box Scale",100,150,math.floor(Config.ESP.BoxScale*100),function(v) Config.ESP.BoxScale=v/100 end)

--//==================================================
--// AIM PAGE
--//==================================================

createToggle(AIMPage,"Aim Assist",Config.AIM.Enabled,function(v) Config.AIM.Enabled=v end)
createToggle(AIMPage,"Silent Aim",Config.AIM.SilentAim,function(v) Config.AIM.SilentAim=v end)
createToggle(AIMPage,"Triggerbot",Config.AIM.Triggerbot,function(v) Config.AIM.Triggerbot=v end)
createToggle(AIMPage,"Visible Only",Config.AIM.VisibleCheck,function(v) Config.AIM.VisibleCheck=v end)
createSlider(AIMPage,"FOV",40,300,Config.AIM.FOV,function(v) Config.AIM.FOV=v end)
createSlider(AIMPage,"Smoothness",1,100,math.floor(Config.AIM.Smoothness*100),function(v) Config.AIM.Smoothness=v/100 end)
createSlider(AIMPage,"Sensitivity",1,100,math.floor(Config.AIM.Sensitivity*100),function(v) Config.AIM.Sensitivity=v/100 end)
createSlider(AIMPage,"Trigger Delay",1,50,math.floor(Config.AIM.TriggerDelay*100),function(v) Config.AIM.TriggerDelay=v/100 end)
createDropdown(AIMPage,"Bone",{"Head","HumanoidRootPart","UpperTorso"},"Head",function(v) Config.AIM.Bone=v end)

--//==================================================
--// VISUAL PAGE
--//==================================================

createToggle(VisualPage,"Fog",Config.Visual.Fog,function(v) Config.Visual.Fog=v end)
createSlider(VisualPage,"Fog Start",0,500,Config.Visual.FogStart,function(v) Config.Visual.FogStart=v end)
createSlider(VisualPage,"Fog End",100,2000,Config.Visual.FogEnd,function(v) Config.Visual.FogEnd=v end)
createDropdown(VisualPage,"Fog Color",{"Red","Blue","Green","Purple","White","Black"},"Red",function(v)
    local colors = {Red=Color3.fromRGB(255,0,0),Blue=Color3.fromRGB(0,0,255),Green=Color3.fromRGB(0,255,0),Purple=Color3.fromRGB(175,0,255),White=Color3.fromRGB(255,255,255),Black=Color3.fromRGB(0,0,0)}
    Config.Visual.FogColor=colors[v]
end)

createToggle(VisualPage,"Third Person",Config.Visual.ThirdPerson,function(v) Config.Visual.ThirdPerson=v end)
createSlider(VisualPage,"Camera Distance",3,20,Config.Visual.ThirdPersonDistance,function(v) Config.Visual.ThirdPersonDistance=v end)
createSlider(VisualPage,"Camera Height",0,8,Config.Visual.ThirdPersonHeight,function(v) Config.Visual.ThirdPersonHeight=v end)

createToggle(VisualPage,"Spinbot",Config.Visual.Spinbot,function(v) Config.Visual.Spinbot=v end)
createSlider(VisualPage,"Spin Speed",1,30,Config.Visual.SpinbotSpeed,function(v) Config.Visual.SpinbotSpeed=v end)
createSlider(VisualPage,"Scale",1,50,math.floor(Config.Visual.Scale*10),function(v) Config.Visual.Scale=v/10 end)

createToggle(VisualPage,"Player Color",Config.Visual.PlayerColor,function(v) Config.Visual.PlayerColor=v end)
createDropdown(VisualPage,"Player Color Value",{"Red","Blue","Green","Purple","White","Black"},"Red",function(v)
    local colors = {Red=Color3.fromRGB(255,0,0),Blue=Color3.fromRGB(0,0,255),Green=Color3.fromRGB(0,255,0),Purple=Color3.fromRGB(175,0,255),White=Color3.fromRGB(255,255,255),Black=Color3.fromRGB(0,0,0)}
    Config.Visual.PlayerColorValue=colors[v]
end)

--//==================================================
--// MISC PAGE
--//==================================================

createSlider(MiscPage,"Speed",16,200,Config.Misc.Speed,function(v) Config.Misc.Speed=v end)
createToggle(MiscPage,"Invisible",Config.Misc.Invisible,function(v) Config.Misc.Invisible=v end)
createToggle(MiscPage,"Teleport",Config.Misc.Teleport,function(v)
    Config.Misc.Teleport=v
    if v and LocalPlayer.Character then
        local target = Players:FindFirstChild(Config.Misc.TeleportTarget)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
end)

--//==================================================
--// CONFIG PAGE
--//==================================================

createDropdown(SettingsPage,"Theme",{"Dark","Light","Purple Neon","Red Blood","Blue Cyber","Green Toxic","RGB"},Config.Theme,function(v)
    Config.Theme=v
    Theme=Themes[v]
    refreshTheme()
end)

createSlider(SettingsPage,"UI Scale",70,130,100,function(v)
    Config.WindowScale=v/100
    Scale.Scale=Config.WindowScale
end)

local SaveBtn = button(SettingsPage, "SAVE CONFIG")
SaveBtn.Size = UDim2.new(1,0,0,36)
SaveBtn.MouseButton1Click:Connect(function() saveConfig() end)

local LoadBtn = button(SettingsPage, "LOAD CONFIG")
LoadBtn.Size = UDim2.new(1,0,0,36)
LoadBtn.MouseButton1Click:Connect(function() loadConfig() end)

local UnloadBtn = button(SettingsPage, "UNLOAD")
UnloadBtn.Size = UDim2.new(1,0,0,36)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(180,50,55)
UnloadBtn.TextColor3 = Color3.fromRGB(255,255,255)
UnloadBtn.MouseButton1Click:Connect(function()
    if getgenv().LEMOS_LOADED then getgenv().LEMOS_LOADED = false end
    GUI:Destroy()
    print("[LEMOS] Unloaded.")
end)

--//==================================================
--// TAB SYSTEM
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

ESPTab.MouseButton1Click:Connect(function() activate("ESP") end)
AIMTab.MouseButton1Click:Connect(function() activate("AIM") end)
VisualTab.MouseButton1Click:Connect(function() activate("VISUAL") end)
MiscTab.MouseButton1Click:Connect(function() activate("MISC") end)
SettingsTab.MouseButton1Click:Connect(function() activate("CONFIG") end)

--//==================================================
--// DRAWING ESP
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
    box.Color = Config.ESP.Color
    box.Filled = false
    box.Visible = false

    local name = DrawingAPI.new("Text")
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.Color = Config.ESP.Color
    name.Visible = false

    local distance = DrawingAPI.new("Text")
    distance.Size = 12
    distance.Center = true
    distance.Outline = true
    distance.Color = Config.ESP.Color
    distance.Visible = false

    local hpBar = DrawingAPI.new("Square")
    hpBar.Thickness = 1
    hpBar.Filled = true
    hpBar.Color = Color3.fromRGB(90, 225, 105)
    hpBar.Visible = false

    local tracer = DrawingAPI.new("Line")
    tracer.Thickness = 1
    tracer.Color = Config.ESP.TracerColor
    tracer.Visible = false

    local cham = nil
    if Config.ESP.Chams then
        cham = Instance.new("Highlight")
        cham.Adornee = model
        cham.FillColor = Config.ESP.ChamColor
        cham.OutlineColor = Config.ESP.ChamColor
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

local function isVisible(part, character)
    if not Config.ESP.VisibilityCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, character}
    local result = Workspace:Raycast(origin, direction, params)
    return result == nil
end

local function updateDrawingESP()
    if not Config.ESP.Enabled then
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

        local visible = isVisible(root, model)

        if Config.ESP.Boxes then
            local topPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3 * Config.ESP.BoxScale, 0))
            local height = math.abs(topPos.Y - position.Y)
            local width = height * 0.65 * Config.ESP.BoxScale

            data.Box.Size = Vector2.new(width, height)
            data.Box.Position = Vector2.new(position.X - width/2, position.Y - height/2)
            data.Box.Color = visible and Config.ESP.Color or Color3.fromRGB(120,120,120)
            data.Box.Visible = true
        else
            data.Box.Visible = false
        end

        if Config.ESP.Names then
            data.Name.Text = model.Name
            data.Name.Position = Vector2.new(position.X, position.Y - 30)
            data.Name.Color = visible and Config.ESP.Color or Color3.fromRGB(120,120,120)
            data.Name.Visible = true
        else
            data.Name.Visible = false
        end

        if Config.ESP.Distance then
            local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local dist = localRoot and (localRoot.Position - root.Position).Magnitude or 0
            data.Distance.Text = math.floor(dist) .. " studs"
            data.Distance.Position = Vector2.new(position.X, position.Y + 20)
            data.Distance.Color = visible and Config.ESP.Color or Color3.fromRGB(120,120,120)
            data.Distance.Visible = true
        else
            data.Distance.Visible = false
        end

        if Config.ESP.Health then
            local hp = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
            data.HPBar.Size = Vector2.new(width + 4, 2)
            data.HPBar.Position = Vector2.new(position.X - width/2 - 2, position.Y - height/2 - 5)
            data.HPBar.Color = Color3.fromRGB(90, 225, 105)
            data.HPBar.Visible = true
        else
            data.HPBar.Visible = false
        end

        if Config.ESP.Tracers then
            local bottom = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            data.Tracer.From = bottom
            data.Tracer.To = Vector2.new(position.X, position.Y)
            data.Tracer.Color = visible and Config.ESP.TracerColor or Color3.fromRGB(120,120,120)
            data.Tracer.Visible = true
        else
            data.Tracer.Visible = false
        end

        if Config.ESP.Chams and data.Cham then
            data.Cham.Enabled = true
            data.Cham.FillColor = visible and Config.ESP.ChamColor or Color3.fromRGB(120,120,120)
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
    FOVCircle.Thickness = 1
    FOVCircle.Color = Theme.accent
    FOVCircle.Filled = false
    FOVCircle.Visible = false
    FOVCircle.Transparency = 0.7
end

--//==================================================
--// AIMBOT + SILENT AIM + TRIGGERBOT
--//==================================================

local SilentAimTarget = nil

local function getClosestTarget()
    local closest = nil
    local closestDist = Config.AIM.FOV
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for model, _ in pairs(ESPObjects) do
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
        if humanoid and root and humanoid.Health > 0 then
            local part = model:FindFirstChild(Config.AIM.Bone) or root
            if part and part:IsA("BasePart") then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local screenPos = Vector2.new(pos.X, pos.Y)
                    local dist = (screenPos - center).Magnitude
                    if dist < closestDist then
                        if not Config.AIM.VisibleCheck or isVisible(part, model) then
                            closestDist = dist
                            closest = part
                        end
                    end
                end
            end
        end
    end

    return closest
end

--// Silent Aim
if hookmetamethod then
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if not checkcaller() and SilentAimTarget and Config.AIM.SilentAim then
            if self == LocalPlayer:GetMouse() then
                if key == "Hit" then
                    return SilentAimTarget.CFrame
                elseif key == "Target" then
                    return SilentAimTarget
                elseif key == "UnitRay" then
                    return Ray.new(Camera.CFrame.Position, (SilentAimTarget.Position - Camera.CFrame.Position).Unit * 1000)
                end
            end
        end
        return oldIndex(self, key)
    end)
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
            FOVCircle.Radius = Config.AIM.FOV
            FOVCircle.Color = Theme.accent
            FOVCircle.Visible = Config.AIM.Enabled
        end
    end

    if Config.AIM.Enabled and camera then
        local target = getClosestTarget()
        SilentAimTarget = target

        if target and not Config.AIM.SilentAim then
            local desired = CFrame.lookAt(camera.CFrame.Position, target.Position)
            camera.CFrame = camera.CFrame:Lerp(desired, math.clamp(Config.AIM.Smoothness, 0.01, 1))
        end
    else
        SilentAimTarget = nil
    end

    if Config.AIM.Triggerbot then
        local target = getClosestTarget()
        if target then
            task.wait(Config.AIM.TriggerDelay)
            if mouse1click then pcall(mouse1click) end
        end
    end
end)

--//==================================================
--// VISUAL
--//==================================================

RunService.RenderStepped:Connect(function()
    if Config.Visual.Fog then
        Lighting.FogColor = Config.Visual.FogColor
        Lighting.FogStart = Config.Visual.FogStart
        Lighting.FogEnd = Config.Visual.FogEnd
    end

    if Config.Visual.PlayerColor then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Color = Config.Visual.PlayerColorValue
                    end
                end
            end
        end
    end
end)

--// Third Person
RunService:BindToRenderStep("LEMOS_ThirdPerson", Enum.RenderPriority.Camera.Value + 1, function()
    if not Config.Visual.ThirdPerson then return end
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    local cam = Workspace.CurrentCamera
    cam.CameraType = Enum.CameraType.Custom
    cam.CameraSubject = humanoid

    local look = cam.CFrame.LookVector
    local desired = root.Position - look * Config.Visual.ThirdPersonDistance + Vector3.new(0, Config.Visual.ThirdPersonHeight, 0)
    cam.CFrame = CFrame.lookAt(desired, root.Position + Vector3.new(0, 1.5, 0))
end)

--// Spinbot / Scale
RunService.Heartbeat:Connect(function(dt)
    if Config.Visual.Spinbot and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Config.Visual.SpinbotSpeed * dt * 60), 0)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Config.Visual.Scale ~= 1 and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.BodyDepthScale.Value = Config.Visual.Scale
            humanoid.BodyWidthScale.Value = Config.Visual.Scale
            humanoid.BodyHeightScale.Value = Config.Visual.Scale
            humanoid.HeadScale.Value = Config.Visual.Scale
        end
    end
end)

--//==================================================
--// MISC
--//==================================================

RunService.RenderStepped:Connect(function()
    if Config.Misc.Speed ~= 16 and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Config.Misc.Speed
        end
    end

    if Config.Misc.Invisible and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.LocalTransparencyModifier = 1
                part.Transparency = 1
            end
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
--// CONFIG SAVE/LOAD
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
                else
                    data[k][k2] = v2
                end
            end
        else
            data[k] = v
        end
    end
    safeWriteFile(path, HttpService:JSONEncode(data))
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
        end
    end
end

--//==================================================
--// WINDOW CONTROLS
--//==================================================

Close.MouseButton1Click:Connect(function() Main.Visible = false end)

local minimized = false
local savedSize = Main.Size

Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        savedSize = Main.Size
        Main.Size = UDim2.fromOffset(460,50)
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
    if input.KeyCode == Enum.KeyCode.RightShift then
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
--// THEME REFRESH
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
    if FOVCircle then FOVCircle.Color = Theme.accent end
    if activeTab then
        local old = activeTab
        activeTab = nil
        activate(old)
    end
end

--//==================================================
--// OPEN ANIMATION
--//==================================================

local targetSize = Main.Size
Main.Size = UDim2.fromOffset(400, 280)
TweenService:Create(Main, TweenInfo.new(.4, Enum.EasingStyle.Quart), {Size = targetSize}):Play()

--//==================================================
--// START
--//==================================================

loadConfig()
scanTargets()
activate("ESP")

print("[LEMOS] 0.1 loaded. Executor: " .. Executor)
