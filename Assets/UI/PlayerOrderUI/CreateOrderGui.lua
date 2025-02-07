--!Type(UI)


--!Bind
local Orders_Root : UIScrollView = nil
--!Bind
local closeButton : UIButton = nil
--!Bind
local closeLabel : UILabel = nil
--!Bind
local _upgradesTab : UIButton = nil
--!Bind
local _beesTab : UIButton = nil
--!Bind
local _honeyTab : UIButton = nil
--!Bind
local _cosmeticsTab : UIButton = nil
--!Bind
local _furnitureTab : UIButton = nil
--!Bind
local upgradesLabel : UILabel = nil
--!Bind
local honeyLabel : UILabel = nil
--!Bind
local timeToReset : UILabel = nil
--!Bind
local timeContainer : UIButton = nil
--!Bind
local _confirmBuy : VisualElement = nil
--!Bind
local _confirmBuyDescription : UIButton = nil
--!Bind
local _confirmBuyButton : UIButton = nil
--!Bind
local _confirmBuyLabel : UILabel= nil
--!Bind
local _declineBuyButton : UIButton = nil
--!Bind
local _declineBuyLabel : UILabel = nil

--!Bind
local _confirmGoldOrHoney : VisualElement = nil
--!Bind
local _confirmGoldOrHoneyDescription : UILabel = nil
--!Bind
local _buyWithGoldButton : UIButton = nil
--!Bind
local _buyWithGoldLabel : UILabel= nil
--!Bind
local _buyWithHoneyButton : UIButton = nil
--!Bind
local _buyWithHoneyLabel : UILabel = nil

--!SerializeField
local statusObject : GameObject = nil

--!SerializeField
local BeeListObject : GameObject = nil

local orderManager = require("OrderManager")
local playerManager = require("PlayerManager")
local UIManager = require("UIManager") 
local audioManager = require("AudioManager")
local purchaseHandler = require("PurchaseHandler")
local apiaryManager = require("ApiaryManager")
local Utils = require("Utils")

local state = 0 -- Which tab are we on?

local selectedIsGold
local selectedId
local selectedCash
local  selectedName
local purchaseType = "generic"

-- client
local soldOutHats = {}

local soldOutFurniture = {}

function GetSoldOutFurniture()
    return soldOutFurniture
end

_upgradesTab:RegisterPressCallback(function()
    local success = ButtonPressed("upgrades")
  end, true, true, true)
  
_beesTab:RegisterPressCallback(function()
    local success = ButtonPressed("bees")
end, true, true, true)

_honeyTab:RegisterPressCallback(function()
    local success = ButtonPressed("honey")
end, true, true, true)

_cosmeticsTab:RegisterPressCallback(function()
    local success = ButtonPressed("cosmetics")
end, true, true, true)

_furnitureTab:RegisterPressCallback(function()
    local success = ButtonPressed("furniture")
end, true, true, true)

function GetSoldOutHats()
    return soldOutHats
end

function InitUpgradesTab(beeCapacity, flowerCapacity, sweetScentLevel, apiarySize)
    Orders_Root:Clear()

    if beeCapacity < 18 then
        CreateQuestItem("Upgrade Bee Capacity to " .. beeCapacity+1 .. " Bees", "BeeCapacity", LookupBeeCapacityUpgradePrice(beeCapacity + 1), false, "", true)
    elseif beeCapacity == 18 then
			CreateQuestItem("Upgrade Bee Capacity to " .. beeCapacity+1 .. " Bees", "bee_size_1", LookupBeeCapacityUpgradePrice(beeCapacity + 1), false, "", false, 100)
		elseif beeCapacity == 19 then
			CreateQuestItem("Upgrade Bee Capacity to " .. beeCapacity+1 .. " Bees", "bee_size_2", LookupBeeCapacityUpgradePrice(beeCapacity + 1), false, "", false, 250)
		end

    if sweetScentLevel < 3 then
        CreateQuestItem("Sweet Scent Upgrade #" .. sweetScentLevel+1, "SweetScentLevel", LookupSweetScentLevelPrice(sweetScentLevel + 1), false, "Rarer bees spawn more frequently", true)
    end

    if playerManager.players[client.localPlayer].HasShears.value == false then
        CreateQuestItem("Shears", "Shears", 5000, false, "Can be used to pick flowers", true)
    else
       if flowerCapacity < 10 then
        CreateQuestItem("Upgrade Flower Capacity to " .. flowerCapacity+1 .. " Flowers", "FlowerCapacity", LookupFlowerCapacityUpgradePrice(flowerCapacity + 1), false, "", true)
       end
    end

    if apiarySize == 0 then
        CreateQuestItem("Upgrade Apiary Size", "apiary_size_1", 250000, false, "Make space for more furniture", false, 250)
    elseif apiarySize == 1 then
        CreateQuestItem("Upgrade Apiary Size", "apiary_size_2", 500000, false, "Make space for more furniture", false, 500)
    end

end

local function InitBeesTab()
    Orders_Root:Clear()
    CreateQuestItem("Random Bee", "Bronze", 50, false, "Bronze Set", false)
    CreateQuestItem("Random Bee", "Silver", 250, false, "Silver Set", false)
    CreateQuestItem("Random Bee", "Gold", 1250, false, "Gold Set", false)
    CreateQuestItem("Random Bee", "Platinum", 5000, false, "Platinum Set", false)
end

local function InitHoneyTab(sweetScentLevel)
    Orders_Root:Clear()

    if sweetScentLevel == 0 then
        netPrice = 50
    elseif sweetScentLevel == 1 then
        netPrice = 200
    elseif sweetScentLevel == 2 then
        netPrice = 600
    elseif sweetScentLevel >= 3 then
        netPrice = 1000
    end

    CreateQuestItem("Bee Net", "Net", netPrice, false, "", false)


    CreateQuestItem("Honey Doubler", "doubler_1", 250, true, "Doubles honey rate for the next 5 minutes.", false)
    CreateQuestItem("Honey Doubler Pro", "doubler_2", 500, true, "Doubles honey rate for the next 15 minutes", false)
end

local function getSeed()
    local now = os.time() -- Get the current time
    local one_hour = 3600 -- 1 hour in seconds
    return math.floor(now / one_hour) -- Determine the current 4-hour block
end

local function formatTime(seconds)
    local one_hour = 3600
    local hours = math.floor(seconds / one_hour)
    local minutes = math.floor((seconds % one_hour) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Function to calculate the time until the next seed change
local function timeUntilNextSeed()
    local now = os.time() -- Get the current time
    local one_hour = 3600 -- 1 hour in seconds
    local next_seed_time = (math.floor(now / one_hour) + 1) * one_hour

    --TODO reset shop when timeout
    if next_seed_time - now == one_hour and state == 3 then
        InitCosmeticsTab()
    elseif next_seed_time - now == one_hour and state == 4 then
        InitFurnitureTab()
    end

    return formatTime(next_seed_time - now) -- Time remaining until the next 4-hour block
end

function InitCosmeticsTab()
    -- Seed the random number generator
    print("Seed: " .. getSeed())
    math.randomseed(getSeed())
    Orders_Root:Clear()

    local hats = {} 

    local i = 0
    -- First loop for premium hats
    while i < 2 do
        local hat = Utils.ChooseHat(true)
        if hat and hats[hat.name] == nil then
            hats[hat.name] = hat
            CreateHatItem(hat.name, hat.id, hat.rarity, hat.goldCost, true, false)
            i = i + 1
        end
    end

    i = 0
    -- Second loop for regular hats
    while i < 4 do
        local hat = Utils.ChooseHat(false)
        if hat and hats[hat.name] == nil then
            hats[hat.name] = hat
            local isSoldOut = soldOutHats[hat.id] and os.time() < soldOutHats[hat.id]
            CreateHatItem(hat.name, hat.id, hat.rarity, hat.cost, false, isSoldOut)
            i = i + 1
        end
    end
end

function InitFurnitureTab()
    -- Seed the random number generator
    print("Seed: " .. getSeed())
    math.randomseed(getSeed())
    Orders_Root:Clear()

    local furnitureItems = {}

    local i = 0
    -- First loop for premium furniture items
    while i < 2 do
        local furniture = Utils.ChooseFurniture(true)
        if furniture and furnitureItems[furniture.name] == nil then
            furnitureItems[furniture.name] = furniture
            CreateFurnitureItem(furniture.name, furniture.id, furniture.goldCost, true, false)
            i = i + 1
        end
    end

    i = 0
    -- Second loop for regular furniture items
    while i < 4 do
        local furniture = Utils.ChooseFurniture(false)
        if furniture and furnitureItems[furniture.name] == nil then
            furnitureItems[furniture.name] = furniture
            local isSoldOut = soldOutFurniture[furniture.id] and os.time() < soldOutFurniture[furniture.id]
            CreateFurnitureItem(furniture.name, furniture.id, furniture.cost, false, isSoldOut)
            i = i + 1
        end
    end
end

function CreateFurnitureItem(Name, Id, Cash, isGold, isSoldOut)
    local questItem = UIButton.new()
    questItem:AddToClassList("furniture-item") -- Add a class to style the quest item.

    if isSoldOut then
        local soldOutLabel = UILabel.new()
        soldOutLabel:AddToClassList("furniture-title")
        soldOutLabel:AddToClassList("text-center")
        soldOutLabel:SetPrelocalizedText("Sold Out")
        questItem:Add(soldOutLabel)

        local soldOutLabelDescription = UILabel.new()
        soldOutLabelDescription:AddToClassList("description")
        soldOutLabelDescription:AddToClassList("text-center")
        soldOutLabelDescription:SetPrelocalizedText("Check back again later")
        questItem:Add(soldOutLabelDescription)

        Orders_Root:Add(questItem)

        return questItem
    end

    -- Create a label for the quest item's title and add it to the quest item.
    local _titleLabel = UILabel.new()
    _titleLabel:AddToClassList("furniture-title")
    _titleLabel:SetPrelocalizedText(Name) -- Set the text to display the quest item's name.
    questItem:Add(_titleLabel)

    local _priceContainer = VisualElement.new()
    _priceContainer:AddToClassList("priceContainerFurniture")

    if not isGold then
        local _icon = UIImage.new()
        _icon:AddToClassList("icon_honey")
        _priceContainer:Add(_icon)
    else
        local _icon = UIImage.new()
        _icon:AddToClassList("icon_gold")
        _priceContainer:Add(_icon)
    end

    local _image = UIImage.new()

    local container = VisualElement.new()
    container:AddToClassList("row-container")

    -- Create a label for the quest item's cash cost and add it to the quest item.
    local _cashLabel = UILabel.new()
    if Screen.width > Screen.height and Screen.height < 1000 then
        _cashLabel:AddToClassList("furniture-price")
        _image:AddToClassList("furniture-image-small")
    else
        _cashLabel:AddToClassList("furniture-price")
        _image:AddToClassList("furniture-image")
    end

    _image.image = Utils.FurnitureImage[Name]
    questItem:Add(_image)

    _cashLabel:SetPrelocalizedText(tostring(Cash)) -- Set the text to display the cash cost.
    _priceContainer:Add(_cashLabel)
    container:Add(_priceContainer)

    questItem:Add(container)

    questItem:RegisterPressCallback(function()
        if not isGold then
            selectedIsGold = isGold
            selectedId = Id
            selectedCash = Cash
            selectedName = Name
            purchaseType = "furniture"
            _confirmBuy.visible = true
        else
            BuyItem(isGold, Id, Name, Cash, "furniture")
        end
    end)

    -- Add the quest item to the UI.
    Orders_Root:Add(questItem)

    return questItem
end

function ButtonPressed(btn: string)
    if btn == "upgrades" then
      if state == 0 then return end
      state = 0
      _upgradesTab:AddToClassList("nav-button--selected")
      _upgradesTab:RemoveFromClassList("nav-button--deselected")
      _beesTab:AddToClassList("nav-button--deselected")
      _honeyTab:AddToClassList("nav-button--deselected")
      _cosmeticsTab:AddToClassList("nav-button--deselected")
      _furnitureTab:AddToClassList("nav-button--deselected")
      Orders_Root:RemoveFromClassList("high-margin")
      timeContainer.visible = false
      InitUpgradesTab(playerManager.GetPlayerBeeCapacity(), playerManager.GetPlayerFlowerCapacity(), playerManager.GetPlayerSweetScentLevel(), playerManager.GetPlayerApiarySize())
      --audioManager.PlaySound("paperSound1", 1)
      return true
    elseif btn == "bees" then
      if state == 1 then return end
      state = 1
      _beesTab:AddToClassList("nav-button--selected")
      _beesTab:RemoveFromClassList("nav-button--deselected")
      _upgradesTab:AddToClassList("nav-button--deselected")
      _honeyTab:AddToClassList("nav-button--deselected")
      _cosmeticsTab:AddToClassList("nav-button--deselected")
      _furnitureTab:AddToClassList("nav-button--deselected")
      Orders_Root:RemoveFromClassList("high-margin")
      timeContainer.visible = false
      InitBeesTab()
      --audioManager.PlaySound("paperSound1", 1)
      return true
    elseif btn == "honey" then
        if state == 2 then return end
        state = 2
        _honeyTab:AddToClassList("nav-button--selected")
        _honeyTab:RemoveFromClassList("nav-button--deselected")
        _beesTab:AddToClassList("nav-button--deselected")
        _upgradesTab:AddToClassList("nav-button--deselected")
        _cosmeticsTab:AddToClassList("nav-button--deselected")
        _furnitureTab:AddToClassList("nav-button--deselected")
        Orders_Root:RemoveFromClassList("high-margin")
        timeContainer.visible = false
        InitHoneyTab(playerManager.GetPlayerSweetScentLevel())
    elseif btn == "cosmetics" then
    if state == 3 then return end
      state = 3
      _cosmeticsTab:AddToClassList("nav-button--selected")
      _cosmeticsTab:RemoveFromClassList("nav-button--deselected")
      _beesTab:AddToClassList("nav-button--deselected")
      _upgradesTab:AddToClassList("nav-button--deselected")
      _honeyTab:AddToClassList("nav-button--deselected")
      _furnitureTab:AddToClassList("nav-button--deselected")
      timeContainer.visible = true
      Orders_Root:AddToClassList("high-margin")
      timeToReset:SetPrelocalizedText("Time until shop resets: " .. timeUntilNextSeed())
      InitCosmeticsTab()
      return true
    elseif btn == "furniture" then
        if state == 4 then return end
        state = 4
        _furnitureTab:AddToClassList("nav-button--selected")
        _furnitureTab:RemoveFromClassList("nav-button--deselected")
        _upgradesTab:AddToClassList("nav-button--deselected")
        _beesTab:AddToClassList("nav-button--deselected")
        _honeyTab:AddToClassList("nav-button--deselected")
        _cosmeticsTab:AddToClassList("nav-button--deselected")
        Orders_Root:AddToClassList("high-margin")
        timeToReset:SetPrelocalizedText("Time until shop resets: " .. timeUntilNextSeed())
        timeContainer.visible = true
        InitFurnitureTab()
        return true
    end
end
  
function LookupSweetScentLevelPrice(level)
    if level == 1 then
        return 500
    elseif level == 2 then
        return 2000
    elseif level == 3 then
        return 8000
    end
end

function LookupFlowerCapacityUpgradePrice(capacity)
    if capacity == 6 then
        return 5000 
    elseif capacity == 7 then
        return 8000 
    elseif capacity == 8 then
        return 12000 
    elseif capacity == 9 then
        return 15000 
    elseif capacity == 10 then
        return 20000 
    end
end

function LookupBeeCapacityUpgradePrice(capacity)
    if capacity == 9 then
        return 200
    elseif capacity == 10 then
        return 500
    elseif capacity == 11 then
        return 1000
    elseif capacity == 12 then
        return 2000
    elseif capacity == 13 then
        return 5000
    elseif capacity == 14 then
        return 8000
    elseif capacity == 15 then
        return 10000
    elseif capacity == 16 then
        return 15000
    elseif capacity == 17 then
        return 25000
    elseif capacity == 18 then
        return 50000
    elseif capacity == 19 then
        return 100000
    elseif capacity == 20 then
        return 250000
    end
end

  function GenerateBee(setId)
    -- Define the chances for each bee in different sets
    local chances = {
        Bronze = {
            {name = "Common Bee", chance = 19},  -- 5 * 5
            {name = "Stone Bee", chance = 19},   -- 5 * 5
            {name = "Meadow Bee", chance = 19},  -- 5 * 5
            {name = "Forest Bee", chance = 19},  -- 5 * 5
            {name = "Aquatic Bee", chance = 15}, -- 2 * 5
            {name = "Giant Bee", chance = 15},   -- 2 * 5
            {name = "Bronze Bee", chance = 15},
            {name = "Silver Bee", chance = 13}    -- 1 * 5
        },
        Silver = {
            {name = "Muddy Bee", chance = 19},   -- 5 * 5
            {name = "Frigid Bee", chance = 19},  -- 5 * 5
            {name = "Oceanic Bee", chance = 19}, -- 5 * 5
            {name = "Steel Bee", chance = 19},   -- 5 * 5
            {name = "Magma Bee", chance = 15},   -- 2 * 5
            {name = "Ghostly Bee", chance = 15}, -- 2 * 5
            {name = "Ruby Bee", chance = 15}  ,   -- 1 * 5
            {name = "Iridescent Bee", chance = 13} -- 1 * 5
        },
        Gold = {
            {name = "Sandy Bee", chance = 19},   -- 5 * 5
            {name = "Autumnal Bee", chance = 19},-- 5 * 5
            {name = "Petal Bee", chance = 19},   -- 5 * 5
            {name = "Camo Bee", chance = 19},    -- 5 * 5
            {name = "Galactic Bee", chance = 15},-- 2 * 5
            {name = "Industrial Bee", chance = 15}, -- 2 * 5
            {name = "Crystal Bee", chance = 15}, -- 1 * 5
            {name = "Pearlescent Bee", chance = 13}   -- 1 * 5
        },
        Platinum = {
            {name = "Hypnotic Bee", chance = 19},   -- 5 * 5
            {name = "Radiant Bee", chance = 19},-- 5 * 5
            {name = "Shadow Bee", chance = 19},   -- 5 * 5
            {name = "Techno Bee", chance = 19},    -- 5 * 5
            {name = "Prismatic Bee", chance = 15},-- 2 * 5
            {name = "Astral Bee", chance = 15}, -- 2 * 5
            {name = "Psychedelic Bee", chance = 15}, -- 1 * 5
            {name = "Rainbow Bee", chance = 13}   -- 1 * 5
        }
    }

    -- Get the bee set for the given setId
    local beeSet = chances[setId]
    if not beeSet then return nil end -- Return nil if the setId is invalid

    -- Generate a random number and determine the bee
    local totalChance = 0
    for _, bee in ipairs(beeSet) do
        totalChance = totalChance + bee.chance
    end

    local number = math.random(1, totalChance)
    local currentChance = 0

    for _, bee in ipairs(beeSet) do
        currentChance = currentChance + bee.chance
        if number <= currentChance then
            return bee.name
        end
    end
end
function CreateHatItem(Name, Id, Rarity, Cash, isGold, isSoldOut)
    local questItem = UIButton.new()
    questItem:AddToClassList("hat-item") -- Add a class to style the quest item.

    if isSoldOut then
        local soldOutLabel = UILabel.new()
        soldOutLabel:AddToClassList("hat-title")
        soldOutLabel:AddToClassList("text-center")
        soldOutLabel:SetPrelocalizedText("Sold Out")
        questItem:Add(soldOutLabel)

        local soldOutLabelDescription = UILabel.new()
        soldOutLabelDescription:AddToClassList("description")
        soldOutLabelDescription:AddToClassList("text-center")
        soldOutLabelDescription:SetPrelocalizedText("Check back again later")
        questItem:Add(soldOutLabelDescription)

        Orders_Root:Add(questItem)

        return questItem
    end

    -- Create a label for the quest item's title and add it to the quest item.
    local _titleLabel = UILabel.new()
    _titleLabel:AddToClassList("hat-title")
    _titleLabel:SetPrelocalizedText(Name) -- Set the text to display the quest item's name.
    questItem:Add(_titleLabel)

    local _priceContainer = VisualElement.new()
    _priceContainer:AddToClassList("priceContainerHat")

    if not isGold then
        local _icon = UIImage.new()
        _icon:AddToClassList("icon_honey")
        _priceContainer:Add(_icon)
    else
        local _icon = UIImage.new()
        _icon:AddToClassList("icon_gold")
        _priceContainer:Add(_icon)
    end

    local _image = UIImage.new()

    local container = VisualElement.new()
    container:AddToClassList("row-container")
    
    local _rarityLabel = UILabel.new()

    -- Create a label for the quest item's cash cost and add it to the quest item.
    local _cashLabel = UILabel.new()
    if Screen.width > Screen.height and Screen.height < 1000 then
        _cashLabel:AddToClassList("hat-price-small")
        _image:AddToClassList("hat-image-small")
        _rarityLabel:AddToClassList("rarity-label-small")
    else
        _cashLabel:AddToClassList("hat-price")
        _image:AddToClassList("hat-image")
        _rarityLabel:AddToClassList("rarity-label")
    end

    _image.image = Utils.HatImage[Name]
    questItem:Add(_image)

    _cashLabel:SetPrelocalizedText(tostring(Cash)) -- Set the text to display the cash cost.
    _priceContainer:Add(_cashLabel)
    container:Add(_priceContainer)

    local _rarityContainer = UIButton.new()
    _rarityContainer:AddToClassList(Rarity)

    _rarityLabel:SetPrelocalizedText(Rarity)
    _rarityContainer:Add(_rarityLabel)
    container:Add(_rarityContainer)

    questItem:Add(container)

    questItem:RegisterPressCallback(function()
        if not isGold then
            selectedIsGold = isGold
            selectedId = Id
            selectedCash = Cash
            selectedName = Name
            purchaseType = "hat"
            _confirmBuy.visible = true
        else
            BuyItem(isGold, Id, Name, Cash, "hat")
        end
    end)

    -- Add the quest item to the UI.
    Orders_Root:Add(questItem)

    return questItem
end


-- Creates a new quest item in the UI.
function CreateQuestItem(Name, Id, Cash, isGold, description, shouldConfirm, GoldPrice)
    -- Create a new button for the quest item.
    local questItem = UIButton.new()
    questItem:AddToClassList("order-item") -- Add a class to style the quest item.

    -- Create a label for the quest item's title and add it to the quest item.
    local _titleLabel = UILabel.new()
    _titleLabel:AddToClassList("title")
    _titleLabel:SetPrelocalizedText(Name) -- Set the text to display the quest item's name.
    questItem:Add(_titleLabel)
    if description~= nil then
        local _descLabel = UILabel.new()
        _descLabel:AddToClassList("description")
        _descLabel:SetPrelocalizedText(description)
        questItem:Add(_descLabel)
    end

    local _priceContainer = VisualElement.new()
    _priceContainer:AddToClassList("priceContainer")



    if isGold then
        local _icon = UIImage.new()
        _icon:AddToClassList("icon_gold")
        _priceContainer:Add(_icon)

        local _cashLabel = UILabel.new()
        _cashLabel:AddToClassList("title")
        _cashLabel:SetPrelocalizedText(tostring(Cash)) -- Set the text to display the cash cost.
        _priceContainer:Add(_cashLabel)
    elseif Cash then
        local _icon = UIImage.new()
        _icon:AddToClassList("icon_honey")
        _priceContainer:Add(_icon)

        local _cashLabel = UILabel.new()
        _cashLabel:AddToClassList("title")
        _cashLabel:SetPrelocalizedText(tostring(Cash)) -- Set the text to display the cash cost.
        _priceContainer:Add(_cashLabel)
    end

    if GoldPrice then

        local _cashLabel = UILabel.new()
        _cashLabel:AddToClassList("title")
        _cashLabel:SetPrelocalizedText("/ ") -- Set the text to display the cash cost.
        _priceContainer:Add(_cashLabel)

        local _icon = UIImage.new()
        _icon:AddToClassList("icon_gold")
        _priceContainer:Add(_icon)

        local _goldLabel = UILabel.new()
        _goldLabel:AddToClassList("title")
        _goldLabel:SetPrelocalizedText(tostring(GoldPrice)) -- Set the text to display the gold cost.
        _priceContainer:Add(_goldLabel)
    end

    questItem:Add(_priceContainer)

    questItem:RegisterPressCallback(function()
        if GoldPrice then
            _confirmGoldOrHoney.visible = true
            selectedHasGoldAndHoneyPrice = true
            selectedId = Id
            selectedCash = Cash
            purchaseType = "generic"
            return
        end

        if shouldConfirm then
            selectedIsGold = isGold
            selectedId = Id
            selectedCash = Cash
            purchaseType = "generic"
            _confirmBuy.visible = true
       else
            Buy(isGold, Id, Cash)
       end
    end, true, true, true)

    -- Add the quest item to the UI.
    Orders_Root:Add(questItem)

    return questItem
end

_buyWithGoldButton:RegisterPressCallback(function()
    Buy(true, selectedId, selectedCash)
    _confirmGoldOrHoney.visible = false end, true, true, true
)

_buyWithHoneyButton:RegisterPressCallback(function()
    Buy(false, selectedId, selectedCash)
    _confirmGoldOrHoney.visible = false end, true, true, true
)

_confirmBuyButton:RegisterPressCallback(function()
    if purchaseType == "hat" then
        BuyItem(selectedIsGold, selectedId, selectedName, selectedCash, "hat")
    elseif purchaseType == "generic" then
        Buy(selectedIsGold, selectedId, selectedCash)
    elseif purchaseType == "furniture" then
        BuyItem(selectedIsGold, selectedId, selectedName, selectedCash, "furntiure")
    end
    _confirmBuy.visible = false end, true, true, true
)

_declineBuyButton:RegisterPressCallback(function()
    _confirmBuy.visible = false end, true, true, true
)

function Init()
    closeLabel:SetPrelocalizedText("Close", true)
    timeToReset:AddToClassList("time-to-reset")
    ButtonPressed("bees")
    Timer.new(1, function() timeToReset:SetPrelocalizedText("Time until shop resets: " .. timeUntilNextSeed()) end, true)
    _confirmBuyDescription:SetPrelocalizedText("Are you sure you want to buy this?")
    _confirmBuyLabel:SetPrelocalizedText("Buy")
    _declineBuyLabel:SetPrelocalizedText("Don't Buy")

    _confirmBuy.visible = false
    _confirmGoldOrHoney.visible = false

    _confirmGoldOrHoneyDescription:SetPrelocalizedText("Purchase with gold or honey?")
    _buyWithHoneyLabel:SetPrelocalizedText("Honey")
    _buyWithGoldLabel:SetPrelocalizedText("Gold")

	purchaseHandler.beeCapacityPurchaseSuccessful:Connect(function() IncreaseBeeCapacity() audioManager.PlaySound("purchaseSound", 1) end)
    purchaseHandler.apiarySizePurchaseSuccessful:Connect(function(product_id) IncreaseApiarySize(product_id) end)

    if Screen.width > Screen.height then
        honeyLabel:SetPrelocalizedText("Honey / Items")
    else
        honeyLabel:SetPrelocalizedText("Items")
    end

    upgradesLabel:SetPrelocalizedText("Upgrades")

    closeButton:RegisterPressCallback(function()
        UIManager.CloseShop()
    end, true, true, true)
end

function Buy(isGold, Id, Cash)
     -- Handle gold payments
     if isGold then
        purchaseHandler.PromptTokenPurchase(Id)
        return
    end

    -- Check bee capacity
    if((Id == "Bronze" or Id == "Silver" or Id == "Gold" or Id == "Platinum") and playerManager.clientBeeCount >= playerManager.GetPlayerBeeCapacity()) then
        UIManager.ToggleUI("PlaceStatus", true)
        statusObject:GetComponent("PlaceApiaryStatus").SetStatus("You already have the maximum number of bees.")
        audioManager.PlaySound("failSound", .75)
        Timer.new(3.5, function() UIManager.ToggleUI("PlaceStatus", false) end, false)
        return
    end

    if playerManager.GetPlayerCash() >= Cash then
          
        print("Purchased " .. Id)

        playerManager.IncrementStat("Cash", -Cash) -- Deduct cash from the player.
        audioManager.PlaySound("purchaseSound", 1)

        -- Give player a net if that's what they bought
        if Id == "Net" then
            playerManager.IncrementStat("Nets", 1)
            return
        elseif Id == "BeeCapacity" or Id=="bee_size_1" or Id == "bee_size_2" then
            
            if playerManager.GetPlayerBeeCapacity() == 20 then
                return
            end
            IncreaseBeeCapacity()
            return
        elseif Id == "FlowerCapacity" then
            InitUpgradesTab(playerManager.GetPlayerBeeCapacity(), playerManager.GetPlayerFlowerCapacity()+1, playerManager.GetPlayerSweetScentLevel(), playerManager.GetPlayerApiarySize())
            playerManager.IncrementStat("FlowerCapacity", 1)
            return
        elseif Id == "SweetScentLevel" then
            if playerManager.GetPlayerSweetScentLevel() == 3 then
                return
            end

            InitUpgradesTab(playerManager.GetPlayerBeeCapacity(), playerManager.GetPlayerFlowerCapacity(), playerManager.GetPlayerSweetScentLevel()+1, playerManager.GetPlayerApiarySize())
            playerManager.IncrementStat("SweetScentLevel", 1)
            return
        elseif Id == "Shears" then
            playerManager.GiveShears()
            UIManager.OpenShearsTutorial()
            return
        elseif Id == "apiary_size_1" or Id == "apiary_size_2" then
            IncreaseApiarySize(Id)
            return
        end
        
        local bee = GenerateBee(Id)
        playerManager.notifyBeePurchased:Fire(bee)
        playerManager.GiveBee(bee, false)
    else
        UIManager.ToggleUI("PlaceStatus", true)
        statusObject:GetComponent("PlaceApiaryStatus").SetStatus("You don't have enough honey.")
        audioManager.PlaySound("failSound", .75)
        Timer.new(3.5, function() UIManager.ToggleUI("PlaceStatus", false) end, false)
    end
end

function IncreaseBeeCapacity()
	InitUpgradesTab(playerManager.GetPlayerBeeCapacity()+1, playerManager.GetPlayerFlowerCapacity(), playerManager.GetPlayerSweetScentLevel(), playerManager.GetPlayerApiarySize())
	playerManager.IncrementStat("BeeCapacity", 1)
end

function IncreaseApiarySize(product_id)
    print("Apiary size with product id: " .. product_id .. " purchased, increasing size")
    if (playerManager.GetPlayerApiarySize() == 0 and product_id == "apiary_size_1") or (playerManager.GetPlayerApiarySize() == 1 and product_id == "apiary_size_2") then
        audioManager.PlaySound("purchaseSound", 1)
        InitUpgradesTab(playerManager.GetPlayerBeeCapacity(), playerManager.GetPlayerFlowerCapacity(), playerManager.GetPlayerSweetScentLevel(), playerManager.GetPlayerApiarySize()+1)
        playerManager.IncrementStat("ApiarySize", 1)
        apiaryManager.ResetApiary()
        return
    end
end

function BuyItem(isGold, Id, Name, Cash, itemType)
    -- Handle gold payments
    if isGold then
        purchaseHandler.PromptTokenPurchase(Id)
        return
    end

    if playerManager.GetPlayerCash() >= Cash then
        playerManager.IncrementStat("Cash", -Cash) -- Deduct cash from the player.
        playerManager.GiveItem(Id)
        playerManager.notifyItemPurchased:Fire(Name or Id)

        if math.random() <= 0.5 then
            local expirationTime = os.time() + 30 * 60
            if itemType == "hat" then
                soldOutHats[Id] = expirationTime
                InitCosmeticsTab()
            elseif itemType == "furniture" then
                soldOutFurniture[Id] = expirationTime
                InitFurnitureTab()
            end
        end
    else
        UIManager.ToggleUI("PlaceStatus", true)
        statusObject:GetComponent("PlaceApiaryStatus").SetStatus("You do not have enough honey.")
        audioManager.PlaySound("failSound", .75)
        Timer.new(2, function() UIManager.ToggleUI("PlaceStatus", false) end, false)
    end
end
