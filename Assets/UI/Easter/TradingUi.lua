--!Type(UI)

--!Bind
local titleLabel : UILabel = nil
--!Bind
local closeButtonLabel : UILabel = nil
--!Bind
local closeButton : UIButton = nil
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
    wager = 0
    wagerAmountLabel:SetPrelocalizedText(tostring(wager))
    infoLabel:SetPrelocalizedText("")

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
            UIManager.HideTradingScreen()
            UIManager.ShowNotification("Challenge timeout", "You have already sent a challenge to this player recently. Please wait a while before sending another one.")
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
    statsNextButtonLabel:SetPrelocalizedText("Next")
    closeButton:RegisterPressCallback(function()
        UIManager.HideBattleInitiation()
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

    tradingManager.NotifyTradeRequestAccepted:Connect(function(targetPlayer, tradeId)
        playerSelectionScreen:AddToClassList("hidden")
        waitingScreen:AddToClassList("hidden")
        tradeSelectionScreen:RemoveFromClassList("hidden")
        tradeId = tradeId
    end)

    tradingManager.NotifyTradeRequestDeclined:Connect(function(targetPlayer)
        UIManager.HideTradingScreen()
        UIManager.ShowTradingRequestDeclined(targetPlayer.name)
    end)
end