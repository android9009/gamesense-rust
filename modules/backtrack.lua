local BacktrackChams = {
    Started = false,
    History = {},    
    Ghosts = {},     
    MaxSeconds = 1.5,
    Folder = nil
}
local BT_STEP = "GS_BacktrackChams"

local function btActive()
    if flag("VisBacktrack", false) ~= true then
        return false, 0
    end
     
    local rageAimbot = flag("AimbotEnabled", false) == true
    local rageBacktrack = flag("AimbotBacktrack", false) == true
    if rageAimbot and rageBacktrack then
        local ms = tonumber(flag("AimbotBacktrackMs", 200)) or 200
        return true, math.clamp(ms, 0, 1200)
    end
     
    local legitAimbot = bindOn(flag("LegitAimbotEnabled", false) == true, "LegitAimbotBind")
    local legitBacktrack = flag("OtherBacktrack", false) == true
    if legitAimbot and legitBacktrack then
        local ms = tonumber(flag("OtherBacktrackTime", 200)) or 200
        return true, math.clamp(ms, 0, 1200)
    end
     
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

         
        local byName = {}
        for _, ghostPart in ipairs(ghost:GetDescendants()) do
            if ghostPart:IsA("BasePart") then
                local bucket = byName[ghostPart.Name]
                if not bucket then bucket = {}; byName[ghostPart.Name] = bucket end
                bucket[#bucket + 1] = ghostPart
            end
        end
        for _, charPart in ipairs(Entity.GetParts(character)) do
            if not charPart:FindFirstAncestorOfClass("Tool") then
                local bucket = byName[charPart.Name]
                local ghostPart = bucket and table.remove(bucket)
                if ghostPart then
                    partPairs[#partPairs + 1] = {Source = charPart, Ghost = ghostPart}
                    if charPart == rootSource then rootGhost = ghostPart end
                end
            end
        end
    else
         
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

     
     
     
    local saved = ghostData.Target and ReposActive[ghostData.Target]
    if saved and saved.OldCFrames then
        for _, pair in ipairs(ghostData.PartPairs) do
            local src = pair.Source
            local cf = saved.OldCFrames[src]
            if cf then
                frame.CFrames[src] = cf
                if src == ghostData.RootSource then
                    frame.RootPos = cf.Position
                end
            end
        end
        if not frame.RootPos and saved.OldCFrame then
            frame.RootPos = saved.OldCFrame.Position
            if ghostData.RootSource then
                frame.CFrames[ghostData.RootSource] = saved.OldCFrame
            end
        end
    else
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
    end

    history[#history + 1] = frame

    while history[1] and (now - history[1].Time) > BacktrackChams.MaxSeconds do
        table.remove(history, 1)
    end
end

 
 
 
 
 
 
 
 
 
local function btDisplayFrame(history, wanted)
    if not history or #history == 0 then return nil end
    local lo, hi = 1, #history
    while lo < hi do
        local mid = math.floor((lo + hi) * 0.5)
        if history[mid].Time < wanted then lo = mid + 1 else hi = mid end
    end
    local chosen = history[lo]
    if lo > 1 and math.abs(history[lo - 1].Time - wanted) <= math.abs(chosen.Time - wanted) then
        chosen = history[lo - 1]
    end
    return chosen
end

 
 
local function btGetChamHitboxes(character, displayFrame)
    local results = {}
    if not character then return results end
    local frame = displayFrame or {}
    local function posOf(partName)
        local p = character:FindFirstChild(partName)
        if p and p:IsA("BasePart") then
            local cf = frame.CFrames and frame.CFrames[p]
            if cf then return cf.Position end
            return p.Position
        end
        return nil
    end
    local head = posOf("Head")
    if head then results[#results + 1] = {Position = head, Name = "Head"} end
    local chest = posOf("UpperTorso") or posOf("Torso")
    if chest then results[#results + 1] = {Position = chest, Name = "Chest"} end
    local stomach = posOf("LowerTorso") or posOf("Torso")
    if stomach and chest and (stomach - chest).Magnitude > 0.5 then
        results[#results + 1] = {Position = stomach, Name = "Stomach"}
    end
    if #results == 0 and displayFrame and displayFrame.RootPos then
        results[#results + 1] = {Position = displayFrame.RootPos, Name = "Root"}
    end
    return results
end

local function btUpdate()
    local enabled, ms = btActive()
    if not enabled then
        if next(BacktrackChams.Ghosts) then
            btClearAll()
        end
        table.clear(BacktrackAim)
        table.clear(BacktrackAimCache)
        table.clear(BacktrackAimByChar)
        table.clear(BacktrackAimHitboxes)
         
        clearReposActive()
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

     
    table.sort(candidates, function(a, b)
        return a.Distance < b.Distance
    end)

    local currentTargets = {}
    local maxTargets = math.min(#candidates, MAX_CHAM_TARGETS)
    local MAX_BT_DISTANCE = 500  

    for i = 1, maxTargets do
        local candidate = candidates[i]
        if candidate.Distance <= MAX_BT_DISTANCE then
            currentTargets[candidate.Key] = candidate.Character
        end
    end

     
    for targetKey in pairs(BacktrackChams.Ghosts) do
        if not currentTargets[targetKey] then
            btDestroy(targetKey)
        end
    end

     
    for targetKey, character in pairs(currentTargets) do
        local ghostData = BacktrackChams.Ghosts[targetKey]
        if not ghostData or not ghostData.Model.Parent or ghostData.Target ~= character then
            btDestroy(targetKey)
            ghostData = btMakeGhost(targetKey, character)
        end

        if ghostData then
            btCapture(targetKey, ghostData, now)

            local history = BacktrackChams.History[targetKey]
             
            local displayFrame = btDisplayFrame(history, wanted)

             
            if displayFrame and displayFrame.RootPos then
                BacktrackAim[targetKey] = displayFrame.RootPos
                BacktrackAimCache[targetKey] = {Character = character, Pos = displayFrame.RootPos}
                BacktrackAimByChar[character] = displayFrame.RootPos
                BacktrackAimHitboxes[character] = btGetChamHitboxes(character, displayFrame)
            end

             
            if displayFrame then
                 
                 
                 
                 
                local BT_PROXIMITY_DIST = 3.2  
                local proximityAlpha = 0
                local currentPos = ghostData.RootSource and ghostData.RootSource.Parent and ghostData.RootSource.Position
                local historicalPos = displayFrame.RootPos

                if currentPos and historicalPos then
                    local distance = (currentPos - historicalPos).Magnitude
                    if distance < BT_PROXIMITY_DIST then
                        local factor = 1 - (distance / BT_PROXIMITY_DIST)
                        proximityAlpha = smoothstep(factor)
                    end
                else
                    proximityAlpha = 0
                end

                 
                local actualFillTrans = fillTrans + (1 - fillTrans) * proximityAlpha
                local actualOutlineTrans = outlineTrans + (1 - outlineTrans) * proximityAlpha
                local isVisible = actualFillTrans < 0.99 or actualOutlineTrans < 0.99

                 
                if ghostData.Highlight and ghostData.Highlight.Parent then
                    ghostData.Highlight.FillColor = col
                    ghostData.Highlight.FillTransparency = actualFillTrans
                    ghostData.Highlight.OutlineColor = col
                    ghostData.Highlight.OutlineTransparency = actualOutlineTrans
                    ghostData.Highlight.Enabled = isVisible
                end

                 
                for _, pair in ipairs(ghostData.PartPairs) do
                    local ghostPart = pair.Ghost
                    local cf = displayFrame.CFrames[pair.Source]
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

     
     
    for targetKey in pairs(BacktrackAimCache) do
        if not currentTargets[targetKey] then
            local cache = BacktrackAimCache[targetKey]
            if cache and cache.Character then
                BacktrackAimByChar[cache.Character] = nil
                BacktrackAimHitboxes[cache.Character] = nil
            end
            BacktrackAim[targetKey] = nil
            BacktrackAimCache[targetKey] = nil
        end
    end
end

function BacktrackChams.Shutdown()
    pcall(function() RunService:UnbindFromRenderStep(BT_STEP) end)
    TaskManager.RemoveConnection("BacktrackApply")
    clearReposActive()
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

 
 
 
 
 
