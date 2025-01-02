--!Type(Module)

--!Type(Module)

-- ApiaryManager.lua


local apiaryPositions = {} -- Server-side table to track all apiary positions
local playerApiaries = {} -- Table to track which apiaries belong to which player

-- Distance threshold to prevent overlapping apiaries
local MIN_DISTANCE = 23

-- Table to store active apiary GameObjects on the client side
local apiaries = {}

local playerManager = require("PlayerManager")
local placedObjectsManager = require("PlacedObjectsManager")
local beeObjectManager = require("BeeObjectManager")
local wildBeeManager = require("WildBeeManager")
local flowerManager = require("FlowerManager")
local utils = require("Utils")

--!SerializeField
local ApiaryPrefab : GameObject = nil

-- Events from server to client to actually add/remove game objects
local addNewApiaryRequest = Event.new("AddNewApiary")
local removeApiaryRequest = Event.new("RemoveApiary")
local updateLabelRequest = Event.new("UpdateLabelRequest")
notifyIsValidLocation = Event.new("NotifyIsValidLocation")

-- Events from client to server to request placement/removal of an apiary
apiaryPlacementRequest = Event.new("ApiaryPlacementRequest")
apiaryRemoveRequest = Event.new("ApiaryRemoveRequest")
notifyApiaryPlacementFailed = Event.new("NotifyApiaryPlacementFailed")
notifyApiaryPlacementSucceeded = Event.new("NotifyApiaryPlacementSucceeded")
requestIsValidLocation = Event.new("RequestIsValidLocation")

localApiaryPosition = nil --client value for local players apiary pos

-- Function to check if a position is valid (i.e., does not overlap with existing apiaries)
local function isPositionValid(position)

    if math.abs(position.x) > 100 or math.abs(position.z) > 100 then
        return 1
    end

    if math.abs(position.x) < 37 and math.abs(position.z) < 37 then
        return 2
    end

    for _, existingPosition in pairs(apiaryPositions) do
        local distance = (existingPosition - position).magnitude
        if distance < MIN_DISTANCE then
            return 3
        end
    end
    return 0
end

function GetLocalPlayerApiaryLocation()
    return localApiaryPosition
end

function GetPlayerApiaryLocation(player)
    -- Check if the player has an apiary position recorded
    local position = apiaryPositions[player]
    if position then
        return position
    else
        return nil -- or return a default position, or handle it as needed
    end
end



-- Client-side: Handles apiary placement and sends position to the server
function RequestPlaceApiary(position)
    apiaryPlacementRequest:FireServer(position)
end

-- Client-side: Removes an apiary for a given player
function RemoveApiary(playerID)
    -- Fire the event to the server to despawn the apiary
    apiaryRemoveRequest:FireServer(playerID)
end

-- Server-side: Connect the apiary placement request event
apiaryPlacementRequest:Connect(function(player, position)
    -- Check if the position is valid
    local ok = isPositionValid(position)
    if ok == 0 then
        -- Store the apiary position
        apiaryPositions[player] = position
        -- Notify all clients to place the new apiary
        SpawnApiary(player, position)
        print("Apiary placed by " .. player.name .. " at " .. tostring(position))

       playerManager.GetBeeList(player, function(bees)
            for i, bee in ipairs(bees) do
                beeObjectManager.SpawnBee(player, bee.species, position, bee.beeId, bee.adult, bee.timeToGrowUp, wildBeeManager.getGrowTime(bee.species), bee.hat)
             end
          end)

        flowerManager.SpawnPlayerFlowersOnAllClients(player, position)
				placedObjectsManager.SpawnPlayerPlacedObjectsOnAllClients(player, position)

        notifyApiaryPlacementSucceeded:FireClient(player, position)
    else
        -- Notify the player that the placement was invalid
        print("Invalid apiary placement for " .. player.name .. " due to overlap.")
        notifyApiaryPlacementFailed:FireClient(player, ok)
    end
end)

-- Server-side: Connect the apiary removal request event
apiaryRemoveRequest:Connect(function(playerID)
    if apiaryPositions[playerID] then
        apiaryPositions[playerID] = nil
        -- Notify clients to remove the apiary for this player
        apiaryRemoveRequest:FireAllClients(playerID)
    end
end)

-- Function to generate a unique ID for apiaries
local function generateApiaryID()
    return tostring(math.random(100000, 999999)) .. "-" .. tostring(os.time())
end

-- Function to remove all apiaries for a player
function RemoveAllPlayerApiaries(player)
    if playerApiaries[player] then
        for _, apiaryData in ipairs(playerApiaries[player]) do
            local apiaryID = apiaryData.id

            -- Fire an event to all clients to remove this apiary by its ID
            removeApiaryRequest:FireAllClients(apiaryID)
        end

        -- Clear the player's apiaries from the server's data
        playerApiaries[player] = nil
        apiaryPositions[player] = nil

        print("All apiaries removed for player: " .. player.name)
    else
        print("No apiaries to remove for player: " .. player.name)
    end
end

function UpdateLabelForApiary(player, count)
    if playerApiaries[player] then
        for _, apiaryData in ipairs(playerApiaries[player]) do
            local apiaryID = apiaryData.id

            -- Fire an event to all clients to remove this apiary by its ID
            updateLabelRequest:FireAllClients(apiaryID, player.name, count)
        end
    end
end

-- Function to spawn all existing apiaries for a specific player's client
function SpawnAllApiariesForPlayer(player)
    -- Iterate through all apiaries in the playerApiaries table
    for owner, apiaryList in pairs(playerApiaries) do
        for _, apiaryData in ipairs(apiaryList) do
            playerManager.GetSeenBeeSpeciesList(owner, function(bees)

                if #bees == 24 then
                    addNewApiaryRequest:FireClient(player, apiaryData.id, owner.name, apiaryData.location, true, #bees)
                else
                    addNewApiaryRequest:FireClient(player, apiaryData.id, owner.name, apiaryData.location, false, #bees)
                end
            end)
        end
    end
end

-- Function to spawn a new apiary for a player
function SpawnApiary(player, location)
    -- Generate a unique ID for the new apiary
    local apiaryID = generateApiaryID()

    -- Add the apiary to the player's list of apiaries on the server
    if not playerApiaries[player] then
        playerApiaries[player] = {}
    end

    table.insert(playerApiaries[player], { id = apiaryID, location = Vector3.new(location.x, location.y, location.z) })

    print("owner is " .. tostring(player.name)) 

    playerManager.GetSeenBeeSpeciesList(player, function(bees)
        -- Send the retrieved bee list back to the client
        if #bees == 24 then
            addNewApiaryRequest:FireAllClients(apiaryID, player.name, Vector3.new(location.x, location.y, location.z), true, #bees)
        else
            addNewApiaryRequest:FireAllClients(apiaryID, player.name, Vector3.new(location.x, location.y, location.z), false, #bees)
        end
    end)
end

-- Client-side functionality

function self:ClientAwake()
    -- Listen for new apiary spawning requests
    addNewApiaryRequest:Connect(function(apiaryID, owner, position, isGold, count)
        if ApiaryPrefab then
            -- Instantiate the apiary prefab
            local newApiary = Object.Instantiate(ApiaryPrefab)

            -- Store the apiary on the client, indexed by its ID
            apiaries[apiaryID] = newApiary

            if isGold then
                newApiary:GetComponent(ApiaryPrefabOwner).GetRegularBox():SetActive(false)
                newApiary:GetComponent(ApiaryPrefabOwner).GetGoldBox():SetActive(true)
            else
                newApiary:GetComponent(ApiaryPrefabOwner).GetRegularBox():SetActive(true)
                newApiary:GetComponent(ApiaryPrefabOwner).GetGoldBox():SetActive(false)
            end

						if owner == client.localPlayer.name then
							newApiary:GetComponent(ApiaryPrefabOwner).SetApiarySize(4)
							objectToSpawn = utils.GetPlacementObject("Toy Goose")
							newApiary:GetComponent(ApiaryPrefabOwner).SetObjectToSpawn(objectToSpawn, "Toy Goose")
							newApiary:GetComponent(ApiaryPrefabOwner).ShowPlacementLocations()
						end

            newApiary:GetComponent(ApiaryPrefabOwner).GetOwnerUi():GetComponent(ApiaryOwnerUi).SetLabel(owner, count)

            -- Set the position of the new apiary
            newApiary.transform.position = position

            print("Apiary spawned on client at position: " .. tostring(position))
        else
            print("ApiaryPrefab is not assigned. Cannot spawn apiary.")
        end
    end)

    -- Listen for apiary removal requests
    removeApiaryRequest:Connect(function(apiaryID)
        if apiaries[apiaryID] then
            -- Destroy the apiary object and remove it from the apiaries table
            Object.Destroy(apiaries[apiaryID])
            apiaries[apiaryID] = nil

            print("Apiary with ID " .. apiaryID .. " removed from client.")
        end
    end)

    updateLabelRequest:Connect(function(apiaryID, playerName, count)
        apiaries[apiaryID]:GetComponent(ApiaryPrefabOwner).GetOwnerUi():GetComponent(ApiaryOwnerUi).SetLabel(playerName, count)
    end)

end

function self:ServerAwake()
    requestIsValidLocation:Connect(function(player, position)
    if isPositionValid(position) == 0 then
        notifyIsValidLocation:FireClient(player, true)
    else
        notifyIsValidLocation:FireClient(player, false)
    end
    end)
end
