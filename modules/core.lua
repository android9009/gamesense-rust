local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Library = __GS_UI
assert(Library, "Gamesense: UI library missing")
Library.UnloadHooks = Library.UnloadHooks or {}
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
 
 
 
 
 
 
 
local function isCharacterLike(model)
    if not model:IsA("Model") then return false end
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    local hasHead = model:FindFirstChild("Head") ~= nil
    local hasTorso = model:FindFirstChild("UpperTorso") ~= nil or model:FindFirstChild("Torso") ~= nil
     
    local hasArms = model:FindFirstChild("LeftArm") ~= nil or model:FindFirstChild("RightArm") ~= nil
        or model:FindFirstChild("Left Arm") ~= nil or model:FindFirstChild("Right Arm") ~= nil
        or model:FindFirstChild("LeftUpperArm") ~= nil or model:FindFirstChild("RightUpperArm") ~= nil
    local hasLegs = model:FindFirstChild("LeftLeg") ~= nil or model:FindFirstChild("RightLeg") ~= nil
        or model:FindFirstChild("Left Leg") ~= nil or model:FindFirstChild("Right Leg") ~= nil
        or model:FindFirstChild("LeftUpperLeg") ~= nil or model:FindFirstChild("RightUpperLeg") ~= nil
    return hasHead and hasTorso and hasArms and hasLegs
end

do
    local candidates, npcs, structures = {}, {}, {}
    local connection, nextRefresh = nil, 0
    local partCache = {}
    local function added(object)
        local model
        if object:IsA("Humanoid") then model = object.Parent
        elseif object:IsA("Model") and object:FindFirstChildOfClass("Humanoid") then model = object end
        if model and model:IsA("Model") then
            candidates[model] = true
            nextRefresh = 0
        end
    end
    local function excluded(model)
        local parent = model
        while parent and parent ~= Workspace do
            if parent:IsA("Camera") or parent.Name:sub(1, 3) == "GS_" then return true end
            parent = parent.Parent
        end
        return false
    end
    local function refresh()
        if not connection then
            connection = Workspace.DescendantAdded:Connect(added)
            for _, object in ipairs(Workspace:GetDescendants()) do
                if object:IsA("Humanoid") then added(object) end
            end
        end
        local now = os.clock()
        if now < nextRefresh then return end
        nextRefresh = now + 0.25
        table.clear(npcs)
        table.clear(structures)
        local seen = {}
        for model in pairs(candidates) do
            local humanoid = model.Parent and model:FindFirstChildOfClass("Humanoid")
            if not humanoid or not model:IsDescendantOf(Workspace) then
                candidates[model] = nil
            elseif humanoid.Health > 0 and findRootPart(model)
                and not Players:GetPlayerFromCharacter(model) and not excluded(model) then
                if isCharacterLike(model) then
                    local nested, parent = false, model.Parent
                    while parent and parent ~= Workspace do
                        if parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then
                            nested = true; break
                        end
                        parent = parent.Parent
                    end
                    if not nested then npcs[#npcs + 1] = model end
                else
                    local top, parent = model, model.Parent
                    while parent and parent ~= Workspace do
                        if parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid")
                            and not Players:GetPlayerFromCharacter(parent) and not isCharacterLike(parent) then top = parent end
                        parent = parent.Parent
                    end
                    if not seen[top] then seen[top] = true; structures[#structures + 1] = top end
                end
            end
        end
        for model, entry in pairs(partCache) do
            if not model.Parent then
                for _, c in ipairs(entry.Connections) do c:Disconnect() end
                partCache[model] = nil
            end
        end
    end
    function Entity.GetNPCs() refresh(); return npcs end
    function Entity.GetStructures() refresh(); return structures end
    function Entity.GetParts(model)
        local entry = partCache[model]
        if not entry then
            entry = {Parts = {}, Dirty = true, Connections = {}}
            local function changed(object) if object:IsA("BasePart") then entry.Dirty = true end end
            entry.Connections = {model.DescendantAdded:Connect(changed), model.DescendantRemoving:Connect(changed)}
            entry.Connections[#entry.Connections + 1] = model.AncestryChanged:Connect(function()
                if not model:IsDescendantOf(Workspace) then
                    for _, c in ipairs(entry.Connections) do c:Disconnect() end
                    partCache[model] = nil
                end
            end)
            partCache[model] = entry
        end
        if entry.Dirty then
            table.clear(entry.Parts)
            for _, object in ipairs(model:GetDescendants()) do
                if object:IsA("BasePart") then entry.Parts[#entry.Parts + 1] = object end
            end
            entry.Dirty = false
        end
        return entry.Parts
    end
    function Entity.Shutdown()
        if connection then connection:Disconnect(); connection = nil end
        for _, entry in pairs(partCache) do for _, c in ipairs(entry.Connections) do c:Disconnect() end end
        table.clear(partCache); table.clear(candidates); table.clear(npcs); table.clear(structures)
        nextRefresh = 0
    end
    table.insert(Library.UnloadHooks, Entity.Shutdown)
end

 
function Entity.Classify(model)
    if not model or not model:IsA("Model") then return nil end
     
    local player = Players:GetPlayerFromCharacter(model)
    if player then
        if player == LocalPlayer then return nil end
        return Entity.IsEnemy(player) and "enemy" or "team"
    end
     
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
    ModelCache = {},
    ModelOcclusion = {},
    OcclusionCache = {},
    LocalHighlight = nil
}
local function configureHighlight(hl, target, options, alwaysOnTop, parent)
    options = options or {}
    local fill = options.FillColor or Color3.fromRGB(255, 50, 50)
    local alpha = options.FillTransparency ~= nil and options.FillTransparency or 0.5
    local outline = options.OutlineColor or fill
    local outlineAlpha = options.OutlineTransparency ~= nil and options.OutlineTransparency or 1
    local depth = alwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
    local enabled = options.Enabled ~= false
    if hl.Adornee ~= target then hl.Adornee = target end
    if hl.FillColor ~= fill then hl.FillColor = fill end
    if hl.FillTransparency ~= alpha then hl.FillTransparency = alpha end
    if hl.OutlineColor ~= outline then hl.OutlineColor = outline end
    if hl.OutlineTransparency ~= outlineAlpha then hl.OutlineTransparency = outlineAlpha end
    if hl.DepthMode ~= depth then hl.DepthMode = depth end
    if hl.Enabled ~= enabled then hl.Enabled = enabled end
    if hl.Parent ~= (parent or target) then hl.Parent = parent or target end
end
function Chams.CreateModel(target, options)
    local hl = Chams.ModelCache[target]
    if not hl or not hl.Parent then
        hl = Instance.new("Highlight")
        hl.Name = "GS_ChamsModel"
        Chams.ModelCache[target] = hl
    end
    configureHighlight(hl, target, options, options.AlwaysOnTop == true, Workspace)
    return hl
end
function Chams.RemoveModel(target)
    if Chams.RemoveLayer then Chams.RemoveLayer(target) end
    local hl = Chams.ModelCache[target]
    if hl then hl:Destroy(); Chams.ModelCache[target] = nil end
    Chams.ModelOcclusion[target] = nil
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
    Chams.RemoveModel(model)
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
    if Chams.ClearLayers then Chams.ClearLayers() end
    for model in pairs(Chams.ModelCache) do Chams.RemoveModel(model) end
    table.clear(Chams.ModelOcclusion)
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
    return TaskManager.Connections[id]
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
