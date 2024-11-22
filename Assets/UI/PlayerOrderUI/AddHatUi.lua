--!Type(UI)


--!Bind
local Hats_Root : UIScrollView = nil
--!Bind
local closeButton : UIButton = nil
--!Bind
local closeLabel : UILabel = nil

local UIManager = require("UIManager") 
local hatsManager = require("HatsManager")
local Utils = require("Utils")

function Init()
    closeLabel:SetPrelocalizedText("Close", true)
    Hats_Root:Clear()
    closeButton:RegisterPressCallback(function()
        UIManager.CloseAddHatMenu()
    end, true, true, true)

    hatsManager.queryOwnedHats:FireServer()
end

function AddHatCard(id, amount)
    local hatCard = UIButton.new()
    hatCard:AddToClassList("hat-item")

    local titleLabel = UILabel.new()
    titleLabel:AddToClassList("title")
    titleLabel:SetPrelocalizedText(Utils.LookupHatName(id))
    hatCard:Add(titleLabel)

    local image = UIImage.new()
    image:AddToClassList("hat-image")
    image:AddToClassList("image")
    image.image = Utils.HatImage[Utils.LookupHatName(id)]
    hatCard:Add(image)

    local amountLabel = UILabel.new()
    amountLabel:AddToClassList("amount")
    amountLabel:SetPrelocalizedText("x" .. amount)
    hatCard:Add(amountLabel)

    hatCard:RegisterPressCallback(function()
        --TODO
    end, true, true, true)

    Hats_Root:Add(hatCard)
end

function NoHats()
    local titleLabel = UILabel.new()
    titleLabel:AddToClassList("no-hats")
    titleLabel:SetPrelocalizedText("You don't have any hats :(")
    Hats_Root:Add(titleLabel)
end

function self:ClientAwake()
  
end
