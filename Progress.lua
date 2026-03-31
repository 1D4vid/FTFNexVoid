return function(env)
    local Library = env.Library
    local ProgressPage = env.Page
    local Players = env.Players
    local RunService = env.RunService
    local CoreGui = env.CoreGui
    local ReplicatedStorage = env.ReplicatedStorage
    local Workspace = env.Workspace
    local LocalPlayer = env.LocalPlayer
    local TweenService = env.TweenService

    local CompVars = {Active = {}, Loop = nil}
    local getupActive = false
    local getupConns = {}
    local getupGui = nil
    local getupList = nil
    local activeGetUp = {}
    local activeTimers = {}
    local ExitDoorLoop = nil
    local activeExitDoors = {}
    local ED_COLORS = { RED = Color3.fromRGB(255, 50, 50), YELLOW = Color3.fromRGB(255, 200, 0), GREEN = Color3.fromRGB(50, 255, 100) }
    local BeastPowerConnection1 = nil
    local BeastPowerConnection2 = nil
    local uiFrameBP, uiLabelBP = nil, nil
    local trackedPowerValue = nil
    local lastPercent = 0
    local isDraining = false
    local BeastPowerLoop2
    
    local CONFIG_GETUP = {
        Font = Enum.Font.Garamond,
        NameColor = Color3.fromRGB(255, 255, 255),
        StrokeColor = Color3.fromRGB(0, 0, 0),
        StrokeThickness = 2.5
    }
    
    local function humanoid(p) return p and p.Character and p.Character:FindFirstChildOfClass("Humanoid") end
    local function ragdoll(p)
        local h = humanoid(p)
        if not h then return false end
        return h.PlatformStand or h:GetState() == Enum.HumanoidStateType.Physics
    end
    local function captured(p)
        local hrp = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        return hrp and hrp.Anchored
    end
    local function colorGetUp(t)
        local red = Color3.fromRGB(255, 0, 0) 
        local yellow = Color3.fromRGB(255, 220, 40)
        local green = Color3.fromRGB(60, 255, 60)
        if t > 0.5 then
            return yellow:Lerp(green, (t - 0.5) * 2)
        else
            return red:Lerp(yellow, t * 2)
        end
    end
    local function applyStroke(parent)
        local stroke = Instance.new("UIStroke")
        stroke.Color = CONFIG_GETUP.StrokeColor
        stroke.Thickness = CONFIG_GETUP.StrokeThickness
        stroke.Transparency = 0
        stroke.LineJoinMode = Enum.LineJoinMode.Round
        stroke.Parent = parent
        return stroke
    end
    
    -- Seção Principal: Chave compatível com tradução se adicionada lá depois (Timers & Indicators)
    Library:CreateSection(ProgressPage, "Timers & Indicators")
    
    local CompProgLoop = nil
    local ActiveComputers = {}

    Library:CreateToggle(ProgressPage, "Computer Progress", false, function(state) 
        if state then
            local function createProgressBar(parent)
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ProgressBar"
                billboard.Adornee = parent
                billboard.Size = UDim2.new(0, 120, 0, 30) 
                billboard.StudsOffset = Vector3.new(0, 4.5, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = parent

                local text = Instance.new("TextLabel")
                text.Name = "ProgressText"
                text.Size = UDim2.new(1, 0, 0, 15)
                text.Position = UDim2.new(0, 0, 0, 0)
                text.BackgroundTransparency = 1
                text.TextColor3 = Color3.fromRGB(255, 255, 255)
                text.TextStrokeTransparency = 0.2
                text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                text.Font = Enum.Font.GothamBold
                text.TextSize = 13
                text.Text = "0%"
                text.Parent = billboard

                local bgBar = Instance.new("Frame")
                bgBar.Name = "BgBar"
                bgBar.Size = UDim2.new(1, 0, 0, 5)
                bgBar.Position = UDim2.new(0, 0, 0, 18)
                bgBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                bgBar.BorderSizePixel = 0
                bgBar.Parent = billboard

                local bgCorner = Instance.new("UICorner")
                bgCorner.CornerRadius = UDim.new(1, 0)
                bgCorner.Parent = bgBar

                local stroke = Instance.new("UIStroke")
                stroke.Color = Color3.fromRGB(0, 0, 0)
                stroke.Thickness = 1.2
                stroke.Parent = bgBar

                local bar = Instance.new("Frame")
                bar.Name = "Bar"
                bar.Size = UDim2.new(0, 0, 1, 0)
                bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                bar.BorderSizePixel = 0
                bar.Parent = bgBar

                local barCorner = Instance.new("UICorner")
                barCorner.CornerRadius = UDim.new(1, 0)
                barCorner.Parent = bar

                return billboard, bar, text
            end

            local function setupComputer(tableModel)
                if tableModel:FindFirstChild("ProgressBar") or ActiveComputers[tableModel] then return end

                local billboard, bar, text = createProgressBar(tableModel)
                local highlight = tableModel:FindFirstChildOfClass("Highlight") or Instance.new("Highlight")
                highlight.Name = "ComputerHighlight"
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = tableModel

                local triggers = {}
                for _, part in ipairs(tableModel:GetChildren()) do
                    if part:IsA("BasePart") and part.Name:match("^ComputerTrigger") then
                        table.insert(triggers, part)
                    end
                end

                ActiveComputers[tableModel] = {
                    Bar = bar,
                    Text = text,
                    Highlight = highlight,
                    Screen = tableModel:FindFirstChild("Screen"),
                    Triggers = triggers,
                    SavedProgress = 0,
                    LastSize = -1
                }
            end

            CompProgLoop = task.spawn(function()
                local overlapParams = OverlapParams.new()
                overlapParams.FilterType = Enum.RaycastFilterType.Include
                local lastMapCheck = 0

                while state and task.wait(0.1) do
                    local now = os.clock()
                    
                    if now - lastMapCheck > 2 then
                        lastMapCheck = now
                        local currentMap = ReplicatedStorage:FindFirstChild("CurrentMap")
                        if currentMap and currentMap.Value ~= "" then
                            local map = Workspace:FindFirstChild(tostring(currentMap.Value))
                            if map then
                                for _, obj in ipairs(map:GetChildren()) do
                                    if obj.Name == "ComputerTable" then
                                        setupComputer(obj)
                                    end
                                end
                            end
                        end
                    end

                    local characterParts = {}
                    local playersList = Players:GetPlayers()
                    for i = 1, #playersList do
                        local char = playersList[i].Character
                        if char then
                            table.insert(characterParts, char)
                        end
                    end
                    overlapParams.FilterDescendantsInstances = characterParts

                    for tableModel, data in pairs(ActiveComputers) do
                        if not tableModel or not tableModel.Parent then
                            ActiveComputers[tableModel] = nil
                            continue
                        end

                        local isGreen = false
                        if data.Screen and data.Screen:IsA("BasePart") then
                            data.Highlight.FillColor = data.Screen.Color
                            data.Highlight.OutlineColor = data.Screen.Color
                            if data.Screen.Color.G > data.Screen.Color.R and data.Screen.Color.G > data.Screen.Color.B then
                                isGreen = true
                            end
                        end

                        if isGreen then
                            data.SavedProgress = 1
                        else
                            local highestTouch = 0
                            for i = 1, #data.Triggers do
                                local touchingParts = Workspace:GetPartsInPart(data.Triggers[i], overlapParams)
                                for j = 1, #touchingParts do
                                    local character = touchingParts[j].Parent
                                    local plr = Players:GetPlayerFromCharacter(character)
                                    if plr then
                                        local tpsm = plr:FindFirstChild("TempPlayerStatsModule")
                                        if tpsm then
                                            local ragdollVal = tpsm:FindFirstChild("Ragdoll")
                                            local apVal = tpsm:FindFirstChild("ActionProgress")
                                            if ragdollVal and typeof(ragdollVal.Value) == "boolean" and not ragdollVal.Value then
                                                if apVal and typeof(apVal.Value) == "number" then
                                                    highestTouch = math.max(highestTouch, apVal.Value)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            data.SavedProgress = math.max(data.SavedProgress, highestTouch)
                        end

                        if data.SavedProgress ~= data.LastSize then
                            data.LastSize = data.SavedProgress
                            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                            TweenService:Create(data.Bar, tweenInfo, {Size = UDim2.new(data.SavedProgress, 0, 1, 0)}):Play()
                        end

                        if data.SavedProgress >= 1 then
                            data.Bar.BackgroundColor3 = Color3.fromRGB(46, 204, 113) 
                            data.Text.TextColor3 = Color3.fromRGB(46, 204, 113)
                            data.Text.Text = "COMPLETED"
                        else
                            data.Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                            data.Text.TextColor3 = Color3.fromRGB(255, 255, 255)
                            data.Text.Text = string.format("%.1f%%", data.SavedProgress * 100)
                        end
                    end
                end
            end)
        else
            if CompProgLoop then task.cancel(CompProgLoop); CompProgLoop = nil end
            table.clear(ActiveComputers)
            
            for _, obj in ipairs(workspace:GetDescendants()) do
                if (obj.Name == "ProgressBar" and obj:IsA("BillboardGui")) or 
                   (obj.Name == "ComputerHighlight" and obj:IsA("Highlight")) then
                    obj:Destroy()
                end
            end
        end
    end)
    
    Library:CreateToggle(ProgressPage, "Door timer", false, function(state)
        if not getgenv().NexDoorTimer then
            getgenv().NexDoorTimer = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/doortimer.lua"))()
        end
        getgenv().NexDoorTimer.Toggle(state)
    end)
    
    Library:CreateToggle(ProgressPage, "GetUp Timer", false, function(state)
        getupActive = state
        if state then
            local DURATION = 28
            local function getUIContainer()
                local s, r = pcall(function() return game:GetService("CoreGui") end)
                return s and r or LocalPlayer:WaitForChild("PlayerGui")
            end
            
            local uiParent = getUIContainer()
            if uiParent:FindFirstChild("RagdollCounterGui") then uiParent.RagdollCounterGui:Destroy() end
            
            getupGui = Instance.new("ScreenGui")
            getupGui.Name = "RagdollCounterGui"
            getupGui.ResetOnSpawn = false
            getupGui.Parent = uiParent
            
            getupList = Instance.new("Frame", getupGui)
            getupList.Size = UDim2.new(0, 160, 0, 400)
            getupList.Position = UDim2.new(1, -60, 0.32, 0) 
            getupList.AnchorPoint = Vector2.new(1, 0) 
            getupList.BackgroundTransparency = 1
            
            local layout = Instance.new("UIListLayout", getupList)
            layout.VerticalAlignment = Enum.VerticalAlignment.Top
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            layout.Padding = UDim.new(0, 8)
            
            local function billboard(p)
                if p == LocalPlayer then return nil end 
                local h = p.Character and p.Character:FindFirstChild("Head")
                if not h then return end
                local old = h:FindFirstChild("RC")
                if old then old:Destroy() end
                
                local bb = Instance.new("BillboardGui", h)
                bb.Name = "RC"
                bb.Size = UDim2.new(5, 0, 3, 0) 
                bb.StudsOffset = Vector3.new(0, 3, 0) 
                bb.AlwaysOnTop = true
                
                local container = Instance.new("Frame", bb)
                container.Size = UDim2.fromScale(1, 1)
                container.BackgroundTransparency = 1
                
                local nameLbl = Instance.new("TextLabel", container)
                nameLbl.Size = UDim2.new(1, 0, 0.45, 0)
                nameLbl.Position = UDim2.new(0, 0, 0, 0)
                nameLbl.BackgroundTransparency = 1
                nameLbl.TextScaled = true
                nameLbl.Font = CONFIG_GETUP.Font
                nameLbl.TextColor3 = CONFIG_GETUP.NameColor
                nameLbl.TextStrokeTransparency = 1 
                nameLbl.Text = p.Name
                applyStroke(nameLbl) 
                
                local timeLbl = Instance.new("TextLabel", container)
                timeLbl.Size = UDim2.new(1, 0, 0.55, 0)
                timeLbl.Position = UDim2.new(0, 0, 0.45, 0) 
                timeLbl.BackgroundTransparency = 1
                timeLbl.TextScaled = true
                timeLbl.Font = CONFIG_GETUP.Font
                timeLbl.TextStrokeTransparency = 1
                applyStroke(timeLbl)
                
                return timeLbl
            end
            
            local function start(p)
                if activeGetUp[p] then return end
                activeGetUp[p] = os.clock()
                
                local headTimer = billboard(p)
                
                local playerFrame = Instance.new("Frame", getupList)
                playerFrame.Size = UDim2.new(1, 0, 0, 45) 
                playerFrame.BackgroundTransparency = 1
                
                local listName = Instance.new("TextLabel", playerFrame)
                listName.Size = UDim2.new(1, 0, 0.45, 0)
                listName.Position = UDim2.new(0, 0, 0, 0)
                listName.BackgroundTransparency = 1
                listName.Font = CONFIG_GETUP.Font
                listName.TextSize = 20
                listName.TextXAlignment = Enum.TextXAlignment.Right 
                listName.TextColor3 = CONFIG_GETUP.NameColor
                listName.TextStrokeTransparency = 1
                listName.Text = p.Name
                applyStroke(listName)
                
                local listTimer = Instance.new("TextLabel", playerFrame)
                listTimer.Size = UDim2.new(1, 0, 0.55, 0)
                listTimer.Position = UDim2.new(0, 0, 0.45, 0)
                listTimer.BackgroundTransparency = 1
                listTimer.Font = CONFIG_GETUP.Font
                listTimer.TextSize = 24
                listTimer.TextXAlignment = Enum.TextXAlignment.Right 
                listTimer.TextStrokeTransparency = 1
                applyStroke(listTimer)
                
                local con
                con = RunService.RenderStepped:Connect(function()
                    if not getupActive or not p.Parent or not ragdoll(p) or captured(p) then
                        if p.Character and p.Character:FindFirstChild("Head") then
                            local bb = p.Character.Head:FindFirstChild("RC")
                            if bb then bb:Destroy() end
                        end
                        playerFrame:Destroy()
                        activeGetUp[p] = nil
                        if con then con:Disconnect() end
                        return
                    end
                    local r = math.max(DURATION - (os.clock() - activeGetUp[p]), 0)
                    local c = colorGetUp(r / DURATION)
                    local timeString = string.format("%.3f", r)
                    
                    if headTimer and headTimer.Parent then
                        headTimer.Text = timeString
                        headTimer.TextColor3 = c
                    end
                    listTimer.Text = timeString
                    listTimer.TextColor3 = c
                    
                    if r <= 0 then
                        listTimer.Text = "0.000"
                        if headTimer then headTimer.Text = "0.000" end
                    end
                end)
                table.insert(getupConns, con)
            end
            
            local hb = task.spawn(function()
                while getupActive and task.wait(0.1) do 
                    for _, p in ipairs(Players:GetPlayers()) do
                        if not activeGetUp[p] and ragdoll(p) and not captured(p) then
                            task.spawn(start, p)
                        end
                    end
                end
            end)
            table.insert(getupConns, hb)
            
            local pr = Players.PlayerRemoving:Connect(function(p)
                if activeGetUp[p] then activeGetUp[p] = nil end
            end)
            table.insert(getupConns, pr)
        else
            getupActive = false
            for _, c in ipairs(getupConns) do
                if typeof(c) == "thread" then task.cancel(c) else c:Disconnect() end
            end
            table.clear(getupConns)
            if getupGui then getupGui:Destroy() getupGui = nil end
            activeGetUp = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Head") then
                    local bb = p.Character.Head:FindFirstChild("RC")
                    if bb then bb:Destroy() end
                end
            end
        end
    end)
    
    local ExitDoorConn = nil
    local ExitDoorAdded = nil
    local ExitDoorRemoving = nil
    Library:CreateToggle(ProgressPage, "ExitDoor Timer", false, function(state) 
        if state then
            local guiName = "FTF_ExitDoorESP_Premium"
            if CoreGui:FindFirstChild(guiName) then
                CoreGui[guiName]:Destroy()
            end

            local folder = Instance.new("Folder")
            folder.Name = guiName
            folder.Parent = CoreGui

            local trackedDoors = {}
            local actionValCache = {} 

            local function getPlayerProgress(plr)
                local actionVal = actionValCache[plr]
                if not actionVal or not actionVal.Parent then
                    actionVal = plr:FindFirstChild("ActionProgress", true)
                    if actionVal and actionVal:IsA("NumberValue") then
                        actionValCache[plr] = actionVal
                    else
                        actionValCache[plr] = nil
                    end
                end
                if actionVal then
                    return actionVal.Value
                end
                return 0
            end

            ExitDoorRemoving = Players.PlayerRemoving:Connect(function(plr)
                actionValCache[plr] = nil
            end)

            local function registerExitDoor(door)
                if trackedDoors[door] then return end 
                local mainPart = door.PrimaryPart
                local doorParts = {}
                local lightParts = {}
                local descendants = door:GetDescendants()
                for i = 1, #descendants do
                    local part = descendants[i]
                    if part:IsA("BasePart") then
                        table.insert(doorParts, part)
                        if not mainPart and part.Transparency < 1 then
                            mainPart = part
                        end
                        local lowerName = string.lower(part.Name)
                        if string.find(lowerName, "light", 1, true) or string.find(lowerName, "screen", 1, true) then
                            table.insert(lightParts, part)
                        end
                    end
                end
                if not mainPart then
                    mainPart = door:FindFirstChildWhichIsA("BasePart")
                end
                if not mainPart then return end

                local highlight = Instance.new("Highlight")
                highlight.Name = "DoorHighlight"
                highlight.Adornee = door 
                highlight.Parent = folder
                highlight.FillColor = Color3.fromRGB(255, 255, 0) 
                highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
                highlight.FillTransparency = 0.55
                highlight.OutlineTransparency = 0.1
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 

                local bgui = Instance.new("BillboardGui")
                bgui.Name = "UI"
                bgui.Size = UDim2.new(0, 170, 0, 55) 
                bgui.StudsOffset = Vector3.new(0, 11, 0)
                bgui.AlwaysOnTop = true
                bgui.ZIndexBehavior = Enum.ZIndexBehavior.Global 
                bgui.Adornee = mainPart
                bgui.Parent = folder
                
                local txt = Instance.new("TextLabel", bgui)
                txt.Name = "Text"
                txt.Size = UDim2.new(1, 0, 0.6, 0)
                txt.Position = UDim2.new(0, 0, 0, 0)
                txt.BackgroundTransparency = 1
                txt.Text = "EXIT"
                txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                txt.Font = Enum.Font.GothamBlack
                txt.TextSize = 14 
                txt.TextStrokeTransparency = 0 
                txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                
                local barBg = Instance.new("Frame", bgui)
                barBg.Name = "BarBg"
                barBg.Size = UDim2.new(0.8, 0, 0, 8) 
                barBg.Position = UDim2.new(0.1, 0, 0.7, 0) 
                barBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                barBg.BackgroundTransparency = 0.4
                barBg.BorderSizePixel = 0
                
                local bgCorner = Instance.new("UICorner", barBg)
                bgCorner.CornerRadius = UDim.new(1, 0)
                
                local bgStroke = Instance.new("UIStroke", barBg)
                bgStroke.Color = Color3.fromRGB(0, 0, 0)
                bgStroke.Thickness = 1.2
                bgStroke.Transparency = 0.2
                
                local fill = Instance.new("Frame", barBg)
                fill.Name = "Fill"
                fill.Size = UDim2.new(0, 0, 1, 0)
                fill.BackgroundColor3 = Color3.fromRGB(255, 255, 0) 
                fill.BorderSizePixel = 0
                
                local fillCorner = Instance.new("UICorner", fill)
                fillCorner.CornerRadius = UDim.new(1, 0)
                
                trackedDoors[door] = {
                    UI = bgui,
                    Highlight = highlight, 
                    Progress = 0,
                    Completed = false,
                    MainPart = mainPart,
                    DoorParts = doorParts,
                    LightParts = lightParts,
                    TextElement = txt,
                    FillElement = fill
                }
            end

            task.spawn(function()
                local workspaceDescendants = workspace:GetDescendants()
                for i = 1, #workspaceDescendants do
                    local obj = workspaceDescendants[i]
                    if string.lower(obj.Name) == "exitdoor" and obj:IsA("Model") then
                        registerExitDoor(obj)
                    end
                end
            end)

            ExitDoorAdded = workspace.DescendantAdded:Connect(function(obj)
                if string.lower(obj.Name) == "exitdoor" and obj:IsA("Model") then
                    task.defer(function()
                        registerExitDoor(obj)
                    end)
                end
            end)

            ExitDoorConn = task.spawn(function()
                while state and task.wait(0.1) do
                    local openingNow = {}
                    local playersList = Players:GetPlayers()

                    for i = 1, #playersList do
                        local plr = playersList[i]
                        local char = plr.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        
                        if hrp then
                            local currentProgress = getPlayerProgress(plr)
                            
                            if currentProgress > 0 then
                                local plrPos = hrp.Position
                                local closestDoor = nil
                                local minDist = 12
                                
                                for door, data in pairs(trackedDoors) do
                                    if door.Parent and data.MainPart and data.MainPart.Parent then
                                        local dist = (data.MainPart.Position - plrPos).Magnitude
                                        if dist < minDist then
                                            minDist = dist
                                            closestDoor = door
                                        end
                                    end
                                end
                                
                                if closestDoor then
                                    openingNow[closestDoor] = currentProgress
                                end
                            end
                        end
                    end

                    for door, data in pairs(trackedDoors) do
                        if not door.Parent then
                            data.UI:Destroy()
                            if data.Highlight then data.Highlight:Destroy() end 
                            trackedDoors[door] = nil
                            continue
                        end
                        
                        if not data.MainPart or not data.MainPart.Parent then
                            local newMain = nil
                            for i = 1, #data.DoorParts do
                                local p = data.DoorParts[i]
                                if p.Parent and p:IsA("BasePart") and p.Name ~= "Trigger" then
                                    newMain = p
                                    break
                                end
                            end
                            
                            if newMain then
                                data.MainPart = newMain
                                data.UI.Adornee = newMain
                            else
                                data.UI:Destroy()
                                if data.Highlight then data.Highlight:Destroy() end
                                trackedDoors[door] = nil
                                continue
                            end
                        end
                        
                        local nativelyOpen = false
                        local lParts = data.LightParts
                        
                        for i = 1, #lParts do
                            local part = lParts[i]
                            if part.Parent and string.find(string.lower(part.BrickColor.Name), "green", 1, true) then
                                nativelyOpen = true
                                break
                            end
                        end
                        
                        if nativelyOpen then
                            data.Completed = true
                            data.Progress = 1
                        else
                            data.Completed = false
                            if openingNow[door] then
                                data.Progress = openingNow[door]
                                if data.Progress > 0.99 then
                                    data.Progress = 0.99
                                end
                            else
                                data.Progress = 0
                            end
                        end
                        
                        if data.Completed then
                            data.FillElement.Size = UDim2.new(1, 0, 1, 0)
                            data.FillElement.BackgroundColor3 = Color3.fromRGB(40, 255, 80)
                            data.TextElement.Text = "DOOR OPENED!"
                            data.TextElement.TextColor3 = Color3.fromRGB(40, 255, 80)
                            
                            data.Highlight.FillColor = Color3.fromRGB(40, 255, 80)
                            data.Highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
                        else
                            data.FillElement.Size = UDim2.new(data.Progress, 0, 1, 0)
                            data.FillElement.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                            
                            data.Highlight.FillColor = Color3.fromRGB(255, 255, 0)
                            data.Highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
                            
                            if data.Progress > 0 then
                                data.TextElement.Text = "OPENING: " .. math.floor(data.Progress * 100) .. "%"
                                data.TextElement.TextColor3 = Color3.fromRGB(255, 255, 0)
                            else
                                data.TextElement.Text = "EXIT"
                                data.TextElement.TextColor3 = Color3.fromRGB(255, 255, 255)
                            end
                        end
                    end
                end
            end)
        else
            if ExitDoorRemoving then ExitDoorRemoving:Disconnect(); ExitDoorRemoving = nil end
            if ExitDoorAdded then ExitDoorAdded:Disconnect(); ExitDoorAdded = nil end
            if ExitDoorConn then task.cancel(ExitDoorConn); ExitDoorConn = nil end
            if CoreGui:FindFirstChild("FTF_ExitDoorESP_Premium") then CoreGui.FTF_ExitDoorESP_Premium:Destroy() end
        end
    end)
    
    Library:CreateToggle(ProgressPage, "BeastPower timer", false, function(state) 
        if state then
            local function getUIContainer()
                local success, result = pcall(function() return CoreGui end)
                if success then return result else return LocalPlayer:WaitForChild("PlayerGui") end
            end
            local container = getUIContainer()
            
            if container:FindFirstChild("BeastTextHUD") then
                container.BeastTextHUD:Destroy()
            end

            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "BeastTextHUD"
            screenGui.IgnoreGuiInset = true
            screenGui.ResetOnSpawn = false
            screenGui.Parent = container

            uiFrameBP = Instance.new("Frame")
            uiFrameBP.Name = "MainFrame"
            uiFrameBP.AnchorPoint = Vector2.new(0.5, 1)
            uiFrameBP.Position = UDim2.new(0.5, 0, 0.85, 0) 
            uiFrameBP.Size = UDim2.new(0, 0, 0, 30) 
            uiFrameBP.AutomaticSize = Enum.AutomaticSize.X 
            uiFrameBP.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            uiFrameBP.BackgroundTransparency = 0.5 
            uiFrameBP.BorderSizePixel = 0 
            uiFrameBP.Visible = false
            uiFrameBP.Parent = screenGui

            local uiCorner = Instance.new("UICorner")
            uiCorner.CornerRadius = UDim.new(0, 6) 
            uiCorner.Parent = uiFrameBP

            local uiPadding = Instance.new("UIPadding")
            uiPadding.PaddingLeft = UDim.new(0, 10) 
            uiPadding.PaddingRight = UDim.new(0, 10) 
            uiPadding.Parent = uiFrameBP

            uiLabelBP = Instance.new("TextLabel")
            uiLabelBP.Name = "StatusText"
            uiLabelBP.Size = UDim2.new(0, 0, 1, 0) 
            uiLabelBP.AutomaticSize = Enum.AutomaticSize.X
            uiLabelBP.BackgroundTransparency = 1
            uiLabelBP.Text = "Carregando..."
            uiLabelBP.TextColor3 = Color3.fromRGB(255, 255, 255) 
            uiLabelBP.Font = Enum.Font.GothamBold 
            uiLabelBP.TextSize = 18 
            uiLabelBP.TextXAlignment = Enum.TextXAlignment.Center
            uiLabelBP.Parent = uiFrameBP
            
            trackedPowerValue = nil
            lastPercent = 0
            isDraining = false

            BeastPowerConnection1 = task.spawn(function()
                while state and task.wait(1) do
                    local foundValue = nil
                    for _, player in ipairs(Players:GetPlayers()) do
                        local char = player.Character
                        if char then
                            local beastPowers = char:FindFirstChild("BeastPowers")
                            if beastPowers then
                                foundValue = beastPowers:FindFirstChildOfClass("NumberValue", true)
                                if foundValue then
                                    break 
                                end
                            end
                        end
                    end
                    trackedPowerValue = foundValue 
                end
            end)

            BeastPowerConnection2 = RunService.RenderStepped:Connect(function()
                if trackedPowerValue and trackedPowerValue.Parent then
                    uiFrameBP.Visible = true
                    
                    local percent = math.clamp(trackedPowerValue.Value, 0, 1)
                    local percentInt = math.floor(percent * 100)
                    
                    uiLabelBP.Text = "BeastPower Back In: " .. percentInt .. "%"
                    
                    if percent < lastPercent then
                        isDraining = true 
                    elseif percent > lastPercent then
                        isDraining = false 
                    end
                    
                    lastPercent = percent 
                    
                    if isDraining then
                        uiLabelBP.TextColor3 = Color3.fromRGB(255, 255, 255)
                    else
                        if percent >= 0.99 then
                            uiLabelBP.TextColor3 = Color3.fromRGB(50, 255, 50) 
                        elseif percent >= 0.80 then
                            uiLabelBP.TextColor3 = Color3.fromRGB(255, 50, 50) 
                        else
                            uiLabelBP.TextColor3 = Color3.fromRGB(255, 255, 255) 
                        end
                    end
                else
                    if uiFrameBP then uiFrameBP.Visible = false end
                    lastPercent = 0 
                    isDraining = false
                end
            end)
        else
            if BeastPowerConnection1 then task.cancel(BeastPowerConnection1); BeastPowerConnection1 = nil end
            if BeastPowerConnection2 then BeastPowerConnection2:Disconnect(); BeastPowerConnection2 = nil end
            if uiFrameBP and uiFrameBP.Parent then uiFrameBP.Parent:Destroy() end
        end
    end)
    
	Library:CreateToggle(ProgressPage, "BeastPower Timer V2", false, function(state) 
        local function CreateLabelBP(player)
            local character = player.Character
            if character then
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local billboard = humanoidRootPart:FindFirstChild("BeastPowerBillboard")
                    if not billboard then
                        billboard = Instance.new("BillboardGui")
                        billboard.Name = "BeastPowerBillboard"
                        billboard.Size = UDim2.new(2, 0, 1, 0)
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        billboard.AlwaysOnTop = true
                        billboard.MaxDistance = math.huge
                        billboard.LightInfluence = 1
                        billboard.Parent = humanoidRootPart
                        local label = Instance.new("TextLabel")
                        label.Name = "BeastPowerLabel"
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Font = Enum.Font.Arcade
                        label.TextSize = 20
                        label.Text = ""
                        label.TextStrokeTransparency = 0.5
                        label.TextColor3 = Color3.new(1, 1, 1)
                        label.TextStrokeColor3 = Color3.new(0, 0, 0)
                        label.Parent = billboard
                    end
                    return billboard.BeastPowerLabel
                end
            end
            return nil
        end
        if state then
            BeastPowerLoop2 = task.spawn(function()
                while state do
                    task.wait(0.5)
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            local label = CreateLabelBP(player)
                            if label then
                                local beastPowers = player.Character:FindFirstChild("BeastPowers")
                                if beastPowers then
                                    local numberValue = beastPowers:FindFirstChildOfClass("NumberValue")
                                    if numberValue then
                                        local roundedValue = math.round(numberValue.Value * 100)
                                        label.Text = tostring(roundedValue) .. "%"
                                    else
                                        label.Text = ""
                                    end
                                else
                                    label.Text = ""
                                end
                            end
                        end
                    end
                end
            end)
        else
            if BeastPowerLoop2 then task.cancel(BeastPowerLoop2) BeastPowerLoop2 = nil end
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local bb = player.Character.HumanoidRootPart:FindFirstChild("BeastPowerBillboard")
                    if bb then bb:Destroy() end
                end
            end
        end
    end)
end
