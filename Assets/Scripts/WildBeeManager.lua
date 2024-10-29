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
--!SerializeField
local MuddyBeePrefab : GameObject = nil
--!SerializeField
local FrigidBeePrefab : GameObject = nil
--!SerializeField
local SteelBeePrefab : GameObject = nil
--!SerializeField
local MagmaBeePrefab : GameObject = nil
--!SerializeField
local GhostlyBeePrefab : GameObject = nil
--!SerializeField
local StormBeePrefab : GameObject = nil
--!SerializeField
local SandyBeePrefab : GameObject = nil
--!SerializeField
local AutumnalBeePrefab : GameObject = nil
--!SerializeField
local PetalBeePrefab : GameObject = nil
--!SerializeField
local GalacticBeePrefab : GameObject = nil
--!SerializeField
local RadiantBeePrefab : GameObject = nil
--!SerializeField
local RainbowBeePrefab : GameObject = nil

-- Bee spawning parameters
local beeSpecies = {
    -- Bronze Set
    { prefab = CommonBeePrefab, name = "Common Bee", spawnFactor = 300 },
    { prefab = StoneBeePrefab, name = "Stone Bee", spawnFactor = 270 },
    { prefab = ForestBeePrefab, name = "Forest Bee", spawnFactor = 270 },
    { prefab = AquaticBeePrefab, name = "Aquatic Bee", spawnFactor = 80 },
    { prefab = GiantBeePrefab, name = "Giant Bee", spawnFactor = 75 },
    { prefab = SilverBeePrefab, name = "Silver Bee", spawnFactor = 40 },

    -- Silver Set
    { prefab = MuddyBeePrefab, name = "Muddy Bee", spawnFactor = 58 },
    { prefab = FrigidBeePrefab, name = "Frigid Bee", spawnFactor = 56 },
    { prefab = SteelBeePrefab, name = "Steel Bee", spawnFactor = 54 },
    { prefab = MagmaBeePrefab, name = "Magma Bee", spawnFactor = 26 },
    { prefab = GhostlyBeePrefab, name = "Ghostly Bee", spawnFactor = 22 },
    { prefab = StormBeePrefab, name = "Storm Bee", spawnFactor = 8 },

    -- Gold Set
    { prefab = SandyBeePrefab, name = "Sandy Bee", spawnFactor = 16 },
    { prefab = AutumnalBeePrefab, name = "Autumnal Bee", spawnFactor = 14 },
    { prefab = PetalBeePrefab, name = "Petal Bee", spawnFactor = 14 },
    { prefab = GalacticBeePrefab, name = "Galactic Bee", spawnFactor = 8 },
    { prefab = RadiantBeePrefab, name = "Radiant Bee", spawnFactor = 6 },
    { prefab = RainbowBeePrefab, name = "Rainbow Bee", spawnFactor = 2 }
}


-- Define bee species data with additional properties: honey generation rate, sell price, and time to grow up
local beeData = {
    -- Bronze Set - 50 Honey to Purchase
    ["Common Bee"] = { honeyRate = 6, sellPrice = 50, growTime = 60, rarity = "Common" },
    ["Stone Bee"] = { honeyRate = 8, sellPrice = 60, growTime = 60, rarity = "Common" },
    ["Forest Bee"] = { honeyRate = 8, sellPrice = 60, growTime = 60, rarity = "Common" },
    ["Aquatic Bee"] = { honeyRate = 14, sellPrice = 100, growTime = 120, rarity = "Uncommon" },
    ["Giant Bee"] = { honeyRate = 16, sellPrice = 110, growTime = 120, rarity = "Uncommon" },
    ["Silver Bee"] = { honeyRate = 22, sellPrice = 180, growTime = 300, rarity = "Rare" },

    -- Silver Set - 250 Honey to Purchase
    ["Muddy Bee"] = { honeyRate = 18, sellPrice = 250, growTime = 60, rarity = "Uncommon" },
    ["Frigid Bee"] = { honeyRate = 20, sellPrice = 270, growTime = 60, rarity = "Uncommon" },
    ["Steel Bee"] = { honeyRate = 20, sellPrice = 270, growTime = 60, rarity = "Uncommon" },
    ["Magma Bee"] = { honeyRate = 28, sellPrice = 360, growTime = 120, rarity = "Rare" },
    ["Ghostly Bee"] = { honeyRate = 30, sellPrice = 380, growTime = 120, rarity = "Rare" },
    ["Storm Bee"] = { honeyRate = 46, sellPrice = 500, growTime = 300, rarity = "Epic" },

    -- Gold Set - 1250 Honey to Purchase
    ["Sandy Bee"] = { honeyRate = 36, sellPrice = 1250, growTime = 60, rarity = "Rare" },
    ["Autumnal Bee"] = { honeyRate = 38, sellPrice = 1300, growTime = 60, rarity = "Rare" },
    ["Petal Bee"] = { honeyRate = 40, sellPrice = 1300, growTime = 60, rarity = "Rare" },
    ["Galactic Bee"] = { honeyRate = 56, sellPrice = 1500, growTime = 120, rarity = "Epic" },
    ["Radiant Bee"] = { honeyRate = 58, sellPrice = 1500, growTime = 120, rarity = "Epic" },
    ["Rainbow Bee"] = { honeyRate = 70, sellPrice = 2000, growTime = 300, rarity = "Legendary" }
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

-- Function to get honey generation rate based on species name
function getHoneyRate(speciesName)
    local species = beeData[speciesName]
    if species then
        return species.honeyRate
    else
        print("Species not found: " .. speciesName)
        return nil
    end
end

-- Function to get sell price based on species name
function getSellPrice(speciesName)
    local species = beeData[speciesName]
    if species then
        return species.sellPrice
    else
        print("Species not found: " .. speciesName)
        return nil
    end
end

-- Function to get time to grow up based on species name
function getGrowTime(speciesName)
    local species = beeData[speciesName]
    if species then
        return species.growTime
    else
        print("Species not found: " .. speciesName)
        return nil
    end
end

function getRarity(speciesName)
    local species = beeData[speciesName]
    if species then
        return species.rarity
    else
        print("Species not found: " .. speciesName)
        return nil
    end
end

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
    local beeCount = playerManager.players[client.localPlayer].Bees.value
    print("Bee count: " .. beeCount)

    if netsAvailable == 0 then
        print("No nets available for player: " .. client.localPlayer.name)
        notifyCaptureFailed:Fire(1)
        return
    elseif beeCount > 11 then
        print("Max bees owned: " .. client.localPlayer.name)
        notifyCaptureFailed:Fire(2)
        return
    end

    -- Decrement the player's net count
    playerManager.IncrementStat("Nets", -1)

    -- Give the captured bee species to the player
    playerManager.GiveBee(speciesName, true)

    -- Remove the bee from the wild bees list and despawn it
    despawnWildBee(bee)

    print("Bee captured and moved to apiary for player: " .. client.localPlayer.name)
    notifyCaptureSucceeded:Fire(speciesName)

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