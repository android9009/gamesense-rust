local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local function LoadUI()
    local function run(code)
        local fn = loadstring(code)
        local result = fn and fn()
        if result then
            return result
        end
        if getgenv then
            return getgenv().Library
        end
        return nil
    end
    if isfile and isfile("gamesense.lua") then
        local ok, code = pcall(readfile, "gamesense.lua")
        if ok and code and #code > 0 then
            return run(code)
        end
    end
    local rawUrl = "https://raw.githubusercontent.com/android9009/gamesense-rust/main/gamesense.lua"
    return run(game:HttpGet(rawUrl))
end
local Library = LoadUI()
if not Library and getgenv then
    Library = getgenv().Library
end
local function findRootPart(model)
    if not model then return nil end
    return model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("Head")
end
local Entity = {}
function Entity.GetLocalPlayer()
    return LocalPlayer
end
function Entity.GetCharacter(player)
    player = player or LocalPlayer
    return player and player.Character
end
function Entity.GetHumanoid(player)
    local char = Entity.GetCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end
function Entity.GetRootPart(player)
    return findRootPart(Entity.GetCharacter(player))
end
function Entity.IsAlive(player)
    player = player or LocalPlayer
    local hum = Entity.GetHumanoid(player)
    local root = Entity.GetRootPart(player)
    return hum ~= nil and hum.Health > 0 and root ~= nil
end
function Entity.IsEnemy(player)
    if not player or player == LocalPlayer then return false end
    if player.Team ~= nil and LocalPlayer.Team ~= nil then
        return player.Team ~= LocalPlayer.Team
    end
    return true
end
function Entity.GetPlayers(enemiesOnly)
    local result = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and Entity.IsAlive(player) then
            if not enemiesOnly or Entity.IsEnemy(player) then
                table.insert(result, player)
            end
        end
    end
    return result
end
function Entity.GetNPCs()
    local result = {}
    local nested = {}
    for _, object in ipairs(Workspace:GetDescendants()) do
        if object:IsA("Model") and not Players:GetPlayerFromCharacter(object) then
            local humanoid = object:FindFirstChildOfClass("Humanoid")
            local root = findRootPart(object)
            if humanoid and humanoid.Health > 0 and root then
                local parent = object.Parent
                while parent do
                    if parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then
                        nested[object] = true
                        break
                    end
                    parent = parent.Parent
                end
                if not nested[object] then
                    result[#result + 1] = object
                end
            end
        end
    end
    return result
end
function Entity.IsAliveModel(model)
    if not model or not model:IsA("Model") then return false end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local root = findRootPart(model)
    return humanoid ~= nil and humanoid.Health > 0 and root ~= nil
end
function Entity.GetDistance(player)
    local myRoot = Entity.GetRootPart(LocalPlayer)
    local targetRoot = Entity.GetRootPart(player)
    if myRoot and targetRoot then
        return (myRoot.Position - targetRoot.Position).Magnitude
    end
    return math.huge
end
local Chams = {
    PartCache = {},
    OcclusionCache = {},
    LocalHighlight = nil
}
local function configureHighlight(hl, target, options, alwaysOnTop, parent)
    options = options or {}
    hl.Adornee = target
    hl.FillColor = options.FillColor or Color3.fromRGB(255, 50, 50)
    hl.FillTransparency = options.FillTransparency ~= nil and options.FillTransparency or 0.5
    hl.OutlineColor = options.OutlineColor or hl.FillColor
    hl.OutlineTransparency = options.OutlineTransparency ~= nil and options.OutlineTransparency or 1
    hl.DepthMode = alwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
    hl.Enabled = options.Enabled ~= false
    hl.Parent = parent or target
end
function Chams.CreatePart(target, options)
    if not target or not target:IsA("BasePart") then return nil end
    options = options or {}
    local hl = Chams.PartCache[target]
    if not hl or not hl.Parent then
        hl = Instance.new("Highlight")
        hl.Name = "GS_ChamsPart"
        Chams.PartCache[target] = hl
    end
    configureHighlight(hl, target, options, options.AlwaysOnTop == true, Workspace)
    return hl
end
function Chams.RemovePart(target)
    local hl = Chams.PartCache[target]
    if hl then
        hl:Destroy()
        Chams.PartCache[target] = nil
    end
    Chams.OcclusionCache[target] = nil
end
function Chams.RemoveModelParts(model)
    local remove = {}
    for part in pairs(Chams.PartCache) do
        if part:IsDescendantOf(model) then
            remove[#remove + 1] = part
        end
    end
    for _, part in ipairs(remove) do
        Chams.RemovePart(part)
    end
end
function Chams.ClearAll()
    local partTargets = {}
    for part in pairs(Chams.PartCache) do
        partTargets[#partTargets + 1] = part
    end
    for _, part in ipairs(partTargets) do
        Chams.RemovePart(part)
    end
    if Chams.LocalHighlight and Chams.LocalHighlight.Parent then
        pcall(function() Chams.LocalHighlight:Destroy() end)
    end
    Chams.LocalHighlight = nil
end
local Targeting = {}
function Targeting.GetCamera()
    return Workspace.CurrentCamera
end
function Targeting.GetMousePosition()
    return UserInputService:GetMouseLocation()
end
function Targeting.WorldToScreen(worldPosition)
    local camera = Targeting.GetCamera()
    if not camera then return Vector2.zero, false end
    local screenPos, onScreen = camera:WorldToViewportPoint(worldPosition)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end
function Targeting.GetClosestToCursor(fovRadius, enemiesOnly, targetPartName)
    targetPartName = targetPartName or "Head"
    local mousePos = Targeting.GetMousePosition()
    local closestPlayer, closestPart, minDistance = nil, nil, fovRadius or math.huge
    for _, player in ipairs(Entity.GetPlayers(enemiesOnly)) do
        local char = Entity.GetCharacter(player)
        local part = char and (char:FindFirstChild(targetPartName) or Entity.GetRootPart(player))
        if part then
            local screenPos, onScreen = Targeting.WorldToScreen(part.Position)
            if onScreen then
                local dist = (screenPos - mousePos).Magnitude
                if dist < minDistance then
                    minDistance = dist
                    closestPlayer = player
                    closestPart = part
                end
            end
        end
    end
    return closestPlayer, closestPart, minDistance
end
local VisualUtils = {
    DefaultClockTime = Lighting.ClockTime,
    DefaultAmbient = Lighting.Ambient,
    DefaultOutdoorAmbient = Lighting.OutdoorAmbient
}
function VisualUtils.SetClockTime(time)
    Lighting.ClockTime = time
end
function VisualUtils.SetAmbient(ambientColor, outdoorColor)
    if ambientColor then Lighting.Ambient = ambientColor end
    if outdoorColor then Lighting.OutdoorAmbient = outdoorColor end
end
function VisualUtils.SetFOV(fov)
    local camera = Targeting.GetCamera()
    if camera then
        camera.FieldOfView = fov
    end
end
function VisualUtils.ResetLighting()
    Lighting.ClockTime = VisualUtils.DefaultClockTime
    Lighting.Ambient = VisualUtils.DefaultAmbient
    Lighting.OutdoorAmbient = VisualUtils.DefaultOutdoorAmbient
end
local TaskManager = {
    Connections = {}
}
function TaskManager.AddConnection(id, signal, callback)
    TaskManager.RemoveConnection(id)
    TaskManager.Connections[id] = signal:Connect(callback)
end
function TaskManager.RemoveConnection(id)
    if TaskManager.Connections[id] then
        TaskManager.Connections[id]:Disconnect()
        TaskManager.Connections[id] = nil
    end
end
function TaskManager.ClearAll()
    for id, conn in pairs(TaskManager.Connections) do
        if conn then
            conn:Disconnect()
        end
    end
    table.clear(TaskManager.Connections)
end
local World = {}
local STEP = "GS_WorldApply"
local SPARK = "rbxasset://textures/particles/sparkles_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"
local PROPS = {
    "ClockTime", "Brightness", "Ambient", "OutdoorAmbient",
    "ColorShift_Top", "ColorShift_Bottom", "FogColor", "FogStart", "FogEnd",
    "GlobalShadows", "ShadowSoftness", "ExposureCompensation",
}
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local function NS(a, b) return NumberSequence.new(a, b or a) end
local function NR(a, b) return NumberRange.new(a, b or a) end
local function CS(a, b)
    return typeof(a) == "ColorSequence" and a or (b and ColorSequence.new(a, b) or ColorSequence.new(a))
end
local WEATHER = {
    [1] = {
        fog = 220, fogc = rgb(118, 132, 148), tint = rgb(186, 198, 214), ccb = -0.04, ccs = -0.08,
        atmo = {0.25, 1.2, rgb(150, 164, 180), rgb(90, 100, 120)},
        lift = 26, size = Vector3.new(110, 1, 110),
        p = {tex = SPARK, col = rgb(168, 186, 210), size = NS(0.12, 0.04), trans = 0.25, life = NR(0.45, 0.75), spd = NR(48, 78), spread = Vector2.new(3, 3), acc = Vector3.new(0, -95, 0), dir = "Bottom", rate = 420, look = "VelocityParallel", glow = 0.15},
        v = {tex = SMOKE, col = rgb(140, 154, 172), size = NS(2.4, 4.5), trans = NS(0.85, 1), life = NR(0.6, 1.1), spd = NR(2, 6), spread = Vector2.new(40, 40), acc = Vector3.new(0, -8, 0), rate = 0},
    },
    [2] = {
        fog = 280, fogc = rgb(188, 200, 214), tint = rgb(214, 226, 238), ccb = 0.04, ccs = -0.12,
        atmo = {0.22, 1.4, rgb(210, 220, 230), rgb(170, 180, 195)},
        lift = 26, size = Vector3.new(90, 1, 90),
        p = {tex = SPARK, col = rgb(245, 248, 255), size = NS(0.18, 0.32), trans = NS(0.15, 0.55), life = NR(4, 7), spd = NR(3, 8), spread = Vector2.new(18, 18), acc = Vector3.new(1.6, -6, 0.4), dir = "Bottom", rate = 220, glow = 0.35, rot = NR(0, 180), spin = NR(-50, 50)},
    },
    [3] = {
        fog = 140, fogc = rgb(46, 52, 68), tint = rgb(78, 88, 112), ccb = -0.12, ccs = -0.18, thunder = true,
        atmo = {0.4, 2.2, rgb(70, 78, 96), rgb(28, 32, 44)},
        lift = 26, size = Vector3.new(110, 1, 110),
        p = {tex = SPARK, col = rgb(168, 186, 210), size = NS(0.12, 0.04), trans = 0.25, life = NR(0.45, 0.75), spd = NR(48, 78), spread = Vector2.new(3, 3), acc = Vector3.new(0, -95, 0), dir = "Bottom", rate = 780, look = "VelocityParallel", glow = 0.15},
        v = {tex = SMOKE, col = rgb(140, 154, 172), size = NS(2.4, 4.5), trans = NS(0.85, 1), life = NR(0.6, 1.1), spd = NR(2, 6), spread = Vector2.new(40, 40), acc = Vector3.new(0, -8, 0), rate = 18},
    },
    [4] = {
        fog = 160, fogc = rgb(58, 50, 46), tint = rgb(92, 78, 68), ccb = -0.1, ccs = -0.22,
        atmo = {0.38, 2, rgb(86, 74, 64), rgb(28, 22, 18)},
        lift = 26, size = Vector3.new(90, 1, 90),
        p = {tex = SMOKE, col = CS(rgb(36, 34, 32), rgb(88, 74, 62)), size = NS(0.16, 0.4), trans = NS(0.2, 0.7), life = NR(3.5, 6), spd = NR(2, 6), spread = Vector2.new(22, 22), acc = Vector3.new(3.5, -5, 0), dir = "Bottom", rate = 160, rot = NR(0, 180), spin = NR(-20, 20)},
        v = {tex = SMOKE, col = rgb(48, 42, 38), size = NS(3, 7), trans = NS(0.78, 1), life = NR(1.2, 2.2), spd = NR(1, 3), rate = 10},
    },
    [5] = {
        fog = 90, fogc = rgb(176, 140, 86), tint = rgb(198, 158, 96), ccb = 0.02, ccs = -0.05,
        atmo = {0.48, 2.6, rgb(186, 150, 92), rgb(120, 88, 48)},
        lift = 0, size = Vector3.new(70, 28, 70),
        p = {tex = SMOKE, col = CS(rgb(186, 148, 88), rgb(214, 176, 110)), size = NS(2.2, 6), trans = NS(0.55, 1), life = NR(1.2, 2.4), spd = NR(18, 42), spread = Vector2.new(28, 12), acc = Vector3.new(26, -1.5, 0), dir = "Right", rate = 70, glow = 0.05},
        v = {tex = SMOKE, col = rgb(168, 132, 78), size = NS(5, 11), trans = NS(0.72, 1), life = NR(1.6, 2.8), spd = NR(8, 16), spread = Vector2.new(50, 30), acc = Vector3.new(18, 0, 0), dir = "Right", rate = 22},
    },
}
local snap, on, autoTime
local cc, folder, anchor, emitters, curWeather = nil, nil, nil, {}, -1
local boltNext, boltT0 = 0, nil
local function flag(name, default)
    local v = Library and Library.Flags and Library.Flags[name]
    if v == nil then return default end
    if type(v) == "table" and v.Color then return v.Color end
    return v
end
-- прозрачность колорпикера (0 = цвет действует полностью, 1 = эффект выключен)
local function pickerAlpha(name)
    local v = Library and Library.Flags and Library.Flags[name]
    if type(v) == "table" and type(v.Transparency) == "number" then
        return math.clamp(v.Transparency, 0, 1)
    end
    return 0
end

local function bindOn(feature, bindName)
    if feature ~= true then return false end
    if bindName == nil then return true end
    local b = flag(bindName, nil)
    if type(b) == "table" then
        return b.Active == true
    end
    return false
end

local function hasOption(flagName, option)
    local v = Library and Library.Flags and Library.Flags[flagName]
    if type(v) == "table" then
        for _, item in ipairs(v) do
            if item == option then return true end
        end
        return false
    end
    return v == option
end
local ChamsRuntime = {
    Started = false,
    BotScanTimer = 0,
    OcclusionTimer = 0,
    Bots = {}
}
local function chamsColor(flagName, fallback)
    local value = Library and Library.Flags and Library.Flags[flagName]
    if type(value) == "table" then
        local color = typeof(value.Color) == "Color3" and value.Color or fallback
        local transparency = type(value.Transparency) == "number" and math.clamp(value.Transparency, 0, 1) or 0.15
        return color, transparency
    end
    return fallback, 0.15
end
local function chamsStyle(flagName)
    local style = Library and Library.Flags and Library.Flags[flagName]
    return style == "Normal" and "Normal" or "Flat"
end
local MAX_CHAM_TARGETS = 14
local MAX_CHAM_PARTS = 16
local modelPartsCache = {}
local function modelPosition(model)
    local root = findRootPart(model)
    return root and root.Position or model:GetPivot().Position
end
local function collectChamsParts(model)
    local parts = {}
    for _, object in ipairs(model:GetDescendants()) do
        if object:IsA("BasePart")
            and object.Name ~= "HumanoidRootPart"
            and object.Transparency < 0.99
            and not object:FindFirstAncestorOfClass("Tool") then
            parts[#parts + 1] = object
        end
    end
    table.sort(parts, function(a, b)
        local aAccessory = a:FindFirstAncestorOfClass("Accessory") ~= nil
        local bAccessory = b:FindFirstAncestorOfClass("Accessory") ~= nil
        if aAccessory ~= bAccessory then
            return not aAccessory
        end
        return a.Name < b.Name
    end)
    while #parts > MAX_CHAM_PARTS do
        table.remove(parts)
    end
    return parts
end
local function getChamsParts(model)
    local cached = modelPartsCache[model]
    if cached then
        local valid = true
        for _, part in ipairs(cached) do
            if not part.Parent or not part:IsDescendantOf(model) then
                valid = false
                break
            end
        end
        if valid then return cached end
    end
    local parts = collectChamsParts(model)
    modelPartsCache[model] = parts
    return parts
end
local function removeModelChams(model)
    local hl = model:FindFirstChild("GS_LocalHighlight")
    if hl then
        pcall(function() hl:Destroy() end)
    end
    if model == LocalPlayer.Character and Chams.LocalHighlight then
        if Chams.LocalHighlight.Parent then
            pcall(function() Chams.LocalHighlight:Destroy() end)
        end
        Chams.LocalHighlight = nil
    end
    Chams.RemoveModelParts(model)
    modelPartsCache[model] = nil
end
local function partIsOccluded(camera, part, character)
    local ignore = {character}
    if LocalPlayer.Character and LocalPlayer.Character ~= character then
        ignore[#ignore + 1] = LocalPlayer.Character
    end
    local points = {part.Position}
    local halfY = math.min(part.Size.Y * 0.3, 1.25)
    if halfY > 0.35 then
        points[#points + 1] = part.CFrame:PointToWorldSpace(Vector3.new(0, halfY, 0))
        points[#points + 1] = part.CFrame:PointToWorldSpace(Vector3.new(0, -halfY, 0))
    end
    for _, point in ipairs(points) do
        local ok, blockers = pcall(function()
            return camera:GetPartsObscuringTarget({point}, ignore)
        end)
        if ok and #blockers == 0 then
            return false
        end
    end
    return true
end
-- Общий флаг: тело локального игрока сейчас скрыто системой LocalTransparency
-- (активен Player overlap или Weapon). Пишется в lpTransparencyApply,
-- читается чамсами локального игрока, чтобы синхронизировать прозрачность заливки.
local localBodyTransparent = false

-- alwaysOn: чамсы рисуются ВСЕГДА одним цветом, без visible/wall-логики
-- (для локал плеера: и на открытой местности, и за стеной — всегда сквозь геометрию)
local function applyModelPartChams(model, visibleFlag, wallFlag, visibleColorFlag, wallColorFlag, visibleStyleFlag, wallStyleFlag, refreshOcclusion, alwaysOn)
    if not Entity.IsAliveModel(model) then
        removeModelChams(model)
        return
    end
    local visibleEnabled = flag(visibleFlag, false) == true
    local wallEnabled = wallFlag and flag(wallFlag, false) == true or false
    if not visibleEnabled and not wallEnabled then
        removeModelChams(model)
        return
    end
    local camera = Workspace.CurrentCamera
    local parts = getChamsParts(model)
    if not camera or #parts == 0 then
        removeModelChams(model)
        return
    end
    local visibleColor, visibleTransparency = chamsColor(visibleColorFlag, Color3.fromRGB(142, 181, 39))
    local wallColor, wallTransparency = chamsColor(wallColorFlag, Color3.fromRGB(79, 143, 214))
    -- Локальный игрок (alwaysOn): заливка хайлайта становится прозрачной ТОЛЬКО
    -- когда тело реально скрыто (LocalTransparency активна — Player overlap/Weapon),
    -- чтобы чамсы не перекрывали модель впустую, пока тело плотное.
    if alwaysOn and localBodyTransparent then
        visibleTransparency = math.max(visibleTransparency, 0.1)
        wallTransparency = math.max(wallTransparency, 0.1)
    end
    local visibleStyle = chamsStyle(visibleStyleFlag)
    local wallStyle = chamsStyle(wallStyleFlag)
    local validParts = {}
    for _, part in ipairs(parts) do
        validParts[part] = true
        local occluded = false
        if not alwaysOn then
            if refreshOcclusion or Chams.OcclusionCache[part] == nil then
                Chams.OcclusionCache[part] = partIsOccluded(camera, part, model)
            end
            occluded = Chams.OcclusionCache[part] == true
        end
        local enabled = occluded and wallEnabled or (not occluded and visibleEnabled)
        if not enabled then
            Chams.RemovePart(part)
        else
            local color = occluded and wallColor or visibleColor
            local transparency = occluded and wallTransparency or visibleTransparency
            local style = occluded and wallStyle or visibleStyle

            if style == "Normal" then
                -- Normal: модель видна «нормально» — лёгкий тинт (заливка
                -- прозрачнее, сквозь неё просвечивает сам персонаж) + чёткая
                -- непрозрачная обводка цвета пикера.
                Chams.CreatePart(part, {
                    FillColor = color,
                    FillTransparency = math.max(transparency, 0.6),
                    OutlineColor = color,
                    OutlineTransparency = 0,
                    AlwaysOnTop = occluded or alwaysOn == true,
                    Enabled = true,
                })
            else
                -- Flat: плоская сплошная заливка цвета пикера, без обводки.
                Chams.CreatePart(part, {
                    FillColor = color,
                    FillTransparency = transparency,
                    OutlineColor = color,
                    OutlineTransparency = 1,
                    AlwaysOnTop = occluded or alwaysOn == true,
                    Enabled = true,
                })
            end
        end
    end
    local stale = {}
    for part in pairs(Chams.PartCache) do
        if part:IsDescendantOf(model) and not validParts[part] then
            stale[#stale + 1] = part
        end
    end
    for _, part in ipairs(stale) do
        Chams.RemovePart(part)
    end
end
local function addChamsTarget(targets, model, kind, player)
    if model and model.Parent and Entity.IsAliveModel(model) then
        targets[#targets + 1] = {Model = model, Kind = kind, Player = player}
    end
end
local function applyLocalPlayerChams(model)
    local enabled = flag("VisLocalPlayer", false) == true
    if not enabled or not Entity.IsAliveModel(model) then
        if Chams.LocalHighlight then
            if Chams.LocalHighlight.Parent then
                pcall(function() Chams.LocalHighlight:Destroy() end)
            end
            Chams.LocalHighlight = nil
        end
        local existingHl = model:FindFirstChild("GS_LocalHighlight")
        if existingHl then
            pcall(function() existingHl:Destroy() end)
        end
        Chams.RemoveModelParts(model)
        return
    end

    local color, trans = chamsColor("VisLocalPlayerColor", Color3.fromRGB(110, 110, 110))
    local style = chamsStyle("VisLocalPlayerStyle")

    if localBodyTransparent then
        trans = math.max(trans, LP_TRANSPARENCY)
    end

    local fillTrans = (style == "Normal") and math.max(trans, 0.6) or trans
    local outlineTrans = (style == "Normal") and 0 or 1

    local hl = Chams.LocalHighlight
    if not hl or not hl.Parent then
        hl = model:FindFirstChild("GS_LocalHighlight")
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "GS_LocalHighlight"
        end
        Chams.LocalHighlight = hl
    end

    hl.Adornee = model
    hl.FillColor = color
    hl.FillTransparency = fillTrans
    hl.OutlineColor = color
    hl.OutlineTransparency = outlineTrans
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = true
    hl.Parent = Workspace
end

local function applyTargetChams(target, refreshOcclusion)
    if target.Kind == "local" then
        applyLocalPlayerChams(target.Model)
    elseif target.Kind == "bot" or target.Kind == "enemy" then
        applyModelPartChams(target.Model, "VisPlayer", "VisPlayerWall", "VisPlayerColor", "VisPlayerWallColor", "VisPlayerStyle", "VisPlayerWallStyle", refreshOcclusion)
    else
        applyModelPartChams(target.Model, "VisTeammate", "VisTeammateWall", "VisTeammateColor", "VisTeammateWallColor", "VisTeammateStyle", "VisTeammateWallStyle", refreshOcclusion)
    end
end

-- On shot: по факту попадания (сервер сам шлёт клиенту remote Hitmarker /
-- BulletHit) оставляем «гоуст» — замороженную копию цели в позе момента
-- попадания, залитую цветом VisOnShotColor (flat-чамсы, "shot record").
-- Стартует плотной, в последнюю секунду плавно тает. Сквозь стены (Highlight).
-- Триггер — только серверный сигнал попадания, поэтому нет ни ложных
-- срабатываний (промах), ни пропусков при разбросе (спред).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OnShot = {
    Ghosts = {},      -- массив {Model, Highlight, Parts, Expiry}
    HitConns = {},    -- список RBXScriptConnection к remote'ам попадания
    Hooked = false
}
local ONSHOT_DURATION = 3  -- сколько живёт гоуст (сек)
local ONSHOT_FADE = 1      -- длительность затухания в конце (сек)
local MAX_GHOSTS = 8       -- лимит одновременных гоустов
local HIT_REMOTES = {"Hitmarker", "BulletHit"}  -- имена remote'ов попадания

local function smoothstep(t)
    return t * t * (3 - 2 * t)
end

local function destroyGhost(g)
    if g.Highlight and g.Highlight.Parent then g.Highlight:Destroy() end
    if g.Model and g.Model.Parent then g.Model:Destroy() end
end

local function spawnGhost(model)
    local color = chamsColor("VisOnShotColor", Color3.fromRGB(110, 110, 110))
    local wasArchivable = model.Archivable
    model.Archivable = true
    local ghost = model:Clone()
    model.Archivable = wasArchivable
    if not ghost then return nil end
    local parts = {}
    for _, obj in ipairs(ghost:GetDescendants()) do
        if obj:IsA("Humanoid") or obj:IsA("AnimationController")
            or obj:IsA("Script") or obj:IsA("LocalScript")
            or obj:IsA("Tool") or obj:IsA("ForceField")
            or obj:IsA("BillboardGui") or obj:IsA("Sound")
            or obj:IsA("Highlight") or obj:IsA("Decal")
            or obj:IsA("JointInstance") or obj:IsA("WeldConstraint")
            or obj:IsA("Motor6D") or obj:IsA("Attachment")
            or obj:IsA("WrapLayer") or obj:IsA("WrapTarget") then
            pcall(function() obj:Destroy() end)
        elseif obj:IsA("BasePart") then
            obj.Anchored = true
            obj.CanCollide = false
            obj.CanQuery = false
            obj.CanTouch = false
            obj.CastShadow = false
            obj.Color = color
            obj.Material = Enum.Material.SmoothPlastic
            obj.Transparency = 0
            parts[#parts + 1] = obj
        end
    end
    local hl = Instance.new("Highlight")
    hl.Name = "GS_OnShot"
    hl.Adornee = ghost
    hl.FillColor = color
    hl.FillTransparency = 0
    hl.OutlineColor = color
    hl.OutlineTransparency = chamsStyle("VisOnShotStyle") == "Normal" and 0 or 1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = true
    hl.Parent = ghost
    ghost.Parent = Workspace
    return {
        Model = ghost,
        Target = model,
        Highlight = hl,
        Parts = parts,
        Expiry = tick() + ONSHOT_DURATION,
    }
end

-- рекурсивный поиск remote'а по имени в ReplicatedStorage
local function findRemoteByName(name)
    local rs = ReplicatedStorage
    local function scan(node)
        for _, child in ipairs(node:GetChildren()) do
            if child.Name == name and (child:IsA("RemoteEvent") or child:IsA("RemoteFunction")) then
                return child
            end
        end
        for _, child in ipairs(node:GetChildren()) do
            if not child:IsA("Script") and not child:IsA("LocalScript") and not child:IsA("ModuleScript") then
                local r = scan(child)
                if r then return r end
            end
        end
        return nil
    end
    return scan(rs)
end

-- ближайшая живая модель (игрок или бот) к мировой точке
local function nearestLivingModel(pos)
    local best, bestDist
    local function consider(model)
        local root = findRootPart(model)
        if not root then return end
        local d = (root.Position - pos).Magnitude
        if not bestDist or d < bestDist then bestDist, best = d, model end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and Entity.IsAliveModel(player.Character) then consider(player.Character) end
    end
    for bot in pairs(ChamsRuntime.Bots) do
        if Entity.IsAliveModel(bot) then consider(bot) end
    end
    if best and bestDist and bestDist < 14 then return best end
    return nil
end

-- вытащить цель из аргументов remote'а (Player / Model / BasePart / позиция)
local function locateTarget(args)
    for _, v in ipairs(args) do
        local t = typeof(v)
        if t == "Instance" then
            if v:IsA("Player") then
                if v.Character and Entity.IsAliveModel(v.Character) then return v.Character end
            elseif v:IsA("Model") and Entity.IsAliveModel(v) then
                return v
            elseif v:IsA("BasePart") then
                local m = v:FindFirstAncestorOfClass("Model")
                if m and Entity.IsAliveModel(m) then return m end
            end
        elseif t == "Vector3" then
            local m = nearestLivingModel(v)
            if m then return m end
        elseif t == "CFrame" then
            local m = nearestLivingModel(v.Position)
            if m then return m end
        end
    end
    return nil
end

-- фолбэк: если аргументы remote'а не несут цель — ищем её под прицелом
local function raycastTarget()
    local camera = Workspace.CurrentCamera
    local char = LocalPlayer.Character
    if not camera or not char then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, camera}
    local hit = Workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * 500, params)
    if hit and hit.Instance then
        local m = hit.Instance:FindFirstAncestorOfClass("Model")
        if m and m ~= char and Entity.IsAliveModel(m) then return m end
    end
    return nil
end

local function spawnGhostOnHit(args)
    if flag("VisOnShot", false) ~= true then return end
    local target = locateTarget(args) or raycastTarget()
    if not target then return end
    while #OnShot.Ghosts >= MAX_GHOSTS do
        destroyGhost(OnShot.Ghosts[1])
        table.remove(OnShot.Ghosts, 1)
    end
    local ghost = spawnGhost(target)
    if ghost then
        OnShot.Ghosts[#OnShot.Ghosts + 1] = ghost
    end
end

-- цепляемся к серверным сигналам попадания (один раз)
local function ensureHooked()
    if OnShot.Hooked then return end
    OnShot.Hooked = true
    for _, name in ipairs(HIT_REMOTES) do
        local remote = findRemoteByName(name)
        if remote and remote.OnClientEvent then
            OnShot.HitConns[#OnShot.HitConns + 1] = remote.OnClientEvent:Connect(function(...)
                spawnGhostOnHit({...})
            end)
        end
    end
end

local function OnShotUpdate()
    if flag("VisOnShot", false) ~= true then
        for _, g in ipairs(OnShot.Ghosts) do destroyGhost(g) end
        table.clear(OnShot.Ghosts)
        return
    end
    ensureHooked()

    local now = tick()
    for i = #OnShot.Ghosts, 1, -1 do
        local g = OnShot.Ghosts[i]
        local remaining = g.Expiry - now
        if remaining <= 0 then
            destroyGhost(g)
            table.remove(OnShot.Ghosts, i)
        else
            local fade = remaining < ONSHOT_FADE and smoothstep(remaining / ONSHOT_FADE) or 1
            local alpha = 1 - fade

            -- Чем ближе текущая модель противника к сохранённому shot-record,
            -- тем прозрачнее становится сам ghost, чтобы они не наслаивались.
            -- На расстоянии 0 studs ghost почти скрыт, после 12 studs эффект
            -- близости полностью исчезает.
            local proximityAlpha = 0
            if g.Target and g.Target.Parent and g.Model and g.Model.Parent then
                local targetRoot = findRootPart(g.Target)
                local ghostRoot = findRootPart(g.Model)
                if targetRoot and ghostRoot then
                    local distance = (targetRoot.Position - ghostRoot.Position).Magnitude
                    proximityAlpha = 1 - math.clamp(distance / 12, 0, 1)
                    proximityAlpha = proximityAlpha * 0.85
                end
            end
            local visualAlpha = math.max(alpha, proximityAlpha)
            for _, part in ipairs(g.Parts) do
                if part.Parent then part.Transparency = visualAlpha end
            end
            if g.Highlight and g.Highlight.Parent then
                g.Highlight.FillTransparency = visualAlpha
            end
        end
    end
end

function ChamsRuntime.Apply(deltaTime)
    OnShotUpdate()
    local targets = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local kind = player == LocalPlayer and "local" or (Entity.IsEnemy(player) and "enemy" or "teammate")
        addChamsTarget(targets, player.Character, kind, player)
    end
    ChamsRuntime.BotScanTimer -= deltaTime or (1 / 60)
    if ChamsRuntime.BotScanTimer <= 0 then
        ChamsRuntime.BotScanTimer = 0.5
        local bots = {}
        for _, bot in ipairs(Entity.GetNPCs()) do
            bots[bot] = true
        end
        ChamsRuntime.Bots = bots
    end
    for bot in pairs(ChamsRuntime.Bots) do
        addChamsTarget(targets, bot, "bot")
    end
    local camera = Workspace.CurrentCamera
    if camera then
        table.sort(targets, function(a, b)
            if a.Kind == "local" then return true end
            if b.Kind == "local" then return false end
            return (modelPosition(a.Model) - camera.CFrame.Position).Magnitude
                < (modelPosition(b.Model) - camera.CFrame.Position).Magnitude
        end)
    end
    local activeModels = {}
    local refreshOcclusion = ChamsRuntime.OcclusionTimer <= 0
    for index = 1, math.min(#targets, MAX_CHAM_TARGETS) do
        local target = targets[index]
        activeModels[target.Model] = true
        applyTargetChams(target, refreshOcclusion)
    end
    if refreshOcclusion then
        ChamsRuntime.OcclusionTimer = 0.08
    else
        ChamsRuntime.OcclusionTimer -= deltaTime or (1 / 60)
    end
    local staleModels = {}
    for model in pairs(modelPartsCache) do
        if not activeModels[model] then
            staleModels[#staleModels + 1] = model
        end
    end
    for _, model in ipairs(staleModels) do
        removeModelChams(model)
    end
    if LocalPlayer.Character and not activeModels[LocalPlayer.Character] then
        if Chams.LocalHighlight then
            if Chams.LocalHighlight.Parent then
                pcall(function() Chams.LocalHighlight:Destroy() end)
            end
            Chams.LocalHighlight = nil
        end
    end
end
function ChamsRuntime.Shutdown()
    TaskManager.RemoveConnection("ChamsApply")
    TaskManager.RemoveConnection("ChamsPlayers")
    Chams.ClearAll()
    table.clear(modelPartsCache)
    for _, conn in ipairs(OnShot.HitConns) do
        conn:Disconnect()
    end
    table.clear(OnShot.HitConns)
    for _, g in ipairs(OnShot.Ghosts) do
        destroyGhost(g)
    end
    table.clear(OnShot.Ghosts)
    ChamsRuntime.Bots = {}
    ChamsRuntime.BotScanTimer = 0
    ChamsRuntime.OcclusionTimer = 0
    ChamsRuntime.Started = false
end
function ChamsRuntime.Start()
    if ChamsRuntime.Started then return end
    ChamsRuntime.Started = true
    TaskManager.AddConnection("ChamsApply", RunService.RenderStepped, ChamsRuntime.Apply)
    TaskManager.AddConnection("ChamsPlayers", Players.PlayerRemoving, function(player)
        if player.Character then Chams.RemoveModelParts(player.Character) end
    end)
    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, ChamsRuntime.Shutdown)
    end
end
----------------------------------------------------------------------
-- Local player transparency (Chams -> "Local player transparency"):
--   Player overlap — тело становится прозрачным, когда камера упирается
--   в него вплотную ИЛИ когда моя модель пересекается с другим игроком/ботом
--   (чтобы не загораживало экран); отвёл камеру / разошёлся — тело вернулось
--   Weapon — держишь ЛЮБОЙ инструмент в руках -> прозрачнеет ТЕЛО персонажа
--   (сам инструмент не трогаем вообще)
-- Работает через LocalTransparencyModifier: Transparency игры не трогаем
-- -> конфликтов с игрой нет, форс-шоу исключён
----------------------------------------------------------------------
local LocalTransparency = {Started = false}
local lpAppliedParts = {}   -- part -> original LocalTransparencyModifier (значение до того, как мы тронули)
local lpBots = {}           -- model -> true: кэш NPC (скан раз в 0.5с, обход Workspace дорогой)
local lpBotScanTimer = 0

local LP_TRANSPARENCY = 0.15            -- степень прозрачности (небольшая — тело остаётся плотным, слегка просвечивает)
local LP_PLAYER_OVERLAP_DISTANCE = 2    -- моя модель пересекается с чужой (только когда реально вплотную)

-- Надёжное чтение multi-select флага: его значение — массив строк выбранных
-- опций (напр. {"Player overlap"}), но на случай кривого executor'а допускаем
-- и обычную строку. Не полагаемся на table.find (в части executor'ов его нет).
local function lpHasOption(option)
    local v = Library and Library.Flags and Library.Flags["VisLocalPlayerTransparency"]
    if type(v) ~= "table" then
        return v == option
    end
    for _, item in ipairs(v) do
        if item == option then
            return true
        end
    end
    return false
end

local function lpPointInPart(part, point)
    local localPoint = part.CFrame:PointToObjectSpace(point)
    local half = part.Size * 0.5 + Vector3.new(0.1, 0.1, 0.1)
    return math.abs(localPoint.X) <= half.X
        and math.abs(localPoint.Y) <= half.Y
        and math.abs(localPoint.Z) <= half.Z
end

local function lpScanBots(deltaTime)
    lpBotScanTimer = lpBotScanTimer - (deltaTime or (1 / 60))
    if lpBotScanTimer > 0 then
        return
    end
    lpBotScanTimer = 0.5
    local bots = {}
    for _, bot in ipairs(Entity.GetNPCs()) do
        bots[bot] = true
    end
    lpBots = bots
end

-- Единая точка принятия решения: true -> тело нужно сделать прозрачным.
-- Все условия читаются заново каждый кадр, поэтому переключение флагов
-- в меню действует мгновенно.
local function lpShouldTransparent(deltaTime)
    local overlapOn = lpHasOption("Player overlap")
    local weaponOn = lpHasOption("Weapon")

    local character = LocalPlayer.Character
    if not character or not character.Parent then
        return false
    end

    if not overlapOn and not weaponOn then
        return false
    end

    -- Условие 1 (Weapon): держим любой инструмент в руках
    if weaponOn and character:FindFirstChildOfClass("Tool") then
        return true
    end

    if not overlapOn then
        return false
    end

    local myRoot = findRootPart(character)

    -- Условие 2 (Player overlap): камера реально «воткнулась» в тело
    -- (зум вплотную / камеру затолкало в стену). Считаем оверлапом только
    -- когда камера оказалась ВНУТРИ части тела. Head пропускаем — в 1-м лице
    -- камера всегда сидит в голове, это не должно считаться оверлапом.
    local camera = Workspace.CurrentCamera
    if myRoot and camera then
        local camPos = camera.CFrame.Position
        for _, object in ipairs(character:GetDescendants()) do
            if object:IsA("BasePart")
                and object.Name ~= "Head"
                and object.Transparency < 1
                and not object:FindFirstAncestorOfClass("Tool")
                and lpPointInPart(object, camPos) then
                return true
            end
        end
    end

    -- Условие 3 (Player overlap): моя модель пересекается с другим игроком/ботом
    if myRoot then
        local myPos = myRoot.Position
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and Entity.IsAlive(player) then
                local root = Entity.GetRootPart(player)
                if root and (root.Position - myPos).Magnitude < LP_PLAYER_OVERLAP_DISTANCE then
                    return true
                end
            end
        end
        lpScanBots(deltaTime)
        for bot in pairs(lpBots) do
            if bot.Parent then
                local root = findRootPart(bot)
                if root and (root.Position - myPos).Magnitude < LP_PLAYER_OVERLAP_DISTANCE then
                    return true
                end
            end
        end
    end

    return false
end

-- Собрать все части тела (BasePart), которые можно прятать:
-- инструменты и их детали не трогаем
local function lpCollectBodyParts(character)
    local wanted = {}
    for _, object in ipairs(character:GetDescendants()) do
        if object:IsA("BasePart")
            and object.Transparency < 1
            and not object:FindFirstAncestorOfClass("Tool") then
            wanted[object] = true
        end
    end
    return wanted
end

-- Снимаем прозрачность со всех частей, что мы трогали: восстанавливаем
-- ИСХОДНОЕ значение каждой части (а не захардкоженный 0). Это гарантирует,
-- что после убирания оружия тело вернётся в норму, даже если игра за это
-- время поменяла прозрачность (точное сравнение с LP_TRANSPARENCY раньше
-- «не замечало» дрейф значения и оставляло тело прозрачным).
local function lpClearApplied()
    for part, original in pairs(lpAppliedParts) do
        if part.Parent then
            part.LocalTransparencyModifier = original
        end
    end
    table.clear(lpAppliedParts)
end

local function lpApplyTransparency(character)
    local wanted = lpCollectBodyParts(character)

    -- 1) убрать с частей, которые больше не должны быть прозрачными
    for part, original in pairs(lpAppliedParts) do
        if not wanted[part] then
            if part.Parent then
                part.LocalTransparencyModifier = original
            end
            lpAppliedParts[part] = nil
        end
    end

    -- 2) навесить на нужные. Поднимаем до нашей прозрачности, только если
    -- сейчас часть видна плотнее; если игра сама скрыла её (модификатор выше) — не трогаем.
    -- Исходное значение запоминаем один раз — на нём потом и откатываемся.
    for part in pairs(wanted) do
        if lpAppliedParts[part] == nil then
            lpAppliedParts[part] = part.LocalTransparencyModifier
        end
        if part.LocalTransparencyModifier < LP_TRANSPARENCY then
            part.LocalTransparencyModifier = LP_TRANSPARENCY
        end
    end
end

local function lpTransparencyApply(deltaTime)
    -- любой сбой логики не должен спамить ошибками в консоль каждый кадр
    local ok, shouldApply = pcall(lpShouldTransparent, deltaTime)
    local character = LocalPlayer.Character
    if not ok or shouldApply ~= true or not character or not character.Parent then
        localBodyTransparent = false
        lpClearApplied()
        return
    end
    localBodyTransparent = true
    lpApplyTransparency(character)
end

function LocalTransparency.Shutdown()
    pcall(function()
        RunService:UnbindFromRenderStep("GSLocalTransparency")
    end)
    TaskManager.RemoveConnection("LocalPlayerTransparency")
    localBodyTransparent = false
    lpClearApplied()
    LocalTransparency.Started = false
end

function LocalTransparency.Start()
    if LocalTransparency.Started then return end
    LocalTransparency.Started = true
    -- BindToRenderStep с большим приоритетом = выполняемся ПОСЛЕ камеры
    -- (камера сбрасывает модификатор — мы пишем поверх), фолбэк — RenderStepped
    local ok = pcall(function()
        RunService:BindToRenderStep("GSLocalTransparency", 2000, lpTransparencyApply)
    end)
    if not ok then
        TaskManager.AddConnection("LocalPlayerTransparency", RunService.RenderStepped, lpTransparencyApply)
    end
    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, LocalTransparency.Shutdown)
    end
end

local function capture()
    local s = {blooms = {}}
    for _, k in ipairs(PROPS) do s[k] = Lighting[k] end
    local a = Lighting:FindFirstChildOfClass("Atmosphere")
    if a then
        s.atmo = a
        s.atmoProps = {Density = a.Density, Offset = a.Offset, Color = a.Color, Decay = a.Decay, Glare = a.Glare, Haze = a.Haze}
    end
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("BloomEffect") then
            s.blooms[#s.blooms + 1] = {child, child.Enabled}
        end
    end
    return s
end
local function restore()
    if not snap then return end
    for _, k in ipairs(PROPS) do pcall(function() Lighting[k] = snap[k] end) end
    if snap.atmo and snap.atmo.Parent then
        for k, v in pairs(snap.atmoProps) do snap.atmo[k] = v end
    end
    for _, b in ipairs(snap.blooms) do
        if b[1].Parent then b[1].Enabled = b[2] end
    end
    if cc then cc:Destroy() cc = nil end
    local leftover = Lighting:FindFirstChild("GS_WorldCorrection")
    if leftover then leftover:Destroy() end
    on, autoTime = false, true
end
local function killWeather()
    curWeather = -1
    boltT0 = nil
    if folder then folder:Destroy() end
    folder, anchor, emitters = nil, nil, {}
end
local function setCC(enabled, tint, br, contrast, sat)
    if not enabled then
        if cc and cc.Parent then
            cc.Enabled, cc.Brightness, cc.Contrast, cc.Saturation, cc.TintColor = false, 0, 0, 0, Color3.new(1, 1, 1)
        end
        return
    end
    if not (cc and cc.Parent) then
        cc = Lighting:FindFirstChild("GS_WorldCorrection")
        if not (cc and cc:IsA("ColorCorrectionEffect")) then
            cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "GS_WorldCorrection"
            cc.Parent = Lighting
        end
    end
    cc.Enabled, cc.TintColor, cc.Brightness, cc.Contrast, cc.Saturation = true, tint, br, contrast, sat
end
local function applyEmitter(e, d)
    if not e then return end
    if not d then
        e.Enabled, e.Rate = false, 0
        return
    end
    e.Texture = d.tex
    e.Color = CS(d.col)
    e.Size = typeof(d.size) == "NumberSequence" and d.size or NS(d.size)
    e.Transparency = typeof(d.trans) == "NumberSequence" and d.trans or NS(d.trans)
    e.Lifetime, e.Speed = d.life, d.spd
    e.SpreadAngle = d.spread or Vector2.zero
    e.Acceleration = d.acc or Vector3.zero
    e.Rotation = d.rot or NR(0)
    e.RotSpeed = d.spin or NR(0)
    e.EmissionDirection = Enum.NormalId[d.dir or "Top"]
    e.LightEmission = d.glow or 0.05
    e.LockedToPart = false
    e.Rate = d.rate or 0
    e.Enabled = (d.rate or 0) > 0
    pcall(function()
        e.Orientation = Enum.ParticleOrientation[d.look or "FacingCamera"]
    end)
end
local function ensureWeather()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    if folder and folder.Parent ~= cam then killWeather() end
    if anchor and anchor.Parent then return anchor end
    folder = Instance.new("Folder")
    folder.Name = "GS_WorldWeather"
    anchor = Instance.new("Part")
    anchor.Name = "GS_WeatherAnchor"
    anchor.Anchored, anchor.CanCollide, anchor.CanQuery, anchor.CanTouch = true, false, false, false
    anchor.CastShadow, anchor.Massless, anchor.Transparency = false, true, 1
    anchor.Size = Vector3.new(90, 2, 90)
    anchor.Parent = folder
    folder.Parent = cam
    for _, name in ipairs({"p", "v"}) do
        local e = Instance.new("ParticleEmitter")
        e.Name, e.Enabled, e.Parent = name, false, anchor
        emitters[name] = e
    end
    return anchor
end
local function setWeather(id)
    if id == curWeather and anchor and anchor.Parent then return end
    if id <= 0 then
        applyEmitter(emitters.p)
        applyEmitter(emitters.v)
        curWeather = 0
        boltT0 = nil
        return
    end
    if not ensureWeather() then return end
    local w = WEATHER[id]
    curWeather = id
    anchor.Size = w.size
    applyEmitter(emitters.p, w.p)
    applyEmitter(emitters.v, w.v)
    if w.thunder then boltNext = os.clock() + 1.5 end
end
local function lightning(now)
    if not boltT0 then
        if now < boltNext then return 0 end
        boltNext, boltT0 = now + 4 + math.random() * 9, now
    end
    local t = now - boltT0
    if t < 0.045 then return 1.25 end
    if t < 0.11 then return 0.12 end
    if t < 0.17 then return 1.65 end
    boltT0 = nil
    return 0
end
local function apply()
    if flag("VisWorldEnabled", false) ~= true then
        if on then
            setWeather(0)
            killWeather()
            restore()
        end
        return
    end
    snap = snap or capture()
    on = true
    local mode = flag("VisBrightnessMode", "Off")
    local ambient = flag("VisAmbientColor", rgb(128, 128, 128))
    local night = flag("VisBrightnessColor", rgb(60, 80, 140))
    -- прозрачность пикеров: 0 = выбранный цвет действует полностью,
    -- 1 = как будто выключено: амбиент возвращается к оригинальному
    -- освещению игры (по снапшоту), ночник теряет цвет, оставляя затемнение
    local ambientStrength = 1 - pickerAlpha("VisAmbientColor")
    local nightStrength = 1 - pickerAlpha("VisBrightnessColor")
    local ambientIn = snap.Ambient:Lerp(ambient, ambientStrength)
    local ambientOut = snap.OutdoorAmbient:Lerp(ambient, ambientStrength)
    local hours = flag("VisTimeChanger", 0)
    local id = math.clamp(math.floor(flag("VisWeather", 0) + 0.5), 0, 5)
    local w = WEATHER[id]
    local white = Color3.new(1, 1, 1)
    if hours == 0 then
        if not autoTime then Lighting.ClockTime = snap.ClockTime autoTime = true end
    else
        autoTime = false
        Lighting.ClockTime = hours % 24
    end
    local tint, br, contrast, sat, useCC = white, 0, 0, 0, false
    if mode == "Fullbright" then
        Lighting.Brightness, Lighting.GlobalShadows = 2.6, false
        Lighting.Ambient = ambientIn
        Lighting.OutdoorAmbient = ambientOut:Lerp(white, 0.72)
        Lighting.ExposureCompensation = 0
        Lighting.ColorShift_Top, Lighting.ColorShift_Bottom = snap.ColorShift_Top, snap.ColorShift_Bottom
    elseif mode == "Night mode" then
        Lighting.Brightness, Lighting.GlobalShadows = 0.42, snap.GlobalShadows
        Lighting.Ambient = ambientIn:Lerp(night, 0.55 * nightStrength)
        Lighting.OutdoorAmbient = ambientOut:Lerp(night, 0.8 * nightStrength)
        Lighting.ColorShift_Top = snap.ColorShift_Top:Lerp(night, nightStrength)
        Lighting.ColorShift_Bottom = snap.ColorShift_Bottom:Lerp(night:Lerp(Color3.new(), 0.45), nightStrength)
        useCC, tint, br, contrast, sat = true, white:Lerp(night, nightStrength), -0.16, 0.1, -0.12
    else
        Lighting.Brightness, Lighting.GlobalShadows = snap.Brightness, snap.GlobalShadows
        Lighting.Ambient, Lighting.OutdoorAmbient = ambientIn, ambientOut
        Lighting.ExposureCompensation = snap.ExposureCompensation
        Lighting.ColorShift_Top, Lighting.ColorShift_Bottom = snap.ColorShift_Top, snap.ColorShift_Bottom
    end
    if w then
        Lighting.FogStart, Lighting.FogEnd, Lighting.FogColor = 0, w.fog, w.fogc
        useCC = true
        tint = tint:Lerp(w.tint, mode == "Night mode" and 0.45 or 0.7)
        br += w.ccb
        sat += w.ccs
    elseif mode == "Fullbright" then
        Lighting.FogStart, Lighting.FogEnd, Lighting.FogColor = 0, 1e6, snap.FogColor
    else
        Lighting.FogColor, Lighting.FogStart, Lighting.FogEnd = snap.FogColor, snap.FogStart, snap.FogEnd
    end
    if w and w.thunder then
        local flash = lightning(os.clock())
        if flash > 0 then
            useCC = true
            br += flash
            tint = tint:Lerp(white, math.clamp(flash, 0, 1))
            Lighting.OutdoorAmbient = Lighting.OutdoorAmbient:Lerp(white, math.clamp(flash, 0, 1))
        end
    else
        boltT0 = nil
    end
    setCC(useCC, tint, br, contrast, sat)
    if snap.atmo and snap.atmo.Parent then
        local a, p = snap.atmo, snap.atmoProps
        if not w then
            if mode == "Fullbright" then a.Density, a.Haze = 0, 0 else for k, v in pairs(p) do a[k] = v end end
        else
            a.Density, a.Haze = math.max(p.Density, w.atmo[1]), math.max(p.Haze, w.atmo[2])
            a.Color, a.Decay = w.atmo[3], w.atmo[4]
        end
    end
    for _, b in ipairs(snap.blooms) do
        if b[1].Parent then b[1].Enabled = mode ~= "Fullbright" and b[2] end
    end
    setWeather(id)
    if anchor and anchor.Parent then
        local cam = Workspace.CurrentCamera
        if cam then
            local pos = cam.CFrame.Position
            anchor.CFrame = CFrame.new(pos + Vector3.new(0, w and w.lift or 26, 0))
        end
    end
end
function World.Shutdown()
    pcall(function() RunService:UnbindFromRenderStep(STEP) end)
    TaskManager.RemoveConnection("WorldApply")
    setWeather(0)
    killWeather()
    restore()
end
function World.Start()
    snap = snap or capture()
    pcall(function() RunService:UnbindFromRenderStep(STEP) end)
    local ok = pcall(function()
        RunService:BindToRenderStep(STEP, Enum.RenderPriority.Last.Value + 10, apply)
    end)
    if not ok then
        TaskManager.AddConnection("WorldApply", RunService.RenderStepped, apply)
    end
    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, World.Shutdown)
    end
end
World.Start()
local Effects = {}
do
    local STEP = "GS_EffectsApply"
    local cam = Workspace.CurrentCamera
    local snapFOV = cam and cam.FieldOfView or 70
    local snapMode, snapMin, snapMax = LocalPlayer.CameraMode, LocalPlayer.CameraMinZoomDistance, LocalPlayer.CameraMaxZoomDistance
    local fovApplied, tpApplied = false, false
    local cache, touched, scanAcc = {}, {}, 0
    local bodyTransparency = {}
    local thirdpersonMode = nil
    local utilityZoomLocked = false
    local WALLMAT = {}
    for _, name in ipairs({
        "Brick", "Concrete", "Cobblestone", "Rock", "Slate", "WoodPlanks",
        "Granite", "Marble", "Basalt", "Asphalt", "Pavement", "Limestone",
        "Sandstone", "Glacier", "Salt",
    }) do
        pcall(function() WALLMAT[Enum.Material[name]] = true end)
    end
    local function isCombatWeaponEquipped()
        local character = LocalPlayer.Character
        local tool = character and character:FindFirstChildOfClass("Tool")
        if not tool then return false end
        local name = string.lower(tool.Name):gsub("[%s%p_]", "")
        local excluded = {
            "hammer", "киянка", "c4", "satchel", "satchelcharge",
            "explosive", "explosivecharge", "buildingplan", "builderplan",
            "buildplan", "blueprint", "строительныйплан", "rock", "stone",
            "pickaxe", "hatchet", "axe", "torch", "flashlight",
            "bandage", "medkit", "syringe", "food", "water", "wood",
        }
        for _, word in ipairs(excluded) do
            if name:find(word, 1, true) then return false end
        end
        for _, attributeName in ipairs({"IsWeapon", "Weapon", "Combat", "IsCombatWeapon"}) do
            local value = tool:GetAttribute(attributeName)
            if value == true then return true end
            if value == false and attributeName == "IsWeapon" then return false end
        end
        local weaponWords = {
            "weapon", "gun", "rifle", "pistol", "revolver", "smg", "shotgun",
            "sniper", "launcher", "bow", "crossbow", "nailgun", "ak", "lr",
            "mp5", "m39", "m249", "thompson", "python", "bolt", "semi",
            "eoka", "l96", "custom", "rocketlauncher",
        }
        for _, word in ipairs(weaponWords) do
            if name:find(word, 1, true) then return true end
        end
        for _, object in ipairs(tool:GetDescendants()) do
            local objectName = string.lower(object.Name):gsub("[%s%p_]", "")
            if objectName:find("muzzle", 1, true)
                or objectName:find("barrel", 1, true)
                or objectName:find("firepoint", 1, true)
                or objectName == "shoot"
                or objectName == "reload" then
                return true
            end
        end
        return false
    end
    local function restoreCamera()
        local current = Workspace.CurrentCamera
        if current and fovApplied then
            current.FieldOfView = snapFOV
        end
        fovApplied = false
        if tpApplied then
            pcall(function()
                LocalPlayer.CameraMode = snapMode
                LocalPlayer.CameraMinZoomDistance = snapMin
                LocalPlayer.CameraMaxZoomDistance = snapMax
            end)
        end
        tpApplied = false
    end
    local function restoreGlass()
        for part in pairs(touched) do
            if part.Parent then
                part.LocalTransparencyModifier = 0
            end
        end
        table.clear(touched)
        table.clear(cache)
    end
    local function restoreOwnBody()
        for part, transparency in pairs(bodyTransparency) do
            if part.Parent then
                part.LocalTransparencyModifier = transparency
            end
        end
        table.clear(bodyTransparency)
    end
    local function forceOwnBodyVisible()
        local character = LocalPlayer.Character
        if not character then return end
        for _, object in ipairs(character:GetDescendants()) do
            if object:IsA("BasePart") and not object:FindFirstAncestorOfClass("Tool") then
                if bodyTransparency[object] == nil then
                    bodyTransparency[object] = object.LocalTransparencyModifier
                end
                if not localBodyTransparent then
                    object.LocalTransparencyModifier = 0
                end
            end
        end
    end
    local function classify(part)
        if not part:IsA("BasePart") or part.Transparency > 0.95 then return false end
        if part.Name:sub(1, 3) == "GS_" then return false end
        local model = part:FindFirstAncestorOfClass("Model")
        if model and Players:GetPlayerFromCharacter(model) then return false end
        local current = Workspace.CurrentCamera
        if current and part:IsDescendantOf(current) then return false end
        local s = part.Size
        local a, b, c = s.X, s.Y, s.Z
        if a > b then a, b = b, a end
        if b > c then b, c = c, b end
        if a > b then a, b = b, a end
        if WALLMAT[part.Material] or (part.CanCollide and b >= 8 and c >= 8) then
            return "wall"
        end
        return "prop"
    end
    local function scanTransparent()
        if flag("VisTransparent", false) ~= true then
            if next(touched) then restoreGlass() end
            return
        end
        local current = Workspace.CurrentCamera
        if not current then return end
        local walls = math.clamp(flag("VisTransparentWalls", 50) / 100, 0, 1)
        local props = math.clamp(flag("VisTransparentProps", 50) / 100, 0, 1)
        local found = {}
        local list = Workspace:GetPartBoundsInRadius(current.CFrame.Position, 180)
        for i = 1, #list do
            local part = list[i]
            local kind = cache[part]
            if kind == nil then
                kind = classify(part)
                cache[part] = kind
            end
            if kind then
                found[part] = true
                part.LocalTransparencyModifier = kind == "wall" and walls or props
                touched[part] = true
            end
        end
        for part in pairs(touched) do
            if not found[part] then
                if part.Parent then part.LocalTransparencyModifier = 0 end
                touched[part] = nil
                cache[part] = nil
            end
        end
    end
    local function applyEffects(dt)
        local current = Workspace.CurrentCamera
        if not current then return end
        scanAcc += dt or 0
        if scanAcc >= 0.3 then
            scanAcc = 0
            scanTransparent()
        elseif flag("VisTransparent", false) == true then
            local walls = math.clamp(flag("VisTransparentWalls", 50) / 100, 0, 1)
            local props = math.clamp(flag("VisTransparentProps", 50) / 100, 0, 1)
            for part, kind in pairs(cache) do
                if kind and part.Parent then
                    part.LocalTransparencyModifier = kind == "wall" and walls or props
                end
            end
        end
        local thirdRequested = bindOn(flag("VisThirdperson", false) == true, "VisThirdpersonBind")
        local ownBodyVisible = flag("VisLocalPlayer", false) == true
            or flag("VisLocalPlayerFake", false) == true
            or thirdRequested
        if ownBodyVisible then
            forceOwnBodyVisible()
        else
            restoreOwnBody()
        end

        local combatWeapon = thirdRequested and isCombatWeaponEquipped()
        if thirdRequested then
            if not tpApplied then
                snapMode, snapMin, snapMax = LocalPlayer.CameraMode, LocalPlayer.CameraMinZoomDistance, LocalPlayer.CameraMaxZoomDistance
            end
            tpApplied = true
            local nextMode = combatWeapon and "weapon" or "distance"
            if thirdpersonMode ~= nextMode then
                thirdpersonMode = nextMode
                utilityZoomLocked = nextMode == "distance"
            end
            pcall(function()
                LocalPlayer.CameraMode = Enum.CameraMode.Classic
                if nextMode == "distance" and utilityZoomLocked then
                    local dist = math.clamp(flag("VisThirdpersonDistance", 10), 0.5, 128)
                    LocalPlayer.CameraMinZoomDistance = dist
                    LocalPlayer.CameraMaxZoomDistance = dist
                else
                    LocalPlayer.CameraMinZoomDistance = 0.5
                    LocalPlayer.CameraMaxZoomDistance = 128
                end
            end)
            if combatWeapon then
                local dist = math.clamp(flag("VisThirdpersonDistance", 10), 0.5, 128)
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = {LocalPlayer.Character, current}
                local hit = Workspace:Raycast(current.CFrame.Position, -current.CFrame.LookVector * dist, params)
                current.CFrame *= CFrame.new(0, 0, hit and math.max(hit.Distance - 0.35, 0) or dist)
            end
        else
            thirdpersonMode = nil
            utilityZoomLocked = false
            if tpApplied then
                pcall(function()
                    LocalPlayer.CameraMode = snapMode
                    LocalPlayer.CameraMinZoomDistance = snapMin
                    LocalPlayer.CameraMaxZoomDistance = snapMax
                end)
                tpApplied = false
            end
        end
        local zoomOn = bindOn(flag("VisCameraZoom", false) == true, "VisCameraZoomBind")
        local fovOn = flag("VisFOVChangerEnabled", false) == true
        if zoomOn or fovOn then
            if not fovApplied then snapFOV = current.FieldOfView end
            fovApplied = true
            current.FieldOfView = zoomOn and flag("VisCameraZoomValue", 40) or flag("VisFOVChanger", 70)
        elseif fovApplied then
            current.FieldOfView = snapFOV
            fovApplied = false
        end
    end
    function Effects.Shutdown()
        pcall(function() RunService:UnbindFromRenderStep(STEP) end)
        TaskManager.RemoveConnection("EffectsApply")
        TaskManager.RemoveConnection("EffectsUtilityWheel")
        restoreOwnBody()
        restoreGlass()
        restoreCamera()
    end
    function Effects.Start()
        pcall(function() RunService:UnbindFromRenderStep(STEP) end)
        local ok = pcall(function()
            RunService:BindToRenderStep(STEP, Enum.RenderPriority.Last.Value + 11, applyEffects)
        end)
        if not ok then
            TaskManager.AddConnection("EffectsApply", RunService.RenderStepped, applyEffects)
        end
        TaskManager.AddConnection("EffectsUtilityWheel", UserInputService.InputChanged, function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseWheel then return end
            if flag("VisThirdperson", false) ~= true then return end
            if isCombatWeaponEquipped() then return end
            utilityZoomLocked = false
            pcall(function()
                LocalPlayer.CameraMinZoomDistance = 0.5
                LocalPlayer.CameraMaxZoomDistance = 128
            end)
        end)
        if Library then
            Library.UnloadHooks = Library.UnloadHooks or {}
            table.insert(Library.UnloadHooks, Effects.Shutdown)
        end
    end
end
Effects.Start()

-- Backtrack chams: визуальная копия цели с задержкой по истории CFrame (полная копия персонажа со сглаживанием прозрачности при совпадении).
local BacktrackChams = {
    Started = false,
    History = {},   -- targetKey -> array of {Time, Frames = { [charPart] = CFrame }}
    Ghosts = {},    -- targetKey -> { Model, Highlight, PartPairs = { {Source = part, Ghost = ghostPart}... }, RootSource, RootGhost, Target = character }
    MaxSeconds = 1.5,
    Folder = nil
}
local BT_STEP = "GS_BacktrackChams"

local function btActive()
    if flag("VisBacktrack", false) ~= true then
        return false, 0
    end
    -- 1. Если включен Rage Aimbot + Backtrack
    local rageAimbot = flag("AimbotEnabled", false) == true
    local rageBacktrack = flag("AimbotBacktrack", false) == true
    if rageAimbot and rageBacktrack then
        local ms = tonumber(flag("AimbotBacktrackMs", 200)) or 200
        return true, math.clamp(ms, 0, 1200)
    end
    -- 2. Если включен Legit Aimbot + Backtrack
    local legitAimbot = bindOn(flag("LegitAimbotEnabled", false) == true, "LegitAimbotBind")
    local legitBacktrack = flag("OtherBacktrack", false) == true
    if legitAimbot and legitBacktrack then
        local ms = tonumber(flag("OtherBacktrackTime", 200)) or 200
        return true, math.clamp(ms, 0, 1200)
    end
    -- Если ни один из режимов аимбота с бектреком не включен — бектрек чамсы не активны
    return false, 0
end

local function btColorAndAlpha()
    local c = Library and Library.Flags and Library.Flags["VisBacktrackColor"]
    local col = (type(c) == "table" and typeof(c.Color) == "Color3") and c.Color or Color3.fromRGB(255, 255, 255)
    local trans = (type(c) == "table" and type(c.Transparency) == "number") and math.clamp(c.Transparency, 0, 1) or 0
    local style = flag("VisBacktrackStyle", "Flat")
    if style ~= "Normal" then style = "Flat" end
    return col, trans, style
end

local function btGetFolder()
    if BacktrackChams.Folder and BacktrackChams.Folder.Parent then
        return BacktrackChams.Folder
    end
    local folder = Workspace:FindFirstChild("GS_BacktrackFolder")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "GS_BacktrackFolder"
        folder.Parent = Workspace
    end
    BacktrackChams.Folder = folder
    return folder
end

local function btDestroy(targetKey)
    local g = BacktrackChams.Ghosts[targetKey]
    if g then
        if g.Highlight and g.Highlight.Parent then
            pcall(function() g.Highlight:Destroy() end)
        end
        if g.Model and g.Model.Parent then
            pcall(function() g.Model:Destroy() end)
        end
    end
    BacktrackChams.Ghosts[targetKey] = nil
    BacktrackChams.History[targetKey] = nil
end

local function btClearAll()
    for targetKey in pairs(BacktrackChams.Ghosts) do
        btDestroy(targetKey)
    end
    table.clear(BacktrackChams.Ghosts)
    table.clear(BacktrackChams.History)
    if BacktrackChams.Folder and BacktrackChams.Folder.Parent then
        pcall(function() BacktrackChams.Folder:Destroy() end)
    end
    BacktrackChams.Folder = nil
end

local function btIsValidTarget(char)
    if not char or not char.Parent then return false end
    local root = findRootPart(char)
    if not root then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return false end
    return true
end

local function btAllowsTarget(player, isBot)
    local targets = Library and Library.Flags and Library.Flags["VisBacktrackTargets"]
    local allowEnemy = true
    local allowTeam = false
    if type(targets) == "table" then
        allowEnemy = false
        allowTeam = false
        for _, t in ipairs(targets) do
            if t == "Enemy" or t == "Enemies" then
                allowEnemy = true
            elseif t == "Team" or t == "Teammate" or t == "Teammates" then
                allowTeam = true
            end
        end
        if not allowEnemy and not allowTeam then
            allowEnemy = true
        end
    elseif type(targets) == "string" then
        if targets == "Enemy" or targets == "Enemies" then
            allowEnemy = true
            allowTeam = false
        elseif targets == "Team" or targets == "Teammate" or targets == "Teammates" then
            allowEnemy = false
            allowTeam = true
        end
    end

    if isBot then
        return allowEnemy
    end

    if not player or player == LocalPlayer then return false end
    local isEnemy = Entity.IsEnemy(player)
    if isEnemy then
        return allowEnemy
    else
        return allowTeam
    end
end

local function btMakeGhost(targetKey, character)
    local col, trans, style = btColorAndAlpha()
    local folder = btGetFolder()

    local ghost = nil
    local wasArchivable = character.Archivable
    character.Archivable = true
    pcall(function()
        ghost = character:Clone()
    end)
    character.Archivable = wasArchivable

    local partPairs = {}
    local rootSource = findRootPart(character)
    local rootGhost = nil

    if ghost then
        -- Очищаем логику и физику из клонированного персонажа
        for _, obj in ipairs(ghost:GetDescendants()) do
            if obj:IsA("Humanoid") or obj:IsA("AnimationController")
                or obj:IsA("Script") or obj:IsA("LocalScript")
                or obj:IsA("Tool") or obj:IsA("ForceField")
                or obj:IsA("BillboardGui") or obj:IsA("Sound")
                or obj:IsA("Highlight") or obj:IsA("Decal")
                or obj:IsA("JointInstance") or obj:IsA("WeldConstraint")
                or obj:IsA("Motor6D") or obj:IsA("Attachment")
                or obj:IsA("WrapLayer") or obj:IsA("WrapTarget") then
                pcall(function() obj:Destroy() end)
            elseif obj:IsA("BasePart") then
                obj.Anchored = true
                obj.CanCollide = false
                obj.CanQuery = false
                obj.CanTouch = false
                obj.CastShadow = false
                obj.Material = Enum.Material.SmoothPlastic
                obj.Color = col
                obj.Transparency = style == "Normal" and math.max(trans, 0.6) or trans
            end
        end

        -- Сопоставляем части тела оригинала с частями клона
        local usedGhosts = {}
        for _, charPart in ipairs(character:GetDescendants()) do
            if charPart:IsA("BasePart") and not charPart:FindFirstAncestorOfClass("Tool") then
                for _, ghostPart in ipairs(ghost:GetDescendants()) do
                    if ghostPart:IsA("BasePart") and not usedGhosts[ghostPart] and ghostPart.Name == charPart.Name then
                        usedGhosts[ghostPart] = true
                        partPairs[#partPairs + 1] = {
                            Source = charPart,
                            Ghost = ghostPart
                        }
                        if charPart == rootSource then
                            rootGhost = ghostPart
                        end
                        break
                    end
                end
            end
        end
    else
        -- Фоллбэк: ручное создание партов
        ghost = Instance.new("Model")
        for _, charPart in ipairs(character:GetDescendants()) do
            if charPart:IsA("BasePart") and not charPart:FindFirstAncestorOfClass("Tool") then
                local p = Instance.new("Part")
                p.Name = charPart.Name
                p.Size = charPart.Size
                p.Shape = charPart:IsA("Part") and charPart.Shape or Enum.PartType.Block
                p.CFrame = charPart.CFrame
                p.Anchored = true
                p.CanCollide = false
                p.CanQuery = false
                p.CanTouch = false
                p.CastShadow = false
                p.Material = Enum.Material.SmoothPlastic
                p.Color = col
                p.Transparency = style == "Normal" and math.max(trans, 0.6) or trans
                p.Parent = ghost
                partPairs[#partPairs + 1] = {
                    Source = charPart,
                    Ghost = p
                }
                if charPart == rootSource then
                    rootGhost = p
                end
            end
        end
    end

    if not rootGhost and #partPairs > 0 then
        rootGhost = partPairs[1].Ghost
    end

    local hl = Instance.new("Highlight")
    hl.Name = "GS_BacktrackHighlight"
    hl.Adornee = ghost
    hl.FillColor = col
    hl.FillTransparency = style == "Normal" and math.max(trans, 0.6) or trans
    hl.OutlineColor = col
    hl.OutlineTransparency = style == "Normal" and 0 or 1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = true
    hl.Parent = ghost

    local nameStr = (typeof(targetKey) == "Instance" and targetKey.Name) or (character and character.Name) or "Target"
    ghost.Name = "GS_BacktrackGhost_" .. nameStr
    ghost.Parent = folder

    local ghostData = {
        Model = ghost,
        Highlight = hl,
        PartPairs = partPairs,
        RootSource = rootSource,
        RootGhost = rootGhost,
        Target = character
    }
    BacktrackChams.Ghosts[targetKey] = ghostData
    return ghostData
end

local function btCapture(targetKey, ghostData, now)
    local history = BacktrackChams.History[targetKey]
    if not history then
        history = {}
        BacktrackChams.History[targetKey] = history
    end

    local frame = {Time = now, RootPos = nil, CFrames = {}}

    for _, pair in ipairs(ghostData.PartPairs) do
        local src = pair.Source
        if src and src.Parent then
            local cf = src.CFrame
            frame.CFrames[src] = cf
            if src == ghostData.RootSource then
                frame.RootPos = cf.Position
            end
        end
    end

    if not frame.RootPos and ghostData.RootSource and ghostData.RootSource.Parent then
        frame.RootPos = ghostData.RootSource.Position
    end

    history[#history + 1] = frame

    while history[1] and (now - history[1].Time) > BacktrackChams.MaxSeconds do
        table.remove(history, 1)
    end
end

local function btFindFrame(history, wantedTime)
    if not history or #history == 0 then
        return nil
    end
    if wantedTime <= history[1].Time then
        return history[1]
    end
    if wantedTime >= history[#history].Time then
        return history[#history]
    end

    local bestFrame = history[1]
    local bestDiff = math.abs(history[1].Time - wantedTime)
    for i = 2, #history do
        local diff = math.abs(history[i].Time - wantedTime)
        if diff < bestDiff then
            bestDiff = diff
            bestFrame = history[i]
        else
            break
        end
    end
    return bestFrame
end

local function btUpdate()
    local enabled, ms = btActive()
    if not enabled then
        if next(BacktrackChams.Ghosts) then
            btClearAll()
        end
        return
    end

    local now = os.clock()
    local wanted = now - (ms / 1000)
    local col, trans, style = btColorAndAlpha()
    local fillTrans = style == "Normal" and math.max(trans, 0.6) or trans
    local outlineTrans = style == "Normal" and 0 or 1

    local camera = Workspace.CurrentCamera
    local camPos = camera and camera.CFrame.Position or Vector3.zero

    local candidates = {}

    -- 1. Все остальные живые игроки с учётом фильтра (Enemy / Team)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and btAllowsTarget(player, false) then
            local char = player.Character
            if btIsValidTarget(char) then
                local dist = (modelPosition(char) - camPos).Magnitude
                candidates[#candidates + 1] = {
                    Key = player,
                    Character = char,
                    Distance = dist
                }
            end
        end
    end

    -- 2. Боты / NPC (считаются как враги)
    if btAllowsTarget(nil, true) and ChamsRuntime and ChamsRuntime.Bots then
        for bot in pairs(ChamsRuntime.Bots) do
            if btIsValidTarget(bot) then
                local dist = (modelPosition(bot) - camPos).Magnitude
                candidates[#candidates + 1] = {
                    Key = bot,
                    Character = bot,
                    Distance = dist
                }
            end
        end
    end

    -- Сортировка по дистанции от камеры (ближайшие цели в приоритете)
    table.sort(candidates, function(a, b)
        return a.Distance < b.Distance
    end)

    local currentTargets = {}
    local maxTargets = math.min(#candidates, MAX_CHAM_TARGETS)
    local MAX_BT_DISTANCE = 500 -- studs: лимит дальности рендера бектрека

    for i = 1, maxTargets do
        local candidate = candidates[i]
        if candidate.Distance <= MAX_BT_DISTANCE then
            currentTargets[candidate.Key] = candidate.Character
        end
    end

    -- Очистка неактивных / вышедших за пределы дистанции
    for targetKey in pairs(BacktrackChams.Ghosts) do
        if not currentTargets[targetKey] then
            btDestroy(targetKey)
        end
    end

    -- Запись истории и отрисовка призрака
    for targetKey, character in pairs(currentTargets) do
        local ghostData = BacktrackChams.Ghosts[targetKey]
        if not ghostData or not ghostData.Model.Parent or ghostData.Target ~= character then
            btDestroy(targetKey)
            ghostData = btMakeGhost(targetKey, character)
        end

        if ghostData then
            btCapture(targetKey, ghostData, now)

            local history = BacktrackChams.History[targetKey]
            local chosen = btFindFrame(history, wanted)

            if chosen then
                -- Логика прозрачности при совпадении с текущим персонажем:
                -- Когда цель стоит на месте (дистанция 0 studs) — призрак полностью прозрачный (невидим),
                -- чтобы не создавать двойное наслоение поверх основного тела.
                -- Когда цель двигается — на дистанции 3.2+ studs призрак становится полностью непрозрачным.
                local BT_PROXIMITY_DIST = 3.2 -- studs
                local proximityAlpha = 0
                local currentPos = ghostData.RootSource and ghostData.RootSource.Parent and ghostData.RootSource.Position
                local historicalPos = chosen.RootPos

                if currentPos and historicalPos then
                    local distance = (currentPos - historicalPos).Magnitude
                    if distance < BT_PROXIMITY_DIST then
                        local factor = 1 - (distance / BT_PROXIMITY_DIST)
                        proximityAlpha = smoothstep(factor)
                    end
                else
                    proximityAlpha = 0
                end

                -- Итоговая прозрачность: плавно уходит в 1 (полная невидимость) при совпадении с телом
                local actualFillTrans = fillTrans + (1 - fillTrans) * proximityAlpha
                local actualOutlineTrans = outlineTrans + (1 - outlineTrans) * proximityAlpha
                local isVisible = actualFillTrans < 0.99 or actualOutlineTrans < 0.99

                -- Обновляем Highlight
                if ghostData.Highlight and ghostData.Highlight.Parent then
                    ghostData.Highlight.FillColor = col
                    ghostData.Highlight.FillTransparency = actualFillTrans
                    ghostData.Highlight.OutlineColor = col
                    ghostData.Highlight.OutlineTransparency = actualOutlineTrans
                    ghostData.Highlight.Enabled = isVisible
                end

                -- Обновляем CFrame и прозрачность каждой части тела клона
                for _, pair in ipairs(ghostData.PartPairs) do
                    local ghostPart = pair.Ghost
                    local cf = chosen.CFrames[pair.Source]
                    if ghostPart and ghostPart.Parent then
                        if cf then
                            ghostPart.CFrame = cf
                        end
                        ghostPart.Color = col
                        ghostPart.Transparency = isVisible and actualFillTrans or 1
                    end
                end
            end
        end
    end
end

function BacktrackChams.Shutdown()
    pcall(function() RunService:UnbindFromRenderStep(BT_STEP) end)
    TaskManager.RemoveConnection("BacktrackApply")
    btClearAll()
    BacktrackChams.Started = false
end

function BacktrackChams.Start()
    if BacktrackChams.Started then return end
    BacktrackChams.Started = true
    local ok = pcall(function()
        RunService:BindToRenderStep(BT_STEP, Enum.RenderPriority.Last.Value + 12, btUpdate)
    end)
    if not ok then
        TaskManager.AddConnection("BacktrackApply", RunService.RenderStepped, btUpdate)
    end
    if Library then
        Library.UnloadHooks = Library.UnloadHooks or {}
        table.insert(Library.UnloadHooks, BacktrackChams.Shutdown)
    end
end
BacktrackChams.Start()

-- // ESP — реальная отрисовка по флагам секции "Preview ESP"
-- Вкл/выкл: ESPBox, ESPHealth, ESPName, ESPDistance, ESPPing, ESPItem, ESPHit (ресурсы в ЕСП удалены; readResources остался для плеер-листа)
-- Слоты:   ESP<Element>Slot (TopLeft..BottomRight / LeftTop..RightBottom) — читаются live,
--          так что перетаскивание чипов в превью сразу двигает реальный ESP
-- Настройки: ESPBoxStyle/Color, ESPHealth*, ESPNameColor, ESPDistance*, ESPPing*, ESPItem*
local ESP = {}
do
    local MAX_TARGETS = 14
    local LINE_HEIGHT = 14
    local BAR_GAP = 3 -- отступ полосок от бокса
    local BAR_THICKNESS_MAX = 4 -- толщина полосок вблизи
    local BAR_THICKNESS_MIN = 2 -- толщина полосок вдали
    local FONT = 0

    local Cache = {}
    local BotScanTimer = 0
    local Bots = {}
    local Started = false
    local Notified = {}

    -- реальная проверка Drawing API: создаём/удаляем тестовые объекты, а не доверяем typeof
    local Supported = false
    local QuadOk = false
    do
        local ok = pcall(function()
            if Drawing == nil or Drawing.new == nil then
                error("Drawing global missing")
            end
            local line = Drawing.new("Line")
            line.From = Vector2.new(0, 0)
            line.To = Vector2.new(1, 1)
            line.Thickness = 1
            line.Transparency = 1
            line.Visible = false
            local text = Drawing.new("Text")
            text.Text = "gs"
            text.Size = 13
            text.Outline = true
            text.Visible = false
            pcall(function()
                text.Font = 0
            end)
            pcall(function()
                line:Remove()
            end)
            pcall(function()
                text:Remove()
            end)
        end)
        Supported = ok
        QuadOk = pcall(function()
            local quad = Drawing.new("Quad")
            quad.Thickness = 2
            quad.Filled = false
            quad.Transparency = 1
            quad.PointA = Vector2.new(0, 0)
            quad.PointB = Vector2.new(8, 0)
            quad.PointC = Vector2.new(8, 8)
            quad.PointD = Vector2.new(0, 8)
            quad.Visible = false
            pcall(function()
                quad:Remove()
            end)
        end)
        -- подбираем рабочий шрифт (в части executor'ов 2/3 не поддерживаются)
        for _, font in ipairs({0, 1, 2, 3}) do
            local fontOk = pcall(function()
                local text = Drawing.new("Text")
                text.Font = font
                pcall(function()
                    text:Remove()
                end)
            end)
            if fontOk then
                FONT = font
                break
            end
        end
    end

    local function notifyOnce(key, text)
        if Notified[key] then
            return
        end
        Notified[key] = true
        if Library and Library.Notifications then
            pcall(function()
                Library.Notifications:Create({Name = text})
            end)
        end
    end

    local DEFAULT_SLOTS = {
        Health = "LeftMiddle",
        Name = "TopCenter",
        Distance = "BottomCenter",
        Ping = "BottomCenter",
        Item = "BottomCenter",
        Hit = "RightTop",
    }

    local function espOn(name)
        return flag("ESP" .. name, false) == true
    end

    local function espColor(name, fallbackColor)
        local value = Library and Library.Flags and Library.Flags[name]
        if type(value) == "table" and typeof(value.Color) == "Color3" then
            local transparency = type(value.Transparency) == "number"
                and math.clamp(value.Transparency, 0, 1) or 0
            return value.Color, transparency
        end
        return fallbackColor, 0
    end

    local function slotOf(name)
        return flag("ESP" .. name .. "Slot", DEFAULT_SLOTS[name] or "TopCenter")
    end

    local function sideOf(slotId)
        return slotId:match("^Left") and "Left"
            or slotId:match("^Right") and "Right"
            or slotId:match("^Top") and "Top"
            or slotId:match("^Bottom") and "Bottom"
            or "Top"
    end

    local function partOf(slotId, side)
        return slotId:sub(#side + 1)
    end

    local function newDrawing(entry, key, kind)
        local existing = entry.Drawings[key]
        if existing then
            return existing
        end
        local object = Drawing.new(kind)
        -- ВАЖНО: в Drawing API Transparency инвертирована относительно Roblox —
        -- 1 = непрозрачно, 0 = полностью невидимо. Дефолт ставим непрозрачным.
        if kind == "Text" then
            object.Size = 13
            object.Font = FONT
            object.Outline = true
            object.OutlineColor = Color3.new(0, 0, 0)
            object.Color = Color3.new(1, 1, 1)
            object.Center = false
        elseif kind == "Quad" then
            object.Thickness = 1
            object.Filled = false
            object.Color = Color3.new(1, 1, 1)
            object.Transparency = 1
        else
            object.Thickness = 1
            object.Color = Color3.new(1, 1, 1)
            object.Transparency = 1
        end
        object.Visible = false
        entry.Drawings[key] = object
        return object
    end

    -- конверсия Roblox-прозрачности (0 = opaque) в Drawing-прозрачность (1 = opaque)
    local function drawTransparency(value)
        return 1 - math.clamp(value or 0, 0, 1)
    end

    -- толщина полоски хп скейлится с размером бокса:
    -- вблизи до 3px, с дистанцией (бокс мельчает) плавно сужается до 1.5px
    local function barThickness(box)
        return math.clamp(box.Height * 0.03, BAR_THICKNESS_MIN, BAR_THICKNESS_MAX)
    end

    local function textWidth(text)
        local ok, bounds = pcall(function()
            return text.TextBounds
        end)
        if ok and typeof(bounds) == "Vector2" then
            return bounds.X
        end
        return 0
    end

    local function hideEntry(entry)
        for _, object in pairs(entry.Drawings) do
            if object.Visible then
                object.Visible = false
            end
        end
    end

    local function clearEntry(entry)
        for _, object in pairs(entry.Drawings) do
            pcall(function()
                object:Remove()
            end)
        end
        table.clear(entry.Drawings)
    end

    -- унифицированные доступы: работают и для игроков, и для ботов/NPC
    local function entryHumanoid(entry)
        if entry.Player then
            return Entity.GetHumanoid(entry.Player)
        end
        if entry.Model and entry.Model.Parent then
            return entry.Model:FindFirstChildOfClass("Humanoid")
        end
        return nil
    end

    local function entryCharacter(entry)
        if entry.Player then
            return Entity.GetCharacter(entry.Player)
        end
        return entry.Model
    end

    local function entryName(entry)
        if entry.Player then
            return entry.Player.DisplayName ~= "" and entry.Player.DisplayName or entry.Player.Name
        end
        return entry.Model and entry.Model.Name or "?"
    end

    local function entryDistance(entry, myRoot)
        local character = entryCharacter(entry)
        if not (myRoot and character) then
            return math.huge
        end
        local root = findRootPart(character)
        if not root then
            return math.huge
        end
        return (myRoot.Position - root.Position).Magnitude
    end

    -- Hit = "могу ли я сейчас попасть по цели": виден хотя бы один хитбокс (не за стеной).
    -- Используем те же парты, что подсвечивают чамсы (getChamsParts) — индикатор
    -- совпадает с хайлайтами 1в1, включая кастомные риги и R6, а не только стандартные R15-имена
    local function targetHittable(camera, character)
        local parts = getChamsParts(character)
        for _, part in ipairs(parts) do
            if not partIsOccluded(camera, part, character) then
                return true
            end
        end
        return false
    end

    -- экранная коробка: классический 2D-бокс — высоту берём из bounding box модели
    -- (плюс небольшой вертикальный паддинг), а ширину считаем от высоты (ratio),
    -- поэтому бокс не раздувается от раскинутых рук/пушки/поворота персонажа
    -- и на любой дистанции держит правильные пропорции (вытянутый, ~2.2:1)
    local BOX_WIDTH_RATIO = 0.65

    local function getScreenBox(model)
        local camera = Workspace.CurrentCamera
        if not camera then
            return nil
        end
        local rootPart = findRootPart(model)
        if not rootPart then
            return nil
        end
        local rootPos = rootPart.Position
        local height = 6
        local centerY = rootPos.Y
        pcall(function()
            local cf, size = model:GetBoundingBox()
            if size and size.Y > 1 then
                height = size.Y
                centerY = cf.Position.Y
            end
        end)
        local centerWorld = Vector3.new(rootPos.X, centerY, rootPos.Z)
        local center = camera:WorldToViewportPoint(centerWorld)
        if center.Z <= 0 then
            return nil
        end

        -- Высота бокса считается от ДИСТАНЦИИ до цели, а не от проекции
        -- вертикальной линии верх-низ. Раньше при взгляде сверху/сбоку эта
        -- вертикаль схлопывалась на экране почти в ноль -> бокс скукоживался.
        -- Теперь размер зависит только от расстояния и мировой высоты модели,
        -- поэтому при любом угле обзора бокс держит стабильный размер.
        local dist = math.max((camera.CFrame.Position - centerWorld).Magnitude, 1)
        local viewportY = camera.ViewportSize.Y
        local fov = math.rad(camera.FieldOfView)
        -- масштаб высоты растёт с дистанцией: вблизи 1.2, вдали до 1.5,
        -- чтобы на дальних целях бокс не выглядел слишком мелким
        local scaleMin, scaleMax, scaleRange = 1.2, 1.5, 150
        local t = math.clamp(dist / scaleRange, 0, 1)
        local heightScale = scaleMin + (scaleMax - scaleMin) * t
        local screenH = (height * heightScale / dist) * (viewportY / (2 * math.tan(fov / 2)))

        local boxHeight = math.max(screenH, 12)
        local boxWidth = math.max(boxHeight * BOX_WIDTH_RATIO, 7)
        local left = center.X - boxWidth * 0.5
        return {
            Left = left,
            Top = center.Y - boxHeight * 0.5,
            Right = left + boxWidth,
            Bottom = center.Y + boxHeight * 0.5,
            CenterX = center.X,
            Width = boxWidth,
            Height = boxHeight,
        }
    end

    -- имена ресурсов: английские И русские (игра может хранить "Дерево"/"Металл")
    local RESOURCE_PATTERNS = {
        Wood = {"wood", "дерев", "бревн"},
        Metal = {"metal", "метал"},
        Scrap = {"scrap", "скрап"},
    }
    -- string.lower не трогает кириллицу (только ASCII) — lowercase вручную:
    -- А-Я (0xD0 0x90..0xAF) -> а-я (0xD0 0xB0.. / 0xD1 0x80..), Ё -> ё
    local function lowerUtf8(text)
        local ascii = string.lower(text)
        local out = {}
        local index = 1
        while index <= #ascii do
            local b1 = string.byte(ascii, index)
            if (b1 == 0xD0 or b1 == 0xD1) and index < #ascii then
                local b2 = string.byte(ascii, index + 1)
                if b1 == 0xD0 and b2 >= 0x90 and b2 <= 0x9F then
                    out[#out + 1] = string.char(0xD0, b2 + 32)
                elseif b1 == 0xD0 and b2 >= 0xA0 and b2 <= 0xAF then
                    out[#out + 1] = string.char(0xD1, b2 - 32)
                elseif b1 == 0xD0 and b2 == 0x81 then
                    out[#out + 1] = string.char(0xD1, 0x91)
                else
                    out[#out + 1] = string.char(b1, b2)
                end
                index += 2
            else
                out[#out + 1] = string.sub(ascii, index, index)
                index += 1
            end
        end
        return table.concat(out)
    end
    local function matchResourceName(lower, key)
        local patterns = RESOURCE_PATTERNS[key]
        for _, pattern in ipairs(patterns) do
            if lower:find(pattern, 1, true) then
                return true
            end
        end
        return false
    end
    local function readResources(player)
        local result = {}
        local function readInstance(instance)
            if not instance then
                return
            end
            -- leaderstats и прямые IntValue/NumberValue-дети
            local containers = {instance}
            local stats = instance:FindFirstChild("leaderstats")
            if stats then
                containers[#containers + 1] = stats
            end
            for _, container in ipairs(containers) do
                for _, child in ipairs(container:GetChildren()) do
                    if child:IsA("IntValue") or child:IsA("NumberValue") then
                        local lower = lowerUtf8(child.Name)
                        for _, key in ipairs({"Wood", "Metal", "Scrap"}) do
                            if result[key] == nil and matchResourceName(lower, key) then
                                result[key] = child.Value
                                break
                            end
                        end
                    end
                end
            end
            -- атрибуты
            local ok, attrs = pcall(instance.GetAttributes, instance)
            if ok and type(attrs) == "table" then
                for name, value in pairs(attrs) do
                    if type(value) == "number" then
                        local lower = lowerUtf8(name)
                        for _, key in ipairs({"Wood", "Metal", "Scrap"}) do
                            if result[key] == nil and matchResourceName(lower, key) then
                                result[key] = value
                                break
                            end
                        end
                    end
                end
            end
        end
        readInstance(player)
        readInstance(player and player.Character)
        if result.Wood == nil and result.Metal == nil and result.Scrap == nil then
            return nil
        end
        return result
    end
    -- для плеер-листа (Skins): панель информации о выбранном игроке
    ESP.ReadResources = readResources

    -- тонкий прямоугольник-штрих через заполненный Quad (для corner-бокса и полосок)
    local function drawStroke(entry, key, x1, y1, x2, y2, thickness, color, transparency)
        local half = thickness / 2
        local quad = newDrawing(entry, key, "Quad")
        quad.Filled = true
        quad.Color = color
        quad.Transparency = drawTransparency(transparency)
        if math.abs(y2 - y1) < 0.01 then
            -- горизонтальный штрих
            quad.PointA = Vector2.new(x1, y1 - half)
            quad.PointB = Vector2.new(x2, y1 - half)
            quad.PointC = Vector2.new(x2, y1 + half)
            quad.PointD = Vector2.new(x1, y1 + half)
        else
            -- вертикальный штрих
            quad.PointA = Vector2.new(x1 - half, y1)
            quad.PointB = Vector2.new(x1 + half, y1)
            quad.PointC = Vector2.new(x2 + half, y2)
            quad.PointD = Vector2.new(x2 - half, y2)
        end
        quad.Visible = true
        return quad
    end

    local function drawBox(entry, box)
        if not QuadOk then
            return
        end
        local color, transparency = espColor("ESPBoxColor", Color3.fromRGB(255, 255, 255))
        -- прозрачность бокса ограничиваем, чтобы его нельзя было сделать полностью невидимым
        transparency = math.min(transparency, 0.9)
        if flag("ESPBoxStyle", "Full") == "Corner" then
            local cw = math.max(box.Width * 0.2, 5)
            local ch = math.max(box.Height * 0.2, 5)
            local strokes = {
                {box.Left, box.Top, box.Left + cw, box.Top},
                {box.Left, box.Top, box.Left, box.Top + ch},
                {box.Right, box.Top, box.Right - cw, box.Top},
                {box.Right, box.Top, box.Right, box.Top + ch},
                {box.Left, box.Bottom, box.Left + cw, box.Bottom},
                {box.Left, box.Bottom, box.Left, box.Bottom - ch},
                {box.Right, box.Bottom, box.Right - cw, box.Bottom},
                {box.Right, box.Bottom, box.Right, box.Bottom - ch},
            }
            for index, s in ipairs(strokes) do
                drawStroke(entry, "BoxOutline" .. index, s[1], s[2], s[3], s[4], 4, Color3.new(0, 0, 0), 0)
            end
            for index, s in ipairs(strokes) do
                drawStroke(entry, "Box" .. index, s[1], s[2], s[3], s[4], 2, color, transparency)
            end
        else
            -- сначала чёрная обводка (созданные раньше Drawing'и рендерятся ниже)
            local outline = newDrawing(entry, "BoxOutlineQuad", "Quad")
            outline.Filled = false
            outline.Thickness = 4
            outline.Color = Color3.new(0, 0, 0)
            outline.Transparency = drawTransparency(0)
            outline.PointA = Vector2.new(box.Left, box.Top)
            outline.PointB = Vector2.new(box.Right, box.Top)
            outline.PointC = Vector2.new(box.Right, box.Bottom)
            outline.PointD = Vector2.new(box.Left, box.Bottom)
            outline.Visible = true
            -- затем цветная рамка сверху
            local quad = newDrawing(entry, "BoxQuad", "Quad")
            quad.Filled = false
            quad.Thickness = 2
            quad.Color = color
            quad.Transparency = drawTransparency(transparency)
            quad.PointA = Vector2.new(box.Left, box.Top)
            quad.PointB = Vector2.new(box.Right, box.Top)
            quad.PointC = Vector2.new(box.Right, box.Bottom)
            quad.PointD = Vector2.new(box.Left, box.Bottom)
            quad.Visible = true
        end
    end

    -- полоска хп: вертикальная на Left/Right слотах, горизонтальная на Top/Bottom.
    -- Градиент: заливка режется на сегменты, ПЕРВЫЙ цвет пикера у верха/лево, ВТОРОЙ у низа/право.
    local function drawBar(entry, box, side, shift, key, ratio, color, colorTo, useGradient, showText, textValue)
        ratio = math.clamp(ratio, 0, 1)
        local half = barThickness(box) / 2
        local bg = newDrawing(entry, key .. "Bg", "Quad")
        bg.Filled = true
        bg.Color = Color3.new(0, 0, 0)
        bg.Transparency = drawTransparency(0)
        local vertical = side == "Left" or side == "Right"

        -- градиент: t = 0 у начала бара (верх для вертикального, лево для горизонтального)
        -- -> первый цвет из колорпикера; t = 1 у конца -> второй цвет (ровно как в превью)
        local function gradientColor(t)
            return color:Lerp(colorTo, math.clamp(t, 0, 1))
        end

        if vertical then
            local x = side == "Left" and (box.Left - shift) or (box.Right + shift)
            local left, right = x - half, x + half
            bg.PointA = Vector2.new(left, box.Top)
            bg.PointB = Vector2.new(right, box.Top)
            bg.PointC = Vector2.new(right, box.Bottom)
            bg.PointD = Vector2.new(left, box.Bottom)
            bg.Visible = true
            -- заливка хп растёт снизу: [fillTop, Bottom]
            local fillTop = box.Bottom - box.Height * ratio
            local fillBottom = box.Bottom
            if useGradient then
                local segments = math.clamp(math.floor(box.Height / 14), 5, 14)
                local segmentHeight = box.Height / segments
                for index = 0, segments - 1 do
                    local segTop = box.Top + index * segmentHeight
                    local segBottom = segTop + segmentHeight
                    -- рисуем сегменты, пересекающиеся с областью заливки
                    if segTop < fillBottom and segBottom > fillTop then
                        local drawTop = math.max(segTop, fillTop)
                        local drawBottom = math.min(segBottom, fillBottom)
                        -- цвет — по позиции сегмента в полном баре (от верха): 0 -> первый цвет
                        local t = ((segTop + segBottom) * 0.5 - box.Top) / box.Height
                        local quad = newDrawing(entry, key .. "Fill" .. index, "Quad")
                        quad.Filled = true
                        quad.Color = gradientColor(t)
                        quad.Transparency = drawTransparency(0)
                        quad.PointA = Vector2.new(left, drawTop)
                        quad.PointB = Vector2.new(right, drawTop)
                        quad.PointC = Vector2.new(right, drawBottom)
                        quad.PointD = Vector2.new(left, drawBottom)
                        quad.Visible = true
                    end
                end
            else
                local fill = newDrawing(entry, key .. "Fill", "Quad")
                fill.Filled = true
                fill.Color = color
                fill.Transparency = drawTransparency(0)
                fill.PointA = Vector2.new(left, fillTop)
                fill.PointB = Vector2.new(right, fillTop)
                fill.PointC = Vector2.new(right, fillBottom)
                fill.PointD = Vector2.new(left, fillBottom)
                fill.Visible = true
            end
            if showText and textValue then
                local text = newDrawing(entry, key .. "Text", "Text")
                text.Size = 11
                text.Center = false
                text.Color = Color3.new(1, 1, 1)
                text.Text = tostring(textValue)
                -- цифра у движущегося края заливки (верх заливки)
                local edgeY = fillTop - 6
                if side == "Left" then
                    text.Position = Vector2.new(left - textWidth(text) - 2, edgeY)
                else
                    text.Position = Vector2.new(right + 2, edgeY)
                end
                text.Visible = true
            end
        else
            local y = side == "Top" and (box.Top - shift) or (box.Bottom + shift)
            local top, bottom = y - half, y + half
            bg.PointA = Vector2.new(box.Left, top)
            bg.PointB = Vector2.new(box.Right, top)
            bg.PointC = Vector2.new(box.Right, bottom)
            bg.PointD = Vector2.new(box.Left, bottom)
            bg.Visible = true
            local fillLeft = box.Left + box.Width * ratio
            if useGradient then
                local segments = math.clamp(math.floor(box.Width / 14), 5, 14)
                local segmentWidth = box.Width / segments
                for index = 0, segments - 1 do
                    local segLeft = box.Left + index * segmentWidth
                    local segRight = segLeft + segmentWidth
                    -- заливка занимает [box.Left, fillLeft]: рисуем пересекающиеся сегменты
                    if segLeft < fillLeft then
                        local drawRight = math.min(segRight, fillLeft)
                        local t = ((segLeft + segRight) * 0.5 - box.Left) / box.Width
                        local quad = newDrawing(entry, key .. "Fill" .. index, "Quad")
                        quad.Filled = true
                        quad.Color = gradientColor(t)
                        quad.Transparency = drawTransparency(0)
                        quad.PointA = Vector2.new(segLeft, top)
                        quad.PointB = Vector2.new(drawRight, top)
                        quad.PointC = Vector2.new(drawRight, bottom)
                        quad.PointD = Vector2.new(segLeft, bottom)
                        quad.Visible = true
                    end
                end
            else
                local fill = newDrawing(entry, key .. "Fill", "Quad")
                fill.Filled = true
                fill.Color = color
                fill.Transparency = drawTransparency(0)
                fill.PointA = Vector2.new(box.Left, top)
                fill.PointB = Vector2.new(fillLeft, top)
                fill.PointC = Vector2.new(fillLeft, bottom)
                fill.PointD = Vector2.new(box.Left, bottom)
                fill.Visible = true
            end
            if showText and textValue then
                local text = newDrawing(entry, key .. "Text", "Text")
                text.Size = 11
                text.Center = true
                text.Color = Color3.new(1, 1, 1)
                text.Text = tostring(textValue)
                text.Position = Vector2.new(fillLeft, top - 14)
                text.Visible = true
            end
        end
    end

    -- тексты: группировка по слоту, вертикальный стек внутри слота, порядок как в превью.
    -- С дистанцией (бокс мельчает) тексты сжимаются: мельче шрифт и плотнее строки
    local function drawTexts(entry, box, pending)
        local scale = math.clamp(box.Height / 260, 0.7, 1)
        local lineHeight = LINE_HEIGHT * scale
        local fontSize = math.clamp(math.floor(13 * scale + 0.5), 9, 13)
        -- мелкий флаг (оружие): ~75% обычного размера, строку не сжимаем —
        -- текст центрируем внутри своей строки, вокруг остаётся свободное место
        local smallSize = math.clamp(math.floor(fontSize * 0.75 + 0.5), 8, 10)
        local groups = {}
        for _, item in ipairs(pending) do
            local id = item.Slot
            groups[id] = groups[id] or {}
            table.insert(groups[id], item)
        end
        for id, items in pairs(groups) do
            table.sort(items, function(a, b)
                return a.Order < b.Order
            end)
            local side = sideOf(id)
            local part = partOf(id, side)
            if side == "Top" or side == "Bottom" then
                local y = side == "Top" and (box.Top - BAR_GAP - lineHeight) or (box.Bottom + BAR_GAP)
                for _, item in ipairs(items) do
                    local itemFont = item.Small and smallSize or fontSize
                    local nudge = (fontSize - itemFont) * 0.5
                    local text = newDrawing(entry, item.Key, "Text")
                    text.Text = item.Text
                    text.Size = itemFont
                    text.Color = item.Color
                    if part == "Left" then
                        text.Center = false
                        text.Position = Vector2.new(box.Left, y + nudge)
                    elseif part == "Right" then
                        text.Center = false
                        text.Position = Vector2.new(box.Right - textWidth(text), y + nudge)
                    else
                        text.Center = true
                        text.Position = Vector2.new(box.CenterX, y + nudge)
                    end
                    text.Visible = true
                    y += lineHeight + 1
                end
            else
                local total = #items * (lineHeight + 1) - 1
                local y
                if part == "Top" then
                    y = box.Top
                elseif part == "Bottom" then
                    y = box.Bottom - total
                else
                    y = box.Top + (box.Height - total) * 0.5
                end
                for _, item in ipairs(items) do
                    local itemFont = item.Small and smallSize or fontSize
                    local nudge = (fontSize - itemFont) * 0.5
                    local text = newDrawing(entry, item.Key, "Text")
                    text.Text = item.Text
                    text.Size = itemFont
                    text.Color = item.Color
                    text.Center = false
                    if side == "Left" then
                        text.Position = Vector2.new(box.Left - BAR_GAP - textWidth(text), y + nudge)
                    else
                        text.Position = Vector2.new(box.Right + BAR_GAP, y + nudge)
                    end
                    text.Visible = true
                    y += lineHeight + 1
                end
            end
        end
    end

    local function updateEntry(entry, box, enabled, myRoot)
        hideEntry(entry)
        local character = entryCharacter(entry)
        local humanoid = entryHumanoid(entry)
        local player = entry.Player

        if enabled.Box then
            drawBox(entry, box)
        end

        local pending = {}

        if enabled.Name then
            pending[#pending + 1] = {
                Key = "Name",
                Text = entryName(entry),
                Slot = slotOf("Name"),
                Order = 1,
                Color = espColor("ESPNameColor", Color3.fromRGB(235, 235, 235)),
            }
        end

        if enabled.Distance and myRoot then
            local studs = entryDistance(entry, myRoot)
            local unit = flag("ESPDistanceUnit", "Meters")
            local text
            if unit == "Studs" then
                text = math.floor(studs) .. " studs"
            elseif unit == "Feet" then
                text = math.floor(studs / 3.571 * 3.281) .. "ft"
            else
                text = math.floor(studs / 3.571) .. "m"
            end
            pending[#pending + 1] = {
                Key = "Distance",
                Text = text,
                Slot = slotOf("Distance"),
                Order = 2,
                Color = espColor("ESPDistanceColor", Color3.fromRGB(235, 235, 235)),
            }
        end

        if enabled.Ping and player then
            local ok, ping = pcall(player.GetNetworkPing, player)
            local ms = ok and math.floor((ping or 0) * 1000) or 0
            local color = espColor("ESPPingColor", Color3.fromRGB(235, 235, 235))
            if flag("ESPPingChecker", false) == true then
                if ms <= 50 then
                    color = Color3.fromRGB(88, 214, 74)
                elseif ms <= 120 then
                    color = Color3.fromRGB(230, 200, 80)
                else
                    color = Color3.fromRGB(214, 79, 79)
                end
            end
            pending[#pending + 1] = {
                Key = "Ping",
                Text = ms .. "ms",
                Slot = slotOf("Ping"),
                Order = 3,
                Color = color,
            }
        end

        local tool = character and character:FindFirstChildOfClass("Tool")
        if enabled.Item and tool and flag("ESPItemText", true) == true then
            pending[#pending + 1] = {
                Key = "Item",
                Text = tool.Name,
                Slot = slotOf("Item"),
                Order = 4,
                -- название оружия рисуется мельче остальных флагов — вокруг него воздух
                Small = true,
                Color = espColor("ESPItemTextColor", Color3.fromRGB(190, 190, 190)),
            }
        end

        if enabled.Hit then
            -- проверяем видимость хитбоксов раз в 0.1с (дорогое удовольствие — GetPartsObscuringTarget)
            local now = os.clock()
            if entry.HitCheckedAt == nil or now - entry.HitCheckedAt >= 0.1 then
                entry.HitCheckedAt = now
                local camera = Workspace.CurrentCamera
                entry.Hittable = camera ~= nil and character ~= nil and targetHittable(camera, character)
            end
            if entry.Hittable then
                pending[#pending + 1] = {
                    Key = "Hit",
                    Text = "Hit",
                    Slot = slotOf("Hit"),
                    Order = 1,
                    Color = Color3.fromRGB(214, 79, 79),
                }
            end
        end

        -- полоски: глубина по стороне как в превью (LayoutBars)
        local thickness = barThickness(box)
        local depthBySide = {}
        if enabled.Health and humanoid then
            local side = sideOf(slotOf("Health"))
            local depth = depthBySide[side] or 0
            depthBySide[side] = depth + 1
            local ratio = humanoid.Health / math.max(humanoid.MaxHealth, 0.01)
            local color = espColor("ESPHealthColor", Color3.fromRGB(88, 214, 74))
            local colorTo = espColor("ESPHealthColorTo", Color3.fromRGB(214, 79, 79))
            drawBar(entry, box, side, BAR_GAP + depth * (thickness + 2), "Health",
                ratio, color, colorTo,
                flag("ESPHealthGradient", false) == true,
                flag("ESPHealthText", false) == true, math.floor(humanoid.Health + 0.5))
        end

        drawTexts(entry, box, pending)
    end

    local function runApply(deltaTime)
        local enabled = {
            Box = espOn("Box"),
            Health = espOn("Health"),
            Name = espOn("Name"),
            Distance = espOn("Distance"),
            Ping = espOn("Ping"),
            Item = espOn("Item"),
            Hit = espOn("Hit"),
        }
        local anyEnabled = false
        for _, value in pairs(enabled) do
            if value then
                anyEnabled = true
                break
            end
        end
        if not anyEnabled then
            for _, entry in pairs(Cache) do
                hideEntry(entry)
            end
            return
        end

        local myRoot = Entity.GetRootPart(LocalPlayer)

        -- цели: живые игроки...
        local targets = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and Entity.IsAlive(player) then
                targets[#targets + 1] = {Player = player}
            end
        end

        -- ...и боты/NPC (скан раз в 0.5с, как в чамсах)
        BotScanTimer -= deltaTime or (1 / 60)
        if BotScanTimer <= 0 then
            BotScanTimer = 0.5
            local bots = {}
            for _, bot in ipairs(Entity.GetNPCs()) do
                bots[bot] = true
            end
            Bots = bots
        end
        for model in pairs(Bots) do
            if Entity.IsAliveModel(model) then
                targets[#targets + 1] = {Model = model}
            end
        end

        for _, target in ipairs(targets) do
            target.Distance = myRoot and entryDistance(target, myRoot) or math.huge
        end
        table.sort(targets, function(a, b)
            return a.Distance < b.Distance
        end)

        local active = {}
        local count = math.min(#targets, MAX_TARGETS)
        for index = 1, count do
            active[targets[index].Player or targets[index].Model] = true
        end
        for key, entry in pairs(Cache) do
            if not active[key] then
                hideEntry(entry)
                -- дохлых/удалённых ботов чистим из кэша целиком
                if not entry.Player and not (entry.Model and entry.Model.Parent) then
                    clearEntry(entry)
                    Cache[key] = nil
                end
            end
        end

        for index = 1, count do
            local target = targets[index]
            local key = target.Player or target.Model
            local entry = Cache[key]
            if not entry then
                entry = {
                    Player = target.Player,
                    Model = target.Model,
                    Drawings = {},
                }
                Cache[key] = entry
            end
            local character = entryCharacter(entry)
            local box = character and getScreenBox(character)
            if box then
                updateEntry(entry, box, enabled, myRoot)
            else
                hideEntry(entry)
            end
        end
    end

    -- любой пад внутри кадра всплывает нотификацией, а не молча
    local function apply(deltaTime)
        local ok, err = pcall(runApply, deltaTime)
        if not ok then
            notifyOnce("error", "ESP error: " .. tostring(err))
        end
    end

    function ESP.Shutdown()
        TaskManager.RemoveConnection("ESPApply")
        TaskManager.RemoveConnection("ESPPlayers")
        for _, entry in pairs(Cache) do
            clearEntry(entry)
        end
        table.clear(Cache)
        table.clear(Bots)
        table.clear(Notified)
        BotScanTimer = 0
        Started = false
    end

    function ESP.Start()
        if Started then
            return
        end
        if not Supported then
            notifyOnce("unsupported", "ESP off: Drawing API unavailable in this executor")
            return
        end
        if not QuadOk then
            notifyOnce("noquad", "ESP: Drawing Quad не поддерживается — боксы не отрисуются")
        end
        Started = true
        TaskManager.AddConnection("ESPApply", RunService.RenderStepped, apply)
        TaskManager.AddConnection("ESPPlayers", Players.PlayerRemoving, function(player)
            local entry = Cache[player]
            if entry then
                clearEntry(entry)
                Cache[player] = nil
            end
        end)
        if Library then
            Library.UnloadHooks = Library.UnloadHooks or {}
            table.insert(Library.UnloadHooks, ESP.Shutdown)
        end
        -- стартовая диагностика: сразу видно, подхватились ли флаги превью
        local on = {}
        for _, name in ipairs({"Box", "Health", "Name", "Distance", "Ping", "Resources", "Item", "Hit"}) do
            if espOn(name) then
                on[#on + 1] = name
            end
        end
        if #on == 0 then
            notifyOnce("noflags", "ESP ready, но все элементы выключены (включи в Preview ESP)")
        else
            notifyOnce("ready", "ESP ready: " .. table.concat(on, ", "))
        end
        -- доступ из Lua-редактора библиотеки: GSESP.Debug(), GSESP.Flags() и т.д.
        if getgenv then
            getgenv().GSESP = ESP
        end
    end

    function ESP.Debug()
        local status = {
            Supported = Supported,
            QuadSupported = QuadOk,
            Started = Started,
            Font = FONT,
            CachedTargets = 0,
            Bots = 0,
        }
        for _ in pairs(Cache) do
            status.CachedTargets += 1
        end
        for _ in pairs(Bots) do
            status.Bots += 1
        end
        status.Flags = {}
        for _, name in ipairs({"Box", "Health", "Name", "Distance", "Ping", "Resources", "Item", "Hit"}) do
            status.Flags[name] = espOn(name)
        end
        print("[GSESP] --- status ---")
        for key, value in pairs(status) do
            if type(value) ~= "table" then
                print("[GSESP] " .. key .. ":", value)
            end
        end
        local flagList = {}
        for name, value in pairs(status.Flags) do
            flagList[#flagList + 1] = (value and "+" or "-") .. name
        end
        print("[GSESP] flags:", table.concat(flagList, " "))
        return status
    end
end
ESP.Start()
ChamsRuntime.Start()
LocalTransparency.Start()

----------------------------------------------------------------------
-- Player list (Skins -> Players): панель информации о выбранном игроке.
-- Ресурсы читаются тем же ридером, что и для ESP; если данных нет —
-- в панели пишем "нет информации" (в ESP строка просто не рисуется)
----------------------------------------------------------------------
local PlayerList = {}
local NO_INFO = "нет информации"
local function playerListApi()
    local tabs = Library and Library.TabsByName
    return tabs and tabs["skins"] and tabs["skins"].PlayerList or nil
end
function PlayerList.Apply()
    local api = playerListApi()
    if not api or type(api.SetInfo) ~= "function" then
        return
    end
    local selected = api.GetSelected and api.GetSelected() or nil
    if not selected then
        api.SetInfo(nil)
        return
    end
    local target = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name == selected then
            target = player
            break
        end
    end
    if not target then
        api.SetInfo(nil)
        return
    end
    local data = {}
    -- ресурсы: нет данных -> "нет информации"
    local resources = ESP.ReadResources and ESP.ReadResources(target) or nil
    data.Wood = resources and resources.Wood ~= nil and tostring(resources.Wood) or NO_INFO
    data.Metal = resources and resources.Metal ~= nil and tostring(resources.Metal) or NO_INFO
    data.Scrap = resources and resources.Scrap ~= nil and tostring(resources.Scrap) or NO_INFO
    -- состояние
    local character = target.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and findRootPart(character)
    if humanoid then
        data.Health = tostring(math.floor(humanoid.Health + 0.5)) .. " / " .. tostring(math.floor(humanoid.MaxHealth + 0.5))
    else
        data.Health = NO_INFO
    end
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        data.Weapon = tool and tool.Name or "-"
    else
        data.Weapon = NO_INFO
    end
    data.Team = target.Team and target.Team.Name or "-"
    -- позиция
    if root then
        local pos = root.Position
        data.Coordinates = string.format("%d, %d, %d", pos.X, pos.Y, pos.Z)
        local myRoot = LocalPlayer.Character and findRootPart(LocalPlayer.Character)
        if myRoot then
            data.Distance = string.format("%.0f м", (pos - myRoot.Position).Magnitude / 3.571)
        else
            data.Distance = NO_INFO
        end
        local velocity = root.AssemblyLinearVelocity
        local horizontal = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
        data.Velocity = string.format("%.1f", velocity.Magnitude)
        local movement
        if velocity.Y > 4 then
            movement = "В воздухе"
        elseif velocity.Y < -4 then
            movement = "Падает"
        elseif horizontal < 0.5 then
            movement = "Стоит"
        elseif horizontal < 16 then
            movement = "Идёт"
        else
            movement = "Бежит"
        end
        data.Movement = movement
    else
        data.Coordinates = NO_INFO
        data.Distance = NO_INFO
        data.Velocity = NO_INFO
        data.Movement = NO_INFO
    end
    api.SetInfo(data)
end
function PlayerList.Start()
    if PlayerList.Started then
        return
    end
    PlayerList.Started = true
    TaskManager.AddConnection("PlayerList", RunService.Heartbeat, function(deltaTime)
        PlayerList.Timer = (PlayerList.Timer or 0) - (deltaTime or 1 / 60)
        if PlayerList.Timer <= 0 then
            PlayerList.Timer = 0.25
            pcall(PlayerList.Apply)
        end
    end)
end
function PlayerList.Shutdown()
    TaskManager.RemoveConnection("PlayerList")
    PlayerList.Started = false
end
PlayerList.Start()
if Library then
    Library.UnloadHooks = Library.UnloadHooks or {}
    table.insert(Library.UnloadHooks, PlayerList.Shutdown)
end

-----------------------------------------------------------------------
--- Movement: Fly, Speedhack, Click teleport, Infinite jump,
--- Jump power, Gravity, Walk on platform
-----------------------------------------------------------------------
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

function Movement.Update(deltaTime)
    local char = LocalPlayer.Character
    if not char or not Entity.IsAlive(LocalPlayer) then
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

    local cam = Workspace.CurrentCamera

    -- 1. Fly (BodyGyro + BodyVelocity + Noclip loop)
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

            hum.PlatformStand = true
        end

        -- Noclip
        for _, child in ipairs(char:GetDescendants()) do
            if child:IsA("BasePart") and child.CanCollide then
                child.CanCollide = false
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
                hum.PlatformStand = false
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            end
            for _, child in ipairs(char:GetDescendants()) do
                if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
                    child.CanCollide = true
                end
            end
            pcall(function()
                cam.CameraType = Enum.CameraType.Custom
                if hum and hum.Parent then
                    cam.CameraSubject = hum
                end
            end)
        end
    end

    -- 2. Speedhack
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

    -- 3. Jump power
    local jumpPowerEnabled = bindOn(flag("MovementJumpPower", false) == true, "MovementJumpPowerBind")
    if jumpPowerEnabled then
        local power = math.clamp(tonumber(flag("MovementJumpPowerValue", 50)) or 50, 0, 1000)
        hum.UseJumpPower = true
        hum.JumpPower = power
        hum.JumpHeight = power * 0.144
        Movement.JumpPowerApplied = true
    elseif Movement.JumpPowerApplied then
        hum.JumpPower = 50
        hum.JumpHeight = 7.2
        Movement.JumpPowerApplied = false
    end

    -- 4. Gravity
    local gravityEnabled = bindOn(flag("MovementGravity", false) == true, "MovementGravityBind")
    if gravityEnabled then
        local grav = math.clamp(tonumber(flag("MovementGravityValue", 196)) or 196, 0, 1000)
        Workspace.Gravity = grav
        Movement.GravityApplied = true
    elseif Movement.GravityApplied then
        Workspace.Gravity = 196.2
        Movement.GravityApplied = false
    end

    -- 5. Walk on (Platform)
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
                p.Parent = Workspace
                Movement.Platform = p
                Movement.LockedY = root.Position.Y - (hum.HipHeight or 2) - 1.2
            end

            -- Высота фиксируется строго на одном уровне, чтобы платформа не вела игрока
            if Movement.LockedY == nil then
                Movement.LockedY = root.Position.Y - (hum.HipHeight or 2) - 1.2
            end

            -- Смещаем платформу только когда игрок отходит от центра больше чем на 4 стада,
            -- при этом высота Y остается неизменной, исключая эффект конвейера
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

    -- Infinite jump
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

    -- Click TP
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
    Workspace.Gravity = 196.2
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.JumpPower = 50
            hum.JumpHeight = 7.2
        end
        for _, child in ipairs(LocalPlayer.Character:GetDescendants()) do
            if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
                child.CanCollide = true
            end
        end
    end
    Movement.Started = false
end
Movement.Start()

-----------------------------------------------------------------------
--- Misc: FPS unlocker, Removals, Anti-fling, Hide name
-----------------------------------------------------------------------
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

return {
    Library = Library,
    Window = Library and Library.Window,
    Tabs = Library and (Library.Tabs or {
        Visuals = Library.TabsByName and Library.TabsByName["lighting"],
        Aiming = Library.TabsByName and Library.TabsByName["aiming"],
        Settings = Library.TabsByName and Library.TabsByName["settings"]
    }),
    Entity = Entity,
    Chams = Chams,
    Targeting = Targeting,
    VisualUtils = VisualUtils,
    TaskManager = TaskManager,
    World = World,
    Effects = Effects,
    ESP = ESP,
    PlayerList = PlayerList,
    BacktrackChams = BacktrackChams,
    Movement = Movement,
    Misc = Misc,
}
