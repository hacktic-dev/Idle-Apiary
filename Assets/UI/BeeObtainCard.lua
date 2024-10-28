--!Type(UI)

--!Bind
local _beeCard : VisualElement = nil
--!Bind
local _beeLabel : UILabel = nil
--!Bind
local _honeyRateLabel : UILabel = nil
--!Bind
local _sellPriceLabel : UILabel = nil
--!Bind
local _beeImage : UIImage = nil
--!Bind
local _rarity : UILabel = nil

local wildBeeManager = require("WildBeeManager")

local playerManager = require("PlayerManager")

_beeCard.visible = false

-- Initialize UI text and image

--_beeImage:SetImage("bee_image.png")

function SetVisible(enabled)
    _beeCard.visible = enabled
end

wildBeeManager.notifyCaptureSucceeded:Connect((function(species)
    _beeLabel:SetPrelocalizedText("You caught a wild " .. species .. "!")
    _rarity:SetPrelocalizedText(wildBeeManager.getRarity(species) .. " Bee")
    _honeyRateLabel:SetPrelocalizedText("Honey rate: " .. wildBeeManager.getHoneyRate(species))
    _sellPriceLabel:SetPrelocalizedText("Sell price: " .. wildBeeManager.getSellPrice(species))
    _beeCard.visible = true
    Timer.new(5, function() _beeCard.visible = false end, false)
end))

playerManager.notifyBeePurchased:Connect((function(species)
    _beeLabel:SetPrelocalizedText("You recieved a " .. species .. "!")
    _rarity:SetPrelocalizedText(wildBeeManager.getRarity(species) .. " Bee")
    _honeyRateLabel:SetPrelocalizedText("Honey rate: " .. wildBeeManager.getHoneyRate(species))
    _sellPriceLabel:SetPrelocalizedText("Sell price: " .. wildBeeManager.getSellPrice(species))
    _beeCard.visible = true
    Timer.new(5, function() _beeCard.visible = false end, false)
end))