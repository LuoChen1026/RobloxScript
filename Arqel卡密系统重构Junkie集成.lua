-- ArqelUI 完整组合 | 芙宁娜（Furina）水之神官主题
local Arqel = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuoChen1026/RobloxScript/main/Arqel%E5%8D%A1%E5%AF%86%E7%B3%BB%E7%BB%9F%E9%87%8D%E6%9E%84.lua"))()
-- 外观
Arqel.Appearance = {
    Title = "XH HUB",
    Subtitle = "输入你的卡密以继续",
    Icon = "rbxassetid://88589651965141",
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
-- ========== 芙宁娜·水神主题【已重调】 ==========
-- 配色来源：芙宁娜礼服：深海宝蓝、冰白、浅金点缀，水元素亮蓝高亮
Arqel.Theme = {
    Accent = Color3.fromRGB(44, 124, 212),        -- 主高亮：芙宁娜礼服宝蓝
    AccentHover = Color3.fromRGB(86, 168, 245),   -- 悬浮：清亮水蓝色
    Background = Color3.fromRGB(12, 22, 42),      -- 背景：深海暗蓝
    Header = Color3.fromRGB(22, 44, 80),          -- 标题栏：深蓝礼服底色
    Input = Color3.fromRGB(28, 52, 92),           -- 输入框：偏深水蓝
    Text = Color3.fromRGB(248, 252, 255),         -- 主文字：冰白
    TextDim = Color3.fromRGB(180, 210, 240),      -- 次要文字：浅雾蓝白
    Success = Color3.fromRGB(92, 210, 174),       -- 成功：保留清新青
    Error = Color3.fromRGB(242, 82, 106),         -- 错误：玫红
    Warning = Color3.fromRGB(234, 202, 132),       -- 警告：芙宁娜礼服浅金色
    StatusIdle = Color3.fromRGB(72, 146, 226),     -- 等待状态：水蓝色
    Discord = Color3.fromRGB(88, 101, 242),
    DiscordHover = Color3.fromRGB(114, 137, 218),
    Divider = Color3.fromRGB(70, 130, 196),       -- 分割线：带淡金感的水蓝
    Pending = Color3.fromRGB(40, 80, 140)         -- 加载中：暗水蓝
}
-- 商店面板
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
    {Version = "v1.0.0", Date = "2026年11月5日", Changes = {"添加卡密系统", "优化UI","适配芙宁娜水神主题"}},
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