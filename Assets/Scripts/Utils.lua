--!Type(Module)

--!SerializeField
local beeTextures : {Texture} = nil
--!SerializeField
local hatTextures : {Texture} = nil
--!SerializeField
local placementObjects : {GameObject} = nil

PlacementObject = {
	["Test"] = placementObjects[1],
	["Chair"] = placementObjects[2],
	["Table"] = placementObjects[3],
	["Chess Table"] = placementObjects[4],
	["Book Table"] = placementObjects[5],
	["White Flower Planter"] = placementObjects[6],
	["Apple Box"] = placementObjects[7],
	["Red Mushroom"] = placementObjects[8],
	["Brown Mushroom"] = placementObjects[9],
	["Teddy Bear"] = placementObjects[10],
	["Toy Goose"] = placementObjects[11],
	["Pillow"] = placementObjects[12],
	["Fountain"] = placementObjects[13],
}

BeeImage = {
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
    ["Rainbow Bee"] = beeTextures[18],
    ["Astral Bee"] = beeTextures[19],
    ["Industrial Bee"] = beeTextures[20],
    ["Pearlescent Bee"] = beeTextures[21],
    ["Prismatic Bee"] = beeTextures[22],
    ["Shadow Bee"] = beeTextures[23],
    ["Hypnotic Bee"] = beeTextures[24],
    ["Festive Bee"] = beeTextures[25],
    ["Locked"] = beeTextures[26]
}

HatImage = {
    ["Yellow Wooly Hat"] = hatTextures[1],
    ["Pink Cap"] = hatTextures[2],
    ["Yellow Bucket Hat"] = hatTextures[3],
    ["Traffic Cone"] = hatTextures[4],
    ["Christmas Elf Hat"] = hatTextures[5],
    ["Pirate Hat"] = hatTextures[6],
    ["Pixel Sunglasses"] = hatTextures[7],
    ["Gold Crown"] = hatTextures[8],

    ["Leather Cap"] = hatTextures[9],
    ["Miner's Helmet"] = hatTextures[10],
    ["Red Beret"] = hatTextures[11],
    ["Sailor's Hat"] = hatTextures[12],
    ["Santa Hat"] = hatTextures[13],
    ["Top Hat"] = hatTextures[14],
    ["Fisherman's Cap"] = hatTextures[15],

    ["Cat Ears"] = hatTextures[16],
    ["Sleeping Cap"] = hatTextures[17],
    ["Mustache"] = hatTextures[18],
}

local hatData = 
{
    {name = "Yellow Wooly Hat", id = "yellow_wooly", rarity = "Common", selectFactorRegular = 10, selectFactorGold = 1, isLimited = false, cost = 3000, goldCost = 100},
    {name = "Pink Cap", id = "pink_cap", rarity = "Common", selectFactorRegular = 10, selectFactorGold = 1, isLimited = false, cost = 4000, goldCost = 250},
    {name = "Yellow Bucket Hat", id = "yellow_bucket", rarity = "Uncommon", selectFactorRegular = 5, selectFactorGold = 2,isLimited = false, cost = 12500, goldCost = 400},
    {name = "Traffic Cone", id = "traffic_cone", rarity = "Uncommon", selectFactorRegular = 5, selectFactorGold = 2, isLimited = false, cost = 20000, goldCost = 450},
    {name = "Christmas Elf Hat", id = "christmas_elf", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = true, cost = 25000, goldCost = 600},
    {name = "Pirate Hat", id = "pirate_hat", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = false, cost = 35000, goldCost = 750},
    {name = "Pixel Sunglasses", id = "pixel_sunglasses", rarity = "Legendary", selectFactorRegular = 0, selectFactorGold = 10, isLimited = false, cost = -1, goldCost = 850},
    {name = "Gold Crown", id = "gold_crown", rarity = "Legendary", selectFactorRegular = 0, selectFactorGold = 10, isLimited = false, cost = -1, goldCost = 1000},

    {name = "Leather Cap", id = "leather_cap", rarity = "Common", selectFactorRegular = 10, selectFactorGold = 1, isLimited = false, cost = 4000, goldCost = 200},
    {name = "Miner's Helmet", id = "miner_helmet", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8,isLimited = false, cost = 25000, goldCost = 500},
    {name = "Red Beret", id = "red_beret", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = false, cost = 30000, goldCost = 650},
    {name = "Sailor's Hat", id = "sailor_hat", rarity = "Uncommon", selectFactorRegular = 5, selectFactorGold = 2, isLimited = true, cost = 10000, goldCost = 350},
    {name = "Santa Hat", id = "santa_hat", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = false, cost = 25000, goldCost = 700},
    {name = "Top Hat", id = "top_hat", rarity = "Legendary", selectFactorRegular = 0, selectFactorGold = 10, isLimited = false, cost = -1, goldCost = 950},
    {name = "Fisherman's Cap", id = "fishermans_cap", rarity = "Uncommon", selectFactorRegular = 5, selectFactorGold = 2, isLimited = false, cost = 10000, goldCost = 300},

    {name = "Cat Ears", id = "cat_ears", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = false, cost = 30000, goldCost = 700},
    {name = "Sleeping Cap", id = "sleeping_cap", rarity = "Common", selectFactorRegular = 10, selectFactorGold = 1, isLimited = false, cost = 4000, goldCost = 200},
    {name = "Mustache", id = "mustache", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = false, cost = 25000, goldCost = 600},
}

function GetPlacementObjectByName(name)
	return PlacementObject[name]
end

function GetPlacementObjectByIndex(index)
  i = 1
	for name, object in pairs(PlacementObject) do
		if i == index then
			return object
		end

		i = i + 1
	end
end

function GetPlacementObjectNameByIndex(index)
  i = 1
	for name, object in pairs(PlacementObject) do
		if i == index then
			return name
		end

		i = i + 1
	end
end


function LookupHatName(id)
    for _, hat in ipairs(hatData) do
        if hat.id == id then
            return hat.name
        end
    end
    return nil -- Return nil if no matching id is found
end

-- Function to calculate total spawn factor
local function GetTotalSelectionFactor(isGold)
    local totalFactor = 0

    for _, hat in ipairs(hatData) do
        if isGold == true then
            factor = hat.selectFactorGold
        else
            factor = hat.selectFactorRegular
        end
        totalFactor = totalFactor + factor
    end
    return totalFactor
end

-- Function to choose a bee species based on spawn factors
function ChooseHat(isGold)
    local totalSpawnFactor = GetTotalSelectionFactor(isGold)
    local rand = math.random() * totalSpawnFactor
    local cumulativeFactor = 0

    for _, hat in ipairs(hatData) do

        if isGold == true then
            factor = hat.selectFactorGold
        else 
            factor = hat.selectFactorRegular
        end

        cumulativeFactor = cumulativeFactor + factor
        if rand <= cumulativeFactor then
            return hat
        end
    end

    -- Fallback in case no species is selected (this shouldn't happen)
    return hat[0]
end