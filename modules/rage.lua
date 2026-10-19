local Misc = {Started = false}
do
    local particles, textures, effects, collisions = {}, {}, {}, {}
    local particleOn, textureOn, effectsOn = false, false, false
    local shadowOriginal, terrainOriginal, nameHumanoid, nameOriginal
    local fpsOriginal, fpsLast, cameraLast
    local active = false

    -- Fast reload v2: reloadTime НЕ трогаем (от него игра останавливает анимацию
    -- через 0.1 сек, а патроны досылает по полному циклу - получался рассинхрон).
    -- Вместо этого при старте перезарядки: ускоряем анимацию перезарядки до ~0.1 сек
    -- и через 0.1 сек досылаем патроны в контроллере. Одной таблицей (лимит локалов).
    local FastReload = {
        Value = 0.1,
        Controller = nil,
        Wrapper = nil,
        OriginalFn = nil,
        ReloadWrapper = nil,
        ReloadOriginal = nil,
        Pending = nil,
    }
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
            if type(loaded) == "table" and (type(loaded.canShoot) == "function" or type(loaded.reload) == "function") then
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
    function FastReload.Capacity(controller)
        if type(controller) == "table" then
            for _, field in ipairs({"magazineSize", "magSize", "maxAmmo", "maxMagazineSize"}) do
                if type(controller[field]) == "number" then
                    return controller[field]
                end
            end
        end
        local character = LocalPlayer and LocalPlayer.Character
        local tool = character and character:FindFirstChildOfClass("Tool")
        if tool then
            local ok, value = pcall(function()
                return tool:GetAttribute("magazineSize")
            end)
            if ok and type(value) == "number" then
                return value
            end
            for _, descendant in ipairs(tool:GetDescendants()) do
                local okDesc, descValue = pcall(function()
                    return descendant:GetAttribute("magazineSize")
                end)
                if okDesc and type(descValue) == "number" then
                    return descValue
                end
            end
        end
        return nil
    end
    function FastReload.SpeedUpAnimations(controller)
        local function adjust(track)
            if track and typeof(track) == "Instance" and track:IsA("AnimationTrack")
                and not track.Looped and track.Length and track.Length > FastReload.Value then
                pcall(function()
                    track:AdjustSpeed(track.Length / FastReload.Value)
                end)
            end
        end
        if type(controller) == "table" then
            for _, value in pairs(controller) do
                adjust(value)
            end
        end
        local roots = {}
        local character = LocalPlayer and LocalPlayer.Character
        if character then
            roots[#roots + 1] = character
        end
        local camera = Workspace and Workspace.CurrentCamera
        if camera then
            roots[#roots + 1] = camera
        end
        for _, root in ipairs(roots) do
            for _, descendant in ipairs(root:GetDescendants()) do
                if descendant:IsA("Animator") or descendant:IsA("AnimationController") then
                    local ok, tracks = pcall(function()
                        return descendant:GetPlayingAnimationTracks()
                    end)
                    if ok and tracks then
                        for _, track in ipairs(tracks) do
                            adjust(track)
                        end
                    end
                end
            end
        end
    end
    function FastReload.Finish(controller)
        local capacity = FastReload.Capacity(controller)
        if capacity and type(controller.ammo) == "number" then
            controller.ammo = capacity
        end
        if controller.reloading ~= nil then
            controller.reloading = false
        end
        -- Синхроним атрибут _ammo, чтобы HUD сразу показал полный магазин.
        if capacity then
            local character = LocalPlayer and LocalPlayer.Character
            local tool = character and character:FindFirstChildOfClass("Tool")
            if tool then
                local function syncAmmo(inst)
                    local ok, value = pcall(function()
                        return inst:GetAttribute("_ammo")
                    end)
                    if ok and value ~= nil then
                        pcall(function()
                            inst:SetAttribute("_ammo", capacity)
                        end)
                    end
                end
                syncAmmo(tool)
                for _, descendant in ipairs(tool:GetDescendants()) do
                    syncAmmo(descendant)
                end
            end
        end
    end
    function FastReload.Begin(controller)
        if type(controller) ~= "table" or FastReload.Pending == controller then
            return
        end
        FastReload.Pending = controller
        task.spawn(function()
            for _ = 1, 5 do
                FastReload.SpeedUpAnimations(controller)
                task.wait(0.02)
            end
        end)
        task.delay(FastReload.Value, function()
            if FastReload.Pending == controller then
                FastReload.Pending = nil
            end
            if flag("MiscFastReload", false) ~= true then
                return
            end
            FastReload.Finish(controller)
        end)
    end
    function FastReload.PatchController()
        local mod = FastReload.FindController()
        if not mod then
            return
        end
        if type(mod.canShoot) == "function" and mod.canShoot ~= FastReload.Wrapper then
            local original = mod.canShoot
            local wrapper = function(self, ...)
                local result = original(self, ...)
                if flag("MiscFastReload", false) == true and type(self) == "table" and self.reloading == true then
                    FastReload.Begin(self)
                end
                return result
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
                local result = originalReload(self, ...)
                if flag("MiscFastReload", false) == true then
                    FastReload.Begin(self)
                end
                return result
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
        if flag("MiscFastReload", false) == true then
            FastReload.PatchController()
        else
            FastReload.RestoreController()
        end
    end

    -- Damage boost: та же механика, что у Fast reload, только для урона.
    -- У тулов есть клиентские атрибуты damage (и minDamage у некоторых) -
    -- пишем туда оригинал x25, оригиналы запоминаем и возвращаем при
    -- выключении чекбокса. Примет ли сервер повышенный урон, зависит от
    -- валидации игры (как и с Fast reload - проверяется в игре).
    local DamageBoost = {Originals = {}, LastScan = 0, Mult = 25}
    function DamageBoost.ApplyTo(tool)
        if not (tool and tool:IsA("Tool")) then
            return
        end
        for _, attr in ipairs({"damage", "minDamage"}) do
            local ok, value = pcall(function()
                return tool:GetAttribute(attr)
            end)
            if ok and type(value) == "number" then
                local rec = DamageBoost.Originals[tool]
                if not rec then
                    rec = {}
                    DamageBoost.Originals[tool] = rec
                end
                if rec[attr] == nil then
                    rec[attr] = value
                end
                local boosted = rec[attr] * DamageBoost.Mult
                if value ~= boosted then
                    pcall(function()
                        tool:SetAttribute(attr, boosted)
                    end)
                end
            end
        end
    end
    function DamageBoost.RestoreAll()
        for tool, rec in pairs(DamageBoost.Originals) do
            if tool and tool.Parent then
                for attr, original in pairs(rec) do
                    pcall(function()
                        tool:SetAttribute(attr, original)
                    end)
                end
            end
        end
        table.clear(DamageBoost.Originals)
    end
    function DamageBoost.Apply()
        if flag("MiscDamageBoost", false) == true then
            local now = os.clock()
            if now - DamageBoost.LastScan < 0.5 then
                return
            end
            DamageBoost.LastScan = now
            local character = LocalPlayer and LocalPlayer.Character
            if character then
                for _, tool in ipairs(character:GetChildren()) do
                    DamageBoost.ApplyTo(tool)
                end
            end
            local backpack = LocalPlayer and LocalPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    DamageBoost.ApplyTo(tool)
                end
            end
            for tool in pairs(DamageBoost.Originals) do
                if not tool.Parent then
                    DamageBoost.Originals[tool] = nil
                end
            end
        elseif next(DamageBoost.Originals) then
            DamageBoost.RestoreAll()
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
        DamageBoost.Apply()
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
        DamageBoost.RestoreAll()
        restoreProperty(particles, "Enabled"); restoreProperty(textures, "Transparency")
        restoreProperty(collisions, "CanCollide"); restoreEffects(); restoreName(); restoreFPS()
        if shadowOriginal ~= nil then Lighting.GlobalShadows = shadowOriginal; shadowOriginal = nil end
        if terrainOriginal ~= nil then pcall(function() Workspace.Terrain.Decoration = terrainOriginal end); terrainOriginal = nil end
        particleOn, textureOn, effectsOn, cameraLast = false, false, false, nil
    end
    table.insert(Library.UnloadHooks, Misc.Shutdown)
end
Misc.Start()
