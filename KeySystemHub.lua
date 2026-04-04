-- ==================== HYPER HUB v2.0 - WIND UI STYLE ====================

local Config = {
    ApiUrl = "https://hyperhub-bot.onrender.com/verify",
    ApiToken = "lolilol980",
    Colors = {
        Bg = Color3.fromRGB(18, 18, 24),
        BgLight = Color3.fromRGB(24, 24, 32),
        BgCard = Color3.fromRGB(30, 30, 42),
        Sidebar = Color3.fromRGB(20, 20, 28),
        Accent = Color3.fromRGB(99, 102, 241),
        AccentHover = Color3.fromRGB(120, 124, 255),
        Success = Color3.fromRGB(34, 197, 94),
        Error = Color3.fromRGB(239, 68, 68),
        Warning = Color3.fromRGB(234, 179, 8),
        Text = Color3.fromRGB(248, 248, 255),
        TextDim = Color3.fromRGB(120, 120, 140),
        Border = Color3.fromRGB(45, 45, 60),
        Toggle = Color3.fromRGB(45, 45, 65),
    },
    ToggleKey = Enum.KeyCode.RightControl,
}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HTTP = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local WIN_W = IsMobile and 360 or 580
local WIN_H = IsMobile and 500 or 420
local SIDE_W = IsMobile and 110 or 150

local IsLicensed = false
local LicenseData = nil
local CurrentTab = nil

-- ======== UTILS ========
local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or UDim.new(0,10)
    c.Parent = p
    return c
end

local function Stroke(p, col, th)
    local s = Instance.new("UIStroke")
    s.Color = col or Config.Colors.Border
    s.Thickness = th or 1
    s.Parent = p
    return s
end

local function Tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function Label(parent, text, size, color, font, pos, sz, align)
    local l = Instance.new("TextLabel")
    l.Text = text
    l.TextSize = size or 13
    l.TextColor3 = color or Config.Colors.Text
    l.Font = font or Enum.Font.Gotham
    l.BackgroundTransparency = 1
    l.Position = pos or UDim2.new(0,0,0,0)
    l.Size = sz or UDim2.new(1,0,0,20)
    l.TextXAlignment = align or Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

-- ======== GUI PRINCIPAL ========
local OldGui = PlayerGui:FindFirstChild("HyperHub")
if OldGui then OldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HyperHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- ======== ECRAN LICENCE ========
local LicFrame = Instance.new("Frame")
LicFrame.Size = UDim2.new(0, IsMobile and 320 or 380, 0, IsMobile and 280 or 300)
LicFrame.Position = UDim2.new(0.5, IsMobile and -160 or -190, 0.5, IsMobile and -140 or -150)
LicFrame.BackgroundColor3 = Config.Colors.Bg
LicFrame.BorderSizePixel = 0
LicFrame.Parent = ScreenGui
Corner(LicFrame, UDim.new(0,16))
Stroke(LicFrame, Config.Colors.Accent, 2)

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(0.6, 0, 0, 3)
AccentLine.Position = UDim2.new(0.2, 0, 0, 0)
AccentLine.BackgroundColor3 = Config.Colors.Accent
AccentLine.BorderSizePixel = 0
AccentLine.Parent = LicFrame
Corner(AccentLine, UDim.new(0,3))

Label(LicFrame, "HYPER HUB", IsMobile and 11 or 12, Config.Colors.Accent, Enum.Font.GothamBold,
    UDim2.new(0,0,0,18), UDim2.new(1,0,0,18), Enum.TextXAlignment.Center)

Label(LicFrame, "Activation de Licence", IsMobile and 17 or 20, Config.Colors.Text, Enum.Font.GothamBold,
    UDim2.new(0,0,0,38), UDim2.new(1,0,0,28), Enum.TextXAlignment.Center)

Label(LicFrame, "Entrez votre cle de licence", IsMobile and 11 or 12, Config.Colors.TextDim, Enum.Font.Gotham,
    UDim2.new(0,0,0,70), UDim2.new(1,0,0,18), Enum.TextXAlignment.Center)

local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -32, 0, IsMobile and 38 or 42)
InputBox.Position = UDim2.new(0, 16, 0, IsMobile and 96 or 100)
InputBox.BackgroundColor3 = Config.Colors.BgCard
InputBox.Text = ""
InputBox.PlaceholderText = "Ex: A1B2C3D4E5F6G7H8"
InputBox.TextColor3 = Config.Colors.Text
InputBox.PlaceholderColor3 = Config.Colors.TextDim
InputBox.Font = Enum.Font.GothamBold
InputBox.TextSize = IsMobile and 13 or 14
InputBox.ClearTextOnFocus = false
InputBox.BorderSizePixel = 0
InputBox.Parent = LicFrame
Corner(InputBox, UDim.new(0,10))
Stroke(InputBox, Config.Colors.Border, 1)

InputBox.Focused:Connect(function()
    Tween(InputBox, {}, 0.2)
    local s = InputBox:FindFirstChildOfClass("UIStroke")
    if s then Tween(s, {Color = Config.Colors.Accent}, 0.2) end
end)
InputBox.FocusLost:Connect(function()
    local s = InputBox:FindFirstChildOfClass("UIStroke")
    if s then Tween(s, {Color = Config.Colors.Border}, 0.2) end
end)

local ActivateBtn = Instance.new("TextButton")
ActivateBtn.Size = UDim2.new(1, -32, 0, IsMobile and 40 or 44)
ActivateBtn.Position = UDim2.new(0, 16, 0, IsMobile and 148 or 158)
ActivateBtn.BackgroundColor3 = Config.Colors.Accent
ActivateBtn.Text = "Activer la Licence"
ActivateBtn.TextColor3 = Color3.fromRGB(255,255,255)
ActivateBtn.Font = Enum.Font.GothamBold
ActivateBtn.TextSize = IsMobile and 13 or 14
ActivateBtn.BorderSizePixel = 0
ActivateBtn.Parent = LicFrame
Corner(ActivateBtn, UDim.new(0,10))

ActivateBtn.MouseEnter:Connect(function()
    Tween(ActivateBtn, {BackgroundColor3 = Config.Colors.AccentHover})
end)
ActivateBtn.MouseLeave:Connect(function()
    Tween(ActivateBtn, {BackgroundColor3 = Config.Colors.Accent})
end)

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(1, -20, 0, 30)
StatusLbl.Position = UDim2.new(0, 10, 0, IsMobile and 198 or 212)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = ""
StatusLbl.TextColor3 = Config.Colors.TextDim
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextSize = IsMobile and 11 or 12
StatusLbl.TextWrapped = true
StatusLbl.TextXAlignment = Enum.TextXAlignment.Center
StatusLbl.Parent = LicFrame

-- ======== FENETRE PRINCIPALE ========
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, WIN_W, 0, WIN_H)
MainFrame.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
MainFrame.BackgroundColor3 = Config.Colors.Bg
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Corner(MainFrame, UDim.new(0,14))
Stroke(MainFrame, Config.Colors.Border, 1)

local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0,-20,0,-20)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0,0,0)
Shadow.ImageTransparency = 0.5
Shadow.ZIndex = 0
Shadow.Parent = MainFrame

-- ---- TITLEBAR ----
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0, IsMobile and 42 or 46)
TitleBar.BackgroundColor3 = Config.Colors.Sidebar
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Corner(TitleBar, UDim.new(0,14))

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1,0,0.5,0)
TitleFix.Position = UDim2.new(0,0,0.5,0)
TitleFix.BackgroundColor3 = Config.Colors.Sidebar
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Dot = Instance.new("Frame")
Dot.Size = UDim2.new(0,8,0,8)
Dot.Position = UDim2.new(0,14,0.5,-4)
Dot.BackgroundColor3 = Config.Colors.Accent
Dot.BorderSizePixel = 0
Dot.Parent = TitleBar
Corner(Dot, UDim.new(1,0))

Label(TitleBar, "Hyper Hub", IsMobile and 13 or 15, Config.Colors.Text, Enum.Font.GothamBold,
    UDim2.new(0,28,0,0), UDim2.new(0,120,1,0), Enum.TextXAlignment.Left)

local Badge = Instance.new("Frame")
Badge.Size = UDim2.new(0, IsMobile and 80 or 95, 0, IsMobile and 20 or 24)
Badge.Position = UDim2.new(0, IsMobile and 140 or 160, 0.5, IsMobile and -10 or -12)
Badge.BackgroundColor3 = Color3.fromRGB(20,50,30)
Badge.BorderSizePixel = 0
Badge.Parent = TitleBar
Corner(Badge, UDim.new(0,6))

local BadgeLbl = Instance.new("TextLabel")
BadgeLbl.Size = UDim2.new(1,0,1,0)
BadgeLbl.BackgroundTransparency = 1
BadgeLbl.Text = "PERMANENT"
BadgeLbl.TextColor3 = Config.Colors.Success
BadgeLbl.Font = Enum.Font.GothamBold
BadgeLbl.TextSize = IsMobile and 9 or 10
BadgeLbl.Parent = Badge

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, IsMobile and 28 or 32, 0, IsMobile and 28 or 32)
CloseBtn.Position = UDim2.new(1, IsMobile and -38 or -44, 0.5, IsMobile and -14 or -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(239,68,68)
CloseBtn.Text = "x"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = IsMobile and 12 or 14
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Corner(CloseBtn, UDim.new(0,8))

CloseBtn.MouseButton1Click:Connect(function()
    Tween(MainFrame, {Size = UDim2.new(0,WIN_W,0,0), Position = UDim2.new(0.5,-WIN_W/2,0.5,0)})
    task.wait(0.2)
    MainFrame.Visible = false
    MainFrame.Size = UDim2.new(0,WIN_W,0,WIN_H)
    MainFrame.Position = UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)
end)

local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = inp.Position
        startPos = MainFrame.Position
    end
end)
UIS.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ---- SIDEBAR ----
local SidebarFrame = Instance.new("Frame")
SidebarFrame.Size = UDim2.new(0, SIDE_W, 1, -(IsMobile and 42 or 46))
SidebarFrame.Position = UDim2.new(0, 0, 0, IsMobile and 42 or 46)
SidebarFrame.BackgroundColor3 = Config.Colors.Sidebar
SidebarFrame.BorderSizePixel = 0
SidebarFrame.Parent = MainFrame

local SidebarBottomFix = Instance.new("Frame")
SidebarBottomFix.Size = UDim2.new(1,0,0,14)
SidebarBottomFix.Position = UDim2.new(0,0,1,-14)
SidebarBottomFix.BackgroundColor3 = Config.Colors.Sidebar
SidebarBottomFix.BorderSizePixel = 0
SidebarBottomFix.Parent = SidebarFrame

local SideLayout = Instance.new("UIListLayout")
SideLayout.FillDirection = Enum.FillDirection.Vertical
SideLayout.Padding = UDim.new(0,4)
SideLayout.Parent = SidebarFrame

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0,10)
SidePad.PaddingLeft = UDim.new(0,8)
SidePad.PaddingRight = UDim.new(0,8)
SidePad.PaddingBottom = UDim.new(0,10)
SidePad.Parent = SidebarFrame

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(0,1,1,-(IsMobile and 42 or 46))
Separator.Position = UDim2.new(0,SIDE_W,0,IsMobile and 42 or 46)
Separator.BackgroundColor3 = Config.Colors.Border
Separator.BorderSizePixel = 0
Separator.Parent = MainFrame

-- ---- CONTENT ----
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1,-SIDE_W-1,1,-(IsMobile and 42 or 46))
ContentFrame.Position = UDim2.new(0,SIDE_W+1,0,IsMobile and 42 or 46)
ContentFrame.BackgroundColor3 = Config.Colors.BgLight
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = Config.Colors.Accent
ContentFrame.CanvasSize = UDim2.new(0,0,0,0)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.Parent = MainFrame
Corner(ContentFrame, UDim.new(0,14))

local ContentPad = Instance.new("UIPadding")
ContentPad.PaddingAll = UDim.new(0,14)
ContentPad.Parent = ContentFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.FillDirection = Enum.FillDirection.Vertical
ContentLayout.Padding = UDim.new(0,10)
ContentLayout.Parent = ContentFrame

-- ======== COMPOSANTS UI ========
local function MakeCard(title)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0,0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Config.Colors.BgCard
    card.BorderSizePixel = 0
    card.Parent = ContentFrame
    Corner(card, UDim.new(0,10))
    Stroke(card, Config.Colors.Border, 1)
    local cardPad = Instance.new("UIPadding")
    cardPad.PaddingAll = UDim.new(0,12)
    cardPad.Parent = card
    local cardLayout = Instance.new("UIListLayout")
    cardLayout.FillDirection = Enum.FillDirection.Vertical
    cardLayout.Padding = UDim.new(0,8)
    cardLayout.Parent = card
    if title then
        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1,0,0,18)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title
        titleLbl.TextColor3 = Config.Colors.TextDim
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = IsMobile and 10 or 11
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Parent = card
    end
    return card
end

local function MakeToggle(parent, labelText, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0, IsMobile and 36 or 38)
    row.BackgroundTransparency = 1
    row.Parent = parent
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-60,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Config.Colors.Text
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = IsMobile and 12 or 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    local state = default or false
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, IsMobile and 42 or 46, 0, IsMobile and 22 or 24)
    track.Position = UDim2.new(1, IsMobile and -46 or -50, 0.5, IsMobile and -11 or -12)
    track.BackgroundColor3 = state and Config.Colors.Accent or Config.Colors.Toggle
    track.BorderSizePixel = 0
    track.Parent = row
    Corner(track, UDim.new(1,0))
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, IsMobile and 16 or 18, 0, IsMobile and 16 or 18)
    knob.Position = state and UDim2.new(1, IsMobile and -19 or -21, 0.5, IsMobile and -8 or -9) or UDim2.new(0, 3, 0.5, IsMobile and -8 or -9)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    Corner(knob, UDim.new(1,0))
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row
    btn.MouseButton1Click:Connect(function()
        state = not state
        Tween(track, {BackgroundColor3 = state and Config.Colors.Accent or Config.Colors.Toggle})
        Tween(knob, {Position = state and UDim2.new(1, IsMobile and -19 or -21, 0.5, IsMobile and -8 or -9) or UDim2.new(0, 3, 0.5, IsMobile and -8 or -9)})
        if callback then callback(state) end
    end)
    return row
end

local function MakeSlider(parent, labelText, min, max, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0, IsMobile and 52 or 56)
    row.BackgroundTransparency = 1
    row.Parent = parent
    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1,0,0,20)
    topRow.BackgroundTransparency = 1
    topRow.Parent = row
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Config.Colors.Text
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = IsMobile and 12 or 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = topRow
    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.3,0,1,0)
    valLbl.Position = UDim2.new(0.7,0,0,0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default or min)
    valLbl.TextColor3 = Config.Colors.Accent
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = IsMobile and 12 or 13
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = topRow
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1,0,0,6)
    track.Position = UDim2.new(0,0,0, IsMobile and 32 or 36)
    track.BackgroundColor3 = Config.Colors.Toggle
    track.BorderSizePixel = 0
    track.Parent = row
    Corner(track, UDim.new(1,0))
    local fill = Instance.new("Frame")
    local pct = ((default or min) - min) / (max - min)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Config.Colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    Corner(fill, UDim.new(1,0))
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0,14,0,14)
    handle.Position = UDim2.new(pct,-7,0.5,-7)
    handle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    handle.BorderSizePixel = 0
    handle.Parent = track
    Corner(handle, UDim.new(1,0))
    local sliding = false
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1,0,0,24)
    sliderBtn.Position = UDim2.new(0,0,0, IsMobile and 25 or 29)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.Parent = row
    local function updateSlider(x)
        local abs = track.AbsolutePosition.X
        local w = track.AbsoluteSize.X
        local p = math.clamp((x - abs) / w, 0, 1)
        local val = math.floor(min + (max - min) * p)
        fill.Size = UDim2.new(p, 0, 1, 0)
        handle.Position = UDim2.new(p, -7, 0.5, -7)
        valLbl.Text = tostring(val)
        if callback then callback(val) end
    end
    sliderBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateSlider(inp.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(inp.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    return row
end

local function MakeDropdown(parent, labelText, options, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.Parent = parent
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1,0,0, IsMobile and 38 or 40)
    header.BackgroundColor3 = Config.Colors.Toggle
    header.Text = ""
    header.BorderSizePixel = 0
    header.Parent = container
    Corner(header, UDim.new(0,8))
    Stroke(header, Config.Colors.Border, 1)
    local headerLbl = Instance.new("TextLabel")
    headerLbl.Size = UDim2.new(1,-40,1,0)
    headerLbl.Position = UDim2.new(0,12,0,0)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Text = labelText
    headerLbl.TextColor3 = Config.Colors.Text
    headerLbl.Font = Enum.Font.GothamSemibold
    headerLbl.TextSize = IsMobile and 12 or 13
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Parent = header
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0,30,1,0)
    arrow.Position = UDim2.new(1,-34,0,0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "v"
    arrow.TextColor3 = Config.Colors.Accent
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 12
    arrow.Parent = header
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1,0,0,0)
    dropdown.BackgroundColor3 = Config.Colors.BgCard
    dropdown.BorderSizePixel = 0
    dropdown.ClipsDescendants = true
    dropdown.Parent = container
    Corner(dropdown, UDim.new(0,8))
    Stroke(dropdown, Config.Colors.Accent, 1)
    local ddLayout = Instance.new("UIListLayout")
    ddLayout.FillDirection = Enum.FillDirection.Vertical
    ddLayout.Parent = dropdown
    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1,0,0, IsMobile and 34 or 36)
        optBtn.BackgroundTransparency = 1
        optBtn.Text = opt
        optBtn.TextColor3 = Config.Colors.Text
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = IsMobile and 12 or 13
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.Parent = dropdown
        local optPad = Instance.new("UIPadding")
        optPad.PaddingLeft = UDim.new(0,12)
        optPad.Parent = optBtn
        optBtn.MouseEnter:Connect(function()
            Tween(optBtn, {BackgroundTransparency = 0.7})
            optBtn.BackgroundColor3 = Config.Colors.Accent
        end)
        optBtn.MouseLeave:Connect(function()
            Tween(optBtn, {BackgroundTransparency = 1})
        end)
        optBtn.MouseButton1Click:Connect(function()
            headerLbl.Text = opt
            Tween(dropdown, {Size = UDim2.new(1,0,0,0)})
            arrow.Text = "v"
            if callback then callback(opt) end
        end)
    end
    local isOpen = false
    local totalH = #options * (IsMobile and 34 or 36)
    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            Tween(dropdown, {Size = UDim2.new(1,0,0,totalH)})
            arrow.Text = "^"
        else
            Tween(dropdown, {Size = UDim2.new(1,0,0,0)})
            arrow.Text = "v"
        end
    end)
    return container
end

local function MakeButton(parent, text, col, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0, IsMobile and 38 or 40)
    btn.BackgroundColor3 = col or Config.Colors.Accent
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = IsMobile and 12 or 13
    btn.BorderSizePixel = 0
    btn.Parent = parent
    Corner(btn, UDim.new(0,8))
    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundTransparency = 0.15})
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundTransparency = 0})
    end)
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end

-- ======== TABS ========
local tabs = {
    {name="Accueil",  icon="[H]"},
    {name="Combat",   icon="[C]"},
    {name="Joueur",   icon="[J]"},
    {name="Ferme",    icon="[F]"},
    {name="Config",   icon="[S]"},
}
local tabBtns = {}
local activeTab = nil

local function ClearContent()
    for _, c in pairs(ContentFrame:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
            c:Destroy()
        end
    end
end

local function LoadTab(tabName)
    if activeTab == tabName then return end
    activeTab = tabName
    ClearContent()
    for _, b in pairs(tabBtns) do
        if b.Name == tabName then
            Tween(b, {BackgroundColor3 = Config.Colors.Accent})
            b.TextColor3 = Color3.fromRGB(255,255,255)
        else
            Tween(b, {BackgroundColor3 = Color3.fromRGB(0,0,0,0)})
            b.BackgroundTransparency = 1
            b.TextColor3 = Config.Colors.TextDim
        end
    end
    if tabName == "Accueil" then
        local c1 = MakeCard("BIENVENUE")
        Label(c1, "Hyper Hub v2.0", IsMobile and 15 or 17, Config.Colors.Accent, Enum.Font.GothamBold,
            nil, UDim2.new(1,0,0,22), Enum.TextXAlignment.Left)
        Label(c1, "Licence : " .. (LicenseData and (LicenseData.type == "perm" and "Permanente" or "Temporaire") or "Active"),
            IsMobile and 11 or 12, Config.Colors.Success, Enum.Font.Gotham,
            nil, UDim2.new(1,0,0,18), Enum.TextXAlignment.Left)
        Label(c1, "Joueur : " .. Player.Name,
            IsMobile and 11 or 12, Config.Colors.TextDim, Enum.Font.Gotham,
            nil, UDim2.new(1,0,0,18), Enum.TextXAlignment.Left)
        local c2 = MakeCard("RACCOURCI")
        Label(c2, "Touche : RightControl (toggle menu)",
            IsMobile and 11 or 12, Config.Colors.TextDim, Enum.Font.Gotham,
            nil, UDim2.new(1,0,0,18), Enum.TextXAlignment.Left)
    elseif tabName == "Combat" then
        local c1 = MakeCard("AIMBOT")
        MakeToggle(c1, "Aimbot", false, function(v) print("Aimbot:", v) end)
        MakeToggle(c1, "Silent Aim", false, function(v) print("SilentAim:", v) end)
        MakeSlider(c1, "Portee Aimbot", 10, 500, 100, function(v) print("Range:", v) end)
        MakeDropdown(c1, "Partie du corps", {"Tete", "Torse", "Aleatoire"}, function(v) print("Part:", v) end)
        local c2 = MakeCard("VISIBILITE")
        MakeToggle(c2, "ESP Joueurs", false, function(v) print("ESP:", v) end)
        MakeToggle(c2, "Tracer", false, function(v) print("Tracer:", v) end)
        MakeSlider(c2, "Epaisseur ESP", 1, 5, 2, function(v) print("ESPThick:", v) end)
        MakeDropdown(c2, "Couleur ESP", {"Rouge", "Bleu", "Vert", "Blanc"}, function(v) print("ESPCol:", v) end)
    elseif tabName == "Joueur" then
        local c1 = MakeCard("MOUVEMENT")
        MakeToggle(c1, "Infinite Jump", false, function(v)
            if v then
                UIS.JumpRequest:Connect(function()
                    if game.Players.LocalPlayer.Character then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                    end
                end)
            end
        end)
        MakeToggle(c1, "Noclip", false, function(v) print("Noclip:", v) end)
        MakeSlider(c1, "Vitesse de marche", 16, 200, 16, function(v)
            if Player.Character then
                local hum = Player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = v end
            end
        end)
        MakeSlider(c1, "Hauteur de saut", 7, 200, 50, function(v)
            if Player.Character then
                local hum = Player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = v end
            end
        end)
        local c2 = MakeCard("APPARENCE")
        MakeDropdown(c2, "Taille du joueur", {"Normal", "Petit", "Geant"}, function(v)
            if Player.Character then
                local hum = Player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    if v == "Normal" then hum.BodyDepthScale.Value=1 hum.BodyHeightScale.Value=1 hum.BodyWidthScale.Value=1
                    elseif v == "Petit" then hum.BodyDepthScale.Value=0.5 hum.BodyHeightScale.Value=0.5 hum.BodyWidthScale.Value=0.5
                    elseif v == "Geant" then hum.BodyDepthScale.Value=2 hum.BodyHeightScale.Value=2 hum.BodyWidthScale.Value=2
                    end
                end
            end
        end)
        MakeButton(c2, "Respawn", Config.Colors.Warning, function()
            Player.Character:BreakJoints()
        end)
    elseif tabName == "Ferme" then
        local c1 = MakeCard("AUTO FARM")
        MakeToggle(c1, "Auto Farm", false, function(v) print("AutoFarm:", v) end)
        MakeToggle(c1, "Auto Collect", false, function(v) print("AutoCollect:", v) end)
        MakeSlider(c1, "Intervalle (sec)", 1, 30, 5, function(v) print("Interval:", v) end)
        MakeDropdown(c1, "Mode de farm", {"Normal", "Rapide", "Ultra"}, function(v) print("Mode:", v) end)
        local c2 = MakeCard("TELEPORT")
        MakeDropdown(c2, "Zone", {"Zone 1","Zone 2","Zone 3","Boss"}, function(v) print("Zone:", v) end)
        MakeButton(c2, "Teleporter", Config.Colors.Accent, function()
            print("Teleport!")
        end)
    elseif tabName == "Config" then
        local c1 = MakeCard("INTERFACE")
        MakeDropdown(c1, "Touche toggle", {"RightControl","RightShift","F5","F6"}, function(v)
            print("Toggle key:", v)
        end)
        MakeToggle(c1, "Notifications", true, function(v) print("Notifs:", v) end)
        MakeToggle(c1, "Sons UI", false, function(v) print("Sounds:", v) end)
        local c2 = MakeCard("LICENCE")
        Label(c2, "Type : " .. (LicenseData and (LicenseData.type == "perm" and "Permanente" or "Temporaire") or "?"),
            IsMobile and 12 or 13, Config.Colors.Success, Enum.Font.GothamSemibold,
            nil, UDim2.new(1,0,0,20), Enum.TextXAlignment.Left)
        MakeButton(c2, "Deconnexion", Config.Colors.Error, function()
            IsLicensed = false
            LicenseData = nil
            MainFrame.Visible = false
            LicFrame.Visible = true
            InputBox.Text = ""
            StatusLbl.Text = ""
        end)
    end
end

for _, tab in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Name = tab.name
    btn.Size = UDim2.new(1,0,0, IsMobile and 36 or 38)
    btn.BackgroundTransparency = 1
    btn.Text = tab.name
    btn.TextColor3 = Config.Colors.TextDim
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = IsMobile and 11 or 12
    btn.BorderSizePixel = 0
    btn.Parent = SidebarFrame
    Corner(btn, UDim.new(0,8))
    table.insert(tabBtns, btn)
    btn.MouseEnter:Connect(function()
        if activeTab ~= tab.name then
            Tween(btn, {BackgroundTransparency = 0.8})
            btn.BackgroundColor3 = Config.Colors.Accent
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= tab.name then
            Tween(btn, {BackgroundTransparency = 1})
        end
    end)
    btn.MouseButton1Click:Connect(function()
        LoadTab(tab.name)
    end)
end

-- ======== TOGGLE KEY ========
UIS.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == Config.ToggleKey and IsLicensed then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            MainFrame.Size = UDim2.new(0,WIN_W,0,0)
            Tween(MainFrame, {Size = UDim2.new(0,WIN_W,0,WIN_H)})
        end
    end
end)

-- ======== VALIDATION CLE (CORRIGE) ========
-- CORRECTION : ValidateLicense est maintenant SYNCHRONE (pas de task.spawn interne)
-- Le seul task.spawn est dans ActivateBtn.MouseButton1Click
-- Cela resout le bug du double task.spawn imbriqué qui causait le silence total

local isValidating = false

local function ValidateLicense(key)
    local cleanKey = key:upper():gsub("%s+","")
    if cleanKey == "" then return false, "Veuillez entrer une cle" end

    -- Appel HTTP direct et synchrone (pas de task.spawn ici !)
    local ok, resp = pcall(function()
        return HTTP:RequestAsync({
            Url = Config.ApiUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = Config.ApiToken
            },
            Body = HTTP:JSONEncode({
                key = cleanKey,
                userId = tostring(Player.UserId),
                username = Player.Name
            })
        })
    end)

    if not ok then
        -- La requete a plante (serveur hors ligne, timeout, etc.)
        return false, "Serveur inaccessible - Reessaie dans 30 sec"
    end

    if not resp then
        return false, "Aucune reponse du serveur"
    end

    -- Lire la reponse JSON
    local ok2, data = pcall(function()
        return HTTP:JSONDecode(resp.Body)
    end)

    if not ok2 or not data then
        return false, "Erreur lecture reponse serveur"
    end

    if data.valid then
        return true, {valid = true, type = data.type or "perm"}
    else
        return false, data.reason or "Cle invalide"
    end
end

-- ======== BOUTON ACTIVER (CORRIGE) ========
ActivateBtn.MouseButton1Click:Connect(function()
    if isValidating then return end

    local key = InputBox.Text
    if key == "" then
        StatusLbl.Text = "Veuillez entrer une cle !"
        StatusLbl.TextColor3 = Config.Colors.Error
        return
    end

    isValidating = true
    ActivateBtn.Text = "Validation..."
    ActivateBtn.BackgroundColor3 = Config.Colors.TextDim
    StatusLbl.Text = "Connexion au serveur..."
    StatusLbl.TextColor3 = Config.Colors.Warning

    -- Un seul task.spawn, ValidateLicense est synchrone dedans
    task.spawn(function()
        local valid, data = ValidateLicense(key)

        if valid then
            IsLicensed = true
            LicenseData = data
            StatusLbl.Text = "Cle valide !"
            StatusLbl.TextColor3 = Config.Colors.Success
            ActivateBtn.Text = "Acces accorde !"
            ActivateBtn.BackgroundColor3 = Config.Colors.Success
            BadgeLbl.Text = data.type == "perm" and "PERMANENT" or "TEMPORAIRE"
            task.wait(0.8)
            LicFrame.Visible = false
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0,WIN_W,0,0)
            Tween(MainFrame, {Size = UDim2.new(0,WIN_W,0,WIN_H)})
            task.wait(0.2)
            LoadTab("Accueil")
        else
            StatusLbl.Text = tostring(data)
            StatusLbl.TextColor3 = Config.Colors.Error
            ActivateBtn.Text = "Activer la Licence"
            ActivateBtn.BackgroundColor3 = Config.Colors.Accent
            isValidating = false
        end
    end)
end)