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
