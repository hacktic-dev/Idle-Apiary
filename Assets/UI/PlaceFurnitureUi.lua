--!Type(UI)

--!Bind
local Furniture_Root : UIScrollView = nil
--!Bind
local closeButton : UIButton = nil
--!Bind
local closeLabel : UILabel = nil

local UIManager = require("UIManager") 
local placedObjectsManager = require("PlacedObjectsController")
local Utils = require("Utils")
local audioManager = require("AudioManager")
local ApiaryManager = require("ApiaryManager")

local existingFurnitureCards = {}

function Init()
    closeLabel:SetPrelocalizedText("Close", true)
    Furniture_Root:Clear()
    existingFurnitureCards = {}
    closeButton:RegisterPressCallback(function()
        UIManager.ClosePlaceFurnitureMenu()
    end, true, true, true)

    placedObjectsManager.receiveOwnedFurniture:Connect(function(name, amount) AddFurnitureCard(name, amount) end)

    placedObjectsManager.noFurnitureOwned:Connect(function() NoFurniture() end)

    print("Querying owned furniture on server")

    placedObjectsManager.queryOwnedFurniture:FireServer()
end

function AddFurnitureCard(id, amount)
    if existingFurnitureCards[id] then
        return
    end

    local furnitureCard = UIButton.new()
    furnitureCard:AddToClassList("furniture-item")

    local titleLabel = UILabel.new()
    titleLabel:AddToClassList("title")
    titleLabel:SetPrelocalizedText(Utils.LookupFurnitureName(id))
    furnitureCard:Add(titleLabel)

    local image = UIImage.new()
    image:AddToClassList("furniture-image")
    image:AddToClassList("image")
    image.image = Utils.FurnitureImage[Utils.LookupFurnitureName(id)]
    furnitureCard:Add(image)

    local amountLabel = UILabel.new()
    amountLabel:AddToClassList("amount")
    amountLabel:SetPrelocalizedText("x" .. amount)
    furnitureCard:Add(amountLabel)

    furnitureCard:RegisterPressCallback(function()
        ApiaryManager.SetPlacementMode(Utils.LookupFurnitureName(id))
        UIManager.OpenPlaceObjectsUi()

    end, true, true, true)

    Furniture_Root:Add(furnitureCard)
    existingFurnitureCards[id] = furnitureCard
end

function NoFurniture()
    if #Furniture_Root:GetChildren() == 0 then
        local titleLabel = UILabel.new()
        titleLabel:AddToClassList("no-furniture")
        titleLabel:SetPrelocalizedText("You don't have any furniture :(")
        Furniture_Root:Add(titleLabel)
    end
end

function self:ClientAwake()
    UIManager.initPlaceFurnitureMenu:Connect(function() Init() end)
end
