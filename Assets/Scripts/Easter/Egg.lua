--!Type(Client)

timeAlive = 0

local MIN_SPAWN_DISTANCE = 45
local MAX_TIME_ALIVE = 180


local inRange = false

function self:Update()
    if owner == nil then
        timeAlive += Time.deltaTime
    end

    if client == nil then
        return
    end

    if (not inRange) and (owner == nil or owner == client.localPlayer.user.id) and Vector3.Distance(self:GetComponent(Transform).position, client.localPlayer.character:GetComponent(Transform).position) < 3 then
        inRange = true
        --SHOW COLLECTION UI
    elseif inRange and  Vector3.Distance(self:GetComponent(Transform).position, client.localPlayer.character:GetComponent(Transform).position) > 3 then
        inRange = false
        --HIDE COLLECTION UI
    end

    if timeAlive > MAX_TIME_ALIVE and Vector3.Distance(self:GetComponent(Transform).position, client.localPlayer.character:GetComponent(Transform).position) > MIN_SPAWN_DISTANCE then
        print("Despawning egg")
        Object.Destroy(self:GetComponent(Transform).gameObject)
    end
end