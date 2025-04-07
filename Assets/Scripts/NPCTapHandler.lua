--!Type(Client)

UIManager = require("UIManager")

--!SerializeField
local npcName : string = ""

function self:ClientAwake()
    local TapHand = self.gameObject:GetComponent(TapHandler)
    TapHand.Tapped:Connect(function()
        if npcName == "crafter" then
            UIManager.ShowEggCraftingUi()
        elseif npcName == "questGiver" then
            UIManager.ShowDailyQuestUi()
        elseif npcName == "questRewarder" then
            UIManager.ShowQuestRewardUi()
        end
    end)
end