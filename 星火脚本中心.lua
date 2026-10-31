local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuoChen1026/RobloxScript/main/Wind%20UI(%E9%87%8D%E6%9E%84%EF%BC%89.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

WindUI:AddTheme({
    Name = "暗黑", -- theme name
    Name = "棉花糖",
    Accent = Color3.fromHex("#18181b"),
    Background = Color3.fromHex("#101010"), -- Accent
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#7a7a7a"),
    Button = Color3.fromHex("#52525b"),
    Icon = Color3.fromHex("#a1a1aa"),
})

local Window = WindUI:CreateWindow({
    Title   = "星火脚本中心",
    Author  = "星火制作",
    Folder  = "XH HUB",
    Icon    = "paint-bucket",
    Theme   = "Dark",
    Acrylic = true,
    Transparent = true,
    Background = "rbxassetid://84152360484913",
    Size    = UDim2.fromOffset(680, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    ToggleKey  = Enum.KeyCode.RightShift,
    Resizable  = true,
    AutoScale  = true,
    NewElements = true,
    BackgroundImageTransparency = 0.65,
    HideSearchBar = false,
    ScrollBarEnabled = false,
    SideBarWidth = 200,
    Topbar = {
        Height      = 44,
        ButtonsType = "Default",
    },
    OpenButton = {
        Title = "星火脚本中心",
        Icon = "zap",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 1,
        Color = ColorSequence.new(
            Color3.fromHex("#000000"),
            Color3.fromHex("#000000")
        ),
    },
    User = {
        Enabled  = true,
        Anonymous = false,
        Callback = function()
            print("user panel clicked")
        end,
    },
})

-- Main Tab
local MainTab = Window:Tab({
    Title = "主要",
    Icon = "house"
})

-- Settings Tab
-- Theme
local ThemeTab = Window:Tab({ Title = "设置", Icon = "settings" })

ThemeTab:Dropdown({
    Title  = "Theme",
    Values = (function()
        local names = {}
        for name in pairs(WindUI:GetThemes()) do
            table.insert(names, name)
        end
        table.sort(names)
        return names
    end)(),
    Value    = WindUI:GetCurrentTheme(),
    Callback = function(selected)
        WindUI:SetTheme(selected)
    end,
})

ThemeTab:Toggle({
    Title = "Acrylic",
    Value = WindUI : GetTransparency(),
    Callback = function()
        local isOn = WindUI.Window.Acrylic
        WindUI:ToggleAcrylic(not isOn)
    end,
})

ThemeTab:Toggle({
    Title = "Transparent",
    Value = WindUI:GetTransparency(),
    Callback = function(state)
        Window:ToggleTransparency(state)
    end
})

local currentKey = Enum.KeyCode.RightShift -- Keybind ToogleUi

ThemeTab:Keybind({
    Title = "Toggle UI Key",
    Value = currentKey,
    Callback = function(v)
        currentKey = (typeof(v) == "EnumItem") and v or Enum.KeyCode[v]
        Window:SetToggleKey(currentKey)
    end,
})

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == currentKey then
        Window:Toggle()
    end
end)

-- Notify
WindUI:Notify({
  Title = "星火脚本中心",
  Content = "欢迎使用星火脚本中心!",
})

WindUI:SetNotificationLower(true)