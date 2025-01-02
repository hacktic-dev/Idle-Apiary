--!Type(UI)

--!Bind
local button : UIButton = nil

--!Bind
local cycleButton : UIButton = nil

placedObjectsManager = require("PlacedObjectsManager")

button:RegisterPressCallback(function()
 placedObjectsManager.Confirm()
end, true, true, true)

cycleButton:RegisterPressCallback(function()
 placedObjectsManager.Cycle()
end, true, true, true)