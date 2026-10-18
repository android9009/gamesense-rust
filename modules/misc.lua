local Misc = {Started = false}
do
    local particles, textures, effects, collisions = {}, {}, {}, {}
    local particleOn, textureOn, effectsOn = false, false, false
    local shadowOriginal, terrainOriginal, nameHumanoid, nameOriginal
    local fpsOriginal, fpsLast, cameraLast
    local active = false

    -- Infinite ammo: _ammo + magazineSize -> 99999999999, reloadTime -> 0.1.
    -- ВАЖНО: патроны в магазине игра держит не в атрибутах Tool, а внутри
    -- BlasterController (self.ammo) - поэтому ниже ещё патчится canShoot.
    local INF_AMMO_VALUE = 99999999999
    local INF_RELOAD_TIME = 0.1
    local INF_AMMO_ATTRS = {"_ammo", "magazineSize", "reloadTime"}
    local infAmmoOriginals = {}
    local infAmmoLastTool = nil
    local function infCoerce(raw, desired)
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
    local function infRead(record)
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
    local function infWrite(record, value)
        if not record or not record.Inst or not record.Inst.Parent then
            return
        end
        if infRead(record) == value then
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
    local function infCollectHolders(tool)
        local records = {}
        local function consider(inst)
            for _, attr in ipairs(INF_AMMO_ATTRS) do
                local ok, value = pcall(function()
                    return inst:GetAttribute(attr)
                end)
                if ok and value ~= nil then
                    records[#records + 1] = {Inst = inst, Attr = attr, Kind = "attribute", Original = value}
                end
            end
            if (inst:IsA("NumberValue") or inst:IsA("IntValue") or inst:IsA("StringValue") or inst:IsA("BoolValue")) then
                for _, attr in ipairs(INF_AMMO_ATTRS) do
                    if inst.Name == attr then
                        records[#records + 1] = {Inst = inst, Attr = attr, Kind = "value", Original = inst.Value}
                    end
                end
            end
        end
        consider(tool)
        for _, descendant in ipairs(tool:GetDescendants()) do
            consider(descendant)
        end
        return records
    end
    local function infRestoreTool(tool)
        local records = infAmmoOriginals[tool]
        if not records then
            return
        end
        for _, record in ipairs(records) do
            infWrite(record, record.Original)
        end
        infAmmoOriginals[tool] = nil
    end
    local function restoreInfiniteAmmo()
        if infAmmoLastTool then
            infRestoreTool(infAmmoLastTool)
            infAmmoLastTool = nil
        end
        local tools = {}
        for tool in pairs(infAmmoOriginals) do
            tools[#tools + 1] = tool
        end
        for _, tool in ipairs(tools) do
            infRestoreTool(tool)
        end
    end
    -- --- BlasterController hook: держим self.ammo (патроны в магазине) на максимуме ---
    local infControllerModule, infControllerWrapper, infControllerOriginal = nil, nil, nil
    local INF_CONTROLLER_MAG_FIELDS = {"magazineSize", "magSize", "maxAmmo", "maxMagazineSize"}
    local function infFindController()
        if infControllerModule then
            return infControllerModule
        end
        local ok, result = pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local blaster = rs and rs:FindFirstChild("Blaster")
            local scripts = blaster and blaster:FindFirstChild("Scripts")
            local mod = scripts and scripts:FindFirstChild("BlasterController")
            if not (mod and mod:IsA("ModuleScript")) then
                return nil
            end
            local loaded = require(mod)
            if type(loaded) == "table" and type(loaded.canShoot) == "function" then
                return loaded
            end
            return nil
        end)
        if ok and type(result) == "table" then
            infControllerModule = result
            return result
        end
        return nil
    end
    local function infForceControllerAmmo(self)
        if type(self) ~= "table" then
            return
        end
        if type(self.ammo) == "number" then
            self.ammo = INF_AMMO_VALUE
        end
        for _, field in ipairs(INF_CONTROLLER_MAG_FIELDS) do
            if type(self[field]) == "number" then
                self[field] = INF_AMMO_VALUE
            end
        end
        if type(self.reloadTime) == "number" then
            self.reloadTime = INF_RELOAD_TIME
        end
    end
    local function infPatchController()
        local mod = infFindController()
        if not mod then
            return
        end
        if infControllerWrapper and mod.canShoot == infControllerWrapper then
            return
        end
        local original = mod.canShoot
        if type(original) ~= "function" then
            return
        end
        local wrapper = function(self, ...)
            if flag("MiscInfiniteAmmo", false) == true then
                pcall(infForceControllerAmmo, self)
            end
            return original(self, ...)
        end
        infControllerOriginal = original
        infControllerWrapper = wrapper
        local ok = pcall(function()
            mod.canShoot = wrapper
        end)
        if not ok then
            infControllerWrapper, infControllerOriginal = nil, nil
        end
    end
    local function infRestoreController()
        local mod = infControllerModule
        if mod and infControllerWrapper and mod.canShoot == infControllerWrapper then
            pcall(function()
                mod.canShoot = infControllerOriginal
            end)
        end
        -- Если поверх нас встал другой враппер (AirShot), наш остаётся в цепочке,
        -- но при выключённом флаге он просто пропускает вызов дальше.
    end

    local function applyInfiniteAmmo()
        local on = flag("MiscInfiniteAmmo", false) == true
        if on then
            infPatchController()
        else
            infRestoreController()
        end
        local character = LocalPlayer and LocalPlayer.Character
        local tool = on and character and character:FindFirstChildOfClass("Tool") or nil
        if infAmmoLastTool and infAmmoLastTool ~= tool then
            infRestoreTool(infAmmoLastTool)
        end
        infAmmoLastTool = tool
        if not on or not tool then
            return
        end
        local records = infAmmoOriginals[tool]
        if not records then
            records = infCollectHolders(tool)
            infAmmoOriginals[tool] = records
        end
        for _, record in ipairs(records) do
            local desired = record.Attr == "reloadTime" and INF_RELOAD_TIME or INF_AMMO_VALUE
            infWrite(record, infCoerce(record.Original, desired))
        end
    end

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
        applyInfiniteAmmo()
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
        infRestoreController()
        restoreInfiniteAmmo()
        restoreProperty(particles, "Enabled"); restoreProperty(textures, "Transparency")
        restoreProperty(collisions, "CanCollide"); restoreEffects(); restoreName(); restoreFPS()
        if shadowOriginal ~= nil then Lighting.GlobalShadows = shadowOriginal; shadowOriginal = nil end
        if terrainOriginal ~= nil then pcall(function() Workspace.Terrain.Decoration = terrainOriginal end); terrainOriginal = nil end
        particleOn, textureOn, effectsOn, cameraLast = false, false, false, nil
    end
    table.insert(Library.UnloadHooks, Misc.Shutdown)
end
Misc.Start()
