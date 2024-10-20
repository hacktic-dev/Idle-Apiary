--!Type(Module)

--!Type(Module)

-- ApiaryManager.lua


local apiaryPositions = {} -- Server-side table to track all apiary positions
local playerApiaries = {} -- Table to track which apiaries belong to which player

-- Distance threshold to prevent overlapping apiaries
local MIN_DISTANCE = 18.75

-- Table to store active apiary GameObjects on the client side
local apiaries = {}

local playerManager = require("PlayerManager")
local beeObjectManager = require("BeeObjectManager")

--!SerializeField
local ApiaryPrefab : GameObject = nil

-- Events from server to client to actually add/remove game objects
local addNewApiaryRequest = Event.new("AddNewApiary")
local removeApiaryRequest = Event.new("RemoveApiary")

-- Events from client to server to request placement/removal of an apiary
apiaryPlacementRequest = Event.new("ApiaryPlacementRequest")
apiaryRemoveRequest = Event.new("ApiaryRemoveRequest")
notifyApiaryPlacementFailed = Event.new("NotifyApiaryPlacementFailed")
notifyApiaryPlacementSucceeded = Event.new("NotifyApiaryPlacementSucceeded")

-- Function to check if a position is valid (i.e., does not overlap with existing apiaries)
local function isPositionValid(position)
    for _, existingPosition in pairs(apiaryPositions) do
        local distance = (existingPosition - position).magnitude
        if distance < MIN_DISTANCE then
            return false
        end
    end
    return true
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
    position = player.character:GetComponent(Transform).position
    -- Check if the position is valid
    if isPositionValid(position) then
        -- Store the apiary position
        apiaryPositions[player] = position
        -- Notify all clients to place the new apiary
        SpawnApiary(player, position)
        print("Apiary placed by " .. player.name .. " at " .. tostring(position))

        Inventory.GetPlayerItems(player, 10, "", function(items, newCursorId, errorCode)
            for i, item in ipairs(items) do
                   if string.find(item.id, "Bee") then
                     for n = 1, item.amount do
                        beeObjectManager.SpawnBee(player, item.id, position)
                    end
                 end
             end
          end)

        playerManager.RecalculatePlayerEarnRate(player)
        notifyApiaryPlacementSucceeded:FireClient(player)
    else
        -- Notify the player that the placement was invalid
        print("Invalid apiary placement for " .. player.name .. " due to overlap.")
        notifyApiaryPlacementFailed:FireClient(player)
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

-- Function to spawn all existing apiaries for a specific player's client
function SpawnAllApiariesForPlayer(player)
    -- Iterate through all apiaries in the playerApiaries table
    for owner, apiaryList in pairs(playerApiaries) do
        for _, apiaryData in ipairs(apiaryList) do
            -- Fire an event to the specified player to spawn each apiary with its ID and location
            addNewApiaryRequest:FireClient(player, apiaryData.id, apiaryData.location)
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

    -- Fire the client event to spawn this apiary for all clients
    addNewApiaryRequest:FireAllClients(apiaryID, Vector3.new(location.x, location.y, location.z))

    print("Apiary placed for player: " .. player.name .. " at location: " .. tostring(location))
end

-- Client-side functionality

function self:ClientAwake()
    -- Listen for new apiary spawning requests
    addNewApiaryRequest:Connect(function(apiaryID, position)
        if ApiaryPrefab then
            -- Instantiate the apiary prefab
            local newApiary = Object.Instantiate(ApiaryPrefab)

            -- Store the apiary on the client, indexed by its ID
            apiaries[apiaryID] = newApiary

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
end
