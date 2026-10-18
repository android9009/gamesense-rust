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
