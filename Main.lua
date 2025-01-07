-- Get the Mercury Library
local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

-- Create the GUI
local GUI = Mercury:Create{
    Name = "Vehicle Recorder",
    Size = UDim2.fromOffset(600, 400),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/deeeity/mercury-lib"
}

-- Create the "Vehicle Recorder" Tab
local Tab = GUI:Tab{
    Name = "Vehicle Recorder",
    Icon = "rbxassetid://8569322835"
}

-- Variables for Vehicle and Recording
local player = game.Players.LocalPlayer
local vehicle = workspace.Vehicles:FindFirstChild(player.Name)
local recording = {}
local isRecording = false
local playback = false
local playbackSpeed = 1
local loopCount = 1
local stopPlaybackFlag = false
local autoraceLoop = nil  -- Store the autorace loop for stopping later
local trackRecording = nil  -- Store the recording data for playback
local trackPlaybackLoopCount = 3 -- Loop track recording 3 times

-- Start Recording Button
Tab:Button{
    Name = "Start Recording",
    Description = "Begin recording your vehicle movements.",
    Callback = function()
        if not isRecording then
            recording = {}
            isRecording = true
            playback = false
            print("Recording started")

            spawn(function()
                while isRecording do
                    if vehicle and vehicle.PrimaryPart then
                        table.insert(recording, {
                            cframe = {vehicle.PrimaryPart.CFrame:components()},
                            time = tick()
                        })
                    end
                    task.wait(0) -- High-frequency recording
                end
            end)
        else
            GUI:Notification{
                Title = "Warning",
                Text = "Recording already in progress.",
                Duration = 3
            }
        end
    end
}

-- Stop Recording Button
Tab:Button{
    Name = "Stop Recording",
    Description = "Stop recording your vehicle movements.",
    Callback = function()
        if isRecording then
            isRecording = false
            print("Recording stopped")
        else
            GUI:Notification{
                Title = "Error",
                Text = "No recording is currently in progress.",
                Duration = 3
            }
        end
    end
}

-- Save Recording to Clipboard Button
Tab:Button{
    Name = "Save Recording",
    Description = "Save the recording data to your clipboard.",
    Callback = function()
        if #recording > 0 then
            local jsonData = game:GetService("HttpService"):JSONEncode(recording)
            setclipboard(jsonData)
            print("Recording saved to clipboard.")
            GUI:Notification{
                Title = "Success",
                Text = "Recording saved to clipboard.",
                Duration = 3
            }
        else
            GUI:Notification{
                Title = "Error",
                Text = "No recording data to save.",
                Duration = 3
            }
        end
    end
}

-- Paste Recording Textbox
Tab:Textbox{
    Name = "Paste Recording",
    Callback = function(text)
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(text)
        end)

        if success and type(data) == "table" then
            recording = data
            GUI:Notification{
                Title = "Success",
                Text = "Recording data loaded successfully.",
                Duration = 3
            }
            print("Recording data loaded.")
        else
            GUI:Notification{
                Title = "Error",
                Text = "Invalid recording data. Ensure it's in JSON format.",
                Duration = 3
            }
        end
    end
}

-- Playback Speed Textbox
Tab:Textbox{
    Name = "Set Playback Speed",
    Callback = function(text)
        local speed = tonumber(text)
        if speed and speed > 0 then
            playbackSpeed = speed
            GUI:Notification{
                Title = "Success",
                Text = "Playback speed updated to " .. playbackSpeed,
                Duration = 3
            }
            print("Playback speed set to:", playbackSpeed)
        else
            GUI:Notification{
                Title = "Error",
                Text = "Invalid playback speed. Enter a number greater than 0.",
                Duration = 3
            }
        end
    end
}

-- Playback Button
Tab:Button{
    Name = "Playback Recording",
    Description = "Play back the loaded recording.",
    Callback = function()
        if not isRecording and #recording > 0 then
            print("Playback started")
            playback = true

            spawn(function()
                for i, frameData in ipairs(recording) do
                    if not playback then break end
                    if vehicle and vehicle.PrimaryPart then
                        vehicle:SetPrimaryPartCFrame(CFrame.new(unpack(frameData.cframe)))
                    end
                    if i < #recording then
                        local delay = ((recording[i + 1].time - frameData.time) / playbackSpeed)
                        if delay > 0 then task.wait(delay) end
                    end
                end

                playback = false
                print("Playback ended")
            end)
        else
            GUI:Notification{
                Title = "Error",
                Text = "No recording available for playback.",
                Duration = 3
            }
        end
    end
}

-- Stop Playback Button
Tab:Button{
    Name = "Stop Playback",
    Description = "Stop the current playback.",
    Callback = function()
        if playback then
            playback = false
            stopPlaybackFlag = true
            print("Playback stopped.")
            GUI:Notification{
                Title = "Success",
                Text = "Playback stopped.",
                Duration = 3
            }
        else
            GUI:Notification{
                Title = "Error",
                Text = "No playback in progress.",
                Duration = 3
            }
        end
    end
}

-- Loop Count Textbox
Tab:Textbox{
    Name = "Loop Count for Playback",
    Callback = function(text)
        local loop = tonumber(text)
        if loop and loop > 0 then
            loopCount = loop
            GUI:Notification{
                Title = "Success",
                Text = "Playback loop count set to " .. loopCount,
                Duration = 3
            }
            print("Playback loop count set to:", loopCount)
        else
            GUI:Notification{
                Title = "Error",
                Text = "Invalid loop count. Enter a number greater than 0.",
                Duration = 3
            }
        end
    end
}

-- New "Autorace" Tab
local AutoraceTab = GUI:Tab{
    Name = "Autorace",
    Icon = "rbxassetid://8569322835"
}

-- Enable Autorace Checkbox
local autoraceLoopRunning = false  -- Flag to track autorace loop status
AutoraceTab:Toggle{
    Name = "Enable Autorace",
    StartingState = false, -- Default state is disabled
    Description = "Autorace Sandy Shores",
    Callback = function(state)
        if state then
            -- If enabled, start autorace loop
            print("Autorace enabled - Sandy Shores")
            autoraceLoopRunning = true
            spawn(function()
                while autoraceLoopRunning do
                    if vehicle then
                        -- Teleport the vehicle to the updated CFrame
                        local targetCFrame = CFrame.new(32, 15, -2335, 1, 0, 0, 0, 1, 0, 0, 0, 1)
                        vehicle:SetPrimaryPartCFrame(targetCFrame)
                    end

                    -- Check if "Race is starting.." condition is met
                    local raceState = game:GetService("Players").LocalPlayer.PlayerGui["RacePadInfo (SandyShores)"].Container.Main.Background.Footer.StateBorder.State.State
                    if raceState and raceState.Text == "Race is starting.." then
                        print("Race is starting, stopping autorace.")
                        autoraceLoopRunning = false
                        break
                    end
                    -- Use a delay of 0.1 between teleportations
                    task.wait(0.1)
                end

                -- After the loop ends, wait for 30 seconds before playing the recording
                if autoraceLoopRunning == false and trackRecording then
                    wait(30)  -- Delay for 30 seconds before playing the recording
                    print("Starting track recording playback")

                    for loop = 1, trackPlaybackLoopCount do
                        -- Loop playback 3 times
                        for i, frameData in ipairs(trackRecording) do
                            if vehicle and vehicle.PrimaryPart then
                                vehicle:SetPrimaryPartCFrame(CFrame.new(unpack(frameData.cframe)))
                            end
                            if i < #trackRecording then
                                local delay = ((trackRecording[i + 1].time - frameData.time) / playbackSpeed)
                                if delay > 0 then task.wait(delay) end
                            end
                        end
                    end
                    print("Track recording playback finished")
                end
            end)
        else
            -- If unchecked, stop the autorace loop and stop playback
            autoraceLoopRunning = false
            playback = false  -- Stop the recording playback if autorace is disabled
            print("Autorace disabled, playback stopped.")
        end
    end
}

-- Track Recording Textbox for Autorace Playback
AutoraceTab:Textbox{
    Name = "Track Recording",
    Callback = function(text)
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(text)
        end)

        if success and type(data) == "table" then
            trackRecording = data
            GUI:Notification{
                Title = "Success",
                Text = "Track recording loaded successfully.",
                Duration = 3
            }
            print("Track recording data loaded.")
        else
            GUI:Notification{
                Title = "Error",
                Text = "Invalid track recording data. Ensure it's in JSON format.",
                Duration = 3
            }
        end
    end
}
