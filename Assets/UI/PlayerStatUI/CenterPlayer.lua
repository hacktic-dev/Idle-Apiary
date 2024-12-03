--!Type(UI)

--!SerializeField
local Camera : GameObject = nil

--!Bind
local center_player : VisualElement = nil

--!Bind
local button : UIButton = nil

--!Bind
local button_home : UIButton = nil

playerManager = require("PlayerManager")

button:RegisterPressCallback(function()
Camera:GetComponent(CustomCamera).FocusOnPlayer()
end, true, true, true)

button_home:RegisterPressCallback(function()
    playerManager.requestApiaryLocation:FireServer();
    end, true, true, true)

function self:ClientAwake()
    playerManager.notifyApiaryLocation:Connect(function(position)
    if position == nil then
        return
    end

    center_player.pickingMode = none;

    print("position: " .. tostring(position))

    Camera:GetComponent(CustomCamera).FocusOnApiary(position)
    end)
end