--!Type(UI)

--!Bind
-- Binding the UILabel for displaying the player's current cash amount
local cashCount : UILabel = nil

--!Bind
-- Binding the UILabel for displaying the player's current nets
local xpCount : UILabel = nil

--!Bind
local _viewBeesButton : UIButton = nil

--!Bind
local _beestiaryButton : UIButton = nil

-- Importing the PlayerManager module to handle player-related functionalities
local playerManager = require("PlayerManager")

-- Function to set the cash count on the UI
function SetCashUI(cash)
    -- Converts the cash amount to string and updates the UI
    cashCount:SetPrelocalizedText(tostring(cash), true)
end

-- Function to set the nets on the UI
function SetNetsUI(nets)
    -- Converts XP to a formatted string to display progression and updates the UI
    xpCount:SetPrelocalizedText(tostring(nets), true)
end

_viewBeesButton:RegisterPressCallback(function()
    print("Button pressed")
end, true, true, true)

_beestiaryButton:RegisterPressCallback(function()
    print("Button pressed")
end, true, true, true)

-- Initialize the UI with default values for role, cash, and XP
SetCashUI(100)
SetNetsUI(0)
