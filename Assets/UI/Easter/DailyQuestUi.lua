--!Type(UI)

--!Bind
local _mainContainer : VisualElement = nil
--!Bind
local _questContainer : VisualElement = nil
--!Bind
local _closeButton : UIButton = nil
--!Bind
local _closeLabel : UILabel = nil

UIManager = require("UIManager")
dailyQuestTracker = require("DailyQuestTracker")

dailyQuestData = {}

function self:ClientAwake()
    _closeButton:RegisterPressCallback(
        function() UIManager.CloseDailyQuestUi() end, true, true, true)
    _closeLabel:SetPrelocalizedText("Close")
end

function Init(_dailyQuestData)
    _questContainer:Clear()
    dailyQuestData = _dailyQuestData
    dailyQuest = dailyQuestTracker.GetDailyQuest()
    dailyQuestText = ""

    if dailyQuest and dailyQuestData[dailyQuest.target] and dailyQuestData[dailyQuest.target] >= dailyQuest.amount then
        dailyQuestText = "Congratulations! You have completed today's quest."
    elseif dailyQuest then
        dailyQuestText = string.format(
            "Today's Quest: %s\nReward: %s Tickets\nProgress: %d/%d",
            dailyQuest.description,
            dailyQuest.reward,
            dailyQuestData[dailyQuest.key] or 0,
            dailyQuest.amount
        )
    else
        dailyQuestText = "No daily quest available today."
    end

    textLabel = UILabel.new()
    textLabel:SetPrelocalizedText(dailyQuestText)
    textLabel:AddToClassList("quest-text")
    _questContainer:Add(textLabel)
end