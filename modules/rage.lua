 

 
 
 
 
 
 
local BacktrackAim = {}
local BacktrackAimCache = {}    
local BacktrackAimByChar = {}   
local BacktrackAimHitboxes = {}  
local RageBot = {
    Started = false,
    Active = false,
    SilentOn = false,
    TargetPart = nil,
    TargetPosition = nil,
    LastFireTick = 0,
    OriginalCFrame = nil,
    FovCircle = nil,
    HooksInstalled = false,
    GameShoot = nil,           
    GameShootFn = nil,         
    GameShootHooked = false,   
    GameShootTried = false,    
}

local AntiAim = {
    Started = false,
    OriginalAutoRotate = nil,
    PinnedPosition = nil,    
    PinnedCharacter = nil,   
}

 
local aaJitterTicks = 0
local aaJitterFlip = false

local Hooks = {}
local cachedNPCs = {}
local npcScanTimer = 0

local function scanBots(deltaTime)
    npcScanTimer -= deltaTime or (1 / 60)
    if npcScanTimer > 0 then return end
    npcScanTimer = 0.5
    table.clear(cachedNPCs)
    for _, model in ipairs(Entity.GetNPCs()) do cachedNPCs[#cachedNPCs + 1] = model end
end

function RageBot.IsAimbotActive()
    local enabled = flag("AimbotEnabled", false) == true
    if not enabled then return false end
    local bind = flag("AimbotEnabledBind", nil)
    if type(bind) == "table" and bind.Key and bind.Key ~= "NONE" and bind.Key ~= "" then
        return bind.Active == true
    end
    return enabled
end

local function getScreenFOVRadius()
    local cam = Workspace.CurrentCamera
    local maxFOV = tonumber(flag("AimbotFOV", 90)) or 90
    maxFOV = math.clamp(maxFOV, 1, 180)
    if not cam then return maxFOV * 4 end
    local radFOV = math.rad(maxFOV / 2)
    local camFOV = math.clamp(cam.FieldOfView, 1, 120)
    local radCamFOV = math.rad(camFOV / 2)
    local radius = (math.tan(radFOV) / math.tan(radCamFOV)) * (cam.ViewportSize.Y / 2)
    return math.clamp(radius, 2, 4000)
end

local visibilityQueries = {{}, {}}
local function visibilityParams(camera, backtrack)
    local state = visibilityQueries[backtrack and 2 or 1]
    local character, folder = LocalPlayer.Character, Library and Library.Folder
    local ghostFolder = backtrack and Workspace:FindFirstChild("GS_BacktrackFolder") or nil
    if not state.Params then
        state.Params = RaycastParams.new()
        state.Params.FilterType = Enum.RaycastFilterType.Exclude
        state.Params.IgnoreWater = true
    end
    if state.Camera ~= camera or state.Character ~= character or state.Folder ~= folder or state.Ghost ~= ghostFolder then
        local filter = {camera}
        if character then filter[#filter + 1] = character end
        if folder then filter[#filter + 1] = folder end
        if ghostFolder then filter[#filter + 1] = ghostFolder end
        state.Params.FilterDescendantsInstances = filter
        state.Camera, state.Character, state.Folder, state.Ghost = camera, character, folder, ghostFolder
    end
    return state.Params
end

local function isPartVisible(cam, targetPart, targetPos, targetModel)
    local localChar = LocalPlayer.Character
    local origin = cam.CFrame.Position
    local dir = targetPos - origin

    local rayParams = visibilityParams(cam, false)

    local result = Workspace:Raycast(origin, dir, rayParams)
    if not result then
        return true
    end
    if result.Instance then
        if result.Instance == targetPart or result.Instance:IsDescendantOf(targetModel) then
            return true
        end
        if result.Instance.Transparency >= 0.85 or not result.Instance.CanCollide then
            if (result.Position - targetPos).Magnitude <= 2.0 then
                return true
            end
        end
    end
    return false
end

function RageBot.GetHitboxParts(model)
    local results = {}
    if not model then return results end

    local hitboxes = flag("AimbotHitbox", {"Head", "Chest"})
    if type(hitboxes) ~= "table" then
        hitboxes = {hitboxes}
    end
    if #hitboxes == 0 then
        hitboxes = {"Head", "Chest"}
    end

    local function hasHitbox(name)
        for _, h in ipairs(hitboxes) do
            if h == name then return true end
        end
        return false
    end

     
    if hasHitbox("Head") then
        local head = model:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
             
             
            local up = head.CFrame.UpVector
            local crown = head.CFrame.Position + up * (head.Size.Y * 0.5)
            table.insert(results, {Part = head, Position = crown, Name = "Head"})
        end
    end

    if hasHitbox("Neck") then
        local neck = model:FindFirstChild("Neck")
        if neck and neck:IsA("BasePart") then
            table.insert(results, {Part = neck, Position = neck.Position, Name = "Neck"})
        else
            local ut = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
            if ut and ut:IsA("BasePart") then
                table.insert(results, {Part = ut, Position = ut.Position + Vector3.new(0, ut.Size.Y * 0.45, 0), Name = "Neck"})
            end
        end
    end

    if hasHitbox("Chest") then
        local ut = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
        if ut and ut:IsA("BasePart") then
            table.insert(results, {Part = ut, Position = ut.Position, Name = "Chest"})
        end
    end

    if hasHitbox("Stomach") then
        local lt = model:FindFirstChild("LowerTorso")
        if lt and lt:IsA("BasePart") then
            table.insert(results, {Part = lt, Position = lt.Position, Name = "Stomach"})
        else
            local torso = model:FindFirstChild("Torso")
            if torso and torso:IsA("BasePart") then
                table.insert(results, {Part = torso, Position = torso.Position - Vector3.new(0, torso.Size.Y * 0.3, 0), Name = "Stomach"})
            end
        end
    end

    if hasHitbox("Legs") then
        for _, limb in ipairs({"LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "Left Leg", "Right Leg"}) do
            local p = model:FindFirstChild(limb)
            if p and p:IsA("BasePart") then
                table.insert(results, {Part = p, Position = p.Position, Name = "Legs"})
                break
            end
        end
    end

    if hasHitbox("Feet") then
        for _, limb in ipairs({"LeftFoot", "RightFoot", "Left Leg", "Right Leg"}) do
            local p = model:FindFirstChild(limb)
            if p and p:IsA("BasePart") then
                table.insert(results, {Part = p, Position = p.Position - Vector3.new(0, p.Size.Y * 0.4, 0), Name = "Feet"})
                break
            end
        end
    end

    if #results == 0 then
        local root = findRootPart(model)
        if root and root:IsA("BasePart") then
            table.insert(results, {Part = root, Position = root.Position, Name = "Root"})
        end
    end

    return results
end

 
 
 
local function btPosVisible(cam, pos)
    local localChar = LocalPlayer.Character
    local origin = cam.CFrame.Position
    local rayParams = visibilityParams(cam, true)
    local res = Workspace:Raycast(origin, pos - origin, rayParams)
    if not res then return true end
    local inst = res.Instance
    if inst and (inst.Transparency >= 0.85 or not inst.CanCollide) then
        return (res.Position - pos).Magnitude <= 2
    end
    return false
end

local function getClosestTarget()
    local camera = Workspace.CurrentCamera
    if not camera then return nil, nil end

    local maxFOV = getScreenFOVRadius() or 2000
    local closestDist = maxFOV
    local closestPart = nil
    local closestPos = nil
    local mousePos = UserInputService:GetMouseLocation()
    local visibleCheck = flag("AimbotVisibleCheck", false) == true
     
    local backtrackActive = next(BacktrackAim) ~= nil
     
     
    local needVis = visibleCheck or backtrackActive

    local targetSel = flag("AimbotTargetSel", {"Players"})
    if type(targetSel) ~= "table" then targetSel = {targetSel} end
    if #targetSel == 0 then targetSel = {"Players"} end

    local allowsPlayers = false
    local allowsTeam = false
    local allowsBots = false
    local allowsStructures = false
    for _, s in ipairs(targetSel) do
        if s == "Players" then allowsPlayers = true
        elseif s == "Team" then allowsTeam = true
        elseif s == "Bots" then allowsBots = true
        elseif s == "Structures" then allowsStructures = true end
    end

     
     
     
     
     
     
     
     

     
    if allowsPlayers or allowsTeam then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and Entity.IsAlive(player) then
                local isEnemy = Entity.IsEnemy(player)
                if (allowsPlayers and isEnemy) or (allowsTeam and not isEnemy) then
                    local char = player.Character
                    if char then
                        local hitboxes = RageBot.GetHitboxParts(char)
                        for _, hb in ipairs(hitboxes) do
                            local screenPos, onScreen = camera:WorldToViewportPoint(hb.Position)
                            if screenPos.Z > 0 then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                if dist <= closestDist then
                                    local isVis = true
                                    if needVis then
                                        isVis = isPartVisible(camera, hb.Part, hb.Position, char)
                                    end
                                    if isVis then
                                        closestDist = dist
                                        closestPart = hb.Part
                                        closestPos = hb.Position
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

     
    if allowsBots and #cachedNPCs > 0 then
        for _, npc in ipairs(cachedNPCs) do
            if Entity.IsAliveModel(npc) then
                local hitboxes = RageBot.GetHitboxParts(npc)
                for _, hb in ipairs(hitboxes) do
                    local screenPos, onScreen = camera:WorldToViewportPoint(hb.Position)
                    if screenPos.Z > 0 then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist <= closestDist then
                            local isVis = true
                            if needVis then
                                isVis = isPartVisible(camera, hb.Part, hb.Position, npc)
                            end
                            if isVis then
                                closestDist = dist
                                closestPart = hb.Part
                                closestPos = hb.Position
                                break
                            end
                        end
                    end
                end
            end
        end
    end

     
    if allowsStructures then
        local structures = Entity.GetStructures()
        for _, structure in ipairs(structures) do
            local targetPart = structure:FindFirstChild("HumanoidRootPart")
                or structure.PrimaryPart
                or structure:FindFirstChild("Head")
                or structure:FindFirstChildOfClass("BasePart")
            if targetPart and targetPart:IsA("BasePart") then
                local targetPos = targetPart.Position
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
                if screenPos.Z > 0 then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist <= closestDist then
                        local isVis = true
                        if needVis then
                            isVis = isPartVisible(camera, targetPart, targetPos, structure)
                        end
                        if isVis then
                            closestDist = dist
                            closestPart = targetPart
                            closestPos = targetPos
                        end
                    end
                end
            end
        end
    end

     
     
     
    if backtrackActive and not closestPart then
        local btFov = maxFOV
        local btDist = btFov
        local btPos = nil
        local btPart = nil
        for targetKey, cache in pairs(BacktrackAimCache) do
            local char = cache and cache.Character
            if char then
                local hits = BacktrackAimHitboxes[char]
                if hits and #hits > 0 then
                     
                    local isEnemyPlayer = false
                    local isBot = false
                    if typeof(targetKey) == "Instance" and targetKey:IsA("Player") then
                        isEnemyPlayer = targetKey ~= LocalPlayer and Entity.IsAlive(targetKey)
                    else
                        isBot = Entity.IsAliveModel(char)
                    end
                    local allowed = false
                    if isEnemyPlayer and allowsPlayers then
                        allowed = Entity.IsEnemy(targetKey)
                    elseif isEnemyPlayer and allowsTeam then
                        allowed = not Entity.IsEnemy(targetKey)
                    elseif isBot and allowsBots then
                        allowed = true
                    end
                    if allowed then
                         
                         
                        for _, hb in ipairs(hits) do
                            local screenPos, onScreen = camera:WorldToViewportPoint(hb.Position)
                            if onScreen and screenPos.Z > 0 then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                if dist <= btDist and btPosVisible(camera, hb.Position) then
                                    btDist = dist
                                    btPos = hb.Position
                                    btPart = findRootPart(char)  
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        if btPos then
            return btPart or nil, btPos, true  
        end
    end

    return closestPart, closestPos, false
end

function RageBot.AutoFire()
    local now = os.clock()
     
    if now - RageBot.LastFireTick < 0.001 then return end
    RageBot.LastFireTick = now

    pcall(function()
        if mouse1click then
            mouse1click()
        elseif mouse1press and mouse1release then
            mouse1press()
            task.delay(0.001, mouse1release)
        end
    end)
end

local function setupSilentAimHooks()
    if RageBot.HooksInstalled then return end
    if not (hookmetamethod and getrawmetatable and checkcaller and newcclosure) then return end

    pcall(function()
        local Mouse = LocalPlayer:GetMouse()

        Hooks.Namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Raycast" or method == "raycast" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" or method == "FindPartOnRay" or method == "findPartOnRayWithIgnoreList" or method == "findPartOnRayWithWhitelist" or method == "findPartOnRay" or method == "ViewportPointToRay" or method == "ScreenPointToRay" or method == "viewportPointToRay" or method == "screenPointToRay" then
                if not checkcaller() and RageBot.Active and RageBot.SilentOn and RageBot.TargetPosition then
                    local targetPos = RageBot.TargetPosition
                    local isWs = (self == Workspace or self.Name == "Workspace")
                    if isWs then
                        local args = { ... }
                        if method == "Raycast" or method == "raycast" then
                            local origin = args[1]
                            local direction = args[2]
                            if typeof(origin) == "Vector3" and (not direction or typeof(direction) ~= "Vector3" or direction.Magnitude >= 10) then
                                args[2] = (targetPos - origin).Unit * 1000
                                local result = Hooks.Namecall(self, table.unpack(args))
                                 
                                 
                                 
                                if result and result.Instance and result.Instance:IsA("BasePart") then
                                    pcall(spawnGhostOnHit, { result.Instance })
                                end
                                return result
                            end
                        else
                            local ray = args[1]
                            if typeof(ray) == "Ray" and ray.Direction.Magnitude >= 10 then
                                args[1] = Ray.new(ray.Origin, (targetPos - ray.Origin).Unit * 1000)
                                local res = { Hooks.Namecall(self, table.unpack(args)) }
                                 
                                local hitPart = res[1]
                                if typeof(hitPart) == "Instance" and hitPart:IsA("BasePart") then
                                    pcall(spawnGhostOnHit, { hitPart })
                                end
                                return table.unpack(res)
                            end
                        end
                    elseif self == Workspace.CurrentCamera or self.Name == "Camera" then
                local cam = Workspace.CurrentCamera
                        if cam then
                            return Ray.new(cam.CFrame.Position, (targetPos - cam.CFrame.Position).Unit)
                        end
                    end
                end
            end

            return Hooks.Namecall(self, ...)
        end))

        Hooks.Index = hookmetamethod(game, "__index", newcclosure(function(self, index)
            if self == Mouse then
                if not checkcaller() and RageBot.Active and RageBot.SilentOn and RageBot.TargetPosition and RageBot.TargetPart then
                    if index == "Hit" or index == "hit" then
                        return CFrame.new(RageBot.TargetPosition)
                    elseif index == "Target" or index == "target" then
                        return RageBot.TargetPart
                    elseif index == "UnitRay" or index == "unitRay" then
                local cam = Workspace.CurrentCamera
                        local origin = cam and cam.CFrame.Position or Vector3.zero
                        return Ray.new(origin, (RageBot.TargetPosition - origin).Unit)
                    end
                end
            end

            return Hooks.Index(self, index)
        end))

        RageBot.HooksInstalled = true
    end)
end

 
 
 
 
 
 
local ReposActive = {}   

local function clearReposActive()
    for model, saved in pairs(ReposActive) do
        pcall(function()
            if saved.Root and saved.Root.Parent then
                saved.Root.CFrame = saved.OldCFrame
            end
        end)
        ReposActive[model] = nil
    end
end

local function restoreReposModel(model)
    local saved = ReposActive[model]
    if not saved then return end
    ReposActive[model] = nil
    pcall(function()
        if saved.Root and saved.Root.Parent then
            saved.Root.CFrame = saved.OldCFrame
        end
    end)
end

 
local function snapshotModelCFrames(model)
    local out = {}
    for _, bp in ipairs(model:GetDescendants()) do
        if bp:IsA("BasePart") and not bp:FindFirstAncestorOfClass("Tool") then
            out[bp] = bp.CFrame
        end
    end
    return out
end

 
 
local function updateBacktrackReposition(targetPart, isShooting, isBacktrackShot)
    local reposTarget = nil
     
     
     
    if isShooting and isBacktrackShot and targetPart and targetPart.Parent then
        local model = targetPart:FindFirstAncestorOfClass("Model")
        if model and model ~= LocalPlayer.Character and BacktrackAimByChar[model] then
            reposTarget = model
        end
    end

     
    for model, saved in pairs(ReposActive) do
        if model ~= reposTarget then
            pcall(function()
                if saved.Root and saved.Root.Parent then
                    saved.Root.CFrame = saved.OldCFrame
                end
            end)
            ReposActive[model] = nil
        end
    end

    if reposTarget then
        local saved = ReposActive[reposTarget]
        local root = findRootPart(reposTarget)
        if root and root.Parent then
            local old = saved and saved.OldCFrame or root.CFrame
            local oldCFrames = saved and saved.OldCFrames or snapshotModelCFrames(reposTarget)
            local btPos = BacktrackAimByChar[reposTarget]
            if btPos then
                pcall(function()
                    root.CFrame = CFrame.new(btPos) * CFrame.Angles(0, old.Rotation.Z, 0)
                end)
            end
            ReposActive[reposTarget] = { Root = root, OldCFrame = old, OldCFrames = oldCFrames }
        end
    end
end

 
 
 
 
 
 
 
local function setupGameShootHook()
    if RageBot.GameShootHooked then return true end
    if RageBot.GameShootTried then return false end
    RageBot.GameShootTried = true
    if not (filtergc and hookfunction) then return false end

    pcall(function()
        local fn = filtergc("function", {Name = "shoot"}, true)
        if type(fn) ~= "function" then return end

        RageBot.GameShootFn = fn
        RageBot.GameShoot = hookfunction(fn, function(...)
            local cam = Workspace.CurrentCamera
            if RageBot.Active and RageBot.SilentOn and RageBot.TargetPosition and cam then
                local oldCFrame = cam.CFrame
                 
                 
                cam.CFrame = CFrame.lookAt(oldCFrame.Position, RageBot.TargetPosition)
                local result = RageBot.GameShoot(...)
                cam.CFrame = oldCFrame
                return result
            end
            return RageBot.GameShoot(...)
        end)
        RageBot.GameShootHooked = RageBot.GameShoot ~= nil
    end)
    return RageBot.GameShootHooked
end

function RageBot.UpdateRender(deltaTime)

    local masterEnabled = flag("AimbotEnabled", false) == true
    local active = RageBot.IsAimbotActive()
    local cam = Workspace.CurrentCamera

    RageBot.Active = active
    RageBot.SilentOn = flag("AimbotSilentAim", false) == true

     
    local visFOV = flag("AimbotVisFOV", false) == true
    if RageBot.FovCircle then
        if masterEnabled and visFOV and cam then
            local radius = getScreenFOVRadius()
            RageBot.FovCircle.Radius = radius
             
            local view = cam.ViewportSize
            RageBot.FovCircle.Position = Vector2.new(view.X * 0.5, view.Y * 0.5)
            RageBot.FovCircle.Visible = true
        else
            RageBot.FovCircle.Visible = false
        end
    end

    if not active or not cam then
        RageBot.TargetPart = nil
        RageBot.TargetPosition = nil
        RageBot.OriginalCFrame = nil
        clearReposActive()
        return
    end

    scanBots(deltaTime)
     
    local part, pos, isBtShot = getClosestTarget()
    RageBot.TargetPart = part
    RageBot.TargetPosition = pos
    RageBot.TargetIsBacktrack = isBtShot == true

    local isShooting = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or flag("AimbotAutoFire", false) == true

     
     
     
     
    updateBacktrackReposition(part, isShooting, RageBot.TargetIsBacktrack)

    if part and pos then
        if not RageBot.SilentOn then
             
            cam.CFrame = CFrame.new(cam.CFrame.Position, pos)
            RageBot.OriginalCFrame = nil
        else
             
             
             
             
             
            if RageBot.GameShootHooked then
                RageBot.OriginalCFrame = nil
            elseif isShooting then
                RageBot.OriginalCFrame = cam.CFrame
                cam.CFrame = CFrame.new(RageBot.OriginalCFrame.Position, pos)
            else
                RageBot.OriginalCFrame = nil
            end
        end

        if flag("AimbotAutoFire", false) == true then
            RageBot.AutoFire()
        end
    else
        RageBot.OriginalCFrame = nil
    end
end

function RageBot.UpdateHeartbeat(deltaTime)
     
    if RageBot.OriginalCFrame and Workspace.CurrentCamera then
        Workspace.CurrentCamera.CFrame = RageBot.OriginalCFrame
        RageBot.OriginalCFrame = nil
    end
end

function RageBot.Start()
    if RageBot.Started then return end
    RageBot.Started = true

    if Drawing and Drawing.new then
        pcall(function()
            local circle = Drawing.new("Circle")
            circle.Visible = false
            circle.Thickness = 1
            circle.NumSides = 64
            circle.Filled = false
            circle.Color = Color3.fromRGB(255, 255, 255)
            circle.Transparency = 1
            circle.ZIndex = 999
            RageBot.FovCircle = circle
        end)
    end

    setupSilentAimHooks()
    setupGameShootHook()
    TaskManager.AddConnection("RageBotRender", RunService.RenderStepped, RageBot.UpdateRender)
    TaskManager.AddConnection("RageBotHeartbeat", RunService.Heartbeat, RageBot.UpdateHeartbeat)

    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, RageBot.Shutdown)
    end
end

function RageBot.Shutdown()
    TaskManager.RemoveConnection("RageBotRender")
    TaskManager.RemoveConnection("RageBotHeartbeat")
    if RageBot.FovCircle then
        pcall(function() RageBot.FovCircle:Remove() end)
        RageBot.FovCircle = nil
    end
    if RageBot.OriginalCFrame and Workspace.CurrentCamera then
        Workspace.CurrentCamera.CFrame = RageBot.OriginalCFrame
        RageBot.OriginalCFrame = nil
    end
     
     
     
    if RageBot.GameShootHooked and RageBot.GameShootFn then
        pcall(function()
            hookfunction(RageBot.GameShootFn, RageBot.GameShoot)
        end)
    end
    RageBot.GameShoot = nil
    RageBot.GameShootFn = nil
    RageBot.GameShootHooked = false
    RageBot.GameShootTried = false
    RageBot.TargetPart = nil
    RageBot.TargetPosition = nil
    RageBot.Active = false
    RageBot.SilentOn = false
    RageBot.Started = false
     
    clearReposActive()
end

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
local RecoilKiller = {
    Started = false,
    ModRef = nil,      
    OldRecoil = nil,   
}

local function rkActive()
    return flag("AimbotAntiRecoil", false) == true
end

 
local function rkFindModule()
    if RecoilKiller.ModRef then
        return RecoilKiller.ModRef
    end
    local rs = game:GetService("ReplicatedStorage")
    local mod
    local blaster = rs and rs:FindFirstChild("Blaster")
    if blaster then
        local scripts = blaster:FindFirstChild("Scripts")
        if scripts then
            mod = scripts:FindFirstChild("CameraRecoiler")
        end
    end
    if not (mod and mod:IsA("ModuleScript")) then
        return nil
    end
    local ok, result = pcall(require, mod)
    if ok and type(result) == "table" and type(result.recoil) == "function" then
        RecoilKiller.ModRef = result
        return result
    end
    return nil
end

 
local function rkApply()
    local mod = rkFindModule()
    if not mod then
        return
    end
    if RecoilKiller.OldRecoil == nil then
        RecoilKiller.OldRecoil = mod.recoil
        mod.recoil = function(p1)
             
        end
    end
end

 
local function rkRestore()
    if RecoilKiller.ModRef and RecoilKiller.OldRecoil then
        RecoilKiller.ModRef.recoil = RecoilKiller.OldRecoil
    end
    RecoilKiller.OldRecoil = nil
end

local function rkUpdate()
    if rkActive() then
        rkApply()
    else
        rkRestore()
    end
end

function RecoilKiller.Start()
    if RecoilKiller.Started then return end
    RecoilKiller.Started = true
    TaskManager.AddConnection("RecoilKillerApply", RunService.RenderStepped, rkUpdate)
    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, RecoilKiller.Shutdown)
    end
end

function RecoilKiller.Shutdown()
    TaskManager.RemoveConnection("RecoilKillerApply")
    rkRestore()
    RecoilKiller.Started = false
end

 
 
 
 
 
 
 
 
 
 
 
 
 
local NoSpread = {
    Started = false,
    ToolCache = {},      
    LastTool = nil,
     
    RayModRef = nil,     
    OldRayDirections = nil,
    RaysPatched = false,
}

local NS_ATTR = "spread"
local NS_CLAMP = Vector2.new(0.0001, 0.0001)

local function nsActive()
    return flag("AimbotAntiSpread", false) == true
end

local function nsIsClampable(value)
     
    return typeof(value) == "Vector2" or type(value) == "table"
end

local function nsCollectHolders(tool)
    local holders = {}
    local function consider(inst)
        local ok, attrs = pcall(function() return inst:GetAttributes() end)
        if ok and attrs and attrs.spread ~= nil then
            holders[inst] = true
        end
    end
    consider(tool)
    for _, child in ipairs(tool:GetDescendants()) do
        consider(child)
    end
    return holders
end

local function nsRestoreTool(tool)
    local saved = NoSpread.ToolCache[tool]
    if not saved then return end
    for holder, original in pairs(saved) do
        pcall(function()
            if original == nil then
                holder:SetAttribute(NS_ATTR, nil)
            else
                holder:SetAttribute(NS_ATTR, original)
            end
        end)
    end
    NoSpread.ToolCache[tool] = nil
end

 
local function nsFindRayMod()
    if NoSpread.RayModRef then
        return NoSpread.RayModRef
    end
    local rs = game:GetService("ReplicatedStorage")
    local blaster = rs and rs:FindFirstChild("Blaster")
    if not blaster then return nil end
    local utility = blaster:FindFirstChild("Utility")
    if not utility then return nil end
    local mod = utility:FindFirstChild("getRayDirections")
    if not (mod and mod:IsA("ModuleScript")) then return nil end
    local ok, result = pcall(require, mod)
    if ok and type(result) == "function" then
        NoSpread.RayModRef = result
        return result
    end
    return nil
end

 
 
 
 
local function nsNoSpreadRays(cameraCFrame, rayCount, spreadRadians, seed)
    local dir = cameraCFrame.LookVector
    local out = {}
    for i = 1, (rayCount or 1) do
        out[i] = dir
    end
    return out
end

 
local function nsFindRayFn()
    if NoSpread.RayModRef then
        return NoSpread.RayModRef
    end
    if not (filtergc and hookfunction) then return nil end
    local fn = filtergc("function", {Name = "getRayDirections"}, true)
    if type(fn) == "function" then
        NoSpread.RayModRef = fn
        return fn
    end
    return nil
end

 
local function nsPatchRays()
    if NoSpread.RaysPatched then return end
    local fn = nsFindRayFn()
    if not fn then return end
    pcall(function()
        NoSpread.OldRayDirections = hookfunction(fn, nsNoSpreadRays)
        NoSpread.RaysPatched = NoSpread.OldRayDirections ~= nil
    end)
end

 
local function nsUnpatchRays()
    if not NoSpread.RaysPatched then return end
    pcall(function()
        hookfunction(NoSpread.RayModRef, NoSpread.OldRayDirections)
    end)
    NoSpread.OldRayDirections = nil
    NoSpread.RaysPatched = false
end

local function nsUpdate()
    local on = nsActive()

     
    if on then
        nsPatchRays()
    else
        nsUnpatchRays()
    end

    local char = LocalPlayer.Character
    local tool = on and char and char:FindFirstChildOfClass("Tool") or nil

     
    if NoSpread.LastTool and NoSpread.LastTool ~= tool then
        nsRestoreTool(NoSpread.LastTool)
    end
    NoSpread.LastTool = tool

    if not on or not tool then
        return
    end

     
    if not NoSpread.ToolCache[tool] then
        local saved = {}
        for holder in pairs(nsCollectHolders(tool)) do
            saved[holder] = holder:GetAttribute(NS_ATTR)
        end
        NoSpread.ToolCache[tool] = saved
    end

     
    local saved = NoSpread.ToolCache[tool]
    for holder in pairs(saved) do
        local current = holder:GetAttribute(NS_ATTR)
        if nsIsClampable(current) then
            local x, y = 0, 0
            if typeof(current) == "Vector2" then
                x, y = current.X, current.Y
            elseif type(current) == "table" then
                x, y = current.X or 0, current.Y or 0
            end
             
            if x ~= NS_CLAMP.X or y ~= NS_CLAMP.Y then
                pcall(function()
                    holder:SetAttribute(NS_ATTR, NS_CLAMP)
                end)
            end
        end
    end
end

function NoSpread.Start()
    if NoSpread.Started then return end
    NoSpread.Started = true
    TaskManager.AddConnection("NoSpreadApply", RunService.RenderStepped, nsUpdate)
    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, NoSpread.Shutdown)
    end
end

function NoSpread.Shutdown()
    TaskManager.RemoveConnection("NoSpreadApply")
    nsUnpatchRays()
    if NoSpread.LastTool then
        nsRestoreTool(NoSpread.LastTool)
        NoSpread.LastTool = nil
    end
    for tool in pairs(NoSpread.ToolCache) do
        nsRestoreTool(tool)
    end
    NoSpread.Started = false
end

 
 
 
 
 
 
 
 
 
 
 
 
local AirShot = {
    Started = false,
    ModuleRef = nil,    
    OldCanShoot = nil,  
    Patched = false,
}

local function airActive()
    return flag("AimbotAirShot", false) == true
end

local function airFindModule()
    if AirShot.ModuleRef then
        return AirShot.ModuleRef
    end
    local rs = game:GetService("ReplicatedStorage")
    local mod
    local blaster = rs and rs:FindFirstChild("Blaster")
    if blaster then
        local scripts = blaster:FindFirstChild("Scripts")
        if scripts then
            mod = scripts:FindFirstChild("BlasterController")
        end
    end
    if not (mod and mod:IsA("ModuleScript")) then
        return nil
    end
    local ok, result = pcall(require, mod)
    if ok and type(result) == "table" and type(result.canShoot) == "function" then
        AirShot.ModuleRef = result
        return result
    end
    return nil
end

 
 
local function airCanShootNoAir(self)
    local SprintController = _G.SprintController
    local sprinting = false
    if SprintController and SprintController.isSprinting then
        sprinting = SprintController.isSprinting()
    end
    local can = self:isHumanoidAlive()
    if can then
        can = self.equipped
        if can then
            can = false
            if 0 < self.ammo then
                can = not self.reloading
                if can then
                    can = self.canShootAfterEquip
                    if can then
                        can = not self.isWeaponBlocked
                        if can then
                            can = not sprinting
                        end
                    end
                end
            end
        end
    end
    return can
end

local function airApply()
    local mod = airFindModule()
    if not mod then
        return
    end
    if not AirShot.Patched then
        AirShot.OldCanShoot = mod.canShoot
        mod.canShoot = function(self, ...)
            if airActive() then
                return airCanShootNoAir(self)
            end
            return AirShot.OldCanShoot(self, ...)
        end
        AirShot.Patched = true
    end
end

local function airRestore()
    if AirShot.ModuleRef and AirShot.OldCanShoot then
        AirShot.ModuleRef.canShoot = AirShot.OldCanShoot
    end
    AirShot.OldCanShoot = nil
    AirShot.Patched = false
end

local function airUpdate()
    if airActive() then
        airApply()
    else
        airRestore()
    end
end

function AirShot.Start()
    if AirShot.Started then return end
    AirShot.Started = true
    TaskManager.AddConnection("AirShotApply", RunService.RenderStepped, airUpdate)
    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, AirShot.Shutdown)
    end
end

function AirShot.Shutdown()
    TaskManager.RemoveConnection("AirShotApply")
    airRestore()
    AirShot.Started = false
end

