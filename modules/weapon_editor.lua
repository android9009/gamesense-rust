local WeaponEditor = {
    Started = false,
    Selected = nil,
    Equipped = nil,
    Profiles = {},
    Originals = {},
    Tools = {},
}
do
    local HttpService = game:GetService("HttpService")
    local StarterPack = game:GetService("StarterPack")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- Editor fields. Key = key used by the UI sliders in gamesense.lua,
    -- Attr = attribute on the Tool (or on one of its descendants).
    local SIMPLE_FIELDS = {
        {Key = "damage", Attr = "damage"},
        {Key = "magazineSize", Attr = "magazineSize"},
        {Key = "_ammo", Attr = "_ammo"},
        {Key = "rateOfFire", Attr = "rateOfFire"},
        {Key = "range", Attr = "range"},
        {Key = "reloadTime", Attr = "reloadTime"},
        {Key = "spread", Attr = "spread"},
        {Key = "rayRadius", Attr = "rayRadius"},
        {Key = "raysPerShot", Attr = "raysPerShot"},
        {Key = "unanchoredImpulseForce", Attr = "unanchoredImpulseForce"},
    }
    local FIELD_BY_KEY = {}
    for _, field in ipairs(SIMPLE_FIELDS) do
        FIELD_BY_KEY[field.Key] = field
    end
    -- Weapons from StarterPack (see screenshot). Building Plan / Hammer and
    -- other tools are not in this list and are also filtered out by attributes.
    local KNOWN_WEAPONS = {
        ak47hld = true, bolt = true, crossbow = true, dvl = true, glock = true,
        hk416 = true, lr300hld = true, m249hld = true, m60hld = true, mk14 = true,
        mp40 = true, mp5hld = true, minigun = true, pistol = true, python = true,
        revolver = true, rifle = true, sks = true, smghld = true,
        thompsonhld = true, vector9 = true, f1 = true, g4 = true, grenade = true,
    }
    local EXCLUDED_NAMES = {
        buildingplan = true, hammer = true, rock = true, torch = true,
        flashlight = true, blueprint = true,
    }
    local GUN_ATTRIBUTES = {"damage", "fireMode", "magazineSize", "rateOfFire", "spread", "raysPerShot", "reloadTime"}

    local scanTimer = 0
    local rsScanTimer = 0
    local lastSignature = ""
    local appliedVersion = setmetatable({}, {__mode = "k"})

    local function ui()
        local tabs = Library and Library.TabsByName
        local tab = tabs and tabs["weapons"]
        return tab and tab.WeaponEditorUI or nil
    end
    local function setStatus(text)
        local editorUi = ui()
        if editorUi and editorUi.SetStatus then
            editorUi.SetStatus(text)
        end
    end
    local function normalizeName(name)
        return string.lower(tostring(name or "")):gsub("[%s%-_]", "")
    end
    local function isWeaponTool(tool)
        if not tool or not tool:IsA("Tool") then
            return false
        end
        local normalized = normalizeName(tool.Name)
        if EXCLUDED_NAMES[normalized] then
            return false
        end
        if KNOWN_WEAPONS[normalized] then
            return true
        end
        -- Only real weapons: they carry gun attributes (ak47HLD etc).
        -- Building Plan / Hammer have none of these, so they never show up.
        local function hasGunAttribute(instance)
            local ok, attrs = pcall(function() return instance:GetAttributes() end)
            if not ok or type(attrs) ~= "table" then
                return false
            end
            for _, attr in ipairs(GUN_ATTRIBUTES) do
                if attrs[attr] ~= nil then
                    return true
                end
            end
            return false
        end
        if hasGunAttribute(tool) then
            return true
        end
        for _, descendant in ipairs(tool:GetDescendants()) do
            if hasGunAttribute(descendant) then
                return true
            end
        end
        return false
    end
    local function collectHolders(tool, attr)
        local holders = {}
        if not tool then
            return holders
        end
        local function consider(instance)
            local ok, value = pcall(function() return instance:GetAttribute(attr) end)
            if ok and value ~= nil then
                holders[#holders + 1] = {Inst = instance, Kind = "attribute", Raw = value}
                return
            end
            if (instance:IsA("NumberValue") or instance:IsA("IntValue") or instance:IsA("StringValue") or instance:IsA("BoolValue"))
                and instance.Name == attr then
                holders[#holders + 1] = {Inst = instance, Kind = "value", Raw = instance.Value}
            end
        end
        consider(tool)
        for _, descendant in ipairs(tool:GetDescendants()) do
            consider(descendant)
        end
        return holders
    end
    local function toNumber(value, fallback)
        if type(value) == "number" then
            return value
        end
        if typeof(value) == "Vector2" or typeof(value) == "Vector3" then
            return value.X
        end
        if type(value) == "string" then
            return tonumber((value:gsub(",", ".")):match("[-%d%.]+")) or fallback or 0
        end
        if type(value) == "boolean" then
            return value and 1 or 0
        end
        return fallback or 0
    end
    local function toVec2Parts(value)
        if typeof(value) == "Vector2" then
            return value.X, value.Y
        end
        if type(value) == "number" then
            return value, value
        end
        if type(value) == "string" then
            local numbers = {}
            for part in string.gmatch((value:gsub(",", " ")), "[-%d%.]+") do
                numbers[#numbers + 1] = tonumber(part) or 0
            end
            return numbers[1] or 0, numbers[2] or numbers[1] or 0
        end
        return 0, 0
    end
    local function coerceLike(raw, editorValue)
        if type(raw) == "number" then
            return editorValue
        end
        if typeof(raw) == "Vector2" then
            return Vector2.new(editorValue, editorValue)
        end
        if typeof(raw) == "Vector3" then
            return Vector3.new(editorValue, editorValue, editorValue)
        end
        if type(raw) == "string" then
            return tostring(editorValue)
        end
        if type(raw) == "boolean" then
            return editorValue ~= 0 and editorValue ~= false
        end
        return editorValue
    end
    local function coerceVec2Like(raw, x, y)
        if typeof(raw) == "Vector2" then
            return Vector2.new(x, y)
        end
        if type(raw) == "string" then
            return string.format("%s, %s", tostring(x), tostring(y))
        end
        if type(raw) == "number" then
            return x
        end
        return Vector2.new(x, y)
    end
    local function writeHolder(holder, value)
        if not holder or not holder.Inst or not holder.Inst.Parent then
            return
        end
        pcall(function()
            if holder.Kind == "value" then
                holder.Inst.Value = value
            else
                holder.Inst:SetAttribute(holder.Attr, value)
            end
        end)
    end
    local function eachTool(name, callback)
        local tools = WeaponEditor.Tools[name]
        if not tools then
            return
        end
        for tool in pairs(tools) do
            if tool and tool.Parent then
                callback(tool)
            end
        end
    end
    local function representativeTool(name)
        local equipped = nil
        local character = LocalPlayer and LocalPlayer.Character
        if character then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool and tool.Name == name then
                equipped = tool
            end
        end
        if equipped then
            return equipped
        end
        local tools = WeaponEditor.Tools[name]
        if tools then
            for tool in pairs(tools) do
                if tool and tool.Parent then
                    return tool
                end
            end
        end
        return nil
    end
    local function readValues(name)
        local values, available = {}, {}
        local tool = representativeTool(name)
        if not tool then
            return values, available
        end
        for _, field in ipairs(SIMPLE_FIELDS) do
            local holders = collectHolders(tool, field.Attr)
            available[field.Key] = #holders > 0
            if #holders > 0 then
                for _, holder in ipairs(holders) do
                    holder.Attr = field.Attr
                end
                values[field.Key] = toNumber(holders[1].Raw, 0)
            end
        end
        for _, recoil in ipairs({"recoilMin", "recoilMax"}) do
            local holders = collectHolders(tool, recoil)
            local has = #holders > 0
            available[recoil .. "X"] = has
            available[recoil .. "Y"] = has
            if has then
                local x, y = toVec2Parts(holders[1].Raw)
                values[recoil .. "X"] = x
                values[recoil .. "Y"] = y
            end
        end
        local fireHolders = collectHolders(tool, "fireMode")
        available.fireMode = #fireHolders > 0
        if #fireHolders > 0 and type(fireHolders[1].Raw) == "string" then
            values.fireMode = fireHolders[1].Raw
        end
        local scopeHolders = collectHolders(tool, "canScope")
        available.canScope = #scopeHolders > 0
        if #scopeHolders > 0 then
            values.canScope = scopeHolders[1].Raw == true
        end
        return values, available
    end
    local function copyValues(values)
        local copy = {}
        for key, value in pairs(values or {}) do
            copy[key] = value
        end
        return copy
    end
    local function anyAvailable(available)
        for _, has in pairs(available or {}) do
            if has == true then
                return true
            end
        end
        return false
    end
    local function ensureOriginal(name)
        if WeaponEditor.Originals[name] then
            return WeaponEditor.Originals[name]
        end
        local values, available = readValues(name)
        if anyAvailable(available) then
            WeaponEditor.Originals[name] = {Values = copyValues(values), Available = available}
        end
        return WeaponEditor.Originals[name]
    end
    local function getProfile(name)
        local profile = WeaponEditor.Profiles[name]
        if not profile then
            local values = readValues(name)
            profile = {Values = values, Modified = false, Version = 0}
            WeaponEditor.Profiles[name] = profile
        end
        return profile
    end
    local function saveProfilesFlag()
        if not Library or not Library.Flags then
            return
        end
        local saved = {}
        for name, profile in pairs(WeaponEditor.Profiles) do
            if profile.Modified then
                saved[name] = copyValues(profile.Values)
            end
        end
        local ok, encoded = pcall(function()
            return HttpService:JSONEncode(saved)
        end)
        if ok then
            Library.Flags.WeaponEditorProfiles = encoded
        end
    end
    local function writeField(name, key, editorValue)
        if editorValue == nil then
            return
        end
        if key == "fireMode" or key == "canScope" then
            local attr = key
            eachTool(name, function(tool)
                for _, holder in ipairs(collectHolders(tool, attr)) do
                    holder.Attr = attr
                    if key == "canScope" then
                        writeHolder(holder, editorValue == true)
                    else
                        writeHolder(holder, tostring(editorValue))
                    end
                end
            end)
            return
        end
        if key == "recoilMinX" or key == "recoilMinY" or key == "recoilMaxX" or key == "recoilMaxY" then
            local attr = (key:sub(1, 9) == "recoilMin") and "recoilMin" or "recoilMax"
            local isX = key:sub(-1) == "X"
            local profile = WeaponEditor.Profiles[name]
            eachTool(name, function(tool)
                for _, holder in ipairs(collectHolders(tool, attr)) do
                    holder.Attr = attr
                    local x, y = toVec2Parts(holder.Raw)
                    if profile and profile.Values then
                        local prefix = attr
                        if profile.Values[prefix .. "X"] ~= nil then x = profile.Values[prefix .. "X"] end
                        if profile.Values[prefix .. "Y"] ~= nil then y = profile.Values[prefix .. "Y"] end
                    end
                    if isX then x = editorValue else y = editorValue end
                    writeHolder(holder, coerceVec2Like(holder.Raw, x, y))
                end
            end)
            return
        end
        local field = FIELD_BY_KEY[key]
        if not field then
            return
        end
        eachTool(name, function(tool)
            for _, holder in ipairs(collectHolders(tool, field.Attr)) do
                holder.Attr = field.Attr
                writeHolder(holder, coerceLike(holder.Raw, editorValue))
            end
        end)
    end
    function WeaponEditor.ApplyProfile(name)
        local profile = WeaponEditor.Profiles[name]
        if not profile or not profile.Modified then
            return
        end
        for key, value in pairs(profile.Values) do
            writeField(name, key, value)
        end
        eachTool(name, function(tool)
            appliedVersion[tool] = profile.Version
        end)
    end
    function WeaponEditor.ApplySelected()
        local name = WeaponEditor.Selected
        if not name then
            setStatus("No weapon selected.")
            return
        end
        if flag("WeaponEditorEnabled", false) ~= true then
            setStatus("Editor is disabled - turn on Enabled on the left.")
            return
        end
        local profile = getProfile(name)
        profile.Modified = true
        profile.Version += 1
        WeaponEditor.ApplyProfile(name)
        saveProfilesFlag()
        setStatus("Applied settings to " .. name .. ".")
    end
    function WeaponEditor.ApplyOpPreset()
        local name = WeaponEditor.Selected
        if not name then
            setStatus("No weapon selected.")
            return
        end
        if flag("WeaponEditorEnabled", false) ~= true then
            setStatus("Editor is disabled - turn on Enabled on the left.")
            return
        end
        local profile = getProfile(name)
        local preset = {
            damage = 9999, magazineSize = 999, _ammo = 99999, rateOfFire = 1200,
            range = 10000, reloadTime = 0.1, spread = 0, raysPerShot = 1,
            unanchoredImpulseForce = 0, recoilMinX = 0, recoilMinY = 0,
            recoilMaxX = 0, recoilMaxY = 0, fireMode = "Auto",
        }
        for key, value in pairs(preset) do
            profile.Values[key] = value
        end
        profile.Modified = true
        profile.Version += 1
        WeaponEditor.ApplyProfile(name)
        saveProfilesFlag()
        local editorUi = ui()
        if editorUi and editorUi.SyncEditor then
            local _, available = readValues(name)
            editorUi.SyncEditor(profile.Values, available)
        end
        setStatus("OP preset applied to " .. name .. ".")
    end
    function WeaponEditor.ResetSelected()
        local name = WeaponEditor.Selected
        if not name then
            setStatus("No weapon selected.")
            return
        end
        WeaponEditor.ResetWeapon(name)
        setStatus("Reset " .. name .. " to original values.")
    end
    function WeaponEditor.ResetWeapon(name)
        local original = ensureOriginal(name)
        local profile = getProfile(name)
        if original then
            profile.Values = copyValues(original.Values)
        else
            profile.Values = readValues(name)
        end
        profile.Modified = false
        profile.Version += 1
        -- Write the original values back to every copy of this weapon.
        for key, value in pairs(profile.Values) do
            writeField(name, key, value)
        end
        eachTool(name, function(tool)
            appliedVersion[tool] = profile.Version
        end)
        saveProfilesFlag()
        if WeaponEditor.Selected == name then
            local editorUi = ui()
            if editorUi and editorUi.SyncEditor then
                local _, available = readValues(name)
                editorUi.SyncEditor(profile.Values, available)
            end
        end
    end
    function WeaponEditor.ResetAll()
        for name, profile in pairs(WeaponEditor.Profiles) do
            if profile.Modified then
                WeaponEditor.ResetWeapon(name)
            end
        end
        saveProfilesFlag()
        setStatus("All weapons reset to original values.")
    end
    function WeaponEditor.Select(name)
        WeaponEditor.Selected = name
        local editorUi = ui()
        if not name then
            if editorUi and editorUi.SetSelected then editorUi.SetSelected(nil) end
            return
        end
        ensureOriginal(name)
        local profile = getProfile(name)
        if not profile.Modified then
            profile.Values = readValues(name)
        end
        if editorUi then
            if editorUi.SetSelected then editorUi.SetSelected(name) end
            if editorUi.SyncEditor then
                local _, available = readValues(name)
                editorUi.SyncEditor(profile.Values, available)
            end
        end
        local original = WeaponEditor.Originals[name]
        if not original then
            setStatus(name .. ": no editable attributes found on this tool.")
        elseif profile.Modified then
            setStatus(name .. ": edited settings loaded. Move a slider to re-apply.")
        else
            setStatus(name .. ": original values loaded.")
        end
    end
    function WeaponEditor.OnFieldChanged(key, value, selectedName)
        local editorUi = ui()
        if editorUi and editorUi.IsSyncing and editorUi.IsSyncing() then
            return
        end
        local name = selectedName or WeaponEditor.Selected
        if not name then
            return
        end
        if flag("WeaponEditorEnabled", false) ~= true then
            setStatus("Editor is disabled - turn on Enabled on the left.")
            return
        end
        local profile = getProfile(name)
        profile.Values[key] = value
        profile.Modified = true
        profile.Version += 1
        writeField(name, key, value)
        eachTool(name, function(tool)
            appliedVersion[tool] = profile.Version
        end)
        saveProfilesFlag()
        setStatus("Applied " .. tostring(key) .. " = " .. tostring(value) .. " to " .. name .. ".")
    end
    local function scanContainer(container, tools, directOnly)
        if not container then
            return
        end
        local children = directOnly and container:GetChildren() or container:GetDescendants()
        for _, instance in ipairs(children) do
            if instance:IsA("Tool") and isWeaponTool(instance) then
                tools[instance.Name] = tools[instance.Name] or {}
                tools[instance.Name][instance] = true
            end
        end
    end
    function WeaponEditor.Refresh(force)
        local tools = {}
        pcall(function() scanContainer(StarterPack, tools, true) end)
        local backpack = LocalPlayer and LocalPlayer:FindFirstChild("Backpack")
        pcall(function() scanContainer(backpack, tools, true) end)
        local character = LocalPlayer and LocalPlayer.Character
        pcall(function() scanContainer(character, tools, true) end)
        if force or rsScanTimer <= 0 then
            rsScanTimer = 4
            pcall(function() scanContainer(ReplicatedStorage, tools, false) end)
        end
        WeaponEditor.Tools = tools
        local names = {}
        for name in pairs(tools) do
            names[#names + 1] = name
        end
        table.sort(names, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        local signature = table.concat(names, "|")
        local editorUi = ui()
        if signature ~= lastSignature then
            lastSignature = signature
            if editorUi and editorUi.SetWeapons then
                editorUi.SetWeapons(names)
            end
        end
        local enabled = flag("WeaponEditorEnabled", false) == true
        local autoApply = flag("WeaponEditorAutoApply", true) == true
        for _, name in ipairs(names) do
            ensureOriginal(name)
            local profile = WeaponEditor.Profiles[name]
            if enabled and autoApply and profile and profile.Modified then
                local needsApply = false
                eachTool(name, function(tool)
                    if appliedVersion[tool] ~= profile.Version then
                        needsApply = true
                    end
                end)
                if needsApply then
                    WeaponEditor.ApplyProfile(name)
                end
            end
        end
        if force and WeaponEditor.Selected and tools[WeaponEditor.Selected] then
            WeaponEditor.Select(WeaponEditor.Selected)
        elseif force then
            setStatus("Found " .. tostring(#names) .. " weapon(s). Equip one or pick it on the left.")
        end
        return names
    end
    local function equippedTool()
        local character = LocalPlayer and LocalPlayer.Character
        local tool = character and character:FindFirstChildOfClass("Tool")
        if tool and isWeaponTool(tool) then
            return tool
        end
        return nil
    end
    function WeaponEditor.Update(deltaTime)
        scanTimer -= deltaTime or (1 / 60)
        rsScanTimer -= deltaTime or (1 / 60)
        local tool = equippedTool()
        local equippedName = tool and tool.Name or nil
        if equippedName ~= WeaponEditor.Equipped then
            WeaponEditor.Equipped = equippedName
            local editorUi = ui()
            if editorUi and editorUi.SetEquipped then
                editorUi.SetEquipped(equippedName)
            end
            if equippedName and flag("WeaponEditorAutoSelect", true) == true then
                WeaponEditor.Select(equippedName)
            end
        end
        if scanTimer <= 0 then
            scanTimer = 0.5
            pcall(function() WeaponEditor.Refresh(false) end)
        end
    end
    function WeaponEditor.Start()
        if WeaponEditor.Started then
            return
        end
        WeaponEditor.Started = true
        Library.WeaponEditor = WeaponEditor
        if Library.ConfigFlags then
            Library.ConfigFlags.WeaponEditorProfiles = function(value)
                if type(value) ~= "string" or value == "" then
                    return
                end
                local ok, decoded = pcall(function()
                    return HttpService:JSONDecode(value)
                end)
                if not ok or type(decoded) ~= "table" then
                    return
                end
                for name, values in pairs(decoded) do
                    if type(values) == "table" then
                        local profile = getProfile(name)
                        profile.Values = copyValues(values)
                        profile.Modified = true
                        profile.Version += 1
                    end
                end
                pcall(function() WeaponEditor.Refresh(true) end)
            end
        end
        TaskManager.AddConnection("WeaponEditorApply", RunService.Heartbeat, WeaponEditor.Update)
        pcall(function() WeaponEditor.Refresh(true) end)
        -- Nothing is in your hands yet: pre-select the first available weapon.
        if not WeaponEditor.Selected then
            for name in pairs(WeaponEditor.Tools) do
                WeaponEditor.Select(name)
                break
            end
        end
        table.insert(Library.UnloadHooks, WeaponEditor.Shutdown)
    end
    function WeaponEditor.Shutdown()
        if not WeaponEditor.Started then
            return
        end
        WeaponEditor.Started = false
        TaskManager.RemoveConnection("WeaponEditorApply")
        -- Restore everything we touched so unloading leaves the game clean.
        for name, profile in pairs(WeaponEditor.Profiles) do
            if profile.Modified then
                local original = WeaponEditor.Originals[name]
                if original then
                    for key, value in pairs(original.Values) do
                        writeField(name, key, value)
                    end
                end
                profile.Modified = false
            end
        end
        if Library and Library.WeaponEditor == WeaponEditor then
            Library.WeaponEditor = nil
        end
    end
end
WeaponEditor.Start()
