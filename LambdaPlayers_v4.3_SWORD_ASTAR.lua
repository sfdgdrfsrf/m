--[[
╔══════════════════════════════════════════════════════════════════╗
║  LAMBDA PLAYERS v4.3 (MULTI-GAME + IGOR + CRUCIBLE + A* ASTAR)  ║
║   Full port of the GMod Lambda Players / Zeta Players addon      ║
║   Features: Teams, Vehicles, Dynamic Difficulty, CollectionService║
║   NEW: Improved Emote System with Music & Custom Animations!     ║
║   NEW: Enhanced Admin System with Fun/Troll Commands!            ║
║   ─────────────────────────────────────────────────────────────  ║
║   SUPPORTED GAMES:                                               ║
║   • Generic / Auto-Detect                                        ║
║   • 99 Nights in Forest                                          ║
║   • Lucky Blocks Battlegrounds                                   ║
║   • Identity Fraud                                               ║
║   • Jailbreak                                                    ║
║   • Prison Life                                                  ║
║   ─────────────────────────────────────────────────────────────  ║
║   Drop into ServerScriptService — zero setup required            ║
╚══════════════════════════════════════════════════════════════════╝

  ADMIN COMMANDS:
    • :spawnzombie [player]    - Spawn zombies that infect players
    • :ban [player]            - Ban a player from the server
    • :kick [player]           - Kick a player from the server
    • :unban [player]          - Unban a player from the server
    • :patricksdoomshutdown [player] - Summon Patrick to consume a player
    • :rainbowtrail [player]   - Give a player a rainbow trail
    • :explode [player]        - Make a player explode
    • :reverse [player]        - Reverse a player's controls
    • :dance [player]          - Force a player to dance
    • :bighead [player]        - Make a player's head giant
    • :freeze [player]         - Freeze a player
    • :trap [player]           - Trap player in a cage
    • :slap [player]           - Slap a player
    • :confuse [player]        - Confuse a player
    • :rocket [player]         - Launch a player into the air
    • :spam [message]          - Spam a message in chat
    • :killallbots             - Kill all bots
    • :patrick                 - Summon Patrick on self
    NEW CLIENT-SIDE COMMANDS:
    • :tp [player]             - Teleport player to a random spot
    • :speed [player]          - Boost player speed to 100
    • :god [player]            - Give player infinite health
    • :heal [player]           - Fully heal a player
    • :fling [player]          - Fling a player into the sky
    • :smoke [player]          - Surround player in smoke
    • :fire [player]           - Set player on fire (visual)
    • :invisible [player]      - Turn player invisible
    • :blind [player]          - Black out a player's screen
    • :drunk [player]          - Make a player's screen wobbly
    • :tiny [player]           - Shrink a player to tiny size
    • :spin [player]           - Spin a player uncontrollably
    • :earthquake [player]     - Shake a player's screen violently
    • :trip [player]           - Force a player to trip/fall
    • :scare [player]          - Jumpscare a player
    • :jail [player]           - Trap player in a jail cell
    • :size [player]           - Randomly resize a player
    • :announce [message]      - Show a big announcement on screen
    • :bring [player]          - Teleport all players to target
    • :launch [player]         - Launch player sideways randomly
    • :orbit [player]          - Make player orbit their position
    • :chaos [player]          - Random combination of effects
    • :fly [player]            - Force player to fly around

  IGOR SYSTEM (chat commands, type in chat):
    • spawn_igor              - Spawn an Igor near you (client-side)
    • kill_igor / 0000        - Remove all your local Igors
    • igor_force_aggressive   - Force all your Igors hostile

  IGOR SYSTEM (admin bot commands):
    • :spawnigor [player]     - Spawn an Igor near a player
    • :killigor [player]      - Remove a player's Igors
    • :igoraggressive [player]- Force a player's Igors hostile

  MERGED FROM:
    • fixed_v4.2.lua          (Lambda Players v4.2 server script)
    • ArtificialIgor_Client.lua (client-sided Igor rig AI)
--]]

local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local TweenService       = game:GetService("TweenService")
local SoundService       = game:GetService("SoundService")
local StarterPack        = game:GetService("StarterPack")
local CollectionService  = game:GetService("CollectionService")
local ChatService        = game:GetService("Chat")
local Teams              = game:GetService("Teams")
local Workspace          = game:GetService("Workspace")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local HttpService        = game:GetService("HttpService")
local ServerStorage      = game:GetService("ServerStorage")

-- FORWARD DECLARATION: botSay must be declared here because banPlayer/kickPlayer/spawnZombie
-- (defined below) reference it. The actual definition is later in the file.
local botSay

-- Create RemoteEvent for client-side command execution
local AdminRemote = Instance.new("RemoteEvent")
AdminRemote.Name = "LambdaAdminCommand"
AdminRemote.Parent = ReplicatedStorage

-- Store banned players
local BannedPlayers = {}

-- Ban function
local function banPlayer(bot, targetPlayer, reason)
    reason = reason or "Violation of server rules"
    botSay(bot, "admin_scold", "!ban " .. targetPlayer.Name .. " " .. reason)
    BannedPlayers[targetPlayer.UserId] = {
        name = targetPlayer.Name,
        reason = reason,
        bannedBy = bot.name,
        time = os.time()
    }
    targetPlayer:Kick("You have been banned by " .. bot.name .. " for: " .. reason)
    botSay(bot, "admin_scold", "🔨 " .. targetPlayer.Name .. " has been banned!")
end

-- Kick function
local function kickPlayer(bot, targetPlayer, reason)
    reason = reason or "No reason specified"
    botSay(bot, "admin_scold", "!kick " .. targetPlayer.Name .. " " .. reason)
    targetPlayer:Kick("You have been kicked by " .. bot.name .. " for: " .. reason)
    botSay(bot, "admin_scold", "👢 " .. targetPlayer.Name .. " has been kicked!")
end

-- Spawn Zombie function (client-side execution)
local function spawnZombie(bot, targetPlayer)
    botSay(bot, "admin_scold", "!spawnzombie " .. targetPlayer.Name)
    local zombieScriptUrl = "https://raw.githubusercontent.com/ian49972/SCRIPTS/refs/heads/main/BRAINZ"
    AdminRemote:FireClient(targetPlayer, {
        command = "spawnzombie",
        url = zombieScriptUrl
    })
    botSay(bot, "admin_scold", "🧟 Zombies have been spawned on " .. targetPlayer.Name .. "!")
end

-- Client-side handler script (injected into each player)
local CLIENT_HANDLER_SCRIPT = [[
-- Lambda Players Client Handler
-- This script handles admin commands from bots

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Patrick's Doom Shutdown function
local function patricksDoomShutdown()
    local function isCharacterPart(obj)
        local model = obj:FindFirstAncestorWhichIsA("Model")
        return model and model:FindFirstChildOfClass("Humanoid") ~= nil
    end
    
    local Object = game:GetObjects("rbxassetid://12102103065")[1]
    if not Object then return end
    
    local patrick = nil
    local attractedParts = {}
    local maxAttracted = 40
    
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local info = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local targetPos = Character:GetPivot()
    
    patrick = Object.Patrick:Clone()
    if patrick and patrick.PatrickChar and patrick.PatrickChar.Giver and patrick.PatrickChar.Giver.Float and patrick.PatrickChar.Giver.Float.Patrick then
        patrick.PatrickChar.Giver.Float.Patrick.Value = patrick
    end
    patrick:PivotTo(Character:GetPivot() + Vector3.new(0, -176.4, 0))
    patrick.Parent = Workspace
    
    local originalTime = Lighting.TimeOfDay
    local originalAmbient = Lighting.Ambient
    local originalOutdoorAmbient = Lighting.OutdoorAmbient
    
    Lighting.TimeOfDay = 0
    Lighting.Ambient = Color3.fromRGB(0, 0, 0)
    Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    
    local Atmosphere = Lighting:FindFirstChildWhichIsA("Atmosphere")
    if Atmosphere then
        Atmosphere:Destroy()
    end
    
    Atmosphere = Instance.new("Atmosphere")
    Atmosphere.Parent = Lighting
    
    local tween = TweenService:Create(Atmosphere, info, {
        Haze = 10,
        Glare = .29,
        Color = Color3.fromRGB(53, 0, 1),
        Decay = Color3.fromRGB(92, 0, 2),
        Density = 0.449
    })
    
    local tween2 = TweenService:Create(patrick.PatrickChar, info, {
        CFrame = targetPos + Vector3.new(0, 76.4, 0)
    })
    
    tween:Play()
    tween2:Play()
    
    tween2.Completed:Connect(function()
        if patrick.PatrickChar and patrick.PatrickChar.Giver then
            patrick.PatrickChar.Giver.Disabled = false
        end
    end)
    
    local LaughSound = Object.Laughter:Clone()
    local Song = Object.SongOfHealing:Clone()
    
    LaughSound.Parent = game:GetService("SoundService")
    Song.Parent = game:GetService("SoundService")
    
    LaughSound:Play()
    Song:Play()
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GuiStuff"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Enabled = false
    ScreenGui.Parent = LocalPlayer.PlayerGui
    
    local Black = Instance.new("Frame")
    Black.Name = "Frame"
    Black.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Black.BackgroundTransparency = 1
    Black.Size = UDim2.new(1, 0, 1, 0)
    Black.Parent = ScreenGui
    
    local function onPartDestroyed(obj)
        if isCharacterPart(obj) and obj.Name == "HumanoidRootPart" and obj.Parent == LocalPlayer.Character then
            ScreenGui.Enabled = true
            local goal = {Transparency = 0}
            local tween = TweenService:Create(Black, TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.In), goal)
            tween:Play()
            task.wait(5)
            game.Players.LocalPlayer:Kick("You got eaten by Patrick!")
        end
    end
    
    coroutine.wrap(function()
        local suckCharacters = false
        task.delay(30, function()
            suckCharacters = true
        end)
        while patrick and patrick.Parent and #attractedParts < maxAttracted do
            task.wait(0.15)
            local candidates = {}
            local mouthPos = patrick.PatrickChar and patrick.PatrickChar.Mouth and patrick.PatrickChar.Mouth.Position
            if not mouthPos then continue end
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(patrick) and obj.Size.Magnitude < 20 and not table.find(attractedParts, obj) then
                    if isCharacterPart(obj) and not suckCharacters then continue end
                    local d = (obj.Position - mouthPos).Magnitude
                    if d < 60 then
                        table.insert(candidates, {obj = obj, dist = d})
                    end
                end
            end
            if #candidates > 0 then
                table.sort(candidates, function(a, b) return a.dist < b.dist end)
                local chosen = candidates[1].obj
                if not chosen.Anchored then chosen.Anchored = true end
                table.insert(attractedParts, chosen)
            end
        end
    end)()
    
    RunService.Heartbeat:Connect(function(dt)
        for i = #attractedParts, 1, -1 do
            local obj = attractedParts[i]
            if obj and obj.Parent and patrick and patrick.PatrickChar and patrick.PatrickChar.Mouth then
                local objectPos = patrick.PatrickChar.Mouth.Position
                local d = (obj.Position - objectPos).Magnitude
                if d > 2 then
                    local lerpAlpha = 0.2 * dt * (100 / d)
                    local newPos = obj.Position:Lerp(objectPos, lerpAlpha)
                    obj.CFrame = CFrame.new(newPos) * obj.CFrame.Rotation
                else
                    onPartDestroyed(obj)
                    obj:Destroy()
                    table.remove(attractedParts, i)
                end
            else
                table.remove(attractedParts, i)
            end
        end
    end)
    
    task.wait(60)
    if patrick then patrick:Destroy() end
    if LaughSound then LaughSound:Stop(); LaughSound:Destroy() end
    if Song then Song:Stop(); Song:Destroy() end
    if ScreenGui then ScreenGui:Destroy() end
    Lighting.TimeOfDay = originalTime
    Lighting.Ambient = originalAmbient
    Lighting.OutdoorAmbient = originalOutdoorAmbient
end

-- Zombie Spawn function (BRAINZ script)
local function spawnZombie()
    local success, err = pcall(function()
        local zombieScript = loadstring(game:HttpGet("https://raw.githubusercontent.com/ian49972/SCRIPTS/refs/heads/main/BRAINZ"))
        if zombieScript then
            zombieScript()
        end
    end)
    if not success then
        warn("Failed to load zombie script: " .. tostring(err))
    end
end

-- Rainbow Trail
local function rainbowTrail(duration)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local trail = Instance.new("Trail")
        trail.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))
        })
        trail.Lifetime = 0.8
        trail.Width = 0.5
        trail.Parent = char.HumanoidRootPart
        task.wait(duration or 15)
        trail:Destroy()
    end
end

-- Explode effect
local function explodeEffect()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local explosion = Instance.new("Explosion")
        explosion.BlastRadius = 10
        explosion.BlastPressure = 0
        explosion.Position = char.HumanoidRootPart.Position
        explosion.Parent = Workspace
        -- Explosion auto-cleans itself; do not Destroy() immediately or it cancels visuals
    end
end

-- Reverse controls
local function reverseControls(duration)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local originalSpeed = hum.WalkSpeed
            hum.WalkSpeed = -originalSpeed
            task.wait(duration or 8)
            if hum.Parent then
                hum.WalkSpeed = originalSpeed
            end
        end
    end
end

-- Dance
local function dance(duration)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Animator then
            local anim = Instance.new("Animation")
            local dances = {
                "rbxassetid://507771019",
                "rbxassetid://507776043",
                "rbxassetid://507777268"
            }
            anim.AnimationId = dances[math.random(1, #dances)]
            local track = hum.Animator:LoadAnimation(anim)
            track:Play()
            task.wait(duration or 10)
            track:Stop()
            track:Destroy()
            anim:Destroy()
        end
    end
end

-- Giant head
local function giantHead(duration)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Head") then
        local head = char.Head
        local originalSize = head.Size
        head.Size = head.Size * 2
        task.wait(duration or 10)
        if head.Parent then
            head.Size = originalSize
        end
    end
end

-- Freeze player
local function freeze(duration)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local originalSpeed = hum.WalkSpeed
            hum.WalkSpeed = 0
            local originalJump = hum.JumpPower
            hum.JumpPower = 0
            task.wait(duration or 5)
            if hum.Parent then
                hum.WalkSpeed = originalSpeed
                hum.JumpPower = originalJump
            end
        end
    end
end

-- Trap in cage
local function trap()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local cage = Instance.new("Model")
        cage.Name = "Cage"
        
        local bars = {}
        for i = 1, 8 do
            local bar = Instance.new("Part")
            bar.Size = Vector3.new(0.5, 8, 0.5)
            bar.Material = Enum.Material.Neon
            bar.Color = Color3.fromRGB(255, 100, 0)
            bar.Anchored = true
            bar.CanCollide = true
            local angle = (i / 8) * math.pi * 2
            bar.Position = hrp.Position + Vector3.new(math.cos(angle) * 3, 0, math.sin(angle) * 3)
            bar.Parent = cage
            table.insert(bars, bar)
        end
        
        local top = Instance.new("Part")
        top.Size = Vector3.new(6, 0.5, 6)
        top.Material = Enum.Material.Neon
        top.Color = Color3.fromRGB(255, 100, 0)
        top.Anchored = true
        top.Position = hrp.Position + Vector3.new(0, 4, 0)
        top.Parent = cage
        
        local bottom = Instance.new("Part")
        bottom.Size = Vector3.new(6, 0.5, 6)
        bottom.Material = Enum.Material.Neon
        bottom.Color = Color3.fromRGB(255, 100, 0)
        bottom.Anchored = true
        bottom.Position = hrp.Position + Vector3.new(0, -4, 0)
        bottom.Parent = cage
        
        cage.Parent = Workspace
        
        task.wait(10)
        cage:Destroy()
    end
end

-- Slap effect
local function slap()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then
        local head = char.Head
        local originalCF = head.CFrame
        local tween = TweenService:Create(head, TweenInfo.new(0.1), {CFrame = head.CFrame * CFrame.Angles(0, 0.5, 0)})
        tween:Play()
        tween.Completed:Wait()
        local tween2 = TweenService:Create(head, TweenInfo.new(0.1), {CFrame = originalCF})
        tween2:Play()
        
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9120380314"
        sound.Volume = 0.5
        sound.Parent = head
        sound:Play()
        task.wait(0.5)
        sound:Destroy()
    end
end

-- Confuse (screen shake)
local function confuse(duration)
    local originalCF = workspace.CurrentCamera.CFrame
    local startTime = tick()
    while tick() - startTime < (duration or 5) do
        workspace.CurrentCamera.CFrame = originalCF * CFrame.Angles(
            math.sin(tick() * 20) * 0.05,
            math.cos(tick() * 15) * 0.05,
            math.sin(tick() * 25) * 0.05
        )
        task.wait()
    end
    workspace.CurrentCamera.CFrame = originalCF
end

-- Rocket launch
local function rocket()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = true
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Velocity = Vector3.new(0, 150, 0)
            bodyVel.MaxForce = Vector3.new(0, 4000, 0)
            bodyVel.Parent = hrp
            
            local trail = Instance.new("Trail")
            trail.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0))
            trail.Lifetime = 0.5
            trail.Width = 1
            trail.Parent = hrp
            
            task.wait(3)
            bodyVel:Destroy()
            trail:Destroy()
            hum.PlatformStand = false
        end
    end
end

-- Teleport to random location
local function teleportRandom(duration)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        -- Anchor to prevent physics jank
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.Anchored = true end
        end
        local randomPos = hrp.Position + Vector3.new(math.random(-100,100), 0, math.random(-100,100))
        hrp.CFrame = CFrame.new(randomPos)
        task.wait(0.2)
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.Anchored = false end
        end
    end
end

-- Speed boost
local function speedBoost(duration)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local originalSpeed = hum.WalkSpeed
            hum.WalkSpeed = 100
            task.wait(duration or 10)
            if hum.Parent then hum.WalkSpeed = originalSpeed end
        end
    end
end

-- God mode (client-side visual + sets health high)
local function godMode(duration)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local origMax = hum.MaxHealth
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            -- Force field visual
            local ff = Instance.new("ForceField")
            ff.Name = "LambdaGodFF"
            ff.Parent = char
            task.wait(duration or 15)
            if hum.Parent then hum.MaxHealth = origMax; hum.Health = origMax end
            if ff and ff.Parent then ff:Destroy() end
        end
    end
end

-- Full heal
local function fullHeal()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = hum.MaxHealth end
    end
end

-- Fling player
local function fling()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(math.random(-300,300), 200, math.random(-300,300))
        bv.MaxForce = Vector3.new(1e6,1e6,1e6)
        bv.Parent = hrp
        local bav = Instance.new("BodyAngularVelocity")
        bav.AngularVelocity = Vector3.new(math.random(-20,20), math.random(-20,20), math.random(-20,20))
        bav.MaxTorque = Vector3.new(1e6,1e6,1e6)
        bav.Parent = hrp
        task.wait(2)
        bv:Destroy(); bav:Destroy()
        if hum then hum.PlatformStand = false end
    end
end

-- Smoke effect
local function smokeEffect(duration)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local smoke = Instance.new("Smoke")
        smoke.Color = Color3.fromRGB(80, 80, 80)
        smoke.Opacity = 0.5
        smoke.RiseVelocity = 5
        smoke.Size = 10
        smoke.Parent = hrp
        task.wait(duration or 8)
        if smoke and smoke.Parent then smoke:Destroy() end
    end
end

-- Fire effect (visual particles)
local function fireEffect(duration)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local fire = Instance.new("Fire")
        fire.Size = 5
        fire.Heat = 10
        fire.Parent = hrp
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 100, 0)
        light.Brightness = 3
        light.Range = 20
        light.Parent = hrp
        -- Damage ticks
        local hum = char:FindFirstChildOfClass("Humanoid")
        task.spawn(function()
            for _ = 1, math.floor((duration or 8) / 0.5) do
                task.wait(0.5)
                if hum and hum.Parent and fire and fire.Parent then
                    hum:TakeDamage(2)
                end
            end
        end)
        task.wait(duration or 8)
        if fire and fire.Parent then fire:Destroy() end
        if light and light.Parent then light:Destroy() end
    end
end

-- Invisible
local function invisible(duration)
    local char = LocalPlayer.Character
    if char then
        local parts = {}
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                table.insert(parts, {part = p, origTrans = p.Transparency})
                p.Transparency = 1
            end
        end
        local face = char:FindFirstChild("Head") and char.Head:FindFirstChildOfClass("Decal")
        if face then face.Transparency = 1 end
        task.wait(duration or 10)
        for _, entry in ipairs(parts) do
            if entry.part and entry.part.Parent then
                entry.part.Transparency = entry.origTrans
            end
        end
        if face and face.Parent then face.Transparency = 0 end
    end
end

-- Blind (blackout screen)
local function blind(duration)
    local gui = Instance.new("ScreenGui")
    gui.Name = "LambdaBlind"
    gui.IgnoreGuiInset = true
    gui.Parent = LocalPlayer.PlayerGui
    local black = Instance.new("Frame")
    black.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    black.BackgroundTransparency = 0
    black.Size = UDim2.new(1, 0, 1, 0)
    black.Parent = gui
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(0.6, 0, 0.1, 0)
    txt.Position = UDim2.new(0.2, 0, 0.45, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(255, 0, 0)
    txt.Text = "YOU ARE BLINDED"
    txt.Font = Enum.Font.GothamBold
    txt.TextScaled = true
    txt.Parent = black
    task.wait(duration or 8)
    gui:Destroy()
end

-- Drunk effect (wobbly camera)
local function drunkEffect(duration)
    local startTime = tick()
    local cam = Workspace.CurrentCamera
    while tick() - startTime < (duration or 10) do
        local t = tick()
        cam.CFrame = cam.CFrame * CFrame.Angles(
            math.sin(t * 3) * 0.02,
            math.cos(t * 2.5) * 0.04,
            math.sin(t * 4) * 0.015
        )
        task.wait()
    end
end

-- Tiny player
local function tinyPlayer(duration)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local originalScale = hum and hum:GetScale() or 1
        if hum then
            local desc = hum:GetAppliedDescription()
            desc.HeightScale = 0.3
            desc.WidthScale = 0.3
            desc.DepthScale = 0.3
            desc.HeadScale = 0.3
            hum:ApplyDescription(desc)
        end
        task.wait(duration or 10)
        if hum and hum.Parent then
            local desc2 = hum:GetAppliedDescription()
            desc2.HeightScale = originalScale
            desc2.WidthScale = originalScale
            desc2.DepthScale = originalScale
            desc2.HeadScale = originalScale
            hum:ApplyDescription(desc2)
        end
    end
end

-- Spin player
local function spinPlayer(duration)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local bav = Instance.new("BodyAngularVelocity")
        bav.AngularVelocity = Vector3.new(0, 50, 0)
        bav.MaxTorque = Vector3.new(0, 1e6, 0)
        bav.Parent = hrp
        task.wait(duration or 8)
        if bav and bav.Parent then bav:Destroy() end
    end
end

-- Earthquake (heavy screen shake)
local function earthquake(duration)
    local startTime = tick()
    local cam = Workspace.CurrentCamera
    while tick() - startTime < (duration or 6) do
        local intensity = 0.3
        cam.CFrame = cam.CFrame * CFrame.Angles(
            (math.random() - 0.5) * intensity,
            (math.random() - 0.5) * intensity,
            (math.random() - 0.5) * intensity * 0.5
        )
        task.wait(0.03)
    end
end

-- Trip player
local function tripPlayer()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = true
            task.wait(1.5)
            if hum.Parent then hum.PlatformStand = false end
        end
    end
end

-- Scare (jumpscare)
local function scarePlayer()
    local gui = Instance.new("ScreenGui")
    gui.Name = "LambdaScare"
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 100
    gui.Parent = LocalPlayer.PlayerGui
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    img.BackgroundTransparency = 0
    img.Parent = gui
    local scareText = Instance.new("TextLabel")
    scareText.Size = UDim2.new(1, 0, 0.4, 0)
    scareText.Position = UDim2.new(0, 0, 0.3, 0)
    scareText.BackgroundTransparency = 1
    scareText.TextColor3 = Color3.fromRGB(255, 0, 0)
    scareText.Text = "  BOO!!!"
    scareText.Font = Enum.Font.GothamBold
    scareText.TextScaled = true
    scareText.TextStrokeTransparency = 0
    scareText.Parent = img
    -- Scary sound
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9125404536"
    sound.Volume = 2
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    task.wait(2)
    gui:Destroy()
    sound:Stop()
    sound:Destroy()
end

-- Jail player
local function jailPlayer(duration)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local jail = Instance.new("Model")
        jail.Name = "LambdaJail"
        -- 4 walls
        local wallSize = Vector3.new(8, 12, 0.5)
        local positions = {
            hrp.Position + Vector3.new(4, 6, 0),
            hrp.Position + Vector3.new(-4, 6, 0),
            hrp.Position + Vector3.new(0, 6, 4),
            hrp.Position + Vector3.new(0, 6, -4),
        }
        local rotations = {0, 0, math.rad(90), math.rad(90)}
        for i = 1, 4 do
            local wall = Instance.new("Part")
            wall.Size = wallSize
            wall.Material = Enum.Material.CorrodedMetal
            wall.Color = Color3.fromRGB(60, 60, 60)
            wall.Anchored = true
            wall.CanCollide = true
            wall.CFrame = CFrame.new(positions[i]) * CFrame.Angles(0, rotations[i], 0)
            wall.Parent = jail
            -- Add bars visual
            for j = 1, 4 do
                local bar = Instance.new("Part")
                bar.Size = Vector3.new(0.3, 12, 0.3)
                bar.Material = Enum.Material.Neon
                bar.Color = Color3.fromRGB(200, 150, 50)
                bar.Anchored = true
                bar.CanCollide = true
                bar.CFrame = CFrame.new(
                    positions[i] + Vector3.new((j-2.5)*2, 0, 0)
                ) * CFrame.Angles(0, rotations[i], 0)
                bar.Parent = jail
            end
        end
        -- Roof
        local roof = Instance.new("Part")
        roof.Size = Vector3.new(8.5, 0.5, 8.5)
        roof.Material = Enum.Material.CorrodedMetal
        roof.Color = Color3.fromRGB(50, 50, 50)
        roof.Anchored = true
        roof.Position = hrp.Position + Vector3.new(0, 12, 0)
        roof.Parent = jail
        -- Floor
        local floor = Instance.new("Part")
        floor.Size = Vector3.new(8.5, 0.5, 8.5)
        floor.Material = Enum.Material.DiamondPlate
        floor.Color = Color3.fromRGB(100, 100, 100)
        floor.Anchored = true
        floor.Position = hrp.Position - Vector3.new(0, 0.5, 0)
        floor.Parent = jail
        jail.Parent = Workspace
        task.wait(duration or 15)
        jail:Destroy()
    end
end

-- Random size change
local function randomSize(duration)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local scales = {0.2, 0.5, 1.5, 2.5, 4, 0.1, 6}
            local scale = scales[math.random(1, #scales)]
            local desc = hum:GetAppliedDescription()
            desc.HeightScale = scale
            desc.WidthScale = scale
            desc.DepthScale = scale
            desc.HeadScale = scale
            hum:ApplyDescription(desc)
            task.wait(duration or 12)
            if hum and hum.Parent then
                local desc2 = hum:GetAppliedDescription()
                desc2.HeightScale = 1
                desc2.WidthScale = 1
                desc2.DepthScale = 1
                desc2.HeadScale = 1
                hum:ApplyDescription(desc2)
            end
        end
    end
end

-- Announce message on screen
local function announce(message, duration)
    message = message or "Lambda Players is watching you..."
    local gui = Instance.new("ScreenGui")
    gui.Name = "LambdaAnnounce"
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 99
    gui.Parent = LocalPlayer.PlayerGui
    -- Background
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0.7, 0, 0.15, 0)
    bg.Position = UDim2.new(0.15, 0, 0.02, 0)
    bg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    bg.BackgroundTransparency = 0.15
    bg.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = bg
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 100, 50)
    stroke.Thickness = 2
    stroke.Parent = bg
    -- Text
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(0.95, 0, 0.8, 0)
    txt.Position = UDim2.new(0.025, 0, 0.1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.Text = "  " .. message
    txt.Font = Enum.Font.GothamBold
    txt.TextScaled = true
    txt.TextWrapped = true
    txt.TextStrokeTransparency = 0.5
    txt.Parent = bg
    task.wait(duration or 8)
    gui:Destroy()
end

-- Bring all players to target (client-side: teleport self to target area)
local function bringToTarget()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local target = p.Character.HumanoidRootPart
            local offset = Vector3.new(math.random(-5,5), 0, math.random(-5,5))
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.Anchored = true end
            end
            char:PivotTo(CFrame.new(target.Position + offset))
            task.wait(0.1)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.Anchored = false end
            end
            break
        end
    end
end

-- Launch sideways
local function launchSideways()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end
        local angle = math.random(0, 360)
        local rad = math.rad(angle)
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(math.cos(rad)*200, 80, math.sin(rad)*200)
        bv.MaxForce = Vector3.new(1e6,1e6,1e6)
        bv.Parent = hrp
        task.wait(3)
        bv:Destroy()
        if hum then hum.PlatformStand = false end
    end
end

-- Orbit effect
local function orbitEffect(duration)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        local centerPos = hrp.Position
        local radius = 15
        local startTime = tick()
        if hum then hum.PlatformStand = true end
        while tick() - startTime < (duration or 8) do
            local t = (tick() - startTime) * 3
            local x = centerPos.X + math.cos(t) * radius
            local z = centerPos.Z + math.sin(t) * radius
            hrp.CFrame = CFrame.new(x, centerPos.Y + 5, z)
            task.wait(0.03)
        end
        if hum then hum.PlatformStand = false end
    end
end

-- Chaos (random combo of effects)
local function chaosEffect(duration)
    local effects = {fling, teleportRandom, spinPlayer, tripPlayer, earthquake, launchSideways, orbitEffect, flyEffect}
    local startT = tick()
    while tick() - startT < (duration or 15) do
        local fx = effects[math.random(1, #effects)]
        pcall(fx)
        task.wait(math.random(2, 4))
    end
end

-- Fly effect (launches player upward then fly around randomly)
local function flyEffect(duration)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = true
            -- Phase 1: Launch straight up
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 80, 0)
            bv.MaxForce = Vector3.new(0, 1e6, 0)
            bv.Parent = hrp
            task.wait(3)
            -- Phase 2: Fly around randomly
            local startTime = tick()
            while tick() - startTime < (duration or 8) do
                local angle = math.random(0, 360)
                local rad = math.rad(angle)
                bv.Velocity = Vector3.new(math.cos(rad)*40, 20, math.sin(rad)*40)
                task.wait(1.5)
            end
            -- Phase 3: Drop
            bv:Destroy()
            task.wait(0.5)
            if hum.Parent then hum.PlatformStand = false end
        end
    end
end

-- Command handler
local function handleCommand(data)
    local cmd = data.command
    local duration = data.duration or 10
    local message = data.message or ""
    
    if cmd == "patricksdoomshutdown" then
        patricksDoomShutdown()
    elseif cmd == "spawnzombie" then
        spawnZombie()
    elseif cmd == "rainbowtrail" then
        rainbowTrail(duration)
    elseif cmd == "explode" then
        explodeEffect()
    elseif cmd == "reverse" then
        reverseControls(duration)
    elseif cmd == "dance" then
        dance(duration)
    elseif cmd == "bighead" then
        giantHead(duration)
    elseif cmd == "freeze" then
        freeze(duration)
    elseif cmd == "trap" then
        trap()
    elseif cmd == "slap" then
        slap()
    elseif cmd == "confuse" then
        confuse(duration)
    elseif cmd == "rocket" then
        rocket()
    elseif cmd == "tp" then
        teleportRandom(duration)
    elseif cmd == "speed" then
        speedBoost(duration)
    elseif cmd == "god" then
        godMode(duration)
    elseif cmd == "heal" then
        fullHeal()
    elseif cmd == "fling" then
        fling()
    elseif cmd == "smoke" then
        smokeEffect(duration)
    elseif cmd == "fire" then
        fireEffect(duration)
    elseif cmd == "invisible" then
        invisible(duration)
    elseif cmd == "blind" then
        blind(duration)
    elseif cmd == "drunk" then
        drunkEffect(duration)
    elseif cmd == "tiny" then
        tinyPlayer(duration)
    elseif cmd == "spin" then
        spinPlayer(duration)
    elseif cmd == "earthquake" then
        earthquake(duration)
    elseif cmd == "trip" then
        tripPlayer()
    elseif cmd == "scare" then
        scarePlayer()
    elseif cmd == "jail" then
        jailPlayer(duration)
    elseif cmd == "size" then
        randomSize(duration)
    elseif cmd == "announce" then
        announce(message, duration)
    elseif cmd == "bring" then
        bringToTarget()
    elseif cmd == "launch" then
        launchSideways()
    elseif cmd == "orbit" then
        orbitEffect(duration)
    elseif cmd == "chaos" then
        chaosEffect(duration)
    elseif cmd == "spawnigor" then
        IgorSystem.spawnIgor()
    elseif cmd == "killigor" then
        IgorSystem.killAllIgor()
    elseif cmd == "igoraggressive" then
        IgorSystem.forceAggressive()
    end
end

-- Listen for remote events
local remote = game:GetService("ReplicatedStorage"):FindFirstChild("LambdaAdminCommand")
if remote then
    remote.OnClientEvent:Connect(handleCommand)

-- ====================================================================
-- ARTIFICIAL IGOR SYSTEM (merged from ArtificialIgor_Client.lua)
-- ====================================================================
-- Client-sided Igor rigs. Each player can spawn their own local Igors
-- via chat commands. Other players won't see them unless they run this
-- script too (which they will, since this handler is injected into
-- every player's PlayerScripts by the server).
-- Chat commands:
--   spawn_igor            -> spawns an Igor near you
--   kill_igor / 0000      -> removes all your local Igors
--   igor_force_aggressive -> forces all your Igors hostile
-- ====================================================================

local PathfindingService = game:GetService("PathfindingService")

local ACTIVE_IGORS = {}
local MEMORY = {} -- [igorModel] = { trust = number, heardLines = {}, state = "Idle" }

----------------------------------------------------------------
-- BUILD THE RIG
----------------------------------------------------------------
local function buildIgorRig(spawnCFrame)
    local model = Instance.new("Model")
    model.Name = "ArtificialIgor"

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(2, 2, 1)
    root.Transparency = 1
    root.CanCollide = false
    root.CFrame = spawnCFrame
    root.Parent = model

    local torso = Instance.new("Part")
    torso.Name = "Torso"
    torso.Size = Vector3.new(2, 2, 1)
    torso.BrickColor = BrickColor.new("Really black")
    torso.CFrame = spawnCFrame
    torso.Parent = model

    local head = Instance.new("Part")
    head.Name = "Head"
    head.Shape = Enum.PartType.Ball
    head.Size = Vector3.new(1.4, 1.4, 1.4)
    head.BrickColor = BrickColor.new("Pastel brown")
    head.CFrame = spawnCFrame * CFrame.new(0, 1.7, 0)
    head.Parent = model

    local neckWeld = Instance.new("WeldConstraint")
    neckWeld.Part0 = torso
    neckWeld.Part1 = head
    neckWeld.Parent = torso

    local rootWeld = Instance.new("WeldConstraint")
    rootWeld.Part0 = root
    rootWeld.Part1 = torso
    rootWeld.Parent = root

    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = model

    model.PrimaryPart = root
    model.Parent = Workspace

    return model
end

----------------------------------------------------------------
-- STATE: IDLE / WANDER
----------------------------------------------------------------
local function wander(igor)
    local root = igor.PrimaryPart
    if not root then return end

    local target = root.Position + Vector3.new(math.random(-20, 20), 0, math.random(-20, 20))
    local path = PathfindingService:CreatePath()

    local ok = pcall(function()
        path:ComputeAsync(root.Position, target)
    end)

    if ok and path.Status == Enum.PathStatus.Success then
        for _, waypoint in ipairs(path:GetWaypoints()) do
            if MEMORY[igor] and MEMORY[igor].state ~= "Idle" then break end
            local goal = waypoint.Position
            local dir = (goal - igor.PrimaryPart.Position)
            igor.PrimaryPart.CFrame = igor.PrimaryPart.CFrame:Lerp(
                CFrame.new(igor.PrimaryPart.Position + dir.Unit * math.min(dir.Magnitude, 4), goal),
                0.5
            )
            task.wait(0.3)
        end
    end
end

----------------------------------------------------------------
-- STATE: BUILDING (stacks nearby loose parts)
----------------------------------------------------------------
local function buildWithProps(igor)
    local root = igor.PrimaryPart
    if not root then return end

    local nearbyParts = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored and obj.Parent ~= igor then
            if (obj.Position - root.Position).Magnitude < 15 then
                table.insert(nearbyParts, obj)
            end
        end
    end

    for i, part in ipairs(nearbyParts) do
        if i > 5 then break end
        part.CFrame = root.CFrame * CFrame.new(0, i * (part.Size.Y + 0.1), -3)
        task.wait(0.4)
    end
end

----------------------------------------------------------------
-- STATE: FEAR (checks if boxed in, tries to escape)
----------------------------------------------------------------
local function isBoxedIn(igor)
    local root = igor.PrimaryPart
    if not root then return false end

    local directions = {Vector3.new(1,0,0), Vector3.new(-1,0,0), Vector3.new(0,0,1), Vector3.new(0,0,-1)}
    local blocked = 0

    for _, dir in ipairs(directions) do
        local rayResult = Workspace:Raycast(root.Position, dir * 5)
        if rayResult then
            blocked += 1
        end
    end

    return blocked >= 4
end

----------------------------------------------------------------
-- STATE: AGGRESSIVE (targets nearest character)
----------------------------------------------------------------
local function goAggressive(igor)
    local root = igor.PrimaryPart
    if not root then return end

    local nearestDist = math.huge
    local nearestChar = nil

    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char and char.PrimaryPart then
            local dist = (char.PrimaryPart.Position - root.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestChar = char
            end
        end
    end

    if nearestChar then
        local dir = (nearestChar.PrimaryPart.Position - root.Position)
        igor.PrimaryPart.CFrame = igor.PrimaryPart.CFrame:Lerp(
            CFrame.new(root.Position + dir.Unit * math.min(dir.Magnitude, 4), nearestChar.PrimaryPart.Position),
            0.5
        )
    end
end

----------------------------------------------------------------
-- MAIN BEHAVIOR LOOP PER IGOR
----------------------------------------------------------------
local function runIgorAI(igor)
    MEMORY[igor] = { trust = 0, heardLines = {}, state = "Idle" }

    task.spawn(function()
        while igor.Parent do
            local mem = MEMORY[igor]
            if not mem then break end

            if isBoxedIn(igor) then
                mem.state = "Fear"
            end

            if mem.state == "Idle" then
                wander(igor)
            elseif mem.state == "Building" then
                buildWithProps(igor)
                mem.state = "Idle"
            elseif mem.state == "Aggressive" then
                goAggressive(igor)
            elseif mem.state == "Fear" then
                wander(igor) -- flee behavior reuses wander to move away
                mem.state = "Idle"
            end

            -- randomly decide to build sometimes
            if mem.state == "Idle" and math.random(1, 20) == 1 then
                mem.state = "Building"
            end

            task.wait(1)
        end
        MEMORY[igor] = nil
    end)
end

----------------------------------------------------------------
-- PUBLIC API (used by both chat commands and remote admin commands)
----------------------------------------------------------------
local IgorSystem = {}

function IgorSystem.spawnIgor()
    local char = LocalPlayer.Character
    if char and char.PrimaryPart then
        local spawnCFrame = char.PrimaryPart.CFrame * CFrame.new(0, 0, -5)
        local igor = buildIgorRig(spawnCFrame)
        table.insert(ACTIVE_IGORS, igor)
        runIgorAI(igor)
        return true
    end
    return false
end

function IgorSystem.killAllIgor()
    for _, igor in ipairs(ACTIVE_IGORS) do
        if igor and igor.Parent then
            igor:Destroy()
        end
    end
    ACTIVE_IGORS = {}
end

function IgorSystem.forceAggressive()
    for _, igor in ipairs(ACTIVE_IGORS) do
        if MEMORY[igor] then
            MEMORY[igor].state = "Aggressive"
        end
    end
end

----------------------------------------------------------------
-- CHAT COMMAND HANDLING (client-side, local player's own chat)
----------------------------------------------------------------
LocalPlayer.Chatted:Connect(function(message)
    local lower = message:lower()

    if lower == "spawn_igor" then
        IgorSystem.spawnIgor()
    elseif lower == "kill_igor" or message == "0000" then
        IgorSystem.killAllIgor()
    elseif lower == "igor_force_aggressive" then
        IgorSystem.forceAggressive()
    else
        -- "remember" chat lines for flavor - Igor can "say" them later
        for _, igor in ipairs(ACTIVE_IGORS) do
            if MEMORY[igor] then
                table.insert(MEMORY[igor].heardLines, message)
            end
        end
    end
end)

-- ====================================================================
-- END ARTIFICIAL IGOR SYSTEM
-- ====================================================================

end
]]

-- Inject client handler into every player
local function setupClientHandler(player)
    local handler = player:FindFirstChild("PlayerScripts"):FindFirstChild("LambdaClientHandler")
    if not handler then
        local script = Instance.new("LocalScript")
        script.Name = "LambdaClientHandler"
        script.Source = CLIENT_HANDLER_SCRIPT
        script.Parent = player:FindFirstChild("PlayerScripts") or player
    end
end

Players.PlayerAdded:Connect(setupClientHandler)
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function() setupClientHandler(player) end)
end

-- Check for banned players on join
Players.PlayerAdded:Connect(function(player)
    if BannedPlayers[player.UserId] then
        local banInfo = BannedPlayers[player.UserId]
        player:Kick("You are banned from this server.\nReason: " .. banInfo.reason .. "\nBanned by: " .. banInfo.bannedBy)
    end
end)

-- ══════════════════════════════════════════════════════════════
--  CONFIG  ── tweak anything here
-- ══════════════════════════════════════════════════════════════
local CONFIG = {
    -- ── GAME MODE ──────────────────────────────────────────────
    GAME_MODE               = "auto",

    -- Population
    MAX_BOTS                = 10,
    BOT_RESPAWN_DELAY       = 5,
    DISCONNECT_REJOIN_MIN   = 30,
    DISCONNECT_REJOIN_MAX   = 120,
    DISCONNECT_CHANCE       = 0.03,

    -- Movement & Physics
    WALK_SPEED              = 14,
    RUN_SPEED               = 24,
    WANDER_RADIUS           = 100,
    JUMP_CHANCE             = 0.05,
    PATHFINDING_TIMEOUT     = 1.5,
    USE_COLLECTION_SERVICE  = true,

    -- AI Behavior
    IDLE_MIN                = 5,
    IDLE_MAX                = 20,
    SIT_MIN                 = 10,
    SIT_MAX                 = 40,
    PANIC_DURATION          = 6,
    SPECTATE_DURATION       = 12,
    CHAT_INTERVAL_MIN       = 15,
    CHAT_INTERVAL_MAX       = 40,
    CONVO_CHANCE            = 0.25,
    CONVO_REPLY_DELAY_MIN   = 1.5,
    CONVO_REPLY_DELAY_MAX   = 4.0,
    CONVO_MAX_EXCHANGES     = 4,

    -- Personalities (Base Values)
    BASE_AGGRESSION         = 0.4,
    BASE_SOCIABILITY        = 0.5,
    BASE_COWARDICE          = 0.3,
    BASE_CURIOSITY          = 0.5,
    BASE_LAZINESS           = 0.35,

    -- Combat
    ATTACK_RANGE            = 8,
    RETREAT_HP_PERCENT      = 0.30,
    MELEE_COOLDOWN          = 0.8,
    DAMAGE_PER_HIT          = 15,
    RANGE_DAMAGE_MULTIPLIER = 0.8,
    DYNAMIC_DIFFICULTY      = true,

    -- Visuals & Audio
    SHOW_NAMEPLATE          = true,
    SHOW_STATUS_ICON        = true,
    ANNOUNCE_JOINS          = true,
    VC_ENABLED              = true,
    VC_VOLUME               = 0.3,
    VC_SOUND_IDS            = {
        "rbxassetid://107757585348762","rbxassetid://111323022883852","rbxassetid://137972499209693",
        "rbxassetid://140510675673683","rbxassetid://92678759917617","rbxassetid://111505333061182",
        "rbxassetid://135332782780175","rbxassetid://8472121264","rbxassetid://6463201877",
        "rbxassetid://90958571328958","rbxassetid://97141912717173","rbxassetid://135632330263329",
    },

    -- Interactions
    TOOL_PICKUP_ENABLED     = true,
    TOOL_USE_CHANCE         = 0.30,
    TOOL_DROP_CHANCE        = 0.15,
    -- ── CRUCIBLE SWORD (new in v4.3) ─────────────────────────
    SWORD_ENABLED           = true,
    SWORD_CHANCE            = 0.20,   -- chance a bot spawns with the Crucible
    SWORD_AUTO_ATTACK_RANGE = 12,     -- studs; bot swings when enemy in range
    SWORD_ATTACK_COOLDOWN   = 1.0,    -- seconds between swings
    SWORD_COMBO_RESET_TIME  = 1.5,    -- seconds of inactivity before combo resets to 1
    SWORD_GIB_ON_KILL       = true,   -- one-shot kill (matches original hacerPapilla)

    -- ── CUSTOM A* PATHFINDER (new in v4.3) ──────────────────────
    USE_CUSTOM_ASTAR        = true,   -- false = fall back to PathfindingService
    ASTAR_VOXEL_SIZE        = 4,      -- voxel edge length in studs
    ASTAR_MAX_ITERATIONS    = 6000,   -- A* loop cap (prevents CPU spikes)
    ASTAR_MAX_NODES         = 800,    -- closed-set cap
    ASTAR_CACHE_TTL         = 30,     -- seconds; voxel walkability cache lifetime
    VEHICLE_ENTER_CHANCE    = 0.40,
    KILLBIND_ENABLED        = true,
    KILLBIND_STUCK_TIME     = 10,
    KILLBIND_STUCK_DIST     = 1.0,

    -- Systems
    RIG_TYPE_OVERRIDE       = "auto",
    ADMIN_CHANCE            = 0.10,
    FRIEND_FORM_CHANCE      = 0.25,
    SPRINT_CHANCE           = 0.50,
    ENABLE_TEAMS            = true,
    ENABLE_ECONOMY_SIM      = true,

    -- Emote System
    EMOTE_ENABLED           = true,
    EMOTE_MUSIC_ENABLED     = true,
    EMOTE_MUSIC_VOLUME      = 0.5,
    EMOTE_MUSIC_IDS         = {
        "rbxassetid://1839246711",
        "rbxassetid://5342472551",
        "rbxassetid://1840193493",
        "rbxassetid://13076028291",
    },
    EMOTE_DURATION_MIN      = 8,
    EMOTE_DURATION_MAX      = 25,
    EMOTE_DANCE_CHANCE      = 0.08,
    EMOTE_SYNC_CHANCE       = 0.35,
}

-- ══════════════════════════════════════════════════════════════
--  GAME MODE DETECTION & RESOLUTION
-- ══════════════════════════════════════════════════════════════
local DETECTED_GAME = "generic"

local GAME_SIGNATURES = {
    ["99nights"]      = {"NightManager","ForestHorror","Campfire","ForestCreature","NightsRemaining"},
    ["luckyblocks"]   = {"LuckyBlock","LuckyBlockManager","LuckyBlockBreak"},
    ["identityfraud"] = {"MazeManager","IdentityFraud","MazePart","StageManager","Backrooms"},
    ["jailbreak"]     = {"CopsAndRobbers","BankManager","JailbreakGameManager","ArrestBrick"},
    ["prisonlife"]    = {"PrisonDoor","GuardTeam","PrisonerTeam","PrisonWall"},
}

local function detectGameMode()
    if CONFIG.GAME_MODE ~= "auto" then return CONFIG.GAME_MODE end
    local gameName = string.lower(game.Name or "")
    if gameName:find("night") and gameName:find("forest") then return "99nights" end
    if gameName:find("lucky") and gameName:find("block") then return "luckyblocks" end
    if gameName:find("identity") then return "identityfraud" end
    if gameName:find("jailbreak") then return "jailbreak" end
    if gameName:find("prison") then return "prisonlife" end
    for gameId, tags in pairs(GAME_SIGNATURES) do
        for _, tag in ipairs(tags) do
            if Workspace:FindFirstChild(tag, true) then return gameId end
        end
    end
    return "generic"
end

-- ══════════════════════════════════════════════════════════════
--  GAME-SPECIFIC CONFIGS
-- ══════════════════════════════════════════════════════════════
local GAME_CONFIG_OVERRIDES = {
    ["99nights"] = {
        BASE_AGGRESSION   = 0.2, BASE_COWARDICE = 0.7, BASE_SOCIABILITY = 0.8,
        PANIC_DURATION    = 12, WANDER_RADIUS = 40, RUN_SPEED = 28, MAX_BOTS = 8,
    },
    ["luckyblocks"] = {
        BASE_AGGRESSION   = 0.7, BASE_CURIOSITY = 0.9, WANDER_RADIUS = 120,
        ATTACK_RANGE      = 12, DAMAGE_PER_HIT = 20, MAX_BOTS = 12,
    },
    ["identityfraud"] = {
        BASE_COWARDICE    = 0.85, BASE_AGGRESSION = 0.1, WALK_SPEED = 12,
        RUN_SPEED         = 22, PANIC_DURATION = 15, WANDER_RADIUS = 60,
        MAX_BOTS          = 8, VEHICLE_ENTER_CHANCE = 0.0,
    },
    ["jailbreak"] = {
        BASE_AGGRESSION   = 0.6, ATTACK_RANGE = 15, DAMAGE_PER_HIT = 18,
        VEHICLE_ENTER_CHANCE = 0.60, RUN_SPEED = 26, MAX_BOTS = 12, ENABLE_TEAMS = true,
    },
    ["prisonlife"] = {
        BASE_AGGRESSION   = 0.55, ATTACK_RANGE = 10, VEHICLE_ENTER_CHANCE = 0.30,
        WANDER_RADIUS     = 80, MAX_BOTS = 10, ENABLE_TEAMS = true,
    },
}

-- ══════════════════════════════════════════════════════════════
--  ASSETS & DATA
-- ══════════════════════════════════════════════════════════════
local BOT_NAMES = {
    "xX_N00bSlayer_Xx","CoolDude2009","ProGamer_lol","RobloxLegend99",
    "ShadowBlade47","StarPlayer_","NoobDestroyer","GamerKing2008",
    "BlazeFire22","DarkHunter_X","PixelPro101","SpeedRunner64",
    "EpicBuilder_YT","SkillMaster99","QuickScope77","TurboPlayer",
    "NightWolf_X","AceGamer47","LegendaryUser","BrickBuilder",
    "ClutchKing_","SwiftNinja_","ChaosLord99","RbxWarrior",
    "HyperDash_X","FrostByte22","GlitchHunter","MegaChamp_",
    "StormRider_RBX","ViperStrike64","CrystalBlade","OmegaPlayer99",
    "ZeroToHero_","BlazeRun2012","EliteSniper_","CodeBreaker_X",
    "PvpPro_","BuildMaster_","SkyWalker_RBX","IronForge22",
    "NeonGhost_","TimberWolf99","ArcLight_X","CritHit_",
    "QuantumLeap_","ObsidianKing","FlameThrower_","VoidWalker_X",
    "TacticalBro_","AquaFire_99","PhantomRider_","CyberLynx22",
    "ToxicNinja_","RealDeal_RBX","NotABot_lol","Totally_Human",
    "def_not_a_bot","xJustinx_","coolcat2010","gamertime_now",
}

-- ══════════════════════════════════════════════════════════════
--  BASE CHAT POOLS
-- ══════════════════════════════════════════════════════════════
local CHAT = {
    idle = {"lol","lmao","gg","ez","nice","noob","wait what","bruh","no way","actually insane","this game is so good","i love roblox","anyone wanna team?","where is everyone","this map is huge","bro i just spawned","my ping is so bad rn","lagging like crazy","YOOOO","nah fr?","based","W","skill issue","get good","fr fr no cap","on god","sheesh","LETS GOOO","anyone know any good games?","add me pls","im bored","this server is dead","yo this is actually funny","bro i'm crying rn","how do you do that","i've been playing for 3 hours","my mum says dinner is ready brb","ngl this slaps","this reminds me of the old days","can someone help me","...","ok","what","hm","nah","yeah","maybe","idk","true","facts","same","wait","hold on"},
    kill = {"EZ","get rekt lol","lmaooo you're so bad","thanks for the free kill","skill issue bestie","L + ratio + didn't ask","GG no RE","you actually fell for that??","too easy","did you even play before today","OMFG YES","LETS GO LETS GO LETS GO","that's for earlier >:)","i've been waiting for that","BOOM"},
    death = {"WHAT","no way bro","HOW","that was so unfair wtf","report him","literally hacking","ok that hurt","i demand a rematch","camping is so lame omg","ugh i hate this game","bro i had full hp","that lag killed me 100%","ok i'm actually done","uno more game","i quit","whatever"},
    taunt = {"1v1 me rn","you cant beat me lol","i'm literally unbeatable","come at me","you scared?","what's wrong","try me","bet you can't even touch me","hahaha"},
    laugh = {"LMAOOO","HAHAHA","bro actually fell","cry about it","that was so funny omg","lololol","i can't","dead","not me dying laughing rn"},
    witness = {"yo did you see that","BRUH","wtf just happened","rip","F in the chat","bro got deleted","that was so brutal ngl","oof","damn...","o7"},
    panic = {"HELP","OMG OMG OMG","RUNNN","SOMEONE HELP ME","WHY IS THIS HAPPENING","AHHHHH","i don't wanna die","PLEASE","no no no no no"},
    assist = {"we got em","good teamwork","clutch","W partner","that's how we do it"},
    fall = {"ow","that hurt a lot","i did not mean to do that","welp","that was a bad idea lol"},
    admin_scold = {"hey stop that","bro i'm watching you","one more time and you're getting reported","read the rules please","this isn't allowed here","don't make me get a mod","seriously?"},
    convo_question = {"yo what's your favourite game?","how long have you been playing roblox?","do you have robux?","what's the best game on roblox right now?","you play any other games?","bro what even is your username","have you played blox fruits?","what's your ping rn?","are you in a group?","do you use mobile or pc?"},
    convo_respond = {"oh that's actually cool","no way really?","same honestly","bro that's wild","i feel that","never heard of it","yeah i get that","that makes sense","lmao okay","nah fr?","wait actually?","interesting...","ok boomer","based tbh"},
    disconnect = {"gtg bye guys","brb dinner","my mum is calling me","i gotta go touch grass","bye everyone","getting off for tonight","see you all later","got hw to do rip","ugh lag is unplayable gtg","k bye","peace out","later nerds"},
    rejoin = {"i'm back","ok i'm back lol","sorry had to eat","reconnected ugh","server looks good again","hi again everyone","missed me?","k i'm online again"},
    sit = {"taking a little break","my legs are tired","just chilling rn","afk for a sec","just watching rn","vibing"},
    dance = {"dance time","ok i'm dancing now","this song goes hard","you can't stop me","best song ever fr","let's dance!","vibing to this","this beat is fire","dance dance dance","move your body","rhythm gaming irl","busting a move","feeling the groove","this is my jam","get up and dance","watch me go","epic dance moves incoming","who needs a dance floor","music mode activated","custom dance unlocked"},
    emote = {"look at me go","check this out","/e dance","try this emote","cool emote right","this emote is sick","my signature move","wait for it...","style points","pro emote skills"},
    vehicle = {"vroom vroom","need a ride","hoping in","car go brrr","nice ride"},
    economy = {"free money","collecting cash","rich soon","grinding","look at my stats"},
}

-- ══════════════════════════════════════════════════════════════
--  GAME-SPECIFIC CHAT POOLS
-- ══════════════════════════════════════════════════════════════
local GAME_CHAT = {
    ["99nights"] = {
        idle = {"did you hear that","stay close to the fire","how many nights left","i don't like this forest","is it morning yet","what was that sound","don't go in there","stick together guys","i swear something moved","why did we come here","this place is creepy af","bro it's so dark","how many nights have we survived","almost made it through the night","i need a torch","don't wander off alone","i hear footsteps","ok who left the fire","the trees are moving","i feel like we're being watched","shhh be quiet","10 nights left right?","almost dawn","we should set up camp","i haven't slept in days","one more night","i'm so scared rn"},
        panic = {"IT'S COMING RUN","SOMETHING IS IN THE TREES","GO GO GO","DON'T LOOK BEHIND YOU","RUN TO THE FIRE","HELP IT'S CHASING ME","IT'S THE MONSTER","STICK TOGETHER","AAAHHHH GET AWAY","I CAN HEAR IT BREATHING","SPRINT","NOOO"},
        taunt = {"you can't scare me","bring it on","come out wherever you are","i'm not afraid"},
        death = {"IT GOT ME","i knew this would happen","should've stayed by the fire","darkness wins again","bro i was so close to dawn"},
        witness = {"F in the chat","RIP","it got them","they were too far from camp","never split up guys","that's what happens when you wander"},
        assist = {"i'll protect you","stay behind me","together we survive","i got your back"},
        vehicle = {},
        economy = {"found some supplies","grabbed the lantern","got wood for the fire","collecting resources"},
        convo_question = {"how many nights have you survived","do you have a torch","where should we camp tonight","did you see the monster","what strategy works best"},
        convo_respond = {"yeah the fire helps","i always stay in the center","never solo at night","good call","same i nearly died last round"},
        sit = {"resting by the fire","waiting for dawn","too tired to move","warming up","not moving till sunrise"},
        game_unique = {"survive the night","dawn is coming","keep the fire burning","light saves lives","never leave camp alone","it hunts in the dark"},
        scare = {"...did you see that??","wait...","shh","something's there","i see eyes in the dark","back to camp NOW"},
    },
    ["luckyblocks"] = {
        idle = {"where are the lucky blocks","found a lucky block!","loot is mid but ok","THIS IS THE BEST LOOT","bro i got trash loot","how do i get better gear","i need more blocks","this lucky block was unlucky lol","op loot incoming","just got scammed by a lucky block","someone is hoarding all the blocks","finally found a sword","this game is actually so fun","who has the best gear rn","found diamonds let's gooo","my loot is so bad","okay who took all the blocks","i literally got a wooden sword from that","bro this lucky block gave me nothing"},
        kill = {"L take that","you should've had better loot","my gear carried hard","get rekt noob","skill + loot = me winning","you never stood a chance"},
        death = {"my loot was just bad","who gave them OP gear","that sword is literally broken","hacker 100%","bro i had no armor","i demand a loot reset"},
        taunt = {"my loot is way better than yours","come fight me with your trash sword","you can't touch me with this kit","loot diff, not skill diff"},
        panic = {"SOMEONE HAS OP LOOT RUN","THEY HAVE A LEGENDARY HELP","RETREAT","i have no armor and they have diamonds"},
        witness = {"bro just got one shot","legendary weapon spotted","that gear is broken","F for them","imagine dying with that loot"},
        vehicle = {},
        economy = {"breaking lucky blocks","collecting gear","saving up good drops","hunting for the rare drop","this loot meta is wild"},
        convo_question = {"what's the best lucky block loot","how do you get legendary gear","ever gotten the jackpot drop","which weapon tier is best","do you stack kills or farm blocks"},
        convo_respond = {"the sword is broken no cap","yeah legendary beats everything","i always rush blocks first","loot is rng what can i say","honestly same strategy"},
        sit = {"catching my breath","saving my gear","waiting for the respawn rush","low hp need a sec"},
        game_unique = {"lucky block!","breaking all the blocks","jackpot incoming","cursed drop again","rare loot spotted","block diff","loot diff"},
        break_block = {"opening this one","wish me luck","this better be good","jackpot jackpot jackpot","oh please be legendary","breaking it!"},
    },
    ["identityfraud"] = {
        idle = {"which way do i go","this maze is impossible","i've been lost for 10 minutes","bro WHERE is the exit","i keep going in circles","stay away from the imposters","trust no one","is that a player or an npc","don't follow strangers","there's something wrong with that character","the halls never end","i can hear footsteps but no one's here","every door looks the same","this map is terrifying","don't split up","almost at the next stage","i think i found a safe room","shh something's behind us","what stage is this","how many stages are left","ok stage 3 already insane"},
        panic = {"IT'S AN IMPOSTER RUN","DON'T TRUST IT","THE MONSTER IS HERE","WRONG WAY GO BACK","HELP IT'S FOLLOWING ME","RUN FAST","SOMEONE HELP","THAT'S NOT A REAL PLAYER","IT'S CHASING ME DOWN THE HALL","DEAD END DEAD END"},
        death = {"the imposter got me","i trusted the wrong person","i picked the wrong door","bro i was so close to the end","it just appeared from nowhere","my fps dropped and i died"},
        taunt = {},
        witness = {"someone just got caught","did you see that creature","something grabbed them","they chose wrong","F","that jumpscare never gets old"},
        assist = {"follow me i know the way","this way is safe","i'll lead","stay behind me","i found the exit"},
        vehicle = {},
        economy = {},
        sit = {"too scared to move","hiding in the corner","waiting for it to pass","i refuse to go first","someone else go"},
        convo_question = {"do you know the way out","which door is safe","how far are you","did you see an imposter","what stage are you on"},
        convo_respond = {"i have no idea honestly","i just follow others","stage 2 i think","yeah it nearly got me","same direction maybe"},
        disconnect = {"i can't do this anymore gtg","this is too scary bye","leaving before the jumpscare gets me","peace i'm traumatized"},
        game_unique = {"trust no one","the maze shifts","something is wrong here","i don't recognize this hallway","this wasn't here before","wrong turn again"},
        suspicious = {"wait...that's not right","something feels off","bro that NPC just looked at me","why is it standing like that","run if you see it stop moving"},
    },
    ["jailbreak"] = {
        idle = {"anyone wanna rob the bank","cops are everywhere","just escaped prison","need a getaway car","the bank vault is open","who's doing the jewelry store","i need a keycard","cruising through the city","helicopter spotted overhead","cop chasing me rn","just got arrested again","anyone got a donut for the cops lol","free donuts fr","speed limits are suggestions","doing the cargo train","someone help with the museum","my bounty is maxed","running from 3 cops right now","this police car is fast","just finished a heist","putting the cash in the bank","grinding heists all day"},
        kill = {"hands up","you're under arrest lol","perp down","nobody escapes me","too slow criminal"},
        death = {"I WAS SO CLOSE TO THE EXIT","they spiked my tires","the cops had backup","my getaway driver abandoned me","should've used the helicopter"},
        taunt = {"you'll never catch me","catch me if you can officer","i'm too fast for the law","jailbreak speedrun any%"},
        panic = {"COPS INCOMING ABORT MISSION","HELICOPTER ABOVE US RUN","ROADBLOCK AHEAD","SPIKE STRIP","THEY BLOCKED THE EXIT"},
        witness = {"bro just got spiked","that was a clean arrest","they really had a helicopter for that","F for them","classic jailbreak moment"},
        vehicle = {"jumping in the lambo","cops can't catch this car","need that keycard for the chopper","vroom vroom officer","best getaway vehicle"},
        economy = {"depositing cash","stacking heist money","buying a gun upgrade","need more cash for the car","grinding all the heists"},
        assist = {"cover me i'm grabbing the cash","need a driver","distract the cops","hold them off","i'll take the vault"},
        sit = {"lying low for a bit","waiting for heat to die down","chilling in the base","planning the next heist"},
        convo_question = {"cop or robber?","what's your bounty","best car in the game right now","ever done the bank solo","how do you escape the helicopter"},
        convo_respond = {"always robber","my bounty is insane","the lambo is unmatched","yeah solo bank is risky","helicopter is the only way out"},
        game_unique = {"the vault is open!","helicopter escape let's go","bounty hunter spotted","police pursuit","starting the heist","this is the best game on roblox","keycard acquired","great escape","cops and robbers fr"},
        heist = {"bank job time","hitting the jewelry store","cargo train incoming","museum heist let's go","this is the big score"},
        arrest = {"freeze!","hands up criminal","you're coming with me","license and registration","code 3 in pursuit"},
    },
    ["prisonlife"] = {
        idle = {"anyone wanna escape","guard's patrol route is predictable","i need a weapon","met in the yard","solitary again smh","just got out of cuffs","the warden is on patrol","do not get caught","escape tunnel in progress","who has the gun","bro they arrested me for nothing","guard shift is changing","the gate is open for 3 seconds","i know a way out","riot incoming","disguise as a guard? yes or no","this prison is too easy to escape","first day in and i'm already planning escape","perimeter patrol is weak","anyone else in the yard","i need backup for this","teamwork is the only way out"},
        kill = {"inmate down","back in your cell","crime doesn't pay","you won't escape today","guard wins again"},
        death = {"THEY SHOT ME","corrupt guards smh","didn't even do anything","this is prison brutality","getting a lawyer"},
        taunt = {"you'll never catch me","enjoy your cell","freedom is just ahead","guards can't stop us all"},
        panic = {"GUARD WITH A GUN RUN","LOCKDOWN INITIATED","ABORT THE ESCAPE","GUARDS EVERYWHERE","CODE RED IN THE YARD"},
        witness = {"bro just got arrested","they didn't make it","F for them","that guard was waiting the whole time","never trust the yard exit"},
        vehicle = {"stealing the guard car","prison bus escape","helicopter on the roof","taking the keys","drive drive drive"},
        economy = {"collecting contraband","found some supplies","grabbed a keycard","looting the armory","saving up for an escape"},
        assist = {"i'll distract the guards","create a diversion","cover the exit","this way to freedom","follow me"},
        sit = {"doing time","just sitting in the yard","waiting for shift change","keeping a low profile","acting normal"},
        convo_question = {"cop or prisoner?","you got a weapon","what's the best escape route","ever made it out","how long is your sentence"},
        convo_respond = {"always prisoner","check the armory","through the fence usually","yeah once but got recaptured","100 years lmao"},
        game_unique = {"prisoner for life","the yard is dangerous","guards patrol every 30 seconds","this prison is no joke","freedom!","breakout time","code orange","lockdown mode","contraband found","escape plan alpha"},
        escape_plan = {"through the sewer","over the wall","bribe the guard","steal a uniform","tunnel under the east wing","wait for the riot"},
        guard_talk = {"prisoner approaching","stay in line","no contraband allowed","back to your cell","watch yourself inmate"},
    },
}

-- ══════════════════════════════════════════════════════════════
--  GAME-SPECIFIC ROLE SYSTEM
-- ══════════════════════════════════════════════════════════════
local GAME_ROLES = {
    ["jailbreak"]  = {"Criminal","Police"},
    ["prisonlife"] = {"Prisoner","Guard"},
    ["99nights"]   = {"Survivor"},
    ["luckyblocks"]= {"Fighter"},
    ["identityfraud"] = {"Explorer"},
    ["generic"]    = {"Player"},
}

local function assignRole(gameMode)
    local roles = GAME_ROLES[gameMode] or GAME_ROLES["generic"]
    return roles[math.random(1, #roles)]
end

local function getRoleColor(role)
    local colors = {
        Criminal  = Color3.fromRGB(220, 50,  50 ),
        Police    = Color3.fromRGB(50,  100, 220),
        Prisoner  = Color3.fromRGB(255, 165, 0  ),
        Guard     = Color3.fromRGB(0,   180, 80 ),
        Survivor  = Color3.fromRGB(180, 100, 0  ),
        Fighter   = Color3.fromRGB(200, 50,  200),
        Explorer  = Color3.fromRGB(100, 200, 220),
        Player    = Color3.fromRGB(200, 200, 200),
    }
    return colors[role] or Color3.new(1,1,1)
end

-- ══════════════════════════════════════════════════════════════
--  GAME-SPECIFIC OBJECTIVES
-- ══════════════════════════════════════════════════════════════
local function getGameObjective(bot, gameMode)
    local hrp = bot.character and bot.character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    if gameMode == "jailbreak" then
        if bot.role == "Criminal" then
            local targets = {"Bank","Vault","JewelryStore","MuseumDoor","Train"}
            for _, name in ipairs(targets) do
                local obj = Workspace:FindFirstChild(name, true)
                if obj and obj:IsA("BasePart") then return obj.Position end
            end
        elseif bot.role == "Police" then
            local spawn = Workspace:FindFirstChild("PoliceBase", true) or Workspace:FindFirstChild("Police", true)
            if spawn then return spawn.Position + Vector3.new(math.random(-20,20), 0, math.random(-20,20)) end
        end
    end

    if gameMode == "prisonlife" then
        if bot.role == "Prisoner" then
            local exits = {"Gate","Fence","Exit","EscapeRoute"}
            for _, name in ipairs(exits) do
                local obj = Workspace:FindFirstChild(name, true)
                if obj and obj:IsA("BasePart") then return obj.Position end
            end
        elseif bot.role == "Guard" then
            local patrol = Workspace:FindFirstChild("Yard", true) or Workspace:FindFirstChild("Prison", true)
            if patrol then return patrol.Position + Vector3.new(math.random(-15,15), 0, math.random(-15,15)) end
        end
    end

    if gameMode == "99nights" then
        local campfire = Workspace:FindFirstChild("Campfire", true) or Workspace:FindFirstChild("Camp", true)
        if campfire and campfire:IsA("BasePart") then
            return campfire.Position + Vector3.new(math.random(-10,10), 0, math.random(-10,10))
        end
    end

    if gameMode == "luckyblocks" then
        local block = Workspace:FindFirstChild("LuckyBlock", true)
        if block and block:IsA("BasePart") then return block.Position end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("lucky") or obj.Name:lower():find("block")) then
                if obj.BrickColor == BrickColor.new("Bright yellow") then
                    return obj.Position
                end
            end
        end
    end

    if gameMode == "identityfraud" then
        local door = Workspace:FindFirstChild("Door", true) or Workspace:FindFirstChild("Exit", true) or Workspace:FindFirstChild("Stage", true)
        if door and door:IsA("BasePart") then return door.Position end
    end

    return nil
end

-- ══════════════════════════════════════════════════════════════
--  MERGED CHAT RESOLVER
-- ══════════════════════════════════════════════════════════════
local ActiveGameChat = CHAT

local function buildMergedChat(gameMode)
    local merged = {}
    local gamePools = GAME_CHAT[gameMode] or {}
    for cat, lines in pairs(CHAT) do
        merged[cat] = {}
        for _, l in ipairs(lines) do merged[cat][#merged[cat]+1] = l end
        if gamePools[cat] then
            for _, l in ipairs(gamePools[cat]) do merged[cat][#merged[cat]+1] = l end
        end
    end
    for cat, lines in pairs(gamePools) do
        if not merged[cat] then merged[cat] = lines end
    end
    return merged
end

-- ══════════════════════════════════════════════════════════════
--  STATUS ICONS
-- ══════════════════════════════════════════════════════════════
local STATUS_ICONS = {
    Wander      = "[Walking]",   Idle       = "[Idle]",        Combat   = "[Fighting]",
    Follow      = "[Following]", Retreat    = "[Retreating]",  Inspect  = "[Inspecting]",
    Interact    = "[Interacting]",Sit       = "[Sitting]",     Dance    = "[Dancing]",
    Panic       = "[PANICKING]", Spectate   = "[Watching]",    Admin    = "[Admin]",
    Friend      = "[Socialising]",Disconnect= "[Disconnected]",Vehicle  = "[Driving]",
    Objective   = "[On Mission]",Heist      = "[Heisting]",    Patrol   = "[Patrolling]",
    Escape      = "[Escaping]",  Hiding     = "[Hiding]",      Hunting  = "[Hunting Blocks]",
    Scouting    = "[Scouting]",  Surviving  = "[Surviving]",   Solving  = "[Solving Maze]",
}

local Bots      = {}
local UsedNames = {}
local nextBotId = 0
local CachedInteractables = {}
local LastPathfindTime = 0
local PlayerStatsCache = {}

-- FORWARD DECLARATIONS
local walkTo
local getSpawnCF
local spawnBot
-- NOTE: botSay is forward-declared near the top of the file (before banPlayer/kickPlayer)

-- ══════════════════════════════════════════════════════════════
--  UTILITIES
-- ══════════════════════════════════════════════════════════════
local function randFloat(a,b)  return a + math.random()*(b-a) end
local function randInt(a,b)    return math.random(a,b) end
local function randSign()      return math.random(2)==1 and 1 or -1 end
local function clamp(v,a,b)    return math.max(a,math.min(b,v)) end
local function dist(a,b)       return (a-b).Magnitude end

local function randPersonality()
    local function vary(base) return clamp(base + randFloat(-0.25,0.25),0,1) end
    return {
        aggression  = vary(CONFIG.BASE_AGGRESSION), sociability = vary(CONFIG.BASE_SOCIABILITY),
        cowardice   = vary(CONFIG.BASE_COWARDICE),  curiosity   = vary(CONFIG.BASE_CURIOSITY),
        laziness    = vary(CONFIG.BASE_LAZINESS),
    }
end

local function getRandomName()
    for _ = 1,200 do
        local n = BOT_NAMES[randInt(1,#BOT_NAMES)]
        if not UsedNames[n] then UsedNames[n]=true; return n end
    end
    return "Player"..randInt(1000,9999)
end

local function chatLine(cat)
    local pool = ActiveGameChat[cat]
    if not pool or #pool==0 then
        pool = CHAT[cat]
        if not pool or #pool==0 then return "..." end
    end
    return pool[randInt(1,#pool)]
end

botSay = function(bot, cat, override)
    local msg = override or chatLine(cat)
    if not bot.character then return end
    local head = bot.character:FindFirstChild("Head")
    if not head then return end
    if ChatService then
        pcall(function() ChatService:Chat(head, msg, Enum.ChatColor.White) end)
    else
        local bg = head:FindFirstChild("ChatBubble")
        if not bg then
            bg = Instance.new("BillboardGui")
            bg.Name = "ChatBubble"; bg.Size = UDim2.new(0,200,0,50)
            bg.StudsOffset = Vector3.new(0,3,0); bg.Adornee = head
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.new(1,1,1); lbl.TextStrokeTransparency = 0
            lbl.TextScaled = true; lbl.Parent = bg; bg.Parent = head
        end
        local lbl = bg:FindFirstChild("TextLabel")
        if lbl then
            lbl.Text = msg
            task.delay(3, function() if lbl then lbl.Text = "" end end)
        end
    end
end

local function getRoot(char)   return char and char:FindFirstChild("HumanoidRootPart") end
local function getHum(char)    return char and char:FindFirstChildOfClass("Humanoid") end

local function nearbyBots(pos, radius, exclude)
    local t = {}
    for _,b in pairs(Bots) do
        if b~=exclude and b.alive and b.character then
            local r = getRoot(b.character)
            if r and dist(r.Position,pos)<=radius then t[#t+1]=b end
        end
    end
    return t
end

local function nearbyRealPlayers(pos, radius)
    local t = {}
    for _,p in ipairs(Players:GetPlayers()) do
        local c = p.Character
        if c then
            local r = getRoot(c)
            if r and dist(r.Position,pos)<=radius then t[#t+1]=p end
        end
    end
    return t
end

local function randomWanderTarget(origin)
    local a = randFloat(0, math.pi*2)
    local r = randFloat(10, CONFIG.WANDER_RADIUS)
    return origin + Vector3.new(math.cos(a)*r, 0, math.sin(a)*r)
end

-- ══════════════════════════════════════════════════════════════
--  OPTIMIZED INTERACTABLE SCANNER
-- ══════════════════════════════════════════════════════════════
local function updateInteractableCache()
    CachedInteractables = {}
    if CONFIG.USE_COLLECTION_SERVICE then
        local tagged = CollectionService:GetTagged("LambdaInteract")
        for _, obj in ipairs(tagged) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                table.insert(CachedInteractables, obj)
            end
        end
    else
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") or obj:IsA("Seat") or obj:IsA("VehicleSeat") then
                table.insert(CachedInteractables, obj)
            end
        end
    end
end
task.spawn(function()
    while true do updateInteractableCache(); task.wait(30) end
end)

-- ══════════════════════════════════════════════════════════════
--  RIG TYPE DETECTION
-- ══════════════════════════════════════════════════════════════
local GAME_RIG_TYPE = "unknown"
local function detectRigType()
    if CONFIG.RIG_TYPE_OVERRIDE ~= "auto" then return CONFIG.RIG_TYPE_OVERRIDE end
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char then
            if char:FindFirstChild("UpperTorso") then return "R15" end
            if char:FindFirstChild("Torso") then return "R6" end
        end
    end
    local sc = game:GetService("StarterPlayer"):FindFirstChild("StarterCharacter")
    if sc then
        if sc:FindFirstChild("UpperTorso") then return "R15" end
        if sc:FindFirstChild("Torso") then return "R6" end
    end
    return "R6"
end
task.spawn(function()
    local tries = 0
    while GAME_RIG_TYPE == "unknown" and tries < 30 do
        GAME_RIG_TYPE = detectRigType()
        if GAME_RIG_TYPE == "unknown" then task.wait(1) end
        tries += 1
    end
    if GAME_RIG_TYPE == "unknown" then GAME_RIG_TYPE = "R6" end
end)

-- ══════════════════════════════════════════════════════════════
--  CHARACTER BUILDER
-- ══════════════════════════════════════════════════════════════
local FALLBACK_USER_IDS = {1,156,261,1211,2207687,55549140,57508472,6916278,122896297,80528689}
local CharacterCache = {}

local function buildCharacter(name)
    local userId
    local plrs = Players:GetPlayers()
    if #plrs > 0 then userId = plrs[math.random(1,#plrs)].UserId
    else userId = FALLBACK_USER_IDS[math.random(1,#FALLBACK_USER_IDS)] end
    local char = CharacterCache[userId]
    if not char or not char.Parent then
        local ok, model = pcall(function() return Players:CreateHumanoidModelFromUserId(userId) end)
        if ok and model then char = model; CharacterCache[userId] = char end
    end
    if not char then
        char = Instance.new("Model"); char.Name = name
        local hrp = Instance.new("Part"); hrp.Name="HumanoidRootPart"; hrp.Size=Vector3.new(2,2,1); hrp.Transparency=1; hrp.CanCollide=false; hrp.Parent=char
        char.PrimaryPart = hrp
        local hum = Instance.new("Humanoid"); hum.Parent = char
        local animator = Instance.new("Animator"); animator.Parent = hum
        return char, hum, hrp, nil, animator, "R6"
    end
    char = char:Clone(); char.Name = name
    local hum      = char:FindFirstChildOfClass("Humanoid")
    local hrp      = char:FindFirstChild("HumanoidRootPart")
    local head     = char:FindFirstChild("Head")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if hrp then char.PrimaryPart = hrp end
    if hum and not animator then animator = Instance.new("Animator"); animator.Parent = hum end
    if hum then
        hum.MaxHealth=100; hum.Health=100; hum.WalkSpeed=CONFIG.WALK_SPEED; hum.JumpPower=50
        hum.DisplayName=name; hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
        hum.HealthDisplayType=Enum.HumanoidHealthDisplayType.AlwaysOff
    end
    local rigType = char:FindFirstChild("UpperTorso") and "R15" or "R6"
    if GAME_RIG_TYPE == "unknown" then GAME_RIG_TYPE = rigType end
    return char, hum, hrp, head, animator, rigType
end

-- ══════════════════════════════════════════════════════════════
--  ANIMATION SYSTEM
-- ══════════════════════════════════════════════════════════════
local ANIM_IDS = {
    R6  = { idle="rbxassetid://180435571", walk="rbxassetid://180426354", jump="rbxassetid://125750702", fall="rbxassetid://180436148", climb="rbxassetid://180436334", sit="rbxassetid://178130996" },
    R15 = { idle="rbxassetid://507766388", walk="rbxassetid://507777826", jump="rbxassetid://507765000", fall="rbxassetid://507767968", climb="rbxassetid://507765644", sit="rbxassetid://2506281703" },
}

local function bindAnimations(char, hum, animator, rigType)
    local ids = ANIM_IDS[rigType] or ANIM_IDS.R6
    local animObjects = {}
    for animName, animId in pairs(ids) do
        local anim = Instance.new("Animation"); anim.AnimationId = animId; animObjects[animName] = anim
    end
    local currentAnim, currentAnimTrack = "", nil
    local function stopAll()
        if currentAnimTrack then pcall(function() currentAnimTrack:Stop(); currentAnimTrack:Destroy() end); currentAnimTrack = nil end
    end
    local function playAnim(name)
        if name == currentAnim then return end
        stopAll(); currentAnim = name
        if not animObjects[name] then return end
        pcall(function() currentAnimTrack = animator:LoadAnimation(animObjects[name]); currentAnimTrack:Play() end)
    end
    hum.Running:Connect(function(speed) if speed > 0.2 then playAnim("walk") else playAnim("idle") end end)
    hum.Jumping:Connect(function() playAnim("jump") end)
    hum.FreeFalling:Connect(function() playAnim("fall") end)
    hum.Seated:Connect(function() stopAll(); playAnim("sit") end)
    hum.Died:Connect(function() stopAll(); currentAnim = "" end)
    playAnim("idle")
    return stopAll
end

-- ══════════════════════════════════════════════════════════════
--  VOICE CHAT SIMULATION
-- ══════════════════════════════════════════════════════════════
local function attachVoiceSound(head)
    if not CONFIG.VC_ENABLED or not head then return nil end
    local sound = Instance.new("Sound")
    sound.Name="LambdaVC"; sound.RollOffMode=Enum.RollOffMode.Linear; sound.RollOffMaxDistance=40
    sound.Volume=CONFIG.VC_VOLUME; sound.Looped=true
    sound.SoundId=CONFIG.VC_SOUND_IDS[math.random(1,#CONFIG.VC_SOUND_IDS)]; sound.Parent=head
    task.spawn(function()
        while sound and sound.Parent do
            task.wait(randFloat(6,20))
            if not sound or not sound.Parent then break end
            sound:Play(); task.wait(randFloat(1.5,4))
            if not sound or not sound.Parent then break end
            sound:Stop()
        end
    end)
    return sound
end

-- ══════════════════════════════════════════════════════════════
--  TOOL & VEHICLE SYSTEM
-- ══════════════════════════════════════════════════════════════
local function getAvailableTools()
    local tools = {}
    for _, item in ipairs(StarterPack:GetChildren()) do if item:IsA("Tool") then tools[#tools+1]=item end end
    for _, item in ipairs(Workspace:GetChildren()) do if item:IsA("Tool") then tools[#tools+1]=item end end
    return tools
end

local function equipTool(bot, tool)
    if not bot.character or not tool then return false end
    local hum = getHum(bot.character)
    if not hum then return false end
    local clone = tool:Clone(); clone.Parent = bot.character
    pcall(function() hum:EquipTool(clone) end)
    bot.equippedTool = clone
    return true
end

local function unequipTool(bot)
    if bot.equippedTool then pcall(function() bot.equippedTool:Destroy() end); bot.equippedTool = nil end
end

local function activateTool(bot)
    if not bot.equippedTool then return end
    pcall(function()
        local re = bot.equippedTool:FindFirstChildOfClass("RemoteEvent")
        if re then re:FireServer() end
    end)
end


-- ══════════════════════════════════════════════════════════════
--  CRUCIBLE SWORD SYSTEM  (new in v4.3)
--  Server-side port of upload/Sword.lua.txt. Lambda bots have a
--  chance to spawn with this weapon. Client-only features (camera
--  FOV, screen shake, first-person arms) are stripped; the visual
--  model, blade extension tween, idle pose, and one-shot Touched
--  damage are all preserved.
-- ══════════════════════════════════════════════════════════════
local C_ENERGY  = Color3.fromRGB(255, 0, 0)
local C_CRIMSON = Color3.fromRGB(255, 0, 0)
local C_WHITE   = Color3.fromRGB(255, 255, 255)

local CRUCIBLE_IDLE_POSE = {
    ['Left Leg']  = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ['Right Arm'] = CFrame.new(1, 0.5, 0, 0.007, 0.262, 0.965, -0.227, 0.940, -0.253, -0.973, -0.217, 0.066),
    ['Head']      = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
    ['Left Arm']  = CFrame.new(0.462, -0.250, -1.020, 0.204, -0.978, -0.000, -0.887, -0.185, -0.422, 0.413, 0.086, -0.906),
    ['Right Leg'] = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
}

local CRUCIBLE_COMBO1 = {
    [2] = {
        ['Head']      = CFrame.new(0,1.15,0) * CFrame.Angles(0,0,0) * CFrame.new(0,0,0) * CFrame.new(0,0.35,0),
        ['Right Arm'] = CFrame.new(-0.190, -1.415, -1.843),
        ['Left Arm']  = CFrame.new(-1.266, -1.350, 1.356),
    },
    [3] = {
        ['Head']      = CFrame.new(0,1.15,0) * CFrame.Angles(0,0,0) * CFrame.new(0,0,0) * CFrame.new(0,0.35,0),
        ['Right Arm'] = CFrame.new(0.876, -0.683, -0.889),
        ['Left Arm']  = CFrame.new(-0.876, -0.683, -0.889),
    },
}

local CRUCIBLE_COMBO2 = {
    [1] = {['Right Arm'] = CFrame.new(0,0,0) * CFrame.Angles(0,0,0), ['Left Arm'] = CFrame.new(0,0,0) * CFrame.Angles(0,0,0)},
    [2] = {['Right Arm'] = CFrame.new(0, 0.1, 0) * CFrame.Angles(0, 0, math.rad(100)),
           ['Left Arm']  = CFrame.new(-1.1, 0.5, -1.5) * CFrame.Angles(math.rad(50), math.rad(-130), math.rad(-70))},
    [3] = {['Right Arm'] = CFrame.new(0.5, 0.4, 0.7) * CFrame.Angles(math.rad(80), 0, math.rad(40)),
           ['Left Arm']  = CFrame.new(-1.4, 0.2, -2.1) * CFrame.Angles(math.rad(120), math.rad(20), math.rad(-50))},
    [4] = {['Right Arm'] = CFrame.new(2.3, 0.6, 0.5) * CFrame.Angles(math.rad(90), 0, math.rad(-90)),
           ['Left Arm']  = CFrame.new(-1.1, -0.3, -0.3) * CFrame.Angles(math.rad(40), math.rad(-50), math.rad(-80))},
}

local CRUCIBLE_MOTORS = {
    ["Head"]      = {"Neck",          "Torso"},
    ["Right Arm"] = {"Right Shoulder", "Torso"},
    ["Left Arm"]  = {"Left Shoulder",  "Torso"},
    ["Right Leg"] = {"Right Hip",      "Torso"},
    ["Left Leg"]  = {"Left Hip",       "Torso"},
}

local CRUCIBLE_BLADE_DATA = {
    {bId="10029465683", bY=2.6,  eId="10029465334", eY=5.5},
    {bId="10029464085", bY=3.6,  eId="10029464588", eY=5.3},
    {bId="10029463282", bY=4.41, eId="10029463519", eY=4.5},
    {bId="10029464324", bY=4.8,  eId="10029463776", eY=3.75},
    {bId="10029464932", bY=5.9,  eId="10029462895", eY=2.6},
}

-- Per-tool controller registry: CrucibleControllers[tool] = { ...closures... }
local CrucibleControllers = {}

local function crucibleCreatePiece(name, meshId, size, material, cf, angles, color, handle)
    local p = Instance.new("MeshPart")
    p.Name = name
    p.MeshId = "rbxassetid://" .. meshId
    p.Size = size
    p.Material = material
    p.Color = color
    p.CanCollide = false
    p.Massless = true
    p.Parent = handle
    local w = Instance.new("Weld")
    w.Part0 = handle
    w.Part1 = p
    w.C0 = cf
    w.Parent = p
    if angles then
        w.C0 = w.C0 * CFrame.Angles(math.rad(angles.X), math.rad(angles.Y), math.rad(angles.Z))
    end
    return p, w
end

-- Builds a Crucible tool. Returns (tool, controller) where controller exposes:
--   :setBlade(bool)        — extend/retract blade + light
--   :applyIdle(bool)       — apply idle pose or restore original C0s
--   :activate(char)        — perform one combo swing with damage
--   :destroy()             — cleanup tweens + sounds
local function createCrucibleSword()
    local tool = Instance.new("Tool")
    tool.Name = "Crucible"
    tool.RequiresHandle = true

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.4, 1.2, 0.4)
    handle.Transparency = 1
    handle.CanCollide = false
    handle.Parent = tool

    local light = Instance.new("PointLight")
    light.Color = C_ENERGY
    light.Range = 15
    light.Brightness = 0
    light.Parent = handle

    -- Static grip + mark
    crucibleCreatePiece("MainGrip", "6391397576",
        Vector3.new(0.08, 0.08, 0.08), Enum.Material.Metal,
        CFrame.new(0, 0.4, 0), Vector3.new(0, 90, 0), Color3.fromRGB(24, 24, 24), handle)
    local mark = crucibleCreatePiece("Mark", "4828974484",
        Vector3.new(0.2, 0.18, 0.13), Enum.Material.Neon,
        CFrame.new(0, 1.12, 0), Vector3.new(0, 90, 0), C_ENERGY, handle)

    -- 5 blade pieces (each has a BasePart B + Energy E)
    local bladeObjs = {}
    for i, d in ipairs(CRUCIBLE_BLADE_DATA) do
        local b, bw = crucibleCreatePiece("B"..tostring(i), d.bId,
            Vector3.new(3,3,3), Enum.Material.Neon,
            CFrame.new(0, 0.8, 0), Vector3.new(-90,0,90), C_CRIMSON, handle)
        local e, ew = crucibleCreatePiece("E"..tostring(i), d.eId,
            Vector3.new(3,3,3), Enum.Material.Neon,
            CFrame.new(0, 0.8, 0), Vector3.new(-90,0,90), C_WHITE, handle)
        b.Transparency = 1
        e.Transparency = 1
        table.insert(bladeObjs, {p=b, w=bw, ty=d.bY, isE=false})
        table.insert(bladeObjs, {p=e, w=ew, ty=d.eY, isE=true})

        -- Server-side Touched damage (one-shot gib)
        b.Touched:Connect(function(hit)
            local ctrl = CrucibleControllers[tool]
            if not ctrl or not ctrl.canDamage then return end
            local m = hit.Parent and (hit.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent)
                       or (hit.Parent and hit.Parent.Parent and hit.Parent.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent.Parent)
            if m and m ~= ctrl.character and not ctrl.hitTable[m] then
                ctrl.hitTable[m] = true
                local s = Instance.new("Sound")
                s.SoundId = "rbxassetid://5665936061"
                s.Parent = hit
                s:Play()
                Debris:AddItem(s, 1)
                -- hacerPapilla: one-shot kill + ragdoll gib
                local eHum = m:FindFirstChildOfClass("Humanoid")
                if eHum and eHum.Health > 0 then
                    eHum.Health = 0
                    for _, parte in pairs(m:GetChildren()) do
                        if parte:IsA("BasePart") then
                            for _, j in pairs(parte:GetChildren()) do
                                if j:IsA("Motor6D") or j:IsA("Weld") then j:Destroy() end
                            end
                            parte.Velocity = (parte.Position - b.Position).Unit * 75 + Vector3.new(0, 30, 0)
                            parte.CanCollide = true
                            parte.Color = Color3.fromRGB(150, 0, 0)
                            local p = Instance.new("ParticleEmitter")
                            p.Color = ColorSequence.new(C_ENERGY)
                            p.Parent = parte
                            p:Emit(15)
                        end
                    end
                    Debris:AddItem(m, 3)
                end
            end
        end)
    end

    -- Sounds
    local equipSnd = Instance.new("Sound")
    equipSnd.SoundId = "rbxassetid://112303690225030"
    equipSnd.Volume = 2
    equipSnd.Parent = handle
    local idleSnd = Instance.new("Sound")
    idleSnd.SoundId = "rbxassetid://8446164946"
    idleSnd.Looped = true
    idleSnd.Volume = 1.5
    idleSnd.Parent = handle
    local offSnd = Instance.new("Sound")
    offSnd.SoundId = "rbxassetid://100513131280674"
    offSnd.Volume = 1.0
    offSnd.Parent = handle

    local controller = {
        tool = tool,
        handle = handle,
        light = light,
        mark = mark,
        bladeObjs = bladeObjs,
        equipSnd = equipSnd,
        idleSnd = idleSnd,
        offSnd = offSnd,
        character = nil,
        originalC0s = {},
        isAttacking = false,
        canDamage = false,
        hitTable = {},
        currentCombo = 1,
        lastAttackTick = 0,
        isEquipped = false,
    }

    function controller:setBlade(val)
        local info = TweenInfo.new(1.0, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        for _, obj in pairs(self.bladeObjs) do
            local tC0 = CFrame.new(0, val and obj.ty or 0.8, 0) * CFrame.Angles(math.rad(-90), 0, math.rad(90))
            local targetTrans = val and (obj.isE and 0 or 0.1) or 1
            TweenService:Create(obj.p, info, {Transparency = targetTrans}):Play()
            TweenService:Create(obj.w, info, {C0 = tC0}):Play()
        end
        TweenService:Create(self.mark, info, {Transparency = val and 0 or 1}):Play()
        TweenService:Create(self.light, info, {Brightness = val and 3 or 0}):Play()
    end

    function controller:applyIdle(isEquipping)
        if not self.character then return end
        local info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        for partName, cf in pairs(CRUCIBLE_IDLE_POSE) do
            local motorInfo = CRUCIBLE_MOTORS[partName]
            local motor = motorInfo and self.character:FindFirstChild(motorInfo[2])
            motor = motor and motor:FindFirstChild(motorInfo[1])
            if motor then
                if not self.originalC0s[partName] then self.originalC0s[partName] = motor.C0 end
                TweenService:Create(motor, info, {C0 = isEquipping and cf or self.originalC0s[partName]}):Play()
            end
        end
    end

    -- One combo swing. Strips camera FOV / screen shake (bot has no camera).
    function controller:activate()
        if self.isAttacking or self.mark.Transparency == 1 then return end
        if tick() - self.lastAttackTick > (CONFIG.SWORD_COMBO_RESET_TIME or 1.5) then
            self.currentCombo = 1
        end
        self.isAttacking = true
        self.hitTable = {}
        self.canDamage = true
        self.lastAttackTick = tick()

        local anim = (self.currentCombo == 1) and CRUCIBLE_COMBO1 or CRUCIBLE_COMBO2
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://91315302125131"
        s.Volume = 1.0
        s.Parent = self.handle
        s:Play()
        Debris:AddItem(s, 2)

        task.spawn(function()
            for i = 1, #anim do
                local speed = (self.currentCombo == 1) and 0.15 or 0.08
                for partName, cf in pairs(anim[i]) do
                    local motorInfo = CRUCIBLE_MOTORS[partName]
                    local motor = self.character:FindFirstChild(motorInfo[2])
                    motor = motor and motor:FindFirstChild(motorInfo[1])
                    if motor then
                        local target = (self.currentCombo == 2) and (self.originalC0s[partName] * cf) or cf
                        TweenService:Create(motor, TweenInfo.new(speed), {C0 = target}):Play()
                    end
                end
                task.wait(speed)
            end
            self.canDamage = false
            task.wait(0.1)
            self:applyIdle(true)
            self.currentCombo = (self.currentCombo == 1) and 2 or 1
            self.isAttacking = false
        end)
    end

    function controller:equip(char)
        self.character = char
        self.isEquipped = true
        self.equipSnd:Play()
        task.wait(0.1)
        self:setBlade(true)
        self.idleSnd:Play()
        self:applyIdle(true)
    end

    function controller:unequip()
        self.isEquipped = false
        self.idleSnd:Stop()
        self.offSnd:Play()
        self:setBlade(false)
        self:applyIdle(false)
    end

    function controller:destroy()
        pcall(function() self.idleSnd:Stop() end)
        self.isEquipped = false
        self.isAttacking = false
        self.canDamage = false
    end

    CrucibleControllers[tool] = controller

    -- Wire up Roblox Tool events to controller
    tool.Equipped:Connect(function()
        local hum = tool.Parent and tool.Parent:FindFirstChildOfClass("Humanoid")
        local char = hum and hum.Parent or tool.Parent
        if char then controller:equip(char) end
    end)
    tool.Unequipped:Connect(function()
        controller:unequip()
    end)

    return tool, controller
end

-- Cached template (built once, cloned per equip)
local CrucibleTemplate = nil
local function getCrucibleTemplate()
    if not CrucibleTemplate then
        CrucibleTemplate = createCrucibleSword()
    end
    return CrucibleTemplate
end

-- Equip a fresh Crucible on a Lambda bot. Replaces bot.equippedTool.
local function equipCrucibleSword(bot)
    if not bot.character then return false end
    local hum = getHum(bot.character)
    if not hum then return false end
    -- Unequip whatever the bot currently holds
    if bot.equippedTool then
        pcall(function() bot.equippedTool:Destroy() end)
        bot.equippedTool = nil
    end
    -- Build a fresh tool (cloning loses Touched connections, so build new each time)
    local tool, ctrl = createCrucibleSword()
    tool.Parent = bot.character
    pcall(function() hum:EquipTool(tool) end)
    bot.equippedTool = tool
    bot.hasSword = true
    return true
end

-- Server-side swing trigger for bots (Lambda bots don't click).
local function crucibleSwing(bot)
    if not bot.equippedTool or bot.equippedTool.Name ~= "Crucible" then return end
    local ctrl = CrucibleControllers[bot.equippedTool]
    if not ctrl or ctrl.isAttacking then return end
    if tick() - ctrl.lastAttackTick < (CONFIG.SWORD_ATTACK_COOLDOWN or 1.0) then return end
    -- Find a nearby enemy within auto-attack range
    local hrp = getRoot(bot.character)
    if not hrp then return end
    local target = nil
    for _, other in pairs(Bots) do
        if other ~= bot and other.alive and other.character then
            local oh = getRoot(other.character)
            if oh and (oh.Position - hrp.Position).Magnitude < (CONFIG.SWORD_AUTO_ATTACK_RANGE or 12) then
                target = other
                break
            end
        end
    end
    -- Also target real players
    if not target then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude < (CONFIG.SWORD_AUTO_ATTACK_RANGE or 12) then
                    target = p.Character
                    break
                end
            end
        end
    end
    if target then
        ctrl:activate()
    end
end

-- Public hook used by the spawn flow below
local function maybeEquipSword(bot)
    if not CONFIG.SWORD_ENABLED then return end
    if math.random() < (CONFIG.SWORD_CHANCE or 0.2) then
        task.delay(randFloat(2, 6), function()
            if not bot.alive then return end
            equipCrucibleSword(bot)
        end)
    end
end

local function findVehicle(bot)
    if not bot.character then return nil end
    local hrp = getRoot(bot.character)
    for _, obj in ipairs(CachedInteractables) do
        if (obj:IsA("Seat") or obj:IsA("VehicleSeat")) and not obj.Occupant then
            if obj.Parent and dist(obj.Position, hrp.Position) < 50 then return obj end
        end
    end
    return nil
end

-- ══════════════════════════════════════════════════════════════
--  KILL BIND / STUCK DETECTION (OPTIMIZED)
-- ══════════════════════════════════════════════════════════════
-- Cache spawn points so we don't recursively search Workspace every killbind
local CachedSpawnCF = nil
local SpawnCFCacheTime = 0

local function getCachedSpawnCF()
    if not CachedSpawnCF or (tick() - SpawnCFCacheTime) > 30 then
        CachedSpawnCF = getSpawnCF()
        SpawnCFCacheTime = tick()
    end
    -- Slight random offset so multiple bots don't stack
    return CachedSpawnCF * CFrame.new(math.random(-3,3), 0, math.random(-3,3))
end

local function bindKillBind(bot)
    if not CONFIG.KILLBIND_ENABLED then return end
    local lastKillbindTime = 0
    task.spawn(function()
        local lastPos = Vector3.new(0,0,0); local stuckTime = 0
        while bot.alive do
            task.wait(1)
            if not bot.alive then break end
            local hrp = getRoot(bot.character)
            if hrp then
                local d = dist(hrp.Position, lastPos)
                local velocity = hrp.AssemblyLinearVelocity.Magnitude
                if d < CONFIG.KILLBIND_STUCK_DIST and velocity < 1 then
                    stuckTime += 1
                    if stuckTime >= CONFIG.KILLBIND_STUCK_TIME then
                        stuckTime = 0
                        -- Cooldown: don't killbind more than once every 8 seconds
                        if tick() - lastKillbindTime < 8 then
                            lastPos = hrp.Position
                            continue
                        end
                        lastKillbindTime = tick()
                        local hum = getHum(bot.character)
                        if hum and hum.Health > 0 then
                            local spawnCF = getCachedSpawnCF()
                            bot:setState("Wander")
                            -- Anchor ALL parts before teleport to prevent physics lag spike
                            local parts = bot.character:GetDescendants()
                            for _, p in ipairs(parts) do
                                if p:IsA("BasePart") then p.Anchored = true end
                            end
                            pcall(function() bot.character:SetPrimaryPartCFrame(spawnCF) end)
                            task.wait(0.3)
                            -- Unanchor after physics settles
                            for _, p in ipairs(parts) do
                                if p:IsA("BasePart") then p.Anchored = false end
                            end
                            task.wait(0.5)
                            if bot.alive then
                                local hrp2 = getRoot(bot.character)
                                if hrp2 and dist(hrp2.Position, spawnCF.Position) >= 3 then
                                    pcall(function() hum:TakeDamage(hum.Health) end)
                                end
                            end
                        end
                    end
                else stuckTime = 0 end
                lastPos = hrp.Position
            end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  ADMIN INTEGRATION (ENHANCED WITH FUN/TROLL COMMANDS)
-- ══════════════════════════════════════════════════════════════
local ADMIN_SYSTEM = nil
local function detectAdminSystem()
    local sss = game:GetService("ServerScriptService")
    if sss:FindFirstChild("HD Admin") or sss:FindFirstChild("HDAdmin") then return "HD" end
    if sss:FindFirstChild("Adonis_Loader") or sss:FindFirstChild("Adonis") then return "Adonis" end
    if _G.HDAdminMain then return "HD" end
    return nil
end
task.spawn(function() task.wait(5); ADMIN_SYSTEM = detectAdminSystem() end)

-- Execute command on target player via RemoteEvent
local function executeOnPlayer(targetPlayer, command, duration)
    if not targetPlayer then return false end
    AdminRemote:FireClient(targetPlayer, {
        command = command,
        duration = duration or 10
    })
    return true
end

-- ══════════════════════════════════════════════════════════════
--  EXECUTE ON BOT (server-side effects for non-admin bot targets)
-- ══════════════════════════════════════════════════════════════
-- Bots have no client, so commands are applied directly on their character.
local function executeOnBot(targetBot, command, duration)
    if not targetBot or not targetBot.alive or not targetBot.character then return false end
    local char = targetBot.character
    local hrp = getRoot(char)
    local hum = getHum(char)
    if not hrp then return false end
    duration = duration or 10

    if command == "explode" then
        local exp = Instance.new("Explosion")
        exp.BlastRadius = 10; exp.BlastPressure = 0
        exp.Position = hrp.Position; exp.Parent = Workspace
    elseif command == "freeze" then
        targetBot._frozen = true
        if hum then hum.WalkSpeed = 0; hum.JumpPower = 0 end
        task.delay(duration, function()
            if targetBot.alive and hum and hum.Parent then
                hum.WalkSpeed = CONFIG.WALK_SPEED; hum.JumpPower = 50
                targetBot._frozen = nil
            end
        end)
    elseif command == "speed" then
        if hum then hum.WalkSpeed = 100 end
        task.delay(duration, function()
            if targetBot.alive and hum and hum.Parent then hum.WalkSpeed = CONFIG.WALK_SPEED end
        end)
    elseif command == "heal" then
        if hum then hum.Health = hum.MaxHealth end
    elseif command == "god" then
        if hum then hum.MaxHealth = math.huge; hum.Health = math.huge end
        task.delay(duration, function()
            if targetBot.alive and hum and hum.Parent then hum.MaxHealth = 100; hum.Health = 100 end
        end)
    elseif command == "fling" then
        if hum then hum.PlatformStand = true end
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(math.random(-300,300), 200, math.random(-300,300))
        bv.MaxForce = Vector3.new(1e6,1e6,1e6); bv.Parent = hrp
        task.delay(2, function()
            bv:Destroy()
            if hum and hum.Parent then hum.PlatformStand = false end
        end)
    elseif command == "slap" then
        if hum then pcall(function() hum:TakeDamage(10) end) end
    elseif command == "rocket" then
        if hum then hum.PlatformStand = true end
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, 150, 0); bv.MaxForce = Vector3.new(0, 4000, 0); bv.Parent = hrp
        task.delay(3, function()
            bv:Destroy()
            if hum and hum.Parent then hum.PlatformStand = false end
        end)
    elseif command == "fly" then
        if hum then hum.PlatformStand = true end
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, 80, 0); bv.MaxForce = Vector3.new(0, 1e6, 0); bv.Parent = hrp
        task.delay(3, function()
            if bv and bv.Parent then
                local startTime = tick()
                while tick() - startTime < duration and targetBot.alive do
                    local angle = math.random(0, 360)
                    local rad = math.rad(angle)
                    bv.Velocity = Vector3.new(math.cos(rad)*40, 20, math.sin(rad)*40)
                    task.wait(1.5)
                end
                bv:Destroy()
            end
            if hum and hum.Parent then hum.PlatformStand = false end
        end)
    elseif command == "launch" then
        if hum then hum.PlatformStand = true end
        local angle = math.random(0, 360); local rad = math.rad(angle)
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(math.cos(rad)*200, 80, math.sin(rad)*200)
        bv.MaxForce = Vector3.new(1e6,1e6,1e6); bv.Parent = hrp
        task.delay(3, function()
            bv:Destroy()
            if hum and hum.Parent then hum.PlatformStand = false end
        end)
    elseif command == "spin" then
        local bav = Instance.new("BodyAngularVelocity")
        bav.AngularVelocity = Vector3.new(0, 50, 0); bav.MaxTorque = Vector3.new(0, 1e6, 0); bav.Parent = hrp
        task.delay(duration, function()
            if bav and bav.Parent then bav:Destroy() end
        end)
    elseif command == "trip" then
        if hum then hum.PlatformStand = true end
        task.delay(1.5, function()
            if hum and hum.Parent then hum.PlatformStand = false end
        end)
    elseif command == "tp" then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.Anchored = true end
        end
        local randomPos = hrp.Position + Vector3.new(math.random(-100,100), 0, math.random(-100,100))
        hrp.CFrame = CFrame.new(randomPos)
        task.delay(0.2, function()
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.Anchored = false end
            end
        end)
    elseif command == "bighead" then
        local head = char:FindFirstChild("Head")
        if head then
            local orig = head.Size
            head.Size = head.Size * 2
            task.delay(duration, function()
                if head and head.Parent then head.Size = orig end
            end)
        end
    elseif command == "tiny" then
        if hum then
            local desc = hum:GetAppliedDescription()
            desc.HeightScale = 0.3; desc.WidthScale = 0.3; desc.DepthScale = 0.3; desc.HeadScale = 0.3
            hum:ApplyDescription(desc)
            task.delay(duration, function()
                if hum and hum.Parent then
                    local d2 = hum:GetAppliedDescription()
                    d2.HeightScale = 1; d2.WidthScale = 1; d2.DepthScale = 1; d2.HeadScale = 1
                    hum:ApplyDescription(d2)
                end
            end)
        end
    elseif command == "size" then
        if hum then
            local scales = {0.2, 0.5, 1.5, 2.5, 4, 0.1, 6}
            local s = scales[math.random(1, #scales)]
            local desc = hum:GetAppliedDescription()
            desc.HeightScale = s; desc.WidthScale = s; desc.DepthScale = s; desc.HeadScale = s
            hum:ApplyDescription(desc)
            task.delay(duration, function()
                if hum and hum.Parent then
                    local d2 = hum:GetAppliedDescription()
                    d2.HeightScale = 1; d2.WidthScale = 1; d2.DepthScale = 1; d2.HeadScale = 1
                    hum:ApplyDescription(d2)
                end
            end)
        end
    elseif command == "smoke" then
        local smoke = Instance.new("Smoke")
        smoke.Color = Color3.fromRGB(80,80,80); smoke.Opacity = 0.5; smoke.RiseVelocity = 5; smoke.Size = 10
        smoke.Parent = hrp
        task.delay(duration, function()
            if smoke and smoke.Parent then smoke:Destroy() end
        end)
    elseif command == "fire" then
        local fire = Instance.new("Fire")
        fire.Size = 5; fire.Heat = 10; fire.Parent = hrp
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255,100,0); light.Brightness = 3; light.Range = 20; light.Parent = hrp
        task.delay(duration, function()
            if fire and fire.Parent then fire:Destroy() end
            if light and light.Parent then light:Destroy() end
        end)
    elseif command == "invisible" then
        local parts = {}
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                table.insert(parts, {part = p, orig = p.Transparency}); p.Transparency = 1
            end
        end
        task.delay(duration, function()
            for _, entry in ipairs(parts) do
                if entry.part and entry.part.Parent then entry.part.Transparency = entry.orig end
            end
        end)
    elseif command == "orbit" then
        if hum then hum.PlatformStand = true end
        local centerPos = hrp.Position
        task.spawn(function()
            local startTime = tick()
            while tick() - startTime < duration and targetBot.alive do
                local t = (tick() - startTime) * 3
                local x = centerPos.X + math.cos(t) * 15
                local z = centerPos.Z + math.sin(t) * 15
                hrp.CFrame = CFrame.new(x, centerPos.Y + 5, z)
                task.wait(0.03)
            end
            if hum and hum.Parent then hum.PlatformStand = false end
        end)
    elseif command == "chaos" then
        local cmds = {"fling", "tp", "spin", "trip", "launch", "orbit"}
        task.spawn(function()
            local startTime = tick()
            while tick() - startTime < duration and targetBot.alive do
                executeOnBot(targetBot, cmds[math.random(1, #cmds)], 3)
                task.wait(math.random(2, 4))
            end
        end)
    else
        -- Fallback: just damage them a little
        if hum then pcall(function() hum:TakeDamage(5) end) end
    end
    return true
end

-- Patrick's Doom Shutdown
local function patricksDoomShutdown(bot, targetPlayer)
    botSay(bot, "admin_scold", "!patricksdoomshutdown " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "patricksdoomshutdown", 60)
    botSay(bot, "admin_scold", "🍔 Patrick has been summoned to consume " .. targetPlayer.Name .. "!")
end

-- Spawn Zombie
local function spawnZombieCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!spawnzombie " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "spawnzombie")
    botSay(bot, "admin_scold", "🧟 Zombies have been spawned on " .. targetPlayer.Name .. "!")
end

-- Rainbow Trail
local function rainbowTrailCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!rainbowtrail " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "rainbowtrail", 15)
    botSay(bot, "admin_scold", "🌈 " .. targetPlayer.Name .. " now has a fabulous rainbow trail!")
end

-- Explode
local function explodePlayerCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!explode " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "explode")
    botSay(bot, "admin_scold", "💥 BOOM! " .. targetPlayer.Name .. " just exploded!")
end

-- Reverse Controls
local function reverseControlsCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!reverse " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "reverse", 8)
    botSay(bot, "admin_scold", "🔄 " .. targetPlayer.Name .. "'s controls are reversed!")
end

-- Dance
local function dancePartyCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!dance " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "dance", 10)
    botSay(bot, "admin_scold", "💃 " .. targetPlayer.Name .. " is forced to dance!")
end

-- Giant Head
local function giantHeadCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!bighead " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "bighead", 10)
    botSay(bot, "admin_scold", "🐘 " .. targetPlayer.Name .. " has a giant head!")
end

-- Freeze
local function freezePlayerCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!freeze " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "freeze", 5)
    botSay(bot, "admin_scold", "❄️ " .. targetPlayer.Name .. " is frozen solid!")
end

-- Trap in Cage
local function trapPlayerCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!trap " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "trap")
    botSay(bot, "admin_scold", "🔒 " .. targetPlayer.Name .. " has been trapped in a cage!")
end

-- Slap
local function slapPlayerCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!slap " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "slap")
    botSay(bot, "admin_scold", "👋 SLAP! " .. targetPlayer.Name .. " got slapped!")
end

-- Confuse
local function confusePlayerCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!confuse " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "confuse", 5)
    botSay(bot, "admin_scold", "🌀 " .. targetPlayer.Name .. " is confused!")
end

-- Rocket Launch
local function rocketPlayerCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!rocket " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "rocket")
    botSay(bot, "admin_scold", "🚀 " .. targetPlayer.Name .. " has been launched to space!")
end

-- Spam Message
local function spamMessageCmd(bot, targetPlayer, message)
    message = message or "I LOVE LAMBDA PLAYERS!"
    botSay(bot, "admin_scold", "!spam " .. (targetPlayer and targetPlayer.Name or "") .. " " .. message)
    for i = 1, 5 do
        task.wait(0.5)
        if bot.alive then
            botSay(bot, "admin_scold", message)
        end
    end
end

-- Kill All Bots
local function killAllBotsCmd(bot)
    botSay(bot, "admin_scold", "!killallbots")
    for _, b in pairs(Bots) do
        if b and b.alive and b.character then
            local hum = getHum(b.character)
            if hum then
                hum.Health = 0
            end
        end
    end
    botSay(bot, "admin_scold", "💀 All bots have been eliminated!")
end

-- Summon Patrick (visual on bot)
local function summonPatrickCmd(bot)
    botSay(bot, "admin_scold", "!patrick")
    local char = bot.character
    if char and char:FindFirstChild("Head") then
        local head = char.Head
        local patrickHat = Instance.new("Part")
        patrickHat.Name = "PatrickHat"
        patrickHat.Size = Vector3.new(2, 2, 2)
        patrickHat.Shape = Enum.PartType.Ball
        patrickHat.Color = Color3.fromRGB(255, 200, 100)
        patrickHat.Material = Enum.Material.Neon
        patrickHat.CanCollide = false
        patrickHat.Parent = head
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = head
        weld.Part1 = patrickHat
        weld.Parent = patrickHat
        task.delay(10, function() patrickHat:Destroy() end)
    end
    botSay(bot, "admin_scold", "🍔 Patrick has been summoned!")
end

-- ── NEW CLIENT-SIDE COMMAND WRAPPERS ──────────────────────────────
-- These all fire to the client via AdminRemote — effects run client-side only.

local function tpCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!tp " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "tp")
    botSay(bot, "admin_scold", "🌀 " .. targetPlayer.Name .. " has been teleported!")
end

local function speedCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!speed " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "speed", 10)
    botSay(bot, "admin_scold", "⚡ " .. targetPlayer.Name .. " has super speed!")
end

local function godCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!god " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "god", 15)
    botSay(bot, "admin_scold", "🛡️ " .. targetPlayer.Name .. " has been granted god mode!")
end

local function healCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!heal " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "heal")
    botSay(bot, "admin_scold", "💚 " .. targetPlayer.Name .. " has been fully healed!")
end

local function flingCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!fling " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "fling")
    botSay(bot, "admin_scold", "🪂 " .. targetPlayer.Name .. " has been flung!")
end

local function smokeCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!smoke " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "smoke", 8)
    botSay(bot, "admin_scold", "💨 " .. targetPlayer.Name .. " is surrounded by smoke!")
end

local function fireCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!fire " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "fire", 8)
    botSay(bot, "admin_scold", "🔥 " .. targetPlayer.Name .. " is on fire!")
end

local function invisibleCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!invisible " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "invisible", 10)
    botSay(bot, "admin_scold", "👻 " .. targetPlayer.Name .. " is now invisible!")
end

local function blindCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!blind " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "blind", 8)
    botSay(bot, "admin_scold", "🖤 " .. targetPlayer.Name .. " has been blinded!")
end

local function drunkCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!drunk " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "drunk", 10)
    botSay(bot, "admin_scold", "🍺 " .. targetPlayer.Name .. " is drunk!")
end

local function tinyCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!tiny " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "tiny", 10)
    botSay(bot, "admin_scold", "🐜 " .. targetPlayer.Name .. " has been shrunk!")
end

local function spinCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!spin " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "spin", 8)
    botSay(bot, "admin_scold", "🌀 " .. targetPlayer.Name .. " is spinning out of control!")
end

local function earthquakeCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!earthquake " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "earthquake", 6)
    botSay(bot, "admin_scold", "🌍 EARTHQUAKE on " .. targetPlayer.Name .. "!")
end

local function tripCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!trip " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "trip")
    botSay(bot, "admin_scold", "🦶 " .. targetPlayer.Name .. " tripped and fell!")
end

local function scareCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!scare " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "scare")
    botSay(bot, "admin_scold", "👻 " .. targetPlayer.Name .. " got jumpscared!")
end

local function jailCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!jail " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "jail", 15)
    botSay(bot, "admin_scold", "🔒 " .. targetPlayer.Name .. " has been sent to jail!")
end

local function sizeCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!size " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "size", 12)
    botSay(bot, "admin_scold", "📏 " .. targetPlayer.Name .. "'s size has been changed!")
end

local function announceCmd(bot, targetPlayer, message)
    message = message or "Lambda Players is watching you..."
    botSay(bot, "admin_scold", "!announce " .. message)
    executeOnPlayer(targetPlayer, "announce", 8)
    -- Re-fire with message
    AdminRemote:FireClient(targetPlayer, {command = "announce", duration = 8, message = message})
    botSay(bot, "admin_scold", "📢 Announcement sent to " .. targetPlayer.Name .. "!")
end

local function bringCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!bring " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "bring")
    botSay(bot, "admin_scold", "🧲 " .. targetPlayer.Name .. " has been brought here!")
end

local function launchCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!launch " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "launch")
    botSay(bot, "admin_scold", "🚀 " .. targetPlayer.Name .. " has been launched sideways!")
end

local function orbitCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!orbit " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "orbit", 8)
    botSay(bot, "admin_scold", "🪐 " .. targetPlayer.Name .. " is orbiting!")
end

local function chaosCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!chaos " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "chaos", 15)
    botSay(bot, "admin_scold", "🌪️ CHAOS has been unleashed on " .. targetPlayer.Name .. "!")
end

local function flyCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!fly " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "fly", 8)
    botSay(bot, "admin_scold", "🕊️ " .. targetPlayer.Name .. " has been forced to fly!")
end


-- Spawn Igor on target player (client-side via RemoteEvent)
local function spawnIgorCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!spawnigor " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "spawnigor")
    botSay(bot, "admin_scold", "🧟 An Igor has been spawned near " .. targetPlayer.Name .. "!")
end

-- Kill all of target player's local Igors
local function killIgorCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!killigor " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "killigor")
    botSay(bot, "admin_scold", "🧹 All of " .. targetPlayer.Name .. "'s Igors have been removed!")
end

-- Force target player's Igors to become aggressive
local function igorAggressiveCmd(bot, targetPlayer)
    botSay(bot, "admin_scold", "!igoraggressive " .. targetPlayer.Name)
    executeOnPlayer(targetPlayer, "igoraggressive")
    botSay(bot, "admin_scold", "😡 " .. targetPlayer.Name .. "'s Igors have gone hostile!")
end

-- Unban player
local function unbanPlayer(bot, targetPlayer)
    if BannedPlayers[targetPlayer.UserId] then
        BannedPlayers[targetPlayer.UserId] = nil
        botSay(bot, "admin_scold", "!unban " .. targetPlayer.Name)
        botSay(bot, "admin_scold", "✅ " .. targetPlayer.Name .. " has been unbanned!")
    else
        botSay(bot, "admin_scold", targetPlayer.Name .. " is not banned.")
    end
end

-- Collection of all admin commands
local ADMIN_COMMANDS = {
    -- Punishment Commands
    ban = { func = banPlayer, desc = "Ban a player from the server", requireTarget = true },
    kick = { func = kickPlayer, desc = "Kick a player from the server", requireTarget = true },
    unban = { func = unbanPlayer, desc = "Unban a player from the server", requireTarget = true },
    
    -- Troll/Fun Commands (existing)
    spawnzombie = { func = spawnZombieCmd, desc = "Spawn zombies that infect players", requireTarget = true },
    patricksdoomshutdown = { func = patricksDoomShutdown, desc = "Summon Patrick to consume a player", requireTarget = true },
    rainbowtrail = { func = rainbowTrailCmd, desc = "Give a player a rainbow trail", requireTarget = true },
    explode = { func = explodePlayerCmd, desc = "Make a player explode", requireTarget = true },
    reverse = { func = reverseControlsCmd, desc = "Reverse a player's controls", requireTarget = true },
    dance = { func = dancePartyCmd, desc = "Force a player to dance", requireTarget = true },
    bighead = { func = giantHeadCmd, desc = "Make a player's head giant", requireTarget = true },
    freeze = { func = freezePlayerCmd, desc = "Freeze a player", requireTarget = true },
    trap = { func = trapPlayerCmd, desc = "Trap a player in a cage", requireTarget = true },
    slap = { func = slapPlayerCmd, desc = "Slap a player", requireTarget = true },
    confuse = { func = confusePlayerCmd, desc = "Confuse a player", requireTarget = true },
    rocket = { func = rocketPlayerCmd, desc = "Launch a player into the air", requireTarget = true },
    
    -- NEW Client-Side Commands
    tp = { func = tpCmd, desc = "Teleport player to a random spot", requireTarget = true },
    speed = { func = speedCmd, desc = "Boost player speed to 100", requireTarget = true },
    god = { func = godCmd, desc = "Give player god mode", requireTarget = true },
    heal = { func = healCmd, desc = "Fully heal a player", requireTarget = true },
    fling = { func = flingCmd, desc = "Fling a player into the sky", requireTarget = true },
    smoke = { func = smokeCmd, desc = "Surround player in smoke", requireTarget = true },
    fire = { func = fireCmd, desc = "Set player on fire", requireTarget = true },
    invisible = { func = invisibleCmd, desc = "Turn player invisible", requireTarget = true },
    blind = { func = blindCmd, desc = "Black out a player's screen", requireTarget = true },
    drunk = { func = drunkCmd, desc = "Make a player's screen wobbly", requireTarget = true },
    tiny = { func = tinyCmd, desc = "Shrink a player to tiny size", requireTarget = true },
    spin = { func = spinCmd, desc = "Spin a player uncontrollably", requireTarget = true },
    earthquake = { func = earthquakeCmd, desc = "Shake a player's screen violently", requireTarget = true },
    trip = { func = tripCmd, desc = "Force a player to trip/fall", requireTarget = true },
    scare = { func = scareCmd, desc = "Jumpscare a player", requireTarget = true },
    jail = { func = jailCmd, desc = "Trap player in a jail cell", requireTarget = true },
    size = { func = sizeCmd, desc = "Randomly resize a player", requireTarget = true },
    announce = { func = announceCmd, desc = "Show announcement on screen", requireTarget = true },
    bring = { func = bringCmd, desc = "Teleport player to another", requireTarget = true },
    launch = { func = launchCmd, desc = "Launch player sideways", requireTarget = true },
    orbit = { func = orbitCmd, desc = "Make player orbit their position", requireTarget = true },
    chaos = { func = chaosCmd, desc = "Random combo of effects", requireTarget = true },
    fly = { func = flyCmd, desc = "Force player to fly", requireTarget = true },
    
    -- Igor System Commands
    spawnigor = { func = spawnIgorCmd, desc = "Spawn an Igor near a player", requireTarget = true },
    killigor = { func = killIgorCmd, desc = "Remove all of a player's local Igors", requireTarget = true },
    igoraggressive = { func = igorAggressiveCmd, desc = "Force a player's Igors hostile", requireTarget = true },

    -- Self-only / No-target Commands
    spam = { func = spamMessageCmd, desc = "Spam a message", requireTarget = false },
    killallbots = { func = killAllBotsCmd, desc = "Kill all bots", requireTarget = false },
    patrick = { func = summonPatrickCmd, desc = "Summon Patrick on self", requireTarget = false },
    
    -- Standard Admin Commands
    warn = { func = function(bot, target) botSay(bot, "admin_scold", "!warn " .. target.Name .. " Please follow the rules!") end, requireTarget = true },
    mute = { func = function(bot, target) botSay(bot, "admin_scold", "!mute " .. target.Name .. " You have been muted for 5 minutes") end, requireTarget = true },
}

-- Admin command handler
-- target can be a Player (client-side via RemoteEvent) or a bot table (server-side via executeOnBot)
local function botUseAdminCommand(bot, target)
    if not target then return end

    local isBot = type(target) == "table" and target.id and target.character
    local targetName = isBot and target.name or (target.Name or "???")

    local commandList = {}
    for cmdName, cmdData in pairs(ADMIN_COMMANDS) do
        if not cmdData.requireTarget or target then
            table.insert(commandList, {name = cmdName, data = cmdData})
        end
    end

    if #commandList == 0 then
        botSay(bot, "admin_scold")
        return
    end

    local chosen = commandList[math.random(1, #commandList)]

    if chosen.data.requireTarget then
        if isBot then
            -- Server-side on bot character (bots have no client)
            botSay(bot, "admin_scold", "!" .. chosen.name .. " " .. targetName)
            executeOnBot(target, chosen.name, 10)
            botSay(bot, "admin_scold", "Executed " .. chosen.name .. " on bot " .. targetName)
        else
            -- Client-side on real player
            chosen.data.func(bot, target)
        end
    else
        chosen.data.func(bot)
    end
end

-- ══════════════════════════════════════════════════════════════
--  INTERACTION SYSTEM
-- ══════════════════════════════════════════════════════════════
local INTERACT_LINES = {"what does this do","let me try this","ooh what's this","pressing it","...","interesting","i wonder what this does","ok i pressed it","why not","bro what did i just press","i should not have done that","that was cool actually","doing stuff"}

local function triggerProximityPrompt(bot, prompt)
    pcall(function() prompt.Triggered:Fire(nil) end)
end

local function triggerClickDetector(bot, detector)
    pcall(function() detector.MouseClick:Fire(nil) end)
end

local function botInteractWith(bot, entry)
    local hum, hrp = getHum(bot.character), getRoot(bot.character)
    if not hum or not hrp then return false end
    local maxRange = entry.kind == "ProximityPrompt" and math.max(2, entry.object.MaxActivationDistance-1) or 4
    if hum then hum.WalkSpeed = CONFIG.WALK_SPEED end
    walkTo(bot, entry.position)
    hrp = getRoot(bot.character)
    if not hrp or dist(hrp.Position, entry.position) > maxRange+4 then return false end
    local lookDir = (entry.position - hrp.Position)
    lookDir = Vector3.new(lookDir.X, 0, lookDir.Z)
    if lookDir.Magnitude > 0.01 then hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + lookDir) end
    task.wait(randFloat(0.3,1.0))
    if math.random() < 0.6 then botSay(bot,"idle", INTERACT_LINES[math.random(1,#INTERACT_LINES)]) end
    if entry.kind == "ProximityPrompt" then triggerProximityPrompt(bot, entry.object)
    elseif entry.kind == "ClickDetector" then triggerClickDetector(bot, entry.object) end
    task.wait(randFloat(0.5,1.5))
    return true
end

local function bindInteractionScanner(bot)
    task.spawn(function()
        while bot.alive do
            task.wait(randFloat(8,15))
            if not bot.alive then break end
            if bot.state ~= "Wander" and bot.state ~= "Idle" then continue end
            local hrp = getRoot(bot.character)
            if not hrp then continue end
            if math.random() < CONFIG.VEHICLE_ENTER_CHANCE then
                local vehicle = findVehicle(bot)
                if vehicle then
                    botSay(bot,"vehicle")
                    bot.interruptPath=false
                    walkTo(bot, vehicle.Position)
                    task.wait(2)
                    if bot.alive and getHum(bot.character) then
                        pcall(function() vehicle:Sit(getHum(bot.character)) end)
                        bot:setState("Vehicle")
                        task.wait(randFloat(10,40))
                        if bot.alive then pcall(function() getHum(bot.character).Sit = false end) end
                    end
                    continue
                end
            end
            local interactables = {}
            for _, obj in ipairs(CachedInteractables) do
                if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then
                    local part = obj.Parent
                    if part and dist(part.Position, hrp.Position) < 30 then
                        table.insert(interactables, {object=obj, kind=obj:IsA("ProximityPrompt") and "ProximityPrompt" or "ClickDetector", position=part.Position})
                    end
                end
            end
            if #interactables == 0 then continue end
            local chance = 0.20 + bot.personality.curiosity * 0.35
            if math.random() < chance then
                bot._interactTarget = interactables[math.random(1, math.min(3,#interactables))]
                bot:setState("Interact")
            end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  NAMEPLATE & UI
-- ══════════════════════════════════════════════════════════════
local function buildNameplate(head, bot)
    if not head then return {Text=""} end
    local bg = Instance.new("BillboardGui")
    bg.Name="LambdaNameplate"; bg.Size=UDim2.new(0,220,0,60); bg.StudsOffset=Vector3.new(0,2.8,0); bg.AlwaysOnTop=false; bg.Adornee=head
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size=UDim2.new(1,0,0.45,0); nameLabel.BackgroundTransparency=1
    nameLabel.TextColor3=getRoleColor(bot.role or "Player")
    nameLabel.TextStrokeTransparency=0; nameLabel.Font=Enum.Font.GothamBold; nameLabel.TextScaled=true
    nameLabel.Text=bot.name; nameLabel.Parent=bg
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Name="RoleLabel"; roleLabel.Size=UDim2.new(1,0,0.25,0); roleLabel.Position=UDim2.new(0,0,0.45,0)
    roleLabel.BackgroundTransparency=1; roleLabel.TextColor3=getRoleColor(bot.role or "Player")
    roleLabel.TextStrokeTransparency=0.5; roleLabel.Font=Enum.Font.GothamBold; roleLabel.TextScaled=true
    roleLabel.Text="[".. (bot.role or "BOT") .."]"..(bot.isAdmin and "[ADMIN]" or ""); roleLabel.Parent=bg
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name="StatusLabel"; statusLabel.Size=UDim2.new(1,0,0.30,0); statusLabel.Position=UDim2.new(0,0,0.70,0)
    statusLabel.BackgroundTransparency=1; statusLabel.TextColor3=Color3.fromRGB(200,200,200)
    statusLabel.TextStrokeTransparency=0; statusLabel.Font=Enum.Font.Gotham; statusLabel.TextScaled=true
    statusLabel.Text="[Idle]"; statusLabel.Parent=bg
    bg.Parent=head
    return statusLabel
end


-- ══════════════════════════════════════════════════════════════
--  CUSTOM A* PATHFINDING ENGINE  (new in v4.3)
--  Replaces PathfindingService for Lambda bot movement. Uses a
--  lazy 3D voxel grid sampled on demand from Workspace, with a
--  min-heap open set, Manhattan heuristic, and 26-directional
--  neighbor expansion (no corner cutting on diagonals).
-- ══════════════════════════════════════════════════════════════
local AstPathfinder = {}

local AST_VOXEL       = CONFIG.ASTAR_VOXEL_SIZE or 4
local AST_MAX_ITER    = CONFIG.ASTAR_MAX_ITERATIONS or 6000
local AST_MAX_NODES   = CONFIG.ASTAR_MAX_NODES or 800
local AST_CACHE_TTL   = CONFIG.ASTAR_CACHE_TTL or 30

-- 26-directional neighbor offsets (3D), cost = euclidean distance * voxel
local AST_NEIGHBORS = (function()
    local t = {}
    for x = -1, 1 do
        for y = -1, 1 do
            for z = -1, 1 do
                if not (x == 0 and y == 0 and z == 0) then
                    local mag = math.sqrt(x*x + y*y + z*z)
                    table.insert(t, {dx=x, dy=y, dz=z, cost=mag * AST_VOXEL})
                end
            end
        end
    end
    return t
end)()

-- Voxel walkability cache: key "x,y,z" -> true (open) | false (blocked)
local AST_VOXEL_CACHE = {}
local AST_VOXEL_CACHE_LAST_CLEAR = tick()

-- Min-heap (priority queue) for the A* open set
local function makeHeap()
    return {items = {}, size = 0}
end

local function heapPush(heap, item, priority)
    heap.size = heap.size + 1
    local i = heap.size
    heap.items[i] = {item = item, priority = priority}
    while i > 1 do
        local parent = math.floor(i / 2)
        if heap.items[parent].priority <= heap.items[i].priority then break end
        heap.items[parent], heap.items[i] = heap.items[i], heap.items[parent]
        i = parent
    end
end

local function heapPop(heap)
    if heap.size == 0 then return nil end
    local top = heap.items[1].item
    heap.items[1] = heap.items[heap.size]
    heap.items[heap.size] = nil
    heap.size = heap.size - 1
    local i = 1
    while true do
        local left = 2 * i
        local right = 2 * i + 1
        local smallest = i
        if left <= heap.size and heap.items[left].priority < heap.items[smallest].priority then
            smallest = left
        end
        if right <= heap.size and heap.items[right].priority < heap.items[smallest].priority then
            smallest = right
        end
        if smallest == i then break end
        heap.items[smallest], heap.items[i] = heap.items[i], heap.items[smallest]
        i = smallest
    end
    return top
end

-- Returns true if the voxel centered at (cx,cy,cz) is open (no solid BasePart).
local function isVoxelOpen(cx, cy, cz)
    local key = cx .. "," .. cy .. "," .. cz
    local now = tick()
    if now - AST_VOXEL_CACHE_LAST_CLEAR > AST_CACHE_TTL then
        AST_VOXEL_CACHE = {}
        AST_VOXEL_CACHE_LAST_CLEAR = now
    end
    if AST_VOXEL_CACHE[key] ~= nil then
        return AST_VOXEL_CACHE[key]
    end
    local half = AST_VOXEL * 0.5
    local region = Region3.new(
        Vector3.new(cx - half, cy - half, cz - half),
        Vector3.new(cx + half, cy + half, cz + half)
    )
    local parts = Workspace:GetPartBoundsInBox(region.CFrame, region.Size)
    local blocked = false
    for _, p in ipairs(parts) do
        if p.CanCollide then
            blocked = true
            break
        end
    end
    AST_VOXEL_CACHE[key] = not blocked
    return not blocked
end

-- Snap a Vector3 to the nearest voxel center
local function snapToVoxel(pos)
    local sx = math.floor((pos.X + AST_VOXEL * 0.5) / AST_VOXEL) * AST_VOXEL
    local sy = math.floor((pos.Y + AST_VOXEL * 0.5) / AST_VOXEL) * AST_VOXEL
    local sz = math.floor((pos.Z + AST_VOXEL * 0.5) / AST_VOXEL) * AST_VOXEL
    return sx, sy, sz
end

-- Walk downward up to 4 voxels to find a position whose floor is solid.
local function findFloorVoxel(x, y, z)
    for i = 0, 4 do
        local belowY = y - i * AST_VOXEL
        if not isVoxelOpen(x, belowY, z) then
            return x, belowY + AST_VOXEL, z
        end
    end
    return x, y, z
end

local function heuristic(ax, ay, az, bx, by, bz)
    return math.abs(ax - bx) + math.abs(ay - by) + math.abs(az - bz)
end

-- Main entry point. Returns a table with .Status and :GetWaypoints(),
-- matching PathfindingService:CreatePath() API so it's a drop-in replacement.
function AstPathfinder.makePath(startPos, goalPos, opts)
    opts = opts or {}
    local agentCanJump = opts.AgentCanJump ~= false
    local maxIter = opts.MaxIter or AST_MAX_ITER
    local maxNodes = opts.MaxNodes or AST_MAX_NODES

    local sx, sy, sz = snapToVoxel(startPos)
    local gx, gy, gz = snapToVoxel(goalPos)
    sx, sy, sz = findFloorVoxel(sx, sy, sz)
    gx, gy, gz = findFloorVoxel(gx, gy, gz)

    local startKey = sx .. "," .. sy .. "," .. sz
    local goalKey  = gx .. "," .. gy .. "," .. gz

    if startKey == goalKey then
        return {
            Status = Enum.PathStatus.Success,
            GetWaypoints = function()
                return {{Position = goalPos, Action = Enum.PathWaypointAction.Walk}}
            end,
        }
    end

    local open = makeHeap()
    local cameFrom = {}
    local gScore = {[startKey] = 0}
    heapPush(open, {x=sx, y=sy, z=sz, key=startKey}, heuristic(sx, sy, sz, gx, gy, gz))

    local closed = {}
    local iter = 0
    local nodesExpanded = 0

    while open.size > 0 do
        iter = iter + 1
        if iter > maxIter then break end

        local current = heapPop(open)
        if not current then break end

        if current.key == goalKey then
            -- reconstruct
            local path = {}
            local k = current.key
            local cx, cy, cz = current.x, current.y, current.z
            while k do
                table.insert(path, 1, {Position = Vector3.new(cx, cy, cz), Action = Enum.PathWaypointAction.Walk})
                local prev = cameFrom[k]
                if not prev then break end
                cx, cy, cz = prev.x, prev.y, prev.z
                k = prev.key
            end
            if #path > 0 then
                path[#path].Position = goalPos
            else
                path[1] = {Position = goalPos, Action = Enum.PathWaypointAction.Walk}
            end
            return {
                Status = Enum.PathStatus.Success,
                GetWaypoints = function() return path end,
            }
        end

        if closed[current.key] then
            -- already processed; skip
        else
            closed[current.key] = true
            nodesExpanded = nodesExpanded + 1
            if nodesExpanded > maxNodes then break end

            for _, n in ipairs(AST_NEIGHBORS) do
                local nx = current.x + n.dx * AST_VOXEL
                local ny = current.y + n.dy * AST_VOXEL
                local nz = current.z + n.dz * AST_VOXEL
                local nkey = nx .. "," .. ny .. "," .. nz
                if not closed[nkey] then
                    local horizontalOpen = isVoxelOpen(nx, current.y, nz)
                    local targetOpen = isVoxelOpen(nx, ny, nz)
                    if horizontalOpen and targetOpen then
                        -- no corner cutting for diagonals
                        if n.dx ~= 0 and n.dz ~= 0 then
                            if (not isVoxelOpen(current.x + n.dx * AST_VOXEL, current.y, current.z)) or
                               (not isVoxelOpen(current.x, current.y, current.z + n.dz * AST_VOXEL)) then
                                goto continue
                            end
                        end
                        if n.dy > 0 and not agentCanJump then
                            goto continue
                        end
                        local tentativeG = (gScore[current.key] or 0) + n.cost
                        if tentativeG < (gScore[nkey] or math.huge) then
                            cameFrom[nkey] = {x=current.x, y=current.y, z=current.z, key=current.key}
                            gScore[nkey] = tentativeG
                            local f = tentativeG + heuristic(nx, ny, nz, gx, gy, gz)
                            heapPush(open, {x=nx, y=ny, z=nz, key=nkey}, f)
                        end
                    end
                end
                ::continue::
            end
        end
    end

    -- No path found
    return {
        Status = Enum.PathStatus.NoPath,
        GetWaypoints = function() return {} end,
    }
end

-- Convenience: same call shape as PathfindingService:CreatePath():ComputeAsync()
local function astarComputePath(startPos, goalPos, opts)
    if not CONFIG.USE_CUSTOM_ASTAR then
        local path = PathfindingService:CreatePath(opts or {})
        local ok = pcall(function() path:ComputeAsync(startPos, goalPos) end)
        if not ok then path = {Status = Enum.PathStatus.NoPath, GetWaypoints = function() return {} end} end
        return path
    end
    return AstPathfinder.makePath(startPos, goalPos, opts)
end

-- ══════════════════════════════════════════════════════════════
--  PATHFINDING
-- ══════════════════════════════════════════════════════════════
walkTo = function(bot, target)
    if not bot.alive or not bot.character then return end
    local hrp, hum = getRoot(bot.character), getHum(bot.character)
    if not hrp or not hum or hum.Health<=0 then return end
    local now = tick()
    if now - LastPathfindTime < 0.5 then hum:MoveTo(target); return end
    LastPathfindTime = now
    local path = astarComputePath(hrp.Position, target,
        {AgentRadius=2, AgentHeight=5, AgentCanJump=true, AgentJumpHeight=7, AgentMaxSlope=45,
         MaxIter=CONFIG.ASTAR_MAX_ITERATIONS, MaxNodes=CONFIG.ASTAR_MAX_NODES})
    if not path or path.Status ~= Enum.PathStatus.Success then hum:MoveTo(target); return end
    local startTick = bot.stateTick
    for _, wp in ipairs(path:GetWaypoints()) do
        if not bot.alive or bot.interruptPath or bot.stateTick ~= startTick then break end
        if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump=true end
        hum:MoveTo(wp.Position)
        local done=false; local t=0; local conn
        conn = hum.MoveToFinished:Connect(function() done=true; conn:Disconnect() end)
        while not done and t<3 and bot.alive and not bot.interruptPath and bot.stateTick==startTick do
            task.wait(0.1); t+=0.1
            if math.random()<CONFIG.JUMP_CHANCE*0.1 then hum.Jump=true end
        end
        pcall(function() conn:Disconnect() end)
    end
end

-- ══════════════════════════════════════════════════════════════
--  EMOTE SYSTEM
-- ══════════════════════════════════════════════════════════════
local EMOTE_ANIMS = {
    Wave="rbxassetid://507770239",
    Dance="rbxassetid://507771019",
    Dance2="rbxassetid://507776043",
    Dance3="rbxassetid://507777268",
    Laugh="rbxassetid://507770818",
    Point="rbxassetid://507770453",
    Cheer="rbxassetid://507770677",
    CustomDance="rbxassetid://126123959691270",
    Applaude="rbxassetid://507770789",
    Confused="rbxassetid://507771043",
    Shrug="rbxassetid://507771133",
}

local EMOTE_CATEGORIES = {
    dance = {"Dance", "Dance2", "Dance3", "CustomDance"},
    social = {"Wave", "Cheer", "Applaude", "Laugh"},
    expression = {"Point", "Confused", "Shrug"},
}

local BotEmoteSounds = {}

local function playEmote(bot, emoteName)
    if not bot.animator then return end
    local id = EMOTE_ANIMS[emoteName]; if not id then return end
    local anim = Instance.new("Animation"); anim.AnimationId = id
    local track; pcall(function() track = bot.animator:LoadAnimation(anim); track:Play() end)
    return track
end

local function playEmoteWithMusic(bot, emoteName, playMusic)
    if not CONFIG.EMOTE_ENABLED then return nil, nil end
    
    local track = playEmote(bot, emoteName)
    local sound = nil
    
    if playMusic and CONFIG.EMOTE_MUSIC_ENABLED and bot.character then
        local head = bot.character:FindFirstChild("Head")
        if head then
            if BotEmoteSounds[bot.id] then
                pcall(function() BotEmoteSounds[bot.id]:Stop(); BotEmoteSounds[bot.id]:Destroy() end)
                BotEmoteSounds[bot.id] = nil
            end
            
            sound = Instance.new("Sound")
            sound.Name = "EmoteMusic"
            sound.SoundId = CONFIG.EMOTE_MUSIC_IDS[math.random(1, #CONFIG.EMOTE_MUSIC_IDS)]
            sound.Volume = CONFIG.EMOTE_MUSIC_VOLUME
            sound.RollOffMode = Enum.RollOffMode.Linear
            sound.RollOffMaxDistance = 50
            sound.Looped = true
            sound.Parent = head
            sound:Play()
            BotEmoteSounds[bot.id] = sound
        end
    end
    
    return track, sound
end

local function stopEmote(bot, track)
    if track then pcall(function() track:Stop(); track:Destroy() end) end
    
    if BotEmoteSounds[bot.id] then
        pcall(function() 
            BotEmoteSounds[bot.id]:Stop()
            BotEmoteSounds[bot.id]:Destroy()
        end)
        BotEmoteSounds[bot.id] = nil
    end
end

local function getRandomEmote(category)
    local pool = EMOTE_CATEGORIES[category] or EMOTE_CATEGORIES.dance
    return pool[math.random(1, #pool)]
end

local function trySyncEmote(bot)
    if math.random() > CONFIG.EMOTE_SYNC_CHANCE then return nil end
    
    local hrp = getRoot(bot.character)
    if not hrp then return nil end
    
    for _, otherBot in pairs(Bots) do
        if otherBot ~= bot and otherBot.alive and otherBot.state == "Dance" and otherBot.character then
            local otherHrp = getRoot(otherBot.character)
            if otherHrp and dist(hrp.Position, otherHrp.Position) < 15 then
                if otherBot._currentEmote then
                    return otherBot._currentEmote
                end
            end
        end
    end
    return nil
end

-- ══════════════════════════════════════════════════════════════
--  BOT METATABLE & STATE CONTROL
-- ══════════════════════════════════════════════════════════════
local BotMeta = {}
BotMeta.__index = BotMeta

function BotMeta:setState(newState)
    if self.state == newState then return end
    self.state = newState; self.stateTick = (self.stateTick or 0)+1; self.interruptPath = true
end

function BotMeta:pickNextState()
    local p = self.personality
    local pool = {
        {state="Wander",   w=3},
        {state="Idle",     w=2 + p.laziness*3},
        {state="Inspect",  w=p.curiosity*3},
        {state="Interact", w=p.curiosity*2},
        {state="Follow",   w=p.sociability*2},
        {state="Sit",      w=p.laziness*2},
        {state="Dance",    w=CONFIG.EMOTE_DANCE_CHANCE * 10},
        {state="Spectate", w=0.5},
        {state="Friend",   w=p.sociability*1.5},
        {state="Objective",w=2.5},
    }
    if self.isAdmin then pool[#pool+1]={state="Admin", w=1.5} end
    if p.aggression > 0.45 then
        local hrp = getRoot(self.character)
        if hrp and #nearbyBots(hrp.Position,25,self) > 0 then pool[#pool+1]={state="__COMBAT__",w=p.aggression*4} end
    end
    if math.random() < CONFIG.DISCONNECT_CHANCE then return "Disconnect" end
    local total = 0; for _,e in ipairs(pool) do total+=e.w end
    local roll = math.random()*total; local cum = 0
    for _,e in ipairs(pool) do
        cum += e.w
        if roll <= cum then
            if e.state == "__COMBAT__" then self:tryStartCombat(); return "Combat" end
            return e.state
        end
    end
    return "Wander"
end

function BotMeta:tryStartCombat()
    local hrp = getRoot(self.character); if not hrp then return end
    local candidates = {}
    for _,b in ipairs(nearbyBots(hrp.Position,25,self)) do
        if DETECTED_GAME == "jailbreak" or DETECTED_GAME == "prisonlife" then
            if b.role ~= self.role then candidates[#candidates+1]=b end
        elseif not self.friends[b.id] then
            candidates[#candidates+1]=b
        end
    end
    for _,p in ipairs(nearbyRealPlayers(hrp.Position,25)) do candidates[#candidates+1]=p end
    if #candidates > 0 then self.combatTarget = candidates[randInt(1,#candidates)] end
end

function BotMeta:pickFollowTarget()
    local hrp = getRoot(self.character); if not hrp then return nil end
    for id in pairs(self.friends) do
        local f = Bots[id]; if f and f.alive and f.character then return f end
    end
    local plrs = nearbyRealPlayers(hrp.Position, 40)
    if #plrs > 0 then return plrs[randInt(1,#plrs)] end
    local near = nearbyBots(hrp.Position, 40, self)
    if #near > 0 then return near[randInt(1,#near)] end
    return nil
end

function BotMeta:startConversation(other)
    if self.inConversation or (other and other.inConversation) then return end
    self.inConversation=true; if other then other.inConversation=true end
    local exchanges = randInt(2, CONFIG.CONVO_MAX_EXCHANGES)
    local q, a = self, other
    task.spawn(function()
        for _ = 1, exchanges do
            task.wait(randFloat(CONFIG.CONVO_REPLY_DELAY_MIN, CONFIG.CONVO_REPLY_DELAY_MAX))
            if not q or not q.alive then break end
            botSay(q, "convo_question")
            task.wait(randFloat(CONFIG.CONVO_REPLY_DELAY_MIN, CONFIG.CONVO_REPLY_DELAY_MAX))
            if a and a.alive then botSay(a, "convo_respond") end
            q, a = a, q
        end
        self.inConversation=false; if other then other.inConversation=false end
    end)
end

function BotMeta:startChatLoop()
    task.spawn(function()
        while self.alive do
            task.wait(randFloat(CONFIG.CHAT_INTERVAL_MIN, CONFIG.CHAT_INTERVAL_MAX))
            if not self.alive then break end
            if not self.inConversation then
                local hrp = getRoot(self.character)
                if hrp and math.random() < CONFIG.CONVO_CHANCE then
                    local near = nearbyBots(hrp.Position, 20, self)
                    if #near > 0 then self:startConversation(near[randInt(1,#near)]) else botSay(self,"idle") end
                else
                    local gamePools = GAME_CHAT[DETECTED_GAME]
                    if gamePools and gamePools.game_unique and math.random() < 0.4 then
                        botSay(self, "game_unique")
                    else
                        botSay(self, "idle")
                    end
                end
            end
        end
    end)
end

function BotMeta:bindWitnessSystem()
    task.spawn(function()
        while self.alive do
            task.wait(2)
            if not self.alive then break end
            local hrp = getRoot(self.character); if not hrp then continue end
            local foundDead = false
            for _, b in pairs(Bots) do
                if b~=self and not b.alive and b.character then
                    local oHrp = getRoot(b.character)
                    if oHrp and dist(hrp.Position, oHrp.Position) < 30 then foundDead=true; break end
                end
            end
            if not foundDead then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health<=0 then
                        local pHrp = getRoot(p.Character)
                        if pHrp and dist(hrp.Position, pHrp.Position) < 30 then foundDead=true; break end
                    end
                end
            end
            if foundDead and math.random() < 0.4 then
                task.delay(randFloat(0.5,2), function() if self.alive then botSay(self,"witness") end end)
            end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  STATE HANDLERS
-- ══════════════════════════════════════════════════════════════
local StateHandlers = {}

function StateHandlers.Vehicle(bot)
    if bot.statusLabel then bot.statusLabel.Text=STATUS_ICONS.Vehicle end
    local hum = getHum(bot.character)
    if hum then hum.WalkSpeed=0 end
    task.wait(5); if bot.alive then bot:setState("Wander") end
end

function StateHandlers.Wander(bot)
    if bot.statusLabel then bot.statusLabel.Text=STATUS_ICONS.Wander end
    local hrp, hum = getRoot(bot.character), getHum(bot.character)
    if not hrp then bot:setState("Idle"); return end
    if hum then hum.WalkSpeed = math.random()<CONFIG.SPRINT_CHANCE and CONFIG.RUN_SPEED or CONFIG.WALK_SPEED end
    bot.interruptPath=false
    walkTo(bot, randomWanderTarget(hrp.Position))
    bot:setState(bot:pickNextState())
end

function StateHandlers.Idle(bot)
    if bot.statusLabel then bot.statusLabel.Text=STATUS_ICONS.Idle end
    local hum = getHum(bot.character); if hum then hum.WalkSpeed=0 end
    local startTick = bot.stateTick; local dur = randFloat(CONFIG.IDLE_MIN, CONFIG.IDLE_MAX)
    task.delay(randFloat(1,dur*0.5), function()
        if bot.alive and bot.stateTick==startTick then
            local r = getRoot(bot.character)
            if r then r.CFrame = r.CFrame * CFrame.Angles(0,randFloat(0,math.pi*2),0) end
        end
    end)
    task.delay(randFloat(2,dur*0.7), function()
        if bot.alive and bot.stateTick==startTick then playEmote(bot,"Wave") end
    end)
    local elapsed=0
    while elapsed<dur and bot.alive and bot.stateTick==startTick do task.wait(0.5); elapsed+=0.5 end
    if bot.stateTick==startTick then bot:setState(bot:pickNextState()) end
end

function StateHandlers.Sit(bot)
    if bot.statusLabel then bot.statusLabel.Text=STATUS_ICONS.Sit end
    botSay(bot,"sit")
    local hum, hrp = getHum(bot.character), getRoot(bot.character)
    local startTick = bot.stateTick
    if hrp then
        local best, bestDist = nil, 25
        for _, obj in ipairs(CachedInteractables) do
            if (obj:IsA("Seat") or obj:IsA("VehicleSeat")) and not obj.Occupant then
                local d = dist(obj.Position, hrp.Position)
                if d < bestDist then best=obj; bestDist=d end
            end
        end
        if best then
            bot.interruptPath=false; walkTo(bot, best.Position)
            if hum and bot.stateTick==startTick then pcall(function() best:Sit(hum) end) end
        else
            if hum then hum.Sit=true end
        end
    end
    local dur=randFloat(CONFIG.SIT_MIN,CONFIG.SIT_MAX); local elapsed=0
    while elapsed<dur and bot.alive and bot.stateTick==startTick do task.wait(0.5); elapsed+=0.5 end
    if hum then hum.Sit=false end
    if bot.stateTick==startTick then bot:setState(bot:pickNextState()) end
end

function StateHandlers.Dance(bot)
    if not CONFIG.EMOTE_ENABLED then bot:setState("Wander"); return end
    if bot.statusLabel then bot.statusLabel.Text=STATUS_ICONS.Dance end
    local hum = getHum(bot.character); if hum then hum.WalkSpeed=0 end
    
    local emoteName = trySyncEmote(bot)
    if not emoteName then
        emoteName = getRandomEmote("dance")
    end
    bot._currentEmote = emoteName
    
    botSay(bot,"dance")
    
    local startTick = bot.stateTick
    
    local track, sound = playEmoteWithMusic(bot, emoteName, true)
    
    local dur = randFloat(CONFIG.EMOTE_DURATION_MIN, CONFIG.EMOTE_DURATION_MAX)
    local elapsed = 0
    
    while elapsed < dur and bot.alive and bot.stateTick == startTick do
        task.wait(0.5)
        elapsed += 0.5
        
        if math.random() < 0.03 then
            botSay(bot, "dance")
        end
    end
    
    stopEmote(bot, track)
    bot._currentEmote = nil
    
    if bot.stateTick == startTick then bot:setState(bot:pickNextState()) end
end

function StateHandlers.Follow(bot)
    if bot.statusLabel then bot.statusLabel.Text=STATUS_ICONS.Follow end
    local target = bot:pickFollowTarget()
    if not target then bot:setState("Wander"); return end
    local hum = getHum(bot.character); if hum then hum.WalkSpeed=CONFIG.WALK_SPEED end
    local followTime=randFloat(15,45); local elapsed=0; local startTick=bot.stateTick
    while elapsed<followTime and bot.alive and bot.stateTick==startTick do
        local tChar = target.Character or target.character
        local tRoot = tChar and getRoot(tChar)
        local myRoot = getRoot(bot.character)
        if not tRoot or not myRoot then break end
        if dist(myRoot.Position, tRoot.Position) > 5 then
            bot.interruptPath=false; walkTo(bot, tRoot.Position)
        else task.wait(0.5) end
        elapsed+=0.5
        if math.random()<0.015 then botSay(bot,"idle") end
    end
    if bot.stateTick==startTick then bot:setState(bot:pickNextState()) end
end

function StateHandlers.Combat(bot)
    if bot.statusLabel then bot.statusLabel.Text=STATUS_ICONS.Combat end
    local hum = getHum(bot.character)
    if not hum then bot:setState("Wander"); return end
    hum.WalkSpeed = CONFIG.RUN_SPEED
    local target = bot.combatTarget
    if not target then bot:setState("Wander"); return end
    if math.random()<0.5 then botSay(bot,"taunt") end
    local lastMelee, giveUp, startTick = 0, 0, bot.stateTick
    local damageMod = 1.0
    if CONFIG.DYNAMIC_DIFFICULTY then
        local avgPlayerKills, count = 0, 0
        for _,p in ipairs(Players:GetPlayers()) do
            local stats = PlayerStatsCache[p.UserId]
            if stats then avgPlayerKills+=stats.kills; count+=1 end
        end
        if count>0 then
            avgPlayerKills = avgPlayerKills/count
            if avgPlayerKills>5 then damageMod=1.2 elseif avgPlayerKills<1 then damageMod=0.8 end
        end
    end
    while bot.alive and bot.stateTick==startTick do
        local tChar = target.character or target.Character
        local tHum, tRoot = tChar and getHum(tChar), tChar and getRoot(tChar)
        local myRoot = getRoot(bot.character)
        if not tHum or (tHum.Health<=0) then
            if target:IsA("Player") and (not tChar or not tHum or tHum.Health<=0) then
                botSay(bot,"kill")
                if math.random()<0.5 then task.delay(0.8,function() if bot.alive then botSay(bot,"laugh") end end) end
                bot.kills+=1; bot.combatTarget=nil; bot:setState("Wander"); break
            end
        end
        if not tRoot then bot:setState("Wander"); break end
        if hum.Health/hum.MaxHealth <= CONFIG.RETREAT_HP_PERCENT and math.random() < bot.personality.cowardice*1.5 then
            bot:setState("Retreat"); break
        end
        if dist(myRoot.Position, tRoot.Position) > CONFIG.ATTACK_RANGE then
            hum:MoveTo(tRoot.Position)
        else
            local now = tick()
            if now - lastMelee >= CONFIG.MELEE_COOLDOWN then
                lastMelee = now
                if bot.equippedTool and bot.equippedTool:FindFirstChild("Handle") then
                    pcall(function() tHum:TakeDamage(CONFIG.DAMAGE_PER_HIT*damageMod*CONFIG.RANGE_DAMAGE_MULTIPLIER) end)
                else
                    pcall(function() tHum:TakeDamage(CONFIG.DAMAGE_PER_HIT*damageMod) end)
                end
            end
        end
        giveUp+=0.2
        if giveUp>30 then bot.combatTarget=nil; bot:setState("Wander"); break end
        task.wait(0.2)
    end
end

function StateHandlers.Retreat(bot)
    if bot.statusLabel then bot.statusLabel.Text=STATUS_ICONS.Retreat end
    local hrp, hum = getRoot(bot.character), getHum(bot.character)
    if not hrp or not hum then bot:setState("Wander"); return end
    botSay(bot,"panic"); hum.WalkSpeed=CONFIG.RUN_SPEED
    local startTick=bot.stateTick; local fleeDir=Vector3.new(randSign(),0,randSign()).Unit
    local target=bot.combatTarget
    if target then
        local tChar=target.character or target.Character
        local tRoot=tChar and getRoot(tChar)
        if tRoot then fleeDir=(hrp.Position-tRoot.Position).Unit end
    end
    bot.combatTarget=nil; bot.interruptPath=false
    walkTo(bot, hrp.Position+fleeDir*randFloat(30,60))
    local elapsed=0
    while elapsed<3 and bot.alive and bot.stateTick==startTick do task.wait(0.5); elapsed+=0.5 end
    if bot.stateTick==startTick then bot:setState("Idle") end
end

function StateHandlers.Panic(bot)
    if bot.statusLabel then bot.statusLabel.Text=STATUS_ICONS.Panic end
    local hum=getHum(bot.character); if hum then hum.WalkSpeed=CONFIG.RUN_SPEED end
    botSay(bot,"panic")
    local elapsed=0; local startTick=bot.stateTick
    while elapsed<CONFIG.PANIC_DURATION and bot.alive and bot.stateTick==startTick do
        local hrp=getRoot(bot.character)
        if hrp and hum then
            local dest=randomWanderTarget(hrp.Position)
            hum:MoveTo(Vector3.new(dest.X,hrp.Position.Y,dest.Z))
        end
        task.wait(0.8); elapsed+=0.8
    end
    if bot.stateTick==startTick then bot:setState("Idle") end
end

function StateHandlers.Inspect(bot)
    if bot.statusLabel then bot.statusLabel.Text=STATUS_ICONS.Inspect end
    local hum,hrp=getHum(bot.character),getRoot(bot.character)
    if hum then hum.WalkSpeed=CONFIG.WALK_SPEED*0.5 end
    if not hrp then bot:setState("Wander"); return end
    local cands={}
    for _,obj in ipairs(CachedInteractables) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(bot.character) then
            local d=dist(obj.Position,hrp.Position)
            if d<50 and d>3 then cands[#cands+1]=obj end
        end
    end
    local startTick=bot.stateTick
    if #cands>0 then
        bot.interruptPath=false; walkTo(bot, cands[randInt(1,#cands)].Position)
        if hum then hum.WalkSpeed=0 end
        playEmote(bot,"Point")
        local dur,elapsed=randFloat(3,8),0
        while elapsed<dur and bot.alive and bot.stateTick==startTick do task.wait(0.5); elapsed+=0.5 end
    end
    if bot.stateTick==startTick then bot:setState(bot:pickNextState()) end
end

function StateHandlers.Interact(bot)
    if bot.statusLabel then bot.statusLabel.Text=STATUS_ICONS.Interact end
    local hrp=getRoot(bot.character); if not hrp then bot:setState("Wander"); return end
    local entry=bot._interactTarget; bot._interactTarget=nil
    if not entry or not entry.object or not entry.object.Parent then bot:setState("Wander"); return end
    local startTick=bot.stateTick
    if botInteractWith(bot, entry) then
        local hum=getHum(bot.character); if hum then hum.WalkSpeed=0 end
        local dur,elapsed=randFloat(1,3),0
        while elapsed<dur and bot.alive and bot.stateTick==startTick do task.wait(0.5); elapsed+=0.5 end
    end
    if bot.stateTick==startTick then bot:setState(bot:pickNextState()) end
end

function StateHandlers.Spectate(bot)
    if bot.statusLabel then bot.statusLabel.Text=STATUS_ICONS.Spectate end
    local hum,hrp=getHum(bot.character),getRoot(bot.character)
    if hum then hum.WalkSpeed=0 end
    local startTick=bot.stateTick
    if hrp then
        local near=nearbyBots(hrp.Position,40,bot)
        if #near>0 then
            local wRoot=getRoot(near[randInt(1,#near)].character)
            if wRoot then hrp.CFrame=CFrame.lookAt(hrp.Position,wRoot.Position) end
        end
    end
    task.delay(randFloat(2,5),function() if bot.alive and bot.stateTick==startTick then botSay(bot,"witness") end end)
    local elapsed=0
    while elapsed<CONFIG.SPECTATE_DURATION and bot.alive and bot.stateTick==startTick do task.wait(0.5); elapsed+=0.5 end
    if bot.stateTick==startTick then bot:setState("Wander") end
end

function StateHandlers.Friend(bot)
    if bot.statusLabel then bot.statusLabel.Text=STATUS_ICONS.Friend end
    local hum,hrp=getHum(bot.character),getRoot(bot.character)
    if hum then hum.WalkSpeed=CONFIG.WALK_SPEED end
    if not hrp then bot:setState("Wander"); return end
    local near=nearbyBots(hrp.Position,30,bot)
    if #near==0 then bot:setState("Wander"); return end
    local candidate=near[randInt(1,#near)]
    local cRoot=getRoot(candidate.character)
    if cRoot then
        bot.interruptPath=false; walkTo(bot, cRoot.Position)
        if math.random()<CONFIG.FRIEND_FORM_CHANCE then
            bot.friends[candidate.id]=true; candidate.friends[bot.id]=true
        end
        bot:startConversation(candidate)
    end
    bot:setState("Wander")
end

function StateHandlers.Admin(bot)
    if not bot.isAdmin then bot:setState("Wander"); return end
    if bot.statusLabel then bot.statusLabel.Text=STATUS_ICONS.Admin end
    local hrp=getRoot(bot.character); if not hrp then bot:setState("Wander"); return end

    -- Gather ALL possible targets: real players + non-admin bots
    local targets = {}
    for _, p in ipairs(nearbyRealPlayers(hrp.Position, 60)) do
        targets[#targets+1] = {entity = p, isBot = false}
    end
    for _, b in ipairs(nearbyBots(hrp.Position, 60, bot)) do
        if not b.isAdmin then
            targets[#targets+1] = {entity = b, isBot = true}
        end
    end

    if #targets == 0 then
        -- No targets nearby, use self-targeting commands
        local selfCommands = {"patrick", "killallbots"}
        local cmd = selfCommands[math.random(1, #selfCommands)]
        if cmd == "patrick" then summonPatrickCmd(bot)
        elseif cmd == "killallbots" then killAllBotsCmd(bot) end
        bot:setState("Wander")
        return
    end

    -- Pick a random target (50/50 bot vs player weighted by what's available)
    local chosen = targets[randInt(1, #targets)]
    local tgt = chosen.entity
    local startTick = bot.stateTick

    -- Walk toward target
    if chosen.isBot then
        local tRoot = getRoot(tgt.character)
        if tRoot then
            local hum=getHum(bot.character); if hum then hum.WalkSpeed=CONFIG.WALK_SPEED end
            bot.interruptPath=false; walkTo(bot, tRoot.Position)
        end
    else
        local tRoot = tgt.Character and getRoot(tgt.Character)
        if tRoot then
            local hum=getHum(bot.character); if hum then hum.WalkSpeed=CONFIG.WALK_SPEED end
            bot.interruptPath=false; walkTo(bot, tRoot.Position)
        end
    end

    if bot.stateTick==startTick then
        botUseAdminCommand(bot, tgt)
    end
    local elapsed=0
    while elapsed<3 and bot.alive and bot.stateTick==startTick do task.wait(0.5); elapsed+=0.5 end
    if bot.stateTick==startTick then bot:setState("Wander") end
end

-- ══════════════════════════════════════════════════════════════
--  GAME-SPECIFIC STATE: OBJECTIVE
-- ══════════════════════════════════════════════════════════════
function StateHandlers.Objective(bot)
    local iconKey = ({
        ["jailbreak"]     = bot.role=="Police" and "Patrol" or "Heist",
        ["prisonlife"]    = bot.role=="Guard" and "Patrol" or "Escape",
        ["99nights"]      = "Surviving",
        ["luckyblocks"]   = "Hunting",
        ["identityfraud"] = "Solving",
    })[DETECTED_GAME] or "Wander"

    if bot.statusLabel then bot.statusLabel.Text = STATUS_ICONS[iconKey] or STATUS_ICONS.Wander end

    local hrp, hum = getRoot(bot.character), getHum(bot.character)
    if not hrp or not hum then bot:setState("Wander"); return end

    local objectivePos = getGameObjective(bot, DETECTED_GAME)
    local startTick = bot.stateTick

    if DETECTED_GAME == "99nights" then
        hum.WalkSpeed = CONFIG.WALK_SPEED
        if math.random() < 0.5 then botSay(bot, "idle") end
        if objectivePos then
            bot.interruptPath = false
            walkTo(bot, objectivePos)
        else
            walkTo(bot, randomWanderTarget(hrp.Position))
        end
        if math.random() < 0.15 then
            botSay(bot, "scare")
            bot:setState("Panic")
            return
        end
        task.wait(randFloat(3, 8))

    elseif DETECTED_GAME == "luckyblocks" then
        hum.WalkSpeed = CONFIG.RUN_SPEED
        botSay(bot, "break_block")
        if objectivePos then
            bot.interruptPath = false
            walkTo(bot, objectivePos)
            task.wait(1)
            if bot.alive and bot.stateTick == startTick then
                botSay(bot, "game_unique")
                local nearBlocks = {}
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Name:lower():find("lucky") then
                        if dist(obj.Position, hrp.Position) < 10 then
                            nearBlocks[#nearBlocks+1] = obj
                        end
                    end
                end
                if #nearBlocks > 0 then
                    local block = nearBlocks[math.random(1,#nearBlocks)]
                    local cd = block:FindFirstChildOfClass("ClickDetector")
                    if cd then pcall(function() cd.MouseClick:Fire(nil) end) end
                    local pp = block:FindFirstChildOfClass("ProximityPrompt")
                    if pp then pcall(function() pp.Triggered:Fire(nil) end) end
                end
            end
        else
            walkTo(bot, randomWanderTarget(hrp.Position))
        end
        task.wait(randFloat(2,5))

    elseif DETECTED_GAME == "identityfraud" then
        hum.WalkSpeed = CONFIG.WALK_SPEED
        if math.random() < 0.3 then botSay(bot, "idle") end
        if math.random() < 0.12 then
            botSay(bot, "suspicious")
            task.wait(0.5)
            if math.random() < 0.5 then
                bot:setState("Panic"); return
            end
        end
        if objectivePos then
            bot.interruptPath = false
            walkTo(bot, objectivePos)
        else
            walkTo(bot, randomWanderTarget(hrp.Position))
        end
        task.wait(randFloat(4, 10))

    elseif DETECTED_GAME == "jailbreak" then
        if bot.role == "Criminal" then
            hum.WalkSpeed = CONFIG.RUN_SPEED
            botSay(bot, "heist")
            if objectivePos then
                bot.interruptPath = false
                walkTo(bot, objectivePos)
                task.wait(randFloat(5,12))
                if bot.alive and bot.stateTick == startTick then
                    botSay(bot, "economy")
                end
            else
                walkTo(bot, randomWanderTarget(hrp.Position))
                task.wait(3)
            end
        else
            hum.WalkSpeed = CONFIG.WALK_SPEED
            botSay(bot, "arrest")
            local criminals = {}
            for _, b in pairs(Bots) do
                if b~=bot and b.alive and b.role=="Criminal" and b.character then
                    local bRoot = getRoot(b.character)
                    if bRoot and dist(bRoot.Position, hrp.Position) < 80 then
                        criminals[#criminals+1] = b
                    end
                end
            end
            if #criminals > 0 and math.random() < 0.5 then
                local target = criminals[randInt(1,#criminals)]
                bot.combatTarget = target
                bot:setState("Combat"); return
            end
            walkTo(bot, objectivePos or randomWanderTarget(hrp.Position))
            task.wait(randFloat(4,8))
        end

    elseif DETECTED_GAME == "prisonlife" then
        if bot.role == "Prisoner" then
            hum.WalkSpeed = CONFIG.WALK_SPEED
            botSay(bot, "escape_plan")
            if objectivePos then
                bot.interruptPath = false
                walkTo(bot, objectivePos)
                task.wait(randFloat(4,10))
            else
                walkTo(bot, randomWanderTarget(hrp.Position))
                task.wait(3)
            end
        else
            hum.WalkSpeed = CONFIG.WALK_SPEED
            botSay(bot, "guard_talk")
            local prisoners = {}
            for _, b in pairs(Bots) do
                if b~=bot and b.alive and b.role=="Prisoner" and b.character then
                    local bRoot = getRoot(b.character)
                    if bRoot and dist(bRoot.Position, hrp.Position) < 50 then
                        prisoners[#prisoners+1] = b
                    end
                end
            end
            if #prisoners > 0 and math.random() < 0.45 then
                local target = prisoners[randInt(1,#prisoners)]
                bot.combatTarget = target
                bot:setState("Combat"); return
            end
            walkTo(bot, objectivePos or randomWanderTarget(hrp.Position))
            task.wait(randFloat(3,7))
        end

    else
        hum.WalkSpeed = CONFIG.WALK_SPEED
        walkTo(bot, randomWanderTarget(hrp.Position))
        task.wait(3)
    end

    if bot.stateTick == startTick then bot:setState(bot:pickNextState()) end
end

-- ══════════════════════════════════════════════════════════════
--  MAIN AI LOOP
-- ══════════════════════════════════════════════════════════════
local function runBot(bot)
    while bot.alive do
        if not bot.character or not bot.character.Parent then break end
        local state = bot.state
        if state == "Disconnect" then
            botSay(bot,"disconnect")
            print(string.format("◀  %s left the game", bot.name))
            bot.alive=false
            task.delay(0.5,function() if bot.character and bot.character.Parent then bot.character:Destroy() end end)
            task.delay(randFloat(CONFIG.DISCONNECT_REJOIN_MIN,CONFIG.DISCONNECT_REJOIN_MAX), function()
                if Bots[bot.id] then print(string.format("▶  %s reconnected", bot.name)); spawnBot(bot) end
            end)
            return
        end
        local handler = StateHandlers[state]
        if handler then
            local ok, err = pcall(handler, bot)
            if not ok then warn("[LambdaPlayers] "..bot.name.." ("..state.."): "..tostring(err)); bot:setState("Wander") end
        else
            bot:setState("Wander")
        end
        task.wait(0.05)
    end
end

-- ══════════════════════════════════════════════════════════════
--  SPAWN POINT SYSTEM
-- ══════════════════════════════════════════════════════════════
local function getAllSpawnPoints()
    local points = {}
    local function search(parent)
        for _,child in ipairs(parent:GetChildren()) do
            if child:IsA("SpawnLocation") then points[#points+1]=child end
            if child:IsA("Model") or child:IsA("Folder") then search(child) end
        end
    end
    search(Workspace)
    return points
end

local function getGameSpawnCF(role)
    if DETECTED_GAME == "jailbreak" or DETECTED_GAME == "prisonlife" then
        local points = getAllSpawnPoints()
        local teamPoints = {}
        for _, sp in ipairs(points) do
            local spName = sp.Name:lower()
            if role == "Criminal" or role == "Prisoner" then
                if spName:find("criminal") or spName:find("prisoner") or spName:find("jail") or spName:find("spawn") then
                    teamPoints[#teamPoints+1] = sp
                end
            elseif role == "Police" or role == "Guard" then
                if spName:find("police") or spName:find("guard") or spName:find("cop") or spName:find("spawn") then
                    teamPoints[#teamPoints+1] = sp
                end
            end
        end
        if #teamPoints > 0 then
            local chosen = teamPoints[math.random(1,#teamPoints)]
            local ox = randFloat(-chosen.Size.X*0.4, chosen.Size.X*0.4)
            local oz = randFloat(-chosen.Size.Z*0.4, chosen.Size.Z*0.4)
            return CFrame.new(chosen.CFrame * Vector3.new(ox, chosen.Size.Y*0.5+4, oz))
        end
    end
    return nil
end

getSpawnCF = function(role)
    local gameCF = getGameSpawnCF(role)
    if gameCF then return gameCF end
    local points = getAllSpawnPoints()
    if #points > 0 then
        local chosen
        for _ = 1,5 do
            local candidate = points[math.random(1,#points)]
            if candidate.Enabled ~= false then
                if chosen==nil or not candidate.TeamColor then chosen=candidate; if not candidate.TeamColor then break end end
            end
        end
        if not chosen then chosen=points[math.random(1,#points)] end
        local ox=randFloat(-chosen.Size.X*0.4, chosen.Size.X*0.4)
        local oz=randFloat(-chosen.Size.Z*0.4, chosen.Size.Z*0.4)
        local worldPos = chosen.CFrame * Vector3.new(ox, chosen.Size.Y*0.5+4, oz)
        return CFrame.new(worldPos)
    end
    local baseplate = Workspace:FindFirstChild("Baseplate")
    if baseplate and baseplate:IsA("BasePart") then
        return CFrame.new(randFloat(-baseplate.Size.X*0.3,baseplate.Size.X*0.3), baseplate.Position.Y+baseplate.Size.Y*0.5+4, randFloat(-baseplate.Size.Z*0.3,baseplate.Size.Z*0.3))
    end
    return CFrame.new(randFloat(-60,60), 6, randFloat(-60,60))
end

spawnBot = function(bot)
    local char, hum, hrp, head, animator, rigType = buildCharacter(bot.name)

    if CONFIG.ENABLE_TEAMS and #Teams:GetChildren() > 0 then
        local team = Teams:GetChildren()[math.random(1,#Teams:GetChildren())]
        if team:IsA("Team") then
            char.PrimaryPart.BrickColor = team.TeamColor
        end
    end

    char.Parent = Workspace
    char:SetPrimaryPartCFrame(getSpawnCF(bot.role))
    bot.character=char; bot.animator=animator; bot.alive=true
    bot.state="Wander"; bot.stateTick=1; bot.combatTarget=nil
    bot.interruptPath=false; bot.inConversation=false
    bot.kills=bot.kills or 0; bot.deaths=bot.deaths or 0; bot.equippedTool=nil
    bot.statusLabel=(CONFIG.SHOW_NAMEPLATE and head) and buildNameplate(head,bot) or {Text=""}

    if CONFIG.ANNOUNCE_JOINS then
        print(string.format("▶  %s [%s] joined the game", bot.name, bot.role or "Player"))
    end
    
    local stopAnims = bindAnimations(char, hum, animator, rigType or "R6")
    attachVoiceSound(head)

    if CONFIG.TOOL_PICKUP_ENABLED then
        task.delay(randFloat(3,10), function()
            if not bot.alive then return end
            -- v4.3: chance to spawn with the Crucible sword instead of a generic tool
            if CONFIG.SWORD_ENABLED and math.random() < (CONFIG.SWORD_CHANCE or 0.2) then
                equipCrucibleSword(bot)
                return
            end
            local tools = getAvailableTools()
            if #tools>0 then equipTool(bot, tools[math.random(1,#tools)]) end
        end)
    end
    -- v4.3: also give a chance to acquire the sword later via maybeEquipSword()
    maybeEquipSword(bot)

    bindKillBind(bot); bindInteractionScanner(bot)

    hum.Died:Connect(function()
        bot.alive=false; bot.deaths+=1
        if stopAnims then pcall(stopAnims) end
        -- v4.3: cleanup Crucible controller if bot had a sword
        if bot.equippedTool and bot.equippedTool.Name == "Crucible" then
            local ctrl = CrucibleControllers[bot.equippedTool]
            if ctrl then ctrl:destroy() end
        end
        unequipTool(bot); botSay(bot,"death")
        stopEmote(bot, nil)
        print(string.format("✕  %s [%s]  (K:%d / D:%d)", bot.name, bot.role or "?", bot.kills, bot.deaths))
        task.delay(3,function() if char and char.Parent then char:Destroy() end end)
        task.delay(CONFIG.BOT_RESPAWN_DELAY, function() if Bots[bot.id] then spawnBot(bot) end end)
    end)
    hum:GetPropertyChangedSignal("Health"):Connect(function()
        if not bot.alive then return end
        if hum.Health<hum.MaxHealth*0.75 and math.random()<0.2 and bot.state~="Combat" then botSay(bot,"fall") end
        if hum.Health<hum.MaxHealth*0.18 and bot.state~="Panic" and bot.state~="Retreat" then bot:setState("Panic") end
    end)
    task.spawn(function()
        while bot.alive do
            task.wait(0.5)
            if bot.state=="Combat" and bot.equippedTool then
                -- v4.3: Crucible sword auto-attack takes priority over generic tool
                if bot.equippedTool.Name == "Crucible" then
                    crucibleSwing(bot)
                else
                    if math.random()<CONFIG.TOOL_USE_CHANCE then activateTool(bot) end
                    if math.random()<CONFIG.TOOL_DROP_CHANCE then unequipTool(bot) end
                end
            end
            if CONFIG.ENABLE_ECONOMY_SIM and math.random()<0.01 then botSay(bot,"economy") end
        end
    end)
    bot:startChatLoop(); bot:bindWitnessSystem()
    task.spawn(function() runBot(bot) end)
end

-- ══════════════════════════════════════════════════════════════
--  BOT FACTORY
-- ══════════════════════════════════════════════════════════════
local function createBot()
    nextBotId += 1
    local role = assignRole(DETECTED_GAME)
    local p = randPersonality()
    if role == "Police" or role == "Guard" then
        p.aggression = clamp(p.aggression + 0.2, 0, 1)
        p.cowardice  = clamp(p.cowardice  - 0.1, 0, 1)
    elseif role == "Criminal" or role == "Prisoner" then
        p.cowardice  = clamp(p.cowardice  + 0.15, 0, 1)
        p.curiosity  = clamp(p.curiosity  + 0.1,  0, 1)
    end
    local bot = setmetatable({
        id=nextBotId, name=getRandomName(), alive=false, character=nil, animator=nil,
        state="Wander", stateTick=0, combatTarget=nil, interruptPath=false,
        personality=p, friends={}, kills=0, deaths=0,
        isAdmin=math.random()<CONFIG.ADMIN_CHANCE, inConversation=false,
        equippedTool=nil, _interactTarget=nil, statusLabel={Text=""},
        role=role,
    }, BotMeta)
    Bots[bot.id] = bot
    task.spawn(function() spawnBot(bot) end)
    return bot
end

-- ══════════════════════════════════════════════════════════════
--  SYSTEMS & MANAGERS
-- ══════════════════════════════════════════════════════════════

-- Friend-Defend Background System
task.spawn(function()
    while true do
        task.wait(1)
        for _, bot in pairs(Bots) do
            if bot and bot.alive and bot.character then
                for friendId in pairs(bot.friends) do
                    local friend = Bots[friendId]
                    if friend and friend.alive and friend.state=="Combat" and friend.combatTarget and bot.state~="Combat" and bot.state~="Retreat" then
                        local bHrp,fHrp=getRoot(bot.character),getRoot(friend.character)
                        if bHrp and fHrp and dist(bHrp.Position,fHrp.Position)<55 and math.random()<0.4 then
                            bot.combatTarget=friend.combatTarget; bot:setState("Combat"); botSay(bot,"assist")
                        end
                    end
                end
            end
        end
    end
end)

-- Player Stat Tracking (Dynamic Difficulty)
Players.PlayerAdded:Connect(function(plr)
    PlayerStatsCache[plr.UserId]={kills=0,deaths=0}
    task.wait(randFloat(1,4))
    for _,bot in pairs(Bots) do
        if bot and bot.alive and math.random()<0.35 then botSay(bot,"idle"); break end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    PlayerStatsCache[plr.UserId]=nil
    task.wait(randFloat(0.5,2))
    local lines={plr.Name.." really just left lmao","bye "..plr.Name,"there goes "..plr.Name,"rip "..plr.Name.." o7",plr.Name.." got scared and left"}
    for _,bot in pairs(Bots) do
        if bot and bot.alive and math.random()<0.3 then botSay(bot,"idle",lines[randInt(1,#lines)]); break end
    end
end)

-- Population Manager
task.spawn(function()
    for _ = 1, CONFIG.MAX_BOTS do task.wait(randFloat(0.5,2.5)); createBot() end
    while true do
        task.wait(6); local live=0
        for _ in pairs(Bots) do live+=1 end
        for _ = 1, CONFIG.MAX_BOTS-live do task.wait(randFloat(1,3)); createBot() end
    end
end)

-- Scoreboard
local leaderFolder = Instance.new("Folder")
leaderFolder.Name="LambdaLeaderboard"; leaderFolder.Parent=game:GetService("ServerStorage")
task.spawn(function()
    while true do
        task.wait(5)
        for _,c in ipairs(leaderFolder:GetChildren()) do c:Destroy() end
        for _,bot in pairs(Bots) do
            if bot then
                local e=Instance.new("Folder"); e.Name=bot.name
                local function iv(n,v) local x=Instance.new("IntValue"); x.Name=n; x.Value=v; x.Parent=e end
                local function sv(n,v) local x=Instance.new("StringValue"); x.Name=n; x.Value=v; x.Parent=e end
                iv("Kills",bot.kills or 0); iv("Deaths",bot.deaths or 0)
                sv("State",bot.state or ""); sv("Role",bot.role or "?")
                sv("IsAdmin",bot.isAdmin and "Yes" or "No"); sv("Game",DETECTED_GAME)
                e.Parent=leaderFolder
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  STARTUP: DETECT GAME, APPLY OVERRIDES, BUILD CHAT
-- ══════════════════════════════════════════════════════════════
task.spawn(function()
    task.wait(2)
    DETECTED_GAME = detectGameMode()

    local overrides = GAME_CONFIG_OVERRIDES[DETECTED_GAME]
    if overrides then
        for k, v in pairs(overrides) do CONFIG[k] = v end
    end

    ActiveGameChat = buildMergedChat(DETECTED_GAME)

    print("=======================================================")
    print(" Lambda Players for Roblox v4.2 — MULTI-GAME EDITION + IGOR SYSTEM")
    print(string.format(" Detected game: %s  |  Max bots: %d", DETECTED_GAME:upper(), CONFIG.MAX_BOTS))
    print(string.format(" Mode set to: %s  (CONFIG.GAME_MODE = \"%s\")", DETECTED_GAME, CONFIG.GAME_MODE))
    print(" Systems: R6/R15 | Teams | Roles | Vehicles | Tools | VC | Igor | Crucible | A*")
    print(" SpawnPoints | ProximityPrompts | ClickDetectors | Killbind")
    print(" Optimization: CollectionService | Spawn Cache | Killbind Cooldown")
    print(" Emote System with Music & Custom Dances")
    print(" Enhanced Admin System with 40+ Commands (incl. Igor System)!")
    print(" Punish:  ban, kick, unban, warn, mute")
    print(" Troll:   spawnzombie, patricksdoomshutdown, rainbowtrail,")
    print("          explode, reverse, dance, bighead, freeze, trap,")
    print("          slap, confuse, rocket, scare, blind, drunk, trip")
    print(" Powers:  speed, god, heal, invisible, tiny, spin, size")
    print(" FX:      fling, smoke, fire, earthquake, launch, orbit, chaos, fly")
    print(" Utility: tp, jail, announce, bring, killallbots, patrick")
    print(" Emote Sync: " .. (CONFIG.EMOTE_SYNC_CHANCE*100) .. "% | Music: " .. (CONFIG.EMOTE_MUSIC_ENABLED and "ON" or "OFF"))
    print(" Supported: generic | 99nights | luckyblocks | identityfraud")
    print("            jailbreak | prisonlife")
    print("=======================================================")
end)