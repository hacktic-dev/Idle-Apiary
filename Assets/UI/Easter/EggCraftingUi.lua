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
local petOnJobLabel : UILabel = nil
--!Bind
local cancelButton : UIButton = nil
--!Bind
local cancelLabel : UILabel = nil
--!Bind
local shopHeader : VisualElement = nil
--!Bind
local redEggCount : UILabel = nil
--!Bind
local orangeEggCount : UILabel = nil
--!Bind
local yellowEggCount : UILabel = nil
--!Bind
local greenEggCount : UILabel = nil
--!Bind
local purpleEggCount : UILabel = nil
--!Bind
local pinkEggCount : UILabel = nil
--!Bind
local whiteEggCount : UILabel = nil
--!Bind
local goldEggCount : UILabel = nil


UIManager = require("UIManager")

local recipes =
{
    {id = "regular_egg", name = "Regular Egg", description = "Hatches a random Easter Bee", requirement = {"egg_red", "egg_orange", "egg_yellow", "egg_green", "egg_purple"} },
    {id = "pink_egg", name = "Pink Egg", description = "Hatches a rare Pink Easter Bee", requirement = {"egg_red", "egg_orange", "egg_yellow", "egg_green", "egg_purple", "egg_pink"} },
    {id = "white_egg", name = "White Egg", description = "Hatches an ultra-rare White Easter Bee", requirement = {"egg_red", "egg_orange", "egg_yellow", "egg_green", "egg_purple", "egg_white"} },
    {id = "gold_egg", name = "Golden Egg", description = "Hatches a legendary Golden Easter Bee!", requirement = {"egg_red", "egg_orange", "egg_yellow", "egg_green", "egg_purple", "egg_gold"} },
}


local function CreateItems(items)
    Orders_Root:Clear()
    _shopInfoArea:Clear()
    for _, item in ipairs(items) do
        CreateItem(item)
    end
end

local tabs = {
    { name = "Craft Eggs", callback = function() CreateItems(recipes) end },
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

        local descriptionLabel = UILabel.new()
        descriptionLabel:AddToClassList("description")
        descriptionLabel:AddToClassList("centered")
        descriptionLabel:SetPrelocalizedText(item.description)
        _shopInfoArea:Add(descriptionLabel)

        local horizontalContainer = VisualElement.new()
        horizontalContainer:AddToClassList("horizontal-container")
        _shopInfoArea:Add(horizontalContainer)

        local eggIdToClassMap = {
            egg_red = "redEggIcon",
            egg_orange = "orangeEggIcon",
            egg_yellow = "yellowEggIcon",
            egg_green = "greenEggIcon",
            egg_purple = "purpleEggIcon",
            egg_pink = "pinkEggIcon",
            egg_white = "whiteEggIcon",
            egg_gold = "goldEggIcon",
        }

        local currentRow = horizontalContainer
        for index, eggId in ipairs(item.requirement) do
            if (index - 1) % 3 == 0 and index > 1 then
            -- Create a new row after every 3 items
            currentRow = VisualElement.new()
            currentRow:AddToClassList("horizontal-container")
            _shopInfoArea:Add(currentRow)
            end

            local eggIcon = VisualElement.new()
            local className = eggIdToClassMap[eggId]
            if className then
            eggIcon:AddToClassList(className)
            else
            print("Warning: No class mapping found for egg ID: " .. eggId)
            end
            currentRow:Add(eggIcon)

            -- Add a plus label only if it's not the last item
            if index < #item.requirement then
            local plusLabel = UILabel.new()
            plusLabel:AddToClassList("plus-text")
            plusLabel:SetPrelocalizedText("+")
            currentRow:Add(plusLabel)
            end
        end

        local craftButton = UIButton.new()
        local craftButtonLabel = UILabel.new()
        craftButtonLabel:AddToClassList("title")
        craftButtonLabel:SetPrelocalizedText("Craft")
        craftButton:Add(craftButtonLabel)
        if false then -- TODO: Check actual crafting conditions
            craftButton:AddToClassList("buy-button-greyed")
            craftButtonLabel:SetPrelocalizedText("Insufficient resources")
        else
            craftButton:AddToClassList("buy-button")
            craftButton:RegisterPressCallback(function()
                    CraftEgg(Id, item)
            end, true, true, true)
        end
        local spacer = VisualElement.new()
        spacer:AddToClassList("spacer")

        spacer:Add(craftButton)
        _shopInfoArea:Add(spacer)
    end
end

function FillOutEggCounts(eggInventory)
    redEggCount:SetPrelocalizedText(eggInventory["egg_red"] or 0)
    orangeEggCount:SetPrelocalizedText(eggInventory["egg_orange"] or 0)
    yellowEggCount:SetPrelocalizedText(eggInventory["egg_yellow"] or 0)
    greenEggCount:SetPrelocalizedText(eggInventory["egg_green"] or 0)
    purpleEggCount:SetPrelocalizedText(eggInventory["egg_purple"] or 0)
    pinkEggCount:SetPrelocalizedText(eggInventory["egg_pink"] or 0)
    whiteEggCount:SetPrelocalizedText(eggInventory["egg_white"] or 0)
    goldEggCount:SetPrelocalizedText(eggInventory["egg_gold"] or 0)
end

function Init(eggInventory)
    closeLabel:SetPrelocalizedText("Close", true)
    _shopInfoArea:Clear()

    closeButton:RegisterPressCallback(function()
        UIManager.CloseEggCraftingUi()
    end, true, true, true)

    -- Create and initialize the tabs
    CreateTabs()

    -- Initialize the first tab
    ButtonPressed("craft eggs")

    FillOutEggCounts(eggInventory)
end

function self:ClientAwake()
end