-- Backtrack chams: визуальная копия цели с задержкой по истории CFrame (полная копия персонажа со сглаживанием прозрачности при совпадении).

-- =========================================================================
-- // RageBot & AntiAim Modules (True 1-Tick RenderStepped/Heartbeat Silent Aim)
-- =========================================================================
-- Умный бектрек: общее состояние между бектрек-чамсами и аимботом.
-- BacktrackAim[targetKey] = позиция призрака бектрека (куда аимбот целится,
-- когда противник за стеной/невидим). Заполняется в btUpdate, читается в getClosestTarget.
local BacktrackAim = {}
local BacktrackAimCache = {}   -- targetKey -> {Character, Pos} для чистки
local BacktrackAimByChar = {}  -- Character/model -> Pos (для reposition на время выстрела)
local BacktrackAimHitboxes = {} -- Character/model -> { {Position=..., Name=...}, ... } (хитбоксы чамса)
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
    GameShoot = nil,          -- оригинал функции shoot игры (возврат из hookfunction)
    GameShootFn = nil,        -- сама функция shoot (объект, который хукаем)
    GameShootHooked = false,  -- true = хук на shoot установлен
    GameShootTried = false,   -- true = уже пытались хукнуть (чтобы не повторять)
}

local AntiAim = {
    Started = false,
    OriginalAutoRotate = nil,
    PinnedPosition = nil,   -- точка фиксации позиции при активном AA
    PinnedCharacter = nil,  -- модель, для которой посчитан пин (сброс при респауне)
}

-- состояние джиттера: счётчик кадров текущего тика и какое из двух значений активно
local aaJitterTicks = 0
local aaJitterFlip = false

local Hooks = {}
local cachedNPCs = {}
local npcScanTimer = 0

local function scanBots(deltaTime)
    npcScanTimer = npcScanTimer + (deltaTime or 0.016)
    if npcScanTimer < 0.5 then return end
    npcScanTimer = 0
    table.clear(cachedNPCs)
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local root = findRootPart(obj)
            if hum and hum.Health > 0 and root then
                table.insert(cachedNPCs, obj)
            end
        elseif obj:IsA("Folder") then
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("Model") and not Players:GetPlayerFromCharacter(child) then
                    local hum = child:FindFirstChildOfClass("Humanoid")
                    local root = findRootPart(child)
                    if hum and hum.Health > 0 and root then
                        table.insert(cachedNPCs, child)
                    end
                end
            end
        end
    end
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

local function isPartVisible(cam, targetPart, targetPos, targetModel)
    local localChar = LocalPlayer.Character
    local origin = cam.CFrame.Position
    local dir = targetPos - origin

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = {localChar, cam}
    if Library and Library.Folder then
        table.insert(ignore, Library.Folder)
    end
    rayParams.FilterDescendantsInstances = ignore
    rayParams.IgnoreWater = true

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

    -- Priority: Head -> Neck -> Chest -> Stomach -> Legs -> Feet
    if hasHitbox("Head") then
        local head = model:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            -- мультипоинт: целимся в макушку (верх головы), а не в центр —
            -- так хедшоты попадают по верхушке черепа
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

-- видимость позиции бектрек-чамса (призрака) из камеры: луч не должен
-- упираться в сплошную стену между камерой и точкой. Свой фолдер призраков
-- исключаем, чтобы сам призрак не считался "стеной".
local function btPosVisible(cam, pos)
    local localChar = LocalPlayer.Character
    local origin = cam.CFrame.Position
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = {localChar, cam}
    if Library and Library.Folder then table.insert(ignore, Library.Folder) end
    local gb = Workspace:FindFirstChild("GS_BacktrackFolder")
    if gb then table.insert(ignore, gb) end
    rayParams.FilterDescendantsInstances = ignore
    rayParams.IgnoreWater = true
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
    -- умный бектрек активен, если есть позиции призраков
    local backtrackActive = next(BacktrackAim) ~= nil
    -- при активном бектреке видимость проверяем всегда: если противник невидим,
    -- direct-наведение его пропустит и сработает фолбэк на позицию бектрека
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

    -- Приоритет цели в обычной стрельбе:
    --   1) Враг ВИДЕН -> стреляем в живую модель (по приоритетному видимому
    --      хитбоксу: голова -> шея -> грудь -> ...).
    --   2) Врага НЕ видно, но бектрек-чамс виден -> стреляем в бектрек-чамс.
    --   3) Оба не видны -> не стреляем вообще.
    -- Для этого при активном бектреке видимость живой цели проверяем всегда:
    --  нужна она, чтобы решить, использовать ли живую модель или бектрек.
    -- needVis = visibleCheck or backtrackActive (см. выше)

    -- 1. Scan Players
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

    -- 2. Scan Bots
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

    -- 3. Scan Structures
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

    -- 4. Живой цели не видно => пробуем видимый бектрек-чамс (призрак).
    --    Стреляем в призрака только если он ВИДЕН; если и призрак не виден —
    --    не стреляем вообще (ниже вернётся nil).
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
                    -- фильтр по типам целей (Players/Team/Bots)
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
                        -- хитбоксы в приоритете (голова -> ...): берём первую
                        -- видимую и в пределах FOV
                        for _, hb in ipairs(hits) do
                            local screenPos, onScreen = camera:WorldToViewportPoint(hb.Position)
                            if onScreen and screenPos.Z > 0 then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                if dist <= btDist and btPosVisible(camera, hb.Position) then
                                    btDist = dist
                                    btPos = hb.Position
                                    btPart = findRootPart(char) -- для silent aim
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        if btPos then
            return btPart or nil, btPos, true -- true = стреляем по бектрек-чамсу
        end
    end

    return closestPart, closestPos, false
end

function RageBot.AutoFire()
    local now = os.clock()
    -- очень быстрый автофайр: почти без лимита, чтобы пули летели на макс. скорости игры
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
                                local res = { Hooks.Namecall(self, table.unpack(args)) }
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

-- REPOSITIONING (бектрек): перенос хитбокса цели в позицию призрака бектрека,
-- чтобы пули в чамс засчитывались (у Roblox нет серверного отката времени, как
-- в CS:GO). Телепорт включается ТОЛЬКО пока мы стреляем в чамс; как только
-- перестали стрелять (или сменили цель) — тело сразу возвращается на место, так
-- что видно, куда реально идёт противник. История бектрека в это время пишет
-- снимок реальных позиций (см. btCapture), поэтому чамс не замирает.
local ReposActive = {}  -- model -> { Root, OldCFrame, OldCFrames }

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

-- Снимок реальных CFrame всех частей тела (для чистой истории во время репозиции)
local function snapshotModelCFrames(model)
    local out = {}
    for _, bp in ipairs(model:GetDescendants()) do
        if bp:IsA("BasePart") and not bp:FindFirstAncestorOfClass("Tool") then
            out[bp] = bp.CFrame
        end
    end
    return out
end

-- Вызывается каждый кадр из RageBot.UpdateRender. Телепортит цель в позицию чамса,
-- пока мы в неё стреляем; все остальные (ранее телепортированные) сразу возвращает.
local function updateBacktrackReposition(targetPart, isShooting, isBacktrackShot)
    local reposTarget = nil
    -- Репозиция нужна ТОЛЬКО когда мы реально стреляем по бектрек-чамсу.
    -- Если стреляем в живого видимого противника (isBacktrackShot = false) —
    -- не телепортируем его: он и так на месте.
    if isShooting and isBacktrackShot and targetPart and targetPart.Parent then
        local model = targetPart:FindFirstAncestorOfClass("Model")
        if model and model ~= LocalPlayer.Character and BacktrackAimByChar[model] then
            reposTarget = model
        end
    end

    -- возвращаем все ранее телепортированные тела, кроме того, что стреляем сейчас
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
            if RageBot.Active and RageBot.SilentOn and RageBot.TargetPosition and cam then
                local oldCFrame = cam.CFrame
                -- Silent aim: наводим камеру на цель (цель — живой противник или
                -- позиция призрака бектрека)
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
    scanBots(deltaTime)

    local masterEnabled = flag("AimbotEnabled", false) == true
    local active = RageBot.IsAimbotActive()
    local cam = Workspace.CurrentCamera

    RageBot.Active = active
    RageBot.SilentOn = flag("AimbotSilentAim", false) == true

    -- 1. FOV Circle
    local visFOV = flag("AimbotVisFOV", false) == true
    if RageBot.FovCircle then
        if masterEnabled and visFOV and cam then
            local radius = getScreenFOVRadius()
            RageBot.FovCircle.Radius = radius
            -- круг FOV прикреплён к ЦЕНТРУ экрана, а не к мышке
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

    -- 2. Target Acquisition
    local part, pos, isBtShot = getClosestTarget()
    RageBot.TargetPart = part
    RageBot.TargetPosition = pos
    RageBot.TargetIsBacktrack = isBtShot == true

    local isShooting = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or flag("AimbotAutoFire", false) == true

    -- 2.5 Backtrack reposition: телепортируем цель в чамс ТОЛЬКО пока стреляем
    -- И при этом целимся именно в бектрек-чамс (не в живого противника);
    -- как только перестали (или бектрек не используется) — сразу сбрасываем,
    -- чтобы видеть реальное положение.
    updateBacktrackReposition(part, isShooting, RageBot.TargetIsBacktrack)

    if part and pos then
        if not RageBot.SilentOn then
            -- Direct aimbot
            cam.CFrame = CFrame.new(cam.CFrame.Position, pos)
            RageBot.OriginalCFrame = nil
        else
            -- Silent aim:
            --   Приоритет — хук реальной функции shoot игры (setupGameShootHook):
            --   цель наводится в сам момент выстрела, камера в кадре не дёргается.
            --   Если хук недоступен — фолбэк: 1-tick flick камерой во время стрельбы
            --   (наводимся в RenderStepped, возвращаем в Heartbeat после обработки оружия).
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
    -- снять хук с функции shoot игры (best effort: если экзекутор не умеет
    -- восстанавливать — хук останется, но он сам себя отключает, когда
    -- аимбот/сайлент выключены)
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
    -- вернуть все репонируемые тела на место
    clearReposActive()
end

-- =========================================================================
-- // Anti recoil (Rage -> "Anti recoil"): ПОЛНОЕ удаление отдачи
-- Игра (Project Real) применяет отдачу через модуль
-- ReplicatedStorage.Blaster.Scripts.CameraRecoiler:
--   - при выстреле BlasterController вызывает CameraRecoiler.recoil(p1),
--     p1 -- Vector2-смещение, посчитанное из оружия;
--   - recoil() копит его в u35 и ставит флаг u36 = 1;
--   - рендер-степ "Recoiler" вертит камеру из u35 и сам же сбрасывает u36.
-- НЕ трогаем атрибуты recoilMin/recoilMax (игра падает, если там не Vector) и
-- НЕ блокируем рендер-степ "Recoiler" (иначе u36 навсегда = 1 и стрельба глохнет).
-- Решение: просто делаем CameraRecoiler.recoil НО-ОПОМ. Тогда:
--   - u35 не копится -> камера НЕ качается (отдача убрана полностью);
--   - u36 не ставится (остаётся 0) -> игра не блокирует следующий выстрел;
--   - рендер-степ продолжает спокойно работать -> игра не падает.
-- При выключении чекбокса функция recoil восстанавливается.
local RecoilKiller = {
    Started = false,
    ModRef = nil,     -- таблица, которую вернул модуль CameraRecoiler
    OldRecoil = nil,  -- оригинальная recoil (для восстановления)
}

local function rkActive()
    return flag("AimbotAntiRecoil", false) == true
end

-- найти и закэшировать модуль CameraRecoiler (через require — он уже загружен игрой)
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

-- нейтрализуем recoil: no-op
local function rkApply()
    local mod = rkFindModule()
    if not mod then
        return
    end
    if RecoilKiller.OldRecoil == nil then
        RecoilKiller.OldRecoil = mod.recoil
        mod.recoil = function(p1)
            -- no-op: отдача игнорируется, u35/u36 не меняются
        end
    end
end

-- восстановить оригинальную recoil
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

-- =========================================================================
-- // Anti spread (Rage -> "Anti spread"): убрать разброс полностью
-- =========================================================================
-- Разброс в Project Real генерируется функцией getRayDirections из атрибута
-- "spread" (Constants.SPREAD_ATTRIBUTE, Vector2). КРИТИЧНО: в BlasterController:shoot()
--   local spread = self.blaster:GetAttribute("spread")
--   if not self.isZoomedIn then spread = spread + 4 end  -- без прицела +4!
-- Поэтому простого клампа атрибута мало: без прицела игра всё равно добавляет +4.
-- Решение (2 слоя, оба live по чекбоксу AimbotAntiSpread):
--   1) hookfunction(getRayDirections) -> все пули строго в центр прицела.
--      Убирает и базовый спред, и "+4" без прицела. (главное)
--   2) клампим атрибут "spread" к крошечному ненулевому Vector2 (запасной слой).
-- При выключении чекбокса перехват снимается и атрибуты восстанавливаются.
local NoSpread = {
    Started = false,
    ToolCache = {},     -- tool -> { [holder] = original }
    LastTool = nil,
    -- перехват getRayDirections (убирает +4 спреда без прицела)
    RayModRef = nil,    -- возврат require(getRayDirections)
    OldRayDirections = nil,
    RaysPatched = false,
}

local NS_ATTR = "spread"
local NS_CLAMP = Vector2.new(0.0001, 0.0001)

local function nsActive()
    return flag("AimbotAntiSpread", false) == true
end

local function nsIsClampable(value)
    -- принимаем только Vector2/таблицу (как игра их хранит) — числа не трогаем
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

-- найти и закэшировать модуль getRayDirections
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

-- getRayDirections без разброса: возвращаем все лучи строго в центр прицела.
-- Это убирает и базовый спред, и тот самый "+4", который игра добавляет,
-- когда прицел НЕ открыт (isZoomedIn=false). Оригинальная сигнатура:
--   getRayDirections(cameraCFrame, rayCount, spreadRadians, seed) -> array of Vector3
local function nsNoSpreadRays(cameraCFrame, rayCount, spreadRadians, seed)
    local dir = cameraCFrame.LookVector
    local out = {}
    for i = 1, (rayCount or 1) do
        out[i] = dir
    end
    return out
end

-- найти функцию getRayDirections через filtergc (она уже захвачена игрой)
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

-- применить перехват (hookfunction), если чекбокс включён
local function nsPatchRays()
    if NoSpread.RaysPatched then return end
    local fn = nsFindRayFn()
    if not fn then return end
    pcall(function()
        NoSpread.OldRayDirections = hookfunction(fn, nsNoSpreadRays)
        NoSpread.RaysPatched = NoSpread.OldRayDirections ~= nil
    end)
end

-- восстановить оригинальную getRayDirections
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

    -- перехват getRayDirections (убирает спред и "+4" без прицела)
    if on then
        nsPatchRays()
    else
        nsUnpatchRays()
    end

    local char = LocalPlayer.Character
    local tool = on and char and char:FindFirstChildOfClass("Tool") or nil

    -- смена оружия / выключение -> восстановить оригиналы прошлого
    if NoSpread.LastTool and NoSpread.LastTool ~= tool then
        nsRestoreTool(NoSpread.LastTool)
    end
    NoSpread.LastTool = tool

    if not on or not tool then
        return
    end

    -- запомнить оригиналы при первом контакте с этим оружием
    if not NoSpread.ToolCache[tool] then
        local saved = {}
        for holder in pairs(nsCollectHolders(tool)) do
            saved[holder] = holder:GetAttribute(NS_ATTR)
        end
        NoSpread.ToolCache[tool] = saved
    end

    -- заклампить разброс к крошечному ненулевому значению
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
            -- ставим только если ещё не закламплено (чтобы не дёргать каждый кадр)
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

-- =========================================================================
-- // Air shot (Rage -> "Air shot"): стрельба в воздухе
-- =========================================================================
-- Игра (Project Real, BlasterController:canShoot) запрещает стрелять, пока
-- гуманоид в воздухе: canShoot ставит humanoid=true, если состояние Jumping
-- или Freefall, и требует `not humanoid`, чтобы вернуть true. Из-за этого
-- в прыжке/падении оружие молчит.
-- Решение: перехватываем метод canShoot у модуля BlasterController (через
-- require) и, когда чекбокс "Air shot" (AimbotAirShot) включён, возвращаем
-- ВЕРСИЮ БЕЗ проверки на воздух: все остальные проверки (жив/экипирован/
-- патроны/перезарядка/блокировка стеной/спринт) остаются, но прыжок и
-- падение больше не запрещают стрельбу. При выключении метод восстанавливается.
local AirShot = {
    Started = false,
    ModuleRef = nil,   -- возврат require(BlasterController) -> u176
    OldCanShoot = nil, -- оригинальный canShoot
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

-- canShoot без ограничения "в воздухе" (повторяет оригинал, но пропускает
-- проверку humanoid == Jumping/Freefall)
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

