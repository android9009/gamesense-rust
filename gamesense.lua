if getgenv().Loaded then
    if getgenv().Library and getgenv().Library.Unload then
        getgenv().Library:Unload()
    end
end
getgenv().Loaded = true
    local InputService, HttpService, GuiService, RunService, CoreGui, TweenService, Workspace, Players = game:GetService("UserInputService"), game:GetService("HttpService"), game:GetService("GuiService"), game:GetService("RunService"), game:GetService("CoreGui"), game:GetService("TweenService"), game:GetService("Workspace"), game:GetService("Players")
    local TextService = game:GetService("TextService")
    local Camera, lp, gui_offset = Workspace.CurrentCamera, Players.LocalPlayer, GuiService:GetGuiInset().Y
    local mouse = lp:GetMouse()
    local vec2, dim2, dim, dim_offset = Vector2.new, UDim2.new, UDim.new, UDim2.fromOffset
    local color, rgb, hex, hsv, rgbseq, rgbkey, numseq, numkey = Color3.new, Color3.fromRGB, Color3.fromHex, Color3.fromHSV, ColorSequence.new, ColorSequenceKeypoint.new, NumberSequence.new, NumberSequenceKeypoint.new
    getgenv().Library = {
        Directory = "gamesense",
        Folders = {
            "/fonts",
            "/configs",
        },
        Flags = {},
        ConfigFlags = {},
        Connections = {},
        Notifications = {Notifs = {}},
        OpenElement = {}; -- type: table or userdata
        EasingStyle = Enum.EasingStyle.Quint;
        TweeningSpeed = 0.25;
        AllDropdowns = {};
    }
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
            local ParentSize = dim2(0, 400, 0, 300) -- минимальный размер окна
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
                    InitialSize = Parent.Position
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
                            InitialSize.X.Offset + (Input.Position.X - InitialPosition.X),
                            0,
                            Horizontal - Parent.Size.X.Offset
                        ),
                        0,
                        math.clamp(
                            InitialSize.Y.Offset + (Input.Position.Y - InitialPosition.Y),
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
                Color = properties.Color or color(1, 1, 1), -- Default to white color if not provided
                Alpha = properties.Alpha or properties.Transparency or 0,
                Mode = properties.Mode or "Keypicker"; -- Animation
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
                Items.Colorpicker.ZIndex += 20000
                for _, descendant in Items.Colorpicker:GetDescendants() do
                    if descendant:IsA("GuiObject") then
                        descendant.ZIndex += 20000
                    end
                end
            end
            function Cfg.SetVisible(bool)
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
            return setmetatable(Cfg, Library)
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
                    Config[Idx] = {active = (Active == true), mode = Mode or "Toggle", key = tostring(Key or "NONE")}
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
            local Multiplier = 1 / (float or 1)
            return math.floor(num * Multiplier + 0.5) / Multiplier
        end
        function Library:Themify(instance, theme, property)
            table.insert(themes.utility[theme][property], instance)
        end
        function Library:SaveGradient(instance, theme) -- instance, tabfill or background, color
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
                    Items.Background = Library:Create( "Frame" , {
                        Parent = Items.Inline;
                        Name = "\0";
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
            do -- Other
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
            return setmetatable(Cfg, Library)
        end
        function Library:Slider(properties)
            local Cfg = {
                Name = properties.Name or nil,
                Suffix = properties.Suffix or "",
                Flag = properties.Flag or properties.Name or "Slider",
                Callback = properties.Callback or function() end,
                Min = properties.Min or 0,
                Max = properties.Max or 100,
                Intervals = properties.Decimal or 1,
                Value = properties.Default or 10,
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
            function Cfg.Set(value)
                Cfg.Value = math.clamp(Library:Round(value, Cfg.Intervals), Cfg.Min, Cfg.Max)
                Items.Accent.Size = dim2((Cfg.Value - Cfg.Min) / (Cfg.Max - Cfg.Min), Cfg.Value == Cfg.Min and 0 or -2, 1, -2)
                Items.Value.Text = Cfg.Formatter and Cfg.Formatter(Cfg.Value) or (tostring(Cfg.Value) .. Cfg.Suffix)
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
            return setmetatable(Cfg, Library)
        end
        function Library:Dropdown(properties)
            local Cfg = {
                Name = properties.Name or nil;
                Flag = properties.Flag or properties.Name or "Dropdown";
                Options = properties.Options or {""};
                Callback = properties.Callback or function() end;
                Multi = properties.Multi or false;
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
            Library:Connection(InputService.InputBegan, function(input, game_event)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if not Library:Hovering({Items.DropdownElements, Items.Dropdown}) then
                        Cfg.SetVisible(false)
                        Cfg.Open = false
                    end
                end
            end)
            Flags[Cfg.Flag] = {}
            ConfigFlags[Cfg.Flag] = Cfg.Set
            Cfg.RefreshOptions(Cfg.Options)
            Cfg.Set(Cfg.Default)
            table.insert(Library.AllDropdowns, Cfg)
            return setmetatable(Cfg, Library)
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
                Items.Name.Text = Text
            end
            return setmetatable(Cfg, Library)
        end
        function Library:Colorpicker(properties)
            local Cfg = {
                Name = properties.Name or "Color",
                Flag = properties.Flag or properties.Name or "Colorpicker",
                Callback = properties.Callback or function() end,
                Color = properties.Color or color(1, 1, 1), -- Default to white color if not provided
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
            return setmetatable(Cfg, Library)
        end
        function Library:Keybind(properties)
            local Cfg = {
                Flag = properties.Flag or properties.Name;
                Callback = properties.Callback or function() end;
                Name = properties.Name or nil;
                Key = properties.Key or nil;
                Mode = properties.Mode or "Toggle";
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
                    for _,mode in {"Always", "Toggle", "Hold"} do
                        Items[mode].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                        Items[mode].BackgroundTransparency = 0;
                        Items[mode].TextColor3 = rgb(205, 205, 205)
                        Items[mode].MouseButton1Click:Connect(function()
                            for _,extra in {"Always", "Toggle", "Hold"} do
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
                for _, mode in {"Always", "Toggle", "Hold"} do
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
                if not table.find({"Toggle", "Hold", "Always"}, mode) then
                    mode = "Toggle"
                end
                Cfg.Mode = mode
                if Cfg.Mode == "Always" then
                    Cfg.Active = true
                elseif Cfg.Mode == "Hold" then
                    Cfg.Active = false
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
                elseif table.find({"Toggle", "Hold", "Always"}, input) then
                    Cfg.SetMode(input)
                elseif type(input) == "table" then
                    local key = input.key ~= nil and input.key or input.Key
                    local mode = input.mode ~= nil and input.mode or input.Mode
                    local active = input.active ~= nil and input.active or input.Active
                    Cfg.Key = NormalizeKey(key)
                    Cfg.SetMode(mode or Cfg.Mode or "Toggle")
                    if active ~= nil then
                        Cfg.Active = active and true or false
                    end
                    if Cfg.Mode == "Always" then
                        Cfg.Active = true
                    elseif Cfg.Mode == "Hold" and active == nil then
                        Cfg.Active = false
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
                        if Cfg.Mode == "Toggle" then
                            Cfg.Set(not Cfg.Active)
                        elseif Cfg.Mode == "Hold" then
                            Cfg.Set(true)
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
                    if Cfg.Mode == "Hold" then
                        Cfg.Set(false)
                    end
                end
            end)
            Cfg.Set({mode = Cfg.Mode, active = Cfg.Active, key = Cfg.Key})
            ConfigFlags[Cfg.Flag] = Cfg.Set
            return setmetatable(Cfg, Library)
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
            return setmetatable(Cfg, Library)
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
    Aimbot:Dropdown({Name = "Target selection", Options = {"Players", "Team", "Bots"}, Multi = true, Default = {"Players"}, Flag = "AimbotTargetSel"})
    Aimbot:Dropdown({Name = "Target hitbox", Options = {"Head", "Neck", "Chest", "Stomach", "Legs", "Feet"}, Multi = true, Default = {"Head", "Chest"}, Flag = "AimbotHitbox"})
    Aimbot:Toggle({Name = "Visible check", Flag = "AimbotVisibleCheck"})
    Aimbot:Toggle({Name = "Auto fire", Flag = "AimbotAutoFire"})
    Aimbot:Toggle({Name = "Silent aim", Flag = "AimbotSilentAim"})
    local RiskyColor = rgb(182, 182, 101)
    local AirShot = Aimbot:Toggle({Name = "Air shot", Flag = "AimbotAirShot"})
    AirShot.Items.Title.TextColor3 = RiskyColor
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
    do
        local aimbotMode = "Toggle"
        local BindButton = Library:Create("TextButton", {
            Active = false;
            BorderColor3 = rgb(0, 0, 0);
            Text = "[NONE]";
            AutoButtonColor = false;
            Name = "\0";
            Parent = Toggle.Items.Components;
            Size = dim2(0, 17, 0, 9);
            Selectable = false;
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            BackgroundColor3 = rgb(12, 12, 12);
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
            TextColor3 = rgb(170, 170, 170);
            TextSize = 11;
            ZIndex = 2;
        })
        local aimbotKey = nil
        local isBinding = false
        local blockBindClick = false
        local blockBindClick2 = false
        local BindOverlay = Library:Create("TextButton", {
            Visible = false;
            Active = true;
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            AutoButtonColor = false;
            Name = "\0";
            Parent = Library.Items;
            Size = dim2(0, 17, 0, 9);
            Selectable = false;
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            ZIndex = 20;
        })
        local ModeFrame = Library:Create("Frame", {
            Parent = Library.Items;
            Visible = false;
            Size = dim2(0, 100, 0, 66);
            Name = "\0";
            Position = dim2(0, 0, 0, 100);
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            ZIndex = 10;
            BackgroundColor3 = rgb(12, 12, 12);
        })
        local ModeInline = Library:Create("Frame", {
            Parent = ModeFrame;
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            ZIndex = 10;
            BackgroundColor3 = rgb(35, 35, 35)
        })
        local function CreateModeOption(text)
            local btn = Library:Create("TextButton", {
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                TextColor3 = rgb(205, 205, 205);
                AutoButtonColor = false;
                BorderColor3 = rgb(0, 0, 0);
                Text = text;
                Parent = ModeInline;
                Size = dim2(1, 0, 0, 22);
                Name = "\0";
                TextXAlignment = Enum.TextXAlignment.Left;
                BorderSizePixel = 0;
                ZIndex = 10;
                TextSize = 13;
                BackgroundColor3 = rgb(26, 26, 26)
            })
            Library:Create("UIPadding", {
                PaddingTop = dim(0, 5);
                PaddingBottom = dim(0, 5);
                Parent = btn;
                PaddingRight = dim(0, 5);
                PaddingLeft = dim(0, 5)
            })
            Library:Create("UIListLayout", {
                Parent = ModeInline;
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            return btn
        end
        local ModeHold = CreateModeOption("Hold")
        local ModeToggle = CreateModeOption("Toggle")
        local ModeAlways = CreateModeOption("Always")
        local function UpdateModeVisuals()
            for _, btn in {ModeHold, ModeToggle, ModeAlways} do
                btn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                btn.TextColor3 = rgb(205, 205, 205)
                btn.BackgroundTransparency = 0
            end
            local selected = aimbotMode == "Hold" and ModeHold or aimbotMode == "Toggle" and ModeToggle or ModeAlways
            selected.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            selected.TextColor3 = rgb(142, 181, 39)
            selected.BackgroundTransparency = 1
        end
        ModeHold.MouseButton1Click:Connect(function()
            aimbotMode = "Hold"
            ModeFrame.Visible = false
            ModeFrame.Parent = Library.Other
        end)
        ModeToggle.MouseButton1Click:Connect(function()
            aimbotMode = "Toggle"
            ModeFrame.Visible = false
            ModeFrame.Parent = Library.Other
        end)
        ModeAlways.MouseButton1Click:Connect(function()
            aimbotMode = "Always"
            ModeFrame.Visible = false
            ModeFrame.Parent = Library.Other
        end)
        local function StartBinding()
            if isBinding then return end
            isBinding = true
            BindButton.Text = "..."
            ModeFrame.Visible = false
            ModeFrame.Parent = Library.Other
            BindOverlay.Visible = true
            BindOverlay.Size = dim2(0, BindButton.AbsoluteSize.X, 0, BindButton.AbsoluteSize.Y)
            BindOverlay.Position = dim2(0, BindButton.AbsolutePosition.X, 0, BindButton.AbsolutePosition.Y)
            local armed = false
            task.defer(function()
                armed = true
            end)
            local con
            con = Library:Connection(InputService.InputBegan, function(input2)
                if isBinding == false or not armed then return end
                local key = input2.KeyCode ~= Enum.KeyCode.Unknown and input2.KeyCode or input2.UserInputType
                if input2.UserInputType == Enum.UserInputType.MouseButton1 then
                    blockBindClick = true
                elseif input2.UserInputType == Enum.UserInputType.MouseButton2 then
                    blockBindClick2 = true
                end
                if key == Enum.KeyCode.Escape then
                    BindButton.Text = "[NONE]"
                    aimbotKey = nil
                    isBinding = false
                    BindOverlay.Visible = false
                    con:Disconnect()
                    return
                end
                if key then
                    aimbotKey = key
                    local text = Keys[key] or tostring(key):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
                    BindButton.Text = "[" .. text .. "]"
                end
                isBinding = false
                BindOverlay.Visible = false
                con:Disconnect()
            end)
        end
        BindButton.MouseButton1Click:Connect(function()
            if blockBindClick then
                blockBindClick = false
                return
            end
            if isBinding then return end
            StartBinding()
        end)
        BindButton.MouseButton2Click:Connect(function()
            if blockBindClick2 then
                blockBindClick2 = false
                return
            end
            if isBinding then return end
            ModeFrame.Visible = not ModeFrame.Visible
            if ModeFrame.Visible then
                ModeFrame.Parent = Library.Items
                ModeFrame.Position = dim2(0, BindButton.AbsolutePosition.X, 0, BindButton.AbsolutePosition.Y + 74)
                UpdateModeVisuals()
            else
                ModeFrame.Parent = Library.Other
            end
        end)
        Library:Connection(InputService.InputBegan, function(input, ge)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if ModeFrame.Visible and not Library:Hovering(ModeFrame) then
                    ModeFrame.Visible = false
                    ModeFrame.Parent = Library.Other
                end
            end
        end)
        table.insert(Library.ExtraClosers, function()
            ModeFrame.Visible = false
            ModeFrame.Parent = Library.Other
        end)
    end
    local Other = Tabs.Rage:Section({Name = "Other", Side = "Right", Size = 0.6})
    Other:Toggle({Name = "Visible FOV", Flag = "AimbotVisFOV"})
    Other:Slider({Name = "Maximum FOV", Min = 1, Max = 180, Suffix = "°", Default = 90, Flag = "AimbotFOV"})
    Other:Toggle({Name = "Lag compensation", Flag = "AimbotLagComp"})
    Other:Toggle({Name = "Backtrack", Flag = "AimbotBacktrack"})
    Other:Slider({Name = "Backtrack ms", Min = 0, Max = 1000, Suffix = "ms", Default = 200, Flag = "AimbotBacktrackMs"})
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
local AddMenuBind
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
    function AddMenuBind(TargetToggle, FlagName, NoToggleState)
        local bindMode = "Toggle"
        local bindActive
        if NoToggleState then
            bindActive = false
        else
            bindActive = TargetToggle.Enabled == true
        end
        local function ApplyState(state)
            bindActive = state == true
            if NoToggleState then
                if type(Flags[FlagName]) ~= "table" then
                    Flags[FlagName] = {Key = boundKey and tostring(boundKey) or "NONE", Mode = bindMode, Active = bindActive}
                else
                    Flags[FlagName].Active = bindActive
                    Flags[FlagName].Mode = bindMode
                end
                return
            end
            TargetToggle.Enabled = bindActive
            TargetToggle.Set(bindActive)
        end
        local boundKey = nil
        local binding = false
        local blockBindClick = false
        local blockBindClick2 = false
        local BindButton = Library:Create("TextButton", {
            Active = false;
            AutoButtonColor = false;
            Parent = TargetToggle.Items.Components;
            Name = "
