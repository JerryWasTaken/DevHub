
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))().Load({
     Title = "DevHub - Ninja Legends",
    Style = 1,
    SizeX = 500,
    SizeY = 300,
    Theme = "Dark",
});

local s = setmetatable({}, {
    __index = function(self, key)
        return game:GetService(key);
    end;
});

-- Localization.
repeat wait() until (game and game:IsLoaded()) and (s.Players.LocalPlayer and s.Players.LocalPlayer.Character);

local Player = s.Players.LocalPlayer;
local Character = Player.Character or Player.CharacterAdded:Wait();
local rootpart = Character.HumanoidRootPart
local isfolder = game:GetService("Workspace").islandUnlockParts
local rankfolder = game:GetService("ReplicatedStorage").Ranks
local coinsfolder = game:GetService("Workspace").spawnedCoins.Valley
local hoopsfolder = game:GetService("Workspace").Hoops
local bossfolder = game:GetService("Workspace").bossFolder

Player.CharacterAdded:Connect(function(char)
    Character = char;
end);

local Workspace = s.Workspace;
local TweenService = s.TweenService;
local RunService = s.RunService;
local VirtualUser = s.VirtualUser;
local ReplicatedStorage = s.ReplicatedStorage;
local Lighting = s.Lighting;

local Camera = Workspace.CurrentCamera;
local Heartbeat, Stepped, RenderStepped = RunService.Heartbeat, RunService.Stepped, RunService.RenderStepped;

-- Exploit Check.
if not firetouchinterest then
    Player:Kick("[BLEUS]: Your exploit isn't compatible with this script.");
    return;
end;

-- Functions consist of: Find | Tween | ninjaEvent | sellNin | getName | updateShop.
local Find, Tween, ninjaEvent, sellNin, getName, updateShop; do
    function Find(dir, name)
        local d, e = math.huge;
        
        for i, v in next, dir:GetDescendants() do -- when I get home ima see if I can change this to GetChildren,
            if (v.Name:find(name) and (v.Transparency and v.Transparency ~= 1)) then
                local Magnitude = Player:DistanceFromCharacter(v.Position);
                
                if Magnitude < d then
                    d = Magnitude;
                    e = v;
                end;
            end;
        end;
        
        return e;
    end;
    
    function Tween(obj, props, time)
        local Tweeb = TweenService:Create(obj, TweenInfo.new(time), props);
        Tweeb:Play();
        
    	return Tweeb;
    end;
    
    function ninjaEvent(...)
        if not Player.ninjaEvent then return end;
        Player.ninjaEvent:FireServer(...);
    end;
    
    function sellNin(t) -- I might make this better in the future.
        local Menu = Player.PlayerGui.gameGui.maxNinjitsuMenu;
        local SellCircle = Workspace.sellAreaCircles.sellAreaCircle16.circleInner:FindFirstChildWhichIsA("TouchTransmitter");
        local Root = (Character.HumanoidRootPart or Character:WaitForChild("HumanoidRootPart"));

        if (not SellCircle or not Menu) then return end;
        
        if t then
            firetouchinterest(Root, SellCircle.Parent, 0);
            wait(0.1);
            firetouchinterest(Root, SellCircle.Parent, 1);
        else
            firetouchinterest(Root, SellCircle.Parent, 0);
            wait(0.1);
            firetouchinterest(Root, SellCircle.Parent, 1);
        end;
    end;
    
    function getName(Option) -- lazy code I dont wanna make better.
        local Results, dir = { }, Player.PlayerGui.gameGui.itemsShopMenu.menus.ranksMenu; do
            if Option == "Weapons" then
                dir = Player.PlayerGui.gameGui.itemsShopMenu.menus.swordsMenu;
            end;
        end;
        
        for i, v in next, dir:GetChildren() do
            if v:IsA("Frame") and (v:FindFirstChild("swordButton") and v:FindFirstChild("lockImage", true) and v:FindFirstChild("equippedLabel", true) and not v.swordButton.lockImage.Visible and not v.swordButton.equippedLabel.Visible) then
                Results[#Results + 1] = v:FindFirstChildWhichIsA("ObjectValue").Value;
            end;
        end;
        
        return tostring(Results[#Results]);
    end;
    
    function updateShop()
        local shopInnerCircle = Workspace.shopAreaCircles.shopAreaCircle19.circleInner;
        local ItemShop = (Player.PlayerGui.gameGui.itemsShopMenu or Player.PlayerGui.gameGui:WaitForChild("itemsShopMenu"));
        
        if (shopInnerCircle and not ItemShop.Visible) then
            local Transmitter = shopInnerCircle:FindFirstChildWhichIsA("TouchTransmitter");
            firetouchinterest((Character.HumanoidRootPart or Character:WaitForChild("HumanoidRootPart")), Transmitter.Parent, 0);
            wait(0.1);
            firetouchinterest((Character.HumanoidRootPart or Character:WaitForChild("HumanoidRootPart")), Transmitter.Parent, 1);
        end;
        
        ItemShop.Visible = false;
        
        if Lighting:FindFirstChild("screenBlur") then
            task.defer(Lighting.screenBlur.Destroy, Lighting.screenBlur);
        end;
    end;
end;

updateShop(); -- just update the shop now lol.

Player.CharacterAdded:Connect(updateShop);
Player.equippedRank:GetPropertyChangedSignal("Value"):Connect(updateShop);

-- Anti-AFK.
if getconnections then
    for i = 1, #getconnections(Player.Idled) do
        getconnections(Player.Idled)[i]:Disable();
    end;
else
    Player.Idled:Connect(function()
       VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame);
       wait(1);
       VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame);
    end);
end;

-- Flags and Chips.
shared._Flags, shared._Chips = {
    AutoSwing,
    AutoSell,
    AutoBuySwords,
    AutoBuyBelts,
    AutoBuyShurikens,
    AutoBuySkills,
    AutoRankUp,
    CollectCoins,
    CollectChi
}, {
    SellAtMaxNin,
    HideWeapon  
};

-- Library Initalation.
local Main = Library.New({
    Title = "Main";
}); do
    Main.Toggle({
        Text = "Auto Swing",
        Callback = function(v)
            shared._Flags.AutoSwing = v;
        end,
        
        Enabled = false;
    });
    
    Main.ChipSet({
        Text = "pop",
        Callback = function(Chip)
            table.foreach(Chip, function(Option, State)
                shared._Chips.HideWeapon = State;
            end);
        end,
        
        Options = { ["Hide Weapon"] = false };
    });
    
    Main.Toggle({
        Text = "Auto Sell",
        Callback = function(v)
            shared._Flags.AutoSell = v;
        end,
        
        Enabled = false;
    });
    
    Main.ChipSet({
        Text = "pop2",
        Callback = function(Chip)
            table.foreach(Chip, function(Option, State)
                shared._Chips.SellAtMaxNin = State;
            end);
        end,
        
        Options = { ["Sell At Max Ninjitsu"] = false };
    });
    
    Main.Toggle({
        Text = "Auto Buy Swords",
        Callback = function(v)
            shared._Flags.AutoBuySwords = v;
        end,
        
        Enabled = false;
    });
        
    Main.Toggle({
        Text = "Auto Buy Belts",
        Callback = function(v)
            shared._Flags.AutoBuyBelts = v;
        end,
        
        Enabled = false;
    });
    
    Main.Toggle({
        Text = "Auto Buy Shurikens",
        Callback = function(v)
            shared._Flags.AutoBuyShurikens = v;
        end,
        
        Enabled = false;
    });
    
    Main.Toggle({
        Text = "Auto Buy Skills",
        Callback = function(v)
            shared._Flags.AutoBuySkills = v;
        end,
        
        Enabled = false;
    });
    
    Main.Toggle({
        Text = "Auto RankUp",
        Callback = function(v)
            shared._Flags.AutoRankUp = v;
        end,
        
        Enabled = false;
    });
end;

local Farming = Library.New({
    Title = "Farming";
}); do
    Farming.Toggle({
        Text = "Collect Coins",
        Callback = function(v)
            shared._Flags.CollectCoins = v;
        end,
        
        Enabled = false;
    });
    
    Farming.Toggle({
        Text = "Collect Chi",
        Callback = function(v)
            shared._Flags.CollectChi = v;
        end,
        
        Enabled = false;
    });
end;

local Teleports = Library.New({
    Title = "Teleports";
}); do
    for i = 1, #Workspace.islandUnlockParts:GetChildren() do
        local v = Workspace.islandUnlockParts:GetChildren()[i];
        
        Teleports.Button({
            Text = v.Name,
            Callback = function()
                Character.HumanoidRootPart.CFrame = (v.CFrame + Vector3.new(0, -25, 0));
                task.wait();
                Character.Humanoid:ChangeState(11);
            end;
        });
    end;
end;

local Misc = Library.New({
    Title = "Misc"
}); do
    Misc.Button({
        Text = "Unlock All Islands",
        Callback = function(v)
            for i = 1, #Workspace.islandUnlockParts:GetChildren() do
                local v = Workspace.islandUnlockParts:GetChildren()[i];

                if v:FindFirstChildWhichIsA("TouchTransmitter") then
                    local Transmitter = v:FindFirstChildWhichIsA("TouchTransmitter");
                    firetouchinterest(Character.HumanoidRootPart, Transmitter.Parent, 0);
                    task.wait();
                    firetouchinterest(Character.HumanoidRootPart, Transmitter.Parent, 1);
                end;
            end;
        end;
    });
    
    Misc.Button({
        Text = "Open All Chests",
        Callback = function(v)
            for i = 1, #Workspace:GetChildren() do
                local v = Workspace:GetChildren()[i];
                
                if v:FindFirstChild("Chest") and (v:FindFirstChild("circleInner") and v.circleInner:FindFirstChildWhichIsA("TouchTransmitter")) then
                    local Transmitter = v.circleInner:FindFirstChildWhichIsA("TouchTransmitter");
                    firetouchinterest(Character.HumanoidRootPart, Transmitter.Parent, 0);
                    task.wait();
                    firetouchinterest(Character.HumanoidRootPart, Transmitter.Parent, 1);

                    wait(3); -- because of chest delay.
                end;
            end;
        end;
    });
    
    Misc.Button({
        Text = "Hide Pop-Ups",
        Callback = function(v)
            if not Player.PlayerGui:FindFirstChild("statEffectsGui") then return end;
            Player.PlayerGui.statEffectsGui:Destroy();

            Player.PlayerGui.ChildAdded:Connect(function(v)
                if v.Name == "statEffectsGui" then
                    task.defer(v.Destroy, v); -- v:Destroy(); defering is better than blatantly destroying it.
                end;
            end);
        end;
    });
end;

local GiveElement = Misc.Dropdown({
    Text = "Give element",
    Callback = function(Value)
        game.ReplicatedStorage.rEvents.elementMasteryEvent:FireServer(Value)
    end,
    Options = {"Inferno", "Frost", "Lightning", "Electral Chaos", "Masterful Wrath", "Shadow Charge", "Eternity Storm", "Shadowfire"}
})

local AutoRobot = Misc.Toggle({
    Text = "Auto Robot Boss {AutoSell Recommended}",
    Callback = function(Value)
        _G.robot = Value
 
        while true do
            if not _G.robot then return end
            local check = bossfolder:FindFirstChild("RobotBoss")
            if check == nil then return end
            rootpart.CFrame = bossfolder["RobotBoss"].HumanoidRootPart.CFrame
            local A_1 = "swingKatana"
            local Event = Player.ninjaEvent
            Event:FireServer(A_1)
            wait()
        end
    end,
    Enabled = false
})
 
local AutoEternalBoss = Misc.Toggle({
    Text = "Auto Eternal Boss {AutoSell Recommended}",
    Callback = function(Value)
        _G.EternalBoss = Value
 
        while true do
            if not _G.EternalBoss then return end
            local check = bossfolder:FindFirstChild("EternalBoss")
            if check == nil then return end
            rootpart.CFrame = bossfolder["EternalBoss"].HumanoidRootPart.CFrame
            local A_1 = "swingKatana"
            local Event = Player.ninjaEvent
            Event:FireServer(A_1)
            wait()
        end
    end,
    Enabled = false
})
 
local AutoAncientMagmaBoss = Misc.Toggle({
    Text = "Auto Ancient Magma Boss {AutoSell Recommended}",
    Callback = function(Value)
        _G.AncientBoss = Value
 
        while true do
            if not _G.AncientBoss then return end
            local check = bossfolder:FindFirstChild("AncientMagmaBoss")
            if check == nil then return end
            rootpart.CFrame = bossfolder["AncientMagmaBoss"].HumanoidRootPart.CFrame
            local A_1 = "swingKatana"
            local Event = Player.ninjaEvent
            Event:FireServer(A_1)
            wait()
        end
    end,
    Enabled = false
})
 


-- Main Loop.
pcall(function() if shared._loop then shared._loop:Disconnect() end end);

wait();
task.spawn(function()
    shared._loop = Stepped:Connect(function()
        if shared._Flags.AutoSwing then
            if not Player:FindFirstChild("ninjaEvent") then return end;

            for i, v in next, Player.Backpack:GetChildren() do
                if (v:FindFirstChild("ninjitsuGain") and not Character:FindFirstChild("ninjitsuGain")) then
                    (Character.Humanoid or Character:WaitForChild("Humanoid")):EquipTool(v);
                end;
            end;
            
            if Character:FindFirstChildWhichIsA("Tool"):FindFirstChild("ninjitsuGain") then
                ninjaEvent("swingKatana");
                
                if shared._Chips.HideWeapon then
                    local Weapon = Character:FindFirstChildWhichIsA("Tool");
                    if (not Weapon or not Weapon:FindFirstChild("ninjitsuGain")) then return end;

                    for i = 1, #Weapon:GetChildren() do
                        local v = Weapon:GetChildren()[i];
                        
                        if (v:FindFirstChildWhichIsA("ParticleEmitter") or v:FindFirstChildWhichIsA("PointLight") or v:FindFirstChildWhichIsA("Trail")) then
                            task.defer(v.Destroy, v);
                        elseif v:IsA("MeshPart") then
                            v.Transparency = 1;
                        end;
                    end;
                    
                    if Character:FindFirstChild("swordCloneModel") then
                        task.defer(Character.swordCloneModel.Destroy, Character.swordCloneModel);
                    end;
                end;
            end;
        end;
        
        if shared._Flags.AutoSell then
            sellNin(shared._Chips.SellAtMaxNin);
        end;
        
        if shared._Flags.AutoBuyBelts then
            ninjaEvent("buyAllBelts", "Blazing Vortex Island");
        end;
        
        if shared._Flags.AutoBuySwords then
            ninjaEvent("buySword", getName("Weapons"));
        end;
        
        if shared._Flags.AutoBuyShurikens then
            ninjaEvent("buyAllShurikens", "Blazing Vortex Island");
        end;

        if shared._Flags.AutoBuySkills then
            ninjaEvent("buyAllSkills", "Blazing Vortex Island");
        end;
        
        if shared._Flags.CollectCoins then
            local Coins = Find(Workspace.spawnedCoins.Valley, "Coin");
            
            if Coins then
                (Character.Humanoid or Character:WaitForChild("Humanoid")):ChangeState(11);
                (Character.HumanoidRootPart or Character:WaitForChild("HumanoidRootPart")).CFrame = Coins.CFrame; --Tween((Character.HumanoidRootPart or Character:WaitForChild("HumanoidRootPart")), {CFrame = CFrame.new(Coins.Position)}, Player:DistanceFromCharacter(Coins.Position) / 1500, Enum.EasingStyle.Linear);
            end;
        end;
        
        if shared._Flags.CollectChi then
            local Chi = Find(Workspace.spawnedCoins.Valley, "Chi");
            
            if Chi then
                (Character.Humanoid or Character:WaitForChild("Humanoid")):ChangeState(11);
                (Character.HumanoidRootPart or Character:WaitForChild("HumanoidRootPart")).CFrame = Chi.CFrame; --Tween((Character.HumanoidRootPart or Character:WaitForChild("HumanoidRootPart")), {CFrame = CFrame.new(Chi.Position)}, Player:DistanceFromCharacter(Chi.Position) / 1500, Enum.EasingStyle.Linear);
            end;
        end;
        
        if shared._Flags.AutoRankUp then
            ninjaEvent("buyRank", getName("Ranks"));
        end;
    end);
end);