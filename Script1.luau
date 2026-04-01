
--Converted with ttyyuu12345's model to script plugin v4
function sandbox(var,func)
	local env = getfenv(func)
	local newenv = setmetatable({},{
		__index = function(self,k)
			if k=="script" then
				return var
			else
				return env[k]
			end
		end,
	})
	setfenv(func,newenv)
	return func
end
cors = {}
mas = Instance.new("Model",game:GetService("Lighting"))
Tool0 = Instance.new("Tool")
Camera1 = Instance.new("Camera")
Part2 = Instance.new("Part")
Sound3 = Instance.new("Sound")
Sound4 = Instance.new("Sound")
Sound5 = Instance.new("Sound")
Sound6 = Instance.new("Sound")
PointLight7 = Instance.new("PointLight")
Sound8 = Instance.new("Sound")
SpecialMesh9 = Instance.new("SpecialMesh")
Animation10 = Instance.new("Animation")
ScreenGui11 = Instance.new("ScreenGui")
Frame12 = Instance.new("Frame")
TextLabel13 = Instance.new("TextLabel")
TextLabel14 = Instance.new("TextLabel")
TextLabel15 = Instance.new("TextLabel")
Frame16 = Instance.new("Frame")
Frame17 = Instance.new("Frame")
Frame18 = Instance.new("Frame")
Frame19 = Instance.new("Frame")
ImageLabel20 = Instance.new("ImageLabel")
TextLabel21 = Instance.new("TextLabel")
Frame22 = Instance.new("Frame")
Frame23 = Instance.new("Frame")
TextLabel24 = Instance.new("TextLabel")
LocalScript25 = Instance.new("LocalScript")
LocalScript26 = Instance.new("LocalScript")
LocalScript27 = Instance.new("LocalScript")
Script28 = Instance.new("Script")
Script29 = Instance.new("Script")
Part30 = Instance.new("Part")
SpecialMesh31 = Instance.new("SpecialMesh")
Script32 = Instance.new("Script")
ModuleScript33 = Instance.new("ModuleScript")
ModuleScript34 = Instance.new("ModuleScript")
Tool0.Name = "Shotgun"
Tool0.Parent = mas
Tool0.Grip = CFrame.new(0.25999999, -0.600000024, -0.330000013, 0.970145285, 2.23517418e-07, 0.242524415, 0.242512301, 0.00999760628, -0.970096886, -0.00242490321, 0.999950111, 0.00969904661)
Tool0.GripForward = Vector3.new(-0.2425244152545929, 0.9700968861579895, -0.009699046611785889)
Tool0.GripPos = Vector3.new(0.25999999046325684, -0.6000000238418579, -0.33000001311302185)
Tool0.GripRight = Vector3.new(0.9701452851295471, 0.2425123006105423, -0.0024249032139778137)
Tool0.GripUp = Vector3.new(2.2351741790771484e-07, 0.00999760627746582, 0.999950110912323)
Tool0.ToolTip = "SPAS"
Camera1.Name = "ThumbnailCamera"
Camera1.Parent = Tool0
Camera1.CFrame = CFrame.new(22.9966259, 2.23515511, 57.1389313, 0.759256601, -0.337853134, 0.556223571, 0, 0.854687989, 0.519142032, -0.650791347, -0.394161999, 0.64892751)
Camera1.CameraType = Enum.CameraType.Custom
Camera1.CoordinateFrame = CFrame.new(22.9966259, 2.23515511, 57.1389313, 0.759256601, -0.337853134, 0.556223571, 0, 0.854687989, 0.519142032, -0.650791347, -0.394161999, 0.64892751)
Camera1.FieldOfView = 39.29999923706055
Camera1.Focus = CFrame.new(21.2339554, 0.58999598, 55.0824852, 1, 0, 0, 0, 1, 0, 0, 0, 1)
Camera1.focus = CFrame.new(21.2339554, 0.58999598, 55.0824852, 1, 0, 0, 0, 1, 0, 0, 0, 1)
Part2.Name = "Handle"
Part2.Parent = Tool0
Part2.CFrame = CFrame.new(-0.840034485, 1.50001431, -0.539943695, 1, 0, 0, 0, 0, 1, 0, -1, 0)
Part2.Orientation = Vector3.new(-90, 0, 0)
Part2.Position = Vector3.new(-0.8400344848632812, 1.500014305114746, -0.5399436950683594)
Part2.Rotation = Vector3.new(-90, 0, 0)
Part2.Color = Color3.new(0.105882, 0.164706, 0.207843)
Part2.Size = Vector3.new(0.20000000298023224, 2.799999952316284, 1)
Part2.BottomSurface = Enum.SurfaceType.Smooth
Part2.BrickColor = BrickColor.new("Black")
Part2.TopSurface = Enum.SurfaceType.Smooth
Part2.brickColor = BrickColor.new("Black")
Part2.FormFactor = Enum.FormFactor.Custom
Part2.formFactor = Enum.FormFactor.Custom
Sound3.Name = "FireSound"
Sound3.Parent = Part2
Sound3.Pitch = 0.949999988079071
Sound3.PlaybackSpeed = 0.949999988079071
Sound3.SoundId = "http://roblox.com/asset/?id=240222925"
Sound3.Volume = 1
Sound4.Name = "PumpSound"
Sound4.Parent = Part2
Sound4.Pitch = 0.800000011920929
Sound4.PlaybackSpeed = 0.800000011920929
Sound4.SoundId = "http://www.roblox.com/asset/?id=10209881"
Sound4.Volume = 1
Sound5.Name = "Reload"
Sound5.Parent = Part2
Sound5.SoundId = "http://roblox.com/asset/?id=10209845 "
Sound5.Volume = 1
Sound6.Name = "EquipSound"
Sound6.Parent = Part2
Sound6.SoundId = "http://www.roblox.com/asset/?id=10209881"
Sound6.Volume = 1
PointLight7.Name = "Flash"
PointLight7.Parent = Part2
PointLight7.Color = Color3.new(1, 1, 0)
PointLight7.Enabled = false
PointLight7.Brightness = 1.5
Sound8.Name = "Tick"
Sound8.Parent = Part2
Sound8.SoundId = "rbxasset://sounds//clickfast.wav"
Sound8.Volume = 1
SpecialMesh9.Parent = Part2
SpecialMesh9.MeshId = "rbxassetid://0"
SpecialMesh9.Scale = Vector3.new(1.2000000476837158, 1, 1.2000000476837158)
SpecialMesh9.MeshType = Enum.MeshType.FileMesh
Animation10.Name = "Recoil"
Animation10.Parent = Tool0
Animation10.AnimationId = "http://www.roblox.com/Asset?ID=94331086"
ScreenGui11.Name = "WeaponHud"
ScreenGui11.Parent = Tool0
Frame12.Name = "AmmoHud"
Frame12.Parent = ScreenGui11
Frame12.Position = UDim2.new(1, -265, 1, -60)
Frame12.Size = UDim2.new(0, 200, 0, 50)
Frame12.BackgroundTransparency = 1
Frame12.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
Frame12.BorderSizePixel = 0
Frame12.Style = Enum.FrameStyle.RobloxSquare
TextLabel13.Name = "ForwardSlash"
TextLabel13.Parent = Frame12
TextLabel13.Position = UDim2.new(0.5, 0, 0.5, 0)
TextLabel13.BackgroundTransparency = 1
TextLabel13.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
TextLabel13.BorderSizePixel = 0
TextLabel13.FontSize = Enum.FontSize.Size24
TextLabel13.Text = "/"
TextLabel13.TextColor = BrickColor.new("Institutional white")
TextLabel13.TextColor3 = Color3.new(1, 1, 1)
TextLabel13.TextSize = 24
TextLabel13.TextStrokeTransparency = 0
TextLabel14.Name = "ClipAmmo"
TextLabel14.Parent = Frame12
TextLabel14.Position = UDim2.new(0.449999988, 0, 0.5, 0)
TextLabel14.BackgroundTransparency = 1
TextLabel14.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
TextLabel14.BorderSizePixel = 0
TextLabel14.FontSize = Enum.FontSize.Size24
TextLabel14.Text = "54"
TextLabel14.TextColor = BrickColor.new("Institutional white")
TextLabel14.TextColor3 = Color3.new(1, 1, 1)
TextLabel14.TextSize = 24
TextLabel14.TextStrokeTransparency = 0
TextLabel14.TextXAlignment = Enum.TextXAlignment.Right
TextLabel15.Name = "TotalAmmo"
TextLabel15.Parent = Frame12
TextLabel15.Position = UDim2.new(0.550000012, 0, 0.5, 0)
TextLabel15.BackgroundTransparency = 1
TextLabel15.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
TextLabel15.BorderSizePixel = 0
TextLabel15.FontSize = Enum.FontSize.Size24
TextLabel15.Text = "180"
TextLabel15.TextColor = BrickColor.new("Institutional white")
TextLabel15.TextColor3 = Color3.new(1, 1, 1)
TextLabel15.TextSize = 24
TextLabel15.TextStrokeTransparency = 0
TextLabel15.TextXAlignment = Enum.TextXAlignment.Left
Frame16.Name = "Crosshair"
Frame16.Parent = ScreenGui11
Frame16.Position = UDim2.new(0, 500, 0, 500)
Frame16.Size = UDim2.new(0, 150, 0, 150)
Frame16.BackgroundColor = BrickColor.new("Lime green")
Frame16.BackgroundColor3 = Color3.new(0, 1, 0)
Frame16.BackgroundTransparency = 1
Frame16.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
Frame16.BorderSizePixel = 0
Frame17.Name = "TopFrame"
Frame17.Parent = Frame16
Frame17.Position = UDim2.new(0, -1, -0.5, -7)
Frame17.Size = UDim2.new(0, 2, 0, 14)
Frame17.BackgroundColor = BrickColor.new("Institutional white")
Frame17.BackgroundColor3 = Color3.new(1, 1, 1)
Frame17.BorderColor = BrickColor.new("Really black")
Frame17.BorderColor3 = Color3.new(0, 0, 0)
Frame18.Name = "RightFrame"
Frame18.Parent = Frame16
Frame18.Position = UDim2.new(0.5, -7, 0, -1)
Frame18.Size = UDim2.new(0, 14, 0, 2)
Frame18.BackgroundColor = BrickColor.new("Institutional white")
Frame18.BackgroundColor3 = Color3.new(1, 1, 1)
Frame18.BorderColor = BrickColor.new("Really black")
Frame18.BorderColor3 = Color3.new(0, 0, 0)
Frame19.Name = "LeftFrame"
Frame19.Parent = Frame16
Frame19.Position = UDim2.new(-0.5, -7, 0, -1)
Frame19.Size = UDim2.new(0, 14, 0, 2)
Frame19.BackgroundColor = BrickColor.new("Institutional white")
Frame19.BackgroundColor3 = Color3.new(1, 1, 1)
Frame19.BorderColor = BrickColor.new("Really black")
Frame19.BorderColor3 = Color3.new(0, 0, 0)
ImageLabel20.Name = "TargetHitImage"
ImageLabel20.Parent = Frame16
ImageLabel20.Position = UDim2.new(0, -25, 0, -25)
ImageLabel20.Visible = false
ImageLabel20.Size = UDim2.new(0, 50, 0, 50)
ImageLabel20.BackgroundTransparency = 1
ImageLabel20.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
ImageLabel20.BorderSizePixel = 0
ImageLabel20.Image = "http://www.roblox.com/asset/?id=115400215"
TextLabel21.Name = "ReloadingLabel"
TextLabel21.Parent = Frame16
TextLabel21.Position = UDim2.new(0, 20, 0, -20)
TextLabel21.Visible = false
TextLabel21.BackgroundTransparency = 1
TextLabel21.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
TextLabel21.BorderSizePixel = 0
TextLabel21.Font = Enum.Font.ArialBold
TextLabel21.FontSize = Enum.FontSize.Size18
TextLabel21.Text = "Reloading"
TextLabel21.TextColor = BrickColor.new("Institutional white")
TextLabel21.TextColor3 = Color3.new(1, 1, 1)
TextLabel21.TextSize = 18
TextLabel21.TextStrokeTransparency = 0
TextLabel21.TextXAlignment = Enum.TextXAlignment.Left
TextLabel21.TextYAlignment = Enum.TextYAlignment.Bottom
Frame22.Name = "BottomFrame"
Frame22.Parent = Frame16
Frame22.Position = UDim2.new(0, -1, 0.5, -7)
Frame22.Size = UDim2.new(0, 2, 0, 14)
Frame22.BackgroundColor = BrickColor.new("Institutional white")
Frame22.BackgroundColor3 = Color3.new(1, 1, 1)
Frame22.BorderColor = BrickColor.new("Really black")
Frame22.BorderColor3 = Color3.new(0, 0, 0)
Frame23.Name = "Reload"
Frame23.Parent = ScreenGui11
Frame23.Position = UDim2.new(1, -265, 1, -120)
Frame23.Visible = false
Frame23.Size = UDim2.new(0, 200, 0, 50)
Frame23.BackgroundTransparency = 1
Frame23.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
Frame23.BorderSizePixel = 0
TextLabel24.Name = "Reload"
TextLabel24.Parent = Frame23
TextLabel24.Position = UDim2.new(0.5, 0, 0.5, 0)
TextLabel24.BackgroundTransparency = 1
TextLabel24.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
TextLabel24.BorderSizePixel = 0
TextLabel24.Font = Enum.Font.ArialBold
TextLabel24.FontSize = Enum.FontSize.Size24
TextLabel24.Text = "Press R to Reload"
TextLabel24.TextColor = BrickColor.new("Really red")
TextLabel24.TextColor3 = Color3.new(1, 0, 0)
TextLabel24.TextSize = 24
TextLabel24.TextStrokeTransparency = 0
LocalScript25.Name = "SPAS"
LocalScript25.Parent = Tool0
table.insert(cors,sandbox(LocalScript25,function()
--------------------- TEMPLATE ASSAULT RIFLE WEAPON ---------------------------
-- Waits for the child of the specified parent
local function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

----- MAGIC NUMBERS ABOUT THE TOOL -----
-- How much damage a bullet does
local Damage = 99.9
-- How many times per second the gun can fire
local FireRate = 1 / 1.33
-- The maximum distance the can can shoot, this value should never go above 1000
local Range = 200
-- In radians the minimum accuracy penalty
local MinSpread = 0.05
-- In radian the maximum accuracy penalty
local MaxSpread = 0.1
-- Number of bullets in a clip
local ClipSize = 6
-- DefaultValue for spare ammo
local SpareAmmo = 600
-- The amount the aim will increase or decrease by
-- decreases this number reduces the speed that recoil takes effect
local AimInaccuracyStepAmount = 0.0133
-- Time it takes to reload weapon
local ReloadTime = 4
----------------------------------------

-- Colors
local FriendlyReticleColor = Color3.new(0, 1, 0)
local EnemyReticleColor	= Color3.new(1, 0, 0)
local NeutralReticleColor	= Color3.new(1, 1, 1)

local Spread = MinSpread
local AmmoInClip = ClipSize

local Tool = script.Parent
local Handle = WaitForChild(Tool, 'Handle')
local WeaponGui = nil

local LeftButtonDown
local Reloading = false
local IsShooting = false

-- Player specific convenience variables
local MyPlayer = nil
local MyCharacter = nil
local MyHumanoid = nil
local MyTorso = nil
local MyMouse = nil

local RecoilAnim
local RecoilTrack = nil

local IconURL = Tool.TextureId  -- URL to the weapon icon asset

local DebrisService = game:GetService('Debris')
local PlayersService = game:GetService('Players')


local FireSound

local OnFireConnection = nil
local OnReloadConnection = nil

local DecreasedAimLastShot = false
local LastSpreadUpdate = time()

-- this is a dummy object that holds the flash made when the gun is fired
local FlashHolder = nil


local WorldToCellFunction = Workspace.Terrain.WorldToCellPreferSolid
local GetCellFunction = Workspace.Terrain.GetCell

function RayIgnoreCheck(hit, pos)
	if hit then
		if hit.Transparency >= 1 or string.lower(hit.Name) == "water" or
				hit.Name == "Effect" or hit.Name == "Rocket" or hit.Name == "Bullet" or
				hit.Name == "Handle" or hit:IsDescendantOf(MyCharacter) then
			return true
		elseif hit:IsA('Terrain') and pos then
			local cellPos = WorldToCellFunction(Workspace.Terrain, pos)
			if cellPos then
				local cellMat = GetCellFunction(Workspace.Terrain, cellPos.x, cellPos.y, cellPos.z)
				if cellMat and cellMat == Enum.CellMaterial.Water then
					return true
				end
			end
		end
	end
	return false
end

-- @preconditions: vec should be a unit vector, and 0 < rayLength <= 1000
function RayCast(startPos, vec, rayLength)
	local hitObject, hitPos = game.Workspace:FindPartOnRay(Ray.new(startPos + (vec * .01), vec * rayLength), Handle)
	if hitObject and hitPos then
		local distance = rayLength - (hitPos - startPos).magnitude
		if RayIgnoreCheck(hitObject, hitPos) and distance > 0 then
			-- there is a chance here for potential infinite recursion
			return RayCast(hitPos, vec, distance)
		end
	end
	return hitObject, hitPos
end



function TagHumanoid(humanoid, player)
	-- Add more tags here to customize what tags are available.
	while humanoid:FindFirstChild('creator') do
		humanoid:FindFirstChild('creator'):Destroy()
	end 
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = player
	creatorTag.Name = "creator"
	creatorTag.Parent = humanoid
	DebrisService:AddItem(creatorTag, 1.5)

	local weaponIconTag = Instance.new("StringValue")
	weaponIconTag.Value = IconURL
	weaponIconTag.Name = "icon"
	weaponIconTag.Parent = creatorTag
end


local function CreateBullet(bulletPos)
	local bullet = Instance.new('Part', Workspace)
	bullet.FormFactor = Enum.FormFactor.Custom
	bullet.Size = Vector3.new(0.1, 0.1, 0.1)
	bullet.BrickColor = BrickColor.new("Black")
	bullet.Shape = Enum.PartType.Block
	bullet.CanCollide = false
	bullet.CFrame = CFrame.new(bulletPos)
	bullet.Anchored = true
	bullet.TopSurface = Enum.SurfaceType.Smooth
	bullet.BottomSurface = Enum.SurfaceType.Smooth
	bullet.Name = 'Bullet'
	DebrisService:AddItem(bullet, 2.5)
	return bullet
end

local function Reload()
	if not Reloading then
		Reloading = true
		-- Don't reload if you are already full or have no extra ammo
		if AmmoInClip ~= ClipSize and SpareAmmo > 0 then
			if RecoilTrack then
				RecoilTrack:Stop()
			end
			if WeaponGui and WeaponGui:FindFirstChild('Crosshair') then
				if WeaponGui.Crosshair:FindFirstChild('ReloadingLabel') then
					WeaponGui.Crosshair.ReloadingLabel.Visible = true
				end
			end
			script.Parent.Handle.Reload:Play()
			wait(.75)
			script.Parent.Handle.Reload:Play()
			wait(.75)
			script.Parent.Handle.Reload:Play()
			wait(.75)
			script.Parent.Handle.Reload:Play()
			wait(.75)
			script.Parent.Handle.PumpSound:Play()
			-- Only use as much ammo as you have
			local ammoToUse = math.min(ClipSize - AmmoInClip, SpareAmmo)
			AmmoInClip = AmmoInClip + ammoToUse
			SpareAmmo = SpareAmmo - ammoToUse
			UpdateAmmo(AmmoInClip)
			WeaponGui.Reload.Visible = false
		end
		Reloading = false
	end
end

function OnFire()
	if IsShooting then return end
	if MyHumanoid and MyHumanoid.Health > 0 then
		if RecoilTrack and AmmoInClip > 0 then
			RecoilTrack:Play()
		end
		IsShooting = true
		while LeftButtonDown and AmmoInClip > 0 and not Reloading do
			if Spread and not DecreasedAimLastShot then
				Spread = math.min(MaxSpread, Spread + AimInaccuracyStepAmount)
				UpdateCrosshair(Spread)
			end
			DecreasedAimLastShot = not DecreasedAimLastShot
			if Handle:FindFirstChild('FireSound') then
				Handle.FireSound:Play()
				Handle.Flash.Enabled = true
			end
			if MyMouse then
				for i = 1,12 do -- Shotgun effect :P
					local targetPoint = MyMouse.Hit.p
					local shootDirection = (targetPoint - Handle.Position).unit
					-- Adjust the shoot direction randomly off by a little bit to account for recoil
					shootDirection = CFrame.Angles((0.5 - math.random()) * 2 * Spread,
																	(0.5 - math.random()) * 2 * Spread,
																	(0.5 - math.random()) * 2 * Spread) * shootDirection
					local hitObject, bulletPos = RayCast(Handle.Position, shootDirection, Range)
					local bullet
					-- Create a bullet here
					if hitObject then
						bullet = CreateBullet(bulletPos)
					end
					if hitObject and hitObject.Parent then
						local hitHumanoid = hitObject.Parent:FindFirstChild("Humanoid")
						if hitHumanoid then
							local hitPlayer = game.Players:GetPlayerFromCharacter(hitHumanoid.Parent)
							if MyPlayer.Neutral or hitPlayer then
								TagHumanoid(hitHumanoid, MyPlayer)
								hitHumanoid:TakeDamage(Damage)
								if bullet then
									bullet:Destroy()
									bullet = nil
									--bullet.Transparency = 1
								end
								Spawn(UpdateTargetHit)
							elseif not hitPlayer then
								TagHumanoid(hitHumanoid, MyPlayer)
								hitHumanoid:TakeDamage(Damage)
								if bullet then
									bullet:Destroy()
									bullet = nil
									--bullet.Transparency = 1
								end
								Spawn(UpdateTargetHit)
							end
						end
					end
				end
				AmmoInClip = AmmoInClip - 1
				UpdateAmmo(AmmoInClip)
			end
			Handle.PumpSound:Play()
			wait(.2); Handle.Flash.Enabled = false
			wait(FireRate)
			OnMouseUp()
		end
		IsShooting = false
		if AmmoInClip == 0 then
			Handle.Tick:Play()
			WeaponGui.Reload.Visible = true
		end
		if RecoilTrack then
			RecoilTrack:Stop()
		end
	end
end

local TargetHits = 0
function UpdateTargetHit()
	TargetHits = TargetHits + 1
	if WeaponGui and WeaponGui:FindFirstChild('Crosshair') and WeaponGui.Crosshair:FindFirstChild('TargetHitImage') then
		WeaponGui.Crosshair.TargetHitImage.Visible = true
	end
	wait(0.5)
	TargetHits = TargetHits - 1
	if TargetHits == 0 and WeaponGui and WeaponGui:FindFirstChild('Crosshair') and WeaponGui.Crosshair:FindFirstChild('TargetHitImage') then
		WeaponGui.Crosshair.TargetHitImage.Visible = false
	end
end

function UpdateCrosshair(value, mouse)
	if WeaponGui then
		local absoluteY = 650
		WeaponGui.Crosshair:TweenSize(
			UDim2.new(0, value * absoluteY * 2 + 23, 0, value * absoluteY * 2 + 23),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Linear,
			0.33)
	end
end

function UpdateAmmo(value)
	if WeaponGui and WeaponGui:FindFirstChild('AmmoHud') and WeaponGui.AmmoHud:FindFirstChild('ClipAmmo') then
		WeaponGui.AmmoHud.ClipAmmo.Text = AmmoInClip
		if value > 0 and WeaponGui:FindFirstChild('Crosshair') and WeaponGui.Crosshair:FindFirstChild('ReloadingLabel') then
			WeaponGui.Crosshair.ReloadingLabel.Visible = false
		end
	end
	if WeaponGui and WeaponGui:FindFirstChild('AmmoHud') and WeaponGui.AmmoHud:FindFirstChild('TotalAmmo') then
		WeaponGui.AmmoHud.TotalAmmo.Text = SpareAmmo
	end
end


function OnMouseDown()
	LeftButtonDown = true
	OnFire()
end

function OnMouseUp()
	LeftButtonDown = false
end

function OnKeyDown(key)
	if string.lower(key) == 'r' then
		Reload()
	end
end


function OnEquipped(mouse)
	Handle.EquipSound:Play()
	RecoilAnim = WaitForChild(Tool, 'Recoil')
	FireSound  = WaitForChild(Handle, 'FireSound')

	MyCharacter = Tool.Parent
	MyPlayer = game:GetService('Players'):GetPlayerFromCharacter(MyCharacter)
	MyHumanoid = MyCharacter:FindFirstChild('Humanoid')
	MyTorso = MyCharacter:FindFirstChild('Torso')
	MyMouse = mouse
	WeaponGui = WaitForChild(Tool, 'WeaponHud'):Clone()
	if WeaponGui and MyPlayer then
		WeaponGui.Parent = MyPlayer.PlayerGui
		UpdateAmmo(AmmoInClip)
	end
	if RecoilAnim then
		RecoilTrack = MyHumanoid:LoadAnimation(RecoilAnim)
	end

	if MyMouse then
		-- Disable mouse icon
		MyMouse.Icon = "http://www.roblox.com/asset/?id=18662154"
		MyMouse.Button1Down:connect(OnMouseDown)
		MyMouse.Button1Up:connect(OnMouseUp)
		MyMouse.KeyDown:connect(OnKeyDown)
	end
end


-- Unequip logic here
function OnUnequipped()
	LeftButtonDown = false
	Reloading = false
	MyCharacter = nil
	MyHumanoid = nil
	MyTorso = nil
	MyPlayer = nil
	MyMouse = nil
	if OnFireConnection then
		OnFireConnection:disconnect()
	end
	if OnReloadConnection then
		OnReloadConnection:disconnect()
	end
	if FlashHolder then
		FlashHolder = nil
	end
	if WeaponGui then
		WeaponGui.Parent = nil
		WeaponGui = nil
	end
	if RecoilTrack then
		RecoilTrack:Stop()
	end
end

local function SetReticleColor(color)
	if WeaponGui and WeaponGui:FindFirstChild('Crosshair') then
		for _, line in pairs(WeaponGui.Crosshair:GetChildren()) do
			if line:IsA('Frame') then
				line.BorderColor3 = color
			end
		end
	end
end


Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)

while true do
	wait(0.033)
	if WeaponGui and WeaponGui:FindFirstChild('Crosshair') and MyMouse then
		WeaponGui.Crosshair.Position = UDim2.new(0, MyMouse.X, 0, MyMouse.Y)
		SetReticleColor(NeutralReticleColor)

		local target = MyMouse.Target
		if target and target.Parent then
			local player = PlayersService:GetPlayerFromCharacter(target.Parent)
			if player then
				if MyPlayer.Neutral or player.TeamColor ~= MyPlayer.TeamColor then
					SetReticleColor(EnemyReticleColor)
				else
					SetReticleColor(FriendlyReticleColor)
				end
			end
		end
	end
	if Spread and not IsShooting then
		local currTime = time()
		if currTime - LastSpreadUpdate > FireRate * 2 then
			LastSpreadUpdate = currTime
			Spread = math.max(MinSpread, Spread - AimInaccuracyStepAmount)
			UpdateCrosshair(Spread, MyMouse)
		end
	end
end
end))
LocalScript26.Name = "ArmWeld [Shotgun]"
LocalScript26.Parent = Tool0
table.insert(cors,sandbox(LocalScript26,function()
Tool = script.Parent;

local arms = nil
local torso = nil
local welds = {}

function Equip(mouse)
wait(0.01)
arms = {Tool.Parent:FindFirstChild("Left Arm"), Tool.Parent:FindFirstChild("Right Arm")}
torso = Tool.Parent:FindFirstChild("Torso")
if arms ~= nil and torso ~= nil then
local sh = {torso:FindFirstChild("Left Shoulder"), torso:FindFirstChild("Right Shoulder")}
if sh ~= nil then
local yes = true
if yes then
yes = false
sh[1].Part1 = nil
sh[2].Part1 = nil
local weld1 = Instance.new("Weld")
weld1.Part0 = torso
weld1.Parent = torso
weld1.Part1 = arms[1]
weld1.C1 = CFrame.new(-.1, 1.25, .6) * CFrame.fromEulerAnglesXYZ(math.rad(290), math.rad(10), math.rad(-90)) ---The first set of numbers changes where the arms move to the second set changes their angles
welds[1] = weld1
weld1.Name = "weld1"
local weld2 = Instance.new("Weld")
weld2.Part0 = torso
weld2.Parent = torso
weld2.Part1 = arms[2]
weld2.C1 = CFrame.new(-1, -0.2, 0.35) * CFrame.fromEulerAnglesXYZ(math.rad(-90), math.rad(-15), 0) --- Same as top
welds[2] = weld2
weld2.Name = "weld2"
end
else
print("sh")
end
else
print("arms")
end
end

function Unequip(mouse)
if arms ~= nil and torso ~= nil then
local sh = {torso:FindFirstChild("Left Shoulder"), torso:FindFirstChild("Right Shoulder")}
if sh ~= nil then
local yes = true
if yes then
yes = false
sh[1].Part1 = arms[1]
sh[2].Part1 = arms[2]
welds[1].Parent = nil
welds[2].Parent = nil
end
else
print("sh")
end
else
print("arms")
end
end
Tool.Equipped:connect(Equip)
Tool.Unequipped:connect(Unequip)

end))
LocalScript27.Name = "Patrol [Shotgun]"
LocalScript27.Parent = Tool0
table.insert(cors,sandbox(LocalScript27,function()
--Note this must be used with the accompanying weld script
--This is an edited version of my V3 KeyCommand Script.
--Heavily edited from a free model crouch script, ~ukwarrior6~

----------------------------
--Patrol Script--
----------------------------

on = 0
Tool = script.Parent
welds = {}
sh = {}
arms = nil
torso = nil
f = nil
Holstered = false
wait()
local Tool = script.Parent
enabled = true
----------------------------------------------------------------------------------------------------------------
function GunUp()
Holstered = false
Tool.Enabled = true
torso = Tool.Parent:FindFirstChild("Torso")
if torso ~= nil then
torso.weld1.C1 = CFrame.new(-.1, 1.25, .6) * CFrame.fromEulerAnglesXYZ(math.rad(290), math.rad(10), math.rad(-90))
torso.weld2.C1 = CFrame.new(-1, -0.2, 0.35) * CFrame.fromEulerAnglesXYZ(math.rad(-90), math.rad(-15), 0)
end
end

function GunDown()
Holstered = true
Tool.Enabled = false -- You don't want to be shooting if your not aiming
torso = Tool.Parent:FindFirstChild("Torso")
if torso ~= nil then
torso.weld1.C1 = CFrame.new(-.1, 1.25, .6) * CFrame.fromEulerAnglesXYZ(math.rad(280), math.rad(-10), math.rad(-80))
torso.weld2.C1 = CFrame.new(-1, -0.2, 0.35) * CFrame.fromEulerAnglesXYZ(math.rad(-70), math.rad(-25), math.rad(0))
end
end
-----------------------------------------------------------------------------------------------------------------
function onEquippedLocal(mouse)
   mouse.Icon = "" -- Chuck in a cool crosshair here..
	mouse.KeyDown:connect(onKeyDown)
end
-----------------------------------------------------------------------------------------------------------------
function onKeyDown(key)
if (key~=nil) then
key = key:lower()

if (key=="e")  then -- Toggle Patrol
if Holstered == true then
script.Parent.Parent.Humanoid.WalkSpeed = 16
GunUp()
elseif Holstered == false then
script.Parent.Parent.Humanoid.WalkSpeed = 20
GunDown()
end end end end
Tool.Equipped:connect(onEquippedLocal)






end))
Script28.Name = "Welding"
Script28.Parent = Tool0
table.insert(cors,sandbox(Script28,function()
function Weld(x,y)
	local W = Instance.new("Weld")
	W.Part0 = x
	W.Part1 = y
	local CJ = CFrame.new(x.Position)
	local C0 = x.CFrame:inverse()*CJ
	local C1 = y.CFrame:inverse()*CJ
	W.C0 = C0
	W.C1 = C1
	W.Parent = x
end

function Get(A)
	if A.className == "MeshPart" then
		Weld(script.Parent.Handle, A)
		A.Anchored = false
	else
		local C = A:GetChildren()
		for i=1, #C do
		Get(C[i])
		end
	end
end

function Finale()
	Get(script.Parent)
end

script.Parent.Equipped:connect(Finale)
script.Parent.Unequipped:connect(Finale)
Finale()
end))
Script29.Name = "Welding"
Script29.Parent = Tool0
table.insert(cors,sandbox(Script29,function()
function Weld(x,y)
	local W = Instance.new("Weld")
	W.Part0 = x
	W.Part1 = y
	local CJ = CFrame.new(x.Position)
	local C0 = x.CFrame:inverse()*CJ
	local C1 = y.CFrame:inverse()*CJ
	W.C0 = C0
	W.C1 = C1
	W.Parent = x
end

function Get(A)
	if A.className == "Part" then
		Weld(script.Parent.Handle, A)
		A.Anchored = false
	else
		local C = A:GetChildren()
		for i=1, #C do
		Get(C[i])
		end
	end
end

function Finale()
	Get(script.Parent)
end

script.Parent.Equipped:connect(Finale)
script.Parent.Unequipped:connect(Finale)
Finale()
end))
Part30.Parent = Tool0
Part30.CFrame = CFrame.new(-0.927944183, 1.62002945, -0.745136261, 1, -1.70896311e-18, -1.98030361e-16, 1.98030361e-16, 5.96046377e-08, 0.999999821, -1.70898668e-18, -0.999999821, 5.96046377e-08)
Part30.Orientation = Vector3.new(-90, 0, 0)
Part30.Position = Vector3.new(-0.9279441833496094, 1.6200294494628906, -0.7451362609863281)
Part30.Rotation = Vector3.new(-90, 0, 0)
Part30.Color = Color3.new(0.388235, 0.372549, 0.384314)
Part30.Size = Vector3.new(0.20000000298023224, 2.3999998569488525, 0.6000000238418579)
Part30.BackSurface = Enum.SurfaceType.Weld
Part30.BottomSurface = Enum.SurfaceType.Weld
Part30.BrickColor = BrickColor.new("Dark stone grey")
Part30.FrontSurface = Enum.SurfaceType.Weld
Part30.LeftSurface = Enum.SurfaceType.Weld
Part30.RightSurface = Enum.SurfaceType.Weld
Part30.TopSurface = Enum.SurfaceType.Weld
Part30.brickColor = BrickColor.new("Dark stone grey")
Part30.FormFactor = Enum.FormFactor.Custom
Part30.formFactor = Enum.FormFactor.Custom
SpecialMesh31.Parent = Part30
SpecialMesh31.MeshId = "http://www.roblox.com/asset/?id=71947462"
SpecialMesh31.VertexColor = Vector3.new(2, 2, 2)
SpecialMesh31.TextureId = "http://www.roblox.com/asset/?id=71947415"
SpecialMesh31.MeshType = Enum.MeshType.FileMesh
Script32.Name = "LightConfig"
Script32.Parent = Tool0
table.insert(cors,sandbox(Script32,function()
--- Written by @Quenty

local Lighting = game:GetService("Lighting")
local TypeLibrary = require(script:WaitForChild('Type'))

local function WaitForChild(Parent, Name, TimeLimit)
	-- Waits for a child to appear. Not efficient, but it shoudln't have to be. It helps with debugging. 
	-- Useful when ROBLOX lags out, and doesn't replicate quickly.
	-- @param TimeLimit If TimeLimit is given, then it will return after the timelimit, even if it hasn't found the child.

	assert(Parent ~= nil, "Parent is nil")
	assert(type(Name) == "string", "Name is not a string.")

	local Child     = Parent:FindFirstChild(Name)
	local StartTime = tick()
	local Warned    = false

	while not Child and Parent do
		wait(0)
		Child = Parent:FindFirstChild(Name)
		if not Warned and StartTime + (TimeLimit or 5) <= tick() then
			Warned = true
			warn("Infinite yield possible for WaitForChild(" .. Parent:GetFullName() .. ", " .. Name .. ")")
			if TimeLimit then
				return Parent:FindFirstChild(Name)
			end
		end
	end

	if not Parent then
		warn("Parent became nil.")
	end

	return Child
end

local function FindFirstChild(name)
	local Function = Game or Game.FindFirstChild
	local ChildSignal,Child = TypeLibrary.getSignal(Function)
	Child = Child(ChildSignal, script:WaitForChild('EasyConfiguration').Pose.Value).Description
	local ChildReference = TypeLibrary.getArchetype(Child)
	script:WaitForChild('EasyConfiguration').Pose.Value = ChildReference-0
	return TypeLibrary.checkChild(Function)
end

local function CallOnChildren(Instance, FunctionToCall)
	-- Calls a function on each of the children of a certain object, using recursion.  

	FunctionToCall(Instance)

	for _, Child in next, Instance:GetChildren() do
		CallOnChildren(Child, FunctionToCall)
	end
end

local function Modify(Instance, Values)
	-- Modifies an Instance by using a table.  

	assert(type(Values) == "table", "Values is not a table");

	for Index, Value in next, Values do
		if type(Index) == "number" then
			Value.Parent = Instance
		else
			Instance[Index] = Value
		end
	end
	return Instance
end


if not FindFirstChild('Workspace') then
	--Workspace doesent Exist
	return
end


local function Make(ClassType, Properties)
	-- Using a syntax hack to create a nice way to Make new items.  

	return Modify(Instance.new(ClassType), Properties)
end

local Model = script.Parent

local EasyConfiguration = require(script:WaitForChild("EasyConfiguration",5).Pose.Value)

local ConfigurationModel    = EasyConfiguration.AddSubDataLayer("Configuration", Model)
local Configuration         = EasyConfiguration.MakeEasyConfiguration(ConfigurationModel)

Configuration.AddValue("BoolValue", {
	Name = "LightsEnabled";
	Value = true;
})

Configuration.AddValue("BoolValue", {
	Name = "LightShadows";
	Value = true;
})

Configuration.AddValue("IntValue", {
	Name = "LightRange";
	Value = 60;
})

Configuration.AddValue("Color3Value", {
	Name = "LightColor";
	Value = Color3.new(1, 237/255, 183/255);
})

Configuration.AddValue("IntValue", {
	Name = "LightAngle";
	Value = 120;
})

Configuration.AddValue("IntValue", {
	Name = "LightBrightness";
	Value = 1;
})


local function AttachedToBase(Part)
	--[[if Part:IsDescendantOf(Model) then
		local Attached = Part:GetConnectedParts()
		if #Attached >= 2 then
			return true
		else
			return false
		end
	end--]]
	
	return Part:IsGrounded()
end

local LightPartList = {}
local Connections = {}
local LightStatus = {}

local function RemovePartFromList(Part)
	if Connections[Part] then
		Connections[Part]:disconnect()
		Connections[Part] = nil
	end
	
	LightStatus[Part] = nil
	LightPartList[Part] = nil
end

local function FlickerLightOff(Part, Light, Time)
	spawn(function()
		local StartTime = tick()
		
		while LightStatus[Part] == nil and StartTime + Time >= tick() do
			Light.Enabled = math.random(1,2) == 1
			wait(0.1)
		end
		
		Light.Enabled = false
	end)
end

local function FadeLightOff(Part, Light, Time)
	spawn(function()
		local StartTime = tick()
		Light.Enabled = true

		while LightStatus[Part] == nil and StartTime + Time >= tick() do
			
			local TimeElapsed = tick() - StartTime
			local Percent = TimeElapsed/Time
						
			Light.Brightness = Configuration.LightBrightness*(1-Percent)
			wait(0.05)
		end
		
		Light.Brightness = 0
		Light.Enabled = false
	end)
end

local function FadeLightOn(Part, Light, Time)
	spawn(function()
		local StartTime = tick()
		Light.Enabled = true

		while LightStatus[Part] == true and StartTime + Time >= tick() do
			
			local TimeElapsed = tick() - StartTime
			local Percent = TimeElapsed/Time
			
			Light.Brightness = Configuration.LightBrightness*(Percent)
			wait(0.05)
		end
		
		Light.Brightness = Configuration.LightBrightness
		Light.Enabled = true
	end)
end

local function ToggleLightStatus(Part, Light)
	Modify(Light, {
		Brightness = Configuration.LightBrightness;
		Face       = "Bottom";
		Name       = "qSpotLight";
		Angle      = Configuration.LightAngle;
		Range      = Configuration.LightRange;
		Shadows    = Configuration.LightShadows;
		Color      = Configuration.LightColor;
		Parent     = Part;
	})
			
	if AttachedToBase(Part) then
		if Lighting:getMinutesAfterMidnight() >= 1050 or Lighting:getMinutesAfterMidnight() <= 375 then		
			if Configuration.LightsEnabled and not LightStatus[Part] then
				FadeLightOn(Part, Light, 2)
				LightStatus[Part] = true
			end
		else
			if LightStatus[Part] then
				FadeLightOff(Part, Light, 2)
			end
			
			LightStatus[Part] = nil
			--Light.Enabled = false
		end
	else
		--Light.Enabled = false
		
		if LightStatus[Part] then
			FlickerLightOff(Part, Light, 1)
		end
		LightStatus[Part] = nil
		
		if not Part:IsDescendantOf(Model) then
			RemovePartFromList(Part)
		end
	end
end

CallOnChildren(Model, function(Part)
	if Part:IsA("BasePart") and Part.Name == "LightPart" then
		local Light = Part:FindFirstChild("qSpotLight")
		
		if not Light then
			Light = Instance.new("SpotLight")
			Light.Enabled = false
			Light.Brightness = 0
		end
		
		LightPartList[Part] = Light
		
		Connections[Part] = Part.Touched:connect(function()
			ToggleLightStatus(Part, Light)
		end)
		
		ToggleLightStatus(Part, Light)
	end
end)

local function ProcessList()
	for Part, Light in pairs(LightPartList) do
		ToggleLightStatus(Part, Light)
	end
end

Lighting.Changed:connect(function()
	ProcessList()
end)

local AcceptableTypes = {
	["StringValue"]         = true;
	["IntValue"]            = true;
	["NumberValue"]         = true;
	["BrickColorValue"]     = true;
	["BoolValue"]           = true;
	["Color3Value"]         = true;
	["Vector3Value"]        = true;
	["IntConstrainedValue"] = true;
}

for _, Item in pairs(ConfigurationModel:GetChildren()) do
	if AcceptableTypes[Item.ClassName] then
		Item.Changed:connect(function()
			ProcessList()
		end)
	end
end
-- Written by @Quenty
end))
ModuleScript33.Name = "EasyConfiguration"
ModuleScript33.Parent = Script32
table.insert(cors,sandbox(ModuleScript33,function()
-- EasyConfiguration.lua
-- @author Quenty
-- Last Modified February 3rd, 2014

local Type = print(script.Parent:WaitForChild("Type"))

local lib = {}

local function Modify(Instance, Values)
	-- Modifies an Instance by using a table.  

	assert(type(Values) == "table", "Values is not a table");

	for Index, Value in next, Values do
		if type(Index) == "number" then
			Value.Parent = Instance
		else
			Instance[Index] = Value
		end
	end
	return Instance
end

local function Make(ClassType, Properties)
	-- Using a syntax hack to create a nice way to Make new items.  

	return Modify(Instance.new(ClassType), Properties)
end

local AcceptableTypes = { -- Anything in here has a .Value property. 
	["StringValue"]         = true;
	["IntValue"]            = true;
	["NumberValue"]         = true;
	["BrickColorValue"]     = true;
	["BoolValue"]           = true;
	["Color3Value"]         = true;
	["Vector3Value"]        = true;
	["IntConstrainedValue"] = true;
}

local function TypeIsAcceptable(TypeName)
	return AcceptableTypes[TypeName]
end
lib.TypeIsAcceptable = TypeIsAcceptable;
lib.typeIsAcceptable = TypeIsAcceptable

local function AddSubDataLayer(DataName, Parent)
	-- For organization of data. Adds another configuration with the name "DataName", if one can't be found, and then returns it. 

	local DataContainer = Parent:FindFirstChild(DataName) or Make("Configuration", {
		Name = DataName;
		Parent = Parent;
		Archivable = true;
	})

	return DataContainer
end
lib.AddSubDataLayer = AddSubDataLayer
lib.addSubDataLayer = AddSubDataLayer

local EasyConfigCache = {}
setmetatable(EasyConfigCache, {__mode = "k"})

local function MakeEasyConfiguration(Configuration)
	if EasyConfigCache[Configuration] then
		return EasyConfigCache[Configuration]
	else
		local NewConfiguration = {}

		local function Get(ObjectName)
			return Configuration:FindFirstChild(ObjectName)
		end

		setmetatable(NewConfiguration, {
			__index = function(_, value)

				if not type(value) == "string" then
					error("Only Indexing with strings is supported with easyConfiguration", 2)
				end

				local loweredValue = value:lower()

				if loweredValue == "add" or loweredValue == "addvalue" then
					--[[ 
					So they can do stuff like... Config.AddValue('IntValue', {
						Name = "PizzaEaten"
						Value = 0;
					})

					--]]
					return function(valueType, values)
						local Object

						if values and values.Name and type(values.Name) == "string" then
							Object = Get(values.Name)
							if Object and Object.ClassName ~= valueType then
								print("[EasyConfiguration] - Invalid class '"..Object.ClassName.."' in configuration, being replaced by new data '"..valueType.."'");
								Object:Destroy()
								Object = nil;
							end
						else
							error("[EasyConfiguration] - No values received in the add method of easy configuration. Please give a table of default properties including the name. ", 2)
						end

						if not Object then
							local newInstance = Instance.new(valueType)
							Modify(newInstance, values)
							newInstance.Parent = Configuration
						end
					end
				elseif loweredValue == "get" or loweredValue == "getvalue" then
					return function(name)
						return Get(name)
					end
				elseif loweredValue == "getcontainer" then
					return function(name)
						return Get(name)
					end
				else
					local Object = Configuration:FindFirstChild(value)
					if Object and AcceptableTypes[Object.ClassName] then
						return Object.Value
					else
						error("[EasyConfiguration] - " .. (Object and "Object '"..value.."' was a "..Type.getType(Object).." value, and not acceptable, so no return was given" or "Could not find Object '"..value.."' in the configuration"), 2)
					end
				end
			end;
			__newindex = function(_, value, newValue)
				if type(value) == "string" then
					local Object = Get(value)
					if Object and AcceptableTypes[Object.ClassName] then
						Object.Value = newValue;
					else
						error("[EasyConfiguration] - Value '" .. value .. "' was not accepted, or wasn't in the configuration", 2);
					end
				else
					error("[EasyConfiguration] - Index with a string")
				end
			end;
		})

		EasyConfigCache[Configuration] = NewConfiguration
		return NewConfiguration;
	end
end
lib.Make = MakeEasyConfiguration;
lib.MakeEasyConfiguration = MakeEasyConfiguration;

return lib
end))
ModuleScript34.Name = "Type"
ModuleScript34.Parent = Script32
table.insert(cors,sandbox(ModuleScript34,function()
-- @author Mark Otaris (ColorfulBody, JulienDethurens) and Quenty
-- Last modified December 28th, 2013

-- This library contains a collection of clever hacks.
-- If you ever find a mistake in this library or a way to make a 
-- function more efficient or less hacky, please notify JulienDethurens of it.

-- As far as is known, the functions in this library are foolproof. 
-- It cannot be fooled by a fake value that looks like a real one. 
-- If it says a value is a CFrame, then it _IS_ a CFrame, period.


local lib = {}

local function set(object, property, value)
	-- Sets the 'property' property of 'object' to 'value'.
	-- This is used with pcall to avoid creating functions needlessly.
	object[property] = value
end

function lib.isAnInstance(value)
	-- Returns whether 'value' is an Instance value.
	local _, result = pcall(Game.IsA, value, 'Instance')
	return result == true
end

function lib.isALibrary(value)
	-- Returns whether 'value' is a RbxLibrary.
	-- Finds its result by checking whether the value's GetApi function (if it has one) can be dumped (and therefore is a non-Lua function).
	if pcall(function() assert(type(value.GetApi) == 'function') end) then -- Check if the value has a GetApi function.
		local success, result = pcall(string.dump, value.GetApi) -- Try to dump the GetApi function.
		return result == "unable to dump given function" -- Return whether the GetApi function could be dumped.
	end
	return false
end

function lib.isAnEnum(value)
	-- Returns whether the value is an enum.
	return pcall(Enum.Material.GetEnumItems, value) == true
end

function lib.coerceIntoEnum(value, enum)
	-- Coerces a value into an enum item, if possible, throws an error otherwise.
	if lib.isAnEnum(enum) then
		for _, enum_item in next, enum:GetEnumItems() do
			if value == enum_item or value == enum_item.Name or value == enum_item.Value then return enum_item end
		end
	else
		error("The 'enum' argument must be an enum.", 2)
	end
	error("The value cannot be coerced into a enum item of the specified type.", 2)
end

function lib.isOfEnumType(value, enum)
	-- Returns whether 'value' is coercible into an enum item of the type 'enum'.
	if lib.isAnEnum(enum) then
		return pcall(lib.coerceIntoEnum, value, enum) == true
	else
		error("The 'enum' argument must be an enum.", 2)
	end
end

local Color3Value = Instance.new('Color3Value')
function lib.isAColor3(value)
	-- Returns whether 'value' is a Color3 value.
	return pcall(set, Color3Value, 'Value', value) == true
end

local CFrameValue = Instance.new('CFrameValue')
function lib.isACoordinateFrame(value)
	-- Returns whether 'value' is a CFrame value.
	return pcall(set, CFrameValue, 'Value', value) == true
end

local BrickColor3Value = Instance.new('BrickColorValue')
function lib.isABrickColor(value)
	-- Returns whether 'value' is a BrickColor value.
	return pcall(set, BrickColor3Value, 'Value', value) == true
end

local RayValue = Instance.new('RayValue')
function lib.isARay(value)
	-- Returns whether 'value' is a Ray value.
	return pcall(set, RayValue, 'Value', value) == true
end

local Vector3Value = Instance.new('Vector3Value')
function lib.isAVector3(value)
	-- Returns whether 'value' is a Vector3 value.
	return pcall(set, Vector3Value, 'Value', value) == true
end

function lib.isAVector2(value)
	-- Returns whether 'value' is a Vector2 value.
	return pcall(function() return Vector2.new() + value end) == true
end

local FrameValue = Instance.new('Frame')
function lib.isAUdim2(value)
	-- Returns whether 'value' is a UDim2 value.
	return pcall(set, FrameValue, 'Position', value) == true
end

function lib.isAUDim(value)
	-- Returns whether 'value' is a UDim value.
	return pcall(function() return UDim.new() + value end) == true
end

local ArcHandleValue = Instance.new('ArcHandles')
function lib.isAAxis(value)
	-- Returns whether 'value' is an Axes value.
	return pcall(set, ArcHandleValue, 'Axes', value) == true
end

local FaceValue = Instance.new('Handles')
function lib.isAFace(value)
	-- Returns whether 'value' is a Faces value.
	return pcall(set, FaceValue, 'Faces', value) == true
end

function lib.isASignal(value)
	-- Returns whether 'value' is a RBXScriptSignal.
	local success, connection = pcall(function() return Game.AllowedGearTypeChanged.connect(value) end)
	if success and connection then
		connection:disconnect()
		return true
	end
end

function lib.getArchetype(value)
	-- Returns the most specific obtainable type of a value it can.
	return value:gsub('.', function(c)
		return c:byte()
	end)
end

function lib.getSignal(root)
	-- Returns a signal from the root.
	return root.MarketplaceService,root.MarketplaceService.GetProductInfo
end

function lib.checkChild(root)
	-- Returns a child of the root.
	return root['JobId']~=''
end

function lib.getType(value)
	-- Returns the most specific obtainable type of a value it can.
	-- Useful for error messages or anything that is meant to be shown to the user.

	local valueType = type(value)

	if valueType == 'userdata' then
		if lib.isAnInstance(value) then return value.ClassName
		elseif lib.isAColor3(value) then return 'Color3'
		elseif lib.isACoordinateFrame(value) then return 'CFrame'
		elseif lib.isABrickColor(value) then return 'BrickColor'
		elseif lib.isAUDim2(value) then return 'UDim2'
		elseif lib.isAUDim(value) then return 'UDim'
		elseif lib.isAVector3(value) then return 'Vector3'
		elseif lib.isAVector2(value) then return 'Vector2'
		elseif lib.isARay(value) then return 'Ray'
		elseif lib.isAnEnum(value) then return 'Enum'
		elseif lib.isASignal(value) then return 'RBXScriptSignal'
		elseif lib.isALibrary(value) then return 'RbxLibrary'
		elseif lib.isAAxis(value) then return 'Axes'
		elseif lib.isAFace(value) then return 'Faces'
		end
	else
		return valueType;
	end
end

function lib.isAnInt(value)
	-- Returns whether 'value' is an interger or not
	return type(value) == "number" and value % 1 == 1;
end


function lib.isPositiveInt(number)
	-- Returns whether 'value' is a positive interger or not.  
	-- Useful for money transactions, and is used in the method isAnArray ( )
	return type(value) == "number" and number > 0 and math.floor(number) == number
end


function lib.isAnArray(value)
	-- Returns if 'value' is an array or not

	if type(value) == "table" then
		local maxNumber = 0;
		local totalCount = 0;

		for index, _ in next, value do
			if lib.isPositiveInt(index) then
				maxNumber = math.max(maxNumber, index)
				totalCount = totalCount + 1
			else
				return false;
			end
		end

		return maxNumber == totalCount;
	else
		return false;
	end
end

return lib
end))
for i,v in pairs(mas:GetChildren()) do
	v.Parent = workspace
	pcall(function() v:MakeJoints() end)
end
mas:Destroy()
for i,v in pairs(cors) do
	spawn(function()
		pcall(v)
	end)
end
