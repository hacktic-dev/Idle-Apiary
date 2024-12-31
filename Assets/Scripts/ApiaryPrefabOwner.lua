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

placedObjectsManager = require("PlacedObjectsManager")

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
	for i = -apiarySize, apiarySize do
		for j = -apiarySize, apiarySize do
			newObject = Object.Instantiate(locationObject)
			newObject.transform.parent = self.transform
			newObject.transform.localPosition = Vector3.new(i*2, 0, j*2)

			table.insert(placementLocations, newObject)

			newObject.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
			if spawnedObject ~= nil then
				Object.Destroy(spawnedObject)
				spawnedObject = nil
			end

			placedObjectsManager.SetProspectiveObject(objectName, i, j)

			spawnedObject = Object.Instantiate(objectToSpawn)
			spawnedObject.transform.parent = self.transform
			spawnedObject.transform.localPosition = Vector3.new(i*2, 0, j*2)
			print("Position " .. i .. ", " .. j .. " tapped.")
			end)
		end
	end
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
	end)
end