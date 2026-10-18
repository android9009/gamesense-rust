local ESP = {}
do
    local function initializeESP()
    local TextService = game:GetService("TextService")
    local HZ, LIMIT = 60, 14
    local INTERVAL = 1 / HZ
    local WHITE, BLACK = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
    local GREEN, RED = Color3.fromRGB(88, 214, 74), Color3.fromRGB(214, 79, 79)
    local DEFAULTS = {Health = "LeftMiddle", Name = "TopCenter", Distance = "BottomCenter", Ping = "BottomCenter", Item = "BottomCenter", Hit = "RightTop"}
    local ORDER = {Name = 1, Distance = 2, Ping = 3, Item = 4, Hit = 1}
    local NAMES = {"Name", "Distance", "Ping", "Item", "Hit"}
    local cache, targets, active = {}, {}, {}
    local gui, running, registered = nil, false, false
    local phase, rosterTimer = 0, 0
    local calls, totalTime, maxTime, rendered, lastError = 0, 0, 0, 0, nil
    local config = {}

    local function set(object, property, value)
        if object[property] ~= value then object[property] = value end
    end
    local function create(class, parent, props)
        local object = Instance.new(class)
        for property, value in pairs(props or {}) do object[property] = value end
        object.Parent = parent
        return object
    end
    local function frame(parent, name)
        return create("Frame", parent, {Name = name, BorderSizePixel = 0, BackgroundTransparency = 1})
    end
    local function color(name, fallback)
        local value = Library.Flags[name]
        if type(value) == "table" and typeof(value.Color) == "Color3" then
            return value.Color, math.clamp(tonumber(value.Transparency) or 0, 0, 1)
        end
        return typeof(value) == "Color3" and value or fallback, 0
    end
    local function slot(name)
        local id = flag("ESP" .. name .. "Slot", DEFAULTS[name])
        return type(id) == "string" and id or DEFAULTS[name]
    end
    local function sideOf(id)
        return id:match("^Left") and "Left" or id:match("^Right") and "Right"
            or id:match("^Bottom") and "Bottom" or "Top"
    end
    local function refreshConfig()
        local any = false
        for _, name in ipairs({"Box", "Health", "Name", "Distance", "Ping", "Item", "Hit"}) do
            config[name] = flag("ESP" .. name, false) == true
            any = any or config[name]
        end
        config.BoxColor, config.BoxAlpha = color("ESPBoxColor", WHITE)
        config.BoxStyle = flag("ESPBoxStyle", "Full")
        config.HealthColor = color("ESPHealthColor", GREEN)
        config.HealthColorTo = color("ESPHealthColorTo", RED)
        config.HealthGradient = flag("ESPHealthGradient", false) == true
        config.HealthText = flag("ESPHealthText", false) == true
        config.HealthSlot = slot("Health")
        config.ItemText = flag("ESPItemText", true) == true
        config.Unit = flag("ESPDistanceUnit", "Meters")
        config.PingChecker = flag("ESPPingChecker", false) == true
        return any
    end
    local function ensureGui()
        if gui then return end
        local parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if gethui then
            local ok, value = pcall(gethui)
            if ok and value then parent = value end
        end
        assert(parent, "ESP: GUI parent unavailable")
        gui = create("ScreenGui", parent, {
            Name = "GS_ESP", IgnoreGuiInset = true, ResetOnSpawn = false,
            DisplayOrder = 100, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        })
    end
    local function destroyEntry(model)
        local entry = cache[model]
        if not entry then return end
        entry.Root:Destroy()
        cache[model] = nil
    end
    local function getEntry(model, player)
        local entry = cache[model]
        if not entry then
            ensureGui()
            entry = {Model = model, Player = player, Labels = {}, Groups = {}, ShapeAt = 0,
                Height = 6, OffsetY = 0, HitAt = 0, PingAt = 0, PingMs = 0}
            entry.Root = frame(gui, "Target")
            entry.Root.Visible = false
            cache[model] = entry
        end
        return entry
    end
    local function label(parent, name)
        return create("TextLabel", parent, {
            Name = name, BackgroundTransparency = 1, BorderSizePixel = 0,
            Font = Enum.Font.SourceSans, TextSize = 15, TextColor3 = WHITE,
            TextStrokeColor3 = BLACK, TextStrokeTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
            Visible = false, ZIndex = 5,
        })
    end
    local function setText(object, text, size)
        local changed = object.Text ~= text or object.TextSize ~= size
        set(object, "Text", text)
        set(object, "TextSize", size)
        return changed
    end
    local function updateShape(entry, root, now)
        if now < entry.ShapeAt then return end
        entry.ShapeAt = now + 0.5
        local minimum, maximum = math.huge, -math.huge
        for _, part in ipairs(Entity.GetParts(entry.Model)) do
            if part.Parent == entry.Model then
                local cf, half = part.CFrame, Entity.GetVisualSize(part) * 0.5
                local extent = math.abs(cf.RightVector.Y) * half.X
                    + math.abs(cf.UpVector.Y) * half.Y + math.abs(cf.LookVector.Y) * half.Z
                minimum = math.min(minimum, part.Position.Y - extent)
                maximum = math.max(maximum, part.Position.Y + extent)
            end
        end
        if minimum < maximum then
            entry.Height = maximum - minimum + 0.2
            entry.OffsetY = (minimum + maximum) * 0.5 - root.Position.Y
        end
    end
    local function project(entry, root, camera, now)
        local centerWorld = root.Position + Vector3.new(0, entry.OffsetY, 0)
        local center = camera:WorldToViewportPoint(centerWorld)
        if center.Z <= 0.1 then return nil end
        updateShape(entry, root, now)
        centerWorld = root.Position + Vector3.new(0, entry.OffsetY, 0)
        center = camera:WorldToViewportPoint(centerWorld)
        local span = camera.CFrame.UpVector * (entry.Height * 0.5)
        local top = camera:WorldToViewportPoint(centerWorld + span)
        local bottom = camera:WorldToViewportPoint(centerWorld - span)
        local height = math.max(math.abs(bottom.Y - top.Y), 2)
        local width = math.max(height * 0.65, 2)
        local x, y = center.X - width * 0.5, center.Y - height * 0.5
        local viewport = camera.ViewportSize
        if x > viewport.X or x + width < 0 or y > viewport.Y or y + height < 0 then return nil end
        local reference = entry.Height / center.Z * viewport.Y / (2 * math.tan(math.rad(35)))
        return x, y, width, height, reference
    end
    local function ensureBox(entry)
        if entry.Box then return end
        local box = frame(entry.Root, "Box")
        box.Size = UDim2.fromScale(1, 1)
        local full = frame(box, "Full")
        full.Size = UDim2.fromScale(1, 1)
        local outline = create("UIStroke", full, {Color = BLACK, Thickness = 4})
        local inner = frame(full, "Color")
        inner.Size = UDim2.fromScale(1, 1)
        local stroke = create("UIStroke", inner, {Thickness = 2})
        local corners = frame(box, "Corners")
        corners.Size = UDim2.fromScale(1, 1)
        local pieces = {}
        for _, anchor in ipairs({Vector2.new(0, 0), Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(1, 1)}) do
            for _, horizontal in ipairs({true, false}) do
                local black = frame(corners, "Outline")
                black.AnchorPoint, black.Position = anchor, UDim2.fromScale(anchor.X, anchor.Y)
                black.BackgroundColor3, black.BackgroundTransparency = BLACK, 0
                local line = frame(black, "Line")
                line.AnchorPoint = Vector2.new(0.5, 0.5)
                line.Position = UDim2.fromScale(0.5, 0.5)
                line.BackgroundTransparency = 0
                pieces[#pieces + 1] = {Back = black, Line = line, Horizontal = horizontal}
            end
        end
        entry.Box = {Root = box, Full = full, Stroke = stroke, Outline = outline, Corners = corners, Pieces = pieces}
    end
    local function drawBox(entry, width, height)
        if not config.Box then
            if entry.Box then set(entry.Box.Root, "Visible", false) end
            return
        end
        ensureBox(entry)
        local box = entry.Box
        set(box.Root, "Visible", true)
        local corner = config.BoxStyle == "Corner"
        set(box.Full, "Visible", not corner)
        set(box.Corners, "Visible", corner)
        set(box.Stroke, "Color", config.BoxColor)
        set(box.Stroke, "Transparency", math.min(config.BoxAlpha, 0.9))
        if corner then
            for _, piece in ipairs(box.Pieces) do
                local w = piece.Horizontal and math.max(width * 0.2, 5) or 4
                local h = piece.Horizontal and 4 or math.max(height * 0.2, 5)
                set(piece.Back, "Size", UDim2.fromOffset(w, h))
                set(piece.Line, "Size", UDim2.fromOffset(piece.Horizontal and w or 2, piece.Horizontal and 2 or h))
                set(piece.Line, "BackgroundColor3", config.BoxColor)
                set(piece.Line, "BackgroundTransparency", math.min(config.BoxAlpha, 0.9))
            end
        end
    end
    local function ensureHealth(entry)
        if entry.Health then return end
        local root = frame(entry.Root, "Health")
        root.BackgroundColor3, root.BackgroundTransparency = BLACK, 0
        root.ClipsDescendants = true
        create("UICorner", root, {CornerRadius = UDim.new(0, 2)})
        local clip = frame(root, "Clip")
        clip.ClipsDescendants = true
        local fill = frame(clip, "Fill")
        fill.BackgroundTransparency = 0
        create("UICorner", fill, {CornerRadius = UDim.new(0, 2)})
        local gradient = create("UIGradient", fill)
        local text = label(entry.Root, "HealthValue")
        text.ZIndex = 6
        entry.Health = {Root = root, Clip = clip, Fill = fill, Gradient = gradient, Text = text}
    end
    local function drawHealth(entry, humanoid, width, height, thickness)
        if not config.Health then
            if entry.Health then set(entry.Health.Root, "Visible", false); set(entry.Health.Text, "Visible", false) end
            return nil, 0
        end
        ensureHealth(entry)
        local hp = entry.Health
        local side = sideOf(config.HealthSlot)
        local vertical = side == "Left" or side == "Right"
        local ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 0.01), 0, 1)
        local length = (vertical and height or width) + 2
        local w, h = vertical and thickness or length, vertical and length or thickness
        local x = side == "Left" and (-3 - thickness * 0.5) or side == "Right" and (width + 3 - thickness * 0.5) or -1
        local y = side == "Top" and (-3 - thickness * 0.5) or side == "Bottom" and (height + 3 - thickness * 0.5) or -1
        set(hp.Root, "Position", UDim2.fromOffset(x, y))
        set(hp.Root, "Size", UDim2.fromOffset(w, h))
        set(hp.Root, "Visible", true)
        set(hp.Clip, "Position", UDim2.fromOffset(0, vertical and h * (1 - ratio) or 0))
        set(hp.Clip, "Size", UDim2.fromOffset(vertical and w or w * ratio, vertical and h * ratio or h))
        set(hp.Fill, "Position", UDim2.fromOffset(0, vertical and -h * (1 - ratio) or 0))
        set(hp.Fill, "Size", UDim2.fromOffset(w, h))
        set(hp.Fill, "BackgroundColor3", config.HealthGradient and WHITE or config.HealthColor)
        set(hp.Gradient, "Enabled", config.HealthGradient)
        set(hp.Gradient, "Rotation", vertical and 90 or 0)
        if hp.Color ~= config.HealthColor or hp.ColorTo ~= config.HealthColorTo then
            hp.Gradient.Color = ColorSequence.new(config.HealthColor, config.HealthColorTo)
            hp.Color, hp.ColorTo = config.HealthColor, config.HealthColorTo
        end
        set(hp.Text, "Visible", config.HealthText)
        if config.HealthText then
            setText(hp.Text, tostring(math.floor(humanoid.Health + 0.5)), 13)
            set(hp.Text, "Size", UDim2.fromOffset(40, 16))
            set(hp.Text, "TextXAlignment", vertical and (side == "Left" and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left) or Enum.TextXAlignment.Center)
            local tx = vertical and (side == "Left" and x - 42 or x + w + 2) or x + w * ratio - 20
            local ty = vertical and y + h * (1 - ratio) - 6 or y - 16
            set(hp.Text, "Position", UDim2.fromOffset(tx, ty))
        end
        return side, 5 + thickness + 2
    end
    local function addText(entry, name, text, tint, alpha, size)
        local item = entry.Labels[name]
        if not item then
            item = {Object = label(entry.Root, name), Name = name, Order = ORDER[name]}
            entry.Labels[name] = item
        end
        item.Used = true
        if setText(item.Object, text, size) or not item.Width then
            item.Width = math.ceil(TextService:GetTextSize(text, size, item.Object.Font, Vector2.new(10000, 1000)).X) + 2
        end
        set(item.Object, "TextColor3", tint)
        set(item.Object, "TextTransparency", alpha or 0)
        set(item.Object, "TextStrokeTransparency", alpha or 0)
        set(item.Object, "Visible", true)
        local id = slot(name)
        local group = entry.Groups[id]
        if not group then group = {}; entry.Groups[id] = group end
        group[#group + 1] = item
    end
    local function textLess(a, b) return a.Order < b.Order end
    local function hittable(camera, model)
        for _, part in ipairs(getChamsParts(model)) do
            if not partIsOccluded(camera, part, model) then return true end
        end
        return false
    end
    local function drawTexts(entry, root, humanoid, camera, myRoot, width, height, reference, hpSide, hpPush, now)
        for _, item in pairs(entry.Labels) do item.Used = false end
        for _, group in pairs(entry.Groups) do table.clear(group) end
        local scale = math.clamp(reference / 260, 0.7, 1)
        local size = math.clamp(math.floor(15 * scale + 0.5), 11, 15)
        local lineHeight = 16 * scale + 1
        local player, model = entry.Player, entry.Model
        if config.Name then
            local tint, alpha = color("ESPNameColor", Color3.fromRGB(235, 235, 235))
            addText(entry, "Name", player and (player.DisplayName ~= "" and player.DisplayName or player.Name) or model.Name, tint, alpha, size)
        end
        if config.Distance and myRoot then
            local studs = (root.Position - myRoot.Position).Magnitude
            local text = config.Unit == "Studs" and (math.floor(studs) .. " studs")
                or config.Unit == "Feet" and (math.floor(studs / 3.571 * 3.281) .. "ft")
                or (math.floor(studs / 3.571) .. "m")
            local tint, alpha = color("ESPDistanceColor", Color3.fromRGB(235, 235, 235))
            addText(entry, "Distance", text, tint, alpha, size)
        end
        if config.Ping and player then
            if now >= entry.PingAt then
                entry.PingAt = now + 0.25
                local ok, ping = pcall(player.GetNetworkPing, player)
                entry.PingMs = ok and math.floor((ping or 0) * 1000) or 0
            end
            local tint, alpha = color("ESPPingColor", Color3.fromRGB(235, 235, 235))
            if config.PingChecker then tint = entry.PingMs <= 50 and GREEN or entry.PingMs <= 120 and Color3.fromRGB(230, 200, 80) or RED end
            addText(entry, "Ping", entry.PingMs .. "ms", tint, alpha, size)
        end
        if config.Item and config.ItemText then
            local tool = model:FindFirstChildOfClass("Tool")
            if tool then
                local tint, alpha = color("ESPItemTextColor", Color3.fromRGB(190, 190, 190))
                addText(entry, "Item", tool.Name, tint, alpha, math.clamp(math.floor(size * 0.8 + 0.5), 9, 12))
            end
        end
        if config.Hit then
            if now >= entry.HitAt then entry.HitAt = now + 0.1; entry.Hittable = hittable(camera, model) end
            if entry.Hittable then addText(entry, "Hit", "Hit", RED, 0, size) end
        end
        for _, item in pairs(entry.Labels) do
            if not item.Used then set(item.Object, "Visible", false) end
        end
        for id, group in pairs(entry.Groups) do
            if #group == 0 then continue end
            table.sort(group, textLess)
            local side = sideOf(id)
            local part = id:sub(#side + 1)
            local push = side == hpSide and hpPush or 0
            local stackHeight = #group * lineHeight - 1
            local y = side == "Top" and (-3 - push - stackHeight)
                or side == "Bottom" and (height + 3 + push)
                or part == "Bottom" and (height - stackHeight)
                or part == "Middle" and ((height - stackHeight) * 0.5) or 0
            for _, item in ipairs(group) do
                local x
                if side == "Left" then x = -3 - push - item.Width
                elseif side == "Right" then x = width + 3 + push
                elseif part == "Left" then x = 0
                elseif part == "Right" then x = width - item.Width
                else x = (width - item.Width) * 0.5 end
                set(item.Object, "Size", UDim2.fromOffset(item.Width, 20))
                set(item.Object, "Position", UDim2.fromOffset(x, y + (size - item.Object.TextSize) * 0.5))
                y += lineHeight
            end
        end
    end
    local function refreshTargets(now)
        if now < rosterTimer then return end
        rosterTimer = now + 0.25
        table.clear(targets)
        table.clear(active)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                targets[#targets + 1] = {Model = player.Character, Player = player}
                active[player.Character] = true
            end
        end
        for _, model in ipairs(Entity.GetNPCs()) do
            targets[#targets + 1] = {Model = model}
            active[model] = true
        end
        for model in pairs(cache) do
            if not active[model] then destroyEntry(model) end
        end
    end
    local function targetLess(a, b) return a.Distance < b.Distance end
    local function update()
        if not refreshConfig() then
            if gui then set(gui, "Enabled", false) end
            rendered = 0
            return
        end
        local camera = Workspace.CurrentCamera
        if not camera then if gui then set(gui, "Enabled", false) end; return end
        ensureGui()
        set(gui, "Enabled", true)
        local now = os.clock()
        refreshTargets(now)
        local myRoot = Entity.GetRootPart(LocalPlayer)
        local origin = myRoot and myRoot.Position or camera.CFrame.Position
        for _, target in ipairs(targets) do
            local root = target.Model.Parent and findRootPart(target.Model)
            target.Distance = root and (root.Position - origin).Magnitude or math.huge
        end
        table.sort(targets, targetLess)
        for _, entry in pairs(cache) do entry.Rendered = false end
        rendered = 0
        for _, target in ipairs(targets) do
            if rendered >= LIMIT then break end
            local model = target.Model
            if target.Player and target.Player.Character ~= model then continue end
            local humanoid = model.Parent and model:FindFirstChildOfClass("Humanoid")
            local root = humanoid and humanoid.Health > 0 and findRootPart(model)
            if not root then continue end
            if camera:WorldToViewportPoint(root.Position).Z <= 0.1 then continue end
            local entry = getEntry(model, target.Player)
            local x, y, width, height, reference = project(entry, root, camera, now)
            if not x then continue end
            entry.Rendered = true
            rendered += 1
            set(entry.Root, "Position", UDim2.fromOffset(x, y))
            set(entry.Root, "Size", UDim2.fromOffset(width, height))
            set(entry.Root, "Visible", true)
            drawBox(entry, width, height)
            local hpSide, hpPush = drawHealth(entry, humanoid, width, height, math.clamp(reference * 0.03, 2, 4))
            drawTexts(entry, root, humanoid, camera, myRoot, width, height, reference, hpSide, hpPush, now)
        end
        for _, entry in pairs(cache) do if not entry.Rendered then set(entry.Root, "Visible", false) end end
    end
    local function step(dt)
        phase += math.max(dt or 0, 0)
        if phase + 1e-9 < INTERVAL then return end
        local periods = math.floor((phase + 1e-9) / INTERVAL)
        phase = math.max(0, phase - periods * INTERVAL)
        local started = os.clock()
        local ok, err = pcall(update)
        local elapsed = os.clock() - started
        calls += 1; totalTime += elapsed; maxTime = math.max(maxTime, elapsed)
        if not ok then
            if gui then gui.Enabled = false end
            if lastError ~= tostring(err) then warn("[ESP] " .. tostring(err)); lastError = tostring(err) end
        end
    end
    local RESOURCE_PATTERNS = {
        Wood = {"wood", "дерев", "бревн"},
        Metal = {"metal", "метал"},
        Scrap = {"scrap", "скрап"},
    }
     
     
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
     
    ESP.ReadResources = readResources

    function ESP.Shutdown()
        TaskManager.RemoveConnection("ESPApply")
        TaskManager.RemoveConnection("ESPPlayers")
        if gui then gui:Destroy(); gui = nil end
        table.clear(cache); table.clear(targets); table.clear(active)
        running, phase, rosterTimer = false, 0, 0
        if getgenv and getgenv().GSESP == ESP then getgenv().GSESP = nil end
    end
    function ESP.Start()
        if running then return end
        running, phase, rosterTimer = true, INTERVAL, 0
        calls, totalTime, maxTime, lastError = 0, 0, 0, nil
        TaskManager.AddConnection("ESPApply", RunService.RenderStepped, step)
        TaskManager.AddConnection("ESPPlayers", Players.PlayerRemoving, function(player)
            for model, entry in pairs(cache) do if entry.Player == player then destroyEntry(model) end end
            rosterTimer = 0
        end)
        if not registered then table.insert(Library.UnloadHooks, ESP.Shutdown); registered = true end
        if getgenv then getgenv().GSESP = ESP end
    end
    function ESP.Profile(reset)
        local count = 0
        for _ in pairs(cache) do count += 1 end
        local result = {Renderer = "NativeGUI", Updates = calls, AverageMs = calls > 0 and totalTime * 1000 / calls or 0,
            MaxMs = maxTime * 1000, CachedTargets = count, RenderedTargets = rendered, LimitHz = HZ}
        print(string.format("[ESP Profile] NativeGUI avg=%.3fms max=%.3fms visible=%d cached=%d updates=%d",
            result.AverageMs, result.MaxMs, rendered, count, calls))
        if reset then calls, totalTime, maxTime = 0, 0, 0 end
        return result
    end
    function ESP.Debug() return ESP.Profile() end
    end
    initializeESP()
end
ESP.Start()
ChamsRuntime.Start()
LocalTransparency.Start()
