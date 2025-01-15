--!Type(ClientAndServer)

--!SerializeField
local chair : GameObject = nil

--!SerializeField
local table : GameObject = nil

--!SerializeField
local chessTable : GameObject = nil

--!SerializeField
local bookTable : GameObject = nil

--!SerializeField
local whiteFlowerPlanter : GameObject = nil

--!SerializeField
local appleBox : GameObject = nil

--!SerializeField
local redMushroom : GameObject = nil

--!SerializeField
local brownMushroom : GameObject = nil

--!SerializeField
local teddyBear : GameObject = nil

--!SerializeField
local toyGoose : GameObject = nil

--!SerializeField
local pillow : GameObject = nil

--!SerializeField
local fountain : GameObject = nil

--!SerializeField
local flower_purple : GameObject = nil

--!SerializeField
local flower_red : GameObject = nil

--!SerializeField
local flower_white : GameObject = nil

--!SerializeField
local flower_yellow : GameObject = nil


PlacementObject = {
    ["Chair"] = chair,
    ["Table"] = table,
    ["Chess Table"] = chessTable,
    ["Book Table"] = bookTable,
    ["White Flower Planter"] = whiteFlowerPlanter,
    ["Apple Box"] = appleBox,
    ["Red Mushroom"] = redMushroom,
    ["Brown Mushroom"] = brownMushroom,
    ["Teddy Bear"] = teddyBear,
    ["Toy Goose"] = toyGoose,
    ["Pillow"] = pillow,
    ["Fountain"] = fountain,
    ["Purple Flower"] = flower_purple,
    ["Red Flower"] = flower_red,
    ["White Flower"] = flower_white,
    ["Yellow Flower"] = flower_yellow
}

spawnedObjects = {}

function SpawnObject(placedObject, userId, apiaryPosition)
    print("spawning object " .. placedObject.name .. " with id " .. placedObject.id)
    print(tostring(self.transform.position))
    print(tostring(apiaryPosition))
    local spawnedObject = Object.Instantiate(PlacementObject[placedObject.name], apiaryPosition + Vector3.new(placedObject.x*2, 0, placedObject.y*2), Quaternion.Euler(0, placedObject.rotation, 0))

    if spawnedObject:GetComponent(Furniture) ~= nil then
        spawnedObject:GetComponent(Furniture).SetOwner(userId)
        spawnedObject:GetComponent(Furniture).SetPlacedId(placedObject.id)
    elseif spawnedObject:GetComponent(Flower) ~= nil then
        spawnedObject:GetComponent(Flower).SetOwner(userId)
        spawnedObject:GetComponent(Flower).SetPlacedId(placedObject.id)
    end
    spawnedObjects[placedObject.id] = spawnedObject
end


function RemoveObject(id)
    print("removing object " .. id)
    Object.Destroy(spawnedObjects[id])
    spawnedObjects[id] = nil

end