--// LEMOS 0.1 BETA
--// Mobile Training UI / Roblox Studio
--// Safe version for your own Roblox experience

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local Config = {
    WindowScale = 1,
    WindowTransparency = 0.06,

    ESP = {
        Enabled = true,
        Boxes = true,
        Health = true,
        Names = true,
        Distance = true,
        Color = Color3.fromRGB(255, 130, 35),
    },

    AIM = {
        Enabled = false,
        FOV = 140,
        Smoothness = 0.15,
    }
}

--==================================================
-- CLEAN OLD UI
--==================================================

local old = PlayerGui:FindFirstChild("LEMOS_UI")
if old then
    old:Destroy()
end

--==================================================
-- HELPERS
--==================================================

local function tween(obj, properties, duration)
    TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    ):Play()
end

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

local function gradient(parent, c1, c2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2)
    })
    g.Rotation = rotation or 0
    g.Parent = parent
    return g
end

local function label(parent, text, size, color)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or Color3.new(1,1,1)
    l.TextSize = size or 14
    l.Font = Enum.Font.GothamMedium
    l.Parent = parent
    return l
end

--==================================================
-- GUI
--==================================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "LEMOS_UI"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.Parent = PlayerGui

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(440, 290)
Main.Position = UDim2.new(0.5, -220, 0.5, -145)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 13)
Main.BackgroundTransparency = Config.WindowTransparency
Main.BorderSizePixel = 0
Main.Parent = GUI

corner(Main, 16)
stroke(Main, Color3.fromRGB(255, 111, 25), 0.55, 1)

gradient(
    Main,
    Color3.fromRGB(18, 18, 19),
    Color3.fromRGB(9, 9, 10),
    135
)

local Scale = Instance.new("UIScale")
Scale.Scale = Config.WindowScale
Scale.Parent = Main

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Logo = Instance.new("Frame")
Logo.Size = UDim2.fromOffset(34, 34)
Logo.Position = UDim2.fromOffset(12, 10)
Logo.BackgroundColor3 = Color3.fromRGB(255, 111, 25)
Logo.BorderSizePixel = 0
Logo.Parent = Header

corner(Logo, 10)

local LogoText = label(
    Logo,
    "L",
    18,
    Color3.fromRGB(10, 10, 10)
)

LogoText.Size = UDim2.fromScale(1,1)
LogoText.Font = Enum.Font.GothamBlack

local Title = label(
    Header,
    "LEMOS",
    17,
    Color3.fromRGB(245,245,245)
)

Title.Position = UDim2.fromOffset(57, 8)
Title.Size = UDim2.fromOffset(150, 22)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold

local Version = label(
    Header,
    "0.1 BETA",
    10,
    Color3.fromRGB(255, 128, 40)
)

Version.Position = UDim2.fromOffset(58, 29)
Version.Size = UDim2.fromOffset(100, 17)
Version.TextXAlignment = Enum.TextXAlignment.Left

--==================================================
-- CLOSE
--==================================================

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(32, 32)
Close.Position = UDim2.new(1, -44, 0, 11)
Close.BackgroundColor3 = Color3.fromRGB(25,25,26)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(190,190,190)
Close.TextSize = 22
Close.Font = Enum.Font.GothamMedium
Close.BorderSizePixel = 0
Close.Parent = Header

corner(Close, 9)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(10, 60)
Sidebar.Size = UDim2.fromOffset(105, 218)
Sidebar.BackgroundColor3 = Color3.fromRGB(16,16,17)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

corner(Sidebar, 12)
stroke(Sidebar, Color3.fromRGB(255,255,255), 0.93, 1)

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 6)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.VerticalAlignment = Enum.VerticalAlignment.Top
SideLayout.Parent = Sidebar

local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0, 10)
SidePadding.PaddingLeft = UDim.new(0, 7)
SidePadding.PaddingRight = UDim.new(0, 7)
SidePadding.Parent = Sidebar

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(125, 60)
Content.Size = UDim2.new(1, -135, 1, -72)
Content.BackgroundTransparency = 1
Content.Parent = Main

--==================================================
-- TABS
--==================================================

local Tabs = {}

local function createTab(name, icon)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, 0, 0, 42)
    Button.BackgroundColor3 = Color3.fromRGB(20,20,21)
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.BorderSizePixel = 0
    Button.Parent = Sidebar

    corner(Button, 9)

    local Icon = label(
        Button,
        icon,
        15,
        Color3.fromRGB(150,150,150)
    )

    Icon.Size = UDim2.fromOffset(25, 42)
    Icon.Position = UDim2.fromOffset(4, 0)

    local Text = label(
        Button,
        name,
        12,
        Color3.fromRGB(155,155,155)
    )

    Text.Position = UDim2.fromOffset(31, 0)
    Text.Size = UDim2.new(1, -34, 1, 0)
    Text.TextXAlignment = Enum.TextXAlignment.Left

    Tabs[name] = {
        Button = Button,
        Icon = Icon,
        Text = Text
    }

    return Button
end

local ESPTab = createTab("ESP", "◈")
local AIMTab = createTab("AIM", "⌁")
local SettingsTab = createTab("SETTINGS", "⚙")

--==================================================
-- PAGE SYSTEM
--==================================================

local Pages = {}

local function createPage(name)
    local Page = Instance.new("Frame")
    Page.Name = name
    Page.Size = UDim2.fromScale(1,1)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = Content

    Pages[name] = Page
    return Page
end

local ESPPage = createPage("ESP")
local AIMPage = createPage("AIM")
local SettingsPage = createPage("SETTINGS")

local function activate(name)
    for pageName, page in pairs(Pages) do
        page.Visible = pageName == name
    end

    for tabName, data in pairs(Tabs) do
        if tabName == name then
            data.Button.BackgroundColor3 = Color3.fromRGB(255,111,25)
            data.Icon.TextColor3 = Color3.fromRGB(10,10,10)
            data.Text.TextColor3 = Color3.fromRGB(10,10,10)
        else
            data.Button.BackgroundColor3 = Color3.fromRGB(20,20,21)
            data.Icon.TextColor3 = Color3.fromRGB(150,150,150)
            data.Text.TextColor3 = Color3.fromRGB(155,155,155)
        end
    end
end

ESPTab.MouseButton1Click:Connect(function()
    activate("ESP")
end)

AIMTab.MouseButton1Click:Connect(function()
    activate("AIM")
end)

SettingsTab.MouseButton1Click:Connect(function()
    activate("SETTINGS")
end)

--==================================================
-- PAGE TITLE
--==================================================

local function pageTitle(parent, titleText, subtitle)
    local T = label(parent, titleText, 19, Color3.fromRGB(245,245,245))
    T.Position = UDim2.fromOffset(4, 0)
    T.Size = UDim2.new(1, -8, 0, 28)
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.Font = Enum.Font.GothamBold

    local S = label(parent, subtitle, 10, Color3.fromRGB(115,115,115))
    S.Position = UDim2.fromOffset(5, 27)
    S.Size = UDim2.new(1, -10, 0, 20)
    S.TextXAlignment = Enum.TextXAlignment.Left
end

pageTitle(ESPPage, "ESP", "Training target visualization")

pageTitle(AIMPage, "AIM", "Training camera assistance")

pageTitle(SettingsPage, "SETTINGS", "Interface configuration")

--==================================================
-- TOGGLE
--==================================================

local function createToggle(parent, textValue, y, initial, callback)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, -8, 0, 38)
    Holder.Position = UDim2.fromOffset(4, y)
    Holder.BackgroundColor3 = Color3.fromRGB(18,18,19)
    Holder.BorderSizePixel = 0
    Holder.Parent = parent

    corner(Holder, 9)

    local Text = label(
        Holder,
        textValue,
        12,
        Color3.fromRGB(210,210,210)
    )

    Text.Position = UDim2.fromOffset(12, 0)
    Text.Size = UDim2.new(1, -65, 1, 0)
    Text.TextXAlignment = Enum.TextXAlignment.Left

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.fromOffset(38, 21)
    Toggle.Position = UDim2.new(1, -50, 0.5, -10)
    Toggle.Text = ""
    Toggle.BorderSizePixel = 0
    Toggle.AutoButtonColor = false
    Toggle.Parent = Holder

    corner(Toggle, 20)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(15,15)
    Knob.BorderSizePixel = 0
    Knob.BackgroundColor3 = Color3.fromRGB(230,230,230)
    Knob.Parent = Toggle

    corner(Knob, 20)

    local state = initial

    local function update()
        if state then
            Toggle.BackgroundColor3 = Color3.fromRGB(255,111,25)
            Knob.Position = UDim2.new(1,-18,0.5,-7)
        else
            Toggle.BackgroundColor3 = Color3.fromRGB(45,45,46)
            Knob.Position = UDim2.new(0,3,0.5,-7)
        end

        if callback then
            callback(state)
        end
    end

    Toggle.MouseButton1Click:Connect(function()
        state = not state
        update()
    end)

    update()

    return Holder
end

--==================================================
-- ESP
--==================================================

createToggle(ESPPage, "ESP Enabled", 55, Config.ESP.Enabled, function(v)
    Config.ESP.Enabled = v
end)

createToggle(ESPPage, "Boxes", 99, Config.ESP.Boxes, function(v)
    Config.ESP.Boxes = v
end)

createToggle(ESPPage, "Health Bar", 143, Config.ESP.Health, function(v)
    Config.ESP.Health = v
end)

createToggle(ESPPage, "Names / Distance", 187, Config.ESP.Names, function(v)
    Config.ESP.Names = v
    Config.ESP.Distance = v
end)

--==================================================
-- AIM
--==================================================

createToggle(AIMPage, "Training Aim Assist", 55, Config.AIM.Enabled, function(v)
    Config.AIM.Enabled = v
end)

-- FOV DISPLAY

local FOVText = label(
    AIMPage,
    "FOV    140",
    12,
    Color3.fromRGB(205,205,205)
)

FOVText.Position = UDim2.fromOffset(5, 105)
FOVText.Size = UDim2.new(1,-10,0,30)
FOVText.TextXAlignment = Enum.TextXAlignment.Left

local FOVBar = Instance.new("Frame")
FOVBar.Position = UDim2.fromOffset(5, 137)
FOVBar.Size = UDim2.new(1,-10,0,5)
FOVBar.BackgroundColor3 = Color3.fromRGB(40,40,41)
FOVBar.BorderSizePixel = 0
FOVBar.Parent = AIMPage

corner(FOVBar, 5)

local FOVFill = Instance.new("Frame")
FOVFill.Size = UDim2.new(0.45,0,1,0)
FOVFill.BackgroundColor3 = Color3.fromRGB(255,111,25)
FOVFill.BorderSizePixel = 0
FOVFill.Parent = FOVBar

corner(FOVFill,5)

--==================================================
-- SETTINGS
--==================================================

local ScaleText = label(
    SettingsPage,
    "UI SCALE",
    11,
    Color3.fromRGB(130,130,130)
)

ScaleText.Position = UDim2.fromOffset(5, 55)
ScaleText.Size = UDim2.new(1,-10,0,20)
ScaleText.TextXAlignment = Enum.TextXAlignment.Left

local ScaleMinus = Instance.new("TextButton")
ScaleMinus.Size = UDim2.fromOffset(35,32)
ScaleMinus.Position = UDim2.fromOffset(5,80)
ScaleMinus.Text = "−"
ScaleMinus.TextSize = 18
ScaleMinus.TextColor3 = Color3.fromRGB(220,220,220)
ScaleMinus.BackgroundColor3 = Color3.fromRGB(24,24,25)
ScaleMinus.BorderSizePixel = 0
ScaleMinus.Parent = SettingsPage

corner(ScaleMinus,8)

local ScaleValue = label(
    SettingsPage,
    "100%",
    12,
    Color3.fromRGB(255,130,40)
)

ScaleValue.Position = UDim2.fromOffset(48,80)
ScaleValue.Size = UDim2.fromOffset(60,32)
ScaleValue.TextXAlignment = Enum.TextXAlignment.Center

local ScalePlus = Instance.new("TextButton")
ScalePlus.Size = UDim2.fromOffset(35,32)
ScalePlus.Position = UDim2.fromOffset(113,80)
ScalePlus.Text = "+"
ScalePlus.TextSize = 18
ScalePlus.TextColor3 = Color3.fromRGB(220,220,220)
ScalePlus.BackgroundColor3 = Color3.fromRGB(24,24,25)
ScalePlus.BorderSizePixel = 0
ScalePlus.Parent = SettingsPage

corner(ScalePlus,8)

local function updateScale()
    Scale.Scale = Config.WindowScale
    ScaleValue.Text = tostring(math.floor(Config.WindowScale * 100)) .. "%"
end

ScaleMinus.MouseButton1Click:Connect(function()
    Config.WindowScale = math.clamp(
        Config.WindowScale - 0.05,
        0.7,
        1.3
    )
    updateScale()
end)

ScalePlus.MouseButton1Click:Connect(function()
    Config.WindowScale = math.clamp(
        Config.WindowScale + 0.05,
        0.7,
        1.3
    )
    updateScale()
end)

--==================================================
-- MOBILE DRAG
--==================================================

local dragging = false
local dragStart
local startPosition

local function beginDrag(input)
    dragging = true
    dragStart = input.Position
    startPosition = Main.Position

    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        beginDrag(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

--==================================================
-- TRAINING ESP
--==================================================

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "LEMOS_TrainingESP"
ESPFolder.Parent = GUI

local ESPObjects = {}

local function removeESP(model)
    local data = ESPObjects[model]

    if data then
        for _, object in pairs(data) do
            if typeof(object) == "Instance" then
                object:Destroy()
            end
        end

        ESPObjects[model] = nil
    end
end

local function createESP(model)
    if not model:IsA("Model") then
        return
    end

    if model == LocalPlayer.Character then
        return
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart

    if not humanoid or not root then
        return
    end

    if ESPObjects[model] then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "LEMOS_Highlight"
    highlight.Adornee = model
    highlight.FillColor = Config.ESP.Color
    highlight.OutlineColor = Color3.fromRGB(255,180,90)
    highlight.FillTransparency = 0.82
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = ESPFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "LEMOS_Info"
    billboard.Adornee = root
    billboard.Size = UDim2.fromOffset(160,45)
    billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.AlwaysOnTop = true
    billboard.Parent = ESPFolder

    local info = Instance.new("TextLabel")
    info.Size = UDim2.fromScale(1,1)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.GothamBold
    info.TextSize = 11
    info.TextColor3 = Config.ESP.Color
    info.TextStrokeTransparency = 0.35
    info.Parent = billboard

    ESPObjects[model] = {
        Highlight = highlight,
        Billboard = billboard,
        Info = info
    }
end

local function scanTrainingTargets()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            createESP(obj)
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not Config.ESP.Enabled then
        for model, data in pairs(ESPObjects) do
            if data.Highlight then
                data.Highlight.Enabled = false
            end
            if data.Billboard then
                data.Billboard.Enabled = false
            end
        end

        return
    end

    for model, data in pairs(ESPObjects) do
        if not model.Parent then
            removeESP(model)
            continue
        end

        local humanoid = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart")
            or model.PrimaryPart

        if not humanoid or not root then
            removeESP(model)
            continue
        end

        data.Highlight.Enabled = Config.ESP.Boxes
        data.Highlight.FillColor = Config.ESP.Color

        data.Billboard.Enabled =
            Config.ESP.Names
            or Config.ESP.Distance
            or Config.ESP.Health

        local distance = 0

        if LocalPlayer.Character then
            local localRoot =
                LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if localRoot then
                distance = (localRoot.Position - root.Position).Magnitude
            end
        end

        local text = ""

        if Config.ESP.Names then
            text = model.Name
        end

        if Config.ESP.Health then
            text = text .. "  HP " .. math.floor(humanoid.Health)
        end

        if Config.ESP.Distance then
            text = text .. "\n" .. math.floor(distance) .. " studs"
        end

        data.Info.Text = text
        data.Info.TextColor3 = Config.ESP.Color
    end
end)

Workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.15)

    if obj:IsA("Model") then
        createESP(obj)
    end
end)

Workspace.DescendantRemoving:Connect(function(obj)
    if ESPObjects[obj] then
        removeESP(obj)
    end
end)

--==================================================
-- TRAINING AIM
--==================================================

local function getClosestTrainingTarget()
    local character = LocalPlayer.Character

    if not character then
        return nil
    end

    local camera = Workspace.CurrentCamera

    if not camera then
        return nil
    end

    local center = camera.ViewportSize / 2
    local closest
    local closestDistance = Config.AIM.FOV

    for model in pairs(ESPObjects) do
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart")
            or model.PrimaryPart

        if humanoid and root and humanoid.Health > 0 then
            local position, visible =
                camera:WorldToViewportPoint(root.Position)

            if visible then
                local screenPosition =
                    Vector2.new(position.X, position.Y)

                local distance =
                    (screenPosition - center).Magnitude

                if distance < closestDistance then
                    closestDistance = distance
                    closest = root
                end
            end
        end
    end

    return closest
end

RunService.RenderStepped:Connect(function()
    if not Config.AIM.Enabled then
        return
    end

    local camera = Workspace.CurrentCamera

    if not camera then
        return
    end

    local target = getClosestTrainingTarget()

    if target then
        local targetCFrame =
            CFrame.lookAt(
                camera.CFrame.Position,
                target.Position
            )

        camera.CFrame =
            camera.CFrame:Lerp(
                targetCFrame,
                Config.AIM.Smoothness
            )
    end
end)

--==================================================
-- FOV SLIDER
--==================================================

FOVBar.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
    and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local function update(inputPosition)
        local x =
            math.clamp(
                inputPosition.X - FOVBar.AbsolutePosition.X,
                0,
                FOVBar.AbsoluteSize.X
            )

        local percent =
            x / FOVBar.AbsoluteSize.X

        FOVFill.Size =
            UDim2.new(percent,0,1,0)

        Config.AIM.FOV =
            math.floor(40 + percent * 260)

        FOVText.Text =
            "FOV    " .. Config.AIM.FOV
    end

    update(input.Position)

    local connection

    connection = UserInputService.InputChanged:Connect(function(changed)
        if changed.UserInputType == Enum.UserInputType.MouseMovement
        or changed.UserInputType == Enum.UserInputType.Touch then

            update(changed.Position)
        end
    end)

    local ended

    ended = UserInputService.InputEnded:Connect(function(changed)
        if changed.UserInputType == Enum.UserInputType.MouseButton1
        or changed.UserInputType == Enum.UserInputType.Touch then

            connection:Disconnect()
            ended:Disconnect()
        end
    end)
end)

--==================================================
-- OPEN ANIMATION
--==================================================

Main.Size = UDim2.fromOffset(400,260)

TweenService:Create(
    Main,
    TweenInfo.new(
        0.45,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),
    {
        Size = UDim2.fromOffset(440,290)
    }
):Play()

--==================================================
-- START
--==================================================

activate("ESP")
scanTrainingTargets()

print("LEMOS 0.1 BETA loaded")
