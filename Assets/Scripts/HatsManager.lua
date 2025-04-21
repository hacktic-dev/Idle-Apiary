--!Type(Module)

--!SerializeField
local hatUi : GameObject = nil

queryOwnedHats = Event.new("QueryOwnedHats")
receiveOwnedHats = Event.new("ReceiveOwnedHats")
noHatsOwned = Event.new("NoHatsOwned")

local utils = require("Utils")

local selectedBeeId = nil

function SetSelectedBee(id)
    selectedBeeId = id
end

function GetSelectedBee()
    return selectedBeeId
end

function LoadHats(hats, cursorId, player)
    Inventory.GetPlayerItems(player, 25, cursorId, function(items, newCursorId, errorCode)
        print("Loading hats...")
        
        if items == nil then
            print(errorCode)
            return
        end

        for _, item in ipairs(items) do
            if utils.IsHat(item.id) then
                table.insert(hats, { id = item.id, amount = item.amount })
            end
        end

        if newCursorId ~= nil then
            LoadHats(hats, newCursorId, player) -- Recursively load more items
        else
            print("Finished loading hats. Total hats: " .. #hats)
            if #hats > 0 then
                receiveOwnedHats:FireClient(player, hats) -- Send all hats at once
            else
                print("No owned hats")
                noHatsOwned:FireClient(player)
            end
        end
    end)
end

function self:ServerAwake()
    queryOwnedHats:Connect(function(player)
        LoadHats({}, "", player) -- Start loading with an empty cursor
    end)
end

function self:ClientAwake()
    receiveOwnedHats:Connect(
        function(hats)
            for _, hat in ipairs(hats) do
                hatUi:GetComponent(AddHatUi).AddHatCard(hat.id, hat.amount)
            end
        end
    )

    noHatsOwned:Connect(
        function()
            hatUi:GetComponent(AddHatUi).NoHats()
        end
    )
end