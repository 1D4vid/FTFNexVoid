local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
	repeat task.wait() until Players.LocalPlayer
	LocalPlayer = Players.LocalPlayer
end

local viewport
local s, r = pcall(function() return gethui() end)
if s and r then 
    viewport = r 
else
    s, r = pcall(function() return getgenv().gethui() end)
    if s and r then 
        viewport = r 
    else
        s, r = pcall(function() return game:GetService("CoreGui") end)
        if s and r then
            viewport = r
        else
            viewport = LocalPlayer:WaitForChild("PlayerGui")
        end
    end
end

pcall(function()
	if LocalPlayer.PlayerGui:FindFirstChild("NexVoidHub") then LocalPlayer.PlayerGui.NexVoidHub:Destroy() end
	if viewport:FindFirstChild("NexVoidHub") then viewport.NexVoidHub:Destroy() end
end)

local function SendNotification(text, duration)
	pcall(function() game.StarterGui:SetCore("SendNotification", {Title = "NexVoidHub", Text = text, Duration = duration or 3}) end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexVoidHub"
ScreenGui.Parent = viewport
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 10000 
ScreenGui.Enabled = false 

local Theme = {
	FrameColor = Color3.fromRGB(12, 12, 12),
	ContentColor = Color3.fromRGB(20, 20, 20),
	ItemColor = Color3.fromRGB(30, 30, 30),
	ItemStroke = Color3.fromRGB(60, 60, 60),
	SwitchOff = Color3.fromRGB(40, 40, 40), 
	Accent = Color3.fromRGB(240, 240, 240),
    AccentDark = Color3.fromRGB(160, 160, 160),
	Text = Color3.fromRGB(255, 255, 255), 
	TextDark = Color3.fromRGB(150, 150, 150),
	Font = Enum.Font.GothamBold,
	CloseRed = Color3.fromRGB(100, 100, 100)
}

local EspConfig = {
    OnlyBeast = false,
    HideNames = true, -- Ativado por padrão
    Survivor = Color3.fromRGB(0, 255, 0),
    Beast = Color3.fromRGB(255, 0, 0),
    Pod = Color3.fromRGB(0, 255, 255),
    BeastHighlight = Color3.fromRGB(0, 255, 255),
    ComputerOutlineOnly = false
}

local LegitSettings = {MuteSteps = false, MuteJumps = false, MuteHack = false}
local CurrentSoundIDs = {Running = 0, Jumping = 0, Landing = 0}
local OriginalSoundBackups = {}

local function formatID(id)
	if type(id) == "number" and id > 0 then return "rbxassetid://" .. id
	elseif type(id) == "string" and id ~= "" and id ~= "0" then
        if not id:find("rbxassetid://") then return "rbxassetid://" .. id else return id end
	end
	return nil
end

local function replaceSounds(character)
	task.spawn(function()
		local rootPart = character:WaitForChild("HumanoidRootPart", 10)
		if not rootPart then return end
		task.wait(0.5)
        if not OriginalSoundBackups[character] then
            OriginalSoundBackups[character] = {}
            for name, _ in pairs(CurrentSoundIDs) do
                local existingSound = rootPart:FindFirstChild(name)
                if existingSound and existingSound:IsA("Sound") then OriginalSoundBackups[character][name] = existingSound.SoundId end
            end
        end
		for soundName, soundId in pairs(CurrentSoundIDs) do
            local sound = rootPart:FindFirstChild(soundName)
            if soundId == 0 then
                if sound and OriginalSoundBackups[character] and OriginalSoundBackups[character][soundName] then
                    sound.SoundId = OriginalSoundBackups[character][soundName]
                end
            else
                local validId = formatID(soundId)
                if validId then
                    if sound and sound:IsA("Sound") then sound.SoundId = validId
                    else
                        local newSound = Instance.new("Sound")
                        newSound.Name = soundName
                        newSound.Parent = rootPart
                        newSound.SoundId = validId
                    end
                end
            end
		end
	end)
end

local function RefreshAllSounds() for _, player in ipairs(Players:GetPlayers()) do if player.Character then replaceSounds(player.Character) end end end
local function setupPlayerSoundEvents(player)
	if player.Character then replaceSounds(player.Character) end
	player.CharacterAdded:Connect(function(newCharacter) replaceSounds(newCharacter) end)
end
for _, player in ipairs(Players:GetPlayers()) do setupPlayerSoundEvents(player) end
Players.PlayerAdded:Connect(setupPlayerSoundEvents)

local function ProcessCharacter(char)
	local root = char:WaitForChild("HumanoidRootPart", 10)
    if not root then return end
    local function MuteLogic(soundObj, typeName)
        if not soundObj then return end
        local targetVol = 0.5
        if typeName == "Running" then targetVol = 0.65 end
        if char == LocalPlayer.Character then
            if typeName == "Running" and LegitSettings.MuteSteps then targetVol = 0 end
            if (typeName == "Jumping" or typeName == "Landing") and LegitSettings.MuteJumps then targetVol = 0 end
        end
        soundObj.Volume = targetVol
        soundObj:GetPropertyChangedSignal("Volume"):Connect(function()
            if char == LocalPlayer.Character then
                if typeName == "Running" and LegitSettings.MuteSteps then soundObj.Volume = 0 
                elseif (typeName == "Jumping" or typeName == "Landing") and LegitSettings.MuteJumps then soundObj.Volume = 0 end
            end
        end)
    end
    task.spawn(function()
        local s1 = root:WaitForChild("Running", 5)
        if s1 then MuteLogic(s1, "Running") end
        local s2 = root:WaitForChild("Jumping", 5)
        if s2 then MuteLogic(s2, "Jumping") end
        local s3 = root:WaitForChild("Landing", 5)
        if s3 then MuteLogic(s3, "Landing") end
    end)
end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(ProcessCharacter) end)
for _, p in pairs(Players:GetPlayers()) do if p.Character then ProcessCharacter(p.Character) end
p.CharacterAdded:Connect(ProcessCharacter) end

local CurrentCursorSize = 24
local PCCursorActive = false
local MobileCrosshair = Instance.new("ImageLabel")
MobileCrosshair.Name = "MobileCrosshair"
MobileCrosshair.Size = UDim2.new(0, CurrentCursorSize, 0, CurrentCursorSize)
MobileCrosshair.AnchorPoint = Vector2.new(0.5, 0.5)
MobileCrosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
MobileCrosshair.BackgroundTransparency = 1
MobileCrosshair.Visible = false
MobileCrosshair.ZIndex = 99
MobileCrosshair.Parent = ScreenGui 

local PCSoftwareCursor = Instance.new("ImageLabel")
PCSoftwareCursor.Name = "PCCursor"
PCSoftwareCursor.Size = UDim2.new(0, CurrentCursorSize, 0, CurrentCursorSize)
PCSoftwareCursor.AnchorPoint = Vector2.new(0.5, 0.5)
PCSoftwareCursor.BackgroundTransparency = 1
PCSoftwareCursor.Visible = false
PCSoftwareCursor.ZIndex = 10000
PCSoftwareCursor.Parent = ScreenGui

local function UpdateCursorSizes(val) 
    CurrentCursorSize = val
    MobileCrosshair.Size = UDim2.new(0, val, 0, val)
    PCSoftwareCursor.Size = UDim2.new(0, val, 0, val) 
end

RunService.RenderStepped:Connect(function() 
    if PCCursorActive then 
        UserInputService.MouseIconEnabled = false
        local mousePos = UserInputService:GetMouseLocation()
        PCSoftwareCursor.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y) 
    else 
        if UserInputService.MouseIconEnabled == false and not PCCursorActive then 
            UserInputService.MouseIconEnabled = true 
        end 
    end 
end)

local function ApplyGradient(instance, color1, color2, rotation)
    local gradient = instance:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, color1), ColorSequenceKeypoint.new(1.00, color2)}
    gradient.Rotation = rotation or 45
    gradient.Parent = instance
    return gradient
end

local AnimatedTextGradients = {}
local function ApplyAnimatedTextGradient(instance)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(120, 120, 120)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(170, 170, 170)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.65, Color3.fromRGB(170, 170, 170)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(120, 120, 120))
    }
    gradient.Rotation = 20
    gradient.Parent = instance
    table.insert(AnimatedTextGradients, gradient)
    return gradient
end

RunService.RenderStepped:Connect(function()
    local time = tick() * 0.6 
    local offset = (time % 2) - 1 
    for _, grad in ipairs(AnimatedTextGradients) do
        if grad.Parent then
            grad.Offset = Vector2.new(offset, 0)
        end
    end
end)

local isMobile = UserInputService.TouchEnabled

local ConfigFileName = "NexVoidHub_Config.json"
local UserConfigs = { ToggleKey = "K" }

local function LoadConfigs()
	pcall(function()
		if isfile and isfile(ConfigFileName) and readfile then
			local content = readfile(ConfigFileName)
            if content then
                local decoded = HttpService:JSONDecode(content)
                if type(decoded) == "table" then
                    for k, v in pairs(decoded) do
                        UserConfigs[k] = v
                    end
                end
            end
		end
	end)
end
LoadConfigs()

local CurrentKey = Enum.KeyCode[UserConfigs.ToggleKey] or Enum.KeyCode.K

local function SaveConfigs()
	UserConfigs.ToggleKey = CurrentKey.Name
	pcall(function()
		if writefile then writefile(ConfigFileName, HttpService:JSONEncode(UserConfigs)) end
	end)
end

local function ResetConfigs()
	pcall(function()
		if delfile and isfile and isfile(ConfigFileName) then
			delfile(ConfigFileName)
		end
	end)
	UserConfigs = { ToggleKey = "K" }
	CurrentKey = Enum.KeyCode.K
end

local Config = {
	MainSize = isMobile and UDim2.new(0, 520, 0, 365) or UDim2.new(0, 600, 0, 420),
	SidebarWidth = isMobile and 130 or 150,
	FooterHeight = 18, 
	BtnHeight = isMobile and 24 or 28, 
	ListPadding = UDim.new(0, 2), 
	FontSize = isMobile and 10 or 12,
	IconSize = isMobile and 13 or 16
}

local ContentConfig = {
	ItemHeight = 40,
	PlayerCardHeight = 50,
	ItemPadding = UDim.new(0, 6)
}

local function MakeDraggable(triggerObject, frameObject)
	local dragging = false
	local dragInput, dragStart, startPos
	triggerObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
            dragStart = input.Position
            startPos = frameObject.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	triggerObject.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frameObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = Config.MainSize
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.6, 0)
MainFrame.BackgroundColor3 = Theme.FrameColor 
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.ClipsDescendants = true
MainFrame.Visible = false 
MainFrame.Parent = ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2
ApplyGradient(MainStroke, Theme.Accent, Color3.fromRGB(20,20,20), -45)

local AnimeBg = Instance.new("ImageLabel")
AnimeBg.Name = "AnimeBackground"
AnimeBg.Size = UDim2.new(1, 0, 1, 0)
AnimeBg.Image = "rbxassetid://131818010442196"
AnimeBg.ScaleType = Enum.ScaleType.Crop
AnimeBg.BackgroundTransparency = 1
AnimeBg.ZIndex = 1
AnimeBg.Parent = MainFrame

local DarkOverlay = Instance.new("Frame")
DarkOverlay.Name = "DarkOverlay"
DarkOverlay.Size = UDim2.new(1, 0, 1, 0)
DarkOverlay.BackgroundColor3 = Color3.new(0,0,0)
DarkOverlay.BackgroundTransparency = 0.65 
DarkOverlay.ZIndex = 2
DarkOverlay.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.new(0,0,0)
TopBar.BackgroundTransparency = 0.5
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 3
TopBar.Parent = MainFrame
MakeDraggable(TopBar, MainFrame)

local TopDiv = Instance.new("Frame")
TopDiv.Size = UDim2.new(1,0,0,1)
TopDiv.Position = UDim2.new(0,0,1,0)
TopDiv.BorderSizePixel=0
TopDiv.Parent = TopBar
ApplyGradient(TopDiv, Color3.new(0,0,0), Theme.Accent, 0) 

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Text = "Nex<font color='rgb(150,150,150)'>Void V2.3</font>"
TitleLabel.RichText = true
TitleLabel.Size = UDim2.new(0, 180, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Theme.Font
TitleLabel.TextSize = 18
TitleLabel.TextColor3 = Theme.Text
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Position = UDim2.new(0, 45, 0, 0)
TitleLabel.ZIndex = 4
TitleLabel.Parent = TopBar

local OpenButton = Instance.new("ImageButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 45, 0, 45)
OpenButton.AnchorPoint = Vector2.new(0, 0)
OpenButton.Position = UDim2.new(0, 15, 0, 60)
OpenButton.BackgroundColor3 = Theme.FrameColor
OpenButton.Image = "rbxassetid://138188957887846"
OpenButton.Visible = false
OpenButton.Active = true
OpenButton.Draggable = true
OpenButton.Parent = ScreenGui
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 4)
local OBS = Instance.new("UIStroke")
OBS.Color = Theme.Accent
OBS.Thickness = 1.5
OBS.Parent = OpenButton
ApplyGradient(OBS, Theme.Accent, Color3.fromRGB(50,50,50), 45)
MakeDraggable(OpenButton, OpenButton)

local function createTopBtn(name, icon, offsetOrder, isImage)
	local Btn
	if isImage then
		Btn = Instance.new("ImageButton")
        Btn.Image = "rbxassetid://" .. icon
        Btn.ScaleType = Enum.ScaleType.Fit
        Btn.ImageTransparency = 1
        local Inner = Instance.new("ImageLabel")
        Inner.Size = UDim2.new(0, 16, 0, 16)
        Inner.Position = UDim2.new(0.5, -8, 0.5, -8)
        Inner.BackgroundTransparency = 1
        Inner.Image = "rbxassetid://" .. icon
        Inner.ImageColor3 = Theme.TextDark
        Inner.ScaleType = Enum.ScaleType.Fit
        Inner.ZIndex = 4
        Inner.Parent = Btn
        Btn.MouseEnter:Connect(function() Inner.ImageColor3 = Theme.Accent end)
        Btn.MouseLeave:Connect(function() Inner.ImageColor3 = Theme.TextDark end)
	else
		Btn = Instance.new("TextButton")
        Btn.Text = icon
        Btn.Font = Enum.Font.GothamBlack
        Btn.TextSize = 16
        Btn.TextColor3 = Theme.TextDark
        if icon == "-" then
            Btn.Text = ""
            local Line = Instance.new("Frame")
            Line.Size = UDim2.new(0, 12, 0, 2)
            Line.Position = UDim2.new(0.5, -6, 0.5, 0)
            Line.BackgroundColor3 = Theme.TextDark
            Line.BorderSizePixel = 0
            Line.ZIndex = 4
            Line.Parent = Btn
            Btn.MouseEnter:Connect(function() Line.BackgroundColor3 = Theme.Accent end)
            Btn.MouseLeave:Connect(function() Line.BackgroundColor3 = Theme.TextDark end)
        else
            Btn.MouseEnter:Connect(function() Btn.TextColor3 = Theme.CloseRed end)
            Btn.MouseLeave:Connect(function() Btn.TextColor3 = Theme.TextDark end)
        end
	end
	Btn.Name = name
    Btn.Parent = TopBar
    Btn.BackgroundTransparency = 1
    Btn.ZIndex = 4
    Btn.Position = UDim2.new(1, -(40 * offsetOrder), 0, 0)
    Btn.Size = UDim2.new(0, 40, 1, 0)
    return Btn
end

local CloseBtn = createTopBtn("Close", "X", 1, false)
local MinimizeBtn = createTopBtn("Minimize", "-", 2, false)
local SettingsBtn = createTopBtn("Settings", "11293977610", 3, true)

local SearchContainer = Instance.new("Frame")
SearchContainer.Name = "SearchContainer"
SearchContainer.Size = UDim2.new(0, 130, 0, 26) 
SearchContainer.Position = UDim2.new(1, -135, 0.5, 0)
SearchContainer.AnchorPoint = Vector2.new(1, 0.5)
SearchContainer.BackgroundColor3 = Theme.ContentColor
SearchContainer.BorderSizePixel = 0
SearchContainer.ClipsDescendants = true
SearchContainer.ZIndex = 4
SearchContainer.Parent = TopBar
Instance.new("UICorner", SearchContainer).CornerRadius = UDim.new(0, 4)

local SearchIcon = Instance.new("ImageLabel")
SearchIcon.Size = UDim2.new(0, 14, 0, 14)
SearchIcon.Position = UDim2.new(0, 8, 0.5, -7)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Image = "rbxassetid://104986431790017"
SearchIcon.ImageColor3 = Theme.TextDark
SearchIcon.ZIndex = 5
SearchIcon.Parent = SearchContainer

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -30, 1, 0)
SearchBox.Position = UDim2.new(0, 28, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.Text = ""
SearchBox.PlaceholderText = "Search..."
SearchBox.TextColor3 = Theme.Text
SearchBox.PlaceholderColor3 = Theme.TextDark
SearchBox.Font = Theme.Font
SearchBox.TextSize = 11
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.ZIndex = 5
SearchBox.Parent = SearchContainer

local CenterContainer = Instance.new("Frame")
CenterContainer.Name = "CenterContainer"
CenterContainer.Size = UDim2.new(1, 0, 1, -(40 + Config.FooterHeight))
CenterContainer.Position = UDim2.new(0, 0, 0, 40)
CenterContainer.BackgroundTransparency = 1
CenterContainer.ZIndex = 3
CenterContainer.Parent = MainFrame

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, Config.SidebarWidth, 1, 0)
Sidebar.BackgroundColor3 = Color3.new(0,0,0)
Sidebar.BackgroundTransparency = 0.6
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3
Sidebar.Parent = CenterContainer

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = Config.ListPadding
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar
local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 5)
SidebarPadding.PaddingBottom = UDim.new(0, 5)
SidebarPadding.Parent = Sidebar 

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -Config.SidebarWidth, 1, 0)
ContentArea.Position = UDim2.new(0, Config.SidebarWidth, 0, 0)
ContentArea.BackgroundColor3 = Color3.new(0,0,0)
ContentArea.BackgroundTransparency = 0.7
ContentArea.BorderSizePixel = 0
ContentArea.ZIndex = 3
ContentArea.Parent = CenterContainer 

local BottomBar = Instance.new("Frame")
BottomBar.Size = UDim2.new(1, 0, 0, Config.FooterHeight)
BottomBar.Position = UDim2.new(0, 0, 1, -Config.FooterHeight)
BottomBar.BackgroundColor3 = Color3.new(0,0,0)
BottomBar.BackgroundTransparency = 0.5
BottomBar.BorderSizePixel = 0
BottomBar.ZIndex = 5
BottomBar.Parent = MainFrame

local StatsText = Instance.new("TextLabel")
StatsText.RichText = true
StatsText.Text = "FPS: 0 | Ping: 0 | clock: 00:00 | Time On Nexvoid: 00:00"
StatsText.Size = UDim2.new(1, -5, 1, 0)
StatsText.Position = UDim2.new(0, 5, 0, 0)
StatsText.BackgroundTransparency = 1
StatsText.TextColor3 = Theme.Text
StatsText.Font = Theme.Font
StatsText.TextSize = isMobile and 9 or 10
StatsText.TextXAlignment = Enum.TextXAlignment.Left
StatsText.ZIndex = 6
StatsText.Parent = BottomBar

local StatusText = Instance.new("TextLabel")
StatusText.RichText = true
local modeText = isMobile and "Mobile" or "PC"
StatusText.Text = "NexVoid V2.3 <font color='rgb(200,200,200)'>" .. modeText .. "</font> | Thank you for using NexVoid."
StatusText.Size = UDim2.new(1, -5, 1, 0)
StatusText.Position = UDim2.new(0, 0, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.TextColor3 = Theme.Text
StatusText.Font = Theme.Font
StatusText.TextSize = isMobile and 9 or 10
StatusText.TextXAlignment = Enum.TextXAlignment.Right
StatusText.ZIndex = 6
StatusText.Parent = BottomBar

local StartTime = os.time()
local sec = os.clock()
local frames = 0
local fps = 60

RunService.RenderStepped:Connect(function()
    frames = frames + 1
    if os.clock() - sec >= 1 then
        fps = frames
        frames = 0
        sec = os.clock()
    end
    
    local ping = 0
    local success, result = pcall(function()
        return math.round(LocalPlayer:GetNetworkPing() * 1000)
    end)
    if success and result then
        ping = result
    else
        pcall(function()
            local pingStr = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
            local pingNum = pingStr:match("%d+")
            if pingNum then ping = tonumber(pingNum) end
        end)
    end
    
    local timeStr = os.date("%H:%M") 
    
    local elapsed = os.time() - StartTime
    local eMins = math.floor(elapsed / 60)
    local eSecs = elapsed % 60
    local elapsedStr = string.format("%02d:%02d", eMins, eSecs)
    if elapsed >= 3600 then
        local eHours = math.floor(elapsed / 3600)
        eMins = math.floor((elapsed % 3600) / 60)
        elapsedStr = string.format("%02d:%02d:%02d", eHours, eMins, eSecs)
    end

    StatsText.Text = string.format(
        "<font color='rgb(255, 255, 255)'>FPS:</font> <font color='rgb(200, 200, 200)'>%d</font> <font color='rgb(100,100,100)'>|</font> " ..
        "<font color='rgb(255, 255, 255)'>Ping:</font> <font color='rgb(200, 200, 200)'>%d</font> <font color='rgb(100,100,100)'>|</font> " ..
        "<font color='rgb(255, 255, 255)'>clock:</font> <font color='rgb(200, 200, 200)'>%s</font> <font color='rgb(100,100,100)'>|</font> " ..
        "<font color='rgb(255, 255, 255)'>Time On Nexvoid:</font> <font color='rgb(200, 200, 200)'>%s</font>", 
        fps, ping, timeStr, elapsedStr
    )
end)

local ModalOverlay = Instance.new("Frame")
ModalOverlay.Size = UDim2.new(1, 0, 1, 0)
ModalOverlay.BackgroundColor3 = Color3.new(0,0,0)
ModalOverlay.BackgroundTransparency = 0.5
ModalOverlay.Visible = false
ModalOverlay.ZIndex = 10
ModalOverlay.Parent = MainFrame

local function createModalBox(height)
    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 280, 0, height)
    Box.AnchorPoint = Vector2.new(0.5, 0.5)
    Box.Position = UDim2.new(0.5, 0, 0.5, 0)
    Box.BackgroundColor3 = Theme.FrameColor
    Box.BorderSizePixel = 0
    Box.ZIndex = 11
    Box.Visible = false
    Box.Parent = ModalOverlay
    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Color = Theme.ItemStroke
    BoxStroke.Parent = Box
    local TopLine = Instance.new("Frame")
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.BackgroundColor3 = Theme.Accent
    TopLine.BorderSizePixel = 0
    TopLine.ZIndex = 12
    TopLine.Parent = Box
    ApplyGradient(TopLine, Theme.Accent, Theme.AccentDark, 0)
    return Box
end

local ExitBox = createModalBox(120)
local YesBtn = Instance.new("TextButton")
YesBtn.Parent = ExitBox
YesBtn.Size = UDim2.new(0, 90, 0, 30)
YesBtn.Position = UDim2.new(0, 20, 0, 75)
YesBtn.Text = "Exit"
YesBtn.BackgroundColor3 = Theme.CloseRed
YesBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 4)

local NoBtn = Instance.new("TextButton")
NoBtn.Parent = ExitBox
NoBtn.Size = UDim2.new(0, 90, 0, 30)
NoBtn.Position = UDim2.new(1, -110, 0, 75)
NoBtn.Text = "Cancel"
NoBtn.BackgroundColor3 = Theme.ContentColor
NoBtn.TextColor3 = Theme.TextDark
Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 4)

local ExitTitle = Instance.new("TextLabel")
ExitTitle.Parent = ExitBox
ExitTitle.Text = "CONFIRMATION"
ExitTitle.Font = Theme.Font
ExitTitle.TextSize = 14
ExitTitle.TextColor3 = Theme.Accent
ExitTitle.Size = UDim2.new(1, 0, 0, 35)
ExitTitle.BackgroundTransparency = 1

local ExitDesc = Instance.new("TextLabel")
ExitDesc.Parent = ExitBox
ExitDesc.Text = "Exit the Script?"
ExitDesc.Font = Enum.Font.Gotham
ExitDesc.TextSize = 14
ExitDesc.TextColor3 = Theme.Text
ExitDesc.Size = UDim2.new(1, 0, 0, 30)
ExitDesc.Position = UDim2.new(0, 0, 0, 35)
ExitDesc.BackgroundTransparency = 1

local SettingsBox = createModalBox(320)
local SetTitle = Instance.new("TextLabel")
SetTitle.Parent = SettingsBox
SetTitle.Text = "SETTINGS"
SetTitle.Size = UDim2.new(1,0,0,35)
SetTitle.TextColor3 = Theme.Accent
SetTitle.BackgroundTransparency = 1
SetTitle.Font = Theme.Font
SetTitle.TextSize = 14

local KeyLabel = Instance.new("TextLabel")
KeyLabel.Text = "Menu Keybind:"
KeyLabel.Font = Enum.Font.Gotham
KeyLabel.TextSize = 12
KeyLabel.TextColor3 = Theme.Text
KeyLabel.Size = UDim2.new(0, 100, 0, 30)
KeyLabel.Position = UDim2.new(0, 15, 0, 45)
KeyLabel.BackgroundTransparency = 1
KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
KeyLabel.Parent = SettingsBox

local KeyBtn = Instance.new("TextButton")
KeyBtn.Parent = SettingsBox
KeyBtn.Text = CurrentKey.Name
KeyBtn.Size = UDim2.new(0, 80, 0, 26)
KeyBtn.Position = UDim2.new(1, -100, 0, 47)
KeyBtn.BackgroundColor3 = Theme.ContentColor
KeyBtn.TextColor3 = Theme.Accent
Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 4)

local KeyDesc = Instance.new("TextLabel")
KeyDesc.Parent = SettingsBox
KeyDesc.Text = "Sets the key to Open and Close this menu."
KeyDesc.Size = UDim2.new(1, -30, 0, 15)
KeyDesc.Position = UDim2.new(0, 15, 0, 75)
KeyDesc.BackgroundTransparency = 1
KeyDesc.Font = Enum.Font.Gotham
KeyDesc.TextSize = 10
KeyDesc.TextColor3 = Theme.TextDark
KeyDesc.TextXAlignment = Enum.TextXAlignment.Left
KeyDesc.TextWrapped = true

local SaveCfgBtn = Instance.new("TextButton")
SaveCfgBtn.Parent = SettingsBox
SaveCfgBtn.Text = "Save Configurations"
SaveCfgBtn.Size = UDim2.new(0, 250, 0, 30)
SaveCfgBtn.Position = UDim2.new(0, 15, 0, 110)
SaveCfgBtn.BackgroundColor3 = Theme.Accent
SaveCfgBtn.TextColor3 = Color3.new(0,0,0)
SaveCfgBtn.Font = Theme.Font
SaveCfgBtn.TextSize = 12
Instance.new("UICorner", SaveCfgBtn).CornerRadius = UDim.new(0, 4)
ApplyGradient(SaveCfgBtn, Theme.Accent, Theme.AccentDark, 90)

local SaveDesc = Instance.new("TextLabel")
SaveDesc.Parent = SettingsBox
SaveDesc.Text = "Saves ALL your enabled options (Toggles, Sliders, Inputs) and your Keybind so they load automatically on your next execution."
SaveDesc.Size = UDim2.new(1, -30, 0, 25)
SaveDesc.Position = UDim2.new(0, 15, 0, 145)
SaveDesc.BackgroundTransparency = 1
SaveDesc.Font = Enum.Font.Gotham
SaveDesc.TextSize = 10
SaveDesc.TextColor3 = Theme.TextDark
SaveDesc.TextXAlignment = Enum.TextXAlignment.Center
SaveDesc.TextWrapped = true

local ResetCfgBtn = Instance.new("TextButton")
ResetCfgBtn.Parent = SettingsBox
ResetCfgBtn.Text = "Reset Configurations"
ResetCfgBtn.Size = UDim2.new(0, 250, 0, 30)
ResetCfgBtn.Position = UDim2.new(0, 15, 0, 185)
ResetCfgBtn.BackgroundColor3 = Theme.CloseRed
ResetCfgBtn.TextColor3 = Color3.new(1,1,1)
ResetCfgBtn.Font = Theme.Font
ResetCfgBtn.TextSize = 12
Instance.new("UICorner", ResetCfgBtn).CornerRadius = UDim.new(0, 4)

local ResetDesc = Instance.new("TextLabel")
ResetDesc.Parent = SettingsBox
ResetDesc.Text = "Deletes all saved data and restores the script to its default state."
ResetDesc.Size = UDim2.new(1, -30, 0, 25)
ResetDesc.Position = UDim2.new(0, 15, 0, 220)
ResetDesc.BackgroundTransparency = 1
ResetDesc.Font = Enum.Font.Gotham
ResetDesc.TextSize = 10
ResetDesc.TextColor3 = Theme.TextDark
ResetDesc.TextXAlignment = Enum.TextXAlignment.Center
ResetDesc.TextWrapped = true

local CloseSetBtn = Instance.new("TextButton")
CloseSetBtn.Parent = SettingsBox
CloseSetBtn.Text = "Close"
CloseSetBtn.Size = UDim2.new(0, 250, 0, 30)
CloseSetBtn.Position = UDim2.new(0, 15, 0, 270)
CloseSetBtn.BackgroundColor3 = Theme.ContentColor
CloseSetBtn.TextColor3 = Theme.TextDark
Instance.new("UICorner", CloseSetBtn).CornerRadius = UDim.new(0, 4)

CloseBtn.MouseButton1Click:Connect(function() 
    ModalOverlay.Visible = true
    ExitBox.Visible = true
    SettingsBox.Visible = false 
end)
SettingsBtn.MouseButton1Click:Connect(function() 
    ModalOverlay.Visible = true
    SettingsBox.Visible = true
    ExitBox.Visible = false 
end)
CloseSetBtn.MouseButton1Click:Connect(function() 
    ModalOverlay.Visible = false
    SettingsBox.Visible = false 
end)
NoBtn.MouseButton1Click:Connect(function() 
    ModalOverlay.Visible = false
    ExitBox.Visible = false 
end)
YesBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
KeyBtn.MouseButton1Click:Connect(function() 
    KeyBtn.Text = "..."
    local conn
    conn = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            CurrentKey = input.KeyCode
            UserConfigs.ToggleKey = CurrentKey.Name
            KeyBtn.Text = CurrentKey.Name
            if conn then conn:Disconnect() end
        end
    end)
end)

SaveCfgBtn.MouseButton1Click:Connect(function() 
	SaveConfigs()
    if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Button", "Save Configurations") end) end
	SaveCfgBtn.Text = "Saved Successfully!"
	task.wait(1.5)
	SaveCfgBtn.Text = "Save Configurations" 
end)

ResetCfgBtn.MouseButton1Click:Connect(function() 
	ResetConfigs()
    if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Button", "Reset Configurations") end) end
	KeyBtn.Text = "K"
	ResetCfgBtn.Text = "Reset Successfully!"
	task.wait(1.5)
	ResetCfgBtn.Text = "Reset Configurations" 
end)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local text = SearchBox.Text:lower()
	for _, page in pairs(ContentArea:GetChildren()) do if page:IsA("ScrollingFrame") then
		for _, item in pairs(page:GetChildren()) do
			if item:IsA("Frame") or item:IsA("TextButton") then
				local lbl = item:FindFirstChildWhichIsA("TextLabel") or (item:IsA("TextButton") and item) or nil
				local txt = (lbl and lbl.Text or ""):lower()
				if txt:find(text) then item.Visible = true else if text ~= "" then item.Visible = false end end
			end
		end
	end end
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == CurrentKey then
		if MainFrame.Visible then 
            MainFrame.Visible = false
            OpenButton.Visible = false 
        else 
            MainFrame.Visible = true
            OpenButton.Visible = false 
        end
	end
end)
MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false
OpenButton.Visible = true end)
OpenButton.MouseButton1Click:Connect(function() MainFrame.Visible = true
OpenButton.Visible = false end)

local Library = {}
local tabs = {}

function createSidebarButton(iconId, name, lazyLoadFunc)
	local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
	Page.Size = UDim2.new(1, -20, 1, -10)
    Page.Position = UDim2.new(0, 10, 0, 5)
	Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.ScrollBarImageTransparency = 0 
	Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.ScrollingDirection = Enum.ScrollingDirection.Y
    Page.Visible = false
    Page.Parent = ContentArea
	local PL = Instance.new("UIListLayout")
    PL.Padding = ContentConfig.ItemPadding
    PL.SortOrder = Enum.SortOrder.LayoutOrder
    PL.Parent = Page
	local PP = Instance.new("UIPadding")
    PP.PaddingBottom = UDim.new(0, 10)
    PP.Parent = Page
	
	local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, Config.BtnHeight)
    TabButton.BackgroundTransparency = 1
    TabButton.Text = ""
    TabButton.Parent = Sidebar
	local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 0.7, 0)
    Indicator.Position = UDim2.new(0, 0, 0.15, 0)
    Indicator.BackgroundColor3 = Theme.Accent
    Indicator.BackgroundTransparency = 1
    Indicator.BorderSizePixel = 0
    Indicator.Parent = TabButton
    ApplyGradient(Indicator, Theme.Accent, Theme.AccentDark, 90)
	
	local Icon = Instance.new("ImageLabel")
    Icon.Image = "rbxassetid://" .. iconId
    Icon.Size = UDim2.new(0, Config.IconSize, 0, Config.IconSize)
    Icon.Position = UDim2.new(0, 12, 0.5, -(Config.IconSize/2))
    Icon.BackgroundTransparency = 1
    Icon.ScaleType = Enum.ScaleType.Fit
    Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    Icon.ImageTransparency = 0.2 
    Icon.Parent = TabButton
	local Label = Instance.new("TextLabel")
    Label.Text = name
    Label.Size = UDim2.new(0, 100, 1, 0)
    Label.Position = UDim2.new(0, 38, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Theme.Font
    Label.TextSize = Config.FontSize
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextTransparency = 0.2 
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TabButton
	
	ApplyAnimatedTextGradient(Label)

    local isLoaded = false

	TabButton.MouseButton1Click:Connect(function()
        if not isLoaded and type(lazyLoadFunc) == "function" then
            lazyLoadFunc(Page)
            isLoaded = true
        end

		for _, tab in pairs(tabs) do 
			tab.Page.Visible = false
			tab.Indicator.BackgroundTransparency = 1
			tab.Label.TextTransparency = 0.2
			tab.Icon.ImageTransparency = 0.2
		end
		Page.Visible = true
		Indicator.BackgroundTransparency = 0
		Label.TextTransparency = 0
		Icon.ImageTransparency = 0
	end)
	
	table.insert(tabs, {
        Page = Page, 
        Indicator = Indicator, 
        Label = Label, 
        Icon = Icon,
        LazyLoad = lazyLoadFunc,
        IsLoaded = function() return isLoaded end,
        SetLoaded = function() isLoaded = true end
    })
	return Page
end

function Library:CreateButton(Page, Text, Callback)
	local BtnFrame = Instance.new("TextButton")
    BtnFrame.Size = UDim2.new(1, 0, 0, ContentConfig.ItemHeight)
    BtnFrame.BackgroundColor3 = Theme.ItemColor
    BtnFrame.BackgroundTransparency = 0.2
    BtnFrame.Text = ""
    BtnFrame.Parent = Page
    local str = Instance.new("UIStroke")
    str.Color = Theme.ItemStroke
    str.Thickness = 1
    str.Transparency = 0.7
    str.Parent = BtnFrame
    Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 6)
    ApplyGradient(BtnFrame, Color3.fromRGB(45,45,45), Theme.ItemColor, 90)
	local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Theme.Text
    Label.Font = Theme.Font
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = BtnFrame
	BtnFrame.MouseButton1Click:Connect(function() 
        if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Button", Text) end) end
        pcall(Callback) 
    end)
    BtnFrame.MouseEnter:Connect(function() TweenService:Create(str, TweenInfo.new(0.3), {Color = Theme.Accent, Transparency = 0.4}):Play() end)
    BtnFrame.MouseLeave:Connect(function() TweenService:Create(str, TweenInfo.new(0.3), {Color = Theme.ItemStroke, Transparency = 0.7}):Play() end)
end

function Library:CreateToggle(Page, Text, Default, Callback)
	local Flag = Page.Name .. "_" .. Text
	local State = UserConfigs[Flag]
	if State == nil then State = Default or false end
	UserConfigs[Flag] = State

	local Tgl = Instance.new("TextButton")
    Tgl.Size = UDim2.new(1, 0, 0, ContentConfig.ItemHeight)
    Tgl.BackgroundColor3 = Theme.ItemColor
    Tgl.BackgroundTransparency = 0.2
    Tgl.Text = ""
    Tgl.Parent = Page
    local str = Instance.new("UIStroke")
    str.Color = Theme.ItemStroke
    str.Thickness = 1
    str.Transparency = 0.7
    str.Parent = Tgl
    Instance.new("UICorner", Tgl).CornerRadius = UDim.new(0, 6)
    ApplyGradient(Tgl, Color3.fromRGB(45,45,45), Theme.ItemColor, 90)
	local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Theme.Text
    Label.Font = Theme.Font
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Tgl
	local Bg = Instance.new("Frame")
    Bg.Size = UDim2.new(0, 34, 0, 18)
    Bg.Position = UDim2.new(1, -46, 0.5, -9)
    Bg.BackgroundColor3 = Theme.SwitchOff
    Bg.Parent = Tgl
    Instance.new("UICorner", Bg).CornerRadius = UDim.new(1, 0)
    local BgGrad = ApplyGradient(Bg, Theme.SwitchOff, Theme.SwitchOff, 90)
	local Cir = Instance.new("Frame")
    Cir.Size = UDim2.new(0, 14, 0, 14)
    Cir.Position = UDim2.new(0, 2, 0.5, -7)
    Cir.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    Cir.Parent = Bg
    Instance.new("UICorner", Cir).CornerRadius = UDim.new(1, 0)
	
    local function Upd(fireCallback)
		if State then 
            TweenService:Create(Bg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
            BgGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.AccentDark)}
            TweenService:Create(Cir, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.new(0,0,0)}):Play()
		else 
            TweenService:Create(Bg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SwitchOff}):Play()
            BgGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme.SwitchOff), ColorSequenceKeypoint.new(1, Theme.SwitchOff)}
            TweenService:Create(Cir, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play() 
        end
		if fireCallback then pcall(Callback, State) end
	end
	
	Tgl.MouseButton1Click:Connect(function() 
        State = not State
        UserConfigs[Flag] = State
        if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Toggle", Text, State) end) end
        Upd(true) 
    end)
    
    if State then
        task.spawn(function() pcall(Callback, State) end)
    end
	Upd(false) 
	
    Tgl.MouseEnter:Connect(function() TweenService:Create(str, TweenInfo.new(0.3), {Color = Theme.Accent, Transparency = 0.4}):Play() end)
    Tgl.MouseLeave:Connect(function() TweenService:Create(str, TweenInfo.new(0.3), {Color = Theme.ItemStroke, Transparency = 0.7}):Play() end)
    
    local function Set(val)
        State = val
        UserConfigs[Flag] = State
        Upd(true)
    end
    return {Set = Set}
end

function Library:CreateToggleKeybind(Page, Text, DefaultState, DefaultKey, Callback)
    local FlagState = Page.Name .. "_" .. Text .. "_State"
    local FlagKey = Page.Name .. "_" .. Text .. "_Key"
    
    local State = UserConfigs[FlagState]
    if State == nil then State = DefaultState or false end
    UserConfigs[FlagState] = State
    
    local Key = UserConfigs[FlagKey]
    if Key == nil then Key = DefaultKey or "None" end
    UserConfigs[FlagKey] = Key

    local Tgl = Instance.new("TextButton")
    Tgl.Size = UDim2.new(1, 0, 0, ContentConfig.ItemHeight)
    Tgl.BackgroundColor3 = Theme.ItemColor
    Tgl.BackgroundTransparency = 0.2
    Tgl.Text = ""
    Tgl.Parent = Page
    local str = Instance.new("UIStroke")
    str.Color = Theme.ItemStroke
    str.Thickness = 1
    str.Transparency = 0.7
    str.Parent = Tgl
    Instance.new("UICorner", Tgl).CornerRadius = UDim.new(0, 6)
    ApplyGradient(Tgl, Color3.fromRGB(45,45,45), Theme.ItemColor, 90)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.4, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Theme.Text
    Label.Font = Theme.Font
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Tgl

    local KeyBtn = Instance.new("TextButton")
    KeyBtn.Size = UDim2.new(0, 45, 0, 20)
    KeyBtn.Position = UDim2.new(1, -100, 0.5, -10)
    KeyBtn.BackgroundColor3 = Theme.ContentColor
    KeyBtn.Text = (Key == "None" and "Set Key" or Key)
    KeyBtn.TextColor3 = Theme.TextDark
    KeyBtn.Font = Enum.Font.Gotham
    KeyBtn.TextSize = 10
    KeyBtn.Parent = Tgl
    Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 4)

    local ResetBtn = Instance.new("TextButton")
    ResetBtn.Size = UDim2.new(0, 40, 0, 20)
    ResetBtn.Position = UDim2.new(1, -148, 0.5, -10)
    ResetBtn.BackgroundColor3 = Theme.ContentColor
    ResetBtn.Text = "Reset"
    ResetBtn.TextColor3 = Theme.CloseRed
    ResetBtn.Font = Enum.Font.Gotham
    ResetBtn.TextSize = 10
    ResetBtn.Parent = Tgl
    Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 4)

    local Bg = Instance.new("Frame")
    Bg.Size = UDim2.new(0, 34, 0, 18)
    Bg.Position = UDim2.new(1, -46, 0.5, -9)
    Bg.BackgroundColor3 = Theme.SwitchOff
    Bg.Parent = Tgl
    Instance.new("UICorner", Bg).CornerRadius = UDim.new(1, 0)
    local BgGrad = ApplyGradient(Bg, Theme.SwitchOff, Theme.SwitchOff, 90)
    local Cir = Instance.new("Frame")
    Cir.Size = UDim2.new(0, 14, 0, 14)
    Cir.Position = UDim2.new(0, 2, 0.5, -7)
    Cir.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    Cir.Parent = Bg
    Instance.new("UICorner", Cir).CornerRadius = UDim.new(1, 0)

    local function Upd(fireCallback)
        if State then 
            TweenService:Create(Bg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
            BgGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.AccentDark)}
            TweenService:Create(Cir, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.new(0,0,0)}):Play()
        else 
            TweenService:Create(Bg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SwitchOff}):Play()
            BgGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme.SwitchOff), ColorSequenceKeypoint.new(1, Theme.SwitchOff)}
            TweenService:Create(Cir, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play() 
        end
        if fireCallback then pcall(Callback, State) end
    end

    Tgl.MouseButton1Click:Connect(function()
        State = not State
        UserConfigs[FlagState] = State
        if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Toggle", Text, State) end) end
        Upd(true)
    end)
    
    ResetBtn.MouseButton1Click:Connect(function()
        UserConfigs[FlagKey] = "None"
        KeyBtn.Text = "Set Key"
    end)
    
    KeyBtn.MouseButton1Click:Connect(function()
        KeyBtn.Text = "..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                    UserConfigs[FlagKey] = "None"
                    KeyBtn.Text = "Set Key"
                else
                    UserConfigs[FlagKey] = input.KeyCode.Name
                    KeyBtn.Text = input.KeyCode.Name
                end
                if conn then conn:Disconnect() end
            end
        end)
    end)
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp then
            local currentKey = UserConfigs[FlagKey]
            if currentKey and currentKey ~= "None" and input.KeyCode.Name == currentKey then
                State = not State
                UserConfigs[FlagState] = State
                if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Toggle", Text .. " (Hotkey)", State) end) end
                Upd(true)
            end
        end
    end)

    if State then
        task.spawn(function() pcall(Callback, State) end)
    end
    Upd(false)
    
    Tgl.MouseEnter:Connect(function() TweenService:Create(str, TweenInfo.new(0.3), {Color = Theme.Accent, Transparency = 0.4}):Play() end)
    Tgl.MouseLeave:Connect(function() TweenService:Create(str, TweenInfo.new(0.3), {Color = Theme.ItemStroke, Transparency = 0.7}):Play() end)
    
    local function Set(val)
        State = val
        UserConfigs[FlagState] = State
        Upd(true)
    end
    return {Set = Set}
end

function Library:CreateSection(Page, Text)
	local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, 0, 0, 20)
    Section.BackgroundTransparency = 1
    Section.Parent = Page
	local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Section
	
	ApplyAnimatedTextGradient(Label)
	
	local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, -(Label.TextBounds.X + 10), 0, 1)
    Line.Position = UDim2.new(0, Label.TextBounds.X + 10, 0.5, 0)
    Line.BackgroundColor3 = Theme.ItemStroke
    Line.BorderSizePixel = 0
    Line.Parent = Section
    ApplyGradient(Line, Theme.Accent, Color3.new(0,0,0), 0)
end

function Library:CreateSlider(Page, Text, Min, Max, Default, Callback)
	local Flag = Page.Name .. "_" .. Text
	local currentVal = UserConfigs[Flag]
	if currentVal == nil then currentVal = Default end
	currentVal = math.clamp(currentVal, Min, Max)
	UserConfigs[Flag] = currentVal

	local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundColor3 = Theme.ItemColor
    Frame.BackgroundTransparency = 0.2
    Frame.Parent = Page
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    local str = Instance.new("UIStroke")
    str.Color = Theme.ItemStroke
    str.Thickness = 1
    str.Transparency = 0.7
    str.Parent = Frame
    ApplyGradient(Frame, Color3.fromRGB(45,45,45), Theme.ItemColor, 90)
	local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Theme.Text
    Label.Font = Theme.Font
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
	local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 40, 0, 20)
    ValueLabel.Position = UDim2.new(1, -10, 0, 2)
    ValueLabel.AnchorPoint = Vector2.new(1, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(currentVal)
    ValueLabel.TextColor3 = Theme.TextDark
    ValueLabel.Font = Theme.Font
    ValueLabel.TextSize = 11
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Frame
	local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -20, 0, 4)
    SliderBar.Position = UDim2.new(0, 10, 0, 28)
    SliderBar.BackgroundColor3 = Theme.SwitchOff
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = Frame
    Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)
	local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((currentVal - Min) / (Max - Min), 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBar
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    ApplyGradient(Fill, Theme.Accent, Theme.AccentDark, 0)
	local Trigger = Instance.new("TextButton")
    Trigger.Size = UDim2.new(1, 0, 1, 0)
    Trigger.BackgroundTransparency = 1
    Trigger.Text = ""
    Trigger.Parent = SliderBar
	
	task.spawn(function() pcall(Callback, currentVal) end)

	local dragging = false
	local function Update(input)
		local pos = UDim2.new(math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1), 0, 1, 0)
        Fill.Size = pos
		local value = math.floor(Min + ((Max - Min) * pos.X.Scale))
		ValueLabel.Text = tostring(value)
		UserConfigs[Flag] = value
		pcall(Callback, value)
	end
	Trigger.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true
    Update(input) end end)
	UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            if dragging then
                dragging = false
                if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Slider", Text, UserConfigs[Flag]) end) end
            end
        end 
    end)
	UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input) end end)
end

function Library:CreateInput(Page, Text, Default, Callback)
	local Flag = Page.Name .. "_" .. Text
	local currentVal = UserConfigs[Flag]
	if currentVal == nil then currentVal = Default end
	UserConfigs[Flag] = currentVal

	local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.BackgroundColor3 = Theme.ItemColor
    Container.BackgroundTransparency = 0.2
    Container.Parent = Page
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)
    local str = Instance.new("UIStroke")
    str.Color = Theme.ItemStroke
    str.Thickness = 1
    str.Transparency = 0.7
    str.Parent = Container
    ApplyGradient(Container, Color3.fromRGB(45,45,45), Theme.ItemColor, 90)
	local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -90, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Theme.Text
    Label.Font = Theme.Font
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
	local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0, 70, 0, 26)
    Box.Position = UDim2.new(1, -80, 0.5, -13)
    Box.BackgroundColor3 = Theme.SwitchOff
    Box.Text = tostring(currentVal)
    Box.TextColor3 = Theme.Text
    Box.Font = Theme.Font
    Box.TextSize = 14
    Box.TextScaled = false
    Box.ClipsDescendants = true
    Box.Parent = Container
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
	
	task.spawn(function() pcall(Callback, currentVal) end)

	Box.FocusLost:Connect(function() 
		local num = tonumber(Box.Text)
		local finalVal = num or (Box.Text ~= "" and Box.Text or currentVal)
		Box.Text = tostring(finalVal)
		UserConfigs[Flag] = finalVal
        if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Input", Text, tostring(finalVal)) end) end
		pcall(Callback, finalVal)
	end)
end

function Library:CreateDropdown(Page, Text, Options, Default, Callback)
	local Flag = Page.Name .. "_" .. Text
	local currentVal = UserConfigs[Flag] or Default or Options[1]
	UserConfigs[Flag] = currentVal

	local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.BackgroundColor3 = Theme.ItemColor
    Container.BackgroundTransparency = 0.2
    Container.ClipsDescendants = true
    Container.Parent = Page
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)
    local str = Instance.new("UIStroke")
    str.Color = Theme.ItemStroke
    str.Thickness = 1
    str.Transparency = 0.7
    str.Parent = Container
    ApplyGradient(Container, Color3.fromRGB(45,45,45), Theme.ItemColor, 90)

	local TopBtn = Instance.new("TextButton")
	TopBtn.Size = UDim2.new(1, 0, 0, 40)
	TopBtn.BackgroundTransparency = 1
	TopBtn.Text = ""
	TopBtn.Parent = Container
    
    TopBtn.MouseEnter:Connect(function() TweenService:Create(str, TweenInfo.new(0.3), {Color = Theme.Accent, Transparency = 0.4}):Play() end)
    TopBtn.MouseLeave:Connect(function() TweenService:Create(str, TweenInfo.new(0.3), {Color = Theme.ItemStroke, Transparency = 0.7}):Play() end)

	local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text .. ": " .. tostring(currentVal)
    Label.TextColor3 = Theme.Text
    Label.Font = Theme.Font
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TopBtn

	local Icon = Instance.new("TextLabel")
	Icon.Size = UDim2.new(0, 20, 0, 20)
	Icon.Position = UDim2.new(1, -30, 0.5, -10)
	Icon.BackgroundTransparency = 1
	Icon.Text = "▼"
	Icon.TextColor3 = Theme.TextDark
	Icon.Font = Enum.Font.Gotham
	Icon.TextSize = 12
	Icon.Parent = TopBtn

	local OptionList = Instance.new("ScrollingFrame")
	OptionList.Size = UDim2.new(1, 0, 1, -40)
	OptionList.Position = UDim2.new(0, 0, 0, 40)
	OptionList.BackgroundTransparency = 1
	OptionList.BorderSizePixel = 0
	OptionList.ScrollBarThickness = 2
	OptionList.CanvasSize = UDim2.new(0, 0, 0, 0)
	OptionList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	OptionList.Parent = Container

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = OptionList

	local isOpen = false

	TopBtn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		if isOpen then
			Container.Size = UDim2.new(1, 0, 0, math.min(40 + (#Options * 25), 150))
			Icon.Text = "▲"
		else
			Container.Size = UDim2.new(1, 0, 0, 40)
			Icon.Text = "▼"
		end
	end)

	local function AddOption(optName)
		local optBtn = Instance.new("TextButton")
		optBtn.Size = UDim2.new(1, 0, 0, 25)
		optBtn.BackgroundColor3 = Theme.ContentColor
		optBtn.BackgroundTransparency = 0.5
		optBtn.Text = tostring(optName)
		optBtn.TextColor3 = Theme.TextDark
		optBtn.Font = Enum.Font.Gotham
		optBtn.TextSize = 11
		optBtn.Parent = OptionList

		optBtn.MouseButton1Click:Connect(function()
			currentVal = optName
			UserConfigs[Flag] = currentVal
			Label.Text = Text .. ": " .. tostring(currentVal)
			isOpen = false
			Container.Size = UDim2.new(1, 0, 0, 40)
			Icon.Text = "▼"
            if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Dropdown", Text, tostring(currentVal)) end) end
			pcall(Callback, currentVal)
		end)
	end

	for _, opt in ipairs(Options) do AddOption(opt) end
	task.spawn(function() pcall(Callback, currentVal) end)
end

function Library:CreateColorPicker(Page, Text, DefaultColor, Callback)
    local Flag = Page.Name .. "_" .. Text
    local currentVal = UserConfigs[Flag]
    if currentVal then
        if type(currentVal) == "string" then
            currentVal = Color3.fromHex(currentVal)
        end
    else
        currentVal = DefaultColor
    end
    UserConfigs[Flag] = currentVal:ToHex()

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.BackgroundColor3 = Theme.ItemColor
    Container.BackgroundTransparency = 0.2
    Container.ClipsDescendants = true
    Container.Parent = Page
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)
    local str = Instance.new("UIStroke")
    str.Color = Theme.ItemStroke
    str.Thickness = 1
    str.Transparency = 0.7
    str.Parent = Container
    ApplyGradient(Container, Color3.fromRGB(45,45,45), Theme.ItemColor, 90)

    local TopBtn = Instance.new("TextButton")
    TopBtn.Size = UDim2.new(1, 0, 0, 40)
    TopBtn.BackgroundTransparency = 1
    TopBtn.Text = ""
    TopBtn.Parent = Container
    TopBtn.MouseEnter:Connect(function() TweenService:Create(str, TweenInfo.new(0.3), {Color = Theme.Accent, Transparency = 0.4}):Play() end)
    TopBtn.MouseLeave:Connect(function() TweenService:Create(str, TweenInfo.new(0.3), {Color = Theme.ItemStroke, Transparency = 0.7}):Play() end)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Theme.Text
    Label.Font = Theme.Font
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TopBtn

    local DisplayColor = Instance.new("Frame")
    DisplayColor.Size = UDim2.new(0, 24, 0, 24)
    DisplayColor.Position = UDim2.new(1, -34, 0.5, -12)
    DisplayColor.BackgroundColor3 = currentVal
    DisplayColor.Parent = TopBtn
    Instance.new("UICorner", DisplayColor).CornerRadius = UDim.new(0, 4)

    local PickerArea = Instance.new("Frame")
    PickerArea.Size = UDim2.new(1, 0, 0, 110)
    PickerArea.Position = UDim2.new(0, 0, 0, 40)
    PickerArea.BackgroundTransparency = 1
    PickerArea.Parent = Container

    local SVMap = Instance.new("ImageButton")
    SVMap.Size = UDim2.new(0, 150, 0, 90)
    SVMap.Position = UDim2.new(0, 10, 0, 10)
    SVMap.AutoButtonColor = false
    SVMap.Parent = PickerArea
    local svImage = Instance.new("ImageLabel")
    svImage.Size = UDim2.new(1,0,1,0)
    svImage.BackgroundTransparency = 1
    svImage.Image = "rbxassetid://4155801252"
    svImage.Parent = SVMap
    local SVCursor = Instance.new("Frame")
    SVCursor.Size = UDim2.new(0, 6, 0, 6)
    SVCursor.BackgroundColor3 = Color3.new(1,1,1)
    SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    SVCursor.Parent = SVMap
    Instance.new("UICorner", SVCursor).CornerRadius = UDim.new(1,0)

    local HueBar = Instance.new("ImageButton")
    HueBar.Size = UDim2.new(0, 20, 0, 90)
    HueBar.Position = UDim2.new(0, 170, 0, 10)
    HueBar.AutoButtonColor = false
    HueBar.BackgroundColor3 = Color3.new(1, 1, 1) 
    HueBar.Parent = PickerArea
    local HueGrad = Instance.new("UIGradient")
    HueGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.500, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 0))
    }
    HueGrad.Rotation = 90
    HueGrad.Parent = HueBar
    local HueCursor = Instance.new("Frame")
    HueCursor.Size = UDim2.new(1, 0, 0, 2)
    HueCursor.BackgroundColor3 = Color3.new(1,1,1)
    HueCursor.AnchorPoint = Vector2.new(0, 0.5)
    HueCursor.Parent = HueBar

    local h, s, v = currentVal:ToHSV()
    local isSVDra, isHueDrag = false, false

    local function UpdateColor()
        local c = Color3.fromHSV(h, s, v)
        currentVal = c
        DisplayColor.BackgroundColor3 = c
        SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        UserConfigs[Flag] = c:ToHex()
        pcall(Callback, c)
    end

    local function UpdateCursors()
        HueCursor.Position = UDim2.new(0, 0, math.clamp(1 - h, 0, 1), 0)
        SVCursor.Position = UDim2.new(math.clamp(s, 0, 1), 0, math.clamp(1 - v, 0, 1), 0)
        UpdateColor()
    end
    UpdateCursors()

    local function handleSVDra(input)
        local rx = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
        local ry = math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
        s = rx
        v = 1 - ry
        UpdateCursors()
    end

    local function handleHueDrag(input)
        local ry = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
        h = 1 - ry
        UpdateCursors()
    end

    SVMap.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSVDra = true
            if Page and Page:IsA("ScrollingFrame") then Page.ScrollingEnabled = false end
            handleSVDra(input)
        end
    end)

    HueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isHueDrag = true
            if Page and Page:IsA("ScrollingFrame") then Page.ScrollingEnabled = false end
            handleHueDrag(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isSVDra or isHueDrag then
                if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Input", Text, "#" .. currentVal:ToHex()) end) end
            end
            isSVDra = false
            isHueDrag = false
            if Page and Page:IsA("ScrollingFrame") then Page.ScrollingEnabled = true end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if isSVDra then
                handleSVDra(input)
            elseif isHueDrag then
                handleHueDrag(input)
            end
        end
    end)

    local isOpen = false
    TopBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            Container.Size = UDim2.new(1, 0, 0, 160)
        else
            Container.Size = UDim2.new(1, 0, 0, 40)
        end
    end)

    task.spawn(function() pcall(Callback, currentVal) end)
end

function Library:CreatePlayerCard(Page, Player, Callback)
	local Card = Instance.new("Frame")
    Card.Name = "PlayerCard" 
    Card.Size = UDim2.new(1, 0, 0, ContentConfig.PlayerCardHeight)
    Card.BackgroundColor3 = Theme.ItemColor
    Card.BackgroundTransparency = 0.2
    Card.Parent = Page
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
    local str = Instance.new("UIStroke")
    str.Color = Theme.ItemStroke
    str.Thickness = 1
    str.Transparency = 0.7
    str.Parent = Card
    ApplyGradient(Card, Color3.fromRGB(45,45,45), Theme.ItemColor, 90)
	local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 36, 0, 36)
    Avatar.Position = UDim2.new(0, 8, 0.5, -18)
    Avatar.BackgroundColor3 = Theme.SwitchOff
    Avatar.Parent = Card
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(0, 6)
	task.spawn(function() 
        local content, isReady = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        if isReady then Avatar.Image = content end 
    end)
	local Display = Instance.new("TextLabel")
    Display.Text = Player.DisplayName
    Display.Size = UDim2.new(1, -130, 0, 18)
    Display.Position = UDim2.new(0, 54, 0, 8)
    Display.BackgroundTransparency = 1
    Display.Font = Theme.Font
    Display.TextSize = 13
    Display.TextColor3 = Theme.Text
    Display.TextXAlignment = Enum.TextXAlignment.Left
    Display.Parent = Card
	local User = Instance.new("TextLabel")
    User.Text = "@" .. Player.Name
    User.Size = UDim2.new(1, -130, 0, 14)
    User.Position = UDim2.new(0, 54, 0, 26)
    User.BackgroundTransparency = 1
    User.Font = Enum.Font.Gotham
    User.TextSize = 11
    User.TextColor3 = Theme.TextDark
    User.TextXAlignment = Enum.TextXAlignment.Left
    User.Parent = Card
	local ActionBtn = Instance.new("TextButton")
    ActionBtn.Size = UDim2.new(0, 75, 0, 26)
    ActionBtn.Position = UDim2.new(1, -83, 0.5, -13)
    ActionBtn.BackgroundColor3 = Theme.Accent
    ActionBtn.Text = "Teleport"
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.TextSize = 11
    ActionBtn.TextColor3 = Color3.new(0,0,0)
    ActionBtn.Parent = Card
    Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 6)
    ApplyGradient(ActionBtn, Theme.Accent, Theme.AccentDark, 90)
    ActionBtn.MouseButton1Click:Connect(function() 
        TweenService:Create(ActionBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        task.wait(0.1)
        TweenService:Create(ActionBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
        if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Button", "Teleport: " .. Player.Name) end) end
        pcall(Callback) 
    end)
end

local HighlightPage = createSidebarButton("132131289033378", "Highlight") 
local HighlightConfigPage = createSidebarButton("71672167742459", "Highlight Config") 
local VisualPage = createSidebarButton("76176408662599", "Visual", function(Page)
    local success, func = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/visual_lazy.lua"))()
    end)
    if success and type(func) == "function" then
        func(Library, Page, UserConfigs)
    else
        SendNotification("Falha ao carregar a aba Visual. Verifique sua internet.", 4)
    end
end)
local ProgressPage = createSidebarButton("105442920358687", "Progress")
local AdvancedPage = createSidebarButton("16717281575", "Advanced") 
local TexturesPage = createSidebarButton("11322093465", "Textures")
local SoundsPage = createSidebarButton("7203392850", "Sound")
local VisualSkinsPage = createSidebarButton("13285615740", "Visual Skins") 
local CrossHairPage = createSidebarButton("114326908103962", "CrossHair")
local TeleportPage = createSidebarButton("12689978575", "Teleport")
local ScriptInfoPage = createSidebarButton("9405926389", "Info")

do
    local EspPlayersConnection = nil
    local EspPlayersLoop = nil
    local playerHighlights = {}
    local playerNameGuis = {}
    local BEAST_WEAPON_NAMES = {["Hammer"] = true,["Gemstone Hammer"] = true,["Iron Hammer"] = true,["Mallet"] = true}
    local beastCache = {}
    local trackedComputers = {}

    local function isBeast(player)
        if beastCache[player] ~= nil then return beastCache[player] end
        local backpack = player:FindFirstChild("Backpack")
        local character = player.Character
        for name in pairs(BEAST_WEAPON_NAMES) do
            if backpack and backpack:FindFirstChild(name) then beastCache[player] = true return true end
            if character and character:FindFirstChild(name) then beastCache[player] = true return true end
        end
        if player.Team and player.Team.Name == "Beast" then beastCache[player] = true return true end
        beastCache[player] = false
        return false
    end
    local function ClearPlayerESP()
        for _, hl in pairs(playerHighlights) do if hl then hl:Destroy() end end
        for _, gui in pairs(playerNameGuis) do if gui then gui:Destroy() end end
        playerHighlights = {}
        playerNameGuis = {}
    end
    local EspOutlineLoop = nil
    local EspOutlineHighlights = {}
    local function checkTool(c)
        if not c then return false end
        if c:FindFirstChildOfClass("Tool") then return true end
        if c:FindFirstChild("Hammer") then return true end
        return false
    end
    local function addOutline(p)
        if p == LocalPlayer then return end
        local h = Instance.new("Highlight")
        h.FillTransparency = 1
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        local s = pcall(function() h.Parent = CoreGui end)
        if not s then pcall(function() h.Parent = LocalPlayer:WaitForChild("PlayerGui") end) end
        EspOutlineHighlights[p] = h
        p.CharacterAdded:Connect(function(c) h.Adornee = c end)
        if p.Character then h.Adornee = p.Character end
    end
    local EspCompLoop = nil
    local EspCompRender = nil
    local function clearEspComputers()
        for _, data in ipairs(trackedComputers) do
            if data.highlight then data.highlight:Destroy() end
        end
        table.clear(trackedComputers)
    end
    local EspPodsLoop = nil
    local createdPodESP = {}
    local beastGlowConns = {}
    local activeGlows = {}

    Library:CreateSection(HighlightPage, "ESP Features")
    Library:CreateToggle(HighlightPage, "Esp Players", false, function(state) 
        if state then
            task.spawn(function()
                while state do
                    table.clear(beastCache)
                    task.wait(1)
                end
            end)
            EspPlayersLoop = task.spawn(function()
                while state do
                    local localChar = LocalPlayer.Character
                    local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
                    if localHRP then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local char = player.Character
                                if not playerHighlights[player] or not playerHighlights[player].Parent then
                                    local hl = Instance.new("Highlight")
                                    hl.Name = player.Name .. "_ESP"
                                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    hl.OutlineTransparency = 0
                                    hl.FillTransparency = 0.5
                                    local s = pcall(function() hl.Parent = CoreGui end)
                                    if not s then hl.Parent = LocalPlayer:WaitForChild("PlayerGui") end
                                    playerHighlights[player] = hl
                                end
                                local highlight = playerHighlights[player]
                                highlight.Adornee = char
                                local beast = isBeast(player)
                                local isTarget = true
                                if EspConfig.OnlyBeast and not beast then
                                    isTarget = false
                                end
                                if isTarget then
                                    highlight.Enabled = true
                                    highlight.FillColor = beast and EspConfig.Beast or EspConfig.Survivor
                                else
                                    highlight.Enabled = false
                                end
                                local head = char:FindFirstChild("Head")
                                local hrp = char:FindFirstChild("HumanoidRootPart")
                                if head and hrp then
                                    if not playerNameGuis[player] or not playerNameGuis[player].Parent then
                                        local gui = Instance.new("BillboardGui")
                                        gui.Name = "NameESP"
                                        gui.AlwaysOnTop = true
                                        gui.Size = UDim2.new(0, 90, 0, 20)
                                        gui.StudsOffset = Vector3.new(0, 2.3, 0)
                                        gui.MaxDistance = math.huge 
                                        local txt = Instance.new("TextLabel")
                                        txt.Name = "Label"
                                        txt.Size = UDim2.new(1,0,1,0)
                                        txt.BackgroundTransparency = 1
                                        txt.TextStrokeTransparency = 0.3
                                        txt.Font = Enum.Font.GothamBold
                                        txt.TextSize = 10
                                        txt.Parent = gui
                                        local s = pcall(function() gui.Parent = CoreGui end)
                                        if not s then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
                                        playerNameGuis[player] = gui
                                    end
                                    local gui = playerNameGuis[player]
                                    gui.Adornee = head
                                    local label = gui:FindFirstChild("Label")
                                    if isTarget and not EspConfig.HideNames then
                                        gui.Enabled = true
                                        if label then
                                            local dist = math.floor((localHRP.Position - hrp.Position).Magnitude)
                                            label.Text = player.Name .. "\n" .. (beast and "BEAST" or "SURVIVOR") .. " | " .. dist .. " studs"
                                            label.TextColor3 = beast and EspConfig.Beast or EspConfig.Survivor
                                        end
                                    else
                                        gui.Enabled = false
                                    end
                                end
                            else
                                if playerHighlights[player] then playerHighlights[player]:Destroy(); playerHighlights[player] = nil end
                                if playerNameGuis[player] then playerNameGuis[player]:Destroy(); playerNameGuis[player] = nil end
                            end
                        end
                    end
                    for trackedPlayer, hl in pairs(playerHighlights) do
                        if not trackedPlayer.Parent then 
                            hl:Destroy()
                            playerHighlights[trackedPlayer] = nil
                        end
                    end
                    for trackedPlayer, gui in pairs(playerNameGuis) do
                        if not trackedPlayer.Parent then 
                            gui:Destroy()
                            playerNameGuis[trackedPlayer] = nil
                        end
                    end
                    task.wait(0.6)
                end
            end)
        else
            if EspPlayersLoop then task.cancel(EspPlayersLoop) end
            ClearPlayerESP()
        end
    end)
    Library:CreateToggle(HighlightPage, "Esp outline", false, function(state) 
        if state then
            for _, p in ipairs(Players:GetPlayers()) do addOutline(p) end
            EspOutlineLoop = task.spawn(function()
                while state and task.wait(0.3) do
                    for p, h in pairs(EspOutlineHighlights) do
                        h.OutlineColor = checkTool(p.Character) and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)
                    end
                end
            end)
        else
            if EspOutlineLoop then task.cancel(EspOutlineLoop) end
            for p, h in pairs(EspOutlineHighlights) do
                if h then h:Destroy() end
            end
            table.clear(EspOutlineHighlights)
        end
    end)
    Library:CreateToggle(HighlightPage, "Esp Tracer Line", false, function(state)
        if not getgenv().NexEspTracer then
            getgenv().NexEspTracer = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/esptracer.lua"))()
        end
        getgenv().NexEspTracer.Toggle(state)
    end)
    Library:CreateDropdown(HighlightPage, "Tracer Origin", {"Inferior", "Topo", "Torso"}, "Inferior", function(val)
        if not getgenv().NexEspTracer then
            getgenv().NexEspTracer = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/esptracer.lua"))()
        end
        getgenv().NexEspTracer.SetOrigin(val)
    end)
    
    local EspCompAdded2 = nil
    local BLUE_READY = Color3.fromRGB(0, 170, 255)
    local GREEN_HACKED = Color3.fromRGB(0, 255, 0)
    local RED_ERROR = Color3.fromRGB(255, 0, 0)

    local function updateEspColor(screen, highlight)
        local color = screen.Color
        local targetColor = BLUE_READY
        if color.R > color.G and color.R > color.B then
            targetColor = RED_ERROR
        elseif color.G > color.B and color.G > color.R then
            targetColor = GREEN_HACKED
        end
        
        highlight.FillColor = targetColor
        highlight.OutlineColor = targetColor
    end

    Library:CreateToggle(HighlightPage, "Esp Computers", false, function(state) 
        if state then
            local function setupComputer(model)
                if model:FindFirstChild("CompESP") then return end
                task.spawn(function()
                    local screen = model:FindFirstChild("Screen") or model:WaitForChild("Screen", 5)
                    if screen and screen:IsA("BasePart") then
                        if model:FindFirstChild("CompESP") then return end
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "CompESP"
                        highlight.Adornee = model
                        highlight.Parent = model
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.OutlineTransparency = 0
                        highlight.FillTransparency = EspConfig.ComputerOutlineOnly and 1 or 0.5
                        table.insert(trackedComputers, {highlight = highlight, screen = screen})
                        updateEspColor(screen, highlight)
                        screen:GetPropertyChangedSignal("Color"):Connect(function()
                            if highlight.Parent then
                                updateEspColor(screen, highlight)
                            end
                        end)
                    end
                end)
            end

            local function onDescendantAdded(obj)
                if obj.Name == "ComputerTable" and obj:IsA("Model") then
                    setupComputer(obj)
                elseif obj.Name == "Screen" and obj.Parent and obj.Parent.Name == "ComputerTable" then
                    setupComputer(obj.Parent)
                end
            end

            for _, obj in pairs(workspace:GetDescendants()) do
                onDescendantAdded(obj)
            end
            EspCompAdded2 = workspace.DescendantAdded:Connect(onDescendantAdded)
        else
            if EspCompAdded2 then EspCompAdded2:Disconnect(); EspCompAdded2 = nil end
            clearEspComputers()
        end
    end)

    local COLOR_OPEN = Color3.fromRGB(0, 255, 0)
    local COLOR_CLOSED = Color3.fromRGB(255, 0, 0)
    local trackedDoorsESP = {}
    local espDoorLoop = nil
    local espDoorAddedConn = nil
    local function getOrCreateDoorESP(model)
        if not model:FindFirstChild("DoorESP_FTF") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "DoorESP_FTF"
            highlight.Adornee = model
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0.2
            highlight.FillColor = COLOR_CLOSED
            highlight.OutlineColor = COLOR_CLOSED
            highlight.Parent = model
            return highlight
        end
        return model:FindFirstChild("DoorESP_FTF")
    end
    local function processDoorPartESP(child, model)
        if child:IsA("BasePart") then
            if child.Name:match("Door") or child.Name == "Part" or child.Name == "Left" or child.Name == "Right" then
                if child.Size.Y > 3 and not child.Name:match("Frame") and not child.Name:match("Wall") then
                    if not trackedDoorsESP[child] then
                        trackedDoorsESP[child] = {
                            esp = getOrCreateDoorESP(model),
                            model = model,
                            initialCFrame = child.CFrame
                        }
                    end
                end
            end
        end
    end
    local function checkIsDoorModelESP(obj)
        if obj:IsA("Model") and (obj.Name == "SingleDoor" or obj.Name == "DoubleDoor" or obj.Name == "SlidingDoor") then
            for _, child in ipairs(obj:GetDescendants()) do
                processDoorPartESP(child, obj)
            end
            obj.DescendantAdded:Connect(function(child)
                processDoorPartESP(child, obj)
            end)
        end
    end
    Library:CreateToggle(HighlightPage, "Esp Doors", false, function(state) 
        if state then
            for _, obj in ipairs(workspace:GetDescendants()) do
                checkIsDoorModelESP(obj)
            end
            espDoorAddedConn = workspace.DescendantAdded:Connect(checkIsDoorModelESP)
            espDoorLoop = task.spawn(function()
                while task.wait(0.1) do
                    for part, data in pairs(trackedDoorsESP) do
                        if part and part.Parent and data.model and data.model.Parent and data.esp then
                            local currentCF = part.CFrame
                            local distMoved = (currentCF.Position - data.initialCFrame.Position).Magnitude
                            local dot = currentCF.LookVector:Dot(data.initialCFrame.LookVector)
                            if part.CanCollide == true then
                                if dot < 0.9 or distMoved > 0.5 then
                                    data.initialCFrame = currentCF
                                end
                            end
                            local isOpen = false
                            if not part.CanCollide or dot < 0.85 or distMoved > 0.5 or part.Transparency > 0.8 then
                                isOpen = true
                            end
                            if isOpen then
                                data.esp.FillColor = COLOR_OPEN
                                data.esp.OutlineColor = COLOR_OPEN
                            else
                                data.esp.FillColor = COLOR_CLOSED
                                data.esp.OutlineColor = COLOR_CLOSED
                            end
                        else
                            if data.esp and not data.model.Parent then 
                                data.esp:Destroy() 
                            end
                            trackedDoorsESP[part] = nil
                        end
                    end
                end
            end)
        else
            if espDoorAddedConn then espDoorAddedConn:Disconnect(); espDoorAddedConn = nil end
            if espDoorLoop then task.cancel(espDoorLoop); espDoorLoop = nil end
            for part, data in pairs(trackedDoorsESP) do
                if data.esp then data.esp:Destroy() end
            end
            table.clear(trackedDoorsESP)
        end
    end)
    
    local PodAdded2 = nil
    local function clearEspPods()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "PodESP" then obj:Destroy() end
        end
    end
    Library:CreateToggle(HighlightPage, "Esp Freezepods", false, function(state) 
        if state then
            local POD_COLOR = Color3.fromRGB(0, 255, 255)
            local BORDER_COLOR = Color3.fromRGB(255, 255, 255)
            local FILL_TRANSPARENCY = 0.5
            local OUTLINE_TRANSPARENCY = 0

            local function setupPod(obj)
                if obj.Name == "FreezePod" and obj:IsA("Model") then
                    if obj:FindFirstChild("PodESP") then return end
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "PodESP"
                    highlight.Adornee = obj
                    highlight.Parent = obj
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.OutlineColor = BORDER_COLOR
                    highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
                    highlight.FillTransparency = FILL_TRANSPARENCY
                    highlight.FillColor = POD_COLOR
                end
            end

            for _, descendant in pairs(workspace:GetDescendants()) do
                setupPod(descendant)
            end
            PodAdded2 = workspace.DescendantAdded:Connect(setupPod)
        else
            if PodAdded2 then PodAdded2:Disconnect(); PodAdded2 = nil end
            clearEspPods()
        end
    end)
    
    Library:CreateToggle(HighlightPage, "Beast Highlight", false, function(state) 
        if state then
            local function checkGlow(char)
                if not char then return end
                local Head = char:WaitForChild("Head", 5)
                if not Head then return end
                local function update()
                    if not state then return end
                    local BeastPowers = char:FindFirstChild("BeastPowers")
                    local existing = Head:FindFirstChild("BeastGlow")
                    if BeastPowers then
                        if not existing then
                            local pl = Instance.new("PointLight")
                            pl.Name = "BeastGlow"
                            pl.Color = EspConfig.BeastHighlight
                            pl.Brightness = 8
                            pl.Range = 25
                            pl.Parent = Head
                            table.insert(activeGlows, pl)
                        end
                    else
                        if existing then existing:Destroy() end
                    end
                end
                update()
                table.insert(beastGlowConns, char.ChildAdded:Connect(function(c) if c.Name == "BeastPowers" then update() end end))
                table.insert(beastGlowConns, char.ChildRemoved:Connect(function(c) if c.Name == "BeastPowers" then update() end end))
            end
            table.insert(beastGlowConns, Players.PlayerAdded:Connect(function(p)
                table.insert(beastGlowConns, p.CharacterAdded:Connect(checkGlow))
                if p.Character then checkGlow(p.Character) end
            end))
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then checkGlow(p.Character) end
                table.insert(beastGlowConns, p.CharacterAdded:Connect(checkGlow))
            end
        else
            for _, c in ipairs(beastGlowConns) do
                if c then c:Disconnect() end
            end
            table.clear(beastGlowConns)
            for _, g in ipairs(activeGlows) do
                if g and g.Parent then g:Destroy() end
            end
            table.clear(activeGlows)
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Head") then
                    local g = p.Character.Head:FindFirstChild("BeastGlow")
                    if g then g:Destroy() end
                end
            end
        end
    end)

    Library:CreateSection(HighlightConfigPage, "Global Settings")
    Library:CreateToggle(HighlightConfigPage, "Only Esp Beast", false, function(state)
        EspConfig.OnlyBeast = state
    end)
    Library:CreateToggle(HighlightConfigPage, "Hide Name Esp Player", true, function(state)
        EspConfig.HideNames = state
    end)
    Library:CreateToggle(HighlightConfigPage, "Esp Computer Outline", false, function(state)
        EspConfig.ComputerOutlineOnly = state
        for _, data in ipairs(trackedComputers) do
            if data.highlight and data.highlight.Parent then
                data.highlight.FillTransparency = state and 1 or 0.5
            end
        end
    end)
    Library:CreateToggle(HighlightConfigPage, "Players RGB", false, function(state)
        if state and not UserConfigs["HighlightPage_Esp outline"] then
            SendNotification("Activate ESP outline to enable RGB.", 4)
        end
        EspConfig.PlayersRGB = state
        if not state then
            for p, hl in pairs(EspOutlineHighlights) do
                if hl and p.Character then
                    hl.OutlineColor = checkTool(p.Character) and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)
                end
            end
        end
    end)
    Library:CreateToggle(HighlightConfigPage, "Computers RGB", false, function(state)
        if state and not UserConfigs["HighlightPage_Esp Computers"] then
            SendNotification("Activate ESP Computers to enable RGB.", 4)
        end
        EspConfig.ComputersRGB = state
        if not state then
            for _, data in ipairs(trackedComputers) do
                if data.highlight and data.highlight.Parent and data.screen then
                    updateEspColor(data.screen, data.highlight)
                end
            end
        end
    end)

    Library:CreateSection(HighlightConfigPage, "Color Customization")
    Library:CreateColorPicker(HighlightConfigPage, "Survivor ESP Color", Color3.fromRGB(0, 255, 0), function(color)
        EspConfig.Survivor = color
    end)
    Library:CreateColorPicker(HighlightConfigPage, "Beast ESP Color", Color3.fromRGB(255, 0, 0), function(color)
        EspConfig.Beast = color
    end)
    Library:CreateColorPicker(HighlightConfigPage, "Freezepod ESP Color", Color3.fromRGB(0, 255, 255), function(color)
        EspConfig.Pod = color
    end)
    Library:CreateColorPicker(HighlightConfigPage, "Beast highlight Color", Color3.fromRGB(0, 255, 255), function(color)
        EspConfig.BeastHighlight = color
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") then
                local g = p.Character.Head:FindFirstChild("BeastGlow")
                if g then g.Color = color end
            end
        end
    end)
end

do
    -- Textures Page Content
    Library:CreateSection(TexturesPage, "Textures & Materials")
    Library:CreateToggle(TexturesPage, "Remove Textures", false, function(state) 
        if not getgenv().NexOptimization then
            getgenv().NexOptimization = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/fps%20booster%20e%20remove%20textures.lua"))()
        end
        getgenv().NexOptimization.ToggleTextures(state)
    end)

    -- Pré-carregamento silencioso se houver configs salvas do Visual
    local precisaPreCarregar = false
    for chave, valor in pairs(UserConfigs) do
        if type(chave) == "string" and chave:match("^VisualPage_") and valor == true then
            precisaPreCarregar = true
            break
        end
    end

    if precisaPreCarregar then
        for _, tab in pairs(tabs) do
            if tab.Page.Name == "VisualPage" and tab.LazyLoad then
                tab.LazyLoad(tab.Page)
                tab.SetLoaded()
                break
            end
        end
    end
end

do
    local CompVars = {Active = {}, Loop = nil}
    local getupActive = false
    local getupConns = {}
    local getupGui = nil
    local getupList = nil
    local getupActivePlayers = {}
    local activeTimers = {}
    local ExitDoorLoop = nil
    local activeExitDoors = {}
    local ED_COLORS = { RED = Color3.fromRGB(255, 50, 50), YELLOW = Color3.fromRGB(255, 200, 0), GREEN = Color3.fromRGB(50, 255, 100) }
    local BeastPowerConnection = nil
    local BeastPowerLabel = nil
    local BeastPowerLoop2
    
    Library:CreateSection(ProgressPage, "Timers & Indicators")
    
    local CompProgLoop = nil
    local CompProgConns = {}
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
                if tableModel:FindFirstChild("ProgressBar") then return end

                local billboard, bar, text = createProgressBar(tableModel)
                local highlight = tableModel:FindFirstChildOfClass("Highlight") or Instance.new("Highlight")
                highlight.Name = "ComputerHighlight"
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = tableModel

                local savedProgress = 0
                local connection 
                local lastSize = -1 
                local overlapParams = OverlapParams.new()
                overlapParams.FilterType = Enum.RaycastFilterType.Include
                
                connection = RunService.Heartbeat:Connect(function()
                    if not tableModel or not tableModel.Parent then
                        connection:Disconnect()
                        return
                    end
                    local screen = tableModel:FindFirstChild("Screen")
                    local isGreen = false
                    if screen and screen:IsA("BasePart") then
                        highlight.FillColor = screen.Color
                        highlight.OutlineColor = screen.Color
                        if screen.Color.G > screen.Color.R and screen.Color.G > screen.Color.B then
                            isGreen = true
                        end
                    end
                    if isGreen then
                        savedProgress = 1
                    else
                        local highestTouch = 0
                        local characterParts = {}
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player.Character then
                                table.insert(characterParts, player.Character)
                            end
                        end
                        overlapParams.FilterDescendantsInstances = characterParts
                        for _, part in ipairs(tableModel:GetChildren()) do
                            if part:IsA("BasePart") and part.Name:match("^ComputerTrigger") then
                                local touchingParts = Workspace:GetPartsInPart(part, overlapParams)
                                for _, touchingPart in ipairs(touchingParts) do
                                    local character = touchingPart.Parent
                                    local plr = Players:GetPlayerFromCharacter(character)
                                    if plr then
                                        local tpsm = plr:FindFirstChild("TempPlayerStatsModule")
                                        if tpsm then
                                            local ragdoll = tpsm:FindFirstChild("Ragdoll")
                                            local ap = tpsm:FindFirstChild("ActionProgress")
                                            if ragdoll and typeof(ragdoll.Value) == "boolean" and not ragdoll.Value then
                                                if ap and typeof(ap.Value) == "number" then
                                                    highestTouch = math.max(highestTouch, ap.Value)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        savedProgress = math.max(savedProgress, highestTouch)
                    end

                    if savedProgress ~= lastSize then
                        lastSize = savedProgress
                        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                        local tween = TweenService:Create(bar, tweenInfo, {Size = UDim2.new(savedProgress, 0, 1, 0)})
                        tween:Play()
                    end

                    if savedProgress >= 1 then
                        bar.BackgroundColor3 = Color3.fromRGB(46, 204, 113) 
                        text.TextColor3 = Color3.fromRGB(46, 204, 113)
                        text.Text = "COMPLETED"
                    else
                        bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        text.TextColor3 = Color3.fromRGB(255, 255, 255)
                        text.Text = string.format("%.1f%%", savedProgress * 100)
                    end
                end)
                table.insert(CompProgConns, connection)
            end

            CompProgLoop = task.spawn(function()
                while state do
                    local currentMap = ReplicatedStorage:FindFirstChild("CurrentMap")
                    if currentMap and currentMap.Value ~= "" then
                        local mapName = tostring(currentMap.Value)
                        local map = Workspace:FindFirstChild(mapName)
                        if map then
                            for _, obj in ipairs(map:GetChildren()) do
                                if obj.Name == "ComputerTable" then
                                    setupComputer(obj)
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            if CompProgLoop then task.cancel(CompProgLoop); CompProgLoop = nil end
            for _, c in ipairs(CompProgConns) do if c then c:Disconnect() end end
            table.clear(CompProgConns)
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "ProgressBar" and obj:IsA("BillboardGui") then obj:Destroy() end
                if obj.Name == "ComputerHighlight" and obj:IsA("Highlight") then obj:Destroy() end
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
            local function humanoid(p) return p.Character and p.Character:FindFirstChildOfClass("Humanoid") end
            local function ragdoll(p)
                local h = humanoid(p)
                if not h then return false end
                return h.PlatformStand or h:GetState() == Enum.HumanoidStateType.Physics
            end
            local function captured(p)
                local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                return hrp and hrp.Anchored
            end
            local function color(t) return Color3.fromRGB(255*(1-t), 255*t, 0) end
            local function getUI()
                local s, r = pcall(function() return game:GetService("CoreGui") end)
                return s and r or LocalPlayer:WaitForChild("PlayerGui")
            end
            if not getupGui then
                getupGui = Instance.new("ScreenGui")
                getupGui.Name = "RagdollCounterGui"
                getupGui.ResetOnSpawn = false
                getupGui.Parent = getUI()
                getupList = Instance.new("Frame", getupGui)
                getupList.Size = UDim2.new(0,240,0,300)
                getupList.Position = UDim2.new(1,-20,1,-20)
                getupList.AnchorPoint = Vector2.new(1,1)
                getupList.BackgroundTransparency = 1
                local layout = Instance.new("UIListLayout", getupList)
                layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            end
            local function billboard(p)
                local h = p.Character and p.Character:FindFirstChild("Head")
                if not h then return end
                local old = h:FindFirstChild("RC")
                if old then old:Destroy() end
                local bb = Instance.new("BillboardGui", h)
                bb.Name = "RC"
                bb.Size = UDim2.new(2.5,0,0.7,0)
                bb.StudsOffset = Vector3.new(0,1.9,0)
                bb.AlwaysOnTop = true
                local t = Instance.new("TextLabel", bb)
                t.Size = UDim2.fromScale(1,1)
                t.BackgroundTransparency = 1
                t.TextScaled = true
                t.Font = Enum.Font.SourceSansBold
                t.TextColor3 = Color3.new(1,1,1)
                return t
            end
            local function start(p)
                if getupActivePlayers[p] then return end
                getupActivePlayers[p] = tick()
                local head = billboard(p)
                local txt = Instance.new("TextLabel", getupList)
                txt.Size = UDim2.new(1,0,0,28)
                txt.BackgroundTransparency = 1
                txt.TextScaled = true
                txt.Font = Enum.Font.GothamBold
                txt.TextXAlignment = Enum.TextXAlignment.Right
                txt.TextColor3 = Color3.new(1,1,1)
                local con
                con = RunService.RenderStepped:Connect(function()
                    if not getupActive or not ragdoll(p) or captured(p) then
                        if p.Character and p.Character:FindFirstChild("Head") then
                            local bb = p.Character.Head:FindFirstChild("RC")
                            if bb then bb:Destroy() end
                        end
                        if txt then txt:Destroy() end
                        getupActivePlayers[p] = nil
                        if con then con:Disconnect() end
                        return
                    end
                    local r = math.max(DURATION - (tick() - getupActivePlayers[p]), 0)
                    local c = color(r / DURATION)
                    if head then
                        head.Text = string.format("%.2fs", r)
                        head.TextColor3 = c
                    end
                    txt.Text = p.Name .. " - " .. string.format("%.2fs", r)
                    txt.TextColor3 = c
                end)
                table.insert(getupConns, con)
            end
            local hb = RunService.Heartbeat:Connect(function()
                for _,p in ipairs(Players:GetPlayers()) do
                    if ragdoll(p) and not captured(p) then
                        task.spawn(start, p)
                    end
                end
            end)
            table.insert(getupConns, hb)
        else
            for _, c in ipairs(getupConns) do
                if c then c:Disconnect() end
            end
            table.clear(getupConns)
            if getupGui then getupGui:Destroy() getupGui = nil end
            getupActivePlayers = {}
            for _,p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Head") then
                    local bb = p.Character.Head:FindFirstChild("RC")
                    if bb then bb:Destroy() end
                end
            end
        end
    end)
    
    local bdGui = nil
    local bdLoop = nil
    local bdDotLoop = nil
    Library:CreateToggle(ProgressPage, "Beast Distance", false, function(state)
        if state then
            if not bdGui then
                bdGui = Instance.new("ScreenGui")
                bdGui.ResetOnSpawn = false
                bdGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0.35, 0, 0.1, 0)
                label.Position = UDim2.new(0.325, 0, 0.1, 0)
                label.BackgroundTransparency = 1
                label.TextScaled = true
                label.TextColor3 = Color3.new(1, 1, 1)
                label.Text = "Loading..."
                label.Visible = true
                label.Parent = bdGui

                local beastPlayer = nil
                local dots = 0
                local currentState = "searching"

                bdLoop = task.spawn(function()
                    while state do
                        local isBeast = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Hammer")
                        if isBeast then
                            currentState = "beast"
                            label.Text = "You are a beast."
                            label.TextColor3 = Color3.new(1, 0, 0)
                        else
                            if not beastPlayer or not beastPlayer.Character then
                                for _, plr in ipairs(Players:GetPlayers()) do
                                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Hammer") then
                                        beastPlayer = plr
                                        break
                                    end
                                end
                            end

                            if not beastPlayer then
                                currentState = "searching"
                            elseif beastPlayer.Character and LocalPlayer.Character then
                                local hrp1 = beastPlayer.Character:FindFirstChild("HumanoidRootPart")
                                local hrp2 = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

                                if hrp1 and hrp2 then
                                    currentState = "tracking"
                                    local distance = (hrp1.Position - hrp2.Position).Magnitude
                                    local formatted = math.floor(distance)
                                    label.Text = "Beast Distance: " .. formatted .. " studs"

                                    if distance <= 50 then
                                        label.TextColor3 = Color3.new(1, 0, 0)
                                    else
                                        label.TextColor3 = Color3.new(1, 1, 1)
                                    end
                                end
                            end
                        end
                        task.wait(0.1)
                    end
                end)
                bdDotLoop = task.spawn(function()
                    while state do
                        if currentState == "searching" then
                            dots = (dots % 3) + 1
                            label.Text = "Looking for beast" .. string.rep(".", dots)
                        end
                        task.wait(0.4)
                    end
                end)
            else
                bdGui.Enabled = true
            end
        else
            if bdLoop then task.cancel(bdLoop); bdLoop = nil end
            if bdDotLoop then task.cancel(bdDotLoop); bdDotLoop = nil end
            if bdGui then bdGui:Destroy(); bdGui = nil end
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
            local function getUI() local s, r = pcall(function() return game:GetService("CoreGui") end); return s and r or LocalPlayer:WaitForChild("PlayerGui") end
            local c = getUI()
            if c:FindFirstChild("BeastTextHUD") then c.BeastTextHUD:Destroy() end
            local sg = Instance.new("ScreenGui")
            sg.Name = "BeastTextHUD"
            sg.IgnoreGuiInset = true
            sg.Parent = c
            BeastPowerLabel = Instance.new("TextLabel")
            BeastPowerLabel.AnchorPoint = Vector2.new(1, 0)
            BeastPowerLabel.Position = UDim2.new(1, -15, 0.60, 0)
            BeastPowerLabel.Size = UDim2.new(0, 200, 0, 30)
            BeastPowerLabel.BackgroundTransparency = 1
            BeastPowerLabel.TextColor3 = Color3.new(1,1,1)
            BeastPowerLabel.TextStrokeTransparency = 0
            BeastPowerLabel.Font = Enum.Font.SourceSansBold
            BeastPowerLabel.TextSize = 18
            BeastPowerLabel.TextXAlignment = Enum.TextXAlignment.Right
            BeastPowerLabel.Visible = false
            BeastPowerLabel.Parent = sg
            BeastPowerConnection = task.spawn(function()
                while state do
                    task.wait(0.5)
                    local found = false
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character and p.Character:FindFirstChild("BeastPowers") then
                            found = true
                            BeastPowerLabel.Visible = true
                            local nv = p.Character.BeastPowers:FindFirstChildOfClass("NumberValue")
                            if nv then
                                local pct = math.clamp(nv.Value, 0, 1)
                                BeastPowerLabel.Text = "BEAST POWER: " .. math.floor(pct * 100) .. "%"
                                BeastPowerLabel.TextColor3 = (pct >= 0.99) and Color3.fromRGB(100, 255, 100) or Color3.new(1,1,1)
                            end
                            break
                        end
                    end
                    if not found then BeastPowerLabel.Visible = false end
                end
            end)
        else
            if BeastPowerConnection then task.cancel(BeastPowerConnection) BeastPowerConnection = nil end
            if BeastPowerLabel and BeastPowerLabel.Parent then BeastPowerLabel.Parent:Destroy() end
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
do
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
do
    local hackSignals = {}
    local hackConnection = nil
    local originalVolumeBackup = {}
    local SoundIDs = {
        Draxyn = {Walk = "130152479167305", Jump = "122238807601932", Fall = "71782790555091"},
        Luana = {Walk = "107070338913559", Jump = "133939057526098"},
        Facility = {Walk = "131592620665625", Jump = "89459688918065", Fall = "88947883822456"}, 
        Noob = {Walk = "110709356093026", Jump = "124276657634407", Fall = "88947883822456"}, 
        Morcego = {Walk = "97458293386939", Jump = "72503238596964", Fall = "83702883984130"}, 
        FKPS = {Walk = "97733831736820", Jump = "86031664547378", Fall = "78180192109919"}, 
        Normal = {Walk = "79392671800290", Jump = "80853972291847", Fall = "88947883822456"}, 
        Others = {Pew = "136299701781122", Sharingan = "118102230060662", Bubble = "129415490412106", Laugh = "80276851298640"}
    }
    local HACK_KEYWORDS = {"keyboard", "typing", "type", "hack", "key"}
    local function isHackSound(sound) local name = sound.Name:lower()
    for _, keyword in ipairs(HACK_KEYWORDS) do if name:find(keyword) then return true end end
    return false end
    local function isFromComputer(sound) local parent = sound.Parent
    while parent do if parent.Name == "ComputerTable" then return true end
    parent = parent.Parent end
    return false end
    local function muteHack(sound) sound.Volume = 0
    local sig = sound:GetPropertyChangedSignal("Volume"):Connect(function() sound.Volume = 0 end)
    table.insert(hackSignals, {Signal = sig, Object = sound}) end
    local noHitSoundEnabled = false
    local noHitSoundSignals = {}
    local HIT_KEYWORDS = {"hit", "smack", "damage", "crack", "bone", "bash", "punch", "impact"}
    local function isHitSoundTarget(soundName)
        soundName = soundName:lower()
        for _, keyword in ipairs(HIT_KEYWORDS) do
            if soundName:match(keyword) then return true end
        end
        return false
    end
    local function muteIfHitSound(obj)
        if obj:IsA("Sound") and isHitSoundTarget(obj.Name) then
            obj.Volume = 0
            local sig = obj:GetPropertyChangedSignal("Volume"):Connect(function()
                if obj.Volume > 0 then obj.Volume = 0 end
            end)
            table.insert(noHitSoundSignals, {Signal = sig, Object = obj})
        end
    end
    local noHitSoundAddedConn = nil
    Library:CreateSection(SoundsPage, "Mute Sounds")
    Library:CreateToggle(SoundsPage, "Remove Your Steps", false, function(state) 
        LegitSettings.MuteSteps = state
        if LocalPlayer.Character then ProcessCharacter(LocalPlayer.Character) end 
    end)
    Library:CreateToggle(SoundsPage, "Remove Your Jumps", false, function(state) 
        LegitSettings.MuteJumps = state
        if LocalPlayer.Character then ProcessCharacter(LocalPlayer.Character) end 
    end)
    Library:CreateToggle(SoundsPage, "Remove Pc Hack Sounds", false, function(state) 
        if state then for _, obj in ipairs(Workspace:GetDescendants()) do if obj:IsA("Sound") and isHackSound(obj) and isFromComputer(obj) then muteHack(obj) end end
        hackConnection = Workspace.DescendantAdded:Connect(function(obj) if obj:IsA("Sound") then if isHackSound(obj) and isFromComputer(obj) then muteHack(obj) end end end) else if hackConnection then hackConnection:Disconnect()
        hackConnection = nil end
        for _, data in ipairs(hackSignals) do if data.Signal then data.Signal:Disconnect() end
        if data.Object then data.Object.Volume = 0.5 end end
        hackSignals = {} end 
    end)
    Library:CreateToggle(SoundsPage, "No hit sound", false, function(state)
        noHitSoundEnabled = state
        if state then
            local function monitorCharacter(character)
                for _, child in ipairs(character:GetDescendants()) do muteIfHitSound(child) end
                character.DescendantAdded:Connect(function(child)
                    task.defer(function() if child and child.Parent and noHitSoundEnabled then muteIfHitSound(child) end end)
                end)
            end
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then monitorCharacter(player.Character) end
                player.CharacterAdded:Connect(function(c) if noHitSoundEnabled then monitorCharacter(c) end end)
            end
            for _, sound in ipairs(game:GetService("SoundService"):GetDescendants()) do muteIfHitSound(sound) end
            noHitSoundAddedConn = game:GetService("SoundService").DescendantAdded:Connect(function(child)
                task.defer(function() if child and child.Parent and noHitSoundEnabled then muteIfHitSound(child) end end)
            end)
        else
            if noHitSoundAddedConn then noHitSoundAddedConn:Disconnect() noHitSoundAddedConn = nil end
            for _, data in ipairs(noHitSoundSignals) do 
                if data.Signal then data.Signal:Disconnect() end
                if data.Object then data.Object.Volume = 0.5 end
            end
            noHitSoundSignals = {}
        end
    end)
    Library:CreateSection(SoundsPage, "General")
    Library:CreateSlider(SoundsPage, "Volume Boost", 0, 10, 1, function(val) 
        for _, sound in pairs(workspace:GetDescendants()) do 
            if sound:IsA("Sound") then 
                if not originalVolumeBackup[sound] then originalVolumeBackup[sound] = sound.Volume end
                if val > 1 then sound.Volume = originalVolumeBackup[sound] * val else sound.Volume = originalVolumeBackup[sound] end
            end 
        end 
    end)
    Library:CreateButton(SoundsPage, "Default Sounds (Reset)", function() 
        CurrentSoundIDs.Running = 0
        CurrentSoundIDs.Jumping = 0
        CurrentSoundIDs.Landing = 0
        RefreshAllSounds()
    end)
    Library:CreateSection(SoundsPage, "DraxynSoulx")
    Library:CreateButton(SoundsPage, "FootSteps", function() CurrentSoundIDs.Running = SoundIDs.Draxyn.Walk RefreshAllSounds() end)
    Library:CreateButton(SoundsPage, "Jump", function() CurrentSoundIDs.Jumping = SoundIDs.Draxyn.Jump RefreshAllSounds() end)
    Library:CreateButton(SoundsPage, "Fall", function() CurrentSoundIDs.Landing = SoundIDs.Draxyn.Fall RefreshAllSounds() end)
    Library:CreateSection(SoundsPage, "Luana_Mitxu")
    Library:CreateButton(SoundsPage, "FootSteps", function() CurrentSoundIDs.Running = SoundIDs.Luana.Walk RefreshAllSounds() end)
    Library:CreateButton(SoundsPage, "Jump", function() CurrentSoundIDs.Jumping = SoundIDs.Luana.Jump RefreshAllSounds() end)
    Library:CreateSection(SoundsPage, "Facility Gamer")
    Library:CreateButton(SoundsPage, "FootSteps", function() CurrentSoundIDs.Running = SoundIDs.Facility.Walk RefreshAllSounds() end)
    Library:CreateButton(SoundsPage, "Jump", function() CurrentSoundIDs.Jumping = SoundIDs.Facility.Jump RefreshAllSounds() end)
    Library:CreateSection(SoundsPage, "NoobTwoPoint")
    Library:CreateButton(SoundsPage, "FootSteps", function() CurrentSoundIDs.Running = SoundIDs.Noob.Walk RefreshAllSounds() end)
    Library:CreateButton(SoundsPage, "Jump", function() CurrentSoundIDs.Jumping = SoundIDs.Noob.Jump RefreshAllSounds() end)
    Library:CreateSection(SoundsPage, "Tio Morcego")
    Library:CreateButton(SoundsPage, "FootSteps", function() CurrentSoundIDs.Running = SoundIDs.Morcego.Walk RefreshAllSounds() end)
    Library:CreateButton(SoundsPage, "Jump", function() CurrentSoundIDs.Jumping = SoundIDs.Morcego.Jump RefreshAllSounds() end)
    Library:CreateButton(SoundsPage, "Fall", function() CurrentSoundIDs.Landing = SoundIDs.Morcego.Fall RefreshAllSounds() end)
    Library:CreateSection(SoundsPage, "FKPS")
    Library:CreateButton(SoundsPage, "FootSteps", function() CurrentSoundIDs.Running = SoundIDs.FKPS.Walk RefreshAllSounds() end)
    Library:CreateButton(SoundsPage, "Jumps", function() CurrentSoundIDs.Jumping = SoundIDs.FKPS.Jump RefreshAllSounds() end)
    Library:CreateButton(SoundsPage, "Fall", function() CurrentSoundIDs.Landing = SoundIDs.FKPS.Fall RefreshAllSounds() end)
    Library:CreateSection(SoundsPage, "Normal")
    Library:CreateButton(SoundsPage, "FootSteps", function() CurrentSoundIDs.Running = SoundIDs.Normal.Walk RefreshAllSounds() end)
    Library:CreateButton(SoundsPage, "Jump", function() CurrentSoundIDs.Jumping = SoundIDs.Normal.Jump RefreshAllSounds() end)
    Library:CreateButton(SoundsPage, "Fall", function() CurrentSoundIDs.Landing = SoundIDs.Normal.Fall RefreshAllSounds() end)
    Library:CreateSection(SoundsPage, "Others")
    Library:CreateButton(SoundsPage, "Pew Jump", function() CurrentSoundIDs.Jumping = SoundIDs.Others.Pew RefreshAllSounds() end)
    Library:CreateButton(SoundsPage, "Sharingan Jump", function() CurrentSoundIDs.Jumping = SoundIDs.Others.Sharingan RefreshAllSounds() end)
    Library:CreateButton(SoundsPage, "Albino Jump", function() CurrentSoundIDs.Jumping = SoundIDs.Others.Bubble RefreshAllSounds() end)
    Library:CreateButton(SoundsPage, "Anime Laugh", function() CurrentSoundIDs.Jumping = SoundIDs.Others.Laugh RefreshAllSounds() end)
end
do
    local selectedUserId = nil
    local HeaderContainer = Instance.new("Frame")
    HeaderContainer.Size = UDim2.new(1, 0, 0, 40)
    HeaderContainer.BackgroundTransparency = 1
    HeaderContainer.Parent = VisualSkinsPage
    local BigIcon = Instance.new("ImageLabel")
    BigIcon.Size = UDim2.new(0, 30, 0, 30)
    BigIcon.Position = UDim2.new(0, 10, 0, 5)
    BigIcon.Image = "rbxassetid://72635232675621"
    BigIcon.BackgroundTransparency = 1
    BigIcon.ImageColor3 = Theme.Accent
    BigIcon.Parent = HeaderContainer
    local MainTitle = Instance.new("TextLabel")
    MainTitle.Text = "SKIN CHANGER"
    MainTitle.Size = UDim2.new(0, 200, 1, 0)
    MainTitle.Position = UDim2.new(0, 50, 0, 0)
    MainTitle.Font = Enum.Font.GothamBlack
    MainTitle.TextSize = 14
    MainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainTitle.TextXAlignment = Enum.TextXAlignment.Left
    MainTitle.BackgroundTransparency = 1
    MainTitle.Parent = HeaderContainer
    ApplyAnimatedTextGradient(MainTitle)
    local InputContainer = Instance.new("Frame")
    InputContainer.Size = UDim2.new(1, 0, 0, 35)
    InputContainer.Position = UDim2.new(0, 0, 0, 45)
    InputContainer.BackgroundColor3 = Theme.ItemColor
    InputContainer.BackgroundTransparency = 0.4
    InputContainer.Parent = VisualSkinsPage
    Instance.new("UICorner", InputContainer).CornerRadius = UDim.new(0, 6)
    local UserInputBox = Instance.new("TextBox")
    UserInputBox.Size = UDim2.new(1, -40, 1, 0)
    UserInputBox.Position = UDim2.new(0, 10, 0, 0)
    UserInputBox.BackgroundTransparency = 1
    UserInputBox.Text = ""
    UserInputBox.PlaceholderText = "Username..."
    UserInputBox.TextColor3 = Theme.Text
    UserInputBox.PlaceholderColor3 = Theme.TextDark
    UserInputBox.Font = Theme.Font
    UserInputBox.TextSize = 13
    UserInputBox.TextXAlignment = Enum.TextXAlignment.Left
    UserInputBox.Parent = InputContainer
    local SearchBtnIcon = Instance.new("ImageButton")
    SearchBtnIcon.Size = UDim2.new(0, 20, 0, 20)
    SearchBtnIcon.Position = UDim2.new(1, -28, 0.5, -10)
    SearchBtnIcon.BackgroundTransparency = 1
    SearchBtnIcon.Image = "rbxassetid://104986431790017"
    SearchBtnIcon.ImageColor3 = Theme.Accent
    SearchBtnIcon.ScaleType = Enum.ScaleType.Fit
    SearchBtnIcon.Parent = InputContainer
    local PresetsLabel = Instance.new("TextLabel")
    PresetsLabel.Text = "QUICK SELECT"
    PresetsLabel.Size = UDim2.new(1, 0, 0, 15)
    PresetsLabel.Position = UDim2.new(0, 0, 0, 85)
    PresetsLabel.BackgroundTransparency = 1
    PresetsLabel.TextColor3 = Theme.TextDark
    PresetsLabel.Font = Enum.Font.GothamBold
    PresetsLabel.TextSize = 10
    PresetsLabel.Parent = VisualSkinsPage
    local PresetsContainer = Instance.new("ScrollingFrame")
    PresetsContainer.Size = UDim2.new(1, 0, 1, -110) 
    PresetsContainer.Position = UDim2.new(0, 0, 0, 105)
    PresetsContainer.BackgroundTransparency = 1
    PresetsContainer.BorderSizePixel = 0
    PresetsContainer.ScrollBarThickness = 2
    PresetsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    PresetsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y 
    PresetsContainer.ScrollingDirection = Enum.ScrollingDirection.Y 
    PresetsContainer.Parent = VisualSkinsPage
    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize = UDim2.new(0, 45, 0, 45) 
    Grid.CellPadding = UDim2.new(0, 6, 0, 6)
    Grid.FillDirection = Enum.FillDirection.Horizontal 
    Grid.SortOrder = Enum.SortOrder.LayoutOrder
    Grid.Parent = PresetsContainer
    local PreviewFrame = Instance.new("Frame")
    PreviewFrame.Size = UDim2.new(0, 220, 0, 80) 
    PreviewFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    PreviewFrame.Position = UDim2.new(0.5, 0, 0.5, 0) 
    PreviewFrame.BackgroundColor3 = Theme.FrameColor 
    PreviewFrame.BorderSizePixel = 0
    PreviewFrame.Visible = false
    PreviewFrame.ZIndex = 100 
    PreviewFrame.Parent = MainFrame 
    local PFC = Instance.new("UICorner")
    PFC.CornerRadius = UDim.new(0, 6)
    PFC.Parent = PreviewFrame
    local PFS = Instance.new("UIStroke")
    PFS.Color = Theme.Accent
    PFS.Thickness = 1
    PFS.Parent = PreviewFrame
    local PImage = Instance.new("ImageLabel")
    PImage.Size = UDim2.new(0, 60, 0, 60)
    PImage.Position = UDim2.new(0, 10, 0.5, -30)
    PImage.BackgroundColor3 = Theme.SwitchOff
    PImage.Parent = PreviewFrame
    Instance.new("UICorner", PImage).CornerRadius = UDim.new(0, 6)
    local PText = Instance.new("TextLabel")
    PText.Text = "Skin Found!"
    PText.Size = UDim2.new(1, -80, 0, 15)
    PText.Position = UDim2.new(0, 80, 0, 10)
    PText.BackgroundTransparency = 1
    PText.TextColor3 = Theme.Accent
    PText.Font = Theme.Font
    PText.TextSize = 13
    PText.TextXAlignment = Enum.TextXAlignment.Left
    PText.Parent = PreviewFrame
    local ApplyBtn = Instance.new("TextButton")
    ApplyBtn.Text = "APPLY"
    ApplyBtn.Size = UDim2.new(0, 80, 0, 24)
    ApplyBtn.Position = UDim2.new(0, 80, 0, 40)
    ApplyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    ApplyBtn.TextColor3 = Color3.new(1,1,1)
    ApplyBtn.Font = Theme.Font
    ApplyBtn.TextSize = 11
    ApplyBtn.Parent = PreviewFrame
    Instance.new("UICorner", ApplyBtn).CornerRadius = UDim.new(0, 4)
    local CancelBtn = Instance.new("TextButton")
    CancelBtn.Text = "X"
    CancelBtn.Size = UDim2.new(0, 24, 0, 24)
    CancelBtn.Position = UDim2.new(0, 170, 0, 40)
    CancelBtn.BackgroundColor3 = Theme.ContentColor
    CancelBtn.TextColor3 = Theme.CloseRed
    CancelBtn.Font = Theme.Font
    CancelBtn.TextSize = 12
    CancelBtn.Parent = PreviewFrame
    Instance.new("UICorner", CancelBtn).CornerRadius = UDim.new(0, 4)
    local function PerformSearch(forcedText)
        local text = forcedText or UserInputBox.Text
        if text and text ~= "" then
            UserInputBox.Text = text
            local s, id = pcall(function() return Players:GetUserIdFromNameAsync(text) end)
            if s and id then
                selectedUserId = id
                local thumb, isReady = Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size150x150)
                if isReady then
                    PImage.Image = thumb
                    PreviewFrame.Visible = true
                end
            else
                SendNotification("User not found!", 2)
                PreviewFrame.Visible = false
            end
        end
    end
    local DummyNames = {
        "fleepkkj", "kaiodurate", "TryNotToRageew", "DenzelDxvices", "DraxynSoulx", "Gaie_VR", "totallyvelez", "steik00s", "Guime_blox", "sennapy", "Mwaiconn", "Dexterzxxp", "Jpzinux", "Udies11br", "akatexs", "phzin_it1", "hq_slyin", "Dv_223", "Dimeyuri", "JaoEverCry", "Baydiina", "Meshew", "SniperFq",
    "sukyaik", "nathanserafas12", "guhtorrez", "sthefany12091", "011coded", 
    "Marionete533", "akatexs", "j_oqoo", "lauriinhakplayer", "tio_morcego", "l_qke", "pqsteljxde", "brokensfr", "TotallyFerr", "ZxvqZayan", "cw_223"
    }
    for _, name in pairs(DummyNames) do
        local Btn = Instance.new("ImageButton")
        Btn.BackgroundColor3 = Theme.ItemColor
        Btn.BackgroundTransparency = 0.4
        Btn.Parent = PresetsContainer
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
        task.spawn(function()
            local s, id = pcall(function() return Players:GetUserIdFromNameAsync(name) end)
            if s and id then
                local thumb = Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                Btn.Image = thumb
            end
        end)
        Btn.MouseButton1Click:Connect(function() PerformSearch(name) end)
    end
    UserInputBox.FocusLost:Connect(function(enter) if enter then PerformSearch() end end)
    SearchBtnIcon.MouseButton1Click:Connect(function() PerformSearch() end)
    ApplyBtn.MouseButton1Click:Connect(function()
        if selectedUserId then
            if not getgenv().NexVisualSkins then
                getgenv().NexVisualSkins = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/visualskin"))()
            end
            getgenv().NexVisualSkins.Transformar(selectedUserId)
            PreviewFrame.Visible = false
            if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Input", "Skin Changer", tostring(selectedUserId)) end) end
        end
    end)
    CancelBtn.MouseButton1Click:Connect(function() 
        PreviewFrame.Visible = false
        selectedUserId = nil 
    end)
end
do
    task.spawn(function()
        if not getgenv().NexCrosshair then
            getgenv().NexCrosshair = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/crosshair.lua"))()
        end
        local function SetPCCursorActive(val)
            PCCursorActive = val
        end
        getgenv().NexCrosshair.Build(Library, CrossHairPage, Theme, MobileCrosshair, PCSoftwareCursor, SetPCCursorActive, UpdateCursorSizes)
    end)
end
do
    Library:CreateSection(TeleportPage, "Map Objects Teleport")
    local currentPCIndex = 0
    Library:CreateButton(TeleportPage, "Teleport Computer", function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local pcs = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "ComputerTable" then table.insert(pcs, obj) end
        end
        if #pcs == 0 then SendNotification("Map not loaded!", 2) return end
        currentPCIndex = currentPCIndex + 1
        if currentPCIndex > #pcs then currentPCIndex = 1 end
        local pc = pcs[currentPCIndex]
        local pcCFrame
        if pc:IsA("Model") then pcCFrame = pc:GetPivot() else
            local part = pc:FindFirstChildWhichIsA("BasePart")
            if part then pcCFrame = part.CFrame end
        end
        if pcCFrame then char.HumanoidRootPart.CFrame = pcCFrame * CFrame.new(0, 3, -3) end
    end)
    local currentDoorIndex = 0
    Library:CreateButton(TeleportPage, "Teleport Exitdoor", function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local doors = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local name = string.lower(obj.Name)
                if string.find(name, "exit") and string.find(name, "door") then table.insert(doors, obj) end
            end
        end
        if #doors == 0 then SendNotification("ExitDoors not found!", 2) return end
        currentDoorIndex = currentDoorIndex + 1
        if currentDoorIndex > #doors then currentDoorIndex = 1 end
        local door = doors[currentDoorIndex]
        local part = door.PrimaryPart or door:FindFirstChildWhichIsA("BasePart")
        if part then char.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0) end
    end)
    local currentPodIndex = 0
    Library:CreateButton(TeleportPage, "Teleport Freezepods", function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local pods = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "FreezePod" then table.insert(pods, obj) end
        end
        if #pods == 0 then SendNotification("Map not loaded!", 2) return end
        currentPodIndex = currentPodIndex + 1
        if currentPodIndex > #pods then currentPodIndex = 1 end
        local pod = pods[currentPodIndex]
        local base = pod:FindFirstChild("BasePart") or pod:FindFirstChildWhichIsA("Part")
        if base then char.HumanoidRootPart.CFrame = base.CFrame * CFrame.new(0, 1, -3) end
    end)
    Library:CreateSection(TeleportPage, "Players Teleport")
    local RefreshBtn = Instance.new("TextButton")
    RefreshBtn.Name = "RefreshBtnStatic"
    RefreshBtn.Size = UDim2.new(1, 0, 0, 32)
    RefreshBtn.BackgroundColor3 = Theme.ItemStroke
    RefreshBtn.Text = "Refresh"
    RefreshBtn.TextColor3 = Theme.Accent
    RefreshBtn.Font = Theme.Font
    RefreshBtn.TextSize = 13
    RefreshBtn.Parent = TeleportPage
    Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 6)
    local Spacer = Instance.new("Frame")
    Spacer.Name = "SpacerStatic"
    Spacer.Size = UDim2.new(1, 0, 0, 5)
    Spacer.BackgroundTransparency = 1
    Spacer.Parent = TeleportPage
    local function UpdateTeleportList()
        for _, child in pairs(TeleportPage:GetChildren()) do 
            if child.Name == "PlayerCard" then 
                child:Destroy() 
            end 
        end
        for _, player in pairs(Players:GetPlayers()) do 
            if player ~= LocalPlayer then 
                Library:CreatePlayerCard(TeleportPage, player, function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
                        LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0) 
                    end
                end) 
            end 
        end
    end
    RefreshBtn.MouseButton1Click:Connect(function() 
        if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Button", "Atualizar Lista de TP") end) end
        UpdateTeleportList() 
    end)
    UpdateTeleportList()
end
do
    for _, child in pairs(ScriptInfoPage:GetChildren()) do
        if child:IsA("UIListLayout") or child:IsA("UIPadding") then
            child:Destroy()
        end
    end
    local InfoLayout = Instance.new("UIListLayout")
    InfoLayout.Padding = UDim.new(0, 10)
    InfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
    InfoLayout.Parent = ScriptInfoPage
    local InfoPadding = Instance.new("UIPadding")
    InfoPadding.PaddingTop = UDim.new(0, 5)
    InfoPadding.PaddingBottom = UDim.new(0, 15)
    InfoPadding.PaddingLeft = UDim.new(0, 5)
    InfoPadding.PaddingRight = UDim.new(0, 15)
    InfoPadding.Parent = ScriptInfoPage
    local CreatorText = Instance.new("TextLabel")
    CreatorText.Size = UDim2.new(1, 0, 0, 18)
    CreatorText.BackgroundTransparency = 1
    CreatorText.Text = "<b>NexVoid creator:</b> <font color='rgb(200,200,200)'>DraxynSoulx</font>"
    CreatorText.RichText = true
    CreatorText.Font = Enum.Font.Gotham
    CreatorText.TextSize = 12
    CreatorText.TextColor3 = Theme.Text
    CreatorText.TextXAlignment = Enum.TextXAlignment.Left
    CreatorText.Parent = ScriptInfoPage
    local TesterText = Instance.new("TextLabel")
    TesterText.Size = UDim2.new(1, 0, 0, 18)
    TesterText.BackgroundTransparency = 1
    TesterText.Text = "<b>NexVoid testers:</b> <font color='rgb(200,200,200)'>znerxeys & SnakeFq</font>"
    TesterText.RichText = true
    TesterText.Font = Enum.Font.Gotham
    TesterText.TextSize = 12
    TesterText.TextColor3 = Theme.Text
    TesterText.TextXAlignment = Enum.TextXAlignment.Left
    TesterText.Parent = ScriptInfoPage
    local Spacer1 = Instance.new("Frame")
    Spacer1.Size = UDim2.new(1, 0, 0, 2)
    Spacer1.BackgroundTransparency = 1
    Spacer1.Parent = ScriptInfoPage
    local function CreateInfoCard(parent, titleText, height)
        local TitleContainer = Instance.new("Frame")
        TitleContainer.Size = UDim2.new(1, 0, 0, 20)
        TitleContainer.BackgroundTransparency = 1
        TitleContainer.Parent = parent
        local Line = Instance.new("Frame")
        Line.Size = UDim2.new(0, 3, 0.7, 0)
        Line.Position = UDim2.new(0, 0, 0.15, 0)
        Line.BackgroundColor3 = Theme.Accent
        Line.BorderSizePixel = 0
        Line.Parent = TitleContainer
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, -10, 1, 0)
        TitleLabel.Position = UDim2.new(0, 8, 0, 0)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = titleText
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextSize = 12
        TitleLabel.TextColor3 = Theme.Accent
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = TitleContainer
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, height)
        Card.BackgroundColor3 = Theme.ItemColor
        Card.BackgroundTransparency = 0.5
        Card.Parent = parent
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Theme.ItemStroke
        Stroke.Thickness = 1
        Stroke.Parent = Card
        local CardLayout = Instance.new("UIListLayout")
        CardLayout.Padding = UDim.new(0, 6)
        CardLayout.SortOrder = Enum.SortOrder.LayoutOrder
        CardLayout.Parent = Card
        local CardPadding = Instance.new("UIPadding")
        CardPadding.PaddingTop = UDim.new(0, 10)
        CardPadding.PaddingBottom = UDim.new(0, 10)
        CardPadding.PaddingLeft = UDim.new(0, 12)
        CardPadding.PaddingRight = UDim.new(0, 12)
        CardPadding.Parent = Card
        return Card
    end
    local function CreateCardItem(parent, icon, text)
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 16)
        Label.BackgroundTransparency = 1
        Label.Text = icon .. "  " .. text
        Label.RichText = true
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 12
        Label.TextColor3 = Theme.Text
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = parent
        return Label
    end
    local PlayerCard = CreateInfoCard(ScriptInfoPage, "PLAYER INFO", 85)
    local FpsLabel = CreateCardItem(PlayerCard, "⏱️", "FPS: <font color='rgb(150,150,150)'>0</font>")
    local PingLabel = CreateCardItem(PlayerCard, "📶", "Ping: <font color='rgb(150,150,150)'>0 ms</font>")
    local executorName = "Unknown"
    if identifyexecutor then executorName = identifyexecutor() end
    local ExecLabel = CreateCardItem(PlayerCard, "💻", "Executor: <font color='rgb(150,150,150)'>" .. executorName .. "</font>")
    local ServerCard = CreateInfoCard(ScriptInfoPage, "SERVER INFO", 85)
    local RegionLabel = CreateCardItem(ServerCard, "🗺️", "Region: <font color='rgb(150,150,150)'>Carregando...</font>")
    local PlayersLabel = CreateCardItem(ServerCard, "👤", "Players: <font color='rgb(150,150,150)'>0</font>")
    local MaxPlayersLabel = CreateCardItem(ServerCard, "👥", "Max Players: <font color='rgb(150,150,150)'>" .. Players.MaxPlayers .. "</font>")
    task.spawn(function()
        local region = "Unknown"
        pcall(function()
            local http = game:GetService("HttpService")
            local res = game:HttpGet("http://ip-api.com/json")
            local data = http:JSONDecode(res)
            if data and data.countryCode then
                region = data.countryCode
            end
        end)
        RegionLabel.Text = "🗺️  Region: <font color='rgb(150,150,150)'>" .. region .. "</font>"
    end)
    local infoFrames = 0
    local infoSec = os.clock()
    RunService.RenderStepped:Connect(function()
        infoFrames = infoFrames + 1
        if os.clock() - infoSec >= 1 then
            local fps = infoFrames
            infoFrames = 0
            infoSec = os.clock()
            FpsLabel.Text = "⏱️  FPS: <font color='rgb(150,150,150)'>" .. fps .. "</font>"
            local ping = 0
            pcall(function() ping = math.round(LocalPlayer:GetNetworkPing() * 1000) end)
            PingLabel.Text = "📶  Ping: <font color='rgb(150,150,150)'>" .. ping .. " ms</font>"
            PlayersLabel.Text = "👤  Players: <font color='rgb(150,150,150)'>" .. #Players:GetPlayers() .. "</font>"
        end
    end)
    local Spacer2 = Instance.new("Frame")
    Spacer2.Size = UDim2.new(1, 0, 0, 5)
    Spacer2.BackgroundTransparency = 1
    Spacer2.Parent = ScriptInfoPage
    local RejoinBtn = Instance.new("TextButton")
    RejoinBtn.Size = UDim2.new(1, 0, 0, 35)
    RejoinBtn.BackgroundColor3 = Theme.ItemColor
    RejoinBtn.BackgroundTransparency = 0.2
    RejoinBtn.Text = "Server Rejoin"
    RejoinBtn.TextColor3 = Theme.Text
    RejoinBtn.Font = Enum.Font.GothamBold
    RejoinBtn.TextSize = 13
    RejoinBtn.Parent = ScriptInfoPage
    local RjStroke = Instance.new("UIStroke")
    RjStroke.Color = Theme.ItemStroke
    RjStroke.Thickness = 1
    RjStroke.Parent = RejoinBtn
    Instance.new("UICorner", RejoinBtn).CornerRadius = UDim.new(0, 6)
    RejoinBtn.MouseEnter:Connect(function() TweenService:Create(RjStroke, TweenInfo.new(0.3), {Color = Theme.Accent}):Play() end)
    RejoinBtn.MouseLeave:Connect(function() TweenService:Create(RjStroke, TweenInfo.new(0.3), {Color = Theme.ItemStroke}):Play() end)
    RejoinBtn.MouseButton1Click:Connect(function()
        if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Button", "Server Rejoin") end) end
        local ts = game:GetService("TeleportService")
        local p = game:GetService("Players").LocalPlayer
        RejoinBtn.Text = "Rejoining..."
        if #game:GetService("Players"):GetPlayers() <= 1 then
            p:Kick("\nRejoining...")
            task.wait()
            ts:Teleport(game.PlaceId, p)
        else
            ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, p)
        end
    end)
    local Spacer3 = Instance.new("Frame")
    Spacer3.Size = UDim2.new(1, 0, 0, 2)
    Spacer3.BackgroundTransparency = 1
    Spacer3.Parent = ScriptInfoPage
    local Msg1 = Instance.new("TextLabel")
    Msg1.Size = UDim2.new(1, 0, 0, 15)
    Msg1.BackgroundTransparency = 1
    Msg1.Text = "NexVoid is a free script; if someone asks you to charge, don't pay."
    Msg1.Font = Enum.Font.Gotham
    Msg1.TextSize = 10
    Msg1.TextColor3 = Color3.fromRGB(200, 50, 50)
    Msg1.TextXAlignment = Enum.TextXAlignment.Center
    Msg1.Parent = ScriptInfoPage
    local Msg2 = Instance.new("TextLabel")
    Msg2.Size = UDim2.new(1, 0, 0, 15)
    Msg2.BackgroundTransparency = 1
    Msg2.Text = "Thank you for using NexVoid. NexVoid On Top"
    Msg2.Font = Enum.Font.GothamBold
    Msg2.TextSize = 11
    Msg2.TextColor3 = Theme.Accent
    Msg2.TextXAlignment = Enum.TextXAlignment.Center
    Msg2.Parent = ScriptInfoPage
end
if tabs[1] then 
	tabs[1].Page.Visible = true
	tabs[1].Indicator.BackgroundTransparency = 0
	tabs[1].Label.TextTransparency = 0
	tabs[1].Icon.ImageTransparency = 0
end
ScreenGui.Enabled = true
MainFrame.Visible = true
OpenButton.Visible = false
