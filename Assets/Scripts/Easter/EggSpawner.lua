--!Type(Client)

--!SerializeField
local SpawnLocations : {GameObject} = nil

--!SerializeField
local RegularEggPrefabs : {GameObject} = nil

--!SerializeField
local PinkEggPrefab : GameObject = nil

--!SerializeField
local WhiteEggPrefab : GameObject = nil

--!SerializeField
local GoldEggPrefab : GameObject = nil

SPAWN_INTERVAL = 2
MIN_SPAWN_DISTANCE = 50

easterEventVariableRetriever = require("EasterEventVariableRetriever")

function self:ClientAwake()
    Timer.new(SPAWN_INTERVAL, function()
        TrySpawnEgg()
    end)
end

function TrySpawnEgg()
    if math.random(0, 100) > 50 then
        return -- failed
    end
    
    while true do
        selection = math.random(1, #SpawnLocations)
        position = SpawnLocations[selection].transform.position
        if Vector3.Distance(position, client.localPlayer.character:GetComponent(Transform).position) > MIN_SPAWN_DISTANCE then
            break
        end
    end

    local spawnRoll = math.random(0, 100)
    local eggPrefab = nil

    if spawnRoll <= easterEventVariableRetriever.GetGoldEggSpawnRate() then
        eggPrefab = GoldEggPrefab
    elseif spawnRoll <= easterEventVariableRetriever.GetGoldEggSpawnRate() + easterEventVariableRetriever.GetWhiteEggSpawnRate() then
        eggPrefab = WhiteEggPrefab
    elseif spawnRoll <= easterEventVariableRetriever.GetGoldEggSpawnRate() + easterEventVariableRetriever.GetWhiteEggSpawnRate() + easterEventVariableRetriever:GetPinkEggSpawnRate() then
        eggPrefab = PinkEggPrefab
    else
        local regularEggIndex = math.random(1, math.min(#RegularEggPrefabs, 5))
        eggPrefab = RegularEggPrefabs[regularEggIndex]
    end

    local egg = Object.Instantiate(eggPrefab)
    egg.transform.position = position
end