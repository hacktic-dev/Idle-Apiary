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

function self:ServerAwake()
    queryOwnedHats:Connect(function(player)
        Inventory.GetPlayerItems(player, 25, "", function(items, newCursorId, errorCode)
            if items == nil then
                print(errorCode)
            end

            hatsOwned = false

            for index, item in items do
                if utils.IsHat(item.id) then
                    receiveOwnedHats:FireClient(player, item.id, item.amount)
                    hatsOwned = true
                end
            end

            if hatsOwned == false then 
                print("No owned hats")
                noHatsOwned:FireClient(player)
            end
        end)
    end)
end

function self:ClientAwake()
    receiveOwnedHats:Connect(
        function(name, amount)
            hatUi:GetComponent(AddHatUi).AddHatCard(name, amount)
        end
    )

    noHatsOwned:Connect(
        function()
            hatUi:GetComponent(AddHatUi).NoHats()
        end
    )
end