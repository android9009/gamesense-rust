 

 
 
 
 
 
 
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
    local selected = flag("AimbotHitbox", {"Head","Chest"})
    if type(selected) ~= "table" then selected = {selected} end
    if #selected == 0 then selected = {"Head","Chest"} end
    local enabled = {}
    for _,name in ipairs(selected) do enabled[name] = true end
    local indexed
    local function part(name)
        local direct = model:FindFirstChild(name)
        if direct and direct:IsA("BasePart") then return direct end
        if not indexed then
            indexed = {}
            for _,candidate in ipairs(Entity.GetParts(model)) do
                if not candidate:FindFirstAncestorOfClass("Tool") and not candidate:FindFirstAncestorOfClass("Accessory") then
                    indexed[candidate.Name:lower():gsub("[%s%p]", "")] = candidate
                end
            end
        end
        return indexed[name:lower():gsub("[%s%p]", "")]
    end
    -- Resolve anatomy from present parts, not a fixed body size or one limb.
    -- This also handles partial/streamed rigs without requiring every R15 part.
    local upper, lower, torso = part("UpperTorso"),part("LowerTorso"),part("Torso")
    local function add(source,group,yFraction)
        if not source then return end
        local position = source.Position
        if yFraction and yFraction ~= 0 then
            position = position + source.CFrame.UpVector*(source.Size.Y*yFraction)
        end
        results[#results+1] = {Part=source,Position=position,Name=group}
    end
    if enabled.Head then add(part("Head"),"Head",.5) end
    if enabled.Neck then
        local neck=part("Neck")
        add(neck or upper or torso,"Neck",neck and 0 or .45)
    end
    if enabled.Chest then add(upper or torso or lower,"Chest") end
    if enabled.Stomach then add(lower or torso or upper,"Stomach",lower and 0 or -.3) end
    if enabled.Legs then
        for _,side in ipairs({"Left","Right"}) do
            local top,bottom=part(side.."UpperLeg"),part(side.."LowerLeg")
            if top or bottom then
                add(top,"Legs");add(bottom,"Legs")
            else
                add(part(side.." Leg"),"Legs")
            end
        end
    end
    if enabled.Feet then
        for _,side in ipairs({"Left","Right"}) do
            local foot=part(side.."Foot")
            add(foot or part(side.."LowerLeg") or part(side.." Leg"),"Feet",foot and 0 or -.4)
        end
    end
    if #results == 0 then
        local root=findRootPart(model)
        if root and root:IsA("BasePart") then add(root,"Root") end
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
    -- Выбор таргета по ФОВу: опорная точка - ПРИЦЕЛ (центр экрана), а не курсор.
    -- Круг FOV рисуется в центре экрана, поэтому и ближайшей считается цель,
    -- чей хитбокс ближе всего к центру. Стреляем всегда в неё.
    local viewSize = camera.ViewportSize
    local mousePos = Vector2.new(viewSize.X * 0.5, viewSize.Y * 0.5)
    local expandedRay = RageBot.ExpandedParts and next(RageBot.ExpandedParts)
        and camera:ScreenPointToRay(mousePos.X, mousePos.Y) or nil
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
                            local selectionPoint = RageBot.GetExpandedAimPoint(hb.Part, hb.Position, expandedRay)
                            hb.Position = RageBot.GetHitboxShotPoint(hb.Part, hb.Position)
                            local screenPos, onScreen = camera:WorldToViewportPoint(selectionPoint)
                            if screenPos.Z > 0 then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                if dist <= closestDist then
                                    local isVis = true
                                    if needVis then
                                        local visiblePoint = RageBot.ResolveVisibleHitbox(camera,hb.Part,hb.Position,char,selectionPoint,mousePos,closestDist)
                                        isVis = visiblePoint ~= nil
                                        if visiblePoint then
                                            hb.Position = visiblePoint
                                        end
                                    end
                                    if isVis then
                                        closestDist = dist
                                        closestPart = hb.Part
                                        closestPos = hb.Position
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
                    local selectionPoint = RageBot.GetExpandedAimPoint(hb.Part, hb.Position, expandedRay)
                    hb.Position = RageBot.GetHitboxShotPoint(hb.Part, hb.Position)
                    local screenPos, onScreen = camera:WorldToViewportPoint(selectionPoint)
                    if screenPos.Z > 0 then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist <= closestDist then
                            local isVis = true
                            if needVis then
                                local visiblePoint = RageBot.ResolveVisibleHitbox(camera,hb.Part,hb.Position,npc,selectionPoint,mousePos,closestDist)
                                isVis = visiblePoint ~= nil
                                if visiblePoint then
                                    hb.Position = visiblePoint
                                end
                            end
                            if isVis then
                                closestDist = dist
                                closestPart = hb.Part
                                closestPos = hb.Position
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
                local selectionPoint = RageBot.GetExpandedAimPoint(targetPart, targetPart.Position, expandedRay)
                local targetPos = RageBot.GetHitboxShotPoint(targetPart, targetPart.Position)
                local screenPos, onScreen = camera:WorldToViewportPoint(selectionPoint)
                if screenPos.Z > 0 then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist <= closestDist then
                        local isVis = true
                        if needVis then
                            local visiblePoint = RageBot.ResolveVisibleHitbox(camera,targetPart,targetPos,structure,selectionPoint,mousePos,closestDist)
                            isVis = visiblePoint ~= nil
                            if visiblePoint then
                                targetPos = visiblePoint
                            end
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

local function autoInputPaused()
    -- Read the actual GUI state, not the old menuOpen/global flag.
    local window = Library and Library.Window
    if not window or not window.Parent or window.Visible ~= true then return false end
    return not Library.Items or Library.Items.Enabled ~= false
end

function RageBot.AutoFire()
    if autoInputPaused() then return end
    local now = os.clock()
     
    if now - RageBot.LastFireTick < 0.001 then return end
    RageBot.LastFireTick = now

    pcall(function()
        if mouse1click then
            mouse1click()
        elseif mouse1press and mouse1release then
            -- Complete the synthetic click here; no delayed release can land on a newly opened menu.
            mouse1press()
            mouse1release()
        end
    end)
end

-- НОРМАЛЬНЫЙ БЕКТРЕК: модель цели переносится в позицию призрака ТОЛЬКО на время
-- самого выстрела (вызов shoot / рейкаст выстрела) и сразу возвращается обратно.
-- Удержания на время зажатой стрельбы больше нет: из-за него призрак залипал
-- в одной точке, а история добивалась копиями замороженной позы и уезжала
-- глубже заданных миллисекунд.
local function beginBacktrackShot()
    if not (RageBot.Active and RageBot.TargetIsBacktrack) then return nil end
    local part = RageBot.TargetPart
    if not (part and part.Parent) then return nil end
    local model = part:FindFirstAncestorOfClass("Model")
    if not model or model == LocalPlayer.Character then return nil end
    local btPos = BacktrackAimByChar[model]
    if not btPos then return nil end
    local root = findRootPart(model)
    if not (root and root.Parent) then return nil end
    local saved = { Root = root, OldCFrame = root.CFrame, OldCFrames = {} }
    for _, bp in ipairs(model:GetDescendants()) do
        if bp:IsA("BasePart") and not bp:FindFirstAncestorOfClass("Tool") then
            saved.OldCFrames[bp] = bp.CFrame
        end
    end
    local ok = pcall(function()
        root.CFrame = CFrame.new(btPos) * CFrame.Angles(0, saved.OldCFrame.Rotation.Z, 0)
    end)
    if not ok then return nil end
    return saved
end

local function endBacktrackShot(saved)
    if not saved then return end
    pcall(function()
        if saved.Root and saved.Root.Parent then
            saved.Root.CFrame = saved.OldCFrame
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
                                local repos = beginBacktrackShot()
                                local result = Hooks.Namecall(self, table.unpack(args))
                                endBacktrackShot(repos)
                                -- on-shot: по факту попадания (любая часть тела)
                                -- спавним гоуст — берём реальный результат рейкаста игры,
                                -- а не серверные remote'ы (те только про туловище).
                                if result and result.Instance and result.Instance:IsA("BasePart") then
                                    pcall(spawnGhostOnHit, { result.Instance })
                                end
                                return result
                            end
                        else
                            local ray = args[1]
                            if typeof(ray) == "Ray" and ray.Direction.Magnitude >= 10 then
                                args[1] = Ray.new(ray.Origin, (targetPos - ray.Origin).Unit * 1000)
                                local repos = beginBacktrackShot()
                                local res = { Hooks.Namecall(self, table.unpack(args)) }
                                endBacktrackShot(repos)
                                -- on-shot: FindPartOnRay возвращает часть первым значением
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

 
 
 
 
 
 
 
 
 
 
-- Silent aim через хук РЕАЛЬНОЙ функции shoot игры (как в отдельном скрипте):
-- ищем функцию по имени через filtergc и подменяем её hookfunction'ом.
-- В момент выстрела игра сама вызывает shoot -> мы на время вызова разворачиваем
-- камеру на цель, стреляем, возвращаем камеру обратно. Работает бесшумно
-- и независимо от того, как игра стреляет (remote / raycast / мгновенно).
-- Если filtergc/hookfunction недоступны или функция не найдена —
-- молча откатываемся на старый вариант (1-tick flick камерой).
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
            local repos = beginBacktrackShot()
            if RageBot.Active and RageBot.SilentOn and RageBot.TargetPosition and cam then
                local oldCFrame = cam.CFrame
                -- Silent aim: наводим камеру на цель (цель — живой противник или
                -- позиция призрака бектрека)
                cam.CFrame = CFrame.lookAt(oldCFrame.Position, RageBot.TargetPosition)
                local result = RageBot.GameShoot(...)
                cam.CFrame = oldCFrame
                endBacktrackShot(repos)
                return result
            end
            local result = RageBot.GameShoot(...)
            endBacktrackShot(repos)
            return result
        end)
        RageBot.GameShootHooked = RageBot.GameShoot ~= nil
    end)
    return RageBot.GameShootHooked
end

function RageBot.UpdateRender(deltaTime)

    local masterEnabled = flag("AimbotEnabled", false) == true
    local active = not autoInputPaused() and RageBot.IsAimbotActive()
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
        if RageBot.OriginalCFrame and cam then cam.CFrame = RageBot.OriginalCFrame end
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

     
     
     
     

    if part and pos then
        if not RageBot.SilentOn then
            cam.CFrame = CFrame.new(cam.CFrame.Position, pos)
            RageBot.OriginalCFrame = nil
        elseif RageBot.GameShootHooked then
            -- Выстрелы перехватывает хук shoot: он наводится в момент выстрела,
            -- камера в кадре не дёргается.
            RageBot.OriginalCFrame = nil
        elseif isShooting then
            -- Фолбэк: 1-tick flick - наводимся в RenderStepped, камеру вернёт
            -- UpdateHeartbeat после обработки кадра оружием.
            RageBot.OriginalCFrame = cam.CFrame
            cam.CFrame = CFrame.new(RageBot.OriginalCFrame.Position, pos)
        else
            RageBot.OriginalCFrame = nil
        end

        if flag("AimbotAutoFire", false) == true then
            RageBot.AutoFire()
        end
    else
        RageBot.OriginalCFrame = nil
    end
end

function RageBot.UpdateHeartbeat(deltaTime)
    -- Restore original camera orientation immediately after weapon scripts processed the frame
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
    NextPatch = 0,
    NextRestore = 0,
    LastError = nil,
}

local NS_ATTR = "spread"
local NS_CLAMP = Vector2.new(0.0001, 0.0001)

local function nsActive()
    return NoSpread.Started and flag("AimbotAntiSpread", false) == true
end

local function nsIsClampable(value)
     
    return typeof(value) == "Vector2" or type(value) == "table" or type(value) == "number"
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
    if not nsActive() and NoSpread.OldRayDirections then
        return NoSpread.OldRayDirections(cameraCFrame, rayCount, spreadRadians, seed)
    end
    local dir = cameraCFrame.LookVector
    local out = {}
    for i = 1, (rayCount or 1) do
        out[i] = dir
    end
    return out
end

 
local function nsFindRayFn()
    if NoSpread.RayModRef then return NoSpread.RayModRef end
    if filtergc then
        local ok, fn = pcall(filtergc, "function", {Name = "getRayDirections"}, true)
        if ok and type(fn) == "function" then NoSpread.RayModRef = fn; return fn end
    end
    return nsFindRayMod()
end
local function nsPatchRays()
    if NoSpread.RaysPatched or os.clock() < NoSpread.NextPatch then return end
    NoSpread.NextPatch = os.clock() + 0.5
    if type(hookfunction) ~= "function" then NoSpread.LastError = "hookfunction unavailable: attribute-only fallback"; return end
    local fn = nsFindRayFn()
    if not fn then NoSpread.LastError = "getRayDirections not found"; return end
    local ok, original = pcall(hookfunction, fn, nsNoSpreadRays)
    if ok and type(original) == "function" then
        NoSpread.OldRayDirections, NoSpread.RaysPatched = original, true
        NoSpread.LastError = nil
    else
        NoSpread.LastError = ok and "hookfunction did not return the original function" or tostring(original)
    end
end
local function nsUnpatchRays()
    if not NoSpread.RaysPatched or os.clock() < NoSpread.NextRestore then return end
    NoSpread.NextRestore = os.clock() + 0.5
    local ok, err = pcall(hookfunction, NoSpread.RayModRef, NoSpread.OldRayDirections)
    if not ok then
        -- Keep the original reference: the installed callback can still delegate
        -- when the checkbox is off, even if this executor cannot unhook now.
        NoSpread.LastError = "Unhook failed: " .. tostring(err)
        return
    end
    NoSpread.OldRayDirections, NoSpread.RaysPatched = nil, false
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
        if holder.Parent then
            local current = holder:GetAttribute(NS_ATTR)
            if nsIsClampable(current) then
                local desired = type(current) == "number" and 0.0001 or NS_CLAMP
                local differs = type(current) == "number" and current ~= desired
                    or (type(current) ~= "number" and (current.X ~= NS_CLAMP.X or current.Y ~= NS_CLAMP.Y))
                if differs then pcall(holder.SetAttribute, holder, NS_ATTR, desired) end
            end
        end
    end
end

function NoSpread.Status()
    local holders = 0
    for _, saved in pairs(NoSpread.ToolCache) do for _ in pairs(saved) do holders += 1 end end
    local result = {Enabled = nsActive(), RayHooked = NoSpread.RaysPatched,
        AttributeHolders = holders, HookAvailable = type(hookfunction) == "function", LastError = NoSpread.LastError}
    print(string.format("[NoSpread] enabled=%s rayHooked=%s holders=%d error=%s",
        tostring(result.Enabled), tostring(result.RayHooked), holders, tostring(result.LastError)))
    return result
end

function NoSpread.Start()
    if NoSpread.Started then return end
    NoSpread.Started = true
    NoSpread.NextPatch, NoSpread.NextRestore = 0, 0
    TaskManager.AddConnection("NoSpreadApply", RunService.RenderStepped, nsUpdate)
    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, NoSpread.Shutdown)
    end
end

function NoSpread.Shutdown()
    NoSpread.Started = false
    TaskManager.RemoveConnection("NoSpreadApply")
    NoSpread.NextRestore = 0
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


local RapidFire = {
    Started = false,
    ToolCache = {},
    LastTool = nil,
    Attr = "rateOfFire",
}

function RapidFire.IsActive()
    return RapidFire.Started and flag("AimbotRapidFire", false) == true
end

function RapidFire.Desired()
    local value = tonumber(flag("AimbotRapidFireValue", 1200))
    if not value or value ~= value or math.abs(value) == math.huge then
        return 1200
    end
    return math.clamp(math.floor(value + 0.5), 500, 3000)
end

function RapidFire.Coerce(raw, desired)
    if typeof(raw) == "Vector2" then
        return Vector2.new(desired, desired)
    end
    if typeof(raw) == "Vector3" then
        return Vector3.new(desired, desired, desired)
    end
    if type(raw) == "string" then
        return tostring(desired)
    end
    if type(raw) == "boolean" then
        return desired ~= 0
    end
    return desired
end

function RapidFire.Read(record)
    local ok, value = pcall(function()
        if record.Kind == "value" then
            return record.Inst.Value
        end
        return record.Inst:GetAttribute(record.Attr)
    end)
    if ok then
        return value
    end
    return nil
end

function RapidFire.Write(record, value)
    if not record or not record.Inst or not record.Inst.Parent then
        return
    end
    if RapidFire.Read(record) == value then
        return
    end
    pcall(function()
        if record.Kind == "value" then
            record.Inst.Value = value
        else
            record.Inst:SetAttribute(record.Attr, value)
        end
    end)
end

function RapidFire.Collect(tool)
    local records = {}
    local function consider(inst)
        local ok, value = pcall(function()
            return inst:GetAttribute(RapidFire.Attr)
        end)
        if ok and value ~= nil then
            records[#records + 1] = {Inst = inst, Attr = RapidFire.Attr, Kind = "attribute", Original = value}
            return
        end
        if (inst:IsA("NumberValue") or inst:IsA("IntValue") or inst:IsA("StringValue") or inst:IsA("BoolValue"))
            and inst.Name == RapidFire.Attr then
            records[#records + 1] = {Inst = inst, Attr = RapidFire.Attr, Kind = "value", Original = inst.Value}
        end
    end
    consider(tool)
    for _, descendant in ipairs(tool:GetDescendants()) do
        consider(descendant)
    end
    return records
end

function RapidFire.RestoreTool(tool)
    local records = RapidFire.ToolCache[tool]
    if not records then
        return
    end
    for _, record in ipairs(records) do
        RapidFire.Write(record, record.Original)
    end
    RapidFire.ToolCache[tool] = nil
end

function RapidFire.RestoreAll()
    if RapidFire.LastTool then
        RapidFire.RestoreTool(RapidFire.LastTool)
        RapidFire.LastTool = nil
    end
    local tools = {}
    for tool in pairs(RapidFire.ToolCache) do
        tools[#tools + 1] = tool
    end
    for _, tool in ipairs(tools) do
        RapidFire.RestoreTool(tool)
    end
end

function RapidFire.Update()
    local on = RapidFire.IsActive()
    local character = LocalPlayer and LocalPlayer.Character
    local tool = on and character and character:FindFirstChildOfClass("Tool") or nil
    if RapidFire.LastTool and RapidFire.LastTool ~= tool then
        RapidFire.RestoreTool(RapidFire.LastTool)
    end
    RapidFire.LastTool = tool
    if not on or not tool then
        return
    end
    local records = RapidFire.ToolCache[tool]
    if not records then
        records = RapidFire.Collect(tool)
        RapidFire.ToolCache[tool] = records
    end
    local desired = RapidFire.Desired()
    for _, record in ipairs(records) do
        RapidFire.Write(record, RapidFire.Coerce(record.Original, desired))
    end
end

function RapidFire.Status()
    return {
        Enabled = RapidFire.IsActive(),
        Value = RapidFire.Desired(),
        Tool = RapidFire.LastTool,
    }
end

function RapidFire.Start()
    if RapidFire.Started then return end
    RapidFire.Started = true
    TaskManager.AddConnection("RapidFireApply", RunService.RenderStepped, RapidFire.Update)
    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, RapidFire.Shutdown)
    end
end

function RapidFire.Shutdown()
    TaskManager.RemoveConnection("RapidFireApply")
    RapidFire.RestoreAll()
    RapidFire.Started = false
end


local HitboxExpander = {Started = false, Records = {}}
RageBot.ExpandedParts = HitboxExpander.Records
do
    local elapsed = 0.1
    local function dot(a, b) return a.X*b.X + a.Y*b.Y + a.Z*b.Z end
    local function slab(offset, velocity, half, lo, hi)
        if math.abs(velocity) < 1e-8 then
            if math.abs(offset) > half then return nil end
            return lo, hi
        end
        local a, b = (-half-offset)/velocity, (half-offset)/velocity
        if a > b then a, b = b, a end
        lo, hi = math.max(lo, a), math.min(hi, b)
        if lo > hi then return nil end
        return lo, hi
    end
    function HitboxExpander.Intersect(origin, direction, cf, size)
        local length = direction.Magnitude
        if length < 1e-6 then return nil end
        local unit, delta = direction * (1/length), origin-cf.Position
        local lo, hi = slab(dot(delta,cf.RightVector),dot(unit,cf.RightVector),size.X*.5,0,length)
        if not lo then return nil end
        lo, hi = slab(dot(delta,cf.UpVector),dot(unit,cf.UpVector),size.Y*.5,lo,hi)
        if not lo then return nil end
        return slab(dot(delta,cf.LookVector),dot(unit,cf.LookVector),size.Z*.5,lo,hi)
    end
    function RageBot.GetExpandedAimPoint(part, fallback, ray)
        local record = HitboxExpander.Records[part]
        if not HitboxExpander.Started or flag("AimbotReach",false) ~= true or not record or not ray
            or (tonumber(flag("AimbotReachValue",5)) or 0) <= 0 then return fallback end
        local magnitude = ray.Direction.Magnitude
        if magnitude < 1e-6 then return fallback end
        local unit = ray.Direction * (1/magnitude)
        local lo, hi = HitboxExpander.Intersect(ray.Origin, unit*10000, part.CFrame, record.ExpandedSize)
        if lo then
            -- Virtual selection point only; actual shots go to the real part.
            return ray.Origin + unit*(lo+math.min(.01,(hi-lo)*.5))
        end
        -- Score nearby cursor rays against the virtual oriented box.
        local offset = ray.Origin + unit*math.max(0,dot(part.Position-ray.Origin,unit)) - part.Position
        local half = record.ExpandedSize*.5
        local x,y,z = math.max(0,half.X-.01),math.max(0,half.Y-.01),math.max(0,half.Z-.01)
        local cf = part.CFrame
        return part.Position + cf.RightVector*math.clamp(dot(offset,cf.RightVector),-x,x)
            + cf.UpVector*math.clamp(dot(offset,cf.UpVector),-y,y)
            + cf.LookVector*math.clamp(dot(offset,cf.LookVector),-z,z)
    end
    local sampleOffsets = {
        Vector3.new(0,0,0), Vector3.new(1,0,0), Vector3.new(-1,0,0),
        Vector3.new(0,1,0), Vector3.new(0,-1,0), Vector3.new(0,0,1), Vector3.new(0,0,-1),
        Vector3.new(1,1,1), Vector3.new(1,1,-1), Vector3.new(1,-1,1), Vector3.new(1,-1,-1),
        Vector3.new(-1,1,1), Vector3.new(-1,1,-1), Vector3.new(-1,-1,1), Vector3.new(-1,-1,-1)
    }
    function RageBot.ResolveVisibleHitbox(cam, part, fallback, model, preferred, mousePos, maxDistance)
        local record = HitboxExpander.Started and flag("AimbotReach",false) == true
            and flag("AimbotVisibleCheck",false) == true
            and (tonumber(flag("AimbotReachValue",5)) or 0) > 0 and HitboxExpander.Records[part]
        if not record then return isPartVisible(cam,part,fallback,model) and fallback or nil end
        -- FOV belongs to the expanded selection region, not the final body point.
        local projected = cam:WorldToViewportPoint(preferred)
        if projected.Z <= 0 or (Vector2.new(projected.X,projected.Y)-mousePos).Magnitude > maxDistance then return nil end
        local origin, params = cam.CFrame.Position, visibilityParams(cam,false)
        local function reachesBody(point)
            local result = Workspace:Raycast(origin,point-origin,params)
            -- No result is EMPTY SPACE, not proof of a character hit.
            return result and result.Instance and (result.Instance==part or result.Instance:IsDescendantOf(model))
        end
        local now, cached = os.clock(), record.VisibleCache
        if cached and now < cached.Until and cached.Camera==cam.CFrame and cached.Frame==part.CFrame
            and cached.Size==part.Size then
            if not cached.Point then return nil end
            if reachesBody(cached.Point) then return cached.Point end
        end
        local point
        if reachesBody(part.Position) then
            point=part.Position
        else
            local candidates,half,cf = {},part.Size*.4,part.CFrame
            for _,offset in ipairs(sampleOffsets) do
                if offset.X~=0 or offset.Y~=0 or offset.Z~=0 then
                    local sample=cf.Position + cf.RightVector*(offset.X*half.X) + cf.UpVector*(offset.Y*half.Y)
                        + cf.LookVector*(offset.Z*half.Z)
                    local screen=cam:WorldToViewportPoint(sample)
                    if screen.Z>0 then
                        candidates[#candidates+1]={Point=sample,Distance=(Vector2.new(screen.X,screen.Y)-mousePos).Magnitude}
                    end
                end
            end
            table.sort(candidates,function(a,b)return a.Distance<b.Distance end)
            for _,sample in ipairs(candidates) do
                if reachesBody(sample.Point) then point=sample.Point;break end
            end
        end
        record.VisibleCache={Until=now+.05,Camera=cam.CFrame,Frame=part.CFrame,Size=part.Size,Point=point}
        return point
    end
    local function selection(value, fallback)
        if type(value) ~= "table" then value = {value} end
        if #value == 0 then value = fallback end
        local set = {}
        for _, name in ipairs(value) do set[name] = true end
        return set
    end
    function HitboxExpander.Restore()
        table.clear(HitboxExpander.Records)
    end
    function RageBot.GetOriginalHitboxSize(part) return part.Size end
    function RageBot.GetHitboxShotPoint(part, fallback)
        if HitboxExpander.Started and flag("AimbotReach",false) == true
            and (tonumber(flag("AimbotReachValue",5)) or 0) > 0 and HitboxExpander.Records[part] then
            return part.Position
        end
        return fallback
    end
    function HitboxExpander.Step()
        local amount = math.clamp(tonumber(flag("AimbotReachValue", 5)) or 0, 0, 30)
        if flag("AimbotReach", false) ~= true or amount <= 0 then
            HitboxExpander.Restore()
            return
        end
        local allowed = selection(flag("AimbotTargetSel", {"Players"}), {})
        local wanted = {}
        local function add(part)
            if part and part:IsA("BasePart") and part.Parent then wanted[part] = true end
        end
        local function body(model)
            if model == LocalPlayer.Character or not Entity.IsAliveModel(model) then return end
            for _, hitbox in ipairs(RageBot.GetHitboxParts(model)) do add(hitbox.Part) end

        end
        if allowed.Players or allowed.Team then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and Entity.IsAlive(player) then
                    local enemy = Entity.IsEnemy(player)
                    if (allowed.Players and enemy) or (allowed.Team and not enemy) then body(player.Character) end
                end
            end
        end
        if allowed.Bots then
            for _, model in ipairs(Entity.GetNPCs()) do body(model) end
        end
        if allowed.Structures then
            for _, model in ipairs(Entity.GetStructures()) do
                if model ~= LocalPlayer.Character and Entity.IsAliveModel(model) then
                    add(model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                        or model:FindFirstChild("Head") or model:FindFirstChildOfClass("BasePart"))
                end
            end
        end
        table.clear(HitboxExpander.Records)
        local growth = Vector3.new(amount, amount, amount)
        for part in pairs(wanted) do
            HitboxExpander.Records[part] = {Size = part.Size, ExpandedSize = part.Size + growth}
        end
    end
    function HitboxExpander.Start()
        if HitboxExpander.Started then return end
        HitboxExpander.Started, elapsed = true, 0.1
        TaskManager.AddConnection("HitboxExpander", RunService.Heartbeat, function(dt)
            if flag("AimbotReach", false) ~= true then
                if next(HitboxExpander.Records) then HitboxExpander.Restore() end
                elapsed = 0.1
                return
            end
            elapsed += dt
            if elapsed < 0.1 then return end
            elapsed = 0
            HitboxExpander.Step()
        end)
    end
    function HitboxExpander.Stop()
        HitboxExpander.Started = false
        TaskManager.RemoveConnection("HitboxExpander")
        HitboxExpander.Restore()
    end
    table.insert(Library.UnloadHooks, HitboxExpander.Stop)
    HitboxExpander.Start()
end
