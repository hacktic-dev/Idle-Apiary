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
    page = 0
    closeLabel:SetPrelocalizedText("Next")
    _tutorial1:SetPrelocalizedText("Welcome to Idle Apiary!\n\nTo get started, talk to the shopkeeper and buy your first bee from the bronze set, then find a good spot and place down your apiary to start generating honey.")
    _tutorialImage:AddToClassList("shopkeeper-image")

    closeButton:RegisterPressCallback(function()
        if page == 0 then
            _tutorial1:SetPrelocalizedText("Each bee set contains 6 bees of varying rarities, and you'll recieve a random bee from the set. You can also capture bees out in the wild, so stock up on bee nets and keep an eye out for rare bees.\n\nCollect them all for a special reward!")
            closeLabel:SetPrelocalizedText("Close")
            _tutorialImage:RemoveFromClassList("shopkeeper-image")
            _tutorialImage:AddToClassList("bee-image")
            page = 1
        elseif page == 1 then
            UIManager.HideTutorial()
            playerManager.IncrementStat("Cash", 0)
            playerManager.IncrementStat("Nets", 0)
        end
    
    end)
end