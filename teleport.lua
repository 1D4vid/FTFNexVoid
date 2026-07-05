return function(env)
    local Library = env.Library
    local TeleportPage = env.Page
    local Players = env.Players
    local Workspace = env.Workspace
    local LocalPlayer = env.LocalPlayer
    local Theme = env.Theme or {
        Accent = Color3.fromRGB(240, 240, 240),
        ItemStroke = Color3.fromRGB(60, 60, 60),
        Font = Enum.Font.GothamBold
    }
    local ScreenGui = env.ScreenGui
    local SendNotification = env.SendNotification
    local UserInputService = env.UserInputService or game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local TeleportService = game:GetService("TeleportService")

    local string_lower = string.lower
    local string_find = string.find
    local Vector3_new = Vector3.new
    local CFrame_new = CFrame.new
    local CFrame_Angles = CFrame.Angles
    local Color3_fromRGB = Color3.fromRGB
    local Color3_new = Color3.new
    local UDim2_new = UDim2.new
    local UDim_new = UDim.new
    local Instance_new = Instance.new
    local task_spawn = task.spawn
    local task_delay = task.delay
    local ipairs = ipairs
    local pairs = pairs
    local math_rad = math.rad

    local BEAST_WEAPON_NAMES = {
        ["Hammer"] = true,
        ["Gemstone Hammer"] = true,
        ["Iron Hammer"] = true,
        ["Mallet"] = true
    }

    local RAD_90 = math_rad(90)
    local whiteColor = Color3_fromRGB(255, 255, 255)
    local grayColor = Color3_fromRGB(150, 150, 150)
    local markerColor = Color3_fromRGB(0, 255, 128)
    local hoverInInfo = TweenInfo.new(0.15)
    local hoverOutInfo = TweenInfo.new(0.15)
    local hoverInGoal = {BackgroundColor3 = Color3_fromRGB(255, 255, 255)}
    local hoverOutGoal = {BackgroundColor3 = Color3_fromRGB(245, 245, 245)}

    local function teleportToLandmark(nameQuery)
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local lowerQuery = string_lower(nameQuery)
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                if string_find(string_lower(obj.Name), lowerQuery) then
                    local targetCFrame = obj:IsA("Model") and obj:GetPivot() or obj.CFrame
                    hrp.CFrame = targetCFrame + Vector3_new(0, 4, 0)
                    SendNotification("Teleported to " .. nameQuery .. "!", 2)
                    return
                end
            end
        end
        SendNotification(nameQuery .. " not found on this map!", 2)
    end

    local function getBeastRoot()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local backpack = p:FindFirstChild("Backpack")
                local character = p.Character
                local isBst = false
                
                if p.Team and p.Team.Name == "Beast" then
                    isBst = true
                else
                    for name in pairs(BEAST_WEAPON_NAMES) do
                        if (backpack and backpack:FindFirstChild(name)) or (character and character:FindFirstChild(name)) then
                            isBst = true
                            break
                        end
                    end
                end
                
                if isBst and character then
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        return hrp
                    end
                end
            end
        end
        return nil
    end

    Library:CreateSection(TeleportPage, "Map Objects", "Left")
    
    local currentPCIndex = 0
    Library:CreateButton(TeleportPage, "TP Computer", function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local pcs = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "ComputerTable" then
                pcs[#pcs + 1] = obj
            end
        end
        
        if #pcs == 0 then
            SendNotification("Map not loaded!", 2)
            return
        end
        
        currentPCIndex = (currentPCIndex % #pcs) + 1
        local pc = pcs[currentPCIndex]
        local pcCFrame
        if pc:IsA("Model") then
            pcCFrame = pc:GetPivot()
        else
            local part = pc:FindFirstChildWhichIsA("BasePart")
            if part then
                pcCFrame = part.CFrame
            end
        end
        
        if pcCFrame then
            hrp.CFrame = pcCFrame * CFrame_new(0, 3, -3)
        end
    end)

    local currentDoorIndex = 0
    Library:CreateButton(TeleportPage, "TP Exitdoor", function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local doors = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local name = string_lower(obj.Name)
                if string_find(name, "exit") and string_find(name, "door") then
                    doors[#doors + 1] = obj
                end
            end
        end
        
        if #doors == 0 then
            SendNotification("ExitDoors not found!", 2)
            return
        end
        
        currentDoorIndex = (currentDoorIndex % #doors) + 1
        local door = doors[currentDoorIndex]
        local part = door.PrimaryPart or door:FindFirstChildWhichIsA("BasePart")
        if part then
            hrp.CFrame = part.CFrame + Vector3_new(0, 3, 0)
        end
    end)

    local currentPodIndex = 0
    Library:CreateButton(TeleportPage, "TP Freezepods", function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local pods = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "FreezePod" then
                pods[#pods + 1] = obj
            end
        end
        
        if #pods == 0 then
            SendNotification("Map not loaded!", 2)
            return
        end
        
        currentPodIndex = (currentPodIndex % #pods) + 1
        local pod = pods[currentPodIndex]
        local base = pod:FindFirstChild("BasePart") or pod:FindFirstChildWhichIsA("Part")
        if base then
            hrp.CFrame = base.CFrame * CFrame_new(0, 1, -3)
        end
    end)

    Library:CreateButton(TeleportPage, "TP Crystal Cove", function()
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame_new(347.5, 51.0, -455.5)
            end
        end
    end)

    Library:CreateButton(TeleportPage, "TP Beast Cave", function()
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame_new(-216.5, 1.5, -223.5)
            end
        end
    end)

    Library:CreateButton(TeleportPage, "Tp Map", function()
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, v in ipairs(Workspace:GetDescendants()) do
                    local name = v.Name
                    if name == "ComputerTable" or name == "FreezePod" or name == "ExitGate" then
                        local part = v:FindFirstChildWhichIsA("BasePart")
                        if part then
                            hrp.CFrame = part.CFrame + Vector3_new(0, 3, 0)
                            break
                        end
                    end
                end
            end
        end
    end)

    Library:CreateSection(TeleportPage, "Extras", "Right")

    local savedCFrame = nil
    local checkpointMarker = nil
    local tpKeybindConn = nil

    local CheckpointFrame = ScreenGui:FindFirstChild("CheckpointFrame")
    if CheckpointFrame then CheckpointFrame:Destroy() end

    CheckpointFrame = Instance_new("Frame")
    CheckpointFrame.Name = "CheckpointFrame"
    CheckpointFrame.Size = UDim2_new(0, 40, 0, 90)
    CheckpointFrame.Position = UDim2_new(0, 2, 0.5, -45)
    CheckpointFrame.BackgroundTransparency = 1
    CheckpointFrame.Visible = false
    CheckpointFrame.ZIndex = 50
    CheckpointFrame.Parent = ScreenGui

    local CPListLayout = Instance_new("UIListLayout")
    CPListLayout.Parent = CheckpointFrame
    CPListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    CPListLayout.Padding = UDim_new(0, 8)

    local SetBtn = Instance_new("ImageButton")
    SetBtn.Size = UDim2_new(1, 0, 0, 40)
    SetBtn.BackgroundTransparency = 1
    SetBtn.Image = "rbxassetid://6723742952"
    SetBtn.Parent = CheckpointFrame

    local TpBtn = Instance_new("ImageButton")
    TpBtn.Size = UDim2_new(1, 0, 0, 40)
    TpBtn.BackgroundTransparency = 1
    TpBtn.Image = "rbxassetid://6723921202"
    TpBtn.Parent = CheckpointFrame

    SetBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                savedCFrame = hrp.CFrame
                if checkpointMarker then checkpointMarker:Destroy() end
                checkpointMarker = Instance_new("Part")
                checkpointMarker.Name = "FleeCheckpointMarker"
                checkpointMarker.Shape = Enum.PartType.Cylinder
                checkpointMarker.Size = Vector3_new(0.2, 4, 4)
                checkpointMarker.CFrame = savedCFrame * CFrame_new(0, -2.5, 0) * CFrame_Angles(0, 0, RAD_90)
                checkpointMarker.Anchored = true
                checkpointMarker.CanCollide = false
                checkpointMarker.Material = Enum.Material.Neon
                checkpointMarker.Color = markerColor
                checkpointMarker.Transparency = 0.4
                checkpointMarker.Parent = Workspace
                
                local light = Instance_new("PointLight")
                light.Color = checkpointMarker.Color
                light.Range = 8
                light.Brightness = 2
                light.Parent = checkpointMarker

                SetBtn.ImageColor3 = grayColor
                task_delay(0.15, function() SetBtn.ImageColor3 = whiteColor end)
                SendNotification("Checkpoint Set!", 2)
            end
        end
    end)

    TpBtn.MouseButton1Click:Connect(function()
        if savedCFrame then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = savedCFrame
                    TpBtn.ImageColor3 = grayColor
                    task_delay(0.15, function() TpBtn.ImageColor3 = whiteColor end)
                end
            end
        else
            SendNotification("No checkpoint set!", 2)
        end
    end)

    Library:CreateToggle(TeleportPage, "Checkpoint (UI+R)", false, function(state)
        CheckpointFrame.Visible = state 
        if state then
            if not tpKeybindConn then
                tpKeybindConn = UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if input.KeyCode == Enum.KeyCode.R and savedCFrame then
                        local char = LocalPlayer.Character
                        if char then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.CFrame = savedCFrame
                            end
                        end
                    end
                end)
            end
        else
            if tpKeybindConn then tpKeybindConn:Disconnect() tpKeybindConn = nil end
            if checkpointMarker then checkpointMarker:Destroy() checkpointMarker = nil end
            savedCFrame = nil
        end
    end)

    Library:CreateButton(TeleportPage, "Reset Character", function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
    end)

    Library:CreateButton(TeleportPage, "Server Rejoin", function()
        if #Players:GetPlayers() <= 1 then
            LocalPlayer:Kick("\nRejoining...")
            task_delay(0.1, function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)

    Library:CreateButton(TeleportPage, "Random Servers", function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)

    Library:CreateButton(TeleportPage, "Teleport to Beast", function()
        local beastRoot = getBeastRoot()
        if beastRoot then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = beastRoot.CFrame + Vector3_new(0, 3, 0)
                    SendNotification("Teleported to Beast!", 2)
                end
            end
        else
            SendNotification("Beast not found or not spawned!", 2)
        end
    end)

    local LeftCol = TeleportPage:FindFirstChild("LeftCol")
    local RightCol = TeleportPage:FindFirstChild("RightCol")

    if LeftCol and RightCol then
        local origLayout = TeleportPage:FindFirstChildOfClass("UIListLayout")
        if origLayout then origLayout:Destroy() end

        local pageListLayout = Instance_new("UIListLayout")
        pageListLayout.FillDirection = Enum.FillDirection.Vertical
        pageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageListLayout.Padding = UDim_new(0, 10)
        pageListLayout.Parent = TeleportPage

        local TopColumnsContainer = Instance_new("Frame")
        TopColumnsContainer.Name = "TopColumnsContainer"
        TopColumnsContainer.Size = UDim2_new(1, 0, 0, 0)
        TopColumnsContainer.AutomaticSize = Enum.AutomaticSize.Y
        TopColumnsContainer.BackgroundTransparency = 1
        TopColumnsContainer.LayoutOrder = 1
        TopColumnsContainer.Parent = TeleportPage

        local hLayout = Instance_new("UIListLayout")
        hLayout.FillDirection = Enum.FillDirection.Horizontal
        hLayout.SortOrder = Enum.SortOrder.LayoutOrder
        hLayout.Padding = UDim_new(0, 12)
        hLayout.Parent = TopColumnsContainer

        LeftCol.Size = UDim2_new(0.5, -6, 0, 0)
        LeftCol.AutomaticSize = Enum.AutomaticSize.Y
        LeftCol.Parent = TopColumnsContainer
        LeftCol.LayoutOrder = 1

        RightCol.Size = UDim2_new(0.5, -6, 0, 0)
        RightCol.AutomaticSize = Enum.AutomaticSize.Y
        RightCol.Parent = TopColumnsContainer
        RightCol.LayoutOrder = 2
    end

    local PlayersSection = Instance_new("Frame")
    PlayersSection.Name = "PlayersTeleportSection"
    PlayersSection.Size = UDim2_new(1, -2, 0, 0)
    PlayersSection.AutomaticSize = Enum.AutomaticSize.Y
    PlayersSection.BackgroundColor3 = Color3_new(0, 0, 0)
    PlayersSection.BackgroundTransparency = 0.45
    PlayersSection.BorderSizePixel = 0
    PlayersSection.LayoutOrder = 2
    PlayersSection.Parent = TeleportPage

    Instance_new("UICorner", PlayersSection).CornerRadius = UDim_new(0, 6)
    local pStroke = Instance_new("UIStroke", PlayersSection)
    pStroke.Color = Color3_fromRGB(40, 40, 40)
    pStroke.Thickness = 1

    local pLayout = Instance_new("UIListLayout", PlayersSection)
    pLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pLayout.Padding = UDim_new(0, 4)

    local pPadding = Instance_new("UIPadding", PlayersSection)
    pPadding.PaddingTop = UDim_new(0, 8)
    pPadding.PaddingBottom = UDim_new(0, 8)
    pPadding.PaddingLeft = UDim_new(0, 10)
    pPadding.PaddingRight = UDim_new(0, 10)

    local HeaderContainer = Instance_new("Frame")
    HeaderContainer.Name = "HeaderContainer"
    HeaderContainer.Size = UDim2_new(1, 0, 0, 20)
    HeaderContainer.BackgroundTransparency = 1
    HeaderContainer.LayoutOrder = 1
    HeaderContainer.Parent = PlayersSection

    local HeaderLabel = Instance_new("TextLabel")
    HeaderLabel.Size = UDim2_new(1, 0, 1, 0)
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.Text = "Players Teleport"
    HeaderLabel.Font = Theme.Font
    HeaderLabel.TextSize = 12
    HeaderLabel.TextColor3 = Color3_fromRGB(255, 255, 255)
    HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeaderLabel.Parent = HeaderContainer

    local RefreshBtn = Instance_new("TextButton")
    RefreshBtn.Name = "RefreshBtnStatic"
    RefreshBtn.Size = UDim2_new(1, 0, 0, 26)
    RefreshBtn.BackgroundColor3 = Color3_fromRGB(0, 0, 0)
    RefreshBtn.BackgroundTransparency = 0.55
    RefreshBtn.Text = "Refresh"
    RefreshBtn.TextColor3 = Theme.Accent
    RefreshBtn.Font = Theme.Font
    RefreshBtn.TextSize = 11
    RefreshBtn.LayoutOrder = 2
    RefreshBtn.Parent = PlayersSection
    Instance_new("UICorner", RefreshBtn).CornerRadius = UDim_new(0, 5)
    local rStr = Instance_new("UIStroke", RefreshBtn)
    rStr.Color = Color3_fromRGB(60, 60, 60)
    rStr.Thickness = 1

    local function CreateCustomPlayerRow(parent, player, layoutOrderIndex)
        local Row = Instance_new("Frame")
        Row.Name = "PlayerRow"
        Row.Size = UDim2_new(1, 0, 0, 44)
        Row.BackgroundTransparency = 1
        Row.BorderSizePixel = 0
        Row.LayoutOrder = layoutOrderIndex
        Row.Parent = parent

        local Avatar = Instance_new("ImageLabel")
        Avatar.Size = UDim2_new(0, 32, 0, 32)
        Avatar.Position = UDim2_new(0, 4, 0.5, -16)
        Avatar.BackgroundColor3 = Color3_fromRGB(20, 20, 20)
        Avatar.BackgroundTransparency = 0.3
        Avatar.Parent = Row
        Instance_new("UICorner", Avatar).CornerRadius = UDim_new(0, 6)

        task_spawn(function()
            local content, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            if isReady then Avatar.Image = content end
        end)

        local Display = Instance_new("TextLabel")
        Display.Text = player.DisplayName
        Display.Size = UDim2_new(1, -140, 0, 16)
        Display.Position = UDim2_new(0, 44, 0, 4)
        Display.BackgroundTransparency = 1
        Display.Font = Enum.Font.GothamBold
        Display.TextSize = 12
        Display.TextColor3 = Color3_fromRGB(255, 255, 255)
        Display.TextXAlignment = Enum.TextXAlignment.Left
        Display.Parent = Row

        local User = Instance_new("TextLabel")
        User.Text = "@" .. player.Name
        User.Size = UDim2_new(1, -140, 0, 14)
        User.Position = UDim2_new(0, 44, 0, 20)
        User.BackgroundTransparency = 1
        User.Font = Enum.Font.Gotham
        User.TextSize = 10
        User.TextColor3 = Color3_fromRGB(150, 150, 150)
        User.TextXAlignment = Enum.TextXAlignment.Left
        User.Parent = Row

        local TpBtn = Instance_new("TextButton")
        TpBtn.Size = UDim2_new(0, 80, 0, 26)
        TpBtn.Position = UDim2_new(1, -84, 0.5, -13)
        TpBtn.BackgroundColor3 = Color3_fromRGB(245, 245, 245)
        TpBtn.Text = "Teleport"
        TpBtn.Font = Enum.Font.GothamBold
        TpBtn.TextSize = 11
        TpBtn.TextColor3 = Color3_fromRGB(15, 15, 15)
        TpBtn.Parent = Row

        Instance_new("UICorner", TpBtn).CornerRadius = UDim_new(0, 5)

        local btnStroke = Instance_new("UIStroke")
        btnStroke.Color = Color3_fromRGB(180, 180, 180)
        btnStroke.Thickness = 1
        btnStroke.Parent = TpBtn

        local btnGrad = Instance_new("UIGradient")
        btnGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3_fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3_fromRGB(215, 215, 215))
        }
        btnGrad.Rotation = 90
        btnGrad.Parent = TpBtn

        TpBtn.MouseEnter:Connect(function()
            TweenService:Create(TpBtn, hoverInInfo, hoverInGoal):Play()
        end)
        TpBtn.MouseLeave:Connect(function()
            TweenService:Create(TpBtn, hoverOutInfo, hoverOutGoal):Play()
        end)

        TpBtn.MouseButton1Click:Connect(function()
            local targetChar = player.Character
            local localChar = LocalPlayer.Character
            if targetChar and localChar then
                local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                local localHrp = localChar:FindFirstChild("HumanoidRootPart")
                if targetHrp and localHrp then
                    localHrp.CFrame = targetHrp.CFrame + Vector3_new(0, 2, 0)
                end
            end
        end)
    end

    local function UpdateTeleportList()
        for _, child in ipairs(PlayersSection:GetChildren()) do 
            if child.Name == "PlayerRow" then 
                child:Destroy() 
            end 
        end
        local index = 3
        for _, player in ipairs(Players:GetPlayers()) do 
            if player ~= LocalPlayer then 
                CreateCustomPlayerRow(PlayersSection, player, index)
                index = index + 1
            end 
        end
    end

    RefreshBtn.MouseButton1Click:Connect(function() 
        UpdateTeleportList() 
    end)

    UpdateTeleportList()
end
