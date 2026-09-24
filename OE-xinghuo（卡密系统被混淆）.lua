local Arqel = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuoChen1026/RobloxScript/main/%E5%8D%A1%E5%AF%86%E7%B3%BB%E7%BB%9F%E6%BA%90%E7%A0%81%E9%87%8D%E5%BB%BA%EF%BC%88%E6%B7%B7%E6%B7%86%E7%89%88%EF%BC%89.lua"))()
local KEYS = {
    ["XHNB"] = "basic",
    ["XHNB666"] = "premium"
}
Arqel.Appearance = {
    Title = "星火",
    Subtitle = "输入您的卡密以继续使用",
    Icon = "rbxassetid://95721401302279",
    IconSize = UDim2.new(0, 30, 0, 30)
}
Arqel.Links = {
    GetKey = "",
    Discord = ""
}
Arqel.Storage = {
    FileName = "Xinghuo_key",
    Remember = false,
    AutoLoad = false
}
Arqel.Options = {
    Keyless = nil,
    KeylessUI = false,
    Blur = true,
    Draggable = true,
    NoGetKey = false
}
Arqel.Theme = {
    Accent = Color3.fromRGB(139, 0, 0),
    AccentHover = Color3.fromRGB(170, 20, 20),
    Background = Color3.fromRGB(15, 15, 15),
    Header = Color3.fromRGB(20, 20, 20),
    Input = Color3.fromRGB(25, 25, 25),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(120, 120, 120),
    Success = Color3.fromRGB(50, 205, 110),
    Error = Color3.fromRGB(245, 70, 90),
    Warning = Color3.fromRGB(255, 180, 50),
    StatusIdle = Color3.fromRGB(180, 80, 80),
    Discord = Color3.fromRGB(88, 101, 242),
    DiscordHover = Color3.fromRGB(114, 137, 218),
    Divider = Color3.fromRGB(45, 45, 70),
    Pending = Color3.fromRGB(60, 60, 60)
}
Arqel.Shop = {
    Enabled = false,
    Icon = "",
    Title = "获得高级访问权限",
    Subtitle = "即时购买 • 全天候支持",
    ButtonText = "购买",
    Link = ""
}
Arqel.Changelog = {
    {Version = "v1.2.0", Date = "2025年1月20日", Changes = {"增加新功能", "修复已知问题"}},
    {Version = "v1.1.0", Date = "2025年1月15日", Changes = {"改进UI"}},
    {Version = "v1.0.0", Date = "2025年1月10日", Changes = {"首次发布"}}
}
Arqel.Callbacks.OnVerify = function(key)
    local tier = KEYS[key]
    if tier then
        getgenv().USER_TIER = tier
        return true
    end
    return false
end
Arqel.Callbacks.OnSuccess = function()
    Arqel:Notify("成功", "验证通过!", 2, "success")
    if getgenv().USER_TIER == "premium" then
        loadstring(game:HttpGet("https://rawscripts.net/raw/Our-Execution-OE-137018"))()
    else
        loadstring(game:HttpGet("https://raw.githubusercontent.com/LuoChen1026/RobloxScript/main/%E6%88%91%E4%BB%AC%E7%9A%84%E5%A4%84%E5%86%B3%E5%9F%BA%E7%A1%80%E7%89%88.lua"))()
    end
end
Arqel.Callbacks.OnFail = function(errorMsg)
    Arqel:Notify("错误", errorMsg, 4, "error")
    print("验证失败:", errorMsg)
end
Arqel.Callbacks.OnClose = function()
    Arqel:Notify("提示", "你关闭了卡密系统", 3, "info")
    print("你关闭了卡密系统")
end
Arqel:Launch()
