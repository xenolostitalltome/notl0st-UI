--[=[
	notl0st UI - Complete Unified Library & Manager
	Professional Roblox UI Framework - All-in-One Script
	Polished • Animated • Modern • Draggable with Rounded Corners
]=]--

local cloneref = (cloneref or clonereference or function(instance: any)
	return instance
end)

local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))

local getgenv = getgenv or function()
	return shared
end

-- Configuration
local CONFIG = {
	VERSION = "1.0.0",
	SCRIPT_NAME = "notl0st UI",
	
	-- Colors
	COLORS = {
		Background = Color3.fromRGB(12, 12, 12),
		Secondary = Color3.fromRGB(18, 18, 18),
		Tertiary = Color3.fromRGB(25, 25, 25),
		Border = Color3.fromRGB(40, 40, 40),
		Text = Color3.fromRGB(220, 220, 220),
		TextDark = Color3.fromRGB(120, 120, 120),
		Accent = Color3.fromRGB(100, 100, 100),
		AccentBright = Color3.fromRGB(140, 140, 140),
		Success = Color3.fromRGB(76, 175, 80),
		Error = Color3.fromRGB(244, 67, 54),
		Warning = Color3.fromRGB(255, 193, 7),
		Info = Color3.fromRGB(33, 150, 243),
	},
	
	-- Animation Timing
	ANIMATION = {
		FAST = 0.15,
		NORMAL = 0.25,
		SLOW = 0.4,
		EASING = Enum.EasingStyle.Quad,
		EASING_DIRECTION = Enum.EasingDirection.Out,
	},
	
	-- UI Metrics
	METRICS = {
		CORNER_RADIUS = 6,
		PADDING = 10,
		BUTTON_HEIGHT = 36,
		SLIDER_HEIGHT = 24,
		TEXTBOX_HEIGHT = 36,
		NOTIFICATION_WIDTH = 320,
		NOTIFICATION_HEIGHT = 80,
	},
	
	-- Fonts
	FONT = Enum.Font.GothamSemibold,
}

-- ============ UTILITY FUNCTIONS ============

local Utils = {}

function Utils.CreateInstance(className, properties)
	local instance = Instance.new(className)
	for prop, value in pairs(properties or {}) do
		instance[prop] = value
	end
	return instance
end

function Utils.Tween(instance, duration, properties)
	local info = TweenInfo.new(
		duration,
		CONFIG.ANIMATION.EASING,
		CONFIG.ANIMATION.EASING_DIRECTION
	)
	local tween = TweenService:Create(instance, info, properties)
	tween:Play()
	return tween
end

function Utils.GetTextSize(text, textSize, font)
	local textBounds = TextService:GetTextSize(text, textSize, font, Vector2.new(math.huge, math.huge))
	return textBounds
end

-- ============ MAIN UI LIBRARY ============

local Library = {}
Library.__index = Library

function Library.new()
	local self = setmetatable({}, Library)
	
	self.screenGui = nil
	self.notifications = {}
	self.windows = {}
	self.draggedWindow = nil
	self.buttons = {}
	self.toggles = {}
	self.sliders = {}
	
	self:Initialize()
	
	return self
end

function Library:Initialize()
	-- Create main ScreenGui
	self.screenGui = Utils.CreateInstance("ScreenGui", {
		Name = "notl0st_UI",
		ResetOnSpawn = false,
		DisplayOrder = 2147483647,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	self.screenGui.Parent = CoreGui
	
	-- Protect GUI if available
	local protectGui = (syn and syn.protect_gui) or function(gui) end
	protectGui(self.screenGui)
	
	-- Add footer
	self:AddFooter()
	
	-- Setup input handling
	self:SetupInputHandling()
end

function Library:AddFooter()
	local footerFrame = Utils.CreateInstance("Frame", {
		Name = "Footer",
		BackgroundColor3 = CONFIG.COLORS.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.new(0, 0, 1, -30),
	})
	footerFrame.Parent = self.screenGui
	
	-- Corner
	local corner = Utils.CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, CONFIG.METRICS.CORNER_RADIUS),
	})
	corner.Parent = footerFrame
	
	-- Script name label
	local scriptLabel = Utils.CreateInstance("TextLabel", {
		Name = "ScriptName",
		BackgroundTransparency = 1,
		TextColor3 = CONFIG.COLORS.TextDark,
		TextSize = 11,
		Font = CONFIG.FONT,
		Text = "Script: " .. CONFIG.SCRIPT_NAME .. " v" .. CONFIG.VERSION,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(1, -10, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
	})
	scriptLabel.Parent = footerFrame
	
	self.footer = footerFrame
end

function Library:SetupInputHandling()
	-- Drag detection for windows
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			for _, window in pairs(self.windows) do
				if self:IsMouseOverElement(window.titleBar) then
					self.draggedWindow = window
					local mouse = Players.LocalPlayer:GetMouse()
					window._dragOffset = Vector2.new(
						mouse.X - window.frame.AbsolutePosition.X,
						mouse.Y - window.frame.AbsolutePosition.Y
					)
					break
				end
			end
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.draggedWindow = nil
		end
	end)
	
	RunService.RenderStepped:Connect(function()
		if self.draggedWindow then
			local mouse = Players.LocalPlayer:GetMouse()
			local offset = self.draggedWindow._dragOffset
			self.draggedWindow.frame.Position = UDim2.new(0, mouse.X - offset.X, 0, mouse.Y - offset.Y)
		end
	end)
end

function Library:IsMouseOverElement(element)
	if not element then return false end
	local mouse = Players.LocalPlayer:GetMouse()
	local mousePos = Vector2.new(mouse.X, mouse.Y)
	
	local absPosX = element.AbsolutePosition.X
	local absPosY = element.AbsolutePosition.Y
	local absSizeX = element.AbsoluteSize.X
	local absSizeY = element.AbsoluteSize.Y
	
	return mousePos.X >= absPosX and mousePos.X <= absPosX + absSizeX and
		   mousePos.Y >= absPosY and mousePos.Y <= absPosY + absSizeY
end

-- ============ WINDOW CREATION ============

function Library:CreateWindow(name, description)
	local window = {}
	window.name = name
	window.description = description or ""
	window.sections = {}
	window.elements = {}
	
	-- Create main frame with rounded corners
	window.frame = Utils.CreateInstance("Frame", {
		Name = "Window_" .. name,
		BackgroundColor3 = CONFIG.COLORS.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 500, 0, 400),
		Position = UDim2.new(0.5, -250, 0.5, -200),
		ClipsDescendants = true,
	})
	window.frame.Parent = self.screenGui
	
	-- POLISHED: Add corner radius to window
	local corner = Utils.CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, CONFIG.METRICS.CORNER_RADIUS),
	})
	corner.Parent = window.frame
	
	-- POLISHED: Add stroke for polish
	local stroke = Utils.CreateInstance("UIStroke", {
		Color = CONFIG.COLORS.Border,
		Thickness = 1,
	})
	stroke.Parent = window.frame
	
	-- Title bar with rounded top corners
	window.titleBar = Utils.CreateInstance("Frame", {
		Name = "TitleBar",
		BackgroundColor3 = CONFIG.COLORS.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 50),
	})
	window.titleBar.Parent = window.frame
	
	local titleCorner = Utils.CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, CONFIG.METRICS.CORNER_RADIUS),
	})
	titleCorner.Parent = window.titleBar
	
	-- Title text
	local titleLabel = Utils.CreateInstance("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		TextColor3 = CONFIG.COLORS.Text,
		TextSize = 16,
		Font = CONFIG.FONT,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.new(0, 10, 0, 10),
	})
	titleLabel.Parent = window.titleBar
	
	-- Description
	if description ~= "" then
		local descLabel = Utils.CreateInstance("TextLabel", {
			Name = "Description",
			BackgroundTransparency = 1,
			TextColor3 = CONFIG.COLORS.TextDark,
			TextSize = 12,
			Font = CONFIG.FONT,
			Text = description,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -20, 0, 15),
			Position = UDim2.new(0, 10, 0, 30),
		})
		descLabel.Parent = window.titleBar
	end
	
	-- Scroll container
	window.scrollFrame = Utils.CreateInstance("ScrollingFrame", {
		Name = "Content",
		BackgroundColor3 = CONFIG.COLORS.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -50),
		Position = UDim2.new(0, 0, 0, 50),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = CONFIG.COLORS.Accent,
	})
	window.scrollFrame.Parent = window.frame
	
	-- UIListLayout for content
	local listLayout = Utils.CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 8),
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	listLayout.Parent = window.scrollFrame
	
	-- Update canvas size when content changes
	listLayout.Changed:Connect(function()
		window.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 16)
	end)
	
	-- Make title bar draggable
	window.titleBar.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mouse = Players.LocalPlayer:GetMouse()
			window._dragOffset = Vector2.new(
				mouse.X - window.frame.AbsolutePosition.X,
				mouse.Y - window.frame.AbsolutePosition.Y
			)
		end
	end)
	
	table.insert(self.windows, window)
	return window
end

-- ============ SECTION CREATION ============

function Library:CreateSection(window, name)
	local section = {}
	section.name = name
	section.elements = {}
	
	local container = Utils.CreateInstance("Frame", {
		Name = "Section_" .. name,
		BackgroundColor3 = CONFIG.COLORS.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -16, 0, 0),
		LayoutOrder = #window.sections + 1,
	})
	
	-- Add padding
	local padding = Utils.CreateInstance("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
	})
	padding.Parent = container
	
	-- Add corner (polished)
	local corner = Utils.CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
	})
	corner.Parent = container
	
	-- Section title
	local titleLabel = Utils.CreateInstance("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		TextColor3 = CONFIG.COLORS.Text,
		TextSize = 14,
		Font = CONFIG.FONT,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 20),
	})
	titleLabel.Parent = container
	
	-- Content container
	section.contentFrame = Utils.CreateInstance("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -20),
		Position = UDim2.new(0, 0, 0, 25),
	})
	section.contentFrame.Parent = container
	
	local layout = Utils.CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 8),
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	layout.Parent = section.contentFrame
	
	section.container = container
	container.Parent = window.scrollFrame
	
	table.insert(window.sections, section)
	return section
end

-- ============ BUTTON CREATION ============

function Library:CreateButton(section, label, callback)
	local button = {}
	button.label = label
	button.callback = callback
	
	local frame = Utils.CreateInstance("TextButton", {
		Name = "Button_" .. label,
		BackgroundColor3 = CONFIG.COLORS.Tertiary,
		TextColor3 = CONFIG.COLORS.Text,
		TextSize = 13,
		Font = CONFIG.FONT,
		Text = label,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, CONFIG.METRICS.BUTTON_HEIGHT),
		AutoButtonColor = false,
		LayoutOrder = #section.elements + 1,
	})
	
	-- POLISHED: Corner
	local corner = Utils.CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
	})
	corner.Parent = frame
	
	-- POLISHED: Stroke
	local stroke = Utils.CreateInstance("UIStroke", {
		Color = CONFIG.COLORS.Border,
		Thickness = 1,
	})
	stroke.Parent = frame
	
	-- Hover animation
	frame.MouseEnter:Connect(function()
		Utils.Tween(frame, CONFIG.ANIMATION.FAST, {
			BackgroundColor3 = CONFIG.COLORS.Accent,
		})
		Utils.Tween(stroke, CONFIG.ANIMATION.FAST, {
			Color = CONFIG.COLORS.AccentBright,
		})
	end)
	
	frame.MouseLeave:Connect(function()
		Utils.Tween(frame, CONFIG.ANIMATION.FAST, {
			BackgroundColor3 = CONFIG.COLORS.Tertiary,
		})
		Utils.Tween(stroke, CONFIG.ANIMATION.FAST, {
			Color = CONFIG.COLORS.Border,
		})
	end)
	
	-- Click animation
	frame.MouseButton1Down:Connect(function()
		Utils.Tween(frame, 0.1, {
			Size = UDim2.new(1, 0, 0, CONFIG.METRICS.BUTTON_HEIGHT - 2),
		})
	end)
	
	frame.MouseButton1Up:Connect(function()
		Utils.Tween(frame, 0.1, {
			Size = UDim2.new(1, 0, 0, CONFIG.METRICS.BUTTON_HEIGHT),
		})
	end)
	
	frame.Activated:Connect(function()
		callback()
	end)
	
	frame.Parent = section.contentFrame
	
	button.frame = frame
	table.insert(section.elements, button)
	return button
end

-- ============ SLIDER CREATION ============

function Library:CreateSlider(section, label, min, max, default, callback)
	local slider = {}
	slider.label = label
	slider.min = min
	slider.max = max
	slider.value = default or min
	slider.callback = callback
	
	local container = Utils.CreateInstance("Frame", {
		Name = "Slider_" .. label,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 70),
		LayoutOrder = #section.elements + 1,
	})
	
	-- Label
	local titleLabel = Utils.CreateInstance("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		TextColor3 = CONFIG.COLORS.Text,
		TextSize = 13,
		Font = CONFIG.FONT,
		Text = label,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 20),
	})
	titleLabel.Parent = container
	
	-- Slider background
	local sliderBg = Utils.CreateInstance("Frame", {
		Name = "Background",
		BackgroundColor3 = CONFIG.COLORS.Tertiary,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, CONFIG.METRICS.SLIDER_HEIGHT),
		Position = UDim2.new(0, 0, 0, 25),
	})
	
	-- POLISHED: Background corner
	local bgCorner = Utils.CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 3),
	})
	bgCorner.Parent = sliderBg
	
	-- POLISHED: Background stroke
	local bgStroke = Utils.CreateInstance("UIStroke", {
		Color = CONFIG.COLORS.Border,
		Thickness = 1,
	})
	bgStroke.Parent = sliderBg
	
	sliderBg.Parent = container
	
	-- Slider fill
	local sliderFill = Utils.CreateInstance("Frame", {
		Name = "Fill",
		BackgroundColor3 = CONFIG.COLORS.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new((slider.value - min) / (max - min), 0, 1, 0),
	})
	
	local fillCorner = Utils.CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 3),
	})
	fillCorner.Parent = sliderFill
	
	sliderFill.Parent = sliderBg
	
	-- Value display
	local valueLabel = Utils.CreateInstance("TextLabel", {
		Name = "Value",
		BackgroundTransparency = 1,
		TextColor3 = CONFIG.COLORS.TextDark,
		TextSize = 12,
		Font = CONFIG.FONT,
		Text = tostring(math.floor(slider.value)),
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(1, -10, 0, 20),
		Position = UDim2.new(0, 5, 0, 25),
	})
	valueLabel.Parent = container
	
	-- Input handling
	sliderBg.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mouse = Players.LocalPlayer:GetMouse()
			local sliderSize = sliderBg.AbsoluteSize.X
			local sliderPos = sliderBg.AbsolutePosition.X
			
			local percent = math.clamp((mouse.X - sliderPos) / sliderSize, 0, 1)
			slider.value = min + (max - min) * percent
			
			Utils.Tween(sliderFill, CONFIG.ANIMATION.FAST, {
				Size = UDim2.new(percent, 0, 1, 0),
			})
			
			valueLabel.Text = tostring(math.floor(slider.value))
			callback(math.floor(slider.value))
		end
	end)
	
	sliderBg.MouseMoved:Connect(function(x, y)
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			local sliderSize = sliderBg.AbsoluteSize.X
			local sliderPos = sliderBg.AbsolutePosition.X
			
			local percent = math.clamp((x - sliderPos) / sliderSize, 0, 1)
			slider.value = min + (max - min) * percent
			
			Utils.Tween(sliderFill, 0.05, {
				Size = UDim2.new(percent, 0, 1, 0),
			})
			
			valueLabel.Text = tostring(math.floor(slider.value))
			callback(math.floor(slider.value))
		end
	end)
	
	container.Parent = section.contentFrame
	
	slider.frame = container
	slider.fill = sliderFill
	table.insert(section.elements, slider)
	return slider
end

-- ============ TEXTBOX CREATION ============

function Library:CreateTextBox(section, label, placeholder, callback)
	local textbox = {}
	textbox.label = label
	textbox.callback = callback
	
	local container = Utils.CreateInstance("Frame", {
		Name = "TextBox_" .. label,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 65),
		LayoutOrder = #section.elements + 1,
	})
	
	-- Label
	local titleLabel = Utils.CreateInstance("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		TextColor3 = CONFIG.COLORS.Text,
		TextSize = 13,
		Font = CONFIG.FONT,
		Text = label,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 20),
	})
	titleLabel.Parent = container
	
	-- TextBox
	local textBox = Utils.CreateInstance("TextBox", {
		Name = "Input",
		BackgroundColor3 = CONFIG.COLORS.Tertiary,
		TextColor3 = CONFIG.COLORS.Text,
		PlaceholderColor3 = CONFIG.COLORS.TextDark,
		PlaceholderText = placeholder or "Enter text...",
		TextSize = 13,
		Font = CONFIG.FONT,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, CONFIG.METRICS.TEXTBOX_HEIGHT),
		Position = UDim2.new(0, 0, 0, 25),
		ClearTextOnFocus = false,
	})
	
	-- POLISHED: Corner
	local corner = Utils.CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
	})
	corner.Parent = textBox
	
	-- POLISHED: Stroke
	local stroke = Utils.CreateInstance("UIStroke", {
		Color = CONFIG.COLORS.Border,
		Thickness = 1,
	})
	stroke.Parent = textBox
	
	-- Padding
	local padding = Utils.CreateInstance("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	})
	padding.Parent = textBox
	
	-- Focus animations
	textBox.Focused:Connect(function()
		Utils.Tween(textBox, CONFIG.ANIMATION.FAST, {
			BackgroundColor3 = CONFIG.COLORS.Secondary,
		})
		Utils.Tween(stroke, CONFIG.ANIMATION.FAST, {
			Color = CONFIG.COLORS.AccentBright,
		})
	end)
	
	textBox.FocusLost:Connect(function(enterPressed)
		Utils.Tween(textBox, CONFIG.ANIMATION.FAST, {
			BackgroundColor3 = CONFIG.COLORS.Tertiary,
		})
		Utils.Tween(stroke, CONFIG.ANIMATION.FAST, {
			Color = CONFIG.COLORS.Border,
		})
		
		if enterPressed then
			callback(textBox.Text)
		end
	end)
	
	textBox.Parent = container
	container.Parent = section.contentFrame
	
	textbox.frame = container
	textbox.input = textBox
	table.insert(section.elements, textbox)
	return textbox
end

-- ============ TOGGLE CREATION ============

function Library:CreateToggle(section, label, default, callback)
	local toggle = {}
	toggle.label = label
	toggle.enabled = default or false
	toggle.callback = callback
	
	local container = Utils.CreateInstance("Frame", {
		Name = "Toggle_" .. label,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
		LayoutOrder = #section.elements + 1,
	})
	
	-- Label
	local titleLabel = Utils.CreateInstance("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		TextColor3 = CONFIG.COLORS.Text,
		TextSize = 13,
		Font = CONFIG.FONT,
		Text = label,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -50, 0, 20),
		Position = UDim2.new(0, 0, 0, 10),
	})
	titleLabel.Parent = container
	
	-- Toggle switch
	local switchFrame = Utils.CreateInstance("Frame", {
		Name = "Switch",
		BackgroundColor3 = toggle.enabled and CONFIG.COLORS.Success or CONFIG.COLORS.Tertiary,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 50, 0, 28),
		Position = UDim2.new(1, -50, 0, 6),
	})
	
	-- POLISHED: Switch corner
	local switchCorner = Utils.CreateInstance("UICorner", {
		CornerRadius = UDim.new(0.5, 0),
	})
	switchCorner.Parent = switchFrame
	
	-- Toggle button inside switch
	local toggleButton = Utils.CreateInstance("Frame", {
		Name = "Button",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 24, 0, 24),
		Position = toggle.enabled and UDim2.new(0, 23, 0, 2) or UDim2.new(0, 2, 0, 2),
	})
	
	-- POLISHED: Button corner
	local buttonCorner = Utils.CreateInstance("UICorner", {
		CornerRadius = UDim.new(0.5, 0),
	})
	buttonCorner.Parent = toggleButton
	
	toggleButton.Parent = switchFrame
	
	-- Click handler
	switchFrame.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			toggle.enabled = not toggle.enabled
			
			Utils.Tween(switchFrame, CONFIG.ANIMATION.NORMAL, {
				BackgroundColor3 = toggle.enabled and CONFIG.COLORS.Success or CONFIG.COLORS.Tertiary,
			})
			
			Utils.Tween(toggleButton, CONFIG.ANIMATION.NORMAL, {
				Position = toggle.enabled and UDim2.new(0, 23, 0, 2) or UDim2.new(0, 2, 0, 2),
			})
			
			callback(toggle.enabled)
		end
	end)
	
	switchFrame.Parent = container
	container.Parent = section.contentFrame
	
	toggle.frame = container
	toggle.switchFrame = switchFrame
	toggle.toggleButton = toggleButton
	table.insert(section.elements, toggle)
	return toggle
end

-- ============ NOTIFICATION SYSTEM ============

function Library:Notify(title, message, duration, notificationType)
	notificationType = notificationType or "Info"
	duration = duration or 3
	
	local notifColors = {
		Info = CONFIG.COLORS.Info,
		Success = CONFIG.COLORS.Success,
		Error = CONFIG.COLORS.Error,
		Warning = CONFIG.COLORS.Warning,
	}
	
	local notif = {}
	
	-- Notification frame
	local frame = Utils.CreateInstance("Frame", {
		Name = "Notification",
		BackgroundColor3 = CONFIG.COLORS.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(0, CONFIG.METRICS.NOTIFICATION_WIDTH, 0, CONFIG.METRICS.NOTIFICATION_HEIGHT),
		Position = UDim2.new(1, 20, 1, -120),
	})
	
	-- POLISHED: Corner
	local corner = Utils.CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, CONFIG.METRICS.CORNER_RADIUS),
	})
	corner.Parent = frame
	
	-- POLISHED: Stroke
	local stroke = Utils.CreateInstance("UIStroke", {
		Color = CONFIG.COLORS.Border,
		Thickness = 1,
	})
	stroke.Parent = frame
	
	-- Colored indicator
	local indicator = Utils.CreateInstance("Frame", {
		Name = "Indicator",
		BackgroundColor3 = notifColors[notificationType] or CONFIG.COLORS.Info,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 4, 1, 0),
	})
	indicator.Parent = frame
	
	-- Padding
	local padding = Utils.CreateInstance("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 15),
		PaddingRight = UDim.new(0, 15),
	})
	padding.Parent = frame
	
	-- Title
	local titleLabel = Utils.CreateInstance("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		TextColor3 = CONFIG.COLORS.Text,
		TextSize = 13,
		Font = CONFIG.FONT,
		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(0.8, 0, 0, 20),
	})
	titleLabel.Parent = frame
	
	-- Message
	local messageLabel = Utils.CreateInstance("TextLabel", {
		Name = "Message",
		BackgroundTransparency = 1,
		TextColor3 = CONFIG.COLORS.TextDark,
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		Text = message,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(0.8, 0, 0, 50),
		Position = UDim2.new(0, 0, 0, 20),
	})
	messageLabel.Parent = frame
	
	frame.Parent = self.screenGui
	
	-- Calculate final Y position
	local yOffset = -120
	for _, existingNotif in pairs(self.notifications) do
		yOffset = yOffset - CONFIG.METRICS.NOTIFICATION_HEIGHT - 10
	end
	
	-- Animate in
	frame.Position = UDim2.new(1, 20, 1, yOffset - 20)
	Utils.Tween(frame, CONFIG.ANIMATION.NORMAL, {
		Position = UDim2.new(1, -CONFIG.METRICS.NOTIFICATION_WIDTH - 20, 1, yOffset),
	})
	
	table.insert(self.notifications, notif)
	
	-- Auto remove after duration
	task.wait(duration)
	
	Utils.Tween(frame, CONFIG.ANIMATION.NORMAL, {
		Position = UDim2.new(1, 20, 1, yOffset),
		BackgroundTransparency = 1,
	})
	
	frame.TweenCompleted:Connect(function()
		frame:Destroy()
		for i, n in pairs(self.notifications) do
			if n == notif then
				table.remove(self.notifications, i)
				break
			end
		end
	end)
end

-- ============ UTILITY METHODS ============

function Library:Destroy()
	if self.screenGui then
		self.screenGui:Destroy()
	end
end

-- ============ NOTIFICATION HELPERS ============

function Library:NotifySuccess(title, message, duration)
	self:Notify(title, message, duration or 3, "Success")
end

function Library:NotifyError(title, message, duration)
	self:Notify(title, message, duration or 3, "Error")
end

function Library:NotifyWarning(title, message, duration)
	self:Notify(title, message, duration or 3, "Warning")
end

function Library:NotifyInfo(title, message, duration)
	self:Notify(title, message, duration or 3, "Info")
end

-- ============ WINDOW MANAGEMENT ============

function Library:GetWindow(name)
	for _, window in pairs(self.windows) do
		if window.name == name then
			return window
		end
	end
	return nil
end

function Library:GetWindows()
	return self.windows
end

function Library:SetWindowVisible(window, visible)
	if type(window) == "string" then
		window = self:GetWindow(window)
	end
	
	if window and window.frame then
		window.frame.Visible = visible
	end
end

-- ============ CREATE GLOBAL INSTANCE ============
-- This is the unified UI library that can be used directly without requiring anything

local notl0stUI = Library.new()

-- Expose to global scope for easy access
getgenv("notl0stUI", notl0stUI)

-- ============ EXAMPLE USAGE (uncomment to test) ============

--[[
-- The library is now available as a global variable, no require needed!
-- Usage:

local ui = notl0stUI
local window = ui:CreateWindow("notl0st UI", "Professional Framework")
local section = ui:CreateSection(window, "Test Section")

ui:CreateButton(section, "Test Button", function()
	ui:NotifySuccess("Success!", "Button clicked!")
end)

ui:CreateSlider(section, "Value", 0, 100, 50, function(value)
	print("Value:", value)
end)

ui:CreateToggle(section, "Enable Feature", false, function(enabled)
	print("Enabled:", enabled)
end)

ui:NotifyInfo("Welcome", "notl0st UI loaded successfully!")
]]

-- ============ RETURN FOR REQUIRE ============

return notl0stUI
