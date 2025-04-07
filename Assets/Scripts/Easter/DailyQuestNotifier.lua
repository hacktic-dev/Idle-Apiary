--!Type(Client)

--!SerializeField

dailyQuestTracker = require("DailyQuestTracker")

function self:ClientAwake()
    Timer.new(2, function()
        dailyQuestTracker.RequestNotifierVisibility()
    end, true)

    dailyQuestTracker.NotifyNotifierVisibilityEvent:Connect(function(isVisible)
        if isVisible then
            self:GetComponent(BobbingIcon).SetText("!")
        else
            self:GetComponent(BobbingIcon).SetText("")
        end
    end)
end