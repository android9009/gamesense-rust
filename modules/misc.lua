local Misc = {Started = false}
do
    local particles, textures, effects, collisions = {}, {}, {}, {}
    local particleOn, textureOn, effectsOn = false, false, false
    local shadowOriginal, terrainOriginal, nameHumanoid, nameOriginal
    local fpsOriginal, fpsLast, cameraLast
    local active = false
    local function isParticle(object)
        return object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Smoke")
            or object:IsA("Fire") or object:IsA("Sparkles") or object:IsA("Beam")
    end
    local function consider(object)
        if particleOn and isParticle(object) then
            if particles[object] == nil then particles[object] = object.Enabled end
            if object.Enabled then object.Enabled = false end
        elseif textureOn and (object:IsA("Decal") or object:IsA("Texture")) then
            local character = LocalPlayer.Character
            if not character or not object:IsDescendantOf(character) then
                if textures[object] == nil then textures[object] = object.Transparency end
                if object.Transparency ~= 1 then object.Transparency = 1 end
            end
        end
    end
    local function considerEffect(object)
        if not effectsOn then return end
        if object:IsA("PostEffect") then
            if effects[object] == nil then effects[object] = {Enabled = object.Enabled} end
            if object.Enabled then object.Enabled = false end
        elseif object:IsA("Atmosphere") then
            if effects[object] == nil then effects[object] = {Density = object.Density, Haze = object.Haze, Glare = object.Glare} end
            object.Density, object.Haze, object.Glare = 0, 0, 0
        end
    end
    local function restoreProperty(store, property)
        for object, original in pairs(store) do
            if object.Parent then pcall(function() object[property] = original end) end
        end
        table.clear(store)
    end
    local function restoreEffects()
        for object, properties in pairs(effects) do
            if object.Parent then pcall(function() for key, value in pairs(properties) do object[key] = value end end) end
        end
        table.clear(effects)
    end
    local function restoreName()
        if nameHumanoid and nameHumanoid.Parent then nameHumanoid.DisplayName = nameOriginal end
        nameHumanoid, nameOriginal = nil, nil
    end
    local function restoreFPS()
        if fpsLast and fpsOriginal and setfpscap then pcall(setfpscap, fpsOriginal) end
        fpsLast, fpsOriginal = nil, nil
    end
    local function refreshCamera(camera)
        if cameraLast == camera then return end
        TaskManager.RemoveConnection("MiscCameraEffects")
        cameraLast = camera
        if camera then
            TaskManager.AddConnection("MiscCameraEffects", camera.ChildAdded, considerEffect)
            if effectsOn then for _, object in ipairs(camera:GetChildren()) do considerEffect(object) end end
        end
    end
    function Misc.Update()
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and findRootPart(character)
        local camera = Workspace.CurrentCamera
        refreshCamera(camera)
        if flag("MiscFPSUnlocker", false) == true and setfpscap then
            local requested = math.clamp(tonumber(flag("MiscFPSValue", 240)) or 240, 30, 999)
            if fpsLast ~= requested then
                if not fpsLast and getfpscap then
                    local ok, value = pcall(getfpscap)
                    if ok and type(value) == "number" then fpsOriginal = value end
                end
                local ok = pcall(setfpscap, requested)
                if ok then fpsLast = requested end
            end
        elseif fpsLast then restoreFPS() end

        local master = flag("MiscRemovals", false) == true
        local nextParticles = master and hasOption("MiscRemovalsList", "Particles")
        local nextTextures = master and hasOption("MiscRemovalsList", "Textures")
        local nextEffects = master and hasOption("MiscRemovalsList", "Post effects")
        local scanWorld = (nextParticles and not particleOn) or (nextTextures and not textureOn)
        local scanEffects = nextEffects and not effectsOn
        particleOn, textureOn, effectsOn = nextParticles, nextTextures, nextEffects
        if not particleOn and next(particles) then restoreProperty(particles, "Enabled") end
        if not textureOn and next(textures) then restoreProperty(textures, "Transparency") end
        if not effectsOn and next(effects) then restoreEffects() end
        if scanWorld then for _, object in ipairs(Workspace:GetDescendants()) do consider(object) end end
        if scanEffects then
            for _, object in ipairs(Lighting:GetChildren()) do considerEffect(object) end
            if camera then for _, object in ipairs(camera:GetChildren()) do considerEffect(object) end end
        end
        for object in pairs(particles) do
            if not object.Parent then particles[object] = nil
            elseif object.Enabled then object.Enabled = false end
        end
        for object in pairs(textures) do
            if not object.Parent then textures[object] = nil
            elseif object.Transparency ~= 1 then object.Transparency = 1 end
        end
        for object, properties in pairs(effects) do
            if not object.Parent then effects[object] = nil
            elseif properties.Enabled ~= nil then
                if object.Enabled then object.Enabled = false end
            else
                if object.Density ~= 0 then object.Density = 0 end
                if object.Haze ~= 0 then object.Haze = 0 end
                if object.Glare ~= 0 then object.Glare = 0 end
            end
        end
        local shadows = master and hasOption("MiscRemovalsList", "Shadows")
        if shadows then
            if shadowOriginal == nil then shadowOriginal = Lighting.GlobalShadows end
            if Lighting.GlobalShadows then Lighting.GlobalShadows = false end
        elseif shadowOriginal ~= nil then Lighting.GlobalShadows = shadowOriginal; shadowOriginal = nil end
        local terrain = master and hasOption("MiscRemovalsList", "Terrain decoration")
        if terrain then
            pcall(function()
                if terrainOriginal == nil then terrainOriginal = Workspace.Terrain.Decoration end
                if Workspace.Terrain.Decoration then Workspace.Terrain.Decoration = false end
            end)
        elseif terrainOriginal ~= nil then
            pcall(function() Workspace.Terrain.Decoration = terrainOriginal end)
            terrainOriginal = nil
        end
        if flag("MiscAntiFling", false) == true then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, part in ipairs(Entity.GetParts(player.Character)) do
                        if not part.Parent then continue end
                        if collisions[part] == nil then collisions[part] = part.CanCollide end
                        if part.CanCollide then part.CanCollide = false end
                        if part.AssemblyLinearVelocity.Magnitude > 80 then part.AssemblyLinearVelocity = Vector3.zero end
                        if part.AssemblyAngularVelocity.Magnitude > 80 then part.AssemblyAngularVelocity = Vector3.zero end
                    end
                end
            end
            for part in pairs(collisions) do if not part.Parent then collisions[part] = nil end end
            if root and root.AssemblyLinearVelocity.Magnitude > 250 then root.AssemblyLinearVelocity = Vector3.zero end
        elseif next(collisions) then restoreProperty(collisions, "CanCollide") end
        if flag("MiscHideName", false) == true and humanoid then
            if nameHumanoid ~= humanoid then restoreName(); nameHumanoid, nameOriginal = humanoid, humanoid.DisplayName end
            if humanoid.DisplayName ~= "Protected" then humanoid.DisplayName = "Protected" end
        elseif nameHumanoid then restoreName() end
    end
    function Misc.Start()
        if active then return end
        active, Misc.Started = true, true
        TaskManager.AddConnection("MiscApply", RunService.RenderStepped, Misc.Update)
        TaskManager.AddConnection("MiscWorldAdded", Workspace.DescendantAdded, consider)
        TaskManager.AddConnection("MiscLightingAdded", Lighting.ChildAdded, considerEffect)
    end
    function Misc.Shutdown()
        active, Misc.Started = false, false
        for _, id in ipairs({"MiscApply", "MiscWorldAdded", "MiscLightingAdded", "MiscCameraEffects"}) do TaskManager.RemoveConnection(id) end
        restoreProperty(particles, "Enabled"); restoreProperty(textures, "Transparency")
        restoreProperty(collisions, "CanCollide"); restoreEffects(); restoreName(); restoreFPS()
        if shadowOriginal ~= nil then Lighting.GlobalShadows = shadowOriginal; shadowOriginal = nil end
        if terrainOriginal ~= nil then pcall(function() Workspace.Terrain.Decoration = terrainOriginal end); terrainOriginal = nil end
        particleOn, textureOn, effectsOn, cameraLast = false, false, false, nil
    end
    table.insert(Library.UnloadHooks, Misc.Shutdown)
end
Misc.Start()
