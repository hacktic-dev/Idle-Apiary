--!Type(UI)
-- Specifies that this script manages UI elements.

--!Bind
local BeeList_Root : UIScrollView = nil -- Reference to the root UI element for the bee list.
--!Bind
local closeButton : UIButton = nil -- Reference to the button for closing the UI.
--!Bind
local closeLabel : UILabel = nil -- Reference to the label for the close button.
--!Bind
local statusLabel : UILabel = nil -- Reference to status label.

local playerManager = require("PlayerManager") -- Accesses player management functions.
local wildBeeManager = require("WildBeeManager")

-- Table to store each bee's UI element by beeId
local beeItems = {}

-- Function to create a bee item as a VisualElement with a sell button
function CreateBeeItem(bee)
    local beeItem = VisualElement.new() -- Create each bee item as a VisualElement
    beeItem:AddToClassList("bee-item") -- Apply styling for each bee

    -- Store this item in the beeItems table using bee.beeId as the key
    beeItems[bee.beeId] = beeItem

    -- Create a label for the bee name and add it to the bee item
    local nameLabel = UILabel.new()
    nameLabel:AddToClassList("bee-name")
    nameLabel:SetPrelocalizedText(bee.species)

    local baybeeLabel = UILabel.new()
    baybeeLabel:AddToClassList("bee-name")
    baybeeLabel:SetPrelocalizedText(bee.adult and "Adult Bee" or "Baybee")

    local rarityLabel = UILabel.new()
    rarityLabel:AddToClassList("bee-name")
    rarityLabel:SetPrelocalizedText(wildBeeManager.getRarity(bee.species))

    local rateLabel = UILabel.new()
    rateLabel:AddToClassList("bee-name")
    rateLabel:SetPrelocalizedText("Honey Rate: " .. wildBeeManager.getHoneyRate(bee.species))

    local sellLabel = UILabel.new()
    sellLabel:AddToClassList("bee-name")
    sellLabel:SetPrelocalizedText("Sell price: " .. wildBeeManager.getSellPrice(bee.species))

    beeItem:Add(nameLabel)
    beeItem:Add(baybeeLabel)
    beeItem:Add(rarityLabel)
    beeItem:Add(rateLabel)
    beeItem:Add(sellLabel)

    -- Create a "Sell" button and add it to the bee item
    local sellNameLabel = UILabel.new()
    sellNameLabel:AddToClassList("bee-name")
    sellNameLabel:SetPrelocalizedText("Sell")

    local sellButton = UIButton.new()
    sellButton:AddToClassList("sell-button")
    sellButton:RegisterPressCallback(function()
        SellBee(bee.species, bee.beeId) -- Function to handle selling the bee
    end, true, true, true)
    sellButton:Add(sellNameLabel)
    beeItem:Add(sellButton)

    -- Add the bee item to the BeeList_Root UI list
    BeeList_Root:Add(beeItem)
end

-- Function to handle selling a bee
function SellBee(species, id)
    print("Selling bee with id " .. id)

    -- Check if the bee item exists in the beeItems table
    if beeItems[id] then
        -- Remove the bee item UI element from BeeList_Root
        BeeList_Root:Remove(beeItems[id])
        
        -- Optionally, remove the bee item from the table
        beeItems[id] = nil

        playerManager.SellBee(species, id)
    else
        print("Bee item with id " .. id .. " not found.")
    end
end

-- Function to populate the UI with a list of bees
function PopulateBeeList(bees)
    BeeList_Root:Clear() -- Clear any previous items in the list
    beeItems = {} -- Reset the beeItems table
    for _, bee in ipairs(bees) do
        CreateBeeItem(bee) -- Create and add each bee item to the UI
    end
end

-- Sets the visibility of the UI.
function SetVisible(visible)
    BeeList_Root:EnableInClassList("hidden", not visible)
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