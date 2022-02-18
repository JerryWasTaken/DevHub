local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

local UI = Material.Load({
    Title = "DevHub - Anime Fighting Simulator",
    Style = 1,
    SizeX = 500,
    SizeY = 300,
    Theme = "Dark",
})

local page1 = UI.New({
    Title = "Main"
})

local plr = game.Players.LocalPlayer
local char = plr.Character
local humanoid = char.Humanoid
local rootpart = char.HumanoidRootPart

local ToggleAutoStrength = page1.Toggle({
    Text = "Auto Strength",
    Callback = function(Value)
		_G.strength = Value
      
		while true do
			if not _G.strength then return end
			local A_1 = "SpecialAction"
			local A_2 = 
			{
				["Request"] = "Click"
			}
			local Event = game:GetService("ReplicatedStorage").RSPackage.Events.GeneralEvent
			Event:FireServer(A_1, A_2)
			local A_1 = "Stat"
			local A_2 = "Strength"
			local Event = game:GetService("ReplicatedStorage").RSPackage.Events.StatFunction
			Event:InvokeServer(A_1, A_2)
			wait(0.25)
		end
    end,
    Enabled = false
})

local ToggleAutoDurability = page1.Toggle({
    Text = "Auto Durability",
    Callback = function(Value)
		_G.strength = Value
      
		while true do
			if not _G.strength then return end
			local A_1 = "SpecialAction"
			local A_2 = 
			{
				["Request"] = "Click"
			}
			local Event = game:GetService("ReplicatedStorage").RSPackage.Events.GeneralEvent
			Event:FireServer(A_1, A_2)
			local A_1 = "Stat"
			local A_2 = "Durability"
			local Event = game:GetService("ReplicatedStorage").RSPackage.Events.StatFunction
			Event:InvokeServer(A_1, A_2)
			wait(0.25)
		end
    end,
    Enabled = false
})

local ToggleAutoChakra = page1.Toggle({
    Text = "Auto Chakra",
    Callback = function(Value)
		_G.chakra = Value
      
		while true do
			if not _G.chakra then return end
			local A_1 = "Stat"
			local A_2 = "Chakra"
			local Event = game:GetService("ReplicatedStorage").RSPackage.Events.StatFunction
			Event:InvokeServer(A_1, A_2)
			wait(0.25)
		end
    end,
    Enabled = false
})

local ToggleAutoSword = page1.Toggle({
    Text = "Auto Sword",
    Callback = function(Value)
		_G.sword = Value
      
		while true do
			if not _G.sword then return end
			local A_1 = "SpecialAction"
			local A_2 = 
			{
				["Request"] = "Click"
			}
			local Event = game:GetService("ReplicatedStorage").RSPackage.Events.GeneralEvent
			Event:FireServer(A_1, A_2)
			local A_1 = "Stat"
			local A_2 = "Sword"
			local Event = game:GetService("ReplicatedStorage").RSPackage.Events.StatFunction
			Event:InvokeServer(A_1, A_2)
			wait(0.25)
		end
    end,
    Enabled = false
})

local page2 = UI.New({
    Title = "Teleports"
})

local Button = page2.Button({
    Text = "Boom",
    Callback = function()
        rootpart.CFrame = CFrame.new(1.06864488, 79.9751892, 18.7659473, -0.527328432, 3.12529274e-08, 0.849661529, -1.35535965e-08, 1, -4.51946107e-08, -0.849661529, -3.53483713e-08, -0.527328432)
    end
})

local Button = page2.Button({
    Text = "Wukong",
    Callback = function()
        rootpart.CFrame = CFrame.new(44.973774, 79.9751892, 19.8556328, -0.304864794, 3.36304105e-08, -0.952395618, -5.73586689e-08, 1, 5.36720748e-08, 0.952395618, 7.09908718e-08, -0.304864794)
    end
})


local page3 = UI.New({
    Title = "Misc"
})

local WalkSpeed = page3.Slider({
    Text = "Walkspeed",
    Callback = function(Value)
        humanoid.WalkSpeed = Value
    end,
    Min = 16,
    Max = 250,
    Def = 16
})

local Jumppower = page3.Slider({
    Text = "Jumppower",
    Callback = function(Value)
        humanoid.JumpPower = Value
    end,
    Min = 50,
    Max = 500,
    Def = 16
})