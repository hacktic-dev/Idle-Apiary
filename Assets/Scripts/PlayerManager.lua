--!Type(Module) -- Module type declaration, typically used in specific game engines or frameworks.

-- Create events for different types of requests, these will be used for communication between client and server.
local getStatsRequest = Event.new("GetStatsRequest")
local saveStatsRequest = Event.new("SaveStatsRequest")
local incrementStatRequest = Event.new("IncrementStatRequest")
local setBeeAdultRequest = Event.new("SetBeeAdultRequest")
local updateBeeAgeRequest = Event.new("UpdateBeeAgeRequest")

local ApiaryManager = require("ApiaryManager")
local beeObjectManager = require("BeeObjectManager")
local wildBeeManager = require("WildBeeManager")
local flowerManager = require("FlowerManager")

-- Variable to hold the player's statistics GUI component
local playerStatGui = nil

-- Table to keep track of players and their associated stats
players = {}

-- Table to hold players' bee storage in memory (server)
local playerBeeStorage = {}

-- Track money accumulation speeds per player (server)
local playerMoneyEarnRates = {}

-- Table to hold players' bee species in memory (server)
local playerSeenBeeSpecies = {}

local playerTimers = {}

giveBeeRequest = Event.new("GiveBee")
sellBeeRequest = Event.new("SellBee")
notifyBeePurchased = Event.new("NotifyBeePurchased")
beeCountUpdated = Event.new("BeeCountUpdated")
playerEarnRateChanged = Event.new("PlayerEarnRateChanged")
giveShearsRequest = Event.new("GiveShearsRequest")

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
local function SaveSeenBeeSpecies(player, id)
    if playerSeenBeeSpecies[player] ~= nil then
        print("saving bees for " .. player.name)
        -- Save the bee species list to persistent storage
        Storage.SetValue(id .. "/" ..  "SeenBeeSpecies", playerSeenBeeSpecies[player], function(errorCode)
            if errorCode then
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
function GenerateUniqueID()
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
local function SaveBeeStorage(player, id)
    if playerBeeStorage[player] ~= nil then
        -- Save the bee storage to persistent storage
        Storage.SetValue(id .. "/" ..  "BeeStorage", playerBeeStorage[player], function(errorCode)
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
        beeId = GenerateUniqueID(),
        species = speciesName,
        adult = isAdult,
        timeToGrowUp = timeToGrowUp
    }

    -- Add the bee to the player's storage in memory
    table.insert(playerBeeStorage[player], bee)

    beeCountUpdated:FireClient(player, #playerBeeStorage[player])

    -- Print the bee information (for debugging purposes)
    print(player.name .. " received a new bee (ID: " .. bee.beeId .. ") of species: " .. speciesName)

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
    GetBeeList(player, function(bees)
        local rate = 0
        for i, bee in ipairs(bees) do
            -- print("checking item " .. item.id)
            if bee.adult then
                rate = rate + wildBeeManager.getHoneyRate(bee.species)
            end
        end

        playerMoneyEarnRates[player] = rate
        print("New earn rate for " .. player.name .. " is " .. rate)
        
        playerEarnRateChanged:FireClient(player, rate)
        restartTimerRequest:FireClient(player, rate)
    end)
end

local function UpdateStorage(player, id)
    local stats = {Cash = 0, Nets = 0, BeeCapacity = 0, FlowerCapacity = 0, SweetScentLevel = 0, HasShears = false}
    stats.Cash = players[player].Cash.value
    stats.Nets = players[player].Nets.value
    stats.BeeCapacity = players[player].BeeCapacity.value
    stats.FlowerCapacity = players[player].FlowerCapacity.value
    stats.SweetScentLevel = players[player].SweetScentLevel.value
    stats.HasShears = players[player].HasShears.value

    -- Save the stats to storage and handle any errors
    Storage.SetValue(id .. "/" .. "PlayerStats", stats, function(errorCode)    end)
    print(player.name .. " Stats Saved")
end

-- Function to track players joining and leaving the game
local function TrackPlayers(game, characterCallback)
    -- Connect to the event when a player joins the game
    scene.PlayerJoined:Connect(function(scene, player)
        -- Initialize player's stats and store them in the players table
        players[player] = {
            player = player,
            Cash = IntValue.new("Cash" .. tostring(player.id), 100),
            Nets = IntValue.new("Nets" .. tostring(player.id), 0), 
            FlowerCapacity = IntValue.new("BeeCapacity" .. tostring(player.id), 5),
            SweetScentLevel = IntValue.new("SweetScentLevel"..tostring(player.id), 0),
            BeeCapacity = IntValue.new("BeeCapacity" .. tostring(player.id), 10),
            HasShears = BoolValue.new("HasShears" .. tostring(player.id), false)
        }
        
        if client == nil then
            --RemoveAllPlayerItems(player)

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
        if client == nil then
            id = player.user.id
            print(player.name .. " with id " .. player.user.id .. " is leaving")
            beeObjectManager.RemoveAllPlayerBees(player)
            ApiaryManager.RemoveAllPlayerApiaries(player)
            SaveSeenBeeSpecies(player, id)
            SaveBeeStorage(player, id)
            UpdateStorage(player, id)
            flowerManager.SaveFlowerPositions(player, id)
            flowerManager.RemoveAllPlayerFlowers(player)
        end
                -- Remove the player from the players table
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

-- Function to get the local player's cash
function GetPlayerCash(player)

    if player == nil then
        return players[client.localPlayer].Cash.value
    else
        return players[player].Cash.value
    end
end

function GetPlayerBeeCapacity()
    return players[client.localPlayer].BeeCapacity.value
end

function GetPlayerSweetScentLevel()
    return players[client.localPlayer].SweetScentLevel.value
end

function GetPlayerFlowerCapacity()
    return players[client.localPlayer].FlowerCapacity.value
end 

function GetPlayerOwnsShears()
    return players[client.localPlayer].HasShears.value
end 

-- Client-side logic
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

    function GiveShears()
        giveShearsRequest:FireServer()
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
    local stats = {Cash = 0, Nets = 0, BeeCapacity = 0}
    stats.Cash = players[player].Cash.value
    stats.Nets = players[player].Nets.value
    stats.BeeCapacity = players[player].BeeCapacity.value
    stats.HasShears = players[player].HasShears.value
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
                stats = {Cash = 100, Nets = 1, BeeCapacity = 10, FlowerCapacity = 5, SweetScentLevel = 0, HasShears = false}
                Storage.SetPlayerValue(player, "PlayerStats", stats) 
            end

            -- Update the player's current networked stats from storage
            players[player].Cash.value = stats.Cash
            players[player].Nets.value = stats.Nets
            players[player].BeeCapacity.value = stats.BeeCapacity

            -- Init 1.1.x values if player is coming from 1.0.x
            if stats.HasShears ~= nil then
                players[player].HasShears.value = stats.HasShears
            else
                players[player].HasShears.value = false
            end

            if stats.SweetScentLevel ~= nil then
                players[player].SweetScentLevel.value = stats.SweetScentLevel
            else
                players[player].SweetScentLevel.value = 0
            end

            if stats.FlowerCapacity ~= nil then
                players[player].FlowerCapacity.value = stats.FlowerCapacity
            else
                players[player].FlowerCapacity.value = 5
            end

            InitializeBeeStorage(player)
            InitializeSeenBeeSpecies(player)

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

         --Increment the  Cash / Nets / Stat of the player by 'value' with +=
         if stat == "Cash" then players[player].Cash.value += value end
         if stat == "Nets" then players[player].Nets.value += value end
         if stat == "BeeCapacity" then players[player].BeeCapacity.value += value end
         if stat == "SweetScentLevel" then players[player].SweetScentLevel.value += value end
         if stat == "FlowerCapacity" then players[player].FlowerCapacity.value += value end
         -- Save the updated stats to storage
         SaveStats(player)

         if(stat ~= "Cash") then
            UpdateStorage(player, player.user.id)
         end
    end)

    giveShearsRequest:Connect(function(player)
        players[player].HasShears.value = true
        SaveStats(player)
        UpdateStorage(player, player.user.id)
    end
    )

    giveBeeRequest:Connect(function(player, name, isCapture)

        

        if isCapture then
            isAdult = true
            growTime = 0
            print(player.name .. " captured a " .. name .. "!")
        else
            isAdult = false
            growTime =  wildBeeManager.getGrowTime(name)
            print(player.name .. " recieved a " .. name .. "!")
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

        -- Only have non zero rate if apiary is placed
        if ApiaryManager.GetPlayerApiaryLocation(player) ~= nil then
            RecalculatePlayerEarnRate(player)
        end
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
                    if ApiaryManager.GetPlayerApiaryLocation(player) ~= nil then
                        RecalculatePlayerEarnRate(player)
                    end
                    print("Bee with ID " .. beeId .. " removed from " .. player.name .. "'s storage.")
                    return
                end
            end
    
            print("Bee with ID " .. beeId .. " not found in " .. player.name .. "'s storage.")
        end)
    end)

    setBeeAdultRequest:Connect(function(player, id)
        print("Bee with id " .. id .. " is growing up")
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
    
                    print("Bee with ID " .. id .. " is now an adult with grow time set to 0.")
                    return
                end
            end
    
            print("Bee with ID " .. id .. " not found in " .. player.name .. "'s storage.")
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
end

function GiveCash(player, amount)
    players[player].Cash.value += amount 
    SaveStats(player)
end