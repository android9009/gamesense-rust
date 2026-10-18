local Misc = {
    Started = false,
    HiddenDisplayName = nil,
    Removals = {
        Particles = {},
        Textures = {},
        Shadows = nil,
        TerrainDecoration = nil,
        PostEffects = {},
    },
}

function Misc.Update(deltaTime)
    local char = LocalPlayer.Character
    local root = char and findRootPart(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local cam = Workspace.CurrentCamera

    -- 1. FPS Unlocker
    if flag("MiscFPSUnlocker", false) == true then
        local fpsVal = math.clamp(tonumber(flag("MiscFPSValue", 240)) or 240, 30, 999)
        if setfpscap then
            pcall(setfpscap, fpsVal)
        end
    end

    -- 2. Removals: независимое применение и восстановление каждой категории live
    local removalsMaster = flag("MiscRemovals", false) == true
    local rem = Misc.Removals

    -- А. Particles
    local particlesOn = removalsMaster and hasOption("MiscRemovalsList", "Particles")
    if particlesOn then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Beam") then
                if rem.Particles[obj] == nil then
                    rem.Particles[obj] = obj.Enabled
                end
                if obj.Enabled then
                    obj.Enabled = false
                end
            end
        end
    elseif next(rem.Particles) then
        for obj, orig in pairs(rem.Particles) do
            if obj and obj.Parent then
                pcall(function() obj.Enabled = orig end)
            end
        end
        table.clear(rem.Particles)
    end

    -- Б. Textures
    local texturesOn = removalsMaster and hasOption("MiscRemovalsList", "Textures")
    if texturesOn then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (obj:IsA("Decal") or obj:IsA("Texture")) and not (char and obj:IsDescendantOf(char)) then
                if rem.Textures[obj] == nil then
                    rem.Textures[obj] = obj.Transparency
                end
                if obj.Transparency < 1 then
                    obj.Transparency = 1
                end
            end
        end
    elseif next(rem.Textures) then
        for obj, orig in pairs(rem.Textures) do
            if obj and obj.Parent then
                pcall(function() obj.Transparency = orig end)
            end
        end
        table.clear(rem.Textures)
    end

    -- В. Shadows
    local shadowsOn = removalsMaster and hasOption("MiscRemovalsList", "Shadows")
    if shadowsOn then
        if rem.Shadows == nil then
            rem.Shadows = Lighting.GlobalShadows
        end
        if Lighting.GlobalShadows then
            Lighting.GlobalShadows = false
        end
    elseif rem.Shadows ~= nil then
        Lighting.GlobalShadows = rem.Shadows
        rem.Shadows = nil
    end

    -- Г. Terrain decoration
    local terrainOn = removalsMaster and hasOption("MiscRemovalsList", "Terrain decoration")
    if terrainOn then
        pcall(function()
            if rem.TerrainDecoration == nil then
                rem.TerrainDecoration = Workspace.Terrain.Decoration
            end
            if Workspace.Terrain.Decoration then
                Workspace.Terrain.Decoration = false
            end
        end)
    elseif rem.TerrainDecoration ~= nil then
        pcall(function() Workspace.Terrain.Decoration = rem.TerrainDecoration end)
        rem.TerrainDecoration = nil
    end

    -- Д. Post effects
    local postEffectsOn = removalsMaster and hasOption("MiscRemovalsList", "Post effects")
    if postEffectsOn then
        local checkContainers = {Lighting, cam}
        for _, container in ipairs(checkContainers) do
            if container then
                for _, fx in ipairs(container:GetChildren()) do
                    if fx:IsA("PostEffect") or fx:IsA("BloomEffect") or fx:IsA("BlurEffect") or fx:IsA("ColorCorrectionEffect") or fx:IsA("SunRaysEffect") or fx:IsA("DepthOfFieldEffect") or fx:IsA("Atmosphere") then
                        if rem.PostEffects[fx] == nil then
                            rem.PostEffects[fx] = fx.Enabled
                        end
                        if fx.Enabled then
                            fx.Enabled = false
                        end
                    end
                end
            end
        end
    elseif next(rem.PostEffects) then
        for fx, orig in pairs(rem.PostEffects) do
            if fx and fx.Parent then
                pcall(function() fx.Enabled = orig end)
            end
        end
        table.clear(rem.PostEffects)
    end

    -- 3. Anti-fling
    if flag("MiscAntiFling", false) == true then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        if part.AssemblyLinearVelocity.Magnitude > 80 then
                            part.AssemblyLinearVelocity = Vector3.zero
                        end
                        if part.AssemblyAngularVelocity.Magnitude > 80 then
                            part.AssemblyAngularVelocity = Vector3.zero
                        end
                    end
                end
            end
        end
        if root and root.AssemblyLinearVelocity.Magnitude > 250 then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end

    -- 4. Hide name
    local hideNameOn = flag("MiscHideName", false) == true
    if hideNameOn and hum then
        if Misc.HiddenDisplayName == nil then
            Misc.HiddenDisplayName = hum.DisplayName
        end
        hum.DisplayName = "Protected"
    elseif not hideNameOn and hum and Misc.HiddenDisplayName ~= nil then
        hum.DisplayName = Misc.HiddenDisplayName
        Misc.HiddenDisplayName = nil
    end
end

function Misc.Start()
    if Misc.Started then return end
    Misc.Started = true
    TaskManager.AddConnection("MiscApply", RunService.RenderStepped, Misc.Update)
    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, Misc.Shutdown)
    end
end

function Misc.Shutdown()
    TaskManager.RemoveConnection("MiscApply")
    local rem = Misc.Removals
    for obj, orig in pairs(rem.Particles) do
        if obj and obj.Parent then pcall(function() obj.Enabled = orig end) end
    end
    table.clear(rem.Particles)

    for obj, orig in pairs(rem.Textures) do
        if obj and obj.Parent then pcall(function() obj.Transparency = orig end) end
    end
    table.clear(rem.Textures)

    if rem.Shadows ~= nil then
        Lighting.GlobalShadows = rem.Shadows
        rem.Shadows = nil
    end

    if rem.TerrainDecoration ~= nil then
        pcall(function() Workspace.Terrain.Decoration = rem.TerrainDecoration end)
        rem.TerrainDecoration = nil
    end

    for fx, orig in pairs(rem.PostEffects) do
        if fx and fx.Parent then pcall(function() fx.Enabled = orig end) end
    end
    table.clear(rem.PostEffects)

    if Misc.HiddenDisplayName ~= nil and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.DisplayName = Misc.HiddenDisplayName end
        Misc.HiddenDisplayName = nil
    end
    Misc.Started = false
end
Misc.Start()

