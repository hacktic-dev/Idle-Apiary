--!Type(Module)

-- Import required managers
local playerManager = require("PlayerManager")
local beeObjectManager = require("BeeObjectManager")

--!SerializeField
local CommonBeePrefab : GameObject = nil
--!SerializeField
local StoneBeePrefab : GameObject = nil
--!SerializeField
local ForestBeePrefab : GameObject = nil
--!SerializeField
local AquaticBeePrefab : GameObject = nil
--!SerializeField
local GiantBeePrefab : GameObject = nil
--!SerializeField
local SilverBeePrefab : GameObject = nil

-- Bee spawning parameters
local beeSpecies = {
    { prefab = CommonBeePrefab, name = "Common Bee", spawnFactor = 50 },
    { prefab = StoneBeePrefab, name = "Stone Bee", spawnFactor = 45 }, 
    { prefab = ForestBeePrefab, name = "Forest Bee", spawnFactor = 45 } ,
    { prefab = AquaticBeePrefab, name = "Aquatic Bee", spawnFactor = 15 } ,
    { prefab = GiantBeePrefab, name = "Giant Bee", spawnFactor = 10 } ,
    { prefab = SilverBeePrefab, name = "Silver Bee", spawnFactor = 5 } 
}

local MIN_SPAWN_DISTANCE = 40 -- Minimum distance from player to spawn a bee
local MAX_SPAWN_DISTANCE = 70 -- Maximum distance from player to spawn a bee
local DESPAWN_DISTANCE = 85 -- Distance beyond which the bee despawns
local MAX_BEES = 8 -- Maximum number of bees allowed

local beeSpawnInterval = 0.1 -- Time in seconds between bee spawn attempts

-- Table to track spawned wild bees
local wildBees = {}

-- Function to calculate total spawn factor
local function getTotalSpawnFactor()
    local totalFactor = 0
    for _, species in ipairs(beeSpecies) do
        totalFactor = totalFactor + species.spawnFactor
    end
    return totalFactor
end

-- Function to choose a bee species based on spawn factors
local function chooseBeeSpecies()
    local totalSpawnFactor = getTotalSpawnFactor()
    local rand = math.random() * totalSpawnFactor
    local cumulativeFactor = 0

    for _, species in ipairs(beeSpecies) do
        cumulativeFactor = cumulativeFactor + species.spawnFactor
        if rand <= cumulativeFactor then
            return species
        end
    end

    -- Fallback in case no species is selected (this shouldn't happen)
    return beeSpecies[1]
end

-- Function to spawn a wild bee around the player's location
local function spawnWildBee(player)

    if #wildBees >= MAX_BEES then
        --print("Max number of wild bees reached. No new bees will be spawned.")
        return
    end

    local playerPosition = player.character:GetComponent(Transform).position

    -- Determine the random distance and direction
    local randomDistance = MIN_SPAWN_DISTANCE + math.random() * (MAX_SPAWN_DISTANCE - MIN_SPAWN_DISTANCE)
    local randomDirection = Vector3.new((math.random()-0.5)*2, 0, (math.random()-0.5)*2).normalized

    local spawnPosition = playerPosition + randomDirection * randomDistance

    -- Choose a bee species based on the calculated probabilities
    local selectedBeeSpecies = chooseBeeSpecies()

    -- Spawn the bee on the client
    local newBee = Object.Instantiate(selectedBeeSpecies.prefab)
    newBee.transform.position = spawnPosition
    newBee:GetComponent(BeeWandererScript).SetSpawnPosition(spawnPosition)
    table.insert(wildBees, { bee = newBee, speciesName = selectedBeeSpecies.name, player = player })

    print("Spawned wild bee (" .. selectedBeeSpecies.name .. ") at at a distance of " .. randomDistance .. " and a position: " .. tostring(spawnPosition))
end

-- Function to despawn a wild bee
local function despawnWildBee(bee)
    -- Destroy the bee object
    Object.Destroy(bee)
    for i, data in ipairs(wildBees) do
        if data.bee == bee then
            table.remove(wildBees, i)
            break
        end
    end

    print("Wild bee despawned.")
end

-- Function to check if a player is near a bee (for UI purposes)
local function isPlayerNearBee(player, bee)
    local playerPosition = player.character:GetComponent(Transform).position
    local beePosition = bee.transform.position

    local distance = (beePosition - playerPosition).magnitude
    return distance < MIN_SPAWN_DISTANCE
end

-- Function to handle bee capture when the player presses the capture button
local function captureBee(player, bee, speciesName)
    -- Check if the player has a net available
    local netsAvailable = playerManager.players[player].Nets.value

    if netsAvailable > 0 then
        -- Decrement the player's net count
        playerManager.IncrementStat(player, "Nets", -1)

        -- Give the captured bee species to the player
        playerManager.GiveBee(player, speciesName)

        -- Remove the bee from the wild bees list and despawn it
        despawnWildBee(bee)

        print("Bee captured and moved to apiary for player: " .. player.name)
    else
        print("No nets available for player: " .. player.name)
    end
end

-- Function to display the capture UI when the player is near a wild bee
local function showCaptureUI(player)
    -- Find the nearest bee
    for _, data in ipairs(wildBees) do
        local bee = data.bee
        local speciesName = data.speciesName

        if isPlayerNearBee(player, bee) then
            -- Show the capture button UI
            -- Assuming a function `showCaptureButton` that takes player and bee data
            showCaptureButton(player, function()
                captureBee(player, bee, speciesName)
            end)
        end
    end
end

-- Periodically spawn wild bees for the player
local function periodicBeeSpawning(player)
    Timer.new(beeSpawnInterval, function()
        spawnWildBee(player)
    end, true)
end

function self:ClientAwake()
    periodicBeeSpawning(client.localPlayer)
end

function self:Update()
    for _, data in ipairs(wildBees) do
        local bee = data.bee

        if((bee.transform.position - client.localPlayer.character:GetComponent(Transform).position).magnitude > DESPAWN_DISTANCE) then
            despawnWildBee(bee)
        end
    end
end