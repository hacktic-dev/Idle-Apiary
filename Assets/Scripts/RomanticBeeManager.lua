--!Type(Module)

poolSize = 0 -- client/server
spawnRate = 0 -- client/server

isBeeSpawned = false -- client
spawnedBee = nil -- client

beeCountToRemoveFromPool = 0 -- server
romanticLeaderboard = nil -- server

notifyRomanticBeeCaught = Event.new("NotifyRomanticBeeCaught")
requestRomanticLeaderboard = Event.new("RequestRomanticLeaderboard")
receiveRomanticLeaderboard = Event.new("ReceiveRomanticLeaderboard")
requestPlayerScore = Event.new("RequestPlayerScore")
receivePlayerScore = Event.new("ReceivePlayerScore")

--!SerializeField
local RomanticBee : GameObject = nil

local MIN_SPAWN_DISTANCE = 50 -- Minimum distance from player to spawn a bee
local MIN_CAPTURE_DISTANCE = 4.5 -- Minimum distance from player to spawn a bee
local MAX_SPAWN_DISTANCE = 135 -- Maximum distance from player to spawn a bee
local DESPAWN_DISTANCE = 140 -- Distance beyond which the bee despawns
local MAX_BEES = 21 -- Maximum number of bees allowed

wildBeeManager = require("WildBeeManager")
playerManager = require("PlayerManager")

local playerScores = {} -- Memory structure to store player-specific scores

-- Periodic saving interval in seconds
local SAVE_INTERVAL = 30

function GetPlayerScore(player)
    return playerScores[player]
end

-- Function to save a player's score to storage
local function SavePlayerScore(player)
    if player ~= nil and playerScores[player] ~= nil then
        Storage.SetPlayerValue(player, "RomanticBeeScore", playerScores[player], function(errorCode)
            if errorCode ~= 0 then
                print("Error saving player score for " .. player.name)
            else
                print("Saved score for " .. player.name .. ": " .. playerScores[player])
            end
        end)
    end
end

function RequestRomanticLeaderboard()
    requestRomanticLeaderboard:FireServer()
end

function self:ServerAwake()
    requestRomanticLeaderboard:Connect(function(player)
        receiveRomanticLeaderboard:FireClient(player, romanticLeaderboard)
    end
    )

    requestPlayerScore:Connect(function(player)
        receivePlayerScore:FireClient(player, playerScores[player])
    end
    )

    spawnRate = NumberValue.new("RomanticBeeSpawnRate", 0)
    poolSize = IntValue.new("RomanticBeePool", 0)

    RetrieveRomanticBeePool()
    UpdateRomanticLeaderboard()

    Timer.new(30, function() RetrieveRomanticBeePool() end, true)

    Timer.new(15, function() UpdateRomanticLeaderboard() end, true)

    Timer.new(SAVE_INTERVAL, function()
        for player, _ in pairs(playerScores) do
            SavePlayerScore(player)
        end
    end, true)

    notifyRomanticBeeCaught:Connect(function(player)
        beeCountToRemoveFromPool = beeCountToRemoveFromPool + 1
        poolSize.value = poolSize.value - 1

        playerScores[player] = playerScores[player] + 1
    end)

    server.PlayerDisconnected:Connect(function(player)
        -- Save player data to storage on disconnect
        --SavePlayerScore(player)
        --playerScores[player] = nil -- Remove from memory
    end)
end

function OnPlayerJoined(player)
        Storage.GetPlayerValue(player, "RomanticBeeScore", function(score, errorCode)
            if errorCode ~= 0 then
                print("Error loading player score for " .. player.name)
                score = 0 -- Default score
            end
            playerScores[player] = score or 0
            print("Loaded score for " .. player.name .. ": " .. playerScores[player])
        end)
end

function OnPlayerLeft(player)
    playerScores[player] = nil
end

function self:ClientAwake()
    Timer.new(1, function() TrySpawnRomanticBee() end, true)
    spawnRate = NumberValue.new("RomanticBeeSpawnRate", 0)
    poolSize = IntValue.new("RomanticBeePool", 0)
end

-- Server
function RetrieveRomanticBeePool()
    Storage.GetValue("RomanticBeePool", function(pool, errorCode)
    if errorCode ~= 0 then
        print("Error: couldn't get romantic bee pool")
        return
    end

    if pool == nil then
        pool = {}
        pool.size = 100
        pool.rate = 1
    end

    pool.size = pool.size - beeCountToRemoveFromPool

    beeCountToRemoveFromPool = 0

    poolSize.value = pool.size
    spawnRate.value = pool.rate

    Storage.SetValue("RomanticBeePool", pool, function(errorCode) if not errorCode == 0 then print("Error: Romantic bee pool update failed!") end end)
    end)

end

function UpdateRomanticLeaderboard()
    -- Get the central leaderboard from storage

    Storage.GetValue("RomanticLeaderboard", function(leaderboard, errorCode)
        if errorCode ~= 0 then
            print("Error: couldn't get romantic leaderboard")
            return
        end

        leaderboard = leaderboard or {}

        -- Update leaderboard based on players' in-memory scores
        for player, score in pairs(playerScores) do

            if player ~= nil then
                local isInTopTen = false

                -- Check if player is already in leaderboard
                for i, entry in ipairs(leaderboard) do
                    if player and entry.key == player.name then
                        isInTopTen = true
                        -- Update player's score if it's higher
                        if score > entry.value then
                            leaderboard[i].value = score
                        end
                        break
                    end
                end

                -- Add new player if not in leaderboard and has a high enough score
                if not isInTopTen then
                    table.insert(leaderboard, {key = player.name, value = score})
                end
            end
        end

        -- Sort leaderboard by score in descending order and trim to top 10
        table.sort(leaderboard, function(a, b) return a.value > b.value end)
        while #leaderboard > 10 do
            table.remove(leaderboard)
        end

        romanticLeaderboard = leaderboard

        -- Save updated leaderboard back to storage
        Storage.SetValue("RomanticLeaderboard", leaderboard, function(errorCode)
            if errorCode ~= 0 then
                print("Error saving leaderboard")
            end
        end)
    end)
end


-- Client
function TrySpawnRomanticBee()
    if math.random() > spawnRate.value then
        return
    end

    if poolSize.value <= 0 then
        return
    end

    if isBeeSpawned then
        return
    end

    local spawnPosition
    local playerPosition = client.localPlayer.character:GetComponent(Transform).position  

    while true do
        spawnPosition = Vector3.new(math.random(-115, 115) , 0, math.random(-115, 115))
        distance = Vector3.Distance(playerPosition, spawnPosition)
        if distance > MIN_SPAWN_DISTANCE and distance < MAX_SPAWN_DISTANCE then break end
    end

    spawnedBee = Object.Instantiate(RomanticBee)
    spawnedBee.transform.position = spawnPosition
    spawnedBee:GetComponent(BeeWandererScript).SetSpawnPosition(spawnPosition)

    table.insert(wildBeeManager.wildBees, { bee = spawnedBee, speciesName = "Romantic Bee", player = client.localPlayer })

    isBeeSpawned = true
end

local function despawnWildBee(bee)
    Object.Destroy(bee)
    isBeeSpawned = false
    spawnedBee = nil

    for i, data in ipairs(wildBeeManager.wildBees) do
        if data.bee == bee then
            table.remove(wildBeeManager.wildBees, i)
            break
        end
    end
end

function captureBee(bee)
    -- Check if the player has a net available
    local netsAvailable = playerManager.players[client.localPlayer].Nets.value
    local beeCount = playerManager.clientBeeCount
    print("Bee count: " .. beeCount)

    if netsAvailable == 0 then
        print("No nets available for player: " .. client.localPlayer.name)
        wildBeeManager.notifyCaptureFailed:Fire(1)
        return
    elseif beeCount + 1 > playerManager.GetPlayerBeeCapacity() then
        print("Max bees owned: " .. client.localPlayer.name)
        wildBeeManager.notifyCaptureFailed:Fire(2)
        return
    end

    -- Decrement the player's net count
    playerManager.IncrementStat("Nets", -1)

    -- Give the captured bee species to the player
    playerManager.GiveBee("Romantic Bee", true)

    -- Remove the bee from the wild bees list and despawn it
    despawnWildBee(bee)

    print("Bee captured and moved to apiary for player: " .. client.localPlayer.name)
    wildBeeManager.notifyCaptureSucceeded:Fire("Romantic Bee")
    notifyRomanticBeeCaught:FireServer()
end

function self:Update()
    if spawnedBee ~= nil and ((spawnedBee.transform.position - client.localPlayer.character:GetComponent(Transform).position).magnitude > DESPAWN_DISTANCE) then
        despawnWildBee(bee)
    end
end