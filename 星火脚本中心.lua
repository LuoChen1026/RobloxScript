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
    Name = "安柏",
    Accent = aa:Gradient({
        ["0"]={Color=Color3.fromHex("#b45309"),Transparency=0},
        ["100"]={Color=Color3.fromHex("#d97706"),Transparency=0},
    },{Rotation=45}),
    Dialog = aa:Gradient({
        ["0"]={Color=Color3.fromHex("#451a03"),Transparency=0},
        ["100"]={Color=Color3.fromHex("#6b2e05"),Transparency=0},
    },{Rotation=90}),
    Text = aa:Gradient({
        ["0"]={Color=Color3.fromHex("#fffbeb"),Transparency=0},
        ["100"]={Color=Color3.fromHex("#fff7ed"),Transparency=0},
    },{Rotation=45}),
    Placeholder = aa:Gradient({
        ["0"]={Color=Color3.fromHex("#d1a326"),Transparency=0},
        ["100"]={Color=Color3.fromHex("#fbbf24"),Transparency=0},
    },{Rotation=45}),
    Background = aa:Gradient({
        ["0"]={Color=Color3.fromHex("#1c1003"),Transparency=0},
        ["100"]={Color=Color3.fromHex("#3f210d"),Transparency=0},
    },{Rotation=90}),
    Button = aa:Gradient({
        ["0"]={Color=Color3.fromHex("#d97706"),Transparency=0},
        ["100"]={Color=Color3.fromHex("#f59e0b"),Transparency=0},
    },{Rotation=45}),
    Icon = Color3.fromHex("#f59e0b"),
    Toggle = aa:Gradient({
        ["0"]={Color=Color3.fromHex("#d97706"),Transparency=0},
        ["100"]={Color=Color3.fromHex("#f59e0b"),Transparency=0},
    },{Rotation=45}),
    Slider = Color3.fromHex("#d97706"),
    Checkbox = aa:Gradient({
        ["0"]={Color=Color3.fromHex("#d97706"),Transparency=0},
        ["100"]={Color=Color3.fromHex("#fbbf24"),Transparency=0},
    },{Rotation=45}),
    PanelBackground = Color3.fromHex("#FFFFFF"),
    PanelBackgroundTransparency = 0.95,
    ElementBackground = Color3.fromHex("#3A2E22"),
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

WindUI:AddTheme({
    Name = "彩虹",
    Accent = aa:Gradient({
        ["0"]={Color=Color3.fromHex("#00ff41"),Transparency=0},
        ["33"]={Color=Color3.fromHex("#00ffff"),Transparency=0},
        ["66"]={Color=Color3.fromHex("#0080ff"),Transparency=0},
        ["100"]={Color=Color3.fromHex("#8000ff"),Transparency=0},
    },{Rotation=45}),
    Dialog = aa:Gradient({
        ["0"]={Color=Color3.fromHex("#ff0080"),Transparency=0},
        ["25"]={Color=Color3.fromHex("#8000ff"),Transparency=0},
        ["50"]={Color=Color3.fromHex("#0080ff"),Transparency=0},
        ["75"]={Color=Color3.fromHex("#00ff80"),Transparency=0},
        ["100"]={Color=Color3.fromHex("#ff8000"),Transparency=0},
    },{Rotation=135}),
    Text = Color3.fromHex("#ffffff"),
    Placeholder = Color3.fromHex("#00ff80"),
    Background = aa:Gradient({
        ["0"]={Color=Color3.fromHex("#ff0040"),Transparency=0},
        ["20"]={Color=Color3.fromHex("#ff4000"),Transparency=0},
        ["40"]={Color=Color3.fromHex("#ffff00"),Transparency=0},
        ["60"]={Color=Color3.fromHex("#00ff40"),Transparency=0},
        ["80"]={Color=Color3.fromHex("#0040ff"),Transparency=0},
        ["100"]={Color=Color3.fromHex("#4000ff"),Transparency=0},
    },{Rotation=90}),
    Button = aa:Gradient({
        ["0"]={Color=Color3.fromHex("#ff0080"),Transparency=0},
        ["25"]={Color=Color3.fromHex("#ff8000"),Transparency=0},
        ["50"]={Color=Color3.fromHex("#ffff00"),Transparency=0},
        ["75"]={Color=Color3.fromHex("#80ff00"),Transparency=0},
        ["100"]={Color=Color3.fromHex("#00ffff"),Transparency=0},
    },{Rotation=60}),
    Icon = Color3.fromHex("#ffffff"),
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
    Visible = false, --主窗口初始隐藏
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
        Enabled = false, -- ✅悬浮打开按钮初始关闭，询问阶段不显示
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
    Values = {"暗黑","光亮","玫瑰","植物","红色","靛蓝","天空","紫罗兰","安柏","翡翠","午夜","猩红","Monokai Pro","棉花糖","Mellowsi","彩虹"},
    Value = "Dark",
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
    Title = "警告！！！",
    Icon = "info",
    Content = "使用此脚本即表示您已知道并愿意自行承担相应的风险",
    Buttons = {
        {
            Title = "关闭",
            Callback = function()
                Window:Destroy() --销毁全部UI，直接退出
            end,
            Variant = "Tertiary",
        },
        {
            Title = "继续",
            Icon = "arrow-right",
            Callback = function()
                -- 点击继续后才显示主窗口 和 悬浮按钮
                Window:SetVisible(true)
                Window.OpenButton.Enabled = true --启用悬浮小圆按钮

                WindUI:Notify({
                    Title = "XH HUB",
                    Content = "欢迎使用XH HUB!",
                })
            end,
            Variant = "Primary",
        }
    }
})