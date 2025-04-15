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

UIManager = require("UIManager")
playerManager = require("PlayerManager")
tradingManager = require("TradingManager")

tradeId = nil

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
    playersContainer:Clear()

    players = tradingManager.RequestAvailableTradePartners:FireServer()
end

function ShowWaitingScreen()
    playerSelectionScreen:AddToClassList("hidden")
    waitingScreen:RemoveFromClassList("hidden")
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

    tradingManager.NotifyTradeRequestAccepted:Connect(function(targetPlayer, _tradeId)
        InitTradeSelectionScreen()
        tradeId = _tradeId
    end)
end

function InitTradeSelectionScreen()
    playerSelectionScreen:AddToClassList("hidden")
    waitingScreen:AddToClassList("hidden")
    tradeSelectionScreen:RemoveFromClassList("hidden")

    eggIcons = {"redEggIcon", "orangeEggIcon", "yellowEggIcon", "greenEggIcon", "purpleEggIcon", "pinkEggIcon", "whiteEggIcon", "goldEggIcon"}

    tradeSelectionScreen:Clear()

    titleLabel = UILabel.new()
    titleLabel:SetPrelocalizedText("Select the eggs you want to trade:")
    titleLabel:AddToClassList("title")
    tradeSelectionScreen:Add(titleLabel)

    eggSelectionContainer = VisualElement.new()
    eggSelectionContainer:AddToClassList("egg__selection_container")

    for i, eggIconName in ipairs(eggIcons) do

        local eggCounterContainer = VisualElement.new()
        eggCounterContainer:AddToClassList("egg__counter_container")

        --Firstly the increase button
        local increaseButton = UIButton.new()
        local increaseLabel = UILabel.new()
        increaseLabel:SetPrelocalizedText("+")
        increaseLabel:AddToClassList("title")
        increaseButton:AddToClassList("egg__counter_button")
        increaseButton:Add(increaseLabel)
        increaseButton:RegisterPressCallback(function()
            --TODO
        end, true, true, true)
        eggCounterContainer:Add(increaseButton)

        -- Now the egg counter itself
        local eggIconContainer = VisualElement.new()
        eggIconContainer:AddToClassList("egg__icon_container")
        local eggIcon = VisualElement.new()
        eggIcon:AddToClassList("eggIcon")
        eggIcon:AddToClassList(eggIconName)
        eggIconContainer:Add(eggIcon)

        local eggIconCounter = UILabel.new()
        eggIconCounter:SetPrelocalizedText("0")
        eggIconCounter:AddToClassList("egg__icon_label")
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
            --TODO
        end, true, true, true)
        eggCounterContainer:Add(decreaseButton)

        eggSelectionContainer:Add(eggCounterContainer)
    end

    tradeSelectionScreen:Add(eggSelectionContainer)

    -- Add the Next button
    local nextButton = UIButton.new()
    local nextLabel = UILabel.new()
    nextLabel:SetPrelocalizedText("Next")
    nextLabel:AddToClassList("title")
    nextButton:AddToClassList("trade__ui__next_button")
    nextButton:Add(nextLabel)
    nextButton:RegisterPressCallback(function()
        -- TODO: Implement functionality for proceeding to the next step
        print("Next button pressed")
    end, true, true, true)
    tradeSelectionScreen:Add(nextButton)

    -- Add the Cancel button
    local cancelButton = UIButton.new()
    local cancelLabel = UILabel.new()
    cancelLabel:SetPrelocalizedText("Cancel")
    cancelLabel:AddToClassList("title")
    cancelButton:AddToClassList("trade__ui__cancel_button")
    cancelButton:Add(cancelLabel)
    cancelButton:RegisterPressCallback(function()
        -- Close the trading UI
        tradingManager.RequestCancelTrade:FireServer(tradeId)
    end, true, true, true)
    tradeSelectionScreen:Add(cancelButton)
end