local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuoChen1026/RobloxScript/main/Wind%20UI(%E9%87%8D%E6%9E%84%EF%BC%89.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

WindUI:AddTheme({
    Name = "Dark",
    Accent = Color3.fromHex("#18181b"),
    Background = Color3.fromHex("#101010"),
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#7a7a7a"),
    Button = Color3.fromHex("#52525b"),
    Icon = Color3.fromHex("#a1a1aa"),
})

-- ✅移到CreateWindow之前
WindUI:SetNotificationLower(true)

local Window = WindUI:CreateWindow({
    Title   = "XH脚本中心",
    Author  = "星火制作",
    Folder  = "XHHUB",
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
        Title = "XH HUB",
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

Window:Tag({
    Title = "V1.0",
    Icon = "github",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 8,
})

local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("XH HUB")

-- Main Tab
local Tab = Window:Tab({
    Title = "PVP类",
    Icon = "target"
})

local Section = Tab:Section({
    Title = "莱克星顿与康科德L&C",
    Icon = "target",
    Opened = true,
})

Section:Button({
    Title = "LC-NEX",
    Description = "NEX制作",
    Tooltip = "缝合进来的",
    Disabled = false,
    Callback = function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/LuoChen1026/RobloxScript/main/LC-NEX.lua"))()
        end)
        if ok then
            WindUI:Notify({
                Title = "脚本执行成功！",
                Content = "LC‑NEX脚本已经成功执行！",
                Duration = 3,
                Icon = "check-circle",
            })
        else
            WindUI:Notify({
                Title = "脚本执行失败",
                Content = tostring(err),
                Duration = 4,
                Icon = "x-circle"
            })
        end
    end
})

-- Settings Tab
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
    Value = true, --窗口初始化Acrylic=true
    Callback = function(state)
        WindUI:ToggleAcrylic(state)
    end,
})
ThemeTab:Toggle({
    Title = "Transparent",
    Value = true, --窗口初始化Transparent=true
    Callback = function(state)
        Window:ToggleTransparency(state)
    end
})

ThemeTab:Keybind({
    Title = "Toggle UI Key",
    Value = Enum.KeyCode.RightShift,
    Callback = function(v)
        local currentKey = (typeof(v) == "EnumItem") and v or Enum.KeyCode[v]
        Window:SetToggleKey(currentKey)
    end,
})

-- ✅删掉手动 UserInputService.InputBegan 监听！窗口自带ToggleKey

--全部控件完成后加载配置
myConfig:Load()

WindUI:Notify({
  Title = "XH HUB",
  Content = "欢迎使用XH HUB!",
})

WindUI:Popup({
    Title = "警告！！！",
    Icon = "info",
    Content = "使用此脚本即表示您已知道并愿意自行承担相应的风险",
    Buttons = {
        {
            Title = "关闭",
            Callback = function() end,
            Variant = "Tertiary",
        },
        {
            Title = "继续",
            Icon = "arrow-right",
            Callback = function() end,
            Variant = "Primary",
        }
    }
})