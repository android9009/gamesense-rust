local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Library = __GS_UI
assert(Library, "Gamesense: UI library missing")
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
-- похожа ли модель на живого персонажа (бот/NPC), а не на структуру
-- (турель, шкаф, спальник и т.п.): настоящий персонаж имеет HumanoidRootPart
-- либо верхний торс/торс И голову. Структуры такого набора частей не имеют.
-- похожа ли модель на полноценного живого персонажа (бот/NPC), а не на
-- структуру (турель, шкаф, сундук, спальник и т.п.). Персонаж обязан иметь
-- полный скелет: HumanoidRootPart + голова + торс + конечности (руки и ноги).
-- Структуры (даже с HumanoidRootPart/Head) полного набора частей не имеют.
local function isCharacterLike(model)
    if not model:IsA("Model") then return false end
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    local hasHead = model:FindFirstChild("Head") ~= nil
    local hasTorso = model:FindFirstChild("UpperTorso") ~= nil or model:FindFirstChild("Torso") ~= nil
    -- конечности: руки + ноги (R15: LeftArm/RightArm, LeftLeg/RightLeg; R6: "Left Arm"/"Right Arm", "Left Leg"/"Right Leg")
    local hasArms = model:FindFirstChild("LeftArm") ~= nil or model:FindFirstChild("RightArm") ~= nil
        or model:FindFirstChild("Left Arm") ~= nil or model:FindFirstChild("Right Arm") ~= nil
    local hasLegs = model:FindFirstChild("LeftLeg") ~= nil or model:FindFirstChild("RightLeg") ~= nil
        or model:FindFirstChild("Left Leg") ~= nil or model:FindFirstChild("Right Leg") ~= nil
    return hasHead and hasTorso and hasArms and hasLegs
end

function Entity.GetNPCs()
    local result = {}
    local nested = {}
    for _, object in ipairs(Workspace:GetDescendants()) do
        if object:IsA("Model") and not Players:GetPlayerFromCharacter(object) then
            local humanoid = object:FindFirstChildOfClass("Humanoid")
            local root = findRootPart(object)
            if humanoid and humanoid.Health > 0 and root and isCharacterLike(object) then
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

-- Структуры: модели с HP (Humanoid) и корнем, но НЕ персонажи и НЕ игроки
-- (турели, шкафы, сундуки, спальники и т.п.).
function Entity.GetStructures()
    local result = {}
    local seen = {}
    for _, object in ipairs(Workspace:GetDescendants()) do
        if object:IsA("Model") and not Players:GetPlayerFromCharacter(object)
            and not isCharacterLike(object) then
            local humanoid = object:FindFirstChildOfClass("Humanoid")
            local root = findRootPart(object)
            if humanoid and humanoid.Health > 0 and root then
                -- берём верхнюю структуру (уникальную), чтобы не дублировать вложенные части
                local top = object
                local parent = object.Parent
                while parent do
                    if parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid")
                        and not Players:GetPlayerFromCharacter(parent)
                        and not isCharacterLike(parent) then
                        top = parent
                    end
                    parent = parent.Parent
                end
                if not seen[top] then
                    seen[top] = true
                    result[#result + 1] = top
                end
            end
        end
    end
    return result
end

-- Классификация живого/целевого объекта: "enemy"/"team"/"bot"/"structure"/nil
function Entity.Classify(model)
    if not model or not model:IsA("Model") then return nil end
    -- игрок
    local player = Players:GetPlayerFromCharacter(model)
    if player then
        if player == LocalPlayer then return nil end
        return Entity.IsEnemy(player) and "enemy" or "team"
    end
    -- не-игрок с HP и корнем
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local root = findRootPart(model)
    if not (humanoid and humanoid.Health > 0 and root) then return nil end
    if isCharacterLike(model) then return "bot" end
    return "structure"
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

local function flag(name, default)
    local v = Library and Library.Flags and Library.Flags[name]
    if v == nil then return default end
    if type(v) == "table" and v.Color then return v.Color end
    return v
end

-- \u043f\u0440\u043e\u0437\u0440\u0430\u0447\u043d\u043e\u0441\u0442\u044c \u043a\u043e\u043b\u043e\u0440\u043f\u0438\u043a\u0435\u0440\u0430 (0 = \u0446\u0432\u0435\u0442 \u0434\u0435\u0439\u0441\u0442\u0432\u0443\u0435\u0442 \u043f\u043e\u043b\u043d\u043e\u0441\u0442\u044c\u044e, 1 = \u044d\u0444\u0444\u0435\u043a\u0442 \u0432\u044b\u043a\u043b\u044e\u0447\u0435\u043d)
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
