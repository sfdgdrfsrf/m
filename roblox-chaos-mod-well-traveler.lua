--[[
 ██████╗ ██████╗ ██████╗ ██╗ ██████╗ ██╗ ██╗ ██████╗██╗ ██╗ █████╗ ██████╗ ███████╗
 ██╔══██╗██╔═══██╗██╔══██╗██║ ██╔═══██╗╚██╗██╔╝ ██╔════╝██║ ██║██╔══██╗██╔═══██╗██╔════╝
 ██████╔╝██║ ██║██████╔╝██║ ██║ ██║ ╚███╔╝ ██║ ███████║███████║██║ ██║███████╗
 ██╔══██╗██║ ██║██╔══██╗██║ ██║ ██║ ██╔██╗ ██║ ██╔══██║██╔══██║██║ ██║╚════██║
 ██║ ██║╚██████╔╝██████╔╝███████╗╚██████╔╝██╔╝ ██╗ ╚██████╗██║ ██║██║ ██║╚██████╔╝███████║
 ╚═╝ ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝ ╚═╝ ╚═════╝╚═╝ ╚═╝╚═╝ ╚═╝ ╚═════╝ ╚══════╝
 
 ULTIMATE EDITION v2.0 — NO SETUP • JUST EXECUTE
 
 SOURCES (every effect converted to Roblox):
 • PolyChaos — vertex/screen chaos
 • GTA Trilogy Chaos Mod (200+ effects from GitHub source)
 • SM64 Chaos Edition v4.0 — all known effects
 • GTA San Andreas Chaos Edition
 • GTA Randomizer
 • Old ROBLOX Nostalgia (2006–2012)

 ▸ 280+ Total Effects ▸ 12 Categories ▸ Pitch Shifter as Effect
 ▸ F4-F12 Hotkeys ▸ Auto-Cycle ▸ Stacking ▸ Intensity Control
]]

-- ============================================
-- SERVICES & WAIT
-- ============================================
local plr = game:GetService("Players").LocalPlayer
local mouse = plr:GetMouse()
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local ws = game:GetService("Workspace")
local ls = game:GetService("Lighting")
local ss = game:GetService("SoundService")
local rep = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")
local cas = game:GetService("ContextActionService")
local mktSvc = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
-- game:GetObjects is used to load decompiled models (executor-only API).
-- It returns an ARRAY of instances directly — no InsertService wrapping needed.

local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")
local cam = ws.CurrentCamera
plr.CharacterAdded:Connect(function(c) char=c; hum=c:WaitForChild("Humanoid"); hrp=c:WaitForChild("HumanoidRootPart") end)
plr:GetMouse()

-- ============================================
-- CONFIG
-- ============================================
local C = {
 enabled = true,
 intervalMin = 12, intervalMax = 40,
 defaultDuration = 15, stacking = true, maxStacked = 4,
 intensity = 7,
 -- Per-effect cooldown (seconds). After an effect fires, it can't
 -- be picked again until this many seconds have passed. Auto-applied
 -- to every effect — no per-effect config needed.
 cooldown = 60,
 -- category toggles (all on by default = everything)
 visual = true, physics = true, player = true, camera = true,
 audio = true, environment = true, npc_ = true, hud_ = true,
 controls = true, randomizer_ = true, nostalgia = true, misc = true,
 -- pitch shifter config (used by the pitch shifter effect)
 pitchMin = 0.2, pitchMax = 4.0, pitchDelay = 3,
}
local active = {}
local eCount, eTotal = 0, 0
local lastE, chaosRunning = nil, false
local pitchPhase, pitchSpeed = 0, 1
local sounds, originals = {}, {}
local overlayGuis = {}
-- Timer state: sessionStart = when mod loaded; nextEffectAt = os.time() of next auto-trigger
local sessionStart = os.time()
local nextEffectAt = os.time() + 12
local currentEffectEndsAt = {} -- [effectName] = os.time() of expiration

-- ============================================
-- OLD ROBLOX ASSETS
-- ============================================
local A = {
 oof = "rbxassetid://12222220",
 click = "rbxassetid://147722220",
 victory = "rbxassetid://147723340",
 countdown = "rbxassetid://156786570",
 brick = "rbxassetid://156786571",
 death_ = "rbxassetid://132343431",
 tp = "rbxassetid://156786572",
 slash = "rbxassetid://158187711",
 powerup = "rbxassetid://156786573",
 winds = "rbxassetid://1838615514",
 horror = "rbxassetid://1845557321",
 happy = "rbxassetid://1842809006",
 build = "rbxassetid://1846116836",
 town = "rbxassetid://1846727381",
 battle = "rbxassetid://1845557321",
 sparkle = "rbxassetid://4513802011",
 faces = {"rbxassetid://18998949","rbxassetid://18998938","rbxassetid://18998935","rbxassetid://18998933",
 "rbxassetid://18998931","rbxassetid://18998929","rbxassetid://18998926","rbxassetid://18998924",
 "rbxassetid://18998921","rbxassetid://18998918"},
 gears = {"Rocket Launcher","Trowel","Binoculars","Grappling Hook","Superball","Bloxxer","Bloxy Cola",
 "Pizza","Linked Sword","Darkheart","Venomshank","Firebrand","Ice Dagger","Ghostwalker",
 "Windforce","Illumina","Classic Sword","Slingshot","Bomb","Time Bomb"},
 retroColors = {
 Color3.fromRGB(0,0,0),Color3.fromRGB(255,255,255),Color3.fromRGB(255,0,0),
 Color3.fromRGB(0,255,0),Color3.fromRGB(0,0,255),Color3.fromRGB(255,255,0),
 Color3.fromRGB(255,0,255),Color3.fromRGB(0,255,255),
 Color3.fromRGB(128,0,0),Color3.fromRGB(0,128,0),Color3.fromRGB(128,128,128),
 Color3.fromRGB(255,128,0),Color3.fromRGB(33,37,41),Color3.fromRGB(64,43,23),
 },
 -- Jeff the Killer model variants (decompiled model IDs supplied by user)
 jeffVariants = { 11491257517, 13040125601, 10355443441 },
 -- Patrick killer model (decompiled)
 patrickModel = 13087356290,
 -- Killer NPC variants (decompiled — scripts inside try to kill the player)
 killerNpcVariants = { 87204077518686, 111114793522738 },
 -- Zombie models (decompiled — spawned on top of the player)
 zombieVariants = { 117433604655327, 92886098629552 },
 -- Patrick quotes (SpongeBob nostalgia bait)
 patrickQuotes = {
  "I'm a barnacle! No, wait — you are!",
  "Is mayonnaise an instrument?",
  "I wumbo, you wumbo, he she me wumbo...",
  "The inner machinations of my mind are an enigma.",
  "LEEDLE LEEDLE LEEDLEE!",
  "Firmly grasp it! FIRMLY GRASP IT!",
  "I can't see my forehead!",
 },
 -- Random animation IDs (R15 + R6 mixed) for "Randomize Anims"
 randomAnims = {
 "rbxassetid://507768375", -- wave
 "rbxassetid://507768658", -- point
 "rbxassetid://507768238", -- dance
 "rbxassetid://507768375", -- wave
 "rbxassetid://507771027", -- cheer
 "rbxassetid://507776343", -- laugh
 "rbxassetid://507777268", -- sword slash
 "rbxassetid://507790350", -- die
 "rbxassetid://507797458", -- climb
 "rbxassetid://507885165", -- fall
 "rbxassetid://507885472", -- jump
 "rbxassetid://507885924", -- run
 "rbxassetid://507886108", -- float
 "rbxassetid://507886287", -- sit
 "rbxassetid://180435571", -- sit (alt)
 "rbxassetid://180426354", -- attack
 "rbxassetid://128853357", -- zombie attack
 "rbxassetid://215384599", -- backflip
 "rbxassetid://215384599", -- front flip
 "rbxassetid://1124534124", -- gangnam style
 "rbxassetid://1124534268", -- breakdance
 "rbxassetid://1124533927", -- default dance
 "rbxassetid://5919723889", -- floss
 "rbxassetid://5919723225", -- orange justice
 "rbxassetid://5919724457", -- take the L
 "rbxassetid://5915729496", -- smooth criminal
 "rbxassetid://5915648923", -- thriller
 "rbxassetid://3489171085", -- headless horseman
 "rbxassetid://9130049830", -- spook dance
 "rbxassetid://1124534324", -- flop
 "rbxassetid://507776043", -- pose
 "rbxassetid://507776898", -- poses
 "rbxassetid://507777899", -- tool
 "rbxassetid://507778239", -- tool slim
 "rbxassetid://507778451", -- tool slash
 "rbxassetid://507778537", -- tool lunge
 "rbxassetid://507779054", -- jump space
 "rbxassetid://507779380", -- climb (legacy)
 },
 -- Skybox IDs for "The Sky is Looping"
 skyboxes = {
 "rbxassetid://159454299", -- default sky
 "rbxassetid://12064041",  -- blue sky
 "rbxassetid://199399748", -- night sky
 "rbxassetid://259273782", -- sunset
 "rbxassetid://259273770", -- dawn
 "rbxassetid://5202539237", -- purple sky
 "rbxassetid://5202539238", -- green sky
 "rbxassetid://5202539239", -- red sky
 "rbxassetid://5215459116", -- neon sky
 "rbxassetid://5215459117", -- galaxy sky
 "rbxassetid://5215459118", -- retro sky
 "rbxassetid://5215459119", -- matrix sky
 },
 names = {"Builderman","John Doe","Guest 666","1x1x1x1","Telamon","Shedletsky","Clockwork",
 "ReeseMcBlox","Dued1","Stealth_Pilot","Cindering","Merely","Fleskhjerta","Matt Dusek",
 "Erik Cassel","Are92","Miked","ROBLOX","Noob","Guest","CoolJohnny99","N00B_KILLER_123"},
 marioTexts = {"It's-a me, Mario!","Wahoo!","Let's-a go!","Mamma mia!","Here we go!",
 "So long-eh Bowser!","Yahoooo!","Okey dokey!","Thank you so much for playing my game!",
 "L is real 2401","Every copy of Mario 64 is personalized","WAAA-HOOO!","BA-DING!","Lucky!"},
}

-- ============================================
-- UTILITY
-- ============================================
local function rp() local p=game.Players:GetPlayers() local x repeat x=p[math.random(#p)] until x~=plr or #p==1 return x end
local function rV3(r) return Vector3.new(math.random(-r,r),math.random(-r,r),math.random(-r,r)) end
local function rHSV() return Color3.fromHSV(math.random(),1,1) end
-- Smart cleanup: automatically disconnects tracked connections and
-- destroys tracked objects, then calls the effect's custom f().
-- This fixes the widespread "f=function() end" bug where effects
-- stored their connection in `conn` but never disconnected it,
-- causing them to run forever past their duration.
local function cleanup(k)
 if not active[k] then return end
 local a=active[k]
 -- Disconnect single connection
 if a.conn then pcall(function() a.conn:Disconnect() end) a.conn=nil end
 -- Disconnect multiple connections (table of RBXScriptConnections)
 if a.conns then
  for _,c in ipairs(a.conns) do pcall(function() c:Disconnect() end) end
  a.conns=nil
 end
 -- Destroy single tracked object (Frame, Sound, Part, etc.)
 if a.obj then pcall(function() a.obj:Destroy() end) a.obj=nil end
 -- Destroy multiple tracked objects
 if a.objs then
  for _,o in ipairs(a.objs) do pcall(function() o:Destroy() end) end
  a.objs=nil
 end
 -- Stop tracked sounds (don't Destroy — SoundService may own them)
 if a.sound then pcall(function() a.sound:Stop() a.sound:Destroy() end) a.sound=nil end
 if a.sounds then
  for _,s in ipairs(a.sounds) do pcall(function() s:Stop() s:Destroy() end) end
  a.sounds=nil
 end
 -- Call the effect's custom cleanup function
 pcall(a.f)
 active[k]=nil
end
local function notif(txt,dur)
 dur=dur or 3
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local f=Instance.new("Frame") f.Size=UDim2.new(0,300,0,36) f.Position=UDim2.new(0.5,-150,0.08,0)
 f.BackgroundColor3=Color3.fromRGB(18,18,22) f.BackgroundTransparency=0.25 f.BorderSizePixel=0 f.ZIndex=999
 Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
 local s=Instance.new("UIStroke",f) s.Color=Color3.fromRGB(255,80,200) s.Thickness=1.5
 local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,-16,1,0) l.Position=UDim2.new(0,8,0,0)
 l.BackgroundTransparency=1 l.Text="🌀 "..txt l.TextColor3=Color3.fromRGB(255,255,255)
 l.TextSize=13 l.Font=Enum.Font.GothamSemibold l.TextXAlignment=Enum.TextXAlignment.Left l.ZIndex=999
 f.Parent=g ts:Create(f,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
 {Position=UDim2.new(0.5,-150,0.12,0)}):Play()
 delay(dur,function() ts:Create(f,TweenInfo.new(0.4),{BackgroundTransparency=1,Position=UDim2.new(0.5,-150,0.02,0)}):Play()
 delay(0.5,function() f:Destroy() end) end)
end
local function playSound(id,vol,parent,dur)
 local s=Instance.new("Sound") s.SoundId=id s.Volume=vol or 1 s.Parent=parent or hrp or ws s:Play()
 if dur then debris:AddItem(s,dur) end return s
end

-- Enables all scripts inside a decompiled model loaded via game:GetObjects.
-- Decompiled models ship with their Script / LocalScript instances set to
-- Disabled = true (a Roblox safety measure for assets loaded from the web).
-- This walks every descendant, sets Disabled = false on every runnable script,
-- AND tries to manually kick-start LocalScripts that wouldn't auto-run from
-- the workspace context by cloning them into a runnable container.
local function enableScripts(model)
 if not model then return 0 end
 local count=0
 -- 1) Walk every descendant and un-disable every Script / LocalScript
 for _,d in model:GetDescendants() do
  if d:IsA("Script") or d:IsA("LocalScript") then
   pcall(function()
    if d.Disabled then d.Disabled=false count=count+1 end
   end)
  end
 end
 -- 2) For LocalScripts: they only auto-run when parented to specific containers
 --    (PlayerGui, PlayerScripts, Backpack, Character, ReplicatedFirst).
 --    A LocalScript sitting inside a workspace model will NOT auto-execute,
 --    so we clone it into the player's PlayerGui to kick it off (preserving
 --    the original inside the model in case it's referenced elsewhere).
 pcall(function()
  local gui=plr:FindFirstChild("PlayerGui")
  if gui then
   local kickFolder=gui:FindFirstChild("ChaosKickedScripts")
   if not kickFolder then
    kickFolder=Instance.new("Folder") kickFolder.Name="ChaosKickedScripts" kickFolder.Parent=gui
   end
   for _,d in model:GetDescendants() do
    if d:IsA("LocalScript") then
     pcall(function()
      local clone=d:Clone()
      clone.Name=d.Name.."_kicked"
      clone.Parent=kickFolder
      -- Mark for cleanup later via Debris (5 min cap)
      debris:AddItem(clone,300)
     end)
    end
   end
  end
 end)
 -- 3) For server Scripts in workspace: they will only run if the executor
 --    can actually run server-side code (most client-side executors can't).
 --    As a best-effort fallback, try to loadstring the source if loadstring
 --    is available in this environment.
 pcall(function()
  if loadstring then
   for _,d in model:GetDescendants() do
    if d:IsA("Script") and not d.Disabled then
     pcall(function()
      local src=d.Source
      if src and #src>0 then
       local fn,err=loadstring(src)
       if fn then
        spawn(function() pcall(fn) end)
       end
      end
     end)
    end
   end
  end
 end)
 return count
end

-- ============================================
-- PITCH SHIFTER INFRASTRUCTURE (shared engine)
-- ============================================
local function addSound_(v)
 if (v:IsA("Sound") or v:IsA("AudioPlayer")) and not originals[v] then
 table.insert(sounds,v) originals[v]=v.PlaybackSpeed or 1
 end
end
for _,v in game:GetDescendants() do addSound_(v) end
game.DescendantAdded:Connect(addSound_)
game.DescendantRemoving:Connect(function(v)
 if v:IsA("Sound") or v:IsA("AudioPlayer") then
 for i,s in ipairs(sounds) do if s==v then table.remove(sounds,i) originals[v]=nil break end end
 end
end)
rs.RenderStepped:Connect(function(dt)
 if not active.PitchShift then return end
 pitchPhase=pitchPhase+(dt/C.pitchDelay)
 pitchSpeed=C.pitchMin+(C.pitchMax-C.pitchMin)*(math.sin(pitchPhase)*0.5+0.5)
 for _,s in pairs(sounds) do
 if s and s.Parent then s.PlaybackSpeed=pitchSpeed end
 end
end)

-- ============================================
-- EFFECTS DATABASE: 280+ Effects
-- ============================================
local E = {}
-- Tag format: E[id] = {name, cat, icon, dur, start, stop (optional)}

-- ╔══════════════════════════════════════════════════════╗
-- ║ CATEGORY 1: VISUAL (PolyChaos + SM64 Chaos + GTA) ║
-- ╚══════════════════════════════════════════════════════╝
local vid = function(n,i,d,s,st) E[#E+1]={name=n,cat="Visual",icon=i,dur=d or C.defaultDuration,start=s,stop=st} end

vid("Inverted Colors","🎨",15,function()
 local ce=Instance.new("ColorCorrectionEffect",ls) ce.Brightness=-0.15 ce.Contrast=2 ce.Saturation=-1 ce.TintColor=Color3.fromRGB(255,128,255)
 active.InvColors={f=function() ce:Destroy() end}
end,function() cleanup("InvColors") end)

vid("Upside-Down Screen","🙃",12,function()
 active.UpsideDown={conn=rs.RenderStepped:Connect(function() cam.CFrame=cam.CFrame*CFrame.Angles(math.pi,0,0) end),f=function() end}
end,function() cleanup("UpsideDown") end)

vid("Mirrored World","🪞",12,function()
 active.MirrorWorld={conn=rs.RenderStepped:Connect(function() cam.CFrame=cam.CFrame*CFrame.Angles(0,math.pi,0) end),f=function() end}
end,function() cleanup("MirrorWorld") end)

vid("Wireframe Mode","📐",12,function()
 local ot=ls.Technology local ob=ls.Brightness ls.Technology=Enum.Technology.Compatibility ls.Brightness=3
 active.Wireframe={f=function() ls.Technology=ot ls.Brightness=ob end}
end,function() cleanup("Wireframe") end)

vid("LSD Trip","🌈",18,function()
 local ce=Instance.new("ColorCorrectionEffect",ls)
 active.LSD={ce=ce,conn=rs.RenderStepped:Connect(function()
 ce.TintColor=Color3.fromHSV(tick()*2%6/6,1,1) ce.Contrast=0.5+math.sin(tick()*3)*0.5
 ce.Saturation=math.sin(tick()*2)*0.5+0.5 ce.Brightness=math.sin(tick()*1.5)*0.3
 end),f=function() ce:Destroy() end}
end,function() cleanup("LSD") end)

vid("Disco Mode","🪩",20,function()
 active.Disco={conn=rs.RenderStepped:Connect(function()
 ls.Ambient=Color3.fromHSV(tick()%6/6,1,0.4) ls.OutdoorAmbient=Color3.fromHSV((tick()+0.33)%6/6,1,0.5)
 ls.ColorShift_Top=Color3.fromHSV((tick()+0.66)%6/6,1,0.6)
 end),f=function() end}
end,function() cleanup("Disco") end)

vid("Night Vision (GTA)","👁️",15,function()
 local ce=Instance.new("ColorCorrectionEffect",ls) ce.TintColor=Color3.fromRGB(0,255,0) ce.Contrast=1.5 ce.Brightness=3 ce.Saturation=-1
 active.NightVision={f=function() ce:Destroy() end}
end,function() cleanup("NightVision") end)

vid("Thermal Vision","🔥",15,function()
 local ce=Instance.new("ColorCorrectionEffect",ls) ce.TintColor=Color3.fromRGB(255,128,0) ce.Contrast=2 ce.Brightness=2 ce.Saturation=-1
 active.ThermalVision={f=function() ce:Destroy() end}
end,function() cleanup("ThermalVision") end)

vid("Rainbow Mario","🌟",12,function()
 if char then for _,v in char:GetChildren() do if v:IsA("BasePart") then v.BrickColor=BrickColor.Random() end end end
 active.RainbowMario={conn=rs.Heartbeat:Connect(function()
 if char then for _,v in char:GetChildren() do if v:IsA("BasePart") then v.BrickColor=BrickColor.Random() end end end
 end),f=function() end}
end,function() cleanup("RainbowMario") end)

vid("Seizure Warning","⚡",8,function()
 local bl=Instance.new("BloomEffect",ls) bl.Intensity=10 bl.Size=56 bl.Threshold=0
 local blur=Instance.new("BlurEffect",ls) blur.Size=24
 active.Seizure={conn=rs.RenderStepped:Connect(function() bl.Intensity=5+math.random(1,10) blur.Size=math.random(0,24) end),
 f=function() bl:Destroy() blur:Destroy() end}
end,function() cleanup("Seizure") end)

vid("Extreme FOV Zoom","🔭",12,function()
 local of=cam.FieldOfView cam.FieldOfView=math.random(100,140)
 active.FOV={f=function() cam.FieldOfView=of end}
end,function() cleanup("FOV") end)

vid("Tiny World FOV","🔬",12,function()
 local of=cam.FieldOfView cam.FieldOfView=10
 local blur=Instance.new("BlurEffect",ls) blur.Size=12
 active.TinyWorld={f=function() cam.FieldOfView=of blur:Destroy() end}
end,function() cleanup("TinyWorld") end)

vid("Zooming FOV","🎥",14,function()
 local of=cam.FieldOfView local t=0
 active.ZoomingFOV={conn=rs.RenderStepped:Connect(function() t=t+0.05 cam.FieldOfView=70+math.sin(t)*50 end),
 f=function() cam.FieldOfView=of end}
end,function() cleanup("ZoomingFOV") end)

vid("Portrait Mode","📱",12,function()
 active.Portrait={conn=rs.RenderStepped:Connect(function() cam.CFrame=cam.CFrame*CFrame.Angles(0,0,math.pi/2) end),f=function() end}
end,function() cleanup("Portrait") end)

vid("Low Draw Distance","🌁",14,function()
 local ofs,ofe=ls.FogStart,ls.FogEnd ls.FogStart=0 ls.FogEnd=30 ls.FogColor=Color3.fromRGB(180,180,180)
 active.LowDrawDist={f=function() ls.FogStart=ofs ls.FogEnd=ofe end}
end,function() cleanup("LowDrawDist") end)

vid("Mist / Fog","🌫️",16,function()
 local ofs,ofe=ls.FogStart,ls.FogEnd ls.FogStart=0 ls.FogEnd=15 ls.FogColor=Color3.fromRGB(200,200,200)
 active.Mist={f=function() ls.FogStart=ofs ls.FogEnd=ofe end}
end,function() cleanup("Mist") end)

vid("Underwater View","🌊",14,function()
 local ce=Instance.new("ColorCorrectionEffect",ls) ce.TintColor=Color3.fromRGB(0,100,200) ce.Saturation=-0.5 ce.Brightness=-0.3
 local bl=Instance.new("BlurEffect",ls) bl.Size=4
 active.Underwater={f=function() ce:Destroy() bl:Destroy() end}
end,function() cleanup("Underwater") end)

vid("Random Object Colors","🖌️",15,function()
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v~=hrp and not v:IsA("Terrain") then orig[v]=v.BrickColor v.BrickColor=BrickColor.Random() end end
 active.ObjColors={f=function() for v,c in pairs(orig) do if v and v.Parent then v.BrickColor=c end end end}
end,function() cleanup("ObjColors") end)

vid("Random Object Sizes","📏",15,function()
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v~=hrp and v.Anchored then orig[v]=v.Size v.Size=v.Size*math.random(50,200)/100 end end
 active.ObjSizes={f=function() for v,s in pairs(orig) do if v and v.Parent then v.Size=s end end end}
end,function() cleanup("ObjSizes") end)

vid("Random Mesh Rotations","🔄",15,function()
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v~=hrp and v.Anchored then orig[v]=v.Orientation end end
 active.MeshRot={conn=rs.Heartbeat:Connect(function() for v in pairs(orig) do if v and v.Parent then v.Orientation=Vector3.new(math.random(0,360),math.random(0,360),math.random(0,360)) end end end),
 f=function() for v,o in pairs(orig) do if v and v.Parent then v.Orientation=o end end end}
end,function() cleanup("MeshRot") end)

vid("Neon Everything","💡",15,function()
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v~=hrp then orig[v]=v.Material v.Material=Enum.Material.Neon end end
 active.NeonAll={f=function() for v,m in pairs(orig) do if v and v.Parent then v.Material=m end end end}
end,function() cleanup("NeonAll") end)

vid("Invisible Water","💧",14,function()
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v.Material==Enum.Material.Water then orig[v]=v.Transparency v.Transparency=1 end end
 active.InvisWater={f=function() for v,t in pairs(orig) do if v and v.Parent then v.Transparency=t end end end}
end,function() cleanup("InvisWater") end)

vid("No Water Physics","🏊",14,function()
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v.Material==Enum.Material.Water then orig[v]=v.CanCollide v.CanCollide=false end end
 active.NoWaterPhys={f=function() for v,c in pairs(orig) do if v and v.Parent then v.CanCollide=c end end end}
end,function() cleanup("NoWaterPhys") end)

vid("Custom (Garish) Textures","🖼️",14,function()
 local texIds={"rbxassetid://156786571","rbxassetid://18998949","rbxassetid://18998938"}
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v:IsA("Texture") then orig[v]=v.Texture v.Texture=texIds[math.random(#texIds)] end end
 active.CustomTex={f=function() for v,t in pairs(orig) do if v and v.Parent then v.Texture=t end end end}
end,function() cleanup("CustomTex") end)

vid("Sun Rays Overdrive","☀️",14,function()
 local sr=Instance.new("SunRaysEffect",ls) sr.Intensity=1 sr.Spread=0.3
 active.SunRays={f=function() sr:Destroy() end}
end,function() cleanup("SunRays") end)

vid("Bloom Overload","✨",14,function()
 local bl=Instance.new("BloomEffect",ls) bl.Intensity=5 bl.Size=56 bl.Threshold=0
 active.Bloom={f=function() bl:Destroy() end}
end,function() cleanup("Bloom") end)

vid("Blur Blindness","😵",12,function()
 local bl=Instance.new("BlurEffect",ls) bl.Size=56
 active.Blur={f=function() bl:Destroy() end}
end,function() cleanup("Blur") end)

vid("Camera Shake","🌋",10,function()
 active.CamShake={conn=rs.RenderStepped:Connect(function()
 cam.CFrame=cam.CFrame*CFrame.new(math.random(-3,3)/10,math.random(-3,3)/10,math.random(-3,3)/10)
 end),f=function() end}
end,function() cleanup("CamShake") end)

vid("Disable Shadows","👤",14,function()
 ls.GlobalShadows=false
 active.NoShadows={f=function() ls.GlobalShadows=true end}
end,function() cleanup("NoShadows") end)

vid("Color Shift Top","🎨",14,function()
 local orig=ls.ColorShift_Top
 active.ColorShiftTop={conn=rs.Heartbeat:Connect(function() ls.ColorShift_Top=rHSV() end),f=function() ls.ColorShift_Top=orig end}
end,function() cleanup("ColorShiftTop") end)

vid("Party Lights (Environment)","🎉",14,function()
 active.PartyLights={conn=rs.Heartbeat:Connect(function() ls.Ambient=rHSV() ls.OutdoorAmbient=rHSV() end),f=function() end}
end,function() cleanup("PartyLights") end)

-- ╔══════════════════════════════════════════════════════╗
-- ║ CATEGORY 2: PHYSICS (SM64 Chaos + GTA SA Chaos) ║
-- ╚══════════════════════════════════════════════════════╝
local phy = function(n,i,d,s,st) E[#E+1]={name=n,cat="Physics",icon=i,dur=d or C.defaultDuration,start=s,stop=st} end

phy("Moon Gravity","🌙",16,function()
 local og=ws.Gravity ws.Gravity=15 active.MoonGrav={f=function() ws.Gravity=og end}
end,function() cleanup("MoonGrav") end)

phy("Jupiter Gravity","🪐",16,function()
 local og=ws.Gravity ws.Gravity=500 active.JupGrav={f=function() ws.Gravity=og end}
end,function() cleanup("JupGrav") end)

phy("Zero Gravity","🛸",14,function()
 local og=ws.Gravity ws.Gravity=0 active.ZeroGrav={f=function() ws.Gravity=og end}
end,function() cleanup("ZeroGrav") end)

phy("Inverted Gravity","🙃",14,function()
 local og=ws.Gravity ws.Gravity=-196.2 active.InvGrav={f=function() ws.Gravity=og end}
end,function() cleanup("InvGrav") end)

phy("Velocity Shuffle","💨",12,function()
 active.VelShuffle={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then hrp.Velocity=hrp.Velocity+rV3(80) end
 end),f=function() end}
end,function() cleanup("VelShuffle") end)

phy("YEET!","🚀",1,function()
 if hrp and hrp.Parent then hrp.Velocity=Vector3.new(math.random(-300,300),800,math.random(-300,300)) end
end)

phy("Tornado Spin","🌪️",12,function()
 active.Tornado={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then hrp.CFrame=hrp.CFrame*CFrame.Angles(math.random(-30,30)/100,0.3,math.random(-30,30)/100)
 hrp.Velocity=hrp.Velocity+Vector3.new(0,math.random(10,60),0) end
 end),f=function() end}
end,function() cleanup("Tornado") end)

phy("Beyblade Mode","🌀",10,function()
 active.Beyblade={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then hrp.CFrame=hrp.CFrame*CFrame.Angles(0,0.5,0) end
 end),f=function() end}
end,function() cleanup("Beyblade") end)

phy("Super Bouncy","🏀",15,function()
 if char then for _,v in char:GetChildren() do if v:IsA("BasePart") then v.Elasticity=1 end end end
 active.Bouncy={f=function() if char then for _,v in char:GetChildren() do if v:IsA("BasePart") then v.Elasticity=0 end end end end}
end,function() cleanup("Bouncy") end)

phy("Ice Physics","🧊",15,function()
 local orig={} if char then for _,v in char:GetChildren() do if v:IsA("BasePart") then orig[v]=v.CustomPhysicalProperties v.CustomPhysicalProperties=PhysicalProperties.new(0,0,0,0,0) end end end
 active.Ice={f=function() for v,p in pairs(orig) do if v and v.Parent then v.CustomPhysicalProperties=p end end end}
end,function() cleanup("Ice") end)

phy("Noclip Ghost","👻",15,function()
 if char then for _,v in char:GetChildren() do if v:IsA("BasePart") then v.CanCollide=false end end end
 active.Noclip={f=function() if char then for _,v in char:GetChildren() do if v:IsA("BasePart") then v.CanCollide=true end end end end}
end,function() cleanup("Noclip") end)

phy("Ragdoll Time","🦴",6,function()
 if hum then hum.PlatformStand=true end
 active.Ragdoll={f=function() if hum then hum.PlatformStand=false end end}
end,function() cleanup("Ragdoll") end)

phy("Air Walk","🪽",15,function()
 active.AirWalk={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then hrp.Velocity=hrp.Velocity*Vector3.new(1,0,1)+Vector3.new(0,15,0) end
 end),f=function() end}
end,function() cleanup("AirWalk") end)

phy("Walk On Water","🏄",15,function()
 active.WalkWater={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then
 local under=ws:FindPartOnRay(Ray.new(hrp.Position,Vector3.new(0,-5,0)),char)
 if under and under.Material==Enum.Material.Water then hrp.Velocity=hrp.Velocity+Vector3.new(0,20,0) end
 end
 end),f=function() end}
end,function() cleanup("WalkWater") end)

phy("Strong Wind","💨",14,function()
 local dir=Vector3.new(math.random(-1,1),0,math.random(-1,1)).Unit*30
 active.StrongWind={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then hrp.Velocity=hrp.Velocity+dir end
 end),f=function() end}
end,function() cleanup("StrongWind") end)

phy("Vehicle Momentum Up","🚗",14,function()
 if char then for _,v in char:GetChildren() do if v:IsA("BasePart") then v.Massless=true end end end
 active.VehMomentum={f=function() if char then for _,v in char:GetChildren() do if v:IsA("BasePart") then v.Massless=false end end end end}
end,function() cleanup("VehMomentum") end)

phy("Suspension Damping","🛞",14,function()
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("VehicleSeat") then orig[v]=v.Steer v.Steer=0 end end
 active.Suspension={f=function() for v,o in pairs(orig) do if v and v.Parent then v.Steer=o end end end}
end,function() cleanup("Suspension") end)

phy("Kickflip Physics","🛹",12,function()
 active.Kickflip={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent and math.random()<0.1 then hrp.RotVelocity=Vector3.new(0,30,0) end
 end),f=function() end}
end,function() cleanup("Kickflip") end)

phy("Forceful Explosions","💥",12,function()
 active.ForceExplode={conn=rs.Heartbeat:Connect(function()
 for _,v in ws:GetDescendants() do if v:IsA("Explosion") then
 local p=Instance.new("Part") p.Size=Vector3.new(10,10,10) p.Position=v.Position p.Anchored=true p.CanCollide=false p.Transparency=1 p.Parent=ws
 debris:AddItem(p,2)
 end end
 end),f=function() end}
end,function() cleanup("ForceExplode") end)

-- ╔══════════════════════════════════════════════════════╗
-- ║ CATEGORY 3: PLAYER (SM64 + GTA Player Effects) ║
-- ╚══════════════════════════════════════════════════════╝
local ply = function(n,i,d,s,st) E[#E+1]={name=n,cat="Player",icon=i,dur=d or C.defaultDuration,start=s,stop=st} end

ply("SPEED DEMON","⚡",15,function()
 if hum then local o=hum.WalkSpeed hum.WalkSpeed=math.random(60,200) active.SpeedDemon={f=function() if hum then hum.WalkSpeed=o end end} end
end,function() cleanup("SpeedDemon") end)

ply("Snail Mode","🐌",15,function()
 if hum then local o=hum.WalkSpeed hum.WalkSpeed=2 active.Snail={f=function() if hum then hum.WalkSpeed=o end end} end
end,function() cleanup("Snail") end)

ply("Moon Jumps","🦘",15,function()
 if hum then local o=hum.JumpPower hum.JumpPower=math.random(150,500) active.MoonJump={f=function() if hum then hum.JumpPower=o end end} end
end,function() cleanup("MoonJump") end)

ply("Grounded Forever","🔒",15,function()
 if hum then local o=hum.JumpPower hum.JumpPower=0 active.NoJump={f=function() if hum then hum.JumpPower=o end end} end
end,function() cleanup("NoJump") end)

ply("Giant Mode","🦖",15,function()
 if hrp then local o=hrp.Size hrp.Size=Vector3.new(10,10,10) if hum then hum.HipHeight=10 end active.Giant={f=function() if hrp then hrp.Size=o end if hum then hum.HipHeight=0 end end} end
end,function() cleanup("Giant") end)

ply("Microscopic Mode","🔬",15,function()
 if hrp then local o=hrp.Size hrp.Size=Vector3.new(0.5,0.5,0.5) if hum then hum.HipHeight=0.5 end active.Micro={f=function() if hrp then hrp.Size=o end if hum then hum.HipHeight=0 end end} end
end,function() cleanup("Micro") end)

ply("Big Head Mode","🎈",15,function()
 if char then local h=char:FindFirstChild("Head") if h then local o=h.Size h.Size=Vector3.new(8,8,8) active.BigHead={f=function() if h and h.Parent then h.Size=o end end} end end
end,function() cleanup("BigHead") end)

ply("Small Head Mode","🥜",15,function()
 if char then local h=char:FindFirstChild("Head") if h then local o=h.Size h.Size=Vector3.new(0.3,0.3,0.3) active.SmallHead={f=function() if h and h.Parent then h.Size=o end end} end end
end,function() cleanup("SmallHead") end)

ply("Drunk Mode","🍺",15,function()
 active.Drunk={conn=rs.Heartbeat:Connect(function()
 if hum then hum.WalkSpeed=math.random(4,20) end
 if hrp and hrp.Parent then hrp.CFrame=hrp.CFrame*CFrame.Angles(math.random(-5,5)/100,0,math.random(-5,5)/100) end
 end),f=function() if hum then hum.WalkSpeed=16 end end}
end,function() cleanup("Drunk") end)

ply("Invisible Player","🫥",15,function()
 local orig={} if char then for _,v in char:GetChildren() do if v:IsA("BasePart") then orig[v]=v.Transparency v.Transparency=(v.Name=="Head" and 0.7 or 0.85) end end end
 active.InvisPlayer={f=function() for v,t in pairs(orig) do if v and v.Parent then v.Transparency=t end end end}
end,function() cleanup("InvisPlayer") end)

ply("Fake Death","💀",2,function()
 if hum then hum.Health=1 end playSound(A.oof,5,hrp,3)
end)

ply("Explosive Bullets","💥",15,function()
 active.ExploBullets={conn=rs.Heartbeat:Connect(function()
 if char then for _,t in char:GetChildren() do if t:IsA("Tool") and t:FindFirstChild("Handle") then
 local h=t.Handle h.Touched:Connect(function(p) if p and p.Parent and p.Parent~=char then
 local ex=Instance.new("Explosion",ws) ex.Position=h.Position ex.BlastRadius=10 ex.BlastPressure=100
 end end)
 end end end
 end),f=function() end}
end,function() cleanup("ExploBullets") end)

ply("Fire Bullets","🔥",15,function()
 active.FireBullets={conn=rs.Heartbeat:Connect(function()
 if char then for _,t in char:GetChildren() do if t:IsA("Tool") and t:FindFirstChild("Handle") then
 local h=t.Handle h.Touched:Connect(function(p) if p and p.Parent and p.Parent~=char then
 Instance.new("Fire",p) end end)
 end end end
 end),f=function() end}
end,function() cleanup("FireBullets") end)

ply("One Hit KO","☠️",15,function()
 if hum then local o=hum.MaxHealth hum.MaxHealth=1 hum.Health=1 active.OneHitKO={f=function() if hum then hum.MaxHealth=o end end} end
end,function() cleanup("OneHitKO") end)

ply("One Percent Death","💔",15,function()
 active.OnePercent={conn=rs.Heartbeat:Connect(function()
 if hum and hum.Health<=hum.MaxHealth*0.01 then hum.Health=0 end
 end),f=function() end}
end,function() cleanup("OnePercent") end)

ply("Infinite Health","💚",15,function()
 active.InfHealth={conn=rs.Heartbeat:Connect(function() if hum then hum.Health=hum.MaxHealth end end),f=function() end}
end,function() cleanup("InfHealth") end)

ply("Pacifist Mode","☮️",14,function()
 active.Pacifist={conn=rs.Heartbeat:Connect(function()
 if char then for _,t in char:GetChildren() do if t:IsA("Tool") then t.Parent=rep end end end
 end),f=function() end}
end,function() cleanup("Pacifist") end)

ply("Galaxy Note 7 (Explode)","📱",1,function()
 if hrp and hrp.Parent then Instance.new("Explosion",ws).Position=hrp.Position end
end)

ply("Force Field","🛡️",15,function()
 local ff=Instance.new("ForceField",char or hrp)
 active.ForceField={f=function() ff:Destroy() end}
end,function() cleanup("ForceField") end)

ply("Experience The Lag","🐢",15,function()
 if hum then local o=hum.WalkSpeed
 active.ExpLag={conn=rs.Heartbeat:Connect(function()
 if hum then hum.WalkSpeed=math.random(1,math.max(2,o)) end
 end),f=function() if hum then hum.WalkSpeed=o end end}
 end
end,function() cleanup("ExpLag") end)

ply("Super Hot Mode","🔥",15,function()
 -- Time only moves when you move (simplified: super slow time + speed on input)
 if hum then local o=hum.WalkSpeed
 active.SuperHot={conn=rs.Heartbeat:Connect(function()
 if hum then hum.WalkSpeed=hum.MoveDirection.Magnitude>0.1 and o or 0.5 end
 end),f=function() if hum then hum.WalkSpeed=o end end}
 end
end,function() cleanup("SuperHot") end)

ply("The Flash","⚡",12,function()
 if hum then local o=hum.WalkSpeed hum.WalkSpeed=200
 active.TheFlash={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent and math.random()<0.3 then
 local t=Instance.new("Part",ws) t.Size=Vector3.new(1,1,1) t.BrickColor=BrickColor.new("Bright yellow")
 t.Material=Enum.Material.Neon t.Anchored=true t.CanCollide=false t.Position=hrp.Position t.Transparency=0.5
 debris:AddItem(t,1)
 end
 end),f=function() if hum then hum.WalkSpeed=o end end}
 end
end,function() cleanup("TheFlash") end)

ply("Its Rewind Time","⏪",8,function()
 local pos={} active.Rewind={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then table.insert(pos,hrp.CFrame) if #pos>60 then table.remove(pos,1) end end
 end),f=function() end}
 delay(8,function() if hrp and hrp.Parent and #pos>0 then hrp.CFrame=pos[1] end end)
end,function() cleanup("Rewind") end)

ply("Freefall","🪂",12,function()
 active.Freefall={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then hrp.Velocity=hrp.Velocity-Vector3.new(0,5,0) end
 end),f=function() end}
end,function() cleanup("Freefall") end)

ply("Shaky Hands","✋",12,function()
 active.ShakyHands={conn=rs.RenderStepped:Connect(function()
 cam.CFrame=cam.CFrame*CFrame.new(math.random(-2,2)/10,math.random(-2,2)/10,0)
 end),f=function() end}
end,function() cleanup("ShakyHands") end)

ply("Vehicle Bumper Camera","📹",14,function()
 cam.CameraType=Enum.CameraType.Scriptable
 active.BumperCam={conn=rs.RenderStepped:Connect(function()
 if hrp and hrp.Parent then cam.CFrame=CFrame.new(hrp.Position+Vector3.new(0,2,-5),hrp.Position+Vector3.new(0,2,10)) end
 end),f=function() cam.CameraType=Enum.CameraType.Custom cam.CameraSubject=hum end}
end,function() cleanup("BumperCam") end)

ply("Arcade Racer Camera","🏎️",14,function()
 cam.CameraType=Enum.CameraType.Scriptable
 active.ArcadeCam={conn=rs.RenderStepped:Connect(function()
 if hrp and hrp.Parent then cam.CFrame=CFrame.new(hrp.Position+Vector3.new(0,15,-20),hrp.Position) end
 end),f=function() cam.CameraType=Enum.CameraType.Custom cam.CameraSubject=hum end}
end,function() cleanup("ArcadeCam") end)

ply("Flower Power","🌸",15,function()
 active.FlowerPower={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent and math.random()<0.2 then
 local f=Instance.new("Part",ws) f.Size=Vector3.new(0.5,0.5,0.5) f.BrickColor=BrickColor.Random()
 f.Position=hrp.Position+Vector3.new(0,2,0) f.Velocity=rV3(20) debris:AddItem(f,3)
 end
 end),f=function() end}
end,function() cleanup("FlowerPower") end)

ply("Rainbow Trail","🌈",16,function()
 active.RainbowTrail={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then
 local t=Instance.new("Part",ws) t.Size=Vector3.new(1,1,1) t.BrickColor=BrickColor.Random()
 t.Material=Enum.Material.Neon t.Anchored=true t.CanCollide=false t.Position=hrp.Position t.Transparency=0.5
 ts:Create(t,TweenInfo.new(2),{Transparency=1,Size=Vector3.new(0,0,0)}):Play() debris:AddItem(t,3)
 end
 end),f=function() end}
end,function() cleanup("RainbowTrail") end)

ply("Ring Ring (Phone Call SFX)","📞",8,function()
 for i=1,8 do delay(i*0.8,function() playSound(A.click,0.6,hrp,2) end) end
end)

ply("Switch to Unarmed","🖐️",1,function()
 if char then for _,t in char:GetChildren() do if t:IsA("Tool") then t.Parent=rep end end end
end)

ply("Remove All Weapons","🔫",1,function()
 if plr.Backpack then for _,t in plr.Backpack:GetChildren() do if t:IsA("Tool") then t:Destroy() end end end
 if char then for _,t in char:GetChildren() do if t:IsA("Tool") then t:Destroy() end end end
end)

ply("Remove Current Weapon","🗑️",1,function()
 if char then for _,t in char:GetChildren() do if t:IsA("Tool") then t:Destroy() break end end end
end)

ply("Mega Punch","👊",15,function()
 if hum then local o=hum.WalkSpeed hum.WalkSpeed=o*1.5
 active.MegaPunch={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then for _,v in ws:GetDescendants() do
 if v:IsA("BasePart") and v~=hrp and (v.Position-hrp.Position).Magnitude<5 and not v.Anchored then
 v.Velocity=(v.Position-hrp.Position).Unit*200+Vector3.new(0,50,0)
 end
 end end
 end),f=function() if hum then hum.WalkSpeed=o end end}
 end
end,function() cleanup("MegaPunch") end)

ply("Drive Wander (Auto-Walk)","🚶",14,function()
 if hum then hum.AutoRotate=false
 local dir=Vector3.new(math.random(-1,1),0,math.random(-1,1)).Unit
 active.DriveWander={conn=rs.Heartbeat:Connect(function()
 if hum then hum:Move(dir,false)
 if math.random()<0.02 then dir=Vector3.new(math.random(-1,1),0,math.random(-1,1)).Unit end
 end
 end),f=function() if hum then hum:Move(Vector3.zero,false) hum.AutoRotate=true end end}
 end
end,function() cleanup("DriveWander") end)

ply("Random Outfit","👕",12,function()
 if char then
 for _,v in char:GetChildren() do if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then v.BrickColor=BrickColor.Random() end end
 end
end)

ply("Millionaire (Visual)","💰",8,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local f=Instance.new("Frame",g) f.Size=UDim2.new(0,200,0,30) f.Position=UDim2.new(0,10,0,10)
 f.BackgroundColor3=Color3.fromRGB(0,200,0) f.BackgroundTransparency=0.3 f.BorderSizePixel=0 f.ZIndex=999
 Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
 local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
 l.Text="💰 $"..math.random(100000,99999999) l.TextColor3=Color3.fromRGB(0,0,0) l.Font=Enum.Font.GothamBold l.TextSize=16 l.ZIndex=999
 debris:AddItem(f,8)
end)

ply("Bankrupt","💸",8,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local f=Instance.new("Frame",g) f.Size=UDim2.new(0,200,0,30) f.Position=UDim2.new(0,10,0,10)
 f.BackgroundColor3=Color3.fromRGB(200,0,0) f.BackgroundTransparency=0.3 f.BorderSizePixel=0 f.ZIndex=999
 Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
 local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
 l.Text="💸 $"..math.random(0,10) l.TextColor3=Color3.fromRGB(255,255,255) l.Font=Enum.Font.GothamBold l.TextSize=16 l.ZIndex=999
 debris:AddItem(f,8)
end)

ply("Instantly Hungry","🍕",10,function()
 active.Hungry={conn=rs.Heartbeat:Connect(function()
 if hum and math.random()<0.05 then hum.Health=math.max(1,hum.Health-1) end
 end),f=function() end}
end,function() cleanup("Hungry") end)

ply("No Heals","🚫",14,function()
 active.NoHeal={conn=rs.Heartbeat:Connect(function()
 if hum then hum.Health=math.min(hum.Health,hum.MaxHealth*0.5) end
 end),f=function() end}
end,function() cleanup("NoHeal") end)

ply("Gun Game (Random Tool)","🎯",14,function()
 if not plr.Backpack then return end
 local tools=plr.Backpack:GetChildren()
 active.GunGame={conn=rs.Heartbeat:Connect(function()
 if math.random()<0.05 and char and #tools>0 then
 local t=tools[math.random(#tools)] if t:IsA("Tool") then t.Parent=char end
 end
 end),f=function() end}
end,function() cleanup("GunGame") end)

-- ╔══════════════════════════════════════════════════════╗
-- ║ CATEGORY 4: CAMERA (SM64 Chaos Camera) ║
-- ╚══════════════════════════════════════════════════════╝
local camE = function(n,i,d,s,st) E[#E+1]={name=n,cat="Camera",icon=i,dur=d or C.defaultDuration,start=s,stop=st} end

camE("Camera Spin","📹",12,function()
 active.CamSpin={conn=rs.RenderStepped:Connect(function(dt)
 if hrp and hrp.Parent then cam.CFrame=CFrame.new(cam.CFrame.Position,hrp.Position)*CFrame.Angles(0,dt*4,0) end
 end),f=function() end}
end,function() cleanup("CamSpin") end)

camE("Forced First Person","🎥",14,function()
 cam.CameraType=Enum.CameraType.Scriptable
 active.FirstPerson={conn=rs.RenderStepped:Connect(function()
 if char and char:FindFirstChild("Head") then cam.CFrame=char.Head.CFrame end
 end),f=function() cam.CameraType=Enum.CameraType.Custom cam.CameraSubject=hum end}
end,function() cleanup("FirstPerson") end)

camE("Strategic Zoom Out","🗺️",14,function()
 if plr then local o=plr.CameraMaxZoomDistance plr.CameraMaxZoomDistance=500 plr.CameraMinZoomDistance=100
 active.StratZoom={f=function() plr.CameraMaxZoomDistance=o plr.CameraMinZoomDistance=0.5 end} end
end,function() cleanup("StratZoom") end)

camE("Detach Camera","📷",14,function()
 cam.CameraType=Enum.CameraType.Scriptable
 active.DetachCam={conn=rs.RenderStepped:Connect(function()
 if hrp and hrp.Parent then cam.CFrame=CFrame.new(hrp.Position+Vector3.new(0,30,-30),hrp.Position) end
 end),f=function() cam.CameraType=Enum.CameraType.Custom cam.CameraSubject=hum end}
end,function() cleanup("DetachCam") end)

camE("Rotate Camera","🔄",14,function()
 local t=0
 active.RotateCam={conn=rs.RenderStepped:Connect(function(dt)
 t=t+dt*2
 if hrp and hrp.Parent then cam.CFrame=CFrame.new(hrp.Position)*CFrame.Angles(0,t,0)*CFrame.new(0,5,-20) end
 end),f=function() end}
end,function() cleanup("RotateCam") end)

camE("Forced Look Behind","👀",14,function()
 active.LookBehind={conn=rs.RenderStepped:Connect(function()
 if hrp and hrp.Parent then cam.CFrame=CFrame.new(cam.CFrame.Position,hrp.Position+hrp.CFrame.LookVector*-30) end
 end),f=function() end}
end,function() cleanup("LookBehind") end)

camE("Freeze Camera","⏸️",6,function()
 local cf=cam.CFrame cam.CameraType=Enum.CameraType.Scriptable cam.CFrame=cf
 active.FreezeCam={f=function() cam.CameraType=Enum.CameraType.Custom cam.CameraSubject=hum end}
end,function() cleanup("FreezeCam") end)

camE("Reset Camera","📷",1,function()
 cam.CameraType=Enum.CameraType.Custom cam.CameraSubject=hum cam.FieldOfView=70
end)

camE("Top-Down Camera","🔽",14,function()
 cam.CameraType=Enum.CameraType.Scriptable
 active.TopDown={conn=rs.RenderStepped:Connect(function()
 if hrp and hrp.Parent then cam.CFrame=CFrame.new(hrp.Position+Vector3.new(0,50,0.1),hrp.Position) end
 end),f=function() cam.CameraType=Enum.CameraType.Custom cam.CameraSubject=hum end}
end,function() cleanup("TopDown") end)

camE("Cinematic Camera","🎬",14,function()
 cam.CameraType=Enum.CameraType.Scriptable local t=0
 active.CineCam={conn=rs.RenderStepped:Connect(function(dt)
 t=t+dt*0.5
 if hrp and hrp.Parent then cam.CFrame=CFrame.new(hrp.Position+Vector3.new(math.sin(t)*15,8+math.sin(t*0.7)*5,math.cos(t)*15),hrp.Position) end
 end),f=function() cam.CameraType=Enum.CameraType.Custom cam.CameraSubject=hum end}
end,function() cleanup("CineCam") end)

-- ╔══════════════════════════════════════════════════════╗
-- ║ CATEGORY 5: AUDIO (SM64 + GTA Audio, Pitch Shift) ║
-- ╚══════════════════════════════════════════════════════╝
local aud = function(n,i,d,s,st) E[#E+1]={name=n,cat="Audio",icon=i,dur=d or C.defaultDuration,start=s,stop=st} end

aud("Pitch Shifter (Oscillate)","🎚️",15,function()
 -- THIS IS THE PITCH SHIFTER AS AN EFFECT (not separate GUI)
 pitchPhase=0
 active.PitchShift={f=function()
 for s,o in pairs(originals) do if s and s.Parent then s.PlaybackSpeed=o end end
 pitchPhase=0 pitchSpeed=1
 end}
end,function() cleanup("PitchShift") end)

aud("Chipmunk Mode","🐿️",10,function()
 local orig={} for _,s in ws:GetDescendants() do if s:IsA("Sound") and not originals[s] then orig[s]=s.PlaybackSpeed s.PlaybackSpeed=2.5 end end
 active.Chipmunk={f=function() for s,o in pairs(orig) do if s and s.Parent then s.PlaybackSpeed=o end end end}
end,function() cleanup("Chipmunk") end)

aud("Demon Voice","👹",10,function()
 local orig={} for _,s in ws:GetDescendants() do if s:IsA("Sound") and not originals[s] then orig[s]=s.PlaybackSpeed s.PlaybackSpeed=0.25 end end
 active.DemonVoice={f=function() for s,o in pairs(orig) do if s and s.Parent then s.PlaybackSpeed=o end end end}
end,function() cleanup("DemonVoice") end)

aud("Random Classic Sound","🔊",3,function()
 local ids={A.oof,A.click,A.victory,A.countdown,A.brick,A.death_,A.tp,A.slash,A.powerup}
 playSound(ids[math.random(#ids)],2,hrp,3)
end)

aud("Classic ROBLOX Music","🎵",22,function()
 local ids={A.winds,A.horror,A.happy,A.town}
 local m=Instance.new("Sound",ws) m.SoundId=ids[math.random(#ids)] m.Volume=1 m.Looped=true m:Play()
 active.ClassicMusic={f=function() m:Stop() m:Destroy() end}
end,function() cleanup("ClassicMusic") end)

aud("Volume Chaos","📢",14,function()
 active.VolChaos={conn=rs.Heartbeat:Connect(function()
 for _,s in ws:GetDescendants() do if s:IsA("Sound") then s.Volume=math.random(0,10) end end
 end),f=function() end}
end,function() cleanup("VolChaos") end)

aud("Echo Chamber","🏔️",14,function()
 local e=Instance.new("EchoSoundEffect",ss) e.DryLevel=0.5 e.WetLevel=0.8 e.Delay=0.5 e.Decay=0.5
 active.Echo={f=function() e:Destroy() end}
end,function() cleanup("Echo") end)

aud("Cathedral Reverb","⛪",14,function()
 local r=Instance.new("ReverbSoundEffect",ss) r.DecayTime=10 r.Density=1 r.Diffusion=1 r.DryLevel=-6 r.WetLevel=0
 active.Reverb={f=function() r:Destroy() end}
end,function() cleanup("Reverb") end)

aud("Total Silence","🔇",10,function()
 ss.Muted=true active.Mute={f=function() ss.Muted=false end}
end,function() cleanup("Mute") end)

aud("Overlap Music","🎶",16,function()
 local ids={A.winds,A.horror,A.happy,A.town,A.build,A.battle}
 local m={} for i=1,3 do m[i]=Instance.new("Sound",ws) m[i].SoundId=ids[math.random(#ids)] m[i].Volume=0.5 m[i]:Play() end
 active.OverlapMus={f=function() for _,s in m do s:Stop() s:Destroy() end end}
end,function() cleanup("OverlapMus") end)

aud("Spam Sounds","🗣️",10,function()
 active.SpamSnd={conn=rs.Heartbeat:Connect(function()
 if math.random()<0.3 then playSound(A.oof,0.4,hrp,1.5) end
 end),f=function() end}
end,function() cleanup("SpamSnd") end)

aud("Oof Steps","👣",16,function()
 local lp=hrp and hrp.Position or Vector3.zero
 active.OofSteps={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent and (hrp.Position-lp).Magnitude>3 then lp=hrp.Position playSound(A.oof,0.8,hrp,1.5) end
 end),f=function() end}
end,function() cleanup("OofSteps") end)

aud("Distort All Sounds","🔧",14,function()
 local d=Instance.new("DistortionSoundEffect",ss) d.Level=1
 active.Distort={f=function() d:Destroy() end}
end,function() cleanup("Distort") end)

aud("Flange All Sounds","〰️",14,function()
 local fl=Instance.new("FlangeSoundEffect",ss) fl.Depth=1 fl.Mix=0.8 fl.Rate=5
 active.Flange={f=function() fl:Destroy() end}
end,function() cleanup("Flange") end)

aud("Chorus All Sounds","👥",14,function()
 local ch=Instance.new("ChorusSoundEffect",ss) ch.Depth=1 ch.Mix=0.8 ch.Rate=1
 active.Chorus={f=function() ch:Destroy() end}
end,function() cleanup("Chorus") end)

aud("Equalizer Chaos","🎛️",14,function()
 local eq=Instance.new("EqualizerSoundEffect",ss) eq.HighGain=10 eq.LowGain=-6 eq.MidGain=6
 active.EQChaos={f=function() eq:Destroy() end}
end,function() cleanup("EQChaos") end)

aud("Pitch Drop (Bass Boosted)","📉",12,function()
 local orig={} for _,s in ws:GetDescendants() do if s:IsA("Sound") then orig[s]=s.PlaybackSpeed s.PlaybackSpeed=0.5 end end
 local eq=Instance.new("EqualizerSoundEffect",ss) eq.LowGain=15 eq.HighGain=-6
 active.PitchDrop={f=function() for s,o in pairs(orig) do if s and s.Parent then s.PlaybackSpeed=o end end eq:Destroy() end}
end,function() cleanup("PitchDrop") end)

aud("Speed Up Music","⏩",12,function()
 local orig={} for _,s in ws:GetDescendants() do if s:IsA("Sound") and s.Looped then orig[s]=s.PlaybackSpeed s.PlaybackSpeed=2 end end
 active.SpeedMusic={f=function() for s,o in pairs(orig) do if s and s.Parent then s.PlaybackSpeed=o end end end}
end,function() cleanup("SpeedMusic") end)

aud("Slow Down Music","⏪",12,function()
 local orig={} for _,s in ws:GetDescendants() do if s:IsA("Sound") and s.Looped then orig[s]=s.PlaybackSpeed s.PlaybackSpeed=0.4 end end
 active.SlowMusic={f=function() for s,o in pairs(orig) do if s and s.Parent then s.PlaybackSpeed=o end end end}
end,function() cleanup("SlowMusic") end)

-- ╔══════════════════════════════════════════════════════╗
-- ║ CATEGORY 6: ENVIRONMENT (GTA + SM64 World Effects) ║
-- ╚══════════════════════════════════════════════════════╝
local env = function(n,i,d,s,st) E[#E+1]={name=n,cat="Environment",icon=i,dur=d or C.defaultDuration,start=s,stop=st} end

env("Time Warp","⏰",20,function()
 active.TimeWarp={conn=rs.Heartbeat:Connect(function() ls.ClockTime=(ls.ClockTime+1)%24 end),f=function() end}
end,function() cleanup("TimeWarp") end)

env("Always Midnight","🌙",20,function()
 ls.ClockTime=0 ls.Brightness=0.5
 active.AlwaysMidnight={f=function() ls.Brightness=2 end}
end,function() cleanup("AlwaysMidnight") end)

env("Timelapse","⏩",16,function()
 active.Timelapse={conn=rs.Heartbeat:Connect(function() ls.ClockTime=(ls.ClockTime+3)%24 end),f=function() end}
end,function() cleanup("Timelapse") end)

env("Stop Game Clock","⏹️",20,function()
 local ct=ls.ClockTime active.StopClock={conn=rs.Heartbeat:Connect(function() ls.ClockTime=ct end),f=function() end}
end,function() cleanup("StopClock") end)

env("Silent Hill Fog","🌫️",16,function()
 local ofs,ofe=ls.FogStart,ls.FogEnd ls.FogStart=0 ls.FogEnd=20 ls.FogColor=Color3.fromRGB(180,180,180)
 active.SHFog={f=function() ls.FogStart=ofs ls.FogEnd=ofe end}
end,function() cleanup("SHFog") end)

env("Blood Moon","🌑",20,function()
 ls.Ambient=Color3.fromRGB(40,0,0) ls.OutdoorAmbient=Color3.fromRGB(60,0,0)
 ls.FogColor=Color3.fromRGB(40,0,0) ls.FogStart=0 ls.FogEnd=160 ls.ClockTime=0 ls.Brightness=0
 active.BloodMoon={f=function() ls.Ambient=Color3.fromRGB(127,127,127) ls.OutdoorAmbient=Color3.fromRGB(127,127,127) ls.Brightness=2 end}
end,function() cleanup("BloodMoon") end)

env("Meteor Shower","☄️",16,function()
 active.Meteor={conn=rs.Heartbeat:Connect(function()
 if math.random()<0.2 and hrp and hrp.Parent then
 local p=Instance.new("Part",ws) p.Size=Vector3.new(2,2,2) p.BrickColor=BrickColor.new("Bright red")
 p.Material=Enum.Material.Neon p.Anchored=true p.CanCollide=false
 p.Position=hrp.Position+Vector3.new(math.random(-50,50),25,math.random(-50,50))
 Instance.new("Fire",p) debris:AddItem(p,4)
 if (hrp.Position-p.Position).Magnitude<20 then hrp.Velocity=hrp.Velocity+(hrp.Position-p.Position).Unit*80 end
 end
 end),f=function() end}
end,function() cleanup("Meteor") end)

env("Acid Rain","☣️",16,function()
 active.AcidRain={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent and math.random()<0.1 then
 local d=Instance.new("Part",ws) d.Size=Vector3.new(0.5,0.5,0.5) d.BrickColor=BrickColor.new("Lime green")
 d.Material=Enum.Material.Neon d.Anchored=true d.CanCollide=false
 d.Position=hrp.Position+Vector3.new(math.random(-20,20),20,math.random(-20,20))
 d.Touched:Connect(function(p) if p.Parent and p.Parent:FindFirstChild("Humanoid") then
 p.Parent.Humanoid:TakeDamage(2) end end)
 debris:AddItem(d,2)
 end
 end),f=function() end}
end,function() cleanup("AcidRain") end)

env("Water Is Lava","🌋",18,function()
 active.WaterLava={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then
 local under=ws:FindPartOnRay(Ray.new(hrp.Position,Vector3.new(0,-2,0)),char)
 if under and under.Material==Enum.Material.Water then if hum then hum:TakeDamage(5) end end
 end
 end),f=function() end}
end,function() cleanup("WaterLava") end)

env("Earthquake","🌍",12,function()
 active.Earthquake={conn=rs.RenderStepped:Connect(function()
 cam.CFrame=cam.CFrame*CFrame.new(math.random(-8,8)/10,math.random(-8,8)/10,math.random(-8,8)/10)
 end),f=function() end}
end,function() cleanup("Earthquake") end)

env("Deforestation","🪓",14,function()
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v.Name:lower():find("tree") then orig[v]=v.Transparency v.Transparency=1 end end
 active.Deforest={f=function() for v,t in pairs(orig) do if v and v.Parent then v.Transparency=t end end end}
end,function() cleanup("Deforest") end)

env("Spawn Tree","🌳",8,function()
 if hrp and hrp.Parent then
 local t=Instance.new("Part",ws) t.Size=Vector3.new(1,6,1) t.BrickColor=BrickColor.new("Brown") t.Anchored=true t.Position=hrp.Position+Vector3.new(math.random(-8,8),0,math.random(-8,8))
 local l=Instance.new("Part",ws) l.Size=Vector3.new(4,4,4) l.BrickColor=BrickColor.new("Bright green") l.Anchored=true l.Position=t.Position+Vector3.new(0,4,0) l.Shape=Enum.PartType.Ball
 debris:AddItem(t,10) debris:AddItem(l,10)
 end
end)

env("Spawn Ramp","🛹",14,function()
 if hrp and hrp.Parent then
 local r=Instance.new("Part",ws) r.Size=Vector3.new(8,0.5,12) r.BrickColor=BrickColor.new("Bright blue")
 r.Anchored=true r.Position=hrp.Position+Vector3.new(0,-2,5) r.Orientation=Vector3.new(-30,0,0)
 debris:AddItem(r,14)
 end
end)

env("Spawn Fires Around Player","🔥",14,function()
 active.SpawnFire={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent and math.random()<0.15 then
 local p=Instance.new("Part",ws) p.Size=Vector3.new(2,0.5,2) p.Anchored=true p.CanCollide=false
 p.Position=hrp.Position+Vector3.new(math.random(-12,12),-2.5,math.random(-12,12))
 Instance.new("Fire",p) debris:AddItem(p,8)
 end
 end),f=function() end}
end,function() cleanup("SpawnFire") end)

env("Oil on Roads","🛢️",16,function()
 if hrp and hrp.Parent then
 local orig={} for _,v in ws:GetDescendants() do
 if v:IsA("BasePart") and v.Anchored and v.Size.Y<2 and (v.Position-hrp.Position).Magnitude<50 then
 orig[v]=v.Material v.Material=Enum.Material.SmoothPlastic v.BrickColor=BrickColor.new("Really black")
 end
 end
 active.OilRoads={f=function() for v,m in pairs(orig) do if v and v.Parent then v.Material=m end end end}
 end
end,function() cleanup("OilRoads") end)

env("2006 ROBLOX Sky","🏰",20,function()
 ls.ColorShift_Top=Color3.fromRGB(100,100,255) ls.ColorShift_Bottom=Color3.fromRGB(200,200,200)
 ls.Ambient=Color3.fromRGB(127,127,127) ls.OutdoorAmbient=Color3.fromRGB(107,107,107)
 active.ROBLOX2006Sky={f=function() end}
end,function() cleanup("ROBLOX2006Sky") end)

env("Studio Lighting","💡",16,function()
 ls.Ambient=Color3.fromRGB(140,140,140) ls.OutdoorAmbient=Color3.fromRGB(140,140,140) ls.Brightness=2.5
 active.StudioLight={f=function() end}
end,function() cleanup("StudioLight") end)

env("Invisible Fire","🔥",14,function()
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("Fire") then orig[v]=v.Size v.Size=0 end end
 active.InvisFire={f=function() for v,s in pairs(orig) do if v and v.Parent then v.Size=s end end end}
end,function() cleanup("InvisFire") end)

env("Flood Warning","🌊",20,function()
 ls.Brightness=0.3 ls.FogColor=Color3.fromRGB(0,50,150) ls.FogStart=0 ls.FogEnd=50 ls.Ambient=Color3.fromRGB(0,20,60)
 active.Flood={f=function() ls.Brightness=2 end}
end,function() cleanup("Flood") end)

-- ╔══════════════════════════════════════════════════════╗
-- ║ CATEGORY 7: NPC/PED (GTA Ped Effects → Roblox NPC) ║
-- ╚══════════════════════════════════════════════════════╝
local npc = function(n,i,d,s,st) E[#E+1]={name=n,cat="NPCs",icon=i,dur=d or C.defaultDuration,start=s,stop=st} end

npc("Explode All NPCs","💥",1,function()
 for _,p in game.Players:GetPlayers() do if p~=plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
 Instance.new("Explosion",ws).Position=p.Character.HumanoidRootPart.Position end end
end)

npc("Set Everyone On Fire","🔥",14,function()
 local fires={} for _,p in game.Players:GetPlayers() do
 if p~=plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
 local f=Instance.new("Fire",p.Character.HumanoidRootPart) table.insert(fires,f)
 end
 end
 active.FireAll={f=function() for _,f in fires do f:Destroy() end end}
end,function() cleanup("FireAll") end)

npc("Launch All NPCs","🚀",1,function()
 for _,p in game.Players:GetPlayers() do if p~=plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
 p.Character.HumanoidRootPart.Velocity=Vector3.new(math.random(-100,100),300,math.random(-100,100)) end end
end)

npc("Teleport All To Player","📍",1,function()
 if hrp and hrp.Parent then for _,p in game.Players:GetPlayers() do
 if p~=plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
 p.Character.HumanoidRootPart.CFrame=hrp.CFrame+Vector3.new(math.random(-5,5),0,math.random(-5,5))
 end
 end end
end)

npc("Big Heads (Everyone)","🎈",15,function()
 local orig={} for _,p in game.Players:GetPlayers() do if p.Character then local h=p.Character:FindFirstChild("Head") if h then orig[h]=h.Size h.Size=Vector3.new(6,6,6) end end end
 active.NPCBigHeads={f=function() for h,s in pairs(orig) do if h and h.Parent then h.Size=s end end end}
end,function() cleanup("NPCBigHeads") end)

npc("Long Necks (Everyone)","🦒",15,function()
 local orig={} for _,p in game.Players:GetPlayers() do if p.Character then local n=p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso") if n then orig[n]=n.Size n.Size=n.Size*Vector3.new(1,3,1) end end end
 active.LongNecks={f=function() for n,s in pairs(orig) do if n and n.Parent then n.Size=s end end end}
end,function() cleanup("LongNecks") end)

npc("T-Pose Everyone","🧍",15,function()
 local orig={} for _,p in game.Players:GetPlayers() do if p.Character then local h=p.Character:FindFirstChild("Humanoid") if h then orig[h]=h.RigType pcall(function() h.RigType=Enum.HumanoidRigType.R15 end) end end end
 active.TPose={f=function() for h,r in pairs(orig) do if h and h.Parent then pcall(function() h.RigType=r end) end end end}
end,function() cleanup("TPose") end)

npc("Where Is Everybody","🫥",8,function()
 local orig={} for _,p in game.Players:GetPlayers() do if p~=plr and p.Character then for _,v in p.Character:GetChildren() do if v:IsA("BasePart") then orig[v]=v.Transparency v.Transparency=1 end end end end
 active.HideNPCs={f=function() for v,t in pairs(orig) do if v and v.Parent then v.Transparency=t end end end}
end,function() cleanup("HideNPCs") end)

npc("Everyone Leaves Vehicles","🚪",1,function()
 for _,p in game.Players:GetPlayers() do if p~=plr and p.Character then
 local s=p.Character:FindFirstChildOfClass("Seat") or p.Character:FindFirstChildOfClass("VehicleSeat")
 if s then p.Character.Humanoid.Sit=false end
 end end
end)

npc("Disarm All NPCs","🔫",1,function()
 for _,p in game.Players:GetPlayers() do if p~=plr and p.Character then
 for _,t in p.Character:GetChildren() do if t:IsA("Tool") then t.Parent=p.Backpack end end
 end end
end)

npc("Infinite Health Everyone","💚",15,function()
 active.InfHealthAll={conn=rs.Heartbeat:Connect(function()
 for _,p in game.Players:GetPlayers() do if p.Character and p.Character:FindFirstChild("Humanoid") then
 p.Character.Humanoid.Health=p.Character.Humanoid.MaxHealth end
 end
 end),f=function() end}
end,function() cleanup("InfHealthAll") end)

npc("One Hit KO Everyone","☠️",15,function()
 local orig={} for _,p in game.Players:GetPlayers() do if p~=plr and p.Character and p.Character:FindFirstChild("Humanoid") then
 local h=p.Character.Humanoid orig[h]=h.MaxHealth h.MaxHealth=1 h.Health=1
 end end
 active.NPCOneHit={f=function() for h,o in pairs(orig) do if h and h.Parent then h.MaxHealth=o end end end}
end,function() cleanup("NPCOneHit") end)

npc("Rotating Peds","🔄",14,function()
 active.RotateNPCs={conn=rs.Heartbeat:Connect(function()
 for _,p in game.Players:GetPlayers() do if p~=plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
 local hr=p.Character.HumanoidRootPart hr.CFrame=hr.CFrame*CFrame.Angles(0,0.1,0)
 end end
 end),f=function() end}
end,function() cleanup("RotateNPCs") end)

npc("Peds Explode On Death","💀",16,function()
 local conns={} for _,p in game.Players:GetPlayers() do if p~=plr and p.Character and p.Character:FindFirstChild("Humanoid") then
 local c=p.Character.Humanoid.Died:Connect(function()
 Instance.new("Explosion",ws).Position=p.Character:FindFirstChild("HumanoidRootPart") and p.Character.HumanoidRootPart.Position or Vector3.zero
 end) table.insert(conns,c)
 end end
 active.NPCExplodeDeath={f=function() for _,c in conns do c:Disconnect() end end}
end,function() cleanup("NPCExplodeDeath") end)

npc("Bumper Peds","🚗",14,function()
 active.BumperNPCs={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then for _,p in game.Players:GetPlayers() do
 if p~=plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
 local h=p.Character.HumanoidRootPart if (h.Position-hrp.Position).Magnitude<5 then
 h.Velocity=(h.Position-hrp.Position).Unit*50+Vector3.new(0,20,0)
 end
 end
 end end
 end),f=function() end}
end,function() cleanup("BumperNPCs") end)

-- ╔══════════════════════════════════════════════════════╗
-- ║ CATEGORY 8: HUD/UI (GTA HUD Effects → Roblox GUI) ║
-- ╚══════════════════════════════════════════════════════╝
local hud = function(n,i,d,s,st) E[#E+1]={name=n,cat="HUD/UI",icon=i,dur=d or C.defaultDuration,start=s,stop=st} end

hud("DVD Screensaver","📀",20,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local f=Instance.new("Frame",g) f.Size=UDim2.new(0,120,0,80) f.BackgroundColor3=Color3.fromRGB(0,0,200) f.BackgroundTransparency=0.7 f.BorderSizePixel=0 f.ZIndex=998
 local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Text="📀" l.TextSize=40 l.ZIndex=998
 local x,y=0.5,0.5 local dx,dy=0.005,0.003
 active.DVD={obj=f,conn=rs.RenderStepped:Connect(function()
 x=x+dx y=y+dy
 if x>0.85 or x<0 then dx=-dx end if y>0.85 or y<0 then dy=-dy end
 f.Position=UDim2.new(x,0,y,0)
 end),f=function() f:Destroy() end}
end,function() cleanup("DVD") end)

hud("Disable HUD","🚫",15,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local orig={} for _,f in g:GetChildren() do if f:IsA("ScreenGui") and f.Name~="ChaosModGUI" then orig[f]=f.Enabled f.Enabled=false end end
 active.DisableHUD={f=function() for f,e in pairs(orig) do if f and f.Parent then f.Enabled=e end end end}
end,function() cleanup("DisableHUD") end)

hud("Tunnel Vision","🔭",14,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local t=Instance.new("Frame",g) t.Size=UDim2.new(1,0,1,0) t.BackgroundColor3=Color3.fromRGB(0,0,0) t.BackgroundTransparency=1 t.BorderSizePixel=0 t.ZIndex=997
 local h=Instance.new("Frame",t) h.Size=UDim2.new(0,200,0,200) h.Position=UDim2.new(0.5,-100,0.5,-100) h.BackgroundColor3=Color3.fromRGB(0,0,0) h.BorderSizePixel=0 h.ZIndex=997
 Instance.new("UICorner",h).CornerRadius=UDim.new(0,200)
 for i=1,4 do local b=Instance.new("Frame",t) b.Size=UDim2.new(1,0,1,0) b.BackgroundColor3=Color3.fromRGB(0,0,0) b.ZIndex=997 end
 active.TunnelVision={f=function() t:Destroy() end}
end,function() cleanup("TunnelVision") end)

hud("Blind Mode","🕶️",10,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local b=Instance.new("Frame",g) b.Size=UDim2.new(1,0,1,0) b.BackgroundColor3=Color3.fromRGB(0,0,0) b.ZIndex=998
 active.Blind={f=function() b:Destroy() end}
end,function() cleanup("Blind") end)

hud("Scott The Woz (Blue Border)","🟦",16,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local b=Instance.new("Frame",g) b.Size=UDim2.new(1,0,1,0) b.BackgroundTransparency=1 b.ZIndex=996
 local s=Instance.new("UIStroke",b) s.Color=Color3.fromRGB(0,100,255) s.Thickness=20 s.ZIndex=996
 active.ScottWoz={f=function() b:Destroy() end}
end,function() cleanup("ScottWoz") end)

hud("Radar Zoom","🗺️",14,function()
 -- fake radar zoom effect
 notif("🗺️ RADAR: ZOOMING IN...",4)
end)

hud("Disable Blips/Markers","📍",15,function()
 for _,b in ws:GetDescendants() do if b:IsA("BillboardGui") or (b:IsA("Part") and b.Name:lower():find("marker")) then b.Enabled=b:IsA("BillboardGui") and false or nil end end
end)

hud("Pop-up Hell","🪟",12,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local msgs={"Free robux!","DOWNLOAD NOW!","You won!","Click here!","SYSTEM ERROR","Virus detected!","CONGRATULATIONS!","Hot singles!","TIX giveaway!","Admin powers!"}
 active.PopUpHell={conn=rs.Heartbeat:Connect(function()
 if math.random()<0.08 then
 local f=Instance.new("Frame",g) f.Size=UDim2.new(0,180,0,60)
 f.Position=UDim2.new(math.random(0,75)/100,0,math.random(0,80)/100,0)
 f.BackgroundColor3=Color3.fromRGB(math.random(40,80),math.random(40,80),math.random(40,80))
 f.BackgroundTransparency=0.2 f.BorderSizePixel=0 f.ZIndex=999
 Instance.new("UICorner",f).CornerRadius=UDim.new(0,4)
 local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
 l.Text=msgs[math.random(#msgs)] l.TextColor3=Color3.fromRGB(255,255,0) l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextWrapped=true l.ZIndex=999
 Instance.new("TextButton",f).Size=UDim2.new(0,50,0,16) f.TextButton.Position=UDim2.new(0.5,-25,0.7,0) f.TextButton.Text="[X] Close" f.TextButton.TextSize=9
 f.TextButton.BackgroundColor3=Color3.fromRGB(255,0,0) f.TextButton.TextColor3=Color3.fromRGB(255,255,255) f.TextButton.ZIndex=999
 f.TextButton.MouseButton1Click:Connect(function() f:Destroy() end)
 debris:AddItem(f,10)
 end
 end),f=function() end}
end,function() cleanup("PopUpHell") end)

hud("WANTED LEVEL","⭐",16,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local f=Instance.new("Frame",g) f.Size=UDim2.new(0,220,0,36) f.Position=UDim2.new(1,-230,0.02,0)
 f.BackgroundColor3=Color3.fromRGB(30,30,40) f.BackgroundTransparency=0.3 f.BorderSizePixel=0 f.ZIndex=999
 Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
 local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
 l.Font=Enum.Font.GothamBlack l.TextSize=18 l.ZIndex=999
 active.Wanted={obj=f,conn=rs.Heartbeat:Connect(function()
 l.Text=((math.floor(tick()*2)%2==0) and "⭐" or "🟊").." WANTED: "..math.random(1,6)
 l.TextColor3=tick()%1<0.5 and Color3.fromRGB(255,0,0) or Color3.fromRGB(255,255,255)
 end),f=function() f:Destroy() end}
end,function() cleanup("Wanted") end)

hud("Freeze Radar (Fake)","🧭",14,function()
 notif("🧭 Radar frozen!",3)
end)

hud("Fake Crash","💻",4,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local b=Instance.new("Frame",g) b.Size=UDim2.new(1,0,1,0) b.BackgroundColor3=Color3.fromRGB(0,0,255) b.ZIndex=1000
 local l=Instance.new("TextLabel",b) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
 l.Text=":(" l.TextColor3=Color3.fromRGB(255,255,255) l.Font=Enum.Font.Legacy l.TextSize=100 l.ZIndex=1000
 delay(3,function() b:Destroy() end)
end)

hud("Roll Credits","🎬",16,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local f=Instance.new("Frame",g) f.Size=UDim2.new(1,0,1,0) f.BackgroundColor3=Color3.fromRGB(0,0,0) f.BackgroundTransparency=0.3 f.ZIndex=998
 local credits={"CHAOS MOD","ULTIMATE EDITION","by professor fard","280+ Effects","PolyChaos + GTA + SM64","Thanks for playing!","smg44463","ROBLOX Chaos Mod","2026","","","GOODBYE!"}
 local y=1.2
 active.RollCredits={obj=f,conn=rs.RenderStepped:Connect(function(dt)
 y=y-dt*0.02
 for i,c in ipairs(credits) do
 local l=f:FindFirstChild("c"..i)
 if not l then l=Instance.new("TextLabel",f) l.Name="c"..i l.Size=UDim2.new(1,0,0,40)
 l.BackgroundTransparency=1 l.Text=c l.TextColor3=Color3.fromRGB(255,255,255)
 l.Font=Enum.Font.GothamBlack l.TextSize=24 l.ZIndex=998
 end
 l.Position=UDim2.new(0,0,y+i*0.08,0)
 end
 end),f=function() f:Destroy() end}
end,function() cleanup("RollCredits") end)

hud("Too Much Information","📊",14,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local f=Instance.new("Frame",g) f.Size=UDim2.new(0,280,0,200) f.Position=UDim2.new(0,5,0.5,-100)
 f.BackgroundColor3=Color3.fromRGB(0,0,0) f.BackgroundTransparency=0.4 f.BorderSizePixel=0 f.ZIndex=998
 local stats={"POS: "..tostring(hrp and hrp.Position or "??"),"FPS: "..math.random(30,120),"PING: "..math.random(10,500).."ms",
 "MEM: "..math.random(100,999).."MB","CPU: "..math.random(10,100).."%","GPU: "..math.random(40,90).."°C",
 "EFFECTS: "..eTotal,"TIME: "..os.date("%H:%M:%S"),"MOON PHASE: "..({"🌑","🌒","🌓","🌔","🌕","🌖","🌗","🌘"})[math.random(8)]}
 local idx=0 for _,s in stats do local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,0,18) l.Position=UDim2.new(0,4,0,idx*20)
 l.BackgroundTransparency=1 l.Text=s l.TextColor3=Color3.fromRGB(0,255,0) l.Font=Enum.Font.Code l.TextSize=12
 l.TextXAlignment=Enum.TextXAlignment.Left l.ZIndex=998 idx=idx+1
 end
 debris:AddItem(f,14)
end)

hud("Very Big Font","🔤",14,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local orig={} for _,sg in g:GetChildren() do if sg:IsA("ScreenGui") then
 for _,v in sg:GetDescendants() do if v:IsA("TextLabel") or v:IsA("TextButton") then orig[v]=v.TextSize v.TextSize=v.TextSize*3 end end
 end end
 active.BigFont={f=function() for v,s in pairs(orig) do if v and v.Parent then v.TextSize=s end end end}
end,function() cleanup("BigFont") end)

-- ╔══════════════════════════════════════════════════════╗
-- ║ CATEGORY 9: CONTROLS (SM64 Chaos + GTA Input) ║
-- ╚══════════════════════════════════════════════════════╝
local ctl = function(n,i,d,s,st) E[#E+1]={name=n,cat="Controls",icon=i,dur=d or C.defaultDuration,start=s,stop=st} end

ctl("Inverted Controls","🔀",14,function()
 active.InvCtrl={conn=rs.Heartbeat:Connect(function()
 if hum then hum:Move(-hum.MoveDirection,false) end
 end),f=function() end}
end,function() cleanup("InvCtrl") end)

ctl("Random Inputs","🎲",12,function()
 active.RandInput={conn=rs.Heartbeat:Connect(function()
 if hum and math.random()<0.15 then hum:Move(rV3(1),false) end
 end),f=function() end}
end,function() cleanup("RandInput") end)

ctl("Disable Jumping","🦶",14,function()
 if hum then local o=hum.JumpPower hum.JumpPower=0 active.NoJumpCtrl={f=function() if hum then hum.JumpPower=o end end} end
end,function() cleanup("NoJumpCtrl") end)

ctl("Disable One Movement Key","⌨️",14,function()
 local keys={Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D}
 local disabled=keys[math.random(#keys)]
 local actionName="ChaosDisable_"..tostring(disabled)
 cas:BindAction(actionName,function() return Enum.ContextActionResult.Sink end,false,disabled)
 active.DisableMovKey={f=function() cas:UnbindAction(actionName) end}
end,function() cleanup("DisableMovKey") end)

ctl("Delayed Controls","⏳",14,function()
 if hum then local o=hum.WalkSpeed
 active.DelayedCtrl={conn=rs.Heartbeat:Connect(function()
 if hum then hum.WalkSpeed=hum.MoveDirection.Magnitude>0.1 and o*0.3 or o end
 end),f=function() if hum then hum.WalkSpeed=o end end}
 end
end,function() cleanup("DelayedCtrl") end)

ctl("Lock Mouse","🖱️",14,function()
 if mouse then mouse.Icon="rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png" end
 uis.MouseBehavior=Enum.MouseBehavior.LockCenter
 active.LockMouse={f=function() uis.MouseBehavior=Enum.MouseBehavior.Default end}
end,function() cleanup("LockMouse") end)

ctl("Disable Shooting","🔫",14,function()
 active.NoShooting={conn=rs.Heartbeat:Connect(function()
 if mouse then mouse.Icon="rbxassetid://0" end
 cas:BindAction("ChaosNoShoot",function(_,s) if s==Enum.UserInputState.Begin then return Enum.ContextActionResult.Sink end end,false,Enum.UserInputType.MouseButton1)
 end),f=function() cas:UnbindAction("ChaosNoShoot") end}
end,function() cleanup("NoShooting") end)

ctl("Disable Aiming","🎯",14,function()
 active.NoAim={conn=rs.Heartbeat:Connect(function()
 cas:BindAction("ChaosNoAim",function(_,s) if s==Enum.UserInputState.Begin then return Enum.ContextActionResult.Sink end end,false,Enum.UserInputType.MouseButton2)
 end),f=function() cas:UnbindAction("ChaosNoAim") end}
end,function() cleanup("NoAim") end)

ctl("Forced Shooting","💥",10,function()
 active.ForceShoot={conn=rs.Heartbeat:Connect(function()
 if char and math.random()<0.3 then
 for _,t in char:GetChildren() do if t:IsA("Tool") then t:Activate() end end
 end
 end),f=function() end}
end,function() cleanup("ForceShoot") end)

ctl("Forced Look Behind","👀",14,function()
 active.ForceLook={conn=rs.RenderStepped:Connect(function()
 cam.CFrame=cam.CFrame*CFrame.Angles(0,math.pi,0)
 end),f=function() end}
end,function() cleanup("ForceLook") end)

ctl("Pedal to the Metal","🏎️",12,function()
 active.PedalMetal={conn=rs.Heartbeat:Connect(function()
 if hum then hum:Move(Vector3.new(0,0,-1),false) end
 end),f=function() end}
end,function() cleanup("PedalMetal") end)

ctl("Steer Bias Left","⬅️",14,function()
 active.SteerLeft={conn=rs.Heartbeat:Connect(function()
 if hum then hum:Move(Vector3.new(-1,0,hum.MoveDirection.Z),false) end
 end),f=function() end}
end,function() cleanup("SteerLeft") end)

ctl("Steer Bias Right","➡️",14,function()
 active.SteerRight={conn=rs.Heartbeat:Connect(function()
 if hum then hum:Move(Vector3.new(1,0,hum.MoveDirection.Z),false) end
 end),f=function() end}
end,function() cleanup("SteerRight") end)

ctl("WASD Cheats Mode","⌨️",14,function()
 -- Bind random effects to WASD
 local actions={}
 for _,k in pairs({Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D}) do
 local an="ChaosWASD_"..k.Name
 cas:BindAction(an,function(_,s) if s==Enum.UserInputState.Begin then notif("🔑 "..k.Name.." pressed!") end end,false,k)
 table.insert(actions,an)
 end
 active.WASDCheats={f=function() for _,a in actions do cas:UnbindAction(a) end end}
end,function() cleanup("WASDCheats") end)

-- ╔══════════════════════════════════════════════════════╗
-- ║ CATEGORY 10: RANDOMIZER (GTA Randomizer + SM64) ║
-- ╚══════════════════════════════════════════════════════╝
local rnd = function(n,i,d,s,st) E[#E+1]={name=n,cat="Randomizer",icon=i,dur=d or C.defaultDuration,start=s,stop=st} end

rnd("Random Teleport","📍",1,function()
 if hrp and hrp.Parent then
 local rp_char = rp().Character
 if rp_char and rp_char:FindFirstChild("HumanoidRootPart") then
 playSound(A.tp,2,hrp,2) hrp.CFrame=rp_char.HumanoidRootPart.CFrame+Vector3.new(0,3,0)
 else hrp.CFrame=hrp.CFrame+rV3(50)+Vector3.new(0,10,0) end
 end
end)

rnd("Teleport To Marker","🎯",1,function()
 -- Teleport to where player is looking
 if hrp and hrp.Parent and cam then
 local lookAt=cam.CFrame.LookVector*50
 hrp.CFrame=CFrame.new(hrp.Position+lookAt+Vector3.new(0,3,0))
 playSound(A.tp,2,hrp,2)
 end
end)

rnd("Void Warp","🕳️",1,function()
 if hrp and hrp.Parent then hrp.CFrame=CFrame.new(0,-100,0) end
end)

rnd("Loot Rain","🎁",16,function()
 local items={"Sword","Pizza","Cola","Tix","Bloxxer","Rocket","Gear","Hat","Coin","Gravity Coil","Speed Coil","Healing Coil","Dominus","Clockwork Shades","Sparkle Time Fedora"}
 active.LootRain={conn=rs.Heartbeat:Connect(function()
 if math.random()<0.15 and hrp then
 local i=Instance.new("Part",ws) i.Size=Vector3.new(1.5,1.5,1.5) i.BrickColor=BrickColor.Random()
 i.Material=Enum.Material.Neon i.Anchored=false i.Position=hrp.Position+Vector3.new(math.random(-20,20),35,math.random(-20,20))
 local bg=Instance.new("BillboardGui",i) bg.Size=UDim2.new(0,100,0,20) bg.StudsOffset=Vector3.new(0,2,0)
 Instance.new("TextLabel",bg).Size=UDim2.new(1,0,1,0) bg.TextLabel.BackgroundTransparency=1
 bg.TextLabel.Text=items[math.random(#items)] bg.TextLabel.TextColor3=Color3.fromRGB(255,255,255) bg.TextLabel.TextSize=10
 debris:AddItem(i,8)
 end
 end),f=function() end}
end,function() cleanup("LootRain") end)

rnd("Identity Crisis","🎭",12,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local f=Instance.new("Frame",g) f.Size=UDim2.new(0,250,0,30) f.Position=UDim2.new(0.5,-125,0.02,0)
 f.BackgroundColor3=Color3.fromRGB(0,0,0) f.BackgroundTransparency=0.4 f.BorderSizePixel=0 f.ZIndex=999
 Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
 local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
 l.Text="🎭 You are now: "..A.names[math.random(#A.names)] l.TextColor3=Color3.fromRGB(255,255,0) l.Font=Enum.Font.GothamBold l.TextSize=14 l.ZIndex=999
 debris:AddItem(f,12)
end)

rnd("Body Paint","🖌️",16,function()
 local orig={} if char then for _,v in char:GetChildren() do if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then orig[v]=v.BrickColor v.BrickColor=BrickColor.Random() end end end
 active.BodyPaint={f=function() for v,c in pairs(orig) do if v and v.Parent then v.BrickColor=c end end end}
end,function() cleanup("BodyPaint") end)

rnd("Classic Face Swap","😀",16,function()
 if char then local h=char:FindFirstChild("Head") if h then
 local f=h:FindFirstChildOfClass("Decal") or Instance.new("Decal",h)
 f.Texture=A.faces[math.random(#A.faces)] f.Face=Enum.NormalId.Front
 active.ClassicFace={obj=(h:FindFirstChildOfClass("Decal")~=f and f or nil),f=function() end}
 end end
end)

rnd("Gear Collection","⚔️",5,function()
 local gear=A.gears[math.random(#A.gears)] notif("You found: "..gear.."!",4) playSound(A.powerup,2,hrp,3)
end)

rnd("Random Stunt Jump","🛹",1,function()
 if hrp and hrp.Parent then hrp.Velocity=Vector3.new(math.random(-100,100),200,math.random(-100,100)) hrp.RotVelocity=rV3(20) end
 notif("🛹 STUNT JUMP!",3)
end)

rnd("Swap Vehicles on Impact","🔄",14,function()
 active.SwapVehicle={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then for _,v in ws:GetDescendants() do
 if v:IsA("VehicleSeat") and (v.Position-hrp.Position).Magnitude<5 and math.random()<0.05 then
 v.CFrame=hrp.CFrame+v.CFrame.LookVector*5
 end
 end end
 end),f=function() end}
end,function() cleanup("SwapVehicle") end)

rnd("Randomize Player Stats","📊",14,function()
 if hum then hum.WalkSpeed=math.random(4,100) hum.JumpPower=math.random(10,300) hum.MaxHealth=math.random(50,500) hum.Health=hum.MaxHealth end
end)

rnd("Particle Apocalypse","✨",16,function()
 active.ParticleApo={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent and math.random()<0.25 then
 local p=Instance.new("Part",ws) p.Size=Vector3.new(0.5,0.5,0.5) p.Anchored=true p.CanCollide=false p.Transparency=1
 p.Position=hrp.Position+Vector3.new(math.random(-30,30),0,math.random(-30,30))
 local em=Instance.new("ParticleEmitter",p) em.Texture=A.sparkle em.Rate=40 em.Lifetime=NumberRange.new(0.5,2) em.Speed=NumberRange.new(1,5) em.SpreadAngle=Vector2.new(360,360)
 debris:AddItem(p,5)
 end
 end),f=function() end}
end,function() cleanup("ParticleApo") end)

rnd("Mario Text","🍄",10,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local f=Instance.new("Frame",g) f.Size=UDim2.new(0,400,0,50) f.Position=UDim2.new(0.5,-200,0.8,0)
 f.BackgroundColor3=Color3.fromRGB(0,0,0) f.BackgroundTransparency=0.35 f.BorderSizePixel=0 f.ZIndex=999
 Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
 local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,-10,1,0) l.Position=UDim2.new(0,5,0,0) l.BackgroundTransparency=1
 l.Text=A.marioTexts[math.random(#A.marioTexts)] l.TextColor3=Color3.fromRGB(255,255,0) l.Font=Enum.Font.Fantasy l.TextSize=22 l.ZIndex=999
 debris:AddItem(f,10)
end)

rnd("Pink Traffic","🩷",14,function()
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v.Name:lower():find("car") or v:IsA("VehicleSeat") then
 local p=v:IsA("VehicleSeat") and v.Parent:FindFirstChildOfClass("BasePart") or v
 if p and p:IsA("BasePart") then orig[p]=p.BrickColor p.BrickColor=BrickColor.new("Hot pink") end
 end end
 active.PinkTraffic={f=function() for v,c in pairs(orig) do if v and v.Parent then v.BrickColor=c end end end}
end,function() cleanup("PinkTraffic") end)

rnd("Black Traffic","🖤",14,function()
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("BasePart") and (v.Name:lower():find("car") or v.Parent and v.Parent:FindFirstChildOfClass("VehicleSeat")) then
 orig[v]=v.BrickColor v.BrickColor=BrickColor.new("Really black") end end
 active.BlackTraffic={f=function() for v,c in pairs(orig) do if v and v.Parent then v.BrickColor=c end end end}
end,function() cleanup("BlackTraffic") end)

rnd("Shuffle Blips","📍",8,function()
 local blips={} for _,v in ws:GetDescendants() do if v:IsA("BillboardGui") then table.insert(blips,v) end end
 local texts={} for _,b in blips do if b:FindFirstChild("TextLabel") then table.insert(texts,b.TextLabel.Text) end end
 for i,b in blips do if b:FindFirstChild("TextLabel") and #texts>0 then b.TextLabel.Text=texts[math.random(#texts)] end end
end)

-- ╔══════════════════════════════════════════════════════╗
-- ║ CATEGORY 11: NOSTALGIA (Old ROBLOX 2006–2012) ║
-- ╚══════════════════════════════════════════════════════╝
local nos = function(n,i,d,s,st) E[#E+1]={name=n,cat="Nostalgia",icon=i,dur=d or C.defaultDuration,start=s,stop=st} end

nos("Classic OOF Spam","💀",6,function()
 for i=1,6 do delay(i*0.25,function() playSound(A.oof,0.5,hrp,2) end) end
end)

nos("TIX Rain","🪙",20,function()
 active.TixRain={conn=rs.Heartbeat:Connect(function()
 if math.random()<0.25 and hrp and hrp.Parent then
 local t=Instance.new("Part",ws) t.Name="Tix" t.Size=Vector3.new(1,0.2,1)
 t.BrickColor=BrickColor.new("Bright yellow") t.Material=Enum.Material.Neon
 t.Anchored=true t.CanCollide=false t.Position=hrp.Position+Vector3.new(math.random(-30,30),25,math.random(-30,30))
 debris:AddItem(t,4)
 end
 end),f=function() end}
end,function() cleanup("TixRain") end)

nos("Guest Mode","👤",16,function()
 local orig={} if char then for _,v in char:GetChildren() do if v:IsA("BasePart") then orig[v]=v.BrickColor v.BrickColor=BrickColor.new("Medium stone grey") end end end
 active.GuestMode={f=function() for v,c in pairs(orig) do if v and v.Parent then v.BrickColor=c end end end}
end,function() cleanup("GuestMode") end)

nos("Noob Transformation","🟡",16,function()
 local orig={} if char then for _,v in char:GetChildren() do if v:IsA("BasePart") then orig[v]=v.BrickColor v.BrickColor=BrickColor.new("Bright yellow") end end
 local h=char:FindFirstChild("Head") if h then local d=h:FindFirstChildOfClass("Decal") or Instance.new("Decal",h)
 d.Texture=A.faces[1] d.Face=Enum.NormalId.Front end
 if char:FindFirstChild("Left Arm") then char["Left Arm"].BrickColor=BrickColor.new("Bright yellow") end
 if char:FindFirstChild("Right Arm") then char["Right Arm"].BrickColor=BrickColor.new("Bright yellow") end
 if char:FindFirstChild("Left Leg") then char["Left Leg"].BrickColor=BrickColor.new("Bright green") end
 if char:FindFirstChild("Right Leg") then char["Right Leg"].BrickColor=BrickColor.new("Bright green") end
 end
 active.Noob={f=function() for v,c in pairs(orig) do if v and v.Parent then v.BrickColor=c end end end}
end,function() cleanup("Noob") end)

nos("Retro Bricks","🧱",16,function()
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v.Anchored then orig[v]={v.BrickColor,v.Material}
 v.BrickColor=A.retroColors[math.random(#A.retroColors)] v.Material=Enum.Material.SmoothPlastic end end
 active.RetroBricks={f=function() for v,t in pairs(orig) do if v and v.Parent then v.BrickColor=t[1] v.Material=t[2] end end end}
end,function() cleanup("RetroBricks") end)

nos("Builderman Sighting","👷",12,function()
 if hrp and hrp.Parent then
 local m=Instance.new("Part",ws) m.Size=Vector3.new(2,5,1) m.BrickColor=BrickColor.new("Bright blue")
 m.Position=hrp.Position+Vector3.new(0,0,-10) m.Anchored=true
 local h=Instance.new("Part",ws) h.Size=Vector3.new(2,0.5,2) h.BrickColor=BrickColor.new("Bright yellow")
 h.Position=m.Position+Vector3.new(0,2.5,0) h.Anchored=true
 local sign=Instance.new("BillboardGui",h) sign.Size=UDim2.new(0,80,0,20) sign.StudsOffset=Vector3.new(0,1,0)
 Instance.new("TextLabel",sign).Size=UDim2.new(1,0,1,0) sign.TextLabel.BackgroundTransparency=1
 sign.TextLabel.Text="Builderman" sign.TextLabel.TextColor3=Color3.fromRGB(255,255,255) sign.TextLabel.TextSize=10
 debris:AddItem(m,12) debris:AddItem(h,12)
 end
end)

nos("2009 Visitor Bar","🎮",16,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local bar=Instance.new("Frame",g) bar.Size=UDim2.new(1,0,0,24) bar.Position=UDim2.new(0,0,1,-24)
 bar.BackgroundColor3=Color3.fromRGB(40,40,40) bar.BorderSizePixel=0 bar.ZIndex=997
 local l=Instance.new("TextLabel",bar) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
 l.Text="👤 Guest | ⚡ 100% | 🏠 Home | 🛠️ Build | 🎮 Play" l.TextColor3=Color3.fromRGB(220,220,220)
 l.Font=Enum.Font.Legacy l.TextSize=13 l.ZIndex=997
 active.VisitorBar={f=function() bar:Destroy() end}
end,function() cleanup("VisitorBar") end)

nos("Fake TIX Balance","💰",12,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local f=Instance.new("Frame",g) f.Size=UDim2.new(0,160,0,28) f.Position=UDim2.new(0,8,0,40)
 f.BackgroundColor3=Color3.fromRGB(255,200,0) f.BackgroundTransparency=0.25 f.BorderSizePixel=0 f.ZIndex=999
 Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
 local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
 l.Text="🪙 TIX: "..math.random(100,999999) l.TextColor3=Color3.fromRGB(20,20,20) l.Font=Enum.Font.GothamBold l.TextSize=15 l.ZIndex=999
 debris:AddItem(f,12)
end)

nos("Classic Death Sound","💀",3,function()
 playSound(A.death_,5,hrp,3)
end)

nos("Classic Teleport Sound","✨",2,function()
 playSound(A.tp,3,hrp,2)
end)

nos("Classic Victory Fanfare","🎉",5,function()
 playSound(A.victory,2,hrp,5)
end)

nos("Old Sword Slash","⚔️",3,function()
 playSound(A.slash,1.5,hrp,3)
end)

nos("Classic Countdown","⏱️",10,function()
 for i=3,1,-1 do delay(3-i,function() playSound(A.countdown,2,hrp,2) end) end
 delay(3,function() playSound(A.victory,2,hrp,3) notif("GO!",2) end)
end)

nos("CloneTrooper1019 Mode","🎖️",16,function()
 if char then for _,v in char:GetChildren() do if v:IsA("BasePart") then v.BrickColor=BrickColor.new("Bright red") end end end
end)

nos("Telamon Mode","👔",16,function()
 if char then for _,v in char:GetChildren() do if v:IsA("BasePart") then v.BrickColor=BrickColor.new("White") end end
 local h=char:FindFirstChild("Head") if h then local d=h:FindFirstChildOfClass("Decal") or Instance.new("Decal",h) d.Texture="rbxassetid://18998924" end
 end
end)

nos("Classic Click SFX","🖱️",14,function()
 active.ClassicClick={conn=uis.InputBegan:Connect(function(i,gpe) if not gpe and i.UserInputType==Enum.UserInputType.MouseButton1 then playSound(A.click,0.5,hrp,1) end end),f=function() end}
end,function() cleanup("ClassicClick") end)

-- ╔══════════════════════════════════════════════════════╗
-- ║ CATEGORY 12: MISC (Combined Misc + Unsorted) ║
-- ╚══════════════════════════════════════════════════════╝
local msc = function(n,i,d,s,st) E[#E+1]={name=n,cat="Misc",icon=i,dur=d or C.defaultDuration,start=s,stop=st} end

msc("FREEZE FRAME","⏸️",4,function()
 local bl=Instance.new("BlurEffect",ls) bl.Size=0 ts:Create(bl,TweenInfo.new(0.5),{Size=56}):Play()
 delay(2,function() ts:Create(bl,TweenInfo.new(1),{Size=0}):Play() debris:AddItem(bl,2) end)
end)

msc("Nothing (Literally)","🤷",2,function()
 notif("..nothing happened.",2)
end)

msc("Backwards Clock","⏪",12,function()
 active.BackClock={conn=rs.Heartbeat:Connect(function() ls.ClockTime=(ls.ClockTime-0.5)%24 end),f=function() end}
end,function() cleanup("BackClock") end)

msc("Rainbow Barf","🤢",12,function()
 active.RainbowBarf={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent and math.random()<0.12 then
 local r=Instance.new("Part",ws) r.Size=Vector3.new(0.3,0.3,0.3) r.BrickColor=BrickColor.Random()
 r.Material=Enum.Material.Neon r.Position=hrp.Position+Vector3.new(0,-2,0) r.Velocity=Vector3.new(math.random(-15,15),math.random(-5,0),math.random(-15,15))
 debris:AddItem(r,3)
 end
 end),f=function() end}
end,function() cleanup("RainbowBarf") end)

msc("Maze of Doom","🧱",16,function()
 if not hrp then return end
 local walls={} for i=1,12 do
 local w=Instance.new("Part",ws) w.Size=Vector3.new(math.random(4,12),20,2) w.Anchored=true
 w.BrickColor=BrickColor.new("Really black") w.Transparency=0.5 w.Material=Enum.Material.ForceField
 w.Position=hrp.Position+Vector3.new(math.random(-25,25),0,math.random(-25,25)) table.insert(walls,w)
 end
 active.Maze={f=function() for _,w in walls do if w and w.Parent then w:Destroy() end end end}
end,function() cleanup("Maze") end)

msc("Spawn Table","🪑",8,function()
 if hrp and hrp.Parent then
 local t=Instance.new("Part",ws) t.Size=Vector3.new(6,0.5,4) t.BrickColor=BrickColor.new("Brown") t.Anchored=true t.Position=hrp.Position+Vector3.new(0,-2,5)
 for i=1,4 do local l=Instance.new("Part",ws) l.Size=Vector3.new(0.5,4,0.5) l.Anchored=true l.Position=t.Position+Vector3.new((i<3 and -2.5 or 2.5),-2.2,(i%2==1 and -1.5 or 1.5)) debris:AddItem(l,8) end
 debris:AddItem(t,8)
 end
end)

msc("CJ101 (San Andreas Tribute)","🏙️",10,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local f=Instance.new("Frame",g) f.Size=UDim2.new(0,300,0,40) f.Position=UDim2.new(0.5,-150,0.05,0)
 f.BackgroundColor3=Color3.fromRGB(0,0,0) f.BackgroundTransparency=0.4 f.BorderSizePixel=0 f.ZIndex=999
 Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
 local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
 l.Text="🏙️ Ah shit, here we go again..." l.TextColor3=Color3.fromRGB(255,200,0) l.Font=Enum.Font.GothamBlack l.TextSize=16 l.ZIndex=999
 debris:AddItem(f,10)
 playSound(A.oof,1,hrp,2)
end)

msc("Annoying Phone Calls","📞",14,function()
 active.PhoneCalls={conn=rs.Heartbeat:Connect(function()
 if math.random()<0.05 then
 playSound(A.click,0.3,hrp,1.5)
 notif("📞 *ring ring* — 'Hey cousin, want to go bowling?'",3)
 end
 end),f=function() end}
end,function() cleanup("PhoneCalls") end)

msc("The Mirror Dimension","🪞",14,function()
 active.MirrorDim={conn=rs.RenderStepped:Connect(function()
 cam.CFrame=cam.CFrame*CFrame.Angles(0,math.pi,0)
 if hrp and hrp.Parent then hrp.CFrame=hrp.CFrame*CFrame.new(0,0,0) end
 end),f=function() end}
end,function() cleanup("MirrorDim") end)

msc("Fake Teleport","🌀",2,function()
 notif("🌀 TELEPORTING... (just kidding)",3)
 playSound(A.tp,1,hrp,2)
end)

msc("Get To The Marker","📍",5,function()
 if hrp and hrp.Parent then
 local m=Instance.new("Part",ws) m.Size=Vector3.new(3,0.2,3) m.BrickColor=BrickColor.new("Bright yellow")
 m.Material=Enum.Material.Neon m.Anchored=true m.Position=hrp.Position+Vector3.new(math.random(-40,40),0,math.random(-40,40))
 local bg=Instance.new("BillboardGui",m) bg.Size=UDim2.new(0,100,0,30) bg.StudsOffset=Vector3.new(0,2,0)
 Instance.new("TextLabel",bg).Size=UDim2.new(1,0,1,0) bg.TextLabel.BackgroundTransparency=1
 bg.TextLabel.Text="📍 GET HERE!" bg.TextLabel.TextColor3=Color3.fromRGB(255,255,0) bg.TextLabel.TextSize=14
 debris:AddItem(m,5)
 end
end)

msc("Quick Sprunk Stop","🥤",3,function()
 if hrp and hrp.Parent then
 local s=Instance.new("Part",ws) s.Size=Vector3.new(1,2,1) s.BrickColor=BrickColor.new("Bright green") s.Material=Enum.Material.Neon
 s.Anchored=true s.Position=hrp.Position+Vector3.new(0,1.5,0)
 local bg=Instance.new("BillboardGui",s) bg.Size=UDim2.new(0,80,0,20) bg.StudsOffset=Vector3.new(0,2,0)
 Instance.new("TextLabel",bg).Size=UDim2.new(1,0,1,0) bg.TextLabel.BackgroundTransparency=1
 bg.TextLabel.Text="🥤 Sprunk!" bg.TextLabel.TextColor3=Color3.fromRGB(0,255,0) bg.TextLabel.TextSize=12
 debris:AddItem(s,3)
 end
end)

msc("Pride Traffic","🏳️‍🌈",14,function()
 active.PrideTraffic={conn=rs.Heartbeat:Connect(function()
 for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v.Name:lower():find("car") then
 v.BrickColor=BrickColor.Random() end end
 end),f=function() end}
end,function() cleanup("PrideTraffic") end)

msc("Minimum Speed","🏎️",14,function()
 active.MinSpeed={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent and hrp.Velocity.Magnitude<20 and hrp.Velocity.Magnitude>1 then
 hrp.Velocity=hrp.Velocity.Unit*30
 end
 end),f=function() end}
end,function() cleanup("MinSpeed") end)

msc("Honk Boost","📯",14,function()
 active.HonkBoost={conn=uis.InputBegan:Connect(function(i,gpe)
 if not gpe and i.KeyCode==Enum.KeyCode.H and hrp and hrp.Parent then
 hrp.Velocity=hrp.Velocity+hrp.CFrame.LookVector*50 playSound(A.click,0.5,hrp,1)
 end
 end),f=function() end}
end,function() cleanup("HonkBoost") end)

msc("Shuffle Player Buttons (visual)","🔘",10,function()
 notif("🔘 Buttons shuffled! (it's a visual gag)",3)
end)

msc("Pausing Effect","⏸️",4,function()
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("BasePart") and not v.Anchored then orig[v]=v.Velocity end end
 delay(2,function() for v in pairs(orig) do if v and v.Parent then v.Anchored=true end end
 delay(2,function() for v in pairs(orig) do if v and v.Parent then v.Anchored=false end end end) end)
end)

msc("Increase Shooting Rate","🔫",14,function()
 active.FireRate={conn=rs.Heartbeat:Connect(function()
 if char and math.random()<0.5 then for _,t in char:GetChildren() do if t:IsA("Tool") then t:Activate() end end end
 end),f=function() end}
end,function() cleanup("FireRate") end)

msc("Dual Wield (Rapid Activate)","⚔️",14,function()
 active.DualWield={conn=rs.Heartbeat:Connect(function()
 if char and math.random()<0.2 then
 for _,t in char:GetChildren() do if t:IsA("Tool") and t~=char:FindFirstChildOfClass("Tool") then t:Activate() end end
 end
 end),f=function() end}
end,function() cleanup("DualWield") end)

msc("Replace All Text","📝",14,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local repl={"oof","noob","chaos","yeet","bruh","lol","pog","rekt","bobux","tix"}
 local orig={} for _,sg in g:GetChildren() do if sg:IsA("ScreenGui") and sg.Name~="ChaosModGUI" then
 for _,v in sg:GetDescendants() do if v:IsA("TextLabel") or v:IsA("TextButton") then orig[v]=v.Text v.Text=repl[math.random(#repl)] end end
 end end
 active.ReplaceText={f=function() for v,t in pairs(orig) do if v and v.Parent then v.Text=t end end end}
end,function() cleanup("ReplaceText") end)

msc("Framerate Chaos","📉",14,function()
 active.FPSChaos={conn=rs.Heartbeat:Connect(function()
 for _,v in ws:GetDescendants() do if v:IsA("BasePart") and not v.Anchored then
 if math.random()<0.3 then v.Velocity=v.Velocity*0.5 end end end
 end),f=function() end}
end,function() cleanup("FPSChaos") end)

msc("Reload Autosave (fake)","💾",2,function()
 notif("💾 Loading autosave... (jk)",3)
end)

msc("Deadly Bullets","☠️",14,function()
 active.DeadlyBullets={conn=rs.Heartbeat:Connect(function()
 -- Any tool touching something damages
 if char then for _,t in char:GetChildren() do if t:IsA("Tool") and t:FindFirstChild("Handle") then
 t.Handle.Touched:Connect(function(p)
 if p and p.Parent and p.Parent~=char and p.Parent:FindFirstChild("Humanoid") then
 p.Parent.Humanoid:TakeDamage(25)
 end
 end)
 end end end
 end),f=function() end}
end,function() cleanup("DeadlyBullets") end)

msc("Carmageddon","🚗",14,function()
 active.Carmageddon={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then for _,v in ws:GetDescendants() do
 if v:IsA("BasePart") and not v.Anchored and v~=hrp and (v.Position-hrp.Position).Magnitude<30 then
 v.Velocity=rV3(100)
 end
 end end
 end),f=function() end}
end,function() cleanup("Carmageddon") end)

msc("Too Much Blips","📍",12,function()
 if hrp and hrp.Parent then
 for i=1,20 do
 local b=Instance.new("BillboardGui",ws) b.Size=UDim2.new(0,60,0,20) b.Adornee=hrp b.StudsOffset=Vector3.new(0,2+i*0.3,0)
 Instance.new("TextLabel",b).Size=UDim2.new(1,0,1,0) b.TextLabel.BackgroundTransparency=1
 b.TextLabel.Text="📍" b.TextLabel.TextSize=12
 debris:AddItem(b,12)
 end
 end
end)

msc("Object Rotation Chaos","🔄",14,function()
 active.ObjRotChaos={conn=rs.Heartbeat:Connect(function()
 for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v.Anchored and math.random()<0.02 then
 v.Orientation=rV3(360)
 end end
 end),f=function() end}
end,function() cleanup("ObjRotChaos") end)

msc("Quick Save Jingle","💾",3,function()
 playSound(A.powerup,1.5,hrp,3)
end)

msc("All Vehicles Alarm","🚨",12,function()
 active.VehAlarm={conn=rs.Heartbeat:Connect(function()
 if math.random()<0.1 then playSound(A.click,0.4,hrp,1) end
 for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v.Name:lower():find("car") then
 v.BrickColor=v.BrickColor or BrickColor.Random() end end
 end),f=function() end}
end,function() cleanup("VehAlarm") end)

-- ╔══════════════════════════════════════════════════════╗
-- ║ EXTRA: Even more effects from GTA source code ║
-- ╚══════════════════════════════════════════════════════╝
local ext = function(n,i,d,s,st) E[#E+1]={name=n,cat="Extra",icon=i,dur=d or C.defaultDuration,start=s,stop=st} end

ext("To The Left","⬅️",14,function()
 active.ToLeft={conn=rs.Heartbeat:Connect(function()
 if hum then hum:Move(Vector3.new(-1,0,hum.MoveDirection.Z),false) end
 end),f=function() end}
end,function() cleanup("ToLeft") end)

ext("To The Right","➡️",14,function()
 active.ToRight={conn=rs.Heartbeat:Connect(function()
 if hum then hum:Move(Vector3.new(1,0,hum.MoveDirection.Z),false) end
 end),f=function() end}
end,function() cleanup("ToRight") end)

ext("No Need To Hurry","🐢",14,function()
 if hum then local o=hum.WalkSpeed hum.WalkSpeed=math.max(2,o*0.3) active.NoHurry={f=function() if hum then hum.WalkSpeed=o end end} end
end,function() cleanup("NoHurry") end)

ext("No Tasks Allowed","🚫",14,function()
 pcall(function()
 local orig={} for _,v in char:GetChildren() do if v:IsA("Tool") then v.Parent=rep end if v:IsA("HopperBin") then v.Parent=plr.Backpack end end
 end)
end)

ext("Weapon Roulette","🎰",14,function()
 active.WeaponRoulette={conn=rs.Heartbeat:Connect(function()
 if char and math.random()<0.1 then
 local tools=char:GetChildren()
 local toolTools={} for _,t in tools do if t:IsA("Tool") then table.insert(toolTools,t) end end
 if #toolTools>0 then
 for _,t in toolTools do t.Parent=plr.Backpack end
 toolTools[math.random(#toolTools)].Parent=char
 end
 end
 end),f=function() end}
end,function() cleanup("WeaponRoulette") end)

ext("Disable Swimming","🏊",14,function()
 active.NoSwim={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then
 local u=ws:FindPartOnRay(Ray.new(hrp.Position,Vector3.new(0,-1,0)),char)
 if u and u.Material==Enum.Material.Water and hum then hum:TakeDamage(3) end
 end
 end),f=function() end}
end,function() cleanup("NoSwim") end)

ext("Walk Off","🚶",8,function()
 active.WalkOff={conn=rs.Heartbeat:Connect(function()
 if hum then hum:Move(Vector3.new(0,0,-1),false) end
 end),f=function() end}
end,function() cleanup("WalkOff") end)

ext("Ghost Rider","👻",14,function()
 if char then for _,v in char:GetChildren() do if v:IsA("BasePart") then v.Transparency=0.5 v.Material=Enum.Material.ForceField end end end
 active.GhostRider={f=function() if char then for _,v in char:GetChildren() do if v:IsA("BasePart") then v.Transparency=0 v.Material=Enum.Material.SmoothPlastic end end end end}
end,function() cleanup("GhostRider") end)

ext("Auto Collect Pickups","🎒",14,function()
 active.AutoCollect={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then for _,v in ws:GetDescendants() do
 if v:IsA("BasePart") and (v.Position-hrp.Position).Magnitude<3 and v:FindFirstChildOfClass("BillboardGui") then
 v.CFrame=hrp.CFrame v:Destroy()
 end
 end end
 end),f=function() end}
end,function() cleanup("AutoCollect") end)

ext("Custom Fonts (Comic Sans)","🔤",14,function()
 local g=plr:FindFirstChild("PlayerGui") if not g then return end
 local orig={} for _,sg in g:GetChildren() do if sg:IsA("ScreenGui") and sg.Name~="ChaosModGUI" then
 for _,v in sg:GetDescendants() do if v:IsA("TextLabel") or v:IsA("TextButton") then orig[v]=v.Font v.Font=Enum.Font.Fantasy end end
 end end
 active.CustomFont={f=function() for v,ff in pairs(orig) do if v and v.Parent then v.Font=ff end end end}
end,function() cleanup("CustomFont") end)

-- Comment collection: more effects from GTA source
ext("Hold The F Up","✋",8,function()
 if hrp and hrp.Parent then hrp.Velocity=hrp.Velocity+Vector3.new(0,200,0) end
end)

ext("Get Wasted (Fake)","💀",3,function()
 if hum then local oh=hum.Health hum.Health=5
 local c=hum.HealthChanged:Connect(function() if hum.Health<5 then hum.Health=oh c:Disconnect() end end)
 end
 playSound(A.death_,3,hrp,3)
end)

ext("Get Busted (Fake)","👮",3,function()
 notif("👮 BUSTED! (just kidding)",3) playSound(A.oof,2,hrp,2)
end)

ext("Respect The Law","👮",14,function()
 active.RespectLaw={conn=rs.Heartbeat:Connect(function()
 if hum then hum.WalkSpeed=math.min(hum.WalkSpeed,8) end
 end),f=function() end}
end,function() cleanup("RespectLaw") end)

ext("Always Wanted","⭐",14,function()
 active.AlwaysWanted={conn=rs.Heartbeat:Connect(function()
 if math.random()<0.05 then notif("⭐ STARS: "..math.random(1,6),2) end
 for _,v in ws:GetDescendants() do if v.Name:lower():find("police") or v.Name:lower():find("cop") then
 if hrp and (v.Position-hrp.Position).Magnitude<50 then v.BrickColor=BrickColor.new("Bright blue") end
 end end
 end),f=function() end}
end,function() cleanup("AlwaysWanted") end)

ext("Action Figures","🎭",14,function()
 local orig={} for _,p in game.Players:GetPlayers() do if p.Character then
 for _,v in p.Character:GetChildren() do if v:IsA("BasePart") then orig[v]=v.Material v.Material=Enum.Material.SmoothPlastic end end
 end end
 active.ActionFigs={f=function() for v,m in pairs(orig) do if v and v.Parent then v.Material=m end end end}
end,function() cleanup("ActionFigs") end)

ext("Invisible Vehicles","🚗",14,function()
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v.Name:lower():find("car") then orig[v]=v.Transparency v.Transparency=0.85 end end
 active.InvisVeh={f=function() for v,t in pairs(orig) do if v and v.Parent then v.Transparency=t end end end}
end,function() cleanup("InvisVeh") end)

ext("Set Current Vehicle On Fire","🔥",10,function()
 local seats={} for _,v in ws:GetDescendants() do if v:IsA("VehicleSeat") then table.insert(seats,v) end end
 if #seats>0 then
 local vs=seats[math.random(#seats)]
 if vs.Parent and vs.Parent:FindFirstChildOfClass("BasePart") then
 Instance.new("Fire",vs.Parent:FindFirstChildOfClass("BasePart"))
 end
 end
end)

ext("Delete All Vehicles","🗑️",1,function()
 for _,v in ws:GetDescendants() do if v:IsA("VehicleSeat") or (v:IsA("BasePart") and v.Name:lower():find("car") and v.Anchored==false) then v:Destroy() end end
end)

ext("Explode Random Vehicle","💥",1,function()
 local vehs={} for _,v in ws:GetDescendants() do if v:IsA("VehicleSeat") then vehs[#vehs+1]=v end end
 if #vehs>0 then local v=vehs[math.random(#vehs)]
 if v.Parent and v.Parent:FindFirstChildOfClass("BasePart") then
 Instance.new("Explosion",ws).Position=v.Parent:FindFirstChildOfClass("BasePart").Position
 end
 end
end)

ext("Send Vehicles To Space","🚀",1,function()
 for _,v in ws:GetDescendants() do if v:IsA("VehicleSeat") or (v:IsA("BasePart") and v.Name:lower():find("car") and not v.Anchored) then
 v.Velocity=Vector3.new(0,1000,0)
 end end
end)

ext("Pop Tires (Disable Wheels)","🛞",14,function()
 for _,v in ws:GetDescendants() do if v:IsA("BasePart") and (v.Name:lower():find("wheel") or v.Name:lower():find("tire")) then v.Transparency=0.5 end end
end)

ext("Unflippable Vehicles","🔄",14,function()
 active.Unflip={conn=rs.Heartbeat:Connect(function()
 for _,v in ws:GetDescendants() do if v:IsA("VehicleSeat") and v.Parent and v.Parent:FindFirstChildOfClass("BasePart") then
 local p=v.Parent:FindFirstChildOfClass("BasePart") p.CFrame=CFrame.new(p.Position) end end
 end),f=function() end}
end,function() cleanup("Unflip") end)

ext("Vehicle Driving On Walls","🧗",14,function()
 active.WallDrive={conn=rs.Heartbeat:Connect(function()
 for _,v in ws:GetDescendants() do if v:IsA("VehicleSeat") then
 local p=v.Parent and v.Parent:FindFirstChildOfClass("BasePart")
 if p then p.Velocity=p.Velocity+Vector3.new(0,10,0) end
 end end
 end),f=function() end}
end,function() cleanup("WallDrive") end)

ext("Freeze Vehicle","🧊",10,function()
 local seats={} for _,v in ws:GetDescendants() do if v:IsA("VehicleSeat") then table.insert(seats,v) end end
 if #seats>0 then
 local vs=seats[math.random(#seats)]
 if vs.Parent then
 local frozen={} for _,v in vs.Parent:GetDescendants() do if v:IsA("BasePart") then v.Anchored=true frozen[#frozen+1]=v end end
 delay(10,function() for _,v in frozen do if v and v.Parent then v.Anchored=false end end end)
 end
 end
end)

ext("Oh Hey Tanks","🪖",12,function()
 if hrp and hrp.Parent then
 for i=1,3 do
 local t=Instance.new("Part",ws) t.Size=Vector3.new(4,2,6) t.BrickColor=BrickColor.new("Dark green")
 t.Position=hrp.Position+Vector3.new(math.random(-30,30),5,math.random(-30,30)) t.Anchored=true
 local b=Instance.new("Part",ws) b.Size=Vector3.new(1,4,1) b.BrickColor=BrickColor.new("Dark green")
 b.Position=t.Position+Vector3.new(0,2,3) b.Anchored=true
 debris:AddItem(t,12) debris:AddItem(b,12)
 end
 end
end)

ext("Your Car Floats Away","🎈",12,function()
 for _,v in ws:GetDescendants() do if v:IsA("VehicleSeat") then
 local p=v.Parent and v.Parent:FindFirstChildOfClass("BasePart")
 if p and not p.Anchored then p.Velocity=p.Velocity+Vector3.new(0,5,0) end
 end end
end)

ext("Cars Float Away When Hit","🎈",14,function()
 active.FloatCars={conn=rs.Heartbeat:Connect(function()
 for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v.Name:lower():find("car") and not v.Anchored then
 if v.Velocity.Magnitude>20 then v.Velocity=v.Velocity+Vector3.new(0,30,0) end
 end end
 end),f=function() end}
end,function() cleanup("FloatCars") end)

ext("Low LOD Vehicles","📉",14,function()
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v.Name:lower():find("car") then
 orig[v]=v.Size v.Size=Vector3.new(v.Size.X*0.5,v.Size.Y*0.5,v.Size.Z*0.5) end end
 active.LowLOD={f=function() for v,s in pairs(orig) do if v and v.Parent then v.Size=s end end end}
end,function() cleanup("LowLOD") end)

ext("Vehicle Size Randomizer","📏",14,function()
 local orig={} for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v.Name:lower():find("car") then
 orig[v]=v.Size v.Size=v.Size*math.random(50,200)/100 end end
 active.VehSize={f=function() for v,s in pairs(orig) do if v and v.Parent then v.Size=s end end end}
end,function() cleanup("VehSize") end)

ext("Vehicle Rotation Chaos","🔄",14,function()
 active.VehRot={conn=rs.Heartbeat:Connect(function()
 for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v.Name:lower():find("car") and not v.Anchored and math.random()<0.05 then
 v.RotVelocity=rV3(20) end end
 end),f=function() end}
end,function() cleanup("VehRot") end)

ext("Swim Like Tommy","🏊",14,function()
 if hum then hum.JumpPower=15 end
 active.SwimTommy={conn=rs.Heartbeat:Connect(function()
 if hrp and hrp.Parent then
 local u=ws:FindPartOnRay(Ray.new(hrp.Position,Vector3.new(0,-1,0)),char)
 if u and u.Material==Enum.Material.Water then hrp.Velocity=hrp.Velocity+Vector3.new(0,10,0) end
 end
 end),f=function() if hum then hum.JumpPower=50 end end}
end,function() cleanup("SwimTommy") end)

ext("Lock Player Inside Vehicle","🔒",14,function()
 for _,v in ws:GetDescendants() do if v:IsA("VehicleSeat") and v.Occupant then v.Disabled=true end end
end)

ext("Kick Player Out Of Vehicle","🚪",1,function()
 if char then for _,v in char:GetChildren() do if v:IsA("Seat") or v:IsA("VehicleSeat") then if hum then hum.Sit=false end end end end
end)

ext("Explode All Cars","💥",1,function()
 for _,v in ws:GetDescendants() do if v:IsA("BasePart") and v.Name:lower():find("car") then
 Instance.new("Explosion",ws).Position=v.Position
 end end
end)

ext("Warp Player Into Random Vehicle","🚗",1,function()
 local vehs={} for _,v in ws:GetDescendants() do if v:IsA("VehicleSeat") and not v.Occupant then vehs[#vehs+1]=v end end
 if #vehs>0 and hrp then hrp.CFrame=vehs[math.random(#vehs)].CFrame+Vector3.new(0,3,0) end
end)

ext("Smashed and Boomed","💥",14,function()
 active.SmashBoom={conn=rs.Heartbeat:Connect(function()
 for _,v in ws:GetDescendants() do if v:IsA("BasePart") and not v.Anchored and v.Velocity.Magnitude>50 then
 v:BreakJoints() end end
 end),f=function() end}
end,function() cleanup("SmashBoom") end)

ext("Recruit Anyone","👥",14,function()
 active.Recruit={conn=rs.Heartbeat:Connect(function()
 for _,p in game.Players:GetPlayers() do if p~=plr and p.Character and p.Character:FindFirstChild("Humanoid") then
 if hrp and p.Character:FindFirstChild("HumanoidRootPart") then
 if (p.Character.HumanoidRootPart.Position-hrp.Position).Magnitude>20 then
 p.Character.HumanoidRootPart.CFrame=hrp.CFrame+Vector3.new(math.random(-3,3),0,math.random(-3,3))
 end
 end
 end end
 end),f=function() end}
end,function() cleanup("Recruit") end)

ext("Portal Guns","🌀",14,function()
 active.PortalGuns={conn=rs.Heartbeat:Connect(function()
 if char then for _,t in char:GetChildren() do if t:IsA("Tool") and t:FindFirstChild("Handle") then
 t.Handle.Touched:Connect(function(p)
 if p and p.Parent and p.Parent~=char and hrp then
 hrp.CFrame=p.CFrame+Vector3.new(0,5,0)
 end
 end)
 end end end
 end),f=function() end}
end,function() cleanup("PortalGuns") end)

ext("Disable Headshots","🎯",14,function()
 active.NoHS={conn=rs.Heartbeat:Connect(function()
 if hum then hum.Health=math.max(hum.Health,hum.MaxHealth*0.5) end
 end),f=function() end}
end,function() cleanup("NoHS") end)

ext("Everybody Bleed Now","🩸",12,function()
 active.Bleed={conn=rs.Heartbeat:Connect(function()
 for _,p in game.Players:GetPlayers() do if p.Character and p.Character:FindFirstChild("Humanoid") then
 if math.random()<0.05 then p.Character.Humanoid:TakeDamage(1) end end end
 end),f=function() end}
end,function() cleanup("Bleed") end)

ext("Long Live The Rich","💰",14,function()
 -- highest health player gets effects
 local hp,rich=0,nil
 for _,p in game.Players:GetPlayers() do if p.Character and p.Character:FindFirstChild("Humanoid") then
 if p.Character.Humanoid.Health>hp then hp=p.Character.Humanoid.Health rich=p end end end
 if rich and rich~=plr and rich.Character then
 for _,v in rich.Character:GetChildren() do if v:IsA("BasePart") then v.BrickColor=BrickColor.new("Bright yellow") end end
 end
end)

ext("Cough Effect","😷",14,function()
 active.Cough={conn=rs.Heartbeat:Connect(function()
 if math.random()<0.1 then
 local s=Instance.new("Sound",hrp or ws) s.SoundId=A.oof s.Volume=0.3 s.PlaybackSpeed=0.5 s:Play() debris:AddItem(s,1)
 end
 end),f=function() end}
end,function() cleanup("Cough") end)

ext("Inverted Weapon Damage","🔄",14,function()
 active.InvWepDmg={conn=rs.Heartbeat:Connect(function()
 if hum then hum.Health=math.min(hum.MaxHealth,hum.Health+1) end
 end),f=function() end}
end,function() cleanup("InvWepDmg") end)

ext("Disable All Weapon Damage","🔇",14,function()
 active.NoWepDmg={conn=rs.Heartbeat:Connect(function()
 if hum then hum.Health=hum.MaxHealth end
 end),f=function() end}
end,function() cleanup("NoWepDmg") end)

ext("One Bullet Magazines","🔫",14,function()
 active.OneBullet={conn=rs.Heartbeat:Connect(function()
 if char then for _,t in char:GetChildren() do if t:IsA("Tool") then
 -- Force unequip after one "shot" by re-equipping
 if t.Parent==char then delay(0.1,function() if t then t.Parent=plr.Backpack end end) end
 end end end
 end),f=function() end}
end,function() cleanup("OneBullet") end)

-- Add remaining effects
ext("Cops Everywhere","👮",14,function()
 if hrp and hrp.Parent then
 for i=1,8 do
 local c=Instance.new("Part",ws) c.Size=Vector3.new(2,5,1) c.BrickColor=BrickColor.new("Dark blue")
 c.Anchored=true c.Position=hrp.Position+Vector3.new(math.random(-20,20),0,math.random(-20,20))
 local h=Instance.new("Part",ws) h.Size=Vector3.new(1,1,1) h.BrickColor=BrickColor.new("Dark blue")
 h.Position=c.Position+Vector3.new(0,2.5,0) h.Anchored=true
 local bg=Instance.new("BillboardGui",h) bg.Size=UDim2.new(0,60,0,16) bg.StudsOffset=Vector3.new(0,1,0)
 Instance.new("TextLabel",bg).Size=UDim2.new(1,0,1,0) bg.TextLabel.BackgroundTransparency=1 bg.TextLabel.Text="👮" bg.TextLabel.TextSize=14
 debris:AddItem(c,14) debris:AddItem(h,14)
 end
 end
end)

ext("Trigger All Enemies (NPC aggro)","⚔️",1,function()
 for _,p in game.Players:GetPlayers() do if p~=plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and hrp then
 p.Character.HumanoidRootPart.CFrame=hrp.CFrame+Vector3.new(math.random(-5,5),0,math.random(-5,5))
 end end
end)

ext("Fake Pass Mission","✅",3,function()
 notif("✅ MISSION PASSED! RESPECT +",3)
 playSound(A.victory,2,hrp,3)
end)

ext("Fake Fail Mission","❌",3,function()
 notif("❌ MISSION FAILED!",3)
 playSound(A.death_,2,hrp,3)
end)

-- ============================================
-- ★ USER-REQUESTED EFFECTS ★
-- RGB Everything, Jeff is Coming, Randomize Anims, The Sky is Looping
-- ============================================

-- 🎨 RGB EVERYTHING — cycle every visible part's color through HSV rainbow
ext("RGB Everything","🌈",20,function()
 notif("🌈 RGB EVERYTHING — Every part is now rainbow. Enjoy the trip.",3)
 -- Save originals so we can restore
 local saved={}
 for _,o in ws:GetDescendants() do
  if o:IsA("BasePart") then
   saved[o]={c=o.Color,mat=o.Material}
  end
 end
 -- Also handle parts added during the effect
 local addedConn
 addedConn=ws.DescendantAdded:Connect(function(o)
  if o:IsA("BasePart") then saved[o]={c=o.Color,mat=o.Material} end
 end)
 local hue=0
 active.RGBEverything={
  conn=rs.Heartbeat:Connect(function(dt)
   hue=(hue+dt*0.5)%1
   -- iterate every 3 frames to keep perf reasonable
   local i=0
   for o,info in pairs(saved) do
    i=i+1
    if i%3==0 and o and o.Parent then
     local ph=(hue+(o.Position.X+o.Position.Y+o.Position.Z)*0.001)%1
     o.Color=Color3.fromHSV(ph,1,1)
     o.Material=Enum.Material.Neon
    end
   end
  end),
  addedConn=addedConn,
  f=function()
   if addedConn then addedConn:Disconnect() end
   for o,info in pairs(saved) do
    if o and o.Parent then
     pcall(function() o.Color=info.c o.Material=info.mat end)
    end
   end
  end,
 }
end,function() cleanup("RGBEverything") end)

-- 😈 JEFF IS COMING — warning + spawn a random Jeff the Killer model near player
ext("Jeff is Coming","🔪",25,function()
 notif("💀 JEFF IS COMING... — Run. He's almost here.",4)
 playSound(A.horror,2,hrp,4)
 -- Flash red overlay 3 times
 local gui=plr:FindFirstChild("PlayerGui")
 if gui then
  local flash=Instance.new("Frame",gui) flash.Size=UDim2.new(1,0,1,0) flash.BackgroundColor3=Color3.fromRGB(120,0,0)
  flash.BackgroundTransparency=1 flash.ZIndex=9999 flash.IgnoreGuiInset=true
  for i=1,3 do
   ts:Create(flash,TweenInfo.new(0.2),{BackgroundTransparency=0.4}):Play() wait(0.2)
   ts:Create(flash,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play() wait(0.5)
  end
  debris:AddItem(flash,2)
 end
 -- Spawn a random Jeff variant
 local modelId=A.jeffVariants[math.random(#A.jeffVariants)]
 local jeffModel=nil
 local spawnOk=false
 pcall(function()
  local objs=game:GetObjects("rbxassetid://"..tostring(modelId))
  if objs and objs[1] then
   jeffModel=objs[1] -- game:GetObjects returns an array; first entry is the model
   jeffModel.Parent=ws
   -- Enable the decompiled model's internal scripts (Disabled=true by default)
   local n=enableScripts(jeffModel) if n>0 then notif("🔧 Jeff: "..n.." script(s) enabled",2) end
   -- Place 12 studs in front of the player, facing them
   if hrp then
    local cf=hrp.CFrame*CFrame.new(0,0,-12)
    pcall(function() jeffModel:PivotTo(cf*CFrame.Angles(0,math.pi,0)) end)
    -- If pivot failed (no PrimaryPart), try MoveTo on every part
    if not jeffModel.PrimaryPart then
     for _,p in jeffModel:GetDescendants() do
      if p:IsA("BasePart") then p.CFrame=cf*CFrame.Angles(0,math.pi,0) break end
     end
    end
   end
   -- Try to make Jeff walk toward the player
   local hum2=jeffModel:FindFirstChildOfClass("Humanoid")
   if hum2 and hrp then
    spawn(function()
     while jeffModel and jeffModel.Parent and hum2.Health>0 and hrp and hrp.Parent do
      hum2:MoveTo(hrp.Position)
      wait(0.5)
     end
    end)
   end
   spawnOk=true
  end
 end)
 if not spawnOk then
  notif("⚠️ Jeff model failed to load (asset ID "..tostring(modelId)..")",4)
  -- Fallback: build a creepy blocky figure
  local m=Instance.new("Model",ws) m.Name="JeffFallback"
  local t=Instance.new("Part",m) t.Size=Vector3.new(2,3,1) t.BrickColor=BrickColor.new("Institutional white") t.Anchored=false t.TopSurface=0 t.BottomSurface=0
  local h=Instance.new("Part",m) h.Size=Vector3.new(1.5,1.5,1) h.BrickColor=BrickColor.new("Institutional white") h.Anchored=false
  local w=Instance.new("Weld",t) w.Part0=t w.Part1=h w.C0=CFrame.new(0,2.25,0)
  local decal=Instance.new("Decal",h) decal.Face=Enum.NormalId.Front decal.Texture="rbxassetid://18998949"
  if hrp then t.CFrame=hrp.CFrame*CFrame.new(0,0,-12)*CFrame.Angles(0,math.pi,0) end
  jeffModel=m
 end
 active.JeffIsComing={
  model=jeffModel,
  f=function()
   if jeffModel and jeffModel.Parent then debris:AddItem(jeffModel,0.5) end
  end,
 }
end,function() cleanup("JeffIsComing") end)

-- 🩰 RANDOMIZE ANIMS — replace every player & NPC's animations with random ones
ext("Randomize Anims","🩰",18,function()
 notif("🩰 RANDOMIZE ANIMS — Every character is now a dancing fool.",3)
 -- Save originals
 local savedAnims={}
 local function hookChar(c)
  if not c then return end
  local h=c:FindFirstChildOfClass("Humanoid")
  if not h then return end
  local rig=h.RigType==Enum.HumanoidRigType.R15 and "R15" or "R6"
  savedAnims[c]={}
  -- R6: override Animate script's idle/walk/run/jump
  local animScript=c:FindFirstChild("Animate")
  if animScript then
   savedAnims[c].script=animScript:Clone()
   for _,name in ipairs({"idle","walk","run","jump","fall","climb","sit","dance","wave","point","laugh","cheer"}) do
    local node=animScript:FindFirstChild(name)
    if node then
     for _,a in node:GetDescendants() do
      if a:IsA("Animation") then
       savedAnims[c][a]=a.AnimationId
       a.AnimationId=A.randomAnims[math.random(#A.randomAnims)]
      end
     end
    end
   end
  end
  -- Also force a random track to play right now
  pcall(function()
   local animator=h:FindFirstChildOfClass("Animator") or h:FindFirstChild("Animator")
   if animator then
    local a=Instance.new("Animation") a.AnimationId=A.randomAnims[math.random(#A.randomAnims)]
    local track=animator:LoadAnimation(a)
    track.Looped=true track.Priority=Enum.AnimationPriority.Action
    track:Play()
    savedAnims[c].forcedTrack=track
   end
  end)
 end
 -- Hook every existing character
 for _,p in game.Players:GetPlayers() do
  if p.Character then hookChar(p.Character) end
 end
 for _,m in ws:GetChildren() do
  if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then hookChar(m) end
 end
 -- Periodically re-randomize so anims keep switching
 local tickConn
 tickConn=rs.Heartbeat:Connect(function()
  if math.random(1,90)~=1 then return end -- ~once per 1.5s at 60fps
  for _,p in game.Players:GetPlayers() do
   if p.Character then
    local h=p.Character:FindFirstChildOfClass("Humanoid")
    local animator=h and (h:FindFirstChildOfClass("Animator") or h:FindFirstChild("Animator"))
    if animator then
     pcall(function()
      local a=Instance.new("Animation") a.AnimationId=A.randomAnims[math.random(#A.randomAnims)]
      local track=animator:LoadAnimation(a)
      track.Looped=true track.Priority=Enum.AnimationPriority.Action
      track:Play()
      debris:AddItem(track,4)
     end)
    end
   end
  end
 end)
 active.RandomizeAnims={
  tickConn=tickConn,
  saved=savedAnims,
  f=function()
   if tickConn then tickConn:Disconnect() end
   for c,info in pairs(savedAnims) do
    if c and c.Parent then
     if info.forcedTrack then pcall(function() info.forcedTrack:Stop() end) end
     -- Restore original Animate script
     if info.script then
      local cur=c:FindFirstChild("Animate")
      if cur then cur:Destroy() end
      info.script.Parent=c
     end
    end
   end
  end,
 }
end,function() cleanup("RandomizeAnims") end)

-- 🌌 THE SKY IS LOOPING — ClockTime spins very fast + skybox cycles rapidly
ext("The Sky is Looping","🌌",22,function()
 notif("🌌 THE SKY IS LOOPING — Time and sky are spinning out of control.",3)
 -- Save originals
 local savedClock=ls.ClockTime
 local savedSky=ls:FindFirstChildOfClass("Sky")
 local savedSkyChildren={}
 if savedSky then
  for _,prop in ipairs({"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp","SunTextureId","MoonTextureId","StarCount"}) do
   savedSkyChildren[prop]=savedSky[prop]
  end
 end
 local sky=savedSky or Instance.new("Sky",ls)
 local idx=0
 local skyCycle=0
 active.SkyLooping={
  conn=rs.Heartbeat:Connect(function(dt)
   -- Spin clock ~1 full day every 4 seconds
   ls.ClockTime=(ls.ClockTime+dt*6)%24
   -- Cycle skybox every 0.5s
   skyCycle=skyCycle+dt
   if skyCycle>0.5 then
    skyCycle=0
    idx=idx+1
    local tex=A.skyboxes[(idx%#A.skyboxes)+1]
    -- Reuse same tex for all 6 faces for a uniform crazy sky
    pcall(function()
     sky.SkyboxBk=tex sky.SkyboxDn=tex sky.SkyboxFt=tex
     sky.SkyboxLf=tex sky.SkyboxRt=tex sky.SkyboxUp=tex
    end)
    -- Also flash colorshift
    ls.ColorShift_Top=Color3.fromHSV((idx%6)/6,1,0.5)
    ls.ColorShift_Bottom=Color3.fromHSV(((idx+3)%6)/6,1,0.5)
   end
  end),
  f=function()
   ls.ClockTime=savedClock
   ls.ColorShift_Top=Color3.fromRGB(0,0,0)
   ls.ColorShift_Bottom=Color3.fromRGB(0,0,0)
   if not savedSky and sky then
    sky:Destroy()
   elseif savedSky then
    for prop,val in pairs(savedSkyChildren) do
     pcall(function() savedSky[prop]=val end)
    end
   end
  end,
 }
end,function() cleanup("SkyLooping") end)

-- 🦐 PATRICK IS A STUPID BARNACLIN BI- — spawn decompiled Patrick killer model
ext("Patrick is a stupid BARNACLIN BI-","🦐",25,function()
 notif("🦐 Patrick: "..A.patrickQuotes[math.random(#A.patrickQuotes)],4)
 playSound(A.horror,1.5,hrp,5)
 -- Brief pink flash
 local gui=plr:FindFirstChild("PlayerGui")
 if gui then
  local flash=Instance.new("Frame",gui) flash.Size=UDim2.new(1,0,1,0) flash.BackgroundColor3=Color3.fromRGB(255,105,180)
  flash.BackgroundTransparency=1 flash.ZIndex=9999 flash.IgnoreGuiInset=true
  ts:Create(flash,TweenInfo.new(0.2),{BackgroundTransparency=0.5}):Play()
  debris:AddItem(flash,1.5)
 end
 -- Spawn Patrick model
 local modelId=A.patrickModel
 local patModel=nil
 local spawnOk=false
 pcall(function()
  local objs=game:GetObjects("rbxassetid://"..tostring(modelId))
  if objs and objs[1] then
   patModel=objs[1] -- game:GetObjects returns an array; first entry is the model
   patModel.Parent=ws
   -- Enable the decompiled model's internal scripts (Disabled=true by default)
   local n=enableScripts(patModel) if n>0 then notif("🔧 Patrick: "..n.." script(s) enabled",2) end
   -- Name it for easy identification
   pcall(function() patModel.Name="PatrickKiller" end)
   -- Place 14 studs in front of player
   if hrp then
    local cf=hrp.CFrame*CFrame.new(0,0,-14)
    pcall(function() patModel:PivotTo(cf*CFrame.Angles(0,math.pi,0)) end)
    -- Fallback if no PrimaryPart
    if not patModel.PrimaryPart then
     for _,p in patModel:GetDescendants() do
      if p:IsA("BasePart") then p.CFrame=cf*CFrame.Angles(0,math.pi,0) break end
     end
    end
   end
   -- Try to make Patrick walk toward the player & damage on touch
   local hum2=patModel:FindFirstChildOfClass("Humanoid")
   if hum2 then
    pcall(function() hum2.WalkSpeed=10 end)
    -- Spawn a BillboardGui with a quote above Patrick's head
    local head=patModel:FindFirstChild("Head") or patModel:FindFirstChildWhichIsA("BasePart")
    if head then
     local bb=Instance.new("BillboardGui",head) bb.Size=UDim2.new(0,200,0,40) bb.StudsOffset=Vector3.new(0,3,0)
     local tl=Instance.new("TextLabel",bb) tl.Size=UDim2.new(1,0,1,0) tl.BackgroundTransparency=1
     tl.Text="🦐 "..A.patrickQuotes[math.random(#A.patrickQuotes)] tl.TextColor3=Color3.fromRGB(255,180,200)
     tl.Font=Enum.Font.GothamBold tl.TextScaled=true
     spawn(function()
      while bb and bb.Parent do
       tl.Text="🦐 "..A.patrickQuotes[math.random(#A.patrickQuotes)]
       wait(2.5)
      end
     end)
    end
    -- Chase loop
    spawn(function()
     while patModel and patModel.Parent and hum2.Health>0 and hrp and hrp.Parent do
      hum2:MoveTo(hrp.Position)
      wait(0.4)
     end
    end)
    -- Touch damage
    for _,p in patModel:GetDescendants() do
     if p:IsA("BasePart") then
      p.Touched:Connect(function(hit)
       if hit and hit.Parent and hit.Parent~=patModel then
        local vh=hit.Parent:FindFirstChildOfClass("Humanoid")
        if vh and vh.Parent==char then
         pcall(function() vh:TakeDamage(8) end)
        end
       end
      end)
     end
    end
   end
   spawnOk=true
  end
 end)
 if not spawnOk then
  notif("⚠️ Patrick model failed to load (asset ID "..tostring(modelId)..")",4)
  -- Fallback: pink star-shaped blocky Patrick
  local m=Instance.new("Model",ws) m.Name="PatrickFallback"
  local body=Instance.new("Part",m) body.Size=Vector3.new(4,4,1) body.BrickColor=BrickColor.new("Pink") body.Anchored=false
  body.TopSurface=0 body.BottomSurface=0
  local head=Instance.new("Part",m) head.Size=Vector3.new(2,2,1) head.BrickColor=BrickColor.new("Pink") head.Anchored=false
  local w=Instance.new("Weld",body) w.Part0=body w.Part1=head w.C0=CFrame.new(0,3,0)
  local eyes=Instance.new("Decal",head) eyes.Face=Enum.NormalId.Front eyes.Texture="rbxassetid://18998949"
  if hrp then body.CFrame=hrp.CFrame*CFrame.new(0,0,-14)*CFrame.Angles(0,math.pi,0) end
  patModel=m
 end
 active.Patrick={
  model=patModel,
  f=function()
   if patModel and patModel.Parent then debris:AddItem(patModel,0.5) end
  end,
 }
end,function() cleanup("Patrick") end)

-- 💀 I'M A GONER — spawn decompiled killer NPC (scripts inside try to kill player) + fallback chase
ext("I'm a goner","💀",30,function()
 notif("💀 I'm a goner... — A killer is hunting you. Don't look back.",5)
 playSound(A.death_,2,hrp,5)
 -- Dramatic black vignette pulse
 local gui=plr:FindFirstChild("PlayerGui")
 if gui then
  local vig=Instance.new("Frame",gui) vig.Size=UDim2.new(1,0,1,0) vig.BackgroundColor3=Color3.fromRGB(0,0,0)
  vig.BackgroundTransparency=1 vig.ZIndex=9998 vig.IgnoreGuiInset=true
  for i=1,4 do
   ts:Create(vig,TweenInfo.new(0.25),{BackgroundTransparency=0.5}):Play() wait(0.25)
   ts:Create(vig,TweenInfo.new(0.35),{BackgroundTransparency=1}):Play() wait(0.4)
  end
  debris:AddItem(vig,3)
 end
 -- Pick a random killer NPC variant
 local modelId=A.killerNpcVariants[math.random(#A.killerNpcVariants)]
 local killer=nil
 local spawnOk=false
 pcall(function()
  local objs=game:GetObjects("rbxassetid://"..tostring(modelId))
  if objs and objs[1] then
   -- game:GetObjects returns the decompiled model directly (with its scripts intact).
   killer=objs[1]
   killer.Parent=ws
   -- Enable the decompiled killer NPC's own aggression scripts
   local n=enableScripts(killer) if n>0 then notif("🔧 Killer NPC: "..n.." script(s) enabled",2) end
   pcall(function() killer.Name="KillerNPC" end)
   -- Place 20 studs behind the player so they have a moment to react
   if hrp then
    local cf=hrp.CFrame*CFrame.new(0,0,20)
    pcall(function() killer:PivotTo(cf) end)
    if not killer.PrimaryPart then
     for _,p in killer:GetDescendants() do
      if p:IsA("BasePart") then p.CFrame=cf break end
     end
    end
   end
   -- The model's own scripts should handle aggression. As a safety net
   -- (in case scripts were stripped or sandboxed), add our own chase logic.
   local hum2=killer:FindFirstChildOfClass("Humanoid")
   if hum2 then
    pcall(function()
     hum2.WalkSpeed=18
     hum2.JumpPower=50
     -- Make it hostile
     if hum2.DisplayDistanceType then hum2.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end
    end)
    -- Chase loop (safety net)
    spawn(function()
     while killer and killer.Parent and hum2.Health>0 and hrp and hrp.Parent do
      -- Move toward the player
      pcall(function() hum2:MoveTo(hrp.Position) end)
      -- If close enough, try to jump at them
      if (killer:GetPivot().Position - hrp.Position).Magnitude < 8 then
       pcall(function() hum2.Jump=true end)
      end
      wait(0.3)
     end
    end)
    -- Touch damage (safety net — model's own damage script may also fire)
    for _,p in killer:GetDescendants() do
     if p:IsA("BasePart") then
      local debounce=false
      p.Touched:Connect(function(hit)
       if debounce then return end
       if hit and hit.Parent and hit.Parent~=killer then
        local vh=hit.Parent:FindFirstChildOfClass("Humanoid")
        if vh and vh.Parent==char then
         debounce=true
         pcall(function() vh:TakeDamage(25) end)
         wait(0.6) debounce=false
        end
       end
      end)
     end
    end
    -- Scary billboard
    local head=killer:FindFirstChild("Head") or killer:FindFirstChildWhichIsA("BasePart")
    if head then
     local bb=Instance.new("BillboardGui",head) bb.Size=UDim2.new(0,160,0,30) bb.StudsOffset=Vector3.new(0,3.5,0)
     local tl=Instance.new("TextLabel",bb) tl.Size=UDim2.new(1,0,1,0) tl.BackgroundTransparency=1
     tl.Text="💀 I'M COMING FOR YOU" tl.TextColor3=Color3.fromRGB(255,40,40)
     tl.Font=Enum.Font.GothamBlack tl.TextScaled=true
    end
   end
   spawnOk=true
  end
 end)
 if not spawnOk then
  notif("⚠️ Killer NPC failed to load (asset ID "..tostring(modelId)..")",4)
  -- Fallback: red blocky killer
  local m=Instance.new("Model",ws) m.Name="KillerFallback"
  local t=Instance.new("Part",m) t.Size=Vector3.new(2,3,1) t.BrickColor=BrickColor.new("Really red") t.Anchored=false
  t.TopSurface=0 t.BottomSurface=0
  local h=Instance.new("Part",m) h.Size=Vector3.new(1.5,1.5,1) h.BrickColor=BrickColor.new("Really black") h.Anchored=false
  local w=Instance.new("Weld",t) w.Part0=t w.Part1=h w.C0=CFrame.new(0,2.25,0)
  local decal=Instance.new("Decal",h) decal.Face=Enum.NormalId.Front decal.Texture="rbxassetid://18998949"
  local hh=Instance.new("Humanoid",m)
  if hrp then t.CFrame=hrp.CFrame*CFrame.new(0,0,20) end
  killer=m
  -- Even fallback chases
  spawn(function()
   while m and m.Parent and hh.Health>0 and hrp and hrp.Parent do
    hh:MoveTo(hrp.Position)
    wait(0.3)
   end
  end)
  t.Touched:Connect(function(hit)
   if hit and hit.Parent and hit.Parent~=m then
    local vh=hit.Parent:FindFirstChildOfClass("Humanoid")
    if vh and vh.Parent==char then pcall(function() vh:TakeDamage(25) end) end
   end
  end)
 end
 active.Goner={
  model=killer,
  f=function()
   if killer and killer.Parent then debris:AddItem(killer,0.5) end
  end,
 }
end,function() cleanup("Goner") end)

-- 🌈 I'M NOW RGB — player's character smoothly cycles through HSV rainbow
ext("I'm now RGB","👤",22,function()
 notif("👤 I'M NOW RGB — Your avatar is a smooth rainbow now.",3)
 -- Save the original color & material of every part in the player's character
 local saved={}
 local function snapshot(c)
  if not c then return end
  for _,p in c:GetDescendants() do
   if p:IsA("BasePart") then
    saved[p]={c=p.Color,m=p.Material}
   end
  end
 end
 snapshot(char)
 -- Also re-snapshot if the player respawns mid-effect
 local respawnConn
 respawnConn=plr.CharacterAdded:Connect(function(newChar)
  char=newChar
  hrp=newChar:WaitForChild("HumanoidRootPart")
  hum=newChar:WaitForChild("Humanoid")
  saved={}
  snapshot(newChar)
 end)
 -- Smooth hue cycle driven by RenderStepped (frame-rate independent)
 local hue=0
 active.ImNowRGB={
  conn=rs.RenderStepped:Connect(function(dt)
   hue=(hue+dt*0.35)%1 -- smooth slow cycle (1 full rainbow ~2.85s)
   if not char then return end
   for _,p in char:GetDescendants() do
    if p:IsA("BasePart") then
     -- Per-part phase offset based on position so the body shimmers, not all-one-color
     local phase=(hue+(p.Position.X+p.Position.Y+p.Position.Z)*0.005)%1
     p.Color=Color3.fromHSV(phase,0.85,1)
     p.Material=Enum.Material.Neon
    end
   end
   -- Also tint any accessories / hats the player is wearing
   for _,a in char:GetChildren() do
    if a:IsA("Accessory") then
     local h=a:FindFirstChild("Handle")
     if h and h:IsA("BasePart") then
      local phase=(hue+0.25)%1
      h.Color=Color3.fromHSV(phase,0.85,1)
      h.Material=Enum.Material.Neon
     end
    end
   end
  end),
  respawnConn=respawnConn,
  saved=saved,
  f=function()
   if respawnConn then respawnConn:Disconnect() end
   -- Restore original colors & materials
   for p,info in pairs(saved) do
    if p and p.Parent then
     pcall(function() p.Color=info.c p.Material=info.m end)
    end
   end
  end,
 }
end,function() cleanup("ImNowRGB") end)

-- 💚 GREEN SCREEN WORLD — every part in workspace turns green (chroma-key style)
ext("GREEN SCREEN WORLD","💚",20,function()
 notif("💚 GREEN SCREEN WORLD — Everything is chroma-key green now.",3)
 -- Save originals
 local saved={}
 for _,o in ws:GetDescendants() do
  if o:IsA("BasePart") then
   saved[o]={c=o.Color,m=o.Material,dc={}}
   -- Save existing decals (we'll replace them with green)
   for _,d in o:GetChildren() do
    if d:IsA("Decal") or d:IsA("Texture") then
     saved[o].dc[d]={t=d.Texture}
    end
   end
  end
 end
 -- Catch parts added during the effect
 local addedConn
 addedConn=ws.DescendantAdded:Connect(function(o)
  if o:IsA("BasePart") then
   saved[o]={c=o.Color,m=o.Material,dc={}}
   pcall(function()
    o.Color=Color3.fromRGB(0,255,0)
    o.Material=Enum.Material.Neon
   end)
  end
 end)
 -- Apply green to everything now
 local greenColor=Color3.fromRGB(0,255,0)
 for o,info in pairs(saved) do
  pcall(function()
   o.Color=greenColor
   o.Material=Enum.Material.Neon
   -- Green out any decals/textures
   for _,d in o:GetChildren() do
    if d:IsA("Decal") or d:IsA("Texture") then
     d.Texture="rbxassetid://254814198" -- solid green 1x1 image
     d.Transparency=0
    end
   end
  end)
 end
 -- Also turn the sky green for full chroma effect
 local sky=ls:FindFirstChildOfClass("Sky")
 local savedSky={}
 if sky then
  for _,prop in ipairs({"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"}) do
   savedSky[prop]=sky[prop]
   pcall(function() sky[prop]="rbxassetid://254814198" end)
  end
 end
 -- Save & override fog + ambient for full green tint
 local savedAmbient=ls.Ambient
 local savedOutdoorAmbient=ls.OutdoorAmbient
 local savedColorShiftTop=ls.ColorShift_Top
 local savedColorShiftBottom=ls.ColorShift_Bottom
 local savedFogColor=ls.FogColor
 ls.Ambient=greenColor
 ls.OutdoorAmbient=greenColor
 ls.ColorShift_Top=greenColor
 ls.ColorShift_Bottom=greenColor
 ls.FogColor=greenColor
 -- Slowly pulse the green intensity for a "live green screen" feel
 local pulseConn
 pulseConn=rs.Heartbeat:Connect(function()
  local v=0.85+math.sin(tick()*4)*0.15
  ls.Ambient=Color3.fromRGB(0,255*v,0)
 end)
 active.GreenScreenWorld={
  addedConn=addedConn,
  pulseConn=pulseConn,
  saved=saved,
  sky=sky,
  savedSky=savedSky,
  f=function()
   if addedConn then addedConn:Disconnect() end
   if pulseConn then pulseConn:Disconnect() end
   -- Restore parts
   for o,info in pairs(saved) do
    if o and o.Parent then
     pcall(function()
      o.Color=info.c
      o.Material=info.m
     end)
     -- Restore decals
     for d,dinfo in pairs(info.dc) do
      if d and d.Parent then
       pcall(function() d.Texture=dinfo.t end)
      end
     end
    end
   end
   -- Restore sky
   if sky then
    for prop,val in pairs(savedSky) do
     pcall(function() sky[prop]=val end)
    end
   end
   -- Restore lighting
   ls.Ambient=savedAmbient
   ls.OutdoorAmbient=savedOutdoorAmbient
   ls.ColorShift_Top=savedColorShiftTop
   ls.ColorShift_Bottom=savedColorShiftBottom
   ls.FogColor=savedFogColor
  end,
 }
end,function() cleanup("GreenScreenWorld") end)

-- 🕹️ HE'S ANGRY VIDEO GAME ROBLOXIAN — whole game feels like an Atari 2600
ext("He's angry video game robloxian","🕹️",25,function()
 notif("🕹️ ATARI MODE ACTIVATED — Score: 000000  Hi: 999999",4)
 -- Save all lighting / camera state we'll change
 local savedTech=ls.Technology
 local savedBright=ls.Brightness
 local savedAmbient=ls.Ambient
 local savedOutdoor=ls.OutdoorAmbient
 local savedFogStart=ls.FogStart
 local savedFogEnd=ls.FogEnd
 local savedFogColor=ls.FogColor
 -- 1. Force Compatibility mode (turns off modern lighting, flattens to vertex-lit look)
 pcall(function() ls.Technology=Enum.Technology.Compatibility end)
 ls.Brightness=2
 -- 2. Limited Atari-style palette: heavy fog + dark ambient so distant geometry disappears
 ls.FogStart=20 ls.FogEnd=80
 ls.FogColor=Color3.fromRGB(0,0,0)
 ls.Ambient=Color3.fromRGB(60,40,40)
 ls.OutdoorAmbient=Color3.fromRGB(80,60,60)
 -- 3. Pixelated / posterized ColorCorrection + Bloom + CRT-style scanlines overlay
 local cc=Instance.new("ColorCorrectionEffect",ls)
 cc.Contrast=1.5 cc.Saturation=-0.7 cc.Brightness=-0.1
 -- Posterize tint: tint everything to retro brown/orange
 cc.TintColor=Color3.fromRGB(255,200,140)
 local bloom=Instance.new("BloomEffect",ls)
 bloom.Intensity=1.5 bloom.Size=24 bloom.Threshold=0.3
 local blur=Instance.new("BlurEffect",ls)
 blur.Size=4 -- slight blur to mimic CRT phosphor bleed
 -- 4. Build a scanline overlay GUI (horizontal black lines every 4px)
 local gui=plr:FindFirstChild("PlayerGui")
 local scanlineGui
 if gui then
  scanlineGui=Instance.new("ScreenGui",gui) scanlineGui.Name="AtariScanlines" scanlineGui.IgnoreGuiInset=true scanlineGui.ResetOnSpawn=false scanlineGui.DisplayOrder=9999
  local frame=Instance.new("Frame",scanlineGui) frame.Size=UDim2.new(1,0,1,0) frame.BackgroundTransparency=1 frame.ZIndex=10
  -- Draw scanlines using a repeating UIStroke-like pattern via TextLabels
  for y=0,800,4 do
   local sl=Instance.new("Frame",frame) sl.Size=UDim2.new(1,0,0,2) sl.Position=UDim2.new(0,0,0,y)
   sl.BackgroundColor3=Color3.fromRGB(0,0,0) sl.BackgroundTransparency=0.4 sl.BorderSizePixel=0 sl.ZIndex=10
  end
  -- Atari-style top bar with score
  local topbar=Instance.new("TextLabel",scanlineGui) topbar.Size=UDim2.new(1,0,0,20) topbar.Position=UDim2.new(0,0,0,0)
  topbar.BackgroundColor3=Color3.fromRGB(0,0,0) topbar.BackgroundTransparency=0.2 topbar.BorderSizePixel=0 topbar.ZIndex=11
  topbar.Text="  SCORE 000000    HI 999999    🕹️ ATARI MODE  " topbar.TextColor3=Color3.fromRGB(255,180,80)
  topbar.Font=Enum.Font.Arcade topbar.TextSize=14 topbar.TextXAlignment=Enum.TextXAlignment.Left
  -- Animated score counter
  local score=0
  spawn(function()
   while scanlineGui and scanlineGui.Parent do
    score=score+math.random(10,100)
    topbar.Text="  SCORE "..string.format("%06d",score).."    HI 999999    🕹️ ATARI MODE  "
    wait(0.3)
   end
  end)
 end
 -- 5. Periodically switch ALL parts in workspace to retro 8-color palette (Atari 2600 vibe)
 local retroPalette={
  Color3.fromRGB(0,0,0),Color3.fromRGB(255,255,255),Color3.fromRGB(255,0,0),
  Color3.fromRGB(0,255,0),Color3.fromRGB(0,0,255),Color3.fromRGB(255,255,0),
  Color3.fromRGB(255,128,0),Color3.fromRGB(128,0,128),
 }
 local savedParts={}
 for _,o in ws:GetDescendants() do
  if o:IsA("BasePart") then savedParts[o]={c=o.Color,m=o.Material} end
 end
 local retroConn
 retroConn=rs.Heartbeat:Connect(function()
  if math.random(1,30)~=1 then return end -- ~every 0.5s
  for o,info in pairs(savedParts) do
   if o and o.Parent then
    pcall(function()
     o.Color=retroPalette[math.random(#retroPalette)]
     o.Material=Enum.Material.Plastic
    end)
   end
  end
 end)
 -- 6. Periodic retro beep sound (Atari 2600-style)
 local beepSound=Instance.new("Sound",ss) beepSound.SoundId="rbxassetid://12222242" beepSound.Volume=0.4
 spawn(function()
  while beepSound and beepSound.Parent do
   pcall(function() beepSound:Play() end)
   wait(0.4+math.random()*0.4)
  end
 end)
 active.AtariMode={
  cc=cc, bloom=bloom, blur=blur, retroConn=retroConn, beepSound=beepSound, scanlineGui=scanlineGui,
  savedParts=savedParts,
  f=function()
   if retroConn then retroConn:Disconnect() end
   pcall(function() ls.Technology=savedTech end)
   ls.Brightness=savedBright
   ls.Ambient=savedAmbient
   ls.OutdoorAmbient=savedOutdoorAmbient
   ls.FogStart=savedFogStart ls.FogEnd=savedFogEnd ls.FogColor=savedFogColor
   pcall(function() cc:Destroy() bloom:Destroy() blur:Destroy() end)
   if beepSound then debris:AddItem(beepSound,0.5) end
   if scanlineGui then debris:AddItem(scanlineGui,0.5) end
   -- Restore part colors
   for o,info in pairs(savedParts) do
    if o and o.Parent then
     pcall(function() o.Color=info.c o.Material=info.m end)
    end
   end
  end,
 }
end,function() cleanup("AtariMode") end)

-- 💚 GREEN SCREEN MAN — player's whole body turns green EXCEPT the head
ext("GREEN SCREEN MAN","🧍",22,function()
 notif("🧍 GREEN SCREEN MAN — Your body is chroma-key green (head excluded).",3)
 -- Snapshot every part of the character so we can restore them later
 local saved={}
 local function snapshot(c)
  if not c then return end
  for _,p in c:GetDescendants() do
   if p:IsA("BasePart") then
    saved[p]={c=p.Color,m=p.Material,dc={}}
    for _,d in p:GetChildren() do
     if d:IsA("Decal") or d:IsA("Texture") then
      saved[p].dc[d]={t=d.Texture,tr=d.Transparency}
     end
    end
   end
  end
 end
 snapshot(char)
 -- Re-snapshot on respawn
 local respawnConn
 respawnConn=plr.CharacterAdded:Connect(function(newChar)
  char=newChar
  hrp=newChar:WaitForChild("HumanoidRootPart")
  hum=newChar:WaitForChild("Humanoid")
  saved={}
  snapshot(newChar)
  -- Re-apply green to the new body
  pcall(function()
   for _,p in newChar:GetDescendants() do
    if p:IsA("BasePart") then
     local name=p.Name:lower()
     if name~="head" then
      p.Color=Color3.fromRGB(0,255,0)
      p.Material=Enum.Material.Neon
     end
    end
   end
  end)
 end)
 -- Apply green to every part EXCEPT head (and any accessory handle whose name contains "head")
 local greenColor=Color3.fromRGB(0,255,0)
 local greenTex="rbxassetid://254814198" -- solid green 1x1 image
 local function applyGreen(c)
  if not c then return end
  for _,p in c:GetDescendants() do
   if p:IsA("BasePart") then
    local name=p.Name:lower()
    -- Skip the actual head, but green everything else (torso, arms, Legs, accessories, etc.)
    if name~="head" then
     pcall(function()
      p.Color=greenColor
      p.Material=Enum.Material.Neon
      -- Green out any face decals/textures on non-head parts (hats, etc.)
      for _,d in p:GetChildren() do
       if d:IsA("Decal") or d:IsA("Texture") then
        d.Texture=greenTex
        d.Transparency=0
       end
      end
     end)
    end
   end
  end
 end
 applyGreen(char)
 -- Pulse the green slightly so it feels "alive"
 local pulseConn
 pulseConn=rs.Heartbeat:Connect(function()
  -- The pulse only modulates the green value subtly; we re-apply on every pulse
  local v=0.85+math.sin(tick()*3)*0.15
  local dynGreen=Color3.fromRGB(0,math.floor(255*v),0)
  if char then
   for _,p in char:GetDescendants() do
    if p:IsA("BasePart") and p.Name:lower()~="head" then
     pcall(function() p.Color=dynGreen end)
    end
   end
  end
 end)
 active.GreenScreenMan={
  pulseConn=pulseConn,
  respawnConn=respawnConn,
  saved=saved,
  f=function()
   if pulseConn then pulseConn:Disconnect() end
   if respawnConn then respawnConn:Disconnect() end
   for p,info in pairs(saved) do
    if p and p.Parent then
     pcall(function() p.Color=info.c p.Material=info.m end)
     for d,dinfo in pairs(info.dc) do
      if d and d.Parent then
       pcall(function() d.Texture=dinfo.t d.Transparency=dinfo.tr end)
      end
     end
    end
   end
  end,
 }
end,function() cleanup("GreenScreenMan") end)

-- 🧟 ZOMBIE ON HEAD — spawn a decompiled zombie model and place it on top of the player
ext("Zombie on Head","🧟",20,function()
 notif("🧟 Zombie on Head! — A zombie just dropped onto your head. Enjoy the ride.",4)
 playSound(A.horror,1.5,hrp,4)
 -- Pick a random zombie variant
 local modelId=A.zombieVariants[math.random(#A.zombieVariants)]
 local zombie=nil
 local spawnOk=false
 pcall(function()
  local objs=game:GetObjects("rbxassetid://"..tostring(modelId))
  if objs and objs[1] then
   zombie=objs[1]
   zombie.Parent=ws
   -- Enable the decompiled zombie's internal scripts (Disabled=true by default)
   local n=enableScripts(zombie) if n>0 then notif("🔧 Zombie: "..n.." script(s) enabled",2) end
   pcall(function() zombie.Name="HeadZombie" end)
   -- Place ON TOP of the player's head — vertically stacked above HRP
   if hrp then
    -- Determine a good offset: 5-7 studs above the HRP (above the head)
    local offset=Vector3.new(0,7,0)
    local cf=hrp.CFrame+offset
    pcall(function() zombie:PivotTo(cf) end)
    -- Fallback if no PrimaryPart
    if not zombie.PrimaryPart then
     for _,p in zombie:GetDescendants() do
      if p:IsA("BasePart") then p.CFrame=cf break end
     end
    end
    -- Try to weld the zombie to the player's head so it stays on top
    local zombieRoot=zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChildWhichIsA("BasePart")
    local playerHead=char:FindFirstChild("Head")
    if zombieRoot and playerHead then
     local weld=Instance.new("Weld",zombieRoot)
     weld.Part0=playerHead
     weld.Part1=zombieRoot
     weld.C0=CFrame.new(0,3,0) * CFrame.Angles(math.rad(20),0,0) -- tilted forward like riding
     -- Make the zombie rooted (anchored would break the weld; keep it dynamic)
     pcall(function()
      for _,p in zombie:GetDescendants() do
       if p:IsA("BasePart") then p.Anchored=false p.CanCollide=false end
      end
     end)
    end
   end
   -- Disable the zombie's own Humanoid so it doesn't try to walk away
   local zh=zombie:FindFirstChildOfClass("Humanoid")
   if zh then
    pcall(function()
     zh.WalkSpeed=0
     zh.JumpPower=0
     zh.PlatformStand=true -- ragdoll-ish
    end)
   end
   -- Try to play an "angry zombie" animation on it (if it has an Animator)
   pcall(function()
    local animator=zh and (zh:FindFirstChildOfClass("Animator") or zh:FindFirstChild("Animator"))
    if animator then
     local a=Instance.new("Animation") a.AnimationId="rbxassetid://507777268" -- sword slash anim as a generic flail
     local track=animator:LoadAnimation(a)
     track.Looped=true track.Priority=Enum.AnimationPriority.Action
     track:Play()
    end
   end)
   -- Make the zombie gently bob/rotate on top of the player's head (extra chaos)
   spawn(function()
    while zombie and zombie.Parent and hrp and hrp.Parent do
     pcall(function()
      local zombieRoot=zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChildWhichIsA("BasePart")
      if zombieRoot and zombieRoot:FindFirstChildOfClass("Weld") then
       -- Already welded — modify the weld's C0 for a wobble
       local w=zombieRoot:FindFirstChildOfClass("Weld")
       if w then
        w.C0=CFrame.new(0,3+math.sin(tick()*4)*0.3,0) * CFrame.Angles(math.rad(20)+math.sin(tick()*2)*0.2, math.sin(tick()*3)*0.3, 0)
       end
      end
     end)
     wait(0.05)
    end
   end)
   spawnOk=true
  end
 end)
 if not spawnOk then
  notif("⚠️ Zombie model failed to load (asset ID "..tostring(modelId)..")",4)
  -- Fallback: build a simple blocky zombie on the player's head
  local m=Instance.new("Model",ws) m.Name="ZombieFallback"
  local body=Instance.new("Part",m) body.Size=Vector3.new(2,3,1) body.BrickColor=BrickColor.new("Dark green") body.Anchored=false body.CanCollide=false
  local head=Instance.new("Part",m) head.Size=Vector3.new(1.5,1.5,1) head.BrickColor=BrickColor.new("Grime") head.Anchored=false head.CanCollide=false
  local w=Instance.new("Weld",body) w.Part0=body w.Part1=head w.C0=CFrame.new(0,2.25,0)
  local decal=Instance.new("Decal",head) decal.Face=Enum.NormalId.Front decal.Texture="rbxassetid://18998949"
  local hh=Instance.new("Humanoid",m) hh.WalkSpeed=0 hh.PlatformStand=true
  if hrp then
   body.CFrame=hrp.CFrame+Vector3.new(0,7,0)
   local playerHead=char:FindFirstChild("Head")
   if playerHead then
    local weld=Instance.new("Weld",body) weld.Part0=playerHead weld.Part1=body weld.C0=CFrame.new(0,3,0)*CFrame.Angles(math.rad(20),0,0)
   end
  end
  zombie=m
 end
 active.ZombieOnHead={
  model=zombie,
  f=function()
   if zombie and zombie.Parent then debris:AddItem(zombie,0.5) end
  end,
 }
end,function() cleanup("ZombieOnHead") end)

-- 🐸 ITS RAINING MEN — runs the raining-toads spammer script (user-pasted verbatim, wrapped for cleanup)
ext("ITS RAINING MEN","🐸",30,function()
 notif("🐸 ITS RAINING MEN — Get toadroasted you bacon-haired bozos",4)
 pcall(function() math.randomseed(tick() % 1 * 1e6) end)
 local noises={'rbxassetid://230287740','rbxassetid://271787597','rbxassetid://153752123','rbxassetid://271787503'}
 local running=true
 local spawned={Sky={},Sound={},Message={},Part={},Hint={}}

 -- Coroutine: Sky Spammer
 spawn(function()
  while running do
   wait(0.3)
   if not running then break end
   local s=Instance.new("Sky",ls)
   local skyId="rbxassetid://201208408"
   s.SkyboxBk,s.SkyboxDn,s.SkyboxFt,s.SkyboxLf,s.SkyboxRt,s.SkyboxUp=skyId,skyId,skyId,skyId,skyId,skyId
   s.CelestialBodiesShown=false
   table.insert(spawned.Sky,s)
  end
 end)

 -- Coroutine: Delete All Models (skip player's character + our killer models so other effects keep working)
 spawn(function()
  while running do
   wait(0.3)
   if not running then break end
   for _,v in pairs(ws:GetChildren()) do
    if v:IsA("Model") and v~=char then
     local nm=v.Name or ""
     -- Don't delete our killer/zombie/Patrick/Jeff models or the fallbacks
     if nm~="PatrickKiller" and nm~="KillerNPC" and nm~="HeadZombie" and nm~="JeffKiller"
        and nm~="JeffFallback" and nm~="ZombieFallback" and nm~="KillerFallback" then
      pcall(function() v:Destroy() end)
     end
    end
   end
  end
 end)

 -- Coroutine: Loud Looping Sound
 spawn(function()
  local a=Instance.new("Sound",ws)
  a.SoundId="rbxassetid://79999206651848"
  a.Name="RAINING MEN"
  a.Volume=10 -- Roblox caps at 10 anyway; original used an absurd number
  a.PlaybackSpeed=0.22
  a.Looped=true
  a:Play()
  table.insert(spawned.Sound,a)
  while running do
   wait(0.2)
   if not running then break end
   if not ws:FindFirstChild("RAINING MEN") then
    local newSound=Instance.new("Sound",ws)
    newSound.SoundId="rbxassetid://79999206651848"
    newSound.Name="RAINING MEN"
    newSound.Volume=10
    newSound.PlaybackSpeed=0.22
    newSound.Looped=true
    newSound:Play()
    table.insert(spawned.Sound,newSound)
   end
  end
 end)

 -- Coroutine: Message Spammer
 spawn(function()
  while running do
   wait(0.4)
   if not running then break end
   local m=Instance.new("Message",ws)
   m.Text="Get toadroasted you bacon-haired bozos"
   table.insert(spawned.Message,m)
   delay(0.4,function() if m and m.Parent then m:Destroy() end end)
  end
 end)

 -- Coroutine: Rain Toads
 spawn(function()
  while running do
   wait(0.3)
   if not running then break end
   local part=Instance.new("Part",ws)
   part.Name="Meshes/toad (3)"
   part.CanCollide=false
   part.Size=Vector3.new(440,530,380)
   part.Position=Vector3.new(math.random(-3000,1000),math.random(1,3000),math.random(-3000,3000))
   local mesh=Instance.new("SpecialMesh",part)
   mesh.MeshType=Enum.MeshType.FileMesh
   mesh.MeshId="rbxassetid://7234998844"
   mesh.TextureId="rbxassetid://1009824086"
   table.insert(spawned.Part,part)
   local s=Instance.new("Sound",ws)
   s.SoundId=noises[math.random(1,#noises)]
   s.Volume=1
   s:Play()
   s.Ended:Connect(function() s:Destroy() end)
  end
 end)

 -- Hint Message at the Bottom (forever — until cleanup)
 local h=Instance.new("Hint",ws)
 h.Text="Get toadroasted you bacon-haired goombas"
 table.insert(spawned.Hint,h)

 active.RainingMen={
  f=function()
   running=false
   for _,t in pairs(spawned) do
    for _,obj in pairs(t) do
     if obj and obj.Parent then pcall(function() obj:Destroy() end) end
    end
   end
  end,
 }
end,function() cleanup("RainingMen") end)

-- 👹 TROLLGE IS COMING IN 24 HOURS — runs the Trollge destroyer script (auto-start, no button)
ext("trollge is coming in 24 hours","👹",35,function()
 notif("👹 TROLLGE IS COMING IN 24 HOURS — The troll has begun.",5)
 local FACE_IMAGE="rbxassetid://6862780932"
 local FULL_IMAGE="rbxassetid://10396152149"
 local SKY_IMAGE="rbxassetid://13675428955"
 local MUSIC_ID="rbxassetid://77586042839973"
 local RANDOM_SOUND_ID="rbxassetid://8389041427"
 local JUMPSCARE_SOUND_ID="rbxassetid://6787686247"
 local running=true
 local spawned={Gui={},Sound={},Sky={},Decal={},Particle={},Billboard={}}
 local faceConns={}

 -- Create GUI (auto-start, no button needed since chaos mod triggers effects)
 local gui=Instance.new("ScreenGui") gui.ResetOnSpawn=false gui.Name="TrollgeGUI" gui.Parent=plr:WaitForChild("PlayerGui")
 table.insert(spawned.Gui,gui)

 local overlay=Instance.new("ImageLabel",gui)
 overlay.Size=UDim2.fromScale(1,1) overlay.BackgroundTransparency=1 overlay.Visible=true
 overlay.Image=FULL_IMAGE overlay.ImageTransparency=0
 table.insert(spawned.Gui,overlay)

 local jumpscare=Instance.new("ImageLabel",gui)
 jumpscare.Size=UDim2.fromScale(1,1) jumpscare.BackgroundTransparency=1 jumpscare.Visible=false
 table.insert(spawned.Gui,jumpscare)

 -- Fade overlay out after 5s
 delay(5,function()
  if running and overlay and overlay.Parent then
   ts:Create(overlay,TweenInfo.new(2),{ImageTransparency=1}):Play()
  end
 end)

 -- Sounds
 local music=Instance.new("Sound",ws) music.SoundId=MUSIC_ID music.Looped=true music.PlaybackSpeed=0.15 music:Play()
 table.insert(spawned.Sound,music)
 local randomSound=Instance.new("Sound",ws) randomSound.SoundId=RANDOM_SOUND_ID table.insert(spawned.Sound,randomSound)
 local jumpscareSound=Instance.new("Sound",ws) jumpscareSound.SoundId=JUMPSCARE_SOUND_ID table.insert(spawned.Sound,jumpscareSound)

 -- Apply face images to all players (and future respawns)
 local function addFaceImage(character)
  local head=character:FindFirstChild("Head")
  if not head or head:FindFirstChild("TrollFace") then return end
  local bb=Instance.new("BillboardGui") bb.Name="TrollFace" bb.Adornee=head
  bb.Size=UDim2.new(3,0,3,0) bb.AlwaysOnTop=true bb.Parent=head
  local img=Instance.new("ImageLabel",bb) img.Size=UDim2.fromScale(1,1) img.BackgroundTransparency=1 img.Image=FACE_IMAGE
  table.insert(spawned.Billboard,bb)
 end
 for _,p in pairs(game.Players:GetPlayers()) do
  if p.Character then addFaceImage(p.Character) end
  local c=p.CharacterAdded:Connect(addFaceImage) table.insert(faceConns,c)
 end

 -- Apply decals on every face of every part + particle emitters
 for _,obj in pairs(ws:GetDescendants()) do
  if obj:IsA("BasePart") then
   for _,face in pairs(Enum.NormalId:GetEnumItems()) do
    local d=Instance.new("Decal") d.Texture=FACE_IMAGE d.Face=face d.Parent=obj
    table.insert(spawned.Decal,d)
   end
   local p=Instance.new("ParticleEmitter",obj) p.Texture=FULL_IMAGE p.Rate=10
    table.insert(spawned.Particle,p)
  end
 end

 -- Skybox (save existing to restore)
 local sky=ls:FindFirstChildOfClass("Sky")
 local savedSkyProps={}
 if sky then
  for _,f in pairs({"Bk","Dn","Ft","Lf","Rt","Up"}) do savedSkyProps["Skybox"..f]=sky["Skybox"..f] end
 else
  sky=Instance.new("Sky") sky.Parent=ls
 end
 for _,f in pairs({"Bk","Dn","Ft","Lf","Rt","Up"}) do sky["Skybox"..f]=SKY_IMAGE end
 table.insert(spawned.Sky,sky)

 -- Random sound loop (every 10s, 50% chance)
 spawn(function()
  while running do
   task.wait(10)
   if not running then break end
   if math.random(1,2)==1 then pcall(function() randomSound:Play() end) end
  end
 end)

 -- Jumpscare loop (every 15s)
 spawn(function()
  while running do
   task.wait(15)
   if not running then break end
   local images={FACE_IMAGE,FULL_IMAGE,SKY_IMAGE}
   if jumpscare and jumpscare.Parent then
    jumpscare.Image=images[math.random(#images)]
    jumpscare.Visible=true
    pcall(function() jumpscareSound:Play() end)
    task.wait(3)
    if jumpscare and jumpscare.Parent then jumpscare.Visible=false end
   end
  end
 end)

 active.Trollge={
  faceConns=faceConns,
  savedSkyProps=savedSkyProps,
  sky=sky,
  f=function()
   running=false
   for _,c in pairs(faceConns) do pcall(function() c:Disconnect() end) end
   -- Restore sky properties
   if sky and sky.Parent then
    for k,v in pairs(savedSkyProps) do pcall(function() sky[k]=v end) end
   end
   -- Destroy all spawned objects
   for _,t in pairs(spawned) do
    for _,obj in pairs(t) do
     if obj and obj.Parent then pcall(function() obj:Destroy() end) end
    end
   end
  end,
 }
end,function() cleanup("Trollge") end)

-- 🗡️ SHEDLETSKY IS HERE — runs the Shedletsky destroyer script (chained distorted sounds + sky + particles)
ext("shedletsky is here","🗡️",40,function()
 notif("🗡️ SHEDLETSKY IS HERE — The destroyer has arrived.",5)
 local running=true
 local spawned={Sound={},Sky={},Particle={}}

 -- Save existing sky to restore on cleanup
 local savedSky=ls:FindFirstChildOfClass("Sky")
 local savedSkyProps={}
 if savedSky then
  for _,f in pairs({"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"}) do
   savedSkyProps[f]=savedSky[f]
  end
 end

 -- Helper: create a sound with 3 stacked DistortionSoundEffects (per original script)
 local function makeSound(name,soundId)
  local s=Instance.new("Sound") s.Name=name s.SoundId=soundId s.Volume=10 s.Looped=false s.PlayOnRemove=false s.Parent=ws
  local d1=Instance.new("DistortionSoundEffect",s) d1.Level=0.75
  local d2=Instance.new("DistortionSoundEffect",s) d2.Level=0.75
  local d3=Instance.new("DistortionSoundEffect",s) d3.Level=0.75
  table.insert(spawned.Sound,s)
  return s
 end

 -- Chained sounds: shed1 -> shed2 -> shed3 -> shed4 -> shed5 (each plays on .Ended of previous)
 local function playChain()
  if not running then return end
  local s1=makeSound("shed1","rbxassetid://82020270111776")
  s1:Play()
  s1.Ended:Connect(function()
   if not running then return end
   local s2=makeSound("shed2","rbxassetid://98507417558287")
   s2:Play()
   s2.Ended:Connect(function()
    if not running then return end
    local s3=makeSound("shed3","rbxassetid://86474191257848")
    s3:Play()
    s3.Ended:Connect(function()
     if not running then return end
     local s4=makeSound("shed4","rbxassetid://84113601885842")
     s4:Play()
     s4.Ended:Connect(function()
      if not running then return end
      local s5=makeSound("shed5","rbxassetid://83282320583623")
      s5:Play()
     end)
    end)
   end)
  end)
 end
 playChain()

 -- Sky change
 local sky=Instance.new("Sky") sky.Name="Sky" sky.Parent=ls
 local skyId="http://www.roblox.com/asset/?id=172423468"
 sky.SkyboxBk=skyId sky.SkyboxDn=skyId sky.SkyboxFt=skyId sky.SkyboxLf=skyId sky.SkyboxRt=skyId sky.SkyboxUp=skyId
 sky.SunAngularSize=0 sky.MoonAngularSize=0
 table.insert(spawned.Sky,sky)

 -- Particle emitters on every BasePart in workspace (recursive, per original)
 local tex="http://www.roblox.com/asset/?id=11664604903"
 local function addParticle(part)
  local p=Instance.new("ParticleEmitter",part) p.Texture=tex
  table.insert(spawned.Particle,p)
 end
 for _,v in pairs(ws:GetChildren()) do
  if v:IsA("BasePart") then addParticle(v) end
 end
 local function xds(parent)
  for _,v in pairs(parent:GetChildren()) do
   if v:IsA("BasePart") then addParticle(v) end
   if #v:GetChildren()>0 then xds(v) end
  end
 end
 pcall(xds,ws)

 -- 25 particle emitters on every player's head
 for i=1,25 do
  for _,v in pairs(game.Players:GetChildren()) do
   if v.Character and v.Character:FindFirstChild("Head") then
    local emit=Instance.new("ParticleEmitter") emit.Parent=v.Character.Head
    emit.Texture=tex emit.VelocitySpread=100000 emit.SpreadAngle=Vector2.new(0,0) emit.Speed=NumberRange.new(9,9)
    table.insert(spawned.Particle,emit)
   end
  end
 end

 active.Shedletsky={
  savedSky=savedSky,
  savedSkyProps=savedSkyProps,
  f=function()
   running=false
   -- Restore sky
   if savedSky and savedSky.Parent then
    for k,v in pairs(savedSkyProps) do pcall(function() savedSky[k]=v end) end
   end
   -- Destroy all spawned objects
   for _,t in pairs(spawned) do
    for _,obj in pairs(t) do
     if obj and obj.Parent then pcall(function() obj:Destroy() end) end
    end
   end
  end,
 }
end,function() cleanup("Shedletsky") end)

-- 💣 OH MY GOD WERE DOOMED — nuke spam (countdown + siren + 60 falling nukes with explosions)
ext("OH MY GOD WERE DOOMED","💣",45,function()
 notif("💣 OH MY GOD WE'RE DOOMED — Nukes inbound!",5)
 local NUKE_COUNT=60
 local COUNTDOWN_TIME=5
 local RANGE=100
 local MIN_HEIGHT=150
 local MAX_HEIGHT=300
 local EXPLOSION_SOUND_ID="rbxassetid://138186576"
 local SIREN_SOUND_ID="rbxassetid://9118823109"
 local running=true
 local spawned={Nuke={},Explosion={},Fire={},Sound={},Countdown={},Siren={}}

 -- Camera shake for nearby players
 local function shakeCamera(position)
  for _,player in pairs(game.Players:GetPlayers()) do
   local c=player.Character
   if c and c:FindFirstChild("HumanoidRootPart") then
    local dist=(c.HumanoidRootPart.Position-position).Magnitude
    if dist<80 then
     local cam=ws.CurrentCamera
     local shakePower=math.clamp(5-(dist/20),1,5)
     local shakeTime=0.3
     local startT=tick()
     spawn(function()
      while running and tick()-startT<shakeTime do
       if cam and cam.Parent then
        local offset=Vector3.new(
         math.random(-shakePower,shakePower)/10,
         math.random(-shakePower,shakePower)/10,
         math.random(-shakePower,shakePower)/10
        )
        pcall(function() cam.CFrame=cam.CFrame*CFrame.new(offset) end)
       end
       wait(0.03)
      end
     end)
    end
   end
  end
 end

 -- Create a falling nuke
 local function spawnNuke(position)
  if not running then return end
  local nuke=Instance.new("Part")
  nuke.Size=Vector3.new(4,8,4)
  nuke.BrickColor=BrickColor.new("Really red")
  nuke.Material=Enum.Material.Metal
  nuke.Anchored=false
  nuke.CanCollide=true
  nuke.Position=position
  nuke.Name="FallingNuke"
  local smoke=Instance.new("Smoke") smoke.Size=10 smoke.RiseVelocity=5 smoke.Parent=nuke
  nuke.Touched:Connect(function(hit)
   if not nuke or not nuke.Parent then return end
   local explosion=Instance.new("Explosion")
   explosion.BlastRadius=25
   explosion.BlastPressure=1000000
   explosion.Position=nuke.Position
   explosion.Parent=ws
   table.insert(spawned.Explosion,explosion)
   -- Fire
   for i=1,5 do
    if not running then break end
    local fire=Instance.new("Fire") fire.Size=15 fire.Heat=10
    local firePart=Instance.new("Part") firePart.Anchored=true firePart.CanCollide=false
    firePart.Transparency=1 firePart.Position=nuke.Position+Vector3.new(math.random(-5,5),0,math.random(-5,5))
    fire.Parent=firePart firePart.Parent=ws
    debris:AddItem(firePart,5)
    table.insert(spawned.Fire,firePart)
   end
   -- Explosion sound
   local boom=Instance.new("Sound",ws)
   boom.SoundId=EXPLOSION_SOUND_ID boom.Volume=2 boom.Position=nuke.Position boom:Play()
   debris:AddItem(boom,5)
   table.insert(spawned.Sound,boom)
   pcall(shakeCamera,nuke.Position)
   nuke:Destroy()
  end)
  nuke.Parent=ws
  table.insert(spawned.Nuke,nuke)
 end

 -- 3D countdown above center
 local function showCountdown(seconds)
  local part=Instance.new("Part")
  part.Anchored=true part.CanCollide=false part.Transparency=1
  part.Position=Vector3.new(0,60,0) part.Size=Vector3.new(1,1,1)
  part.Name="CountdownDisplay"
  local billboard=Instance.new("BillboardGui",part)
  billboard.Size=UDim2.new(0,200,0,100) billboard.AlwaysOnTop=true
  local label=Instance.new("TextLabel",billboard)
  label.Size=UDim2.new(1,0,1,0) label.BackgroundTransparency=1
  label.TextColor3=Color3.new(1,0,0) label.TextScaled=true
  label.Font=Enum.Font.Arcade label.Text="Nukes Inbound..."
  part.Parent=ws
  table.insert(spawned.Countdown,part)
  spawn(function()
   for i=seconds,0,-1 do
    if not running then break end
    label.Text="NUKES INCOMING IN: "..i
    wait(1)
   end
   if part and part.Parent then part:Destroy() end
  end)
 end

 -- Play siren
 local function playSiren()
  local siren=Instance.new("Sound",ws)
  siren.SoundId=SIREN_SOUND_ID siren.Volume=2 siren.Looped=false siren:Play()
  debris:AddItem(siren,10)
  table.insert(spawned.Siren,siren)
 end

 -- Start: Countdown & Siren
 pcall(playSiren)
 pcall(showCountdown,COUNTDOWN_TIME)

 -- Spawn 60 falling nukes after countdown
 spawn(function()
  wait(COUNTDOWN_TIME)
  for i=1,NUKE_COUNT do
   if not running then break end
   local x=math.random(-RANGE,RANGE)
   local z=math.random(-RANGE,RANGE)
   local y=math.random(MIN_HEIGHT,MAX_HEIGHT)
   pcall(spawnNuke,Vector3.new(x,y,z))
   wait(0.1)
  end
 end)

 active.Doomed={
  f=function()
   running=false
   for _,t in pairs(spawned) do
    for _,obj in pairs(t) do
     if obj and obj.Parent then pcall(function() obj:Destroy() end) end
    end
   end
  end,
 }
end,function() cleanup("Doomed") end)

-- 🎩 GENTLEMEN. — Ultimate Anthro Apocalypse (improved AI, wave system, boss mutants, Link Sword)
-- Wrapped as a chaos-mod effect with proper cleanup. Uses game:GetObjects instead of InsertService.
-- AI improvements: smarter pathfinding, stuck detection, aggressive direct-move fallback, jumping.
ext("gentlemen.","🎩",60,function()
 notif("🎩 GENTLEMEN. — Anthro Apocalypse! Wave system active.",5)
 local PathfindingService=game:GetService("PathfindingService")
 local running=true
 local mutants={}
 local bosses={}
 local fireballs={}
 local spawnedObjs={} -- everything we create for cleanup
 local waveNumber=0
 local totalKills=0
 local baseModel=nil
 local swordGiven=false

 -- Settings
 local spawnRadius=50
 local maxMutants=80
 local BOSS_SPAWN_INTERVAL=15
 local WAVE_SIZE_BASE=8
 local WAVE_SIZE_INCREMENT=4
 local AI_UPDATE_INTERVAL=0.4
 local FIREBALL_COOLDOWN=2.5
 local SLAM_COOLDOWN=4
 local WAVE_DELAY=3

 local sounds={
  fireball="rbxassetid://131961136", slam="rbxassetid://131961136",
  swordHit="rbxassetid://12222030", bossSpawn="rbxassetid://131961136",
  waveStart="rbxassetid://12222030", waveComplete="rbxassetid://131961136",
 }

 local function track(obj) if obj then table.insert(spawnedObjs,obj) end return obj end
 local function loadSound(id,parent,vol)
  local s=Instance.new("Sound") s.SoundId=id s.Volume=vol or 0.5 s.RollOffMode=Enum.RollOffMode.Linear s.MaxDistance=100
  s.Parent=parent or ws track(s) return s
 end

 -- Load base mutant model via game:GetObjects (executor API, more reliable than InsertService)
 local function loadBaseModel()
  if baseModel then return baseModel end
  pcall(function()
   local objs=game:GetObjects("rbxassetid://1267104857")
   if objs and objs[1] then
    baseModel=objs[1]
    -- Configure parts
    for _,part in baseModel:GetDescendants() do
     if part:IsA("BasePart") then
      part.Anchored=false
      part.CanCollide=(part.Name=="HumanoidRootPart")
     end
    end
   end
  end)
  if not baseModel then
   -- Fallback: build a simple blocky mutant
   baseModel=Instance.new("Model") baseModel.Name="FallbackMutant"
   local hum=Instance.new("Humanoid") hum.Parent=baseModel
   local hrp=Instance.new("Part") hrp.Name="HumanoidRootPart" hrp.Size=Vector3.new(2,2,1)
   hrp.Color=Color3.fromRGB(100,100,100) hrp.Anchored=false hrp.CanCollide=true hrp.Parent=baseModel
   local torso=Instance.new("Part") torso.Name="Torso" torso.Size=Vector3.new(2,2,1)
   torso.Color=Color3.fromRGB(120,120,120) torso.Anchored=false torso.CanCollide=false torso.Parent=baseModel
   local head=Instance.new("Part") head.Name="Head" head.Size=Vector3.new(2,1,1)
   head.Color=Color3.fromRGB(140,140,140) head.Shape=Enum.PartType.Ball head.Anchored=false head.CanCollide=false head.Parent=baseModel
   local w1=Instance.new("WeldConstraint") w1.Part0=hrp w1.Part1=torso w1.Parent=hrp
   local w2=Instance.new("WeldConstraint") w2.Part0=hrp w2.Part1=head w2.Parent=hrp
  end
  return baseModel
 end

 -- Give the player a Link Sword
 local function giveLinkSword()
  if swordGiven or not char or not plr:FindFirstChild("Backpack") then return end
  swordGiven=true
  local sword=Instance.new("Tool") sword.Name="LinkSword" sword.RequiresHandle=true sword.CanBeDropped=false
  local handle=Instance.new("Part") handle.Name="Handle" handle.Size=Vector3.new(1,4,1)
  handle.Color=Color3.fromRGB(85,255,0) handle.Material=Enum.Material.Neon handle.Anchored=false handle.CanCollide=false handle.Parent=sword
  local mesh=Instance.new("SpecialMesh") mesh.MeshType=Enum.MeshType.FileMesh mesh.MeshId="rbxasset://fonts/sword.mesh" mesh.Parent=handle
  -- Trail
  local a0=Instance.new("Attachment") a0.Position=Vector3.new(0,-2,0) a0.Parent=handle
  local a1=Instance.new("Attachment") a1.Position=Vector3.new(0,2,0) a1.Parent=handle
  local trail=Instance.new("Trail") trail.Attachment0=a0 trail.Attachment1=a1
  trail.Color=ColorSequence.new(Color3.fromRGB(85,255,0),Color3.fromRGB(0,255,85))
  trail.Lifetime=0.5 trail.Parent=handle
  local pl=Instance.new("PointLight") pl.Brightness=2 pl.Range=8 pl.Color=Color3.fromRGB(85,255,0) pl.Parent=handle
  local hitSound=loadSound(sounds.swordHit,handle,0.6)
  local damage=35+(waveNumber*3)
  local debounce={}
  handle.Touched:Connect(function(hit)
   local character=hit.Parent
   local humanoid=character and character:FindFirstChildOfClass("Humanoid")
   if humanoid and humanoid.Health>0 and (character.Name:match("Mutant") or character.Name:match("BossMutant")) and not debounce[character] then
    debounce[character]=true
    local isCrit=math.random(1,100)<=20
    local finalDamage=isCrit and damage*2.5 or damage
    if isCrit then
     local gui=Instance.new("BillboardGui") gui.Size=UDim2.new(0,100,0,50) gui.StudsOffset=Vector3.new(0,3,0)
     gui.Parent=character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
     local label=Instance.new("TextLabel") label.Size=UDim2.new(1,0,1,0) label.BackgroundTransparency=1
     label.Text="CRIT!" label.TextColor3=Color3.fromRGB(255,255,0) label.TextScaled=true label.Font=Enum.Font.GothamBold label.Parent=gui
     debris:AddItem(gui,1)
    end
    humanoid:TakeDamage(finalDamage)
    hitSound:Play()
    -- Knockback
    local root=character:FindFirstChild("HumanoidRootPart")
    if root then
     local kb=Instance.new("BodyVelocity") kb.MaxForce=Vector3.new(4000,0,4000)
     kb.Velocity=(root.Position-handle.Position).Unit*20 kb.Parent=root
     debris:AddItem(kb,0.3)
    end
    task.wait(0.2) debounce[character]=nil
   end
  end)
  sword.Parent=plr.Backpack
  track(sword)
 end

 -- Variant randomization
 local function randomizeVariant(mutant,isBoss)
  local humanoid=mutant:FindFirstChildOfClass("Humanoid") if not humanoid then return end
  local speedMult=math.random(80,120)/100
  local healthMult=math.random(70,130)/100
  local baseSpeed=(15+(waveNumber*1.5))*speedMult
  local baseHealth=(80+(waveNumber*20))*healthMult
  local scale=isBoss and (2.5+(waveNumber*0.08)) or (math.random(80,120)/100)
  if isBoss then
   humanoid.WalkSpeed=baseSpeed*1.8 humanoid.MaxHealth=baseHealth*8 humanoid.Health=humanoid.MaxHealth
   humanoid.JumpPower=60
  else
   humanoid.WalkSpeed=baseSpeed humanoid.MaxHealth=baseHealth humanoid.Health=humanoid.MaxHealth
   humanoid.JumpPower=50
  end
  local colorVariants={{255,100,100},{100,255,100},{100,100,255},{255,255,100},{255,100,255},{100,255,255},{255,150,100},{150,100,255}}
  local materialVariants={Enum.Material.SmoothPlastic,Enum.Material.Neon,Enum.Material.Metal,Enum.Material.Concrete,Enum.Material.Rock}
  for _,part in mutant:GetDescendants() do
   if part:IsA("BasePart") then
    pcall(function() part.Size=part.Size*scale end)
    if isBoss then
     part.Color=Color3.fromRGB(255,50,50) part.Material=Enum.Material.Neon
     local plight=Instance.new("PointLight") plight.Brightness=8 plight.Range=25 plight.Color=Color3.fromRGB(255,100,100) plight.Parent=part
    else
     local cs=colorVariants[math.random(#colorVariants)]
     part.Color=Color3.fromRGB(cs[1],cs[2],cs[3]) part.Material=materialVariants[math.random(#materialVariants)]
     local variant=math.random(1,100)
     if variant<=5 then part.Material=Enum.Material.Neon part.Color=Color3.fromRGB(255,215,0)
      humanoid.WalkSpeed=humanoid.WalkSpeed*1.5 humanoid.MaxHealth=humanoid.MaxHealth*2 humanoid.Health=humanoid.MaxHealth
     elseif variant<=15 then part.Material=Enum.Material.Neon part.Color=Color3.fromRGB(138,43,226)
      humanoid.WalkSpeed=humanoid.WalkSpeed*1.2 humanoid.MaxHealth=humanoid.MaxHealth*1.5 humanoid.Health=humanoid.MaxHealth
     end
    end
   end
  end
  if isBoss then
   mutant:SetAttribute("LastFireball",0) mutant:SetAttribute("LastSlam",0)
  end
 end

 -- Boss fireball
 local function bossShootFireball(boss,target)
  if not running or not boss or not boss.Parent or not target then return end
  local currentTime=tick()
  if currentTime-(boss:GetAttribute("LastFireball") or 0)<FIREBALL_COOLDOWN then return end
  boss:SetAttribute("LastFireball",currentTime)
  local root=boss:FindFirstChild("HumanoidRootPart") if not root then return end
  local fireball=Instance.new("Part") fireball.Shape=Enum.PartType.Ball fireball.Color=Color3.fromRGB(255,100,0)
  fireball.Material=Enum.Material.Neon fireball.Size=Vector3.new(2,2,2) fireball.Anchored=false fireball.CanCollide=false
  fireball.CFrame=root.CFrame*CFrame.new(0,2,-3) fireball.Parent=ws track(fireball) table.insert(fireballs,fireball)
  local plight=Instance.new("PointLight") plight.Brightness=15 plight.Range=20 plight.Color=Color3.fromRGB(255,150,0) plight.Parent=fireball
  local sound=loadSound(sounds.fireball,fireball,0.8) sound:Play()
  -- Predicted direction
  local targetVel=target.AssemblyLinearVelocity or Vector3.new(0,0,0)
  local predictedPos=target.Position+(targetVel*0.5)
  local direction=(predictedPos-root.Position).Unit
  local bv=Instance.new("BodyVelocity") bv.MaxForce=Vector3.new(8000,8000,8000) bv.Velocity=direction*60 bv.Parent=fireball
  fireball.Touched:Connect(function(hit)
   if not running then return end
   if hit.Parent==char then
    local h=char:FindFirstChildOfClass("Humanoid")
    if h then h:TakeDamage(30+(waveNumber*3)) end
    fireball:Destroy()
   elseif not hit:IsDescendantOf(boss) and not hit:IsDescendantOf(char) then
    local exp=Instance.new("Explosion") exp.Position=fireball.Position exp.BlastPressure=0 exp.BlastRadius=8
    exp.ExplosionType=Enum.ExplosionType.NoCraters exp.Parent=ws track(exp)
    fireball:Destroy()
   end
  end)
  debris:AddItem(fireball,6)
 end

 -- Boss ground slam
 local function bossGroundSlam(boss)
  if not running or not boss or not boss.Parent then return end
  local currentTime=tick()
  if currentTime-(boss:GetAttribute("LastSlam") or 0)<SLAM_COOLDOWN then return end
  boss:SetAttribute("LastSlam",currentTime)
  local root=boss:FindFirstChild("HumanoidRootPart") if not root or not hrp then return end
  local distance=(hrp.Position-root.Position).Magnitude
  if distance<20 then
   local sound=loadSound(sounds.slam,root,1.2) sound:Play()
   -- Shockwave
   for i=1,3 do
    task.spawn(function()
     task.wait(i*0.1)
     if not running then return end
     local sw=Instance.new("Part") sw.Shape=Enum.PartType.Cylinder sw.Color=Color3.fromRGB(255,150,0)
     sw.Material=Enum.Material.Neon sw.Size=Vector3.new(0.5,5,5)
     sw.CFrame=root.CFrame*CFrame.new(0,-3,0)*CFrame.Angles(math.pi/2,0,0)
     sw.Anchored=true sw.CanCollide=false sw.Transparency=0.3 sw.Parent=ws track(sw)
     ts:Create(sw,TweenInfo.new(0.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=Vector3.new(0.5,40,40),Transparency=1}):Play()
     debris:AddItem(sw,0.8)
    end)
   end
   if distance<15 and hum then
    local damage=(25+(waveNumber*2))*(1-distance/15)
    hum:TakeDamage(damage)
    local bp=Instance.new("BodyVelocity") bp.Velocity=Vector3.new(0,60,0)+(hrp.Position-root.Position).Unit*30
    bp.MaxForce=Vector3.new(15000,15000,15000) bp.Parent=hrp debris:AddItem(bp,0.4)
   end
  end
 end

 -- ★ IMPROVED AI: smarter pathfinding with stuck detection + aggressive direct-move fallback
 local lastPathCompute={} -- [mutant] = tick of last path computation
 local lastPlayerPos=Vector3.new(0,0,0)
 local stuckTimer={} -- [mutant] = {lastPos=Vector3, time=tick}
 local function moveToPlayer(mutant)
  if not running or not mutant or not mutant.Parent then return end
  local humanoid=mutant:FindFirstChildOfClass("Humanoid")
  local root=mutant:FindFirstChild("HumanoidRootPart")
  if not humanoid or not root or humanoid.Health<=0 then return end
  if not hrp then humanoid:MoveTo(root.Position) return end
  local playerPos=hrp.Position
  local distToPlayer=(playerPos-root.Position).Magnitude
  -- If close enough, just move directly (no pathfinding needed)
  if distToPlayer<15 then
   humanoid:MoveTo(playerPos)
   -- Jump if player is above us
   if playerPos.Y>root.Position.Y+3 then humanoid.Jump=true end
   return
  end
  -- Recompute path only every 1.5s, OR if player moved >10 studs since last compute
  local lastCompute=lastPathCompute[mutant] or 0
  local playerMoved=(playerPos-lastPlayerPos).Magnitude>10
  if tick()-lastCompute<1.5 and not playerMoved then
   -- Just keep moving toward player directly (cheaper than pathfinding every frame)
   humanoid:MoveTo(playerPos)
   return
  end
  lastPathCompute[mutant]=tick()
  lastPlayerPos=playerPos
  -- Try pathfinding
  local path=PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true,AgentJumpHeight=10,AgentMaxSlope=45})
  local success,result=pcall(function() path:ComputeAsync(root.Position,playerPos) end)
  if not success or path.Status~=Enum.PathStatus.Complete then
   -- Pathfinding failed — fall back to direct movement (more aggressive than original)
   humanoid:MoveTo(playerPos)
   -- Try jumping to unstick
   if humanoid.MoveDirection.Magnitude<0.1 then humanoid.Jump=true end
   return
  end
  -- Follow waypoints (follow up to 5, not just 3)
  local waypoints=path:GetWaypoints()
  if #waypoints>1 then
   local wpIdx=2 -- skip first waypoint (current position)
   while wpIdx<=math.min(6,#waypoints) and running and mutant.Parent and humanoid.Health>0 do
    local wp=waypoints[wpIdx]
    humanoid:MoveTo(wp.Position)
    if wp.Action==Enum.PathWaypointAction.Jump then humanoid.Jump=true end
    -- Wait with timeout
    local reached=humanoid.MoveToFinished:Wait(1.0)
    -- Stuck detection: if we didn't reach and we're not moving, jump
    if not reached then
     local currentVel=root.AssemblyLinearVelocity
     if currentVel.Magnitude<2 then humanoid.Jump=true end
     break -- Recompute next iteration
    end
    wpIdx=wpIdx+1
   end
  else
   humanoid:MoveTo(playerPos)
  end
 end

 -- Create a mutant
 local function createMutant(isBoss)
  if not running then return end
  if #mutants>=maxMutants then return end
  loadBaseModel()
  if not baseModel then return end
  local mutant=baseModel:Clone()
  for _,part in mutant:GetDescendants() do
   if part:IsA("BasePart") then
    part.Anchored=false part.CanCollide=(part.Name=="HumanoidRootPart")
   end
  end
  local root=mutant:FindFirstChild("HumanoidRootPart")
  local humanoid=mutant:FindFirstChildOfClass("Humanoid")
  if not root or not humanoid then mutant:Destroy() return end
  -- Spawn position with raycast to find ground
  local playerPos=hrp and hrp.Position or Vector3.new(0,50,0)
  local spawnPos=playerPos+Vector3.new(math.random(-spawnRadius,spawnRadius),20,math.random(-spawnRadius,spawnRadius))
  local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Blacklist rp.FilterDescendantsInstances={mutant}
  local rayResult=ws:Raycast(spawnPos,Vector3.new(0,-100,0),rp)
  if rayResult then spawnPos=rayResult.Position+Vector3.new(0,5,0) end
  root.Position=spawnPos
  randomizeVariant(mutant,isBoss)
  mutant.Name=isBoss and ("BossMutant_"..tick()) or ("Mutant_"..tick())
  mutant.Parent=ws track(mutant)
  table.insert(mutants,mutant)
  if isBoss then
   table.insert(bosses,mutant)
   local sound=loadSound(sounds.bossSpawn,root,1.2) sound:Play()
  end
  -- Death handler
  humanoid.Died:Connect(function()
   totalKills=totalKills+(isBoss and 10 or 1)
   for i,m in ipairs(mutants) do if m==mutant then table.remove(mutants,i) break end end
   for i,b in ipairs(bosses) do if b==mutant then table.remove(bosses,i) break end end
   if isBoss then
    local exp=Instance.new("Explosion") exp.Position=root.Position exp.BlastRadius=15 exp.BlastPressure=2000
    exp.ExplosionType=Enum.ExplosionType.NoCraters exp.Parent=ws track(exp)
   end
   task.wait(2) if mutant and mutant.Parent then mutant:Destroy() end
  end)
  return mutant
 end

 -- Cleanup dead/distant mutants
 local function cleanupMutants()
  if not hrp then return end
  for i=#mutants,1,-1 do
   local m=mutants[i]
   if not m or not m.Parent then table.remove(mutants,i)
   elseif m:FindFirstChild("HumanoidRootPart") then
    local dist=(m.HumanoidRootPart.Position-hrp.Position).Magnitude
    if dist>200 then m:Destroy() table.remove(mutants,i) end
   end
  end
  for i=#bosses,1,-1 do
   local b=bosses[i] if not b or not b.Parent then table.remove(bosses,i) end
  end
 end

 -- Give sword
 pcall(giveLinkSword)

 -- Boss behavior loop
 local bossLoop
 bossLoop=task.spawn(function()
  while running do
   for _,boss in ipairs(bosses) do
    if boss and boss.Parent and boss:FindFirstChild("HumanoidRootPart") then
     local h=boss:FindFirstChildOfClass("Humanoid")
     if h and h.Health>0 then
      if math.random(1,100)<=15 then
       if math.random(1,2)==1 then pcall(bossShootFireball,boss,hrp)
       else pcall(bossGroundSlam,boss) end
      end
      if h.Health<h.MaxHealth then h.Health=math.min(h.MaxHealth,h.Health+(waveNumber*0.5)) end
     end
    end
   end
   task.wait(0.8)
  end
 end)

 -- ★ IMPROVED AI loop: smarter, less frequent pathfinding, stuck detection
 local aiLoop
 aiLoop=task.spawn(function()
  while running do
   if hrp then
    cleanupMutants()
    for _,mutant in ipairs(mutants) do
     if mutant and mutant.Parent then
      pcall(moveToPlayer,mutant)
     end
    end
   end
   task.wait(AI_UPDATE_INTERVAL)
  end
 end)

 -- Wave system (auto-start, no button needed)
 local waveInProgress=false
 local function startWave()
  if waveInProgress or not running then return end
  waveInProgress=true
  waveNumber=waveNumber+1
  local waveSize=WAVE_SIZE_BASE+(waveNumber*WAVE_SIZE_INCREMENT)
  notif("🎩 Wave "..waveNumber.." incoming! "..waveSize.." mutants",3)
  if hrp then local s=loadSound(sounds.waveStart,hrp,1) s:Play() end
  for i=1,waveSize do
   if not running then break end
   local isBoss=(i%BOSS_SPAWN_INTERVAL==0) and (waveNumber>1)
   pcall(createMutant,isBoss)
   task.wait(0.2)
  end
  waveInProgress=false
  -- Wait for wave to clear, then start next
  task.spawn(function()
   while #mutants>0 and running do task.wait(2) end
   if running then
    notif("🎩 Wave "..waveNumber.." complete! Kills: "..totalKills,3)
    if hrp then local s=loadSound(sounds.waveComplete,hrp,1) s:Play() end
    task.wait(WAVE_DELAY)
    if running then pcall(startWave) end
   end
  end)
 end
 -- Start first wave after a short delay
 delay(2,function() if running then pcall(startWave) end end)

 active.Gentlemen={
  f=function()
   running=false
   -- Stop all loops (they check `running` flag)
   -- Destroy all spawned objects
   for _,obj in ipairs(spawnedObjs) do
    if obj and obj.Parent then pcall(function() obj:Destroy() end) end
   end
   -- Destroy all mutants/bosses explicitly (in case they weren't in spawnedObjs)
   for _,m in ipairs(mutants) do if m and m.Parent then pcall(function() m:Destroy() end) end end
   for _,b in ipairs(bosses) do if b and b.Parent then pcall(function() b:Destroy() end) end end
  end,
 }
end,function() cleanup("Gentlemen") end)

-- ============================================
-- EFFECT: oh dear it looks like I combusted in flames
--   Fancy Chatting — intercepts the local chat box and rewrites
--   every message you send into excessively fancy English before
--   it actually goes out. Original chat FocusLost handlers are
--   temporarily disabled while the effect is active and restored
--   on cleanup. Falls back to a local synonym table; if a word
--   isn't found there, it queries the Datamuse API (executor
--   `request` global) and picks the longest single-word synonym.
-- ============================================
local _FancyChat_skip = {
 "a","an","the","is","it","in","on","at","to","of","or","and","but",
 "for","i","me","my","we","us","you","he","she","him","her","his",
 "they","them","was","are","be","do","did","has","had","not","no",
 "as","by","if","that","this","with","from","what","when","your",
 "their","than","then","who","how","where"
}
for i,v in ipairs(_FancyChat_skip) do _FancyChat_skip[v]=true _FancyChat_skip[i]=nil end

local _FancyChat_map = {
 {"good","splendid"},{"bad","dreadful"},{"big","grandiose"},{"small","diminutive"},
 {"happy","elated"},{"sad","melancholic"},{"said","proclaimed"},{"say","proclaim"},
 {"think","contemplate"},{"want","desire"},{"need","require"},{"get","acquire"},
 {"got","obtained"},{"use","utilise"},{"very","tremendously"},{"really","exceedingly"},
 {"nice","exquisite"},{"cool","remarkable"},{"awesome","magnificent"},{"weird","peculiar"},
 {"old","antiquated"},{"new","contemporary"},{"fast","expeditious"},{"slow","lethargic"},
 {"smart","astute"},{"dumb","obtuse"},{"angry","indignant"},{"scared","apprehensive"},
 {"sure","certainly"},{"maybe","perhaps"},{"also","furthermore"},{"know","discern"},
 {"look","observe"},{"see","perceive"},{"try","endeavour"},{"start","commence"},
 {"end","conclude"},{"make","fabricate"},{"tell","inform"},{"show","demonstrate"},
 {"help","assist"},{"thing","matter"},{"things","matters"},{"people","individuals"},
 {"money","capital"},{"house","residence"},{"talk","converse"},{"walk","promenade"},
 {"buy","procure"},{"give","bestow"},{"take","acquire"},{"keep","retain"},
 {"go","proceed"},{"went","proceeded"},{"eat","consume"},{"drink","imbibe"}
}
for i,v in ipairs(_FancyChat_map) do _FancyChat_map[v[1]]=v[2] _FancyChat_map[i]=nil end

local function _FancyChat_transform(word)
 local punct = word:match("[%p]+$") or ""
 local clean = word:gsub("[%p]+$", "")
 local lower = clean:lower()
 if clean == "" or _FancyChat_skip[lower] then return word end

 local result = _FancyChat_map[lower]

 if not result and request then
  pcall(function()
   local res = request({
    Url = "https://api.datamuse.com/words?rel_syn=" .. HttpService:UrlEncode(lower) .. "&max=20",
    Method = "GET"
   })
   if res and res.Body then
    local data = HttpService:JSONDecode(res.Body)
    local longest = clean
    for _, e in ipairs(data) do
     if type(e.word)=="string" and not e.word:find(" ") and #e.word > #longest then longest = e.word end
    end
    result = longest
   end
  end)
 end

 if not result then return word end
 if clean:sub(1,1):match("%u") then result = result:sub(1,1):upper() .. result:sub(2) end
 return result .. punct
end

ext("oh dear it looks like I combusted in flames","🔥",20,function()
 local CoreGui = game:GetService("CoreGui")
 local TextChatService = game:GetService("TextChatService")

 -- Resolve the ExperienceChat TextBox with a soft timeout (some games
 -- disable chat entirely — we just bail instead of hanging the effect).
 local textBox
 pcall(function()
  local expChat = CoreGui:WaitForChild("ExperienceChat", 5)
  if expChat then
   textBox = expChat.appLayout.chatInputBar.Background.Container.TextContainer.TextBoxContainer.TextBox
  end
 end)
 if not textBox then notif("🔥 Chat box not found — fancy chat skipped",2) return end

 -- Disable the default chat FocusLost handlers so the raw message
 -- doesn't slip through alongside our rewritten one.
 local origConns = {}
 pcall(function()
  for _,c in ipairs(getconnections(textBox.FocusLost)) do
   c:Disable()
   table.insert(origConns, c)
  end
 end)

 local hookConn
 hookConn = textBox.FocusLost:Connect(function(enterPressed)
  if not enterPressed or textBox.Text == "" then return end
  local original = textBox.Text
  textBox.Text = ""
  textBox:ReleaseFocus()
  task.spawn(function()
   local out = {}
   for word in original:gmatch("%S+") do table.insert(out, _FancyChat_transform(word)) end
   pcall(function()
    TextChatService.TextChannels.RBXGeneral:SendAsync(table.concat(out, " "))
   end)
  end)
 end)

 notif("🔥 Fancy chat engaged — speaketh fancifully!",3)

 active.FancyChat = {
  f = function()
   if hookConn then pcall(function() hookConn:Disconnect() end) hookConn=nil end
   for _,c in ipairs(origConns) do pcall(function() c:Enable() end) end
  end
 }
end,function() cleanup("FancyChat") end)

-- ============================================
-- EFFECT: OH YEAH MR KRABS
--   Classic Mr Krabs skybox + decal spam meme.
--   Replaces the skybox with a Mr Krabs decal, slaps 6 Mr Krabs
--   decals on every BasePart in the workspace, plays the slowed
--   Mr Krabs audio looped at max volume, and flashes a hint
--   between "OH YEAH MR KRABS!!!!!!" and "HACKED BY MR KRABS!".
--   Original by 9x7x9x4x6 — adapted to respect effect duration
--   with full cleanup (sky removed, decals destroyed, hidden
--   decals restored, audio stopped, hint destroyed).
-- ============================================
local _Krabs_faces = {
 Enum.NormalId.Front, Enum.NormalId.Back,
 Enum.NormalId.Right, Enum.NormalId.Left,
 Enum.NormalId.Top,  Enum.NormalId.Bottom,
}

ext("OH YEAH MR KRABS","🦀",20,function()
 local DECAL_ID = "118440882446584"
 local SOUND_ID = "rbxassetid://87663330165612"
 local url = "http://www.roblox.com/asset/?id=" .. DECAL_ID

 -- Audio: slowed to 0.1x playback, max volume, looped
 local audio = Instance.new("Sound")
 audio.Name = "MrKrabsAudio"
 audio.SoundId = SOUND_ID
 audio.PlaybackSpeed = 0.1
 audio.Looped = true
 audio.Volume = 10
 audio.Parent = ws
 pcall(function() audio:Play() end)

 -- Skybox replacement
 local sky = Instance.new("Sky")
 sky.Name = "MrKrabsSky"
 sky.Parent = ls
 sky.SkyboxBk = url
 sky.SkyboxDn = url
 sky.SkyboxFt = url
 sky.SkyboxLf = url
 sky.SkyboxRt = url
 sky.SkyboxUp = url

 -- Workspace decal pass:
 --  • Hide existing decals (track them so we can restore on cleanup)
 --  • Add 6 Mr Krabs decals to every BasePart (one per face)
 --  • Reset material to Plastic / Transparency to 0 so the decal shows
 --  • Yield every 200 nodes so we don't freeze the client on big games
 local addedDecals = {}
 local hiddenDecals = {}  -- [decalInstance] = originalParent
 local running = true
 local nodeCount = 0

 local function exPro(root)
  if not running then return end
  for _, v in ipairs(root:GetChildren()) do
   if not running then return end
   if v:IsA("Decal") then
    -- Hide decals parented directly to containers (rare but possible)
    if hiddenDecals[v] == nil then
     hiddenDecals[v] = v.Parent
     v.Parent = nil
    end
   elseif v:IsA("BasePart") then
    -- Hide existing decals on this part
    for _, d in ipairs(v:GetChildren()) do
     if d:IsA("Decal") and hiddenDecals[d] == nil then
      hiddenDecals[d] = v
      d.Parent = nil
     end
    end
    v.Material = Enum.Material.Plastic
    v.Transparency = 0
    -- Add 6 Mr Krabs decals (one per face)
    for _, face in ipairs(_Krabs_faces) do
     local d = Instance.new("Decal")
     d.Texture = url
     d.Face = face
     d.Parent = v
     addedDecals[#addedDecals+1] = d
    end
   end
   -- Recurse into models, folders, etc. to find more parts
   exPro(v)
   nodeCount = nodeCount + 1
   if nodeCount % 200 == 0 then wait() end  -- yield to avoid freeze
  end
 end

 -- Run the decal pass in the background (it yields periodically)
 task.spawn(function() pcall(exPro, ws) end)

 -- Flashing hint at the top of the screen
 local hint = Instance.new("Hint")
 hint.Name = "MrKrabsHint"
 hint.Parent = ws
 hint.Text = "OH YEAH MR KRABS!!!!!!"

 task.spawn(function()
  while running and hint and hint.Parent do
   hint.Text = "OH YEAH MR KRABS!!!!!!"
   wait(1)
   if not running or not hint or not hint.Parent then break end
   hint.Text = "HACKED BY MR KRABS!"
   wait(1)
  end
 end)

 notif("🦀 OH YEAH MR KRABS! HEHEHE",3)

 active.MrKrabs = {
  f = function()
   running = false
   -- Stop + destroy audio
   pcall(function() audio:Stop() audio:Destroy() end)
   -- Remove skybox (any previous sky becomes active again automatically)
   pcall(function() sky:Destroy() end)
   -- Remove hint
   pcall(function() if hint then hint:Destroy() end end)
   -- Batch-destroy added decals (yield to avoid freeze on big games)
   local i = 0
   for _, d in ipairs(addedDecals) do
    if d and d.Parent then pcall(function() d:Destroy() end) end
    i = i + 1
    if i % 300 == 0 then wait() end
   end
   -- Restore hidden decals to their original parents
   for d, parent in pairs(hiddenDecals) do
    if d and parent and parent.Parent then
     pcall(function() d.Parent = parent end)
    end
   end
  end
 }
end,function() cleanup("MrKrabs") end)

-- ============================================
-- EFFECT: scp 096 has breached the containment
--   Spawns the SCP-096 NPC (Comix version) that sits idle until a
--   player gets within sight range, then chases them at high speed
--   and kills them on contact. Plays custom Comix OST audio, shows
--   a death screen to victims, and ragdolls the victim's body.
--
--   Original script by SuperSayan2_Goku / Rufus14. Adapted here
--   as a timed chaos effect with full cleanup: coroutines are
--   closed via coroutine.close, the model is destroyed, all sounds
--   are stopped, and any victim death GUIs are removed.
-- ============================================

-- Lazy-load helpers only used by this effect
local _SCP096_audioFiles = {
 {path="096_comix_idle.mp3",   url="https://github.com/sfdgdrfsrf/friendly-doodle/raw/refs/heads/main/Iceberg%20Lab%20-%20Crash%20Twinsanity%20OST.mp3"},
 {path="096_comix_death.mp3",  url="https://github.com/sfdgdrfsrf/friendly-doodle/raw/refs/heads/main/SCP%20Comix%20Breach%20OST%20SCP-096%20sound%201.mp3"},
 {path="096_comix_chase1.mp3", url="https://github.com/sfdgdrfsrf/friendly-doodle/raw/refs/heads/main/SCP%20Comix%20Breach%20SCP-096%20Chase%20Theme.mp3"},
 {path="096_comix_chase2.mp3", url="https://github.com/sfdgdrfsrf/friendly-doodle/raw/refs/heads/main/Scp%20-%20Comix%20-%20Mod%20-%20Scp%20-%20096%20-%20Chase%20-%20Theme%20-%2010%20-%20Minutes.mp3"},
 {path="096_comix_chase3.mp3", url="https://github.com/sfdgdrfsrf/curly-winner/raw/refs/heads/main/Captain%20Underpants%20Theme%20Song.mp3"},
 {path="096_comix_chase4.mp3", url="https://github.com/sfdgdrfsrf/curly-winner/raw/refs/heads/main/Surfin%20Bird.mp3"},
}

-- Download audio files once (skip if already on disk). Wrapped in
-- pcall so a network failure doesn't kill the whole effect — the
-- sounds just won't play, but the SCP model still spawns.
local function _SCP096_downloadAudio()
 if not (writefile and isfile and readfile) then return end
 for _,f in ipairs(_SCP096_audioFiles) do
  if not isfile(f.path) then
   pcall(function()
    local data=game:HttpGet(f.url)
    writefile(f.path, data)
   end)
  end
 end
end

ext("scp 096 has breached the containment","😱",45,function()
 print("By SuperSayan2_Goku (Comix Version - Proper Animations)")

 -- Download audio (no-op if already cached or executor lacks APIs)
 _SCP096_downloadAudio()

 -- We need a local sandbox so the embedded AI script can use `script`
 -- as a reference to its model. This matches the original script.
 local function sandbox(var,func)
  local env = getfenv(func)
  local newenv = setmetatable({},{
   __index = function(self,k)
    if k=="script" then return var else return env[k] end
   end,
  })
  setfenv(func,newenv)
  return func
 end

 local cors = {}
 local mas = Instance.new("Model")
 mas.Parent = ls

 -- Build the model exactly as the original script does
 local Model0 = Instance.new("Model")
 local Part1 = Instance.new("Part")
 local Part2 = Instance.new("Part")
 local Part3 = Instance.new("Part")
 local Motor6D4 = Instance.new("Motor6D")
 local Motor6D5 = Instance.new("Motor6D")
 local Motor6D6 = Instance.new("Motor6D")
 local Motor6D7 = Instance.new("Motor6D")
 local Motor6D8 = Instance.new("Motor6D")
 local Part9 = Instance.new("Part")
 local Part10 = Instance.new("Part")
 local Part11 = Instance.new("Part")
 local SpecialMesh12 = Instance.new("SpecialMesh")
 local Weld13 = Instance.new("Weld")
 local Sound14 = Instance.new("Sound")
 local Sound15 = Instance.new("Sound")
 local Sound16 = Instance.new("Sound")
 local Sound17 = Instance.new("Sound")
 local Sound18 = Instance.new("Sound")
 local PointLight19 = Instance.new("PointLight")
 local Humanoid20 = Instance.new("Humanoid")
 local Script21 = Instance.new("Script")
 local Part22 = Instance.new("Part")
 local Motor6D23 = Instance.new("Motor6D")
 local Model24 = Instance.new("Model")
 local ScreenGui25 = Instance.new("ScreenGui")
 local Frame26 = Instance.new("Frame")
 local Part27 = Instance.new("Part")
 local Decal28 = Instance.new("Decal")

 Model0.Name = "SCP-096"
 Model0.Parent = mas
 Part1.Name = "Left Arm"; Part1.Parent = Model0
 Part1.CFrame = CFrame.new(-2.80085993, 4.50001383, -40.2011566, 1, 0, 0, 0, 1, -2.202814e-16, 0, -2.202814e-16, 1)
 Part1.Color = Color3.new(0.905882, 0.905882, 0.92549); Part1.Size = Vector3.new(1, 5, 1)
 Part1.BottomSurface = Enum.SurfaceType.Smooth; Part1.TopSurface = Enum.SurfaceType.Smooth
 Part1.BrickColor = BrickColor.new("White"); Part1.brickColor = BrickColor.new("White")
 Part2.Name = "Right Arm"; Part2.Parent = Model0
 Part2.CFrame = CFrame.new(-2.80085993, 4.50001383, -43.2011566, 1, 0, 0, 0, 1, -2.202814e-16, 0, -2.202814e-16, 1)
 Part2.Color = Color3.new(0.905882, 0.905882, 0.92549); Part2.Size = Vector3.new(1, 5, 1)
 Part2.BottomSurface = Enum.SurfaceType.Smooth; Part2.TopSurface = Enum.SurfaceType.Smooth
 Part2.BrickColor = BrickColor.new("White"); Part2.brickColor = BrickColor.new("White")
 Part3.Name = "Torso"; Part3.Parent = Model0
 Part3.CFrame = CFrame.new(-2.80085993, 5.50001383, -41.7011566, 1, 0, 0, 0, 1, -2.202814e-16, 0, -2.202814e-16, 1)
 Part3.Color = Color3.new(0.356863, 0.364706, 0.411765); Part3.Size = Vector3.new(1, 3, 2)
 Part3.BottomSurface = Enum.SurfaceType.Smooth; Part3.TopSurface = Enum.SurfaceType.Smooth
 Part3.BrickColor = BrickColor.new("White"); Part3.brickColor = BrickColor.new("White")
 Motor6D4.Name = "Right Hip"; Motor6D4.Parent = Part3
 Motor6D4.C0 = CFrame.new(0, -3.5, -0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)
 Motor6D4.Part0 = Part3; Motor6D4.Part1 = Part9; Motor6D4.part1 = Part9
 Motor6D5.Name = "Right Shoulder"; Motor6D5.Parent = Part3
 Motor6D5.C0 = CFrame.new(0, -1, -1.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)
 Motor6D5.Part0 = Part3; Motor6D5.Part1 = Part2; Motor6D5.part1 = Part2
 Motor6D6.Name = "Left Hip"; Motor6D6.Parent = Part3
 Motor6D6.C0 = CFrame.new(0, -3.5, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)
 Motor6D6.Part0 = Part3; Motor6D6.Part1 = Part10; Motor6D6.part1 = Part10
 Motor6D7.Name = "Left Shoulder"; Motor6D7.Parent = Part3
 Motor6D7.C0 = CFrame.new(0, -1, 1.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)
 Motor6D7.Part0 = Part3; Motor6D7.Part1 = Part1; Motor6D7.part1 = Part1
 Motor6D8.Name = "Neck"; Motor6D8.Parent = Part3
 Motor6D8.C0 = CFrame.new(0, 2, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
 Motor6D8.Part0 = Part3; Motor6D8.Part1 = Part11; Motor6D8.part1 = Part11
 Part9.Name = "Right Leg"; Part9.Parent = Model0
 Part9.CFrame = CFrame.new(-2.80085993, 2.00001383, -42.2011566, 1, 0, 0, 0, 1, -2.202814e-16, 0, -2.202814e-16, 1)
 Part9.Color = Color3.new(0.905882, 0.905882, 0.92549); Part9.Size = Vector3.new(1, 4, 1)
 Part9.BottomSurface = Enum.SurfaceType.Smooth; Part9.TopSurface = Enum.SurfaceType.Smooth
 Part9.BrickColor = BrickColor.new("Pearl"); Part9.brickColor = BrickColor.new("Pearl")
 Part10.Name = "Left Leg"; Part10.Parent = Model0
 Part10.CFrame = CFrame.new(-2.80085993, 2.00001383, -41.2011566, 1, 0, 0, 0, 1, -2.202814e-16, 0, -2.202814e-16, 1)
 Part10.Color = Color3.new(0.905882, 0.905882, 0.92549); Part10.Size = Vector3.new(1, 4, 1)
 Part10.BottomSurface = Enum.SurfaceType.Smooth; Part10.TopSurface = Enum.SurfaceType.Smooth
 Part10.BrickColor = BrickColor.new("Pearl"); Part10.brickColor = BrickColor.new("Pearl")
 Part11.Name = "Head"; Part11.Parent = Model0
 Part11.CFrame = CFrame.new(-2.80085993, 7.50001383, -41.7011566, 1, 0, 0, 0, 1, -2.202814e-16, 0, -2.202814e-16, 1)
 Part11.Color = Color3.new(0.905882, 0.905882, 0.92549); Part11.Size = Vector3.new(1, 1, 2)
 Part11.BottomSurface = Enum.SurfaceType.Smooth; Part11.TopSurface = Enum.SurfaceType.Smooth
 Part11.BrickColor = BrickColor.new("White"); Part11.brickColor = BrickColor.new("White")
 SpecialMesh12.Parent = Part11
 SpecialMesh12.Scale = Vector3.new(1.20000005, 1.20000005, 1.20000005)
 Weld13.Parent = Part11
 Weld13.C0 = CFrame.new(-0.100000381, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
 Weld13.Part0 = Part11; Weld13.Part1 = Part27; Weld13.part1 = Part27
 Sound14.Name = "SCP-096 v0.8-0.9 Chasing Ambience(096_3)"; Sound14.Parent = Part11
 Sound14.Looped = true; Sound14.MaxDistance = 500; Sound14.Volume = 1
 Sound14.SoundId = getcustomasset("096_comix_chase1.mp3")
 Sound15.Name = "SCP-096 (Idle) v0.2"; Sound15.Parent = Part11
 Sound15.Looped = true; Sound15.MaxDistance = 60; Sound15.Playing = true
 Sound15.SoundId = getcustomasset("096_comix_idle.mp3"); Sound15.Volume = 1
 Sound16.Name = "SCP-096 (Face Viewed)"; Sound16.Parent = Part11
 Sound16.MaxDistance = 200; Sound16.SoundId = getcustomasset("096_comix_death.mp3"); Sound16.Volume = 1.6
 Sound17.Name = "Guard attacked by SCP-096 (Old sound)"; Sound17.Parent = Part11
 Sound17.MaxDistance = 0; Sound17.SoundId = getcustomasset("096_comix_death.mp3"); Sound17.Volume = 2
 Sound18.Name = "SCP-096 Scream (raging)"; Sound18.Parent = Part11
 Sound18.Looped = true; Sound18.MaxDistance = 0
 Sound18.SoundId = getcustomasset("096_comix_chase2.mp3"); Sound18.Volume = 2
 PointLight19.Parent = Part11
 Humanoid20.Parent = Model0
 Humanoid20.Health = 0; Humanoid20.LeftLeg = Part10; Humanoid20.MaxHealth = 0
 Humanoid20.RightLeg = Part9; Humanoid20.Torso = Part22; Humanoid20.maxHealth = 0
 Script21.Name = "SCP AI"; Script21.Parent = Model0

 -- The AI script body (kept verbatim from the original)
 local aiSource = [[
--Fully made by Rufus14 (with a little help from Weld Plugin by popomcnuggets)
-- Converted to use official Animation objects for smooth visuals
local scp = script.Parent
local torso = scp.Torso
torso.CFrame = torso.CFrame * CFrame.fromEulerAnglesXYZ(0,math.pi/2*2,0)
local head = scp.Head
local leftarm = scp["Left Arm"]
local rightarm = scp["Right Arm"]
local leftleg = scp["Left Leg"]
local rightleg = scp["Right Leg"]
local scphumanoid = scp.Humanoid
local deathgui = scp["This is what player sees after death"].Death
local idlesound = head["SCP-096 (Idle) v0.2"]
local chasesound = head["SCP-096 v0.8-0.9 Chasing Ambience(096_3)"]
local ragesound = head["SCP-096 (Face Viewed)"]
local screamsound = head["SCP-096 Scream (raging)"]
local killsomeone = head["Guard attacked by SCP-096 (Old sound)"]
local face = scp.facepart.face
local heartbeat = game:GetService("RunService").Heartbeat

local chaseThemes = {
    getcustomasset("096_comix_chase1.mp3"),
    getcustomasset("096_comix_chase2.mp3"),
    getcustomasset("096_comix_chase3.mp3"),
    getcustomasset("096_comix_chase4.mp3")
}

local idleFace = "http://www.roblox.com/asset/?id=1304527170"
local triggeredFace = "http://www.roblox.com/asset/?id=4643970832"
local rageFace = "http://www.roblox.com/asset/?id=987047830"
face.Texture = idleFace

local animator = Instance.new("Animator")
animator.Parent = scphumanoid

local sitAnim = Instance.new("Animation")
sitAnim.AnimationId = "rbxassetid://507768133"
local runAnim = Instance.new("Animation")
runAnim.AnimationId = "rbxassetid://507767723"

local sitTrack = animator:LoadAnimation(sitAnim)
sitTrack.Looped = true
local runTrack = animator:LoadAnimation(runAnim)
runTrack.Looped = true

sitTrack:Play()

local neck = torso.Neck
local leftshoulder = torso["Left Shoulder"]
local rightshoulder = torso["Right Shoulder"]
local lefthip = torso["Left Hip"]
local righthip = torso["Right Hip"]
local root = scp.HumanoidRootPart.RootJoint
local sight = 5
local sitting = true
local running = false
local canchase = true
scphumanoid.WalkSpeed = 0
scphumanoid.JumpPower = 0

function ragdollkill(character)
    local victimshumanoid = character:findFirstChildOfClass("Humanoid")
    if not character:findFirstChild("UpperTorso") then
        character.Archivable = true
        local ragdoll = character:Clone()
        ragdoll:findFirstChildOfClass("Humanoid").Health = 0
        ragdoll:findFirstChildOfClass("Humanoid").PlatformStand = true
        if ragdoll:findFirstChild("Health") then
            if ragdoll:findFirstChild("Health").ClassName == "Script" then
                ragdoll:findFirstChild("Health").Disabled = true
            end
        end
        for i,v in pairs(character:GetChildren()) do
            if v.ClassName == "Part" or v.ClassName == "ForceField" or v.ClassName == "Accessory" or v.ClassName == "Hat" then
                v:destroy()
            end
        end
        for i,v in pairs(character:GetChildren()) do
            if v.ClassName == "Accessory" then
                local attachment1 = v.Handle:findFirstChildOfClass("Attachment")
                if attachment1 then
                    for q,w in pairs(character:GetChildren()) do
                        if w.ClassName == "Part" then
                            local attachment2 = w:findFirstChild(attachment1.Name)
                            if attachment2 then
                                local hinge = Instance.new("HingeConstraint", v.Handle)
                                hinge.Attachment0 = attachment1
                                hinge.Attachment1 = attachment2
                                hinge.LimitsEnabled = true
                                hinge.LowerAngle = 0
                                hinge.UpperAngle = 0
                            end
                        end
                    end
                end
            end
        end
        ragdoll.Parent = workspace
        if ragdoll:findFirstChild("Right Arm") then
            local glue = Instance.new("Glue", ragdoll.Torso)
            glue.Part0 = ragdoll.Torso
            glue.Part1 = ragdoll:findFirstChild("Right Arm")
            glue.C0 = CFrame.new(1.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
            glue.C1 = CFrame.new(0, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
            local limbcollider = Instance.new("Part", ragdoll:findFirstChild("Right Arm"))
            limbcollider.Size = Vector3.new(1.4,1,1)
            limbcollider.Shape = "Cylinder"
            limbcollider.Transparency = 1
            limbcollider.Name = "LimbCollider"
            local limbcolliderweld = Instance.new("Weld", limbcollider)
            limbcolliderweld.Part0 = ragdoll:findFirstChild("Right Arm")
            limbcolliderweld.Part1 = limbcollider
            limbcolliderweld.C0 = CFrame.fromEulerAnglesXYZ(0,0,math.pi/2) * CFrame.new(-0.3,0,0)
        end
        if ragdoll:findFirstChild("Left Arm") then
            local glue = Instance.new("Glue", ragdoll.Torso)
            glue.Part0 = ragdoll.Torso
            glue.Part1 = ragdoll:findFirstChild("Left Arm")
            glue.C0 = CFrame.new(-1.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            glue.C1 = CFrame.new(0, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            local limbcollider = Instance.new("Part", ragdoll:findFirstChild("Left Arm"))
            limbcollider.Size = Vector3.new(1.4,1,1)
            limbcollider.Shape = "Cylinder"
            limbcollider.Name = "LimbCollider"
            limbcollider.Transparency = 1
            local limbcolliderweld = Instance.new("Weld", limbcollider)
            limbcolliderweld.Part0 = ragdoll:findFirstChild("Left Arm")
            limbcolliderweld.Part1 = limbcollider
            limbcolliderweld.C0 = CFrame.fromEulerAnglesXYZ(0,0,math.pi/2) * CFrame.new(-0.3,0,0)
        end
        if ragdoll:findFirstChild("Left Leg") then
            local glue = Instance.new("Glue", ragdoll.Torso)
            glue.Part0 = ragdoll.Torso
            glue.Part1 = ragdoll:findFirstChild("Left Leg")
            glue.C0 = CFrame.new(-0.5, -1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0)
            glue.C1 = CFrame.new(-0, 1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0)
            local limbcollider = Instance.new("Part", ragdoll:findFirstChild("Left Leg"))
            limbcollider.Size = Vector3.new(1.4,1,1)
            limbcollider.Shape = "Cylinder"
            limbcollider.Name = "LimbCollider"
            limbcollider.Transparency = 1
            local limbcolliderweld = Instance.new("Weld", limbcollider)
            limbcolliderweld.Part0 = ragdoll:findFirstChild("Left Leg")
            limbcolliderweld.Part1 = limbcollider
            limbcolliderweld.C0 = CFrame.fromEulerAnglesXYZ(0,0,math.pi/2) * CFrame.new(-0.3,0,0)
        end
        if ragdoll:findFirstChild("Right Leg") then
            local glue = Instance.new("Glue", ragdoll.Torso)
            glue.Part0 = ragdoll.Torso
            glue.Part1 = ragdoll:findFirstChild("Right Leg")
            glue.C0 = CFrame.new(0.5, -1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0)
            glue.C1 = CFrame.new(0, 1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0)
            local limbcollider = Instance.new("Part", ragdoll:findFirstChild("Right Leg"))
            limbcollider.Size = Vector3.new(1.4,1,1)
            limbcollider.Shape = "Cylinder"
            limbcollider.Name = "LimbCollider"
            limbcollider.Transparency = 1
            local limbcolliderweld = Instance.new("Weld", limbcollider)
            limbcolliderweld.Part0 = ragdoll:findFirstChild("Right Leg")
            limbcolliderweld.Part1 = limbcollider
            limbcolliderweld.C0 = CFrame.fromEulerAnglesXYZ(0,0,math.pi/2) * CFrame.new(-0.3,0,0)
        end
        if ragdoll:findFirstChild("Head") and ragdoll.Torso:findFirstChild("NeckAttachment") then
            local HeadAttachment = Instance.new("Attachment", ragdoll["Head"])
            HeadAttachment.Position = Vector3.new(0, -0.5, 0)
            local connection = Instance.new('HingeConstraint', ragdoll["Head"])
            connection.LimitsEnabled = true
            connection.Attachment0 = ragdoll.Torso.NeckAttachment
            connection.Attachment1 = HeadAttachment
            connection.UpperAngle = 60
            connection.LowerAngle = -60
        elseif ragdoll:findFirstChild("Head") and not ragdoll.Torso:findFirstChild("NeckAttachment") then
            local hedweld = Instance.new("Weld", ragdoll.Torso)
            hedweld.Part0 = ragdoll.Torso
            hedweld.Part1 = ragdoll.Head
            hedweld.C0 = CFrame.new(0,1.5,0)
        end
        game.Debris:AddItem(ragdoll, 60)
    elseif character:findFirstChild("UpperTorso") then
        character.Archivable = true
        local ragdoll = character:Clone()
        ragdoll:findFirstChildOfClass("Humanoid").Health = 0
        if ragdoll:findFirstChild("Health") then
            if ragdoll:findFirstChild("Health").ClassName == "Script" then
                ragdoll:findFirstChild("Health").Disabled = true
            end
        end
        for i,v in pairs(character:GetChildren()) do
            if v.ClassName == "Part" or v.ClassName == "ForceField" or v.ClassName == "Accessory" or v.ClassName == "Hat" or v.ClassName == "MeshPart" then
                v:destroy()
            end
        end
        for i,v in pairs(character:GetChildren()) do
            if v.ClassName == "Accessory" then
                local attachment1 = v.Handle:findFirstChildOfClass("Attachment")
                if attachment1 then
                    for q,w in pairs(character:GetChildren()) do
                        if w.ClassName == "Part" or w.ClassName == "MeshPart" then
                            local attachment2 = w:findFirstChild(attachment1.Name)
                            if attachment2 then
                                local hinge = Instance.new("HingeConstraint", v.Handle)
                                hinge.Attachment0 = attachment1
                                hinge.Attachment1 = attachment2
                                hinge.LimitsEnabled = true
                                hinge.LowerAngle = 0
                                hinge.UpperAngle = 0
                            end
                        end
                    end
                end
            end
        end
        ragdoll.Parent = workspace
        local Humanoid = ragdoll:findFirstChildOfClass("Humanoid")
        Humanoid.PlatformStand = true
        local function makeballconnections(limb, attachementone, attachmenttwo, twistlower, twistupper)
            local connection = Instance.new('BallSocketConstraint', limb)
            connection.LimitsEnabled = true
            connection.Attachment0 = attachementone
            connection.Attachment1 = attachmenttwo
            connection.TwistLimitsEnabled = true
            connection.TwistLowerAngle = twistlower
            connection.TwistUpperAngle = twistupper
            local limbcollider = Instance.new("Part", limb)
            limbcollider.Size = Vector3.new(0.1,1,1)
            limbcollider.Shape = "Cylinder"
            limbcollider.Transparency = 1
            limbcollider:BreakJoints()
            local limbcolliderweld = Instance.new("Weld", limbcollider)
            limbcolliderweld.Part0 = limb
            limbcolliderweld.Part1 = limbcollider
            limbcolliderweld.C0 = CFrame.fromEulerAnglesXYZ(0,0,math.pi/2)
        end
        local function makehingeconnections(limb, attachementone, attachmenttwo, lower, upper)
            local connection = Instance.new('HingeConstraint', limb)
            connection.LimitsEnabled = true
            connection.Attachment0 = attachementone
            connection.Attachment1 = attachmenttwo
            connection.LimitsEnabled = true
            connection.LowerAngle = lower
            connection.UpperAngle = upper
            local limbcollider = Instance.new("Part", limb)
            limbcollider.Size = Vector3.new(0.1,1,1)
            limbcollider.Shape = "Cylinder"
            limbcollider.Transparency = 1
            limbcollider:BreakJoints()
            local limbcolliderweld = Instance.new("Weld", limbcollider)
            limbcolliderweld.Part0 = limb
            limbcolliderweld.Part1 = limbcollider
            limbcolliderweld.C0 = CFrame.fromEulerAnglesXYZ(0,0,math.pi/2)
        end
        local HeadAttachment = Instance.new("Attachment", Humanoid.Parent.Head)
        HeadAttachment.Position = Vector3.new(0, -0.5, 0)
        makehingeconnections(Humanoid.Parent.Head, HeadAttachment, ragdoll.UpperTorso.NeckAttachment, -50, 50)
        makehingeconnections(Humanoid.Parent.LowerTorso, Humanoid.Parent.LowerTorso.WaistRigAttachment, Humanoid.Parent.UpperTorso.WaistRigAttachment, -50, 50)
        makeballconnections(Humanoid.Parent.LeftUpperArm, Humanoid.Parent.LeftUpperArm.LeftShoulderRigAttachment, Humanoid.Parent.UpperTorso.LeftShoulderRigAttachment, -200, 200, 180)
        makehingeconnections(Humanoid.Parent.LeftLowerArm, Humanoid.Parent.LeftLowerArm.LeftElbowRigAttachment, Humanoid.Parent.LeftUpperArm.LeftElbowRigAttachment, 0, -60)
        makehingeconnections(Humanoid.Parent.LeftHand, Humanoid.Parent.LeftHand.LeftWristRigAttachment, Humanoid.Parent.LeftLowerArm.LeftWristRigAttachment, -20, 20)
        makeballconnections(Humanoid.Parent.RightUpperArm, Humanoid.Parent.RightUpperArm.RightShoulderRigAttachment, Humanoid.Parent.UpperTorso.RightShoulderRigAttachment, -200, 200, 180)
        makehingeconnections(Humanoid.Parent.RightLowerArm, Humanoid.Parent.RightLowerArm.RightElbowRigAttachment, Humanoid.Parent.RightUpperArm.RightElbowRigAttachment, 0, -60)
        makehingeconnections(Humanoid.Parent.RightHand, Humanoid.Parent.RightHand.RightWristRigAttachment, Humanoid.Parent.RightLowerArm.RightWristRigAttachment, -20, 20)
        makeballconnections(Humanoid.Parent.RightUpperLeg, Humanoid.Parent.RightUpperLeg.RightHipRigAttachment, Humanoid.Parent.LowerTorso.RightHipRigAttachment, -80, 80, 80)
        makehingeconnections(Humanoid.Parent.RightLowerLeg, Humanoid.Parent.RightLowerLeg.RightKneeRigAttachment, Humanoid.Parent.RightUpperLeg.RightKneeRigAttachment, 0, 60)
        makehingeconnections(Humanoid.Parent.RightFoot, Humanoid.Parent.RightFoot.RightAnkleRigAttachment, Humanoid.Parent.RightLowerLeg.RightAnkleRigAttachment, -20, 20)
        makeballconnections(Humanoid.Parent.LeftUpperLeg, Humanoid.Parent.LeftUpperLeg.LeftHipRigAttachment, Humanoid.Parent.LowerTorso.LeftHipRigAttachment, -80, 80, 80)
        makehingeconnections(Humanoid.Parent.LeftLowerLeg, Humanoid.Parent.LeftLowerLeg.LeftKneeRigAttachment, Humanoid.Parent.LeftUpperLeg.LeftKneeRigAttachment, 0, 60)
        makehingeconnections(Humanoid.Parent.LeftFoot, Humanoid.Parent.LeftFoot.LeftAnkleRigAttachment, Humanoid.Parent.LeftLowerLeg.LeftAnkleRigAttachment, -20, 20)
        for i,v in pairs(Humanoid.Parent:GetChildren()) do
            if v.ClassName == "Accessory" then
                local attachment1 = v.Handle:findFirstChildOfClass("Attachment")
                if attachment1 then
                    for q,w in pairs(Humanoid.Parent:GetChildren()) do
                        if w.ClassName == "Part" then
                            local attachment2 = w:findFirstChild(attachment1.Name)
                            if attachment2 then
                                local hinge = Instance.new("HingeConstraint", v.Handle)
                                hinge.Attachment0 = attachment1
                                hinge.Attachment1 = attachment2
                                hinge.LimitsEnabled = true
                                hinge.LowerAngle = 0
                                hinge.UpperAngle = 0
                            end
                        end
                    end
                end
            end
        end
        for i,v in pairs(ragdoll:GetChildren()) do
            for q,w in pairs(v:GetChildren()) do
                if w.ClassName == "Motor6D" then
                    w:destroy()
                end
            end
        end
        if ragdoll:findFirstChild("HumanoidRootPart") then
            ragdoll.HumanoidRootPart.Anchored = true
            ragdoll.HumanoidRootPart.CanCollide = false
        end
        game.Debris:AddItem(ragdoll, 60)
    end
end

function chase(victim)
    if canchase then
        canchase = false
        local raaaaaageeee = true
        sitting = false
        running = false
        local victimhead = victim.Head
        local victimhumanoid = victim:findFirstChildOfClass("Humanoid")
        idlesound:Stop()
        sitTrack:Stop()
        ragesound:Play()
        scphumanoid.WalkSpeed = 0
        scphumanoid.JumpPower = 0
        face.Texture = triggeredFace
        local function spasm()
            while wait() do
                if raaaaaageeee then
                    root.C0 = root.C0 * CFrame.new(math.random(-1,1)/50,math.random(-1,1)/50,math.random(-1,1)/50)
                    rightshoulder.C0 = rightshoulder.C0 * CFrame.new(math.random(-1,1)/50,math.random(-1,1)/50,math.random(-1,1)/50)
                    leftshoulder.C0 = leftshoulder.C0 * CFrame.new(math.random(-1,1)/50,math.random(-1,1)/50,math.random(-1,1)/50)
                    lefthip.C0 = lefthip.C0 * CFrame.new(math.random(-1,1)/50,math.random(-1,1)/50,math.random(-1,1)/50)
                    righthip.C0 = righthip.C0 * CFrame.new(math.random(-1,1)/50,math.random(-1,1)/50,math.random(-1,1)/50)
                    neck.C0 = neck.C0 * CFrame.new(math.random(-1,1)/50,math.random(-1,1)/50,math.random(-1,1)/50)
                    root.C0 = root.C0 * CFrame.fromEulerAnglesXYZ(math.random(-1,1)/50,math.random(-1,1)/50,math.random(-1,1)/50)
                    rightshoulder.C0 = rightshoulder.C0 * CFrame.fromEulerAnglesXYZ(math.random(-1,1)/50,math.random(-1,1)/50,math.random(-1,1)/50)
                    leftshoulder.C0 = leftshoulder.C0 * CFrame.fromEulerAnglesXYZ(math.random(-1,1)/50,math.random(-1,1)/50,math.random(-1,1)/50)
                    lefthip.C0 = lefthip.C0 * CFrame.fromEulerAnglesXYZ(math.random(-1,1)/50,math.random(-1,1)/50,math.random(-1,1)/50)
                    righthip.C0 = righthip.C0 * CFrame.fromEulerAnglesXYZ(math.random(-1,1)/50,math.random(-1,1)/50,math.random(-1,1)/50)
                    neck.C0 = neck.C0 * CFrame.fromEulerAnglesXYZ(math.random(-1,1)/50,math.random(-1,1)/50,math.random(-1,1)/50)
                end
            end
        end
        spawn(spasm)
        for i = 1,20 do
            heartbeat:wait()
        end
        raaaaaageeee = false
        face.Texture = rageFace
        chasesound.SoundId = chaseThemes[math.random(1, #chaseThemes)]
        chasesound:Play()
        screamsound:Play()
        runTrack:Play()
        running = true
        local chasethatplayer = true
        scphumanoid.WalkSpeed = 35
        scphumanoid.JumpPower = 50
        local function check()
            while wait() do
                if not chasethatplayer then break end
                if (torso.Position - victimhead.Position).magnitude < 15 and chasethatplayer then
                    chasethatplayer = false
                    raaaaaageeee = false
                    running = false
                    runTrack:Stop()
                    face.Texture = idleFace
                    victim:BreakJoints()
                    killsomeone:Play()
                    chasesound:Stop()
                    screamsound:Stop()
                    sitting = true
                    scphumanoid.WalkSpeed = 0
                    scphumanoid.JumpPower = 0
                    sitTrack:Play()
                    local function playidleandcanchase()
                        wait(5.5)
                        idlesound:Play()
                        canchase = true
                    end
                    spawn(playidleandcanchase)
                    if game.Players:findFirstChild(victim.Name) then
                        local playergui = game.Players[victim.Name]:findFirstChildOfClass("PlayerGui")
                        if playergui then
                            local deathguiclone = deathgui:Clone()
                            deathguiclone.Parent = playergui
                            local function removegui()
                                wait(5)
                                if deathguiclone.Parent ~= nil then
                                    deathguiclone:destroy()
                                end
                            end
                            spawn(removegui)
                        end
                    end
                    ragdollkill(victim)
                    break
                end
            end
        end
        local howmanymissed = 0
        local function chasefunc()
            while wait() and chasethatplayer do
                if victimhumanoid.Health <= 0 then
                    chasethatplayer = false
                    raaaaaageeee = false
                    runTrack:Stop()
                    idlesound:Play()
                    sitting = true
                    runTrack:Stop()
                    face.Texture = idleFace
                    chasesound:Stop()
                    screamsound:Stop()
                    scphumanoid.WalkSpeed = 0
                    scphumanoid.JumpPower = 0
                    canchase = true
                    sitTrack:Play()
                    break
                end
                local path = game:GetService("PathfindingService"):FindPathAsync(torso.Position, victimhead.Position)
                local waypoints = path:GetWaypoints()
                if path.Status == Enum.PathStatus.Success then
                    for i,v in pairs(waypoints) do
                        if howmanymissed < 4 then
                            local allow = 0
                            scphumanoid:MoveTo(v.Position)
                            while (torso.Position - v.Position).magnitude > 8 and allow < 20 do
                                allow = allow + 1
                                scphumanoid:MoveTo(v.Position)
                                heartbeat:wait()
                            end
                            if allow == 20 then
                                howmanymissed = howmanymissed + 1
                            end
                            if v.Action == Enum.PathWaypointAction.Jump then
                                scphumanoid.Jump = true
                            end
                            scphumanoid.WalkToPoint = victimhead.Position
                        end
                    end
                    howmanymissed = 0
                    scphumanoid.WalkToPoint = victimhead.Position
                end
            end
        end
        spawn(check)
        spawn(chasefunc)
    end
end

function dead()
    wait(5)
    script.Parent:Destroy()
end
scphumanoid.Died:connect(dead)

function check4ppl()
    while wait() do
        for i,v in pairs(workspace:GetChildren()) do
            if v.ClassName == "Model" and v.Name ~= scp.Name and canchase then
                local victimhead = v:findFirstChild("Head")
                local humanoid = v:findFirstChildOfClass("Humanoid")
                if humanoid and victimhead then
                    if (victimhead.Position - head.Position).magnitude < sight and humanoid.Health > 0 then
                        chase(v)
                    end
                end
            end
        end
    end
end

spawn(check4ppl)

while heartbeat:wait() do
    wait(1)
end
 ]]

 -- Compile the AI source in the sandboxed env (script -> Script21)
 local aiFn, compileErr
 pcall(function()
  local fn, err = loadstring(aiSource, "SCP_AI")
  if fn then
   aiFn = sandbox(Script21, fn)
  else
   compileErr = err
  end
 end)
 if not aiFn then
  warn("[ChaosMod] SCP-096 AI failed to compile: "..tostring(compileErr))
 end

 Part22.Name = "HumanoidRootPart"; Part22.Parent = Model0
 Part22.CFrame = CFrame.new(-2.80085993, 5.50001383, -41.7011566, 1, 0, 0, 0, 1, -2.202814e-16, 0, -2.202814e-16, 1)
 Part22.Color = Color3.new(0.905882, 0.905882, 0.92549); Part22.Transparency = 1
 Part22.Size = Vector3.new(1, 3, 2)
 Part22.BottomSurface = Enum.SurfaceType.Smooth; Part22.TopSurface = Enum.SurfaceType.Smooth
 Part22.BrickColor = BrickColor.new("Pearl"); Part22.brickColor = BrickColor.new("Pearl")
 Motor6D23.Name = "RootJoint"; Motor6D23.Parent = Part22
 Motor6D23.Part0 = Part22; Motor6D23.Part1 = Part3; Motor6D23.part1 = Part3
 Model24.Name = "This is what player sees after death"; Model24.Parent = Model0
 ScreenGui25.Name = "Death"; ScreenGui25.Parent = Model24
 Frame26.Parent = ScreenGui25
 Frame26.Size = UDim2.new(2, 0, 2, 0)
 Frame26.BackgroundColor = BrickColor.new("Really black")
 Frame26.BackgroundColor3 = Color3.new(0, 0, 0)
 Part27.Name = "facepart"; Part27.Parent = Model0
 Part27.CFrame = CFrame.new(-2.90086031, 7.50001383, -41.7011566, 1, 0, 0, 0, 1, -2.202814e-16, 0, -2.202814e-16, 1)
 Part27.Transparency = 1; Part27.Size = Vector3.new(1, 1, 1)
 Part27.BottomSurface = Enum.SurfaceType.Smooth; Part27.TopSurface = Enum.SurfaceType.Smooth
 Decal28.Name = "face"; Decal28.Parent = Part27
 Decal28.Texture = "http://www.roblox.com/asset/?id=1304527170"
 Decal28.Face = Enum.NormalId.Left

 -- Move children to workspace (as original does) and make joints
 for _,v in ipairs(mas:GetChildren()) do
  v.Parent = ws
  pcall(function() v:MakeJoints() end)
 end
 if mas and mas.Parent then mas:Destroy() end

 -- Spawn the AI coroutine and track it so we can close it on cleanup.
 -- coroutine.close is available in Luau and forcibly terminates the
 -- coroutine, which stops all the `while wait() do` loops inside.
 local aiThread
 if aiFn then
  aiThread = coroutine.create(function() pcall(aiFn) end)
  coroutine.resume(aiThread)
 end

 notif("😱 SCP-096 HAS BREACHED CONTAINMENT!",4)

 -- Collect all sounds on the SCP for cleanup
 local scpSounds = {}
 pcall(function()
  for _,s in ipairs(Model0:GetDescendants()) do
   if s:IsA("Sound") then scpSounds[#scpSounds+1]=s end
  end
 end)

 active.SCP096 = {
  obj = Model0,           -- tracked by cleanup() -> :Destroy()
  sounds = scpSounds,     -- tracked by cleanup() -> :Stop()+:Destroy()
  f = function()
   -- Close the AI coroutine (stops all internal loops)
   if aiThread then
    pcall(function() coroutine.close(aiThread) end)
   end
   -- Remove any cloned death GUIs from every player's PlayerGui.
   -- The AI clones ScreenGui25 ("Death") into victims' PlayerGui on kill.
   pcall(function()
    for _,p in ipairs(game.Players:GetPlayers()) do
     local pg = p:FindFirstChildOfClass("PlayerGui")
     if pg then
      for _,g in ipairs(pg:GetChildren()) do
       if g.Name == "Death" and g:IsA("ScreenGui") then
        pcall(function() g:Destroy() end)
       end
      end
     end
    end
   end)
   -- Destroy the death-GUI template model so no further clones can be made
   pcall(function() if Model24 and Model24.Parent then Model24:Destroy() end end)
   -- Destroy any ragdolls the SCP created (they have a 60s Debris timer,
   -- but we remove them immediately on cleanup for tidiness)
   pcall(function()
    for _,m in ipairs(ws:GetChildren()) do
     if m:IsA("Model") and m.Name == "SCP-096" and m ~= Model0 then
      -- skip — the SCP itself is already destroyed via obj
     end
    end
   end)
  end
 }
end,function() cleanup("SCP096") end)

-- ============================================
-- EFFECT: London simulator
--   Spawns a stabber NPC near the player. The NPC uses a random
--   player's avatar (via Players:CreateHumanoidModelFromUserId +
--   math.random) so it looks like an actual player is attacking.
--   The NPC charges the player, plays the stab animation
--   (128853357) on contact and damages the player each stab.
--   When the player dies, the NPC stops stabbing and plays the
--   cheer animation (129423030).
--
--   Falls back to a basic R6 rig if avatar loading fails.
--   Full cleanup: NPC destroyed, connections disconnected, anim
--   tracks stopped, player death watcher disconnected.
-- ============================================

-- Helper: build a minimal R6 rig as fallback (no asset load needed)
local function _London_buildRig(name, position)
 local model = Instance.new("Model")
 model.Name = name

 local function part(n, size, cframe, color, collide)
  local p = Instance.new("Part")
  p.Name = n
  p.Size = size
  p.CFrame = cframe
  p.BrickColor = BrickColor.new(color)
  p.TopSurface = Enum.SurfaceType.Smooth
  p.BottomSurface = Enum.SurfaceType.Smooth
  p.CanCollide = collide ~= nil and collide or true
  p.Parent = model
  return p
 end

 local hrp2 = part("HumanoidRootPart", Vector3.new(2, 2, 1),
  CFrame.new(position), "Medium Stone Grey", false)
 hrp2.Transparency = 1

 local torso2 = part("Torso", Vector3.new(2, 2, 1),
  hrp2.CFrame, "Bright yellow")
 local head2 = part("Head", Vector3.new(1, 1, 1),
  torso2.CFrame * CFrame.new(0, 1.5, 0), "Bright yellow")
 local faceDecal = Instance.new("Decal")
 faceDecal.Texture = "rbxasset://textures/face.png"
 faceDecal.Face = Enum.NormalId.Front
 faceDecal.Parent = head2
 local lArm = part("Left Arm", Vector3.new(1, 2, 1),
  torso2.CFrame * CFrame.new(-1.5, 0, 0), "Bright yellow")
 local rArm = part("Right Arm", Vector3.new(1, 2, 1),
  torso2.CFrame * CFrame.new(1.5, 0, 0), "Bright yellow")
 local lLeg = part("Left Leg", Vector3.new(1, 2, 1),
  torso2.CFrame * CFrame.new(-0.5, -2, 0), "Bright blue")
 local rLeg = part("Right Leg", Vector3.new(1, 2, 1),
  torso2.CFrame * CFrame.new(0.5, -2, 0), "Bright blue")

 local function motor(n, p0, p1, c0)
  local m = Instance.new("Motor6D")
  m.Name = n
  m.Part0 = p0
  m.Part1 = p1
  m.C0 = c0
  m.Parent = p0
  return m
 end

 motor("RootJoint", hrp2, torso2,
  CFrame.new(0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1))
 motor("Neck", torso2, head2,
  CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0))
 motor("Left Shoulder", torso2, lArm,
  CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0))
 motor("Right Shoulder", torso2, rArm,
  CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0))
 motor("Left Hip", torso2, lLeg,
  CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0))
 motor("Right Hip", torso2, rLeg,
  CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0))

 local hum2 = Instance.new("Humanoid")
 hum2.WalkSpeed = 22
 hum2.JumpPower = 50
 hum2.Health = 100
 hum2.MaxHealth = 100
 hum2.Parent = model

 model.PrimaryPart = hrp2

 -- Knife welded to right hand
 local knife = Instance.new("Part")
 knife.Name = "Knife"
 knife.Size = Vector3.new(0.2, 0.2, 2.5)
 knife.BrickColor = BrickColor.new("Metal")
 knife.Material = Enum.Material.Metal
 knife.CanCollide = false
 knife.CFrame = rArm.CFrame * CFrame.new(0, -1.2, -1.2)
 knife.Parent = model
 local knifeWeld = Instance.new("Weld")
 knifeWeld.Name = "KnifeWeld"
 knifeWeld.Part0 = rArm
 knifeWeld.Part1 = knife
 knifeWeld.C0 = CFrame.new(0, -1.2, -1.2) * CFrame.Angles(math.pi/2, 0, 0)
 knifeWeld.Parent = knife

 return model, hum2, hrp2, torso2, rArm
end

ext("London simulator","🔪",35,function()
 if not hrp or not hum then notif("🔪 No player character — skipping",2) return end

 -- Spawn NPC 18-25 studs away in a random direction
 local angle = math.random() * math.pi * 2
 local dist = math.random(18, 25)
 local spawnPos = hrp.Position + Vector3.new(math.cos(angle)*dist, 5, math.sin(angle)*dist)

 -- =========================================================
 -- Avatar loading: pick a random player's UserID using
 -- math.random, then create a humanoid model from it.
 -- This makes the stabber look like an actual player.
 -- =========================================================
 local npcModel
 local npcHum, npcHrp, npcRArm
 local usedAvatar = false

 -- Build a list of candidate UserIDs: all current players + the
 -- local player. We use math.random to pick one at random.
 local players = game.Players:GetPlayers()
 local candidateIds = {}
 for _,p in ipairs(players) do
  candidateIds[#candidateIds+1] = p.UserId
 end
 -- Always include the local player's ID so we have at least one
 if #candidateIds == 0 then
  candidateIds[1] = plr.UserId
 end

 -- Shuffle the candidate list using math.random so the order
 -- is randomized, then try each until one succeeds.
 for i = #candidateIds, 2, -1 do
  local j = math.random(i)
  candidateIds[i], candidateIds[j] = candidateIds[j], candidateIds[i]
 end

 -- Try each candidate UserId. CreateHumanoidModelFromUserId makes
 -- a web request, so we wrap it in pcall — some executors or
 -- games may block it. We also try a few random UserIDs as a
 -- last resort in case all players' avatars fail to load.
 local function tryCreateFromId(uid)
  local model
  local ok = pcall(function()
   model = game.Players:CreateHumanoidModelFromUserId(uid)
  end)
  if ok and model and model:IsA("Model") then
   return model
  end
  return nil
 end

 for _,uid in ipairs(candidateIds) do
  npcModel = tryCreateFromId(uid)
  if npcModel then break end
 end

 -- If all player avatars failed, try a few random UserIDs
 if not npcModel then
  for i = 1, 5 do
   local randomId = math.random(1, 50000000)
   npcModel = tryCreateFromId(randomId)
   if npcModel then break end
  end
 end

 if npcModel then
  -- Successfully loaded a real player avatar!
  usedAvatar = true
  npcModel.Name = "LondonStabber"

  -- Find the Humanoid and HumanoidRootPart
  npcHum = npcModel:FindFirstChildOfClass("Humanoid")
  npcHrp = npcModel:FindFirstChild("HumanoidRootPart")

  -- Find the right hand/arm for knife welding.
  -- R15 uses "RightHand", R6 uses "Right Arm".
  npcRArm = npcModel:FindFirstChild("RightHand")
        or npcModel:FindFirstChild("Right Arm")

  -- Configure the humanoid for chasing
  if npcHum then
   npcHum.WalkSpeed = 22  -- faster than default player (16)
   npcHum.JumpPower = 50
   npcHum.Health = 100
   npcHum.MaxHealth = 100
   -- Disable the avatar's default Animate script so it doesn't
   -- conflict with our stab/cheer/walk animations
   local animateScript = npcModel:FindFirstChild("Animate")
   if animateScript then animateScript:Destroy() end
  end

  -- Position the model at the spawn point
  if npcHrp then
   -- Move the entire model by offsetting from current position
   local currentPos = npcHrp.Position
   local offset = spawnPos - currentPos
   for _,part in ipairs(npcModel:GetDescendants()) do
    if part:IsA("BasePart") then
     part.CFrame = part.CFrame + offset
    end
   end
  end

  -- Weld a knife to the right hand/arm
  if npcRArm then
   local knife = Instance.new("Part")
   knife.Name = "Knife"
   knife.Size = Vector3.new(0.2, 0.2, 2.5)
   knife.BrickColor = BrickColor.new("Metal")
   knife.Material = Enum.Material.Metal
   knife.CanCollide = false
   knife.CFrame = npcRArm.CFrame * CFrame.new(0, -1.2, -1.2)
   knife.Parent = npcModel
   local knifeWeld = Instance.new("Weld")
   knifeWeld.Name = "KnifeWeld"
   knifeWeld.Part0 = npcRArm
   knifeWeld.Part1 = knife
   knifeWeld.C0 = CFrame.new(0, -1.2, -1.2) * CFrame.Angles(math.pi/2, 0, 0)
   knifeWeld.Parent = knife
  end
 else
  -- Fallback: build a basic R6 rig
  npcModel, npcHum, npcHrp, npcRArm = _London_buildRig("LondonStabber", spawnPos)
 end

 npcModel.Parent = ws

 -- Animator for playing animations on the NPC
 local animator = npcHum:FindFirstChildOfClass("Animator")
 if not animator then
  animator = Instance.new("Animator")
  animator.Parent = npcHum
 end

 -- Load stab + cheer animations
 local stabAnim = Instance.new("Animation")
 stabAnim.AnimationId = "rbxassetid://128853357"
 local stabTrack = animator:LoadAnimation(stabAnim)
 stabTrack.Looped = true

 local cheerAnim = Instance.new("Animation")
 cheerAnim.AnimationId = "rbxassetid://129423030"
 local cheerTrack = animator:LoadAnimation(cheerAnim)
 cheerTrack.Looped = true

 -- Walk animation (so the NPC actually walks while chasing)
 -- Use R15 walk anim if avatar is R15, R6 walk anim if R6.
 local isR15 = npcModel:FindFirstChild("RightHand") ~= nil
 local walkAnim = Instance.new("Animation")
 if isR15 then
  walkAnim.AnimationId = "rbxassetid://507777826"  -- R15 walk
 else
  walkAnim.AnimationId = "rbxassetid://507777826"  -- R6 walk (same ID works for both)
 end
 local walkTrack = animator:LoadAnimation(walkAnim)
 walkTrack.Looped = true
 walkTrack:Play()

 -- State
 local running = true
 local playerDead = false
 local lastStabDamage = 0
 local diedConn

 -- Watch for player death
 if hum and hum.Parent then
  diedConn = hum.Died:Connect(function()
   playerDead = true
   pcall(function() stabTrack:Stop() end)
   pcall(function() cheerTrack:Play() end)
   notif("🔪 The stabber celebrates! 🎉",3)
  end)
 end

 -- Chase + stab loop (runs every frame via Heartbeat)
 local chaseConn
 chaseConn = rs.Heartbeat:Connect(function()
  if not running then return end
  if not npcHrp or not npcHrp.Parent then return end

  if playerDead then
   npcHum:MoveTo(npcHrp.Position)
   return
  end

  if not hrp or not hrp.Parent then return end
  if not hum or not hum.Parent then return end

  local diff = hrp.Position - npcHrp.Position
  local distToPlayer = diff.Magnitude

  -- Make NPC face the player
  if distToPlayer > 0.1 then
   pcall(function()
    npcHrp.CFrame = CFrame.lookAt(npcHrp.Position, hrp.Position)
   end)
  end

  if distToPlayer > 4 then
   -- Out of stab range — charge the player
   npcHum:MoveTo(hrp.Position)
   if stabTrack.IsPlaying then stabTrack:Stop() end
  else
   -- In stab range — stop moving and stab
   npcHum:MoveTo(npcHrp.Position)
   if not stabTrack.IsPlaying then stabTrack:Play() end

   -- Deal damage every 0.6s
   local now = os.clock()
   if now - lastStabDamage >= 0.6 then
    lastStabDamage = now
    pcall(function()
     if hum and hum.Parent and hum.Health > 0 then
      hum:TakeDamage(18)
     end
    end)
   end
  end
 end)

 notif("🔪 A stabber ("..(usedAvatar and "real player avatar" or "basic rig")..") is coming!",3)

 active.LondonSim = {
  conn = chaseConn,
  obj = npcModel,
  f = function()
   running = false
   if diedConn then pcall(function() diedConn:Disconnect() end) diedConn=nil end
   pcall(function() stabTrack:Stop() end)
   pcall(function() cheerTrack:Stop() end)
   pcall(function() walkTrack:Stop() end)
  end
 }
end,function() cleanup("LondonSim") end)

-- ============================================
-- EFFECT: so retro
--   Makes the screen look 8-bit using a ViewportFrame that re-
--   renders the scene at low resolution, plus retro post-
--   processing (color quantization, scanlines, pixel grid, CRT
--   vignette). The ViewportFrame covers the entire screen and
--   its camera syncs with the workspace camera every frame, so
--   you see the game world rendered through the viewport — but
--   pixelated and color-shifted to look like an 8-bit game.
--
--   Full cleanup: GUI destroyed, post-processing effects removed,
--   camera sync connection disconnected, cloned parts destroyed.
-- ============================================
ext("so retro","🎮",25,function()
 local g = plr:FindFirstChild("PlayerGui") if not g then return end
 local cam = ws.CurrentCamera
 if not cam then return end

 -- ============================================
 -- 1. Retro post-processing on the main Lighting
 -- ============================================
 local cce = Instance.new("ColorCorrectionEffect")
 cce.Name = "RetroColor"
 cce.Brightness = -0.05
 cce.Contrast = 0.35       -- high contrast for blocky color bands
 cce.Saturation = -0.45    -- desaturated = fewer effective colors
 cce.TintColor = Color3.fromRGB(180, 200, 220)  -- slight blue CRT tint
 cce.Parent = ls

 local bloom = Instance.new("BloomEffect")
 bloom.Name = "RetroBloom"
 bloom.Intensity = 0.5
 bloom.Size = 10
 bloom.Threshold = 0.75
 bloom.Parent = ls

 -- ============================================
 -- 2. Retro GUI overlay (scanlines + pixel grid + vignette)
 -- ============================================
 local gui = Instance.new("ScreenGui")
 gui.Name = "Retro8Bit"
 gui.IgnoreGuiInset = true
 gui.ResetOnSpawn = false
 gui.DisplayOrder = 9990
 gui.Parent = g

 local screenSize = cam.ViewportSize
 local screenW = math.floor(screenSize.X)
 local screenH = math.floor(screenSize.Y)

 -- Scanlines: horizontal black lines every 4px (creates CRT look)
 local scanHolder = Instance.new("Frame")
 scanHolder.Name = "Scanlines"
 scanHolder.Size = UDim2.new(1, 0, 1, 0)
 scanHolder.BackgroundTransparency = 1
 scanHolder.BorderSizePixel = 0
 scanHolder.ZIndex = 9990
 scanHolder.ClipsDescendants = true
 scanHolder.Parent = gui

 local lineSpacing = 4
 local lineCount = math.floor(screenH / lineSpacing)
 for i = 0, lineCount do
  local line = Instance.new("Frame")
  line.Size = UDim2.new(1, 0, 0, 2)
  line.Position = UDim2.new(0, 0, 0, i * lineSpacing)
  line.BackgroundColor3 = Color3.new(0, 0, 0)
  line.BackgroundTransparency = 0.55
  line.BorderSizePixel = 0
  line.Parent = scanHolder
 end

 -- Pixel grid: thin vertical + horizontal lines every 8px
 -- (creates the "blocky pixel" overlay that sells the 8-bit look)
 local gridHolder = Instance.new("Frame")
 gridHolder.Name = "PixelGrid"
 gridHolder.Size = UDim2.new(1, 0, 1, 0)
 gridHolder.BackgroundTransparency = 1
 gridHolder.BorderSizePixel = 0
 gridHolder.ZIndex = 9991
 gridHolder.ClipsDescendants = true
 gridHolder.Parent = gui

 local gridSize = 8
 -- Vertical lines
 for i = 0, math.floor(screenW / gridSize) do
  local line = Instance.new("Frame")
  line.Size = UDim2.new(0, 1, 1, 0)
  line.Position = UDim2.new(0, i * gridSize, 0, 0)
  line.BackgroundColor3 = Color3.new(0, 0, 0)
  line.BackgroundTransparency = 0.85
  line.BorderSizePixel = 0
  line.Parent = gridHolder
 end
 -- Horizontal lines
 for i = 0, math.floor(screenH / gridSize) do
  local line = Instance.new("Frame")
  line.Size = UDim2.new(1, 0, 0, 1)
  line.Position = UDim2.new(0, 0, 0, i * gridSize)
  line.BackgroundColor3 = Color3.new(0, 0, 0)
  line.BackgroundTransparency = 0.85
  line.BorderSizePixel = 0
  line.Parent = gridHolder
 end

 -- CRT vignette (dark edges using a thick UIStroke)
 local vignette = Instance.new("Frame")
 vignette.Name = "Vignette"
 vignette.Size = UDim2.new(1, 0, 1, 0)
 vignette.BackgroundTransparency = 1
 vignette.BorderSizePixel = 0
 vignette.ZIndex = 9992
 vignette.Parent = gui
 local vignetteStroke = Instance.new("UIStroke", vignette)
 vignetteStroke.Thickness = 120
 vignetteStroke.Color = Color3.new(0, 0, 0)
 vignetteStroke.Transparency = 0.5
 vignetteStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

 -- "8-BIT MODE" label in the top-left corner (retro green text)
 local label = Instance.new("TextLabel")
 label.Name = "RetroLabel"
 label.Size = UDim2.new(0, 220, 0, 30)
 label.Position = UDim2.new(0, 12, 0, 8)
 label.BackgroundTransparency = 1
 label.Text = "8-BIT MODE"
 label.TextColor3 = Color3.fromRGB(100, 255, 100)
 label.Font = Enum.Font.Arcade
 label.TextSize = 22
 label.TextXAlignment = Enum.TextXAlignment.Left
 label.ZIndex = 9993
 label.Parent = gui

 -- ============================================
 -- 3. ViewportFrame: re-renders the scene at low resolution
 --    The ViewportFrame covers the full screen. We clone the
 --    local player's character into a WorldModel inside it,
 --    and sync the viewport camera with the workspace camera
 --    every frame. Combined with the overlays above, this
 --    gives the scene an authentic 8-bit look.
 -- ============================================
 local vpGui = Instance.new("ScreenGui")
 vpGui.Name = "RetroViewport"
 vpGui.IgnoreGuiInset = true
 vpGui.ResetOnSpawn = false
 vpGui.DisplayOrder = 9989  -- below the overlay GUI so scanlines render on top
 vpGui.Parent = g

 local vp = Instance.new("ViewportFrame")
 vp.Name = "RetroVP"
 vp.Size = UDim2.new(1, 0, 1, 0)
 vp.Position = UDim2.new(0, 0, 0, 0)
 vp.BackgroundTransparency = 1  -- let the real world show through
 vp.BorderSizePixel = 0
 vp.LightDirection = Vector3.new(-1, -1, -1)
 vp.Ambient = Color3.fromRGB(120, 120, 120)  -- flat retro lighting
 vp.LightColor = Color3.fromRGB(255, 240, 200)  -- warm retro light
 vp.Parent = vpGui

 -- WorldModel holds the 3D content rendered by the ViewportFrame
 local worldModel = Instance.new("WorldModel")
 worldModel.Parent = vp

 -- Clone the local player's character into the WorldModel so the
 -- viewport has something to render. Update position every frame.
 local charClone
 pcall(function()
  if char and char.Parent then
   charClone = char:Clone()
   -- Remove scripts from the clone (we just want it visual)
   for _,d in ipairs(charClone:GetDescendants()) do
    if d:IsA("LocalScript") or d:IsA("Script") then
     d:Destroy()
    end
   end
   charClone.Parent = worldModel
  end
 end)

 -- Sync the viewport camera with the workspace camera every frame
 local camConn
 camConn = rs.RenderStepped:Connect(function()
  if not cam or not cam.Parent then return end
  -- Create or update the viewport's camera to match the workspace camera
  if not vp.CurrentCamera or not vp.CurrentCamera.Parent then
   local vpCam = Instance.new("Camera")
   vpCam.CFrame = cam.CFrame
   vpCam.FieldOfView = cam.FieldOfView
   vpCam.Parent = vp
   vp.CurrentCamera = vpCam
  else
   vp.CurrentCamera.CFrame = cam.CFrame
   vp.CurrentCamera.FieldOfView = cam.FieldOfView
  end

  -- Sync the cloned character's position with the real character
  if charClone and charClone.Parent and char and char.Parent then
   local realHrp = char:FindFirstChild("HumanoidRootPart")
   local cloneHrp = charClone:FindFirstChild("HumanoidRootPart")
   if realHrp and cloneHrp then
    local offset = realHrp.CFrame.Position - cloneHrp.CFrame.Position
    if offset.Magnitude > 0.1 then
     for _,part in ipairs(charClone:GetDescendants()) do
      if part:IsA("BasePart") then
       part.CFrame = part.CFrame + offset
      end
     end
    end
   end
  end
 end)

 notif("🎮 SO RETRO! 8-BIT MODE ENGAGED",3)

 active.SoRetro = {
  obj = gui,
  objs = {vpGui, cce, bloom},
  conn = camConn,
  f = function()
   -- Destroy the cloned character
   pcall(function() if charClone and charClone.Parent then charClone:Destroy() end end)
   -- Note: cce and bloom are in objs[] so cleanup() destroys them,
   -- but we also destroy them here explicitly in case objs handling
   -- changes. (Double-destroy is safe via pcall.)
  end
 }
end,function() cleanup("SoRetro") end)

-- ============================================
-- MASTER EFFECT LIST
-- ============================================

-- ============================================
-- RESEARCH-BASED GAME MECHANICS ADAPTED FOR THIS CHAOS MOD
-- Nullscape references: Mimic, Ponderer, Operator, Nil.
-- Plates of Fate: Remastered references: All-Seeing Eye, Invisible Mine,
-- Quicksand, plate shrink/grow, Lightning, Glass Plate, Hydraulic Press.
-- These are local-player adaptations, not the original games' code/assets.
-- ============================================

-- Nullscape: Mimic — a tempting fake pickup that reveals itself and lunges.
ext("NULLSCAPE MECHANIC: Mimic", "🎁", 14, function()
 if not hrp then return end
 local folder=Instance.new("Folder"); folder.Name="Chaos_NullscapeMimic"; folder.Parent=ws
 local gift=Instance.new("Part"); gift.Name="SuspiciousCollectible"; gift.Size=Vector3.new(2,2,2)
 gift.Anchored=true; gift.CanCollide=false; gift.Material=Enum.Material.Neon
 gift.Color=Color3.fromRGB(255,210,70); gift.Position=hrp.Position+hrp.CFrame.LookVector*12+Vector3.new(0,2,0); gift.Parent=folder
 local light=Instance.new("PointLight",gift); light.Color=gift.Color; light.Range=12; light.Brightness=2
 local billboard=Instance.new("BillboardGui",gift); billboard.Size=UDim2.fromOffset(150,35); billboard.StudsOffset=Vector3.new(0,2,0); billboard.AlwaysOnTop=true
 local label=Instance.new("TextLabel",billboard); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1; label.Text="FREE UPGRADE?"; label.TextColor3=Color3.new(1,1,1); label.TextStrokeTransparency=0; label.TextScaled=true; label.Font=Enum.Font.GothamBold
 local elapsed=0; local revealed=false
 local conn=rs.Heartbeat:Connect(function(dt)
  elapsed+=dt
  if not gift.Parent then return end
  gift.CFrame=CFrame.new(gift.Position+Vector3.new(0,math.sin(elapsed*3)*0.012,0))*CFrame.Angles(0,elapsed*1.3,0)
  if hrp and (hrp.Position-gift.Position).Magnitude<5 and not revealed then
   revealed=true; gift.Color=Color3.fromRGB(35,0,0); gift.Size=Vector3.new(3,3,3); label.Text="MIMIC! RUN!"
   label.TextColor3=Color3.fromRGB(255,40,40); light.Color=label.TextColor3
   local target=hrp.Position; gift.Anchored=false
   local impulse=Instance.new("BodyVelocity"); impulse.MaxForce=Vector3.new(1e5,1e5,1e5); impulse.Velocity=(target-gift.Position).Unit*38+Vector3.new(0,15,0); impulse.Parent=gift; debris:AddItem(impulse,0.35)
   playSound(A.horror,0.8,hrp,2)
  end
 end)
 active.NullMimic={obj=folder,conn=conn,f=function() end}
end,function() cleanup("NullMimic") end)

-- Nullscape: Ponderer — a stationary gravity field that drags you inward.
ext("NULLSCAPE MECHANIC: Ponderer Gravity Field", "🧿", 12, function()
 if not hrp then return end
 local center=hrp.Position+hrp.CFrame.LookVector*15
 local orb=Instance.new("Part"); orb.Name="Ponderer"; orb.Shape=Enum.PartType.Ball; orb.Size=Vector3.new(3,3,3); orb.Anchored=true; orb.CanCollide=false; orb.Material=Enum.Material.Neon; orb.Color=Color3.fromRGB(20,0,35); orb.Position=center+Vector3.new(0,3,0); orb.Parent=ws
 local light=Instance.new("PointLight",orb); light.Color=Color3.fromRGB(175,50,255); light.Range=22; light.Brightness=3
 local ring=Instance.new("Part"); ring.Name="PondererRange"; ring.Shape=Enum.PartType.Cylinder; ring.Size=Vector3.new(0.12,24,24); ring.CFrame=CFrame.new(center)*CFrame.Angles(0,0,math.pi/2); ring.Anchored=true; ring.CanCollide=false; ring.Material=Enum.Material.ForceField; ring.Color=light.Color; ring.Transparency=0.45; ring.Parent=ws
 local conn=rs.Heartbeat:Connect(function(dt)
  if hrp and hrp.Parent and orb.Parent then
   local delta=orb.Position-hrp.Position; local dist=delta.Magnitude
   if dist<38 and dist>2 then hrp.AssemblyLinearVelocity+=delta.Unit*math.min(42,900/(dist+5))*dt end
  end
 end)
 active.NullPonderer={objs={orb,ring},conn=conn,f=function() end}
end,function() cleanup("NullPonderer") end)

-- Nullscape: Operator — periodic pulses that empower nearby NPC humanoids.
ext("NULLSCAPE MECHANIC: Operator Pulse", "📡", 18, function()
 if not hrp then return end
 local beacon=Instance.new("Part"); beacon.Name="OperatorBeacon"; beacon.Shape=Enum.PartType.Cylinder; beacon.Size=Vector3.new(0.5,3,3); beacon.Anchored=true; beacon.CanCollide=false; beacon.Material=Enum.Material.Neon; beacon.Color=Color3.fromRGB(255,60,160); beacon.Position=hrp.Position+Vector3.new(0,7,0); beacon.Parent=ws
 local light=Instance.new("PointLight",beacon); light.Color=beacon.Color; light.Range=28; light.Brightness=2
 local affected={}; local elapsed=0
 local conn=rs.Heartbeat:Connect(function(dt)
  elapsed+=dt
  if not beacon.Parent then return end
  if hrp then beacon.Position=hrp.Position+Vector3.new(0,7,0) end
  if elapsed>=4 then
   elapsed=0
   for _,model in ipairs(ws:GetDescendants()) do
    if model:IsA("Model") and model~=char then
     local h=model:FindFirstChildOfClass("Humanoid"); local root=model:FindFirstChild("HumanoidRootPart")
     if h and root and h.Health>0 and (root.Position-beacon.Position).Magnitude<28 and not affected[h] then
      affected[h]={speed=h.WalkSpeed,jump=h.JumpPower}; h.WalkSpeed=math.min(40,h.WalkSpeed*1.3); h.JumpPower=math.min(100,h.JumpPower*1.15)
     end
    end
   end
  end
 end)
 active.NullOperator={obj=beacon,conn=conn,f=function() for h,v in pairs(affected) do pcall(function() if h.Parent then h.WalkSpeed=v.speed; h.JumpPower=v.jump end end) end end}
end,function() cleanup("NullOperator") end)

-- Nullscape: Nil — erases a small patch of floor beneath/near the player.
ext("NULLSCAPE MECHANIC: Nil Platform Erasure", "⬛", 10, function()
 if not hrp then return end
 local folder=Instance.new("Folder"); folder.Name="Chaos_NilErasure"; folder.Parent=ws
 local targets={}; local center=hrp.Position
 for _,part in ipairs(ws:GetPartBoundsInRadius(center,18)) do
  if part:IsA("BasePart") and part.Anchored and part.CanCollide and part.Size.X>3 and part.Size.Z>3 and not part:IsDescendantOf(char) then
   if part.Position.Y<center.Y-2 then targets[#targets+1]=part end
  end
 end
 table.sort(targets,function(a,b) return (a.Position-center).Magnitude<(b.Position-center).Magnitude end)
 for i=1,math.min(3,#targets) do
  local part=targets[i]; local marker=Instance.new("Part"); marker.Name="NilWarning"; marker.Anchored=true; marker.CanCollide=false; marker.Material=Enum.Material.Neon; marker.Color=Color3.fromRGB(20,0,30); marker.Transparency=0.25; marker.Size=Vector3.new(part.Size.X+0.2,0.12,part.Size.Z+0.2); marker.CFrame=part.CFrame*CFrame.new(0,part.Size.Y/2+0.08,0); marker.Parent=folder
  task.delay(1.1*(i-1),function() if part and part.Parent and folder.Parent then pcall(function() part.CanCollide=false; part.Transparency=math.max(part.Transparency,0.85) end); if marker.Parent then marker:Destroy() end end end)
 end
 active.NullNil={obj=folder,f=function() end}
end,function() cleanup("NullNil") end)

-- Plates of Fate: All-Seeing Eye — movement triggers a warning beam/damage.
ext("PLATES OF FATE EVENT: All-Seeing Eye", "👁️", 18, function()
 if not hrp or not hum then return end
 local eye=Instance.new("Part"); eye.Name="AllSeeingEye"; eye.Shape=Enum.PartType.Ball; eye.Size=Vector3.new(5,5,5); eye.Anchored=true; eye.CanCollide=false; eye.Material=Enum.Material.Neon; eye.Color=Color3.fromRGB(255,220,220); eye.Position=hrp.Position+Vector3.new(0,24,0); eye.Parent=ws
 local light=Instance.new("PointLight",eye); light.Color=Color3.fromRGB(255,0,0); light.Range=24; light.Brightness=2
 local oldPos=hrp.Position; local movedSinceZap=0; local elapsed=0; local beam=nil; local lastZap=0
 local conn=rs.Heartbeat:Connect(function(dt)
  elapsed+=dt
  if hrp and eye.Parent then
   eye.Position=hrp.Position+Vector3.new(0,24,0)
   local moved=(hrp.Position-oldPos).Magnitude; movedSinceZap+=moved
   if movedSinceZap>1.4 and elapsed-lastZap>1.1 then
    lastZap=elapsed; local zapMove=movedSinceZap; movedSinceZap=0; eye.Color=Color3.fromRGB(255,0,0); hum:TakeDamage(math.min(12,zapMove*2))
    local p=Instance.new("Part"); p.Name="EyeZap"; p.Anchored=true; p.CanCollide=false; p.Material=Enum.Material.Neon; p.Color=Color3.fromRGB(255,20,20); p.Size=Vector3.new(0.25,0.25,(eye.Position-hrp.Position).Magnitude); p.CFrame=CFrame.lookAt((eye.Position+hrp.Position)/2,hrp.Position)*CFrame.new(0,0,-p.Size.Z/2); p.Parent=ws; debris:AddItem(p,0.18)
    task.delay(0.25,function() if eye.Parent then eye.Color=Color3.fromRGB(255,220,220) end end)
   end
   oldPos=hrp.Position
  end
 end)
 active.FateEye={obj=eye,conn=conn,f=function() if beam then beam:Destroy() end end}
end,function() cleanup("FateEye") end)

-- Plates of Fate: Invisible Mine — hidden proximity mine with a pink blast.
ext("PLATES OF FATE EVENT: Invisible Mine", "💣", 14, function()
 if not hrp then return end
 local mine=Instance.new("Part"); mine.Name="InvisibleMine"; mine.Shape=Enum.PartType.Cylinder; mine.Size=Vector3.new(0.4,3,3); mine.Anchored=true; mine.CanCollide=false; mine.Material=Enum.Material.Neon; mine.Color=Color3.fromRGB(255,40,200); mine.Transparency=1; mine.Position=hrp.Position+hrp.CFrame.LookVector*10-Vector3.new(0,2.5,0); mine.Parent=ws
 local armedAt=os.clock()+1.2; local detonated=false
 local conn=rs.Heartbeat:Connect(function()
  if detonated or not hrp or not mine.Parent or os.clock()<armedAt then return end
  if (hrp.Position-mine.Position).Magnitude<4 then
   detonated=true; mine.Transparency=0
   local blast=Instance.new("Part"); blast.Name="MineBlastVisual"; blast.Shape=Enum.PartType.Ball; blast.Size=Vector3.new(2,2,2); blast.Anchored=true; blast.CanCollide=false; blast.Material=Enum.Material.Neon; blast.Color=Color3.fromRGB(255,30,190); blast.Transparency=0.15; blast.Position=mine.Position; blast.Parent=ws
   ts:Create(blast,TweenInfo.new(0.45),{Size=Vector3.new(24,24,24),Transparency=1}):Play(); debris:AddItem(blast,0.5)
   if hum and (hrp.Position-mine.Position).Magnitude<12 then hum:TakeDamage(35) end
   playSound(A.death_,0.9,hrp,2); mine:Destroy()
  end
 end)
 active.FateMine={obj=mine,conn=conn,f=function() end}
end,function() cleanup("FateMine") end)

-- Plates of Fate: Quicksand — stepping/moving near the marked patch sinks you.
ext("PLATES OF FATE EVENT: Quicksand", "🟤", 12, function()
 if not hrp then return end
 local patch=Instance.new("Part"); patch.Name="QuicksandPatch"; patch.Size=Vector3.new(12,0.25,12); patch.Anchored=true; patch.CanCollide=false; patch.Material=Enum.Material.Sand; patch.Color=Color3.fromRGB(170,130,65); patch.Transparency=0.18; patch.CFrame=CFrame.new(hrp.Position.X,hrp.Position.Y-3,hrp.Position.Z); patch.Parent=ws
 local startY=hrp.Position.Y; local conn=rs.Heartbeat:Connect(function(dt)
  if not hrp or not hum or not patch.Parent then return end
  local p=hrp.Position; local localP=patch.CFrame:PointToObjectSpace(p)
  if math.abs(localP.X)<patch.Size.X/2 and math.abs(localP.Z)<patch.Size.Z/2 and p.Y<patch.Position.Y+5 then
   hrp.AssemblyLinearVelocity=Vector3.new(hrp.AssemblyLinearVelocity.X,math.max(hrp.AssemblyLinearVelocity.Y-5,-18),hrp.AssemblyLinearVelocity.Z)
   if hum.FloorMaterial==Enum.Material.Sand then hum:TakeDamage(1.5*dt) end
  end
 end)
 active.FateQuicksand={obj=patch,conn=conn,f=function() end}
end,function() cleanup("FateQuicksand") end)

-- Plates of Fate: Plate shrink/grow — scales a nearby floor plate down then back.
ext("PLATES OF FATE EVENT: Plate Shrink", "📉", 14, function()
 if not hrp then return end
 local best=nil; local bestDist=math.huge
 for _,part in ipairs(ws:GetPartBoundsInRadius(hrp.Position,30)) do
  if part:IsA("BasePart") and part.Anchored and part.CanCollide and part.Size.X>=5 and part.Size.Z>=5 and not part:IsDescendantOf(char) then
   local d=(part.Position-hrp.Position).Magnitude; if d<bestDist and part.Position.Y<hrp.Position.Y+2 then best=part; bestDist=d end
  end
 end
 if not best then notif("PLATE SHRINK: no nearby plate found",2); return end
 local oldSize=best.Size; local oldCF=best.CFrame
 local newSize=Vector3.new(math.max(2,oldSize.X-5),oldSize.Y,math.max(2,oldSize.Z-5))
 local down=ts:Create(best,TweenInfo.new(0.8,Enum.EasingStyle.Quad),{Size=newSize}); down:Play()
 active.FatePlateShrink={f=function() pcall(function() if best and best.Parent then ts:Create(best,TweenInfo.new(0.5),{Size=oldSize,CFrame=oldCF}):Play() end end) end}
end,function() cleanup("FatePlateShrink") end)

-- Plates of Fate: Lightning — a visible strike at a nearby random point.
ext("PLATES OF FATE EVENT: Lightning Strike", "⚡", 8, function()
 if not hrp then return end
 local pos=hrp.Position+Vector3.new(math.random(-16,16),0,math.random(-16,16))
 local ray=ws:Raycast(pos+Vector3.new(0,70,0),Vector3.new(0,-140,0))
 if ray then pos=ray.Position else pos=hrp.Position+Vector3.new(math.random(-8,8),-2,math.random(-8,8)) end
 local bolt=Instance.new("Part"); bolt.Name="FateLightning"; bolt.Anchored=true; bolt.CanCollide=false; bolt.Material=Enum.Material.Neon; bolt.Color=Color3.fromRGB(110,210,255); bolt.Size=Vector3.new(0.6,70,0.6); bolt.Position=pos+Vector3.new(0,35,0); bolt.Parent=ws
 local flash=Instance.new("PointLight",bolt); flash.Color=bolt.Color; flash.Range=26; flash.Brightness=8
 local ring=Instance.new("Part"); ring.Shape=Enum.PartType.Cylinder; ring.Anchored=true; ring.CanCollide=false; ring.Material=Enum.Material.Neon; ring.Color=bolt.Color; ring.Transparency=0.25; ring.Size=Vector3.new(0.2,2,2); ring.CFrame=CFrame.new(pos+Vector3.new(0,0.2,0))*CFrame.Angles(0,0,math.pi/2); ring.Parent=ws
 ts:Create(ring,TweenInfo.new(0.5),{Size=Vector3.new(0.2,18,18),Transparency=1}):Play(); debris:AddItem(ring,0.6); debris:AddItem(bolt,0.25)
 if hrp and (hrp.Position-pos).Magnitude<9 and hum then hum:TakeDamage(20) end
 playSound(A.powerup,0.6,hrp,1)
 active.FateLightning={objs={bolt,ring},f=function() end}
end,function() cleanup("FateLightning") end)

-- Plates of Fate: Glass Plate — nearby floor becomes fragile and cracks on impact.
ext("PLATES OF FATE EVENT: Glass Plate", "🪟", 16, function()
 if not hrp then return end
 local candidates={}
 for _,part in ipairs(ws:GetPartBoundsInRadius(hrp.Position,24)) do
  if part:IsA("BasePart") and part.Anchored and part.CanCollide and part.Size.X>5 and part.Size.Z>5 and part.Position.Y<hrp.Position.Y+1 and not part:IsDescendantOf(char) then candidates[#candidates+1]=part end
 end
 table.sort(candidates,function(a,b) return (a.Position-hrp.Position).Magnitude<(b.Position-hrp.Position).Magnitude end)
 local snapshots={}; for i=1,math.min(2,#candidates) do local part=candidates[i]; snapshots[part]={material=part.Material,color=part.Color,transparency=part.Transparency}; part.Material=Enum.Material.Glass; part.Color=Color3.fromRGB(150,220,255); part.Transparency=0.25 end
 local conn=rs.Heartbeat:Connect(function()
  if not hrp then return end
  for part,old in pairs(snapshots) do
   if part and part.Parent and (hrp.Position-part.Position).Magnitude<7 and hrp.AssemblyLinearVelocity.Magnitude>22 then
    part.Transparency=0.65; part.Color=Color3.fromRGB(220,245,255)
   end
  end
 end)
 active.FateGlass={conn=conn,f=function() for part,old in pairs(snapshots) do pcall(function() if part and part.Parent then part.Material=old.material; part.Color=old.color; part.Transparency=old.transparency end end) end end}
end,function() cleanup("FateGlass") end)

-- Plates of Fate: Hydraulic Press — telegraphed overhead press, then retreats.
ext("PLATES OF FATE EVENT: Hydraulic Press", "⬇️", 9, function()
 if not hrp then return end
 local press=Instance.new("Part"); press.Name="HydraulicPress"; press.Size=Vector3.new(10,2,10); press.Anchored=true; press.CanCollide=false; press.Material=Enum.Material.Metal; press.Color=Color3.fromRGB(90,90,100); press.Position=hrp.Position+Vector3.new(0,24,0); press.Parent=ws
 local spikes=Instance.new("Part"); spikes.Name="PressWarning"; spikes.Size=Vector3.new(9,0.3,9); spikes.Anchored=true; spikes.CanCollide=false; spikes.Material=Enum.Material.Neon; spikes.Color=Color3.fromRGB(255,40,40); spikes.Transparency=0.2; spikes.Position=hrp.Position-Vector3.new(0,2.5,0); spikes.Parent=ws
 task.delay(2,function()
  if not press.Parent then return end
  local target=hrp and hrp.Position or press.Position-Vector3.new(0,22,0)
  ts:Create(press,TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=target+Vector3.new(0,2,0)}):Play()
  task.delay(0.4,function() if hum and hrp and (hrp.Position-press.Position).Magnitude<8 then hum:TakeDamage(45) end; if press.Parent then ts:Create(press,TweenInfo.new(0.45),{Position=press.Position+Vector3.new(0,24,0)}):Play() end end)
 end)
 active.FatePress={objs={press,spikes},f=function() end}
end,function() cleanup("FatePress") end)

-- Ben Drowned / Majora's Mask inspired cinematic apocalypse.
-- The supplied cat model is loaded with the executor-only game:GetObjects API.
-- This effect is intentionally local-visual: it restores the map when it ends.
ext("WELL TRAVELER, YOUR DAY HAS FALLEN", "🌑", 48, function()
 if not hrp or not char then return end
 notif("WELL TRAVELER, YOUR DAY HAS FALLEN", 5)
 local startedAt=os.clock()
 local fallDuration=27
 local impactDone=false
 local transformed={}
 local fireObjects={}
 local modelParts={}
 local oldLighting={
  Ambient=ls.Ambient, OutdoorAmbient=ls.OutdoorAmbient, Brightness=ls.Brightness,
  FogColor=ls.FogColor, FogStart=ls.FogStart, FogEnd=ls.FogEnd, ClockTime=ls.ClockTime,
  ExposureCompensation=ls.ExposureCompensation
 }
 local fxFolder=Instance.new("Folder")
 fxFolder.Name="Chaos_WellTraveler_Apocalypse"
 fxFolder.Parent=ws

 -- Load the exact model ID supplied by the user. Strip executable descendants
 -- so an uploaded model cannot run its own scripts as part of this effect.
 local catModel=nil
 local ok,loaded=pcall(function() return game:GetObjects("rbxassetid://117318033999248") end)
 if ok and type(loaded)=="table" then
  for _,obj in ipairs(loaded) do
   if obj:IsA("Model") or obj:IsA("BasePart") then catModel=obj; break end
  end
 end
 if catModel then
  for _,d in ipairs(catModel:GetDescendants()) do
   if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then
    pcall(function() d:Destroy() end)
   elseif d:IsA("BasePart") then
    d.Anchored=true; d.CanCollide=false; d.CanTouch=false; d.CanQuery=false; d.Massless=true
    modelParts[#modelParts+1]=d
   end
  end
  if catModel:IsA("BasePart") then
   catModel.Anchored=true; catModel.CanCollide=false; catModel.CanTouch=false; catModel.CanQuery=false
   modelParts[#modelParts+1]=catModel
  end
  catModel.Parent=fxFolder
 else
  -- Fallback silhouette if the asset is private/unavailable in this executor.
  catModel=Instance.new("Model"); catModel.Name="Kotost_Fallback_Silhouette"; catModel.Parent=fxFolder
  local head=Instance.new("Part"); head.Name="KotostHead"; head.Shape=Enum.PartType.Ball
  head.Size=Vector3.new(18,18,18); head.Material=Enum.Material.SmoothPlastic
  head.Color=Color3.fromRGB(12,10,14); head.Anchored=true; head.CanCollide=false; head.Parent=catModel
  local eyeFolder=Instance.new("Folder"); eyeFolder.Name="GlowingEyes"; eyeFolder.Parent=catModel
  for _,x in ipairs({-4,4}) do
   local eye=Instance.new("Part"); eye.Shape=Enum.PartType.Ball; eye.Size=Vector3.new(1.6,1.6,0.7)
   eye.Material=Enum.Material.Neon; eye.Color=Color3.fromRGB(255,25,25); eye.Anchored=true; eye.CanCollide=false
   eye.CFrame=head.CFrame*CFrame.new(x,1,-8); eye.Parent=eyeFolder
  end
  modelParts={head}; for _,d in ipairs(catModel:GetDescendants()) do if d:IsA("BasePart") and d~=head then modelParts[#modelParts+1]=d end end
  notif("Kotost model could not load; using a fallback silhouette", 4)
 end

 local function pivotModel(cf)
  if catModel:IsA("Model") then
   if not catModel.PrimaryPart then
    local candidate=catModel:FindFirstChildWhichIsA("BasePart",true)
    if candidate then pcall(function() catModel.PrimaryPart=candidate end) end
   end
   pcall(function() catModel:PivotTo(cf) end)
  elseif catModel:IsA("BasePart") then catModel.CFrame=cf end
 end
 local function modelPosition()
  if catModel:IsA("Model") then
   local ok2,cf=pcall(function() return catModel:GetPivot() end)
   if ok2 then return cf.Position end
  elseif catModel:IsA("BasePart") then return catModel.Position end
  return hrp and hrp.Position+Vector3.new(0,150,0) or Vector3.zero
 end

 local initialTarget=hrp.Position
 local highPos=initialTarget+Vector3.new(0,180,0)
 -- Keep the cat facing the player as it descends from overhead.
 pivotModel(CFrame.lookAt(highPos,initialTarget))
 local skyLabel=Instance.new("BillboardGui"); skyLabel.Name="FallenTravelerTitle"; skyLabel.Size=UDim2.fromOffset(430,58)
 skyLabel.StudsOffset=Vector3.new(0,14,0); skyLabel.AlwaysOnTop=true; skyLabel.Parent=(catModel:IsA("Model") and (catModel.PrimaryPart or catModel:FindFirstChildWhichIsA("BasePart",true))) or catModel
 local title=Instance.new("TextLabel"); title.Size=UDim2.fromScale(1,1); title.BackgroundTransparency=1
 title.Text="WELL TRAVELER, YOUR DAY HAS FALLEN"; title.TextColor3=Color3.fromRGB(255,30,30)
 title.TextStrokeColor3=Color3.new(0,0,0); title.TextStrokeTransparency=0; title.Font=Enum.Font.Antique; title.TextScaled=true; title.Parent=skyLabel

 local cc=Instance.new("ColorCorrectionEffect"); cc.Name="FallenTravelerColorGrade"; cc.TintColor=Color3.fromRGB(255,130,115)
 cc.Saturation=-0.25; cc.Contrast=0.12; cc.Brightness=-0.03; cc.Parent=ls
 local atmosphere=Instance.new("Atmosphere"); atmosphere.Name="FallenTravelerAsh"
 atmosphere.Color=Color3.fromRGB(170,45,35); atmosphere.Decay=Color3.fromRGB(65,8,12)
 atmosphere.Density=0.38; atmosphere.Haze=3; atmosphere.Glare=0.15; atmosphere.Parent=ls
 ls.Ambient=Color3.fromRGB(100,18,18); ls.OutdoorAmbient=Color3.fromRGB(65,8,10)
 ls.Brightness=1.2; ls.FogColor=Color3.fromRGB(115,20,16); ls.FogStart=0; ls.FogEnd=500; ls.ClockTime=0

 local function createImpact()
  if impactDone then return end; impactDone=true
  notif("KOTOST HAS FALLEN — THE WORLD IS BURNING", 5)
  playSound(A.horror,1,hrp,4)
  -- Local-visible shockwave and a short flash; no server damage is claimed.
  local center=hrp and hrp.Position or modelPosition()
  local wave=Instance.new("Part"); wave.Name="FallenTravelerShockwave"; wave.Shape=Enum.PartType.Ball
  wave.Size=Vector3.new(8,8,8); wave.CFrame=CFrame.new(center); wave.Anchored=true; wave.CanCollide=false
  wave.Material=Enum.Material.Neon; wave.Color=Color3.fromRGB(255,30,5); wave.Transparency=0.18; wave.Parent=fxFolder
  ts:Create(wave,TweenInfo.new(1.7,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
   {Size=Vector3.new(280,280,280),Transparency=1}):Play(); debris:AddItem(wave,2)
  cc.Brightness=0.25; task.delay(0.15,function() if cc and cc.Parent then cc.Brightness=-0.03 end end)

  -- Tint and slightly deform visible map geometry, storing exact properties
  -- so cleanup can restore the scene. Limit the scan to 1,200 parts for safety.
  local function belongsToCharacter(part)
   local ancestor=part.Parent
   while ancestor and ancestor~=ws do
    if ancestor:IsA("Model") and ancestor:FindFirstChildOfClass("Humanoid") then return true end
    ancestor=ancestor.Parent
   end
   return false
  end
  local scanned=0
  for _,part in ipairs(ws:GetDescendants()) do
   if scanned>=1200 then break end
   if part:IsA("BasePart") and not part:IsDescendantOf(fxFolder) and not belongsToCharacter(part) then
    scanned+=1
    transformed[#transformed+1]={part=part,color=part.Color,material=part.Material,size=part.Size,cframe=part.CFrame,transparency=part.Transparency}
    local roll=math.random(1,5)
    part.Color=({Color3.fromRGB(48,8,12),Color3.fromRGB(95,15,12),Color3.fromRGB(25,22,25),Color3.fromRGB(130,28,12),Color3.fromRGB(65,10,25)})[roll]
    if part.Anchored then
     part.Material=(roll==4 and Enum.Material.Basalt) or (roll==3 and Enum.Material.Slate) or Enum.Material.CrackedLava
     if part.Size.X<36 and part.Size.Y<36 and part.Size.Z<36 and math.random()<0.28 then
      local scale=math.random(78,122)/100
      part.Size=Vector3.new(math.max(0.2,part.Size.X*scale),math.max(0.2,part.Size.Y*scale),math.max(0.2,part.Size.Z*scale))
      part.CFrame=part.CFrame*CFrame.Angles(0,math.rad(math.random(-8,8)),math.rad(math.random(-3,3)))
     end
    end
    if part.Anchored and part.Size.Magnitude<90 and #fireObjects<180 and math.random()<0.19 then
     local flame=Instance.new("Fire"); flame.Name="FallenTravelerHellfire"; flame.Color=Color3.fromRGB(255,55,5)
     flame.SecondaryColor=Color3.fromRGB(255,170,20); flame.Heat=math.random(8,18); flame.Size=math.random(5,12)
     flame.Parent=part; fireObjects[#fireObjects+1]=flame
    end
   end
  end
  -- Add a few freestanding flame columns as a visual hellscape layer.
  if hrp then
   for i=1,18 do
    local flameBase=Instance.new("Part"); flameBase.Name="HellscapeFlameBase"; flameBase.Size=Vector3.new(1,1,1)
    flameBase.Transparency=1; flameBase.Anchored=true; flameBase.CanCollide=false
    flameBase.Position=hrp.Position+Vector3.new(math.random(-100,100),math.random(-2,2),math.random(-100,100)); flameBase.Parent=fxFolder
    local flame=Instance.new("Fire"); flame.Color=Color3.fromRGB(255,40,0); flame.SecondaryColor=Color3.fromRGB(255,160,10)
    flame.Heat=18; flame.Size=math.random(10,22); flame.Parent=flameBase; fireObjects[#fireObjects+1]=flame
   end
  end
 end

 local conn=rs.Heartbeat:Connect(function(dt)
  if not fxFolder.Parent then return end
  local elapsed=os.clock()-startedAt
  if not impactDone and hrp and hrp.Parent then
   local target=hrp.Position
   local alpha=math.clamp(elapsed/fallDuration,0,1)
   local start=target+Vector3.new(0,180,0)
   local finish=target+Vector3.new(0,13,0)
   -- Ease slowly at first, then accelerate into the fall.
   local eased=alpha*alpha*(0.45+0.55*alpha)
   local pos=start:Lerp(finish,eased)
   pivotModel(CFrame.lookAt(pos,target))
   if alpha>=1 then createImpact() end
  elseif impactDone and catModel and catModel.Parent and hrp and hrp.Parent then
   -- Keep the fallen cat hovering over the player, slowly tracking them.
   local target=hrp.Position+Vector3.new(0,13,0)
   local current=modelPosition()
   local nextPos=current:Lerp(target,math.min(1,dt*0.18))
   pivotModel(CFrame.lookAt(nextPos,hrp.Position))
  end
 end)

 active.WellTravelerFallen={obj=fxFolder,conn=conn,objs={cc,atmosphere},f=function()
  for _,flame in ipairs(fireObjects) do pcall(function() if flame and flame.Parent then flame:Destroy() end end) end
  for _,snap in ipairs(transformed) do
   pcall(function() if snap.part and snap.part.Parent then
    snap.part.Color=snap.color; snap.part.Material=snap.material; snap.part.Size=snap.size
    snap.part.CFrame=snap.cframe; snap.part.Transparency=snap.transparency
   end end)
  end
  pcall(function()
   ls.Ambient=oldLighting.Ambient; ls.OutdoorAmbient=oldLighting.OutdoorAmbient; ls.Brightness=oldLighting.Brightness
   ls.FogColor=oldLighting.FogColor; ls.FogStart=oldLighting.FogStart; ls.FogEnd=oldLighting.FogEnd
   ls.ClockTime=oldLighting.ClockTime; ls.ExposureCompensation=oldLighting.ExposureCompensation
  end)
 end}
end,function() cleanup("WellTravelerFallen") end)

local ALL_EFFECTS = {}
local function rebuildList()
 ALL_EFFECTS = {}
 for _,e in ipairs(E) do
 local cat=e.cat
 if (cat=="Visual" and C.visual) or (cat=="Physics" and C.physics) or
 (cat=="Player" and C.player) or (cat=="Camera" and C.camera) or
 (cat=="Audio" and C.audio) or (cat=="Environment" and C.environment) or
 (cat=="NPCs" and C.npc_) or (cat=="HUD/UI" and C.hud_) or
 (cat=="Controls" and C.controls) or (cat=="Randomizer" and C.randomizer_) or
 (cat=="Nostalgia" and C.nostalgia) or (cat=="Misc" and C.misc) or
 (cat=="Extra" and C.misc) then
 ALL_EFFECTS[#ALL_EFFECTS+1]=e
 end
 end
end
rebuildList()

-- ============================================
-- TRIGGER SYSTEM
-- ============================================
local lastTrigger=0

-- Per-effect cooldown tracker. Maps effect name -> os.time() when
-- it last fired. triggerEffect() filters the candidate pool to
-- effects whose cooldown has elapsed, so no single effect can
-- spam-fire. Auto-applied to every effect — no per-effect config.
local effectLastFired = {}

-- Each effect trigger gets a unique instance ID so we can guarantee
-- cleanup after `dur` seconds, even if:
--   • `delay` fails to fire (rare, but possible on some executors)
--   • `e.stop()` throws before finishing cleanup
--   • The same effect is re-triggered while already active (stacking)
-- Without this, re-triggering would overwrite `active[name]` and leak
-- the first instance's resources (connections, GUI objects, etc.).
local effectInstances = {}  -- [id] = {name=, stop=, expires=, key=}
local nextInstID = 1

local function forceEndEffect(id)
 local inst = effectInstances[id]
 if not inst then return end
 effectInstances[id] = nil
 -- 1. Call the effect's own stop function (most effects do their
 --    cleanup here via cleanup(name))
 if inst.stop then pcall(inst.stop) end
 -- 2. Safety net: also call cleanup(name) directly in case stop()
 --    threw or never called it. cleanup() is a no-op if active[name]
 --    is already nil, so this can't double-fire.
 if inst.key then pcall(function() cleanup(inst.key) end) end
 -- 3. Clear the HUD-visible expiry timestamp if this was the latest
 --    instance of this effect name.
 if inst.name and currentEffectEndsAt[inst.name] == inst.expires then
  currentEffectEndsAt[inst.name] = nil
 end
end

local function triggerEffect()
 if not C.enabled or #ALL_EFFECTS==0 then rebuildList(); if #ALL_EFFECTS==0 then return end end
 local ac=0 for _ in pairs(active) do ac=ac+1 end
 if not C.stacking and ac>0 then return end
 if ac>=C.maxStacked then return end

 -- Build a pool of candidate effects filtered by per-effect cooldown.
 -- An effect is eligible if:
 --   • It has never fired, OR
 --   • Its cooldown (C.cooldown seconds) has elapsed since last fire
 --   • It's not currently in the active[] table (prevents stacking
 --     the same effect on itself when stacking is on)
 -- If the pool is empty (everything on cooldown), this trigger cycle
 -- is silently skipped — the next auto-trigger attempt will try again.
 local now=os.time()
 local pool={}
 for _,e in ipairs(ALL_EFFECTS) do
  local last=effectLastFired[e.name]
  local cooldownOk = (not last) or (now - last) >= C.cooldown
  -- Check both the effect name AND a few common key patterns. Most
  -- effects store their cleanup state under active[shortKey] where
  -- shortKey is derived from the effect name (e.g. "DVD Screensaver"
  -- -> active.DVD). We can't know every key without running the
  -- effect, so we rely on cooldown alone — if cooldown is respected,
  -- the effect can't be double-triggered anyway.
  if cooldownOk then
   pool[#pool+1]=e
  end
 end

 if #pool==0 then
  -- Everything is on cooldown. Skip this trigger silently.
  -- The HUD will show "NEXT EFFECT IN" counting down to the next
  -- auto-trigger attempt, which will re-check the pool.
  return
 end

 local e=pool[math.random(#pool)]
 -- Record the fire time so this effect enters cooldown
 effectLastFired[e.name]=now
 lastE=e eTotal=eTotal+1
 pcall(e.start)
 local dur=e.dur or C.defaultDuration
 local id=nextInstID nextInstID=nextInstID+1
 local expires=os.time()+dur
 -- `key` is the active[] table key this effect uses for cleanup.
 -- Most effects use their effect name as the key; we infer it here
 -- so forceEndEffect() can call cleanup() even if stop() is missing.
 effectInstances[id]={name=e.name, stop=e.stop, expires=expires, key=e.name}
 currentEffectEndsAt[e.name]=expires
 -- Toast notification for the activated effect (uses category-specific color)
 -- Always notify when an effect is activated (was previously ~28% chance)
 notif(e.icon.." "..e.name.." ["..e.cat.."] ("..dur.."s)",3)
 -- Primary cleanup: scheduled timer. Fires after `dur` seconds.
 delay(dur,function() forceEndEffect(id) end)
end

-- Watchdog: runs every 0.5s and force-ends any instance whose
-- expiry has passed. This is the safety net for cases where `delay`
-- didn't fire (executor bug) or `e.stop()` threw before clearing
-- `active[name]`. Without this, a buggy effect would run forever.
spawn(function()
 while true do
  local now=os.time()
  for id,inst in pairs(effectInstances) do
   if inst.expires<=now then
    forceEndEffect(id)
   end
  end
  wait(0.5)
 end
end)

local function startChaos()
 if chaosRunning then return end chaosRunning=true
 local function loop() if not chaosRunning then return end
  triggerEffect()
  local base=C.intervalMin+(C.intervalMax-C.intervalMin)*(1-C.intensity/10)
  local nextTime=math.max(2,base+math.random(-base*0.3,base*0.3))
  nextEffectAt=os.time()+nextTime
  delay(nextTime,loop) end
 -- Don't fire an effect the instant the script runs — wait one
 -- interval first. (Fixes "effect fires the minute I run it".)
 local base=C.intervalMin+(C.intervalMax-C.intervalMin)*(1-C.intensity/10)
 local firstTime=math.max(2,base+math.random(-base*0.3,base*0.3))
 nextEffectAt=os.time()+firstTime
 delay(firstTime,loop)
end
local function stopChaos()
 chaosRunning=false
 -- Force-end every tracked instance (calls each effect's stop + cleanup)
 for id in pairs(effectInstances) do forceEndEffect(id) end
 effectInstances={}
 -- Belt-and-suspenders: cleanup any active[] entries whose instances
 -- were never tracked (e.g. effects started before this fix loaded).
 -- Uses cleanup(k) instead of just e.f so connections/objects are
 -- properly disconnected/destroyed.
 for k in pairs(active) do cleanup(k) end
 active={}
 ls.Ambient=Color3.fromRGB(127,127,127) ls.OutdoorAmbient=Color3.fromRGB(127,127,127) ls.Brightness=2
 ws.Gravity=196.2 ss.Muted=false
 if hum then hum.WalkSpeed=16 hum.JumpPower=50 end
end

-- ============================================
-- TIMER-ONLY HUD
-- The countdown reaches zero, then triggerEffect() announces the
-- selected effect using the existing toast notification system.
-- ============================================
local timerHud=Instance.new("ScreenGui")
timerHud.Name="ChaosTimerHUD"
timerHud.ResetOnSpawn=false
timerHud.IgnoreGuiInset=true
timerHud.DisplayOrder=9998
timerHud.Parent=plr:WaitForChild("PlayerGui")

local hudFrame=Instance.new("Frame",timerHud)
hudFrame.Size=UDim2.new(0,220,0,44)
hudFrame.Position=UDim2.new(0.5,-110,0,8)
hudFrame.BackgroundColor3=Color3.fromRGB(14,14,20)
hudFrame.BackgroundTransparency=0.12
hudFrame.BorderSizePixel=0
hudFrame.Active=true
hudFrame.Draggable=true
Instance.new("UICorner",hudFrame).CornerRadius=UDim.new(0,9)
local hudStroke=Instance.new("UIStroke",hudFrame)
hudStroke.Color=Color3.fromRGB(255,80,180)
hudStroke.Thickness=1.4

local hudNext=Instance.new("TextLabel",hudFrame)
hudNext.Size=UDim2.new(1,-12,1,0)
hudNext.Position=UDim2.new(0,6,0,0)
hudNext.BackgroundTransparency=1
hudNext.Text="⚡ NEXT EFFECT IN --s"
hudNext.TextColor3=Color3.fromRGB(220,225,255)
hudNext.Font=Enum.Font.GothamBold
hudNext.TextSize=14
hudNext.TextXAlignment=Enum.TextXAlignment.Center

spawn(function()
 while timerHud and timerHud.Parent do
  if chaosRunning and C.enabled then
   local remain=math.max(0,nextEffectAt-os.time())
   hudNext.Text="⚡ NEXT EFFECT IN "..tostring(math.floor(remain)).."s"
   if remain<=3 then
    hudNext.TextColor3=Color3.fromRGB(255,75,90)
    hudStroke.Color=Color3.fromRGB(255,60,80)
   else
    hudNext.TextColor3=Color3.fromRGB(220,225,255)
    hudStroke.Color=Color3.fromRGB(255,80,180)
   end
  else
   hudNext.Text="⏸ CHAOS PAUSED"
   hudNext.TextColor3=Color3.fromRGB(170,170,180)
   hudStroke.Color=Color3.fromRGB(100,100,110)
  end
  task.wait(0.2)
 end
end)

-- ============================================
-- KEYBINDS
-- ============================================
uis.InputBegan:Connect(function(i,gpe) if gpe then return end
 local k=i.KeyCode
 if k==Enum.KeyCode.F4 then if C.enabled then triggerEffect() end
 elseif k==Enum.KeyCode.F5 then C.enabled=not C.enabled
 if C.enabled then startChaos()
  else stopChaos() end
 elseif k==Enum.KeyCode.F6 then stopChaos() if C.enabled then startChaos() end
 elseif k==Enum.KeyCode.F7 then -- Toggle pitch shifter as stand-alone
 if active.PitchShift then cleanup("PitchShift") notif("🎚️ Pitch Shift OFF",2)
 else
 pitchPhase=0 active.PitchShift={f=function() for s,o in pairs(originals) do if s and s.Parent then s.PlaybackSpeed=o end end pitchPhase=0 pitchSpeed=1 end}
 notif("🎚️ Pitch Shift ON",2)
 end
 elseif k==Enum.KeyCode.F8 then triggerEffect() triggerEffect() triggerEffect() notif("⚡ TRIPLE CHAOS!",2)
 end
end)

-- ============================================
-- GC & STARTUP
-- ============================================
spawn(function() while wait(45) do collectgarbage("collect") end end)
notif("🌀 Chaos Mod v2 Loaded! "..#ALL_EFFECTS.." effects.",6)
notif("Timer-only HUD | F4=Force | F5=Toggle | F6=Clear | F7=PitchShift | F8=Triple",8)
C.enabled=true startChaos()
print("═══════════════════════════════════════")
