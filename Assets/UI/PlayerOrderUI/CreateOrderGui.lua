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
local _cosmeticsTab : UIButton = nil

--!SerializeField
local statusObject : GameObject = nil

--!SerializeField
local BeeListObject : GameObject = nil

local orderManager = require("OrderManager")
local playerManager = require("PlayerManager")
local UIManager = require("UIManager") 
local audioManager = require("AudioManager")
local purchaseHandler = require("PurchaseHandler")

local state = 0 -- Which tab are we on?

_upgradesTab:RegisterPressCallback(function()
    local success = ButtonPressed("upgrades")
  end, true, true, true)
  
_beesTab:RegisterPressCallback(function()
local success = ButtonPressed("bees")
end, true, true, true)

local function InitUpgradesTab()
    Orders_Root:Clear()
    CreateQuestItem("Bee Net", "Net", 120, false)
    CreateQuestItem("Random Bee from the Bronze Set", "Bronze", 50, false)
    CreateQuestItem("Random Bee from the Silver Set", "Silver", 250, false)
    CreateQuestItem("Random Bee from the Gold Set", "Gold", 1250, false)
end

local function InitBeesTab()
    Orders_Root:Clear()
    CreateQuestItem("Purchase Honey Doubler", "doubler_1", 250, true, "Doubles honey rate for the next 5 minutes.")
    CreateQuestItem("Purchase Honey Doubler Pro", "doubler_2", 500, true, "Doubles honey rate for the next 15 minutes")
end

function ButtonPressed(btn: string)
    if btn == "upgrades" then
      if state == 0 then return end -- Already in Poles
      state = 0
      _upgradesTab:AddToClassList("nav-button--selected")
      _upgradesTab:RemoveFromClassList("nav-button--deselected")
      _beesTab:AddToClassList("nav-button--deselected")
      --_cosmeticsTab:AddToClassList("nav-button--deselected")
      InitUpgradesTab()
      --audioManager.PlaySound("paperSound1", 1)
      return true
    elseif btn == "bees" then
      if state == 1 then return end -- Already in Bait
      state = 1
      _beesTab:AddToClassList("nav-button--selected")
      _beesTab:RemoveFromClassList("nav-button--deselected")
      _upgradesTab:AddToClassList("nav-button--deselected")
     -- _cosmeticsTab:AddToClassList("nav-button--deselected")
      InitBeesTab()
      --audioManager.PlaySound("paperSound1", 1)
      return true
    elseif btn == "cosmetics" then
      state = 2
      _cosmeticsTab:AddToClassList("nav-button--selected")
      _cosmeticsTab:RemoveFromClassList("nav-button--deselected")
      _beesTab:AddToClassList("nav-button--deselected")
      _upgradesTab:AddToClassList("nav-button--deselected")
      --PopulateShop(Deals)
      --audioManager.PlaySound("paperSound1", 1)
      return true
    end
  end
  

  function GenerateBee(setId)
    -- Define the chances for each bee in different sets
    local chances = {
        Bronze = {
            {name = "Common Bee", chance = 20},  -- 5 * 5
            {name = "Stone Bee", chance = 20},   -- 5 * 5
            {name = "Forest Bee", chance = 20},  -- 5 * 5
            {name = "Aquatic Bee", chance = 15}, -- 2 * 5
            {name = "Giant Bee", chance = 15},   -- 2 * 5
            {name = "Silver Bee", chance = 10}    -- 1 * 5
        },
        Silver = {
            {name = "Muddy Bee", chance = 20},   -- 5 * 5
            {name = "Frigid Bee", chance = 20},  -- 5 * 5
            {name = "Steel Bee", chance = 20},   -- 5 * 5
            {name = "Magma Bee", chance = 15},   -- 2 * 5
            {name = "Ghostly Bee", chance = 15}, -- 2 * 5
            {name = "Iridescent Bee", chance = 10} -- 1 * 5
        },
        Gold = {
            {name = "Sandy Bee", chance = 20},   -- 5 * 5
            {name = "Autumnal Bee", chance = 20},-- 5 * 5
            {name = "Petal Bee", chance = 20},   -- 5 * 5
            {name = "Galactic Bee", chance = 15},-- 2 * 5
            {name = "Radiant Bee", chance = 15}, -- 2 * 5
            {name = "Rainbow Bee", chance = 10}   -- 1 * 5
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

            if playerManager.PlayerHasActiveHoneyDoubler(player) then
                statusObject:GetComponent("PlaceApiaryStatus").SetStatus("You already have an active honey doubler! Wait for it to run out before purchasing again.")
                UIManager.ToggleUI("PlaceStatus", true)
                Timer.new(3.5, function() UIManager.ToggleUI("PlaceStatus", false) end, false)
            end

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

-- Called when the UI object this script is attached to is initialized.
function Init()
    closeLabel:SetPrelocalizedText("Close", true) -- Set the text of the close button.
    ButtonPressed("upgrades")
    InitUpgradesTab()
    -- Add a callback to the close button to hide the UI when pressed.
    closeButton:RegisterPressCallback(function()
        UIManager.CloseShop()
    end, true, true, true)
end