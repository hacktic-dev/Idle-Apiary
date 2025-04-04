--!Type(Client)

UIManager = require("UIManager")

--!SerializeField
local npcName : string = ""

function self:ClientAwake()
    local TapHand = self.gameObject:GetComponent(TapHandler)
    TapHand.Tapped:Connect(function()
        if npcName == "crafter" then
            UIManager.ShowEggCraftingUi()
        end
    end)
end