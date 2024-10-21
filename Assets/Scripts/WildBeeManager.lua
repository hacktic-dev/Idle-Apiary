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
    { prefab = AquaticBeePrefab, name = "Aquatic Bee", spawnFactor = 12 } ,
    { prefab = GiantBeePrefab, name = "Giant Bee", spawnFactor = 10 } ,
    { prefab = SilverBeePrefab, name = "Silver Bee", spawnFactor = 5 } 
}

local MIN_SPAWN_DISTANCE = 45 -- Minimum distance from player to spawn a bee
local MIN_CAPTURE_DISTANCE = 4.5 -- Minimum distance from player to spawn a bee
local MAX_SPAWN_DISTANCE = 125 -- Maximum distance from player to spawn a bee
local DESPAWN_DISTANCE = 130 -- Distance beyond which the bee despawns
local MAX_BEES = 14 -- Maximum number of bees allowed

local beeSpawnInterval = 0.1 -- Time in seconds between bee spawn attempts

beeCaptureRequest = Event.new("BeeCaptureRequest")
notifyCaptureFailed = Event.new("NotifyCaptureFailed")
notifyCaptureSucceeded = Event.new("NotifyCaptureSucceeded")

-- Table to track spawned wild bees
wildBees = {}

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
function isPlayerNearBee(player, bee)
    local playerPosition = player.character:GetComponent(Transform).position
    local beePosition = bee.transform.position

    local distance = (beePosition - playerPosition).magnitude
    return distance < MIN_CAPTURE_DISTANCE
end

-- Function to handle bee capture when the player presses the capture button
function captureBee(bee, speciesName)
    -- Check if the player has a net available
    local netsAvailable = playerManager.players[client.localPlayer].Nets.value

    if netsAvailable > 0 then
        -- Decrement the player's net count
        playerManager.IncrementStat("Nets", -1)

        -- Give the captured bee species to the player
        playerManager.GiveBee(speciesName)

        -- Remove the bee from the wild bees list and despawn it
        despawnWildBee(bee)

        print("Bee captured and moved to apiary for player: " .. client.localPlayer.name)
        notifyCaptureSucceeded:Fire(speciesName)
    else
        print("No nets available for player: " .. client.localPlayer.name)
        notifyCaptureFailed:Fire()
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