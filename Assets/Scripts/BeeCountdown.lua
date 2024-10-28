--!Type(Client)

local timeRemaining = 0
local id = nil
local isEnabled = false
local isOwningClient = false
local timeToUpdate = 5

playerManager = require("PlayerManager")

local isMeterInUse = false

--!SerializeField
local meterObject : GameObject = nil -- The UI GameObject associated with this task.

function InitiateMeter(duration, coolDown, startTime)
    isMeterInUse = true
    meterObject:GetComponent(TaskMeter).StartMeter(duration, coolDown, startTime)
end

function SetTimeRemaining(time)
    timeRemaining = time
end

function SetId(_id)
    id = _id
end

function Enable()
    isEnabled = true
end

function SetIsOwningClient()
    isOwningClient = true
end

function self:Start()
    if isMeterInUse == false then
        meterObject:GetComponent(TaskMeter).SetVisible(false)
    end
end

function self:Update()

    if isEnabled == false then
        return
    end

    if timeRemaining > 0 then
        timeRemaining -= Time.deltaTime
        timeToUpdate -= Time.deltaTime

        if timeToUpdate < 0 then
            playerManager.UpdateBeeAge(id, timeRemaining)
            timeToUpdate = 5
        end
    end

    if timeRemaining < 0 then
        print("Time ran out for bee with id " .. id)
        self:GetComponent(Transform).localScale = Vector3.new(1,1,1)
        meterObject:GetComponent(TaskMeter).SetVisible(false)
        if isOwningClient then
            playerManager.SetBeeAdult(id)
        end
        isEnabled = false
    end
end