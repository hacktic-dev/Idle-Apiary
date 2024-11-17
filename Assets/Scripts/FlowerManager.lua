--!Type(Module)

--!SerializeField
local SpawnLocations : {GameObject} = nil

--!SerializeField
local Flowers : {GameObject} = nil

--!SerializeField
local InfoCard : GameObject = nil

--!SerializeField
local flowerPlaceUi : GameObject = nil

local UIManager = require("UIManager")
local audioManager = require("AudioManager")
local playerManager = require("PlayerManager")
local apiaryManager = require("ApiaryManager")

giveFlower = Event.new("giveFlowerEvent")

function self:ClientAwake()
    Timer.new(.2, function() TrySpawnFlower() end, true)
end

local MIN_SPAWN_DISTANCE = 45 

flowerAreaEnteredEvent = Event.new("FlowerAreaEnteredEvent")
flowerAreaExitedEvent = Event.new("FlowerAreaExitedEvent")
apiaryCanPlaceFlower = Event.new("ApiaryCanPlaceFlowerEvent")
apiaryCannotPlaceFlower = Event.new("ApiaryCannotPlaceFlowerEvent")
queryOwnedFlowers = Event.new("queryOwnedFlowers")
recieveOwnedFlowers = Event.new("recieveOwnedFlowers")
noFlowersOwned = Event.new("noFlowersOwned")
requestPlaceFlower = Event.new("requestPlaceFlower")

clientSpawnFlower = Event.new("clientSpawnFlower")

local placedFlowers = {} -- Placed flowers across all players (server)

local spawnedFlowers = {} -- Spawned flowers on client

local flowerObjects = {
    ["Yellow"] = Flowers[1],
    ["Purple"] = Flowers[2],
    ["White"] = Flowers[3],
    ["Red"] = Flowers[4],
}

canPlaceFLower = true

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

    queryOwnedFlowers:Connect(function(player)
        Inventory.GetPlayerItems(player, 4, "", function(items, newCursorId, errorCode)

            if items == nil then
                print(errorCode)
            end

            if #items == 0 then 
                print("No owned flowers")
                noFlowersOwned:FireClient(player)
            end
            for index, item in items do
                recieveOwnedFlowers:FireClient(player, item.id, item.amount)
            end
        end)
    end)
end

function self:Update()
    if client == nil then
        return 
    end

    position = apiaryManager.GetLocalPlayerApiaryLocation()
    playerPosition = client.localPlayer.character:GetComponent(Transform).position

    -- Check if the player is within the square
    if (position ~= nil ) and (playerPosition.x >= position.x - 9 and playerPosition.x <= position.x + 9) and
    (playerPosition.z >= position.z - 9 and playerPosition.z <= position.z + 9) and playerManager.GetPlayerOwnsShears() then
        if canPlaceFLower == false then
            canPlaceFLower = true
            apiaryCanPlaceFlower:Fire()
        end
    else
        if canPlaceFLower == true then
            canPlaceFLower = false
            apiaryCannotPlaceFlower:Fire()
        end
    end
end

function LookupFlowerDescription(name)
    if name == "Red" then
        return "Increase honey rate by 0.1% for every bee of the SAME species in your apiary."
    elseif name == "Purple" then
        return "Increase honey rate by 0.1% for each player in the room."
    elseif name == "Yellow" then
        return "Increase honey rate by 0.1% for each bee wearing a hat."
    elseif name == "White" then
        return "Increase honey rate by 0.1% for each bee of a UNIQUE species in your apiary.";
    end
end

function PlaceFlower(name, position) -- client
    requestPlaceFlower:FireServer(name , position)
end

noFlowersOwned:Connect(function()
    flowerPlaceUi:GetComponent(PlaceFlowerUi).NoFlowers()
end)

recieveOwnedFlowers:Connect(function(name, amount)
    print("recieved!")
    flowerPlaceUi:GetComponent(PlaceFlowerUi).AddFlowerCard(name, amount)  
    end)

requestPlaceFlower:Connect(function(player, name, position)
    apiaryPosition = apiaryManager.GetPlayerApiaryLocation(player)
    localPosition = position - apiaryManager.GetPlayerApiaryLocation(player)

    local id = playerManager.GenerateUniqueID()

    clientSpawnFlower:FireAllClients(name, id, player, position)

    if placedFlowers[player] == nil then
        placedFlowers[player] = {}
    end

    local flower = {name = name, owner = player, position = localPosition, id}

    table.insert(placedFlowers[player], flower)
end)

clientSpawnFlower:Connect(function(name, id, owner, position)
    local flower = Object.Instantiate(flowerObjects[name])
    flower:GetComponent(Transform).position = position
    flower:GetComponent(Flower).SetOwner(owner)
    spawnedFlowers[id] = flower
end)