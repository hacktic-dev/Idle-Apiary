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
--!Bind
local _alphabeticalSortLabel : UILabel = nil
--!Bind
local _alphabeticalSort : UIButton = nil
--!Bind
local _raritySortLabel : UILabel = nil
--!Bind
local _raritySort : UIButton = nil
--!Bind
local _honeyRateSortLabel : UILabel = nil
--!Bind
local _honeyRateSort : UIButton = nil
--!Bind
local _sellPriceSortLabel : UILabel = nil
--!Bind
local _sellPriceSort : UIButton = nil
--!Bind
local _confirmSell : VisualElement = nil
--!Bind
local _confirmSellDescription : UIButton = nil
--!Bind
local _confirmSellButton : UIButton = nil
--!Bind
local _confirmSellLabel : UILabel= nil
--!Bind
local _declineSellButton : UIButton = nil
--!Bind
local _declineSellLabel : UILabel = nil


local count = 0

local playerManager = require("PlayerManager") -- Accesses player management functions.
local wildBeeManager = require("WildBeeManager")
local UIManager = require("UIManager")
local audioManager = require("AudioManager")
local Utils = require("Utils")
local hatsManager = require("HatsManager")
local beeObjectManager = require("BeeObjectManager")

local sortMode = 1

local selectedBee = nil

-- Table to store each bee's UI element by beeId
local beeItems = {}

function MapRarity(rarity)
    if rarity == "Common" then
        return 0
    elseif rarity == "Uncommon" then
        return 1
    elseif rarity == "Rare" then
        return 2
    elseif rarity == "Epic" then
        return 3
    elseif rarity == "Legendary" then
        return 4
    end
end
    

-- Function to create a bee item as a VisualElement with a sell button
function CreateBeeItem(bee)
    local beeItem = VisualElement.new() -- Create each bee item as a VisualElement
    beeItem:AddToClassList("bee-item") -- Apply styling for each bee

    -- Store this item in the beeItems table using bee.beeId as the key
    beeItems[bee.beeId] = beeItem

    -- Create a label for the bee name and add it to the bee item
    local nameLabel = UILabel.new()
    nameLabel:AddToClassList("bee-title")
    nameLabel:SetPrelocalizedText(bee.species)

    local _image = UIImage.new()
    _image:AddToClassList("inventory__item__icon__image")
    _image.image = Utils.BeeImage[bee.species]

    local baybeeLabel = UILabel.new()
    baybeeLabel:AddToClassList("bee-name")
    baybeeLabel:SetPrelocalizedText(bee.adult and "Adult Bee" or "Baybee")

    local rarityLabel = UILabel.new()
    rarityLabel:AddToClassList("bee-name")
    rarityLabel:SetPrelocalizedText(wildBeeManager.getRarity(bee.species) .. " Rarity")

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
    beeItem:Add(_image)
    beeItem:Add(baybeeLabel)
    beeItem:Add(rarityLabel)
    beeItem:Add(rateLabel)
    beeItem:Add(sellLabel)

    local rowContainer = VisualElement.new()
    rowContainer:AddToClassList("row-container")

    -- Only able to sell adults
    if bee.adult then
        -- Create a "Sell" button and add it to the bee item
        local sellNameLabel = UILabel.new()
        sellNameLabel:AddToClassList("bee-name")
        sellNameLabel:SetPrelocalizedText("Sell")

        local sellButton = UIButton.new()
        sellButton:AddToClassList("sell-button")
        sellButton:RegisterPressCallback(function()
            selectedBee = bee
            _confirmSell.visible = true
        end, true, true, true)
        sellButton:Add(sellNameLabel)
        rowContainer:Add(sellButton)

        if bee.hat == nil then
            local addHatLabel = UILabel.new()
            addHatLabel:AddToClassList("bee-name")
            addHatLabel:SetPrelocalizedText("Add Hat")
    
            local addHatButton = UIButton.new()
            addHatButton:AddToClassList("add-hat")
            addHatButton:RegisterPressCallback(function()
                 hatsManager.SetSelectedBee(bee.beeId)
                 UIManager.OpenAddHatMenu()
            end, true, true, true)
            addHatButton:Add(addHatLabel)
            rowContainer:Add(addHatButton)
        else
            local removeHatLabel = UILabel.new()
            removeHatLabel:AddToClassList("bee-name")
            removeHatLabel:SetPrelocalizedText("Remove Hat")
    
            local removeHatButton = UIButton.new()
            removeHatButton:AddToClassList("remove-hat")
            removeHatButton:RegisterPressCallback(function()
                beeObjectManager.requestApplyHat:FireServer(nil, bee.beeId)
                playerManager.requestRemoveBeeHat:FireServer(bee.beeId)
                BeeList_Root:Clear()
                playerManager.RequestBeeList()
            end, true, true, true)
            removeHatButton:Add(removeHatLabel)
            rowContainer:Add(removeHatButton)
        end
    else
        -- Create a "Sell" button and add it to the bee item
        local sellNameLabel = UILabel.new()
        sellNameLabel:AddToClassList("bee-name")
        sellNameLabel:SetPrelocalizedText("Wait")

        local sellButton = UIButton.new()
        sellButton:AddToClassList("sell-button-greyed")
        sellButton:Add(sellNameLabel)
        rowContainer:Add(sellButton)
    end

    beeItem:Add(rowContainer)

    -- Add the bee item to the BeeList_Root UI list
    BeeList_Root:Add(beeItem)
end

_alphabeticalSort:RegisterPressCallback(function()
    sortMode = 0
    BeeList_Root:Clear()
    playerManager.RequestBeeList()
end, true, true, true)


_raritySort:RegisterPressCallback(function()
    sortMode = 1
    BeeList_Root:Clear()
    playerManager.RequestBeeList()
end, true, true, true)

_honeyRateSort:RegisterPressCallback(function()
    sortMode = 2
    BeeList_Root:Clear()
    playerManager.RequestBeeList()
end, true, true, true)

_sellPriceSort:RegisterPressCallback(function()
    sortMode = 3
    BeeList_Root:Clear()
    playerManager.RequestBeeList()
end, true, true, true)


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
    table.sort(bees, function(a, b)
        if sortMode == 0 then
            return a.species < b.species
        elseif sortMode == 1 then
            return MapRarity(wildBeeManager.getRarity(a.species)) > MapRarity(wildBeeManager.getRarity(b.species))
        elseif sortMode == 2 then
            return wildBeeManager.getHoneyRate(a.species) > wildBeeManager.getHoneyRate(b.species)
        elseif sortMode == 3 then
            return wildBeeManager.getSellPrice(a.species) >  wildBeeManager.getSellPrice(b.species)
        end
    end
    )
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
    _alphabeticalSortLabel:SetPrelocalizedText("Sort Alphabetically")
    _raritySortLabel:SetPrelocalizedText("Sort by Rarity")
    _honeyRateSortLabel:SetPrelocalizedText("Sort by Honey Rate")
    _sellPriceSortLabel:SetPrelocalizedText("Sort by Sell Price")
    _confirmSellDescription:SetPrelocalizedText("Are you sure you want to sell this bee?")
    _confirmSellLabel:SetPrelocalizedText("Sell")
    _declineSellLabel:SetPrelocalizedText("Don't Sell")
    
    if Screen.height > Screen.width then
        _alphabeticalSort:AddToClassList("hidden")
        _raritySort:AddToClassList("hidden")
        _sellPriceSort:AddToClassList("hidden")
        _honeyRateSort:AddToClassList("hidden")
    end

    _confirmSell.visible = false

    closeLabel:SetPrelocalizedText("Close", true) -- Set the text of the close button.

    -- Add a callback to the close button to hide the UI when pressed.
    closeButton:RegisterPressCallback(function()
        UIManager.CloseBeeList()
    end, true, true, true)

    _confirmSellButton:RegisterPressCallback(function()
        SellBee(selectedBee.species, selectedBee.beeId, selectedBee.adult)
        _confirmSell.visible = false end, true, true, true
    )

    _declineSellButton:RegisterPressCallback(function()
        _confirmSell.visible = false end, true, true, true
    )
end

function self:ClientAwake()
    totalHoneyRateLabel:SetPrelocalizedText("Total Honey Rate: " .. 0)

    playerManager.playerEarnRateChanged:Connect(function(rate)
        if rate ~= 0 then
            rate = sigFig(rate, 5)
        end
        totalHoneyRateLabel:SetPrelocalizedText("Total Honey Rate: " .. rate)
    end)
end

function sigFig(num,figures)
    local x=figures - math.ceil(math.log10(math.abs(num)))
    return(math.floor(num*10^x+0.5)/10^x)
end
