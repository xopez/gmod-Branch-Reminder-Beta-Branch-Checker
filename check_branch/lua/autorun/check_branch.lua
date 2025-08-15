if SERVER then
    util.AddNetworkString("CheckClientBranch")

    local configPath = "branch_reminder_config.json"
    local defaultConfig = { interval = 300 }

    local function loadOrCreateConfig()
        local configTable

        if file.Exists(configPath, "DATA") then
            configTable = util.JSONToTable(file.Read(configPath, "DATA"))
        end

        -- Validate or create default config
        if
            not configTable
            or type(configTable.interval) ~= "number"
            or configTable.interval <= 0
        then
            configTable = table.Copy(defaultConfig)
            file.Write(configPath, util.TableToJSON(configTable, false))
            print("[BranchCheck] Config file created or reset to default values.")
        end

        return configTable
    end

    local config = loadOrCreateConfig()
    local branchReminderInterval = config.interval

    print(string.format("[BranchCheck] Reminder interval: %d seconds", branchReminderInterval))

    hook.Add("PlayerInitialSpawn", "SendServerBranch", function(ply)
        net.Start("CheckClientBranch")
        net.WriteString(BRANCH)
        net.WriteUInt(branchReminderInterval, 16) -- supports up to ~18 hours
        net.Send(ply)
    end)
else -- CLIENT
    local COLOR_WARN = Color(255, 100, 100)
    local COLOR_INFO = Color(100, 200, 255)
    local COLOR_YELLOW = Color(255, 255, 0)
    local TIMER_NAME = "BranchReminderTimer"

    local function showBranchWarning(serverBranch)
        if serverBranch == "unknown" and BRANCH ~= "unknown" then
            chat.AddText(
                COLOR_WARN,
                "[BranchCheck] Please leave the beta branch to avoid potential issues!"
            )
            return true
        elseif serverBranch ~= "unknown" and BRANCH ~= serverBranch then
            chat.AddText(
                COLOR_INFO,
                "[BranchCheck] Please switch to the server's beta: ",
                COLOR_YELLOW,
                serverBranch
            )
            return true
        end
        return false
    end

    net.Receive("CheckClientBranch", function()
        local serverBranch = net.ReadString()
        local interval = net.ReadUInt(16)

        print(
            string.format(
                "[BranchCheck] Server branch: %s, Client branch: %s",
                serverBranch,
                BRANCH
            )
        )
        print(string.format("[BranchCheck] Reminder interval: %d seconds", interval))

        timer.Remove(TIMER_NAME) -- stop any existing reminder timer

        if showBranchWarning(serverBranch) then
            timer.Create(TIMER_NAME, interval, 0, function()
                showBranchWarning(serverBranch)
            end)
        end
    end)

    hook.Add("ShutDown", "StopBranchReminderTimer", function()
        timer.Remove(TIMER_NAME)
    end)
end
