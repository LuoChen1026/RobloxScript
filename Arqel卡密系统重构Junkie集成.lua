-- ArqelUI 完整组合 | 芙宁娜蓝白主题
local Arqel = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuoChen1026/RobloxScript/main/Arqel%E5%8D%A1%E5%AF%86%E7%B3%BB%E7%BB%9F%E9%87%8D%E6%9E%84.lua"))()

-- 外观
Arqel.Appearance = {
    Title = "XH HUB",
    Subtitle = "输入你的卡密以继续",
    Icon = "rbxassetid://95721401302279",
    IconSize = UDim2.new(0, 30, 0, 30)
}

-- 链接
Arqel.Links = {
    GetKey = "https://jnkie.com/flow/94d07f34-3209-4263-9ed5-1436aed225e9",
    Discord = "https://discord.gg/QGdxePx5y"
}

Arqel.Storage = {
    FileName = "XH KEY",
    Remember = false,
    AutoLoad = false
}

-- UI选项
Arqel.Options = {
    Keyless = nil,
    KeylessUI = false,
    Blur = true,
    Draggable = true,
    NoGetKey = false
}

-- 芙宁娜蓝白主题
Arqel.Theme = {
    Accent = Color3.fromRGB(80, 140, 255),
    AccentHover = Color3.fromRGB(110, 170, 255),
    Background = Color3.fromRGB(20, 28, 48),
    Header = Color3.fromRGB(30, 42, 72),
    Input = Color3.fromRGB(35, 48, 80),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(170, 190, 230),
    Success = Color3.fromRGB(80, 220, 170),
    Error = Color3.fromRGB(255, 90, 110),
    Warning = Color3.fromRGB(255, 200, 110),
    StatusIdle = Color3.fromRGB(120, 160, 255),
    Discord = Color3.fromRGB(88, 101, 242),
    DiscordHover = Color3.fromRGB(114, 137, 218),
    Divider = Color3.fromRGB(55, 75, 120),
    Pending = Color3.fromRGB(90, 110, 150)
}

-- 商店面板（关闭）
Arqel.Shop = {
    Enabled = true,
    Icon = "",
    Title = "获取高级版本",
    Subtitle = "即时提供 • 7×24小时全天候支持",
    ButtonText = "购买",
    Link = ""
}

-- 更新日志
Arqel.Changelog = {
    {Version = "v1.0.0", Date = "2026年11月5日", Changes = {"添加卡密系统", "优化UI"}},
}

-- 回调
Arqel.Callbacks = {
    OnVerify = nil,
    OnSuccess = function()
        -- 密钥验证成功后加载你的Hub脚本
        loadstring(game:HttpGet("https://raw.githubusercontent.com/LuoChen1026/RobloxScript/main/%E6%98%9F%E7%81%AB%E8%84%9A%E6%9C%AC%E4%B8%AD%E5%BF%83.luaw"))()
    end,
    OnFail = function(errorMsg)
        print("失败:", errorMsg)
    end,
    OnClose = function()
        print("用户关闭了卡密系统")
    end
}

-- 星火密钥系统启动
Arqel:LaunchJunkie({
    Service = "星火",
    Identifier = "1016287",
    Provider = "尘洛"
})