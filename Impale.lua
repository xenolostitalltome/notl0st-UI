--!strict
-- Services

-- 
local MainModule = require(game.ServerScriptService.MainModule)

-- Declarations
local module = {}

-- Types
local drainTime = 3
local tickFreq = 0.3

--//Variables
local ServerScript = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local changedparts = {}
local effects = {}

--// Modules
local Utility = require(ServerScript.Modules.Utility)

--// Functions
local function Clean()
	for a, b in pairs(changedparts) do
		b.Transparency = 0
	end
	for a, b in pairs(effects) do
		b:Destroy()
	end
end

module.fire = function(player: Player)
	local character = player.Character :: any
	local FoundPlayers = {}
	
	if not character then
		return
	end
	
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
	if not humanoid then
		return
	end
	
	local Sword = character:FindFirstChild("Sword") :: any
	
	if not Sword then
		return
	end
	
	local swordAttach = Sword:FindFirstChild("StabAlign") :: any & BasePart
	
	if not swordAttach then
		return
	end
	
	local hrp = character:FindFirstChild("HumanoidRootPart") :: Part
	
	if not hrp then
		return
	end
	
	local animator = humanoid:FindFirstChild("Animator") :: Animator
	
	if not animator then
		return
	end
	
	--// Dash
	local BV = Instance.new("BodyVelocity")
	BV.Name = "ThurstVelocity"
	BV.Parent = character.Torso
	BV.MaxForce = Vector3.new(10^5, 0, 10^5)
	BV.Velocity = hrp.CFrame.LookVector * 80
	Utility:Debris(BV, 0.4)
	
	--// Hitbox
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include 
	overlapParams.FilterDescendantsInstances = {unpack(CollectionService:GetTagged("Character"))}
	
	local HurtBox = Utility:CreateMeleeHitbox(hrp, CFrame.new(0, 0, -2.25), Vector3.new(6.5, 4.5, 4.5))
	HurtBox.Name = "ImpaleHitbox"
	HurtBox.Transparency = 1
	Utility:Debris(HurtBox, 1)
	
	--// Stab in front of user
	local ImpaleAnim = animator:LoadAnimation(script.Animations.Impale)
	ImpaleAnim:Play()
	effects[#effects + 1] = ImpaleAnim

	local disable = Instance.new("BoolValue")
	disable.Name = "Disable"
	disable.Parent = character
	effects[#effects + 1] = disable :: any
	local tDisable = Instance.new("BoolValue")
	tDisable.Name = "TrueDisable"
	tDisable.Parent = character
	effects[#effects + 1] = tDisable :: any
	local NoAttack = Instance.new("BoolValue")
	NoAttack.Name = "NoAttack"
	NoAttack.Parent = character
	effects[#effects + 1] = NoAttack :: any
	character:SetAttribute("Intangibility", true)
	
	local function Cleanup()
		ImpaleAnim:Stop()
	end
	
	task.spawn(function()
		while HurtBox.Parent do
			RunService.Stepped:Wait()
			local hitbox = workspace:GetPartsInPart(HurtBox, overlapParams)
			local hit = false

			for i,v in pairs(hitbox) do
				if hit then return end
				
				if v.Parent:FindFirstChild("Humanoid") then
					if v.Parent ~= character then
						if not v.Parent:FindFirstChild("Intagibility") then
							BV:Destroy()
							hit = true
							table.insert(FoundPlayers, v.Parent)
							
							local targetCharacter = v.Parent
							local targetHrp = targetCharacter.HumanoidRootPart :: any & BasePart
							local targetHumanoid = targetCharacter.Humanoid :: any & Humanoid
							
							local disable1 = Instance.new("BoolValue")
							disable.Name = "Disable"
							disable.Parent = targetCharacter
							effects[#effects + 1] = disable1 :: any
							local tDisable1 = Instance.new("BoolValue")
							tDisable.Name = "TrueDisable"
							tDisable.Parent = targetCharacter
							effects[#effects + 1] = tDisable1 :: any
							local NoAttack1 = Instance.new("BoolValue")
							NoAttack.Name = "NoAttack"
							NoAttack.Parent = targetCharacter
							effects[#effects + 1] = NoAttack1 :: any
							local weld = Instance.new("Weld")
							weld.Parent = Sword
							weld.Part0 = swordAttach
							weld.Part1 = targetHrp
							effects[#effects + 1] = weld :: any


							--// Impale them and drain life until hit or duration is met

							local tickTime = 0
							local totalTime = 0

							local hb

							local function cleanAll()
								Cleanup()
								character:SetAttribute("Intangibility", false)
								hb:Disconnect()
							end

							local lastHP = humanoid.Health

							hb = game["Run Service"].Heartbeat:Connect(function(dt)
								tickTime += dt
								totalTime += dt

								if targetCharacter.Effects:FindFirstChild("KO") then
									Clean()
									character:SetAttribute("Intangibility", false)
									cleanAll()
									return
								end

								if humanoid.Health < lastHP then
									Clean()
									character:SetAttribute("Intangibility", false)
									cleanAll()
									return
								end

								if totalTime >= drainTime then
									Clean()
									character:SetAttribute("Intangibility", false)
									cleanAll()
									return
								end

								if tickTime >= tickFreq then
									tickTime -= tickFreq

									local healthDelta = targetHumanoid.MaxHealth * 0.005

									MainModule.TagHumanoid(player, targetHumanoid, {
										Damage = healthDelta,
										LifeSteal = healthDelta,
										ThroughStun = true,
										IgnoreDefense = true,
										Sharp = true
									})
									lastHP = humanoid.Health
								end
							end)
						end
					end	
				end
			end
		end

	end)
	
	if #FoundPlayers == 0 then
		task.wait(1)
		Clean()
		character:SetAttribute("Intangibility", false)
		Cleanup()
		return
	end
	

	
	--local targetPlayer

	---- Check if anyone is in front
	--for _, target: Player in pairs(game.Players:GetPlayers()) do
	--	if target == player then
	--		continue
	--	end

	--	if not target.Character then
	--		continue
	--	end

	--	local targHrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart") :: BasePart

	--	if not targHrp then
	--		continue
	--	end

	--	if (targHrp.Position - hrp.Position).Magnitude > 10 then
	--		continue
	--	end

	--	targetPlayer = target
	--end

	---- If anyone is found anchor them both and impale
	--if not targetPlayer then
	--	task.wait(1)
	--	Cleanup()
	--	return
	--end

	--local targetCharacter = targetPlayer.Character :: any
	--local targetHrp = targetCharacter.HumanoidRootPart :: any & BasePart
	--local targetHumanoid = targetCharacter.Humanoid :: any & Humanoid

	--local disable = Instance.new("BoolValue")
	--disable.Name = "Disable"
	--disable.Parent = targetCharacter
	--local tDisable = Instance.new("BoolValue")
	--tDisable.Name = "TrueDisable"
	--tDisable.Parent = targetCharacter
	--local NoAttack = Instance.new("BoolValue")
	--NoAttack.Name = "NoAttack"
	--NoAttack.Parent = targetCharacter
	--local weld = Instance.new("Weld")
	--weld.Parent = Sword
	--weld.Part0 = swordAttach
	--weld.Part1 = targetHrp


	--local function targetCleanup()
	--	weld:Destroy()
	--	disable:Destroy()
	--	tDisable:Destroy()
	--	NoAttack:Destroy()
	--	--TargetAnim:Destroy()
	--end

	---- Impale them and drain life until hit or duration is met

	--local tickTime = 0
	--local totalTime = 0

	--local hb

	--local function cleanAll()
	--	Cleanup()
	--	targetCleanup()
	--	hb:Disconnect()
	--end

	--local lastHP = humanoid.Health

	--hb = game["Run Service"].Heartbeat:Connect(function(dt)
	--	tickTime += dt
	--	totalTime += dt

	--	if targetCharacter.Effects:FindFirstChild("KO") then
	--		cleanAll()
	--		return
	--	end

	--	if humanoid.Health < lastHP then
	--		cleanAll()
	--		return
	--	end

	--	if totalTime >= drainTime then
	--		cleanAll()
	--		return
	--	end

	--	if tickTime >= tickFreq then
	--		tickTime -= tickFreq

	--		local healthDelta = targetHumanoid.MaxHealth * 0.005

	--		MainModule.TagHumanoid(player, targetHumanoid, {
	--			Damage = healthDelta,
	--			LifeSteal = healthDelta,
	--			ThroughStun = true,
	--			IgnoreDefense = true,
	--			Sharp = true
	--		})
	--		lastHP = humanoid.Health
	--	end
	--end)
	
	
	
end

return module
