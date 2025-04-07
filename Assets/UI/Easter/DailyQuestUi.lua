--!Type(UI)

--!Bind
local _mainContainer : VisualElement = nil

UIManager = require("UIManager")
dailyQuestTracker = require("DailyQuestTracker")

dailyQuestData = {}

function self:ClientAwake()
end

function Init(_dailyQuestData)
    _mainContainer:Clear()

    questContainer = VisualElement.new()
    questContainer:AddToClassList("quest-container")
    _mainContainer:Add(questContainer)

    dailyQuestData = _dailyQuestData
    dailyQuest = dailyQuestTracker.GetDailyQuest()
    dailyQuestText = ""

    questClaimed = dailyQuestData["lastCompletedQuestDate"] == dailyQuestTracker.GetSeed()
    questCompleted = dailyQuest and dailyQuestData[dailyQuest.target] and dailyQuestData[dailyQuest.target] >= dailyQuest.amount

    if questCompleted and (not questClaimed) then
        dailyQuestText = "Congratulations! You have completed today's quest."
    elseif not questClaimed then
        dailyQuestText = string.format(
            "Today's Quest: %s\nProgress: %d/%d",
            dailyQuest.description,
            dailyQuestData[dailyQuest.target] or 0,
            dailyQuest.amount
        )
    else
        dailyQuestText = "You have already completed today's quest."
    end

    textLabel = UILabel.new()
    textLabel:SetPrelocalizedText(dailyQuestText)
    textLabel:AddToClassList("quest-text")
    questContainer:Add(textLabel)

    if not questClaimed then
        horizontalContainer = VisualElement.new()
        horizontalContainer:AddToClassList("horizontal-container")

        rewardLabel = UILabel.new()
        rewardLabel:SetPrelocalizedText("Reward: " .. (dailyQuest and dailyQuest.reward or 0))
        rewardLabel:AddToClassList("quest-text")
        horizontalContainer:Add(rewardLabel)

        ticketIcon = UIImage.new()
        ticketIcon:AddToClassList("ticket-icon")
        horizontalContainer:Add(ticketIcon)
        questContainer:Add(horizontalContainer)
    end

    if (not questCompleted) or questClaimed then
        closeButton = UIButton.new()
        closeLabel = UILabel.new()
        closeLabel:SetPrelocalizedText("Close")
        closeLabel:AddToClassList("title")
        closeButton:Add(closeLabel)
        closeButton:AddToClassList("close-button")
        closeButton:RegisterPressCallback(function()
            UIManager.CloseDailyQuestUi()
        end, true, true, true)
        _mainContainer:Add(closeButton)
    else
        claimButton = UIButton.new()
        claimLabel = UILabel.new()
        claimLabel:SetPrelocalizedText("Claim")
        claimLabel:AddToClassList("title")
        claimButton:Add(claimLabel)
        claimButton:AddToClassList("claim-button")
        claimButton:RegisterPressCallback(function()
            dailyQuestTracker.ClaimDailyQuestReward()
            UIManager.CloseDailyQuestUi()
        end, true, true, true)
        _mainContainer:Add(claimButton)
    end
end