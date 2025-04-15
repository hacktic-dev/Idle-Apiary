--!Type(UI)

--!Bind
local _card : VisualElement = nil
--!Bind
local _tutorial1 : UILabel = nil
--!Bind
local _tutorialImage : UIImage = nil
--!Bind
local closeButton : UIButton = nil
--!Bind
local closeLabel : UILabel = nil

local UIManager = require("UIManager")
local playerManager = require("PlayerManager")

playerInited = false

local tutorials = {
    default = {
        steps = {
            {
                text = "Welcome to Idle Apiary!\n\nTo get started, open the shop and buy your first bee from the bronze set, then find a good spot and place down your apiary to start generating honey.",
                imageClass = "shopkeeper-image",
                closeText = "Next",
            },
            {
                text = "When you purchase a bee, it will be a baybee. Baybees have to grow up into adult bees before they will start generating honey or can be sold.",
                imageClass = "baybee-image",
                closeText = "Next",
            },
            {
                text = "Each bee set contains 6 bees of varying rarities, and you'll receive a random bee from the set. You can also capture bees out in the wild, so purchase some Bee Nets from the 'Items' tab, and keep an eye out for rare bees.\n\nTry to collect them all!",
                imageClass = "bee-image",
                closeText = "Close",
            },
        },
        onComplete = function()
            if not playerInited then
                Timer.new(3, function() UIManager.ShowTutorial() ShowTutorial("event") end, false)
            end
            UIManager.HideTutorial()
            playerManager.IncrementStat("Cash", 0)
            playerManager.IncrementStat("Nets", 0)
        end,
    },
    secondJoin = {
        steps = {
            text = "Welcome back!\n\nPlace down your apiary again to continue where you left off.",
            imageClass = nil,
            closeText = "Close",
        },
        onComplete = function()
            UIManager.HideTutorial()
        end,
    },
    event = {
        steps = {
            {
                text = "Welcome to the Easter Egg Hunt event!\n\nSearch the map for Easter eggs hidden under trees and near objects. Collect them before they despawn!",
                imageClass = nil,
                closeText = "Next",
            },
            {
                text = "There are 8 egg colors to find: 5 regular and 3 rare. Rare eggs are harder to find but can be used to craft special bee eggs.",
                imageClass = nil,
                closeText = "Next",
            },
            {
                text = "Combine one of each regular egg to craft a bee egg. Place it in your apiary to hatch a unique Easter bee which can be sold for HR gold!.",
                imageClass = nil,
                closeText = "Next",
            },
            {
                text = "Rare eggs can be crafted to create rare bee eggs. These hatch into mythical bees with very high sell prices! Hatch a golden bee and win 1000 HR gold!",
                imageClass = nil,
                closeText = "Next",
            },
            {
                text = "Trade eggs with other players or exchange them for exclusive items. Complete daily quests and spin the wheel for more rewards!",
                imageClass = nil,
                closeText = "Close",
            },
        },
        onComplete = function()
            UIManager.HideTutorial()
        end,
    },
}

local currentTutorial = nil
local currentStep = 0

local function ShowStep()
    local step = currentTutorial.steps[currentStep]
    if not step then
        if currentTutorial.onComplete then
            currentTutorial.onComplete()
        end
        return
    end

    _tutorial1:SetPrelocalizedText(step.text)
    closeLabel:SetPrelocalizedText(step.closeText)

    if step.imageClass then
        _tutorialImage:RemoveFromClassList("shopkeeper-image")
        _tutorialImage:RemoveFromClassList("baybee-image")
        _tutorialImage:RemoveFromClassList("bee-image")
        _tutorialImage:RemoveFromClassList("romantic-image")
        _tutorialImage:RemoveFromClassList("leaderboard-image")
        _tutorialImage:AddToClassList(step.imageClass)
        _tutorialImage.visible = true
    else
        _tutorialImage.visible = false
    end
end

function Init(_playerInited)
    playerInited = _playerInited
    if playerManager.GetPlayerJoins() == 1 or playerInited then
        ShowTutorial("default")
    elseif playerManager.GetPlayerJoins() == 2 then
        ShowTutorial("secondJoin")
    elseif playerManager.GetLastJoinedVersion() == 3 then
        ShowTutorial("event")
    end
end

function ShowTutorial(tutorial)
    currentTutorial = tutorials[tutorial]
    currentStep = 1
    ShowStep()
end

function GetShouldShowTutorial()
    return playerManager.GetPlayerJoins() == 1 or playerManager.GetPlayerJoins() == 2 or playerManager.GetLastJoinedVersion() == 3
end

function self:ClientAwake()
    closeButton:RegisterPressCallback(function()
        currentStep = currentStep + 1
        ShowStep()
    end)
end
