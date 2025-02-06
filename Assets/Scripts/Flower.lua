--!Type(ClientAndServer)

--!SerializeField
local id : string = ""

--!SerializeField
local isLegacy : boolean = false

local placedId = nil

owner = nil

timeAlive = 0

local MIN_SPAWN_DISTANCE = 45

local flowerManager = require("FlowerManager")

local inRange = false

function SetOwner(_owner)
    owner = _owner
end

function SetPlacedId(_id)
    placedId = _id
end

function self:Update()
    if owner == nil then
        timeAlive += Time.deltaTime
    end

    if client == nil then
        return
    end

    if (not inRange) and (owner == nil or owner == client.localPlayer.user.id) and Vector3.Distance(self:GetComponent(Transform).position, client.localPlayer.character:GetComponent(Transform).position) < 3 then
        inRange = true
        flowerManager.flowerAreaEntered(self:GetComponent(Transform).gameObject, id, flowerManager.LookupFlowerDescription(id), owner, placedId, isLegacy)
    elseif inRange and  Vector3.Distance(self:GetComponent(Transform).position, client.localPlayer.character:GetComponent(Transform).position) > 3 then
        inRange = false
        flowerManager.flowerAreaExited()
    end

    if isLegacy and timeAlive > 180 and Vector3.Distance(self:GetComponent(Transform).position, client.localPlayer.character:GetComponent(Transform).position) > MIN_SPAWN_DISTANCE then
        print("Despawning flower")
        Object.Destroy(self:GetComponent(Transform).gameObject)
    end
end