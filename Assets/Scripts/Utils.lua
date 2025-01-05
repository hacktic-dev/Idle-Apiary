--!Type(Module)

--!SerializeField
local beeTextures : {Texture} = nil
--!SerializeField
local hatTextures : {Texture} = nil
--!SerializeField
local placementTextures : {Texture} = nil
--!SerializeField
local placementObjects : {GameObject} = nil

PlacementObject = {
    ["Chair"] = placementObjects[1],
    ["Table"] = placementObjects[2],
    ["Chess Table"] = placementObjects[3],
    ["Book Table"] = placementObjects[4],
    ["White Flower Planter"] = placementObjects[5],
    ["Apple Box"] = placementObjects[6],
    ["Red Mushroom"] = placementObjects[7],
    ["Brown Mushroom"] = placementObjects[8],
    ["Teddy Bear"] = placementObjects[9],
    ["Toy Goose"] = placementObjects[10],
    ["Pillow"] = placementObjects[11],
    ["Fountain"] = placementObjects[12],
    ["Purple Flower"] = placementObjects[13],
    ["Red Flower"] = placementObjects[14],
    ["White Flower"] = placementObjects[15],
    ["Yellow Flower"] = placementObjects[16],
    ["Bee Box"] = placementObjects[17],
    ["Street Lamp"] = placementObjects[18],
    ["Modern Fountain"] = placementObjects[19],
    ["Bench"] = placementObjects[20],
    ["Red Flower Planter"] = placementObjects[21],
    ["Pink Flower Planter"] = placementObjects[22],
    ["White Flower Pot"] = placementObjects[23],
    ["Red Flower Pot"] = placementObjects[24],
    ["Pink Flower Pot"] = placementObjects[25],
    ["Cherry Blossom Petal"] = placementObjects[26],
    ["Cherry Blossom Tree"] = placementObjects[27],
    ["Heart Pillow" ] = placementObjects[28]
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
    ["Meadow Bee"] = beeTextures[26],
    ["Bronze Bee"] = beeTextures[27],
    ["Oceanic Bee"] = beeTextures[28],
    ["Ruby Bee"] = beeTextures[29],
    ["Camo Bee"] = beeTextures[30],
    ["Crystal Bee"] = beeTextures[31],
    ["Techno Bee"] = beeTextures[32],
    ["Psychedelic Bee"] = beeTextures[33],
    ["Romantic Bee"] = beeTextures[34],
    ["Locked"] = beeTextures[35]
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
    ["Heart Headband"] = hatTextures[19]
}

FurnitureImage = {
    ["Chair"] = placementTextures[1],
    ["Table"] = placementTextures[2],
    ["Chess Table"] = placementTextures[3],
    ["Book Table"] = placementTextures[4],
    ["White Flower Planter"] = placementTextures[5],
    ["Apple Box"] = placementTextures[6],
    ["Red Mushroom"] = placementTextures[7],
    ["Brown Mushroom"] = placementTextures[8],
    ["Teddy Bear"] = placementTextures[9],
    ["Toy Goose"] = placementTextures[10],
    ["Pillow"] = placementTextures[11],
    ["Fountain"] = placementTextures[12],
    ["Purple Flower"] = placementTextures[13],
    ["Red Flower"] = placementTextures[14],
    ["White Flower"] = placementTextures[15],
    ["Yellow Flower"] = placementTextures[16],
    ["Purple Flower Greyed"] = placementTextures[17],
    ["Red Flower Greyed"] = placementTextures[18],
    ["White Flower Greyed"] = placementTextures[19],
    ["Yellow Flower Greyed"] = placementTextures[20],
    ["Bee Box"] = placementTextures[21],

    ["Street Lamp"] = placementTextures[22],
    ["Modern Fountain"] = placementTextures[23],
    ["Bench"] = placementTextures[24],
    ["Red Flower Planter"] = placementTextures[25],
    ["Pink Flower Planter"] = placementTextures[26],
    ["White Flower Pot"] = placementTextures[27],
    ["Red Flower Pot"] = placementTextures[28],
    ["Pink Flower Pot"] = placementTextures[29],
    ["Cherry Blossom Petal"] = placementTextures[30],
    ["Cherry Blossom Tree"] = placementTextures[31],
    ["Heart Pillow"] = placementTextures[33]
}

local hatData = 
{
    {name = "Yellow Wooly Hat", id = "yellow_wooly", rarity = "Common", selectFactorRegular = 10, selectFactorGold = 0, isLimited = false, cost = 3000, goldCost = 100},
    {name = "Pink Cap", id = "pink_cap", rarity = "Common", selectFactorRegular = 10, selectFactorGold = 0, isLimited = false, cost = 4000, goldCost = 250},
    {name = "Yellow Bucket Hat", id = "yellow_bucket", rarity = "Uncommon", selectFactorRegular = 5, selectFactorGold = 0,isLimited = false, cost = 12500, goldCost = 400},
    {name = "Traffic Cone", id = "traffic_cone", rarity = "Uncommon", selectFactorRegular = 5, selectFactorGold = 2, isLimited = false, cost = 20000, goldCost = 450},
    {name = "Christmas Elf Hat", id = "christmas_elf", rarity = "Rare", selectFactorRegular = 0, selectFactorGold = 0, isLimited = true, cost = 25000, goldCost = 600},
    {name = "Pirate Hat", id = "pirate_hat", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = false, cost = 35000, goldCost = 750},
    {name = "Pixel Sunglasses", id = "pixel_sunglasses", rarity = "Legendary", selectFactorRegular = 0, selectFactorGold = 10, isLimited = false, cost = -1, goldCost = 850},
    {name = "Gold Crown", id = "gold_crown", rarity = "Legendary", selectFactorRegular = 0, selectFactorGold = 10, isLimited = false, cost = -1, goldCost = 1000},

    {name = "Leather Cap", id = "leather_cap", rarity = "Common", selectFactorRegular = 10, selectFactorGold = 1, isLimited = false, cost = 4000, goldCost = 200},
    {name = "Miner's Helmet", id = "miner_helmet", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8,isLimited = false, cost = 25000, goldCost = 500},
    {name = "Red Beret", id = "red_beret", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = false, cost = 30000, goldCost = 650},
    {name = "Sailor's Hat", id = "sailor_hat", rarity = "Uncommon", selectFactorRegular = 5, selectFactorGold = 2, isLimited = true, cost = 10000, goldCost = 350},
    {name = "Santa Hat", id = "santa_hat", rarity = "Rare", selectFactorRegular = 0, selectFactorGold = 0, isLimited = false, cost = 25000, goldCost = 700},
    {name = "Top Hat", id = "top_hat", rarity = "Legendary", selectFactorRegular = 0, selectFactorGold = 10, isLimited = false, cost = -1, goldCost = 950},
    {name = "Fisherman's Cap", id = "fishermans_cap", rarity = "Uncommon", selectFactorRegular = 5, selectFactorGold = 0, isLimited = false, cost = 10000, goldCost = 300},

    {name = "Cat Ears", id = "cat_ears", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = false, cost = 30000, goldCost = 700},
    {name = "Sleeping Cap", id = "sleeping_cap", rarity = "Common", selectFactorRegular = 10, selectFactorGold = 1, isLimited = false, cost = 4000, goldCost = 200},
    {name = "Mustache", id = "mustache", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = false, cost = 25000, goldCost = 600},
    {name = "Heart Headband", id = "heart_headband", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = false, cost = 35000, goldCost = 500}
}

local furnitureData = {
    {name = "Chair", id = "chair", cost = 6000, goldCost = 200, selectFactorRegular = 10, selectFactorGold = 3},
    {name = "Table", id = "table", cost = 6000, goldCost = 200, selectFactorRegular = 10, selectFactorGold = 3},
    {name = "Chess Table", id = "table_chess", cost = 8000, goldCost = 230, selectFactorRegular = 10, selectFactorGold = 3},
    {name = "Book Table", id = "table_book", cost = 8000, goldCost = 230, selectFactorRegular = 10, selectFactorGold = 3},
    {name = "White Flower Planter", id = "white_flower_planter", cost = 7000, goldCost = 200, selectFactorRegular = 8, selectFactorGold = 12},
    {name = "Apple Box", id = "apple_box", cost = 5000, goldCost = 150, selectFactorRegular = 10, selectFactorGold = 5},
    {name = "Red Mushroom", id = "mushroom_red", cost = 4000, goldCost = 125, selectFactorRegular = 10, selectFactorGold = 10},
    {name = "Brown Mushroom", id = "mushroom_brown", cost = 4000, goldCost = 125, selectFactorRegular = 10, selectFactorGold = 10},
    {name = "Teddy Bear", id = "teddy", cost = 10000, goldCost = 250, selectFactorRegular = 5, selectFactorGold = 18},
    {name = "Toy Goose", id = "goose", cost = 10000, goldCost = 250, selectFactorRegular = 5, selectFactorGold = 18},
    {name = "Pillow", id = "pillow", cost = 4000, goldCost = 125, selectFactorRegular = 10, selectFactorGold = 10},
    {name = "Fountain", id = "fountain", cost = 10000, goldCost = 300, selectFactorRegular = 6, selectFactorGold = 15},
    {name = "Red Flower", id = "Red", cost = 0, goldCost = 0, selectFactorRegular = 0, selectFactorGold = 0},
    {name = "White Flower", id = "White", cost = 0, goldCost = 0, selectFactorRegular = 0, selectFactorGold = 0},
    {name = "Yellow Flower", id = "Yellow", cost = 0, goldCost = 0, selectFactorRegular = 0, selectFactorGold = 0},
    {name = "Purple Flower", id = "Purple", cost = 0, goldCost = 0, selectFactorRegular = 0, selectFactorGold = 0},
    {name = "Bee Box", id = "bee_box", cost = 0, goldCost = 0, selectFactorRegular = 0, selectFactorGold = 0},

    {name = "Street Lamp", id = "street_lamp", cost = 800, goldCost = 250, selectFactorRegular = 10, selectFactorGold = 10},
    {name = "Modern Fountain", id = "modern_fountain", cost = 12000, goldCost = 300, selectFactorRegular = 6, selectFactorGold = 15},
    {name = "Bench", id = "bench", cost = 8000, goldCost = 220, selectFactorRegular = 10, selectFactorGold = 10},
    {name = "Red Flower Planter", id = "red_flower_planter", cost = 7000, goldCost = 200, selectFactorRegular = 8, selectFactorGold = 12},
    {name = "Pink Flower Planter", id = "pink_flower_planter", cost = 7000, goldCost = 200, selectFactorRegular = 8, selectFactorGold = 12},
    {name = "White Flower Pot", id = "white_flower_pot", cost = 5000, goldCost = 150, selectFactorRegular = 10, selectFactorGold = 5},
    {name = "Red Flower Pot", id = "red_flower_pot", cost = 5000, goldCost = 150, selectFactorRegular = 10, selectFactorGold = 5},
    {name = "Pink Flower Pot", id = "pink_flower_pot", cost = 5000, goldCost = 150, selectFactorRegular = 10, selectFactorGold = 5},
    {name = "Cherry Blossom Petal", id = "cherry_blossom_petal", cost = 5000, goldCost = 150, selectFactorRegular = 5, selectFactorGold = 30},
    {name = "Cherry Blossom Tree", id = "cherry_blossom_tree", cost = 25000, goldCost = 400, selectFactorRegular = 4, selectFactorGold = 30},
    {name = "Heart Pillow", id = "heart_pillow", cost = 12000, goldCost = 350, selectFactorRegular = 4, selectFactorGold = 30}
}

function IsHat(id)
    for _, hat in ipairs(hatData) do
        if hat.id == id then
            return true
        end
    end
    return false
end

function IsFurniture(id)
    for _, furniture in ipairs(furnitureData) do
        if furniture.id == id then
            return true
        end
    end
    return false
end

function IsFlower(id)
    return id == "Red" or id == "White" or id == "Yellow" or id == "Purple"
end

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

function GetPlacementObjectIdByName(name)
    for _, furniture in ipairs(furnitureData) do
        if furniture.name == name then
            return furniture.id
        end
    end
    return nil
end


function LookupHatName(id)
    for _, hat in ipairs(hatData) do
        if hat.id == id then
            return hat.name
        end
    end
    return nil -- Return nil if no matching id is found
end

function LookupFurnitureIdByName(Name)
    for _, furniture in ipairs(furnitureData) do
        if furniture.name == Name then
            return furniture.id
        end
    end
    return nil -- Return nil if no matching id is found
end

function LookupFurnitureName(id)
    for _, furniture in ipairs(furnitureData) do
        if furniture.id == id then
            return furniture.name
        end
    end
    return nil -- Return nil if no matching id is found
end

-- Function to calculate total spawn factor
local function GetTotalSelectionFactor(data, isGold)
    local totalFactor = 0

    for _, item in ipairs(data) do
        local factor = isGold and item.selectFactorGold or item.selectFactorRegular
        totalFactor = totalFactor + factor
    end
    return totalFactor
end

-- Function to choose a bee species based on spawn factors
function ChooseHat(isGold)
    local totalSpawnFactor = GetTotalSelectionFactor(hatData, isGold)
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

function ChooseFurniture(isGold)
    local totalSpawnFactor = GetTotalSelectionFactor(furnitureData, isGold)
    local rand = math.random() * totalSpawnFactor
    local cumulativeFactor = 0

    for _, furniture in ipairs(furnitureData) do
        local factor = isGold and furniture.selectFactorGold or furniture.selectFactorRegular
        cumulativeFactor = cumulativeFactor + factor
        if rand <= cumulativeFactor then
            return furniture
        end
    end

    -- Fallback in case no furniture is selected (this shouldn't happen)
    return furnitureData[1]
end
