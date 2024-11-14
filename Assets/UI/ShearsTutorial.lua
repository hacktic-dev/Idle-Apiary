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
    _tutorial1:SetPrelocalizedText("Shears tutorial test 1")
    _tutorialImage:RemoveFromClassList("bee-image")
    _tutorialImage:AddToClassList("shopkeeper-image")
end

function self:ClientAwake()

    closeButton:RegisterPressCallback(function()
        if page == 0 then
            _tutorial1:SetPrelocalizedText("Shears tutorial test 2")
            closeLabel:SetPrelocalizedText("Next")
            _tutorialImage:RemoveFromClassList("shopkeeper-image")
            _tutorialImage:AddToClassList("baybee-image")
            page = 1
        elseif page == 1 then
            _tutorial1:SetPrelocalizedText("Shears tutorial test 3")
            closeLabel:SetPrelocalizedText("Close")
            _tutorialImage:RemoveFromClassList("baybee-image")
            _tutorialImage:AddToClassList("bee-image")
            page = 2
        elseif page == 2 then
            UIManager.CloseShearsTutorial()
            playerManager.IncrementStat("Cash", 0)
            playerManager.IncrementStat("Nets", 0)
        end
    
    end)
end