
--local keys, network = loadstring(game:HttpGet("https://raw.githubusercontent.com/Introvert1337/RobloxReleases/main/Scripts/Jailbreak/KeyFetcher.lua"))();

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
        vehicle_speed = 150
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
        --movement:pathfind();
        task.wait(0.5);
    end;
    
    local y_level = 25;
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


local old_is_point_in_tag = dependencies.modules.player_utils.isPointInTag;
dependencies.modules.player_utils.isPointInTag = function(point, tag)
    if tag == "NoRagdoll" or tag == "NoFallDamage" then 
        return true;
    end;
    
    return old_is_point_in_tag(point, tag);
end;


G_8_ = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
local player = game.Players.LocalPlayer

local tweenservice = game:GetService('TweenService')



function Notif(Text,Time)
    require(game:GetService("ReplicatedStorage").Game.Notification).SetColor(Color3.fromRGB(0,0,0))
    require(game:GetService("ReplicatedStorage").Game.Notification).new({
        Text = Text,
        Duration = Time
    })
end

local deez = game:GetService("VirtualInputManager")

			local function Ib(ic)
				deez:SendKeyEvent(true, ic, false, game)
				wait()
				deez:SendKeyEvent(false, ic, false, game)
			end


local function selltp(cframe,tried)
    local tried = tried or {};
    local nearest_vehicle = utilities:get_nearest_vehicle(tried);
    
    if player.Character.Humanoid.Sit == false then
        movement:move_to_position(player.Character.HumanoidRootPart, nearest_vehicle.Seat.CFrame, dependencies.variables.player_speed);
        
        local enter_attempts = 1;

        repeat -- attempt to enter car
            for _,d in pairs(require(game:GetService("ReplicatedStorage").Module.UI).CircleAction.Specs) do
                        if d.Part == nearest_vehicle.Seat then
                            d:Callback(d,true)
                        end
                    end
                    
            enter_attempts = enter_attempts + 1;

            task.wait(0.1);
        until enter_attempts == 10 or nearest_vehicle.Seat.PlayerName.Value == player.Name;

        if nearest_vehicle.Seat.PlayerName.Value ~= player.Name then -- if it failed to enter, try a new car
            table.insert(tried, nearest_vehicle);

            return tp(cframe, tried or {nearest_vehicle});
        end;



        function G_17_(a)
  --va(true)
		local tween = tweenservice:Create(nearest_vehicle.PrimaryPart, TweenInfo.new((a.Position - player.Character.PrimaryPart.Position).Magnitude / 60), {CFrame = CFrame.new(a.Position)})
       tween:Play()
       tween.Completed:Wait()
  --va(false)
end

        --[[wait(1)
        network:FireServer(keys.EnterCar, nearest_vehicle, nearest_vehicle.Seat);
        wait(1)--]]
       if dependencies.helicopters[nearest_vehicle.Name] then
                    movement:sellTP(nearest_vehicle.Model.TopDisc, cframe, dependencies.variables.vehicle_speed);
                    task.wait(0.15);
                    for _,d in pairs(require(game:GetService("ReplicatedStorage").Module.UI).CircleAction.Specs) do
                        if d.Part == nearest_vehicle.Seat then
                            d:Callback(d,true)
                        end
                    end
                    task.wait(0.15);
                    local deez = game:GetService("VirtualInputManager")

			local function Ib(ic)
				deez:SendKeyEvent(true, ic, false, game)
				wait()
				deez:SendKeyEvent(false, ic, false, game)
			end
                    --network:FireServer(keys.ExitCar)
                elseif dependencies.motorcycles[nearest_vehicle.Name] then
                    movement:sellTP(nearest_vehicle.CameraVehicleSeat, cframe, dependencies.variables.vehicle_speed);
                    task.wait(0.15);
                    for _,d in pairs(require(game:GetService("ReplicatedStorage").Module.UI).CircleAction.Specs) do
                        if d.Part == nearest_vehicle.Seat then
                            d:Callback(d,true)
                        end
                    end
                    task.wait(0.15);
                    --network:FireServer(keys.ExitCar)
                elseif nearest_vehicle.Name == "DuneBuggy" then
                    movement:sellTP(nearest_vehicle.BoundingBox, cframe, dependencies.variables.vehicle_speed);
                    task.wait(0.15);
                    for _,d in pairs(require(game:GetService("ReplicatedStorage").Module.UI).CircleAction.Specs) do
                        if d.Part == nearest_vehicle.Seat then
                            d:Callback(d,true)
                        end
                    end
                    task.wait(0.15);
                    --network:FireServer(keys.ExitCar)
                elseif nearest_vehicle.Name == "Chassis" then
                    movement:sellTP(nearest_vehicle.PrimaryPart, cframe, dependencies.variables.vehicle_speed);
                else
                    movement:sellTP(nearest_vehicle.PrimaryPart, 500, cframe, dependencies.variables.vehicle_speed);
                    --G_17_(cframe)
                    task.wait(0.15);
                    for _,d in pairs(require(game:GetService("ReplicatedStorage").Module.UI).CircleAction.Specs) do
                        if d.Part == nearest_vehicle.Seat then
                            d:Callback(d,true)
                        end
                    end
                    task.wait(0.15);
                    --network:FireServer(keys.ExitCar)
                end
    else
        for i,v in pairs(workspace.Vehicles:GetChildren()) do 
            if v.PrimaryPart ~= nil and v.Seat:FindFirstChild("Player") and v.Seat.Player.Value == true and tostring(v.Seat.PlayerName.Value) == game:GetService("Players").LocalPlayer.Name then 
                
                if dependencies.helicopters[v.Name] then
                    movement:sellTP(v.Model.TopDisc, cframe, dependencies.variables.vehicle_speed);
                    task.wait(0.15);
                    network:FireServer(keys.ExitCar)
                elseif dependencies.motorcycles[v.Name] then
                    movement:sellTP(v.CameraVehicleSeat, cframe, dependencies.variables.vehicle_speed);
                    task.wait(0.15);
                    network:FireServer(keys.ExitCar)
                elseif v.Name == "DuneBuggy" then
                    movement:sellTP(v.BoundingBox, cframe, dependencies.variables.vehicle_speed);
                    task.wait(0.15);
                    network:FireServer(keys.ExitCar)
                elseif v.Name == "Drone" then
                    Notif("Drone unsupported","3")
                else
                    print(v)
                    movement:sellTP(v.PrimaryPart, cframe, dependencies.variables.vehicle_speed);
                    task.wait(0.15);
                    --network:FireServer(keys.ExitCar)
                end
                --v:MoveTo(Vector3.new(-289.790344, 18.853775, 1603.8446)) -- Change the cords you want to TP Too. Current: Crime Base 
            end
        end
    end
end

return selltp
