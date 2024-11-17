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

-- Initialize UI text and image

function ShowCaughtWild(species)
    _beeLabel:SetPrelocalizedText("You caught a wild " .. species .. "!")
    _rarity:SetPrelocalizedText(wildBeeManager.getRarity(species) .. " Bee")
    _honeyRateLabel:SetPrelocalizedText("Honey rate: " .. wildBeeManager.getHoneyRate(species))
    _sellPriceLabel:SetPrelocalizedText("Sell price: " .. wildBeeManager.getSellPrice(species))
end

function ShowRecieved(species)
    _beeLabel:SetPrelocalizedText("You recieved a " .. species .. "!")
    _rarity:SetPrelocalizedText(wildBeeManager.getRarity(species) .. " Bee")
    _honeyRateLabel:SetPrelocalizedText("Honey rate: " .. wildBeeManager.getHoneyRate(species))
    _sellPriceLabel:SetPrelocalizedText("Sell price: " .. wildBeeManager.getSellPrice(species))
end

function ShowFlowerCut(name, effect)
    _beeLabel:SetPrelocalizedText("You picked a " .. name .. " flower!")
    _rarity:SetPrelocalizedText(effect)
    _honeyRateLabel:SetPrelocalizedText("")
    _sellPriceLabel:SetPrelocalizedText("")
end

function showPurchasedHoney(id)
    if id == "honey_1" then
        _beeLabel:SetPrelocalizedText("You purchased 250 honey!")
    elseif id == "honey_2" then
        _beeLabel:SetPrelocalizedText("You purchased 1000 honey!")
    elseif id == "honey_3" then
        _beeLabel:SetPrelocalizedText("You purchased 3000 honey!")
    end

    _rarity:SetPrelocalizedText("Thank you for your purchase!")
    _honeyRateLabel:SetPrelocalizedText("Please reach out to hacktic if there are any issues.")
    _sellPriceLabel:SetPrelocalizedText("")
end

function showPurchasedHoneyFailed()
    _beeLabel:SetPrelocalizedText("There was an error while purchasing")
    _rarity:SetPrelocalizedText("Please try again later")
    _honeyRateLabel:SetPrelocalizedText("Your gold has not been deducted.")
    _sellPriceLabel:SetPrelocalizedText("")
end