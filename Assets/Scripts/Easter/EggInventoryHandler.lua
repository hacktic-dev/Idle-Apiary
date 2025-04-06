--!Type(Module)

nearEgg = nil

--Events
EnteredEggRangeEvent = Event.new("EnteredEggRangeEvent")
ExitedEggRangeEvent = Event.new("ExitedEggRangeEvent")
GiveEggEvent = Event.new("GiveEggEvent")
NotifyEggCollectedEvent = Event.new("NotifyEggCollectedEvent")
DestroyEggPrefabEvent = Event.new("DestroyEggPrefabEvent")

RequestEggFinderActiveEvent = Event.new("RequestEggFinderActiveEvent")
NotifyEggFinderActiveEvent = Event.new("NotifyEggFinderActiveEvent")

RequestCraftEggEvent = Event.new("RequestCraftEggEvent")
NotifyEggCraftedEvent = Event.new("NotifyEggCraftedEvent") 

RequestEggInventoryEvent = Event.new("RequestEggInventoryEvent")
NotifyEggInventoryRecievedEvent = Event.new("NotifyEggInventoryRecievedEvent")

activePlayerEggFinders = {}

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

function EnteredEggRange(egg)
    if nearEgg == nil then
        nearEgg = egg
        print("near egg colour is " .. nearEgg.GetColour())
        EnteredEggRangeEvent:Fire(egg)
    end
end

function ExitedEggRange()
    if nearEgg ~= nil then
        ExitedEggRangeEvent:Fire()
        nearEgg = nil
    end
end

function CollectEgg()
    NotifyEggCollectedEvent:Fire(nearEgg.GetColour())
    GiveEggEvent:FireServer(nearEgg.GetId())
    DestroyEggPrefabEvent:Fire(nearEgg)
end

function self:ServerAwake()
    GiveEggEvent:Connect(function(player, eggId)
        local transaction = InventoryTransaction.new():GivePlayer(player, eggId, 1)
        Inventory.CommitTransaction(transaction)
    end)

    RequestEggFinderActiveEvent:Connect(function(player)
        if activePlayerEggFinders[player] == true then
            NotifyEggFinderActiveEvent:FireClient(player, true)
        else
            NotifyEggFinderActiveEvent:FireClient(player, false)
        end
    end)

    RequestEggInventoryEvent:Connect(function(player)
        GetPlayerItems(player, {}, nil)
    end)

    RequestCraftEggEvent:Connect(function(player, item)
        local transaction = InventoryTransaction.new():GivePlayer(player, item.id, 1)

        for _, eggId in ipairs(item.requirement) do
            transaction = transaction:TakePlayer(player, eggId, 1)
        end

        Inventory.CommitTransaction(transaction)
        NotifyEggCraftedEvent:FireClient(player, item.name)
    end)
end

function GetPlayerItems(player, eggInventory, cursorId)
    Inventory.GetPlayerItems(player, 50, cursorId, function(items, newCursorId, errorCode)
    if errorCode ~= 0 then
        print("Error: couldn't retrieve player items")
        return
    end

    for index, item in items do
        print(item.id .. " " .. item.amount)
        if table.find(eggIds, item.id) then
            print("found egg " .. item.id)
            eggInventory[item.id] = (eggInventory[item.id] or 0) + item.amount
        end
    end

    if(newCursorId ~= nil) then
        GetPlayerItems(player, eggInventory, newCursorId)
    else
        NotifyEggInventoryRecievedEvent:FireClient(player, eggInventory)
    end
    end)
end

function SetEggFinderActiveForPlayer(player)
    activePlayerEggFinders[player] = true
    Timer.new(900, function()
        activePlayerEggFinders[player] = nil
    end)
end

function CraftEgg(item)
    RequestCraftEggEvent:FireServer(item)
end