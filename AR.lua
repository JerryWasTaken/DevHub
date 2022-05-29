--Teleport Method

local keys, network = loadstring(game:HttpGet("https://raw.githubusercontent.com/Introvert1337/RobloxReleases/main/Scripts/Jailbreak/KeyFetcher.lua"))();

local replicated_storage = game:GetService("ReplicatedStorage");
local run_service = game:GetService("RunService");
local pathfinding_service = game:GetService("PathfindingService");
local players = game:GetService("Players");
local tween_service = game:GetService("TweenService");

local player = players.LocalPlayer;

local dependencies = {
    variables = {
        up_vector = Vector3.new(0, 500, 0),
        raycast_params = RaycastParams.new(),
        path = pathfinding_service:CreatePath({WaypointSpacing = 3}),
        player_speed = 80, 
        vehicle_speed = 100
    },
    modules = {
        ui = require(replicated_storage.Module.UI),
        store = require(replicated_storage.App.store),
        player_utils = require(replicated_storage.Game.PlayerUtils),
        vehicle_data = require(replicated_storage.Game.Garage.VehicleData)
    },
    helicopters = {Heli = true}, -- heli is included in free vehicles
    motorcycles = {Volt = true}, -- volt type is "custom" but works the same as a motorcycle
    free_vehicles = {},
    unsupported_vehicles = {},
    door_positions = {}    
};

local movement = {};
local utilities = {};

--// function to toggle if a door can be collided with

function utilities:toggle_door_collision(door, toggle)
    for index, child in next, door.Model:GetChildren() do 
        if child:IsA("BasePart") then 
            child.CanCollide = toggle;
        end; 
    end;
end;

--// function to get the nearest vehicle that can be entered

function utilities:get_nearest_vehicle(tried) -- unoptimized
    local nearest;
    local distance = math.huge;

    for index, action in next, dependencies.modules.ui.CircleAction.Specs do -- all of the interations
        if action.IsVehicle and action.ShouldAllowEntry == true and action.Enabled == true and action.Name == "Enter Driver" then -- if the interaction is to enter the driver seat of a vehicle
            local vehicle = action.ValidRoot;

            if not table.find(tried, vehicle) and workspace.VehicleSpawns:FindFirstChild(vehicle.Name) then
                if not dependencies.unsupported_vehicles[vehicle.Name] and (dependencies.modules.store._state.garageOwned.Vehicles[vehicle.Name] or dependencies.free_vehicles[vehicle.Name]) and not vehicle.Seat.Player.Value then -- check if the vehicle is supported, owned and not already occupied
                    if not workspace:Raycast(vehicle.Seat.Position, dependencies.variables.up_vector, dependencies.variables.raycast_params) then
                        local magnitude = (vehicle.Seat.Position - player.Character.HumanoidRootPart.Position).Magnitude; 
            
                        if magnitude < distance then 
                            distance = magnitude;
                            nearest = vehicle;
                        end;
                    end;
                end;
            end;
        end;
    end;

    return nearest;
end;

--// function to pathfind to a position with no collision above

function movement:pathfind(tried)
    local distance = math.huge;
    local nearest;

    local tried = tried or {};
    
    for index, value in next, dependencies.door_positions do -- find the nearest position in our list of positions without collision above
        if not table.find(tried, value) then
            local magnitude = (value.position - player.Character.HumanoidRootPart.Position).Magnitude;
            
            if magnitude < distance then 
                distance = magnitude;
                nearest = value;
            end;
        end;
    end;

    table.insert(tried, nearest);

    utilities:toggle_door_collision(nearest.instance, false);

    local path = dependencies.variables.path;
    path:ComputeAsync(player.Character.HumanoidRootPart.Position, nearest.position);

    if path.Status == Enum.PathStatus.Success then -- if path making is successful
        local waypoints = path:GetWaypoints();

        for index = 1, #waypoints do 
            local waypoint = waypoints[index];
            
            player.Character.HumanoidRootPart.CFrame = CFrame.new(waypoint.Position + Vector3.new(0, 2.5, 0)); -- walking movement is less optimal

            if not workspace:Raycast(player.Character.HumanoidRootPart.Position, dependencies.variables.up_vector, dependencies.variables.raycast_params) then -- if there is nothing above the player
                utilities:toggle_door_collision(nearest.instance, true);

                return;
            end;

            task.wait(0.05);
        end;
    end;

    utilities:toggle_door_collision(nearest.instance, true);

    movement:pathfind(tried);
end;

--// function to interpolate characters position to a position

function movement:move_to_position(part, cframe, speed, car, target_vehicle, tried_vehicles)
    local vector_position = cframe.Position;
    
    if not car and workspace:Raycast(part.Position, dependencies.variables.up_vector, dependencies.variables.raycast_params) then -- if there is an object above us, use pathfind function to get to a position with no collision above
        movement:pathfind();
        task.wait(0.5);
    end;
    
    local y_level = 500;
    local higher_position = Vector3.new(vector_position.X, y_level, vector_position.Z); -- 500 studs above target position

    repeat -- use velocity to move towards the target position
        local velocity_unit = (higher_position - part.Position).Unit * speed;
        part.Velocity = Vector3.new(velocity_unit.X, 0, velocity_unit.Z);

        task.wait();

        part.CFrame = CFrame.new(part.CFrame.X, y_level, part.CFrame.Z);
    until (part.Position - higher_position).Magnitude < 10;

    part.CFrame = CFrame.new(part.Position.X, vector_position.Y, part.Position.Z);
    part.Velocity = Vector3.new(0, 0, 0);
end;

function movement:sellTP(part, cframe, speed, car, target_vehicle, tried_vehicles)
    local vector_position = cframe.Position;
    
    if not car and workspace:Raycast(part.Position, dependencies.variables.up_vector, dependencies.variables.raycast_params) then -- if there is an object above us, use pathfind function to get to a position with no collision above
        movement:pathfind();
        task.wait(0.5);
    end;
    
    local y_level = 100;
    local higher_position = Vector3.new(vector_position.X, y_level, vector_position.Z); -- 500 studs above target position

    repeat -- use velocity to move towards the target position
        local velocity_unit = (higher_position - part.Position).Unit * speed;
        part.Velocity = Vector3.new(velocity_unit.X, 0, velocity_unit.Z);

        task.wait();

        part.CFrame = CFrame.new(part.CFrame.X, y_level, part.CFrame.Z);

        if target_vehicle and target_vehicle.Seat.Player.Value then -- if someone occupies the vehicle while we're moving to it, we need to move to the next vehicle
            table.insert(tried_vehicles, target_vehicle);

            local nearest_vehicle = utilities:get_nearest_vehicle(tried_vehicles);

            if nearest_vehicle then 
                movement:move_to_position(player.Character.HumanoidRootPart, nearest_vehicle.Seat.CFrame, 135, false, nearest_vehicle);
            end;

            return;
        end;
    until (part.Position - higher_position).Magnitude < 10;

    part.CFrame = CFrame.new(part.Position.X, vector_position.Y, part.Position.Z);
    part.Velocity = Vector3.new(0, 0, 0);
end;

--// raycast filter

dependencies.variables.raycast_params.FilterType = Enum.RaycastFilterType.Blacklist;
dependencies.variables.raycast_params.FilterDescendantsInstances = {player.Character, workspace.Vehicles, workspace:FindFirstChild("Rain")};

workspace.ChildAdded:Connect(function(child) -- if it starts raining, add rain to collision ignore list
    if child.Name == "Rain" then 
        table.insert(dependencies.variables.raycast_params.FilterDescendantsInstances, child);
    end;
end);

player.CharacterAdded:Connect(function(character) -- when the player respawns, add character back to collision ignore list
    table.insert(dependencies.variables.raycast_params.FilterDescendantsInstances, character);
end);

--// get free vehicles, owned helicopters, motorcycles and unsupported/new vehicles

for index, vehicle_data in next, dependencies.modules.vehicle_data do
    if vehicle_data.Type == "Heli" then -- helicopters
        dependencies.helicopters[vehicle_data.Make] = true;
    elseif vehicle_data.Type == "Motorcycle" then --- motorcycles
        dependencies.motorcycles[vehicle_data.Make] = true;
    end;

    if vehicle_data.Type ~= "Chassis" and vehicle_data.Type ~= "Motorcycle" and vehicle_data.Type ~= "Heli" and vehicle_data.Type ~= "DuneBuggy" and vehicle_data.Make ~= "Volt" then -- weird vehicles that are not supported
        dependencies.unsupported_vehicles[vehicle_data.Make] = true;
    end;
    
    if not vehicle_data.Price then -- free vehicles
        dependencies.free_vehicles[vehicle_data.Make] = true;
    end;
end;

--// get all positions near a door which have no collision above them

for index, value in next, workspace:GetChildren() do
    if value.Name:sub(-4, -1) == "Door" then 
        local touch_part = value:FindFirstChild("Touch");

        if touch_part and touch_part:IsA("BasePart") then
            for distance = 5, 100, 5 do 
                local forward_position, backward_position = touch_part.Position + touch_part.CFrame.LookVector * (distance + 3), touch_part.Position + touch_part.CFrame.LookVector * -(distance + 3); -- distance + 3 studs forward and backward from the door
                
                if not workspace:Raycast(forward_position, dependencies.variables.up_vector, dependencies.variables.raycast_params) then -- if there is nothing above the forward position from the door
                    table.insert(dependencies.door_positions, {instance = value, position = forward_position});

                    break;
                elseif not workspace:Raycast(backward_position, dependencies.variables.up_vector, dependencies.variables.raycast_params) then -- if there is nothing above the backward position from the door
                    table.insert(dependencies.door_positions, {instance = value, position = backward_position});

                    break;
                end;
            end;
        end;
    end;
end;

--// no damage and ragdoll 

local old_fire_server = getupvalue(network.FireServer, 1);
setupvalue(network.FireServer, 1, function(key, ...)
    if key == keys.Damage then 
        return;
    end;

    return old_fire_server(key, ...);
end);

local old_is_point_in_tag = dependencies.modules.player_utils.isPointInTag;
dependencies.modules.player_utils.isPointInTag = function(point, tag)
    if tag == "NoRagdoll" or tag == "NoFallDamage" then 
        return true;
    end;
    
    return old_is_point_in_tag(point, tag);
end;

local function carTP(cframe, tried) -- unoptimized
    local relative_position = (cframe.Position - player.Character.HumanoidRootPart.Position);
    local target_distance = relative_position.Magnitude;

    if target_distance <= 20 and not workspace:Raycast(player.Character.HumanoidRootPart.Position, relative_position.Unit * target_distance, dependencies.variables.raycast_params) then 
        player.Character.HumanoidRootPart.CFrame = cframe; 
        
        return;
    end; 

    local tried = tried or {};
    local nearest_vehicle = utilities:get_nearest_vehicle(tried);

    if nearest_vehicle then 
        local vehicle_distance = (nearest_vehicle.Seat.Position - player.Character.HumanoidRootPart.Position).Magnitude; 

        if target_distance < vehicle_distance then -- if target position is closer than the nearest vehicle
            movement:move_to_position(player.Character.HumanoidRootPart, cframe, dependencies.variables.player_speed);
        else 
            if nearest_vehicle.Seat.PlayerName.Value ~= player.Name then
                movement:move_to_position(player.Character.HumanoidRootPart, nearest_vehicle.Seat.CFrame, dependencies.variables.player_speed, false, nearest_vehicle, tried);

                local enter_attempts = 1;

                repeat -- attempt to enter car
                    network:FireServer(keys.EnterCar, nearest_vehicle, nearest_vehicle.Seat);
                    
                    enter_attempts = enter_attempts + 1;

                    task.wait(0.1);
                until enter_attempts == 10 or nearest_vehicle.Seat.PlayerName.Value == player.Name;

                if nearest_vehicle.Seat.PlayerName.Value ~= player.Name then -- if it failed to enter, try a new car
                    table.insert(tried, nearest_vehicle);

                    return carTP(cframe, tried or {nearest_vehicle});
                end;
            end;

            local vehicle_root_part; -- inline conditional would be way too long

            if dependencies.helicopters[nearest_vehicle.Name] then -- each type of vehicle has a different root part, which is why we sort them so we can do this
                vehicle_root_part = nearest_vehicle.Model.TopDisc;
            elseif dependencies.motorcycles[nearest_vehicle.Name] then 
                vehicle_root_part = nearest_vehicle.CameraVehicleSeat;
            elseif nearest_vehicle.Name == "DuneBuggy" then 
                vehicle_root_part = nearest_vehicle.BoundingBox;
            else 
                vehicle_root_part = nearest_vehicle.PrimaryPart;
            end;

            movement:move_to_position(vehicle_root_part, cframe, dependencies.variables.vehicle_speed, true);

			local deez = game:GetService("VirtualInputManager")

			local function Ib(ic)
				deez:SendKeyEvent(true, ic, false, game)
				wait()
				deez:SendKeyEvent(false, ic, false, game)
			end

            repeat -- attempt to exit car
                task.wait(0.15);
                --network:FireServer(keys.ExitCar); -- Broke 
				Ib("E")
            until nearest_vehicle.Seat.PlayerName.Value ~= player.Name;
        end;
    end;
end;

local function TP(cframe, tried) -- unoptimized
    movement:move_to_position(player.Character.HumanoidRootPart, cframe, dependencies.variables.player_speed); 
end;

local function SellTP(cframe, tried)
	movement:sellTP(player.Character.HumanoidRootPart, cframe, dependencies.variables.player_speed); 
end;

G_8_ = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
local player = game.Players.LocalPlayer

local tweenservice = game:GetService('TweenService')

function G_17_(a)
  --va(true)
		local tween = tweenservice:Create(player.Character.PrimaryPart, TweenInfo.new((a.Position - player.Character.PrimaryPart.Position).Magnitude / 60), {CFrame = CFrame.new(a.Position)})
       tween:Play()
       tween.Completed:Wait()
  --va(false)
end



a, b, c, d = getupvalues or debug.getupvalues, getupvalue or debug.getupvalue, setupvalue or debug.setupvalue, islclosure or is_l_closure
local L = game:GetService("Players")
local M = L.LocalPlayer or L:GetPropertyChangedSignal("LocalPlayer"):Wait() or L.LocalPlayer
local N = game:GetService("VirtualInputManager")
local O, P
local Q = {}
local R = Vector3.new()
local S = false
local T, U, V = Color3.fromRGB(0, 222, 0), Color3.fromRGB(222, 0, 0), Color3.fromRGB(222, 222, 222)
local W = {
	enabled = false,
	jewlAllowCrims = false,
	preferLongTP = false,
	bankRadius2 = 19,
	preferUnsafeEsc = false,
	warnSeconds = 1.5,
	respawnForPlane = true
}
local X = false
local Y = game:GetService("RunService").Stepped
local Z = {}
local ab
local bb = function()
	for ic = 1, #Z do
		Z[ic].CanCollide = false
	end
end
local function cb()
	if not ab then
		ab = Y:Connect(bb)
	end
end
local function db()
	if ab then
		ab:Disconnect()
		ab = nil
	end
end
local function eb(ic)
	if ic then
		Q = ic:WaitForChild("HumanoidRootPart")
		P = ic:WaitForChild("Humanoid")
		wait(0.2)
		Z = {}
		for jc, kc in ipairs(ic:GetChildren()) do
			if kc:IsA("BasePart") then
				Z[#Z + 1] = kc
			end
		end
	end
end
eb(M.Character)
M.CharacterAdded:Connect(eb)
e = function(ic, jc, kc)
	local lc = Instance.new(ic)
	for mc, nc in next, kc do
		lc[mc] = nc
	end
	lc.Parent = jc
	return lc
end
f = e("ScreenGui", game.CoreGui, {
	Name = "AutoRob",
	ResetOnSpawn = false,
	ZIndexBehavior = "Sibling"
})
g = e("Frame", f, {
	Name = "Main",
	ClipsDescendants = true,
	Draggable = true,
	Active = true,
	Size = UDim2.new(0, 333, 0, 140),
	Position = UDim2.new(0.1, 0, 0.3, 0),
	BackgroundColor3 = Color3.new(0, 0.118, 0.239)
})
h = e("Frame", g, {
	Name = "homeFrame",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -30, 1, -55),
	Position = UDim2.new(0, 15, 0, 40)
})
i = e("TextButton", h, {
	Name = "AbortBtn",
	Size = UDim2.new(0.48, 0, 0.3, 0),
	Text = "ABORT",
	Font = "SourceSans",
	Position = UDim2.new(0.52, 0, 0.25, 0),
	TextSize = 23,
	AutoButtonColor = false,
	BackgroundColor3 = Color3.new(0.502, 0.498, 0.506)
})
j = e("Frame", i, {
	Name = "Shade",
	BackgroundTransparency = 0.9,
	Size = UDim2.new(1, 0, 0.5, 0),
	Position = UDim2.new(0, 0, 0.5, 0),
	BackgroundColor3 = Color3.new(),
	Visible = false
})
k = e("TextLabel", h, {
	Name = "Status",
	Size = UDim2.new(1, 0, 0.27, 0),
	Text = "Status: Loading...",
	TextSize = 15,
	TextXAlignment = "Left",
	Font = "Code",
	Position = UDim2.new(0, 0, 0.73, 0),
	BackgroundColor3 = Color3.new(0.765, 0.765, 0.765)
})
l = e("TextButton", h, {
	Name = "ToggleBtn",
	Size = UDim2.new(0.48, 0, 0.3, 0),
	Text = "TOGGLE",
	Font = "SourceSans",
	Position = UDim2.new(0, 0, 0.25, 0),
	TextSize = 23,
	BackgroundColor3 = W.enabled and T or U
})
m = e("Frame", l, {
	Name = "Shade",
	BackgroundTransparency = 0.9,
	Size = UDim2.new(1, 0, 0.5, 0),
	Position = UDim2.new(0, 0, 0.5, 0),
	BackgroundColor3 = Color3.new()
})
n = e("Frame", h, {
	Name = "availabels",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0.23, 0),
	Position = UDim2.new(0, 0, -0.12, 0),
	BackgroundColor3 = Color3.new(1, 1, 1)
})
o = e("TextLabel", n, {
	Name = "jewelryLbl",
	Size = UDim2.new(0.2, 0, 1, 0),
	Text = "Jewel",
	TextSize = 18,
	Font = "SourceSansLight",
	BackgroundTransparency = 1,
	Position = UDim2.new(0.34, 0, 0, 0),
	TextColor3 = Color3.new(1, 1, 1),
	BackgroundColor3 = Color3.new(1, 1, 1)
})
p = e("TextLabel", n, {
	Name = "trainLbl",
	Size = UDim2.new(0.2, 0, 1, 0),
	Text = "Train",
	TextSize = 18,
	Font = "SourceSansLight",
	BackgroundTransparency = 1,
	Position = UDim2.new(0.5, 0, 0, 0),
	TextColor3 = Color3.new(1, 1, 1),
	BackgroundColor3 = Color3.new(1, 1, 1)
})
q = e("TextLabel", n, {
	Name = "bankLbl",
	Size = UDim2.new(0.2, 0, 1, 0),
	Text = "Bank",
	TextSize = 18,
	Font = "SourceSansLight",
	BackgroundTransparency = 1,
	Position = UDim2.new(0.65, 0, 0, 0),
	TextColor3 = Color3.new(1, 1, 1),
	BackgroundColor3 = Color3.new(1, 1, 1)
})
r = e("TextLabel", n, {
	Name = "airdropLbl",
	Size = UDim2.new(0.2, 0, 1, 0),
	Text = "Airdrop",
	TextSize = 18,
	Font = "SourceSansLight",
	BackgroundTransparency = 1,
	Position = UDim2.new(0.82, 0, 0, 0),
	TextColor3 = Color3.new(1, 1, 1),
	BackgroundColor3 = Color3.new(1, 1, 1)
})
s = e("TextLabel", n, {
	Name = "museumLbl",
	Size = UDim2.new(0.2, 0, 1, 0),
	Text = "Museum",
	TextSize = 18,
	Font = "SourceSansLight",
	BackgroundTransparency = 1,
	TextColor3 = Color3.new(1, 1, 1),
	BackgroundColor3 = Color3.new(1, 1, 1),
	Position = UDim2.new(0.15, 0, 0, 0)
})
t = e("TextLabel", n, {
	Name = "planeLbl",
	Size = UDim2.new(0.2, 0, 1, 0),
	Text = "Plane",
	TextSize = 18,
	Font = "SourceSansLight",
	BackgroundTransparency = 1,
	TextColor3 = Color3.new(1, 1, 1),
	BackgroundColor3 = Color3.new(1, 1, 1),
	Position = UDim2.new(-0.04, 0, 0, 0)
})
u = e("TextButton", g, {
	Name = "CloseBtn",
	TextWrapped = true,
	TextStrokeTransparency = 0.7,
	Size = UDim2.new(0, 25, 0, 25),
	TextColor3 = V,
	Text = "X",
	BackgroundTransparency = 1,
	Font = "GothamBold",
	Position = UDim2.new(1, -22, 0, 0),
	TextScaled = true
})
v = e("ImageButton", g, {
	Name = "CogBtn",
	Image = "rbxassetid://135740223",
	Size = UDim2.new(0, 25, 0, 25),
	Position = UDim2.new(0, 0, 0, 2),
	BackgroundTransparency = 1
})
w = e("Frame", g, {
	Name = "setsframe",
	BackgroundTransparency = 0.02,
	Size = UDim2.new(1, -10, 0.8, -10),
	Position = UDim2.new(-1, 5, 0.2, 5),
	BorderSizePixel = 0,
	BackgroundColor3 = Color3.new(1, 1, 1)
})
x = e("Frame", w, {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0.25, 0)
})
y = e("TextBox", x, {
	Name = "BankRadiusBox",
	TextWrapped = true,
	Size = UDim2.new(0, 40, 0, 15),
	Text = W.bankRadius2,
	Font = "GothamSemibold",
	Position = UDim2.new(0.78, 0, 0.2, 0),
	TextScaled = true,
	BackgroundColor3 = Color3.new(1, 1, 1)
})
z = e("TextLabel", x, {
	TextWrapped = true,
	Size = UDim2.new(0.8, 0, 1, 0),
	Text = "Bank Cops Danger Range",
	TextSize = 15,
	Font = "Code",
	BackgroundTransparency = 1
})
A = e("Frame", w, {
	BackgroundTransparency = 0.93,
	Size = UDim2.new(1, 0, 0.25, 0),
	Position = UDim2.new(0, 0, 0.25, 0),
	BackgroundColor3 = Color3.new()
})
B = e("TextButton", A, {
	Name = "JewlSetBtn",
	Size = UDim2.new(0, 25, 0, 15),
	Text = W.respawnForPlane and 'X' or '',
	Font = "SourceSansSemibold",
	Position = UDim2.new(0.8, 0, 0.2, 0),
	TextSize = 20,
	BackgroundColor3 = Color3.new(1, 1, 1)
})
C = e("TextLabel", A, {
	TextWrapped = true,
	Size = UDim2.new(0.8, 0, 1, 0),
	Text = "Respawn To Speed Up Plane",
	TextSize = 15,
	Font = "Code",
	BackgroundTransparency = 1
})
D = e("Frame", w, {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0.25, 0),
	Position = UDim2.new(0, 0, 0.5, 0)
})
E = e("TextButton", D, {
	Name = "WarnSetBtn",
	Size = UDim2.new(0, 25, 0, 15),
	Text = W.warnSeconds > 1.51 and 'X' or '',
	Font = "SourceSansSemibold",
	Position = UDim2.new(0.8, 0, 0.2, 0),
	TextSize = 20,
	BackgroundColor3 = Color3.new(1, 1, 1)
})
F = e("TextLabel", D, {
	TextWrapped = true,
	Size = UDim2.new(0.8, 0, 1, 0),
	Text = "Prefer Longer Warnings",
	TextSize = 15,
	Font = "Code",
	BackgroundTransparency = 1
})
G = e("Frame", w, {
	BackgroundTransparency = 0.93,
	Size = UDim2.new(1, 0, 0.25, 0),
	Position = UDim2.new(0, 0, 0.75, 0),
	BackgroundColor3 = Color3.new()
})
H = e("TextButton", G, {
	Name = "EscSetBtn",
	Size = UDim2.new(0, 25, 0, 15),
	Text = W.preferUnsafeEsc and 'X' or '',
	Font = "SourceSansSemibold",
	Position = UDim2.new(0.8, 0, 0.2, 0),
	TextSize = 20,
	BackgroundColor3 = Color3.new(1, 1, 1)
})
I = e("TextLabel", G, {
	TextWrapped = true,
	Size = UDim2.new(0.8, 0, 1, 0),
	Text = "Remember Your Position",
	TextSize = 15,
	Font = "Code",
	BackgroundTransparency = 1
})
J = e("TextLabel", g, {
	Name = "Title",
	TextWrapped = false,
	Size = UDim2.new(0.5, 0, 0, 20),
	Text = "Auto-Rob by SirelKilla {Undetected}",
	TextSize = 18,
	Font = "Highway",
	BackgroundTransparency = 1,
	Position = UDim2.new(0.24, 0, 0, 3),
	TextColor3 = V,
	BackgroundColor3 = Color3.new(1, 1, 1)
})
K = e("TextButton", g, {
	Name = "SaveSetsBtn",
	Size = UDim2.new(0, 60, 0, 25),
	Text = "Save",
	Font = "SourceSans",
	Style = "RobloxRoundDefaultButton",
	Position = UDim2.new(0, 30, 0, -25),
	TextSize = 20
})
u.MouseButton1Click:Connect(function()
	f:Destroy()
	S = true
	if O then
		O:Disconnect()
	end
end)
u.MouseEnter:Connect(function()
	u.TextColor3 = U
end)
u.MouseLeave:Connect(function()
	u.TextColor3 = V
end)
local function fb(ic)
	i.AutoButtonColor = ic
	i.BackgroundColor3 = ic and Color3.new(0.353, 0.557, 0.914) or Color3.new(0.502, 0.498, 0.506)
	j.Visible = ic
	S = false
end
i.MouseButton1Click:Connect(function()
	if i.AutoButtonColor then
		if O then
			O:Disconnect()
		end
		fb(false)
		S = true
		i.Text = "Aborted."
		wait(2.8)
		i.Text = "ABORT"
	end
end)
local function gb(ic)
	k.Text = "Status: "..ic
end
local hb = game:GetService("TweenService"):Create(v, TweenInfo.new(0.25), {
	Rotation = 135
})
local ib = game:GetService("TweenService"):Create(v, TweenInfo.new(0.25), {
	Rotation = 0
})
local jb = false
v.MouseButton1Click:Connect(function()
	jb = not jb
	if jb then
		w:TweenPosition(UDim2.new(0, 5, 0.2, 5), nil, "Quart", 0.3, true)
		h:TweenPosition(UDim2.new(1, 15, 0, 40), nil, "Quart", 0.3, true)
		if writefile then
			K:TweenPosition(UDim2.new(0, 30, 0, 2), nil, "Quart", 0.3, true)
		end
		hb:Play()
	else
		w:TweenPosition(UDim2.new(-1, 5, 0.2, 5), nil, "Quart", 0.3, true)
		h:TweenPosition(UDim2.new(0, 15, 0, 40), nil, "Quart", 0.3, true)
		K:TweenPosition(UDim2.new(0, 30, 0, -25), nil, "Quart", 0.3, true)
		ib:Play()
	end
end)
local kb = y.Text
y:GetPropertyChangedSignal("Text"):Connect(function()
	y.Text = y.Text:sub(1, 4)
	local ic = tonumber(y.Text)
	if ic then
		if ic > 99 then
			y.Text = '99'
		end
	elseif y.Text ~= '' then
		y.Text = kb
	end
	kb = y.Text
end)
y.FocusLost:Connect(function()
	if tonumber(y.Text) then
		W.bankRadius2 = tonumber(y.Text)
	end
	y.Text = tostring(W.bankRadius2)
end)
B.MouseButton1Click:Connect(function()
	W.respawnForPlane = not W.respawnForPlane
	B.Text = W.respawnForPlane and "X" or ""
end)
E.MouseButton1Click:Connect(function()
	W.warnSeconds = W.warnSeconds > 1.51 and 1.5 or 3
	E.Text = W.warnSeconds > 1.51 and "X" or ""
end)
H.MouseButton1Click:Connect(function()
	W.preferUnsafeEsc = not W.preferUnsafeEsc
	H.Text = W.preferUnsafeEsc and "X" or ""
end)
K.MouseButton1Click:Connect(function()
	if writefile and K.Style.Name == "RobloxRoundDefaultButton" then
		K.Style = "RobloxRoundButton"
		writefile("JBAR.txt", game:GetService("HttpService"):JSONEncode(W))
		K.Text = "Saved."
		wait(1)
		K.Text = "Save"
		K.Style = "RobloxRoundDefaultButton"
	end
end)
l.MouseButton1Click:Connect(function()
	W.enabled = not W.enabled
	l.BackgroundColor3 = W.enabled and T or U
end)
M:WaitForChild("PlayerScripts"):WaitForChild("LocalScript")
wait(0.5)
wait(5 - workspace.DistributedGameTime)
local lb, mb, nb, ob, pb
if a then
	local ic = (getreg or debug.getregistry)()
	for jc = 1, #ic do
		local kc = ic[jc]
		if type(kc) == "function" and (is_protected_closure == nil or is_protected_closure(kc) == false) and (d == nil or d(kc)) then
			local lc = a(kc)
			for mc, nc in next, lc do
				if type(nc) == "table" then
					if rawget(nc, "Specs") and nc.Frame and #nc == 0 then
						lb = nc.Specs
					elseif rawget(nc, "IsFlying") and #nc == 0 then
						nc.IsFlying = function()
							return tostring(getfenv(2).script) == "Falling"
						end
					elseif mb == nil and #nc == 3 then
						for oc = 1, 3 do
							if type(nc[oc]) == "table" and nc[oc].Name == "Punch" then
								mb = nc[oc]
							end
						end
					end
				elseif nb == nil and (nc == "Prisoner" or nc == "Police" or nc == "Neutral") and #lc == 2 then
					nb = kc
					ob = mc
				elseif pb == nil and type(nc) == "function" and (is_protected_closure == nil or is_protected_closure(nc) == false) and (d == nil or d(nc)) then
					for oc, pc in next, a(nc) do
						if type(pc) == "table" and rawget(pc, "LastVehicleExit") then
							pb = nc
						end
					end
				end
			end
		end
	end
end
for ic, jc in ipairs(workspace.Buildings:GetChildren()) do
	if (jc.Position - Vector3.new(-302.6, 30.3, 1431.9)).Magnitude < 1 then
		jc.CanCollide = false
	end
end
for ic, jc in ipairs(workspace.Jewelrys:GetChildren()[1].Building:GetChildren()) do
	if jc.Name == "Part" and (jc.Position - Vector3.new(157.8, 63.4, 1336.6)).Magnitude < 1 then
		jc.CanCollide = false
	end
end
local qb = {
	{
		CFrame.new(1053.6, 101.7, 1245.6),
		workspace.Museum.MummyCase.MummyNode
	},
	{
		CFrame.new(1037.1, 116.6, 1254.8),
		workspace.Museum.Reference.Items1.Gold
	},
	{
		CFrame.new(1046.8, 116.6, 1262.7),
	},
	{
		CFrame.new(1029.4, 116.6, 1247.7),
		workspace.Museum.Reference.Items1.Cone.Cone
	},
	{
		CFrame.new(1038.8, 101.7, 1238.7),
	},
	{
		CFrame.new(1105.3, 101.7, 1151),
	}
}
local rb = workspace.Trains:FindFirstChild("SteamEngine") ~= nil
local sb = false
local tb
local ub = tb or {}
workspace.Trains.ChildAdded:Connect(function(ic)
	wait(math.random())
	if ic.Name == "SteamEngine" then
		rb = true
	elseif ic.Name == "BoxCar" and tb == nil and ub.Parent == nil and false then
		ub = ic
		wait(24 + math.random() * 53)
		if ic.Parent and tb == nil then
			tb = ic
		end
	end
	p.TextColor3 = (tb or rb) and T or Color3.new(1, 1, 1)
end)
workspace.Trains.ChildRemoved:Connect(function(ic)
	if tb == ic then
		tb = nil
	elseif ic.Name == "SteamEngine" then
		rb = false
	elseif ic.Name == "BoxCar" then
		tb = false
	end
	p.TextColor3 = (tb or rb) and T or Color3.new(1, 1, 1)
end)
p.TextColor3 = (tb or rb) and T or Color3.new(1, 1, 1)
local vb = {}
local wb = 0
local function xb()
	local ic = workspace.Plane.Crates:GetChildren()
	for jc = 1, #ic do
		local kc = ic[jc]:FindFirstChild("1")
		if kc and kc.Transparency < .99 and kc.Position.Y > 50 then
			return kc
		end
	end
end
local function yb(ic)
	if ic.ClassName == "Model" then
		if ic.Name == "Drop" then
			local jc = ic:WaitForChild("Briefcase", 2)
			while jc and jc.Parent and ic:FindFirstChild("Parachute") do
				ic.ChildRemoved:Wait()
				wait()
			end
			if jc and jc.Parent then
				vb[#vb + 1] = jc
				r.TextColor3 = T
			end
		elseif ic.Name == "Plane" and ic:WaitForChild("Crates", 2) then
			wb = tick() + 120
			while ic.Parent and xb() == nil do
				wait(0.3)
			end
			if ic.Parent then
				sb = true
				t.TextColor3 = T
			end
		end
	end
end
for ic, jc in ipairs(workspace:GetChildren()) do
	if jc.ClassName == "Model" then
		coroutine.wrap(yb)(jc)
	end
end
workspace.ChildAdded:Connect(yb)
workspace.ChildRemoved:Connect(function(ic)
	if ic.ClassName == "Model" then
		if ic.Name == "Drop" then
			wait()
			for jc = #vb, 1, -1 do
				if not vb[jc].Parent then
					table.remove(vb, jc)
				end
			end
			r.TextColor3 = #vb > 0 and T or Color3.new(1, 1, 1)
		elseif ic.Name == "Plane" then
			sb = false
			t.TextColor3 = Color3.new(1, 1, 1)
			wb = tick()
		end
	end
end)
local zb = workspace.Banks:GetChildren()[1].Extra.Sign.Decal
local Ab = workspace.Jewelrys:GetChildren()[1].Extras.Sign.Decal
local Bb = workspace.Museum.Roof.Hole.RoofPart
local Cb = zb.Transparency > 0.01
local Db = Ab.Transparency > 0.01
local Eb = not Bb.CanCollide
local Fb = #workspace.Ringers.Bank:GetChildren() == 0
local Gb = #workspace.Ringers.Jewelry:GetChildren() == 0
zb:GetPropertyChangedSignal("Transparency"):Connect(function()
	wait()
	Cb = zb.Transparency > 0.01
	q.TextColor3 = Cb and T or Color3.new(1, 1, 1)
	if not Cb then
		Fb = true
	end
end)
Ab:GetPropertyChangedSignal("Transparency"):Connect(function()
	wait()
	Db = Ab.Transparency > 0.01
	o.TextColor3 = Db and T or Color3.new(1, 1, 1)
	if not Db then
		Gb = true
	end
end)
Bb:GetPropertyChangedSignal("CanCollide"):Connect(function()
	wait()
	Eb = not Bb.CanCollide
	s.TextColor3 = Eb and T or Color3.new(1, 1, 1)
end)
q.TextColor3 = Cb and T or Color3.new(1, 1, 1)
o.TextColor3 = Db and T or Color3.new(1, 1, 1)
s.TextColor3 = Eb and T or Color3.new(1, 1, 1)
workspace.Ringers.Bank.ChildAdded:Connect(function()
	Fb = false
end)
workspace.Ringers.Jewelry.ChildAdded:Connect(function()
	Gb = false
end)
local function Hb(ic, jc)
	local kc = tick()
	local lc = 0.1
	ic = (ic == nil or ic <= 0) and 0.001 or ic
	lc = (lc > ic) and ic or lc
	while tick() - kc < ic and S == false and (jc == nil or jc(tick() - kc)) do
		wait(lc)
	end
	return tick() - kc
end
local function Ib(ic)
	N:SendKeyEvent(true, ic, false, game)
	wait()
	N:SendKeyEvent(false, ic, false, game)
end
local function Jb(ic)
	if P.Sit then
		P.Jump = true
		if pb then
			pb(true)
		else
			Ib("Space")
		end
		if ic or P:GetStateEnabled("Running") then
			wait()
		else
			wait(3)
		end
	end
end
local function Kb(ic)
	return tonumber((tostring(ic):gsub("%D", "")))
end
local function Lb()
	return M.PlayerGui.RobberyMoneyGui.Container.Bottom.Progress.Amount.Visible and Kb(M.PlayerGui.RobberyMoneyGui.Container.Bottom.Progress.Amount.Text) + 2 > Kb(M.PlayerGui.RobberyMoneyGui.Container.Bottom.Progress.Amount.Text)
end
local function Mb()
	local ic, jc = M.PlayerGui.MainGui.MuseumBag.TextLabel.Text:match("(.-)/(.+)")
	return M.PlayerGui.MainGui.MuseumBag.Visible and ic and jc and Kb(ic) >= Kb(jc)
end
local Nb
local function Ob()
	return (Nb.Door.Closed.CFrame.lookVector - Nb.Door.Hinge.CFrame.lookVector).Magnitude > 0.1
end
local function Pb(ic)
	local jc = game:GetService("Teams").Police:GetPlayers()
	for kc = 1, #jc do
		local lc = jc[kc]
		if lc.Character and lc.Character:FindFirstChild("HumanoidRootPart") and lc.Character:FindFirstChild("Humanoid") then
			local mc = lc.Character.HumanoidRootPart.Position
			if (Nb.Door.Hinge.Position - mc).Magnitude < ic and lc.Character.Humanoid.Health > 0 and workspace:FindPartOnRayWithWhitelist(Ray.new(mc, Nb.TriggerDoor.Position - Nb.Door.Hinge.CFrame.lookVector * 3 - mc), {
				Nb.Decoration,
				Nb.Parent.Parent.TopFloor
			}) == nil then
				return true
			end
		end
	end
	return false
end
local function Qb(ic)
	if S then
		return
	end
	local jc = workspace.CurrentCamera
	jc.CameraType = "Scriptable"
	jc.CFrame = CFrame.new(jc.CFrame.p, ic.Position)
	wait()
	jc.CameraType = "Custom"
	wait()
	N:SendKeyEvent(true, "E", false, game)
end
local function Rb(ic)
	if lb then
		for jc = 1, #lb do
			if lb[jc].Part == ic then
				lb[jc]:Callback(true)
				break
			end
		end
		Hb(1)
	else
		local jc = ic.Weld
		local kc, lc = jc.C0, jc.Part1
		jc.C0, jc.Part1 = CFrame.new(0, 0, 9), Q
		if M.PlayerGui.MainGui.CircleAction.Visible then
			Q.CFrame = Q.CFrame + Q.CFrame.lookVector * 20
		end
		local mc = Ray.new(Q.Position, Q.CFrame.lookVector * 11)
		local nc = {
			Q.Parent
		}
		local oc = {}
		while true do
			local pc = workspace:FindPartOnRayWithIgnoreList(mc, nc)
			if pc then
				nc[#nc + 1] = pc
				oc[pc] = pc.CanCollide
				pc.CanCollide = false
			else
				break
			end
		end
		wait()
		Qb(ic)
		Hb(0.1)
		for pc, qc in next, oc do
			pc.CanCollide = qc
		end
		jc.C0, jc.Part1 = kc, lc
		N:SendKeyEvent(false, "E", false, game)
		Hb(0.9)
	end
	return P.Sit
end
local Sb = {}
local function Tb(ic)
	if S then
		return
	end
	if Sb.Parent == nil or Sb.Player.Value or Sb.Position.Y < -10 or Rb(Sb) == false then
		for jc, kc in ipairs(workspace.Vehicles:GetChildren()) do
			if kc.Name == "Camaro" and kc:FindFirstChild("Engine") and kc:FindFirstChild("Seat") and kc.Seat:FindFirstChild("Weld") and kc.Seat:FindFirstChild("Player") and kc.Seat.Player.Value == false and kc.Seat ~= Sb and not S then
				if Rb(kc.Seat) then
					Sb = kc.Seat
					if kc:FindFirstChild("BodyVelocity") == nil then
						e("BodyVelocity", kc.Engine, {
							Velocity = R,
							MaxForce = Vector3.new(1e6, 1e6, 1e6),
							P = 1000
						})
					end
					break
				end
			end
		end
	end
	Sb.Parent:SetPrimaryPartCFrame(CFrame.new(ic.X + 7, math.random(200, 300), ic.Z))
	Hb(1)
	if S then
		return
	end
	Jb(true)
	delay(3, function()
		Q.CFrame = Q.CFrame + Vector3.new(0, 0.001, 0)
	end)
	Q:GetPropertyChangedSignal("CFrame"):Wait()
	Q.CFrame = ic
	Q.Velocity, Q.RotVelocity = R, R
	Hb(0.1)
	Q.CFrame = ic
	Q.Velocity, Q.RotVelocity = R, R
end
local function Ub(ic)
	P:SetStateEnabled("FallingDown", false)
	local jc = (ic - ic.p) + Q.Position + Vector3.new(0, 4, 0)
	local kc = ic.p - Q.Position
	local lc = workspace.Gravity
	workspace.Gravity = 0
	for mc = 0, kc.Magnitude, 1.8 do
		if S then
			break
		end
		Q.CFrame = jc + kc.Unit * mc
		Q.Velocity, Q.RotVelocity = R, R
		wait()
	end
	if not S then
		Q.CFrame = ic
	end
	workspace.Gravity = lc
end
local Vb = CFrame.new()
local function Wb(ic)
	fb(true)
	gb(ic.." ready.")
	local jc = g.BackgroundColor3
	local kc = 0
	while kc < W.warnSeconds do
		for lc = 0, 1, 1 / (30 * .25) do
			g.BackgroundColor3 = jc:lerp(U, lc)
			kc = kc + wait()
		end
		for lc = 0, 1, 1 / (30 * .25) do
			g.BackgroundColor3 = U:lerp(jc, lc)
			kc = kc + wait()
		end
	end
	g.BackgroundColor3 = jc
	if P == nil or P.Health < 1 then
		wait(5)
	end
	if S or not W.enabled then
		return false
	end
	Jb()
	if M.Team.Name == "Prisoner" then
		gb("Breaking out...")
		if workspace.Vehicles:FindFirstChild("Camaro") == nil or workspace.Vehicles:FindFirstChild("Heli") == nil then
			TP(CFrame.new(-1022, 60, -1533))
		end
		Hb(25, function()
			return M.PlayerGui.MainGui.CellTime.Visible
		end)
		carTP(CFrame.new(-298 + math.random() * 10, 18, 1430))
		Hb(3)
	end
	Vb = Q.CFrame
	return W.enabled and not S
end
local function Xb()
	S = false
	gb("Escaping...")
	if W.preferUnsafeEsc then
		--TP(Vb)
		movement:pathfind();
	else
		--TP(CFrame.new(-298 + math.random() * 10, 18, 1430))
		movement:pathfind();
	end
end

function JewBox()
	for i,v in pairs(workspace.Jewelrys:GetDescendants()) do
		if v.Name == "Boxes" then
			local part = v:GetChildren()[math.random(1,table.maxn(v:GetChildren()))]
			local pos = CFrame.new(part.Position - part.CFrame.LookVector * 2, part.Position)
			return pos
		end
	end
end
local function Yb()
	local ic = Wb("Jewelry")

	function movement:JewelryEntry(tried)
        local distance = math.huge;
        local nearest;
    
        local tried = tried or {};
        
        for index, value in next, dependencies.door_positions do -- find the nearest position in our list of positions without collision above
            if not table.find(tried, value) then
                local magnitude = (value.position - player.Character.HumanoidRootPart.Position).Magnitude;
                
                if magnitude < distance then 
                    distance = magnitude;
                    nearest = value;
                end;
            end;
        end;
    
        table.insert(tried, nearest);
    
        utilities:toggle_door_collision(nearest.instance, false);
    
        local path = dependencies.variables.path;
        path:ComputeAsync(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position, game:GetService("Workspace").Jewelrys:GetChildren()[1].WindowEntry.LaserTouch.Position);
    
        if path.Status == Enum.PathStatus.Success then -- if path making is successful
            local waypoints = path:GetWaypoints();
    
            for index = 1, #waypoints do 
                local waypoint = waypoints[index];
                
                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(waypoint.Position + Vector3.new(0, 2.5, 0)); -- walking movement is less optimal
    
                if not workspace:Raycast(player.Character.HumanoidRootPart.Position, dependencies.variables.up_vector, dependencies.variables.raycast_params) then -- if there is nothing above the player
                    utilities:toggle_door_collision(nearest.instance, true);
    
                    return;
                end;
    
                task.wait(0.05);
            end;
        end;
    
        utilities:toggle_door_collision(nearest.instance, true);
    
        movement:JewelryEntry(tried);
    end;

	if ic then
		gb("TPing to jewelry...")
		--carTP(CFrame.new(89.7, 17.88, 1302.53) * CFrame.Angles(0, math.pi / -2, 0))
        carTP(CFrame.new(136.667511, 18.5636292, 1352.01721))
        wait(10)
		ic = not S
		gb("Robbery started!")
		local jc = 0
		local kc = workspace.Jewelrys:GetChildren()[1].Boxes:GetChildren()
		table.sort(kc, function(lc, mc)
			return lc.Position.X > mc.Position.X
		end)
		for lc = 1, #kc do
			if S or Db == false or (jc > 3 and Lb()) then
				break
			end
			local mc = kc[lc]
			if mc.Transparency < 0.9 then
				if mc.Position.X < 120 and mc.Position.Z > 1330 then
					G_17_(CFrame.new(mc.Position + mc.CFrame.lookVector * 2.5 + Vector3.new(0, 0, -2.5), mc.Position))
				elseif mc.Position.Z < 1309 and mc.Position.Z > 1304 then
					G_17_(CFrame.new(mc.Position + mc.CFrame.lookVector * 2.5 + Vector3.new(0, 0, -2.5), mc.Position))
					--game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mc.Position + mc.CFrame.lookVector * 2.5 + Vector3.new(0, 0, -2.5), mc.Position)
				else
					G_17_(CFrame.new(mc.Position + mc.CFrame.lookVector * 2.5 + Vector3.new(0, 0, -2.5), mc.Position))
				end
				Hb(1)
				for nc = 1, 4 do
					if mb then
						mb:Callback(true)
					else
						Ib("F")
					end
					Hb(0.5)
					if mc.Transparency > 0.9 then
						break
					end
				end
				jc = jc + 1
				Hb(0.5)
			end
		end
		gb("Selling...")
		G_17_(CFrame.new(105.671745, 38.8217659, 1332.52734, -0.994528353, -8.98596253e-10, 0.10446699, -5.9451094e-10, 1, 2.94196556e-09, -0.10446699, 2.86376145e-09, -0.994528353))
		G_17_(CFrame.new(97.6859283, 54.6054611, 1285.37573, 0.998322845, 2.48869032e-08, 0.0578920953, -2.45343337e-08, 1, -6.80088608e-09, -0.0578920953, 5.3691358e-09, 0.998322845) * CFrame.Angles(0, math.pi, 0))
		G_17_(CFrame.new(111.336212, 36.6054611, 1282.47852, 0.0568848848, 7.73347963e-08, -0.998380721, 1.92794953e-08, 1, 7.85587133e-08, 0.998380721, -2.37170799e-08, 0.0568848848))
		G_17_(CFrame.new(120.14576, 36.6054611, 1341.08484, 0.861237645, 2.36252227e-08, 0.508202434, -6.24102086e-08, 1, 5.92771663e-08, -0.508202434, -8.27687501e-08, 0.861237645))
		
		--Ub(CFrame.new(-202, 34.7, 1544) * CFrame.Angles(0, math.pi, 0))
		Ub(3, function()
			return M.PlayerGui.RobberyMoneyGui.Container.Bottom.Progress.Amount.Visible
		end)
		Xb()
		if ic then
			Db = false
			o.TextColor3 = Color3.new(1, 1, 1)
			gb("Jewelry success!")
		end
	end
	fb(false)
	wait(2)
	if ic then
		gb("10 second cooldown.")
		wait(10)
	end
end
local function Zb()
	local ic = Wb("Bank")

	--[[function movement:BankTriggerVault(tried)
        local distance = math.huge;
        local nearest;
    
        local tried = tried or {};
        
        for index, value in next, dependencies.door_positions do -- find the nearest position in our list of positions without collision above
            if not table.find(tried, value) then
                local magnitude = (value.position - player.Character.HumanoidRootPart.Position).Magnitude;
                
                if magnitude < distance then 
                    distance = magnitude;
                    nearest = value;
                end;
            end;
        end;
    
        table.insert(tried, nearest);
    
        utilities:toggle_door_collision(nearest.instance, false);
    
        local path = dependencies.variables.path;
        path:ComputeAsync(player.Character.HumanoidRootPart.Position, game:GetService("Workspace").Banks["1c88d270-f30e-4703-b460-c405ae175dda"].Layout["03Corridor"].TriggerDoor.Position);
    
        if path.Status == Enum.PathStatus.Success then -- if path making is successful
            local waypoints = path:GetWaypoints();
    
            for index = 1, #waypoints do 
                local waypoint = waypoints[index];
                
                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(waypoint.Position + Vector3.new(0, 2.5, 0)); -- walking movement is less optimal
    
                if not workspace:Raycast(player.Character.HumanoidRootPart.Position, dependencies.variables.up_vector, dependencies.variables.raycast_params) then -- if there is nothing above the player
                    utilities:toggle_door_collision(nearest.instance, true);
    
                    return;
                end;
    
                task.wait(0.05);
            end;
        end;
    
        utilities:toggle_door_collision(nearest.instance, true);
    
        movement:BankTriggerVault(tried);
    end;

	if ic then
		gb("TPing to bank...")
		carTP(CFrame.new(8.69768047, 18.5636635, 788.429993, 0.992843032, 6.66786804e-08, -0.119426444, -6.24084606e-08, 1, 3.94960864e-08, 0.119426444, -3.17601945e-08, 0.992843032))
		Hb(5)
		carTP(CFrame.new(24.7804241, 18.8141232, 852.089172, -0.834913909, 7.25782456e-08, -0.550380588, 5.52096502e-08, 1, 4.81175064e-08, 0.550380588, 9.78765602e-09, -0.834913909) + Vector3.new(0, 3, 0))
		Hb(2)
		carTP(CFrame.new(90.8596649, 1.31384552, 857.090149, -0.0112044159, -1.21873782e-08, -0.999937236, 9.47687582e-08, 1, -1.32500384e-08, 0.999937236, -9.49112646e-08, -0.0112044159))
		Hb(2)
		carTP(CFrame.new(95.9255753, 1.3138454, 820.557922, 0.995373785, 3.65304165e-09, -0.0960784853, -1.01850244e-08, 1, -6.74954919e-08, 0.0960784853, 6.81618033e-08, 0.995373785))
		ic = not S
		gb("Opening vault...")
		Nb = workspace.Banks:GetChildren()[1].Layout:GetChildren()[1]
		if not S then
			local jc = Nb.TriggerDoor.CFrame
			G_17_(Nb.TriggerDoor.CFrame)
			movement:BankTriggerVault();
			wait()
			Nb.TriggerDoor.CFrame = jc
			local kc = Nb.Door.Hinge.CFrame
			if Nb.Money.Size.Magnitude > 25 and (Nb.Money.Position - kc.Position).Magnitude < 30 then
				if Nb.Name == "TheMint" then
					carTP(kc + kc.lookVector * 3 + kc.rightVector * 13.5)
				else
					G_17_(kc + kc.lookVector * 3 + kc.rightVector * -5.5 + Vector3.new(0, 3, 0))
				end
			else
				if Nb:FindFirstChild("Lasers") then
					for lc, mc in ipairs(Nb.Lasers:GetChildren()) do
						if mc.Name == "LaserTrack" then
							mc:Destroy()
						end
					end
				end
				G_17_(Nb.Money.CFrame)
			end
		end
		Hb(300, function()
			return Cb and Ob() == false
		end)
		Hb(3, function()
			return Cb and (not(Ob() and Pb(W.bankRadius2)))
		end)
		gb("Robbery started!")
		Hb(80, function()
			return Lb() == false and Cb and (not(Ob() and Pb(W.bankRadius2)))
		end)
		Q.CFrame = CFrame.new(Q.CFrame.X, 20, Q.CFrame.Z)
		wait(0.5)
		Xb()
		if ic then
			Cb = false
			q.TextColor3 = Color3.new(1, 1, 1)
			gb("Bank success!")
		end
	end
	fb(false)
	wait(2)
	if ic then
		gb("10 second cooldown.")
		wait(10)
	end--]]

	gb("Skipping bank.")
end
local function ac()
	local ic = Wb("Train")
	if ic then
		local jc = tb.Model.Rob.Gold
		local kc = workspace.Trains.LocomotiveFront.Model.Front
		gb("TPing to train...")
		TP(jc.CFrame + jc.Velocity * 2)
		ic = not S
		if tb.Parent then
			if lb and false then
				O = Y:Connect(function()
					Q.CFrame = tb.Skeleton.RoofDoorClosed.CFrame + Vector3.new(0, -5, 0)
					Q.Velocity, Q.RotVelocity = R, R
				end)
				gb("Bypassing by waiting...")
				Hb(5)
				O:Disconnect()
				local lc, mc
				for nc = 1, #lb do
					local oc = lb[nc]
					if lc == nil and oc.Name == "Open Door" and tostring(oc.Part) == "RoofDoorClosed" and tb:IsAncestorOf(oc.Part) then
						lc = oc
					elseif mc == nil and oc.Name == "Breach Vault" and tb:IsAncestorOf(oc.Part) then
						mc = oc
					end
				end
				if lc then
					lc:Callback(true)
				end
				wait()
				if mc then
					mc:Callback(true)
				end
			else
				gb("Opening door...")
				O = Y:Connect(function()
					Q.CFrame = tb.Skeleton.RoofDoorClosed.CFrame + Vector3.new(0, -5, 0)
					Q.Velocity, Q.RotVelocity = R, R
				end)
				Hb(0.45)
				Qb(tb.Skeleton.RoofDoorClosed)
				Hb(7, function()
					return (tb.Skeleton.RoofDoor.Position - tb.Skeleton.RoofDoorClosed.Position).Magnitude < 1
				end)
				O:Disconnect()
				Hb()
				N:SendKeyEvent(false, "E", false, game)
				gb("Opening vault...")
				O = Y:Connect(function()
					Q.CFrame = jc.CFrame
					Q.Velocity, Q.RotVelocity = R, R
				end)
				Hb(0.45)
				Qb(tb.Skeleton.Vault.Part)
				Hb(7, function()
					return tb.Skeleton.Vault.Part.RotVelocity.Magnitude < .001
				end)
				O:Disconnect()
				Hb(0.2)
				N:SendKeyEvent(false, "E", false, game)
			end
			gb("Robbery started!")
			O = Y:Connect(function()
				Q.CFrame = jc.CFrame
				Q.Velocity, Q.RotVelocity = R, R
			end)
			Hb(65, function()
				return Lb() == false and kc.Position.X > -1584
			end)
			O:Disconnect()
		end
		Xb()
		if ic then
			tb = nil
			p.TextColor3 = Color3.new(1, 1, 1)
			gb("Train success!")
		end
	end
	fb(false)
	wait(2)
	if ic then
		gb("10 second cooldown.")
		wait(10)
	end
end
local function bc()
	local ic = Wb("Museum")
	if ic then
		gb("TPing to museum...")
		carTP(CFrame.new(1064, 107, 1194))
		Hb(1)
		if S then
			ic = false
		else
			gb("Robbery started!")
			local jc = M.PlayerGui.MainGui.MuseumBag.TextLabel
			jc.Text = "9"..jc.Text:sub(2)
			for kc = 1, #qb do
				local lc = qb[kc][1]
				local mc = qb[kc][2]
				if mc.Transparency < .99 then
					if S or Eb == false or jc.Text:sub(1, 1) == jc.Text:sub(5, 5) then
						break
					end
					Ub(lc)
					if lb then
						if kc == 1 then
							mc = mc.Parent.Parent.MummyNode
						end
						for nc = 1, #lb do
							if lb[nc].Part == mc then
								lb[nc]:Callback(true)
								break
							end
						end
						Hb(0.5)
					else
						Qb(mc)
						Hb(7, function()
							return mc.Transparency < .99
						end)
						N:SendKeyEvent(false, "E", false, game)
						Hb()
					end
				end
			end
			if W.preferUnsafeEsc then
				Tb(Vb)
			else
				TP(CFrame.new(-298 + math.random() * 10, 18, 1430))
			end
			gb("Bypassing by waiting...")
			Hb(9)
			Jb()
			Vb = Q.CFrame
			gb("Selling...")
			TP(CFrame.new(1686, 50.7, -1844))
			Hb(4)
			carTP(CFrame.new(1647, 50.7, -1813))
			Hb(9, function()
				return M.PlayerGui.MainGui.MuseumBag.Visible
			end)
		end
		Xb()
		if ic then
			Eb = false
			s.TextColor3 = Color3.new(1, 1, 1)
			gb("Museum success!")
		end
	end
	fb(false)
	wait(2)
	if ic then
		gb("10 second cooldown.")
		wait(10)
	end
end
local function cc()
	local ic = Wb("Steam engine")
	if ic then
		gb("Robbery started!")
		local jc = tick()
		local kc = workspace.Trains:GetDescendants()
		for lc = 1, #kc do
			local mc = kc[lc]
			if mc.Name == "Briefcase" and mc.Parent and mc:FindFirstChild("Weld") then
				if S or Mb() then
					break
				end
				if lb then
					for nc = 1, #lb do
						if lb[nc].Part == mc then
							lb[nc]:Callback(true)
							break
						end
					end
					Hb(2.5)
				else
					mc.Weld.C0 = CFrame.new(0, 0, 5)
					mc.Weld.Part1 = Q
					Hb()
					Qb(mc)
					Hb(3, function()
						return mc.Parent ~= nil
					end)
					N:SendKeyEvent(false, "E", false, game)
					Hb()
					mc:ClearAllChildren()
				end
			end
		end
		Hb(1)
		gb("Bypassing by waiting...")
		carTP(CFrame.new(1686, 50.7, -1844))
		Jb()
		gb("Selling...")
		carTP(CFrame.new(2286.67114, 19.1927166, -2080.41528, 0.999894977, 2.60326927e-10, 0.0144938128, -2.627637e-10, 1, 1.66221661e-10, -0.0144938128, -1.70012643e-10, 0.999894977))
		wait(1)
		G_17_(CFrame.new(2216.5354, 19.3582458, -2470.72461, 0.988022506, -8.40341983e-08, 0.154309943, 8.18320629e-08, 1, 2.06226609e-08, -0.154309943, -7.74815145e-09, 0.988022506))
		wait(1)
		G_17_(CFrame.new(2215.97217, 19.3582382, -2482.66382, 0.984725893, -4.8232188e-08, 0.174111873, 3.5906762e-08, 1, 7.39402282e-08, -0.174111873, -6.65590676e-08, 0.984725893))
		wait(1)
		G_17_(CFrame.new(2279.09497, 19.5319271, -2566.47266, 0.923211098, 1.34089917e-09, -0.384293169, -1.34842226e-09, 1, 2.49863297e-10, 0.384293169, 2.87512902e-10, 0.923211098))
		wait(1)
		G_17_(CFrame.new(2291.23999, 19.7313976, -2586.60156, 0.837760448, 7.36023225e-08, -0.546037972, -8.74550352e-08, 1, 6.15250739e-10, 0.546037972, 4.72383377e-08, 0.837760448))
		wait(1)
		G_17_(CFrame.new(2279.09497, 19.5319271, -2566.47266, 0.923211098, 1.34089917e-09, -0.384293169, -1.34842226e-09, 1, 2.49863297e-10, 0.384293169, 2.87512902e-10, 0.923211098))
		wait(1)
		G_17_(CFrame.new(2215.97217, 19.3582382, -2482.66382, 0.984725893, -4.8232188e-08, 0.174111873, 3.5906762e-08, 1, 7.39402282e-08, -0.174111873, -6.65590676e-08, 0.984725893))
		wait(1)
		G_17_(CFrame.new(2216.5354, 19.3582458, -2470.72461, 0.988022506, -8.40341983e-08, 0.154309943, 8.18320629e-08, 1, 2.06226609e-08, -0.154309943, -7.74815145e-09, 0.988022506))
		wait(1)
		G_17_(CFrame.new(2286.67114, 19.1927166, -2080.41528, 0.999894977, 2.60326927e-10, 0.0144938128, -2.627637e-10, 1, 1.66221661e-10, -0.0144938128, -1.70012643e-10, 0.999894977))
		Hb(9, function()
			return M.PlayerGui.RobberyMoneyGui.Container.Bottom.Progress.Amount.Visible
		end)
		Xb()
		if ic then
			rb = false
			p.TextColor3 = Color3.new(1, 1, 1)
			gb("Train success!")
		end
	end
	fb(false)
	wait(2)
	if ic then
		gb("10 second cooldown.")
		wait(10)
	end
end
local function dc()
	local ic = Wb("Airdrop")
	if ic then
		local jc = vb[1]
		if jc and jc.Parent then
			gb("TPing to airdrop...")
			cb()
			carTP(jc.CFrame)
			network:FireServer(keys.ExitCar);
			local kc = workspace.Gravity
			workspace.Gravity = 0
			Hb()
			if S then
				ic = false
			else
				Hb(70, function(lc)
					gb("Please wait "..math.floor(10 - lc).." seconds.")
					Q.CFrame = jc.CFrame + Vector3.new(0, 7, 0)
					Q.Velocity, Q.RotVelocity = R, R
					if lb then
						if math.floor(70 - lc) % 7 == 0 then
							for mc = 1, #lb do
								if lb[mc].Part == jc then
									lb[mc]:Callback(true)
									break
								end
							end
						end
						wait(lc % 1)
					else
						Qb(jc)
						Hb()
						N:SendKeyEvent(true, "E", false, game)
						Hb(6.5, function()
							return jc.Parent ~= nil
						end)
						N:SendKeyEvent(false, "E", false, game)
					end
					return jc.Parent ~= nil
				end)
				Hb(1)
			end
			workspace.Gravity = kc
			db()
			Xb()
		end
		if ic then
			gb("Airdrop success!")
		end
	end
	fb(false)
	wait(2)
	if ic then
		gb("10 second cooldown.")
		wait(10)
	end
end
local function ec()
	local ic = Wb("Plane")
	if ic then
		local jc
		if workspace:FindFirstChild("Plane") then
			jc = workspace.Plane:FindFirstChild("Root")
		end
		if jc then
			gb("Waiting for takeoff.")
			Hb(20, function()
				return jc.Parent ~= nil and jc.Position.Y < 300
			end)
			gb("TPing to plane...")
			carTP(workspace.Plane.Root.CFrame)
			ic = not S
			if workspace:FindFirstChild("Plane") then
				gb("Robbery started!")
				local kc = workspace.Plane.Crates:GetChildren()
				for lc = 1, #kc do
					local mc = kc[lc]:FindFirstChild("1")
					if mc and mc.Parent and mc.Transparency < .99 and not S then
						local nc = mc.Parent["2"]
						local oc
						O = Y:Connect(function()
							Q.CFrame = nc.CFrame + Vector3.new(0, -9, 0)
							Q.Velocity, Q.RotVelocity = R, R
						end)
						if lb then
							Hb(0.5)
							for pc = 1, #lb do
								local qc = lb[pc]
								if lb[pc].Part == mc then
									lb[pc]:Callback(true)
									break
								end
							end
						else
							mc.Anchored = false
							oc = e("Weld", mc, {
								Part0 = mc,
								Part1 = Q,
								C0 = CFrame.new(0, 4.5, 0)
							})
							Hb(0.5)
							Qb(mc)
							Hb(20, function()
								return mc.Transparency < .99
							end)
							N:SendKeyEvent(false, "E", false, game)
							mc.CanCollide = true
						end
						Hb(0.5)
						O:Disconnect()
						if M.PlayerGui.RobberyMoneyGui.Container.Bottom.Progress.Amount.Visible == true then
							--gb("Bypassing by waiting...")
							carTP(CFrame.new(2287.85889, 19.2167702, -2079.25439, 0.648379564, -1.39355008e-08, -0.761317253, 7.61388907e-09, 1, -1.18200534e-08, 0.761317253, 1.86729587e-09, 0.648379564))
							if oc then
								oc:Destroy()
							end
							Hb(9)
							Jb()
							gb("Selling...")
							carTP(CFrame.new(-328.864075, 21.2396393, 2047.15833, 0.725646138, 6.38517506e-08, 0.688068032, -6.68926319e-08, 1, -2.22526921e-08, -0.688068032, -2.98791036e-08, 0.725646138))
							wait(1)
							G_17_(CFrame.new(-333.380646, 21.2396393, 2051.09912, 0.79385674, -4.42797443e-08, 0.608104765, 4.75456474e-08, 1, 1.07470104e-08, -0.608104765, 2.03811492e-08, 0.79385674))
							wait(1)
							G_17_(CFrame.new(-340.594696, 21.2396374, 2055.54614, 0.7938568, -2.92722255e-08, 0.608104765, 2.97143536e-08, 1, 9.34589472e-09, -0.608104765, 1.06501377e-08, 0.7938568))
							wait(1)
							G_17_(CFrame.new(-328.864075, 21.2396393, 2047.15833, 0.725646138, 6.38517506e-08, 0.688068032, -6.68926319e-08, 1, -2.22526921e-08, -0.688068032, -2.98791036e-08, 0.725646138))
							Q.Anchored = true
							Hb(3, function()
								return M.PlayerGui.MainGui.CrateCollectMoney.Visible
							end)
							Q.Anchored = false
							break
						elseif oc then
							oc:Destroy()
						end
					end
				end
			end
			Xb()
		end
		if ic then
			sb = false
			t.TextColor3 = Color3.new(1, 1, 1)
			gb("Plane success!")
		end
	end
	fb(false)
	wait(2)
	if ic then
		gb("10 second cooldown.")
		wait(10)
	end
end
local function fc()
	wb = tick()
	gb("Speeding up the plane...")
	local ic = Q.CFrame
	if tostring(M.Team) ~= "Police" then
		c(nb, ob, "Police")
		nb()
		M.CharacterAdded:Wait()
		wait(0.5)
	end
	for kc = 1, #lb do
		if lb[kc].Name == "Call Cargo Plane" then
			lb[kc]:Callback(true)
			break
		end
	end
	local jc
	jc = game.CoreGui.RobloxGui.NotificationFrame.ChildAdded:Connect(function(kc)
		jc:Disconnect()
		local lc = kc:WaitForChild("NotificationText").Text
		if lc:match("Wait %d") then
			wb = tick() - (197 - tonumber(lc:match("%d+")))
		end
	end)
	wait(0.5)
	c(nb, ob, "Prisoner")
	nb()
	M.CharacterAdded:Wait()
	wait(3)
	Tb(ic)
	if workspace:FindFirstChild("Plane") then
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "CargoPlane",
			Text = "Arriving shortly!"
		})
	end
end
game:GetService("StarterGui"):SetCore("SendNotification", {
	Title = "Auto-Rob by sirelKilla",
	Text = X and "SETTINGS CHANGED!" or "",
	Duration = 20,
	Button1 = "ok boomer"
})
local gc = 0
local hc = 0
while wait(0.5) and f.Parent do
	if workspace.Trains:FindFirstChild("LocomotiveFront") then
		local ic = workspace.Trains.LocomotiveFront.Model.Front.Position
		if ic.X < -1300 and ic.Z < 350 then
			tb = nil
			p.TextColor3 = Color3.new(1, 1, 1)
		end
	end
	if (fireclickdetector or click_detector) and workspace.Switches.BranchBack.Rail.Transparency < .9 then
		(fireclickdetector or click_detector)(workspace.Switches.BranchBack.Lever.Click.ClickDetector, 1)
	end
	if tick() - hc > 60 then
		hc = tick()
		game:GetService("VirtualUser"):CaptureController()
		game:GetService("VirtualUser"):ClickButton2(Vector2.new())
	end
	M.PlayerGui.RobberyMoneyGui.Enabled = false
	if W.enabled then
		if sb then
			ec()
		elseif Eb then
			bc()
		elseif Db then
			Yb()
		elseif rb then
			cc()
		elseif tb then
			ac()
		--elseif Cb then
			--Zb()
		elseif nb and W.respawnForPlane and tick() - wb > 197 and (#L:GetPlayers() < 20 or #game:GetService("Teams").Police:GetPlayers() > 1) then
			fc()
		elseif #vb > 0 then
		    dc()
		else
			gb("Wait for stores to open"..string.rep('.', gc % 3 + 1))
			gc = gc + 1
		end
	else
		gb("Disabled.")
	end
end
