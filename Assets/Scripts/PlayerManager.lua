--!Type(Module) -- Module type declaration, typically used in specific game engines or frameworks.

-- Create events for different types of requests, these will be used for communication between client and server.
local getStatsRequest = Event.new("GetStatsRequest")
local saveStatsRequest = Event.new("SaveStatsRequest")
local incrementStatRequest = Event.new("IncrementStatRequest")
local setRoleRequest = Event.new("SetRoleRequest")

local beeObjectManager = require("BeeObjectManager")

-- Variable to hold the player's statistics GUI component
local playerStatGui = nil

-- Table to keep track of players and their associated stats
players = {}

-- Table to manage the pool of plots (0 to 7)
local plotPool = {0, 1, 2, 3, 4, 5, 6, 7}

-- Table to track which plot is assigned to each player
local playerPlots = {}

-- Track money accumulation speeds per player
local playerMoneyEarnRates = {}

local playerTimers = {}

-- List of predefined spawn locations for each plot (0 to 7)
local spawnLocations = {
    {x = -13, y = 0, z = -21}, -- Spawn location for plot 0
    {x = -13, y = 0, z = -7.5}, -- Spawn location for plot 1
    {x = -13, y = 0, z = 7.5}, -- SpaFwn location for plot 2
    {x = -13, y = 0, z = 21}, -- Spawn location for plot 3
    {x = 13, y = 0, z = -21}, -- Spawn location for plot 4
    {x = 13, y = 0, z = -7.5}, -- Spawn location for plot 5
    {x = 13, y = 0, z = 7.5}, -- Spawn location for plot 6
    {x = 13, y = 0, z = 21}  -- Spawn location for plot 7
}

local plotAssignedEvent = Event.new("PlotAssigned")

giveBeeRequest = Event.new("GiveBee")

local restartTimerRequest = Event.new("RestartTimer")

local MoneyTimer = nil

-- Function to spawn a player at their assigned plot's spawn location
local function spawnAtPlot(player, plot)
    local spawnLocation = spawnLocations[plot.value + 1] -- Plot numbers are 0-7, but Lua tables are 1-based
    if spawnLocation then
        -- Set player's position to the spawn location
        player.character:Teleport(Vector3.new(spawnLocation.x, spawnLocation.y, spawnLocation.z))
        print(player.name .. " has been spawned at plot " .. plot.value .. " location.")
    else
        print("ERROR: No valid spawn location for plot " .. plot.value .. " for player " .. player.name)
    end
end

-- Function to assign a plot to a player
local function assignPlot(playerInfo)
    if #plotPool > 0 then
        -- Take a plot from the pool and assign it to the player
        local plot = table.remove(plotPool, 1)
        playerPlots[playerInfo.player.id] = plot
        playerInfo.Plot.value = plot
        print(playerInfo.player.name .. " has been assigned plot " .. playerInfo.Plot.value)
    else
        -- If no plots are available, print an error
        print("ERROR: No available plots for player " .. player.name)
    end
end

-- Function to return a plot to the pool when a player leaves
local function returnPlot(id)

    plot = playerPlots[id]

    for id, plot in pairs(playerPlots) do
        print("plot " .. plot .. " has id " .. id)
    end

    print("Id to be returned - " .. id)

    if plot ~= nil then
        -- Return the player's plot to the pool
        table.insert(plotPool, plot)
        print("Plot " .. plot .. " has been returned to the pool.")
        playerPlots[id] = nil -- Clear the player's assigned plot
    else
        print("Error - Player had no plot.")
    end
end

local function LookupBeeEarnRate(Bee)
    if Bee == "Common Bee" then
        return 6
    elseif Bee == "Stone Bee" then
        return 8
    elseif Bee == "Forest Bee" then
        return 8
    elseif Bee == "Aquatic Bee" then
        return 14
    elseif Bee == "Giant Bee" then
        return 16
    elseif Bee == "Silver Bee" then
        return 22
    elseif Bee == "Muddy Bee" then
        return 16
    elseif Bee == "Frigid Bee" then
        return 18
    elseif Bee == "Steel Bee" then
        return 18
    elseif Bee == "Magma Bee" then
        return 26
    elseif Bee == "Ghostly Bee" then
        return 28
    elseif Bee == "Golden Bee" then
        return 44
    else
        return 0
        -- todo - add other bees
    end
end

-- Function to remove all items from a player's inventory
function RemoveAllPlayerItems(player)
    -- First, retrieve all the player's items
    Inventory.GetPlayerItems(player, 10, nil, function(items, newCursorId, errorCode)
        -- Loop through each item and queue it for removal
        for _, item in ipairs(items) do
            local transaction = InventoryTransaction.new()
            transaction:TakePlayer(player, item.id, item.amount)
            Inventory.CommitTransaction(transaction)
        end

        print("All items removed from player: " .. player.name)
    end)
end

local function RecalculatePlayerEarnRate(player)
    Inventory.GetPlayerItems(player, 10, "", function(items, newCursorId, errorCode)
        local rate = 0
        for i, item in ipairs(items) do
            -- print("checking item " .. item.id)
            if string.find(item.id, "Bee") then
                rate = rate + LookupBeeEarnRate(item.id) * item.amount
            end
        end

        playerMoneyEarnRates[player] = rate
        print("New earn rate for " .. player.name .. " is " .. rate)
        
        restartTimerRequest:FireClient(player, rate)
    end)
end

-- Function to track players joining and leaving the game
local function TrackPlayers(game, characterCallback)
    -- Connect to the event when a player joins the game
    scene.PlayerJoined:Connect(function(scene, player)
        -- Initialize player's stats and store them in the players table
        players[player] = {
            player = player,
            Plot = IntValue.new("Plot" .. tostring(player.id), -1),
            Role = IntValue.new("Role" .. tostring(player.id), -1), -- Role: 1 = Employee, 0 = Customer, -1 = Undefined
            Cash = IntValue.new("Cash" .. tostring(player.id), 100), -- Initial cash value
            WorkXP = IntValue.new("WorkXP" .. tostring(player.id), 0), -- Initial work experience
            CustXP = IntValue.new("CustXp" .. tostring(player.id), 0) -- Initial customer experience
        }
        
        if client == nil then
            RemoveAllPlayerItems(player)

            beeObjectManager.SpawnAllBeesForPlayer(player)
            Inventory.GetPlayerItems(player, 10, "", function(items, newCursorId, errorCode)
                for i, item in ipairs(items) do
                    if string.find(item.id, "Bee") then
                        for n = 1, item.amount do
                            beeObjectManager.SpawnBee(player, item.id, spawnLocations[players[player].Plot.value + 1])
                        end
                    end
                end
            end)
        end

        if client == nil then
            playerTimers[player] = nil
            RecalculatePlayerEarnRate(player)
        end

        -- Connect to the event when the player's character changes (e.g., respawn)
        player.CharacterChanged:Connect(function(player, character)
            local playerinfo = players[player]
            -- If character is nil, do nothing
            if (character == nil) then
                return
            end 

            -- If a character callback function is provided, call it with the player information
            if characterCallback then
                characterCallback(playerinfo)
            end
        end)
    end)

    -- Connect to the event when a player leaves the game
    game.PlayerDisconnected:Connect(function(player)
        -- Remove the player from the players table
        print(player.name .. " with id " .. player.id .. " is leaving")
        if client == nil then
            beeObjectManager.RemoveAllPlayerBees(player)
            returnPlot(player.id)
        end
        players[player] = nil
    end)
end

-- Function to find the key with the maximum value in a table
local function findMaxKey(tbl)
    local maxKey = nil
    local maxValue = -math.huge -- Start with negative infinity as initial maximum value

    -- Iterate through the table to find the key with the maximum value
    for key, value in pairs(tbl) do
        if value > maxValue then
            maxValue = value
            maxKey = key
        elseif value == maxValue then
            maxValue = value
            maxKey = nil -- If there is a tie, set maxKey to nil
        end
    end

    return maxKey
end

--[[

    Client-side functionality

--]]

-- Function to change the player's role by sending a request to the server
function ChangeRole()
    setRoleRequest:FireServer()
end

-- Function to get the local player's cash
function GetPlayerCash()
    return players[client.localPlayer].Cash.value
end

-- Function to initialize the client-side logic
function self:ClientAwake()
    -- Get the PlayerStatGui component from the game object to interact with the player's stat UI
    playerStatGui = self.gameObject:GetComponent(PlayerStatGui)

    -- Function to handle character instantiation for a player
    function OnCharacterInstantiate(playerinfo)
        local player = playerinfo.player
        local character = player.character
        
       spawnAtPlot(player, playerinfo.Plot)

        -- Handle changes in the player's role
        playerinfo.Role.Changed:Connect(function(currentRole, oldVal)
            if player == client.localPlayer then
                local roleText = ""
                if currentRole == 0 then 
                    roleText = "Customer"
                    playerStatGui.SetXpUI(playerinfo.CustXP.value)
                elseif currentRole == 1 then 
                    roleText = "Employee" 
                    playerStatGui.SetXpUI(playerinfo.WorkXP.value)
                end
                -- Update the local UI to reflect the new role
                playerStatGui.SetRoleUI(roleText)
                -- Request the server to save the updated stats
                saveStatsRequest:FireServer()
            end
        end)

        -- Handle changes in the player's cash
        playerinfo.Cash.Changed:Connect(function(currentCash, oldVal)
            if player == client.localPlayer then
                -- Update the local UI to reflect the new cash value
                playerStatGui.SetCashUI(currentCash)
            end
        end)

        -- Handle changes in the player's work experience
        playerinfo.WorkXP.Changed:Connect(function(currentXP, oldVal)
            if player == client.localPlayer and playerinfo.Role.value == 1 then
                -- Update the local UI to reflect the new work experience value
                playerStatGui.SetXpUI(currentXP)
            end
        end)

        restartTimerRequest:Connect(function(rate)
            if MoneyTimer ~= nil then
                MoneyTimer:Stop()
            end
            MoneyTimer = Timer.new(60/rate, function() IncrementStat("Cash", 1) end, true)
        end)

        -- Handle changes in the player's customer experience
        playerinfo.CustXP.Changed:Connect(function(currentXP, oldVal)
            if player == client.localPlayer and playerinfo.Role.value == 0 then
                -- Update the local UI to reflect the new customer experience value
                playerStatGui.SetXpUI(currentXP)
            end
        end)
    end

    -- Function to increment a specific stat by a given value
    function IncrementStat(stat, value)
        incrementStatRequest:FireServer(stat, value)
    end

    -- Request the server to send the player's stats
    getStatsRequest:FireServer()

    -- Track players joining and leaving, and handle character instantiation
    TrackPlayers(client, OnCharacterInstantiate)
end

function GiveBee(player, name)
    giveBeeRequest:FireServer(player, value)
end

--[[

    Server-side functionality

--]]

-- Function to save a player's stats to persistent storage
local function SaveStats(player)
    -- Create a table to store the player's current stats
    local stats = {Role = 0, Cash = 0, WorkXP = 0, CustXP = 0}
    stats.Role = players[player].Role.value
    stats.Cash = players[player].Cash.value
    stats.WorkXP = players[player].WorkXP.value
    stats.CustXP = players[player].CustXP.value

    -- Save the stats to storage and handle any errors
    Storage.SetPlayerValue(player, "PlayerStats", stats, function(errorCode)
        --print(player.name .. " Stats Saved")
    end)
end

-- Function to initialize the server-side logic
function self:ServerAwake()
    -- Track players joining and leaving the game
    TrackPlayers(server) 

    scene.PlayerJoined:Connect(function(scene, player)
        assignPlot(players[player])
    end)

    -- Fetch a player's stats from storage when they join
    getStatsRequest:Connect(function(player)
        Storage.GetPlayerValue(player, "PlayerStats", function(stats)
            -- If no existing stats are found, create default stats
            if stats == nil then 
                stats = {Role = 1, Cash = 100, WorkXP = 0, CustXP = 0}
                Storage.SetPlayerValue(player, "PlayerStats", stats) 
            end

            -- Update the player's current networked stats from storage
            players[player].Role.value = stats.Role
            players[player].Cash.value = stats.Cash
            players[player].WorkXP.value = stats.WorkXP
            players[player].CustXP.value = stats.CustXP

            --[[
            -- Uncomment the following lines to print the player's stats to the console for debugging
            for stat, value in pairs(stats) do
                print(player.name .. "'s " .. stat .. ": " .. tostring(value))
            end
            --]]
        end)
    end)

    -- Save the player's stats when requested by the client
    saveStatsRequest:Connect(function(player)
        SaveStats(player)
    end)

    -- Increment a player's stat when requested by the client
    incrementStatRequest:Connect(function(player, stat, value)
         --Override the Role Stat of the player to 'value' with =
         if stat == "Role" then players[player].Role.value = value end

         --Increment the  Cash / WorkXP / CustXp Stat of the player by 'value' with +=
         if stat == "Cash" then players[player].Cash.value += value end
         if stat == "WorkXP" then players[player].WorkXP.value += value end
         if stat == "CustXP" then players[player].CustXP.value += value end
         -- Save the updated stats to storage
         SaveStats(player)
    end)

    giveBeeRequest:Connect(function(player, name)

        print(player.name .. " recieved a " .. name .. "!")

        local transaction = InventoryTransaction.new():GivePlayer(player, name, 1)
        Inventory.CommitTransaction(transaction)
    
        beeObjectManager.SpawnBee(player, name, spawnLocations[players[player].Plot.value + 1])

        Inventory.GetPlayerItems(player, 10, "", function(items, newCursorId, errorCode)
            -- Your logic for handling the retrieved items goes here
            print("Player " .. player.name .. " has:")
            for i, item in ipairs(items) do
                -- Print the name of each item
                print("Item " .. i .. ": " .. item.id .. " | Quantity: " .. item.amount)
            end
        end)

        RecalculatePlayerEarnRate(player)
    end)

    -- Change a player's role when requested by the client
    setRoleRequest:Connect(function(player)
        -- Retrieve the current role of the player from the players table.
        local currentRole = players[player].Role.value

        if currentRole == 0 then -- Check if the current role is Customer (0).
            currentRole = 1  -- Change role to Employee (1).

        elseif currentRole == 1 then -- Check if the current role is Employee (1).
            currentRole = 0  -- Change role to Customer (0).

        else -- If the current role is neither Customer (0) nor Employee (1), print an error message.
            print("ERROR: player outside Role bounds")
            return  -- Exit the function to prevent further execution.
        end
        -- Update the player's role
        players[player].Role.value = currentRole
    end)
end