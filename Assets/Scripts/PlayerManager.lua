--!Type(Module) -- Module type declaration, typically used in specific game engines or frameworks.

-- Create events for different types of requests, these will be used for communication between client and server.
getStatsRequest = Event.new("GetStatsRequest")
local saveStatsRequest = Event.new("SaveStatsRequest")
local incrementStatRequest = Event.new("IncrementStatRequest")
local setBeeAdultRequest = Event.new("SetBeeAdultRequest")
local updateBeeAgeRequest = Event.new("UpdateBeeAgeRequest")

local ApiaryManager = require("ApiaryManager")
local beeObjectManager = require("BeeObjectManager")
local wildBeeManager = require("WildBeeManager")

-- Variable to hold the player's statistics GUI component
local playerStatGui = nil

-- Table to keep track of players and their associated stats
players = {}

onlinePlayers = {} -- strictly online players only

-- Table to hold players' bee storage in memory
local playerBeeStorage = {}

-- Track money accumulation speeds per player
local playerMoneyEarnRates = {}

-- Table to hold players' bee species in memory
local playerSeenBeeSpecies = {}

-- Table for who has active honey doubler (server)
local playerHasHoneyDoubler = {}

local playerTimers = {}

giveBeeRequest = Event.new("GiveBee")
sellBeeRequest = Event.new("SellBee")
notifyBeePurchased = Event.new("NotifyBeePurchased")
beeCountUpdated = Event.new("BeeCountUpdated")

requestSeenBees = Event.new("RequestSeenBees")
recieveSeenBees = Event.new("RecieveSeenBees")

local restartTimerRequest = Event.new("RestartTimer")

local MoneyTimer = nil

clientBeeCount = 0

-- Event to request bee data from the server
local requestBeeList = Event.new("RequestBeeList")

-- Event to receive bee data from the server
receiveBeeList = Event.new("ReceiveBeeList")

updateBeeList = Event.new("UpdateBeeList")

--!SerializeField
local playerStatObject : GameObject = nil

-- Function to initialize bee species list for a player by loading from storage
local function InitializeSeenBeeSpecies(player, callback)
    -- Fetch the player's bee species data from storage
    Storage.GetPlayerValue(player, "SeenBeeSpecies", function(storedSpecies, errorCode)
        
        if playerSeenBeeSpecies[player] ~= nil then
            if #playerSeenBeeSpecies[player] ~= 0 then
                callback(playerSeenBeeSpecies[player])
                return
            end
        end


        -- If there is no data in storage, initialize an empty table
        if storedSpecies == nil then
            storedSpecies = {}
        end
        -- Store the player's bee species in memory
        playerSeenBeeSpecies[player] = storedSpecies

        -- If a callback is provided, call it once storage is loaded
        if callback then
            callback(storedSpecies)
        end
    end)
end

-- Function to save the player's bee species list back to persistent storage
local function SaveSeenBeeSpecies(player)
    if playerSeenBeeSpecies[player] ~= nil then
        -- Save the bee species list to persistent storage
        Storage.SetPlayerValue(player, "SeenBeeSpecies", playerSeenBeeSpecies[player], function(errorCode)
            if errorCode then
                --print("Error saving bee species for " .. player.name .. ": " .. tostring(errorCode))
            end
        end)
    end
end

-- Function to get the list of all bee species a player has obtained
function GetSeenBeeSpeciesList(player, callback)
    InitializeSeenBeeSpecies(player, function(storedSpecies)
        -- Return the list of species using the callback function
        if callback then
            callback(storedSpecies)
        end
    end)
end

-- Function to request the bee list for the local player
function RequestBeeList()
    requestBeeList:FireServer() -- Sends a request to the server with the player ID
end

-- Server-side event to listen for bee list requests
requestBeeList:Connect(function(player)
    -- Retrieve the bee list from storage
    GetBeeList(player, function(bees)
        -- Send the retrieved bee list back to the client
        receiveBeeList:FireClient(player, bees)
    end)
end)

-- Function to generate a unique ID for each bee
local function GenerateUniqueBeeId()
    return tostring(os.time()) .. "-" .. tostring(math.random(1000, 9999))
end

-- Function to initialize bee storage for a player by loading frequestSeenBeesrom storage
local function InitializeBeeStorage(player, callback)

    if playerBeeStorage[player] ~= nil then
        callback(playerBeeStorage[player])
        return
    end

    -- Fetch the player's bee data from storage
    Storage.GetPlayerValue(player, "BeeStorage", function(storedBees, errorCode)
        if not errorCode == 0 then
            return
        end

        -- If there is no data in storage, initialize an empty table
        if storedBees == nil then

            if playerBeeStorage[player] ~= nil then
                if #playerBeeStorage[player] ~= 0 then
                    callback(playerBeeStorage[player])
                    return
                end
            end

            storedBees = {}
        end
        -- Store the player's bee data in memory
        playerBeeStorage[player] = storedBees
        beeCountUpdated:FireClient(player, #playerBeeStorage[player])
        
        -- If a callback is provided (for async operations), call it once storage is loaded
        if callback then
            callback(storedBees)
        end
    end)
end

-- Function to save the player's bee storage back to persistent storage
local function SaveBeeStorage(player)
    if playerBeeStorage[player] ~= nil then
        -- Save the bee storage to persistent storage
        Storage.SetPlayerValue(player, "BeeStorage", playerBeeStorage[player], function(errorCode)
        end)
    end
end

-- Function to initialize bee storage for a player by loading from storage
local function InitializeBeeStorageSync(player)
    -- Fetch the player's bee data from storage and wait for the result
    local storedBees = Storage.GetPlayerValue(player, "BeeStorage")
    
    -- If there is no data in storage, initialize an empty table
    if storedBees == nil then

        if playerBeeStorage[player] ~= nil then
            if #playerBeeStorage[player] ~= 0 then
                return
            end
        end

        storedBees = {}
    end

    -- Store the player's bee data in memory
    playerBeeStorage[player] = storedBees
end

-- Function to add a bee to the player's storage and return its ID
function AddBee(player, speciesName, isAdult, timeToGrowUp)
    -- Ensure bee storage is initialized for the player
    if playerBeeStorage[player] == nil then
        InitializeBeeStorageSync(player) -- Synchronously load storage if needed
    end

    -- Create a new bee structure with a unique ID
    local bee = {
        beeId = GenerateUniqueBeeId(),
        species = speciesName,
        adult = isAdult,
        timeToGrowUp = timeToGrowUp
    }

    -- Add the bee to the player's storage in memory
    table.insert(playerBeeStorage[player], bee)

    beeCountUpdated:FireClient(player, #playerBeeStorage[player])

    -- --print the bee information (for debugging purposes)
    --print(player.name .. " received a new bee (ID: " .. bee.beeId .. ") of species: " .. speciesName)

    -- Return the bee ID
    return bee.beeId
end

-- Function to remove a bee from the player's storage by bee ID
function SellBee(beeSpecies, beeId, isAdult)
    sellBeeRequest:FireServer(beeId)
    local sellPrice = wildBeeManager.getSellPrice(beeSpecies)
    IncrementStat("Cash", sellPrice)
end

function SetBeeAdult(id)
    setBeeAdultRequest:FireServer(id)
end

function UpdateBeeAge(id, timeLeft)
    updateBeeAgeRequest:FireServer(id,timeLeft)
end

-- Function to get the list of all bees in the player's storage
function GetBeeList(player, callback)
    InitializeBeeStorage(player, function(storedBees)
        -- Return the list of bees using the callback function
        if callback then
            callback(storedBees)
        end
    end)
end

function RecalculatePlayerEarnRate(player)

    if ApiaryManager.GetPlayerApiaryLocation(player) == nil then
        return
    end

    GetBeeList(player, function(bees)
        local rate = 0
        for i, bee in ipairs(bees) do
            -- --print("checking item " .. item.id)
            if bee.adult then
                rate = rate + wildBeeManager.getHoneyRate(bee.species)
            end
        end

        if playerHasHoneyDoubler[player] == true then
            rate = rate * 2
        end

        playerMoneyEarnRates[player] = rate
        --print("New earn rate for " .. player.name .. " is " .. rate)
        
        restartTimerRequest:FireClient(player, rate)
    end)
end

local function UpdateStorage(player)
    local stats = {Cash = 0, Nets = 0, Bees = 0}
    stats.Cash = players[player].Cash.value
    stats.Nets = players[player].Nets.value

    -- Save the stats to storage and handle any errors
    Storage.SetPlayerValue(player, "PlayerStats", stats, function(errorCode)    end)
    --print(player.name .. " Stats Saved")
end

function tableContains(tbl, element)
    for _, value in ipairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

function removeElement(tbl, element)
    for i, value in ipairs(tbl) do
        if value == element then
            table.remove(tbl, i)
            return true -- Successfully removed
        end
    end
    return false -- Element not found
end

function ReinitPlayer(player)
    -- Initialize player's stats and store them in the players table
    players[player] = {
        player = player,
        Cash = IntValue.new("Cash" .. tostring(player.id), 100), -- Initial cash value
        Nets = IntValue.new("Nets" .. tostring(player.id), 0), -- Initial work experience
    }

    if client == nil then
        print("Player " .. player.name .. " was initialised")
        --RemoveAllPlayerItems(player)
        table.insert(onlinePlayers, player)
        ApiaryManager.SpawnAllApiariesForPlayer(player)
        beeObjectManager.SpawnAllBeesForPlayer(player)
        playerTimers[player] = nil

        Storage.SetPlayerValue(player, player.name, player.name)
    end
end

-- Function to track players joining and leaving the game
function TrackPlayers(game, characterCallback)
    -- Connect to the event when a player joins the game
    scene.PlayerJoined:Connect(function(scene, player)

        if players[player] ~= nil then
            return
        end

        -- Initialize player's stats and store them in the players table
        players[player] = {
            player = player,
            Cash = IntValue.new("Cash" .. tostring(player.id), 100), -- Initial cash value
            Nets = IntValue.new("Nets" .. tostring(player.id), 0), -- Initial work experience
        }

        if client == nil then
            print("Player " .. player.name .. " was initialised")
            --RemoveAllPlayerItems(player)
            table.insert(onlinePlayers, player)
            ApiaryManager.SpawnAllApiariesForPlayer(player)
            beeObjectManager.SpawnAllBeesForPlayer(player)
            playerTimers[player] = nil

            Storage.SetPlayerValue(player, player.name, player.name)
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
        --print(player.name .. " with id " .. player.id .. " is leaving")
        if client == nil then
            beeObjectManager.RemoveAllPlayerBees(player)
            ApiaryManager.RemoveAllPlayerApiaries(player)
            SaveProgress(player)
            removeElement(onlinePlayers, player)
        end
        Timer.new(20, function() 
            if tableContains(onlinePlayers, player) == false then
             players[player] = nil end end
            , false)
    end)
end

function SaveProgress(player)
    SaveBeeStorage(player)
    UpdateStorage(player)
    SaveSeenBeeSpecies(player)
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

-- Function to get the local player's cash
function GetPlayerCash(player)

    if player == nil then
        return players[client.localPlayer].Cash.value
    else
        if players[player] == nil then
            return -1
        end
        return players[player].Cash.value
    end
end

-- Function to initialize the client-side logic
function self:ClientAwake()
    -- Get the PlayerStatGui component from the game object to interact with the player's stat UI
    playerStatGui = playerStatObject:GetComponent(PlayerStatGui)

    -- Function to handle character instantiation for a player
    function OnCharacterInstantiate(playerinfo)
        local player = playerinfo.player
        local character = player.character

        -- Handle changes in the player's cash
        playerinfo.Cash.Changed:Connect(function(currentCash, oldVal)
            if player == client.localPlayer then
                -- Update the local UI to reflect the new cash value
                playerStatGui.SetCashUI(currentCash)
            end
        end)

        playerinfo.Nets.Changed:Connect(function(currentNets, oldVal)
            if player == client.localPlayer then
                -- Update the local UI to reflect the new cash value
                playerStatGui.SetNetsUI(currentNets)
            end
        end)

        restartTimerRequest:Connect(function(rate)
            if MoneyTimer ~= nil then
                MoneyTimer:Stop()
            end
            MoneyTimer = Timer.new(60/rate, function() IncrementStat("Cash", 1) end, true)
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

    updateBeeList:Connect(function() RequestBeeList() end)
end

function GiveBee(name, isCapture)
    giveBeeRequest:FireServer(name, isCapture)
    RequestBeeList() -- Update the bee list if it's open
end

--[[

    Server-side functionality

--]]

-- Function to save a player's stats to persistent storage
local function SaveStats(player)
    -- Create a table to store the player's current stats
    local stats = {Cash = 0, Nets = 0, Bees = 0}
    stats.Cash = players[player].Cash.value
    stats.Nets = players[player].Nets.value
end

-- Function to initialize the server-side logic
function self:ServerAwake()
    -- Track players joining and leaving the game
    TrackPlayers(server) 

    -- Fetch a player's stats from storage when they join
    getStatsRequest:Connect(function(player)
        Storage.GetPlayerValue(player, "PlayerStats", function(stats, errorCode)

            if not errorCode == 0 then
                return
            end

            -- If no existing stats are found, create default stats
            if stats == nil then 
                stats = {Cash = 100, Nets = 1, Bees = 0}
                Storage.SetPlayerValue(player, "PlayerStats", stats) 
            end

            -- Update the player's current networked stats from storage
            players[player].Cash.value = stats.Cash
            players[player].Nets.value = stats.Nets

            InitializeBeeStorage(player)
            InitializeSeenBeeSpecies(player)

            print("Stats filled out for player " .. player.name)

            --[[
            -- Uncomment the following lines to --print the player's stats to the console for debugging
            for stat, value in pairs(stats) do
                --print(player.name .. "'s " .. stat .. ": " .. tostring(value))
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

         --Increment the  Cash / Nets / Stat of the player by 'value' with +=
         if stat == "Cash" then players[player].Cash.value += value end
         if stat == "Nets" then players[player].Nets.value += value end
         -- Save the updated stats to storage
         SaveStats(player)

         if(stat ~= "Cash") then
            UpdateStorage(player)
         end
    end)

    giveBeeRequest:Connect(function(player, name, isCapture)

        

        if isCapture then
            isAdult = true
            growTime = 0
            --print(player.name .. " captured a " .. name .. "!")
        else
            isAdult = false
            growTime =  wildBeeManager.getGrowTime(name)
            --print(player.name .. " recieved a " .. name .. "!")
        end
        
        -- Ensure the bee species list is initialized for the player
        if playerSeenBeeSpecies[player] == nil then
            InitializeSeenBeeSpecies(player)
        end

        -- Check if the species is already in the list; if not, add it
        if not table.find(playerSeenBeeSpecies[player], name) then
            table.insert(playerSeenBeeSpecies[player], name)
        end


        id = AddBee(player, name, isAdult, growTime)
    
        if ApiaryManager.GetPlayerApiaryLocation(player) ~= nil then
            beeObjectManager.SpawnBee(player, name, ApiaryManager.GetPlayerApiaryLocation(player), id, isAdult, growTime, wildBeeManager.getGrowTime(name))
        end

        RecalculatePlayerEarnRate(player)
    end)

    sellBeeRequest:Connect(function(player, beeId)
    
        InitializeBeeStorage(player, function(storedBees)
            -- Loop through the bee storage to find the bee to remove by beeId
            for index, bee in ipairs(storedBees) do
                if bee.beeId == beeId then
                    table.remove(storedBees, index)
                    beeObjectManager.RemoveBee(player, beeId)
                    -- Save the updated bee storage back to persistent storage
                    beeCountUpdated:FireClient(player, #playerBeeStorage[player])
                    RecalculatePlayerEarnRate(player)
                    --print("Bee with ID " .. beeId .. " removed from " .. player.name .. "'s storage.")
                    return
                end
            end
    
            --print("Bee with ID " .. beeId .. " not found in " .. player.name .. "'s storage.")
        end)
    end)

    setBeeAdultRequest:Connect(function(player, id)
        --print("Bee with id " .. id .. " is growing up")
        -- Ensure the bee storage is loaded for the player
        GetBeeList(player, function(storedBees)
            -- Loop through the player's bees to find the one with the matching ID
            for _, bee in ipairs(storedBees) do
                if bee.beeId == id then
                    -- Set the bee to adult and grow time to zero
                    bee.adult = true
                    bee.timeToGrowUp = 0
    
                    -- Save the updated bee storage back to persistent storage
                    RecalculatePlayerEarnRate(player)
                    updateBeeList:FireClient(player)
    
                    --print("Bee with ID " .. id .. " is now an adult with grow time set to 0.")
                    return
                end
            end
    
            --print("Bee with ID " .. id .. " not found in " .. player.name .. "'s storage.")
        end)
    end)

    updateBeeAgeRequest:Connect(function(player, id, timeLeft)
        GetBeeList(player, function(storedBees)
            -- Loop through the player's bees to find the one with the matching ID
            for _, bee in ipairs(storedBees) do
                if bee.beeId == id then
                    bee.timeToGrowUp = timeLeft
                    return
                end
            end
        end)
    end)

    requestSeenBees:Connect(function(player)
        GetSeenBeeSpeciesList(player, function(bees)
            -- Send the retrieved bee list back to the client
            recieveSeenBees:FireClient(player, bees)
        end)
    end)

    Timer.new(30, function() 
    for player, data in ipairs(players) do
        SaveProgress(player)
    end
    --print("Saved!")
    end, true)
end

function SetHoneyDoublerForPlayer(player, time)
   playerHasHoneyDoubler[player] = true
   Timer.new(time, function() playerHasHoneyDoubler[player] = nil RecalculatePlayerEarnRate(player) end, false)
    RecalculatePlayerEarnRate(player)
end

function PlayerHasActiveHoneyDoubler(player)
    print("checking if player has active doubler")
    if playerHasHoneyDoubler[player] == true then
        print("true!")
        return true
    end
    print("false!")
    return false
end