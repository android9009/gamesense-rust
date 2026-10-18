local Misc = {Started = false}
do
    local particles, textures, effects, collisions = {}, {}, {}, {}
    local particleOn, textureOn, effectsOn = false, false, false
    local shadowOriginal, terrainOriginal, nameHumanoid, nameOriginal
    local fpsOriginal, fpsLast, cameraLast
    local active = false

    -- Fast reload: reloadTime -> 0.1 на оружии в руках и в BlasterController.
    -- Всё одной таблицей: рантайм склеен в один чанк, лимит Luau - 200 локалов.
    local FastReload = {
        Value = 0.1,
        Attrs = {"reloadTime"},
        Originals = {},
        LastTool = nil,
        Controller = nil,
        Wrapper = nil,
        OriginalFn = nil,
        ReloadWrapper = nil,
        ReloadOriginal = nil,
    }
    function FastReload.Coerce(raw)
        if typeof(raw) == "Vector2" then
            return Vector2.new(FastReload.Value, FastReload.Value)
        end
        if typeof(raw) == "Vector3" then
            return Vector3.new(FastReload.Value, FastReload.Value, FastReload.Value)
        end
        if type(raw) == "string" then
            return tostring(FastReload.Value)
        end
        if type(raw) == "boolean" then
            return true
        end
        return FastReload.Value
    end
    function FastReload.Read(record)
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
    function FastReload.Write(record, value)
        if not record or not record.Inst or not record.Inst.Parent then
            return
        end
        if FastReload.Read(record) == value then
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
    function FastReload.Collect(tool)
        local records = {}
        local function consider(inst)
            for _, attr in ipairs(FastReload.Attrs) do
                local ok, value = pcall(function()
                    return inst:GetAttribute(attr)
                end)
                if ok and value ~= nil then
                    records[#records + 1] = {Inst = inst, Attr = attr, Kind = "attribute", Original = value}
                end
            end
            if inst:IsA("NumberValue") or inst:IsA("IntValue") or inst:IsA("StringValue") or inst:IsA("BoolValue") then
                for _, attr in ipairs(FastReload.Attrs) do
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
    function FastReload.RestoreTool(tool)
        local records = FastReload.Originals[tool]
        if not records then
            return
        end
        for _, record in ipairs(records) do
            FastReload.Write(record, record.Original)
        end
        FastReload.Originals[tool] = nil
    end
    function FastReload.RestoreAll()
        if FastReload.LastTool then
            FastReload.RestoreTool(FastReload.LastTool)
            FastReload.LastTool = nil
        end
        local tools = {}
        for tool in pairs(FastReload.Originals) do
            tools[#tools + 1] = tool
        end
        for _, tool in ipairs(tools) do
            FastReload.RestoreTool(tool)
        end
    end
    function FastReload.FindController()
        if FastReload.Controller then
            return FastReload.Controller
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
            FastReload.Controller = result
            return result
        end
        return nil
    end
    function FastReload.Force(self)
        if type(self) == "table" and type(self.reloadTime) == "number" then
            self.reloadTime = FastReload.Value
        end
    end
    function FastReload.PatchController()
        local mod = FastReload.FindController()
        if not mod then
            return
        end
        if type(mod.canShoot) == "function" and mod.canShoot ~= FastReload.Wrapper then
            local original = mod.canShoot
            local wrapper = function(self, ...)
                if flag("MiscFastReload", false) == true then
                    pcall(FastReload.Force, self)
                end
                return original(self, ...)
            end
            FastReload.OriginalFn = original
            FastReload.Wrapper = wrapper
            local ok = pcall(function()
                mod.canShoot = wrapper
            end)
            if not ok then
                FastReload.Wrapper, FastReload.OriginalFn = nil, nil
            end
        end
        if type(mod.reload) == "function" and mod.reload ~= FastReload.ReloadWrapper then
            local originalReload = mod.reload
            local reloadWrapper = function(self, ...)
                if flag("MiscFastReload", false) == true then
                    pcall(FastReload.Force, self)
                end
                return originalReload(self, ...)
            end
            FastReload.ReloadOriginal = originalReload
            FastReload.ReloadWrapper = reloadWrapper
            local ok = pcall(function()
                mod.reload = reloadWrapper
            end)
            if not ok then
                FastReload.ReloadWrapper, FastReload.ReloadOriginal = nil, nil
            end
        end
    end
    function FastReload.RestoreController()
        local mod = FastReload.Controller
        if not mod then
            return
        end
        if FastReload.Wrapper and mod.canShoot == FastReload.Wrapper then
            pcall(function()
                mod.canShoot = FastReload.OriginalFn
            end)
        end
        if FastReload.ReloadWrapper and mod.reload == FastReload.ReloadWrapper then
            pcall(function()
                mod.reload = FastReload.ReloadOriginal
            end)
        end
    end
    function FastReload.Apply()
        local on = flag("MiscFastReload", false) == true
        if on then
            FastReload.PatchController()
        else
            FastReload.RestoreController()
        end
        local character = LocalPlayer and LocalPlayer.Character
        local tool = on and character and character:FindFirstChildOfClass("Tool") or nil
        if FastReload.LastTool and FastReload.LastTool ~= tool then
            FastReload.RestoreTool(FastReload.LastTool)
        end
        FastReload.LastTool = tool
        if not on or not tool then
            return
        end
        local records = FastReload.Originals[tool]
        if not records then
            records = FastReload.Collect(tool)
            FastReload.Originals[tool] = records
        end
        for _, record in ipairs(records) do
            FastReload.Write(record, FastReload.Coerce(record.Original))
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
        FastReload.Apply()
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
        FastReload.RestoreController()
        FastReload.RestoreAll()
        restoreProperty(particles, "Enabled"); restoreProperty(textures, "Transparency")
        restoreProperty(collisions, "CanCollide"); restoreEffects(); restoreName(); restoreFPS()
        if shadowOriginal ~= nil then Lighting.GlobalShadows = shadowOriginal; shadowOriginal = nil end
        if terrainOriginal ~= nil then pcall(function() Workspace.Terrain.Decoration = terrainOriginal end); terrainOriginal = nil end
        particleOn, textureOn, effectsOn, cameraLast = false, false, false, nil
    end
    table.insert(Library.UnloadHooks, Misc.Shutdown)
end
Misc.Start()
