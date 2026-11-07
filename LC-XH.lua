-- ========== 完整翻译表 ==========
local Translations = {
    -- 基础信息
    ["NEX-LC Hub"]    = "LC-XH HUB",
    ["By HL_linfeng"] = "星火制作",
    ["By linfeng"]    = "星火制作",
    ["Search"]        = "搜索",
    ["Toggle"]        = "开关",
    ["1104985377"]    = "582669853",
    ["NEX-Lexington and Concord"]    = "Lexington and Concord-XH",
    -- 颜色与背景设置界面
    ["Themes"]               = "主题设置",
    ["Background color"]     = "背景颜色",
    ["Background image"]     = "背景图片",
    ["Image color"]          = "图片颜色",
    ["Main color"]           = "主要颜色",
    ["Accent color"]         = "强调色",
    ["Outline color"]        = "轮廓颜色",
    ["Font color"]           = "字体颜色",
    ["Font Face"]            = "字体样式",
    ["Contrast check: good"] = "对比度: 良好",
    ["Contrast check: poor"] = "对比度: 较差",

    -- 主题管理按钮
    ["Theme list"]           = "主题列表",
    ["Load theme"]           = "加载主题",
    ["Set as default"]       = "设为默认",
    ["Custom theme name"]    = "自定义主题名称",
    ["Create theme"]         = "创建主题",
    ["Custom themes"]        = "自定义主题",
    ["Overwrite theme"]      = "覆盖主题",
    ["Delete theme"]         = "删除主题",
    ["Refresh list"]         = "刷新列表",
    ["Reset default"]        = "重置默认",
    ["Current default theme: none"] = "当前默认主题: 无",
    ["Theme JSON"]           = "主题 JSON",
    ["Import theme"]         = "导入主题",
    ["Export current theme"] = "导出当前主题",

    -- 字体列表 (Font Face)
    ["BuilderSans"] = "等线体",
    ["Code"]        = "代码体",
    ["Fantasy"]     = "幻想体",
    ["Gotham"]      = "哥谭体",
    ["Jura"]        = "朱拉体",
    ["Roboto"]      = "机器人体",
    ["RobotoMono"]  = "机器人等宽",
    ["SourceSans"]  = "思源黑体",

    -- 主题列表 (Theme List)
    ["Default"]      = "默认",
    ["BBot"]         = "BBot",
    ["Fatality"]     = "致命",
    ["Jester"]       = "小丑",
    ["Mint"]         = "薄荷",
    ["Tokyo Night"]  = "东京之夜",
    ["Ubuntu"]       = "Ubuntu",
    ["Quartz"]       = "石英",
    ["Nord"]         = "北欧风",
    ["Dracula"]      = "德古拉",
    ["Monokai"]      = "Monokai",
    ["Gruvbox"]      = "Gruvbox",
    ["Solarized"]    = "日光",
    ["Catppuccin"]   = "卡布奇诺",
    ["One Dark"]     = "暗黑",
    ["Cyberpunk"]    = "赛博朋克",
    ["Oceanic Next"] = "海洋",
    ["Material"]     = "材质",
}

-- ========== 核心引擎 ==========
local keys = {}
for k in pairs(Translations) do keys[#keys+1] = k end
table.sort(keys, function(a, b) return #a > #b end)

local function esc(s)  return (s:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")) end
local function escR(s) return (s:gsub("%%", "%%%%")) end

local pats = {}
for _, k in ipairs(keys) do
    pats[#pats+1] = { k, esc(k), escR(Translations[k]) }
end

local function norm(s)
    return (s:match("^%s*(.-)%s*$") or s):lower()
end
local normIndex = {}
for k, v in pairs(Translations) do
    normIndex[norm(k)] = v
end

local cache = {}
local cacheSize = 0
local MAX_CACHE = 2000
local MAX_EXACT_LEN = 256
local MAX_CACHE_LEN = 512

local function containsLatin(s)
    return s:find("[A-Za-z]") ~= nil
end
local function containsCJK(s)
    return s:find("[\228-\233]") ~= nil
end
local function containsDigit(s)
    return s:find("%d") ~= nil
end

local function translateText(s)
    if type(s) ~= "string" or s == "" then return s end

    local c = cache[s]
    if c ~= nil then return c end

    -- 1) 短文本精确匹配 (优先处理纯数字如 1104985377)
    if #s <= MAX_EXACT_LEN then
        local r = Translations[s] or normIndex[norm(s)]
        if r then
            if cacheSize < MAX_CACHE then cache[s] = r; cacheSize = cacheSize + 1 end
            return r
        end
    end

    -- 2) 快速排除
    local hasLatin = containsLatin(s)
    local hasDigit = containsDigit(s)
    
    -- 如果既没有英文也没有数字（例如纯中文、纯符号），直接跳过
    if not hasLatin and not hasDigit then return s end

    -- 3) 子串替换 (只要含英文或数字，就继续替换)
    local orig = s
    for i = 1, #pats do
        local raw, pat, rep = pats[i][1], pats[i][2], pats[i][3]
        if s:find(raw, 1, true) then
            s = s:gsub(pat, rep)
        end
    end

    if s ~= orig and #orig <= MAX_CACHE_LEN and cacheSize < MAX_CACHE then
        cache[orig] = s
        cacheSize = cacheSize + 1
    end
    return s
end

-- 辅助函数：判断对象是否使用了图标字体
local function isIconFont(d)
    local isIcon = false
    pcall(function()
        if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
            if d.Font == Enum.Font.MaterialIcons or d.Font == Enum.Font.MaterialIconsRegular then
                isIcon = true
            end
            if not isIcon and d.FontFace and d.FontFace.Font then
                local family = d.FontFace.Font.Family
                if type(family) == "string" and (family:lower():find("material") or family:lower():find("icon")) then
                    isIcon = true
                end
            end
        end
    end)
    return isIcon
end

-- 辅助函数：判断是否应该跳过翻译
local function shouldSkip(d, key, value)
    -- 针对搜索图标的特判：如果是 Text 属性且值为 "Search" 的 Label/Button，大概率是图标
    if key == "Text" and value == "Search" then
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            return true
        end
    end
    -- 如果是纯图标字体对象，跳过
    if isIconFont(d) then
        return true
    end
    return false
end

-- 拦截文本赋值
do
    local ok, err = pcall(function()
        local mt = getrawmetatable(game)
        local oldNI = mt.__newindex
        setreadonly(mt, false)
        mt.__newindex = newcclosure(function(self, key, value)
            if type(value) == "string" and (key == "Text" or key == "PlaceholderText") then
                if not shouldSkip(self, key, value) then
                    local n = translateText(value)
                    if n ~= value then value = n end
                end
            end
            if oldNI then
                return oldNI(self, key, value)
            end
        end)
        setreadonly(mt, true)
    end)
    if not ok then warn("[汉化] hook 失败:", err) end
end

-- 初始扫描
local function isTextObj(d)
    return d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")
end

local function processOne(d)
    if not isTextObj(d) then return end
    
    -- 恢复被误翻的图标 (如果是图标字体却显示成了中文)
    if isIconFont(d) then
        if d.Text == "搜索" then
            pcall(function() d.Text = "Search" end)
        end
        return
    end

    local t = d.Text
    if type(t) == "string" and t ~= "" then
        if not shouldSkip(d, "Text", t) then
            local n = translateText(t)
            if n ~= t then d.Text = n end
        end
    end
    
    if d:IsA("TextBox") then
        local p = d.PlaceholderText
        if type(p) == "string" and p ~= "" then
            if not shouldSkip(d, "PlaceholderText", p) then
                local n = translateText(p)
                if n ~= p then d.PlaceholderText = n end
            end
        end
    end
end

local function sweepAsync(root, batch)
    if not root then return end
    local ok, list = pcall(function() return root:GetDescendants() end)
    if not ok or not list then return end
    local i, n = 1, #list
    task.spawn(function()
        while i <= n do
            local limit = math.min(i + batch - 1, n)
            for j = i, limit do
                pcall(processOne, list[j])
            end
            i = limit + 1
            task.wait()
        end
    end)
end

sweepAsync(game:GetService("CoreGui"), 150)
local player = game:GetService("Players").LocalPlayer
if player and player:FindFirstChild("PlayerGui") then
    sweepAsync(player.PlayerGui, 150)
end

-- 加载主脚本
task.wait(1)
local s, e = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/LuoChen1026/RobloxScript/main/LC-NEX.lua"))()
end)
if not s then warn("[汉化] 加载失败:", e) end