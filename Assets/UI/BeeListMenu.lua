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
--!Bind
local beeCountLabel : UILabel = nil
--!Bind
local totalHoneyRateLabel : UILabel = nil

local count = 0;

local playerManager = require("PlayerManager") -- Accesses player management functions.
local wildBeeManager = require("WildBeeManager")
local UIManager = require("UIManager")
local audioManager = require("AudioManager")

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

    local honeyRate = 0
    if bee.adult then
        honeyRate = wildBeeManager.getHoneyRate(bee.species)
    end

    local rateLabel = UILabel.new()
    rateLabel:AddToClassList("bee-name")
    rateLabel:SetPrelocalizedText("Honey Rate: " .. honeyRate)

    local sellPrice = wildBeeManager.getSellPrice(bee.species)

    local sellLabel = UILabel.new()
    sellLabel:AddToClassList("bee-name")
    sellLabel:SetPrelocalizedText("Sell price: " .. sellPrice)

    beeItem:Add(nameLabel)
    beeItem:Add(baybeeLabel)
    beeItem:Add(rarityLabel)
    beeItem:Add(rateLabel)
    beeItem:Add(sellLabel)

    -- Only able to sell adults
    if bee.adult then
        -- Create a "Sell" button and add it to the bee item
        local sellNameLabel = UILabel.new()
        sellNameLabel:AddToClassList("bee-name")
        sellNameLabel:SetPrelocalizedText("Sell")

        local sellButton = UIButton.new()
        sellButton:AddToClassList("sell-button")
        sellButton:RegisterPressCallback(function()
            SellBee(bee.species, bee.beeId, bee.adult) -- Function to handle selling the bee
        end, true, true, true)
        sellButton:Add(sellNameLabel)
        beeItem:Add(sellButton)
    else
        -- Create a "Sell" button and add it to the bee item
        local sellNameLabel = UILabel.new()
        sellNameLabel:AddToClassList("bee-name")
        sellNameLabel:SetPrelocalizedText("Wait")

        local sellButton = UIButton.new()
        sellButton:AddToClassList("sell-button-greyed")
        sellButton:Add(sellNameLabel)
        beeItem:Add(sellButton)
    end

    -- Add the bee item to the BeeList_Root UI list
    BeeList_Root:Add(beeItem)
end

-- Function to handle selling a bee
function SellBee(species, id, isAdult)
    print("Selling bee with id " .. id)

    -- Check if the bee item exists in the beeItems table
    if beeItems[id] then
        -- Remove the bee item UI element from BeeList_Root
        BeeList_Root:Remove(beeItems[id])
        
        -- Optionally, remove the bee item from the table
        beeItems[id] = nil

        audioManager.PlaySound("purchaseSound", 1)
        playerManager.SellBee(species, id, isAdult)
        count = count-1
        beeCountLabel:SetPrelocalizedText(count .. "/" .. playerManager.GetPlayerBeeCapacity(), true)
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
    count = #bees
    beeCountLabel:SetPrelocalizedText(count .. "/" .. playerManager.GetPlayerBeeCapacity(), true)
    
end

-- Called when the UI object this script is attached to is initialized.
function Init()
    statusLabel.visible = false
    closeLabel:SetPrelocalizedText("Close", true) -- Set the text of the close button.

    -- Add a callback to the close button to hide the UI when pressed.
    closeButton:RegisterPressCallback(function()
        UIManager.CloseBeeList()
    end, true, true, true)
end

function self:ClientAwake()
    totalHoneyRateLabel:SetPrelocalizedText("Total Honey Rate: " .. 0)

    playerManager.playerEarnRateChanged:Connect(function(rate)
        totalHoneyRateLabel:SetPrelocalizedText("Total Honey Rate: " .. sigFig(rate, 5))
    end)
end

function sigFig(num,figures)
    local x=figures - math.ceil(math.log10(math.abs(num)))
    return(math.floor(num*10^x+0.5)/10^x)
end
