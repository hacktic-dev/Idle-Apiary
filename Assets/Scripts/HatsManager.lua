--!Type(Module)

--!SerializeField
local hatUi : GameObject = nil

queryOwnedHats = Event.new("QueryOwnedHats")
recieveOwnedHats = Event.new("RecieveOwnedHats")
noHatsOwned = Event.new("NoHatsOwned")

function self:ServerAwake()
    queryOwnedHats:Connect(function(player)
        Inventory.GetPlayerItems(player, 25, "", function(items, newCursorId, errorCode)
            if items == nil then
                print(errorCode)
            end

            hatsOwned = false

            for index, item in items do
                if item.id ~= "Red" and item.id ~= "Yellow" and item.id ~= "White" and item.id ~= "Purple" then
                    recieveOwnedHats:FireClient(player, item.id, item.amount)
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
    recieveOwnedHats:Connect(
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