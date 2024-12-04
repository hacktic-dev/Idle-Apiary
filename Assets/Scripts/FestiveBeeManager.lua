--!Type(Module)

poolSize = 0 -- client/server
spawnRate = 0 -- client/server

isBeeSpawned = false -- client
spawnedBee = nil -- client

beeCountToRemoveFromPool = 0 -- server
beeCountCaughtPerPlayer = nil -- server
festiveLeaderboard = nil -- server

notifyFestiveBeeCaught = Event.new("NotifyFestiveBeeCaught")

--!SerializeField
local FestiveBee : GameObject = nil

local MIN_SPAWN_DISTANCE = 50 -- Minimum distance from player to spawn a bee
local MIN_CAPTURE_DISTANCE = 4.5 -- Minimum distance from player to spawn a bee
local MAX_SPAWN_DISTANCE = 135 -- Maximum distance from player to spawn a bee
local DESPAWN_DISTANCE = 140 -- Distance beyond which the bee despawns
local MAX_BEES = 21 -- Maximum number of bees allowed

wildBeeManager = require("WildBeeManager")
playerManager = require("PlayerManager")

function self:ServerAwake()
    spawnRate = NumberValue.new("FestiveBeeSpawnRate", 0)
    poolSize = IntValue.new("FestiveBeePool", 0)

    RetrieveFestiveBeePool()
    UpdateFestiveLeaderboard()

    Timer.new(30, function() RetrieveFestiveBeePool() end, true)

    Timer.new(30, function() UpdateFestiveLeaderboard() end, true)

    notifyFestiveBeeCaught:Connect(function(player)
        beeCountToRemoveFromPool = beeCountToRemoveFromPool + 1
        poolSize.value = poolSize.value - 1

        if beeCountCaughtPerPlayer == nil then
            beeCountCaughtPerPlayer = {}
        end

        if beeCountCaughtPerPlayer[player.name] == nil then
            beeCountCaughtPerPlayer[player.name] = 1
        else
            beeCountCaughtPerPlayer[player.name] = beeCountCaughtPerPlayer[player.name] + 1
        end
    end)
end

function self:ClientAwake()
    Timer.new(1, function() TrySpawnFestiveBee() end, true)
    spawnRate = NumberValue.new("FestiveBeeSpawnRate", 0)
    poolSize = IntValue.new("FestiveBeePool", 0)
end

-- Server
function RetrieveFestiveBeePool()
    Storage.GetValue("FestiveBeePool", function(pool, errorCode)
    if errorCode ~= 0 then
        print("Error: couldn't get festive bee pool")
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

    Storage.SetValue("FestiveBeePool", pool, function(errorCode) if not errorCode == 0 then print("Error: Festive bee pool update failed!") end end)
    end)

end

function UpdateFestiveLeaderboard()
    Storage.GetValue("FestiveLeaderboard", function(leaderboard, errorCode)
        if errorCode ~= 0 then
            print("Error: couldn't get festive leaderboard")
            return
        end

        if leaderboard == nil then
            leaderboard = {}
        end

        if beeCountCaughtPerPlayer ~= nil then
            for player, count in ipairs(beeCountCaughtPerPlayer) do
                if leaderboard[player] == nil then
                    leaderboard[player] = count
                else
                    leaderboard[player] = leaderboard[player] + count
                end
            end
        end

        beeCountCaughtPerPlayer = {}

        Storage.SetValue("FestiveLeaderboard", leaderboard, function(errorCode) if not errorCode == 0 then print("Error: Festive leaderboard update failed!") end end)

        local sortableArray = {}
        for key, value in pairs(leaderboard) do
            table.insert(sortableArray, {key = key, value = value})
        end

        -- Step 2: Sort the array by the value field
        table.sort(sortableArray, function(a, b)
            return a.value < b.value -- Sort in ascending order
        end)

        festiveLeaderboard = {}
        for _, pair in ipairs(sortableArray) do
            festiveLeaderboard[pair.key] = pair.value
        end

    end)  
end

-- Client
function TrySpawnFestiveBee()

    print(poolSize.value)

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

    spawnedBee = Object.Instantiate(FestiveBee)
    spawnedBee.transform.position = spawnPosition
    spawnedBee:GetComponent(BeeWandererScript).SetSpawnPosition(spawnPosition)

    table.insert(wildBeeManager.wildBees, { bee = spawnedBee, speciesName = "Festive Bee", player = client.localPlayer })

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
    playerManager.GiveBee("Festive Bee", true)

    -- Remove the bee from the wild bees list and despawn it
    despawnWildBee(bee)

    print("Bee captured and moved to apiary for player: " .. client.localPlayer.name)
    wildBeeManager.notifyCaptureSucceeded:Fire("Festive Bee")
    notifyFestiveBeeCaught:FireServer()
end

function self:Update()
    if spawnedBee ~= nil and ((spawnedBee.transform.position - client.localPlayer.character:GetComponent(Transform).position).magnitude > DESPAWN_DISTANCE) then
        despawnWildBee(bee)
    end
end