local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuoChen1026/RobloxScript/main/Wind%20UI(%E9%87%8D%E6%9E%84%EF%BC%89.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

WindUI:AddTheme({
    Name = "暗黑",
    Accent = Color3.fromHex("#18181b"),
    Background = Color3.fromHex("#101010"),
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#7a7a7a"),
    Button = Color3.fromHex("#52525b"),
    Icon = Color3.fromHex("#a1a1aa"),
})

WindUI:AddTheme ({
    Name = "光亮",
    Accent = Color3.fromHex("#efefef"),
    Outline = Color3.fromHex("#ffffff"),
    Text = Color3.fromHex("#000000"),
    Placeholder = Color3.fromHex("#555555"),
    Background = Color3.fromHex("#FFFFFF"),
    Button = Color3.fromHex("#18181b"),
    Icon = Color3.fromHex("#52525b"),
})

WindUI:AddTheme({
    Name = "玫瑰",
    Accent = Color3.fromHex("#be185d"),
    Dialog = Color3.fromHex("#4c0519"),
    Text = Color3.fromHex("#fdf2f8"),
    Placeholder = Color3.fromHex("#d67aa6"),
    Background = Color3.fromHex("#1f0308"),
    Button = Color3.fromHex("#e95f74"),
    Icon = Color3.fromHex("#fb7185"),
    ElementBackground = Color3.fromHex("#381E23"),
    ElementBackgroundTransparency = 0,
})

WindUI:AddTheme({
    Name = "植物",
    Accent = Color3.fromHex("#166534"),
    Dialog = Color3.fromHex("#052e16"),
    Text = Color3.fromHex("#f0fdf4"),
    Placeholder = Color3.fromHex("#4fbf7a"),
    Background = Color3.fromHex("#0a1b0f"),
    Button = Color3.fromHex("#16a34a"),
    Icon = Color3.fromHex("#4ade80"),
    ElementBackground = Color3.fromHex("#28342A"),
    ElementBackgroundTransparency = 0,
})

WindUI:AddTheme({
    Name = "红色",
    Accent = Color3.fromHex("#991b1b"),
    Dialog = Color3.fromHex("#450a0a"),
    Text = Color3.fromHex("#fef2f2"),
    Placeholder = Color3.fromHex("#d95353"),
    Background = Color3.fromHex("#1c0606"),
    Button = Color3.fromHex("#dc2626"),
    Icon = Color3.fromHex("#ef4444"),
    ElementBackground = Color3.fromHex("#322221"),
    ElementBackgroundTransparency = 0,
})

WindUI:AddTheme({
    Name = "靛蓝",
    Accent = Color3.fromHex("#3730a3"),
    Dialog = Color3.fromHex("#1e1b4b"),
    Text = Color3.fromHex("#f1f5f9"),
    Placeholder = Color3.fromHex("#7078d9"),
    Background = Color3.fromHex("#0f0a2e"),
    Button = Color3.fromHex("#4f46e5"),
    Icon = Color3.fromHex("#6366f1"),
    ElementBackground = Color3.fromHex("#282543"),
    ElementBackgroundTransparency = 0,
})

WindUI:AddTheme({
    Name = "天空",
    Accent = Color3.fromHex("#00d4ff"),
    Dialog = Color3.fromHex("#0a4d66"),
    Text = Color3.fromHex("#e6f7ff"),
    Placeholder = Color3.fromHex("#66b3cc"),
    Background = Color3.fromHex("#051a26"),
    Button = Color3.fromHex("#00a8cc"),
    Icon = Color3.fromHex("#2db8d9"),
    Toggle = Color3.fromHex("#00d9d9"),
    Slider = Color3.fromHex("#00d4ff"),
    Checkbox = Color3.fromHex("#00d4ff"),
    PanelBackground = Color3.fromHex("#0d3a47"),
    PanelBackgroundTransparency = 0.8,
    ElementBackground = Color3.fromHex("#172E3B"),
    ElementBackgroundTransparency = 0,
})

WindUI:AddTheme({
    Name = "紫罗兰",
    Accent = Color3.fromHex("#6d28d9"),
    Dialog = Color3.fromHex("#3c1361"),
    Text = Color3.fromHex("#faf5ff"),
    Placeholder = Color3.fromHex("#8f7ee0"),
    Background = Color3.fromHex("#1e0a3e"),
    Button = Color3.fromHex("#7c3aed"),
    Icon = Color3.fromHex("#8b5cf6"),
    ElementBackground = Color3.fromHex("#342650"),
    ElementBackgroundTransparency = 0,
})

WindUI:AddTheme({
    Name = "翡翠",
    Accent = Color3.fromHex("#047857"),
    Dialog = Color3.fromHex("#022c22"),
    Text = Color3.fromHex("#ecfdf5"),
    Placeholder = Color3.fromHex("#3fbf8f"),
    Background = Color3.fromHex("#011411"),
    Button = Color3.fromHex("#059669"),
    Icon = Color3.fromHex("#10b981"),
    ElementBackground = Color3.fromHex("#202E2A"),
    ElementBackgroundTransparency = 0,
})

WindUI:AddTheme({
    Name = "午夜",
    Accent = Color3.fromHex("#1e3a8a"),
    Dialog = Color3.fromHex("#0c1e42"),
    Text = Color3.fromHex("#dbeafe"),
    Placeholder = Color3.fromHex("#2f74d1"),
    Background = Color3.fromHex("#0a0f1e"),
    Button = Color3.fromHex("#2563eb"),
    Primary = Color3.fromHex("#2563eb"),
    Icon = Color3.fromHex("#5591f4"),
    ElementBackground = Color3.fromHex("#242836"),
    ElementBackgroundTransparency = 0,
})

WindUI:AddTheme({
    Name = "猩红",
    Accent = Color3.fromHex("#b91c1c"),
    Dialog = Color3.fromHex("#450a0a"),
    Text = Color3.fromHex("#fef2f2"),
    Placeholder = Color3.fromHex("#6f757b"),
    Background = Color3.fromHex("#0c0404"),
    Button = Color3.fromHex("#991b1b"),
    Icon = Color3.fromHex("#dc2626"),
    ElementBackground = Color3.fromHex("#251F1F"),
    ElementBackgroundTransparency = 0,
})

WindUI:AddTheme({
    Name = "Monokai Pro",
    Accent = Color3.fromHex("#fc9867"),
    Dialog = Color3.fromHex("#1e1e1e"),
    Text = Color3.fromHex("#fcfcfa"),
    Placeholder = Color3.fromHex("#afafaf"),
    Background = Color3.fromHex("#191622"),
    Button = Color3.fromHex("#ab9df2"),
    Icon = Color3.fromHex("#a9dc76"),
    ElementBackground = Color3.fromHex("#323039"),
    ElementBackgroundTransparency = 0,
})

WindUI:AddTheme({
    Name = "棉花糖",
    Accent = Color3.fromHex("#ec4899"),
    Dialog = Color3.fromHex("#2d1b3d"),
    Text = Color3.fromHex("#fdf2f8"),
    Placeholder = Color3.fromHex("#8a5fd3"),
    Background = Color3.fromHex("#1a0b2e"),
    Button = Color3.fromHex("#d946ef"),
    Slider = Color3.fromHex("#d946ef"),
    Icon = Color3.fromHex("#06b6d4"),
    ElementBackground = Color3.fromHex("#312643"),
    ElementBackgroundTransparency = 0,
})

WindUI:AddTheme({
    Name = "Mellowsi",
    Accent = Color3.fromHex("#342A1E"),
    Dialog = Color3.fromHex("#291C13"),
    Text = Color3.fromHex("#F5EBDD"),
    Placeholder = Color3.fromHex("#9C8A73"),
    Background = Color3.fromHex("#1C1002"),
    Button = Color3.fromHex("#342A1E"),
    Icon = Color3.fromHex("#C9B79C"),
    Toggle = Color3.fromHex("#a9873f"),
    Slider = Color3.fromHex("#C9A24D"),
    Checkbox = Color3.fromHex("#C9A24D"),
    ElementBackground = Color3.fromHex("#33291E"),
    ElementBackgroundTransparency = 0,
})

-- ✅移到CreateWindow之前
WindUI:SetNotificationLower(true)

local Window = WindUI:CreateWindow({
    Title   = "XH HUB",
    Author  = "星火制作",
    Folder  = "XH HUB",
    Icon    = "crown",
    Theme   = "暗黑",
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
        Icon = "sparkles",
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
    Radius = 12,
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
    Opened = false,
})

Section:Button({
    Title = "LC-XH",
    Description = "星火制作",
    Tooltip = "二改NEX",
    Disabled = false,
    Callback = function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/LuoChen1026/RobloxScript/main/LC-XH.lua"))()
        end)
        if ok then
            WindUI:Notify({
                Title = "脚本执行成功！",
                Content = "LC‑XH脚本已经成功执行！",
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

local Tab = Window:Tab({
    Title = "PVE类",
    Icon = "swords"
})

local Section = Tab:Section({
    Title = "试炼",
    Icon = "brain",
    Opened = false,
})

Section:Button({
    Title = "试炼-TomTamX",
    Description = "星火汉化",
    Tooltip = "汉化老外的",
    Disabled = false,
    Callback = function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/LuoChen1026/RobloxScript/main/%E8%AF%95%E7%82%BC-TomTamX.lua"))()
        end)
        if ok then
            WindUI:Notify({
                Title = "脚本执行成功！",
                Content = "试炼‑TomTamX脚本已经成功执行！",
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

local Section = Tab:Section({
    Title = "我们的处决",
    Icon = "gem",
    Opened = false,
})

Section:Button({
    Title = "我们的处决-XH",
    Description = "星火制作",
    Tooltip = "二改Zero",
    Disabled = false,
    Callback = function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/LuoChen1026/RobloxScript/main/OE-XH.lua"))()
        end)
        if ok then
            WindUI:Notify({
                Title = "脚本执行成功！",
                Content = "OE-XH脚本已经成功执行！",
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
    Title  = "主题",
    Values = {"暗黑","光亮","玫瑰","植物","红色","靛蓝","天空","紫罗兰","翡翠","午夜","猩红","Monokai Pro","棉花糖","Mellowsi"},
    Value = "暗黑",
    Callback = function(selected)
        WindUI:SetTheme(selected)
    end,
})

ThemeTab:Toggle({
    Title = "毛玻璃",
    Value = true,
    Callback = function(state)
        WindUI:ToggleAcrylic(state)
    end,
})
ThemeTab:Toggle({
    Title = "透明",
    Value = true,
    Callback = function(state)
        Window:ToggleTransparency(state)
    end
})

--全部控件完成后加载配置
myConfig:Load()

WindUI:Notify({
  Title = "XH HUB",
  Content = "欢迎使用XH HUB!",
})

WindUI:Popup({
    Title = "警告，使用前必读！！！",
    Icon = "info",
    Content = "在本游戏中使用第三方脚本违反服务条款，且风险极高。可能导致的后果包括：永久封禁账号，HWID封禁，账号被反作弊系统标记，丢失全部进度、物品以及购买的内容，脚本仅为学习/教育目的提供。因使用本工具造成的任何封禁、账号损失或其他损害，我们均不承担责任，关闭将无法让您使用脚本，继续将使您能够使用脚本同时代表您已知晓风险并愿意自行承担相应后果，强烈建议使用小号进行测试",
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