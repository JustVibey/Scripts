-- Get the Mercury Library
local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

-- Create the GUI
local GUI = Mercury:Create{
    Name = "Vehicle Recorder",
    Size = UDim2.fromOffset(600, 400),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/deeeity/mercury-lib"
}

-- Create the Tab
local Tab = GUI:Tab{
    Name = "Vehicle Recorder",
    Icon = "rbxassetid://8569322835"
}

-- Variables
local player = game.Players.LocalPlayer
local vehicle = workspace.Vehicles:FindFirstChild(player.Name)
local recording = {}
local isRecording = false
local playback = false
local playbackSpeed = 1 -- Default playback speed
local loopCount = 1    -- Default loop count for playback

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
            GUI:Notification{
                Title = "Recording Started",
                Text = "Recording has started successfully.",
                Duration = 3
            }
        else
            GUI:Notification{
                Title = "Warning",
                Text = "Recording is already in progress.",
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
            GUI:Notification{
                Title = "Recording Stopped",
                Text = "Recording has been stopped.",
                Duration = 3
            }
        else
            GUI:Notification{
                Title = "Error",
                Text = "No recording is currently in progress.",
                Duration = 3
            }
        end
    end
}

-- Playback Recording Button
Tab:Button{
    Name = "Playback Recording",
    Description = "Play back the loaded recording.",
    Callback = function()
        if not isRecording and #recording > 0 then
            print("Playback started")
            playback = true
            stopPlaybackFlag = false
            GUI:Notification{
                Title = "Playback Started",
                Text = "Playback has started.",
                Duration = 3
            }

            spawn(function()
                for loop = 1, loopCount do
                    if stopPlaybackFlag then break end
                    print("Loop #" .. loop)
                    local lastTime = tick() -- Store the initial playback start time
                    for i, frameData in ipairs(recording) do
                        if stopPlaybackFlag then break end
                        if vehicle and vehicle.PrimaryPart then
                            -- Set vehicle to recorded CFrame
                            vehicle:SetPrimaryPartCFrame(CFrame.new(unpack(frameData.cframe)))
                        end

                        -- Calculate delay based on playback speed (note: the delay is inversely related to the playback speed)
                        local delay = (recording[i + 1] and (recording[i + 1].time - frameData.time) or 0) / playbackSpeed
                        local elapsed = tick() - lastTime
                        -- Delay until the correct playback point for the new speed (faster playback means we wait less)
                        if elapsed < delay then
                            task.wait(delay - elapsed)
                        end
                        lastTime = tick()  -- Update lastTime for the next frame's playback timing
                    end
                    if stopPlaybackFlag then break end
                end

                playback = false
                print("Playback ended")
                GUI:Notification{
                    Title = "Playback Ended",
                    Text = "Playback has ended.",
                    Duration = 3
                }
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
    Description = "Stop the playback of the recorded vehicle movements.",
    Callback = function()
        stopPlaybackFlag = true
        print("Playback stopped.")
        GUI:Notification{
            Title = "Playback Stopped",
            Text = "The playback has been stopped.",
            Duration = 3
        }
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

-- Loop Count Textbox
Tab:Textbox{
    Name = "Set Loop Count",
    Default = "1", -- Default loop count
    Callback = function(text)
        local loops = tonumber(text)
        if loops and loops > 0 then
            loopCount = loops
            GUI:Notification{
                Title = "Success",
                Text = "Loop count updated to " .. loopCount,
                Duration = 3
            }
            print("Loop count set to:", loopCount)
        else
            GUI:Notification{
                Title = "Error",
                Text = "Invalid loop count. Enter a number greater than 0.",
                Duration = 3
            }
        end
    end
}
