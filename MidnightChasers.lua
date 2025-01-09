local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()
local GUI = Mercury:Create{
    Name = "Mercury",
    Size = UDim2.fromOffset(600, 400),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/deeeity/mercury-lib"
}
local AutoraceTab = GUI:Tab{
    Name = "Autorace",
    Icon = "rbxassetid://8569322835"
}

local function getPlayerCar(playerName)
    local carName = playerName .. "'s Car"
    return workspace:FindFirstChild(carName)
end

local function setPrimaryPart(car)
    if not car.PrimaryPart then
        local primaryPart = car:FindFirstChildWhichIsA("BasePart")
        if primaryPart then
            car.PrimaryPart = primaryPart
        end
    end
end

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

local function getPrimaryPart(vehicle)
    local primaryPart = vehicle.PrimaryPart
    if not primaryPart then
        primaryPart = vehicle:FindFirstChildWhichIsA("BasePart")
    end
    return primaryPart
end

local flySpeed = 50
local mainCarName = "2002 Holder EN6-R"

local function flyVehicleToCFrame(vehicle, targetCFrame)
    local T = getPrimaryPart(vehicle)
    if not T then return end

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
        BV.velocity = direction * flySpeed
        BG.cframe = targetCFrame
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

local function flyToCheckpoints(vehicle)
    local checkpoints = workspace.Races.Race2.Checkpoints
    for i = 2, 70 do
        local checkpoint = checkpoints:FindFirstChild(tostring(i))
        if checkpoint then
            flyVehicleToCFrame(vehicle, checkpoint.CFrame)
            wait(0.1)
        end
    end
    local finishCheckpoint = checkpoints:FindFirstChild("Finish")
    if finishCheckpoint then
        flyVehicleToCFrame(vehicle, finishCheckpoint.CFrame)
    end
end

local function executeAdditionalSteps()
    wait(2)
    game:GetService("ReplicatedStorage"):WaitForChild("DespawnCar"):FireServer()
    wait(1)
    local player = game.Players.LocalPlayer
    player.Character.HumanoidRootPart.CFrame = CFrame.new(3346, -15, 966, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    wait(3)
    local args = {mainCarName}
    game:GetService("ReplicatedStorage"):WaitForChild("SpawnCar"):FireServer(unpack(args))
    wait(3)
    game:GetService("ReplicatedStorage"):WaitForChild("SpawnCar"):FireServer(unpack(args))
    wait(3)
end

local function handleAutorace(player, targetCFrame, flyToCheckpointsFlag)
    while true do
        local car = getPlayerCar(player.Name)
        if car then
            while true do
                if teleportCar(car, targetCFrame) then
                    local countdownText = workspace.Races.Race2.QueueRegion.RaceQueue.Container.Queue.Countdown
                    if countdownText and countdownText.Text == "Starting in 0 seconds" then
                        wait(10)
                        if flyToCheckpointsFlag then
                            flyToCheckpoints(car)
                        end
                        executeAdditionalSteps()
                        break
                    end
                end
                wait(0.1)
            end
        else
            wait(1)
        end
    end
end

local function handleAltAccount(player, targetCFrame)
    while true do
        local car = getPlayerCar(player.Name)
        if car then
            while true do
                if teleportCar(car, targetCFrame) then
                    local countdownText = workspace.Races.Race2.QueueRegion.RaceQueue.Container.Queue.Countdown
                    if countdownText and countdownText.Text == "Starting in 0 seconds" then
                        GUI:Notification{
                            Title = "Teleport Loop Stopped",
                            Text = "Teleport loop has been stopped.",
                            Duration = 3
                        }
                        wait(10)
                        game:GetService("ReplicatedStorage"):WaitForChild("DespawnCar"):FireServer()
                        while true do
                            local playersText = workspace.Races.Race2.QueueRegion.RaceQueue.Container.Queue.Players
                            if playersText and playersText.Text == "Players Waiting (1/4)" then
                                break
                            end
                            wait(0.1)
                        end
                        local args = {mainCarName}
                        game:GetService("ReplicatedStorage"):WaitForChild("SpawnCar"):FireServer(unpack(args))
                        break
                    end
                end
                wait(0.1)
            end
        else
            wait(1)
        end
    end
end

local autoraceEnabled = false
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

AutoraceTab:Slider{
    Name = "Fly Speed",
    Description = "Adjust the fly speed (1-1000)",
    Default = 50,
    Min = 1,
    Max = 1000,
    Callback = function(value)
        flySpeed = value
    end
}

AutoraceTab:Textbox{
    Name = "Main Car Name",
    Description = "Enter your main car name",
    Default = "2002 Holder EN6-R",
    Callback = function(value)
        mainCarName = value
    end
}

local antiAFKEnabled = false
AutoraceTab:Button{
    Name = "Anti AFK",
    Description = nil,
    Callback = function()
        if antiAFKEnabled then
            GUI:Notification{
                Title = "Anti AFK Disabled",
                Text = "Anti AFK has been disabled.",
                Duration = 3
            }
            antiAFKEnabled = false
        else
            GUI:Notification{
                Title = "Anti AFK Enabled",
                Text = "Anti AFK has been enabled.",
                Duration = 3
            }
            antiAFKEnabled = true
            local GC = getconnections or get_signal_cons
            if GC then
                for i,v in pairs(GC(game.Players.LocalPlayer.Idled)) do
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
    end
}

GUI:Notification{
    Title = "Script Information",
    Text = "All scripts were made by JustVibey",
    Duration = 5
}
local discordLink = "https://discord.com/invite/CewxE4y2qv"
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Discord Invite",
    Text = "Join the Discord server: " .. discordLink,
    Duration = 10
})
