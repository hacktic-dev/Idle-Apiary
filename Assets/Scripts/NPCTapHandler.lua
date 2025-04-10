--!Type(Client)

UIManager = require("UIManager")

--!SerializeField
local npcName : string = ""

function self:ClientAwake()
    local TapHand = self.gameObject:GetComponent(TapHandler)
    TapHand.Tapped:Connect(function()
        if npcName == "crafter" then
            UIManager.OpenEggCraftingUi()
        elseif npcName == "questGiver" then
            UIManager.OpenDailyQuestUi()
        elseif npcName == "questRewarder" then
            UIManager.OpenQuestRewardUi()
        elseif npcName == "trader" then
            UIManager.OpenTradingUi()
        end
    end)
end