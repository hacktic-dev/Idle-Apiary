--!Type(Module)

local playerManager = require("PlayerManager")

--!SerializeField
local CommonBee : GameObject = nil
--!SerializeField
local StoneBee : GameObject = nil
--!SerializeField
local ForestBee : GameObject = nil
--!SerializeField
local AquaticBee : GameObject = nil
--!SerializeField
local GiantBee : GameObject = nil
--!SerializeField
local SilverBee : GameObject = nil

-- Server-side table to track which bees belong to which player
local playerBees = {}

local bees = {}

updateBeePositionRequest = Event.new("UpdateBeePosition")
addNewBeeRequest = Event.new("AddNewBee")
removeBeeRequest = Event.new("RemoveBee")

function LookupBeeEarnRate(Bee)
    if Bee == "Common Bee" then
        return 6
    elseif Bee == "Stone Bee" then
        return 8
    elseif Bee == "Forest Bee" then
        return 8
    elseif Bee == "Aquatic Bee" then
        return 14
    elseif Bee == "Giant Bee" then
        return 16
    elseif Bee == "Silver Bee" then
        return 22
    elseif Bee == "Muddy Bee" then
        return 16
    elseif Bee == "Frigid Bee" then
        return 18
    elseif Bee == "Steel Bee" then
        return 18
    elseif Bee == "Magma Bee" then
        return 26
    elseif Bee == "Ghostly Bee" then
        return 28
    elseif Bee == "Golden Bee" then
        return 44
    else
        return 0
        -- todo - add other bees
    end
end

-- Function to generate unique ID for bees
local function generateBeeID()
    return tostring(math.random(100000, 999999)) .. "-" .. tostring(os.time())
end

function RemoveAllPlayerBees(player)
    -- Check if the player has any bees stored
    if playerBees[player] then
        -- Loop through the player's bees
        for _, beeData in ipairs(playerBees[player]) do
            local beeID = beeData.id
            
            -- Fire an event to all clients to remove this bee by its ID
            removeBeeRequest:FireAllClients(beeID)
        end

        -- Clear the bees from the server's data structure for this player
        playerBees[player] = nil
        
        print("All bees removed for player: " .. player.name)
    else
        print("No bees to remove for player: " .. player.name)
    end
end

-- Function to spawn all bees for the specific player's client
function SpawnAllBeesForPlayer(player)
    -- Loop through all players and their bees
    for owner, beeList in pairs(playerBees) do
        for _, beeData in ipairs(beeList) do
            -- Fire an event to the specific player to spawn each bee with its species, ID, and location
            addNewBeeRequest:FireClient(player, beeData.species, beeData.id, beeData.location)
        end
    end
end

function SpawnBee(player, species, location)
    -- Generate a unique ID for the new bee
    local beeID = generateBeeID()
    
    -- Add bee to player's list of bees on the server with full data (id, species, location)
    if not playerBees[player] then
        playerBees[player] = {}
    end

    table.insert(playerBees[player], {id = beeID, species = species, location = Vector3.new(location.x, location.y, location.z)})

    -- Fire the client event to spawn this bee for all clients
    addNewBeeRequest:FireAllClients(species, beeID, Vector3.new(location.x, location.y, location.z))
end

-- Client side functionality

function self:ClientAwake()
    updateBeePositionRequest:Connect(function(id, position)
        if bees[id] then
            bees[id].transform.position = position
        end
    end)

    addNewBeeRequest:Connect(function(species, beeID, position)
        local Bee = nil
        if species == "Common Bee" then
            Bee = CommonBee
        elseif species == "Stone Bee" then
            Bee = StoneBee
        elseif species == "Forest Bee" then
            Bee = ForestBee
        elseif species == "Aquatic Bee" then
            Bee = AquaticBee
        elseif species == "Giant Bee" then
            Bee = GiantBee
        elseif species == "Silver Bee" then
            Bee = SilverBee
        end

        if Bee then
            -- Instantiate the bee
            local newBee = Object.Instantiate(Bee)

            -- Store the bee on the client, indexed by its ID
            bees[beeID] = newBee

            -- Set the position with a slight random offset
            newBee.transform.position = position + Vector3.new(math.random() + math.random(-8, 7), 0, math.random() + math.random(-8, 7))
            
            -- Initialize bee behavior by setting its spawn position
            newBee:GetComponent(BeeWandererScript).SetSpawnPosition(position)
        end
    end)

    removeBeeRequest:Connect(function(beeID)
        -- Check if the bee exists on the client by its ID
        if bees[beeID] then
            -- Destroy the bee object and remove it from the bees table
            Object.Destroy(bees[beeID])
            bees[beeID] = nil
        end
    end)
end