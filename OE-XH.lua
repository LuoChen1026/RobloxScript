-- ========== 全新翻译表 (X-HUB 适配版) ==========
local Translations = {
    -- 基础 UI & 侧边栏
    ["Zero Hub | Our Execution"] = "XH HUB | 我们的处决",
    ["Updated in 2026-09-10"]    = "更新于 2026-09-10",
    ["Search"]                   = "搜索",
    ["Info"]                     = "信息",
    ["ESP"]                      = "透视",
    ["Main"]                     = "主要功能",
    ["Auto"]                     = "自动化",
    ["Kill Aura"]                = "杀戮光环",
    ["Gun"]                      = "枪械",
    ["Basic"]                    = "基础",
    ["Sapper"]                   = "工兵",
    ["Heal"]                     = "治疗",
    ["Open Gui"]                 = "打开脚本",
    
    -- 信息面板
    ["User"]                     = "用户",
    ["Kills:"]                   = "击杀:",
    ["Upira:"]                   = "乌皮拉:",
    
    -- 功能
    ["Zombies ESP"]              = "僵尸透视",
    ["Runner ESP"]               = "跑者透视",
    ["Expand"]                   = "命中箱扩大",
    ["Head"]                     = "头部",
    
    -- 主题列表
    ["Rose"]                     = "玫瑰",
    ["Rainbow"]                  = "彩虹",
    ["Plant"]                    = "植物",
    ["Mellowsi"]                 = "柔和",
    ["Midnight"]                 = "午夜",
    ["Violet"]                   = "紫罗兰",
    ["CottonCandy"]              = "棉花糖",
    ["Dark"]                     = "暗黑",
    ["MonokaiPro"]               = "MonokaiPro",
    ["Indigo"]                   = "靛蓝",
    ["Sky"]                      = "天空",
    ["Crimson"]                  = "深红",
    ["Amber"]                    = "琥珀",
    ["Emerald"]                  = "翡翠",
    ["Red"]                      = "红色",
    ["Light"]                    = "明亮",
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

local function containsLatin(s) return s:find("[A-Za-z]") ~= nil end
local function containsDigit(s) return s:find("%d") ~= nil end

local function translateText(s)
    if type(s) ~= "string" or s == "" then return s end
    local c = cache[s]
    if c ~= nil then return c end

    if #s <= MAX_EXACT_LEN then
        local r = Translations[s] or normIndex[norm(s)]
        if r then
            if cacheSize < MAX_CACHE then cache[s] = r; cacheSize = cacheSize + 1 end
            return r
        end
    end

    local hasLatin = containsLatin(s)
    local hasDigit = containsDigit(s)
    if not hasLatin and not hasDigit then return s end

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

local function shouldSkip(d, key, value)
    -- 修复：仅当 Text 为 Search 且是 Label/Button 时才跳过（因为通常是图标），TextBox 的 Placeholder 依然可以翻译
    if key == "Text" and value == "Search" then
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            return true
        end
    end
    if isIconFont(d) then return true end
    return false
end

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

local function isTextObj(d)
    return d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")
end

local function processOne(d)
    if not isTextObj(d) then return end
    if isIconFont(d) then
        if d.Text == "搜索" then pcall(function() d.Text = "Search" end) end
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
            for j = i, limit do pcall(processOne, list[j]) end
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
    -- 这里是你提供的链接
    local url = "https://raw.githubusercontent.com/yuanshenqdon/Script/refs/heads/main/%E6%9C%80%E5%90%8E%E7%9A%84%E5%A4%84%E5%86%B3"
    local success, code = pcall(game.HttpGet, game, url)
    if success and code then
        local func, loadErr = loadstring(code)
        if func then
            func()
        else
            warn("[执行] 脚本代码解析失败:", loadErr)
        end
    else
        warn("[执行] 下载主脚本失败，请检查链接是否有效！")
    end
end)
if not s then warn("[执行] 运行异常:", e) end