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

local CurrentCursorSize = 24
local PCCursorActive = false

local function formatID(id)
	if type(id) == "number" and id > 0 then return "rbxassetid://" .. id
	elseif type(id) == "string" and id ~= "" and id ~= "0" then
        if not id:find("rbxassetid://") then return "rbxassetid://" .. id else return id end
	end
	return nil
end

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
AnimeBg.Image = "rbxassetid://105390794856350"
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
	SaveCfgBtn.Text = "Saved Successfully!"
	task.wait(1.5)
	SaveCfgBtn.Text = "Save Configurations" 
end)

ResetCfgBtn.MouseButton1Click:Connect(function() 
	ResetConfigs()
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

local function createSidebarButton(iconId, name)
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
	return Page
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
		pcall(Callback, finalVal)
	end)
end

-- Função especial de "Em desenvolvimento"
local function CreateInDevelopmentUI(Page)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 1, 0)
    Container.BackgroundTransparency = 1
    Container.Parent = Page

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "Em desenvolvimento..."
    Label.Font = Enum.Font.GothamBlack
    Label.TextSize = 22
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Parent = Container

    ApplyAnimatedTextGradient(Label)

    task.spawn(function()
        while task.wait() and Label.Parent do
            local t1 = TweenService:Create(Label, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize = 26})
            t1:Play()
            t1.Completed:Wait()
            local t2 = TweenService:Create(Label, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize = 22})
            t2:Play()
            t2.Completed:Wait()
        end
    end)
end

-- ===========================
-- CRIAÇÃO DAS ABAS (PÁGINAS)
-- ===========================

local HighlightPage = createSidebarButton("15909461117", "Highlight") 
local HighlightConfigPage = createSidebarButton("12403104094", "Highlight Config") 
local VisualPage = createSidebarButton("76176408662599", "Visual") 
local ProgressPage = createSidebarButton("16181404460", "Progress")
local AdvancedPage = createSidebarButton("16717281575", "Advanced") 
local TexturesPage = createSidebarButton("127930161876549", "Textures") -- ESSA PÁGINA MANTÉM OS SCRIPTS
local SoundsPage = createSidebarButton("7203392850", "Sound")
local VisualSkinsPage = createSidebarButton("13285615740", "Visual Skins") 
local CrossHairPage = createSidebarButton("16181366859", "CrossHair")
local TeleportPage = createSidebarButton("12689978575", "Teleport")
local ScriptInfoPage = createSidebarButton("5832745500", "Info")


-- APLICANDO A TELA DE "EM DESENVOLVIMENTO" PARA QUASE TODAS AS ABAS
CreateInDevelopmentUI(HighlightPage)
CreateInDevelopmentUI(HighlightConfigPage)
CreateInDevelopmentUI(VisualPage)
CreateInDevelopmentUI(ProgressPage)
CreateInDevelopmentUI(AdvancedPage)
CreateInDevelopmentUI(SoundsPage)
CreateInDevelopmentUI(VisualSkinsPage)
CreateInDevelopmentUI(CrossHairPage)
CreateInDevelopmentUI(TeleportPage)
CreateInDevelopmentUI(ScriptInfoPage)


-- ===========================
-- CATEGORIA TEXTURES (INACTA)
-- ===========================
do
    Library:CreateSection(TexturesPage, "Textures Settings")
    Library:CreateToggle(TexturesPage, "Remove Textures", false, function(state) 
        if not getgenv().NexOptimization then
            getgenv().NexOptimization = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/fps%20booster%20e%20remove%20textures.lua"))()
        end
        getgenv().NexOptimization.ToggleTextures(state)
    end)
    
    Library:CreateToggle(TexturesPage, "FpsBooster", false, function(state) 
        if not getgenv().NexOptimization then
            getgenv().NexOptimization = loadstring(game:HttpGet("https://raw.githubusercontent.com/1D4vid/FTFNexVoid/refs/heads/main/fps%20booster%20e%20remove%20textures.lua"))()
        end
        getgenv().NexOptimization.ToggleFPSBooster(state)
    end)

    local ultraHDConns = {}
    local createdMaterials = {}
    Library:CreateToggle(TexturesPage, "Ultra HD Graphics", false, function(state) 
        local MaterialService = game:GetService("MaterialService")
        local StarterGui = game:GetService("StarterGui")
        local Camera = Workspace.CurrentCamera
        
        if state then
            local function createMaterial(name, baseMaterial, colorMap, normalMap, roughnessMap)
                local Mat = Instance.new("MaterialVariant")
                Mat.Name = name .. "_TextureOnly"
                Mat.BaseMaterial = baseMaterial
                Mat.ColorMap = colorMap
                Mat.NormalMap = normalMap
                Mat.RoughnessMap = roughnessMap
                Mat.Parent = MaterialService
                pcall(function() MaterialService:SetBaseMaterialOverride(baseMaterial, Mat) end)
                table.insert(createdMaterials, {Variant = Mat, Base = baseMaterial})
            end

            createMaterial("Concrete", Enum.Material.Concrete, "rbxassetid://6223521473", "rbxassetid://6223521257", "rbxassetid://6223521360")
            createMaterial("Brick", Enum.Material.Brick, "rbxassetid://6396996328", "rbxassetid://6396996024", "rbxassetid://6396996160")
            createMaterial("Wood", Enum.Material.Wood, "rbxassetid://924320031", "rbxassetid://924320256", "rbxassetid://924305001")
            createMaterial("WoodPlanks", Enum.Material.WoodPlanks, "rbxassetid://924320031", "rbxassetid://924320256", "rbxassetid://924305001")

            pcall(function() MaterialService.Use2022Materials = true end)

            local spectateIndex = 1
            local allPlayers = {}
            local function updatePlayerList()
                allPlayers = {}
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                        table.insert(allPlayers, plr)
                    end
                end
            end
            local function spectatePlayer(direction)
                updatePlayerList()
                if #allPlayers == 0 then return end

                spectateIndex = spectateIndex + direction
                if spectateIndex > #allPlayers then spectateIndex = 1 end
                if spectateIndex < 1 then spectateIndex = #allPlayers end

                local target = allPlayers[spectateIndex]
                if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                    Camera.CameraType = Enum.CameraType.Custom
                    Camera.CameraSubject = target.Character.Humanoid
                    
                    pcall(function()
                        StarterGui:SetCore("SendNotification", {
                            Title = "Spectating";
                            Text = target.Name;
                            Duration = 1;
                        })
                    end)
                end
            end
            local function stopSpectating()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    Camera.CameraType = Enum.CameraType.Custom
                    Camera.CameraSubject = LocalPlayer.Character.Humanoid
                    pcall(function()
                        StarterGui:SetCore("SendNotification", {Title = "Reset"; Text = "Camera no Jogador"; Duration = 2})
                    end)
                end
            end

            table.insert(ultraHDConns, UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode == Enum.KeyCode.Right then
                    spectatePlayer(1)
                elseif input.KeyCode == Enum.KeyCode.Left then
                    spectatePlayer(-1)
                elseif input.KeyCode == Enum.KeyCode.Backspace then
                    stopSpectating()
                end
            end))
        else
            for _, m in ipairs(createdMaterials) do
                pcall(function() MaterialService:SetBaseMaterialOverride(m.Base, "") end)
                if m.Variant then m.Variant:Destroy() end
            end
            table.clear(createdMaterials)
            pcall(function() MaterialService.Use2022Materials = false end)
            
            for _, c in ipairs(ultraHDConns) do c:Disconnect() end
            table.clear(ultraHDConns)
            
            if Camera.CameraSubject and Camera.CameraSubject:IsA("Humanoid") and Camera.CameraSubject.Parent ~= LocalPlayer.Character then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    Camera.CameraType = Enum.CameraType.Custom
                    Camera.CameraSubject = LocalPlayer.Character.Humanoid
                end
            end
        end
    end)

    Library:CreateSection(TexturesPage, "Double Jump Effects")

    local currentDoubleJumpConns = {}
    local originalTextures = {}
    local OriginalSparkleColors = {}
    local function EnableDoubleJumpEffect(texturaID)
        for _, c in ipairs(currentDoubleJumpConns) do c:Disconnect() end
        table.clear(currentDoubleJumpConns)
        
        local function aplicarTextura(obj)
            if texturaID == "Default" then
                obj:SetAttribute("CurrentTexture", nil)
                if obj.ClassName == "ParticleEmitter" then
                    if originalTextures[obj] then
                        obj.Texture = originalTextures[obj]
                    end
                elseif obj.ClassName == "Sparkles" then
                    local oldClone = obj.Parent:FindFirstChild("CustomSparkleClone_" .. obj.Name)
                    if oldClone then oldClone:Destroy() end
                    if OriginalSparkleColors[obj] then
                        pcall(function() obj.SparkleColor = OriginalSparkleColors[obj] end)
                    else
                        pcall(function() obj.SparkleColor = Color3.new(1, 1, 1) end) 
                    end
                end
                return
            end

            if obj:GetAttribute("CurrentTexture") == texturaID then return end
            obj:SetAttribute("CurrentTexture", texturaID)
            
            local classe = obj.ClassName
            if classe == "ParticleEmitter" then
                local sucesso, texturaAtual = pcall(function() return obj.Texture end)
                if sucesso and texturaAtual and string.find(string.lower(texturaAtual), "sparkles_main") then
                    if not originalTextures[obj] then
                        originalTextures[obj] = obj.Texture
                    end
                    obj.Texture = texturaID
                end
            elseif classe == "Sparkles" then
                if not OriginalSparkleColors[obj] then
                    OriginalSparkleColors[obj] = obj.SparkleColor
                end
                pcall(function() obj.SparkleColor = Color3.new(0, 0, 0) end)
                
                local oldClone = obj.Parent:FindFirstChild("CustomSparkleClone_" .. obj.Name)
                if oldClone then oldClone:Destroy() end
                
                local clone = Instance.new("ParticleEmitter")
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
                clone.Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0), 
                    NumberSequenceKeypoint.new(0.5, 1), 
                    NumberSequenceKeypoint.new(1, 0)
                })
                clone.Parent = obj.Parent
                clone.Enabled = obj.Enabled
                
                local conexao
                conexao = obj:GetPropertyChangedSignal("Enabled"):Connect(function() 
                    if clone then clone.Enabled = obj.Enabled end
                end)
                
                local destConn
                destConn = obj.Destroying:Connect(function()
                    if conexao then conexao:Disconnect() end
                    if destConn then destConn:Disconnect() end
                    if clone then clone:Destroy() end
                end)
                
                table.insert(currentDoubleJumpConns, conexao)
                table.insert(currentDoubleJumpConns, destConn)
            end
        end

        local pastasSeguras = {workspace, game:GetService("ReplicatedStorage"), game:GetService("Players")}
        for _, pasta in ipairs(pastasSeguras) do
            for _, obj in ipairs(pasta:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Sparkles") then
                    task.spawn(aplicarTextura, obj)
                end
            end
            if texturaID ~= "Default" then
                table.insert(currentDoubleJumpConns, pasta.DescendantAdded:Connect(function(obj)
                    if obj:IsA("ParticleEmitter") or obj:IsA("Sparkles") then
                        task.defer(function() aplicarTextura(obj) end)
                    end
                end))
            end
        end
    end

    local CustomInputContainer = Instance.new("Frame")
    CustomInputContainer.Size = UDim2.new(1, 0, 0, 40)
    CustomInputContainer.BackgroundColor3 = Theme.ItemColor
    CustomInputContainer.BackgroundTransparency = 0.2
    CustomInputContainer.Parent = TexturesPage
    Instance.new("UICorner", CustomInputContainer).CornerRadius = UDim.new(0, 6)
    local CIStr = Instance.new("UIStroke")
    CIStr.Color = Theme.ItemStroke
    CIStr.Thickness = 1
    CIStr.Transparency = 0.7
    CIStr.Parent = CustomInputContainer
    ApplyGradient(CustomInputContainer, Color3.fromRGB(45,45,45), Theme.ItemColor, 90)

    local CustomInputBox = Instance.new("TextBox")
    CustomInputBox.Size = UDim2.new(1, -90, 1, 0)
    CustomInputBox.Position = UDim2.new(0, 10, 0, 0)
    CustomInputBox.BackgroundTransparency = 1
    CustomInputBox.Text = ""
    CustomInputBox.PlaceholderText = "Enter Texture ID..."
    CustomInputBox.TextColor3 = Theme.Text
    CustomInputBox.PlaceholderColor3 = Theme.TextDark
    CustomInputBox.Font = Theme.Font
    CustomInputBox.TextSize = 12
    CustomInputBox.TextXAlignment = Enum.TextXAlignment.Left
    CustomInputBox.ClearTextOnFocus = false
    CustomInputBox.Parent = CustomInputContainer

    local ApplyBtn = Instance.new("TextButton")
    ApplyBtn.Size = UDim2.new(0, 60, 0, 24)
    ApplyBtn.Position = UDim2.new(1, -70, 0.5, -12)
    ApplyBtn.BackgroundColor3 = Theme.Accent
    ApplyBtn.Text = "Apply"
    ApplyBtn.Font = Enum.Font.GothamBold
    ApplyBtn.TextSize = 11
    ApplyBtn.TextColor3 = Color3.new(0,0,0)
    ApplyBtn.Parent = CustomInputContainer
    Instance.new("UICorner", ApplyBtn).CornerRadius = UDim.new(0, 4)

    ApplyBtn.MouseButton1Click:Connect(function()
        local val = CustomInputBox.Text
        if val and val ~= "" then
            local formatted = formatID(val)
            if formatted then
                EnableDoubleJumpEffect(formatted)
            end
        end
    end)

    local GridWrapper = Instance.new("Frame")
    GridWrapper.Size = UDim2.new(1, 0, 0, 0)
    GridWrapper.AutomaticSize = Enum.AutomaticSize.Y
    GridWrapper.BackgroundTransparency = 1
    GridWrapper.Parent = TexturesPage
    
    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize = UDim2.new(0, 48, 0, 48)
    Grid.CellPadding = UDim2.new(0, 8, 0, 8)
    Grid.SortOrder = Enum.SortOrder.LayoutOrder
    Grid.Parent = GridWrapper
    
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = UDim.new(0, 5)
    UIPadding.PaddingBottom = UDim.new(0, 5)
    UIPadding.PaddingLeft = UDim.new(0, 5)
    UIPadding.PaddingRight = UDim.new(0, 5)
    UIPadding.Parent = GridWrapper

    local defaultBtn = Instance.new("TextButton")
    defaultBtn.Text = "Default"
    defaultBtn.Font = Enum.Font.GothamBold
    defaultBtn.TextSize = 11
    defaultBtn.TextColor3 = Theme.Text
    defaultBtn.BackgroundColor3 = Theme.ItemColor
    defaultBtn.BackgroundTransparency = 0.3
    defaultBtn.Parent = GridWrapper
    Instance.new("UICorner", defaultBtn).CornerRadius = UDim.new(0, 8)
    local dStr = Instance.new("UIStroke")
    dStr.Color = Theme.ItemStroke
    dStr.Thickness = 1
    dStr.Transparency = 0.4
    dStr.Parent = defaultBtn
    
    defaultBtn.MouseEnter:Connect(function()
        TweenService:Create(dStr, TweenInfo.new(0.3), {Color = Theme.Accent, Transparency = 0}):Play()
        TweenService:Create(defaultBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45,45,45)}):Play()
    end)
    defaultBtn.MouseLeave:Connect(function()
        TweenService:Create(dStr, TweenInfo.new(0.3), {Color = Theme.ItemStroke, Transparency = 0.4}):Play()
        TweenService:Create(defaultBtn, TweenInfo.new(0.3), {BackgroundColor3 = Theme.ItemColor}):Play()
    end)
    
    defaultBtn.MouseButton1Click:Connect(function()
        EnableDoubleJumpEffect("Default")
    end)
    
    local effectIDs = {
        "81110491136307", "117864251880006", "120181545812734", "74056211768119", 
        "116419901031627", "92247449256845", "113423466689563", "90279999098357", 
        "94123299347751", "105065705443269", "122902019815288", "138617722401997", 
        "75192344666220", "139646605021296", "133105930199997", "96482830256985", 
        "107964624563909", "122185636007520", "130200330618832", "84159990264787",
        "87265760472097", "125925535971201", "99196076742919", "80555494674270", 
        "77364460442867", "84014330993791", "80081088131892", "70463296258416"
    }
    
    for _, id in ipairs(effectIDs) do
        local btn = Instance.new("ImageButton")
        btn.BackgroundColor3 = Theme.ItemColor
        btn.BackgroundTransparency = 0.3
        btn.Image = "rbxassetid://" .. id
        btn.ScaleType = Enum.ScaleType.Crop 
        btn.Parent = GridWrapper
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        local str = Instance.new("UIStroke")
        str.Color = Theme.ItemStroke
        str.Thickness = 1
        str.Transparency = 0.4
        str.Parent = btn
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(str, TweenInfo.new(0.3), {Color = Theme.Accent, Transparency = 0}):Play()
            TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45,45,45)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(str, TweenInfo.new(0.3), {Color = Theme.ItemStroke, Transparency = 0.4}):Play()
            TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Theme.ItemColor}):Play()
        end)
        
        btn.MouseButton1Click:Connect(function()
            EnableDoubleJumpEffect("rbxassetid://" .. id)
        end)
    end
    
    Library:CreateSection(TexturesPage, "Mobile Button Jump")

    local mobileJumpConns = {}
    local function EnableMobileButtonJump(texturaID)
        if not isMobile then
            SendNotification("This option is only for mobile players.", 3)
            return
        end
        
        for _, c in ipairs(mobileJumpConns) do c:Disconnect() end
        table.clear(mobileJumpConns)

        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local function applyCustomButton(touchGui)
            local touchControlFrame = touchGui:WaitForChild("TouchControlFrame", 5)
            if not touchControlFrame then return end
            
            local jumpButton = touchControlFrame:WaitForChild("JumpButton", 5)
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
            
            local customIcon = Instance.new("ImageLabel")
            customIcon.Name = "CustomJumpIcon"
            customIcon.Size = UDim2.new(1, 0, 1, 0)
            customIcon.Position = UDim2.new(0, 0, 0, 0)
            customIcon.BackgroundTransparency = 1
            customIcon.Image = texturaID
            customIcon.ZIndex = jumpButton.ZIndex + 50
            customIcon.Parent = jumpButton
            
            local c1 = jumpButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    customIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
                end
            end)
            
            local c2 = jumpButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    customIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                end
            end)

            table.insert(mobileJumpConns, c1)
            table.insert(mobileJumpConns, c2)
        end

        if playerGui:FindFirstChild("TouchGui") then
            task.spawn(applyCustomButton, playerGui.TouchGui)
        end

        if texturaID ~= "Default" then
            table.insert(mobileJumpConns, playerGui.ChildAdded:Connect(function(child)
                if child.Name == "TouchGui" then
                    task.spawn(applyCustomButton, child)
                end
            end))
        end
    end

    local MJumpInputContainer = Instance.new("Frame")
    MJumpInputContainer.Size = UDim2.new(1, 0, 0, 40)
    MJumpInputContainer.BackgroundColor3 = Theme.ItemColor
    MJumpInputContainer.BackgroundTransparency = 0.2
    MJumpInputContainer.Parent = TexturesPage
    Instance.new("UICorner", MJumpInputContainer).CornerRadius = UDim.new(0, 6)
    local MJumpStr = Instance.new("UIStroke")
    MJumpStr.Color = Theme.ItemStroke
    MJumpStr.Thickness = 1
    MJumpStr.Transparency = 0.7
    MJumpStr.Parent = MJumpInputContainer
    ApplyGradient(MJumpInputContainer, Color3.fromRGB(45,45,45), Theme.ItemColor, 90)

    local MJumpTextBox = Instance.new("TextBox")
    MJumpTextBox.Size = UDim2.new(1, -90, 1, 0)
    MJumpTextBox.Position = UDim2.new(0, 10, 0, 0)
    MJumpTextBox.BackgroundTransparency = 1
    MJumpTextBox.Text = ""
    MJumpTextBox.PlaceholderText = "Enter Texture ID..."
    MJumpTextBox.TextColor3 = Theme.Text
    MJumpTextBox.PlaceholderColor3 = Theme.TextDark
    MJumpTextBox.Font = Theme.Font
    MJumpTextBox.TextSize = 12
    MJumpTextBox.TextXAlignment = Enum.TextXAlignment.Left
    MJumpTextBox.ClearTextOnFocus = false
    MJumpTextBox.Parent = MJumpInputContainer

    local MJumpApplyBtn = Instance.new("TextButton")
    MJumpApplyBtn.Size = UDim2.new(0, 60, 0, 24)
    MJumpApplyBtn.Position = UDim2.new(1, -70, 0.5, -12)
    MJumpApplyBtn.BackgroundColor3 = Theme.Accent
    MJumpApplyBtn.Text = "Apply"
    MJumpApplyBtn.Font = Enum.Font.GothamBold
    MJumpApplyBtn.TextSize = 11
    MJumpApplyBtn.TextColor3 = Color3.new(0,0,0)
    MJumpApplyBtn.Parent = MJumpInputContainer
    Instance.new("UICorner", MJumpApplyBtn).CornerRadius = UDim.new(0, 4)

    MJumpApplyBtn.MouseButton1Click:Connect(function()
        local val = MJumpTextBox.Text
        if val and val ~= "" then
            local formatted = formatID(val)
            if formatted then
                EnableMobileButtonJump(formatted)
            end
        end
    end)

    local MJumpGridWrapper = Instance.new("Frame")
    MJumpGridWrapper.Size = UDim2.new(1, 0, 0, 0)
    MJumpGridWrapper.AutomaticSize = Enum.AutomaticSize.Y
    MJumpGridWrapper.BackgroundTransparency = 1
    MJumpGridWrapper.Parent = TexturesPage
    
    local MJumpGrid = Instance.new("UIGridLayout")
    MJumpGrid.CellSize = UDim2.new(0, 48, 0, 48)
    MJumpGrid.CellPadding = UDim2.new(0, 8, 0, 8)
    MJumpGrid.SortOrder = Enum.SortOrder.LayoutOrder
    MJumpGrid.Parent = MJumpGridWrapper
    
    local MJumpPadding = Instance.new("UIPadding")
    MJumpPadding.PaddingTop = UDim.new(0, 5)
    MJumpPadding.PaddingBottom = UDim.new(0, 5)
    MJumpPadding.PaddingLeft = UDim.new(0, 5)
    MJumpPadding.PaddingRight = UDim.new(0, 5)
    MJumpPadding.Parent = MJumpGridWrapper

    local mDefaultBtn = Instance.new("TextButton")
    mDefaultBtn.Text = "Default"
    mDefaultBtn.Font = Enum.Font.GothamBold
    mDefaultBtn.TextSize = 11
    mDefaultBtn.TextColor3 = Theme.Text
    mDefaultBtn.BackgroundColor3 = Theme.ItemColor
    mDefaultBtn.BackgroundTransparency = 0.3
    mDefaultBtn.Parent = MJumpGridWrapper
    Instance.new("UICorner", mDefaultBtn).CornerRadius = UDim.new(0, 8)
    local mDStr = Instance.new("UIStroke")
    mDStr.Color = Theme.ItemStroke
    mDStr.Thickness = 1
    mDStr.Transparency = 0.4
    mDStr.Parent = mDefaultBtn
    
    mDefaultBtn.MouseEnter:Connect(function()
        TweenService:Create(mDStr, TweenInfo.new(0.3), {Color = Theme.Accent, Transparency = 0}):Play()
        TweenService:Create(mDefaultBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45,45,45)}):Play()
    end)
    mDefaultBtn.MouseLeave:Connect(function()
        TweenService:Create(mDStr, TweenInfo.new(0.3), {Color = Theme.ItemStroke, Transparency = 0.4}):Play()
        TweenService:Create(mDefaultBtn, TweenInfo.new(0.3), {BackgroundColor3 = Theme.ItemColor}):Play()
    end)
    
    mDefaultBtn.MouseButton1Click:Connect(function()
        EnableMobileButtonJump("Default")
    end)

    local mJumpIDs = {
        "126321670529682", "77430663366893", "115979689020396", "101678026501268", 
        "100604012502918", "107988778180975", "106355869384286", "119823685069603"
    }

    for _, id in ipairs(mJumpIDs) do
        local btn = Instance.new("ImageButton")
        btn.BackgroundColor3 = Theme.ItemColor
        btn.BackgroundTransparency = 0.3
        btn.Image = "rbxassetid://" .. id
        btn.ScaleType = Enum.ScaleType.Crop 
        btn.Parent = MJumpGridWrapper
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        local str = Instance.new("UIStroke")
        str.Color = Theme.ItemStroke
        str.Thickness = 1
        str.Transparency = 0.4
        str.Parent = btn
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(str, TweenInfo.new(0.3), {Color = Theme.Accent, Transparency = 0}):Play()
            TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45,45,45)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(str, TweenInfo.new(0.3), {Color = Theme.ItemStroke, Transparency = 0.4}):Play()
            TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Theme.ItemColor}):Play()
        end)
        
        btn.MouseButton1Click:Connect(function()
            EnableMobileButtonJump("rbxassetid://" .. id)
        end)
    end
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
