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

local page = 0

local showingEventTutorial = false

local UIManager = require("UIManager")
local playerManager = require("PlayerManager")

function Init(playerInited)
    if playerManager.GetPlayerJoins() == 1 or playerInited then
        page = 0
        closeLabel:SetPrelocalizedText("Next")
        _tutorial1:SetPrelocalizedText("Welcome to Idle Apiary!\n\nTo get started, open the shop and buy your first bee from the bronze set, then find a good spot and place down your apiary to start generating honey.")
        _tutorialImage.visible = true
        _tutorialImage:RemoveFromClassList("bee-image")
        _tutorialImage:AddToClassList("shopkeeper-image")
    elseif playerManager.GetPlayerJoins() == 2 then
        page = 0
        closeLabel:SetPrelocalizedText("Close")
        _tutorial1:SetPrelocalizedText("Welcome back!\n\nPlace down your apiary again to continue where you left off.")
        _tutorialImage.visible = false
    elseif playerManager.GetLastJoinedVersion() == 0 then
        showingEventTutorial = true
        closeLabel:SetPrelocalizedText("Next")
        _tutorial1:SetPrelocalizedText("Welcome to the Festive Event!\n\nKeep an eye out for festive bees that rarely appear in the world. These bees can be sold to receive HR gold!")
        _tutorialImage.visible = true
        _tutorialImage:AddToClassList("festive-image")
        _tutorialImage:RemoveFromClassList("hidden")
    else
        UIManager.HideTutorial()
        playerManager.IncrementStat("Cash", 0)
        playerManager.IncrementStat("Nets", 0)
    end
end

function self:ClientAwake()

    closeButton:RegisterPressCallback(function()

        if showingEventTutorial then
            if page == 0 then
                _tutorial1:SetPrelocalizedText("Check the leaderboard to see who has caught the most festive bees.\n\nGold prizes will be given out for the top 10 players at the end of the event.")
                closeLabel:SetPrelocalizedText("Next")
                _tutorialImage:RemoveFromClassList("festive-image")
                _tutorialImage:AddToClassList("leaderboard-image")
                page = 1
            elseif page == 1 then
                _tutorial1:SetPrelocalizedText("The event ends at midnight CET, 31st December.\n\n1st Place : 10,000 Gold\n2nd Place : 5,000 Gold\n3rd Place : 2,000 Gold\n4th Place : 1,000 Gold\n5th Place : 500 Gold\n6th-10th Place : 100 Gold")
                closeLabel:SetPrelocalizedText("Close")
                _tutorialImage:RemoveFromClassList("leaderboard-image")
                _tutorialImage:AddToClassList("hidden")
                page = 2
            elseif page == 2 then
                UIManager.HideTutorial()
            end
            return
        end

        if playerManager.GetPlayerJoins() == 2 then
            UIManager.HideTutorial()
            playerManager.IncrementStat("Cash", 0)
            playerManager.IncrementStat("Nets", 0)
            return
        end

        if page == 0 then
            _tutorial1:SetPrelocalizedText("When you purchase a bee, it will be a baybee. Baybees have to grow up into adult bees before they will start generating honey or can be sold.")
            closeLabel:SetPrelocalizedText("Next")
            _tutorialImage:RemoveFromClassList("shopkeeper-image")
            _tutorialImage:AddToClassList("baybee-image")
            page = 1
        elseif page == 1 then
            _tutorial1:SetPrelocalizedText("Each bee set contains 6 bees of varying rarities, and you'll receive a random bee from the set. You can also capture bees out in the wild, so purchase some Bee Nets from the 'Items' tab, and keep an eye out for rare bees.\n\nTry to collect them all!")
            closeLabel:SetPrelocalizedText("Close")
            _tutorialImage:RemoveFromClassList("baybee-image")
            _tutorialImage:AddToClassList("bee-image")
            page = 2
        elseif page == 2 then
            UIManager.HideTutorial()
            playerManager.IncrementStat("Cash", 0)
            playerManager.IncrementStat("Nets", 0)
        end
    
    end)
end