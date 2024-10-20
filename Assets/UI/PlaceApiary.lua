--!Type(UI)

--!Bind
local _statusLabel : UILabel = nil
--!Bind
local _placeApiaryButton : UIButton = nil

local ApiaryManager = require("ApiaryManager")

local hasPlacedApiary = false

-- Function to place an apiary at the player's position
local function placeApiary()
    if not hasPlacedApiary then
        local player = client.localPlayer
        position = Vector3.new(0,0,0)
        -- Call the PlaceApiary function from your ApiaryManager
        ApiaryManager.apiaryPlacementRequest:FireServer(player, position)
    end
end

ApiaryManager.notifyApiaryPlacementFailed:Connect(function()
    _statusLabel.visible = true
    _statusLabel:SetPrelocalizedText("Apiary cannot not be placed here.")
end)

ApiaryManager.notifyApiaryPlacementSucceeded:Connect(function()
    _statusLabel:SetPrelocalizedText("")
    _statusLabel.visible = false
    _placeApiaryButton.visible = false
end)

-- Register a callback for when the button is pressed
_placeApiaryButton:RegisterPressCallback(function()
    placeApiary() -- Call the function to place an apiary
end, true, true, true)

function self:ClientAwake()
    _statusLabel.visible = false
end