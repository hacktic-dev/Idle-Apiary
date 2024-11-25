--!Type(UI)

--!SerializeField
local Camera : GameObject = nil

--!Bind
local button : UIButton = nil

button:RegisterPressCallback(function()
Camera:GetComponent(CustomCamera).FocusOnPlayer()
end, true, true, true)