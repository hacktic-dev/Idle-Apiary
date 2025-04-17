--!Type(UI)

--!Bind
local titleLabel : UILabel = nil
--!Bind
local closeButtonLabel : UILabel = nil
--!Bind
local closeButton : UIButton = nil
--!Bind
local playerSelectionScreen : VisualElement = nil
--!Bind
local playersContainer : VisualElement = nil
--!Bind
local waitingScreen : VisualElement = nil
--!Bind
local waitingLabel : UILabel = nil
--!Bind
local tradeSelectionScreen : VisualElement = nil
--!Bind
local tradeConfirmationScreen : VisualElement = nil

UIManager = require("UIManager")
playerManager = require("PlayerManager")
tradingManager = require("TradingManager")

eggIds =
{
    "egg_red",
    "egg_orange",
    "egg_yellow",
    "egg_green",
    "egg_purple",
    "egg_pink",
    "egg_white",
    "egg_gold"
}

tradeId = nil
items = {} -- Items owned by this player
mySelectedItems = {} -- Items selected by this player
otherSelectedItems = {} -- Items selected by the other player
otherPlayer = nil
otherPlayerLabel = nil

tradingItemsSelected = {}
eggCounters = {}

selectionNextButton = nil

playerTimeout = {}

function Init()

    if waitingForResponse then
       UIManager.HideBattleInitiation()
       UIManager.ShowNotification("Waiting for response", "You have already sent a trade request. Please wait for a response before sending another one.")
       return
    end

    playerSelectionScreen:RemoveFromClassList("hidden")
    waitingScreen:AddToClassList("hidden")
    tradeSelectionScreen:AddToClassList("hidden")
    tradeConfirmationScreen:AddToClassList("hidden")
    playersContainer:Clear()

    players = tradingManager.RequestAvailableTradePartners:FireServer()
end

function ShowWaitingScreen()
    playerSelectionScreen:AddToClassList("hidden")
    waitingScreen:RemoveFromClassList("hidden")
    tradeSelectionScreen:AddToClassList("hidden")
    tradeConfirmationScreen:AddToClassList("hidden")
end

function OnPlayerSelected(player)
    challengedPlayer = player

    if playerTimeout[player] ~= nil then
        if os.time() - playerTimeout[player] < 60 then
            UIManager.NotifyTradeTimeout()
            return
        end
    end

    playerTimeout[player] = os.time()
    tradingManager.RequestStartTrade:FireServer(challengedPlayer)
    ShowWaitingScreen()
end

function self:ClientAwake()
    titleLabel:SetPrelocalizedText("Select a player to trade with:")
    waitingLabel:SetPrelocalizedText("Waiting for response...")
    closeButtonLabel:SetPrelocalizedText("Close")
    --statsNextButtonLabel:SetPrelocalizedText("Next")
    closeButton:RegisterPressCallback(function()
        UIManager.CloseTradingUi()
    end, true, true, true)

    tradingManager.NotifyAvailableTradePartners:Connect(function(players)
    
        print("Players: " .. #players)

        for i, data in ipairs(players) do
            if data.player ~= client.localPlayer then

                local playerButton = UIButton.new()
                local playerLabel = UILabel.new()
                playerLabel:SetPrelocalizedText(data.player.name)
                playerLabel:AddToClassList("title")
                playerButton:Add(playerLabel)
                playerButton:AddToClassList("battle__ui__select__player")
                playerButton:RegisterPressCallback(function()
                    OnPlayerSelected(data.player)
                end, true, true, true)
                playersContainer:Add(playerButton)
            end
        end
    end)

    tradingManager.NotifyTradeRequestAccepted:Connect(function(_otherPlayer, _tradeId, _items)
        otherPlayer = _otherPlayer
        ShowTradeSelectionScreen()
        tradeId = _tradeId
        items = _items
    end)

    tradingManager.NotifyWaitingForOtherPlayerReady:Connect(function()
       ShowWaitingScreen()
    end)

    tradingManager.NotifyWaitingForOtherPlayerConfirmed:Connect(function()
        ShowWaitingScreen()
    end)

    tradingManager.NotifyShowConfirmTrade:Connect(function(otherPlayer, tradeId, _mySelectedItems, _otherSelectedItems)
        tradeId = _tradeId
        mySelectedItems = _mySelectedItems
        otherSelectedItems = _otherSelectedItems
        ShowTradeConfirmationScreen()
    end)

    tradingManager.NotifyOtherPlayerSelected:Connect(function()
        otherPlayerLabel.visible = true
    end)

    tradingManager.NotifyOtherPlayerConfirmed:Connect(function()
        otherPlayerLabel.visible = true
    end)
end

function ShowTradeSelectionScreen()
    playerSelectionScreen:AddToClassList("hidden")
    waitingScreen:AddToClassList("hidden")
    tradeSelectionScreen:RemoveFromClassList("hidden")
    tradeConfirmationScreen:AddToClassList("hidden")

    tradingItemsSelected = {}
    for _, eggId in ipairs(eggIds) do
        tradingItemsSelected[eggId] = 0
    end

    eggCounters = {}

    eggIcons = {
        egg_red = "redEggIcon",
        egg_orange = "orangeEggIcon",
        egg_yellow = "yellowEggIcon",
        egg_green = "greenEggIcon",
        egg_purple = "purpleEggIcon",
        egg_pink = "pinkEggIcon",
        egg_white = "whiteEggIcon",
        egg_gold = "goldEggIcon"
    }

    tradeSelectionScreen:Clear()

    titleLabel = UILabel.new()
    titleLabel:SetPrelocalizedText("Select the eggs you want to trade:")
    titleLabel:AddToClassList("title")
    tradeSelectionScreen:Add(titleLabel)

    eggSelectionContainer = VisualElement.new()
    eggSelectionContainer:AddToClassList("egg__selection_container")

    for _, eggType in ipairs(eggIds) do
        local eggIconName = eggIcons[eggType]

        local eggCounterContainer = VisualElement.new()
        eggCounterContainer:AddToClassList("egg__counter_container")

        -- Firstly the increase button
        local increaseButton = UIButton.new()
        local increaseLabel = UILabel.new()
        increaseLabel:SetPrelocalizedText("+")
        increaseLabel:AddToClassList("title")
        increaseButton:AddToClassList("egg__counter_button")
        increaseButton:Add(increaseLabel)
        increaseButton:RegisterPressCallback(function()
            if tradingItemsSelected[eggType] < (items[eggType] or 0) then
                tradingItemsSelected[eggType] = tradingItemsSelected[eggType] + 1
                SetValue(eggType, tostring(tradingItemsSelected[eggType]))
            end
        end, true, true, true)
        eggCounterContainer:Add(increaseButton)

        -- Now the egg counter itself
        local eggIconContainer = VisualElement.new()
        eggIconContainer:AddToClassList("egg__icon_container")
        local eggIcon = VisualElement.new()
        eggIcon:AddToClassList("egg__icon")
        eggIcon:AddToClassList("egg__icon__margin")
        eggIcon:AddToClassList(eggIconName)
        eggIconContainer:Add(eggIcon)

        local eggIconCounter = UILabel.new()
        eggIconCounter:SetPrelocalizedText("0")
        eggIconCounter:AddToClassList("egg__icon_label")
        eggCounters[eggType] = eggIconCounter
        eggIconContainer:Add(eggIconCounter)

        eggCounterContainer:Add(eggIconContainer)

        -- Finally the decrease button
        local decreaseButton = UIButton.new()
        local decreaseLabel = UILabel.new()
        decreaseLabel:SetPrelocalizedText("-")
        decreaseLabel:AddToClassList("title")
        decreaseButton:AddToClassList("egg__counter_button")
        decreaseButton:Add(decreaseLabel)
        decreaseButton:RegisterPressCallback(function()
            if tradingItemsSelected[eggType] > 0 then
                tradingItemsSelected[eggType] = tradingItemsSelected[eggType] - 1
                SetValue(eggType, tostring(tradingItemsSelected[eggType]))
            end
        end, true, true, true)
        eggCounterContainer:Add(decreaseButton)

        eggSelectionContainer:Add(eggCounterContainer)
    end

    tradeSelectionScreen:Add(eggSelectionContainer)

    otherPlayerLabel = UILabel.new()
    otherPlayerLabel:SetPrelocalizedText(otherPlayer.name .. " has selected their items.")
    otherPlayerLabel:AddToClassList("subtitle")
    otherPlayerLabel.visible = false
    tradeSelectionScreen:Add(otherPlayerLabel)

    -- Add the Next button
    selectionNextButton = UIButton.new()
    local nextLabel = UILabel.new()
    nextLabel:SetPrelocalizedText("Next")
    nextLabel:AddToClassList("title")
    selectionNextButton:AddToClassList("trade__ui_button")
    selectionNextButton.visible = false
    selectionNextButton:Add(nextLabel)
    selectionNextButton:RegisterPressCallback(function()
        tradingManager.RequestSetReadyState:FireServer(tradeId, tradingItemsSelected)
    end, true, true, true)
    tradeSelectionScreen:Add(selectionNextButton)

    -- Add the Cancel button
    local cancelButton = UIButton.new()
    local cancelLabel = UILabel.new()
    cancelLabel:SetPrelocalizedText("Cancel")
    cancelLabel:AddToClassList("title")
    cancelButton:AddToClassList("trade__ui_button")
    cancelButton:Add(cancelLabel)
    cancelButton:RegisterPressCallback(function()
        -- Close the trading UI
        tradingManager.RequestCancelTrade:FireServer(tradeId)
    end, true, true, true)
    tradeSelectionScreen:Add(cancelButton)
end

function SetValue(eggType, value)
    if eggCounters[eggType] then
        eggCounters[eggType]:SetPrelocalizedText(value)
    end

    local allZero = true
    for _, count in pairs(tradingItemsSelected) do
        if count > 0 then
            allZero = false
            break
        end
    end

    selectionNextButton.visible = not allZero
end

function ShowTradeConfirmationScreen()
    playerSelectionScreen:AddToClassList("hidden")
    waitingScreen:AddToClassList("hidden")
    tradeSelectionScreen:AddToClassList("hidden")
    tradeConfirmationScreen:RemoveFromClassList("hidden")

    tradeConfirmationScreen:Clear()

    local titleLabel = UILabel.new()
    titleLabel:SetPrelocalizedText("Trade Confirmation")
    titleLabel:AddToClassList("title")
    tradeConfirmationScreen:Add(titleLabel)

    local eggIcons = {
        egg_red = "redEggIcon",
        egg_orange = "orangeEggIcon",
        egg_yellow = "yellowEggIcon",
        egg_green = "greenEggIcon",
        egg_purple = "purpleEggIcon",
        egg_pink = "pinkEggIcon",
        egg_white = "whiteEggIcon",
        egg_gold = "goldEggIcon"
    }

    local function AddEggRow(container, items, labelText)
        local rowLabel = UILabel.new()
        rowLabel:SetPrelocalizedText(labelText)
        rowLabel:AddToClassList("subtitle")
        container:Add(rowLabel)

        local eggSelectionContainer = VisualElement.new()
        eggSelectionContainer:AddToClassList("egg__confirmation_container")

        for eggType, count in pairs(items) do
            if count > 0 then
                local eggCounterContainer = VisualElement.new()
                eggCounterContainer:AddToClassList("egg__icon__confirmation_container")

                local eggIcon = VisualElement.new()
                eggIcon:AddToClassList("egg__icon")
                eggIcon:AddToClassList("egg__icon__confirm")
                eggIcon:AddToClassList(eggIcons[eggType])
                eggCounterContainer:Add(eggIcon)

                local eggCountLabel = UILabel.new()
                eggCountLabel:SetPrelocalizedText(tostring(count))
                eggCountLabel:AddToClassList("egg__icon_label")
                eggCounterContainer:Add(eggCountLabel)

                eggSelectionContainer:Add(eggCounterContainer)
            end
        end

        container:Add(eggSelectionContainer)
    end

    -- Add my selected items row
    AddEggRow(tradeConfirmationScreen, mySelectedItems, "Your Selected Items:")

    -- Add other player's selected items row
    AddEggRow(tradeConfirmationScreen, otherSelectedItems, "Other Player's Selected Items:")

    otherPlayerLabel = UILabel.new()
    otherPlayerLabel:SetPrelocalizedText(otherPlayer.name .. " has confirmed the trade.")
    otherPlayerLabel:AddToClassList("title")
    otherPlayerLabel.visible = false
    tradeConfirmationScreen:Add(otherPlayerLabel)

    -- Add Confirm button
    local confirmButton = UIButton.new()
    local confirmLabel = UILabel.new()
    confirmLabel:SetPrelocalizedText("Confirm Trade")
    confirmLabel:AddToClassList("title")
    confirmButton:AddToClassList("trade__ui_button")
    confirmButton:Add(confirmLabel)
    confirmButton:RegisterPressCallback(function()
        tradingManager.RequestConfirmTrade:FireServer(tradeId)
    end, true, true, true)
    tradeConfirmationScreen:Add(confirmButton)

    -- Add Cancel button
    local cancelButton = UIButton.new()
    local cancelLabel = UILabel.new()
    cancelLabel:SetPrelocalizedText("Cancel")
    cancelLabel:AddToClassList("title")
    cancelButton:AddToClassList("trade__ui_button")
    cancelButton:Add(cancelLabel)
    cancelButton:RegisterPressCallback(function()
        tradingManager.RequestCancelTrade:FireServer(tradeId)
    end, true, true, true)
    tradeConfirmationScreen:Add(cancelButton)
end
