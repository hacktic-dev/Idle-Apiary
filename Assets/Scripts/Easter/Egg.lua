--!Type(Client)

timeAlive = 0

local MIN_SPAWN_DISTANCE = 45
local MAX_TIME_ALIVE = 180

local inRange = false

EggDespawnEvent = Event.new("EggDespawnEvent")

function self:Update()
    timeAlive += Time.deltaTime

    if timeAlive > MAX_TIME_ALIVE and Vector3.Distance(self:GetComponent(Transform).position, client.localPlayer.character:GetComponent(Transform).position) > MIN_SPAWN_DISTANCE then
        print("Despawning egg")
        Object.Destroy(self:GetComponent(Transform).gameObject)
        EggDespawnEvent:Fire()
    end
end