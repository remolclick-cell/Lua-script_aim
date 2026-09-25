--// LEMOS Delta Edition
--// For Delta Executor (Mobile/PC)
--// Players-only ESP + Camera/Mouse Aim

if getgenv().LEMOS_LOADED then
    warn("[LEMOS] Already loaded. Unload first or rejoin.")
    return
end
getgenv().LEMOS_LOADED = true

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

--==================================================
-- CONFIG
--==================================================

local Config = {
    WindowScale = 1,
    WindowTransparency = 0.06,
    Theme = "Dark",
    ESP = {
        Enabled = true,
        Boxes = true,
        Health = true,
        Names = true,
        Distance = true,
        TeamCheck = true,
        Color = Color3.fromRGB(255, 111, 25),
    },
    AIM = {
        Enabled = false,
        Mode = "Camera", -- "Camera" | "Mouse"
        FOV = 140,
        Smoothness = 0.15,
        Bone = "HumanoidRootPart",
        VisibleOnly = true,
        TeamCheck = true,
        Sensitivity = 0.5, -- for Mouse aim
    },
    ThirdPerson = {
        Enabled = false,
        Distance = 8,
        Height = 2,
    },
    Troll = {
        Spinbot = false,
        SpinSpeed = 8,
        Flip = false,
    },
}

--==================================================
-- THEMES
--==================================================

local Themes = {
    Dark = {
        accent = Color3.fromRGB(255,111,25),
        bg = Color3.fromRGB(12,12,13),
        panel = Color3.fromRGB(18,18,19),
        item = Color3.fromRGB(22,22,23),
        text = Color3.fromRGB(245,245,245),
        sub = Color3.fromRGB(135,135,135),
    },
    Light = {
        accent = Color3.fromRGB(255,105,30),
        bg = Color3.fromRGB(238,238,240),
        panel = Color3.fromRGB(250,250,252),
        item = Color3.fromRGB(232,232,235),
        text = Color3.fromRGB(25,25,28),
        sub = Color3.fromRGB(105,105,110),
    },
    ["Purple Neon"] = {
        accent = Color3.fromRGB(177,90,255),
        bg = Color3.fromRGB(12,9,17),
        panel = Color3.fromRGB(22,16,29),
        item = Color3.fromRGB(29,21,38),
        text = Color3.fromRGB(247,242,255),
        sub = Color3.fromRGB(155,135,175),
    },
    ["Red Blood"] = {
        accent = Color3.fromRGB(235,55,65),
        bg = Color3.fromRGB(16,9,10),
        panel = Color3.fromRGB(27,14,15),
        item = Color3.fromRGB(38,18,20),
        text = Color3.fromRGB(255,242,243),
        sub = Color3.fromRGB(165,125,128),
    },
    ["Blue Cyber"] = {
        accent = Color3.fromRGB(50,160,255),
        bg = Color3.fromRGB(8,13,19),
        panel = Color3.fromRGB(13,22,31),
        item = Color3.fromRGB(18,29,40),
        text = Color3.fromRGB(240,248,255),
        sub = Color3.fromRGB(125,155,180),
    },
    ["Green Toxic"] = {
        accent = Color3.fromRGB(90,225,105),
        bg = Color3.fromRGB(8,14,9),
        panel = Color3.fromRGB(14,24,16),
        item = Color3.fromRGB(19,32,21),
        text = Color3.fromRGB(240,255,241),
        sub = Color3.fromRGB(130,165,135),
    },
    RGB = {
        accent = Color3.fromRGB(255,80,200),
        bg = Color3.fromRGB(10,10,14),
        panel = Color3.fromRGB(18,18,24),
        item = Color3.fromRGB(25,25,34),
        text = Color3.fromRGB(245,245,250),
        sub = Color3.fromRGB(135,135,150),
    },
}

local Theme = Themes[Config.Theme]

--==================================================
-- HELPERS
--==================================================

local function safe(fn, ...)
    local ok, result = pcall(fn, ...)
    if not ok then warn("[LEMOS] " .. tostring(result)) end
    return ok, result
end

local function tween(obj, props, duration)
    return TweenService:Create(
        obj,
        TweenInfo.new(duration or .18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    )
end

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

--==================================================
-- CLEAN OLD UI
--==================================================

local guiParent = (gethui and gethui()) or PlayerGui
local old = guiParent:FindFirstChild("LEMOS_UI")
if old then old:Destroy() end

--==================================================
-- GUI
--==================================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "LEMOS_UI"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = guiParent

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(470, 330)
Main.Position = UDim2.new(.5, -235, .5, -165)
Main.BackgroundColor3 = Theme.bg
Main.BackgroundTransparency = Config.WindowTransparency
Main.BorderSizePixel = 0
Main.Parent = GUI
corner(Main, 16)
local MainStroke = stroke(Main, Theme.accent, .5, 1)

local Scale = Instance.new("UIScale")
Scale.Scale = Config.WindowScale
Scale.Parent = Main

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,54)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Logo = Instance.new("Frame")
Logo.Size = UDim2.fromOffset(34,34)
Logo.Position = UDim2.fromOffset(12,10)
Logo.BackgroundColor3 = Theme.accent
Logo.BorderSizePixel = 0
Logo.Parent = Header
corner(Logo,10)

local LogoText = label(Logo,"L",18,Theme.bg)
LogoText.Size = UDim2.fromScale(1,1)
LogoText.Font = Enum.Font.GothamBlack

local Title = label(Header,"LEMOS",17,Theme.text)
Title.Position = UDim2.fromOffset(57,7)
Title.Size = UDim2.fromOffset(180,22)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold

local Version = label(Header,"DELTA",9,Theme.accent)
Version.Position = UDim2.fromOffset(58,29)
Version.Size = UDim2.fromOffset(120,17)
Version.TextXAlignment = Enum.TextXAlignment.Left

local Minimize = button(Header,"—")
Minimize.Size = UDim2.fromOffset(32,32)
Minimize.Position = UDim2.new(1,-82,0,11)

local Close = button(Header,"×")
Close.Size = UDim2.fromOffset(32,32)
Close.Position = UDim2.new(1,-44,0,11)

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(10,60)
Sidebar.Size = UDim2.fromOffset(112,258)
Sidebar.BackgroundColor3 = Theme.panel
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
corner(Sidebar,12)
local SideStroke = stroke(Sidebar,Theme.text,.93,1)

local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0,9)
SidePadding.PaddingLeft = UDim.new(0,7)
SidePadding.PaddingRight = UDim.new(0,7)
SidePadding.Parent = Sidebar

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0,6)
SideLayout.Parent = Sidebar

local Tabs = {}
local Pages = {}

local function createTab(name, icon)
    local b = button(Sidebar, "")
    b.Name = name
    b.Size = UDim2.new(1,0,0,42)

    local i = label(b,icon,15,Theme.sub)
    i.Size = UDim2.fromOffset(25,42)
    i.Position = UDim2.fromOffset(3,0)

    local t = label(b,name,11,Theme.sub)
    t.Position = UDim2.fromOffset(30,0)
    t.Size = UDim2.new(1,-34,1,0)
    t.TextXAlignment = Enum.TextXAlignment.Left

    Tabs[name] = {Button=b,Icon=i,Text=t}
    return b
end

local ESPTab = createTab("ESP","◈")
local AIMTab = createTab("AIM","⌁")
local PlayerTab = createTab("PLAYER","●")
local TrollTab = createTab("TROLL","◆")
local SettingsTab = createTab("SETTINGS","⚙")

--==================================================
-- CONTENT / PAGES
--==================================================

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(132,60)
Content.Size = UDim2.new(1,-142,1,-72)
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
    p.Visible = false
    p.Parent = Content

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0,4)
    pad.PaddingRight = UDim.new(0,4)
    pad.PaddingBottom = UDim.new(0,8)
    pad.Parent = p

    Pages[name] = p
    return p
end

local ESPPage = createPage("ESP")
local AIMPage = createPage("AIM")
local PlayerPage = createPage("PLAYER")
local TrollPage = createPage("TROLL")
local SettingsPage = createPage("SETTINGS")

local function pageTitle(parent,titleText,subtitle)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1,0,0,52)
    box.BackgroundTransparency = 1
    box.Parent = parent

    local t = label(box,titleText,19,Theme.text)
    t.Position = UDim2.fromOffset(3,0)
    t.Size = UDim2.new(1,-6,0,27)
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Font = Enum.Font.GothamBold

    local s = label(box,subtitle,10,Theme.sub)
    s.Position = UDim2.fromOffset(4,27)
    s.Size = UDim2.new(1,-8,0,20)
    s.TextXAlignment = Enum.TextXAlignment.Left
end

pageTitle(ESPPage,"ESP","Player visualization")
pageTitle(AIMPage,"AIM","Camera / Mouse assist")
pageTitle(PlayerPage,"PLAYER","Camera controls")
pageTitle(TrollPage,"TROLL","Local effects")
pageTitle(SettingsPage,"SETTINGS","Interface config")

--==================================================
-- CONTROLS
--==================================================

local function createToggle(parent,textValue,initial,callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,0,0,40)
    holder.BackgroundColor3 = Theme.item
    holder.BorderSizePixel = 0
    holder.Parent = parent
    corner(holder,9)

    local txt = label(holder,textValue,12,Theme.text)
    txt.Position = UDim2.fromOffset(12,0)
    txt.Size = UDim2.new(1,-65,1,0)
    txt.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.fromOffset(40,22)
    toggle.Position = UDim2.new(1,-52,.5,-11)
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.BorderSizePixel = 0
    toggle.Parent = holder
    corner(toggle,20)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(16,16)
    knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    corner(knob,20)

    local state = initial

    local function update()
        toggle.BackgroundColor3 = state and Theme.accent or Color3.fromRGB(55,55,58)
        knob.Position = state and UDim2.new(1,-19,.5,-8) or UDim2.new(0,3,.5,-8)
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
    holder.Size = UDim2.new(1,0,0,58)
    holder.BackgroundColor3 = Theme.item
    holder.BorderSizePixel = 0
    holder.Parent = parent
    corner(holder,9)

    local txt = label(holder,textValue,11,Theme.text)
    txt.Position = UDim2.fromOffset(12,4)
    txt.Size = UDim2.new(1,-90,0,22)
    txt.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = label(holder,tostring(initial),10,Theme.accent)
    valueLabel.Position = UDim2.new(1,-70,0,4)
    valueLabel.Size = UDim2.fromOffset(58,22)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("Frame")
    bar.Position = UDim2.fromOffset(12,34)
    bar.Size = UDim2.new(1,-24,0,6)
    bar.BackgroundColor3 = Color3.fromRGB(55,55,58)
    bar.BorderSizePixel = 0
    bar.Parent = holder
    corner(bar,6)

    local fill = Instance.new("Frame")
    fill.BorderSizePixel = 0
    fill.BackgroundColor3 = Theme.accent
    fill.Parent = bar
    corner(fill,6)

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
    holder.Size = UDim2.new(1,0,0,42)
    holder.BackgroundColor3 = Theme.item
    holder.BorderSizePixel = 0
    holder.Parent = parent
    corner(holder,9)

    local txt = label(holder,textValue,11,Theme.text)
    txt.Position = UDim2.fromOffset(12,0)
    txt.Size = UDim2.new(.48,0,1,0)
    txt.TextXAlignment = Enum.TextXAlignment.Left

    local current = initial
    local b = button(holder,current)
    b.Size = UDim2.new(.47,0,0,30)
    b.Position = UDim2.new(.51,0,.5,-15)

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
        list.Size = UDim2.new(1,0,0,#options*31+8)
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
            item.Size = UDim2.new(1,-8,0,29)
            item.Position = UDim2.fromOffset(4,0)
            item.ZIndex = 31
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

--==================================================
-- ESP PAGE
--==================================================

createToggle(ESPPage,"ESP Enabled",Config.ESP.Enabled,function(v) Config.ESP.Enabled=v end)
createToggle(ESPPage,"Boxes",Config.ESP.Boxes,function(v) Config.ESP.Boxes=v end)
createToggle(ESPPage,"Health Bar",Config.ESP.Health,function(v) Config.ESP.Health=v end)
createToggle(ESPPage,"Names",Config.ESP.Names,function(v) Config.ESP.Names=v end)
createToggle(ESPPage,"Distance",Config.ESP.Distance,function(v) Config.ESP.Distance=v end)
createToggle(ESPPage,"Team Check",Config.ESP.TeamCheck,function(v) Config.ESP.TeamCheck=v end)

createDropdown(ESPPage,"ESP Color",{"Orange","White","Red","Blue","Green","Purple"},"Orange",function(v)
    local colors = {
        Orange=Color3.fromRGB(255,111,25),
        White=Color3.fromRGB(245,245,245),
        Red=Color3.fromRGB(255,70,75),
        Blue=Color3.fromRGB(65,160,255),
        Green=Color3.fromRGB(80,225,100),
        Purple=Color3.fromRGB(175,90,255),
    }
    Config.ESP.Color=colors[v]
end)

--==================================================
-- AIM PAGE
--==================================================

createToggle(AIMPage,"Aim Assist",Config.AIM.Enabled,function(v) Config.AIM.Enabled=v end)

createDropdown(AIMPage,"Aim Mode",{"Camera","Mouse"},"Camera",function(v)
    Config.AIM.Mode=v
end)

createToggle(AIMPage,"Visible targets only",Config.AIM.VisibleOnly,function(v) Config.AIM.VisibleOnly=v end)
createToggle(AIMPage,"Team Check",Config.AIM.TeamCheck,function(v) Config.AIM.TeamCheck=v end)

createSlider(AIMPage,"FOV",40,300,Config.AIM.FOV,function(v)
    Config.AIM.FOV=v
end)

createSlider(AIMPage,"Smoothness",1,100,math.floor(Config.AIM.Smoothness*100),function(v)
    Config.AIM.Smoothness=v/100
end)

createSlider(AIMPage,"Mouse Sens",1,100,math.floor(Config.AIM.Sensitivity*100),function(v)
    Config.AIM.Sensitivity=v/100
end)

createDropdown(AIMPage,"Target Bone",{"Head","HumanoidRootPart","UpperTorso"},"HumanoidRootPart",function(v)
    Config.AIM.Bone=v
end)

--==================================================
-- PLAYER PAGE
--==================================================

createToggle(PlayerPage,"Third Person",Config.ThirdPerson.Enabled,function(v)
    Config.ThirdPerson.Enabled=v
end)

createSlider(PlayerPage,"Camera Distance",3,20,Config.ThirdPerson.Distance,function(v)
    Config.ThirdPerson.Distance=v
end)

createSlider(PlayerPage,"Camera Height",0,8,Config.ThirdPerson.Height,function(v)
    Config.ThirdPerson.Height=v
end)

--==================================================
-- TROLL PAGE
--==================================================

createToggle(TrollPage,"Spinbot",Config.Troll.Spinbot,function(v)
    Config.Troll.Spinbot=v
end)

createSlider(TrollPage,"Spin Speed",1,30,Config.Troll.SpinSpeed,function(v)
    Config.Troll.SpinSpeed=v
end)

createToggle(TrollPage,"Local Flip",Config.Troll.Flip,function(v)
    Config.Troll.Flip=v
end)

--==================================================
-- SETTINGS
--==================================================

createDropdown(SettingsPage,"Theme",{
    "Dark","Light","Purple Neon","Red Blood","Blue Cyber","Green Toxic","RGB"
},Config.Theme,function(v)
    Config.Theme=v
    Theme=Themes[v]
end)

createSlider(SettingsPage,"UI Scale",70,130,100,function(v)
    Config.WindowScale=v/100
    Scale.Scale=Config.WindowScale
end)

local UnloadBtn = button(SettingsPage, "UNLOAD SCRIPT")
UnloadBtn.Size = UDim2.new(1,0,0,40)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(180,50,55)
UnloadBtn.TextColor3 = Color3.fromRGB(255,255,255)

UnloadBtn.MouseButton1Click:Connect(function()
    if getgenv().LEMOS_LOADED then
        getgenv().LEMOS_LOADED = false
    end
    GUI:Destroy()
    print("[LEMOS] Unloaded.")
end)

--==================================================
-- TAB SYSTEM
--==================================================

local function activate(name)
    for pageName,page in pairs(Pages) do
        page.Visible=(pageName==name)
    end

    for tabName,data in pairs(Tabs) do
        local active=(tabName==name)
        data.Button.BackgroundColor3=active and Theme.accent or Theme.item
        data.Icon.TextColor3=active and Theme.bg or Theme.sub
        data.Text.TextColor3=active and Theme.bg or Theme.sub
    end
end

ESPTab.MouseButton1Click:Connect(function() activate("ESP") end)
AIMTab.MouseButton1Click:Connect(function() activate("AIM") end)
PlayerTab.MouseButton1Click:Connect(function() activate("PLAYER") end)
TrollTab.MouseButton1Click:Connect(function() activate("TROLL") end)
SettingsTab.MouseButton1Click:Connect(function() activate("SETTINGS") end)

--==================================================
-- FOV CIRCLE
--==================================================

local FOVCircle = Instance.new("Frame")
FOVCircle.Name="FOV"
FOVCircle.AnchorPoint=Vector2.new(.5,.5)
FOVCircle.BackgroundTransparency=1
FOVCircle.Size=UDim2.fromOffset(Config.AIM.FOV*2,Config.AIM.FOV*2)
FOVCircle.Position=UDim2.fromScale(.5,.5)
FOVCircle.Visible=false
FOVCircle.Parent=GUI
corner(FOVCircle,999)
local FOVStroke=stroke(FOVCircle,Theme.accent,.25,1)

--==================================================
-- PLAYER ESP
--==================================================

local ESPObjects={}
local ESPFolder=Instance.new("Folder")
ESPFolder.Name="LEMOS_PlayerESP"
ESPFolder.Parent=GUI

local function isEnemy(player)
    if not Config.ESP.TeamCheck then return true end
    if not player.Team or not LocalPlayer.Team then return true end
    return player.Team ~= LocalPlayer.Team
end

local function removeESP(player)
    local data=ESPObjects[player]
    if not data then return end
    for _,obj in pairs(data) do
        if typeof(obj)=="Instance" then
            pcall(function() obj:Destroy() end)
        end
    end
    ESPObjects[player]=nil
end

local function createESP(player)
    if player==LocalPlayer then return end
    if not isEnemy(player) then return end
    if ESPObjects[player] then return end
    if not player.Character then return end

    local root=player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid=player.Character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    local highlight=Instance.new("Highlight")
    highlight.Name="LEMOS_Highlight"
    highlight.Adornee=player.Character
    highlight.FillColor=Config.ESP.Color
    highlight.OutlineColor=Config.ESP.Color
    highlight.FillTransparency=.82
    highlight.OutlineTransparency=0
    highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent=ESPFolder

    local billboard=Instance.new("BillboardGui")
    billboard.Name="LEMOS_Info"
    billboard.Adornee=root
    billboard.Size=UDim2.fromOffset(180,58)
    billboard.StudsOffset=Vector3.new(0,3.4,0)
    billboard.AlwaysOnTop=true
    billboard.Parent=ESPFolder

    local info=Instance.new("TextLabel")
    info.Size=UDim2.fromScale(1,1)
    info.BackgroundTransparency=1
    info.Font=Enum.Font.GothamBold
    info.TextSize=11
    info.TextColor3=Config.ESP.Color
    info.TextStrokeTransparency=.35
    info.TextYAlignment=Enum.TextYAlignment.Center
    info.Parent=billboard

    local hpBack=Instance.new("Frame")
    hpBack.Size=UDim2.new(1,-20,0,4)
    hpBack.Position=UDim2.new(0,10,1,-6)
    hpBack.BackgroundColor3=Color3.fromRGB(35,35,35)
    hpBack.BorderSizePixel=0
    hpBack.Parent=billboard
    corner(hpBack,4)

    local hpFill=Instance.new("Frame")
    hpFill.Size=UDim2.fromScale(1,1)
    hpFill.BackgroundColor3=Color3.fromRGB(90,225,105)
    hpFill.BorderSizePixel=0
    hpFill.Parent=hpBack
    corner(hpFill,4)

    ESPObjects[player]={
        Highlight=highlight,
        Billboard=billboard,
        Info=info,
        HPBack=hpBack,
        HPFill=hpFill,
        Humanoid=humanoid,
        Character=player.Character,
    }
end

-- Track character respawns
local function setupPlayer(player)
    if player==LocalPlayer then return end
    if player.Character then
        task.defer(function() createESP(player) end)
    end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if ESPObjects[player] then removeESP(player) end
        createESP(player)
    end)
end

for _,p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removeESP)

--==================================================
-- VISIBILITY CHECK
--==================================================

local function visibleFromCamera(part,character)
    if not Config.AIM.VisibleOnly then return true end

    local camera=Workspace.CurrentCamera
    if not camera or not part then return false end

    local origin=camera.CFrame.Position
    local direction=part.Position-origin

    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={
        LocalPlayer.Character,
        character,
    }

    local result=Workspace:Raycast(origin,direction,params)
    return result==nil
end

--==================================================
-- TARGET SEARCH
--==================================================

local function getAimPart(character)
    local preferred=Config.AIM.Bone
    local part=character:FindFirstChild(preferred)
    if part and part:IsA("BasePart") then return part end
    return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
end

local function isEnemyAim(player)
    if not Config.AIM.TeamCheck then return true end
    if not player.Team or not LocalPlayer.Team then return true end
    return player.Team ~= LocalPlayer.Team
end

local function getClosestTarget()
    local camera=Workspace.CurrentCamera
    if not camera then return nil end

    local center=Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
    local closest=nil
    local closestDistance=Config.AIM.FOV

    for _,player in ipairs(Players:GetPlayers()) do
        if player==LocalPlayer then continue end
        if not isEnemyAim(player) then continue end
        if not player.Character then continue end

        local humanoid=player.Character:FindFirstChildOfClass("Humanoid")
        local part=getAimPart(player.Character)

        if humanoid and humanoid.Health>0 and part then
            local screen,onscreen=camera:WorldToViewportPoint(part.Position)

            if onscreen then
                local point=Vector2.new(screen.X,screen.Y)
                local dist=(point-center).Magnitude

                if dist<closestDistance and visibleFromCamera(part,player.Character) then
                    closestDistance=dist
                    closest=part
                end
            end
        end
    end

    return closest
end

--==================================================
-- RENDER LOOP
--==================================================

RunService.RenderStepped:Connect(function(dt)
    local camera=Workspace.CurrentCamera

    if camera then
        local center=Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
        FOVCircle.Position=UDim2.fromOffset(center.X,center.Y)
        FOVCircle.Size=UDim2.fromOffset(Config.AIM.FOV*2,Config.AIM.FOV*2)
        FOVCircle.Visible=Config.AIM.Enabled
        FOVStroke.Color=Theme.accent
    end

    for player,data in pairs(ESPObjects) do
        local character=player.Character
        if not character or not character.Parent then
            removeESP(player)
            continue
        end

        -- Recalculate if character changed
        if data.Character ~= character then
            removeESP(player)
            createESP(player)
            continue
        end

        local humanoid=character:FindFirstChildOfClass("Humanoid")
        local root=character:FindFirstChild("HumanoidRootPart")

        if not humanoid or not root then
            removeESP(player)
            continue
        end

        if not isEnemy(player) then
            data.Highlight.Enabled=false
            data.Billboard.Enabled=false
            continue
        end

        data.Highlight.Enabled=Config.ESP.Enabled and Config.ESP.Boxes
        data.Highlight.FillColor=Config.ESP.Color
        data.Highlight.OutlineColor=Config.ESP.Color

        local localRoot=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local distance=localRoot and (localRoot.Position-root.Position).Magnitude or 0

        local lines={}
        if Config.ESP.Names then table.insert(lines,player.Name) end
        if Config.ESP.Health then table.insert(lines,"HP "..math.floor(humanoid.Health)) end
        if Config.ESP.Distance then table.insert(lines,math.floor(distance).." studs") end

        data.Info.Text=table.concat(lines,"  •  ")
        data.Info.TextColor3=Config.ESP.Color
        data.Billboard.Enabled=Config.ESP.Enabled and #lines>0

        local hp=math.clamp(humanoid.Health/math.max(humanoid.MaxHealth,1),0,1)
        data.HPBack.Visible=Config.ESP.Enabled and Config.ESP.Health
        data.HPFill.Visible=Config.ESP.Enabled and Config.ESP.Health
        data.HPFill.Size=UDim2.new(hp,0,1,0)
    end

    -- Aim Assist
    if Config.AIM.Enabled and camera then
        local target=getClosestTarget()

        if target then
            if Config.AIM.Mode == "Camera" then
                local desired=CFrame.lookAt(camera.CFrame.Position,target.Position)
                camera.CFrame=camera.CFrame:Lerp(desired,math.clamp(Config.AIM.Smoothness,0.01,1))
            elseif Config.AIM.Mode == "Mouse" and mousemoverel then
                local screen,onscreen=camera:WorldToViewportPoint(target.Position)
                if onscreen then
                    local center=Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
                    local dx=(screen.X-center.X)*Config.AIM.Sensitivity
                    local dy=(screen.Y-center.Y)*Config.AIM.Sensitivity
                    pcall(mousemoverel,dx,dy)
                end
            end
        end
    end
end)

--==================================================
-- THIRD PERSON
--==================================================

local previousCameraType=nil
local previousCameraSubject=nil

RunService:BindToRenderStep("LEMOS_ThirdPerson",Enum.RenderPriority.Camera.Value+1,function()
    local camera=Workspace.CurrentCamera
    local character=LocalPlayer.Character
    local root=character and character:FindFirstChild("HumanoidRootPart")
    local humanoid=character and character:FindFirstChildOfClass("Humanoid")

    if not camera or not root or not humanoid then return end

    if Config.ThirdPerson.Enabled then
        if not previousCameraType then
            previousCameraType=camera.CameraType
            previousCameraSubject=camera.CameraSubject
        end

        camera.CameraType=Enum.CameraType.Custom
        camera.CameraSubject=humanoid

        local look=camera.CFrame.LookVector
        local desired=root.Position-look*Config.ThirdPerson.Distance+Vector3.new(0,Config.ThirdPerson.Height,0)
        camera.CFrame=CFrame.lookAt(desired,root.Position+Vector3.new(0,1.5,0))
    elseif previousCameraType then
        camera.CameraType=previousCameraType
        camera.CameraSubject=previousCameraSubject or humanoid
        previousCameraType=nil
        previousCameraSubject=nil
    end
end)

--==================================================
-- SPIN / FLIP
--==================================================

RunService.Heartbeat:Connect(function(dt)
    local character=LocalPlayer.Character
    local root=character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if Config.Troll.Spinbot then
        root.CFrame=root.CFrame*CFrame.Angles(0,math.rad(Config.Troll.SpinSpeed*60)*dt,0)
    end

    if Config.Troll.Flip then
        root.CFrame=root.CFrame*CFrame.Angles(math.rad(180)*dt,0,0)
    end
end)

--==================================================
-- THEME REFRESH
--==================================================

local function refreshTheme()
    Theme=Themes[Config.Theme]

    Main.BackgroundColor3=Theme.bg
    MainStroke.Color=Theme.accent

    Logo.BackgroundColor3=Theme.accent
    LogoText.TextColor3=Theme.bg
    Title.TextColor3=Theme.text
    Version.TextColor3=Theme.accent

    SideStroke.Color=Theme.text

    for _,data in pairs(Tabs) do
        data.Icon.TextColor3=Theme.sub
        data.Text.TextColor3=Theme.sub
        data.Button.BackgroundColor3=Theme.item
    end

    FOVStroke.Color=Theme.accent
    activate("ESP")
end

local oldActivate=activate
activate=function(name)
    refreshTheme()
    oldActivate(name)
end

--==================================================
-- WINDOW CONTROLS
--==================================================

Close.MouseButton1Click:Connect(function()
    Main.Visible=false
end)

local minimized=false
local savedSize=Main.Size

Minimize.MouseButton1Click:Connect(function()
    minimized=not minimized
    if minimized then
        savedSize=Main.Size
        Main.Size=UDim2.fromOffset(470,54)
        Sidebar.Visible=false
        Content.Visible=false
    else
        Main.Size=savedSize
        Sidebar.Visible=true
        Content.Visible=true
    end
end)

UserInputService.InputBegan:Connect(function(input,processed)
    if processed then return end
    if input.KeyCode==Enum.KeyCode.RightShift then
        Main.Visible=not Main.Visible
    end
end)

--==================================================
-- DRAG / MOBILE
--==================================================

local dragging=false
local dragStart=nil
local startPosition=nil

local function beginDrag(input)
    dragging=true
    dragStart=input.Position
    startPosition=Main.Position

    input.Changed:Connect(function()
        if input.UserInputState==Enum.UserInputState.End then
            dragging=false
        end
    end)
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1
    or input.UserInputType==Enum.UserInputType.Touch then
        beginDrag(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType==Enum.UserInputType.MouseMovement
    or input.UserInputType==Enum.UserInputType.Touch then
        local delta=input.Position-dragStart
        Main.Position=UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset+delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset+delta.Y
        )
    end
end)

--==================================================
-- OPEN ANIMATION
--==================================================

local targetSize=Main.Size
Main.Size=UDim2.fromOffset(410,285)
tween(Main,{Size=targetSize},.42):Play()

--==================================================
-- START
--==================================================

activate("ESP")

print("[LEMOS] Delta edition loaded.")
print("[LEMOS] ESP targets: players only.")
print("[LEMOS] Aim modes: Camera / Mouse.")
