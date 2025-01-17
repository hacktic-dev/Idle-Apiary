--!Type(Module)

local requestObjectPlacement = Event.new("requestObjectPlacement")
local requestObjectDeletion = Event.new("requestObjectDeletion")
closePlacementMenu = Event.new("closePlacementMenu")

requestFreeSpaces = Event.new("requestFreeSpaces")
receiveFreeSpaces = Event.new("receiveFreeSpaces")
requestOccupiedSpaces = Event.new("requestOccupiedSpaces")
receiveOccupiedSpaces = Event.new("receiveOccupiedSpaces")

queryOwnedFurniture = Event.new("queryOwnedFurniture")
receiveOwnedFurniture = Event.new("receiveOwnedFurniture")
setFlowerStatus = Event.new("setFlowerStatus")
noFurnitureOwned = Event.new("noFurnitureOwned")
setConfirmButtonState = Event.new("setConfirmButtonState")

selectItem = Event.new("selectItem")

prospectiveObject = nil

apiaryManager = require("ApiaryManager")
playerManager = require("PlayerManager")
flowerManager = require("FlowerManager")
utils = require("Utils")

local placedObjects = {} -- Placed objects across all players (server)

local spawnedObjects = {} -- Spawned objects on client

index = 1

function GetPlacedFlowers(player)
	print("Getting placed flowers")
	local flowers = {}
	if placedObjects[player] then
		for _, object in ipairs(placedObjects[player]) do
			print("Checking object " .. object.id .. " with object id " .. utils.GetPlacementObjectIdByName(object.name))
			if utils.IsFlower(utils.GetPlacementObjectIdByName(object.name)) then
				print("Object is a flower")
				table.insert(flowers, utils.GetPlacementObjectIdByName(object.name))
			end
		end
	end
	return flowers
end

function Reset()
	
	prospectiveObject = nil
	setConfirmButtonState:Fire(false)
end

function SetProspectiveObject(_object, _name, _x, _y)
	prospectiveobjectPrefab = _object
	prospectiveObject = {name = _name, x = _x, y = _y, rotation = 0}
	setConfirmButtonState:Fire(true)
end

function Confirm()
	if prospectiveObject == nil then
		return
	end
	requestObjectPlacement:FireServer(prospectiveObject.name, prospectiveObject.x, prospectiveObject.y, prospectiveObject.rotation)
	closePlacementMenu:Fire()
end	

function Rotate(angle)
	rotation = prospectiveobjectPrefab.transform.localRotation.eulerAngles
	prospectiveobjectPrefab.transform.localRotation = Quaternion.Euler(rotation.x, rotation.y + angle, rotation.z)
	prospectiveObject.rotation = prospectiveObject.rotation + angle
end

function Cancel()
	closePlacementMenu:Fire()
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
  print("Initing server3")

	queryOwnedFurniture:Connect(function(player)
		print("Getting furniture")
		Inventory.GetPlayerItems(player, 25, "", function(items, newCursorId, errorCode)
			if items == nil then
				print(errorCode)
			end

			print("Furniture recieved")

			furnitureOwned = false

			print("placed flower count: " .. GetPlacedFlowerCount(player) .. " max flowers: " ..  playerManager.GetPlayerFlowerCapacity(player))
			local canPlaceFlower = GetPlacedFlowerCount(player) <  playerManager.GetPlayerFlowerCapacity(player)
			setFlowerStatus:FireClient(player, canPlaceFlower)

			for index, item in items do

				print(item.id)

				if utils.IsFurniture(item.id) or utils.IsFlower(item.id) then
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

		self:GetComponent(ObjectSpawnController).SpawnObject(placedObject, player.user.id, apiaryPosition)
	
		if placedObjects[player] == nil then
				placedObjects[player] = {}
		end

		table.insert(placedObjects[player], placedObject)
		local transaction = InventoryTransaction.new():TakePlayer(player, utils.LookupFurnitureIdByName(placedObject.name), 1)
		Inventory.CommitTransaction(transaction)
		playerManager.RecalculatePlayerEarnRate(player)
	end)

	requestObjectDeletion:Connect(function(player, id)
		if placedObjects[player] == nil then
			return
		end

		local name = nil

		for index, object in ipairs(placedObjects[player]) do
			if object.id == id then
				name = object.name
				table.remove(placedObjects[player], index)
				break
			end
		end

		self:GetComponent(ObjectSpawnController).RemoveObject(id)

		local transaction = InventoryTransaction.new():GivePlayer(player, utils.LookupFurnitureIdByName(name), 1)
		Inventory.CommitTransaction(transaction)
		playerManager.RecalculatePlayerEarnRate(player)
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

		receiveFreeSpaces:FireClient(player, player, freeSpaces)
	end)

	requestOccupiedSpaces:Connect(function(player)
		print("Requesting occupied spaces")
		receiveOccupiedSpaces:FireClient(player, placedObjects[player])
	end)
end

function Delete(id)
	requestObjectDeletion:FireServer(id)
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

end

function SpawnAllObjectsForIncomingPlayer(player)

end

function RemoveAllPlayerPlacedObjects(player) -- server
    print("removing all objects for player " .. player.name)
    if placedObjects[player] then
        for _ , object in ipairs(placedObjects[player]) do
            self:GetComponent(ObjectSpawnController).RemoveObject(object.id)
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
            self:GetComponent(ObjectSpawnController).SpawnObject(object, player.user.id, apiaryPosition)
        end
    end)
end

function SavePlacedObjects(player, id) -- server
    if placedObjects[player] ~= nil then
        print("Saving placed objects for " .. player.name)
        Storage.SetValue(id .. "/" .. "PlacedObjects", placedObjects[player], function(errorCode) if not errorCode == 0 then print("Placed objects storage failed!") end end)
    end
end

function GetPlacedFlowerCount(player)
	local count = 0
	if placedObjects[player] then
		for _, object in ipairs(placedObjects[player]) do
			print("Checking object " .. object.id)
			if utils.IsFlower(utils.GetPlacementObjectIdByName(object.name)) then
				count = count + 1
			end
		end
	end
	print("Returning count " .. count)
	print("flower manager count " .. #flowerManager.GetPlacedFlowers(player))
	return count + #flowerManager.GetPlacedFlowers(player)
end