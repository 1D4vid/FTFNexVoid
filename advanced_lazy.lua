return function(Library, AdvancedPage, ScreenGui)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Workspace = game:GetService("Workspace")
    local Camera = Workspace.CurrentCamera
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local flyEnabled = false
    local flySpeed = 50
    local flyBg, flyBv
    local jpEnabled = false
    local jpVal = 120
    local originalJP = {}
    local jpRunConnection
    local wsEnabled = false
    local wsValue = 16
    local originalWS = {}
    local wsRunConnection
    local hbEnabled = false
    local hbShowVisual = false
    local hbSize = 2
    local hbLoop = nil
    local infJumpEnabled = false
    local infJumpConnection = nil
    local shiftlockEnabled = false
    local ShiftLockCrosshair = nil
    local userGameSettings = nil
    local unlockZoomEnabled = false
    local unlockZoomMax = 100000 
    local zoomPropertyConn = nil
    local originalZoom = LocalPlayer.CameraMaxZoomDistance
    local fastDoubleJumpEnabled = false
    local fastDoubleJumpConns = {}
    local fDJ_CD = 1
    local fDJ_JP = 36
    local disabledJumpConns = {}
    local fdjBackupState = {}
    local noHackFailEnabled = false
    local noHackFailThread = nil

    local function backupFDJ(c)
        local h = c:FindFirstChild("Humanoid")
        if h then
            fdjBackupState[c] = {
                UseJumpPower = h.UseJumpPower,
                JumpPower = h.JumpPower,
                JumpHeight = h.JumpHeight
            }
        end
    end
    local function restoreFDJBackup(c)
        local h = c and c:FindFirstChild("Humanoid")
        if h and fdjBackupState[c] then
            h.UseJumpPower = fdjBackupState[c].UseJumpPower
            h.JumpPower = fdjBackupState[c].JumpPower
            h.JumpHeight = fdjBackupState[c].JumpHeight
        end
    end
    local function killJumpFDJ(c)
        if not getconnections then return end
        for _,x in pairs(getconnections(UserInputService.JumpRequest))do
            pcall(function()
                local f=x.Function
                if type(f)=="function"then
                    local e=getfenv(f)
                    if e.script and e.script:IsDescendantOf(c)then
                        x:Disable()
                        table.insert(disabledJumpConns, x)
                    end
                end
            end)
        end
    end
    local function restoreJumpFDJ()
        for _, x in pairs(disabledJumpConns) do
            pcall(function() x:Enable() end)
        end
        table.clear(disabledJumpConns)
    end
    local function applyZoom()
        if unlockZoomEnabled then
            if LocalPlayer.CameraMaxZoomDistance < unlockZoomMax then
                LocalPlayer.CameraMaxZoomDistance = unlockZoomMax
            end
        end
    end
    local function enforceOfficialSync()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local cam = workspace.CurrentCamera
        if not hum then return end
        if not userGameSettings then pcall(function() userGameSettings = UserSettings():GetService("UserGameSettings") end) end
        if userGameSettings then
            if userGameSettings.RotationType ~= Enum.RotationType.CameraRelative then
                pcall(function() userGameSettings.RotationType = Enum.RotationType.CameraRelative end)
            end
        end
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        local dist = (cam.Focus.Position - cam.CFrame.Position).Magnitude
        if dist > 1 then 
            local rawCFrame = cam.CFrame
            cam.CFrame = rawCFrame * CFrame.new(1.75, 0, 0)
            cam.Focus = cam.CFrame * CFrame.new(0, 0, -dist)
        end
    end
    local function BackupJump(character)
        local hum = character:FindFirstChild("Humanoid")
        if hum then
            originalJP[character] = {
                JumpPower = hum.JumpPower,
                UseJumpPower = hum.UseJumpPower,
                JumpHeight = hum.JumpHeight
            }
        end
    end
    local function RestoreJump(character)
        local hum = character:FindFirstChild("Humanoid")
        if hum and originalJP[character] then
            hum.UseJumpPower = originalJP[character].UseJumpPower
            hum.JumpPower = originalJP[character].JumpPower
            hum.JumpHeight = originalJP[character].JumpHeight
        end
    end
    local function BackupSpeed(char)
        local hum = char:FindFirstChild("Humanoid")
        if hum then originalWS[char] = hum.WalkSpeed end
    end
    local function RestoreSpeed(char)
        local hum = char:FindFirstChild("Humanoid")
        if hum and originalWS[char] then hum.WalkSpeed = originalWS[char] end
    end
    local function updateHitboxes()
		for _, v in pairs(Players:GetPlayers()) do
			if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = v.Character.HumanoidRootPart
				local targetSize = Vector3.new(hbSize, hbSize, hbSize)
				if hrp.Size ~= targetSize then hrp.Size = targetSize end
				local targetTrans = hbShowVisual and 0.6 or 1
				if hrp.Transparency ~= targetTrans then hrp.Transparency = targetTrans end
				hrp.CanCollide = false
			end
		end
	end

	Library:CreateSection(AdvancedPage, "Players")
    Library:CreateToggle(AdvancedPage, "Auto Interact", false, function(state)
        if not getgenv().NexAutoInteract then
            getgenv().NexAutoInteract = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/autointeract.lua"))()
        end
        getgenv().NexAutoInteract.Toggle(state)
    end)
    Library:CreateToggle(AdvancedPage, "Noclip Cam", false, function(state)
        if state then
            LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
        else
            LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
        end
    end)
    
    local fdjConnection = nil
    Library:CreateToggle(AdvancedPage, "Fast Double Jump", false, function(state)
        local P = game:GetService("Players")
        local U = game:GetService("UserInputService")
        local R = game:GetService("RunService")
        local D = game:GetService("Debris")
        local plr = P.LocalPlayer
        if state then
            local CD = 0.6
            local JP = 36

            if getgenv().ConexoesFTF then
                for _,c in pairs(getgenv().ConexoesFTF)do pcall(function()c:Disconnect()end) end
            end
            getgenv().ConexoesFTF={}

            if getgenv().PulosOriginais then
                for _,x in pairs(getgenv().PulosOriginais)do pcall(function()x:Enable()end) end
            end
            getgenv().PulosOriginais={}

            local function killJump(c)
                if not getconnections then return end
                for _,x in pairs(getconnections(U.JumpRequest))do
                    pcall(function()
                        local f=x.Function
                        if type(f)=="function"then
                            local e=getfenv(f)
                            if e.script and e.script:IsDescendantOf(c)then
                                table.insert(getgenv().PulosOriginais,x)
                                x:Disable()
                            end
                        end
                    end)
                end
            end

            local function cloud(r)
                if not r then return end
                local p=Instance.new("Part")
                p.Transparency=1
                p.Size=Vector3.new(.1,.1,.1)
                p.CanCollide=false
                p.Massless=true
                p.Anchored=true
                p.CFrame=CFrame.new(r.Position.X,r.Position.Y-3.2,r.Position.Z)*r.CFrame.Rotation
                p.Parent=workspace

                local pe=Instance.new("ParticleEmitter")
                pe.LightInfluence=0
                pe.Brightness=2
                pe.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.6),NumberSequenceKeypoint.new(.05,1.2),NumberSequenceKeypoint.new(1,.4)})
                pe.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.7,0),NumberSequenceKeypoint.new(1,1)})
                pe.EmissionDirection=Enum.NormalId.Front
                pe.Lifetime=NumberRange.new(.3)
                pe.Rate=0
                pe.Speed=NumberRange.new(12)
                pe.Acceleration=Vector3.new(0,4,0)
                pe.SpreadAngle=Vector2.new(0,180)
                pe.Shape=Enum.ParticleEmitterShape.Disc
                pe.ShapeStyle=Enum.ParticleEmitterShapeStyle.Surface
                pe.LockedToPart=true
                pe.Parent=p
                pe:Emit(24)
                D:AddItem(p,.5)
            end

            local function spark(c)
                if not c then return end
                local g=c:FindFirstChild("PackedGemstone")
                local a=(g and g:FindFirstChild("Handle")) or c:FindFirstChild("Right Arm")
                if not a then return end

                local p=Instance.new("Part")
                p.Transparency=1
                p.Size=Vector3.new(.1,.1,.1)
                p.CanCollide=false
                p.Massless=true
                p.Parent=workspace

                local w=Instance.new("Weld")
                w.Part0=p
                w.Part1=a
                w.C0=g and CFrame.new() or CFrame.new(.4,.6,.7)
                w.Parent=p

                local pe=Instance.new("ParticleEmitter")
                pe.LightInfluence=0
                pe.Brightness=2
                pe.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.1,.6),NumberSequenceKeypoint.new(1,0)})
                pe.EmissionDirection=Enum.NormalId.Top
                pe.Lifetime=NumberRange.new(.8)
                pe.Rate=0
                pe.RotSpeed=NumberRange.new(270)
                pe.Speed=NumberRange.new(0)
                pe.Shape=g and Enum.ParticleEmitterShape.Disc or Enum.ParticleEmitterShape.Surface
                pe.ShapeStyle=g and Enum.ParticleEmitterShapeStyle.Surface or Enum.ParticleEmitterShapeStyle.Volume
                pe.LockedToPart=true
                pe.Parent=p

                pe:Emit(1)
                D:AddItem(p,1)
            end

            local function start(c)
                task.spawn(function()
                    task.wait(1)
                    killJump(c)
                end)

                local h=c:WaitForChild("Humanoid",5)
                local r=c:WaitForChild("HumanoidRootPart",5)
                if not h or not r then return end

                local air=true
                local lj=0
                local ld=0
                local cd=false
                local j=false

                local hb=R.Heartbeat:Connect(function()
                    if not h or not h.Parent then return end
                    if j and not h.Jump then lj=time() end
                    if cd and time()-ld>=CD then
                        cd=false
                        task.spawn(function()spark(c)end)
                    end
                    j=h.Jump
                end)
                table.insert(getgenv().ConexoesFTF,hb)

                local st=h.StateChanged:Connect(function(_,n)
                    if n==Enum.HumanoidStateType.Landed and not h.Jump then
                        air=true
                    end
                end)
                table.insert(getgenv().ConexoesFTF,st)

                local jm=U.JumpRequest:Connect(function()
                    if not h or not r or not r.Parent then return end

                    local p=RaycastParams.new()
                    p.FilterType=Enum.RaycastFilterType.Exclude
                    p.FilterDescendantsInstances={c}
                    p.RespectCanCollide=true
                    pcall(function()p.CollisionGroup="PLAYERS_BODIES"end)

                    local d=16
                    local ok,hit=pcall(function()
                        return workspace:Blockcast(r.CFrame,Vector3.new(2.2,2,1.4),Vector3.new(0,-16,0),p)
                    end)
                    if ok and hit then d=hit.Distance end

                    local s=h:GetState()

                    if air and d>3.5 and r.AssemblyLinearVelocity.Y<16
                    and s==Enum.HumanoidStateType.Freefall
                    and h.FloorMaterial==Enum.Material.Air
                    and time()-lj>=.05
                    and time()-ld>=CD then

                        air=false
                        r.AssemblyLinearVelocity=Vector3.new(0,JP,0)
                        ld=time()
                        cd=true
                        cloud(r)
                    end
                end)
                table.insert(getgenv().ConexoesFTF,jm)
            end

            if plr.Character then start(plr.Character) end
            fdjConnection = plr.CharacterAdded:Connect(function(c)
                start(c)
            end)
            table.insert(getgenv().ConexoesFTF, fdjConnection)
        else
            if fdjConnection then fdjConnection:Disconnect(); fdjConnection = nil end
            if getgenv().ConexoesFTF then
                for _,c in pairs(getgenv().ConexoesFTF)do pcall(function()c:Disconnect()end) end
            end
            getgenv().ConexoesFTF={}

            if getgenv().PulosOriginais then
                for _,x in pairs(getgenv().PulosOriginais)do pcall(function()x:Enable()end) end
            end
            getgenv().PulosOriginais={}
        end
    end)
    
    LocalPlayer.CharacterAdded:Connect(function(c)
        if shiftlockEnabled then
            RunService:UnbindFromRenderStep("FinalNailSync")
            task.wait(0.000005)
            RunService:BindToRenderStep("FinalNailSync", Enum.RenderPriority.Camera.Value + 1, enforceOfficialSync)
        end
    end)
    Library:CreateToggle(AdvancedPage, "Inf Jump", false, function(state)
        infJumpEnabled = state
        if state then
            if not infJumpConnection then
                infJumpConnection = UserInputService.JumpRequest:Connect(function()
                    if infJumpEnabled then
                        pcall(function()
                            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                        end)
                    end
                end)
            end
        else
            if infJumpConnection then
                infJumpConnection:Disconnect()
                infJumpConnection = nil
            end
        end
    end)
    Library:CreateToggle(AdvancedPage, "Shiftlock", false, function(state)
        shiftlockEnabled = state
        if state then
            if not ShiftLockCrosshair then
                ShiftLockCrosshair = Instance.new("ImageLabel")
                ShiftLockCrosshair.Name = "ShiftLockCrosshair"
                ShiftLockCrosshair.AnchorPoint = Vector2.new(0.5, 0.5)
                ShiftLockCrosshair.Position = UDim2.new(0.5, 0, 0.5, -29)
                ShiftLockCrosshair.Size = UDim2.new(0.04, 0, 0.04, 0) 
                ShiftLockCrosshair.BackgroundTransparency = 1
                ShiftLockCrosshair.Image = "rbxasset://textures/MouseLockedCursor.png"
                ShiftLockCrosshair.Visible = true
                ShiftLockCrosshair.ZIndex = 10
                local aspect = Instance.new("UIAspectRatioConstraint")
                aspect.AspectRatio = 1
                aspect.Parent = ShiftLockCrosshair
                ShiftLockCrosshair.Parent = ScreenGui 
            else
                ShiftLockCrosshair.Visible = true
            end
            RunService:BindToRenderStep("FinalNailSync", Enum.RenderPriority.Camera.Value + 1, enforceOfficialSync)
        else
            if ShiftLockCrosshair then ShiftLockCrosshair.Visible = false end
            RunService:UnbindFromRenderStep("FinalNailSync")
            pcall(function()
                if userGameSettings then
                    userGameSettings.RotationType = Enum.RotationType.MovementRelative
                end
            end)
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end)
    Library:CreateToggle(AdvancedPage, "Unlock Zoom Cam", false, function(state)
        unlockZoomEnabled = state
        if state then
            originalZoom = LocalPlayer.CameraMaxZoomDistance
            applyZoom()
            if not zoomPropertyConn then
                zoomPropertyConn = LocalPlayer:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(applyZoom)
            end
        else
            if zoomPropertyConn then zoomPropertyConn:Disconnect(); zoomPropertyConn = nil end
            LocalPlayer.CameraMaxZoomDistance = originalZoom 
        end
    end)
    
    Library:CreateToggleKeybind(AdvancedPage, "Fly", false, "None", function(state) 
        flyEnabled = state
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        if state then
            if hum then hum.PlatformStand = true end
            flyBg = Instance.new("BodyGyro", hrp)
            flyBg.P = 9e4
            flyBg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBg.CFrame = hrp.CFrame
            flyBv = Instance.new("BodyVelocity", hrp)
            flyBv.Velocity = Vector3.new(0, 0, 0)
            flyBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        else
            if hum then hum.PlatformStand = false end
            if flyBg then flyBg:Destroy() flyBg = nil end
            if flyBv then flyBv:Destroy() flyBv = nil end
        end
    end)
    Library:CreateSlider(AdvancedPage, "Fly Speed", 10, 200, 50, function(val) flySpeed = val end)
    RunService.RenderStepped:Connect(function()
        if flyEnabled and flyBg and flyBv and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local hum = LocalPlayer.Character.Humanoid
            flyBg.CFrame = CFrame.new(hrp.Position, hrp.Position + Camera.CFrame.LookVector)
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                local camLook = Camera.CFrame.LookVector
                local camRight = Camera.CFrame.RightVector
                local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
                local flatRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
                local forwardInput = moveDir:Dot(flatLook)
                local rightInput = moveDir:Dot(flatRight)
                local flyVelocity = (Camera.CFrame.LookVector * forwardInput) + (Camera.CFrame.RightVector * rightInput)
                flyBv.Velocity = flyVelocity.Unit * flySpeed
            else
                flyBv.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end)
    local noclipConnection
    Library:CreateToggleKeybind(AdvancedPage, "No clip", false, "None", function(state) 
        if state then
            if not noclipConnection then
                noclipConnection = RunService.Stepped:Connect(function()
                    if LocalPlayer.Character then
                        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            end
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
        end
    end)
    Library:CreateToggleKeybind(AdvancedPage, "Jump Power", false, "None", function(state) 
        jpEnabled = state 
        if state then
            if LocalPlayer.Character then BackupJump(LocalPlayer.Character) end
            if not jpRunConnection then
                jpRunConnection = RunService.Stepped:Connect(function()
                    if jpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        local hum = LocalPlayer.Character.Humanoid
                        if not originalJP[LocalPlayer.Character] then BackupJump(LocalPlayer.Character) end
                        hum.UseJumpPower = true
                        hum.JumpPower = jpVal
                        hum.JumpHeight = jpVal / 2
                    end
                end)
            end
        else
            if jpRunConnection then jpRunConnection:Disconnect() jpRunConnection = nil end
            if LocalPlayer.Character then RestoreJump(LocalPlayer.Character) end
        end
    end)
    Library:CreateSlider(AdvancedPage, "Jump Power Val", 50, 300, 120, function(val) jpVal = val end)
    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid", 5)
        if jpEnabled then BackupJump(char) end
    end)
    Library:CreateToggleKeybind(AdvancedPage, "Walkspeed", false, "None", function(state) 
        wsEnabled = state 
        if state then
            if LocalPlayer.Character then BackupSpeed(LocalPlayer.Character) end
            if not wsRunConnection then
                wsRunConnection = RunService.Stepped:Connect(function()
                    if wsEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        local hum = LocalPlayer.Character.Humanoid
                        if not originalWS[LocalPlayer.Character] then BackupSpeed(LocalPlayer.Character) end
                        hum.WalkSpeed = wsValue
                    end
                end)
            end
        else
            if wsRunConnection then wsRunConnection:Disconnect() wsRunConnection = nil end
            if LocalPlayer.Character then RestoreSpeed(LocalPlayer.Character) end
        end
    end)
	Library:CreateSlider(AdvancedPage, "Speed Value", 16, 200, 16, function(val) wsValue = val end)
    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid", 5)
        if wsEnabled then BackupSpeed(char) end
    end)

	Library:CreateSection(AdvancedPage, "Beast")
    local njdEnabledLocal = false
    local njdConnectionLocal = nil
    local njdBackupSpeed = 16
    local function checkNJD(c)
        if not c then return false end
        if c:FindFirstChildOfClass("Tool") then return true end
        if c:FindFirstChild("Hammer") then return true end
        return false
    end
    local function bindNJDLocal(c)
        local h = c:WaitForChild("Humanoid", 5)
        if not h then return end
        njdBackupSpeed = checkNJD(c) and 16.5 or 16
        njdConnectionLocal = h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if njdEnabledLocal and h.WalkSpeed < njdBackupSpeed and checkNJD(c) then
                h.WalkSpeed = njdBackupSpeed
            end
        end)
    end
	Library:CreateToggle(AdvancedPage, "No Jump Delay", false, function(state) 
        njdEnabledLocal = state
        if state then
            if LocalPlayer.Character then bindNJDLocal(LocalPlayer.Character) end
        else
            if njdConnectionLocal then 
                njdConnectionLocal:Disconnect() 
                njdConnectionLocal = nil 
            end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = checkNJD(LocalPlayer.Character) and 16.5 or 16
            end
        end
    end)
    LocalPlayer.CharacterAdded:Connect(function(c) if njdEnabledLocal then bindNJDLocal(c) end end)
	Library:CreateToggle(AdvancedPage, "Hitbox extender", false, function(state) 
        hbEnabled = state
        if state then 
            hbLoop = task.spawn(function()
                while hbEnabled do
                    updateHitboxes()
                    task.wait(1)
                end
            end)
        else 
            if hbLoop then task.cancel(hbLoop) hbLoop = nil end
            for _, v in pairs(Players:GetPlayers()) do 
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then 
                    v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                    v.Character.HumanoidRootPart.Transparency = 1
                    v.Character.HumanoidRootPart.CanCollide = true 
                end 
            end 
        end 
    end)
    Library:CreateInput(AdvancedPage, "Hitbox Size", 2, function(val) hbSize = val end)
	
    Library:CreateSection(AdvancedPage, "Survivor")
	Library:CreateToggle(AdvancedPage, "Fling", false, function(state)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if state then
            if not hrp or not hum then return end
            getgenv().FlingAtivo = true
            getgenv().FlingNoclip = RunService.Stepped:Connect(function()
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            getgenv().FlingGiro = RunService.Heartbeat:Connect(function()
                if not char or not char.Parent or hum.Health <= 0 then return end
                hrp.AssemblyAngularVelocity = Vector3.new(0, 50000, 0)
                local direcao = hum.MoveDirection * hum.WalkSpeed
                hrp.AssemblyLinearVelocity = Vector3.new(direcao.X, hrp.AssemblyLinearVelocity.Y, direcao.Z)
            end)
        else
            getgenv().FlingAtivo = false
            if getgenv().FlingNoclip then getgenv().FlingNoclip:Disconnect() end
            if getgenv().FlingGiro then getgenv().FlingGiro:Disconnect() end
            if hrp then
                hrp.AssemblyAngularVelocity = Vector3.zero
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
	end)
    
	Library:CreateToggle(AdvancedPage, "No hack fail", false, function(state) 
        noHackFailEnabled = state
        getgenv().AutoAcertar = state
        if state then
            if noHackFailThread then task.cancel(noHackFailThread) end
            noHackFailThread = task.spawn(function()
                local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvent")
                while getgenv().AutoAcertar do
                    task.wait(0.1) 
                    pcall(function()
                        if remoteEvent then
                            remoteEvent:FireServer("SetPlayerMinigameResult", true)
                        end
                    end)
                end
            end)
        else
            getgenv().AutoAcertar = false
            if noHackFailThread then task.cancel(noHackFailThread) noHackFailThread = nil end
        end
    end)
    Library:CreateToggle(AdvancedPage, "auto save", false, function(state) 
        if not getgenv().NexAutoSave then
            getgenv().NexAutoSave = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/autosave.lua"))()
        end
        getgenv().NexAutoSave.Toggle(state)
    end)
end
