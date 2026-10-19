-- ============================================================================
-- ItemGiver: выдача предметов и правка их атрибутов для таба Giver.
--
-- Как работает выдача: шаблоны тулзов ищутся в ReplicatedStorage/StarterPack
-- (там игры на Blaster обычно и держат оружие/инструменты). Найденный шаблон
-- клонируется в Backpack. Если шаблона нет - пробуем игровые RemoteEvent с
-- именами про give/purchase/buy (pcall, что нашлось). Мега-кирка/топор: клон
-- базового инструмента с разогнанными атрибутами под фарм (как 200x у других).
--
-- Apply пишет атрибуты во ВСЕ копии предмета (Backpack/Character/StarterGear
-- + сам шаблон, чтобы следующие выдачи были сразу с настройками), Reset
-- возвращает оригиналы, записанные перед первой правкой.
-- ============================================================================

ItemGiver = {
    Templates = {},
    Originals = {},
    Mega = {["Mega Pickaxe"] = "pickaxe", ["Mega Axe"] = "axe"},
    LastScan = -1,
    FieldKeys = {"damage", "minDamage", "spread", "range", "rateOfFire", "magazineSize", "raysPerShot", "rayRadius"},
}

local function scanTools(root, into)
    if not root then
        return
    end
    for _, inst in ipairs(root:GetDescendants()) do
        if inst:IsA("Tool") and not into[inst.Name] then
            into[inst.Name] = inst
        end
    end
end

function ItemGiver.Scan()
    local templates = {}
    pcall(function()
        scanTools(game:GetService("ReplicatedStorage"), templates)
    end)
    pcall(function()
        scanTools(game:GetService("StarterPack"), templates)
    end)
    ItemGiver.Templates = templates
    local names = {"Mega Pickaxe", "Mega Axe"}
    for name in pairs(templates) do
        names[#names + 1] = name
    end
    local char = LocalPlayer and LocalPlayer.Character
    for _, holder in ipairs({LocalPlayer and LocalPlayer:FindFirstChildOfClass("Backpack"), char}) do
        if holder then
            for _, inst in ipairs(holder:GetChildren()) do
                if inst:IsA("Tool") then
                    names[#names + 1] = inst.Name
                end
            end
        end
    end
    if Library and Library.GiverBridge and Library.GiverBridge.SetItems then
        pcall(function()
            Library.GiverBridge.SetItems(names)
        end)
    end
    return names
end

local function findCopies(name)
    local copies = {}
    local holders = {}
    local backpack = LocalPlayer and LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        holders[#holders + 1] = backpack
    end
    if LocalPlayer and LocalPlayer.Character then
        holders[#holders + 1] = LocalPlayer.Character
    end
    pcall(function()
        local starterGear = LocalPlayer and LocalPlayer:FindFirstChild("StarterGear")
        if starterGear then
            holders[#holders + 1] = starterGear
        end
    end)
    for _, holder in ipairs(holders) do
        for _, inst in ipairs(holder:GetChildren()) do
            if inst:IsA("Tool") and inst.Name == name then
                copies[#copies + 1] = inst
            end
        end
    end
    local template = ItemGiver.Templates[name]
    if template then
        copies[#copies + 1] = template
    end
    return copies
end

local function baseTemplate(kind)
    local patterns = kind == "pickaxe" and {"pickaxe", "кирк"} or {"axe", "топор"}
    local found = nil
    for name, inst in pairs(ItemGiver.Templates) do
        local lower = name:lower()
        for _, pat in ipairs(patterns) do
            if lower:find(pat, 1, true) then
                found = inst
                break
            end
        end
        if found then
            break
        end
    end
    return found
end

function ItemGiver.Describe(name)
    local source = nil
    if ItemGiver.Mega[name] then
        source = baseTemplate(ItemGiver.Mega[name])
    else
        local copies = findCopies(name)
        source = copies[1]
    end
    local attrs = {}
    if source then
        for _, key in ipairs(ItemGiver.FieldKeys) do
            local value = source:GetAttribute(key)
            if value ~= nil then
                attrs[key] = value
            end
        end
    end
    return attrs
end

local function recordOriginals(inst)
    if ItemGiver.Originals[inst] then
        return
    end
    local saved = {}
    for _, key in ipairs(ItemGiver.FieldKeys) do
        local value = inst:GetAttribute(key)
        saved[key] = value == nil and false or value
    end
    ItemGiver.Originals[inst] = saved
end

function ItemGiver.Apply(name, fields)
    local count = 0
    for _, inst in ipairs(findCopies(name)) do
        recordOriginals(inst)
        for key, value in pairs(fields) do
            -- Пишем только туда, где атрибут реально есть: мусор не плодим.
            if inst:GetAttribute(key) ~= nil then
                inst:SetAttribute(key, value)
                count = count + 1
            end
        end
    end
    return count
end

function ItemGiver.Reset(name)
    local count = 0
    for inst, saved in pairs(ItemGiver.Originals) do
        if inst and inst.Name == name then
            for key, value in pairs(saved) do
                pcall(function()
                    if value == false then
                        inst:SetAttribute(key, nil)
                    else
                        inst:SetAttribute(key, value)
                    end
                end)
                count = count + 1
            end
            ItemGiver.Originals[inst] = nil
        end
    end
    return count
end

local function giveClone(template)
    local backpack = LocalPlayer and LocalPlayer:FindFirstChildOfClass("Backpack")
    if not (template and backpack) then
        return false
    end
    local clone = template:Clone()
    clone.Parent = backpack
    return true
end

local function tryGiveRemotes(name)
    local attempted = false
    pcall(function()
        for _, inst in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if inst:IsA("RemoteEvent") then
                local lower = inst.Name:lower()
                if lower:find("give", 1, true) or lower:find("purchase", 1, true) or lower:find("buy", 1, true) then
                    attempted = true
                    pcall(function()
                        inst:FireServer(name)
                    end)
                end
            end
        end
    end)
    return attempted
end

function ItemGiver.Give(name)
    if ItemGiver.Mega[name] then
        local base = baseTemplate(ItemGiver.Mega[name])
        if not base then
            return false, "base tool not found (no axe/pickaxe template in storage)"
        end
        local backpack = LocalPlayer and LocalPlayer:FindFirstChildOfClass("Backpack")
        if not backpack then
            return false, "no backpack"
        end
        local clone = base:Clone()
        -- Мега-фарм: урон x200, темп на максимум, если атрибуты есть.
        local dmg = tonumber(clone:GetAttribute("damage")) or 10
        clone:SetAttribute("damage", math.max(dmg * 200, 2000))
        if clone:GetAttribute("rateOfFire") ~= nil then
            clone:SetAttribute("rateOfFire", 2500)
        end
        clone:SetAttribute("_mega", true)
        clone.Parent = backpack
        return true, name .. " given (200x farm)"
    end
    local template = ItemGiver.Templates[name]
    if template then
        if giveClone(template) then
            return true, name .. " given"
        end
        return false, "clone failed"
    end
    if tryGiveRemotes(name) then
        return true, "no template, give remotes fired for " .. name
    end
    return false, "template not found in storage: " .. name
end

function ItemGiver.Start()
    ItemGiver.Scan()
    TaskManager.AddConnection("ItemGiverRescan", RunService.Heartbeat, function()
        local now = os.clock()
        if now - ItemGiver.LastScan >= 5 then
            ItemGiver.LastScan = now
            pcall(function()
                ItemGiver.Scan()
            end)
        end
    end)
end
