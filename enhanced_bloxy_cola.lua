local player = game:GetService("Players").LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local debris = game:GetService("Debris")

-- Cleanup
for _, v in pairs(player.PlayerGui:GetChildren()) do 
    if v.Name == "ColaGui" then v:Destroy() end 
end

local tool = Instance.new("Tool")
tool.Name = "Bloxy Cola"
tool.Parent = player.Backpack
tool.RequiresHandle = true

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(1, 1.2, 1)
handle.Parent = tool

local mesh = Instance.new("SpecialMesh")
mesh.MeshId = "rbxassetid://10470609"
mesh.TextureId = "rbxassetid://10470600"
mesh.Parent = handle

local foam = Instance.new("ParticleEmitter", handle)
foam.Texture = "rbxassetid://2430535539"
foam.Rate = 0
foam.Speed = NumberRange.new(10, 20)
foam.Size = NumberSequence.new(1, 5)
foam.Lifetime = NumberRange.new(0.5, 1)
foam.EmissionDirection = Enum.NormalId.Top

-- Settings
local drinksDone = 0
local isAddicted = false
local lastDrinkTime = tick()
local isDrunk = false
local isSitting = false
local isSleeping = false
local nausea = 0 -- New: nausea meter
local hasVomited = false
local isRagdolled = false
local heartbeatCounter = 0
local isCar = false
local hasWings = false
local isLevitating = false
local originalHeadSize = nil
local originalHeadColor = nil
local witchsBrewActive = false
local isInvisible = false
local isAmongUs = false
local isPeppaPigActive = false

local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "ColaGui"
screenGui.ResetOnSpawn = true
screenGui.IgnoreGuiInset = true

-- Create nausea meter
local nauseaFrame = Instance.new("Frame", screenGui)
nauseaFrame.Size = UDim2.new(0, 200, 0, 25)
nauseaFrame.Position = UDim2.new(0.5, -100, 0.05, 0)
nauseaFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
nauseaFrame.BorderSizePixel = 2
nauseaFrame.BorderColor3 = Color3.new(0, 0, 0)
nauseaFrame.Visible = false

local nauseaBar = Instance.new("Frame", nauseaFrame)
nauseaBar.Size = UDim2.new(0, 0, 1, 0)
nauseaBar.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
nauseaBar.BorderSizePixel = 0

local nauseaLabel = Instance.new("TextLabel", nauseaFrame)
nauseaLabel.Size = UDim2.new(1, 0, 1, 0)
nauseaLabel.BackgroundTransparency = 1
nauseaLabel.Text = "Nausea"
nauseaLabel.TextColor3 = Color3.new(1, 1, 1)
nauseaLabel.Font = Enum.Font.SourceSansBold
nauseaLabel.TextSize = 16

local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton", screenGui)
    btn.Size = UDim2.new(0, 150, 0, 45)
    btn.Position = pos
    btn.Visible = false
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.BorderSizePixel = 2
    btn.BorderColor3 = Color3.new(0, 0, 0)
    return btn
end

local sitBtn = createBtn("Sit", UDim2.new(0.5, -235, 0.8, 0), Color3.fromRGB(100, 50, 20))
local sleepBtn = createBtn("Sleep", UDim2.new(0.5, -75, 0.8, 0), Color3.fromRGB(40, 40, 100))
local vomitBtn = createBtn("Vomit", UDim2.new(0.5, 85, 0.8, 0), Color3.fromRGB(100, 150, 50))

local phrases = {
    "DRINK BLOXY COLA!", 
    "DRINK BLOXY COLA OR DIE", 
    "You Getting Crazy Drink Bloxy cola", 
    "Hello Drink Bloxy Cola",
    "MORE... MORE COLA...",
    "I NEED IT NOW!",
    "JUST ONE MORE SIP...",
    "THE COLA CALLS TO ME..."
}

-- Effect types that can randomly occur
local effectTypes = {
    "normal",      -- Regular drunk effect
    "car",         -- Transform into car
    "wings",       -- Grow wings and levitate
    "witchsbrew",  -- Head size/color randomization
    "ragdoll",     -- Ragdoll physics
    "vomit",       -- Instant vomit
    "invisible",   -- Minecraft invisibility
    "amongus",     -- Among Us character
    "peppapig"     -- Forced Peppa Pig video
}

-- Enhanced blur and color effects
local function addDrunkEffects()
    -- Blur
    if not camera:FindFirstChild("ColaBlur") then
        local blur = Instance.new("BlurEffect", camera)
        blur.Size = 5
        blur.Name = "ColaBlur"
    end
    
    -- Color correction for drunk vision
    if not camera:FindFirstChild("ColaColor") then
        local colorCorrect = Instance.new("ColorCorrectionEffect", camera)
        colorCorrect.Name = "ColaColor"
        colorCorrect.Saturation = 0.3
        colorCorrect.TintColor = Color3.fromRGB(255, 220, 200)
    end
    
    -- Chromatic aberration effect
    if not camera:FindFirstChild("ColaSunRays") then
        local sunRays = Instance.new("SunRaysEffect", camera)
        sunRays.Name = "ColaSunRays"
        sunRays.Intensity = 0.05
        sunRays.Spread = 1
    end
end

local function removeDrunkEffects()
    if camera:FindFirstChild("ColaBlur") then camera.ColaBlur:Destroy() end
    if camera:FindFirstChild("ColaColor") then camera.ColaColor:Destroy() end
    if camera:FindFirstChild("ColaSunRays") then camera.ColaSunRays:Destroy() end
end

-- NEW: Car transformation effect
local function transformIntoCar(duration)
    local char = player.Character
    if not char or isCar then return end
    
    isCar = true
    local hum = char:FindFirstChild("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not hum or not rootPart then return end
    
    -- Hide body parts
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 1
        end
        if part:IsA("Accessory") then
            part.Handle.Transparency = 1
        end
    end
    
    -- Create car body
    local carBody = Instance.new("Part")
    carBody.Name = "CarBody"
    carBody.Size = Vector3.new(6, 3, 10)
    carBody.Color = Color3.fromRGB(math.random(100, 255), math.random(100, 255), math.random(100, 255))
    carBody.Material = Enum.Material.SmoothPlastic
    carBody.CanCollide = true
    carBody.Parent = char
    
    -- Weld to character
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = rootPart
    weld.Part1 = carBody
    weld.Parent = carBody
    
    -- Add car mesh
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1047302736" -- Car mesh
    mesh.Scale = Vector3.new(0.15, 0.15, 0.15)
    mesh.Parent = carBody
    
    -- Engine sound
    local engineSound = Instance.new("Sound", carBody)
    engineSound.SoundId = "rbxassetid://9113934668"
    engineSound.Looped = true
    engineSound.Volume = 0.4
    engineSound.Name = "EngineSound"
    engineSound:Play()
    
    -- Speed boost
    hum.WalkSpeed = 60
    
    -- Exhaust particles
    local exhaust = Instance.new("Part")
    exhaust.Size = Vector3.new(0.5, 0.5, 0.5)
    exhaust.Transparency = 1
    exhaust.CanCollide = false
    exhaust.Parent = char
    
    local exhaustWeld = Instance.new("WeldConstraint")
    exhaustWeld.Part0 = carBody
    exhaustWeld.Part1 = exhaust
    exhaustWeld.Parent = exhaust
    
    local exhaustParticle = Instance.new("ParticleEmitter")
    exhaustParticle.Parent = exhaust
    exhaustParticle.Texture = "rbxassetid://2420770853"
    exhaustParticle.Rate = 20
    exhaustParticle.Lifetime = NumberRange.new(0.5, 1)
    exhaustParticle.Speed = NumberRange.new(5, 10)
    exhaustParticle.Color = ColorSequence.new(Color3.fromRGB(100, 100, 100))
    exhaustParticle.Size = NumberSequence.new(1, 3)
    exhaustParticle.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })
    
    -- Horn sound on jump
    local hornConnection
    hornConnection = hum.Jumping:Connect(function()
        local horn = Instance.new("Sound", carBody)
        horn.SoundId = "rbxassetid://9120386436"
        horn.Volume = 0.6
        horn:Play()
        debris:AddItem(horn, 2)
    end)
    
    -- Show notification
    local notify = Instance.new("TextLabel", screenGui)
    notify.Size = UDim2.new(0, 300, 0, 60)
    notify.Position = UDim2.new(0.5, -150, 0.4, 0)
    notify.BackgroundTransparency = 0.3
    notify.BackgroundColor3 = Color3.new(0, 0, 0)
    notify.TextColor3 = Color3.fromRGB(255, 200, 0)
    notify.TextScaled = true
    notify.Text = "🚗 CAR MODE ACTIVATED! 🚗"
    notify.Font = Enum.Font.SourceSansBold
    
    task.delay(3, function() notify:Destroy() end)
    
    -- Restore after duration
    task.wait(duration or 15)
    
    if carBody.Parent then
        carBody:Destroy()
        exhaust:Destroy()
        hornConnection:Disconnect()
    end
    
    -- Restore character
    if char and char.Parent then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0
            end
            if part:IsA("Accessory") then
                part.Handle.Transparency = 0
            end
        end
    end
    
    if hum then
        hum.WalkSpeed = 16
    end
    
    isCar = false
end

-- NEW: Ragdoll physics function
local function ragdollCharacter(duration)
    local char = player.Character
    if not char or isRagdolled then return end
    
    isRagdolled = true
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    
    -- Save original state
    hum.PlatformStand = true
    hum.AutoRotate = false
    
    -- Create ragdoll joints
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("Motor6D") then
            local a0 = Instance.new("Attachment")
            local a1 = Instance.new("Attachment")
            a0.Parent = v.Part0
            a1.Parent = v.Part1
            a0.CFrame = v.C0
            a1.CFrame = v.C1
            
            local socket = Instance.new("BallSocketConstraint")
            socket.Parent = v.Parent
            socket.Attachment0 = a0
            socket.Attachment1 = a1
            socket.LimitsEnabled = true
            socket.TwistLimitsEnabled = true
            socket.UpperAngle = 45
            socket.TwistLowerAngle = -45
            socket.TwistUpperAngle = 45
            socket.Name = "RagdollSocket"
            
            v.Enabled = false
        end
    end
    
    -- Add random force
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(math.random(-20, 20), 5, math.random(-20, 20))
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Parent = rootPart
        debris:AddItem(bodyVelocity, 0.1)
    end
    
    -- Restore after duration
    task.wait(duration or 3)
    
    if char and char.Parent then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("Motor6D") then
                v.Enabled = true
            end
            if v.Name == "RagdollSocket" or v:IsA("Attachment") then
                v:Destroy()
            end
        end
        
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = true
        end
    end
    
    isRagdolled = false
end

-- NEW: Vomit effect
local function createVomit()
    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end
    
    hasVomited = true
    
    -- Vomit particle effect
    local vomitEmitter = Instance.new("ParticleEmitter")
    vomitEmitter.Parent = head
    vomitEmitter.Texture = "rbxassetid://6490035152" -- Splatter texture
    vomitEmitter.Rate = 100
    vomitEmitter.Lifetime = NumberRange.new(1, 2)
    vomitEmitter.Speed = NumberRange.new(10, 20)
    vomitEmitter.SpreadAngle = Vector2.new(30, 30)
    vomitEmitter.Color = ColorSequence.new(Color3.fromRGB(120, 150, 60))
    vomitEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.5, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    vomitEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    })
    vomitEmitter.Acceleration = Vector3.new(0, -20, 0)
    vomitEmitter.EmissionDirection = Enum.NormalId.Front
    
    -- Vomit sound
    local vomitSound = Instance.new("Sound", head)
    vomitSound.SoundId = "rbxassetid://142283152" -- Vomit sound
    vomitSound.Volume = 0.5
    vomitSound.PlaybackSpeed = 0.8
    vomitSound:Play()
    
    -- Screen shake
    task.spawn(function()
        for i = 1, 20 do
            camera.CFrame = camera.CFrame * CFrame.Angles(
                math.rad(math.random(-2, 2)),
                math.rad(math.random(-2, 2)),
                math.rad(math.random(-2, 2))
            )
            task.wait(0.05)
        end
    end)
    
    -- Create vomit puddle
    task.spawn(function()
        task.wait(0.5)
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local puddle = Instance.new("Part")
            puddle.Size = Vector3.new(4, 0.1, 4)
            puddle.CFrame = rootPart.CFrame * CFrame.new(0, -3, -2)
            puddle.Anchored = true
            puddle.CanCollide = false
            puddle.Color = Color3.fromRGB(120, 150, 60)
            puddle.Material = Enum.Material.SmoothPlastic
            puddle.Transparency = 0.3
            puddle.Parent = workspace
            
            local decal = Instance.new("Decal", puddle)
            decal.Texture = "rbxassetid://6490035152"
            decal.Face = Enum.NormalId.Top
            
            debris:AddItem(puddle, 30)
        end
    end)
    
    task.wait(2)
    vomitEmitter:Destroy()
    vomitSound:Destroy()
    
    -- Reset nausea
    nausea = 0
    nauseaFrame.Visible = false
    hasVomited = false
end

-- NEW: Wings and levitation effect
local function giveWings(duration)
    local char = player.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
    local torso = char and (char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
    if not rootPart or not torso or hasWings then return end
    
    hasWings = true
    isLevitating = true
    
    -- Create left wing
    local leftWing = Instance.new("Part")
    leftWing.Name = "LeftWing"
    leftWing.Size = Vector3.new(0.5, 4, 2)
    leftWing.Color = Color3.fromRGB(255, 255, 255)
    leftWing.Material = Enum.Material.Neon
    leftWing.CanCollide = false
    leftWing.Parent = char
    
    local leftMesh = Instance.new("SpecialMesh")
    leftMesh.MeshType = Enum.MeshType.FileMesh
    leftMesh.MeshId = "rbxassetid://19367179"
    leftMesh.Scale = Vector3.new(1, 1, 1)
    leftMesh.Parent = leftWing
    
    local leftWeld = Instance.new("Weld")
    leftWeld.Part0 = torso
    leftWeld.Part1 = leftWing
    leftWeld.C0 = CFrame.new(-1.5, 0.5, 0.5) * CFrame.Angles(0, math.rad(20), 0)
    leftWeld.Parent = leftWing
    
    -- Create right wing
    local rightWing = Instance.new("Part")
    rightWing.Name = "RightWing"
    rightWing.Size = Vector3.new(0.5, 4, 2)
    rightWing.Color = Color3.fromRGB(255, 255, 255)
    rightWing.Material = Enum.Material.Neon
    rightWing.CanCollide = false
    rightWing.Parent = char
    
    local rightMesh = Instance.new("SpecialMesh")
    rightMesh.MeshType = Enum.MeshType.FileMesh
    rightMesh.MeshId = "rbxassetid://19367179"
    rightMesh.Scale = Vector3.new(1, 1, 1)
    rightMesh.Parent = rightWing
    
    local rightWeld = Instance.new("Weld")
    rightWeld.Part0 = torso
    rightWeld.Part1 = rightWing
    rightWeld.C0 = CFrame.new(1.5, 0.5, 0.5) * CFrame.Angles(0, math.rad(-20), 0)
    rightWeld.Parent = rightWing
    
    -- Wing glow effect
    local glow = Instance.new("PointLight")
    glow.Name = "WingGlow"
    glow.Brightness = 2
    glow.Range = 15
    glow.Color = Color3.fromRGB(255, 220, 150)
    glow.Parent = torso
    
    -- Feather particles
    local feathers = Instance.new("ParticleEmitter")
    feathers.Parent = torso
    feathers.Texture = "rbxassetid://6490035152"
    feathers.Rate = 5
    feathers.Lifetime = NumberRange.new(2, 3)
    feathers.Speed = NumberRange.new(1, 3)
    feathers.SpreadAngle = Vector2.new(180, 180)
    feathers.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    feathers.Size = NumberSequence.new(0.3, 0.1)
    feathers.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    feathers.Rotation = NumberRange.new(0, 360)
    feathers.Name = "FeatherParticles"
    
    -- Angelic sound
    local angelSound = Instance.new("Sound", torso)
    angelSound.SoundId = "rbxassetid://1843463175"
    angelSound.Volume = 0.5
    angelSound.Looped = true
    angelSound.Name = "AngelSound"
    angelSound:Play()
    
    -- Notification
    local notify = Instance.new("TextLabel", screenGui)
    notify.Size = UDim2.new(0, 350, 0, 60)
    notify.Position = UDim2.new(0.5, -175, 0.4, 0)
    notify.BackgroundTransparency = 0.3
    notify.BackgroundColor3 = Color3.new(0, 0, 0)
    notify.TextColor3 = Color3.fromRGB(255, 220, 150)
    notify.TextScaled = true
    notify.Text = "👼 WINGS ACTIVATED! 👼"
    notify.Font = Enum.Font.SourceSansBold
    
    task.delay(3, function() notify:Destroy() end)
    
    -- Levitation mechanics
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    bodyVelocity.Velocity = Vector3.new(0, 20, 0)
    bodyVelocity.Parent = rootPart
    bodyVelocity.Name = "LevitationForce"
    
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = 30
    end
    
    -- Wing flapping animation
    task.spawn(function()
        local flapSpeed = 0
        while hasWings and leftWing.Parent and rightWing.Parent do
            flapSpeed = flapSpeed + 0.2
            local flapAngle = math.sin(flapSpeed) * 30
            
            leftWeld.C0 = CFrame.new(-1.5, 0.5, 0.5) * CFrame.Angles(0, math.rad(20 + flapAngle), 0)
            rightWeld.C0 = CFrame.new(1.5, 0.5, 0.5) * CFrame.Angles(0, math.rad(-20 - flapAngle), 0)
            
            task.wait(0.05)
        end
    end)
    
    -- Gradual descent after reaching height
    task.wait(5)
    if bodyVelocity.Parent then
        bodyVelocity.Velocity = Vector3.new(0, 5, 0)
    end
    
    task.wait(duration - 5 or 15)
    
    -- Remove wings
    if leftWing.Parent then leftWing:Destroy() end
    if rightWing.Parent then rightWing:Destroy() end
    if glow.Parent then glow:Destroy() end
    if feathers.Parent then feathers:Destroy() end
    if angelSound.Parent then angelSound:Destroy() end
    if bodyVelocity.Parent then bodyVelocity:Destroy() end
    
    if hum then
        hum.WalkSpeed = 16
    end
    
    hasWings = false
    isLevitating = false
end

-- NEW: Witch's Brew effect (random head size and color)
local function applyWitchsBrew(duration)
    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    if not head or witchsBrewActive then return end
    
    witchsBrewActive = true
    
    -- Save original values
    if not originalHeadSize then
        originalHeadSize = head.Size
    end
    if not originalHeadColor then
        originalHeadColor = head.Color
    end
    
    -- Random colors
    local colors = {
        Color3.fromRGB(255, 0, 0),      -- Red
        Color3.fromRGB(0, 255, 0),      -- Green
        Color3.fromRGB(0, 0, 255),      -- Blue
        Color3.fromRGB(255, 0, 255),    -- Magenta
        Color3.fromRGB(255, 255, 0),    -- Yellow
        Color3.fromRGB(0, 255, 255),    -- Cyan
        Color3.fromRGB(255, 128, 0),    -- Orange
        Color3.fromRGB(128, 0, 255),    -- Purple
        Color3.fromRGB(255, 192, 203),  -- Pink
        Color3.fromRGB(0, 255, 128)     -- Spring green
    }
    
    -- Random size options
    local sizeMultipliers = {0.3, 0.5, 0.7, 1.5, 2, 2.5, 3, 4}
    
    -- Apply random effect
    local randomSize = sizeMultipliers[math.random(1, #sizeMultipliers)]
    local randomColor = colors[math.random(1, #colors)]
    
    head.Size = originalHeadSize * randomSize
    head.Color = randomColor
    
    -- Rainbow glow effect
    local glow = Instance.new("PointLight")
    glow.Name = "WitchGlow"
    glow.Brightness = 3
    glow.Range = 20
    glow.Color = randomColor
    glow.Parent = head
    
    -- Sparkle particles
    local sparkles = Instance.new("ParticleEmitter")
    sparkles.Parent = head
    sparkles.Texture = "rbxassetid://2426650658"
    sparkles.Rate = 30
    sparkles.Lifetime = NumberRange.new(0.5, 1)
    sparkles.Speed = NumberRange.new(2, 5)
    sparkles.SpreadAngle = Vector2.new(180, 180)
    sparkles.Color = ColorSequence.new(randomColor)
    sparkles.Size = NumberSequence.new(0.5, 0)
    sparkles.LightEmission = 1
    sparkles.Name = "WitchSparkles"
    
    -- Potion sound
    local potionSound = Instance.new("Sound", head)
    potionSound.SoundId = "rbxassetid://5140864083"
    potionSound.Volume = 0.6
    potionSound:Play()
    debris:AddItem(potionSound, 3)
    
    -- Notification with size description
    local sizeText = randomSize < 1 and "TINY" or (randomSize > 2 and "GIANT" or "BIG")
    local notify = Instance.new("TextLabel", screenGui)
    notify.Size = UDim2.new(0, 400, 0, 60)
    notify.Position = UDim2.new(0.5, -200, 0.4, 0)
    notify.BackgroundTransparency = 0.3
    notify.BackgroundColor3 = Color3.new(0, 0, 0)
    notify.TextColor3 = randomColor
    notify.TextScaled = true
    notify.Text = "🧙 WITCH'S BREW: " .. sizeText .. " HEAD! 🧙"
    notify.Font = Enum.Font.SourceSansBold
    
    task.delay(3, function() notify:Destroy() end)
    
    -- Color cycling effect
    task.spawn(function()
        local colorIndex = 1
        while witchsBrewActive and head.Parent do
            task.wait(0.5)
            colorIndex = colorIndex + 1
            if colorIndex > #colors then colorIndex = 1 end
            head.Color = colors[colorIndex]
            if glow.Parent then
                glow.Color = colors[colorIndex]
            end
            if sparkles.Parent then
                sparkles.Color = ColorSequence.new(colors[colorIndex])
            end
        end
    end)
    
    -- Restore after duration
    task.wait(duration or 20)
    
    if head.Parent and originalHeadSize then
        head.Size = originalHeadSize
    end
    if head.Parent and originalHeadColor then
        head.Color = originalHeadColor
    end
    
    if glow.Parent then glow:Destroy() end
    if sparkles.Parent then sparkles:Destroy() end
    
    witchsBrewActive = false
end

-- NEW: Minecraft invisibility effect
local function applyInvisibility(duration)
    local char = player.Character
    if not char or isInvisible then return end
    
    isInvisible = true
    
    -- Invisibility particles (like Minecraft)
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if torso then
        local invisParticles = Instance.new("ParticleEmitter")
        invisParticles.Parent = torso
        invisParticles.Texture = "rbxassetid://2426650658" -- Sparkle texture
        invisParticles.Rate = 10
        invisParticles.Lifetime = NumberRange.new(0.5, 1)
        invisParticles.Speed = NumberRange.new(0, 2)
        invisParticles.SpreadAngle = Vector2.new(180, 180)
        invisParticles.Color = ColorSequence.new(Color3.fromRGB(150, 150, 200))
        invisParticles.Size = NumberSequence.new(0.3, 0)
        invisParticles.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(1, 1)
        })
        invisParticles.Name = "InvisibilityParticles"
    end
    
    -- Potion sound
    local potionSound = Instance.new("Sound", torso)
    potionSound.SoundId = "rbxassetid://241816017" -- Minecraft potion drink
    potionSound.Volume = 0.5
    potionSound:Play()
    debris:AddItem(potionSound, 2)
    
    -- Make character invisible
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 1
        end
        if part:IsA("Accessory") then
            part.Handle.Transparency = 1
        end
    end
    
    -- Face decal invisible
    local head = char:FindFirstChild("Head")
    if head then
        local face = head:FindFirstChild("face")
        if face then
            face.Transparency = 1
        end
    end
    
    -- Notification
    local notify = Instance.new("TextLabel", screenGui)
    notify.Size = UDim2.new(0, 350, 0, 60)
    notify.Position = UDim2.new(0.5, -175, 0.4, 0)
    notify.BackgroundTransparency = 0.3
    notify.BackgroundColor3 = Color3.new(0, 0, 0)
    notify.TextColor3 = Color3.fromRGB(150, 150, 200)
    notify.TextScaled = true
    notify.Text = "👻 INVISIBILITY POTION! 👻"
    notify.Font = Enum.Font.SourceSansBold
    
    task.delay(3, function() notify:Destroy() end)
    
    -- Restore after duration
    task.wait(duration or 20)
    
    if char and char.Parent then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0
            end
            if part:IsA("Accessory") then
                part.Handle.Transparency = 0
            end
        end
        
        if head then
            local face = head:FindFirstChild("face")
            if face then
                face.Transparency = 0
            end
        end
        
        if torso and torso:FindFirstChild("InvisibilityParticles") then
            torso.InvisibilityParticles:Destroy()
        end
    end
    
    isInvisible = false
end

-- NEW: Among Us transformation
local function transformIntoAmongUs(duration)
    local char = player.Character
    if not char or isAmongUs then return end
    
    isAmongUs = true
    local hum = char:FindFirstChild("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not hum or not rootPart then return end
    
    -- Hide body parts
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 1
        end
        if part:IsA("Accessory") then
            part.Handle.Transparency = 1
        end
    end
    
    -- Random crewmate color
    local amongUsColors = {
        Color3.fromRGB(197, 17, 17),   -- Red
        Color3.fromRGB(19, 46, 209),   -- Blue
        Color3.fromRGB(17, 127, 45),   -- Green
        Color3.fromRGB(238, 84, 187),  -- Pink
        Color3.fromRGB(240, 125, 13),  -- Orange
        Color3.fromRGB(246, 246, 87),  -- Yellow
        Color3.fromRGB(63, 71, 78),    -- Black
        Color3.fromRGB(215, 225, 241), -- White
        Color3.fromRGB(107, 47, 188),  -- Purple
        Color3.fromRGB(113, 73, 30)    -- Brown
    }
    
    local crewmateColor = amongUsColors[math.random(1, #amongUsColors)]
    
    -- Create Among Us body
    local amongUsBody = Instance.new("Part")
    amongUsBody.Name = "AmongUsBody"
    amongUsBody.Size = Vector3.new(3, 4, 2)
    amongUsBody.Color = crewmateColor
    amongUsBody.Material = Enum.Material.SmoothPlastic
    amongUsBody.CanCollide = true
    amongUsBody.Parent = char
    
    -- Weld to character
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = rootPart
    weld.Part1 = amongUsBody
    weld.Parent = amongUsBody
    
    -- Mesh for Among Us shape
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://5592539808" -- Among Us crewmate mesh
    mesh.Scale = Vector3.new(0.5, 0.5, 0.5)
    mesh.Parent = amongUsBody
    
    -- Visor (eye) part
    local visor = Instance.new("Part")
    visor.Size = Vector3.new(2, 1, 0.2)
    visor.Color = Color3.fromRGB(100, 200, 255)
    visor.Material = Enum.Material.Neon
    visor.CanCollide = false
    visor.Parent = char
    visor.Name = "AmongUsVisor"
    
    local visorWeld = Instance.new("WeldConstraint")
    visorWeld.Part0 = amongUsBody
    visorWeld.Part1 = visor
    visorWeld.Parent = visor
    
    -- Among Us sound
    local susSound = Instance.new("Sound", amongUsBody)
    susSound.SoundId = "rbxassetid://5700183626" -- Among Us role sound
    susSound.Volume = 0.6
    susSound:Play()
    debris:AddItem(susSound, 3)
    
    -- Walking sound effect
    local walkSound = Instance.new("Sound", amongUsBody)
    walkSound.SoundId = "rbxassetid://4813011827" -- Walking sound
    walkSound.Looped = true
    walkSound.Volume = 0.3
    walkSound.Name = "WalkSound"
    
    local walkConnection
    walkConnection = hum.Running:Connect(function(speed)
        if speed > 0 then
            if not walkSound.Playing then walkSound:Play() end
        else
            walkSound:Stop()
        end
    end)
    
    -- Notification
    local notify = Instance.new("TextLabel", screenGui)
    notify.Size = UDim2.new(0, 350, 0, 60)
    notify.Position = UDim2.new(0.5, -175, 0.4, 0)
    notify.BackgroundTransparency = 0.3
    notify.BackgroundColor3 = Color3.new(0, 0, 0)
    notify.TextColor3 = crewmateColor
    notify.TextScaled = true
    notify.Text = "🔪 SUS TRANSFORMATION! 🔪"
    notify.Font = Enum.Font.SourceSansBold
    
    task.delay(3, function() notify:Destroy() end)
    
    -- Slower speed (crewmate waddle)
    hum.WalkSpeed = 12
    
    -- Restore after duration
    task.wait(duration or 20)
    
    if amongUsBody.Parent then
        amongUsBody:Destroy()
    end
    if visor.Parent then
        visor:Destroy()
    end
    if walkConnection then
        walkConnection:Disconnect()
    end
    
    -- Restore character
    if char and char.Parent then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0
            end
            if part:IsA("Accessory") then
                part.Handle.Transparency = 0
            end
        end
    end
    
    if hum then
        hum.WalkSpeed = 16
    end
    
    isAmongUs = false
end

-- NEW: Forced Peppa Pig video
local function playPeppaPig(duration)
    if isPeppaPigActive then return end
    
    isPeppaPigActive = true
    
    -- Create fullscreen video frame
    local videoFrame = Instance.new("Frame")
    videoFrame.Name = "PeppaPigFrame"
    videoFrame.Size = UDim2.new(1, 0, 1, 0)
    videoFrame.Position = UDim2.new(0, 0, 0, 0)
    videoFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    videoFrame.BorderSizePixel = 0
    videoFrame.ZIndex = 10
    videoFrame.Parent = screenGui
    
    -- Video player
    local videoPlayer = Instance.new("VideoFrame")
    videoPlayer.Size = UDim2.new(1, 0, 1, 0)
    videoPlayer.Position = UDim2.new(0, 0, 0, 0)
    videoPlayer.BackgroundTransparency = 1
    videoPlayer.Video = "https://github.com/sfdgdrfsrf/curly-winner/raw/refs/heads/main/iShowSpeed%20in%20Peppa%20Pig.mp4"
    videoPlayer.Looped = true
    videoPlayer.Volume = 0.5
    videoPlayer.Parent = videoFrame
    videoPlayer:Play()
    
    -- Warning text
    local warningText = Instance.new("TextLabel")
    warningText.Size = UDim2.new(0, 400, 0, 80)
    warningText.Position = UDim2.new(0.5, -200, 0.1, 0)
    warningText.BackgroundTransparency = 0.5
    warningText.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    warningText.TextColor3 = Color3.new(1, 1, 1)
    warningText.TextScaled = true
    warningText.Text = "⚠️ CRINGE OVERLOAD ⚠️"
    warningText.Font = Enum.Font.SourceSansBold
    warningText.Parent = videoFrame
    
    -- Countdown timer
    local timerText = Instance.new("TextLabel")
    timerText.Size = UDim2.new(0, 200, 0, 50)
    timerText.Position = UDim2.new(0.5, -100, 0.85, 0)
    timerText.BackgroundTransparency = 0.5
    timerText.BackgroundColor3 = Color3.new(0, 0, 0)
    timerText.TextColor3 = Color3.new(1, 1, 1)
    timerText.TextScaled = true
    timerText.Font = Enum.Font.SourceSansBold
    timerText.Parent = videoFrame
    
    -- Countdown
    task.spawn(function()
        local timeLeft = duration or 15
        while timeLeft > 0 and videoFrame.Parent do
            timerText.Text = "Time Left: " .. math.floor(timeLeft) .. "s"
            task.wait(1)
            timeLeft = timeLeft - 1
        end
    end)
    
    -- Notification
    local notify = Instance.new("TextLabel", screenGui)
    notify.Size = UDim2.new(0, 400, 0, 60)
    notify.Position = UDim2.new(0.5, -200, 0.4, 0)
    notify.BackgroundTransparency = 0.3
    notify.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
    notify.TextColor3 = Color3.new(1, 1, 1)
    notify.TextScaled = true
    notify.Text = "🐷 PEPPA PIG CURSE! 🐷"
    notify.Font = Enum.Font.SourceSansBold
    notify.ZIndex = 11
    
    task.delay(3, function() notify:Destroy() end)
    
    -- Screen flash effect
    task.spawn(function()
        local flashCount = 0
        while isPeppaPigActive and videoFrame.Parent and flashCount < 10 do
            warningText.TextColor3 = Color3.new(1, math.random(), math.random())
            task.wait(0.2)
            flashCount = flashCount + 1
        end
    end)
    
    -- Remove after duration
    task.wait(duration or 15)
    
    if videoFrame.Parent then
        videoFrame:Destroy()
    end
    
    isPeppaPigActive = false
end

-- Cleanup function
local function clearAll()
    isAddicted = false
    drinksDone = 0
    isDrunk = false
    isSitting = false
    isSleeping = false
    nausea = 0
    hasVomited = false
    isCar = false
    hasWings = false
    isLevitating = false
    witchsBrewActive = false
    isInvisible = false
    isAmongUs = false
    isPeppaPigActive = false
    
    sitBtn.Visible = false
    sleepBtn.Visible = false
    vomitBtn.Visible = false
    nauseaFrame.Visible = false
    
    removeDrunkEffects()
    
    -- Remove car parts
    local char = player.Character
    if char then
        if char:FindFirstChild("CarBody") then char.CarBody:Destroy() end
        if char:FindFirstChild("LeftWing") then char.LeftWing:Destroy() end
        if char:FindFirstChild("RightWing") then char.RightWing:Destroy() end
        if char:FindFirstChild("WingGlow") then char.WingGlow:Destroy() end
        if char:FindFirstChild("AmongUsBody") then char.AmongUsBody:Destroy() end
        
        -- Restore head
        local head = char:FindFirstChild("Head")
        if head and originalHeadSize then
            head.Size = originalHeadSize
        end
        if head and originalHeadColor then
            head.Color = originalHeadColor
        end
        
        -- Restore visibility
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0
            end
            if part:IsA("Accessory") then
                part.Handle.Transparency = 0
            end
        end
    end
    
    -- Remove Peppa Pig GUI
    if screenGui:FindFirstChild("PeppaPigFrame") then
        screenGui.PeppaPigFrame:Destroy()
    end
    
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
end

player.CharacterAdded:Connect(clearAll)

-- Enhanced Zzz effect
local function spawnZzz()
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end
    
    local bb = Instance.new("BillboardGui", char.Head)
    bb.Size = UDim2.new(0, 50, 0, 50)
    bb.Adornee = char.Head
    bb.StudsOffset = Vector3.new(math.random(-1, 1) * 0.5, 2, 0)
    
    local lbl = Instance.new("TextLabel", bb)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Zzz"
    lbl.TextColor3 = Color3.fromRGB(200, 200, 255)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextStrokeTransparency = 0.5
    
    task.spawn(function()
        for i = 1, 40 do
            if not bb.Parent then break end
            bb.StudsOffset = bb.StudsOffset + Vector3.new(math.sin(i * 0.2) * 0.05, 0.1, 0.05)
            lbl.TextTransparency = i / 40
            lbl.TextStrokeTransparency = 0.5 + (i / 40) * 0.5
            task.wait(0.05)
        end
        bb:Destroy()
    end)
end

-- NEW: Heartbeat effect when addicted
local function createHeartbeatEffect()
    if not isAddicted then return end
    
    local beat = Instance.new("Sound", camera)
    beat.SoundId = "rbxassetid://535840393" -- Heartbeat sound
    beat.Volume = 0.3
    beat.Looped = true
    beat.Name = "HeartbeatSound"
    beat:Play()
    
    task.spawn(function()
        while isAddicted and beat.Parent do
            heartbeatCounter = heartbeatCounter + 1
            
            -- Pulse screen effect
            if camera:FindFirstChild("ColaColor") then
                local colorCorrect = camera.ColaColor
                local intensity = math.sin(heartbeatCounter * 0.1) * 0.2
                colorCorrect.Brightness = intensity * 0.1
            end
            
            -- Pulse blur
            if camera:FindFirstChild("ColaBlur") then
                camera.ColaBlur.Size = 5 + math.abs(math.sin(heartbeatCounter * 0.1)) * 3
            end
            
            task.wait(0.05)
        end
        beat:Destroy()
    end)
end

-- Sleep button
sleepBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if isDrunk and root then
        isSleeping = true
        char.Humanoid.PlatformStand = true
        root.CFrame = root.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(math.rad(90), 0, 0)
        root.Anchored = true
        
        -- Snoring sound
        local snore = Instance.new("Sound", char.Head)
        snore.SoundId = "rbxassetid://4841633633"
        snore.Volume = 0.4
        snore.Looped = true
        snore.Name = "SnoreSound"
        snore:Play()
        
        task.spawn(function()
            while isSleeping do
                spawnZzz()
                task.wait(1.5)
            end
        end)
        
        task.wait(10)
        
        isSleeping = false
        root.Anchored = false
        char.Humanoid.PlatformStand = false
        root.CFrame = root.CFrame * CFrame.new(0, 3, 0) * CFrame.Angles(math.rad(-90), 0, 0)
        isDrunk = false
        nausea = 0
        
        if snore then snore:Destroy() end
        
        sitBtn.Visible = false
        sleepBtn.Visible = false
        vomitBtn.Visible = false
        nauseaFrame.Visible = false
        removeDrunkEffects()
    end
end)

-- Sit button
sitBtn.MouseButton1Click:Connect(function()
    local hum = player.Character:FindFirstChild("Humanoid")
    if not isSitting then
        isSitting = true
        hum.Sit = true
        sitBtn.Text = "Unsit"
    else
        isSitting = false
        hum.Sit = false
        sitBtn.Text = "Sit"
    end
end)

-- NEW: Vomit button
vomitBtn.MouseButton1Click:Connect(function()
    if nausea >= 30 and not hasVomited then
        createVomit()
    end
end)

-- Tool activation
tool.Activated:Connect(function()
    local char = player.Character
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        -- Drinking animation
        task.spawn(function()
            local head = char:FindFirstChild("Head")
            local arm = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
            local grip = arm and arm:FindFirstChild("RightGrip")
            
            if grip then grip.Enabled = false end
            
            -- Drinking sound
            local drinkSound = Instance.new("Sound", handle)
            drinkSound.SoundId = "rbxassetid://10722059" -- Drinking sound
            drinkSound.Volume = 0.6
            drinkSound:Play()
            
            foam.Rate = 1000
            
            for i = 1, 45 do
                handle.CFrame = head.CFrame * CFrame.new(0, -0.2, -1) * CFrame.Angles(math.rad(90), 0, 0)
                runService.Heartbeat:Wait()
            end
            
            foam.Rate = 0
            drinkSound:Destroy()
            
            if grip then grip.Enabled = true end
        end)
        
        -- Speed boost
        hum.WalkSpeed = 40
        hum.JumpPower = 70
        hum.UseJumpPower = true
        
        drinksDone = drinksDone + 1
        lastDrinkTime = tick()
        
        -- Increase nausea
        nausea = math.min(100, nausea + math.random(15, 25))
        nauseaFrame.Visible = true
        
        -- Update nausea bar color
        if nausea < 40 then
            nauseaBar.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        elseif nausea < 70 then
            nauseaBar.BackgroundColor3 = Color3.fromRGB(200, 200, 50)
        else
            nauseaBar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        
        nauseaBar:TweenSize(UDim2.new(nausea / 100, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        
        -- RANDOM EFFECT SELECTION (weighted chances)
        local randomEffect = nil
        local effectRoll = math.random(1, 100)
        
        if effectRoll <= 10 then
            randomEffect = "car"
        elseif effectRoll <= 20 then
            randomEffect = "wings"
        elseif effectRoll <= 30 then
            randomEffect = "witchsbrew"
        elseif effectRoll <= 40 then
            randomEffect = "invisible"
        elseif effectRoll <= 50 then
            randomEffect = "amongus"
        elseif effectRoll <= 60 then
            randomEffect = "peppapig"
        elseif effectRoll <= 70 then
            randomEffect = "ragdoll"
        elseif effectRoll <= 80 and nausea >= 50 then
            randomEffect = "vomit"
        else
            randomEffect = "normal"
        end
        
        -- Apply selected effect
        if randomEffect == "car" then
            task.spawn(function()
                transformIntoCar(15)
            end)
        elseif randomEffect == "wings" then
            task.spawn(function()
                giveWings(20)
            end)
        elseif randomEffect == "witchsbrew" then
            task.spawn(function()
                applyWitchsBrew(20)
            end)
        elseif randomEffect == "invisible" then
            task.spawn(function()
                applyInvisibility(20)
            end)
        elseif randomEffect == "amongus" then
            task.spawn(function()
                transformIntoAmongUs(20)
            end)
        elseif randomEffect == "peppapig" then
            task.spawn(function()
                playPeppaPig(15)
            end)
        elseif randomEffect == "ragdoll" then
            task.delay(1, function()
                ragdollCharacter(3)
            end)
        elseif randomEffect == "vomit" then
            task.delay(math.random(1, 3), function()
                if not hasVomited then
                    createVomit()
                end
            end)
        end
        
        -- Drunk logic with enhanced chances
        local shouldGetDrunk = false
        if drinksDone == 3 then
            isAddicted = true
            shouldGetDrunk = true
            createHeartbeatEffect()
        elseif drinksDone >= 5 then
            shouldGetDrunk = math.random() <= 0.8 -- 80% chance
        elseif math.random() <= 0.5 then
            shouldGetDrunk = true
        end
        
        if shouldGetDrunk and not isDrunk then
            isDrunk = true
            sitBtn.Visible = true
            sleepBtn.Visible = true
            addDrunkEffects()
        end
        
        -- Show vomit button when nausea is high
        if nausea >= 30 then
            vomitBtn.Visible = true
        end
        
        -- Random auto-vomit if nausea too high (reduced since we have random effect)
        if nausea >= 80 and math.random() <= 0.2 and not hasVomited then
            task.delay(math.random(1, 3), function()
                createVomit()
            end)
        end
        
        -- Effects wear off
        task.delay(35, function()
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
            end
            
            if not isSleeping then
                isDrunk = false
                sitBtn.Visible = false
                sleepBtn.Visible = false
                
                if nausea < 30 then
                    vomitBtn.Visible = false
                end
                
                removeDrunkEffects()
            end
        end)
    end
end)

-- Death timer (60 sec when addicted)
task.spawn(function()
    while true do
        task.wait(1)
        if isAddicted and player.Character and player.Character.Humanoid.Health > 0 then
            if tick() - lastDrinkTime >= 60 then
                -- Dramatic death effect
                local char = player.Character
                local hum = char:FindFirstChild("Humanoid")
                
                -- Screen flash
                local flash = Instance.new("Frame", screenGui)
                flash.Size = UDim2.new(1, 0, 1, 0)
                flash.BackgroundColor3 = Color3.new(1, 0, 0)
                flash.BackgroundTransparency = 0.5
                flash.BorderSizePixel = 0
                
                tweenService:Create(flash, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
                
                task.wait(1)
                hum.Health = 0
                clearAll()
            end
        end
    end
end)

-- Random addiction phrases
task.spawn(function()
    while true do
        task.wait(math.random(5, 10))
        if isAddicted then
            local label = Instance.new("TextLabel", screenGui)
            label.Size = UDim2.new(0, 320, 0, 60)
            label.AnchorPoint = Vector2.new(0.5, 0.5)
            label.Position = UDim2.new(math.random(15, 85) / 100, 0, math.random(15, 80) / 100, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255, math.random(0, 50), 0)
            label.TextScaled = true
            label.Text = phrases[math.random(1, #phrases)]
            label.Font = Enum.Font.SourceSansBold
            label.TextStrokeTransparency = 0
            label.TextStrokeColor3 = Color3.new(0, 0, 0)
            label.Rotation = math.random(-15, 15)
            
            -- Pulse effect
            task.spawn(function()
                for i = 1, 15 do
                    label.TextSize = 20 + math.sin(i * 0.5) * 5
                    task.wait(0.1)
                end
            end)
            
            task.delay(3, function()
                tweenService:Create(label, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                task.wait(0.5)
                label:Destroy()
            end)
        end
    end
end)

-- Enhanced POV drunk camera
runService.RenderStepped:Connect(function()
    if isDrunk and not isSitting and not isSleeping then
        local t = tick()
        local intensity = 1
        
        -- Increase intensity based on drinks
        if drinksDone >= 5 then
            intensity = 2
        elseif drinksDone >= 8 then
            intensity = 3
        end
        
        camera.CFrame = camera.CFrame * CFrame.Angles(
            math.sin(t * 1.2) * 0.02 * intensity,
            math.cos(t * 1.0) * 0.02 * intensity,
            math.sin(t * 0.7) * 0.01 * intensity
        )
        
        -- Random head tilt when very drunk
        if drinksDone >= 6 and math.random() <= 0.01 then
            camera.CFrame = camera.CFrame * CFrame.Angles(0, 0, math.rad(math.random(-30, 30)))
        end
    end
end)

-- Nausea decay over time
task.spawn(function()
    while true do
        task.wait(2)
        if nausea > 0 and not isDrunk then
            nausea = math.max(0, nausea - 2)
            nauseaBar:TweenSize(UDim2.new(nausea / 100, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
            
            if nausea == 0 then
                nauseaFrame.Visible = false
                vomitBtn.Visible = false
            end
        end
    end
end)
