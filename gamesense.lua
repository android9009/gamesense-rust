if getgenv().Loaded then
    if getgenv().Library and getgenv().Library.Unload then
        getgenv().Library:Unload()
    end
end
getgenv().Loaded = true
local Library

    local InputService, HttpService, GuiService, RunService, CoreGui, TweenService, Workspace, Players = game:GetService("UserInputService"), game:GetService("HttpService"), game:GetService("GuiService"), game:GetService("RunService"), game:GetService("CoreGui"), game:GetService("TweenService"), game:GetService("Workspace"), game:GetService("Players")
    local TextService = game:GetService("TextService")
    local Camera, lp, gui_offset = Workspace.CurrentCamera, Players.LocalPlayer, GuiService:GetGuiInset().Y
    local mouse = lp:GetMouse()
    local vec2, dim2, dim, dim_offset = Vector2.new, UDim2.new, UDim.new, UDim2.fromOffset
    local color, rgb, hex, hsv, rgbseq, rgbkey, numseq, numkey = Color3.new, Color3.fromRGB, Color3.fromHex, Color3.fromHSV, ColorSequence.new, ColorSequenceKeypoint.new, NumberSequence.new, NumberSequenceKeypoint.new
    Library = {
        Directory = "gamesense",
        Folders = {
            "/fonts",
            "/configs",
        },
        Flags = {},
        ConfigFlags = {},
        Connections = {},
        Notifications = {Notifs = {}},
        OpenElement = {};  
        EasingStyle = Enum.EasingStyle.Quint;
        TweeningSpeed = 0.25;
        AllDropdowns = {};
    }
    if getgenv then getgenv().Library = Library end

    local themes = {
        preset = {
            inline = rgb(50, 50, 50);
            gradient = rgb(40, 40, 40);
            outline = rgb(20, 20, 20);
            accent = rgb(142, 181, 39);
            background = rgb(30, 30, 30);
            text_color = rgb(239, 239, 239);
            text_outline = rgb(0, 0, 0);
            tab_background = rgb(26, 26, 26);
        },
        utility = {},
        gradients = {
            Selected = {};
            Deselected = {};
        },
    }
    for theme,color in themes.preset do
        themes.utility[theme] = {
            BackgroundColor3 = {};
            TextColor3 = {};
            ImageColor3 = {};
            ScrollBarImageColor3 = {};
            Color = {};
        }
    end
    local function PickerColorGlobal(color)
        return color
    end
    local Keys = {
        [Enum.KeyCode.Delete] = "DEL",
        [Enum.KeyCode.Insert] = "INS",
        [Enum.KeyCode.Home] = "HOME",
        [Enum.KeyCode.End] = "END",
        [Enum.KeyCode.PageUp] = "PGUP",
        [Enum.KeyCode.PageDown] = "PGDN",
        [Enum.KeyCode.Tab] = "TAB",
        [Enum.KeyCode.LeftShift] = "LS",
        [Enum.KeyCode.RightShift] = "RS",
        [Enum.KeyCode.LeftControl] = "LC",
        [Enum.KeyCode.RightControl] = "RC",
        [Enum.KeyCode.Backspace] = "BS",
        [Enum.KeyCode.Return] = "Ent",
        [Enum.KeyCode.LeftAlt] = "LA",
        [Enum.KeyCode.RightAlt] = "RA",
        [Enum.KeyCode.CapsLock] = "CAPS",
        [Enum.KeyCode.One] = "1",
        [Enum.KeyCode.Two] = "2",
        [Enum.KeyCode.Three] = "3",
        [Enum.KeyCode.Four] = "4",
        [Enum.KeyCode.Five] = "5",
        [Enum.KeyCode.Six] = "6",
        [Enum.KeyCode.Seven] = "7",
        [Enum.KeyCode.Eight] = "8",
        [Enum.KeyCode.Nine] = "9",
        [Enum.KeyCode.Zero] = "0",
        [Enum.KeyCode.KeypadOne] = "Num1",
        [Enum.KeyCode.KeypadTwo] = "Num2",
        [Enum.KeyCode.KeypadThree] = "Num3",
        [Enum.KeyCode.KeypadFour] = "Num4",
        [Enum.KeyCode.KeypadFive] = "Num5",
        [Enum.KeyCode.KeypadSix] = "Num6",
        [Enum.KeyCode.KeypadSeven] = "Num7",
        [Enum.KeyCode.KeypadEight] = "Num8",
        [Enum.KeyCode.KeypadNine] = "Num9",
        [Enum.KeyCode.KeypadZero] = "Num0",
        [Enum.KeyCode.Minus] = "-",
        [Enum.KeyCode.Equals] = "=",
        [Enum.KeyCode.Tilde] = "~",
        [Enum.KeyCode.LeftBracket] = "[",
        [Enum.KeyCode.RightBracket] = "]",
        [Enum.KeyCode.RightParenthesis] = ")",
        [Enum.KeyCode.LeftParenthesis] = "(",
        [Enum.KeyCode.Semicolon] = ",",
        [Enum.KeyCode.Quote] = "'",
        [Enum.KeyCode.BackSlash] = "\\",
        [Enum.KeyCode.Comma] = ",",
        [Enum.KeyCode.Period] = ".",
        [Enum.KeyCode.Slash] = "/",
        [Enum.KeyCode.Asterisk] = "*",
        [Enum.KeyCode.Plus] = "+",
        [Enum.KeyCode.Period] = ".",
        [Enum.KeyCode.Backquote] = "`",
        [Enum.UserInputType.MouseButton1] = "MB1",
        [Enum.UserInputType.MouseButton2] = "MB2",
        [Enum.UserInputType.MouseButton3] = "MB3",
        [Enum.KeyCode.Escape] = "ESC",
        [Enum.KeyCode.Space] = "SPC",
    }
    Library.__index = Library
    for _,path in Library.Folders do
        makefolder(Library.Directory .. path)
    end
    Library.ExtraClosers = {}
    Library.OpenHooks = {}
    Library.UnloadHooks = {}
    Library.DragLock = false
    Library.NoDrag = {}
    local Flags = Library.Flags
    local ConfigFlags = Library.ConfigFlags
    local Notifications = Library.Notifications
    local Fonts = {}; do
        function RegisterFont(Name, Weight, Style, Asset)
            if not isfile(Asset.Id) then
                writefile(Asset.Id, Asset.Font)
            end
            if isfile(Name .. ".font") then
                delfile(Name .. ".font")
            end
            local Data = {
                name = Name,
                faces = {
                    {
                        name = "Normal",
                        weight = Weight,
                        style = Style,
                        assetId = getcustomasset(Asset.Id),
                    },
                },
            }
            writefile(Name .. ".font", HttpService:JSONEncode(Data))
            return getcustomasset(Name .. ".font");
        end
        local Verdana = RegisterFont("Verawdawdawdwaddana", 400, "Normal", {
            Id = "Verdanawdawdwada.ttf",
            Font = game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/fs-tahoma-8px.ttf"),
        })
        Library.Font = Font.new(Verdana, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
    end
        local function RegisterUIElement(owner, kind, cfg)
            if not cfg then return cfg end
            local section = nil
            if owner then
                if owner.Items and owner.Items.Elements then
                    section = owner
                elseif owner.__section then
                    section = owner.__section
                end
            end
            cfg.__kind = kind
            cfg.__section = section
            cfg.__sectionName = section and section.Name or nil
            cfg.__tabName = section and section.Tab and section.Tab.RegistryName or nil
            Library.ElementRegistry = Library.ElementRegistry or {}
            table.insert(Library.ElementRegistry, cfg)
            return cfg
        end
        Library.RegisterUIElement = RegisterUIElement
        function Library:Tween(Object, Properties, Info)
            local tween = TweenService:Create(Object, Info or TweenInfo.new(Library.TweeningSpeed, Library.EasingStyle, Enum.EasingDirection.InOut, 0, false, 0), Properties)
            tween:Play()
            return tween
        end
        function Library:LayoutPath()
            return Library.Directory .. "/layout.json"
        end
        function Library:SaveLayout()
            local Window = Library.Window
            if not Window then
                return
            end
            local Data = {
                SizeX = Window.Size.X.Offset;
                SizeY = Window.Size.Y.Offset;
                PosX = Window.Position.X.Offset;
                PosY = Window.Position.Y.Offset;
            }
            pcall(function()
                writefile(Library:LayoutPath(), HttpService:JSONEncode(Data))
            end)
        end
        function Library:LoadLayout(Window)
            local Path = Library:LayoutPath()
            if not isfile(Path) then
                return
            end
            local Success, Data = pcall(function()
                return HttpService:JSONDecode(readfile(Path))
            end)
            if not Success or type(Data) ~= "table" then
                return
            end
            local Viewport = Camera.ViewportSize
            if tonumber(Data.SizeX) and tonumber(Data.SizeY) then
                Window.Size = dim2(
                    0, math.clamp(Data.SizeX, 400, Viewport.X),
                    0, math.clamp(Data.SizeY, 300, Viewport.Y)
                )
            end
            if tonumber(Data.PosX) and tonumber(Data.PosY) then
                Window.Position = dim2(
                    0, math.clamp(Data.PosX, 0, math.max(0, Viewport.X - Window.Size.X.Offset)),
                    0, math.clamp(Data.PosY, 0, math.max(0, Viewport.Y - Window.Size.Y.Offset))
                )
            end
        end
        function Library:Resizify(Parent)
            local Resizing = Library:Create("TextButton", {
                Position = dim2(1, -10, 1, -10);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(0, 10, 0, 10);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255);
                Parent = Parent;
                BackgroundTransparency = 1;
                Text = ""
            })
            local IsResizing = false
            local Size
            local InputLost
            local ParentSize = dim2(0, 400, 0, 300)  
            Resizing.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if Library.DragLock then
                        return
                    end
                    IsResizing = true
                    InputLost = input.Position
                    Size = Parent.Size
                end
            end)
            Resizing.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    IsResizing = false
                    Library:SaveLayout()
                end
            end)
            Library:Connection(InputService.InputChanged, function(input, game_event)
                if IsResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                    Parent.Size = dim2(
                        Size.X.Scale,
                        math.clamp(Size.X.Offset + (input.Position.X - InputLost.X), ParentSize.X.Offset, Camera.ViewportSize.X),
                        Size.Y.Scale,
                        math.clamp(Size.Y.Offset + (input.Position.Y - InputLost.Y), ParentSize.Y.Offset, Camera.ViewportSize.Y)
                    )
                end
            end)
        end
        function Library:Hovering(Object)
            if type(Object) == "table" then
                local Pass = false;
                for _,obj in Object do
                    if Library:Hovering(obj) then
                        Pass = true
                        return Pass
                    end
                end
            else
                if typeof(Object) ~= "Instance" or not Object:IsA("GuiObject") then
                    return false
                end
                local y_cond = Object.AbsolutePosition.Y <= mouse.Y and mouse.Y <= Object.AbsolutePosition.Y + Object.AbsoluteSize.Y
                local x_cond = Object.AbsolutePosition.X <= mouse.X and mouse.X <= Object.AbsolutePosition.X + Object.AbsoluteSize.X
                return (y_cond and x_cond)
            end
        end
        function Library:Draggify(Parent)
            local Dragging = false
            local IntialSize = Parent.Position
            local InitialPosition
            Parent.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if Library.DragLock then
                        return
                    end
                    for _, zone in Library.NoDrag do
                        local ok, blocked = pcall(function()
                            return zone.Visible and Library:Hovering(zone)
                        end)
                        if ok and blocked then
                            return
                        end
                    end
                    Dragging = true
                    InitialPosition = Input.Position
                    IntialSize = Parent.Position
                end
            end)
            Parent.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                    Library:SaveLayout()
                end
            end)
            Library:Connection(InputService.InputChanged, function(Input, game_event)
                if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                    local Horizontal = Camera.ViewportSize.X
                    local Vertical = Camera.ViewportSize.Y
                    local NewPosition = dim2(
                        0,
                        math.clamp(
                            IntialSize.X.Offset + (Input.Position.X - InitialPosition.X),
                            0,
                            Horizontal - Parent.Size.X.Offset
                        ),
                        0,
                        math.clamp(
                            IntialSize.Y.Offset + (Input.Position.Y - InitialPosition.Y),
                            0,
                            Vertical - Parent.Size.Y.Offset
                        )
                    )
                    Parent.Position = NewPosition
                end
            end)
        end
        function Library:ConvertEnum(enum)
            local EnumParts = {}
            for part in string.gmatch(enum, "[%w_]+") do
                table.insert(EnumParts, part)
            end
            local EnumTable = Enum
            for i = 2, #EnumParts do
                local EnumItem = EnumTable[EnumParts[i]]
                EnumTable = EnumItem
            end
            return EnumTable
        end
        function Library:Keypicker(properties)
            local Cfg = {
                Name = properties.Name or "Color",
                Flag = properties.Flag or properties.Name or "Colorpicker",
                Callback = properties.Callback or function() end,
                Color = properties.Color or color(1, 1, 1),  
                Alpha = properties.Alpha or properties.Transparency or 0,
                Mode = properties.Mode or "Keypicker";  
                Open = false,
                Items = {};
            }
            local DraggingSat = false
            local DraggingHue = false
            local DraggingAlpha = false
            local h, s, v = Cfg.Color:ToHSV()
            local a = Cfg.Alpha
            Flags[Cfg.Flag] = {Color = Cfg.Color, Transparency = Cfg.Alpha}
            local Items = Cfg.Items; do
                    Items.ColorpickerObject = Library:Create( "TextButton" , {
                        Active = false;
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "";
                        AutoButtonColor = false;
                        Name = "\0";
                        Parent = self.Items.Components;
                        Size = dim2(0, 17, 0, 9);
                        Selectable = false;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(12, 12, 12)
                    });
                    Items.Checker = Library:Create( "ImageLabel" , {
                        Parent = Items.ColorpickerObject;
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        Size = dim2(1, -2, 1, -2);
                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;
                        Image = "rbxassetid://3887014357";
                        ScaleType = Enum.ScaleType.Tile;
                        TileSize = dim2(0, 4, 0, 4);
                        ZIndex = 1;
                    });
                    Items.InnerObject = Library:Create( "Frame" , {
                        Parent = Items.ColorpickerObject;
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        ZIndex = 2;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Library:Create( "UIGradient" , {
                        Rotation = 90;
                        Parent = Items.InnerObject;
                        Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(208, 208, 208))}
                    });
                    Items.Colorpicker = Library:Create( "TextButton" , {
                        Active = false;
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "";
                        AutoButtonColor = false;
                        Parent = Library.Items;
                        Visible = false;
                        Name = "\0";
                        Position = dim2(0, 800, 0, 54);
                        Size = dim2(0, 180, 0, 175);
                        Selectable = false;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(12, 12, 12)
                    });
                    Items.Inline = Library:Create( "Frame" , {
                        Parent = Items.Colorpicker;
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(35, 35, 35)
                    });
                    Items._ = Library:Create( "UIPadding" , {
                        PaddingTop = dim(0, 3);
                        Name = "\0";
                        PaddingBottom = dim(0, 3);
                        Parent = Items.Inline;
                        PaddingRight = dim(0, 3);
                        PaddingLeft = dim(0, 3)
                    });
                    Items.SatVal = Library:Create( "Frame" , {
                        Name = "\0";
                        Parent = Items.Inline;
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -20, 1, -15);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    Items.Inner = Library:Create( "Frame" , {
                        Parent = Items.SatVal;
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 221, 255)
                    });
                    Items.SatValPicker = Library:Create( "Frame" , {
                        Name = "\0";
                        Parent = Items.Inner;
                        AnchorPoint = vec2(0.5, 0.5);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 4, 0, 4);
                        BorderSizePixel = 0;
                        ZIndex = 10000;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Items.InlinePicker = Library:Create( "Frame" , {
                        Parent = Items.SatValPicker;
                        Name = "\0";
                        BackgroundTransparency = 0.15000000596046448;
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 2, 0, 2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Items.Saturation = Library:Create( "Frame" , {
                        Parent = Items.Inner;
                        Name = "\0";
                        Size = dim2(1, 0, 1, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        ZIndex = 2;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Library:Create( "UIGradient" , {
                        Rotation = 270;
                        Transparency = numseq{numkey(0, 0), numkey(1, 1)};
                        Parent = Items.Saturation;
                        Color = rgbseq{rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(0, 0, 0))}
                    });
                    Items.Val = Library:Create( "TextButton" , {
                        Active = false;
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "";
                        AutoButtonColor = false;
                        Name = "\0";
                        Parent = Items.Inner;
                        Size = dim2(1, 0, 1, 0);
                        Selectable = false;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Library:Create( "UIGradient" , {
                        Parent = Items.Val;
                        Transparency = numseq{numkey(0, 0), numkey(1, 1)}
                    });
                    Items.Alpha = Library:Create( "TextButton" , {
                        Active = true;
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "";
                        AutoButtonColor = false;
                        Parent = Items.Inline;
                        Name = "\0";
                        Position = dim2(0, 0, 1, -12);
                        Size = dim2(1, -18, 0, 12);
                        Selectable = false;
                        BorderSizePixel = 0;
                        BackgroundTransparency = 1;
                    });
                    Items.AlphaInline = Library:Create( "Frame" , {
                        Parent = Items.Alpha;
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255);
                    });
                    Items.AlphaGradient = Library:Create( "UIGradient" , {
                        Parent = Items.AlphaInline;
                        Transparency = numseq{numkey(0, 0), numkey(1, 1)};
                    });
                    Items.AlphaPicker = Library:Create( "Frame" , {
                        BorderMode = Enum.BorderMode.Inset;
                        BorderColor3 = rgb(12, 12, 12);
                        Parent = Items.AlphaInline;
                        BackgroundTransparency = 0;
                        AnchorPoint = vec2(0.5, 0);
                        Position = dim2(0, 0, 0, 0);
                        Name = "\0";
                        Size = dim2(0, 2, 1, 0);
                        ZIndex = 3;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Library:Create( "UIStroke" , {
                        Parent = Items.AlphaPicker;
                        LineJoinMode = Enum.LineJoinMode.Miter
                    });
                    Items.Hue = Library:Create( "TextButton" , {
                        Active = false;
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "";
                        AutoButtonColor = false;
                        Parent = Items.Inline;
                        Name = "\0";
                        Position = dim2(1, -17, 0, 0);
                        Size = dim2(0, 17, 1, -15);
                        Selectable = false;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    Items.HueInline = Library:Create( "Frame" , {
                        Parent = Items.Hue;
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Library:Create( "UIGradient" , {
                        Rotation = 90;
                        Parent = Items.HueInline;
                        Color = rgbseq{rgbkey(0, rgb(255, 0, 0)), rgbkey(0.17, rgb(255, 255, 0)), rgbkey(0.33, rgb(0, 255, 0)), rgbkey(0.5, rgb(0, 255, 255)), rgbkey(0.67, rgb(0, 0, 255)), rgbkey(0.83, rgb(255, 0, 255)), rgbkey(1, rgb(255, 0, 0))}
                    });
                    Items.HuePicker = Library:Create( "Frame" , {
                        BorderMode = Enum.BorderMode.Inset;
                        BorderColor3 = rgb(12, 12, 12);
                        Parent = Items.HueInline;
                        BackgroundTransparency = 0.25;
                        Position = dim2(0, 1, 1, 1);
                        Name = "\0";
                        Size = dim2(1, -2, 0, 2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Library:Create( "UIStroke" , {
                        Parent = Items.HuePicker;
                        LineJoinMode = Enum.LineJoinMode.Miter
                    });
            end;
            do
                table.insert(Library.NoDrag, Items.Colorpicker)
                Items.Colorpicker.ZIndex += 20000
                for _, descendant in Items.Colorpicker:GetDescendants() do
                    if descendant:IsA("GuiObject") then
                        descendant.ZIndex += 20000
                    end
                end
            end
            function Cfg.SetVisible(bool)
                if Cfg.__removed or not Items.Colorpicker or Items.Colorpicker.Parent == nil then
                    return
                end
                Items.Colorpicker.Visible = bool
                Items.Colorpicker.Parent = bool and Library.Items or Library.Other
                local Origin = Items.ColorpickerObject.AbsolutePosition
                local Viewport = Camera.ViewportSize
                local Size = Items.Colorpicker.AbsoluteSize
                local X = math.clamp(Origin.X, 0, math.max(0, Viewport.X - Size.X))
                local Y = Origin.Y + 74
                if Y + Size.Y > Viewport.Y then
                    Y = math.max(0, Origin.Y - Size.Y + 65)
                end
                Items.Colorpicker.Position = dim2(0, X, 0, Y)
            end
            function Cfg.Set(color, alpha)
                if type(color) == "boolean" then
                    return
                end
                if color then
                    h, s, v = color:ToHSV()
                end
                if alpha ~= nil then
                    a = alpha
                end
                local Color = hsv(h, s, v)
                Items.SatValPicker.Position = dim2(s, 0, 1 - v, 0)
                Items.AlphaPicker.Position = dim2(a, 0, 0, 0)
                Items.HuePicker.Position = dim2(0, 1, h, -1)
                Items.Inner.BackgroundColor3 = hsv(h, 1, 1)
                Items.AlphaInline.BackgroundColor3 = Color
                Items.InnerObject.BackgroundColor3 = Color
                Items.InnerObject.BackgroundTransparency = a
                Flags[Cfg.Flag] = {
                    Color = Color;
                    Transparency = a
                }
                Cfg.Callback(Color, a)
            end
            function Cfg.UpdateColor()
                local Mouse = InputService:GetMouseLocation()
                local offset = vec2(Mouse.X, Mouse.Y - gui_offset)
                if DraggingSat then
                    s = math.clamp((offset - Items.Val.AbsolutePosition).X / Items.Val.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((offset - Items.Val.AbsolutePosition).Y / Items.Val.AbsoluteSize.Y, 0, 1)
                elseif DraggingHue then
                    h = math.clamp((offset - Items.Hue.AbsolutePosition).Y / Items.Hue.AbsoluteSize.Y, 0, 1)
                elseif DraggingAlpha then
                    a = math.clamp((offset - Items.Alpha.AbsolutePosition).X / Items.Alpha.AbsoluteSize.X, 0, 1)
                end
                Cfg.Set()
            end
            Items.ColorpickerObject.MouseButton1Click:Connect(function()
                Cfg.Open = not Cfg.Open
                Cfg.SetVisible(Cfg.Open)
            end)
            Items.ColorpickerObject.MouseButton2Click:Connect(function()
                Library:OpenColorContextMenu(Cfg, Items.ColorpickerObject)
            end)
            table.insert(Library.ExtraClosers, function()
                if Cfg.Open then
                    Cfg.Open = false
                    Cfg.SetVisible(false)
                end
                Library:CloseColorContextMenu()
            end)
            InputService.InputChanged:Connect(function(input)
                if (DraggingSat or DraggingHue or DraggingAlpha) and input.UserInputType == Enum.UserInputType.MouseMovement then
                    Cfg.UpdateColor()
                end
            end)
            Library:Connection(InputService.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    DraggingSat = false
                    DraggingHue = false
                    DraggingAlpha = false
                    if not Library:Hovering({Items.ColorpickerObject, Items.Colorpicker}) then
                        Cfg.SetVisible(false)
                        Cfg.Open = false
                    end
                end
            end)
            Library:Connection(InputService.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if Library.ColorContextMenu and Library.ColorContextMenu.Visible then
                        if not Library:Hovering({Library.ColorContextMenu}) then
                            Library:CloseColorContextMenu()
                        end
                    end
                    if not Library:Hovering({Items.ColorpickerObject, Items.Colorpicker}) then
                        Cfg.SetVisible(false)
                        Cfg.Open = false
                    end
                end
            end)
            Items.Alpha.MouseButton1Down:Connect(function()
                DraggingAlpha = true
            end)
            Items.Hue.MouseButton1Down:Connect(function()
                DraggingHue = true
            end)
            Items.Val.MouseButton1Down:Connect(function()
                DraggingSat = true
            end)
            Cfg.Set(Cfg.Color, Cfg.Alpha)
            ConfigFlags[Cfg.Flag] = Cfg.Set
            return RegisterUIElement(self, "color_picker", setmetatable(Cfg, Library))
        end
        function Library:GetConfig()
            local Config = {}
            for Idx, Value in pairs(Flags) do
                if Idx == "config_name_list" or Idx == "ConfigPresetName" then
                    continue
                end
                if type(Value) == "table" and (Value.key ~= nil or Value.Key ~= nil or Value.mode ~= nil or Value.Mode ~= nil) then
                    local Key = Value.key ~= nil and Value.key or Value.Key
                    local Mode = Value.mode ~= nil and Value.mode or Value.Mode
                    local Active = Value.active ~= nil and Value.active or Value.Active
                    Config[Idx] = {active = (Active == true), mode = Mode or "Hold", key = tostring(Key or "NONE")}
                elseif type(Value) == "table" and Value["Transparency"] ~= nil and Value["Color"] ~= nil and typeof(Value["Color"]) == "Color3" then
                    Config[Idx] = {Transparency = Value["Transparency"], Color = Value["Color"]:ToHex()}
                elseif typeof(Value) == "Color3" then
                    Config[Idx] = {Transparency = 0, Color = Value:ToHex()}
                elseif typeof(Value) == "EnumItem" then
                    Config[Idx] = tostring(Value)
                else
                    Config[Idx] = Value
                end
            end
            return HttpService:JSONEncode(Config)
        end
        function Library:LoadConfig(JSON)
            local ok, Config = pcall(function()
                return HttpService:JSONDecode(JSON)
            end)
            if not ok or type(Config) ~= "table" then
                return false, "Invalid JSON"
            end
            for Idx, Value in pairs(Config) do
                if Idx == "config_name_list" or Idx == "ConfigPresetName" then
                    continue
                end
                local Function = ConfigFlags[Idx]
                if Function then
                    pcall(function()
                        if type(Value) == "table" and Value["Transparency"] ~= nil and Value["Color"] ~= nil then
                            local col = hex(Value["Color"])
                            Function(PickerColorGlobal(col), Value["Transparency"])
                        elseif type(Value) == "table" and (Value["active"] ~= nil or Value["Active"] ~= nil or Value["key"] ~= nil or Value["Key"] ~= nil or Value["mode"] ~= nil or Value["Mode"] ~= nil) then
                            Function(Value)
                        else
                            Function(Value)
                        end
                    end)
                end
            end
            return true
        end
        function Library:Round(num, float)
            num, float = tonumber(num), tonumber(float) or 1
            if not num or num ~= num or math.abs(num) == math.huge then return 0 end
            if float ~= float or float <= 0 or float == math.huge then float = 1 end
            local scaled = num / float
            if math.abs(scaled) == math.huge then return num end
            return math.floor(scaled + 0.5) * float
        end
        function Library:Themify(instance, theme, property)
            table.insert(themes.utility[theme][property], instance)
        end
        function Library:SaveGradient(instance, theme)  
            table.insert(themes.gradients[theme], instance)
        end
        function Library:RefreshTheme(theme, color)
            for property,instances in themes.utility[theme] do
                for _,object in instances do
                    if object[property] == themes.preset[theme] then
                        object[property] = color
                    end
                end
            end
            themes.preset[theme] = color
        end
        function Library:Connection(signal, callback)
            local connection = signal:Connect(callback)
            table.insert(Library.Connections, connection)
            return connection
        end
        function Library:CloseElement()
            local IsMulti = typeof(Library.OpenElement)
            if not Library.OpenElement then
                return
            end
            for i = 1, #Library.OpenElement do
                local Data = Library.OpenElement[i]
                if Data.Ignore then
                    continue
                end
                Data.SetVisible(false)
                Data.Open = false
            end
            Library.OpenElement = {}
		end
        function Library:GetColorContextMenu()
            if Library.ColorContextMenu then
                return Library.ColorContextMenu
            end
            local Menu = Library:Create("Frame", {
                Parent = Library.Other,
                Name = "\0",
                Size = dim2(0, 68, 0, 40),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(12, 12, 12),
                Visible = false,
                ZIndex = 25000
            })
            local Outline = Library:Create("Frame", {
                Parent = Menu,
                Name = "\0",
                Position = dim2(0, 1, 0, 1),
                Size = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(35, 35, 35)
            })
            local Inline = Library:Create("Frame", {
                Parent = Outline,
                Name = "\0",
                Position = dim2(0, 1, 0, 1),
                Size = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(18, 18, 18)
            })
            Library:Create("UIListLayout", {
                Parent = Inline,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = dim(0, 0)
            })
            local function CreateMenuButton(text, layoutOrder, onClick)
                local btn = Library:Create("TextButton", {
                    Parent = Inline,
                    Name = "\0",
                    Size = dim2(1, 0, 0, 18),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(18, 18, 18),
                    Text = text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                    TextColor3 = rgb(205, 205, 205),
                    LayoutOrder = layoutOrder,
                    ZIndex = 25001
                })
                Library:Create("UIPadding", {
                    Parent = btn,
                    PaddingLeft = dim(0, 8),
                    PaddingRight = dim(0, 8)
                })
                btn.MouseEnter:Connect(function()
                    btn.BackgroundColor3 = rgb(28, 28, 28)
                    btn.TextColor3 = themes.preset.accent
                end)
                btn.MouseLeave:Connect(function()
                    btn.BackgroundColor3 = rgb(18, 18, 18)
                    btn.TextColor3 = rgb(205, 205, 205)
                end)
                btn.MouseButton1Click:Connect(onClick)
                return btn
            end
            CreateMenuButton("Copy", 1, function()
                if Library.ActiveColorContextCfg then
                    local cfg = Library.ActiveColorContextCfg
                    local colorVal = Flags[cfg.Flag] and Flags[cfg.Flag].Color or cfg.Color
                    local alphaVal = Flags[cfg.Flag] and Flags[cfg.Flag].Transparency or cfg.Alpha or 0
                    Library.ColorClipboard = {
                        Color = colorVal,
                        Alpha = alphaVal
                    }
                end
                Library:CloseColorContextMenu()
            end)
            CreateMenuButton("Paste", 2, function()
                if Library.ActiveColorContextCfg and Library.ColorClipboard then
                    local cfg = Library.ActiveColorContextCfg
                    cfg.Set(Library.ColorClipboard.Color, Library.ColorClipboard.Alpha)
                end
                Library:CloseColorContextMenu()
            end)
            Library.ColorContextMenu = Menu
            return Menu
        end
        function Library:CloseColorContextMenu()
            if Library.ColorContextMenu then
                Library.ColorContextMenu.Visible = false
                Library.ColorContextMenu.Parent = Library.Other
                Library.ActiveColorContextCfg = nil
            end
        end
        function Library:OpenColorContextMenu(Cfg, TargetObject)
            local menu = Library:GetColorContextMenu()
            if menu.Visible and Library.ActiveColorContextCfg == Cfg then
                Library:CloseColorContextMenu()
                return
            end
            Library.ActiveColorContextCfg = Cfg
            menu.Parent = Library.Items
            menu.Visible = true
            local Origin = TargetObject.AbsolutePosition
            local Viewport = Camera.ViewportSize
            local Size = TargetObject.AbsoluteSize
            local MenuSize = menu.AbsoluteSize
            local X = math.clamp(Origin.X, 0, math.max(0, Viewport.X - 68))
            local Y = Origin.Y + 71
            if Y + 40 > Viewport.Y then
                Y = math.max(0, Origin.Y + 62 - 40)
            end
            menu.Position = dim2(0, X, 0, Y)
        end
        function Library:Create(instance, options)
            local ins = Instance.new(instance)
            if instance == "TextButton" or ins:IsA("TextButton") then
                ins["AutoButtonColor"] = false
                ins["Text"] = ""
            end
            for prop, value in options do
                ins[prop] = value
            end
            return ins
        end
        function Library:Unload()
            for _, hook in Library.UnloadHooks or {} do
                pcall(hook)
            end
            if Library.Items then
                Library.Items:Destroy()
            end
            if Library.Other then
                Library.Other:Destroy()
            end
            for _,connection in Library.Connections do
                connection:Disconnect()
                connection = nil
            end
            getgenv().Library = nil
        end
        function Library:Window(properties)
            local Cfg = {
                Name = properties.Name or "nebula";
                Size = properties.Size or dim2(0, 660, 0, 674);
                TabInfo;
                Tweening = false;
                Items = {};
            }
            Library.Items = Library:Create( "ScreenGui" , {
                Parent = CoreGui;
                Name = "\0";
                Enabled = true;
                ZIndexBehavior = Enum.ZIndexBehavior.Global;
                IgnoreGuiInset = true;
                DisplayOrder = 500;
            });
            Library.Other = Library:Create( "ScreenGui" , {
                Parent = CoreGui;
                Name = "\0";
                Enabled = false;
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
                IgnoreGuiInset = true;
            });
            local Items = Cfg.Items; do
                    Items.Window = Library:Create( "Frame" , {
                        Parent = Library.Items;
                        Name = "\0";
                        Visible = false;
                        ClipsDescendants = true;
                        Position = dim2(0.5, -Cfg.Size.X.Offset / 2, 0.5, -Cfg.Size.Y.Offset / 2);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = Cfg.Size;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(12, 12, 12)
                    }); Items.Window.Position = dim2(0, Items.Window.AbsolutePosition.X, 0, Items.Window.AbsolutePosition.Y);
                    Items.Inline = Library:Create( "Frame" , {
                        Parent = Items.Window;
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(61, 61, 61)
                    });
                    Items.Hollow = Library:Create( "Frame" , {
                        Parent = Items.Inline;
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(43, 43, 43)
                    });
                    Items.Inline = Library:Create( "Frame" , {
                        Parent = Items.Hollow;
                        Name = "\0";
                        Position = dim2(0, 3, 0, 3);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -6, 1, -6);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(61, 61, 61)
                    });
                    Items.InnerPage = Library:Create( "Frame" , {
                        Parent = Items.Inline;
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(12, 12, 12)
                    });
                    Items.ImageLabel = Library:Create( "ImageLabel" , {
                        BorderColor3 = rgb(0, 0, 0);
                        Parent = Items.InnerPage;
                        Size = dim2(1, -2, 0, 2);
                        Image = "rbxassetid://8508019876";
                        BackgroundTransparency = 1;
                        Position = dim2(0, 1, 0, 1);
                        ZIndex = 3;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    Items.Fillbar = Library:Create( "Frame" , {
                        Parent = Items.ImageLabel;
                        Size = dim2(1, 0, 0, 1);
                        Name = "\0";
                        Position = dim2(0, 0, 0, -1);
                        BorderColor3 = rgb(0, 0, 0);
                        ZIndex = 3;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(12, 12, 12)
                    });
                    Items.AccentBar = Library:Create( "Frame" , {
                        Parent = Items.ImageLabel;
                        Size = dim2(1, 0, 0, 1);
                        Name = "\0";
                        Position = dim2(0, 0, 1, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        ZIndex = 3;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(6, 6, 6)
                    });
                    Items.Outline = Library:Create( "Frame" , {
                        Name = "\0";
                        Parent = Items.InnerPage;
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 75, 1, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(40, 40, 40)
                    });
                    Items.Inline = Library:Create( "Frame" , {
                        Parent = Items.Outline;
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    Items.Background = Library:Create( "ScrollingFrame" , {
                        Parent = Items.Inline;
                        Name = "\0";
                        Active = true;
                        CanvasSize = dim2(0, 0, 0, 0);
                        AutomaticCanvasSize = Enum.AutomaticSize.Y;
                        ScrollBarThickness = 3;
                        ScrollBarImageColor3 = rgb(70, 70, 70);
                        ScrollBarImageTransparency = 0.35;
                        ScrollingDirection = Enum.ScrollingDirection.Y;
                        ElasticBehavior = Enum.ElasticBehavior.Never;
                        ClipsDescendants = true;
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(12, 12, 12)
                    });
                    Library:Create( "UIListLayout" , {
                        Parent = Items.Background;
                        Padding = dim(0, 4)
                    });
                    Library:Create( "UIPadding" , {
                        Parent = Items.Background;
                        PaddingTop = dim(0, 9);
                        PaddingLeft = dim(0, -2)
                    });
                    Items.Fill = Library:Create( "Frame" , {
                        Name = "\0";
                        Parent = Items.Outline;
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, 0, 0, 1);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(12, 12, 12)
                    });
                    Items.FillTwo = Library:Create( "Frame" , {
                        Parent = Items.Outline;
                        Name = "\0";
                        Size = dim2(0, 2, 1, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        ZIndex = 2;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(12, 12, 12)
                    });
                    Items.FillThree = Library:Create( "Frame" , {
                        Parent = Items.Outline;
                        Size = dim2(1, -2, 0, 5);
                        Name = "\0";
                        Position = dim2(0, 0, 1, -5);
                        BorderColor3 = rgb(0, 0, 0);
                        ZIndex = 2;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(12, 12, 12)
                    });
                    Items.FillFive = Library:Create( "Frame" , {
                        Parent = Items.Outline;
                        Name = "\0";
                        Position = dim2(1, -2, 0, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 1, 1, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    Items.PageHolder = Library:Create( "Frame" , {
                        Parent = Items.InnerPage;
                        Name = "\0";
                        Position = dim2(0, 75, 0, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -75, 1, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Library:Create( "ImageLabel" , {
                        ImageColor3 = rgb(12, 12, 12);
                        ScaleType = Enum.ScaleType.Tile;
                        BorderColor3 = rgb(0, 0, 0);
                        Image = "rbxassetid://8547666218";
                        TileSize = dim2(0, 8, 0, 8);
                        Parent = Items.PageHolder;
                        Size = dim2(1, 0, 1, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(20, 20, 20)
                    });
            end
            do  
                Library.Window = Items.Window
                Library:LoadLayout(Items.Window)
                Library:Draggify(Items.Window)
                Library:Resizify(Items.Window)
            end
            function Cfg.ToggleMenu(bool)
                Items.Window.Visible = bool
                menuOpen = bool
                if bool then
                    InputService.MouseBehavior = Enum.MouseBehavior.Default
                    InputService.MouseIconEnabled = true
                    for _, open in Library.OpenHooks do
                        pcall(open)
                    end
                else
                    Library:CloseElement()
                    for _, close in Library.ExtraClosers do
                        pcall(close)
                    end
                    if Library.AllDropdowns then
                        for _, dd in Library.AllDropdowns do
                            pcall(function()
                                if dd and dd.Open and dd.SetVisible then
                                    dd.Open = false
                                    dd.SetVisible(false)
                                end
                            end)
                        end
                    end
                end
            end
            return setmetatable(Cfg, Library)
        end
        function Library:Tab(properties)
            local Cfg = {
                Items = {};
                Icon = properties.Icon or properties.icon or "rbxassetid://8547236654"
            }
            local Items = Cfg.Items; do
                    Items.ButtonHolder = Library:Create( "TextButton" , {
                        Parent = self.Items.Background;
                        Text = "";
                        AutoButtonColor = true;
                        BackgroundTransparency = 1;
                        Name = "\0";
                        Active = true;
                        ZIndex = 5;
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, 0, 0, 70);
                        Position = dim2(0, -2, 0, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    Items.Outline = Library:Create( "Frame" , {
                        Parent = Items.ButtonHolder;
                        Name = "\0";
                        Size = dim2(1, 0, 1, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        ZIndex = 3;
                        Visible = false;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    Items.Inline = Library:Create( "Frame" , {
                        Parent = Items.Outline;
                        Size = dim2(1, 1, 1, -2);
                        ZIndex = 3;
                        Name = "\0";
                        Position = dim2(0, 0, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(40, 40, 40)
                    });
                    Items.Background = Library:Create( "Frame" , {
                        Parent = Items.Inline;
                        Size = dim2(1, 0, 1, -2);
                        ZIndex = 3;
                        Name = "\0";
                        Position = dim2(0, 0, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(20, 20, 20)
                    });
                    Items.Pattern = Library:Create( "ImageLabel" , {
                        ImageColor3 = rgb(12, 12, 12);
                        ScaleType = Enum.ScaleType.Tile;
                        BorderColor3 = rgb(0, 0, 0);
                        ZIndex = 4;
                        Parent = Items.Background;
                        Name = "\0";
                        TileSize = dim2(0, 8, 0, 8);
                        Image = "rbxassetid://8547666218";
                        BackgroundTransparency = 1;
                        Size = dim2(1, 2, 1, 0);
                        Position = dim2(0, -1, 0, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    Items.Filler = Library:Create( "Frame" , {
                        Parent = Items.Background;
                        Name = "\0";
                        ZIndex = 3;
                        Position = dim2(1, 0, 0, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 2, 1, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(20, 20, 20)
                    });
                    Items.Icon = Library:Create( "ImageLabel" , {
                        BorderColor3 = rgb(0, 0, 0);
                        Parent = Items.ButtonHolder;
                        Name = "\0";
                        ImageColor3 = rgb(100, 100, 100);
                        Size = dim2(0, 50, 0, 50);
                        AnchorPoint = vec2(0.5, 0.5);
                        Image = Cfg.Icon;
                        BackgroundTransparency = 1;
                        Position = dim2(0.5, 0, 0.5, 0);
                        ZIndex = 4;
                        BorderSizePixel = 0;
                    });
                    Items.Shade = Library:Create( "ImageLabel" , {
                        ImageColor3 = rgb(0, 0, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        Parent = Items.ButtonHolder;
                        Name = "\0";
                        Size = dim2(0, 50, 0, 50);
                        AnchorPoint = vec2(0.5, 0.5);
                        Image = Cfg.Icon;
                        BackgroundTransparency = 1;
                        Position = dim2(0.5, 1, 0.5, 1);
                        ZIndex = 3;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    Items.Button = Library:Create( "TextButton" , {
                        Parent = Items.ButtonHolder;
                        Name = "\0";
                        BackgroundTransparency = 1;
                        Size = dim2(1, 0, 1, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "";
                        ZIndex = 3;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    Items.Page = Library:Create( "Frame" , {
                        Parent = self.Items.PageHolder;
                        BackgroundTransparency = 1;
                        Visible = false;
                        Name = "\0";
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, 0, 1, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Library:Create( "UIListLayout" , {
                        FillDirection = Enum.FillDirection.Horizontal;
                        HorizontalFlex = Enum.UIFlexAlignment.Fill;
                        Parent = Items.Page;
                        Padding = dim(0, 20);
                        SortOrder = Enum.SortOrder.LayoutOrder;
                        VerticalFlex = Enum.UIFlexAlignment.Fill
                    });
                    Library:Create( "UIPadding" , {
                        PaddingTop = dim(0, 20);
                        PaddingBottom = dim(0, 20);
                        Parent = Items.Page;
                        PaddingRight = dim(0, 20);
                        PaddingLeft = dim(0, 20)
                    });
                    Items.Left = Library:Create( "Frame" , {
                        Parent = Items.Page;
                        BackgroundTransparency = 1;
                        Name = "\0";
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 100, 0, 100);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Library:Create( "UIListLayout" , {
                        SortOrder = Enum.SortOrder.LayoutOrder;
                        VerticalFlex = Cfg.RightFill and Enum.UIFlexAlignment.Fill or Enum.UIFlexAlignment.None;
                        Parent = Items.Left;
                        Padding = dim(0, 19);
                    });
                    Items.Right = Library:Create( "Frame" , {
                        Parent = Items.Page;
                        BackgroundTransparency = 1;
                        Name = "\0";
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 100, 0, 100);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Library:Create( "UIListLayout" , {
                        SortOrder = Enum.SortOrder.LayoutOrder;
                        VerticalFlex = Cfg.LeftFill and Enum.UIFlexAlignment.Fill or Enum.UIFlexAlignment.None;
                        Parent = Items.Right;
                        Padding = dim(0, 19);
                    });
            end
            function Cfg.OpenTab()
                local Tab = self.TabInfo
                if Tab then
                    Tab.Page.Visible = false
                    Tab.Page.Parent = Library.Other
                    Tab.Icon.ImageColor3 = rgb(100, 100, 100)
                    Tab.Outline.Visible = false
                end
                Items.Icon.ImageColor3 = rgb(255, 255, 255)
                Items.Outline.Visible = true
                Items.Page.Parent = self.Items.PageHolder
                Items.Page.Visible = true
                self.TabInfo = Cfg.Items
            end
            Items.ButtonHolder.MouseButton1Down:Connect(function()
                Cfg.OpenTab()
            end)
            if not self.TabInfo then
                Cfg.OpenTab()
            end
            return setmetatable(Cfg, Library)
        end
        function Library:Section(properties)
            local Cfg = {
                Name = properties.name or properties.Name or "Section";
                Side = properties.side or properties.Side or "Left";
                Size = properties.size or properties.Size or 1;
                Items = {};
            };
            local Items = Cfg.Items; do
                Items.Outline = Library:Create( "Frame" , {
                    Name = "\0";
                    Parent = self.Items[Cfg.Side];
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, Cfg.Size, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(12, 12, 12)
                });
                Items.Inline = Library:Create( "Frame" , {
                    Parent = Items.Outline;
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(40, 40, 40)
                });
                Items.Background = Library:Create( "Frame" , {
                    Parent = Items.Inline;
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(23, 23, 23)
                });
                Items.Title = Library:Create( "TextLabel" , {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
                    TextColor3 = rgb(255, 255, 255);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = Cfg.Name;
                    Parent = Items.Background;
                    Name = "\0";
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundTransparency = 1;
                    Position = dim2(0, 9, 0, -9);
                    BorderSizePixel = 0;
                    ZIndex = 4;
                    TextSize = 13;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Items.Shade = Library:Create( "TextLabel" , {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
                    TextColor3 = rgb(0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = Cfg.Name;
                    Parent = Items.Background;
                    Name = "\0";
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundTransparency = 1;
                    Position = dim2(0, 13, 0, -8);
                    BorderSizePixel = 0;
                    ZIndex = 3;
                    TextSize = 13;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Library:Create( "Frame" , {
                    Parent = Items.Title;
                    Position = dim2(0, 2, 0.5, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 5, 0, 2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(23, 23, 23)
                });
                Items.ScrollbarFill = Library:Create( "Frame" , {
                    Visible = false;
                    BorderColor3 = rgb(0, 0, 0);
                    AnchorPoint = vec2(1, 0);
                    Name = "\0";
                    Position = dim2(1, 0, 0, 0);
                    Parent = Items.Background;
                    Size = dim2(0, 6, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(45, 45, 45)
                });
                Items.Holder = Library:Create( "ScrollingFrame" , {
                    Active = true;
                    AutomaticCanvasSize = Enum.AutomaticSize.Y;
                    ZIndex = 2;
                    BorderSizePixel = 0;
                    CanvasSize = dim2(0, 0, 0, 0);
                    ScrollBarImageColor3 = rgb(65, 65, 65);
                    MidImage = "rbxassetid://74268315755026";
                    BorderColor3 = rgb(0, 0, 0);
                    ScrollBarThickness = 4;
                    Parent = Items.Background;
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Position = dim2(0, 0, 0, 1);
                    Size = dim2(1, -1, 1, -1);
                    BottomImage = "rbxassetid://74268315755026";
                    TopImage = "rbxassetid://74268315755026";
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Items.Elements = Library:Create( "Frame" , {
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = Items.Holder;
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Position = dim2(0, 20, 0, 19);
                    Size = dim2(1, -42, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Library:Create( "UIListLayout" , {
                    Parent = Items.Elements;
                    Padding = dim(0, 8);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
                Items.Gradient = Library:Create( "Frame" , {
                    BorderColor3 = rgb(0, 0, 0);
                    AnchorPoint = vec2(0, 1);
                    Parent = Items.Background;
                    Name = "\0";
                    Position = dim2(0, 0, 1, 0);
                    Size = dim2(1, -6, 0, 20);
                    ZIndex = 2;
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Library:Create( "UIGradient" , {
                    Rotation = -90;
                    Transparency = numseq{numkey(0, 0), numkey(0.502, 0.4937499761581421), numkey(1, 1)};
                    Parent = Items.Gradient;
                    Color = rgbseq{rgbkey(0, rgb(23, 23, 23)), rgbkey(1, rgb(23, 23, 23))}
                });
                Items.Up = Library:Create( "ImageLabel" , {
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = Items.Background;
                    Name = "\0";
                    Size = dim2(0, 5, 0, 4);
                    AnchorPoint = vec2(1, 0.5);
                    Visible = false;
                    Image = "rbxassetid://83504953088675";
                    BackgroundTransparency = 1;
                    Position = dim2(1, -10, 1, -8);
                    ZIndex = 5;
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Items.Down = Library:Create( "ImageLabel" , {
                    Parent = Items.Background;
                    BorderColor3 = rgb(0, 0, 0);
                    Name = "\0";
                    Rotation = 180;
                    Size = dim2(0, 5, 0, 4);
                    Visible = false;
                    AnchorPoint = vec2(1, 0.5);
                    Image = "rbxassetid://83504953088675";
                    BackgroundTransparency = 1;
                    Position = dim2(1, -10, 0, 8);
                    ZIndex = 5;
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Items.Elements:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    Items.ScrollbarFill = Items.Holder.AbsoluteSize.Y < Items.Holder.AbsoluteSize.Y and true or false
                end)
            end
            Library.Registry = Library.Registry or {}
            local tabName = self.RegistryName or "unknown"
            Library.Registry[tabName] = Library.Registry[tabName] or {}
            Library.Registry[tabName][string.lower(Cfg.Name)] = Cfg
            Cfg.Tab = self
            return setmetatable(Cfg, Library)
        end
        function Library:Toggle(properties)
            local Cfg = {
                Name = properties.Name or "Toggle";
                Flag = properties.Flag or properties.Name or "Toggle";
                Enabled = properties.Default or false;
                Callback = properties.Callback or function() end;
                Folding = properties.Folding or false;
                Collapsable = properties.Collapsing or true;
                Items = {};
            }
            local Items = Cfg.Items; do
                Items.Toggle = Library:Create( "TextButton" , {
                    Active = false;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    AutoButtonColor = false;
                    Parent = self.Items.Elements;
                    BackgroundTransparency = 1;
                    Name = "\0";
                    Size = dim2(1, 0, 0, 8);
                    Selectable = false;
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Items.Components = Library:Create( "Frame" , {
                    Parent = Items.Toggle;
                    Name = "\0";
                    Position = dim2(1, 0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 0, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Library:Create( "UIListLayout" , {
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalAlignment = Enum.HorizontalAlignment.Right;
                    Parent = Items.Components;
                    Padding = dim(0, 3);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
                Items.Title = Library:Create( "TextLabel" , {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                    TextColor3 = rgb(205, 205, 205);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = Cfg.Name;
                    Parent = Items.Toggle;
                    Name = "\0";
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundTransparency = 1;
                    Position = dim2(0, 19, 0, -4);
                    BorderSizePixel = 0;
                    ZIndex = 2;
                    TextSize = 13;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Items.Holder = Library:Create( "Frame" , {
                    Name = "\0";
                    Parent = Items.Toggle;
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 8, 0, 8);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(12, 12, 12)
                });
                Items.Accent = Library:Create( "Frame" , {
                    Parent = Items.Holder;
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundTransparency = 1;
                    ZIndex = 2;
                    BackgroundColor3 = themes.preset.accent
                }); Library:Themify(Items.Accent, "accent", "BackgroundColor3")
                Library:Create( "UIGradient" , {
                    Rotation = 90;
                    Parent = Items.Accent;
                    Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(170, 170, 170))}
                });
                Items.Background = Library:Create( "Frame" , {
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = Items.Holder;
                    Position = dim2(0, 1, 0, 1);
                    Name = "\0";
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Library:Create( "UIGradient" , {
                    Rotation = 90;
                    Parent = Items.Background;
                    Color = rgbseq{rgbkey(0, rgb(85, 85, 85)), rgbkey(1, rgb(60, 60, 60))}
                });
            end;
            function Cfg.Set(bool)
                Cfg.Enabled = bool
                Flags[Cfg.Flag] = bool
                Cfg.Callback(bool)
                Library:Tween(Items.Accent, {BackgroundTransparency = bool and 0 or 1})
            end
            Items.Toggle.MouseButton1Click:Connect(function()
                Cfg.Enabled = not Cfg.Enabled
                Cfg.Set(Cfg.Enabled)
            end)
            Cfg.Set(Cfg.Enabled)
            ConfigFlags[Cfg.Flag] = Cfg.Set
            return RegisterUIElement(self, "checkbox", setmetatable(Cfg, Library))
        end
        function Library:Slider(properties)
            -- All sliders in the menu use whole numbers only: min/max/step/default are
            -- normalized to integers, values snap to the step and render with %d,
            -- so a value can never look like 25.000123 again.
            local function IntegerValue(value, fallback)
                local number = tonumber(value)
                if not number or number ~= number or math.abs(number) == math.huge then
                    return fallback or 0
                end
                return math.floor(number + 0.5)
            end
            local minValue = IntegerValue(properties.Min, 0)
            local maxValue = IntegerValue(properties.Max, 100)
            if maxValue < minValue then
                maxValue = minValue
            end
            local Cfg = {
                Name = properties.Name or nil,
                Suffix = properties.Suffix or "",
                Flag = properties.Flag or properties.Name or "Slider",
                Callback = properties.Callback or function() end,
                Min = minValue,
                Max = maxValue,
                Intervals = math.max(1, IntegerValue(properties.Decimal, 1)),
                Value = IntegerValue(properties.Default, minValue),
                Formatter = properties.Formatter,
                Dragging = false,
                Items = {}
            }
            local Items = Cfg.Items; do
                Items.Slider = Library:Create( "TextButton" , {
                    Active = false;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    AutoButtonColor = false;
                    Parent = self.Items.Elements;
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 8);
                    AutomaticSize = Enum.AutomaticSize.Y;
                    Selectable = false;
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                if Cfg.Name then
                    Items.Title = Library:Create( "TextLabel" , {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                        TextColor3 = rgb(205, 205, 205);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = Cfg.Name;
                        Parent = Items.Slider;
                        Name = "\0";
                        AutomaticSize = Enum.AutomaticSize.XY;
                        BackgroundTransparency = 1;
                        Position = dim2(0, 21, 0, -2);
                        BorderSizePixel = 0;
                        ZIndex = 2;
                        TextSize = 13;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                end
                Items.Holder = Library:Create( "TextButton" , {
                    Parent = Items.Slider;
                    AutoButtonColor = false;
                    Text = "";
                    Name = "\0";
                    Position = dim2(0, 20, 0, Cfg.Name and 14 or 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -55, 0, 7);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(12, 12, 12)
                });
                Items.Background = Library:Create( "Frame" , {
                    Parent = Items.Holder;
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Library:Create( "UIGradient" , {
                    Rotation = 90;
                    Parent = Items.Background;
                    Color = rgbseq{rgbkey(0, rgb(52, 52, 52)), rgbkey(1, rgb(68, 68, 68))}
                });
                Items.Plus = Library:Create( "TextButton" , {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                    TextColor3 = rgb(205, 205, 205);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "+";
                    Parent = Items.Holder;
                    Name = "\0";
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundTransparency = 1;
                    Position = dim2(1, 5, 0, -3);
                    BorderSizePixel = 0;
                    ZIndex = 2;
                    TextSize = 12;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Items.Minus = Library:Create( "TextButton" , {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                    TextColor3 = rgb(205, 205, 205);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "-";
                    Parent = Items.Holder;
                    Name = "\0";
                    AnchorPoint = vec2(1, 0);
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundTransparency = 1;
                    Position = dim2(0, -3, 0, -3);
                    BorderSizePixel = 0;
                    ZIndex = 2;
                    TextSize = 12;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Items.Accent = Library:Create( "Frame" , {
                    Parent = Items.Holder;
                    Size = dim2(0.5, -2, 1, -2);
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    ZIndex = 2;
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.accent
                }); Library:Themify(Items.Accent, "accent", "BackgroundColor3")
                Library:Create( "UIGradient" , {
                    Rotation = 90;
                    Parent = Items.Accent;
                    Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(170, 170, 170))}
                });
                Items.Value = Library:Create( "TextBox" , {
                    Parent = Items.Accent;
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
                    Name = "\0";
                    TextColor3 = rgb(205, 205, 205);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "100%";
                    AutomaticSize = Enum.AutomaticSize.XY;
                    Selectable = false;
                    AnchorPoint = vec2(0.5, 0);
                    BorderSizePixel = 0;
                    BackgroundTransparency = 1;
                    Position = dim2(1, 0, 0.10000000149011612, 0);
                    Active = false;
                    ZIndex = 2;
                    TextSize = 13;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Library:Create( "UIStroke" , {
                    Parent = Items.Value;
                    Transparency = 0.5
                });
            end
            table.insert(Library.NoDrag, Items.Holder)
            table.insert(Library.NoDrag, Items.Minus)
            table.insert(Library.NoDrag, Items.Plus)
            function Cfg.Set(value)
                if type(value) == "string" then
                    value = value:match("^%s*(.-)%s*$")
                    local suffix = tostring(Cfg.Suffix or "")
                    if #suffix > 0 and value:sub(-#suffix) == suffix then
                        value = value:sub(1, #value-#suffix)
                    end
                    value = value:gsub(",", ".")
                end
                local number = tonumber(value)
                if not number or number ~= number or math.abs(number) == math.huge then
                    number = tonumber(Cfg.Value) or tonumber(Cfg.Min) or 0
                    if number ~= number or math.abs(number) == math.huge then number = 0 end
                end
                -- Re-normalize in case code touched Min/Max/Intervals directly.
                Cfg.Min = IntegerValue(Cfg.Min, 0)
                Cfg.Max = IntegerValue(Cfg.Max, Cfg.Min)
                if Cfg.Max < Cfg.Min then
                    Cfg.Max = Cfg.Min
                end
                Cfg.Intervals = math.max(1, IntegerValue(Cfg.Intervals, 1))
                Cfg.Value = IntegerValue(math.clamp(Library:Round(number, Cfg.Intervals), Cfg.Min, Cfg.Max), Cfg.Min)
                local range = Cfg.Max - Cfg.Min
                Items.Accent.Size = dim2(range > 0 and (Cfg.Value - Cfg.Min) / range or 0, Cfg.Value == Cfg.Min and 0 or -2, 1, -2)
                Items.Value.Text = Cfg.Formatter and Cfg.Formatter(Cfg.Value) or (string.format("%d", Cfg.Value) .. Cfg.Suffix)
                Flags[Cfg.Flag] = Cfg.Value
                Cfg.Callback(Flags[Cfg.Flag])
            end
            Items.Holder.MouseButton1Down:Connect(function()
                Cfg.Dragging = true
            end)
            Items.Minus.MouseButton1Down:Connect(function()
                Cfg.Value -= Cfg.Intervals
                Cfg.Set(Cfg.Value)
            end)
            Items.Plus.MouseButton1Down:Connect(function()
                Cfg.Value += Cfg.Intervals
                Cfg.Set(Cfg.Value)
            end)
            Library:Connection(InputService.InputChanged, function(input)
                if Cfg.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local Size = (input.Position.X - Items.Holder.AbsolutePosition.X) / Items.Holder.AbsoluteSize.X
                    local Value = ((Cfg.Max - Cfg.Min) * Size) + Cfg.Min
                    Cfg.Set(Value)
                end
            end)
            Library:Connection(InputService.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Cfg.Dragging = false
                end
            end)
            Items.Value.Focused:Connect(function()
                Library:Tween(Items.Value, {TextColor3 = themes.preset.accent})
            end)
            Items.Value.FocusLost:Connect(function()
                Library:Tween(Items.Value, {TextColor3 = rgb(205, 205, 205)})
                Cfg.Set(Items.Value.Text)
            end)
            Cfg.Set(Cfg.Value)
            ConfigFlags[Cfg.Flag] = Cfg.Set
            return RegisterUIElement(self, "slider", setmetatable(Cfg, Library))
        end
        function Library:Dropdown(properties)
            local Cfg = {
                Name = properties.Name or nil;
                Flag = properties.Flag or properties.Name or "Dropdown";
                Options = properties.Options or {""};
                Callback = properties.Callback or function() end;
                Multi = properties.Multi or false;
                MinSelected = properties.MinSelected or 0;
                Scrolling = properties.Scrolling or false;
                Open = false;
                OptionInstances = {};
                MultiItems = {};
                Items = {};
                Tweening = false;
                Ignore = properties.Ignore or false;
            }
            Cfg.Default = properties.Default or (Cfg.Multi and {Cfg.Items[1]}) or Cfg.Items[1] or "None"
            Flags[Cfg.Flag] = Cfg.Default
            local Items = Cfg.Items; do
                    Items.Dropdown = Library:Create( "TextButton" , {
                        Active = false;
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "";
                        AutoButtonColor = false;
                        Parent = self.Items.Elements;
                        Name = "\0";
                        BackgroundTransparency = 1;
                        Size = dim2(1, 0, 0, 8);
                        Selectable = false;
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Items.Title = Library:Create( "TextLabel" , {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                        TextColor3 = rgb(205, 205, 205);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = Cfg.Name;
                        Parent = Items.Dropdown;
                        Name = "\0";
                        AutomaticSize = Enum.AutomaticSize.XY;
                        BackgroundTransparency = 1;
                        Position = dim2(0, 20, 0, -2);
                        BorderSizePixel = 0;
                        ZIndex = 2;
                        TextSize = 13;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Items.Outline = Library:Create( "TextButton" , {
                        Parent = Items.Dropdown;
                        Text = "";
                        AutoButtonColor = false;
                        Name = "\0";
                        Position = dim2(0, 20, 0, 13);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -55, 0, 20);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(12, 12, 12)
                    });
                    Items.Accent = Library:Create( "Frame" , {
                        Parent = Items.Outline;
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        ClipsDescendants = true;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Items.DropdownGradient = Library:Create( "UIGradient" , {
                        Rotation = 90;
                        Parent = Items.Accent;
                        Color = rgbseq{rgbkey(0, rgb(31, 31, 31)), rgbkey(1, rgb(36, 36, 36))}
                    });
                    Items.InnerText = Library:Create( "TextLabel" , {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                        TextColor3 = rgb(205, 205, 205);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "-";
                        Parent = Items.Accent;
                        Name = "\0";
                        Size = dim2(1, -12, 1, 0);
                        BackgroundTransparency = 1;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextTruncate = Enum.TextTruncate.AtEnd;
                        ClipsDescendants = true;
                        BorderSizePixel = 0;
                        ZIndex = 2;
                        TextSize = 13;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Library:Create( "UIPadding" , {
                        PaddingLeft = dim(0, 5);
                        Parent = Items.InnerText
                    });
                    Items.Arrow = Library:Create( "ImageLabel" , {
                        BorderColor3 = rgb(0, 0, 0);
                        Parent = Items.Accent;
                        AnchorPoint = vec2(1, 0.5);
                        Image = "rbxassetid://83504953088675";
                        BackgroundTransparency = 1;
                        Position = dim2(1, -5, 0.5, 0);
                        Size = dim2(0, 5, 0, 4);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Items.DropdownElements = Library:Create( "Frame" , {
                        Parent = Library.Items;
                        Size = dim2(0, 132, 0, 47);
                        Name = "\0";
                        Visible = false;
                        Position = dim2(0.6994267702102661, 0, 0.370685338973999, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        BorderSizePixel = 0;
                        ZIndex = 4;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        BackgroundColor3 = rgb(12, 12, 12)
                    });
                    Items.DropdownHolder = Library:Create( "Frame" , {
                        Parent = Items.DropdownElements;
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        ZIndex = 4;
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(35, 35, 35)
                    });
                    Library:Create( "UIPadding" , {
                        PaddingBottom = dim(0, 1);
                        Parent = Items.DropdownHolder
                    });
                    Library:Create( "UIListLayout" , {
                        Parent = Items.DropdownHolder;
                        SortOrder = Enum.SortOrder.LayoutOrder
                    });
                    table.insert(Library.NoDrag, Items.DropdownElements);
                    table.insert(Library.NoDrag, Items.Outline);
            end
            function Cfg.RenderOption(text)
                local Button = Library:Create( "TextButton" , {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                    TextColor3 = rgb(205, 205, 205);
                    AutoButtonColor = false;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = text;
                    Parent = Items.DropdownHolder;
                    ClipsDescendants = true;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    Size = dim2(1, 0, 0, 0);
                    Name = "\0";
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    ZIndex = 4;
                    TextSize = 13;
                    BackgroundColor3 = rgb(26, 26, 26)
                });
                Library:Create( "UIPadding" , {
                    PaddingTop = dim(0, 5);
                    PaddingBottom = dim(0, 5);
                    Parent = Button;
                    PaddingRight = dim(0, 5);
                    PaddingLeft = dim(0, 5)
                });
                table.insert(Cfg.OptionInstances, Button)
                return Button
            end
            function Cfg.SetVisible(bool)
                -- Popup may be destroyed (element/section removed, Lua script cleanup):
                -- Parent is locked then, and reparenting spams errors on every click.
                if Cfg.__removed or not Items.DropdownElements or Items.DropdownElements.Parent == nil then
                    return
                end
                if Library.OpenElement ~= Cfg then
                    Library:CloseElement(Cfg)
                end
                Items.DropdownElements.Position = dim2(0, Items.Outline.AbsolutePosition.X, 0, Items.Outline.AbsolutePosition.Y + 80)
				Items.DropdownElements.Size = dim_offset(Items.Outline.AbsoluteSize.X + 1, 0)
                Items.DropdownElements.Visible = bool
                Items.DropdownElements.Parent = bool and Library.Items or Library.Other
                Items.DropdownGradient.Color = bool and rgbseq{rgbkey(0, rgb(41, 41, 41)), rgbkey(1, rgb(46, 46, 46))} or rgbseq{rgbkey(0, rgb(31, 31, 31)), rgbkey(1, rgb(36, 36, 36))}
                Items.Arrow.Rotation = bool and 180 or 0
                Library.OpenElement = Cfg
            end
            function Cfg.Set(value)
                local Selected = {}
                local IsTable = type(value) == "table"
                for _,option in Cfg.OptionInstances do
                    if option.Text == value or (IsTable and table.find(value, option.Text)) then
                        table.insert(Selected, option.Text)
                        Cfg.MultiItems = Selected
                        option.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
                        option.TextColor3 = themes.preset.accent
                        option.BackgroundTransparency = 1
                    else
                        option.TextColor3 = rgb(205, 205, 205)
                        option.BackgroundTransparency = 0
                        option.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                    end
                end
                Items.InnerText.Text = if IsTable then (#Selected > 0 and table.concat(Selected, ", ") or "None") else Selected[1] or ""
                Flags[Cfg.Flag] = if IsTable then Selected else Selected[1]
                Cfg.Callback(Flags[Cfg.Flag])
            end
            function Cfg.RefreshOptions(options)
                Cfg.Options = options
                for _,option in Cfg.OptionInstances do
                    option:Destroy()
                end
                Cfg.OptionInstances = {}
                for _,option in options do
                    local Button = Cfg.RenderOption(option)
                    Button.MouseButton1Down:Connect(function()
                        if Cfg.Multi then
                            local Selected = table.find(Cfg.MultiItems, Button.Text)
                            if Selected then
                                if Cfg.MinSelected and #Cfg.MultiItems <= Cfg.MinSelected then
                                    return
                                end
                                table.remove(Cfg.MultiItems, Selected)
                            else
                                table.insert(Cfg.MultiItems, Button.Text)
                            end
                            Cfg.Set(Cfg.MultiItems)
                        else
                            Cfg.SetVisible(false)
                            Cfg.Open = false
                            Cfg.Set(Button.Text)
                        end
                    end)
                end
            end
            Items.Outline.MouseButton1Click:Connect(function()
                Cfg.Open = not Cfg.Open
                Cfg.SetVisible(Cfg.Open)
            end)
            local DropdownInputConnection
            DropdownInputConnection = Library:Connection(InputService.InputBegan, function(input, game_event)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if Cfg.__removed or not Items.DropdownElements or Items.DropdownElements.Parent == nil then
                        if DropdownInputConnection then
                            DropdownInputConnection:Disconnect()
                        end
                        return
                    end
                    if not Library:Hovering({Items.DropdownElements, Items.Dropdown}) then
                        Cfg.SetVisible(false)
                        Cfg.Open = false
                    end
                end
            end)
            Items.DropdownElements.Destroying:Connect(function()
                if DropdownInputConnection then
                    DropdownInputConnection:Disconnect()
                end
            end)
            Flags[Cfg.Flag] = {}
            ConfigFlags[Cfg.Flag] = Cfg.Set
            Cfg.RefreshOptions(Cfg.Options)
            Cfg.Set(Cfg.Default)
            table.insert(Library.AllDropdowns, Cfg)
            return RegisterUIElement(self, Cfg.Multi and "multiselect" or "combobox", setmetatable(Cfg, Library))
        end
        function Library:Label(properties)
            local Cfg = {
                Name = properties.Name or "Label",
                Items = {};
            }
            local Items = Cfg.Items; do
                Items.Label = Library:Create( "Frame" , {
                    Parent = self.Items.Elements;
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 8);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Items.Title = Library:Create( "TextLabel" , {
                    TextWrapped = true;
                    Parent = Items.Label;
                    ZIndex = 2;
                    TextSize = 13;
                    Size = dim2(1, -55, 0, 0);
                    RichText = true;
                    TextColor3 = rgb(205, 205, 205);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = Cfg.Name;
                    Name = "\0";
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    Position = dim2(0, 21, 0, -2);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Items.Components = Library:Create( "Frame" , {
                    Parent = Items.Label;
                    Name = "\0";
                    Position = dim2(1, 0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 0, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Library:Create( "UIListLayout" , {
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalAlignment = Enum.HorizontalAlignment.Right;
                    Parent = Items.Components;
                    Padding = dim(0, 3);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
            end
            function Cfg.Set(Text)
                Cfg.Name = Text
                if Items.Title then Items.Title.Text = Text end
            end
            return RegisterUIElement(self, "label", setmetatable(Cfg, Library))
        end
        function Library:Colorpicker(properties)
            local Cfg = {
                Name = properties.Name or "Color",
                Flag = properties.Flag or properties.Name or "Colorpicker",
                Callback = properties.Callback or function() end,
                Color = properties.Color or color(1, 1, 1),  
                Alpha = properties.Alpha or properties.Transparency or 0,
                Open = false;
                Mode = properties.Mode or "Animation";
                Items = {};
            }
            local Picker = self:Keypicker(Cfg)
            local Items = Picker.Items; do
                Cfg.Items = Items
                Cfg.Set = Picker.Set
            end;
            Cfg.Set(Cfg.Color, Cfg.Alpha)
            ConfigFlags[Cfg.Flag] = Cfg.Set
            return setmetatable(Cfg, Library)
        end
        function Library:Textbox(properties)
            local Cfg = {
                Name = properties.Name;
                PlaceHolder = properties.PlaceHolder or properties.PlaceHolderText or properties.Holder or properties.HolderText or "Type here...";
                Default = properties.Default or "";
                Flag = properties.Flag or properties.Name or "TextBox";
                Callback = properties.Callback or function() end;
                Clear = properties.ClearTextOnFocus or false;
                Items = {};
            }
            Flags[Cfg.Flag] = Cfg.Default
            local Items = Cfg.Items; do
                Items.List = Library:Create( "TextButton" , {
                    Active = false;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    AutoButtonColor = false;
                    Parent = self.Items.Elements;
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 10);
                    Selectable = false;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Items.Textbox = Library:Create( "Frame" , {
                    Parent = Items.List;
                    Size = dim2(1, -55, 0, 20);
                    Name = "\0";
                    Position = dim2(0, 20, 0, -1);
                    BorderColor3 = rgb(0, 0, 0);
                    ZIndex = 2;
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(13, 13, 13)
                });
                Items.Inline = Library:Create( "Frame" , {
                    Parent = Items.Textbox;
                    Size = dim2(1, -2, 1, -2);
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    ZIndex = 2;
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(53, 53, 53)
                });
                Items.ExtraInline = Library:Create( "Frame" , {
                    Parent = Items.Inline;
                    Size = dim2(1, -2, 1, -2);
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    ZIndex = 2;
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(17, 17, 17)
                });
                Items.Background = Library:Create( "TextBox" , {
                    Parent = Items.ExtraInline;
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                    BorderSizePixel = 0;
                    ClipsDescendants = true;
                    ClearTextOnFocus = Cfg.Clear;
                    TextColor3 = rgb(205, 205, 205);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    CursorPosition = -1;
                    TextStrokeTransparency = 1;
                    Size = dim2(1, -2, 1, -2);
                    Selectable = false;
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    Active = false;
                    ZIndex = 2;
                    TextSize = 13;
                    BackgroundColor3 = rgb(26, 26, 26)
                });
            end
            function Cfg.Set(text)
                Flags[Cfg.Flag] = text
                Items.Background.Text = text
                Cfg.Callback(text)
            end
            Items.Background.Focused:Connect(function()
                Library:Tween(Items.Background, {TextColor3 = themes.preset.accent})
                Items.Background.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            end)
            Items.Background.FocusLost:Connect(function()
                Library:Tween(Items.Background, {TextColor3 = rgb(205, 205, 205)})
                Items.Background.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
            end)
            Items.Background:GetPropertyChangedSignal("Text"):Connect(function()
                Cfg.Set(Items.Background.Text)
            end)
            if Cfg.Default then
                Cfg.Set(Cfg.Default)
            end
            ConfigFlags[Cfg.Flag] = Cfg.Set
            return RegisterUIElement(self, "textbox", setmetatable(Cfg, Library))
        end
        function Library:Keybind(properties)
            local Cfg = {
                Flag = properties.Flag or properties.Name;
                Callback = properties.Callback or function() end;
                Name = properties.Name or nil;
                Key = properties.Key or nil;
                Mode = properties.Mode or "Hold";
                Active = properties.Default or false;
                Show = properties.ShowInList or true;
                Open = false;
                Binding;
                Ignore = false;
                Items = {}
            }
            Flags[Cfg.Flag] = {
                Mode = Cfg.Mode,
                Key = Cfg.Key,
                Active = Cfg.Active
            }
            local Items = Cfg.Items; do
                    Items.Keybind = Library:Create( "TextButton" , {
                        Parent = self.Items.Components;
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                        Name = "\0";
                        TextColor3 = rgb(170, 170, 170);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "[T]";
                        AutomaticSize = Enum.AutomaticSize.XY;
                        Selectable = false;
                        AnchorPoint = vec2(0.5, 0);
                        BorderSizePixel = 0;
                        BackgroundTransparency = 1;
                        Position = dim2(1, 0, 0.10000000149011612, 0);
                        Active = true;
                        AutoButtonColor = false;
                        ZIndex = 2;
                        TextSize = 11;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Items.KeybindOutline = Library:Create( "Frame" , {
                        Parent = Library.Items;
                        Visible = false;
                        Size = dim2(0, 100, 0, 22);
                        Name = "\0";
                        Position = dim2(0.8264937996864319, 0, 0.33450964093208313, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        BackgroundColor3 = rgb(12, 12, 12)
                    });
                    Items.Inline = Library:Create( "Frame" , {
                        Parent = Items.KeybindOutline;
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(35, 35, 35)
                    });
                    Library:Create( "UIListLayout" , {
                        Parent = Items.Inline;
                        SortOrder = Enum.SortOrder.LayoutOrder
                    });
                    Items.Toggle = Library:Create( "TextButton" , {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                        TextColor3 = rgb(205, 205, 205);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "Toggle";
                        Parent = Items.Inline;
                        ClipsDescendants = true;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        Size = dim2(1, 0, 0, 0);
                        Name = "\0";
                        TextXAlignment = Enum.TextXAlignment.Left;
                        BorderSizePixel = 0;
                        ZIndex = 2;
                        TextSize = 13;
                        BackgroundColor3 = rgb(26, 26, 26)
                    });
                    Library:Create( "UIPadding" , {
                        PaddingTop = dim(0, 5);
                        PaddingBottom = dim(0, 5);
                        Parent = Items.Toggle;
                        PaddingRight = dim(0, 5);
                        PaddingLeft = dim(0, 5)
                    });
                    Items.Hold = Library:Create( "TextButton" , {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                        TextColor3 = rgb(205, 205, 205);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "Hold";
                        Parent = Items.Inline;
                        ClipsDescendants = true;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        Size = dim2(1, 0, 0, 0);
                        Name = "\0";
                        TextXAlignment = Enum.TextXAlignment.Left;
                        BorderSizePixel = 0;
                        ZIndex = 2;
                        TextSize = 13;
                        BackgroundColor3 = rgb(26, 26, 26)
                    });
                    Library:Create( "UIPadding" , {
                        PaddingTop = dim(0, 5);
                        PaddingBottom = dim(0, 5);
                        Parent = Items.Hold;
                        PaddingRight = dim(0, 5);
                        PaddingLeft = dim(0, 5)
                    });
                    Items.Always = Library:Create( "TextButton" , {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
                        Parent = Items.Inline;
                        TextColor3 = rgb(142, 181, 39);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "Always";
                        Name = "\0";
                        AutomaticSize = Enum.AutomaticSize.Y;
                        Size = dim2(1, 0, 0, 0);
                        ClipsDescendants = true;
                        BackgroundTransparency = 1;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        BorderSizePixel = 0;
                        ZIndex = 2;
                        TextSize = 13;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    Library:Create( "UIPadding" , {
                        PaddingTop = dim(0, 5);
                        PaddingBottom = dim(0, 5);
                        Parent = Items.Always;
                        PaddingRight = dim(0, 5);
                        PaddingLeft = dim(0, 5)
                    });
                    Items.Off = Library:Create( "TextButton" , {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                        TextColor3 = rgb(205, 205, 205);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "Off hotkey";
                        Parent = Items.Inline;
                        ClipsDescendants = true;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        Size = dim2(1, 0, 0, 0);
                        Name = "\0";
                        TextXAlignment = Enum.TextXAlignment.Left;
                        BorderSizePixel = 0;
                        ZIndex = 2;
                        TextSize = 13;
                        BackgroundColor3 = rgb(26, 26, 26)
                    });
                    Library:Create( "UIPadding" , {
                        PaddingTop = dim(0, 5);
                        PaddingBottom = dim(0, 5);
                        Parent = Items.Off;
                        PaddingRight = dim(0, 5);
                        PaddingLeft = dim(0, 5)
                    });
                    for _,mode in {"Always", "Toggle", "Hold", "Off"} do
                        Items[mode].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                        Items[mode].BackgroundTransparency = 0;
                        Items[mode].TextColor3 = rgb(205, 205, 205)
                        Items[mode].MouseButton1Click:Connect(function()
                            for _,extra in {"Always", "Toggle", "Hold", "Off"} do
                                Items[extra].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                                Items[extra].BackgroundTransparency = 0;
                                Items[extra].TextColor3 = rgb(205, 205, 205)
                            end
                            Items[mode].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                            Items[mode].BackgroundTransparency = 1;
                            Items[mode].TextColor3 = themes.preset.accent
                            Cfg.Set(mode)
                        end)
                    end
            end
            local function UpdateModeVisuals()
                for _, mode in {"Always", "Toggle", "Hold", "Off"} do
                    if Items[mode] then
                        Items[mode].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", mode == Cfg.Mode and Enum.FontWeight.Bold or Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                        Items[mode].BackgroundTransparency = mode == Cfg.Mode and 1 or 0
                        Items[mode].TextColor3 = mode == Cfg.Mode and themes.preset.accent or rgb(205, 205, 205)
                    end
                end
            end
            local function KeyText(key)
                if key == nil or key == "NONE" or key == Enum.KeyCode.Escape then
                    return "NONE"
                end
                local text = Keys[key] or tostring(key):gsub("Enum.", "")
                return tostring(text):gsub("KeyCode.", ""):gsub("UserInputType.", "")
            end
            local function NormalizeKey(key)
                if key == nil or key == "NONE" or key == "Enum.KeyCode.Unknown" or key == "Unknown" then
                    return "NONE"
                end
                if typeof(key) == "EnumItem" then
                    return key == Enum.KeyCode.Escape and "NONE" or key
                end
                if type(key) == "string" then
                    if key == "Escape" or key == "Enum.KeyCode.Escape" or key == "NONE" then
                        return "NONE"
                    end
                    if key:find("Enum", 1, true) then
                        local success, enumItem = pcall(function()
                            return Library:ConvertEnum(key)
                        end)
                        if success and enumItem then
                            return enumItem == Enum.KeyCode.Escape and "NONE" or enumItem
                        end
                    end
                    local success, enumItem = pcall(function()
                        return Enum.KeyCode[key]
                    end)
                    if success and enumItem then
                        return enumItem == Enum.KeyCode.Escape and "NONE" or enumItem
                    end
                    local success2, enumItem2 = pcall(function()
                        return Enum.UserInputType[key]
                    end)
                    if success2 and enumItem2 then
                        return enumItem2
                    end
                end
                return key
            end
            function Cfg.SetMode(mode)
                if not table.find({"Toggle", "Hold", "Always", "Off"}, mode) then
                    mode = "Hold"
                end
                Cfg.Mode = mode
                if Cfg.Mode == "Always" then
                    Cfg.Active = true
                elseif Cfg.Mode == "Hold" then
                    Cfg.Active = false
                elseif Cfg.Mode == "Off" then
                    -- Off hotkey: работает, пока клавиша НЕ зажата.
                    Cfg.Active = not Cfg.KeyHeld
                end
                UpdateModeVisuals()
            end
            function Cfg.Set(input)
                if type(input) == "boolean" then
                    Cfg.Active = input
                    if Cfg.Mode == "Always" then
                        Cfg.Active = true
                    end
                elseif typeof(input) == "EnumItem" then
                    Cfg.Key = NormalizeKey(input)
                elseif table.find({"Toggle", "Hold", "Always", "Off"}, input) then
                    Cfg.SetMode(input)
                elseif type(input) == "table" then
                    local key = input.key ~= nil and input.key or input.Key
                    local mode = input.mode ~= nil and input.mode or input.Mode
                    local active = input.active ~= nil and input.active or input.Active
                    Cfg.Key = NormalizeKey(key)
                    Cfg.SetMode(mode or Cfg.Mode or "Hold")
                    if active ~= nil then
                        Cfg.Active = active and true or false
                    end
                    if Cfg.Mode == "Always" then
                        Cfg.Active = true
                    elseif Cfg.Mode == "Hold" and active == nil then
                        Cfg.Active = false
                    elseif Cfg.Mode == "Off" and active == nil then
                        Cfg.Active = not Cfg.KeyHeld
                    end
                elseif type(input) == "string" then
                    Cfg.Key = NormalizeKey(input)
                end
                local __text = KeyText(Cfg.Key)
                Items.Keybind.Text = "[" .. __text .. "]"
                if Items.Keybinds then
                    Items.Keybinds.TextTransparency = 1
                    Library:Tween(Items.Keybinds, {TextTransparency = 0})
                    if Items.KeybindsStroke then
                        Items.KeybindsStroke.Transparency = 1
                        Library:Tween(Items.KeybindsStroke, {Transparency = 0})
                    end
                    Items.Keybinds.Visible = Cfg.Active
                    Items.Keybinds.Text = string.format("[%s]: %s", __text, Cfg.Name or Cfg.Flag or "Key")
                end
                Flags[Cfg.Flag] = {
                    mode = Cfg.Mode,
                    key = Cfg.Key,
                    active = Cfg.Active
                }
                Cfg.Callback(Cfg.Active)
            end
            function Cfg.SetVisible(bool)
                if Cfg.__removed or not Items.KeybindOutline or Items.KeybindOutline.Parent == nil then
                    return
                end
                Items.KeybindOutline.Visible = bool
                Items.KeybindOutline.Parent = bool and Library.Items or Library.Other
                Items.KeybindOutline.Position = dim2(0, Items.Keybind.AbsolutePosition.X + 2, 0, Items.Keybind.AbsolutePosition.Y + 74)
            end
            Items.Keybind.MouseButton1Down:Connect(function()
                task.wait()
                Items.Keybind.Text = "[...]"
                if Cfg.Binding then
                    Cfg.Binding:Disconnect()
                    Cfg.Binding = nil
                end
                Cfg.Binding = Library:Connection(InputService.InputBegan, function(keycode, game_event)
                    local selected = keycode.KeyCode ~= Enum.KeyCode.Unknown and keycode.KeyCode or keycode.UserInputType
                    Cfg.Set(selected)
                    if Cfg.Binding then
                        Cfg.Binding:Disconnect()
                        Cfg.Binding = nil
                    end
                end)
            end)
            Items.Keybind.MouseButton2Down:Connect(function()
                Cfg.Open = not Cfg.Open
                Cfg.SetVisible(Cfg.Open)
            end)
            Library:Connection(InputService.InputBegan, function(input, game_event)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if Cfg.Open and not Library:Hovering({Items.KeybindOutline, Items.Keybind}) then
                        Cfg.SetVisible(false)
                        Cfg.Open = false
                    end
                end
                if not game_event then
                    local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
                    if selected_key == Cfg.Key then
                        Cfg.KeyHeld = true
                        if Cfg.Mode == "Toggle" then
                            Cfg.Set(not Cfg.Active)
                        elseif Cfg.Mode == "Hold" then
                            Cfg.Set(true)
                        elseif Cfg.Mode == "Off" then
                            Cfg.Set(false)
                        end
                    end
                end
            end)
            Library:Connection(InputService.InputEnded, function(input, game_event)
                if game_event then
                    return
                end
                local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
                if selected_key == Cfg.Key then
                    Cfg.KeyHeld = false
                    if Cfg.Mode == "Hold" then
                        Cfg.Set(false)
                    elseif Cfg.Mode == "Off" then
                        Cfg.Set(true)
                    end
                end
            end)
            Cfg.Set({mode = Cfg.Mode, active = Cfg.Active, key = Cfg.Key})
            ConfigFlags[Cfg.Flag] = Cfg.Set
            return RegisterUIElement(self, "hotkey", setmetatable(Cfg, Library))
        end
        function Library:Button(properties)
            local Cfg = {
                Name = properties.Name or "TextBox",
                Callback = properties.Callback or function() end,
                Items = {};
            }
            local Items = Cfg.Items; do
                Items.Button = Library:Create( "TextButton" , {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                    TextColor3 = rgb(0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    Parent = self.Items.GroupElements or self.Items.Elements;
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    TextSize = 14;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Items.Outline = Library:Create( "Frame" , {
                    Name = "\0";
                    Parent = Items.Button;
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 0, 18);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.outline
                });	Library:Themify(Items.Outline, "outline", "BackgroundColor3")
                Items.Inline = Library:Create( "Frame" , {
                    Parent = Items.Outline;
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.inline
                });	Library:Themify(Items.Inline, "inline", "BackgroundColor3")
                Items.Background = Library:Create( "Frame" , {
                    Parent = Items.Inline;
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                local gradient = Library:Create( "UIGradient" , {
                    Rotation = 90;
                    Parent = Items.Background;
                    Color = rgbseq{rgbkey(0, themes.preset.inline), rgbkey(1, themes.preset.gradient)}
                }); Library:SaveGradient(gradient, "Selected");
                Items.Name = Library:Create( "TextLabel" , {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                    TextColor3 = themes.preset.text_color;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = Cfg.Name;
                    Parent = Items.Background;
                    Name = "\0";
                    Size = dim2(1, 0, 1, 0);
                    BackgroundTransparency = 1;
                    Position = dim2(0, 3, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 13;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Library:Create( "UIStroke" , {
                    Parent = Items.Name;
                    LineJoinMode = Enum.LineJoinMode.Miter
                });
            end
            Items.Button.MouseButton1Click:Connect(function()
                Items.Name.TextColor3 = rgb(255, 255, 255)
                Library:Tween(Items.Name, {TextColor3 = themes.preset.text_color})
                Cfg.Callback()
            end)
            return RegisterUIElement(self, "button", setmetatable(Cfg, Library))
        end
        function Notifications:RefreshNotifications()
            local offset = 50
            for i, v in Notifications.Notifs do
                local Position = vec2(20, offset)
                Library:Tween(v, {Position = dim_offset(Position.X, Position.Y)})
                offset += (v.AbsoluteSize.Y + 10)
            end
            return offset
        end
        function Notifications:FadeNotifs(path, is_fading)
            local fading = is_fading and 1 or 0
            Library:Tween(path, {BackgroundTransparency = fading})
            for _, instance in path:GetDescendants() do
                if not instance:IsA("GuiObject") then
                    if instance:IsA("UIStroke") then
                        Library:Tween(instance, {Transparency = fading})
                    end
                    continue
                end
                if instance:IsA("TextLabel") then
                    Library:Tween(instance, {TextTransparency = fading})
                elseif instance:IsA("Frame") then
                    Library:Tween(instance, {BackgroundTransparency = instance.Transparency and 0.6 and is_fading and 1 or 0.6})
                end
            end
        end
        function Notifications:Create(properties)
            local Cfg = {
                Name = properties.Name or "This is a title!";
                Lifetime = properties.LifeTime or 3;
                Items = {};
                outline;
            }
            local Items = Cfg.Items; do
                Items.Outline = Library:Create( "Frame" , {
                    Parent = Library.Items;
                    Size = dim2(0, 0, 0, 18);
                    Name = "\0";
                    AnchorPoint = vec2(1, 0);
                    Position = dim2(0, 7, 0, 46);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundColor3 = rgb(52, 52, 52)
                });
                Items.Inline = Library:Create( "Frame" , {
                    Parent = Items.Outline;
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundColor3 = rgb(5, 5, 5)
                });
                Library:Create( "UIPadding" , {
                    PaddingTop = dim(0, 7);
                    PaddingBottom = dim(0, 6);
                    Parent = Items.Inline;
                    PaddingRight = dim(0, 8);
                    PaddingLeft = dim(0, 4)
                });
                Items.Text = Library:Create( "TextLabel" , {
                    FontFace = Library.Font;
                    Parent = Items.Inline;
                    TextColor3 = rgb(255, 255, 255);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = Cfg.Name;
                    Name = "\0";
                    AutomaticSize = Enum.AutomaticSize.XY;
                    Size = dim2(1, -4, 1, 0);
                    Position = dim2(0, 4, 0, -2);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    ZIndex = 2;
                    TextSize = 12;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                Library:Create( "UIPadding" , {
                    PaddingBottom = dim(0, 1);
                    PaddingRight = dim(0, 1);
                    Parent = Items.Outline
                });
                Items.AccentLine = Library:Create( "Frame" , {
                    Parent = Items.Outline;
                    Name = "\0";
                    Position = dim2(0, 2, 1, -1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -1, 0, 1);
                    BorderSizePixel = 0;
                    ZIndex = 100;
                    BackgroundColor3 = themes.preset.accent
                });	Library:Themify(Items.AccentLine, "accent", "BackgroundColor3")
                Items.Accent = Library:Create( "Frame" , {
                    Parent = Items.Outline;
                    Name = "\0";
                    ZIndex = 100;
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 1, 1, -1);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.accent
                });	Library:Themify(Items.Accent, "accent", "BackgroundColor3")
            end
            local index = #Notifications.Notifs + 1
            Notifications.Notifs[index] = Items.Outline
            local offset = Notifications:RefreshNotifications()
            Items.Outline.Position = dim_offset(20, offset)
            Library:Tween(Items.Outline, {AnchorPoint = vec2(0, 0)})
            Library:Tween(Items.AccentLine, {Size = dim2(0, -2, 0, 1)}, TweenInfo.new(Cfg.Lifetime, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, 0))
            task.spawn(function()
                task.wait(Cfg.Lifetime)
                Notifications.Notifs[index] = nil
                Notifications:FadeNotifs(Items.Outline, true)
                Library:Tween(Items.Outline, {AnchorPoint = vec2(1, 0)})
                task.wait(1)
                Items.Outline:Destroy()
            end)
        end
local Window = Library:Window({})
local Tabs = {
    Rage = Window:Tab({Icon = "rbxassetid://8547236654"}),
    Aiming = Window:Tab({Icon = "rbxassetid://8547249956"}),
    Lighting = Window:Tab({Icon = "rbxassetid://8547254518"}),
    Settings = Window:Tab({Icon = "rbxassetid://8547256547"}),
    Skins = Window:Tab({Icon = "rbxassetid://8547258459"}),
    Saving = Window:Tab({Icon = "rbxassetid://107672994153530"}),
    Lua = Window:Tab({Icon = "rbxassetid://83653738255058"}),
    Giver = Window:Tab({Icon = "rbxassetid://107672994153530"}),
}
Library.Registry = Library.Registry or {}
Library.TabsByName = Library.TabsByName or {}
for name, tab in Tabs do
    tab.RegistryName = string.lower(name)
    Library.TabsByName[string.lower(name)] = tab
end
Library.TabAliases = {
    ragebot = "rage",
    legit = "aiming",
    legitbot = "aiming",
    aa = "rage",
    antiaim = "rage",
    visuals = "lighting",
    visual = "lighting",
    esp = "lighting",
    misc = "settings",
    players = "skins",
    playerlist = "skins",
    config = "saving",
    configs = "saving",
    scripts = "lua",
}
local function BindVisibility(Toggle, Elements)
    local Instances = {}
    for _, element in Elements do
        local instance = element.Items.Slider
            or element.Items.Toggle
            or element.Items.Dropdown
            or element.Items.Label
        if instance then
            table.insert(Instances, instance)
        end
    end
    local Previous = Toggle.Callback
    local function Refresh(bool)
        for _, instance in Instances do
            instance.Visible = bool
        end
    end
    Toggle.Callback = function(bool)
        Refresh(bool)
        if Previous then
            Previous(bool)
        end
    end
    Refresh(Toggle.Enabled)
end
local AddMenuBind
do
    function AddMenuBind(TargetToggle, FlagName, NoToggleState)
        local bindMode = "Hold"
        local boundKey = nil
        local bindActive = false
        local binding = false
        local blockBindClick = false
        local blockBindClick2 = false

        local function HasKey()
            return boundKey ~= nil and boundKey ~= "NONE"
        end

        local keyHeld = false
        local function ComputeActive(state)
            if not TargetToggle.Enabled then
                return false
            end
            if bindMode == "Always" then
                return true
            end
            if boundKey == nil or boundKey == "NONE" then
                -- Без клавиши Off hotkey выключить нечем - он работает.
                return bindMode == "Off"
            end
            if bindMode == "Off" then
                -- Off hotkey: работает, пока клавиша НЕ зажата.
                return not keyHeld
            end
            return state == true
        end

        local function ApplyState(state)
            bindActive = state == true
            local active = ComputeActive(bindActive)
            Flags[FlagName] = {
                Key = boundKey and tostring(boundKey) or "NONE";
                Mode = bindMode;
                Active = active;
            }
        end

        local prevToggleCallback = TargetToggle.Callback
        TargetToggle.Callback = function(state, ...)
            if prevToggleCallback then
                prevToggleCallback(state, ...)
            end
            ApplyState(bindActive)
        end

        local BindButton = Library:Create("TextButton", {
            Active = false;
            AutoButtonColor = false;
            Parent = TargetToggle.Items.Components;
            Name = "";
            Text = "[NONE]";
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
            TextColor3 = rgb(170, 170, 170);
            TextSize = 11;
            Size = dim2(0, 32, 0, 9);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            BackgroundColor3 = rgb(12, 12, 12);
            ZIndex = 2;
        })
        local ModeFrame = Library:Create("Frame", {
            Parent = Library.Other;
            Visible = false;
            Size = dim2(0, 100, 0, 88);
            Name = "";
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            ZIndex = 10;
            BackgroundColor3 = rgb(12, 12, 12);
        })
        local ModeInline = Library:Create("Frame", {
            Parent = ModeFrame;
            Name = "";
            Position = dim2(0, 1, 0, 1);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            ZIndex = 10;
            BackgroundColor3 = rgb(35, 35, 35);
        })
        Library:Create("UIListLayout", {
            Parent = ModeInline;
            SortOrder = Enum.SortOrder.LayoutOrder;
        })
        local function CreateModeOption(text)
            local button = Library:Create("TextButton", {
                Parent = ModeInline;
                Name = "";
                Text = text;
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                TextColor3 = rgb(205, 205, 205);
                TextSize = 13;
                TextXAlignment = Enum.TextXAlignment.Left;
                AutoButtonColor = false;
                Size = dim2(1, 0, 0, 22);
                BorderSizePixel = 0;
                ZIndex = 10;
                BackgroundColor3 = rgb(26, 26, 26);
            })
            Library:Create("UIPadding", {
                Parent = button;
                PaddingLeft = dim(0, 5);
                PaddingRight = dim(0, 5);
                PaddingTop = dim(0, 5);
                PaddingBottom = dim(0, 5);
            })
            return button
        end
        local ModeHold = CreateModeOption("Hold")
        local ModeToggle = CreateModeOption("Toggle")
        local ModeAlways = CreateModeOption("Always")
        local ModeOff = CreateModeOption("Off hotkey")
        local function UpdateModeVisuals()
            for _, button in {ModeHold, ModeToggle, ModeAlways, ModeOff} do
                button.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                button.TextColor3 = rgb(205, 205, 205)
                button.BackgroundTransparency = 0
            end
            local selected = bindMode == "Hold" and ModeHold or bindMode == "Toggle" and ModeToggle or bindMode == "Off" and ModeOff or ModeAlways
            selected.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            selected.TextColor3 = themes.preset.accent
            selected.BackgroundTransparency = 1
        end
        local function CloseModeMenu()
            ModeFrame.Visible = false
            ModeFrame.Parent = Library.Other
        end
        table.insert(Library.ExtraClosers, CloseModeMenu)
        local function SetMode(mode)
            bindMode = mode
            if bindMode == "Always" then
                ApplyState(true)
            elseif bindMode == "Hold" then
                ApplyState(false)
            else
                ApplyState(bindActive)
            end
            CloseModeMenu()
        end
        ModeHold.MouseButton1Click:Connect(function()
            SetMode("Hold")
        end)
        ModeToggle.MouseButton1Click:Connect(function()
            SetMode("Toggle")
        end)
        ModeAlways.MouseButton1Click:Connect(function()
            SetMode("Always")
        end)
        ModeOff.MouseButton1Click:Connect(function()
            SetMode("Off")
        end)
        table.insert(Library.NoDrag, ModeFrame)
        table.insert(Library.NoDrag, BindButton)
        BindButton.MouseButton1Click:Connect(function()
            if blockBindClick then
                blockBindClick = false
                return
            end
            if binding then return end
            binding = true
            Library.DragLock = true
            BindButton.Text = "[...]"
            CloseModeMenu()
            local armed = false
            task.defer(function()
                armed = true
            end)
            local connection
            connection = Library:Connection(InputService.InputBegan, function(input)
                if not binding or not armed then return end
                local key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    blockBindClick = true
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    blockBindClick2 = true
                end
                if key == Enum.KeyCode.Escape then
                    boundKey = nil
                    BindButton.Text = "[NONE]"
                else
                    boundKey = key
                    local keyName = Keys[key] or tostring(key):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
                    BindButton.Text = "[" .. keyName .. "]"
                end
                binding = false
                Library.DragLock = false
                connection:Disconnect()
                ApplyState(false)
            end)
        end)
        BindButton.MouseButton2Click:Connect(function()
            if blockBindClick2 then
                blockBindClick2 = false
                return
            end
            if binding then return end
            ModeFrame.Visible = not ModeFrame.Visible
            if ModeFrame.Visible then
                ModeFrame.Parent = Library.Items
                ModeFrame.Position = dim2(0, BindButton.AbsolutePosition.X, 0, BindButton.AbsolutePosition.Y + 74)
                UpdateModeVisuals()
            else
                ModeFrame.Parent = Library.Other
            end
        end)
        Library:Connection(InputService.InputBegan, function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and ModeFrame.Visible and not Library:Hovering(ModeFrame) then
                CloseModeMenu()
            end
            if binding or not boundKey then return end
            local key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
            if key ~= boundKey then return end
            keyHeld = true
            if bindMode == "Toggle" then
                ApplyState(not bindActive)
            elseif bindMode == "Hold" then
                ApplyState(true)
            else
                ApplyState(bindActive)
            end
        end)
        Library:Connection(InputService.InputEnded, function(input, gameProcessed)
            if binding or not boundKey then return end
            local key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
            if key ~= boundKey then return end
            keyHeld = false
            if bindMode == "Hold" then
                ApplyState(false)
            elseif bindMode == "Off" then
                ApplyState(bindActive)
            end
        end)

        local function SetBind(input)
            if type(input) == "table" then
                local key = input.key ~= nil and input.key or input.Key
                local mode = input.mode ~= nil and input.mode or input.Mode
                local active = input.active ~= nil and input.active or input.Active

                if key == nil or key == "NONE" or key == "Enum.KeyCode.Unknown" or key == "Unknown" then
                    boundKey = nil
                    BindButton.Text = "[NONE]"
                else
                    if typeof(key) == "EnumItem" then
                        boundKey = (key == Enum.KeyCode.Escape and nil) or key
                    elseif type(key) == "string" then
                        if key == "Escape" or key == "Enum.KeyCode.Escape" or key == "NONE" then
                            boundKey = nil
                        elseif key:find("Enum", 1, true) then
                            local ok, enumItem = pcall(function() return Library:ConvertEnum(key) end)
                            boundKey = (ok and enumItem ~= Enum.KeyCode.Escape and enumItem) or nil
                        else
                            local ok, enumItem = pcall(function() return Enum.KeyCode[key] end)
                            if not ok or not enumItem then
                                ok, enumItem = pcall(function() return Enum.UserInputType[key] end)
                            end
                            boundKey = (ok and enumItem ~= Enum.KeyCode.Escape and enumItem) or nil
                        end
                    end
                    if boundKey then
                        local keyName = Keys[boundKey] or tostring(boundKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
                        BindButton.Text = "[" .. keyName .. "]"
                    else
                        BindButton.Text = "[NONE]"
                    end
                end

                if mode and table.find({"Hold", "Toggle", "Always", "Off"}, mode) then
                    bindMode = mode
                end
                UpdateModeVisuals()

                if bindMode == "Always" then
                    ApplyState(true)
                elseif bindMode == "Hold" then
                    ApplyState(false)
                elseif bindMode == "Off" then
                    ApplyState(bindActive)
                elseif active ~= nil then
                    ApplyState(active == true)
                else
                    ApplyState(false)
                end
            elseif typeof(input) == "EnumItem" or type(input) == "string" then
                SetBind({key = input, mode = bindMode, active = bindActive})
                return
            elseif type(input) == "boolean" then
                ApplyState(input)
            end
        end

        ApplyState(false)
        ConfigFlags[FlagName] = SetBind
    end
end
-- Профили настроек по группам оружия (Weapon select): у каждой группы свой
    -- набор значений управляемых контролов. Global - обычные флаги; группа без
    -- включённого Override использует Global. Override у Global нет и быть не может.
    local WeaponGroupOptions = {"Global", "Rifles", "SMGs", "Snipers", "Shotguns", "Pistols", "LMG", "Other"}
    local function CopyProfileValue(value)
        if type(value) == "table" then
            local out = {}
            for k, v in pairs(value) do out[k] = v end
            return out
        end
        return value
    end
    local function CreateWeaponProfileUI(Section, Prefix, PriorityFlag)
        local ProfilesFlag = Prefix .. "WeaponProfiles"
        local ui = {Current = "Global", Managed = {}, GlobalValues = {}, Loading = false}
        local function GetProfiles()
            local profiles = Flags[ProfilesFlag]
            if type(profiles) ~= "table" then
                profiles = {}
                Flags[ProfilesFlag] = profiles
            end
            return profiles
        end
        local function GetProfile(group)
            local profiles = GetProfiles()
            local prof = profiles[group]
            if type(prof) ~= "table" then
                prof = {Override = false, Values = {}}
                profiles[group] = prof
            end
            if type(prof.Values) ~= "table" then prof.Values = {} end
            return prof
        end
        function ui.SaveOutgoing()
            local prof = ui.Current ~= "Global" and GetProfile(ui.Current) or nil
            local toProfile = prof and prof.Override == true
            for _, m in ipairs(ui.Managed) do
                if toProfile then
                    prof.Values[m.Flag] = CopyProfileValue(Flags[m.Flag])
                else
                    ui.GlobalValues[m.Flag] = CopyProfileValue(Flags[m.Flag])
                end
            end
        end
        function ui.LoadGroup(group)
            if type(group) ~= "string" or group == "" then group = "Global" end
            ui.Loading = true
            ui.SaveOutgoing()
            ui.Current = group
            local prof = GetProfile(group)
            local useOverride = group ~= "Global" and prof.Override == true
            if ui.OverrideElement then
                ui.OverrideElement.Set(useOverride)
                if ui.OverrideElement.Items and ui.OverrideElement.Items.Toggle then
                    ui.OverrideElement.Items.Toggle.Visible = group ~= "Global"
                end
            end
            for _, m in ipairs(ui.Managed) do
                local value
                if useOverride and prof.Values[m.Flag] ~= nil then
                    value = prof.Values[m.Flag]
                else
                    value = ui.GlobalValues[m.Flag]
                end
                if value ~= nil and m.Element and m.Element.Set then
                    m.Element.Set(CopyProfileValue(value))
                end
            end
            ui.Loading = false
        end
        ui.SelectElement = Section:Dropdown({
            Name = "Weapon select",
            Options = WeaponGroupOptions,
            Default = "Global",
            Flag = Prefix .. "WeaponSelect",
            Callback = function(value)
                if ui.Loading then return end
                if type(value) == "table" then value = value[1] end
                ui.LoadGroup(value)
            end,
        })
        Section:Dropdown({
            Name = "Target priority",
            Options = {"Closest to crosshair", "Lowest health", "Closest distance"},
            Default = "Closest to crosshair",
            Flag = PriorityFlag,
        })
        ui.OverrideElement = Section:Toggle({
            Name = "Override",
            Flag = Prefix .. "WeaponOverride",
            Callback = function(state)
                if ui.Loading then return end
                local group = ui.Current
                if group == "Global" then return end
                local prof = GetProfile(group)
                prof.Override = state == true
                ui.Loading = true
                if state then
                    -- Первое включение: профиль стартует с текущих значений.
                    for _, m in ipairs(ui.Managed) do
                        if prof.Values[m.Flag] == nil then
                            prof.Values[m.Flag] = CopyProfileValue(Flags[m.Flag])
                        end
                    end
                else
                    -- Выключили: контролы показывают глобальные значения.
                    for _, m in ipairs(ui.Managed) do
                        local value = ui.GlobalValues[m.Flag]
                        if value ~= nil and m.Element and m.Element.Set then
                            m.Element.Set(CopyProfileValue(value))
                        end
                    end
                end
                ui.Loading = false
            end,
        })
        if ui.OverrideElement.Items and ui.OverrideElement.Items.Toggle then
            ui.OverrideElement.Items.Toggle.Visible = false
        end
        function ui.Bind(managed)
            ui.Managed = managed or {}
            ui.GlobalValues = {}
            for _, m in ipairs(ui.Managed) do
                ui.GlobalValues[m.Flag] = CopyProfileValue(Flags[m.Flag])
            end
            local selected = Flags[Prefix .. "WeaponSelect"]
            if type(selected) == "string" and selected ~= "Global" then
                ui.LoadGroup(selected)
            end
        end
        return ui
    end
do
    local Page = Tabs.Rage.Items.Page
    for _, child in pairs(Page:GetChildren()) do
        if child:IsA("UIListLayout") then
            child.HorizontalFlex = Enum.UIFlexAlignment.None
        end
    end
    Tabs.Rage.Items.Left.Size = dim2(0.5, -10, 1, 0)
    Tabs.Rage.Items.Right.Size = dim2(0.5, -10, 1, 0)
    for _, child in pairs(Tabs.Rage.Items.Left:GetChildren()) do
        if child:IsA("UIListLayout") then
            child.VerticalFlex = Enum.UIFlexAlignment.None
        end
    end
    for _, child in pairs(Tabs.Rage.Items.Right:GetChildren()) do
        if child:IsA("UIListLayout") then
            child.VerticalFlex = Enum.UIFlexAlignment.None
        end
    end
    local Aimbot = Tabs.Rage:Section({Name = "Aimbot", Side = "Left"})
    local Toggle = Aimbot:Toggle({Name = "Enabled", Flag = "AimbotEnabled"})
    local RageProfiles = CreateWeaponProfileUI(Aimbot, "Rage", "AimbotTargetPriority")
    Aimbot:Dropdown({Name = "Target selection", Options = {"Players", "Team", "Bots", "Structures"}, Multi = true, Default = {"Players"}, Flag = "AimbotTargetSel"})
    local RageHitboxElement = Aimbot:Dropdown({Name = "Target hitbox", Options = {"Head", "Neck", "Chest", "Stomach", "Legs", "Feet"}, Multi = true, Default = {"Head", "Chest"}, Flag = "AimbotHitbox"})
    local RageMultipointElement = Aimbot:Dropdown({Name = "Multipoint", Options = {"Head", "Neck", "Chest", "Stomach", "Legs", "Feet"}, Multi = true, Default = {}, Flag = "AimbotMultipoint"})
    local RageMultipointScale = Aimbot:Slider({Name = "Multipoint scale", Min = 0, Max = 100, Default = 50, Suffix = "%", Flag = "AimbotMultipointScale"})
    Aimbot:Toggle({Name = "Visible check", Flag = "AimbotVisibleCheck"})
    Aimbot:Toggle({Name = "Auto fire", Flag = "AimbotAutoFire"})
    Aimbot:Toggle({Name = "Silent aim", Flag = "AimbotSilentAim"})
    Aimbot:Toggle({Name = "Anti recoil", Flag = "AimbotAntiRecoil"})
    Aimbot:Toggle({Name = "Anti spread", Flag = "AimbotAntiSpread"})
    local RiskyColor = rgb(182, 182, 101)
    local AirShot = Aimbot:Toggle({Name = "Air shot", Flag = "AimbotAirShot"})
    AirShot.Items.Title.TextColor3 = RiskyColor
    local RapidFireToggle = Aimbot:Toggle({Name = "Rapid fire", Flag = "AimbotRapidFire"})
    RapidFireToggle.Items.Title.TextColor3 = RiskyColor
    local RapidFireSlider = Aimbot:Slider({
        Name = "Rate of fire",
        Min = 500,
        Max = 3000,
        Default = 1200,
        Decimal = 1,
        Suffix = " rpm",
        Flag = "AimbotRapidFireValue"
    })
    if RapidFireSlider.Items.Title then
        RapidFireSlider.Items.Title.TextColor3 = RiskyColor
    end
    BindVisibility(RapidFireToggle, {RapidFireSlider})
    Aimbot:Toggle({Name = "Lag compensation", Flag = "AimbotLagComp", Default = true})
    local PredictionToggle = Aimbot:Toggle({Name = "Prediction", Flag = "AimbotPrediction", Default = false})
    local PredictionMode = Aimbot:Dropdown({Name = "Prediction mode", Options = {"Light", "Balanced", "Aggressive"}, Default = "Balanced", Flag = "AimbotPredictionMode"})
    BindVisibility(PredictionToggle, {PredictionMode})
    local ReachToggle = Aimbot:Toggle({Name = "Hitbox expander", Flag = "AimbotReach"})
    ReachToggle.Items.Title.TextColor3 = RiskyColor
    local ReachSlider = Aimbot:Slider({
        Name = "Expand amount",
        Min = 0,
        Max = 30,
        Default = 5,
        Decimal = 0.1,
        Suffix = " studs",
        Flag = "AimbotReachValue"
    })
    if ReachSlider.Items.Title then
        ReachSlider.Items.Title.TextColor3 = RiskyColor
    end
    BindVisibility(ReachToggle, {ReachSlider})
    AddMenuBind(Toggle, "AimbotEnabledBind", true)
    local Other = Tabs.Rage:Section({Name = "Other", Side = "Right", Size = 0.6})
    Other:Toggle({Name = "Visible FOV", Flag = "AimbotVisFOV"})
    local RageFovElement = Other:Slider({Name = "Maximum FOV", Min = 1, Max = 180, Suffix = "°", Default = 90, Flag = "AimbotFOV"})
    Other:Toggle({Name = "Lag compensation", Flag = "AimbotLagComp"})
    Other:Toggle({Name = "Backtrack", Flag = "AimbotBacktrack"})
    Other:Slider({Name = "Backtrack ms", Min = 0, Max = 200, Suffix = "ms", Default = 200, Flag = "AimbotBacktrackMs"})
    RageProfiles.Bind({
        {Flag = "AimbotHitbox", Element = RageHitboxElement},
        {Flag = "AimbotMultipoint", Element = RageMultipointElement},
        {Flag = "AimbotMultipointScale", Element = RageMultipointScale},
        {Flag = "AimbotFOV", Element = RageFovElement},
    })
    local AA = Tabs.Rage:Section({Name = "Anti-aimbot angles", Side = "Right", Size = 0.4})
    local function UpdateRageRightSections()
        local gap = 19
        local availableHeight = math.max(0, Tabs.Rage.Items.Right.AbsoluteSize.Y - gap)
        local otherHeight = math.floor(availableHeight * 0.6)
        local antiAimHeight = availableHeight - otherHeight
        Other.Items.Outline.Size = dim2(1, 0, 0, otherHeight)
        AA.Items.Outline.Size = dim2(1, 0, 0, antiAimHeight)
    end
    Library:Connection(Tabs.Rage.Items.Right:GetPropertyChangedSignal("AbsoluteSize"), UpdateRageRightSections)
    task.defer(UpdateRageRightSections)
    AA:Toggle({Name = "Enable anti-aim", Flag = "AAEnabled"})
    AA:Dropdown({Name = "Yaw", Options = {"At targets", "Local view"}, Default = "At targets", Flag = "AAYaw"})
    local AASliders = {}
    AA:Dropdown({
        Name = "Yaw value",
        Options = {"180", "Spin", "Jitter"},
        Default = "180",
        Flag = "AAYawValue",
        Callback = function(value)
            if not next(AASliders) then return end
            for _, slider in pairs(AASliders) do
                slider.Items.Slider.Visible = false
            end
            if value == "180" then
                AASliders.YawOffset.Items.Slider.Visible = true
            elseif value == "Spin" then
                AASliders.SpinOffset.Items.Slider.Visible = true
            elseif value == "Jitter" then
                AASliders.JitterOffset1.Items.Slider.Visible = true
                AASliders.JitterOffset2.Items.Slider.Visible = true
                AASliders.JitterSpeed.Items.Slider.Visible = true
            end
        end
    })
    AASliders.YawOffset = AA:Slider({Name = "Yaw offset", Min = -180, Max = 180, Suffix = "°", Default = 0, Flag = "AAYawOffset"})
    AASliders.SpinOffset = AA:Slider({Name = "Spin offset", Min = -180, Max = 180, Suffix = "°", Default = 0, Flag = "AASpinOffset"})
    AASliders.JitterOffset1 = AA:Slider({Name = "Jitter offset 1", Min = -180, Max = 180, Suffix = "°", Default = 0, Flag = "AAJitOff1"})
    AASliders.JitterOffset2 = AA:Slider({Name = "Jitter offset 2", Min = -180, Max = 180, Suffix = "°", Default = 0, Flag = "AAJitOff2"})
    AASliders.JitterSpeed = AA:Slider({Name = "Jitter speed", Min = 0, Max = 30, Suffix = "t", Default = 5, Flag = "AAJitSpeed"})
    AASliders.SpinOffset.Items.Slider.Visible = false
    AASliders.JitterOffset1.Items.Slider.Visible = false
    AASliders.JitterOffset2.Items.Slider.Visible = false
    AASliders.JitterSpeed.Items.Slider.Visible = false
end
do
    local Page = Tabs.Aiming.Items.Page
    for _, child in pairs(Page:GetChildren()) do
        if child:IsA("UIListLayout") then
            child.HorizontalFlex = Enum.UIFlexAlignment.None
        end
    end
    Tabs.Aiming.Items.Left.Size = dim2(0.5, -10, 1, 0)
    Tabs.Aiming.Items.Right.Size = dim2(0.5, -10, 1, 0)
    for _, column in {Tabs.Aiming.Items.Left, Tabs.Aiming.Items.Right} do
        for _, child in pairs(column:GetChildren()) do
            if child:IsA("UIListLayout") then
                child.VerticalFlex = Enum.UIFlexAlignment.None
            end
        end
    end
    local LegitAimbot = Tabs.Aiming:Section({
        Name = "Aimbot",
        Side = "Left",
        Size = 1
    })
    local LegitEnabled = LegitAimbot:Toggle({
        Name = "Enabled",
        Flag = "LegitAimbotEnabled"
    })
    AddMenuBind(LegitEnabled, "LegitAimbotBind", true)
    local LegitProfiles = CreateWeaponProfileUI(LegitAimbot, "Legit", "LegitTargetPriority")
    local LegitSmoothElement = LegitAimbot:Slider({
        Name = "Smooth",
        Min = 0,
        Max = 10,
        Default = 5,
        Flag = "LegitAimbotSpeed"
    })
    local LegitAttackSmoothElement = LegitAimbot:Slider({
        Name = "Smooth (in attack)",
        Min = 0,
        Max = 10,
        Default = 5,
        Flag = "LegitAimbotAttackSpeed"
    })
    LegitAimbot:Slider({
        Name = "Speed scale - FOV",
        Min = 0,
        Max = 100,
        Default = 100,
        Suffix = "%",
        Flag = "LegitAimbotSpeedScaleFOV"
    })
    local LegitMaxLockElement = LegitAimbot:Slider({
        Name = "Maximum lock-on time",
        Min = 0,
        Max = 10000,
        Default = 0,
        Decimal = 1,
        Flag = "LegitAimbotMaxLockTime",
        Formatter = function(value)
            if value <= 0 then
                return "off"
            end
            if value % 1000 == 0 then
                return (value / 1000) .. "s"
            end
            return tostring(value) .. "ms"
        end
    })
    local LegitReactionElement = LegitAimbot:Slider({
        Name = "Reaction time",
        Min = 0,
        Max = 1000,
        Default = 100,
        Decimal = 1,
        Suffix = "ms",
        Flag = "LegitAimbotReactionTime"
    })
    local LegitFovElement = LegitAimbot:Slider({
        Name = "Maximum FOV",
        Min = 0,
        Max = 180,
        Default = 10,
        Decimal = 0.1,
        Suffix = "°",
        Flag = "LegitAimbotMaximumFOV"
    })
    LegitAimbot:Slider({
        Name = "Recoil compensation (P/Y)",
        Min = 0,
        Max = 100,
        Default = 100,
        Suffix = "%",
        Flag = "LegitAimbotRecoilPitch"
    })
    LegitAimbot:Slider({
        Min = 0,
        Max = 100,
        Default = 75,
        Suffix = "%",
        Flag = "LegitAimbotRecoilYaw"
    })
    local LegitVisibleCheckElement = LegitAimbot:Toggle({Name = "Visible check", Flag = "LegitAimbotVisibleCheck"})
    LegitAimbot:Toggle({Name = "Visible FOV", Flag = "LegitAimbotVisibleFOV"})
    local HitboxColor = rgb(182, 182, 101)
    local LegitHead = LegitAimbot:Toggle({Name = "Head", Flag = "LegitAimbotHead"})
    local LegitChest = LegitAimbot:Toggle({Name = "Chest", Flag = "LegitAimbotChest"})
    local LegitStomach = LegitAimbot:Toggle({Name = "Stomach", Flag = "LegitAimbotStomach"})
    for _, hitbox in {LegitHead, LegitChest, LegitStomach} do
        hitbox.Items.Title.TextColor3 = HitboxColor
    end
    LegitProfiles.Bind({
        {Flag = "LegitAimbotSpeed", Element = LegitSmoothElement},
        {Flag = "LegitAimbotAttackSpeed", Element = LegitAttackSmoothElement},
        {Flag = "LegitAimbotMaxLockTime", Element = LegitMaxLockElement},
        {Flag = "LegitAimbotReactionTime", Element = LegitReactionElement},
        {Flag = "LegitAimbotMaximumFOV", Element = LegitFovElement},
        {Flag = "LegitAimbotVisibleCheck", Element = LegitVisibleCheckElement},
        {Flag = "LegitAimbotHead", Element = LegitHead},
        {Flag = "LegitAimbotChest", Element = LegitChest},
        {Flag = "LegitAimbotStomach", Element = LegitStomach},
    })
    local Triggerbot = Tabs.Aiming:Section({
        Name = "Triggerbot",
        Side = "Right",
        Size = 0.7
    })
    Triggerbot.Items.Outline.Size = dim2(1, 0, 0.7, -10)
    local TriggerEnabled = Triggerbot:Toggle({
        Name = "Enabled",
        Flag = "TriggerbotEnabled"
    })
    AddMenuBind(TriggerEnabled, "TriggerbotBind", true)
    Triggerbot:Slider({
        Name = "Reaction time",
        Min = 0,
        Max = 1000,
        Default = 100,
        Decimal = 1,
        Suffix = "ms",
        Flag = "TriggerbotReactionTime"
    })
    Triggerbot:Toggle({
        Name = "Magnet trigger",
        Flag = "TriggerbotMagnet"
    })
    Triggerbot:Toggle({Name = "Visible check", Flag = "TriggerbotVisibleCheck"})
    local TriggerHead = Triggerbot:Toggle({Name = "Head", Flag = "TriggerbotHead"})
    local TriggerChest = Triggerbot:Toggle({Name = "Chest", Flag = "TriggerbotChest"})
    local TriggerStomach = Triggerbot:Toggle({Name = "Stomach", Flag = "TriggerbotStomach"})
    for _, hitbox in {TriggerHead, TriggerChest, TriggerStomach} do
        hitbox.Items.Title.TextColor3 = HitboxColor
    end
    local Other = Tabs.Aiming:Section({
        Name = "Other",
        Side = "Right",
        Size = 0.3
    })
    Other.Items.Outline.Size = dim2(1, 0, 0.3, -9)
    local BacktrackToggle = Other:Toggle({
        Name = "Backtrack",
        Flag = "OtherBacktrack"
    })
    local BacktrackTime = Other:Slider({
        Name = "Backtrack time",
        Min = 0,
        Max = 200,
        Default = 200,
        Suffix = "ms",
        Flag = "OtherBacktrackTime"
    })
    BindVisibility(BacktrackToggle, {BacktrackTime})
end
Window.ToggleMenu(true)
do
    local Page = Tabs.Lighting.Items.Page
    for _, child in pairs(Page:GetChildren()) do
        if child:IsA("UIListLayout") then
            child.HorizontalFlex = Enum.UIFlexAlignment.None
        end
    end
    Tabs.Lighting.Items.Left.Size = dim2(0.5, -10, 1, 0)
    Tabs.Lighting.Items.Right.Size = dim2(0.5, -10, 1, 0)
    for _, column in {Tabs.Lighting.Items.Left, Tabs.Lighting.Items.Right} do
        for _, child in pairs(column:GetChildren()) do
            if child:IsA("UIListLayout") then
                child.VerticalFlex = Enum.UIFlexAlignment.None
            end
        end
    end
    local function SectionTabs(Section, names)
        local Bar = Library:Create("Frame", {
            Parent = Section.Items.Elements;
            Name = "\0";
            Size = dim2(1, 0, 0, 16);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = -1;
            BackgroundColor3 = rgb(255, 255, 255);
        })
        Library:Create("UIListLayout", {
            Parent = Bar;
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalFlex = Enum.UIFlexAlignment.Fill;
            SortOrder = Enum.SortOrder.LayoutOrder;
        })
        local pages, buttons = {}, {}
        local function Select(index)
            for i, page in pages do
                page.Items.Elements.Visible = (i == index)
                buttons[i].TextColor3 = (i == index) and themes.preset.accent or rgb(140, 140, 140)
                buttons[i].BackgroundColor3 = (i == index) and rgb(30, 30, 30) or rgb(20, 20, 20)
            end
        end
        for i, name in names do
            local button = Library:Create("TextButton", {
                Parent = Bar;
                Name = "\0";
                Text = name;
                AutoButtonColor = false;
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                TextSize = 13;
                TextColor3 = rgb(140, 140, 140);
                Size = dim2(0, 0, 1, 0);
                LayoutOrder = i;
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(20, 20, 20);
            })
            local Holder = Library:Create("Frame", {
                Parent = Section.Items.Elements;
                Name = "\0";
                Size = dim2(1, 0, 0, 0);
                AutomaticSize = Enum.AutomaticSize.Y;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                LayoutOrder = i;
                Visible = false;
                BackgroundColor3 = rgb(255, 255, 255);
            })
            Library:Create("UIListLayout", {
                Parent = Holder;
                Padding = dim(0, 8);
                SortOrder = Enum.SortOrder.LayoutOrder;
            })
            buttons[i] = button
            pages[i] = setmetatable({
                Name = name;
                Items = { Elements = Holder };
            }, Library)
            button.MouseButton1Click:Connect(function()
                Select(i)
            end)
        end
        Select(1)
        return unpack(pages)
    end
    local LeftTop = Tabs.Lighting:Section({Name = "Colored models", Side = "Left", Size = 0.7})
    LeftTop.Items.Outline.Size = dim2(1, 0, 0.7, -10)
    local LeftBottom = Tabs.Lighting:Section({Name = "World", Side = "Left", Size = 0.3})
    LeftBottom.Items.Outline.Size = dim2(1, 0, 0.3, -9)
    local RightTop = Tabs.Lighting:Section({Name = "Preview ESP", Side = "Right", Size = 0.65})
    RightTop.Items.Outline.Size = dim2(1, 0, 0.65, -10)
    local RightBottom = Tabs.Lighting:Section({Name = "Effects", Side = "Right", Size = 0.35})
    RightBottom.Items.Outline.Size = dim2(1, 0, 0.35, -9)
    local function ColoredModel(name, flag, color)
        local toggle = LeftTop:Toggle({Name = name, Flag = flag})
        local picker = toggle:Colorpicker({Flag = flag .. "Color", Color = color})
        local style = LeftTop:Dropdown({
            Name = nil,
            Options = {"Normal", "Flat"},
            Default = "Flat",
            Flag = flag .. "Style"
        })
        local root = style.Items.Dropdown
        local previous = toggle.Callback
        local function Refresh(state)
            root.Visible = state
        end
        local previousStyle = style.Callback
        style.Callback = function(...)
            if previousStyle then
                previousStyle(...)
            end
            Refresh(toggle.Enabled)
        end
        toggle.Callback = function(state, ...)
            if previous then
                previous(state, ...)
            end
            Refresh(state)
        end
        Refresh(toggle.Enabled)
        return toggle, picker, style
    end
    local PlayerToggle, PlayerPicker, PlayerStyle = ColoredModel("Player", "VisPlayer", rgb(142, 181, 39))
    local PlayerWallToggle, PlayerWallPicker, PlayerWallStyle = ColoredModel("Player behind wall", "VisPlayerWall", rgb(79, 143, 214))
    local TeammateToggle, TeammatePicker, TeammateStyle = ColoredModel("Teammate", "VisTeammate", rgb(110, 110, 110))
    local TeammateWallToggle, TeammateWallPicker, TeammateWallStyle = ColoredModel("Teammate behind wall", "VisTeammateWall", rgb(255, 255, 255))
    local ChamsSources = {
        Enemy = {
            Visible = {Toggle = PlayerToggle, Picker = PlayerPicker, Flag = "VisPlayerColor", StyleFlag = "VisPlayerStyle", Style = PlayerStyle};
            Invisible = {Toggle = PlayerWallToggle, Picker = PlayerWallPicker, Flag = "VisPlayerWallColor", StyleFlag = "VisPlayerWallStyle", Style = PlayerWallStyle};
        };
        Team = {
            Visible = {Toggle = TeammateToggle, Picker = TeammatePicker, Flag = "VisTeammateColor", StyleFlag = "VisTeammateStyle", Style = TeammateStyle};
            Invisible = {Toggle = TeammateWallToggle, Picker = TeammateWallPicker, Flag = "VisTeammateWallColor", StyleFlag = "VisTeammateWallStyle", Style = TeammateWallStyle};
        };
    }
    ColoredModel("Local player", "VisLocalPlayer", rgb(110, 110, 110))
    LeftTop:Dropdown({
        Name = "Local player transparency",
        Options = {"Player overlap", "Weapon"},
        Multi = true,
        Default = {},
        Flag = "VisLocalPlayerTransparency"
    })
    ColoredModel("Local player fake", "VisLocalPlayerFake", rgb(20, 20, 20))
    ColoredModel("On shot", "VisOnShot", rgb(110, 110, 110))
    local BacktrackToggle, BacktrackPicker, BacktrackStyle = ColoredModel("Backtrack", "VisBacktrack", rgb(255, 255, 255))
    local BacktrackTargets = LeftTop:Dropdown({
        Name = nil,
        Options = {"Enemy", "Team"},
        Multi = true,
        Default = {"Enemy"},
        MinSelected = 1,
        Flag = "VisBacktrackTargets"
    })
    local rootBacktrackTargets = BacktrackTargets.Items.Dropdown
    local prevBacktrackToggle = BacktrackToggle.Callback
    local function RefreshBacktrackTargets(state)
        rootBacktrackTargets.Visible = state
        if not state and BacktrackTargets.Open then
            BacktrackTargets.SetVisible(false)
            BacktrackTargets.Open = false
        end
    end
    local prevBacktrackStyle = BacktrackStyle.Callback
    BacktrackStyle.Callback = function(...)
        if prevBacktrackStyle then prevBacktrackStyle(...) end
        RefreshBacktrackTargets(BacktrackToggle.Enabled)
    end
    BacktrackToggle.Callback = function(state, ...)
        if prevBacktrackToggle then prevBacktrackToggle(state, ...) end
        RefreshBacktrackTargets(state)
    end
    RefreshBacktrackTargets(BacktrackToggle.Enabled)
    local WorldEnabled = LeftBottom:Toggle({
        Name = "Enable",
        Default = false,
        Flag = "VisWorldEnabled"
    })
    local Brightness = LeftBottom:Dropdown({
        Name = "Brightness adjustment",
        Options = {"Off", "Fullbright", "Night mode"},
        Default = "Off",
        Flag = "VisBrightnessMode"
    })
    local BrightnessComponents = Library:Create("Frame", {
        Parent = Brightness.Items.Dropdown;
        Name = "\0";
        AnchorPoint = vec2(1, 0);
        Position = dim2(1, 0, 0, 18);
        Size = dim2(0, 30, 0, 9);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        ZIndex = 2;
        BackgroundColor3 = rgb(255, 255, 255);
    })
    Library:Create("UIListLayout", {
        Parent = BrightnessComponents;
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalAlignment = Enum.HorizontalAlignment.Right;
        Padding = dim(0, 3);
        SortOrder = Enum.SortOrder.LayoutOrder;
    })
    local BrightnessHost = setmetatable({
        Items = { Components = BrightnessComponents };
    }, Library)
    local BrightnessColor = BrightnessHost:Colorpicker({
        Flag = "VisBrightnessColor",
        Color = rgb(60, 80, 140)
    })
    local function UpdateBrightnessPicker(mode)
        local visible = (mode == "Night mode")
        BrightnessComponents.Visible = visible
        if not visible and BrightnessColor.SetVisible then
            BrightnessColor.SetVisible(false)
        end
    end
    Brightness.Callback = function(mode)
        UpdateBrightnessPicker(mode)
    end
    UpdateBrightnessPicker(Flags.VisBrightnessMode)
    LeftBottom:Label({Name = "Ambient"}):Colorpicker({
        Flag = "VisAmbientColor",
        Color = rgb(128, 128, 128)
    })
    LeftBottom:Slider({
        Name = "Time changer",
        Min = 0,
        Max = 24,
        Default = 0,
        Decimal = 1,
        Suffix = "h",
        Formatter = function(v)
            return v == 0 and "Auto" or (tostring(v) .. "h")
        end,
        Flag = "VisTimeChanger"
    })
    local WeatherNames = {
        [0] = "Off",
        [1] = "Rain",
        [2] = "Snow",
        [3] = "Thunderstorm",
        [4] = "Ashfall",
        [5] = "Dust storm"
    }
    LeftBottom:Slider({
        Name = "Weather",
        Min = 0,
        Max = 5,
        Default = 0,
        Decimal = 1,
        Formatter = function(v)
            return WeatherNames[math.floor(v + 0.5)] or "Off"
        end,
        Flag = "VisWeather"
    })
    local PreviewOk, PreviewErr = pcall(function()
        local ESPFlags = {}
        local function PickerColor(color)
            return color
        end
        local function LiftPicker(picker)
            local object = picker.Items and picker.Items.ColorpickerObject
            if object then
                object.ZIndex = 30020
                for _, descendant in object:GetDescendants() do
                    if descendant:IsA("GuiObject") then
                        descendant.ZIndex = 30021
                    end
                end
            end
            local window = picker.Items and picker.Items.Colorpicker
            if window then
                window.ZIndex = 40000
                for _, descendant in window:GetDescendants() do
                    if descendant:IsA("GuiObject") then
                        descendant.ZIndex += 20000
                    end
                end
            end
            return picker
        end
        local function MakeColorRow(parent, text, order, width)
            local row = Library:Create("Frame", {
                Parent = parent;
                Name = "\0";
                Size = dim2(1, 0, 0, 12);
                BackgroundTransparency = 1;
                LayoutOrder = order;
                BorderSizePixel = 0;
                ZIndex = 30003;
                BackgroundColor3 = rgb(255, 255, 255);
            })
            Library:Create("TextLabel", {
                Parent = row;
                Name = "\0";
                Text = text;
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                TextSize = 12;
                TextColor3 = rgb(190, 190, 190);
                TextXAlignment = Enum.TextXAlignment.Left;
                BackgroundTransparency = 1;
                Size = dim2(1, -(width or 30), 1, 0);
                BorderSizePixel = 0;
                ZIndex = 30004;
                BackgroundColor3 = rgb(255, 255, 255);
            })
            local host = Library:Create("Frame", {
                Parent = row;
                Name = "\0";
                AnchorPoint = vec2(1, 0.5);
                Position = dim2(1, 0, 0.5, 0);
                Size = dim2(0, width or 20, 0, 9);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ZIndex = 30004;
                BackgroundColor3 = rgb(255, 255, 255);
            })
            Library:Create("UIListLayout", {
                Parent = host;
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                Padding = dim(0, 3);
                SortOrder = Enum.SortOrder.LayoutOrder;
            })
            return row, setmetatable({Items = {Components = host}}, Library)
        end
        local function MakeCheckbox(parent, text, order, callback, default)
            local self = {
                State = default or false;
                Callback = callback;
            }
            local button = Library:Create("TextButton", {
                Parent = parent;
                Name = "\0";
                Text = "";
                AutoButtonColor = false;
                BackgroundTransparency = 1;
                Size = dim2(1, 0, 0, 10);
                LayoutOrder = order;
                BorderSizePixel = 0;
                ZIndex = 30003;
                BackgroundColor3 = rgb(255, 255, 255);
            })
            local outline = Library:Create("Frame", {
                Parent = button;
                Name = "\0";
                Size = dim2(0, 8, 0, 8);
                Position = dim2(0, 0, 0, 1);
                BorderSizePixel = 0;
                ZIndex = 30004;
                BackgroundColor3 = rgb(12, 12, 12);
            })
            local accent = Library:Create("Frame", {
                Parent = outline;
                Name = "\0";
                Position = dim2(0, 1, 0, 1);
                Size = dim2(1, -2, 1, -2);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ZIndex = 30005;
                BackgroundColor3 = themes.preset.accent;
            })
            local label = Library:Create("TextLabel", {
                Parent = button;
                Name = "\0";
                Text = text;
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                TextSize = 13;
                TextColor3 = rgb(205, 205, 205);
                TextXAlignment = Enum.TextXAlignment.Left;
                BackgroundTransparency = 1;
                Position = dim2(0, 14, 0, -2);
                Size = dim2(1, -14, 0, 13);
                BorderSizePixel = 0;
                ZIndex = 30004;
                BackgroundColor3 = rgb(255, 255, 255);
            })
            self.Button = button
            self.Label = label
            function self.Set(state, silent)
                self.State = state
                accent.BackgroundTransparency = state and 0 or 1
                if not silent and self.Callback then
                    self.Callback(state)
                end
            end
            function self.Toggle()
                self.Set(not self.State)
            end
            button.MouseButton1Click:Connect(self.Toggle)
            self.Set(self.State, true)
            return self
        end
        local function MakeSection(parent)
            local section = Library:Create("Frame", {
                Parent = parent;
                Name = "\0";
                Size = dim2(1, 0, 0, 0);
                AutomaticSize = Enum.AutomaticSize.Y;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Visible = false;
                LayoutOrder = 3;
                ZIndex = 30002;
                BackgroundColor3 = rgb(255, 255, 255);
            })
            Library:Create("UIListLayout", {
                Parent = section;
                Padding = dim(0, 6);
                SortOrder = Enum.SortOrder.LayoutOrder;
            })
            return section
        end
        local AllCombos = {}
        local function MakeCombo(parent, label, order, options, root, multi, default)
            local self = {
                Multi = multi or false;
                Options = options;
                Selected = {};
                Buttons = {};
                Callback = nil;
            }
            if label then
                Library:Create("TextLabel", {
                    Parent = parent;
                    Name = "\0";
                    Text = label;
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                    TextSize = 12;
                    TextColor3 = rgb(190, 190, 190);
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 12);
                    LayoutOrder = order;
                    BorderSizePixel = 0;
                    ZIndex = 30003;
                    BackgroundColor3 = rgb(255, 255, 255);
                })
            end
            local outline = Library:Create("TextButton", {
                Parent = parent;
                Name = "\0";
                Text = "";
                AutoButtonColor = false;
                Size = dim2(1, 0, 0, 20);
                LayoutOrder = order + 1;
                BorderSizePixel = 0;
                ZIndex = 30003;
                BackgroundColor3 = rgb(12, 12, 12);
            })
            local inner = Library:Create("Frame", {
                Parent = outline;
                Name = "\0";
                Position = dim2(0, 1, 0, 1);
                Size = dim2(1, -2, 1, -2);
                BorderSizePixel = 0;
                ZIndex = 30004;
                BackgroundColor3 = rgb(255, 255, 255);
            })
            Library:Create("UIGradient", {
                Parent = inner;
                Rotation = 90;
                Color = rgbseq{rgbkey(0, rgb(31, 31, 31)), rgbkey(1, rgb(36, 36, 36))};
            })
            local text = Library:Create("TextLabel", {
                Parent = inner;
                Name = "\0";
                Text = options[1];
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                TextSize = 13;
                TextColor3 = rgb(205, 205, 205);
                TextXAlignment = Enum.TextXAlignment.Left;
                TextTruncate = Enum.TextTruncate.AtEnd;
                BackgroundTransparency = 1;
                Size = dim2(1, -14, 1, 0);
                ClipsDescendants = true;
                BorderSizePixel = 0;
                ZIndex = 30005;
                BackgroundColor3 = rgb(255, 255, 255);
            })
            Library:Create("UIPadding", {
                Parent = text;
                PaddingLeft = dim(0, 5);
            })
            Library:Create("ImageLabel", {
                Parent = inner;
                Name = "\0";
                AnchorPoint = vec2(1, 0.5);
                Position = dim2(1, -5, 0.5, 0);
                Size = dim2(0, 5, 0, 4);
                Image = "rbxassetid://83504953088675";
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ZIndex = 30005;
                BackgroundColor3 = rgb(255, 255, 255);
            })
            local list = Library:Create("Frame", {
                Parent = root;
                Name = "\0";
                Visible = false;
                Size = dim2(0, 132, 0, 0);
                AutomaticSize = Enum.AutomaticSize.Y;
                BorderSizePixel = 0;
                ZIndex = 31000;
                BackgroundColor3 = rgb(12, 12, 12);
            })
            local holder = Library:Create("Frame", {
                Parent = list;
                Name = "\0";
                Position = dim2(0, 1, 0, 1);
                Size = dim2(1, -2, 1, -2);
                AutomaticSize = Enum.AutomaticSize.Y;
                BorderSizePixel = 0;
                ZIndex = 31001;
                BackgroundColor3 = rgb(35, 35, 35);
            })
            Library:Create("UIPadding", {
                Parent = holder;
                PaddingBottom = dim(0, 1);
            })
            Library:Create("UIListLayout", {
                Parent = holder;
                SortOrder = Enum.SortOrder.LayoutOrder;
            })
            self.Outline = outline
            self.Text = text
            self.List = list
            function self.Refresh()
                if self.Multi then
                    local picked = {}
                    for _, value in self.Options do
                        if self.Selected[value] then
                            table.insert(picked, value)
                        end
                    end
                    text.Text = #picked > 0 and table.concat(picked, ", ") or "None"
                else
                    text.Text = self.Value or self.Options[1]
                end
                for _, entry in self.Buttons do
                    local active = self.Multi and self.Selected[entry.Value] or self.Value == entry.Value
                    entry.Button.TextColor3 = active and themes.preset.accent or rgb(205, 205, 205)
                    entry.Button.BackgroundTransparency = active and 1 or 0
                    entry.Button.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",
                        active and Enum.FontWeight.Bold or Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                end
            end
            function self.Set(value, silent)
                if self.Multi then
                    self.Selected[value] = not self.Selected[value]
                else
                    self.Value = value
                    list.Visible = false
                end
                self.Refresh()
                if not silent and self.Callback then
                     
                     
                    if self.Multi then
                        self.Callback(value, self.Selected[value] == true)
                    else
                        self.Callback(value)
                    end
                end
            end
            for index, value in options do
                local button = Library:Create("TextButton", {
                    Parent = holder;
                    Name = "\0";
                    Text = value;
                    AutoButtonColor = false;
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                    TextSize = 13;
                    TextColor3 = rgb(205, 205, 205);
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ClipsDescendants = true;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    Size = dim2(1, 0, 0, 0);
                    LayoutOrder = index;
                    BorderSizePixel = 0;
                    ZIndex = 31002;
                    BackgroundColor3 = rgb(26, 26, 26);
                })
                Library:Create("UIPadding", {
                    Parent = button;
                    PaddingTop = dim(0, 5);
                    PaddingBottom = dim(0, 5);
                    PaddingLeft = dim(0, 5);
                    PaddingRight = dim(0, 5);
                })
                table.insert(self.Buttons, {Button = button, Value = value})
                button.MouseButton1Click:Connect(function()
                    self.Set(value)
                end)
            end
            function self.Follow()
                if not list.Visible then
                    return
                end
                local rel = outline.AbsolutePosition - root.AbsolutePosition
                local size = outline.AbsoluteSize
                list.Size = dim2(0, size.X, 0, 0)
                list.Position = dim2(0, rel.X, 0, rel.Y + size.Y)
            end
            Library:Connection(RunService.RenderStepped, self.Follow)
            outline.MouseButton1Click:Connect(function()
                local show = not list.Visible
                for _, other in AllCombos do
                    other.List.Visible = false
                end
                list.Visible = show
                self.Follow()
            end)
            if default then
                if self.Multi then
                    for _, value in default do
                        self.Selected[value] = true
                    end
                else
                    self.Value = default
                end
            end
            self.Refresh()
            table.insert(AllCombos, self)
            return self
        end
        local Root = Library:Create("Frame", {
            Parent = RightTop.Items.Background;
            Name = "\0";
            Position = dim2(0, 20, 0, 19);
            Size = dim2(1, -40, 1, -34);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ZIndex = 3;
            BackgroundColor3 = rgb(255, 255, 255);
        })
        local ChamsBar = Library:Create("Frame", {
            Parent = Root;
            Name = "\0";
            Size = dim2(1, 0, 0, 18);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ZIndex = 4;
            BackgroundColor3 = rgb(255, 255, 255);
        })
        Library:Create("UIListLayout", {
            Parent = ChamsBar;
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalFlex = Enum.UIFlexAlignment.Fill;
            Padding = dim(0, 3);
            SortOrder = Enum.SortOrder.LayoutOrder;
        })
        local Preview = Library:Create("Frame", {
            Parent = Root;
            Name = "\0";
            Position = dim2(0, 0, 0, 22);
            Size = dim2(1, 0, 1, -60);
            BorderSizePixel = 0;
            ClipsDescendants = true;
            ZIndex = 3;
            BackgroundColor3 = rgb(12, 12, 12);
        })
        local PreviewInline = Library:Create("Frame", {
            Parent = Preview;
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            ClipsDescendants = true;
            ZIndex = 4;
            BackgroundColor3 = rgb(18, 18, 18);
        })
        local Target = Library:Create("Frame", {
            Parent = PreviewInline;
            Name = "\0";
            AnchorPoint = vec2(0.5, 0.5);
            Position = dim2(0.5, 0, 0.47, 0);
            Size = dim2(1, 0, 0.66, 0);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ZIndex = 5;
            BackgroundColor3 = rgb(255, 255, 255);
        })
        Library:Create("UIAspectRatioConstraint", {
            Parent = Target;
            AspectRatio = 0.48;
            AspectType = Enum.AspectType.FitWithinMaxSize;
            DominantAxis = Enum.DominantAxis.Height;
        })
        local Dummy = Library:Create("ImageLabel", {
            Parent = Target;
            Name = "\0";
            AnchorPoint = vec2(0.5, 0.5);
            Position = dim2(0.5, 0, 0.5, 0);
            Size = dim2(1.45, 0, 1, 0);
            BackgroundTransparency = 1;
            Image = "rbxassetid://337558544";
            ScaleType = Enum.ScaleType.Stretch;
            BorderSizePixel = 0;
            ZIndex = 6;
            BackgroundColor3 = rgb(255, 255, 255);
        })
        local ChamsOverlay = Library:Create("ImageLabel", {
            Parent = Target;
            Name = "\0";
            AnchorPoint = vec2(0.5, 0.5);
            Position = Dummy.Position;
            Size = Dummy.Size;
            BackgroundTransparency = 1;
            Image = Dummy.Image;
            ImageColor3 = rgb(255, 255, 255);
            ImageTransparency = 1;
            ScaleType = Enum.ScaleType.Stretch;
            BorderSizePixel = 0;
            ZIndex = 8;
            BackgroundColor3 = rgb(255, 255, 255);
        })
        local ChamsOutlines = {}
        for _, offset in {
            vec2(-1, 0), vec2(1, 0), vec2(0, -1), vec2(0, 1),
            vec2(-1, -1), vec2(1, -1), vec2(-1, 1), vec2(1, 1),
        } do
            local outline = Library:Create("ImageLabel", {
                Parent = Target;
                Name = "\0";
                AnchorPoint = vec2(0.5, 0.5);
                Position = dim2(0.5, offset.X, 0.5, offset.Y);
                Size = Dummy.Size;
                BackgroundTransparency = 1;
                Image = Dummy.Image;
                ImageColor3 = rgb(255, 255, 255);
                ImageTransparency = 1;
                ScaleType = Enum.ScaleType.Stretch;
                BorderSizePixel = 0;
                ZIndex = 7;
                BackgroundColor3 = rgb(255, 255, 255);
            })
            table.insert(ChamsOutlines, outline)
        end
        local DummyOriginal = Dummy.Image
        local DummySilhouetteContent = nil
        local function MakeSilhouette()
            pcall(function()
                local AssetService = game:GetService("AssetService")
                local editable = AssetService:CreateEditableImageAsync(Content.fromUri(Dummy.Image))
                if not editable then
                    return
                end
                DummyOriginal = Dummy.Image
                local size = editable.Size
                local pixels = editable:ReadPixelsBuffer(vec2(0, 0), size)
                local count = buffer.len(pixels)
                for offset = 0, count - 4, 4 do
                    local alpha = buffer.readu8(pixels, offset + 3)
                    if alpha < 128 then
                        buffer.writeu8(pixels, offset + 3, 0)
                    else
                        buffer.writeu8(pixels, offset, 255)
                        buffer.writeu8(pixels, offset + 1, 255)
                        buffer.writeu8(pixels, offset + 2, 255)
                        buffer.writeu8(pixels, offset + 3, 255)
                    end
                end
                editable:WritePixelsBuffer(vec2(0, 0), size, pixels)
                DummySilhouetteContent = Content.fromObject(editable)
            end)
        end
        local function UseSilhouette(flat)
            if flat then
                if DummySilhouetteContent then
                    ChamsOverlay.ImageContent = DummySilhouetteContent
                    for _, outline in ChamsOutlines do
                        outline.ImageContent = DummySilhouetteContent
                    end
                else
                    ChamsOverlay.Image = DummyOriginal
                    for _, outline in ChamsOutlines do
                        outline.Image = DummyOriginal
                    end
                end
            elseif DummyOriginal then
                ChamsOverlay.Image = DummyOriginal
                for _, outline in ChamsOutlines do
                    if DummySilhouetteContent then
                        outline.ImageContent = DummySilhouetteContent
                    else
                        outline.Image = DummyOriginal
                    end
                end
            end
        end
        local DummyLoader = Library:Create("TextLabel", {
            Parent = PreviewInline;
            Name = "\0";
            AnchorPoint = vec2(0.5, 0.5);
            Position = dim2(0.5, 0, 0.5, 0);
            Size = dim2(1, 0, 0, 14);
            Text = "loading model...";
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
            TextSize = 12;
            TextColor3 = rgb(140, 140, 140);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ZIndex = 9;
            BackgroundColor3 = rgb(255, 255, 255);
        })
        task.spawn(function()
            local finished = false
            task.spawn(function()
                local dots = 0
                while not finished do
                    dots = (dots + 1) % 4
                    if DummyLoader and DummyLoader.Parent then
                        DummyLoader.Text = "loading model" .. string.rep(".", dots)
                    end
                    task.wait(0.35)
                end
            end)
            local function Finish()
                finished = true
                if DummyLoader then
                    DummyLoader:Destroy()
                end
            end
            Dummy:GetPropertyChangedSignal("IsLoaded"):Connect(function()
                if Dummy.IsLoaded then
                    Finish()
                end
            end)
            pcall(function()
                game:GetService("ContentProvider"):PreloadAsync({Dummy})
            end)
            local elapsed = 0
            while not Dummy.IsLoaded and elapsed < 30 do
                elapsed = elapsed + task.wait(0.25)
            end
            MakeSilhouette()
            Finish()
        end)
        local Box = Library:Create("Frame", {
            Parent = Target;
            Name = "\0";
            Size = dim2(1, 0, 1, 0);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Visible = false;
            ZIndex = 8;
            BackgroundColor3 = rgb(255, 255, 255);
        })
        local BoxStroke = Library:Create("UIStroke", {
            Parent = Box;
            Color = rgb(255, 255, 255);
            Thickness = 1;
            LineJoinMode = Enum.LineJoinMode.Miter;
        })
        local BoxCorners = {}
        for _, corner in {
            {Anchor = vec2(0, 0), Position = dim2(0, 0, 0, 0)};
            {Anchor = vec2(1, 0), Position = dim2(1, 0, 0, 0)};
            {Anchor = vec2(0, 1), Position = dim2(0, 0, 1, 0)};
            {Anchor = vec2(1, 1), Position = dim2(1, 0, 1, 0)};
        } do
            local holder = Library:Create("Frame", {
                Parent = Box;
                Name = "\0";
                AnchorPoint = corner.Anchor;
                Position = corner.Position;
                Size = dim2(0.2, 0, 0.13, 0);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Visible = false;
                ZIndex = 9;
                BackgroundColor3 = rgb(255, 255, 255);
            })
            local horizontal = Library:Create("Frame", {
                Parent = holder;
                Name = "\0";
                AnchorPoint = corner.Anchor;
                Position = corner.Position;
                Size = dim2(1, 0, 0, 1);
                BorderSizePixel = 0;
                ZIndex = 9;
                BackgroundColor3 = rgb(255, 255, 255);
            })
            local vertical = Library:Create("Frame", {
                Parent = holder;
                Name = "\0";
                AnchorPoint = corner.Anchor;
                Position = corner.Position;
                Size = dim2(0, 1, 1, 0);
                BorderSizePixel = 0;
                ZIndex = 9;
                BackgroundColor3 = rgb(255, 255, 255);
            })
            table.insert(BoxCorners, {Holder = holder, Lines = {horizontal, vertical}})
        end
        local BoxSettings = {Style = "Full", Color = rgb(255, 255, 255), Transparency = 0}
        local function RefreshBox()
            local isCorner = BoxSettings.Style == "Corner"
            BoxStroke.Color = BoxSettings.Color
            BoxStroke.Transparency = isCorner and 1 or BoxSettings.Transparency
            for _, corner in BoxCorners do
                corner.Holder.Visible = isCorner
                for _, line in corner.Lines do
                    line.BackgroundColor3 = BoxSettings.Color
                    line.BackgroundTransparency = BoxSettings.Transparency
                end
            end
        end
        local Health = Library:Create("Frame", {
            Parent = Target;
            Name = "\0";
            AnchorPoint = vec2(1, 0);
            Position = dim2(0, -5, 0, 0);
            Size = dim2(0, 4, 1, 0);
            BorderSizePixel = 0;
            Visible = false;
            ZIndex = 8;
            BackgroundColor3 = rgb(0, 0, 0);
        })
        Library:Create("UICorner", {
            Parent = Health;
            CornerRadius = dim(0, 2);
        })
        local HealthFill = Library:Create("Frame", {
            Parent = Health;
            Name = "\0";
            AnchorPoint = vec2(0, 1);
            Position = dim2(0, 0, 1, 0);
            Size = dim2(1, 0, 1, 0);
            BorderSizePixel = 0;
            ZIndex = 9;
            BackgroundColor3 = rgb(88, 214, 74);
        })
        Library:Create("UICorner", {
            Parent = HealthFill;
            CornerRadius = dim(0, 2);
        })
        local HealthGradient = Library:Create("UIGradient", {
            Parent = HealthFill;
            Rotation = 90;
            Enabled = false;
            Color = rgbseq{rgbkey(0, rgb(88, 214, 74)), rgbkey(1, rgb(214, 79, 79))};
        })
        local HealthText = Library:Create("TextLabel", {
            Parent = HealthFill;
            Name = "\0";
            Text = "100";
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
            TextSize = 11;
            TextColor3 = rgb(255, 255, 255);
            TextStrokeTransparency = 0;
            BackgroundTransparency = 1;
            AnchorPoint = vec2(0.5, 1);
            Position = dim2(0.5, 0, 0, -1);
            AutomaticSize = Enum.AutomaticSize.XY;
            BorderSizePixel = 0;
            ZIndex = 12;
            Visible = false;
            BackgroundColor3 = rgb(255, 255, 255);
        })
        local HealthSettings = {
            Text = false;
            Gradient = false;
            Color = rgb(88, 214, 74);
            ColorTo = rgb(214, 79, 79);
        }
        local function RefreshHealth()
            HealthText.Visible = Health.Visible and HealthSettings.Text
            HealthGradient.Enabled = HealthSettings.Gradient
            if HealthSettings.Gradient then
                HealthFill.BackgroundColor3 = rgb(255, 255, 255)
                HealthGradient.Color = rgbseq{
                    rgbkey(0, HealthSettings.Color),
                    rgbkey(1, HealthSettings.ColorTo),
                }
            else
                HealthFill.BackgroundColor3 = HealthSettings.Color
            end
        end
        local Bars = {}
        local SlotList = nil
        local function ApplyBarSlot(bar, fill, slotId, thickness, depth)
            local side = slotId:match("^Left") and "Left"
                or slotId:match("^Right") and "Right"
                or slotId:match("^Top") and "Top"
                or slotId:match("^Bottom") and "Bottom"
                or slotId
            local shift = 5 + (depth or 0) * (thickness + 2)
            if side == "Left" or side == "Right" then
                bar.AnchorPoint = vec2(side == "Left" and 1 or 0, 0)
                bar.Position = dim2(side == "Left" and 0 or 1, side == "Left" and -shift or shift, 0, 0)
                bar.Size = dim2(0, thickness, 1, 0)
                fill.AnchorPoint = vec2(0, 1)
                fill.Position = dim2(0, 0, 1, 0)
                fill.Size = dim2(1, 0, fill:GetAttribute("Value") or 1, 0)
            else
                bar.AnchorPoint = vec2(0, side == "Top" and 1 or 0)
                bar.Position = dim2(0, 0, side == "Top" and 0 or 1, side == "Top" and -shift or shift)
                bar.Size = dim2(1, 0, 0, thickness)
                fill.AnchorPoint = vec2(0, 0)
                fill.Position = dim2(0, 0, 0, 0)
                fill.Size = dim2(fill:GetAttribute("Value") or 1, 0, 1, 0)
            end
        end
        local function LayoutBars()
            local used = {}
            local counts = {}
            for _, entry in Bars do
                if not entry.Element.Objects[1].Visible then
                    continue
                end
                local slotId = entry.Element.Slot
                local side = slotId:match("^Left") and "Left"
                    or slotId:match("^Right") and "Right"
                    or slotId:match("^Top") and "Top"
                    or slotId:match("^Bottom") and "Bottom"
                    or slotId
                local depth = counts[side] or 0
                counts[side] = depth + 1
                used[side] = math.max(used[side] or 0, 5 + (depth + 1) * (entry.Bar.Thickness + 2))
                ApplyBarSlot(entry.Element.Objects[1], entry.Bar.Fill, slotId, entry.Bar.Thickness, depth)
            end
            if not SlotList then
                return
            end
            for _, slot in SlotList do
                local push = used[slot.Side] or 0
                local base = slot.BasePosition
                if slot.Side == "Left" then
                    slot.Holder.Position = dim2(base.X.Scale, base.X.Offset - push, base.Y.Scale, base.Y.Offset)
                elseif slot.Side == "Right" then
                    slot.Holder.Position = dim2(base.X.Scale, base.X.Offset + push, base.Y.Scale, base.Y.Offset)
                elseif slot.Side == "Top" then
                    slot.Holder.Position = dim2(base.X.Scale, base.X.Offset, base.Y.Scale, base.Y.Offset - push)
                else
                    slot.Holder.Position = dim2(base.X.Scale, base.X.Offset, base.Y.Scale, base.Y.Offset + push)
                end
            end
        end
        HealthFill:SetAttribute("Value", 1)
        table.insert(Library.NoDrag, Preview)
        local ChamsState = {Team = "Enemy", Mode = "Visible"}
        local function CurrentSource()
            return ChamsSources[ChamsState.Team][ChamsState.Mode]
        end
        local ChamsStyle = "Flat"
        local function RefreshChams()
            local source = CurrentSource()
            local data = Flags[source.Flag] or {}
            local swatch = source.Picker.Items and source.Picker.Items.InnerObject
            local col = data.Color or (swatch and swatch.BackgroundColor3) or rgb(255, 255, 255)
            local alpha = data.Transparency or (swatch and swatch.BackgroundTransparency) or 0
            if not source.Toggle.Enabled then
                UseSilhouette(false)
                Dummy.ImageColor3 = rgb(255, 255, 255)
                Dummy.ImageTransparency = 0
                ChamsOverlay.ImageColor3 = rgb(255, 255, 255)
                ChamsOverlay.ImageTransparency = 1
                for _, outline in ChamsOutlines do
                    outline.ImageColor3 = rgb(255, 255, 255)
                    outline.ImageTransparency = 1
                end
                return
            end
            ChamsStyle = Flags[source.StyleFlag] or "Flat"
            UseSilhouette(ChamsStyle == "Flat")
            Dummy.ImageColor3 = rgb(255, 255, 255)
            Dummy.ImageTransparency = 0
            ChamsOverlay.ImageColor3 = col
            ChamsOverlay.ImageTransparency = alpha
            local outlineTransparency = ChamsStyle == "Normal" and alpha or 1
            for _, outline in ChamsOutlines do
                outline.ImageColor3 = col
                outline.ImageTransparency = outlineTransparency
            end
        end
        local ChamsButtons = {}
        local function RefreshChamsButtons()
            for _, entry in ChamsButtons do
                local active = (entry.Kind == "Team" and ChamsState.Team == entry.Value)
                    or (entry.Kind == "Mode" and ChamsState.Mode == entry.Value)
                entry.Button.TextColor3 = active and themes.preset.accent or rgb(150, 150, 150)
                entry.Button.BackgroundColor3 = active and rgb(34, 34, 34) or rgb(22, 22, 22)
            end
        end
        for order, info in {
            {Text = "Enemy", Kind = "Team", Value = "Enemy"};
            {Text = "Team", Kind = "Team", Value = "Team"};
            {Text = "Visible", Kind = "Mode", Value = "Visible"};
            {Text = "Invisible", Kind = "Mode", Value = "Invisible"};
        } do
            local button = Library:Create("TextButton", {
                Parent = ChamsBar;
                Name = "\0";
                Text = info.Text;
                AutoButtonColor = false;
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                TextSize = 12;
                TextColor3 = rgb(150, 150, 150);
                Size = dim2(0, 0, 1, 0);
                LayoutOrder = order;
                BorderSizePixel = 0;
                ZIndex = 5;
                BackgroundColor3 = rgb(22, 22, 22);
            })
            table.insert(ChamsButtons, {Button = button, Kind = info.Kind, Value = info.Value})
            button.MouseButton1Click:Connect(function()
                ChamsState[info.Kind] = info.Value
                RefreshChamsButtons()
                RefreshChams()
            end)
        end
        for _, team in ChamsSources do
            for _, source in team do
                local previousToggle = source.Toggle.Callback
                source.Toggle.Callback = function(...)
                    if previousToggle then
                        previousToggle(...)
                    end
                    RefreshChams()
                end
                if source.Style then
                    local previousStyle = source.Style.Callback
                    source.Style.Callback = function(...)
                        if previousStyle then
                            previousStyle(...)
                        end
                        RefreshChams()
                    end
                end
                local swatch = source.Picker.Items and source.Picker.Items.InnerObject
                if swatch then
                    swatch:GetPropertyChangedSignal("BackgroundColor3"):Connect(RefreshChams)
                    swatch:GetPropertyChangedSignal("BackgroundTransparency"):Connect(RefreshChams)
                end
            end
        end
        RefreshChamsButtons()
        RefreshChams()
        local Slots = {}
        local function MakeSlot(id, props)
            local holder = Library:Create("Frame", {
                Parent = Target;
                Name = "\0";
                AnchorPoint = props.Anchor;
                Position = props.Position;
                Size = props.Size;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ZIndex = 10;
                BackgroundColor3 = rgb(255, 255, 255);
            })
            Library:Create("UIListLayout", {
                Parent = holder;
                Padding = dim(0, 1);
                HorizontalAlignment = props.Horizontal;
                VerticalAlignment = props.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
            })
            local slot = {
                Id = id;
                Holder = holder;
                Align = props.Align or Enum.TextXAlignment.Center;
                BasePosition = props.Position;
                Side = props.Side;
            }
            table.insert(Slots, slot)
            return slot
        end
        local function FindSlot(id)
            for _, slot in Slots do
                if slot.Id == id then
                    return slot
                end
            end
        end
        for _, side in {"Top", "Bottom"} do
            local isTop = side == "Top"
            for _, part in {"Left", "Center", "Right"} do
                local anchorX = part == "Left" and 0 or (part == "Center" and 0.5 or 1)
                MakeSlot(side .. part, {
                    Side = side;
                    Anchor = vec2(anchorX, isTop and 1 or 0);
                     
                    Position = dim2(part == "Left" and 0.10 or (part == "Center" and 0.5 or 0.90),
                        not isTop and (part == "Left" and -12 or (part == "Right" and 12 or 0)) or 0,
                        isTop and 0 or 1, isTop and -3 or 3);
                    Size = dim2(0.55, 0, 0, isTop and 30 or 46);
                    Horizontal = part == "Left" and Enum.HorizontalAlignment.Left
                        or (part == "Center" and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Right);
                    Vertical = isTop and Enum.VerticalAlignment.Bottom or Enum.VerticalAlignment.Top;
                    Align = part == "Left" and Enum.TextXAlignment.Left
                        or (part == "Center" and Enum.TextXAlignment.Center or Enum.TextXAlignment.Right);
                })
            end
        end
        for _, side in {"Left", "Right"} do
            local isLeft = side == "Left"
            for _, part in {"Top", "Middle", "Bottom"} do
                local anchorY = part == "Top" and 0 or (part == "Middle" and 0.5 or 1)
                MakeSlot(side .. part, {
                    Side = side;
                    Anchor = vec2(isLeft and 1 or 0, anchorY);
                    Position = dim2(isLeft and 0 or 1, isLeft and -3 or 3, anchorY, 0);
                    Size = dim2(0, 74, 0.34, 0);
                    Horizontal = isLeft and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left;
                    Vertical = part == "Top" and Enum.VerticalAlignment.Top
                        or (part == "Middle" and Enum.VerticalAlignment.Center or Enum.VerticalAlignment.Bottom);
                    Align = isLeft and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left;
                })
            end
        end
        SlotList = Slots
        local function MakeText(text, slotId, color, order, textSize)
            local slot = FindSlot(slotId)
            return Library:Create("TextLabel", {
                Parent = slot.Holder;
                Name = "\0";
                Text = text;
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                TextSize = textSize or 12;
                TextColor3 = color or rgb(235, 235, 235);
                TextStrokeTransparency = 0;
                BackgroundTransparency = 1;
                 
                Size = dim2(0, 0, 0, 13);
                AutomaticSize = Enum.AutomaticSize.X;
                LayoutOrder = order or 1;
                TextXAlignment = slot.Align;
                BorderSizePixel = 0;
                ZIndex = 11;
                Visible = false;
                BackgroundColor3 = rgb(255, 255, 255);
            })
        end
        local Name = MakeText("Player", "TopCenter", rgb(235, 235, 235), 1)
        local NameSettings = {}
        local function RefreshName()
        end
        local Distance = MakeText("12m", "BottomCenter", rgb(235, 235, 235), 1)
        local DistanceSettings = {Unit = "Meters", Value = 12}
        local function RefreshDistance()
            if DistanceSettings.Unit == "Studs" then
                Distance.Text = math.floor(DistanceSettings.Value * 3.571) .. " studs"
            elseif DistanceSettings.Unit == "Feet" then
                Distance.Text = math.floor(DistanceSettings.Value * 3.281) .. "ft"
            else
                Distance.Text = DistanceSettings.Value .. "m"
            end
        end
        local Ping = MakeText("34ms", "BottomCenter", rgb(235, 235, 235), 2)
        local PingSettings = {Checker = false, Color = rgb(235, 235, 235), Value = 34}
        local function RefreshPing()
            if PingSettings.Checker then
                local value = PingSettings.Value
                if value <= 50 then
                    Ping.TextColor3 = rgb(88, 214, 74)
                elseif value <= 120 then
                    Ping.TextColor3 = rgb(230, 200, 80)
                else
                    Ping.TextColor3 = rgb(214, 79, 79)
                end
            else
                Ping.TextColor3 = PingSettings.Color
            end
        end
         
        local ItemName = MakeText("AK-47", "BottomCenter", rgb(190, 190, 190), 3, 10)
        local ItemSettings = {Text = true}
        Flags.ESPItemText = true
        local function RefreshItem()
            ItemName.Text = ItemSettings.Text and "AK-47" or ""
            ItemName.TextTransparency = ItemSettings.Text and 0 or 1
        end
        local Hit = MakeText("Hit", "RightTop", rgb(214, 79, 79), 1)
        local Elements = {
            {Name = "Box", Objects = {Box}},
            {Name = "Health", Objects = {Health}, Slot = "LeftMiddle", Bar = {Fill = HealthFill, Thickness = 4}},
            {Name = "Name", Objects = {Name}, Slot = "TopCenter"},
            {Name = "Distance", Objects = {Distance}, Slot = "BottomCenter"},
            {Name = "Ping", Objects = {Ping}, Slot = "BottomCenter"},
            {Name = "Item", Objects = {ItemName}, Slot = "BottomCenter"},
            {Name = "Hit", Objects = {Hit}, Slot = "RightTop"},
        }
        for _, element in Elements do
            if element.Bar then
                table.insert(Bars, {Element = element, Bar = element.Bar})
            end
        end
        local Dragging = nil
        local Ghost = nil
        local function ClosestSlot()
            local mousePos = InputService:GetMouseLocation()
            local point = vec2(mousePos.X, mousePos.Y - gui_offset)
            local best, bestDist = nil, math.huge
            for _, slot in Slots do
                local holder = slot.Holder
                local center = holder.AbsolutePosition + (holder.AbsoluteSize / 2)
                local distance = (center - point).Magnitude
                if distance < bestDist then
                    bestDist = distance
                    best = slot
                end
            end
            return best
        end
        for _, element in Elements do
            if not element.Slot then
                continue
            end
            local object = element.Objects[1]
            object.Active = true
            object.Selectable = false
            local function BeginDrag(input)
                if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                    return
                end
                if Dragging then
                    return
                end
                if Ghost then
                    Ghost:Destroy()
                    Ghost = nil
                end
                Dragging = element
                Library.DragLock = true
                local mousePos = InputService:GetMouseLocation()
                local origin = PreviewInline.AbsolutePosition
                local position = dim2(
                    0, mousePos.X - origin.X,
                    0, mousePos.Y - gui_offset - origin.Y
                )
                if element.Bar then
                    object.BackgroundTransparency = 0.65
                    element.Bar.Fill.BackgroundTransparency = 0.65
                    Ghost = Library:Create("Frame", {
                        Parent = PreviewInline;
                        Name = "\0";
                        AnchorPoint = vec2(0.5, 0.5);
                        Position = position;
                        Size = dim2(0, object.AbsoluteSize.X, 0, object.AbsoluteSize.Y);
                        BorderSizePixel = 0;
                        Visible = false;
                        ZIndex = 15;
                        BackgroundColor3 = element.Bar.Fill.BackgroundColor3;
                    })
                    Ghost:SetAttribute("Short", element.Bar.Thickness)
                else
                    object.TextTransparency = 0.65
                    Ghost = Library:Create("TextLabel", {
                        Parent = PreviewInline;
                        Name = "\0";
                        Text = object.Text;
                        FontFace = object.FontFace;
                        TextSize = object.TextSize;
                        TextColor3 = object.TextColor3;
                        TextStrokeTransparency = 0;
                        BackgroundTransparency = 1;
                        AutomaticSize = Enum.AutomaticSize.XY;
                        AnchorPoint = vec2(0.5, 0.5);
                        Position = position;
                        Visible = false;
                        BorderSizePixel = 0;
                        ZIndex = 15;
                        BackgroundColor3 = rgb(255, 255, 255);
                    })
                end
                Ghost.Visible = true
            end
             
            element.BeginPreviewDrag = BeginDrag
        end
        Library:Connection(InputService.InputBegan, function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 or Dragging then
                return
            end
            local ancestor = Preview
            while ancestor do
                if ancestor:IsA("GuiObject") and not ancestor.Visible then return end
                if ancestor:IsA("ScreenGui") and not ancestor.Enabled then return end
                ancestor = ancestor.Parent
            end
            local mouse = InputService:GetMouseLocation()
            local point = vec2(mouse.X, mouse.Y - gui_offset)
            local selected, best = nil, math.huge
            for _, element in Elements do
                local object = element.Objects[1]
                if not element.BeginPreviewDrag or not object.Visible then continue end
                local pos, size = object.AbsolutePosition, object.AbsoluteSize
                local left, top, width, height = pos.X, pos.Y, size.X, size.Y
                if not element.Bar then
                    if object.Text == "" or object.TextTransparency >= 1 then continue end
                    local bounds = object.TextBounds
                    width, height = bounds.X, bounds.Y
                    if object.TextXAlignment == Enum.TextXAlignment.Center then
                        left = pos.X + (size.X - width) * 0.5
                    elseif object.TextXAlignment == Enum.TextXAlignment.Right then
                        left = pos.X + size.X - width
                    end
                    if object.TextYAlignment == Enum.TextYAlignment.Center then
                        top = pos.Y + (size.Y - height) * 0.5
                    elseif object.TextYAlignment == Enum.TextYAlignment.Bottom then
                        top = pos.Y + size.Y - height
                    end
                end
                if point.X >= left - 2 and point.X <= left + width + 2
                    and point.Y >= top - 2 and point.Y <= top + height + 2 then
                    local distance = (point - vec2(left + width * 0.5, top + height * 0.5)).Magnitude
                    if distance < best then
                        selected, best = element, distance
                    end
                end
            end
            if selected then selected.BeginPreviewDrag(input) end
        end)
        Library:Connection(InputService.InputChanged, function(input)
            if not Dragging or not Ghost or input.UserInputType ~= Enum.UserInputType.MouseMovement then
                return
            end
            local mousePos = InputService:GetMouseLocation()
            local origin = PreviewInline.AbsolutePosition
            Ghost.Position = dim2(
                0, mousePos.X - origin.X,
                0, mousePos.Y - gui_offset - origin.Y
            )
            if Dragging.Bar then
                local target = ClosestSlot()
                if target then
                    local vertical = target.Id:match("^Left") or target.Id:match("^Right")
                    local long = vertical and Target.AbsoluteSize.Y or Target.AbsoluteSize.X
                    local short = Ghost:GetAttribute("Short")
                    Ghost.Size = vertical and dim2(0, short, 0, long) or dim2(0, long, 0, short)
                end
            end
        end)
        Library:Connection(InputService.InputEnded, function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end
            if not Dragging then
                if Ghost then
                    Ghost:Destroy()
                    Ghost = nil
                end
                return
            end
            local element = Dragging
            local object = element.Objects[1]
            local target = ClosestSlot()
            if target then
                element.Slot = target.Id
                Flags["ESP" .. element.Name:gsub("%s", "") .. "Slot"] = target.Id
                if element.Bar then
                    LayoutBars()
                else
                    object.Parent = target.Holder
                    object.TextXAlignment = target.Align
                end
            end
            if Ghost then
                Ghost:Destroy()
                Ghost = nil
            end
            if element.Bar then
                object.BackgroundTransparency = 0
                element.Bar.Fill.BackgroundTransparency = 0
            else
                object.TextTransparency = 0
            end
            Dragging = nil
            Library.DragLock = false
        end)
        local Bottom = Library:Create("Frame", {
            Parent = Root;
            Name = "\0";
            AnchorPoint = vec2(0, 0);
            Position = dim2(0, 0, 0, 0);
            Size = dim2(1, 0, 0, 0);
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ZIndex = 3;
            BackgroundColor3 = rgb(255, 255, 255);
        })
        Library:Create("UIListLayout", {
            Parent = Bottom;
            Padding = dim(0, 5);
            SortOrder = Enum.SortOrder.LayoutOrder;
        })
        Library:Create("TextLabel", {
            Parent = Bottom;
            Name = "\0";
            Text = "Elements";
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
            TextSize = 13;
            TextColor3 = rgb(235, 235, 235);
            TextXAlignment = Enum.TextXAlignment.Left;
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 14);
            LayoutOrder = 1;
            ZIndex = 3;
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255);
        })
        local Pool = Library:Create("Frame", {
            Parent = Bottom;
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 2;
            ZIndex = 3;
            BackgroundColor3 = rgb(255, 255, 255);
        })
        Library:Create("UIListLayout", {
            Parent = Pool;
            FillDirection = Enum.FillDirection.Horizontal;
            Wraps = true;
            Padding = dim(0, 4);
            VerticalAlignment = Enum.VerticalAlignment.Top;
            SortOrder = Enum.SortOrder.LayoutOrder;
        })
        local ContextMenu = Library:Create("Frame", {
            Parent = Root;
            Name = "\0";
            Visible = false;
            Size = dim2(0, 156, 0, 0);
            AutomaticSize = Enum.AutomaticSize.Y;
            BorderSizePixel = 0;
            ZIndex = 30000;
            BackgroundColor3 = rgb(12, 12, 12);
        })
        local ContextBorder = Library:Create("Frame", {
            Parent = ContextMenu;
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            Size = dim2(1, -2, 1, -2);
            AutomaticSize = Enum.AutomaticSize.Y;
            BorderSizePixel = 0;
            ZIndex = 30001;
            BackgroundColor3 = rgb(40, 40, 40);
        })
        local ContextInline = Library:Create("Frame", {
            Parent = ContextBorder;
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            Size = dim2(1, -2, 1, -2);
            AutomaticSize = Enum.AutomaticSize.Y;
            BorderSizePixel = 0;
            ZIndex = 30002;
            BackgroundColor3 = rgb(23, 23, 23);
        })
        Library:Create("UIListLayout", {
            Parent = ContextInline;
            Padding = dim(0, 6);
            SortOrder = Enum.SortOrder.LayoutOrder;
        })
        Library:Create("UIPadding", {
            Parent = ContextInline;
            PaddingTop = dim(0, 7);
            PaddingBottom = dim(0, 9);
            PaddingLeft = dim(0, 8);
            PaddingRight = dim(0, 8);
        })
        local ContextTitle = Library:Create("TextLabel", {
            Parent = ContextInline;
            Name = "\0";
            Text = "Box";
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
            TextSize = 13;
            TextColor3 = themes.preset.accent;
            TextXAlignment = Enum.TextXAlignment.Left;
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 13);
            LayoutOrder = 1;
            BorderSizePixel = 0;
            ZIndex = 30002;
            BackgroundColor3 = rgb(255, 255, 255);
        })
        Library:Create("Frame", {
            Parent = ContextInline;
            Name = "\0";
            Size = dim2(1, 0, 0, 1);
            LayoutOrder = 2;
            BorderSizePixel = 0;
            ZIndex = 30002;
            BackgroundColor3 = rgb(45, 45, 45);
        })
        local BoxSection = MakeSection(ContextInline)
        local StyleCombo = MakeCombo(BoxSection, "Type", 3, {"Full", "Corner"}, Root, false, "Full")
        StyleCombo.Callback = function(value)
            BoxSettings.Style = value
            Flags.ESPBoxStyle = value
            RefreshBox()
        end
        Flags.ESPBoxStyle = BoxSettings.Style
        local _, BoxHost = MakeColorRow(BoxSection, "Color", 6)
        local BoxPicker = LiftPicker(BoxHost:Colorpicker({
            Flag = "ESPBoxColor";
            Color = PickerColor(rgb(255, 255, 255));
        }))
        do
            local swatch = BoxPicker.Items and BoxPicker.Items.InnerObject
            if swatch then
                local function Sync()
                    BoxSettings.Color = swatch.BackgroundColor3
                    BoxSettings.Transparency = swatch.BackgroundTransparency
                    RefreshBox()
                end
                swatch:GetPropertyChangedSignal("BackgroundColor3"):Connect(Sync)
                swatch:GetPropertyChangedSignal("BackgroundTransparency"):Connect(Sync)
                Sync()
            end
        end
        local HealthSection = MakeSection(ContextInline)
        MakeCheckbox(HealthSection, "Text", 1, function(state)
            HealthSettings.Text = state
            Flags.ESPHealthText = state
            RefreshHealth()
        end)
        local _, HealthHost = MakeColorRow(HealthSection, "Color", 3, 44)
        local HealthPicker = LiftPicker(HealthHost:Colorpicker({
            Flag = "ESPHealthColor";
            Color = PickerColor(rgb(88, 214, 74));
        }))
        local HealthPickerTo = LiftPicker(HealthHost:Colorpicker({
            Flag = "ESPHealthColorTo";
            Color = PickerColor(rgb(214, 79, 79));
        }))
        local function RefreshGradientVisibility()
            local object = HealthPickerTo.Items and HealthPickerTo.Items.ColorpickerObject
            if object then
                object.Visible = HealthSettings.Gradient
            end
            if not HealthSettings.Gradient and HealthPickerTo.Open then
                HealthPickerTo.Open = false
                HealthPickerTo.SetVisible(false)
            end
        end
        MakeCheckbox(HealthSection, "Gradient", 2, function(state)
            HealthSettings.Gradient = state
            Flags.ESPHealthGradient = state
            RefreshGradientVisibility()
            RefreshHealth()
        end)
        for _, entry in {{HealthPicker, "Color"}, {HealthPickerTo, "ColorTo"}} do
            local swatch = entry[1].Items and entry[1].Items.InnerObject
            if swatch then
                local function Sync()
                    HealthSettings[entry[2]] = swatch.BackgroundColor3
                    RefreshHealth()
                end
                swatch:GetPropertyChangedSignal("BackgroundColor3"):Connect(Sync)
                Sync()
            end
        end
        RefreshGradientVisibility()
        RefreshHealth()
        local NameSection = MakeSection(ContextInline)
        local DraggingAvatar = false  
        local _, NameHost = MakeColorRow(NameSection, "Color", 1)
        local NamePicker = LiftPicker(NameHost:Colorpicker({
            Flag = "ESPNameColor";
            Color = PickerColor(rgb(235, 235, 235));
        }))
        do
            local swatch = NamePicker.Items and NamePicker.Items.InnerObject
            if swatch then
                swatch:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
                    Name.TextColor3 = swatch.BackgroundColor3
                end)
            end
        end
        RefreshName()
        local DistSection = MakeSection(ContextInline)
        local DistCombo = MakeCombo(DistSection, "Units", 1, {"Meters", "Studs", "Feet"}, Root, false, "Meters")
        local DistList = DistCombo.List
        DistCombo.Callback = function(value)
            DistanceSettings.Unit = value
            Flags.ESPDistanceUnit = value
            RefreshDistance()
        end
        local _, DistHost = MakeColorRow(DistSection, "Color", 3)
        local DistPicker = LiftPicker(DistHost:Colorpicker({
            Flag = "ESPDistanceColor";
            Color = PickerColor(rgb(235, 235, 235));
        }))
        do
            local swatch = DistPicker.Items and DistPicker.Items.InnerObject
            if swatch then
                swatch:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
                    Distance.TextColor3 = swatch.BackgroundColor3
                end)
            end
        end
        RefreshDistance()
        local PingSection = MakeSection(ContextInline)
        local PingColorRow, PingHost = MakeColorRow(PingSection, "Color", 2)
        MakeCheckbox(PingSection, "Ping checker", 1, function(state)
            PingSettings.Checker = state
            Flags.ESPPingChecker = state
            PingColorRow.Visible = not state
            RefreshPing()
        end)
        local PingPicker = LiftPicker(PingHost:Colorpicker({
            Flag = "ESPPingColor";
            Color = PickerColor(rgb(235, 235, 235));
        }))
        do
            local swatch = PingPicker.Items and PingPicker.Items.InnerObject
            if swatch then
                swatch:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
                    PingSettings.Color = swatch.BackgroundColor3
                    RefreshPing()
                end)
            end
        end
        RefreshPing()
        local ItemSection = MakeSection(ContextInline)
        local ItemPickers = {}
        ItemSettings.Text = true
        Flags.ESPItemText = true
        local ItemRow, ItemHost = MakeColorRow(ItemSection, "Color", 1)
        local ItemPicker = LiftPicker(ItemHost:Colorpicker({
            Flag = "ESPItemTextColor";
            Color = PickerColor(rgb(190, 190, 190));
        }))
        do
            local swatch = ItemPicker.Items and ItemPicker.Items.InnerObject
            if swatch then
                swatch:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
                    ItemName.TextColor3 = swatch.BackgroundColor3
                end)
            end
        end
        table.insert(ItemPickers, {Row = ItemRow, Picker = ItemPicker})
        RefreshItem()
        local HitSection = MakeSection(ContextInline)
        -- Мигающий хитбокс на манекене (голова - куда аимится чит): в превью
        -- пикер красит именно его, а не текст Hit.
        local HitboxDummy = Library:Create("Frame", {
            Parent = Target;
            Name = "\0";
            AnchorPoint = vec2(0.5, 0);
            Position = dim2(0.5, 0, 0.02, 0);
            Size = dim2(0.22, 0, 0.13, 0);
            BackgroundColor3 = rgb(214, 79, 79);
            BackgroundTransparency = 0.35;
            BorderSizePixel = 0;
            ZIndex = 12;
            Visible = Flags.ESPHitboxVisual == true;
            BackgroundColor3 = rgb(214, 79, 79);
        })
        local HitboxAlpha = 0
        local HitboxCorner = Library:Create("UICorner", {
            Parent = HitboxDummy;
            CornerRadius = dim(0, 0);
        })
        local function SyncHitboxShape(value)
            HitboxCorner.CornerRadius = value == "Circle" and dim(0.5, 0) or dim(0, 0)
        end
        MakeCheckbox(HitSection, "Visual hitbox", 1, function(state)
            Flags.ESPHitboxVisual = state
            HitboxDummy.Visible = state
        end, Flags.ESPHitboxVisual == true)
        local _, HitHost = MakeColorRow(HitSection, "Color", 2)
        local HitPicker = LiftPicker(HitHost:Colorpicker({
            Flag = "ESPHitboxColor";
            Color = PickerColor(rgb(214, 79, 79));
        }))
        local HitShapeCombo = MakeCombo(HitSection, "Shape", 3, {"Box", "Circle"}, Root, false, Flags.ESPHitboxShape or "Box")
        HitShapeCombo.Callback = function(value)
            Flags.ESPHitboxShape = value
            SyncHitboxShape(value)
        end
        Flags.ESPHitboxShape = Flags.ESPHitboxShape or "Box"
        SyncHitboxShape(Flags.ESPHitboxShape)
        do
            local swatch = HitPicker.Items and HitPicker.Items.InnerObject
            if swatch then
                local function Sync()
                    HitboxDummy.BackgroundColor3 = swatch.BackgroundColor3
                    HitboxAlpha = swatch.BackgroundTransparency
                    HitboxDummy.BackgroundTransparency = 0.35 + 0.65 * HitboxAlpha
                end
                swatch:GetPropertyChangedSignal("BackgroundColor3"):Connect(Sync)
                swatch:GetPropertyChangedSignal("BackgroundTransparency"):Connect(Sync)
                Sync()
            end
        end
        -- Lua API (3.0): расширения превью. Скрипты добавляют свои чипы в
        -- полосу под моделью и свои пункты в контекстные меню готовых чипов.
        local LuaContextItems = {}
        local LuaContextSection = MakeSection(ContextInline)
        local function RebuildLuaContext(name)
            for _, child in ipairs(LuaContextSection:GetChildren()) do
                if child:IsA("GuiObject") then
                    child:Destroy()
                end
            end
            local defs = LuaContextItems[name]
            LuaContextSection.Visible = defs ~= nil and #defs > 0
            if not defs then
                return
            end
            local order = 1
            for _, def in ipairs(defs) do
                if def.kind == "combobox" then
                    local combo = MakeCombo(LuaContextSection, def.name, order, def.options or {}, Root, false, Library.Flags[def.flag] or def.default)
                    combo.Callback = function(value)
                        Library.Flags[def.flag] = value
                        if def.callback then
                            pcall(def.callback, value)
                        end
                    end
                else
                    local cb = MakeCheckbox(LuaContextSection, def.name, order, function(state)
                        Library.Flags[def.flag] = state
                        if def.callback then
                            pcall(def.callback, state)
                        end
                    end, Library.Flags[def.flag] == true)
                    ConfigFlags[def.flag] = function(value)
                        cb.Set(value == true)
                    end
                end
                order = order + 1
            end
        end
        local function AddPreviewChip(def)
            local flagName = def.flag or ("ESP" .. tostring(def.name):gsub("%s", ""))
            local Chip = Library:Create("TextButton", {
                Parent = Pool;
                Name = "\0";
                Text = tostring(def.name);
                AutoButtonColor = false;
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                TextSize = 12;
                TextColor3 = rgb(150, 150, 150);
                AutomaticSize = Enum.AutomaticSize.X;
                Size = dim2(0, 0, 0, 18);
                LayoutOrder = 900;
                BorderSizePixel = 0;
                ZIndex = 4;
                BackgroundColor3 = rgb(26, 26, 26);
            })
            Library:Create("UIPadding", {
                Parent = Chip;
                PaddingLeft = dim(0, 6);
                PaddingRight = dim(0, 6);
            })
            local value = Library.Flags[flagName]
            if value == nil then
                value = def.default
            end
            if def.kind == "combobox" and value == nil then
                value = (def.options or {})[1]
            end
            local function RefreshChip()
                local on = def.kind == "combobox" or value == true
                Chip.TextColor3 = on and themes.preset.accent or rgb(150, 150, 150)
                Chip.BackgroundColor3 = on and rgb(34, 34, 34) or rgb(26, 26, 26)
                Chip.Text = def.kind == "combobox" and (tostring(def.name) .. ": " .. tostring(value)) or tostring(def.name)
            end
            local function SetValue(nextValue, fire)
                value = nextValue
                Library.Flags[flagName] = value
                RefreshChip()
                if fire ~= false and def.callback then
                    pcall(def.callback, value)
                end
            end
            Chip.MouseButton1Click:Connect(function()
                if def.kind == "combobox" then
                    local options = def.options or {}
                    if #options == 0 then
                        return
                    end
                    local index = 1
                    for i, option in ipairs(options) do
                        if option == value then
                            index = i
                            break
                        end
                    end
                    SetValue(options[index % #options + 1])
                else
                    SetValue(not value)
                end
            end)
            ConfigFlags[flagName] = function(configValue)
                SetValue(configValue, false)
            end
            SetValue(value, false)
            return Chip
        end
        Library.PreviewHooks = {
            AddChip = AddPreviewChip,
            Extend = function(elementName, def)
                LuaContextItems[elementName] = LuaContextItems[elementName] or {}
                table.insert(LuaContextItems[elementName], def)
            end,
            Elements = function()
                local names = {}
                for _, element in ipairs(Elements) do
                    names[#names + 1] = element.Name
                end
                return names
            end,
        }
        local ContextChip = nil
        local function CloseAllLists()
            for _, combo in AllCombos do
                combo.List.Visible = false
            end
        end
        local function CloseContext()
            ContextChip = nil
            ContextMenu.Visible = false
            CloseAllLists()
            for _, picker in {BoxPicker, HealthPicker, HealthPickerTo, NamePicker, DistPicker, PingPicker, HitPicker} do
                if picker.Open then
                    picker.Open = false
                    picker.SetVisible(false)
                end
            end
            for _, entry in ItemPickers do
                if entry.Picker.Open then
                    entry.Picker.Open = false
                    entry.Picker.SetVisible(false)
                end
            end
        end
        local function FollowChip()
            if not ContextChip or not ContextMenu.Visible then
                return
            end
            local rel = ContextChip.AbsolutePosition - Root.AbsolutePosition
            local chipSize = ContextChip.AbsoluteSize
            ContextMenu.Position = dim2(0, rel.X, 0, rel.Y + chipSize.Y)
        end
        local function OpenContext(name, chip)
            ContextTitle.Text = name
            ContextChip = chip
            BoxSection.Visible = name == "Box"
            HealthSection.Visible = name == "Health"
            NameSection.Visible = name == "Name"
            DistSection.Visible = name == "Distance"
            PingSection.Visible = name == "Ping"
            ItemSection.Visible = name == "Item"
            HitSection.Visible = name == "Hit"
            RebuildLuaContext(name)
            CloseAllLists()
            ContextMenu.AnchorPoint = vec2(0, 0)
            ContextMenu.Visible = true
            FollowChip()
        end
        Library:Connection(RunService.RenderStepped, FollowChip)
        table.insert(Library.ExtraClosers, CloseContext)
        Library:Connection(InputService.InputBegan, function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end
            if not ContextMenu.Visible then
                return
            end
            local function NearObject(object, padding)
                if not object or not object.Visible then
                    return false
                end
                local mouse = InputService:GetMouseLocation()
                local point = vec2(mouse.X, mouse.Y - gui_offset)
                local topLeft = object.AbsolutePosition - vec2(padding, padding)
                local bottomRight = object.AbsolutePosition + object.AbsoluteSize + vec2(padding, padding)
                return point.X >= topLeft.X and point.X <= bottomRight.X
                    and point.Y >= topLeft.Y and point.Y <= bottomRight.Y
            end
            if NearObject(ContextMenu, 6) then
                return
            end
            if NearObject(StyleList, 6) then
                return
            end
            if NearObject(DistList, 6) then
                return
            end
            if DraggingAvatar then
                return
            end
            for _, picker in {BoxPicker, HealthPicker, HealthPickerTo, NamePicker, DistPicker, PingPicker, HitPicker} do
                if picker.Open then
                    return
                end
                if NearObject(picker.Items and picker.Items.Colorpicker, 14) then
                    return
                end
            end
            for _, entry in ItemPickers do
                if entry.Picker.Open then
                    return
                end
                if NearObject(entry.Picker.Items and entry.Picker.Items.Colorpicker, 14) then
                    return
                end
            end
            CloseContext()
        end)
        RefreshBox()
        for index, element in Elements do
            local Chip = Library:Create("TextButton", {
                Parent = Pool;
                Name = "\0";
                Text = element.Name;
                AutoButtonColor = false;
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                TextSize = 12;
                TextColor3 = rgb(150, 150, 150);
                AutomaticSize = Enum.AutomaticSize.X;
                Size = dim2(0, 0, 0, 18);
                LayoutOrder = index;
                BorderSizePixel = 0;
                ZIndex = 4;
                BackgroundColor3 = rgb(26, 26, 26);
            })
            Library:Create("UIPadding", {
                Parent = Chip;
                PaddingLeft = dim(0, 6);
                PaddingRight = dim(0, 6);
            })
            local Flag = "ESP" .. element.Name:gsub("%s", "")
            element.Slot = Flags[Flag .. "Slot"] or element.Slot
            Flags[Flag] = false
            if Flags[Flag .. "Slot"] == nil then Flags[Flag .. "Slot"] = element.Slot end
            local function Set(bool)
                ESPFlags[element.Name] = bool
                Flags[Flag] = bool
                for _, object in element.Objects do
                    object.Visible = bool
                end
                LayoutBars()
                if element.Name == "Health" then
                    RefreshHealth()
                elseif element.Name == "Name" then
                    RefreshName()
                elseif element.Name == "Item" then
                    RefreshItem()
                end
                Chip.TextColor3 = bool and themes.preset.accent or rgb(150, 150, 150)
                Chip.BackgroundColor3 = bool and rgb(34, 34, 34) or rgb(26, 26, 26)
            end
            Chip.MouseButton1Click:Connect(function()
                Set(not ESPFlags[element.Name])
            end)
            if element.Name == "Box" or element.Name == "Health" or element.Name == "Name" or element.Name == "Distance" or element.Name == "Ping" or element.Name == "Item" or element.Name == "Hit" then
                Chip.MouseButton2Click:Connect(function()
                    if ContextMenu.Visible and ContextTitle.Text == element.Name then
                        CloseContext()
                    else
                        OpenContext(element.Name, Chip)
                    end
                end)
            end
            ConfigFlags[Flag] = Set
            Set(false)
            local slot = FindSlot(element.Slot)
            if slot and not element.Bar then
                for _, object in element.Objects do
                    object.Parent = slot.Holder
                    object.TextXAlignment = slot.Align
                end
            end
        end
        local function ResizePreview()
            Preview.Size = dim2(1, 0, 1, -(Bottom.AbsoluteSize.Y + 28))
            Bottom.Position = dim2(0, 0, 0, Preview.Position.Y.Offset + Preview.AbsoluteSize.Y + 6)
        end
        Bottom:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizePreview)
        Preview:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizePreview)
        ResizePreview()
        LayoutBars()
        for _, name in {"Box", "Health"} do
            if ConfigFlags["ESP" .. name:gsub("%s", "")] then
                ConfigFlags["ESP" .. name:gsub("%s", "")](true)
            end
        end
    end)
    if not PreviewOk then
        warn("[gamesense] Preview ESP error: " .. tostring(PreviewErr))
    end
    local Transparent = RightBottom:Toggle({Name = "Transparent", Flag = "VisTransparent"})
    local TransparentWalls = RightBottom:Slider({
        Name = "Transparent walls",
        Min = 0,
        Max = 100,
        Default = 50,
        Suffix = "%",
        Flag = "VisTransparentWalls"
    })
    local TransparentProps = RightBottom:Slider({
        Name = "Transparent props",
        Min = 0,
        Max = 100,
        Default = 50,
        Suffix = "%",
        Flag = "VisTransparentProps"
    })
    BindVisibility(Transparent, {TransparentWalls, TransparentProps})

    local Thirdperson = RightBottom:Toggle({
        Name = "Thirdperson",
        Flag = "VisThirdperson"
    })
    AddMenuBind(Thirdperson, "VisThirdpersonBind", true)
    local ThirdpersonDistance = RightBottom:Slider({
        Name = "Thirdperson distance",
        Min = 0,
        Max = 30,
        Default = 10,
        Decimal = 1,
        Flag = "VisThirdpersonDistance"
    })
    BindVisibility(Thirdperson, {ThirdpersonDistance})
    local FOVChanger = RightBottom:Toggle({Name = "FOV changer", Flag = "VisFOVChangerEnabled"})
    local FOVSlider = RightBottom:Slider({
        Min = 60,
        Max = 120,
        Default = 70,
        Decimal = 1,
        Suffix = "°",
        Flag = "VisFOVChanger"
    })
    BindVisibility(FOVChanger, {FOVSlider})
    local ZoomToggle = RightBottom:Toggle({Name = "Camera zoom", Flag = "VisCameraZoom"})
    AddMenuBind(ZoomToggle, "VisCameraZoomBind", true)
    local ZoomSlider = RightBottom:Slider({
        Min = 10,
        Max = 120,
        Default = 40,
        Decimal = 1,
        Suffix = "°",
        Flag = "VisCameraZoomValue"
    })
    BindVisibility(ZoomToggle, {ZoomSlider})
    Tabs.Lighting.Visuals = {
        LeftTop = LeftTop, LeftBottom = LeftBottom,
        RightTop = RightTop, RightBottom = RightBottom,
    }
end
do
    local Page = Tabs.Settings.Items.Page
    for _, child in pairs(Page:GetChildren()) do
        if child:IsA("UIListLayout") then
            child.HorizontalFlex = Enum.UIFlexAlignment.None
        end
    end
    Tabs.Settings.Items.Left.Size = dim2(0.5, -10, 1, 0)
    Tabs.Settings.Items.Right.Size = dim2(0.5, -10, 1, 0)
    for _, column in {Tabs.Settings.Items.Left, Tabs.Settings.Items.Right} do
        for _, child in pairs(column:GetChildren()) do
            if child:IsA("UIListLayout") then
                child.VerticalFlex = Enum.UIFlexAlignment.None
            end
        end
    end
    local Misc = Tabs.Settings:Section({Name = "Misc", Side = "Left", Size = 1})
    Misc.Items.Outline.Size = dim2(1, 0, 1, 0)
    local FPSToggle = Misc:Toggle({Name = "FPS unlocker", Flag = "MiscFPSUnlocker"})
    local FPSSlider = Misc:Slider({
        Min = 60,
        Max = 999,
        Default = 240,
        Decimal = 1,
        Suffix = " fps",
        Flag = "MiscFPSValue"
    })
    BindVisibility(FPSToggle, {FPSSlider})
    local RemovalsToggle = Misc:Toggle({Name = "Removals", Flag = "MiscRemovals"})
    local RemovalsList = Misc:Dropdown({
        Options = {"Particles", "Textures", "Shadows", "Terrain decoration", "Post effects"},
        Multi = true,
        Default = {"Particles", "Shadows"},
        Flag = "MiscRemovalsList"
    })
    BindVisibility(RemovalsToggle, {RemovalsList})
    Misc:Toggle({Name = "Anti-fling", Flag = "MiscAntiFling"})
    Misc:Toggle({Name = "Hide name", Flag = "MiscHideName"})
    Misc:Toggle({Name = "Fast reload", Flag = "MiscFastReload"})
    local Movement = Tabs.Settings:Section({Name = "Movement", Side = "Right", Size = 0.55})
    Movement.Items.Outline.Size = dim2(1, 0, 0.55, -10)
    local SettingsSection = Tabs.Settings:Section({Name = "Settings", Side = "Right", Size = 0.45})
    SettingsSection.Items.Outline.Size = dim2(1, 0, 0.45, -9)
    local FlyToggle = Movement:Toggle({Name = "Fly", Flag = "MovementFly"})
    AddMenuBind(FlyToggle, "MovementFlyBind", true)
    local FlySpeed = Movement:Slider({
        Name = "Speed",
        Min = 0,
        Max = 200,
        Default = 50,
        Decimal = 1,
        Flag = "MovementFlySpeed"
    })
    BindVisibility(FlyToggle, {FlySpeed})
    local SpeedhackToggle = Movement:Toggle({Name = "Speedhack", Flag = "MovementSpeedhack"})
    AddMenuBind(SpeedhackToggle, "MovementSpeedhackBind", true)
    local SpeedhackSpeed = Movement:Slider({
        Name = "Speed",
        Min = 0,
        Max = 200,
        Default = 50,
        Decimal = 1,
        Flag = "MovementSpeedhackSpeed"
    })
    BindVisibility(SpeedhackToggle, {SpeedhackSpeed})
    local ClickTPToggle = Movement:Toggle({Name = "Click teleport", Flag = "MovementClickTP"})
    AddMenuBind(ClickTPToggle, "MovementClickTPBind", true)
    Movement:Toggle({Name = "Infinite jump", Flag = "MovementInfJump"})
    local JumpPowerToggle = Movement:Toggle({Name = "Jump power", Flag = "MovementJumpPower"})
    AddMenuBind(JumpPowerToggle, "MovementJumpPowerBind", true)
    local JumpPowerSlider = Movement:Slider({
        Min = 0,
        Max = 300,
        Default = 50,
        Decimal = 1,
        Flag = "MovementJumpPowerValue"
    })
    BindVisibility(JumpPowerToggle, {JumpPowerSlider})
    local GravityToggle = Movement:Toggle({Name = "Gravity", Flag = "MovementGravity"})
    AddMenuBind(GravityToggle, "MovementGravityBind", true)
    local GravitySlider = Movement:Slider({
        Min = 0,
        Max = 400,
        Default = 196,
        Decimal = 1,
        Flag = "MovementGravityValue"
    })
    BindVisibility(GravityToggle, {GravitySlider})
    local WalkOnToggle = Movement:Toggle({Name = "Walk on", Flag = "MovementWalkOn"})
    AddMenuBind(WalkOnToggle, "MovementWalkOnBind", true)
    local WalkOnMode = Movement:Dropdown({
        Options = {"Always", "Water", "Void"},
        Default = "Water",
        Flag = "MovementWalkOnMode"
    })
    BindVisibility(WalkOnToggle, {WalkOnMode})
    local MenuKeyToggle = SettingsSection:Toggle({
        Name = "Menu key",
        Flag = "MenuKeyEnabled",
        Default = true
    })
    MenuKeyToggle.Items.Holder.Visible = false
    MenuKeyToggle.Items.Title.Position = dim2(0, 0, 0, -4)
    do
        local binding = false
        local blockClick = false
        local BindButton = Library:Create("TextButton", {
            Active = true;
            AutoButtonColor = false;
            Parent = MenuKeyToggle.Items.Components;
            Name = "";
            Text = "[END]";
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
            TextColor3 = rgb(170, 170, 170);
            TextSize = 11;
            Size = dim2(0, 32, 0, 9);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            BackgroundColor3 = rgb(12, 12, 12);
            ZIndex = 2;
        })
        Library.MenuKey = Enum.KeyCode.End
        Flags.MenuKey = tostring(Library.MenuKey)

        local function SetMenuKey(key)
            if key == nil or key == "NONE" or key == "Enum.KeyCode.Unknown" or key == "Unknown" then
                Library.MenuKey = nil
                BindButton.Text = "[NONE]"
            else
                if typeof(key) == "EnumItem" then
                    Library.MenuKey = (key == Enum.KeyCode.Escape and nil) or key
                elseif type(key) == "string" then
                    if key == "Escape" or key == "Enum.KeyCode.Escape" or key == "NONE" then
                        Library.MenuKey = nil
                    elseif key:find("Enum", 1, true) then
                        local ok, item = pcall(function() return Library:ConvertEnum(key) end)
                        Library.MenuKey = (ok and item ~= Enum.KeyCode.Escape and item) or Enum.KeyCode.End
                    else
                        local ok, item = pcall(function() return Enum.KeyCode[key] end)
                        if not ok or not item then
                            ok, item = pcall(function() return Enum.UserInputType[key] end)
                        end
                        Library.MenuKey = (ok and item ~= Enum.KeyCode.Escape and item) or Enum.KeyCode.End
                    end
                elseif type(key) == "table" and (key.key or key.Key) then
                    SetMenuKey(key.key or key.Key)
                    return
                end
                if Library.MenuKey then
                    local keyName = Keys[Library.MenuKey] or tostring(Library.MenuKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
                    BindButton.Text = "[" .. keyName .. "]"
                else
                    BindButton.Text = "[NONE]"
                end
            end
            Flags.MenuKey = Library.MenuKey and tostring(Library.MenuKey) or "NONE"
        end
        ConfigFlags["MenuKey"] = SetMenuKey

        BindButton.MouseButton1Click:Connect(function()
            if blockClick then
                blockClick = false
                return
            end
            if binding then
                return
            end
            binding = true
            BindButton.Text = "[...]"
            local armed = false
            task.defer(function()
                armed = true
            end)
            local connection
            connection = Library:Connection(InputService.InputBegan, function(input)
                if not binding or not armed then
                    return
                end
                local key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    blockClick = true
                end
                if key == Enum.KeyCode.Escape then
                    Library.MenuKey = nil
                    BindButton.Text = "[NONE]"
                else
                    Library.MenuKey = key
                    local keyName = Keys[key] or tostring(key):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
                    BindButton.Text = "[" .. keyName .. "]"
                end
                Flags.MenuKey = Library.MenuKey and tostring(Library.MenuKey) or "NONE"
                Library.MenuKeyJustBound = true
                binding = false
                connection:Disconnect()
            end)
        end)
    end
    local MenuColorLabel = SettingsSection:Label({Name = "Menu color"})
    MenuColorLabel.Items.Title.Position = dim2(0, 0, 0, -2)
    MenuColorLabel:Colorpicker({
        Flag = "MenuColor",
        Color = PickerColorGlobal(themes.preset.accent),
        Callback = function(color)
            pcall(function()
                Library:RefreshTheme("accent", color)
            end)
        end
    })
    local DPIDropdown = SettingsSection:Dropdown({
        Name = "DPI scale",
        Options = {"100%", "125%", "150%", "175%", "200%"},
        Default = "100%",
        Flag = "DPIScale",
        Callback = function(value)
            local clean = tostring(value):gsub("%%", "")
            local scale = tonumber(clean)
            if not scale then
                return
            end
            pcall(function()
                local window = Library.Window
                if not window then
                    return
                end
                local ui = window:FindFirstChildOfClass("UIScale")
                if not ui then
                    ui = Library:Create("UIScale", {Parent = window})
                end
                ui.Scale = scale / 100
            end)
        end
    })
    DPIDropdown.Items.Title.Position = dim2(0, 0, 0, -2)
    DPIDropdown.Items.Outline.Position = dim2(0, 0, 0, 13)
    DPIDropdown.Items.Outline.Size = dim2(1, -20, 0, 20)
    SettingsSection:Toggle({
        Name = "Anti-untrusted",
        Flag = "AntiUntrusted",
        Default = true,
        Callback = function(state)
            Flags.AntiUntrusted = state
        end
    })
     
     
    local LowFPSLabel = Library:Create("TextLabel", {
        Parent = Library.Items;
        Name = "\0";
        Text = "";
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
        TextSize = 14;
        TextColor3 = rgb(255, 255, 255);
        TextStrokeTransparency = 0.6;
        TextStrokeColor3 = rgb(0, 0, 0);
        BackgroundTransparency = 1;
        AnchorPoint = vec2(1, 0);
        Position = dim2(1, -8, 0, 6);
        Size = dim2(0, 80, 0, 16);
        BorderSizePixel = 0;
        ZIndex = 50000;
        Visible = false;
        BackgroundColor3 = rgb(255, 255, 255);
    })
     
    local function lowFpsColor(fps)
        local high = 100
        local low = 30
        if fps >= high then
            return rgb(255, 255, 255)
        elseif fps <= low then
            return rgb(214, 79, 79)
        end
        local mid = (low + high) / 2
        if fps >= mid then
            local t = (fps - mid) / (high - mid)
            return rgb(255, math.floor(200 + (255 - 200) * t), math.floor(0 + 255 * t))
        else
            local t = (fps - low) / (mid - low)
            return rgb(
                math.floor(214 + (255 - 214) * t),
                math.floor(79 + (200 - 79) * t),
                math.floor(79 + (0 - 79) * t)
            )
        end
    end
    SettingsSection:Toggle({
        Name = "Low FPS warning",
        Flag = "LowFPSWarning",
        Callback = function(state)
            if not state then
                LowFPSLabel.Visible = false
            end
        end
    })
     
     
    local lastFps = -1
    Library:Connection(RunService.RenderStepped, function(delta)
        if not Flags.LowFPSWarning then
            if LowFPSLabel.Visible then
                LowFPSLabel.Visible = false
            end
            lastFps = -1
            return
        end
        local fps = math.floor(1 / math.max(delta, 0.0001))
        if fps ~= lastFps then
            lastFps = fps
            LowFPSLabel.Text = string.format("FPS: %d", fps)
            LowFPSLabel.TextColor3 = lowFpsColor(fps)
        end
        if not LowFPSLabel.Visible then
            LowFPSLabel.Visible = true
        end
    end)
    SettingsSection:Toggle({
        Name = "Lock menu layout",
        Flag = "LockMenuLayout",
        Callback = function(state)
            Library.DragLock = state
        end
    })
    SettingsSection:Button({
        Name = "Reset menu layout",
        Callback = function()
            pcall(function()
                if isfile(Library:LayoutPath()) then
                    delfile(Library:LayoutPath())
                end
            end)
            if Library.Window then
                Library.Window.Size = dim2(0, 660, 0, 674)
                Library.Window.Position = dim2(0.5, -330, 0.5, -337)
            end
        end
    })
    SettingsSection:Button({
        Name = "Unload",
        Callback = function()
            Library:Unload()
        end
    })
    Tabs.Settings.Sections = {
        Misc = Misc,
        Movement = Movement,
        Settings = SettingsSection,
    }
end

do
    local Page = Tabs.Giver.Items.Page
    for _, child in pairs(Page:GetChildren()) do
        if child:IsA("UIListLayout") then
            child.HorizontalFlex = Enum.UIFlexAlignment.None
        end
    end
    Tabs.Giver.Items.Left.Size = dim2(0.5, -10, 1, 0)
    Tabs.Giver.Items.Right.Size = dim2(0.5, -10, 1, 0)
    for _, column in {Tabs.Giver.Items.Left, Tabs.Giver.Items.Right} do
        for _, child in pairs(column:GetChildren()) do
            if child:IsA("UIListLayout") then
                child.VerticalFlex = Enum.UIFlexAlignment.None
            end
        end
    end
    local ItemsSection = Tabs.Giver:Section({Name = "Weapons", Side = "Left", Size = 1})
    ItemsSection.Items.Outline.Size = dim2(1, 0, 1, 0)
    local SettingsSection = Tabs.Giver:Section({Name = "Item settings", Side = "Right", Size = 1})
    SettingsSection.Items.Outline.Size = dim2(1, 0, 1, 0)
    Tabs.Giver.Sections = {
        Items = ItemsSection,
        Settings = SettingsSection,
    }
    local ListOutline = Library:Create("Frame", {
        Parent = ItemsSection.Items.Elements;
        Name = "\0";
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 1, -4);
        LayoutOrder = 1;
        BackgroundColor3 = themes.preset.outline;
    }); Library:Themify(ListOutline, "outline", "BackgroundColor3")
    local ListInline = Library:Create("Frame", {
        Parent = ListOutline;
        Name = "\0";
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = themes.preset.inline;
    }); Library:Themify(ListInline, "inline", "BackgroundColor3")
    local ListBackground = Library:Create("Frame", {
        Parent = ListInline;
        Name = "\0";
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = rgb(23, 23, 23);
    })
    local ListHolder = Library:Create("ScrollingFrame", {
        Parent = ListBackground;
        Name = "\0";
        Active = true;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = dim2(0, 0, 0, 2);
        Size = dim2(1, 0, 1, -4);
        CanvasSize = dim2(0, 0, 0, 0);
        AutomaticCanvasSize = Enum.AutomaticSize.Y;
        ScrollBarThickness = 4;
        ScrollBarImageColor3 = rgb(65, 65, 65);
        MidImage = "rbxassetid://74268315755026";
        TopImage = "rbxassetid://74268315755026";
        BottomImage = "rbxassetid://74268315755026";
        ZIndex = 2;
    })
    Library:Create("UIListLayout", {
        Parent = ListHolder;
        Padding = dim(0, 1);
        SortOrder = Enum.SortOrder.LayoutOrder;
    })
    local SelectedName = nil
    local Entries = {}
    local FieldDefs = {
        {Key = "damage", Name = "Damage"},
        {Key = "minDamage", Name = "Min damage"},
        {Key = "spread", Name = "Spread"},
        {Key = "range", Name = "Range"},
        {Key = "rateOfFire", Name = "Rate of fire"},
        {Key = "magazineSize", Name = "Magazine size"},
        {Key = "raysPerShot", Name = "Rays per shot"},
        {Key = "rayRadius", Name = "Ray radius"},
    }
    local FieldBoxes = {}
    local SelectedLabel = Library:Create("TextLabel", {
        Parent = SettingsSection.Items.Elements;
        Name = "\0";
        Text = "Item: -";
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
        TextSize = 13;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextColor3 = themes.preset.text_color;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Size = dim2(1, 0, 0, 16);
        LayoutOrder = 1;
        ZIndex = 3;
    })
    local function RefreshEntryVisuals()
        for name, entry in Entries do
            local selected = name == SelectedName
            entry.BackgroundTransparency = selected and 0 or 1
            entry.BackgroundColor3 = themes.preset.accent
            entry.TextColor3 = selected and rgb(255, 255, 255) or themes.preset.text_color
        end
    end
    local function FillFields()
        local attrs = {}
        if SelectedName and ItemGiver and ItemGiver.Describe then
            pcall(function()
                attrs = ItemGiver.Describe(SelectedName) or {}
            end)
        end
        for _, def in ipairs(FieldDefs) do
            local box = FieldBoxes[def.Key]
            if box and box.Items and box.Items.Background then
                local value = attrs[def.Key]
                box.Items.Background.Text = value ~= nil and tostring(value) or ""
            end
        end
    end
    local function SelectItem(name)
        SelectedName = name
        Library.Flags.GiverSelected = name
        SelectedLabel.Text = "Item: " .. (name or "-")
        RefreshEntryVisuals()
        FillFields()
    end
    local function AddEntry(name)
        if Entries[name] then
            return
        end
        local isMega = name == "Mega Pickaxe" or name == "Mega Axe"
        local entry = Library:Create("TextButton", {
            Parent = ListHolder;
            Name = "\0";
            Text = isMega and (name .. " (200x)") or name;
            AutoButtonColor = false;
            LayoutOrder = isMega and 0 or 1;
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", isMega and Enum.FontWeight.SemiBold or Enum.FontWeight.Regular, Enum.FontStyle.Normal);
            TextSize = 13;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextColor3 = themes.preset.text_color;
            BackgroundColor3 = themes.preset.accent;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 0, 14);
            Position = dim2(0, 1, 0, 0);
            ZIndex = 3;
        })
        Library:Create("UIPadding", {
            Parent = entry;
            PaddingLeft = dim(0, 4);
        })
        entry.MouseButton1Click:Connect(function()
            SelectItem(SelectedName == name and nil or name)
        end)
        Entries[name] = entry
        RefreshEntryVisuals()
    end
    local order = 2
    for _, def in ipairs(FieldDefs) do
        local box = SettingsSection:Textbox({Name = def.Name, Flag = "GiverField_" .. def.Key, Default = ""})
        box.Items.List.LayoutOrder = order
        order = order + 1
        FieldBoxes[def.Key] = box
    end
    local function CollectFields()
        local fields = {}
        for _, def in ipairs(FieldDefs) do
            local box = FieldBoxes[def.Key]
            local raw = box and box.Items and box.Items.Background and box.Items.Background.Text or ""
            local value = tonumber(raw)
            if value then
                fields[def.Key] = value
            end
        end
        return fields
    end
    local function Notify(text)
        pcall(function()
            Notifications:Create({Name = text})
        end)
    end
    local GiveButton = SettingsSection:Button({
        Name = "Give",
        Callback = function()
            if not SelectedName then
                Notify("Select an item first")
                return
            end
            if ItemGiver and ItemGiver.Give then
                local ok, msg = ItemGiver.Give(SelectedName)
                Notify(tostring(msg))
            else
                Notify("ItemGiver module is not loaded")
            end
        end
    })
    GiveButton.Items.Button.LayoutOrder = order
    order = order + 1
    local ApplyButton = SettingsSection:Button({
        Name = "Apply",
        Callback = function()
            if not SelectedName then
                Notify("Select an item first")
                return
            end
            if ItemGiver and ItemGiver.Apply then
                local count = ItemGiver.Apply(SelectedName, CollectFields())
                Notify("Applied to " .. tostring(count) .. " attribute(s)")
            else
                Notify("ItemGiver module is not loaded")
            end
        end
    })
    ApplyButton.Items.Button.LayoutOrder = order
    order = order + 1
    local ResetButton = SettingsSection:Button({
        Name = "Reset",
        Callback = function()
            if not SelectedName then
                Notify("Select an item first")
                return
            end
            if ItemGiver and ItemGiver.Reset then
                local count = ItemGiver.Reset(SelectedName)
                FillFields()
                Notify("Restored " .. tostring(count) .. " attribute(s)")
            else
                Notify("ItemGiver module is not loaded")
            end
        end
    })
    ResetButton.Items.Button.LayoutOrder = order
    Library.GiverBridge = {
        SetItems = function(names)
            for _, name in ipairs(names) do
                AddEntry(name)
            end
        end,
    }
    Library.GiverBridge.SetItems({
        "Mega Pickaxe", "Mega Axe",
        "ak47HLD", "lr300HLD", "hk416", "rifle", "G4",
        "SMGHLD", "MP5HLD", "vector9", "mp-40", "thompsonHLD",
        "bolt", "dvl", "mk14", "sks", "crossbow",
        "glock", "pistol", "python", "revolver",
        "m249HLD", "m60HLD", "Minigun",
        "Grenade", "F1", "Hammer", "Building Plan", "Chainsaw", "Drill", "Axe", "Pickaxe",
    })
end
do
    local Page = Tabs.Skins.Items.Page
    for _, child in pairs(Page:GetChildren()) do
        if child:IsA("UIListLayout") then
            child.HorizontalFlex = Enum.UIFlexAlignment.None
        end
    end
    Tabs.Skins.Items.Left.Size = dim2(0.5, -10, 1, 0)
    Tabs.Skins.Items.Right.Size = dim2(0.5, -10, 1, 0)
    for _, column in {Tabs.Skins.Items.Left, Tabs.Skins.Items.Right} do
        for _, child in pairs(column:GetChildren()) do
            if child:IsA("UIListLayout") then
                child.VerticalFlex = Enum.UIFlexAlignment.None
            end
        end
    end
    local PlayersSection = Tabs.Skins:Section({Name = "Players", Side = "Left", Size = 1})
    PlayersSection.Items.Outline.Size = dim2(1, 0, 1, 0)
    local Adjustments = Tabs.Skins:Section({Name = "Adjustments", Side = "Right", Size = 1})
    Adjustments.Items.Outline.Size = dim2(1, 0, 1, 0)
    Tabs.Skins.Sections = {
        Players = PlayersSection,
        Adjustments = Adjustments,
    }
    local ListOutline = Library:Create("Frame", {
        Parent = PlayersSection.Items.Elements;
        Name = "\0";
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 415);
        LayoutOrder = 1;
        BackgroundColor3 = themes.preset.outline;
    }); Library:Themify(ListOutline, "outline", "BackgroundColor3")
    local ListInline = Library:Create("Frame", {
        Parent = ListOutline;
        Name = "\0";
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = themes.preset.inline;
    }); Library:Themify(ListInline, "inline", "BackgroundColor3")
    local ListBackground = Library:Create("Frame", {
        Parent = ListInline;
        Name = "\0";
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = rgb(23, 23, 23);
    })
    local ListHolder = Library:Create("ScrollingFrame", {
        Parent = ListBackground;
        Name = "\0";
        Active = true;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = dim2(0, 0, 0, 2);
        Size = dim2(1, 0, 1, -4);
        CanvasSize = dim2(0, 0, 0, 0);
        AutomaticCanvasSize = Enum.AutomaticSize.Y;
        ScrollBarThickness = 4;
        ScrollBarImageColor3 = rgb(65, 65, 65);
        MidImage = "rbxassetid://74268315755026";
        TopImage = "rbxassetid://74268315755026";
        BottomImage = "rbxassetid://74268315755026";
        ZIndex = 2;
    })
    Library:Create("UIListLayout", {
        Parent = ListHolder;
        Padding = dim(0, 1);
        SortOrder = Enum.SortOrder.LayoutOrder;
    })
    local SelectedPlayer = nil
    local RefreshInfo  
    local Entries = {}
    local function RefreshEntryVisuals()
        for name, entry in Entries do
            local selected = name == SelectedPlayer
            entry.BackgroundTransparency = selected and 0 or 1
            entry.BackgroundColor3 = themes.preset.accent
            entry.TextColor3 = selected and rgb(255, 255, 255) or themes.preset.text_color
        end
    end
    local function AddPlayer(player)
        if Entries[player.Name] then
            return
        end
        local entry = Library:Create("TextButton", {
            Parent = ListHolder;
            Name = "\0";
            Text = player == lp and (player.Name .. " (you)") or player.Name;
            AutoButtonColor = false;
            LayoutOrder = player == lp and 0 or 1;
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", player == lp and Enum.FontWeight.SemiBold or Enum.FontWeight.Regular, Enum.FontStyle.Normal);
            TextSize = 13;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextColor3 = themes.preset.text_color;
            BackgroundColor3 = themes.preset.accent;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 0, 14);
            Position = dim2(0, 1, 0, 0);
            ZIndex = 3;
        })
        Library:Create("UIPadding", {
            Parent = entry;
            PaddingLeft = dim(0, 4);
        })
        entry.MouseButton1Click:Connect(function()
            SelectedPlayer = SelectedPlayer == player.Name and nil or player.Name
            RefreshEntryVisuals()
            RefreshInfo()
        end)
        Entries[player.Name] = entry
        RefreshEntryVisuals()
    end
    local function RemovePlayer(player)
        local entry = Entries[player.Name]
        if not entry then
            return
        end
        entry:Destroy()
        Entries[player.Name] = nil
        if SelectedPlayer == player.Name then
            SelectedPlayer = nil
            RefreshInfo()
        end
    end
    for _, player in pairs(Players:GetPlayers()) do
        AddPlayer(player)
    end
    Library:Connection(Players.PlayerAdded, AddPlayer)
    Library:Connection(Players.PlayerRemoving, RemovePlayer)
    local ResetAll = PlayersSection:Button({
        Name = "Reset all",
        Callback = function()
            SelectedPlayer = nil
            RefreshEntryVisuals()
            RefreshInfo()
        end
    })
    ResetAll.Items.Button.LayoutOrder = 2
    local InfoOutline = Library:Create("Frame", {
        Parent = Adjustments.Items.Elements;
        Name = "\0";
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 415);
        LayoutOrder = 1;
        BackgroundColor3 = themes.preset.outline;
    }); Library:Themify(InfoOutline, "outline", "BackgroundColor3")
    local InfoInline = Library:Create("Frame", {
        Parent = InfoOutline;
        Name = "\0";
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = themes.preset.inline;
    }); Library:Themify(InfoInline, "inline", "BackgroundColor3")
    local InfoBackground = Library:Create("Frame", {
        Parent = InfoInline;
        Name = "\0";
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = rgb(23, 23, 23);
    })
    local InfoHolder = Library:Create("ScrollingFrame", {
        Parent = InfoBackground;
        Name = "\0";
        Active = true;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = dim2(0, 0, 0, 2);
        Size = dim2(1, 0, 1, -4);
        CanvasSize = dim2(0, 0, 0, 0);
        AutomaticCanvasSize = Enum.AutomaticSize.Y;
        ScrollBarThickness = 4;
        ScrollBarImageColor3 = rgb(65, 65, 65);
        MidImage = "rbxassetid://74268315755026";
        TopImage = "rbxassetid://74268315755026";
        BottomImage = "rbxassetid://74268315755026";
        ZIndex = 2;
    })
    Library:Create("UIListLayout", {
        Parent = InfoHolder;
        Padding = dim(0, 1);
        SortOrder = Enum.SortOrder.LayoutOrder;
    })
    local InfoRows = {}
    local function MakeInfoRow(text, order, color)
        local row = Library:Create("Frame", {
            Parent = InfoHolder;
            Name = "\0";
            BackgroundTransparency = 1;
            BackgroundColor3 = rgb(28, 28, 28);
            BorderSizePixel = 0;
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 22);
            Position = dim2(0, 0, 0, 0);
            LayoutOrder = order;
        })
        local title = Library:Create("TextLabel", {
            Parent = row;
            Name = "\0";
            Text = text;
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
            TextSize = 14;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextYAlignment = Enum.TextYAlignment.Center;
            TextColor3 = color or rgb(205, 205, 205);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            BorderColor3 = rgb(0, 0, 0);
            Position = dim2(0, 10, 0, 0);
            Size = dim2(0.55, -10, 1, 0);
            ZIndex = 3;
        })
        local value = Library:Create("TextLabel", {
            Parent = row;
            Name = "\0";
            Text = "-";
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
            TextSize = 14;
            TextXAlignment = Enum.TextXAlignment.Right;
            TextYAlignment = Enum.TextYAlignment.Center;
            TextTruncate = Enum.TextTruncate.AtEnd;
            TextColor3 = themes.preset.text_color;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            BorderColor3 = rgb(0, 0, 0);
            AnchorPoint = vec2(1, 0);
            Position = dim2(1, -10, 0, 0);
            Size = dim2(0.45, 0, 1, 0);
            ZIndex = 3;
        })
        Library:Create("UIStroke", {
            Parent = value;
            Transparency = 0.6;
            LineJoinMode = Enum.LineJoinMode.Miter;
        })
        local self = {Row = row, Title = title, Value = value}
        function self.Set(text, textColor)
            value.Text = text
            value.TextColor3 = textColor or themes.preset.text_color
        end
        table.insert(InfoRows, self)
        return self
    end
    local function MakeInfoHeader(text, order)
        local holder = Library:Create("Frame", {
            Parent = InfoHolder;
            Name = "\0";
            BackgroundTransparency = 1;
            BackgroundColor3 = rgb(255, 255, 255);
            BorderSizePixel = 0;
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 26);
            Position = dim2(0, 0, 0, 0);
            LayoutOrder = order;
        })
        local label = Library:Create("TextLabel", {
            Parent = holder;
            Name = "\0";
            Text = string.upper(text);
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
            TextSize = 13;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextYAlignment = Enum.TextYAlignment.Bottom;
            TextColor3 = themes.preset.accent;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            BorderColor3 = rgb(0, 0, 0);
            Position = dim2(0, 10, 0, 0);
            Size = dim2(1, -20, 1, -5);
            ZIndex = 3;
        }); Library:Themify(label, "accent", "TextColor3")
        return label
    end
    MakeInfoHeader("Resources", 1)
    local WoodRow  = MakeInfoRow("Wood",  2, rgb(160, 122, 72))
    local ScrapRow = MakeInfoRow("Scrap", 3, rgb(150, 190, 120))
    local MetalRow = MakeInfoRow("Metal", 4, rgb(120, 156, 190))
    MakeInfoHeader("State", 8)
    local HealthRow = MakeInfoRow("Health", 9)
    local WeaponRow = MakeInfoRow("Weapon", 11)
    local TeamRow = MakeInfoRow("Team", 12)
    MakeInfoHeader("Position", 13)
    local CoordsRow = MakeInfoRow("Coordinates", 14)
    local DistanceRow = MakeInfoRow("Distance", 15)
    local VelocityRow = MakeInfoRow("Velocity", 16)
    local StateRow = MakeInfoRow("Movement", 17)
    local function ClearInfo()
        for _, row in InfoRows do
            row.Set("-")
        end
    end
    function RefreshInfo()
        ClearInfo()
    end
    ClearInfo()
     
     
     
    local InfoRowMap = {
        Wood = WoodRow,
        Scrap = ScrapRow,
        Metal = MetalRow,
        Health = HealthRow,
        Weapon = WeaponRow,
        Team = TeamRow,
        Coordinates = CoordsRow,
        Distance = DistanceRow,
        Velocity = VelocityRow,
        Movement = StateRow,
    }
    Tabs.Skins.PlayerList = {
        Holder = ListHolder;
        Entries = Entries;
        GetSelected = function()
            return SelectedPlayer
        end;
        RefreshInfo = function()
            RefreshInfo()
        end;
        SetInfo = function(data)
            if type(data) ~= "table" then
                ClearInfo()
                return
            end
            for key, row in pairs(InfoRowMap) do
                local value = data[key]
                if value == nil then
                    row.Set("-")
                elseif type(value) == "table" then
                    row.Set(tostring(value.Text), value.Color)
                else
                    row.Set(tostring(value))
                end
            end
        end;
    }
end
do
    local Page = Tabs.Saving.Items.Page
    for _, child in pairs(Page:GetChildren()) do
        if child:IsA("UIListLayout") then
            child.HorizontalFlex = Enum.UIFlexAlignment.None
        end
    end
    Tabs.Saving.Items.Left.Size = dim2(0.5, -10, 1, 0)
    Tabs.Saving.Items.Right.Size = dim2(0.5, -10, 1, 0)
    for _, column in {Tabs.Saving.Items.Left, Tabs.Saving.Items.Right} do
        for _, child in pairs(column:GetChildren()) do
            if child:IsA("UIListLayout") then
                child.VerticalFlex = Enum.UIFlexAlignment.None
            end
        end
    end
    local Presets = Tabs.Saving:Section({Name = "Presets", Side = "Left", Size = 1})
    Presets.Items.Outline.Size = dim2(1, 0, 1, 0)
    local LuaSection = Tabs.Saving:Section({Name = "Lua", Side = "Right", Size = 1})
    LuaSection.Items.Outline.Size = dim2(1, 0, 1, 0)
    Tabs.Saving.Sections = {
        Presets = Presets,
        Lua = LuaSection,
    }
    local ConfigOutline = Library:Create("Frame", {
        Parent = Presets.Items.Elements;
        Name = "\0";
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 220);
        LayoutOrder = 1;
        BackgroundColor3 = themes.preset.outline;
    }); Library:Themify(ConfigOutline, "outline", "BackgroundColor3")
    local ConfigInline = Library:Create("Frame", {
        Parent = ConfigOutline;
        Name = "\0";
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = themes.preset.inline;
    }); Library:Themify(ConfigInline, "inline", "BackgroundColor3")
    local ConfigBackground = Library:Create("Frame", {
        Parent = ConfigInline;
        Name = "\0";
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = rgb(23, 23, 23);
    })
    local ConfigList = Library:Create("ScrollingFrame", {
        Parent = ConfigBackground;
        Name = "\0";
        Active = true;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = dim2(0, 0, 0, 2);
        Size = dim2(1, 0, 1, -4);
        CanvasSize = dim2(0, 0, 0, 0);
        AutomaticCanvasSize = Enum.AutomaticSize.Y;
        ScrollBarThickness = 4;
        ScrollBarImageColor3 = rgb(65, 65, 65);
        MidImage = "rbxassetid://74268315755026";
        TopImage = "rbxassetid://74268315755026";
        BottomImage = "rbxassetid://74268315755026";
        ZIndex = 2;
    })
    Library:Create("UIListLayout", {
        Parent = ConfigList;
        Padding = dim(0, 1);
        SortOrder = Enum.SortOrder.LayoutOrder;
    })
    local SelectedConfig = nil
    local ConfigEntries = {}
    local NameBox
    local ConfigActions  
    local DefaultFlags = {}
    for flag, value in Flags do
        if type(value) == "table" then
            local copy = {}
            for key, sub in value do
                copy[key] = sub
            end
            DefaultFlags[flag] = copy
        else
            DefaultFlags[flag] = value
        end
    end
    local function CleanName(name)
        if type(name) ~= "string" then
            return nil
        end
        name = name:gsub("^%s+", ""):gsub("%s+$", ""):gsub("[\\/:%*%?\"<>|]", "")
        return name ~= "" and name or nil
    end
    local function ConfigPath(name)
        return Library.Directory .. "/configs/" .. name .. ".cfg"
    end
    local function RefreshConfigVisuals()
        for name, entry in ConfigEntries do
            local selected = name == SelectedConfig
            entry.BackgroundTransparency = selected and 0 or 1
            entry.BackgroundColor3 = rgb(12, 12, 12)
            entry.TextColor3 = selected and rgb(255, 255, 255) or themes.preset.text_color
        end
    end
    local function RefreshConfigList()
        for _, entry in ConfigEntries do
            entry:Destroy()
        end
        table.clear(ConfigEntries)
        local files = {}
        pcall(function()
            files = listfiles(Library.Directory .. "/configs")
        end)
        for _, file in files do
            local name = file:gsub("%.cfg$", "")
            name = name:match("[^/\\]+$") or name
            local entry = Library:Create("TextButton", {
                Parent = ConfigList;
                Name = "\0";
                Text = name;
                AutoButtonColor = false;
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                TextSize = 13;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextColor3 = themes.preset.text_color;
                BackgroundColor3 = themes.preset.accent;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(1, -2, 0, 14);
                Position = dim2(0, 1, 0, 0);
                ZIndex = 3;
            })
            Library:Create("UIPadding", {
                Parent = entry;
                PaddingLeft = dim(0, 4);
            })
            local lastClick = 0
            entry.MouseButton1Click:Connect(function()
                local now = os.clock()
                local double = (now - lastClick) < 0.35
                lastClick = now
                SelectedConfig = name
                if NameBox then
                    NameBox.Set(name)
                end
                RefreshConfigVisuals()
                if double and ConfigActions and ConfigActions.Load then
                    ConfigActions.Load()
                end
            end)
            ConfigEntries[name] = entry
        end
        if SelectedConfig and not ConfigEntries[SelectedConfig] then
            SelectedConfig = nil
        end
        RefreshConfigVisuals()
    end
    local function WidenTextbox(box)
        box.Items.Textbox.Size = dim2(1, 0, 0, 20)
        box.Items.Textbox.Position = dim2(0, 0, 0, -1)
        return box
    end
    NameBox = Presets:Textbox({
        Flag = "ConfigPresetName",
        PlaceHolder = "config name...",
        Callback = function(text)
            SelectedConfig = text ~= "" and text or nil
        end
    })
    NameBox.Items.List.LayoutOrder = 2
    WidenTextbox(NameBox)
    local function CurrentName()
        return CleanName(Flags.ConfigPresetName) or CleanName(SelectedConfig)
    end
    local Buttons = {
        {"Load", function()
            local name = CurrentName()
            if not name then
                Notifications:Create({Name = "Enter or select a config name"})
                return
            end
            if not isfile(ConfigPath(name)) then
                Notifications:Create({Name = "Config \"" .. name .. "\" doesn't exist"})
                return
            end
            local ok, err = pcall(function()
                Library:LoadConfig(readfile(ConfigPath(name)))
            end)
            if not ok then
                Notifications:Create({Name = "Failed to load: " .. tostring(err)})
                return
            end
            SelectedConfig = name
            RefreshConfigVisuals()
            Notifications:Create({Name = "Loaded config (" .. name .. ")"})
        end},
        {"Save", function()
            local name = CurrentName()
            if not name then
                Notifications:Create({Name = "Enter a config name"})
                return
            end
            local existed = isfile(ConfigPath(name))
            local ok, err = pcall(function()
                writefile(ConfigPath(name), Library:GetConfig())
            end)
            if not ok then
                Notifications:Create({Name = "Failed to save: " .. tostring(err)})
                return
            end
            SelectedConfig = name
            RefreshConfigList()
            Notifications:Create({Name = (existed and "Overwrote config (" or "Saved config (") .. name .. ")"})
        end},
        {"Delete", function()
            local name = CurrentName()
            if not name then
                Notifications:Create({Name = "Enter or select a config name"})
                return
            end
            if not isfile(ConfigPath(name)) then
                Notifications:Create({Name = "Config \"" .. name .. "\" doesn't exist"})
                return
            end
            local ok, err = pcall(function()
                delfile(ConfigPath(name))
            end)
            if not ok then
                Notifications:Create({Name = "Failed to delete: " .. tostring(err)})
                return
            end
            SelectedConfig = nil
            if NameBox then
                NameBox.Set("")
            end
            RefreshConfigList()
            Notifications:Create({Name = "Deleted config (" .. name .. ")"})
        end},
        {"Reset", function()
            local restored = 0
            for flag, default in DefaultFlags do
                local setter = ConfigFlags[flag]
                if setter then
                    local ok = pcall(setter, default)
                    if ok then
                        restored += 1
                    end
                end
            end
            SelectedConfig = nil
            if NameBox then
                NameBox.Set("")
            end
            RefreshConfigVisuals()
            Notifications:Create({Name = "Reset " .. restored .. " settings to default"})
        end},
        {"Import from clipboard", function()
            local ok, data = pcall(function()
                return getclipboard and getclipboard() or ""
            end)
            if not ok or type(data) ~= "string" or data == "" then
                Notifications:Create({Name = "Clipboard is empty"})
                return
            end
            local loaded, err = pcall(function()
                Library:LoadConfig(data)
            end)
            if not loaded then
                Notifications:Create({Name = "Invalid config data"})
                return
            end
            local name = CurrentName()
            if name then
                pcall(function()
                    writefile(ConfigPath(name), data)
                end)
                SelectedConfig = name
                RefreshConfigList()
            end
            Notifications:Create({Name = name and ("Imported into (" .. name .. ")") or "Imported from clipboard"})
        end},
        {"Export to clipboard", function()
            local name = CurrentName()
            local data
            if name and isfile(ConfigPath(name)) then
                local ok, contents = pcall(readfile, ConfigPath(name))
                data = ok and contents or nil
            end
            data = data or Library:GetConfig()
            local ok = pcall(function()
                setclipboard(data)
            end)
            Notifications:Create({Name = ok and "Exported to clipboard" or "Clipboard unavailable"})
        end},
    }
    ConfigActions = {}
    for index, data in Buttons do
        local button = Presets:Button({Name = data[1], Callback = data[2]})
        button.Items.Button.LayoutOrder = 2 + index
        ConfigActions[data[1]] = data[2]
    end
    NameBox.Items.Background.FocusLost:Connect(function(enter)
        if not enter then
            return
        end
        local name = CurrentName()
        if not name then
            return
        end
        if isfile(ConfigPath(name)) then
            ConfigActions.Load()
        else
            ConfigActions.Save()
        end
    end)
    RefreshConfigList()
    Tabs.Saving.Configs = {
        Refresh = RefreshConfigList;
        GetSelected = function()
            return SelectedConfig
        end;
    }
    local LUA_DIR    = Library.Directory .. "/lua"
    local EDITOR_FILE = Library.Directory .. "/lua_editor.lua"
    local EDITOR_URL  = "https://raw.githubusercontent.com/i77lhm/storage/refs/heads/main/lua_editor.lua"
    pcall(function()
        if not isfolder(LUA_DIR) then
            makefolder(LUA_DIR)
        end
    end)
    local function LuaPath(name)
        return LUA_DIR .. "/" .. name .. ".lua"
    end
    local SelectedScript = nil
    local ScriptEntries = {}
    local RefreshScriptList
    local OpenScriptInEditor
    local ReloadActiveScript  
    local LuaEnabled = LuaSection:Toggle({Name = "Enabled", Flag = "LuaEnabled", Default = true})
    local LuaUnsafe = LuaSection:Toggle({Name = "Allow unsafe scripts", Flag = "LuaAllowUnsafe"})
    LuaEnabled.Items.Toggle.LayoutOrder = 1
    LuaUnsafe.Items.Toggle.LayoutOrder = 2
    local ReloadButton = LuaSection:Button({
        Name = "Reload active scripts",
        Callback = function()
            if ReloadActiveScript then
                ReloadActiveScript()
            end
        end
    })
    ReloadButton.Items.Button.LayoutOrder = 3
    local ScriptBox = LuaSection:Textbox({
        Flag = "LuaScriptName",
        PlaceHolder = "script name...",
    })
    WidenTextbox(ScriptBox)
    ScriptBox.Items.List.LayoutOrder = 4
    local ScriptOutline = Library:Create("Frame", {
        Parent = LuaSection.Items.Elements;
        Name = "\0";
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 300);
        LayoutOrder = 5;
        BackgroundColor3 = themes.preset.outline;
    }); Library:Themify(ScriptOutline, "outline", "BackgroundColor3")
    local ScriptInline = Library:Create("Frame", {
        Parent = ScriptOutline;
        Name = "\0";
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = themes.preset.inline;
    }); Library:Themify(ScriptInline, "inline", "BackgroundColor3")
    local ScriptBackground = Library:Create("Frame", {
        Parent = ScriptInline;
        Name = "\0";
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = rgb(23, 23, 23);
    })
    local ScriptList = Library:Create("ScrollingFrame", {
        Parent = ScriptBackground;
        Name = "\0";
        Active = true;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = dim2(0, 0, 0, 2);
        Size = dim2(1, 0, 1, -4);
        CanvasSize = dim2(0, 0, 0, 0);
        AutomaticCanvasSize = Enum.AutomaticSize.Y;
        ScrollBarThickness = 4;
        ScrollBarImageColor3 = rgb(65, 65, 65);
        MidImage = "rbxassetid://74268315755026";
        TopImage = "rbxassetid://74268315755026";
        BottomImage = "rbxassetid://74268315755026";
        ZIndex = 2;
    })
    Library:Create("UIListLayout", {
        Parent = ScriptList;
        Padding = dim(0, 1);
        SortOrder = Enum.SortOrder.LayoutOrder;
    })
    local function RefreshScriptVisuals()
        for name, entry in ScriptEntries do
            local selected = name == SelectedScript
            entry.BackgroundTransparency = selected and 0 or 1
            entry.BackgroundColor3 = rgb(12, 12, 12)
            entry.TextColor3 = selected and rgb(255, 255, 255) or themes.preset.text_color
        end
    end
    function RefreshScriptList()
        for _, entry in ScriptEntries do
            entry:Destroy()
        end
        table.clear(ScriptEntries)
        local files = {}
        pcall(function()
            files = listfiles(LUA_DIR)
        end)
        for index, file in files do
            if file:sub(-4) == ".lua" then
                local name = file:gsub("%.lua$", "")
                name = name:match("[^/\\]+$") or name
                local entry = Library:Create("TextButton", {
                    Parent = ScriptList;
                    Name = "\0";
                    Text = name;
                    AutoButtonColor = false;
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                    TextSize = 13;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextColor3 = themes.preset.text_color;
                    BackgroundColor3 = rgb(12, 12, 12);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 0, 14);
                    Position = dim2(0, 1, 0, 0);
                    LayoutOrder = index;
                    ZIndex = 3;
                })
                Library:Create("UIPadding", {
                    Parent = entry;
                    PaddingLeft = dim(0, 4);
                })
                local lastClick = 0
                entry.MouseButton1Click:Connect(function()
                    local now = os.clock()
                    local double = (now - lastClick) < 0.35
                    lastClick = now
                    SelectedScript = name
                    ScriptBox.Set(name)
                    RefreshScriptVisuals()
                    if double and OpenScriptInEditor then
                        OpenScriptInEditor(name)
                    end
                end)
                ScriptEntries[name] = entry
            end
        end
        RefreshScriptVisuals()
    end
    RefreshScriptList()
    local StartupToggle = LuaSection:Toggle({Name = "Load on startup", Flag = "LuaLoadOnStartup"})
    StartupToggle.Items.Toggle.LayoutOrder = 7
    local Editor = {Open = false, Running = false, Script = nil, Unsaved = false}
    local MAX_EDITOR_CHARS = 190000
    local EditorScreen = Library:Create("ScreenGui", {
        Name = "\0";
        Enabled = true;
        IgnoreGuiInset = true;
        ZIndexBehavior = Enum.ZIndexBehavior.Global;
        DisplayOrder = 999;
    })
    pcall(function()
        EditorScreen.Parent = gethui and gethui() or CoreGui
    end)
    if not EditorScreen.Parent then
        EditorScreen.Parent = CoreGui
    end
    local EDIT_W, EDIT_H = 700, 480
    local EditorOutline = Library:Create("Frame", {
        Parent = EditorScreen;
        Name = "\0";
        Visible = false;
        Size = dim2(0, EDIT_W, 0, EDIT_H);
        Position = dim2(0.5, -EDIT_W / 2, 0.5, -EDIT_H / 2);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = themes.preset.outline;
    }); Library:Themify(EditorOutline, "outline", "BackgroundColor3")
    table.insert(Library.NoDrag, EditorOutline)
    local EditorInline = Library:Create("Frame", {
        Parent = EditorOutline;
        Name = "\0";
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = themes.preset.inline;
    }); Library:Themify(EditorInline, "inline", "BackgroundColor3")
    local EditorBlocker = Library:Create("TextButton", {
        Parent = EditorInline;
        Name = "\0";
        Text = "";
        AutoButtonColor = false;
        Active = true;
        Selectable = false;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Size = dim2(1, 0, 1, 0);
        ZIndex = 0;
    })
    local EditorBody = Library:Create("Frame", {
        Parent = EditorInline;
        Name = "\0";
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        ClipsDescendants = true;
        BackgroundColor3 = rgb(23, 23, 23);
    })
    local EditorBar = Library:Create("Frame", {
        Parent = EditorBody;
        Name = "\0";
        Size = dim2(1, 0, 0, 24);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = rgb(16, 16, 16);
    })
    Library:Create("Frame", {
        Parent = EditorBar;
        Name = "\0";
        Size = dim2(1, 0, 0, 1);
        Position = dim2(0, 0, 1, -1);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.accent;
    })
    local EditorTitle = Library:Create("TextLabel", {
        Parent = EditorBar;
        Name = "\0";
        Text = "lua editor";
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
        TextSize = 13;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextColor3 = themes.preset.text_color;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = dim2(0, 9, 0, 0);
        Size = dim2(1, -60, 1, 0);
        ZIndex = 2;
    })
    local function RefreshTitle()
        local base = Editor.Script and ("lua editor  -  " .. Editor.Script .. ".lua") or "lua editor"
        EditorTitle.Text = Editor.Unsaved and (base .. "*") or base
    end
    local EditorClose = Library:Create("TextButton", {
        Parent = EditorBar;
        Name = "\0";
        Text = "X";
        AutoButtonColor = false;
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
        TextSize = 13;
        TextColor3 = rgb(150, 150, 150);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Size = dim2(0, 24, 1, 0);
        Position = dim2(1, -24, 0, 0);
        ZIndex = 2;
    })
    EditorClose.MouseEnter:Connect(function()
        EditorClose.TextColor3 = rgb(220, 90, 90)
    end)
    EditorClose.MouseLeave:Connect(function()
        EditorClose.TextColor3 = rgb(150, 150, 150)
    end)
    do
        local dragging, startPos, startMouse = false, nil, nil
        EditorBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                startPos = EditorOutline.Position
                startMouse = input.Position
            end
        end)
        Library:Connection(InputService.InputChanged, function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - startMouse
                EditorOutline.Position = dim2(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
        Library:Connection(InputService.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end
    local CodeOutline = Library:Create("Frame", {
        Parent = EditorBody;
        Name = "\0";
        Position = dim2(0, 8, 0, 32);
        Size = dim2(1, -16, 1, -70);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = rgb(12, 12, 12);
    })
    local CodeArea = Library:Create("Frame", {
        Parent = CodeOutline;
        Name = "\0";
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        ClipsDescendants = true;
        BackgroundColor3 = rgb(18, 18, 18);
    })
    local GUTTER, CODE_SIZE = 34, 13
    local LINE_MULT = 1.35
    local LINE_H = 18
    local ORIGIN_X, ORIGIN_Y = 6, 4
    local TEXT_NUDGE_Y = 0
    local Gutter = Library:Create("Frame", {
        Parent = CodeArea;
        Name = "\0";
        Size = dim2(0, GUTTER, 1, 0);
        BorderSizePixel = 0;
        BorderColor3 = rgb(0, 0, 0);
        ClipsDescendants = true;
        BackgroundColor3 = rgb(22, 22, 22);
        ZIndex = 4;
    })
    Library:Create("Frame", {
        Parent = Gutter;
        Name = "\0";
        Size = dim2(0, 1, 1, 0);
        Position = dim2(1, -1, 0, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(38, 38, 38);
        ZIndex = 4;
    })
    local LineNumbers = Library:Create("TextLabel", {
        Parent = Gutter;
        Name = "\0";
        Text = "1";
        FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
        TextSize = CODE_SIZE;
        LineHeight = LINE_MULT;
        TextColor3 = rgb(90, 90, 90);
        TextXAlignment = Enum.TextXAlignment.Right;
        TextYAlignment = Enum.TextYAlignment.Top;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = dim2(0, -6, 0, ORIGIN_Y + TEXT_NUDGE_Y);
        Size = dim2(1, 0, 0, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        ZIndex = 5;
    })
    local CodeScroll = Library:Create("ScrollingFrame", {
        Parent = CodeArea;
        Name = "\0";
        Active = true;
        Position = dim2(0, GUTTER, 0, 0);
        Size = dim2(1, -GUTTER, 1, 0);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        CanvasSize = dim2(0, 1600, 0, 0);
        ScrollBarThickness = 4;
        ScrollBarImageColor3 = rgb(65, 65, 65);
        MidImage = "rbxassetid://74268315755026";
        TopImage = "rbxassetid://74268315755026";
        BottomImage = "rbxassetid://74268315755026";
        ZIndex = 2;
    })
    local CodeHighlight = Library:Create("TextLabel", {
        Parent = CodeScroll;
        Name = "\0";
        Text = "";
        RichText = true;
        FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
        TextSize = CODE_SIZE;
        LineHeight = LINE_MULT;
        TextColor3 = rgb(220, 220, 220);
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Top;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = dim2(0, ORIGIN_X, 0, ORIGIN_Y + TEXT_NUDGE_Y);
        Size = dim2(0, 1600, 1, 0);
        ZIndex = 2;
    })
    local SelectionLayer = Library:Create("Frame", {
        Parent = CodeScroll;
        Name = "\0";
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = dim2(0, ORIGIN_X, 0, ORIGIN_Y);
        Size = dim2(0, 1600, 1, 0);
        ZIndex = 1;
    })
    local CodeBox = Library:Create("TextBox", {
        Parent = CodeScroll;
        Name = "\0";
        Text = "";
        PlaceholderText = "-- write your lua here";
        PlaceholderColor3 = rgb(90, 90, 90);
        MultiLine = true;
        ClearTextOnFocus = false;
        TextWrapped = false;
        FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
        TextSize = CODE_SIZE;
        LineHeight = LINE_MULT;
        TextColor3 = rgb(220, 220, 220);
        TextTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Top;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = dim2(0, ORIGIN_X, 0, ORIGIN_Y + TEXT_NUDGE_Y);
        Size = dim2(0, 1600, 1, 0);
        ZIndex = 3;
    })
    local EditorStatus = Library:Create("TextLabel", {
        Parent = EditorBody;
        Name = "\0";
        Text = "Ln 1, Col 1";
        FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
        TextSize = 12;
        TextColor3 = rgb(130, 130, 130);
        TextXAlignment = Enum.TextXAlignment.Right;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = dim2(0, -10, 1, -28);
        Size = dim2(1, 0, 0, 24);
        ZIndex = 2;
    })
    local CHAR_W = 0
    local function MeasureChar()
        local ok, size = pcall(function()
            return TextService:GetTextSize(
                string.rep("M", 100),
                CODE_SIZE,
                Enum.Font.RobotoMono,
                vec2(100000, 100000)
            )
        end)
        if ok and size and size.X > 0 then
            CHAR_W = size.X / 100
        else
            CHAR_W = CODE_SIZE * 0.6
        end
    end
    MeasureChar()
    local function ApplyTextOffset()
        CodeHighlight.Position = dim2(0, ORIGIN_X, 0, ORIGIN_Y + TEXT_NUDGE_Y)
        CodeBox.Position = dim2(0, ORIGIN_X, 0, ORIGIN_Y + TEXT_NUDGE_Y)
        LineNumbers.Position = dim2(0, -6, 0, ORIGIN_Y + TEXT_NUDGE_Y)
    end
    Editor.SetTextOffset = function(value)
        TEXT_NUDGE_Y = value or 0
        ApplyTextOffset()
        pcall(function()
            RenderVisible(true)
            RefreshCaret()
            RefreshSelection()
        end)
    end
    task.defer(function()
        local probe = Library:Create("TextLabel", {
            Parent = CodeScroll;
            Name = "\0";
            Text = string.rep("M", 100);
            FontFace = CodeHighlight.FontFace;
            TextSize = CODE_SIZE;
            BackgroundTransparency = 1;
            TextTransparency = 1;
            AutomaticSize = Enum.AutomaticSize.XY;
            Position = dim2(0, 0, 0, -9999);
        })
        for _ = 1, 10 do
            task.wait(0.1)
            if probe.TextBounds.X > 0 then
                CHAR_W = probe.TextBounds.X / 100
                break
            end
        end
        probe:Destroy()
    end)
    local function DisplayLen(str)
        local ok, count = pcall(utf8.len, str)
        if ok and count then
            return count
        end
        return #str
    end
    local Caret = Library:Create("Frame", {
        Parent = SelectionLayer;
        Name = "\0";
        BackgroundColor3 = rgb(230, 230, 230);
        BorderSizePixel = 0;
        Visible = false;
        Size = dim2(0, 1, 0, LINE_H);
        ZIndex = 6;
    })
    local function RefreshCaret()
        local pos = CodeBox.CursorPosition
        if pos < 1 or not CodeBox:IsFocused() then
            Caret.Visible = false
            return
        end
        local before = string.sub(CodeBox.Text, 1, pos - 1)
        local line = 0
        for _ in string.gmatch(before, "\n") do
            line += 1
        end
        local lastBreak = string.match(before, ".*()\n") or 0
        local column = DisplayLen(string.sub(before, lastBreak + 1))
        Caret.Visible = true
        Caret.Position = dim2(0, column * CHAR_W, 0, line * LINE_H)
    end
    task.spawn(function()
        while Caret and Caret.Parent do
            if CodeBox:IsFocused() then
                Caret.BackgroundTransparency = Caret.BackgroundTransparency > 0.5 and 0 or 1
            end
            task.wait(0.5)
        end
    end)
    local SelectionBars = {}
    local function ClearSelection()
        for _, bar in SelectionBars do
            bar.Visible = false
        end
    end
    local function GetBar(index)
        local bar = SelectionBars[index]
        if not bar then
            bar = Library:Create("Frame", {
                Parent = SelectionLayer;
                Name = "\0";
                BorderSizePixel = 0;
                BorderColor3 = rgb(0, 0, 0);
                BackgroundColor3 = rgb(38, 79, 120);
                BackgroundTransparency = 0.15;
                ZIndex = 1;
            })
            SelectionBars[index] = bar
        end
        return bar
    end
    local function RefreshSelection()
        local selStart = CodeBox.SelectionStart
        local cursor = CodeBox.CursorPosition
        if selStart < 1 or cursor < 1 or selStart == cursor or CHAR_W <= 0 then
            ClearSelection()
            return
        end
        local from = math.min(selStart, cursor)
        local to = math.max(selStart, cursor) - 1
        local text = CodeBox.Text
        local barIndex = 0
        local lineIndex = 0
        local pos = 1
        while true do
            local lineEnd = text:find("\n", pos, true)
            local stop = (lineEnd or (#text + 1)) - 1
            local a = math.max(pos, from)
            local b = math.min(stop, to)
            if a <= b then
                barIndex += 1
                local bar = GetBar(barIndex)
                local offset = DisplayLen(string.sub(text, pos, a - 1))
                local width = DisplayLen(string.sub(text, a, b))
                local top = math.floor(lineIndex * LINE_H)
                local bottom = math.floor((lineIndex + 1) * LINE_H)
                local left = math.floor(offset * CHAR_W)
                local right = math.floor((offset + width) * CHAR_W + 0.5)
                bar.Visible = true
                bar.Position = dim2(0, left, 0, top)
                bar.Size = dim2(0, right - left, 0, bottom - top)
            elseif lineEnd and from <= lineEnd and to >= lineEnd then
                barIndex += 1
                local bar = GetBar(barIndex)
                local lineLen = DisplayLen(string.sub(text, pos, stop))
                local top = math.floor(lineIndex * LINE_H)
                local bottom = math.floor((lineIndex + 1) * LINE_H)
                bar.Visible = true
                bar.Position = dim2(0, math.floor(lineLen * CHAR_W), 0, top)
                bar.Size = dim2(0, math.ceil(CHAR_W * 0.5), 0, bottom - top)
            end
            if not lineEnd then
                break
            end
            pos = lineEnd + 1
            lineIndex += 1
        end
        for index = barIndex + 1, #SelectionBars do
            SelectionBars[index].Visible = false
        end
    end
    local Keywords = {
        ["and"]=1,["break"]=1,["do"]=1,["else"]=1,["elseif"]=1,["end"]=1,["false"]=1,
        ["for"]=1,["function"]=1,["if"]=1,["in"]=1,["local"]=1,["nil"]=1,["not"]=1,
        ["or"]=1,["repeat"]=1,["return"]=1,["then"]=1,["true"]=1,["until"]=1,
        ["while"]=1,["continue"]=1,
    }
    local GlobalWords = {
        ["print"]=1,["warn"]=1,["error"]=1,["assert"]=1,["pcall"]=1,["pairs"]=1,
        ["ipairs"]=1,["tonumber"]=1,["tostring"]=1,["type"]=1,["typeof"]=1,
        ["setmetatable"]=1,["string"]=1,["table"]=1,["math"]=1,["task"]=1,
        ["game"]=1,["workspace"]=1,["Instance"]=1,["Vector2"]=1,["Vector3"]=1,
        ["UDim2"]=1,["Color3"]=1,["CFrame"]=1,["Enum"]=1,["self"]=1,["api"]=1,
    }
    local function EscapeXml(str)
        str = str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
        str = str:gsub('"', "&quot;"):gsub("'", "&apos;")
        return str
    end
    local function Span(color, text)
        return '<font color="' .. color .. '">' .. EscapeXml(text) .. "</font>"
    end
    local function Highlight(code)
        local out, i, n = {}, 1, #code
        while i <= n do
            local char = code:sub(i, i)
            if code:sub(i, i + 3) == "--[[" then
                local close = code:find("]]", i + 4, true)
                local stop = close and (close + 1) or n
                table.insert(out, Span("#6A9955", code:sub(i, stop)))
                i = stop + 1
            elseif code:sub(i, i + 1) == "--" then
                local stop = (code:find("\n", i) or (n + 1)) - 1
                table.insert(out, Span("#6A9955", code:sub(i, stop)))
                i = stop + 1
            elseif char == '"' or char == "'" then
                local j = i + 1
                while j <= n do
                    local c = code:sub(j, j)
                    if c == "\\" then
                        j += 2
                    elseif c == char or c == "\n" then
                        break
                    else
                        j += 1
                    end
                end
                table.insert(out, Span("#CE9178", code:sub(i, math.min(j, n))))
                i = j + 1
            elseif char:match("%d") then
                local num = code:match("^%d*%.?%d+", i) or char
                table.insert(out, Span("#B5CEA8", num))
                i += #num
            elseif char:match("[%a_]") then
                local word = code:match("^[%w_]+", i)
                local nextChar = code:match("^%s*(.)", i + #word)
                local color
                if Keywords[word] then
                    color = "#569CD6"
                elseif nextChar == "(" then
                    color = "#DCDCAA"
                elseif GlobalWords[word] then
                    color = "#4EC9B0"
                else
                    color = "#E6E6E6"
                end
                table.insert(out, Span(color, word))
                i += #word
            else
                table.insert(out, EscapeXml(char))
                i += 1
            end
        end
        return table.concat(out)
    end
    local CodeDirty = true
    local CodeLines = {""}
    local RenderedFirst = -1
    local RenderedLast = -1
    local OVERSCAN = 6
    local function SplitLines()
        local text = CodeBox.Text
        local ok, result = pcall(string.split, text, "\n")
        if not ok or type(result) ~= "table" or #result == 0 then
            result = {}
            local pos = 1
            while true do
                local lineEnd = string.find(text, "\n", pos, true)
                if not lineEnd then
                    result[#result + 1] = string.sub(text, pos)
                    break
                end
                result[#result + 1] = string.sub(text, pos, lineEnd - 1)
                pos = lineEnd + 1
            end
        end
        if #result == 0 then
            result = {""}
        end
        CodeLines = result
    end
    local function RefreshGutter()
        local lines = #CodeLines
        local height = math.max(lines * LINE_H + 20, CodeArea.AbsoluteSize.Y)
        CodeScroll.CanvasSize = dim2(0, 1600, 0, height)
        CodeBox.Size = dim2(0, 1600, 0, height)
        SelectionLayer.Size = dim2(0, 1600, 0, height)
    end
    local function RenderVisible(force)
        local viewHeight = CodeArea.AbsoluteSize.Y
        if viewHeight <= 0 then
            viewHeight = 400
        end
        local top = CodeScroll.CanvasPosition.Y
        local firstLine = math.max(1, math.floor(top / LINE_H) - OVERSCAN)
        local visibleCount = math.ceil(viewHeight / LINE_H) + OVERSCAN * 2
        local lastLine = math.min(#CodeLines, firstLine + visibleCount)
        if not force and firstLine == RenderedFirst and lastLine == RenderedLast then
            return
        end
        RenderedFirst = firstLine
        RenderedLast = lastLine
        local chunk = table.create(lastLine - firstLine + 1)
        for index = firstLine, lastLine do
            local ok, result = pcall(Highlight, CodeLines[index] or "")
            chunk[#chunk + 1] = ok and result or EscapeXml(CodeLines[index] or "")
        end
        CodeHighlight.Text = table.concat(chunk, "\n")
        CodeHighlight.Position = dim2(0, ORIGIN_X, 0, ORIGIN_Y + TEXT_NUDGE_Y + (firstLine - 1) * LINE_H)
        CodeHighlight.Size = dim2(0, 1600, 0, (lastLine - firstLine + 2) * LINE_H)
        local numbers = table.create(lastLine - firstLine + 1)
        for index = firstLine, lastLine do
            numbers[#numbers + 1] = tostring(index)
        end
        LineNumbers.Text = table.concat(numbers, "\n")
        LineNumbers.Position = dim2(0, -6, 0, ORIGIN_Y + TEXT_NUDGE_Y + (firstLine - 1) * LINE_H - CodeScroll.CanvasPosition.Y)
    end
    local function MeasureLineStep()
        local single = Library:Create("TextLabel", {
            Parent = CodeScroll;
            Name = "\0";
            Text = "M";
            FontFace = CodeHighlight.FontFace;
            TextSize = CODE_SIZE;
            LineHeight = LINE_MULT;
            BackgroundTransparency = 1;
            TextTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextYAlignment = Enum.TextYAlignment.Top;
            AutomaticSize = Enum.AutomaticSize.XY;
            Position = dim2(0, 0, 0, -99999);
        })
        local probe = Library:Create("TextLabel", {
            Parent = CodeScroll;
            Name = "\0";
            Text = string.rep("M\n", 20) .. "M";
            FontFace = CodeHighlight.FontFace;
            TextSize = CODE_SIZE;
            LineHeight = LINE_MULT;
            BackgroundTransparency = 1;
            TextTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextYAlignment = Enum.TextYAlignment.Top;
            AutomaticSize = Enum.AutomaticSize.XY;
            Position = dim2(0, 0, 0, -99999);
        })
        task.defer(function()
            for _ = 1, 30 do
                local bounds = probe.TextBounds
                if bounds.Y > 0 and single.TextBounds.Y > 0 then
                    local step = (bounds.Y - single.TextBounds.Y) / 20
                    if step > 1 and math.abs(step - LINE_H) > 0.01 then
                        LINE_H = step
                        Caret.Size = dim2(0, 1, 0, LINE_H)
                        RefreshGutter()
                        RenderVisible(true)
                        RefreshCaret()
                        RefreshSelection()
                    end
                    break
                end
                task.wait(0.05)
            end
            probe:Destroy()
            single:Destroy()
        end)
    end
    CodeBox:GetPropertyChangedSignal("Text"):Connect(function()
        CodeDirty = true
        if not Editor.Unsaved then
            Editor.Unsaved = true
            RefreshTitle()
        end
        SplitLines()
        RefreshGutter()
        RefreshSelection()
        RefreshCaret()
    end)
    CodeBox:GetPropertyChangedSignal("SelectionStart"):Connect(function()
        RefreshSelection()
        RefreshCaret()
    end)
    CodeBox:GetPropertyChangedSignal("CursorPosition"):Connect(function()
        local pos = CodeBox.CursorPosition
        if pos < 1 then
            return
        end
        local text = CodeBox.Text
        local before = text:sub(1, pos - 1)
        local line = 1
        for _ in before:gmatch("\n") do
            line += 1
        end
        local lastBreak = before:match(".*()\n") or 0
        local total = 1
        for _ in text:gmatch("\n") do
            total += 1
        end
        EditorStatus.Text = string.format("Ln %d, Col %d   |   %d lines", line, pos - lastBreak, total)
        RefreshSelection()
        RefreshCaret()
    end)
    CodeBox.Focused:Connect(function()
        RefreshSelection()
        RefreshCaret()
    end)
    CodeBox.FocusLost:Connect(function()
        ClearSelection()
        Caret.Visible = false
    end)
    Library:Connection(RunService.Heartbeat, function()
        if CodeDirty then
            CodeDirty = false
            RenderVisible(true)
        end
    end)
    CodeScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        RenderVisible(false)
        LineNumbers.Position = dim2(0, -6, 0, ORIGIN_Y + TEXT_NUDGE_Y + (RenderedFirst - 1) * LINE_H - CodeScroll.CanvasPosition.Y)
    end)
    local RunSession = nil
    local function UnloadScript()
        if RunSession then
            for _, fn in RunSession.unload do
                pcall(fn)
            end
            for _, connection in RunSession.connections do
                pcall(function()
                    connection:Disconnect()
                end)
            end
            for _, object in RunSession.instances do
                pcall(function()
                    object:Destroy()
                end)
            end
            RunSession = nil
        end
        Editor.Running = false
    end
    local function RunScript(source)
        UnloadScript()
        local loader = loadstring or load
        if not loader then
            Notifications:Create({Name = "loadstring unavailable"})
            return false
        end
        local func, err = loader(source, "@gamesense_lua")
        if not func then
            Notifications:Create({Name = "Syntax error: " .. tostring(err)})
            return false
        end
        RunSession = {connections = {}, instances = {}, unload = {}, render = {}, key = {}, binds = {}}
        local session = RunSession
        local api = {}
        api.library = Library
        api.flags = Flags
        api.player = lp
        api.camera = Camera
        api.game = game
        api.version = "3.0"
        local client = {}
        local function Join(...)
            local parts = {}
            for index = 1, select("#", ...) do
                parts[index] = tostring(select(index, ...))
            end
            return table.concat(parts, " ")
        end
        function client.log(...)
            Notifications:Create({Name = Join(...)})
        end
        function client.color_log(r, g, b, ...)
            Notifications:Create({Name = Join(...)})
        end
        function client.error_log(...)
            Notifications:Create({Name = "[error] " .. Join(...)})
        end
        function client.userid_to_entindex(id)
            local player = Players:GetPlayerByUserId(id)
            return player
        end
        function client.screen_size()
            local size = Camera.ViewportSize
            return size.X, size.Y
        end
        function client.timestamp()
            return os.clock() * 1000
        end
        function client.system_time()
            local date = os.date("*t")
            return date.hour, date.min, date.sec, 0
        end
        function client.unix_time()
            return os.time()
        end
        function client.delay_call(delay, fn, ...)
            local args = table.pack(...)
            task.delay(delay, function()
                pcall(fn, table.unpack(args, 1, args.n))
            end)
        end
        function client.exec(cmd)
            client.log("exec: " .. tostring(cmd))
        end
        client.set_event_callback = function(event, fn)
            api.on(event, fn)
        end
        api.client = client
        function client.latency()
            local ok, ping = pcall(function()
                return lp:GetNetworkPing()
            end)
            return ok and ping or 0
        end
        function client.eye_position()
            return Camera.CFrame.Position
        end
        function client.camera_angles()
            return Camera.CFrame
        end
        -- ============ API 3.0: рисование (renderer.* из CS2) ============
        local draw = {objects = {}}
        local function ToColor(color)
            if typeof(color) == "Color3" then
                return color
            end
            if type(color) == "table" then
                return Color3.fromRGB(color[1] or 255, color[2] or 255, color[3] or 255)
            end
            return Color3.fromRGB(255, 255, 255)
        end
        local function NewDraw(kind, props)
            local ok, object = pcall(function()
                return Drawing.new(kind)
            end)
            if not ok or not object then
                return nil
            end
            for key, value in pairs(props or {}) do
                pcall(function()
                    object[key] = value
                end)
            end
            object.Visible = true
            draw.objects[#draw.objects + 1] = object
            return object
        end
        function draw.line(x1, y1, x2, y2, color, thickness)
            return NewDraw("Line", {From = Vector2.new(x1, y1), To = Vector2.new(x2, y2), Color = ToColor(color), Thickness = thickness or 1})
        end
        function draw.rect(x, y, w, h, color, filled)
            return NewDraw("Square", {Position = Vector2.new(x, y), Size = Vector2.new(w, h), Color = ToColor(color), Filled = filled == true})
        end
        function draw.circle(x, y, radius, color, filled, segments)
            return NewDraw("Circle", {Position = Vector2.new(x, y), Radius = radius, Color = ToColor(color), Filled = filled == true, NumSides = segments or 32})
        end
        function draw.text(x, y, text, color, size, centered)
            return NewDraw("Text", {Position = Vector2.new(x, y), Text = tostring(text), Color = ToColor(color), Size = size or 13, Center = centered == true, Outline = true})
        end
        function draw.clear()
            for _, object in ipairs(draw.objects) do
                pcall(function()
                    object:Remove()
                end)
            end
            draw.objects = {}
        end
        api.draw = draw
        table.insert(session.unload, function()
            draw.clear()
        end)
        function api.world_to_screen(position)
            local screen, onScreen = Camera:WorldToViewportPoint(position)
            return screen.X, screen.Y, onScreen and screen.Z > 0
        end
        -- ============ API 3.0: сущности (entity.* из CS2) ============
        local entities = {}
        local function RootOf(player)
            local char = player and player.Character
            return char and char:FindFirstChild("HumanoidRootPart")
        end
        function entities.get_local()
            return lp
        end
        function entities.get_players(enemiesOnly)
            local result = {}
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp then
                    if not enemiesOnly or not (lp.Team and player.Team and lp.Team == player.Team) then
                        result[#result + 1] = player
                    end
                end
            end
            return result
        end
        function entities.is_alive(player)
            local char = player and player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            return hum ~= nil and hum.Health > 0
        end
        function entities.get_health(player)
            local char = player and player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            return hum and hum.Health or 0
        end
        function entities.get_root(player)
            return RootOf(player)
        end
        function entities.get_distance(player)
            local root = RootOf(player)
            if not root then
                return math.huge
            end
            return (root.Position - Camera.CFrame.Position).Magnitude
        end
        function entities.get_screen_pos(player)
            local root = RootOf(player)
            if not root then
                return nil
            end
            local screen, onScreen = Camera:WorldToViewportPoint(root.Position)
            return screen.X, screen.Y, onScreen and screen.Z > 0
        end
        function entities.get_bounding_box(player)
            local char = player and player.Character
            if not char then
                return nil
            end
            local cf, size = char:GetBoundingBox()
            local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
            local any = false
            for _, sx in ipairs({-1, 1}) do
                for _, sy in ipairs({-1, 1}) do
                    for _, sz in ipairs({-1, 1}) do
                        local corner = cf:PointToWorldSpace(Vector3.new(size.X * 0.5 * sx, size.Y * 0.5 * sy, size.Z * 0.5 * sz))
                        local screen, onScreen = Camera:WorldToViewportPoint(corner)
                        if onScreen and screen.Z > 0 then
                            any = true
                            minX = math.min(minX, screen.X)
                            minY = math.min(minY, screen.Y)
                            maxX = math.max(maxX, screen.X)
                            maxY = math.max(maxY, screen.Y)
                        end
                    end
                end
            end
            if not any then
                return nil
            end
            return minX, minY, maxX - minX, maxY - minY
        end
        api.entities = entities
        -- ============ API 3.0: ввод, сеть, данные, звук ============
        local input = {}
        function input.is_key_down(key)
            local code = Enum.KeyCode[tostring(key)]
            if not code then
                return false
            end
            return InputService:IsKeyDown(code)
        end
        function input.is_mouse_down(button)
            return InputService:IsMouseButtonPressed(button == 2 and Enum.UserInputType.MouseButton2 or Enum.UserInputType.MouseButton1)
        end
        function input.mouse_position()
            local pos = InputService:GetMouseLocation()
            return pos.X, pos.Y
        end
        api.input = input
        function api.http_get(url)
            local ok, result = pcall(function()
                return game:HttpGet(url)
            end)
            return ok and result or nil
        end
        function api.set_clipboard(text)
            if type(setclipboard) == "function" then
                pcall(setclipboard, tostring(text))
                return true
            end
            return false
        end
        function api.play_sound(id, volume)
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://" .. tostring(id)
            sound.Volume = volume or 0.5
            sound.Parent = game:GetService("SoundService")
            sound:Play()
            task.delay(3, function()
                pcall(function()
                    sound:Destroy()
                end)
            end)
            return sound
        end
        function api.data_write(key, value)
            if type(makefolder) ~= "function" or type(writefile) ~= "function" then
                return false
            end
            pcall(makefolder, "gamesense/data")
            local ok = pcall(writefile, "gamesense/data/" .. tostring(key) .. ".txt", tostring(value))
            return ok
        end
        function api.data_read(key)
            if type(readfile) ~= "function" or type(isfile) ~= "function" then
                return nil
            end
            local path = "gamesense/data/" .. tostring(key) .. ".txt"
            if not isfile(path) then
                return nil
            end
            local ok, content = pcall(readfile, path)
            return ok and content or nil
        end
        local ui = {}
        ui.version = "3.0"
        -- ============ API 3.0: ESP Preview ============
        -- Свои чипы появляются прямо в полосе превью под моделью, а
        -- preview_extend добавляет пункты в контекстное меню готовых чипов
        -- (Box, Health, Name, Distance, Ping, Item) по правому клику.
        function ui.preview_elements()
            if Library.PreviewHooks and Library.PreviewHooks.Elements then
                return Library.PreviewHooks.Elements()
            end
            return {}
        end
        function ui.preview_add_checkbox(name, default, callback)
            if not (Library.PreviewHooks and Library.PreviewHooks.AddChip) then
                return nil
            end
            return Library.PreviewHooks.AddChip({name = name, kind = "toggle", default = default == true, callback = callback})
        end
        function ui.preview_add_combobox(name, options, default, callback)
            if not (Library.PreviewHooks and Library.PreviewHooks.AddChip) then
                return nil
            end
            return Library.PreviewHooks.AddChip({name = name, kind = "combobox", options = options, default = default, callback = callback})
        end
        function ui.preview_extend(chipName, spec)
            if not (Library.PreviewHooks and Library.PreviewHooks.Extend) then
                return false
            end
            local kind = spec.type == "combobox" and "combobox" or "checkbox"
            local flagName = spec.flag or ("ESPLua_" .. tostring(chipName) .. "_" .. tostring(spec.name)):gsub("%s", "")
            Library.Flags[flagName] = Library.Flags[flagName] ~= nil and Library.Flags[flagName] or spec.default
            Library.PreviewHooks.Extend(chipName, {
                kind = kind,
                name = spec.name,
                flag = flagName,
                options = spec.options,
                default = spec.default,
                callback = spec.callback,
            })
            return true
        end
        local Elements = {}
        local ElementId = 0
        local OwnedHandles = {}
        local SessionTabs = {}
        local SessionSections = {}
        local ContainerAliases = {
            esp            = "preview esp",
            preview        = "preview esp",
            player_esp     = "preview esp",
            models         = "colored models",
            chams          = "colored models",
            world          = "world",
            effects        = "effects",
            aimbot         = "aimbot",
            ragebot        = "aimbot",
            aa             = "anti-aimbot angles",
            antiaim        = "anti-aimbot angles",
            anti_aim       = "anti-aimbot angles",
            fakelag        = "other",
            triggerbot     = "triggerbot",
            trigger        = "triggerbot",
            misc           = "misc",
            movement       = "movement",
            settings       = "settings",
            players        = "players",
            adjustments    = "adjustments",
            presets        = "presets",
            lua            = "lua",
            other          = "other",
        }
        local function Trim(value)
            return (tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", ""))
        end
        local function NormalizeId(value)
            return string.lower(Trim(value))
        end
        local function ResolveTabId(tab)
            if type(tab) == "number" then
                local data = Elements[tab]
                if data and data.kind == "tab" then
                    return data.extra.id
                end
                error("invalid tab handle", 3)
            end
            if type(tab) == "table" then
                if tab.RegistryName then
                    return string.lower(tostring(tab.RegistryName))
                end
                if tab.__tabId then
                    return string.lower(tostring(tab.__tabId))
                end
                error("invalid tab object", 3)
            end
            local id = NormalizeId(tab)
            id = Library.TabAliases[id] or id
            return id
        end
        local function TabObject(tab)
            if type(tab) == "number" then
                local data = Elements[tab]
                if data and data.kind == "tab" then
                    return data.object, data.extra.id
                end
                error("invalid tab handle", 3)
            end
            if type(tab) == "table" and tab.Items and tab.Items.ButtonHolder then
                return tab, ResolveTabId(tab)
            end
            local id = ResolveTabId(tab)
            local object = Library.TabsByName and Library.TabsByName[id]
            if not object then
                error("unknown tab '" .. id .. "'", 3)
            end
            return object, id
        end
        local function ResolveSection(tabName, containerName)
            local section, tabId = nil, nil
            if type(containerName) == "number" then
                local data = Elements[containerName]
                if data and data.kind == "section" then
                    return data.object
                end
            end
            if type(containerName) == "table" and containerName.Items and containerName.Items.Elements then
                return containerName
            end
            tabName = NormalizeId(tabName)
            tabName = Library.TabAliases[tabName] or tabName
            tabId = tabName
            containerName = NormalizeId(containerName)
            local registry = Library.Registry[tabId]
            if not registry then
                local known = {}
                for name in Library.Registry do
                    table.insert(known, name)
                end
                error("unknown tab '" .. tabId .. "' (available: " .. table.concat(known, ", ") .. ")", 3)
            end
            section = registry[containerName]
            if not section then
                local alias = ContainerAliases[containerName]
                if alias then
                    section = registry[alias]
                end
            end
            if not section then
                for name, candidate in registry do
                    if string.find(name, containerName, 1, true) then
                        section = candidate
                        break
                    end
                end
            end
            if not section then
                local known = {}
                for name in registry do
                    table.insert(known, "'" .. name .. "'")
                end
                error(
                    "unknown container '" .. containerName .. "' in tab '" .. tabId ..
                    "' (available: " .. table.concat(known, ", ") .. ")",
                    3
                )
            end
            return section
        end
        local function ResolveSectionEx(tabName, containerName)
            if type(containerName) == "number" then
                local data = Elements[containerName]
                if data and data.kind == "section" then
                    return data.object, data.extra.tab
                end
            end
            if type(containerName) == "table" and containerName.Items and containerName.Items.Elements then
                local owner = containerName.Tab
                return containerName, owner and owner.RegistryName and string.lower(owner.RegistryName) or nil
            end
            local tabId = ResolveTabId(tabName)
            return ResolveSection(tabId, containerName), tabId
        end
        local function FindSectionObject(tab, container)
            if type(container) == "number" or (type(container) == "table" and container.Items and container.Items.Elements) then
                return ResolveSectionEx(tab, container)
            end
            local tabId = ResolveTabId(tab)
            local tabObject = Library.TabsByName and Library.TabsByName[tabId]
            if not tabObject then
                error("unknown tab '" .. tabId .. "'", 3)
            end
            local registry = Library.Registry[tabId] or {}
            local key = NormalizeId(container)
            local section = registry[key]
            if not section and ContainerAliases[key] then
                section = registry[ContainerAliases[key]]
            end
            if not section then
                return ResolveSectionEx(tabId, container)
            end
            return section, tabId
        end
        local function Register(kind, object, extra)
            ElementId += 1
            local handle = ElementId
            Elements[handle] = {
                kind = kind,
                object = object,
                extra = extra or {},
                visible = true,
                enabled = true,
            }
            if extra and extra.owned then
                table.insert(OwnedHandles, handle)
            end
            return handle
        end
        local function Get(handle)
            local data = Elements[handle]
            if not data then
                error("invalid ui element", 3)
            end
            return data
        end
        local function ElementRoot(data)
            if not data then
                return nil
            end
            if data.extra and data.extra.root then
                return data.extra.root
            end
            local object = data.object
            local items = object and object.Items or {}
            return items.Toggle or items.Slider or items.Dropdown or items.Label
                or items.List or items.Button or items.ColorpickerObject or items.Keybind
                or items.Outline or items.ButtonHolder or items.Title
                or (data.extra and data.extra.label and data.extra.label.Items and data.extra.label.Items.Label)
        end
        local function ElementTitleObject(data)
            local object = data and data.object
            local items = object and object.Items or {}
            return items.Title or items.Name or items.InnerText
                or (data.extra and data.extra.label and data.extra.label.Items and data.extra.label.Items.Title)
        end
        local function RemoveFromLibraryRegistry(object)
            if type(object) ~= "table" then
                return
            end
            object.__removed = true
            if Library.ElementRegistry then
                for index = #Library.ElementRegistry, 1, -1 do
                    if Library.ElementRegistry[index] == object then
                        table.remove(Library.ElementRegistry, index)
                    end
                end
            end
        end
        local function DestroyObjectGui(object)
            if type(object) ~= "table" or not object.Items then
                return
            end
            local destroyed = {}
            local function destroy(instance)
                if instance and typeof(instance) == "Instance" and not destroyed[instance] then
                    destroyed[instance] = true
                    pcall(function()
                        instance:Destroy()
                    end)
                end
            end
            -- Popup roots live outside the element root (dropdown list, color menu, keybind menu).
            destroy(object.Items.DropdownElements)
            destroy(object.Items.Colorpicker)
            destroy(object.Items.KeybindOutline)
            destroy(object.Items.Outline)
            for _, instance in pairs(object.Items) do
                if typeof(instance) == "Instance" and instance.Parent
                    and (instance.Parent == Library.Items or instance.Parent == Library.Other) then
                    destroy(instance)
                end
            end
        end
        local function InvalidateHandlesForSection(section)
            for handle, data in pairs(Elements) do
                if data.object and data.object.__section == section then
                    Elements[handle] = nil
                elseif data.extra and data.extra.sectionObject == section then
                    Elements[handle] = nil
                end
            end
        end
        local function InvalidateHandlesForTab(tabId)
            for handle, data in pairs(Elements) do
                if data.extra and data.extra.tab == tabId then
                    Elements[handle] = nil
                elseif data.object and data.object.__tabName == tabId then
                    Elements[handle] = nil
                end
            end
        end

        ----------------------------------------------------------------
        -- Tabs: create / open / hide / remove / inspect
        ----------------------------------------------------------------
        function ui.new_tab(id, icon, options)
            if type(icon) == "table" and options == nil then
                options = icon
                icon = nil
            end
            options = options or {}
            local tabId = NormalizeId(id)
            if tabId == "" then
                error("tab id is empty", 2)
            end
            Library.TabsByName = Library.TabsByName or {}
            Library.Registry = Library.Registry or {}
            local existing = Library.TabsByName[tabId]
            if existing then
                return Register("tab", existing, {id = tabId, custom = existing.__luaCreated == true, root = existing.Items.ButtonHolder})
            end
            local iconValue = icon or options.icon or options.Icon or "rbxassetid://8547236654"
            if type(iconValue) == "number" then
                iconValue = "rbxassetid://" .. tostring(iconValue)
            end
            local tab = Window:Tab({Icon = iconValue})
            tab.RegistryName = tabId
            tab.__luaCreated = true
            tab.__luaTitle = options.title or options.name
            Library.TabsByName[tabId] = tab
            Library.Registry[tabId] = {}
            SessionTabs[tabId] = tab
            -- Custom tabs get the same two filled columns as the built-in tabs.
            tab.Items.Left.Size = dim2(0.5, -10, 1, 0)
            tab.Items.Right.Size = dim2(0.5, -10, 1, 0)
            for _, column in {tab.Items.Left, tab.Items.Right} do
                for _, child in pairs(column:GetChildren()) do
                    if child:IsA("UIListLayout") then
                        child.VerticalFlex = Enum.UIFlexAlignment.None
                    end
                end
            end
            if options.leftSize or options.rightSize then
                tab.Items.Left.Size = dim2(options.leftSize or 0.5, -10, 1, 0)
                tab.Items.Right.Size = dim2(options.rightSize or 0.5, -10, 1, 0)
            end
            if tab.__luaTitle then
                local title = Library:Create("TextLabel", {
                    Parent = tab.Items.ButtonHolder;
                    Name = "\0";
                    Text = tostring(tab.__luaTitle);
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                    TextSize = 9;
                    TextColor3 = rgb(150, 150, 150);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    Size = dim2(1, 0, 0, 12);
                    Position = dim2(0, 0, 1, -14);
                    ZIndex = 5;
                })
                tab.Items.LuaTitle = title
            end
            if options.aliases then
                for _, alias in ipairs(options.aliases) do
                    Library.TabAliases[NormalizeId(alias)] = tabId
                end
            end
            if options.open then
                tab.OpenTab()
            end
            return Register("tab", tab, {id = tabId, custom = true, root = tab.Items.ButtonHolder})
        end
        ui.create_tab = ui.new_tab
        function ui.get_tab(tab)
            local object, id = TabObject(tab)
            for handle, data in pairs(Elements) do
                if data.kind == "tab" and data.object == object then
                    return handle
                end
            end
            return Register("tab", object, {id = id, custom = object.__luaCreated == true, root = object.Items.ButtonHolder})
        end
        function ui.tab_object(tab)
            local object = TabObject(tab)
            return object
        end
        function ui.open_tab(tab)
            local object = TabObject(tab)
            if object and object.OpenTab then
                object.OpenTab()
            end
            return true
        end
        ui.select_tab = ui.open_tab
        function ui.get_current_tab()
            if not Window or not Window.TabInfo then
                return nil
            end
            for id, tab in pairs(Library.TabsByName or {}) do
                if tab.Items == Window.TabInfo then
                    return id
                end
            end
            return nil
        end
        function ui.is_tab_visible(tab)
            local object = TabObject(tab)
            return object.Items.ButtonHolder.Visible == true
        end
        function ui.set_tab_visible(tab, visible)
            local object, id = TabObject(tab)
            visible = visible and true or false
            object.Items.ButtonHolder.Visible = visible
            if not visible and ui.get_current_tab() == id then
                for otherId, other in pairs(Library.TabsByName or {}) do
                    if otherId ~= id and other.Items.ButtonHolder.Visible then
                        other.OpenTab()
                        break
                    end
                end
            end
            return visible
        end
        ui.hide_tab = function(tab)
            return ui.set_tab_visible(tab, false)
        end
        ui.show_tab = function(tab)
            return ui.set_tab_visible(tab, true)
        end
        function ui.set_tab_icon(tab, icon)
            local object = TabObject(tab)
            if type(icon) == "number" then
                icon = "rbxassetid://" .. tostring(icon)
            end
            object.Icon = icon
            object.Items.Icon.Image = icon
            object.Items.Shade.Image = icon
            return true
        end
        function ui.list_tabs()
            local out = {}
            for id, tab in pairs(Library.TabsByName or {}) do
                table.insert(out, {
                    id = id,
                    custom = tab.__luaCreated == true,
                    visible = tab.Items.ButtonHolder.Visible == true,
                    current = ui.get_current_tab() == id,
                    icon = tab.Icon,
                    title = tab.__luaTitle,
                })
            end
            table.sort(out, function(a, b)
                return a.id < b.id
            end)
            return out
        end
        function ui.remove_tab(tab, force)
            local object, id = TabObject(tab)
            if object.__luaCreated ~= true and not force then
                return false, "built-in tab: use ui.hide_tab(tab) or pass force=true"
            end
            if ui.get_current_tab() == id then
                for otherId, other in pairs(Library.TabsByName or {}) do
                    if otherId ~= id and other.Items.ButtonHolder.Visible then
                        other.OpenTab()
                        break
                    end
                end
            end
            local registry = Library.Registry[id] or {}
            for _, section in pairs(registry) do
                InvalidateHandlesForSection(section)
            end
            InvalidateHandlesForTab(id)
            pcall(function()
                object.Items.Page:Destroy()
            end)
            pcall(function()
                object.Items.ButtonHolder:Destroy()
            end)
            Library.TabsByName[id] = nil
            Library.Registry[id] = nil
            SessionTabs[id] = nil
            for alias, target in pairs(Library.TabAliases) do
                if target == id then
                    Library.TabAliases[alias] = nil
                end
            end
            return true
        end

        ----------------------------------------------------------------
        -- Sections: create on any side, move, resize, hide, remove
        ----------------------------------------------------------------
        local function NormalizeSide(side)
            side = string.lower(tostring(side or "Right"))
            if side == "l" or side == "left" then
                return "Left"
            end
            return "Right"
        end
        local function NormalizeSectionSize(size, offset)
            if type(size) == "table" then
                return tonumber(size.scale or size.Scale or size[1]) or 1,
                    tonumber(size.offset or size.Offset or size[2] or offset) or 0
            end
            return tonumber(size) or 1, tonumber(offset) or 0
        end
        function ui.new_section(tab, container, side, size)
            if type(side) == "table" then
                local config = side
                side = config.side or config.Side
                size = config.size or config.Size
            end
            local tabObject, tabId = TabObject(tab)
            local key = NormalizeId(container)
            Library.Registry[tabId] = Library.Registry[tabId] or {}
            local existing = Library.Registry[tabId][key]
            if existing and existing.__luaCreated then
                if size then
                    local sizeScale, sizeOffset = NormalizeSectionSize(size)
                    existing.Size = sizeScale
                    existing.SizeOffset = sizeOffset
                    existing.Items.Outline.Size = dim2(1, 0, sizeScale, sizeOffset)
                end
                return Register("section", existing, {tab = tabId, root = existing.Items.Outline, sectionObject = existing, existing = true})
            end
            local sizeScale, sizeOffset = NormalizeSectionSize(size)
            local section = tabObject:Section({
                Name = container,
                Side = NormalizeSide(side),
                Size = sizeScale,
            })
            section.__luaCreated = true
            section.SizeOffset = sizeOffset
            if size then
                section.Items.Outline.Size = dim2(1, 0, sizeScale, sizeOffset)
            end
            table.insert(SessionSections, {tab = tabId, id = key, section = section})
            return Register("section", section, {tab = tabId, root = section.Items.Outline, sectionObject = section, owned = true})
        end
        function ui.new_tab_section(tab, container, side, size)
            return ui.new_section(tab, container, side, size)
        end
        function ui.get_section(tab, container)
            local section, tabId = FindSectionObject(tab, container)
            return Register("section", section, {tab = tabId, root = section.Items.Outline, sectionObject = section, existing = true})
        end
        function ui.section_object(tab, container)
            local section = FindSectionObject(tab, container)
            return section
        end
        function ui.list_sections(tab)
            local _, tabId = TabObject(tab)
            local out = {}
            for name, section in pairs(Library.Registry[tabId] or {}) do
                table.insert(out, {
                    id = name,
                    name = section.Name,
                    side = section.Side,
                    custom = section.__luaCreated == true,
                    visible = section.Items.Outline.Visible == true,
                })
            end
            table.sort(out, function(a, b)
                return a.id < b.id
            end)
            return out
        end
        local function SectionArgs(tab, container, value)
            -- supports set_section_*(sectionHandle, value)
            if type(tab) == "number" and value == nil then
                local data = Get(tab)
                if data.kind == "section" then
                    return data.object, data.extra.tab, container
                end
            end
            local section, tabId = FindSectionObject(tab, container)
            return section, tabId, value
        end
        function ui.set_section_visible(tab, container, visible)
            local section, _, state = SectionArgs(tab, container, visible)
            section.Items.Outline.Visible = state and true or false
            return section.Items.Outline.Visible
        end
        ui.hide_section = function(tab, container)
            return ui.set_section_visible(tab, container, false)
        end
        ui.show_section = function(tab, container)
            return ui.set_section_visible(tab, container, true)
        end
        function ui.set_section_side(tab, container, side)
            local section, _, value = SectionArgs(tab, container, side)
            local tabObject = section.Tab
            local sideName = NormalizeSide(value)
            section.Side = sideName
            section.Items.Outline.Parent = tabObject.Items[sideName]
            return sideName
        end
        function ui.set_section_size(tab, container, size, offset)
            local section, _, value = SectionArgs(tab, container, size)
            local number, sizeOffset = NormalizeSectionSize(value, offset)
            section.Size = number
            section.SizeOffset = sizeOffset
            section.Items.Outline.Size = dim2(1, 0, number, sizeOffset)
            return number, sizeOffset
        end
        function ui.rename_section(tab, container, newName)
            local section, tabId, value = SectionArgs(tab, container, newName)
            local registry = Library.Registry[tabId]
            if registry then
                for key, candidate in pairs(registry) do
                    if candidate == section then
                        registry[key] = nil
                    end
                end
                registry[NormalizeId(value)] = section
            end
            section.Name = tostring(value)
            if section.Items.Title then
                section.Items.Title.Text = section.Name
            end
            if section.Items.Shade then
                section.Items.Shade.Text = section.Name
            end
            return section.Name
        end
        function ui.remove_section(tab, container, force)
            local section, tabId = FindSectionObject(tab, container)
            if section.__luaCreated ~= true and not force then
                return false, "built-in section: use ui.hide_section(...) or pass force=true"
            end
            if Library.ElementRegistry then
                for _, candidate in ipairs(Library.ElementRegistry) do
                    if candidate.__section == section then
                        DestroyObjectGui(candidate)
                        candidate.__removed = true
                    end
                end
            end
            InvalidateHandlesForSection(section)
            RemoveFromLibraryRegistry(section)
            DestroyObjectGui(section)
            if Library.Registry[tabId] then
                for key, candidate in pairs(Library.Registry[tabId]) do
                    if candidate == section then
                        Library.Registry[tabId][key] = nil
                    end
                end
            end
            return true
        end

        ----------------------------------------------------------------
        -- Standard element creation (old constructors stay compatible)
        ----------------------------------------------------------------
        local function FlagPrefix(name)
            return "lua_" .. tostring(name or "element") .. "_" .. tostring(ElementId + 1)
        end
        local function FindLuaElement(section, kind, name)
            if not Library.ElementRegistry then
                return nil
            end
            for index = #Library.ElementRegistry, 1, -1 do
                local candidate = Library.ElementRegistry[index]
                if candidate.__luaCreated and not candidate.__removed
                    and candidate.__section == section and candidate.__kind == kind
                    and tostring(candidate.Name or "") == tostring(name or "") then
                    return candidate
                end
            end
            return nil
        end
        local function ApplyElementConfig(handle, config)
            if not config then
                return handle
            end
            local data = Get(handle)
            if config.callback and data.kind ~= "button" then
                ui.set_callback(handle, config.callback)
            elseif config.callback and data.kind == "button" then
                ui.set_callback(handle, config.callback)
            end
            if config.order then
                ui.set_layout_order(handle, config.order)
            end
            if config.visible ~= nil then
                ui.set_visible(handle, config.visible)
            end
            if config.enabled ~= nil then
                ui.set_enabled(handle, config.enabled)
            end
            if config.color then
                local colorValue = config.color
                if type(colorValue) == "table" then
                    ui.set_color(handle, colorValue[1] or 255, colorValue[2] or 255, colorValue[3] or 255)
                end
            end
            return handle
        end
        local function CreateStandard(tab, container, kind, config)
            config = config or {}
            local section, tabId = ResolveSectionEx(tab, container)
            local name = config.name or config.Name or config.text or kind
            if kind == "label" then
                name = config.text or config.Text or name
            end
            if config.reuse then
                local existing = FindLuaElement(section, kind, name)
                if existing then
                    local handle = Register(kind, existing, {tab = tabId, section = section.Name, sectionObject = section, existing = true, label = config.__label})
                    return ApplyElementConfig(handle, config)
                end
            end
            local element, extraLabel = nil, nil
            local flag = config.flag or config.Flag or FlagPrefix(name)
            if kind == "checkbox" then
                element = section:Toggle({Name = name, Flag = flag, Default = config.default or config.Default or false})
            elseif kind == "slider" then
                element = section:Slider({
                    Name = name,
                    Min = config.min or config.Min or 0,
                    Max = config.max or config.Max or 100,
                    Default = config.default or config.Default or config.min or config.Min or 0,
                    Decimal = config.decimal or config.step or config.Decimal or 1,
                    Suffix = config.unit or config.suffix or config.Suffix or "",
                    Flag = flag,
                    Formatter = config.formatter,
                })
            elseif kind == "combobox" or kind == "multiselect" then
                local options = config.options or config.Options or {}
                element = section:Dropdown({
                    Name = name,
                    Options = options,
                    Multi = kind == "multiselect" or config.multi or false,
                    Default = config.default or config.Default or (kind == "multiselect" and {} or options[1]),
                    MinSelected = config.minSelected or 0,
                    Flag = flag,
                })
            elseif kind == "button" then
                element = section:Button({Name = name, Callback = function() end})
            elseif kind == "label" then
                element = section:Label({Name = name})
            elseif kind == "textbox" then
                element = section:Textbox({
                    Name = config.name or config.Name,
                    Flag = flag,
                    PlaceHolder = config.placeholder or config.PlaceHolder or "Type here...",
                    Default = config.default or config.Default or "",
                })
            elseif kind == "hotkey" then
                extraLabel = section:Label({Name = name})
                element = extraLabel:Keybind({Name = name, Flag = flag})
            elseif kind == "color_picker" then
                extraLabel = section:Label({Name = name})
                local colorValue = config.color
                local pickerColor = rgb(255, 255, 255)
                if typeof(colorValue) == "Color3" then
                    pickerColor = colorValue
                elseif type(colorValue) == "table" then
                    pickerColor = rgb(colorValue[1] or 255, colorValue[2] or 255, colorValue[3] or 255)
                elseif config.r then
                    pickerColor = rgb(config.r or 255, config.g or 255, config.b or 255)
                end
                element = extraLabel:Colorpicker({
                    Flag = flag,
                    Color = pickerColor,
                    Alpha = config.alpha or config.Alpha or (config.a and (1 - config.a / 255)) or 0,
                })
            else
                error("unknown element kind '" .. tostring(kind) .. "'", 3)
            end
            element.__luaCreated = true
            element.__luaKind = kind
            local handle = Register(kind, element, {
                tab = tabId,
                section = section.Name,
                sectionObject = section,
                owned = true,
                label = extraLabel,
            })
            return ApplyElementConfig(handle, config)
        end
        function ui.new_checkbox(tab, container, name, default)
            return CreateStandard(tab, container, "checkbox", {name = name, default = default})
        end
        function ui.new_slider(tab, container, name, min, max, init, showTooltip, unit, scale)
            return CreateStandard(tab, container, "slider", {
                name = name, min = min, max = max, default = init, unit = unit, decimal = scale,
            })
        end
        function ui.new_combobox(tab, container, name, ...)
            local options = {...}
            if type(options[1]) == "table" then
                options = options[1]
            end
            return CreateStandard(tab, container, "combobox", {name = name, options = options, default = options[1]})
        end
        function ui.new_multiselect(tab, container, name, ...)
            local options = {...}
            if type(options[1]) == "table" then
                options = options[1]
            end
            return CreateStandard(tab, container, "multiselect", {name = name, options = options, default = {}})
        end
        function ui.new_button(tab, container, name, callback)
            local handle = CreateStandard(tab, container, "button", {name = name})
            if callback then
                ui.set_callback(handle, function()
                    callback()
                end)
            end
            return handle
        end
        function ui.new_label(tab, container, name)
            return CreateStandard(tab, container, "label", {name = name, text = name})
        end
        function ui.new_color_picker(tab, container, name, r, g, b, a)
            return CreateStandard(tab, container, "color_picker", {
                name = name or "color", color = {r or 255, g or 255, b or 255}, a = a,
            })
        end
        function ui.new_textbox(tab, container, name)
            return CreateStandard(tab, container, "textbox", {name = name})
        end
        function ui.new_hotkey(tab, container, name)
            return CreateStandard(tab, container, "hotkey", {name = name or "hotkey"})
        end
        -- Friendly aliases
        ui.new_toggle = ui.new_checkbox
        ui.new_dropdown = ui.new_combobox
        ui.new_input = ui.new_textbox

        ----------------------------------------------------------------
        -- Generic list widget (как PlayerList в Skins)
        ----------------------------------------------------------------
        local function MakeBox(parent, height)
            local outline = Library:Create("Frame", {
                Parent = parent;
                Name = "\0";
                BorderSizePixel = 0;
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(1, 0, 0, height or 260);
                BackgroundColor3 = themes.preset.outline;
            })
            Library:Themify(outline, "outline", "BackgroundColor3")
            local inline = Library:Create("Frame", {
                Parent = outline;
                Name = "\0";
                Position = dim2(0, 1, 0, 1);
                Size = dim2(1, -2, 1, -2);
                BorderSizePixel = 0;
                BorderColor3 = rgb(0, 0, 0);
                BackgroundColor3 = themes.preset.inline;
            })
            Library:Themify(inline, "inline", "BackgroundColor3")
            local background = Library:Create("Frame", {
                Parent = inline;
                Name = "\0";
                Position = dim2(0, 1, 0, 1);
                Size = dim2(1, -2, 1, -2);
                BorderSizePixel = 0;
                BorderColor3 = rgb(0, 0, 0);
                BackgroundColor3 = rgb(23, 23, 23);
            })
            return outline, background
        end
        local function NormalizeListItem(item)
            if type(item) == "table" then
                local id = item.id or item.Id or item.value or item.Value or item.text or item.Text or item.name or item.Name
                local text = item.text or item.Text or item.name or item.Name or tostring(id)
                return {
                    id = tostring(id),
                    text = tostring(text),
                    data = item.data or item.Data or item.value or item.Value or item,
                    suffix = item.suffix or item.badge,
                    color = item.color,
                }
            end
            return {id = tostring(item), text = tostring(item), data = item}
        end
        local function CreateList(tab, container, config)
            config = config or {}
            local section, tabId = ResolveSectionEx(tab, container)
            local state = {
                Name = config.name or config.Name or "List",
                Callback = function() end,
                DoubleCallback = nil,
                ItemsData = {},
                Entries = {},
                Selected = nil,
                SelectedIndex = nil,
                Filter = "",
                Height = config.height or config.Height or 260,
                Items = {},
            }
            local showSearch = config.search ~= false
            local outline, background = MakeBox(section.Items.Elements, state.Height)
            outline.LayoutOrder = config.order or 0
            state.Items.List = outline
            state.Items.Outline = outline
            local searchBox = nil
            local holderTop = 2
            if showSearch then
                local searchFrame = Library:Create("Frame", {
                    Parent = background;
                    Name = "\0";
                    Position = dim2(0, 2, 0, 2);
                    Size = dim2(1, -4, 0, 18);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(13, 13, 13);
                    ZIndex = 3;
                })
                searchBox = Library:Create("TextBox", {
                    Parent = searchFrame;
                    Name = "\0";
                    Text = "";
                    PlaceholderText = config.searchPlaceholder or "Search...";
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                    TextSize = 13;
                    TextColor3 = rgb(205, 205, 205);
                    PlaceholderColor3 = rgb(120, 120, 120);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    Position = dim2(0, 5, 0, 0);
                    Size = dim2(1, -10, 1, 0);
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ClearTextOnFocus = false;
                    ZIndex = 4;
                })
                holderTop = 23
                state.Items.Search = searchBox
            end
            local holder = Library:Create("ScrollingFrame", {
                Parent = background;
                Name = "\0";
                Active = true;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Position = dim2(0, 0, 0, holderTop);
                Size = dim2(1, 0, 1, -(holderTop + 2));
                CanvasSize = dim2(0, 0, 0, 0);
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                ScrollBarThickness = 4;
                ScrollBarImageColor3 = rgb(65, 65, 65);
                MidImage = "rbxassetid://74268315755026";
                TopImage = "rbxassetid://74268315755026";
                BottomImage = "rbxassetid://74268315755026";
                ZIndex = 2;
            })
            Library:Create("UIListLayout", {
                Parent = holder;
                Padding = dim(0, 1);
                SortOrder = Enum.SortOrder.LayoutOrder;
            })
            state.Items.Holder = holder
            local handle = nil
            local function itemVisible(item)
                if state.Filter == "" then
                    return true
                end
                local filter = string.lower(state.Filter)
                return string.find(string.lower(item.text), filter, 1, true) ~= nil
                    or string.find(string.lower(item.id), filter, 1, true) ~= nil
            end
            local function refreshVisuals()
                for id, entry in pairs(state.Entries) do
                    local item = nil
                    for _, candidate in ipairs(state.ItemsData) do
                        if candidate.id == id then
                            item = candidate
                            break
                        end
                    end
                    local selected = id == state.Selected
                    entry.BackgroundTransparency = selected and 0 or 1
                    entry.BackgroundColor3 = themes.preset.accent
                    entry.TextColor3 = selected and rgb(255, 255, 255) or themes.preset.text_color
                    entry.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", selected and Enum.FontWeight.SemiBold or Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                    entry.Visible = item and itemVisible(item) or false
                end
            end
            local function rebuild()
                for _, entry in pairs(state.Entries) do
                    pcall(function()
                        entry:Destroy()
                    end)
                end
                table.clear(state.Entries)
                for index, item in ipairs(state.ItemsData) do
                    local display = item.suffix and (item.text .. "  [" .. tostring(item.suffix) .. "]") or item.text
                    local entry = Library:Create("TextButton", {
                        Parent = holder;
                        Name = "\0";
                        Text = display;
                        AutoButtonColor = false;
                        LayoutOrder = index;
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                        TextSize = 13;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextColor3 = themes.preset.text_color;
                        BackgroundColor3 = themes.preset.accent;
                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 0, 14);
                        Position = dim2(0, 1, 0, 0);
                        ZIndex = 3;
                    })
                    Library:Create("UIPadding", {
                        Parent = entry;
                        PaddingLeft = dim(0, 4);
                    })
                    if type(item.color) == "table" then
                        entry.TextColor3 = rgb(item.color[1] or 205, item.color[2] or 205, item.color[3] or 205)
                    end
                    local lastClick = 0
                    table.insert(session.connections, entry.MouseButton1Click:Connect(function()
                        local now = os.clock()
                        local double = (now - lastClick) < 0.35
                        lastClick = now
                        state.Selected = item.id
                        state.SelectedIndex = index
                        refreshVisuals()
                        if state.Callback then
                            state.Callback(item.id, item.text, index, item.data)
                        end
                        if double and state.DoubleCallback then
                            state.DoubleCallback(item.id, item.text, index, item.data)
                        end
                    end))
                    state.Entries[item.id] = entry
                end
                refreshVisuals()
            end
            state.__rebuild = rebuild
            state.__refresh = refreshVisuals
            state.__holder = holder
            if searchBox then
                table.insert(session.connections, searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    state.Filter = searchBox.Text or ""
                    refreshVisuals()
                end))
            end
            handle = Register("list", state, {
                tab = tabId,
                section = section.Name,
                sectionObject = section,
                owned = true,
                root = outline,
            })
            if config.items then
                ui.list_set_items(handle, config.items)
            end
            if config.callback then
                ui.set_callback(handle, config.callback)
            end
            if config.doubleCallback then
                state.DoubleCallback = function(...)
                    pcall(config.doubleCallback, handle, ...)
                end
            end
            return handle
        end
        function ui.new_list(tab, container, name, height, showSearch)
            if type(name) == "table" then
                local config = name
                config.name = config.name or config.Name or "List"
                return CreateList(tab, container, config)
            end
            return CreateList(tab, container, {name = name, height = height, search = showSearch})
        end
        local function ListState(handle)
            local data = Get(handle)
            if data.kind ~= "list" then
                error("element is not a list", 3)
            end
            return data.object, data
        end
        function ui.list_set_items(handle, items, preserveSelection)
            local state = ListState(handle)
            local previous = preserveSelection and state.Selected or nil
            state.ItemsData = {}
            for _, item in ipairs(items or {}) do
                table.insert(state.ItemsData, NormalizeListItem(item))
            end
            if previous then
                local found = false
                for index, item in ipairs(state.ItemsData) do
                    if item.id == previous then
                        state.SelectedIndex = index
                        found = true
                        break
                    end
                end
                if not found then
                    state.Selected, state.SelectedIndex = nil, nil
                end
            else
                state.Selected, state.SelectedIndex = nil, nil
            end
            state.__rebuild()
            return #state.ItemsData
        end
        function ui.list_add(handle, item, selectIt)
            local state = ListState(handle)
            local normalized = NormalizeListItem(item)
            for _, existing in ipairs(state.ItemsData) do
                if existing.id == normalized.id then
                    existing.text, existing.data, existing.suffix = normalized.text, normalized.data, normalized.suffix
                    state.__rebuild()
                    if selectIt then
                        ui.list_set_selected(handle, normalized.id, true)
                    end
                    return normalized.id
                end
            end
            table.insert(state.ItemsData, normalized)
            state.__rebuild()
            if selectIt then
                ui.list_set_selected(handle, normalized.id, true)
            end
            return normalized.id
        end
        function ui.list_remove(handle, id)
            local state = ListState(handle)
            id = tostring(id)
            for index, item in ipairs(state.ItemsData) do
                if item.id == id then
                    table.remove(state.ItemsData, index)
                    if state.Selected == id then
                        state.Selected, state.SelectedIndex = nil, nil
                    end
                    state.__rebuild()
                    return true
                end
            end
            return false
        end
        function ui.list_clear(handle)
            local state = ListState(handle)
            state.ItemsData = {}
            state.Selected, state.SelectedIndex = nil, nil
            state.__rebuild()
        end
        function ui.list_count(handle)
            local state = ListState(handle)
            return #state.ItemsData
        end
        function ui.list_get_items(handle)
            local state = ListState(handle)
            local out = {}
            for index, item in ipairs(state.ItemsData) do
                table.insert(out, {id = item.id, text = item.text, index = index, data = item.data})
            end
            return out
        end
        function ui.list_get_selected(handle)
            local state = ListState(handle)
            if not state.Selected then
                return nil
            end
            for index, item in ipairs(state.ItemsData) do
                if item.id == state.Selected then
                    return item.id, item.text, index, item.data
                end
            end
            return nil
        end
        function ui.list_set_selected(handle, id, silent)
            local state = ListState(handle)
            if id == nil then
                state.Selected, state.SelectedIndex = nil, nil
                state.__refresh()
                return nil
            end
            for index, item in ipairs(state.ItemsData) do
                if item.id == tostring(id) then
                    state.Selected, state.SelectedIndex = item.id, index
                    state.__refresh()
                    if not silent and state.Callback then
                        state.Callback(item.id, item.text, index, item.data)
                    end
                    return item.id
                end
            end
            return nil
        end
        function ui.list_set_search(handle, text)
            local state, data = ListState(handle)
            state.Filter = tostring(text or "")
            if state.Items.Search then
                state.Items.Search.Text = state.Filter
            end
            state.__refresh()
            return state.Filter
        end
        function ui.list_set_double_callback(handle, callback)
            local state = ListState(handle)
            state.DoubleCallback = function(...)
                pcall(callback, handle, ...)
            end
        end
        function ui.list_set_height(handle, height)
            local state, data = ListState(handle)
            state.Height = tonumber(height) or state.Height
            data.extra.root.Size = dim2(1, 0, 0, state.Height)
            return state.Height
        end
        function ui.list_sort(handle, descending)
            local state = ListState(handle)
            table.sort(state.ItemsData, function(a, b)
                if descending then
                    return string.lower(a.text) > string.lower(b.text)
                end
                return string.lower(a.text) < string.lower(b.text)
            end)
            state.__rebuild()
        end

        ----------------------------------------------------------------
        -- Info panel (правая часть как в PlayerList)
        ----------------------------------------------------------------
        local function CreateInfoPanel(tab, container, config)
            config = config or {}
            local section, tabId = ResolveSectionEx(tab, container)
            local outline, background = MakeBox(section.Items.Elements, config.height or 260)
            outline.LayoutOrder = config.order or 0
            local holder = Library:Create("ScrollingFrame", {
                Parent = background;
                Name = "\0";
                Active = true;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Position = dim2(0, 0, 0, 2);
                Size = dim2(1, 0, 1, -4);
                CanvasSize = dim2(0, 0, 0, 0);
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                ScrollBarThickness = 4;
                ScrollBarImageColor3 = rgb(65, 65, 65);
                MidImage = "rbxassetid://74268315755026";
                TopImage = "rbxassetid://74268315755026";
                BottomImage = "rbxassetid://74268315755026";
                ZIndex = 2;
            })
            Library:Create("UIListLayout", {
                Parent = holder;
                Padding = dim(0, 1);
                SortOrder = Enum.SortOrder.LayoutOrder;
            })
            local state = {
                Name = config.name or config.Name or "Info",
                Rows = {},
                RowOrder = {},
                Items = {List = outline, Outline = outline, Holder = holder},
                Callback = function() end,
            }
            local handle = Register("info", state, {
                tab = tabId,
                section = section.Name,
                sectionObject = section,
                owned = true,
                root = outline,
            })
            if config.title then
                ui.info_add_header(handle, config.title)
            end
            if config.rows then
                for _, row in ipairs(config.rows) do
                    if type(row) == "table" then
                        ui.info_add_row(handle, row.key or row[1], row.label or row[2] or row.key or row[1], row.color)
                    else
                        ui.info_add_row(handle, row, row)
                    end
                end
            end
            return handle
        end
        function ui.new_info_panel(tab, container, name, height)
            if type(name) == "table" then
                return CreateInfoPanel(tab, container, name)
            end
            return CreateInfoPanel(tab, container, {name = name, height = height})
        end
        local function InfoState(handle)
            local data = Get(handle)
            if data.kind ~= "info" then
                error("element is not an info panel", 3)
            end
            return data.object
        end
        function ui.info_add_header(handle, text)
            local state = InfoState(handle)
            local holder = state.Items.Holder
            local order = #state.RowOrder + 100
            local frame = Library:Create("Frame", {
                Parent = holder;
                Name = "\0";
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Size = dim2(1, 0, 0, 26);
                LayoutOrder = order;
            })
            local label = Library:Create("TextLabel", {
                Parent = frame;
                Name = "\0";
                Text = string.upper(tostring(text));
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
                TextSize = 13;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                TextColor3 = themes.preset.accent;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Position = dim2(0, 10, 0, 0);
                Size = dim2(1, -20, 1, -5);
                ZIndex = 3;
            })
            Library:Themify(label, "accent", "TextColor3")
            table.insert(state.RowOrder, {header = true, frame = frame})
            return label
        end
        function ui.info_add_row(handle, key, labelText, color)
            local state = InfoState(handle)
            key = tostring(key)
            if state.Rows[key] then
                return state.Rows[key]
            end
            local holder = state.Items.Holder
            local order = #state.RowOrder + 1
            local row = Library:Create("Frame", {
                Parent = holder;
                Name = "\0";
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Size = dim2(1, 0, 0, 22);
                LayoutOrder = order;
            })
            local title = Library:Create("TextLabel", {
                Parent = row;
                Name = "\0";
                Text = tostring(labelText or key);
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                TextSize = 14;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Center;
                TextColor3 = type(color) == "table" and rgb(color[1] or 205, color[2] or 205, color[3] or 205) or rgb(205, 205, 205);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Position = dim2(0, 10, 0, 0);
                Size = dim2(0.55, -10, 1, 0);
                ZIndex = 3;
            })
            local value = Library:Create("TextLabel", {
                Parent = row;
                Name = "\0";
                Text = "-";
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
                TextSize = 14;
                TextXAlignment = Enum.TextXAlignment.Right;
                TextYAlignment = Enum.TextYAlignment.Center;
                TextTruncate = Enum.TextTruncate.AtEnd;
                TextColor3 = themes.preset.text_color;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                AnchorPoint = vec2(1, 0);
                Position = dim2(1, -10, 0, 0);
                Size = dim2(0.45, 0, 1, 0);
                ZIndex = 3;
            })
            Library:Create("UIStroke", {
                Parent = value;
                Transparency = 0.6;
                LineJoinMode = Enum.LineJoinMode.Miter;
            })
            local record = {Row = row, Title = title, Value = value, Key = key}
            state.Rows[key] = record
            table.insert(state.RowOrder, record)
            return record
        end
        function ui.info_set(handle, key, value, r, g, b)
            local state = InfoState(handle)
            if type(key) == "table" and value == nil then
                for rowKey, rowValue in pairs(key) do
                    ui.info_set(handle, rowKey, rowValue)
                end
                return true
            end
            local record = state.Rows[tostring(key)] or ui.info_add_row(handle, key, key)
            if type(value) == "table" and value.Text ~= nil then
                record.Value.Text = tostring(value.Text)
                if value.Color then
                    record.Value.TextColor3 = value.Color
                end
            else
                record.Value.Text = value == nil and "-" or tostring(value)
            end
            if r then
                record.Value.TextColor3 = rgb(r or 255, g or 255, b or 255)
            end
            return true
        end
        function ui.info_get(handle, key)
            local state = InfoState(handle)
            local record = state.Rows[tostring(key)]
            return record and record.Value.Text or nil
        end
        function ui.info_clear(handle)
            local state = InfoState(handle)
            for _, record in pairs(state.Rows) do
                record.Value.Text = "-"
            end
        end
        function ui.info_remove_row(handle, key)
            local state = InfoState(handle)
            local record = state.Rows[tostring(key)]
            if record then
                pcall(function()
                    record.Row:Destroy()
                end)
                state.Rows[tostring(key)] = nil
                return true
            end
            return false
        end

        ----------------------------------------------------------------
        -- Image / progress / spacer
        ----------------------------------------------------------------
        function ui.new_image(tab, container, name, image, width, height)
            local section, tabId = ResolveSectionEx(tab, container)
            local root = Library:Create("Frame", {
                Parent = section.Items.Elements;
                Name = "\0";
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Size = dim2(1, 0, 0, (height or 80) + 16);
            })
            local title = nil
            if name then
                title = Library:Create("TextLabel", {
                    Parent = root;
                    Name = "\0";
                    Text = tostring(name);
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                    TextSize = 13;
                    TextColor3 = rgb(205, 205, 205);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    Position = dim2(0, 21, 0, -2);
                    Size = dim2(1, -21, 0, 14);
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ZIndex = 2;
                })
            end
            local imageValue = image
            if type(imageValue) == "number" then
                imageValue = "rbxassetid://" .. tostring(imageValue)
            end
            local picture = Library:Create("ImageLabel", {
                Parent = root;
                Name = "\0";
                Image = imageValue or "";
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Position = dim2(0, 20, 0, 14);
                Size = dim2(0, width or 80, 0, height or 80);
                ZIndex = 2;
            })
            local state = {Name = name, Items = {Label = root, Title = title, Image = picture}, ImageInstance = picture}
            return Register("image", state, {tab = tabId, section = section.Name, sectionObject = section, owned = true, root = root})
        end
        function ui.set_image(handle, image)
            local data = Get(handle)
            if data.kind ~= "image" then
                error("element is not an image", 3)
            end
            if type(image) == "number" then
                image = "rbxassetid://" .. tostring(image)
            end
            data.object.ImageInstance.Image = image
            return true
        end
        function ui.new_progress(tab, container, name, default, max)
            local section, tabId = ResolveSectionEx(tab, container)
            max = tonumber(max) or 100
            local root = Library:Create("Frame", {
                Parent = section.Items.Elements;
                Name = "\0";
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Size = dim2(1, 0, 0, 30);
            })
            local title = Library:Create("TextLabel", {
                Parent = root;
                Name = "\0";
                Text = tostring(name or "Progress");
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                TextSize = 13;
                TextColor3 = rgb(205, 205, 205);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Position = dim2(0, 21, 0, -2);
                Size = dim2(1, -21, 0, 14);
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 2;
            })
            local holder = Library:Create("Frame", {
                Parent = root;
                Name = "\0";
                Position = dim2(0, 20, 0, 14);
                Size = dim2(1, -55, 0, 7);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(12, 12, 12);
            })
            local fill = Library:Create("Frame", {
                Parent = holder;
                Name = "\0";
                Position = dim2(0, 1, 0, 1);
                Size = dim2(0, 0, 1, -2);
                BorderSizePixel = 0;
                ZIndex = 2;
                BackgroundColor3 = themes.preset.accent;
            })
            Library:Themify(fill, "accent", "BackgroundColor3")
            local valueLabel = Library:Create("TextLabel", {
                Parent = root;
                Name = "\0";
                Text = "";
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
                TextSize = 13;
                TextColor3 = rgb(205, 205, 205);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                AnchorPoint = vec2(1, 0);
                Position = dim2(1, -5, 0, 10);
                Size = dim2(0, 50, 0, 14);
                TextXAlignment = Enum.TextXAlignment.Right;
                ZIndex = 2;
            })
            local state = {
                Name = name, Value = tonumber(default) or 0, Max = max,
                Callback = function() end,
                Items = {Label = root, Title = title, Holder = holder, Fill = fill, ValueLabel = valueLabel},
            }
            state.Update = function()
                local percent = max > 0 and math.clamp(state.Value / max, 0, 1) or 0
                fill.Size = dim2(percent, percent == 0 and 0 or -2, 1, -2)
                valueLabel.Text = tostring(state.Value) .. "/" .. tostring(max)
            end
            state.Update()
            return Register("progress", state, {tab = tabId, section = section.Name, sectionObject = section, owned = true, root = root})
        end
        function ui.new_spacer(tab, container, height)
            local section, tabId = ResolveSectionEx(tab, container)
            local root = Library:Create("Frame", {
                Parent = section.Items.Elements;
                Name = "\0";
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Size = dim2(1, 0, 0, tonumber(height) or 8);
            })
            local state = {Name = "spacer", Items = {Label = root}}
            return Register("spacer", state, {tab = tabId, section = section.Name, sectionObject = section, owned = true, root = root})
        end
        ui.new_separator = function(tab, container)
            return ui.new_label(tab, container, "------------------------")
        end

        ----------------------------------------------------------------
        -- Unified creation: ui.create(tab, container, kind, config)
        ----------------------------------------------------------------
        function ui.create(tab, container, kind, config)
            config = config or {}
            kind = string.lower(tostring(kind or "label"))
            if kind == "toggle" then
                kind = "checkbox"
            elseif kind == "dropdown" then
                kind = "combobox"
            elseif kind == "multi" or kind == "multiselect_dropdown" then
                kind = "multiselect"
            elseif kind == "input" then
                kind = "textbox"
            elseif kind == "color" then
                kind = "color_picker"
            end
            if kind == "list" then
                config.name = config.name or config.Name or "List"
                return CreateList(tab, container, config)
            elseif kind == "info" or kind == "info_panel" then
                return CreateInfoPanel(tab, container, config)
            elseif kind == "image" then
                return ui.new_image(tab, container, config.name or config.Name, config.image or config.Image, config.width, config.height)
            elseif kind == "progress" then
                return ui.new_progress(tab, container, config.name or config.Name, config.default or 0, config.max or 100)
            elseif kind == "spacer" then
                return ui.new_spacer(tab, container, config.height or 8)
            end
            return CreateStandard(tab, container, kind, config)
        end
        ui.add = ui.create

        ----------------------------------------------------------------
        -- Get / set / callbacks / visibility / text / colors
        ----------------------------------------------------------------
        function ui.get(handle)
            local data = Get(handle)
            local object = data.object
            if data.kind == "list" then
                local id, text, index, itemData = ui.list_get_selected(handle)
                return id, text, index, itemData
            end
            if data.kind == "progress" then
                return object.Value
            end
            if data.kind == "label" then
                return object.Name
            end
            if data.kind == "tab" then
                return data.extra.id
            end
            if data.kind == "section" then
                return object.Name
            end
            if data.kind == "color_picker" then
                local value = Flags[object.Flag]
                if type(value) == "table" and value.Color then
                    local colorValue = value.Color
                    return math.floor(colorValue.R * 255), math.floor(colorValue.G * 255), math.floor(colorValue.B * 255),
                        math.floor((1 - (value.Transparency or 0)) * 255)
                end
                return 255, 255, 255, 255
            end
            if object and object.Flag then
                return Flags[object.Flag]
            end
            return nil
        end
        function ui.set(handle, ...)
            local data = Get(handle)
            local object = data.object
            if data.kind == "list" then
                return ui.list_set_selected(handle, (...), false)
            end
            if data.kind == "progress" then
                object.Value = tonumber((...)) or 0
                object.Update()
                if object.Callback then
                    object.Callback(object.Value)
                end
                return object.Value
            end
            if data.kind == "image" then
                return ui.set_image(handle, (...))
            end
            if data.kind == "color_picker" then
                local r, g, b, a = ...
                if object.Set then
                    object.Set(rgb(r or 255, g or 255, b or 255), a and (1 - a / 255) or 0)
                end
                return
            end
            if data.kind == "button" then
                if object.Callback then
                    pcall(object.Callback)
                end
                return
            end
            if data.kind == "tab" then
                return ui.open_tab(handle)
            end
            if data.kind == "section" then
                return ui.set_section_visible(handle, (...))
            end
            if object and object.Set then
                object.Set((...))
            end
        end
        ui.set_value = ui.set
        function ui.set_callback(handle, callback)
            local data = Get(handle)
            if data.kind == "list" or data.kind == "info" or data.kind == "progress" then
                data.object.Callback = function(...)
                    pcall(callback, handle, ...)
                end
                return handle
            end
            data.object.Callback = function(...)
                pcall(callback, handle, ...)
            end
            return handle
        end
        function ui.set_visible(handle, visible)
            local data = Get(handle)
            data.visible = visible and true or false
            if data.kind == "tab" then
                return ui.set_tab_visible(handle, data.visible)
            end
            if data.kind == "section" then
                data.object.Items.Outline.Visible = data.visible
                return data.visible
            end
            local instance = ElementRoot(data)
            if instance then
                instance.Visible = data.visible
            end
            return data.visible
        end
        function ui.is_visible(handle)
            local data = Get(handle)
            if data.kind == "tab" then
                return ui.is_tab_visible(handle)
            end
            local instance = ElementRoot(data)
            return instance and instance.Visible == true or data.visible == true
        end
        ui.show = ui.set_visible
        function ui.hide(handle)
            return ui.set_visible(handle, false)
        end
        function ui.set_enabled(handle, enabled)
            local data = Get(handle)
            local instance = ElementRoot(data)
            data.enabled = enabled and true or false
            if instance then
                for _, child in ipairs(instance:GetDescendants()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                        child.TextTransparency = data.enabled and 0 or 0.6
                    end
                end
                if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
                    instance.TextTransparency = data.enabled and 0 or 0.6
                end
            end
            return data.enabled
        end
        function ui.is_enabled(handle)
            return Get(handle).enabled == true
        end
        function ui.set_color(handle, r, g, b)
            local data = Get(handle)
            local object = data.object
            local items = object.Items or {}
            local colorValue = rgb(r or 255, g or 255, b or 255)
            local target = items.Title or items.Name
            if target then
                target.TextColor3 = colorValue
            end
            if data.extra and data.extra.label and data.extra.label.Items then
                data.extra.label.Items.Title.TextColor3 = colorValue
            end
            if data.kind == "list" then
                -- у списка цвет меняет только заголовки строк через пересоздание не трогаем
            end
            return true
        end
        function ui.set_accent_color(handle, r, g, b)
            local data = Get(handle)
            local items = data.object.Items or {}
            local colorValue = rgb(r or 255, g or 255, b or 255)
            if items.Accent and items.Accent:IsA("Frame") then
                items.Accent.BackgroundColor3 = colorValue
            end
            if data.kind == "progress" and items.Fill then
                items.Fill.BackgroundColor3 = colorValue
            end
            return true
        end
        function ui.set_text(handle, text)
            local data = Get(handle)
            local object = data.object
            text = tostring(text)
            if data.kind == "section" then
                object.Name = text
                if object.Items.Title then
                    object.Items.Title.Text = text
                end
                if object.Items.Shade then
                    object.Items.Shade.Text = text
                end
                return text
            end
            if data.kind == "label" and object.Set then
                object.Set(text)
                return text
            end
            local target = ElementTitleObject(data)
            if target then
                target.Text = text
            end
            if object and object.Name ~= nil and data.kind ~= "list" and data.kind ~= "info" then
                object.Name = text
            end
            if data.kind == "list" or data.kind == "info" or data.kind == "image" or data.kind == "progress" then
                object.Name = text
                local title = object.Items and object.Items.Title
                if title then
                    title.Text = text
                end
            end
            return text
        end
        ui.rename = ui.set_text
        function ui.name(handle)
            local data = Get(handle)
            if data.kind == "tab" then
                return data.extra.id
            end
            if data.kind == "section" then
                return data.object.Name
            end
            if data.kind == "list" or data.kind == "info" or data.kind == "image" or data.kind == "progress" then
                return data.object.Name or ""
            end
            local target = ElementTitleObject(data)
            if target then
                return target.Text or ""
            end
            return data.object.Name or ""
        end
        function ui.type(handle)
            return Get(handle).kind
        end
        function ui.raw(handle)
            return Get(handle).object
        end
        function ui.is_menu_open()
            return Library.Window and Library.Window.Visible or false
        end
        ui.is_menu_opened = ui.is_menu_open
        function ui.mouse_position()
            local pos = InputService:GetMouseLocation()
            return pos.X, pos.Y
        end
        function ui.set_layout_order(handle, order)
            local data = Get(handle)
            local instance = ElementRoot(data)
            if instance then
                instance.LayoutOrder = tonumber(order) or 0
            end
            return tonumber(order) or 0
        end
        function ui.get_layout_order(handle)
            local instance = ElementRoot(Get(handle))
            return instance and instance.LayoutOrder or 0
        end
        function ui.move(handle, tab, container)
            local data = Get(handle)
            local section, tabId = ResolveSectionEx(tab, container)
            local instance = ElementRoot(data)
            if data.extra and data.extra.label and data.extra.label.Items then
                instance = data.extra.label.Items.Label or instance
            end
            if instance then
                instance.Parent = section.Items.Elements
            end
            data.extra.tab = tabId
            data.extra.section = section.Name
            data.extra.sectionObject = section
            if type(data.object) == "table" then
                data.object.__section = section
                data.object.__tabName = tabId
                data.object.__sectionName = section.Name
            end
            return true
        end

        ----------------------------------------------------------------
        -- Editing existing elements: range / options / placeholder
        ----------------------------------------------------------------
        function ui.set_range(handle, minValue, maxValue)
            local data = Get(handle)
            local object = data.object
            if data.kind ~= "slider" or not object.Set then
                error("element is not a slider", 3)
            end
            object.Min = math.floor((tonumber(minValue) or object.Min) + 0.5)
            object.Max = math.floor((tonumber(maxValue) or object.Max) + 0.5)
            if object.Max < object.Min then
                object.Max = object.Min
            end
            object.Set(object.Value)
            return object.Min, object.Max
        end
        function ui.get_range(handle)
            local object = Get(handle).object
            return object.Min, object.Max
        end
        function ui.set_step(handle, step)
            local data = Get(handle)
            local object = data.object
            if data.kind ~= "slider" then
                error("element is not a slider", 3)
            end
            object.Intervals = math.max(1, math.floor((tonumber(step) or object.Intervals or 1) + 0.5))
            object.Set(object.Value)
            return object.Intervals
        end
        function ui.set_suffix(handle, suffix)
            local data = Get(handle)
            local object = data.object
            if data.kind ~= "slider" then
                error("element is not a slider", 3)
            end
            object.Suffix = tostring(suffix or "")
            object.Set(object.Value)
            return object.Suffix
        end
        function ui.get_options(handle)
            local data = Get(handle)
            if data.kind ~= "combobox" and data.kind ~= "multiselect" then
                error("element is not a combobox", 3)
            end
            local out = {}
            for _, option in ipairs(data.object.Options or {}) do
                table.insert(out, option)
            end
            return out
        end
        function ui.set_options(handle, options, keepSelection)
            local data = Get(handle)
            local object = data.object
            if data.kind ~= "combobox" and data.kind ~= "multiselect" then
                error("element is not a combobox", 3)
            end
            options = options or {}
            local current = Flags[object.Flag]
            object.RefreshOptions(options)
            object.Options = options
            if data.kind == "multiselect" then
                local filtered = {}
                if keepSelection and type(current) == "table" then
                    for _, value in ipairs(current) do
                        if table.find(options, value) then
                            table.insert(filtered, value)
                        end
                    end
                end
                object.Set(filtered)
            else
                if keepSelection and current ~= nil and table.find(options, current) then
                    object.Set(current)
                elseif options[1] ~= nil then
                    object.Set(options[1])
                else
                    object.Set(nil)
                end
            end
            return options
        end
        function ui.add_option(handle, option)
            local options = ui.get_options(handle)
            if not table.find(options, option) then
                table.insert(options, option)
                ui.set_options(handle, options, true)
            end
            return options
        end
        function ui.remove_option(handle, option)
            local options = ui.get_options(handle)
            local index = table.find(options, option)
            if index then
                table.remove(options, index)
                ui.set_options(handle, options, true)
            end
            return options
        end
        function ui.set_placeholder(handle, text)
            local data = Get(handle)
            if data.kind ~= "textbox" then
                error("element is not a textbox", 3)
            end
            if data.object.Items and data.object.Items.Background then
                data.object.Items.Background.PlaceholderText = tostring(text or "")
            end
            return text
        end

        ----------------------------------------------------------------
        -- Find / reference / describe existing (built-in) elements
        ----------------------------------------------------------------
        local function CandidateSection(candidate)
            if candidate.__section then
                return candidate.__section
            end
            -- fallback: ищем секцию по GUI-иерархии
            local root = nil
            local items = candidate.Items or {}
            root = items.Toggle or items.Slider or items.Dropdown or items.Label or items.List or items.Button or items.ColorpickerObject or items.Keybind
            if root then
                for _, sections in pairs(Library.Registry or {}) do
                    for _, section in pairs(sections) do
                        local ok, descendant = pcall(function()
                            return root:IsDescendantOf(section.Items.Elements)
                        end)
                        if ok and descendant then
                            candidate.__section = section
                            candidate.__tabName = section.Tab and section.Tab.RegistryName
                            candidate.__sectionName = section.Name
                            return section
                        end
                    end
                end
            end
            return nil
        end
        local function CandidateName(candidate)
            if candidate.Name ~= nil then
                return tostring(candidate.Name)
            end
            local items = candidate.Items or {}
            local target = items.Title or items.Name
            return target and target.Text or ""
        end
        local function SessionHandleFor(object)
            for handle, data in pairs(Elements) do
                if data.object == object then
                    return handle
                end
            end
            return nil
        end
        local function RegisterCandidate(candidate, tabId, section)
            local existing = SessionHandleFor(candidate)
            if existing then
                return existing
            end
            local kind = candidate.__kind or candidate.__luaKind or "reference"
            return Register(kind, candidate, {
                tab = tabId,
                section = section and section.Name,
                sectionObject = section,
                existing = true,
            })
        end
        function ui.reference(tab, container, name, kind, occurrence)
            local section, tabId = FindSectionObject(tab, container)
            local wanted = string.lower(tostring(name or ""))
            local wantedKind = kind and string.lower(tostring(kind)) or nil
            occurrence = tonumber(occurrence) or 1
            local exact, fuzzy = {}, {}
            for _, candidate in ipairs(Library.ElementRegistry or {}) do
                if candidate.__removed then
                    continue
                end
                local candidateSection = CandidateSection(candidate)
                if candidateSection ~= section then
                    continue
                end
                if wantedKind and string.lower(tostring(candidate.__kind or "")) ~= wantedKind then
                    continue
                end
                local candidateName = string.lower(CandidateName(candidate))
                if candidateName == wanted then
                    table.insert(exact, candidate)
                elseif string.find(candidateName, wanted, 1, true) then
                    table.insert(fuzzy, candidate)
                end
            end
            local chosen = exact[occurrence] or fuzzy[occurrence]
            if chosen then
                return RegisterCandidate(chosen, tabId, section)
            end
            -- fallback как в старой версии API: просто текстовый лейбл
            for _, child in ipairs(section.Items.Elements:GetDescendants()) do
                if child:IsA("TextLabel") and child.Text == name then
                    return Register("reference", {Items = {Title = child}}, {tab = tabId, section = section.Name, sectionObject = section, existing = true})
                end
            end
            return nil
        end
        function ui.reference_by_flag(flag)
            for _, candidate in ipairs(Library.ElementRegistry or {}) do
                if not candidate.__removed and candidate.Flag == flag then
                    local section = CandidateSection(candidate)
                    local tabId = candidate.__tabName or (section and section.Tab and section.Tab.RegistryName)
                    return RegisterCandidate(candidate, tabId, section)
                end
            end
            return nil
        end
        function ui.find_elements(tab, container, query)
            local sectionFilter, tabFilter, kindFilter, nameFilter, flagFilter = nil, nil, nil, nil, nil
            if tab then
                tabFilter = ResolveTabId(tab)
            end
            if container then
                local ok, section = pcall(FindSectionObject, tab or tabFilter, container)
                if ok then
                    sectionFilter = section
                end
            end
            if type(query) == "string" then
                nameFilter = string.lower(query)
            elseif type(query) == "table" then
                kindFilter = query.kind and string.lower(tostring(query.kind)) or nil
                nameFilter = query.name and string.lower(tostring(query.name)) or nil
                flagFilter = query.flag
                if query.tab then
                    tabFilter = ResolveTabId(query.tab)
                end
            end
            local out = {}
            for _, candidate in ipairs(Library.ElementRegistry or {}) do
                if candidate.__removed then
                    continue
                end
                local candidateSection = CandidateSection(candidate)
                local candidateTab = candidate.__tabName or (candidateSection and candidateSection.Tab and candidateSection.Tab.RegistryName)
                if tabFilter and candidateTab ~= tabFilter then
                    continue
                end
                if sectionFilter and candidateSection ~= sectionFilter then
                    continue
                end
                if kindFilter and string.lower(tostring(candidate.__kind or "")) ~= kindFilter then
                    continue
                end
                if flagFilter and candidate.Flag ~= flagFilter then
                    continue
                end
                if nameFilter then
                    local candidateName = string.lower(CandidateName(candidate))
                    if not string.find(candidateName, nameFilter, 1, true) then
                        continue
                    end
                end
                table.insert(out, RegisterCandidate(candidate, candidateTab, candidateSection))
            end
            return out
        end
        function ui.list_elements(tab, container, kind)
            local handles = ui.find_elements(tab, container, kind and {kind = kind} or nil)
            local out = {}
            for _, handle in ipairs(handles) do
                table.insert(out, ui.describe(handle))
            end
            return out
        end
        function ui.describe(handle)
            local data = Get(handle)
            local object = data.object
            local info = {
                handle = handle,
                kind = data.kind,
                name = ui.name(handle),
                tab = data.extra and data.extra.tab or (type(object) == "table" and object.__tabName or nil),
                section = data.extra and data.extra.section or (type(object) == "table" and object.__sectionName or nil),
                flag = type(object) == "table" and object.Flag or nil,
                visible = ui.is_visible(handle),
                enabled = data.enabled == true,
                custom = type(object) == "table" and object.__luaCreated == true or false,
            }
            local ok, value = pcall(ui.get, handle)
            if ok then
                info.value = value
            end
            if data.kind == "slider" and type(object) == "table" then
                info.min, info.max, info.step, info.suffix = object.Min, object.Max, object.Intervals, object.Suffix
            elseif data.kind == "combobox" or data.kind == "multiselect" then
                info.options = ui.get_options(handle)
                info.multi = data.kind == "multiselect"
            elseif data.kind == "list" then
                info.count = ui.list_count(handle)
                info.selected = (ui.list_get_selected(handle))
            end
            return info
        end
        function ui.get_flag(flag)
            return Flags[flag]
        end
        function ui.set_flag(flag, value)
            local setter = ConfigFlags[flag]
            if setter then
                local ok = pcall(setter, value)
                return ok
            end
            Flags[flag] = value
            return true
        end
        ui.get_by_flag = ui.reference_by_flag

        ----------------------------------------------------------------
        -- Remove / clone / cleanup
        ----------------------------------------------------------------
        function ui.remove(handle)
            local data = Get(handle)
            if data.kind == "tab" then
                local ok, err = ui.remove_tab(handle)
                if ok then
                    Elements[handle] = nil
                end
                return ok, err
            end
            if data.kind == "section" then
                local ok, err = ui.remove_section(data.extra.tab, data.object.Name, true)
                if ok then
                    Elements[handle] = nil
                end
                return ok, err
            end
            local object = data.object
            if data.kind == "list" or data.kind == "info" or data.kind == "image" or data.kind == "progress" or data.kind == "spacer" then
                local root = ElementRoot(data)
                if root then
                    pcall(function()
                        root:Destroy()
                    end)
                end
            else
                if data.extra and data.extra.label then
                    DestroyObjectGui(data.extra.label)
                    RemoveFromLibraryRegistry(data.extra.label)
                end
                DestroyObjectGui(object)
                RemoveFromLibraryRegistry(object)
            end
            Elements[handle] = nil
            return true
        end
        function ui.clone(handle, tab, container, newName)
            local data = Get(handle)
            local object = data.object
            local kind = data.kind
            local section, tabId = ResolveSectionEx(tab, container)
            local name = newName or ((ui.name(handle) or kind) .. " copy")
            local element = nil
            if kind == "checkbox" then
                element = section:Toggle({Name = name, Flag = FlagPrefix(name), Default = ui.get(handle) == true})
            elseif kind == "slider" then
                element = section:Slider({
                    Name = name, Min = object.Min, Max = object.Max, Decimal = object.Intervals,
                    Suffix = object.Suffix, Default = ui.get(handle) or object.Min, Flag = FlagPrefix(name),
                    Formatter = object.Formatter,
                })
            elseif kind == "combobox" or kind == "multiselect" then
                element = section:Dropdown({
                    Name = name, Options = ui.get_options(handle), Multi = kind == "multiselect",
                    Default = ui.get(handle), Flag = FlagPrefix(name),
                })
            elseif kind == "button" then
                element = section:Button({Name = name, Callback = object.Callback or function() end})
            elseif kind == "label" then
                element = section:Label({Name = name})
            elseif kind == "textbox" then
                element = section:Textbox({Name = name, Flag = FlagPrefix(name), Default = ui.get(handle) or ""})
            else
                error("clone is not supported for kind '" .. tostring(kind) .. "'", 3)
            end
            element.__luaCreated = true
            local newHandle = Register(kind, element, {tab = tabId, section = section.Name, sectionObject = section, owned = true})
            if object.Callback and kind ~= "button" then
                element.Callback = object.Callback
            end
            return newHandle
        end
        function ui.cleanup(options)
            options = options or {}
            local removed = 0
            for index = #OwnedHandles, 1, -1 do
                local handle = OwnedHandles[index]
                if Elements[handle] then
                    if pcall(ui.remove, handle) then
                        removed += 1
                    end
                end
            end
            if options.sections then
                for index = #SessionSections, 1, -1 do
                    local record = SessionSections[index]
                    if pcall(ui.remove_section, record.tab, record.id, true) then
                        removed += 1
                    end
                end
            end
            if options.tabs then
                local ids = {}
                for id in pairs(SessionTabs) do
                    table.insert(ids, id)
                end
                for _, id in ipairs(ids) do
                    if pcall(ui.remove_tab, id) then
                        removed += 1
                    end
                end
            end
            return removed
        end
        function ui.list()
            local out = {}
            for tabName, sections in Library.Registry do
                local names = {}
                for sectionName in sections do
                    table.insert(names, sectionName)
                end
                table.sort(names)
                out[tabName] = names
            end
            return out
        end
        function ui.dump()
            for tabName, sections in ui.list() do
                Notifications:Create({Name = tabName .. ": " .. table.concat(sections, ", ")})
            end
        end
        function ui.capabilities()
            local names = {}
            for name, value in pairs(ui) do
                if type(value) == "function" then
                    table.insert(names, name)
                end
            end
            table.sort(names)
            return names
        end
        function ui.help()
            local text = "gamesense lua ui v" .. ui.version .. ": " .. table.concat(ui.capabilities(), ", ")
            Notifications:Create({Name = text})
            return text
        end
        api.ui = ui
        local entity = {}
        function entity.get_local_player()
            return lp
        end
        function entity.get_players(enemiesOnly)
            local out = {}
            for _, player in Players:GetPlayers() do
                if player == lp then
                    continue
                end
                if enemiesOnly and player.Team and lp.Team and player.Team == lp.Team then
                    continue
                end
                table.insert(out, player)
            end
            return out
        end
        function entity.get_all(className)
            local out = {}
            for _, object in workspace:GetDescendants() do
                if not className or object:IsA(className) then
                    table.insert(out, object)
                end
            end
            return out
        end
        function entity.get_prop(player, prop)
            local character = player and player.Character
            if not character then
                return nil
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local root = character:FindFirstChild("HumanoidRootPart")
            if prop == "health" then
                return humanoid and humanoid.Health
            elseif prop == "max_health" then
                return humanoid and humanoid.MaxHealth
            elseif prop == "origin" then
                return root and root.Position
            elseif prop == "velocity" then
                return root and root.AssemblyLinearVelocity
            elseif prop == "name" then
                return player.Name
            end
            return nil
        end
        function entity.hitbox_position(player, hitbox)
            local character = player and player.Character
            if not character then
                return nil
            end
            local part = character:FindFirstChild(hitbox or "Head")
            return part and part.Position
        end
        function entity.is_alive(player)
            local humanoid = player
                and player.Character
                and player.Character:FindFirstChildOfClass("Humanoid")
            return humanoid ~= nil and humanoid.Health > 0
        end
        function entity.is_enemy(player)
            if not (player and lp) then
                return false
            end
            if player.Team and lp.Team then
                return player.Team ~= lp.Team
            end
            return player ~= lp
        end
        function entity.get_distance(player)
            local root = player
                and player.Character
                and player.Character:FindFirstChild("HumanoidRootPart")
            if not root then
                return math.huge
            end
            return (Camera.CFrame.Position - root.Position).Magnitude
        end
        api.entity = entity
        local render = {}
        local RenderGui = Instance.new("ScreenGui")
        RenderGui.Name = "\0"
        RenderGui.IgnoreGuiInset = true
        RenderGui.ResetOnSpawn = false
        RenderGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        RenderGui.DisplayOrder = 100
        pcall(function()
            RenderGui.Parent = gethui and gethui() or CoreGui
        end)
        if not RenderGui.Parent then
            RenderGui.Parent = lp:WaitForChild("PlayerGui")
        end
        table.insert(session.instances, RenderGui)
        local drawPool = {}
        local drawIndex = 0
        table.insert(session.connections, RunService.Heartbeat:Connect(function()
            for index = 1, drawIndex do
                local item = drawPool[index]
                if item then
                    item.Visible = false
                end
            end
            drawIndex = 0
        end))
        local function AcquireFrame(class)
            drawIndex += 1
            local item = drawPool[drawIndex]
            if not item or not item:IsA(class) then
                if item then
                    item:Destroy()
                end
                item = Instance.new(class)
                item.BorderSizePixel = 0
                item.Parent = RenderGui
                drawPool[drawIndex] = item
            end
            item.Visible = true
            return item
        end
        function render.rect_filled(x, y, w, h, r, g, b, a)
            local frame = AcquireFrame("Frame")
            frame.AnchorPoint = vec2(0, 0)
            frame.Rotation = 0
            frame.ZIndex = 1
            frame.Position = dim2(0, x, 0, y)
            frame.Size = dim2(0, w, 0, h)
            frame.BackgroundColor3 = rgb(r or 255, g or 255, b or 255)
            frame.BackgroundTransparency = 1 - ((a or 255) / 255)
            return frame
        end
        function render.rect(x, y, w, h, r, g, b, a, thickness)
            thickness = thickness or 1
            render.rect_filled(x, y, w, thickness, r, g, b, a)
            render.rect_filled(x, y + h - thickness, w, thickness, r, g, b, a)
            render.rect_filled(x, y, thickness, h, r, g, b, a)
            render.rect_filled(x + w - thickness, y, thickness, h, r, g, b, a)
        end
        function render.line(x1, y1, x2, y2, r, g, b, a, thickness)
            local frame = AcquireFrame("Frame")
            local dx, dy = x2 - x1, y2 - y1
            local length = math.sqrt(dx * dx + dy * dy)
            frame.AnchorPoint = vec2(0, 0.5)
            frame.Position = dim2(0, x1, 0, y1)
            frame.Size = dim2(0, length, 0, thickness or 1)
            frame.Rotation = math.deg(math.atan2(dy, dx))
            frame.BackgroundColor3 = rgb(r or 255, g or 255, b or 255)
            frame.BackgroundTransparency = 1 - ((a or 255) / 255)
            return frame
        end
        function render.text(x, y, r, g, b, a, size, text, centered)
            local label = AcquireFrame("TextLabel")
            label.BackgroundTransparency = 1
            label.Position = dim2(0, x, 0, y)
            label.Size = dim2(0, 0, 0, 0)
            label.AutomaticSize = Enum.AutomaticSize.XY
            label.ZIndex = 10
            label.Font = Enum.Font.Code
            label.TextSize = size or 13
            label.Text = tostring(text)
            label.TextColor3 = rgb(r or 255, g or 255, b or 255)
            label.TextTransparency = 1 - ((a or 255) / 255)
            label.TextXAlignment = centered and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
            return label
        end
        function render.circle(x, y, radius, r, g, b, a)
            local frame = AcquireFrame("Frame")
            frame.AnchorPoint = vec2(0.5, 0.5)
            frame.Position = dim2(0, x, 0, y)
            frame.Size = dim2(0, radius * 2, 0, radius * 2)
            frame.BackgroundColor3 = rgb(r or 255, g or 255, b or 255)
            frame.BackgroundTransparency = 1 - ((a or 255) / 255)
            local corner = frame:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
            corner.CornerRadius = dim(1, 0)
            corner.Parent = frame
            return frame
        end
        function render.world_to_screen(position)
            local screen, visible = Camera:WorldToViewportPoint(position)
            if not visible then
                return nil
            end
            return screen.X, screen.Y
        end
        function render.screen_size()
            local size = Camera.ViewportSize
            return size.X, size.Y
        end
        api.render = render
        local protection = {}
        local hiddenNames = {}
        function protection.hide_instance(object)
            if typeof(object) ~= "Instance" then
                return false
            end
            local ok = pcall(function()
                object.Name = "\0"
                if gethui then
                    object.Parent = gethui()
                elseif syn and syn.protect_gui then
                    syn.protect_gui(object)
                end
            end)
            hiddenNames[object] = true
            return ok
        end
        function protection.safe_call(fn, ...)
            local args = table.pack(...)
            local ok, result = pcall(function()
                return fn(table.unpack(args, 1, args.n))
            end)
            return ok, result
        end
        function protection.humanize(value, spread)
            spread = spread or 0.05
            return value * (1 + (math.random() - 0.5) * 2 * spread)
        end
        function protection.random_delay(base, spread)
            local jitter = (math.random() - 0.5) * 2 * (spread or base * 0.3)
            task.wait(math.max(0, base + jitter))
        end
        function protection.is_hooked(fn)
            if not fn then
                return false
            end
            local ok, info = pcall(debug.info, fn, "s")
            if not ok then
                return true
            end
            return info ~= nil and tostring(info):find("C") == nil
        end
        function protection.clean_logs()
            pcall(function()
                if setclipboard then
                    setclipboard("")
                end
            end)
        end
        api.protection = protection
        function api.on(event, fn)
            event = string.lower(tostring(event))
            if event == "render" or event == "update" or event == "paint" then
                table.insert(session.render, fn)
            elseif event == "unload" or event == "shutdown" then
                table.insert(session.unload, fn)
            elseif event == "key" or event == "input" then
                table.insert(session.key, fn)
            end
        end
        api.set_event_callback = api.on
        function api.connect(signal, fn)
            local connection = signal:Connect(fn)
            table.insert(session.connections, connection)
            return connection
        end
        function api.track(object)
            table.insert(session.instances, object)
            return object
        end
        function api.bind(keyCode, fn)
            table.insert(session.binds, {Key = keyCode, Fn = fn})
        end
        function api.print(...)
            Notifications:Create({Name = Join(...)})
        end
        api.notify = api.print
        api.warn = api.print
        api.log = api.print
        table.insert(session.connections, RunService.RenderStepped:Connect(function(delta)
            for _, fn in session.render do
                local okRender, renderErr = pcall(fn, delta)
                if not okRender then
                    Notifications:Create({Name = "render error: " .. tostring(renderErr)})
                    session.render = {}
                    break
                end
            end
        end))
        table.insert(session.connections, InputService.InputBegan:Connect(function(input, processed)
            if processed then
                return
            end
            for _, bind in session.binds do
                if input.KeyCode == bind.Key then
                    pcall(bind.Fn)
                end
            end
            for _, fn in session.key do
                pcall(fn, input.KeyCode)
            end
        end))
        local ok, runtimeErr = pcall(func, api)
        if not ok then
            Notifications:Create({Name = "Runtime error: " .. tostring(runtimeErr)})
            UnloadScript()
            return false
        end
        Editor.Running = true
        return true
    end
    local function MakeEditorButton(text, order, callback)
        local outline = Library:Create("Frame", {
            Parent = EditorBody;
            Name = "\0";
            Size = dim2(0, 100, 0, 20);
            Position = dim2(0, 8 + (order - 1) * 108, 1, -28);
            BorderSizePixel = 0;
            BorderColor3 = rgb(0, 0, 0);
            BackgroundColor3 = themes.preset.outline;
        }); Library:Themify(outline, "outline", "BackgroundColor3")
        local inline = Library:Create("Frame", {
            Parent = outline;
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BorderColor3 = rgb(0, 0, 0);
            BackgroundColor3 = rgb(38, 38, 38);
        })
        local button = Library:Create("TextButton", {
            Parent = inline;
            Name = "\0";
            Text = text;
            AutoButtonColor = false;
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
            TextSize = 13;
            TextColor3 = themes.preset.text_color;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Size = dim2(1, 0, 1, 0);
            ZIndex = 2;
        })
        button.MouseEnter:Connect(function()
            inline.BackgroundColor3 = rgb(52, 52, 52)
        end)
        button.MouseLeave:Connect(function()
            inline.BackgroundColor3 = rgb(38, 38, 38)
        end)
        button.MouseButton1Click:Connect(function()
            task.spawn(callback)
        end)
        return button
    end
    local EditorLoadButton
    local MenuLoadButton
    local function SyncRunState()
        local label = Editor.Running and "Unload script" or "Load script"
        if EditorLoadButton then
            EditorLoadButton.Text = Editor.Running and "Unload" or "Load"
        end
        if MenuLoadButton then
            MenuLoadButton.Items.Name.Text = label
        end
    end
    -- Единое сохранение Lua-кода. Имя берётся от ОТКРЫТОГО в редакторе файла
    -- (Editor.Script), а не из поля имени: раньше после загрузки конфига или
    -- очистки поля Save писал код мимо открытого скрипта - файл появлялся,
    -- а код в нужном скрипте не сохранялся. Запись проверяем чтением обратно.
    local function SaveScript(silent)
        local name = Editor.Script or CleanName(Flags.LuaScriptName) or SelectedScript
        if not name then
            if not silent then
                Notifications:Create({Name = "Enter a script name"})
            end
            return false
        end
        local text = CodeBox.Text
        local ok = pcall(function()
            writefile(LuaPath(name), text)
        end)
        if ok then
            local backOk, back = pcall(readfile, LuaPath(name))
            ok = backOk and back == text
        end
        if not ok then
            if not silent then
                Notifications:Create({Name = "Failed to save"})
            end
            return false
        end
        SelectedScript = name
        Editor.Script = name
        Editor.Unsaved = false
        RefreshTitle()
        RefreshScriptList()
        if not silent then
            Notifications:Create({Name = "Saved script (" .. name .. ")"})
        end
        return true
    end
    local function ToggleRun()
        if Editor.Running then
            UnloadScript()
            SyncRunState()
            Notifications:Create({Name = "Script unloaded"})
            return
        end
        if Flags.LuaEnabled == false then
            Notifications:Create({Name = "Lua is disabled"})
            return
        end
        local scriptName = Editor.Script or CleanName(Flags.LuaScriptName) or SelectedScript
        -- Автосейв перед запуском: код из редактора всегда пишется на диск,
        -- иначе правки жили только до закрытия чита.
        if scriptName and CodeBox.Text:gsub("%s", "") ~= "" then
            SaveScript(true)
        end
        local source = CodeBox.Text
        if source:gsub("%s", "") == "" then
            local name = scriptName
            if not name or not isfile(LuaPath(name)) then
                Notifications:Create({Name = "Nothing to load"})
                return
            end
            source = readfile(LuaPath(name))
            if #source <= MAX_EDITOR_CHARS then
                CodeBox.Text = source
            else
                CodeBox.Text = string.format(
                    "-- %s.lua (%d KB)\n-- Файл слишком большой для редактора, запущен напрямую с диска.\n",
                    name, math.floor(#source / 1024)
                )
                Notifications:Create({Name = "File too large to edit - running from disk"})
            end
        end
        if RunScript(source) then
            if scriptName then
                Flags.LuaStartupScript = scriptName
            end
            SyncRunState()
            Notifications:Create({Name = "Script loaded"})
        end
    end
    ReloadActiveScript = function()
        if Flags.LuaEnabled == false then
            Notifications:Create({Name = "Lua is disabled"})
            return
        end
        local name = Editor.Script or SelectedScript or CleanName(Flags.LuaScriptName)
        if not name or not isfile(LuaPath(name)) then
            Notifications:Create({Name = "No script file to reload"})
            return
        end
        SaveScript(true)
        local ok, source = pcall(readfile, LuaPath(name))
        if not ok or not source then
            Notifications:Create({Name = "Failed to read script"})
            return
        end
        if RunScript(source) then
            Flags.LuaStartupScript = name
            SyncRunState()
            Notifications:Create({Name = "Reloaded script (" .. name .. ")"})
        end
    end
    MakeEditorButton("Save", 1, function()
        SaveScript(false)
    end)
    EditorLoadButton = MakeEditorButton("Load", 2, ToggleRun)
    EditorClose.MouseButton1Click:Connect(function()
        if Editor.Unsaved then
            SaveScript(true)
        end
        Editor.Open = false
        EditorOutline.Visible = false
    end)
    OpenScriptInEditor = function(name)
        local ok, source = pcall(readfile, LuaPath(name))
        source = ok and source or ""
        if #source > MAX_EDITOR_CHARS then
            Notifications:Create({Name = "File too large to open in editor"})
            source = string.format(
                "-- %s.lua (%d KB)\n-- Слишком большой файл, откройте его вне редактора.\n",
                name, math.floor(#source / 1024)
            )
        end
        CodeBox.Text = source
        Editor.Script = name
        Editor.Unsaved = false
        RefreshTitle()
        Editor.Open = true
        EditorOutline.Visible = true
    end
    MenuLoadButton = LuaSection:Button({
        Name = "Load script",
        Callback = ToggleRun
    })
    MenuLoadButton.Items.Button.LayoutOrder = 8
    local CreateScript = LuaSection:Button({
        Name = "Create",
        Callback = function()
            local name = CleanName(Flags.LuaScriptName)
            if not name then
                Notifications:Create({Name = "Enter a script name"})
                return
            end
            if isfile(LuaPath(name)) then
                Notifications:Create({Name = "Script \"" .. name .. "\" already exists"})
                return
            end
            CodeBox.Text = "-- " .. name .. "\n\nlocal api = ...\n\napi.print(\"hello from " .. name .. "\")\n"
            Editor.Script = name
            ScriptBox.Set(name)
            -- Файл создаётся на диске сразу, а не только после ручного Save.
            local created = pcall(function()
                writefile(LuaPath(name), CodeBox.Text)
            end)
            Editor.Unsaved = not created
            RefreshTitle()
            RefreshScriptList()
            Editor.Open = true
            EditorOutline.Visible = true
            Notifications:Create({Name = created and ("Created script (" .. name .. ")") or "New script (unsaved) - press Save"})
        end
    })
    CreateScript.Items.Button.LayoutOrder = 9
    local DeleteScript = LuaSection:Button({
        Name = "Delete",
        Callback = function()
            local name = CleanName(Flags.LuaScriptName) or SelectedScript
            if not name then
                Notifications:Create({Name = "Enter or select a script"})
                return
            end
            if not isfile(LuaPath(name)) then
                Notifications:Create({Name = "Script \"" .. name .. "\" doesn't exist"})
                return
            end
            local ok = pcall(function()
                delfile(LuaPath(name))
            end)
            if not ok then
                Notifications:Create({Name = "Failed to delete script"})
                return
            end
            if SelectedScript == name then
                SelectedScript = nil
            end
            ScriptBox.Set("")
            RefreshScriptList()
            Notifications:Create({Name = "Deleted script (" .. name .. ")"})
        end
    })
    DeleteScript.Items.Button.LayoutOrder = 10
    local OpenEditor = LuaSection:Button({
        Name = "Open lua editor",
        Callback = function()
            Editor.Open = not Editor.Open
            EditorOutline.Visible = Editor.Open
        end
    })
    OpenEditor.Items.Button.LayoutOrder = 11
    table.insert(Library.ExtraClosers, function()
        Editor.WasOpen = Editor.Open
        if Editor.Open then
            EditorOutline.Visible = false
        end
    end)
    table.insert(Library.OpenHooks, function()
        if Editor.WasOpen and Editor.Open then
            EditorOutline.Visible = true
        end
    end)
    local MENU_ORDER, EDITOR_ORDER = 500, 999
    local function FocusEditor()
        EditorScreen.DisplayOrder = EDITOR_ORDER
        if Library.Items then
            Library.Items.DisplayOrder = MENU_ORDER
        end
        Editor.Focused = true
    end
    local function FocusMenu()
        EditorScreen.DisplayOrder = MENU_ORDER - 1
        if Library.Items then
            Library.Items.DisplayOrder = MENU_ORDER
        end
        Editor.Focused = false
    end
    Editor.FocusEditor = FocusEditor
    Editor.FocusMenu = FocusMenu
    EditorBlocker.MouseButton1Down:Connect(FocusEditor)
    EditorBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            FocusEditor()
        end
    end)
    CodeBox.Focused:Connect(FocusEditor)
    Library:Connection(InputService.InputBegan, function(input, processed)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        if not (Library.Window and Library.Window.Visible) then
            return
        end
        if EditorOutline.Visible and Library:Hovering(EditorOutline) then
            return
        end
        if Library:Hovering(Library.Window) then
            FocusMenu()
        end
    end)
    FocusEditor()
    Library.UnloadHooks = Library.UnloadHooks or {}
    table.insert(Library.UnloadHooks, function()
        UnloadScript()
        pcall(function()
            EditorScreen:Destroy()
        end)
    end)
    SplitLines()
    RefreshGutter()
    RenderVisible(true)
    MeasureLineStep()
    SyncRunState()
    -- Load on startup: если тумблер включён, запускаем последний запущенный
    -- скрипт (его имя пишется в Flags.LuaStartupScript при каждом Load/Reload
    -- и сохраняется вместе с конфигом).
    task.defer(function()
        if Flags.LuaEnabled == false or Flags.LuaLoadOnStartup ~= true then
            return
        end
        local name = Flags.LuaStartupScript
        if type(name) ~= "string" or name == "" or not isfile(LuaPath(name)) then
            return
        end
        local ok, source = pcall(readfile, LuaPath(name))
        if not ok or not source or source:gsub("%s", "") == "" then
            return
        end
        SelectedScript = name
        Editor.Script = name
        if #source <= MAX_EDITOR_CHARS then
            CodeBox.Text = source
            Editor.Unsaved = false
            RefreshTitle()
        end
        if RunScript(source) then
            SyncRunState()
        end
    end)
end
local menuOpen = true
Library:Connection(RunService.RenderStepped, function()
    if menuOpen then
        InputService.MouseBehavior = Enum.MouseBehavior.Default
        InputService.MouseIconEnabled = true
    end
end)
local ContextActionService = game:GetService("ContextActionService")
local origToggle = Window.ToggleMenu
Window.ToggleMenu = function(bool)
    origToggle(bool)
    if bool then
        ContextActionService:BindCoreAction("BlockEscape", function()
            return Enum.ContextActionResult.Sink
        end, false, Enum.KeyCode.Escape)
    else
        ContextActionService:UnbindCoreAction("BlockEscape")
    end
end
ContextActionService:BindCoreAction("BlockEscape", function()
    return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.Escape)
Library.UnloadHooks = Library.UnloadHooks or {}
table.insert(Library.UnloadHooks, function()
    pcall(function()
        ContextActionService:UnbindCoreAction("BlockEscape")
    end)
end)
Library:Connection(InputService.InputBegan, function(input, ge)
    local key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
    if key ~= (Library.MenuKey or Enum.KeyCode.End) then
        return
    end
    if Library.MenuKeyJustBound then
        Library.MenuKeyJustBound = false
        return
    end
    menuOpen = not menuOpen
    Window.ToggleMenu(menuOpen)
end)

return Library
