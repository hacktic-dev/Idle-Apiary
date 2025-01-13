--!Type(UI)

--!Bind
local closeLabel : UILabel = nil -- Reference to the label for the close button.
--!Bind
local closeButton : UIButton = nil -- Reference to the button for closing the UI.
--!Bind
local _InventoryContent : UIScrollView = nil -- Important do not remove

--!Bind
local _beeCard : VisualElement = nil
--!Bind
local _beeLabel : UILabel = nil
--!Bind
local _beeSet : UILabel = nil
--!Bind
local _honeyRateLabel : UILabel = nil
--!Bind
local _sellPriceLabel : UILabel = nil
--!Bind
local _beeImage : UIImage = nil
--!Bind
local _rarity : UILabel = nil
--!Bind
local _rankLabel : UILabel = nil

local UIManager = require("UIManager") 
local Utils = require("Utils")
local wildBeeManager = require("WildBeeManager")
local playerManager = require("PlayerManager")

-- Create a list of bee names
beeNames = {
    "Common Bee", "Stone Bee", "Forest Bee", "Meadow Bee", "Aquatic Bee", "Giant Bee", "Bronze Bee", "Silver Bee",
    "Muddy Bee", "Frigid Bee", "Steel Bee", "Oceanic Bee", "Magma Bee", "Ghostly Bee", "Ruby Bee", "Iridescent Bee",
    "Sandy Bee", "Autumnal Bee", "Petal Bee", "Camo Bee", "Galactic Bee", "Industrial Bee", "Crystal Bee", "Pearlescent Bee",
    "Hypnotic Bee", "Radiant Bee", "Shadow Bee", "Techno Bee",  "Prismatic Bee", "Astral Bee", "Psychedelic Bee", "Rainbow Bee"}

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
            _image.image = Utils.BeeImage[beeName]
            questItem:RegisterPressCallback(function()
                ShowCard(beeName, true)
            end
            )
        else
            _image.image = Utils.BeeImage["Locked"]
            questItem:RegisterPressCallback(function()
                ShowCard(beeName, false)
            end
            )
        end
        questItem:Add(_image)

        _InventoryContent:Add(questItem)
    end
end

function ShowCard(species, beeSeen)
    _beeCard.visible = true
    speciesName = species
    if not beeSeen then
        speciesName = "?????"
    end
    _beeLabel:SetPrelocalizedText(speciesName)
    _beeSet:SetPrelocalizedText(wildBeeManager.getSet(species))
    _rarity:SetPrelocalizedText(wildBeeManager.getRarity(species) .. " Bee")
    _honeyRateLabel:SetPrelocalizedText("Honey rate: " .. wildBeeManager.getHoneyRate(species))
    _sellPriceLabel:SetPrelocalizedText("Sell price: " .. wildBeeManager.getSellPrice(species))
end

-- Called when the UI object this script is attached to is initialized.
function Init()
    closeLabel:SetPrelocalizedText("Close", true) -- Set the text of the close button.
    playerManager.requestSeenBees:FireServer()
    _beeCard.visible = false
    -- Add a callback to the close button to hide the UI when pressed.
    closeButton:RegisterPressCallback(function()
        UIManager.CloseBeestiary()
    end, true, true, true)

    playerManager.receiveSeenBees:Connect(function(seenBees)
        Populate(seenBees)

				count = #seenBees

				for index, value in ipairs(seenBees) do
					if value == "Festive Bee" or value == "Romantic Bee" then
						count = count - 1
					end
				end

        howManyToNextRank = 8 - (count % 8)
        if count == 32 then
            _rankLabel:SetPrelocalizedText("You have discovered every bee!")
        elseif howManyToNextRank == 1 then
            _rankLabel:SetPrelocalizedText("Discover 1 more bee to reach the next rank!")
        else
            _rankLabel:SetPrelocalizedText("Discover " .. howManyToNextRank .. " more bees to reach the next rank!")
        end
    end)
end
