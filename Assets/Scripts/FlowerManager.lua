--!Type(Module)

--!SerializeField
local SpawnLocations : {GameObject} = nil

--!SerializeField
local Flowers : {GameObject} = nil

--!SerializeField
local InfoCard : GameObject = nil

local UIManager = require("UIManager")
local audioManager = require("AudioManager")
local playerManager = require("PlayerManager")

giveFlower = Event.new("giveFlowerEvent")

function self:ClientAwake()
 Timer.new(.2, function() TrySpawnFlower() end, true)
end

local MIN_SPAWN_DISTANCE = 45 

flowerAreaEnteredEvent = Event.new("FlowerAreaEnteredEvent")
flowerAreaExitedEvent = Event.new("FlowerAreaExitedEvent")

local flower : GameObject = nil
local id : string = nil
local desc : string = nil

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

function flowerAreaEntered(_flower, _id, _desc)

    if playerManager.GetPlayerOwnsShears() == false then
        return
    end

    flower = _flower
    id = _id
    desc = _desc
    flowerAreaEnteredEvent:Fire()
end

function getFlower()
    audioManager.PlaySound("cutSound", 1)
    UIManager.ToggleUI("BeeCard", true)
    UIManager.ToggleUI("PlaceButtons", false)
    UIManager.ToggleUI("PlayerStats", false)
    InfoCard:GetComponent(BeeObtainCard).ShowFlowerCut(id, desc)
    Timer.new(5.75, function() 
        UIManager.ToggleUI("BeeCard", false)
        UIManager.ToggleUI("PlaceButtons", true)
        UIManager.ToggleUI("PlayerStats", true) end, false)

    giveFlower:FireServer(id)


    Object.Destroy(flower)
    flowerAreaExitedEvent:Fire()
end

function flowerAreaExited()
    flowerAreaExitedEvent:Fire()
end

function self:ServerAwake()
    giveFlower:Connect(function(player, flower)
        local transaction = InventoryTransaction.new():GivePlayer(player, flower, 1)
        Inventory.CommitTransaction(transaction)
    end)
end