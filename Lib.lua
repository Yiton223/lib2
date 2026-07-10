local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.__index = Library

-- Цветовая палитра (Красная тема)
local Theme = {
    MainRed = Color3.fromRGB(255, 75, 75),
    DarkRed = Color3.fromRGB(160, 35, 35),
    Background = Color3.fromRGB(14, 19, 30),
    SecondaryBG = Color3.fromRGB(20, 24, 35),
    Stroke = Color3.fromRGB(55, 45, 45),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(200, 200, 200)
}

local function MakeDraggable(topbarobject, object)
    local Dragging = false
    local DragInput
    local DragStart
    local StartPosition

    local function Update(input)
        if not (DragStart and StartPosition) then
            return
        end
        local Delta = input.Position - DragStart
        object.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                    DragInput = nil
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if Dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input == DragInput then
            Update(input)
        end
    end)
end

local function FormatValue(Value: string | number)
    local n = tonumber(Value)
    if not n then 
        return tostring(Value)
    end
    local suffixes = {
        "", "k", "M", "B", "T", "QD", "QN", "SX", "SP"
    }
    local index = 1
    local absNumber = math.abs(n)
    while absNumber >= 1000 and index < #suffixes do
        absNumber = absNumber / 1000
        index = index + 1
    end
    local sign = n < 0 and "-" or ""
    local formatted
    if absNumber >= 1 and index > 1 then
        formatted = string.format("%.1f", absNumber):gsub("%.0$", "")
    else
        formatted = tostring(math.floor(absNumber * 100) / 100)
    end
    return sign .. formatted .. suffixes[index]
end

function Library:CreateWindow(TitleText: string)
    local WindowObj = {}
    local StatsList = {}
    local IsFullscreen = true

    local Xyesos = Instance.new("ScreenGui")
    Xyesos.Name = "RedLib"
    Xyesos.Parent = CoreGui
    Xyesos.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Xyesos.IgnoreGuiInset = true
    Xyesos.ResetOnSpawn = false

    -- ═══════════════════════════════════════════════════════
    --  ГЛОБАЛЬНЫЙ TOOLTIP (1 инстанс на всю библиотеку)
    -- ═══════════════════════════════════════════════════════
    local Tooltip = Instance.new("TextLabel")
    Tooltip.Name = "GlobalTooltip"
    Tooltip.Parent = Xyesos
    Tooltip.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Tooltip.BackgroundTransparency = 0.05
    Tooltip.BorderSizePixel = 0
    Tooltip.TextColor3 = Theme.Text
    Tooltip.TextSize = 12
    Tooltip.Font = Enum.Font.GothamMedium
    Tooltip.Visible = false
    Tooltip.ZIndex = 100
    Tooltip.Text = ""
    Tooltip.TextWrapped = true
    Instance.new("UICorner", Tooltip).CornerRadius = UDim.new(0, 4)
    local TooltipPadding = Instance.new("UIPadding")
    TooltipPadding.Parent = Tooltip
    TooltipPadding.PaddingLeft = UDim.new(0, 8)
    TooltipPadding.PaddingRight = UDim.new(0, 8)
    TooltipPadding.PaddingTop = UDim.new(0, 4)
    TooltipPadding.PaddingBottom = UDim.new(0, 4)

    local function AttachTooltip(object, text)
        object.MouseEnter:Connect(function()
            Tooltip.Text = text
            Tooltip.Visible = true
        end)
        object.MouseMoved:Connect(function(x, y)
            local mx = tonumber(x) or 0
            local my = tonumber(y) or 0
            Tooltip.Position = UDim2.new(0, mx + 15, 0, my + 15)
            local bounds = Tooltip.TextBounds
            Tooltip.Size = UDim2.new(0, math.min(bounds.X + 16, 300), 0, bounds.Y + 8)
        end)
        object.MouseLeave:Connect(function()
            Tooltip.Visible = false
        end)
    end

    -- ═══════════════════════════════════════════════════════
    --  FULLSCREEN VIEW
    -- ═══════════════════════════════════════════════════════
    local FullscreenBG = Instance.new("Frame")
    FullscreenBG.Name = "FullscreenBackground"
    FullscreenBG.Parent = Xyesos
    FullscreenBG.BackgroundColor3 = Theme.Background
    FullscreenBG.BorderSizePixel = 0
    FullscreenBG.Size = UDim2.new(1, 0, 1, 0)
    FullscreenBG.Visible = true

    local Watermark = Instance.new("ImageLabel")
    Watermark.Name = "Watermark"
    Watermark.Parent = FullscreenBG
    Watermark.BackgroundTransparency = 1.000
    Watermark.Size = UDim2.new(1, 0, 1, 0)
    Watermark.Image = "rbxassetid://5079174090"
    Watermark.ImageTransparency = 0.960

    local FullTitleLabel = Instance.new("TextLabel")
    FullTitleLabel.Name = "Title"
    FullTitleLabel.Parent = FullscreenBG
    FullTitleLabel.BackgroundTransparency = 1.000
    FullTitleLabel.Position = UDim2.new(0.15, 0, 0.05, 0)
    FullTitleLabel.Size = UDim2.new(0.7, 0, 0.10, 0)
    FullTitleLabel.Font = Enum.Font.FredokaOne
    FullTitleLabel.Text = TitleText
    FullTitleLabel.TextColor3 = Theme.Text
    FullTitleLabel.TextScaled = true
    FullTitleLabel.TextWrapped = true

    local FullTitleGradient = Instance.new("UIGradient")
    FullTitleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.MainRed),
        ColorSequenceKeypoint.new(1, Theme.DarkRed)
    })
    FullTitleGradient.Rotation = 90
    FullTitleGradient.Parent = FullTitleLabel

    local FullContainer = Instance.new("Frame")
    FullContainer.Name = "FullContainer"
    FullContainer.Parent = FullscreenBG
    FullContainer.BackgroundTransparency = 1
    FullContainer.Position = UDim2.new(0.15, 0, 0.18, 0)
    FullContainer.Size = UDim2.new(0.7, 0, 0.72, 0)

    local FullListLayout = Instance.new("UIListLayout")
    FullListLayout.Parent = FullContainer
    FullListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    FullListLayout.Padding = UDim.new(0, 10)

    -- ═══════════════════════════════════════════════════════
    --  MINI VIEW
    -- ═══════════════════════════════════════════════════════
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = Xyesos
    MainFrame.BackgroundColor3 = Theme.SecondaryBG
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Stroke
    MainStroke.Thickness = 2
    MainStroke.Parent = MainFrame

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Theme.Text
    TitleBar.BackgroundTransparency = 1.000
    TitleBar.Size = UDim2.new(1, 0, 0, 40)

    local MiniTitleLabel = Instance.new("TextLabel")
    MiniTitleLabel.Name = "Title"
    MiniTitleLabel.Parent = TitleBar
    MiniTitleLabel.BackgroundTransparency = 1.000
    MiniTitleLabel.Position = UDim2.new(0, 15, 0, 0)
    MiniTitleLabel.Size = UDim2.new(1, -30, 1, 0)
    MiniTitleLabel.Font = Enum.Font.FredokaOne
    MiniTitleLabel.Text = TitleText
    MiniTitleLabel.TextColor3 = Theme.Text
    MiniTitleLabel.TextSize = 22
    MiniTitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local MiniTitleGradient = Instance.new("UIGradient")
    MiniTitleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.MainRed),
        ColorSequenceKeypoint.new(1, Theme.DarkRed)
    })
    MiniTitleGradient.Rotation = 0
    MiniTitleGradient.Parent = MiniTitleLabel

    MakeDraggable(TitleBar, MainFrame)

    local MiniContainer = Instance.new("ScrollingFrame")
    MiniContainer.Name = "Container"
    MiniContainer.Parent = MainFrame
    MiniContainer.Active = true
    MiniContainer.BackgroundColor3 = Theme.Text
    MiniContainer.BackgroundTransparency = 1.000
    MiniContainer.BorderSizePixel = 0
    MiniContainer.Position = UDim2.new(0, 0, 0, 50)
    MiniContainer.Size = UDim2.new(1, 0, 1, -60)
    MiniContainer.ScrollBarThickness = 2
    MiniContainer.ScrollBarImageColor3 = Theme.MainRed
    MiniContainer.ElasticBehavior = Enum.ElasticBehavior.Always
    MiniContainer.ScrollingDirection = Enum.ScrollingDirection.Y

    local MiniListLayout = Instance.new("UIListLayout")
    MiniListLayout.Parent = MiniContainer
    MiniListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    MiniListLayout.Padding = UDim.new(0, 6)

    local MiniPadding = Instance.new("UIPadding")
    MiniPadding.Parent = MiniContainer
    MiniPadding.PaddingLeft = UDim.new(0, 15)
    MiniPadding.PaddingRight = UDim.new(0, 15)

    MiniListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        MiniContainer.CanvasSize = UDim2.new(0, 0, 0, MiniListLayout.AbsoluteContentSize.Y + 10)
    end)

    -- ═══════════════════════════════════════════════════════
    --  FLOATING TOGGLE
    -- ═══════════════════════════════════════════════════════
    local FloatToggleBtn = Instance.new("ImageButton")
    FloatToggleBtn.Name = "FloatingToggle"
    FloatToggleBtn.Parent = Xyesos
    FloatToggleBtn.BackgroundColor3 = Theme.MainRed
    FloatToggleBtn.Position = UDim2.new(0.9, 0, 0.9, -60)
    FloatToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    FloatToggleBtn.ZIndex = 10
    FloatToggleBtn.AutoButtonColor = true
    FloatToggleBtn.Image = "rbxassetid://5079174090"

    local FloatCorner = Instance.new("UICorner")
    FloatCorner.CornerRadius = UDim.new(1, 0)
    FloatCorner.Parent = FloatToggleBtn

    local FloatStroke = Instance.new("UIStroke")
    FloatStroke.Thickness = 2
    FloatStroke.Color = Theme.Text
    FloatStroke.Parent = FloatToggleBtn

    local FloatShadow = Instance.new("ImageLabel")
    FloatShadow.Name = "Shadow"
    FloatShadow.Parent = FloatToggleBtn
    FloatShadow.BackgroundTransparency = 1
    FloatShadow.Position = UDim2.new(0, -15, 0, -15)
    FloatShadow.Size = UDim2.new(1, 30, 1, 30)
    FloatShadow.ZIndex = 9
    FloatShadow.Image = "rbxassetid://5079174090"
    FloatShadow.ImageColor3 = Color3.fromRGB(0,0,0)
    FloatShadow.ImageTransparency = 0.6
    FloatShadow.SliceCenter = Rect.new(10, 10, 118, 118)

    AttachTooltip(FloatToggleBtn, "Toggle View")

    -- Плавное переключение + tween
    local function ToggleView()
        IsFullscreen = not IsFullscreen
        if IsFullscreen then
            MainFrame.Visible = false
            FullscreenBG.Visible = true
            FullscreenBG.BackgroundTransparency = 1
            TweenService:Create(FullscreenBG, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        else
            TweenService:Create(FullscreenBG, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            task.delay(0.2, function()
                FullscreenBG.Visible = false
                MainFrame.Visible = true
                MainFrame.Size = UDim2.new(0, 280, 0, 380)
                TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
                    Size = UDim2.new(0, 300, 0, 400)
                }):Play()
            end)
        end
    end
    MakeDraggable(FloatToggleBtn, FloatToggleBtn)
    FloatToggleBtn.MouseButton1Click:Connect(ToggleView)

    -- Auto-hide после 3 секунд бездействия
    local InactivityTimer
    local function ResetOpacity()
        TweenService:Create(FloatToggleBtn, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
        if InactivityTimer then task.cancel(InactivityTimer) end
        InactivityTimer = task.delay(3, function()
            TweenService:Create(FloatToggleBtn, TweenInfo.new(0.5), {ImageTransparency = 0.5}):Play()
        end)
    end
    UserInputService.InputChanged:Connect(ResetOpacity)

    -- ═══════════════════════════════════════════════════════
    --  ADD SECTION (разделитель с заголовком)
    -- ═══════════════════════════════════════════════════════
    function WindowObj:AddSection(SectionName: string)
        -- Fullscreen: линия — текст — линия
        local FullFrame = Instance.new("Frame")
        FullFrame.Name = "Section_" .. SectionName
        FullFrame.Parent = FullContainer
        FullFrame.BackgroundTransparency = 1
        FullFrame.Size = UDim2.new(1, 0, 0, 32)

        local LeftLine = Instance.new("Frame")
        LeftLine.Name = "LeftLine"
        LeftLine.Parent = FullFrame
        LeftLine.BackgroundColor3 = Theme.MainRed
        LeftLine.BorderSizePixel = 0
        LeftLine.Size = UDim2.new(0.28, 0, 0, 2)
        LeftLine.Position = UDim2.new(0.02, 0, 0.5, -1)

        local RightLine = Instance.new("Frame")
        RightLine.Name = "RightLine"
        RightLine.Parent = FullFrame
        RightLine.BackgroundColor3 = Theme.MainRed
        RightLine.BorderSizePixel = 0
        RightLine.Size = UDim2.new(0.28, 0, 0, 2)
        RightLine.Position = UDim2.new(0.7, 0, 0.5, -1)

        local Label = Instance.new("TextLabel")
        Label.Name = "Title"
        Label.Parent = FullFrame
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0.3, 0, 0, 0)
        Label.Size = UDim2.new(0.4, 0, 1, 0)
        Label.Font = Enum.Font.GothamBold
        Label.Text = "  " .. SectionName .. "  "
        Label.TextColor3 = Theme.MainRed
        Label.TextScaled = true
        Label.TextWrapped = true

        -- Mini: текст с подчеркиванием
        local MiniFrame = Instance.new("Frame")
        MiniFrame.Name = "MiniSection_" .. SectionName
        MiniFrame.Parent = MiniContainer
        MiniFrame.BackgroundTransparency = 1
        MiniFrame.Size = UDim2.new(1, 0, 0, 26)

        local MiniLabel = Instance.new("TextLabel")
        MiniLabel.Name = "Title"
        MiniLabel.Parent = MiniFrame
        MiniLabel.BackgroundTransparency = 1
        MiniLabel.Size = UDim2.new(1, 0, 0.65, 0)
        MiniLabel.Font = Enum.Font.GothamBold
        MiniLabel.Text = SectionName
        MiniLabel.TextColor3 = Theme.MainRed
        MiniLabel.TextSize = 13
        MiniLabel.TextXAlignment = Enum.TextXAlignment.Left

        local MiniLine = Instance.new("Frame")
        MiniLine.Name = "Line"
        MiniLine.Parent = MiniFrame
        MiniLine.BackgroundColor3 = Theme.MainRed
        MiniLine.BorderSizePixel = 0
        MiniLine.Size = UDim2.new(1, 0, 0, 1)
        MiniLine.Position = UDim2.new(0, 0, 0.85, 0)

        return {}
    end

    -- ═══════════════════════════════════════════════════════
    --  ADD SEPERATOR (старый, для совместимости)
    -- ═══════════════════════════════════════════════════════
    function WindowObj:AddSeperator()
        local FullSepFrame = Instance.new("Frame")
        FullSepFrame.Name = "SeperatorFrame"
        FullSepFrame.Parent = FullContainer
        FullSepFrame.BackgroundTransparency = 1
        FullSepFrame.Size = UDim2.new(1, 0, 0, 20)

        local FullLine = Instance.new("Frame")
        FullLine.Name = "Line"
        FullLine.Parent = FullSepFrame
        FullLine.BackgroundColor3 = Theme.Text
        FullLine.BorderSizePixel = 0
        FullLine.Size = UDim2.new(1, 0, 0, 2)
        FullLine.Position = UDim2.new(0, 0, 0.5, 0)

        local FullGradient = Instance.new("UIGradient")
        FullGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Theme.Background),
            ColorSequenceKeypoint.new(0.50, Theme.MainRed),
            ColorSequenceKeypoint.new(1.00, Theme.Background)
        })
        FullGradient.Parent = FullLine

        local MiniSpacer = Instance.new("Frame")
        MiniSpacer.Name = "SepSpacer"
        MiniSpacer.BackgroundTransparency = 1
        MiniSpacer.Size = UDim2.new(1, 0, 0, 10)
        MiniSpacer.Parent = MiniContainer

        local MiniLine = Instance.new("Frame")
        MiniLine.Name = "Seperator"
        MiniLine.Parent = MiniSpacer
        MiniLine.BackgroundColor3 = Theme.Text
        MiniLine.BackgroundTransparency = 0
        MiniLine.BorderSizePixel = 0
        MiniLine.Size = UDim2.new(1, 0, 0, 2)
        MiniLine.Position = UDim2.new(0, 0, 0.5, 0)

        local MiniGradient = Instance.new("UIGradient")
        MiniGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Theme.SecondaryBG),
            ColorSequenceKeypoint.new(0.50, Theme.MainRed),
            ColorSequenceKeypoint.new(1.00, Theme.SecondaryBG)
        })
        MiniGradient.Parent = MiniLine

        return {}
    end

    -- ═══════════════════════════════════════════════════════
    --  ADD STAT (+ Rolling Counter)
    -- ═══════════════════════════════════════════════════════
    function WindowObj:AddStat(StatName: string, InitialValue: string | number, Format: boolean?)
        local shouldFormat = if Format == nil then true else Format
        local StatObj = {}
        local currentNum = tonumber(InitialValue)

        -- NumberValue для Rolling Counter (TweenService сам интерполирует)
        local RollNumber = Instance.new("NumberValue")
        RollNumber.Value = currentNum or 0
        RollNumber.Parent = Xyesos

        local FullStatFrame = Instance.new("Frame")
        FullStatFrame.Name = "Stat_" .. StatName
        FullStatFrame.Parent = FullContainer
        FullStatFrame.BackgroundColor3 = Theme.Text
        FullStatFrame.BackgroundTransparency = 0.95
        FullStatFrame.BorderSizePixel = 0
        FullStatFrame.Size = UDim2.new(1, 0, 0.06, 0)

        local FullCorner = Instance.new("UICorner")
        FullCorner.CornerRadius = UDim.new(0, 8)
        FullCorner.Parent = FullStatFrame

        local FullStatLabel = Instance.new("TextLabel")
        FullStatLabel.Name = "Label"
        FullStatLabel.Parent = FullStatFrame
        FullStatLabel.BackgroundTransparency = 1.000
        FullStatLabel.Position = UDim2.new(0.02, 0, 0, 0)
        FullStatLabel.Size = UDim2.new(0.48, 0, 1, 0)
        FullStatLabel.Font = Enum.Font.GothamBold
        FullStatLabel.Text = StatName
        FullStatLabel.TextColor3 = Theme.TextDim
        FullStatLabel.TextScaled = true
        FullStatLabel.TextWrapped = true
        FullStatLabel.TextXAlignment = Enum.TextXAlignment.Left

        local FullValueLabel = Instance.new("TextLabel")
        FullValueLabel.Name = "Value"
        FullValueLabel.Parent = FullStatFrame
        FullValueLabel.BackgroundTransparency = 1.000
        FullValueLabel.Position = UDim2.new(0.5, 0, 0, 0)
        FullValueLabel.Size = UDim2.new(0.48, 0, 1, 0)
        FullValueLabel.Font = Enum.Font.GothamBold
        FullValueLabel.Text = tostring(InitialValue)
        FullValueLabel.TextColor3 = Theme.Text
        FullValueLabel.TextScaled = true
        FullValueLabel.TextWrapped = true
        FullValueLabel.TextXAlignment = Enum.TextXAlignment.Right

        local FullValueGradient = Instance.new("UIGradient")
        FullValueGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.MainRed),
            ColorSequenceKeypoint.new(1, Theme.DarkRed)
        })
        FullValueGradient.Parent = FullValueLabel

        -- Легкое свечение у значения (1 UIStroke)
        local FullValueStroke = Instance.new("UIStroke")
        FullValueStroke.Color = Theme.MainRed
        FullValueStroke.Transparency = 0.85
        FullValueStroke.Thickness = 1.5
        FullValueStroke.Parent = FullValueLabel

        local MiniStatFrame = Instance.new("Frame")
        MiniStatFrame.Name = "StatFrame_" .. StatName
        MiniStatFrame.Parent = MiniContainer
        MiniStatFrame.BackgroundColor3 = Color3.fromRGB(45, 35, 35)
        MiniStatFrame.BackgroundTransparency = 0.5
        MiniStatFrame.BorderSizePixel = 0
        MiniStatFrame.Size = UDim2.new(1, 0, 0, 35)

        local MiniCorner = Instance.new("UICorner")
        MiniCorner.CornerRadius = UDim.new(0, 6)
        MiniCorner.Parent = MiniStatFrame

        local MiniNameLabel = Instance.new("TextLabel")
        MiniNameLabel.Name = "Name"
        MiniNameLabel.Parent = MiniStatFrame
        MiniNameLabel.BackgroundTransparency = 1
        MiniNameLabel.Position = UDim2.new(0, 10, 0, 0)
        MiniNameLabel.Size = UDim2.new(0.5, -10, 1, 0)
        MiniNameLabel.Font = Enum.Font.GothamMedium
        MiniNameLabel.Text = StatName
        MiniNameLabel.TextColor3 = Theme.TextDim
        MiniNameLabel.TextSize = 14
        MiniNameLabel.TextXAlignment = Enum.TextXAlignment.Left

        local MiniValueLabel = Instance.new("TextLabel")
        MiniValueLabel.Name = "Value"
        MiniValueLabel.Parent = MiniStatFrame
        MiniValueLabel.BackgroundTransparency = 1
        MiniValueLabel.Position = UDim2.new(0.5, 0, 0, 0)
        MiniValueLabel.Size = UDim2.new(0.5, -10, 1, 0)
        MiniValueLabel.Font = Enum.Font.GothamBold
        MiniValueLabel.Text = tostring(InitialValue)
        MiniValueLabel.TextColor3 = Theme.Text
        MiniValueLabel.TextSize = 14
        MiniValueLabel.TextXAlignment = Enum.TextXAlignment.Right

        -- Обновление текста из NumberValue (TweenService驱动)
        local function RefreshText()
            local v = RollNumber.Value
            if shouldFormat then
                local txt = FormatValue(v)
                FullValueLabel.Text = txt
                MiniValueLabel.Text = txt
            else
                local txt = tostring(math.floor(v * 100) / 100)
                FullValueLabel.Text = txt
                MiniValueLabel.Text = txt
            end
        end

        RollNumber.Changed:Connect(RefreshText)

        if not currentNum then
            FullValueLabel.Text = tostring(InitialValue)
            MiniValueLabel.Text = tostring(InitialValue)
        else
            RefreshText()
        end

        function StatObj:Update(NewValue)
            local n = tonumber(NewValue)
            if not n then
                FullValueLabel.Text = tostring(NewValue)
                MiniValueLabel.Text = tostring(NewValue)
                return
            end
            TweenService:Create(RollNumber, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Value = n}):Play()
        end

        function StatObj:SetTooltip(text)
            AttachTooltip(FullStatFrame, text)
            AttachTooltip(MiniStatFrame, text)
        end

        table.insert(StatsList, StatObj)
        return StatObj
    end

    -- ═══════════════════════════════════════════════════════
    --  ADD BUTTON (+ Hover)
    -- ═══════════════════════════════════════════════════════
    function WindowObj:AddButton(Text: string, Callback)
        local ButtonObj = {}

        local MiniBtn = Instance.new("TextButton")
        MiniBtn.Name = "Button_" .. Text
        MiniBtn.Parent = MiniContainer
        MiniBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 35)
        MiniBtn.Size = UDim2.new(1, 0, 0, 35)
        MiniBtn.Font = Enum.Font.GothamBold
        MiniBtn.Text = Text
        MiniBtn.TextColor3 = Theme.Text
        MiniBtn.TextSize = 14
        MiniBtn.AutoButtonColor = false

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = MiniBtn

        -- Hover-эффекты (0 постоянной нагрузки)
        local baseColor = Color3.fromRGB(40, 35, 35)
        local hoverColor = Color3.fromRGB(55, 45, 45)

        MiniBtn.MouseEnter:Connect(function()
            TweenService:Create(MiniBtn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
        end)
        MiniBtn.MouseLeave:Connect(function()
            TweenService:Create(MiniBtn, TweenInfo.new(0.15), {BackgroundColor3 = baseColor}):Play()
        end)

        MiniBtn.MouseButton1Click:Connect(function()
            local tween = TweenService:Create(MiniBtn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.MainRed})
            tween:Play()
            tween.Completed:Wait()
            TweenService:Create(MiniBtn, TweenInfo.new(0.1), {BackgroundColor3 = baseColor}):Play()
            Callback()
        end)

        function ButtonObj:SetTooltip(text)
            AttachTooltip(MiniBtn, text)
        end

        return ButtonObj
    end

    return WindowObj
end

return Library
