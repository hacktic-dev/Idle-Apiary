--!Type(ClientAndServer)

isHatching = false

placedObjectsController = require("PlacedObjectsController")
playerManager = require("PlayerManager")

hatchTimePassed = 0
eggHatchTime = 10 -- seconds

objectId = nil
eggId = nil
ownerPlayer = nil

hatchTimes = {
    ["Regular Bee Egg"] = 15, --300
    ["Pink Bee Egg"] = 30, --600
    ["White Bee Egg"] = 45, --900
    ["gold_bee_egg"] = 60, --1200
}

function InitEgg(player, _eggId, _objectId)
    ownerPlayer = player
    objectId = _objectId
    eggId = _eggId
    isHatching = true
    eggHatchTime = hatchTimes[eggId] or 10
end

function self:Update()
    if isHatching == false then
        return
    end
    hatchTimePassed += Time.deltaTime
    --print("egg ".. objectId .. " hatch time passed: " .. hatchTimePassed .. " / " .. eggHatchTime)

    if hatchTimePassed >= eggHatchTime then
       --TODO
       print("egg ".. objectId .. " hatched")
       placedObjectsController.RequestObjectDeletion:Fire(ownerPlayer, objectId, false)
       playerManager.GiveEasterBee(ownerPlayer, eggId)
    end
end