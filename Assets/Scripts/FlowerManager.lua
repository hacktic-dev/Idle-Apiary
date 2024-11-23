--!Type(Module)

--!SerializeField
local SpawnLocations : {GameObject} = nil

--!SerializeField
local Flowers : {GameObject} = nil

--!SerializeField
local InfoCard : GameObject = nil

--!SerializeField
local flowerPlaceUi : GameObject = nil

--!SerializeField
local statusObject : GameObject = nil

local UIManager = require("UIManager")
local audioManager = require("AudioManager")
local playerManager = require("PlayerManager")
local apiaryManager = require("ApiaryManager")

giveFlower = Event.new("giveFlowerEvent")

function self:ClientAwake()
    Timer.new(12, function() TrySpawnFlower() end, true)
end

local MIN_SPAWN_DISTANCE = 45 

flowerAreaEnteredEvent = Event.new("FlowerAreaEnteredEvent")
flowerAreaExitedEvent = Event.new("FlowerAreaExitedEvent")
apiaryCanPlaceFlower = Event.new("ApiaryCanPlaceFlowerEvent")
apiaryCannotPlaceFlower = Event.new("ApiaryCannotPlaceFlowerEvent")
queryOwnedFlowers = Event.new("queryOwnedFlowers")
recieveOwnedFlowers = Event.new("recieveOwnedFlowers")
noFlowersOwned = Event.new("noFlowersOwned")
requestPlaceFlower = Event.new("requestPlaceFlower") -- client to server
removeFlowerRequest = Event.new("removeFlowerRequest") -- server to client
clientSpawnFlower = Event.new("clientSpawnFlower") -- server to client
notifyFlowerPlacementFailed = Event.new("notifyFlowerPlacementFailed")

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
local nearOwner = nil
local nearPlacedId = nil

local apiaryPosition = nil

function GetPlacedFlowers(player)
    return placedFlowers[player]
end

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

function flowerAreaEntered(_flower, _id, _desc, _owner, _placedId)

    if playerManager.GetPlayerOwnsShears() == false then
        return
    end

    flower = _flower
    id = _id
    desc = _desc
    nearOwner = _owner
    nearPlacedId = _placedId
    flowerAreaEnteredEvent:Fire()
end

function getFlower()
    audioManager.PlaySound("cutSound", 1)
    UIManager.ToggleUI("BeeCard", true)
    UIManager.ToggleUI("PlaceButtons", false)
    UIManager.ToggleUI("PlayerStats", false)
    InfoCard:GetComponent(InfoCard).ShowFlowerCut(id, desc)
    Timer.new(5.75, function() 
        UIManager.ToggleUI("BeeCard", false)
        UIManager.ToggleUI("PlaceButtons", true)
        UIManager.ToggleUI("PlayerStats", true) end, false)

    giveFlower:FireServer(id, nearOwner, nearPlacedId)

    Object.Destroy(flower)
    flowerAreaExitedEvent:Fire()
end

function flowerAreaExited()
    flowerAreaExitedEvent:Fire()
end

function self:ServerAwake()
    giveFlower:Connect(function(player, flower, owner, placedId)

        if owner ~= nil then
            print(placedId)

            for index, flower in ipairs(placedFlowers[player]) do
                if flower.id == placedId then
                    table.remove(placedFlowers[player], index)
                    playerManager.RecalculatePlayerEarnRate(player)
                end
            end

            removeFlowerRequest:FireAllClients(placedId)
        end

        local transaction = InventoryTransaction.new():GivePlayer(player, flower, 1)
        Inventory.CommitTransaction(transaction)
    end)

    queryOwnedFlowers:Connect(function(player)
        Inventory.GetPlayerItems(player, 25, "", function(items, newCursorId, errorCode)
            if items == nil then
                print(errorCode)
            end

            flowersOwned = false

            for index, item in items do
                if item.id == "Red" or item.id == "Yellow" or item.id == "White" or item.id == "Purple" then
                    recieveOwnedFlowers:FireClient(player, item.id, item.amount)
                    flowersOwned = true
                end
            end

            if flowersOwned == false then 
                print("No owned flowers")
                noFlowersOwned:FireClient(player)
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

function RemoveAllPlayerFlowers(player) -- server
    print("removing all flowers for player " .. player.name)
    if placedFlowers[player] then
        for _ , flower in ipairs(placedFlowers[player]) do
            local id = flower.id

            removeFlowerRequest:FireAllClients(id)
        end

        placedFlowers[player] = nil
    end
end

function SaveFlowerPositions(player, id) -- server
    if placedFlowers[player] ~= nil then
        Storage.SetValue(id .. "/" .. "PlacedFlowers", placedFlowers[player], function(errorCode) end)
    end
end

function SpawnPlayerFlowersOnAllClients(player, _apiaryPosition)
    apiaryPosition = _apiaryPosition
    Storage.GetPlayerValue(player, "PlacedFlowers", function(storedFlowers, errorCode)

        if storedFlowers == nil then
            placedFlowers[player] = {}
            playerManager.RecalculatePlayerEarnRate(player)
            return
        end
        
        placedFlowers[player] = storedFlowers
        playerManager.RecalculatePlayerEarnRate(player)

        for _, flower in ipairs(storedFlowers) do
            clientSpawnFlower:FireAllClients(flower.name, flower.id, player.user.id, apiaryPosition + flower.position)
        end
    end)
end

function SpawnAllFlowersForIncomingPlayer(player)
    for owner, flowerList in pairs(placedFlowers) do
        for _, flower in ipairs(flowerList) do
            clientSpawnFlower:FireClient(player, flower.name, flower.id, owner.user.id, apiaryManager.GetPlayerApiaryLocation(owner) + flower.position)
        end
    end
end

noFlowersOwned:Connect(function()
    flowerPlaceUi:GetComponent(PlaceFlowerUi).NoFlowers()
end)

recieveOwnedFlowers:Connect(function(name, amount)
    print("recieved!")
    flowerPlaceUi:GetComponent(PlaceFlowerUi).AddFlowerCard(name, amount)  
    end)

requestPlaceFlower:Connect(function(player, name, position)

    if#placedFlowers[player] == playerManager.GetPlayerFlowerCapacity(player) then
        notifyFlowerPlacementFailed:FireClient(player)
        return
    end

    apiaryPosition = apiaryManager.GetPlayerApiaryLocation(player)
    localPosition = position - apiaryManager.GetPlayerApiaryLocation(player)

    local id = playerManager.GenerateUniqueID()

    clientSpawnFlower:FireAllClients(name, id, player.user.id, position)

    if placedFlowers[player] == nil then
        placedFlowers[player] = {}
    end

    local flower = {name = name, owner = player.user.id, position = localPosition, id = id}

    table.insert(placedFlowers[player], flower)
    playerManager.RecalculatePlayerEarnRate(player)

    local transaction = InventoryTransaction.new():TakePlayer(player, name, 1)
    Inventory.CommitTransaction(transaction)
end)

clientSpawnFlower:Connect(function(name, id, userId, position)
    local flower = Object.Instantiate(flowerObjects[name])
    flower:GetComponent(Transform).position = position
    flower:GetComponent(Flower).SetOwner(userId)
    flower:GetComponent(Flower).SetPlacedId(id)
    spawnedFlowers[id] = flower
end)

removeFlowerRequest:Connect(function(id)
    print("removing flower with id " .. id)
    if spawnedFlowers[id] then
        Object.Destroy(spawnedFlowers[id])
        spawnedFlowers[id] = nil
    end
 end)

 notifyFlowerPlacementFailed:Connect(function()
    statusObject:GetComponent("PlaceApiaryStatus").SetStatus("You already have the maximum number of flowers placed.")
    UIManager.ToggleUI("PlaceStatus", true)
    Timer.new(3.5, function() UIManager.ToggleUI("PlaceStatus", false) end, false)
 end)