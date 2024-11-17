--!Type(UI)


--!Bind
local Flowers_Root : UIScrollView = nil
--!Bind
local closeButton : UIButton = nil
--!Bind
local closeLabel : UILabel = nil

local orderManager = require("OrderManager")
local playerManager = require("PlayerManager")
local UIManager = require("UIManager") 
local audioManager = require("AudioManager")
local apiaryManager = require("ApiaryManager")
local purchaseHandler = require("PurchaseHandler")

local state = 0 -- Which tab are we on?

local flowerManager = require("FlowerManager")

function Init()
    closeLabel:SetPrelocalizedText("Close", true)
    Flowers_Root:Clear()
    closeButton:RegisterPressCallback(function()
        UIManager.ClosePlaceFlowerMenu()
    end, true, true, true)

    flowerManager.queryOwnedFlowers:FireServer()
end

function AddFlowerCard(name, amount)
    local flowerCard = UIButton.new()
    flowerCard:AddToClassList("flower-item")

    local titleLabel = UILabel.new()
    titleLabel:AddToClassList("title")
    titleLabel:SetPrelocalizedText(name .. " Flower")
    flowerCard:Add(titleLabel)

    local image = UIImage.new()
    image:AddToClassList(name .. "-flower-image")
    image:AddToClassList("image")
    flowerCard:Add(image)

    local descriptionLabel = UILabel.new()
    descriptionLabel:AddToClassList("description")
    descriptionLabel:SetPrelocalizedText(flowerManager.LookupFlowerDescription(name))
    flowerCard:Add(descriptionLabel)

    local amountLabel = UILabel.new()
    amountLabel:AddToClassList("amount")
    amountLabel:SetPrelocalizedText("x" .. amount)
    flowerCard:Add(amountLabel)

    flowerCard:RegisterPressCallback(function()
        position = client.localPlayer.character:GetComponent(Transform).position
        flowerManager.PlaceFlower(name, position)
        UIManager.ClosePlaceFlowerMenu()
    end, true, true, true)

    Flowers_Root:Add(flowerCard)
end

function NoFlowers()
    local titleLabel = UILabel.new()
    titleLabel:AddToClassList("title")
    titleLabel:SetPrelocalizedText("You don't have any flowers :(")
    Flowers_Root:Add(titleLabel)
end

function self:ClientAwake()
  
end
