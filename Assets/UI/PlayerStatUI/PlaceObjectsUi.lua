--!Type(UI)

--!Bind
local _confirmButton : UIButton = nil

--!Bind
local _cancelButton : UIButton = nil

--!Bind
local _rotateClockwiseButton : UIButton = nil

--!Bind
local _rotateCounterClockwiseButton : UIButton = nil

--!Bind
local _confirmLabel : UILabel = nil

--!Bind
local _cancelLabel : UILabel = nil

placedObjectsManager = require("PlacedObjectsController")

_confirmButton:RegisterPressCallback(function()
 placedObjectsManager.Confirm()
end, true, true, true)

_rotateClockwiseButton:RegisterPressCallback(function()
    placedObjectsManager.Rotate(90)
end, true, true, true)

_rotateCounterClockwiseButton:RegisterPressCallback(function()
    placedObjectsManager.Rotate(-90)
end, true, true, true)

_cancelButton:RegisterPressCallback(function()
    placedObjectsManager.Cancel()
end, true, true, true)

function self:ClientAwake()
    _confirmLabel:SetPrelocalizedText("Confirm")
    _cancelLabel:SetPrelocalizedText("Cancel")

    placedObjectsManager.setConfirmButtonState:Connect(function(state)
        print("state changed")
        _confirmButton.visible = state
        _rotateClockwiseButton.visible = state
        _rotateCounterClockwiseButton.visible = state
    end)
end