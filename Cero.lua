	local TW = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Utilities = require(Assets.Modules.Utils)
local CameraShake = require(Assets.Modules.CameraShakeHandler)

local Debounce = false
local Holding = false

local AnimationCache = {}

local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Include

local function LoadAnimTrack(Hum, Animation, Data)
	if not AnimationCache[Animation] then
		AnimationCache[Animation] = Hum:LoadAnimation(Animation)
		AnimationCache[Animation].Looped = Data.Looped or false
		AnimationCache[Animation].Priority = Data.AnimationPriority or Enum.AnimationPriority.Action 
	end
	return AnimationCache[Animation]
end

local System = {}

System.Active = function()
	local Character = game.Players.LocalPlayer.Character
	local RootPart = Character.HumanoidRootPart
	local Hum = Character.Humanoid
	
	if Debounce == false then
		Debounce = true
		Holding = true
		
		local GroundFx = script.Vfx.GroundPiece:Clone()
		GroundFx.Parent = RootPart
		GroundFx.CFrame = RootPart.CFrame * CFrame.new(0,-3,0)
		Utilities.Particle_Setup({Holder = GroundFx, Type = "Enable", Bool = true})
		
		local CeroSphereFx = script.Vfx.CeroSphereCharge:Clone()
		CeroSphereFx.Parent = RootPart	
		CeroSphereFx.CFrame = Character.Head.CFrame * CFrame.new(0, 0, -2)
		Utilities.Particle_Setup({Holder = CeroSphereFx, Type = "Enable", Bool = true})
		local tween = TW:Create(CeroSphereFx.Attachment.PointLight, TweenInfo.new(.35), {Brightness = 1.5})
		tween:Play()
		tween:Destroy()
		
		local Bp = Instance.new("BodyPosition")
		Bp.Parent = RootPart
		Bp.Name = "HoldCharBp"
		Bp.MaxForce = Vector3.one * 4e4
		Bp.D = 150
		Bp.Position = RootPart.Position

		local Bg = Instance.new("BodyGyro")
		Bg.Parent = RootPart
		Bg.Name = "HoldCharBg"
		Bg.MaxTorque = Vector3.one * 4e4
		Bg.CFrame = CFrame.lookAt(RootPart.Position, game.Players.LocalPlayer:GetMouse().Hit.Position)

		spawn(function()
			while Holding do 
				CeroSphereFx.CFrame = Character.Head.CFrame * CFrame.new(0, 0, -2)
				Bg.CFrame = CFrame.lookAt(RootPart.Position, game.Players.LocalPlayer:GetMouse().Hit.Position)
				task.wait()
			end
			Utilities.Particle_Setup({Holder = CeroSphereFx, Type = "Enable", Bool = false})
			Utilities.Particle_Setup({Holder = GroundFx, Type = "Enable", Bool = false})
			local tween = TW:Create(CeroSphereFx.Attachment.PointLight, TweenInfo.new(.35), {Brightness = 0})
			tween:Play()
			tween:Destroy()
			
			delay(1.5, function()
				CeroSphereFx:Destroy()
				GroundFx:Destroy()
			end)
			Bp:Destroy()
			Bg:Destroy()
		end)
	end
	
end

System.End = function()
	local Character = game.Players.LocalPlayer.Character
	local RootPart = Character.HumanoidRootPart
	local Hum = Character.Humanoid
	
	if Holding == true and Debounce == true then
		Holding = false
		delay(5, function()
			Debounce = false
		end)
		
		local InitPos = (Character.Head.CFrame * CFrame.new(0,0,-2)).Position
		local EndPos = (RootPart.CFrame * CFrame.new(0,0,-1000)).Position
		
		local DustFx = script.Vfx.DustEmitter:Clone()
		DustFx.Parent = RootPart
		DustFx.CFrame = CFrame.lookAt((RootPart.CFrame * CFrame.new(0,-3,0)).Position, EndPos) * CFrame.Angles(0, math.rad(180),0) 
		Utilities.Particle_Setup({Holder = DustFx, Type = "Enable", Bool = true})
		
		local CircleFx = script.Vfx.CircleFx:Clone()
		CircleFx.Parent = RootPart
		CircleFx.CFrame = Character.Head.CFrame * CFrame.new(0, 0, -2)
		Utilities.Particle_Setup({Holder = CircleFx, Type = "Enable", Bool = true})
		
		delay(0.15,function()
			local BeamFx = script.Vfx.BeamEmitter:Clone()
			BeamFx.Parent = RootPart
			BeamFx.CFrame = CFrame.lookAt(InitPos,EndPos) * CFrame.Angles(0,math.rad(180),0)
			Utilities.Particle_Setup({Holder = BeamFx, Type = "Enable", Bool = true})
			
			local Impact = script.Vfx.Impact:Clone()
			Impact.Parent = game.Lighting
			task.delay(0.1,function()
				local tween = TW:Create(Impact, TweenInfo.new(.1), {TintColor = Color3.fromRGB(255,255,255)})
				tween:Play()
				tween:Destroy()
				task.delay(0.1,function()
					Impact.Contrast = 2
					task.delay(0.1,function()
						Impact:Destroy()
					end)
				end)
			end)
			
			local tween = TW:Create(BeamFx.ParticlePlaceHolder.PointLight, TweenInfo.new(.35), {Brightness = 2})
			tween:Play()
			tween:Destroy()
			
			spawn(function()
				local Enablea = true
				task.delay(3,function()
					Enablea = false
				end)
				while Enablea do
					CameraShake.ShakeOnce({3.5,3.5,0.2,0.6})
					task.wait(0.06)
				end
			end)
			
			for _,v in pairs(BeamFx:GetChildren()) do
				if v.Name == "A2" then
					v.Position = Vector3.new(0,0,0)
					local tween = TW:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = Vector3.new(0,0,70)})
					tween:Play()
					tween:Destroy()
				end
			end
			
			delay(3, function()
				for _,v in pairs(BeamFx:GetChildren()) do
					if v.Name == "A1" then
						for i,a in pairs(v:GetChildren()) do
							local tween = TW:Create(a, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CurveSize0 = 0, CurveSize1 = 0, Width0 = 0, Width1 = 0})
							tween:Play()
							tween:Destroy()
						end
					end
				end
				task.delay(.3, function()
					Utilities.Particle_Setup({Holder = BeamFx, Type = "Enable", Bool = false})
				end)
				
				local tween = TW:Create(BeamFx.ParticlePlaceHolder.PointLight, TweenInfo.new(.35), {Brightness = 0})
				tween:Play()
				tween:Destroy()
				
				
				Utilities.Particle_Setup({Holder = CircleFx, Type = "Enable", Bool = false})
				Utilities.Particle_Setup({Holder = DustFx, Type = "Enable", Bool = false})
			end)
		end)

		
	end
end

return System
