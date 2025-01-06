--!Type(UI)

--!Bind
local _cancelButton : UIButton = nil
--!Bind
local _cancelLabel : UILabel = nil

local ApiaryManager = require("ApiaryManager")
local placedObjectsManager = require("PlacedObjectsController")

_cancelButton:RegisterPressCallback(function()
    placedObjectsManager.Cancel()
end, true, true, true)

function Init()
    _cancelLabel:SetPrelocalizedText("Cancel")
    ApiaryManager.SetRemovalMode()

end