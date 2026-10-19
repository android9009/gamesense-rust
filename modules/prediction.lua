-- ============================================================================
-- Prediction: отдельный высокоточный предикт позиции цели для RageBot.
--
-- В отличие от лаг-компенсации (она сдвигает точку только на время
-- рассинхрона сети), предикт моделирует БУДУЩЕЕ движение цели целиком:
--   * история движения: измеренные скорость и ускорение по кадрам
--     (стрейфы, развороты, резкие старты и остановки);
--   * намерение цели: Humanoid.MoveDirection x WalkSpeed - куда цель
--     реально бежит по инпуту, а не куда её несёт инерция рендера;
--   * пинги: мой (полный RTT) и цели (GetNetworkPing), кэшируются;
--   * воздух: прыжки и падения интегрируются по гравитации мира
--     покадрово, с детектом приземления;
--   * ландшафт: высота земли под предсказанной позицией (цель не уйдёт
--     под ступеньки/рампы и не зависнет над склоном), стены - предикт
--     скользит вдоль стены, а не упирается сквозь неё.
--
-- Режимы (AimbotPredictionMode):
--   Light      - только скорость, урезанное время, без ускорения/ландшафта.
--   Balanced   - скорость + ускорение + гравитация + ландшафт.
--   Aggressive - дольше горизонт, полное ускорение, сильный учёт инпута.
-- ============================================================================

Prediction = {
    History = {},
    Modes = {
        Light = {TimeScale = 0.55, LeadCap = 0.25, Accel = 0, Gravity = false, Terrain = false, Intent = 0, VelBlend = 0.7},
        Balanced = {TimeScale = 1.0, LeadCap = 0.35, Accel = 0.6, Gravity = true, Terrain = true, Intent = 0.3, VelBlend = 0.5},
        Aggressive = {TimeScale = 1.3, LeadCap = 0.5, Accel = 1.0, Gravity = true, Terrain = true, Intent = 0.6, VelBlend = 0.35},
    },
    MyPing = 0.05,
    MyPingAt = -1,
    HisPing = 0,
    HisPingAt = -1,
    HisModel = nil,
    LastPrune = 0,
}

function Prediction.GetMyPing(now)
    if now - Prediction.MyPingAt < 0.25 then
        return Prediction.MyPing
    end
    Prediction.MyPingAt = now
    local ping = nil
    pcall(function()
        local stats = game:GetService("Stats")
        local network = stats and stats:FindFirstChild("Network")
        local serverStats = network and network:FindFirstChild("ServerStatsItem")
        local item = serverStats and serverStats:FindFirstChild("Data Ping")
        if item then
            ping = item:GetValue() / 1000
        end
    end)
    if ping == nil then
        pcall(function()
            ping = LocalPlayer:GetNetworkPing()
        end)
    end
    Prediction.MyPing = math.clamp(tonumber(ping) or 0.05, 0, 0.4)
    return Prediction.MyPing
end

function Prediction.GetHisPing(model, now)
    if Prediction.HisModel == model and now - Prediction.HisPingAt < 0.5 then
        return Prediction.HisPing
    end
    Prediction.HisModel, Prediction.HisPingAt = model, now
    local ping = nil
    local plr = model and Players:GetPlayerFromCharacter(model)
    if plr then
        pcall(function()
            ping = plr:GetNetworkPing()
        end)
    end
    Prediction.HisPing = math.clamp(tonumber(ping) or 0, 0, 0.5)
    return Prediction.HisPing
end

function Prediction.RaycastParams(model)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local filter = {}
    if model then
        filter[#filter + 1] = model
    end
    if LocalPlayer and LocalPlayer.Character then
        filter[#filter + 1] = LocalPlayer.Character
    end
    params.FilterDescendantsInstances = filter
    return params
end

-- Высота земли под позицией (неровности ландшафта: ступеньки, рампы, склоны).
function Prediction.GroundAt(model, pos, drop)
    local ok, hit = pcall(function()
        return Workspace:Raycast(pos + Vector3.new(0, 3, 0), Vector3.new(0, -(drop + 3), 0), Prediction.RaycastParams(model))
    end)
    if ok and hit then
        return hit.Position.Y
    end
    return nil
end

-- Стена на пути: возвращает позицию со скольжением вдоль стены.
function Prediction.WallSlide(model, from, to)
    local disp = to - from
    local horiz = Vector3.new(disp.X, 0, disp.Z)
    if horiz.Magnitude < 0.05 then
        return to
    end
    local ok, hit = pcall(function()
        return Workspace:Raycast(from, horiz, Prediction.RaycastParams(model))
    end)
    if not ok or not hit then
        return to
    end
    local frac = math.clamp((hit.Distance - 0.5) / horiz.Magnitude, 0, 1)
    local point = from + horiz * frac
    local rest = horiz * (1 - frac)
    local n = hit.Normal
    rest = rest - n * rest:Dot(n)
    point = point + rest * 0.85
    return Vector3.new(point.X, to.Y, point.Z)
end

-- История движения цели: скорость/ускорение по реальным позициям рута,
-- высота рута над землёй (для приземлений и следования ландшафту).
function Prediction.Sample(model, root, hum, now, mode)
    if now - Prediction.LastPrune > 5 then
        Prediction.LastPrune = now
        for m, sm in pairs(Prediction.History) do
            if now - sm.At > 5 then
                Prediction.History[m] = nil
            end
        end
    end
    local pos = root.Position
    local sm = Prediction.History[model]
    if not sm then
        sm = {Pos = pos, Vel = root.AssemblyLinearVelocity, Acc = Vector3.new(0, 0, 0), At = now, GroundOffset = 2.9}
        Prediction.History[model] = sm
    else
        local dt = now - sm.At
        if dt >= 0.005 then
            local rawVel = (pos - sm.Pos) / dt
            if rawVel.Magnitude > 280 then
                -- Телепорт/респавн: история невалидна.
                sm.Vel = root.AssemblyLinearVelocity
                sm.Acc = Vector3.new(0, 0, 0)
            else
                local vel = sm.Vel:Lerp(rawVel, mode.VelBlend)
                local rawAcc = (vel - sm.Vel) / dt
                if rawAcc.Magnitude > 650 then
                    rawAcc = rawAcc.Unit * 650
                end
                sm.Acc = sm.Acc:Lerp(rawAcc, 0.4)
                sm.Vel = vel
            end
            sm.Pos = pos
            sm.At = now
        end
    end
    if mode.Terrain then
        local gy = Prediction.GroundAt(model, pos, 14)
        if gy then
            sm.GroundOffset = math.clamp(pos.Y - gy, 0.5, 9)
        end
    end
    return sm
end

-- Главная точка входа: возвращает предсказанную позицию (pos - точка
-- прицеливания, обычно хитбокс; симуляция идёт по руту, дельта переносится).
function Prediction.Predict(model, pos, now)
    local root = model and findRootPart(model)
    if not root then
        return pos
    end
    local modeName = flag("AimbotPredictionMode", "Balanced")
    local mode = Prediction.Modes[modeName] or Prediction.Modes.Balanced
    local hum = model:FindFirstChildOfClass("Humanoid")
    local sm = Prediction.Sample(model, root, hum, now, mode)

    -- Горизонт предикта: рассинхрон сети (мой пинг + его пинг/2 + буфер)
    -- на масштаб режима, с кэпом режима.
    local lead = math.clamp((Prediction.GetMyPing(now) + Prediction.GetHisPing(model, now) * 0.5 + 0.03) * mode.TimeScale, 0, mode.LeadCap)
    if lead <= 0.001 then
        return pos
    end

    -- Статы оружия: вне range предиктить нечего; снарядному оружию в горизонт
    -- добавляется время полёта снаряда до цели, автоогню - средний довод до
    -- следующего выстрела по темпу (rateOfFire).
    local cam = Workspace.CurrentCamera
    local dist = cam and (pos - cam.CFrame.Position).Magnitude or 0
    local wstats = getWeaponStats(now)
    if wstats then
        if wstats.Range and wstats.Range > 0 and dist > wstats.Range then
            return pos
        end
        if wstats.BulletSpeed and wstats.BulletSpeed > 10 and dist > 0 then
            lead = lead + dist / wstats.BulletSpeed
        end
        if wstats.RateOfFire and wstats.RateOfFire > 0 then
            lead = lead + math.min(30 / wstats.RateOfFire, 0.04)
        end
        lead = math.min(lead, wstats.BulletSpeed and 1.2 or (mode.LeadCap + 0.35))
    end

    local vel = sm.Vel:Lerp(root.AssemblyLinearVelocity, 0.25)
    -- Намерение цели: куда она бежит по инпуту (MoveDirection x WalkSpeed).
    if hum and mode.Intent > 0 then
        local md = hum.MoveDirection
        if md and md.Magnitude > 0.1 then
            local want = md * (tonumber(hum.WalkSpeed) or 16)
            local k = mode.Intent * 0.5
            vel = Vector3.new(vel.X + (want.X - vel.X) * k, vel.Y, vel.Z + (want.Z - vel.Z) * k)
        end
    end
    if vel.Magnitude < 0.1 and sm.Acc.Magnitude < 1 then
        return pos
    end

    local airborne = false
    if hum then
        airborne = hum.FloorMaterial == Enum.Material.Air
    end
    local gravity = tonumber(Workspace.Gravity) or 196.2
    local acc = Vector3.new(
        math.clamp(sm.Acc.X, -300, 300) * mode.Accel,
        airborne and (mode.Gravity and -gravity or 0) or math.clamp(sm.Acc.Y, -80, 80) * mode.Accel,
        math.clamp(sm.Acc.Z, -300, 300) * mode.Accel
    )

    -- По-кадровая симуляция вперёд: скорость получает ускорение (в воздухе
    -- тянет гравитация), позиция шагает; ландшафт и стены правят траекторию.
    local step = 1 / 60
    local steps = math.max(1, math.floor(lead / step + 0.5))
    local simPos = root.Position
    local simVel = vel
    local terrainAt = simPos
    for i = 1, steps do
        simVel = simVel + acc * step
        if simVel.Magnitude > 340 then
            simVel = simVel.Unit * 340
        end
        simPos = simPos + simVel * step
        if mode.Terrain and i % 2 == 0 then
            simPos = Prediction.WallSlide(model, terrainAt, simPos)
            local gy = Prediction.GroundAt(model, simPos, 40)
            if gy then
                local targetY = gy + sm.GroundOffset
                if airborne then
                    if simPos.Y <= targetY then
                        -- Приземление: дальше цель идёт по земле.
                        simPos = Vector3.new(simPos.X, targetY, simPos.Z)
                        simVel = Vector3.new(simVel.X, 0, simVel.Z)
                        acc = Vector3.new(acc.X, 0, acc.Z)
                        airborne = false
                    end
                elseif simPos.Y > targetY + 7 then
                    -- Сбежала с обрыва/спрыгнула: дальше падает.
                    airborne = true
                    if mode.Gravity then
                        acc = Vector3.new(acc.X, -gravity, acc.Z)
                    end
                else
                    -- Идёт по ландшафту: ступеньки, рампы, склоны.
                    simPos = Vector3.new(simPos.X, targetY, simPos.Z)
                end
            end
            terrainAt = simPos
        end
    end

    local delta = simPos - root.Position
    if delta.Magnitude > 40 then
        delta = delta.Unit * 40
    end
    if wstats then
        -- Спред: конус оружия на дистанции цели (+ радиус луча) и так даёт
        -- люфт ошибки - глушим экстремальное упреждение, чтобы не перелетать.
        -- Дробовик (несколько лучей): веер pellets покрывает ошибку, упреждение
        -- мягче и ближе к центру.
        local cone = math.tan(math.rad(math.clamp(wstats.Spread, 0, 15))) * dist + wstats.RayRadius
        if wstats.RaysPerShot > 1 then
            delta = delta * 0.75
        elseif cone > 0.5 then
            delta = delta * math.clamp(1 - cone * 0.012, 0.82, 1)
        end
    end
    local aimPos = pos + delta
    -- Точка не дальше range оружия от камеры: дальше выстрел не долетит.
    if wstats and wstats.Range and wstats.Range > 0 and cam then
        local toAim = aimPos - cam.CFrame.Position
        if toAim.Magnitude > wstats.Range then
            aimPos = cam.CFrame.Position + toAim.Unit * wstats.Range
        end
    end
    return aimPos
end
