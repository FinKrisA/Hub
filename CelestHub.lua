--[[
    Celest Hub GUI
    Interface moderne pour Roblox
    Version: 4.2 (Ajout Auto Answer)
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Joueur local
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- CHARGEMENT DE WINDUI
-- ============================================
local WindUI

local success, err = pcall(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/Main.lua"))()
end)

if not success or not WindUI then
    warn("[Celest Hub] Erreur de chargement WindUI: " .. tostring(err))
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CelestHub_Error"
    screenGui.Parent = game.CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 100)
    frame.Position = UDim2.new(0.5, -150, 0.5, -50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.white
    textLabel.TextScaled = true
    textLabel.Text = "Celest Hub\nErreur de chargement WindUI!"
    textLabel.Parent = frame
    
    return
end

print("[Celest Hub] WindUI chargé avec succès!")

-- ============================================
-- VARIABLES GLOBALES & ÉTAT
-- ============================================
local Settings = {
    WalkSpeed = 16,
    JumpPower = 50,
    Gravity = 196.2,
    AutoBringEnabled = false,
    AutoASC1Enabled = false,
    AutoASC2Enabled = false,
    AutoASC3Enabled = false,
    AutoASC4Enabled = false,
    AutoSAC1Enabled = false,
    AutoSAC2Enabled = false,
    AutoSAC3Enabled = false,
    AutoSAC4Enabled = false,
    InfiniteJump = false,
    AutoEquipPoidsEnabled = false,
    AutoAnswerEnabled = false,
    AnswerDelay = 1,
}

local JumpConnection = nil
local TeleportLockConnection = nil

-- Variables pour l'Auto Answer
local AnsweredMessages = {}
local AnsweredExpressions = {}
local AutoAnswerConnections = {}

-- Obtenir le personnage
local function GetCharacter()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    return character, humanoid, rootPart
end

-- Appliquer les paramètres
local function ApplyCharacterSettings()
    task.wait(0.3)
    local character, humanoid = GetCharacter()
    if not humanoid then return end
    
    pcall(function()
        if Settings.WalkSpeed ~= 16 then
            humanoid.WalkSpeed = Settings.WalkSpeed
        end
        if Settings.JumpPower ~= 50 then
            humanoid.JumpPower = Settings.JumpPower
            humanoid.UseJumpPower = true
        end
        if Settings.Gravity ~= 196.2 then
            workspace.Gravity = Settings.Gravity
        end
    end)
end

-- ============================================
-- LOGIQUE AUTO ANSWER (Traduite & Intégrée)
-- ============================================
local function SolveExpression(expression)
    local expr = expression:gsub("[^%d%+%-%*/%.%(%)]", "")
    expr = expr:gsub("x", "*"):gsub("X", "*"):gsub("×", "*"):gsub("÷", "/")
    local success, result = pcall(function()
        local func = loadstring("return " .. expr)
        if func then return func() end
        return nil
    end)
    if success and result then
        if result == math.floor(result) then
            return tostring(math.floor(result))
        else
            return tostring(math.floor(result * 100 + 0.5) / 100)
        end
    end
    return nil
end

local function NormalizeExpression(expr)
    local normalized = expr:gsub("%s+", "")
    normalized = normalized:gsub("x", "*"):gsub("X", "*"):gsub("×", "*"):gsub("÷", "/")
    return normalized
end

local function IsValidMathExpression(message)
    local numbers = {}
    local operatorsFound = false
    for num in message:gmatch("%d+") do table.insert(numbers, tonumber(num)) end
    if message:find("[+%-*/xX×÷]") then operatorsFound = true end
    return #numbers >= 2 and operatorsFound
end

local function TrySolveMessage(message)
    if not IsValidMathExpression(message) then return nil, nil end
    local patterns = {
        "(%d+[%s]*[%+%-%*/x×÷][%s]*%d+[%s]*[%+%-%*/x×÷]?[%s]*%d*)",
        "(%d+[%s]*[%+%-%*/][%s]*%d+)",
        "What is (%d+[%s]*[%+%-%*/x×÷][%s]*%d+)",
        "Solve[:%s]*(%d+[%s]*[%+%-%*/x×÷][%s]*%d+)",
        "Answer[:%s]*(%d+[%s]*[%+%-%*/x×÷][%s]*%d+)",
    }
    for _, pattern in pairs(patterns) do
        local match = message:match(pattern)
        if match then
            local answer = SolveExpression(match)
            if answer then return answer, match end
        end
    end
    return nil, nil
end

local function SendChatMessage(message)
    pcall(function()
        local TextChatService = game:GetService("TextChatService")
        local generalChannel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if generalChannel then generalChannel:SendAsync(message) return end
    end)
    pcall(function()
        local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatRemote then
            local sayEvent = chatRemote:FindFirstChild("SayMessageRequest")
            if sayEvent then sayEvent:FireServer(message, "All") end
        end
    end)
end

local function HandleIncomingMessage(message, senderUserId)
    if not Settings.AutoAnswerEnabled then return end
    if senderUserId and senderUserId == LocalPlayer.UserId then return end

    local currentTime = tick()
    for key, t in pairs(AnsweredMessages) do
        if currentTime - t > 5 then AnsweredMessages[key] = nil end
    end

    if AnsweredMessages[message] then return end

    local answer, expr = TrySolveMessage(message)
    if answer and expr then
        local normalizedExpr = NormalizeExpression(expr)
        if AnsweredExpressions[normalizedExpr] then return end

        AnsweredMessages[message] = currentTime
        AnsweredExpressions[normalizedExpr] = currentTime

        task.delay(Settings.AnswerDelay, function()
            if Settings.AutoAnswerEnabled then SendChatMessage(answer) end
        end)
    end
end

local function SetupAutoAnswer(enabled)
    Settings.AutoAnswerEnabled = enabled

    for _, conn in pairs(AutoAnswerConnections) do pcall(function() conn:Disconnect() end) end
    AutoAnswerConnections = {}
    AnsweredMessages = {}
    AnsweredExpressions = {}

    if not enabled then return end

    task.spawn(function()
        while task.wait(300) do
            if Settings.AutoAnswerEnabled then
                AnsweredExpressions = {}
                AnsweredMessages = {}
            end
        end
    end)

    local useOldChat = true
    pcall(function()
        local TextChatService = game:GetService("TextChatService")
        if TextChatService and TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            useOldChat = false
        end
    end)

    if not useOldChat then
        pcall(function()
            local TextChatService = game:GetService("TextChatService")
            if TextChatService and TextChatService.MessageReceived then
                local conn = TextChatService.MessageReceived:Connect(function(textChatMessage)
                    if not Settings.AutoAnswerEnabled then return end
                    local msg = textChatMessage.Text
                    local senderId = nil
                    if textChatMessage.TextSource then senderId = textChatMessage.TextSource.UserId end
                    HandleIncomingMessage(msg, senderId)
                end)
                table.insert(AutoAnswerConnections, conn)
            end
        end)
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local conn = player.Chatted:Connect(function(message) HandleIncomingMessage(message, player.UserId) end)
                table.insert(AutoAnswerConnections, conn)
            end
        end
        local conn = Players.PlayerAdded:Connect(function(player)
            if player == LocalPlayer then return end
            local chatConn = player.Chatted:Connect(function(message) HandleIncomingMessage(message, player.UserId) end)
            table.insert(AutoAnswerConnections, chatConn)
        end)
        table.insert(AutoAnswerConnections, conn)
    end
end

-- ============================================
-- CRÉATION DE LA FENÊTRE
-- ============================================
local Window

local windowSuccess, windowErr = pcall(function()
    Window = WindUI:CreateWindow({
        Title = "Celest Hub",
        Author = "Celest",
        Folder = "CelestHub",
        Size = UDim2.fromOffset(580, 420),
        Transparent = true,
        SideBarWidth = 180,
        Background = "Dark",
    })
end)

if not windowSuccess or not Window then
    warn("[Celest Hub] Erreur création fenêtre: " .. tostring(windowErr))
    return
end

print("[Celest Hub] Fenêtre créée avec succès!")

-- ============================================
-- SECTION: HOME
-- ============================================
local HomeTab = Window:Tab({
    Title = "Home",
    Icon = "home",
})

HomeTab:Paragraph({
    Title = "Bienvenue sur Celest Hub!",
    Description = "Utilisez le menu à gauche pour naviguer.\n\nToutes les fonctionnalités sont opérationnelles.",
})

-- ============================================
-- SECTION: MOVEMENT
-- ============================================
local MovementTab = Window:Tab({
    Title = "Movement",
    Icon = "move",
})

MovementTab:Slider({
    Title = "WalkSpeed",
    Description = "Vitesse (16 = normal)",
    Value = { Min = 16, Max = 500, Default = Settings.WalkSpeed },
    Callback = function(Value)
        Settings.WalkSpeed = Value
        local _, humanoid = GetCharacter()
        if humanoid then humanoid.WalkSpeed = Value end
    end,
})

MovementTab:Slider({
    Title = "JumpPower",
    Description = "Saut (50 = normal)",
    Value = { Min = 0, Max = 500, Default = Settings.JumpPower },
    Callback = function(Value)
        Settings.JumpPower = Value
        local _, humanoid = GetCharacter()
        if humanoid then
            humanoid.JumpPower = Value
            humanoid.UseJumpPower = true
        end
    end,
})

MovementTab:Slider({
    Title = "Gravity",
    Description = "Gravité (196 = normal)",
    Value = { Min = 0, Max = 500, Default = 196 },
    Callback = function(Value)
        Settings.Gravity = Value
        workspace.Gravity = Value
    end,
})

MovementTab:Button({
    Title = "Reset Movement",
    Description = "Réinitialiser vitesse et saut",
    Callback = function()
        Settings.WalkSpeed = 16
        Settings.JumpPower = 50
        Settings.Gravity = 196.2
        local _, humanoid = GetCharacter()
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
        workspace.Gravity = 196.2
    end,
})

MovementTab:Toggle({
    Title = "Infinite Jump",
    Description = "Sauter en l'air",
    Default = false,
    Callback = function(Value)
        Settings.InfiniteJump = Value
        if JumpConnection then JumpConnection:Disconnect() JumpConnection = nil end
        if Value then
            JumpConnection = UserInputService.JumpRequest:Connect(function()
                local _, humanoid = GetCharacter()
                if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end,
})

MovementTab:Button({
    Title = "Reset Character",
    Description = "Réinitialiser le personnage",
    Callback = function()
        local _, humanoid = GetCharacter()
        if humanoid then humanoid.Health = 0 end
    end,
})

-- ============================================
-- SECTION: FONCTIONS
-- ============================================
local FonctionsTab = Window:Tab({
    Title = "Fonctions",
    Icon = "user",
})

-- Fonction générique pour créer un Auto-Toggle (ASC/SAC)
local function CreateAutoToggle(Title, SettingKey, RemotePath)
    FonctionsTab:Toggle({
        Title = Title,
        Description = "Active automatiquement " .. Title,
        Default = false,
        Callback = function(Value)
            Settings[SettingKey] = Value
            
            if Value then
                task.spawn(function()
                    while Settings[SettingKey] and task.wait(1) do
                        pcall(function()
                            RemotePath:FireServer()
                        end)
                    end
                end)
            end
        end,
    })
end

-- Création des boutons ASC/SAC
CreateAutoToggle("Auto ASC1", "AutoASC1Enabled", ReplicatedStorage.Remote.FromLocalForServer.Get.asc1)
CreateAutoToggle("Auto ASC2", "AutoASC2Enabled", ReplicatedStorage.Remote.FromLocalForServer.Get.asc2)
CreateAutoToggle("Auto ASC3", "AutoASC3Enabled", ReplicatedStorage.Remote.FromLocalForServer.Get.asc3)
CreateAutoToggle("Auto ASC4", "AutoASC4Enabled", ReplicatedStorage.Remote.FromLocalForServer.Get.asc4)

CreateAutoToggle("Auto SAC1", "AutoSAC1Enabled", ReplicatedStorage.Remote.FromLocalForServer.Get.sac1)
CreateAutoToggle("Auto SAC2", "AutoSAC2Enabled", ReplicatedStorage.Remote.FromLocalForServer.Get.sac2)
CreateAutoToggle("Auto SAC3", "AutoSAC3Enabled", ReplicatedStorage.Remote.FromLocalForServer.Get.sac3)
CreateAutoToggle("Auto SAC4", "AutoSAC4Enabled", ReplicatedStorage.Remote.FromLocalForServer.Get.sac4)

-- Auto Orb
FonctionsTab:Toggle({
    Title = "Auto Orb",
    Description = "Collecte automatique des orbes",
    Default = false,
    Callback = function(Value)
        Settings.AutoBringEnabled = Value
        
        if Value then
            task.spawn(function()
                while Settings.AutoBringEnabled do
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local addFolder = Workspace:FindFirstChild("Add")
                    if root and addFolder then
                        for _, item in pairs(addFolder:GetDescendants()) do
                            if item:IsA("BasePart") and item.Name:sub(1,1) == "B" then
                                if item.Parent then
                                    item.CanCollide = false
                                    item.AssemblyLinearVelocity = Vector3.new(0,0,0)
                                    item.AssemblyAngularVelocity = Vector3.new(0,0,0)
                                    item.CFrame = root.CFrame * CFrame.new(0, 3.5, 0)
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
})

-- Auto Equip Poids
FonctionsTab:Toggle({
    Title = "Auto Equip Poids",
    Description = "Équipe automatiquement l'outil 'Weight' (Instantané)",
    Default = false,
    Callback = function(Value)
        Settings.AutoEquipPoidsEnabled = Value
        
        if Value then
            task.spawn(function()
                while Settings.AutoEquipPoidsEnabled do
                    pcall(function()
                        local character = LocalPlayer.Character
                        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                        local backpack = LocalPlayer:FindFirstChild("Backpack")
                        
                        if humanoid and backpack then
                            if not character:FindFirstChild("Weight") then
                                local tool = backpack:FindFirstChild("Weight")
                                if tool then
                                    humanoid:EquipTool(tool)
                                end
                            end
                        end
                    end)
                    task.wait()
                end
            end)
        end
    end,
})

-- NOUVEAU : Auto Answer
FonctionsTab:Toggle({
    Title = "Auto Answer",
    Description = "Résout automatiquement les calculs dans le chat",
    Default = false,
    Callback = function(Value)
        SetupAutoAnswer(Value)
    end,
})

-- Slider pour le délai de réponse
FonctionsTab:Slider({
    Title = "Délai Réponse (sec)",
    Description = "Temps d'attente avant d'envoyer la réponse",
    Value = { Min = 0, Max = 5, Default = Settings.AnswerDelay },
    Callback = function(Value)
        Settings.AnswerDelay = Value
    end
})

-- ============================================
-- SECTION: POSITION
-- ============================================
local PositionTab = Window:Tab({
    Title = "Position",
    Icon = "map-pin",
})

local PosElement = PositionTab:Paragraph({
    Title = "Coordonnées Actuelles",
    Description = "X: 0\nY: 0\nZ: 0",
})

task.spawn(function()
    while task.wait(0.1) do
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        
        if root then
            local pos = root.Position
            local text = string.format("X: %.2f\nY: %.2f\nZ: %.2f", pos.X, pos.Y, pos.Z)
            PosElement:SetDesc(text)
        else
            PosElement:SetDesc("En attente du personnage...")
        end
    end
end)

PositionTab:Button({
    Title = "Copier la Position",
    Description = "Copie les coordonnées actuelles (Format: X, Y, Z)",
    Callback = function()
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        
        if root then
            local pos = root.Position
            local text = string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)
            
            if setclipboard then
                setclipboard(text)
            end
        end
    end,
})

local SavedCoords = ""

PositionTab:Input({
    Title = "Coordonnées Cibles",
    Description = "Collez ou entrez les coords (ex: 100, 50, 200)",
    Placeholder = "X, Y, Z",
    Callback = function(Value)
        SavedCoords = Value
    end
})

PositionTab:Toggle({
    Title = "Lock Position",
    Description = "Téléporte et maintient à la position indiquée",
    Default = false,
    Callback = function(Value)
        if TeleportLockConnection then
            TeleportLockConnection:Disconnect()
            TeleportLockConnection = nil
        end

        if Value then
            if SavedCoords == "" then return end
            
            local parts = string.split(SavedCoords, ",")
            if #parts == 3 then
                local x = tonumber(parts[1])
                local y = tonumber(parts[2])
                local z = tonumber(parts[3])
                
                if x and y and z then
                    TeleportLockConnection = RunService.RenderStepped:Connect(function()
                        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.CFrame = CFrame.new(x, y, z)
                        end
                    end)
                end
            end
        end
    end,
})

-- ============================================
-- SECTION: BOX
-- ============================================
local BoxTab = Window:Tab({
    Title = "Box",
    Icon = "box",
})

local BoxNames = {
    [1] = "Box1 [Free]",
    [2] = "Box2 [1k cash]",
    [3] = "Box3 [1m cash]",
    [4] = "Box4 [1t cash]",
    [5] = "Box5 [1sx cash]",
    [6] = "Box6 [0.1 asc]",
    [7] = "Box7 [100 asc]",
    [8] = "Box8 [1k asc]",
    [9] = "Box9 [10k asc]",
    [10] = "Box10 [40k asc]",
    [11] = "Box11 [400k asc]"
}

local function CreateBoxToggle(boxNumber)
    local settingKey = "AutoBox" .. boxNumber .. "Enabled"
    local boxInternalName = "Box" .. boxNumber
    local boxDisplayName = BoxNames[boxNumber]
    
    Settings[settingKey] = false

    BoxTab:Toggle({
        Title = boxDisplayName,
        Description = "Ouvre automatiquement " .. boxInternalName,
        Default = false,
        Callback = function(Value)
            Settings[settingKey] = Value
            
            if Value then
                task.spawn(function()
                    while Settings[settingKey] and task.wait(1) do
                        pcall(function()
                            local args = {
                                [1] = boxInternalName
                            }
                            game:GetService("ReplicatedStorage").Remote.FromServerForLocal.Box.AutoOpen:FireServer(unpack(args))
                        end)
                    end
                end)
            end
        end,
    })
end

for i = 1, 11 do
    CreateBoxToggle(i)
end

-- ============================================
-- SECTION: SETTINGS
-- ============================================
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings",
})

SettingsTab:Button({
    Title = "Reset All",
    Description = "Réinitialiser tout",
    Callback = function()
        -- Réinit variables
        Settings.WalkSpeed = 16
        Settings.JumpPower = 50
        Settings.Gravity = 196.2
        Settings.AutoBringEnabled = false
        Settings.AutoASC1Enabled = false
        Settings.AutoASC2Enabled = false
        Settings.AutoASC3Enabled = false
        Settings.AutoASC4Enabled = false
        Settings.AutoSAC1Enabled = false
        Settings.AutoSAC2Enabled = false
        Settings.AutoSAC3Enabled = false
        Settings.AutoSAC4Enabled = false
        Settings.InfiniteJump = false
        Settings.AutoEquipPoidsEnabled = false
        Settings.AutoAnswerEnabled = false
        
        for i = 1, 11 do
            Settings["AutoBox" .. i .. "Enabled"] = false
        end
        
        -- Nettoyage
        if JumpConnection then JumpConnection:Disconnect() JumpConnection = nil end
        if TeleportLockConnection then TeleportLockConnection:Disconnect() TeleportLockConnection = nil end
        SetupAutoAnswer(false) -- Stoppe les connexions du chat
        
        workspace.Gravity = 196.2
        local _, humanoid = GetCharacter()
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
    end,
})

-- ============================================
-- EVENTS
-- ============================================
LocalPlayer.CharacterAdded:Connect(function()
    ApplyCharacterSettings()
end)

print("[Celest Hub] Chargement terminé!")
