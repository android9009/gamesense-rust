-- Legit aimbot + triggerbot (вкладка Aiming). Плавная доводка камеры без снапа:
-- скорость, реакция, время лока, FOV и хитбоксы берутся из флагов Legit*/Triggerbot*.
local LegitBot = {
    Started = false,
    Target = nil,      -- текущая модель цели
    GhostPos = nil,    -- точка бектрек-призрака (когда живой цели нет)
    SeenAt = 0,        -- когда цель впервые попала в прицел (reaction time)
    LockAt = 0,        -- когда цель захвачена (maximum lock-on time)
    IgnoreUntil = {},  -- model -> время: не брать цель после истекания лока
    LastCam = nil,     -- CFrame камеры прошлого кадра (компенсация отдачи)
    HoverTarget = nil, -- цель под прицелом у триггербота
    HoverAt = 0,
    LastShot = 0,
}

local function legitAimActive()
    if flag("LegitAimbotEnabled", false) ~= true then return false end
    local bind = flag("LegitAimbotBind", nil)
    if type(bind) == "table" and bind.Key and bind.Key ~= "NONE" and bind.Key ~= "" then
        return bind.Active == true
    end
    return true
end

local function triggerActive()
    if flag("TriggerbotEnabled", false) ~= true then return false end
    local bind = flag("TriggerbotBind", nil)
    if type(bind) == "table" and bind.Key and bind.Key ~= "NONE" and bind.Key ~= "" then
        return bind.Active == true
    end
    return true
end

local function legitHitboxPart(model)
    local function find(name)
        local part = model:FindFirstChild(name)
        if part and part:IsA("BasePart") then return part end
        return nil
    end
    if flag("LegitAimbotHead", false) == true then
        local part = find("Head")
        if part then return part end
    end
    if flag("LegitAimbotChest", false) == true then
        local part = find("UpperTorso") or find("Torso")
        if part then return part end
    end
    if flag("LegitAimbotStomach", false) == true then
        local part = find("LowerTorso") or find("Torso")
        if part then return part end
    end
    -- Ничего не выбрано - грудь по умолчанию.
    return find("UpperTorso") or find("Torso") or find("Head") or findRootPart(model)
end

local function angleTo(cam, pos)
    local dir = pos - cam.CFrame.Position
    if dir.Magnitude < 1e-4 then return 999 end
    local dot = math.clamp(cam.CFrame.LookVector:Dot(dir.Unit), -1, 1)
    return math.deg(math.acos(dot))
end

local function findLegitTarget(cam, now)
    local maxFov = math.clamp(tonumber(flag("LegitAimbotMaximumFOV", 10)) or 10, 0.1, 180)
    local visCheck = flag("LegitAimbotVisibleCheck", false) == true
    local best, bestPart, bestAngle = nil, nil, maxFov

    local function consider(model)
        if not model or model == LocalPlayer.Character then return end
        if LegitBot.IgnoreUntil[model] and now < LegitBot.IgnoreUntil[model] then return end
        if not Entity.IsAliveModel(model) then return end
        local part = legitHitboxPart(model)
        if not part then return end
        local ang = angleTo(cam, part.Position)
        if ang > bestAngle then return end
        if visCheck and not isPartVisible(cam, part, part.Position, model) then return end
        best, bestPart, bestAngle = model, part, ang
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and Entity.IsAlive(player) and Entity.IsEnemy(player) then
            consider(player.Character)
        end
    end
    if cachedNPCs then
        for _, npc in ipairs(cachedNPCs) do
            consider(npc)
        end
    end

    -- Легитный бектрек: живой цели в FOV нет - целимся в призрак.
    if not best and flag("OtherBacktrack", false) == true and BacktrackAimHitboxes then
        for char, hits in pairs(BacktrackAimHitboxes) do
            if char and char ~= LocalPlayer.Character and Entity.IsAliveModel(char) then
                for _, hb in ipairs(hits) do
                    if hb and hb.Position then
                        local ang = angleTo(cam, hb.Position)
                        if ang <= bestAngle then
                            best, bestPart, bestAngle = char, nil, ang
                            LegitBot.GhostPos = hb.Position
                        end
                    end
                end
            end
        end
    end

    return best, bestPart, bestAngle
end

local function triggerIsEnemy(model)
    local player = Players:GetPlayerFromCharacter(model)
    if player then
        return Entity.IsAlive(player) and Entity.IsEnemy(player)
    end
    return Entity.IsAliveModel(model)
end

local function triggerPartAllowed(part)
    local head = flag("TriggerbotHead", false) == true
    local chest = flag("TriggerbotChest", false) == true
    local stomach = flag("TriggerbotStomach", false) == true
    if not (head or chest or stomach) then return true end
    local name = part.Name
    if head and name == "Head" then return true end
    if chest and (name == "UpperTorso" or name == "Torso") then return true end
    if stomach and (name == "LowerTorso" or name == "Torso") then return true end
    return false
end

local function triggerUpdate(cam, now)
    if not triggerActive() or autoInputPaused() then
        LegitBot.HoverTarget = nil
        return
    end

    local target = nil
    local view = cam.ViewportSize
    local ray = cam:ScreenPointToRay(view.X * 0.5, view.Y * 0.5)
    local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, visibilityParams(cam, false))
    if result and result.Instance and result.Instance:IsA("BasePart") then
        local model = result.Instance:FindFirstAncestorOfClass("Model")
        if model and model ~= LocalPlayer.Character
            and triggerPartAllowed(result.Instance) and triggerIsEnemy(model) then
            target = model
        end
    end

    -- Magnet trigger: прямого хита нет - стреляем, если хитбокс врага
    -- впритык к прицелу, и слегка доворачиваем камеру на него.
    if not target and flag("TriggerbotMagnet", false) == true then
        local magnetAngle, magnetPart = 3, nil
        local function considerMagnet(model)
            if not model or model == LocalPlayer.Character or not Entity.IsAliveModel(model) then return end
            for _, name in ipairs({"Head", "UpperTorso", "Torso", "LowerTorso"}) do
                local part = model:FindFirstChild(name)
                if part and part:IsA("BasePart") and triggerPartAllowed(part) then
                    local ang = angleTo(cam, part.Position)
                    if ang <= magnetAngle then
                        magnetAngle, magnetPart, target = ang, part, model
                    end
                end
            end
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and Entity.IsAlive(player) and Entity.IsEnemy(player) then
                considerMagnet(player.Character)
            end
        end
        if cachedNPCs then
            for _, npc in ipairs(cachedNPCs) do
                considerMagnet(npc)
            end
        end
        if target and magnetPart then
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, magnetPart.Position), 0.35)
        end
    end

    if target then
        if LegitBot.HoverTarget ~= target then
            LegitBot.HoverTarget = target
            LegitBot.HoverAt = now
        end
        local reaction = (tonumber(flag("TriggerbotReactionTime", 100)) or 100) / 1000
        if now - LegitBot.HoverAt >= reaction and now - LegitBot.LastShot >= math.max(reaction, 0.06) then
            LegitBot.LastShot = now
            pcall(function()
                if mouse1click then
                    mouse1click()
                elseif mouse1press and mouse1release then
                    mouse1press()
                    mouse1release()
                end
            end)
        end
    else
        LegitBot.HoverTarget = nil
    end
end

function LegitBot.Update(dt)
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local now = os.clock()
    -- Rage-aimbot главнее: за камеру не дерёмся.
    local rageBusy = RageBot and RageBot.Active

    -- Компенсация отдачи: пока стреляем, возвращаем заданную долю увода камеры.
    -- Дельта считается от кадра ПОСЛЕ наших поворотов, поэтому своя доводка
    -- и доводка легита в неё не попадают.
    local firing = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    if firing and LegitBot.LastCam then
        local pitchPct = math.clamp(tonumber(flag("LegitAimbotRecoilPitch", 100)) or 100, 0, 100) / 100
        local yawPct = math.clamp(tonumber(flag("LegitAimbotRecoilYaw", 75)) or 75, 0, 100) / 100
        if pitchPct > 0 or yawPct > 0 then
            local rel = LegitBot.LastCam:ToObjectSpace(cam.CFrame)
            local rx, ry = rel:ToEulerAnglesYXZ()
            if rx ~= 0 or ry ~= 0 then
                cam.CFrame = cam.CFrame * CFrame.Angles(-rx * pitchPct, -ry * yawPct, 0)
            end
        end
    end

    if legitAimActive() and not rageBusy and not autoInputPaused() then
        local target, part, ang = findLegitTarget(cam, now)
        if target ~= LegitBot.Target then
            LegitBot.Target = target
            LegitBot.SeenAt = now
            LegitBot.LockAt = now
        end
        if target then
            local reaction = (tonumber(flag("LegitAimbotReactionTime", 100)) or 100) / 1000
            local maxLock = tonumber(flag("LegitAimbotMaxLockTime", 1000)) or 1000
            if maxLock < 1000 and now - LegitBot.LockAt > maxLock / 1000 then
                -- Лок истёк: отпускаем цель и ненадолго её игнорируем.
                LegitBot.IgnoreUntil[target] = now + 0.35
                LegitBot.Target = nil
            elseif now - LegitBot.SeenAt >= reaction then
                local aimPos = part and part.Position or LegitBot.GhostPos
                if aimPos then
                    local speed = firing
                        and (tonumber(flag("LegitAimbotAttackSpeed", 0.65)) or 0.65)
                        or (tonumber(flag("LegitAimbotSpeed", 0.65)) or 0.65)
                    speed = math.clamp(speed, 0, 1)
                    -- Speed scale - FOV: у края FOV скорость полная, у центра -
                    -- мягче, чтобы не перелетать хитбокс.
                    local scaleFov = math.clamp(tonumber(flag("LegitAimbotSpeedScaleFOV", 100)) or 100, 0, 100) / 100
                    if scaleFov > 0 then
                        local maxFov = math.clamp(tonumber(flag("LegitAimbotMaximumFOV", 10)) or 10, 0.1, 180)
                        local ratio = math.clamp(ang / maxFov, 0, 1)
                        speed = speed * ((1 - scaleFov) + scaleFov * ratio)
                    end
                    local alpha = 1 - math.pow(1 - speed, math.max(dt or (1 / 60), 1 / 240) * 60)
                    local goal = CFrame.new(cam.CFrame.Position, aimPos)
                    cam.CFrame = cam.CFrame:Lerp(goal, math.clamp(alpha, 0, 1))
                end
            end
        end
    else
        LegitBot.Target = nil
    end

    if not rageBusy then
        triggerUpdate(cam, now)
    end

    LegitBot.LastCam = cam.CFrame
end

function LegitBot.Start()
    if LegitBot.Started then return end
    LegitBot.Started = true
    TaskManager.AddConnection("LegitAim", RunService.RenderStepped, LegitBot.Update)
    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, LegitBot.Shutdown)
    end
end

function LegitBot.Shutdown()
    TaskManager.RemoveConnection("LegitAim")
    LegitBot.Target = nil
    LegitBot.HoverTarget = nil
    LegitBot.LastCam = nil
    table.clear(LegitBot.IgnoreUntil)
    LegitBot.Started = false
end

LegitBot.Start()
