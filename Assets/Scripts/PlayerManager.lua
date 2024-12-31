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
local flowerManager = require("FlowerManager")
local festiveBeeManager = require("FestiveBeeManager")
local placedObjectsManager = require("PlacedObjectsManager")

-- Variable to hold the player's statistics GUI component
local playerStatGui = nil

-- Table to keep track of players and their associated stats
players = {}

onlinePlayers = {} -- strictly online players only

-- Table to hold players' bee storage in memory (server)
local playerBeeStorage = {}

-- Track money accumulation speeds per player (server)
local playerMoneyEarnRates = {}

-- Table to hold players' bee species in memory (server)
local playerSeenBeeSpecies = {}

-- Table for who has active honey doubler (server)
local playerHasHoneyDoubler = {}

local playerTimers = {}

-- Track how many times a player has joined (server)
local playerJoins = {}

giveBeeRequest = Event.new("GiveBeeRequest")
sellBeeRequest = Event.new("SellBeeRequest")
notifyBeePurchased = Event.new("NotifyBeePurchased")
notifyHatPurchased = Event.new("NotifyHatPurchased")
beeCountUpdated = Event.new("BeeCountUpdated")
playerEarnRateChanged = Event.new("PlayerEarnRateChanged")
giveShearsRequest = Event.new("GiveShearsRequest")
givePlayerHatRequest = Event.new("GivePlayerHatRequest")
requestRemoveBeeHat = Event.new("requestRemoveBeeHat")
setPlayerVersionString = Event.new("setPlayerVersionString")

requestApiaryLocation = Event.new("requestApiaryLocation")
notifyApiaryLocation = Event.new("notifyApiaryLocation")

requestSeenBees = Event.new("RequestSeenBees")
receiveSeenBees = Event.new("ReceiveSeenBees")
requestEarnRates = Event.new("RequestEarnRates")
receiveEarnRates = Event.new("ReceiveEarnRates")
requestHatStatus = Event.new("RequestHatStatus")
receiveHatStatus = Event.new("ReceiveHatStatus")
setHatStatus = Event.new("SetHatStatus")

local restartTimerRequest = Event.new("RestartCashTimer")

local MoneyTimer = nil

lastJoinedVersion = -1

clientBeeCount = 0

--!SerializeField
local CreateOrderObject : GameObject = nil

-- Event to request bee data from the server
local requestBeeList = Event.new("RequestBeeList")

-- Event to receive bee data from the server
receiveBeeList = Event.new("ReceiveBeeList")

updateBeeList = Event.new("UpdateBeeList")

--!SerializeField
local playerStatObject : GameObject = nil

function SetBeeHat(player, beeId, hatId)
    for _, bee in ipairs(playerBeeStorage[player]) do
        if bee.beeId == beeId then

            if hatId == nil then
                local transaction = InventoryTransaction.new():GivePlayer(player, bee.hat, 1)
                Inventory.CommitTransaction(transaction)
            end

            bee.hat = hatId
            return
        end
    end
end

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

function SaveHatStatus(player, id)
    requestHatStatus:FireClient(player)
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
    if player ~= nil and playerBeeStorage[player] ~= nil then
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
        timeToGrowUp = timeToGrowUp,
        hat = nil
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
    if beeSpecies ~= "Fesitve Bee" then
        IncrementStat("Cash", sellPrice)
    end
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

function RecalculatePlayerEarnRate(player, isDc)

    if ApiaryManager.GetPlayerApiaryLocation(player) == nil then
        playerEarnRateChanged:FireClient(player, 0)
        restartTimerRequest:FireClient(player, 0)
        playerMoneyEarnRates[player] = 0
        return
    end

    GetBeeList(player, function(bees)
        local rate = 0

        uniqueBees = {}
        beeCounts = {}
        uniqueHats = {}

        for i, bee in ipairs(bees) do
            -- --print("checking item " .. item.id)
            if bee.adult then
                if not table.find(uniqueBees, bee.species) then
                    table.insert(uniqueBees, bee.species)
                    beeCounts[bee.species] = 0
                end
                beeCounts[bee.species] = beeCounts[bee.species] + 1
                rate = rate + wildBeeManager.getHoneyRate(bee.species)
            end

            if bee.hat ~= nil then
                if not table.find(uniqueHats, bee.hat) then
                    table.insert(uniqueHats, bee.hat)
                end
            end
        end

        totalEffect = 1
        if flowerManager.GetPlacedFlowers(player) ~= nil then
            redCount = 0
            whiteCount = 0
            yellowCount = 0
            purpleCount = 0

            -- Calculate flowers amount
            for index , flower in ipairs(flowerManager.GetPlacedFlowers(player)) do
                if flower.name == "Red" then
                    redCount = redCount + 1
                elseif flower.name == "White" then
                    whiteCount = whiteCount + 1
                elseif flower.name == "Yellow" then
                    yellowCount = yellowCount + 1
                elseif flower.name == "Purple" then
                    purpleCount = purpleCount + 1
                end
            end
            
            most = 0
            for bee, count in ipairs(beeCounts) do
                if count > most then
                    most = count
                end
            end

            -- Calculate flower effects
            whiteEffect = #uniqueBees * whiteCount * 0.001

            redEffect = most * redCount * 0.001

            yellowEffect = #uniqueHats * yellowCount * 0.001
            
            purpleEffect = 0

            for player, value in pairs(players) do
                if player ~= nil then
                    purpleEffect = purpleEffect + 1
                end
            end

            if isDc ~= nil then
                purpleEffect = purpleEffect - 1
            end

            purpleEffect = purpleEffect * purpleCount * 0.001

            totalEffect = 1 + whiteEffect + redEffect + yellowEffect + purpleEffect
        end

        rate = rate * totalEffect
        if playerHasHoneyDoubler[player] == true then
            rate = rate * 2
        end

        playerMoneyEarnRates[player] = rate
        --print("New earn rate for " .. player.name .. " is " .. rate)
        
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

function GetLastJoinedVersion()
    return lastJoinedVersion.value
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
            Cash = IntValue.new("Cash" .. tostring(player.id), 100),
            Nets = IntValue.new("Nets" .. tostring(player.id), 0), 
            FlowerCapacity = IntValue.new("FlowerCapacity" .. tostring(player.id), 5),
            SweetScentLevel = IntValue.new("SweetScentLevel"..tostring(player.id), 0),
            BeeCapacity = IntValue.new("BeeCapacity" .. tostring(player.id), 10),
            HasShears = BoolValue.new("HasShears" .. tostring(player.id), false)
        }

        if client ~= nil then
           lastJoinedVersion = IntValue.new("LastJoinedVersion" .. tostring(player.id), 0)
        end

        if client == nil then
            print("Player " .. player.name .. " was initialised")
            --RemoveAllPlayerItems(player)
            table.insert(onlinePlayers, player)
            ApiaryManager.SpawnAllApiariesForPlayer(player)
            beeObjectManager.SpawnAllBeesForPlayer(player)
            flowerManager.SpawnAllFlowersForIncomingPlayer(player)
						placedObjectsManager.SpawnAllObjectsForIncomingPlayer(player)
            playerTimers[player] = nil
            setPlayerVersionString:FireClient(player, "1.2.3")
            festiveBeeManager.OnPlayerJoined(player)

            for player, playerData in pairs(players) do
                RecalculatePlayerEarnRate(player)
            end

            Storage.GetPlayerValue(player, player.name, function(data, errorCode)
                if data == nil or data.joins == nil then
                    data = {name = player.name, version = 1, joins = 1} -- remember to increment version for each breaking change
                else
                    data.joins = data.joins + 1
                end

                version = IntValue.new("LastJoinedVersion" .. tostring(player.id), 0)
                version.value = data.version

                data.version = 1

                print("player joins are " .. data.joins)

                playerJoins[player] = IntValue.new("Joins" .. tostring(player.id), 0)
                Timer.new(0.05, function() playerJoins[player].value = data.joins end, false)
                Storage.SetPlayerValue(player, player.name, data)
            end)

            Storage.GetPlayerValue(player, "HatStatus", function(soldOutHats)
                setHatStatus:FireClient(player, soldOutHats)
            end)
        else
            playerJoins[player] = IntValue.new("Joins" .. tostring(player.id), 0)
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
            id = player.user.id
            print(player.name .. " with id " .. player.user.id .. " is leaving")
            beeObjectManager.RemoveAllPlayerBees(player)
            ApiaryManager.RemoveAllPlayerApiaries(player)
            flowerManager.RemoveAllPlayerFlowers(player)
						placedObjectsManager.RemoveAllPlayerPlacedObjects(player)
            playerJoins[player] = nil
            festiveBeeManager.OnPlayerLeft(player)
            SaveProgress(player, true)
            removeElement(onlinePlayers, player)
        end
        Timer.new(5, function() 
            if tableContains(onlinePlayers, player) == false then
             players[player] = nil end end
            , false)
    end)
end

function SaveProgress(player, wasDc)
    SaveBeeStorage(player, player.user.id)
    UpdateStorage(player, player.user.id)
    SaveSeenBeeSpecies(player, player.user.id)
    SaveHatStatus(player, player.user.id)
    flowerManager.SaveFlowerPositions(player, player.user.id)
		placedObjectsManager.SavePlacedObjects(player, player.user.id)
    for player, playerData in pairs(players) do
        RecalculatePlayerEarnRate(player, wasDc)
    end
end

function RequestEarnRates()
    print("requesting")
    requestEarnRates:FireServer()
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

function GetPlayerBeeCapacity()
    return players[client.localPlayer].BeeCapacity.value
end

function GetPlayerJoins()
    print("getting player joins... " .. playerJoins[client.localPlayer].value)
    return playerJoins[client.localPlayer].value
end

function GetPlayerSweetScentLevel()
    return players[client.localPlayer].SweetScentLevel.value
end

function GetPlayerFlowerCapacity(player)
    if player == nil then
        return players[client.localPlayer].FlowerCapacity.value
    else
        return players[player].FlowerCapacity.value
    end
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
            MoneyTimer = Timer.new(60/rate, function() IncrementCashLocal() end, true)
        end)
    end

    Timer.new(1, function() SendCashBatch() end, true)

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

    requestHatStatus:Connect(function() receiveHatStatus:FireServer(CreateOrderObject:GetComponent(CreateOrderGui).GetSoldOutHats()) end)

    setHatStatus:Connect(function(_soldOutHats) soldOutHats = _soldOutHats end)

		placedObjectsManager.InitClient()
end

function SendCashBatch()
    if localCash ~= nil then
        IncrementStat("Cash", localCash)
    end
    localCash = 0
end

function IncrementCashLocal()
    localCash = localCash + 1
    playerStatGui.SetCashUI(players[client.localPlayer].Cash.value + localCash)
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

    print("PlayerManager ServerAwake started")

    -- Fetch a player's stats from storage when they join
    getStatsRequest:Connect(function(player)
        Storage.GetPlayerValue(player, "PlayerStats", function(stats, errorCode)

            if not errorCode == 0 then
                return
            end

            -- If no existing stats are found, create default stats
            if stats == nil then 
                stats = {Cash = 100, Nets = 1, BeeCapacity = 8, FlowerCapacity = 5, SweetScentLevel = 0, HasShears = false}
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
            --print(player.name .. " captured a " .. name .. "!")
        else
            isAdult = false
            growTime =  wildBeeManager.getGrowTime(name)
            --print(player.name .. " received a " .. name .. "!")
        end
        
        -- Ensure the bee species list is initialized for the player
        if playerSeenBeeSpecies[player] == nil then
            InitializeSeenBeeSpecies(player)
        end

        -- Check if the species is already in the list; if not, add it
        if not table.find(playerSeenBeeSpecies[player], name) then
            table.insert(playerSeenBeeSpecies[player], name)
        end

        ApiaryManager.UpdateLabelForApiary(player, #playerSeenBeeSpecies[player])

        id = AddBee(player, name, isAdult, growTime)
    
        if ApiaryManager.GetPlayerApiaryLocation(player) ~= nil then
            beeObjectManager.SpawnBee(player, name, ApiaryManager.GetPlayerApiaryLocation(player), id, isAdult, growTime, wildBeeManager.getGrowTime(name), nil)
        end

        RecalculatePlayerEarnRate(player)
    end)

    sellBeeRequest:Connect(function(player, beeId)
    
        InitializeBeeStorage(player, function(storedBees)
            -- Loop through the bee storage to find the bee to remove by beeId
            for index, bee in ipairs(storedBees) do
                if bee.beeId == beeId then

                    if bee.hat ~= nil then
                        local transaction = InventoryTransaction.new():GivePlayer(player, bee.hat, 1)
                        Inventory.CommitTransaction(transaction)
                    end
        

                    table.remove(storedBees, index)
                    beeObjectManager.RemoveBee(player, beeId)
                    -- Save the updated bee storage back to persistent storage
                    beeCountUpdated:FireClient(player, #playerBeeStorage[player])

                    if bee.species == "Festive Bee" then
                      Wallet.TransferGoldToPlayer(player, 1, function(response, err)
                        if err ~= WalletError.None then
			                    error("Something went wrong while transferring gold: " .. WalletError[err])
			                    return
		                    end

                        print("Sent 1 Gold, Gold remaining: : ", response.gold)
                      end)
                    end

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
            receiveSeenBees:FireClient(player, bees)
        end)
    end)

    givePlayerHatRequest:Connect(function(player, Id)
        local transaction = InventoryTransaction.new():GivePlayer(player, Id, 1)
        Inventory.CommitTransaction(transaction)
    end)

    requestRemoveBeeHat:Connect(function(player, beeId)
        SetBeeHat(player, beeId, nil)
    end)

    requestApiaryLocation:Connect(function(player)
        notifyApiaryLocation:FireClient(player, ApiaryManager.GetPlayerApiaryLocation(player))
    end
    )

    Timer.new(45, function() 
    for player, data in pairs(players) do
        if player ~= nil then
            print("saving for player " .. player.name .. ".")
            print("test")
            SaveProgress(player, false)
        end
    end
    print("Saved!")
    end, true)

		print("About to init placed objects")
		placedObjectsManager.InitServer()
    requestEarnRates:Connect(function(player)
        print("Earn rates requested")
        receiveEarnRates:FireClient(player, playerMoneyEarnRates)
    end)

    receiveHatStatus:Connect(function(player, soldOutHats)
        Storage.SetPlayerValue(player, "HatStatus", soldOutHats)
    end)

		print("PlayerManager ServerAwake finished")
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

function GiveHat(Id)
    givePlayerHatRequest:FireServer(Id)
end

showBadges = true

function ShouldShowBadges()
    return showBadges
end

showBadgesChanged = Event.new("showBadgesChanged")

function ToggleShowBadges()
    if showBadges then
        showBadges = false
    else
        showBadges = true
    end

    showBadgesChanged:Fire(showBadges)
end