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
--!Bind
local close : UIButton = nil

local wildBeeManager = require("WildBeeManager")

local playerManager = require("PlayerManager")

closeCallback = nil

timer = nil

close:RegisterPressCallback(function()
    closeCallback()
    StopTimer()
end, true, true, true)

-- Initialize UI text and image

function ShowCaughtWild(species)
    _beeLabel:SetPrelocalizedText("You caught a wild " .. species .. "!")
    _rarity:SetPrelocalizedText(wildBeeManager.getRarity(species) .. " Bee")
    _honeyRateLabel:SetPrelocalizedText("Honey rate: " .. wildBeeManager.getHoneyRate(species))
    _sellPriceLabel:SetPrelocalizedText("Sell price: " .. wildBeeManager.getSellPrice(species))
    SetTimer()
end

function ShowEggCollected(eggColour)
    _beeLabel:SetPrelocalizedText("You collected a " .. eggColour .. " egg!")
    _rarity:SetPrelocalizedText("")
    _honeyRateLabel:SetPrelocalizedText("")
    _sellPriceLabel:SetPrelocalizedText("")
    SetTimer()
end

function ShowReceived(species)
    _beeLabel:SetPrelocalizedText("You received a " .. species .. "!")
    _rarity:SetPrelocalizedText(wildBeeManager.getRarity(species) .. " Bee")
    _honeyRateLabel:SetPrelocalizedText("Honey rate: " .. wildBeeManager.getHoneyRate(species))
    _sellPriceLabel:SetPrelocalizedText("Sell price: " .. wildBeeManager.getSellPrice(species))
    SetTimer()
end

function ShowPurchasedItem(hat)
    _beeLabel:SetPrelocalizedText("You purchased a " .. hat .. "!")
    _rarity:SetPrelocalizedText("")
    _honeyRateLabel:SetPrelocalizedText("")
    _sellPriceLabel:SetPrelocalizedText("")
    SetTimer()
end

function ShowFlowerCut(name, effect)
    _beeLabel:SetPrelocalizedText("You picked a " .. name .. " flower!")
    _rarity:SetPrelocalizedText(effect)
    _honeyRateLabel:SetPrelocalizedText("")
    _sellPriceLabel:SetPrelocalizedText("")
    SetTimer()
end

function ShowEggCrafted(name)
    _beeLabel:SetPrelocalizedText("You crafted a " .. name .. "!")
    _rarity:SetPrelocalizedText("")
    _honeyRateLabel:SetPrelocalizedText("")
    _sellPriceLabel:SetPrelocalizedText("")
    SetTimer()
end

function ShowRewardExchanged(name, cost)
    _beeLabel:SetPrelocalizedText("You exchanged " .. cost .. " tickets for a " .. name .. "!")
    _rarity:SetPrelocalizedText("")
    _honeyRateLabel:SetPrelocalizedText("")
    _sellPriceLabel:SetPrelocalizedText("")
    SetTimer()
end

function showPurchasedHoney(id)
    if id == "doubler_1" then
        _beeLabel:SetPrelocalizedText("You purchased a Honey Doubler!")
    elseif id == "doubler_2" then
        _beeLabel:SetPrelocalizedText("You purchased a Honey Doubler Pro!")
    elseif id == "egg_finder" then
        _beeLabel:SetPrelocalizedText("You purchased an Egg Finder!")
    end

    _rarity:SetPrelocalizedText("Thank you for your purchase!")
    _honeyRateLabel:SetPrelocalizedText("")
    _sellPriceLabel:SetPrelocalizedText("")
    SetTimer()
end

function showPurchasedHoneyFailed()
    _beeLabel:SetPrelocalizedText("There was an error while purchasing")
    _rarity:SetPrelocalizedText("Please try again later")
    _honeyRateLabel:SetPrelocalizedText("Your gold has not been deducted.")
    _sellPriceLabel:SetPrelocalizedText("")
    SetTimer()
end

function SetCloseCallback(callback)
    closeCallback = callback
end

function SetTimer()
    StopTimer()
    timer = Timer.new(5, function() closeCallback() end, false)
end

function StopTimer()
    if timer ~= nil then
        timer:Stop()
    end
end