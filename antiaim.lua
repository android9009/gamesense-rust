function AntiAim.Update(deltaTime)
    local enabled = flag("AAEnabled", false) == true
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = findRootPart(char)

    if not enabled or not hum or hum.Health <= 0 or not root then
        if hum then
            if AntiAim.OriginalAutoRotate ~= nil then
                hum.AutoRotate = AntiAim.OriginalAutoRotate
                AntiAim.OriginalAutoRotate = nil
            elseif not hum.AutoRotate then
                hum.AutoRotate = true
            end
        end
        AntiAim.PinnedPosition = nil
        AntiAim.PinnedCharacter = nil
        return
    end

    if AntiAim.OriginalAutoRotate == nil then
        AntiAim.OriginalAutoRotate = hum.AutoRotate
    end
    hum.AutoRotate = false

    -- Фиксация позиции: персонаж только вращается, но не двигается.
    -- Точка пина берётся при включении AA (или при респауне) и держится,
    -- пока игрок стоит. Идём/прыгаем/падаем — пин едет за игроком.
    if AntiAim.PinnedCharacter ~= char then
        AntiAim.PinnedCharacter = char
        AntiAim.PinnedPosition = root.Position
    end
    local aaState = hum:GetState()
    local pinMoving = aaInputHeld()
        or aaState == Enum.HumanoidStateType.Jumping
        or aaState == Enum.HumanoidStateType.Freefall
        or hum.MoveDirection.Magnitude > 0.01
    if pinMoving then
        AntiAim.PinnedPosition = root.Position
    else
        -- стоим: гасим инерцию/толчки, чтобы спин не таскал персонажа
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    local cam = Workspace.CurrentCamera
    local baseYaw = 0
    local yawMode = flag("AAYaw", "At targets")

    if yawMode == "At targets" then
        local closestTarget = nil
        local minDist = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and Entity.IsAlive(p) and Entity.IsEnemy(p) then
                local tRoot = Entity.GetRootPart(p)
                if tRoot then
                    local d = (tRoot.Position - root.Position).Magnitude
                    if d < minDist then
                        minDist = d
                        closestTarget = tRoot
                    end
                end
            end
        end
        if not closestTarget and #cachedNPCs > 0 then
            for _, bot in ipairs(cachedNPCs) do
                local bRoot = findRootPart(bot)
                if bRoot then
                    local d = (bRoot.Position - root.Position).Magnitude
                    if d < minDist then
                        minDist = d
                        closestTarget = bRoot
                    end
                end
            end
        end
        if closestTarget then
            local dir = closestTarget.Position - root.Position
            baseYaw = math.atan2(dir.X, dir.Z)
        else
            local look = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
            baseYaw = math.atan2(look.X, look.Z)
        end
    else
        local look = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
        baseYaw = math.atan2(look.X, look.Z)
    end

    local yawValue = flag("AAYawValue", "180")
    local yawOffset = 0

    if yawValue == "180" then
        local off = tonumber(flag("AAYawOffset", 0)) or 0
        yawOffset = math.rad(180 + off)
    elseif yawValue == "Spin" then
        -- Spin offset: 0 = НЕ крутит. Знак = направление: минус = влево, плюс = вправо.
        -- Модуль = скорость: чем больше число, тем быстрее крутит в свою сторону.
        local spinOff = tonumber(flag("AASpinOffset", 0)) or 0
        yawOffset = 0
        if spinOff ~= 0 then
            local rate = spinOff * 18 -- °/с на единицу слайдера (1 = 3 RPM, 180 = 540 RPM)
            yawOffset = math.rad((os.clock() * rate) % 360)
        end
    elseif yawValue == "Jitter" then
        -- Jitter: j1/j2 — углы со знаком (минус = влево, плюс = вправо от базы).
        -- AAJitSpeed — это ТИКИ перед сменой джиттера: 1т = самый быстрый
        -- (смена каждый кадр), больше тиков = медленнее.
        local j1 = tonumber(flag("AAJitOff1", 0)) or 0
        local j2 = tonumber(flag("AAJitOff2", 0)) or 0
        local ticks = math.max(1, math.floor((tonumber(flag("AAJitSpeed", 5)) or 5) + 0.5))
        aaJitterTicks = aaJitterTicks + 1
        if aaJitterTicks >= ticks then
            aaJitterTicks = 0
            aaJitterFlip = not aaJitterFlip
        end
        local chosen = aaJitterFlip and j2 or j1
        yawOffset = math.rad(chosen)
    end

    local finalYaw = baseYaw + yawOffset
    -- позиция из пина (стоим — зафиксирована), меняем только ориентацию
    local pinned = AntiAim.PinnedPosition or root.Position
    root.CFrame = CFrame.new(pinned) * CFrame.Angles(0, finalYaw, 0)
end

function AntiAim.Start()
    if AntiAim.Started then return end
    AntiAim.Started = true
    TaskManager.AddConnection("AntiAimApply", RunService.RenderStepped, AntiAim.Update)
    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, AntiAim.Shutdown)
    end
end

function AntiAim.Shutdown()
    TaskManager.RemoveConnection("AntiAimApply")
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if AntiAim.OriginalAutoRotate ~= nil then
                hum.AutoRotate = AntiAim.OriginalAutoRotate
                AntiAim.OriginalAutoRotate = nil
            elseif not hum.AutoRotate then
                hum.AutoRotate = true
            end
        end
    end
    AntiAim.Started = false
    aaJitterTicks = 0
    aaJitterFlip = false
    AntiAim.PinnedPosition = nil
    AntiAim.PinnedCharacter = nil
end

RageBot.Start()
RecoilKiller.Start()
NoSpread.Start()
AirShot.Start()
AntiAim.Start()

