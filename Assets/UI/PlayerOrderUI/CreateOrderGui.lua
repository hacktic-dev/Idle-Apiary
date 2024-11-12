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

local state = 0 -- Which tab are we on?

_upgradesTab:RegisterPressCallback(function()
    local success = ButtonPressed("upgrades")
  end, true, true, true)
  
_beesTab:RegisterPressCallback(function()
local success = ButtonPressed("bees")
end, true, true, true)

_cosmeticsTab:RegisterPressCallback(function()
local success = ButtonPressed("cosmetics")
end, true, true, true)

local function InitUpgradesTab()
    Orders_Root:Clear()
    CreateQuestItem("Bee Net", "Net", 100)
end

local function InitBeesTab()
    Orders_Root:Clear()
    CreateQuestItem("Random Bee from the Bronze Set", "Bronze", 50)
    CreateQuestItem("Random Bee from the Silver Set", "Silver", 250)
    CreateQuestItem("Random Bee from the Gold Set", "Gold", 1250)
end

function ButtonPressed(btn: string)
    if btn == "upgrades" then
      if state == 0 then return end -- Already in Poles
      state = 0
      _upgradesTab:AddToClassList("nav-button--selected")
      _upgradesTab:RemoveFromClassList("nav-button--deselected")
      _beesTab:AddToClassList("nav-button--deselected")
      _cosmeticsTab:AddToClassList("nav-button--deselected")
      InitUpgradesTab()
      --audioManager.PlaySound("paperSound1", 1)
      return true
    elseif btn == "bees" then
      if state == 1 then return end -- Already in Bait
      state = 1
      _beesTab:AddToClassList("nav-button--selected")
      _beesTab:RemoveFromClassList("nav-button--deselected")
      _upgradesTab:AddToClassList("nav-button--deselected")
      _cosmeticsTab:AddToClassList("nav-button--deselected")
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


-- Creates a new quest item in the UI.
function CreateQuestItem(Name, Id, Cash)
    -- Create a new button for the quest item.
    local questItem = UIButton.new()
    questItem:AddToClassList("order-item") -- Add a class to style the quest item.

    -- Create a label for the quest item's title and add it to the quest item.
    local _titleLabel = UILabel.new()
    _titleLabel:AddToClassList("title")
    _titleLabel:SetPrelocalizedText(Name.. " -") -- Set the text to display the quest item's name.
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

        if(Id ~= "Net" and playerManager.clientBeeCount > 11) then
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
    InitUpgradesTab()
    -- Add a callback to the close button to hide the UI when pressed.
    closeButton:RegisterPressCallback(function()
        UIManager.CloseShop()
    end, true, true, true)
end