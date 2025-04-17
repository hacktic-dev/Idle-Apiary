--!Type(Module)

Utils = require("Utils")
playerManager = require("PlayerManager")
eggInventoryHandler = require("EggInventoryHandler")

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
NotifyOtherPlayerSelected = Event.new("NotifyOtherPlayerSelected")
NotifyShowConfirmTrade = Event.new("NotifyShowConfirmTrade")

RequestConfirmTrade = Event.new("RequestConfirmTrade")
NotifyWaitingForOtherPlayerConfirmed = Event.new("NotifyWaitingForOtherPlayerConfirmed")
NotifyOtherPlayerConfirmed = Event.new("NotifyOtherPlayerConfirmed")

RequestCancelTrade = Event.new("RequestCancelTrade")

NotifyTradeConfirmed = Event.new("NotifyTradeConfirmed")
NotifyTradeCancelled = Event.new("NotifyTradeCancelled")

TRADE_TIMEOUT = 30

responseRecieved = {}

function self:ServerAwake()
    RequestStartTrade:Connect(function(sendingPlayer, targetPlayer)
        print("RequestStartTrade")
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

        eggInventoryHandler.GetPlayerItems(sendingPlayer, {}, "", function(items)
            NotifyTradeRequestAccepted:FireClient(sendingPlayer, targetPlayer, tradeId, items)
        end)
        eggInventoryHandler.GetPlayerItems(targetPlayer, {}, "", function(items)
            NotifyTradeRequestAccepted:FireClient(targetPlayer, sendingPlayer, tradeId, items)
        end)
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
                    NotifyOtherPlayerSelected:FireClient(trade.target)
                end
            else
                trade.targetPlayerItems = items
                trade.targetReady = true
                if trade.senderReady then
                    NotifyShowConfirmTrade:FireClient(trade.sender, trade.target, tradeId, trade.sendingPlayerItems, trade.targetPlayerItems)
                    NotifyShowConfirmTrade:FireClient(trade.target, trade.sender, tradeId, trade.targetPlayerItems, trade.sendingPlayerItems)
                else
                    NotifyWaitingForOtherPlayerReady:FireClient(trade.target, trade.sender, tradeId)
                    NotifyOtherPlayerSelected:FireClient(trade.sender)
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
                    NotifyOtherPlayerConfirmed:FireClient(trade.target)
                end
            else
                trade.targetConfirmed = true
                if trade.senderConfirmed then
                    Trade(trade, tradeId)
                else
                    NotifyWaitingForOtherPlayerConfirmed:FireClient(trade.target, trade.sender, tradeId)
                    NotifyOtherPlayerConfirmed:FireClient(trade.sender)
                end
            end
        end
    end)

    RequestCancelTrade:Connect(function(player, tradeId)
        print("RequestCancelTrade")
        local trade = activeTrades[tradeId]
        if trade then
            print("Trade cancelled")
            NotifyTradeCancelled:FireClient(trade.sender, player)
            NotifyTradeCancelled:FireClient(trade.target, player)
            activeTrades[tradeId] = nil
        end
    end)

    RequestAvailableTradePartners:Connect(function(player)
        local players = playerManager.GetAllPlayers()
        NotifyAvailableTradePartners:FireClient(player, players)
    end)

end

function StartTrade(sendingPlayer, targetPlayer)
    id = Utils.GenerateUniqueID()
    trade = {sender = sendingPlayer, target = targetPlayer, sendingPlayerItems = {}, targetPlayerItems = {}, senderReady = false, targetReady = false, senderConfirmed = false, targetConfirmed = false}    activeTrades[id] = trade
    return id
end

function Trade(trade, tradeId)
    local transaction = InventoryTransaction.new()

    for id, quantity in pairs(trade.sendingPlayerItems) do
        print("Moving item: " .. id .. " amount: " .. quantity)
        transaction = transaction:MovePlayers(trade.sender, trade.target, id, quantity)
    end

    for id, quantity in pairs(trade.targetPlayerItems) do
        print("Moving item: " .. id .. " amount: " .. quantity)
        transaction = transaction:MovePlayers(trade.target, trade.sender, id, quantity)
    end

    Inventory.CommitTransaction(transaction)

    NotifyTradeConfirmed:FireClient(trade.sender, trade.target, trade.sendingPlayerItems, trade.targetPlayerItems)
    NotifyTradeConfirmed:FireClient(trade.target, trade.sender, trade.targetPlayerItems, trade.sendingPlayerItems)
    activeTrades[tradeId] = nil
end

function PlayerDisconnected(player)
    for id, trade in pairs(activeTrades) do
        if trade.sender == player or trade.target == player then
            NotifyTradeCancelled:FireClient(trade.sender, player)
            NotifyTradeCancelled:FireClient(trade.target, player)
            activeTrades[id] = nil
        end
    end
end