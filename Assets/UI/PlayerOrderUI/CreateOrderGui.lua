--!Type(UI)
-- Specifies that this script manages UI elements.

--!Bind
local Orders_Root : UIScrollView = nil -- Reference to the root UI element for orders.
--!Bind
local closeButton : UIButton = nil -- Reference to the button for closing the UI.
--!Bind
local closeLabel : UILabel = nil -- Reference to the label for the close button.
--!Bind
local statusLabel : UILabel = nil -- Reference to status label.

local orderManager = require("OrderManager") -- Accesses order management functions.
local playerManager = require("PlayerManager") -- Accesses player management functions.

function GenerateBee(setId)
    local number = math.random(1, 20)
    if setId == "Bronze" then
        if number < 6 then
            return "Common Bee"
        elseif number < 11 then
            return "Stone Bee"
        elseif number < 16 then
            return "Forest Bee"
        elseif number < 18 then
            return "Aquatic Bee"
        elseif number < 20 then
            return "Giant Bee"
        else
            return "Silver Bee"
        end
    elseif setId == "Silver" then
        if number < 6 then
            return "Muddy Bee"
        elseif number < 11 then
            return "Frigid Bee"
        elseif number < 16 then
            return "Steel Bee"
        elseif number < 18 then
            return "Magma Bee"
        elseif number < 20 then
            return "Ghostly Bee"
        else
            return "Storm Bee"
        end
    elseif setId == "Gold" then
        if number < 6 then
            return "Sandy Bee"
        elseif number < 11 then
            return "Autumnal Bee"
        elseif number < 16 then
            return "Petal Bee"
        elseif number < 18 then
            return "Galactic Bee"
        elseif number < 20 then
            return "Radiant Bee"
        else
            return "Rainbow Bee"
        end
    end
end


-- Creates a new quest item in the UI.
function CreateQuestItem(Name, Id, Cash)
    -- Create a new button for the quest item.
    local questItem = UIButton.new()
    questItem:AddToClassList("order-item") -- Add a class to style the quest item.

    -- Create a label for the quest item's title and add it to the quest item.
    local _titleLabel = UILabel.new()
    _titleLabel:AddToClassList("title")
    _titleLabel:SetPrelocalizedText("Buy: " .. Name) -- Set the text to display the quest item's name.
    questItem:Add(_titleLabel)

    -- Create a label for the quest item's XP reward and add it to the quest item.
    -- local _xpLabel = UILabel.new()
    -- _xpLabel:AddToClassList("title")
    -- _xpLabel:SetPrelocalizedText(tostring(XP).."xp") -- Set the text to display the XP reward.
   --  questItem:Add(_xpLabel)

    -- Create a label for the quest item's cash cost and add it to the quest item.
    local _cashLabel = UILabel.new()
    _cashLabel:AddToClassList("title")
    _cashLabel:SetPrelocalizedText("$"..tostring(Cash)) -- Set the text to display the cash cost.
    questItem:Add(_cashLabel)

    -- Add a press callback to the quest item button.
    questItem:RegisterPressCallback(function()
        -- Check if the player is a customer and has enough cash to buy the item.

        if(Id ~= "Net" and playerManager.players[client.localPlayer].Bees.value > 11) then
            statusLabel.visible = true
            statusLabel:SetPrelocalizedText("You already have the maximum number of bees.")
            Timer.new(5, function() statusLabel.visible = false end, false)
            return
        end

        if playerManager.GetPlayerCash() >= Cash then
            
            playerManager.IncrementStat("Cash", -Cash) -- Deduct cash from the player.

            -- Give player a net if that's what they bought
            if Id == "Net" then
                playerManager.IncrementStat("Nets", 1)
                return
            end
            
            local bee = GenerateBee(Id)
            playerManager.notifyBeePurchased:Fire(bee)
            playerManager.GiveBee(bee, false)
        else
            statusLabel.visible = true
            statusLabel:SetPrelocalizedText("You don't have enough honey.")
            Timer.new(5, function() statusLabel.visible = false end, false)
        end
    end, true, true, true)

    -- Add the quest item to the UI.
    Orders_Root:Add(questItem)

    return questItem
end

-- Sets the visibility of the UI.
function SetVisible(visible)
    Orders_Root:EnableInClassList("hidden", not visible)
    closeButton:EnableInClassList("hidden", not visible)
end

-- Called when the UI object this script is attached to is initialized.
function self:Awake()
    statusLabel.visible = false
    SetVisible(false) -- Hide the UI initially.
    closeLabel:SetPrelocalizedText("Close", true) -- Set the text of the close button.
    
    -- Add a callback to the close button to hide the UI when pressed.
    closeButton:RegisterPressCallback(function()
        SetVisible(false)
    end, true, true, true)
end

-- Create quest items for the UI.
local NetMenuItem = CreateQuestItem("Bee Net", "Net", 100)
local BronzeBeeMenuItem = CreateQuestItem("Random Bee from the Bronze Set", "Bronze", 50)
local SilverBeeMenuItem = CreateQuestItem("Random Bee from the Silver Set", "Silver", 250)
local SilverBeeMenuItem = CreateQuestItem("Random Bee from the Gold Set", "Gold", 1250)
