function AntiAim.Update(deltaTime)
    local enabled = flag("AAEnabled", false) == true
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = findRootPart(char)

    if AntiAim.OriginalHumanoid and AntiAim.OriginalHumanoid ~= hum then
        if AntiAim.OriginalHumanoid.Parent then AntiAim.OriginalHumanoid.AutoRotate = AntiAim.OriginalAutoRotate end
        AntiAim.OriginalHumanoid, AntiAim.OriginalAutoRotate = nil, nil
    end
    if not enabled or not hum or hum.Health <= 0 or not root then
        if AntiAim.OriginalHumanoid then
            if AntiAim.OriginalHumanoid.Parent then AntiAim.OriginalHumanoid.AutoRotate = AntiAim.OriginalAutoRotate end
            AntiAim.OriginalHumanoid, AntiAim.OriginalAutoRotate = nil, nil
        end
        AntiAim.PinnedPosition, AntiAim.PinnedCharacter = nil, nil
        return
    end
    if not AntiAim.OriginalHumanoid then
        AntiAim.OriginalHumanoid, AntiAim.OriginalAutoRotate = hum, hum.AutoRotate
    end
    hum.AutoRotate = false

     
     
     
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
         
         
        local spinOff = tonumber(flag("AASpinOffset", 0)) or 0
        yawOffset = 0
        if spinOff ~= 0 then
            local rate = spinOff * 18  
            yawOffset = math.rad((os.clock() * rate) % 360)
        end
    elseif yawValue == "Jitter" then
         
         
         
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
    if AntiAim.OriginalHumanoid and AntiAim.OriginalHumanoid.Parent then
        AntiAim.OriginalHumanoid.AutoRotate = AntiAim.OriginalAutoRotate
    end
    AntiAim.OriginalHumanoid, AntiAim.OriginalAutoRotate = nil, nil
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
RapidFire.Start()
AntiAim.Start()

