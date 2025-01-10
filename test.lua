-- Get the Library
local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

-- Create the GUI
local GUI = Mercury:Create{
    Name = "Mercury",
    Size = UDim2.fromOffset(600, 400),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/deeeity/mercury-lib"
}

-- Create the Sandy Autorace Tab
local SandyAutoraceTab = GUI:Tab{
    Name = "Sandy Autorace",
    Icon = "rbxassetid://8569322835"
}

-- Create the Autofarms Tab
local AutofarmsTab = GUI:Tab{
    Name = "Autofarms",
    Icon = "rbxassetid://8569322835"
}

-- Define the target CFrame
local targetCFrame = CFrame.new(32, 15, -2334) * CFrame.Angles(-0.22200000286102295, 28.305999755859375, 0.14499999582767487)
local teleportCFrame = CFrame.new(33.4263916, 13.992197, -2335.7002, -0.000281376473, -0.354013532, -0.935240984, 0.999999881, 6.94168994e-05, -0.000327080896, 0.000180645933, -0.935241342, 0.354012847)
local initialTeleportCFrame = CFrame.new(50, 15, -2290, 1, 0, 0, 0, 1, 0, 0, 0, 1)

-- Define the CFrames for Helicopter Autofarm
local helicopterCFrame1 = CFrame.new(8069.80566, 2322.02588, -4987.56543, -0.882902145, -0.0165187418, -0.469266415, -0.0187662691, 0.999823868, 0.000112827205, 0.469181895, 0.00890599564, -0.883056641)
local helicopterCFrame2 = CFrame.new(-11043.2266, 2481.86523, 6594.7915, -0.819718659, -0.087325491, -0.566070259, -0.105920158, 0.994374633, -1.68102688e-05, 0.562887371, 0.0599444732, -0.824356973)

-- Define the rotations for the primary part
local rotation1 = Vector3.new(179.7689971923828, 55.9370002746582, -179.7989959716797)
local rotation2 = Vector3.new(0.11900000274181366, -57.21099853515625, 0.29899999499320984)

-- Variable to track the state of the toggles
local autofarmMainEnabled = false
local autofarmAltEnabled = false
local antiAFKEnabled = false
local helicopterAutofarmEnabled = false
local flySpeed = 50 -- Default fly speed
local helicopterSpeed = 50 -- Default helicopter speed
local modelsDeleted = false -- Flag to ensure models are deleted only once

-- Function to get the player's car
local function getPlayerCar(playerName)
    local car = workspace.Vehicles:FindFirstChild(playerName)
    return car
end

-- Function to set the primary part of the car
local function setPrimaryPart(car)
    if not car.PrimaryPart then
        local primaryPart = car:FindFirstChildWhichIsA("BasePart")
        if primaryPart then
            car.PrimaryPart = primaryPart
        end
    end
end

-- Function to get the primary part of the vehicle
local function getPrimaryPart(vehicle)
    local primaryPart = vehicle.PrimaryPart
    if not primaryPart then
        primaryPart = vehicle:FindFirstChildWhichIsA("BasePart")
    end
    return primaryPart
end

-- Function to teleport the car
local function teleportCar(car, cframe)
    if car then
        setPrimaryPart(car)
        if car.PrimaryPart then
            car:SetPrimaryPartCFrame(cframe)
            return true
        end
    end
    return false
end

-- Function to make the vehicle fly to a CFrame
local function flyVehicleToCFrame(vehicle, targetCFrame, speed, targetRotation)
    local T = getPrimaryPart(vehicle)
    if not T then
        return
    end

    local BG = Instance.new('BodyGyro')
    local BV = Instance.new('BodyVelocity')
    BG.P = 9e4
    BG.Parent = T
    BV.Parent = T
    BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    BG.cframe = T.CFrame
    BV.velocity = Vector3.new(0, 0, 0)
    BV.maxForce = Vector3.new(9e9, 9e9, 9e9)

    local function moveToCFrame()
        local currentPos = T.Position
        local direction = (targetCFrame.Position - currentPos).Unit
        local distance = (targetCFrame.Position - currentPos).Magnitude
        BV.velocity = direction * speed
        BG.cframe = targetCFrame * CFrame.Angles(math.rad(targetRotation.X), math.rad(targetRotation.Y), math.rad(targetRotation.Z))
        if distance < 10 then
            BV.velocity = Vector3.new(0, 0, 0)
            BG:Destroy()
            BV:Destroy()
            return true
        end
        return false
    end

    while not moveToCFrame() do
        wait()
    end
end

-- Function to make the vehicle fly to checkpoints
local function flyToCheckpoints(car, laps)
    while true do
        local checkpoints = workspace.Game.Races.LocalSession.SandyShores.Checkpoints:GetChildren()
        if #checkpoints == 0 then
            wait(1) -- Wait and retry
            continue
        end

        table.sort(checkpoints, function(a, b)
            return tonumber(a.Name) < tonumber(b.Name)
        end)

        for lap = 1, laps do
            for _, checkpoint in ipairs(checkpoints) do
                local checkpointCFrame = checkpoint.CFrame
                flyVehicleToCFrame(car, checkpointCFrame, flySpeed)
                wait(0.2) -- Freeze at each checkpoint for 0.2 seconds
            end
        end

        -- Fly to the finish ring after completing the laps
        local finishRing = workspace.Game.Races.LocalSession.SandyShores.Finish
        if finishRing then
            flyVehicleToCFrame(car, finishRing.CFrame, flySpeed)
        end

        break -- Exit the loop after completing the laps
    end
end

-- Function to delete specified models
local function deleteModels()
    if modelsDeleted then return end
    local modelsToDelete = {
        workspace.Map.Islands.SandyShores["Foundation (ForceLoad)"].Foundation.RockHills,
        workspace.Map.Islands.SandyShores.Track.Track.Structures:GetChildren()[4],
        workspace.Map.Islands.SandyShores.Track.Track.Structures:GetChildren()[5],
        workspace.Map.Islands.SandyShores.Track.Track.Structures.Railing,
        workspace.Map.Islands.SandyShores.Track.Track.Structures.Dock,
        workspace.Map.Islands.SandyShores["Foundation (ForceLoad)"].Foundation.DirtPath,
        workspace.Map.Islands.SandyShores["Foundation (ForceLoad)"].Foundation.GrassMain,
        workspace.Map.Islands.SandyShores["Foundation (ForceLoad)"].Foundation.SandSide,
        workspace.Map.Islands.SandyShores.Track.Track.Structures:GetChildren()[3],
        workspace.Map.Islands.SandyShores.Track.Track.Structures:GetChildren()[2],
        workspace.Map.Islands.SandyShores.Track.Track.Structures,
    }

    for _, model in ipairs(modelsToDelete) do
        if model then
            model:Destroy()
        end
    end
    modelsDeleted = true
end

-- Function to run the autofarm process
local function runAutofarm()
    while autofarmMainEnabled do
        -- Teleport the player's vehicle to the specified CFrame
        local player = game.Players.LocalPlayer
        local car = getPlayerCar(player.Name)
        if car then
            teleportCar(car, initialTeleportCFrame)
            wait(3) -- Wait for 3 seconds
        end

        -- Fire the remote event
        local args = {
            [1] = "SandyShores",
            [2] = "Exhibition",
            [3] = "Join"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RaceQueue"):FireServer(unpack(args))

        -- Wait for 22 seconds
        wait(22)

        -- Delete specified models
        deleteModels()

        -- Fly to checkpoints for 3 laps
        if car then
            flyToCheckpoints(car, 3)
        end

        -- Wait for 3 seconds after hitting the finish line
        wait(3)
    end
end

-- Function to run the alt autofarm process
local function runAutofarmAlt()
    while autofarmAltEnabled do
        -- Teleport the player's vehicle to the specified CFrame
        local player = game.Players.LocalPlayer
        local car = getPlayerCar(player.Name)
        if car then
            teleportCar(car, initialTeleportCFrame)
            wait(3) -- Wait for 3 seconds
        end

        -- Fire the remote event to join the race
        local args = {
            [1] = "SandyShores",
            [2] = "Exhibition",
            [3] = "Join"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RaceQueue"):FireServer(unpack(args))

        -- Wait for the race to start
        local stateText = player.PlayerGui["RacePadInfo (SandyShores)"].Container.Main.Background.Footer.StateBorder.State.State
        while stateText.Text ~= "Race is starting.." do
            wait()
            stateText = player.PlayerGui["RacePadInfo (SandyShores)"].Container.Main.Background.Footer.StateBorder.State.State
        end
        wait(22)

        -- Retrieve the altCarName from the player's vehicle CarType
        local altCarName = workspace.Vehicles[player.Name].CarType.Value

        -- Despawn the vehicle
        local args = {
            [1] = "Spawn",
            [2] = altCarName
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("VehicleEvent"):FireServer(unpack(args))

        -- Wait for 3 seconds
        wait(3)

        -- Retrieve the altCarName from the player's vehicle CarType
        local altCarName = workspace.Vehicles[player.Name].CarType.Value

        -- Spawn a new vehicle with the retrieved altCarName
        local args = {
            [1] = "Spawn",
            [2] = altCarName
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("VehicleEvent"):FireServer(unpack(args))

        -- Wait for 3 seconds
        wait(3)
    end
end

-- Function to run the helicopter autofarm process
local function runHelicopterAutofarm()
    while helicopterAutofarmEnabled do
        local player = game.Players.LocalPlayer
        local car = getPlayerCar(player.Name)
        if car then
            local T = getPrimaryPart(car)
            if T then
                print("Primary part found:", T)
                flyVehicleToCFrame(car, helicopterCFrame1, helicopterSpeed, rotation1)
                print("Flying to CFrame1")
                wait(1) -- Wait for 1 second
                flyVehicleToCFrame(car, helicopterCFrame2, helicopterSpeed, rotation2)
                print("Flying to CFrame2")
                wait(1) -- Wait for 1 second
            else
                print("Primary part not found for vehicle:", car)
            end
        else
            print("Vehicle not found for player:", player.Name)
        end
        wait(1) -- Add a small delay to avoid excessive looping
    end
end

-- Function to enable anti-AFK
local function enableAntiAFK()
    local GC = getconnections or get_signal_cons
    if GC then
        for i, v in pairs(GC(game.Players.LocalPlayer.Idled)) do
            if v["Disable"] then
                v["Disable"](v)
            elseif v["Disconnect"] then
                v["Disconnect"](v)
            end
        end
    else
        local VirtualUser = game:GetService("VirtualUser")
        game.Players.LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end

-- Add a Checkbox called Autofarm Main
SandyAutoraceTab:Toggle{
    Name = "Autofarm Main",
    StartingState = false,
    Description = "Enable Sandy Shores Autorace On Main Account",
    Callback = function(state)
        autofarmMainEnabled = state
        if state then
            -- Start the loop to run the autofarm process
            spawn(runAutofarm)
            GUI:Notification{
                Title = "Autofarm Main",
                Text = "Autofarm Main enabled",
                Duration = 5
            }
        else
            GUI:Notification{
                Title = "Autofarm Main",
                Text = "Autofarm Main disabled",
                Duration = 5
            }
        end
    end
}

-- Add a Checkbox called Autofarm Alt
SandyAutoraceTab:Toggle{
    Name = "Autofarm Alt",
    StartingState = false,
    Description = "Enable Sandy Shores Autorace On Alt Account",
    Callback = function(state)
        autofarmAltEnabled = state
        if state then
            -- Start the loop to run the alt autofarm process
            spawn(runAutofarmAlt)
            GUI:Notification{
                Title = "Autofarm Alt",
                Text = "Autofarm Alt enabled",
                Duration = 5
            }
        else
            GUI:Notification{
                Title = "Autofarm Alt",
                Text = "Autofarm Alt disabled",
                Duration = 5
            }
        end
    end
}

-- Add a Button called Anti AFK
SandyAutoraceTab:Button{
    Name = "Anti AFK",
    Callback = function()
        antiAFKEnabled = not antiAFKEnabled
        if antiAFKEnabled then
            enableAntiAFK()
            GUI:Notification{
                Title = "Anti AFK",
                Text = "Anti AFK enabled",
                Duration = 5
            }
        else
            GUI:Notification{
                Title = "Anti AFK",
                Text = "Anti AFK disabled",
                Duration = 5
            }
        end
    end
}

-- Add a Slider called Autofarm Speed
SandyAutoraceTab:Slider{
    Name = "Autofarm Speed",
    Default = 50,
    Min = 1,
    Max = 1000,
    Callback = function(value)
        flySpeed = value
    end
}

-- Add a Checkbox called Helicopter Autofarm
AutofarmsTab:Toggle{
    Name = "Helicopter Autofarm",
    StartingState = false,
    Description = nil,
    Callback = function(state)
        helicopterAutofarmEnabled = state
        if state then
            -- Start the loop to run the helicopter autofarm process
            spawn(runHelicopterAutofarm)
            GUI:Notification{
                Title = "Helicopter Autofarm",
                Text = "Helicopter Autofarm enabled",
                Duration = 5
            }
        else
            GUI:Notification{
                Title = "Helicopter Autofarm",
                Text = "Helicopter Autofarm disabled",
                Duration = 5
            }
        end
    end
}

-- Add a Slider called Helicopter Speed
AutofarmsTab:Slider{
    Name = "Helicopter Speed",
    Default = 50,
    Min = 1,
    Max = 1000,
    Callback = function(value)
        helicopterSpeed = value
    end
}

-- Add a notification for script information
GUI:Notification{
    Title = "Script Information",
    Text = "All scripts were made by JustVibey",
    Duration = 10
}

-- Add a credit section
GUI:Credit{
    Name = "Vibey Hub",
    Description = "JustVibey Created the script",
    Discord = "https://discord.gg/8DANGfUYgg"
}
