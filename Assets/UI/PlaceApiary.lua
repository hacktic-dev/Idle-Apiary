--!Type(UI)

--!Bind
local _statusLabel : UILabel = nil
--!Bind
local _placeApiaryButton : UIButton = nil

local ApiaryManager = require("ApiaryManager")

local hasPlacedApiary = false

--!Bind
local _CaptureButton : UIButton = nil

local wildBeeManager = require("WildBeeManager")
local audioManager = require("AudioManager")

-- Table to store the current UI state (whether the button is visible)
local captureUIVisible = true

local species = ""
local nearBee = nil


-- Function to place an apiary at the player's position
local function placeApiary()
    if not hasPlacedApiary then
        local player = client.localPlayer
        position = Vector3.new(0,0,0)
        -- Call the PlaceApiary function from your ApiaryManager
        ApiaryManager.apiaryPlacementRequest:FireServer(player, position)
    end
end

ApiaryManager.notifyApiaryPlacementFailed:Connect(function(reason)
    _statusLabel.visible = true
    local why = ""
    if reason == 1 then
        why = " You are too close to the border fence."
    elseif reason == 2 then
        why = " Try moving further away from spawn."
    elseif reason == 3 then
        why = " You are too close to another players apiary."
    end
    _statusLabel:SetPrelocalizedText("Apiary cannot not be placed here." .. why)
    Timer.new(5, function() _statusLabel.visible = false end, false)
end)

ApiaryManager.notifyApiaryPlacementSucceeded:Connect(function()
    _statusLabel:SetPrelocalizedText("")
    _statusLabel.visible = false
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
    _statusLabel:SetPrelocalizedText(why)
    _statusLabel.visible = true
    Timer.new(5, function() _statusLabel.visible = false end, false)
end)

-- Register a callback for when the button is pressed
_placeApiaryButton:RegisterPressCallback(function()
    placeApiary() -- Call the function to place an apiary
end, true, true, true)

function self:ClientAwake()
    _statusLabel.visible = false
end

-- Function to show the Capture Button
local function showCaptureButton()
    if not captureUIVisible then
        _CaptureButton.visible = true
        captureUIVisible = true
    end
end

-- Function to hide the Capture Button
local function hideCaptureButton()
    if captureUIVisible then
        _CaptureButton.visible = false
        captureUIVisible = false
    end
end

-- Function to handle the button press (captures the bee)
local function onCaptureButtonPressed(bee, speciesName)
    -- Send a signal to the capture script when the button is pressed
    wildBeeManager.captureBee(bee, species)
end

-- Register the button press callback
_CaptureButton:RegisterPressCallback(function()
    -- Assuming `player` and `bee` data is stored globally or passed here
    onCaptureButtonPressed(nearBee, species)
end, true, true, true)

-- Function to check player's proximity to bees and show the UI accordingly
local function updateCaptureUI(player)
    local isNearBee = false
    for _, data in ipairs(wildBeeManager.wildBees) do
        local bee = data.bee

        if wildBeeManager.isPlayerNearBee(player, bee) then
            --print(player.name .. " is close to a " .. data.speciesName .. " at position " .. tostring(bee.transform.position))
            nearBee = data.bee
            species = data.speciesName
            showCaptureButton() -- Show the button if the player is near a bee
            isNearBee = true
            break
        end
    end

    -- If the player is not near any bees, hide the capture button
    if not isNearBee then
        hideCaptureButton()
    end
end

-- Periodically update the Capture UI
function self:Update()
    hideCaptureButton()
    updateCaptureUI(client.localPlayer)
end
