-- ==================== HYPER HUB v1.0.0 ====================
-- Script executable via Executor (Synapse X, ScriptWare, etc.)
-- ===========================================================

local isExecutor = (getgenv and true) or (shared and true)
if not isExecutor then
    warn("Ce script necessite un executor Roblox")
    return
end

-- ==================== CONFIGURATION ====================
local Config = {
    Colors = {
        Background = Color3.fromRGB(30, 30, 40),
        BackgroundLight = Color3.fromRGB(25, 25, 35),
        Sidebar = Color3.fromRGB(20, 20, 28),
        Accent = Color3.fromRGB(0, 200, 255),
        AccentSecondary = Color3.fromRGB(138, 43, 226),
        Success = Color3.fromRGB(0, 230, 118),
        Error = Color3.fromRGB(255, 82, 82),
        Warning = Color3.fromRGB(255, 170, 0),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 150, 160),
        Border = Color3.fromRGB(50, 50, 60),
    },
    WindowSize = UDim2.new(0, 600, 0, 400),
    SidebarWidth = 160,
    TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenInfoFast = TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    -- CORRIGE : URL directe sans /validate en plus
    ApiUrl = "https://hyperhub-bot.onrender.com/verify",
    ApiToken = "lolilol980",
}

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ==================== VARIABLES ====================
local ScreenGui, MainFrame, Sidebar, ContentContainer, LicenseEntryScreen
local CurrentTab = "Home"
local IsLicensed = false
local LicenseData = nil
local ToggleKey = Enum.KeyCode.RightControl

-- ==================== UTILITAIRES ====================
local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 10)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Config.Colors.Border
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function Tween(instance, properties, tweenInfo)
    tweenInfo = tweenInfo or Config.TweenInfo
    local t = TweenService:Create(instance, tweenInfo, properties)
    t:Play()
    return t
end

local function Notify(title, message, notificationType)
    local color = Config.Colors.Accent
    if notificationType == "success" then color = Config.Colors.Success
    elseif notificationType == "error" then color = Config.Colors.Error
    elseif notificationType == "warning" then color = Config.Colors.Warning
    end

    local container = PlayerGui:FindFirstChild("NotificationsContainer")
    if not container then
        container = Instance.new("ScreenGui")
        container.Name = "NotificationsContainer"
        container.ResetOnSpawn = false
        container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        container.Parent = PlayerGui
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.Padding = UDim.new(0, 10)
        layout.Parent = container
    end

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 280, 0, 70)
    notif.BackgroundColor3 = Config.Colors.BackgroundLight
    notif.BorderSizePixel = 0
    notif.Parent = container
    CreateCorner(notif)
    CreateStroke(notif, color, 2)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.Parent = notif
    CreateCorner(bar, UDim.new(0, 2))

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -20, 0, 22)
    titleLbl.Position = UDim2.new(0, 12, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = color
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = notif

    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1, -20, 0, 35)
    msgLbl.Position = UDim2.new(0, 12, 0, 30)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Text = message
    msgLbl.TextColor3 = Config.Colors.Text
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextSize = 12
    msgLbl.TextWrapped = true
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextYAlignment = Enum.TextYAlignment.Top
    msgLbl.Parent = notif

    notif.Position = UDim2.new(1, 50, 0, 0)
    Tween(notif, {Position = UDim2.new(0, 0, 0, 0)})
    task.delay(4, function()
        Tween(notif, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1})
        task.wait(0.3)
        notif:Destroy()
    end)
end

-- ==================== VALIDATION CLE (CORRIGE) ====================
local function ValidateLicense(key)
    -- Nettoyage de la cle
    local cleanKey = key:upper():gsub("%s+", "")

    if cleanKey == "" then
        return false, "Veuillez entrer une cle"
    end

    -- CORRIGE : Envoi direct a /verify sans ajouter /validate
    local success, response = pcall(function()
        local requestBody = HttpService:JSONEncode({
            key = cleanKey,
            userId = tostring(Player.UserId),
            username = Player.Name
        })
        -- CORRIGE : Authorization sans "Bearer", juste le token
        return HttpService:RequestAsync({
            Url = Config.ApiUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = Config.ApiToken
            },
            Body = requestBody
        })
    end)

    if success and response then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)
        if ok and data then
            if data.valid then
                -- Retourne le type : permanent ou temporaire
                return true, {
                    valid = true,
                    type = data.type or "perm",
                    message = data.type == "perm" and "Licence Permanente" or "Licence Temporaire"
                }
            else
                return false, data.reason or "Cle de licence invalide"
            end
        else
            return false, "Erreur de lecture de la reponse"
        end
    else
        return false, "Impossible de contacter le serveur. Verifie ta connexion."
    end
end

-- ==================== INTERFACE ====================
local UpdateLicenseStatus, UpdateTabs, UpdateContent

local function ShowMainUI()
    if LicenseEntryScreen then LicenseEntryScreen.Visible = false end
    if MainFrame then MainFrame.Visible = true end
    if UpdateLicenseStatus then UpdateLicenseStatus() end
    if UpdateTabs then UpdateTabs() end
    if UpdateContent then UpdateContent() end
    Notify("Bienvenue", "Appuyez sur [RightControl] pour masquer le menu", "success")
end

local function ShowLicenseScreen()
    if MainFrame then MainFrame.Visible = false end
    if LicenseEntryScreen then LicenseEntryScreen.Visible = true end
end

local function CreateUI()
    local oldGui = PlayerGui:FindFirstChild("HyperHub")
    if oldGui then oldGui:Destroy() end

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HyperHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui

    -- === MAIN FRAME ===
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Config.WindowSize
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Config.Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    CreateCorner(MainFrame)
    CreateStroke(MainFrame, Config.Colors.Border, 1)

    -- Draggable
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Config.Colors.Sidebar
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    CreateCorner(Header)

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(1, -100, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = "HYPER HUB"
    HeaderTitle.TextColor3 = Config.Colors.Accent
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextSize = 16
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header

    -- Licence info dans header
    local LicenseTag = Instance.new("TextLabel")
    LicenseTag.Name = "LicenseTag"
    LicenseTag.Size = UDim2.new(0, 120, 0, 25)
    LicenseTag.Position = UDim2.new(1, -130, 0.5, -12)
    LicenseTag.BackgroundColor3 = Config.Colors.Success
    LicenseTag.Text = "PERMANENT"
    LicenseTag.TextColor3 = Color3.fromRGB(255, 255, 255)
    LicenseTag.Font = Enum.Font.GothamBold
    LicenseTag.TextSize = 11
    LicenseTag.Parent = Header
    CreateCorner(LicenseTag, UDim.new(0, 6))

    -- Sidebar
    Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, Config.SidebarWidth, 1, -45)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = Config.Colors.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.FillDirection = Enum.FillDirection.Vertical
    SidebarLayout.Padding = UDim.new(0, 4)
    SidebarLayout.Parent = Sidebar

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 8)
    SidebarPadding.PaddingLeft = UDim.new(0, 8)
    SidebarPadding.PaddingRight = UDim.new(0, 8)
    SidebarPadding.Parent = Sidebar

    -- Content
    ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -Config.SidebarWidth, 1, -45)
    ContentContainer.Position = UDim2.new(0, Config.SidebarWidth, 0, 45)
    ContentContainer.BackgroundColor3 = Config.Colors.BackgroundLight
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame

    -- Tabs
    local tabs = {
        {name = "Accueil", icon = "Home"},
        {name = "Combat", icon = "Sword"},
        {name = "Joueur", icon = "Person"},
        {name = "Ferme", icon = "Crop"},
        {name = "Parametres", icon = "Settings"},
    }

    local tabButtons = {}

    local function SetTab(tabName)
        CurrentTab = tabName
        for _, btn in pairs(tabButtons) do
            if btn.Name == tabName then
                Tween(btn, {BackgroundColor3 = Config.Colors.Accent})
                btn.TextColor3 = Color3.fromRGB(0, 0, 0)
            else
                Tween(btn, {BackgroundColor3 = Color3.fromRGB(35, 35, 50)})
                btn.TextColor3 = Config.Colors.TextDim
            end
        end
        -- Efface le contenu
        for _, child in pairs(ContentContainer:GetChildren()) do
            child:Destroy()
        end
        -- Contenu par tab
        local contentPad = Instance.new("UIPadding")
        contentPad.PaddingAll = UDim.new(0, 15)
        contentPad.Parent = ContentContainer

        if tabName == "Accueil" then
            local welcome = Instance.new("TextLabel")
            welcome.Size = UDim2.new(1, 0, 0, 40)
            welcome.BackgroundTransparency = 1
            welcome.Text = "Bienvenue sur Hyper Hub"
            welcome.TextColor3 = Config.Colors.Accent
            welcome.Font = Enum.Font.GothamBold
            welcome.TextSize = 18
            welcome.TextXAlignment = Enum.TextXAlignment.Left
            welcome.Parent = ContentContainer

            local sub = Instance.new("TextLabel")
            sub.Size = UDim2.new(1, 0, 0, 30)
            sub.Position = UDim2.new(0, 0, 0, 45)
            sub.BackgroundTransparency = 1
            sub.Text = "Licence active - " .. (LicenseData and (LicenseData.type == "perm" and "Permanente" or "Temporaire") or "")
            sub.TextColor3 = Config.Colors.Success
            sub.Font = Enum.Font.Gotham
            sub.TextSize = 13
            sub.TextXAlignment = Enum.TextXAlignment.Left
            sub.Parent = ContentContainer
        end
    end

    UpdateLicenseStatus = function()
        local tag = Header:FindFirstChild("LicenseTag")
        if tag and LicenseData then
            if LicenseData.type == "perm" then
                tag.Text = "PERMANENT"
                tag.BackgroundColor3 = Config.Colors.Success
            else
                tag.Text = "TEMPORAIRE"
                tag.BackgroundColor3 = Config.Colors.Warning
            end
        end
    end

    UpdateTabs = function()
        for _, btn in pairs(tabButtons) do
            btn:Destroy()
        end
        tabButtons = {}
        for _, tab in ipairs(tabs) do
            local btn = Instance.new("TextButton")
            btn.Name = tab.name
            btn.Size = UDim2.new(1, 0, 0, 36)
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            btn.Text = tab.name
            btn.TextColor3 = Config.Colors.TextDim
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 13
            btn.BorderSizePixel = 0
            btn.Parent = Sidebar
            CreateCorner(btn, UDim.new(0, 8))
            table.insert(tabButtons, btn)
            btn.MouseButton1Click:Connect(function()
                SetTab(tab.name)
            end)
        end
    end

    UpdateContent = function()
        SetTab("Accueil")
    end

    -- Toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    -- ==================== ECRAN LICENCE (CORRIGE) ====================
    -- CORRIGE : Frame centree, pas plein ecran
    LicenseEntryScreen = Instance.new("Frame")
    LicenseEntryScreen.Name = "LicenseEntryScreen"
    LicenseEntryScreen.Size = UDim2.new(0, 400, 0, 300)
    LicenseEntryScreen.Position = UDim2.new(0.5, -200, 0.5, -150)
    LicenseEntryScreen.BackgroundColor3 = Config.Colors.Background
    LicenseEntryScreen.BorderSizePixel = 0
    LicenseEntryScreen.Visible = true
    LicenseEntryScreen.Parent = ScreenGui
    CreateCorner(LicenseEntryScreen, UDim.new(0, 16))
    CreateStroke(LicenseEntryScreen, Config.Colors.Accent, 2)

    -- Titre
    local LicenseTitle = Instance.new("TextLabel")
    LicenseTitle.Size = UDim2.new(1, 0, 0, 50)
    LicenseTitle.Position = UDim2.new(0, 0, 0, 20)
    LicenseTitle.BackgroundTransparency = 1
    LicenseTitle.Text = "Activation de Licence"
    LicenseTitle.TextColor3 = Config.Colors.Accent
    LicenseTitle.Font = Enum.Font.GothamBold
    LicenseTitle.TextSize = 20
    LicenseTitle.Parent = LicenseEntryScreen

    -- Sous-titre
    local LicenseSubtitle = Instance.new("TextLabel")
    LicenseSubtitle.Size = UDim2.new(1, 0, 0, 25)
    LicenseSubtitle.Position = UDim2.new(0, 0, 0, 65)
    LicenseSubtitle.BackgroundTransparency = 1
    LicenseSubtitle.Text = "Entrez votre cle de licence"
    LicenseSubtitle.TextColor3 = Config.Colors.TextDim
    LicenseSubtitle.Font = Enum.Font.Gotham
    LicenseSubtitle.TextSize = 13
    LicenseSubtitle.Parent = LicenseEntryScreen

    -- Input box
    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(1, -40, 0, 40)
    InputBox.Position = UDim2.new(0, 20, 0, 105)
    InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    InputBox.Text = ""
    InputBox.PlaceholderText = "Ex: A1B2C3D4E5F6G7H8"
    InputBox.TextColor3 = Config.Colors.Text
    InputBox.PlaceholderColor3 = Config.Colors.TextDim
    InputBox.Font = Enum.Font.GothamBold
    InputBox.TextSize = 14
    InputBox.ClearTextOnFocus = false
    InputBox.BorderSizePixel = 0
    InputBox.Parent = LicenseEntryScreen
    CreateCorner(InputBox, UDim.new(0, 8))
    CreateStroke(InputBox, Config.Colors.Border, 1)

    -- Bouton Activer
    local ActivateBtn = Instance.new("TextButton")
    ActivateBtn.Size = UDim2.new(1, -40, 0, 45)
    ActivateBtn.Position = UDim2.new(0, 20, 0, 160)
    ActivateBtn.BackgroundColor3 = Config.Colors.Accent
    ActivateBtn.Text = "Activer"
    ActivateBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    ActivateBtn.Font = Enum.Font.GothamBold
    ActivateBtn.TextSize = 15
    ActivateBtn.BorderSizePixel = 0
    ActivateBtn.Parent = LicenseEntryScreen
    CreateCorner(ActivateBtn, UDim.new(0, 10))

    -- Statut
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 30)
    StatusLabel.Position = UDim2.new(0, 0, 0, 215)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Config.Colors.TextDim
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 12
    StatusLabel.Parent = LicenseEntryScreen

    -- CORRIGE : Logique du bouton Activer
    local isValidating = false
    ActivateBtn.MouseButton1Click:Connect(function()
        if isValidating then return end

        local key = InputBox.Text
        if key == "" then
            StatusLabel.Text = "Veuillez entrer une cle !"
            StatusLabel.TextColor3 = Config.Colors.Error
            return
        end

        isValidating = true
        ActivateBtn.Text = "Validation en cours..."
        ActivateBtn.BackgroundColor3 = Config.Colors.TextDim
        StatusLabel.Text = "Connexion au serveur..."
        StatusLabel.TextColor3 = Config.Colors.Warning

        -- Lance la validation dans un thread separe pour ne pas bloquer
        task.spawn(function()
            local valid, result = ValidateLicense(key)

            if valid then
                IsLicensed = true
                LicenseData = result
                StatusLabel.Text = "Cle valide ! Acces accorde."
                StatusLabel.TextColor3 = Config.Colors.Success
                ActivateBtn.Text = "Acces accorde !"
                ActivateBtn.BackgroundColor3 = Config.Colors.Success
                task.wait(1)
                ShowMainUI()
            else
                StatusLabel.Text = "Erreur : " .. tostring(result)
                StatusLabel.TextColor3 = Config.Colors.Error
                ActivateBtn.Text = "Activer"
                ActivateBtn.BackgroundColor3 = Config.Colors.Accent
                isValidating = false
            end
        end)
    end)
end

-- Lancer
CreateUI()
ShowLicenseScreen()