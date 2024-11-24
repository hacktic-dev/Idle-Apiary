--!Type(Module)

--[[
  In this example we will be using "tokens" as the currency
  This is currently stored locally, but you should store it in Storage or Inventory for persistence
]]

--!SerializeField
local InfoCardObject : GameObject = nil

local playerManager = require("PlayerManager")
audioManager = require("AudioManager")
local UIManager = require("UIManager")

--!SerializeField
local statusObject : GameObject = nil

testServer = Event.new("testServer")
serverResponse = Event.new("serverResponse")

hideUiEvent = Event.new("HideUiEvent")

purchaseSucceededEvent = Event.new("purchaseSucceededEvent")
purchaseFailedEvent = Event.new("purchaseFailedEvent")

responseTesting = false

attempts = 0

-- Function to Prompt the player to purchase a token (Client Side)
function PromptTokenPurchase(id: string)
    testServer:FireServer(id)
    responseTesting = true
    Timer.new(0.5, function() 
    if responseTesting then
        statusObject:GetComponent("PlaceApiaryStatus").SetStatus("This feature isn't available right now. Please try again later.")
        UIManager.ToggleUI("PlaceStatus", true)
        Timer.new(3.5, function() UIManager.ToggleUI("PlaceStatus", false) end, false)
    end
    end, false)
end

-- Function to handle the purchase (Server Side)
function ServerHandlePurchase(purchase, player: Player)
  -- Note: The product ID is a string even when it represents a number
  local productId = purchase.product_id -- The product ID that was purchased (e.g., "token")

  print("Player " .. player.name .. " has made a purchase of ".. productId ..". Attempting...")

  local time = 0

  if productId == "doubler_1" then
    time = 300
  elseif product_id == "doubler_2" then
    time = 900
  else
    Payments.AcknowledgePurchase(purchase, false)
    purchaseFailedEvent:FireClient(player)
  end

  playerManager.SetHoneyDoublerForPlayer(player, time)

  Payments.AcknowledgePurchase(purchase, true, function(ackErr: PaymentsError)
    if ackErr ~= PaymentsError.None then
      print("Error acknowledging purchase: " .. ackErr)
      purchaseFailedEvent:FireClient(player)
      return
    end
    print("Player ".. player.name .." honey doubler is now active")
    purchaseSucceededEvent:FireClient(player, productId)
  end)
end

-- Initialize the module
function self:ServerAwake()
  -- IMPORTANT: Register the ServerHandlePurchase function as the callback for the PurchaseHandler
  Payments.PurchaseHandler = ServerHandlePurchase

  testServer:Connect(function(player, id)
      print("Purchase request was initiated by " .. player.name)

      if playerManager.PlayerHasActiveHoneyDoubler(player) then
        serverResponse:FireClient(player, id, false)
        return
      end

    serverResponse:FireClient(player, id, true)
  end)
end

function self:ClientAwake()
    serverResponse:Connect(function(id, allowed)
      responseTesting = false
      
        if allowed == false then
          statusObject:GetComponent("PlaceApiaryStatus").SetStatus("You already have an active honey doubler! Wait for it to run out before purchasing again.")
          UIManager.ToggleUI("PlaceStatus", true)
          Timer.new(3.5, function() UIManager.ToggleUI("PlaceStatus", false) end, false)
          return
        end
        Payments:PromptPurchase(id, function(paid) end)
    end)
    
    purchaseSucceededEvent:Connect(function(id)
      print("Purchase successful. Showing UI.")
      print(id)
      UIManager.ToggleUI("BeeCard", true)
      UIManager.ToggleUI("ShopUi", false)
      UIManager.ToggleUI("PlayerStats", false)
      InfoCardObject:GetComponent(BeeObtainCard).showPurchasedHoney(id)
      hideUiEvent:Fire()
      audioManager.PlaySound("purchaseSound", 1)
    end)

        
    purchaseFailedEvent:Connect(function()
      print("Purchase failed")
      UIManager.ToggleUI("BeeCard", true)
      UIManager.ToggleUI("ShopUi", false)
      UIManager.ToggleUI("PlayerStats", false)
      InfoCardObject:GetComponent(BeeObtainCard).showPurchasedHoneyFailed()
      hideUiEvent:Fire()
    end)

    hideUiEvent:Connect(function()
        Timer.new(5, function() UIManager.ToggleUI("BeeCard", false)
            UIManager.ToggleUI("ShopUi", true)
            UIManager.HideButtons()
            UIManager.ToggleUI("PlayerStats", true) end, false)
          end)
end