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

SPAWN_INTERVAL = 1
MIN_SPAWN_DISTANCE = 50
EGG_RANGE = 2

eggInventoryHandler = require("EggInventoryHandler")

eggs = {}

local wasInRange = false
local eggFinderActive = false

easterEventVariableRetriever = require("EasterEventVariableRetriever")

function self:ClientAwake()
    Timer.new(SPAWN_INTERVAL, function()
        eggInventoryHandler.RequestEggFinderActiveEvent:FireServer()
    end, true)

    eggInventoryHandler.NotifyEggFinderActiveEvent:Connect(function(isActive)
        eggFinderActive = isActive
        TrySpawnEgg()
    end)

    eggInventoryHandler.DestroyEggPrefabEvent:Connect(function(egg)
        print("Destroying egg prefab")
        for i, e in ipairs(eggs) do
            if e == egg.gameObject then
                table.remove(eggs, i)
                Object.Destroy(e)
                print("Egg destroyed")
                break
            end
        end
    end)
end

function TrySpawnEgg()
    local spawnChance = easterEventVariableRetriever.GetEggSpawnChance()
    if eggFinderActive then
        spawnChance = spawnChance * 6
    end

    if math.random() > spawnChance then
        return -- failed
    end
    
    while true do
        selection = math.random(1, #SpawnLocations)
        position = SpawnLocations[selection].transform.position
        if Vector3.Distance(position, client.localPlayer.character:GetComponent(Transform).position) > MIN_SPAWN_DISTANCE then
            break
        end
    end

    local spawnRoll = math.random()
    local eggPrefab = nil

    local goldEggRate = easterEventVariableRetriever.GetGoldEggSpawnRate()
    local whiteEggRate = easterEventVariableRetriever.GetWhiteEggSpawnRate()
    local pinkEggRate = easterEventVariableRetriever.GetPinkEggSpawnRate()

    if eggFinderActive then
        goldEggRate = goldEggRate * 2
        whiteEggRate = whiteEggRate * 2
        pinkEggRate = pinkEggRate * 2
    end

    if spawnRoll <= goldEggRate then
        eggPrefab = GoldEggPrefab
    elseif spawnRoll <= goldEggRate + whiteEggRate then
        eggPrefab = WhiteEggPrefab
    elseif spawnRoll <= goldEggRate + whiteEggRate + pinkEggRate then
        eggPrefab = PinkEggPrefab
    else
        local regularEggIndex = math.random(1, math.min(#RegularEggPrefabs, 5))
        eggPrefab = RegularEggPrefabs[regularEggIndex]
    end

    local egg = Object.Instantiate(eggPrefab)
    egg.transform.position = position
    table.insert(eggs, egg)
    egg:GetComponent(Egg).EggDespawnEvent:Connect(function()
        for i, e in ipairs(eggs) do
            if e == egg then
                table.remove(eggs, i)
                break
            end
        end
    end)
end

function self:Update()
    local playerPosition = client.localPlayer.character:GetComponent(Transform).position
    local isInRange = false
    local inRangeEgg = nil

    for _, egg in ipairs(eggs) do
        local eggPosition = egg.transform.position
        if Vector3.Distance(playerPosition, eggPosition) <= EGG_RANGE then
            isInRange = true
            inRangeEgg = egg
            break
        end
    end

    if isInRange and not self.wasInRange then
        self.wasInRange = true
        eggInventoryHandler.EnteredEggRange(inRangeEgg:GetComponent(Egg))
        print("Entered egg range: " .. inRangeEgg:GetComponent(Egg).GetId())
    elseif not isInRange and self.wasInRange then
        self.wasInRange = false
        eggInventoryHandler.ExitedEggRange()
        print("Exited egg range")
    end
end