--!Type(Client)

--!SerializeField
local RegularBox : GameObject = nil

--!SerializeField
local GoldBox : GameObject = nil

--!SerializeField
local OwnerUI : GameObject = nil

--!SerializeField
local locationObject : GameObject = nil

--!SerializeField
local removalObject : GameObject = nil 

--!SerializeField
local apiarySize0 : GameObject = nil

--!SerializeField
local apiarySize1 : GameObject = nil

--!SerializeField
local apiarySize2 : GameObject = nil

local ownerName = nil

local apiarySize = nil

local objectToSpawn = nil

local objectName = nil

local spawnedObject = nil

placedObjectsManager = require("PlacedObjectsController")
UIManager = require("UIManager")

placementLocations = {}

function SetOwnerName(id)
	ownerName = id
end

function SetApiarySize(size)
	apiarySize = size
	if size == 2 then
		apiarySize0:SetActive(true)
		apiarySize1:SetActive(false)
		apiarySize2:SetActive(false)
	elseif size == 4 then
		apiarySize0:SetActive(false)
		apiarySize1:SetActive(true)
		apiarySize2:SetActive(false)
	elseif size == 5 then
		apiarySize0:SetActive(false)
		apiarySize1:SetActive(false)
		apiarySize2:SetActive(true)
	end
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
	print("Showing placement locations")
	placedObjectsManager.requestFreeSpaces:FireServer(apiarySize)
end

function ShowRemovalLocations()
	print("Showing removal locations")
	placedObjectsManager.requestOccupiedSpaces:FireServer()
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
		UIManager.CloseRemoveFurnitureMenu()
	end)

	placedObjectsManager.selectItem:Connect(function(object, name)
	 SetObjectToSpawn(object, name)
	end)

	placedObjectsManager.receiveFreeSpaces:Connect(function(player, freeSpaces)

		if ownerName ~= player.name then
			return
		end

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

	placedObjectsManager.receiveOccupiedSpaces:Connect(function(objects)
		print("Received occupied spaces")
		for _, object in ipairs(objects) do
			newObject = Object.Instantiate(removalObject)
			newObject.transform.parent = self.transform
			newObject.transform.localPosition = Vector3.new(object.x*2, 0, object.y*2)

			table.insert(placementLocations, newObject)

			newObject.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
				placedObjectsManager.Delete(object.id)

				for _, object in placementLocations do
					Object.Destroy(object)
				end

				UIManager.CloseRemoveFurnitureMenu()
			end)
		end
	end)
end