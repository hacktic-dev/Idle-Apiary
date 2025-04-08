--!Type(UI)


--!Bind
local Orders_Root : UIScrollView = nil
--!Bind
local navigationArea : VisualElement = nil
--!Bind
local closeButton : UIButton = nil
--!Bind
local closeLabel : UILabel = nil
--!Bind
local _shopInfoArea : VisualElement = nil
--!Bind
local _ShopContent : VisualElement = nil
--!Bind
local shopHeader : VisualElement = nil


UIManager = require("UIManager")
dailyQuestTracker = require("DailyQuestTracker")
eggInventoryHandler = require("EggInventoryHandler")

local rewards = {
    {id ="chicken_hat", name ="Chicken Hat", ticketCost = 5 , type = "hat"},
    {id ="bunny_ears", name ="Bunny Ears", ticketCost = 10, type = "hat"},
    {id ="chocolate_egg", name ="Chocolate Egg", ticketCost = 10, type = "furniture"},
    {id="easter_basket", name="Easter Basket", ticketCost = 10, type = "furniture"},
    {id="rabbit_plush", name="Rabbit Plush", ticketCost = 15, type = "furniture"},
    {id="chicken_plush", name="Chicken Plush", ticketCost = 15, type = "furniture"},
    {id="moai_head", name="Moai Head", ticketCost = 20, type = "furniture"},
}

local ticketCount = 0

local function CreateItems(items)
    Orders_Root:Clear()
    _shopInfoArea:Clear()
    for _, item in ipairs(items) do
        CreateItem(item)
    end
end

local tabs = {
    { name = "Rewards", callback = function() CreateItems(rewards) end },
}

local function CreateTabs()
    navigationArea:Clear()

    for i, tabInfo in ipairs(tabs) do
        local tabButton = VisualElement.new()
        tabButton:AddToClassList("nav-button--deselected")

        local tabLabel = UILabel.new()
        tabLabel:SetPrelocalizedText(tabInfo.name)
        tabButton:Add(tabLabel)

        tabButton:RegisterPressCallback(function()
            ButtonPressed(tabInfo.name:lower())
        end, true, true, true)

        -- Add the tab button to the UI (assuming you have a container for the tabs)
        navigationArea:Add(tabButton)

        -- Store the tab button in the tabs table for later reference
        tabs[i].button = tabButton
    end
end

function ButtonPressed(btn)
    for i, tabInfo in ipairs(tabs) do
        if tabInfo.name:lower() == btn then
            if state == i then return end
            state = i
            tabInfo.button:AddToClassList("nav-button--selected")
            tabInfo.button:RemoveFromClassList("nav-button--deselected")
            print("Button pressed: " .. tabInfo.name)
            tabInfo.callback()
        else
            tabInfo.button:AddToClassList("nav-button--deselected")
            tabInfo.button:RemoveFromClassList("nav-button--selected")
        end
    end
end

-- Creates a new quest item in the UI.
local questItems = {}

function CreateItem(item)
    -- Store the quest item details in a table.
    questItems[item.id] = item

    -- Create a new button for the quest item.
    local questItem = UIButton.new()
    questItem:AddToClassList("order-item") -- Add a class to style the quest item.

    -- Create a label for the quest item's title and add it to the quest item.
    local _titleLabel = UILabel.new()
    _titleLabel:AddToClassList("title")
    _titleLabel:SetPrelocalizedText(item.name) -- Set the text to display the quest item's name.
    questItem:Add(_titleLabel)

    questItem:RegisterPressCallback(function()
        OnItemClicked(item.id)
    end, true, true, true)

    -- Add the quest item to the UI.
    Orders_Root:Add(questItem)

    return questItem
end

function OnItemClicked(Id)
    _shopInfoArea:Clear()
    local item = questItems[Id]
    if item then
        local nameLabel = UILabel.new()
        nameLabel:SetPrelocalizedText(item.name)
        nameLabel:AddToClassList("title")
        _shopInfoArea:Add(nameLabel)

        local horizontalContainer = VisualElement.new()
        horizontalContainer:AddToClassList("horizontal-container")
        _shopInfoArea:Add(horizontalContainer)

        local ticketCostLabel = UILabel.new()
        ticketCostLabel:SetPrelocalizedText(item.ticketCost)
        ticketCostLabel:AddToClassList("description")
        horizontalContainer:Add(ticketCostLabel)

        local ticketIcon = UIImage.new()
        ticketIcon:AddToClassList("ticket-icon")
        horizontalContainer:Add(ticketIcon)

        _shopInfoArea:Add(horizontalContainer)

        local exchangeButton = UIButton.new()
        local exchangeButtonLabel = UILabel.new()
        exchangeButtonLabel:AddToClassList("title")
        exchangeButtonLabel:SetPrelocalizedText("Exchange")
        exchangeButton:Add(exchangeButtonLabel)
        if item.ticketCost <= ticketCount then
            exchangeButton:AddToClassList("buy-button")
            exchangeButton:RegisterPressCallback(function()
                eggInventoryHandler.ExchangeReward(item)
            end, true, true, true)
        else
            exchangeButton:AddToClassList("buy-button-greyed")
            exchangeButtonLabel:SetPrelocalizedText("Not enough tickets")
        end
        local spacer = VisualElement.new()
        spacer:AddToClassList("spacer")

        spacer:Add(exchangeButton)
        _shopInfoArea:Add(spacer)
    end
end

function Init(_ticketCount)
    closeLabel:SetPrelocalizedText("Close", true)
    _shopInfoArea:Clear()

    closeButton:RegisterPressCallback(function()
        UIManager.CloseQuestRewardUi()
    end, true, true, true)

    ticketCount = _ticketCount

    CreateTabs()
    ButtonPressed("rewards")
end