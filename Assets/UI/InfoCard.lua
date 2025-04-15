--!Type(UI)

--!Bind
local _infoCard : VisualElement = nil
--!Bind
local close : UIButton = nil

local wildBeeManager = require("WildBeeManager")
local playerManager = require("PlayerManager")

closeCallback = nil
timer = nil

isTradeRequest = false
sendingPlayer = nil

RequestAcceptTradeEvent = Event.new("RequestAcceptTradeEvent")
RequestDeclineTradeEvent = Event.new("RequestDeclineTradeEvent")

close:RegisterPressCallback(function()
    if isTradeRequest then
        OnDecline()
        isTradeRequest = false
        return
    end
    if closeCallback ~= nil then
        closeCallback()
    end
    StopTimer()
end, true, true, true)

-- Helper function to clear _infoCard
local function ClearInfoCard()
    _infoCard:Clear()
end

-- Helper function to create and add a UILabel
local function AddLabel(parent, class, text)
    local label = UILabel.new()
    label:AddToClassList(class)
    label:SetPrelocalizedText(text)
    parent:Add(label)
    return label
end

-- Helper function to create and add a UIImage
local function AddImage(parent, class, src)
    local image = UIImage.new()
    image:AddToClassList(class)
    image:SetSource(src) -- TODO
    parent:Add(image)
    return image
end

-- Function to populate the UI dynamically
local function PopulateInfoCard(mainText, rarityText, honeyRateText, sellPriceText, imageSrc)
    ClearInfoCard()
    AddLabel(_infoCard, "info-main-label", mainText)
    if imageSrc then
        AddImage(_infoCard, "info-image", imageSrc)
    end
    if rarityText then
        AddLabel(_infoCard, "info-label", rarityText)
    end
    if honeyRateText then
        AddLabel(_infoCard, "info-label", honeyRateText)
    end
    if sellPriceText then
        AddLabel(_infoCard, "info-label", sellPriceText)
    end
end

-- Functions to show different UI states
function ShowCaughtWild(species)
    PopulateInfoCard(
        "You caught a wild " .. species .. "!",
        wildBeeManager.getRarity(species) .. " Bee",
        "Honey rate: " .. wildBeeManager.getHoneyRate(species),
        "Sell price: " .. wildBeeManager.getSellPrice(species),
        nil -- todo add actual image
    )
    SetTimer()
end

function ShowEggCollected(eggColour)
    PopulateInfoCard(
        "You collected a " .. eggColour .. " egg!",
        nil,
        nil,
        nil,
        nil
    )
    SetTimer()
end

function ShowReceived(species)
    PopulateInfoCard(
        "You received a " .. species .. "!",
        wildBeeManager.getRarity(species) .. " Bee",
        "Honey rate: " .. wildBeeManager.getHoneyRate(species),
        "Sell price: " .. wildBeeManager.getSellPrice(species),
        nil 
    )
    SetTimer()
end

function ShowPurchasedItem(hat)
    PopulateInfoCard(
        "You purchased a " .. hat .. "!",
        nil,
        nil,
        nil,
        nil
    )
    SetTimer()
end

function ShowFlowerCut(name, effect)
    PopulateInfoCard(
        "You picked a " .. name .. " flower!",
        effect,
        nil,
        nil,
        nil
    )
    SetTimer()
end

function ShowEggCrafted(name)
    PopulateInfoCard(
        "You crafted a " .. name .. "!",
        nil,
        nil,
        nil,
        nil
    )
    SetTimer()
end

function ShowRewardExchanged(name, cost)
    PopulateInfoCard(
        "You exchanged " .. cost .. " tickets for a " .. name .. "!",
        nil,
        nil,
        nil,
        nil
    )
    SetTimer()
end

function showPurchasedHoney(id)
    local mainText
    if id == "doubler_1" then
        mainText = "You purchased a Honey Doubler!"
    elseif id == "doubler_2" then
        mainText = "You purchased a Honey Doubler Pro!"
    elseif id == "egg_finder" then
        mainText = "You purchased an Egg Finder!"
    end

    PopulateInfoCard(
        mainText,
        "Thank you for your purchase!",
        nil,
        nil,
        nil
    )
    SetTimer()
end

function showPurchasedHoneyFailed()
    PopulateInfoCard(
        "There was an error while purchasing",
        "Please try again later",
        "Your gold has not been deducted.",
        nil,
        nil
    )
    SetTimer()
end

function ShowTradeRequest(_sendingPlayer)
    ClearInfoCard()
    
    isTradeRequest = true
    sendingPlayer = _sendingPlayer

    -- Add main text
    AddLabel(_infoCard, "info-main-label", "You have received a trade request from " .. sendingPlayer.name .. "!")
    
    -- Create Accept button
    local acceptButton = UIButton.new()
    acceptButton:AddToClassList("accept-button")
    local acceptLabel = UILabel.new()
    acceptLabel:AddToClassList("info-main-label")
    acceptLabel:SetPrelocalizedText("Accept")
    acceptButton:Add(acceptLabel)
    acceptButton:RegisterPressCallback(function()
        isTradeRequest = false
        OnAccept()
        StopTimer()
    end, true, true, true)
    _infoCard:Add(acceptButton)
    
    -- Create Decline button
    local declineButton = UIButton.new()
    declineButton:AddToClassList("decline-button")
    local declineLabel = UILabel.new()
    declineLabel:AddToClassList("info-main-label")
    declineLabel:SetPrelocalizedText("Decline")
    declineButton:Add(declineLabel)
    declineButton:RegisterPressCallback(function()
        isTradeRequest = false
        OnDecline()
        StopTimer()
    end, true, true, true)
    _infoCard:Add(declineButton)
    _infoCard:Add(declineButton)
end

function ShowTradeRequestDeclined(targetPlayer)
    PopulateInfoCard(
        "Trade request declined",
        targetPlayer.name .. " has declined your trade request.",
        nil,
        nil,
        nil
    )
end

function ShowTradeTimeout()
    PopulateInfoCard(
        "Too many requests!",
        "You have sent a trade request to this player recently. Please wait a while before sending another one.",
        nil,
        nil,
        nil
    )
end

function ShowTradeCancelled(targetPlayer)
    local playerName = targetPlayer == client.localPlayer and "You" or targetPlayer.name
    PopulateInfoCard(
        "Trade cancelled",
        playerName .. (targetPlayer == client.localPlayer and " have" or " has") .. " cancelled the trade.",
        nil,
        nil,
        nil
    )
end

function ShowTradeConfirmed(otherPlayer)
    PopulateInfoCard(
        "Trade completed",
        "You have successfully traded with " .. otherPlayer.name .. "!",
        nil,
        nil,
        nil
    )
end

function OnAccept()
    RequestAcceptTradeEvent:Fire(sendingPlayer)
end

function OnDecline()
    RequestDeclineTradeEvent:Fire(sendingPlayer)
end

-- Timer and close callback functions
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