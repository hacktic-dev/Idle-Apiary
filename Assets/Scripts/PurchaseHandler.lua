--!Type(Module)

--[[
  In this example we will be using "tokens" as the currency
  This is currently stored locally, but you should store it in Storage or Inventory for persistence
]]

local playerManager = require("PlayerManager")
audioManager = require("AudioManager")
local UIManager = require("UIManager")

--!SerializeField
local statusObject : GameObject = nil

testServer = Event.new("testServer")
serverResponse = Event.new("serverResponse")

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

  -- Assuming you have multiple products to purchase (e.g., "token_100", "token_500")
  if productId == "honey_1" then
    tokensToGive = 250
  elseif productId == "honey_2" then
    tokensToGive = 1000
  elseif productId == "honey_3" then
    tokensToGive = 3000
  else
    -- No product found, reject the purchase and return
    Payments.AcknowledgePurchase(purchase, false)
    -- Add an extra message to the console to help with debugging
    print("Unknown product ID: " .. productId)
    return
  end

  -- The purchase was successful, acknowledge the purchase and give the player the tokens
  Payments.AcknowledgePurchase(purchase, true, function(ackErr: PaymentsError)
    -- Check for any errors when acknowledging the purchase
    if ackErr ~= PaymentsError.None then
      print("Error acknowledging purchase: " .. ackErr)
      return
    end

    -- Add the tokens to the player's account (calling the IncrementTokens function)
    IncrementTokens(player, tokensToGive)
  end)
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
        Payments:PromptPurchase(id, function(paid)
            if paid then
              print("Purchase successful")
              audioManager.PlaySound("purchaseSound", 1)
            else
              print("Purchase failed")
            end
          end)
    end)
end