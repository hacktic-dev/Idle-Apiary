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
local _leaderboardButton : UIButton = nil

--!Bind
local _viewTutorialButton : UIButton = nil

--!Bind
local _toggleBadgesButton : UIButton = nil

--!Bind
local _hamburgerButton : UIButton = nil

--!Bind
local _settingsButton : UIButton = nil

--!Bind
local versionText : UILabel = nil

--!SerializeField
local BeeListObject : GameObject = nil

--!SerializeField
local ShopObject : GameObject = nil


-- Importing the PlayerManager module to handle player-related functionalities
local playerManager = require("PlayerManager")
local UIManager = require("UIManager")
local festiveBeeManager = require("FestiveBeeManager")

local useHamburger = false

showBadges = true

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
    UIManager.HideAll()
    UIManager.OpenTutorialByPlayer()
end, true, true, true)

_hamburgerButton:RegisterPressCallback(function()
    OpenMenu()
end, true, true, true)

_settingsButton:RegisterPressCallback(function()
    OpenSettings()
end, true, true, true)

_toggleBadgesButton:RegisterPressCallback(function()
    playerManager.ToggleShowBadges()
end, true, true, true)

_leaderboardButton:RegisterPressCallback(function()
    UIManager.OpenLeaderboard()
end, true, true, true)


-- Initialize the UI with default values for role, cash, and XP
SetCashUI(100)
SetNetsUI(0)

function self:ClientAwake()

    _viewTutorialButton:AddToClassList("hide")
    _viewTutorialButton:AddToClassList("hide")
    _viewTutorialButton:AddToClassList("hide")
    _viewTutorialButton:AddToClassList("hide")
    _hamburgerButton:AddToClassList("hide")
    versionText:SetPrelocalizedText("")

    playerManager.setPlayerVersionString:Connect(function(string)
        versionText:SetPrelocalizedText(string)
    end)

    if Screen.height > Screen.width then
        useHamburger = true
    end

    ShowMenu()
    CloseSettings()

 playerManager.receiveBeeList:Connect(function(bees)
    BeeListObject:GetComponent(BeeListMenu).PopulateBeeList(bees)
 end)

 playerManager.beeCountUpdated:Connect(function(count)
    playerManager.clientBeeCount = count
    print("Bee count: " .. count)
    if count > 0 then
        _viewBeesButton:EnableInClassList("hidden", false)
    else
        _viewBeesButton:EnableInClassList("hidden", true)
        UIManager.CloseBeeList()
    end
    end)
end

function OpenSettings()
    _viewTutorialButton:EnableInClassList("hide", false)
    _toggleBadgesButton:EnableInClassList("hide", false)
    _settingsButton:EnableInClassList("hide", true)
end

function CloseSettings()
    _viewTutorialButton:EnableInClassList("hide", true)
    _toggleBadgesButton:EnableInClassList("hide", true)
    _settingsButton:EnableInClassList("hide", false)
end


function OpenMenu()
    _openShopButton:EnableInClassList("hide", false)
    _beestiaryButton:EnableInClassList("hide", false)
    _viewBeesButton:EnableInClassList("hide", false)
    _leaderboardButton:EnableInClassList("hide", false)
    _hamburgerButton:EnableInClassList("hide", true)
end

function ShowMenu()
    _openShopButton:EnableInClassList("hide", useHamburger)
    _beestiaryButton:EnableInClassList("hide", useHamburger)
    _viewBeesButton:EnableInClassList("hide", useHamburger)
    _leaderboardButton:EnableInClassList("hide", useHamburger)
    _hamburgerButton:EnableInClassList("hide", not useHamburger)
end

function ShowButtons()
    _viewTutorialButton.visible = true
    _openShopButton.visible = true
    _beestiaryButton.visible = true
    _viewBeesButton.visible = true
    _hamburgerButton.visible = true
    _settingsButton.visible = true
    _toggleBadgesButton.visible = true
    _leaderboardButton.visible = true
end

function HideButtons(boolean : isVisible)
    _viewTutorialButton.visible = false
    _openShopButton.visible = false
    _beestiaryButton.visible = false
    _viewBeesButton.visible = false
    _hamburgerButton.visible = false
    _settingsButton.visible = false
    _toggleBadgesButton.visible = false
    _leaderboardButton.visible = false
end