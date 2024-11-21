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
local upgrades : UILabel = nil
--!Bind
local timeToReset : UILabel = nil
--!Bind
local timeContainer : UIButton = nil

--!SerializeField
local statusObject : GameObject = nil

--!SerializeField
local BeeListObject : GameObject = nil

local orderManager = require("OrderManager")
local playerManager = require("PlayerManager")
local UIManager = require("UIManager") 
local audioManager = require("AudioManager")
local purchaseHandler = require("PurchaseHandler")
local Utils = require("Utils")

local state = 0 -- Which tab are we on?

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

function InitUpgradesTab(beeCapacity, flowerCapacity, sweetScentLevel)
    Orders_Root:Clear()

    if sweetScentLevel == 0 then
        netPrice = 120
    elseif sweetScentLevel == 1 then
        netPrice = 300
    elseif sweetScentLevel == 2 then
        netPrice = 500
    end

    CreateQuestItem("Purchase a Bee Net", "Net", netPrice, false)

    if beeCapacity < 20 then
        CreateQuestItem("Upgrade Bee Capacity to " .. beeCapacity+1 .. " Bees", "BeeCapacity", LookupBeeCapacityUpgradePrice(beeCapacity + 1), false)
    end

    if sweetScentLevel < 2 then
        CreateQuestItem("Sweet Scent Upgrade #" .. sweetScentLevel+1, "SweetScentLevel", LookupSweetScentLevelPrice(sweetScentLevel + 1), false, "Rarer bees spawn more frequently")
    end

    if playerManager.players[client.localPlayer].HasShears.value == false then
        CreateQuestItem("Purchase Shears", "Shears", 5000, false, "Can be used to pick flowers")
    else
       if flowerCapacity < 10 then
        CreateQuestItem("Upgrade Flower Capacity to " .. flowerCapacity+1 .. " Flowers", "FlowerCapacity", LookupFlowerCapacityUpgradePrice(flowerCapacity + 1), false)
       end
    end
end

local function InitBeesTab()
    Orders_Root:Clear()
    CreateQuestItem("Purchase a Random Bee", "Bronze", 50, false, "Bronze Set")
    CreateQuestItem("Purchase a Random Bee", "Silver", 250, false, "Silver Set")
    CreateQuestItem("Purchase a Random Beet", "Gold", 1250, false, "Gold Set")
end

local function InitHoneyTab()
    Orders_Root:Clear()
    CreateQuestItem("Purchase 250 Honey", "honey_1", 100, true)
    CreateQuestItem("Purchase 1000 Honey", "honey_2", 200, true)
    CreateQuestItem("Purchase 3000 Honey", "honey_3", 500, true)
end

local function getSeed()
    local now = os.time() -- Get the current time
    local four_hours = 14400 -- 4 hours in seconds
    return math.floor(now / four_hours) -- Determine the current 4-hour block
end

local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Function to calculate the time until the next seed change
local function timeUntilNextSeed()
    local now = os.time() -- Get the current time
    local four_hours = 14400 -- 4 hours in seconds
    local next_seed_time = (math.floor(now / four_hours) + 1) * four_hours

    --TODO reset shop when timeout
    if next_seed_time - now == 14400 and state == 3 then
        InitCosmeticsTab()
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
            CreateHatItem(hat.name, hat.id, hat.rarity, hat.goldCost, true)
            i = i + 1
        end
    end

    i = 0
    -- Second loop for regular hats
    while i < 4 do
        local hat = Utils.ChooseHat(false)
        if hat and hats[hat.name] == nil then
            hats[hat.name] = hat
            CreateHatItem(hat.name, hat.id, hat.rarity, hat.cost, false)
            i = i + 1
        end
    end
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
      Orders_Root:RemoveFromClassList("high-margin")
      timeContainer.visible = false
      InitUpgradesTab(playerManager.GetPlayerBeeCapacity(), playerManager.GetPlayerFlowerCapacity(), playerManager.GetPlayerSweetScentLevel())
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
        Orders_Root:RemoveFromClassList("high-margin")
        timeContainer.visible = false
        InitHoneyTab()
    elseif btn == "cosmetics" then
    if state == 3 then return end
      state = 3
      _cosmeticsTab:AddToClassList("nav-button--selected")
      _cosmeticsTab:RemoveFromClassList("nav-button--deselected")
      _beesTab:AddToClassList("nav-button--deselected")
      _upgradesTab:AddToClassList("nav-button--deselected")
      _honeyTab:AddToClassList("nav-button--deselected")
      timeContainer.visible = true
      Orders_Root:AddToClassList("high-margin")
      timeToReset:SetPrelocalizedText("Time until shop resets: " .. timeUntilNextSeed())
      InitCosmeticsTab()
      return true
    end
end
  
function LookupSweetScentLevelPrice(level)
    if level == 1 then
        return 500
    elseif level == 2 then
        return 2000
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
    if capacity == 11 then
        return 200
    elseif capacity == 12 then
        return 500
    elseif capacity == 13 then
        return 1000
    elseif capacity == 14 then
        return 2000
    elseif capacity == 15 then
        return 5000
    elseif capacity == 16 then
        return 8000
    elseif capacity == 17 then
        return 10000
    elseif capacity == 18 then
        return 15000
    elseif capacity == 19 then
        return 25000
    elseif capacity == 20 then
        return 50000
    end
end

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
            return "Iridescent Bee"
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

function CreateHatItem(Name, Id, Rarity, Cash, isGold)
    local questItem = UIButton.new()
    questItem:AddToClassList("hat-item") -- Add a class to style the quest item.

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
        -- Handle gold payments
        if isGold then
            purchaseHandler.PromptTokenPurchase(Id)
            return
        end

        if playerManager.GetPlayerCash() >= Cash then
              
            playerManager.IncrementStat("Cash", -Cash) -- Deduct cash from the player.
            playerManager.GiveHat(Id)
            playerManager.notifyHatPurchased:Fire(Name)
        else
            UIManager.ToggleUI("PlaceStatus", true)
            statusObject:GetComponent("PlaceApiaryStatus").SetStatus("You do not have enough honey.")
            Timer.new(2, function() UIManager.ToggleUI("PlaceStatus", false) end, false)
        end
    end)

    -- Add the quest item to the UI.
    Orders_Root:Add(questItem)

    return questItem
end

-- Creates a new quest item in the UI.
function CreateQuestItem(Name, Id, Cash, isGold, description)
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

    -- Create a label for the quest item's XP reward and add it to the quest item.
    -- local _xpLabel = UILabel.new()
    -- _xpLabel:AddToClassList("title")
    -- _xpLabel:SetPrelocalizedText(tostring(XP).."xp") -- Set the text to display the XP reward.
   --  questItem:Add(_xpLabel)
    local _priceContainer = VisualElement.new()
    _priceContainer:AddToClassList("priceContainer")

    if not isGold then
        local _icon = UIImage.new()
        _icon:AddToClassList("icon_honey")
        _priceContainer:Add(_icon)
    else
        local _icon = UIImage.new()
        _icon:AddToClassList("icon_gold")
        _priceContainer:Add(_icon)
    end

    -- Create a label for the quest item's cash cost and add it to the quest item.
    local _cashLabel = UILabel.new()
    _cashLabel:AddToClassList("title")
    _cashLabel:SetPrelocalizedText(tostring(Cash)) -- Set the text to display the cash cost.
    _priceContainer:Add(_cashLabel)
    questItem:Add(_priceContainer)

    questItem:RegisterPressCallback(function()
        -- Handle gold payments
        if isGold then
            purchaseHandler.PromptTokenPurchase(Id)
            return
        end

        -- Check bee capacity
        if((Id == "Bronze" or Id == "Silver" or Id == "Gold") and playerManager.clientBeeCount == playerManager.GetPlayerBeeCapacity()) then
            UIManager.ToggleUI("PlaceStatus", true)
            statusObject:GetComponent("PlaceApiaryStatus").SetStatus("You already have the maximum number of bees.")
            Timer.new(3.5, function() UIManager.ToggleUI("PlaceStatus", false) end, false)
            return
        end

        if playerManager.GetPlayerCash() >= Cash then
              
            playerManager.IncrementStat("Cash", -Cash) -- Deduct cash from the player.
            audioManager.PlaySound("purchaseSound", 1)

            -- Give player a net if that's what they bought
            if Id == "Net" then
                playerManager.IncrementStat("Nets", 1)
                return
            elseif Id == "BeeCapacity" then
                InitUpgradesTab(playerManager.GetPlayerBeeCapacity() + 1, playerManager.GetPlayerFlowerCapacity(), playerManager.GetPlayerSweetScentLevel())
                playerManager.IncrementStat("BeeCapacity", 1)
                return
            elseif Id == "FlowerCapacity" then
                InitUpgradesTab(playerManager.GetPlayerBeeCapacity(), playerManager.GetPlayerFlowerCapacity() + 1, playerManager.GetPlayerSweetScentLevel())
                playerManager.IncrementStat("FlowerCapacity", 1)
                return
            elseif Id == "SweetScentLevel" then
                InitUpgradesTab(playerManager.GetPlayerBeeCapacity(), playerManager.GetPlayerFlowerCapacity(), playerManager.GetPlayerSweetScentLevel() + 1)
                playerManager.IncrementStat("SweetScentLevel", 1)
                return
            elseif Id == "Shears" then
                playerManager.GiveShears()
                UIManager.OpenShearsTutorial()
                return
            end
            
            local bee = GenerateBee(Id)
            playerManager.notifyBeePurchased:Fire(bee)
            playerManager.GiveBee(bee, false)
        else
            UIManager.ToggleUI("PlaceStatus", true)
            statusObject:GetComponent("PlaceApiaryStatus").SetStatus("You don't have enough honey.")
            Timer.new(3.5, function() UIManager.ToggleUI("PlaceStatus", false) end, false)
        end
    end, true, true, true)

    -- Add the quest item to the UI.
    Orders_Root:Add(questItem)

    return questItem
end

function Init()
    closeLabel:SetPrelocalizedText("Close", true)
    timeToReset:AddToClassList("time-to-reset")
    ButtonPressed("bees")
    Timer.new(1, function() timeToReset:SetPrelocalizedText("Time until shop resets: " .. timeUntilNextSeed()) end, true)
    if Screen.width > Screen.height then
        upgrades:SetPrelocalizedText("Upgrades / Items")
    else
        upgrades:SetPrelocalizedText("Items")
    end
    closeButton:RegisterPressCallback(function()
        UIManager.CloseShop()
    end, true, true, true)
end