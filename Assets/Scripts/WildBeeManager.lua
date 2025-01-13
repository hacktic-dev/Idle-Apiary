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
local IndustrialBeePrefab : GameObject = nil
--!SerializeField
local PearlescentBeePrefab : GameObject = nil
--!SerializeField
local HypnoticBeePrefab : GameObject = nil
--!SerializeField
local RadiantBeePrefab : GameObject = nil
--!SerializeField
local ShadowBeePrefab : GameObject = nil
--!SerializeField
local PrismaticBeePrefab : GameObject = nil
--!SerializeField
local AstralBeePrefab : GameObject = nil
--!SerializeField
local RainbowBeePrefab : GameObject = nil
--!SerializeField
local MeadowBeePrefab : GameObject = nil
--!SerializeField
local BronzeBeePrefab : GameObject = nil
--!SerializeField
local OceanicBeePrefab : GameObject = nil
--!SerializeField
local RubyBeePrefab : GameObject = nil
--!SerializeField
local CamoBeePrefab : GameObject = nil
--!SerializeField
local CrystalBeePrefab : GameObject = nil
--!SerializeField
local TechnoBeePrefab : GameObject = nil
--!SerializeField
local PsychedelicBeePrefab : GameObject = nil


local beeSpecies = {
    -- Bronze Set
    { prefab = CommonBeePrefab, name = "Common Bee", spawnFactor_0 = 300, spawnFactor_1 = 175, spawnFactor_2 = 100, spawnFactor_3 = 60 },
    { prefab = StoneBeePrefab, name = "Stone Bee", spawnFactor_0 = 275, spawnFactor_1 = 160, spawnFactor_2 = 88, spawnFactor_3 = 55 },
    { prefab = ForestBeePrefab, name = "Forest Bee", spawnFactor_0 = 275, spawnFactor_1 = 160, spawnFactor_2 = 88, spawnFactor_3 = 55 },
    { prefab = AquaticBeePrefab, name = "Aquatic Bee", spawnFactor_0 = 70, spawnFactor_1 = 60, spawnFactor_2 = 35, spawnFactor_3 = 25 },
    { prefab = GiantBeePrefab, name = "Giant Bee", spawnFactor_0 = 60, spawnFactor_1 = 55, spawnFactor_2 = 30, spawnFactor_3 = 20 },
    { prefab = SilverBeePrefab, name = "Silver Bee", spawnFactor_0 = 30, spawnFactor_1 = 30, spawnFactor_2 = 20, spawnFactor_3 = 15 },
    { prefab = MeadowBeePrefab, name = "Meadow Bee", spawnFactor_0 = 275, spawnFactor_1 = 160, spawnFactor_2 = 88, spawnFactor_3 = 55 },
    { prefab = BronzeBeePrefab, name = "Bronze Bee", spawnFactor_0 = 60, spawnFactor_1 = 55, spawnFactor_2 = 30, spawnFactor_3 = 20 },

    -- Silver Set
    { prefab = MuddyBeePrefab, name = "Muddy Bee", spawnFactor_0 = 40, spawnFactor_1 = 55, spawnFactor_2 = 70, spawnFactor_3 = 90 },
    { prefab = FrigidBeePrefab, name = "Frigid Bee", spawnFactor_0 = 38, spawnFactor_1 = 50, spawnFactor_2 = 65, spawnFactor_3 = 85 },
    { prefab = SteelBeePrefab, name = "Steel Bee", spawnFactor_0 = 38, spawnFactor_1 = 50, spawnFactor_2 = 65, spawnFactor_3 = 85 },
    { prefab = MagmaBeePrefab, name = "Magma Bee", spawnFactor_0 = 15, spawnFactor_1 = 30, spawnFactor_2 = 55, spawnFactor_3 = 70 },
    { prefab = GhostlyBeePrefab, name = "Ghostly Bee", spawnFactor_0 = 13, spawnFactor_1 = 30, spawnFactor_2 = 40, spawnFactor_3 = 60 },
    { prefab = IridescentBeePrefab, name = "Iridescent Bee", spawnFactor_0 = 7, spawnFactor_1 = 15, spawnFactor_2 = 30, spawnFactor_3 = 45 },
    { prefab = OceanicBeePrefab, name = "Oceanic Bee", spawnFactor_0 = 38, spawnFactor_1 =50, spawnFactor_2 = 65, spawnFactor_3 = 85 },
    { prefab = RubyBeePrefab, name = "Ruby Bee", spawnFactor_0 = 13, spawnFactor_1 = 30, spawnFactor_2 = 40, spawnFactor_3 = 60 },

    -- Gold Set
    { prefab = SandyBeePrefab, name = "Sandy Bee", spawnFactor_0 = 12, spawnFactor_1 = 20, spawnFactor_2 = 38, spawnFactor_3 = 55 },
    { prefab = AutumnalBeePrefab, name = "Autumnal Bee", spawnFactor_0 = 9, spawnFactor_1 = 18, spawnFactor_2 = 38, spawnFactor_3 = 50 },
    { prefab = PetalBeePrefab, name = "Petal Bee", spawnFactor_0 = 9, spawnFactor_1 = 15, spawnFactor_2 = 33, spawnFactor_3 = 45 },
    { prefab = GalacticBeePrefab, name = "Galactic Bee", spawnFactor_0 = 6, spawnFactor_1 = 12, spawnFactor_2 = 22, spawnFactor_3 = 33 },
    { prefab = IndustrialBeePrefab, name = "Industrial Bee", spawnFactor_0 = 4, spawnFactor_1 = 8, spawnFactor_2 = 18, spawnFactor_3 = 30 },
    { prefab = PearlescentBeePrefab, name = "Pearlescent Bee", spawnFactor_0 = 2, spawnFactor_1 = 4, spawnFactor_2 = 11, spawnFactor_3 = 20 },
    { prefab = CamoBeePrefab, name = "Camo Bee", spawnFactor_0 = 9, spawnFactor_1 = 18, spawnFactor_2 = 38, spawnFactor_3 = 50 },
    { prefab = CrystalBeePrefab, name = "Crystal Bee", spawnFactor_0 = 4, spawnFactor_1 = 8, spawnFactor_2 = 18, spawnFactor_3 = 30 },
    -- Platinum Set
    { prefab = HypnoticBeePrefab, name = "Hypnotic Bee", spawnFactor_0 = 0, spawnFactor_1 = 6, spawnFactor_2 = 18, spawnFactor_3 = 30 },
    { prefab = RadiantBeePrefab, name = "Radiant Bee", spawnFactor_0 = 0, spawnFactor_1 = 6, spawnFactor_2 = 16, spawnFactor_3 = 30 },
    { prefab = ShadowBeePrefab, name = "Shadow Bee", spawnFactor_0 = 0, spawnFactor_1 = 6, spawnFactor_2 = 16, spawnFactor_3 = 28 },
    { prefab = PrismaticBeePrefab, name = "Prismatic Bee", spawnFactor_0 = 0, spawnFactor_1 = 4, spawnFactor_2 = 10, spawnFactor_3 = 20 },
    { prefab = AstralBeePrefab, name = "Astral Bee", spawnFactor_0 = 0, spawnFactor_1 = 4, spawnFactor_2 = 8, spawnFactor_3 = 18 },
    { prefab = RainbowBeePrefab, name = "Rainbow Bee", spawnFactor_0 = 0, spawnFactor_1 = 2, spawnFactor_2 = 5, spawnFactor_3 = 11 },
    { prefab = TechnoBeePrefab, name = "Techno Bee", spawnFactor_0 = 0, spawnFactor_1 = 6, spawnFactor_2 = 18, spawnFactor_3 = 30 },
    { prefab = PsychedelicBeePrefab, name = "Psychedelic Bee", spawnFactor_0 = 0, spawnFactor_1 = 4, spawnFactor_2 = 10, spawnFactor_3 = 20 },
}



-- Define bee species data with additional properties: honey generation rate, sell price, and time to grow up
beeData = {
    -- Bronze Set - 50 Honey to Purchase
    ["Common Bee"] = { honeyRate = 8, sellPrice = 50, growTime = 40, rarity = "Common", set = "Bronze Set" },
    ["Stone Bee"] = { honeyRate = 10, sellPrice = 60, growTime = 40, rarity = "Common", set = "Bronze Set" },
    ["Forest Bee"] = { honeyRate = 10, sellPrice = 60, growTime = 40, rarity = "Common", set = "Bronze Set" },
    ["Aquatic Bee"] = { honeyRate = 14, sellPrice = 80, growTime = 80, rarity = "Uncommon", set = "Bronze Set" },
    ["Giant Bee"] = { honeyRate = 16, sellPrice = 80, growTime = 80, rarity = "Uncommon", set = "Bronze Set" },
    ["Silver Bee"] = { honeyRate = 20, sellPrice = 120, growTime = 200, rarity = "Rare", set = "Bronze Set" },

    -- Silver Set - 250 Honey to Purchase
    ["Muddy Bee"] = { honeyRate = 14, sellPrice = 120, growTime = 40, rarity = "Uncommon", set = "Silver Set" },
    ["Frigid Bee"] = { honeyRate = 16, sellPrice = 130, growTime = 40, rarity = "Uncommon", set = "Silver Set" },
    ["Steel Bee"] = { honeyRate = 16, sellPrice = 130, growTime = 40, rarity = "Uncommon", set = "Silver Set" },
    ["Magma Bee"] = { honeyRate = 24, sellPrice = 200, growTime = 80, rarity = "Rare", set = "Silver Set" },
    ["Ghostly Bee"] = { honeyRate = 24, sellPrice = 220, growTime = 80, rarity = "Rare", set = "Silver Set" },
    ["Iridescent Bee"] = { honeyRate = 30, sellPrice = 300, growTime = 200, rarity = "Epic", set = "Silver Set" },

    -- Gold Set - 1250 Honey to Purchase
    ["Sandy Bee"] = { honeyRate = 26, sellPrice = 300, growTime = 40, rarity = "Rare", set = "Gold Set" },
    ["Autumnal Bee"] = { honeyRate = 28, sellPrice = 400, growTime = 40, rarity = "Rare", set = "Gold Set" },
    ["Petal Bee"] = { honeyRate = 28, sellPrice = 500, growTime = 40, rarity = "Rare", set = "Gold Set" },
    ["Galactic Bee"] = { honeyRate = 34, sellPrice = 800, growTime = 80, rarity = "Epic", set = "Gold Set" },
    ["Industrial Bee"] = { honeyRate = 38, sellPrice = 1000, growTime = 80, rarity = "Epic", set = "Gold Set" },
    ["Pearlescent Bee"] = { honeyRate = 50, sellPrice = 1500, growTime = 200, rarity = "Legendary", set = "Gold Set" },

    -- Platinum Set - 5000 Honey to Purchase
    ["Hypnotic Bee"] = { honeyRate = 44, sellPrice = 2500, growTime = 40, rarity = "Epic", set = "Platinum Set" },
    ["Radiant Bee"] = { honeyRate = 46, sellPrice = 2800, growTime = 40, rarity = "Epic", set = "Platinum Set" },
    ["Shadow Bee"] = { honeyRate = 48, sellPrice = 3200, growTime = 40, rarity = "Epic", set = "Platinum Set" },
    ["Prismatic Bee"] = { honeyRate = 56, sellPrice = 4000, growTime = 80, rarity = "Legendary", set = "Platinum Set" },
    ["Astral Bee"] = { honeyRate = 60, sellPrice = 4500, growTime = 80, rarity = "Legendary", set = "Platinum Set" },
    ["Rainbow Bee"] = { honeyRate = 80, sellPrice = 6000, growTime = 200, rarity = "Mythical", set = "Platinum Set" },

    ["Festive Bee"] = { honeyRate = 60, sellPrice = "1 Gold", growTime = 200, rarity = "Mythical", set = "Event Bee" },
    ["Romantic Bee"] = { honeyRate = 60, sellPrice = "1 Gold", growTime = 200, rarity = "Mythical", set = "Event Bee" },

    -- 1.3 Update
    ["Meadow Bee"] = { honeyRate = 10, sellPrice = 70, growTime = 40, rarity = "Common", set = "Bronze Set" },
    ["Bronze Bee"] = { honeyRate = 18, sellPrice = 140, growTime = 80, rarity = "Uncommon", set = "Bronze Set" },
    ["Oceanic Bee"] = { honeyRate = 20, sellPrice = 140, growTime = 40, rarity = "Uncommon", set = "Silver Set" },
    ["Ruby Bee"] = { honeyRate = 26, sellPrice = 230, growTime = 80, rarity = "Rare", set = "Silver Set" },
    ["Camo Bee"] = { honeyRate = 30, sellPrice = 600, growTime = 40, rarity = "Rare", set = "Gold Set" },
    ["Crystal Bee"] = { honeyRate = 36, sellPrice = 900, growTime = 80, rarity = "Epic", set = "Gold Set" },
    ["Techno Bee"] = { honeyRate = 46, sellPrice = 2500, growTime = 40, rarity = "Epic", set = "Platinum Set" },
    ["Psychedelic Bee"] = { honeyRate = 58, sellPrice = 4000, growTime = 80, rarity = "Legendary", set = "Platinum Set" }
}


local MIN_SPAWN_DISTANCE = 50 -- Minimum distance from player to spawn a bee
local MIN_CAPTURE_DISTANCE = 4.5 -- Minimum distance from player to spawn a bee
local MAX_SPAWN_DISTANCE = 135 -- Maximum distance from player to spawn a bee
local DESPAWN_DISTANCE = 140 -- Distance beyond which the bee despawns
local MAX_BEES = 21 -- Maximum number of bees allowed

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

    local level = playerManager.GetPlayerSweetScentLevel()

    for _, species in ipairs(beeSpecies) do

        if level == 0 then
            factor = species.spawnFactor_0
        elseif level == 1 then
            factor = species.spawnFactor_1
        elseif level == 2 then
            factor = species.spawnFactor_2
        elseif level >= 3 then
            factor = species.spawnFactor_3
        end

        totalFactor = totalFactor + factor
    end
    return totalFactor
end

-- Function to choose a bee species based on spawn factors
local function chooseBeeSpecies()
    local totalSpawnFactor = getTotalSpawnFactor()
    local rand = math.random() * totalSpawnFactor
    local cumulativeFactor = 0

    local level = playerManager.GetPlayerSweetScentLevel()

    for _, species in ipairs(beeSpecies) do

        if level == 0 then
            factor = species.spawnFactor_0
        elseif level == 1 then
            factor = species.spawnFactor_1
        elseif level == 2 then
            factor = species.spawnFactor_2
        elseif level == 3 then
            factor = species.spawnFactor_3
        end

        cumulativeFactor = cumulativeFactor + factor
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

    -- todo - spawn first based on loc inside area, then check distance

    local spawnPosition
    local playerPosition = player.character:GetComponent(Transform).position

    spawnPosition = Vector3.new(math.random(-115, 115) , 0, math.random(-115, 115))
    distance = Vector3.Distance(playerPosition, spawnPosition)
    if distance < MIN_SPAWN_DISTANCE or distance > MAX_SPAWN_DISTANCE then return end

    -- Choose a bee species based on the calculated probabilities
    local selectedBeeSpecies = chooseBeeSpecies()

    -- Spawn the bee on the client
    local newBee = Object.Instantiate(selectedBeeSpecies.prefab)
    newBee.transform.position = spawnPosition
    newBee:GetComponent(BeeWandererScript).SetSpawnPosition(spawnPosition)
    table.insert(wildBees, { bee = newBee, speciesName = selectedBeeSpecies.name, player = player })

    print("Spawned wild bee (" .. selectedBeeSpecies.name .. ") at position: " .. tostring(spawnPosition))
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
    elseif beeCount + 1 > playerManager.GetPlayerBeeCapacity() then
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

        
        if( bee ~= nil and (bee.transform.position - client.localPlayer.character:GetComponent(Transform).position).magnitude > DESPAWN_DISTANCE) then
            despawnWildBee(bee)
        end
    end
end