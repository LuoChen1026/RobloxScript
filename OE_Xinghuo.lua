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
local LP = Players.LocalPlayer
local player = LP
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")
local ORIGINAL_WALKSPEED = humanoid.WalkSpeed
local config = {
    KillAura = {
        Enabled = false,
        Range = 30,
        Interval = 0.5,
        AutoRotate = false,
    },
    Block = {
        Enabled = true,
        AnimSpeed = 20,
    },
    Heal = {
        Enabled = true,
        HealInterval = 0.5,
        HealThreshold = 100,
        FakeDistance = 0.5,
    },
    KeySpotESP = {
        Enabled = false
    },
    LadderESP = {
        Enabled = false
    },
    PlayerMod = {
        Enabled = false,
        WalkSpeed = 16
    },
    PlayerESP = {
        Enabled = false,
        ShowBox = true,
        ShowName = true,
        ShowHealth = true,
        ShowDistance = true
    },
    ZombieESP = {
        Enabled = false,
        ShowBox = true,
        ShowName = true,
        ShowHealth = true,
        ShowDistance = true
    }
}
local killAuraRunning = false
local killAuraLoopConn = nil
local blocking = false
local blockTrack = nil
local blockMarker = nil
local blockLoop = nil
local currentTool = nil
local healRunning = false
local healLoopConn = nil
local healTool = nil
local ESPRefreshLoop = nil
local ESP_Container = {}

local function SetWalkSpeed(speed)
    config.PlayerMod.WalkSpeed = speed
    if humanoid and humanoid:IsDescendantOf(game) then
        if config.PlayerMod.Enabled then
            humanoid.WalkSpeed = speed
        else
            humanoid.WalkSpeed = ORIGINAL_WALKSPEED
        end
    end
end

local function ResetPlayerProperties()
    SetWalkSpeed(ORIGINAL_WALKSPEED)
end

local function ToggleCustomWalkSpeed(state)
    config.PlayerMod.Enabled = state
    if state then
        SetWalkSpeed(config.PlayerMod.WalkSpeed)
        WindUI:Notify({Title="人物功能", Content="自定义移动速度已开启", Icon="check"})
    else
        ResetPlayerProperties()
        WindUI:Notify({Title="人物功能", Content="自定义移动速度已关闭，恢复原始速度", Icon="x"})
    end
end

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
        if config.PlayerMod.Enabled then
            humanoid.WalkSpeed = config.PlayerMod.WalkSpeed
        else
            humanoid.WalkSpeed = ORIGINAL_WALKSPEED
        end
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
    if config.PlayerMod.Enabled then
        SetWalkSpeed(config.PlayerMod.WalkSpeed)
    else
        ResetPlayerProperties()
    end
    ClearAllMobPlayerESP()
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
local function ClearKeySpotESP()
    for _, v in ipairs(game:GetDescendants()) do
        if v.Name == "KeySpotESP_UI" or v.Name == "KeySpotESP_HL" then
            v:Destroy()
        end
    end
end
local function LoadKeySpotESP()
    ClearKeySpotESP()
    local KEYSPOTS_ROOT = workspace["Garden Of Dishonor"].KeySpots
    local count = 0
    local function makeESP(part, label)
        if not part or not part:IsA("BasePart") then return end
        count = count + 1
        local hl = Instance.new("Highlight")
        hl.Name = "KeySpotESP_HL"
        hl.Adornee = part
        hl.Parent = part
        hl.FillColor = Color3.fromRGB(255, 215, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        local bb = Instance.new("BillboardGui")
        bb.Name = "KeySpotESP_UI"
        bb.Adornee = part
        bb.Parent = part
        bb.Size = UDim2.new(0, 160, 0, 32)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        local txt = Instance.new("TextLabel")
        txt.Parent = bb
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = label or part.Name
        txt.TextColor3 = Color3.fromRGB(255, 215, 0)
        txt.TextStrokeTransparency = 0
        txt.TextStrokeColor3 = Color3.new(0, 0, 0)
        txt.TextScaled = true
        txt.Font = Enum.Font.SourceSansBold
    end
    local function scan(container)
        for _, v in ipairs(container:GetChildren()) do
            if v:IsA("BasePart") then
                makeESP(v, v.Name)
            elseif v:IsA("Model") then
                local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                if p then makeESP(p, v.Name) end
            elseif v:IsA("Folder") or v:IsA("Model") then
                scan(v)
            end
        end
    end
    scan(KEYSPOTS_ROOT)
    print("[KeySpots ESP] 完成，共标记", count, "个点")
end
local function ToggleKeySpotESP(state)
    config.KeySpotESP.Enabled = state
    if state then
        LoadKeySpotESP()
        WindUI:Notify({Title="钥匙透视", Content="已开启", Icon="check"})
    else
        ClearKeySpotESP()
        WindUI:Notify({Title="钥匙透视", Content="已关闭", Icon="x"})
    end
end
local function ClearLadderESP()
    for _, v in ipairs(game:GetDescendants()) do
        if v.Name == "LadderESP_HL" then
            v:Destroy()
        end
    end
end
local function LoadLadderESP()
    ClearLadderESP()
    local ROOT = workspace.Kyraht.BeginningArea.LadderSpawns
    local count = 0
    local function makeESP(model)
        if not model or not model:IsA("Model") then return end
        count = count + 1
        local hl = Instance.new("Highlight")
        hl.Name = "LadderESP_HL"
        hl.Adornee = model
        hl.Parent = model
        hl.FillColor = Color3.fromRGB(0, 255, 180)
        hl.FillTransparency = 0
        hl.OutlineTransparency = 1
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    local function scan(container)
        for _, v in ipairs(container:GetChildren()) do
            if v:IsA("Model") and v.Name:lower():find("ladder") then
                makeESP(v)
            elseif v:IsA("Folder") or v:IsA("Model") then
                scan(v)
            end
        end
    end
    scan(ROOT)
    print("[Ladder ESP] 完成，共标记", count, "个")
end
local function ToggleLadderESP(state)
    config.LadderESP.Enabled = state
    if state then
        LoadLadderESP()
        WindUI:Notify({Title="梯子透视", Content="已开启", Icon="check"})
    else
        ClearLadderESP()
        WindUI:Notify({Title="梯子透视", Content="已关闭", Icon="x"})
    end
end

local function ClearAllMobPlayerESP()
    for _, obj in ipairs(ESP_Container) do
        if obj and obj:IsDescendantOf(game) then
            obj:Destroy()
        end
    end
    table.clear(ESP_Container)
    for _, v in ipairs(game:GetDescendants()) do
        if v.Name == "ESP_Player_HL" or v.Name == "ESP_Player_BB" or v.Name == "ESP_Zombie_HL" or v.Name == "ESP_Zombie_BB" then
            v:Destroy()
        end
    end
end

local function CreateBillboardESP(adornee, textStr, tagName)
    if not adornee then return nil end
    local bb = Instance.new("BillboardGui")
    bb.Name = tagName or "ESP_Player_BB"
    bb.Adornee = adornee
    bb.Size = UDim2.new(0, 220, 0, 60)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.Parent = adornee
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = textStr
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.TextColor3 = Color3.new(1,1,1)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.Parent = bb
    table.insert(ESP_Container, bb)
    return bb
end

local function CreateHighlightESP(adornee, fillColor, outlineColor, tagName)
    if not adornee then return nil end
    local hl = Instance.new("Highlight")
    hl.Name = tagName or "ESP_Player_HL"
    hl.Adornee = adornee
    hl.FillColor = fillColor
    hl.OutlineColor = outlineColor
    hl.FillTransparency = 0.75
    hl.OutlineTransparency = 0.15
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = adornee
    table.insert(ESP_Container, hl)
    return hl
end

local function RefreshPlayerESP()
    if not config.PlayerESP.Enabled then return end
    local myRoot = character and character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            local tarChar = targetPlayer.Character
            if not tarChar then continue end
            local tarHum = tarChar:FindFirstChildOfClass("Humanoid")
            local tarRoot = tarChar:FindFirstChild("HumanoidRootPart")
            if not tarHum or not tarRoot or tarHum.Health <= 0 then continue end
            local dist = math.floor((tarRoot.Position - myRoot.Position).Magnitude)
            local fillCol = Color3.fromRGB(0,180,255)
            local outCol = Color3.new(0,0,0)
            if config.PlayerESP.ShowBox then
                CreateHighlightESP(tarRoot, fillCol, outCol, "ESP_Player_HL")
            end
            if config.PlayerESP.ShowName or config.PlayerESP.ShowHealth or config.PlayerESP.ShowDistance then
                local displayText = ""
                if config.PlayerESP.ShowName then displayText = displayText .. targetPlayer.Name.."\n" end
                if config.PlayerESP.ShowHealth then displayText = displayText .. "HP:"..math.floor(tarHum.Health).."/"..tarHum.MaxHealth.."\n" end
                if config.PlayerESP.ShowDistance then displayText = displayText .. "距离:"..dist.." studs" end
                CreateBillboardESP(tarRoot, displayText, "ESP_Player_BB")
            end
        end
    end
end

local function RefreshZombieESP()
    if not config.ZombieESP.Enabled then return end
    local myRoot = character and character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local scanPool = {}
    local zombieFolder = workspace:FindFirstChild("AliveZombies")
    if zombieFolder then
        for _,m in ipairs(zombieFolder:GetChildren()) do
            if m:IsA("Model") then table.insert(scanPool,m) end
        end
    end
    for _,m in ipairs(workspace:GetDescendants()) do
        if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(m) then
            table.insert(scanPool,m)
        end
    end
    for _,mobModel in ipairs(scanPool) do
        local hum = mobModel:FindFirstChildOfClass("Humanoid")
        local root = mobModel:FindFirstChild("HumanoidRootPart")
        if not hum or not root or hum.Health <= 0 then continue end
        local dist = math.floor((root.Position - myRoot.Position).Magnitude)
        local fillCol = Color3.fromRGB(255,40,40)
        local outCol = Color3.new(0,0,0)
        if config.ZombieESP.ShowBox then
            CreateHighlightESP(root, fillCol, outCol, "ESP_Zombie_HL")
        end
        if config.ZombieESP.ShowName or config.ZombieESP.ShowHealth or config.ZombieESP.ShowDistance then
            local displayText = ""
            if config.ZombieESP.ShowName then displayText = displayText .. mobModel.Name.."\n" end
            if config.ZombieESP.ShowHealth then displayText = displayText .. "HP:"..math.floor(hum.Health).."/"..hum.MaxHealth.."\n" end
            if config.ZombieESP.ShowDistance then displayText = displayText .. "距离:"..dist.." studs" end
            CreateBillboardESP(root, displayText, "ESP_Zombie_BB")
        end
    end
end

local function StartESPGlobalLoop()
    if ESPRefreshLoop then task.cancel(ESPRefreshLoop) end
    ESPRefreshLoop = task.spawn(function()
        while task.wait(0.35) do
            ClearAllMobPlayerESP()
            if config.PlayerESP.Enabled then RefreshPlayerESP() end
            if config.ZombieESP.Enabled then RefreshZombieESP() end
            if not config.PlayerESP.Enabled and not config.ZombieESP.Enabled then
                ClearAllMobPlayerESP()
                break
            end
        end
    end)
end

local function StopESPGlobalLoop()
    if ESPRefreshLoop then
        task.cancel(ESPRefreshLoop)
        ESPRefreshLoop = nil
    end
    ClearAllMobPlayerESP()
end

local function TogglePlayerESP(state)
    config.PlayerESP.Enabled = state
    if state then
        StartESPGlobalLoop()
        WindUI:Notify({Title="玩家ESP", Content="已开启", Icon="check"})
    else
        if not config.ZombieESP.Enabled then StopESPGlobalLoop() end
        WindUI:Notify({Title="玩家ESP", Content="已关闭", Icon="x"})
    end
end

local function ToggleZombieESP(state)
    config.ZombieESP.Enabled = state
    if state then
        StartESPGlobalLoop()
        WindUI:Notify({Title="僵尸ESP", Content="已开启", Icon="check"})
    else
        if not config.PlayerESP.Enabled then StopESPGlobalLoop() end
        WindUI:Notify({Title="僵尸ESP", Content="已关闭", Icon="x"})
    end
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
    },
    KeySpotESP = {
        Toggle = function() ToggleKeySpotESP(not config.KeySpotESP.Enabled) end
    },
    LadderESP = {
        Toggle = function() ToggleLadderESP(not config.LadderESP.Enabled) end
    },
    PlayerMod = {
        SetWalkSpeed = function(speed) SetWalkSpeed(speed) end,
        Reset = function() ResetPlayerProperties() end,
        ToggleCustom = function() ToggleCustomWalkSpeed(not config.PlayerMod.Enabled) end
    },
    PlayerESP = {
        Toggle = function() TogglePlayerESP(not config.PlayerESP.Enabled) end
    },
    ZombieESP = {
        Toggle = function() ToggleZombieESP(not config.ZombieESP.Enabled) end
    }
}

local Window = WindUI:CreateWindow({
    Title = "我们的处决脚本",
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
    Desc = "优先扫描存活僵尸文件夹；若无，则遍历全地图非玩家实体。武器必须带有挥动远程事件，支持自动从背包装备。"
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
    Desc = "装备强盗武器自动循环格挡；卸下武器立刻停止；重生角色自动恢复格挡逻辑。"
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
    Desc = "必须持有带有治疗玩家、AddTags远程事件的治疗工具；只会治疗血量低于阈值的其他玩家。"
})

local PlayerTab = Window:Tab({
    Title = "人物功能",
    Icon = "person"
})
local PL_Main = PlayerTab:Section({Title = "角色属性修改"})

PL_Main:Toggle({
    Flag = "player_walkspeed_enable",
    Title = "启用自定义移动速度",
    Default = config.PlayerMod.Enabled,
    Callback = function(state)
        ToggleCustomWalkSpeed(state)
    end
})

PL_Main:Slider({
    Flag = "player_walkspeed",
    Title = "移动速度",
    Step = 1,
    Value = {Min=16,Max=120,Default=config.PlayerMod.WalkSpeed},
    Callback = function(val)
        SetWalkSpeed(val)
    end
})

PL_Main:Button({
    Title = "恢复原始速度",
    Icon = "undo",
    Callback = function()
        ResetPlayerProperties()
        WindUI:Notify({Title="人物功能", Content="已恢复原始移动速度", Icon="check"})
    end
})
local PL_Info = PlayerTab:Section({Title = "说明信息"})
PL_Info:Paragraph({
    Title = "使用说明",
    Desc = "必须开启【启用自定义移动速度】滑块才会生效；关闭开关自动恢复游戏原始16速度；脚本销毁 / 全部关闭自动复原；角色重生自动继承开关状态。"
})

local ESPTab = Window:Tab({
    Title = "透视ESP",
    Icon = "eye"
})
local ESP_Main = ESPTab:Section({Title = "地图点位透视"})
ESP_Main:Toggle({
    Flag = "keyspot_esp",
    Title = "钥匙透视",
    Default = config.KeySpotESP.Enabled,
    Callback = function(state)
        ToggleKeySpotESP(state)
    end
})
ESP_Main:Toggle({
    Flag = "ladder_esp",
    Title = "梯子透视",
    Default = config.LadderESP.Enabled,
    Callback = function(state)
        ToggleLadderESP(state)
    end
})

local ESP_PlayerSection = ESPTab:Section({Title = "玩家ESP"})
ESP_PlayerSection:Toggle({
    Flag = "player_esp_enable",
    Title = "启用玩家ESP",
    Default = config.PlayerESP.Enabled,
    Callback = function(state)
        TogglePlayerESP(state)
    end
})
ESP_PlayerSection:Toggle({
    Flag = "player_esp_box",
    Title = "显示方框高亮",
    Default = config.PlayerESP.ShowBox,
    Callback = function(state)
        config.PlayerESP.ShowBox = state
    end
})
ESP_PlayerSection:Toggle({
    Flag = "player_esp_name",
    Title = "显示玩家名字",
    Default = config.PlayerESP.ShowName,
    Callback = function(state)
        config.PlayerESP.ShowName = state
    end
})
ESP_PlayerSection:Toggle({
    Flag = "player_esp_hp",
    Title = "显示血量",
    Default = config.PlayerESP.ShowHealth,
    Callback = function(state)
        config.PlayerESP.ShowHealth = state
    end
})
ESP_PlayerSection:Toggle({
    Flag = "player_esp_dist",
    Title = "显示距离",
    Default = config.PlayerESP.ShowDistance,
    Callback = function(state)
        config.PlayerESP.ShowDistance = state
    end
})

local ESP_ZombieSection = ESPTab:Section({Title = "僵尸/怪物ESP"})
ESP_ZombieSection:Toggle({
    Flag = "zombie_esp_enable",
    Title = "启用僵尸ESP",
    Default = config.ZombieESP.Enabled,
    Callback = function(state)
        ToggleZombieESP(state)
    end
})
ESP_ZombieSection:Toggle({
    Flag = "zombie_esp_box",
    Title = "显示方框高亮",
    Default = config.ZombieESP.ShowBox,
    Callback = function(state)
        config.ZombieESP.ShowBox = state
    end
})
ESP_ZombieSection:Toggle({
    Flag = "zombie_esp_name",
    Title = "显示怪物名称",
    Default = config.ZombieESP.ShowName,
    Callback = function(state)
        config.ZombieESP.ShowName = state
    end
})
ESP_ZombieSection:Toggle({
    Flag = "zombie_esp_hp",
    Title = "显示血量",
    Default = config.ZombieESP.ShowHealth,
    Callback = function(state)
        config.ZombieESP.ShowHealth = state
    end
})
ESP_ZombieSection:Toggle({
    Flag = "zombie_esp_dist",
    Title = "显示距离",
    Default = config.ZombieESP.ShowDistance,
    Callback = function(state)
        config.ZombieESP.ShowDistance = state
    end
})

local ESP_Info = ESPTab:Section({Title = "说明信息"})
ESP_Info:Paragraph({
    Title = "使用说明",
    Desc = "钥匙：高亮耻辱花园内点位；梯子：填充高亮基拉特过桥后梯子模型，无描边方框；玩家ESP标记其他玩家；僵尸ESP标记存活怪物，刷新间隔0.35秒。"
})
local GlobalTab = Window:Tab({
    Title = "全局工具",
    Icon = "settings"
})
local GL_Main = GlobalTab:Section({Title = "一键操作"})
GL_Main:Button({
    Title = "一键关闭所有功能",
    Icon = "power-off",
    Callback = function()
        config.KillAura.Enabled = false
        config.Block.Enabled = false
        config.Heal.Enabled = false
        config.KeySpotESP.Enabled = false
        config.LadderESP.Enabled = false
        config.PlayerESP.Enabled = false
        config.ZombieESP.Enabled = false
        config.PlayerMod.Enabled = false
        ToggleCustomWalkSpeed(false)

        StopKillAura()
        stopBlocking()
        StopHeal()
        ClearKeySpotESP()
        ClearLadderESP()
        StopESPGlobalLoop()
        ClearAllMobPlayerESP()
        ResetPlayerProperties()
        WindUI:Notify({Title="全局", Content="全部功能已关闭，人物属性已复原", Icon="check"})
    end
})
GL_Main:Button({
    Title = "销毁UI面板（全部功能失效）",
    Icon = "shredder",
    Callback = function()
        config.PlayerMod.Enabled = false
        ToggleCustomWalkSpeed(false)

        StopKillAura()
        stopBlocking()
        StopHeal()
        ClearKeySpotESP()
        ClearLadderESP()
        StopESPGlobalLoop()
        ClearAllMobPlayerESP()
        ResetPlayerProperties()
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
            if config.PlayerMod.Enabled then
                ToggleCustomWalkSpeed(true)
            else
                ToggleCustomWalkSpeed(false)
            end
            if config.PlayerESP.Enabled then TogglePlayerESP(true) end
            if config.ZombieESP.Enabled then ToggleZombieESP(true) end
            WindUI:Notify({Title="配置", Content="配置加载成功", Icon="check"})
        end
    end
})
print("✅ 我们的处决脚本加载完成！")
print("🌐 全局API：_G.OE_Script")
