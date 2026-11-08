-- ========== 完整翻译表（已剔除功能性参数） ==========
local Translations = {
    -- 基础信息
    ["NEX-LC Hub"]    = "XH-LC HUB",
    ["By HL_linfeng"] = "星火制作",
    ["By linfeng"]    = "星火制作",
    ["Search"]        = "搜索",
    ["Toggle"]        = "开关",
    ["NEX"]           = "XH",
    ["1104985377"]    = "582669853",

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
    
    -- ⚠️ 注意：不要在这里添加主题名称（如 Nord, Default）和字体名称！
    -- 添加后会导致下拉菜单点击无效！
}

-- ========== 核心引擎 ==========
local keys = {}
for k in pairs(Translations) do keys[#keys+1] = k end
table.sort(keys, function(a, b) return #a > #b end)

local function esc(s)  return (s:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")) end
local function escR(s) return (s:gsub("%%", "%%%%")) end
local pats = {}
for _, k in ipairs(keys) do
    pats[#pats+1] = { esc(k), escR(Translations[k]) }
end

local cache = {}
local cacheSize = 0
local MAX_CACHE = 3000

local function translateText(s)
    if type(s) ~= "string" or s == "" then return s end
    local c = cache[s]
    if c ~= nil then return c end

    local r = Translations[s]
    if r then
        if cacheSize < MAX_CACHE then cache[s] = r; cacheSize = cacheSize + 1 end
        return r
    end

    local orig = s
    for i = 1, #pats do
        if s:find(pats[i][1], 1, true) then
            s = s:gsub(pats[i][1], pats[i][2])
        end
    end
    if cacheSize < MAX_CACHE then cache[orig] = s; cacheSize = cacheSize + 1 end
    return s
end

-- ========== 核心修复：精准拦截，防止破坏逻辑 ==========
do
    local ok, err = pcall(function()
        local mt = getrawmetatable(game)
        local oldNI = mt.__newindex
        setreadonly(mt, false)
        mt.__newindex = newcclosure(function(self, key, value)
            -- 只有值为字符串，且属于特定 UI 类型时才处理
            if type(value) == "string" then
                if self:IsA("TextLabel") or self:IsA("TextButton") then
                    if key == "Text" then
                        local n = translateText(value)
                        if n ~= value then value = n end
                    end
                elseif self:IsA("TextBox") then
                    -- 重点：绝不拦截 TextBox 的 "Text"（防止玩家输入或底层参数被改），只改提示词
                    if key == "PlaceholderText" then
                        local n = translateText(value)
                        if n ~= value then value = n end
                    end
                end
            end
            return oldNI(self, key, value)
        end)
        setreadonly(mt, true)
    end)
    if not ok then warn("[汉化] hook 失败:", err) end
end

-- 初始扫描（同样保护输入框内容）
local function processOne(d)
    if d:IsA("TextLabel") or d:IsA("TextButton") then
        local t = d.Text
        if type(t) == "string" and t ~= "" then
            local n = translateText(t)
            if n ~= t then d.Text = n end
        end
    elseif d:IsA("TextBox") then
        -- 初始扫描也不碰 TextBox.Text，防止搜索等逻辑失效
        local p = d.PlaceholderText
        if type(p) == "string" and p ~= "" then
            local n = translateText(p)
            if n ~= p then d.PlaceholderText = n end
        end
    end
end

local function sweepOnce(root)
    if not root then return end
    local list = root:GetDescendants()
    for i = 1, #list do
        pcall(processOne, list[i])
    end
end

pcall(sweepOnce, game:GetService("CoreGui"))
local player = game:GetService("Players").LocalPlayer
if player and player:FindFirstChild("PlayerGui") then
    pcall(sweepOnce, player.PlayerGui)
end

-- 加载主脚本
task.wait(1)
local s, e = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/LuoChen1026/RobloxScript/main/LC-NEX.lua"))()
end)
if not s then warn("[汉化] 加载失败:", e) end