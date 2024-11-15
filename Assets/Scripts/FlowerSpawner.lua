--!Type(Client)

--!SerializeField
local SpawnLocations : {GameObject} = nil

--!SerializeField
local Flowers : {GameObject} = nil

function self:ClientAwake()
 Timer.new(30, function() TrySpawnFlower() end, true)
end

local MIN_SPAWN_DISTANCE = 45 

function TrySpawnFlower()
    if math.random(0, 100) > 20 then
        return -- failed
    end
    
    while true do
        selection = math.random(1, #SpawnLocations)
        position = SpawnLocations[selection].transform.position
        if Vector3.Distance(position, client.localPlayer.character:GetComponent(Transform).position) > MIN_SPAWN_DISTANCE then
            break
        end
    end

    print("Spawning flower at spot " .. selection)

    selection = math.random(1, #Flowers)
    local flower = Object.Instantiate(Flowers[selection])
    flower.transform.position = position
end