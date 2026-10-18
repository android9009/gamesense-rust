local ESP = {}
do
    local ESP_UPDATE_HZ = 45
    local ESP_UPDATE_INTERVAL = 1 / ESP_UPDATE_HZ
    local updateAccumulator = 0
    local elapsedSinceUpdate = 0
    local MAX_TARGETS = 14
    local LINE_HEIGHT = 14
    local BAR_GAP = 3 -- отступ полосок от бокса
    local BAR_THICKNESS_MAX = 4 -- толщина полосок вблизи
    local BAR_THICKNESS_MIN = 2 -- толщина полосок вдали
    local FONT = 0

    local HealthGui = nil
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

    -- ESP-подсистема вынесена в отдельную функцию, чтобы не раздувать
    -- регистровый пул BacktrackChams.Start() (лимит Luau 200 локальных).
    local function defineESP()
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

    -- Drawing API writes can cross an executor/native boundary. Only send changes.
    local function cachedDrawing(native)
        local values = {}
        local widthText, widthSize, widthFont, widthBounds
        return setmetatable({}, {
            __index = function(_, property)
                if property == "Remove" then
                    return function() native:Remove() end
                end
                if property == "TextBounds" then
                    if widthBounds == nil or widthText ~= values.Text
                        or widthSize ~= values.Size or widthFont ~= values.Font then
                        widthBounds = native.TextBounds
                        widthText, widthSize, widthFont = values.Text, values.Size, values.Font
                    end
                    return widthBounds
                end
                local value = values[property]
                if value ~= nil then return value end
                return native[property]
            end,
            __newindex = function(_, property, value)
                if values[property] == value then return end
                native[property] = value
                values[property] = value
            end,
        })
    end

    local function newDrawing(entry, key, kind)
        entry.UsedDrawings[key] = entry.Frame
        local existing = entry.Drawings[key]
        if existing then
            return existing
        end
        local object = cachedDrawing(Drawing.new(kind))
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
        return math.clamp((box.ReferenceHeight or box.Height) * 0.03, BAR_THICKNESS_MIN, BAR_THICKNESS_MAX)
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
        if entry.HealthUI then entry.HealthUI.Root.Visible = false end
        for _, object in pairs(entry.Drawings) do
            if object.Visible then
                object.Visible = false
            end
        end
    end

    local function finishEntry(entry)
        for key, object in pairs(entry.Drawings) do
            if entry.UsedDrawings[key] ~= entry.Frame and object.Visible then
                object.Visible = false
            end
        end
        if entry.HealthUI and entry.HealthFrame ~= entry.Frame then
            entry.HealthUI.Root.Visible = false
        end
    end

    local function clearEntry(entry)
        if entry.BodyConnections then
            for _, connection in ipairs(entry.BodyConnections) do connection:Disconnect() end
            entry.BodyConnections = nil
        end
        if entry.HealthUI then
            entry.HealthUI.Root:Destroy()
            entry.HealthUI = nil
        end
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

    local function getScreenBox(model, entry)
        local camera = Workspace.CurrentCamera
        if not camera then
            return nil
        end
        local rootPart = findRootPart(model)
        if not rootPart then
            return nil
        end
        -- Body-only bounds: held tools/accessories must not inflate the ESP.
        local minimum, maximum = math.huge, -math.huge
        if entry.BodyModel ~= model then
            if entry.BodyConnections then
                for _, connection in ipairs(entry.BodyConnections) do connection:Disconnect() end
            end
            entry.BodyModel, entry.BodyParts, entry.BodyDirty = model, {}, true
            local function changed(child)
                if child:IsA("BasePart") then entry.BodyDirty = true end
            end
            entry.BodyConnections = {
                model.ChildAdded:Connect(changed), model.ChildRemoved:Connect(changed),
            }
        end
        if entry.BodyDirty then
            table.clear(entry.BodyParts)
            for _, part in ipairs(model:GetChildren()) do
                if part:IsA("BasePart") then entry.BodyParts[#entry.BodyParts + 1] = part end
            end
            entry.BodyDirty = false
        end
        for _, part in ipairs(entry.BodyParts) do
            if part.Parent == model then
                local cf, half = part.CFrame, part.Size * 0.5
                local extentY = math.abs(cf.RightVector.Y) * half.X
                    + math.abs(cf.UpVector.Y) * half.Y
                    + math.abs(cf.LookVector.Y) * half.Z
                minimum = math.min(minimum, part.Position.Y - extentY)
                maximum = math.max(maximum, part.Position.Y + extentY)
            end
        end
        local height = minimum < maximum and (maximum - minimum) or 6
        local centerY = minimum < maximum and (minimum + maximum) * 0.5 or rootPart.Position.Y
        local centerWorld = Vector3.new(rootPart.Position.X, centerY, rootPart.Position.Z)
        local center = camera:WorldToViewportPoint(centerWorld)
        if center.Z <= 0.1 then return nil end
        -- Project a camera-facing vertical span with Roblox's actual projection.
        -- This also supports non-vertical FieldOfViewMode and wide viewports.
        local halfSpan = camera.CFrame.UpVector * (height * 0.5 + 0.1)
        local topPoint = camera:WorldToViewportPoint(centerWorld + halfSpan)
        local bottomPoint = camera:WorldToViewportPoint(centerWorld - halfSpan)
        local boxHeight = math.max(math.abs(bottomPoint.Y - topPoint.Y), 2)
        local boxWidth = math.max(boxHeight * BOX_WIDTH_RATIO, 2)
        local viewport = camera.ViewportSize
        if center.X + boxWidth * 0.5 < 0 or center.X - boxWidth * 0.5 > viewport.X
            or center.Y + boxHeight * 0.5 < 0 or center.Y - boxHeight * 0.5 > viewport.Y then
            return nil
        end
        -- Decoration scale uses a fixed reference FOV, not the zoomed box height.
        local referenceHeight = (height + 0.2) / math.max(center.Z, 0.1)
            * viewport.Y / (2 * math.tan(math.rad(70) * 0.5))
        local left = center.X - boxWidth * 0.5
        return {
            Left = left,
            Top = center.Y - boxHeight * 0.5,
            Right = left + boxWidth,
            Bottom = center.Y + boxHeight * 0.5,
            CenterX = center.X,
            Width = boxWidth,
            Height = boxHeight,
            ReferenceHeight = referenceHeight,
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
        local radius = barThickness(box) / 2
        local vertical = side == "Left" or side == "Right"
        -- Extend to the outside edge of the ESP box stroke.
        local start = (vertical and box.Top or box.Left) - 1
        local finish = (vertical and box.Bottom or box.Right) + 1
        local length = finish - start
        local cross = vertical and (side == "Left" and box.Left - shift or box.Right + shift)
            or (side == "Top" and box.Top - shift or box.Bottom + shift)
        -- Native UIGradient: one continuous surface, no Drawing slice boundaries.
        if not HealthGui then
            HealthGui = Instance.new("ScreenGui")
            HealthGui.Name = "GamesenseHealthBars"
            HealthGui.IgnoreGuiInset = true
            HealthGui.ResetOnSpawn = false
            HealthGui.DisplayOrder = 100
            HealthGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            local parent = LocalPlayer:WaitForChild("PlayerGui")
            if gethui then
                local ok, hidden = pcall(gethui)
                if ok and hidden then parent = hidden end
            end
            HealthGui.Parent = parent
        end
        if not entry.HealthUI then
            local root = Instance.new("Frame")
            root.Name = "Health"
            root.BorderSizePixel = 0
            root.BackgroundColor3 = Color3.new(0, 0, 0)
            root.ClipsDescendants = true
            root.Parent = HealthGui
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 2)
            corner.Parent = root
            local clip = Instance.new("Frame")
            clip.BackgroundTransparency = 1
            clip.BorderSizePixel = 0
            clip.ClipsDescendants = true
            clip.Parent = root
            local fill = Instance.new("Frame")
            fill.BorderSizePixel = 0
            fill.Parent = clip
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0, 2)
            fillCorner.Parent = fill
            local gradient = Instance.new("UIGradient")
            gradient.Parent = fill
            entry.HealthUI = {Root = root, Clip = clip, Fill = fill, Gradient = gradient}
        end
        local ui = entry.HealthUI
        entry.HealthFrame = entry.Frame
        local width = vertical and radius * 2 or length
        local height = vertical and length or radius * 2
        ui.Root.Position = UDim2.fromOffset(vertical and (cross - radius) or start,
            vertical and start or (cross - radius))
        ui.Root.Size = UDim2.fromOffset(width, height)
        ui.Root.Visible = true
        ui.Clip.Position = UDim2.fromOffset(0, vertical and height * (1 - ratio) or 0)
        ui.Clip.Size = UDim2.fromOffset(vertical and width or width * ratio,
            vertical and height * ratio or height)
        -- Keep the gradient aligned to the full HP scale when health decreases.
        ui.Fill.Position = UDim2.fromOffset(0, vertical and -height * (1 - ratio) or 0)
        ui.Fill.Size = UDim2.fromOffset(width, height)
        local fillColor = useGradient and Color3.new(1, 1, 1) or color
        if ui.LastFillColor ~= fillColor then
            ui.Fill.BackgroundColor3, ui.LastFillColor = fillColor, fillColor
        end
        if ui.LastGradient ~= useGradient then
            ui.Gradient.Enabled, ui.LastGradient = useGradient, useGradient
        end
        if ui.LastVertical ~= vertical then
            ui.Gradient.Rotation = vertical and 90 or 0
            ui.LastVertical = vertical
        end
        if ui.LastColor ~= color or ui.LastColorTo ~= colorTo then
            ui.Gradient.Color = ColorSequence.new(color, colorTo)
            ui.LastColor, ui.LastColorTo = color, colorTo
        end
        local lo = vertical and (finish - length * ratio) or start
        local hi = vertical and finish or (start + length * ratio)
        if showText and textValue then
            local text = newDrawing(entry, key .. "Text", "Text")
            text.Size = 13
            text.Center = not vertical
            text.Color = Color3.new(1, 1, 1)
            text.Text = tostring(textValue)
            if vertical then
                text.Position = Vector2.new(side == "Left" and (cross - radius - textWidth(text) - 2)
                    or (cross + radius + 2), lo - 6)
            else
                text.Position = Vector2.new(hi, cross - radius - 16)
            end
            text.Visible = true
        end
    end

    -- тексты: группировка по слоту, вертикальный стек внутри слота, порядок как в превью.
    -- С дистанцией (бокс мельчает) тексты сжимаются: мельче шрифт и плотнее строки
    local function textOrderLess(a, b) return a.Order < b.Order end
    local function drawTexts(entry, box, pending, barPush)
        local scale = math.clamp((box.ReferenceHeight or box.Height) / 260, 0.7, 1)
        local lineHeight = (LINE_HEIGHT + 2) * scale
        local fontSize = math.clamp(math.floor(15 * scale + 0.5), 11, 15)
        -- мелкий флаг (оружие): ~75% обычного размера, строку не сжимаем —
        -- текст центрируем внутри своей строки, вокруг остаётся свободное место
        local smallSize = math.clamp(math.floor(fontSize * 0.8 + 0.5), 9, 12)
        local groups = entry.TextGroups
        for _, items in pairs(groups) do table.clear(items) end
        for _, item in ipairs(pending) do
            local id = item.Slot
            groups[id] = groups[id] or {}
            table.insert(groups[id], item)
        end
        for id, items in pairs(groups) do
            if #items == 0 then continue end
            table.sort(items, textOrderLess)
            local side = sideOf(id)
            local part = partOf(id, side)
            local push = barPush[side] or 0
            if side == "Top" or side == "Bottom" then
                -- Keep the whole stack outside the box and the health bar.
                local total = #items * (lineHeight + 1) - 1
                local y = side == "Top" and (box.Top - BAR_GAP - push - total)
                    or (box.Bottom + BAR_GAP + push)
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
                        text.Position = Vector2.new(box.Left - BAR_GAP - push - textWidth(text), y + nudge)
                    else
                        text.Position = Vector2.new(box.Right + BAR_GAP + push, y + nudge)
                    end
                    text.Visible = true
                    y += lineHeight + 1
                end
            end
        end
    end

    local function updateEntry(entry, box, enabled, myRoot)
        entry.Frame = (entry.Frame or 0) + 1
        local character = entryCharacter(entry)
        local humanoid = entryHumanoid(entry)
        local player = entry.Player

        if enabled.Box then
            drawBox(entry, box)
        end

        local pending = entry.Pending
        if not pending then pending = {}; entry.Pending = pending end
        table.clear(pending)

        if enabled.Name then
            local item = entry.TextItems.Name
            if not item then item = {}; entry.TextItems.Name = item end
            item.Key = "Name"
            item.Text = entryName(entry)
            item.Slot = slotOf("Name")
            item.Order = 1
            item.Color = espColor("ESPNameColor", Color3.fromRGB(235, 235, 235))
            pending[#pending + 1] = item
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
            local item = entry.TextItems.Distance
            if not item then item = {}; entry.TextItems.Distance = item end
            item.Key = "Distance"
            item.Text = text
            item.Slot = slotOf("Distance")
            item.Order = 2
            item.Color = espColor("ESPDistanceColor", Color3.fromRGB(235, 235, 235))
            pending[#pending + 1] = item
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
            local item = entry.TextItems.Ping
            if not item then item = {}; entry.TextItems.Ping = item end
            item.Key = "Ping"
            item.Text = ms .. "ms"
            item.Slot = slotOf("Ping")
            item.Order = 3
            item.Color = color
            pending[#pending + 1] = item
        end

        local tool = character and character:FindFirstChildOfClass("Tool")
        if enabled.Item and tool and flag("ESPItemText", true) == true then
            local item = entry.TextItems.Item
            if not item then item = {}; entry.TextItems.Item = item end
            item.Key = "Item"
            item.Text = tool.Name
            item.Slot = slotOf("Item")
            item.Order = 4
            item.Small = true
            item.Color = espColor("ESPItemTextColor", Color3.fromRGB(190, 190, 190))
            pending[#pending + 1] = item
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
                local item = entry.TextItems.Hit
                if not item then item = {}; entry.TextItems.Hit = item end
                item.Key = "Hit"
                item.Text = "Hit"
                item.Slot = slotOf("Hit")
                item.Order = 1
                item.Color = Color3.fromRGB(214, 79, 79)
                pending[#pending + 1] = item
            end
        end

        -- полоски: глубина по стороне как в превью (LayoutBars)
        local thickness = barThickness(box)
        local depthBySide = entry.BarDepth
        table.clear(depthBySide)
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

        -- Match preview LayoutBars: reserve space on the occupied side.
        local barPush = entry.BarPush
        table.clear(barPush)
        for side, count in pairs(depthBySide) do
            barPush[side] = 5 + count * (thickness + 2)
        end
        drawTexts(entry, box, pending, barPush)
        finishEntry(entry)
    end

    local targetBuffer, activeBuffer = {}, {}
    local targetRecords = setmetatable({}, {__mode = "k"})
    local function targetRecord(key, isPlayer)
        local record = targetRecords[key]
        if not record then
            record = isPlayer and {Player = key} or {Model = key}
            targetRecords[key] = record
        end
        return record
    end
    local function targetLess(a, b) return a.Distance < b.Distance end

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
        local targets = targetBuffer
        table.clear(targets)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and Entity.IsAlive(player) then
                targets[#targets + 1] = targetRecord(player, true)
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
                targets[#targets + 1] = targetRecord(model, false)
            end
        end

        for _, target in ipairs(targets) do
            target.Distance = myRoot and entryDistance(target, myRoot) or math.huge
        end
        table.sort(targets, targetLess)

        local active = activeBuffer
        table.clear(active)
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
                    UsedDrawings = {},
                    TextItems = {},
                    TextGroups = {},
                    BarDepth = {},
                    BarPush = {},
                    Frame = 0,
                }
                Cache[key] = entry
            end
            local character = entryCharacter(entry)
            local box = character and getScreenBox(character, entry)
            if box then
                updateEntry(entry, box, enabled, myRoot)
            else
                hideEntry(entry)
            end
        end
    end

    -- любой пад внутри кадра всплывает нотификацией, а не молча
    local function apply(deltaTime)
        local dt = math.max(deltaTime or 0, 0)
        updateAccumulator += dt
        elapsedSinceUpdate += dt
        if updateAccumulator + 1e-9 < ESP_UPDATE_INTERVAL then return end
        -- Keep fractional phase, but never run catch-up batches after a slow frame.
        local periods = math.floor((updateAccumulator + 1e-9) / ESP_UPDATE_INTERVAL)
        updateAccumulator = math.max(0, updateAccumulator - periods * ESP_UPDATE_INTERVAL)
        local elapsed = elapsedSinceUpdate
        elapsedSinceUpdate = 0
        -- Pass actual elapsed time so NPC scan timers do not slow down at 45 Hz.
        local ok, err = pcall(runApply, elapsed)
        if not ok then
            for _, entry in pairs(Cache) do hideEntry(entry) end
            notifyOnce("error", "ESP error: " .. tostring(err))
        end
    end

    function ESP.Shutdown()
        updateAccumulator, elapsedSinceUpdate = 0, 0
        TaskManager.RemoveConnection("ESPApply")
        TaskManager.RemoveConnection("ESPPlayers")
        for _, entry in pairs(Cache) do
            clearEntry(entry)
        end
        table.clear(Cache)
        table.clear(targetBuffer)
        table.clear(activeBuffer)
        table.clear(targetRecords)
        if HealthGui then
            HealthGui:Destroy()
            HealthGui = nil
        end
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
        updateAccumulator = ESP_UPDATE_INTERVAL -- first render updates immediately
        elapsedSinceUpdate = 0
        TaskManager.AddConnection("ESPApply", RunService.RenderStepped, apply)
        TaskManager.AddConnection("ESPPlayers", Players.PlayerRemoving, function(player)
            targetRecords[player] = nil
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
            UpdateLimitHz = ESP_UPDATE_HZ,
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
    defineESP()
end
ESP.Start()
ChamsRuntime.Start()
LocalTransparency.Start()

----------------------------------------------------------------------
-- Player list (Skins -> Players): панель информации о выбранном игроке.
-- Ресурсы читаются тем же ридером, что и для ESP; если данных нет —
-- в панели пишем "нет информации" (в ESP строка просто не рисуется)
----------------------------------------------------------------------
