--!Type(Module)

-- Serialized fields for UI components
--!SerializeField
local BeeListObject : GameObject = nil
--!SerializeField
local BeeObtainCardObject : GameObject = nil
--!SerializeField
local PlaceApiaryObject : GameObject = nil
--!SerializeField
local CreateOrderGuiObject : GameObject = nil
--!SerializeField
local BeestiaryObject : GameObject = nil
--!SerializeField
local TutorialObject : GameObject = nil
--!SerializeField
local StatsObject : GameObject = nil

local wildBeeManager = require("WildBeeManager")
local playerManager = require("PlayerManager")
local audioManager = require("AudioManager")

local uiMap = {
    BeeList = BeeListObject,
    BeeCard = BeeObtainCardObject,
    PlaceButtons = PlaceApiaryObject,
    ShopUi = CreateOrderGuiObject,
    Beestiary = BeestiaryObject,
    Tutorial = TutorialObject,
    PlayerStats = StatsObject
}

  -- Activate the object if it is not active
  function ActivateObject(object)
    if not object.activeSelf then
      object:SetActive(true)
      print("UI activated")
    end
  end
  
  -- Deactivate the object if it is active
  function DeactivateObject(object)
    if object.activeSelf then
      object:SetActive(false)
      print("UI deactivated")
    end
  end

  --- Toggles visibility for all UI components, with an optional exclusion list
function ToggleAll(visible: boolean, except)
    for ui, component in pairs(uiMap) do
        if not (except and except[ui]) then
            if visible then
                ActivateObject(component)
            else
                DeactivateObject(component)
            end
        end
    end
end

--- Toggles the visibility of a specific UI component
function ToggleUI(ui: string, visible: boolean)
    local uiComponent = uiMap[ui]
    if not uiComponent then
        print("[ToggleUI] UI component not found: " .. ui)
        return
    end

    if visible then
       ActivateObject(uiComponent)
    else
       DeactivateObject(uiComponent)
    end
end

function OpenBeeList()
    ToggleUI("BeeList", true)
    ToggleUI("Beestiary", false)
    ToggleUI("BeeCard", false)
    ToggleUI("ShopUi", false)
    ToggleUI("PlaceButtons", false)
    BeeListObject:GetComponent(BeeListMenu).Init()
end

function CloseBeeList()
    ToggleUI("BeeList", false)
    ToggleUI("PlaceButtons", true)
end

function OpenShop()
    ToggleUI("BeeList", false)
    ToggleUI("Beestiary", false)
    ToggleUI("BeeCard", false)
    ToggleUI("ShopUi", true)
    ToggleUI("PlaceButtons", false)
    CreateOrderGuiObject:GetComponent(CreateOrderGui).Init()
end

function OpenBeestiary()
    ToggleUI("BeeList", false)
    ToggleUI("BeeCard", false)
    ToggleUI("Beestiary", true)
    ToggleUI("ShopUi", false)
    ToggleUI("PlaceButtons", false)
    BeestiaryObject:GetComponent(Beestiary).Init()
end

function CloseBeestiary()
    ToggleUI("Beestiary", false)
    ToggleUI("PlaceButtons", true)
end

function CloseShop()
    ToggleUI("ShopUi", false)
    ToggleUI("PlaceButtons", true)
end

function HideTutorial()
    ToggleUI("PlayerStats", true)
    ToggleUI("Tutorial", false)
    ToggleUI("PlaceButtons", true)
end

wildBeeManager.notifyCaptureSucceeded:Connect((function(species)
    ToggleUI("BeeCard", true)
    ToggleUI("PlaceButtons", false)
    BeeObtainCardObject:GetComponent(BeeObtainCard).ShowCaughtWild(species)
    audioManager.PlaySound("captureSound", 1)
    Timer.new(3.5, function() ToggleUI("BeeCard", false) ToggleUI("PlaceButtons", true) end, false)
end))

playerManager.notifyBeePurchased:Connect((function(species)
    ToggleUI("BeeCard", true)
    ToggleUI("ShopUi", false)
    BeeObtainCardObject:GetComponent(BeeObtainCard).ShowRecieved(species)
    Timer.new(3.5, function() ToggleUI("BeeCard", false) ToggleUI("Shop", true) ToggleUI("PlaceButtons", true) end, false)
end))

function self:ClientAwake()
    Timer.new(.1, function() 
        ToggleUI("BeeList", false)
        ToggleUI("BeeCard", false)
        ToggleUI("ShopUi", false)
        ToggleUI("Beestiary", false)
        ToggleUI("Tutorial", true)
        ToggleUI("PlaceButtons", false)
        ToggleUI("PlayerStats", false)
        TutorialObject:GetComponent(Tutorial).Init()
    end, false)
end