--!Type(Client)

--!SerializeField
local RegularBox : GameObject = nil

--!SerializeField
local GoldBox : GameObject = nil

--!SerializeField
local OwnerUI : GameObject = nil

--!SerializeField
local locationObject : GameObject = nil

local apiarySize = nil

local objectToSpawn = nil

local objectName = nil

local spawnedObject = nil

placedObjectsManager = require("PlacedObjectsController")
UIManager = require("UIManager")

placementLocations = {}

function SetApiarySize(size)
	apiarySize = size
end

function SetObjectToSpawn(object, name)
	objectToSpawn = object
	objectName = name
end

function GetGoldBox()
    return GoldBox
end

function GetRegularBox()
    return RegularBox
end

function GetOwnerUi()
    return OwnerUI
end

function ShowPlacementLocations()
	placedObjectsManager.requestFreeSpaces:FireServer(apiarySize)
end

function self:ClientAwake()
	placedObjectsManager.closePlacementMenu:Connect(function()
		for _, object in placementLocations do
			Object.Destroy(object)
		end

		placementLocations = {}

		if spawnedObject ~= nil then
			Object.Destroy(spawnedObject)
			spawnedObject = nil
		end

		UIManager.ClosePlaceObjectsUi()
	end)

	placedObjectsManager.selectItem:Connect(function(object, name)
	 SetObjectToSpawn(object, name)
	end)

	placedObjectsManager.receiveFreeSpaces:Connect(function(freeSpaces)
		placedObjectsManager.Reset()
		for _, space in ipairs(freeSpaces) do
			if space.x ~= 0 or space.y ~= 0 then
				newObject = Object.Instantiate(locationObject)
				newObject.transform.parent = self.transform
				newObject.transform.localPosition = Vector3.new(space.x*2, 0, space.y*2)

				table.insert(placementLocations, newObject)

				newObject.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
				if spawnedObject ~= nil then
					Object.Destroy(spawnedObject)
					spawnedObject = nil
				end

				spawnedObject = Object.Instantiate(objectToSpawn)
				spawnedObject.transform.parent = self.transform
				spawnedObject.transform.localPosition = Vector3.new(space.x*2, 0, space.y*2)

				placedObjectsManager.SetProspectiveObject(spawnedObject, objectName, space.x, space.y)


				print("Position " .. space.x .. ", " .. space.y .. " tapped.")
				end)
			end
		end

	end)
end