local WindowTable = {} -- We will be inserting Main Function in here

function WindowTable:CreateWindow(hubname, GameName)
    HubName = HubName or "NewHub"
    GameName = GameName or "Game"
	
	local Tutorial = Instance.new("ScreenGui")
    local Top = Instance.new("Frame")
    local HubName = Instance.new("TextLabel")
    local Game = Instance.new("TextLabel")
	local MainFrame = Instance.new("Frame")
	local mainCorner = Instance.new("UICorner")
	local SideBar = Instance.new("Frame")
	local sideCorner = Instance.new("UICorner")
	local coverCorner = Instance.new("Frame")
	local allTabs = Instance.new("Frame")
	local tabListing = Instance.new("UIListLayout")
	local allPages = Instance.new("Frame")
	local mainCorner_2 = Instance.new("UICorner")
    local Dash = Instance.new("TextLabel")
    local UIS = game:GetService("UserInputService")

	Tutorial.Name = "Tutorial"
	Tutorial.Parent = game.CoreGui	
	Tutorial.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	Tutorial.ResetOnSpawn = false

    function dragify(Frame)
        dragToggle = nil
        local dragSpeed = 0.50
        dragInput = nil
        dragStart = nil
        local dragPos = nil
        function updateInput(input)
            local Delta = input.Position - dragStart
            local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
            game:GetService("TweenService"):Create(Frame, TweenInfo.new(0.30), {Position = Position}):Play()
        end
        Frame.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and UIS:GetFocusedTextBox() == nil then
                dragToggle = true
                dragStart = input.Position
                startPos = Frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragToggle = false
                    end
                end)
            end
        end)
        Frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input == dragInput and dragToggle then
                updateInput(input)
            end
        end)
    end

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = Tutorial
    MainFrame.BackgroundColor3 = Color3.fromRGB(45, 48, 53)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.396969676, 0, 0.302184463, 0)
    MainFrame.Size = UDim2.new(0, 430, 0, 260)
    dragify(MainFrame)

    Top.Name = "Top"
    Top.Parent = MainFrame
    Top.BackgroundColor3 = Color3.fromRGB(45, 48, 53)
    Top.BorderColor3 = Color3.fromRGB(30, 30, 30)
    Top.BorderSizePixel = 0
    Top.Position = UDim2.new(0, 0, -0.0961538479, 0)
    Top.Size = UDim2.new(0, 430, 0, 25)    

    HubName.Name = "HubName"
    HubName.Parent = Top
    HubName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HubName.BackgroundTransparency = 1.000
    HubName.Position = UDim2.new(0.309741646, 0, 0.137391299, 0)
    HubName.Size = UDim2.new(0, 72, 0, 18)
    HubName.Font = Enum.Font.Gotham
    HubName.Text = hubname
    HubName.TextColor3 = Color3.fromRGB(255, 255, 255)
    HubName.TextSize = 15.000
    
    Game.Name = "Game"
    Game.Parent = Top
    Game.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Game.BackgroundTransparency = 1.000
    Game.Position = UDim2.new(0.518604517, 0, 0.137391359, 0)
    Game.Size = UDim2.new(0, 73, 0, 18)
    Game.Font = Enum.Font.Gotham
    Game.Text = GameName
    Game.TextColor3 = Color3.fromRGB(0, 170, 0)
    Game.TextSize = 15.000

    Dash.Name = "Dash"
    Dash.Parent = Top
    Dash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dash.BackgroundTransparency = 1.000
    Dash.Position = UDim2.new(0.421369553, 0, 0.137391359, 0)
    Dash.Size = UDim2.new(0, 64, 0, 18)
    Dash.Font = Enum.Font.Gotham
    Dash.Text = "-"
    Dash.TextColor3 = Color3.fromRGB(255, 255, 255)
    Dash.TextSize = 15.000

	mainCorner.CornerRadius = UDim.new(0, 0)
	mainCorner.Name = "mainCorner"
	mainCorner.Parent = MainFramewdwaw

	SideBar.Name = "SideBar"
	SideBar.Parent = MainFrame
	SideBar.BackgroundColor3 = Color3.fromRGB(35, 38, 42)
	SideBar.BorderSizePixel = 0
	SideBar.Size = UDim2.new(0, 110, 0, 260)

	sideCorner.CornerRadius = UDim.new(0, 3)
	sideCorner.Name = "sideCorner"
	sideCorner.Parent = SideBar

	coverCorner.Name = "coverCorner"
	coverCorner.Parent = SideBar
	coverCorner.BackgroundColor3 = Color3.fromRGB(35, 38, 42)
	coverCorner.BorderSizePixel = 0
	coverCorner.Position = UDim2.new(0.943925261, 0, 0, 0)
	coverCorner.Size = UDim2.new(0, 6, 0, 260)

	allTabs.Name = "allTabs"
	allTabs.Parent = SideBar
	allTabs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	allTabs.BackgroundTransparency = 1.000
	allTabs.Position = UDim2.new(0.0500000007, 0, 0.0299999993, 0)
	allTabs.Size = UDim2.new(0, 98, 0, 246)

	tabListing.Name = "tabListing"
	tabListing.Parent = allTabs
	tabListing.SortOrder = Enum.SortOrder.LayoutOrder
	tabListing.Padding = UDim.new(0, 2)

	allPages.Name = "allPages"
	allPages.Parent = MainFrame
	allPages.BackgroundColor3 = Color3.fromRGB(39, 42, 47)
	allPages.Position = UDim2.new(0.274418592, 0, 0.0269230772, 0)
	allPages.Size = UDim2.new(0, 306, 0, 245)

	mainCorner_2.CornerRadius = UDim.new(0, 3)
	mainCorner_2.Name = "mainCorner"
	mainCorner_2.Parent = allPages

	local pagesFolder = Instance.new("Folder")

	pagesFolder.Name = "pagesFolder"
	pagesFolder.Parent = allPages
	
	local TabHandler = {}
	
	function TabHandler:CreateTab(tabname)
		tabname = tabname or "New Tab"
		local tabButton = Instance.new("TextButton")
		local tabCorner = Instance.new("UICorner")
		local newPage = Instance.new("ScrollingFrame") 
		local elementsListing = Instance.new("UIListLayout")
        local Selected = Instance.new("Frame") 

		local elementsPadding = Instance.new("UIPadding")

		elementsPadding.Name = "elementsPadding"
		elementsPadding.Parent = newPage
		elementsPadding.PaddingRight = UDim.new(0, 5)
		elementsPadding.PaddingTop = UDim.new(0, 5)

        Selected.Name = "Selected"
        Selected.Parent = tabButton
        Selected.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Selected.Position = UDim2.new(0, 0, 0.167999268, 0)
        Selected.Size = UDim2.new(0, 3, 0, 13)
        Selected.Visible = false
		
		tabButton.Name = "tabButton"
		tabButton.Parent = allTabs
		tabButton.BackgroundColor3 = Color3.fromRGB(115, 49, 37)
		tabButton.Size = UDim2.new(0, 99, 0, 25)
		tabButton.Font = Enum.Font.Gotham
		tabButton.Text = tabname -- Displays our custom text
		tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		tabButton.TextSize = 14.000
		tabButton.AutoButtonColor = false	
		tabButton.MouseButton1Click:Connect(function()
			for i,v in next, pagesFolder:GetChildren() do -- We get all the pages that we added
				v.Visible = false	-- then we make them invisible 
			end 
			newPage.Visible = true	-- We make current page visible but not others
			
			--Animations Below  -- Optional
			for i,v in next, allTabs:GetChildren() do	-- We get all the elements inside the frame
				if v:IsA("TextButton") then -- We can't animate UIListLayout, so we check if its a TextButton
					game.TweenService:Create(v, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						BackgroundColor3 = Color3.fromRGB(115, 49, 37) -- We animate other Tab Buttons and making the current one seem Checked
					}):Play()
				end
			end
			game.TweenService:Create(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				BackgroundColor3 = Color3.fromRGB(43, 43, 43) -- We animate other Tab Buttons and making the current one seem Checked
			}):Play()
		end)

		tabCorner.CornerRadius = UDim.new(0, 3)
		tabCorner.Name = "sideCorner"
		tabCorner.Parent = tabButton
		
		newPage.Name = "newPage"
		newPage.Parent = pagesFolder
		newPage.Active = true
		newPage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		newPage.BackgroundTransparency = 1.000
		newPage.Size = UDim2.new(1, 0, 1, 0)
		newPage.ScrollBarThickness = 5
		newPage.Visible = false
		newPage.ZIndex = 99

		elementsListing.Name = "elementsListing"
		elementsListing.Parent = newPage
		elementsListing.HorizontalAlignment = Enum.HorizontalAlignment.Center
		elementsListing.SortOrder = Enum.SortOrder.LayoutOrder
		elementsListing.Padding = UDim.new(0, 5)
		
		local ElementHandler = {}
		
		function ElementHandler:CreateButton(btnText, callback)
			btnText = btnText or "Text Button"
			callback = callback or function() end	
			
			local TextButton = Instance.new("TextButton")
			local buttonCorner = Instance.new("UICorner")
			
			TextButton.Parent = newPage
			TextButton.BackgroundColor3 = Color3.fromRGB(44, 48, 53)
			TextButton.Position = UDim2.new(0.0245098043, 0, 0, 0)
			TextButton.Size = UDim2.new(0, 291, 0, 32)
			TextButton.AutoButtonColor = false
			TextButton.Font = Enum.Font.Gotham
			TextButton.Text = btnText
			TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextButton.TextSize = 14.000
			TextButton.ZIndex = 1
			TextButton.MouseButton1Click:Connect(function()
				callback()
			end)

			buttonCorner.CornerRadius = UDim.new(0, 3)
			buttonCorner.Name = "buttonCorner"
			buttonCorner.Parent = TextButton
		end

        function ElementHandler:CreateSlider(text, minvalue, maxvalue, callback)
            text = text or "Slider"
            minvalue = minvalue or 0
            maxvalue =  maxvalue or 100

            callback = callback or function() end

            local mouse = game.Players.LocalPlayer:GetMouse()
            local uis = game:GetService("UserInputService")
            local Value;

            local Slider = Instance.new("TextButton")
            local sliderButtonCover = Instance.new("UICorner")
            local sliderinfo = Instance.new("TextLabel")
            local SliderButton = Instance.new("TextButton")
            local SliderCorner = Instance.new("UICorner")
            local SliderFrame = Instance.new("Frame")
            local sliderCorner = Instance.new("UICorner")
            local Name = Instance.new("TextLabel")

            Slider.Name = "Slider"
        Slider.Parent = newPage
        Slider.BackgroundColor3 = Color3.fromRGB(44, 48, 53)
        Slider.Position = UDim2.new(0.0166112948, 0, 0.308333337, 0)
        Slider.Size = UDim2.new(0, 291, 0, 37)
        Slider.AutoButtonColor = false
        Slider.Font = Enum.Font.Gotham
        Slider.Text = ""
        Slider.TextColor3 = Color3.fromRGB(255, 255, 255)
        Slider.TextSize = 14.000

        sliderButtonCover.CornerRadius = UDim.new(0, 3)
        sliderButtonCover.Name = "sliderButtonCover"
        sliderButtonCover.Parent = Slider

        sliderinfo.Name = "sliderinfo"
        sliderinfo.Parent = Slider
        sliderinfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderinfo.BackgroundTransparency = 1.000
        sliderinfo.Position = UDim2.new(0.663230002, 0, 0, 0)
        sliderinfo.Size = UDim2.new(0, 90, 0, 13)
        sliderinfo.Font = Enum.Font.Gotham
        sliderinfo.Text = "10"
        sliderinfo.TextColor3 = Color3.fromRGB(255, 255, 255)
        sliderinfo.TextSize = 11.000
        sliderinfo.TextXAlignment = Enum.TextXAlignment.Right

        SliderButton.Name = "SliderButton"
        SliderButton.Parent = Slider
        SliderButton.BackgroundColor3 = Color3.fromRGB(61, 67, 74)
        SliderButton.Position = UDim2.new(0.0240549836, 0, 0.540540516, 0)
        SliderButton.Selectable = false
        SliderButton.Size = UDim2.new(0, 276, 0, 8)
        SliderButton.AutoButtonColor = false
        SliderButton.Font = Enum.Font.SourceSans
        SliderButton.Text = ""
        SliderButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        SliderButton.TextSize = 14.000

        SliderCorner.CornerRadius = UDim.new(0, 888)
        SliderCorner.Name = "SliderCorner"
        SliderCorner.Parent = SliderButton

        SliderFrame.Name = "SliderFrame"
        SliderFrame.Parent = SliderButton
        SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 109, 83)
        SliderFrame.Position = UDim2.new(0, 0, -0.0836143494, 0)
        SliderFrame.Size = UDim2.new(0, 0, 0, 8)

        sliderCorner.CornerRadius = UDim.new(0, 888)
        sliderCorner.Name = "sliderCorner"
        sliderCorner.Parent = SliderFrame

        Name.Name = "Name"
        Name.Parent = Slider
        Name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Name.BackgroundTransparency = 1.000
        Name.Position = UDim2.new(0.0240547452, 0, 0, 0)
        Name.Size = UDim2.new(0, 90, 0, 13)
        Name.Font = Enum.Font.Gotham
        Name.Text = text
        Name.TextColor3 = Color3.fromRGB(255, 255, 255)
        Name.TextSize = 11.000
        Name.TextXAlignment = Enum.TextXAlignment.Left
            
        SliderButton.MouseButton1Down:Connect(function()
        Value = math.floor((((tonumber(maxvalue) - tonumber(minvalue)) / 276) * SliderFrame.AbsoluteSize.X) + tonumber(minvalue)) or 0
        pcall(function()
            callback(Value)
        end)
        SliderFrame.Size = UDim2.new(0, math.clamp(mouse.X - SliderFrame.AbsolutePosition.X, 0, 276), 0, 8)
        moveconnection = mouse.Move:Connect(function()
            sliderinfo.Text = Value
            Value = math.floor((((tonumber(maxvalue) - tonumber(minvalue)) / 276) * SliderFrame.AbsoluteSize.X) + tonumber(minvalue))
            pcall(function()
                callback(Value)
            end)
            SliderFrame.Size = UDim2.new(0, math.clamp(mouse.X - SliderFrame.AbsolutePosition.X, 0, 276), 0, 8)
        end)
        releaseconnection = uis.InputEnded:Connect(function(Mouse)
            if Mouse.UserInputType == Enum.UserInputType.MouseButton1 then
                Value = math.floor((((tonumber(maxvalue) - tonumber(minvalue)) / 276) * SliderFrame.AbsoluteSize.X) + tonumber(minvalue))
                pcall(function()
                    callback(Value)
                end)
                SliderFrame.Size = UDim2.new(0, math.clamp(mouse.X - SliderFrame.AbsolutePosition.X, 0, 276), 0, 8)
                moveconnection:Disconnect()
                releaseconnection:Disconnect()
        end
    end)
end)

        end
		
		function ElementHandler:CreateToggle(togInfo, callback)
			togInfo = togInfo or "Toggle"
			callback = callback or function() end	

			local toggleButton = Instance.new("TextButton")
			local toggleButtonCover = Instance.new("UICorner")
			local toggle = Instance.new("Frame")
			local toggleCorner = Instance.new("UICorner")
			local toggleInfo = Instance.new("TextLabel")

			toggleButton.Name = "toggleButton"
			toggleButton.Parent = newPage
			toggleButton.BackgroundColor3 = Color3.fromRGB(44, 48, 53)
			toggleButton.Position = UDim2.new(0.0245098043, 0, 0, 0)
			toggleButton.Size = UDim2.new(0, 291, 0, 32)
			toggleButton.AutoButtonColor = false
			toggleButton.Font = Enum.Font.Gotham
			toggleButton.Text = ""
			toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			toggleButton.TextSize = 14.000

			toggleButtonCover.CornerRadius = UDim.new(0, 3)
			toggleButtonCover.Name = "toggleButtonCover"
			toggleButtonCover.Parent = toggleButton

			toggle.Name = "toggle"
			toggle.Parent = toggleButton
			toggle.BackgroundColor3 = Color3.fromRGB(61, 67, 74)
			toggle.Position = UDim2.new(0.0240549836, 0, 0.15625, 0)
			toggle.Size = UDim2.new(0, 22, 0, 22)

			toggleCorner.CornerRadius = UDim.new(0, 888)
			toggleCorner.Name = "toggleCorner"
			toggleCorner.Parent = toggle

			toggleInfo.Name = "toggleInfo"
			toggleInfo.Parent = toggleButton
			toggleInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			toggleInfo.BackgroundTransparency = 1.000
			toggleInfo.Position = UDim2.new(0.130584195, 0, 0, 0)
			toggleInfo.Size = UDim2.new(0, 230, 0, 32)
			toggleInfo.Font = Enum.Font.Gotham
			toggleInfo.Text = togInfo --- We set our custom text here
			toggleInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
			toggleInfo.TextSize = 14.000
			toggleInfo.TextXAlignment = Enum.TextXAlignment.Left
			
			local tog = false
			
			toggleButton.MouseButton1Click:Connect(function()
				tog = not tog
				callback(tog) -- Callbacks whenever we toggle
				if tog then 
					game.TweenService:Create(toggle, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						BackgroundColor3 = Color3.fromRGB(255, 109, 83)
					}):Play()
					--- We put our animation here when the toggle is on
				else
					game.TweenService:Create(toggle, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						BackgroundColor3 = Color3.fromRGB(61, 67, 74)
					}):Play()
					---We Put our animation here when the toggle is off
				end
			end)
		end
		
		return ElementHandler
	end
	return TabHandler
end
