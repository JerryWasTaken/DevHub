local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

local UI = Material.Load({
    Title = "DevHub - Jailbreak",
    Style = 1,
    SizeX = 500,
    SizeY = 300,
    Theme = "Dark",
})

local plr = game:GetService("Players").LocalPlayer
local char = plr.Character
local humanoid = char.Humanoid
local rootpart = char.HumanoidRootPart

local gmt = getrawmetatable(game)
		setreadonly(gmt, false)
		local oldindex = gmt.__index
		gmt.__index = newcclosure(function(self,b)
			if b == "WalkSpeed" then
				return 16
			end
			if b == "JumpPower" then
				return 50
			end
			return oldindex(self,b)
		end)
		
--[[
local page1 = UI.New({
    Title = "Main"
})
--]]

local page3 = UI.New({
    Title = "LocalPlayer"
})

local WalkSpeed = page3.Slider({
    Text = "Walkspeed",
    Callback = function(Value)
		game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end,
    Min = 16,
    Max = 250,
    Def = 16
})

local Jumppower = page3.Slider({
    Text = "Jumppower",
    Callback = function(Value)
		game:GetService("Players").LocalPlayer.Character.Humanoid.JumpPower = Value
    end,
    Min = 50,
    Max = 500,
    Def = 16
})

local Gravity = page3.Slider({
    Text = "Gravity",
    Callback = function(Value)
		game:GetService("Workspace").Gravity = Value
    end,
    Min = 0,
    Max = 196.2,
    Def = 0
})

local FOV = page3.Slider({
    Text = "Field Of View",
    Callback = function(Value)
		game:GetService("Workspace").Camera.FieldOfView = Value
    end,
    Min = 70,
    Max = 120,
    Def = 70
})

local InfiniteJump = page3.Toggle({
    Text = "InfiniteJump",
    Callback = function(Value)
		_G.infinjump = Value

local Player = game:GetService("Players").LocalPlayer
	if _G.infinjump then
		Humanoid = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		Humanoid:ChangeState("Jumping")
		wait(0.1)
		Humanoid:ChangeState("Seated")
		end
		
		if _G.infinjump == true then
			_G.infinjump = false
			else
			_G.infinjump = true
		end
    end,
    Enabled = false
})

local InfiniteJump = page3.Toggle({
    Text = "Clicktp [Not Working.]",
    Callback = function(Value)
		_G.Clicktp = Value
		
		local Mouse = game:GetService('Players').LocalPlayer:GetMouse()
		
		while true do
			if not _G.Fly then return end
			mouse.Button1Down:Connect(function()
				if Mouse.Target then
					local teleport = loadstring(game:HttpGet("https://raw.githubusercontent.com/Introvert1337/RobloxReleases/main/Scripts/Jailbreak/Teleporation.lua"))();
				teleport(CFrame.new(Mouse.Hit.x, Mouse.Hit.y + 5, Mouse.Hit.z));
				end
			end)
		end
    end,
    Enabled = false
})

local Fly = page3.Toggle({
    Text = "Fly",
    Callback = function(Value)
		_G.Fly = Value
      
		while true do
			if not _G.Fly then return end
			game:GetService('Players').LocalPlayer.Character.Humanoid.Name = "Humanoida"
repeat wait()
     game:GetService("StarterGui"):SetCore("SendNotification",{
                Title = "Jailbreak Admin V3",
                Text = "Press E 2 stop flying",
                Duration = 15,
                })
    
    until game:GetService"Players".LocalPlayer and game:GetService"Players".LocalPlayer.Character and game:GetService"Players".LocalPlayer.Character:findFirstChild("UpperTorso") and game:GetService"Players".LocalPlayer.Character:findFirstChild("Humanoida")
local mouse = game:GetService"Players".LocalPlayer:GetMouse()
repeat wait() until mouse
    local plr   = game:GetService"Players".LocalPlayer
    local torso = plr.Character.UpperTorso
local flying   = true
local deb      = true
local ctrl     = {f = 0, b = 0, l = 0, r = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0}
local maxspeed = 100
local speed    = 0
 
function Fly()
local bg = Instance.new("BodyGyro", torso)
bg.P = 9e4
bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
bg.cframe = torso.CFrame
local bv = Instance.new("BodyVelocity", torso)
bv.velocity = Vector3.new(0,0.1,0)
bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
repeat wait()
    plr.Character.Humanoida.PlatformStand = true
if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
speed = speed+.5+(speed/maxspeed)
if speed > maxspeed then
speed = maxspeed
end
elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
speed = speed-1
if speed < 0 then
speed = 0
end
end
if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
bv.velocity = ((game:GetService("Workspace").CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game:GetService("Workspace").CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game:GetService("Workspace").CurrentCamera.CoordinateFrame.p))*speed
lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
bv.velocity = ((game:GetService("Workspace").CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game:GetService("Workspace").CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game:GetService("Workspace").CurrentCamera.CoordinateFrame.p))*speed
else
bv.velocity = Vector3.new(0,0.1,0)
end
bg.cframe = game:GetService("Workspace").CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
until not flying
ctrl = {f = 0, b = 0, l = 0, r = 0}
lastctrl = {f = 0, b = 0, l = 0, r = 0}
speed = 0
bg:Destroy()
bv:Destroy()
plr.Character.Humanoida.PlatformStand = false
end
mouse.KeyDown:connect(function(key)
if key:lower() == "e" then
if flying then flying = false
else
flying = true
Fly()
end
elseif key:lower() == "w" then
ctrl.f = 1
elseif key:lower() == "s" then
ctrl.b = -1
elseif key:lower() == "a" then
ctrl.l = -1
elseif key:lower() == "d" then
ctrl.r = 1
end
end)
mouse.KeyUp:connect(function(key)
if key:lower() == "w" then
ctrl.f = 0
elseif key:lower() == "s" then
ctrl.b = 0
elseif key:lower() == "a" then
ctrl.l = 0
elseif key:lower() == "d" then
ctrl.r = 0
end
end)
Fly()
		end
    end,
    Enabled = false
})


local page2 = UI.New({
    Title = "Teleports"
})

local Button = page2.Button({
    Text = "Prison In",
    Callback = function()
        local teleport = loadstring(game:HttpGet("https://raw.githubusercontent.com/Introvert1337/RobloxReleases/main/Scripts/Jailbreak/Teleporation.lua"))();
        teleport(CFrame.new(-1233.56116, 18.4980164, -1740.74011, 0.996626258, 5.81633453e-09, -0.0820736066, -6.73784895e-09, 1, -1.09509353e-08, 0.0820736066, 1.14669891e-08, 0.996626258));
    end
})

local Button = page2.Button({
    Text = "Prison Out",
    Callback = function()
        local teleport = loadstring(game:HttpGet("https://raw.githubusercontent.com/Introvert1337/RobloxReleases/main/Scripts/Jailbreak/Teleporation.lua"))();
        teleport(CFrame.new(-1167.44385, 18.3958454, -1386.3313, 0.225322619, 2.62839421e-08, -0.974284232, 1.86601739e-08, 1, 3.12932329e-08, 0.974284232, -2.5231385e-08, 0.225322619));
    end
})

local Button = page2.Button({
    Text = "Jewlery In",
    Callback = function()
        local teleport = loadstring(game:HttpGet("https://raw.githubusercontent.com/Introvert1337/RobloxReleases/main/Scripts/Jailbreak/Teleporation.lua"))();
        teleport(CFrame.new(-1167.44385, 18.3958454, -1386.3313, 0.225322619, 2.62839421e-08, -0.974284232, 1.86601739e-08, 1, 3.12932329e-08, 0.974284232, -2.5231385e-08, 0.225322619));
    end
})

local Button = page2.Button({
    Text = "Jewlery Out",
    Callback = function()
        local teleport = loadstring(game:HttpGet("https://raw.githubusercontent.com/Introvert1337/RobloxReleases/main/Scripts/Jailbreak/Teleporation.lua"))();
        teleport(CFrame.new(150, 18, 1373));
    end
})


local page4 = UI.New({
    Title = "Combat"
})


local page5 = UI.New({
    Title = "Vehicle"
})

local page6 = UI.New({
    Title = "Misc"
})

local AutoRob = page6.Toggle({
    Text = "AutoRob [Coming soon.]",
    Callback = function(Value)
		_G.autorob = Value
		
    end,
    Enabled = false
})