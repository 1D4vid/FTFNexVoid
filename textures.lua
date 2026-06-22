return function(env)
    local Instance_new = Instance.new
    local Color3_new = Color3.new
    local Color3_fromRGB = Color3.fromRGB
    local UDim2_new = UDim2.new
    local UDim_new = UDim.new
    local task_wait = task.wait
    local task_spawn = task.spawn
    local task_defer = task.defer
    local os_clock = os.clock
    local table_insert = table.insert
    local table_clear = table.clear
    local pairs = pairs
    local ipairs = ipairs
    local pcall = pcall
    local string_find = string.find
    local string_lower = string.lower
    local setmetatable = setmetatable
    local game = game

    local Library = env.Library
    local Page = env.Page
    local Workspace = env.Workspace
    local Players = env.Players
    local LocalPlayer = env.LocalPlayer
    local RunService = env.RunService
    local TweenService = env.TweenService
    local UserInputService = env.UserInputService
    local Theme = env.Theme
    local UserConfigs = env.UserConfigs
    local GetParentTarget = env.GetParentTarget
    local isMobile = env.isMobile
    local ContentConfig = env.ContentConfig
    local UpdateCursorSizes = env.UpdateCursorSizes
    local SetPCCursorActive = env.SetPCCursorActive
    local MobileCrosshair = env.MobileCrosshair
    local PCSoftwareCursor = env.PCSoftwareCursor
    local Lighting = game:GetService("Lighting")
    local Mouse = LocalPlayer:GetMouse()

    local GetPlayerFromCharacter = Players.GetPlayerFromCharacter

    local function showNotification(text)
        local sg = Instance_new("ScreenGui")
        sg.Name = "VisualNotification"
        sg.ResetOnSpawn = false
        
        local frame = Instance_new("Frame")
        frame.Size = UDim2_new(0, 260, 0, 40)
        frame.Position = UDim2_new(0.5, -130, 0, -50)
        frame.BackgroundColor3 = Color3_fromRGB(20, 20, 20)
        frame.BackgroundTransparency = 0.15
        frame.Parent = sg
        
        local corner = Instance_new("UICorner")
        corner.CornerRadius = UDim_new(0, 6)
        corner.Parent = frame
        
        local stroke = Instance_new("UIStroke")
        stroke.Color = Color3_fromRGB(45, 45, 45)
        stroke.Thickness = 1
        stroke.Parent = frame
        
        local label = Instance_new("TextLabel")
        label.Size = UDim2_new(1, -20, 1, 0)
        label.Position = UDim2_new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3_fromRGB(240, 240, 240)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextWrapped = true
        label.Parent = frame
        
        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pGui then
            sg.Parent = pGui
        else
            sg.Parent = game:GetService("CoreGui")
        end
        
        local t1 = TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2_new(0.5, -130, 0, 25)})
        t1:Play()
        
        task_spawn(function()
            task_wait(3)
            local t2 = TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2_new(0.5, -130, 0, -50)})
            t2:Play()
            t2.Completed:Connect(function()
                sg:Destroy()
            end)
        end)
    end

    local formatID = function(id)
        if type(id) == "number" and id > 0 then return "rbxassetid://" .. id
        elseif type(id) == "string" and id ~= "" and id ~= "0" then
            if not string_find(id, "rbxassetid://") then return "rbxassetid://" .. id else return id end
        end
        return nil
    end

    local function batchProcess(items, processFunc, onComplete)
        local total = #items
        if total == 0 then
            if onComplete then onComplete() end
            return
        end
        local index = 1
        
        local function run()
            local startTime = os_clock()
            while index <= total do
                for _ = 1, 100 do
                    if index > total then break end
                    local item = items[index]
                    if item then
                        processFunc(item)
                    end
                    index = index + 1
                end
                
                if os_clock() - startTime >= 0.004 then
                    task_wait()
                    startTime = os_clock()
                end
            end
            if onComplete then onComplete() end
        end
        task_spawn(run)
    end

    local function createGridContainer(parentTarget)
        local bg = Instance_new("Frame")
        bg.Size = UDim2_new(1, -2, 0, 1)
        bg.Position = UDim2_new(0, 1, 0, 0)
        bg.BackgroundColor3 = Color3_new(0, 0, 0)
        bg.BackgroundTransparency = 0.45
        bg.Visible = true
        bg.Parent = parentTarget
        
        Instance_new("UICorner", bg).CornerRadius = UDim_new(0, 6)
        local str = Instance_new("UIStroke", bg)
        str.Color = Color3_fromRGB(40, 40, 40)
        str.Thickness = 1

        local wrapper = Instance_new("Frame")
        wrapper.Size = UDim2_new(1, 0, 0, 1)
        wrapper.BackgroundTransparency = 1
        wrapper.Parent = bg
        
        local grid = Instance_new("UIGridLayout")
        grid.CellSize = UDim2_new(0, 36, 0, 36)
        grid.CellPadding = UDim2_new(0, 8, 0, 8)
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
        grid.Parent = wrapper
        
        local pad = Instance_new("UIPadding")
        pad.PaddingTop = UDim_new(0, 8)
        pad.PaddingBottom = UDim_new(0, 8)
        pad.Parent = wrapper

        task_defer(function()
            bg.AutomaticSize = Enum.AutomaticSize.Y
            wrapper.AutomaticSize = Enum.AutomaticSize.Y
            bg.Visible = false
            bg.Visible = true
        end)

        return wrapper
    end

    local cursorLoopConn = nil
    local function updateMouseVisibility()
        local savedPC = UserConfigs["TexturesPage_Crosshair_PC"]
        if savedPC and savedPC ~= "RESET" and not isMobile then
            if UserInputService.MouseIconEnabled then
                UserInputService.MouseIconEnabled = false
            end
            if Mouse.Icon ~= "rbxassetid://0" then
                Mouse.Icon = "rbxassetid://0"
            end
        else
            if Mouse.Icon == "rbxassetid://0" then
                Mouse.Icon = ""
                UserInputService.MouseIconEnabled = true
            end
        end
    end

    if cursorLoopConn then cursorLoopConn:Disconnect() end
    cursorLoopConn = RunService.RenderStepped:Connect(updateMouseVisibility)

    local cachedParts = {}
    local cachedLights = {}
    
    local originalMapStates = setmetatable({}, {__mode = "k"})
    local originalLightStates = setmetatable({}, {__mode = "k"})
    local mcTexturesCache = setmetatable({}, {__mode = "k"})

    local wbEnabled = false
    local snowEnabled = false
    local mcEnabled = false
    local removeShadowsEnabled = false

    local IgnoreNames = { ComputerTable = true, ExitDoor = true }
    local mcFaces = {"Front", "Back", "Bottom", "Top", "Right", "Left"}
    
    local mcMaterials = {
        [Enum.Material.Wood] = "3258599312", 
        [Enum.Material.WoodPlanks] = "8676581022", 
        [Enum.Material.Brick] = "8558400252", 
        [Enum.Material.Cobblestone] = "5003953441",
        [Enum.Material.Concrete] = "7341687607", 
        [Enum.Material.DiamondPlate] = "6849247561", 
        [Enum.Material.Fabric] = "118776397", 
        [Enum.Material.Granite] = "4722586771",
        [Enum.Material.Grass] = "4722588177", 
        [Enum.Material.Ice] = "3823766459", 
        [Enum.Material.Marble] = "62967586", 
        [Enum.Material.Metal] = "62967586", 
        [Enum.Material.Sand] = "152572215"
    }

    local function isPlayerPart(part)
        local parent = part.Parent
        if not parent then return false end
        if GetPlayerFromCharacter(Players, parent) then return true end
        local grand = parent.Parent
        if grand and GetPlayerFromCharacter(Players, grand) then return true end
        return false
    end

    local function refreshPartVisual(part)
        if not part or not part.Parent then return end

        local bkp = originalMapStates[part]
        if not bkp then
            bkp = {
                Material = part.Material,
                Color = part.Color,
                CastShadow = part.CastShadow
            }
            originalMapStates[part] = bkp
        end

        local targetMaterial = bkp.Material
        local targetColor = bkp.Color
        local targetShadow = bkp.CastShadow

        if removeShadowsEnabled then
            targetShadow = false
        end

        local mcApplied = false

        if snowEnabled then
            if part.Anchored and not IgnoreNames[part.Name] then
                targetMaterial = Enum.Material.Snow
                targetColor = Color3_fromRGB(255, 255, 255)
            end
        elseif wbEnabled then
            targetMaterial = Enum.Material.Brick
            targetColor = Color3_fromRGB(255, 255, 255)
        elseif mcEnabled then
            local textureId = mcMaterials[bkp.Material]
            if textureId then
                targetMaterial = Enum.Material.SmoothPlastic
                mcApplied = true
                
                local texGroup = mcTexturesCache[part]
                if not texGroup then
                    texGroup = {}
                    for i = 1, 6 do
                        local face = mcFaces[i]
                        local tex = Instance_new("Texture")
                        tex.Name = "McTexture_" .. face
                        tex.ZIndex = 2147483647
                        tex.Face = Enum.NormalId[face]
                        tex.StudsPerTileU = 4
                        tex.StudsPerTileV = 4
                        tex.Parent = part
                        texGroup[i] = tex
                    end
                    mcTexturesCache[part] = texGroup
                end
                
                local fullTexId = "rbxassetid://" .. textureId
                local partColor = bkp.Color
                local partTrans = part.Transparency
                for i = 1, 6 do
                    local tex = texGroup[i]
                    if tex and tex.Parent then
                        if tex.Texture ~= fullTexId then tex.Texture = fullTexId end
                        if tex.Color3 ~= partColor then tex.Color3 = partColor end
                        if tex.Transparency ~= partTrans then tex.Transparency = partTrans end
                    end
                end
            end
        end

        if not mcApplied then
            local texGroup = mcTexturesCache[part]
            if texGroup then
                for i = 1, 6 do
                    local tex = texGroup[i]
                    if tex then pcall(function() tex:Destroy() end) end
                end
                mcTexturesCache[part] = nil
            end
        end

        pcall(function()
            if part.Material ~= targetMaterial then part.Material = targetMaterial end
            if part.Color ~= targetColor then part.Color = targetColor end
            if part.CastShadow ~= targetShadow then part.CastShadow = targetShadow end
        end)
    end

    local function refreshLightVisual(light)
        if not light or not light.Parent then return end
        local bkp = originalLightStates[light]
        if not bkp then
            bkp = { Shadows = light.Shadows }
            originalLightStates[light] = bkp
        end

        local targetShadow = bkp.Shadows
        if removeShadowsEnabled then
            targetShadow = false
        end

        pcall(function()
            if light.Shadows ~= targetShadow then light.Shadows = targetShadow end
        end)
    end

    task_spawn(function()
        local desc = Workspace:GetDescendants()
        local startTime = os_clock()
        for i = 1, #desc do
            local v = desc[i]
            local class = v.ClassName
            
            if class == "Part" or class == "MeshPart" or class == "WedgePart" or class == "CornerWedgePart" then
                if not isPlayerPart(v) then
                    table_insert(cachedParts, v)
                end
            elseif class == "PointLight" or class == "SpotLight" or class == "SurfaceLight" then
                table_insert(cachedLights, v)
            end
            
            if os_clock() - startTime >= 0.004 then
                task_wait()
                startTime = os_clock()
            end
        end

        Workspace.DescendantAdded:Connect(function(child)
            task_defer(function()
                local class = child.ClassName
                if class == "Part" or class == "MeshPart" or class == "WedgePart" or class == "CornerWedgePart" then
                    if not isPlayerPart(child) then
                        table_insert(cachedParts, child)
                        refreshPartVisual(child)
                    end
                elseif class == "PointLight" or class == "SpotLight" or class == "SurfaceLight" then
                    table_insert(cachedLights, child)
                    refreshLightVisual(child)
                end
            end)
        end)
    end)


    Library:CreateSection(Page, "Map Textures", "Left")

    Library:CreateToggle(Page, "White Bricks", false, function(state)
        wbEnabled = state
        if state then showNotification("Applying White Bricks texture...") end
        batchProcess(cachedParts, refreshPartVisual)
    end)

    Library:CreateToggle(Page, "Snow Textures", false, function(state)
        snowEnabled = state
        if state then showNotification("Applying Snow texture...") end
        batchProcess(cachedParts, refreshPartVisual)
    end)

    local removeTexturesEnabled = false
    local removeTexturesConn = nil
    local textureBackups = setmetatable({}, {__mode = "k"})

    local function isMapAsset(v)
        if v:FindFirstAncestorOfClass("Model") and v:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid") then
            return false
        end
        local className = v.ClassName
        if className == "Camera" or v:IsA("GuiObject") or className == "Highlight" then
            return false
        end
        return true
    end

    local function applyRemoveTexture(v)
        if not v or not v.Parent then return end
        if not isMapAsset(v) then return end

        local class = v.ClassName
        if class == "Decal" or class == "Texture" then
            if not textureBackups[v] then
                textureBackups[v] = { Texture = v.Texture }
            end
            v.Texture = ""
        elseif class == "MeshPart" then
            if not textureBackups[v] then
                textureBackups[v] = { TextureID = v.TextureID, Material = v.Material }
            end
            v.TextureID = ""
            v.Material = Enum.Material.SmoothPlastic
        elseif class == "SpecialMesh" then
            if not textureBackups[v] then
                textureBackups[v] = { TextureId = v.TextureId }
            end
            v.TextureId = ""
        elseif v:IsA("BasePart") then
            if not textureBackups[v] then
                textureBackups[v] = { Material = v.Material }
            end
            v.Material = Enum.Material.SmoothPlastic
        end
    end

    local function restoreTextures()
        for v, data in pairs(textureBackups) do
            if v and v.Parent then
                pcall(function()
                    local class = v.ClassName
                    if class == "Decal" or class == "Texture" then
                        v.Texture = data.Texture
                    elseif class == "MeshPart" then
                        v.TextureID = data.TextureID
                        v.Material = data.Material
                    elseif class == "SpecialMesh" then
                        v.TextureId = data.TextureId
                    elseif v:IsA("BasePart") then
                        v.Material = data.Material
                    end
                end)
            end
        end
        table_clear(textureBackups)
    end

    Library:CreateToggle(Page, "Remove Textures", false, function(state) 
        removeTexturesEnabled = state
        if state then
            showNotification("Removing map textures, please wait...")
            local descendants = Workspace:GetDescendants()
            batchProcess(descendants, applyRemoveTexture)

            removeTexturesConn = Workspace.DescendantAdded:Connect(function(v)
                task_defer(function()
                    if removeTexturesEnabled then
                        applyRemoveTexture(v)
                    end
                end)
            end)
        else
            if removeTexturesConn then
                removeTexturesConn:Disconnect()
                removeTexturesConn = nil
            end
            restoreTextures()
        end
    end)

    Library:CreateToggle(Page, "Minecraft Texture", false, function(state)
        mcEnabled = state
        if state then showNotification("Applying Minecraft texture...") end
        batchProcess(cachedParts, refreshPartVisual)
    end)


    Library:CreateSection(Page, "FPS Settings", "Right")
    
    local fpsBoosterEnabled = false
    local fpsBoosterConn = nil
    local fpsBoosterBackups = setmetatable({}, {__mode = "k"})
    local originalSettings = {}

    Library:CreateToggle(Page, "FpsBooster", false, function(state) 
        fpsBoosterEnabled = state
        if state then
            showNotification("Boosting game performance, please wait...")
            local s = UserSettings():GetService("UserGameSettings")
            local settings = settings()
            
            pcall(function()
                originalSettings.QualityLevel = settings.Rendering.QualityLevel
                originalSettings.MeshPartDetailLevel = settings.Rendering.MeshPartDetailLevel
                originalSettings.SavedQualityLevel = s.SavedQualityLevel
                
                settings.Rendering.QualityLevel = Enum.QualityLevel.Level01
                settings.Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
                s.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
            end)

            local badClasses = {
                ["ParticleEmitter"] = true, ["Smoke"] = true, ["Fire"] = true, ["Sparkles"] = true, 
                ["Trail"] = true, ["Decal"] = true, ["Texture"] = true, ["Beam"] = true 
            }

            local function optimize(v)
                if not v or not v.Parent then return end
                if v:FindFirstAncestorOfClass("Model") and v:FindFirstAncestorOfClass("Model"):FindFirstChild("Humanoid") then 
                    return 
                end
                local className = v.ClassName
                if className == "Camera" or v:IsA("GuiObject") or className == "Highlight" then
                    return
                end

                if not fpsBoosterBackups[v] then
                    fpsBoosterBackups[v] = {}
                    if badClasses[className] then
                        fpsBoosterBackups[v].Enabled = v.Enabled
                    elseif className == "Decal" or className == "Texture" then
                        fpsBoosterBackups[v].Texture = v.Texture
                    elseif className == "MeshPart" then
                        fpsBoosterBackups[v].TextureID = v.TextureID
                        fpsBoosterBackups[v].Material = v.Material
                        fpsBoosterBackups[v].CastShadow = v.CastShadow
                        fpsBoosterBackups[v].CollisionFidelity = v.CollisionFidelity
                    elseif className == "SpecialMesh" then
                        fpsBoosterBackups[v].TextureId = v.TextureId
                    elseif v:IsA("BasePart") then
                        fpsBoosterBackups[v].Material = v.Material
                        fpsBoosterBackups[v].Reflectance = v.Reflectance
                        fpsBoosterBackups[v].CastShadow = v.CastShadow
                    end
                end

                if badClasses[className] then
                    v.Enabled = false
                elseif className == "Decal" or className == "Texture" then
                    v.Texture = ""
                elseif className == "MeshPart" then
                    v.TextureID = ""
                    v.Material = Enum.Material.Plastic
                    v.CastShadow = false
                    v.CollisionFidelity = Enum.CollisionFidelity.Box
                elseif className == "SpecialMesh" then
                    v.TextureId = ""
                elseif v:IsA("BasePart") then
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                    v.CastShadow = false
                end
            end

            local function fastSweep()
                local descendants = Workspace:GetDescendants()
                local start = os_clock()

                for i = 1, #descendants do
                    if not fpsBoosterEnabled then break end
                    local v = descendants[i]
                    if v and v.Parent then
                        optimize(v)
                    end
                    
                    if i % 300 == 0 then
                        if os_clock() - start > 0.016 then
                            task_wait()
                            start = os_clock()
                        end
                    end
                end
            end
            task_spawn(fastSweep)

            fpsBoosterConn = Workspace.DescendantAdded:Connect(function(v)
                task_wait(0.5)
                if fpsBoosterEnabled and v and v.Parent then
                    optimize(v)
                end
            end)

            local t = Workspace:FindFirstChildOfClass("Terrain")
            if t then
                if not originalSettings.Terrain then
                    originalSettings.Terrain = {
                        WaterWaveSize = t.WaterWaveSize,
                        WaterWaveSpeed = t.WaterWaveSpeed,
                        WaterReflectance = t.WaterReflectance,
                        WaterTransparency = t.WaterTransparency
                    }
                end
                pcall(function()
                    t.WaterWaveSize = 0
                    t.WaterWaveSpeed = 0
                    t.WaterReflectance = 0
                    t.WaterTransparency = 0
                end)
            end
        else
            if fpsBoosterConn then
                fpsBoosterConn:Disconnect()
                fpsBoosterConn = nil
            end

            for v, backup in pairs(fpsBoosterBackups) do
                if v and v.Parent then
                    pcall(function()
                        local className = v.ClassName
                        if backup.Enabled ~= nil then
                            v.Enabled = backup.Enabled
                        elseif className == "Decal" or className == "Texture" then
                            v.Texture = backup.Texture
                        elseif className == "MeshPart" then
                            v.TextureID = backup.TextureID
                            v.Material = backup.Material
                            v.CastShadow = backup.CastShadow
                            v.CollisionFidelity = backup.CollisionFidelity
                        elseif className == "SpecialMesh" then
                            v.TextureId = backup.TextureId
                        elseif v:IsA("BasePart") then
                            v.Material = backup.Material
                            v.Reflectance = backup.Reflectance
                            v.CastShadow = backup.CastShadow
                        end
                    end)
                end
            end
            table_clear(fpsBoosterBackups)

            pcall(function()
                local s = UserSettings():GetService("UserGameSettings")
                local settings = settings()
                if originalSettings.QualityLevel then settings.Rendering.QualityLevel = originalSettings.QualityLevel end
                if originalSettings.MeshPartDetailLevel then settings.Rendering.MeshPartDetailLevel = originalSettings.MeshPartDetailLevel end
                if originalSettings.SavedQualityLevel then s.SavedQualityLevel = originalSettings.SavedQualityLevel end
            end)

            local t = Workspace:FindFirstChildOfClass("Terrain")
            if t and originalSettings.Terrain then
                pcall(function()
                    t.WaterWaveSize = originalSettings.Terrain.WaterWaveSize
                    t.WaterWaveSpeed = originalSettings.Terrain.WaterWaveSpeed
                    t.WaterReflectance = originalSettings.Terrain.WaterReflectance
                    t.WaterTransparency = originalSettings.Terrain.WaterTransparency
                end)
            end
        end
    end)

    local grayOutfitsEnabled = false
    local grayCharacterConns = {}
    local characterBackups = setmetatable({}, {__mode = "k"})

    local function applyGreyCharacter(char)
        if not char or not char.Parent then return end
        if characterBackups[char] then return end
        
        local backup = {
            Parts = {},
            Accessories = {},
            Clothes = {},
            Connections = {}
        }
        
        local function processItem(i)
            if not i or not i.Parent then return end
            
            local class = i.ClassName
            if (i:IsA("BasePart") or class == "MeshPart") and i.Name ~= "HumanoidRootPart" then
                local isAcc = i:FindFirstAncestorOfClass("Accessory")
                if isAcc then
                    if i.Name == "Handle" and not backup.Accessories[i] then
                        local handleBackup = {
                            Color = i.Color,
                            Material = i.Material,
                            TextureID = nil,
                            MeshInstance = nil
                        }
                        i.Color = Color3_fromRGB(150, 150, 150)
                        i.Material = Enum.Material.SmoothPlastic
                        
                        if class == "MeshPart" then
                            handleBackup.TextureID = i.TextureID
                            i.TextureID = ""
                        else
                            local mesh = i:FindFirstChildWhichIsA("SpecialMesh") or i:FindFirstChildWhichIsA("Mesh")
                            if mesh then
                                handleBackup.TextureID = mesh.TextureId
                                handleBackup.MeshInstance = mesh
                                mesh.TextureId = ""
                            end
                        end
                        backup.Accessories[i] = handleBackup
                    end
                else
                    if not backup.Parts[i] then
                        backup.Parts[i] = {
                            Color = i.Color,
                            Material = i.Material
                        }
                        i.Color = Color3_fromRGB(150, 150, 150)
                        i.Material = Enum.Material.SmoothPlastic
                    end
                end
            elseif i:IsA("Clothing") or class == "ShirtGraphic" or i.Name == "Shirt Graphic" then
                if not backup.Clothes[i] then
                    backup.Clothes[i] = i.Parent
                    task_defer(function() i.Parent = nil end)
                end
            elseif class == "SpecialMesh" or i:IsA("FileMesh") then
                local p = i.Parent
                if p and p.Name == "Handle" and backup.Accessories[p] then
                    local hBkp = backup.Accessories[p]
                    if not hBkp.MeshInstance then
                        hBkp.TextureID = i.TextureId
                        hBkp.MeshInstance = i
                        i.TextureId = ""
                    end
                end
            end
        end

        for _, i in ipairs(char:GetDescendants()) do
            processItem(i)
        end

        local conn = char.DescendantAdded:Connect(function(desc)
            task_wait()
            if grayOutfitsEnabled then
                processItem(desc)
            end
        end)
        table_insert(backup.Connections, conn)
        
        characterBackups[char] = backup
    end

    local function restoreCharacter(char)
        local backup = characterBackups[char]
        if not backup then return end
        
        for _, conn in ipairs(backup.Connections) do
            conn:Disconnect()
        end
        
        for part, data in pairs(backup.Parts) do
            if part and part.Parent then
                part.Color = data.Color
                part.Material = data.Material
            end
        end
        
        for handle, data in pairs(backup.Accessories) do
            if handle and handle.Parent then
                handle.Color = data.Color
                handle.Material = data.Material
                if handle:IsA("MeshPart") then
                    handle.TextureID = data.TextureID
                elseif data.MeshInstance then
                    data.MeshInstance.TextureId = data.TextureID
                end
            end
        end
        
        for clothing, originalParent in pairs(backup.Clothes) do
            if clothing then
                clothing.Parent = char
            end
        end
        
        characterBackups[char] = nil
    end

    local function handleCharacterLoading(char)
        if not char then return end
        local player = GetPlayerFromCharacter(Players, char)
        if player then
            if not player:HasAppearanceLoaded() then
                local loaded = false
                local appearanceConn
                appearanceConn = player.CharacterAppearanceLoaded:Connect(function()
                    loaded = true
                    if appearanceConn then appearanceConn:Disconnect() end
                end)
                
                local start = os_clock()
                while not loaded and os_clock() - start < 5 do
                    task_wait(0.1)
                end
                if appearanceConn then appearanceConn:Disconnect() end
            end
        end
        task_wait(0.1)
        if grayOutfitsEnabled then
            applyGreyCharacter(char)
        end
    end

    Library:CreateToggle(Page, "Gray Characters", false, function(state)
        grayOutfitsEnabled = state
        if state then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    task_spawn(handleCharacterLoading, player.Character)
                end
                local conn = player.CharacterAdded:Connect(function(char)
                    task_spawn(handleCharacterLoading, char)
                end)
                table_insert(grayCharacterConns, conn)
            end
            
            local conn2 = Players.PlayerAdded:Connect(function(player)
                local conn = player.CharacterAdded:Connect(function(char)
                    task_spawn(handleCharacterLoading, char)
                end)
                table_insert(grayCharacterConns, conn)
            end)
            table_insert(grayCharacterConns, conn2)
        else
            for _, conn in ipairs(grayCharacterConns) do
                conn:Disconnect()
            end
            table_clear(grayCharacterConns)
            
            for char, _ in pairs(characterBackups) do
                restoreCharacter(char)
            end
            table_clear(characterBackups)
        end
    end)

    local shadowChangedConn = nil

    Library:CreateToggle(Page, "Remove Shadows", false, function(state)
        removeShadowsEnabled = state
        
        if state then
            pcall(function() Lighting.GlobalShadows = false end)
            shadowChangedConn = Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
                if Lighting.GlobalShadows and removeShadowsEnabled then
                    pcall(function() Lighting.GlobalShadows = false end)
                end
            end)
        else
            if shadowChangedConn then shadowChangedConn:Disconnect() shadowChangedConn = nil end
            pcall(function() Lighting.GlobalShadows = true end)
        end

        batchProcess(cachedParts, refreshPartVisual, function()
            batchProcess(cachedLights, refreshLightVisual)
        end)
    end)

    local removeParticlesEnabled = false
    local particlesDescConnW = nil
    local particlesDescConnL = nil
    local particleBkp = setmetatable({}, {__mode = "k"})

    local function applyParticleRemoval(objeto)
        if not removeParticlesEnabled then return end
        
        local class = objeto.ClassName
        local isParticle = class == "ParticleEmitter" or 
                           class == "Sparkles" or 
                           class == "Fire" or 
                           class == "Smoke" or 
                           class == "Trail" or 
                           class == "Beam" or 
                           objeto:IsA("PostEffect")
        
        if isParticle then
            if not particleBkp[objeto] then
                local connection
                connection = objeto:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if removeParticlesEnabled and objeto.Enabled == true then
                        pcall(function() objeto.Enabled = false end)
                    end
                end)
                
                particleBkp[objeto] = {
                    Enabled = objeto.Enabled,
                    Conn = connection
                }
            end
            pcall(function() objeto.Enabled = false end)
        elseif class == "Explosion" then
            pcall(function() objeto:Destroy() end)
        end
    end

    Library:CreateToggle(Page, "Remove Particles", false, function(state)
        removeParticlesEnabled = state
        
        if state then
            local descW = Workspace:GetDescendants()
            local descL = Lighting:GetDescendants()
            
            batchProcess(descW, applyParticleRemoval, function()
                if removeParticlesEnabled then
                    batchProcess(descL, applyParticleRemoval)
                end
            end)

            particlesDescConnW = Workspace.DescendantAdded:Connect(function(child)
                if removeParticlesEnabled then task_defer(applyParticleRemoval, child) end
            end)
            particlesDescConnL = Lighting.DescendantAdded:Connect(function(child)
                if removeParticlesEnabled then task_defer(applyParticleRemoval, child) end
            end)
        else
            if particlesDescConnW then particlesDescConnW:Disconnect() particlesDescConnW = nil end
            if particlesDescConnL then particlesDescConnL:Disconnect() particlesDescConnL = nil end

            local currentBkp = particleBkp
            particleBkp = setmetatable({}, {__mode = "k"})
            local toRevert = {}
            for obj, data in pairs(currentBkp) do
                table_insert(toRevert, {obj = obj, data = data})
            end

            batchProcess(toRevert, function(item)
                local obj = item.obj
                local data = item.data
                
                if data.Conn then
                    pcall(function() data.Conn:Disconnect() end)
                end
                
                if obj and obj.Parent then
                    pcall(function()
                        if data.Enabled ~= nil then obj.Enabled = data.Enabled end
                    end)
                end
            end)
        end
    end)


    Library:CreateSection(Page, "Double Jump Effects (P1)", "Left")
    local targetParentDJ1 = GetParentTarget(Page)
    
    Library:CreateSection(Page, "Double Jump (P2)", "Left")
    local targetParentDJ2 = GetParentTarget(Page)


    Library:CreateSection(Page, "Crosshairs (P1)", "Right")
    Library:CreateSlider(Page, "Cursor Size", 10, 100, 24, UpdateCursorSizes)
    local targetParentCur1 = GetParentTarget(Page)
    
    Library:CreateSection(Page, "Crosshairs (P2)", "Right")
    local targetParentCur2 = GetParentTarget(Page)


    local currentDoubleJumpConns = {}
    local originalTextures = setmetatable({}, {__mode = "k"})
    local OriginalSparkleColors = setmetatable({}, {__mode = "k"})
    
    local function EnableDoubleJumpEffect(texturaID)
        UserConfigs["TexturesPage_DoubleJump"] = texturaID
        for _, c in ipairs(currentDoubleJumpConns) do c:Disconnect() end
        table_clear(currentDoubleJumpConns)
        
        local function aplicarTextura(obj)
            local class = obj.ClassName
            if texturaID == "Default" then
                obj:SetAttribute("CurrentTexture", nil)
                if class == "ParticleEmitter" then
                    if originalTextures[obj] then obj.Texture = originalTextures[obj] end
                elseif class == "Sparkles" then
                    local oldClone = obj.Parent:FindFirstChild("CustomSparkleClone_" .. obj.Name)
                    if oldClone then oldClone:Destroy() end
                    if OriginalSparkleColors[obj] then pcall(function() obj.SparkleColor = OriginalSparkleColors[obj] end)
                    else pcall(function() obj.SparkleColor = Color3_new(1, 1, 1) end) end
                end
                return
            end

            if obj:GetAttribute("CurrentTexture") == texturaID then return end
            obj:SetAttribute("CurrentTexture", texturaID)
            
            if class == "ParticleEmitter" then
                local sucesso, texturaAtual = pcall(function() return obj.Texture end)
                if sucesso and texturaAtual and string_find(string_lower(texturaAtual), "sparkles_main") then
                    if not originalTextures[obj] then originalTextures[obj] = obj.Texture end
                    obj.Texture = texturaID
                end
            elseif class == "Sparkles" then
                if not OriginalSparkleColors[obj] then OriginalSparkleColors[obj] = obj.SparkleColor end
                pcall(function() obj.SparkleColor = Color3_new(0, 0, 0) end)
                
                local oldClone = obj.Parent:FindFirstChild("CustomSparkleClone_" .. obj.Name)
                if oldClone then oldClone:Destroy() end
                
                local clone = Instance_new("ParticleEmitter")
                clone.Name = "CustomSparkleClone_" .. obj.Name
                clone.Texture = texturaID
                clone.Rate = 20
                clone.Speed = NumberRange.new(2, 4)
                clone.Lifetime = NumberRange.new(1.5, 2)
                clone.Rotation = NumberRange.new(0, 360)
                clone.RotSpeed = NumberRange.new(-50, 50)
                clone.LightEmission = 0.8
                clone.ZOffset = 1
                clone.Brightness = 2
                clone.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 0)})
                clone.Parent = obj.Parent
                clone.Enabled = obj.Enabled
                
                local conexao = obj:GetPropertyChangedSignal("Enabled"):Connect(function() 
                    if clone then clone.Enabled = obj.Enabled end
                end)
                local destConn = obj.Destroying:Connect(function()
                    if conexao then conexao:Disconnect() end
                    if clone then clone:Destroy() end
                end)
                
                table_insert(currentDoubleJumpConns, conexao)
                table_insert(currentDoubleJumpConns, destConn)
            end
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            local char = plr.Character
            if char then
                local descendants = char:GetDescendants()
                for i = 1, #descendants do
                    local obj = descendants[i]
                    local class = obj.ClassName
                    if class == "ParticleEmitter" or class == "Sparkles" then
                        aplicarTextura(obj)
                    end
                end
            end
        end

        task_spawn(function()
            local desc = Workspace:GetDescendants()
            local targets = {}
            for i = 1, #desc do
                local obj = desc[i]
                if obj then
                    local class = obj.ClassName
                    if class == "ParticleEmitter" or class == "Sparkles" then
                        table_insert(targets, obj)
                    end
                end
            end
            batchProcess(targets, aplicarTextura)
        end)

        if texturaID ~= "Default" then
            table_insert(currentDoubleJumpConns, Workspace.DescendantAdded:Connect(function(obj)
                local class = obj.ClassName
                if class == "ParticleEmitter" or class == "Sparkles" then
                    task_defer(function() aplicarTextura(obj) end)
                end
            end))

            for _, plr in ipairs(Players:GetPlayers()) do
                table_insert(currentDoubleJumpConns, plr.CharacterAdded:Connect(function(char)
                    table_insert(currentDoubleJumpConns, char.DescendantAdded:Connect(function(obj)
                        local class = obj.ClassName
                        if class == "ParticleEmitter" or class == "Sparkles" then
                            task_defer(function() aplicarTextura(obj) end)
                        end
                    end))
                end))
            end

            table_insert(currentDoubleJumpConns, Players.PlayerAdded:Connect(function(plr)
                table_insert(currentDoubleJumpConns, plr.CharacterAdded:Connect(function(char)
                    table_insert(currentDoubleJumpConns, char.DescendantAdded:Connect(function(obj)
                        local class = obj.ClassName
                        if class == "ParticleEmitter" or class == "Sparkles" then
                            task_defer(function() aplicarTextura(obj) end)
                        end
                    end))
                end))
            end))
        end
    end

    local CustomInputContainer = Instance_new("Frame")
    CustomInputContainer.Size = UDim2_new(1, -2, 0, ContentConfig.ItemHeightNew)
    CustomInputContainer.Position = UDim2_new(0, 1, 0, 0)
    CustomInputContainer.BackgroundTransparency = 1
    CustomInputContainer.Parent = targetParentDJ1

    local CustomInputBox = Instance_new("TextBox")
    CustomInputBox.Size = UDim2_new(1, -65, 1, 0)
    CustomInputBox.Position = UDim2_new(0, 5, 0, 0)
    CustomInputBox.BackgroundTransparency = 1
    CustomInputBox.Text = ""
    local savedDJ = UserConfigs["TexturesPage_DoubleJump"]
    if savedDJ and savedDJ ~= "Default" then CustomInputBox.Text = savedDJ:gsub("rbxassetid://", "") end
    CustomInputBox.PlaceholderText = "Texture ID..."
    CustomInputBox.TextColor3 = Theme.TextDark
    CustomInputBox.PlaceholderColor3 = Theme.TextDark
    CustomInputBox.Font = Theme.Font
    CustomInputBox.TextSize = 10
    CustomInputBox.TextXAlignment = Enum.TextXAlignment.Left
    CustomInputBox.ClearTextOnFocus = false
    CustomInputBox.Parent = CustomInputContainer

    local ApplyBtn = Instance_new("TextButton")
    ApplyBtn.Size = UDim2_new(0, 55, 0, 20)
    ApplyBtn.Position = UDim2_new(1, -60, 0.5, -10)
    ApplyBtn.BackgroundColor3 = Color3_new(0,0,0)
    ApplyBtn.BackgroundTransparency = 0.45
    ApplyBtn.Text = "Apply"
    ApplyBtn.Font = Enum.Font.GothamBold
    ApplyBtn.TextSize = 10
    ApplyBtn.TextColor3 = Theme.TextDark
    ApplyBtn.Parent = CustomInputContainer
    Instance_new("UICorner", ApplyBtn).CornerRadius = UDim_new(0, 4)
    local abStr = Instance_new("UIStroke", ApplyBtn)
    abStr.Color = Color3_fromRGB(40,40,40)

    ApplyBtn.MouseButton1Click:Connect(function()
        local val = CustomInputBox.Text
        if val and val ~= "" then
            local formatted = formatID(val)
            if formatted then
                UserConfigs["TexturesPage_DoubleJump"] = formatted
                EnableDoubleJumpEffect(formatted)
            end
        end
    end)

    local effectIDs = {
        "81110491136307", "117864251880006", "120181545812734", "74056211768119", 
        "116419901031627", "92247449256845", "113423466689563", "90279999098357", 
        "94123299347751", "105065705443269", "122902019815288", "138617722401997", 
        "75192344666220", "139646605021296", "133105930199997", "96482830256985", 
        "107964624563909", "122185636007520", "130200330618832", 
        "87265760472097", "125925535971201", "99196076742919", "80555494674270", 
        "77364460442867", "84014330993791", "80081088131892", "70463296258416",
        "84683340454265", "110707827597886", "94615398600162", "136555497393349", 
        "115660311620643", "87528090276578", "91090339346537", "104273334466284", 
        "125877054664162", "99696281853254", "115091366896134", "118044368508403"
    }

    local GridWrapperDJ1 = createGridContainer(targetParentDJ1)
    local GridWrapperDJ2 = createGridContainer(targetParentDJ2)

    local defaultBtn = Instance_new("TextButton")
    defaultBtn.Text = "Default"
    defaultBtn.Font = Enum.Font.GothamBold
    defaultBtn.TextSize = 9
    defaultBtn.TextColor3 = Theme.TextDark
    defaultBtn.BackgroundColor3 = Color3_new(0,0,0)
    defaultBtn.BackgroundTransparency = 0.45
    defaultBtn.Parent = GridWrapperDJ1
    Instance_new("UICorner", defaultBtn).CornerRadius = UDim_new(0, 4)
    local dbStr = Instance_new("UIStroke", defaultBtn)
    dbStr.Color = Color3_fromRGB(40,40,40)
    
    defaultBtn.MouseEnter:Connect(function() TweenService:Create(dbStr, TweenInfo.new(0.2), {Color=Theme.Accent}):Play() TweenService:Create(defaultBtn, TweenInfo.new(0.2), {TextColor3=Theme.Accent}):Play() end)
    defaultBtn.MouseLeave:Connect(function() TweenService:Create(dbStr, TweenInfo.new(0.2), {Color=Color3_fromRGB(40,40,40)}):Play() TweenService:Create(defaultBtn, TweenInfo.new(0.2), {TextColor3=Theme.TextDark}):Play() end)
    defaultBtn.MouseButton1Click:Connect(function() UserConfigs["TexturesPage_DoubleJump"] = "Default" EnableDoubleJumpEffect("Default") end)

    for i, id in ipairs(effectIDs) do
        local targetGrid = (i <= 19) and GridWrapperDJ1 or GridWrapperDJ2
        local btn = Instance_new("ImageButton")
        btn.BackgroundColor3 = Color3_new(0,0,0)
        btn.BackgroundTransparency = 0.45
        btn.Image = "rbxassetid://" .. id
        btn.ScaleType = Enum.ScaleType.Crop 
        btn.Parent = targetGrid
        Instance_new("UICorner", btn).CornerRadius = UDim_new(0, 4)
        local ebStr = Instance_new("UIStroke", btn)
        ebStr.Color = Color3_fromRGB(40,40,40)

        btn.MouseEnter:Connect(function() TweenService:Create(ebStr, TweenInfo.new(0.2), {Color=Theme.Accent}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(ebStr, TweenInfo.new(0.2), {Color=Color3_fromRGB(40,40,40)}):Play() end)
        btn.MouseButton1Click:Connect(function() 
            UserConfigs["TexturesPage_DoubleJump"] = "rbxassetid://" .. id
            EnableDoubleJumpEffect("rbxassetid://" .. id)
        end)
    end

    if isMobile then
        Library:CreateSection(Page, "Mobile Button Jump (P1)", "Left")
        local targetParentMJ1 = GetParentTarget(Page)

        Library:CreateSection(Page, "Mobile Button Jump (P2)", "Right")
        local targetParentMJ2 = GetParentTarget(Page)

        local mobileJumpConns = {}
        local function EnableMobileButtonJump(texturaID)
            UserConfigs["TexturesPage_MobileJump"] = texturaID
            if not isMobile then return end
            
            for _, c in ipairs(mobileJumpConns) do c:Disconnect() end
            table_clear(mobileJumpConns)

            local playerGui = LocalPlayer:WaitForChild("PlayerGui")
            local function applyCustomButton(touchGui)
                local touchControlFrame = touchGui:FindFirstChild("TouchControlFrame") or touchGui:WaitForChild("TouchControlFrame", 2)
                if not touchControlFrame then return end
                local jumpButton = touchControlFrame:FindFirstChild("JumpButton") or touchControlFrame:WaitForChild("JumpButton", 2)
                if not jumpButton then return end

                if texturaID == "Default" then
                    jumpButton.ImageTransparency = 0
                    local existingIcon = jumpButton:FindFirstChild("CustomJumpIcon")
                    if existingIcon then existingIcon:Destroy() end
                    return
                end
                
                jumpButton.ImageTransparency = 1 
                local existingIcon = jumpButton:FindFirstChild("CustomJumpIcon")
                if existingIcon then existingIcon:Destroy() end
                
                local customIcon = Instance_new("ImageLabel")
                customIcon.Name = "CustomJumpIcon"
                customIcon.Size = UDim2_new(1, 0, 1, 0)
                customIcon.Position = UDim2_new(0, 0, 0, 0)
                customIcon.BackgroundTransparency = 1
                customIcon.Image = texturaID
                customIcon.ZIndex = jumpButton.ZIndex + 50
                customIcon.Parent = jumpButton
                
                local c1 = jumpButton.InputBegan:Connect(function(input)
                    local ut = input.UserInputType
                    if ut == Enum.UserInputType.Touch or ut == Enum.UserInputType.MouseButton1 then
                        customIcon.ImageColor3 = Color3_fromRGB(150, 150, 150)
                    end
                end)
                local c2 = jumpButton.InputEnded:Connect(function(input)
                    local ut = input.UserInputType
                    if ut == Enum.UserInputType.Touch or ut == Enum.UserInputType.MouseButton1 then
                        customIcon.ImageColor3 = Color3_fromRGB(255, 255, 255)
                    end
                end)
                table_insert(mobileJumpConns, c1)
                table_insert(mobileJumpConns, c2)
            end

            if playerGui:FindFirstChild("TouchGui") then task_spawn(applyCustomButton, playerGui.TouchGui) end
            if texturaID ~= "Default" then
                table_insert(mobileJumpConns, playerGui.ChildAdded:Connect(function(child)
                    if child.Name == "TouchGui" then task_spawn(applyCustomButton, child) end
                end))
            end
        end

        local MJInputContainer = Instance_new("Frame")
        MJInputContainer.Size = UDim2_new(1, -2, 0, ContentConfig.ItemHeightNew)
        MJInputContainer.Position = UDim2_new(0, 1, 0, 0)
        MJInputContainer.BackgroundTransparency = 1
        MJInputContainer.Parent = targetParentMJ1

        local MJumpTextBox = Instance_new("TextBox")
        MJumpTextBox.Size = UDim2_new(1, -65, 1, 0)
        MJumpTextBox.Position = UDim2_new(0, 5, 0, 0)
        MJumpTextBox.BackgroundTransparency = 1
        MJumpTextBox.Text = ""
        local savedMJ = UserConfigs["TexturesPage_MobileJump"]
        if savedMJ and savedMJ ~= "Default" then MJumpTextBox.Text = savedMJ:gsub("rbxassetid://", "") end
        MJumpTextBox.PlaceholderText = "Texture ID..."
        MJumpTextBox.TextColor3 = Theme.TextDark
        MJumpTextBox.PlaceholderColor3 = Theme.TextDark
        MJumpTextBox.Font = Theme.Font
        MJumpTextBox.TextSize = 10
        MJumpTextBox.TextXAlignment = Enum.TextXAlignment.Left
        MJumpTextBox.ClearTextOnFocus = false
        MJumpTextBox.Parent = MJInputContainer

        local MJumpApplyBtn = Instance_new("TextButton")
        MJumpApplyBtn.Size = UDim2_new(0, 55, 0, 20)
        MJumpApplyBtn.Position = UDim2_new(1, -60, 0.5, -10)
        MJumpApplyBtn.BackgroundColor3 = Color3_new(0,0,0)
        MJumpApplyBtn.BackgroundTransparency = 0.45
        MJumpApplyBtn.Text = "Apply"
        MJumpApplyBtn.Font = Enum.Font.GothamBold
        MJumpApplyBtn.TextSize = 10
        MJumpApplyBtn.TextColor3 = Theme.TextDark
        MJumpApplyBtn.Parent = MJInputContainer
        Instance_new("UICorner", MJumpApplyBtn).CornerRadius = UDim_new(0, 4)
        local mbStr = Instance_new("UIStroke", MJumpApplyBtn)
        mbStr.Color = Color3_fromRGB(40,40,40)

        MJumpApplyBtn.MouseButton1Click:Connect(function()
            local val = MJumpTextBox.Text
            if val and val ~= "" then
                local formatted = formatID(val)
                if formatted then
                    UserConfigs["TexturesPage_MobileJump"] = formatted
                    EnableMobileButtonJump(formatted)
                end
            end
        end)

        local MJGridWrapper1 = createGridContainer(targetParentMJ1)
        local MJGridWrapper2 = createGridContainer(targetParentMJ2)

        local mDefaultBtn = Instance_new("TextButton")
        mDefaultBtn.Text = "Default"
        mDefaultBtn.Font = Enum.Font.GothamBold
        mDefaultBtn.TextSize = 9
        mDefaultBtn.TextColor3 = Theme.TextDark
        mDefaultBtn.BackgroundColor3 = Color3_new(0,0,0)
        mDefaultBtn.BackgroundTransparency = 0.45
        mDefaultBtn.Parent = MJGridWrapper1
        Instance_new("UICorner", mDefaultBtn).CornerRadius = UDim_new(0, 4)
        local mDStr = Instance_new("UIStroke", mDefaultBtn)
        mDStr.Color = Color3_fromRGB(40,40,40)
        
        mDefaultBtn.MouseEnter:Connect(function() TweenService:Create(mDStr, TweenInfo.new(0.2), {Color=Theme.Accent}):Play() TweenService:Create(mDefaultBtn, TweenInfo.new(0.2), {TextColor3=Theme.Accent}):Play() end)
        mDefaultBtn.MouseLeave:Connect(function() TweenService:Create(mDStr, TweenInfo.new(0.2), {Color=Color3_fromRGB(40,40,40)}):Play() TweenService:Create(defaultBtn, TweenInfo.new(0.2), {TextColor3=Theme.TextDark}):Play() end)
        mDefaultBtn.MouseButton1Click:Connect(function() UserConfigs["TexturesPage_MobileJump"] = "Default" EnableMobileButtonJump("Default") end)

        local mJumpIDs_P1 = {
            "126321670529682", "77430663366893", "115979689020396", "101678026501268", 
            "100604012502918", "107988778180975", "106355869384286", "119823685069603"
        }

        for _, id in ipairs(mJumpIDs_P1) do
            local btn = Instance_new("ImageButton")
            btn.BackgroundColor3 = Color3_new(0,0,0)
            btn.BackgroundTransparency = 0.45
            btn.Image = "rbxassetid://" .. id
            btn.ScaleType = Enum.ScaleType.Crop 
            btn.Parent = MJGridWrapper1
            Instance_new("UICorner", btn).CornerRadius = UDim_new(0, 4)
            local str = Instance_new("UIStroke", btn)
            str.Color = Color3_fromRGB(40,40,40)
            
            btn.MouseEnter:Connect(function() TweenService:Create(str, TweenInfo.new(0.2), {Color=Theme.Accent}):Play() end)
            btn.MouseLeave:Connect(function() TweenService:Create(str, TweenInfo.new(0.2), {Color=Color3_fromRGB(40,40,40)}):Play() end)
            btn.MouseButton1Click:Connect(function() 
                UserConfigs["TexturesPage_MobileJump"] = "rbxassetid://" .. id
                EnableMobileButtonJump("rbxassetid://" .. id)
            end)
        end

        local mJumpIDs_P2 = {
            "70463296258416", "80555494674270", "74056211768119", "115091366896134", 
            "117864251880006", "130200330618832", "77364460442867"
        }

        for _, id in ipairs(mJumpIDs_P2) do
            local btn = Instance_new("ImageButton")
            btn.BackgroundColor3 = Color3_new(0,0,0)
            btn.BackgroundTransparency = 0.45
            btn.Image = "rbxassetid://" .. id
            btn.ScaleType = Enum.ScaleType.Crop 
            btn.Parent = MJGridWrapper2
            Instance_new("UICorner", btn).CornerRadius = UDim_new(0, 4)
            local str = Instance_new("UIStroke", btn)
            str.Color = Color3_fromRGB(40,40,40)
            
            btn.MouseEnter:Connect(function() TweenService:Create(str, TweenInfo.new(0.2), {Color=Theme.Accent}):Play() end)
            btn.MouseLeave:Connect(function() TweenService:Create(str, TweenInfo.new(0.2), {Color=Color3_fromRGB(40,40,40)}):Play() end)
            btn.MouseButton1Click:Connect(function() 
                UserConfigs["TexturesPage_MobileJump"] = "rbxassetid://" .. id
                EnableMobileButtonJump("rbxassetid://" .. id)
            end)
        end
    end

    local CursorList = {
        {Name = "Default", ID = "RESET"},
        {Name = "Use Cursor", ID = "15368174199"}, {Name = "Use Cursor", ID = "12701650945"},
        {Name = "Use Cursor", ID = "119350232226515"}, {Name = "Use Cursor", ID = "5060823578"}, 
        {Name = "Use Cursor", ID = "9896571799"}, {Name = "Use Cursor", ID = "139654963330788"}, 
        {Name = "Use Cursor", ID = "13441649168"}, {Name = "Use Cursor", ID = "88005681147215"}, 
        {Name = "Use Cursor", ID = "72902755839437"}, {Name = "Use Cursor", ID = "128926155948846"}, 
        {Name = "Use Cursor", ID = "95348763251820"}, {Name = "Use Cursor", ID = "138513473967293"}, 
        {Name = "Use Cursor", ID = "82043397777881"}, {Name = "Use Cursor", ID = "84583215296063"}, 
        {Name = "Use Cursor", ID = "120058675182639"}, {Name = "Use Cursor", ID = "130210380679877"}, 
        {Name = "Use Cursor", ID = "74264514489577"}, {Name = "Use Cursor", ID = "115877213393063"}, 
        {Name = "Use Cursor", ID = "133579119074302"}, {Name = "Use Cursor", ID = "137970082797101"}, 
        {Name = "Use Cursor", ID = "116865736993390"}, {Name = "Use Cursor", ID = "70613337612134"}, 
        {Name = "Use Cursor", ID = "75670552980458"}, {Name = "Use Cursor", ID = "100822311002882"}, 
        {Name = "Use Cursor", ID = "135331308026486"}, {Name = "Use Cursor", ID = "91090339346537"}, 
        {Name = "Use Cursor", ID = "99626703938913"}, {Name = "Use Cursor", ID = "112195317343485"}, 
        {Name = "Use Cursor", ID = "89746976355403"}, {Name = "Use Cursor", ID = "132191954497107"}, 
        {Name = "Use Cursor", ID = "93050147531878"}, {Name = "Use Cursor", ID = "88343941218179"}, 
        {Name = "Use Cursor", ID = "81277812126144"}, {Name = "Use Cursor", ID = "131422226977434"}, 
        {Name = "Use Cursor", ID = "116499481211766"}, {Name = "Use Cursor", ID = "139192004969086"}, 
        {Name = "Use Cursor", ID = "115820239502902"}
    }

    local function CreateCursorSystem(isMob)
        local CInputContainer = Instance_new("Frame")
        CInputContainer.Size = UDim2_new(1, -2, 0, ContentConfig.ItemHeightNew)
        CInputContainer.Position = UDim2_new(0, 1, 0, 0)
        CInputContainer.BackgroundTransparency = 1
        CInputContainer.Parent = targetParentCur1
        
        local TextBox = Instance_new("TextBox")
        TextBox.Size = UDim2_new(1, -65, 1, 0)
        TextBox.Position = UDim2_new(0, 5, 0, 0)
        TextBox.BackgroundTransparency = 1
        TextBox.Text = ""
        local flagKey = "TexturesPage_Crosshair_" .. (isMob and "Mobile" or "PC")
        local savedCross = UserConfigs[flagKey]
        if savedCross and savedCross ~= "RESET" then TextBox.Text = savedCross:gsub("rbxassetid://", "") end
        TextBox.PlaceholderText = "Texture ID..."
        TextBox.TextColor3 = Theme.TextDark
        TextBox.PlaceholderColor3 = Theme.TextDark
        TextBox.Font = Theme.Font
        TextBox.TextSize = 10
        TextBox.TextXAlignment = Enum.TextXAlignment.Left
        TextBox.ClearTextOnFocus = false
        TextBox.Parent = CInputContainer
        
        local ApplyBtn = Instance_new("TextButton")
        ApplyBtn.Size = UDim2_new(0, 55, 0, 20)
        ApplyBtn.Position = UDim2_new(1, -60, 0.5, -10)
        ApplyBtn.BackgroundColor3 = Color3_new(0,0,0)
        ApplyBtn.BackgroundTransparency = 0.45
        ApplyBtn.Text = "Apply"
        ApplyBtn.Font = Enum.Font.GothamBold
        ApplyBtn.TextSize = 10
        ApplyBtn.TextColor3 = Theme.TextDark
        ApplyBtn.Parent = CInputContainer
        Instance_new("UICorner", ApplyBtn).CornerRadius = UDim_new(0, 4)
        local apStr = Instance_new("UIStroke", ApplyBtn)
        apStr.Color = Color3_fromRGB(40,40,40)
        
        ApplyBtn.MouseButton1Click:Connect(function() 
            local id = TextBox.Text
            if id ~= "" then 
                local fullID = formatID(id)
                local flag = "TexturesPage_Crosshair_" .. (isMob and "Mobile" or "PC")
                UserConfigs[flag] = fullID
                if isMob then 
                    MobileCrosshair.Image = fullID
                    MobileCrosshair.Visible = true 
                else 
                    PCSoftwareCursor.Image = fullID
                    SetPCCursorActive(true)
                    PCSoftwareCursor.Visible = true 
                    updateMouseVisibility()
                end 
            end 
        end)

        local GridWrapperCur1 = createGridContainer(targetParentCur1)
        local GridWrapperCur2 = createGridContainer(targetParentCur2)
        
        for i, item in ipairs(CursorList) do
            local targetGrid = (i <= 18) and GridWrapperCur1 or GridWrapperCur2

            if item.ID == "RESET" then
                local defaultBtn = Instance_new("TextButton")
                defaultBtn.Text = "Default"
                defaultBtn.Font = Enum.Font.GothamBold
                defaultBtn.TextSize = 9
                defaultBtn.TextColor3 = Theme.TextDark
                defaultBtn.BackgroundColor3 = Color3_new(0,0,0)
                defaultBtn.BackgroundTransparency = 0.45
                defaultBtn.Parent = targetGrid
                Instance_new("UICorner", defaultBtn).CornerRadius = UDim_new(0, 4)
                local dStr = Instance_new("UIStroke", defaultBtn)
                dStr.Color = Color3_fromRGB(40,40,40)
                
                defaultBtn.MouseEnter:Connect(function() TweenService:Create(dStr, TweenInfo.new(0.2), {Color=Theme.Accent}):Play() TweenService:Create(defaultBtn, TweenInfo.new(0.2), {TextColor3=Theme.Accent}):Play() end)
                defaultBtn.MouseLeave:Connect(function() TweenService:Create(dStr, TweenInfo.new(0.2), {Color=Color3_fromRGB(40,40,40)}):Play() TweenService:Create(defaultBtn, TweenInfo.new(0.2), {TextColor3=Theme.TextDark}):Play() end)
                
                defaultBtn.MouseButton1Click:Connect(function() 
                    local flag = "TexturesPage_Crosshair_" .. (isMob and "Mobile" or "PC")
                    UserConfigs[flag] = "RESET"
                    if isMob then 
                        MobileCrosshair.Visible = false 
                    else 
                        SetPCCursorActive(false)
                        PCSoftwareCursor.Visible = false
                        UserInputService.MouseIconEnabled = true 
                        Mouse.Icon = ""
                    end 
                end)
            else
                local btn = Instance_new("ImageButton")
                btn.BackgroundColor3 = Color3_new(0,0,0)
                btn.BackgroundTransparency = 0.45
                btn.Image = "rbxassetid://" .. item.ID
                btn.ScaleType = Enum.ScaleType.Crop 
                btn.Parent = targetGrid
                Instance_new("UICorner", btn).CornerRadius = UDim_new(0, 4)
                local imgStr = Instance_new("UIStroke", btn)
                imgStr.Color = Color3_fromRGB(40,40,40)
                
                btn.MouseEnter:Connect(function() imgStr.Color = Theme.Accent end)
                btn.MouseLeave:Connect(function() imgStr.Color = Color3_fromRGB(40,40,40) end)
                
                btn.MouseButton1Click:Connect(function() 
                    local fullID = "rbxassetid://" .. item.ID
                    local flag = "TexturesPage_Crosshair_" .. (isMob and "Mobile" or "PC")
                    UserConfigs[flag] = fullID
                    if isMob then 
                        MobileCrosshair.Image = fullID
                        MobileCrosshair.Visible = true 
                    else 
                        PCSoftwareCursor.Image = fullID
                        SetPCCursorActive(true)
                        PCSoftwareCursor.Visible = true 
                        updateMouseVisibility()
                    end 
                end)
            end
        end
    end

    local usePCCursor = UserInputService.MouseEnabled
    if usePCCursor then CreateCursorSystem(false) else CreateCursorSystem(true) end

    if UserConfigs["TexturesPage_DoubleJump"] then task_spawn(function() EnableDoubleJumpEffect(UserConfigs["TexturesPage_DoubleJump"]) end) end
    if isMobile and UserConfigs["TexturesPage_MobileJump"] then task_spawn(function() EnableMobileButtonJump(UserConfigs["TexturesPage_MobileJump"]) end) end

    task_spawn(function()
        if usePCCursor then
            local saved = UserConfigs["TexturesPage_Crosshair_PC"]
            if saved and saved ~= "RESET" then
                PCSoftwareCursor.Image = saved
                SetPCCursorActive(true)
                PCSoftwareCursor.Visible = true 
                updateMouseVisibility()
            end
        else
            local saved = UserConfigs["TexturesPage_Crosshair_Mobile"]
            if saved and saved ~= "RESET" then
                MobileCrosshair.Image = saved
                MobileCrosshair.Visible = true 
            end
        end
    end)
end
