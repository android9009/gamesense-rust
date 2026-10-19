-- Legit aimbot + triggerbot (вкладка Aiming). Плавная доводка камеры без снапа:
-- скорость, реакция, время лока, FOV и хитбоксы берутся из флагов Legit*/Triggerbot*.
local LegitBot = {
    Started = false,
    Target = nil,      -- текущая модель цели
    GhostPos = nil,    -- точка бектрек-призрака (когда живой цели нет)
    VisibleSince = {}, -- model -> с какого времени цель непрерывно видна (reaction)
    LockAt = 0,        -- когда цель захвачена (maximum lock-on time)
    FovCircle = nil,
    IgnoreUntil = {},  -- model -> время: не брать цель после истекания лока
    HoverTarget = nil, -- цель под прицелом у триггербота
    HoverAt = 0,
    LastShot = 0,
}

local function legitAimActive()
    if flag("LegitAimbotEnabled", false) ~= true then return false end
    -- Работает по бинду: держишь клавишу бинда - аимбот сам наводится, без стрельбы.
    -- И при стрельбе (Mouse1) - тоже, а не только в момент выстрела по бинду.
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        return true
    end
    local bind = flag("LegitAimbotBind", nil)
    if type(bind) == "table" and bind.Key and bind.Key ~= "NONE" and bind.Key ~= "" then
        return bind.Active == true
    end
    return true
end

-- Smooth: шкала 0..10, чем МЕНЬШЕ - тем быстрее доводка (0 = мгновенно).
-- Возвращает фактор доводки за кадр 60fps. Старые конфиги (0..100 %) конвертим.
local function smoothAmount(flagName, defaultSmooth)
    local raw = tonumber(profileFlag("Legit", flagName, defaultSmooth)) or defaultSmooth
    if raw > 10 then
        raw = math.clamp((100 - raw) / 9.5, 0, 10)
    end
    raw = math.clamp(raw, 0, 10)
    return 1 - (raw / 10) * 0.95
end

local function triggerActive()
    if flag("TriggerbotEnabled", false) ~= true then return false end
    local bind = flag("TriggerbotBind", nil)
    if type(bind) == "table" and bind.Key and bind.Key ~= "NONE" and bind.Key ~= "" then
        return bind.Active == true
    end
    return true
end

local function legitSelectedParts(model)
    local function find(name)
        local part = model:FindFirstChild(name)
        if part and part:IsA("BasePart") then return part end
        return nil
    end
    local parts = {}
    if profileFlag("Legit", "LegitAimbotHead", false) == true then
        local part = find("Head")
        if part then parts[#parts + 1] = part end
    end
    if profileFlag("Legit", "LegitAimbotChest", false) == true then
        local part = find("UpperTorso") or find("Torso")
        if part then parts[#parts + 1] = part end
    end
    if profileFlag("Legit", "LegitAimbotStomach", false) == true then
        local part = find("LowerTorso") or find("Torso")
        if part then parts[#parts + 1] = part end
    end
    if #parts == 0 then
        -- Ничего не выбрано - грудь по умолчанию.
        local part = find("UpperTorso") or find("Torso") or find("Head") or findRootPart(model)
        if part then parts[#parts + 1] = part end
    end
    return parts
end

-- Точка прицела: первый ВИДИМЫЙ выбранный хитбокс (голова скрыта за
-- ступеньками, а ноги видны - целимся в ноги). При Visible check невидимая
-- цель не берётся вообще, без него - падаем на первый выбранный хитбокс.
local function legitAimPart(cam, model)
    local parts = legitSelectedParts(model)
    if #parts == 0 then return nil end
    for _, part in ipairs(parts) do
        if isPartVisible(cam, part, part.Position, model) then
            return part
        end
    end
    if profileFlag("Legit", "LegitAimbotVisibleCheck", false) == true then
        return nil
    end
    return parts[1]
end

-- Цель "замечена", если виден хотя бы один выбранный хитбокс.
local function legitSpotted(cam, model)
    for _, part in ipairs(legitSelectedParts(model)) do
        if isPartVisible(cam, part, part.Position, model) then
            return true
        end
    end
    return false
end

local function angleTo(cam, pos)
    local dir = pos - cam.CFrame.Position
    if dir.Magnitude < 1e-4 then return 999 end
    local dot = math.clamp(cam.CFrame.LookVector:Dot(dir.Unit), -1, 1)
    return math.deg(math.acos(dot))
end

local function findLegitTarget(cam, now)
    local maxFov = math.clamp(tonumber(profileFlag("Legit", "LegitAimbotMaximumFOV", 10)) or 10, 0.1, 180)
    local priority = flag("LegitTargetPriority", "Closest to crosshair")
    local bestScore = math.huge
    local best, bestPart, bestAngle = nil, nil, maxFov

    local function consider(model)
        if not model or model == LocalPlayer.Character then return end
        if LegitBot.IgnoreUntil[model] and now < LegitBot.IgnoreUntil[model] then return end
        if not Entity.IsAliveModel(model) then return end
        local part = legitAimPart(cam, model)
        if not part then return end
        local ang = angleTo(cam, part.Position)
        if ang > maxFov then return end
        local score = ang
        if priority == "Lowest health" then
            local hum = model:FindFirstChildOfClass("Humanoid")
            score = (hum and hum.Health or 100) * 100000 + ang
        elseif priority == "Closest distance" then
            score = (part.Position - cam.CFrame.Position).Magnitude * 1000 + ang * 0.001
        end
        if score <= bestScore then
            bestScore = score
            best, bestPart, bestAngle = model, part, ang
        end
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

-- Компенсация отдачи: та же логика, что рейдж Anti-recoil (CameraRecoiler),
-- только частичная - вектор рекойла каждого оружия масштабируется по
-- процентам Pitch/Yaw. 100% по питчу = вертикального рекойла нет совсем.
local LegitRecoil = { ModRef = nil, OldRecoil = nil, Patched = false }

local function legitRecoilInstall()
    if LegitRecoil.Patched then return true end
    if not LegitRecoil.ModRef then
        local rs = game:GetService("ReplicatedStorage")
        local blaster = rs and rs:FindFirstChild("Blaster")
        local scripts = blaster and blaster:FindFirstChild("Scripts")
        local mod = scripts and scripts:FindFirstChild("CameraRecoiler")
        if not (mod and mod:IsA("ModuleScript")) then return false end
        local ok, result = pcall(require, mod)
        if not (ok and type(result) == "table" and type(result.recoil) == "function") then
            return false
        end
        LegitRecoil.ModRef = result
    end
    LegitRecoil.OldRecoil = LegitRecoil.ModRef.recoil
    LegitRecoil.ModRef.recoil = function(p1)
        if flag("LegitAimbotEnabled", false) == true and typeof(p1) == "Vector2" then
            local pitchPct = math.clamp(tonumber(flag("LegitAimbotRecoilPitch", 100)) or 100, 0, 100) / 100
            local yawPct = math.clamp(tonumber(flag("LegitAimbotRecoilYaw", 75)) or 75, 0, 100) / 100
            if pitchPct > 0 or yawPct > 0 then
                p1 = Vector2.new(p1.X * (1 - yawPct), p1.Y * (1 - pitchPct))
            end
        end
        return LegitRecoil.OldRecoil(p1)
    end
    LegitRecoil.Patched = true
    return true
end

local function triggerIsEnemy(model)
    local player = Players:GetPlayerFromCharacter(model)
    if player then
        return Entity.IsAlive(player) and Entity.IsEnemy(player)
    end
    return Entity.IsAliveModel(model)
end

local function triggerSelectedParts(model)
    local function find(name)
        local part = model:FindFirstChild(name)
        if part and part:IsA("BasePart") then return part end
        return nil
    end
    local parts = {}
    if flag("TriggerbotHead", false) == true then
        local part = find("Head")
        if part then parts[#parts + 1] = part end
    end
    if flag("TriggerbotChest", false) == true then
        local part = find("UpperTorso") or find("Torso")
        if part then parts[#parts + 1] = part end
    end
    if flag("TriggerbotStomach", false) == true then
        local part = find("LowerTorso") or find("Torso")
        if part then parts[#parts + 1] = part end
    end
    if #parts == 0 then
        for _, name in ipairs({"Head", "UpperTorso", "Torso", "LowerTorso"}) do
            local part = find(name)
            if part then parts[#parts + 1] = part end
        end
        if #parts == 0 then
            local root = findRootPart(model)
            if root then parts[#parts + 1] = root end
        end
    end
    return parts
end

local function triggerUpdate(cam, now)
    if not triggerActive() or autoInputPaused() then
        LegitBot.HoverTarget = nil
        return
    end

    -- Ищем хитбокс врага рядом с прицелом: прямой триггер - впритык к центру,
    -- с магнитом - в радиусе побольше и с доводкой камеры на хитбокс.
    local magnet = flag("TriggerbotMagnet", false) == true
    local maxAngle = magnet and 5 or 1.2
    local bestModel, bestPart, bestAngle = nil, nil, maxAngle

    local function consider(model)
        if not model or model == LocalPlayer.Character or not triggerIsEnemy(model) then return end
        for _, part in ipairs(triggerSelectedParts(model)) do
            local ang = angleTo(cam, part.Position)
            if ang <= bestAngle and isPartVisible(cam, part, part.Position, model) then
                bestModel, bestPart, bestAngle = model, part, ang
            end
        end
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

    if not bestModel then
        LegitBot.HoverTarget = nil
        return
    end

    -- Магнит: доворачиваем камеру прямо на хитбокс (свой аимбот триггера).
    if magnet and bestPart then
        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, bestPart.Position), 0.45)
    end

    -- Reaction time как в аимботе: цель должна непрерывно быть в зоне
    -- триггера указанное время, дальше выстрел - и таймер заново.
    if LegitBot.HoverTarget ~= bestModel then
        LegitBot.HoverTarget = bestModel
        LegitBot.HoverAt = now
    end
    local reaction = (tonumber(flag("TriggerbotReactionTime", 100)) or 100) / 1000
    if now - LegitBot.HoverAt >= reaction then
        LegitBot.HoverAt = now
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
end

function LegitBot.Update(dt)
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local now = os.clock()
    -- Rage-aimbot главнее: за камеру не дерёмся.
    local rageBusy = RageBot and RageBot.Active

    local firing = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    -- Компенсация отдачи живёт в обёртке CameraRecoiler.recoil (ставится один
    -- раз); здесь только дожидаемся загрузки модуля игры.
    if not LegitRecoil.Patched and now >= (LegitBot.NextRecoilTry or 0) then
        LegitBot.NextRecoilTry = now + 0.5
        legitRecoilInstall()
    end

    -- Круг Visible FOV: радиус Maximum FOV в пикселях по центру экрана.
    if LegitBot.FovCircle then
        if flag("LegitAimbotEnabled", false) == true and flag("LegitAimbotVisibleFOV", false) == true then
            local maxFovDeg = math.clamp(tonumber(profileFlag("Legit", "LegitAimbotMaximumFOV", 10)) or 10, 0.1, 89)
            local radius = (math.tan(math.rad(maxFovDeg)) / math.tan(math.rad(math.clamp(cam.FieldOfView, 1, 120) / 2)))
                * (cam.ViewportSize.Y * 0.5)
            LegitBot.FovCircle.Radius = math.clamp(radius, 2, 4000)
            LegitBot.FovCircle.Position = Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5)
            LegitBot.FovCircle.Visible = true
        else
            LegitBot.FovCircle.Visible = false
        end
    end

    if legitAimActive() and not rageBusy and not autoInputPaused() then
        local target, part, ang = findLegitTarget(cam, now)
        if target ~= LegitBot.Target then
            LegitBot.Target = target
            LegitBot.LockAt = now
        end
        if target then
            -- Reaction time: таймер идёт, только пока цель ВИДНА (хотя бы один
            -- выбранный хитбокс). Пока таймер не истёк - не наводимся; цель
            -- скрылась - таймер сброшен.
            for model in pairs(LegitBot.VisibleSince) do
                if model ~= target or not model.Parent then
                    LegitBot.VisibleSince[model] = nil
                end
            end
            if not part or legitSpotted(cam, target) then
                LegitBot.VisibleSince[target] = LegitBot.VisibleSince[target] or now
            else
                LegitBot.VisibleSince[target] = nil
            end
            local reaction = (tonumber(profileFlag("Legit", "LegitAimbotReactionTime", 100)) or 100) / 1000
            local maxLock = tonumber(profileFlag("Legit", "LegitAimbotMaxLockTime", 0)) or 0
            if maxLock > 0 and now - LegitBot.LockAt > maxLock / 1000 then
                -- Лок истёк: отпускаем цель и ненадолго её игнорируем.
                LegitBot.IgnoreUntil[target] = now + 0.35
                LegitBot.Target = nil
            elseif LegitBot.VisibleSince[target] and now - LegitBot.VisibleSince[target] >= reaction then
                local aimPos = part and part.Position or LegitBot.GhostPos
                if aimPos then
                    local speed = firing
                        and smoothAmount("LegitAimbotAttackSpeed", 5)
                        or smoothAmount("LegitAimbotSpeed", 5)
                    -- Speed scale - FOV: у края FOV скорость полная, у центра -
                    -- мягче, чтобы не перелетать хитбокс.
                    local scaleFov = math.clamp(tonumber(flag("LegitAimbotSpeedScaleFOV", 100)) or 100, 0, 100) / 100
                    if scaleFov > 0 then
                        local maxFov = math.clamp(tonumber(profileFlag("Legit", "LegitAimbotMaximumFOV", 10)) or 10, 0.1, 180)
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
        table.clear(LegitBot.VisibleSince)
    end

    if not rageBusy then
        triggerUpdate(cam, now)
    end
end

function LegitBot.Start()
    if LegitBot.Started then return end
    LegitBot.Started = true
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
            LegitBot.FovCircle = circle
        end)
    end
    TaskManager.AddConnection("LegitAim", RunService.RenderStepped, LegitBot.Update)
    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, LegitBot.Shutdown)
    end
end

function LegitBot.Shutdown()
    TaskManager.RemoveConnection("LegitAim")
    if LegitRecoil.Patched and LegitRecoil.ModRef and LegitRecoil.OldRecoil then
        LegitRecoil.ModRef.recoil = LegitRecoil.OldRecoil
    end
    LegitRecoil.OldRecoil = nil
    LegitRecoil.Patched = false
    if LegitBot.FovCircle then
        pcall(function() LegitBot.FovCircle:Remove() end)
        LegitBot.FovCircle = nil
    end
    LegitBot.Target = nil
    LegitBot.HoverTarget = nil
    table.clear(LegitBot.IgnoreUntil)
    table.clear(LegitBot.VisibleSince)
    LegitBot.Started = false
end

LegitBot.Start()
