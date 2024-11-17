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
    _tutorial1:SetPrelocalizedText("Congratulations on your new shears! Keep an eye out for flowers growing that you can pick.")
    _tutorialImage:AddToClassList("image-1")
end

function self:ClientAwake()

    closeButton:RegisterPressCallback(function()
        if page == 0 then
            _tutorial1:SetPrelocalizedText("Once you've got some flowers, you can plant them in your apiary to increase your honey generation.")
            closeLabel:SetPrelocalizedText("Next")
            _tutorialImage:RemoveFromClassList("image-1")
            _tutorialImage:AddToClassList("image-2")
            page = 1
        elseif page == 1 then
            _tutorial1:SetPrelocalizedText("Each type of flower has a different effect, so mix and match them to find the best combination for you!")
            closeLabel:SetPrelocalizedText("Close")
            _tutorialImage:RemoveFromClassList("image-3")
            _tutorialImage:AddToClassList("image-3")
            page = 2
        elseif page == 2 then
            UIManager.CloseShearsTutorial()
            playerManager.IncrementStat("Cash", 0)
            playerManager.IncrementStat("Nets", 0)
        end
    
    end)
end