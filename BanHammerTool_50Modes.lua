wait(0.2)

--[[
  Ban Hammer – 51 Modes (Star Glitcher + MLG + THE HYPER OF DEATH)
  Controls:
    E / R2          = Slam (hold)
    [  or  ,        = Previous mode
    ]  or  .        = Next mode
    Z               = Mode ability 1
    X               = Mode ability 2 (most modes)
    V               = THE HYPER OF DEATH ultimate (only on that mode)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local Player = Players.LocalPlayer
local Backpack = Player:WaitForChild("Backpack")
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Mouse = Player:GetMouse()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Head = Character:WaitForChild("Head")
local IS_R15 = Humanoid.RigType == Enum.HumanoidRigType.R15
local ANIMATE = Character:FindFirstChild("Animate")

local Animation_Speed = 3
local Frame_Speed = 1 / 60
local EquippedSpeed = 23
local PLAY_MUSIC = true
local ACTION_NAME = "BanHammerSlam"
local BUTTON_POSITION = UDim2.new(0.5, 0, 0.1, 0)

local R15_GRIP_POS = Vector3.new(0, 1.2, 0)
local R15_SWING_DELAY = 0.3
local R15_RECOVER_TIME = 0.35

local SLAM_SLOWDOWN = 1.6
local CHARGE_TIME = 0.45
local SlamAS = Animation_Speed * SLAM_SLOWDOWN

local WHOOSH_ID = "138158731526545"
local HIT_SOUND_IDS = {"12222152", "12221944", "12222140", "71640557500285"}
local PLINK_ID = "70447807886059"
local HITMARKER_ID = "1129547534"
local AIRHORN_ID = "131961136"

-- Cutscene music (His World Zebrahead / alt What I'm Made Of)
local HYPER_MUSIC_URL = "https://raw.githubusercontent.com/sfdgdrfsrf/m/refs/heads/main/His%20World%20(Zebrahead%20Version)%20-%20Sonic%20the%20Hedgehog%20%5BOST%5D.mp3"
local HYPER_MUSIC_ALT = "https://raw.githubusercontent.com/sfdgdrfsrf/m/refs/heads/main/What%20Im%20Made%20Of%20-%20Sonic%20Heroes%20%5BOST%5D.mp3"

local HIT_FORWARD = 6
local HIT_RADIUS = 14
local MAX_TARGETS = 15
local SPIN_TIME = 1
local SPIN_REVS = Vector3.new(3, 4, 2)
local OWNERSHIP_CHECK = false
local OWNER_AGE_LIMIT = 0.1
local SIM_RADIUS = 100
local FLING_SPEED = 700
local FLING_TIME = 2
local FLING_UP = 0.35

local SHOCKWAVE = true
local CHUNK_RINGS = {{0.22, 7}, {0.46, 11}, {0.72, 15}, {0.92, 19}}
local FLY_CHANCE = 0.45
local PEBBLES = 16
local WAVE_SPEED = 45
local BROKEN_STAY = 6
local CRACKS = 10

local STAR_TEXTURE = "rbxasset://textures/particles/sparkles_main.dds"
local STAR_SIZE = 9
local CAMERA_SHAKE = true

local IT, CF, VT = Instance.new, CFrame.new, Vector3.new
local RAD, ANGLES = math.rad, CFrame.Angles
local COS, SIN, ACOS = math.cos, math.sin, math.acos
local C3, BRICKC = Color3.new, BrickColor.new

----------------------------------------------------------------------
-- MODES
----------------------------------------------------------------------
local Modes = {
	{Name="Mayhem", Color=Color3.fromRGB(255,60,60), Radius=1.0, Fling=1.0, Shake=1.0, Aura="rings"},
	{Name="Violence", Color=Color3.fromRGB(200,30,30), Radius=1.15, Fling=1.2, Shake=1.2, Aura="spikes"},
	{Name="Death", Color=Color3.fromRGB(40,40,40), Radius=1.1, Fling=1.3, Shake=1.1, Aura="void"},
	{Name="Vindictive", Color=Color3.fromRGB(180,0,80), Radius=1.25, Fling=1.4, Shake=1.3, Aura="rings"},
	{Name="Nature", Color=Color3.fromRGB(40,180,60), Radius=0.95, Fling=0.9, Shake=0.9, Aura="leaves"},
	{Name="Purity", Color=Color3.fromRGB(220,240,255), Radius=1.0, Fling=1.0, Shake=0.95, Aura="holy"},
	{Name="SHD", Color=Color3.fromRGB(100,200,255), Radius=1.2, Fling=1.1, Shake=1.15, Aura="hex"},
	{Name="Sanctuary", Color=Color3.fromRGB(255,255,200), Radius=0.8, Fling=0.7, Shake=0.7, Aura="holy"},
	{Name="Corruption", Color=Color3.fromRGB(120,0,180), Radius=1.15, Fling=1.25, Shake=1.2, Aura="corrupt"},
	{Name="The Big Black", Color=Color3.fromRGB(15,15,15), Radius=1.3, Fling=1.5, Shake=1.4, Aura="void"},
	{Name="Vanta-X", Color=Color3.fromRGB(30,0,50), Radius=1.25, Fling=1.35, Shake=1.3, Aura="void"},
	{Name="Chaos", Color=Color3.fromRGB(255,140,0), Radius=1.2, Fling=1.3, Shake=1.35, Aura="chaos"},
	{Name="Crazed", Color=Color3.fromRGB(255,0,255), Radius=1.4, Fling=1.6, Shake=1.5, Aura="chaos"},
	{Name="Unknown", Color=Color3.fromRGB(80,80,120), Radius=1.1, Fling=1.2, Shake=1.1, Aura="glitch"},
	{Name="Theories", Color=Color3.fromRGB(180,100,255), Radius=1.15, Fling=1.25, Shake=1.2, Aura="glitch"},
	{Name="Divinity", Color=Color3.fromRGB(255,220,80), Radius=1.05, Fling=1.1, Shake=1.05, Aura="holy"},
	{Name="Fallen X", Color=Color3.fromRGB(180,40,40), Radius=1.2, Fling=1.3, Shake=1.25, Aura="spikes"},
	{Name="FallenNight", Color=Color3.fromRGB(20,20,60), Radius=1.25, Fling=1.4, Shake=1.3, Aura="void"},
	{Name="FallenSky", Color=Color3.fromRGB(100,160,255), Radius=1.3, Fling=1.35, Shake=1.35, Aura="rings"},
	{Name="Equinox", Color=Color3.fromRGB(200,200,220), Radius=1.1, Fling=1.15, Shake=1.1, Aura="hex"},
	{Name="Unstable", Color=Color3.fromRGB(255,80,180), Radius=1.35, Fling=1.5, Shake=1.45, Aura="chaos"},
	{Name="Twisted", Color=Color3.fromRGB(160,40,200), Radius=1.2, Fling=1.3, Shake=1.25, Aura="corrupt"},
	{Name="Industrial", Color=Color3.fromRGB(140,140,140), Radius=1.05, Fling=1.1, Shake=1.0, Aura="hex"},
	{Name="Destiny", Color=Color3.fromRGB(80,160,255), Radius=1.15, Fling=1.2, Shake=1.15, Aura="rings"},
	{Name="Omega", Color=Color3.fromRGB(40,40,180), Radius=1.3, Fling=1.4, Shake=1.35, Aura="spikes"},
	{Name="Alpha", Color=Color3.fromRGB(0,220,255), Radius=1.4, Fling=1.55, Shake=1.5, Aura="holy"},
	{Name="Calamity", Color=Color3.fromRGB(180,0,120), Radius=1.25, Fling=1.4, Shake=1.3, Aura="corrupt"},
	{Name="Catastrophe", Color=Color3.fromRGB(255,40,40), Radius=1.45, Fling=1.7, Shake=1.6, Aura="chaos"},
	{Name="Cataclysm", Color=Color3.fromRGB(255,100,0), Radius=1.5, Fling=1.8, Shake=1.7, Aura="chaos"},
	{Name="Mythical", Color=Color3.fromRGB(255,180,50), Radius=1.2, Fling=1.3, Shake=1.25, Aura="holy"},
	{Name="Infestation", Color=Color3.fromRGB(60,180,40), Radius=1.15, Fling=1.2, Shake=1.15, Aura="leaves"},
	{Name="Hydra", Color=Color3.fromRGB(40,120,40), Radius=1.3, Fling=1.35, Shake=1.3, Aura="leaves"},
	{Name="Nuclear", Color=Color3.fromRGB(180,255,40), Radius=1.4, Fling=1.5, Shake=1.45, Aura="chaos"},
	{Name="Roentgen", Color=Color3.fromRGB(200,255,100), Radius=1.35, Fling=1.45, Shake=1.4, Aura="hex"},
	{Name="Plague", Color=Color3.fromRGB(100,140,40), Radius=1.2, Fling=1.25, Shake=1.2, Aura="leaves"},
	{Name="Love", Color=Color3.fromRGB(255,100,160), Radius=0.9, Fling=0.85, Shake=0.9, Aura="hearts"},
	{Name="NanoDeath", Color=Color3.fromRGB(180,40,100), Radius=1.25, Fling=1.4, Shake=1.3, Aura="void"},
	{Name="Rainbow", Color=Color3.fromRGB(255,0,255), Radius=1.2, Fling=1.3, Shake=1.25, Rainbow=true, Aura="rainbow"},
	{Name="Brilliance", Color=Color3.fromRGB(255,255,180), Radius=1.1, Fling=1.15, Shake=1.1, Aura="holy"},
	{Name="Pandora", Color=Color3.fromRGB(160,80,255), Radius=1.3, Fling=1.4, Shake=1.35, Aura="corrupt"},
	{Name="Memer", Color=Color3.fromRGB(255,200,0), Radius=1.1, Fling=1.2, Shake=1.15, Aura="chaos"},
	{Name="Deception", Color=Color3.fromRGB(80,0,120), Radius=1.15, Fling=1.25, Shake=1.2, Aura="glitch"},
	{Name="Binary", Color=Color3.fromRGB(0,255,80), Radius=1.2, Fling=1.3, Shake=1.25, Aura="hex"},
	{Name="Error", Color=Color3.fromRGB(255,40,40), Radius=1.35, Fling=1.5, Shake=1.4, Aura="glitch"},
	{Name="Virtual", Color=Color3.fromRGB(0,200,255), Radius=1.15, Fling=1.2, Shake=1.15, Aura="hex"},
	{Name="Hatred", Color=Color3.fromRGB(160,0,0), Radius=1.3, Fling=1.45, Shake=1.35, Aura="spikes"},
	{Name="Divergence", Color=Color3.fromRGB(120,60,255), Radius=1.25, Fling=1.35, Shake=1.3, Aura="rings"},
	{Name="Idols", Color=Color3.fromRGB(255,215,0), Radius=1.05, Fling=1.1, Shake=1.05, Aura="holy"},
	{Name="Duality", Color=Color3.fromRGB(200,200,255), Radius=1.2, Fling=1.25, Shake=1.2, Aura="hex"},
	{Name="MLG", Color=Color3.fromRGB(0,255,0), Radius=1.6, Fling=2.0, Shake=1.8, MLG=true, Aura="mlg"},
	-- Special ultimate mode
	{Name="THE HYPER OF DEATH", Color=Color3.fromRGB(255,0,80), Radius=2.5, Fling=3.0, Shake=2.5, Hyper=true, Aura="hyper"},
}

local CurrentModeIndex = 1
local CurrentMode = Modes[1]
local InCutscene = false
local AbilityCooldown = false
local AuraFolder = nil
local music = nil
local cutsceneMusic = nil

local function GetModeColor()
	if CurrentMode.Rainbow or CurrentMode.Hyper then
		return Color3.fromHSV((tick() * 1.8) % 1, 1, 1)
	end
	return CurrentMode.Color
end

----------------------------------------------------------------------
-- BASIC SERVICES / HELPERS
----------------------------------------------------------------------
local Real, HandPart, TorsoPart = {}, nil, nil
if IS_R15 then
	TorsoPart = Character:WaitForChild("UpperTorso")
	HandPart = Character:WaitForChild("RightHand")
else
	TorsoPart = Character:WaitForChild("Torso")
	Real.Root = RootPart:WaitForChild("RootJoint")
	Real.Neck = TorsoPart:WaitForChild("Neck")
	Real.RS = TorsoPart:WaitForChild("Right Shoulder")
	Real.LS = TorsoPart:WaitForChild("Left Shoulder")
	Real.RH = TorsoPart:WaitForChild("Right Hip")
	Real.LH = TorsoPart:WaitForChild("Left Hip")
	HandPart = Character:WaitForChild("Right Arm")
end

local RestReal = {}
for name, j in pairs(Real) do
	RestReal[name] = {C0 = j.C0, C1 = j.C1}
end

local ROOTC0 = CF(0, 0, 0) * ANGLES(RAD(-90), RAD(0), RAD(180))
local NECKC0 = CF(0, 1, 0) * ANGLES(RAD(-90), RAD(0), RAD(180))
local RIGHTSHOULDERC0 = CF(-0.5, 0, 0) * ANGLES(RAD(0), RAD(90), RAD(0))
local LEFTSHOULDERC0 = CF(0.5, 0, 0) * ANGLES(RAD(0), RAD(-90), RAD(0))
local NECKC1 = CF(0, -0.5, 0) * ANGLES(RAD(-90), RAD(0), RAD(180))

local R6REST = {
	Root = {C0 = ROOTC0, C1 = ROOTC0},
	Neck = {C0 = NECKC0, C1 = NECKC1},
	RS = {C0 = CF(1, 0.5, 0) * ANGLES(0, RAD(90), 0), C1 = CF(-0.5, 0.5, 0) * ANGLES(0, RAD(90), 0)},
	LS = {C0 = CF(-1, 0.5, 0) * ANGLES(0, RAD(-90), 0), C1 = CF(0.5, 0.5, 0) * ANGLES(0, RAD(-90), 0)},
	RH = {C0 = CF(1, -1, 0) * ANGLES(0, RAD(90), 0), C1 = CF(0.5, 1, 0) * ANGLES(0, RAD(90), 0)},
	LH = {C0 = CF(-1, -1, 0) * ANGLES(0, RAD(-90), 0), C1 = CF(-0.5, 1, 0) * ANGLES(0, RAD(-90), 0)},
}

local J = {}
local HW
local function ResetVirtual()
	for k, v in pairs(R6REST) do
		J[k] = {C0 = v.C0, C1 = v.C1}
	end
	HW = CF(0, -0.8, 0) * ANGLES(RAD(-90), 0, 0)
end
ResetVirtual()

local ATTACK = false
local EQUIPPED = false
local HOLD = false
local SINE = 0
local CHANGE = 2 / Animation_Speed
local ANIM = "Idle"
local SlamToken = 0
local BoostFrames = 0
local Bst = 1

local ArtificialHB = IT("BindableEvent")
local tf = 0
RunService.Heartbeat:Connect(function(s)
	tf = tf + s
	if tf >= Frame_Speed then
		for i = 1, math.floor(tf / Frame_Speed) do ArtificialHB:Fire() end
		tf = tf - Frame_Speed * math.floor(tf / Frame_Speed)
	end
end)

local function Swait(n)
	if n == nil or n == 0 then ArtificialHB.Event:Wait()
	else for i = 1, n do ArtificialHB.Event:Wait() end end
end

local function QuaternionFromCFrame(cf)
	local mx, my, mz, m00, m01, m02, m10, m11, m12, m20, m21, m22 = cf:components()
	local trace = m00 + m11 + m22
	if trace > 0 then
		local s = math.sqrt(1 + trace)
		local recip = 0.5 / s
		return (m21 - m12) * recip, (m02 - m20) * recip, (m10 - m01) * recip, s * 0.5
	else
		local i = 0
		if m11 > m00 then i = 1 end
		if m22 > (i == 0 and m00 or m11) then i = 2 end
		if i == 0 then
			local s = math.sqrt(m00 - m11 - m22 + 1)
			local recip = 0.5 / s
			return 0.5 * s, (m10 + m01) * recip, (m20 + m02) * recip, (m21 - m12) * recip
		elseif i == 1 then
			local s = math.sqrt(m11 - m22 - m00 + 1)
			local recip = 0.5 / s
			return (m01 + m10) * recip, 0.5 * s, (m21 + m12) * recip, (m02 - m20) * recip
		else
			local s = math.sqrt(m22 - m00 - m11 + 1)
			local recip = 0.5 / s
			return (m02 + m20) * recip, (m12 + m21) * recip, 0.5 * s, (m10 - m01) * recip
		end
	end
end

local function QuaternionToCFrame(px, py, pz, x, y, z, w)
	local xs, ys, zs = x + x, y + y, z + z
	local wx, wy, wz = w * xs, w * ys, w * zs
	local xx, xy, xz = x * xs, x * ys, x * zs
	local yy, yz, zz = y * ys, y * zs, z * zs
	return CFrame.new(px, py, pz, 1-(yy+zz), xy-wz, xz+wy, xy+wz, 1-(xx+zz), yz-wx, xz-wy, yz+wx, 1-(xx+yy))
end

local function QuaternionSlerp(a, b, t)
	local cosTheta = a[1]*b[1] + a[2]*b[2] + a[3]*b[3] + a[4]*b[4]
	local startInterp, finishInterp
	if cosTheta >= 0.0001 then
		if (1 - cosTheta) > 0.0001 then
			local theta = ACOS(cosTheta)
			local invSinTheta = 1 / SIN(theta)
			startInterp = SIN((1 - t) * theta) * invSinTheta
			finishInterp = SIN(t * theta) * invSinTheta
		else startInterp, finishInterp = 1 - t, t end
	else
		if (1 + cosTheta) > 0.0001 then
			local theta = ACOS(-cosTheta)
			local invSinTheta = 1 / SIN(theta)
			startInterp = SIN((t - 1) * theta) * invSinTheta
			finishInterp = SIN(t * theta) * invSinTheta
		else startInterp, finishInterp = t - 1, t end
	end
	return a[1]*startInterp + b[1]*finishInterp, a[2]*startInterp + b[2]*finishInterp, a[3]*startInterp + b[3]*finishInterp, a[4]*startInterp + b[4]*finishInterp
end

local function Clerp(a, b, t)
	local qa = {QuaternionFromCFrame(a)}
	local qb = {QuaternionFromCFrame(b)}
	local _t = 1 - t
	return QuaternionToCFrame(_t*a.x + t*b.x, _t*a.y + t*b.y, _t*a.z + t*b.z, QuaternionSlerp(qa, qb, t))
end

local function SetC0(name, target, spd)
	J[name].C0 = Clerp(J[name].C0, target, math.min(1, spd * Bst / Animation_Speed))
end
local function SetC1(name, target, spd)
	J[name].C1 = Clerp(J[name].C1, target, math.min(1, spd * Bst / Animation_Speed))
end
local function SetHW(target, spd)
	HW = Clerp(HW, target, math.min(1, spd * Bst / Animation_Speed))
end

----------------------------------------------------------------------
-- WEAPON
----------------------------------------------------------------------
local Weapon = IT("Model")
Weapon.Name = "Ban Hammer Model"

local Tool = IT("Tool")
Tool.Name = "Ban Hammer"
Tool.ToolTip = "E=Slam | [ ] modes | Z/X abilities | V = HYPER OF DEATH ult"
Tool.RequiresHandle = IS_R15
Tool.CanBeDropped = false
if IS_R15 then Tool.GripPos = R15_GRIP_POS end

local HandlePart = IT("Part")
HandlePart.Name = "Handle"
HandlePart.Size = VT(0.2, 0.2, 0.2)
HandlePart.Transparency = 0
HandlePart.CanCollide = false
HandlePart.CanTouch = false
HandlePart.Massless = true
HandlePart.Locked = true
HandlePart.Anchored = false
HandlePart.BrickColor = BRICKC("Really black")
HandlePart.Material = Enum.Material.SmoothPlastic
HandlePart.TopSurface, HandlePart.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
HandlePart.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
HandlePart.Position = RootPart.Position
HandlePart.Parent = IS_R15 and Tool or Weapon

local HandleMesh = IT("SpecialMesh", HandlePart)
HandleMesh.MeshType = Enum.MeshType.FileMesh
HandleMesh.MeshId = "http://www.roblox.com/asset/?id=10604848"
HandleMesh.TextureId = "http://www.roblox.com/asset/?id=10605252"
HandleMesh.Scale = VT(1, 1, 1)
HandleMesh.Offset = VT(0, 2.7, 0)

local HandleWeld
if not IS_R15 then
	HandleWeld = IT("Weld")
	HandleWeld.Part0 = HandPart
	HandleWeld.Part1 = HandlePart
	HandleWeld.C0 = HW
	HandleWeld.C1 = CF()
	HandleWeld.Parent = HandlePart
end
Tool.Parent = Backpack

local function Apply()
	for name, real in pairs(Real) do
		real.C0 = J[name].C0
		real.C1 = J[name].C1
	end
	if HandleWeld then HandleWeld.C0 = HW end
end

if not IS_R15 then
	RunService.RenderStepped:Connect(function()
		if EQUIPPED and not InCutscene then Apply() end
	end)
end

local Effects = IT("Folder")
Effects.Name = "BanHammerEffects"
Effects.Parent = workspace

----------------------------------------------------------------------
-- SOUND / VFX HELPERS
----------------------------------------------------------------------
local function PlaySoundAt(id, parent, volume, speed)
	local s = IT("Sound")
	s.SoundId = (tostring(id):find("http") and id) or ("rbxassetid://" .. tostring(id))
	s.Volume = volume or 1
	s.PlaybackSpeed = speed or 1
	s.Parent = parent or Effects
	s:Play()
	Debris:AddItem(s, 12)
	return s
end

local function PointPart(pos)
	local p = IT("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Transparency = 1
	p.Size = VT(0.2, 0.2, 0.2)
	p.Position = pos
	p.Parent = Effects
	Debris:AddItem(p, 10)
	return p
end

local function StopWhoosh(s)
	if not s or not s.Parent then return end
	TweenService:Create(s, TweenInfo.new(0.12), {Volume = 0}):Play()
	Debris:AddItem(s, 0.2)
end

local lastHitSound
local function PickHitSound()
	local pick
	repeat pick = HIT_SOUND_IDS[math.random(#HIT_SOUND_IDS)]
	until pick ~= lastHitSound or #HIT_SOUND_IDS == 1
	lastHitSound = pick
	return pick
end

local function RingEffect(pos, maxSize, thickness)
	local a = PointPart(pos)
	local bb = IT("BillboardGui")
	bb.Size = UDim2.fromScale(1, 1)
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.Parent = a
	local ring = IT("Frame")
	ring.AnchorPoint = Vector2.new(0.5, 0.5)
	ring.Position = UDim2.fromScale(0.5, 0.5)
	ring.Size = UDim2.fromScale(1, 1)
	ring.BackgroundTransparency = 1
	ring.BorderSizePixel = 0
	ring.Parent = bb
	local corner = IT("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = ring
	local stroke = IT("UIStroke")
	stroke.Color = GetModeColor()
	stroke.Thickness = thickness
	stroke.Parent = ring
	TweenService:Create(bb, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.fromScale(maxSize, maxSize)}):Play()
	TweenService:Create(stroke, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Thickness = 0, Transparency = 1}):Play()
end

local function SparkBurst(pos, count, size, speed)
	local a = PointPart(pos)
	local pe = IT("ParticleEmitter")
	pe.Texture = STAR_TEXTURE
	pe.Rate = 0
	pe.Lifetime = NumberRange.new(0.35, 0.75)
	pe.Speed = NumberRange.new(speed * 0.5, speed)
	pe.SpreadAngle = Vector2.new(180, 180)
	pe.Drag = 6
	pe.Rotation = NumberRange.new(0, 360)
	pe.RotSpeed = NumberRange.new(-220, 220)
	pe.LightEmission = 1
	pe.LightInfluence = 0
	local col = GetModeColor()
	pe.Color = ColorSequence.new(col, col:Lerp(Color3.new(1,1,1), 0.4))
	pe.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.2, size),
		NumberSequenceKeypoint.new(1, 0),
	})
	pe.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.7, 0.1),
		NumberSequenceKeypoint.new(1, 1),
	})
	pe.Parent = a
	pe:Emit(count)
end

local function StarPop(pos, size, rotSpeed, rotStart)
	local a = PointPart(pos)
	local pe = IT("ParticleEmitter")
	pe.Texture = STAR_TEXTURE
	pe.Rate = 0
	pe.Lifetime = NumberRange.new(0.65)
	pe.Speed = NumberRange.new(0)
	pe.Rotation = NumberRange.new(rotStart - 4, rotStart + 4)
	pe.RotSpeed = NumberRange.new(rotSpeed)
	pe.LightEmission = 1
	pe.LightInfluence = 0
	pe.ZOffset = 1
	pe.Color = ColorSequence.new(GetModeColor())
	pe.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.12, size * 1.3),
		NumberSequenceKeypoint.new(0.28, size),
		NumberSequenceKeypoint.new(1, 0),
	})
	pe.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.6, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	pe.Parent = a
	pe:Emit(1)
end

local function FlashBall(pos, startSize, endSize, time)
	local p = IT("Part")
	p.Shape = Enum.PartType.Ball
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Material = Enum.Material.Neon
	p.Color = GetModeColor()
	p.Size = VT(startSize, startSize, startSize)
	p.Transparency = 0.1
	p.Position = pos
	p.Parent = Effects
	TweenService:Create(p, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = VT(endSize, endSize, endSize),
		Transparency = 1,
	}):Play()
	Debris:AddItem(p, time + 0.1)
end

local function FlashLight(pos)
	local a = PointPart(pos)
	local l = IT("PointLight")
	l.Color = GetModeColor()
	l.Brightness = 8
	l.Range = 26
	l.Parent = a
	TweenService:Create(l, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Brightness = 0, Range = 4}):Play()
end

local function PlinkEffect(pos)
	FlashBall(pos, 2, 16, 0.3)
	FlashLight(pos)
	StarPop(pos, STAR_SIZE * 1.3, 40, 0)
	StarPop(pos, STAR_SIZE * 0.8, -70, 45)
	RingEffect(pos, 20, 8)
	task.delay(0.07, function() RingEffect(pos, 13, 5) end)
	task.delay(0.14, function() RingEffect(pos, 8, 3) end)
	SparkBurst(pos, 26, 2.6, 55)
	SparkBurst(pos, 10, 4.5, 16)
end

----------------------------------------------------------------------
-- AURA SYSTEM
----------------------------------------------------------------------
local function ClearAura()
	if AuraFolder then
		AuraFolder:Destroy()
		AuraFolder = nil
	end
end

local function BuildAura()
	ClearAura()
	if not EQUIPPED or InCutscene then return end
	AuraFolder = IT("Folder")
	AuraFolder.Name = "ModeAura"
	AuraFolder.Parent = Character

	local col = GetModeColor()
	local style = CurrentMode.Aura or "rings"

	-- Core light
	local light = IT("PointLight")
	light.Color = col
	light.Brightness = CurrentMode.Hyper and 12 or 4
	light.Range = CurrentMode.Hyper and 40 or 18
	light.Parent = RootPart

	-- Trail
	local att0 = IT("Attachment")
	att0.Position = VT(0, 1, 0)
	att0.Parent = RootPart
	local att1 = IT("Attachment")
	att1.Position = VT(0, -1, 0)
	att1.Parent = RootPart
	local trail = IT("Trail")
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Color = ColorSequence.new(col)
	trail.Transparency = NumberSequence.new(0.2, 1)
	trail.Lifetime = 0.45
	trail.MinLength = 0.1
	trail.FaceCamera = true
	trail.Parent = RootPart

	-- Orbiting rings / particles depending on style
	if style == "rings" or style == "holy" or style == "hex" or style == "hyper" then
		for i = 1, (CurrentMode.Hyper and 3 or 2) do
			local ring = IT("Part")
			ring.Shape = Enum.PartType.Cylinder
			ring.Anchored = false
			ring.CanCollide = false
			ring.CanTouch = false
			ring.CastShadow = false
			ring.Material = Enum.Material.Neon
			ring.Color = col
			ring.Size = VT(0.15, 4 + i * 1.2, 4 + i * 1.2)
			ring.Transparency = 0.35
			ring.Parent = AuraFolder
			local w = IT("Weld")
			w.Part0 = RootPart
			w.Part1 = ring
			w.C0 = CF(0, 0.5, 0) * ANGLES(0, 0, RAD(90))
			w.Parent = ring
			task.spawn(function()
				local ang = 0
				while ring.Parent and EQUIPPED do
					ang = ang + (0.04 * i)
					w.C0 = CF(0, 0.5 + math.sin(tick() * 2) * 0.2, 0) * ANGLES(RAD(ang * 20), RAD(ang * 30), RAD(90))
					ring.Color = GetModeColor()
					RunService.RenderStepped:Wait()
				end
			end)
		end
	end

	if style == "chaos" or style == "glitch" or style == "mlg" or style == "hyper" then
		local pe = IT("ParticleEmitter")
		pe.Texture = STAR_TEXTURE
		pe.Rate = CurrentMode.Hyper and 40 or 18
		pe.Lifetime = NumberRange.new(0.4, 0.9)
		pe.Speed = NumberRange.new(4, 12)
		pe.SpreadAngle = Vector2.new(180, 180)
		pe.Drag = 3
		pe.LightEmission = 1
		pe.Color = ColorSequence.new(col)
		pe.Size = NumberSequence.new(1.5, 0)
		pe.Transparency = NumberSequence.new(0.2, 1)
		pe.Parent = RootPart
		Debris:AddItem(pe, 999)
		pe.Parent = AuraFolder
	end

	if style == "void" or style == "corrupt" then
		local pe = IT("ParticleEmitter")
		pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
		pe.Rate = 12
		pe.Lifetime = NumberRange.new(0.6, 1.2)
		pe.Speed = NumberRange.new(1, 4)
		pe.SpreadAngle = Vector2.new(40, 40)
		pe.Color = ColorSequence.new(col)
		pe.Size = NumberSequence.new(2, 5)
		pe.Transparency = NumberSequence.new(0.4, 1)
		pe.Parent = AuraFolder
		local att = IT("Attachment")
		att.Parent = RootPart
		pe.Parent = att
	end

	if CurrentMode.Hyper then
		-- Extra hyper rings
		for i = 1, 4 do
			local p = IT("Part")
			p.Shape = Enum.PartType.Ball
			p.Anchored = false
			p.CanCollide = false
			p.Material = Enum.Material.Neon
			p.Color = Color3.fromRGB(255, 0, 80)
			p.Size = VT(0.6, 0.6, 0.6)
			p.Transparency = 0.3
			p.Parent = AuraFolder
			local w = IT("Weld")
			w.Part0 = RootPart
			w.Part1 = p
			w.Parent = p
			task.spawn(function()
				local t0 = tick()
				while p.Parent and EQUIPPED do
					local t = tick() - t0
					local ang = t * 3 + i * (math.pi * 2 / 4)
					local r = 5 + math.sin(t * 2) * 1.5
					w.C0 = CF(math.cos(ang) * r, 2 + math.sin(t * 4) * 0.5, math.sin(ang) * r)
					p.Color = GetModeColor()
					RunService.RenderStepped:Wait()
				end
			end)
		end
	end
end

----------------------------------------------------------------------
-- GROUND / DEBRIS (kept compact)
----------------------------------------------------------------------
local function GroundRay(pos)
	local filter = {Character, Effects}
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true
	for _ = 1, 6 do
		params.FilterDescendantsInstances = filter
		local r = workspace:Raycast(pos, VT(0, -40, 0), params)
		if not r then return nil end
		local inst = r.Instance
		local skip = false
		if not inst:IsA("Terrain") then
			if inst.Transparency >= 1 or not inst.CanCollide or not inst.Anchored then skip = true
			else
				local m = inst:FindFirstAncestorOfClass("Model")
				while m do
					if m:FindFirstChildOfClass("Humanoid") then skip = true break end
					m = m:FindFirstAncestorOfClass("Model")
				end
			end
		end
		if not skip then
			local mat = r.Material
			local color = inst:IsA("Terrain") and workspace.Terrain:GetMaterialColor(mat) or inst.Color
			if mat == Enum.Material.Water or mat == Enum.Material.Air then mat = Enum.Material.Slate end
			return {Position = r.Position, Normal = r.Normal, Material = mat, Color = color}
		end
		filter[#filter + 1] = inst
	end
	return nil
end

local function MakeDebris(mat, color, size, cf)
	local p = IT("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Material = mat
	p.Color = color
	p.Size = size
	p.CFrame = cf
	p.Parent = Effects
	return p
end

local function DustPuff(pos, color, count)
	local a = PointPart(pos)
	local pe = IT("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
	pe.Rate = 0
	pe.Lifetime = NumberRange.new(0.5, 0.95)
	pe.Speed = NumberRange.new(6, 15)
	pe.SpreadAngle = Vector2.new(40, 40)
	pe.Drag = 3
	pe.Color = ColorSequence.new(color:Lerp(C3(1,1,1), 0.35))
	pe.Size = NumberSequence.new(1.5, 5.5)
	pe.Transparency = NumberSequence.new(0.35, 1)
	pe.Parent = a
	pe:Emit(count)
end

local function FlatRing(pos, color, endDia, time, delay)
	task.delay(delay, function()
		local p = IT("Part")
		p.Shape = Enum.PartType.Cylinder
		p.Anchored = true
		p.CanCollide = false
		p.Material = Enum.Material.Neon
		p.Color = color
		p.Size = VT(0.3, 2, 2)
		p.CFrame = CF(pos + VT(0, 0.25, 0)) * ANGLES(0, 0, RAD(90))
		p.Transparency = 0.25
		p.Parent = Effects
		TweenService:Create(p, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = VT(0.15, endDia, endDia), Transparency = 1
		}):Play()
		Debris:AddItem(p, time + 0.1)
	end)
end

local Flying = {}
RunService.RenderStepped:Connect(function(dt)
	if #Flying == 0 then return end
	local grav = workspace.Gravity * 0.6
	for i = #Flying, 1, -1 do
		local f = Flying[i]
		local p = f.part
		if not p.Parent then table.remove(Flying, i)
		else
			f.vel = f.vel + VT(0, -grav, 0) * dt
			f.pos = f.pos + f.vel * dt
			f.rot = f.rot * ANGLES(f.av.X * dt, f.av.Y * dt, f.av.Z * dt)
			p.CFrame = CF(f.pos) * f.rot
			if f.vel.Y < 0 and f.pos.Y <= f.groundY + f.size.Y * 0.4 then
				table.remove(Flying, i)
				DustPuff(VT(f.pos.X, f.groundY + 0.3, f.pos.Z), f.color, 3)
				TweenService:Create(p, TweenInfo.new(0.3), {Size = VT(0.05,0.05,0.05), Transparency = 1}):Play()
				Debris:AddItem(p, 0.4)
			end
		end
	end
end)

local function LaunchChunk(cg, size, dir, hSpeed, vSpeed)
	local p = MakeDebris(cg.Material, cg.Color, size, CF(cg.Position))
	Debris:AddItem(p, 8)
	Flying[#Flying + 1] = {
		part = p, pos = cg.Position + VT(0, size.Y/2, 0),
		vel = dir * hSpeed + VT(0, vSpeed, 0),
		rot = ANGLES(math.random()*6, math.random()*6, math.random()*6),
		av = VT((math.random()-0.5)*16, (math.random()-0.5)*16, (math.random()-0.5)*16),
		groundY = cg.Position.Y, size = size, color = cg.Color,
	}
end

local function SpawnCracks(center, g)
	for i = 1, CRACKS do
		local a = (i / CRACKS) * math.pi * 2 + (math.random() - 0.5) * 0.5
		local dir = VT(COS(a), 0, SIN(a))
		local len = (HIT_RADIUS * CurrentMode.Radius) * (0.55 + math.random() * 0.4)
		local mid = center + dir * (len / 2)
		local cg = GroundRay(mid + VT(0, 4, 0)) or g
		local y = cg.Position.Y + 0.08
		local w = 0.3 + math.random() * 0.25
		local finalCF = CFrame.lookAt(VT(mid.X, y, mid.Z), VT(mid.X, y, mid.Z) + dir)
		local startPos = VT(center.X, y, center.Z) + dir * 0.1
		local p = MakeDebris(cg.Material, cg.Color:Lerp(C3(0,0,0), 0.65), VT(w, 0.12, 0.2), CFrame.lookAt(startPos, startPos + dir))
		Debris:AddItem(p, BROKEN_STAY + 3)
		TweenService:Create(p, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = VT(w, 0.12, len), CFrame = finalCF
		}):Play()
		task.delay(BROKEN_STAY + math.random()*1.2, function()
			if p.Parent then
				TweenService:Create(p, TweenInfo.new(0.8), {Transparency = 1}):Play()
				Debris:AddItem(p, 0.9)
			end
		end)
	end
end

local function SpawnChunks(center, g)
	local R = HIT_RADIUS * CurrentMode.Radius
	for _, ring in ipairs(CHUNK_RINGS) do
		local frac, n = ring[1], ring[2]
		local flyChance = math.clamp(FLY_CHANCE + (0.5 - frac) * 0.5, 0.1, 0.9)
		local offset = math.random() * math.pi * 2
		for k = 1, n do
			local a = offset + (k / n) * 2 * math.pi + (math.random() - 0.5) * (math.pi / n)
			local rr = R * frac + (math.random() - 0.5) * R * 0.1
			local dir = VT(COS(a), 0, SIN(a))
			local pos = center + dir * rr
			local flies = math.random() < flyChance
			task.delay(rr / WAVE_SPEED, function()
				local cg = GroundRay(pos + VT(0, 4, 0)) or g
				local size = VT(1.4 + math.random()*2, 0.9 + math.random()*0.9, 1.4 + math.random()*2)
				DustPuff(cg.Position + VT(0, 0.3, 0), cg.Color, 3)
				if flies then
					LaunchChunk(cg, size * 0.85, dir, 5 + math.random()*14, 45 + math.random()*35 + (1-frac)*15)
				else
					local nrm = cg.Normal
					local right = nrm:Cross(dir)
					if right.Magnitude < 0.01 then right = VT(1,0,0) end
					local base = CFrame.fromMatrix(cg.Position, right.Unit, nrm)
					local tilt = RAD(math.random(18,38)) * (math.random(2)==1 and 1 or -1)
					local final = base * ANGLES(tilt, 0, 0) * ANGLES(0, RAD(math.random(-35,35)), 0) * CF(0, size.Y*0.2, 0)
					local p = MakeDebris(cg.Material, cg.Color, size, final * CF(0, -size.Y*1.2, 0))
					Debris:AddItem(p, BROKEN_STAY + 4)
					TweenService:Create(p, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {CFrame = final}):Play()
					task.delay(BROKEN_STAY + math.random()*1.5, function()
						if p.Parent then
							TweenService:Create(p, TweenInfo.new(0.5), {CFrame = final * CF(0, -size.Y*1.2, 0)}):Play()
							Debris:AddItem(p, 0.6)
						end
					end)
				end
			end)
		end
	end
	for _ = 1, PEBBLES do
		local a = math.random() * math.pi * 2
		local rr = R * 0.8 * math.sqrt(math.random())
		local dir = VT(COS(a), 0, SIN(a))
		local pos = center + dir * rr
		task.delay(rr / WAVE_SPEED, function()
			local cg = GroundRay(pos + VT(0, 4, 0)) or g
			local s = 0.35 + math.random() * 0.5
			LaunchChunk(cg, VT(s,s,s), dir, 3 + math.random()*10, 55 + math.random()*40)
		end)
	end
end

local function ShockwaveEffect(origin)
	if not SHOCKWAVE then return end
	local g = GroundRay(origin + VT(0, 2, 0))
	if not g then return end
	local center = g.Position
	local col = GetModeColor()
	FlatRing(center, col, (HIT_RADIUS * CurrentMode.Radius) * 2.2, 0.5, 0)
	FlatRing(center, g.Color:Lerp(col, 0.5), (HIT_RADIUS * CurrentMode.Radius) * 1.6, 0.45, 0.08)
	DustPuff(center + VT(0, 0.5, 0), g.Color, 14)
	SpawnCracks(center, g)
	SpawnChunks(center, g)
end

local function Shake(intensity, duration)
	if not CAMERA_SHAKE then return end
	intensity = intensity * (CurrentMode.Shake or 1)
	task.spawn(function()
		local t0 = os.clock()
		while os.clock() - t0 < duration and Humanoid.Parent do
			local k = 1 - (os.clock() - t0) / duration
			Humanoid.CameraOffset = VT((math.random()-0.5)*intensity*k, (math.random()-0.5)*intensity*k, 0)
			Swait()
		end
		if Humanoid.Parent then Humanoid.CameraOffset = VT(0,0,0) end
	end)
end

----------------------------------------------------------------------
-- TARGET / VOID
----------------------------------------------------------------------
local Targeted = setmetatable({}, {__mode = "k"})

local function CenterOf(target)
	if target:IsA("Model") then
		local cf = target:GetBoundingBox()
		return cf.Position
	end
	return target.Position
end

local function CollectParts(target)
	local list, added = {}, {}
	local function add(p)
		if not added[p] then added[p] = true; list[#list+1] = p end
	end
	if target:IsA("BasePart") then
		add(target)
		local ok, connected = pcall(function() return target:GetConnectedParts(true) end)
		if ok then for _, p in ipairs(connected) do add(p) end end
	end
	for _, d in ipairs(target:GetDescendants()) do
		if d:IsA("BasePart") then add(d) end
	end
	return list
end

local function IsPinnedToWorld(part, ownerModel)
	local function outside(p)
		return p.Anchored and not (ownerModel and p:IsDescendantOf(ownerModel))
	end
	if outside(part) then return true end
	local ok, connected = pcall(function() return part:GetConnectedParts(true) end)
	if not ok then return false end
	for _, p in ipairs(connected) do if outside(p) then return true end end
	return false
end

local function FindTarget(part)
	local m = part:FindFirstAncestorOfClass("Model")
	while m do
		if m:FindFirstChildOfClass("Humanoid") then
			if Players:GetPlayerFromCharacter(m) then return nil end
			if IsPinnedToWorld(part, m) then return nil end
			return m
		end
		local par = m.Parent
		if par and par:IsA("Model") then m = par
		else m = par and par:FindFirstAncestorOfClass("Model") or nil end
	end
	if part.Anchored or IsPinnedToWorld(part, nil) then return nil end
	return part.AssemblyRootPart or part
end

local function SendToVoid(target, superFling)
	if Targeted[target] then return end
	Targeted[target] = true
	local parts = CollectParts(target)
	if #parts == 0 then return end

	local origPivot = target:GetPivot()
	local origProps = {}
	for _, p in ipairs(parts) do
		origProps[p] = {CanCollide = p.CanCollide, CanTouch = p.CanTouch}
	end

	local function Ghost()
		for _, p in ipairs(parts) do
			if p.Parent then
				pcall(function()
					if p:CanSetNetworkOwnership() then p:SetNetworkOwner(Player) end
				end)
				if not p.Anchored then
					p.AssemblyLinearVelocity = VT(0,0,0)
					p.AssemblyAngularVelocity = VT(0,0,0)
				end
				p.CanCollide = false
				p.CanTouch = false
			end
		end
	end
	Ghost()

	local hum = target:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = true
		hum:ChangeState(Enum.HumanoidStateType.Physics)
		local animator = hum:FindFirstChildOfClass("Animator")
		if animator then
			for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do tr:Stop(0) end
		end
	end

	local center = CenterOf(target)
	local rel = CF(center):Inverse() * target:GetPivot()
	local sx = math.random(2)==1 and 1 or -1
	local sy = math.random(2)==1 and 1 or -1
	local sz = math.random(2)==1 and 1 or -1
	local flingMul = (CurrentMode.Fling or 1) * (superFling and 4 or 1)

	local function KillAndFling()
		local hum2 = target:FindFirstChildOfClass("Humanoid")
		if hum2 then
			hum2.PlatformStand = false
			hum2.Health = 0
			pcall(function() hum2:ChangeState(Enum.HumanoidStateType.Dead) end)
		end
		local dir = (center - RootPart.Position) * VT(1,0,1)
		if dir.Magnitude < 0.1 then dir = RootPart.CFrame.LookVector end
		local vel = (dir.Unit + VT(0, FLING_UP + (superFling and 0.8 or 0), 0)).Unit * (FLING_SPEED * flingMul)
		local tumble = VT(math.random(-60,60), math.random(-60,60), math.random(-60,60))
		local started = os.clock()
		local hb
		hb = RunService.Heartbeat:Connect(function()
			if not target.Parent or os.clock() - started > FLING_TIME + (superFling and 3 or 0) then
				hb:Disconnect()
				return
			end
			for _, p in ipairs(parts) do
				if p.Parent and not p.Anchored then
					p.CanCollide = false
					p.AssemblyLinearVelocity = vel
					p.AssemblyAngularVelocity = tumble
				end
			end
		end)
	end

	local t0 = os.clock()
	local sentAt
	local conn
	conn = RunService.RenderStepped:Connect(function()
		if not target.Parent then conn:Disconnect() return end
		Ghost()
		local t = os.clock() - t0
		if t < SPIN_TIME then
			local full = 2 * math.pi * ((t / SPIN_TIME) ^ 1.5)
			local rot = ANGLES(full * SPIN_REVS.X * sx, full * SPIN_REVS.Y * sy, full * SPIN_REVS.Z * sz)
			target:PivotTo(CF(center) * rot * rel)
		else
			if not sentAt then
				sentAt = os.clock()
				PlaySoundAt(PLINK_ID, PointPart(center), 3, 0.95 + math.random()*0.15)
				PlinkEffect(center)
				if CurrentMode.MLG or CurrentMode.Hyper then
					PlaySoundAt(HITMARKER_ID, PointPart(center), 3, 1)
				end
				conn:Disconnect()
				target:PivotTo(CF(center) * rel)
				KillAndFling()
			end
		end
	end)
end

local function SlamImpact()
	local origin = (RootPart.CFrame * CF(0, 0, -HIT_FORWARD)).Position
	if CurrentMode.MLG or CurrentMode.Hyper then
		PlaySoundAt(HITMARKER_ID, PointPart(origin), 4, 1)
		if CurrentMode.MLG then PlaySoundAt(AIRHORN_ID, PointPart(origin), 2.2, 0.95 + math.random()*0.1) end
	else
		PlaySoundAt(PickHitSound(), PointPart(origin), 4, 1)
	end
	ShockwaveEffect(origin)

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Character, Effects}
	local found, seen = {}, {}
	local radius = HIT_RADIUS * (CurrentMode.Radius or 1)
	for _, part in ipairs(workspace:GetPartBoundsInRadius(origin, radius, params)) do
		local tgt = FindTarget(part)
		if tgt and not seen[tgt] and not Targeted[tgt] and #found < MAX_TARGETS then
			seen[tgt] = true
			found[#found + 1] = tgt
		end
	end
	Shake(#found > 0 and 1.6 or 1.1, 0.35)
	for _, tgt in ipairs(found) do
		local c = CenterOf(tgt)
		RingEffect(c, 9, 5)
		SparkBurst(c, 14, 1.5, 35)
		SendToVoid(tgt)
	end
end

----------------------------------------------------------------------
-- MODE ABILITIES (Z / X)
----------------------------------------------------------------------
local function AbilityZ()
	if AbilityCooldown or InCutscene or not EQUIPPED then return end
	AbilityCooldown = true
	task.delay(1.2, function() AbilityCooldown = false end)

	local col = GetModeColor()
	local origin = RootPart.Position

	-- Teleport dash / short burst toward mouse
	local goal = Mouse.Hit.Position
	local dir = (goal - origin)
	if dir.Magnitude > 80 then dir = dir.Unit * 80 end
	local dest = origin + dir

	-- Visual
	for i = 1, 6 do
		RingEffect(origin + VT(0, i * 0.4, 0), 4 + i, 3)
	end
	SparkBurst(origin, 20, 2, 40)
	PlaySoundAt(WHOOSH_ID, RootPart, 2.5, 1.4)

	-- Move
	local old = RootPart.CFrame
	RootPart.CFrame = CF(dest) * (old - old.Position)
	FlashBall(dest, 4, 18, 0.35)
	SparkBurst(dest, 18, 2.2, 45)
	Shake(1.2, 0.25)

	-- Light damage around landing
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Character, Effects}
	for _, part in ipairs(workspace:GetPartBoundsInRadius(dest, 10, params)) do
		local tgt = FindTarget(part)
		if tgt and not Targeted[tgt] then
			SendToVoid(tgt)
		end
	end
end

local function AbilityX()
	if AbilityCooldown or InCutscene or not EQUIPPED then return end
	AbilityCooldown = true
	task.delay(2.0, function() AbilityCooldown = false end)

	local col = GetModeColor()
	local origin = RootPart.Position + VT(0, 2, 0)

	-- Expanding shockwave / wave
	PlaySoundAt(PickHitSound(), PointPart(origin), 3.5, 0.8)
	for i = 1, 5 do
		task.delay(i * 0.08, function()
			RingEffect(origin, 8 + i * 6, 6)
			FlatRing(origin, col, 12 + i * 8, 0.4, 0)
		end)
	end
	Shake(1.8, 0.5)

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Character, Effects}
	for _, part in ipairs(workspace:GetPartBoundsInRadius(origin, 35, params)) do
		local tgt = FindTarget(part)
		if tgt and not Targeted[tgt] then
			local c = CenterOf(tgt)
			SparkBurst(c, 12, 2, 50)
			SendToVoid(tgt)
		end
	end
end

----------------------------------------------------------------------
-- THE HYPER OF DEATH CUTSCENE
----------------------------------------------------------------------
local function CreateUndertaleDialog(text, duration)
	local gui = IT("ScreenGui")
	gui.Name = "HyperDialog"
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 100
	gui.Parent = Player:WaitForChild("PlayerGui")

	local frame = IT("Frame")
	frame.Size = UDim2.new(0.7, 0, 0.18, 0)
	frame.Position = UDim2.new(0.15, 0, 0.72, 0)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BorderSizePixel = 4
	frame.BorderColor3 = Color3.new(1, 1, 1)
	frame.Parent = gui

	local label = IT("TextLabel")
	label.Size = UDim2.new(0.96, 0, 0.85, 0)
	label.Position = UDim2.new(0.02, 0, 0.08, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Font = Enum.Font.Code
	label.TextSize = 22
	label.TextWrapped = true
	label.Text = ""
	label.Parent = frame

	-- Typewriter
	task.spawn(function()
		for i = 1, #text do
			if not gui.Parent then break end
			label.Text = string.sub(text, 1, i)
			-- soft click sound
			if i % 2 == 0 then
				local s = IT("Sound")
				s.SoundId = "rbxassetid://541939763"
				s.Volume = 0.35
				s.PlaybackSpeed = 1.2 + math.random() * 0.2
				s.Parent = SoundService
				s:Play()
				Debris:AddItem(s, 1)
			end
			task.wait(0.028)
		end
	end)

	task.delay(duration or (#text * 0.03 + 1.5), function()
		if gui.Parent then gui:Destroy() end
	end)
	return gui
end

local function HyperOfDeathUltimate()
	if InCutscene or not EQUIPPED or not CurrentMode.Hyper then return end
	InCutscene = true
	ATTACK = true
	HOLD = false
	SlamToken = SlamToken + 1
	ClearAura()

	-- Freeze player movement
	local oldWalk = Humanoid.WalkSpeed
	local oldJump = Humanoid.JumpPower
	Humanoid.WalkSpeed = 0
	Humanoid.JumpPower = 0

	-- Music
	if music then music:Stop() end
	cutsceneMusic = IT("Sound")
	cutsceneMusic.SoundId = HYPER_MUSIC_URL
	cutsceneMusic.Volume = 3
	cutsceneMusic.Looped = false
	cutsceneMusic.Parent = SoundService
	cutsceneMusic:Play()
	-- fallback
	task.delay(2, function()
		if cutsceneMusic and cutsceneMusic.IsPlaying == false then
			cutsceneMusic.SoundId = HYPER_MUSIC_ALT
			cutsceneMusic:Play()
		end
	end)

	-- 1. Jump up
	local startCF = RootPart.CFrame
	local jumpTarget = startCF.Position + VT(0, 45, 0)
	local t0 = os.clock()
	local jumpConn
	jumpConn = RunService.RenderStepped:Connect(function()
		local a = math.clamp((os.clock() - t0) / 1.1, 0, 1)
		local ease = a * a * (3 - 2 * a)
		RootPart.CFrame = CF(startCF.Position:Lerp(jumpTarget, ease)) * (startCF - startCF.Position)
		if a >= 1 then jumpConn:Disconnect() end
	end)
	PlaySoundAt(WHOOSH_ID, RootPart, 3, 0.7)
	for i = 1, 8 do
		task.delay(i * 0.08, function()
			SparkBurst(RootPart.Position, 10, 3, 30)
			RingEffect(RootPart.Position, 6 + i, 4)
		end)
	end
	task.wait(1.2)

	-- 2. Undertale dialog
	local dialog = CreateUndertaleDialog("YOU WILL BE PUNISHED NUBS\nYOU WILL SEE WHAT MY TRUE COLORS\nRAAAAAAAA", 5.5)
	task.wait(5.2)
	if dialog and dialog.Parent then dialog:Destroy() end

	-- 3. Charge Spirit Bomb (big ball above)
	local bombPos = RootPart.Position + VT(0, 18, 0)
	local bomb = IT("Part")
	bomb.Shape = Enum.PartType.Ball
	bomb.Anchored = true
	bomb.CanCollide = false
	bomb.Material = Enum.Material.Neon
	bomb.Color = Color3.fromRGB(255, 40, 80)
	bomb.Size = VT(2, 2, 2)
	bomb.Transparency = 0.15
	bomb.Position = bombPos
	bomb.Parent = Effects

	local bombLight = IT("PointLight")
	bombLight.Color = Color3.fromRGB(255, 80, 120)
	bombLight.Brightness = 15
	bombLight.Range = 60
	bombLight.Parent = bomb

	-- Growing bomb + particles
	local chargeTime = 2.8
	TweenService:Create(bomb, TweenInfo.new(chargeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = VT(28, 28, 28)
	}):Play()

	local chargePe = IT("ParticleEmitter")
	chargePe.Texture = STAR_TEXTURE
	chargePe.Rate = 80
	chargePe.Lifetime = NumberRange.new(0.5, 1.2)
	chargePe.Speed = NumberRange.new(8, 25)
	chargePe.SpreadAngle = Vector2.new(180, 180)
	chargePe.LightEmission = 1
	chargePe.Color = ColorSequence.new(Color3.fromRGB(255, 0, 80), Color3.fromRGB(255, 200, 50))
	chargePe.Size = NumberSequence.new(3, 0)
	chargePe.Transparency = NumberSequence.new(0.1, 1)
	chargePe.Parent = bomb

	-- Rainbow rings during charge
	for i = 1, 12 do
		task.delay(i * 0.18, function()
			if bomb.Parent then
				RingEffect(bomb.Position, 10 + i * 3, 8)
				Shake(0.8 + i * 0.15, 0.2)
			end
		end)
	end
	task.wait(chargeTime + 0.15)

	-- 4. Blast – Super Hyper Sonic style + spirit bomb detonation
	PlaySoundAt(HITMARKER_ID, PointPart(bomb.Position), 5, 0.8)
	PlaySoundAt(AIRHORN_ID, PointPart(bomb.Position), 3, 0.9)

	-- Giant flash
	FlashBall(bomb.Position, 20, 120, 0.9)
	local whiteFlash = IT("Part")
	whiteFlash.Shape = Enum.PartType.Ball
	whiteFlash.Anchored = true
	whiteFlash.CanCollide = false
	whiteFlash.Material = Enum.Material.Neon
	whiteFlash.Color = Color3.new(1, 1, 1)
	whiteFlash.Size = VT(5, 5, 5)
	whiteFlash.Transparency = 0
	whiteFlash.Position = bomb.Position
	whiteFlash.Parent = Effects
	TweenService:Create(whiteFlash, TweenInfo.new(0.6), {Size = VT(200, 200, 200), Transparency = 0.3}):Play()

	-- Collect ALL nearby NPCs and super-fling them
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Character, Effects}
	local blasted = {}
	for _, part in ipairs(workspace:GetPartBoundsInRadius(bomb.Position, 200, params)) do
		local tgt = FindTarget(part)
		if tgt and not blasted[tgt] then
			blasted[tgt] = true
			-- Hyper trails on them
			local c = CenterOf(tgt)
			for i = 1, 4 do
				SparkBurst(c + VT(math.random(-5,5), math.random(0,8), math.random(-5,5)), 15, 3, 80)
			end
			SendToVoid(tgt, true) -- superFling
		end
	end

	bomb:Destroy()
	Shake(4, 1.2)
	task.wait(0.7)

	-- 5. Fade to white
	local fadeGui = IT("ScreenGui")
	fadeGui.IgnoreGuiInset = true
	fadeGui.DisplayOrder = 200
	fadeGui.Parent = Player.PlayerGui
	local fade = IT("Frame")
	fade.Size = UDim2.fromScale(1, 1)
	fade.BackgroundColor3 = Color3.new(1, 1, 1)
	fade.BackgroundTransparency = 1
	fade.BorderSizePixel = 0
	fade.Parent = fadeGui
	TweenService:Create(fade, TweenInfo.new(1.2), {BackgroundTransparency = 0}):Play()
	task.wait(1.4)

	-- 6. White void – player alone
	-- Hide everything else visually by keeping full white + place player
	RootPart.CFrame = CF(0, 10, 0)
	Humanoid.WalkSpeed = 0
	Humanoid.JumpPower = 0

	-- Clear residual effects
	for _, c in ipairs(Effects:GetChildren()) do
		if c ~= whiteFlash then c:Destroy() end
	end

	-- Soft floating particles in the void
	local voidPe = IT("ParticleEmitter")
	voidPe.Texture = STAR_TEXTURE
	voidPe.Rate = 15
	voidPe.Lifetime = NumberRange.new(2, 4)
	voidPe.Speed = NumberRange.new(1, 4)
	voidPe.SpreadAngle = Vector2.new(180, 180)
	voidPe.LightEmission = 1
	voidPe.Color = ColorSequence.new(Color3.fromRGB(255, 100, 150), Color3.fromRGB(255, 255, 255))
	voidPe.Size = NumberSequence.new(1.5, 0)
	voidPe.Transparency = NumberSequence.new(0.3, 1)
	voidPe.Parent = RootPart

	-- Keep white for a few seconds while music plays
	task.wait(6)

	-- Fade back
	TweenService:Create(fade, TweenInfo.new(1.5), {BackgroundTransparency = 1}):Play()
	task.wait(1.6)
	fadeGui:Destroy()
	voidPe:Destroy()
	if whiteFlash and whiteFlash.Parent then whiteFlash:Destroy() end

	-- Restore
	if cutsceneMusic then
		TweenService:Create(cutsceneMusic, TweenInfo.new(1.5), {Volume = 0}):Play()
		Debris:AddItem(cutsceneMusic, 2)
		cutsceneMusic = nil
	end
	Humanoid.WalkSpeed = oldWalk
	Humanoid.JumpPower = oldJump
	InCutscene = false
	ATTACK = false
	if EQUIPPED then
		BuildAura()
		if PLAY_MUSIC then
			-- restart normal mode music if desired
		end
	end
end

----------------------------------------------------------------------
-- SLAM ANIMATION (R6)
----------------------------------------------------------------------
local function SlamPose(hwY, hwRx, rootZ, rootRx, neckRx, shZ, shRx, hipSpd)
	local spd = 2 / SlamAS
	HW = Clerp(HW, CF(0, hwY, 0) * ANGLES(RAD(hwRx), RAD(-45), 0), spd)
	J.Root.C0 = Clerp(J.Root.C0, ROOTC0 * CF(0, 0, rootZ) * ANGLES(RAD(rootRx), 0, 0), spd)
	J.Neck.C0 = Clerp(J.Neck.C0, NECKC0 * ANGLES(RAD(neckRx), 0, 0), spd)
	J.RS.C0 = Clerp(J.RS.C0, CF(1, 0.5, shZ) * ANGLES(RAD(shRx), 0, RAD(-45)) * RIGHTSHOULDERC0, spd)
	J.LS.C0 = Clerp(J.LS.C0, CF(-1, 0.5, shZ) * ANGLES(RAD(shRx), 0, RAD(45)) * LEFTSHOULDERC0, spd)
	local h = hipSpd / SlamAS
	J.RH.C0 = Clerp(J.RH.C0, CF(1, -1 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(0, RAD(90), 0) * ANGLES(RAD(-8), 0, RAD(25)), h)
	J.LH.C0 = Clerp(J.LH.C0, CF(-1, -1 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(0, RAD(-90), 0) * ANGLES(RAD(-8), 0, RAD(25)), h)
end

local function Phase(dur, fn, cancelled)
	for i = 0, dur, 0.1 / SlamAS do
		Swait()
		if cancelled() then return false end
		fn()
	end
	return true
end

local function WaitSec(sec, cancelled)
	local t0 = os.clock()
	while os.clock() - t0 < sec do
		Swait()
		if cancelled() then return false end
	end
	return true
end

local function BANSLAM()
	if ATTACK or not EQUIPPED or InCutscene then return end
	ATTACK = true
	local token = SlamToken
	local whoosh
	local function cancelled()
		local c = token ~= SlamToken or not EQUIPPED or InCutscene
		if c and whoosh then StopWhoosh(whoosh) whoosh = nil end
		return c
	end

	if IS_R15 then
		repeat
			whoosh = PlaySoundAt(WHOOSH_ID, RootPart, 2, 1)
			local swing = IT("StringValue")
			swing.Name = "toolanim"
			swing.Value = "Slash"
			swing.Parent = Tool
			if not WaitSec(R15_SWING_DELAY, cancelled) then return end
			StopWhoosh(whoosh) whoosh = nil
			SlamImpact()
			if not WaitSec(R15_RECOVER_TIME, cancelled) then return end
		until HOLD == false or cancelled()
		if token == SlamToken then ATTACK = false end
		return
	end
	repeat
		whoosh = PlaySoundAt(WHOOSH_ID, RootPart, 2, 1)
		if not Phase(CHARGE_TIME, function() SlamPose(-0.8, -90, 7, 0, 25, 0.5, 250, 2) end, cancelled) then return end
		if not Phase(0.08, function() SlamPose(-1, -90, 2, 75, -25, -1, 120, 0.5) end, cancelled) then return end
		if not Phase(0.08, function() SlamPose(-1, -70, 2, 75, -25, -1, 60, 0.5) end, cancelled) then return end
		StopWhoosh(whoosh) whoosh = nil
		SlamImpact()
		if not Phase(0.1, function() SlamPose(-1, -70, 1.8, 75, -25, -1, 60, 0.5) end, cancelled) then return end
		if HOLD then
			for i = 0, 0.08, 0.1 / SlamAS do
				Swait()
				if cancelled() then return end
				if not HOLD then break end
				SlamPose(-1, -90, 2, 75, -25, -1, 120, 0.5)
			end
		end
	until HOLD == false or cancelled()
	if token == SlamToken then
		ATTACK = false
		BoostFrames = 25
	end
end

local function OnSlamAction(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		HOLD = true
		if EQUIPPED and not ATTACK and not InCutscene then
			task.spawn(BANSLAM)
		end
	elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
		HOLD = false
	end
	return Enum.ContextActionResult.Sink
end

----------------------------------------------------------------------
-- MODE SWITCH + MUSIC
----------------------------------------------------------------------
local function ApplyModeMusic()
	if not PLAY_MUSIC then return end
	if music and music.Parent then music:Stop() music:Destroy() music = nil end
	if CurrentMode.Hyper then return end -- handled by cutscene
	music = IT("Sound")
	music.SoundId = "rbxassetid://462506896"
	music.Looped = true
	music.Volume = 4
	music.Parent = Character
	music:Play()
end

local function SwitchMode(delta)
	if InCutscene then return end
	CurrentModeIndex = ((CurrentModeIndex - 1 + delta) % #Modes) + 1
	CurrentMode = Modes[CurrentModeIndex]
	if EQUIPPED then
		ApplyModeMusic()
		BuildAura()
	end
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = CurrentMode.Name,
			Text = string.format("R x%.2f | F x%.2f  [%d/%d]%s",
				CurrentMode.Radius, CurrentMode.Fling, CurrentModeIndex, #Modes,
				CurrentMode.Hyper and "  |  V = ULTIMATE" or ""),
			Duration = 2.8,
		})
	end)
end

----------------------------------------------------------------------
-- EQUIP / CLEANUP
----------------------------------------------------------------------
local originalSpeed = Humanoid.WalkSpeed
local simConn

local function ApplySimRadius()
	local setHidden = sethiddenproperty or set_hidden_property or set_hidden_prop
	if setHidden then
		pcall(setHidden, Player, "SimulationRadius", SIM_RADIUS)
		pcall(setHidden, Player, "MaximumSimulationRadius", SIM_RADIUS)
	else
		pcall(function() Player.SimulationRadius = SIM_RADIUS end)
		pcall(function() Player.MaximumSimulationRadius = SIM_RADIUS end)
	end
end

local function Cleanup()
	EQUIPPED = false
	HOLD = false
	ATTACK = false
	InCutscene = false
	SlamToken = SlamToken + 1
	BoostFrames = 0
	Bst = 1
	Weapon.Parent = nil
	ContextActionService:UnbindAction(ACTION_NAME)
	for name, j in pairs(Real) do
		j.C0, j.C1 = RestReal[name].C0, RestReal[name].C1
	end
	ResetVirtual()
	if ANIMATE then ANIMATE.Disabled = false end
	if music then music:Destroy() music = nil end
	if cutsceneMusic then cutsceneMusic:Destroy() cutsceneMusic = nil end
	if simConn then simConn:Disconnect() simConn = nil end
	ClearAura()
	if Humanoid.Parent then Humanoid.WalkSpeed = originalSpeed end
end

Tool.Equipped:Connect(function()
	if EQUIPPED or Humanoid.Health <= 0 then return end
	originalSpeed = Humanoid.WalkSpeed
	ResetVirtual()
	EQUIPPED = true
	if not IS_R15 then
		Weapon.Parent = Character
		if ANIMATE then ANIMATE.Disabled = true end
		for _, t in ipairs(Humanoid:GetPlayingAnimationTracks()) do t:Stop(0) end
	end
	Humanoid.WalkSpeed = EquippedSpeed
	if simConn then simConn:Disconnect() end
	simConn = RunService.Heartbeat:Connect(ApplySimRadius)
	ApplySimRadius()
	ApplyModeMusic()
	BuildAura()

	ContextActionService:BindAction(ACTION_NAME, OnSlamAction, true, Enum.KeyCode.E, Enum.KeyCode.ButtonR2)
	ContextActionService:SetTitle(ACTION_NAME, "Slam")
	ContextActionService:SetPosition(ACTION_NAME, BUTTON_POSITION)
end)

Tool.Unequipped:Connect(Cleanup)
Humanoid.Died:Connect(function()
	Cleanup()
	Weapon:Destroy()
end)

-- Input
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe or not EQUIPPED then return end
	if InCutscene then return end
	if input.KeyCode == Enum.KeyCode.LeftBracket or input.KeyCode == Enum.KeyCode.Comma then
		SwitchMode(-1)
	elseif input.KeyCode == Enum.KeyCode.RightBracket or input.KeyCode == Enum.KeyCode.Period then
		SwitchMode(1)
	elseif input.KeyCode == Enum.KeyCode.Z then
		AbilityZ()
	elseif input.KeyCode == Enum.KeyCode.X then
		AbilityX()
	elseif input.KeyCode == Enum.KeyCode.V then
		if CurrentMode.Hyper then
			task.spawn(HyperOfDeathUltimate)
		end
	end
end)

-- Startup notifies
task.spawn(function()
	local function Notify(title, text)
		for _ = 1, 15 do
			local ok = pcall(function()
				StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 3.2})
			end)
			if ok then return end
			task.wait(0.4)
		end
	end
	Notify("Ban Hammer 51 Modes", "Star Glitcher + MLG + THE HYPER OF DEATH")
	task.wait(0.5)
	Notify("Controls", "E=Slam  [ ]=Modes  Z/X=Abilities  V=Hyper Ult")
	task.wait(0.5)
	Notify("Hyper Mode", "Switch to last mode then press V for the cutscene")
end)

-- Idle / walk animation loop
while Humanoid.Parent do
	Swait()
	if EQUIPPED and not IS_R15 and not InCutscene then
		Bst = (BoostFrames > 0) and 4 or 1
		if BoostFrames > 0 then BoostFrames = BoostFrames - 1 end
		SINE = SINE + CHANGE
		local vel = RootPart.AssemblyLinearVelocity
		local TORSOVELOCITY = (vel * VT(1, 0, 1)).Magnitude
		local TORSOVERTICALVELOCITY = vel.Y
		local grounded = Humanoid.FloorMaterial ~= Enum.Material.Air
		local spd16 = Humanoid.WalkSpeed / 16
		local W = 6 / spd16
		local rootAngY = RootPart.AssemblyAngularVelocity.Y
		local headAngY = Head.AssemblyAngularVelocity.Y

		if not ATTACK then
			SetC0("RS", CF(1.5, 0, 0) * ANGLES(RAD(200), RAD(90), 0) * RIGHTSHOULDERC0, 0.2)
			SetHW(CF(0, -0.8, 0) * ANGLES(RAD(-90), 0, 0), 0.2)
		end

		if ANIM == "Walk" and TORSOVELOCITY > 1 and not ATTACK then
			SetC1("Root", ROOTC0 * CF(0, 0, -0.15 * COS(SINE / (W / 2))) * ANGLES(0, -rootAngY / 75, 0), 2 * spd16)
			SetC1("Neck", NECKC1 * ANGLES(RAD(2.5 * SIN(SINE / (W / 2))), 0, -headAngY / 30), 0.2 * spd16)
			SetC1("RH", CF(0.5, 0.875 - 0.125 * SIN(SINE / W), -0.125 * COS(SINE / W)) * ANGLES(0, RAD(90), 0) * ANGLES(0, 0, RAD(76 * COS(SINE / W))), 0.2 * spd16)
			SetC1("LH", CF(-0.5, 0.875 + 0.125 * SIN(SINE / W), 0.125 * COS(SINE / W)) * ANGLES(0, RAD(-90), 0) * ANGLES(0, 0, RAD(76 * COS(SINE / W))), 0.2 * spd16)
		else
			SetC1("Root", ROOTC0, 0.2)
			SetC1("Neck", NECKC1, 0.2)
			SetC1("RH", CF(0.5, 1, 0) * ANGLES(0, RAD(90), 0), 0.2)
			SetC1("LH", CF(-0.5, 1, 0) * ANGLES(0, RAD(-90), 0), 0.2)
		end

		if TORSOVERTICALVELOCITY > 1 and not grounded then
			ANIM = "Jump"
			if not ATTACK then
				SetC0("Root", ROOTC0, 0.2)
				SetC0("Neck", NECKC0 * ANGLES(RAD(-20), 0, 0), 0.2)
				SetC0("LS", CF(-1.5, 0.5, 0) * ANGLES(RAD(-40), 0, RAD(-20)) * LEFTSHOULDERC0, 0.2)
				SetC0("RH", CF(1, -1, -0.3) * ANGLES(0, RAD(90), 0) * ANGLES(RAD(-5), 0, RAD(-20)), 0.2)
				SetC0("LH", CF(-1, -1, -0.3) * ANGLES(0, RAD(-90), 0) * ANGLES(RAD(-5), 0, RAD(20)), 0.2)
			end
		elseif TORSOVERTICALVELOCITY < -1 and not grounded then
			ANIM = "Fall"
			if not ATTACK then
				SetC0("Root", ROOTC0, 0.2)
				SetC0("Neck", NECKC0 * ANGLES(RAD(20), 0, 0), 0.2)
				SetC0("LS", CF(-1.5, 0.5, 0) * ANGLES(0, 0, RAD(-60)) * LEFTSHOULDERC0, 0.2)
				SetC0("RH", CF(1, -1, 0) * ANGLES(0, RAD(90), 0) * ANGLES(0, 0, RAD(20)), 0.2)
				SetC0("LH", CF(-1, -1, 0) * ANGLES(0, RAD(-90), 0) * ANGLES(0, 0, RAD(10)), 0.2)
			end
		elseif TORSOVELOCITY < 1 and grounded then
			ANIM = "Idle"
			if not ATTACK then
				SetC0("Root", ROOTC0 * CF(0, 0, 0.05 * COS(SINE / 12)), 0.15)
				SetC0("Neck", NECKC0 * ANGLES(RAD(-2.5 * SIN(SINE / 12)), 0, 0), 0.15)
				SetC0("LS", CF(-1.5, 0.5, 0) * ANGLES(0, 0, RAD(-12)) * LEFTSHOULDERC0, 0.15)
				SetC0("RH", CF(1, -1 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(0, RAD(90), 0) * ANGLES(RAD(-8), 0, 0), 0.15)
				SetC0("LH", CF(-1, -1 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(0, RAD(-90), 0) * ANGLES(RAD(-8), 0, 0), 0.15)
			end
		elseif TORSOVELOCITY > 1 and grounded then
			ANIM = "Walk"
			if not ATTACK then
				SetC0("Root", ROOTC0 * CF(0, 0, -0.1) * ANGLES(RAD(5), 0, 0), 0.15)
				SetC0("Neck", NECKC0 * ANGLES(RAD(5 - 8 * SIN(SINE / (W / 2))), 0, 0), 0.15)
				SetC0("LS", CF(-1.5, 0.5, 0) * ANGLES(RAD(-60 * COS(SINE / W)), 0, RAD(-5)) * LEFTSHOULDERC0, 0.35)
				SetC0("RH", CF(1, -1 - 0.15 * COS(SINE / W * 2), -0.2 + 0.2 * COS(SINE / W)) * ANGLES(0, RAD(90), 0) * ANGLES(0, 0, RAD(-15)), 2)
				SetC0("LH", CF(-1, -1 - 0.15 * COS(SINE / W * 2), -0.2 - 0.2 * COS(SINE / W)) * ANGLES(0, RAD(-90), 0) * ANGLES(0, 0, RAD(15)), 2)
			end
		end
	end
end
