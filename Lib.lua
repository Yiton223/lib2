local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui") 

local Library = {}
Library.__index = Library

-- Цветовая палитра для удобного изменения (Красная тема)
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
        if not (DragStart and StartPosition) then return end

        local Delta = input.Position - DragStart
        object.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input == DragInput then
            Update(input)
        end
    end)
end

local function FormatValue(Value)
    local n = tonumber(Value)
    if not n then return tostring(Value) end

    local suffixes = {"", "k", "M", "B", "T", "QD", "QN", "SX", "SP"}
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

function Library:CreateWindow(TitleText)
    local WindowObj = {}
    local StatsList = {}
    local IsFullscreen = true

    local Xyesos = Instance.new("ScreenGui")
    Xyesos.Name = "RedLib"
    Xyesos.Parent = CoreGui
    Xyesos.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Xyesos.IgnoreGuiInset = true
    Xyesos.ResetOnSpawn = false

    local FullscreenBG = Instance.new("Frame")
    FullscreenBG.Name = "FullscreenBackground"
    FullscreenBG.Parent = Xyesos
    FullscreenBG.BackgroundColor3 = Theme.Background
    FullscreenBG.BorderSizePixel = 0
    FullscreenBG.Size = UDim2.new(1, 0, 1, 0)
    FullscreenBG.Visible = true

    -- [ВИЗУАЛ] Красная аура дыхания на фоне
    local GlassAura = Instance.new("ImageLabel")
    GlassAura.Name = "GlassAura"
    GlassAura.Parent = FullscreenBG
    GlassAura.BackgroundTransparency = 1
    GlassAura.Position = UDim2.new(0, -50, 0, -50)
    GlassAura.Size = UDim2.new(1, 100, 1, 100)
    GlassAura.Image = "rbxassetid://5079174090"
    GlassAura.ImageColor3 = Theme.MainRed
    GlassAura.ImageTransparency = 0.92
    GlassAura.ZIndex = 0

    local auraTweenIn = TweenService:Create(GlassAura, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.88})
    local auraTweenOut = TweenService:Create(GlassAura, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.95})
    local function AnimateAura()
        auraTweenIn:Play()
        auraTweenIn.Completed:Connect(function()
            auraTweenOut:Play()
            auraTweenOut.Completed:Connect(AnimateAura)
        end)
    end
    AnimateAura()

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

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = Xyesos
    MainFrame.BackgroundColor3 = Theme.SecondaryBG
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false

    -- [ВИЗУАЛ] Фростед-стекло за мини окном
    local MainGlass = Instance.new("ImageLabel")
    MainGlass.Name = "MainGlass"
    MainGlass.Parent = MainFrame
    MainGlass.BackgroundTransparency = 1
    MainGlass.Position = UDim2.new(0, -20, 0, -20)
    MainGlass.Size = UDim2.new(1, 40, 1, 40)
    MainGlass.Image = "rbxassetid://5079174090"
    MainGlass.ImageColor3 = Theme.MainRed
    MainGlass.ImageTransparency = 0.94
    MainGlass.ZIndex = 0

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

    local function ToggleView()
        IsFullscreen = not IsFullscreen
        FullscreenBG.Visible = IsFullscreen
        MainFrame.Visible = not IsFullscreen
    end
    
    MakeDraggable(FloatToggleBtn, FloatToggleBtn)
    FloatToggleBtn.MouseButton1Click:Connect(ToggleView)

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

    function WindowObj:AddStat(StatName, InitialValue, Format)
        local shouldFormat = Format ~= false
        local StatObj = {}

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

        -- [ВИЗУАЛ] Стеклянная линия сверху карточки
        local FullGlassLine = Instance.new("Frame")
        FullGlassLine.Name = "GlassLine"
        FullGlassLine.Parent = FullStatFrame
        FullGlassLine.BackgroundTransparency = 0.7
        FullGlassLine.BackgroundColor3 = Theme.MainRed
        FullGlassLine.BorderSizePixel = 0
        FullGlassLine.Size = UDim2.new(1, 0, 0, 1)
        FullGlassLine.Position = UDim2.new(0, 0, 0, 0)

        local GlassLineGradient = Instance.new("UIGradient")
        GlassLineGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.MainRed),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Theme.MainRed)
        })
        GlassLineGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.3, 0.3),
            NumberSequenceKeypoint.new(0.7, 0.3),
            NumberSequenceKeypoint.new(1, 1)
        })
        GlassLineGradient.Parent = FullGlassLine

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

        -- [ВИЗУАЛ] Стеклянная линия сверху мини-карточки
        local MiniGlassLine = Instance.new("Frame")
        MiniGlassLine.Name = "MiniGlassLine"
        MiniGlassLine.Parent = MiniStatFrame
        MiniGlassLine.BackgroundTransparency = 0.7
        MiniGlassLine.BackgroundColor3 = Theme.MainRed
        MiniGlassLine.BorderSizePixel = 0
        MiniGlassLine.Size = UDim2.new(1, 0, 0, 1)
        MiniGlassLine.Position = UDim2.new(0, 0, 0, 0)

        local MiniGlassGradient = Instance.new("UIGradient")
        MiniGlassGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.MainRed),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Theme.MainRed)
        })
        MiniGlassGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.3, 0.3),
            NumberSequenceKeypoint.new(0.7, 0.3),
            NumberSequenceKeypoint.new(1, 1)
        })
        MiniGlassGradient.Parent = MiniGlassLine

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

        if shouldFormat then
            local formatted = FormatValue(InitialValue)
            FullValueLabel.Text = formatted
            MiniValueLabel.Text = formatted
        end

        -- [ОРИГИНАЛЬНАЯ ЛЕГКАЯ ЛОГИКА] Никаких анимаций и просчетов
        function StatObj:Update(NewValue)
            local finalValue = shouldFormat and FormatValue(NewValue) or tostring(NewValue)
            FullValueLabel.Text = finalValue
            MiniValueLabel.Text = finalValue
        end

        table.insert(StatsList, StatObj)
        return StatObj
    end

    function WindowObj:AddButton(Text, Callback)
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

        -- [ВИЗУАЛ] Стеклянная линия на кнопке
        local BtnGlassLine = Instance.new("Frame")
        BtnGlassLine.Name = "GlassLine"
        BtnGlassLine.Parent = MiniBtn
        BtnGlassLine.BackgroundTransparency = 0.5
        BtnGlassLine.BackgroundColor3 = Theme.MainRed
        BtnGlassLine.BorderSizePixel = 0
        BtnGlassLine.Size = UDim2.new(1, 0, 0, 1)
        BtnGlassLine.Position = UDim2.new(0, 0, 0, 0)

        local BtnGlassGradient = Instance.new("UIGradient")
        BtnGlassGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.MainRed),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Theme.MainRed)
        })
        BtnGlassGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.3, 0.2),
            NumberSequenceKeypoint.new(0.7, 0.2),
            NumberSequenceKeypoint.new(1, 1)
        })
        BtnGlassGradient.Parent = BtnGlassLine
        
        MiniBtn.MouseButton1Click:Connect(function()
            local tween = TweenService:Create(MiniBtn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.MainRed})
            tween:Play()
            tween.Completed:Wait()
            TweenService:Create(MiniBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 35, 35)}):Play()
            Callback()
        end)

        return ButtonObj
    end
    return WindowObj
end
return Library
