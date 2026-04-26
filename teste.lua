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
    HideNames = false,
    BeastHighlight = Color3.fromRGB(0, 255, 255),
    Survivor = Color3.fromRGB(0, 255, 0),
    Beast = Color3.fromRGB(255, 0, 0),
    Pod = Color3.fromRGB(0, 255, 255)
}

local LegitSettings = {MuteSteps = false, MuteJumps = false, MuteHack = false}
local CurrentSoundIDs = {Running = 0, Jumping = 0, Landing = 0}
local OriginalSoundBackups = setmetatable({}, {__mode = "k"})

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

local function SetPCCursorActive(val)
    PCCursorActive = val
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
AnimeBg.Image = "rbxassetid://131507084726658"
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
TitleLabel.Text = "Nex<font color='rgb(150,150,150)'>Void V2.5</font>"
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
        elseif name == "Language" then
            Btn.MouseEnter:Connect(function() Btn.TextColor3 = Theme.Accent end)
            Btn.MouseLeave:Connect(function() Btn.TextColor3 = Theme.TextDark end)
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
local LangBtn = createTopBtn("Language", "EN", 4, false)

local SearchContainer = Instance.new("Frame")
SearchContainer.Name = "SearchContainer"
SearchContainer.Size = UDim2.new(0, 130, 0, 26) 
SearchContainer.Position = UDim2.new(1, -175, 0.5, 0)
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

local StatusText = Instance.new("TextLabel")
StatusText.RichText = true
local modeText = isMobile and "Mobile" or "PC"
StatusText.Text = "NexVoid V2.5 <font color='rgb(200,200,200)'>" .. modeText .. "</font> | Thank you for using NexVoid."
StatusText.Size = UDim2.new(1, -10, 1, 0)
StatusText.Position = UDim2.new(0, 0, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.TextColor3 = Theme.Text
StatusText.Font = Theme.Font
StatusText.TextSize = isMobile and 9 or 10
StatusText.TextXAlignment = Enum.TextXAlignment.Right
StatusText.ZIndex = 6
StatusText.Parent = BottomBar

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

local ExitBoxContainer = Instance.new("Frame")
ExitBoxContainer.Size = UDim2.new(0, 310, 0, 165)
ExitBoxContainer.AnchorPoint = Vector2.new(0.5, 0.5)
ExitBoxContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
ExitBoxContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ExitBoxContainer.BorderSizePixel = 0
ExitBoxContainer.ZIndex = 11
ExitBoxContainer.Visible = false
ExitBoxContainer.Parent = ModalOverlay
Instance.new("UICorner", ExitBoxContainer).CornerRadius = UDim.new(0, 10)
local ExitBoxStroke = Instance.new("UIStroke")
ExitBoxStroke.Color = Color3.fromRGB(45, 45, 45)
ExitBoxStroke.Thickness = 1.5
ExitBoxStroke.Parent = ExitBoxContainer

local ExitTopGlow = Instance.new("Frame")
ExitTopGlow.Size = UDim2.new(1, 0, 0, 4)
ExitTopGlow.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
ExitTopGlow.BorderSizePixel = 0
ExitTopGlow.ZIndex = 12
ExitTopGlow.Parent = ExitBoxContainer
Instance.new("UICorner", ExitTopGlow).CornerRadius = UDim.new(0, 10)
local FixBottomCorners = Instance.new("Frame")
FixBottomCorners.Size = UDim2.new(1, 0, 0, 2)
FixBottomCorners.Position = UDim2.new(0, 0, 1, -2)
FixBottomCorners.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
FixBottomCorners.BorderSizePixel = 0
FixBottomCorners.ZIndex = 12
FixBottomCorners.Parent = ExitTopGlow
ApplyGradient(ExitTopGlow, Color3.fromRGB(255, 80, 80), Color3.fromRGB(150, 20, 20), 0)

local ExitTitleLabel = Instance.new("TextLabel")
ExitTitleLabel.Size = UDim2.new(1, 0, 0, 40)
ExitTitleLabel.Position = UDim2.new(0, 0, 0, 15)
ExitTitleLabel.BackgroundTransparency = 1
ExitTitleLabel.Text = "Exit NexVoidHub"
ExitTitleLabel:SetAttribute("OriginalText", "Exit NexVoidHub")
ExitTitleLabel.Font = Enum.Font.GothamBlack
ExitTitleLabel.TextSize = 18
ExitTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitTitleLabel.ZIndex = 12
ExitTitleLabel.Parent = ExitBoxContainer

local ExitDescLabel = Instance.new("TextLabel")
ExitDescLabel.Size = UDim2.new(1, -40, 0, 40)
ExitDescLabel.Position = UDim2.new(0, 20, 0, 50)
ExitDescLabel.BackgroundTransparency = 1
ExitDescLabel.Text = "Are you absolutely sure you want to close the script? You will need to re-execute to open it again."
ExitDescLabel:SetAttribute("OriginalText", "Are you absolutely sure you want to close the script? You will need to re-execute to open it again.")
ExitDescLabel.Font = Enum.Font.Gotham
ExitDescLabel.TextSize = 12
ExitDescLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
ExitDescLabel.TextWrapped = true
ExitDescLabel.ZIndex = 12
ExitDescLabel.Parent = ExitBoxContainer

local CancelExitBtn = Instance.new("TextButton")
CancelExitBtn.Size = UDim2.new(0.42, 0, 0, 36)
CancelExitBtn.Position = UDim2.new(0.06, 0, 0, 110)
CancelExitBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
CancelExitBtn.Text = "Cancel"
CancelExitBtn:SetAttribute("OriginalText", "Cancel")
CancelExitBtn.Font = Enum.Font.GothamBold
CancelExitBtn.TextSize = 13
CancelExitBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CancelExitBtn.ZIndex = 12
CancelExitBtn.Parent = ExitBoxContainer
Instance.new("UICorner", CancelExitBtn).CornerRadius = UDim.new(0, 6)
local CancelStroke = Instance.new("UIStroke")
CancelStroke.Color = Color3.fromRGB(60, 60, 60)
CancelStroke.Thickness = 1
CancelStroke.Parent = CancelExitBtn

local ConfirmExitBtn = Instance.new("TextButton")
ConfirmExitBtn.Size = UDim2.new(0.42, 0, 0, 36)
ConfirmExitBtn.Position = UDim2.new(0.52, 0, 0, 110)
ConfirmExitBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
ConfirmExitBtn.Text = "Yes, Exit"
ConfirmExitBtn:SetAttribute("OriginalText", "Yes, Exit")
ConfirmExitBtn.Font = Enum.Font.GothamBold
ConfirmExitBtn.TextSize = 13
ConfirmExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfirmExitBtn.ZIndex = 12
ConfirmExitBtn.Parent = ExitBoxContainer
Instance.new("UICorner", ConfirmExitBtn).CornerRadius = UDim.new(0, 6)
local ConfirmStroke = Instance.new("UIStroke")
ConfirmStroke.Color = Color3.fromRGB(100, 20, 20)
ConfirmStroke.Thickness = 1
ConfirmStroke.Parent = ConfirmExitBtn
ApplyGradient(ConfirmExitBtn, Color3.fromRGB(255, 60, 60), Color3.fromRGB(180, 20, 20), 90)

CancelExitBtn.MouseEnter:Connect(function()
    TweenService:Create(CancelExitBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
    TweenService:Create(CancelStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(100, 100, 100)}):Play()
end)
CancelExitBtn.MouseLeave:Connect(function()
    TweenService:Create(CancelExitBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
    TweenService:Create(CancelStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(60, 60, 60)}):Play()
end)

ConfirmExitBtn.MouseEnter:Connect(function()
    TweenService:Create(ConfirmExitBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 60, 60)}):Play()
end)
ConfirmExitBtn.MouseLeave:Connect(function()
    TweenService:Create(ConfirmExitBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 40, 40)}):Play()
end)

local SettingsBox = createModalBox(320)
local SetTitle = Instance.new("TextLabel")
SetTitle.Parent = SettingsBox
SetTitle.Text = "SETTINGS"
SetTitle:SetAttribute("OriginalText", "SETTINGS")
SetTitle.Size = UDim2.new(1,0,0,35)
SetTitle.TextColor3 = Theme.Accent
SetTitle.BackgroundTransparency = 1
SetTitle.Font = Theme.Font
SetTitle.TextSize = 14

local KeyLabel = Instance.new("TextLabel")
KeyLabel.Text = "Menu Keybind:"
KeyLabel:SetAttribute("OriginalText", "Menu Keybind:")
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
KeyDesc:SetAttribute("OriginalText", "Sets the key to Open and Close this menu.")
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
SaveCfgBtn:SetAttribute("OriginalText", "Save Configurations")
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
SaveDesc:SetAttribute("OriginalText", "Saves ALL your enabled options (Toggles, Sliders, Inputs) and your Keybind so they load automatically on your next execution.")
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
ResetCfgBtn:SetAttribute("OriginalText", "Reset Configurations")
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
ResetDesc:SetAttribute("OriginalText", "Deletes all saved data and restores the script to its default state.")
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
CloseSetBtn:SetAttribute("OriginalText", "Close")
CloseSetBtn.Size = UDim2.new(0, 250, 0, 30)
CloseSetBtn.Position = UDim2.new(0, 15, 0, 270)
CloseSetBtn.BackgroundColor3 = Theme.ContentColor
CloseSetBtn.TextColor3 = Theme.TextDark
Instance.new("UICorner", CloseSetBtn).CornerRadius = UDim.new(0, 4)

CloseBtn.MouseButton1Click:Connect(function() 
    ModalOverlay.Visible = true
    ExitBoxContainer.Size = UDim2.new(0, 0, 0, 0)
    ExitBoxContainer.Visible = true
    TweenService:Create(ExitBoxContainer, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 310, 0, 165)}):Play()
    SettingsBox.Visible = false 
end)
SettingsBtn.MouseButton1Click:Connect(function() 
    ModalOverlay.Visible = true
    SettingsBox.Visible = true
    ExitBoxContainer.Visible = false 
end)
CloseSetBtn.MouseButton1Click:Connect(function() 
    ModalOverlay.Visible = false
    SettingsBox.Visible = false 
end)

CancelExitBtn.MouseButton1Click:Connect(function() 
    local tw = TweenService:Create(ExitBoxContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
    tw:Play()
    tw.Completed:Wait()
    ModalOverlay.Visible = false
    ExitBoxContainer.Visible = false 
end)
ConfirmExitBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

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
    local original = SaveCfgBtn:GetAttribute("OriginalText")
    local cLang = LangBtn.Text
	SaveCfgBtn.Text = "Saved Successfully!"
    SaveCfgBtn:SetAttribute("OriginalText", "Saved Successfully!")
    if cLang ~= "EN" then
        pcall(function()
            local module = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/translation.lua"))()
            if module and module.Translate then module.Translate(ScreenGui, cLang) end
        end)
    end
	task.wait(1.5)
	SaveCfgBtn.Text = original
    SaveCfgBtn:SetAttribute("OriginalText", original)
    if cLang ~= "EN" then
        pcall(function()
            local module = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/translation.lua"))()
            if module and module.Translate then module.Translate(ScreenGui, cLang) end
        end)
    end
end)

ResetCfgBtn.MouseButton1Click:Connect(function() 
	ResetConfigs()
    if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Button", "Reset Configurations") end) end
	KeyBtn.Text = "K"
    local original = ResetCfgBtn:GetAttribute("OriginalText")
    local cLang = LangBtn.Text
	ResetCfgBtn.Text = "Reset Successfully!"
    ResetCfgBtn:SetAttribute("OriginalText", "Reset Successfully!")
    if cLang ~= "EN" then
        pcall(function()
            local module = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/translation.lua"))()
            if module and module.Translate then module.Translate(ScreenGui, cLang) end
        end)
    end
	task.wait(1.5)
	ResetCfgBtn.Text = original
    ResetCfgBtn:SetAttribute("OriginalText", original)
    if cLang ~= "EN" then
        pcall(function()
            local module = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/translation.lua"))()
            if module and module.Translate then module.Translate(ScreenGui, cLang) end
        end)
    end
end)

local currentLangIndex = 1
local langs = {"EN", "PT", "ES"}
LangBtn.MouseButton1Click:Connect(function()
    currentLangIndex = currentLangIndex + 1
    if currentLangIndex > #langs then currentLangIndex = 1 end
    local lang = langs[currentLangIndex]
    LangBtn.Text = lang
    
    if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Button", "Language: " .. lang) end) end
    
    task.spawn(function()
        local s, module = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/translation.lua"))()
        end)
        if s and module then
            if type(module) == "table" and module.Translate then
                module.Translate(ScreenGui, lang)
            elseif type(module) == "function" then
                module(ScreenGui, lang)
            end
        end
    end)
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

local function createSidebarButton(iconId, name, lazyLoadFunc)
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
    Label:SetAttribute("OriginalText", name) 
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

    local loaded = false
	TabButton.MouseButton1Click:Connect(function()
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
	
	table.insert(tabs, {Page = Page, Indicator = Indicator, Label = Label, Icon = Icon})
	
	if lazyLoadFunc then
		task.spawn(function()
			local s, e = pcall(function() lazyLoadFunc(Page) end)
			if not s then warn("NexVoid Prefetch Error for " .. name .. ": ", e) end
		end)
	end

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
    Label:SetAttribute("OriginalText", Text) 
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
    Label:SetAttribute("OriginalText", Text) 
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
    Label:SetAttribute("OriginalText", Text) 
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
    Section.Size = UDim2.new(1, 0, 0, 25)
    Section.BackgroundTransparency = 1
    Section.Parent = Page
    
	local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label:SetAttribute("OriginalText", Text) 
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Section
	
	ApplyAnimatedTextGradient(Label)
	
	local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, -(Label.TextBounds.X + 12), 0, 2)
    Line.Position = UDim2.new(0, Label.TextBounds.X + 12, 0.5, 0)
    Line.BackgroundColor3 = Theme.ItemStroke
    Line.BorderSizePixel = 0
    Line.Parent = Section
    ApplyGradient(Line, Theme.Accent, Color3.new(0,0,0), 0)

    Label:GetPropertyChangedSignal("TextBounds"):Connect(function()
        Line.Size = UDim2.new(1, -(Label.TextBounds.X + 12), 0, 2)
        Line.Position = UDim2.new(0, Label.TextBounds.X + 12, 0.5, 0)
    end)
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
    Label:SetAttribute("OriginalText", Text) 
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
    Label:SetAttribute("OriginalText", Text) 
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
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text .. ": " .. tostring(currentVal)
    Label:SetAttribute("OriginalText", Text) 
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

    local MenuBg = Instance.new("Frame")
    MenuBg.Size = UDim2.new(1, 0, 1, -40)
    MenuBg.Position = UDim2.new(0, 0, 0, 40)
    MenuBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MenuBg.BorderSizePixel = 0
    MenuBg.Parent = Container

    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(0, 2, 1, 0)
    AccentLine.Position = UDim2.new(1, -2, 0, 0)
    AccentLine.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    AccentLine.BorderSizePixel = 0
    AccentLine.ZIndex = 5
    AccentLine.Parent = MenuBg

    local OptionList = Instance.new("ScrollingFrame")
    OptionList.Size = UDim2.new(1, -4, 1, 0)
    OptionList.Position = UDim2.new(0, 0, 0, 0)
    OptionList.BackgroundTransparency = 1
    OptionList.BorderSizePixel = 0
    OptionList.ScrollBarThickness = 2
    OptionList.ScrollBarImageColor3 = Theme.Accent
    OptionList.CanvasSize = UDim2.new(0, 0, 0, 0)
    OptionList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    OptionList.Parent = MenuBg

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = OptionList

    local isOpen = false

    TopBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, math.min(40 + (#Options * 30), 180))}):Play()
            Icon.Text = "▲"
            TweenService:Create(Icon, TweenInfo.new(0.3), {TextColor3 = Theme.Accent}):Play()
        else
            TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 40)}):Play()
            Icon.Text = "▼"
            TweenService:Create(Icon, TweenInfo.new(0.3), {TextColor3 = Theme.TextDark}):Play()
        end
    end)

    local function AddOption(optName)
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 30)
        optBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        optBtn.BackgroundTransparency = 1
        optBtn.Text = tostring(optName)
        optBtn.TextColor3 = (currentVal == optName) and Theme.Text or Theme.TextDark
        optBtn.Font = (currentVal == optName) and Enum.Font.GothamBold or Enum.Font.Gotham
        optBtn.TextSize = 11
        optBtn.TextXAlignment = Enum.TextXAlignment.Center
        optBtn.Parent = OptionList

        local sep = Instance.new("Frame")
        sep.Size = UDim2.new(1, -20, 0, 1)
        sep.Position = UDim2.new(0, 10, 1, -1)
        sep.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        sep.BorderSizePixel = 0
        sep.Parent = optBtn

        optBtn.MouseEnter:Connect(function()
            TweenService:Create(optBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.85}):Play()
            if currentVal ~= optName then 
                TweenService:Create(optBtn, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
            end
        end)
        optBtn.MouseLeave:Connect(function()
            TweenService:Create(optBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            if currentVal ~= optName then 
                TweenService:Create(optBtn, TweenInfo.new(0.2), {TextColor3 = Theme.TextDark}):Play()
            end
        end)

        optBtn.MouseButton1Click:Connect(function()
            currentVal = optName
            UserConfigs[Flag] = currentVal
            
            local originalLabel = Label:GetAttribute("OriginalText")
            if originalLabel then
                local currentText = Label.Text
                local translatedPrefix = string.split(currentText, ": ")[1]
                Label.Text = translatedPrefix .. ": " .. tostring(currentVal)
            else
                Label.Text = Text .. ": " .. tostring(currentVal)
            end
            
            isOpen = false
            TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 40)}):Play()
            Icon.Text = "▼"
            TweenService:Create(Icon, TweenInfo.new(0.3), {TextColor3 = Theme.TextDark}):Play()
            
            for _, child in pairs(OptionList:GetChildren()) do
                if child:IsA("TextButton") then 
                    child.TextColor3 = Theme.TextDark
                    child.Font = Enum.Font.Gotham
                end
            end
            optBtn.TextColor3 = Theme.Text
            optBtn.Font = Enum.Font.GothamBold
            
            if _G.NexVoidLog then task.spawn(function() _G.NexVoidLog("Dropdown", Text, tostring(currentVal)) end) end
            pcall(Callback, currentVal)
            
            task.delay(0.1, function()
                local cLang = LangBtn.Text
                if cLang ~= "EN" then
                    pcall(function()
                        local module = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/translation.lua"))()
                        if module and module.Translate then module.Translate(ScreenGui, cLang) end
                    end)
                end
            end)
        end)
    end

    for _, opt in ipairs(Options) do AddOption(opt) end
    task.spawn(function() pcall(Callback, currentVal) end)
end

function Library:CreatePlayerDropdown(Page, Text, Default, Callback)
    local Flag = Page.Name .. "_" .. Text
    local currentVal = UserConfigs[Flag] or Default or "Select Player"
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
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text .. ": " .. tostring(currentVal)
    Label:SetAttribute("OriginalText", Text) 
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

    local MenuBg = Instance.new("Frame")
    MenuBg.Size = UDim2.new(1, 0, 1, -40)
    MenuBg.Position = UDim2.new(0, 0, 0, 40)
    MenuBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MenuBg.BorderSizePixel = 0
    MenuBg.Parent = Container

    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(0, 2, 1, 0)
    AccentLine.Position = UDim2.new(1, -2, 0, 0)
    AccentLine.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    AccentLine.BorderSizePixel = 0
    AccentLine.ZIndex = 5
    AccentLine.Parent = MenuBg

    local OptionList = Instance.new("ScrollingFrame")
    OptionList.Size = UDim2.new(1, -4, 1, 0)
    OptionList.Position = UDim2.new(0, 0, 0, 0)
    OptionList.BackgroundTransparency = 1
    OptionList.BorderSizePixel = 0
    OptionList.ScrollBarThickness = 2
    OptionList.ScrollBarImageColor3 = Theme.Accent
    OptionList.CanvasSize = UDim2.new(0, 0, 0, 0)
    OptionList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    OptionList.Parent = MenuBg

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = OptionList

    local isOpen = false

    local function AddOption(optName)
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 30)
        optBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        optBtn.BackgroundTransparency = 1
        optBtn.Text = tostring(optName)
        optBtn.TextColor3 = (currentVal == optName) and Theme.Text or Theme.TextDark
        optBtn.Font = (currentVal == optName) and Enum.Font.GothamBold or Enum.Font.Gotham
        optBtn.TextSize = 11
        optBtn.TextXAlignment = Enum.TextXAlignment.Center
        optBtn.Parent = OptionList

        local sep = Instance.new("Frame")
        sep.Size = UDim2.new(1, -20, 0, 1)
        sep.Position = UDim2.new(0, 10, 1, -1)
        sep.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        sep.BorderSizePixel = 0
        sep.Parent = optBtn

        optBtn.MouseEnter:Connect(function()
            TweenService:Create(optBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.85}):Play()
            if currentVal ~= optName then 
                TweenService:Create(optBtn, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
            end
        end)
        optBtn.MouseLeave:Connect(function()
            TweenService:Create(optBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            if currentVal ~= optName then 
                TweenService:Create(optBtn, TweenInfo.new(0.2), {TextColor3 = Theme.TextDark}):Play()
            end
        end)

        optBtn.MouseButton1Click:Connect(function()
            currentVal = optName
            UserConfigs[Flag] = currentVal
            
            local originalLabel = Label:GetAttribute("OriginalText")
            if originalLabel then
                local currentText = Label.Text
                local translatedPrefix = string.split(currentText, ": ")[1]
                Label.Text = translatedPrefix .. ": " .. tostring(currentVal)
            else
                Label.Text = Text .. ": " .. tostring(currentVal)
            end
            
            isOpen = false
            TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 40)}):Play()
            Icon.Text = "▼"
            TweenService:Create(Icon, TweenInfo.new(0.3), {TextColor3 = Theme.TextDark}):Play()
            
            pcall(Callback, currentVal)
        end)
    end

    TopBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            for _, child in ipairs(OptionList:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            
            local playersList = Players:GetPlayers()
            local playerCount = 0
            for _, p in ipairs(playersList) do
                if p ~= LocalPlayer then
                    AddOption(p.Name)
                    playerCount = playerCount + 1
                end
            end

            local targetHeight = math.min(40 + (playerCount * 30), 180)
            if targetHeight == 40 then targetHeight = 70 end 
            
            TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
            Icon.Text = "▲"
            TweenService:Create(Icon, TweenInfo.new(0.3), {TextColor3 = Theme.Accent}):Play()
        else
            TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 40)}):Play()
            Icon.Text = "▼"
            TweenService:Create(Icon, TweenInfo.new(0.3), {TextColor3 = Theme.TextDark}):Play()
        end
    end)

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
    Label:SetAttribute("OriginalText", Text) 
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

local function LoadProgressPage(pageObj)
    local code = game:HttpGet("https://raw.githubusercontent.com/1D4vid/lazzyloading/refs/heads/main/Progress.lua")
    loadstring(code)()({ Library = Library, Page = pageObj, Players = Players, RunService = RunService, CoreGui = CoreGui, ReplicatedStorage = ReplicatedStorage, Workspace = Workspace, LocalPlayer = LocalPlayer, TweenService = TweenService, Theme = Theme, SendNotification = SendNotification })
end

local function LoadTeleportPage(pageObj)
    local code = game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/teleport.lua")
    loadstring(code)()({ Library = Library, Page = pageObj, Players = Players, RunService = RunService, CoreGui = CoreGui, ReplicatedStorage = ReplicatedStorage, Workspace = Workspace, LocalPlayer = LocalPlayer, TweenService = TweenService, Theme = Theme, SendNotification = SendNotification })
end

local function LoadTexturesPage(pageObj)
    local code = game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/textures.lua")
    loadstring(code)()({
        Library = Library,
        Page = pageObj,
        Theme = Theme,
        UserConfigs = UserConfigs,
        isMobile = isMobile,
        Players = Players,
        LocalPlayer = LocalPlayer,
        Workspace = Workspace,
        Camera = Camera,
        UserInputService = UserInputService,
        TweenService = TweenService,
        SendNotification = SendNotification,
        formatID = formatID,
        MobileCrosshair = MobileCrosshair,
        PCSoftwareCursor = PCSoftwareCursor,
        SetPCCursorActive = SetPCCursorActive,
        UpdateCursorSizes = UpdateCursorSizes,
        ApplyGradient = ApplyGradient,
        RunService = RunService
    })
end

local function LoadVisualSkinsPage(pageObj)
    local code = game:HttpGet("https://raw.githubusercontent.com/1D4vid/lazzyloading/refs/heads/main/visualskins.lua")
    loadstring(code)()({
        Library = Library,
        Page = pageObj,
        Theme = Theme,
        Players = Players,
        LocalPlayer = LocalPlayer,
        RunService = RunService,
        TweenService = TweenService,
        ModalOverlay = ModalOverlay,
        SendNotification = SendNotification,
        ApplyGradient = ApplyGradient
    })
end

local function LoadAdvancedPage(pageObj)
    local code = game:HttpGet("https://raw.githubusercontent.com/1D4vid/lazzyloading/refs/heads/main/advanced.lua")
    loadstring(code)()({
        Library = Library,
        Page = pageObj,
        Players = Players,
        RunService = RunService,
        ReplicatedStorage = ReplicatedStorage,
        UserInputService = UserInputService,
        LocalPlayer = LocalPlayer,
        Camera = Camera,
        Workspace = Workspace,
        ScreenGui = ScreenGui
    })
end

local function LoadFogPage(pageObj)
    local code = game:HttpGet("https://raw.githubusercontent.com/1D4vid/lazzyloading/refs/heads/main/fog.lua")
    loadstring(code)()({
        Library = Library,
        Page = pageObj,
        Lighting = Lighting,
        RunService = RunService,
        TweenService = TweenService,
        UserInputService = UserInputService,
        Theme = Theme,
        UserConfigs = UserConfigs,
        ApplyGradient = ApplyGradient,
        ApplyAnimatedTextGradient = ApplyAnimatedTextGradient
    })
end

local function LoadAutoFarmPage(pageObj)
    local code = game:HttpGet("https://raw.githubusercontent.com/1D4vid/lazzyloading/refs/heads/main/autofarm.lua")
    loadstring(code)()({
        Library = Library,
        Page = pageObj,
        Theme = Theme,
        ReplicatedStorage = ReplicatedStorage,
        Workspace = Workspace,
        Players = Players,
        LocalPlayer = LocalPlayer,
        SendNotification = SendNotification
    })
end

local function LoadSoundsPage(pageObj)
    local code = game:HttpGet("https://raw.githubusercontent.com/1D4vid/lazzyloading/refs/heads/main/sounds.lua")
    loadstring(code)()({
        Library = Library, 
        Page = pageObj, 
        Players = Players, 
        Workspace = Workspace, 
        LocalPlayer = LocalPlayer, 
        ProcessCharacter = ProcessCharacter, 
        LegitSettings = LegitSettings, 
        CurrentSoundIDs = CurrentSoundIDs, 
        RefreshAllSounds = RefreshAllSounds,
        Theme = Theme,
        UserConfigs = UserConfigs
    })
end

local HighlightPage = createSidebarButton("14502433595", "Highlight") 
local VisualPage = createSidebarButton("76176408662599", "Visual") 
local ProgressPage = createSidebarButton("6761866149", "Progress", LoadProgressPage)
local TexturesPage = createSidebarButton("12623720992", "Textures", LoadTexturesPage)
local AutoFarmPage = createSidebarButton("12403104094", "Auto Farm", LoadAutoFarmPage) 
local FogPage = createSidebarButton("111246090084265", "Fog", LoadFogPage)
local SoundsPage = createSidebarButton("13288142767", "Sound", LoadSoundsPage)
local AdvancedPage = createSidebarButton("16717281575", "Advanced", LoadAdvancedPage) 
local VisualSkinsPage = createSidebarButton("11656483170", "Visual Skins", LoadVisualSkinsPage) 
local TeleportPage = createSidebarButton("12689978575", "Teleport", LoadTeleportPage)
local ScriptInfoPage = createSidebarButton("5832745500", "Info")

do
    local EspPlayersConnection = nil
    local EspPlayersLoop = nil
    local playerHighlights = setmetatable({}, {__mode = "k"})
    local playerNameGuis = setmetatable({}, {__mode = "k"})
    local BEAST_WEAPON_NAMES = {["Hammer"] = true,["Gemstone Hammer"] = true,["Iron Hammer"] = true,["Mallet"] = true}
    local beastCache = setmetatable({}, {__mode = "k"})
    
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
        playerHighlights = setmetatable({}, {__mode = "k"})
        playerNameGuis = setmetatable({}, {__mode = "k"})
    end

    local EspOutlineLoop = nil
    local EspOutlinePlayerAddedConn = nil
    local EspOutlineHighlights = setmetatable({}, {__mode = "k"})
    
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

    local tracerEnabled = false
    local tracerOrigin = "Inferior"
    local tracerLines = {}
    local TracerRenderConn = nil

    local function getRoot(char) return char and char:FindFirstChild("HumanoidRootPart") end
    local function isAlive(char)
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        return humanoid and humanoid.Health > 0
    end

    local function updateTracerState(state)
        tracerEnabled = state
        if state then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and not tracerLines[p] then
                    local line = Drawing.new("Line")
                    line.Thickness = 1.5
                    line.Transparency = 1
                    line.Visible = false
                    tracerLines[p] = line
                end
            end
            
            if not TracerRenderConn then
                TracerRenderConn = RunService.RenderStepped:Connect(function()
                    local viewportSize = Camera.ViewportSize
                    local from = Vector2.new(viewportSize.X / 2, viewportSize.Y)

                    if tracerOrigin == "Topo" then
                        from = Vector2.new(viewportSize.X / 2, 0)
                    elseif tracerOrigin == "Inferior" then
                        from = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                    elseif tracerOrigin == "Torso" then
                        local localChar = LocalPlayer.Character
                        local localRoot = getRoot(localChar)
                        if localRoot and isAlive(localChar) then
                            local origin3D = localRoot.Position
                            local origin2D, originVisible = Camera:WorldToViewportPoint(origin3D)
                            if not originVisible then
                                local camForward = Camera.CFrame.LookVector
                                local adjusted = origin3D + (camForward * 2)
                                origin2D = Camera:WorldToViewportPoint(adjusted)
                            end
                            from = Vector2.new(origin2D.X, origin2D.Y)
                        end
                    end

                    for player, line in pairs(tracerLines) do
                        local char = player.Character
                        local root = getRoot(char)

                        if tracerEnabled and root and isAlive(char) then
                            local pos, visible = Camera:WorldToViewportPoint(root.Position)
                            if visible then
                                line.From = from
                                line.To = Vector2.new(pos.X, pos.Y)
                                line.Color = isBeast(player) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
                                line.Visible = true
                            else
                                line.Visible = false
                            end
                        else
                            if line then line.Visible = false end
                        end
                    end
                end)
            end
        else
            for _, line in pairs(tracerLines) do 
                if line then line.Visible = false end
            end
        end
    end

    Players.PlayerAdded:Connect(function(p)
        if p ~= LocalPlayer then
            local line = Drawing.new("Line")
            line.Thickness = 1.5
            line.Transparency = 1
            line.Visible = false
            tracerLines[p] = line
        end
    end)

    Players.PlayerRemoving:Connect(function(p)
        if tracerLines[p] then tracerLines[p]:Remove(); tracerLines[p] = nil end
        beastCache[p] = nil
    end)

    local EspCompLoop = nil
    local EspCompRender = nil
    local computers = {}
    local function ClearCompESP()
        for _, data in pairs(computers) do
            if data.Highlight then data.Highlight:Destroy() end
        end
        computers = {}
    end
    
    local EspPodsLoop = nil
    local createdPodESP = {}
    local beastGlowConns = {}
    local activeGlows = setmetatable({}, {__mode = "v"})

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
            
            EspOutlinePlayerAddedConn = Players.PlayerAdded:Connect(function(p)
                addOutline(p)
            end)
            
            EspOutlineLoop = task.spawn(function()
                while state and task.wait(0.3) do
                    for p, h in pairs(EspOutlineHighlights) do
                        h.OutlineColor = checkTool(p.Character) and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)
                    end
                end
            end)
        else
            if EspOutlinePlayerAddedConn then EspOutlinePlayerAddedConn:Disconnect(); EspOutlinePlayerAddedConn = nil end
            if EspOutlineLoop then task.cancel(EspOutlineLoop) end
            for p, h in pairs(EspOutlineHighlights) do
                if h then h:Destroy() end
            end
            table.clear(EspOutlineHighlights)
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
    
    Library:CreateToggle(HighlightPage, "Esp Tracer Line", false, function(state)
        updateTracerState(state)
    end)
    
    Library:CreateDropdown(HighlightPage, "Tracer Origin", {"Inferior", "Topo", "Torso"}, "Inferior", function(val)
        tracerOrigin = val
    end)
    
    local EspCompAdded2 = nil
    local function clearEspComputers()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "CompESP" then obj:Destroy() end
        end
    end
    Library:CreateToggle(HighlightPage, "Esp Computers", false, function(state) 
        if state then
            local BLUE_READY = Color3.fromRGB(0, 170, 255)
            local GREEN_HACKED = Color3.fromRGB(0, 255, 0)
            local RED_ERROR = Color3.fromRGB(255, 0, 0)
            local BORDER_COLOR = Color3.fromRGB(255, 255, 255)
            local FILL_TRANSPARENCY = 0.5
            local OUTLINE_TRANSPARENCY = 0

            local function updateEspColor(screen, highlight)
                local color = screen.Color
                if color.R > color.G and color.R > color.B then
                    highlight.FillColor = RED_ERROR
                elseif color.G > color.B and color.G > color.R then
                    highlight.FillColor = GREEN_HACKED
                else
                    highlight.FillColor = BLUE_READY
                end
            end

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
                        highlight.OutlineColor = BORDER_COLOR
                        highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
                        highlight.FillTransparency = FILL_TRANSPARENCY
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
    
    local doorEspConnection = nil
    local doorEspLoop = nil
    local trackedDoors = {}
    
    Library:CreateToggle(HighlightPage, "Esp Doors", false, function(state) 
        if state then
            local COLOR_OPEN = Color3.fromRGB(0, 255, 0)
            local COLOR_CLOSED = Color3.fromRGB(255, 0, 0)

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
                            if not trackedDoors[child] then
                                trackedDoors[child] = {
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

            for _, obj in ipairs(Workspace:GetDescendants()) do
                checkIsDoorModelESP(obj)
            end

            doorEspConnection = Workspace.DescendantAdded:Connect(checkIsDoorModelESP)

            doorEspLoop = task.spawn(function()
                while task.wait(0.1) do
                    if not state then break end 
                    
                    for part, data in pairs(trackedDoors) do
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
                            trackedDoors[part] = nil
                        end
                    end
                end
            end)
        else
            if doorEspConnection then doorEspConnection:Disconnect() doorEspConnection = nil end
            if doorEspLoop then task.cancel(doorEspLoop) doorEspLoop = nil end
            
            for _, data in pairs(trackedDoors) do
                if data.esp then data.esp:Destroy() end
            end
            table.clear(trackedDoors)
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
end

do
    Library:CreateSection(HighlightPage, "Global Settings")
    Library:CreateToggle(HighlightPage, "Only Esp Beast", false, function(state)
        EspConfig.OnlyBeast = state
    end)
    Library:CreateSection(HighlightPage, "Color Customization")
    Library:CreateColorPicker(HighlightPage, "Beast highlight Color", Color3.fromRGB(0, 255, 255), function(color)
        EspConfig.BeastHighlight = color
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") then
                local g = p.Character.Head:FindFirstChild("BeastGlow")
                if g then g.Color = color end
            end
        end
    end)
    Library:CreateColorPicker(HighlightPage, "Survivor ESP Color", Color3.fromRGB(0, 255, 0), function(color)
        EspConfig.Survivor = color
    end)
    Library:CreateColorPicker(HighlightPage, "Beast ESP Color", Color3.fromRGB(255, 0, 0), function(color)
        EspConfig.Beast = color
    end)
    Library:CreateColorPicker(HighlightPage, "Freezepod ESP Color", Color3.fromRGB(0, 255, 255), function(color)
        EspConfig.Pod = color
    end)
end

do
    local HideLeavesConnection = nil
    local hiddenParts = setmetatable({}, {__mode = "k"}) 
    local currentFont = "Default"
    local originalFonts = setmetatable({}, {__mode = "k"})
    
    local originalName = LocalPlayer.Name
    local originalDisplayName = LocalPlayer.DisplayName
    local originalLevel = "1"
    local spoofName = LocalPlayer.Name
    local spoofLevel = 100
    local spoofIconId = "rbxassetid://1188562340"
    
    local spoofedOthers = {}
    local othersOriginalDisplayNames = {}
    local spoofOthersEnabled = false
    
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
    
    local function patchElement(e)
        if not e or not e:IsA("GuiObject") then return end
        if not (e:IsA("TextLabel") or e:IsA("TextButton") or e:IsA("TextBox")) then return end
        local ok, txt = pcall(function() return e.Text end)
        if not ok or not txt or txt == "" then return end
        
        local changed = false
        local newTxt = txt
        
        if spoofVisualsEnabled then
            if newTxt:find(originalName, 1, true) then
                newTxt = newTxt:gsub(originalName, spoofName)
                changed = true
            end
            if originalDisplayName and newTxt:find(originalDisplayName, 1, true) then
                newTxt = newTxt:gsub(originalDisplayName, spoofName)
                changed = true
            end
        end
        
        if spoofOthersEnabled then
            for origNameKey, fakeData in pairs(spoofedOthers) do
                local fakeName = fakeData.spoofName
                if newTxt:find(origNameKey, 1, true) then
                    newTxt = newTxt:gsub(origNameKey, fakeName)
                    changed = true
                end
                local origDisp = othersOriginalDisplayNames[origNameKey]
                if origDisp and newTxt:find(origDisp, 1, true) then
                    newTxt = newTxt:gsub(origDisp, fakeName)
                    changed = true
                end
            end
        end
        
        if changed then
            if not originalTexts[e] then originalTexts[e] = txt end
            pcall(function() e.Text = newTxt end)
        else
            if originalTexts[e] and txt ~= originalTexts[e] then
                local orig = originalTexts[e]
                local shouldBeSpoofed = false
                
                if spoofVisualsEnabled and (orig:find(originalName, 1, true) or (originalDisplayName and orig:find(originalDisplayName, 1, true))) then
                    shouldBeSpoofed = true
                end
                
                if spoofOthersEnabled and not shouldBeSpoofed then
                    for origNameKey, _ in pairs(spoofedOthers) do
                        if orig:find(origNameKey, 1, true) or (othersOriginalDisplayNames[origNameKey] and orig:find(othersOriginalDisplayNames[origNameKey], 1, true)) then
                            shouldBeSpoofed = true
                            break
                        end
                    end
                end
                
                if not shouldBeSpoofed then
                    pcall(function() e.Text = orig end)
                end
            end
        end
    end
    
    local function trackElement(e)
        if not e then return end
        if e:IsA("TextLabel") or e:IsA("TextButton") or e:IsA("TextBox") then
            patchElement(e)
            pcall(function() e:GetPropertyChangedSignal("Text"):Connect(function() patchElement(e) end) end)
        end
    end
    local trackersInitialized = false

    local function updateTrackers()
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
        end
        for e, origTxt in pairs(originalTexts) do
            if e and e.Parent then 
                pcall(function() e.Text = origTxt end)
                patchElement(e)
            end
        end
    end

    spoofVisualsLoop = RunService.Heartbeat:Connect(function()
        if not spoofVisualsEnabled and not spoofOthersEnabled then return end
        pcall(function()
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local namesFrame = playerGui and playerGui:FindFirstChild("PlayerNamesFrame", true)

            if spoofOthersEnabled then
                for origNameKey, data in pairs(spoofedOthers) do
                    local player = Players:FindFirstChild(origNameKey)
                    if player and player.Character then
                        local hum = player.Character:FindFirstChildOfClass("Humanoid")
                        if hum then 
                            if not othersOriginalDisplayNames[origNameKey] then 
                                othersOriginalDisplayNames[origNameKey] = hum.DisplayName 
                            end
                            pcall(function() hum.DisplayName = data.spoofName end) 
                        end
                    end
                    
                    if namesFrame then
                        local playerFrame = namesFrame:FindFirstChild(origNameKey .. "PlayerFrame")
                        if playerFrame then
                            local levelLabel = playerFrame:FindFirstChild("LevelLabel")
                            local nameLabel  = playerFrame:FindFirstChild("NameLabel")
                            local iconLabel  = playerFrame:FindFirstChild("IconLabel")
                            
                            if levelLabel then levelLabel.Text = tostring(data.spoofLevel) end
                            if nameLabel then nameLabel.Text = data.spoofName end
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
                                fakeIcon.Image = data.spoofIcon
                                fakeIcon.Visible = true
                                fakeIcon.ScaleType = Enum.ScaleType.Fit
                                
                                if data.spoofIcon == meusIcones.QA or data.spoofIcon == meusIcones.CON then
                                    fakeIcon.Size = UDim2.new(1.35, 0, 1.35, 0) 
                                else
                                    fakeIcon.Size = UDim2.new(1.0, 0, 1.0, 0)
                                end
                            end
                        end
                    end
                end
            end
            
            if spoofVisualsEnabled then
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
                    fakeIcon.ScaleType = Enum.ScaleType.Fit
                    if spoofIconId == meusIcones.QA or spoofIconId == meusIcones.CON then
                        fakeIcon.Size = UDim2.new(1.35, 0, 1.35, 0) 
                    else
                        fakeIcon.Size = UDim2.new(1.0, 0, 1.0, 0)
                    end
                end
                playerFrame.LayoutOrder = -spoofLevel
            end
        end)
    end)

    local function restoreOtherPlayer(realName)
        if not realName then return end
        spoofedOthers[realName] = nil
        
        local player = Players:FindFirstChild(realName)
        if player and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and othersOriginalDisplayNames[realName] then 
                pcall(function() hum.DisplayName = othersOriginalDisplayNames[realName] end) 
            end
        end
        
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local namesFrame = playerGui and playerGui:FindFirstChild("PlayerNamesFrame", true)
        if namesFrame then
            local playerFrame = namesFrame:FindFirstChild(realName .. "PlayerFrame")
            if playerFrame then
                local iconLabel = playerFrame:FindFirstChild("IconLabel")
                if iconLabel then
                    iconLabel.ImageTransparency = 0
                    local fakeIcon = iconLabel:FindFirstChild("IconeFakeCorrigido")
                    if fakeIcon then fakeIcon.Visible = false end
                end
            end
        end
        updateTrackers()
    end

    local stretchConnection = nil

    local grayConns = {}
    local grayBackups = setmetatable({}, {__mode = "k"})
    local function makeGray(char)
        if not char then return end
        if not grayBackups[char] then
            grayBackups[char] = { parts = setmetatable({}, {__mode="k"}), meshes = setmetatable({}, {__mode="k"}), clothes = {} }
        end
        local backup = grayBackups[char]
        
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:FindFirstAncestorWhichIsA("Tool") then continue end
            if obj:IsA("BasePart") then
                if not backup.parts[obj] then
                    backup.parts[obj] = { Color = obj.Color, Material = obj.Material }
                end
                obj.Color = Color3.fromRGB(150, 150, 150)
                obj.Material = Enum.Material.SmoothPlastic
                if obj:IsA("MeshPart") then
                    if not backup.meshes[obj] then backup.meshes[obj] = obj.TextureID end
                    obj.TextureID = ""
                end
            elseif obj:IsA("SpecialMesh") then
                if not backup.meshes[obj] then backup.meshes[obj] = obj.TextureId end
                obj.TextureId = ""
            elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("BodyColors") or (obj:IsA("Decal") and obj.Name ~= "face") then
                table.insert(backup.clothes, {obj = obj, parent = obj.Parent})
                obj.Parent = nil
            end
        end
    end
    
    local function restoreGray(char)
        local backup = grayBackups[char]
        if not backup then return end
        
        for part, data in pairs(backup.parts) do
            if part and part.Parent then
                part.Color = data.Color
                part.Material = data.Material
            end
        end
        for mesh, tex in pairs(backup.meshes) do
            if mesh and mesh.Parent then
                if mesh:IsA("MeshPart") then mesh.TextureID = tex
                elseif mesh:IsA("SpecialMesh") then mesh.TextureId = tex end
            end
        end
        for _, clothData in ipairs(backup.clothes) do
            if clothData.obj then clothData.obj.Parent = clothData.parent end
        end
        grayBackups[char] = nil
    end

    Library:CreateSection(VisualPage, "Camera & UI")
    local FovVal = 70
    Library:CreateSlider(VisualPage, "Fov Changer", 70, 120, 70, function(v) FovVal = v end)
    RunService.RenderStepped:Connect(function() 
        local cam = Workspace.CurrentCamera
        if cam then cam.FieldOfView = FovVal end
    end)
    local fontOptions = {"Default"}
    for _, font in ipairs(Enum.Font:GetEnumItems()) do
        if font.Name ~= "Unknown" and font.Name ~= "Legacy" then table.insert(fontOptions, font.Name) end
    end
    Library:CreateDropdown(VisualPage, "Font Changer", fontOptions, "Default", function(val) 
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
    Library:CreateToggle(VisualPage, "stretch screen", false, function(state) 
        if state then getgenv().Resolution = {[".gg/scripters"] = 0.65}
        local Cam = workspace.CurrentCamera
        stretchConnection = game:GetService("RunService").RenderStepped:Connect(function() Cam.CFrame = Cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, getgenv().Resolution[".gg/scripters"], 0, 0, 0, 1) end) else if stretchConnection then stretchConnection:Disconnect()
        stretchConnection = nil end
        getgenv().Resolution = {[".gg/scripters"] = 1} end 
    end)

    Library:CreateSection(VisualPage, "Visual Name/Level")
    Library:CreateToggle(VisualPage, "Enable Visuals", false, function(state) 
        spoofVisualsEnabled = state
        if state then
            updateTrackers()
        else
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
            updateTrackers()
        end
    end)
    Library:CreateInput(VisualPage, "Fake Name", LocalPlayer.Name, function(val) 
        spoofName = val 
        if spoofVisualsEnabled then updateTrackers() end
    end)
    Library:CreateInput(VisualPage, "Fake Level", "67", function(val) 
        spoofLevel = tonumber(val) or 100 
    end)
    Library:CreateDropdown(VisualPage, "Select Icon", {"VIP", "QA", "CON", "Mod", "Dev", "Manager", "MrWindy", "Nenhum"}, "VIP", function(val) 
        spoofIconId = meusIcones[val] or "" 
    end)

    Library:CreateSection(VisualPage, "Spoof Other Players")
    local targetOrigName = "Select Player"
    local targetFakeName = "Fake Name"
    local targetFakeLevel = 100
    local targetFakeIcon = meusIcones.VIP
    
    Library:CreateToggle(VisualPage, "Enable Others Spoofing", false, function(state)
        spoofOthersEnabled = state
        if state then
            updateTrackers()
        else
            for origNameKey, _ in pairs(spoofedOthers) do
                local p = Players:FindFirstChild(origNameKey)
                if p and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    local origDisp = othersOriginalDisplayNames[origNameKey]
                    if hum and origDisp then pcall(function() hum.DisplayName = origDisp end) end
                end
                
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                local namesFrame = playerGui and playerGui:FindFirstChild("PlayerNamesFrame", true)
                if namesFrame then
                    local playerFrame = namesFrame:FindFirstChild(origNameKey .. "PlayerFrame")
                    if playerFrame then
                        local iconLabel = playerFrame:FindFirstChild("IconLabel")
                        if iconLabel then
                            iconLabel.ImageTransparency = 0
                            local fakeIcon = iconLabel:FindFirstChild("IconeFakeCorrigido")
                            if fakeIcon then fakeIcon.Visible = false end
                        end
                    end
                end
            end
            updateTrackers()
        end
    end)

    Library:CreatePlayerDropdown(VisualPage, "Target Player", "Select Player", function(val) 
        targetOrigName = val 
    end)

    Library:CreateInput(VisualPage, "Target Fake Name", "Fake Name", function(val) 
        targetFakeName = val 
    end)
    
    Library:CreateInput(VisualPage, "Target Fake Level", "100", function(val) 
        targetFakeLevel = tonumber(val) or 100 
    end)
    
    Library:CreateDropdown(VisualPage, "Target Fake Icon", {"VIP", "QA", "CON", "Mod", "Dev", "Manager", "MrWindy", "Nenhum"}, "VIP", function(val) 
        targetFakeIcon = meusIcones[val] or "" 
    end)
    
    Library:CreateButton(VisualPage, "Apply To Selected Player", function()
        if targetOrigName ~= "Select Player" and targetFakeName ~= "" then
            local p = Players:FindFirstChild(targetOrigName)
            if p then
                if not othersOriginalDisplayNames[p.Name] then
                    othersOriginalDisplayNames[p.Name] = p.DisplayName
                end
                
                spoofedOthers[p.Name] = {
                    spoofName = targetFakeName, 
                    spoofLevel = targetFakeLevel, 
                    spoofIcon = targetFakeIcon
                }
                
                SendNotification("Applied fake data to " .. p.Name, 3)
                
                if spoofOthersEnabled then
                    updateTrackers()
                end
            end
        else
            SendNotification("Select a valid player first!", 3)
        end
    end)
    
    Library:CreateButton(VisualPage, "Reset Selected Player", function()
        if targetOrigName ~= "Select Player" then
            restoreOtherPlayer(targetOrigName)
            SendNotification("Restored " .. targetOrigName, 3)
        end
    end)
    
    Library:CreateButton(VisualPage, "Clear All Spoofed Players", function()
        for name, _ in pairs(spoofedOthers) do
            restoreOtherPlayer(name)
        end
        table.clear(spoofedOthers)
        SendNotification("All spoofed players restored.", 3)
    end)

    Library:CreateSection(VisualPage, "Visual Environment")
    Library:CreateToggle(VisualPage, "Hide Leaves (Only Homestead)", false, function(state) 
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
            table.clear(hiddenParts)
        end
    end)

    Library:CreateToggle(VisualPage, "Gray characters", false, function(state) 
        if state then
            local function setupCharacter(character)
                local player = Players:GetPlayerFromCharacter(character)
                if player and not player:HasAppearanceLoaded() then
                    player.CharacterAppearanceLoaded:Wait()
                end
                task.wait(0.1)
                if not character or not character.Parent then return end
                makeGray(character)
                
                local c1 = character.DescendantAdded:Connect(function(obj)
                    task.wait()
                    if obj and obj.Parent then
                        if obj:FindFirstAncestorWhichIsA("Tool") then return end
                        if obj:IsA("BasePart") then
                            if not grayBackups[character].parts[obj] then
                                grayBackups[character].parts[obj] = { Color = obj.Color, Material = obj.Material }
                            end
                            obj.Color = Color3.fromRGB(150, 150, 150)
                            obj.Material = Enum.Material.SmoothPlastic
                            if obj:IsA("MeshPart") then
                                if not grayBackups[character].meshes[obj] then
                                    grayBackups[character].meshes[obj] = obj.TextureID
                                end
                                obj.TextureID = ""
                            end
                        elseif obj:IsA("SpecialMesh") then
                            if not grayBackups[character].meshes[obj] then
                                grayBackups[character].meshes[obj] = obj.TextureId
                            end
                            obj.TextureId = ""
                        elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("BodyColors") or (obj:IsA("Decal") and obj.Name ~= "face") then
                            table.insert(grayBackups[character].clothes, {obj = obj, parent = obj.Parent})
                            obj.Parent = nil
                        end
                    end
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
            
            for char, _ in pairs(grayBackups) do
                restoreGray(char)
            end
        end
    end)
    Library:CreateToggle(VisualPage, "Floorbang", false, function(state)
        if not getgenv().NexFloorbang then
            getgenv().NexFloorbang = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/floorbang.lua"))()
        end
        getgenv().NexFloorbang.Toggle(state)
    end)
end

do
    local function createInfoCard(titleText, items)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 40 + (#items * 25))
        Card.BackgroundColor3 = Color3.new(0, 0, 0)
        Card.BackgroundTransparency = 0.4
        Card.BorderSizePixel = 0
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)

        local Stroke = Instance.new("UIStroke", Card)
        Stroke.Color = Color3.fromRGB(35, 35, 35)
        Stroke.Thickness = 1
        
        local TitleLabel = Instance.new("TextLabel", Card)
        TitleLabel.Size = UDim2.new(1, -30, 0, 30)
        TitleLabel.Position = UDim2.new(0, 20, 0, 0)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = titleText
        TitleLabel.Font = Enum.Font.GothamBlack
        TitleLabel.TextSize = 12
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local AccentBar = Instance.new("Frame", Card)
        AccentBar.Size = UDim2.new(0, 3, 0, 14)
        AccentBar.Position = UDim2.new(0, 10, 0, 8)
        AccentBar.BackgroundColor3 = Theme.Accent
        AccentBar.BorderSizePixel = 0
        Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(1, 0)
        
        local Sep = Instance.new("Frame", Card)
        Sep.Size = UDim2.new(1, -20, 0, 1)
        Sep.Position = UDim2.new(0, 10, 0, 30)
        Sep.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Sep.BorderSizePixel = 0

        local dynamicLabels = {}

        for i, field in ipairs(items) do
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Position = UDim2.new(0, 15, 0, 35 + ((i - 1) * 25))
            Label.BackgroundTransparency = 1
            Label.RichText = true
            Label.Text = field.Default
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 12
            Label.TextColor3 = Theme.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Card

            if field.Id then
                dynamicLabels[field.Id] = Label
            end
        end
        return Card, dynamicLabels
    end

    local creditsCard, _ = createInfoCard("CREDITS", {
        {Default = "<b>NexVoid Creator:</b> <font color='rgb(150,150,150)'>Discord @davidnaoxita.</font>"},
        {Default = "<b>NexVoid Testers:</b> <font color='rgb(150,150,150)'>znerxeys, ayko.</font>"},
        {Default = "<b>NexVoid Contributor:</b> <font color='rgb(150,150,150)'>@v1kxz</font>"}
    })
    creditsCard.Parent = ScriptInfoPage

    local playerCard, playerLabels = createInfoCard("PLAYER INFO", {
        {Id = "FPS", Default = "<b>FPS:</b> <font color='rgb(150,150,150)'>...</font>"},
        {Id = "Ping", Default = "<b>Ping:</b> <font color='rgb(150,150,150)'>... ms</font>"},
        {Id = "Exec", Default = "<b>Executor:</b> <font color='rgb(150,150,150)'>" .. (identifyexecutor and identifyexecutor() or "Unknown") .. "</font>"}
    })
    playerCard.Parent = ScriptInfoPage

    local serverCard, serverLabels = createInfoCard("SERVER INFO", {
        {Id = "Region", Default = "<b>Region:</b> <font color='rgb(150,150,150)'>Fetching...</font>"},
        {Id = "Players", Default = "<b>Players:</b> <font color='rgb(150,150,150)'>...</font>"},
        {Id = "Max", Default = "<b>Max Players:</b> <font color='rgb(150,150,150)'>" .. tostring(Players.MaxPlayers) .. "</font>"}
    })
    serverCard.Parent = ScriptInfoPage

    Library:CreateButton(ScriptInfoPage, "Server Rejoin", function()
        local TeleportService = game:GetService("TeleportService")
        if #Players:GetPlayers() <= 1 then
            LocalPlayer:Kick("\nRejoining...")
            task.wait()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)

    Library:CreateButton(ScriptInfoPage, "Random Servers", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)

    local frames = 0
    local lastUpdate = tick()

    task.spawn(function()
        local s, r = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("http://ip-api.com/json/"))
        end)
        local reg = "Unknown"
        if s and r and r.countryCode then
            reg = r.countryCode
        end
        if serverLabels["Region"] then
            serverLabels["Region"].Text = "<b>Region:</b> <font color='rgb(150,150,150)'>" .. reg .. "</font>"
        end
    end)

    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local currentTick = tick()
        if currentTick - lastUpdate >= 1 then
            local fps = frames
            frames = 0
            lastUpdate = currentTick
            
            if playerLabels["FPS"] then
                playerLabels["FPS"].Text = "<b>FPS:</b> <font color='rgb(150,150,150)'>" .. tostring(fps) .. "</font>"
            end
            
            local pingVal = 0
            pcall(function()
                pingVal = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            if playerLabels["Ping"] then
                playerLabels["Ping"].Text = "<b>Ping:</b> <font color='rgb(150,150,150)'>" .. tostring(pingVal) .. " ms</font>"
            end

            if serverLabels["Players"] then
                serverLabels["Players"].Text = "<b>Players:</b> <font color='rgb(150,150,150)'>" .. tostring(#Players:GetPlayers()) .. "</font>"
            end
        end
    end)

    local CenterMsg1 = Instance.new("TextLabel")
    CenterMsg1.Size = UDim2.new(1, 0, 0, 20)
    CenterMsg1.BackgroundTransparency = 1
    CenterMsg1.Text = "Thank you for using Nexvoid. Nexvoid on top."
    CenterMsg1.Font = Enum.Font.Gotham
    CenterMsg1.TextSize = 11
    CenterMsg1.TextColor3 = Color3.fromRGB(150, 150, 150)
    CenterMsg1.TextXAlignment = Enum.TextXAlignment.Center
    CenterMsg1.Parent = ScriptInfoPage

    local CenterMsg2 = Instance.new("TextLabel")
    CenterMsg2.Size = UDim2.new(1, 0, 0, 20)
    CenterMsg2.BackgroundTransparency = 1
    CenterMsg2.Text = "NexVoid is a free script, don't pay for it."
    CenterMsg2.Font = Enum.Font.Gotham
    CenterMsg2.TextSize = 11
    CenterMsg2.TextColor3 = Color3.fromRGB(150, 150, 150)
    CenterMsg2.TextXAlignment = Enum.TextXAlignment.Center
    CenterMsg2.Parent = ScriptInfoPage
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
