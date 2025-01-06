--!Type(UI)

--!Bind
local _placeApiaryButton : UIButton = nil

local ApiaryManager = require("ApiaryManager")

local hasPlacedApiary = false

--!SerializeField
local statusObject : GameObject = nil

--!Bind
local _CaptureButton : UIButton = nil
--!Bind
local _PickFlowerButton : UIButton = nil
--!Bind
local _PlaceFlowerButton : UIButton = nil
--!Bind
local _PlaceFurnitureButton : UIButton = nil
--!Bind
local _RemoveFurnitureButton : UIButton = nil

local wildBeeManager = require("WildBeeManager")
local audioManager = require("AudioManager")
local UIManager = require("UIManager")
local flowerManager = require("FlowerManager")
local festiveBeeManager = require("FestiveBeeManager")

-- Table to store the current UI state (whether the button is visible)
local captureUIVisible = true

local species = ""
local nearBee = nil


-- Function to place an apiary at the player's position
local function placeApiary()
    if not hasPlacedApiary then
        local player = client.localPlayer
        position = player.character:GetComponent(Transform).position
        -- Call the PlaceApiary function from your ApiaryManager
        ApiaryManager.apiaryPlacementRequest:FireServer(position)
    end
end

ApiaryManager.notifyApiaryPlacementFailed:Connect(function(reason)
    UIManager.ToggleUI("PlaceStatus", true)
    local why = ""
    if reason == 1 then
        why = " You are too close to the border fence."
    elseif reason == 2 then
        why = " Try moving further away from spawn."
    elseif reason == 3 then
        why = " You are too close to another players apiary."
    end
    statusObject:GetComponent("PlaceApiaryStatus").SetStatus("Apiary cannot not be placed here." .. why)
    audioManager.PlaySound("failSound", .75)
    Timer.new(3.5, function() UIManager.ToggleUI("PlaceStatus", false) end, false)
end)

ApiaryManager.notifyApiaryPlacementSucceeded:Connect(function(position)
    UIManager.ToggleUI("PlaceStatus", false)
    ApiaryManager.localApiaryPosition = position 
    _placeApiaryButton.visible = false
    audioManager.PlaySound("placeSound", 1)
end)

wildBeeManager.notifyCaptureFailed:Connect(function(reason)
    local why = ""
    if reason == 1 then
        why = "You don't have any bee nets!"
    elseif reason == 2 then
        why = "You already have the maximum number of bees."
    end
    statusObject:GetComponent("PlaceApiaryStatus").SetStatus(why)
    audioManager.PlaySound("failSound", .75)
    UIManager.ToggleUI("PlaceStatus", true)
    Timer.new(3.5, function() UIManager.ToggleUI("PlaceStatus", false) end, false)
end)

-- Register a callback for when the button is pressed
_placeApiaryButton:RegisterPressCallback(function()
    placeApiary() -- Call the function to place an apiary
end, true, true, true)

local function toggleUIElement(element, shouldShow)
    if shouldShow then
        element:AddToClassList("shown")
        element:RemoveFromClassList("hidden")
    else
        element:AddToClassList("hidden")
        element:RemoveFromClassList("shown")
    end
end

-- Function to handle the button press (captures the bee)
local function onCaptureButtonPressed(bee, speciesName)
    -- Send a signal to the capture script when the button is pressed
    if speciesName == "Festive Bee" then
        festiveBeeManager.captureBee(bee)
        return
    end

    wildBeeManager.captureBee(bee, species)
end

-- Register the button press callback
_CaptureButton:RegisterPressCallback(function()
    -- Assuming `player` and `bee` data is stored globally or passed here
    onCaptureButtonPressed(nearBee, species)
end, true, true, true)

_PickFlowerButton:RegisterPressCallback(function()
    flowerManager.getFlower()
end, true, true, true
)

_PlaceFlowerButton:RegisterPressCallback(function()
    UIManager.OpenPlaceFlowerMenu()
end, true, true, true
)

_PlaceFurnitureButton:RegisterPressCallback(function()
    UIManager.OpenPlaceFurnitureMenu()
end, true, true, true
)

_RemoveFurnitureButton:RegisterPressCallback(function()
    UIManager.OpenRemoveFurnitureMenu()
end, true, true, true
)

-- Function to check player's proximity to bees and show the UI accordingly
local function updateCaptureUI(player)
    local isNearBee = false
    for _, data in ipairs(wildBeeManager.wildBees) do
        local bee = data.bee

        if wildBeeManager.isPlayerNearBee(player, bee) then
            --print(player.name .. " is close to a " .. data.speciesName .. " at position " .. tostring(bee.transform.position))
            nearBee = data.bee
            species = data.speciesName
            toggleUIElement(_CaptureButton, true) -- Show the button if the player is near a bee
            isNearBee = true
            break
        end
    end

    -- If the player is not near any bees, hide the capture button
    if not isNearBee then
        toggleUIElement(_CaptureButton, false)
    end
end

-- Periodically update the Capture UI
function self:Update()
    toggleUIElement(_CaptureButton, false)
    updateCaptureUI(client.localPlayer)
end

function self:ClientAwake()
    toggleUIElement(_PickFlowerButton, false)
    toggleUIElement(_PlaceFlowerButton, false)
    toggleUIElement(_PlaceFurnitureButton, false)

    Timer.new(0.5, function()
        if _placeApiaryButton.visible == false then
            return
        end
        position = client.localPlayer.character:GetComponent(Transform).position
         ApiaryManager.requestIsValidLocation:FireServer(position)
    end, true)

    ApiaryManager.notifyIsValidLocation:Connect(function(isValid) 
        if isValid then
            _placeApiaryButton:AddToClassList("primary-button")
            _placeApiaryButton:RemoveFromClassList("greyed-out-button")
        else
            _placeApiaryButton:RemoveFromClassList("primary-button")
            _placeApiaryButton:AddToClassList("greyed-out-button")
        end
    end)

    flowerManager.flowerAreaEnteredEvent:Connect(function()
        toggleUIElement(_PickFlowerButton, true)
    end)

    flowerManager.flowerAreaExitedEvent:Connect(function()
        toggleUIElement(_PickFlowerButton, false)
    end)

    flowerManager.apiaryPlayerStatusChanged:Connect(function(inApiary, hasShears)
        toggleUIElement(_PlaceFlowerButton, inApiary and hasShears)
        toggleUIElement(_PlaceFurnitureButton, inApiary)
        toggleUIElement(_RemoveFurnitureButton, inApiary)
    end)
end