table.insert(Library.UnloadHooks, TaskManager.ClearAll)
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
    RageBot = RageBot,
    RecoilKiller = RecoilKiller,
    NoSpread = NoSpread,
    AirShot = AirShot,
    AntiAim = AntiAim,
    BacktrackChams = BacktrackChams,
    Movement = Movement,
    Misc = Misc,
}
