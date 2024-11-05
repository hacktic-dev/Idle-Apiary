--!Type(UI)

--!Bind
local closeLabel : UILabel = nil -- Reference to the label for the close button.
--!Bind
local closeButton : UIButton = nil -- Reference to the button for closing the UI.
--!Bind
local _InventoryContent : UIScrollView = nil -- Important do not remove

--!SerializeField
local beeTextures : {Texture} = nil

local UIManager = require("UIManager") 
local wildBeeManager = require("WildBeeManager")
local playerManager = require("PlayerManager")

-- Create a list of bee names
beeNames = {
    "Common Bee", "Stone Bee", "Forest Bee", "Aquatic Bee", "Giant Bee", "Silver Bee",
    "Muddy Bee", "Frigid Bee", "Steel Bee", "Magma Bee", "Ghostly Bee", "Iridescent Bee",
    "Sandy Bee", "Autumnal Bee", "Petal Bee", "Galactic Bee", "Radiant Bee", "Rainbow Bee"
}

local BeeImage = {
    ["Common Bee"] = beeTextures[1],
    ["Stone Bee"] = beeTextures[2],
    ["Forest Bee"] = beeTextures[3],
    ["Aquatic Bee"] = beeTextures[4],
    ["Giant Bee"] = beeTextures[5],
    ["Silver Bee"] = beeTextures[6],
    ["Muddy Bee"] = beeTextures[7],
    ["Frigid Bee"] = beeTextures[8],
    ["Steel Bee"] = beeTextures[9],
    ["Magma Bee"] = beeTextures[10],
    ["Ghostly Bee"] = beeTextures[11],
    ["Iridescent Bee"] = beeTextures[12],
    ["Sandy Bee"] = beeTextures[13],
    ["Autumnal Bee"] = beeTextures[14],
    ["Petal Bee"] = beeTextures[15],
    ["Galactic Bee"] = beeTextures[16],
    ["Radiant Bee"] = beeTextures[17],
    ["Rainbow Bee"] = beeTextures[18]
}


function Populate(seenBees)
    _InventoryContent:Clear()
    print("Populating list")

    for _, beeName in ipairs(beeNames) do
        print("Adding " .. beeName)
        beeSeen = false
        for i, seenBeeName in ipairs(seenBees) do
            if beeName == seenBeeName then
                beeSeen = true
                break
            end
        end

        local questItem = UIButton.new()
        questItem:AddToClassList("order-item") -- Add a class to style the quest item.

        local _image = UIImage.new()
        _image:AddToClassList("inventory__item__icon__image")
        if beeSeen then
            _image.image = BeeImage[beeName]
        else
            _image.image = beeTextures[19]
        end
        questItem:Add(_image)

        _InventoryContent:Add(questItem)
    end
end

-- Called when the UI object this script is attached to is initialized.
function Init()
    closeLabel:SetPrelocalizedText("Close", true) -- Set the text of the close button.
    playerManager.requestSeenBees:FireServer()
    -- Add a callback to the close button to hide the UI when pressed.
    closeButton:RegisterPressCallback(function()
        UIManager.CloseBeestiary()
    end, true, true, true)

    playerManager.recieveSeenBees:Connect(function(seenBees)
        Populate(seenBees)
    end)
end
