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

function SpawnBee(player, species, location, beeID, isAdult, growTimeRemaining, totalGrowTime)
    -- Add bee to player's list of bees on the server with full data (id, species, location)
    if not playerBees[player] then
        playerBees[player] = {}
    end

    table.insert(playerBees[player], {id = beeID, species = species, location = Vector3.new(location.x, location.y, location.z)})

    -- Fire the client event to spawn this bee for all clients
    addNewBeeRequest:FireAllClients(species, beeID, Vector3.new(location.x, location.y, location.z), isAdult, growTimeRemaining, totalGrowTime)
end

-- Client side functionality

function self:ClientAwake()
    updateBeePositionRequest:Connect(function(id, position)
        if bees[id] then
            bees[id].transform.position = position
        end
    end)

    addNewBeeRequest:Connect(function(species, beeID, position, isAdult, growTimeRemaining, totalGrowTime)
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

        print("Spawning bee " .. species .. " on client")

        if Bee then
            -- Instantiate the bee
            local newBee = Object.Instantiate(Bee)

            -- Store the bee on the client, indexed by its ID
            bees[beeID] = newBee

            if(isAdult == false) then
                newBee.transform.localScale = Vector3.new(0.5,0.5,0.5)
                newBee:GetComponent(TaskMeter).SetVisible(true)
                newBee:GetComponent(TaskMeter).StartMeter(totalGrowTime, 0.1, totalGrowTime-growTimeRemaining)
                newBee:GetComponent(BeeCountdown).Enable()
                newBee:GetComponent(BeeCountdown).SetTimeRemaining(growTimeRemaining)
                newBee:GetComponent(BeeCountdown).SetId(beeID)
            else
                newBee.GetComponent(TaskMeter).SetVisible(false)
            end

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