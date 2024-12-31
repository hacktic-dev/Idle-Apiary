--!Type(UI)

--!Bind
local button : UIButton = nil

placedObjectsManager = require("PlacedObjectsManager")

button:RegisterPressCallback(function()
 placedObjectsManager.Confirm()
end, true, true, true)