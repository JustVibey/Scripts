-- Load the Mercury library
local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

-- Create the GUI
local GUI = Mercury:Create{
    Name = "Mercury",
    Size = UDim2.fromOffset(600, 400),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/deeeity/mercury-lib"
}

-- Create the "Autorace" tab
local AutoraceTab = GUI:Tab{
    Name = "Autorace",
    Icon = "rbxassetid://8569322835"  -- You can change the icon if needed
}

-- Function to get the player's car
local function getPlayerCar(playerName)
    local carName = playerName .. "'s Car"
    return workspace:FindFirstChild(carName)
end

-- Function to set the primary part of the car model
local function setPrimaryPart(car)
    if not car.PrimaryPart then
        local primaryPart = car:FindFirstChildWhichIsA("BasePart")
        if primaryPart then
            car.PrimaryPart = primaryPart
            print("Primary part set to: ", primaryPart.Name)  -- Debug statement
        else
            print("No BasePart found in car model")  -- Debug statement
        end
    end
end

-- Function to teleport the car
local function teleportCar(car, cframe)
    if car then
        setPrimaryPart(car)
        if car.PrimaryPart then
            car:SetPrimaryPartCFrame(cframe)
            print("Teleported car to: ", cframe)  -- Debug statement
            return true
        else
            print("Failed to set PrimaryPart")  -- Debug statement
        end
    else
        print("Car not found")  -- Debug statement
    end
    return false
end

-- Function to get the primary part of the vehicle
local function getPrimaryPart(vehicle)
    local primaryPart = vehicle.PrimaryPart
    if not primaryPart then
        primaryPart = vehicle:FindFirstChildWhichIsA("BasePart")
    end
    return primaryPart
end

-- Variable to store the fly speed
local flySpeed = 50
local mainCarName = "2002 Holder EN6-R" -- Default car name

-- Function to fly the vehicle to the target CFrame
local function flyVehicleToCFrame(vehicle, targetCFrame)
    local T = getPrimaryPart(vehicle)
    if not T then
        warn("Primary part not found for the vehicle.")
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

        BV.velocity = direction * flySpeed -- Use the flySpeed variable
        BG.cframe = targetCFrame

        if distance < 10 then -- Adjust the threshold as needed for leeway
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

-- Function to fly the vehicle to the checkpoints
local function flyToCheckpoints(vehicle)
    local checkpoints = workspace.Races.Race2.Checkpoints
    for i = 2, 70 do
        local checkpoint = checkpoints:FindFirstChild(tostring(i))
        if checkpoint then
            flyVehicleToCFrame(vehicle, checkpoint.CFrame)
            wait(0.1)  -- Reduced wait time to 0.1 seconds at each checkpoint for smoother transitions
        end
    end
    local finishCheckpoint = checkpoints:FindFirstChild("Finish")
    if finishCheckpoint then
        flyVehicleToCFrame(vehicle, finishCheckpoint.CFrame)
    end
end

-- Function to execute additional steps after finishing checkpoints
local function executeAdditionalSteps()
    wait(2) -- Wait 2 seconds

    game:GetService("ReplicatedStorage"):WaitForChild("DespawnCar"):FireServer()

    wait(1) -- Wait 1 second

    local player = game.Players.LocalPlayer
    player.Character.HumanoidRootPart.CFrame = CFrame.new(3346, -15, 966, 1, 0, 0, 0, 1, 0, 0, 0, 1)

    wait(3) -- Wait 3 seconds

    local args = {
        [1] = mainCarName
    }
    game:GetService("ReplicatedStorage"):WaitForChild("SpawnCar"):FireServer(unpack(args))

    wait(3) -- Wait 3 seconds

    game:GetService("ReplicatedStorage"):WaitForChild("SpawnCar"):FireServer(unpack(args))

    wait(3) -- Wait 3 seconds
end

-- Function to handle the autorace process
local function handleAutorace(player, targetCFrame, flyToCheckpointsFlag)
    while true do
        local car = getPlayerCar(player.Name)
        if car then
            print("Car found: ", car.Name)  -- Debug statement

            -- Continuously teleport the car to the starting position until the countdown reaches "Starting in 0 seconds"
            while true do
                if teleportCar(car, targetCFrame) then
                    local countdownText = workspace.Races.Race2.QueueRegion.RaceQueue.Container.Queue.Countdown
                    if countdownText and countdownText.Text == "Starting in 0 seconds" then
                        print("Countdown reached: Stopping teleport loop")  -- Debug statement
                        wait(10)  -- Wait 10 seconds
                        if flyToCheckpointsFlag then
                            flyToCheckpoints(car)
                        end
                        executeAdditionalSteps()
                        break
                    end
                end
                wait(0.1)  -- Teleport loop delay of 0.1 seconds
            end
        else
            print("Car not found for player: ", player.Name)  -- Debug statement
            wait(1)  -- Wait 1 second before retrying
        end
    end
end

-- Function to handle the alt account process
local function handleAltAccount(player, targetCFrame)
    while true do
        local car = getPlayerCar(player.Name)
        if car then
            print("Car found: ", car.Name)  -- Debug statement

            -- Continuously teleport the car to the starting position until the countdown reaches "Starting in 0 seconds"
            while true do
                if teleportCar(car, targetCFrame) then
                    local countdownText = workspace.Races.Race2.QueueRegion.RaceQueue.Container.Queue.Countdown
                    if countdownText and countdownText.Text == "Starting in 0 seconds" then
                        print("Countdown reached: Stopping teleport loop")  -- Debug statement
                        GUI:Notification{
                            Title = "Teleport Loop Stopped",
                            Text = "Teleport loop has been stopped.",
                            Duration = 3
                        }
                        wait(10)  -- Wait 10 seconds

                        -- Execute additional steps
                        game:GetService("ReplicatedStorage"):WaitForChild("DespawnCar"):FireServer()

                        -- Wait until the text changes to "Players Waiting (1/4)"
                        while true do
                            local playersText = workspace.Races.Race2.QueueRegion.RaceQueue.Container.Queue.Players
                            if playersText and playersText.Text == "Players Waiting (1/4)" then
                                break
                            end
                            wait(0.1) -- Check delay of 0.1 seconds
                        end

                        -- Spawn the car
                        local args = {
                            [1] = mainCarName
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("SpawnCar"):FireServer(unpack(args))

                        break
                    end
                end
                wait(0.1)  -- Teleport loop delay of 0.1 seconds
            end
        else
            print("Car not found for player: ", player.Name)  -- Debug statement
            wait(1)  -- Wait 1 second before retrying
        end
    end
end

-- Add a checkbox called "Enable Autorace"
local autoraceEnabled = false
local teleportNotificationShown = false

AutoraceTab:Toggle{
    Name = "Enable Autorace",
    StartingState = false,
    Description = nil,
    Callback = function(state)
        autoraceEnabled = state
        if autoraceEnabled then
            GUI:Notification{
                Title = "Autorace Enabled",
                Text = "Autorace has been enabled.",
                Duration = 3
            }
            local player = game.Players.LocalPlayer
            local targetCFrame = CFrame.new(-8728, 27, 1997, 1, 0, 0, 0, 1, 0, 0, 0, 1)
            spawn(function()
                handleAutorace(player, targetCFrame, true)
            end)
        else
            GUI:Notification{
                Title = "Autorace Disabled",
                Text = "Autorace has been disabled.",
                Duration = 3
            }
        end
    end
}

-- Add a checkbox called "Alt Account"
local altAccountEnabled = false

AutoraceTab:Toggle{
    Name = "Alt Account",
    StartingState = false,
    Description = nil,
    Callback = function(state)
        altAccountEnabled = state
        if altAccountEnabled then
            GUI:Notification{
                Title = "Alt Account Enabled",
                Text = "Alt Account has been enabled.",
                Duration = 3
            }
            local player = game.Players.LocalPlayer
            local targetCFrame = CFrame.new(-8728, 27, 1997, 1, 0, 0, 0, 1, 0, 0, 0, 1)
            spawn(function()
                handleAltAccount(player, targetCFrame)
            end)
        else
            GUI:Notification{
                Title = "Alt Account Disabled",
                Text = "Alt Account has been disabled.",
                Duration = 3
            }
        end
    end
}

-- Add a slider to adjust the fly speed
AutoraceTab:Slider{
    Name = "Fly Speed",
    Description = "Adjust the fly speed (1-1000)",
    Default = 50,
    Min = 1,
    Max = 1000,
    Callback = function(value)
        flySpeed = value
        print("Fly Speed: ", flySpeed)  -- Debug statement
    end
}

-- Add a text box to enter the main car name
AutoraceTab:Textbox{
    Name = "Main Car Name",
    Description = "Enter your main car name",
    Default = "2002 Holder EN6-R",
    Callback = function(value)
        mainCarName = value
        print("Main Car Name: ", mainCarName)  -- Debug statement
    end
}

-- Initial notification and clipboard copy
GUI:Notification{
    Title = "Script Information",
    Text = "All scripts were made by JustVibey",
    Duration = 5
}

local discordLink = "https://discord.com/invite/CewxE4y2qv"
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Discord Invite",
    Text = "Discord invite link copied to clipboard!",
    Duration = 5
})

local player = game.Players.LocalPlayer
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Clipboard",
    Text = "Link copied to clipboard!",
    Duration = 5
})

local httpService = game:GetService("HttpService")
httpService:RequestAsync({
    Url = "http://127.0.0.1:6463/rpc?v=1",
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json",
        ["Origin"] = "https://developer.roblox.com"
    },
    Body = httpService:JSONEncode({
        cmd = "setclipboard",
        text = discordLink
    })
})
