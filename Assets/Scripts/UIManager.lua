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
--!SerializeField
local CenterPlayerButtonObject : GameObject = nil
--!SerializeField
local LeaderboardObject : GameObject = nil

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
    AddHatMenu = AddHatMenuObject,
    CenterPlayerButton = CenterPlayerButtonObject,
    Leaderboard = LeaderboardObject
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
    ToggleUI("CenterPlayerButton", false)
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
    ToggleUI("CenterPlayerButton", false)
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
    ToggleUI("CenterPlayerButton", false)
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
    ToggleUI("CenterPlayerButton", true)
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

function HideAll()
    ToggleUI("PlaceFlowerMenu", false)
    ToggleUI("AddHatMenu", false)
    ToggleUI("BeeList", false)
    ToggleUI("ShearsTutorial", false)
    ToggleUI("BeeCard", false)
    ToggleUI("ShopUi", false)
    ToggleUI("Beestiary", false)
    ToggleUI("PlaceButtons", false)
    ToggleUI("PlayerStats", false)
    ToggleUI("CenterPlayerButton", false)
    ToggleUI("PlaceStatus", false)
    ToggleUI("Leaderboard", false)
    ToggleUI("Tutorial", false)
end

function OpenShearsTutorial()
    ToggleUI("ShopUi", false)
    ToggleUI("PlayerStats", false)
    ToggleUI("CenterPlayerButton", false)
    ToggleUI("ShearsTutorial", true)
    ShearsTutorialObject:GetComponent(ShearsTutorial).Init()
end

function CloseShearsTutorial()
    ToggleUI("ShopUi", true)
    ShowMenu()
    ToggleUI("ShearsTutorial", false)
    CreateOrderGuiObject:GetComponent(CreateOrderGui).Init()
end

function OpenPlaceFlowerMenu()
    ToggleUI("PlaceFlowerMenu", true)
    ToggleUI("PlayerStats", false)
    ToggleUI("CenterPlayerButton", false)
    ToggleUI("PlaceButtons", false)
    PlaceFlowerMenuObject:GetComponent(PlaceFlowerUi).Init()
end

function ClosePlaceFlowerMenu()
    ToggleUI("PlaceFlowerMenu", false)
    ShowMenu()
    ToggleUI("PlaceButtons", true)
end


function OpenAddHatMenu()
    ToggleUI("AddHatMenu", true)
    ToggleUI("BeeList", false)
    ToggleUI("PlayerStats", false)
    ToggleUI("CenterPlayerButton", false)
    ToggleUI("PlaceButtons", false)
    AddHatMenuObject:GetComponent(AddHatUi).Init()
end

function CloseAddHatMenu()
    ToggleUI("AddHatMenu", false)
    ShowMenu()
    ToggleUI("PlaceButtons", true)
end

function OpenLeaderboard()
    ToggleUI("Leaderboard", true)
    ToggleUI("PlayerStats", false)
    ToggleUI("CenterPlayerButton", false)
    ToggleUI("PlaceButtons", false)
    LeaderboardObject:GetComponent(Leaderboard).Init()
end

function CloseLeaderboard()
    ToggleUI("Leaderboard", false)
    ToggleUI("PlayerStats", true)
    ToggleUI("CenterPlayerButton", true)
    ToggleUI("PlaceButtons", true)
end

function OpenTutorialByPlayer()
    ToggleUI("Tutorial", true)
    TutorialObject:GetComponent(Tutorial).Init(true, false)
end

wildBeeManager.notifyCaptureSucceeded:Connect((function(species)
    ToggleUI("BeeCard", true)
    ToggleUI("PlaceButtons", false)
    ToggleUI("PlayerStats", false)
    ToggleUI("CenterPlayerButton", false)
    InfoCardObject:GetComponent(InfoCard).ShowCaughtWild(species)
    audioManager.PlaySound("captureSound", 1)
    InfoCardObject:GetComponent(InfoCard).SetCloseCallback(function() ToggleUI("BeeCard", false) ToggleUI("PlaceButtons", true) ToggleUI("PlayerStats", true) ToggleUI("CenterPlayerButton", true) end)
end))

playerManager.notifyBeePurchased:Connect((function(species)
    ToggleUI("BeeCard", true)
    ToggleUI("PlayerStats", false)
    ToggleUI("CenterPlayerButton", false)
    ToggleUI("ShopUi", false)
    InfoCardObject:GetComponent(InfoCard).ShowReceived(species)
    InfoCardObject:GetComponent(InfoCard).SetCloseCallback(function() ToggleUI("BeeCard", false) ToggleUI("ShopUi", true) HideButtons() ToggleUI("PlayerStats", true) end)
end))

playerManager.notifyItemPurchased:Connect((function(item)
    audioManager.PlaySound("purchaseSound", 1)
    ToggleUI("BeeCard", true)
    ToggleUI("PlayerStats", false)
    ToggleUI("CenterPlayerButton", false)
    ToggleUI("ShopUi", false)
    InfoCardObject:GetComponent(InfoCard).ShowPurchasedItem(item)
    InfoCardObject:GetComponent(InfoCard).SetCloseCallback( function() ToggleUI("BeeCard", false) ToggleUI("ShopUi", true) HideButtons() ToggleUI("PlayerStats", true) end)
end))

function self:ClientAwake()
    Timer.new(0.2, function() 
        HideAll()
    end, false)

    Timer.new(.5, function() 
        ToggleUI("Tutorial", true)
        TutorialObject:GetComponent(Tutorial).Init(false)
    end, false)
end

function ShowMenu()
    ToggleUI("PlayerStats", true)
    ToggleUI("CenterPlayerButton", true)
    StatsObject:GetComponent("PlayerStatGui").ShowMenu()
    StatsObject:GetComponent("PlayerStatGui").CloseSettings()
end