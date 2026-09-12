local WindUI
do
    local ok, result = pcall(function()
        return require("./src/init")
    end)
    if ok then
        WindUI = result
    else
        WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

local config = {
    KillAura = {
        Enabled = false,
        Range = 30,
        Interval = 0.5,
        AutoRotate = false,
    },
    Block = {
        Enabled = false,
        AnimSpeed = 20,
    },
    Heal = {
        Enabled = false,
        HealInterval = 0.5,
        HealThreshold = 100,
        FakeDistance = 0.5,
    }
}

local killAuraRunning = false
local killAuraLoopConn = nil

local function getChar()
    return player.Character
end

local function getWeapon()
    local char = getChar()
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Swing") then
        return tool
    end
    for _, t in ipairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and t:FindFirstChild("Swing") then
            return t
        end
    end
    return nil
end

local function getNearestEnemy()
    local char = getChar()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local nearest = nil
    local minDist = config.KillAura.Range
    local zombieFolder = workspace:FindFirstChild("AliveZombies")
    if zombieFolder then
        for _, obj in ipairs(zombieFolder:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                local hum = obj:FindFirstChild("Humanoid")
                if hum.Health > 0 then
                    local targetRoot = obj:FindFirstChild("HumanoidRootPart")
                    local dist = (targetRoot.Position - root.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = obj
                    end
                end
            end
        end
    end
    if not nearest then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                local hum = obj:FindFirstChild("Humanoid")
                if hum.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                    local targetRoot = obj:FindFirstChild("HumanoidRootPart")
                    local dist = (targetRoot.Position - root.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = obj
                    end
                end
            end
        end
    end
    return nearest
end

local function attack(enemy, weapon)
    local swing = weapon:FindFirstChild("Swing")
    if not swing then return end
    local char = getChar()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local targetRoot = enemy and enemy:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then return end
    if config.KillAura.AutoRotate then
        local dir = (targetRoot.Position - root.Position).Unit
        root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(dir.X, 0, dir.Z))
    end
    pcall(function()
        swing:FireServer(1)
    end)
end

local function StartKillAura()
    if killAuraRunning then return end
    killAuraRunning = true
    killAuraLoopConn = task.spawn(function()
        while killAuraRunning and config.KillAura.Enabled do
            task.wait(config.KillAura.Interval)
            local char = getChar()
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            local weapon = getWeapon()
            if not weapon then continue end
            if weapon.Parent == player.Backpack then
                pcall(function()
                    char.Humanoid:EquipTool(weapon)
                end)
                task.wait(0.1)
            end
            local enemy = getNearestEnemy()
            if enemy then
                attack(enemy, weapon)
            end
        end
        killAuraRunning = false
    end)
end

local function StopKillAura()
    killAuraRunning = false
    if killAuraLoopConn then
        task.cancel(killAuraLoopConn)
        killAuraLoopConn = nil
    end
end

local blocking = false
local blockTrack = nil
local blockMarker = nil
local blockLoop = nil
local currentTool = nil

local function stopBlocking()
    if blockLoop then
        blockLoop:Disconnect()
        blockLoop = nil
    end
    if blockTrack then
        blockTrack:Stop()
        blockTrack = nil
    end
    if blockMarker then
        blockMarker:Destroy()
        blockMarker = nil
    end
    if humanoid and humanoid:IsDescendantOf(game) then
        humanoid.WalkSpeed = 16
    end
    blocking = false
    currentTool = nil
end

local function startBlockCycle(tool)
    if not config.Block.Enabled then return end
    if blocking then return end
    blocking = true
    currentTool = tool
    local sabreAnims = ReplicatedStorage:WaitForChild("GlobalGunAnimations"):WaitForChild("Melee"):WaitForChild("Sabre")
    local anim = sabreAnims:WaitForChild("Block")
    blockTrack = animator:LoadAnimation(anim)
    blockTrack:Play()
    blockTrack.Looped = false
    blockTrack:AdjustSpeed(config.Block.AnimSpeed)
    humanoid.WalkSpeed = 12
    blockMarker = Instance.new("BoolValue")
    blockMarker.Name = "WeaponBlocking2"
    blockMarker.Parent = character
    local blockedEvent = tool:FindFirstChild("Blocked")
    if blockedEvent and blockedEvent:IsA("RemoteEvent") then
        blockedEvent:FireServer()
    end

    blockTrack.Stopped:Connect(function()
        if blocking then
            stopBlocking()
            task.wait(0.05)
            startBlockCycle(tool)
        end
    end)

    blockLoop = RunService.Heartbeat:Connect(function()
        if blocking and blockedEvent and os.clock() % 0.3 < 0.05 then
            blockedEvent:FireServer()
        end
    end)
end

local function onToolEquipped(tool)
    if tool.Name == "Sabre" and config.Block.Enabled then
        startBlockCycle(tool)
    end
end

local function onToolUnequipped()
    stopBlocking()
end

character.ChildAdded:Connect(function(child)
    if child:IsA("Tool") and child.Name == "Sabre" then
        onToolEquipped(child)
    end
end)

character.ChildRemoved:Connect(function(child)
    if child:IsA("Tool") and child.Name == "Sabre" then
        onToolUnequipped(child)
    end
end)

local healRunning = false
local healLoopConn = nil
local healTool = nil

local function getLocalCharacter()
    return player.Character
end

local function getHealTool()
    local char = getLocalCharacter()
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("HealPlayer") and tool:FindFirstChild("AddTags") then
        return tool
    end
    return nil
end

local function getHealTargets()
    local targets = {}
    local myChar = getLocalCharacter()
    if not myChar then return targets end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local c = p.Character
            if c then
                local hum = c:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and hum.Health < config.Heal.HealThreshold then
                    targets[#targets + 1] = p
                end
            end
        end
    end
    return targets
end

local function healTarget(p)
    if not healTool then return end
    local targetChar = p.Character
    if not targetChar then return end
    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
    if not targetHum or targetHum.Health <= 0 or targetHum.Health >= config.Heal.HealThreshold then return end
    local myChar = getLocalCharacter()
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local fakePos = myRoot.Position + Vector3.new(0, config.Heal.FakeDistance, 0)
    local addTagsEvent = healTool:FindFirstChild("AddTags")
    local healPlayerEvent = healTool:FindFirstChild("HealPlayer")
    if addTagsEvent and addTagsEvent:IsA("RemoteEvent") then
        pcall(function() addTagsEvent:FireServer(player, p, true) end)
    end
    if healPlayerEvent and healPlayerEvent:IsA("RemoteEvent") then
        pcall(function() healPlayerEvent:FireServer(fakePos, fakePos, 90, targetHum, true, player) end)
    end
    task.delay(0.2, function()
        if addTagsEvent and addTagsEvent:IsA("RemoteEvent") then
            pcall(function() addTagsEvent:FireServer(player, p, false) end)
        end
    end)
end

local function StartHeal()
    if healRunning then return end
    healRunning = true
    healLoopConn = task.spawn(function()
        while healRunning and config.Heal.Enabled do
            task.wait(config.Heal.HealInterval)
            healTool = getHealTool()
            if not healTool then continue end
            local targets = getHealTargets()
            for _, p in ipairs(targets) do
                healTarget(p)
                task.wait(0.1)
            end
        end
        healRunning = false
    end)
end

local function StopHeal()
    healRunning = false
    if healLoopConn then
        task.cancel(healLoopConn)
        healLoopConn = nil
    end
end

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    animator = humanoid:WaitForChild("Animator")

    stopBlocking()
    StopHeal()
    task.wait(0.1)
    if config.Heal.Enabled then
        StartHeal()
    end

    local tool = character:FindFirstChildOfClass("Tool")
    if tool and tool.Name == "Sabre" and config.Block.Enabled then
        startBlockCycle(tool)
    end
end)

do
    local currentTool = character:FindFirstChildOfClass("Tool")
    if currentTool and currentTool.Name == "Sabre" and config.Block.Enabled then
        startBlockCycle(currentTool)
    end
end

if config.Heal.Enabled then
    StartHeal()
end

_G.OE_Script = {
    KillAura = {
        Enable = function() config.KillAura.Enabled = true; StartKillAura() end,
        Disable = function() config.KillAura.Enabled = false; StopKillAura() end,
        Toggle = function() config.KillAura.Enabled = not config.KillAura.Enabled; if config.KillAura.Enabled then StartKillAura() else StopKillAura() end end,
    },
    Block = {
        Enable = function() config.Block.Enabled = true; local tool = character:FindFirstChildOfClass("Tool"); if tool and tool.Name == "Sabre" then startBlockCycle(tool) end end,
        Disable = function() config.Block.Enabled = false; stopBlocking() end,
        Toggle = function() config.Block.Enabled = not config.Block.Enabled; if config.Block.Enabled then local tool = character:FindFirstChildOfClass("Tool"); if tool and tool.Name == "Sabre" then startBlockCycle(tool) end else stopBlocking() end end,
    },
    Heal = {
        Enable = function() config.Heal.Enabled = true; StartHeal() end,
        Disable = function() config.Heal.Enabled = false; StopHeal() end,
        Toggle = function() config.Heal.Enabled = not config.Heal.Enabled; if config.Heal.Enabled then StartHeal() else StopHeal() end end,
        SetThreshold = function(t) config.Heal.HealThreshold = t end,
    }
}

local Window = WindUI:CreateWindow({
    Title = "我们的处决",
    Author = "Made by星火",
    Folder = "OE_Xinghuo",
    NewElements = true,
    HideSearchBar = false,
    OpenButton = {
        Title = "Our execution",
        CornerRadius = UDim.new(1,0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Color = ColorSequence.new(
            Color3.fromHex("#8b0000"),
            Color3.fromHex("#ff2222")
        )
    }
})

local ConfigManager = Window.ConfigManager

local KillAuraTab = Window:Tab({
    Title = "杀戮光环",
    Icon = "sword"
})
local KA_Main = KillAuraTab:Section({Title = "基础设置"})

KA_Main:Toggle({
    Flag = "ka_enabled",
    Title = "启用杀戮光环",
    Default = config.KillAura.Enabled,
    Callback = function(state)
        config.KillAura.Enabled = state
        if state then
            StartKillAura()
            WindUI:Notify({Title="杀戮光环", Content="已开启", Icon="check"})
        else
            StopKillAura()
            WindUI:Notify({Title="杀戮光环", Content="已关闭", Icon="x"})
        end
    end
})

KA_Main:Toggle({
    Flag = "ka_autorotate",
    Title = "自动转向敌人",
    Default = config.KillAura.AutoRotate,
    Callback = function(state)
        config.KillAura.AutoRotate = state
    end
})

KA_Main:Slider({
    Flag = "ka_range",
    Title = "攻击范围",
    Step = 1,
    Value = {Min=5,Max=100,Default=config.KillAura.Range},
    Callback = function(val)
        config.KillAura.Range = val
    end
})

KA_Main:Slider({
    Flag = "ka_interval",
    Title = "攻击间隔",
    Step = 0.05,
    Value = {Min=0.1,Max=3.0,Default=config.KillAura.Interval},
    Callback = function(val)
        config.KillAura.Interval = val
    end
})

local KA_Info = KillAuraTab:Section({Title = "说明信息"})
KA_Info:Paragraph({
    Title = "使用说明",
    Desc = "优先扫描AliveZombies文件夹；若无，则遍历全地图非玩家实体。武器必须带有Swing远程事件，支持自动从背包装备。"
})

local BlockTab = Window:Tab({
    Title = "自动格挡",
    Icon = "shield"
})
local BL_Main = BlockTab:Section({Title = "格挡设置"})

BL_Main:Toggle({
    Flag = "block_enabled",
    Title = "启用自动格挡",
    Default = config.Block.Enabled,
    Callback = function(state)
        config.Block.Enabled = state
        if not state then
            stopBlocking()
            WindUI:Notify({Title="自动格挡", Content="已关闭", Icon="x"})
        else
            local tool = character:FindFirstChildOfClass("Tool")
            if tool and tool.Name == "Sabre" and not blocking then
                startBlockCycle(tool)
                WindUI:Notify({Title="自动格挡", Content="已开启", Icon="check"})
            end
        end
    end
})

BL_Main:Slider({
    Flag = "block_speed",
    Title = "格挡动画倍速",
    Step = 1,
    Value = {Min=1,Max=50,Default=config.Block.AnimSpeed},
    Callback = function(val)
        config.Block.AnimSpeed = val
        if blocking and currentTool then
            stopBlocking()
            task.wait(0.05)
            startBlockCycle(currentTool)
        end
    end
})

local BL_Info = BlockTab:Section({Title = "说明信息"})
BL_Info:Paragraph({
    Title = "使用说明",
    Desc = "装备Sabre武器自动循环格挡；卸下武器立刻停止；重生角色自动恢复格挡逻辑。"
})

local HealTab = Window:Tab({
    Title = "全图治疗",
    Icon = "heart"
})
local HL_Main = HealTab:Section({Title = "治疗设置"})

HL_Main:Toggle({
    Flag = "heal_enabled",
    Title = "启用全图治疗",
    Default = config.Heal.Enabled,
    Callback = function(state)
        config.Heal.Enabled = state
        if state then
            StartHeal()
            WindUI:Notify({Title="全图治疗", Content="已开启", Icon="check"})
        else
            StopHeal()
            WindUI:Notify({Title="全图治疗", Content="已关闭", Icon="x"})
        end
    end
})

HL_Main:Slider({
    Flag = "heal_interval",
    Title = "治疗间隔",
    Step = 0.05,
    Value = {Min=0.1,Max=2.0,Default=config.Heal.HealInterval},
    Callback = function(val)
        config.Heal.HealInterval = val
    end
})

HL_Main:Slider({
    Flag = "heal_threshold",
    Title = "血量触发阈值",
    Step = 5,
    Value = {Min=10,Max=200,Default=config.Heal.HealThreshold},
    Callback = function(val)
        config.Heal.HealThreshold = val
    end
})

HL_Main:Slider({
    Flag = "heal_fakedist",
    Title = "伪造距离",
    Step = 0.1,
    Value = {Min=0,Max=2.0,Default=config.Heal.FakeDistance},
    Callback = function(val)
        config.Heal.FakeDistance = val
    end
})

local HL_Info = HealTab:Section({Title = "说明信息"})
HL_Info:Paragraph({
    Title = "使用说明",
    Desc = "必须持有带有HealPlayer、AddTags远程事件的治疗工具；只会治疗血量低于阈值的其他玩家。"
})

local GlobalTab = Window:Tab({
    Title = "全局工具",
    Icon = "settings"
})
local GL_Main = GlobalTab:Section({Title = "一键操作"})

GL_Main:Button({
    Title = "全部关闭所有功能",
    Icon = "power-off",
    Callback = function()
        config.KillAura.Enabled = false
        config.Block.Enabled = false
        config.Heal.Enabled = false
        StopKillAura()
        stopBlocking()
        StopHeal()
        WindUI:Notify({Title="全局", Content="全部功能已关闭", Icon="check"})
    end
})

GL_Main:Button({
    Title = "销毁UI面板",
    Icon = "shredder",
    Callback = function()
        StopKillAura()
        stopBlocking()
        StopHeal()
        Window:Destroy()
    end
})

local GL_Config = GlobalTab:Section({Title = "配置管理"})

GL_Config:Button({
    Title = "保存当前配置",
    Icon = "save",
    Callback = function()
        local cfg = ConfigManager:CreateConfig("main")
        if cfg:Save() then
            WindUI:Notify({Title="配置", Content="配置保存成功", Icon="check"})
        end
    end
})

GL_Config:Button({
    Title = "加载配置",
    Icon = "refresh-cw",
    Callback = function()
        local cfg = ConfigManager:CreateConfig("main")
        if cfg:Load() then
            WindUI:Notify({Title="配置", Content="配置加载成功", Icon="check"})
        end
    end
})

print("✅ 我们的处决脚本加载完成！")
print("🌐 全局API：_G.OE_Script")
