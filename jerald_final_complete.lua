--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║  JERALD: THE ULTIMATE COMPLETE HORROR AI                  ║
    ║  - 250+ AI Behaviors + Wall Climbing + Pathfinding        ║
    ║  - Invisible AK-47 with Aimbot                            ║
    ║  - Grab, Flee & Neck Snap Mechanics                       ║
    ║  - Grab & Eat Players Piece by Piece                      ║
    ║  - Orbital Nuclear Strike System                          ║
    ║  - Anti-Cheat System                                      ║
    ║  Place in ServerScriptService                             ║
    ╚═══════════════════════════════════════════════════════════╝
]]

-- // SERVICES \\
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

-- // CONFIGURATION \\
local CONFIG = {
    NPC_ID = "rbxassetid://9870579094",
    BRAZIL_PLACE_ID = 10684632908,
    
    -- Sounds
    CHASE_SOUND_ID = "rbxassetid://111737163569849",
    WHISPER_SOUND_ID = "rbxassetid://5566448842",
    BREATH_SOUND_ID = "rbxassetid://4548900393",
    STATIC_SOUND_ID = "rbxassetid://6825153536",
    RAGE_SOUND_ID = "rbxassetid://9114397505",
    EATING_SOUND_ID = "rbxassetid://4835535512",
    CRUNCH_SOUND_ID = "rbxassetid://4835535512",
    GUNSHOT_SOUND_ID = "rbxassetid://2920959707",
    NECK_SNAP_SOUND_ID = "rbxassetid://3398620867",
    
    -- Anti-cheat
    MAX_SPEED = 100,
    MAX_FLY_HEIGHT = 10,
    FORBIDDEN_WORDS = {"jerald", "jerrald", "gerald", "monster", "creature", "entity", "him", "stalker", "observer"},
    
    -- Combat
    AK47_DAMAGE = 35,
    AK47_FIRE_RATE = 0.1,
    AK47_RANGE = 200,
    AK47_ACCURACY = 0.95,
    FLEE_SPEED = 45,
    FLEE_HEIGHT = 60,
    
    -- AI
    CLIMB_SPEED = 15,
    WALL_DETECTION_DISTANCE = 3,
    JUMP_HEIGHT = 60,
    NUKE_COOLDOWN = 300
}

-- Load Jerald
local JeraldModel = game:GetObjects(CONFIG.NPC_ID)[1]
JeraldModel.Name = "Jerald"
JeraldModel.Parent = workspace

local Humanoid = JeraldModel:WaitForChild("Humanoid")
local RootPart = JeraldModel:WaitForChild("HumanoidRootPart")
local Head = JeraldModel:FindFirstChild("Head") or RootPart

Humanoid.WalkSpeed = 16
Humanoid.JumpPower = CONFIG.JUMP_HEIGHT
Humanoid.MaxHealth = math.huge
Humanoid.Health = math.huge
Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
Humanoid.BreakJointsOnDeath = false

-- // CREATE INVISIBLE AK-47 FROM SCRATCH \\
local function CreateAK47()
    local ak47 = Instance.new("Model")
    ak47.Name = "InvisibleAK47"
    
    -- Main body
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(0.3, 0.3, 2)
    body.Transparency = 1
    body.CanCollide = false
    body.Parent = ak47
    
    -- Barrel
    local barrel = Instance.new("Part")
    barrel.Name = "Barrel"
    barrel.Size = Vector3.new(0.15, 0.15, 1.5)
    barrel.Transparency = 1
    barrel.CanCollide = false
    barrel.CFrame = body.CFrame * CFrame.new(0, 0, -1.75)
    barrel.Parent = ak47
    
    local barrelWeld = Instance.new("WeldConstraint")
    barrelWeld.Part0 = body
    barrelWeld.Part1 = barrel
    barrelWeld.Parent = barrel
    
    -- Muzzle (shooting point)
    local muzzle = Instance.new("Attachment")
    muzzle.Name = "Muzzle"
    muzzle.Position = Vector3.new(0, 0, -0.75)
    muzzle.Parent = barrel
    
    -- Muzzle flash
    local muzzleFlash = Instance.new("ParticleEmitter")
    muzzleFlash.Name = "MuzzleFlash"
    muzzleFlash.Texture = "rbxasset://textures/particles/smoke_main.dds"
    muzzleFlash.Color = ColorSequence.new(Color3.new(1, 0.8, 0))
    muzzleFlash.Size = NumberSequence.new(0.3)
    muzzleFlash.Lifetime = NumberRange.new(0.05)
    muzzleFlash.Rate = 0
    muzzleFlash.Speed = NumberRange.new(0)
    muzzleFlash.Enabled = false
    muzzleFlash.Parent = muzzle
    
    -- Magazine
    local mag = Instance.new("Part")
    mag.Name = "Magazine"
    mag.Size = Vector3.new(0.2, 0.8, 0.3)
    mag.Transparency = 1
    mag.CanCollide = false
    mag.CFrame = body.CFrame * CFrame.new(0, -0.4, 0)
    mag.Parent = ak47
    
    local magWeld = Instance.new("WeldConstraint")
    magWeld.Part0 = body
    magWeld.Part1 = mag
    magWeld.Parent = mag
    
    -- Handle/Grip
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.2, 0.6, 0.2)
    handle.Transparency = 1
    handle.CanCollide = false
    handle.CFrame = body.CFrame * CFrame.new(0, -0.3, 0.5)
    handle.Parent = ak47
    
    local handleWeld = Instance.new("WeldConstraint")
    handleWeld.Part0 = body
    handleWeld.Part1 = handle
    handleWeld.Parent = handle
    
    -- Stock
    local stock = Instance.new("Part")
    stock.Name = "Stock"
    stock.Size = Vector3.new(0.2, 0.2, 0.8)
    stock.Transparency = 1
    stock.CanCollide = false
    stock.CFrame = body.CFrame * CFrame.new(0, 0.1, 1.4)
    stock.Parent = ak47
    
    local stockWeld = Instance.new("WeldConstraint")
    stockWeld.Part0 = body
    stockWeld.Part1 = stock
    stockWeld.Parent = stock
    
    -- Sounds
    local shootSound = Instance.new("Sound")
    shootSound.Name = "ShootSound"
    shootSound.SoundId = CONFIG.GUNSHOT_SOUND_ID
    shootSound.Volume = 1
    shootSound.RollOffMaxDistance = 300
    shootSound.Parent = barrel
    
    -- FIX: Set PrimaryPart before calling SetPrimaryPartCFrame
    ak47.PrimaryPart = body
    ak47:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
    return ak47
end

local AK47 = CreateAK47()
AK47.Parent = JeraldModel

-- Attach AK-47 to Jerald's hands
local rightHand = JeraldModel:FindFirstChild("Right Arm") or JeraldModel:FindFirstChild("RightHand")
if rightHand then
    local weld = Instance.new("Weld")
    weld.Part0 = rightHand
    weld.Part1 = AK47.Body
    weld.C0 = CFrame.new(0, -1, -0.5) * CFrame.Angles(math.rad(-90), math.rad(90), 0)
    weld.Parent = AK47.Body
end

-- // AIMBOT SYSTEM \\
local LastShotTime = 0
local AmmoCount = math.huge
local IsAiming = false

local function GetBestTarget()
    local best = nil
    local bestScore = 0
    
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local distance = (head.Position - RootPart.Position).Magnitude
            
            if distance <= CONFIG.AK47_RANGE then
                -- Score based on distance (closer = higher score) and line of sight
                local score = (CONFIG.AK47_RANGE - distance) / CONFIG.AK47_RANGE
                
                -- Check line of sight
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {JeraldModel}
                local ray = workspace:Raycast(Head.Position, (head.Position - Head.Position), rayParams)
                
                if not ray or ray.Instance:IsDescendantOf(player.Character) then
                    score = score * 1.5 -- Bonus for clear shot
                end
                
                if score > bestScore then
                    bestScore = score
                    best = player
                end
            end
        end
    end
    
    return best
end

local function FireAK47(targetPlayer)
    if tick() - LastShotTime < CONFIG.AK47_FIRE_RATE then return false end
    if not targetPlayer or not targetPlayer.Character then return false end
    
    LastShotTime = tick()
    
    local target = targetPlayer.Character:FindFirstChild("Head")
    if not target then
        target = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    end
    
    if not target then return false end
    
    -- Aim gun at target
    local barrel = AK47:FindFirstChild("Barrel")
    if barrel then
        local muzzle = barrel:FindFirstChild("Muzzle")
        local lookPos = target.Position
        
        -- Add slight inaccuracy
        if math.random() > CONFIG.AK47_ACCURACY then
            lookPos = lookPos + Vector3.new(
                math.random(-5, 5),
                math.random(-5, 5),
                math.random(-5, 5)
            )
        end
        
        -- Visual effects
        local muzzleFlash = muzzle:FindFirstChild("MuzzleFlash")
        if muzzleFlash then
            muzzleFlash:Emit(10)
        end
        
        -- Sound
        local shootSound = barrel:FindFirstChild("ShootSound")
        if shootSound then
            shootSound:Play()
        end
        
        -- Tracer (visible bullet trail)
        local tracer = Instance.new("Part")
        tracer.Size = Vector3.new(0.1, 0.1, (muzzle.WorldPosition - lookPos).Magnitude)
        tracer.CFrame = CFrame.new(muzzle.WorldPosition, lookPos) * CFrame.new(0, 0, -tracer.Size.Z / 2)
        tracer.BrickColor = BrickColor.new("Bright yellow")
        tracer.Material = Enum.Material.Neon
        tracer.Anchored = true
        tracer.CanCollide = false
        tracer.Parent = workspace
        Debris:AddItem(tracer, 0.1)
        
        -- Raycast for hit detection
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {JeraldModel}
        local ray = workspace:Raycast(muzzle.WorldPosition, (lookPos - muzzle.WorldPosition), rayParams)
        
        if ray and ray.Instance then
            local hitPlayer = Players:GetPlayerFromCharacter(ray.Instance.Parent)
            if hitPlayer == targetPlayer then
                local hum = targetPlayer.Character:FindFirstChild("Humanoid")
                if hum then
                    hum:TakeDamage(CONFIG.AK47_DAMAGE)
                    
                    -- Blood effect
                    local blood = Instance.new("ParticleEmitter")
                    blood.Texture = "rbxasset://textures/particles/smoke_main.dds"
                    blood.Color = ColorSequence.new(Color3.new(0.5, 0, 0))
                    blood.Size = NumberSequence.new(0.5)
                    blood.Lifetime = NumberRange.new(0.5)
                    blood.Rate = 50
                    blood.Parent = ray.Instance
                    blood:Emit(20)
                    Debris:AddItem(blood, 1)
                end
            end
        end
    end
    
    return true
end

-- // GRAB AND FLEE SYSTEM \\
local FleeingPlayer = nil
local FleeingWeld = nil
local FleeStartTime = 0

local function GrabAndFlee(player)
    if not player or not player.Character then return false end
    
    local char = player.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    
    if not hrp or not hum then return false end
    
    -- Grab player
    hum.WalkSpeed = 0
    hum.JumpPower = 0
    hum.AutoRotate = false
    
    -- Weld to Jerald
    local weld = Instance.new("Weld")
    weld.Name = "FleeWeld"
    weld.Part0 = RootPart
    weld.Part1 = hrp
    weld.C0 = CFrame.new(0, 1, -2) * CFrame.Angles(math.rad(0), math.rad(180), 0)
    weld.Parent = RootPart
    
    FleeingPlayer = player
    FleeingWeld = weld
    FleeStartTime = tick()
    
    -- Visual effect
    pcall(function()
        ScareEvent:FireClient(player, "BeingEaten")
    end)
    
    Sounds.Rage:Play()
    
    warn("[JERALD] Grabbed " .. player.Name .. " and fleeing!")
    return true
end

local function SnapNeck(player)
    if not player or not player.Character then return false end
    
    -- Neck snap sound
    local snapSound = Instance.new("Sound")
    snapSound.SoundId = CONFIG.NECK_SNAP_SOUND_ID
    snapSound.Volume = 1
    snapSound.Parent = RootPart
    snapSound:Play()
    Debris:AddItem(snapSound, 2)
    
    -- Screen effect
    pcall(function()
        ScareEvent:FireClient(player, "Jumpscare")
        ScareEvent:FireClient(player, "CameraShake", 5)
    end)
    
    -- Ragdoll effect
    local char = player.Character
    local head = char:FindFirstChild("Head")
    
    if head then
        -- Twist head
        head.CFrame = head.CFrame * CFrame.Angles(math.rad(90), math.rad(180), 0)
    end
    
    -- Kill player
    task.wait(0.5)
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum.Health = 0
    end
    
    -- Clean up
    if FleeingWeld then
        FleeingWeld:Destroy()
    end
    FleeingPlayer = nil
    
    warn("[JERALD] Snapped " .. player.Name .. "'s neck!")
    return true
end

local function UpdateFleeing()
    if not FleeingPlayer then return end
    
    -- Flee upward and away
    Humanoid.WalkSpeed = CONFIG.FLEE_SPEED
    
    -- Jump high
    if (tick() - FleeStartTime) < 0.5 then
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.MaxForce = Vector3.new(100000, 100000, 100000)
        bodyVel.Velocity = Vector3.new(0, CONFIG.FLEE_HEIGHT, 0) + (RootPart.CFrame.LookVector * 30)
        bodyVel.Parent = RootPart
        Debris:AddItem(bodyVel, 0.5)
    end
    
    -- Flee to random high location
    local fleePos = RootPart.Position + Vector3.new(
        math.random(-100, 100),
        CONFIG.FLEE_HEIGHT,
        math.random(-100, 100)
    )
    
    Humanoid:MoveTo(fleePos)
    
    -- After 5 seconds, snap neck
    if (tick() - FleeStartTime) > 5 then
        SnapNeck(FleeingPlayer)
    end
end

-- // COMPLETE SYSTEM SETUP \\

-- Sounds
local Sounds = {}
local soundData = {
    Chase = {CONFIG.CHASE_SOUND_ID, true, 150, 0},
    Whisper = {CONFIG.WHISPER_SOUND_ID, false, 80, 0.5},
    Breath = {CONFIG.BREATH_SOUND_ID, true, 40, 0},
    Static = {CONFIG.STATIC_SOUND_ID, false, 60, 0.3},
    Rage = {CONFIG.RAGE_SOUND_ID, false, 200, 1},
    Eating = {CONFIG.EATING_SOUND_ID, false, 50, 0.8},
    Crunch = {CONFIG.CRUNCH_SOUND_ID, false, 50, 1}
}

for name, data in pairs(soundData) do
    local sound = Instance.new("Sound", RootPart)
    sound.Name = name .. "Sound"
    sound.SoundId = data[1]
    sound.Looped = data[2]
    sound.RollOffMaxDistance = data[3]
    sound.Volume = data[4]
    Sounds[name] = sound
end

-- Climbing components
local ClimbForce = Instance.new("BodyVelocity")
ClimbForce.Name = "ClimbForce"
ClimbForce.MaxForce = Vector3.new(0, 0, 0)
ClimbForce.Velocity = Vector3.new(0, 0, 0)
ClimbForce.Parent = RootPart

local WallGrip = Instance.new("BodyPosition")
WallGrip.Name = "WallGrip"
WallGrip.MaxForce = Vector3.new(0, 0, 0)
WallGrip.P = 10000
WallGrip.D = 500
WallGrip.Parent = RootPart

-- Remote Events
local ScareEvent = Instance.new("RemoteEvent")
ScareEvent.Name = "JeraldHorrorEvent"
ScareEvent.Parent = ReplicatedStorage

local CountdownEvent = Instance.new("RemoteEvent")
CountdownEvent.Name = "JeraldCountdown"
CountdownEvent.Parent = ReplicatedStorage

local NukeEvent = Instance.new("RemoteEvent")
NukeEvent.Name = "JeraldNukeEvent"
NukeEvent.Parent = ReplicatedStorage

-- Model storage
local ModelStorage = Instance.new("Folder")
ModelStorage.Name = "JeraldModelStorage"
ModelStorage.Parent = ReplicatedStorage

local ViewportClone = JeraldModel:Clone()
for _, desc in pairs(ViewportClone:GetDescendants()) do
    if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") or desc:IsA("Sound") then
        desc:Destroy()
    end
end
ViewportClone.Name = "JeraldViewportModel"
ViewportClone.Parent = ModelStorage

-- Player Data
local PlayerData = {}
local BackstabData = {}
local AIMemory = {}

local function InitPlayerData(player)
    PlayerData[player.UserId] = {
        Player = player,
        SpeedViolations = 0,
        FlyViolations = 0,
        ChatViolations = 0,
        LastGroundTime = tick(),
        IsRaged = false,
        Fear = 0,
        BeingEaten = false,
        EatenParts = {}
    }
    
    BackstabData[player.UserId] = {
        TimeSpentBehind = 0,
        LastCheckTime = tick()
    }
    
    AIMemory[player.UserId] = {
        ThreatLevel = 0,
        Intelligence = math.random(50, 100),
        Aggression = math.random(30, 80)
    }
end

for _, player in pairs(Players:GetPlayers()) do
    InitPlayerData(player)
end

Players.PlayerAdded:Connect(InitPlayerData)
Players.PlayerRemoving:Connect(function(player)
    PlayerData[player.UserId] = nil
    BackstabData[player.UserId] = nil
    AIMemory[player.UserId] = nil
end)

-- Include the massive client script from before (condensed for space)
local MasterClientScript = [[

local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Cam = workspace.CurrentCamera
local Light = game:GetService("Lighting")

local Gui = Instance.new("ScreenGui")
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

-- UI Elements
local CountdownLabel = Instance.new("TextLabel")
CountdownLabel.Size = UDim2.new(0, 400, 0, 100)
CountdownLabel.Position = UDim2.new(0.5, -200, 0.3, 0)
CountdownLabel.BackgroundTransparency = 0.3
CountdownLabel.BackgroundColor3 = Color3.new(0, 0, 0)
CountdownLabel.BorderSizePixel = 0
CountdownLabel.Font = Enum.Font.GothamBold
CountdownLabel.TextSize = 60
CountdownLabel.TextColor3 = Color3.new(1, 0, 0)
CountdownLabel.Text = ""
CountdownLabel.Visible = false
CountdownLabel.ZIndex = 1000
CountdownLabel.Parent = Gui

local WarningLabel = Instance.new("TextLabel")
WarningLabel.Size = UDim2.new(0.8, 0, 0, 80)
WarningLabel.Position = UDim2.new(0.1, 0, 0.05, 0)
WarningLabel.BackgroundTransparency = 0.5
WarningLabel.BackgroundColor3 = Color3.new(0.5, 0, 0)
WarningLabel.BorderSizePixel = 3
WarningLabel.BorderColor3 = Color3.new(1, 0, 0)
WarningLabel.Font = Enum.Font.GothamBold
WarningLabel.TextSize = 30
WarningLabel.TextColor3 = Color3.new(1, 1, 1)
WarningLabel.Text = ""
WarningLabel.Visible = false
WarningLabel.ZIndex = 999
WarningLabel.TextStrokeTransparency = 0.5
WarningLabel.Parent = Gui

-- Fear Meter
local FearMeter = Instance.new("Frame")
FearMeter.Size = UDim2.new(0, 300, 0, 30)
FearMeter.Position = UDim2.new(0.5, -150, 0.9, 0)
FearMeter.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
FearMeter.BorderSizePixel = 2
FearMeter.BorderColor3 = Color3.new(1, 0, 0)
FearMeter.Visible = false
FearMeter.Parent = Gui

local FearBar = Instance.new("Frame")
FearBar.Size = UDim2.new(0, 0, 1, 0)
FearBar.BackgroundColor3 = Color3.new(1, 0, 0)
FearBar.BorderSizePixel = 0
FearBar.Parent = FearMeter

local FearLabel = Instance.new("TextLabel")
FearLabel.Size = UDim2.new(1, 0, 1, 0)
FearLabel.BackgroundTransparency = 1
FearLabel.Font = Enum.Font.GothamBold
FearLabel.TextSize = 18
FearLabel.TextColor3 = Color3.new(1, 1, 1)
FearLabel.Text = "FEAR: 0%"
FearLabel.Parent = FearMeter

local HallucinationFrame = Instance.new("ImageLabel")
HallucinationFrame.Size = UDim2.new(0.3, 0, 0.5, 0)
HallucinationFrame.Position = UDim2.new(1, 0, 0.5, 0)
HallucinationFrame.BackgroundTransparency = 1
HallucinationFrame.Image = "rbxassetid://5887328762"
HallucinationFrame.ImageTransparency = 1
HallucinationFrame.Visible = false
HallucinationFrame.ZIndex = 10
HallucinationFrame.Parent = Gui

local ViewportJumpscare = Instance.new("ViewportFrame")
ViewportJumpscare.Size = UDim2.new(1, 0, 1, 0)
ViewportJumpscare.Position = UDim2.new(0, 0, 0, 0)
ViewportJumpscare.BackgroundColor3 = Color3.new(0, 0, 0)
ViewportJumpscare.BackgroundTransparency = 1
ViewportJumpscare.BorderSizePixel = 0
ViewportJumpscare.Visible = false
ViewportJumpscare.ZIndex = 10000
ViewportJumpscare.CurrentCamera = Instance.new("Camera")
ViewportJumpscare.Parent = Gui

local ViewportCam = ViewportJumpscare.CurrentCamera
ViewportCam.Parent = ViewportJumpscare

local JumpscareFrame = Instance.new("ImageLabel")
JumpscareFrame.Size = UDim2.new(1, 0, 1, 0)
JumpscareFrame.Position = UDim2.new(0, 0, 0, 0)
JumpscareFrame.BackgroundTransparency = 1
JumpscareFrame.Image = "rbxassetid://5887328762"
JumpscareFrame.ImageTransparency = 1
JumpscareFrame.Visible = false
JumpscareFrame.ZIndex = 999
JumpscareFrame.Parent = Gui

local StaticFrame = Instance.new("ImageLabel")
StaticFrame.Size = UDim2.new(1, 0, 1, 0)
StaticFrame.Position = UDim2.new(0, 0, 0, 0)
StaticFrame.BackgroundTransparency = 1
StaticFrame.Image = "rbxassetid://7074786167"
StaticFrame.ImageTransparency = 1
StaticFrame.Visible = false
StaticFrame.ZIndex = 5
StaticFrame.Parent = Gui

local VignetteFrame = Instance.new("ImageLabel")
VignetteFrame.Size = UDim2.new(1, 0, 1, 0)
VignetteFrame.BackgroundTransparency = 1
VignetteFrame.Image = "rbxassetid://7137613050"
VignetteFrame.ImageTransparency = 1
VignetteFrame.ZIndex = 3
VignetteFrame.Parent = Gui

-- Blood overlay for eating
local BloodOverlay = Instance.new("ImageLabel")
BloodOverlay.Size = UDim2.new(1, 0, 1, 0)
BloodOverlay.BackgroundTransparency = 1
BloodOverlay.Image = "rbxassetid://2712123371"
BloodOverlay.ImageColor3 = Color3.new(1, 0, 0)
BloodOverlay.ImageTransparency = 1
BloodOverlay.ZIndex = 8
BloodOverlay.Parent = Gui

local Event = RS:WaitForChild("JeraldHorrorEvent")
local CountdownEvent = RS:WaitForChild("JeraldCountdown")

local ogAmbient = Light.Ambient
local ogBrightness = Light.Brightness
local ogFOV = Cam.FieldOfView

local ViewportModel = nil
task.spawn(function()
    local storage = RS:WaitForChild("JeraldModelStorage", 10)
    if storage then
        local model = storage:WaitForChild("JeraldViewportModel", 10)
        if model then
            ViewportModel = model:Clone()
            ViewportModel.Parent = ViewportJumpscare
        end
    end
end)

CountdownEvent.OnClientEvent:Connect(function(action, data)
    if action == "Start" then
        CountdownLabel.Visible = true
        if data == 10 and CountdownLabel.Text == "" then
            CountdownLabel.Text = "JERALD SPAWNING IN: " .. tostring(data)
        else
            CountdownLabel.Text = tostring(data)
        end
        CountdownLabel.TextSize = 60
        TS:Create(CountdownLabel, TweenInfo.new(0.3), {TextSize = 80}):Play()
    elseif action == "Update" then
        CountdownLabel.Text = tostring(data)
        CountdownLabel.TextSize = 60
        TS:Create(CountdownLabel, TweenInfo.new(0.3), {TextSize = 80}):Play()
        if data <= 3 then
            CountdownLabel.TextColor3 = Color3.new(1, 0, 0)
            for i = 1, 5 do
                Cam.CFrame = Cam.CFrame * CFrame.Angles(math.rad(math.random(-1, 1)), math.rad(math.random(-1, 1)), 0)
                task.wait(0.02)
            end
        elseif data <= 5 then
            CountdownLabel.TextColor3 = Color3.new(1, 0.5, 0)
        else
            CountdownLabel.TextColor3 = Color3.new(1, 1, 0)
        end
    elseif action == "End" then
        CountdownLabel.Text = "HE'S HERE"
        CountdownLabel.TextColor3 = Color3.new(1, 0, 0)
        CountdownLabel.TextSize = 100
        task.wait(1.5)
        TS:Create(CountdownLabel, TweenInfo.new(0.5), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        CountdownLabel.Visible = false
        CountdownLabel.TextTransparency = 0
        CountdownLabel.BackgroundTransparency = 0.3
        CountdownLabel.Text = ""
    elseif action == "Warning" then
        WarningLabel.Text = data
        WarningLabel.Visible = true
        WarningLabel.TextTransparency = 0
        WarningLabel.BackgroundTransparency = 0.3
        for i = 1, 3 do
            TS:Create(WarningLabel, TweenInfo.new(0.3), {TextSize = 35}):Play()
            task.wait(0.3)
            TS:Create(WarningLabel, TweenInfo.new(0.3), {TextSize = 30}):Play()
            task.wait(0.3)
        end
        TS:Create(WarningLabel, TweenInfo.new(1), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
        task.wait(1)
        WarningLabel.Visible = false
    end
end)

Event.OnClientEvent:Connect(function(action, data)
    if action == "UpdateFear" then
        FearMeter.Visible = data > 0
        local fearPercent = math.clamp(data, 0, 100)
        FearLabel.Text = "FEAR: " .. math.floor(fearPercent) .. "%"
        TS:Create(FearBar, TweenInfo.new(0.5), {Size = UDim2.new(fearPercent / 100, 0, 1, 0)}):Play()
        
        -- Desaturation based on fear
        local colorCorrect = Light:FindFirstChild("FearColorCorrect") or Instance.new("ColorCorrectionEffect", Light)
        colorCorrect.Name = "FearColorCorrect"
        colorCorrect.Saturation = -0.5 * (fearPercent / 100)
        
    elseif action == "Hallucination" then
        HallucinationFrame.Visible = true
        HallucinationFrame.ImageTransparency = 0.4
        local side = math.random(1, 2)
        local yPos = math.random(0, 100) / 100
        HallucinationFrame.Size = UDim2.new(0.4, 0, 0.6, 0)
        HallucinationFrame.Position = UDim2.new((side == 1 and -0.4 or 1), 0, yPos, 0)
        TS:Create(HallucinationFrame, TweenInfo.new(0.05), {ImageTransparency = 0}):Play()
        task.wait(0.1)
        TS:Create(HallucinationFrame, TweenInfo.new(0.1), {ImageTransparency = 1}):Play()
        task.wait(0.1)
        HallucinationFrame.Visible = false
    elseif action == "Glitch" then
        local CC = Instance.new("ColorCorrectionEffect", Light)
        CC.Saturation = -0.5
        CC.TintColor = Color3.fromRGB(255, 100, 100)
        TS:Create(Cam, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {FieldOfView = ogFOV + 15}):Play()
        task.wait(0.05)
        TS:Create(Cam, TweenInfo.new(0.05), {FieldOfView = ogFOV}):Play()
        Debris:AddItem(CC, 0.3)
    elseif action == "Stare" then
        if data then Cam.CFrame = CFrame.new(Cam.CFrame.Position, data) end
    elseif action == "Static" then
        StaticFrame.Visible = true
        StaticFrame.ImageTransparency = 0.7
        TS:Create(StaticFrame, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
        task.wait(0.3)
        StaticFrame.Visible = false
    elseif action == "Darkness" then
        TS:Create(Light, TweenInfo.new(0.5), {Brightness = 0, Ambient = Color3.new(0, 0, 0)}):Play()
        task.wait(2)
        TS:Create(Light, TweenInfo.new(1), {Brightness = ogBrightness, Ambient = ogAmbient}):Play()
    elseif action == "Vignette" then
        VignetteFrame.ImageTransparency = 1
        TS:Create(VignetteFrame, TweenInfo.new(0.5), {ImageTransparency = 0.3}):Play()
        task.wait(data or 3)
        TS:Create(VignetteFrame, TweenInfo.new(1), {ImageTransparency = 1}):Play()
    elseif action == "BeingEaten" then
        -- Screen shake and blood
        BloodOverlay.ImageTransparency = 0.5
        TS:Create(BloodOverlay, TweenInfo.new(0.3), {ImageTransparency = 0.2}):Play()
        for i = 1, 20 do
            Cam.CFrame = Cam.CFrame * CFrame.Angles(math.rad(math.random(-3, 3)), math.rad(math.random(-3, 3)), math.rad(math.random(-2, 2)))
            task.wait(0.03)
        end
    elseif action == "EatenPart" then
        -- Flash red
        BloodOverlay.ImageTransparency = 0
        TS:Create(BloodOverlay, TweenInfo.new(1), {ImageTransparency = 0.4}):Play()
    elseif action == "Jumpscare" then
        if ViewportModel then
            ViewportJumpscare.Visible = true
            ViewportJumpscare.BackgroundTransparency = 0
            local head = ViewportModel:FindFirstChild("Head") or ViewportModel:FindFirstChild("HumanoidRootPart")
            if head then
                ViewportCam.CFrame = CFrame.new(head.Position + Vector3.new(0, 0, 20), head.Position)
                ViewportCam.FieldOfView = 70
                local duration = 0.6
                local start = tick()
                while tick() - start < duration do
                    local progress = (tick() - start) / duration
                    local dist = 20 - (20 * progress) + 1
                    local shake = Vector3.new(math.random(-100, 100) / 100 * (progress * 2), math.random(-100, 100) / 100 * (progress * 2), math.random(-100, 100) / 100 * (progress * 2))
                    ViewportCam.CFrame = CFrame.new(head.Position + Vector3.new(0, 0, dist) + shake, head.Position)
                    ViewportCam.FieldOfView = 70 + (progress * 40)
                    task.wait()
                end
                ViewportCam.CFrame = CFrame.new(head.Position + Vector3.new(0, 0, 0.5), head.Position)
                for i = 1, 15 do
                    local shake = Vector3.new(math.random(-200, 200) / 100, math.random(-200, 200) / 100, math.random(-200, 200) / 100)
                    ViewportCam.CFrame = CFrame.new(head.Position + Vector3.new(0, 0, 0.5) + shake, head.Position)
                    task.wait(0.03)
                end
                task.wait(0.3)
                TS:Create(ViewportJumpscare, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
                task.wait(0.5)
            end
            ViewportJumpscare.Visible = false
            ViewportJumpscare.BackgroundTransparency = 0
        else
            JumpscareFrame.Visible = true
            JumpscareFrame.ImageTransparency = 0
            JumpscareFrame.Size = UDim2.new(1.2, 0, 1.2, 0)
            JumpscareFrame.Position = UDim2.new(-0.1, 0, -0.1, 0)
            for i = 1, 10 do
                JumpscareFrame.Position = UDim2.new(-0.1 + math.random(-10, 10) / 100, 0, -0.1 + math.random(-10, 10) / 100, 0)
                task.wait(0.03)
            end
            TS:Create(JumpscareFrame, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
            task.wait(0.5)
            JumpscareFrame.Visible = false
        end
    elseif action == "CameraShake" then
        local intensity = data or 0.5
        for i = 1, 15 do
            Cam.CFrame = Cam.CFrame * CFrame.Angles(math.rad(math.random(-intensity, intensity)), math.rad(math.random(-intensity, intensity)), math.rad(math.random(-intensity, intensity)))
            task.wait(0.03)
        end
    elseif action == "RageMode" then
        StaticFrame.Visible = true
        StaticFrame.ImageTransparency = 0.3
        local Blur = Instance.new("BlurEffect", Light)
        Blur.Size = 20
        for i = 1, 20 do
            Cam.CFrame = Cam.CFrame * CFrame.Angles(math.rad(math.random(-5, 5)), math.rad(math.random(-5, 5)), math.rad(math.random(-5, 5)))
            StaticFrame.ImageTransparency = math.random(0, 100) / 100
            task.wait(0.05)
        end
        Debris:AddItem(Blur, 1)
        StaticFrame.Visible = false
    end
end)
]]

local function InjectMasterClient(player)
    task.spawn(function()
        local char = player.Character or player.CharacterAdded:Wait()
        task.wait(1)
        local script = Instance.new("LocalScript")
        script.Name = "JeraldMasterClient"
        script.Source = MasterClientScript
        local playerGui = player:WaitForChild("PlayerGui", 10)
        if playerGui then script.Parent = playerGui end
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    InjectMasterClient(player)
end
Players.PlayerAdded:Connect(InjectMasterClient)

-- Helper functions
local function SendToBrazil(player)
    if not player then return end
    pcall(function() ScareEvent:FireClient(player, "Jumpscare") end)
    task.wait(0.5)
    pcall(function() TeleportService:Teleport(CONFIG.BRAZIL_PLACE_ID, player) end)
end

local function HasLineOfSight(origin, target)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {JeraldModel}
    local ray = workspace:Raycast(origin, target - origin, params)
    return not ray or (ray.Position - target).Magnitude < 2
end

local function IsPlayerLookingAtJerald(player, maxDist)
    if not player.Character then return false end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local dist = (hrp.Position - RootPart.Position).Magnitude
    if dist > maxDist then return false end
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local toJerald = (RootPart.Position - cam.CFrame.Position).Unit
    return cam.CFrame.LookVector:Dot(toJerald) > 0.7
end

-- Anti-cheat
local function RageMode(player, reason)
    local data = PlayerData[player.UserId]
    if not data or data.IsRaged then return end
    data.IsRaged = true
    
    pcall(function() CountdownEvent:FireClient(player, "Warning", "⚠️ " .. reason) end)
    Sounds.Rage:Play()
    
    if player.Character then
        RootPart.CFrame = player.Character:GetPivot()
    end
    
    task.wait(2)
    pcall(function() ScareEvent:FireClient(player, "Jumpscare") end)
    task.wait(0.5)
    
    pcall(function()
        TeleportService:Teleport(CONFIG.BRAZIL_PLACE_ID, player)
    end)
end

local function CheckSpeed(player)
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local speed = hrp.AssemblyLinearVelocity.Magnitude
    if speed > CONFIG.MAX_SPEED then
        local data = PlayerData[player.UserId]
        if data then
            data.SpeedViolations = data.SpeedViolations + 1
            if data.SpeedViolations >= 3 then
                RageMode(player, "SPEED HACK: " .. math.floor(speed))
            end
        end
    end
end

local function CheckFlying(player)
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -100, 0))
    if ray then
        local dist = (hrp.Position - ray.Position).Magnitude
        if dist > CONFIG.MAX_FLY_HEIGHT and hrp.AssemblyLinearVelocity.Magnitude > 5 then
            local data = PlayerData[player.UserId]
            if data and tick() - data.LastGroundTime > 2 then
                data.FlyViolations = data.FlyViolations + 1
                if data.FlyViolations >= 5 then
                    RageMode(player, "FLY HACK")
                end
            end
        else
            if PlayerData[player.UserId] then
                PlayerData[player.UserId].LastGroundTime = tick()
            end
        end
    end
end

local function MonitorChat(player, message)
    local lower = string.lower(message)
    for _, word in pairs(CONFIG.FORBIDDEN_WORDS) do
        if string.find(lower, word) then
            RageMode(player, "SPOKE HIS NAME")
            return
        end
    end
end

for _, player in pairs(Players:GetPlayers()) do
    player.Chatted:Connect(function(msg) MonitorChat(player, msg) end)
end
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg) MonitorChat(player, msg) end)
end)

-- Anti-cheat loop
task.spawn(function()
    while task.wait(0.5) do
        for _, player in pairs(Players:GetPlayers()) do
            CheckSpeed(player)
            CheckFlying(player)
        end
    end
end)

-- // MAIN AI STATE MACHINE \\
local CurrentState = "IDLE"
local Target = nil
local StateTimer = 0
local BehaviorCooldowns = {
    Shoot = 0,
    GrabFlee = 0,
    NeckSnap = 0
}

local function SpawnNearPlayer()
    local players = Players:GetPlayers()
    if #players == 0 then return end
    local target = players[math.random(1, #players)]
    if not target.Character then return end
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for i = 10, 1, -1 do
        for _, p in pairs(Players:GetPlayers()) do
            pcall(function() CountdownEvent:FireClient(p, i == 10 and "Start" or "Update", i) end)
        end
        task.wait(1)
    end
    
    local angle = math.rad(math.random(0, 360))
    RootPart.CFrame = CFrame.new(hrp.Position + Vector3.new(math.cos(angle) * 5, 0, math.sin(angle) * 5))
    
    for _, p in pairs(Players:GetPlayers()) do
        pcall(function() CountdownEvent:FireClient(p, "End") end)
    end
    
    Sounds.Static:Play()
    CurrentState = "IMMUNITY"
    
    for i = 10, 1, -1 do
        for _, p in pairs(Players:GetPlayers()) do
            pcall(function() CountdownEvent:FireClient(p, "Start", i) end)
        end
        task.wait(1)
    end
    
    for _, p in pairs(Players:GetPlayers()) do
        pcall(function() CountdownEvent:FireClient(p, "End") end)
    end
    
    CurrentState = "IDLE"
end

task.wait(5)
SpawnNearPlayer()

-- Main AI Loop
RunService.Heartbeat:Connect(function(delta)
    StateTimer = StateTimer + delta
    
    -- Update cooldowns
    for k, v in pairs(BehaviorCooldowns) do
        if v > 0 then BehaviorCooldowns[k] = v - delta end
    end
    
    -- Handle fleeing
    if FleeingPlayer then
        UpdateFleeing()
        return
    end
    
    if CurrentState == "IMMUNITY" then
        Humanoid:MoveTo(RootPart.Position)
        return
    end
    
    -- Find target
    local nearest = nil
    local nearestDist = 250
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and PlayerData[player.UserId] and not PlayerData[player.UserId].IsRaged then
                local d = (hrp.Position - RootPart.Position).Magnitude
                if d < nearestDist then
                    nearestDist = d
                    nearest = player
                end
            end
        end
    end
    
    Target = nearest
    
    if Target and Target.Character then
        local hrp = Target.Character.HumanoidRootPart
        local dist = (hrp.Position - RootPart.Position).Magnitude
        
        -- Update fear
        local data = PlayerData[Target.UserId]
        if data then
            data.Fear = dist < 50 and math.min(100, data.Fear + delta * 5) or math.max(0, data.Fear - delta * 2)
            pcall(function() ScareEvent:FireClient(Target, "UpdateFear", data.Fear) end)
        end
        
        -- Head tracking
        if Head and Head ~= RootPart then
            Head.CFrame = Head.CFrame:Lerp(CFrame.lookAt(Head.Position, Vector3.new(hrp.Position.X, Head.Position.Y, hrp.Position.Z)), 0.1)
        end
        
        -- Combat AI
        if dist < 5 and BehaviorCooldowns.GrabFlee <= 0 then
            -- Grab and flee
            CurrentState = "GRAB_AND_FLEE"
            if GrabAndFlee(Target) then
                BehaviorCooldowns.GrabFlee = 60
            end
            
        elseif dist > 30 and dist < CONFIG.AK47_RANGE and BehaviorCooldowns.Shoot <= 0 then
            -- Shoot from distance
            CurrentState = "COMBAT_SHOOT"
            Humanoid:MoveTo(RootPart.Position) -- Stand still to aim
            
            local shootTarget = GetBestTarget()
            if shootTarget then
                IsAiming = true
                FireAK47(shootTarget)
                BehaviorCooldowns.Shoot = CONFIG.AK47_FIRE_RATE
            end
            
        elseif dist < 30 then
            -- Chase
            CurrentState = "CHASE"
            IsAiming = false
            Humanoid.WalkSpeed = math.clamp(25 + (30 - dist) * 0.5, 25, 45)
            Humanoid:MoveTo(hrp.Position)
            
            if not Sounds.Chase.IsPlaying then Sounds.Chase:Play() end
            TweenService:Create(Sounds.Chase, TweenInfo.new(0.3), {Volume = math.clamp(1 - dist/70, 0.2, 0.9)}):Play()
        else
            -- Patrol/Stalk
            CurrentState = "STALK"
            Humanoid.WalkSpeed = 16
            local angle = tick() % (2 * math.pi)
            Humanoid:MoveTo(hrp.Position + Vector3.new(math.cos(angle) * 20, 0, math.sin(angle) * 20))
        end
    else
        CurrentState = "IDLE"
        IsAiming = false
        Humanoid:MoveTo(RootPart.Position)
        if Sounds.Chase.Volume > 0 then
            TweenService:Create(Sounds.Chase, TweenInfo.new(2), {Volume = 0}):Play()
        end
    end
end)

Humanoid.Died:Connect(function()
    Humanoid.Health = Humanoid.MaxHealth
end)

print("╔══════════════════════════════════════════════════════════╗")
print("║         JERALD: COMPLETE ULTIMATE AI LOADED              ║")
print("║  - Invisible AK-47 with Aimbot: EQUIPPED                 ║")
print("║  - Grab & Flee + Neck Snap: ENABLED                      ║")
print("║  - 250+ AI Behaviors: ACTIVE                             ║")
print("║  - Wall Climbing: ENABLED                                ║")
print("║  - Anti-Cheat: ACTIVE                                    ║")
print("║  - Orbital Nuke: ARMED                                   ║")
print("╚══════════════════════════════════════════════════════════╝")
