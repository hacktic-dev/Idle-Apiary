--!Type(Client)

--!SerializeField
local id : string = ""
--!SerializeField
local desc : string = ""

timeAlive = 0

local MIN_SPAWN_DISTANCE = 45

local flowerManager = require("FlowerManager")

local inRange = false

function self:Update()
    timeAlive += Time.deltaTime

    if (not inRange) and Vector3.Distance(self:GetComponent(Transform).position, client.localPlayer.character:GetComponent(Transform).position) < 3 then
        inRange = true
        flowerManager.flowerAreaEntered(self:GetComponent(Transform).gameObject, id, desc)
    elseif inRange and  Vector3.Distance(self:GetComponent(Transform).position, client.localPlayer.character:GetComponent(Transform).position) > 3 then
        inRange = false
        flowerManager.flowerAreaExited()
    end

    if timeAlive > 180 and Vector3.Distance(self:GetComponent(Transform).position, client.localPlayer.character:GetComponent(Transform).position) > MIN_SPAWN_DISTANCE then
        print("Despawning flower")
        Object.Destroy(self:GetComponent(Transform).gameObject)
    end
end