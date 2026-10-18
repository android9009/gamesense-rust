local Movement = {
    Started = false,
    Platform = nil,
    LockedY = nil,
    JumpPowerApplied = false,
    GravityApplied = false,
    InfJumpConn = nil,
    ClickTPConn = nil,
    LastClickTime = 0,
    Fly = {
        Active = false,
        BodyGyro = nil,
        BodyVelocity = nil,
    },
}

do
local collisionOriginal = {}
local flyHumanoid, platformStandOriginal
local jumpHumanoid, jumpPowerOriginal, jumpHeightOriginal, useJumpOriginal
local gravityOriginal
local function restoreFlyState()
    for part, original in pairs(collisionOriginal) do
        if part.Parent then part.CanCollide = original end
    end
    table.clear(collisionOriginal)
    if flyHumanoid and flyHumanoid.Parent then flyHumanoid.PlatformStand = platformStandOriginal end
    flyHumanoid, platformStandOriginal = nil, nil
end
local function restoreJump()
    if jumpHumanoid and jumpHumanoid.Parent then
        jumpHumanoid.UseJumpPower = useJumpOriginal
        jumpHumanoid.JumpPower = jumpPowerOriginal
        jumpHumanoid.JumpHeight = jumpHeightOriginal
    end
    jumpHumanoid = nil
    Movement.JumpPowerApplied = false
end
local function restoreGravity()
    if gravityOriginal ~= nil then Workspace.Gravity = gravityOriginal; gravityOriginal = nil end
    Movement.GravityApplied = false
end

function Movement.Update(deltaTime)
    local char = LocalPlayer.Character
    if not char or not Entity.IsAlive(LocalPlayer) then
        restoreFlyState()
        restoreJump()
        if not bindOn(flag("MovementGravity", false) == true, "MovementGravityBind") then restoreGravity() end
        if Movement.Platform and Movement.Platform.Parent then
            Movement.Platform:Destroy()
            Movement.Platform = nil
        end
        if Movement.Fly.Active then
            if Movement.Fly.BodyGyro then Movement.Fly.BodyGyro:Destroy(); Movement.Fly.BodyGyro = nil end
            if Movement.Fly.BodyVelocity then Movement.Fly.BodyVelocity:Destroy(); Movement.Fly.BodyVelocity = nil end
            Movement.Fly.Active = false
        end
        return
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = findRootPart(char)
    if not hum or not root then
        return
    end

    if flyHumanoid and flyHumanoid ~= hum then restoreFlyState() end
    if jumpHumanoid and jumpHumanoid ~= hum then restoreJump() end
    local cam = Workspace.CurrentCamera

     
    local flyEnabled = bindOn(flag("MovementFly", false) == true, "MovementFlyBind")
    if flyEnabled and cam then
        local speed = math.clamp(tonumber(flag("MovementFlySpeed", 50)) or 50, 0, 500)
        
        if not Movement.Fly.Active or not Movement.Fly.BodyGyro or not Movement.Fly.BodyVelocity or Movement.Fly.BodyGyro.Parent ~= root then
            Movement.Fly.Active = true
            if Movement.Fly.BodyGyro then Movement.Fly.BodyGyro:Destroy() end
            if Movement.Fly.BodyVelocity then Movement.Fly.BodyVelocity:Destroy() end

            local bg = Instance.new("BodyGyro")
            bg.P = 9e4
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = cam.CFrame
            bg.Parent = root
            Movement.Fly.BodyGyro = bg

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.zero
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Parent = root
            Movement.Fly.BodyVelocity = bv

            if flyHumanoid ~= hum then flyHumanoid, platformStandOriginal = hum, hum.PlatformStand end
            hum.PlatformStand = true
        end

         
        for _, child in ipairs(Entity.GetParts(char)) do
            if child.Parent then
                if collisionOriginal[child] == nil then collisionOriginal[child] = child.CanCollide end
                if child.CanCollide then child.CanCollide = false end
            end
        end

        local f = 0
        local b = 0
        local l = 0
        local r = 0
        local q = 0
        local e = 0

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then f = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then b = -1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then l = -1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then r = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then e = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then q = -1 end

        local moveVector = ((cam.CFrame.LookVector * (f + b))
            + ((cam.CFrame * CFrame.new((l + r), (q + e) * 0.2, 0).Position) - cam.CFrame.Position))

        if Movement.Fly.BodyVelocity and Movement.Fly.BodyVelocity.Parent then
            Movement.Fly.BodyVelocity.Velocity = moveVector.Magnitude > 0 and moveVector.Unit * speed or Vector3.zero
        end
        if Movement.Fly.BodyGyro and Movement.Fly.BodyGyro.Parent then
            Movement.Fly.BodyGyro.CFrame = cam.CFrame
        end
    else
        if Movement.Fly.Active then
            Movement.Fly.Active = false
            if Movement.Fly.BodyGyro then
                Movement.Fly.BodyGyro:Destroy()
                Movement.Fly.BodyGyro = nil
            end
            if Movement.Fly.BodyVelocity then
                Movement.Fly.BodyVelocity:Destroy()
                Movement.Fly.BodyVelocity = nil
            end
            if hum and hum.Parent then
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            end
            restoreFlyState()
            pcall(function()
                cam.CameraType = Enum.CameraType.Custom
                if hum and hum.Parent then
                    cam.CameraSubject = hum
                end
            end)
        end
    end

     
    local speedhackEnabled = bindOn(flag("MovementSpeedhack", false) == true, "MovementSpeedhackBind")
    if speedhackEnabled and not flyEnabled then
        local speed = math.clamp(tonumber(flag("MovementSpeedhackSpeed", 50)) or 50, 0, 500)
        if hum.MoveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity = Vector3.new(
                hum.MoveDirection.X * speed,
                root.AssemblyLinearVelocity.Y,
                hum.MoveDirection.Z * speed
            )
        end
    end

     
    local jumpPowerEnabled = bindOn(flag("MovementJumpPower", false) == true, "MovementJumpPowerBind")
    if jumpPowerEnabled then
        local power = math.clamp(tonumber(flag("MovementJumpPowerValue", 50)) or 50, 0, 1000)
        if jumpHumanoid ~= hum then
            jumpHumanoid, jumpPowerOriginal, jumpHeightOriginal, useJumpOriginal = hum, hum.JumpPower, hum.JumpHeight, hum.UseJumpPower
        end
        hum.UseJumpPower = true
        hum.JumpPower = power
        hum.JumpHeight = power * 0.144
        Movement.JumpPowerApplied = true
    elseif Movement.JumpPowerApplied then
        restoreJump()
    end

     
    local gravityEnabled = bindOn(flag("MovementGravity", false) == true, "MovementGravityBind")
    if gravityEnabled then
        local grav = math.clamp(tonumber(flag("MovementGravityValue", 196)) or 196, 0, 1000)
        if gravityOriginal == nil then gravityOriginal = Workspace.Gravity end
        if Workspace.Gravity ~= grav then Workspace.Gravity = grav end
        Movement.GravityApplied = true
    elseif Movement.GravityApplied then
        restoreGravity()
    end

     
    local walkOnEnabled = bindOn(flag("MovementWalkOn", false) == true, "MovementWalkOnBind")
    if walkOnEnabled then
        local mode = flag("MovementWalkOnMode", "Water")
        local shouldPlace = false

        if mode == "Always" then
            shouldPlace = true
        elseif mode == "Water" then
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Swimming then
                shouldPlace = true
            else
                local checkPos = root.Position - Vector3.new(0, 2.5, 0)
                local voxel = Workspace.Terrain:ReadVoxels(Region3.new(checkPos - Vector3.new(1, 1, 1), checkPos + Vector3.new(1, 1, 1)):ExpandToGrid(4))
                if voxel and voxel[1] and voxel[1][1] and voxel[1][1][1] == Enum.Material.Water then
                    shouldPlace = true
                end
            end
        elseif mode == "Void" then
            if root.Position.Y < -10 then
                shouldPlace = true
            end
        end

        if shouldPlace then
            if not Movement.Platform or not Movement.Platform.Parent then
                local p = Instance.new("Part")
                p.Name = "GS_WalkOnPlatform"
                p.Size = Vector3.new(30, 1, 30)
                p.Anchored = true
                p.CanCollide = true
                p.Transparency = 1
                p.Material = Enum.Material.SmoothPlastic
                p.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
                Movement.LockedY = root.Position.Y - (hum.HipHeight or 2) - 1.2
                p.CFrame = CFrame.new(root.Position.X, Movement.LockedY, root.Position.Z)
                p.Parent = Workspace
                Movement.Platform = p
            end

             
            if Movement.LockedY == nil then
                Movement.LockedY = root.Position.Y - (hum.HipHeight or 2) - 1.2
            end

             
             
            local currentPos = Movement.Platform.Position
            local deltaX = root.Position.X - currentPos.X
            local deltaZ = root.Position.Z - currentPos.Z
            if (deltaX * deltaX + deltaZ * deltaZ) > 16 then
                Movement.Platform.CFrame = CFrame.new(root.Position.X, Movement.LockedY, root.Position.Z)
            end
        else
            Movement.LockedY = nil
            if Movement.Platform and Movement.Platform.Parent then
                Movement.Platform:Destroy()
                Movement.Platform = nil
            end
        end
    else
        Movement.LockedY = nil
        if Movement.Platform and Movement.Platform.Parent then
            Movement.Platform:Destroy()
            Movement.Platform = nil
        end
    end
end

function Movement.Start()
    if Movement.Started then return end
    Movement.Started = true
    TaskManager.AddConnection("MovementApply", RunService.Heartbeat, Movement.Update)

     
    Movement.InfJumpConn = TaskManager.AddConnection("MovementInfJump", UserInputService.JumpRequest, function()
        if flag("MovementInfJump", false) == true then
            local char = LocalPlayer.Character
            if char and Entity.IsAlive(LocalPlayer) then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = findRootPart(char)
                if hum and root then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    local jumpVel = hum.JumpPower > 0 and hum.JumpPower or 50
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, jumpVel, root.AssemblyLinearVelocity.Z)
                end
            end
        end
    end)

     
    Movement.ClickTPConn = TaskManager.AddConnection("MovementClickTP", UserInputService.InputBegan, function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local clickTPActive = bindOn(flag("MovementClickTP", false) == true, "MovementClickTPBind")
            if clickTPActive then
                local now = os.clock()
                if now - Movement.LastClickTime < 0.2 then return end
                Movement.LastClickTime = now

                local mousePos = UserInputService:GetMouseLocation()
                local cam = Workspace.CurrentCamera
                if cam then
                    local unitRay = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    params.FilterDescendantsInstances = {LocalPlayer.Character}
                    local hit = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1500, params)
                    local targetPos = hit and hit.Position or (unitRay.Origin + unitRay.Direction * 200)
                    local char = LocalPlayer.Character
                    local root = char and findRootPart(char)
                    if root then
                        root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3.5, 0), targetPos + Vector3.new(0, 3.5, 0) + cam.CFrame.LookVector)
                    end
                end
            end
        end
    end)

    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, Movement.Shutdown)
    end
end

function Movement.Shutdown()
    TaskManager.RemoveConnection("MovementApply")
    TaskManager.RemoveConnection("MovementInfJump")
    TaskManager.RemoveConnection("MovementClickTP")
    if Movement.Fly.BodyGyro then
        Movement.Fly.BodyGyro:Destroy()
        Movement.Fly.BodyGyro = nil
    end
    if Movement.Fly.BodyVelocity then
        Movement.Fly.BodyVelocity:Destroy()
        Movement.Fly.BodyVelocity = nil
    end
    Movement.Fly.Active = false
    if Movement.Platform and Movement.Platform.Parent then
        Movement.Platform:Destroy()
        Movement.Platform = nil
    end
    restoreFlyState()
    restoreJump()
    restoreGravity()
    Movement.Started = false
end
Movement.Start()

 
 
 

end
