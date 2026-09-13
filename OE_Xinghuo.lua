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
    HitboxMod = {
        Enabled = false,
        Scale = 4
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

local HitboxMod = {
	Enabled = false,
	Scale = 4,
	LoopConn = nil,
	Hitboxes = {},
}

local function HB_isZombie(obj)
	if obj.ClassName ~= "Model" then return false end
	if Players:GetPlayerFromCharacter(obj) then return false end
	local ancestor = obj
	for _ = 1, 3 do
		ancestor = ancestor.Parent
		if not ancestor then break end
		if ancestor.Name == "AliveZombies" then return true end
	end
	return false
end

local function HB_createHitbox(model)
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end
	local root = model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChild("UpperTorso")
		or model:FindFirstChild("Torso")
	if not root then return end

	local hb = Instance.new("Part")
	hb.Name = "_HitboxOverride"
	hb.Size = Vector3.new(8, 10, 8) * HitboxMod.Scale
	hb.Transparency = 1
	hb.CanCollide = false
	hb.CanTouch = false
	hb.CanQuery = true
	hb.Massless = true
	hb.Anchored = true
	hb.Locked = true
	hb.CFrame = root.CFrame
	hb.Parent = model

	HitboxMod.Hitboxes[model] = hb
end

local function HB_removeHitbox(model)
	local hb = HitboxMod.Hitboxes[model]
	if hb and hb.Parent then
		pcall(function() hb:Destroy() end)
	end
	HitboxMod.Hitboxes[model] = nil
end

local function HB_restoreAll()
	for model in pairs(HitboxMod.Hitboxes) do
		HB_removeHitbox(model)
	end
	HitboxMod.Hitboxes = {}
end

local function HB_start()
	if HitboxMod.LoopConn then return end
	HitboxMod.LoopConn = RunService.Heartbeat:Connect(function()
		if not HitboxMod.Enabled then return end
		local zf = workspace:FindFirstChild("AliveZombies")
		if not zf then return end

		local toRemove = {}
		for model in pairs(HitboxMod.Hitboxes) do
			local hum = model:FindFirstChildOfClass("Humanoid")
			if not model.Parent or not hum or hum.Health <= 0 then
				toRemove[#toRemove + 1] = model
			end
		end
		for _, m in ipairs(toRemove) do HB_removeHitbox(m) end

		for _, obj in ipairs(zf:GetChildren()) do
			if HB_isZombie(obj) then
				local hb = HitboxMod.Hitboxes[obj]
				if not hb or not hb.Parent then
					HB_createHitbox(obj)
					hb = HitboxMod.Hitboxes[obj]
				end
				if hb then
					local root = obj:FindFirstChild("HumanoidRootPart")
						or obj:FindFirstChild("UpperTorso")
						or obj:FindFirstChild("Torso")
					if root then
						hb.CFrame = root.CFrame
						hb.Size = Vector3.new(8, 10, 8) * HitboxMod.Scale
					end
				end
			end
		end
	end)
end

local function HB_stop()
	if HitboxMod.LoopConn then
		HitboxMod.LoopConn:Disconnect()
		HitboxMod.LoopConn = nil
	end
	HB_restoreAll()
end

local function HB_SetEnabled(state)
	HitboxMod.Enabled = state
	if state then
		HB_start()
		WindUI:Notify({Title="碰撞箱修改", Content="碰撞箱已开启", Icon="check"})
	else
		HB_stop()
		WindUI:Notify({Title="碰撞箱修改", Content="碰撞箱已关闭，全部生成的碰撞箱已清除", Icon="x"})
	end
end

local function HB_SetScale(val)
	HitboxMod.Scale = val
	for model,hb in pairs(HitboxMod.Hitboxes) do
		if hb and hb.Parent then
			local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
			if root then
				hb.Size = Vector3.new(8,10,8)*val
			end
		end
	end
end

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
    local sabreAnims = ReplicatedStorage:FindFirstChild("GlobalGunAnimations")
    if not sabreAnims then return end
    local melee = sabreAnims:FindFirstChild("Melee")
    if not melee then return end
    local sabreFolder = melee:FindFirstChild("Sabre")
    if not sabreFolder then return end
    local anim = sabreFolder:FindFirstChild("Block")
    if not anim then return end
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

local AnimPlayer = {
	Enabled = false,
	currentTrack = nil,
	animator = nil,
	humanoid = nil,
	character = nil,
	Selected = nil,
}

local AnimLib = {
	RespawnAnimation = "rbxassetid://134357211337658",
	Running = "rbxassetid://94161185164143",
	Staggerv2 = "rbxassetid://84384220591289",
	RunnerSpawn = "rbxassetid://18995793649",
	RunnerEat = "rbxassetid://79825893428035",
	RunnerAttack = "rbxassetid://78054258382672",
	RunnerGRAB = "rbxassetid://101206134935798",
	RunnerStun = "rbxassetid://17698361300",
	RunnerMauled = "rbxassetid://87675641077272",
	WalkerAttack = "rbxassetid://71038809040364",
	WalkerEat = "rbxassetid://81237775972142",
	WalkerClaw = "rbxassetid://129710968176304",
	WalkerMaul = "rbxassetid://89440749137230",
	WalkerShoved = "rbxassetid://84102396082891",
	PlayerStagger = "rbxassetid://84520532471132",
	BleedLoop = "rbxassetid://90739531913123",
	BleedStart = "rbxassetid://119650374617755",
	BlockStun = "rbxassetid://131128430900538",
	EscapistShove = "rbxassetid://122506490797047",
	ZombieIdle = "rbxassetid://130160040074885",
	ZombieWalk = "rbxassetid://18418514157",
	ZombieEat = "rbxassetid://101998531930577",
	ZombieGRAB = "rbxassetid://18381484723",
	ZombieAttack = "rbxassetid://17641570205",
	RapierEquip = "rbxassetid://98213384363769",
	RapierIdle = "rbxassetid://74237429034411",
	RapierAttack1 = "rbxassetid://120146914014730",
	RapierQuickJab = "rbxassetid://77993741190871",
	RifleBayonetSwing = "rbxassetid://71732252302609",
	RifleBayonetSwing2 = "rbxassetid://103181422853099",
	RifleBayonetSwing3 = "rbxassetid://102486547226766",
	AxeHeavyAttack = "rbxassetid://119202425062610",
	ShovelAttack1 = "rbxassetid://76146025354153",
	LanceAttack1 = "rbxassetid://78964290032781",
	SledgehammerAttack1 = "rbxassetid://113410130586491",
	LumberAxeAttack1 = "rbxassetid://108044964349463",
	ChargeRunning = "rbxassetid://90670518840837",
	ChargeCry = "rbxassetid://125038863177512",
	Punch = "rbxassetid://117027378087360",
	Shove = "rbxassetid://128482034834595",
}

local AnimNameCN = {
	RespawnAnimation = "重生动画",
	Running = "奔跑",
	Staggerv2 = "眩晕v2",
	RunnerSpawn = "奔跑者-生成",
	RunnerEat = "奔跑者-进食",
	RunnerAttack = "奔跑者-攻击",
	RunnerGRAB = "奔跑者-抓取",
	RunnerStun = "奔跑者-眩晕",
	RunnerMauled = "奔跑者-被撕咬",
	WalkerAttack = "步行者-攻击",
	WalkerEat = "步行者-进食",
	WalkerClaw = "步行者-爪击",
	WalkerMaul = "步行者-撕咬",
	WalkerShoved = "步行者-被推开",
	PlayerStagger = "玩家-踉跄",
	BleedLoop = "流血循环",
	BleedStart = "流血开始",
	BlockStun = "格挡眩晕",
	EscapistShove = "逃生者-推开",
	ZombieIdle = "僵尸-待机",
	ZombieWalk = "僵尸-行走",
	ZombieEat = "僵尸-进食",
	ZombieGRAB = "僵尸-抓取",
	ZombieAttack = "僵尸-攻击",
	RapierEquip = "细剑-装备",
	RapierIdle = "细剑-待机",
	RapierAttack1 = "细剑-攻击1",
	RapierQuickJab = "细剑-快速刺击",
	RifleBayonetSwing = "步枪刺刀-挥击1",
	RifleBayonetSwing2 = "步枪刺刀-挥击2",
	RifleBayonetSwing3 = "步枪刺刀-挥击3",
	AxeHeavyAttack = "斧头-重击",
	ShovelAttack1 = "铁锹-攻击1",
	LanceAttack1 = "骑枪-攻击1",
	SledgehammerAttack1 = "大锤-攻击1",
	LumberAxeAttack1 = "伐木斧-攻击1",
	ChargeRunning = "冲锋-奔跑",
	ChargeCry = "冲锋-喊叫",
	Punch = "出拳",
	Shove = "推开",
}

local AnimNameReverse = {}
for en, cn in pairs(AnimNameCN) do
	AnimNameReverse[cn] = en
end

local AnimNameList = {}
for name, _ in pairs(AnimLib) do
	local cn = AnimNameCN[name] or name
	table.insert(AnimNameList, cn)
end
table.sort(AnimNameList)

local function Anim_refreshChar()
	AnimPlayer.character = player.Character or player.CharacterAdded:Wait()
	AnimPlayer.humanoid = AnimPlayer.character:WaitForChild("Humanoid")
	AnimPlayer.animator = AnimPlayer.humanoid:WaitForChild("Animator")
end

local function Anim_stopCurrent()
	if AnimPlayer.currentTrack then
		pcall(function() AnimPlayer.currentTrack:Stop() end)
		AnimPlayer.currentTrack = nil
	end
end

local function Anim_play(name, looped, speed)
	if not name then return end
	if AnimNameReverse[name] then
		name = AnimNameReverse[name]
	end
	if not AnimPlayer.animator then Anim_refreshChar() end
	local id = AnimLib[name]
	if not id then return end
	Anim_stopCurrent()
	local anim = Instance.new("Animation")
	anim.AnimationId = id
	local track = AnimPlayer.animator:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action4
	track.Looped = looped ~= false
	pcall(function() track:Play() end)
	track:AdjustSpeed(speed or 1)
	AnimPlayer.currentTrack = track
end

player.CharacterAdded:Connect(function()
	task.wait(0.5)
	if AnimPlayer.Enabled then Anim_refreshChar() end
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    animator = humanoid:WaitForChild("Animator")
    if config.PlayerMod.Enabled then
        SetWalkSpeed(config.PlayerMod.WalkSpeed)
    else
        ResetPlayerProperties()
    end
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
    local garden = workspace:FindFirstChild("Garden Of Dishonor")
    if not garden then return end
    local KEYSPOTS_ROOT = garden:FindFirstChild("KeySpots")
    if not KEYSPOTS_ROOT then return end
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
    local kyraht = workspace:FindFirstChild("Kyraht")
    if not kyraht then return end
    local beginArea = kyraht:FindFirstChild("BeginningArea")
    if not beginArea then return end
    local ROOT = beginArea:FindFirstChild("LadderSpawns")
    if not ROOT then return end
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

local FMH_Players = game:GetService("Players")
local FMH_LocalPlayer = FMH_Players.LocalPlayer
local FMH_RunService = game:GetService("RunService")
local FMH_UserInputService = game:GetService("UserInputService")
local FMH_Lighting = game:GetService("Lighting")

local function GetHealTool()
	local char = FMH_LocalPlayer.Character
	if not char then return nil end
	local tool = char:FindFirstChildOfClass("Tool")
	if tool and tool:FindFirstChild("HealPlayer") and tool:FindFirstChild("AddTags") then return tool end
	return nil
end

local function GetHealToolFromBackpack()
	local backpack = FMH_LocalPlayer:FindFirstChild("Backpack")
	if not backpack then return nil end
	for _, t in ipairs(backpack:GetChildren()) do
		if t:IsA("Tool") and t:FindFirstChild("HealPlayer") and t:FindFirstChild("AddTags") then return t end
	end
	return nil
end

local function EquipHealTool()
	local tool = GetHealTool()
	if tool then return tool end
	local bpTool = GetHealToolFromBackpack()
	if bpTool then
		local char = FMH_LocalPlayer.Character
		if char and char:FindFirstChildOfClass("Humanoid") then
			pcall(function() char.Humanoid:EquipTool(bpTool) end)
			task.wait(0.1)
			return GetHealTool()
		end
	end
	return nil
end

_G.OE_Script = {
    KillAura = {
        Enable = function() config.KillAura.Enabled = true; StartKillAura() end,
        Disable = function() config.KillAura.Enabled = false; StopKillAura() end,
        Toggle = function() config.KillAura.Enabled = not config.KillAura.Enabled; if config.KillAura.Enabled then StartKillAura() else StopKillAura() end end,
    },
    HitboxMod = {
        Enable = function() HB_SetEnabled(true) end,
        Disable = function() HB_SetEnabled(false) end,
        Toggle = function() HB_SetEnabled(not HitboxMod.Enabled) end,
        SetScale = function(val) HB_SetScale(val) end,
        ClearAll = function() HB_restoreAll() end
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
    HealToolUtil = {
        GetHealTool = function() return GetHealTool() end,
        GetHealToolFromBackpack = function() return GetHealToolFromBackpack() end,
        EquipHealTool = function() return EquipHealTool() end
    },
    AnimUtil = {
        RefreshChar = function() Anim_refreshChar() end,
        StopCurrent = function() Anim_stopCurrent() end,
        Play = function(name, looped, speed) Anim_play(name, looped, speed) end
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

local KA_HitboxSection = KillAuraTab:Section({Title = "碰撞箱修改"})
KA_HitboxSection:Toggle({
    Flag = "hitbox_mod_enable",
    Title = "启用碰撞箱修改",
    Default = HitboxMod.Enabled,
    Callback = function(state)
        HB_SetEnabled(state)
    end
})
KA_HitboxSection:Slider({
    Flag = "hitbox_scale",
    Title = "碰撞箱缩放倍率",
    Step = 0.25,
    Value = {Min=1,Max=10,Default=HitboxMod.Scale},
    Callback = function(val)
        HB_SetScale(val)
    end
})
KA_HitboxSection:Paragraph({
    Title = "提示",
    Desc = "仅对AliveZombies文件夹内僵尸生效；生成透明不可见Query部件，增大武器命中判定；关闭自动清理全部生成碰撞箱。"
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
    Title = "更多功能",
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

local AnimTab = Window:Tab({
    Title = "人物动作",
    Icon = "film"
})
local Anim_Section = AnimTab:Section({Title = "动画播放控制"})
local SelectedAnimName = AnimNameList[1]
local AnimLoopState = false
local AnimPlaySpeed = 1

Anim_Section:Dropdown({
    Flag = "anim_select",
    Text = "选择动画",
    Values = AnimNameList,
    Default = AnimNameList[1],
    Callback = function(val)
        SelectedAnimName = val
    end
})
Anim_Section:Toggle({
    Flag = "anim_loop",
    Title = "循环播放动画",
    Default = false,
    Callback = function(val)
        AnimLoopState = val
    end
})
Anim_Section:Slider({
    Flag = "anim_speed",
    Title = "动画播放速度",
    Step = 0.1,
    Value = {Min=0.1,Max=5,Default=1},
    Callback = function(val)
        AnimPlaySpeed = val
    end
})
Anim_Section:Button({
    Title = "播放选中动画",
    Icon = "play",
    Callback = function()
        Anim_play(SelectedAnimName, AnimLoopState, AnimPlaySpeed)
        WindUI:Notify({Title="人物动作", Content="开始播放动画："..SelectedAnimName, Icon="check"})
    end
})
Anim_Section:Button({
    Title = "停止当前动画",
    Icon = "square",
    Callback = function()
        Anim_stopCurrent()
        WindUI:Notify({Title="人物动作", Content="已停止播放动画", Icon="x"})
    end
})
Anim_Section:Paragraph({
    Title = "提示",
    Desc = "重生角色会自动刷新动画组件；动画优先级Action4，会覆盖大部分游戏原生动作。"
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
local ESP_Info = ESPTab:Section({Title = "说明信息"})
ESP_Info:Paragraph({
    Title = "使用说明",
    Desc = "钥匙：高亮耻辱花园内点位；梯子：填充高亮基拉特过桥后梯子模型，无描边方框。"
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
        HitboxMod.Enabled = false
        HB_stop()
        Anim_stopCurrent()

        config.KillAura.Enabled = false
        config.Block.Enabled = false
        config.Heal.Enabled = false
        config.KeySpotESP.Enabled = false
        config.LadderESP.Enabled = false
        config.PlayerMod.Enabled = false
        ToggleCustomWalkSpeed(false)

        StopKillAura()
        stopBlocking()
        StopHeal()
        ClearKeySpotESP()
        ClearLadderESP()
        ResetPlayerProperties()
        WindUI:Notify({Title="全局", Content="全部功能已关闭，人物属性已复原", Icon="check"})
    end
})
GL_Main:Button({
    Title = "销毁UI面板（全部功能失效）",
    Icon = "shredder",
    Callback = function()
        HitboxMod.Enabled = false
        HB_stop()
        Anim_stopCurrent()

        config.PlayerMod.Enabled = false
        ToggleCustomWalkSpeed(false)

        StopKillAura()
        stopBlocking()
        StopHeal()
        ClearKeySpotESP()
        ClearLadderESP()
        ResetPlayerProperties()
        Window:Destroy()
    end
})
local GL_Config = GlobalTab:Section({Title = "配置管理"})
GL_Config:Button({
    Title = "保存当前配置",
    Icon = "save",
    Callback = function()
        config.HitboxMod.Enabled = HitboxMod.Enabled
        config.HitboxMod.Scale = HitboxMod.Scale

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
            HitboxMod.Scale = config.HitboxMod.Scale
            HB_SetEnabled(config.HitboxMod.Enabled)

            WindUI:Notify({Title="配置", Content="配置加载成功", Icon="check"})
        end
    end
})
print("✅ 我们的处决脚本加载完成！")
print("🌐 全局API：_G.OE_Script")
