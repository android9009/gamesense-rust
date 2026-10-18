do
    local BIAS = 0.01
    local MASK_ALPHA = 0.9999999
    local MAX_PARTS = 16
    Chams.LayerCache = {}

    local function destroyLayer(model)
        local layer = Chams.LayerCache[model]
        if not layer then return end
        if layer.Highlight then layer.Highlight:Destroy() end
        layer.Model:Destroy()
        Chams.LayerCache[model] = nil
    end
    Chams.RemoveLayer = destroyLayer
    function Chams.ClearLayers()
        for model in pairs(Chams.LayerCache) do destroyLayer(model) end
        if Chams.LayerFolder then Chams.LayerFolder:Destroy(); Chams.LayerFolder = nil end
    end
    local function ensureFolder()
        if not Chams.LayerFolder or not Chams.LayerFolder.Parent then
            local folder = Instance.new("Folder")
            folder.Name = "GS_ChamsLayers"
            folder.Parent = Workspace
            Chams.LayerFolder = folder
        end
        return Chams.LayerFolder
    end
    local function copyPart(source, parent)
        local original = source.Archivable
        source.Archivable = true
        local ok, copy = pcall(source.Clone, source)
        source.Archivable = original
        if not ok or not copy then return nil end
        for _, child in ipairs(copy:GetDescendants()) do
            if not child:IsA("DataModelMesh") then child:Destroy() end
        end
        copy.Name = source.Name
        copy.Anchored = true
        copy.CanCollide, copy.CanTouch, copy.CanQuery = false, false, false
        copy.CastShadow = false
        copy.Material = Enum.Material.Glass
        copy.Transparency, copy.LocalTransparencyModifier = 1, 0
        copy.Reflectance = 0
        if copy:IsA("MeshPart") then
            -- A nonempty texture avoids the untextured glass specular path.
            copy.TextureID = "rbxasset://textures/white.dds"
        end
        copy.Parent = parent
        return copy
    end
    local function reconcile(layer, sourceModel, now)
        if now < layer.NextParts then return end
        layer.NextParts = now + 0.25
        local wanted, count = {}, 0
        for _, source in ipairs(Entity.GetParts(sourceModel)) do
            if count >= MAX_PARTS then break end
            if source.Parent == sourceModel and source.Name ~= "HumanoidRootPart"
                and source.Transparency < 0.99 then
                wanted[source] = true
                local pair = layer.Parts[source]
                if not pair then
                    local copy = copyPart(source, layer.Model)
                    if copy then
                        pair = {Copy = copy, Mesh = copy:FindFirstChildOfClass("SpecialMesh"),
                            SourceMesh = source:FindFirstChildOfClass("SpecialMesh")}
                        layer.Parts[source] = pair
                    end
                end
                if pair then count += 1 end
            end
        end
        for source, pair in pairs(layer.Parts) do
            if not wanted[source] then pair.Copy:Destroy(); layer.Parts[source] = nil end
        end
    end
    local function ensureLayer(model)
        local layer = Chams.LayerCache[model]
        if not layer then
            local proxy = Instance.new("Model")
            proxy.Name = "GS_VisibleMask"
            proxy.Parent = ensureFolder()
            local highlight = Instance.new("Highlight")
            highlight.Name = "GS_VisibleLayer"
            layer = {Model = proxy, Highlight = highlight, Parts = {}, NextParts = 0}
            Chams.LayerCache[model] = layer
        end
        return layer
    end
    function Chams.ApplyLayers(model, visibleOptions, wallOptions, camera)
        if not wallOptions then
            destroyLayer(model)
            if visibleOptions then
                visibleOptions.AlwaysOnTop = false
                return Chams.CreateModel(model, visibleOptions)
            end
            Chams.RemoveModel(model)
            return nil
        end
        wallOptions.AlwaysOnTop = true
        local back = Chams.CreateModel(model, wallOptions)
        local layer = ensureLayer(model)
        reconcile(layer, model, os.clock())
        local cameraPosition = camera.CFrame.Position
        local root = findRootPart(model)
        local distance = root and (root.Position - cameraPosition).Magnitude or 10
        local factor = 1 - math.min(BIAS / math.max(distance, 0.1), 0.001)
        for source, pair in pairs(layer.Parts) do
            local copy = pair.Copy
            if source.Parent == model and copy.Parent then
                local shift = (cameraPosition - source.Position) * (1 - factor)
                local size = source.Size * factor
                if copy.Size ~= size then copy.Size = size end
                copy.CFrame = source.CFrame + shift
                if pair.Mesh and pair.SourceMesh and pair.SourceMesh.Parent then
                    local scale = pair.SourceMesh.Scale * factor
                    if pair.Mesh.Scale ~= scale then pair.Mesh.Scale = scale end
                end
            else
                copy:Destroy()
                layer.Parts[source] = nil
                layer.NextParts = 0
            end
        end
        if visibleOptions then
            if visibleOptions.FillTransparency >= 1 and visibleOptions.OutlineTransparency >= 1 then
                visibleOptions.OutlineTransparency = MASK_ALPHA
            end
            configureHighlight(layer.Highlight, layer.Model, visibleOptions, false, layer.Model)
        else
            -- Keep an almost invisible Occluded mask, rather than disabling it:
            -- the foreground Highlight must still participate in compositing.
            configureHighlight(layer.Highlight, layer.Model, {
                FillTransparency = 1, OutlineTransparency = MASK_ALPHA,
                FillColor = wallOptions.FillColor, OutlineColor = wallOptions.FillColor, Enabled = true,
            }, false, layer.Model)
        end
        return back
    end
end
