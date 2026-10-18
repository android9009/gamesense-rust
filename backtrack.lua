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

    -- Пока цель сдвинута в позицию чамса (reposition), пишем снимок РЕАЛЬНЫХ
    -- позиций (сделан до сдвига), а не сдвинутую — иначе история забивается
    -- "поддельным" местом и чамс/прицел замирают на одном тике.
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

-- CS:GO-стиль: сканируем окно истории и выбираем кадр, чья позиция реально
-- видима с камеры (не за стеной) — такой кадр можно пробить пулей. Берём самый
-- свежий видимый кадр в окне (wanted..now), чтобы прицел/чамс шли за целью и не
-- застревали на одном тике. Невидимые (застенные) кадры пропускаем: в них всё
-- равно не попасть, поэтому если видимых в окне нет — возвращаем nil (цель не
-- стреляем, чтобы не тратить выстрелы в невалидные позиции).
-- Кадр для ОТРИСОВКИ чамса и ПРИЦЕЛА: всегда возвращает кадр (ближайший к нужной
-- задержке, иначе самый свежий). Чамс рисуется, а аимбот целится прямо в его
-- позицию — простая схема без репозиции и фильтров видимости.
local function btDisplayFrame(history, wanted)
    if not history or #history == 0 then
        return nil
    end
    local best = history[1]
    local bestDiff = math.abs(history[1].Time - wanted)
    for i = 2, #history do
        local diff = math.abs(history[i].Time - wanted)
        if diff < bestDiff then
            bestDiff = diff
            best = history[i]
        end
    end
    return best
end

-- Хитбоксы ЧАМСА из исторического кадра: голова/грудь/живот/корень — чтобы аим
-- мог реагировать на все хитбоксы призрака, а не только на центр тела.
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
        -- вернуть тела, если бектрек выключен посреди репозиции
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
            -- единый кадр: и отрисовка чамса, и прицел — на позицию призрака
            local displayFrame = btDisplayFrame(history, wanted)

            -- аимбот целится прямо в позицию чамса
            if displayFrame and displayFrame.RootPos then
                BacktrackAim[targetKey] = displayFrame.RootPos
                BacktrackAimCache[targetKey] = {Character = character, Pos = displayFrame.RootPos}
                BacktrackAimByChar[character] = displayFrame.RootPos
                BacktrackAimHitboxes[character] = btGetChamHitboxes(character, displayFrame)
            end

            -- отрисовка чамса (всегда, на displayFrame)
            if displayFrame then
                -- Логика прозрачности при совпадении с текущим персонажем:
                -- Когда цель стоит на месте (дистанция 0 studs) — призрак полностью прозрачный (невидим),
                -- чтобы не создавать двойное наслоение поверх основного тела.
                -- Когда цель двигается — на дистанции 3.2+ studs призрак становится полностью непрозрачным.
                local BT_PROXIMITY_DIST = 3.2 -- studs
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

    -- чистка BacktrackAim: если цель больше не имеет призрака (не в списке currentTargets),
    -- убираем её из умного бектрека, чтобы аимбот не целился в устаревшую позицию.
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

-- // ESP — реальная отрисовка по флагам секции "Preview ESP"
-- Вкл/выкл: ESPBox, ESPHealth, ESPName, ESPDistance, ESPPing, ESPItem, ESPHit (ресурсы в ЕСП удалены; readResources остался для плеер-листа)
-- Слоты:   ESP<Element>Slot (TopLeft..BottomRight / LeftTop..RightBottom) — читаются live,
--          так что перетаскивание чипов в превью сразу двигает реальный ESP
-- Настройки: ESPBoxStyle/Color, ESPHealth*, ESPNameColor, ESPDistance*, ESPPing*, ESPItem*
