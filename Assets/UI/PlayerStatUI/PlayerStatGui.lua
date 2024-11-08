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

--!Bind
local _openShopButton : UIButton = nil

--!Bind
local _viewTutorialButton : UIButton = nil

--!SerializeField
local BeeListObject : GameObject = nil

--!SerializeField
local ShopObject : GameObject = nil


-- Importing the PlayerManager module to handle player-related functionalities
local playerManager = require("PlayerManager")
local UIManager = require("UIManager")

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
    UIManager.OpenBeeList()
    playerManager.RequestBeeList()
end, true, true, true)

_beestiaryButton:RegisterPressCallback(function()
    UIManager.OpenBeestiary()
end, true, true, true)

_openShopButton:RegisterPressCallback(function()
    UIManager.OpenShop()
end, true, true, true)

_viewTutorialButton:RegisterPressCallback(function()
    UIManager.OpenTutorial()
end, true, true, true)

-- Initialize the UI with default values for role, cash, and XP
SetCashUI(100)
SetNetsUI(0)

function self:ClientAwake()
 playerManager.receiveBeeList:Connect(function(bees)
    BeeListObject:GetComponent(BeeListMenu).PopulateBeeList(bees)
 end)

 playerManager.beeCountUpdated:Connect(function(count)
    playerManager.clientBeeCount = count
    if count > 0 then
        _viewBeesButton:EnableInClassList("hidden", false)
    else
        _viewBeesButton:EnableInClassList("hidden", true)
        UIManager.CloseBeeList()
    end
    end)
end

function ShowButtons()
    _viewTutorialButton.visible = true
    _openShopButton.visible = true
    _beestiaryButton.visible = true
    _viewBeesButton.visible = true
end

function HideButtons(boolean : isVisible)
    _viewTutorialButton.visible = false
    _openShopButton.visible = false
    _beestiaryButton.visible = false
    _viewBeesButton.visible = false
end