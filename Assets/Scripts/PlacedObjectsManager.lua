--!Type(Module)

local requestObjectPlacement = Event.new("requestObjectPlacement")
closePlacementMenu = Event.new("closePlacementMenu")
local clientSpawnPlacedObject = Event.new("clientSpawnPlacedObject")
local removeObjectRequest = Event.new("removeObjectRequest")

prospectiveObject = nil

apiaryManager = require("ApiaryManager")
playerManager = require("PlayerManager")
utils = require("Utils")

local placedObjects = {} -- Placed objects across all players (server)

local spawnedObjects = {} -- Spawned objects on client

function SetProspectiveObject(_name, _x, _y)
	prospectiveObject = {name = _name, x = _x, y = _y}
end

function Confirm()
	print("confirm hit")
	requestObjectPlacement:FireServer(prospectiveObject.name, prospectiveObject.x, prospectiveObject.y)
	closePlacementMenu:Fire()
end	

function InitServer()	
  print("Initing server")

	requestObjectPlacement:Connect(function(player, _name, _x, _y)
		print("spawning")

		local _id = playerManager.GenerateUniqueID()
		placedObject = {name = _name, x = _x, y = _y, id = _id}

		apiaryPosition = apiaryManager.GetPlayerApiaryLocation(player)

		position = 

		clientSpawnPlacedObject:FireAllClients(placedObject, player.user.id, apiaryPosition)
	
			if placedObjects[player] == nil then
					placedObjects[player] = {}
			end

			table.insert(placedObjects[player], placedObject)
			-- TODO: take object from inventory

	end)
end

function InitClient()
  print("Initing client")
	clientSpawnPlacedObject:Connect(function(placedObject, userId, apiaryPosition)
		print("Spawning object")
		local spawnedObject = Object.Instantiate(utils.GetPlacementObject(placedObject.name))
		spawnedObject:GetComponent(Transform).position = apiaryPosition + Vector3.new(placedObject.x*2, 0, placedObject.y*2)
		spawnedObject:GetComponent(Furniture).SetOwner(userId)
		spawnedObjects[placedObject.id] = spawnedObject
	end)

	removeObjectRequest:Connect(function(id)
		    if spawnedObjects[id] then
        Object.Destroy(spawnedObjects[id])
        spawnedObjects[id] = nil
    end
	end)
end

function SpawnAllObjectsForIncomingPlayer(player)
	for owner, objectList in pairs(placedObjects) do
		for _, object in ipairs(objectList) do
			clientSpawnPlacedObject:FireClient(player, object, owner.user.id, apiaryManager.GetPlayerApiaryLocation(owner))
		end
	end
end

function RemoveAllPlayerPlacedObjects(player) -- server
    print("removing all objects for player " .. player.name)
    if placedObjects[player] then
        for _ , object in ipairs(placedObjects[player]) do
            local id = object.id

            removeObjectRequest:FireAllClients(id)
        end

        placedObjects[player] = nil
    end
end


function SpawnPlayerPlacedObjectsOnAllClients(player, _apiaryPosition)
    apiaryPosition = _apiaryPosition
    Storage.GetPlayerValue(player, "PlacedObjects", function(storedObjects, errorCode)

        if storedObjects == nil then
            storedObjects[player] = {}
            return
        end
        
        placedObjects[player] = storedObjects
        for _, object in ipairs(storedObjects) do
            clientSpawnPlacedObject:FireAllClients(object, player.user.id, apiaryPosition)
        end
    end)
end

function SavePlacedObjects(player, id) -- server
    if placedObjects[player] ~= nil then
        print("Saving placed objects for " .. player.name)
        Storage.SetValue(id .. "/" .. "PlacedObjects", placedObjects[player], function(errorCode) if not errorCode == 0 then print("Placed objects storage failed!") end end)
    end
end