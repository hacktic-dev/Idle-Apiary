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
--!SerializeField
local PlaceFurnitureMenuObject : GameObject = nil
--!SerializeField
local PlaceObjectsUiObject : GameObject = nil
--!SerializeField
local RemoveFurnitureMenuObject : GameObject = nil

--EASTER
--!SerializeField
local EggCraftingUiObject : GameObject = nil
--!SerializeField
local DailyQuestUiObject : GameObject = nil
--!SerializeField
local QuestRewardUiObject : GameObject = nil
--!SerializeField
local TradingUiObject : GameObject = nil
--!SerializeField
local EggInventoryObject : GameObject = nil
--!SerializeField
local DailyRewardsWheelObject : GameObject = nil
--!SerializeField
local EggObtainUiObject : GameObject = nil

local wildBeeManager = require("WildBeeManager")
local playerManager = require("PlayerManager")
local audioManager = require("AudioManager")
local eggInventoryHandler = require("EggInventoryHandler")
local dailyQuestTracker = require("DailyQuestTracker")
local tradingManager = require("TradingManager")

initPlaceFurnitureMenu = Event.new("initPlaceFurnitureMenu")

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
    Leaderboard = LeaderboardObject,
    PlaceFurnitureMenu = PlaceFurnitureMenuObject,
    PlaceObjectsUi = PlaceObjectsUiObject,
    RemoveFurnitureMenu = RemoveFurnitureMenuObject,
    EggCraftingUi = EggCraftingUiObject,
    DailyQuestUi = DailyQuestUiObject,
    QuestRewardUi = QuestRewardUiObject,
    TradingUi = TradingUiObject,
    EggInventory = EggInventoryObject,
    DailyRewardsWheel = DailyRewardsWheelObject,
    EggObtainUi = EggObtainUiObject,
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
end

function ShowTutorial()
    HideAll()
    ToggleUI("Tutorial", true)
end

function HideTutorial()
    if not IsActive("Tutorial") then
        return
    end
    ShowMenu()
    ToggleUI("Tutorial", false)
end

function HideAll()
    ToggleUI("PlaceFlowerMenu", false)
    ToggleUI("PlaceFurnitureMenu", false)
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
    ToggleUI("Tutorial", false)
    ToggleUI("PlaceObjectsUi", false)
    ToggleUI("RemoveFurnitureMenu", false)
    ToggleUI("EggCraftingUi", false)
    ToggleUI("DailyQuestUi", false)
    ToggleUI("QuestRewardUi", false)
    ToggleUI("TradingUi", false)
    ToggleUI("EggInventory", false)
    ToggleUI("DailyRewardsWheel", false)
    ToggleUI("EggObtainUi", false)
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
    HideMenu()
    PlaceFlowerMenuObject:GetComponent(PlaceFlowerUi).Init()
end

function ClosePlaceFlowerMenu()
    ToggleUI("PlaceFlowerMenu", false)
    ShowMenu()
end

function OpenPlaceFurnitureMenu()
    ToggleUI("PlaceFurnitureMenu", true)
    HideMenu()
    initPlaceFurnitureMenu:Fire()
end

function ClosePlaceFurnitureMenu()
    ToggleUI("PlaceFurnitureMenu", false)
    ShowMenu()
end

function OpenPlaceObjectsUi()
    ToggleUI("PlaceObjectsUi", true)
    ToggleUI("PlayerStats", false)
    ToggleUI("PlaceFurnitureMenu", false)
    ToggleUI("CenterPlayerButton", false)
    ToggleUI("PlaceButtons", false)
end

function ClosePlaceObjectsUi()
    ToggleUI("PlaceObjectsUi", false)
    ShowMenu()
end

function OpenRemoveFurnitureMenu()
    ToggleUI("RemoveFurnitureMenu", true)
    HideMenu()
    print("Opening remove furniture menu")
    RemoveFurnitureMenuObject:GetComponent(RemoveFurnitureUi).Init()
end

function CloseRemoveFurnitureMenu()
    ToggleUI("RemoveFurnitureMenu", false)
    ShowMenu()
end

function OpenAddHatMenu()
    ToggleUI("AddHatMenu", true)
    ToggleUI("BeeList", false)
    HideMenu()
    AddHatMenuObject:GetComponent(AddHatUi).Init()
end

function CloseAddHatMenu()
    ToggleUI("AddHatMenu", false)
    ShowMenu()
end

function OpenEggCraftingUi()
    eggInventoryHandler.RequestEggInventoryEvent:FireServer()
end

function CloseEggCraftingUi()
    ToggleUI("EggCraftingUi", false)
    ShowMenu()
end

function OpenDailyQuestUi()
    dailyQuestTracker.RequestDailyQuestDataEvent:FireServer()
end

function CloseDailyQuestUi()
    ToggleUI("DailyQuestUi", false)
    ShowMenu()
end

function OpenQuestRewardUi()
    dailyQuestTracker.RequestTicketCountEvent:FireServer()
end

function CloseQuestRewardUi()
    ToggleUI("QuestRewardUi", false)
    StatsObject:GetComponent(PlayerStatGui).ShowAllButTickets()
    ShowMenu()
end

function OpenTradingUi()
    ToggleUI("TradingUi", true)
    HideMenu()
    TradingUiObject:GetComponent(TradingUi).Init()
end

function CloseTradingUi()
    ToggleUI("TradingUi", false)
    ShowMenu()
end

function NotifyTradeTimeout()
    ToggleUI("BeeCard", true)
    ToggleUI("TradingUi", false)
    InfoCardObject:GetComponent(InfoCard).ShowTradeTimeout()
    audioManager.PlaySound("failSound", 1)
    InfoCardObject:GetComponent(InfoCard).SetCloseCallback(
        function()  
            ToggleUI("BeeCard", false) 
            ToggleUI("TradingUi", false) 
            ShowMenu()
        end)
end

function OpenEggInventory()
    ToggleUI("EggInventory", true)
    HideMenu()
    EggInventoryObject:GetComponent(EggInventoryUi).Init()
end

function CloseEggInventory()
    ToggleUI("EggInventory", false)
    ShowMenu()
end

function OpenDailyRewardsWheel()
    ToggleUI("DailyRewardsWheel", true)
    HideMenu()
    DailyRewardsWheelObject:GetComponent(DailyRewardsWheel).Init()
end

function CloseDailyRewardsWheel()
    ToggleUI("DailyRewardsWheel", false)
    ShowMenu()
end

function OpenEggObtainUi(eggId : string)
    ToggleUI("EggObtainUi", true)
    HideMenu()
    audioManager.PlaySound("captureSound", 1)
    EggObtainUiObject:GetComponent(EggObtainUi).Init(eggId)
end

function CloseEggObtainUi()
    ToggleUI("EggObtainUi", false)
    ShowMenu()
end

function OpenTutorialByPlayer()
    ToggleUI("Tutorial", true)
    TutorialObject:GetComponent(Tutorial).Init(true)
end

wildBeeManager.notifyCaptureSucceeded:Connect((function(species)
    ToggleUI("BeeCard", true)
    ToggleUI("PlaceButtons", false)
    ToggleUI("PlayerStats", false)
    ToggleUI("CenterPlayerButton", false)
    InfoCardObject:GetComponent(InfoCard).ShowCaughtWild(species)
    audioManager.PlaySound("captureSound", 1)
    InfoCardObject:GetComponent(InfoCard).SetCloseCallback(
        function()
            ToggleUI("BeeCard", false)
            ShowMenu()
        end)
end))

playerManager.notifyBeePurchased:Connect((function(species)
    ToggleUI("BeeCard", true)
    ToggleUI("PlayerStats", false)
    ToggleUI("CenterPlayerButton", false)
    ToggleUI("ShopUi", false)
    InfoCardObject:GetComponent(InfoCard).ShowReceived(species)
    InfoCardObject:GetComponent(InfoCard).SetCloseCallback(
        function()
            ToggleUI("BeeCard", false)
            ToggleUI("ShopUi", true)
            HideButtons()
            ToggleUI("PlayerStats", true)
        end)
end))

playerManager.notifyItemPurchased:Connect((function(item)
    ToggleUI("BeeCard", true)
    ToggleUI("PlayerStats", false)
    ToggleUI("CenterPlayerButton", false)
    ToggleUI("ShopUi", false)
    InfoCardObject:GetComponent(InfoCard).ShowPurchasedItem(item)
    audioManager.PlaySound("purchaseSound", 1)
    InfoCardObject:GetComponent(InfoCard).SetCloseCallback(
        function()
            ToggleUI("BeeCard", false)
            ToggleUI("ShopUi", true)
            HideButtons()
            ToggleUI("PlayerStats", true)
        end)
end))

function self:ClientAwake()
    Timer.new(0.2, function() 
        HideAll()
        ShowMenu()
    end, false)

    Timer.new(3, function() 
        shouldShow = TutorialObject:GetComponent(Tutorial).GetShouldShowTutorial()
        print("Should show tutorial: " .. tostring(shouldShow))
        if shouldShow then
            HideMenu()
            ToggleUI("Tutorial", true)
            TutorialObject:GetComponent(Tutorial).Init(false)
        end
    end, false)

    eggInventoryHandler.NotifyEggCollectedEvent:Connect((function(eggId)
        OpenEggObtainUi(eggId)
    end))

    eggInventoryHandler.NotifyEggInventoryRecievedEvent:Connect((function(eggs)
        ToggleUI("EggCraftingUi", true)
        ToggleUI("PlayerStats", false)
        ToggleUI("CenterPlayerButton", false)
        ToggleUI("PlaceButtons", false)
        EggCraftingUiObject:GetComponent(EggCraftingUi).Init(eggs)
    end))

    eggInventoryHandler.NotifyEggCraftedEvent:Connect((function(name)
        ToggleUI("BeeCard", true)
        ToggleUI("EggCraftingUi", false)
        InfoCardObject:GetComponent(InfoCard).ShowEggCrafted(name)
        audioManager.PlaySound("captureSound", 1) --TODO add a new sound here
        InfoCardObject:GetComponent(InfoCard).SetCloseCallback(
            function()  
                ToggleUI("BeeCard", false) 
                OpenEggCraftingUi()
            end)
    end))

    eggInventoryHandler.NotifyRewardExchangedEvent:Connect((function(name, cost)
        ToggleUI("BeeCard", true)
        ToggleUI("PlayerStats", false)
        ToggleUI("QuestRewardUi", false)
        InfoCardObject:GetComponent(InfoCard).ShowRewardExchanged(name, cost)
        audioManager.PlaySound("captureSound", 1) --TODO add a new sound here
        InfoCardObject:GetComponent(InfoCard).SetCloseCallback(
            function()  
                ToggleUI("BeeCard", false)
                ToggleUI("PlayerStats", true)
                OpenQuestRewardUi()
            end)
    end))

    tradingManager.NotifyStartTradeRequested:Connect((function(sendingPlayer)
        HideAll()
        ToggleUI("BeeCard", true)
        InfoCardObject:GetComponent(InfoCard).ShowTradeRequest(sendingPlayer)
    end))

    tradingManager.NotifyTradeRequestDeclined:Connect((function(targetPlayer)
        ToggleUI("BeeCard", true)
        ToggleUI("TradingUi", false)
        InfoCardObject:GetComponent(InfoCard).ShowTradeRequestDeclined(targetPlayer)
        audioManager.PlaySound("failSound", 1)
        InfoCardObject:GetComponent(InfoCard).SetCloseCallback(
            function()  
                ToggleUI("BeeCard", false) 
                ShowMenu()
            end)
    end))

    --Open trading UI for the receiving player after accepting the trade request
    tradingManager.NotifyTradeRequestAccepted:Connect((function(targetPlayer, tradeId)
        if not IsActive("TradingUi") then
            ToggleUI("BeeCard", false)
            HideMenu()
            ToggleUI("TradingUi", true)
        end
    end))

    tradingManager.NotifyTradeCancelled:Connect((function(cancellingPlayer)
        ToggleUI("BeeCard", true)
        ToggleUI("TradingUi", false)
        InfoCardObject:GetComponent(InfoCard).ShowTradeCancelled(cancellingPlayer)
        audioManager.PlaySound("failSound", 0.75)
        InfoCardObject:GetComponent(InfoCard).SetCloseCallback(
            function()  
                ToggleUI("BeeCard", false) 
                ShowMenu()
            end)
    end))

    tradingManager.NotifyTradeConfirmed:Connect((function(otherPlayer)
        ToggleUI("BeeCard", true)
        ToggleUI("TradingUi", false)
        InfoCardObject:GetComponent(InfoCard).ShowTradeConfirmed(otherPlayer)
        audioManager.PlaySound("captureSound", 1) --TODO add a new sound here
        InfoCardObject:GetComponent(InfoCard).SetCloseCallback(
            function()  
                ToggleUI("BeeCard", false) 
                ShowMenu()
            end)
    end))

    InfoCardObject:GetComponent(InfoCard).RequestAcceptTradeEvent:Connect((function(sendingPlayer)
        tradingManager.RequestAcceptTradeRequest:FireServer(sendingPlayer)
        ToggleUI("BeeCard", false)
        ShowMenu()
    end))

    InfoCardObject:GetComponent(InfoCard).RequestDeclineTradeEvent:Connect((function(sendingPlayer)
        tradingManager.RequestDeclineTradeRequest:FireServer(sendingPlayer)
        ToggleUI("BeeCard", false)
        ShowMenu()
    end))

    dailyQuestTracker.NotifyDailyQuestDataRecievedEvent:Connect((function(data)
        ToggleUI("DailyQuestUi", true)
        ToggleUI("PlayerStats", false)
        ToggleUI("CenterPlayerButton", false)
        ToggleUI("PlaceButtons", false)
        DailyQuestUiObject:GetComponent(DailyQuestUi).Init(data)
    end))

    dailyQuestTracker.NotifyTicketCountReceivedEvent:Connect((function(ticketCount)
        ToggleUI("QuestRewardUi", true)
        ToggleUI("CenterPlayerButton", false)
        ToggleUI("PlaceButtons", false)
        StatsObject:GetComponent(PlayerStatGui).ShowOnlyTickets(ticketCount)
        QuestRewardUiObject:GetComponent(QuestRewardUi).Init(ticketCount)
    end))
end

function ShowMenu()
    ToggleUI("PlayerStats", true)
    ToggleUI("CenterPlayerButton", true)
    ToggleUI("PlaceButtons", true)
    StatsObject:GetComponent("PlayerStatGui").ShowMenu()
    StatsObject:GetComponent("PlayerStatGui").CloseSettings()
end

function HideMenu()
    ToggleUI("PlayerStats", false)
    ToggleUI("CenterPlayerButton", false)
    ToggleUI("PlaceButtons", false)
end