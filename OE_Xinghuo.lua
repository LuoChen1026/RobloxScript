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
    FullMapHeal = {
        Enabled = false,
        HealInterval = 0.5,
        HealThreshold = 100,
        FakeDistance = 0.5,
        AutoEquip = false
    },
    SelfHeal = {
        Enabled = false,
        HealInterval = 0.2,
        HealThreshold = 99,
        HealAmount = 90,
        StopThreshold = 100,
        AutoEquip = false
    },
    RapierKillAura = {
        Enabled = false,
        Range = 30,
        Interval = 0.5,
        AutoRotate = false,
        AutoEquip = false
    },
    MeleeKillAura = {
        Enabled = false,
        Range = 30,
        Interval = 0.5,
        AutoRotate = false,
        AutoEquip = false
    },
    RifleKillAura = {
        Enabled = false,
        Range = 300,
        Interval = 0.3,
        AutoRotate = false,
        AutoEquip = false,
        AutoReload = false,
        ReloadInterval = 2.5
    },
    MoveMod = {
        FlyEnabled = false,
        FlySpeed = 60,
        NoclipEnabled = false,
        HighlightEnabled = false
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
	config.HitboxMod.Enabled = state
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
	config.HitboxMod.Scale = val
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

local FMH_Players = game:GetService("Players")
local FMH_LocalPlayer = FMH_Players.LocalPlayer
local FMH_RunService = game:GetService("RunService")
local FMH_UserInputService = game:GetService("UserInputService")
local FMH_Lighting = game:GetService("Lighting")

local MoveMod = {
	FlyEnabled = false,
	FlySpeed = 60,
	NoclipEnabled = false,
	SpeedEnabled = false,
	SpeedValue = 30,
	HighlightEnabled = false,
}

local flyBV = nil
local flyConn = nil
local flyControl = nil
do
	local ok, module = pcall(function()
		return require(FMH_LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
	end)
	if ok and module then
		pcall(function() flyControl = module:GetControls() end)
	end
end

local function Fly_start()
	if flyConn then return end
	local char = FMH_LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end

	flyBV = Instance.new("BodyVelocity")
	flyBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	flyBV.P = 1250
	flyBV.Parent = hrp

	flyConn = FMH_RunService.RenderStepped:Connect(function()
		if not MoveMod.FlyEnabled or not flyBV or not flyBV.Parent then
			if flyConn then flyConn:Disconnect(); flyConn = nil end
			if flyBV then flyBV:Destroy(); flyBV = nil end
			return
		end

		local moveVec = Vector3.new(0, 0, 0)
		if flyControl then
			local ok2, mv = pcall(function() return flyControl:GetMoveVector() end)
			if ok2 and mv then moveVec = mv end
		else
			if FMH_UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + Vector3.new(0, 0, -1) end
			if FMH_UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec + Vector3.new(0, 0, 1) end
			if FMH_UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec + Vector3.new(-1, 0, 0) end
			if FMH_UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + Vector3.new(1, 0, 0) end
		end

		local cam = workspace.CurrentCamera
		local cf = cam.CFrame
		local dir = (cf.LookVector * -moveVec.Z) + (cf.RightVector * moveVec.X)

		if FMH_UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			dir = dir + Vector3.new(0, 1, 0)
		end
		if FMH_UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			dir = dir - Vector3.new(0, 1, 0)
		end

		if dir.Magnitude > 0 then
			flyBV.Velocity = dir.Unit * MoveMod.FlySpeed
		else
			flyBV.Velocity = Vector3.new(0, 0.1, 0)
		end
	end)
end

local function Fly_stop()
	if flyConn then flyConn:Disconnect(); flyConn = nil end
	if flyBV then flyBV:Destroy(); flyBV = nil end
end

local noclipConn = nil
local function Noclip_apply()
	local char = FMH_LocalPlayer.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then part.CanCollide = false end
	end
end

local function Noclip_start()
	if noclipConn then return end
	noclipConn = FMH_RunService.Stepped:Connect(function()
		if MoveMod.NoclipEnabled then pcall(Noclip_apply) end
	end)
end

local function Noclip_stop()
	if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
	local char = FMH_LocalPlayer.Character
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				pcall(function() part.CanCollide = true end)
			end
		end
	end
end

local Highlight_original = nil
local function Highlight_start()
	if MoveMod.HighlightEnabled then return end
	MoveMod.HighlightEnabled = true

	Highlight_original = {
		Brightness = FMH_Lighting.Brightness,
		ClockTime = FMH_Lighting.ClockTime,
		FogEnd = FMH_Lighting.FogEnd,
		FogStart = FMH_Lighting.FogStart,
		Ambient = FMH_Lighting.Ambient,
		OutdoorAmbient = FMH_Lighting.OutdoorAmbient,
		GlobalShadows = FMH_Lighting.GlobalShadows,
	}

	pcall(function()
		FMH_Lighting.Brightness = 3
		FMH_Lighting.ClockTime = 14
		FMH_Lighting.FogEnd = 100000
		FMH_Lighting.FogStart = 100000
		FMH_Lighting.Ambient = Color3.fromRGB(180, 180, 180)
		FMH_Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
		FMH_Lighting.GlobalShadows = false
	end)

	for _, v in ipairs(FMH_Lighting:GetChildren()) do
		if v:IsA("Atmosphere") then pcall(function() v:Destroy() end) end
	end
end

local function Highlight_stop()
	if not MoveMod.HighlightEnabled then return end
	MoveMod.HighlightEnabled = false
	if Highlight_original then
		pcall(function()
			FMH_Lighting.Brightness = Highlight_original.Brightness
			FMH_Lighting.ClockTime = Highlight_original.ClockTime
			FMH_Lighting.FogEnd = Highlight_original.FogEnd
			FMH_Lighting.FogStart = Highlight_original.FogStart
			FMH_Lighting.Ambient = Highlight_original.Ambient
			FMH_Lighting.OutdoorAmbient = Highlight_original.OutdoorAmbient
			FMH_Lighting.GlobalShadows = Highlight_original.GlobalShadows
		end)
	end
end

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

local FullMapHeal = {
	Enabled = false, HealInterval = 0.5, HealThreshold = 100,
	FakeDistance = 0.5, AutoEquip = false,
	Whitelist = {}, WhitelistEmpty = true, LoopRunning = false,
}

local function FMH_isWhitelisted(player)
	if FullMapHeal.WhitelistEmpty then return true end
	return FullMapHeal.Whitelist[player] == true
end

local function FMH_getTargets()
	local targets = {}
	for _, player in ipairs(FMH_Players:GetPlayers()) do
		if player ~= FMH_LocalPlayer and FMH_isWhitelisted(player) then
			local char = player.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 and hum.Health < FullMapHeal.HealThreshold then
					targets[#targets + 1] = player
				end
			end
		end
	end
	return targets
end

local function FMH_healTarget(player, healTool)
	if not healTool then return end
	local targetChar = player.Character
	if not targetChar then return end
	local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
	if not targetHum or targetHum.Health <= 0 or targetHum.Health >= FullMapHeal.HealThreshold then return end

	local myChar = FMH_LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end
	local fakePos = myRoot.Position + Vector3.new(0, FullMapHeal.FakeDistance, 0)

	local addTagsEvent = healTool:FindFirstChild("AddTags")
	local healPlayerEvent = healTool:FindFirstChild("HealPlayer")

	if addTagsEvent then pcall(function() addTagsEvent:FireServer(FMH_LocalPlayer, player, true) end) end
	if healPlayerEvent then pcall(function() healPlayerEvent:FireServer(fakePos, fakePos, 90, targetHum, true, FMH_LocalPlayer) end) end
	task.delay(0.2, function()
		if addTagsEvent then pcall(function() addTagsEvent:FireServer(FMH_LocalPlayer, player, false) end) end
	end)
end

local function FMH_start()
	if FullMapHeal.LoopRunning then return end
	FullMapHeal.LoopRunning = true
	task.spawn(function()
		while FullMapHeal.LoopRunning do
			task.wait(FullMapHeal.HealInterval)
			if not FullMapHeal.Enabled then continue end
			local tool = FullMapHeal.AutoEquip and EquipHealTool() or GetHealTool()
			if not tool then continue end
			for _, player in ipairs(FMH_getTargets()) do
				FMH_healTarget(player, tool)
				task.wait(0.1)
			end
		end
	end)
end
local function FMH_stop() FullMapHeal.LoopRunning = false end

local SelfHeal = {
	Enabled = false, HealInterval = 0.2, HealThreshold = 99,
	HealAmount = 90, StopThreshold = 100, AutoEquip = false,
	LoopRunning = false, isHealing = false,
}

local function SH_healSelf()
	if SelfHeal.isHealing then return end
	SelfHeal.isHealing = true

	local healTool = SelfHeal.AutoEquip and EquipHealTool() or GetHealTool()
	if not healTool then SelfHeal.isHealing = false; return end

	local myChar = FMH_LocalPlayer.Character
	if not myChar then SelfHeal.isHealing = false; return end
	local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
	local myRoot = myChar:FindFirstChild("HumanoidRootPart")
	if not myHumanoid or not myRoot then SelfHeal.isHealing = false; return end

	local addTagsEvent = healTool:FindFirstChild("AddTags")
	local healPlayerEvent = healTool:FindFirstChild("HealPlayer")

	task.spawn(function()
		if addTagsEvent then pcall(function() addTagsEvent:FireServer(FMH_LocalPlayer, FMH_LocalPlayer, true) end) end
		while SelfHeal.Enabled and myHumanoid.Health > 0 and myHumanoid.Health < SelfHeal.StopThreshold do
			local healPos = myRoot.Position
			if healPlayerEvent then
				pcall(function() healPlayerEvent:FireServer(healPos, healPos, SelfHeal.HealAmount, myHumanoid, true, FMH_LocalPlayer) end)
			end
			task.wait(SelfHeal.HealInterval)
		end
		if addTagsEvent then pcall(function() addTagsEvent:FireServer(FMH_LocalPlayer, FMH_LocalPlayer, false) end) end
		SelfHeal.isHealing = false
	end)
end

local function SH_start()
	if SelfHeal.LoopRunning then return end
	SelfHeal.LoopRunning = true
	task.spawn(function()
		while SelfHeal.LoopRunning do
			task.wait(SelfHeal.HealInterval)
			if not SelfHeal.Enabled then continue end
			local myChar = FMH_LocalPlayer.Character
			if not myChar then continue end
			local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
			if not myHumanoid or myHumanoid.Health <= 0 then continue end
			if myHumanoid.Health < SelfHeal.HealThreshold and not SelfHeal.isHealing then
				SH_healSelf()
			end
		end
	end)
end
local function SH_stop() SelfHeal.LoopRunning = false; SelfHeal.isHealing = false end

local RapierKillAura = {
	Enabled = false, Range = 30, Interval = 0.5,
	AutoRotate = false, AutoEquip = false,
	AttackParams = {"Aga", 1}, LoopRunning = false,
}

local function RKA_getWeapon()
	local char = FMH_LocalPlayer.Character; if not char then return nil end
	local tool = char:FindFirstChildOfClass("Tool")
	if tool and tool.Name == "Rapier" and tool:FindFirstChild("Swing") then return tool end
	local backpack = FMH_LocalPlayer:FindFirstChild("Backpack")
	if backpack then
		for _, t in ipairs(backpack:GetChildren()) do
			if t:IsA("Tool") and t.Name == "Rapier" and t:FindFirstChild("Swing") then return t end
		end
	end
	return nil
end

local function RKA_getNearestEnemy()
	local char = FMH_LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart"); if not root then return nil end
	local nearest, minDist = nil, RapierKillAura.Range
	local zf = workspace:FindFirstChild("AliveZombies")
	if zf then
		for _, obj in ipairs(zf:GetChildren()) do
			if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
				local hum = obj:FindFirstChild("Humanoid")
				if hum.Health > 0 then
					local tr = obj:FindFirstChild("HumanoidRootPart")
					local dist = (tr.Position - root.Position).Magnitude
					if dist < minDist then minDist = dist; nearest = obj end
				end
			end
		end
	end
	if not nearest then
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
				local hum = obj:FindFirstChild("Humanoid")
				if hum.Health > 0 and not FMH_Players:GetPlayerFromCharacter(obj) then
					local tr = obj:FindFirstChild("HumanoidRootPart")
					local dist = (tr.Position - root.Position).Magnitude
					if dist < minDist then minDist = dist; nearest = obj end
				end
			end
		end
	end
	return nearest
end

local function RKA_attack(enemy, weapon)
	local swing = weapon:FindFirstChild("Swing"); if not swing then return end
	local char = FMH_LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local tr = enemy and enemy:FindFirstChild("HumanoidRootPart")
	if not root or not tr then return end
	if RapierKillAura.AutoRotate then
		local dir = (tr.Position - root.Position).Unit
		root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(dir.X, 0, dir.Z))
	end
	pcall(function() swing:FireServer(unpack(RapierKillAura.AttackParams)) end)
end

local function RKA_start()
	if RapierKillAura.LoopRunning then return end
	RapierKillAura.LoopRunning = true
	task.spawn(function()
		while RapierKillAura.LoopRunning do
			task.wait(RapierKillAura.Interval)
			if not RapierKillAura.Enabled then continue end
			local char = FMH_LocalPlayer.Character
			if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
			local weapon = RKA_getWeapon(); if not weapon then continue end
			if RapierKillAura.AutoEquip and weapon.Parent == FMH_LocalPlayer.Backpack then
				pcall(function() char.Humanoid:EquipTool(weapon) end); task.wait(0.1)
			end
			local enemy = RKA_getNearestEnemy()
			if enemy then RKA_attack(enemy, weapon) end
		end
	end)
end
local function RKA_stop() RapierKillAura.LoopRunning = false end

local MeleeKillAura = {
	Enabled = false, Range = 30, Interval = 0.5,
	AutoRotate = false, AutoEquip = false, LoopRunning = false,
}

local function MKA_getWeapon()
	local char = FMH_LocalPlayer.Character; if not char then return nil end
	local tool = char:FindFirstChildOfClass("Tool")
	if tool and tool:FindFirstChild("Swing") then return tool end
	for _, t in ipairs(FMH_LocalPlayer.Backpack:GetChildren()) do
		if t:IsA("Tool") and t:FindFirstChild("Swing") then return t end
	end
	return nil
end

local function MKA_getNearestEnemy()
	local char = FMH_LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart"); if not root then return nil end
	local nearest, minDist = nil, MeleeKillAura.Range
	local zf = workspace:FindFirstChild("AliveZombies")
	if zf then
		for _, obj in ipairs(zf:GetChildren()) do
			if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
				local hum = obj:FindFirstChild("Humanoid")
				if hum.Health > 0 then
					local tr = obj:FindFirstChild("HumanoidRootPart")
					local dist = (tr.Position - root.Position).Magnitude
					if dist < minDist then minDist = dist; nearest = obj end
				end
			end
		end
	end
	if not nearest then
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
				local hum = obj:FindFirstChild("Humanoid")
				if hum.Health > 0 and not FMH_Players:GetPlayerFromCharacter(obj) then
					local tr = obj:FindFirstChild("HumanoidRootPart")
					local dist = (tr.Position - root.Position).Magnitude
					if dist < minDist then minDist = dist; nearest = obj end
				end
			end
		end
	end
	return nearest
end

local function MKA_attack(enemy, weapon)
	local swing = weapon:FindFirstChild("Swing"); if not swing then return end
	local char = FMH_LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local tr = enemy and enemy:FindFirstChild("HumanoidRootPart")
	if not root or not tr then return end
	if MeleeKillAura.AutoRotate then
		local dir = (tr.Position - root.Position).Unit
		root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(dir.X, 0, dir.Z))
	end
	pcall(function() swing:FireServer(1) end)
end

local function MKA_start()
	if MeleeKillAura.LoopRunning then return end
	MeleeKillAura.LoopRunning = true
	task.spawn(function()
		while MeleeKillAura.LoopRunning do
			task.wait(MeleeKillAura.Interval)
			if not MeleeKillAura.Enabled then continue end
			local char = FMH_LocalPlayer.Character
			if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
			local weapon = MKA_getWeapon(); if not weapon then continue end
			if MeleeKillAura.AutoEquip and weapon.Parent == FMH_LocalPlayer.Backpack then
				pcall(function() char.Humanoid:EquipTool(weapon) end); task.wait(0.1)
			end
			local enemy = MKA_getNearestEnemy()
			if enemy then MKA_attack(enemy, weapon) end
		end
	end)
end
local function MKA_stop() MeleeKillAura.LoopRunning = false end

local RifleKillAura = {
	Enabled = false, Range = 300, Interval = 0.3,
	AutoRotate = false, AutoEquip = false,
	AutoReload = false, ReloadInterval = 2.5, LastReload = 0,
	LoopRunning = false, Targets = {},
}

local RKA_targetNames = {
	"Walker", "Runner", "ZombieEngineer", "Prowler",
	"PugerlyMusician", "DefencelessCivilian", "MateoDupont",
	"Marksman", "EnemyPugrelian", "JollyLurker",
	"PugrelianDread", "PugrelianOfficer", "Defector",
}

local RKA_targetNameCN = {
	Walker = "步行者",
	Runner = "奔跑者",
	ZombieEngineer = "僵尸工程师",
	Prowler = "潜行者",
	PugerlyMusician = "音乐家僵尸",
	DefencelessCivilian = "无防御平民",
	MateoDupont = "马特奥·杜邦",
	Marksman = "神射手",
	EnemyPugrelian = "敌方普格瑞利安",
	JollyLurker = "欢乐潜伏者",
	PugrelianDread = "普格瑞利安·恐惧",
	PugrelianOfficer = "普格瑞利安·军官",
	Defector = "叛逃者",
}

for _, n in ipairs(RKA_targetNames) do RifleKillAura.Targets[n] = false end

local function RKA_nameMatches(name)
	for targetName, enabled in pairs(RifleKillAura.Targets) do
		if enabled then
			if name == targetName or name:sub(1, #targetName) == targetName then return true end
		end
	end
	return false
end

local function RKA_isEnabledTarget(obj)
	if RKA_nameMatches(obj.Name) then return true end
	local parent = obj.Parent
	if parent and parent.Name == "AliveZombies" then
		for targetName, enabled in pairs(RifleKillAura.Targets) do
			if enabled then
				if obj.Name == targetName or obj.Name:sub(1, #targetName) == targetName then
					return true
				end
			end
		end
	end
	return false
end

local function RKA_rifle_getWeapon()
	local char = FMH_LocalPlayer.Character; if not char then return nil end
	local tool = char:FindFirstChildOfClass("Tool")
	if tool and tool:FindFirstChild("Firing") then return tool end
	local backpack = FMH_LocalPlayer:FindFirstChild("Backpack")
	if backpack then
		for _, t in ipairs(backpack:GetChildren()) do
			if t:IsA("Tool") and t:FindFirstChild("Firing") then return t end
		end
	end
	return nil
end

local function RKA_rifle_isValidTarget(obj)
	if obj.ClassName ~= "Model" then return false end
	if not RKA_isEnabledTarget(obj) then return false end
	if FMH_Players:GetPlayerFromCharacter(obj) then return false end
	local hum = obj:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	if not obj:FindFirstChild("HumanoidRootPart") then return false end
	return true
end

local function RKA_rifle_getNearestEnemy()
	local char = FMH_LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart"); if not root then return nil end
	local nearest, minDist = nil, RifleKillAura.Range

	local zf = workspace:FindFirstChild("AliveZombies")
	local scanList = zf and zf:GetChildren() or {}
	for _, obj in ipairs(scanList) do
		if RKA_rifle_isValidTarget(obj) then
			local hrp = obj:FindFirstChild("HumanoidRootPart")
			local dist = (hrp.Position - root.Position).Magnitude
			if dist < minDist then minDist = dist; nearest = obj end
		end
	end

	if not nearest then
		for _, obj in ipairs(workspace:GetDescendants()) do
			if RKA_rifle_isValidTarget(obj) then
				local hrp = obj:FindFirstChild("HumanoidRootPart")
				local dist = (hrp.Position - root.Position).Magnitude
				if dist < minDist then minDist = dist; nearest = obj end
			end
		end
	end

	if type(getnilinstances) == "function" then
		pcall(function()
			for _, obj in next, getnilinstances() do
				if RKA_rifle_isValidTarget(obj) then
					local hrp = obj:FindFirstChild("HumanoidRootPart")
					local dist = (hrp.Position - root.Position).Magnitude
					if dist < minDist then minDist = dist; nearest = obj end
				end
			end
		end)
	end

	return nearest
end

local function RKA_rifle_tryReload(weapon)
	if not weapon then return false end
	local attemptReload = weapon:FindFirstChild("AttemptReload")
	if attemptReload then
		pcall(function() attemptReload:FireServer() end)
		return true
	end
	return false
end

local function RKA_rifle_getAmmo(weapon)
	if not weapon then return nil end
	local ok, ammo = pcall(function() return weapon:GetAttribute("Ammo") end)
	if ok then return ammo end
	return nil
end

local function RKA_rifle_attack(enemy, weapon)
	local firing = weapon:FindFirstChild("Firing"); if not firing then return end
	local char = FMH_LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local targetRoot = enemy and enemy:FindFirstChild("HumanoidRootPart")
	if not root or not targetRoot then return end

	if RifleKillAura.AutoRotate then
		local dir = (targetRoot.Position - root.Position).Unit
		root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(dir.X, 0, dir.Z))
	end

	local fireArea = weapon:FindFirstChild("Handle")
		and weapon.Handle:FindFirstChild("Grip2")
		and weapon.Handle.Grip2:FindFirstChild("FireArea")
	local origin = (fireArea and fireArea.WorldPosition) or root.Position
	local direction = (targetRoot.Position - origin).Unit

	local filterList = {char}
	if workspace:FindFirstChild("Buildings") then table.insert(filterList, workspace.Buildings) end
	if workspace:FindFirstChild("Corpses") then table.insert(filterList, workspace.Corpses) end
	if workspace:FindFirstChild("AlivePlayers") then table.insert(filterList, workspace.AlivePlayers) end

	pcall(function()
		firing:FireServer(origin, direction, filterList, targetRoot)
	end)
end

local function RKA_rifle_start()
	if RifleKillAura.LoopRunning then return end
	RifleKillAura.LoopRunning = true
	task.spawn(function()
		while RifleKillAura.LoopRunning do
			task.wait(RifleKillAura.Interval)
			if not RifleKillAura.Enabled then continue end
			local char = FMH_LocalPlayer.Character
			if not char or not char:FindFirstChild("HumanoidRootPart") then continue end

			local weapon = RKA_rifle_getWeapon()
			if not weapon then continue end

			if RifleKillAura.AutoEquip and weapon.Parent == FMH_LocalPlayer.Backpack then
				pcall(function() char.Humanoid:EquipTool(weapon) end)
				task.wait(0.1)
			end

			if RifleKillAura.AutoReload then
				local ammo = RKA_rifle_getAmmo(weapon)
				if ammo ~= nil and ammo <= 0 then
					if tick() - RifleKillAura.LastReload >= RifleKillAura.ReloadInterval then
						RifleKillAura.LastReload = tick()
						RKA_rifle_tryReload(weapon)
					end
					continue
				end
			end

			local enemy = RKA_rifle_getNearestEnemy()
			if enemy then RKA_rifle_attack(enemy, weapon) end
		end
	end)
end
local function RKA_rifle_stop() RifleKillAura.LoopRunning = false end

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

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    animator = humanoid:WaitForChild("Animator")
    Fly_stop()
    Noclip_stop()
    if config.PlayerMod.Enabled then
        SetWalkSpeed(config.PlayerMod.WalkSpeed)
    else
        ResetPlayerProperties()
    end
    stopBlocking()
    StopHeal()
    FMH_stop()
    SH_stop()
    RKA_stop()
    MKA_stop()
    RKA_rifle_stop()
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
    FullMapHeal = {
        Enable = function() FullMapHeal.Enabled = true; FMH_start() end,
        Disable = function() FullMapHeal.Enabled = false; FMH_stop() end,
        Toggle = function() FullMapHeal.Enabled = not FullMapHeal.Enabled; if FullMapHeal.Enabled then FMH_start() else FMH_stop() end end
    },
    SelfHeal = {
        Enable = function() SelfHeal.Enabled = true; SH_start() end,
        Disable = function() SelfHeal.Enabled = false; SH_stop() end,
        Toggle = function() SelfHeal.Enabled = not SelfHeal.Enabled; if SelfHeal.Enabled then SH_start() else SH_stop() end end
    },
    RapierKillAura = {
        Enable = function() RapierKillAura.Enabled = true; RKA_start() end,
        Disable = function() RapierKillAura.Enabled = false; RKA_stop() end,
        Toggle = function() RapierKillAura.Enabled = not RapierKillAura.Enabled; if RapierKillAura.Enabled then RKA_start() else RKA_stop() end end
    },
    MeleeKillAura = {
        Enable = function() MeleeKillAura.Enabled = true; MKA_start() end,
        Disable = function() MeleeKillAura.Enabled = false; MKA_stop() end,
        Toggle = function() MeleeKillAura.Enabled = not MeleeKillAura.Enabled; if MeleeKillAura.Enabled then MKA_start() else MKA_stop() end end
    },
    RifleKillAura = {
        Enable = function() RifleKillAura.Enabled = true; RKA_rifle_start() end,
        Disable = function() RifleKillAura.Enabled = false; RKA_rifle_stop() end,
        Toggle = function() RifleKillAura.Enabled = not RifleKillAura.Enabled; if RifleKillAura.Enabled then RKA_rifle_start() else RKA_rifle_stop() end end
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
    MoveMod = {
        ToggleFly = function() MoveMod.FlyEnabled = not MoveMod.FlyEnabled; if MoveMod.FlyEnabled then Fly_start() else Fly_stop() end end,
        ToggleNoclip = function() MoveMod.NoclipEnabled = not MoveMod.NoclipEnabled; if MoveMod.NoclipEnabled then Noclip_start() else Noclip_stop() end end,
        ToggleLight = function() MoveMod.HighlightEnabled = not MoveMod.HighlightEnabled; if MoveMod.HighlightEnabled then Highlight_start() else Highlight_stop() end end,
        SetFlySpeed = function(speed) MoveMod.FlySpeed = speed end
    },
    AnimPlayer = {
        ToggleAnim = function() AnimPlayer.Enabled = not AnimPlayer.Enabled; if AnimPlayer.Enabled then Anim_refreshChar() else Anim_stopCurrent() end end,
        PlayAnim = function(name, looped, speed) Anim_play(name, looped, speed) end
    },
    FullMapHealToggle = function() FullMapHeal.Enabled = not FullMapHeal.Enabled; if FullMapHeal.Enabled then FMH_start() else FMH_stop() end end,
    SelfHealToggle = function() SelfHeal.Enabled = not SelfHeal.Enabled; if SelfHeal.Enabled then SH_start() else SH_stop() end end
}

local Window = WindUI:CreateWindow({
    Title = "OE Script",
    Icon = "rbxassetid://14730439020",
    Folder = "OESave",
    Keybind = Enum.KeyCode.RightShift,
})

local AttackTab = Window:Tab({
    Title = "攻击功能",
    Icon = "sword"
})

local KA_Main = AttackTab:Section({Title = "原版近战杀戮光环｜基础设置"})
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

local KA_HitboxSection = AttackTab:Section({Title = "原版近战杀戮光环｜怪物Hitbox判定修改"})
KA_HitboxSection:Toggle({
    Flag = "hitbox_mod_enable",
    Title = "启用怪物超大判定盒",
    Default = HitboxMod.Enabled,
    Callback = function(state)
        HB_SetEnabled(state)
    end
})
KA_HitboxSection:Slider({
    Flag = "hitbox_scale",
    Title = "Hitbox缩放倍率",
    Step = 0.25,
    Value = {Min=1,Max=10,Default=HitboxMod.Scale},
    Callback = function(val)
        HB_SetScale(val)
    end
})
KA_HitboxSection:Paragraph({
    Title = "提示",
    Desc = "仅对AliveZombies文件夹内僵尸生效；生成透明不可见Query部件，增大武器命中判定；关闭自动清理全部生成部件。"
})

local KA_Info = AttackTab:Section({Title = "原版近战杀戮光环｜说明信息"})
KA_Info:Paragraph({
    Title = "使用说明",
    Desc = "优先扫描存活僵尸文件夹；若无，则遍历全地图非玩家实体。武器必须带有挥动远程事件，支持自动从背包装备。"
})

local RKA_Section = AttackTab:Section({Title="细剑杀戮光环"})
RKA_Section:Toggle({
    Flag = "rapier_kill_aura_enable",
    Title = "启用细剑杀戮光环",
    Default = RapierKillAura.Enabled,
    Callback = function(state)
        RapierKillAura.Enabled = state
        if state then RKA_start() else RKA_stop() end
        WindUI:Notify({Title="细剑杀戮光环", Content = state and "已开启" or "已关闭", Icon = state and "check" or "x"})
    end
})
RKA_Section:Toggle({
    Flag = "rapier_autorotate",
    Title = "自动转向敌人",
    Default = RapierKillAura.AutoRotate,
    Callback = function(state) RapierKillAura.AutoRotate = state end
})
RKA_Section:Toggle({
    Flag = "rapier_autoequip",
    Title = "自动装备武器",
    Default = RapierKillAura.AutoEquip,
    Callback = function(state) RapierKillAura.AutoEquip = state end
})
RKA_Section:Slider({
    Flag = "rapier_range",
    Title = "攻击范围",
    Step = 1,
    Value = {Min=5,Max=100,Default=RapierKillAura.Range},
    Callback = function(val) RapierKillAura.Range = val end
})
RKA_Section:Slider({
    Flag = "rapier_interval",
    Title = "攻击间隔",
    Step = 0.05,
    Value = {Min=0.1,Max=3,Default=RapierKillAura.Interval},
    Callback = function(val) RapierKillAura.Interval = val end
})

local MKA_Section = AttackTab:Section({Title="通用近战杀戮光环"})
MKA_Section:Toggle({
    Flag = "melee_kill_aura_enable",
    Title = "启用通用近战杀戮光环",
    Default = MeleeKillAura.Enabled,
    Callback = function(state)
        MeleeKillAura.Enabled = state
        if state then MKA_start() else MKA_stop() end
        WindUI:Notify({Title="通用近战杀戮光环", Content = state and "已开启" or "已关闭", Icon = state and "check" or "x"})
    end
})
MKA_Section:Toggle({
    Flag = "melee_autorotate",
    Title = "自动转向敌人",
    Default = MeleeKillAura.AutoRotate,
    Callback = function(state) MeleeKillAura.AutoRotate = state end
})
MKA_Section:Toggle({
    Flag = "melee_autoequip",
    Title = "自动装备武器",
    Default = MeleeKillAura.AutoEquip,
    Callback = function(state) MeleeKillAura.AutoEquip = state end
})
MKA_Section:Slider({
    Flag = "melee_range",
    Title = "攻击范围",
    Step = 1,
    Value = {Min=5,Max=100,Default=MeleeKillAura.Range},
    Callback = function(val) MeleeKillAura.Range = val end
})
MKA_Section:Slider({
    Flag = "melee_interval",
    Title = "攻击间隔",
    Step = 0.05,
    Value = {Min=0.1,Max=3,Default=MeleeKillAura.Interval},
    Callback = function(val) MeleeKillAura.Interval = val end
})

local RFA_Section = AttackTab:Section({Title="步枪远程杀戮光环"})
RFA_Section:Toggle({
    Flag = "rifle_kill_aura_enable",
    Title = "启用步枪远程杀戮光环",
    Default = RifleKillAura.Enabled,
    Callback = function(state)
        RifleKillAura.Enabled = state
        if state then RKA_rifle_start() else RKA_rifle_stop() end
        WindUI:Notify({Title="步枪远程杀戮光环", Content = state and "已开启" or "已关闭", Icon = state and "check" or "x"})
    end
})
RFA_Section:Toggle({
    Flag = "rifle_autorotate",
    Title = "自动转向敌人",
    Default = RifleKillAura.AutoRotate,
    Callback = function(state) RifleKillAura.AutoRotate = state end
})
RFA_Section:Toggle({
    Flag = "rifle_autoequip",
    Title = "自动装备武器",
    Default = RifleKillAura.AutoEquip,
    Callback = function(state) RifleKillAura.AutoEquip = state end
})
RFA_Section:Toggle({
    Flag = "rifle_autoreload",
    Title = "自动换弹",
    Default = RifleKillAura.AutoReload,
    Callback = function(state) RifleKillAura.AutoReload = state end
})
RFA_Section:Slider({
    Flag = "rifle_range",
    Title = "攻击范围",
    Step = 5,
    Value = {Min=20,Max=500,Default=RifleKillAura.Range},
    Callback = function(val) RifleKillAura.Range = val end
})
RFA_Section:Slider({
    Flag = "rifle_interval",
    Title = "攻击间隔",
    Step = 0.05,
    Value = {Min=0.1,Max=2,Default=RifleKillAura.Interval},
    Callback = function(val) RifleKillAura.Interval = val end
})
RFA_Section:Slider({
    Flag = "rifle_reloadinterval",
    Title = "换弹冷却",
    Step = 0.1,
    Value = {Min=1,Max=10,Default=RifleKillAura.ReloadInterval},
    Callback = function(val) RifleKillAura.ReloadInterval = val end
})
local targetList = {}
for _,name in ipairs(RKA_targetNames) do
    table.insert(targetList,RKA_targetNameCN[name])
end
RFA_Section:Dropdown({
    Flag = "rifle_targets",
    Text = "目标类型勾选",
    Multi = true,
    Values = targetList,
    Callback = function(selectedArr)
        for _,n in ipairs(RKA_targetNames) do
            RifleKillAura.Targets[n] = false
        end
        for _,cn in ipairs(selectedArr) do
            local enKey = nil
            for k,v in pairs(RKA_targetNameCN) do
                if v == cn then enKey = k break end
            end
            if enKey then RifleKillAura.Targets[enKey]=true end
        end
    end
})

local BlockTab = Window:Tab({
    Title = "格挡功能",
    Icon = "shield"
})
local BlockSection = BlockTab:Section({Title="格挡设置"})
BlockSection:Toggle({
    Flag = "block_enable",
    Title = "启用Sabre格挡",
    Default = config.Block.Enabled,
    Callback = function(state)
        config.Block.Enabled = state
        local tool = character:FindFirstChildOfClass("Tool")
        if state then
            WindUI:Notify({Title="格挡", Content="已开启", Icon="check"})
            if tool and tool.Name == "Sabre" then startBlockCycle(tool) end
        else
            stopBlocking()
            WindUI:Notify({Title="格挡", Content="已关闭", Icon="x"})
        end
    end
})
BlockSection:Slider({
    Flag = "block_anim_speed",
    Title = "格挡动画速度",
    Step = 0.5,
    Value = {Min=1,Max=50,Default=config.Block.AnimSpeed},
    Callback = function(val)
        config.Block.AnimSpeed = val
    end
})

local HealTab = Window:Tab({
    Title = "治疗功能",
    Icon = "heart"
})
local HealSection = HealTab:Section({Title="全图队友治疗"})
HealSection:Toggle({
    Flag = "heal_enable",
    Title = "启用全图治疗",
    Default = config.Heal.Enabled,
    Callback = function(state)
        config.Heal.Enabled = state
        if state then StartHeal() else StopHeal() end
        WindUI:Notify({Title="全图治疗", Content = state and "已开启" or "已关闭", Icon = state and "check" or "x"})
    end
})
HealSection:Slider({
    Flag = "heal_interval",
    Title = "治疗间隔",
    Step = 0.05,
    Value = {Min=0.1,Max=3,Default=config.Heal.HealInterval},
    Callback = function(val) config.Heal.HealInterval = val end
})
HealSection:Slider({
    Flag = "heal_threshold",
    Title = "低于血量阈值才治疗",
    Step = 1,
    Value = {Min=1,Max=100,Default=config.Heal.HealThreshold},
    Callback = function(val) config.Heal.HealThreshold = val end
})

local FullMapHealSection = HealTab:Section({Title="新版全图治疗"})
FullMapHealSection:Toggle({
    Flag = "fmh_enable",
    Title = "启用新版全图治疗",
    Default = FullMapHeal.Enabled,
    Callback = function(state)
        FullMapHeal.Enabled = state
        if state then FMH_start() else FMH_stop() end
        WindUI:Notify({Title="新版全图治疗", Content = state and "已开启" or "已关闭", Icon = state and "check" or "x"})
    end
})
FullMapHealSection:Toggle({
    Flag = "fmh_autoequip",
    Title = "自动装备治疗工具",
    Default = FullMapHeal.AutoEquip,
    Callback = function(state) FullMapHeal.AutoEquip = state end
})
FullMapHealSection:Slider({
    Flag = "fmh_interval",
    Title = "治疗间隔",
    Step = 0.05,
    Value = {Min=0.1,Max=3,Default=FullMapHeal.HealInterval},
    Callback = function(val) FullMapHeal.HealInterval = val end
})
FullMapHealSection:Slider({
    Flag = "fmh_threshold",
    Title = "血量阈值",
    Step = 1,
    Value = {Min=1,Max=100,Default=FullMapHeal.HealThreshold},
    Callback = function(val) FullMapHeal.HealThreshold = val end
})

local SelfHealSection = HealTab:Section({Title="自我治疗"})
SelfHealSection:Toggle({
    Flag = "sh_enable",
    Title = "启用自我治疗",
    Default = SelfHeal.Enabled,
    Callback = function(state)
        SelfHeal.Enabled = state
        if state then SH_start() else SH_stop() end
        WindUI:Notify({Title="自我治疗", Content = state and "已开启" or "已关闭", Icon = state and "check" or "x"})
    end
})
SelfHealSection:Toggle({
    Flag = "sh_autoequip",
    Title = "自动装备治疗工具",
    Default = SelfHeal.AutoEquip,
    Callback = function(state) SelfHeal.AutoEquip = state end
})
SelfHealSection:Slider({
    Flag = "sh_interval",
    Title = "治疗间隔",
    Step = 0.05,
    Value = {Min=0.1,Max=3,Default=SelfHeal.HealInterval},
    Callback = function(val) SelfHeal.HealInterval = val end
})
SelfHealSection:Slider({
    Flag = "sh_healthreshold",
    Title = "低于该血量开始治疗",
    Step = 1,
    Value = {Min=1,Max=100,Default=SelfHeal.HealThreshold},
    Callback = function(val) SelfHeal.HealThreshold = val end
})
SelfHealSection:Slider({
    Flag = "sh_healamount",
    Title = "单次治疗量",
    Step = 1,
    Value = {Min=1,Max=100,Default=SelfHeal.HealAmount},
    Callback = function(val) SelfHeal.HealAmount = val end
})
SelfHealSection:Slider({
    Flag = "sh_stopthreshold",
    Title = "到达该血量停止治疗",
    Step = 1,
    Value = {Min=1,Max=100,Default=SelfHeal.StopThreshold},
    Callback = function(val) SelfHeal.StopThreshold = val end
})

local AnimTab = Window:Tab({
    Title = "人物动画",
    Icon = "dance"
})
local AnimSection = AnimTab:Section({Title="动画播放"})
AnimSection:Toggle({
    Flag = "anim_enable",
    Title = "启用动画模块",
    Default = AnimPlayer.Enabled,
    Callback = function(state)
        AnimPlayer.Enabled = state
        if state then
            Anim_refreshChar()
            WindUI:Notify({Title="动画", Content="动画模块已启用", Icon="check"})
        else
            Anim_stopCurrent()
            WindUI:Notify({Title="动画", Content="动画模块已关闭", Icon="x"})
        end
    end
})
AnimSection:Dropdown({
    Flag = "anim_select",
    Text = "选择动画",
    Values = AnimNameList,
    Callback = function(selected)
        AnimPlayer.Selected = selected
    end
})
AnimSection:Toggle({
    Flag = "anim_loop",
    Title = "循环播放",
    Default = true,
})
AnimSection:Slider({
    Flag = "anim_speed",
    Title = "动画速度",
    Step = 0.1,
    Value = {Min=0.1,Max=10,Default=1},
})
AnimSection:Button({
    Title = "播放选中动画",
    Callback = function()
        local looped = WindUI:GetFlagValue("anim_loop")
        local speed = WindUI:GetFlagValue("anim_speed")
        Anim_play(AnimPlayer.Selected, looped, speed)
    end
})
AnimSection:Button({
    Title = "停止动画",
    Callback = function()
        Anim_stopCurrent()
    end
})

local MoveTab = Window:Tab({
    Title = "移动功能",
    Icon = "walk"
})
local MoveSection = MoveTab:Section({Title="移动设置"})
MoveSection:Toggle({
    Flag = "fly_enable",
    Title = "飞行",
    Default = MoveMod.FlyEnabled,
    Callback = function(state)
        MoveMod.FlyEnabled = state
        if state then Fly_start() else Fly_stop() end
        WindUI:Notify({Title="飞行", Content = state and "已开启" or "已关闭", Icon = state and "check" or "x"})
    end
})
MoveSection:Slider({
    Flag = "fly_speed",
    Title = "飞行速度",
    Step = 1,
    Value = {Min=10,Max=200,Default=MoveMod.FlySpeed},
    Callback = function(val) MoveMod.FlySpeed = val end
})
MoveSection:Toggle({
    Flag = "noclip_enable",
    Title = "穿墙(Noclip)",
    Default = MoveMod.NoclipEnabled,
    Callback = function(state)
        MoveMod.NoclipEnabled = state
        if state then Noclip_start() else Noclip_stop() end
        WindUI:Notify({Title="穿墙", Content = state and "已开启" or "已关闭", Icon = state and "check" or "x"})
    end
})
MoveSection:Toggle({
    Flag = "light_enable",
    Title = "全局高亮照明",
    Default = MoveMod.HighlightEnabled,
    Callback = function(state)
        MoveMod.HighlightEnabled = state
        if state then Highlight_start() else Highlight_stop() end
        WindUI:Notify({Title="全局照明", Content = state and "已开启" or "已关闭", Icon = state and "check" or "x"})
    end
})

local PlayerTab = Window:Tab({
    Title = "人物功能",
    Icon = "user"
})
local PlayerSection = PlayerTab:Section({Title="人物属性"})
PlayerSection:Toggle({
    Flag = "player_ws_enable",
    Title = "自定义移速",
    Default = config.PlayerMod.Enabled,
    Callback = function(state)
        ToggleCustomWalkSpeed(state)
    end
})
PlayerSection:Slider({
    Flag = "player_ws",
    Title = "移动速度",
    Step = 1,
    Value = {Min=1,Max=200,Default=config.PlayerMod.WalkSpeed},
    Callback = function(val)
        config.PlayerMod.WalkSpeed = val
        if config.PlayerMod.Enabled then
            SetWalkSpeed(val)
        end
    end
})

local ESPTab = Window:Tab({
    Title = "ESP透视",
    Icon = "eye"
})
local ESPSpotSection = ESPTab:Section({Title="点位透视"})
ESPSpotSection:Toggle({
    Flag = "esp_keyspot",
    Title = "钥匙点位ESP",
    Default = config.KeySpotESP.Enabled,
    Callback = function(state)
        ToggleKeySpotESP(state)
    end
})
ESPSpotSection:Toggle({
    Flag = "esp_ladder",
    Title = "梯子点位ESP",
    Default = config.LadderESP.Enabled,
    Callback = function(state)
        ToggleLadderESP(state)
    end
})

Window:SelectTab(AttackTab)
