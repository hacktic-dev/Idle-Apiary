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

-- Function to increment the player's tokens (Server Side)
function IncrementTokens(player: Player, amount: number)
  -- Note: Remember to add your own logic if you are using Network values or Storage
  -- In this case we are only storing the tokens locally (not recommended but for example purposes)
  playerManager.GiveCash(player, amount)
  -- Print the player's name, the amount of tokens they received, and their total tokens
  print(player.name .. " received " .. amount .. " honey.")
end

-- Function to handle the purchase (Server Side)
function ServerHandlePurchase(purchase, player: Player)
  -- Note: The product ID is a string even when it represents a number
  local productId = purchase.product_id -- The product ID that was purchased (e.g., "token")

  -- The amount of tokens to give the player
  local tokensToGive = 0 -- Initialize the amount of tokens to give

  local cash = playerManager.GetPlayerCash(player)

  -- Assuming you have multiple products to purchase (e.g., "token_100", "token_500")
  if productId == "honey_1" then
    tokensToGive = 250
  elseif productId == "honey_2" then
    tokensToGive = 1000
  elseif productId == "honey_3" then
    tokensToGive = 3000
  end

  -- Add the tokens to the player's account (calling the IncrementTokens function)
  IncrementTokens(player, tokensToGive)

  Timer.new(0.3, function() 
    print(playerManager.GetPlayerCash(player) - 1000 .. " vs. " .. cash)

    if playerManager.GetPlayerCash(player) - 200 > cash then
      Payments.AcknowledgePurchase(purchase, true, function(ackErr: PaymentsError)
        -- Check for any errors when acknowledging the purchase
        if ackErr ~= PaymentsError.None then
          print("Error acknowledging purchase: " .. ackErr)
          purchaseFailedEvent:FireClient(player)
          return

        end
        purchaseSucceededEvent:FireClient(player, productId)
      end)
    else
      print("no purchase")
      Payments.AcknowledgePurchase(purchase, false)
      purchaseFailedEvent:FireClient(player)
    end
  end, false)
end

-- Initialize the module
function self:ServerAwake()
  -- IMPORTANT: Register the ServerHandlePurchase function as the callback for the PurchaseHandler
  Payments.PurchaseHandler = ServerHandlePurchase

  testServer:Connect(function(player, id)
    serverResponse:FireClient(player, id)
  end)
end

function self:ClientAwake()
    serverResponse:Connect(function(id)
        responseTesting = false
        Payments:PromptPurchase(id, function(paid) end)
    end)
    
    purchaseSucceededEvent:Connect(function(id)
      print("Purchase successful")
      print(id)
      UIManager.ToggleUI("BeeCard", true)
      UIManager.ToggleUI("ShopUi", false)
      UIManager.ToggleUI("PlayerStats", false)
      InfoCardObject:GetComponent(InfoCard).showPurchasedHoney(id)
      hideUiEvent:Fire()
      audioManager.PlaySound("purchaseSound", 1)
    end)

        
    purchaseFailedEvent:Connect(function()
      print("Purchase failed")
      UIManager.ToggleUI("BeeCard", true)
      UIManager.ToggleUI("ShopUi", false)
      UIManager.ToggleUI("PlayerStats", false)
      InfoCardObject:GetComponent(InfoCard).showPurchasedHoneyFailed()
      hideUiEvent:Fire()
    end)

    hideUiEvent:Connect(function()
        Timer.new(5, function() UIManager.ToggleUI("BeeCard", false)
            UIManager.ToggleUI("ShopUi", true)
            UIManager.HideButtons()
            UIManager.ToggleUI("PlayerStats", true) end, false)
end
    )
end