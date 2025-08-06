if SERVER then
    util.AddNetworkString("CheckClientBranch")
    
    local configPath = "branch_reminder_config.json"
    local defaultConfig = {
        interval = 300
    }

    local branchReminderInterval = defaultConfig.interval

    --  Load or create JSON
    local function loadOrCreateConfig()
        if not file.Exists(configPath, "DATA") then
            local json = util.TableToJSON(defaultConfig, false) -- minified
            file.Write(configPath, json)
            print("[BranchCheck] Config file created with default values.")
            return defaultConfig
        end

        local json = file.Read(configPath, "DATA")
        local configTable = util.JSONToTable(json)

        if not configTable or type(configTable.interval) ~= "number" or configTable.interval <= 0 then
            print("[BranchCheck] Invalid config content. Using default value.")
            return defaultConfig
        end

        return configTable
    end

    -- Load configuration directly during loading
    local config = loadOrCreateConfig()
    branchReminderInterval = config.interval
    print("[BranchCheck] Reminder-Interval: " .. branchReminderInterval .. " seconds")

    hook.Add("PlayerInitialSpawn", "SendServerBranch", function(ply)
        net.Start("CheckClientBranch")
        net.WriteString(BRANCH)
        net.WriteUInt(branchReminderInterval, 16) -- Enough for values up to 65535 seconds (~18 hours)
        net.Send(ply)
    end)

else -- CLIENT
    local function showBranchWarning(serverBranch)
        if serverBranch == "unknown" then
            if BRANCH ~= "unknown" then
                chat.AddText(Color(255, 100, 100), "[BranchCheck] Please leave the beta branch to avoid issues!")
                return true
            end
        else
            if BRANCH ~= serverBranch then
                chat.AddText(Color(100, 200, 255), "[BranchCheck] Please switch to the server's beta branch: ", Color(255, 255, 0), serverBranch)
                return true
            end
        end
        return false
    end

    local branchCheckTimerName = "BranchReminderTimer"

    net.Receive("CheckClientBranch", function()
        local serverBranch = net.ReadString()
        local interval = net.ReadUInt(16)

        print("[BranchCheck] Server Branch: " .. serverBranch .. ", Client Branch: " .. BRANCH)
        print("[BranchCheck] Reminder interval: " .. interval .. " seconds")

        if showBranchWarning(serverBranch) then
            -- Start repeat timer with received interval
            timer.Create(branchCheckTimerName, interval, 0, function()
                showBranchWarning(serverBranch)
            end)
        end
    end)

    hook.Add("ShutDown", "StopBranchReminderTimer", function()
        timer.Remove(branchCheckTimerName)
    end)
end
