--!Type(Module)

requestObjectPlacement = Event.new("requestObjectPlacement")
closePlacementMenu = Event.new("closePlacementMenu")
clientSpawnPlacedObject = Event.new("clientSpawnPlacedObject")

prospectiveObject = nil

apiaryManager = require("apiaryManager")
utils = require("Utils")

local placedObjects = {} -- Placed objects across all players (server)

local spawnedObjects = {} -- Spawned objects on client

function SetProspectiveObject(_name, _x, _y)
	prospectiveObject = {name = _name, x = _x, y = _y, id = nil}
end

function Confirm()
	requestObjectPlacement:FireServer(prospectiveObject)
	closePlacementMenu:Fire()
end	

requestObjectPlacement:Connect(function(player, placedObject)
	print("spawning")
	apiaryPosition = apiaryManager.GetPlayerApiaryLocation(player)

	local id = playerManager.GenerateUniqueID()
	placedObject.id = id
	position = apiaryPosition + Vector3.new(placedObject.x*2, 0, placedObject.y*2)

	clientSpawnPlacedObject:FireAllClients(placedObject, player.user.id, position)
	
		if placedObjects[player] == nil then
				placedObjects[player] = {}
		end

		table.insert(placedObjects[player], placedObject)
		-- TODO: take object from inventory

end)

function self:ClientAwake()
	clientSpawnPlacedObject:Connect(function(placedObject, userId, position)
		local spawnedObject = Object.Instantiate(utils.GetPlacementObject(placedObject.name))
		spawnedObject:GetComponent(Transform).position = position
		spawnedObject:GetComponent(Furniture).SetOwner(userId)
		spawnedObjects[placedObject.id] = spawnedObject
	end)
end