-- Autorace Tab
local AutoraceTab = GUI:Tab{
    Name = "Autorace",
    Icon = "rbxassetid://8569322835"
}

-- Autorace variables
local autoracePlaybackSpeed = 1  -- Default speed for autorace playback

-- Autorace Speed Textbox
AutoraceTab:Textbox{
    Name = "Autorace Speed",
    Description = "Adjust the speed of the playback during autorace.",
    Callback = function(text)
        local speed = tonumber(text)
        if speed and speed > 0 then
            autoracePlaybackSpeed = speed
            GUI:Notification{
                Title = "Success",
                Text = "Autorace speed set to " .. autoracePlaybackSpeed,
                Duration = 3
            }
            print("Autorace playback speed set to:", autoracePlaybackSpeed)
        else
            GUI:Notification{
                Title = "Error",
                Text = "Invalid speed. Please enter a positive number.",
                Duration = 3
            }
        end
    end
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

                -- After the loop ends, wait for 23 seconds before playing the recording
                if autoraceLoopRunning == false and trackRecording then
                    wait(23)  -- Delay for 23 seconds before playing the recording
                    print("Starting track recording playback")

                    -- Loop to replay the track 3 times
                    for loop = 1, trackPlaybackLoopCount do
                        for i, frameData in ipairs(trackRecording) do
                            if vehicle and vehicle.PrimaryPart then
                                vehicle:SetPrimaryPartCFrame(CFrame.new(unpack(frameData.cframe)))
                            end
                            if i < #trackRecording then
                                -- Adjust the playback speed based on autorace speed setting
                                local delay = ((trackRecording[i + 1].time - frameData.time) / (autoracePlaybackSpeed))
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
