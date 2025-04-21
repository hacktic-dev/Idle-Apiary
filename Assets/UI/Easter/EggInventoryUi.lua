--!Type(UI)

--!Bind
local eggInventoryScreen : VisualElement = nil

UIManager = require("UIManager")
playerManager = require("PlayerManager")
eggInventoryHandler = require("EggInventoryHandler")

recievedEggs = false
recievedBeeEggs = false
eggs = {}
beeEggs = {}

eggIds =
{
    "egg_red",
    "egg_orange",
    "egg_yellow",
    "egg_green",
    "egg_purple",
    "egg_pink",
    "egg_white",
    "egg_gold"
}

beeEggIds = 
{
    "regular_bee_egg",
    "pink_bee_egg",
    "white_bee_egg",
    "gold_bee_egg"
}

function Init()
    recievedEggs = false
    recievedBeeEggs = false
    eggInventoryHandler.RequestEggInventoryDisplayEvent:FireServer()
    eggInventoryHandler.RequestBeeEggInventoryEvent:FireServer()
end

function self:ClientAwake()
    eggInventoryHandler.NotifyEggInventoryDisplayEvent:Connect(function(eggInventory)
        
        eggs = eggInventory
        recievedEggs = true

        if recievedEggs and recievedBeeEggs then
           FillOut()
        end
    end)

    eggInventoryHandler.NotifyBeeEggInventoryDisplayEvent:Connect(function(eggInventory)
        
        beeEggs = eggInventory
        recievedBeeEggs = true

        if recievedEggs and recievedBeeEggs then
           FillOut()
        end
    end)
end

function FillOut()
    eggInventoryScreen:Clear()

    local eggIcons = {
        egg_red = "redEggIcon",
        egg_orange = "orangeEggIcon",
        egg_yellow = "yellowEggIcon",
        egg_green = "greenEggIcon",
        egg_purple = "purpleEggIcon",
        egg_pink = "pinkEggIcon",
        egg_white = "whiteEggIcon",
        egg_gold = "goldEggIcon"
    }

    local beeEggIcons = {
        regular_bee_egg = "beeEggIcon",
        pink_bee_egg = "pinkBeeEggIcon",
        white_bee_egg = "whiteBeeEggIcon",
        gold_bee_egg = "goldBeeEggIcon"
    }

    local function AddEggRow(container, items, labelText, eggIcons, eggIds)
        local rowLabel = UILabel.new()
        rowLabel:SetPrelocalizedText(labelText)
        rowLabel:AddToClassList("subtitle")
        container:Add(rowLabel)

        local horizontalContainer = nil
        for index, eggType in ipairs(eggIds) do
            if (index - 1) % 4 == 0 then
                horizontalContainer = VisualElement.new()
                horizontalContainer:AddToClassList("horizontal-container")
            end

            local count = items[eggType] or 0 
            
            if count then
                local eggCounterContainer = VisualElement.new()
                eggCounterContainer:AddToClassList("egg__icon__confirmation_container")

                local eggIcon = VisualElement.new()
                eggIcon:AddToClassList("egg__icon")
                eggIcon:AddToClassList("egg__icon__confirm")
                eggIcon:AddToClassList(eggIcons[eggType])
                eggCounterContainer:Add(eggIcon)

                local eggCountLabel = UILabel.new()
                eggCountLabel:SetPrelocalizedText(tostring(count))
                eggCountLabel:AddToClassList("egg__icon_label")
                eggCounterContainer:Add(eggCountLabel)

                horizontalContainer:Add(eggCounterContainer)
            end

            container:Add(horizontalContainer)
        end
    end

    AddEggRow(eggInventoryScreen, eggs, "Easter Eggs", eggIcons, eggIds)
    AddEggRow(eggInventoryScreen, beeEggs, "Bee Eggs", beeEggIcons, beeEggIds)

    -- Add Close button
    local closeButton = UIButton.new()
    local closeLabel = UILabel.new()
    closeLabel:SetPrelocalizedText("Close")
    closeLabel:AddToClassList("title")
    closeButton:AddToClassList("trade__ui_button")
    closeButton:Add(closeLabel)
    closeButton:RegisterPressCallback(function()
        UIManager.CloseEggInventory()
    end, true, true, true)
    eggInventoryScreen:Add(closeButton)
end