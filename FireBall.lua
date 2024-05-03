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

local FireBall = {}

FireBall.Active = function()
	local Character = game.Players.LocalPlayer.Character
	local RootPart = Character.HumanoidRootPart
	local Hum = Character.Humanoid
	
	if Debounce == false then
		Debounce = true
		Holding = true
		
		
		local Animation = script.Anims.Hold	
		local AnimationTrack = LoadAnimTrack(Hum, Animation, {Looped = true,})
		AnimationTrack:Play()
		
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
				Bg.CFrame = CFrame.lookAt(RootPart.Position, game.Players.LocalPlayer:GetMouse().Hit.Position)
				task.wait()
			end
			Bp:Destroy()
			Bg:Destroy()
		end)
	end
end

FireBall.End = function()
	local Character = game.Players.LocalPlayer.Character
	local RootPart = Character.HumanoidRootPart
	local Hum = Character.Humanoid
	
	RayParams.FilterDescendantsInstances = {workspace.Map}
	
	if Holding == true and Debounce == true then
		Holding = false
		delay(2, function()
			Debounce = false
		end)
		
		local Animation = script.Anims.Hold
		local AnimTrack = LoadAnimTrack(Hum, Animation, {Looped = true})
		AnimTrack:Stop()
		
		local Animation = script.Anims.Release
		local AnimTrack = LoadAnimTrack(Hum, Animation, {Looped = false})
		AnimTrack:Play()
		
		delay(0.183, function()
			local RootFX = script.Vfx.Holder.RootFX:Clone()
			RootFX.Parent = RootPart
			Utilities.Particle_Setup({Holder = RootFX, Type = "Emit"})
			task.delay(1.5, function()
				RootFX:Destroy()
			end)
			
			local EndPos = (RootPart.CFrame * CFrame.new(0,0,-1000)).Position
			
			local Projectile = script.Vfx.Projectile:Clone()
			Projectile.Parent = workspace.Ignore
			Projectile.CFrame = CFrame.lookAt(RootFX.WorldCFrame.Position, EndPos)
			
			Utilities.Particle_Setup({Holder = Projectile, Type = "Enable", Bool = true})
			
			local StartTick = tick()
			local Velocity = (Projectile.Position -EndPos).Unit * -50
			local Connection
			
			Connection = game:GetService("RunService").RenderStepped:Connect(function(dt)
				if tick() - StartTick > 2 then
					Utilities.Particle_Setup({Holder = Projectile, Type = "Enable", Bool = false})
					
					Projectile.Transparency = 1
					
					local tween = TW:Create(Projectile.Light.PointLight, TweenInfo.new(.35), {Brightness = 0})
					tween:Play()
					tween:Destroy()
					
					delay(2, function()
						Projectile:Destroy()
					end)
					
					Connection:Disconnect()
					return
				end		
				
				local Result = workspace:Raycast(Projectile.Position, Velocity * dt - Vector3.new(0,0,0) * dt * dt, RayParams)
				
				if Result then
					Utilities.Particle_Setup({Holder = Projectile.Explosion, Type = "Emit"})
					Utilities.Particle_Setup({Holder = Projectile, Type = "Enable", Bool = false})
					
					Projectile.Transparency = 1
					
					local tween = TW:Create(Projectile.Light.PointLight, TweenInfo.new(0.35), {Brightness = 0})
					tween:Play()
					tween:Destroy()
					
					delay(2, function()
						Projectile:Destroy()
					end)
					
					CameraShake.ShakeOnce({7,7,0.1,0.55})
					
					Connection:Disconnect()
					return
				else
					Projectile.Position = Projectile.Position + Velocity * dt - Vector3.new(0,0,0) * dt * dt
					Velocity += -Vector3.new(0,0,0) * dt
				end
			end)
		end)
	end
end

return FireBall
