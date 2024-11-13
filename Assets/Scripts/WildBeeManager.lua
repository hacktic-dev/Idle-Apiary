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
local IridescentBeePrefab : GameObject = nil
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
    { prefab = CommonBeePrefab, name = "Common Bee", spawnFactor = 275 },
    { prefab = StoneBeePrefab, name = "Stone Bee", spawnFactor = 250 },
    { prefab = ForestBeePrefab, name = "Forest Bee", spawnFactor = 250 },
    { prefab = AquaticBeePrefab, name = "Aquatic Bee", spawnFactor = 60 },
    { prefab = GiantBeePrefab, name = "Giant Bee", spawnFactor = 48 },
    { prefab = SilverBeePrefab, name = "Silver Bee", spawnFactor = 28 },

    -- Silver Set
    { prefab = MuddyBeePrefab, name = "Muddy Bee", spawnFactor = 40 },
    { prefab = FrigidBeePrefab, name = "Frigid Bee", spawnFactor = 38 },
    { prefab = SteelBeePrefab, name = "Steel Bee", spawnFactor = 38 },
    { prefab = MagmaBeePrefab, name = "Magma Bee", spawnFactor = 15 },
    { prefab = GhostlyBeePrefab, name = "Ghostly Bee", spawnFactor = 13 },
    { prefab = IridescentBeePrefab, name = "Iridescent Bee", spawnFactor = 7 },

    -- Gold Set
    { prefab = SandyBeePrefab, name = "Sandy Bee", spawnFactor = 12 },
    { prefab = AutumnalBeePrefab, name = "Autumnal Bee", spawnFactor = 9 },
    { prefab = PetalBeePrefab, name = "Petal Bee", spawnFactor = 9 },
    { prefab = GalacticBeePrefab, name = "Galactic Bee", spawnFactor = 6 },
    { prefab = RadiantBeePrefab, name = "Radiant Bee", spawnFactor = 4 },
    { prefab = RainbowBeePrefab, name = "Rainbow Bee", spawnFactor = 2 }
}


-- Define bee species data with additional properties: honey generation rate, sell price, and time to grow up
beeData = {
    -- Bronze Set - 50 Honey to Purchase
    ["Common Bee"] = { honeyRate = 8, sellPrice = 50, growTime = 60, rarity = "Common", set = "Bronze Set" },
    ["Stone Bee"] = { honeyRate = 10, sellPrice = 60, growTime = 60, rarity = "Common", set = "Bronze Set" },
    ["Forest Bee"] = { honeyRate = 10, sellPrice = 60, growTime = 60, rarity = "Common", set = "Bronze Set" },
    ["Aquatic Bee"] = { honeyRate = 14, sellPrice = 80, growTime = 120, rarity = "Uncommon", set = "Bronze Set" },
    ["Giant Bee"] = { honeyRate = 16, sellPrice = 80, growTime = 120, rarity = "Uncommon", set = "Bronze Set" },
    ["Silver Bee"] = { honeyRate = 20, sellPrice = 120, growTime = 300, rarity = "Rare", set = "Bronze Set" },

    -- Silver Set - 250 Honey to Purchase
    ["Muddy Bee"] = { honeyRate = 14, sellPrice = 120, growTime = 60, rarity = "Uncommon", set = "Silver Set" },
    ["Frigid Bee"] = { honeyRate = 16, sellPrice = 130, growTime = 60, rarity = "Uncommon", set = "Silver Set" },
    ["Steel Bee"] = { honeyRate = 16, sellPrice = 130, growTime = 60, rarity = "Uncommon", set = "Silver Set" },
    ["Magma Bee"] = { honeyRate = 24, sellPrice = 200, growTime = 120, rarity = "Rare", set = "Silver Set" },
    ["Ghostly Bee"] = { honeyRate = 24, sellPrice = 220, growTime = 120, rarity = "Rare", set = "Silver Set" },
    ["Iridescent Bee"] = { honeyRate = 30, sellPrice = 300, growTime = 300, rarity = "Epic", set = "Silver Set" },

    -- Gold Set - 1250 Honey to Purchase
    ["Sandy Bee"] = { honeyRate = 26, sellPrice = 300, growTime = 60, rarity = "Rare", set = "Gold Set" },
    ["Autumnal Bee"] = { honeyRate = 28, sellPrice = 400, growTime = 60, rarity = "Rare", set = "Gold Set" },
    ["Petal Bee"] = { honeyRate = 28, sellPrice = 500, growTime = 60, rarity = "Rare", set = "Gold Set" },
    ["Galactic Bee"] = { honeyRate = 34, sellPrice = 800, growTime = 120, rarity = "Epic", set = "Gold Set" },
    ["Radiant Bee"] = { honeyRate = 38, sellPrice = 1000, growTime = 120, rarity = "Epic", set = "Gold Set" },
    ["Rainbow Bee"] = { honeyRate = 50, sellPrice = 1500, growTime = 300, rarity = "Legendary", set = "Gold Set" }
}


local MIN_SPAWN_DISTANCE = 45 -- Minimum distance from player to spawn a bee
local MIN_CAPTURE_DISTANCE = 4.5 -- Minimum distance from player to spawn a bee
local MAX_SPAWN_DISTANCE = 125 -- Maximum distance from player to spawn a bee
local DESPAWN_DISTANCE = 130 -- Distance beyond which the bee despawns
local MAX_BEES = 20 -- Maximum number of bees allowed

local beeSpawnInterval = 0.1 -- Time in seconds between bee spawn attempts

beeCaptureRequest = Event.new("BeeCaptureRequest")
notifyCaptureFailed = Event.new("NotifyCaptureFailed")
notifyCaptureSucceeded = Event.new("NotifyCaptureSucceeded")

-- Table to track spawned wild bees
wildBees = {}

function getSet(speciesName)
    local species = beeData[speciesName]
    if species then
        return species.set
    else
        print("Species not found: " .. speciesName)
        return nil
    end
end

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
    local beeCount = playerManager.clientBeeCount
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