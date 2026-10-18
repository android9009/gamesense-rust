local World = {}
local STEP = "GS_WorldApply"
local SPARK = "rbxasset://textures/particles/sparkles_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"
local PROPS = {
    "ClockTime", "Brightness", "Ambient", "OutdoorAmbient",
    "ColorShift_Top", "ColorShift_Bottom", "FogColor", "FogStart", "FogEnd",
    "GlobalShadows", "ShadowSoftness", "ExposureCompensation",
}
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local function NS(a, b) return NumberSequence.new(a, b or a) end
local function NR(a, b) return NumberRange.new(a, b or a) end
local function CS(a, b)
    return typeof(a) == "ColorSequence" and a or (b and ColorSequence.new(a, b) or ColorSequence.new(a))
end
local WEATHER = {
    [1] = {
        fog = 220, fogc = rgb(118, 132, 148), tint = rgb(186, 198, 214), ccb = -0.04, ccs = -0.08,
        atmo = {0.25, 1.2, rgb(150, 164, 180), rgb(90, 100, 120)},
        lift = 26, size = Vector3.new(110, 1, 110),
        p = {tex = SPARK, col = rgb(168, 186, 210), size = NS(0.12, 0.04), trans = 0.25, life = NR(0.45, 0.75), spd = NR(48, 78), spread = Vector2.new(3, 3), acc = Vector3.new(0, -95, 0), dir = "Bottom", rate = 420, look = "VelocityParallel", glow = 0.15},
        v = {tex = SMOKE, col = rgb(140, 154, 172), size = NS(2.4, 4.5), trans = NS(0.85, 1), life = NR(0.6, 1.1), spd = NR(2, 6), spread = Vector2.new(40, 40), acc = Vector3.new(0, -8, 0), rate = 0},
    },
    [2] = {
        fog = 280, fogc = rgb(188, 200, 214), tint = rgb(214, 226, 238), ccb = 0.04, ccs = -0.12,
        atmo = {0.22, 1.4, rgb(210, 220, 230), rgb(170, 180, 195)},
        lift = 26, size = Vector3.new(90, 1, 90),
        p = {tex = SPARK, col = rgb(245, 248, 255), size = NS(0.18, 0.32), trans = NS(0.15, 0.55), life = NR(4, 7), spd = NR(3, 8), spread = Vector2.new(18, 18), acc = Vector3.new(1.6, -6, 0.4), dir = "Bottom", rate = 220, glow = 0.35, rot = NR(0, 180), spin = NR(-50, 50)},
    },
    [3] = {
        fog = 140, fogc = rgb(46, 52, 68), tint = rgb(78, 88, 112), ccb = -0.12, ccs = -0.18, thunder = true,
        atmo = {0.4, 2.2, rgb(70, 78, 96), rgb(28, 32, 44)},
        lift = 26, size = Vector3.new(110, 1, 110),
        p = {tex = SPARK, col = rgb(168, 186, 210), size = NS(0.12, 0.04), trans = 0.25, life = NR(0.45, 0.75), spd = NR(48, 78), spread = Vector2.new(3, 3), acc = Vector3.new(0, -95, 0), dir = "Bottom", rate = 780, look = "VelocityParallel", glow = 0.15},
        v = {tex = SMOKE, col = rgb(140, 154, 172), size = NS(2.4, 4.5), trans = NS(0.85, 1), life = NR(0.6, 1.1), spd = NR(2, 6), spread = Vector2.new(40, 40), acc = Vector3.new(0, -8, 0), rate = 18},
    },
    [4] = {
        fog = 160, fogc = rgb(58, 50, 46), tint = rgb(92, 78, 68), ccb = -0.1, ccs = -0.22,
        atmo = {0.38, 2, rgb(86, 74, 64), rgb(28, 22, 18)},
        lift = 26, size = Vector3.new(90, 1, 90),
        p = {tex = SMOKE, col = CS(rgb(36, 34, 32), rgb(88, 74, 62)), size = NS(0.16, 0.4), trans = NS(0.2, 0.7), life = NR(3.5, 6), spd = NR(2, 6), spread = Vector2.new(22, 22), acc = Vector3.new(3.5, -5, 0), dir = "Bottom", rate = 160, rot = NR(0, 180), spin = NR(-20, 20)},
        v = {tex = SMOKE, col = rgb(48, 42, 38), size = NS(3, 7), trans = NS(0.78, 1), life = NR(1.2, 2.2), spd = NR(1, 3), rate = 10},
    },
    [5] = {
        fog = 90, fogc = rgb(176, 140, 86), tint = rgb(198, 158, 96), ccb = 0.02, ccs = -0.05,
        atmo = {0.48, 2.6, rgb(186, 150, 92), rgb(120, 88, 48)},
        lift = 0, size = Vector3.new(70, 28, 70),
        p = {tex = SMOKE, col = CS(rgb(186, 148, 88), rgb(214, 176, 110)), size = NS(2.2, 6), trans = NS(0.55, 1), life = NR(1.2, 2.4), spd = NR(18, 42), spread = Vector2.new(28, 12), acc = Vector3.new(26, -1.5, 0), dir = "Right", rate = 70, glow = 0.05},
        v = {tex = SMOKE, col = rgb(168, 132, 78), size = NS(5, 11), trans = NS(0.72, 1), life = NR(1.6, 2.8), spd = NR(8, 16), spread = Vector2.new(50, 30), acc = Vector3.new(18, 0, 0), dir = "Right", rate = 22},
    },
}
local snap, on, autoTime
local cc, folder, anchor, emitters, curWeather = nil, nil, nil, {}, -1
local boltNext, boltT0 = 0, nil
local ChamsRuntime = {
    Started = false,
    BotScanTimer = 0,
    OcclusionTimer = 0,
    Bots = {}
}
local function chamsColor(flagName, fallback)
    local value = Library and Library.Flags and Library.Flags[flagName]
    if type(value) == "table" then
        local color = typeof(value.Color) == "Color3" and value.Color or fallback
        local transparency = type(value.Transparency) == "number" and math.clamp(value.Transparency, 0, 1) or 0.15
        return color, transparency
    end
    return fallback, 0.15
end
local function chamsStyle(flagName)
    local style = Library and Library.Flags and Library.Flags[flagName]
    return style == "Normal" and "Normal" or "Flat"
end
local MAX_CHAM_TARGETS = 14
local MAX_CHAM_PARTS = 16
local modelPartsCache = {}
local function modelPosition(model)
    local root = findRootPart(model)
    return root and root.Position or model:GetPivot().Position
end
local function collectChamsParts(model)
    local parts = {}
    for _, object in ipairs(Entity.GetParts(model)) do
        if object:IsA("BasePart")
            and object.Name ~= "HumanoidRootPart"
            and object.Transparency < 0.99
            and not object:FindFirstAncestorOfClass("Tool") then
            parts[#parts + 1] = object
        end
    end
    table.sort(parts, function(a, b)
        local aAccessory = a:FindFirstAncestorOfClass("Accessory") ~= nil
        local bAccessory = b:FindFirstAncestorOfClass("Accessory") ~= nil
        if aAccessory ~= bAccessory then
            return not aAccessory
        end
        return a.Name < b.Name
    end)
    while #parts > MAX_CHAM_PARTS do
        table.remove(parts)
    end
    return parts
end
local function getChamsParts(model)
    local cached = modelPartsCache[model]
    if cached then
        local valid = true
        for _, part in ipairs(cached) do
            if not part.Parent or not part:IsDescendantOf(model) then
                valid = false
                break
            end
        end
        if valid then return cached end
    end
    local parts = collectChamsParts(model)
    modelPartsCache[model] = parts
    return parts
end
local function removeModelChams(model)
    local hl = model:FindFirstChild("GS_LocalHighlight")
    if hl then
        pcall(function() hl:Destroy() end)
    end
    if model == LocalPlayer.Character and Chams.LocalHighlight then
        if Chams.LocalHighlight.Parent then
            pcall(function() Chams.LocalHighlight:Destroy() end)
        end
        Chams.LocalHighlight = nil
    end
    Chams.RemoveModelParts(model)
    modelPartsCache[model] = nil
end
local function partIsOccluded(camera, part, character)
    local ignore = {character}
    if LocalPlayer.Character and LocalPlayer.Character ~= character then
        ignore[#ignore + 1] = LocalPlayer.Character
    end
    local points = {part.Position}
    local halfY = math.min(part.Size.Y * 0.3, 1.25)
    if halfY > 0.35 then
        points[#points + 1] = part.CFrame:PointToWorldSpace(Vector3.new(0, halfY, 0))
        points[#points + 1] = part.CFrame:PointToWorldSpace(Vector3.new(0, -halfY, 0))
    end
    for _, point in ipairs(points) do
        local ok, blockers = pcall(function()
            return camera:GetPartsObscuringTarget({point}, ignore)
        end)
        if ok and #blockers == 0 then
            return false
        end
    end
    return true
end
 
 
 
local LP_TRANSPARENCY = 0.15
local localBodyTransparent = false

 
 
local function applyModelPartChams(model, visibleFlag, wallFlag, visibleColorFlag, wallColorFlag, visibleStyleFlag, wallStyleFlag, refreshOcclusion, alwaysOn)
    local visibleEnabled = flag(visibleFlag, false) == true
    local wallEnabled = wallFlag and flag(wallFlag, false) == true or false
    if not Entity.IsAliveModel(model) or (not visibleEnabled and not wallEnabled) then
        Chams.RemoveModel(model)
        return
    end
    local camera = Workspace.CurrentCamera
    if not camera then Chams.RemoveModel(model); return end
    local visibleOptions, wallOptions
    if visibleEnabled then
        local color, alpha = chamsColor(visibleColorFlag, Color3.fromRGB(142, 181, 39))
        local normal = chamsStyle(visibleStyleFlag) == "Normal"
        visibleOptions = {FillColor = color, FillTransparency = normal and math.max(alpha, 0.6) or alpha,
            OutlineColor = color, OutlineTransparency = normal and 0 or 1, Enabled = true}
    end
    if wallEnabled then
        local color, alpha = chamsColor(wallColorFlag, Color3.fromRGB(79, 143, 214))
        local normal = chamsStyle(wallStyleFlag) == "Normal"
        wallOptions = {FillColor = color, FillTransparency = normal and math.max(alpha, 0.6) or alpha,
            OutlineColor = color, OutlineTransparency = normal and 0 or 1, Enabled = true}
    end
    Chams.ApplyLayers(model, visibleOptions, wallOptions, camera)
end
local function addChamsTarget(targets, model, kind, player)
    if model and model.Parent and Entity.IsAliveModel(model) then
        local index = #targets + 1
        ChamsRuntime.RecordPool = ChamsRuntime.RecordPool or {}
        local record = ChamsRuntime.RecordPool[index]
        if not record then record = {}; ChamsRuntime.RecordPool[index] = record end
        record.Model, record.Kind, record.Player = model, kind, player
        targets[index] = record
    end
end
local function applyLocalPlayerChams(model)
    local enabled = flag("VisLocalPlayer", false) == true
    if not enabled or not Entity.IsAliveModel(model) then
        if Chams.LocalHighlight then
            if Chams.LocalHighlight.Parent then
                pcall(function() Chams.LocalHighlight:Destroy() end)
            end
            Chams.LocalHighlight = nil
        end
        local existingHl = model:FindFirstChild("GS_LocalHighlight")
        if existingHl then
            pcall(function() existingHl:Destroy() end)
        end
        Chams.RemoveModelParts(model)
        return
    end

    local color, trans = chamsColor("VisLocalPlayerColor", Color3.fromRGB(110, 110, 110))
    local style = chamsStyle("VisLocalPlayerStyle")

    if localBodyTransparent then
        trans = math.max(trans, LP_TRANSPARENCY)
    end

    local fillTrans = (style == "Normal") and math.max(trans, 0.6) or trans
    local outlineTrans = (style == "Normal") and 0 or 1

    local hl = Chams.LocalHighlight
    if not hl or not hl.Parent then
        hl = model:FindFirstChild("GS_LocalHighlight")
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "GS_LocalHighlight"
        end
        Chams.LocalHighlight = hl
    end

    configureHighlight(hl, model, {
        FillColor = color, FillTransparency = fillTrans,
        OutlineColor = color, OutlineTransparency = outlineTrans, Enabled = true,
    }, true, Workspace)
end

local function applyTargetChams(target, refreshOcclusion)
    if target.Kind == "local" then
        applyLocalPlayerChams(target.Model)
    elseif target.Kind == "bot" or target.Kind == "enemy" then
        applyModelPartChams(target.Model, "VisPlayer", "VisPlayerWall", "VisPlayerColor", "VisPlayerWallColor", "VisPlayerStyle", "VisPlayerWallStyle", refreshOcclusion)
    else
        applyModelPartChams(target.Model, "VisTeammate", "VisTeammateWall", "VisTeammateColor", "VisTeammateWallColor", "VisTeammateStyle", "VisTeammateWallStyle", refreshOcclusion)
    end
end

 
 
 
 
 
 
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OnShot = {
    Ghosts = {},          
    HitConns = {},        
    Hooked = false,
    LastModelTime = {}    
}
local ONSHOT_DURATION = 3   
local ONSHOT_FADE = 1       
local MAX_GHOSTS = 4        
local HIT_REMOTES = {"Hitmarker", "BulletHit"}   

local function smoothstep(t)
    return t * t * (3 - 2 * t)
end

local function destroyGhost(g)
    if g.Highlight and g.Highlight.Parent then g.Highlight:Destroy() end
    if g.Model and g.Model.Parent then g.Model:Destroy() end
end

local function spawnGhost(model)
    local color = chamsColor("VisOnShotColor", Color3.fromRGB(110, 110, 110))
    local wasArchivable = model.Archivable
    model.Archivable = true
    local ghost = model:Clone()
    model.Archivable = wasArchivable
    if not ghost then return nil end
    local parts = {}
    for _, obj in ipairs(ghost:GetDescendants()) do
        if obj:IsA("Humanoid") or obj:IsA("AnimationController")
            or obj:IsA("Script") or obj:IsA("LocalScript")
            or obj:IsA("Tool") or obj:IsA("ForceField")
            or obj:IsA("BillboardGui") or obj:IsA("Sound")
            or obj:IsA("Highlight") or obj:IsA("Decal")
            or obj:IsA("JointInstance") or obj:IsA("WeldConstraint")
            or obj:IsA("Motor6D") or obj:IsA("Attachment")
            or obj:IsA("WrapLayer") or obj:IsA("WrapTarget") then
            pcall(function() obj:Destroy() end)
        elseif obj:IsA("BasePart") then
            obj.Anchored = true
            obj.CanCollide = false
            obj.CanQuery = false
            obj.CanTouch = false
            obj.CastShadow = false
            obj.Color = color
            obj.Material = Enum.Material.SmoothPlastic
            obj.Transparency = 0
            parts[#parts + 1] = obj
        end
    end
    local hl = Instance.new("Highlight")
    hl.Name = "GS_OnShot"
    hl.Adornee = ghost
    hl.FillColor = color
    hl.FillTransparency = 0
    hl.OutlineColor = color
    hl.OutlineTransparency = chamsStyle("VisOnShotStyle") == "Normal" and 0 or 1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = true
    hl.Parent = ghost
    ghost.Parent = Workspace
    return {
        Model = ghost,
        Target = model,
        Highlight = hl,
        Parts = parts,
        Expiry = tick() + ONSHOT_DURATION,
    }
end

 
local function findRemoteByName(name)
    local rs = ReplicatedStorage
    local function scan(node)
        for _, child in ipairs(node:GetChildren()) do
            if child.Name == name and (child:IsA("RemoteEvent") or child:IsA("RemoteFunction")) then
                return child
            end
        end
        for _, child in ipairs(node:GetChildren()) do
            if not child:IsA("Script") and not child:IsA("LocalScript") and not child:IsA("ModuleScript") then
                local r = scan(child)
                if r then return r end
            end
        end
        return nil
    end
    return scan(rs)
end

 
 
 
 
 
local function isShotTargetModel(m)
    if not m or not m:IsA("Model") then return false end
    if m == LocalPlayer.Character then return false end
    local humanoid = m:FindFirstChildOfClass("Humanoid")
    local root = findRootPart(m)
    return humanoid ~= nil and root ~= nil
end

 
 
 
local function nearestLivingModel(pos)
    local best, bestDist
    local function consider(model)
         
        local minD
        for _, obj in ipairs(Entity.GetParts(model)) do
            if obj:IsA("BasePart") then
                local d = (obj.Position - pos).Magnitude
                if not minD or d < minD then minD = d end
            end
        end
        if minD and (not bestDist or minD < bestDist) then
            bestDist = minD
            best = model
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and isShotTargetModel(player.Character) then consider(player.Character) end
    end
    if ChamsRuntime and ChamsRuntime.Bots then
        for bot in pairs(ChamsRuntime.Bots) do
            if isShotTargetModel(bot) then consider(bot) end
        end
    end
    if best and bestDist and bestDist < 30 then return best end
    return nil
end

 
local function locateTarget(args)
    for _, v in ipairs(args) do
        local t = typeof(v)
        if t == "Instance" then
            if v:IsA("Player") then
                if v.Character and isShotTargetModel(v.Character) then return v.Character end
            elseif v:IsA("Model") and isShotTargetModel(v) then
                return v
            elseif v:IsA("BasePart") then
                local m = v:FindFirstAncestorOfClass("Model")
                if m and isShotTargetModel(m) then return m end
            end
        elseif t == "Vector3" then
            local m = nearestLivingModel(v)
            if m then return m end
        elseif t == "CFrame" then
            local m = nearestLivingModel(v.Position)
            if m then return m end
        end
    end
    return nil
end

 
local function raycastTarget()
    local camera = Workspace.CurrentCamera
    local char = LocalPlayer.Character
    if not camera or not char then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, camera}
    local hit = Workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * 500, params)
    if hit and hit.Instance then
        local m = hit.Instance:FindFirstAncestorOfClass("Model")
        if m and m ~= char and isShotTargetModel(m) then return m end
    end
    return nil
end

local function spawnGhostOnHit(args)
    if flag("VisOnShot", false) ~= true then return end
    local target = locateTarget(args) or raycastTarget()
    if not target then return end
     
     
    local nowT = tick()
    if OnShot.LastModelTime[target] and nowT - OnShot.LastModelTime[target] < 0.15 then return end
    OnShot.LastModelTime[target] = nowT
    while #OnShot.Ghosts >= MAX_GHOSTS do
        destroyGhost(OnShot.Ghosts[1])
        table.remove(OnShot.Ghosts, 1)
    end
    local ok, ghost = pcall(spawnGhost, target)
    if ok and ghost then
        OnShot.Ghosts[#OnShot.Ghosts + 1] = ghost
    end
end

 
local function ensureHooked()
    if OnShot.Hooked or os.clock() < (OnShot.NextScan or 0) then return end
    OnShot.NextScan = os.clock() + 1
    OnShot.RemoteSet = OnShot.RemoteSet or {}
    local found = 0
    for _, name in ipairs(HIT_REMOTES) do
        local remote = findRemoteByName(name)
        if remote and remote:IsA("RemoteEvent") then
            found += 1
            if not OnShot.RemoteSet[remote] then
                OnShot.RemoteSet[remote] = true
                OnShot.HitConns[#OnShot.HitConns + 1] = remote.OnClientEvent:Connect(function(...)
                    spawnGhostOnHit({...})
                end)
            end
        end
    end
    OnShot.Hooked = found == #HIT_REMOTES
end

local function OnShotUpdate()
    if flag("VisOnShot", false) ~= true then
        for _, g in ipairs(OnShot.Ghosts) do destroyGhost(g) end
        table.clear(OnShot.Ghosts)
        return
    end
    ensureHooked()

    local now = tick()
    for i = #OnShot.Ghosts, 1, -1 do
        local g = OnShot.Ghosts[i]
        local remaining = g.Expiry - now
        if remaining <= 0 then
            destroyGhost(g)
            table.remove(OnShot.Ghosts, i)
        else
            local fade = remaining < ONSHOT_FADE and smoothstep(remaining / ONSHOT_FADE) or 1
            local alpha = 1 - fade

             
             
             
             
            local proximityAlpha = 0
            if g.Target and g.Target.Parent and g.Model and g.Model.Parent then
                local targetRoot = findRootPart(g.Target)
                local ghostRoot = findRootPart(g.Model)
                if targetRoot and ghostRoot then
                    local distance = (targetRoot.Position - ghostRoot.Position).Magnitude
                    proximityAlpha = 1 - math.clamp(distance / 12, 0, 1)
                    proximityAlpha = proximityAlpha * 0.85
                end
            end
            local visualAlpha = math.max(alpha, proximityAlpha)
            for _, part in ipairs(g.Parts) do
                if part.Parent then part.Transparency = visualAlpha end
            end
            if g.Highlight and g.Highlight.Parent then
                g.Highlight.FillTransparency = visualAlpha
            end
        end
    end
end

function ChamsRuntime.Apply(deltaTime)
    OnShotUpdate()
    local enemies = flag("VisPlayer", false) == true or flag("VisPlayerWall", false) == true
    local teammates = flag("VisTeammate", false) == true or flag("VisTeammateWall", false) == true
    local own = flag("VisLocalPlayer", false) == true
    if not enemies and not teammates and not own then
        if not ChamsRuntime.Idle then
            Chams.ClearAll()
            table.clear(modelPartsCache)
            table.clear(ChamsRuntime.Bots)
            ChamsRuntime.Idle = true
        end
        return
    end
    ChamsRuntime.Idle = false
    Chams.BeginLayerFrame()
    ChamsRuntime.TargetBuffer = ChamsRuntime.TargetBuffer or {}
    local targets = ChamsRuntime.TargetBuffer
    table.clear(targets)
    for _, player in ipairs(Players:GetPlayers()) do
        local kind = player == LocalPlayer and "local" or (Entity.IsEnemy(player) and "enemy" or "teammate")
        if (kind == "local" and own) or (kind == "enemy" and enemies) or (kind == "teammate" and teammates) then
            addChamsTarget(targets, player.Character, kind, player)
        end
    end
    if enemies then
        for _, bot in ipairs(Entity.GetNPCs()) do addChamsTarget(targets, bot, "bot") end
    end
    local camera = Workspace.CurrentCamera
    if camera then
        local position = camera.CFrame.Position
        for _, target in ipairs(targets) do target.Distance = (modelPosition(target.Model) - position).Magnitude end
        table.sort(targets, function(a, b)
            if (a.Kind == "local") ~= (b.Kind == "local") then return a.Kind == "local" end
            return a.Distance < b.Distance
        end)
    end
    ChamsRuntime.ActiveModels = ChamsRuntime.ActiveModels or {}
    local activeModels = ChamsRuntime.ActiveModels
    table.clear(activeModels)
    for index = 1, math.min(#targets, MAX_CHAM_TARGETS) do
        local target = targets[index]
        activeModels[target.Model] = true
        applyTargetChams(target, false)
    end
    for model in pairs(Chams.ModelCache) do
        if not activeModels[model] then Chams.RemoveModel(model) end
    end
    for model in pairs(Chams.ModelOcclusion) do
        if not activeModels[model] then Chams.ModelOcclusion[model] = nil end
    end
    if LocalPlayer.Character and not activeModels[LocalPlayer.Character] then
        if Chams.LocalHighlight then
            if Chams.LocalHighlight.Parent then
                pcall(function() Chams.LocalHighlight:Destroy() end)
            end
            Chams.LocalHighlight = nil
        end
    end
    Chams.FlushLayerFrame()
end
function ChamsRuntime.Shutdown()
    pcall(function() RunService:UnbindFromRenderStep("GS_ChamsApply") end)
    TaskManager.RemoveConnection("ChamsApply")
    TaskManager.RemoveConnection("ChamsPlayers")
    Chams.ClearAll()
    table.clear(modelPartsCache)
    for _, conn in ipairs(OnShot.HitConns) do
        conn:Disconnect()
    end
    table.clear(OnShot.HitConns)
    for _, g in ipairs(OnShot.Ghosts) do
        destroyGhost(g)
    end
    table.clear(OnShot.Ghosts)
    table.clear(OnShot.LastModelTime)
    ChamsRuntime.TargetBuffer, ChamsRuntime.RecordPool, ChamsRuntime.ActiveModels = nil, nil, nil
    ChamsRuntime.Bots = {}
    ChamsRuntime.BotScanTimer = 0
    ChamsRuntime.OcclusionTimer = 0
    ChamsRuntime.Idle = false
    OnShot.Hooked = false
    OnShot.RemoteSet = nil
    OnShot.NextScan = nil
    ChamsRuntime.Started = false
end
function ChamsRuntime.Start()
    if ChamsRuntime.Started then return end
    ChamsRuntime.Started = true
    local bound = pcall(function()
        RunService:BindToRenderStep("GS_ChamsApply", Enum.RenderPriority.Last.Value + 14, ChamsRuntime.Apply)
    end)
    if not bound then TaskManager.AddConnection("ChamsApply", RunService.RenderStepped, ChamsRuntime.Apply) end
    TaskManager.AddConnection("ChamsPlayers", Players.PlayerRemoving, function(player)
        if player.Character then Chams.RemoveModelParts(player.Character) end
    end)
    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, ChamsRuntime.Shutdown)
    end
end
 
 
 
 
 
 
 
 
 
 
local LocalTransparency = {Started = false}
local lpAppliedParts = {}    
local lpBots = {}            
local lpBotScanTimer = 0

local LP_PLAYER_OVERLAP_DISTANCE = 2     

 
 
 
local function lpHasOption(option)
    local v = Library and Library.Flags and Library.Flags["VisLocalPlayerTransparency"]
    if type(v) ~= "table" then
        return v == option
    end
    for _, item in ipairs(v) do
        if item == option then
            return true
        end
    end
    return false
end

local function lpPointInPart(part, point)
    local localPoint = part.CFrame:PointToObjectSpace(point)
    local half = part.Size * 0.5 + Vector3.new(0.1, 0.1, 0.1)
    return math.abs(localPoint.X) <= half.X
        and math.abs(localPoint.Y) <= half.Y
        and math.abs(localPoint.Z) <= half.Z
end

local function lpScanBots(deltaTime)
    lpBotScanTimer = lpBotScanTimer - (deltaTime or (1 / 60))
    if lpBotScanTimer > 0 then
        return
    end
    lpBotScanTimer = 0.5
    local bots = {}
    for _, bot in ipairs(Entity.GetNPCs()) do
        bots[bot] = true
    end
    lpBots = bots
end

 
 
 
local function lpShouldTransparent(deltaTime)
    local overlapOn = lpHasOption("Player overlap")
    local weaponOn = lpHasOption("Weapon")

    local character = LocalPlayer.Character
    if not character or not character.Parent then
        return false
    end

    if not overlapOn and not weaponOn then
        return false
    end

     
    if weaponOn and character:FindFirstChildOfClass("Tool") then
        return true
    end

    if not overlapOn then
        return false
    end

    local myRoot = findRootPart(character)

     
     
     
     
    local camera = Workspace.CurrentCamera
    if myRoot and camera then
        local camPos = camera.CFrame.Position
        for _, object in ipairs(Entity.GetParts(character)) do
            if object:IsA("BasePart")
                and object.Name ~= "Head"
                and object.Transparency < 1
                and not object:FindFirstAncestorOfClass("Tool")
                and lpPointInPart(object, camPos) then
                return true
            end
        end
    end

     
    if myRoot then
        local myPos = myRoot.Position
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and Entity.IsAlive(player) then
                local root = Entity.GetRootPart(player)
                if root and (root.Position - myPos).Magnitude < LP_PLAYER_OVERLAP_DISTANCE then
                    return true
                end
            end
        end
        lpScanBots(deltaTime)
        for bot in pairs(lpBots) do
            if bot.Parent then
                local root = findRootPart(bot)
                if root and (root.Position - myPos).Magnitude < LP_PLAYER_OVERLAP_DISTANCE then
                    return true
                end
            end
        end
    end

    return false
end

 
 
local function lpCollectBodyParts(character)
    local wanted = {}
    for _, object in ipairs(Entity.GetParts(character)) do
        if object:IsA("BasePart")
            and object.Transparency < 1
            and not object:FindFirstAncestorOfClass("Tool") then
            wanted[object] = true
        end
    end
    return wanted
end

 
 
 
 
 
local function lpClearApplied()
    for part, original in pairs(lpAppliedParts) do
        if part.Parent then
            part.LocalTransparencyModifier = original
        end
    end
    table.clear(lpAppliedParts)
end

local function lpApplyTransparency(character)
    local wanted = lpCollectBodyParts(character)

     
    for part, original in pairs(lpAppliedParts) do
        if not wanted[part] then
            if part.Parent then
                part.LocalTransparencyModifier = original
            end
            lpAppliedParts[part] = nil
        end
    end

     
     
     
    for part in pairs(wanted) do
        if lpAppliedParts[part] == nil then
            lpAppliedParts[part] = part.LocalTransparencyModifier
        end
        if part.LocalTransparencyModifier < LP_TRANSPARENCY then
            part.LocalTransparencyModifier = LP_TRANSPARENCY
        end
    end
end

local function lpTransparencyApply(deltaTime)
     
    local ok, shouldApply = pcall(lpShouldTransparent, deltaTime)
    local character = LocalPlayer.Character
    if not ok or shouldApply ~= true or not character or not character.Parent then
        localBodyTransparent = false
        lpClearApplied()
        return
    end
    localBodyTransparent = true
    lpApplyTransparency(character)
end

function LocalTransparency.Shutdown()
    pcall(function()
        RunService:UnbindFromRenderStep("GSLocalTransparency")
    end)
    TaskManager.RemoveConnection("LocalPlayerTransparency")
    localBodyTransparent = false
    lpClearApplied()
    LocalTransparency.Started = false
end

function LocalTransparency.Start()
    if LocalTransparency.Started then return end
    LocalTransparency.Started = true
     
     
    local ok = pcall(function()
        RunService:BindToRenderStep("GSLocalTransparency", 2000, lpTransparencyApply)
    end)
    if not ok then
        TaskManager.AddConnection("LocalPlayerTransparency", RunService.RenderStepped, lpTransparencyApply)
    end
    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, LocalTransparency.Shutdown)
    end
end

local function capture()
    local s = {blooms = {}}
    for _, k in ipairs(PROPS) do s[k] = Lighting[k] end
    local a = Lighting:FindFirstChildOfClass("Atmosphere")
    if a then
        s.atmo = a
        s.atmoProps = {Density = a.Density, Offset = a.Offset, Color = a.Color, Decay = a.Decay, Glare = a.Glare, Haze = a.Haze}
    end
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("BloomEffect") then
            s.blooms[#s.blooms + 1] = {child, child.Enabled}
        end
    end
    return s
end
local function restore()
    if not snap then return end
    for _, k in ipairs(PROPS) do pcall(function() Lighting[k] = snap[k] end) end
    if snap.atmo and snap.atmo.Parent then
        for k, v in pairs(snap.atmoProps) do snap.atmo[k] = v end
    end
    for _, b in ipairs(snap.blooms) do
        if b[1].Parent then b[1].Enabled = b[2] end
    end
    if cc then cc:Destroy() cc = nil end
    local leftover = Lighting:FindFirstChild("GS_WorldCorrection")
    if leftover then leftover:Destroy() end
    on, autoTime = false, true
end
local function killWeather()
    curWeather = -1
    boltT0 = nil
    if folder then folder:Destroy() end
    folder, anchor, emitters = nil, nil, {}
end
local function setCC(enabled, tint, br, contrast, sat)
    if not enabled then
        if cc and cc.Parent then
            cc.Enabled, cc.Brightness, cc.Contrast, cc.Saturation, cc.TintColor = false, 0, 0, 0, Color3.new(1, 1, 1)
        end
        return
    end
    if not (cc and cc.Parent) then
        cc = Lighting:FindFirstChild("GS_WorldCorrection")
        if not (cc and cc:IsA("ColorCorrectionEffect")) then
            cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "GS_WorldCorrection"
            cc.Parent = Lighting
        end
    end
    cc.Enabled, cc.TintColor, cc.Brightness, cc.Contrast, cc.Saturation = true, tint, br, contrast, sat
end
local function applyEmitter(e, d)
    if not e then return end
    if not d then
        e.Enabled, e.Rate = false, 0
        return
    end
    e.Texture = d.tex
    e.Color = CS(d.col)
    e.Size = typeof(d.size) == "NumberSequence" and d.size or NS(d.size)
    e.Transparency = typeof(d.trans) == "NumberSequence" and d.trans or NS(d.trans)
    e.Lifetime, e.Speed = d.life, d.spd
    e.SpreadAngle = d.spread or Vector2.zero
    e.Acceleration = d.acc or Vector3.zero
    e.Rotation = d.rot or NR(0)
    e.RotSpeed = d.spin or NR(0)
    e.EmissionDirection = Enum.NormalId[d.dir or "Top"]
    e.LightEmission = d.glow or 0.05
    e.LockedToPart = false
    e.Rate = d.rate or 0
    e.Enabled = (d.rate or 0) > 0
    pcall(function()
        e.Orientation = Enum.ParticleOrientation[d.look or "FacingCamera"]
    end)
end
local function ensureWeather()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    if folder and folder.Parent ~= cam then killWeather() end
    if anchor and anchor.Parent then return anchor end
    folder = Instance.new("Folder")
    folder.Name = "GS_WorldWeather"
    anchor = Instance.new("Part")
    anchor.Name = "GS_WeatherAnchor"
    anchor.Anchored, anchor.CanCollide, anchor.CanQuery, anchor.CanTouch = true, false, false, false
    anchor.CastShadow, anchor.Massless, anchor.Transparency = false, true, 1
    anchor.Size = Vector3.new(90, 2, 90)
    anchor.Parent = folder
    folder.Parent = cam
    for _, name in ipairs({"p", "v"}) do
        local e = Instance.new("ParticleEmitter")
        e.Name, e.Enabled, e.Parent = name, false, anchor
        emitters[name] = e
    end
    return anchor
end
local function setWeather(id)
    if id == curWeather and anchor and anchor.Parent then return end
    if id <= 0 then
        applyEmitter(emitters.p)
        applyEmitter(emitters.v)
        curWeather = 0
        boltT0 = nil
        return
    end
    if not ensureWeather() then return end
    local w = WEATHER[id]
    curWeather = id
    anchor.Size = w.size
    applyEmitter(emitters.p, w.p)
    applyEmitter(emitters.v, w.v)
    if w.thunder then boltNext = os.clock() + 1.5 end
end
local function lightning(now)
    if not boltT0 then
        if now < boltNext then return 0 end
        boltNext, boltT0 = now + 4 + math.random() * 9, now
    end
    local t = now - boltT0
    if t < 0.045 then return 1.25 end
    if t < 0.11 then return 0.12 end
    if t < 0.17 then return 1.65 end
    boltT0 = nil
    return 0
end
local function apply()
    if flag("VisWorldEnabled", false) ~= true then
        if on then
            setWeather(0)
            killWeather()
            restore()
        end
        return
    end
    snap = snap or capture()
    on = true
    local mode = flag("VisBrightnessMode", "Off")
    local ambient = flag("VisAmbientColor", rgb(128, 128, 128))
    local night = flag("VisBrightnessColor", rgb(60, 80, 140))
     
     
     
    local ambientStrength = 1 - pickerAlpha("VisAmbientColor")
    local nightStrength = 1 - pickerAlpha("VisBrightnessColor")
    local ambientIn = snap.Ambient:Lerp(ambient, ambientStrength)
    local ambientOut = snap.OutdoorAmbient:Lerp(ambient, ambientStrength)
    local hours = flag("VisTimeChanger", 0)
    local id = math.clamp(math.floor(flag("VisWeather", 0) + 0.5), 0, 5)
    local w = WEATHER[id]
    local white = Color3.new(1, 1, 1)
    if hours == 0 then
        if not autoTime then Lighting.ClockTime = snap.ClockTime autoTime = true end
    else
        autoTime = false
        Lighting.ClockTime = hours % 24
    end
    local tint, br, contrast, sat, useCC = white, 0, 0, 0, false
    if mode == "Fullbright" then
        Lighting.Brightness, Lighting.GlobalShadows = 2.6, false
        Lighting.Ambient = ambientIn
        Lighting.OutdoorAmbient = ambientOut:Lerp(white, 0.72)
        Lighting.ExposureCompensation = 0
        Lighting.ColorShift_Top, Lighting.ColorShift_Bottom = snap.ColorShift_Top, snap.ColorShift_Bottom
    elseif mode == "Night mode" then
        Lighting.Brightness, Lighting.GlobalShadows = 0.42, snap.GlobalShadows
        Lighting.Ambient = ambientIn:Lerp(night, 0.55 * nightStrength)
        Lighting.OutdoorAmbient = ambientOut:Lerp(night, 0.8 * nightStrength)
        Lighting.ColorShift_Top = snap.ColorShift_Top:Lerp(night, nightStrength)
        Lighting.ColorShift_Bottom = snap.ColorShift_Bottom:Lerp(night:Lerp(Color3.new(), 0.45), nightStrength)
        useCC, tint, br, contrast, sat = true, white:Lerp(night, nightStrength), -0.16, 0.1, -0.12
    else
        Lighting.Brightness, Lighting.GlobalShadows = snap.Brightness, snap.GlobalShadows
        Lighting.Ambient, Lighting.OutdoorAmbient = ambientIn, ambientOut
        Lighting.ExposureCompensation = snap.ExposureCompensation
        Lighting.ColorShift_Top, Lighting.ColorShift_Bottom = snap.ColorShift_Top, snap.ColorShift_Bottom
    end
    if w then
        Lighting.FogStart, Lighting.FogEnd, Lighting.FogColor = 0, w.fog, w.fogc
        useCC = true
        tint = tint:Lerp(w.tint, mode == "Night mode" and 0.45 or 0.7)
        br += w.ccb
        sat += w.ccs
    elseif mode == "Fullbright" then
        Lighting.FogStart, Lighting.FogEnd, Lighting.FogColor = 0, 1e6, snap.FogColor
    else
        Lighting.FogColor, Lighting.FogStart, Lighting.FogEnd = snap.FogColor, snap.FogStart, snap.FogEnd
    end
    if w and w.thunder then
        local flash = lightning(os.clock())
        if flash > 0 then
            useCC = true
            br += flash
            tint = tint:Lerp(white, math.clamp(flash, 0, 1))
            Lighting.OutdoorAmbient = Lighting.OutdoorAmbient:Lerp(white, math.clamp(flash, 0, 1))
        end
    else
        boltT0 = nil
    end
    setCC(useCC, tint, br, contrast, sat)
    if snap.atmo and snap.atmo.Parent then
        local a, p = snap.atmo, snap.atmoProps
        if not w then
            if mode == "Fullbright" then a.Density, a.Haze = 0, 0 else for k, v in pairs(p) do a[k] = v end end
        else
            a.Density, a.Haze = math.max(p.Density, w.atmo[1]), math.max(p.Haze, w.atmo[2])
            a.Color, a.Decay = w.atmo[3], w.atmo[4]
        end
    end
    for _, b in ipairs(snap.blooms) do
        if b[1].Parent then b[1].Enabled = mode ~= "Fullbright" and b[2] end
    end
    setWeather(id)
    if anchor and anchor.Parent then
        local cam = Workspace.CurrentCamera
        if cam then
            local pos = cam.CFrame.Position
            anchor.CFrame = CFrame.new(pos + Vector3.new(0, w and w.lift or 26, 0))
        end
    end
end
function World.Shutdown()
    pcall(function() RunService:UnbindFromRenderStep(STEP) end)
    TaskManager.RemoveConnection("WorldApply")
    setWeather(0)
    killWeather()
    restore()
end
function World.Start()
    snap = snap or capture()
    pcall(function() RunService:UnbindFromRenderStep(STEP) end)
    local ok = pcall(function()
        RunService:BindToRenderStep(STEP, Enum.RenderPriority.Last.Value + 10, apply)
    end)
    if not ok then
        TaskManager.AddConnection("WorldApply", RunService.RenderStepped, apply)
    end
    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, World.Shutdown)
    end
end
World.Start()
local Effects = {}
do
    local STEP = "GS_EffectsApply"
    local cam = Workspace.CurrentCamera
    local snapFOV = cam and cam.FieldOfView or 70
    local snapMode, snapMin, snapMax = LocalPlayer.CameraMode, LocalPlayer.CameraMinZoomDistance, LocalPlayer.CameraMaxZoomDistance
    local fovApplied, tpApplied = false, false
    local cache, touched, scanAcc = {}, {}, 0
    local bodyTransparency = {}
    local thirdpersonMode = nil
    local utilityZoomLocked = false
    local thirdPersonParams = RaycastParams.new()
    thirdPersonParams.FilterType = Enum.RaycastFilterType.Exclude
    local thirdPersonCharacter, thirdPersonCamera
    local WALLMAT = {}
    for _, name in ipairs({
        "Brick", "Concrete", "Cobblestone", "Rock", "Slate", "WoodPlanks",
        "Granite", "Marble", "Basalt", "Asphalt", "Pavement", "Limestone",
        "Sandstone", "Glacier", "Salt",
    }) do
        pcall(function() WALLMAT[Enum.Material[name]] = true end)
    end
    local weaponKinds = setmetatable({}, {__mode = "k"})
    local function classifyCombatWeapon(tool)
        local name = string.lower(tool.Name):gsub("[%s%p_]", "")
        local excluded = {
            "hammer", "киянка", "c4", "satchel", "satchelcharge",
            "explosive", "explosivecharge", "buildingplan", "builderplan",
            "buildplan", "blueprint", "строительныйплан", "rock", "stone",
            "pickaxe", "hatchet", "axe", "torch", "flashlight",
            "bandage", "medkit", "syringe", "food", "water", "wood",
        }
        for _, word in ipairs(excluded) do
            if name:find(word, 1, true) then return false end
        end
        for _, attributeName in ipairs({"IsWeapon", "Weapon", "Combat", "IsCombatWeapon"}) do
            local value = tool:GetAttribute(attributeName)
            if value == true then return true end
            if value == false and attributeName == "IsWeapon" then return false end
        end
        local weaponWords = {
            "weapon", "gun", "rifle", "pistol", "revolver", "smg", "shotgun",
            "sniper", "launcher", "bow", "crossbow", "nailgun", "ak", "lr",
            "mp5", "m39", "m249", "thompson", "python", "bolt", "semi",
            "eoka", "l96", "custom", "rocketlauncher",
        }
        for _, word in ipairs(weaponWords) do
            if name:find(word, 1, true) then return true end
        end
        for _, object in ipairs(tool:GetDescendants()) do
            local objectName = string.lower(object.Name):gsub("[%s%p_]", "")
            if objectName:find("muzzle", 1, true)
                or objectName:find("barrel", 1, true)
                or objectName:find("firepoint", 1, true)
                or objectName == "shoot"
                or objectName == "reload" then
                return true
            end
        end
        return false
    end
    local function isCombatWeaponEquipped()
        local character = LocalPlayer.Character
        local tool = character and character:FindFirstChildOfClass("Tool")
        if not tool then return false end
        local record = weaponKinds[tool]
        local now = os.clock()
        if not record or now >= record.Expires then
            record = {Value = classifyCombatWeapon(tool), Expires = now + 0.5}
            weaponKinds[tool] = record
        end
        return record.Value
    end
    local function restoreCamera()
        local current = Workspace.CurrentCamera
        if current and fovApplied then
            current.FieldOfView = snapFOV
        end
        fovApplied = false
        if tpApplied then
            pcall(function()
                LocalPlayer.CameraMode = snapMode
                LocalPlayer.CameraMinZoomDistance = snapMin
                LocalPlayer.CameraMaxZoomDistance = snapMax
            end)
        end
        tpApplied = false
    end
    local function restoreGlass()
        for part in pairs(touched) do
            if part.Parent then
                part.LocalTransparencyModifier = touched[part]
            end
        end
        table.clear(touched)
        table.clear(cache)
    end
    local function restoreOwnBody()
        for part, transparency in pairs(bodyTransparency) do
            if part.Parent then
                part.LocalTransparencyModifier = transparency
            end
        end
        table.clear(bodyTransparency)
    end
    local function forceOwnBodyVisible()
        local character = LocalPlayer.Character
        if not character then return end
        for _, object in ipairs(Entity.GetParts(character)) do
            if object:IsA("BasePart") and not object:FindFirstAncestorOfClass("Tool") then
                if bodyTransparency[object] == nil then
                    bodyTransparency[object] = object.LocalTransparencyModifier
                end
                if not localBodyTransparent then
                    object.LocalTransparencyModifier = 0
                end
            end
        end
    end
    local function classify(part)
        if not part:IsA("BasePart") or part.Transparency > 0.95 then return false end
        if part.Name:sub(1, 3) == "GS_" then return false end
        local model = part:FindFirstAncestorOfClass("Model")
        if model and Players:GetPlayerFromCharacter(model) then return false end
        local current = Workspace.CurrentCamera
        if current and part:IsDescendantOf(current) then return false end
        local s = part.Size
        local a, b, c = s.X, s.Y, s.Z
        if a > b then a, b = b, a end
        if b > c then b, c = c, b end
        if a > b then a, b = b, a end
        if WALLMAT[part.Material] or (part.CanCollide and b >= 8 and c >= 8) then
            return "wall"
        end
        return "prop"
    end
    local function scanTransparent()
        if flag("VisTransparent", false) ~= true then
            if next(touched) then restoreGlass() end
            return
        end
        local current = Workspace.CurrentCamera
        if not current then return end
        local walls = math.clamp(flag("VisTransparentWalls", 50) / 100, 0, 1)
        local props = math.clamp(flag("VisTransparentProps", 50) / 100, 0, 1)
        local found = {}
        local list = Workspace:GetPartBoundsInRadius(current.CFrame.Position, 180)
        for i = 1, #list do
            local part = list[i]
            local kind = cache[part]
            if kind == nil then
                kind = classify(part)
                cache[part] = kind
            end
            if kind then
                found[part] = true
                if touched[part] == nil then touched[part] = part.LocalTransparencyModifier end
                part.LocalTransparencyModifier = kind == "wall" and walls or props
            end
        end
        for part in pairs(touched) do
            if not found[part] then
                if part.Parent then part.LocalTransparencyModifier = touched[part] end
                touched[part] = nil
                cache[part] = nil
            end
        end
    end
    local function applyEffects(dt)
        local current = Workspace.CurrentCamera
        if not current then return end
        scanAcc += dt or 0
        if scanAcc >= 0.3 then
            scanAcc = 0
            scanTransparent()
        elseif flag("VisTransparent", false) == true then
            local walls = math.clamp(flag("VisTransparentWalls", 50) / 100, 0, 1)
            local props = math.clamp(flag("VisTransparentProps", 50) / 100, 0, 1)
            for part, kind in pairs(cache) do
                if kind and part.Parent then
                    part.LocalTransparencyModifier = kind == "wall" and walls or props
                end
            end
        end
        local thirdRequested = bindOn(flag("VisThirdperson", false) == true, "VisThirdpersonBind")
        local ownBodyVisible = flag("VisLocalPlayer", false) == true
            or flag("VisLocalPlayerFake", false) == true
            or thirdRequested
        if ownBodyVisible then
            forceOwnBodyVisible()
        else
            restoreOwnBody()
        end

        local combatWeapon = thirdRequested and isCombatWeaponEquipped()
        if thirdRequested then
            if not tpApplied then
                snapMode, snapMin, snapMax = LocalPlayer.CameraMode, LocalPlayer.CameraMinZoomDistance, LocalPlayer.CameraMaxZoomDistance
            end
            tpApplied = true
            local nextMode = combatWeapon and "weapon" or "distance"
            if thirdpersonMode ~= nextMode then
                thirdpersonMode = nextMode
                utilityZoomLocked = nextMode == "distance"
            end
            pcall(function()
                LocalPlayer.CameraMode = Enum.CameraMode.Classic
                if nextMode == "distance" and utilityZoomLocked then
                    local dist = math.clamp(flag("VisThirdpersonDistance", 10), 0.5, 128)
                    LocalPlayer.CameraMinZoomDistance = dist
                    LocalPlayer.CameraMaxZoomDistance = dist
                else
                    LocalPlayer.CameraMinZoomDistance = 0.5
                    LocalPlayer.CameraMaxZoomDistance = 128
                end
            end)
            if combatWeapon then
                local dist = math.clamp(flag("VisThirdpersonDistance", 10), 0.5, 128)
                if thirdPersonCharacter ~= LocalPlayer.Character or thirdPersonCamera ~= current then
                    thirdPersonCharacter, thirdPersonCamera = LocalPlayer.Character, current
                    local filter = {current}
                    if thirdPersonCharacter then filter[#filter + 1] = thirdPersonCharacter end
                    thirdPersonParams.FilterDescendantsInstances = filter
                end
                local hit = Workspace:Raycast(current.CFrame.Position, -current.CFrame.LookVector * dist, thirdPersonParams)
                current.CFrame *= CFrame.new(0, 0, hit and math.max(hit.Distance - 0.35, 0) or dist)
            end
        else
            thirdpersonMode = nil
            utilityZoomLocked = false
            if tpApplied then
                pcall(function()
                    LocalPlayer.CameraMode = snapMode
                    LocalPlayer.CameraMinZoomDistance = snapMin
                    LocalPlayer.CameraMaxZoomDistance = snapMax
                end)
                tpApplied = false
            end
        end
        local zoomOn = bindOn(flag("VisCameraZoom", false) == true, "VisCameraZoomBind")
        local fovOn = flag("VisFOVChangerEnabled", false) == true
        if zoomOn or fovOn then
            if not fovApplied then snapFOV = current.FieldOfView end
            fovApplied = true
            current.FieldOfView = zoomOn and flag("VisCameraZoomValue", 40) or flag("VisFOVChanger", 70)
        elseif fovApplied then
            current.FieldOfView = snapFOV
            fovApplied = false
        end
    end
    function Effects.Shutdown()
        pcall(function() RunService:UnbindFromRenderStep(STEP) end)
        TaskManager.RemoveConnection("EffectsApply")
        TaskManager.RemoveConnection("EffectsUtilityWheel")
        restoreOwnBody()
        restoreGlass()
        restoreCamera()
    end
    function Effects.Start()
        pcall(function() RunService:UnbindFromRenderStep(STEP) end)
        local ok = pcall(function()
            RunService:BindToRenderStep(STEP, Enum.RenderPriority.Last.Value + 11, applyEffects)
        end)
        if not ok then
            TaskManager.AddConnection("EffectsApply", RunService.RenderStepped, applyEffects)
        end
        TaskManager.AddConnection("EffectsUtilityWheel", UserInputService.InputChanged, function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseWheel then return end
            if flag("VisThirdperson", false) ~= true then return end
            if isCombatWeaponEquipped() then return end
            utilityZoomLocked = false
            pcall(function()
                LocalPlayer.CameraMinZoomDistance = 0.5
                LocalPlayer.CameraMaxZoomDistance = 128
            end)
        end)
        if Library then
            Library.UnloadHooks = Library.UnloadHooks or {}
            table.insert(Library.UnloadHooks, Effects.Shutdown)
        end
    end
end
Effects.Start()

