local LoadTick = os.clock()

-- [Feature: Multi-instance Safety] Keyed by creator + script title + game, so
-- reopening the SAME hub's script in the SAME game replaces its own previous
-- window, while a different hub's script (sharing this same library file)
-- is left completely alone.
getgenv().Adytum_Instances = getgenv().Adytum_Instances or { }

local Library do
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService")
    local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")

    gethui = gethui or function()
        return CoreGui
    end

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()

    local FromRGB = Color3.fromRGB
    local FromHSV = Color3.fromHSV
    local FromHex = Color3.fromHex

    local RGBSequence = ColorSequence.new
    local RGBSequenceKeypoint = ColorSequenceKeypoint.new
    local NumSequence = NumberSequence.new
    local NumSequenceKeypoint = NumberSequenceKeypoint.new

    local UDim2New = UDim2.new
    local UDimNew = UDim.new
    local Vector2New = Vector2.new

    local MathClamp = math.clamp
    local MathFloor = math.floor
    local MathAbs = math.abs
    local MathSin = math.sin

    local TableInsert = table.insert
    local TableFind = table.find
    local TableRemove = table.remove
    local TableConcat = table.concat
    local TableClone = table.clone
    local TableUnpack = table.unpack

    local StringFormat = string.format
    local StringFind = string.find
    local StringGSub = string.gsub
    local StringLower = string.lower
    local StringLen = string.len

    local InstanceNew = Instance.new

    local RectNew = Rect.new

    local IsMobile = UserInputService.TouchEnabled or false

    Library = {
        Theme =  { },

        MenuKeybind = tostring(Enum.KeyCode.RightControl), 
        Flags = { },

        Tween = {
            Time = 0.2,
            Style = Enum.EasingStyle.Quad,
            Direction = Enum.EasingDirection.Out
        },

        FadeSpeed = 0.2,

        Folders = {
            Directory = "Adytum_libraryfolder",
            Configs   = "Adytum_libraryfolder/Configs",
            Themes    = "Adytum_libraryfolder/Themes",
            Assets    = "Adytum_libraryfolder/Assets",
        },

        Images = {
            ["Saturation"] = {"Saturation.png", "https://github.com/sametexe001/images/blob/main/saturation.png?raw=true" },
            ["Value"] = { "Value.png", "https://github.com/sametexe001/images/blob/main/value.png?raw=true" },
            ["Hue"] = { "Hue.png", "https://github.com/sametexe001/images/blob/main/horizontalhue.png?raw=true" },
            ["Checkers"] = { "Checkers.png", "https://github.com/sametexe001/images/blob/main/checkers.png?raw=true" },
        },

        -- Ignore below
        Pages = { },
        Sections = { },

        Connections = { },
        Threads = { },

        ThemeMap = { },
        ThemeItems = { },

        CopiedColor = nil,

        OpenFrames = { },

        CurrentPage = nil,

        SearchItems = { },

        SetFlags = { },

        UnnamedConnections = 0,
        UnnamedFlags = 0,

        Holder = nil,
        NotifHolder = nil,
        UnusedHolder = nil,
        Font = nil,
        KeyList = nil,

        Colorpickers = { },

        -- [Feature: Advanced Theming] Set to true while batch-updating
        -- colorpicker UIs (RefreshThemeColorpickers) so the individual picker
        -- callbacks don't re-flip ActivePreset to "Custom" or retrigger
        -- SaveActiveTheme while a preset switch is already in progress.
        _SuppressThemeCallbacks = false,

        -- [Feature: Theme Presets] Registry of colour presets
        ThemePresets = { },
        ActivePreset  = "Default",
        AllowThemePresets = true,   -- dev sets false to hide preset picker from users

        -- [Feature: Config Export] Toggle export/import buttons in settings
        AllowConfigExport = true,   -- dev sets false to disable

        -- [Feature: Advanced Theming] Toggle the "Advanced Mode" switch in
        -- Theming that reveals theme export/import + a saved-themes list
        -- (mirrors the Configs subpage). Dev sets false to hide the switch
        -- and this whole feature from users entirely.
        AllowAdvancedTheming = true,   -- dev sets false to disable

        -- [Feature: Unknown Mode] Lets the user hide their real Roblox
        -- identity from the player profile box. AllowUnknownMode is the dev
        -- switch for the WHOLE feature (default true = users get the toggle
        -- in Settings). UnknownModeStyle picks WHAT happens when a user turns
        -- it on: "Placeholder" swaps the avatar/username/id for generic
        -- placeholders while keeping the box visible, "Hidden" removes the
        -- profile box entirely. Not overridable by the loading script.
        AllowUnknownMode = true,        -- dev sets false to disable the whole feature
        UnknownModeStyle = "Placeholder", -- "Placeholder" | "Hidden" -- dev picks the behavior

        -- [Feature: Corner Radius] Per-type corner radius values and registry
        CornerRadius = {
            Window  = 6,
            Boxes   = 3,
            Sliders = 0,
        },
        CornerRadiusDefaults = {
            Window  = 6,
            Boxes   = 3,
            Sliders = 0,
        },
        CornerItems = {
            Window  = { },
            Boxes   = { },
            Sliders = { },
        },

        -- [Feature: Title] Window title text and position
        TitleText     = "",
        TitlePosition = "Topbar",   -- "Topbar" | "Logo" | "None"

        -- [Feature: Credits] Entries shown in the Credits sub-page
        Credits = { },
    }

    Library.__index = Library
    Library.Sections.__index = Library.Sections
    Library.Pages.__index = Library.Pages

    local Keys = {
        ["Unknown"]           = "Unknown",
        ["Backspace"]         = "Back",
        ["Tab"]               = "Tab",
        ["Clear"]             = "Clear",
        ["Return"]            = "Return",
        ["Pause"]             = "Pause",
        ["Escape"]            = "Escape",
        ["Space"]             = "Space",
        ["QuotedDouble"]      = '"',
        ["Hash"]              = "#",
        ["Dollar"]            = "$",
        ["Percent"]           = "%",
        ["Ampersand"]         = "&",
        ["Quote"]             = "'",
        ["LeftParenthesis"]   = "(",
        ["RightParenthesis"]  = " )",
        ["Asterisk"]          = "*",
        ["Plus"]              = "+",
        ["Comma"]             = ",",
        ["Minus"]             = "-",
        ["Period"]            = ".",
        ["Slash"]             = "`",
        ["Three"]             = "3",
        ["Seven"]             = "7",
        ["Eight"]             = "8",
        ["Colon"]             = ":",
        ["Semicolon"]         = ";",
        ["LessThan"]          = "<",
        ["GreaterThan"]       = ">",
        ["Question"]          = "?",
        ["Equals"]            = "=",
        ["At"]                = "@",
        ["LeftBracket"]       = "LeftBracket",
        ["RightBracket"]      = "RightBracked",
        ["BackSlash"]         = "BackSlash",
        ["Caret"]             = "^",
        ["Underscore"]        = "_",
        ["Backquote"]         = "`",
        ["LeftCurly"]         = "{",
        ["Pipe"]              = "|",
        ["RightCurly"]        = "}",
        ["Tilde"]             = "~",
        ["Delete"]            = "Delete",
        ["End"]               = "End",
        ["KeypadZero"]        = "Keypad0",
        ["KeypadOne"]         = "Keypad1",
        ["KeypadTwo"]         = "Keypad2",
        ["KeypadThree"]       = "Keypad3",
        ["KeypadFour"]        = "Keypad4",
        ["KeypadFive"]        = "Keypad5",
        ["KeypadSix"]         = "Keypad6",
        ["KeypadSeven"]       = "Keypad7",
        ["KeypadEight"]       = "Keypad8",
        ["KeypadNine"]        = "Keypad9",
        ["KeypadPeriod"]      = "KeypadP",
        ["KeypadDivide"]      = "KeypadD",
        ["KeypadMultiply"]    = "KeypadM",
        ["KeypadMinus"]       = "KeypadM",
        ["KeypadPlus"]        = "KeypadP",
        ["KeypadEnter"]       = "KeypadE",
        ["KeypadEquals"]      = "KeypadE",
        ["Insert"]            = "Insert",
        ["Home"]              = "Home",
        ["PageUp"]            = "PageUp",
        ["PageDown"]          = "PageDown",
        ["RightShift"]        = "RightShift",
        ["LeftShift"]         = "LeftShift",
        ["RightControl"]      = "RightControl",
        ["LeftControl"]       = "LeftControl",
        ["LeftAlt"]           = "LeftAlt",
        ["RightAlt"]          = "RightAlt"
    }

    local Themes = {
		["Preset"] = {
			["Background"] = FromRGB(6, 12, 20),            -- Fondo principal: azul marino casi negro
			["Border"] = FromRGB(16, 28, 44),                -- Borde sutil azulado
			["Inline"] = FromRGB(12, 22, 36),                -- Separaciones entre elementos
			["Hovered Element"] = FromRGB(28, 58, 96),       -- Hover: azul océano vivo
			["Page Background"] = FromRGB(9, 17, 27),        -- Fondo de subpáginas
			["Outline"] = FromRGB(42, 78, 122),              -- Contorno acristalado
			["Element"] = FromRGB(14, 26, 42),               -- Bloques de interfaz
			["Gradient"] = FromRGB(22, 74, 130),             -- Degradado mar oscuro -> azul claro
			["Text"] = FromRGB(222, 236, 248),               -- Texto claro, casi blanco azulado
			["Text Stroke"] = FromRGB(0, 0, 0),
			["Placeholder Text"] = FromRGB(138, 160, 184),
			["Accent"] = FromRGB(58, 138, 224)               -- 🌊 Azul marino brillante (acento)
		},
		-- [Feature: Theme Presets] Built-in: Midnight (deep violet)
		["Midnight"] = {
			["Background"]      = FromRGB(8, 6, 18),
			["Border"]          = FromRGB(22, 18, 44),
			["Inline"]          = FromRGB(15, 12, 30),
			["Hovered Element"] = FromRGB(52, 38, 110),
			["Page Background"] = FromRGB(12, 9, 24),
			["Outline"]         = FromRGB(80, 58, 160),
			["Element"]         = FromRGB(18, 14, 38),
			["Gradient"]        = FromRGB(100, 60, 200),
			["Text"]            = FromRGB(230, 220, 255),
			["Text Stroke"]     = FromRGB(0, 0, 0),
			["Placeholder Text"]= FromRGB(160, 140, 200),
			["Accent"]          = FromRGB(130, 80, 255)
		},
		-- [Feature: Theme Presets] Built-in: Ember (warm orange)
		["Ember"] = {
			["Background"]      = FromRGB(18, 8, 6),
			["Border"]          = FromRGB(44, 20, 16),
			["Inline"]          = FromRGB(28, 12, 10),
			["Hovered Element"] = FromRGB(110, 45, 30),
			["Page Background"] = FromRGB(22, 10, 8),
			["Outline"]         = FromRGB(160, 70, 40),
			["Element"]         = FromRGB(35, 14, 12),
			["Gradient"]        = FromRGB(200, 80, 40),
			["Text"]            = FromRGB(255, 235, 220),
			["Text Stroke"]     = FromRGB(0, 0, 0),
			["Placeholder Text"]= FromRGB(200, 160, 140),
			["Accent"]          = FromRGB(255, 100, 50)
		},
    }

    Library.Theme = TableClone(Themes["Preset"])

    -- Register all built-in presets ("Preset" key is exposed as "Default" to users)
    Library.ThemePresets["Default"]  = TableClone(Themes["Preset"])
    Library.ThemePresets["Midnight"] = TableClone(Themes["Midnight"])
    Library.ThemePresets["Ember"]    = TableClone(Themes["Ember"])

    -- Folders
    for Index, Value in Library.Folders do 
        if not isfolder(Value) then
            makefolder(Value)
        end
    end

    -- [Feature: Theme Presets] Auto-saved preset choice. Selecting a preset in
    -- the dropdown persists it here immediately (no manual "save"/"create config"
    -- step needed) and it's restored automatically on the next load. When the
    -- user manually recolors anything instead of picking a registered preset,
    -- ActivePreset becomes the special name "Custom" and the actual colours
    -- (not just a name, since "Custom" isn't in ThemePresets) are persisted
    -- to ActiveThemeFile in real time via SaveActiveTheme.
    Library.ActivePresetFile = Library.Folders.Directory .. "/ActivePreset.txt"
    Library.ActiveThemeFile  = Library.Folders.Directory .. "/ActiveTheme.json"

    Library.SaveActivePreset = function(self, Name)
        pcall(writefile, self.ActivePresetFile, Name)
    end

    Library.SaveActiveTheme = function(self)
        pcall(writefile, self.ActiveThemeFile, self:GetThemeConfig())
    end

    if isfile(Library.ActivePresetFile) then
        local Ok, SavedName = pcall(readfile, Library.ActivePresetFile)
        if Ok and SavedName == "Custom" then
            local FileOk, JSON = pcall(readfile, Library.ActiveThemeFile)
            if FileOk then
                local DecodeOk, Decoded = pcall(HttpService.JSONDecode, HttpService, JSON)
                if DecodeOk and type(Decoded) == "table" then
                    for Key, HexValue in Decoded do
                        if type(HexValue) == "string" and Library.Theme[Key] then
                            local ColorOk, Color = pcall(FromHex, HexValue)
                            if ColorOk then
                                Library.Theme[Key] = Color
                            end
                        end
                    end
                    Library.ActivePreset = "Custom"
                end
            end
        elseif Ok and SavedName and Library.ThemePresets[SavedName] then
            Library.ActivePreset = SavedName
            Library.Theme = TableClone(Library.ThemePresets[SavedName])
        end
    end

    -- Images
    for Index, Value in Library.Images do 
        local ImageData = Value

        local ImageName = ImageData[1]
        local ImageLink = ImageData[2]
        
        if not isfile(Library.Folders.Assets .. "/" .. ImageName) then
            writefile(Library.Folders.Assets .. "/" .. ImageName, game:HttpGet(ImageLink))
        end
    end

    -- Tweening
    local Tween = { } do
        Tween.__index = Tween

        Tween.Create = function(self, Item, Info, Goal, IsRawItem)
            Item = IsRawItem and Item or Item.Instance
            Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)

            local NewTween = {
                Tween = TweenService:Create(Item, Info, Goal),
                Info = Info,
                Goal = Goal,
                Item = Item
            }

            NewTween.Tween:Play()

            setmetatable(NewTween, Tween)

            return NewTween
        end

        Tween.GetProperty = function(self, Item)
            Item = Item or self.Item 

            if Item:IsA("Frame") then
                return { "BackgroundTransparency" }
            elseif Item:IsA("TextLabel") or Item:IsA("TextButton") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif Item:IsA("ImageLabel") or Item:IsA("ImageButton") then
                return { "BackgroundTransparency", "ImageTransparency" }
            elseif Item:IsA("ScrollingFrame") then
                return { "BackgroundTransparency", "ScrollBarImageTransparency" }
            elseif Item:IsA("TextBox") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif Item:IsA("UIStroke") then 
                return { "Transparency" }
            end
        end

        Tween.FadeItem = function(self, Item, Property, Visibility, Speed)
            local Item = Item or self.Item 

            local OldTransparency = Item[Property]
            Item[Property] = Visibility and 1 or OldTransparency

            local NewTween = Tween:Create(Item, TweenInfo.new(Speed or Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction), {
                [Property] = Visibility and OldTransparency or 1
            }, true)

            Library:Connect(NewTween.Tween.Completed, function()
                if not Visibility then 
                    task.wait()
                    Item[Property] = OldTransparency
                end
            end)

            return NewTween
        end

        Tween.Get = function(self)
            if not self.Tween then 
                return
            end

            return self.Tween, self.Info, self.Goal
        end

        Tween.Pause = function(self)
            if not self.Tween then 
                return
            end

            self.Tween:Pause()
        end

        Tween.Play = function(self)
            if not self.Tween then 
                return
            end

            self.Tween:Play()
        end

        Tween.Clean = function(self)
            if not self.Tween then 
                return
            end

            Tween:Pause()
            self = nil
        end
    end

    -- Instances
    local Instances = { } do
        Instances.__index = Instances

        Instances.Create = function(self, Class, Properties)
            local NewItem = {
                Instance = InstanceNew(Class),
                Properties = Properties,
                Class = Class
            }

            setmetatable(NewItem, Instances)

            for Property, Value in NewItem.Properties do
                NewItem.Instance[Property] = Value
            end

            return NewItem
        end

        Instances.FadeItem = function(self, Visibility, Speed)
            local Item = self.Instance

            if Visibility == true then 
                Item.Visible = true
            end

            local Descendants = Item:GetDescendants()
            TableInsert(Descendants, Item)

            local NewTween

            for Index, Value in Descendants do 
                local TransparencyProperty = Tween:GetProperty(Value)

                if not TransparencyProperty then 
                    continue
                end

                if type(TransparencyProperty) == "table" then 
                    for _, Property in TransparencyProperty do 
                        NewTween = Tween:FadeItem(Value, Property, not Visibility, Speed)
                    end
                else
                    NewTween = Tween:FadeItem(Value, TransparencyProperty, not Visibility, Speed)
                end
            end
        end

        Instances.AddToTheme = function(self, Properties)
            if not self.Instance then 
                return
            end

            Library:AddToTheme(self, Properties)
        end

        Instances.ChangeItemTheme = function(self, Properties)
            if not self.Instance then 
                return
            end

            Library:ChangeItemTheme(self, Properties)
        end

        Instances.Connect = function(self, Event, Callback, Name)
            if not self.Instance then 
                return
            end

            if not self.Instance[Event] then 
                return
            end

            if IsMobile then
                if Event == "MouseButton1Down" or Event == "MouseButton1Click" then
                    Event = "TouchTap"
                elseif Event == "MouseButton2Down" or Event == "MouseButton2Click" then
                    Event = "TouchLongPress"
                end
            end

            return Library:Connect(self.Instance[Event], Callback, Name)
        end

        Instances.Tween = function(self, Info, Goal)
            if not self.Instance then 
                return
            end

            return Tween:Create(self, Info, Goal)
        end

        Instances.Disconnect = function(self, Name)
            if not self.Instance then 
                return
            end

            return Library:Disconnect(Name)
        end

        Instances.Clean = function(self)
            if not self.Instance then 
                return
            end

            self.Instance:Destroy()
            self = nil
        end

        Instances.MakeDraggable = function(self)
            if not self.Instance then 
                return
            end

            local Gui = self.Instance

            local Dragging = false 
            local DragStart
            local StartPosition 

            local Set = function(Input)
                local DragDelta = Input.Position - DragStart
                self:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(StartPosition.X.Scale, StartPosition.X.Offset + DragDelta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + DragDelta.Y)})
            end

            local InputChanged

            self:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true

                    DragStart = Input.Position
                    StartPosition = Gui.Position

                    if InputChanged then 
                        return
                    end

                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Dragging = false

                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
            end)

            -- Only subscribe to InputChanged while a drag is active to avoid firing on every mouse move globally
            local DragMoveConn
            self:Connect("InputBegan", function(Input)
                if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not DragMoveConn then
                    DragMoveConn = UserInputService.InputChanged:Connect(function(Inp)
                        if (Inp.UserInputType == Enum.UserInputType.MouseMovement or Inp.UserInputType == Enum.UserInputType.Touch) and Dragging then
                            Set(Inp)
                        end
                    end)
                end
            end)

            self:Connect("InputEnded", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if DragMoveConn then
                        DragMoveConn:Disconnect()
                        DragMoveConn = nil
                    end
                end
            end)

            return Dragging
        end

        Instances.MakeResizeable = function(self, Minimum, Maximum)
            if not self.Instance then 
                return
            end

            local Gui = self.Instance

            local Resizing = false 
            local Start = UDim2New()
            local Delta = UDim2New()
            local ResizeMax = Gui.Parent.AbsoluteSize - Gui.AbsoluteSize

            local ResizeButton = Instances:Create("ImageButton", {
				Parent = Gui,
                Image = "",
				AnchorPoint = Vector2New(1, 1),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = UDim2New(0, 14, 0, 14),
				Position = UDim2New(1, -3, 1, -3),
                Name = "\0",
				BorderSizePixel = 0,
				BackgroundTransparency = 0.35,
                BackgroundColor3 = FromRGB(255, 255, 255),
                ZIndex = 999,
				AutoButtonColor = false,
                Visible = true,
			})  ResizeButton:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UICorner", {
                Parent = ResizeButton.Instance,
                Name = "\0",
                CornerRadius = UDimNew(0, 3),
            })

            ResizeButton:OnHover(function()
                ResizeButton.Instance.BackgroundTransparency = 0.05
            end)
            ResizeButton:OnHoverLeave(function()
                ResizeButton.Instance.BackgroundTransparency = 0.35
            end)

            local InputChanged

            ResizeButton:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then

                    Resizing = true

                    Start = Gui.Size - UDim2New(0, Input.Position.X, 0, Input.Position.Y)

                    if InputChanged then 
                        return
                    end

                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Resizing = false

                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
            end)

            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Resizing then
                        ResizeMax = Maximum or Gui.Parent.AbsoluteSize - Gui.AbsoluteSize

                        Delta = Start + UDim2New(0, Input.Position.X, 0, Input.Position.Y)
                        Delta = UDim2New(0, math.clamp(Delta.X.Offset, Minimum.X, ResizeMax.X), 0, math.clamp(Delta.Y.Offset, Minimum.Y, ResizeMax.Y))

                        Tween:Create(Gui, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = Delta}, true)
                    end
                end
            end)

            return Resizing, ResizeButton
        end


        Instances.OnHover = function(self, Function)
            if not self.Instance then 
                return
            end
            
            return Library:Connect(self.Instance.MouseEnter, Function)
        end

        Instances.OnHoverLeave = function(self, Function)
            if not self.Instance then 
                return
            end
            
            return Library:Connect(self.Instance.MouseLeave, Function)
        end

        Instances.Border = function(self, Type)
            if not self.Instance then 
                return
            end

            local Color = Type == "Border" and Library.Theme.Border or Type == "Outline" and Library.Theme.Outline
        
            local UIStroke = Instances:Create("UIStroke", {
                Parent = self.Instance,
                Color = Color,
                Thickness = 1,
                LineJoinMode = Enum.LineJoinMode.Miter
            })  UIStroke:AddToTheme({Color = Type})

            return UIStroke
        end

        Instances.TextBorder = function(self)
            if not self.Instance then 
                return
            end

            local UIStroke = Instances:Create("UIStroke", {
                Parent = self.Instance,
                Color = Library.Theme["Text Stroke"],
                Thickness = 1,
                -- [Fix: Title Legibility] Was 0.6 (very faint), which let titles
                -- wash out against bright accent glows/light themes. A more
                -- opaque stroke keeps text readable regardless of what's behind it.
                Transparency = 0.25,
                LineJoinMode = Enum.LineJoinMode.Miter
            })  UIStroke:AddToTheme({Color = "Text Stroke"})

            return UIStroke
        end 
    end

    -- Custom font
    local CustomFont = { } do
        function CustomFont:New(Name, Weight, Style, Data)
            if isfile(Library.Folders.Assets .. "/" .. Name .. ".json") then
                return Font.new(getcustomasset(Library.Folders.Assets .. "/" .. Name .. ".json"))
            end

            if not isfile(Library.Folders.Assets .. "/" .. Name .. ".ttf") then 
                writefile(Library.Folders.Assets .. "/" .. Name .. ".ttf", game:HttpGet(Data.Url))
            end

            local FontData = {
                name = Name,
                faces = { {
                    name = "Regular",
                    weight = Weight,
                    style = Style,
                    assetId = getcustomasset(Library.Folders.Assets .. "/" .. Name .. ".ttf")
                } }
            }

            writefile(Library.Folders.Assets .. "/" .. Name .. ".json", HttpService:JSONEncode(FontData))
            return Font.new(getcustomasset(Library.Folders.Assets .. "/" .. Name .. ".json"))
        end

        function CustomFont:Get(Name)
            if isfile(Library.Folders.Assets .. "/" .. Name .. ".json") then
                return Font.new(getcustomasset(Library.Folders.Assets .. "/" .. Name .. ".json"))
            end
        end

        CustomFont:New("Monaco", 400, "Regular", {
            Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/Monaco.ttf"
        })

        Library.Font = CustomFont:Get("Monaco")
    end

    Library.Holder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 2,
        ResetOnSpawn = false
    })

    Library.UnusedHolder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Enabled = false,
        ResetOnSpawn = false
    })

    Library.NotifHolder = Instances:Create("Frame", {
        Parent = Library.Holder.Instance,
        Name = "\0",
        BackgroundTransparency = 1,
        Size = UDim2New(0, 0, 1, 0),
        BorderColor3 = FromRGB(0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = FromRGB(255, 255, 255)
    })

    Instances:Create("UIListLayout", {
        Parent = Library.NotifHolder.Instance,
        Name = "\0",
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDimNew(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Instances:Create("UIPadding", {
        Parent = Library.NotifHolder.Instance,
        Name = "\0",
        PaddingTop = UDimNew(0, 12),
        PaddingBottom = UDimNew(0, 12),
        PaddingRight = UDimNew(0, 12),
        PaddingLeft = UDimNew(0, 12)
    })

    Library.Unload = function(self)
        for Index, Value in self.Connections do 
            Value.Connection:Disconnect()
        end

        for Index, Value in self.Threads do 
            coroutine.close(Value)
        end

        if self.Holder then 
            self.Holder:Clean()
        end

        Library = nil 
        getgenv().Library = nil

        UserInputService.MouseIconEnabled = true
    end

    Library.GetImage = function(self, Image)
        local ImageData = self.Images[Image]

        if not ImageData then 
            return
        end

        return getcustomasset(self.Folders.Assets .. "/" .. ImageData[1])
    end

    Library.Round = function(self, Number, Float)
        local Multiplier = 1 / (Float or 1)
        return MathFloor(Number * Multiplier) / Multiplier
    end

    Library.Thread = function(self, Function)
        local NewThread = coroutine.create(Function)
        
        coroutine.wrap(function()
            coroutine.resume(NewThread)
        end)()

        TableInsert(self.Threads, NewThread)
        return NewThread
    end
    
    Library.SafeCall = function(self, Function, ...)
        local Arguements = { ... }
        local Success, Result = pcall(Function, TableUnpack(Arguements))

        if not Success then
            warn(Result)
            return false
        end

        return Success
    end

    Library.Connect = function(self, Event, Callback, Name)
        Name = Name or StringFormat("Connection%s%s", self.UnnamedConnections + 1, HttpService:GenerateGUID(false))

        local NewConnection = {
            Event = Event,
            Callback = Callback,
            Name = Name,
            Connection = nil
        }

        Library:Thread(function()
            NewConnection.Connection = Event:Connect(Callback)
        end)

        TableInsert(self.Connections, NewConnection)
        return NewConnection
    end

    Library.Disconnect = function(self, Name)
        for _, Connection in self.Connections do 
            if Connection.Name == Name then
                Connection.Connection:Disconnect()
                break
            end
        end
    end

    Library.NextFlag = function(self)
        local FlagNumber = self.UnnamedFlags + 1
        return StringFormat("flag_number_%s_%s", FlagNumber, HttpService:GenerateGUID(false))
    end

    Library.AddToTheme = function(self, Item, Properties)
        Item = Item.Instance or Item 

        local ThemeData = {
            Item = Item,
            Properties = Properties,
        }

        for Property, Value in ThemeData.Properties do
            if type(Value) == "string" then
                Item[Property] = self.Theme[Value]
            else
                Item[Property] = Value()
            end
        end

        TableInsert(self.ThemeItems, ThemeData)
        self.ThemeMap[Item] = ThemeData
    end

	Library.ToRich = function(self, Text, Color)
        if not Color then
            return `<font color="rgb(255, 255, 255)">{Text}</font>`
        end

        if not Color.R or not Color.G or not Color.B then
            return `<font color="rgb(255, 255, 255)">{Text}</font>`
        end

		return `<font color="rgb({MathFloor(Color.R * 255)}, {MathFloor(Color.G * 255)}, {MathFloor(Color.B * 255)})">{Text}</font>`
	end

    -- [Feature: Config Export] The Theming subpage registers a colorpicker
    -- flag per theme colour (e.g. "AccentTheme", "GradientTheme"), a
    -- "ThemePreset" dropdown flag, and derived animation flags built by
    -- appending onto that colorpicker flag (e.g. "BorderThemeAnimation
    -- Keyframe1", "AccentThemeAnimationSpeed") -- all in the same global
    -- Library.Flags table as every other feature flag (toggles/sliders/
    -- etc). All of these contain "Theme" somewhere in the name, which is
    -- theme state, not user-selected feature config, so they must be
    -- excluded here or Export/Import Config ends up dumping (and
    -- overwriting) the theme instead of the actual saved selections.
    Library.IsThemeFlag = function(self, Index)
        return type(Index) == "string" and StringFind(Index, "Theme") ~= nil
    end

    Library.GetConfig = function(self)
        local Config = { } 

        local Success, Result = Library:SafeCall(function()
            for Index, Value in Library.Flags do 
                if Library:IsThemeFlag(Index) then
                    continue
                end

                if type(Value) == "table" and Value.Key then
                    Config[Index] = {Key = tostring(Value.Key), Mode = Value.Mode}
                elseif type(Value) == "table" and Value.Color then
                    Config[Index] = {Color = "#" .. Value.Color, Alpha = Value.Alpha}
                else
                    Config[Index] = Value
                end
            end
        end)

        return HttpService:JSONEncode(Config)
    end

    Library.LoadConfig = function(self, Config)
        local Decoded = HttpService:JSONDecode(Config)

        local Success, Result = Library:SafeCall(function()
            for Index, Value in Decoded do 
                if Library:IsThemeFlag(Index) then
                    continue
                end

                local SetFunction = Library.SetFlags[Index]

                if not SetFunction then
                    continue
                end

                if type(Value) == "table" and Value.Key then 
                    SetFunction(Value)
                elseif type(Value) == "table" and Value.Color then
                    SetFunction(Value.Color, Value.Alpha)
                else
                    SetFunction(Value)
                end
            end
        end)

        return Success, Result
    end

    Library.DeleteConfig = function(self, Config)
        if isfile(Library.Folders.Configs .. "/" .. Config) then 
            delfile(Library.Folders.Configs .. "/" .. Config)
        end
    end

    -- [Feature: Theme Files] Themes subpage counterpart to DeleteConfig
    Library.DeleteTheme = function(self, ThemeFile)
        if isfile(Library.Folders.Themes .. "/" .. ThemeFile) then
            delfile(Library.Folders.Themes .. "/" .. ThemeFile)
        end
    end

    -- [Feature: Single Autoload] Marks Target as the "[AT] " autoload file
    -- inside Folder, stripping the "[AT] " prefix off every other file in
    -- that same folder first so there is never more than one autoload
    -- config/theme at a time. Returns the (possibly renamed) new filename.
    Library.SetAutoload = function(self, Folder, Target)
        for _, Path in ipairs(listfiles(Folder)) do
            local FileName = string.match(Path, "([^/\\]+)$")
            if FileName and FileName ~= Target and FileName:match("^%[AT%]") then
                local CleanName = FileName:gsub("^%[AT%]%s*", "")
                local OldPath = Folder .. "/" .. FileName
                local NewPath = Folder .. "/" .. CleanName
                if not isfile(NewPath) then
                    writefile(NewPath, readfile(OldPath))
                    pcall(function() delfile(OldPath) end)
                end
            end
        end

        local OldPath = Folder .. "/" .. Target
        if not isfile(OldPath) then
            return Target
        end

        local CleanName = Target:gsub("^%[AT%]%s*", "")
        local NewName = "[AT] " .. CleanName
        local NewPath = Folder .. "/" .. NewName

        if Target ~= NewName then
            writefile(NewPath, readfile(OldPath))
            pcall(function() delfile(OldPath) end)
        end

        return NewName
    end

    -- [Feature: Single Autoload] Strips the "[AT] " prefix off Target inside
    -- Folder, i.e. undoes SetAutoload without marking anything else as the
    -- new autoload. Returns the (possibly renamed) new filename.
    Library.RemoveAutoload = function(self, Folder, Target)
        local OldPath = Folder .. "/" .. Target
        if not isfile(OldPath) then
            return Target
        end

        if not Target:match("^%[AT%]") then
            return Target
        end

        local CleanName = Target:gsub("^%[AT%]%s*", "")
        local NewPath = Folder .. "/" .. CleanName

        writefile(NewPath, readfile(OldPath))
        pcall(function() delfile(OldPath) end)

        return CleanName
    end

    -- [Feature: Config Export/Import] Inline paste/copy box used by the
    -- "Export Config" / "Import Config" buttons in Settings -> Configs.
    -- Unlike a popup, this is built once as a normal child of the Configs
    -- section (Parent) and just shows/hides + swaps its own content, so
    -- there's no separate floating window/interface involved.
    Library.BuildInlineConfigBox = function(self, Parent)
        local Box = Instances:Create("Frame", {
            Parent = Parent,
            Name = "\0",
            Size = UDim2New(1, 0, 0, 210),
            BorderSizePixel = 2,
            BorderColor3 = FromRGB(12, 12, 12),
            BackgroundColor3 = FromRGB(6, 12, 20),
            Visible = false
        })  Box:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})
        Box:Border("Border")

        local BoxCorner = InstanceNew("UICorner")
        BoxCorner.Name = "\0"
        BoxCorner.CornerRadius = UDimNew(0, 4)
        BoxCorner.Parent = Box.Instance

        local TitleLabel = Instances:Create("TextLabel", {
            Parent = Box.Instance,
            Name = "\0",
            FontFace = Library.Font,
            Text = "",
            TextColor3 = FromRGB(222, 236, 248),
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2New(0, 10, 0, 8),
            Size = UDim2New(1, -40, 0, 16),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            TextSize = 13
        })  TitleLabel:AddToTheme({TextColor3 = "Text"})
        TitleLabel:TextBorder()

        local CloseButton = Instances:Create("TextButton", {
            Parent = Box.Instance,
            Name = "\0",
            FontFace = Library.Font,
            Text = "X",
            AutoButtonColor = false,
            TextColor3 = FromRGB(138, 160, 184),
            AnchorPoint = Vector2New(1, 0),
            Position = UDim2New(1, -6, 0, 6),
            Size = UDim2New(0, 20, 0, 20),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            TextSize = 13
        })  CloseButton:AddToTheme({TextColor3 = "Placeholder Text"})

        local InputBackground = Instances:Create("Frame", {
            Parent = Box.Instance,
            Name = "\0",
            Position = UDim2New(0, 10, 0, 30),
            Size = UDim2New(1, -20, 1, -76),
            BorderSizePixel = 2,
            BorderColor3 = FromRGB(12, 12, 12),
            BackgroundColor3 = FromRGB(12, 22, 36)
        })  InputBackground:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Outline"})

        local InputCorner = InstanceNew("UICorner")
        InputCorner.Name = "\0"
        InputCorner.CornerRadius = UDimNew(0, 4)
        InputCorner.Parent = InputBackground.Instance

        local InputBox = Instances:Create("TextBox", {
            Parent = InputBackground.Instance,
            Name = "\0",
            FontFace = Font.fromEnum(Enum.Font.Code), -- monospace: aligns JSON quotes/braces, easier to read
            Text = "",
            PlaceholderText = "",
            MultiLine = true,
            ClearTextOnFocus = false,
            TextEditable = false,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextColor3 = FromRGB(222, 236, 248),
            PlaceholderColor3 = FromRGB(138, 160, 184),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2New(0, 8, 0, 6),
            Size = UDim2New(1, -16, 1, -12),
            TextSize = 13
        })  InputBox:AddToTheme({TextColor3 = "Text"})

        local ActionButton = Instances:Create("TextButton", {
            Parent = Box.Instance,
            Name = "\0",
            FontFace = Library.Font,
            AutoButtonColor = false,
            Text = "Copy",
            TextColor3 = FromRGB(222, 236, 248),
            AnchorPoint = Vector2New(0, 1),
            Position = UDim2New(0, 10, 1, -8),
            Size = UDim2New(1, -20, 0, 28),
            BorderSizePixel = 2,
            BorderColor3 = FromRGB(12, 12, 12),
            BackgroundColor3 = FromRGB(58, 138, 224),
            TextSize = 12
        })  ActionButton:AddToTheme({BackgroundColor3 = "Accent", BorderColor3 = "Border"})

        local CurrentMode, CurrentCallback

        local function Hide()
            Box.Instance.Visible = false
        end

        CloseButton:Connect("MouseButton1Click", Hide)

        -- Interactive click feedback: swap label + flash colour so the user
        -- can see their click actually registered, then restore after a beat.
        local ActionBusy = false
        local function FlashAction(FeedbackText)
            if ActionBusy then return end
            ActionBusy = true

            local OriginalText = ActionButton.Instance.Text

            ActionButton.Instance.Text = FeedbackText
            ActionButton:ChangeItemTheme({BackgroundColor3 = "Element"})
            ActionButton:Tween(nil, {BackgroundColor3 = FromRGB(70, 180, 110)})

            task.delay(0.9, function()
                if ActionButton.Instance and ActionButton.Instance.Parent then
                    ActionButton.Instance.Text = OriginalText
                    ActionButton:ChangeItemTheme({BackgroundColor3 = "Accent"})
                    ActionButton:Tween(nil, {BackgroundColor3 = Library.Theme.Accent})
                end
                ActionBusy = false
            end)
        end

        ActionButton:Connect("MouseButton1Click", function()
            if CurrentMode == "Import" then
                FlashAction("Imported!")
                if CurrentCallback then
                    CurrentCallback(InputBox.Instance.Text)
                end
            else
                if setclipboard then
                    pcall(setclipboard, InputBox.Instance.Text)
                    FlashAction("Copied!")
                    Library:Notification("Success", "Config copied to clipboard", 3)
                else
                    Library:Notification("Error", "Your executor doesn't support setclipboard", 3)
                end
            end
        end)

        local BoxHandle = { Instance = Box }

        function BoxHandle:Show(Title, Mode, PresetText, Callback)
            CurrentMode = Mode
            CurrentCallback = Callback

            TitleLabel.Instance.Text = Title
            InputBox.Instance.Text = PresetText or ""
            InputBox.Instance.PlaceholderText = Mode == "Import" and "Paste your config here..." or ""
            InputBox.Instance.TextEditable = Mode == "Import"
            ActionButton.Instance.Text = Mode == "Import" and "Import" or "Copy"

            Box.Instance.Visible = true
        end

        function BoxHandle:Hide()
            Hide()
        end

        return BoxHandle
    end

    -- [Feature: Config Export/Import] Persistent export/import container.
    -- Unlike Library.BuildInlineConfigBox (a show/hide box that pops in and
    -- out like a dropdown), this is always visible and meant to be dropped
    -- straight into its own Section, so it sits in the Configs subpage the
    -- same permanent way the config list/buttons Section does.
    Library.BuildExportImportBox = function(self, Parent)
        local InputBackground = Instances:Create("Frame", {
            Parent = Parent,
            Name = "\0",
            Size = UDim2New(1, 0, 0, 140),
            BorderSizePixel = 2,
            BorderColor3 = FromRGB(12, 12, 12),
            BackgroundColor3 = FromRGB(12, 22, 36)
        })  InputBackground:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Outline"})
        InputBackground:Border("Border")

        local InputCorner = InstanceNew("UICorner")
        InputCorner.Name = "\0"
        InputCorner.CornerRadius = UDimNew(0, 4)
        InputCorner.Parent = InputBackground.Instance

        local InputBox = Instances:Create("TextBox", {
            Parent = InputBackground.Instance,
            Name = "\0",
            FontFace = Font.fromEnum(Enum.Font.Code), -- monospace: aligns JSON quotes/braces, easier to read
            Text = "",
            PlaceholderText = "Paste a config here to import, or press Export to fill this with your current config...",
            MultiLine = true,
            ClearTextOnFocus = false,
            TextEditable = true,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextColor3 = FromRGB(222, 236, 248),
            PlaceholderColor3 = FromRGB(138, 160, 184),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2New(0, 8, 0, 6),
            Size = UDim2New(1, -16, 1, -12),
            TextSize = 13
        })  InputBox:AddToTheme({TextColor3 = "Text"})

        local BoxHandle = { Instance = InputBackground }

        function BoxHandle:GetText()
            return InputBox.Instance.Text
        end

        function BoxHandle:SetText(Text)
            InputBox.Instance.Text = Text or ""
        end

        return BoxHandle
    end

    Library.RefreshFileList = function(self, Element, Folder)
        local CurrentList = { }
        local List = { }

        for Index, Value in ipairs(listfiles(Folder)) do
            local FileName = string.match(Value, "([^/\\]+)$")
            if FileName then
                List[Index] = FileName
            end
        end

        local IsNew = #List ~= CurrentList

        if not IsNew then
            for Index = 1, #List do
                if List[Index] ~= CurrentList[Index] then
                    IsNew = true
                    break
                end
            end
        else
            CurrentList = List
            Element:Refresh(CurrentList)
        end
    end

    Library.RefreshConfigsList = function(self, Element)
        Library:RefreshFileList(Element, Library.Folders.Configs)
    end

    -- [Feature: Advanced Theming] Themes subpage counterpart to RefreshConfigsList
    Library.RefreshThemesList = function(self, Element)
        Library:RefreshFileList(Element, Library.Folders.Themes)
    end

    Library.ChangeItemTheme = function(self, Item, Properties)
        Item = Item.Instance or Item

        if not self.ThemeMap[Item] then 
            return
        end

        self.ThemeMap[Item].Properties = Properties
        self.ThemeMap[Item] = self.ThemeMap[Item]
    end

    Library.ChangeTheme = function(self, Theme, Color)
        self.Theme[Theme] = Color

        for _, Item in self.ThemeItems do
            for Property, Value in Item.Properties do
                if type(Value) == "string" and Value == Theme then
                    Item.Item[Property] = Color
                elseif type(Value) == "function" then
                    Item.Item[Property] = Value()
                end
            end
        end
    end

    Library.IsMouseOverFrame = function(self, Frame, XOffset, YOffset)
        Frame = Frame.Instance
        XOffset = XOffset or 0 
        YOffset = YOffset or 0

        local MousePosition = Vector2New(Mouse.X + XOffset, Mouse.Y + YOffset)

        return MousePosition.X >= Frame.AbsolutePosition.X and MousePosition.X <= Frame.AbsolutePosition.X + Frame.AbsoluteSize.X 
        and MousePosition.Y >= Frame.AbsolutePosition.Y and MousePosition.Y <= Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y
    end

    Library.Lerp = function(self, Start, Finish, Time)
        return Start + (Finish - Start) * Time
    end

    -- [Feature: Corner Radius] Register a UICorner instance so SetCornerRadius updates it later
    Library.RegisterCorner = function(self, Corner, Type)
        if not self.CornerItems[Type] then
            self.CornerItems[Type] = { }
        end
        TableInsert(self.CornerItems[Type], Corner)
        -- Apply current radius immediately
        Corner.CornerRadius = UDimNew(0, self.CornerRadius[Type] or 0)
    end

    -- [Feature: Corner Radius] Update all registered corners of the given type
    Library.SetCornerRadius = function(self, Type, Value)
        local Min = (self.CornerRadiusDefaults and self.CornerRadiusDefaults[Type]) or 0
        Value = MathClamp(Value, Min, 32)
        self.CornerRadius[Type] = Value
        if self.CornerItems[Type] then
            for _, Corner in self.CornerItems[Type] do
                if Corner and Corner.Parent then
                    Corner.CornerRadius = UDimNew(0, Value)
                end
            end
        end
    end

    -- [Feature: Theme Presets] Register a developer-defined colour preset
    Library.RegisterThemePreset = function(self, Name, ColorTable)
        self.ThemePresets[Name] = TableClone(ColorTable)
    end

    -- [Feature: Theme Presets] Apply a registered preset by name
    Library.SetThemePreset = function(self, Name)
        local Preset = self.ThemePresets[Name]
        if not Preset then return end
        self.ActivePreset = Name
        for Key, Color in Preset do
            self:ChangeTheme(Key, Color)
        end
    end

    -- [Feature: Config Export] Serialise current theme colours to JSON.
    -- Pretty-printed (one "Key": "Value" pair per line, sorted alphabetically)
    -- so it's actually readable in the export box instead of one dense line.
    Library.GetThemeConfig = function(self)
        local Keys = { }
        for Key in self.Theme do
            TableInsert(Keys, Key)
        end
        table.sort(Keys)

        local Lines = { "{" }
        for Index, Key in ipairs(Keys) do
            local HexValue = "#" .. self.Theme[Key]:ToHex()
            local Comma = Index < #Keys and "," or ""
            TableInsert(Lines, string.format('    "%s": "%s"%s', Key, HexValue, Comma))
        end
        TableInsert(Lines, "}")

        return table.concat(Lines, "\n")
    end

    -- [Feature: Config Export] Load theme colours from a JSON string.
    -- Pass AutoSave = true to also persist the loaded colours as the active
    -- custom theme (used by the autoload path). Manual Load button should
    -- NOT pass AutoSave so it stays ephemeral.
    Library.LoadThemeConfig = function(self, JSON, AutoSave)
        local Ok, Decoded = pcall(HttpService.JSONDecode, HttpService, JSON)
        if not Ok or type(Decoded) ~= "table" then
            return false, "Invalid JSON"
        end
        for Key, HexValue in Decoded do
            if type(HexValue) == "string" and self.Theme[Key] then
                local ColorOk, Color = pcall(FromHex, HexValue)
                if ColorOk then
                    self:ChangeTheme(Key, Color)
                end
            end
        end
        -- Refresh colorpicker UIs so they show the newly loaded colours
        self:RefreshThemeColorpickers()
        if AutoSave then
            -- [Feature: Autoload] Autoloaded theme takes priority: persist it
            -- as the active custom theme so on the next launch the library
            -- restores it instead of whichever preset was previously saved.
            self.ActivePreset = "Custom"
            self:SaveActivePreset("Custom")
            self:SaveActiveTheme()
        end
        return true
    end

    -- [Feature: Advanced Theming] Push current Library.Theme colours into all
    -- registered theme-colorpicker UIs so they reflect an externally applied
    -- theme (preset switch or file load) without the user having to reopen
    -- the picker. Uses _SuppressThemeCallbacks so the individual picker
    -- callbacks don't re-flip ActivePreset to "Custom" while refreshing.
    Library.RefreshThemeColorpickers = function(self)
        self._SuppressThemeCallbacks = true
        for _, Picker in self.Colorpickers do
            local Flag = Picker.Flag
            if type(Flag) == "string" and Flag:match("Theme$") then
                local ColorName = Flag:gsub("Theme$", "")
                local Color = self.Theme[ColorName]
                if Color then
                    pcall(function() Picker:Set(Color, Picker.Alpha) end)
                end
            end
        end
        self._SuppressThemeCallbacks = false
    end

    -- [Feature: Folder Structure] Build per-hub per-game folder tree
    Library.BuildFolderPaths = function(self, Title, DevName)
        local function Sanitize(Str)
            return StringGSub(tostring(Str or "Unknown"), "[^%w%-_]", "_")
        end
        local GameName = Sanitize(game.Name)
        local GameId   = tostring(game.PlaceId)
        local Hub      = StringFormat("Ady...%s_by...%s", Sanitize(Title), Sanitize(DevName))
        local GameDir  = StringFormat("Ady...%s_ID%s", GameName, GameId)
        local Root     = "Adytum_libraryfolder"
        local HubPath  = Root .. "/" .. Hub
        local GamePath = HubPath .. "/" .. GameDir

        self.Folders = {
            Directory = Root,
            Hub       = HubPath,
            Game      = GamePath,
            Configs   = GamePath .. "/Configs",
            -- [Feature: Global Themes] Kept at the shared Root instead of the
            -- per-hub path so a theme saved (or set active) from one dev's
            -- script is immediately visible and usable from any other dev's
            -- script that loads this same Loader.lua, rather than being
            -- siloed per hub/game like Configs are.
            Themes    = Root .. "/Themes",
            Assets    = HubPath .. "/Assets",
        }

        local Paths = {
            Root,
            Root .. "/Themes",
            HubPath,
            HubPath .. "/Assets",
            GamePath,
            GamePath .. "/Configs",
        }
        for _, Path in Paths do
            if not isfolder(Path) then
                makefolder(Path)
            end
        end

        -- Re-copy assets to the hub Assets folder if not already there
        for _, ImageData in self.Images do
            local ImageName = tostring(ImageData[1])
            local DestPath  = self.Folders.Assets .. "/" .. ImageName
            if not isfile(DestPath) then
                pcall(function()
                    writefile(DestPath, game:HttpGet(ImageData[2]))
                end)
            end
        end
    end

    -- Components
    local Components = { } do
        Components.Window = function(self, Data)
            local Items = { } do
                Items["Window"] = Instances:Create("Frame", {
                    Parent = Data.Parent.Instance,
                    Name = "\0",
                    AnchorPoint = Data.AnchorPoint,
                    Position = Data.Position,
                    BorderColor3 = FromRGB(12, 12, 12),
                    Size = Data.Size,
                    BorderSizePixel = 2,
                    ClipsDescendants = true,
                    BackgroundTransparency = 0.12,
                    BackgroundColor3 = FromRGB(6, 12, 20)
                })  Items["Window"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

                -- Degradado de mar oscuro (glassmorphism) por defecto
                Instances:Create("UIGradient", {
                    Parent = Items["Window"].Instance,
                    Name = "\0",
                    Color = RGBSequence({
                        RGBSequenceKeypoint(0, FromRGB(4, 8, 14)),
                        RGBSequenceKeypoint(0.5, FromRGB(10, 28, 48)),
                        RGBSequenceKeypoint(1, FromRGB(22, 74, 130))
                    }),
                    Rotation = 90
                })

                if Data.Draggable then 
                    Items["Window"]:MakeDraggable()
                end

                if Data.Resizeable then 
                    local Minimum = Data.MinSize or Vector2New(Data.Size.X.Offset, Data.Size.Y.Offset)
                    local Maximum = Data.MaxSize or Vector2New(9999, 9999)

                    local _, ResizeHandle = Items["Window"]:MakeResizeable(Minimum, Maximum)
                    Items["ResizeButton"] = ResizeHandle
                end

                Items["UIStroke"] = Items["Window"]:Border("Outline")

                -- [Feature: Corner Radius] Main window UICorner
                local WinCorner = InstanceNew("UICorner")
                WinCorner.Name = "\0"
                WinCorner.Parent = Items["Window"].Instance
                Library:RegisterCorner(WinCorner, "Window")
            end

            return Items
        end

        Components.AutosizingLabel = function(self, Data)
            local Label = { } 

            local Items = { } do
                Items["Label"] = Instances:Create("TextLabel", {
                    Parent = Data.Parent.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Data.Text,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Label"]:AddToTheme({TextColor3 = "Text"})

                Items["UIStroke"] = Items["Label"]:TextBorder()
            end

            function Label:SetProperty(Property, Value)
                Items["Label"].Instance[Property] = Value
            end

            return Label, Items
        end

        Components.WindowPage = function(self, Data)
            local Page = {
                Active = false,
                SubPages = { },
                Items = { },
                Window = Data.Window,
                ColumnsData = { }
            }

            local Items = { } do
                Items["Inactive"] = Instances:Create("TextButton", {
                    Parent = Data.Parent.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(12, 12, 12),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 0.6000000238418579,
                    Size = UDim2New(1, 0, 0, 25),
                    BorderSizePixel = 2,
                    TextSize = 14,
                    -- [Feature: Settings Always Last] LayoutOrder drives the
                    -- side button's position in the tab list (see
                    -- Library.Page below); the Settings tab is always given
                    -- the max int32 order so it sorts after every other page
                    -- no matter what order pages are created/deferred in.
                    LayoutOrder = Data.LayoutOrder or 0,
                    BackgroundColor3 = FromRGB(25, 30, 26)
                })  Items["Inactive"]:AddToTheme({BackgroundColor3 = "Page Background", BorderColor3 = "Border"})

                Items["ButtonBorder"] = Instances:Create("UIStroke", {
                    Parent = Items["Inactive"].Instance,
                    Name = "\0",
                    Color = FromRGB(61, 60, 65),
                    Transparency = 0.6,
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                })  Items["ButtonBorder"]:AddToTheme({Color = "Outline"})

                Items["Liner"] = Instances:Create("Frame", {
                    Parent = Items["Inactive"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 1, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(25, 30, 26)
                })  Items["Liner"]:AddToTheme({BackgroundColor3 = "Accent"})

                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Inactive"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Data.Name,
                    AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 8, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 9,
                    -- [Fix: Title Legibility] The Glow frame below is created
                    -- AFTER this label, so without an explicit ZIndex it was
                    -- rendering ON TOP of the tab title, washing it out/hiding
                    -- it. ZIndex forces the text back above the glow.
                    ZIndex = 2,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

                Items["TextStroke"] = Items["Text"]:TextBorder()

                Items["Glow"] = Instances:Create("Frame", {
                    Parent = Items["Inactive"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 20, 1, 0),
                    BorderSizePixel = 0,
                    ZIndex = 1,
                    BackgroundColor3 = FromRGB(25, 30, 26)
                })  Items["Glow"]:AddToTheme({BackgroundColor3 = "Accent"})

                Items["GlowGradient"] = Instances:Create("UIGradient", {
                    Parent = Items["Glow"].Instance,
                    Name = "\0",
                    -- [Fix: Title Legibility] Floor raised from 0 to 0.35 so the glow never goes fully opaque under a title/label
                    Transparency = NumSequence{NumSequenceKeypoint(0, 0.35), NumSequenceKeypoint(0.193, 0.8687499761581421), NumSequenceKeypoint(0.504, 0.96875), NumSequenceKeypoint(1, 1)}
                })

                Items["Page"] = Instances:Create("Frame", {
                    Parent = Data.ContentHolder.Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Visible = false,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0),
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                if Data.SubPages then
                    -- SubPagesMode controls how the subpages bar is sized:
                    --   "Auto" (default) - the bar grows horizontally to fit its
                    --     buttons, up to the full width of the page, at which
                    --     point it stops growing and becomes horizontally
                    --     scrollable instead. Height never changes.
                    --   "Full" - the bar is always fully expanded (full page
                    --     width), the previous/legacy behavior.
                    local SubPagesMode = Data.SubPagesMode or "Auto"

                    Items["SubPages"] = Instances:Create("ScrollingFrame", {
                        Parent = Items["Page"].Instance,
                        Name = "\0",
                        Size = SubPagesMode == "Full" and UDim2New(1, 0, 0, 35) or UDim2New(0, 0, 0, 35),
                        BorderColor3 = FromRGB(42, 49, 45),
                        BorderSizePixel = 2,
                        AutomaticCanvasSize = Enum.AutomaticSize.X,
                        CanvasSize = UDim2New(0, 0, 0, 0),
                        ScrollingDirection = Enum.ScrollingDirection.X,
                        ScrollBarThickness = 0,
                        ScrollBarImageColor3 = FromRGB(58, 138, 224),
                        BackgroundColor3 = FromRGB(20, 24, 21)
                    })  Items["SubPages"]:AddToTheme({BackgroundColor3 = "Page Background", BorderColor3 = "Outline", ScrollBarImageColor3 = "Accent"})

                    Items["SubPages"]:Border("Border")

                    Instances:Create("UIPadding", {
                        Parent = Items["SubPages"].Instance,
                        Name = "\0",
                        PaddingRight = UDimNew(0, 7),
                        PaddingLeft = UDimNew(0, 7)
                    })

                    local SubPagesListLayout = Instances:Create("UIListLayout", {
                        Parent = Items["SubPages"].Instance,
                        Name = "\0",
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDimNew(0, 12),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    if SubPagesMode == "Auto" then
                        -- Only the horizontal size is ever driven automatically
                        -- here; the bar's height always stays fixed at 35.
                        --
                        -- We measure content width off the UIListLayout's own
                        -- AbsoluteContentSize rather than the ScrollingFrame's
                        -- CanvasSize/AutomaticCanvasSize. The latter is computed
                        -- from the former on a later step, so listening to
                        -- CanvasSize instead can end up one layout pass further
                        -- behind (and in some cases never catch up before the
                        -- rest of the script has already added every subpage).
                        local function UpdateSubPagesBarWidth()
                            local MaxWidth = Items["Page"].Instance.AbsoluteSize.X
                            local ContentWidth = SubPagesListLayout.Instance.AbsoluteContentSize.X + 14 -- + left/right UIPadding

                            -- The page frame can briefly report an AbsoluteSize of 0
                            -- before the engine finishes its first layout pass (or in
                            -- some executor environments). Falling back to the raw
                            -- content width in that case avoids the bar collapsing to
                            -- an invisible 0px sliver instead of just being uncapped
                            -- for a moment until a real MaxWidth comes through.
                            local TargetWidth = (MaxWidth > 0) and math.min(ContentWidth, MaxWidth) or ContentWidth

                            Items["SubPages"].Instance.Size = UDim2New(0, TargetWidth, 0, 35)
                        end

                        -- Exposed so WindowSubPage can force a recompute right after
                        -- each subpage button is added, instead of relying only on
                        -- change signals (which can lag a frame behind, or in rare
                        -- cases not fire before the rest of the calling script has
                        -- already finished adding subpages).
                        Items["UpdateSubPagesBarWidth"] = UpdateSubPagesBarWidth

                        Library:Connect(SubPagesListLayout.Instance:GetPropertyChangedSignal("AbsoluteContentSize"), UpdateSubPagesBarWidth)
                        Library:Connect(Items["Page"].Instance:GetPropertyChangedSignal("AbsoluteSize"), UpdateSubPagesBarWidth)

                        UpdateSubPagesBarWidth()
                    end

                    Items["Columns"] = Instances:Create("Frame", {
                        Parent = Items["Page"].Instance,
                        Name = "\0",
                        BackgroundTransparency = 1,
                        Position = UDim2New(0, 0, 0, 51),
                        BorderColor3 = FromRGB(42, 49, 45),
                        Size = UDim2New(1, 0, 1, -51),
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })
                else
                    Instances:Create("UIListLayout", {
                        Parent = Items["Page"].Instance,
                        Name = "\0",
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalFlex = Enum.UIFlexAlignment.Fill,
                        Padding = UDimNew(0, 14),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    for Index = 1, Data.Columns do 
                        local NewColumn = Instances:Create("ScrollingFrame", {
                            Parent = Items["Page"].Instance,
                            Name = "\0",
                            ScrollBarImageColor3 = FromRGB(0, 0, 0),
                            Active = true,
                            AutomaticCanvasSize = Enum.AutomaticSize.Y,
                            ScrollBarThickness = 0,
                            BackgroundTransparency = 1,
                            Size = UDim2New(1, 0, 1, 0),
                            BackgroundColor3 = FromRGB(255, 255, 255),
                            BorderColor3 = FromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            CanvasSize = UDim2New(0, 0, 0, 0)
                        })

                        Instances:Create("UIPadding", {
                            Parent = NewColumn.Instance,
                            Name = "\0",
                            PaddingTop = UDimNew(0, 2),
                            PaddingBottom = UDimNew(0, 2),
                            PaddingRight = UDimNew(0, 2),
                            PaddingLeft = UDimNew(0, 2)
                        })

                        Instances:Create("UIListLayout", {
                            Parent = NewColumn.Instance,
                            Name = "\0",
                            Padding = UDimNew(0, 14),
                            SortOrder = Enum.SortOrder.LayoutOrder
                        })

                        Page.ColumnsData[Index] = NewColumn
                    end
                end

                Page.Items = Items
            end

            local Debounce = false

            function Page:Turn(Bool)
                if Debounce then 
                    return 
                end

                Page.Active = Bool 
                
                Debounce = true
                Items["Page"].Instance.Visible = Bool 
                Items["Page"].Instance.Parent = Bool and Data.ContentHolder.Instance or Library.UnusedHolder.Instance

                if Page.Active then
                    Items["Inactive"]:Tween(nil, {BackgroundTransparency = 0})
                    Items["ButtonBorder"]:Tween(nil, {Transparency = 0})
                    Items["Glow"]:Tween(nil, {BackgroundTransparency = 0})
                    Items["Liner"]:Tween(nil, {BackgroundTransparency = 0})
                    Items["Text"]:Tween(nil, {Position = UDim2New(0, 13, 0.5, 0)})

                    Library.CurrentPage = Page
                else
                    Items["Inactive"]:Tween(nil, {BackgroundTransparency = 0.6})
                    Items["ButtonBorder"]:Tween(nil, {Transparency = 0.6})
                    Items["Glow"]:Tween(nil, {BackgroundTransparency = 1})
                    Items["Liner"]:Tween(nil, {BackgroundTransparency = 1})
                    Items["Text"]:Tween(nil, {Position = UDim2New(0, 8, 0.5, 0)})
                end

                local AllInstances = Items["Page"].Instance:GetDescendants()
                TableInsert(AllInstances, Items["Page"].Instance)
                
                local NewTween 

                for Index, Value in AllInstances do 
                    local TransparencyProperty = Tween:GetProperty(Value)

                    if not TransparencyProperty then 
                        continue
                    end

                    if type(TransparencyProperty) == "table" then 
                        for _, Property in TransparencyProperty do 
                            NewTween = Tween:FadeItem(Value, Property, Bool, Data.Window.FadeTime)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Data.Window.FadeTime)
                    end
                end

                if NewTween then
                    Library:Connect(NewTween.Tween.Completed, function()
                        Debounce = false
                    end)
                else
                    Debounce = false
                    Library:Notification("Warning", "Skipped a page transition animation (no tweenable elements found).", 3)
                end
            end

            Items["Inactive"]:Connect("MouseButton1Down", function()
                for Index, Value in Data.Window.Pages do 
                    if Value == Page and Page.Active then
                        return
                    end

                    Value:Turn(Value == Page)
                end
            end)

            Items["Inactive"]:OnHover(function()
                Items["Inactive"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element", BorderColor3 = "Border"})
                Items["Inactive"]:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
            end)

            Items["Inactive"]:OnHoverLeave(function()
                Items["Inactive"]:ChangeItemTheme({BackgroundColor3 = "Page Background", BorderColor3 = "Border"})
                Items["Inactive"]:Tween(nil, {BackgroundColor3 = Library.Theme["Page Background"]})
            end)

            if #Data.Window.Pages == 0 then 
                Page:Turn(true)
            end

            TableInsert(Data.Window.Pages, Page)
            return Page, Items 
        end

        Components.WindowSubPage = function(self, Data)
            local SubPage = {
                Active = false,
                ColumnsData = { }
            }

            local Items = { } do
                Items["Inactive"] = Instances:Create("TextButton", {
                    Parent = Data.Page.Items["SubPages"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(12, 12, 12),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 0, 0, 20),
                    BorderSizePixel = 2,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(25, 30, 26)
                })  Items["Inactive"]:AddToTheme({BackgroundColor3 = "Page Background", BorderColor3 = "Border"})

                Items["ButtonBorder"] = Instances:Create("UIStroke", {
                    Parent = Items["Inactive"].Instance,
                    Name = "\0",
                    Color = FromRGB(61, 60, 65),
                    Transparency = 1,
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                })  Items["ButtonBorder"]:AddToTheme({Color = "Outline"})

                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Inactive"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Data.Name,
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, -5, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 9,
                    -- [Fix: Title Legibility] See main tab fix above; same
                    -- Glow-created-after-Text ordering issue applies here.
                    ZIndex = 2,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

                Items["TextStroke"] = Items["Text"]:TextBorder()

                Instances:Create("UIPadding", {
                    Parent = Items["Text"].Instance,
                    Name = "\0",
                    PaddingRight = UDimNew(0, 8),
                    PaddingLeft = UDimNew(0, 8)
                })

                Instances:Create("UIPadding", {
                    Parent = Items["Inactive"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 2),
                    PaddingLeft = UDimNew(0, 18),
                    PaddingRight = UDimNew(0, 12)
                })

                Items["Glow"] = Instances:Create("Frame", {
                    Parent = Items["Inactive"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, -18, 0, -2),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 20, 1, 2),
                    BorderSizePixel = 0,
                    ZIndex = 1,
                    BackgroundColor3 = FromRGB(202, 243, 255)
                })  Items["Glow"]:AddToTheme({BackgroundColor3 = "Accent"})

                Instances:Create("UIGradient", {
                    Parent = Items["Glow"].Instance,
                    Name = "\0",
                    -- [Fix: Title Legibility] Floor raised from 0 to 0.35 so the glow never goes fully opaque under a title/label
                    Transparency = NumSequence{NumSequenceKeypoint(0, 0.35), NumSequenceKeypoint(0.193, 0.8687499761581421), NumSequenceKeypoint(0.504, 0.96875), NumSequenceKeypoint(1, 1)}
                })

                Items["Liner"] = Instances:Create("Frame", {
                    Parent = Items["Inactive"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, -18, 0, -2),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 1, 1, 2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(202, 243, 255)
                })  Items["Liner"]:AddToTheme({BackgroundColor3 = "Accent"})

                Items["Page"] = Instances:Create("Frame", {
                    Parent = Data.Page.Items["Columns"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, -2, 0, -2),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 2, 1, 0),
                    BorderSizePixel = 0,
                    Visible = false,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["Page"].Instance,
                    Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Padding = UDimNew(0, 14),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                for Index = 1, Data.Columns do 
                    local NewColumn = Instances:Create("ScrollingFrame", {
                        Parent = Items["Page"].Instance,
                        Name = "\0",
                        ScrollBarImageColor3 = FromRGB(0, 0, 0),
                        Active = true,
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollBarThickness = 0,
                        BackgroundTransparency = 1,
                        Size = UDim2New(1, 0, 1, 0),
                        BackgroundColor3 = FromRGB(255, 255, 255),
                        BorderColor3 = FromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        CanvasSize = UDim2New(0, 0, 0, 0)
                    })

                    Instances:Create("UIPadding", {
                        Parent = NewColumn.Instance,
                        Name = "\0",
                        PaddingTop = UDimNew(0, 2),
                        PaddingBottom = UDimNew(0, 2),
                        PaddingRight = UDimNew(0, 2),
                        PaddingLeft = UDimNew(0, 2)
                    })

                    Instances:Create("UIListLayout", {
                        Parent = NewColumn.Instance,
                        Name = "\0",
                        Padding = UDimNew(0, 14),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    SubPage.ColumnsData[Index] = NewColumn
                end
            end

            local Debounce = false

            Library.SearchItems[SubPage] = { }

            function SubPage:Turn(Bool)
                if Debounce then 
                    return 
                end

                SubPage.Active = Bool 
                Debounce = true
                Items["Page"].Instance.Visible = Bool 
                Items["Page"].Instance.Parent = Bool and Data.Page.Items["Columns"].Instance or Library.UnusedHolder.Instance

                if SubPage.Active then
                    Items["Inactive"]:Tween(nil, {BackgroundTransparency = 0})
                    Items["ButtonBorder"]:Tween(nil, {Transparency = 0})
                    Items["Liner"]:Tween(nil, {BackgroundTransparency = 0})
                    Items["Glow"]:Tween(nil, {BackgroundTransparency = 0})
                    Items["Text"]:Tween(nil, {Position = UDim2New(0.5, 0, 0.5, 0)})

                    Library.CurrentPage = SubPage
                else
                    Items["Inactive"]:Tween(nil, {BackgroundTransparency = 1})
                    Items["ButtonBorder"]:Tween(nil, {Transparency = 1})
                    Items["Liner"]:Tween(nil, {BackgroundTransparency = 1})
                    Items["Glow"]:Tween(nil, {BackgroundTransparency = 1})
                    Items["Text"]:Tween(nil, {Position = UDim2New(0.5, -5, 0.5, 0)})
                end

                local AllInstances = Items["Page"].Instance:GetDescendants()
                TableInsert(AllInstances, Items["Page"].Instance)

                local NewTween 

                for Index, Value in AllInstances do 
                    local TransparencyProperty = Tween:GetProperty(Value)

                    if not TransparencyProperty then 
                        continue
                    end

                    if type(TransparencyProperty) == "table" then 
                        for _, Property in TransparencyProperty do 
                            NewTween = Tween:FadeItem(Value, Property, Bool, Data.Window.FadeTime)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Data.Window.FadeTime)
                    end
                end

                if NewTween then
                    Library:Connect(NewTween.Tween.Completed, function()
                        Debounce = false
                    end)
                else
                    Debounce = false
                    Library:Notification("Warning", "Skipped a page transition animation (no tweenable elements found).", 3)
                end
            end

            Items["Inactive"]:Connect("MouseButton1Down", function()
                for Index, Value in Data.Page.SubPages do 
                    if Value == SubPage and SubPage.Active then
                        return
                    end

                    Value:Turn(Value == SubPage)
                end
            end)

            if #Data.Page.SubPages == 0 then 
                SubPage:Turn(true)
            end

            TableInsert(Data.Page.SubPages, SubPage)

            -- [Fix] In Auto mode the bar's width is normally kept in sync via
            -- CanvasSize/AbsoluteSize change signals, but those can lag a frame
            -- behind (or, in some executor environments, not have fired yet by
            -- the time every subpage has already been added synchronously).
            -- Forcing an explicit recompute here -- deferred one frame so the
            -- engine has finished laying out the new button first -- guarantees
            -- the bar always ends up sized correctly instead of staying stuck
            -- at its initial (possibly 0px) width.
            if Data.Page.Items["UpdateSubPagesBarWidth"] then
                task.defer(Data.Page.Items["UpdateSubPagesBarWidth"])
            end

            return SubPage
        end

        Components.Toggle = function(self, Data)
            local Toggle = {
                Value = false,
                Flag = Data.Flag
            }
            
            local Items = { } do
                Items["Toggle"] = Instances:Create("TextButton", {
                    Parent = Data.Parent.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 12),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Items["Indicator"] = Instances:Create("Frame", {
                    Parent = Items["Toggle"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 0.5),
                    Position = UDim2New(0, 0, 0.5, 0),
                    BorderColor3 = FromRGB(12, 12, 12),
                    Size = UDim2New(0, 12, 0, 12),
                    BorderSizePixel = 2,
                    BackgroundColor3 = FromRGB(30, 36, 31)
                })  Items["Indicator"]:AddToTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})

                Instances:Create("UIStroke", {
                    Parent = Items["Indicator"].Instance,
                    Name = "\0",
                    Color = FromRGB(42, 49, 45),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Outline"})

                Instances:Create("UIGradient", {
                    Parent = Items["Indicator"].Instance,
                    Name = "\0",
                    Rotation = -165,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(208, 208, 208))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, Library.Theme.Gradient)}
                end})

                Items["Check"] = Instances:Create("ImageLabel", {
                    Parent = Items["Indicator"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(0, 0, 0),
                    ScaleType = Enum.ScaleType.Fit,
                    ImageTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "rbxassetid://108016671469439",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(1, 2, 1, 2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Toggle"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Data.Name,
                    Size = UDim2New(0, 0, 0, 15),
                    AnchorPoint = Vector2New(0, 0.5),
                    Position = UDim2New(0, 22, 0.5, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

                Items["Text"]:TextBorder()

                Items["SubElements"] = Instances:Create("Frame", {
                    Parent = Items["Toggle"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, Items["Text"].Instance.TextBounds.X + 30, 0, 0),
                    Size = UDim2New(0, 0, 1, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["SubElements"].Instance,
                    Name = "\0",
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDimNew(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end
            
            function Toggle:Get()
                return Toggle.Value 
            end

            function Toggle:SetText(Text)
                Text = tostring(Text)
                Items["Text"].Instance.Text = Text
            end

            function Toggle:Set(Value)
                Toggle.Value = Value 
                Library.Flags[Toggle.Flag] = Value 

                if Toggle.Value then
                    Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = "Accent", BorderColor3 = "Border"})
                    Items["Indicator"]:Tween(nil, {BackgroundColor3 = Library.Theme.Accent})
                    task.wait(0.05)
                    Items["Check"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {ImageTransparency = 0, Size = UDim2New(1, 2, 1, 2)})
                else
                    Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})
                    Items["Indicator"]:Tween(nil, {BackgroundColor3 = Library.Theme.Element})
                    task.wait(0.05)
                    Items["Check"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {ImageTransparency = 1, Size = UDim2New(0, 0, 0, 0)})
                end

                if Data.Callback then 
                    Library:SafeCall(Data.Callback, Toggle.Value)
                end
            end

            function Toggle:SetVisibility(Bool)
                Items["Toggle"].Instance.Visible = Bool 
            end

            local PageSearchData = Library.SearchItems[Data.Page]

            if PageSearchData then
                local SearchData = {
                    Element = Items["Toggle"],
                    Name = Data.Name,
                }

                TableInsert(PageSearchData, SearchData)
            end

            Items["Toggle"]:Connect("MouseButton1Down", function()
                Toggle:Set(not Toggle.Value)
            end)

            Items["Toggle"]:OnHover(function()
                if Toggle.Value then 
                    return 
                end

                Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element", BorderColor3 = "Border"})
                Items["Indicator"]:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
            end)

            Items["Toggle"]:OnHoverLeave(function()
                if Toggle.Value then 
                    return 
                end

                Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})
                Items["Indicator"]:Tween(nil, {BackgroundColor3 = Library.Theme["Element"]})
            end)

            Toggle:Set(Data.Default)

            Library.SetFlags[Toggle.Flag] = function(Value)
                Toggle:Set(Value)
            end

            return Toggle, Items
        end

        Components.Button = function(self, Data)
            local Button = { }

            local Items = { } do
                Items["Button"] = Instances:Create("Frame", {
                    Parent = Data.Parent.Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["Button"].Instance,
                    Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Padding = UDimNew(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end

            function Button:Add(Name, Callback)
                local NewButton = { }

                local SubItems = { } do
                    SubItems["NewButton"] = Instances:Create("TextButton", {
                        Parent = Items["Button"].Instance,
                        Name = "\0",
                        FontFace = Library.Font,
                        TextColor3 = FromRGB(0, 0, 0),
                        BorderColor3 = FromRGB(12, 12, 12),
                        Text = "",
                        AutoButtonColor = false,
                        Size = UDim2New(1, 0, 0, 20),
                        BorderSizePixel = 2,
                        TextSize = 14,
                        BackgroundColor3 = FromRGB(30, 36, 31)
                    })  SubItems["NewButton"]:AddToTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})

                    Instances:Create("UIGradient", {
                        Parent = SubItems["NewButton"].Instance,
                        Name = "\0",
                        Rotation = -165,
                        Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(208, 208, 208))}
                    }):AddToTheme({Color = function()
                        return RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, Library.Theme.Gradient)}
                    end})

                    Instances:Create("UIStroke", {
                        Parent = SubItems["NewButton"].Instance,
                        Name = "\0",
                        Color = FromRGB(42, 49, 45),
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    }):AddToTheme({Color = "Outline"})

                    SubItems["Text"] = Instances:Create("TextLabel", {
                        Parent = SubItems["NewButton"].Instance,
                        Name = "\0",
                        FontFace = Library.Font,
                        TextColor3 = FromRGB(235, 235, 235),
                        BorderColor3 = FromRGB(0, 0, 0),
                        Text = Name,
                        BackgroundTransparency = 1,
                        Size = UDim2New(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        TextSize = 9,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  SubItems["Text"]:AddToTheme({TextColor3 = "Text"})

                    SubItems["Text"]:TextBorder()
                end

                function NewButton:Press()
                    SubItems["NewButton"]:ChangeItemTheme({BackgroundColor3 = "Accent", BorderColor3 = "Border"})
                    SubItems["NewButton"]:Tween(nil, {BackgroundColor3 = Library.Theme.Accent})

                    Library:SafeCall(Callback)
                    task.wait(0.1)

                    SubItems["NewButton"]:ChangeItemTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})
                    SubItems["NewButton"]:Tween(nil, {BackgroundColor3 = Library.Theme.Element})
                end

                function NewButton:SetVisibility(Bool)
                    SubItems["NewButton"].Instance.Visible = Bool
                end

                function NewButton:SetText(Text)
                    SubItems["Text"].Instance.Text = tostring(Text)
                end

                -- Greys the label out when there's nothing to act on (e.g. no
                -- config selected) and turns it back to normal text color
                -- once there is, as a visual cue rather than just failing silently.
                function NewButton:SetEnabled(Bool)
                    SubItems["Text"]:ChangeItemTheme({TextColor3 = Bool and "Text" or "Placeholder Text"})
                    SubItems["Text"].Instance.TextColor3 = Bool and Library.Theme.Text or Library.Theme["Placeholder Text"]
                end

                local PageSearchData = Library.SearchItems[Data.Page]

                if PageSearchData then
                    local SearchData = {
                        Element = SubItems["NewButton"],
                        Name = Name,
                    }

                    TableInsert(PageSearchData, SearchData)
                end

                SubItems["NewButton"]:OnHover(function()
                    SubItems["NewButton"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element", BorderColor3 = "Border"})
                    SubItems["NewButton"]:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
                end)

                SubItems["NewButton"]:OnHoverLeave(function()
                    SubItems["NewButton"]:ChangeItemTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})
                    SubItems["NewButton"]:Tween(nil, {BackgroundColor3 = Library.Theme.Element})
                end)

                SubItems["NewButton"]:Connect("MouseButton1Down", function()
                    NewButton:Press()
                end)

                return NewButton 
            end

            function Button:SetVisibility(Bool)
                Items["Button"].Instance.Visible = Bool
            end

            return Button, Items
        end

        Components.Slider = function(self, Data)
            local Slider = {
                Value = 0,
                Flag = Data.Flag,
                Sliding = false
            }

            local Items = { } do
                Items["Slider"] = Instances:Create("Frame", {
                    Parent = Data.Parent.Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 28),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Slider"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Data.Name,
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 0, 0, 15),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

                Items["Text"]:TextBorder()

                Items["RealSlider"] = Instances:Create("TextButton", {
                    Parent = Items["Slider"].Instance,
                    AutoButtonColor = false,
                    Text = "",
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 0, 1, 0),
                    BorderColor3 = FromRGB(12, 12, 12),
                    Size = UDim2New(1, 0, 0, 10),
                    BorderSizePixel = 2,
                    BackgroundColor3 = FromRGB(30, 36, 31)
                })  Items["RealSlider"]:AddToTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})

                Instances:Create("UIGradient", {
                    Parent = Items["RealSlider"].Instance,
                    Name = "\0",
                    Rotation = -165,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(208, 208, 208))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, Library.Theme.Gradient)}
                end})

                Instances:Create("UIStroke", {
                    Parent = Items["RealSlider"].Instance,
                    Name = "\0",
                    Color = FromRGB(42, 49, 45),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Outline"})

                -- [Feature: Corner Radius] Slider track UICorner
                local SliderCorner = InstanceNew("UICorner")
                SliderCorner.Name = "\0"
                SliderCorner.Parent = Items["RealSlider"].Instance
                Library:RegisterCorner(SliderCorner, "Sliders")

                Items["Accent"] = Instances:Create("Frame", {
                    Parent = Items["RealSlider"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0.5, 0, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(202, 243, 255)
                })  Items["Accent"]:AddToTheme({BackgroundColor3 = "Accent"})

                Instances:Create("UIGradient", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    Rotation = -165,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(208, 208, 208))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, Library.Theme.Gradient)}
                end})

                Items["Dragger"] = Instances:Create("Frame", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(1, 0.5),
                    Position = UDim2New(1, 0, 0.5, 0),
                    BorderColor3 = FromRGB(42, 49, 45),
                    Size = UDim2New(0, 3, 1, 3),
                    BorderSizePixel = 2,
                    BackgroundColor3 = FromRGB(14, 17, 15)
                })  Items["Dragger"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Outline"})

                Instances:Create("UIStroke", {
                    Parent = Items["Dragger"].Instance,
                    Name = "\0",
                    Color = FromRGB(12, 12, 12),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})

                Items["Value"] = Instances:Create("TextLabel", {
                    Parent = Items["Slider"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "50%",
                    AnchorPoint = Vector2New(1, 0),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, 0, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Value"]:AddToTheme({TextColor3 = "Text"})

                Items["Value"]:TextBorder()
            end

            function Slider:Get()
                return Slider.Value
            end

            function Slider:SetVisibility(Bool)
                Items["Slider"].Instance.Visible = Bool
            end

            function Slider:Set(Value)
                Slider.Value = Library:Round(MathClamp(Value, Data.Min, Data.Max), Data.Decimals)

                Library.Flags[Slider.Flag] = Slider.Value

                Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2New((Slider.Value - Data.Min) / (Data.Max - Data.Min), 0, 1, 0)})
                Items["Value"].Instance.Text = StringFormat("%s%s", tostring(Slider.Value), Data.Suffix)

                if Data.Callback then 
                    Library:SafeCall(Data.Callback, Slider.Value)
                end
            end

            --[[
            local PageSearchData = Library.SearchItems[Data.Page]

            if PageSearchData then
                local SearchData = {
                    Element = Items["Slider"],
                    Name = Data.Name,
                }

                TableInsert(PageSearchData, SearchData)
            end
            --]]

            local InputChanged

            Items["RealSlider"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Slider.Sliding = true 

                    local SizeX = (Mouse.X - Items["RealSlider"].Instance.AbsolutePosition.X) / Items["RealSlider"].Instance.AbsoluteSize.X
                    local Value = ((Data.Max - Data.Min) * SizeX) + Data.Min

                    Slider:Set(Value)

                    if InputChanged then
                        return
                    end

                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Slider.Sliding = false
                            
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
            end)

            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Slider.Sliding then
                        local SizeX = (Mouse.X - Items["RealSlider"].Instance.AbsolutePosition.X) / Items["RealSlider"].Instance.AbsoluteSize.X
                        local Value = ((Data.Max - Data.Min) * SizeX) + Data.Min

                        Slider:Set(Value)
                    end
                end
            end)

            Items["Slider"]:OnHover(function()
                Items["RealSlider"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element", BorderColor3 = "Border"})
                Items["RealSlider"]:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
            end)

            Items["Slider"]:OnHoverLeave(function()
                Items["RealSlider"]:ChangeItemTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})
                Items["RealSlider"]:Tween(nil, {BackgroundColor3 = Library.Theme["Element"]})
            end)

            if Data.Default then 
                Slider:Set(Data.Default)
            end

            Library.SetFlags[Slider.Flag] = function(Value)
                Slider:Set(Value)
            end

            return Slider, Items
        end

        Components.Label = function(self, Data)
            local Label = { }

            local Items = { } do
                Items["Label"] = Instances:Create("Frame", {
                    Parent = Data.Parent.Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 20),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Label"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Data.Name,
                    Size = UDim2New(0, 0, 0, 15),
                    AnchorPoint = Vector2New(0, 0.5),
                    Position = UDim2New(0, 0, 0.5, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

                Items["Text"]:TextBorder()

                Items["SubElements"] = Instances:Create("Frame", {
                    Parent = Items["Label"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, Items["Text"].Instance.TextBounds.X + 8, 0, 0),
                    Size = UDim2New(0, 0, 1, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["SubElements"].Instance,
                    Name = "\0",
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDimNew(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end

            function Label:SetText(Text)
                Text = tostring(Text)

                Items["Text"].Instance.Text = Text
            end

            function Label:SetVisibility(Bool)
                Items["Label"].Instance.Visible = Bool
            end

            return Label, Items 
        end

        Components.Dropdown = function(self, Data)
            local Dropdown = {
                Flag = Data.Flag, 
                Value = { },
                Options = { },
                IsOpen = false
            }

            local Items = { } do
                Items["Dropdown"] = Instances:Create("Frame", {
                    Parent = Data.Parent.Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 40),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Dropdown"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Data.Name,
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 0, 0, 15),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

                Items["Text"]:TextBorder()

                Items["RealDropdown"] = Instances:Create("TextButton", {
                    Parent = Items["Dropdown"].Instance,
                    AutoButtonColor = false,
                    Text = "",
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 0, 1, 0),
                    BorderColor3 = FromRGB(12, 12, 12),
                    Size = UDim2New(1, 0, 0, 20),
                    BorderSizePixel = 2,
                    BackgroundColor3 = FromRGB(30, 36, 31)
                })  Items["RealDropdown"]:AddToTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})

                Instances:Create("UIGradient", {
                    Parent = Items["RealDropdown"].Instance,
                    Name = "\0",
                    Rotation = -165,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(208, 208, 208))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, Library.Theme.Gradient)}
                end})

                Instances:Create("UIStroke", {
                    Parent = Items["RealDropdown"].Instance,
                    Name = "\0",
                    Color = FromRGB(42, 49, 45),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Outline"})

                Items["Value"] = Instances:Create("TextLabel", {
                    Parent = Items["RealDropdown"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "--",
                    AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(1, -25, 0, 15),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Position = UDim2New(0, 8, 0.5, 0),
                    BorderSizePixel = 0,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Value"]:AddToTheme({TextColor3 = "Text"})

                Items["Value"]:TextBorder()

                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["RealDropdown"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(202, 243, 255),
                    ScaleType = Enum.ScaleType.Fit,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0.5),
                    Image = "rbxassetid://113229176886493",
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, -2, 0.5, 0),
                    Size = UDim2New(0, 20, 0, 20),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Icon"]:AddToTheme({ImageColor3 = "Accent"})

                Items["OptionHolder"] = Instances:Create("Frame", {
                    Parent = Library.UnusedHolder.Instance,
                    Name = "\0",
                    Visible = false,
                    BorderColor3 = FromRGB(12, 12, 12),
                    BorderSizePixel = 2,
                    Position = UDim2New(0, 0, 1, 8),
                    Size = UDim2New(1, 0, 0, 25),
                    ZIndex = 5,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = FromRGB(20, 24, 21)
                })  Items["OptionHolder"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Border"})

                Instances:Create("UIStroke", {
                    Parent = Items["OptionHolder"].Instance,
                    Name = "\0",
                    Color = FromRGB(42, 49, 45),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Outline"})

                Instances:Create("UIPadding", {
                    Parent = Items["OptionHolder"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 5),
                    PaddingBottom = UDimNew(0, 5),
                    PaddingRight = UDimNew(0, 5),
                    PaddingLeft = UDimNew(0, 8)
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["OptionHolder"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 3),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end

            function Dropdown:Get()
                return Dropdown.Value
            end

            local Debounce = false
            local RenderStepped  

            function Dropdown:SetOpen(Bool)
                if Debounce then 
                    return
                end

                Dropdown.IsOpen = Bool

                Debounce = true 

                if Dropdown.IsOpen then 
                    Items["OptionHolder"].Instance.Visible = true
                    Items["OptionHolder"].Instance.Parent = Library.Holder.Instance
                    Items["Icon"]:Tween(nil, {Rotation = -90})
                    
                    RenderStepped = RunService.RenderStepped:Connect(function()
                        Items["OptionHolder"].Instance.Position = UDim2New(0, Items["RealDropdown"].Instance.AbsolutePosition.X, 0, Items["RealDropdown"].Instance.AbsolutePosition.Y + Items["RealDropdown"].Instance.AbsoluteSize.Y + 5)
                        Items["OptionHolder"].Instance.Size = UDim2New(0, Items["RealDropdown"].Instance.AbsoluteSize.X, 0, 0)
                    end)

                    if not Debounce then 
                        for Index, Value in Library.OpenFrames do 
                            if Value ~= Dropdown then 
                                Value:SetOpen(false)
                            end
                        end

                        Library.OpenFrames[Dropdown] = Dropdown 
                    end
                else
                    if not Debounce then 
                        if Library.OpenFrames[Dropdown] then 
                            Library.OpenFrames[Dropdown] = nil
                        end
                    end

                    if RenderStepped then 
                        RenderStepped:Disconnect()
                        RenderStepped = nil
                    end

                    Items["Icon"]:Tween(nil, {Rotation = 0})
                end

                local Descendants = Items["OptionHolder"].Instance:GetDescendants()
                TableInsert(Descendants, Items["OptionHolder"].Instance)

                local NewTween

                for Index, Value in Descendants do 
                    local TransparencyProperty = Tween:GetProperty(Value)

                    if not TransparencyProperty then
                        continue 
                    end

                    if type(TransparencyProperty) == "table" then 
                        for _, Property in TransparencyProperty do 
                            NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                    end
                end
                
                if NewTween then
                    NewTween.Tween.Completed:Connect(function()
                        Debounce = false 
                        Items["OptionHolder"].Instance.Visible = Dropdown.IsOpen
                        task.wait(0.2)
                        Items["OptionHolder"].Instance.Parent = not Dropdown.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
                end)
                else
                    Debounce = false
                    Library:Notification("Warning", "Skipped an animation (no tweenable elements found).", 3)
                end
            end

            function Dropdown:SetVisibility(Bool)
                Items["Dropdown"].Instance.Visible = Bool
            end

            function Dropdown:Set(Option)
                if Data.Multi then 
                    if type(Option) ~= "table" then 
                        return
                    end

                    Dropdown.Value = Option
                    Library.Flags[Dropdown.Flag] = Option

                    for Index, Value in Option do
                        local OptionData = Dropdown.Options[Value]
                        
                        if not OptionData then
                            continue
                        end

                        OptionData.Selected = true 
                        OptionData:Toggle("Active")
                    end

                    Items["Value"].Instance.Text = TableConcat(Option, ", ")
                else
                    if not Dropdown.Options[Option] then
                        return
                    end

                    local OptionData = Dropdown.Options[Option]

                    Dropdown.Value = Option
                    Library.Flags[Dropdown.Flag] = Option

                    for Index, Value in Dropdown.Options do
                        if Value ~= OptionData then
                            Value.Selected = false 
                            Value:Toggle("Inactive")
                        else
                            Value.Selected = true 
                            Value:Toggle("Active")
                        end
                    end

                    Items["Value"].Instance.Text = Option
                end

                if Data.Callback then   
                    Library:SafeCall(Data.Callback, Dropdown.Value)
                end
            end

            function Dropdown:Add(Option)
                local OptionButton = Instances:Create("TextButton", {
                    Parent = Items["OptionHolder"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Option,
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2New(1, 0, 0, 15),
                    ZIndex = 5,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  OptionButton:AddToTheme({TextColor3 = "Text"})

                local OptionData = {
                    Button = OptionButton,
                    Name = Option,
                    Selected = false
                }

                function OptionData:Toggle(Status)
                    if Status == "Active" then 
                        OptionData.Button:ChangeItemTheme({TextColor3 = "Accent"})
                        OptionData.Button:Tween(nil, {TextColor3 = Library.Theme.Accent})
                    else
                        OptionData.Button:ChangeItemTheme({TextColor3 = "Text"}) 
                        OptionData.Button:Tween(nil, {TextColor3 = Library.Theme.Text})
                    end
                end

                function OptionData:Set()
                    OptionData.Selected = not OptionData.Selected

                    if Data.Multi then 
                        local Index = TableFind(Dropdown.Value, OptionData.Name)

                        if Index then 
                            TableRemove(Dropdown.Value, Index)
                        else
                            TableInsert(Dropdown.Value, OptionData.Name)
                        end

                        OptionData:Toggle(Index and "Inactive" or "Active")

                        Library.Flags[Dropdown.Flag] = Dropdown.Value

                        local TextFormat = #Dropdown.Value > 0 and TableConcat(Dropdown.Value, ", ") or "--"
                        Items["Value"].Instance.Text = TextFormat
                    else
                        if OptionData.Selected then 
                            Dropdown.Value = OptionData.Name
                            Library.Flags[Dropdown.Flag] = OptionData.Name

                            OptionData.Selected = true
                            OptionData:Toggle("Active")

                            for Index, Value in Dropdown.Options do 
                                if Value ~= OptionData then
                                    Value.Selected = false 
                                    Value:Toggle("Inactive")
                                end
                            end

                            Items["Value"].Instance.Text = OptionData.Name
                        else
                            Dropdown.Value = nil
                            Library.Flags[Dropdown.Flag] = nil

                            OptionData.Selected = false
                            OptionData:Toggle("Inactive")

                            Items["Value"].Instance.Text = "--"
                        end
                    end

                    if Data.Callback then
                        Library:SafeCall(Data.Callback, Dropdown.Value)
                    end
                end

                OptionData.Button:Connect("MouseButton1Down", function()
                    OptionData:Set()
                end)

                Dropdown.Options[OptionData.Name] = OptionData
                return OptionData
            end

            function Dropdown:Remove(Option)
                if not Dropdown.Options[Option] then
                    return
                end

                Dropdown.Options[Option].Button:Clean()
                Dropdown.Options[Option] = nil
            end

            function Dropdown:Refresh(List)
                for Index, Value in Dropdown.Options do 
                    Dropdown:Remove(Value.Name)
                end

                for Index, Value in List do 
                    Dropdown:Add(Value)
                end
            end

            Items["RealDropdown"]:Connect("MouseButton1Down", function()
                Dropdown:SetOpen(not Dropdown.IsOpen)
            end)

            Items["Dropdown"]:OnHover(function()
                Items["RealDropdown"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element", BorderColor3 = "Border"})
                Items["RealDropdown"]:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
            end)

            Items["Dropdown"]:OnHoverLeave(function()
                Items["RealDropdown"]:ChangeItemTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})
                Items["RealDropdown"]:Tween(nil, {BackgroundColor3 = Library.Theme["Element"]})
            end)

            Library:Connect(UserInputService.InputBegan, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if not Dropdown.IsOpen then
                        return 
                    end

                    if Library:IsMouseOverFrame(Items["OptionHolder"]) then 
                        return
                    end

                    Dropdown:SetOpen(false)
                end
            end)

            for Index, Value in Data.Items do 
                Dropdown:Add(Value)
            end

            if Data.Default then 
                Dropdown:Set(Data.Default)
            end

            Library.SetFlags[Dropdown.Flag] = function(Value)
                Dropdown:Set(Value)
            end

            return Dropdown, Items 
        end

        Components.ColorpickerTab = function(self, Data)
            if not Data.Pages then 
                return
            end

            local NewTab = { 
                Name = Data.Name,
                Active = false
            }

            local Items = { } do
                Items["Inactive"] = Instances:Create("TextButton", {
                    Parent = Data.PageHolder.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = NewTab.Name,
                    AutoButtonColor = false,
                    Size = UDim2New(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(20, 24, 21)
                })  Items["Inactive"]:AddToTheme({BackgroundColor3 = "Inline"})

                Items["Inactive"]:TextBorder()

                Items["PageContent"] = Instances:Create("Frame", {
                    Parent = Data.ContentHolder.Instance,
                    Name = "\0",
                    Visible = false,
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
            end

            function NewTab:Turn(Bool)
                NewTab.Active = Bool 

                if NewTab.Active then
                    Items["PageContent"].Instance.Visible = true 
                    Items["PageContent"].Instance.Parent = Data.ContentHolder.Instance 

                    Items["Inactive"]:ChangeItemTheme({BackgroundColor3 = "Background"})
                    Items["Inactive"]:Tween(nil, {BackgroundColor3 = Library.Theme.Background})
                else
                    Items["PageContent"].Instance.Visible = false
                    Items["PageContent"].Instance.Parent = Library.UnusedHolder.Instance 

                    Items["Inactive"]:ChangeItemTheme({BackgroundColor3 = "Inline"})
                    Items["Inactive"]:Tween(nil, {BackgroundColor3 = Library.Theme.Inline})
                end
            end

            Items["Inactive"]:Connect("MouseButton1Down", function()
                for Index, Value in Data.Stack do 
                    Value:Turn(Value == NewTab)
                end
            end)

            if #Data.Stack == 0 then 
                NewTab:Turn(true)
            end

            TableInsert(Data.Stack, NewTab)
            return NewTab, Items 
        end

        Components.CreateSubPaletteItems = function(self, Items)
            Items["ColorpickerWindow"].Instance.Size = UDim2New(0, 171, 0, 168)

            Items["Palette"] = Instances:Create("TextButton", {
                Parent = Items["ColorpickerWindow"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(42, 49, 45),
                Text = "",
                AutoButtonColor = false,
                Position = UDim2New(0, 8, 0, 8),
                Size = UDim2New(1, -41, 1, -41),
                BorderSizePixel = 2,
                TextSize = 14,
                BackgroundColor3 = FromRGB(157, 175, 255)
            })  Items["Palette"]:AddToTheme({BorderColor3 = "Outline"})

            Instances:Create("UIStroke", {
                Parent = Items["Palette"].Instance,
                Name = "\0",
                Color = FromRGB(12, 12, 12),
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Border"})

            Items["Saturation"] = Instances:Create("ImageLabel", {
                Parent = Items["Palette"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Image = Library:GetImage("Saturation"),
                BackgroundTransparency = 1,
                Size = UDim2New(1, 0, 1, 0),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Value"] = Instances:Create("ImageLabel", {
                Parent = Items["Palette"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 2, 1, 0),
                Image = Library:GetImage("Value"),
                BackgroundTransparency = 1,
                Position = UDim2New(0, -1, 0, 0),
                ZIndex = 3,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["PaletteDragger"] = Instances:Create("Frame", {
                Parent = Items["Palette"].Instance,
                Name = "\0",
                Position = UDim2New(0, 8, 0, 8),
                ZIndex = 5,
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0, 2, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Items["PaletteDragger"].Instance,
                Name = "\0",
                Color = FromRGB(12, 12, 12),
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Border"})

            Items["Hue"] = Instances:Create("Frame", {
                Parent = Items["ColorpickerWindow"].Instance,
                Name = "\0",
                Active = true,
                BorderColor3 = FromRGB(42, 49, 45),
                AnchorPoint = Vector2New(1, 0),
                Position = UDim2New(1, -8, 0, 8),
                Size = UDim2New(0, 15, 1, -16),
                Selectable = true,
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Hue"]:AddToTheme({BorderColor3 = "Outline"})

            Instances:Create("UIStroke", {
                Parent = Items["Hue"].Instance,
                Name = "\0",
                Color = FromRGB(12, 12, 12),
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Border"})

            Items["HueInline"] = Instances:Create("TextButton", {
                Parent = Items["Hue"].Instance,
                Text = "",
                AutoButtonColor = false,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIGradient", {
                Parent = Items["HueInline"].Instance,
                Name = "\0",
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 0, 0)), RGBSequenceKeypoint(0.17, FromRGB(255, 255, 0)), RGBSequenceKeypoint(0.33, FromRGB(0, 255, 0)), RGBSequenceKeypoint(0.5, FromRGB(0, 255, 255)), RGBSequenceKeypoint(0.67, FromRGB(0, 0, 255)), RGBSequenceKeypoint(0.83, FromRGB(255, 0, 255)), RGBSequenceKeypoint(1, FromRGB(255, 0, 0))}
            })

            Items["HueDragger"] = Instances:Create("Frame", {
                Parent = Items["Hue"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Items["HueDragger"].Instance,
                Name = "\0",
                Color = FromRGB(12, 12, 12),
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Border"})

            Items["Alpha"] = Instances:Create("TextButton", {
                Parent = Items["ColorpickerWindow"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(42, 49, 45),
                Text = "",
                AutoButtonColor = false,
                AnchorPoint = Vector2New(0, 1),
                Position = UDim2New(0, 8, 1, -8),
                Size = UDim2New(1, -41, 0, 15),
                BorderSizePixel = 2,
                TextSize = 14,
                BackgroundColor3 = FromRGB(157, 175, 255)
            })  Items["Alpha"]:AddToTheme({BorderColor3 = "Outline"})

            Instances:Create("UIStroke", {
                Parent = Items["Alpha"].Instance,
                Name = "\0",
                Color = FromRGB(12, 12, 12),
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Border"})

            Items["Checkers"] = Instances:Create("ImageLabel", {
                Parent = Items["Alpha"].Instance,
                Name = "\0",
                ScaleType = Enum.ScaleType.Tile,
                BorderColor3 = FromRGB(0, 0, 0),
                TileSize = UDim2New(0, 6, 0, 6),
                Image = Library:GetImage("Checkers"),
                BackgroundTransparency = 1,
                Size = UDim2New(1, 0, 1, 0),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  

            Instances:Create("UIGradient", {
                Parent = Items["Checkers"].Instance,
                Name = "\0",
                Transparency = NumSequence{NumSequenceKeypoint(0, 1), NumSequenceKeypoint(0.37, 0.5), NumSequenceKeypoint(1, 0)}
            })

            Items["AlphaDragger"] = Instances:Create("Frame", {
                Parent = Items["Alpha"].Instance,
                Name = "\0",
                ZIndex = 5,
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0, 1, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Items["AlphaDragger"].Instance,
                Name = "\0",
                Color = FromRGB(12, 12, 12),
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Border"})
        end

        Components.Colorpicker = function(self, Data) -- poetry warning (╯°□°)╯
            local Colorpicker = {
                IsOpen = false,

                Hue = 0,
                Saturation = 0,
                Value = 0,
                Alpha = 0,

                Color = FromRGB(255, 255, 255),
                HexValue = "#ffffff",

                Pages = Data.Pages and { } or nil,
                Flag = Data.Flag,
            }

            local UpdateSync

            local Items = { } do
                Items["ColorpickerButton"] = Instances:Create("TextButton", {
                    Parent = Data.Parent.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(12, 12, 12),
                    Text = "",
                    AutoButtonColor = false,
                    Position = UDim2New(0, -123, 0, 0),
                    Size = UDim2New(0, 15, 0, 15),
                    BorderSizePixel = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(157, 175, 255)
                })  Items["ColorpickerButton"]:AddToTheme({BorderColor3 = "Border"})

                Instances:Create("UIStroke", {
                    Parent = Items["ColorpickerButton"].Instance,
                    Name = "\0",
                    Color = FromRGB(42, 49, 45),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Outline"})

                Items["ColorpickerButtonInline"] = Instances:Create("Frame", {
                    Parent = Items["ColorpickerButton"].Instance,
                    Name = "\0",
                    Position = UDim2New(0, 1, 0, 1),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(157, 175, 255)
                })

                Instances:Create("UIGradient", {
                    Parent = Items["ColorpickerButtonInline"].Instance,
                    Name = "\0",
                    Rotation = -165,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(208, 208, 208))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, Library.Theme.Gradient)}
                end})

                Items["ColorpickerWindow"] = Instances:Create("TextButton", {
                    Parent = Library.UnusedHolder.Instance,
                    Text = "",
                    AutoButtonColor = false,
                    Name = "\0",
                    Position = UDim2New(0, 12, 0, 12),
                    BorderColor3 = FromRGB(12, 12, 12),
                    Size = UDim2New(0, 266, 0, 258),
                    BorderSizePixel = 2,
                    BackgroundColor3 = FromRGB(14, 17, 15)
                })  Items["ColorpickerWindow"]:AddToTheme({BorderColor3 = "Border", BackgroundColor3 = "Background"})

                Instances:Create("UIStroke", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    Color = FromRGB(42, 49, 45),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Outline"})

                if Data.Pages then 
                    Items["Pages"] = Instances:Create("Frame", {
                        Parent = Items["ColorpickerWindow"].Instance,
                        Name = "\0",
                        BackgroundTransparency = 1,
                        BorderColor3 = FromRGB(0, 0, 0),
                        Size = UDim2New(1, 0, 0, 20),
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })

                    Instances:Create("UIListLayout", {
                        Parent = Items["Pages"].Instance,
                        Name = "\0",
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalFlex = Enum.UIFlexAlignment.Fill
                    })

                    Items["Content"] = Instances:Create("Frame", {
                        Parent = Items["ColorpickerWindow"].Instance,
                        Name = "\0",
                        BackgroundTransparency = 1,
                        Position = UDim2New(0, 0, 0, 25),
                        BorderColor3 = FromRGB(0, 0, 0),
                        Size = UDim2New(1, 0, 1, -25),
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })
                else
                    Components:CreateSubPaletteItems(Items)
                end
            end

            local ColorTab, ColorTabItems = Components:ColorpickerTab({
                ContentHolder = Items["Content"],
                Pages = Colorpicker.Pages,
                PageHolder = Items["Pages"],
                Stack = Colorpicker.Pages,
                Name = "Color"
            })

            local AnimationsTab, AnimationsTabItems = Components:ColorpickerTab({
                ContentHolder = Items["Content"],
                Pages = Colorpicker.Pages,
                PageHolder = Items["Pages"],
                Stack = Colorpicker.Pages,
                Name = "Animations"
            })

            local OtherTab, OtherTabItems = Components:ColorpickerTab({
                ContentHolder = Items["Content"],
                Pages = Colorpicker.Pages,
                PageHolder = Items["Pages"],
                Stack = Colorpicker.Pages,
                Name = "Other"
            })

            local OldColor = Colorpicker.Color
            local OldAlpha = Colorpicker.Alpha
            local CurrentAnimation

            local AnimationsDropdown, AnimationsDropdownItems
            local KeyframeOneLabel, KeyframeOneLabelItems
            local KeyframeTwoLabel, KeyframeTwoLabelItems

            local KeyframeOneColorpicker, KeyframeOneColorpickerItems
            local KeyframeTwoColorpicker, KeyframeTwoColorpickerItems

            local AnimationSpeedSlider, AnimationSpeedSliderItems

            if ColorTab then
                Items["Palette"] = Instances:Create("TextButton", {
                    Parent = ColorTabItems["PageContent"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(42, 49, 45),
                    Text = "",
                    AutoButtonColor = false,
                    Position = UDim2New(0, 8, 0, 8),
                    Size = UDim2New(1, -46, 1, -46),
                    BorderSizePixel = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(157, 175, 255)
                })  Items["Palette"]:AddToTheme({BorderColor3 = "Outline"})

                Instances:Create("UIStroke", {
                    Parent = Items["Palette"].Instance,
                    Name = "\0",
                    Color = FromRGB(12, 12, 12),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})

                Items["Saturation"] = Instances:Create("ImageLabel", {
                    Parent = Items["Palette"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Image = Library:GetImage("Saturation"),
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 1, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Items["Value"] = Instances:Create("ImageLabel", {
                    Parent = Items["Palette"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 2, 1, 0),
                    Image = Library:GetImage("Value"),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, -1, 0, 0),
                    ZIndex = 3,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Items["PaletteDragger"] = Instances:Create("Frame", {
                    Parent = Items["Palette"].Instance,
                    Name = "\0",
                    Position = UDim2New(0, 8, 0, 8),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 2, 0, 2),
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIStroke", {
                    Parent = Items["PaletteDragger"].Instance,
                    Name = "\0",
                    Color = FromRGB(12, 12, 12),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})

                Items["Hue"] = Instances:Create("Frame", {
                    Parent = ColorTabItems["PageContent"].Instance,
                    Name = "\0",
                    Active = true,
                    BorderColor3 = FromRGB(42, 49, 45),
                    AnchorPoint = Vector2New(1, 0),
                    Position = UDim2New(1, -8, 0, 8),
                    Size = UDim2New(0, 20, 1, -16),
                    Selectable = true,
                    BorderSizePixel = 2,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Hue"]:AddToTheme({BorderColor3 = "Outline"})

                Instances:Create("UIStroke", {
                    Parent = Items["Hue"].Instance,
                    Name = "\0",
                    Color = FromRGB(12, 12, 12),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})

                Items["HueInline"] = Instances:Create("TextButton", {
                    Parent = Items["Hue"].Instance,
                    AutoButtonColor = false,
                    Text = "",
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIGradient", {
                    Parent = Items["HueInline"].Instance,
                    Name = "\0",
                    Rotation = 90,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 0, 0)), RGBSequenceKeypoint(0.17, FromRGB(255, 255, 0)), RGBSequenceKeypoint(0.33, FromRGB(0, 255, 0)), RGBSequenceKeypoint(0.5, FromRGB(0, 255, 255)), RGBSequenceKeypoint(0.67, FromRGB(0, 0, 255)), RGBSequenceKeypoint(0.83, FromRGB(255, 0, 255)), RGBSequenceKeypoint(1, FromRGB(255, 0, 0))}
                })

                Items["HueDragger"] = Instances:Create("Frame", {
                    Parent = Items["Hue"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 1),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIStroke", {
                    Parent = Items["HueDragger"].Instance,
                    Name = "\0",
                    Color = FromRGB(12, 12, 12),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})

                Items["Alpha"] = Instances:Create("TextButton", {
                    Parent = ColorTabItems["PageContent"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(42, 49, 45),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 8, 1, -8),
                    Size = UDim2New(1, -46, 0, 20),
                    BorderSizePixel = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(157, 175, 255)
                })  Items["Alpha"]:AddToTheme({BorderColor3 = "Outline"})

                Instances:Create("UIStroke", {
                    Parent = Items["Alpha"].Instance,   
                    Name = "\0",
                    Color = FromRGB(12, 12, 12),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})

                Items["Checkers"] = Instances:Create("ImageLabel", {
                    Parent = Items["Alpha"].Instance,
                    Name = "\0",
                    ScaleType = Enum.ScaleType.Tile,
                    BorderColor3 = FromRGB(0, 0, 0),
                    TileSize = UDim2New(0, 6, 0, 6),
                    Image = Library:GetImage("Checkers"),
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 1, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  

                Instances:Create("UIGradient", {
                    Parent = Items["Checkers"].Instance,
                    Name = "\0",
                    Transparency = NumSequence{NumSequenceKeypoint(0, 1), NumSequenceKeypoint(0.37, 0.5), NumSequenceKeypoint(1, 0)}
                })

                Items["AlphaDragger"] = Instances:Create("Frame", {
                    Parent = Items["Alpha"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 1, 1, 0),
                    ZIndex = 5,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIStroke", {
                    Parent = Items["AlphaDragger"].Instance,
                    Name = "\0",
                    Color = FromRGB(12, 12, 12),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})
            end

            if AnimationsTab then
                AnimationsDropdown, AnimationsDropdownItems = Components:Dropdown({
                    Parent = AnimationsTabItems["PageContent"],
                    Name = "Animations",
                    Items = {"Rainbow", "Fade", "Fade alpha", "Linear"},
                    Default = nil,
                    Flag = Colorpicker.Flag.."Animation",
                    Multi = false,
                    Debounce = Colorpicker,
                    Callback = function(Value)
                        CurrentAnimation = Value
                        if Value == "Rainbow" then 
                            if KeyframeOneLabel and KeyframeTwoLabel and AnimationSpeedSlider then
                                KeyframeOneLabel:SetVisibility(false)
                                KeyframeTwoLabel:SetVisibility(false)

                                AnimationSpeedSliderItems["Slider"].Instance.Position = UDim2New(0, 8, 0, 45)
                            end

                            OldColor = Colorpicker.Color

                            Library:Thread(function()
                                while task.wait() do 
                                    local RainbowHue = MathAbs(MathSin(tick() * (AnimationSpeedSlider.Value / 25)))
                                    local Color = FromHSV(RainbowHue, 1, 1)

                                    Colorpicker:Set(Color, Colorpicker.Alpha)
                                    UpdateSync(true)

                                    if CurrentAnimation ~= "Rainbow" then
                                        Colorpicker:Set(OldColor, Colorpicker.Alpha)
                                        break
                                    end
                                end
                            end)
                        elseif Value == "Fade" then 
                            if KeyframeOneLabel and KeyframeTwoLabel and AnimationSpeedSlider then
                                KeyframeOneLabel:SetVisibility(true)
                                KeyframeTwoLabel:SetVisibility(false)

                                AnimationSpeedSliderItems["Slider"].Instance.Position = UDim2New(0, 8, 0, 65)

                                OldColor = Colorpicker.Color
                                
                                Library:Thread(function()
                                    while task.wait() do 
                                        local Speed = MathAbs(MathSin(tick() * (AnimationSpeedSlider.Value / 25)))
                                        Colorpicker:Set(KeyframeOneColorpicker.Color:Lerp(FromRGB(0, 0, 0), Speed), Colorpicker.Alpha)
                                        UpdateSync(true)

                                        if CurrentAnimation ~= "Fade" then
                                            Colorpicker:Set(OldColor, Colorpicker.Alpha)
                                            break
                                        end
                                    end
                                end)
                            end
                        elseif Value == "Fade alpha" then
                            if KeyframeOneLabel and KeyframeTwoLabel then
                                KeyframeOneLabel:SetVisibility(false)
                                KeyframeTwoLabel:SetVisibility(false)

                                AnimationSpeedSliderItems["Slider"].Instance.Position = UDim2New(0, 8, 0, 45)

                                OldColor = Colorpicker.Alpha
                                
                                Library:Thread(function()
                                    while task.wait() do 
                                        local AlphaValue = MathAbs(MathSin(tick() * (AnimationSpeedSlider.Value / 25)))
                                        Colorpicker:Set(Colorpicker.Color, AlphaValue)
                                        UpdateSync(true)

                                        if CurrentAnimation ~= "Fade alpha" then
                                            Colorpicker:Set(Colorpicker.Color, OldAlpha)
                                            break
                                        end
                                    end
                                end)
                            end
                        elseif Value == "Linear" then
                            if KeyframeOneLabel and KeyframeTwoLabel then
                                KeyframeOneLabel:SetVisibility(true)
                                KeyframeTwoLabel:SetVisibility(true)

                                AnimationSpeedSliderItems["Slider"].Instance.Position = UDim2New(0, 8, 0, 85)

                                OldColor = Colorpicker.Color
                                
                                Library:Thread(function()
                                    while task.wait() do 
                                        local Speed = MathAbs(MathSin(tick() * (AnimationSpeedSlider.Value / 25)))
                                        Colorpicker:Set(KeyframeOneColorpicker.Color:Lerp(KeyframeTwoColorpicker.Color, Speed), Colorpicker.Alpha)
                                        UpdateSync(true)

                                        if CurrentAnimation ~= "Linear" then
                                            Colorpicker:Set(OldColor, Colorpicker.Alpha)
                                            break
                                        end
                                    end
                                end)
                            end
                        end
                    end
                })

                AnimationsDropdownItems["Dropdown"].Instance.Position = UDim2New(0, 8, 0, 0)
                AnimationsDropdownItems["Dropdown"].Instance.Size = UDim2New(1, -16, 0, 40)

                KeyframeOneLabel, KeyframeOneLabelItems = Components:Label({
                    Parent = AnimationsTabItems["PageContent"],
                    Name = "Keyframe 1",
                })

                KeyframeOneLabelItems["Label"].Instance.Position = UDim2New(0, 8, 0, 45)
                KeyframeOneLabelItems["Label"].Instance.Size = UDim2New(1, -16, 0, 20)

                KeyframeTwoLabel, KeyframeTwoLabelItems = Components:Label({
                    Parent = AnimationsTabItems["PageContent"],
                    Name = "Keyframe 2",
                })

                KeyframeTwoLabelItems["Label"].Instance.Position = UDim2New(0, 8, 0, 65)
                KeyframeTwoLabelItems["Label"].Instance.Size = UDim2New(1, -16, 0, 20)

                KeyframeOneColorpicker, KeyframeOneColorpickerItems = Components:Colorpicker({
                    Parent = KeyframeOneLabelItems["SubElements"],
                    Alpha = 0,
                    Pages = false,
                    Default = Color3.fromRGB(255, 255, 255),
                    Flag = Colorpicker.Flag.."Animation".."Keyframe1",
                    Debounce = Colorpicker,
                })

                KeyframeTwoColorpicker, KeyframeTwoColorpickerItems = Components:Colorpicker({
                    Parent = KeyframeTwoLabelItems["SubElements"],
                    Alpha = 0,
                    Pages = false,
                    Default = Color3.fromRGB(0, 0, 0),
                    Debounce = Colorpicker,
                    Flag = Colorpicker.Flag.."Animation".."Keyframe2",
                })

                AnimationSpeedSlider, AnimationSpeedSliderItems = Components:Slider({
                    Parent = AnimationsTabItems["PageContent"],
                    Name = "Speed",
                    Flag = Colorpicker.Flag .. "AnimationSpeed",
                    Min = 0,
                    Max = 100,
                    Decimals = 0.1,
                    Default = 20,
                    Suffix = "%",
                })

                AnimationSpeedSliderItems["Slider"].Instance.Position = UDim2New(0, 8, 0, 85)
                AnimationSpeedSliderItems["Slider"].Instance.Size = UDim2New(1, -16, 0, 28)
            end

            local IsSyncToggled

            if OtherTab then
                Items["CurrentColor"] = Instances:Create("Frame", {
                    Parent = OtherTabItems["PageContent"].Instance,
                    Name = "\0",
                    Position = UDim2New(0, 8, 0, 8),
                    BorderColor3 = FromRGB(42, 49, 45),
                    Size = UDim2New(1, -16, 0, 50),
                    BorderSizePixel = 2,
                    BackgroundColor3 = FromRGB(157, 175, 255)
                })  Items["CurrentColor"]:AddToTheme({BorderColor3 = "Outline"})

                Instances:Create("UIStroke", {
                    Parent = Items["CurrentColor"].Instance,
                    Name = "\0",
                    Color = FromRGB(12, 12, 12),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})

                Instances:Create("UIGradient", {
                    Parent = Items["CurrentColor"].Instance,
                    Name = "\0",
                    Rotation = 82,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(154, 154, 154))}
                })

                Items["RGBColor"] = Instances:Create("TextLabel", {
                    Parent = OtherTabItems["PageContent"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "RGB:",
                    Size = UDim2New(1, -16, 0, 15),
                    Position = UDim2New(0, 8, 0, 65),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    RichText = true,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Items["HEXColor"] = Instances:Create("TextLabel", {
                    Parent = OtherTabItems["PageContent"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "HEX:",
                    Size = UDim2New(1, -16, 0, 15),
                    Position = UDim2New(0, 8, 0, 85),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    RichText = true,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Items["HSVColor"] = Instances:Create("TextLabel", {
                    Parent = OtherTabItems["PageContent"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "HSV:",
                    Size = UDim2New(1, -16, 0, 15),
                    Position = UDim2New(0, 8, 0, 105),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    RichText = true,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                local CopyNPasteButton, CopyNPasteButtonItems = Components:Button({
                    Parent = OtherTabItems["PageContent"],
                })

                CopyNPasteButtonItems["Button"].Instance.Position = UDim2New(0, 8, 0, 145)
                CopyNPasteButtonItems["Button"].Instance.Size = UDim2New(1, -16, 0, 20)

                CopyNPasteButton:Add("Copy", function()
                    Library.CopiedColor = Colorpicker.Color
                end)

                CopyNPasteButton:Add("Paste", function()
                    if Library.CopiedColor then
                        Colorpicker:Set(Library.CopiedColor)
                    end
                end)

                local Stash = { }

                IsSyncToggled = false

                local SyncColorpickersToggle, SyncColorpickerToggleItems = Components:Toggle({
                    Parent = OtherTabItems["PageContent"],
                    Flag = "SyncColorpickers"..Colorpicker.Flag,
                    Name = "Sync colorpickers",
                    Default = false,
                    Callback = function(Value)
                        IsSyncToggled = Value
                        if Value then 
                            for Index, Value in Library.Colorpickers do 
                                Stash[Value] = Value.Color
                                Value:Set(Colorpicker.Color)
                            end
                        else
                            for Index, Value in Library.Colorpickers do 
                                if Stash[Value] then
                                    Value:Set(Stash[Value])
                                end
                            end
                        end
                    end
                })

                SyncColorpickerToggleItems["Toggle"].Instance.Position = UDim2New(0, 8, 0, 125)
                SyncColorpickerToggleItems["Toggle"].Instance.Size = UDim2New(1, -16, 0, 12)
            end

            local Debounce = false
            local RenderStepped  

            function Colorpicker:SetOpen(Bool)
                if Debounce then 
                    return
                end

                Colorpicker.IsOpen = Bool

                Debounce = true 

                if Colorpicker.IsOpen then 
                    Items["ColorpickerWindow"].Instance.Visible = true
                    Items["ColorpickerWindow"].Instance.Parent = Library.Holder.Instance
                    
                    RenderStepped = RunService.RenderStepped:Connect(function()
                        Items["ColorpickerWindow"].Instance.Position = UDim2New(0, Items["ColorpickerButton"].Instance.AbsolutePosition.X, 0, Items["ColorpickerButton"].Instance.AbsolutePosition.Y + Items["ColorpickerButton"].Instance.AbsoluteSize.Y + 5)
                    end)

                    if not Data.Debounce then
                        for Index, Value in Library.OpenFrames do 
                            if Value ~= Colorpicker and Value ~= AnimationsDropdownItems then 
                                Value:SetOpen(false)
                            end
                        end

                        Library.OpenFrames[Colorpicker] = Colorpicker 
                    end
                else
                    if not Data.Debounce then 
                        if Library.OpenFrames[Colorpicker] then 
                            Library.OpenFrames[Colorpicker] = nil
                        end
                    end

                    if RenderStepped then 
                        RenderStepped:Disconnect()
                        RenderStepped = nil
                    end
                end

                local Descendants = Items["ColorpickerWindow"].Instance:GetDescendants()
                TableInsert(Descendants, Items["ColorpickerWindow"].Instance)

                local NewTween

                for Index, Value in Descendants do 
                    local TransparencyProperty = Tween:GetProperty(Value)

                    if not TransparencyProperty then
                        continue 
                    end

                    if type(TransparencyProperty) == "table" then 
                        for _, Property in TransparencyProperty do 
                            NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                    end
                end
                
                if NewTween then
                    NewTween.Tween.Completed:Connect(function()
                        Debounce = false 
                        Items["ColorpickerWindow"].Instance.Visible = Colorpicker.IsOpen
                        task.wait(0.2)
                        Items["ColorpickerWindow"].Instance.Parent = not Colorpicker.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
                end)
                else
                    Debounce = false
                    Library:Notification("Warning", "Skipped an animation (no tweenable elements found).", 3)
                end
            end

            UpdateSync = function(Bool)
                if IsSyncToggled and Bool then 
                    for Index, Value in Library.Colorpickers do 
                        if Value ~= Colorpicker and not StringFind(Value.Flag, "Theme") then
                            Value:Set(Colorpicker.Color)
                        end
                    end
                end
            end

            function Colorpicker:Update(IsFromAlpha, UpdateSyncc)
                local Hue, Saturation, Value = Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value
                Colorpicker.Color = FromHSV(Hue, Saturation, Value)
                Colorpicker.HexValue = Colorpicker.Color:ToHex()

                Library.Flags[Colorpicker.Flag] = {
                    Alpha = Colorpicker.Alpha,
                    Color = Colorpicker.HexValue
                }

                Items["ColorpickerButton"]:Tween(nil, {BackgroundColor3 = Colorpicker.Color})
                Items["ColorpickerButtonInline"]:Tween(nil, {BackgroundColor3 = Colorpicker.Color})

                UpdateSync(UpdateSyncc)

                if OtherTab then
                    Items["CurrentColor"]:Tween(nil, {BackgroundColor3 = Colorpicker.Color})

                    local Red = MathFloor(Colorpicker.Color.R * 255)
                    local Green = MathFloor(Colorpicker.Color.G * 255)
                    local Blue = MathFloor(Colorpicker.Color.B * 255)
                    local RedGreenBlue = tostring(Red) .. ", " .. tostring(Green) .. ", " .. tostring(Blue)

                    local FloorHue, FloorSat, FloorVal = nil, nil, nil

                    Items["RGBColor"].Instance.Text = "RGB: "..RedGreenBlue
                    Items["HSVColor"].Instance.Text = `HSV: %1, %1, %1`
                    Items["HEXColor"].Instance.Text = "HEX: " .. "#" .. Colorpicker.HexValue
                end

                Items["Palette"]:Tween(nil, {BackgroundColor3 = FromHSV(Hue, 1, 1)})

                if not IsFromAlpha then 
                    Items["Alpha"]:Tween(nil, {BackgroundColor3 = Colorpicker.Color})
                end

                if Data.Callback then 
                    Library:SafeCall(Data.Callback, Colorpicker.Color, Colorpicker.Alpha)
                end
            end

            function Colorpicker:Set(Color, Alpha)
                if type(Color) == "table" then
                    Color = FromRGB(Color[1], Color[2], Color[3])
                    Alpha = Color[4]
                elseif type(Color) == "string" then
                    Color = FromHex(Color)
                end 

                Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value = Color:ToHSV()
                Colorpicker.Alpha = Alpha or 0  

                local PaletteValueX = MathClamp(1 - Colorpicker.Saturation, 0, 0.99)
                local PaletteValueY = MathClamp(1 - Colorpicker.Value, 0, 0.99)

                local AlphaPositionX = MathClamp(Colorpicker.Alpha, 0, 0.995)
                    
                local HuePositionY = MathClamp(Colorpicker.Hue, 0, 0.995)

                Items["PaletteDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(PaletteValueX, 0, PaletteValueY, 0)})
                Items["HueDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, HuePositionY, 0)})
                Items["AlphaDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(AlphaPositionX, 0, 0, 0)})
                Colorpicker:Update(true, true)
            end

            Items["ColorpickerButton"]:Connect("MouseButton1Down", function()
                Colorpicker:SetOpen(not Colorpicker.IsOpen)
            end)

            local SlidingPalette = false
            local PaletteChanged
            
            function Colorpicker:SlidePalette(Input)
                if not Input or not SlidingPalette then
                    return
                end

                local ValueX = MathClamp(1 - (Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 1)
                local ValueY = MathClamp(1 - (Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 1)

                Colorpicker.Saturation = ValueX
                Colorpicker.Value = ValueY

                local SlideX = MathClamp((Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 0.99)
                local SlideY = MathClamp((Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 0.99)

                Items["PaletteDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(SlideX, 0, SlideY, 0)})
                Colorpicker:Update(false, true)
            end
            
            local SlidingHue = false
            local HueChanged

            function Colorpicker:SlideHue(Input)
                if not Input or not SlidingHue then
                    return
                end
                
                local ValueY = MathClamp((Input.Position.Y - Items["Hue"].Instance.AbsolutePosition.Y) / Items["Hue"].Instance.AbsoluteSize.Y, 0, 1)

                Colorpicker.Hue = ValueY

                local SlideY = MathClamp((Input.Position.Y - Items["Hue"].Instance.AbsolutePosition.Y) / Items["Hue"].Instance.AbsoluteSize.Y, 0, 0.995)

                Items["HueDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, SlideY, 0)})
                Colorpicker:Update(false, true)
            end

            local SlidingAlpha = false 
            local AlphaChanged

            function Colorpicker:SlideAlpha(Input)
                if not Input or not SlidingAlpha then
                    return
                end

                local ValueX = MathClamp((Input.Position.X - Items["Alpha"].Instance.AbsolutePosition.X) / Items["Alpha"].Instance.AbsoluteSize.X, 0, 1)

                Colorpicker.Alpha = ValueX

                local SlideX = MathClamp((Input.Position.X - Items["Alpha"].Instance.AbsolutePosition.X) / Items["Alpha"].Instance.AbsoluteSize.X, 0, 0.995)

                Items["AlphaDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(SlideX, 0, 0, 0)})
                Colorpicker:Update(true, true)
            end

            Items["Palette"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    SlidingPalette = true 

                    Colorpicker:SlidePalette(Input)

                    if PaletteChanged then
                        return
                    end

                    PaletteChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            SlidingPalette = false

                            PaletteChanged:Disconnect()
                            PaletteChanged = nil
                        end
                    end)
                end
            end)

            Items["HueInline"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    SlidingHue = true 

                    Colorpicker:SlideHue(Input)

                    if HueChanged then
                        return
                    end

                    HueChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            SlidingHue = false

                            HueChanged:Disconnect()
                            HueChanged = nil
                        end
                    end)
                end
            end)

            Items["Alpha"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    SlidingAlpha = true 

                    Colorpicker:SlideAlpha(Input)

                    if AlphaChanged then
                        return
                    end

                    AlphaChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            SlidingAlpha = false

                            AlphaChanged:Disconnect()
                            AlphaChanged = nil
                        end
                    end)
                end
            end)

            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if SlidingPalette then 
                        Colorpicker:SlidePalette(Input)
                    end

                    if SlidingHue then
                        Colorpicker:SlideHue(Input)
                    end

                    if SlidingAlpha then
                        Colorpicker:SlideAlpha(Input)
                    end
                end
            end)

            Library:Connect(UserInputService.InputBegan, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if not Colorpicker.IsOpen then
                        return
                    end

                    if Library:IsMouseOverFrame(Items["ColorpickerWindow"]) then
                        return
                    end

                    if KeyframeOneLabel and KeyframeTwoLabel then
                        if Library:IsMouseOverFrame(KeyframeOneColorpickerItems["ColorpickerWindow"]) then
                            return
                        end

                        if Library:IsMouseOverFrame(KeyframeTwoColorpickerItems["ColorpickerWindow"]) then
                            return
                        end
                    end

                    Colorpicker:SetOpen(false)
                end
            end)

            if Data.Default then
                Colorpicker:Set(Data.Default, Data.Alpha)
                OldColor = Colorpicker.Color
            end

            Library.Colorpickers[Colorpicker] = Colorpicker

            Library.SetFlags[Colorpicker.Flag] = function(Value, Alpha)
                Colorpicker:Set(Value, Alpha)
            end

            return Colorpicker, Items
        end

        Components.Keybind = function(self, Data)
            local Keybind = { 
                IsOpen = false,

                Key = "",
                Value = "",

                Flag = Data.Flag,

                Mode = "",

                Toggled = false,

                Picking = false
            }

            local KeylistItem

            if Library.KeyList then
                KeylistItem = Library.KeyList:Add("", "", "")
            end

            local Items = { } do
                Items["KeyButton"] = Instances:Create("TextButton", {
                    Parent = Data.Parent.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    TextTransparency = 0.4000000059604645,
                    Text = "MB2",
                    AutoButtonColor = false,
                    Size = UDim2New(0, 0, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["KeyButton"]:AddToTheme({TextColor3 = "Text"})
                
                Items["KeyButton"]:TextBorder()
                
                Items["KeybindWindow"] = Instances:Create("Frame", {
                    Parent = Library.UnusedHolder.Instance,
                    Name = "\0",
                    Position = UDim2New(0.007692307699471712, 0, 0.35323384404182434, 0),
                    BorderColor3 = FromRGB(12, 12, 12),
                    Size = UDim2New(0, 70, 0, 90),
                    BorderSizePixel = 2,
                    BackgroundColor3 = FromRGB(14, 17, 15)
                })  Items["KeybindWindow"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

                Items["Toggle"] = Instances:Create("TextButton", {
                    Parent = Items["KeybindWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "Toggle",
                    AutoButtonColor = false,
                    Position = UDim2New(0, 8, 0, 8),
                    Size = UDim2New(1, -16, 0, 20),
                    BorderSizePixel = 0,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(202, 243, 255)
                })  Items["Toggle"]:AddToTheme({BackgroundColor3 = "Accent", TextColor3 = "Text"})

                Items["Toggle"]:TextBorder()

                Instances:Create("UIStroke", {
                    Parent = Items["KeybindWindow"].Instance,
                    Name = "\0",
                    Color = FromRGB(42, 49, 45),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Outline"})

                Items["Hold"] = Instances:Create("TextButton", {
                    Parent = Items["KeybindWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "Hold",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 8, 0, 38),
                    Size = UDim2New(1, -16, 0, 20),
                    BorderSizePixel = 0,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(202, 243, 255)
                })  Items["Hold"]:AddToTheme({BackgroundColor3 = "Accent", TextColor3 = "Text"})

                Items["Hold"]:TextBorder()

                Items["Always"] = Instances:Create("TextButton", {
                    Parent = Items["KeybindWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "Always",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 8, 0, 68),
                    Size = UDim2New(1, -16, 0, 20),
                    BorderSizePixel = 0,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(202, 243, 255)
                })  Items["Always"]:AddToTheme({BackgroundColor3 = "Accent", TextColor3 = "Text"})  

                Items["Always"]:TextBorder()
            end

            local Modes = {
                ["Toggle"] = Items["Toggle"],
                ["Hold"] = Items["Hold"],
                ["Always"] = Items["Always"]
            }

            local Update = function()
                if KeylistItem then
                    KeylistItem:SetText(Keybind.Value, Data.Name, Keybind.Mode)
                    KeylistItem:SetStatus(Keybind.Toggled)
                end
            end

            function Keybind:Get()
                return Keybind.Key, Keybind.Mode, Keybind.Toggled
            end

            function Keybind:Set(Key)
                if StringFind(tostring(Key), "Enum") then 
                    Keybind.Key = tostring(Key)

                    Key = Key.Name == "Backspace" and "None" or Key.Name

                    local KeyString = Keys[Keybind.Key] or StringGSub(Key, "Enum.", "") or "None"
                    local TextToDisplay = StringGSub(StringGSub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None"

                    Keybind.Value = TextToDisplay
                    Items["KeyButton"].Instance.Text = TextToDisplay

                    Library.Flags[Keybind.Flag] = {
                        Mode = Keybind.Mode,
                        Key = Keybind.Key,
                        Toggled = Keybind.Toggled
                    }

                    if Data.Callback then 
                        Library:SafeCall(Data.Callback, Keybind.Toggled)
                    end

                    Update()
                elseif type(Key) == "table" then
                    local RealKey = Key.Key == "Backspace" and "None" or Key.Key
                    Keybind.Key = tostring(Key.Key)

                    if Key.Mode then
                        Keybind.Mode = Key.Mode
                        Keybind:SetMode(Key.Mode)
                    else
                        Keybind.Mode = "Toggle"
                        Keybind:SetMode("Toggle")
                    end

                    local KeyString = Keys[Keybind.Key] or StringGSub(tostring(RealKey), "Enum.", "") or RealKey
                    local TextToDisplay = KeyString and StringGSub(StringGSub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None"

                    TextToDisplay = StringGSub(StringGSub(KeyString, "KeyCode.", ""), "UserInputType.", "")

                    Keybind.Value = TextToDisplay
                    Items["KeyButton"].Instance.Text = TextToDisplay

                    if Data.Callback then 
                        Library:SafeCall(Data.Callback, Keybind.Toggled)
                    end

                    Update()
                elseif TableFind({"Toggle", "Hold", "Always"}, Key) then
                    Keybind.Mode = Key
                    Keybind:SetMode(Keybind.Mode)

                    if Data.Callback then 
                        Library:SafeCall(Data.Callback, Keybind.Toggled)
                    end

                    Update()
                end

                Keybind.Picking = false
            end

            local Debounce = false
            local RenderStepped  

            function Keybind:SetOpen(Bool)
                if Debounce then 
                    return
                end

                Keybind.IsOpen = Bool

                Debounce = true 

                if Keybind.IsOpen then 
                    Items["KeybindWindow"].Instance.Visible = true
                    Items["KeybindWindow"].Instance.Parent = Library.Holder.Instance
                    
                    RenderStepped = RunService.RenderStepped:Connect(function()
                        Items["KeybindWindow"].Instance.Position = UDim2New(0, Items["KeyButton"].Instance.AbsolutePosition.X, 0, Items["KeyButton"].Instance.AbsolutePosition.Y + Items["KeyButton"].Instance.AbsoluteSize.Y + 5)
                    end)

                    if not Debounce then 
                        for Index, Value in Library.OpenFrames do 
                            if Value ~= Keybind then 
                                Value:SetOpen(false)
                            end
                        end

                        Library.OpenFrames[Keybind] = Keybind 
                    end
                else
                    if not Debounce then 
                        if Library.OpenFrames[Keybind] then 
                            Library.OpenFrames[Keybind] = nil
                        end
                    end

                    if RenderStepped then 
                        RenderStepped:Disconnect()
                        RenderStepped = nil
                    end
                end

                local Descendants = Items["KeybindWindow"].Instance:GetDescendants()
                TableInsert(Descendants, Items["KeybindWindow"].Instance)

                local NewTween

                for Index, Value in Descendants do 
                    local TransparencyProperty = Tween:GetProperty(Value)

                    if not TransparencyProperty then
                        continue 
                    end

                    if type(TransparencyProperty) == "table" then 
                        for _, Property in TransparencyProperty do 
                            NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                    end
                end
                
                if NewTween then
                    NewTween.Tween.Completed:Connect(function()
                        Debounce = false 
                        Items["KeybindWindow"].Instance.Visible = Keybind.IsOpen
                        task.wait(0.2)
                        Items["KeybindWindow"].Instance.Parent = not Keybind.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
                end)
                else
                    Debounce = false
                    Library:Notification("Warning", "Skipped an animation (no tweenable elements found).", 3)
                end
            end

            function Keybind:SetMode(Mode)
                for Index, Value in Modes do 
                    if Index == Mode then
                        Value:Tween(nil, {BackgroundTransparency = 0})
                    else
                        Value:Tween(nil, {BackgroundTransparency = 1})
                    end
                end

                Library.Flags[Keybind.Flag] = {
                    Mode = Keybind.Mode,
                    Key = Keybind.Key,
                    Toggled = Keybind.Toggled
                }

                if Data.Callback then 
                    Library:SafeCall(Data.Callback, Keybind.Toggled)
                end

                Update()
            end

            function Keybind:Press(Bool)
                if Keybind.Mode == "Toggle" then 
                    Keybind.Toggled = not Keybind.Toggled
                elseif Keybind.Mode == "Hold" then 
                    Keybind.Toggled = Bool
                elseif Keybind.Mode == "Always" then 
                    Keybind.Toggled = true
                end

                Library.Flags[Keybind.Flag] = {
                    Mode = Keybind.Mode,
                    Key = Keybind.Key,
                    Toggled = Keybind.Toggled
                }

                if Data.Callback then 
                    Library:SafeCall(Data.Callback, Keybind.Toggled)
                end

                Update()
            end

            Items["KeyButton"]:Connect("MouseButton1Click", function()
                Keybind.Picking = true 

                Items["KeyButton"].Instance.Text = "."
                Library:Thread(function()
                    local Count = 1

                    while true do 
                        if not Keybind.Picking then 
                            break
                        end

                        if Count == 4 then
                            Count = 1
                        end

                        Items["KeyButton"].Instance.Text = Count == 1 and "." or Count == 2 and ".." or Count == 3 and "..."
                        Count += 1
                        task.wait(0.5)
                    end
                end)

                local InputBegan
                InputBegan = UserInputService.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.Keyboard then 
                        Keybind:Set(Input.KeyCode)
                    else
                        Keybind:Set(Input.UserInputType)
                    end

                    InputBegan:Disconnect()
                    InputBegan = nil
                end)
            end)

            Items["KeyButton"]:Connect("MouseButton2Down", function()
                Keybind:SetOpen(not Keybind.IsOpen)
            end)

            Library:Connect(UserInputService.InputBegan, function(Input)
                if Keybind.Value == "None" then
                    return
                end

                if tostring(Input.KeyCode) == Keybind.Key then
                    if Keybind.Mode == "Toggle" then 
                        Keybind:Press()
                    elseif Keybind.Mode == "Hold" then 
                        Keybind:Press(true)
                    elseif Keybind.Mode == "Always" then 
                        Keybind:Press(true)
                    end
                elseif tostring(Input.UserInputType) == Keybind.Key then
                    if Keybind.Mode == "Toggle" then 
                        Keybind:Press()
                    elseif Keybind.Mode == "Hold" then 
                        Keybind:Press(true)
                    elseif Keybind.Mode == "Always" then 
                        Keybind:Press(true)
                    end
                end

                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if not Keybind.IsOpen then
                        return
                    end

                    if Library:IsMouseOverFrame(Items["KeybindWindow"]) then
                        return
                    end

                    Keybind:SetOpen(false)
                end
            end)

            Library:Connect(UserInputService.InputEnded, function(Input)
                if Keybind.Value == "None" then
                    return
                end

                if tostring(Input.KeyCode) == Keybind.Key then
                    if Keybind.Mode == "Hold" then 
                        Keybind:Press(false)
                    elseif Keybind.Mode == "Always" then 
                        Keybind:Press(true)
                    end
                elseif tostring(Input.UserInputType) == Keybind.Key then
                    if Keybind.Mode == "Hold" then 
                        Keybind:Press(false)
                    elseif Keybind.Mode == "Always" then 
                        Keybind:Press(true)
                    end
                end
            end)

            Items["Toggle"]:Connect("MouseButton1Down", function()
                Keybind.Mode = "Toggle"
                Keybind:SetMode("Toggle")
            end)

            Items["Hold"]:Connect("MouseButton1Down", function()
                Keybind.Mode = "Hold"
                Keybind:SetMode("Hold")
            end)

            Items["Always"]:Connect("MouseButton1Down", function()
                Keybind.Mode = "Always"
                Keybind:SetMode("Always")
            end)

            if Data.Default then
                Keybind:Set({Key = Data.Default, Mode = Data.Mode or "Toggle"})
            end

            Library.SetFlags[Keybind.Flag] = function(Value)
                Keybind:Set(Value)
            end

            return Keybind, Items 
        end

        Components.Textbox = function(self, Data)
            local Textbox = {
                Flag = Data.Flag,
                Value = ""
            }

            local Items = { } do
                Items["Textbox"] = Instances:Create("Frame", {
                    Parent = Data.Parent.Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 40),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Textbox"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Data.Name,
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 0, 0, 15),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

                Items["Text"]:TextBorder()

                Items["Background"] = Instances:Create("Frame", {
                    Parent = Items["Textbox"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 0, 1, 0),
                    BorderColor3 = FromRGB(12, 12, 12),
                    Size = UDim2New(1, 0, 0, 20),
                    BorderSizePixel = 2,
                    BackgroundColor3 = FromRGB(30, 36, 31)
                })  Items["Background"]:AddToTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})

                Instances:Create("UIGradient", {
                    Parent = Items["Background"].Instance,
                    Name = "\0",
                    Rotation = -165,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(208, 208, 208))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, Library.Theme.Gradient)}
                end})

                Instances:Create("UIStroke", {
                    Parent = Items["Background"].Instance,
                    Name = "\0",
                    Color = FromRGB(42, 49, 45),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Outline"})

                Items["Input"] = Instances:Create("TextBox", {
                    Parent = Items["Background"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    PlaceholderColor3 = FromRGB(185, 185, 185),
                    PlaceholderText = Data.Placeholder,
                    TextSize = 9,
                    Size = UDim2New(1, 0, 1, 0),
                    ClipsDescendants = true,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    TextColor3 = FromRGB(235, 235, 235),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Position = UDim2New(0, 0, 0, 0),
                    ClearTextOnFocus = false,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Input"]:AddToTheme({TextColor3 = "Text", PlaceholderColor3 = "Placeholder Text"})

                Items["Input"]:TextBorder()

                Instances:Create("UIPadding", {
                    Parent = Items["Input"].Instance,
                    Name = "\0",
                    PaddingLeft = UDimNew(0, 8),
                    PaddingRight = UDimNew(0, 8)
                })
            end

            function Textbox:Get()
                return Textbox.Value
            end

            function Textbox:SetVisibility(Bool)
                Items["Textbox"].Instance.Visible = Bool
            end

            function Textbox:Set(Value)
                if Data.Numeric then
                    if (not tonumber(Value)) and StringLen(tostring(Value)) > 0 then
                        Value = Textbox.Value
                    end
                end

                Textbox.Value = Value
                Items["Input"].Instance.Text = Value
                Library.Flags[Textbox.Flag] = Value

                if Data.Callback then
                    Library:SafeCall(Data.Callback, Value)
                end
            end
            
            if Data.Finished then 
                Items["Input"]:Connect("FocusLost", function(PressedEnterQuestionMark)
                    if PressedEnterQuestionMark then
                        Textbox:Set(Items["Input"].Instance.Text)
                    end
                end)
            else
                Items["Input"].Instance:GetPropertyChangedSignal("Text"):Connect(function()
                    Textbox:Set(Items["Input"].Instance.Text)
                end)
            end

            if Data.Default then
                Textbox:Set(Data.Default)
            end

            Library.SetFlags[Textbox.Flag] = function(Value)
                Textbox:Set(Value)
            end

            return Textbox, Items
        end

        Components.Searchbox = function(self, Data) -- just pasted the entire dropdown fucntion with different instances, i cant be asked to make a whole new functionality
            local Dropdown = {
                Flag = Data.Flag, 
                Value = { },
                Options = { },
                IsOpen = false
            }

            local Items = { } do
                Items["Listbox"] = Instances:Create("Frame", {
                    Parent = Data.Parent.Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 185),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Items["Search"] = Instances:Create("Frame", {
                    Parent = Items["Listbox"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 0.4000000059604645,
                    Size = UDim2New(0, 0, 0, 20),
                    BorderColor3 = FromRGB(12, 12, 12),
                    BorderSizePixel = 2,
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = FromRGB(14, 17, 15)
                })  Items["Search"]:AddToTheme({BorderColor3 = "Border", BackgroundColor3 = "Background"})

                Instances:Create("UIStroke", {
                    Parent = Items["Search"].Instance,
                    Name = "\0",
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Transparency = 0.4000000059604645,
                    Color = FromRGB(42, 49, 45),
                    LineJoinMode = Enum.LineJoinMode.Miter
                }):AddToTheme({Color = "Outline"})

                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Search"].Instance,
                    Name = "\0",
                    ScaleType = Enum.ScaleType.Fit,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0.5),
                    Image = "rbxassetid://71197946135150",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    Size = UDim2New(0, 16, 0, 16),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Icon"]:AddToTheme({ImageColor3 = "Text"})

                Items["Input"] = Instances:Create("TextBox", {
                    Parent = Items["Search"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    Size = UDim2New(0, 0, 1, 0),
                    Position = UDim2New(0, 22, 0, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    PlaceholderColor3 = FromRGB(185, 185, 185),
                    AutomaticSize = Enum.AutomaticSize.X,
                    PlaceholderText = "search..",
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Input"]:AddToTheme({TextColor3 = "Text", PlaceholderColor3 = "Placeholder Text"})

                Items["Input"]:TextBorder()

                Instances:Create("UIPadding", {
                    Parent = Items["Search"].Instance,
                    Name = "\0",
                    PaddingRight = UDimNew(0, 5),
                    PaddingLeft = UDimNew(0, 3)
                })

                Items["RealListbox"] = Instances:Create("Frame", {
                    Parent = Items["Listbox"].Instance,
                    Name = "\0",
                    ClipsDescendants = true,
                    BorderColor3 = FromRGB(12, 12, 12),
                    Size = UDim2New(1, 0, 1, -28),
                    SelectionGroup = true,
                    Position = UDim2New(0, 0, 0, 28),
                    Selectable = true,
                    Active = true,
                    BorderSizePixel = 2,
                    BackgroundColor3 = FromRGB(30, 36, 31)
                })  Items["RealListbox"]:AddToTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})

                Instances:Create("UIStroke", {
                    Parent = Items["RealListbox"].Instance,
                    Name = "\0",
                    Color = FromRGB(42, 49, 45),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Outline"})

                Instances:Create("UIGradient", {
                    Parent = Items["RealListbox"].Instance,
                    Name = "\0",
                    Rotation = -165,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(208, 208, 208))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, Library.Theme.Gradient)}
                end})

                Items["List"] = Instances:Create("ScrollingFrame", {
                    Parent = Items["RealListbox"].Instance,
                    Name = "\0",
                    Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2New(0, 0, 0, 0),
                    ScrollBarImageColor3 = FromRGB(202, 243, 255),
                    MidImage = "rbxassetid://136419474381965",
                    BorderColor3 = FromRGB(0, 0, 0),
                    ScrollBarThickness = 2,
                    Size = UDim2New(1, -12, 1, -10),
                    Position = UDim2New(0, 3, 0, 5),
                    TopImage = "rbxassetid://136419474381965",
                    CanvasPosition = Vector2New(0, 57),
                    BottomImage = "rbxassetid://136419474381965",
                    BackgroundTransparency = 1,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["List"]:AddToTheme({ScrollBarImageColor3 = "Accent"})

                Instances:Create("UIListLayout", {
                    Parent = Items["List"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Instances:Create("UIPadding", {
                    Parent = Items["List"].Instance,
                    Name = "\0",
                    PaddingBottom = UDimNew(0, 8),
                    PaddingLeft = UDimNew(0, 5),
                })
            end

            function Dropdown:Get()
                return Dropdown.Value
            end

            function Dropdown:SetVisibility(Bool)
                Items["Listbox"].Instance.Visible = Bool
            end

            function Dropdown:Set(Option)
                if Data.Multi then 
                    if type(Option) ~= "table" then 
                        return
                    end

                    Dropdown.Value = Option
                    Library.Flags[Dropdown.Flag] = Option

                    for Index, Value in Option do
                        local OptionData = Dropdown.Options[Value]
                        
                        if not OptionData then
                            continue
                        end

                        OptionData.Selected = true 
                        OptionData:Toggle("Active")
                    end
                else
                    if not Dropdown.Options[Option] then
                        return
                    end

                    local OptionData = Dropdown.Options[Option]

                    Dropdown.Value = Option
                    Library.Flags[Dropdown.Flag] = Option

                    for Index, Value in Dropdown.Options do
                        if Value ~= OptionData then
                            Value.Selected = false 
                            Value:Toggle("Inactive")
                        else
                            Value.Selected = true 
                            Value:Toggle("Active")
                        end
                    end
                end

                if Data.Callback then   
                    Library:SafeCall(Data.Callback, Dropdown.Value)
                end
            end

            function Dropdown:Add(Option)
                local OptionButton = Instances:Create("TextButton", {
                    Parent = Items["List"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Option,
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2New(1, 0, 0, 20),
                    ZIndex = 1,
                    TextSize = 9,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  OptionButton:AddToTheme({TextColor3 = "Text"})

                OptionButton:TextBorder()

                local OptionData = {
                    Button = OptionButton,
                    Name = Option,
                    Selected = false
                }

                function OptionData:Toggle(Status)
                    if Status == "Active" then 
                        OptionData.Button:ChangeItemTheme({TextColor3 = "Accent"})
                        OptionData.Button:Tween(nil, {TextColor3 = Library.Theme.Accent})
                    else
                        OptionData.Button:ChangeItemTheme({TextColor3 = "Text"}) 
                        OptionData.Button:Tween(nil, {TextColor3 = Library.Theme.Text})
                    end
                end

                function OptionData:Set()
                    OptionData.Selected = not OptionData.Selected

                    if Data.Multi then 
                        local Index = TableFind(Dropdown.Value, OptionData.Name)

                        if Index then 
                            TableRemove(Dropdown.Value, Index)
                        else
                            TableInsert(Dropdown.Value, OptionData.Name)
                        end

                        OptionData:Toggle(Index and "Inactive" or "Active")

                        Library.Flags[Dropdown.Flag] = Dropdown.Value
                    else
                        if OptionData.Selected then 
                            Dropdown.Value = OptionData.Name
                            Library.Flags[Dropdown.Flag] = OptionData.Name

                            OptionData.Selected = true
                            OptionData:Toggle("Active")

                            for Index, Value in Dropdown.Options do 
                                if Value ~= OptionData then
                                    Value.Selected = false 
                                    Value:Toggle("Inactive")
                                end
                            end
                        else
                            Dropdown.Value = nil
                            Library.Flags[Dropdown.Flag] = nil

                            OptionData.Selected = false
                            OptionData:Toggle("Inactive")
                        end
                    end

                    if Data.Callback then
                        Library:SafeCall(Data.Callback, Dropdown.Value)
                    end
                end

                OptionData.Button:Connect("MouseButton1Down", function()
                    OptionData:Set()
                end)

                Dropdown.Options[OptionData.Name] = OptionData
                return OptionData
            end

            function Dropdown:Remove(Option)
                if not Dropdown.Options[Option] then
                    return
                end

                Dropdown.Options[Option].Button:Clean()
                Dropdown.Options[Option] = nil
            end

            function Dropdown:Refresh(List)
                for Index, Value in Dropdown.Options do 
                    Dropdown:Remove(Value.Name)
                end

                for Index, Value in List do 
                    Dropdown:Add(Value)
                end
            end

            Items["Listbox"]:OnHover(function()
                Items["Listbox"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element", BorderColor3 = "Border"})
                Items["Listbox"]:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
            end)

            Items["Listbox"]:OnHoverLeave(function()
                Items["Listbox"]:ChangeItemTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})
                Items["Listbox"]:Tween(nil, {BackgroundColor3 = Library.Theme["Element"]})
            end)

            local SearchStepped

            Items["Input"]:Connect("Focused", function()
                SearchStepped = RunService.RenderStepped:Connect(function()
                    for Index, Value in Dropdown.Options do
                        if Items["Input"].Instance.Text ~= "" then
                            if StringFind(StringLower(Value.Name), StringLower(Items["Input"].Instance.Text)) then
                                Value.Button.Instance.Visible = true
                            else
                                Value.Button.Instance.Visible = false
                            end
                        else
                            Value.Button.Instance.Visible = true
                        end
                    end
                end)
            end)

            Items["Input"]:Connect("FocusLost", function()
                if SearchStepped then
                    SearchStepped:Disconnect()
                    SearchStepped = nil
                end
            end)

            for Index, Value in Data.Items do 
                Dropdown:Add(Value)
            end

            if Data.Default then 
                Dropdown:Set(Data.Default)
            end

            Library.SetFlags[Dropdown.Flag] = function(Value)
                Dropdown:Set(Value)
            end

            return Dropdown, Items 
        end
    end

    -- Library components
	Library.Watermark = function(self, Name)
	    local Watermark = { }
	
	    local Items = { } do 
	        Items["Watermark"] = Instances:Create("Frame", {
	            Parent = Library.Holder.Instance,
	            Name = "\0",
	            AnchorPoint = Vector2New(0.5, 1),
	            Position = UDim2New(0.5, 0, 1, -1),
	            BorderColor3 = FromRGB(12, 12, 12),
	            BorderSizePixel = 2,
	            AutomaticSize = Enum.AutomaticSize.XY,
	            BackgroundColor3 = FromRGB(14, 17, 15)
	        })  Items["Watermark"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})
	
	        Items["Watermark"]:MakeDraggable()
	
	        Instances:Create("UIStroke", {
	            Parent = Items["Watermark"].Instance,
	            Name = "\0",
	            Color = FromRGB(42, 49, 45),
	            LineJoinMode = Enum.LineJoinMode.Miter,
	            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	        }):AddToTheme({Color = "Outline"})
	
	        Instances:Create("UIPadding", {
	            Parent = Items["Watermark"].Instance,
	            Name = "\0",
	            PaddingTop = UDimNew(0, 5),
	            PaddingBottom = UDimNew(0, 7),
	            PaddingRight = UDimNew(0, 5),
	            PaddingLeft = UDimNew(0, 5)
	        })
	
	        Items["Text"] = Instances:Create("TextLabel", {
	            Parent = Items["Watermark"].Instance,
	            Name = "\0",
	            FontFace = Library.Font,
	            TextColor3 = FromRGB(235, 235, 235),
	            BorderColor3 = FromRGB(0, 0, 0),
	            Text = Name .. " | 0 fps | 0 ms", -- Initial text with placeholder values
	            Position = UDim2New(0, 0, 0, 2),
	            BackgroundTransparency = 1,
	            TextXAlignment = Enum.TextXAlignment.Left,
	            BorderSizePixel = 0,
	            AutomaticSize = Enum.AutomaticSize.XY,
	            TextSize = 9,
	            BackgroundColor3 = FromRGB(255, 255, 255)
	        })  Items["Text"]:AddToTheme({TextColor3 = "Text"})
	
	        Items["Text"]:TextBorder()
	
	        Items["Liner"] = Instances:Create("Frame", {
	            Parent = Items["Watermark"].Instance,
	            Name = "\0",
	            Position = UDim2New(0, -5, 0, -5),
	            BorderColor3 = FromRGB(0, 0, 0),
	            Size = UDim2New(1, 10, 0, 1),
	            BorderSizePixel = 0,
	            BackgroundColor3 = FromRGB(202, 243, 255)
	        })  Items["Liner"]:AddToTheme({BackgroundColor3 = "Accent"})
	    end
	
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

-- Watermark FPS: use a simple frame counter reset every 0.5s (no O(n) table.remove)
local wmFrameCount = 0
local wmLastTime   = tick()
local wmCachedFPS  = 0
local wmLastPing   = 0
local wmUpdateInterval = 0.5  -- update display twice per second
local wmLastDisplayUpdate = 0

-- Function to get ping (in milliseconds)
local function getPing()
    local pingStat = Stats:FindFirstChild("PerformanceStats") and Stats.PerformanceStats:FindFirstChild("Ping")
    if pingStat then
        return math.floor(pingStat:GetValue())
    else
        return 0
    end
end

-- Start watermark update loop (single Heartbeat, lightweight frame counter)
-- Tracked via Library:Connect so Library:Unload() (and the Panic button)
-- actually disconnects it instead of leaving it running forever.
Library:Connect(RunService.Heartbeat, function()
    wmFrameCount += 1
    local now = tick()
    if now - wmLastDisplayUpdate >= wmUpdateInterval then
        local elapsed = now - wmLastTime
        wmCachedFPS = elapsed > 0 and math.round(wmFrameCount / elapsed) or 0
        wmLastPing   = getPing()
        wmFrameCount = 0
        wmLastTime   = now
        wmLastDisplayUpdate = now
        if Items["Text"] and Items["Text"].Instance then
            Items["Text"].Instance.Text = string.format("%s | %d fps | %d ms", Name, wmCachedFPS, wmLastPing)
        end
    end
end)



	
	    function Watermark:SetVisibility(Bool)
	        Items["Watermark"].Instance.Visible = Bool
	    end
	
	    return Watermark
	end

    Library.KeybindList = function(self)
        local KeybindList = { }
        Library.KeyList = KeybindList

        local Items = { } do
            Items["KeybindList"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                Name = "\0",
                AnchorPoint = Vector2New(0, 0.5),
                Position = UDim2New(0, 12, 0.5, 55),
                BorderColor3 = FromRGB(12, 12, 12),
                Size = UDim2New(0, 116, 0, 32),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(14, 17, 15)
            })  Items["KeybindList"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Items["KeybindList"]:MakeDraggable()

            Instances:Create("UIStroke", {
                Parent = Items["KeybindList"].Instance,
                Name = "\0",
                Color = FromRGB(42, 49, 45),
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Outline"})

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["KeybindList"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(235, 235, 235),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "Keybinds",
                Size = UDim2New(0, 0, 0, 20),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0, -4),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 9,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Items["Title"]:TextBorder()

            Instances:Create("UIPadding", {
                Parent = Items["KeybindList"].Instance,
                Name = "\0",
                PaddingTop = UDimNew(0, 8),
                PaddingBottom = UDimNew(0, 8),
                PaddingRight = UDimNew(0, 8),
                PaddingLeft = UDimNew(0, 8)
            })

            Items["Liner"] = Instances:Create("Frame", {
                Parent = Items["KeybindList"].Instance,
                Name = "\0",
                Position = UDim2New(0, 0, 0, 15),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(202, 243, 255)
            })  Items["Liner"]:AddToTheme({BackgroundColor3 = "Accent"})

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["KeybindList"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0, 32),
                Size = UDim2New(1, 0, 0, 0),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Content"].Instance,
                Name = "\0",
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        end

        function KeybindList:Add(Key, Name, Mode)
            local NewKey = Instances:Create("TextLabel", {
                Parent = Items["Content"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(235, 235, 235),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "" ..Key .." - " ..Name .. " ("..Mode..")",
                BackgroundTransparency = 1,
                Size = UDim2New(0, 0, 0, 15),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextTransparency = 1,
                Visible = false,
                TextSize = 9,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  NewKey:AddToTheme({TextColor3 = "Text"})

            NewKey:TextBorder()

            function NewKey:SetText(Key, Name, Mode)
                NewKey.Instance.Text = "" ..Key .." - " ..Name .. " ("..Mode..")"
            end

            function NewKey:SetStatus(Bool)
                if Bool then
                    NewKey.Instance.Visible = true
                    NewKey:Tween(nil, {TextTransparency = 0})
                else
                    NewKey:Tween(nil, {TextTransparency = 1}).Tween.Completed:Connect(function()
                        NewKey.Instance.Visible = false
                    end)
                end
            end

            return NewKey
        end

        function KeybindList:SetVisibility(Bool)
            Items["KeybindList"].Instance.Visible = Bool
        end

        return KeybindList
    end

    Library.Notification = function(self, Title, Description, Duration)
        local Items = { } do 
            Items["Notification"] = Instances:Create("Frame", {
                Parent = Library.NotifHolder.Instance,
                Name = "\0",
                Size = UDim2New(0, 0, 0, 25),
                BorderColor3 = FromRGB(12, 12, 12),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundColor3 = FromRGB(14, 17, 15)
            })  Items["Notification"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Items["UIStroke1"] = Instances:Create("UIStroke", {
                Parent = Items["Notification"].Instance,
                Name = "\0",
                Color = FromRGB(42, 49, 45),
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            })  Items["UIStroke1"]:AddToTheme({Color = "Outline"})

            Instances:Create("UIPadding", {
                Parent = Items["Notification"].Instance,
                Name = "\0",
                PaddingTop = UDimNew(0, 5),
                PaddingBottom = UDimNew(0, 12),
                PaddingRight = UDimNew(0, 5),
                PaddingLeft = UDimNew(0, 5)
            })

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["Notification"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(235, 235, 235),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Title,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.XY,
                TextSize = 9,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

           Items["UIStroke2"] =  Items["Title"]:TextBorder()

            Items["Description"] = Instances:Create("TextLabel", {
                Parent = Items["Notification"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(235, 235, 235),
                TextTransparency = 0.4000000059604645,
                Text = Description,
                Position = UDim2New(0, 0, 0, 15),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderColor3 = FromRGB(0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.XY,
                TextSize = 9,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Description"]:AddToTheme({TextColor3 = "Text"})

            Items["UIStroke3"] = Items["Description"]:TextBorder()

            Items["Liner"] = Instances:Create("Frame", {
                Parent = Items["Notification"].Instance,
                Name = "\0",
                Position = UDim2New(0, 0, 1, 8),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(202, 243, 255)
            })  Items["Liner"]:AddToTheme({BackgroundColor3 = "Accent"})
        end

        local Size = Items["Notification"].Instance.AbsoluteSize

        for Index, Value in Items do 
            if Value.Instance:IsA("Frame") then
                Value.Instance.BackgroundTransparency = 1
            elseif Value.Instance:IsA("TextLabel") then 
                Value.Instance.TextTransparency = 1
            elseif Value.Instance:IsA("UIStroke") then
                Value.Instance.Transparency = 1
            end
        end 

        Items["Notification"].Instance.AutomaticSize = Enum.AutomaticSize.Y

        Library:Thread(function()
            for Index, Value in Items do 
                if Value.Instance:IsA("Frame") then
                    Value:Tween(nil, {BackgroundTransparency = 0})
                elseif Value.Instance:IsA("TextLabel") and Index ~= "Description" then 
                    Value:Tween(nil, {TextTransparency = 0})
                elseif Value.Instance:IsA("TextLabel") and Index == "Description" then 
                    Value:Tween(nil, {TextTransparency = 0.4})
                elseif Value.Instance:IsA("UIStroke") then
                    Value:Tween(nil, {Transparency = 0})
                end
            end

            Items["Notification"]:Tween(nil, {Size = UDim2New(0, Size.X, 0, 0)})
            Items["Liner"]:Tween(TweenInfo.new(Duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2New(0, 0, 0, 1)})
            
            task.delay(Duration + 0.1, function()
                for Index, Value in Items do 
                    if Value.Instance:IsA("Frame") then
                        Value:Tween(nil, {BackgroundTransparency = 1})
                    elseif Value.Instance:IsA("TextLabel") then 
                        Value:Tween(nil, {TextTransparency = 1})
                    elseif Value.Instance:IsA("UIStroke") then
                        Value:Tween(nil, {Transparency = 1})
                    end
                end

                Items["Notification"]:Tween(nil, {Size = UDim2New(0, 0, 0, 0)})
                task.wait(0.5)
                Items["Notification"]:Clean()
            end)
        end)
    end

    Library.InventoryViewer = function(self)
        local Viewer = { }
        Viewer.Items = { } 

        local Items = { } do
            Items["InventoryViewer"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                Name = "\0",
                Position = UDim2New(0.007766990456730127, 0, 0.11442785710096359, 0),
                BorderColor3 = FromRGB(12, 12, 12),
                Size = UDim2New(0, 325, 0, 277),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(14, 17, 15)
            })  Items["InventoryViewer"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["InventoryViewer"].Instance,
                Name = "\0",
                Color = FromRGB(42, 49, 45),
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Outline"})

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["InventoryViewer"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(235, 235, 235),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "Inventory",
                Size = UDim2New(0, 0, 0, 15),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 8, 0, 4),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 9,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Items["Tools"] = Instances:Create("Frame", {
                Parent = Items["InventoryViewer"].Instance,
                Name = "\0",
                Position = UDim2New(0, 8, 0, 27),
                BorderColor3 = FromRGB(42, 49, 45),
                Size = UDim2New(1, -16, 1, -108),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(20, 24, 21)
            })  Items["Tools"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Outline"})

            Instances:Create("UIStroke", {
                Parent = Items["Tools"].Instance,
                Name = "\0",
                Color = FromRGB(12, 12, 12),
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Border"})

            Items["Holder"] = Instances:Create("ScrollingFrame", {
                Parent = Items["Tools"].Instance,
                Name = "\0",
                Active = true,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0,
                CanvasSize = UDim2New(0, 0, 0, 0),
                ScrollBarImageColor3 = FromRGB(202, 243, 255),
                MidImage = "rbxassetid://123708228368098",
                BorderColor3 = FromRGB(0, 0, 0),
                ScrollBarThickness = 2,
                Size = UDim2New(1, -4, 1, -8),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0, 4),
                BottomImage = "rbxassetid://123708228368098",
                TopImage = "rbxassetid://123708228368098",
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Holder"]:AddToTheme({ScrollBarImageColor3 = "Accent"})

            Instances:Create("UIGridLayout", {
                Parent = Items["Holder"].Instance,
                Name = "\0",
                SortOrder = Enum.SortOrder.LayoutOrder,
                CellSize = UDim2New(0, 65, 0, 65)
            })

            Instances:Create("UIPadding", {
                Parent = Items["Holder"].Instance,
                Name = "\0",
                PaddingTop = UDimNew(0, 4),
                PaddingLeft = UDimNew(0, 8)
            })

            Items["PlayerAvatar"] = Instances:Create("ImageLabel", {
                Parent = Items["InventoryViewer"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(42, 49, 45),
                AnchorPoint = Vector2New(0, 1),
                Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
                Position = UDim2New(0, 8, 1, -8),
                Size = UDim2New(0, 60, 0, 60),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(14, 17, 15)
            })  Items["PlayerAvatar"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Outline"})

            Instances:Create("UIStroke", {
                Parent = Items["PlayerAvatar"].Instance,
                Name = "\0",
                Color = FromRGB(12, 12, 12),
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Outline"})
            
            Items["PlayerHealth"] = Instances:Create("TextLabel", {
                Parent = Items["InventoryViewer"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(235, 235, 235),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "Health: ",
                AnchorPoint = Vector2New(0, 1),
                Size = UDim2New(0, 0, 0, 15),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 75, 1, -55),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 9,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["PlayerHealth"]:AddToTheme({TextColor3 = "Text"})

            Items["PlayerDistance"] = Instances:Create("TextLabel", {
                Parent = Items["InventoryViewer"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(235, 235, 235),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "Distance:  studs",
                AnchorPoint = Vector2New(0, 1),
                Size = UDim2New(0, 0, 0, 15),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 75, 1, -35),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 9,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["PlayerDistance"]:AddToTheme({TextColor3 = "Text"})
        end

        function Viewer:SetPlayerHealth(Value)
            Items["PlayerHealth"].Instance.Text = tostring(Value)
        end

        function Viewer:SetPlayerDistance(Value)
            Items["PlayerDistance"].Instance.Text = "Distance: "..tostring(Value).." studs"
        end

        function Viewer:SetPlayer(Value)
            local PlayerAvatar, _ = Players:GetUserThumbnailAsync(Value.UserId)
            Items["PlayerAvatar"].Instance.Image = PlayerAvatar
            Items["Title"].Instance.Text = Value.Name .. "'s Inventory"
        end

        function Viewer:AddTool(Name, Image)
            local NewItem = { }

            local SubItems = { } do
                SubItems["Item"] = Instances:Create("Frame", {
                    Parent = Items["Holder"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(12, 12, 12),
                    Size = UDim2New(0, 100, 0, 100),
                    BorderSizePixel = 2,
                    BackgroundColor3 = FromRGB(20, 24, 21)
                })  SubItems["Item"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Border"})

                Instances:Create("UIStroke", {
                    Parent = SubItems["Item"].Instance,
                    Name = "\0",
                    Color = FromRGB(42, 49, 45),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Outline"})

                SubItems["Image"] = Instances:Create("ImageLabel", {
                    Parent = SubItems["Item"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(202, 243, 255),
                    ScaleType = Enum.ScaleType.Fit,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "rbxassetid://"..Image,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(0, 45, 0, 45),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  SubItems["Image"]:AddToTheme({ImageColor3 = "Accent"})
            end

            function NewItem:Remove()
                Viewer.Items[Name] = nil
                SubItems["Item"]:Clean()
            end

            Viewer.Items[Name] = NewItem
            return NewItem
        end

        function Viewer:RemoveAllTools()
            for Index, Value in Viewer.Items do 
                Value:Remove()
            end
        end

        return Viewer
    end

    Library.Window = function(self, Data)
        Data = Data or { }

        local Window = { 
            Logo = Data.Logo or Data.logo or "",
            FadeTime = Data.FadeTime or Data.fadetime or 0.4,
            Size = Data.Size or Data.size or UDim2New(0, 751, 0, 539),

            -- Resize limits
            MinSize = Data.MinSize or Data.minsize or nil,
            MaxSize = Data.MaxSize or Data.maxsize or nil,

            -- [Feature: Title] Developer-supplied title
            Title = Data.Title or Data.title or "",
            DevName = Data.DevName or Data.devname or "Dev",
            TitlePosition = Data.TitlePosition or Data.titleposition or "Topbar",

            -- [Feature: Credits]
            Credits = Data.Credits or Data.credits or { },

            -- [Feature: Config Export] Per-window override
            AllowConfigExport = (Data.AllowConfigExport ~= nil) and Data.AllowConfigExport
                             or (Data.allowconfigexport ~= nil) and Data.allowconfigexport
                             or Library.AllowConfigExport,

            Pages = { },
            Items = { },

            IsOpen = false,
            IsMinimized = false,
        }

        -- [Feature: Folder Structure] Build per-hub per-game directories when dev info is supplied
        if Window.Title ~= "" or Window.DevName ~= "Dev" then
            Library:BuildFolderPaths(
                Window.Title ~= "" and Window.Title or "Script",
                Window.DevName
            )
        end

        -- [Feature: Multi-instance Safety] Same creator + title + game re-running
        -- this script replaces its own previous window; other hubs are untouched.
        do
            local InstanceKey = tostring(Window.DevName) .. "::" .. tostring(Window.Title ~= "" and Window.Title or "Script") .. "::" .. tostring(game.PlaceId)
            local Registry = getgenv().Adytum_Instances

            if Registry[InstanceKey] then
                pcall(Registry[InstanceKey])
            end

            Registry[InstanceKey] = function()
                Library:Unload()
            end
        end

        -- Store window metadata in Library so CreateSettingsPage can access it
        Library.TitleText        = Window.Title
        Library.TitlePosition    = Window.TitlePosition
        Library.Credits          = Window.Credits
        Library.AllowConfigExport = Window.AllowConfigExport

        local Items = Components:Window({
            Parent = Library.Holder,
            Draggable = true,
            Resizeable = true,
            AnchorPoint = Vector2New(0, 0),
            Position = UDim2New(0, Camera.ViewportSize.X / 3.3, 0, Camera.ViewportSize.Y / 3.3),
            Size = Window.Size,
            MinSize = Window.MinSize,
            MaxSize = Window.MaxSize
        }) do
            Items["Side"] = Instances:Create("Frame", {
                Parent = Items["Window"].Instance,
                Name = "\0",
                Position = UDim2New(0, 12, 0, 42),
                BorderColor3 = FromRGB(16, 28, 44),
                Size = UDim2New(0, 200, 1, -54),
                BorderSizePixel = 2,
                BackgroundTransparency = 0.25,
                BackgroundColor3 = FromRGB(12, 22, 36)
            })  Items["Side"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Outline"})
            
            Items["Side"]:Border("Border")

            Items["Window"].Instance.Visible = false

            -- ── [Feature: Topbar] ─────────────────────────────────────────────
            -- Slim 30-px bar at the top of the window. Acts as:
            --   • Secondary drag handle
            --   • Title display area (when TitlePosition == "Topbar")
            --   • Minimise toggle
            Items["Topbar"] = Instances:Create("Frame", {
                Parent = Items["Window"].Instance,
                Name = "\0",
                Position = UDim2New(0, 0, 0, 0),
                Size = UDim2New(1, 0, 0, 30),
                BorderSizePixel = 0,
                ZIndex = 5,
                BackgroundTransparency = 0.05,
                BackgroundColor3 = FromRGB(6, 12, 20)
            })  Items["Topbar"]:AddToTheme({BackgroundColor3 = "Background"})

            -- Topbar bottom accent line
            Items["TopbarLiner"] = Instances:Create("Frame", {
                Parent = Items["Topbar"].Instance,
                Name = "\0",
                AnchorPoint = Vector2New(0, 1),
                Position = UDim2New(0, 0, 1, 0),
                Size = UDim2New(1, 0, 0, 1),
                BorderSizePixel = 0,
                ZIndex = 6,
                BackgroundColor3 = FromRGB(58, 138, 224)
            })  Items["TopbarLiner"]:AddToTheme({BackgroundColor3 = "Accent"})

            -- Title label in the topbar
            Items["TopbarTitle"] = Instances:Create("TextLabel", {
                Parent = Items["Topbar"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                Text = Window.Title,
                TextColor3 = FromRGB(222, 236, 248),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                AnchorPoint = Vector2New(0, 0.5),
                Position = UDim2New(0, 12, 0.5, 0),
                Size = UDim2New(1, -60, 0, 16),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 6,
                TextSize = 11,
                BackgroundColor3 = FromRGB(255, 255, 255),
                Visible = Window.TitlePosition == "Topbar"
            })  Items["TopbarTitle"]:AddToTheme({TextColor3 = "Text"})
            Items["TopbarTitle"]:TextBorder()

            -- Minimise button [—]
            Items["MinimizeBtn"] = Instances:Create("TextButton", {
                Parent = Items["Topbar"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                Text = "—",
                TextColor3 = FromRGB(138, 160, 184),
                AutoButtonColor = false,
                AnchorPoint = Vector2New(1, 0.5),
                Position = UDim2New(1, -8, 0.5, 0),
                Size = UDim2New(0, 26, 0, 22),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 6,
                TextSize = 16,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["MinimizeBtn"]:AddToTheme({TextColor3 = "Placeholder Text"})
            Items["MinimizeBtn"]:TextBorder()

            -- Topbar as secondary drag handle (moves the parent window frame)
            do
                local WinGui = Items["Window"].Instance
                local Dragging = false
                local DragStart, StartPos

                Items["Topbar"]:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1
                    or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging  = true
                        DragStart = Input.Position
                        StartPos  = WinGui.Position
                        Input.Changed:Connect(function()
                            if Input.UserInputState == Enum.UserInputState.End then
                                Dragging = false
                            end
                        end)
                    end
                end)

                Library:Connect(UserInputService.InputChanged, function(Input)
                    if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement
                    or Input.UserInputType == Enum.UserInputType.Touch) then
                        local Delta = Input.Position - DragStart
                        WinGui.Position = UDim2New(
                            StartPos.X.Scale, StartPos.X.Offset + Delta.X,
                            StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y
                        )
                    end
                end)
            end

            -- Minimise / restore
            do
                local FullSize = Window.Size

                Items["MinimizeBtn"]:Connect("MouseButton1Down", function()
                    Window.IsMinimized = not Window.IsMinimized
                    if Window.IsMinimized then
                        Items["Window"].Instance:TweenSize(
                            UDim2New(0, FullSize.X.Offset, 0, 30),
                            Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true
                        )
                        Items["MinimizeBtn"].Instance.Text = "□"
                        if Items["ResizeButton"] then
                            Items["ResizeButton"].Instance.Visible = false
                        end

                        -- Side (tabs + profile) and Content (pages: Settings,
                        -- Credits, Configs...) are sized relative to the window
                        -- and go negative once it shrinks to 30px, which used
                        -- to leave a sliver of the profile visible and broke
                        -- the pages inside. Just hide them outright instead.
                        Items["Side"].Instance.Visible = false
                        Items["Content"].Instance.Visible = false
                    else
                        Items["Window"].Instance:TweenSize(
                            FullSize,
                            Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true
                        )
                        Items["MinimizeBtn"].Instance.Text = "—"
                        if Items["ResizeButton"] then
                            Items["ResizeButton"].Instance.Visible = true
                        end

                        Items["Side"].Instance.Visible = true
                        Items["Content"].Instance.Visible = true
                    end
                end)

                Items["MinimizeBtn"]:OnHover(function()
                    Items["MinimizeBtn"]:Tween(nil, {TextColor3 = Library.Theme.Accent})
                end)
                Items["MinimizeBtn"]:OnHoverLeave(function()
                    Items["MinimizeBtn"]:Tween(nil, {TextColor3 = Library.Theme["Placeholder Text"]})
                end)
            end
            -- ── end Topbar ────────────────────────────────────────────────────

            Items["Logo"] = Instances:Create("ImageLabel", {
                Parent = Items["Side"].Instance,
                Name = "\0",
                ImageColor3 = FromRGB(202, 243, 255),
                ScaleType = Enum.ScaleType.Fit,
                BorderColor3 = FromRGB(0, 0, 0),
                AnchorPoint = Vector2New(0.5, 0),
                Image = "rbxassetid://" .. Window.Logo,
                BackgroundTransparency = 1,
                Position = UDim2New(0.5, 0, 0, 12),
                Size = UDim2New(0, 75, 0, 75),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Logo"]:AddToTheme({ImageColor3 = "Accent"})

            -- [Feature: Title] Title label rendered below the logo (TitlePosition == "Logo")
            Items["LogoTitle"] = Instances:Create("TextLabel", {
                Parent = Items["Side"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                Text = Window.Title,
                TextColor3 = FromRGB(222, 236, 248),
                AnchorPoint = Vector2New(0.5, 0),
                Position = UDim2New(0.5, 0, 0, 92),
                Size = UDim2New(1, -16, 0, 14),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextTruncate = Enum.TextTruncate.AtEnd,
                BorderSizePixel = 0,
                TextSize = 10,
                BackgroundColor3 = FromRGB(255, 255, 255),
                Visible = Window.TitlePosition == "Logo"
            })  Items["LogoTitle"]:AddToTheme({TextColor3 = "Text"})
            Items["LogoTitle"]:TextBorder()

            -- Helper called by Settings "Title Position" dropdown
            local function ApplyTitlePosition(Position)
                Library.TitlePosition = Position
                if Position == "Topbar" then
                    Items["TopbarTitle"].Instance.Visible = true
                    Items["LogoTitle"].Instance.Visible   = false
                elseif Position == "Logo" then
                    Items["TopbarTitle"].Instance.Visible = false
                    Items["LogoTitle"].Instance.Visible   = true
                else  -- "None"
                    Items["TopbarTitle"].Instance.Visible = false
                    Items["LogoTitle"].Instance.Visible   = false
                end
            end
            ApplyTitlePosition(Window.TitlePosition)
            Window.ApplyTitlePosition = ApplyTitlePosition

            Items["Pages"] = Instances:Create("Frame", {
                Parent = Items["Side"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0, 100),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 1, -174),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIPadding", {
                Parent = Items["Pages"].Instance,
                Name = "\0",
                PaddingRight = UDimNew(0, 8),
                PaddingLeft = UDimNew(0, 8)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Pages"].Instance,
                Name = "\0",
                Padding = UDimNew(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            local Content, _ = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

            -- Player profile block: sits below the tab list, shows photo,
            -- username, and user ID underneath the username. Not optional.
            Items["Profile"] = Instances:Create("Frame", {
                Parent = Items["Side"].Instance,
                Name = "\0",
                BackgroundTransparency = 0.25,
                BorderColor3 = FromRGB(16, 28, 44),
                AnchorPoint = Vector2New(0, 1),
                Position = UDim2New(0, 6, 1, -6),
                Size = UDim2New(1, -12, 0, 54),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(12, 22, 36)
            })  Items["Profile"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Outline"})

            Items["Profile"]:Border("Border")

            Items["ProfileAvatar"] = Instances:Create("ImageLabel", {
                Parent = Items["Profile"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                AnchorPoint = Vector2New(0, 0.5),
                Image = Content,
                BackgroundTransparency = 1,
                Position = UDim2New(0, 8, 0.5, 0),
                Size = UDim2New(0, 38, 0, 38),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["ProfileAvatar"]:Border("Outline").Instance.LineJoinMode = Enum.LineJoinMode.Round

            Instances:Create("UICorner", {
                Parent = Items["ProfileAvatar"].Instance,
                Name = "\0",
                CornerRadius = UDimNew(1, 0)
            })

            Items["ProfileUsername"] = Instances:Create("TextLabel", {
                Parent = Items["Profile"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(222, 236, 248),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = LocalPlayer.Name,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2New(0, 54, 0, 9),
                Size = UDim2New(1, -60, 0, 14),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["ProfileUsername"]:AddToTheme({TextColor3 = "Text"})

            Items["ProfileUsername"]:TextBorder()

            Items["ProfileUserId"] = Instances:Create("TextLabel", {
                Parent = Items["Profile"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(138, 160, 184),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = tostring(LocalPlayer.UserId),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2New(0, 54, 0, 27),
                Size = UDim2New(1, -60, 0, 12),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                TextSize = 9,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["ProfileUserId"]:AddToTheme({TextColor3 = "Placeholder Text"})

            -- [Feature: Unknown Mode] Real values kept so we can restore them
            -- if the user turns the toggle back off. What actually happens
            -- when it's turned on ("Placeholder" vs "Hidden") is decided by
            -- the dev via Library.UnknownModeStyle, not by the loading script.
            local RealAvatar   = Content
            local RealUsername = LocalPlayer.Name
            local RealUserId   = tostring(LocalPlayer.UserId)
            local ProfileVisibleSize = Items["Pages"].Instance.Size

            local function ApplyUnknownMode(Bool)
                if not Library.AllowUnknownMode then
                    return
                end

                if Library.UnknownModeStyle == "Hidden" then
                    Items["Profile"].Instance.Visible = not Bool
                    -- Reclaim the space the profile box occupied when it's
                    -- hidden, so the tab list isn't left with a dead gap.
                    Items["Pages"].Instance.Size = Bool
                        and UDim2New(1, 0, 1, -114)
                        or ProfileVisibleSize
                else -- "Placeholder"
                    Items["Profile"].Instance.Visible = true
                    Items["Pages"].Instance.Size = ProfileVisibleSize
                    Items["ProfileAvatar"].Instance.Image = Bool and "rbxasset://textures/ui/GuiImagePlaceholder.png" or RealAvatar
                    Items["ProfileUsername"].Instance.Text = Bool and "Unknown" or RealUsername
                    Items["ProfileUserId"].Instance.Text = Bool and "XX00XX00" or RealUserId
                end
            end

            Window.ApplyUnknownMode = ApplyUnknownMode

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["Window"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 226, 0, 42),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -238, 1, -54),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["MouseBackground"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0, 16, 0, 16),
                BorderSizePixel = 0,
                ZIndex = 9999,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["MouseImage"] = Instances:Create("ImageLabel", {
                Parent = Items["MouseBackground"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Image = "rbxassetid://76631660114196",
                BackgroundTransparency = 1,
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                ZIndex = 9999,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["MouseImage"]:AddToTheme({ImageColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["MouseImage"].Instance,
                Name = "\0",
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(99, 108, 117))}
            })

            UserInputService.MouseIconEnabled = false

            Window.Items = Items
        end

        local Debounce = false

        -- Track mouse cursor only while the color picker window is open
        local MouseTrackConn
        local function startMouseTracking()
            if MouseTrackConn then return end
            MouseTrackConn = RunService.RenderStepped:Connect(function()
                local MouseLocation = UserInputService:GetMouseLocation()
                Items["MouseBackground"].Instance.Position = UDim2New(0, MouseLocation.X - 1, 0, MouseLocation.Y - 56)
            end)
        end
        local function stopMouseTracking()
            if MouseTrackConn then
                MouseTrackConn:Disconnect()
                MouseTrackConn = nil
            end
        end
        -- Patch SetOpen to start/stop tracking with visibility
        local _origSetOpen = Window.SetOpen
        Window.SetOpen = function(self, Bool)
            if Bool then startMouseTracking() else stopMouseTracking() end
            return _origSetOpen(self, Bool)
        end
        startMouseTracking() -- start now since window opens immediately after

        local OldSizes = { }

        function Window:AddToOldSizes(Item, Size)
            if not OldSizes[Item] then
                OldSizes[Item] = Size
            end
        end

        function Window:GetOldSize(Item)
            if OldSizes[Item] then
                return OldSizes[Item]
            end
        end

        function Window:SetOpen(Bool)
            if Debounce then 
                return
            end

            Window.IsOpen = Bool

            Debounce = true 

            if Window.IsOpen then 
                Items["Window"].Instance.Visible = true 
            end

            local Descendants = Items["Window"].Instance:GetDescendants()
            TableInsert(Descendants, Items["Window"].Instance)

            local NewTween

            for Index, Value in Descendants do 
                local TransparencyProperty = Tween:GetProperty(Value)

                if not TransparencyProperty then
                    continue 
                end

                if type(TransparencyProperty) == "table" then 
                    for _, Property in TransparencyProperty do 
                        NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                    end
                else
                    NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                end
            end
            
            if NewTween then
                NewTween.Tween.Completed:Connect(function()
                    Debounce = false 
                    Items["Window"].Instance.Visible = Window.IsOpen
                    if Window.IsOpen then
                        Items["MouseBackground"].Instance.Visible = true
                        UserInputService.MouseIconEnabled = false
                    else
                        Items["MouseBackground"].Instance.Visible = false
                        UserInputService.MouseIconEnabled = true
                    end
            end)
            else
                Debounce = false
                Library:Notification("Warning", "Skipped an animation (no tweenable elements found).", 3)
            end
        end

        Library:Connect(UserInputService.InputBegan, function(Input)
            if tostring(Input.KeyCode) == Library.MenuKeybind or tostring(Input.UserInputType) == Library.MenuKeybind then
                Window:SetOpen(not Window.IsOpen)
            end
        end)

        Window:SetOpen(true)

        setmetatable(Window, self)

        -- Settings tab is mandatory and ALWAYS goes last, no matter how many
        -- other pages the script adds afterward, and this cannot be disabled
        -- or reordered from outside the library. We defer its creation with
        -- task.defer so it runs only after the rest of the calling script's
        -- current execution (i.e. every Window:Page(...) call the user makes
        -- right after Window(...) returns) has finished, which guarantees
        -- the Settings tab button is the last child added to the tab list.
        task.defer(function()
            local AutoWatermark = Library:Watermark("")
            local AutoKeybindList = Library:KeybindList()

            Window.Watermark = AutoWatermark
            Window.KeybindList = AutoKeybindList

            Library:CreateSettingsPage(Window, AutoWatermark, AutoKeybindList)
        end)

        return Window
    end

    Library.Page = function(self, Data)
        Data = Data or { }

        local Page = {
            Window = self,

            Name = Data.Name or Data.name or "Page",
            Columns = Data.Columns or Data.columns or 2,
            SubPages = Data.SubPages or Data.subpages or false,
            -- "Auto" (default): subpages bar grows to fit its buttons, up to
            -- the full page width, then scrolls. "Full": bar is always fully
            -- expanded (legacy behavior).
            SubPagesMode = Data.SubPagesMode or Data.subpagesmode or "Auto",
        }

        -- [Feature: Settings Always Last] Side buttons sort by LayoutOrder
        -- (see Components.WindowPage), so every page created here gets an
        -- incrementing order matching creation order -- except the mandatory
        -- Settings page (CreateSettingsPage passes PinLast = true below),
        -- which always gets the max int32 instead (LayoutOrder is a 32-bit
        -- int property, so math.huge/inf isn't valid here). This keeps
        -- Settings visually pinned to the bottom of the side buttons even
        -- though it's actually created via task.defer, regardless of how
        -- many pages/subpages the calling script adds, and in whatever
        -- order/timing it adds them.
        self.PageOrderCounter = (self.PageOrderCounter or 0) + 1
        local LayoutOrder = Data.PinLast and 2147483647 or self.PageOrderCounter

        Library.SearchItems[Page] = { }

        local NewPage, Items = Components:WindowPage({
            Name = Page.Name,
            ContentHolder = Page.Window.Items["Content"],
            Stack = Page.Window.Pages,
            Parent = Page.Window.Items["Pages"],
            Columns = Page.Columns,
            SubPages = Page.SubPages,
            SubPagesMode = Page.SubPagesMode,
            FadeTime = Page.Window.FadeTime,
            Window = Page.Window,
            LayoutOrder = LayoutOrder
        })

        return setmetatable(NewPage, Library.Pages)
    end

    Library.Pages.SubPage = function(self, Data)
        Data = Data or { }

        local SubPage = {
            Window = self.Window,
            Page = self,

            Name = Data.Name or Data.name or "SubPage",
            Columns = Data.Columns or Data.columns or 2,
        }

        Library.SearchItems[SubPage] = { }

        local NewSubPage, Items = Components:WindowSubPage({
            Page = SubPage.Page,
            Name = SubPage.Name,
            Columns = SubPage.Columns,
            Window = SubPage.Page.Window
        })

        return setmetatable(NewSubPage, Library.Pages)
    end

    Library.Pages.Section = function(self, Data)
        Data = Data or { }

        local Section = {
            Window = self.Window,
            Page = self,

            Name = Data.Name or Data.name or "Section",
            Side = Data.Side or Data.side or 1,

            Items = { }
        }

        local Items = { } do
            Items["Section"] = Instances:Create("Frame", {
                Parent = Section.Page.ColumnsData[Section.Side].Instance,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 25),
                BorderColor3 = FromRGB(42, 49, 45),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(20, 24, 21)
            })  Items["Section"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Outline"})

            Items["Section"]:Border("Border")

            -- [Feature: Corner Radius] Section box UICorner
            local BoxCorner = InstanceNew("UICorner")
            BoxCorner.Name = "\0"
            BoxCorner.Parent = Items["Section"].Instance
            Library:RegisterCorner(BoxCorner, "Boxes")

            Items["Liner"] = Instances:Create("Frame", {
                Parent = Items["Section"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(202, 243, 255)
            })  Items["Liner"]:AddToTheme({BackgroundColor3  = "Accent"})

            Items["Glow"] = Instances:Create("Frame", {
                Parent = Items["Section"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 15),
                BorderSizePixel = 0,
                -- [Fix: Title Legibility] Explicit low ZIndex guarantees the
                -- title text below always renders above this glow overlay.
                ZIndex = 1,
                BackgroundColor3 = FromRGB(202, 243, 255)
            })  Items["Glow"]:AddToTheme({BackgroundColor3  = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["Glow"].Instance,
                Name = "\0",
                Rotation = 90,
                -- [Fix: Title Legibility] Floor raised from 0 to 0.35 so the glow never goes fully opaque under a title/label
                    Transparency = NumSequence{NumSequenceKeypoint(0, 0.35), NumSequenceKeypoint(0.193, 0.8687499761581421), NumSequenceKeypoint(0.504, 0.96875), NumSequenceKeypoint(1, 1)}
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Section"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(235, 235, 235),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Section.Name,
                Size = UDim2New(0, 0, 0, 15),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 6, 0, 5),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 9,
                ZIndex = 2,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Items["Text"]:TextBorder()

            Instances:Create("UIPadding", {
                Parent = Items["Section"].Instance,
                Name = "\0",
                PaddingBottom = UDimNew(0, 8)
            })

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["Section"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 10, 0, 26),
                Size = UDim2New(1, -20, 0, 0),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Content"].Instance,
                Name = "\0",
                Padding = UDimNew(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Section.Items = Items
        end

        return setmetatable(Section, Library.Sections)
    end
    
    Library.Sections.Toggle = function(self, Data)
        Data = Data or { }

        local Toggle = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Name = Data.Name or Data.name or "Toggle",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Default = Data.Default or Data.default or false,
            Callback = Data.Callback or Data.callback or function() end
        }

        local NewToggle, ToggleItems = Components:Toggle({
            Name = Toggle.Name,
            Parent = Toggle.Section.Items["Content"],
            Flag = Toggle.Flag,
            Default = Toggle.Default,
            Page = Toggle.Page,
            Callback = Toggle.Callback
        })

        function NewToggle:Colorpicker(Data)
            local Colorpicker = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                Callback = Data.Callback or Data.callback or function() end,
                Alpha = Data.Alpha or Data.alpha or 0,
            }

            local NewColorpicker, ColorpickerItems = Components:Colorpicker({
                Name = Colorpicker.Name,
                Parent = ToggleItems["SubElements"],
                Pages = true,
                Page = Colorpicker.Page,
                Flag = Colorpicker.Flag,
                Default = Colorpicker.Default,
                Alpha = Colorpicker.Alpha,
                Callback = Colorpicker.Callback,
            })

            return NewColorpicker
        end

        function NewToggle:Keybind(Data)
            Data = Data or { }

            local Keybind = {
                Window = self.Window,
                Page = self.Page,
                Section = self.Section,

                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or Enum.KeyCode.RightShift,
                Callback = Data.Callback or Data.callback or function() end,
                Mode = Data.Mode or Data.mode or "Toggle",
            }

            local NewKeybind, KeybindItems = Components:Keybind({
                Name = Toggle.Name,
                Parent = ToggleItems["SubElements"],
                Page = Keybind.Page,
                Flag = Keybind.Flag,
                Default = Keybind.Default,
                Mode = Keybind.Mode,
                Callback = Keybind.Callback
            })

            return NewKeybind
        end

        return NewToggle
    end

    Library.Sections.Button = function(self)
        local Button = {
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        local NewButton, ButtonItems = Components:Button({
            Parent = Button.Section.Items["Content"],
            Page = Button.Page
        })

        return NewButton
    end

    Library.Sections.Slider = function(self, Data)
        Data = Data or { }
        
        local Slider = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Name = Data.Name or Data.name or "Slider",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Min = Data.Min or Data.min or 0,
            Decimals = Data.Decimals or Data.decimals or 1,
            Suffix = Data.Suffix or Data.suffix or "",
            Max = Data.Max or Data.max or 100,
            Default = Data.Default or Data.Default or 0,
            Callback = Data.Callback or Data.callback or function() end,
        }

        local NewSlider, SliderItems = Components:Slider({
            Name = Slider.Name,
            Parent = Slider.Section.Items["Content"],
            Flag = Slider.Flag,
            Min = Slider.Min,
            Page = Slider.Page,
            Decimals = Slider.Decimals,
            Suffix = Slider.Suffix,
            Max = Slider.Max,
            Default = Slider.Default,
            Callback = Slider.Callback,
        })

        local PageSearchData = Library.SearchItems[Slider.Page]

        if PageSearchData then
            local SearchData = {
                Element = SliderItems["Slider"],
                Name = Slider.Name,
            }

            TableInsert(PageSearchData, SearchData)
        end

        return NewSlider 
    end

    Library.Sections.Dropdown = function(self, Data)
        Data = Data or { }

        local Dropdown = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Name = Data.Name or Data.name or "Dropdown",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Items = Data.Items or Data.items or { },
            Default = Data.Default or Data.default or nil,
            Multi = Data.Multi or Data.multi or false,
            Callback = Data.Callback or Data.callback or function() end            
        }

        local NewDropdown, DropdownItems = Components:Dropdown({
            Name = Dropdown.Name,
            Parent = Dropdown.Section.Items["Content"],
            Flag = Dropdown.Flag,
            Items = Dropdown.Items,
            Page = Dropdown.Page,
            Default = Dropdown.Default,
            Multi = Dropdown.Multi,
            Callback = Dropdown.Callback,
        })

        local PageSearchData = Library.SearchItems[Dropdown.Page]

        if PageSearchData then
            local SearchData = {
                Element = DropdownItems["Dropdown"],
                Name = Dropdown.Name,
            }

            TableInsert(PageSearchData, SearchData)
        end

        return NewDropdown 
    end

    Library.Sections.Label = function(self, Name)
        local Label = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Name = Name or "Label"
        }

        local NewLabel, LabelItems = Components:Label({
            Name = Label.Name,
            Parent = Label.Section.Items["Content"],
            Page = Label.Page,
        })

        function NewLabel:Colorpicker(Data)
            Data = Data or { }

            local Colorpicker = {
                Window = self.Window,
                Page = self.Page,
                Section = self.Section,

                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                Callback = Data.Callback or Data.callback or function() end,
                Alpha = Data.Alpha or Data.alpha or 0,
            }

            local NewColorpicker, ColorpickerItems = Components:Colorpicker({
                Name = Colorpicker.Name,
                Parent = LabelItems["SubElements"],
                Pages = true,
                Page = Colorpicker.Page,
                Flag = Colorpicker.Flag,
                Default = Colorpicker.Default,
                Alpha = Colorpicker.Alpha,
                Callback = Colorpicker.Callback,
            })

            return NewColorpicker
        end

        function NewLabel:Keybind(Data)
            Data = Data or { }

            local Keybind = {
                Window = self.Window,
                Page = self.Page,
                Section = self.Section,

                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or Enum.KeyCode.RightShift,
                Callback = Data.Callback or Data.callback or function() end,
                Mode = Data.Mode or Data.mode or "Toggle",
            }

            local NewKeybind, KeybindItems = Components:Keybind({
                Name = Label.Name,
                Parent = LabelItems["SubElements"],
                Page = Keybind.Page,
                Flag = Keybind.Flag,
                Default = Keybind.Default,
                Mode = Keybind.Mode,
                Callback = Keybind.Callback
            })

            return NewKeybind
        end

        local PageSearchData = Library.SearchItems[Label.Page]

        if PageSearchData then
            local SearchData = {
                Element = LabelItems["Label"],
                Name = Label.Name,
            }

            TableInsert(PageSearchData, SearchData)
        end

        return NewLabel
    end

    Library.Sections.Textbox = function(self, Data)
        Data = Data or { }

        local Textbox = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Name = Data.Name or Data.name or "Textbox",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Default = Data.Default or Data.default or "",
            Numeric = Data.Numeric or Data.numeric or false,
            Finished = Data.Finished or Data.finished or false,
            Placeholder = Data.Placeholder or Data.placeholder or "...",
            Callback = Data.Callback or Data.callback or function() end,
        }

        local NewTextbox, TextboxItems = Components:Textbox({
            Name = Textbox.Name,
            Placeholder = Textbox.Placeholder,
            Parent = Textbox.Section.Items["Content"],
            Flag = Textbox.Flag,
            Page = Textbox.Page,
            Default = Textbox.Default,
            Numeric = Textbox.Numeric,
            Finished = Textbox.Finished,
            Callback = Textbox.Callback,
        })

        local PageSearchData = Library.SearchItems[Textbox.Page]

        if PageSearchData then
            local SearchData = {
                Element = TextboxItems["Textbox"],
                Name = Textbox.Name,
            }

            TableInsert(PageSearchData, SearchData)
        end

        return NewTextbox
    end

    Library.Sections.Searchbox = function(self, Data)
        Data = Data or { }

        local Searchbox = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Name = Data.Name or Data.name or "Searchbox",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Items = Data.Items or Data.items or { },
            Default = Data.Default or Data.default or nil,
            Multi = Data.Multi or Data.multi or false,
            Callback = Data.Callback or Data.callback or function() end            
        }

        local NewSearchbox, SearchboxItems = Components:Searchbox({
            Parent = Searchbox.Section.Items["Content"],
            Flag = Searchbox.Flag,
            Items = Searchbox.Items,
            Page = Searchbox.Page,
            Default = Searchbox.Default,
            Multi = Searchbox.Multi,
            Callback = Searchbox.Callback,
        })

        local PageSearchData = Library.SearchItems[Searchbox.Page]

        if PageSearchData then
            local SearchData = {
                Element = SearchboxItems["Listbox"],
                Name = Searchbox.Name,
            }

            TableInsert(PageSearchData, SearchData)
        end

        return NewSearchbox 
    end

    Library.BlankElement = function(self, Data)
        local BlankElement = {
            Name = Data.Name or Data.name or "Blank",
            Size = Data.Size or Data.size or 18
        }

        local Items = { } do
            Items["BlankElement"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, BlankElement.Size),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Label"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(235, 235, 235),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = BlankElement.Name,
                Size = UDim2New(0, 0, 0, 15),
                AnchorPoint = Vector2New(0, 0.5),
                Position = UDim2New(0, 0, 0.5, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 9,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Items["Text"]:TextBorder()
        end

        return BlankElement, Items
    end

    Library.CreateSettingsPage = function(self, Window, Watermark, KeybindList)
        local SettingsPage = Window:Page({Name = "Settings", SubPages = true, PinLast = true}) do 
            local ThemingSubPage = SettingsPage:SubPage({Name = "Theming", Columns = 2}) do 
                -- [Feature: Advanced Theming] Sections revealed/hidden by the
                -- "Advanced Mode" toggle. Populated once each advanced section
                -- is built; starts empty since the toggle's Callback fires
                -- (with its Default=false) before the sections exist yet.
                local AdvancedThemingSections = { }
                local function SetAdvancedThemingVisible(Bool)
                    for _, Section in AdvancedThemingSections do
                        Section.Items["Section"].Instance.Visible = Bool
                    end
                end

                -- Upvalue so colorpicker callbacks can flip the dropdown to "Custom".
                local PresetDropdown

                -- ── TARGET LAYOUT ──────────────────────────────────────────
                -- Side=1 LEFT  (always visible):
                --   1. ThemesSection  ← Advanced Mode toggle + Preset dropdown
                --   2. ColorsSection  ← per-colour colorpickers
                -- Side=2 RIGHT (advanced-mode only):
                --   1. ThemesListSection        ← saved-themes CRUD
                --   2. ExportImportThemeSection ← Import as textbox + big box

                -- ── LEFT COLUMN ─────────────────────────────────────────────

                local ThemesSection = ThemingSubPage:Section({Name = "Themes", Side = 1}) do
                    if Library.AllowAdvancedTheming then
                        ThemesSection:Toggle({
                            Name = "Advanced Mode",
                            Flag = "AdvancedTheming",
                            Default = false,
                            Callback = function(Value)
                                SetAdvancedThemingVisible(Value)
                            end
                        })
                    end

                    if Library.AllowThemePresets then
                        local PresetNames = { }
                        for Name in Library.ThemePresets do
                            TableInsert(PresetNames, Name)
                        end
                        -- "Custom" always present so colorpicker callbacks can
                        -- call PresetDropdown:Set("Custom") reliably.
                        TableInsert(PresetNames, "Custom")

                        PresetDropdown = ThemesSection:Dropdown({
                            Name = "Preset",
                            Flag = "ThemePreset",
                            Items = PresetNames,
                            Default = Library.ActivePreset,
                            Callback = function(Value)
                                if not Value then return end

                                -- Skip the initial fire on construction and
                                -- the re-fire when Set("Custom") is called.
                                if Value == Library.ActivePreset then
                                    return
                                end

                                if Value == "Custom" then
                                    Library.ActivePreset = "Custom"
                                    Library:SaveActivePreset("Custom")
                                    Library:SaveActiveTheme()
                                    return
                                end

                                Library:SetThemePreset(Value)
                                Library:RefreshThemeColorpickers()
                                Library:SaveActivePreset(Value)
                                Library:Notification("Success", "Preset theme saved automatically", 3)
                            end
                        })
                    end
                end

                -- Colors section: per-colour colorpickers on Side=1 (LEFT),
                -- directly below ThemesSection. Always visible (not advanced-gated).
                -- Each callback flips the preset dropdown to "Custom" in real time.
                local ColorsSection = ThemingSubPage:Section({Name = "Colors", Side = 1}) do
                    for Index, Value in Library.Theme do
                        ColorsSection:Label(Index):Colorpicker({
                            Name = Index,
                            Flag = Index .. "Theme",
                            Default = Value,
                            Callback = function(Value)
                                -- Suppressed during batch refresh so preset
                                -- dropdown doesn't re-flip to "Custom".
                                if Library._SuppressThemeCallbacks then return end

                                Library.Theme[Index] = Value
                                Library:ChangeTheme(Index, Value)

                                Library.ActivePreset = "Custom"
                                if PresetDropdown then
                                    PresetDropdown:Set("Custom")
                                end
                                Library:SaveActivePreset("Custom")
                                Library:SaveActiveTheme()
                            end
                        })
                    end
                end

                -- ── RIGHT COLUMN (advanced only) ───────────────────────────

                if Library.AllowAdvancedTheming then
                    local ThemeSelected
                    local ThemeName
                    local UpdateThemeSelectionButtons
                    local ThemesSearchbox

                    -- Saved Themes CRUD list: Side=2 (RIGHT column, top).
                    local ThemesListSection = ThemingSubPage:Section({Name = "Saved Themes", Side = 2}) do
                        ThemesSearchbox = ThemesListSection:Searchbox({
                            Name = "SearchboxThemes",
                            Flag = "ThemesSearchbox",
                            Items = { },
                            Multi = false,
                            Callback = function(Value)
                                ThemeSelected = Value
                                UpdateThemeSelectionButtons()
                            end
                        })

                        ThemesListSection:Textbox({
                            Name = "Theme name",
                            Default = "",
                            Flag = "ThemeName",
                            Placeholder = "Enter text",
                            Callback = function(Value)
                                ThemeName = Value
                            end
                        })

                        local CreateAndDeleteButton = ThemesListSection:Button()

                        CreateAndDeleteButton:Add("Create", function()
                            if ThemeName and ThemeName ~= "" then
                                if not isfile(Library.Folders.Themes .. "/" .. ThemeName .. ".json") then
                                    writefile(Library.Folders.Themes .. "/" .. ThemeName .. ".json", Library:GetThemeConfig())
                                    Library:Notification("Success", "Created theme " .. ThemeName .. " succesfully", 5)
                                    Library:RefreshThemesList(ThemesSearchbox)
                                else
                                    Library:Notification("Error", "Theme with the name " .. ThemeName .. " already exists", 5)
                                    return
                                end
                            end
                        end)

                        local DeleteButton = CreateAndDeleteButton:Add("Delete", function()
                            if ThemeSelected then
                                Library:DeleteTheme(ThemeSelected)
                                Library:Notification("Success", "Deleted theme " .. ThemeSelected .. " succesfully", 5)
                                ThemeSelected = nil
                                UpdateThemeSelectionButtons()
                                Library:RefreshThemesList(ThemesSearchbox)
                            end
                        end)

                        local LoadAndSaveButton = ThemesListSection:Button()

                        -- Manual load: no AutoSave, stays ephemeral.
                        -- Only autoloaded [AT] themes persist on startup.
                        local LoadButton = LoadAndSaveButton:Add("Load", function()
                            if ThemeSelected then
                                local Ok, Err = Library:LoadThemeConfig(
                                    readfile(Library.Folders.Themes .. "/" .. ThemeSelected)
                                )
                                if Ok then
                                    Library:Notification("Success", "Loaded theme " .. ThemeSelected .. " succesfully", 5)
                                else
                                    Library:Notification("Error", "Failed to load theme " .. ThemeSelected .. " report this to the devs:\n" .. tostring(Err), 5)
                                end
                            end
                        end)

                        LoadAndSaveButton:Add("Save", function()
                            local targetTheme = ThemeSelected
                            if ThemeName and ThemeName ~= "" then
                                targetTheme = ThemeName .. ".json"
                            end
                            if targetTheme then
                                writefile(Library.Folders.Themes .. "/" .. targetTheme, Library:GetThemeConfig())
                                Library:Notification("Success", "Saved theme " .. targetTheme:gsub("%.json$", "") .. " succesfully", 5)
                                Library:RefreshThemesList(ThemesSearchbox)
                            else
                                Library:Notification("Error", "Please enter a name or select a theme to save", 5)
                            end
                        end)

                        local AutoloadButton = ThemesListSection:Button()
                        local AutoloadActionButton = AutoloadButton:Add("Set as Autoload [AT]", function()
                            if ThemeSelected then
                                local NewName = Library:SetAutoload(Library.Folders.Themes, ThemeSelected)
                                ThemeSelected = NewName
                                Library:Notification("Success", "Set " .. NewName:gsub("%.json$", "") .. " as Autoload theme", 5)
                                Library:RefreshThemesList(ThemesSearchbox)
                            else
                                Library:Notification("Error", "Please select a theme first", 5)
                            end
                        end)

                        local RemoveAutoloadButton = AutoloadButton:Add("Remove Autoload", function()
                            if ThemeSelected then
                                local NewName = Library:RemoveAutoload(Library.Folders.Themes, ThemeSelected)
                                ThemeSelected = NewName
                                Library:Notification("Success", "Removed autoload from " .. NewName:gsub("%.json$", ""), 5)
                                Library:RefreshThemesList(ThemesSearchbox)
                            else
                                Library:Notification("Error", "Please select a theme first", 5)
                            end
                        end)

                        UpdateThemeSelectionButtons = function()
                            local HasSelection = ThemeSelected ~= nil and ThemeSelected ~= ""
                            DeleteButton:SetEnabled(HasSelection)
                            LoadButton:SetEnabled(HasSelection)
                            AutoloadActionButton:SetEnabled(HasSelection)
                            RemoveAutoloadButton:SetEnabled(HasSelection)
                        end
                        UpdateThemeSelectionButtons()

                        Library:RefreshThemesList(ThemesSearchbox)
                    end
                    TableInsert(AdvancedThemingSections, ThemesListSection)

                    -- Export/Import Theme: Side=2 (RIGHT column, below ThemesListSection).
                    -- "Import as" textbox saves the pasted JSON to disk so it
                    -- appears in the Saved Themes list (mirrors Config export/import).
                    local ImportThemeName

                    local ExportImportThemeSection = ThemingSubPage:Section({Name = "Export / Import Theme", Side = 2}) do
                        ExportImportThemeSection:Textbox({
                            Name = "Import as",
                            Default = "",
                            Flag = "ImportThemeName",
                            Placeholder = "Enter a name for the imported theme",
                            Callback = function(Value)
                                ImportThemeName = Value
                            end
                        })

                        local ThemeBox = Library:BuildExportImportBox(ExportImportThemeSection.Items["Content"].Instance)

                        local ThemeExportButton = ExportImportThemeSection:Button()

                        ThemeExportButton:Add("Export", function()
                            ThemeBox:SetText(Library:GetThemeConfig())
                            Library:Notification("Success", "Exported current theme below", 3)
                        end)

                        ThemeExportButton:Add("Copy", function()
                            if setclipboard then
                                pcall(setclipboard, ThemeBox:GetText())
                                Library:Notification("Success", "Theme copied to clipboard", 3)
                            else
                                Library:Notification("Error", "Your executor doesn't support setclipboard", 3)
                            end
                        end)

                        local ThemeImportClearButton = ExportImportThemeSection:Button()

                        ThemeImportClearButton:Add("Import", function()
                            local Text = ThemeBox:GetText()

                            if Text == nil or Text == "" then
                                Library:Notification("Error", "Please paste a theme first", 5)
                                return
                            end

                            if not ImportThemeName or ImportThemeName == "" then
                                Library:Notification("Error", "Please enter a name for the imported theme", 5)
                                return
                            end

                            local DecodeOk = pcall(HttpService.JSONDecode, HttpService, Text)
                            if not DecodeOk then
                                Library:Notification("Error", "Import failed: pasted text isn't valid JSON", 5)
                                return
                            end

                            local FileName = ImportThemeName .. ".json"

                            if isfile(Library.Folders.Themes .. "/" .. FileName) then
                                Library:Notification("Error", "Theme with the name " .. ImportThemeName .. " already exists", 5)
                                return
                            end

                            writefile(Library.Folders.Themes .. "/" .. FileName, Text)
                            Library:Notification("Success", "Imported theme " .. ImportThemeName .. " successfully", 5)
                            Library:RefreshThemesList(ThemesSearchbox)
                        end)

                        ThemeImportClearButton:Add("Clear", function()
                            ThemeBox:SetText("")
                        end)
                    end
                    TableInsert(AdvancedThemingSections, ExportImportThemeSection)

                    -- Hidden until user flips Advanced Mode on.
                    SetAdvancedThemingVisible(false)
                end

            end

            local ConfigsSubPage = SettingsPage:SubPage({Name = "Configs", Columns = 2}) do 
                -- Shared across both Sections below (config list/buttons on
                -- Side 1, Export/Import container on Side 2) so the Export
                -- button can be gated on the same selection state as
                -- Delete/Load/Autoload.
                local ConfigName
                local ConfigSelected
                local UpdateSelectionDependentButtons -- forward declared; assigned once the buttons below exist

                local ConfigsSearchbox

                local ConfigsSection = ConfigsSubPage:Section({Name = "Configs", Side = 1}) do
                    ConfigsSearchbox = ConfigsSection:Searchbox({
                        Name = "SearchboxConfigs",
                        Flag = "ConfigsSearchobx",
                        Items = { },
                        Multi = false,
                        Callback = function(Value)
                            ConfigSelected = Value
                            UpdateSelectionDependentButtons()
                        end
                    })

                    ConfigsSection:Textbox({
                        Name = "Config name", 
                        Default = "", 
                        Flag = "ConfigName", 
                        Placeholder = "Enter text", 
                        Callback = function(Value)
                            ConfigName = Value
                        end
                    })

                    local CreateAndDeleteButton = ConfigsSection:Button()

                    CreateAndDeleteButton:Add("Create", function()
                        if ConfigName and ConfigName ~= "" then
                            if not isfile(Library.Folders.Configs .. "/" .. ConfigName .. ".json") then
                                writefile(Library.Folders.Configs .. "/" .. ConfigName .. ".json", Library:GetConfig())
                                Library:Notification("Success", "Created config "..ConfigName .. " succesfully", 5)
                                Library:RefreshConfigsList(ConfigsSearchbox)
                            else
                                Library:Notification("Error", "Config with the name "..ConfigName .. " already exists", 5)
                                return
                            end
                        end
                    end)

                    local DeleteButton = CreateAndDeleteButton:Add("Delete", function()
                        if ConfigSelected then
                            Library:DeleteConfig(ConfigSelected)
                            Library:Notification("Success", "Deleted config "..ConfigSelected .. " succesfully", 5)
                            ConfigSelected = nil
                            UpdateSelectionDependentButtons()
                            Library:RefreshConfigsList(ConfigsSearchbox)
                        end
                    end)

                    local LoadAndSaveButton = ConfigsSection:Button()    

                    local LoadButton = LoadAndSaveButton:Add("Load", function()
                        if ConfigSelected then
                            local Success, Result = Library:LoadConfig(readfile(Library.Folders.Configs .. "/" .. ConfigSelected))

                            if Success then 
                                Library:Notification("Success", "Loaded config "..ConfigSelected .. " succesfully", 5)
                            else
                                Library:Notification("Error", "Failed to load config "..ConfigSelected .. " report this to the devs:\n"..Result, 5)
                            end
                        end
                    end)

                    LoadAndSaveButton:Add("Save", function()
                        local targetConfig = ConfigSelected
                        if ConfigName and ConfigName ~= "" then
                            targetConfig = ConfigName .. ".json"
                        end
                        if targetConfig then
                            writefile(Library.Folders.Configs .. "/" .. targetConfig, Library:GetConfig())
                            Library:Notification("Success", "Saved config "..targetConfig:gsub("%.json$", "").." succesfully", 5)
                            Library:RefreshConfigsList(ConfigsSearchbox)
                        else
                            Library:Notification("Error", "Please enter a name or select a config to save", 5)
                        end
                    end)

                    local AutoloadButton = ConfigsSection:Button()
                    local AutoloadActionButton = AutoloadButton:Add("Set as Autoload [AT]", function()
                        local targetConfig = ConfigSelected
                        if targetConfig then
                            local NewName = Library:SetAutoload(Library.Folders.Configs, targetConfig)
                            ConfigSelected = NewName
                            Library:Notification("Success", "Set " .. NewName:gsub("%.json$", "") .. " as Autoload config", 5)
                            Library:RefreshConfigsList(ConfigsSearchbox)
                        else
                            Library:Notification("Error", "Please select a config first", 5)
                        end
                    end)

                    local RemoveAutoloadButton = AutoloadButton:Add("Remove Autoload", function()
                        local targetConfig = ConfigSelected
                        if targetConfig then
                            local NewName = Library:RemoveAutoload(Library.Folders.Configs, targetConfig)
                            ConfigSelected = NewName
                            Library:Notification("Success", "Removed autoload from " .. NewName:gsub("%.json$", ""), 5)
                            Library:RefreshConfigsList(ConfigsSearchbox)
                        else
                            Library:Notification("Error", "Please select a config first", 5)
                        end
                    end)

                    -- [Feature: Config selection feedback] Grey the label out
                    -- when no config is selected, white once one is, instead
                    -- of the buttons silently doing nothing when pressed.
                    UpdateSelectionDependentButtons = function()
                        local HasSelection = ConfigSelected ~= nil and ConfigSelected ~= ""
                        DeleteButton:SetEnabled(HasSelection)
                        LoadButton:SetEnabled(HasSelection)
                        AutoloadActionButton:SetEnabled(HasSelection)
                        RemoveAutoloadButton:SetEnabled(HasSelection)
                    end
                    UpdateSelectionDependentButtons()

                    Library:RefreshConfigsList(ConfigsSearchbox)
                end

                -- [Feature: Config Export] Export/Import of the actual saved
                -- config files in Library.Folders.Configs (same data as the
                -- config list/Save/Load on Side 1) -- not the theme colours,
                -- which have their own identical-looking Section on the
                -- Theming subpage instead (GetThemeConfig/LoadThemeConfig).
                -- Export dumps the raw JSON of whatever's selected in the
                -- list; Import writes whatever JSON is pasted into the box
                -- to disk as a new config under the typed name, rather than
                -- just live-loading it, so it shows up in the list like any
                -- other saved config.
                if Library.AllowConfigExport then
                    local ImportConfigName

                    local ExportImportSection = ConfigsSubPage:Section({Name = "Export / Import Config", Side = 2}) do
                        ExportImportSection:Textbox({
                            Name = "Import as",
                            Default = "",
                            Flag = "ImportConfigName",
                            Placeholder = "Enter a name for the imported config",
                            Callback = function(Value)
                                ImportConfigName = Value
                            end
                        })

                        local ConfigBox = Library:BuildExportImportBox(ExportImportSection.Items["Content"].Instance)

                        local ExportButton = ExportImportSection:Button()

                        local ExportActionButton = ExportButton:Add("Export", function()
                            if not ConfigSelected then
                                return
                            end

                            local Success, Result = pcall(readfile, Library.Folders.Configs .. "/" .. ConfigSelected)

                            if Success then
                                ConfigBox:SetText(Result)
                                Library:Notification("Success", "Exported config "..ConfigSelected:gsub("%.json$", "").." below", 3)
                            else
                                Library:Notification("Error", "Failed to read config "..ConfigSelected, 5)
                            end
                        end)

                        ExportButton:Add("Copy", function()
                            if setclipboard then
                                pcall(setclipboard, ConfigBox:GetText())
                                Library:Notification("Success", "Config copied to clipboard", 3)
                            else
                                Library:Notification("Error", "Your executor doesn't support setclipboard", 3)
                            end
                        end)

                        local ImportClearButton = ExportImportSection:Button()

                        ImportClearButton:Add("Import", function()
                            local Text = ConfigBox:GetText()

                            if Text == nil or Text == "" then
                                Library:Notification("Error", "Please paste a config first", 5)
                                return
                            end

                            if not ImportConfigName or ImportConfigName == "" then
                                Library:Notification("Error", "Please enter a name for the imported config", 5)
                                return
                            end

                            local DecodeOk = pcall(HttpService.JSONDecode, HttpService, Text)
                            if not DecodeOk then
                                Library:Notification("Error", "Import failed: pasted text isn't valid JSON", 5)
                                return
                            end

                            local FileName = ImportConfigName .. ".json"

                            if isfile(Library.Folders.Configs .. "/" .. FileName) then
                                Library:Notification("Error", "Config with the name "..ImportConfigName .. " already exists", 5)
                                return
                            end

                            writefile(Library.Folders.Configs .. "/" .. FileName, Text)
                            Library:Notification("Success", "Imported config "..ImportConfigName .. " succesfully", 5)
                            Library:RefreshConfigsList(ConfigsSearchbox)
                        end)

                        ImportClearButton:Add("Clear", function()
                            ConfigBox:SetText("")
                        end)

                        -- Same selection-gated greying as Delete/Load/Autoload,
                        -- plus a label swap since "Export" doesn't make sense
                        -- to leave up when there's nothing selected to export.
                        local function UpdateExportButton()
                            local HasSelection = ConfigSelected ~= nil and ConfigSelected ~= ""
                            ExportActionButton:SetEnabled(HasSelection)
                            ExportActionButton:SetText(HasSelection and "Export" or "No config selected")
                        end

                        UpdateExportButton()

                        local PreviousUpdateSelectionDependentButtons = UpdateSelectionDependentButtons
                        UpdateSelectionDependentButtons = function()
                            PreviousUpdateSelectionDependentButtons()
                            UpdateExportButton()
                        end
                    end
                end
            end

			local SettingsSubPage = SettingsPage:SubPage({Name = "Settings", Columns = 2}) do 
			    local SettingsSection = SettingsSubPage:Section({Name = "Settings", Side = 1}) do
			        SettingsSection:Toggle({
			            Name = "Watermark",
			            Flag = "Watermark",
			            Default = true,
			            Callback = function(Value)
			                Watermark:SetVisibility(Value)
			            end
			        })
			
			        SettingsSection:Toggle({
			            Name = "Keybind list",
			            Flag = "Keybind list",
			            Default = true,
			            Callback = function(Value)
			                KeybindList:SetVisibility(Value)
			            end
			        })

			        -- [Feature: Title] User can reposition or hide the window title
			        if Library.TitleText ~= "" then
			            local CurrentPos = Library.TitlePosition
			            local PosMap = {Topbar = "Topbar", Logo = "Logo box", None = "None"}
			            SettingsSection:Dropdown({
			                Name = "Title Position",
			                Flag = "TitlePosition",
			                Items = {"Topbar", "Logo box", "None"},
			                Default = PosMap[CurrentPos] or "Topbar",
			                Callback = function(Value)
			                    local Pos = Value == "Logo box" and "Logo" or Value
			                    -- [Fix: Title Disappearing] Was called with a colon
			                    -- (Window:ApplyTitlePosition(Pos)), which silently
			                    -- passed Window itself as the Position argument
			                    -- instead of Pos. Position then never matched
			                    -- "Topbar"/"Logo" and fell through to the "None"
			                    -- branch, hiding the title every time this ran.
			                    if Window and Window.ApplyTitlePosition then
			                        Window.ApplyTitlePosition(Pos)
			                    end
			                end
			            })
			        end

			        -- [Feature: Unknown Mode] Lets the user anonymize the
			        -- player profile box. Whether this shows up at all is a
			        -- dev-level switch (Library.AllowUnknownMode); what it
			        -- actually does (hide the box vs. show placeholders) is
			        -- also chosen by the dev (Library.UnknownModeStyle), not
			        -- configurable from here.
			        if Library.AllowUnknownMode then
			            SettingsSection:Toggle({
			                Name = "Unknown Mode",
			                Flag = "UnknownMode",
			                Default = false,
			                Callback = function(Value)
			                    if Window and Window.ApplyUnknownMode then
			                        Window.ApplyUnknownMode(Value)
			                    end
			                end
			            })
			        end
			
			        SettingsSection:Slider({
			            Name = "Fade time",
			            Flag = "FadeTime",
			            Default = Library.FadeSpeed,
			            Min = 0,
			            Max = 1,
			            Decimals = 0.01,
			            Callback = function(Value)
			                Library.FadeSpeed = Value
			            end
			        })
			
			        SettingsSection:Slider({
			            Name = "Tween time",
			            Flag = "TweenTime",
			            Default = Library.Tween.Time,
			            Min = 0,
			            Max = 1,
			            Decimals = 0.01,
			            Callback = function(Value)
			                Library.Tween.Time = Value
			            end
			        })
			
			        SettingsSection:Dropdown({
			            Name = "Tween style",
			            Flag = "Tween style",
			            Items = { "Linear", "Quad", "Quart", "Back", "Bounce", "Circular", "Cubic", "Elastic", "Exponential", "Sine", "Quint" },
			            Default = "Cubic",
			            Callback = function(Value)
			                Library.Tween.Style = Enum.EasingStyle[Value]
			            end
			        })
			
			        SettingsSection:Dropdown({
			            Name = "Tween direction",
			            Flag = "Tween direction",
			            Items = { "In", "Out", "InOut" },
			            Default = "Out",
			            Callback = function(Value)
			                Library.Tween.Direction = Enum.EasingDirection[Value]
			            end
			        })
			
			        SettingsSection:Button():Add("Panic / Emergency Close", function()
			            Library:Notification("Emergency Close", "Script unloaded and game state restored.", 5)
			            Library:Unload()
			        end)
			        -- Added Rejoin Button
			        SettingsSection:Button():Add("Rejoin", function()
			            local TeleportService = game:GetService("TeleportService")
			            local Players = game:GetService("Players")
			            local LocalPlayer = Players.LocalPlayer
			            if LocalPlayer then
			                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
			            end
			        end)
			
			        -- Added Serverhop Button
			        SettingsSection:Button():Add("Serverhop", function()
			            local TeleportService = game:GetService("TeleportService")
			            local Players = game:GetService("Players")
			            local LocalPlayer = Players.LocalPlayer
			            if LocalPlayer then
			                TeleportService:Teleport(game.PlaceId, LocalPlayer)
			            end
			        end)
			
			        SettingsSection:Label("UI Keybind"):Keybind({
			            Name = "Menu keybind",
			            Flag = "UIKeybind",
			            Default = Library.MenuKeybind,
			            Mode = "Toggle",
			            Callback = function()
			                Library.MenuKeybind = Library.Flags["UIKeybind"].Key
			            end
			        })
			    end
			end

            -- [Feature: Credits] Always-last sub-page showing dev credits
            local CreditsSubPage = SettingsPage:SubPage({Name = "Credits", Columns = 1}) do
                local CreditsSection = CreditsSubPage:Section({Name = "Credits", Side = 1}) do
                    if type(Library.Credits) == "table" then
                        for _, Entry in Library.Credits do
                            local EntryName = tostring(Entry.Name or Entry.name or "?")
                            local EntryRole = tostring(Entry.Role or Entry.role or "")
                            local Line = EntryRole ~= "" and (EntryName .. "  —  " .. EntryRole) or EntryName
                            CreditsSection:Label(Line)
                        end
                    end
                    if #Library.Credits > 0 then
                        CreditsSection:Label("────────────────")
                    end
                    CreditsSection:Label("Built with Adytum Library")
                end
            end
        end

        -- [Feature: Autoload] Load whichever config is tagged "[AT] " on startup.
        -- This must run after every Flag-registering component (both the
        -- caller's pages/sections and this Settings page) has been built,
        -- since LoadConfig applies values through Library.SetFlags.
        if Library.Folders and Library.Folders.Configs and isfolder(Library.Folders.Configs) then
            for _, Path in ipairs(listfiles(Library.Folders.Configs)) do
                local FileName = string.match(Path, "([^/\\]+)$")
                if FileName and FileName:match("^%[AT%]") then
                    local Ok = Library:LoadConfig(readfile(Path))

                    if Ok then
                        Library:Notification("Autoload", "Loaded autoload config " .. FileName:gsub("%.json$", ""), 5)
                    else
                        Library:Notification("Error", "Failed to autoload config " .. FileName:gsub("%.json$", ""), 5)
                    end

                    break
                end
            end
        end

        -- [Feature: Advanced Theming] Same autoload-on-startup treatment for
        -- whichever theme is tagged "[AT] ", if the feature is enabled.
        -- AutoSave = true so the loaded colours overwrite the ActivePreset/
        -- ActiveTheme persistence files, giving the autoloaded theme priority
        -- over any preset that was previously active.
        if Library.AllowAdvancedTheming and Library.Folders and Library.Folders.Themes and isfolder(Library.Folders.Themes) then
            for _, Path in ipairs(listfiles(Library.Folders.Themes)) do
                local FileName = string.match(Path, "([^/\\]+)$")
                if FileName and FileName:match("^%[AT%]") then
                    local Ok = Library:LoadThemeConfig(readfile(Path), true)  -- AutoSave: persist as active custom theme

                    if Ok then
                        Library:Notification("Autoload", "Loaded autoload theme " .. FileName:gsub("%.json$", ""), 5)
                    else
                        Library:Notification("Error", "Failed to autoload theme " .. FileName:gsub("%.json$", ""), 5)
                    end

                    break
                end
            end
        end

        return SettingsPage
    end
end

return Library
