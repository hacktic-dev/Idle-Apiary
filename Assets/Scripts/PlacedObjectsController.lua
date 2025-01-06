--!Type(Module)

local requestObjectPlacement = Event.new("requestObjectPlacement")
closePlacementMenu = Event.new("closePlacementMenu")
local clientSpawnPlacedObject = Event.new("clientSpawnPlacedObject")
local removeObjectRequest = Event.new("removeObjectRequest")

requestSitPlayerOnSeat = Event.new("requestSitPlayerOnSeat")
clientSitPlayerOnSeat = Event.new("clientSitPlayerOnSeat")

requestFreeSpaces = Event.new("requestFreeSpaces")
receiveFreeSpaces = Event.new("receiveFreeSpaces")

queryOwnedFurniture = Event.new("queryOwnedFurniture")
receiveOwnedFurniture = Event.new("receiveOwnedFurniture")
noFurnitureOwned = Event.new("noFurnitureOwned")

selectItem = Event.new("selectItem")

prospectiveObject = nil

apiaryManager = require("ApiaryManager")
playerManager = require("PlayerManager")
utils = require("Utils")

local placedObjects = {} -- Placed objects across all players (server)

local spawnedObjects = {} -- Spawned objects on client

index = 1

function SetProspectiveObject(_object, _name, _x, _y)
	prospectiveobjectPrefab = _object
	prospectiveObject = {name = _name, x = _x, y = _y, rotation = 0}
end

function Confirm()
	print(prospectiveObject.rotation)
	requestObjectPlacement:FireServer(prospectiveObject.name, prospectiveObject.x, prospectiveObject.y, prospectiveObject.rotation)
	closePlacementMenu:Fire()
end	

function Rotate(angle)
	rotation = prospectiveobjectPrefab.transform.localRotation.eulerAngles
	prospectiveobjectPrefab.transform.localRotation = Quaternion.Euler(rotation.x, rotation.y + angle, rotation.z)
	prospectiveObject.rotation = prospectiveObject.rotation + angle
end

function Cycle()
	index = index + 1
	if index > 13 then
		index = 1
	end

	selectItem:Fire(utils.GetPlacementObjectByIndex(index), utils.GetPlacementObjectNameByIndex(index))
end

function InitServer()	
  print("Initing server")
  print("Initing server2")

	queryOwnedFurniture:Connect(function(player)
		print("Getting furniture")
		Inventory.GetPlayerItems(player, 25, "", function(items, newCursorId, errorCode)
			if items == nil then
				print(errorCode)
			end

			print("Furniture recieved")

			furnitureOwned = false

			for index, item in items do

				print(item.id)

				if utils.IsFurniture(item.id) then
					receiveOwnedFurniture:FireClient(player, item.id, item.amount)
					furnitureOwned = true
				end
			end

			if furnitureOwned == false then 
				print("No owned hats")
				noFurnitureOwned:FireClient(player)
			end
		end)
	end)

	requestObjectPlacement:Connect(function(player, _name, _x, _y, _rotation)
		print(_rotation)

		local _id = playerManager.GenerateUniqueID()
		placedObject = {name = _name, x = _x, y = _y, id = _id, rotation = _rotation}

		apiaryPosition = apiaryManager.GetPlayerApiaryLocation(player)

		clientSpawnPlacedObject:FireAllClients(placedObject, player.user.id, apiaryPosition)
	
			if placedObjects[player] == nil then
					placedObjects[player] = {}
			end

			table.insert(placedObjects[player], placedObject)
			local transaction = InventoryTransaction.new():TakePlayer(player, utils.LookupFurnitureIdByName(placedObject.name), 1)
			Inventory.CommitTransaction(transaction)

	end)

	requestFreeSpaces:Connect(function(player, size)

		freeSpaces = {}

		for i = -size, size do
			for j = -size, size do
				if CheckIfSpaceFree(player, i, j) then
					table.insert(freeSpaces, {x = i, y = j})
				end
			end
		end

		receiveFreeSpaces:FireClient(player, freeSpaces)
	end)

	requestSitPlayerOnSeat:Connect(function(player, placedId)
		clientSitPlayerOnSeat:FireAllClients(player, placedId)
	end)
end

function CheckIfSpaceFree(player, i, j)
	
	if placedObjects[player] == nil then
		return true
	end

	for _ , object in ipairs(placedObjects[player]) do
		if object.x == i and object.y == j then
			return false
		end
	end

	return true
end

function InitClient()
  print("Initing client")
	clientSpawnPlacedObject:Connect(function(placedObject, userId, apiaryPosition)
		
		print(placedObject.rotation)
		local spawnedObject = Object.Instantiate(utils.GetPlacementObjectByName(placedObject.name))
		spawnedObject:GetComponent(Transform).position = apiaryPosition + Vector3.new(placedObject.x*2, 0, placedObject.y*2)

		rotation = spawnedObject:GetComponent(Transform).localRotation.eulerAngles
		spawnedObject:GetComponent(Transform).localRotation = Quaternion.Euler(rotation.x, rotation.y + placedObject.rotation, rotation.z)

		spawnedObject:GetComponent(Furniture).SetOwner(userId)
		spawnedObject:GetComponent(Furniture).SetPlacedId(placedObject.id)
		spawnedObjects[placedObject.id] = spawnedObject
	end)

	removeObjectRequest:Connect(function(id)
		    if spawnedObjects[id] then
        Object.Destroy(spawnedObjects[id])
        spawnedObjects[id] = nil
    end
	end)

	clientSitPlayerOnSeat:Connect(function(player, placedId)
		spawnedObjects[placedId]:GetComponent(Furniture).ClientSitPlayerOnSeat(player)
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
            storedObjects = {}
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