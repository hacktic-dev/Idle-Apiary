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
            "Today's Quest: %s\nProgress: %d/%d",
            dailyQuest.description,
            dailyQuestData[dailyQuest.target] or 0,
            dailyQuest.amount
        )
    else
        dailyQuestText = "No daily quest available today."
    end

    textLabel = UILabel.new()
    textLabel:SetPrelocalizedText(dailyQuestText)
    textLabel:AddToClassList("quest-text")

    horizontalContainer = VisualElement.new()
    horizontalContainer:AddToClassList("horizontal-container")

    rewardLabel = UILabel.new()
    rewardLabel:SetPrelocalizedText("Reward: " .. (dailyQuest and dailyQuest.reward or 0))
    rewardLabel:AddToClassList("quest-text")
    horizontalContainer:Add(rewardLabel)

    ticketIcon = UIImage.new()
    ticketIcon:AddToClassList("ticket-icon")
    horizontalContainer:Add(ticketIcon)

    spacer = VisualElement.new()
    spacer:AddToClassList("spacer")

    _questContainer:Add(textLabel)
    _questContainer:Add(horizontalContainer)
    _questContainer:Add(spacer)
end