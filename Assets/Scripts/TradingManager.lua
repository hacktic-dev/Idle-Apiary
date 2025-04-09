--!Type(Module)

Utils = require("Utils")

activeTrades = {}

RequestAvailableTradePartners = Event.new("RequestAvailableTradePartners")
NotifyAvailableTradePartners = Event.new("NotifyAvailableTradePartners")

RequestStartTrade = Event.new("RequestStartTrade")
NotifyStartTradeRequested = Event.new("NotifyStartTradeRequested")

RequestDeclineTradeRequest = Event.new("RequestDeclineTradeRequest")
RequestAcceptTradeRequest = Event.new("RequestAcceptTradeRequest")
NotifyTradeRequestDeclined = Event.new("NotifyTradeRequestDeclined")
NotifyTradeRequestAccepted = Event.new("NotifyTradeRequestAccepted")

RequestSetReadyState = Event.new("RequestSetReadyState")
NotifyWaitingForOtherPlayerReady = Event.new("NotifyWaitingForOtherPlayerReady")
NotifyShowConfirmTrade = Event.new("NotifyShowConfirmTrade")

RequestConfirmTrade = Event.new("RequestConfirmTrade")
NotifyWaitingForOtherPlayerConfirmed = Event.new("NotifyWaitingForOtherPlayerConfirmed")

RequestCancelTrade = Event.new("RequestCancelTrade")

NotifyTradeConfirmed = Event.new("NotifyTradeConfirmed")
NotifyTradeCancelled = Event.new("NotifyTradeCancelled")

TRADE_TIMEOUT = 30

responseRecieved = {}

function self:ServerAwake()
    RequestStartTrade:Connect(function(sendingPlayer, targetPlayer)
        NotifyStartTradeRequested:FireClient(targetPlayer, sendingPlayer)
        Timer.new(TRADE_TIMEOUT, function()
            if not responseRecieved[targetPlayer] then
                NotifyTradeRequestDeclined:FireClient(sendingPlayer, targetPlayer)
                NotifyTradeRequestDeclined:FireClient(targetPlayer, sendingPlayer)
            end
        end)
        responseRecieved[targetPlayer] = false
    end)

    RequestAcceptTradeRequest:Connect(function(targetPlayer, sendingPlayer)
        tradeId = StartTrade(sendingPlayer, targetPlayer)
        responseRecieved[targetPlayer] = true
        NotifyTradeRequestAccepted:FireClient(sendingPlayer, targetPlayer, tradeId)
        NotifyTradeRequestAccepted:FireClient(targetPlayer, sendingPlayer, tradeId)
    end)

    RequestDeclineTradeRequest:Connect(function(targetPlayer, sendingPlayer)
        responseRecieved[targetPlayer] = true
        NotifyTradeRequestDeclined:FireClient(sendingPlayer, targetPlayer)
    end)

    RequestSetReadyState:Connect(function(player, tradeId, items)
        local trade = activeTrades[tradeId]
        if trade then
            if player == trade.sender then
                trade.sendingPlayerItems = items
                trade.senderReady = true
                if trade.targetReady then
                    NotifyShowConfirmTrade:FireClient(trade.sender, trade.target, tradeId, trade.sendingPlayerItems, trade.targetPlayerItems)
                    NotifyShowConfirmTrade:FireClient(trade.target, trade.sender, tradeId, trade.targetPlayerItems, trade.sendingPlayerItems)
                else
                    NotifyWaitingForOtherPlayerReady:FireClient(trade.sender, trade.target, tradeId)
                end
            else
                trade.targetPlayerItems = items
                trade.targetReady = true
                if trade.senderReady then
                    NotifyShowConfirmTrade:FireClient(trade.sender, trade.target, tradeId, trade.sendingPlayerItems, trade.targetPlayerItems)
                    NotifyShowConfirmTrade:FireClient(trade.target, trade.sender, tradeId, trade.targetPlayerItems, trade.sendingPlayerItems)
                else
                    NotifyWaitingForOtherPlayerReady:FireClient(trade.target, trade.sender, tradeId)
                end
            end
        end
    end)

    RequestConfirmTrade:Connect(function(player, tradeId)
        local trade = activeTrades[tradeId]
        if trade then
            if player == trade.sender then
                trade.senderConfirmed = true
                if trade.targetConfirmed then
                    Trade(trade, tradeId)
                else
                    NotifyWaitingForOtherPlayerConfirmed:FireClient(trade.sender, trade.target, tradeId)
                end
            else
                trade.targetConfirmed = true
                if trade.senderConfirmed then
                    Trade(trade, tradeId)
                else
                    NotifyWaitingForOtherPlayerConfirmed:FireClient(trade.target, trade.sender, tradeId)
                end
            end
        end
    end)

    RequestCancelTrade:Connect(function(player, tradeId)
        local trade = activeTrades[tradeId]
        if trade then
            NotifyTradeCancelled:FireClient(trade.sender, player)
            NotifyTradeCancelled:FireClient(trade.target, player)
            activeTrades[tradeId] = nil
        end
    end)
end

function StartTrade(sendingPlayer, targetPlayer)
    id = Utils.GenerateUniqueID()
    trade = {sender = sendingPlayer, target = targetPlayer, sendingPlayerItems = {}, targetPlayerItems = {}, senderReady = false, targetReady = false, senderConfirmed = false, targetConfirmed = false}    activeTrades[id] = trade
    return id
end

function Trade(trade, tradeId)
    local transaction = InventoryTransaction.new()

    for _, item in ipairs(trade.sendingPlayerItems) do
        transaction:MovePlayers(trade.sender, trade.target, item.id, item.amount)
    end

    for _, item in ipairs(trade.targetPlayerItems) do
        transaction:MovePlayers(trade.target, trade.sender, item.id, item.amount)
    end

    Inventory.CommitTransaction(transaction)

    NotifyTradeConfirmed:FireClient(trade.sender, trade.target, trade.sendingPlayerItems, trade.targetPlayerItems)
    NotifyTradeConfirmed:FireClient(trade.target, trade.sender, trade.targetPlayerItems, trade.sendingPlayerItems)
    activeTrades[tradeId] = nil
end