--!Type(Client)

local timeRemaining = 0
local id = nil
local isEnabled = false

playerManager = require("PlayerManager")

function SetTimeRemaining(time)
    timeRemaining = time
end

function SetId(_id)
    id = _id
end

function Enable()
    isEnabled = true
end

function self:Update()

    if isEnabled == false then
        return
    end

    timeRemaining -= Time.deltaTime

    if timeRemaining < 0 then
        print("Time ran out for bee with id " .. id)
        self:GetComponent(TaskMeter).SetVisible(false)
        self:GetComponent(Transform).localScale = Vector3.new(1,1,1)
        playerManager.SetBeeAdult(id)
        isEnabled = false
    end
end