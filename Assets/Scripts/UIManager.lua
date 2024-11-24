--!Type(Module)

-- Serialized fields for UI components
--!SerializeField
local BeeListObject : GameObject = nil
--!SerializeField
local InfoCardObject : GameObject = nil
--!SerializeField
local PlaceApiaryObject : GameObject = nil
--!SerializeField
local CreateOrderGuiObject : GameObject = nil
--!SerializeField
local BeestiaryObject : GameObject = nil
--!SerializeField
local TutorialObject : GameObject = nil
--!SerializeField
local ShearsTutorialObject : GameObject = nil
--!SerializeField
local StatsObject : GameObject = nil
--!SerializeField
local StatusObject : GameObject = nil
--!SerializeField
local PlaceFlowerMenuObject : GameObject = nil
--!SerializeField
local AddHatMenuObject : GameObject = nil

local wildBeeManager = require("WildBeeManager")
local playerManager = require("PlayerManager")
local audioManager = require("AudioManager")

local uiMap = {
    BeeList = BeeListObject,
    BeeCard = InfoCardObject,
    PlaceButtons = PlaceApiaryObject,
    ShopUi = CreateOrderGuiObject,
    Beestiary = BeestiaryObject,
    Tutorial = TutorialObject,
    PlayerStats = StatsObject,
    PlaceStatus = StatusObject,
    ShearsTutorial = ShearsTutorialObject,
    PlaceFlowerMenu = PlaceFlowerMenuObject,
    AddHatMenu = AddHatMenuObject
}

  -- Activate the object if it is not active
  function ActivateObject(object)
    if not object.activeSelf then
      object:SetActive(true)
      --print("UI activated")
    end
  end
  
  -- Deactivate the object if it is active
  function DeactivateObject(object)
    if object.activeSelf then
      object:SetActive(false)
      --print("UI deactivated")
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

function IsActive(ui : string)
    return uiMap[ui].activeSelf
end

--- Toggles the visibility of a specific UI component
function ToggleUI(ui: string, visible: boolean)
    local uiComponent = uiMap[ui]
    if not uiComponent then
        --print("[ToggleUI] UI component not found: " .. ui)
        return
    end

    if visible then
       --print("[ToggleUI] UI component activated " .. ui)
       ActivateObject(uiComponent)
    else
        --print("[ToggleUI] UI component deactivated " .. ui)
       DeactivateObject(uiComponent)
    end
end

function OpenBeeList()
    ToggleUI("BeeList", true)
    ToggleUI("Beestiary", false)
    ToggleUI("BeeCard", false)
    ToggleUI("ShopUi", false)
    ToggleUI("PlaceButtons", false)
    ToggleUI("PlayerStats", false)
    BeeListObject:GetComponent(BeeListMenu).Init()
end

function CloseBeeList()
    if not IsActive("BeeList") then
        return
    end
    ToggleUI("BeeList", false)
    ToggleUI("PlaceButtons", true)
    ShowMenu()
end

function OpenShop()
    ToggleUI("BeeList", false)
    ToggleUI("Beestiary", false)
    ToggleUI("BeeCard", false)
    ToggleUI("ShopUi", true)
    HideButtons()
    ToggleUI("PlaceButtons", false)
    --ToggleUI("PlayerStats", false)
    CreateOrderGuiObject:GetComponent(CreateOrderGui).Init()
end

function OpenBeestiary()
    ToggleUI("BeeList", false)
    ToggleUI("BeeCard", false)
    ToggleUI("Beestiary", true)
    ToggleUI("ShopUi", false)
    ToggleUI("PlaceButtons", false)
    ToggleUI("PlayerStats", false)
    BeestiaryObject:GetComponent(Beestiary).Init()
end

function HideButtons()
    StatsObject:GetComponent(PlayerStatGui).HideButtons()
end

function ShowButtons()
    StatsObject:GetComponent(PlayerStatGui).ShowButtons()
end

function CloseBeestiary()
    if not IsActive("Beestiary") then
        return
    end
    ToggleUI("Beestiary", false)
    ShowMenu()
    ToggleUI("PlaceButtons", true)
end

function CloseShop()
    if not IsActive("ShopUi") then
        return
    end
    ShowButtons()
    ShowMenu()
    ToggleUI("ShopUi", false)
    --ToggleUI("PlayerStats", true)
    ToggleUI("PlaceButtons", true)
end

function HideTutorial()
    if not IsActive("Tutorial") then
        return
    end
    ShowMenu()
    ToggleUI("Tutorial", false)
    ToggleUI("PlaceButtons", true)
end

function OpenTutorial(playerInited)
    ToggleUI("PlaceFlowerMenu", false)
    ToggleUI("AddHatMenu", false)
    ToggleUI("BeeList", false)
    ToggleUI("ShearsTutorial", false)
    ToggleUI("BeeCard", false)
    ToggleUI("ShopUi", false)
    ToggleUI("Beestiary", false)
    ToggleUI("Tutorial", true)
    ToggleUI("PlaceButtons", false)
    ToggleUI("PlayerStats", false)
    ToggleUI("PlaceStatus", false)
    TutorialObject:GetComponent(Tutorial).Init(playerInited)
end

function OpenShearsTutorial()
    ToggleUI("ShopUi", false)
    ToggleUI("PlayerStats", false)
    ToggleUI("ShearsTutorial", true)
    ShearsTutorialObject:GetComponent(ShearsTutorial).Init()
end

function CloseShearsTutorial()
    ToggleUI("ShopUi", true)
    ToggleUI("PlayerStats", true)
    ToggleUI("ShearsTutorial", false)
    CreateOrderGuiObject:GetComponent(CreateOrderGui).Init()
end

function OpenPlaceFlowerMenu()
    ToggleUI("PlaceFlowerMenu", true)
    ToggleUI("PlayerStats", false)
    ToggleUI("PlaceButtons", false)
    PlaceFlowerMenuObject:GetComponent(PlaceFlowerUi).Init()
end

function ClosePlaceFlowerMenu()
    ToggleUI("PlaceFlowerMenu", false)
    ToggleUI("PlayerStats", true)
    ToggleUI("PlaceButtons", true)
end


function OpenAddHatMenu()
    ToggleUI("AddHatMenu", true)
    ToggleUI("BeeList", false)
    ToggleUI("PlayerStats", false)
    ToggleUI("PlaceButtons", false)
    AddHatMenuObject:GetComponent(AddHatUi).Init()
end

function CloseAddHatMenu()
    ToggleUI("AddHatMenu", false)
    ToggleUI("PlayerStats", true)
    ToggleUI("PlaceButtons", true)
end

wildBeeManager.notifyCaptureSucceeded:Connect((function(species)
    ToggleUI("BeeCard", true)
    ToggleUI("PlaceButtons", false)
    ToggleUI("PlayerStats", false)
    InfoCardObject:GetComponent(InfoCard).ShowCaughtWild(species)
    audioManager.PlaySound("captureSound", 1)
    Timer.new(3.5, function() ToggleUI("BeeCard", false) ToggleUI("PlaceButtons", true) ToggleUI("PlayerStats", true) end, false)
end))

playerManager.notifyBeePurchased:Connect((function(species)
    ToggleUI("BeeCard", true)
    ToggleUI("PlayerStats", false)
    ToggleUI("ShopUi", false)
    InfoCardObject:GetComponent(InfoCard).ShowRecieved(species)
    Timer.new(3.5, function() ToggleUI("BeeCard", false) ToggleUI("ShopUi", true) HideButtons() ToggleUI("PlayerStats", true) end, false)
end))

playerManager.notifyHatPurchased:Connect((function(hat)
    audioManager.PlaySound("purchaseSound", 1)
    ToggleUI("BeeCard", true)
    ToggleUI("PlayerStats", false)
    ToggleUI("ShopUi", false)
    InfoCardObject:GetComponent(InfoCard).ShowHat(hat)
    Timer.new(3.5, function() ToggleUI("BeeCard", false) ToggleUI("ShopUi", true) HideButtons() ToggleUI("PlayerStats", true) end, false)
end))


function self:ClientAwake()
    Timer.new(0.5, function() 
        OpenTutorial(false)
    end, false)
end

function ShowMenu()
    ToggleUI("PlayerStats", true)
    StatsObject:GetComponent("PlayerStatGui").ShowMenu()
end