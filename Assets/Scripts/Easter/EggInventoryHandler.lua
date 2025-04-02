--!Type(Module)

nearEgg = nil

--Events
EnteredEggRangeEvent = Event.new("EnteredEggRangeEvent")
ExitedEggRangeEvent = Event.new("ExitedEggRangeEvent")
GiveEggEvent = Event.new("GiveEggEvent")
NotifyEggCollectedEvent = Event.new("NotifyEggCollectedEvent")
DestroyEggPrefabEvent = Event.new("DestroyEggPrefabEvent")

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
end