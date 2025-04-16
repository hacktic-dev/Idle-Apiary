--!Type(ClientAndServer)

--!SerializeField
local Meter : TaskMeter = nil

isHatching = false

placedObjectsController = require("PlacedObjectsController")
playerManager = require("PlayerManager")

hatchTimePassed = NumberValue.new("hatchTimePassed", 0)
eggHatchTime = NumberValue.new("hatchTime", 0)

objectId = nil
eggId = nil
ownerPlayer = nil

hatchTimes = {
    ["Regular Bee Egg"] = 300, --300
    ["Pink Bee Egg"] = 600, --600
    ["White Bee Egg"] = 900, --900
    ["Golden Bee Egg"] = 1200, --1200
}

function InitEgg(player, _eggId, _objectId)
    ownerPlayer = player
    objectId = _objectId
    eggId = _eggId
    isHatching = true
    eggHatchTime.value = hatchTimes[eggId] or 10
end

function self:Update()
    if isHatching == false then
        return
    end

    hatchTimePassed.value = hatchTimePassed.value + Time.deltaTime

    if hatchTimePassed.value >= eggHatchTime.value then
       --TODO
       playerManager.GiveEasterBee(ownerPlayer, eggId)
       placedObjectsController.RequestObjectDeletion:Fire(ownerPlayer, objectId, false)
    end
end

function self:ClientAwake()
    eggHatchTime.Changed:Connect(function(newValue)
        Meter.StartMeter(newValue, 0, 0)
    end)
end