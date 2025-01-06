--!Type(UI)

--!Bind
local button : UIButton = nil

--!Bind
local _rotateClockwiseButton : UIButton = nil

--!Bind
local _rotateCounterClockwiseButton : UIButton = nil

--!Bind
local _confirm : UILabel = nil

placedObjectsManager = require("PlacedObjectsController")

button:RegisterPressCallback(function()
 placedObjectsManager.Confirm()
end, true, true, true)

_rotateClockwiseButton:RegisterPressCallback(function()
    placedObjectsManager.Rotate(90)
end, true, true, true)

_rotateCounterClockwiseButton:RegisterPressCallback(function()
    placedObjectsManager.Rotate(-90)
end, true, true, true)

function self:ClientAwake()
    _confirm:SetPrelocalizedText("Confirm")
end