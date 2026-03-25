return function(Library, Page, UserConfigs)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local Workspace = game:GetService("Workspace")
    local CoreGui = game:GetService("CoreGui")
    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

    local stretchConnection = nil
    local BlackFogLoop = nil
    local OriginalAtmosphereData = nil
    local grayConns = {}
    local grayCache = {} 

    local HideLeavesConnection = nil
    local hiddenParts = {} 
    local currentFont = "Default"
    local originalFonts = {}
    local originalName = LocalPlayer.Name
    local originalDisplayName = LocalPlayer.DisplayName
    local originalLevel = "1"
    local spoofName = LocalPlayer.Name
    local spoofLevel = 67
    local spoofIconId = "rbxassetid://1188562340"
    local spoofVisualsEnabled = false
    local spoofVisualsLoop

    local meusIcones = {
        VIP = "rbxassetid://1188562340",
        QA = "rbxassetid://105177418407648",
        CON = "rbxassetid://76898592264692",
        Mod = "rbxassetid://105155010224102",
        Dev = "rbxassetid://18940006678",
        Manager = "rbxassetid://131476591459702",
        MrWindy = "rbxassetid://18937953345",
        Nenhum = ""
    }
    
    local originalTexts = setmetatable({}, {__mode = "k"})
    local trackersInitialized = false

    Library:CreateSection(Page, "Client Modifications")
    Library:CreateToggle(Page, "FpsBooster", false, function(state) 
        if not getgenv().NexOptimization then
            getgenv().NexOptimization = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/fps%20booster%20e%20remove%20textures.lua"))()
        end
        getgenv().NexOptimization.ToggleFPSBooster(state)
    end)

    Library:CreateToggle(Page, "Gray characters", false, function(state) 
        if state then
            local GRAY_COLOR = Color3.fromRGB(150, 150, 150)

            local function cleanObject(obj, char)
                if obj:FindFirstAncestorWhichIsA("Tool") then return end
                
                if obj:IsA("CharacterMesh") then return end

                if not grayCache[char] then grayCache[char] = { instances = {}, props = {} } end
                local cache = grayCache[char]

                if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("BodyColors") or obj:IsA("Decal") then
                    table.insert(cache.instances, {obj = obj, parent = obj.Parent})
                    obj.Parent = nil
                elseif obj:IsA("BasePart") then
                    table.insert(cache.props, {obj = obj, prop = "Color", val = obj.Color})
                    table.insert(cache.props, {obj = obj, prop = "Material", val = obj.Material})
                    obj.Color = GRAY_COLOR
                    obj.Material = Enum.Material.SmoothPlastic
                    
                    if obj:IsA("MeshPart") then
                        table.insert(cache.props, {obj = obj, prop = "TextureID", val = obj.TextureID})
                        obj.TextureID = ""
                    end
                elseif obj:IsA("SpecialMesh") then
                    table.insert(cache.props, {obj = obj, prop = "TextureId", val = obj.TextureId})
                    obj.TextureId = ""
                end
            end

            local function makeCharacterGray(character)
                if not character or not character.Parent then return end
                for _, obj in ipairs(character:GetDescendants()) do
                    cleanObject(obj, character)
                end
            end

            local function setupCharacter(character)
                local player = Players:GetPlayerFromCharacter(character)
                if player and not player:HasAppearanceLoaded() then
                    player.CharacterAppearanceLoaded:Wait()
                end
                if not character or not character.Parent then return end
                makeCharacterGray(character)
                local c1 = character.DescendantAdded:Connect(function(obj)
                    task.wait()
                    if obj and obj.Parent then cleanObject(obj, character) end
                end)
                table.insert(grayConns, c1)
            end

            local function onPlayerAdded(player)
                if player == LocalPlayer then return end
                if player.Character then task.spawn(setupCharacter, player.Character) end
                local c2 = player.CharacterAdded:Connect(setupCharacter)
                table.insert(grayConns, c2)
            end

            for _, player in ipairs(Players:GetPlayers()) do
                onPlayerAdded(player)
            end
            local c3 = Players.PlayerAdded:Connect(onPlayerAdded)
            table.insert(grayConns, c3)
        else
            for _, c in ipairs(grayConns) do if c then c:Disconnect() end end
            table.clear(grayConns)

            for char, cache in pairs(grayCache) do
                for _, item in ipairs(cache.instances) do
                    if item.obj then item.obj.Parent = item.parent end
                end
                for _, item in ipairs(cache.props) do
                    if item.obj then
                        pcall(function() item.obj[item.prop] = item.val end)
                    end
                end
            end
            table.clear(grayCache)
        end
    end)

    Library:CreateToggle(Page, "Black Fog", false, function(state)
        if state then
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if atm then
                OriginalAtmosphereData = {
                    Color = atm.Color, Glare = atm.Glare, Haze = atm.Haze,
                    Decay = atm.Decay, Density = atm.Density, Offset = atm.Offset
                }
            else
                OriginalAtmosphereData = "None"
            end
            BlackFogLoop = task.spawn(function()
                while state do
                    task.wait(1)
                    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
                    if not atmosphere then
                        atmosphere = Instance.new("Atmosphere")
                        atmosphere.Parent = Lighting
                    end
                    if atmosphere.Density ~= 0.75 or atmosphere.Haze ~= 2.46 then
                        atmosphere.Color = Color3.fromRGB(0, 0, 0)
                        atmosphere.Glare = 0
                        atmosphere.Haze = 2.46
                        atmosphere.Decay = Color3.fromRGB(0, 0, 0)
                        atmosphere.Density = 0.75
                        atmosphere.Offset = 0
                    end
                end
            end)
        else
            if BlackFogLoop then task.cancel(BlackFogLoop); BlackFogLoop = nil end
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if OriginalAtmosphereData == "None" then
                if atm then atm:Destroy() end
            elseif OriginalAtmosphereData and type(OriginalAtmosphereData) == "table" then
                if atm then
                    atm.Color = OriginalAtmosphereData.Color
                    atm.Glare = OriginalAtmosphereData.Glare
                    atm.Haze = OriginalAtmosphereData.Haze
                    atm.Decay = OriginalAtmosphereData.Decay
                    atm.Density = OriginalAtmosphereData.Density
                    atm.Offset = OriginalAtmosphereData.Offset
                end
            end
        end
    end)

    Library:CreateToggle(Page, "stretch screen", false, function(state) 
        if state then 
            getgenv().Resolution = {[".gg/scripters"] = 0.65}
            local Cam = workspace.CurrentCamera
            stretchConnection = game:GetService("RunService").RenderStepped:Connect(function() 
                Cam.CFrame = Cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, getgenv().Resolution[".gg/scripters"], 0, 0, 0, 1) 
            end) 
        else 
            if stretchConnection then stretchConnection:Disconnect()
                stretchConnection = nil 
            end
            getgenv().Resolution = {[".gg/scripters"] = 1} 
        end 
    end)

    local function patchElement(e)
        if not e or not e:IsA("GuiObject") then return end
        if not (e:IsA("TextLabel") or e:IsA("TextButton") or e:IsA("TextBox")) then return end
        local ok, txt = pcall(function() return e.Text end)
        if not ok or not txt or txt == "" then return end
        if not spoofVisualsEnabled then
            if originalTexts[e] and txt ~= originalTexts[e] then
                pcall(function() e.Text = originalTexts[e] end)
            end
            return
        end
        local changed = false
        local newTxt = txt
        if newTxt:find(originalName, 1, true) then
            newTxt = newTxt:gsub(originalName, spoofName)
            changed = true
        end
        if originalDisplayName and newTxt:find(originalDisplayName, 1, true) then
            newTxt = newTxt:gsub(originalDisplayName, spoofName)
            changed = true
        end
        if changed then
            if not originalTexts[e] then originalTexts[e] = txt end
            pcall(function() e.Text = newTxt end)
        end
    end

    local function trackElement(e)
        if not e then return end
        if e:IsA("TextLabel") or e:IsA("TextButton") or e:IsA("TextBox") then
            patchElement(e)
            pcall(function() e:GetPropertyChangedSignal("Text"):Connect(function() patchElement(e) end) end)
        end
    end

    Library:CreateSection(Page, "Visual Environment")
    Library:CreateToggle(Page, "Hide Leaves (Only Homestead)", false, function(state) 
        if state then
            local function isGreen(part)
                local c = part.Color
                return (c.G > c.R * 1.1) and (c.G > c.B * 1.1)
            end
            local function cleanPart(part)
                if not part:IsA("BasePart") then return end
                if part.Transparency == 1 then return end
                if part.Name == "HumanoidRootPart" then return end
                if not part.CanCollide then
                    local mat = part.Material
                    local name = part.Name:lower()
                    if name:find("leaf") or name:find("bush") or name:find("grass") or name:find("tree") or mat == Enum.Material.Grass or mat == Enum.Material.LeafyGrass or isGreen(part) then
                        if not (part.Parent:FindFirstChild("Humanoid") or part.Parent.Parent:FindFirstChild("Humanoid")) then
                             if not hiddenParts[part] then
                                hiddenParts[part] = part.Transparency 
                                part.Transparency = 1
                            end
                        end
                    end
                end
            end
            for _, v in pairs(workspace:GetDescendants()) do cleanPart(v) end
            HideLeavesConnection = workspace.DescendantAdded:Connect(cleanPart)
        else
            if HideLeavesConnection then HideLeavesConnection:Disconnect() end
            for part, originalTrans in pairs(hiddenParts) do
                if part and part.Parent then part.Transparency = originalTrans end
            end
            hiddenParts = {}
        end
    end)
    
    local noFogEnabled = false
    local originalAtmos = {}
    local originalSky = {}
    local noFogAddedConn = nil
    local function arrumarAtmosphere(atm)
        if not noFogEnabled then return end
        if not originalAtmos[atm] then
            originalAtmos[atm] = {
                Color = atm.Color, Glare = atm.Glare, Haze = atm.Haze, Decay = atm.Decay, Density = atm.Density, Offset = atm.Offset
            }
        end
        atm.Color = Color3.fromRGB(0, 0, 0)
        atm.Glare = 0
        atm.Haze = 10
        atm.Decay = Color3.fromRGB(0, 0, 0)
        atm.Density = 0
        atm.Offset = 0
        if not atm:FindFirstChild("NoFogLock") then
            local lock = Instance.new("Folder")
            lock.Name = "NoFogLock"
            lock.Parent = atm
            atm:GetPropertyChangedSignal("Density"):Connect(function()
                if noFogEnabled and atm.Density ~= 0 then
                    atm.Density = 0
                end
            end)
        end
    end

    local function arrumarSky(sky)
        if not noFogEnabled then return end
        if not originalSky[sky] then
            originalSky[sky] = {
                MoonAngularSize = sky.MoonAngularSize, StarCount = sky.StarCount
            }
        end
        sky.MoonAngularSize = 10
        sky.StarCount = 0
    end

    Library:CreateToggle(Page, "No fog", false, function(state) 
        noFogEnabled = state
        if state then
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if atm then arrumarAtmosphere(atm) end
            local sky = Lighting:FindFirstChildOfClass("Sky")
            if sky then arrumarSky(sky) end
            noFogAddedConn = Lighting.ChildAdded:Connect(function(filho)
                task.defer(function()
                    if filho:IsA("Atmosphere") then
                        arrumarAtmosphere(filho)
                    elseif filho:IsA("Sky") then
                        arrumarSky(filho)
                    end
                end)
            end)
        else
            if noFogAddedConn then noFogAddedConn:Disconnect(); noFogAddedConn = nil end
            for atm, data in pairs(originalAtmos) do
                if atm and atm.Parent then
                    atm.Color = data.Color
                    atm.Glare = data.Glare
                    atm.Haze = data.Haze
                    atm.Decay = data.Decay
                    atm.Density = data.Density
                    atm.Offset = data.Offset
                end
            end
            for sky, data in pairs(originalSky) do
                if sky and sky.Parent then
                    sky.MoonAngularSize = data.MoonAngularSize
                    sky.StarCount = data.StarCount
                end
            end
            table.clear(originalAtmos)
            table.clear(originalSky)
        end
    end)

    Library:CreateToggle(Page, "Floorbang", false, function(state)
        if not getgenv().NexFloorbang then
            getgenv().NexFloorbang = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/floorbang.lua"))()
        end
        getgenv().NexFloorbang.Toggle(state)
    end)

    Library:CreateSection(Page, "Camera & UI")
    local FovVal = 70
    Library:CreateSlider(Page, "Fov Changer", 70, 120, 70, function(v) FovVal = v end)
    RunService.RenderStepped:Connect(function() 
        local cam = Workspace.CurrentCamera
        if cam then cam.FieldOfView = FovVal end
    end)
    
    local fontOptions = {"Default"}
    for _, font in ipairs(Enum.Font:GetEnumItems()) do
        if font.Name ~= "Unknown" and font.Name ~= "Legacy" then table.insert(fontOptions, font.Name) end
    end
    Library:CreateDropdown(Page, "Font Changer", fontOptions, "Default", function(val) 
        currentFont = val
        local function applyFont(obj)
            if not originalFonts[obj] then originalFonts[obj] = obj.FontFace end
            if currentFont == "Default" then
                pcall(function() obj.FontFace = originalFonts[obj] end)
            else
                local selectedFont = Enum.Font[currentFont]
                if selectedFont then
                    pcall(function() obj.FontFace = Font.fromEnum(selectedFont) end)
                end
            end
        end
        for _, obj in pairs(LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then applyFont(obj) end
        end
        LocalPlayer:WaitForChild("PlayerGui").DescendantAdded:Connect(function(d) 
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then task.defer(applyFont, d) end 
        end)
    end)

    Library:CreateSection(Page, "Visual Name/Level")
    Library:CreateToggle(Page, "Enable Visuals", false, function(state) 
        spoofVisualsEnabled = state
        if state then
            if not trackersInitialized then
                trackersInitialized = true
                pcall(function()
                    for _, gui in ipairs(CoreGui:GetDescendants()) do trackElement(gui) end
                    CoreGui.DescendantAdded:Connect(trackElement)
                    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
                    if playerGui then
                        for _, gui in ipairs(playerGui:GetDescendants()) do trackElement(gui) end
                        playerGui.DescendantAdded:Connect(trackElement)
                    end
                end)
            else
                for e, _ in pairs(originalTexts) do
                    patchElement(e)
                end
            end
            if spoofVisualsLoop then spoofVisualsLoop:Disconnect() end
            spoofVisualsLoop = RunService.Heartbeat:Connect(function()
                if not spoofVisualsEnabled then return end
                pcall(function()
                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    if not playerGui then return end
                    local char = LocalPlayer.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then pcall(function() hum.DisplayName = spoofName end) end
                        local head = char:FindFirstChild("Head")
                        if head then
                            for _, gui in ipairs(head:GetChildren()) do
                                if gui:IsA("BillboardGui") then
                                    for _, d in ipairs(gui:GetDescendants()) do trackElement(d) end
                                end
                            end
                        end
                    end
                    local namesFrame = playerGui:FindFirstChild("PlayerNamesFrame", true)
                    if not namesFrame then return end
                    local playerFrame = namesFrame:FindFirstChild(LocalPlayer.Name .. "PlayerFrame")
                    if not playerFrame then return end
                    local levelLabel = playerFrame:FindFirstChild("LevelLabel")
                    local nameLabel  = playerFrame:FindFirstChild("NameLabel")
                    local iconLabel  = playerFrame:FindFirstChild("IconLabel")
                    if levelLabel and originalLevel == "1" and levelLabel.Text ~= tostring(spoofLevel) then
                        originalLevel = levelLabel.Text
                    end
                    if levelLabel then levelLabel.Text = tostring(spoofLevel) end
                    if nameLabel then nameLabel.Text = spoofName end
                    if iconLabel then 
                        iconLabel.ImageTransparency = 1
                        local fakeIcon = iconLabel:FindFirstChild("IconeFakeCorrigido")
                        if not fakeIcon then
                            fakeIcon = Instance.new("ImageLabel")
                            fakeIcon.Name = "IconeFakeCorrigido"
                            fakeIcon.BackgroundTransparency = 1
                            fakeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
                            fakeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
                            fakeIcon.ZIndex = iconLabel.ZIndex + 1
                            fakeIcon.Parent = iconLabel
                        end
                        fakeIcon.Image = spoofIconId
                        fakeIcon.Visible = true
                        
                        if spoofIconId == meusIcones.QA or spoofIconId == meusIcones.CON then
                            fakeIcon.Size = UDim2.new(1.35, 0, 1.35, 0) 
                        else
                            fakeIcon.Size = UDim2.new(1.0, 0, 1.0, 0)
                        end
                    end
                    playerFrame.LayoutOrder = -spoofLevel
                end)
            end)
        else
            if spoofVisualsLoop then spoofVisualsLoop:Disconnect() end
            for e, origTxt in pairs(originalTexts) do
                if e and e.Parent then pcall(function() e.Text = origTxt end) end
            end
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum.DisplayName = originalDisplayName end) end
                end
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if not playerGui then return end
                local namesFrame = playerGui:FindFirstChild("PlayerNamesFrame", true)
                if namesFrame then
                    local playerFrame = namesFrame:FindFirstChild(LocalPlayer.Name .. "PlayerFrame")
                    if playerFrame then
                        local levelLabel = playerFrame:FindFirstChild("LevelLabel")
                        local nameLabel  = playerFrame:FindFirstChild("NameLabel")
                        local iconLabel  = playerFrame:FindFirstChild("IconLabel")
                        if levelLabel then levelLabel.Text = tostring(originalLevel) end
                        if nameLabel then nameLabel.Text = originalDisplayName end
                        if iconLabel then 
                            iconLabel.ImageTransparency = 0
                            local fakeIcon = iconLabel:FindFirstChild("IconeFakeCorrigido")
                            if fakeIcon then fakeIcon.Visible = false end
                        end
                        playerFrame.LayoutOrder = -tonumber(originalLevel)
                    end
                end
            end)
        end
    end)

    Library:CreateInput(Page, "Fake Name", LocalPlayer.Name, function(val) spoofName = val end)
    Library:CreateInput(Page, "Fake Level", "100", function(val) spoofLevel = tonumber(val) or 100 end)
    
    local opcoesIcones = {"VIP", "QA", "CON", "Mod", "Dev", "Manager", "MrWindy", "Nenhum"}
    Library:CreateDropdown(Page, "Select Icon", opcoesIcones, "VIP", function(val) 
        spoofIconId = meusIcones[val] or "" 
    end)
end
