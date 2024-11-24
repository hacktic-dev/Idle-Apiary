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

local UIManager = require("UIManager")
local playerManager = require("PlayerManager")

function Init()
    if playerManager.GetPlayerJoins() == 1 then
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
    else
        UIManager.HideTutorial()
        playerManager.IncrementStat("Cash", 0)
        playerManager.IncrementStat("Nets", 0)
    end
end

function self:ClientAwake()

    closeButton:RegisterPressCallback(function()

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
            _tutorial1:SetPrelocalizedText("Each bee set contains 6 bees of varying rarities, and you'll recieve a random bee from the set. You can also capture bees out in the wild, so stock up on bee nets and keep an eye out for rare bees.\n\nTry to collect them all!")
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