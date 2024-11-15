--!Type(Client)

--!SerializeField
local id : number = 0

timeAlive = 0

local MIN_SPAWN_DISTANCE = 45

function self:Update()
    timeAlive += Time.deltaTime

    if timeAlive > 180 and Vector3.Distance(self:GetComponent(Transform).position, client.localPlayer.character:GetComponent(Transform).position) > MIN_SPAWN_DISTANCE then
        print("Despawning flower")
        Object.Destroy(self:GetComponent(Transform).gameObject)
    end
end